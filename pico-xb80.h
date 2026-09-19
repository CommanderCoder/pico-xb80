#pragma once

// MZF header layout: byte 0 is the file type, bytes 1..17 hold the IBF name
// terminated by CR. OPERATING.md calls this the IBF filename and it is what
// gets listed and compared against, not the name on the SD card.
#define IBF_NAME_OFFSET 1
#define IBF_NAME_MAX    17

uint8_t getFileCount(void);
char* getDisplayName(uint8_t index);  // IBF name, tagged <1 <2 ... when shared
char* getRawName(uint8_t index);      // IBF name exactly as the header holds it
char* getFileName(uint8_t index);     // filename on the SD card
uint8_t getFileAttr(uint8_t index);   // MZF type byte

void establishFileList(const char* rootdir="/");

void list_files_local(const char* extension, const char* rootdir="/"); // TEMPORARY DIAGNOSTIC: list every .MZF file on the SD card directly on the Pico side (no Z80/PIO involvement at all), to check the SD/FatFs listing logic in isolation from the Z80 transport. Remove once confirmed working.

void set_led(bool on=false);
