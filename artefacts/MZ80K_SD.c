#include "pico/stdlib.h"
#include <stdio.h>
#include "sdcard_src/fatfs/ff.h"

#include "sdcard_src/fatfs_interface.h"

#include "scramble.h"
#include "mincave.h"
#include "basic.h"

#include "cursed_chambers.h"

// Persistent FatFs and SD objects
static FIL current_file;
static int sd_initialized = 0;

namespace {
constexpr uint kClkPin = 10;
constexpr uint kCmdPin = 11;
constexpr uint kDat0Pin = 12; // pin 12 on Revision A boards, pin 24 on Revision B boards
}  // namespace

// These are allocated on first use and kept for the program lifetime so
// FatFs has a stable FATFS structure owned by the FatFsInterface instance.
static class SdCard* g_sd = nullptr;
static class FatFsInterface* g_fatfs = nullptr;

// Fallback in-memory filesystem for ROM data
char filenames[10][1] = {"B", "S",  "M", "C", "", "", "", "", "", ""};
uint8_t const* filesystem[10] = { basic_sp_5025_data, scramble_data, minotaurs_cave_data, cursed_chambers_data, 0, 0, 0, 0, 0, 0};
int filesizes[10] = { sizeof(basic_sp_5025_data), sizeof(scramble_data), sizeof(minotaurs_cave_data), sizeof(cursed_chambers_data), 0, 0, 0, 0, 0, 0};
int curpos = 0;


bool SD_begin() {
  // Allocate SD and FatFsInterface once and keep them alive for the
  // lifetime of the program so the FATFS object inside FatFsInterface
  // remains valid after this function returns.
  if (g_sd == nullptr) {
    g_sd = new SdCard(kCmdPin, kClkPin, kDat0Pin);
  }

  if (!g_sd->initialize()) {
    printf("SD: initialization failed\n");
    return false;
  }
  printf("SD: initialization succeeded\n");

  if (g_fatfs == nullptr) {
    g_fatfs = new FatFsInterface(*g_sd);
  }

  // Initialize FatFs filesystem via the C++ wrapper
  printf("Initializing FatFs\n");

  if (g_fatfs->mount()) {
    printf("FatFs mounted successfully\n");
    sd_initialized = 1;
    return true;
  } else {
    printf("FatFs mount failed\n");
    g_fatfs->unmount();
    sd_initialized = 0;
    return false;
  }
}

bool SD_exists(const char* filename) {
    if (!sd_initialized) return false;
    
    FILINFO fno;
    FRESULT result = f_stat(filename, &fno);
    return result == FR_OK;
}

bool SD_remove(const char* filename) {
    if (!sd_initialized) return false;
    
    FRESULT result = f_unlink(filename);
    return result == FR_OK;
}

int SD_open(const char* filename, int mode) {
    if (!sd_initialized) {
        // Try in-memory filesystem as fallback
        for (int i = 0; i < 10; i++) {
            if (filename[0] == filenames[i][0]) {
                curpos = 0;
                return i;
            }
        }
        return -1;
    }
    
    BYTE fatfs_mode = 0;
    if (mode == 0) {  // FILE_READ
        fatfs_mode = FA_READ;
    } else {  // FILE_WRITE
        fatfs_mode = FA_CREATE_ALWAYS | FA_WRITE;
    }
    
    FRESULT result = f_open(&current_file, filename, fatfs_mode);
    if (result == FR_OK) {
        return 0;  // Valid file handle
    }
    return -1;  // Error
}

uint8_t SD_read(int file_handle) {
    // If file_handle is from in-memory filesystem
    if (file_handle >= 0 && file_handle < 10 && !sd_initialized) {
        if (curpos < filesizes[file_handle]) {
            return filesystem[file_handle][curpos++];
        } else {
            return 0;  // End of file
        }
    }
    
    // Read from SD card
    if (sd_initialized && file_handle == 0) {
        uint8_t byte;
        UINT bytes_read;
        FRESULT result = f_read(&current_file, &byte, 1, &bytes_read);
        if (result == FR_OK && bytes_read == 1) {
            return byte;
        }
        return 0;
    }
    
    return 0;
}

void SD_seek(int pos) {
    if (sd_initialized) {
        f_lseek(&current_file, pos);
    } else {
        curpos = pos;
    }
}


typedef unsigned char byte;
#define boolean byte
#define true 1
#define false 0

void fBBave(){
    // placeholder for the actual save function that will be called from the Z80
    // this is where you would implement the logic to read the data from the Z80, save it to the SD card, and send a response back to the Z80
    printf("fBBave called - this is where you would implement the save logic\n");

  }

  void febren(){
    // placeholder for the actual load function that will be called from the Z80
    // this is where you would implement the logic to read the filename from the Z80, load the data from the SD card, and send it back to the Z80
    printf("febren called - this is where you would implement the load logic\n");
  }

void boot(){
    // placeholder for the actual boot function that will be called from the Z80
    // this is where you would implement the logic to read the filename from the Z80, load the data from the SD card, and send it back to the Z80 for execution
    printf("boot called - this is where you would implement the boot logic\n");
}

void println(const char* str) {
    printf("%s\n", str);
}

void print(const char* str) {
    printf("%s", str);
}

extern uint8_t recbyte();
extern void sndbyte(uint8_t response);

// Forward declaration for f_match
boolean f_match(char *f_name, char *c_name);

// SdFat SD;
unsigned long m_lop=128;
char m_name[40];
byte s_data[260];
char f_name[40];
char c_name[40];
char new_name[40];

//File names support long filename format.
boolean eflg = false;

void sdinit(void){
  // SD system initialization
  if( !SD_begin() )
  {
    println("Failed : SD.begin");
    eflg = true;
  }
  else {
    println("OK : SD.begin");
    eflg = false;
  }
println("START");


}

// Lowercase -> Uppercase

char upper(char c){
  if('a' <= c && c <= 'z'){
    c = c - ('a' - 'A');
  }
  return c;
}

// Add if the filename does not end in ".mzt"
void addmzt(char *f_name)
{
  unsigned int lp1 = 0;
  while (f_name[lp1] != 0x0D)
  {
    lp1++;
  }
  if (f_name[lp1 - 4] != '.' ||
      (f_name[lp1 - 3] != 'M' &&
       f_name[lp1 - 3] != 'm') ||
      (f_name[lp1 - 2] != 'Z' &&
       f_name[lp1 - 2] != 'z') ||
      (f_name[lp1 - 1] != 'T' &&
       f_name[lp1 - 1] != 't'))
  {
    f_name[lp1++] = '.';
    f_name[lp1++] = 'm';
    f_name[lp1++] = 'z';
    f_name[lp1++] = 't';
  }
  f_name[lp1] = 0x00;
}

// Save to SD card
void f_save()
{
  char p_name[20];
  UINT bw = 0;

  // Get the saved file name
  for (unsigned int lp1 = 0; lp1 <= 32; lp1++)
  {
    f_name[lp1] = recbyte();
  }
  addmzt(f_name);
  
  // Get the program name
  for (unsigned int lp1 = 0; lp1 <= 16; lp1++)
  {
    p_name[lp1] = recbyte();
  }
  p_name[15] = 0x0D;
  p_name[16] = 0x00;
  
  // Get start address
  int s_adrs1 = recbyte();
  int s_adrs2 = recbyte();
  unsigned int s_adrs = s_adrs1 + s_adrs2 * 256;
  
  // Get end address
  int e_adrs1 = recbyte();
  int e_adrs2 = recbyte();
  unsigned int e_adrs = e_adrs1 + e_adrs2 * 256;
  
  // Get execution address
  int g_adrs1 = recbyte();
  int g_adrs2 = recbyte();
  unsigned int g_adrs = g_adrs1 + g_adrs2 * 256;
  
  // File size calculation
  unsigned int f_length = e_adrs - s_adrs + 1;
  unsigned int f_length1 = f_length % 256;
  unsigned int f_length2 = f_length / 256;
  
  // Delete the file if it exists
  if (SD_exists(f_name))
  {
    SD_remove(f_name);
  }

  // Open file for writing
  if (SD_open(f_name, 1) >= 0)  // FILE_WRITE mode
  {
    // Sending status code (OK)
    sndbyte(0x00);
    
    uint8_t mode_byte = 0x01;
    f_write(&current_file, &mode_byte, 1, &bw);
    
    // Program name (17 bytes)
    f_write(&current_file, (uint8_t*)p_name, 17, &bw);
    
    // Null terminator
    uint8_t null_byte = 0x00;
    f_write(&current_file, &null_byte, 1, &bw);
    
    // File size (2 bytes)
    f_write(&current_file, (uint8_t*)&f_length1, 1, &bw);
    f_write(&current_file, (uint8_t*)&f_length2, 1, &bw);
    
    // Start address (2 bytes)
    f_write(&current_file, (uint8_t*)&s_adrs1, 1, &bw);
    f_write(&current_file, (uint8_t*)&s_adrs2, 1, &bw);
    
    // Execution address (2 bytes)
    f_write(&current_file, (uint8_t*)&g_adrs1, 1, &bw);
    f_write(&current_file, (uint8_t*)&g_adrs2, 1, &bw);
    
    // Fill up to 7F with 00 (103 more bytes to reach 128 total header)
    for (unsigned int lp1 = 0; lp1 <= 103; lp1++)
    {
      uint8_t zero = 0x00;
      f_write(&current_file, &zero, 1, &bw);
    }
    
    // Actual data transfer
    long lp1 = 0;
    while (lp1 <= f_length - 1)
    {
      int i = 0;
      while (i <= 255 && lp1 <= f_length - 1)
      {
        s_data[i] = recbyte();
        i++;
        lp1++;
      }
      f_write(&current_file, s_data, i, &bw);
    }
    
    f_close(&current_file);
  } 
  else 
  {
    // Send status code (ERROR)
    sndbyte(0xF1);
    sdinit();
  }
}

// Read from SD card
void f_load(void)
{
  // Get filename
  for (unsigned int lp1 = 0; lp1 <= 32; lp1++)
  {
    f_name[lp1] = recbyte();
  }
  addmzt(f_name);

  // Try to open file from SD card
  if (SD_open(f_name, 0) >= 0)  // FILE_READ mode
  {
    sndbyte(0x00);  // ok - got the file
    
    // Read file type
    uint8_t wk1 = SD_read(0);
    
    // Read and send program name (16 bytes)
    for (unsigned int lp1 = 0; lp1 <= 16; lp1++)
    {
      wk1 = SD_read(0);
      sndbyte(wk1);
    }
    
    // Get file size
    int f_length1 = SD_read(0);
    int f_length2 = SD_read(0);
    unsigned int f_length = f_length1 + f_length2 * 256;
    
    // Get start address
    int s_adrs1 = SD_read(0);
    int s_adrs2 = SD_read(0);
    unsigned int s_adrs = s_adrs1 + s_adrs2 * 256;
    
    // Get execution address
    int g_adrs1 = SD_read(0);
    int g_adrs2 = SD_read(0);
    unsigned int g_adrs = g_adrs1 + g_adrs2 * 256;
    
    // Send metadata back to Z80
    sndbyte(s_adrs1);
    sndbyte(s_adrs2);
    sndbyte(f_length1);
    sndbyte(f_length2);
    sndbyte(g_adrs1);
    sndbyte(g_adrs2);
    
    // Seek to data section (skip to byte 128)
    SD_seek(128);

    // Data transmission
    for (unsigned int lp1 = 0; lp1 < f_length; lp1++)
    {
      byte i_data = SD_read(0);
      sndbyte(i_data);
    }
    
    f_close(&current_file);
  }
  else
  {
    // Try fallback in-memory filesystem
    int file_handle = -1;
    for (int i = 0; i < 10; i++) {
      if (f_name[0] == filenames[i][0]) {
        file_handle = i;
        break;
      }
    }
    
    if (file_handle >= 0 && filesizes[file_handle] > 0)
    {
      sndbyte(0x00);  // ok - got the file
      int wk1 = 0;
      wk1 = SD_read(file_handle);  // filetype
      
      // Read and send program name (16 bytes)
      for (unsigned int lp1 = 0; lp1 <= 16; lp1++)
      {
        wk1 = SD_read(file_handle);
        sndbyte(wk1);
      }
      
      // Get file size
      int f_length2 = SD_read(file_handle);
      int f_length1 = SD_read(file_handle);
      unsigned int f_length = f_length1 * 256 + f_length2;
      
      // Get start address
      int s_adrs2 = SD_read(file_handle);
      int s_adrs1 = SD_read(file_handle);
      unsigned int s_adrs = s_adrs1 * 256 + s_adrs2;
      
      // Get execution address
      int g_adrs2 = SD_read(file_handle);
      int g_adrs1 = SD_read(file_handle);
      unsigned int g_adrs = g_adrs1 * 256 + g_adrs2;
      
      sndbyte(s_adrs2);
      sndbyte(s_adrs1);
      sndbyte(f_length2);
      sndbyte(f_length1);
      sndbyte(g_adrs2);
      sndbyte(g_adrs1);
      
      SD_seek(128);

      // Data transmission
      for (unsigned int lp1 = 0; lp1 < f_length; lp1++)
      {
        byte i_data = SD_read(file_handle);
        sndbyte(i_data);
      }
    }
    else
    {
      sndbyte(0xF1);  // File not found error
    }
  }
}

// ASTART Copies the specified file as filename "0000.mzt"
void astart(void)
{
  char w_name[] = "0000.mzt";

  // Get filename
  for (unsigned int lp1 = 0; lp1 <= 32; lp1++)
  {
    f_name[lp1] = recbyte();
  }
  addmzt(f_name);
  
  // Error if the file does not exist
  if (SD_exists(f_name))
  {
    // If 0000.mzt exists, delete it
    if (SD_exists(w_name))
    {
      SD_remove(w_name);
    }
    
    // Open source file for reading
    if (SD_open(f_name, 0) >= 0)
    {
      // Get file size
      FSIZE_t f_length = f_size(&current_file);
      
      // Close read file
      f_close(&current_file);
      
      // Open destination file for writing
      if (SD_open(w_name, 1) >= 0)
      {
        // Reopen source file for reading
        SD_open(f_name, 0);
        
        // Copy data
        long lp1 = 0;
        while (lp1 < f_length)
        {
          int i = 0;
          while (i < 256 && lp1 < f_length)
          {
            s_data[i] = SD_read(0);
            i++;
            lp1++;
          }
          f_write(&current_file, s_data, i, NULL);
        }
        
        f_close(&current_file);
        f_close(&current_file);  // Close both files
        
        // Sending status code (OK)
        sndbyte(0x00);
      }
      else
      {
        // Send status code (ERROR)
        sndbyte(0xF1);
        sdinit();
      }
    }
    else
    {
      // Send status code (ERROR)
      sndbyte(0xF1);
      sdinit();
    }
  }
  else
  {
    // Send status code (ERROR)
    sndbyte(0xF1);
    sdinit();
  }
}

// SD system filelist
void dirlist(void)
{
  // Get comparison string (up to 32+1 characters)
  for (unsigned int lp1 = 0; lp1 <= 32; lp1++)
  {
    c_name[lp1] = recbyte();
  }

  // Open root directory
  DIR dir;
  FILINFO fno;
  FRESULT result = f_opendir(&dir, "/");
  
  if (result != FR_OK)
  {
    sndbyte(0xF1);  // Error
    return;
  }

  int cntl2 = 0;
  unsigned int br_chk = 0;
  int page = 1;
  
  // Send files, pausing after 20 items
  while (1)
  {
    result = f_readdir(&dir, &fno);
    if (result != FR_OK || fno.fname[0] == '\0')
    {
      // End of directory
      if (cntl2 > 0 || page == 1)
      {
        // Send termination
        sndbyte(0xFF);
        sndbyte(0x00);
      }
      break;
    }

    // Filter by match if needed
    if (f_match(fno.fname, c_name))
    {
      // Send filename
      unsigned int lp1 = 0;
      while (lp1 < 36 && fno.fname[lp1] != 0x00)
      {
        sndbyte(upper(fno.fname[lp1]));
        lp1++;
      }
      sndbyte(0x0D);
      sndbyte(0x00);
      cntl2++;
    }

    // Pause after 20 items or end of directory
    if (cntl2 >= 20)
    {
      sndbyte(0xFE);  // Request for instructions
      
      br_chk = recbyte();  // Selection: 0=Continue, 'B'=Previous, Other=Terminate
      
      if (br_chk != 0 && br_chk != 0x42)
      {
        // Terminate
        break;
      }
      
      if (br_chk == 0x42)
      {
        // Go back to first file - reopen directory
        f_closedir(&dir);
        result = f_opendir(&dir, "/");
        if (result != FR_OK)
        {
          sndbyte(0xF1);
          break;
        }
        page = 1;
        cntl2 = 0;
        
        if (page > 1)
        {
          // Skip to previous page (TODO: implement proper pagination)
          cntl2 = 0;
        }
      }
      else
      {
        // Continue
        page++;
        cntl2 = 0;
      }
    }
  }

  f_closedir(&dir);
}

//   // Compare f_name and c_name until c_name contains 0x00
//   // FILENAME COMPARE
boolean f_match(char *f_name, char *c_name)
{
  boolean flg1 = true;
  unsigned int lp1 = 0;
  
  // If c_name is empty (just null terminator), match all files
  if (c_name[0] == 0x00)
  {
    return true;
  }
  
  // Compare filenames
  while (lp1 <= 32 && c_name[lp1] != 0x00 && flg1 == true)
  {
    if (upper(f_name[lp1]) != upper(c_name[lp1]))
    {
      flg1 = false;
    }
    lp1++;
  }
  
  return flg1;
}

  // FILE DELETE
  void f_del(void)
  {
    // Get filename
    for (unsigned int lp1 = 0; lp1 <= 32; lp1++)
    {
      f_name[lp1] = recbyte();
    }
    addmzt(f_name);

    // Error if the file does not exist
    if (SD_exists(f_name))
    {
      // Sending status code (OK)
      sndbyte(0x00);

      // Receive processing selection (0: Continue DELETE, Non-zero: CANCEL)
      if (recbyte() == 0x00)
      {
        if (SD_remove(f_name))
        {
          // Sending status code (OK)
          sndbyte(0x00);
        }
        else
        {
          // Send status code (Error)
          sndbyte(0xF1);
          sdinit();
        }
      }
      else
      {
        // Send status code (Cancel)
        sndbyte(0x01);
      }
    }
    else
    {
      // Send status code (Error)
      sndbyte(0xF1);
      sdinit();
    }
  }

// FILERENAME
void f_ren(void)
{
  // Get the current file name
  for (unsigned int lp1 = 0; lp1 <= 32; lp1++)
  {
    f_name[lp1] = recbyte();
  }
  addmzt(f_name);

  // Error if the file does not exist
  if (SD_exists(f_name))
  {
    // Sending status code (OK)
    sndbyte(0x00);

    // Get new filename
    for (unsigned int lp1 = 0; lp1 <= 32; lp1++)
    {
      new_name[lp1] = recbyte();
    }
    addmzt(new_name);
    
    // Sending status code (OK)
    sndbyte(0x00);

    // Rename file
    if (f_rename(f_name, new_name) == FR_OK)
    {
      // Sending status code (OK)
      sndbyte(0x00);
    }
    else
    {
      // Sending status code (Error)
      sndbyte(0xFF);
    }
  }
  else
  {
    // Send status code (Error)
    sndbyte(0xF1);
    sdinit();
  }
}

        // FILE DUMP
void f_dump(void)
{
  // Get filename
  for (unsigned int lp1 = 0; lp1 <= 32; lp1++)
  {
    f_name[lp1] = recbyte();
  }
  addmzt(f_name);

  // Error if the file does not exist
  if (SD_exists(f_name))
  {
    // Sending status code (OK)
    sndbyte(0x00);

    // Open file for reading
    if (SD_open(f_name, 0) >= 0)
    {
      FSIZE_t f_length = f_size(&current_file);
      long lp1 = 0;
      unsigned int br_chk = 0;
      
      while (lp1 < f_length)
      {
        // Send address at top of screen
        sndbyte(lp1 % 256);
        sndbyte(lp1 / 256);
        
        int i = 0;
        // Send actual data (128 bytes per screen)
        while (i < 128 && lp1 < f_length)
        {
          sndbyte(SD_read(0));
          i++;
          lp1++;
        }
        
        // If less than 128 bytes, send 0x00 for remaining bytes
        while (i < 128)
        {
          sndbyte(0x00);
          i++;
        }
        
        // Wait for instructions
        br_chk = recbyte();
        
        // If BREAK (0xFF), set pointer to FILE END
        if (br_chk == 0xFF)
        {
          lp1 = f_length;
        }
        
        // If BACK (0x42), move pointer back 256 bytes
        if (br_chk == 0x42)
        {
          if (lp1 > 256)
          {
            lp1 = lp1 - 256;
          }
          else
          {
            lp1 = 0;
          }
          f_lseek(&current_file, lp1);
        }
      }
      
      // Send exit code 0xFFFF to ADRS
      if (lp1 >= f_length)
      {
        sndbyte(0xFF);
        sndbyte(0xFF);
      }
      
      f_close(&current_file);
      
      // Sending status code (OK)
      sndbyte(0x00);
    }
    else
    {
      // Send status code (ERROR)
      sndbyte(0xF1);
      sdinit();
    }
  }
  else
  {
    // Send status code (Error)
    sndbyte(0xF1);
    sdinit();
  }
}

// FILE COPY
void f_copy(void)
{
  // Get the current file name
  for (unsigned int lp1 = 0; lp1 <= 32; lp1++)
  {
    f_name[lp1] = recbyte();
  }
  addmzt(f_name);
  
  // Error if the file does not exist
  if (SD_exists(f_name))
  {
    // Sending status code (OK)
    sndbyte(0x00);

    // Get new filename
    for (unsigned int lp1 = 0; lp1 <= 32; lp1++)
    {
      new_name[lp1] = recbyte();
    }
    addmzt(new_name);
    
    // An error will occur if a file with the same name as the new file name already exists
    if (!SD_exists(new_name))
    {
      // Sending status code (OK)
      sndbyte(0x00);
      
      // Open source file for reading
      if (SD_open(f_name, 0) >= 0)
      {
        FSIZE_t f_length = f_size(&current_file);
        
        // Close source file
        f_close(&current_file);
        
        // Open destination file for writing
        if (SD_open(new_name, 1) >= 0)
        {
          // Reopen source file for reading
          SD_open(f_name, 0);
          
          // Copy actual data
          long lp1 = 0;
          while (lp1 < f_length)
          {
            int i = 0;
            while (i < 256 && lp1 < f_length)
            {
              s_data[i] = SD_read(0);
              i++;
              lp1++;
            }
            f_write(&current_file, s_data, i, NULL);
          }
          
          f_close(&current_file);
          f_close(&current_file);  // Close both files
          
          // Sending status code (OK)
          sndbyte(0x00);
        }
        else
        {
          // Send status code (Error)
          sndbyte(0xF1);
          sdinit();
        }
      }
      else
      {
        // Send status code (Error)
        sndbyte(0xF3);
        sdinit();
      }
    }
    else
    {
      // Send status code (Error - file already exists)
      sndbyte(0xF1);
      sdinit();
    }
  }
  else
  {
    // Send status code (Error - source not found)
    sndbyte(0xF1);
    sdinit();
  }
}

// //91h for 0436H MONITOR Light Information Alternative Processing
void mon_whead(void){
  char m_info[130];
  UINT bw = 0;
  
  // Information block received
  for (unsigned int lp1 = 0; lp1 < 128; lp1++){
    m_info[lp1] = recbyte();
  }
  
  // Extracting filename
  for (unsigned int lp1 = 0; lp1 < 17; lp1++){
    m_name[lp1] = m_info[lp1 + 1];
  }
  
  // Add .MZT for DOS filenames
  addmzt(m_name);
  m_info[16] = 0x0D;
  
  // Delete the file if it exists
  if (SD_exists(m_name)){
    SD_remove(m_name);
  }
  
  // Open file for writing
  if (SD_open(m_name, 1) >= 0) {
    // Sending status code (OK)
    sndbyte(0x00);
    
    // Information block write
    for (unsigned int lp1 = 0; lp1 < 128; lp1++){
      uint8_t byte_val = (uint8_t)m_info[lp1];
      f_write(&current_file, &byte_val, 1, &bw);
    }
    
    f_close(&current_file);
  } else {
    // Send status code (ERROR)
    sndbyte(0xF1);
    sdinit();
  }
}

// //92h 0475H MONITOR Write Data Replacement Processing
void mon_wdata(void){
  UINT bw = 0;
  
  // Get file size
  int f_length1 = recbyte();
  int f_length2 = recbyte();
  
  // File size calculation
  unsigned int f_length = f_length1 + f_length2 * 256;
  
  // Open file for writing (append to existing file from mon_whead)
  if (SD_open(m_name, 1) >= 0) {
    // Sending status code (OK)
    sndbyte(0x00);
    
    // Actual data
    long lp1 = 0;
    while (lp1 < f_length){
      int i = 0;
      while (i < 256 && lp1 < f_length){
        s_data[i] = recbyte();
        i++;
        lp1++;
      }
      f_write(&current_file, s_data, i, &bw);
    }
    
    f_close(&current_file);
  } else {
    // Send status code (ERROR)
    sndbyte(0xF1);
  }
}

// //04D8H MONITOR Read Information Alternative Processing
void mon_lhead(void){
  // Clear Read Data Points
  m_lop = 128;
  
  // Get filename
  for (unsigned int lp1 = 0; lp1 <= 32; lp1++){
    m_name[lp1] = recbyte();
  }
  addmzt(m_name);

  // Error if the file does not exist
  if (SD_exists(m_name)){
    sndbyte(0x00);  // Send OK
    
    // Open file for reading
    if (SD_open(m_name, 0) >= 0) {
      sndbyte(0x00);  // Another OK
      
      // Read and send 128 bytes of header
      for (unsigned int lp1 = 0; lp1 < 128; lp1++){
        uint8_t i_data = SD_read(0);
        sndbyte(i_data);
      }
      
      sndbyte(0x00);  // Final OK
      // Don't close file yet - mon_ldata will continue reading from it
    }
    else {
      // Send status code (ERROR)
      sndbyte(0xFF);
      sdinit();
    }
  }
  else {
    // Send status code (FILE NOT FOUND ERROR)
    sndbyte(0xF1);
    sdinit();
  }
}

// //04F8H MONITOR Read Data Replacement Processing
void mon_ldata(void){
  // Error if the file does not exist (check if file is still open)
  sndbyte(0x00);  // Send OK
  
  // Open file again if needed (should already be open from mon_lhead)
  if (sd_initialized) {
    sndbyte(0x00);  // Another OK
    
    // Seek to current position
    f_lseek(&current_file, m_lop);
    
    // Get read size
    int f_length2 = recbyte();
    int f_length1 = recbyte();
    unsigned int f_length = f_length1 * 256 + f_length2;
    
    // Send data
    for (unsigned int lp1 = 0; lp1 < f_length; lp1++){
      uint8_t i_data = SD_read(0);
      sndbyte(i_data);
    }
    
    // Update read position
    m_lop = m_lop + f_length;
    sndbyte(0x00);  // Final OK
  }
  else {
    // Send status code (ERROR)
    sndbyte(0xFF);
  }
}

// //BOOT process (for MZ-2000_SD only)
// void boot(void){
// //Get filename
//   for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
//     m_name[lp1] = recbyte();
//   }
// //// print("m_name:");
// //// println(m_name);
// //Error if the file does not exist
//   if (SD.exists(m_name) == true){
//     sndbyte(0x00);
// //Open F
//     File file = SD.open( m_name, FILE_READ );
//     if ( true == file ) {
//     sndbyte(0x00);
// // Sending file size
//       unsigned long f_length = file.size();
//       unsigned int f_len1 = f_length / 256;
//       unsigned int f_len2 = f_length % 256;
//       sndbyte(f_len2);
//       sndbyte(f_len1);
// //// println(f_length,HEX);
// //// println(f_len2,HEX);
// //// println(f_len1,HEX);

// // Sending actual data
//       for (unsigned long lp1 = 1;lp1 <= f_length;lp1++){
//          byte i_data = file.read();
//          sndbyte(i_data);
//       }

//     else {
// //Send status code (ERROR)
//       sndbyte(0xFF);
//     }  
//   else {
// //Send status code (FILE NOT FIND ERROR)
//     sndbyte(0xF1);
//   }
// }

void SD_init()
{
  // test that the SD Card is available and working
  // check for a file called '0000.mzt' and if it exists, 
  // list all the file on the SD card
  sdinit();

  if (SD_exists("0000.mzt"))
  {
    println("0000.mzt found - listing files:");
    dirlist();
  }
  else
  {   
     println("0000.mzt not found - SD card may be empty or not working");
  }

}

void SD_loop()
{

  // Waiting for command acquisition
  //// print("cmd:");
  byte cmd = recbyte();
  //// println(cmd,HEX);
  if (eflg == false)
  {
    switch (cmd)
    {
      // Save to SD card after 80 hours
    case 0x80:
      println("SAVE START");
      // Sending status code (OK)
      sndbyte(0x00);
      fBBave();
      break;
      // Load from SD card in 81 hours
    case 0x81:
      println("LOAD START");
      // Sending status code (OK)
      sndbyte(0x00);
      f_load();
      break;
      // Rename and copy the specified file as 0000.mzt in 82 hours.
    case 0x82:
      println("ASTART START");
      // Sending status code (OK)
      sndbyte(0x00);
      astart();
      break;
      // Output file list in 83 hours
    case 0x83:
      println("FILE LIST START");
      // Sending status code (OK)
      sndbyte(0x00);
      sdinit();
      dirlist();
      break;
      // Delete file after 84 hours
    case 0x84:
      println("FILE Delete START");
      // Sending status code (OK)
      sndbyte(0x00);
      f_del();
      break;
      // Rename files after 85 hours
    case 0x85:
      println("FILE Rename START");
      // Sending status code (OK)
      sndbyte(0x00);
      febren();
      break;
    case 0x86:
      // File dump at 86h
      println("FILE Dump START");
      // Sending status code (OK)
      sndbyte(0x00);
      f_dump();
      break;
    case 0x87:
      // File copy in 87 hours
      println("FILE Copy START");
      // Sending status code (OK)
      sndbyte(0x00);
      f_copy();
      break;
    case 0x91:
      // 91h for 0436H MONITOR Light Information Alternative Processing
      println("0436H START");
      // Sending status code (OK)
      sndbyte(0x00);
      mon_whead();
      break;
      // 92h 0475H MONITOR Write Data Replacement Processing
    case 0x92:
      println("0475H START");
      // Sending status code (OK)
      sndbyte(0x00);
      mon_wdata();
      break;
      // 93h 04D8H MONITOR Read Information Alternative Processing
    case 0x93:
      println("04D8H START");
      // Sending status code (OK)
      sndbyte(0x00);
      mon_lhead();
      break;
      // 94h 04F8H MONITOR read data substitution process
    case 0x94:
      println("04F8H START");
      // Sending status code (OK)
      sndbyte(0x00);
      mon_ldata();
      break;
      // Boot load in 95 hours (for MZ-2000_SD only)
    case 0x95:
      println("BOOT LOAD START");
      // Sending status code (OK)
      sndbyte(0x00);
      boot();
      break;
    default:
      // Send status code (CMD ERROR)
      sndbyte(0xF4);
    }
  }
  else
  {
    // Send status code (ERROR)
    sndbyte(0xF0);
    sdinit();
  }
}