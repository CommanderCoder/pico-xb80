// Copyright (c) Andrew Hague (Commander Coder), 21 September 2026
//
// This code may not be reused, in whole or in part, without attribution
// to the author, Andrew Hague (Commander Coder).

#include <stdio.h>
#include <stdint.h>
#include <strings.h> 

#include "pico/stdlib.h"

#include "fatfs_interface.h"

#include "xb_interface/xb_if.h"

#include "sharp-mz80k/sharp_mz.h"

#include "pico-xb80.h"



// Diagnostic: list every .MZF file on the SD card directly on the Pico side
// (no Z80/PIO involvement at all). Called from sdinit() after each successful
// mount as a sanity check of the SD/FatFs listing logic, independent of the
// Z80 transport.
void list_files_local(const char* extension, const char* rootdir)
{
  DIR dir;
  FILINFO fno;
  FRESULT result = f_opendir(&dir, rootdir);
  if (result != FR_OK) {
    _DEBUG("list_files_local: f_opendir failed");
    return;
  }

  _DEBUG("--- files on SD (Pico-local listing) ---");
  int count = 0;
  while (1) {
    result = f_readdir(&dir, &fno);
    if (result != FR_OK || fno.fname[0] == '\0') {
      break;
    }

    int len = strlen(fno.fname);
    if (len == 0 || fno.fname[0] == '.' || len < 4) {
      continue;
    }
    const char *ext = &fno.fname[len - 3];
    if (strncasecmp(ext, extension, 3) != 0)
    {
      continue;
    }

    _DEBUG("  %s  (%lu bytes)\n", fno.fname, (unsigned long)fno.fsize);
    count++;
  }
  f_closedir(&dir);
  _DEBUG("---  %d file(s) found with extension .%s ---\n", count, extension);
}


// build a local cache of the files in the root directory which end in .MZF or .mzf
struct FileEntry {
  FILINFO fno;        // FATFS file info structure - the SD card filename
  char rawname[IBF_NAME_MAX + 1];     // IBF name exactly as the header holds it
  char displayname[IBF_NAME_MAX + 1]; // same, tagged <1 <2 ... if it is shared
  uint8_t attr;       // MZF type byte (header offset 0)
};

// 255 not 256 because FileCount is a count, and not an index, so the maximum index is 254, which is 255 entries in total.
static struct FileEntry FileList[255];
static uint8_t FileCount = 0; // number of files found

uint8_t getFileCount(void){
  return FileCount;
}

char* getDisplayName(uint8_t index){
  if (index >= FileCount) {
    return nullptr; // or handle error as appropriate
  }
  return FileList[index].displayname;
}

char* getFileName(uint8_t index){
  if (index >= FileCount) {
    return nullptr; // or handle error as appropriate
  }
  return FileList[index].fno.fname;
}

char* getRawName(uint8_t index){
  if (index >= FileCount) {
    return nullptr;
  }
  return FileList[index].rawname;
}

uint8_t getFileAttr(uint8_t index){
  if (index >= FileCount) {
    return 0;
  }
  return FileList[index].attr;
}

// Read the MZF header prefix: byte 0 is the file type and bytes 1..17 hold the
// IBF name terminated by CR. See OPERATING.md - the IBF name, not the SD card
// filename, is what gets listed and what filenames are compared against.
// Returns false if the file is too short or unreadable to carry a header.
static bool readHeaderInfo(const char* path, uint8_t* attr, char* ibf, size_t ibf_len)
{
  FIL fp;
  if (f_open(&fp, path, FA_READ) != FR_OK) {
    return false;
  }

  uint8_t hdr[IBF_NAME_OFFSET + IBF_NAME_MAX];
  UINT br = 0;
  FRESULT res = f_read(&fp, hdr, sizeof(hdr), &br);
  f_close(&fp);

  if (res != FR_OK || br < sizeof(hdr)) {
    return false;
  }

  *attr = hdr[0];

  // Header names are a fixed-width field, so they are commonly padded with
  // spaces at both ends. Trim them: the padding is not part of the name and
  // a leading space would otherwise defeat the menu's first-letter filter.
  size_t start = IBF_NAME_OFFSET;
  size_t end = IBF_NAME_OFFSET + IBF_NAME_MAX;
  for (size_t i = IBF_NAME_OFFSET; i < end; i++) {
    if (hdr[i] == 0x0D) { end = i; break; }   // CR ends the name field
  }
  while (start < end && hdr[start] == ' ') start++;
  while (end > start && hdr[end - 1] == ' ') end--;

  size_t n = 0;
  for (size_t i = start; i < end && n + 1 < ibf_len; i++) {
    unsigned char c = hdr[i];
    ibf[n++] = (c >= 32 && c <= 126) ? (char)c : '.';
  }
  ibf[n] = '\0';

  return n > 0;
}

// Append "<n" to a name, overwriting its tail if there is no room to grow.
static void tagName(char* name, size_t name_size, unsigned seq)
{
  char suffix[8];
  int slen = snprintf(suffix, sizeof(suffix), "<%u", seq);
  if (slen <= 0 || (size_t)slen >= name_size) return;

  const size_t room = name_size - 1;      // characters the buffer can hold
  size_t len = strlen(name);
  size_t at = (len + (size_t)slen <= room) ? len : room - (size_t)slen;

  memcpy(name + at, suffix, (size_t)slen);
  name[at + (size_t)slen] = '\0';
}

// IBF names are not unique - a patched copy normally keeps the header of the
// original it was built from, so two files happily claim the same name. Tag
// every member of such a group <1, <2, <3 ... so each can be picked out of the
// listing and referenced on its own.
//
// Only this scanned listing is tagged. The files on the card are not touched,
// and rawname still holds what the header actually says.
static void disambiguateNames(void)
{
  bool tagged[255] = { false };

  for (uint8_t i = 0; i < FileCount; i++)
  {
    if (tagged[i]) continue;

    // Count the files sharing this name, including this one
    uint8_t shared = 0;
    for (uint8_t j = i; j < FileCount; j++)
    {
      if (!tagged[j] && strcasecmp(FileList[j].rawname, FileList[i].rawname) == 0) shared++;
    }
    if (shared < 2) continue;

    // Number them in the order the directory scan found them
    const char* base = FileList[i].rawname;
    unsigned seq = 0;
    for (uint8_t j = i; j < FileCount; j++)
    {
      if (tagged[j] || strcasecmp(FileList[j].rawname, base) != 0) continue;
      tagName(FileList[j].displayname, sizeof(FileList[j].displayname), ++seq);
      tagged[j] = true;
    }
  }
}

void establishFileList(const char* rootdir)
{
  // Open root directory
  DIR dir;
  FILINFO fno;
  FRESULT result = f_opendir(&dir, rootdir);

  FileCount = 0; // reset file count
  
  // Count files in the root MZ_FD directory
  while (true)
  {
    result = f_readdir(&dir, &fno);
    if (result != FR_OK || fno.fname[0] == '\0')
    {
      // End of directory
      break;
    }

    int len = strlen(fno.fname);

    // Check for a .MZF/.mzf extension (case-sensitive match on both variants)
    if (len >= 4 && (!strcmp(fno.fname + len - 4, ".MZF") || !strcmp(fno.fname + len - 4, ".mzf")) && fno.fname[0] != '.')
    {
        struct FileEntry* entry = &FileList[FileCount];
        entry->fno = fno;
        entry->attr = 0;
        entry->rawname[0] = '\0';

        // The name to list is the IBF name inside the header, not the SD
        // card filename, so read it back out of the file itself.
        char path[300];
        snprintf(path, sizeof(path), "%s/%s", rootdir, fno.fname);

        if (!readHeaderInfo(path, &entry->attr,
                            entry->rawname, sizeof(entry->rawname)))
        {
            // No usable header - fall back to the SD name minus ".mzf" so the
            // file is still reachable rather than being listed as blank.
            int n = len - 4;
            if (n > (int)sizeof(entry->rawname) - 1)
                n = sizeof(entry->rawname) - 1;
            memcpy(entry->rawname, fno.fname, n);
            entry->rawname[n] = '\0';

        }

        // Starts out identical - disambiguateNames() adds a tag below if this
        // name turns out to be shared with another file.
        memcpy(entry->displayname, entry->rawname, sizeof(entry->rawname));

        if (++FileCount >= 255) break; // stop once the list is full
    }
  }
  f_closedir(&dir);

  disambiguateNames();

  // NOTE - FileCount is clamped to 255, so if there are more than 255 files, only the first 255 will be stored in FileList.


  // dump the file list for debugging
  _DEBUG("FileCount: %d\n", FileCount);
  for (uint8_t i = 0; i < FileCount; i++)
  {
    char othername[IBF_NAME_MAX + 1];
    memcpy(othername, FileList[i].rawname, sizeof(othername));
    int n = strlen(othername);
    for (int i = 0; i < n; i++)
     if ((unsigned char)othername[i] < 32 ||
        (unsigned char)othername[i] > 126)
        othername[i] = '.';

    _DEBUG("File %d: %s\n", i, othername);
  }
}


void init_led()
{
    // Initialize the GPIO pin for the LED
    gpio_init(PICO_DEFAULT_LED_PIN);
    gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);
}

void set_led(bool on)
{
    gpio_put(PICO_DEFAULT_LED_PIN, on ? 1 : 0);
}


int main(void) {
    // prep USB logging
    stdio_init_all();
    sleep_ms(2000);

    _DEBUG("Pico-XB80 for Sharp MZ80K v1.0.0\n");

   

    // Start the Z80 expansion bus interface (PIO + DMA shadow memory). The
    // SD card and FatFs are brought up later by sdinit() from the command loop.
    start_xb_interface();

    // Initialise the Sharp MZ series interface
    SharpMZ_initialise();
    
  // prep GPIO for LED - must come after setup of interface 
  // since that will change pin 25 state to input for the SD card interface

    init_led();

    set_led(true);
    sleep_ms(1000);
    set_led(false); // force off

    // Start the command loop for Sharp MZ series commands
    SharpMZ_cmdloop();
    
    // Never reaches here, unless there is problem in cmdloop.
    while (1) {
        sleep_ms(1000);
    }
}
