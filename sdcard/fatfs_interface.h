#pragma once

#include "sd_card.h"
#include <cstdio>

#if __has_include("ff.h")
#define PICO_SD_READER_HAS_FATFS 1
extern "C" {
#include "ff.h"
}
#else
#define PICO_SD_READER_HAS_FATFS 0
#endif

class FatFsInterface {
public:
    explicit FatFsInterface(SdCard& sd_card) : sd_card_(sd_card) {}

    bool mount() {
#if PICO_SD_READER_HAS_FATFS
        fatfs_bind_sd_card(&sd_card_);
        const FRESULT result = f_mount(&filesystem_, "", 1);
        if (result != FR_OK) {
            std::printf("FatFs: mount failed (%d)\n", static_cast<int>(result));
            return false;
        }
        return true;
#else
        std::printf("FatFs: ff.h not found, add FatFs sources to enable file listing\n");
        return false;
#endif
    }

    void unmount() {
#if PICO_SD_READER_HAS_FATFS
        (void)f_mount(nullptr, "", 1);
#endif
    }

    FRESULT exists(const char* filename, FILINFO* fno) {
#if PICO_SD_READER_HAS_FATFS
        FRESULT result = f_stat(filename, fno);
        return result;
#else
        (void)filename;
        (void)fno;
        return FR_INVALID_NAME;
#endif
    }

    bool list_root_directory() {
#if PICO_SD_READER_HAS_FATFS
        DIR dir;
        FILINFO info;

        FRESULT result = f_opendir(&dir, "/");
        if (result != FR_OK) {
            std::printf("FatFs: cannot open root directory (%d)\n", static_cast<int>(result));
            return false;
        }

        std::printf("Root directory:\n");
        while (true) {
            result = f_readdir(&dir, &info);
            if (result != FR_OK) {
                std::printf("FatFs: readdir failed (%d)\n", static_cast<int>(result));
                (void)f_closedir(&dir);
                return false;
            }

            if (info.fname[0] == '\0') {
                break;
            }

            const bool is_dir = (info.fattrib & AM_DIR) != 0;
            std::printf("  %c %s\n", is_dir ? 'D' : 'F', info.fname);
        }

        (void)f_closedir(&dir);
        return true;
#else
        return false;
#endif
    }

    FRESULT remove(const char* filename) {
#if PICO_SD_READER_HAS_FATFS
        return f_unlink(filename);
#else
        (void)filename;
        return FR_INVALID_NAME;
#endif
    }

    FRESULT open(FIL* file, const char* filename, BYTE mode) {
#if PICO_SD_READER_HAS_FATFS
        return f_open(file, filename, mode);
#else
        (void)file;
        (void)filename;
        (void)mode;
        return FR_INVALID_NAME;
#endif
    }

    FRESULT read(FIL* file, void* buffer, UINT btr, UINT* br) {
#if PICO_SD_READER_HAS_FATFS
        return f_read(file, buffer, btr, br);
#else
        (void)file;
        (void)buffer;
        (void)btr;
        (void)br;
        return FR_INVALID_NAME;
#endif
    }

    bool read_file(const char* path, uint8_t* buffer, size_t buffer_size, size_t* bytes_read) {
#if PICO_SD_READER_HAS_FATFS
        if (path == nullptr || buffer == nullptr || bytes_read == nullptr) {
            return false;
        }

        FIL file;
        FRESULT result = f_open(&file, path, FA_READ);
        if (result != FR_OK) {
            std::printf("FatFs: cannot open %s (%d)\n", path, static_cast<int>(result));
            return false;
        }

        UINT read_count = 0;
        result = f_read(&file, buffer, static_cast<UINT>(buffer_size), &read_count);
        const FSIZE_t size = f_size(&file);
        (void)f_close(&file);
        if (result != FR_OK) {
            std::printf("FatFs: cannot read %s (%d)\n", path, static_cast<int>(result));
            return false;
        }

        *bytes_read = static_cast<size_t>(read_count);

        std::printf("FatFs: read %u bytes from %s (size=%llu)\n",
                    static_cast<unsigned>(read_count),
                    path,
                    static_cast<unsigned long long>(size));
        return true;
#else
        (void)path;
        (void)buffer;
        (void)buffer_size;
        (void)bytes_read;
        return false;
#endif
    }

private:
    SdCard& sd_card_;

#if PICO_SD_READER_HAS_FATFS
    FATFS filesystem_{};
#endif
};
