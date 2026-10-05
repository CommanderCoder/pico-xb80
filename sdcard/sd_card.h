// Copyright (c) Andrew Hague (Commander Coder), 21 September 2026
//
// This code may not be reused, in whole or in part, without attribution
// to the author, Andrew Hague (Commander Coder).

#pragma once

#include "pico/stdlib.h"
#include "pico/types.h"
#include "hardware/spi.h"

// Pass as cs_gpio when SD pin 1 (CS/DAT3) is not wired to a GPIO at all.
// Without it there is no way to select SPI mode, so the card is driven in
// native 1-bit mode only.
static constexpr uint kSdNoPin = ~0u;

enum class SdBusMode : uint8_t {
    Native1Bit,  // bit-banged SD native mode, 1-bit DAT bus
    Spi,         // hardware SPI block (spi0/spi1), 8 bits per transfer
};

// Two transports to the same card, chosen at initialize() time:
//
//   SPI (preferred when available) drives the card through one of the RP2350's
//   SPI blocks, so a sector moves as 512 hardware-clocked bytes at
//   kSpiBaudrateData instead of 4096 bit-banged GPIO transitions. This needs
//   CS wired to a GPIO and CLK/DI/DO to land on pins that can carry the SCK/TX/RX
//   functions of one SPI instance (see spi_instance_for() in sd_card.cpp) -
//   the bank-0 pinmap fixes which pins those are, it is not a free choice.
//
//   Native 1-bit is the fallback and the mode this driver has always used:
//   it bit-bangs CMD/CLK/DAT0 with sleep_us() timing
//   (kClockHalfPeriodUsData = 1us => ~500kHz) and busy-waits the CPU for the
//   whole 512-byte sector, unlike the Z80 side which is all PIO+DMA. DAT1/DAT2
//   are never referenced and DAT3 is only held high (as a pull-up on cs_gpio,
//   which is the same physical pin), so the card stays at its default 1-bit
//   bus width.
//
// initialize() probes SPI first when the wiring allows it and falls back to
// native 1-bit if the card does not answer. The probe order matters: a card
// latches SPI mode on the first CMD0 it sees with CS low and will not leave
// it again until power is cycled, whereas native mode (CMD0 with CS high) can
// still be followed by an SPI attempt. So the recoverable direction is
// SPI-then-native, which is what this does.
//
// Still open on the native path: 4-bit mode would roughly 4x DAT throughput
// per clock but needs DAT1-DAT3 on real GPIOs, ACMD6 after CMD55 during init,
// and a 4-bit read/write_data_block. And a PIO-based clocking scheme (like the
// Z80 bus interface already uses) would beat bit-banging outright and free the
// core during transfers. Both only matter on boards where SPI is unavailable.
class SdCard {
public:
    // cmd_gpio is SD pin 2 (CMD in native mode, DI/MOSI in SPI mode),
    // dat0_gpio is SD pin 7 (DAT0 / DO/MISO), cs_gpio is SD pin 1
    // (DAT3 / CS). Set probe_spi false to stay on the native 1-bit path
    // regardless of wiring.
    SdCard(uint cmd_gpio, uint clk_gpio, uint dat0_gpio,
           uint cs_gpio = kSdNoPin, bool probe_spi = true);

    bool initialize();
    bool read_sector(uint32_t lba, uint8_t* buffer, size_t size = 512);
    bool write_sector(uint32_t lba, const uint8_t* buffer, size_t size = 512);

    SdBusMode bus_mode() const { return mode_; }
    const char* bus_mode_name() const;

private:
    // --- native 1-bit mode ---
    bool initialize_native();
    bool wait_ready(uint32_t timeout_us);
    void send_command_r0(uint8_t command, uint32_t argument);
    bool send_command_r2(uint8_t command, uint32_t argument);
    bool send_command_r1(uint8_t command, uint32_t argument, uint32_t* status);
    bool send_command_r3r7(uint8_t command, uint32_t argument, uint32_t* payload);
    bool send_command_r6(uint8_t command, uint32_t argument, uint32_t* payload);
    bool read_sector_native(uint32_t lba, uint8_t* buffer, size_t size);
    bool write_sector_native(uint32_t lba, const uint8_t* buffer, size_t size);

    // --- SPI mode ---
    bool spi_wiring_supported() const;  // can these GPIOs carry one SPI instance?
    bool initialize_spi();
    void release_spi();                 // hand the pins back to the native path
    void spi_select();
    void spi_deselect();
    bool read_sector_spi(uint32_t lba, uint8_t* buffer, size_t size);
    bool write_sector_spi(uint32_t lba, const uint8_t* buffer, size_t size);

    uint cmd_gpio_;
    uint clk_gpio_;
    uint dat0_gpio_;
    uint cs_gpio_;
    bool probe_spi_;
    SdBusMode mode_;
    spi_inst_t* spi_;
    uint16_t rca_;
    bool high_capacity_;
};

#if __has_include("diskio.h")
extern "C" void fatfs_bind_sd_card(SdCard* card);
#endif
