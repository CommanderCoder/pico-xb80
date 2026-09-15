#pragma once

#include "pico/stdlib.h"
#include "pico/types.h"

// NOTE - SD access is native-mode 1-bit only: the constructor takes a single
// dat0_gpio, and sd_card.cpp's read_data_block_1bit/write_data_block_1bit
// clock one bit per DAT line transition (see the "1bit" in their names).
// DAT3 is only ever driven as a pull-up (to keep the card out of SPI mode,
// see sd_card.cpp around PICO_SD_DAT3_PIN) and DAT1/DAT2 aren't referenced
// at all, so the card is left in its default 1-bit bus width.
//
// Moving to 4-bit would roughly 4x the DAT throughput per clock and needs:
// wiring DAT1-DAT3 to real GPIOs (not just a pull-up), sending ACMD6 after
// CMD55 during init to switch the card into 4-bit mode, and a 4-bit
// read/write_data_block that samples/drives 4 GPIOs per clock instead of 1.
// Also worth pairing with the PIO note below - see it before deciding how
// much to change here.
//
// Separately: this whole driver bit-bangs GPIO with sleep_us() for clock
// timing (kClockHalfPeriodUsData = 1us => ~500kHz, and it's a CPU-blocking
// busy-wait for the whole 512-byte sector, unlike the Z80 side which is all
// PIO+DMA). A PIO-based SD clocking scheme (like the Z80 bus interface
// already uses) would be both much faster and free the CPU core during
// transfers - and would make a 4-bit upgrade a matter of widening the PIO's
// `in`/`out` pin count rather than adding more bit-banged loops.
class SdCard {
public:
    SdCard(uint cmd_gpio, uint clk_gpio, uint dat0_gpio);

    bool initialize();
    bool read_sector(uint32_t lba, uint8_t* buffer, size_t size = 512);
    bool write_sector(uint32_t lba, const uint8_t* buffer, size_t size = 512);

private:
    bool wait_ready(uint32_t timeout_us);
    void send_command_r0(uint8_t command, uint32_t argument);
    bool send_command_r2(uint8_t command, uint32_t argument);
    bool send_command_r1(uint8_t command, uint32_t argument, uint32_t* status);
    bool send_command_r3r7(uint8_t command, uint32_t argument, uint32_t* payload);
    bool send_command_r6(uint8_t command, uint32_t argument, uint32_t* payload);

    uint cmd_gpio_;
    uint clk_gpio_;
    uint dat0_gpio_;
    uint16_t rca_;
    bool high_capacity_;
};

#if __has_include("diskio.h")
extern "C" void fatfs_bind_sd_card(SdCard* card);
#endif
