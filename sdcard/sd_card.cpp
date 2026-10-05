// Copyright (c) Andrew Hague (Commander Coder), 21 September 2026
//
// This code may not be reused, in whole or in part, without attribution
// to the author, Andrew Hague (Commander Coder).

#include "sd_card.h"

#include <cstdio>
#include <cstring>

#include "hardware/gpio.h"
#include "pico/time.h"
#include "crc16.h"

// #define _DEBUG_PRINT(...) std::printf(__VA_ARGS__)
#define _DEBUG_PRINT(...) {}
#define _ERROR_PRINT(...) std::printf(__VA_ARGS__)


namespace {
constexpr uint32_t kSectorSize = 512;
constexpr uint32_t kClockHalfPeriodUsInit = 20;
constexpr uint32_t kClockHalfPeriodUsData = 1;

// SPI mode clocks: identification is only guaranteed to work at 100-400kHz,
// data transfers then run as fast as the wiring stands (the card's own SPI
// ceiling is 25MHz).
constexpr uint kSpiBaudrateInit = 400'000;
constexpr uint kSpiBaudrateData = 12'500'000;

constexpr uint8_t kCmd0 = 0;
constexpr uint8_t kCmd2 = 2;
constexpr uint8_t kCmd8 = 8;
constexpr uint8_t kCmd13 = 13;
constexpr uint8_t kCmd16 = 16;
constexpr uint8_t kCmd17 = 17;
constexpr uint8_t kCmd24 = 24;
constexpr uint8_t kCmd3 = 3;
constexpr uint8_t kCmd7 = 7;
constexpr uint8_t kCmd55 = 55;
constexpr uint8_t kCmd58 = 58;  // READ_OCR, SPI mode only
constexpr uint8_t kAcmd41 = 41;

struct ParsedResponse48 {
    uint8_t command_index = 0;
    uint32_t payload = 0;
    bool valid = false;
};

inline void cmd_release(uint cmd_gpio) {
    gpio_set_dir(cmd_gpio, GPIO_IN);
    gpio_pull_up(cmd_gpio);
}

inline void cmd_drive_low(uint cmd_gpio) {
    gpio_set_dir(cmd_gpio, GPIO_OUT);
    gpio_put(cmd_gpio, 0);
}

inline void cmd_drive_high(uint cmd_gpio) {
    gpio_set_dir(cmd_gpio, GPIO_OUT);
    gpio_put(cmd_gpio, 1);
}

inline void clock_high(uint clk_gpio, uint32_t half_period_us) {
    gpio_put(clk_gpio, 1);
    sleep_us(half_period_us);
}

inline void clock_low(uint clk_gpio, uint32_t half_period_us) {
    gpio_put(clk_gpio, 0);
    sleep_us(half_period_us);
}

void clock_write_bit(uint clk_gpio, uint cmd_gpio, bool bit, uint32_t half_period_us) {
    if (bit) {
        cmd_release(cmd_gpio);
    } else {
        cmd_drive_low(cmd_gpio);
    }
    clock_high(clk_gpio, half_period_us);
    clock_low(clk_gpio, half_period_us);
}

bool clock_read_bit(uint clk_gpio, uint gpio, uint32_t half_period_us) {
    clock_high(clk_gpio, half_period_us);
    const bool bit = gpio_get(gpio) != 0;
    clock_low(clk_gpio, half_period_us);
    return bit;
}

uint8_t crc7_sd(const uint8_t* data, size_t len) {
    uint8_t crc = 0;
    for (size_t i = 0; i < len; ++i) {
        uint8_t current = data[i];
        for (int bit = 0; bit < 8; ++bit) {
            crc <<= 1;
            if (((current ^ crc) & 0x80) != 0) {
                crc ^= 0x09;
            }
            current <<= 1;
        }
    }
    return static_cast<uint8_t>(crc & 0x7F);
}

void send_clocks_with_idle_cmd(uint clk_gpio, uint cmd_gpio, uint32_t cycles, uint32_t half_period_us) {
    cmd_release(cmd_gpio);
    for (uint32_t i = 0; i < cycles; ++i) {
        clock_high(clk_gpio, half_period_us);
        clock_low(clk_gpio, half_period_us);
    }
}

void send_command_frame(uint clk_gpio, uint cmd_gpio, uint8_t command, uint32_t argument, uint32_t half_period_us) {
    // SD spec Ncc: minimum 8 clocks between end of previous response and start of next command.
    cmd_release(cmd_gpio);
    for (int i = 0; i < 8; ++i) {
        clock_high(clk_gpio, half_period_us);
        clock_low(clk_gpio, half_period_us);
    }

    uint8_t frame[6] = {
        static_cast<uint8_t>(0x40u | (command & 0x3Fu)),
        static_cast<uint8_t>((argument >> 24) & 0xFFu),
        static_cast<uint8_t>((argument >> 16) & 0xFFu),
        static_cast<uint8_t>((argument >> 8) & 0xFFu),
        static_cast<uint8_t>(argument & 0xFFu),
        0,
    };
    frame[5] = static_cast<uint8_t>((crc7_sd(frame, 5) << 1) | 0x01u);

    for (uint8_t byte : frame) {
        for (int bit = 7; bit >= 0; --bit) {
            clock_write_bit(clk_gpio, cmd_gpio, ((byte >> bit) & 0x01u) != 0, half_period_us);
        }
    }
    cmd_release(cmd_gpio);
}

bool read_response_48(uint clk_gpio, uint cmd_gpio, uint32_t half_period_us, ParsedResponse48* out) {
    constexpr uint32_t kStartTimeoutBits = 20000;

    bool found_start = false;
    for (uint32_t i = 0; i < kStartTimeoutBits; ++i) {
        if (!clock_read_bit(clk_gpio, cmd_gpio, half_period_us)) {
            found_start = true;
            break;
        }
    }
    _DEBUG_PRINT("SD: read_response_48 found_start=%d\n", found_start);
    if (!found_start) {
        return false;
    }

    const bool transmission_bit = clock_read_bit(clk_gpio, cmd_gpio, half_period_us);
    _DEBUG_PRINT("SD: read_response_48 transmission_bit=%d\n", transmission_bit);
    if (transmission_bit) {
        return false;
    }

    uint8_t cmd_index = 0;
    for (int i = 0; i < 6; ++i) {
        cmd_index = static_cast<uint8_t>((cmd_index << 1) | (clock_read_bit(clk_gpio, cmd_gpio, half_period_us) ? 1u : 0u));
    }

    uint32_t payload = 0;
    for (int i = 0; i < 32; ++i) {
        payload = static_cast<uint32_t>((payload << 1) | (clock_read_bit(clk_gpio, cmd_gpio, half_period_us) ? 1u : 0u));
    }

// https://users.ece.utexas.edu/~valvano/EE345M/SD_Physical_Layer_Spec.pdf

    // payload of 0x00000900 means bits 12:9 [CURRENT_STATE] and 8 [READY_FOR_DATA] are set,  
    // Current State of 0b0100 = Transfer state, and Ready for Data = 1 means the card is ready to accept the next command or data block,

    uint8_t crc = 0; // CRC7
    for (int i = 0; i < 7; ++i) {
        crc = static_cast<uint8_t>((crc << 1) | (clock_read_bit(clk_gpio, cmd_gpio, half_period_us) ? 1u : 0u));
    }

    // end bit
    const bool end_bit = clock_read_bit(clk_gpio, cmd_gpio, half_period_us);
    _DEBUG_PRINT("SD: read_response_48 cmd_index=%d, payload=0x%08X, end_bit=%d\n", cmd_index, payload, end_bit);
    if (!end_bit) {
        return false;
    }

    // get some more bits to ensure the card has finished transmitting and released the CMD line (required before next command).
    for (int i = 0; i < 16; ++i) {
        (void)clock_read_bit(clk_gpio, cmd_gpio, half_period_us);
    }

    out->command_index = cmd_index;
    out->payload = payload;
    out->valid = true;
    return true;
}

bool read_data_block_1bit(uint clk_gpio, uint cmd_gpio, uint dat0_gpio, uint32_t half_period_us, uint8_t* buffer, size_t size) {
    constexpr uint32_t kDataStartTimeoutBits = 200000;
    cmd_release(cmd_gpio);

    bool found_start = false;
    for (uint32_t i = 0; i < kDataStartTimeoutBits; ++i) {
        if (!clock_read_bit(clk_gpio, dat0_gpio, half_period_us)) {
            found_start = true;
            break;
        }
    }
    if (!found_start) {
        return false;
    }

    for (size_t i = 0; i < size; ++i) {
        uint8_t value = 0;
        for (int bit = 0; bit < 8; ++bit) {
            value = static_cast<uint8_t>((value << 1) | (clock_read_bit(clk_gpio, dat0_gpio, half_period_us) ? 1u : 0u));
        }
        buffer[i] = value;
        }

        // discard CRC
    for (int i = 0; i < 16; ++i) {
        (void)clock_read_bit(clk_gpio, dat0_gpio, half_period_us);
    }

    const bool end_bit = clock_read_bit(clk_gpio, dat0_gpio, half_period_us);
  
    // Data-to-Command Turnaround 
    // Minimum wait: You must provide at least 8 clock cycles (1 byte worth of clocks) after the End Bit before initiating the next command

    // Clock out 16 extra cycles so the card fully processes the command.
    for (int i = 0; i < 16; ++i) {
        clock_high(clk_gpio, kClockHalfPeriodUsInit);
        clock_low(clk_gpio, kClockHalfPeriodUsInit);
    }
    
    // need this 10ms - no idea why.
    sleep_ms(10);

    return end_bit;
}


// Returns true if the card accepted the data block.
bool write_data_block_1bit(uint clk_gpio,
                           uint cmd_gpio,
                           uint dat0_gpio,
                           uint32_t half_period_us,
                           const uint8_t* buffer,
                           size_t size) {
    if (!buffer || size == 0) {
        return false;
    }

  
    // // Optional: debug dump
    // _DEBUG_PRINT("SD: write_data_block_1bit writing %u bytes:\n", (unsigned)size);
    // for (size_t i = 0; i < size; ++i) {
    //     _DEBUG_PRINT("0x%02X ", buffer[i]);
    //     if ((i + 1) % 16 == 0) {
    //         _DEBUG_PRINT("  ");
    //         for (size_t j = i + 1 - 16; j <= i; ++j) {
    //             uint8_t b = buffer[j];
    //             _DEBUG_PRINT("%c", (b >= 32 && b <= 126) ? b : '.');
    //         }
    //         _DEBUG_PRINT("\n");
    //     }
    // }
    // _DEBUG_PRINT("\n");

    // fill a buffer with 0xff and calculate the CRC
    uint8_t crc_buffer[kSectorSize];
    std::memset(crc_buffer, 0xFF, sizeof(crc_buffer));
    uint16_t crcFF = calculate_sd_crc16_fast(crc_buffer, sizeof(crc_buffer));
    _DEBUG_PRINT("SD: 0xff buffer calculated CRC=0x%04X\n", crcFF);



      // Release CMD so the card can drive responses.
    cmd_release(cmd_gpio); 
    // // 3) Provide at least 8 clocks before the card responds
    // for (int i = 0; i < 8; ++i) {
    //     clock_high(clk_gpio, half_period_us);
    //     clock_low(clk_gpio, half_period_us);
    // }

    // 1) Start token (0xFE) on DAT0
    const uint8_t start_token = 0xFE;
    for (int bit = 7; bit >= 0; --bit) {
        bool v = ((start_token >> bit) & 0x01u) != 0;
        clock_write_bit(clk_gpio, dat0_gpio, v, half_period_us);
    }

    // 2) Data + CRC16-CCITT
    uint16_t crc = 0x0000;
    for (size_t i = 0; i < size; ++i) {
        uint8_t value = buffer[i];

        // Update CRC
		crc = crc16_table[((crc>>8) ^ value) & 0xff] ^ (crc << 8);

        // Send byte MSB first
        for (int bit = 7; bit >= 0; --bit) {
            bool v = ((value >> bit) & 0x01u) != 0;
            clock_write_bit(clk_gpio, dat0_gpio, v, half_period_us);
        }
    }

    // Send CRC (MSB first)
    for (int bit = 15; bit >= 0; --bit) {
        bool v = ((crc >> bit) & 0x01u) != 0;
        clock_write_bit(clk_gpio, dat0_gpio, v, half_period_us);
        }

    // Release DAT0 so the card can drive the data-response token.
    cmd_release(dat0_gpio);

    // // Provide a few extra clocks for the card to process the received block
    // // and start driving the response token, then give a short delay.
    // for (int i = 0; i < 8; ++i) {
    //     clock_high(clk_gpio, half_period_us);
    //     clock_low(clk_gpio, half_period_us);
    // }
    // sleep_ms(1);

    // 4) Read the 8-bit data response token from DAT0 (status is its 3-bit sss field):
    // read the data response token from the card
    // The card will respond with a 3-bit token indicating the result of the write operation:
    // 0b010: Data accepted
    // 0b101: Data rejected due to a CRC error
    // 0b110: Data rejected due to a write error (e.g., trying to write to a write-protected card)
    // getting byte 0xE5: 0b11100101 which is 0bxxx0sssx 
    // so response is 0b010 = accepted
    uint8_t response_token = 0;
    for (int bit = 0; bit < 8; ++bit) {
        bool bit_val = clock_read_bit(clk_gpio, dat0_gpio, half_period_us);
        response_token = static_cast<uint16_t>((response_token << 1) | (bit_val ? 1u : 0u));
    }
    // Print the raw response token to aid debugging (visible on serial).
    _DEBUG_PRINT("SD: write_data_block_1bit response_token_raw=0x%02X\n", response_token);

    uint8_t status = (response_token >> 1) & 0b111; // sss field

    // 5) Card busy: DAT0 held low while programming
    constexpr uint32_t kBusyTimeoutBits = 1'000'000; // tune as needed
    uint32_t busy_count = 0;

    // Wait for DAT0 to go low (busy start)
    while (clock_read_bit(clk_gpio, dat0_gpio, half_period_us)) {
        if (++busy_count > kBusyTimeoutBits) {
            _ERROR_PRINT("SD: write_data_block_1bit timeout waiting for busy start\n");
            return false;
        }
    }

    _ERROR_PRINT("SDCARD: busy count %d\n",busy_count);

    // Wait for DAT0 to go high again (busy end)
    busy_count = 0;
    while (!clock_read_bit(clk_gpio, dat0_gpio, half_period_us)) {
        if (++busy_count > kBusyTimeoutBits) {
            _ERROR_PRINT("SD: write_data_block_1bit timeout waiting for busy end\n");
            return false;
        }
    }

    if (status != 0b010) { // 010 = data accepted
        _ERROR_PRINT("SD: write_data_block_1bit write failed, status=0b%03u\n", status);
        return false;
    }

    _DEBUG_PRINT("SD: write_data_block_1bit response_token=0x%02X status=0b%03u, CRC=0x%04X\n",
                 response_token, status, crc);

    cmd_release(cmd_gpio);

    // At this point the card is ready for the next command.
    return true;
}

// ---------------------------------------------------------------------------
// SPI mode
//
// The same SD command set, but framed a byte at a time by the SPI block: six
// bytes of command out, then an R1 status byte clocked in (plus four payload
// bytes for R3/R7). The card leaves DO high whenever it has nothing to say,
// so "reading" is really "shift out 0xFF and keep whatever comes back".
// ---------------------------------------------------------------------------

enum class SpiRole : uint { Rx = 0, Csn = 1, Sck = 2, Tx = 3 };

// Bank-0 pinmap: FUNCSEL 1 (GPIO_FUNC_SPI) cycles RX, CSn, SCK, TX every four
// GPIOs and alternates spi0/spi1 every eight, the whole way up GPIO0..47. A
// given pin can therefore only ever carry one SPI role on one instance, which
// is what makes SPI availability a property of the wiring rather than a
// choice. Returns nullptr when this gpio cannot be `role`.
spi_inst_t* spi_instance_for(uint gpio, SpiRole role) {
    if (gpio >= NUM_BANK0_GPIOS) {
        return nullptr;
    }
    if (static_cast<uint>(role) != (gpio & 3u)) {
        return nullptr;
    }
    return ((gpio >> 3) & 1u) != 0 ? spi1 : spi0;
}

uint8_t spi_xfer(spi_inst_t* spi, uint8_t value) {
    uint8_t received = 0xFF;
    (void)spi_write_read_blocking(spi, &value, &received, 1);
    return received;
}

// The card pulls DO low for as long as it is busy programming; 0xFF is idle.
bool spi_wait_not_busy(spi_inst_t* spi, uint32_t timeout_ms) {
    const absolute_time_t deadline = make_timeout_time_ms(timeout_ms);
    do {
        if (spi_xfer(spi, 0xFF) == 0xFF) {
            return true;
        }
    } while (absolute_time_diff_us(get_absolute_time(), deadline) > 0);
    return false;
}

// Returns the R1 status byte, or 0xFF if the card never answered.
uint8_t spi_send_command(spi_inst_t* spi, uint8_t command, uint32_t argument) {
    uint8_t frame[6] = {
        static_cast<uint8_t>(0x40u | (command & 0x3Fu)),
        static_cast<uint8_t>((argument >> 24) & 0xFFu),
        static_cast<uint8_t>((argument >> 16) & 0xFFu),
        static_cast<uint8_t>((argument >> 8) & 0xFFu),
        static_cast<uint8_t>(argument & 0xFFu),
        0,
    };
    // CRC is otherwise ignored in SPI mode, but CMD0 and CMD8 are checked -
    // and crc7_sd produces the 0x95/0x87 they expect, so no special case.
    frame[5] = static_cast<uint8_t>((crc7_sd(frame, 5) << 1) | 0x01u);
    (void)spi_write_blocking(spi, frame, sizeof(frame));

    // Ncr: the response lands within 8 bytes and is flagged by a clear bit 7.
    for (int i = 0; i < 10; ++i) {
        const uint8_t r1 = spi_xfer(spi, 0xFF);
        if ((r1 & 0x80u) == 0) {
            return r1;
        }
    }
    return 0xFF;
}

// R3 (OCR) and R7 (CMD8 voltage echo) are an R1 byte plus a 32-bit payload.
uint8_t spi_send_command_r3r7(spi_inst_t* spi, uint8_t command, uint32_t argument, uint32_t* payload) {
    const uint8_t r1 = spi_send_command(spi, command, argument);
    // A card rejecting the command as illegal sends no payload to collect.
    if ((r1 & 0x04u) != 0) {
        return r1;
    }

    uint8_t bytes[4] = {0, 0, 0, 0};
    (void)spi_read_blocking(spi, 0xFF, bytes, sizeof(bytes));
    if (payload != nullptr) {
        *payload = (static_cast<uint32_t>(bytes[0]) << 24) |
                   (static_cast<uint32_t>(bytes[1]) << 16) |
                   (static_cast<uint32_t>(bytes[2]) << 8) |
                   static_cast<uint32_t>(bytes[3]);
    }
    return r1;
}

bool spi_read_data_block(spi_inst_t* spi, uint8_t* buffer, size_t size) {
    // Nac: wait for the 0xFE start token. Anything else with a clear top
    // nibble is an error token (out of range, CC error, ECC failure, ...).
    const absolute_time_t deadline = make_timeout_time_ms(300);
    while (true) {
        const uint8_t token = spi_xfer(spi, 0xFF);
        if (token == 0xFEu) {
            break;
        }
        if ((token & 0xF0u) == 0) {
            _ERROR_PRINT("SD: SPI read error token 0x%02X\n", token);
            return false;
        }
        if (absolute_time_diff_us(get_absolute_time(), deadline) <= 0) {
            _ERROR_PRINT("SD: SPI read timed out waiting for data token\n");
            return false;
        }
    }

    (void)spi_read_blocking(spi, 0xFF, buffer, size);

    uint8_t crc_bytes[2] = {0, 0};
    (void)spi_read_blocking(spi, 0xFF, crc_bytes, sizeof(crc_bytes));
    const uint16_t received = static_cast<uint16_t>((crc_bytes[0] << 8) | crc_bytes[1]);
    const uint16_t computed = calculate_sd_crc16_fast(buffer, size);
    // Data blocks always carry a real CRC16 - CMD59 only governs whether the
    // card checks the ones we send - so a mismatch is a genuine error.
    if (received != computed) {
        _ERROR_PRINT("SD: SPI read CRC mismatch (card=0x%04X computed=0x%04X)\n", received, computed);
        return false;
    }
    return true;
}

bool spi_write_data_block(spi_inst_t* spi, const uint8_t* buffer, size_t size) {
    spi_xfer(spi, 0xFF);  // Nwr: one idle byte ahead of the start token

    const uint8_t token = 0xFE;
    (void)spi_write_blocking(spi, &token, 1);
    (void)spi_write_blocking(spi, buffer, size);

    const uint16_t crc = calculate_sd_crc16_fast(buffer, size);
    const uint8_t crc_bytes[2] = {
        static_cast<uint8_t>(crc >> 8),
        static_cast<uint8_t>(crc & 0xFFu),
    };
    (void)spi_write_blocking(spi, crc_bytes, sizeof(crc_bytes));

    // Data response token is xxx0sss1; sss = 010 is accepted, 101 a CRC
    // error and 110 a write error.
    uint8_t response = 0xFF;
    for (int i = 0; i < 10; ++i) {
        response = spi_xfer(spi, 0xFF);
        if ((response & 0x11u) == 0x01u) {
            break;
        }
    }
    const uint8_t status = static_cast<uint8_t>((response >> 1) & 0x07u);
    if (status != 0x02u) {
        _ERROR_PRINT("SD: SPI write rejected, token=0x%02X status=0b%03u\n", response, status);
        return false;
    }

    // DO stays low for as long as the card is programming the block.
    if (!spi_wait_not_busy(spi, 1000)) {
        _ERROR_PRINT("SD: SPI write timed out while the card was programming\n");
        return false;
    }

    _DEBUG_PRINT("SD: SPI write accepted, CRC=0x%04X\n", crc);
    return true;
}

// Is something off-chip holding this pin up?
//
// Enable the RP2350's own pull-down and see who wins. The SD_DAT0 net carries
// a 10k pull-up to 3V3 on the board (R21 on the Olimex schematic), which
// against the internal pull-down's ~60k leaves the pin near 2.8V - a solid
// high. A pin that is only a header pin has nothing on it and follows the
// pull-down to 0. The pull-up is on the board rather than in the card, so
// this reads the same with an empty socket.
//
// The pin's current function is put back afterwards: GPIO24 is inside the
// 16..47 block that eb_gpio_init() hands to the PIO, and probing it should
// not quietly take it away.
bool gpio_sees_external_pullup(uint gpio) {
    const gpio_function_t previous = gpio_get_function(gpio);

    gpio_set_function(gpio, GPIO_FUNC_SIO);
    gpio_set_dir(gpio, GPIO_IN);
    gpio_pull_down(gpio);
    sleep_us(200);  // settle through the net's RC
    const bool high = gpio_get(gpio);

    gpio_disable_pulls(gpio);
    gpio_set_function(gpio, previous);
    return high;
}

}  // namespace

// Deliberately electrical rather than a protocol probe. Asking the card
// instead would mean sending it CMD0, and a CMD0 seen with CS low latches a
// card into SPI mode until the power is cycled - so a guess that went wrong
// could not be taken back. Reading the pull-ups commits to nothing.
SdBoardRevision SdCard::detect_board_revision() {
    const bool dat0_on_revision_a_pin = gpio_sees_external_pullup(kSdDat0GpioRevisionA);
    const bool dat0_on_revision_b_pin = gpio_sees_external_pullup(kSdDat0GpioRevisionB);

    if (dat0_on_revision_b_pin && !dat0_on_revision_a_pin) {
        return SdBoardRevision::RevisionB;
    }
    if (dat0_on_revision_a_pin && !dat0_on_revision_b_pin) {
        return SdBoardRevision::RevisionA;
    }

    // Neither pin pulled up (no SD/MMC fitted at all?) or both did (something
    // else wired to the spare pin on the extension header).
    _ERROR_PRINT("SD: board revision undetermined (GPIO%u=%d GPIO%u=%d)\n",
                 kSdDat0GpioRevisionA, dat0_on_revision_a_pin,
                 kSdDat0GpioRevisionB, dat0_on_revision_b_pin);
    return SdBoardRevision::Unknown;
}

const char* SdCard::board_revision_name(SdBoardRevision revision) {
    switch (revision) {
        case SdBoardRevision::RevisionA: return "Revision A";
        case SdBoardRevision::RevisionB: return "Revision B";
        default: return "unknown revision";
    }
}

SdCard::SdCard(uint cmd_gpio, uint clk_gpio, uint dat0_gpio, uint cs_gpio, bool probe_spi)
    : cmd_gpio_(cmd_gpio),
      clk_gpio_(clk_gpio),
      dat0_gpio_(dat0_gpio),
      cs_gpio_(cs_gpio),
      probe_spi_(probe_spi),
      mode_(SdBusMode::Native1Bit),
      spi_(nullptr),
      rca_(0),
      high_capacity_(false) {}

// Revision A has no CS connection (R24 unpopulated), so there is nothing for
// the SPI probe to find and it is skipped outright. A Revision A board with
// R24 fitted can still get SPI by naming the pins explicitly instead.
// Unknown is treated as Revision B, which is what current boards are.
SdCard::SdCard(SdBoardRevision revision)
    : SdCard(kSdCmdGpio,
             kSdClkGpio,
             revision == SdBoardRevision::RevisionA ? kSdDat0GpioRevisionA : kSdDat0GpioRevisionB,
             kSdCsGpio,
             revision != SdBoardRevision::RevisionA) {}

const char* SdCard::bus_mode_name() const {
    return mode_ == SdBusMode::Spi ? "SPI" : "native 1-bit";
}

// Probe SPI when the wiring allows it, otherwise stay on the native 1-bit
// path. The order is forced by the card: it latches SPI mode on the first
// CMD0 it sees with CS low and cannot leave again until power is cycled,
// while native mode (CMD0 with CS high) can still be followed by an SPI
// attempt. SPI-then-native is therefore the recoverable direction.
bool SdCard::initialize() {
    if (spi_wiring_supported()) {
        if (initialize_spi()) {
            mode_ = SdBusMode::Spi;
            return true;
        }
        // If the card did answer CMD0 before failing later on, it is now
        // latched into SPI mode and the native attempt below will fail too -
        // that is as far as recovery goes without a power cycle.
        _ERROR_PRINT("SD: SPI unavailable, falling back to native 1-bit mode\n");
        release_spi();
    }

    mode_ = SdBusMode::Native1Bit;
    return initialize_native();
}

bool SdCard::spi_wiring_supported() const {
    if (!probe_spi_ || cs_gpio_ == kSdNoPin || cs_gpio_ >= NUM_BANK0_GPIOS) {
        return false;
    }
    // CS is driven as a plain GPIO (see spi_select), so it only has to exist.
    // CLK/DI/DO have to be the SCK/TX/RX pins of one and the same instance.
    spi_inst_t* const sck = spi_instance_for(clk_gpio_, SpiRole::Sck);
    spi_inst_t* const tx = spi_instance_for(cmd_gpio_, SpiRole::Tx);
    spi_inst_t* const rx = spi_instance_for(dat0_gpio_, SpiRole::Rx);
    return sck != nullptr && sck == tx && sck == rx;
}

void SdCard::spi_select() {
    gpio_put(cs_gpio_, 0);
    spi_xfer(spi_, 0xFF);  // lead-in byte once CS is asserted
}

void SdCard::spi_deselect() {
    gpio_put(cs_gpio_, 1);
    spi_xfer(spi_, 0xFF);  // trailing byte so the card lets go of DO
}

bool SdCard::initialize_spi() {
    spi_ = spi_instance_for(clk_gpio_, SpiRole::Sck);
    if (spi_ == nullptr) {
        return false;
    }

    spi_init(spi_, kSpiBaudrateInit);
    spi_set_format(spi_, 8, SPI_CPOL_0, SPI_CPHA_0, SPI_MSB_FIRST);
    gpio_set_function(clk_gpio_, GPIO_FUNC_SPI);
    gpio_set_function(cmd_gpio_, GPIO_FUNC_SPI);
    gpio_set_function(dat0_gpio_, GPIO_FUNC_SPI);
    gpio_pull_up(dat0_gpio_);  // DO floats while the card is deselected

    // CS is bit-banged rather than handed to the SPI block's own CSn, which
    // deasserts per transfer; SD needs it held across a whole command plus
    // its response and data block.
    gpio_init(cs_gpio_);
    gpio_set_dir(cs_gpio_, GPIO_OUT);
    gpio_put(cs_gpio_, 1);

    auto fail = [this](const char* why) {
        _ERROR_PRINT("SD: SPI probe failed - %s\n", why);
        gpio_put(cs_gpio_, 1);
        return false;
    };

    // >= 74 clocks with CS and DI high is the card's power-up wake sequence.
    for (int i = 0; i < 10; ++i) {
        spi_xfer(spi_, 0xFF);
    }

    gpio_put(cs_gpio_, 0);
    spi_xfer(spi_, 0xFF);  // lead-in byte once CS is asserted

    // CMD0 received with CS low is what selects SPI mode. A card that will
    // not answer here is exactly the signal to fall back to native 1-bit.
    bool idle = false;
    for (int i = 0; i < 10 && !idle; ++i) {
        idle = (spi_send_command(spi_, kCmd0, 0) == 0x01u);
    }
    if (!idle) {
        return fail("no response to CMD0");
    }

    uint32_t r7 = 0;
    if (spi_send_command_r3r7(spi_, kCmd8, 0x1AA, &r7) != 0x01u || (r7 & 0xFFFu) != 0x1AAu) {
        return fail("CMD8 rejected (pre-2.0 card?)");
    }

    // ACMD41 with HCS set; the card clears R1's idle bit once it is ready.
    bool ready = false;
    for (int i = 0; i < 200 && !ready; ++i) {
        (void)spi_send_command(spi_, kCmd55, 0);
        ready = (spi_send_command(spi_, kAcmd41, 0x40000000UL) == 0x00u);
        if (!ready) {
            sleep_ms(10);
        }
    }
    if (!ready) {
        return fail("ACMD41 timeout");
    }

    uint32_t ocr = 0;
    if (spi_send_command_r3r7(spi_, kCmd58, 0, &ocr) != 0x00u) {
        return fail("CMD58 failed");
    }
    // CCS (OCR bit 30) set means the card is addressed in blocks, not bytes.
    high_capacity_ = (ocr & (1u << 30)) != 0;

    if (!high_capacity_ && spi_send_command(spi_, kCmd16, kSectorSize) != 0x00u) {
        return fail("CMD16 failed");
    }

    gpio_put(cs_gpio_, 1);
    spi_xfer(spi_, 0xFF);

    // Identification done - wind the clock up for data transfers.
    const uint baudrate = spi_set_baudrate(spi_, kSpiBaudrateData);

    // RCA only exists on the native bus; in SPI mode CS does the selecting.
    rca_ = 0;
    _DEBUG_PRINT("\nSD: SPI init done (%s, %u Hz)\n", high_capacity_ ? "SDHC/SDXC" : "SDSC", baudrate);
    return true;
}

void SdCard::release_spi() {
    if (spi_ != nullptr) {
        spi_deinit(spi_);
        spi_ = nullptr;
    }
    // Hand the pins back as plain GPIOs for the bit-banged native path.
    gpio_set_function(clk_gpio_, GPIO_FUNC_SIO);
    gpio_set_function(cmd_gpio_, GPIO_FUNC_SIO);
    gpio_set_function(dat0_gpio_, GPIO_FUNC_SIO);
}

bool SdCard::read_sector_spi(uint32_t lba, uint8_t* buffer, size_t size) {
    const uint32_t argument = high_capacity_ ? lba : (lba * kSectorSize);

    spi_select();
    if (!spi_wait_not_busy(spi_, 500)) {
        _ERROR_PRINT("SD: SPI card still busy before CMD17\n");
        spi_deselect();
        return false;
    }

    const uint8_t r1 = spi_send_command(spi_, kCmd17, argument);
    if (r1 != 0x00u) {
        _ERROR_PRINT("SD: SPI CMD17 failed (r1=0x%02X)\n", r1);
        spi_deselect();
        return false;
    }

    const bool ok = spi_read_data_block(spi_, buffer, size);
    spi_deselect();
    return ok;
}

bool SdCard::write_sector_spi(uint32_t lba, const uint8_t* buffer, size_t size) {
    const uint32_t argument = high_capacity_ ? lba : (lba * kSectorSize);

    spi_select();
    if (!spi_wait_not_busy(spi_, 500)) {
        _ERROR_PRINT("SD: SPI card still busy before CMD24\n");
        spi_deselect();
        return false;
    }

    const uint8_t r1 = spi_send_command(spi_, kCmd24, argument);
    if (r1 != 0x00u) {
        _ERROR_PRINT("SD: SPI CMD24 failed (r1=0x%02X)\n", r1);
        spi_deselect();
        return false;
    }

    bool ok = spi_write_data_block(spi_, buffer, size);

    // The write is only really done once the card reports a clean status.
    if (ok) {
        uint32_t status = 0;
        // R2: an R1 byte plus a second status byte, both zero when happy.
        const uint8_t r2_first = spi_send_command(spi_, kCmd13, 0);
        const uint8_t r2_second = spi_xfer(spi_, 0xFF);
        status = (static_cast<uint32_t>(r2_first) << 8) | r2_second;
        if (status != 0) {
            _ERROR_PRINT("SD: SPI CMD13 error status=0x%04X\n", status);
            ok = false;
        }
    }

    spi_deselect();
    return ok;
}

bool SdCard::wait_ready(uint32_t timeout_us) {
    const absolute_time_t deadline = make_timeout_time_us(timeout_us);
    while (absolute_time_diff_us(get_absolute_time(), deadline) > 0) {
        if (gpio_get(dat0_gpio_) != 0) {
            return true;
        }
        (void)clock_read_bit(clk_gpio_, dat0_gpio_, kClockHalfPeriodUsInit);
    }
    return false;
}

void SdCard::send_command_r0(uint8_t command, uint32_t argument) {
    // R0 = no response (e.g. CMD0 in native SD mode).
    _DEBUG_PRINT("SD: CMD%d (no response expected)\n", command);
    send_command_frame(clk_gpio_, cmd_gpio_, command, argument, kClockHalfPeriodUsInit);
    // Clock out 8 extra cycles so the card fully processes the command.
    for (int i = 0; i < 8; ++i) {
        clock_high(clk_gpio_, kClockHalfPeriodUsInit);
        clock_low(clk_gpio_, kClockHalfPeriodUsInit);
    }
    cmd_release(cmd_gpio_);
}

bool SdCard::send_command_r1(uint8_t command, uint32_t argument, uint32_t* status) {
    _DEBUG_PRINT("SD: CMD%d arg=0x%08X\n", command, argument);
    if (!wait_ready(500000)) {
        return false;
    }
    _DEBUG_PRINT("SD: CMD%d ready, sending command frame\n", command);
    send_command_frame(clk_gpio_, cmd_gpio_, command, argument, kClockHalfPeriodUsInit);

    ParsedResponse48 response{};
    _DEBUG_PRINT("SD: CMD%d waiting for response\n", command);
    if (!read_response_48(clk_gpio_, cmd_gpio_, kClockHalfPeriodUsInit, &response)) {
        return false;
    }
    _DEBUG_PRINT("SD: CMD%d got response (cmd_index=%d, payload=0x%08X)\n", command, response.command_index, response.payload);
    if (response.command_index != command) {
        return false;
    }
    _DEBUG_PRINT("SD: CMD%d response valid\n", command);
    if (status != nullptr) {
        *status = response.payload;
    }
    return true;
}

bool SdCard::send_command_r3r7(uint8_t command, uint32_t argument, uint32_t* payload) {
    if (!wait_ready(500000)) {
        return false;
    }
    send_command_frame(clk_gpio_, cmd_gpio_, command, argument, kClockHalfPeriodUsInit);

    ParsedResponse48 response{};
    if (!read_response_48(clk_gpio_, cmd_gpio_, kClockHalfPeriodUsInit, &response)) {
        return false;
    }
    // R3 (OCR) response sets command index bits to 0x3F, not the actual command.
    // R7 (CMD8) does echo the index, but we accept both here.
    if (payload != nullptr) {
        *payload = response.payload;
    }
    return true;
}

bool SdCard::send_command_r2(uint8_t command, uint32_t argument) {
    // R2 response is 136 bits. We must consume it fully so CMD line is free for CMD3.
    if (!wait_ready(500000)) {
        return false;
    }
    send_command_frame(clk_gpio_, cmd_gpio_, command, argument, kClockHalfPeriodUsInit);

    constexpr uint32_t kStartTimeoutBits = 20000;
    bool found_start = false;
    for (uint32_t i = 0; i < kStartTimeoutBits; ++i) {
        if (!clock_read_bit(clk_gpio_, cmd_gpio_, kClockHalfPeriodUsInit)) {
            found_start = true;
            break;
        }
    }
    _DEBUG_PRINT("SD: CMD2 R2 found_start=%d\n", found_start);
    if (!found_start) {
        return false;
    }
    // Discard remaining 135 bits (transmission + reserved + CID[127:0] + CRC + end).
    for (int i = 0; i < 135; ++i) {
        (void)clock_read_bit(clk_gpio_, cmd_gpio_, kClockHalfPeriodUsInit);
    }
    return true;
}

bool SdCard::send_command_r6(uint8_t command, uint32_t argument, uint32_t* payload) {
    if (!wait_ready(500000)) {
        return false;
    }
    send_command_frame(clk_gpio_, cmd_gpio_, command, argument, kClockHalfPeriodUsInit);

    ParsedResponse48 response{};
    if (!read_response_48(clk_gpio_, cmd_gpio_, kClockHalfPeriodUsInit, &response)) {
        return false;
    }
    if (response.command_index != command) {
        return false;
    }
    if (payload != nullptr) {
        *payload = response.payload;
    }
    return true;
}

bool SdCard::initialize_native() {
    // DAT3 is the same physical pin as CS and has to be high when CMD0 goes
    // out, or the card would select SPI mode. Pull it up rather than drive
    // it: on the native bus it is a data line the card may own.
    if (cs_gpio_ != kSdNoPin) {
        _DEBUG_PRINT("SD: initializing with DAT3 pull-up on GPIO %u\n", cs_gpio_);
        gpio_init(cs_gpio_);
        gpio_set_dir(cs_gpio_, GPIO_IN);
        gpio_pull_up(cs_gpio_);
    }

    gpio_init(clk_gpio_);
    gpio_set_dir(clk_gpio_, GPIO_OUT);
    gpio_put(clk_gpio_, 0);

    gpio_init(cmd_gpio_);
    cmd_release(cmd_gpio_);

    gpio_init(dat0_gpio_);
    gpio_set_dir(dat0_gpio_, GPIO_IN);
    gpio_pull_up(dat0_gpio_);

    send_clocks_with_idle_cmd(clk_gpio_, cmd_gpio_, 80, kClockHalfPeriodUsInit);

    // CMD0 is R0 in native SD mode — the card resets to idle with no response.
    send_command_r0(kCmd0, 0);
    sleep_ms(2);
    uint32_t status = 0;

    uint32_t r7 = 0;
    if (!send_command_r3r7(kCmd8, 0x1AA, &r7) || (r7 & 0xFFFu) != 0x1AAu) {
        _ERROR_PRINT("SD: CMD8 failed or unsupported card\n");
        return false;
    }

    bool ready = false;
    uint32_t ocr = 0;
    for (int i = 0; i < 200; ++i) {
        if (!send_command_r1(kCmd55, 0, &status)) {
            _ERROR_PRINT("SD: CMD55 failed\n");
            return false;
        }
        // Bit 30 = HCS (host supports SDHC/SDXC), bits 23:15 = 2.7–3.6 V voltage window.
        // Sending a non-zero voltage window is required; all-zero means "query only" and
        // the card will never set OCR bit 31 to signal ready.
        if (!send_command_r3r7(kAcmd41, 0x40FF8000UL, &ocr)) {
            _ERROR_PRINT("SD: ACMD41 failed\n");
            return false;
        }
        if ((ocr & (1u << 31)) != 0) {
            ready = true;
            break;
        }
        sleep_ms(10);
    }

    if (!ready) {
        _ERROR_PRINT("SD: ACMD41 timeout\n");
        return false;
    }

    // CMD2: ALL_SEND_CID — card moves READY→IDENTIFICATION; required before CMD3.
    if (!send_command_r2(kCmd2, 0)) {
        _ERROR_PRINT("SD: CMD2 failed\n");
        return false;
    }

    uint32_t r6 = 0;
    if (!send_command_r6(kCmd3, 0, &r6)) {
        _ERROR_PRINT("SD: CMD3 failed\n");
        return false;
    }
    rca_ = static_cast<uint16_t>(r6 >> 16);

    if (!send_command_r1(kCmd7, static_cast<uint32_t>(rca_) << 16, &status)) {
        _ERROR_PRINT("SD: CMD7 failed\n");
        return false;
    }

    high_capacity_ = (ocr & (1u << 30)) != 0;
    if (!high_capacity_) {
        if (!send_command_r1(kCmd16, 512, &status)) {
            _ERROR_PRINT("SD: CMD16 failed\n");
            return false;
        }
    }

    _DEBUG_PRINT("\nSD: init done (%s, RCA=0x%04X)\n", high_capacity_ ? "SDHC/SDXC" : "SDSC", rca_);
    return true;
}

bool SdCard::read_sector(uint32_t lba, uint8_t* buffer, size_t size) {
    if (buffer == nullptr || size != kSectorSize) {
        return false;
    }

    return mode_ == SdBusMode::Spi ? read_sector_spi(lba, buffer, size)
                                   : read_sector_native(lba, buffer, size);
}

bool SdCard::read_sector_native(uint32_t lba, uint8_t* buffer, size_t size) {

    const uint32_t argument = high_capacity_ ? lba : (lba * kSectorSize);
    uint32_t status = 0;
    if (!send_command_r1(kCmd17, argument, &status)) {
        return false;
    }

    return read_data_block_1bit(clk_gpio_, cmd_gpio_, dat0_gpio_, kClockHalfPeriodUsData, buffer, size);
}


bool SdCard::write_sector(uint32_t lba, const uint8_t* buffer, size_t size) {
    if (buffer == nullptr || size != kSectorSize) {
        return false;
    }

    return mode_ == SdBusMode::Spi ? write_sector_spi(lba, buffer, size)
                                   : write_sector_native(lba, buffer, size);
}

bool SdCard::write_sector_native(uint32_t lba, const uint8_t* buffer, size_t size) {

    const uint32_t argument = high_capacity_ ? lba : (lba * kSectorSize);
    uint32_t status = 0;
    if (!send_command_r1(kCmd24, argument, &status)) {
        return false;
    }

    bool r = write_data_block_1bit(clk_gpio_, cmd_gpio_, dat0_gpio_, kClockHalfPeriodUsData, buffer, size);

        // now use SEND_STATUS to see what is happening
    while(true) {
        send_command_r1(kCmd13, 0, &status); // card zero
        _DEBUG_PRINT("SD: CMD13 status=0x%08X\n", status);
        if ((status & 0xFF) != 0) {
            _ERROR_PRINT("SD: CMD13 error status=0x%08X\n", status);
            return false;
        }
        if ((status & 0x100) == 0x100 && (status & 0x800) == 0x800) {
            break; // card is ready and in transfer state
        }
    }

    return r;
}


#if __has_include("diskio.h")
extern "C" {
#include "ff.h"
#include "diskio.h"
}

namespace {
SdCard* g_bound_sd_card = nullptr;
uint32_t g_lba_offset = 0;  // LBA start of the first recognised FAT32 partition
}

extern "C" void fatfs_bind_sd_card(SdCard* card) {
    g_bound_sd_card = card;

    // Parse the MBR partition table and record the LBA offset of the first
    // FAT32 partition so disk_read can transparently redirect FatFS.
    g_lba_offset = 0;
    static uint8_t mbr[512];
    _DEBUG_PRINT("FatFs: reading sector 0 for MBR scan\n");
    if (card->read_sector(0, mbr, sizeof(mbr))) {
        _DEBUG_PRINT("FatFs: sector 0 read ok sig=%02X%02X bpb0=%02X\n",
                    mbr[510], mbr[511], mbr[0]);
        const bool has_mbr_sig = (mbr[510] == 0x55u && mbr[511] == 0xAAu);
        const bool is_bpb = (mbr[0] == 0xEBu || mbr[0] == 0xE9u);
        if (has_mbr_sig && !is_bpb) {
            for (int e = 0; e < 4; ++e) {
                const uint8_t* pt = &mbr[446 + e * 16];
                const uint8_t type = pt[4];
                _DEBUG_PRINT("FatFs: MBR entry %d type=0x%02X\n", e + 1, type);
                if (type == 0x0Bu || type == 0x0Cu) {
                    const uint32_t lba =
                        static_cast<uint32_t>(pt[8]) |
                        (static_cast<uint32_t>(pt[9]) << 8) |
                        (static_cast<uint32_t>(pt[10]) << 16) |
                        (static_cast<uint32_t>(pt[11]) << 24);
                    if (lba > 0) {
                        g_lba_offset = lba;
                        _DEBUG_PRINT("FatFs: MBR partition %d type=0x%02X at LBA %lu\n",
                                    e + 1, type, static_cast<unsigned long>(lba));
                        break;
                    }
                }
            }
            if (g_lba_offset > 0) {
                static uint8_t boot_sector[512];
                if (card->read_sector(g_lba_offset, boot_sector, sizeof(boot_sector))) {
                    const bool has_boot_sig = (boot_sector[510] == 0x55u && boot_sector[511] == 0xAAu);
                    if (!has_boot_sig) {
                        _ERROR_PRINT("FatFs: invalid FAT32 boot sector signature at LBA %lu\n",
                                    static_cast<unsigned long>(g_lba_offset));
                        g_lba_offset = 0;
                    }
                } else {
                    _ERROR_PRINT("FatFs: failed to read FAT32 boot sector at LBA %lu\n",
                                static_cast<unsigned long>(g_lba_offset));
                    g_lba_offset = 0;
                }
            }
        }
    } else {
        _ERROR_PRINT("FatFs: sector 0 read FAILED\n");
    }
}

extern "C" DSTATUS disk_initialize(BYTE pdrv) {
    if (pdrv != 0 || g_bound_sd_card == nullptr) {
        return STA_NOINIT;
    }
    return 0;
}

extern "C" DSTATUS disk_status(BYTE pdrv) {
    if (pdrv != 0 || g_bound_sd_card == nullptr) {
        return STA_NOINIT;
    }
    return 0;
}

extern "C" DRESULT disk_read(BYTE pdrv, BYTE* buff, LBA_t sector, UINT count) {
    if (pdrv != 0 || g_bound_sd_card == nullptr || buff == nullptr || count == 0) {
        return RES_PARERR;
    }

    for (UINT i = 0; i < count; ++i) {
        if (!g_bound_sd_card->read_sector(static_cast<uint32_t>(sector + i) + g_lba_offset, buff + (i * kSectorSize), kSectorSize)) {
            return RES_ERROR;
        }
    }

    return RES_OK;
}

extern "C" DRESULT disk_write(BYTE pdrv, const BYTE* buff, LBA_t sector, UINT count) {
    if (pdrv != 0 || g_bound_sd_card == nullptr || buff == nullptr || count == 0) {
        return RES_PARERR;
    }

    for (UINT i = 0; i < count; ++i) {
        if (!g_bound_sd_card->write_sector(static_cast<uint32_t>(sector + i) + g_lba_offset, buff + (i * kSectorSize), kSectorSize)) {
            return RES_ERROR;
        }
    }

    //return RES_WRPRT;

    return RES_OK;
}

extern "C" DRESULT disk_ioctl(BYTE pdrv, BYTE cmd, void* buff) {
    if (pdrv != 0) {
        return RES_PARERR;
    }

    switch (cmd) {
        case CTRL_SYNC:
            return RES_OK;
        case GET_SECTOR_SIZE:
            if (buff == nullptr) {
                return RES_PARERR;
            }
            *static_cast<WORD*>(buff) = static_cast<WORD>(kSectorSize);
            return RES_OK;
        default:
            return RES_PARERR;
    }
}
#endif
