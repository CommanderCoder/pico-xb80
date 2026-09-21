// Copyright (c) Andrew Hague (Commander Coder), 21 September 2026
//
// This code may not be reused, in whole or in part, without attribution
// to the author, Andrew Hague (Commander Coder).

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

void list_files_local(const char* extension, const char* rootdir="/"); // Diagnostic: Pico-side listing of the .MZF files, run by sdinit() after each mount

void set_led(bool on=false);
