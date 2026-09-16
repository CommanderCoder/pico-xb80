#include <stdio.h>
#include <stdint.h>

#include "pico/stdlib.h"

#include "ff.h"
#include "fatfs_interface.h"

#include "xb_interface/xb_if.h"

#include "sharp-mz80k/FD_rom.h"
#include "sharp-mz80k/sharp_mz.h"

// File operation mode constants
constexpr uint FILE_READ = 0;
constexpr uint FILE_WRITE = 1;
constexpr char ROOT_DIR[12] = "/MZ_FD"; // Root directory for MZF files

// Forward declarations of FATFS object
static class FatFsInterface* g_fatfs = nullptr;
#define USING_FATFS (NULL != g_fatfs)

// SDfile: wrapper around FatFs FIL and fallback in-memory files
class SDfile {
public:
  FIL fil;

  // open file. Returns 0 on success, -1 on error. Mirrors previous SdFat_open behaviour.
  int open(const char* filename, int mode) {
    BYTE fatfs_mode = 0;
    if (mode == FILE_READ) fatfs_mode = FA_READ;
    else fatfs_mode = FA_CREATE_ALWAYS | FA_WRITE;

    FRESULT result = g_fatfs->open(&fil, filename, fatfs_mode);
    if (result == FR_OK) {
      return 0;
    }
    return -1;
  }

  void close() {
    f_close(&fil);
  }

  // write buffer to file
  FRESULT write(const void* buf, UINT btw, UINT* bw) {
    return f_write(&fil, (uint8_t*)buf, btw, bw);
  }

  // read one byte (returns 0 on EOF or error)
  uint8_t readByte() {
    uint8_t byte = 0;
    UINT br = 0;
    FRESULT res = f_read(&fil, &byte, 1, &br);
    if (res == FR_OK && br == 1) return byte;
    return 0;
  }

  // seek to position
  FRESULT seek(FSIZE_t p) {
    return f_lseek(&fil, p);
  }

  // get file size
  FSIZE_t size() {
    return f_size(&fil);
  };
};

static SDfile current_file;
static SDfile current_file_for_copy;

// current file diagnostics

void print_current_file_diag(){
#if USBDEBUG

  printf("=== SDfile Diagnostics ===\n");
  // Assuming current_file is your FIL container object
  FIL* filval = &(current_file.fil);

  printf("=== FatFs FIL Structure Diagnostics ===\n");
  printf("Flag (Status):       0x%02X\n", filval->flag);
  printf("File Size:           %lu bytes\n", (unsigned long)filval->obj.objsize);
  printf("Read/Write Pointer:  %lu (offset from start)\n", (unsigned long)filval->fptr);
  printf("Start Cluster:       %lu\n", (unsigned long)filval->obj.sclust);
  printf("Current Cluster:     %lu\n", (unsigned long)filval->clust);
#if !FF_FS_READONLY
  printf("Current Sector:      %lu\n", (unsigned long)filval->sect);
#endif

  // Optional: Breakdown the flag byte for quick reading
  printf("Flag Breakdown:\n");
  printf("  - FA_READ:         %s\n", (filval->flag & 0x01) ? "YES" : "NO");
  printf("  - FA_WRITE:        %s\n", (filval->flag & 0x02) ? "YES" : "NO");
  printf("  - FA_OPENED:       %s\n", (filval->flag & 0x01) ? "YES" : "NO"); // Usually matches read/write state
  printf("  - FA_MODIFIED:     %s\n", (filval->flag & 0x40) ? "YES" : "NO");
  printf("=======================================\n");
#endif 
}

// SDCard slot pin assignments
namespace {
  constexpr uint kClkPin = 10;
  constexpr uint kCmdPin = 11;
  constexpr uint kDat0Pin = 12; // pin 12 on Revision A boards, pin 24 on Revision B boards
}  // namespace

typedef unsigned char byte;
#define boolean byte
#define true 1
#define false 0

// SdFat SD;
unsigned long m_lop=128;
byte s_data[260];
char m_name[40];
char m_name_copy[130]; // includes path

//File names support long filename format.
boolean support_lfn = false;

void println(const char* str) {
    _DEBUG("%s\n", str);
}

void print(const char* str) {
    _DEBUG("%s", str);
}


// Forward declarations
boolean f_match(char *f_name, char *c_name);
bool InitSDFatFs();

// TEMPORARY DIAGNOSTIC: list every .MZF file on the SD card directly on the
// Pico side (no Z80/PIO involvement at all), to check the SD/FatFs listing
// logic in isolation from the Z80 transport. Remove once confirmed working.
static void list_mzf_files_local(void)
{
  DIR dir;
  FILINFO fno;
  FRESULT result = f_opendir(&dir, ROOT_DIR);
  if (result != FR_OK) {
    println("list_mzf_files_local: f_opendir failed");
    return;
  }

  println("--- .MZF files on SD (Pico-local listing) ---");
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
    if (!((ext[0] == 'm' || ext[0] == 'M') &&
          (ext[1] == 'z' || ext[1] == 'Z') &&
          (ext[2] == 'f' || ext[2] == 'F'))) {
      continue;
    }

    _DEBUG("  %s  (%lu bytes)\n", fno.fname, (unsigned long)fno.fsize);
    count++;
  }
  f_closedir(&dir);
  _DEBUG("--- %d .MZF file(s) ---\n", count);
}

void sdinit(void){
  // SD system initialization
  if( !InitSDFatFs() )
  {
    println("Failed : SD.begin");
    support_lfn = true;
  }
  else {
    println("OK : SD.begin");
    support_lfn = false;
  }
println("START");

  if (!support_lfn) {
    list_mzf_files_local(); // TEMPORARY DIAGNOSTIC
  }
}

// Lowercase -> Uppercase
char upper(char c){
  if('a' <= c && c <= 'z'){
    c = c - ('a' - 'A');
  }
  return c;
}

// Add if the filename does not end in ".mzf"
void addmzf(char *f_name)
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
      (f_name[lp1 - 1] != 'F' &&
       f_name[lp1 - 1] != 'f'))
  {
    f_name[lp1++] = '.';
    f_name[lp1++] = 'm';
    f_name[lp1++] = 'z';
    f_name[lp1++] = 'f';
  }
  f_name[lp1] = 0x00;
}


void addrootdir(char* f_name_copy, const char* f_name, size_t max_len)
{
  strncpy(f_name_copy, ROOT_DIR, max_len - 1);
  strncat(f_name_copy, "/", max_len - strlen(f_name_copy) - 1);
  strncat(f_name_copy, f_name, max_len - strlen(f_name_copy) - 1);
}


void rcv_block(char* buff, int size)
{
  for (unsigned int lp1 = 0; lp1 < size; lp1++){
    buff[lp1] = recbyte();
  }
}

void rcv_filename32(char *f_name)
{
  rcv_block(f_name, 33); // 32 plus terminator
}

// Save to SD card
void f_save()
{
  char p_name[20];
  UINT bw = 0;
  char f_name[40];

  rcv_filename32(f_name); 
  addrootdir(m_name_copy, f_name, sizeof(m_name_copy));
  addmzf(m_name_copy);
  
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

  _DEBUG("save file start %d\n",s_adrs);
  _DEBUG("save file end %d\n",e_adrs);
  _DEBUG("save file exe %d\n",g_adrs);
  _DEBUG("save file length %d\n",f_length);
  // Delete the file if it exists
  FILINFO fno;
  if (g_fatfs->exists(m_name_copy,&fno) == FR_OK)
  {
    g_fatfs->remove(m_name_copy);
  }

  // Open file for writing (this sets the 'current_file')
  if (current_file.open(m_name_copy, FILE_WRITE) >= 0)  // FILE_WRITE mode
  {
    // Sending status code (OK)
    sndbyte(0x00);
    
    uint8_t mode_byte = 0x01;
    current_file.write(&mode_byte, 1, &bw);
    
    // Program name (17 bytes)
    current_file.write((uint8_t*)p_name, 17, &bw);
    
    // Null terminator
    uint8_t null_byte = 0x00;
    current_file.write(&null_byte, 1, &bw);

    // File size (2 bytes)
    current_file.write((uint8_t*)&f_length1, 1, &bw);
    current_file.write((uint8_t*)&f_length2, 1, &bw);
    
    // Start address (2 bytes)
    current_file.write((uint8_t*)&s_adrs1, 1, &bw);
    current_file.write((uint8_t*)&s_adrs2, 1, &bw);
    
    // Execution address (2 bytes)
    current_file.write((uint8_t*)&g_adrs1, 1, &bw);
    current_file.write((uint8_t*)&g_adrs2, 1, &bw);
    
    // Fill up to 7F with 00 (103 more bytes to reach 128 total header)
    {
      uint8_t zero[128];
      memset(zero, null_byte, 128);
      current_file.write(zero, 103, &bw);
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
      current_file.write(s_data, i, &bw);
    }
    
    current_file.close();
  } 
  else 
  {
    // Send status code (ERROR)
    sndbyte(0xF1);
    sdinit();
  }
}

void f_send(const char* f_name)
{
  char f_name_copy[300]; // buffer for the filename
  addrootdir(f_name_copy,f_name, sizeof(f_name_copy)); // prepend root directory to filename
  // Try to open file from SD card
  if (current_file.open(f_name_copy, FILE_READ) >= 0)  // FILE_READ mode
  {
    sndbyte(0x00);  // ok - got the file
    
    // Read file type
    uint8_t wk1 = current_file.readByte();
    
    // Read and send program name (16 bytes)
    for (unsigned int lp1 = 0; lp1 <= 16; lp1++)
    {
      wk1 = current_file.readByte();

      uint8_t char_repr = (wk1 >= 32 && wk1 <= 126) ? wk1 : '.'; // printable ASCII or dot

       _DEBUG("%c ",char_repr);
      sndbyte(wk1);
    }
    
    // Get file size
    int f_length1 = current_file.readByte();
    int f_length2 = current_file.readByte();
    unsigned int f_length = f_length1 + f_length2 * 256;
    _DEBUG("load file length %u\n",f_length);
    
    // Get start address
    int s_adrs1 = current_file.readByte();
    int s_adrs2 = current_file.readByte();
    unsigned int s_adrs = s_adrs1 + s_adrs2 * 256;
    _DEBUG("load file start %u\n",s_adrs);
    
    // Get execution address
    int g_adrs1 = current_file.readByte();
    int g_adrs2 = current_file.readByte();
    unsigned int g_adrs = g_adrs1 + g_adrs2 * 256;
    _DEBUG("load file exe %u\n",g_adrs);
  

    // Send metadata back to Z80
    sndbyte(s_adrs1);
    sndbyte(s_adrs2);
    sndbyte(f_length1);
    sndbyte(f_length2);
    sndbyte(g_adrs1);
    sndbyte(g_adrs2);
    
    // Seek to data section (skip to byte 128)
    current_file.seek(128);

    // Data transmission
    for (unsigned int lp1 = 0; lp1 < f_length; lp1++)
    {
      byte i_data = current_file.readByte();
      // uint8_t char_repr = (i_data >= 32 && i_data <= 126) ? i_data : '.'; // printable ASCII or dot

      // _DEBUG("%02x %c\n", i_data, char_repr);
      sndbyte(i_data);
      // sleep_ms(100);
    }
    
    current_file.close();
  }
  else
  {
    sndbyte(0xF1);  // File not found error
  }
}



// Read from SD card
void f_load(void)
{
  char f_name[40];
  rcv_filename32(f_name);
  addmzf(f_name);
  _DEBUG("%s\n",f_name);

  f_send(f_name);
}

// ASTART Copies the specified file as filename "0000.mzf"
void astart(void)
{
  char w_name[50];
  addrootdir(w_name, "0000.mzf", sizeof(w_name)); // prepend root directory to filename

  // Get filename
  char f_name[40];
  rcv_filename32(f_name);
  addrootdir(m_name_copy, f_name, sizeof(m_name_copy)); // prepend root directory to filename
  addmzf(m_name_copy);
  
  // Error if the file does not exist
  FILINFO fno;
  if (g_fatfs->exists(m_name_copy,&fno) == FR_OK)
  {
    // If 0000.mzf exists, delete it
    FILINFO fno;
    if (g_fatfs->exists(w_name,&fno) == FR_OK)
    {
      g_fatfs->remove(w_name);
    }
    
    // Open source file for reading
    if (current_file.open(m_name_copy, FILE_READ) >= 0)
    {
      // Get file size
      FSIZE_t f_length = current_file.size();
      
      // Close read file
      current_file.close();
      
      // Open destination file for writing
      if (current_file_for_copy.open(w_name, FILE_WRITE) >= 0)
      {
        // Reopen source file for reading
        current_file.open(m_name_copy, FILE_READ);
        
        // Copy data
        long lp1 = 0;
        while (lp1 < f_length)
        {
          int i = 0;
          while (i < 256 && lp1 < f_length)
          {
            s_data[i] = current_file.readByte();
            i++;
            lp1++;
          }
          current_file_for_copy.write(s_data, i, NULL);
        }
        
        current_file.close();
        current_file_for_copy.close();  // Close both files
        
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

// build a local cache of the files in the root directory which end in .MZF or .mzf
struct FileEntry {
  FILINFO fno; // FATFS file info structure
  char displayname[32]; // 32 characters for the filename
};

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

void sendFileName(const uint8_t index)
{
  if (index >= FileCount || index >= 255) {
    sndbyte(0xF1); // error: index out of bounds
    return;
  }
  sndbyte(0x00); // ok - got the file name

  // send up to 32 characters of the display name, including null terminator if present
  // terminate at 0
  const char* name = FileList[index].displayname;
  for (int i = 0; i < 32; i++) {
    char c = name[i];
    sndbyte(c);
    if (c == '\0') break; // stop sending if we hit the null terminator
  }
}



// Read from SD card
void sendFileData(const uint8_t index)
{
  if (index >= FileCount || index >= 255) {
    sndbyte(0xF1); // error: index out of bounds
    return;
  }

  char f_name[300]; // buffer for the filename  
  strncpy(f_name, FileList[index].fno.fname, sizeof(f_name) - 1);
  f_name[sizeof(f_name) - 1] = '\0'; // ensure null termination

  _DEBUG("sendFileData: %s\n", f_name);

  f_send(f_name);
}


// SD system filelist
void dirlist(void)
{
  // Get comparison string (up to 32+1 characters)
  char c_name[40];
  rcv_filename32(c_name);

  // Open root directory
  DIR dir;
  FILINFO fno;
  FRESULT result = f_opendir(&dir, ROOT_DIR);
  
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

    // Ignore dotfiles and only show files with a .mzf extension (case-insensitive)
    {
      int len = strlen(fno.fname);
      printf("dirlist: checking file %s\n", fno.fname);
      if (len == 0 || fno.fname[0] == '.')
      {
        continue;
      }
      if (len < 4)
      {
        continue;
      }
      const char *ext = &fno.fname[len - 3];
      if (!((ext[0] == 'm' || ext[0] == 'M') &&
            (ext[1] == 'z' || ext[1] == 'Z') &&
            (ext[2] == 'f' || ext[2] == 'F')))
      {
        continue;
      }
    }

    // Filter by match if needed
    if (f_match(fno.fname, c_name))
    {
      _DEBUG("direntry %s %u\n", fno.fname, fno.fsize);

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
        result = f_opendir(&dir, ROOT_DIR);
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
  char f_name[40];
  rcv_filename32(f_name);
  addmzf(f_name);

    // Error if the file does not exist
    FILINFO fno;
    if (g_fatfs->exists(f_name,&fno) == FR_OK)
    {
      // Sending status code (OK)
      sndbyte(0x00);

      // Receive processing selection (0: Continue DELETE, Non-zero: CANCEL)
      if (recbyte() == 0x00)
      {
        if (g_fatfs->remove(f_name) == FR_OK)
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
  char f_name[40];
  rcv_filename32(f_name);
  addmzf(f_name);

  // Error if the file does not exist
    FILINFO fno;
  if (g_fatfs->exists(f_name,&fno) == FR_OK)
  {
    // Sending status code (OK)
    sndbyte(0x00);

    // Get new filename
    char new_name[40];
    rcv_filename32(new_name);
    addmzf(new_name);
      
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
  char f_name[40];
  rcv_filename32(f_name);
  addmzf(f_name);

  _DEBUG("fname %s\n", f_name);

  // Error if the file does not exist
  FILINFO fno;
  if (g_fatfs->exists(f_name,&fno) == FR_OK)
  {
    // Sending status code (OK)
    sndbyte(0x00);

    // Open file for reading
    if (current_file.open(f_name, FILE_READ) >= 0)
    {
      print_current_file_diag();
      FSIZE_t f_length = current_file.size();
      // FSIZE is 64bits!
      _DEBUG("length %016llX (%lu)\n", f_length, f_length);

      uint16_t f_length16 = (f_length&0xffff);
      _DEBUG("length %04X (%u)\n", f_length16, f_length16);

      long lp1 = 0;
      unsigned int br_chk = 0;

      while (lp1 < f_length)
      {
        // Send address at top of screen
        sndbyte(lp1 % 256);
        sndbyte(lp1 / 256);
        
        int i = 0;
        // Send actual data (128 bytes per scrdeen)
        while (i < 128 && lp1 < f_length)
        {
          sndbyte(current_file.readByte());
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
          current_file.seek(lp1);
        }
      }
      
      // Send exit code 0xFFFF to ADRS
      if (lp1 >= f_length)
      {
        sndbyte(0xFF);
        sndbyte(0xFF);
      }
      
      current_file.close();
      
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
  char f_name[40];
  rcv_filename32(f_name);
  addmzf(f_name);

  _DEBUG("copy %s\n", f_name);
  
  // Error if the file does not exist
  FILINFO fno;
  if (g_fatfs->exists(f_name,&fno) == FR_OK)
  {
    // Sending status code (OK)
    sndbyte(0x00);

    // Get new filename
    char new_name[40];
    rcv_filename32(new_name);
    addmzf(new_name);

    _DEBUG("%s -> %s\n", f_name, new_name);
    
    // An error will occur if a file with the same name as the new file name already exists
    FILINFO fno;
    if (g_fatfs->exists(new_name,&fno) != FR_OK)
    {
      // Sending status code (OK)
      sndbyte(0x00);
      
      // Open source file for reading
      if (current_file.open(f_name, FILE_READ) >= 0)
      {
        FSIZE_t f_length = current_file.size();
        
        // Close source file
        current_file.close();
        
        // Open destination file for writing
        if (current_file_for_copy.open(new_name, FILE_WRITE) >= 0)
        {
          // Reopen source file for reading
          current_file.open(f_name, FILE_READ);
          
          // Copy actual data
          long lp1 = 0;
          while (lp1 < f_length)
          {
            int i = 0;
            while (i < 256 && lp1 < f_length)
            {
              s_data[i] = current_file.readByte();
              i++;
              lp1++;
            }
            current_file_for_copy.write(s_data, i, NULL);
          }
          
          current_file_for_copy.close();
          current_file.close();  // Close both files
          
          // Sending status code (OK)
          sndbyte(0x00);
        }
        else
        {
          _DEBUG("%s not writable\n", new_name);

          // Send status code (Error)
          sndbyte(0xF1);
          sdinit();
        }
      }
      else
      {
        _DEBUG("%s not found\n", f_name);

        // Send status code (Error)
        sndbyte(0xF3);
        sdinit();
      }
    }
    else
    {
      _DEBUG("%s already exists\n", new_name);

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

bool stillOpen=false;

// //91h for 0436H MONITOR Light Information Alternative Processing
void mon_whead(void){
  char m_info[130];
  UINT bw = 0;
  
  // Information block received
  rcv_block(m_info, 128);
  
  // Extracting filename
  for (unsigned int lp1 = 0; lp1 < 17; lp1++){
    m_name[lp1] = m_info[lp1 + 1];
  }

  addrootdir(m_name_copy, m_name, sizeof(m_name_copy));
      _DEBUG("write to %s\n", m_name_copy);

  
  // Add .MZF for DOS filenames
  addmzf(m_name_copy);
  m_info[16] = 0x0D;
  
  // Delete the file if it exists
  FILINFO fno;
  if (g_fatfs->exists(m_name_copy,&fno) == FR_OK){
      _DEBUG("removing %s\n", m_name_copy);
    g_fatfs->remove(m_name_copy);
  }
  stillOpen = false;
  // Open file for writing
  if (current_file.open(m_name_copy, FILE_WRITE) >= 0) {
    // Sending status code (OK)
    sndbyte(0x00);
    

    // Information block write
    for (unsigned int lp1 = 0; lp1 < 128; lp1++){
      uint8_t byte_val = (uint8_t)m_info[lp1];
     
      current_file.write(&byte_val, 1, &bw);
    }
        _DEBUG("ok\n");

        stillOpen = true;
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
      _DEBUG("wl %u\n", f_length);

  // Open file for writing (append to existing file from mon_whead)
  if (stillOpen) {
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
      current_file.write(s_data, i, &bw);
    }
    
    _DEBUG("ok\n");
    
    stillOpen = false;
    current_file.close();
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
  rcv_filename32(m_name);
  addmzf(m_name);
  addrootdir(m_name_copy, m_name, sizeof(m_name_copy));
    _DEBUG("looking for header for '%s'\n",m_name_copy);

  // Error if the file does not exist
  FILINFO fno;
  if (g_fatfs->exists(m_name_copy,&fno) == FR_OK)
  {
    sndbyte(0x00);  // Send OK
    _DEBUG("ok\n");
    
    // Open file for reading
    if (current_file.open(m_name_copy, FILE_READ) >= 0) {
      sndbyte(0x00);  // Another OK
    _DEBUG("ok\n");
      
      // Read and send 128 bytes of header
      for (unsigned int lp1 = 0; lp1 < 128; lp1++){
        uint8_t i_data = current_file.readByte();

        sndbyte(i_data);

        }

    sndbyte(0x00);  // Final OK
    _DEBUG("ok\n");
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

  addrootdir(m_name_copy, m_name, sizeof(m_name_copy));
    _DEBUG("looking for data for '%s'\n",m_name_copy);

    /** CHECK THE FILE EXISTS STILL */

  FILINFO fno;
  if (g_fatfs->exists(m_name_copy,&fno) == FR_OK)
{
  // Error if the file does not exist (check if file is still open)
  sndbyte(0x00);  // Send OK
     _DEBUG("ok\n");
 

  /** OPEN THE FILE FOR READING */

    if (current_file.open(m_name_copy, FILE_READ) >= 0) {

    sndbyte(0x00);  // Another OK
    _DEBUG("ok\n");
    
    // Seek to current position
    current_file.seek(m_lop);
    
    // Get read size
    int f_length2 = recbyte();
    int f_length1 = recbyte();
    unsigned int f_length = f_length1 * 256 + f_length2;
    _DEBUG("l %u\n", f_length);
    
  
    // Send data
    for (unsigned int lp1 = 0; lp1 < f_length; lp1++){
      
      uint8_t i_data = current_file.readByte();
      sndbyte(i_data);
    }
    
    // Update read position
    m_lop = m_lop + f_length;
    sndbyte(0x00);  // Final OK
    _DEBUG("ok\n");
  }
  else {
    // Send status code (ERROR)
    sndbyte(0xFF);
  }
}
else
{
  //Send status code (FILE NOT FIND ERROR)
    sndbyte(0xF1);
}
}

//BOOT process (for MZ-2000_SD only)
void boot(void){
//Get filename
  rcv_filename32(m_name);

//Error if the file does not exist
  FILINFO fno;
  if (g_fatfs->exists(m_name,&fno) == FR_OK)

  {
    sndbyte(0x00);  // Send OK
//Open F
    if (current_file.open(m_name, FILE_READ) >= 0) {
      sndbyte(0x00);
// Sending file size
      unsigned long f_length = current_file.size();
      unsigned int f_len1 = f_length / 256;
      unsigned int f_len2 = f_length % 256;
      sndbyte(f_len2);
      sndbyte(f_len1);

// Sending actual data
      for (unsigned long lp1 = 1;lp1 <= f_length;lp1++){
         byte i_data = current_file.readByte();
         sndbyte(i_data);
      }
    }
    else {
//Send status code (ERROR)
      sndbyte(0xFF);
    }
  }  
  else {
//Send status code (FILE NOT FIND ERROR)
    sndbyte(0xF1);
  }
}



bool InitSDFatFs() {

  // already initialised
  if (g_fatfs != nullptr)
  {
    _DEBUG("SD: initialization skipped\n");
  
    return true;
  }

  // Allocate SD and FatFsInterface once and keep them alive for the
  // lifetime of the program so the FATFS object inside FatFsInterface
  // remains valid after this function returns.
  SdCard* sd = nullptr;

  if (sd == nullptr) {
    sd = new SdCard(kCmdPin, kClkPin, kDat0Pin);
  }

  if (!sd->initialize()) {
    _DEBUG("SD: initialization failed\n");
    return false;
  }
  _DEBUG("SD: initialization succeeded\n");

  if (g_fatfs == nullptr) {
    g_fatfs = new FatFsInterface(*sd);
  }

  // Initialize FatFs filesystem via the C++ wrapper
  _DEBUG("Initializing FatFs\n");

  if (g_fatfs->mount()) {
    _DEBUG("FatFs mounted successfully\n");
    return true;
  } else {
    _DEBUG("FatFs mount failed\n");
    g_fatfs->unmount();
    delete g_fatfs;
    g_fatfs=nullptr;
    return false;
  }
}



// --- Main Init Function ---

void mzcmd_init()
{
    // Initialize the SD card physical layer
    sdinit();


}

void mzcmd_commandwait()
{
  // Waiting for command acquisition
  _DEBUG("\ncmd: ");
  byte cmd = recbyte(); // waits for command byte
  _DEBUG("0x%02X\n",cmd);
  if (support_lfn == false)
  {
    switch (cmd)
    {
      // Save to SD card
    case SAVE:
      println("SAVE START");
      // Sending status code (OK)
      sndbyte(0x00);
      f_save();
      break;
      // Load from SD card
    case LOAD:
      println("LOAD START");
      // Sending status code (OK)
      sndbyte(0x00);
      f_load();
      // f_testload();
      break;
      // Rename and copy the specified file as 0000.mzf
    case ASTART:
      println("ASTART START");
      // Sending status code (OK)
      sndbyte(0x00);
      astart();
      break;
      // Output file list 
    case FILELIST:
      println("FILE LIST START");
      // Sending status code (OK)
      sndbyte(0x00);
      sdinit();

      dirlist();
      break;
      // Delete file
    case FILEDEL:
      println("FILE Delete START");
      // Sending status code (OK)
      sndbyte(0x00);
      f_del();
      break;
      // Rename files
    case FILEREN:
      println("FILE Rename START");
      // Sending status code (OK)
      sndbyte(0x00);
      f_ren();
      break;
    case FILEDUMP:
      // File dump 
      println("FILE Dump START");
      // Sending status code (OK)
      sndbyte(0x00);
      f_dump();
      break;
    case FILECOPY:
      // File copy 
      println("FILE Copy START");
      // Sending status code (OK)
      sndbyte(0x00);
      f_copy();
      break;
    case MONITOR_WHEAD:
      // 91h for 0436H MONITOR Light Information Alternative Processing
      println("0436H whead START");
      // Sending status code (OK)
      sndbyte(0x00);
      mon_whead();
      break;
      // 92h 0475H MONITOR Write Data Replacement Processing
    case MONITOR_WDATA:
      println("0475H wdata START");
      // Sending status code (OK)
      sndbyte(0x00);
      mon_wdata();
      break;
      // 93h 04D8H MONITOR Read Information Alternative Processing
    case MONITOR_LHEAD:
      println("04D8H lhead START");
      // Sending status code (OK)
      sndbyte(0x00);
      mon_lhead();
      break;
      // 94h 04F8H MONITOR read data substitution process
    case MONITOR_LDATA:
      println("04F8H ldata START");
      // Sending status code (OK)
      sndbyte(0x00);
      mon_ldata();
      break;
      // Boot load (for MZ-2000_SD only)
    case BOOTLOAD:
      println("BOOT LOAD START");
      // Sending status code (OK)
      sndbyte(0x00);
      boot();
      break;
    case FILECOUNT:

      println("FILE COUNT START");
      // Sending status code (OK)
      sndbyte(0x00);

     establishFileList();
     sndbyte(getFileCount()); // single byte - count is clamped to 255

      break;
    case FILEINFO:
      println("FILE INFO START");
      // Sending status code (OK)
      sndbyte(0x00);
      // Implement file info logic here
      {
        int index = recbyte();
        sendFileName(index); // send filename for the given index
      }
      break;
    case FILELOAD:
      println("FILE LOAD START");
      // Sending status code (OK)
      sndbyte(0x00);
      // Implement file load logic here
      {
        int index = recbyte();
        sendFileData(index); // load file for the given index
      }
      break;
    default:
      _DEBUG("unrecognised 0x%02X\n",cmd);
  
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



int main(void) {
    stdio_init_all();
    sleep_ms(2000);

    _DEBUG("Pico-XB80 for Sharp MZ80K v1.0.0\n");


    // Initialise the FD Rom
    const int fd_rom_start = 0xF000;
    // initialise the shadow memory
    for (int i = 0; i < EB_BUFFER_LENGTH; i++) {
        if (i >= fd_rom_start && i <= fd_rom_start + fd_rom_size) {
            _eb_memory[i] = fd_rom_data[i-fd_rom_start]; // data byte in lower 8 bits, permissions 0x01 (read-only) in upper 8 bits 
        } else {
            _eb_memory[i] = 0; // default to 0 with no permissions
        }
    }
    
    // Initialize the SD card and FatFs
    start_xb_interface();

    // Start the command loop for Sharp MZ series commands
    SharpMZ_cmdloop();
    
    // Never reaches here, unless there is problem in cmdloop.
    while (1) {
        sleep_ms(1000);
    }
}
