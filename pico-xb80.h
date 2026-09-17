#pragma once

uint8_t getFileCount(void);
char* getDisplayName(uint8_t index);
char* getFileName(uint8_t index);

void establishFileList(void);

void list_files_local(const char* extension); // TEMPORARY DIAGNOSTIC: list every .MZF file on the SD card directly on the Pico side (no Z80/PIO involvement at all), to check the SD/FatFs listing logic in isolation from the Z80 transport. Remove once confirmed working.
