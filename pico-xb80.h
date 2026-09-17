#pragma once


#include "ff.h"

#define getFileCount() (FileCount) // getter for FileCount
extern uint8_t FileCount; // number of files found

void establishFileList(void);
void sdinit(void);
bool f_match(char *f_name, char *c_name);


// build a local cache of the files in the root directory which end in .MZF or .mzf
struct FileEntry {
  FILINFO fno; // FATFS file info structure
  char displayname[32]; // 32 characters for the filename
};

extern struct FileEntry FileList[255];
