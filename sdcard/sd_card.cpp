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

}  // namespace

SdCard::SdCard(uint cmd_gpio, uint clk_gpio, uint dat0_gpio)
    : cmd_gpio_(cmd_gpio), clk_gpio_(clk_gpio), dat0_gpio_(dat0_gpio), rca_(0), high_capacity_(false) {}

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

bool SdCard::initialize() {
#ifdef PICO_SD_DAT3_PIN
    _DEBUG_PRINT("SD: initializing with DAT3 pull-up on GPIO %u\n", PICO_SD_DAT3_PIN);
    gpio_init(PICO_SD_DAT3_PIN);
    gpio_set_dir(PICO_SD_DAT3_PIN, GPIO_IN);
    gpio_pull_up(PICO_SD_DAT3_PIN);
#endif

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
