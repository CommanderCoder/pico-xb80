// 2022.1.24 Modified the process to correct the 20h padding at the end of filenames to 0dh, moving from the Arduino side to the MZ-80K side.
// Review the description of comparison operators
// 2022.1.25 Deprecated delay() when receiving each command.
// 2022.1.26 Removed the restriction that only file type codes 0x01 could be loaded using the FD command.
// 2022.1.29 Fixed a bug in the FDP command.
// 2022.1.30 FDL command specification change: For FDL AZ, only files with matching first characters in the filename will be output.
// 2022.1.31 FDL command specification change: When using FDL x, only files with matching first characters in the filename are output.
// Press the B key to display the previous 20 items
// 2022.2.2 Modified to allow searching with FDL x even if the DOS file name is in lowercase letters.
// 2022.2.4 MZ-1200 countermeasure: Added delay(1000) during initialization.
// 2022.2.8 FDL command specification change: For FDL x, the filename can be expanded to 1 to 32 characters from the beginning.
// June 19, 2023: Added BOOT LOADER loading functionality due to the addition of a boot method for MZ-2000_SD. This does not affect MZ-80K_SD.
// 2024.3.4 Added initialization process when SD-card is reinserted.
// 2025.12.4 Removed unnecessary addmzt from mon_ldata processing.
//
#include "SdFat.h"
#include
SdFat SD;
unsigned long m_lop = 128;
char m_name[40];
byte s_data[260];
char f_name[40];
char c_name[40];
char new_name[40];

#define CABLESELECTPIN (10)
#define CHKPIN (15)
#define PB0PIN (2)
#define PB1PIN (3)
#define PB2PIN (4)
#define PB3PIN (5)
#define PB4PIN (6)
#define PB5PIN (7)
#define PB6PIN (8)
#define PB7PIN (9)
#define FLGPIN (14)
#define PA0PIN (16)
#define PA1PIN (17)
#define PA2PIN (18)
#define PA3PIN (19)
//File names support long filename format.
boolean eflg;

void sdinit(void){
  // SD system initialization
  if( !SD.begin(CABLESELECTPIN,8) )
  {
//// Serial.println("Failed : SD.begin");
    eflg = true;
  else {
//// Serial.println("OK : SD.begin");
    eflg = false;
  }
//// Serial.println("START");
}

void setup(){
//// Serial.begin(9600);
// CS=pin10
// pin10 output

  pinMode(CABLESELECTPIN,OUTPUT);
  pinMode(CHKPIN,INPUT); //CHK
  pinMode(PB0PIN,OUTPUT); //Data to send
  pinMode( PB1PIN,OUTPUT); //Data to transmit
  pinMode( PB2PIN,OUTPUT); //Data to transmit
  pinMode( PB3PIN,OUTPUT); //Data to transmit
  pinMode( PB4PIN,OUTPUT); //Transmit data
  pinMode( PB5PIN,OUTPUT); //Transmit data
  pinMode( PB6PIN,OUTPUT); //Transmit data
  pinMode( PB7PIN,OUTPUT); //Transmit data
  pinMode( FLGPIN,OUTPUT); //FLG

  pinMode(PA0PIN,INPUT_PULLUP); //Received data
  pinMode(PA1PIN,INPUT_PULLUP); //Received data
  pinMode(PA2PIN,INPUT_PULLUP); //Received data
  pinMode(PA3PIN,INPUT_PULLUP); //Received data

  digitalWrite(PB0PIN,LOW);
  digitalWrite(PB1PIN,LOW);
  digitalWrite(PB2PIN,LOW);
  digitalWrite(PB3PIN,LOW);
  digitalWrite(PB4PIN,LOW);
  digitalWrite(PB5PIN,LOW);
  digitalWrite(PB6PIN,LOW);
  digitalWrite(PB7PIN,LOW);
  digitalWrite(FLGPIN,LOW);

// 2022.2.4 MZ-1200 countermeasures
  delay(1500);

  sdinit();
}

//4-bit reception
byte rcv4bit(void){
// Loop until it becomes HIGH
  while(digitalRead(CHKPIN) != HIGH){
  }
// Received
  byte j_data = digitalRead(PA0PIN)+digitalRead(PA1PIN)*2+digitalRead(PA2PIN)*4+digitalRead(PA3PIN)*8;
//Set FLG
  digitalWrite(FLGPIN,HIGH);
// Loops until LOW
  while(digitalRead(CHKPIN) == HIGH){
  }
// Reset FLG
  digitalWrite(FLGPIN,LOW);
  return(j_data);
}

// 1 BYTE games
byte rcv1byte(void){
  byte i_data = 0;
  i_data=rcv4bit()*16;
  i_data = i_data + rcv4bit();
  return(i_data);
}

// 1 BYTE transmission
void snd1byte(byte i_data){
// Set the 8 bits from the least significant bit.
  digitalWrite(PB0PIN,(i_data)&0x01);
  digitalWrite(PB1PIN,(i_data>>1)&0x01);
  digitalWrite(PB2PIN,(i_data>>2)&0x01);
  digitalWrite(PB3PIN,(i_data>>3)&0x01);
  digitalWrite(PB4PIN,(i_data>>4)&0x01);
  digitalWrite(PB5PIN,(i_data>>5)&0x01);
  digitalWrite(PB6PIN,(i_data>>6)&0x01);
  digitalWrite(PB7PIN,(i_data>>7)&0x01);
  digitalWrite(FLGPIN,HIGH);
// Loop until it becomes HIGH
  while(digitalRead(CHKPIN) != HIGH){
  }
  digitalWrite(FLGPIN,LOW);
// Loops until LOW
  while(digitalRead(CHKPIN) == HIGH){
  }
}

// Lowercase -> Uppercase
char upper(char c){
  if('a' <= c && c <= 'z'){
    c = c - ('a' - 'A');
  }
  return c;
}

//Add if the filename does not end in ".mzt"
void addmzt(char *f_name){
  unsigned int lp1=0;
  while (f_name[lp1] != 0x0D){
    lp1++;
  }
  if (f_name[lp1-4]!='.' ||
    ( f_name[lp1-3]!='M' &&
      f_name[lp1-3]!='m' ) ||
    ( f_name[lp1-2]!='Z' &&
      f_name[lp1-2]!='z' ) ||
    ( f_name[lp1-1]!='T' &&
      f_name[lp1-1]!='t' ) ){
         f_name[lp1++] = '.';
         f_name[lp1++] = 'm';
         f_name[lp1++] = 'z';
         f_name[lp1++] = 't';
  }
  f_name[lp1] = 0x00;
}

// Save to SD card
void f_save(void){
char p_name[20];

//Get the saved file name
  for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
    f_name[lp1] = rcv1byte();
  }
  addmzt(f_name);
//Get the program name
  for (unsigned int lp1 = 0;lp1 <= 16;lp1++){
    p_name[lp1] = rcv1byte();
  }
  p_name[15] = 0x0D;
  p_name[16] = 0x00;
// Get start address
  int s_adrs1 = rcv1byte();
  int s_adrs2 = rcv1byte();
//Calculate start address
  unsigned int s_adrs = s_adrs1+s_adrs2*256;
// Get end address
  int e_adrs1 = rcv1byte();
  int e_adrs2 = rcv1byte();
// End address calculation
  unsigned int e_adrs = e_adrs1+e_adrs2*256;
//Get execution address
  int g_adrs1 = rcv1byte();
  int g_adrs2 = rcv1byte();
//Calculate execution address
  unsigned int g_adrs = g_adrs1+g_adrs2*256;
// File size calculation
  unsigned int f_length = e_adrs - s_adrs + 1;
  unsigned int f_length1 = f_length % 256;
  unsigned int f_length2 = f_length / 256;
// Delete the file if it exists.
  if (SD.exists(f_name) == true){
    SD.remove(f_name);
  }
//Open F
  File file = SD.open( f_name, FILE_WRITE );
  if ( true == file ) {
//Sending status code (OK)
    snd1byte(0x00);
//File mode setting (01)
    file.write(char(0x01));
//Program name
    file.write(p_name);
    file.write(char(0x00));
// File size
    file.write(f_length1);
    file.write(f_length2);
// Start address
    file.write(s_adrs1);
    file.write(s_adrs2);
//Execution address
    file.write(g_adrs1);
    file.write(g_adrs2);
// Fill up to 7F with 00
    for (unsigned int lp1 = 0;lp1 <= 103;lp1++){
      file.write(char(0x00));
    }
// Actual data
    long lp1 = 0;
    while (lp1 <= f_length-1){
      int i=0;
      while(i<=255 && lp1<=f_length-1){
        s_data[i] = rcv1byte();
        i++;
        lp1++;
      }
      file.write(s_data,i);
    }
    file.close();
   else {
//Send status code (ERROR)
    snd1byte(0xF1);
    sdinit();
  }
}

//Read from SD card
void f_load(void){
//Get filename
  for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
    f_name[lp1] = rcv1byte();
  }
  addmzt(f_name);
//Error if the file does not exist
  if (SD.exists(f_name) == true){
//Open F
    File file = SD.open( f_name, FILE_READ );
    if ( true == file ) {
// Eliminate the need to determine the file type code.
// if( file.read() == 0x01){
//Sending status code (OK)
        snd1byte(0x00);
        int wk1 = 0;
        wk1 = file.read();
        for (unsigned int lp1 = 0;lp1 <= 16;lp1++){
          wk1 = file.read();
          snd1byte(wk1);
        }
//Get file size
        int f_length2 = file.read();
        int f_length1 = file.read();
        unsigned int f_length = f_length1*256+f_length2;
// Get start address
        int s_adrs2 = file.read();
        int s_adrs1 = file.read();
        unsigned int s_adrs = s_adrs1*256+s_adrs2;
//Get execution address
        int g_adrs2 = file.read();
        int g_adrs1 = file.read();
        unsigned int g_adrs = g_adrs1*256+g_adrs2;
        snd1byte(s_adrs2);
        snd1byte(s_adrs1);
        snd1byte(f_length2);
        snd1byte(f_length1);
        snd1byte(g_adrs2);
        snd1byte(g_adrs1);
        file.seek(128);
//Data transmission
        for (unsigned int lp1 = 0;lp1 < f_length;lp1++){
            byte i_data = file.read();
            snd1byte(i_data);
        }
        file.close();
// } else {
//Send status code (ERROR)
// snd1byte(0xF2);
          sdinit();
// }  
     else {
//Send status code (ERROR)
      snd1byte(0xFF);
      sdinit();
   }  
   else {
//Send status code (FILE NOT FIND ERROR)
    snd1byte(0xF1);
    sdinit();
  }
}

//ASTART Copies the specified file as filename "0000.mzt"
void astart(void){
char w_name[]="0000.mzt";

//Get filename
  for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
    f_name[lp1] = rcv1byte();
  }
  addmzt(f_name);
//Error if the file does not exist
  if (SD.exists(f_name) == true){
//If 0000.mzt exists, delete it.
    if (SD.exists(w_name) == true){
      SD.remove(w_name);
    }
//Open F
    File file_r = SD.open( f_name, FILE_READ );
    File file_w = SD.open( w_name, FILE_WRITE );
      if ( true == file_r ) {
// Actual data
        unsigned int f_length = file_r.size();
        long lp1 = 0;
        while (lp1 <= f_length-1){
          int i=0;
          while(i<=255 && lp1<=f_length-1){
            s_data[i] = file_r.read();
            i++;
            lp1++;
          }
          file_w.write(s_data,i);
        }
        file_w.close();
        file_r.close();
//Sending status code (OK)
        snd1byte(0x00);
      else {
//Send status code (ERROR)
      snd1byte(0xF1);
      sdinit();
    }
  else {
//Send status code (ERROR)
    snd1byte(0xF1);
    sdinit();
  }  
}

// SD system filelist
void dirlist(void){
// Get comparison string (up to 32+1 characters)
  for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
    c_name[lp1] = rcv1byte();
// Serial.print(c_name[lp1],HEX);
// Serial.println("");
  }
//
  File file = SD.open("/");
  File entry = file.openNextFile();
  int cntl2 = 0;
  unsigned int br_chk = 0;
  int page = 1;
//If outputting all items, the process will pause after 20 items have been output. You can then select to continue or stop by typing.
  while (br_chk == 0) {
    if(entry){
      entry.getName(f_name,36);
      unsigned int lp1=0;
//Send one item
// Compares the filename using the comparison string, up to the first 10 characters, and outputs only those that match.
      if (f_match(f_name,c_name)){
        while (lp1<=36 && f_name[lp1]!=0x00){
        snd1byte(upper(f_name[lp1]));
        lp1++;
        }
        snd1byte(0x0D);
        snd1byte(0x00);
        cntl2++;
      }
    }
    if (!entry || cntl2 > 19){
// Request for instructions on whether to continue or discontinue.
      snd1byte(0xfe);

//Selection instruction received (0: Continue, B: Previous page, Other: Terminate)
      br_chk = rcv1byte();
//Previous page processing
      if (br_chk==0x42){
// To the first file
        file.rewindDirectory();
// Entry Value update
        entry = file.openNextFile();
// Go back to the first file again
        file.rewindDirectory();
        if(page <= 2){
//If the current page is page 1 or 2, return to page 1.
          page = 0;
        else {
//If the current page is page 3 or later, skip the files up to two pages prior.
          page = page - 2;
          cntl2=0;
          while(cntl2 < page*20){
            entry = file.openNextFile();
// if (upper(f_name[0]) == pg0 || pg0 == 0x20){
            if (f_match(f_name,c_name)){
              cntl2++;
            }
          }
        }
        br_chk=0;
      }
      page++;
      cntl2 = 0;
    }
//If there are still files, load the next one; otherwise, stop loading.
    if (entry){
      entry = file.openNextFile();
    else
      br_chk=1;
    }
//If the FDL results are less than 20, the process will terminate without requesting further instructions.
    if (!entry && cntl2 < 20 && page ==1){
      break;
    }
  }
// Processing termination instruction
  snd1byte(0xFF);
  snd1byte(0x00);
}

// Compare f_name and c_name until c_name contains 0x00
//FILENAME COMPARE
boolean f_match(char *f_name,char *c_name){
  boolean flg1 = true;
  unsigned int lp1 = 0;
// Serial.print(f_name);
// Serial.print(" ");
// Serial.print(c_name);
// Serial.print(" ");
  while (lp1 <=32 && c_name[0] != 0x00 && flg1 == true){
// Serial.print(f_name[lp1],HEX);
// Serial.Print("-");
// Serial.print(c_name[lp1+1],HEX);
// Serial.print(" ");
    if (upper(f_name[lp1]) != c_name[lp1+1]){
      flg1 = false;
    }
    lp1++;
    if (c_name[lp1+1]==0x00){
      break;
    }
  }
// if (flg1){
// Serial.println("true");
// } else{
// Serial.println("false");
// }
  return flg1;
}

//FILE DELETE
void f_del(void){

//Get filename
  for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
    f_name[lp1] = rcv1byte();
  }
  addmzt(f_name);

//Error if the file does not exist
  if (SD.exists(f_name) == true){
//Sending status code (OK)
    snd1byte(0x00);

// Receive processing selection (0: Continue DELETE, Non-zero: CANSEL)
    if (rcv1byte() == 0x00){
      if (SD.remove(f_name) == true){
//Sending status code (OK)
        snd1byte(0x00);
      else
//Send status code (Error)
        snd1byte(0xf1);
        sdinit();
      }
    else
//Send status code (Cancel)
      snd1byte(0x01);
    }
  else
//Send status code (Error)
        snd1byte(0xf1);
        sdinit();
  }
}

//FILERENAME
void f_len(void){

//Get the current file name
  for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
    f_name[lp1] = rcv1byte();
  }
  addmzt(f_name);

//Error if the file does not exist
  if (SD.exists(f_name) == true){
//Sending status code (OK)
    snd1byte(0x00);

//Get new filename
    for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
      new_name[lp1] = rcv1byte();
    }
    addmzt(new_name);
//Sending status code (OK)
    snd1byte(0x00);

    File file = SD.open( f_name, FILE_WRITE );
    if ( true == file ) {
      if (file.rename(new_name)){
 //Sending status code (OK)
         snd1byte(0x00);
        else {
 //Sending status code (OK)
          snd1byte(0xff);
        }
      file.close();
    else
//Send status code (Error)
      snd1byte(0xf1);
      sdinit();
    }
  else
//Send status code (Error)
      snd1byte(0xf1);
      sdinit();
  }
}

//FILE DUMP
void f_dump(void){
unsigned int br_chk = 0;

//Get filename
  for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
    f_name[lp1] = rcv1byte();
  }
  addmzt(f_name);

//Error if the file does not exist
  if (SD.exists(f_name) == true){
//Sending status code (OK)
    snd1byte(0x00);

//Open F
    File file = SD.open( f_name, FILE_READ );
      if ( true == file ) {
// Actual data transmission (1 screen: 128 bytes)
        unsigned int f_length = file.size();
        long lp1 = 0;
        while (lp1 <= f_length-1){
//Send ADRS at the top of the screen
          snd1byte(lp1 % 256);
          snd1byte(lp1 / 256);
          int i=0;
// Send actual data
          while(i<128 && lp1<=f_length-1){
            snd1byte(file.read());
            i++;
            lp1++;
          }
//If FILE END is less than 128 bytes, send 0x00 to the remaining bytes.
          while(i<128){
            snd1byte(0x00);
            i++;
          }
Waiting for instructions
          br_chk=rcv1byte();
//If BREAK, set the pointer to FILE END
          if (br_chk==0xff){
            lp1 = f_length;
          }
//B:When BACK is received, the pointer is reset by 256 bytes. If it's the first screen, reset it to 0 and display the first screen again.
          if (br_chk==0x42){
            if(lp1>255){
              if (lp1 % 128 == 0){
                lp1 = lp1 - 256;
              else {
                lp1 = lp1 - 128 - (lp1 % 128);
              }
              file.seek(lp1);
            else
              lp1 = 0;
              file.seek(0);
            }
          }
        }
//If FILE END or BREAK, send exit code 0FFFFH to ADRS.
        if (lp1 > f_length-1){
          snd1byte(0xff);
          snd1byte(0xff);
        };
        file.close();
//Sending status code (OK)
        snd1byte(0x00);
      else {
//Send status code (ERROR)
      snd1byte(0xF1);
      sdinit();
    }
  else
//Send status code (Error)
        snd1byte(0xf1);
        sdinit();
  }
}

//FILE COPY
void f_copy(void){

//Get the current file name
  for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
    f_name[lp1] = rcv1byte();
  }
  addmzt(f_name);
//Error if the file does not exist
  if (SD.exists(f_name) == true){
//Sending status code (OK)
    snd1byte(0x00);

//Get new filename
    for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
      new_name[lp1] = rcv1byte();
    }
    addmzt(new_name);
// An error will occur if a file with the same name as the new file name already exists.
    if (SD.exists(new_name) == false){
//Sending status code (OK)
        snd1byte(0x00);
//Open F
    File file_r = SD.open( f_name, FILE_READ );
    File file_w = SD.open( new_name, FILE_WRITE );
      if ( true == file_r ) {
// Copy of actual data
        unsigned int f_length = file_r.size();
        long lp1 = 0;
        while (lp1 <= f_length-1){
          int i=0;
          while(i<=255 && lp1<=f_length-1){
            s_data[i] = file_r.read();
            i++;
            lp1++;
          }
          file_w.write(s_data,i);
        }
        file_w.close();
        file_r.close();
//Sending status code (OK)
        snd1byte(0x00);
      else
//Send status code (Error)
      snd1byte(0xf1);
      sdinit();
    }
      else
//Send status code (Error)
        snd1byte(0xf3);
        sdinit();
    }
  else
//Send status code (Error)
      snd1byte(0xf1);
      sdinit();
  }
}

//91h for 0436H MONITOR Light Information Alternative Processing
void mon_whead(void){
char m_info[130];
// Information block received
  for (unsigned int lp1 = 0;lp1 < 128;lp1++){
    m_info[lp1] = rcv1byte();
  }
//S-OS SWORD sends filenames ending in 20h, so we add 0dh.
//The 8080 text editor and assembler send 20h after the filename, so it has been corrected to 0dh.
//This will be handled on the MZ-80K side.
// int lp2 = 17;
// while (lp2>0 && (m_info[lp2] ==0x20 || m_info[lp2] ==0x0d)){
// m_info[lp2]=0x0d;
// lp2--;
// }
// Extracting filename
  for (unsigned int lp1 = 0;lp1 < 17;lp1++){
    m_name[lp1] = m_info[lp1+1];
  }
// Add .MZT for DOS filenames
  addmzt(m_name);
  m_info[16] = 0x0d;
// Delete the file if it exists.
  if (SD.exists(m_name) == true){
    SD.remove(m_name);
  }
//Open F
  File file = SD.open( m_name, FILE_WRITE );
  if ( true == file ) {
//Sending status code (OK)
    snd1byte(0x00);
// Information block write
    for (unsigned int lp1 = 0;lp1 < 128;lp1++){
      file.write(m_info[lp1]);
    }
    file.close();
  else {
//Send status code (ERROR)
    snd1byte(0xF1);
    sdinit();
  }
}

//92h 0475H MONITOR Write Data Replacement Processing
void mon_wdata(void){
//Get file size
  int f_length1 = rcv1byte();
  int f_length2 = rcv1byte();
// File size calculation
  unsigned int f_length = f_length1+f_length2*256;
//Open F
  File file = SD.open( m_name, FILE_WRITE );
  if ( true == file ) {
//Sending status code (OK)
    snd1byte(0x00);
// Actual data
    long lp1 = 0;
    while (lp1 <= f_length-1){
      int i=0;
      while(i<=255 && lp1<=f_length-1){
        s_data[i] = rcv1byte();
        i++;
        lp1++;
      }
      file.write(s_data,i);
    }
    file.close();
  else {
//Send status code (ERROR)
    snd1byte(0xF1);
  }
}

//04D8H MONITOR Read Information Alternative Processing
void mon_lhead(void){
// Clear Read Data Points
  m_lop=128;
//Get filename
  for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
    m_name[lp1] = rcv1byte();
  }
  addmzt(m_name);
//Error if the file does not exist
  if (SD.exists(m_name) == true){
    snd1byte(0x00);
//Open F
    File file = SD.open( m_name, FILE_READ );
    if ( true == file ) {
      snd1byte(0x00);
      for (unsigned int lp1 = 0;lp1 < 128;lp1++){
          byte i_data = file.read();
          snd1byte(i_data);
      }
      file.close();
      snd1byte(0x00);
    else {
//Send status code (ERROR)
      snd1byte(0xFF);
      sdinit();
    }  
  else {
//Send status code (FILE NOT FIND ERROR)
    snd1byte(0xF1);
    sdinit();
  }
}

//04F8H MONITOR Read Data Replacement Processing
void mon_ldata(void){
// 2025.12.4 Removed addmzt as it was an unnecessary process.
// addmzt(m_name);
//Error if the file does not exist
  if (SD.exists(m_name) == true){
    snd1byte(0x00);
//Open F
    File file = SD.open( m_name, FILE_READ );
    if ( true == file ) {
      snd1byte(0x00);
      file.seek(m_lop);
// Get read size
      int f_length2 = rcv1byte();
      int f_length1 = rcv1byte();
      unsigned int f_length = f_length1*256+f_length2;
      for (unsigned int lp1 = 0;lp1 < f_length;lp1++){
        byte i_data = file.read();
        snd1byte(i_data);
      }
      file.close();
      m_lop = m_lop + f_length;
      snd1byte(0x00);
    else {
//Send status code (ERROR)
      snd1byte(0xFF);
    }  
  else {
//Send status code (FILE NOT FIND ERROR)
    snd1byte(0xF1);
  }
}

//BOOT process (for MZ-2000_SD only)
void boot(void){
//Get filename
  for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
    m_name[lp1] = rcv1byte();
  }
//// Serial.print("m_name:");
//// Serial.println(m_name);
//Error if the file does not exist
  if (SD.exists(m_name) == true){
    snd1byte(0x00);
//Open F
    File file = SD.open( m_name, FILE_READ );
    if ( true == file ) {
    snd1byte(0x00);
// Sending file size
      unsigned long f_length = file.size();
      unsigned int f_len1 = f_length / 256;
      unsigned int f_len2 = f_length % 256;
      snd1byte(f_len2);
      snd1byte(f_len1);
//// Serial.println(f_length,HEX);
//// Serial.println(f_len2,HEX);
//// Serial.println(f_len1,HEX);

// Sending actual data
      for (unsigned long lp1 = 1;lp1 <= f_length;lp1++){
         byte i_data = file.read();
         snd1byte(i_data);
      }

    else {
//Send status code (ERROR)
      snd1byte(0xFF);
    }  
  else {
//Send status code (FILE NOT FIND ERROR)
    snd1byte(0xF1);
  }
}

void loop()
{
  digitalWrite(PB0PIN,LOW);
  digitalWrite(PB1PIN,LOW);
  digitalWrite(PB2PIN,LOW);
  digitalWrite(PB3PIN,LOW);
  digitalWrite(PB4PIN,LOW);
  digitalWrite(PB5PIN,LOW);
  digitalWrite(PB6PIN,LOW);
  digitalWrite(PB7PIN,LOW);
  digitalWrite(FLGPIN,LOW);
// Waiting for command acquisition
//// Serial.print("cmd:");
  byte cmd = rcv1byte();
//// Serial.println(cmd,HEX);
  if (eflg == false){
    switch(cmd) {
// Save to SD card after 80 hours
      do 0x80:
//// Serial.println("SAVE START");
//Sending status code (OK)
        snd1byte(0x00);
        fBBave();
        break;
//Load from SD card in 81 hours
      case 0x81:
//// Serial.println("LOAD START");
//Sending status code (OK)
        snd1byte(0x00);
        f_load();
        break;
// Rename and copy the specified file as 0000.mzt in 82 hours.
      case 0x82:
//// Serial.println("ASTART START");
//Sending status code (OK)
        snd1byte(0x00);
        astart();
        break;
// Output file list in 83 hours
      case 0x83:
//// Serial.println("FILE LIST START");
//Sending status code (OK)
        snd1byte(0x00);
        sdinit();
        dirlist();
        break;
// Delete file after 84 hours
      case 0x84:
//// Serial.println("FILE Delete START");
//Sending status code (OK)
        snd1byte(0x00);
        f_del();
        break;
// Rename files after 85 hours
      case 0x85:
//// Serial.println("FILE Rename START");
//Sending status code (OK)
        snd1byte(0x00);
        febren();
        break;
      case 0x86:  
// File dump at 86h
//// Serial.println("FILE Dump START");
//Sending status code (OK)
        snd1byte(0x00);
        f_dump();
        break;
      case 0x87:  
// File copy in 87 hours
//// Serial.println("FILE Copy START");
//Sending status code (OK)
        snd1byte(0x00);
        f_copy();
        break;
      case 0x91:
//91h for 0436H MONITOR Light Information Alternative Processing
//// Serial.println("0436H START");
//Sending status code (OK)
        snd1byte(0x00);
        mon_whead();
        break;
//92h 0475H MONITOR Write Data Replacement Processing
      case 0x92:
//// Serial.println("0475H START");
//Sending status code (OK)
        snd1byte(0x00);
        mon_wdata();
        break;
//93h 04D8H MONITOR Read Information Alternative Processing
      case 0x93:
//// Serial.println("04D8H START");
//Sending status code (OK)
        snd1byte(0x00);
        mon_lhead();
        break;
//94h 04F8H MONITOR read data substitution process
      case 0x94:
//// Serial.println("04F8H START");
//Sending status code (OK)
        snd1byte(0x00);
        mon_ldata();
        break;
//Boot load in 95 hours (for MZ-2000_SD only)
      case 0x95:
//// Serial.println("BOOT LOAD START");
//Sending status code (OK)
        snd1byte(0x00);
        boot();
        break;
      default:
//Send status code (CMD ERROR)
        snd1byte(0xF4);
    }
  else {
//Send status code (ERROR)
    snd1byte(0xF0);
    sdinit();
  }
}