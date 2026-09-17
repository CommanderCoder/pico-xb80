#include <stdio.h>
#include <stdint.h>
#include <strings.h> 

#include "pico/stdlib.h"

#include "fatfs_interface.h"

#include "xb_interface/xb_if.h"

#include "sharp-mz80k/sharp_mz.h"

#include "pico-xb80.h"





// couldn't find sd card
bool sd_missing = false;



// Forward declarations
bool InitSDFatFs();


// TEMPORARY DIAGNOSTIC: list every .MZF file on the SD card directly on the
// Pico side (no Z80/PIO involvement at all), to check the SD/FatFs listing
// logic in isolation from the Z80 transport. Remove once confirmed working.
static void list_files_local(const char* extension)
{
  DIR dir;
  FILINFO fno;
  FRESULT result = f_opendir(&dir, ROOT_DIR);
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

void sdinit(void){
  // SD system initialization
  if( !InitSDFatFs() )
  {
    _DEBUG("Failed : SD.begin");
    sd_missing = true;
  }
  else {
    _DEBUG("OK : SD.begin");
    sd_missing = false;
  }

  
  if (!sd_missing) {
    list_files_local("mzf"); // TEMPORARY DIAGNOSTIC
  }

}



// 255 not 256 because FileCount is a count, and not an index, so the maximum index is 254, which is 255 entries in total.
struct FileEntry FileList[255]; // 255 files, each with a max length of 32 characters
uint8_t FileCount = 0; // number of files found
#define getFileCount() (FileCount) // getter for FileCount

void establishFileList(void)
{
  // Open root directory
  DIR dir;
  FILINFO fno;
  FRESULT result = f_opendir(&dir, ROOT_DIR);

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
        FileList[FileCount].fno = fno;

        // Build a sanitized, extension-stripped name for display
        char displayname[32] = {0}; // zero-init guarantees null termination

        int n = len - 4; // length of filename without the extension
        if (n > (int)sizeof(displayname) - 1)
            n = sizeof(displayname) - 1; // clamp so we never write past displayname[]

        memcpy(displayname, fno.fname, n); // safe: n is bounded above

        // Replace non-printable / non-ASCII bytes with '.' for safe display
        for (int i = 0; i < n; i++)
            if ((unsigned char)displayname[i] < 32 || (unsigned char)displayname[i] > 126)
                displayname[i] = '.';

        // Copy into the file list entry, then force a terminator
        // (strncpy won't null-terminate if src fills the whole count)
        strncpy(FileList[FileCount].displayname, displayname, sizeof(FileList[FileCount].displayname) - 1);
        FileList[FileCount].displayname[sizeof(FileList[FileCount].displayname) - 1] = '\0';

        if (++FileCount >= 255) break; // stop once the list is full 
    }
  }
  f_closedir(&dir);

  // NOTE - FileCount is clamped to 255, so if there are more than 255 files, only the first 255 will be stored in FileList.


  // dump the file list for debugging
  _DEBUG("FileCount: %d\n", FileCount);
  for (uint8_t i = 0; i < FileCount; i++)
  {
    _DEBUG("File %d: %s\n", i, FileList[i].displayname);
  }
}

//   // Compare f_name and c_name until c_name contains 0x00
//   // FILENAME COMPARE
bool f_match(char *f_name, char *c_name)
{
  bool flg1 = true;
  unsigned int lp1 = 0;
  
  // If c_name is empty (just null terminator), match all files
  if (c_name[0] == 0x00)
  {
    return true;
  }
  
  // Compare filenames [len 32], f_name & c_name case-insensitively and set flg1 to false if they don't match
  if (strncasecmp(f_name, c_name, 32) != 0)
  {
    flg1 = false;
  }

  return flg1;
}


void init_led()
{
    // Initialize the GPIO pin for the LED
    gpio_init(PICO_DEFAULT_LED_PIN);
    gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);
}

void toggle_led(bool force_off = false)
{
    // Toggle the LED state
    static bool led_state = false;
    led_state = force_off?false:!led_state;
    gpio_put(PICO_DEFAULT_LED_PIN, led_state);
}

int main(void) {
    // prep USB logging
    stdio_init_all();
    sleep_ms(2000);

    _DEBUG("Pico-XB80 for Sharp MZ80K v1.0.0\n");

    // prep GPIO for LED

    init_led();

    toggle_led();
    sleep_ms(1000);
    toggle_led(true); // force off


    // Initialize the SD card and FatFs
    start_xb_interface();

    // Initialise the Sharp MZ series interface
    SharpMZ_initialise();
    

    // Start the command loop for Sharp MZ series commands
    SharpMZ_cmdloop();
    
    // Never reaches here, unless there is problem in cmdloop.
    while (1) {
        sleep_ms(1000);
    }
}
