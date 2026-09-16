# PATCHING BASIC

Load and Save routines exist within the MONITOR rom.  Cannot patch the Monitor ROM (hardware) using software
so any program which loads or saves will need to be patched.  

This can be done by searching through the machine code looking for jumps to the load or save routines.

These routines are in the monitor ROM at these location, and have these hex codes to jump.
 ADDR MC     LABEL: pseudo-assembler
 0021 C33604 PHEAD: JP Phead Punch header.
 0024 C37504 PDATA: JP Pdata Punch data.
 0027 C3D804 LHEAD: JP Lhead Load header.
 002A C3F804 LDATA: JP Ldat a Load data.
 OO2D C38805 CHECK: JP Check Checks file.

0xC3 is the JP instruction, and PHEAD code is at location 0x0436 in the monitor rom, for example.

Normal Sharp assembler programs will jump to 0x0021 (for example) and this will jump to 0x0436 which performs the 'write' header. (Punch was used for Write back in the 1970's on this machine).

## Without changing the rom

The replacement jump functions are in the FD rom at these locations:

 F004 C3 E7 F7     ENT1: 	JP		MSHED ; PHEAD (punch header)
 F007 C3 32 F8     ENT2: 	JP		MSDAT ; PDATA (punch data)
 F00A C3 66 F8     ENT3: 	JP		MLHED ; LHEAD (load header)
 F00D C3 50 F9     ENT4: 	JP		MLDAT ; LDATA (load data)
 F010 C3 83 F9     ENT5: 	JP		MVRFY ; CHECK (Checks file)

Need to patch every program. The first of these is naturally BASIC.  To patch BASIC need to look for 

 CALL 0021H
 and replace with
 CALL F004H

 CALL 0027H
 and replace with
 CALL F00AH


 so simply search through the BASIC binary and replace
 0xcd, 0x21, 0x00 _with_ 0xcd, 0x04, 0xf0
 0xcd, 0x24, 0x00 _with_ 0xcd, 0x07, 0xf0
 0xcd, 0x27, 0x00 _with_ 0xcd, 0x0a, 0xf0
 0xcd, 0x2A, 0x00 _with_ 0xcd, 0x0d, 0xf0
 0xcd, 0x2D, 0x00 _with_ 0xcd, 0x10, 0xf0


# Monitor ROM patch for FD_rom1.s

If you feel patching the ROM would be best, thus works for ALL existing Sharp programs then 
you replace the code at these locations to jump to the routines in the FD rom.

　0437 : D5 → C3
　0438 : C5 → 04
　0439 : E5 → F0
== JP F004

　0476 : D5 → C3
　0477 : C5 → 07
　0478 : E5 → F0
== JP F007

　04D9 : D5 → C3
　04DA : C5 → 0A
　04DB : E5 → F0
== JP F00A

　04F9 : D5 → C3
　04FA : C5 → 0D
　04FB : E5 → F0
== JP F00D

　0589 : D5 → C3
　058A : C5 → 10
　058B : E5 → F0
== JP F010
