#include "sharp_mz.h"
#include "fatfs/ff.h"
#include "fatfs_interface.h"
#include "xb_interface/xb_if.h"
#include "FD_rom.h"
#include "pico-xb80.h"

// PORTO at 0xE000 is the decoder which
// drives The keyboard rows

// NOTE: the Original FD; MZ-80FD + MZ-80FIO needed to be plugged into the IO Interface Unit MZ-80I/O
// when it was installed type FD would read the program from ROM at 0xf000-0xf3ff 
// It would use the 4 port addresses 0xf8-0xfb to interface and grab the first 14 sectors from
// track 0 into ram address 0x9800 (i.e. machine needs > 36Kb) and then executed at that address. 
// (128 bytes per sector)

// Possibly do the same by loading boot.mzf into 0x9800 and running it when FD is used (only if boot.mzf exists)
// and use *FDS to skip booting.

char m_name_copy[130]; // includes path
unsigned long m_lop=128;
char m_name[40];

// Lowercase -> Uppercase
char upper(char c){
  if('a' <= c && c <= 'z'){
    c = c - ('a' - 'A');
  }
  return c;
}


typedef unsigned char byte;

char ROOT_DIR[12] = "/MZ_FD"; // Root directory for MZF files

byte s_data[260];

// SDCard slot pin assignments
namespace {
  constexpr uint kClkPin = 10;
  constexpr uint kCmdPin = 11;
  constexpr uint kDat0Pin = 12; // pin 12 on Revision A boards, pin 24 on Revision B boards
}  // namespace



// Forward declarations of FATFS object
class FatFsInterface* g_fatfs = nullptr;
#define USING_FATFS (NULL != g_fatfs)

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



// File operation mode constants
constexpr uint FILE_READ = 0;
constexpr uint FILE_WRITE = 1;

// SDfile: wrapper around FatFs FIL and fallback in-memory files
class SDfile {
public:
  FIL fil;

  // open file. Returns 0 on success, -1 on error. Mirrors previous SdFat_open behaviour.
  int open(const char* filename, int mode) {
    set_led(true);
    BYTE fatfs_mode = 0;
    if (mode == FILE_READ) fatfs_mode = FA_READ;
    else fatfs_mode = FA_CREATE_ALWAYS | FA_WRITE;

    FRESULT result = g_fatfs->open(&fil, filename, fatfs_mode);
    if (result == FR_OK) {
    _DEBUG("SDfile: open for %s with mode %d, FRESULT: %d\n", filename, mode, static_cast<int>(result));
      return 0;
    }
      set_led(false);
    return -1;
  }


  void close() {
    set_led(false);
    _DEBUG("SDfile: closing file %d\n", static_cast<int>(fil.obj.id));
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


// couldn't find sd card
bool sd_missing = false;



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
    list_files_local("mzf", ROOT_DIR); // TEMPORARY DIAGNOSTIC
  }

}



void println(const char* str) {
    _DEBUG("%s\n", str);
}


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



void addrootdir(char* f_name_copy, const char* f_name, size_t max_len)
{
  snprintf(f_name_copy, max_len, "%s/%s", ROOT_DIR, f_name);
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

// Receive a filename from the Z80 as a plain NUL-terminated string.
// The Z80 sends 33 bytes: the name, a CR, then NUL padding.
static void recv_name(char *out, size_t out_len)
{
  char raw[40];
  memset(raw, 0, sizeof(raw));
  rcv_filename32(raw);
  raw[33] = '\0';

  size_t n = 0;
  for (size_t i = 0; i < 33 && n + 1 < out_len; i++)
  {
    if (raw[i] == 0x0D || raw[i] == '\0') break;
    out[n++] = raw[i];
  }
  while (n > 0 && out[n - 1] == ' ') n--; // drop the header's space padding
  out[n] = '\0';
}

// Build "<ROOT_DIR>/<name>.mzf", tolerating a name that already carries the
// extension.
static void make_mzf_path(char *dest, size_t dest_len, const char *name)
{
  size_t len = strlen(name);
  if (len > 4 && strncasecmp(name + len - 4, ".mzf", 4) == 0)
  {
    snprintf(dest, dest_len, "%s/%s", ROOT_DIR, name);
  }
  else
  {
    snprintf(dest, dest_len, "%s/%s.mzf", ROOT_DIR, name);
  }
}

// Strip the ".mzf" extension from an SD filename.
static void strip_mzf(char *dest, size_t dest_len, const char *sdname)
{
  size_t len = strlen(sdname);
  if (len > 4 && strncasecmp(sdname + len - 4, ".mzf", 4) == 0) len -= 4;
  if (len > dest_len - 1) len = dest_len - 1;
  memcpy(dest, sdname, len);
  dest[len] = '\0';
}

// Find the file a name from the Z80 refers to and return its full SD path.
//
// Per OPERATING.md names are IBF names - the name stored inside the file
// header - so that is matched first. The SD card filename is only tried as a
// fallback, which is what lets "*FD" boot 0000.mzf by its SD name even though
// that file's IBF name is whatever program it holds.
//
// With allow_prefix set, a leading-substring match is accepted too, matching
// how BASIC lets you abbreviate a name after LOAD.
static bool resolve_name(const char *name, char *path, size_t path_len,
                         bool allow_prefix)
{
  if (name[0] == '\0') return false;

  establishFileList(ROOT_DIR);
  const uint8_t count = getFileCount();
  const size_t want = strlen(name);

  // 1. exact listed name, which carries the <n tag when a name is shared and
  //    so is the only way to single out one file of a duplicate group
  for (uint8_t i = 0; i < count; i++)
  {
    if (strcasecmp(getDisplayName(i), name) == 0)
    {
      addrootdir(path, getFileName(i), path_len);
      return true;
    }
  }

  // 2. exact IBF name as the header holds it, so an untagged name typed from
  //    BASIC still finds the first file carrying it
  for (uint8_t i = 0; i < count; i++)
  {
    if (strcasecmp(getRawName(i), name) == 0)
    {
      addrootdir(path, getFileName(i), path_len);
      return true;
    }
  }

  // 3. exact SD filename
  for (uint8_t i = 0; i < count; i++)
  {
    char base[300];
    strip_mzf(base, sizeof(base), getFileName(i));
    if (strcasecmp(base, name) == 0)
    {
      addrootdir(path, getFileName(i), path_len);
      return true;
    }
  }

  if (!allow_prefix) return false;

  // 4. IBF name beginning with the requested text
  for (uint8_t i = 0; i < count; i++)
  {
    if (strncasecmp(getRawName(i), name, want) == 0)
    {
      addrootdir(path, getFileName(i), path_len);
      return true;
    }
  }

  return false;
}

// True if any file already carries this IBF name, which is what rename and
// copy check their destination against.
//
// except_path lets rename ignore the file being renamed, so giving a file an
// IBF name that already matches its own SD filename is not reported as a
// collision with itself.
static bool ibf_name_taken(const char *name, const char *except_path)
{
  establishFileList(ROOT_DIR);
  const uint8_t count = getFileCount();

  for (uint8_t i = 0; i < count; i++)
  {
    char path[300];
    addrootdir(path, getFileName(i), sizeof(path));
    if (except_path != nullptr && strcasecmp(path, except_path) == 0) continue;

    // The header name, not the listed one - a <n tag is only a label this
    // scan added, so it must not make a name look free or taken.
    if (strcasecmp(getRawName(i), name) == 0) return true;

    char base[300];
    strip_mzf(base, sizeof(base), getFileName(i));
    if (strcasecmp(base, name) == 0) return true;
  }
  return false;
}

// Receive a listing index from the Z80 and turn it into the file's SD path.
// The index refers to the list built by the last FILECOUNT - the one the menu
// is showing - so it picks exactly the row the user chose, even where several
// files share an IBF name. Copies the path out because anything that rescans
// (resolve_name, ibf_name_taken) will overwrite the list entries.
static bool recv_source_index(char *path, size_t path_len)
{
  uint8_t index = recbyte();
  if (index >= getFileCount())
  {
    return false;
  }
  addrootdir(path, getFileName(index), path_len);
  return true;
}

// Overwrite the 17-byte IBF name field in an existing file's header so a
// renamed or copied file lists under its new name.
static bool write_ibf_name(const char *path, const char *name)
{
  FIL fp;
  if (f_open(&fp, path, FA_READ | FA_WRITE) != FR_OK) return false;
  if (f_lseek(&fp, IBF_NAME_OFFSET) != FR_OK)
  {
    f_close(&fp);
    return false;
  }

  char field[IBF_NAME_MAX];
  memset(field, 0, sizeof(field));
  size_t n = strlen(name);
  if (n > sizeof(field) - 1) n = sizeof(field) - 1;
  memcpy(field, name, n);
  field[n] = 0x0D; // CR terminates the name field

  UINT bw = 0;
  FRESULT res = f_write(&fp, field, sizeof(field), &bw);
  f_close(&fp);
  return res == FR_OK && bw == sizeof(field);
}

// Save to SD card
void f_save()
{
  char p_name[20];
  uint bw = 0;
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

    // Program name (17 bytes, header offsets 01H-11H)
    current_file.write((uint8_t*)p_name, 17, &bw);

    uint8_t null_byte = 0x00;

    // File size (2 bytes) - this belongs at offset 12H. An extra null used
    // to be written here first, pushing the size, load and exec addresses
    // one byte along so f_send() read them back from the wrong offsets.
    current_file.write((uint8_t*)&f_length1, 1, &bw);
    current_file.write((uint8_t*)&f_length2, 1, &bw);
    
    // Start address (2 bytes)
    current_file.write((uint8_t*)&s_adrs1, 1, &bw);
    current_file.write((uint8_t*)&s_adrs2, 1, &bw);
    
    // Execution address (2 bytes)
    current_file.write((uint8_t*)&g_adrs1, 1, &bw);
    current_file.write((uint8_t*)&g_adrs2, 1, &bw);
    
    // Fill up to 7FH with 00 (1 + 17 + 6 bytes written so far)
    {
      uint8_t zero[128];
      memset(zero, null_byte, 128);
      current_file.write(zero, 128 - 24, &bw);
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

void f_send(const char* f_name_copy)
{
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

      // uint8_t char_repr = (wk1 >= 32 && wk1 <= 126) ? wk1 : '.'; // printable ASCII or dot

      //  _DEBUG("%c ",char_repr);
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
  char i_name[40];
  recv_name(i_name, sizeof(i_name));
  _DEBUG("%s\n", i_name);

  char f_name[300];
  if (resolve_name(i_name, f_name, sizeof(f_name), false))
  {
    f_send(f_name);
  }
  else
  {
    sndbyte(0xF1);  // File not found error
  }
}

// ASTART - copy the located file over "0000.mzf". Sends a single status byte
// once the copy is done (or has failed).
static void astart_core(const char *src)
{
  char w_name[50];
  addrootdir(w_name, "0000.mzf", sizeof(w_name)); // prepend root directory to filename

  // Get the IBF filename and find the file it names
  char i_name[40];
  recv_name(i_name, sizeof(i_name));

  // Error if the file does not exist
  if (resolve_name(i_name, m_name_copy, sizeof(m_name_copy), false))
  {
    // If 0000.mzf exists, delete it
    FILINFO fno;
    if (g_fatfs->exists(w_name,&fno) == FR_OK)
    {
      g_fatfs->remove(w_name);
    }
    
    // Open source file for reading
    if (current_file.open(src, FILE_READ) >= 0)
    {
      // Get file size
      FSIZE_t f_length = current_file.size();
      
      // Close read file
      current_file.close();
      
      // Open destination file for writing
      if (current_file_for_copy.open(w_name, FILE_WRITE) >= 0)
      {
        // Reopen source file for reading
        current_file.open(src, FILE_READ);
        
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



// Missing wrapper called by mzcmd_commandwait()
void astart(void)
{
  char i_name[40];
  recv_name(i_name, sizeof(i_name));
  _DEBUG("astart: %s\n", i_name);

  char path[300];
  if (resolve_name(i_name, path, sizeof(path), false))
  {
    astart_core(path);
  }
  else
  {
    sndbyte(0xF1);
    sdinit();
  }
}

void sendFileName(const uint8_t index)
{
  uint8_t FileCount = getFileCount();
  if (index >= FileCount || index >= 255) {
    sndbyte(0xF1); // error: index out of bounds
    return;
  }
  sndbyte(0x00); // ok - got the file name

  // File type first, so the ROM can honour the BASIC/machine-code filter
  sndbyte(getFileAttr(index));

  // send up to 32 characters of the IBF name, including null terminator if present
  // terminate at 0
  const char* name = getDisplayName(index);
  for (int i = 0; i < 32; i++) {
    char c = name[i];
    sndbyte(c);
    if (c == '\0') break; // stop sending if we hit the null terminator
  }
}



// Read from SD card
void sendFileData(const uint8_t index)
{
    uint8_t FileCount = getFileCount();

  if (index >= FileCount || index >= 255) {
    sndbyte(0xF1); // error: index out of bounds
    return;
  }

  // Loading is by index, so the real SD path is used directly here rather
  // than going back through an IBF name lookup.
  char f_name[300];
  addrootdir(f_name, getFileName(index), sizeof(f_name));

  _DEBUG("sendFileData: %s\n", f_name);

  f_send(f_name);
}


// SD system filelist. Lists IBF names, matching the file menu.
void dirlist(void)
{
  // Get comparison string (up to 32+1 characters)
  char c_name[40];
  recv_name(c_name, sizeof(c_name));

  _DEBUG("dirlist: comparison string: %s\n", c_name);

  establishFileList(ROOT_DIR);
  const uint8_t count = getFileCount();
  const size_t match_len = strlen(c_name);

  int shown = 0;
  uint8_t i = 0;
  uint8_t page_start = 0;

  while (i < count)
  {
    const char *name = getDisplayName(i);

    if (match_len == 0 || strncasecmp(name, c_name, match_len) == 0)
    {
      _DEBUG("direntry %s\n", name);

      for (unsigned int lp1 = 0; lp1 < 36 && name[lp1] != '\0'; lp1++)
      {
        sndbyte(upper(name[lp1]));
      }
      sndbyte(0x0D);
      sndbyte(0x00);
      shown++;
    }
    i++;

    // Pause after a screenful
    if (shown >= 20)
    {
      sndbyte(0xFE);  // Request for instructions

      // Selection: 0 = continue, 'B' = previous page, anything else = stop
      unsigned int br_chk = recbyte();
      if (br_chk != 0 && br_chk != 0x42) return;

      if (br_chk == 0x42)
      {
        // Step back over this page and the one before it
        i = (page_start >= 20) ? (uint8_t)(page_start - 20) : 0;
      }
      page_start = i;
      shown = 0;
    }
  }

  // Send termination
  sndbyte(0xFF);
  sndbyte(0x00);
}


// FILE DELETE - everything after the file has been located.
// Protocol: status 0, confirm byte in (0 = go ahead), result.
static void del_core(const char *path)
{
  // Sending status code (OK)
  sndbyte(0x00);

  // Receive processing selection (0: Continue DELETE, Non-zero: CANCEL)
  if (recbyte() == 0x00)
  {
    if (g_fatfs->remove(path) == FR_OK)
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

// FILE DELETE by IBF name
void f_del(void)
{
  char i_name[40];
  recv_name(i_name, sizeof(i_name));
  char path[300];

  if (resolve_name(i_name, path, sizeof(path), false))
  {
    del_core(path);
  }
  else
  {
    sndbyte(0xF1);
    sdinit();
  }
}

// FILE DELETE by listing index
void f_del_idx(void)
{
  char path[300];
  if (recv_source_index(path, sizeof(path)))
  {
    del_core(path);
  }
  else
  {
    sndbyte(0xF1);
  }
}

// FILERENAME - everything after the file has been located.
// Protocol: status 0, new name in, status 0, result.
static void ren_core(const char *path)
{
  // Sending status code (OK)
  sndbyte(0x00);

  // Get new filename
  char n_name[40];
  recv_name(n_name, sizeof(n_name));

  // Sending status code (OK)
  sndbyte(0x00);

  // Fail if the new name is already in use as an IBF name
  char new_path[300];
  make_mzf_path(new_path, sizeof(new_path), n_name);

  if (ibf_name_taken(n_name, path))
  {
    _DEBUG("%s already exists\n", n_name);
    sndbyte(0xFF);
    return;
  }

  // Rename the file, then put the new name inside the header too so the
  // listing (which shows IBF names) reflects the change.
  if (f_rename(path, new_path) == FR_OK && write_ibf_name(new_path, n_name))
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

// FILERENAME by IBF name
void f_ren(void)
{
  char i_name[40];
  recv_name(i_name, sizeof(i_name));
  char path[300];

  if (resolve_name(i_name, path, sizeof(path), false))
  {
    ren_core(path);
  }
  else
  {
    sndbyte(0xF1);
    sdinit();
  }
}

// FILERENAME by listing index
void f_ren_idx(void)
{
  char path[300];
  if (recv_source_index(path, sizeof(path)))
  {
    ren_core(path);
  }
  else
  {
    sndbyte(0xF1);
  }
}

        // FILE DUMP
// FILE DUMP - everything after the file has been located.
// Protocol: status 0, then blocks of {offset lo, offset hi, 128 bytes, key
// byte in}, ending with offset FFFF and a final status.
static void dump_core(const char *f_name)
{
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
}

// FILE DUMP by IBF name
void f_dump(void)
{
  char i_name[40];
  recv_name(i_name, sizeof(i_name));
  char path[300];

  _DEBUG("fname %s\n", i_name);

  if (resolve_name(i_name, path, sizeof(path), false))
  {
    dump_core(path);
  }
  else
  {
    sndbyte(0xF1);
    sdinit();
  }
}

// FILE DUMP by listing index
void f_dump_idx(void)
{
  char path[300];
  if (recv_source_index(path, sizeof(path)))
  {
    dump_core(path);
  }
  else
  {
    sndbyte(0xF1);
  }
}

// FILE COPY - everything after the source file has been located.
// Protocol: status 0, new name in, status (F1 if that name is taken), result.
static void copy_core(const char *f_name)
{
  {
    // Sending status code (OK)
    sndbyte(0x00);

    // Get new filename
    char n_name[40];
    recv_name(n_name, sizeof(n_name));
    char new_name[300];
    make_mzf_path(new_name, sizeof(new_name), n_name);

    _DEBUG("%s -> %s\n", f_name, new_name);

    // An error will occur if a file with the same IBF name already exists
    if (!ibf_name_taken(n_name, nullptr))
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

          // Give the copy its own IBF name, so the listing does not show two
          // files under the same name.
          if (write_ibf_name(new_name, n_name))
          {
            // Sending status code (OK)
            sndbyte(0x00);
          }
          else
          {
            sndbyte(0xF1);
          }
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
}

// FILE COPY by IBF name
void f_copy(void)
{
  char i_name[40];
  recv_name(i_name, sizeof(i_name));
  char path[300];

  _DEBUG("copy %s\n", i_name);

  if (resolve_name(i_name, path, sizeof(path), false))
  {
    copy_core(path);
  }
  else
  {
    sndbyte(0xF1);
    sdinit();
  }
}

// FILE COPY by listing index
void f_copy_idx(void)
{
  char path[300];
  if (recv_source_index(path, sizeof(path)))
  {
    copy_core(path);
  }
  else
  {
    sndbyte(0xF1);
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
  
  
  // Get the IBF filename BASIC asked for
  recv_name(m_name, sizeof(m_name));
  _DEBUG("looking for header for '%s' in '%s'\n", m_name, ROOT_DIR);

  // Match on the IBF name inside the header, not the SD card filename.
  // A leading-substring match is allowed so a name can be abbreviated after
  // LOAD, which is how the old SD-filename wildcard search behaved.
  if (resolve_name(m_name, m_name_copy, sizeof(m_name_copy), true))
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
      // _DEBUG("%02x ",i_data);
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

  // addrootdir(m_name_copy, m_name, sizeof(m_name_copy));
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
  if (sd_missing == false)
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

     establishFileList(ROOT_DIR);
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



void SharpMZ_cmdloop()
{
    mzcmd_init();
 
    _DEBUG("\nEntering Sharp MZ command loop. Waiting for commands from Z80...\n");

    uint8_t last_command = 0;
    while(1)
    {
        mzcmd_commandwait();
    }
    
}

void SharpMZ_initialise()
{
    // Initialise the FD Rom
    const int fd_rom_start = 0xF000;

    assert(fd_rom_size <= 0x0ff9); // Cannot drift into the bytes used for the SD card interface (0xFFFA-0xFFFF)
    // initialise the shadow memory
    for (int i = 0; i < EB_BUFFER_LENGTH; i++) {
        if (i >= fd_rom_start && i < fd_rom_start + fd_rom_size) {
            eb_set(i, fd_rom_data[i-fd_rom_start]); // data byte in lower 8 bits
        } else {
            eb_set(i, 0); // default to 0 
        }
    }

    // the ROM - permissions 0x01 (read-only) in upper 8 bits
    eb_set_perm(0xF000, EB_PERM_READ_ONLY, 0x0FF9);


    // z80 empties first, then expects pico to empty - this means the
    // ROM is ready to be read by the Z80 and the SD card interface is ready to be used
    wait_z80_mailbox_empty();

}