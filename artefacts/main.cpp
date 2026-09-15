#include <cstdio>
#include <cstring>
#include "fatfs_interface.h"
#include "pico/stdlib.h"
#include "sd_card.h"

#define _ERROR_PRINT(...) {}

namespace {

constexpr uint kClkPin = 10;
constexpr uint kCmdPin = 11;
constexpr uint kDat0Pin = 12; // pin 12 on Revision A boards, pin 24 on Revision B boards

}  // namespace

void hex_dump(const char* title, const uint8_t* data, size_t size) { 
    std::printf("%s (%zu bytes):\n", title, size);
    for (size_t i = 0; i < size; i += 16) {
        std::printf("  %04zx:", i);
        for (size_t j = 0; j < 16 && (i + j) < size; ++j) {
            std::printf(" %02X", data[i + j]);
        }
        // ascii representation of 16 bytes
        std::printf("  ");
        for (size_t j = 0; j < 16 && (i + j) < size; ++j) {
            const uint8_t byte = data[i + j];
            std::printf("%c", (byte >= 32 && byte <= 126) ? byte : '.');
        }
        std::printf("\n");
    }
}

bool read_vbr_sector(SdCard& sd, uint8_t* vbr, uint32_t* out_vbr_lba) {
    static uint8_t sector0[512];
    if (!sd.read_sector(0, sector0, sizeof(sector0))) {
        _ERROR_PRINT("Test VBR: cannot read sector 0\n");
        return false;
    }

    if (sector0[510] != 0x55 || sector0[511] != 0xAA) {
        _ERROR_PRINT("Test VBR: invalid sector 0 signature %02X %02X\n", sector0[510], sector0[511]);
        return false;
    }

    uint32_t vbr_lba = 0;
    const bool looks_like_bpb = (sector0[0] == 0xEB || sector0[0] == 0xE9);
    if (!looks_like_bpb) {
        for (int e = 0; e < 4; ++e) {
            const uint8_t* pt = &sector0[446 + (e * 16)];
            const uint8_t type = pt[4];
            if (type == 0x0B || type == 0x0C) {
                vbr_lba = static_cast<uint32_t>(pt[8]) |
                          (static_cast<uint32_t>(pt[9]) << 8) |
                          (static_cast<uint32_t>(pt[10]) << 16) |
                          (static_cast<uint32_t>(pt[11]) << 24);
                if (vbr_lba != 0) {
                    break;
                }
            }
        }
    }

    if (!sd.read_sector(vbr_lba, vbr, 512)) {
        _ERROR_PRINT("Test VBR: cannot read VBR sector at LBA %lu\n", static_cast<unsigned long>(vbr_lba));
        return false;
    }
    *out_vbr_lba = vbr_lba;
    return true;
}

bool test_vbr_oem(SdCard& sd) {
    static uint8_t vbr[512];
    uint32_t vbr_lba = 0;
    if (!read_vbr_sector(sd, vbr, &vbr_lba)) {
        return false;
    }

    char oem[9]{};
    std::memcpy(oem, &vbr[3], 8);
    std::printf("Test 1/4 VBR OEM (LBA %lu): \"%s\"\n", static_cast<unsigned long>(vbr_lba), oem);
    if (std::memcmp(oem, "SD  4.4", 7) != 0) {
        std::printf("Test 1/4 warning: OEM prefix is not \"SD  4.4\"\n");
    }
    return true;
}

bool test_read_0000_mzt(FatFsInterface& fatfs) {
    static uint8_t buffer[128];
    size_t bytes_read = 0;
    if (!fatfs.read_file("/0000.mzt", buffer, sizeof(buffer), &bytes_read)) {
        std::printf("Test 4/4 failed: cannot read /0000.mzt\n");
        return false;
    }

    std::printf("Test 4/4 /0000.mzt first %u bytes:", static_cast<unsigned>(bytes_read));
    for (size_t i = 0; i < bytes_read; ++i) {
        std::printf(" %02X", buffer[i]);
    }
    std::printf("\n");
    return true;
}

int main() {
    stdio_init_all();
    sleep_ms(2000);

    std::printf("\n\npico-sd-reader starting...\n");
    SdCard sd(kCmdPin, kClkPin, kDat0Pin);

    if (!sd.initialize()) {
        std::printf("SD: initialization failed\n");
        while (true) {
            sleep_ms(1000);
        }
    }

    bool all_passed = true;
    all_passed = test_vbr_oem(sd) && all_passed;

    FatFsInterface fatfs(sd);
    if (!fatfs.mount()) {
        std::printf("Test 2/4 failed: FatFs mount\n");
        all_passed = false;
    } else {
        std::printf("Test 2/4 passed: FatFs mount\n");
        if (!fatfs.list_root_directory()) {
            std::printf("Test 3/4 failed: list root directory\n");
            all_passed = false;
        } else {
            std::printf("Test 3/4 passed: list root directory\n");
        }
        all_passed = test_read_0000_mzt(fatfs) && all_passed;
    }
    fatfs.unmount();

    std::printf("SD file tests: %s\n", all_passed ? "PASSED" : "FAILED");
    while (true) {
        sleep_ms(1000);
    }
}
