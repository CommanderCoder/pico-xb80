; ============================================================================
; MZ80K Pico-XB80 FD ROM
; ============================================================================
; Purpose: SD card file system for the Sharp MZ-80K, reached from the monitor
;          "FD" command. Implements the behaviour described in OPERATING.md.
; Location: 0xF000 (4KB ROM window, must stay below 0x0FF9 - see
;           SharpMZ_initialise() in sharp_mz.cpp; 0xFFFA-0xFFFF is the mailbox)
;
; Monitor command line:
;   *FD                      boot 0000.mzf
;   *FDF                     open the file menu
;   *FDS saddr eaddr xaddr name   save a memory block
;   *FDM saddr               dump memory, 128 bytes per screen
;   *FDW saddr hexbytes      write hex bytes into memory
;
; File menu keys (see OPERATING.md):
;   W/S move, , / . page, X or ENTER run, L load only, H help, F filter,
;   T type toggle, A autoboot copy, C copy, R rename, D delete, P print,
;   SHIFT+BREAK exit
;
; MAILBOX Interface:
;   Z80_TO_PICO_DATA    = 0xFFFA  (Z80 writes data here)
;   Z80_TO_PICO_FLAG    = 0xFFFB  (Z80 sets flag when data ready)
;   PICO_TO_Z80_DATA    = 0xFFFC  (Z80 reads data here)
;   PICO_TO_Z80_FLAG    = 0xFFFD  (PICO sets flag when data ready)
; ============================================================================

; Monitor ROM Entry Points
GETL        EQU 0003H       ; Get line from keyboard into LBUF
LETLN       EQU 0006H       ; Output newline
NEWLIN      EQU 0009H       ; Output newline conditionally
PRNTS       EQU 000CH       ; Print space
MON_VIDEO   EQU 0012H       ; Output single character
MON_MESSAGE EQU 0015H       ; Output message (0x0D terminated)
MON_STRING  EQU 0018H       ; Output string with wrapping
MON_GETKEY  EQU 001BH       ; Get single keystroke (no echo)
MON_BRKEY   EQU 001EH       ; BREAK key check routine (returns Z=1 if BREAK pressed)
TIMST       EQU 0033H       ; Timer start/read
MONITOR_80K EQU 0082H       ; Monitor command prompt
PRTWRD      EQU 03BAH       ; Print 16-bit word in hex (HL)
PRTBYT      EQU 03C3H       ; Print 8-bit byte in hex (A)
HLHEX       EQU 0410H       ; Parse 4 ASCII hex digits at (DE) into HL, CY on error
TWOHEX      EQU 041FH       ; Parse 2 ASCII hex digits at (DE) into A, CY on error
ADCN        EQU 0BB9H       ; ASCII -> display code
DISPCH      EQU 0DB5H       ; Display a character in display-code form

; Monitor RAM Locations
IBUFE       EQU 10F0H       ; File header buffer (128 bytes)
FNAME       EQU 10F1H       ; Filename in file header
FSIZE       EQU 1102H       ; File size in header (load path)
EADRS       EQU 1102H       ; End address in header (save path - same slot)
SADRS       EQU 1104H       ; Start address for file load
EXEAD       EQU 1106H       ; Execution address (where to jump after load)
CURSOR      EQU 1171H       ; Cursor position (col = low byte, row = high byte)
LBUF        EQU 11A3H       ; Line input buffer from keyboard
MBUF        EQU 11B0H       ; Monitor work buffer - used by the ENT3 load hook
                            ; because that runs while BASIC is resident and
                            ; high RAM may belong to the user's program

; MAILBOX Addresses (Memory-mapped I/O to PICO)
Z80_TO_PICO_DATA    EQU 0FFFAh  ; Write data byte to PICO
Z80_TO_PICO_FLAG    EQU 0FFFBh  ; Write 1 when data ready, PICO clears when read
PICO_TO_Z80_DATA    EQU 0FFFCh  ; Read data byte from PICO
PICO_TO_Z80_FLAG    EQU 0FFFDh  ; Read 1 when data ready, Z80 clears when read

; Menu RAM Storage (High RAM, doesn't conflict with user programs)
WORKING_STORE   EQU 0C800H  ; 33-byte buffer for the current entry from PICO
PAGE_BUFFER     EQU 0C830H  ; 16 names x NAME_FIELD bytes = 288 bytes
ATTR_BUFFER     EQU 0C950H  ; MZF type byte for each of the 16 cached rows
INDEX_BUFFER    EQU 0C960H  ; PICO file index for each of the 16 cached rows
NAMEBUF         EQU 0C970H  ; 34-byte buffer for a name typed by the user
PAGE_NUM        EQU 0CB20H  ; Current page number (0-based)
CURSOR_POS      EQU 0CB21H  ; Cursor row within current page (0-15)
CACHED_PAGE     EQU 0CB23H  ; Which page number is currently cached
CACHED_COUNT    EQU 0CB24H  ; How many files are on the cached page
FILTER_CHR      EQU 0CB25H  ; Letter filter, 0 = show every name
TYPE_MODE       EQU 0CB26H  ; 0 = all types, 1 = BASIC only, 2 = machine code only
FILE_ATTR       EQU 0CB27H  ; MZF type byte of the last entry fetched
RUN_FLAG        EQU 0CB28H  ; 1 = execute after loading, 0 = load only
DUMP_ADR        EQU 0CB29H  ; Working address for the P (print) display

; Constants
ROWS_PER_PAGE   EQU 16      ; Files displayed per page
NAME_FIELD      EQU 18      ; Bytes per cached name: 17 characters plus a CR.
                            ; Wide enough for a full IBF name, so the <n tag
                            ; the PICO adds to a shared name stays visible.
NAME_CHARS      EQU 17      ; Characters copied into a field
ROW_START       EQU 2       ; First screen row for file list
MSG_ROW         EQU 23      ; Screen row used for prompts and results
CLS_CHAR        EQU 16H     ; Character to clear screen and home cursor
ARROW           EQU 0C6H    ; Right arrow character for cursor marker

; Key codes returned by MON_GETKEY. The monitor reports these as device codes,
; not ASCII: CR is 66H and SHIFT+BREAK is 64H. Both collide with lower case
; letters once bit 5 is cleared, so they must be tested BEFORE any case
; folding - never mask with AND 5FH ahead of these checks.
KEY_BREAK       EQU 64H     ; SHIFT+BREAK
KEY_CR          EQU 66H     ; ENTER

; MZF header type byte (header offset 0)
ATTR_MCODE      EQU 01H     ; Machine code; 02H-05H are the BASIC variants

; SD Card Commands (values sent to PICO - see xb_interface/xb_if.h)
SD_SAVE         EQU 080H    ; Save by filename
SD_LOADNAME     EQU 081H    ; Load by filename
SD_ASTART       EQU 082H    ; Copy a file over 0000.mzf
SD_DEL          EQU 084H    ; Delete
SD_REN          EQU 085H    ; Rename
SD_DUMP         EQU 086H    ; Dump file contents
SD_COPY         EQU 087H    ; Copy
SD_FILECOUNT    EQU 0A0H    ; Query total file count
SD_DIRLIST      EQU 0A1H    ; Get type + name at index
SD_LOADIDX      EQU 0A2H    ; Load file at index

; ============================================================================
; ROM Start (0xF000) - TAPE LOADER BYPASS with File I/O Handlers
; ============================================================================
; Entry Point Layout - these addresses are baked into patched programs by
; tools/filehandle_patch.py, so nothing may be inserted before ENT5.
;   0xF000: NOP (padding)
;   0xF001: JP FDSTART (monitor command parser)
;   0xF004: JP ENT1 (PHEAD - Save header, uses 0x91)
;   0xF007: JP ENT2 (PDATA - Save data, uses 0x92)
;   0xF00A: JP ENT3 (LHEAD - Load header, uses 0x93)
;   0xF00D: JP ENT4 (LDATA - Load data, uses 0x94)
;   0xF010: JP ENT5 (CHECK - Verify, uses 0x95)
; ============================================================================
        ORG 0F000H

        NOP                     ; Padding (required by some ROM programmers)
        JP  FDSTART             ; Monitor "FD" command entry

ENT1:   JP  MSHED               ; PHEAD entry - Save header
ENT2:   JP  MSDAT               ; PDATA entry - Save data
ENT3:   JP  MLHED               ; LHEAD entry - Load header
ENT4:   JP  MLDAT               ; LDATA entry - Load data
ENT5:   JP  MVRFY               ; CHECK entry - Verify/Check

; ============================================================================
; MSHED - Write file header to SD card
; ============================================================================
; Inputs:  FNAME = filename, IBUFE = 128-byte header
; Protocol: Command 0x91 + 128-byte header + receive checksum
; ============================================================================
MSHED:
        DI                      ; Disable interrupts during I/O
        PUSH DE
        PUSH BC
        PUSH HL

        ; Check if filename is empty (leading CR)
        LD   A, (FNAME)
        CP   0DH
        JP   Z, MSHNONAME       ; No filename, error

        ; Send save header command (0x91)
        LD   A, 91H
        CALL MCMD
        AND  A
        JP   NZ, MERR

        ; Send 128-byte header from IBUFE
        LD   HL, IBUFE
        LD   B, 80H             ; 128 bytes
MSH3:
        LD   A, (HL)
        CALL SNDBYTE
        INC  HL
        DEC  B
        JR   NZ, MSH3

        ; Receive checksum
        CALL RCVBYTE
        AND  A
        JP   NZ, MERR

        JP   MRET

MSHNONAME:
        LD   DE, MSG_NONAME
        CALL MON_MESSAGE
        CALL LETLN
        POP  HL
        POP  BC
        POP  DE
        LD   A, 02H
        SCF
        RET

; ============================================================================
; MSDAT - Write file data to SD card
; ============================================================================
; Inputs:  SADRS = data address, FSIZE = byte count
; Protocol: Command 0x92 + 2-byte size + data bytes
; ============================================================================
MSDAT:
        DI
        PUSH DE
        PUSH BC
        PUSH HL

        ; Send save data command (0x92)
        LD   A, 92H
        CALL MCMD
        AND  A
        JP   NZ, MERR

        ; Send file size (2 bytes, little-endian)
        LD   HL, FSIZE
        LD   A, (HL)
        CALL SNDBYTE
        INC  HL
        LD   A, (HL)
        CALL SNDBYTE

        ; Receive acknowledge
        CALL RCVBYTE
        AND  A
        JP   NZ, MERR

        ; Send all file data bytes
        LD   DE, (FSIZE)
        LD   HL, (SADRS)
MSD1:
        LD   A, (HL)
        CALL SNDBYTE
        DEC  DE
        LD   A, D
        OR   E
        INC  HL
        JR   NZ, MSD1

        ; NOTE: PICO's mon_wdata() sends no further byte after the data
        ; phase (unlike mon_ldata's load path, it has no final status/
        ; checksum byte) - closes the file and returns. Do not wait for
        ; one here or this hangs forever after a successful save.
        JP   MRET

; ============================================================================
; MLHED - Read file header from SD card
; ============================================================================
; Inputs:  BASIC workspace at 458EH/458FH (filename and flag)
; Protocol: Command 0x93 + filename + receive 128-byte header + checksum
; ============================================================================
MLHED:
        DI
        PUSH DE
        PUSH BC
        PUSH HL

        ; Clear LBUF
        LD   B, 08H
        LD   DE, LBUF
        LD   A, 0DH
MLH0:
        LD   (DE), A
        INC  DE
        DEC  B
        JR   NZ, MLH0

        ; Check if BASIC provided a filename
        LD   A, (458EH)
        AND  A
        JP   Z, MLHNONAME

        ; Copy filename from BASIC workspace into the monitor work buffer
        LD   HL, (458FH)
        LD   DE, MBUF+9
        LD   B, 10H
MLH7:
        LD   A, (HL)
        CP   22H                ; Closing quote?
        JR   Z, MLH7E
        CP   0DH
        JR   Z, MLH7E
        CP   20H
        JR   C, MLH7E            ; Control char ends
        LD   (DE), A
        INC  HL
        INC  DE
        DJNZ MLH7
MLH7E:
        LD   A, 0DH
        LD   (DE), A

        ; Display filename being loaded
        LD   DE, MBUF+9
        CALL MON_MESSAGE
        CALL LETLN

        ; Send load header command (0x93)
        LD   A, 93H
        CALL MCMD
        AND  A
        JP   NZ, MERR

        ; Send the filename as 33 bytes (name, CR, then NUL padding)
        LD   HL, MBUF+9
        CALL SNDNAME

        ; Receive status
        CALL RCVBYTE
        AND  A
        JP   NZ, MERR

        ; Receive another status
        CALL RCVBYTE
        AND  A
        JP   NZ, MERR

        ; Receive 128-byte header into IBUFE
        LD   HL, IBUFE
        LD   B, 80H
MLH5:
        CALL RCVBYTE
        LD   (HL), A
        INC  HL
        DEC  B
        JR   NZ, MLH5

        ; Receive checksum
        CALL RCVBYTE
        AND  A
        JP   NZ, MERR

        JP   MRET

MLHNONAME:
        LD   DE, MSG_NONAME
        CALL MON_MESSAGE
        CALL LETLN
        POP  HL
        POP  BC
        POP  DE
        LD   A, 02H
        SCF
        RET

; ============================================================================
; MLDAT - Read file data from SD card
; ============================================================================
; Inputs:  SADRS = destination address, FSIZE = byte count
; Protocol: Command 0x94 + 2-byte size + receive data bytes + checksum
; ============================================================================
MLDAT:
        DI
        PUSH DE
        PUSH BC
        PUSH HL

        ; Send load data command (0x94)
        LD   A, 94H
        CALL MCMD
        AND  A
        JP   NZ, MERR

        ; Receive status
        CALL RCVBYTE
        AND  A
        JP   NZ, MERR

        ; Receive another status
        CALL RCVBYTE
        AND  A
        JP   NZ, MERR

        ; Send file size (2 bytes)
        LD   DE, FSIZE
        LD   A, (DE)
        CALL SNDBYTE
        INC  DE
        LD   A, (DE)
        CALL SNDBYTE

        ; Receive all file data bytes (uses DBRCV)
        CALL DBRCV

        ; Receive checksum
        CALL RCVBYTE
        AND  A
        JP   NZ, MERR

        JP   MRET

; ============================================================================
; MVRFY - Verify file (stub implementation)
; ============================================================================
MVRFY:
        XOR  A                  ; Clear A (return success)
        RET

; ============================================================================
; DBRCV - Receive FSIZE bytes from PICO into memory at SADRS
; ============================================================================
DBRCV:
        LD   DE, (FSIZE)        ; Load byte count
        LD   HL, (SADRS)        ; Load destination address
DBRLOP:
        CALL RCVBYTE            ; Get next byte
        LD   (HL), A            ; Store at destination
        DEC  DE                 ; Decrement count
        LD   A, D
        OR   E
        INC  HL                 ; Advance destination
        JR   NZ, DBRLOP         ; Loop until all bytes received
        RET

; ============================================================================
; DBSEND - Send memory from SADRS to EADRS (inclusive) to PICO
; ============================================================================
DBSEND:
        LD   HL, (EADRS)
        EX   DE, HL             ; DE = last address to send
        LD   HL, (SADRS)
DBSLOP:
        LD   A, (HL)
        CALL SNDBYTE
        LD   A, H
        CP   D
        JR   NZ, DBSLP1
        LD   A, L
        CP   E
        RET  Z                  ; Sent the final byte
DBSLP1:
        INC  HL
        JR   DBSLOP

; ============================================================================
; MCMD - Send command byte in A, return PICO's status byte in A
; ============================================================================
MCMD:
        CALL SNDBYTE            ; Send command
        CALL RCVBYTE            ; Receive status
        RET

; ============================================================================
; MRET - Return from file operation handler
; ============================================================================
MRET:
        POP  HL
        POP  BC
        POP  DE
        XOR  A
        RET

; ============================================================================
; MERR - Error handler for the ENT1-ENT5 monitor hooks
; ============================================================================
MERR:
        CALL SHOW_ERR
        POP  HL
        POP  BC
        POP  DE
        LD   A, 02H
        SCF
        RET

; ============================================================================
; SHOW_ERR - Print the message matching the PICO status byte in A
; ============================================================================
; Inputs:  A = status byte (0F0H, 0F1H, 0F3H, 0F4H or other)
; ============================================================================
SHOW_ERR:
        CP   0F0H
        JR   NZ, SERR1
        LD   DE, MSG_F0
        JR   SERRMSG
SERR1:
        CP   0F1H
        JR   NZ, SERR3
        LD   DE, MSG_F1
        JR   SERRMSG
SERR3:
        CP   0F3H
        JR   NZ, SERR4
        LD   DE, MSG_F3
        JR   SERRMSG
SERR4:
        CP   0F4H
        JR   NZ, SERR99
        LD   DE, MSG_CMD
        JR   SERRMSG
SERR99:
        CALL PRTBYT
        LD   DE, MSG99
SERRMSG:
        CALL MON_MESSAGE
        CALL LETLN
        RET

; ============================================================================
; FDSTART - Monitor command line parser
; ============================================================================
; The monitor jumps here for the "FD" command with the typed line still in
; LBUF, prompt character included. Work out which sub-command was given.
; ============================================================================
FDSTART:
        CALL COMMS_INIT         ; Clear mailbox flags

        LD   DE, LBUF
        LD   A, (DE)
        CP   '*'                ; Prompt character is usually present
        JR   NZ, FDS1
        INC  DE
FDS1:
        LD   A, (DE)
        CP   'F'
        JP   NZ, MENU_START     ; Unparseable - fall back to the menu
        INC  DE
        LD   A, (DE)
        CP   'D'
        JP   NZ, MENU_START
        INC  DE                 ; DE -> character after "FD"

        LD   A, (DE)
        CP   0DH                ; Bare *FD
        JR   Z, FDBOOT
        CP   20H                ; *FD followed by spaces
        JR   Z, FDBOOT
        CP   '/'
        JR   Z, FDBOOT

        CP   'F'                ; *FDF - file menu
        JP   Z, MENU_START
        CP   'S'                ; *FDS - save a memory block
        JP   Z, FDSAVE
        CP   'M'                ; *FDM - dump memory
        JP   Z, FDMEM
        CP   'W'                ; *FDW - write memory
        JP   Z, FDWRITE

        LD   DE, MSG_CMD
        CALL MON_MESSAGE
        CALL LETLN
        JP   MONITOR_80K

; ============================================================================
; FDBOOT - *FD loads and runs 0000.mzf
; ============================================================================
FDBOOT:
        LD   A, SD_LOADNAME
        CALL MCMD               ; Send command, receive dispatch ack
        AND  A
        JP   NZ, FDERR
        LD   HL, DEFNAME
        CALL SNDNAME            ; Send "0000" as 33 bytes
        CALL RCVBYTE            ; File opened?
        AND  A
        JP   NZ, FDERR
        CALL HDRCV              ; Header: name, SADRS, FSIZE, EXEAD
        CALL DBRCV              ; File body
        LD   HL, (EXEAD)
        JP   (HL)               ; Run it

; Report a PICO status byte and drop back to the monitor prompt
FDERR:
        CALL SHOW_ERR
        JP   MONITOR_80K

; ============================================================================
; FDSAVE - *FDS saddr eaddr xaddr filename
; ============================================================================
; Sends command 0x80 then, in order: the 33-byte SD filename, the 17-byte
; IBF name, SADRS, EADRS and EXEAD, then the memory block itself.
; ============================================================================
FDSAVE:
        INC  DE                 ; Skip 'S'
        INC  DE                 ; Skip the separating space

        PUSH DE                 ; Save address - start address
        CALL HLHEX
        JP   C, FDADERR
        LD   (SADRS), HL
        POP  DE
        INC  DE
        INC  DE
        INC  DE
        INC  DE
        INC  DE                 ; Past 4 hex digits + separator

        PUSH DE                 ; Save address - end address
        CALL HLHEX
        JP   C, FDADERR
        ; End address must be above the start address
        PUSH HL
        LD   BC, (SADRS)
        AND  A                  ; Clear carry before SBC
        SBC  HL, BC
        POP  HL
        JP   Z, FDADERR
        JP   C, FDADERR
        LD   (EADRS), HL
        POP  DE
        INC  DE
        INC  DE
        INC  DE
        INC  DE
        INC  DE

        PUSH DE                 ; Execution address
        CALL HLHEX
        JP   C, FDADERR
        LD   (EXEAD), HL
        POP  DE
        INC  DE
        INC  DE
        INC  DE
        INC  DE
        INC  DE                 ; DE -> filename

        LD   A, (DE)
        CP   31H                ; Must look like a real filename
        JP   C, FDNMERR
        EX   DE, HL             ; HL -> filename in LBUF

        ; ---- send it ----
        PUSH HL
        LD   A, SD_SAVE
        CALL MCMD
        AND  A
        POP  HL
        JP   NZ, FDERR

        PUSH HL
        CALL SNDNAME            ; 33 bytes: the SD card filename
        POP  HL
        CALL SNDIBF             ; 17 bytes: the IBF name inside the header

        LD   HL, SADRS          ; Start address
        CALL SND16
        LD   HL, EADRS          ; End address
        CALL SND16
        LD   HL, EXEAD          ; Execution address
        CALL SND16

        CALL RCVBYTE            ; File opened for writing?
        AND  A
        JP   NZ, FDERR

        CALL DBSEND             ; The memory block
        LD   DE, MSG_SVOK
        CALL MON_MESSAGE
        CALL LETLN
        JP   MONITOR_80K

FDADERR:
        POP  DE                 ; Discard the saved parse position
        LD   DE, MSG_AD
        CALL MON_MESSAGE
        CALL LETLN
        JP   MONITOR_80K

FDNMERR:
        LD   DE, MSG_FNAME
        CALL MON_MESSAGE
        CALL LETLN
        JP   MONITOR_80K

; Send the two bytes at (HL) - little endian 16-bit value
SND16:
        LD   A, (HL)
        CALL SNDBYTE
        INC  HL
        LD   A, (HL)
        CALL SNDBYTE
        RET

; ============================================================================
; FDMEM - *FDM saddr : display memory, 128 bytes per screen
; ============================================================================
; This is a purely local display - no PICO traffic at all.
; ============================================================================
FDMEM:
        INC  DE                 ; Skip 'M'
        INC  DE                 ; Skip space
        CALL HLHEX
        JP   C, FDADERR2
        LD   (DUMP_ADR), HL

FDM_SCREEN:
        LD   C, 10H             ; 16 rows of 8 bytes = 128 bytes
FDM_ROW:
        LD   HL, (DUMP_ADR)
        CALL PRTWRD             ; Address
        CALL PRNTS

        ; Hex column
        LD   HL, (DUMP_ADR)
        LD   B, 08H
FDM_HEX:
        LD   A, (HL)
        CALL PRTBYT
        CALL PRNTS
        CALL BRK_TEST           ; SHIFT+BREAK aborts mid-screen
        JR   Z, FDM_END
        INC  HL
        DJNZ FDM_HEX

        ; Character column
        LD   HL, (DUMP_ADR)
        LD   B, 08H
FDM_CHR:
        LD   A, (HL)
        CALL PUTCHR
        CALL BRK_TEST
        JR   Z, FDM_END
        INC  HL
        DJNZ FDM_CHR

        LD   (DUMP_ADR), HL     ; HL has advanced 8 bytes
        CALL LETLN
        DEC  C
        JR   NZ, FDM_ROW

        CALL PAGE_PROMPT        ; A = 0 next, 1 back, 2 break
        CP   02H
        JR   Z, FDM_END
        CP   01H
        JR   NZ, FDM_SCREEN
        ; Back one screen
        LD   HL, (DUMP_ADR)
        LD   DE, 0100H
        AND  A
        SBC  HL, DE
        LD   (DUMP_ADR), HL
        JR   FDM_SCREEN

FDM_END:
        JP   MONITOR_80K

FDADERR2:
        LD   DE, MSG_AD
        CALL MON_MESSAGE
        CALL LETLN
        JP   MONITOR_80K

; ============================================================================
; FDWRITE - *FDW saddr hexbytes
; ============================================================================
; Writes the hex byte pairs that follow the address into memory, then
; re-prompts with the next address so entry can continue. An empty line
; (ENTER straight after the address) stops.
; ============================================================================
FDWRITE:
        INC  DE                 ; Skip 'W'
        INC  DE                 ; Skip space
        CALL HLHEX
        JP   C, FDADERR2
        INC  DE
        INC  DE
        INC  DE
        INC  DE                 ; Past the 4 address digits

FDW_SKIP1:
        LD   A, (DE)
        CP   0DH
        JR   Z, FDW_END         ; Nothing left on the line - stop
        CP   20H
        JR   NZ, FDW_BYTE
        INC  DE
        JR   FDW_SKIP1

FDW_BYTE:
        CALL TWOHEX             ; Advances DE past the two digits
        JR   C, FDW_PROMPT      ; Not hex - keep what we have and re-prompt
        LD   (HL), A
        INC  HL

FDW_SKIP2:
        LD   A, (DE)
        CP   0DH
        JR   Z, FDW_PROMPT
        CP   20H
        JR   NZ, FDW_BYTE
        INC  DE
        JR   FDW_SKIP2

FDW_PROMPT:
        ; Print "*FDW nnnn " so the monitor's line editor picks the whole
        ; line up again when GETL re-reads it.
        LD   DE, MSG_FDW
        CALL MON_MESSAGE
        CALL PRTWRD
        CALL PRNTS
        LD   DE, LBUF
        CALL GETL
        ; GETL reports a BREAK out of line entry as 1BH in the first
        ; column - stop rather than re-parsing a line that isn't there.
        LD   A, (LBUF)
        CP   1BH
        JR   Z, FDW_END
        LD   DE, LBUF+3         ; -> 'W' of the echoed "*FDW "
        JP   FDWRITE

FDW_END:
        JP   MONITOR_80K

; ============================================================================
; PAGE_PROMPT - "NEXT:ANY BACK:B BREAK:SHIFT+BREAK" and read the answer
; ============================================================================
; Outputs: A = 0 next page, 1 previous page, 2 break
; ============================================================================
PAGE_PROMPT:
        LD   DE, MSG_PAGEK
        CALL MON_MESSAGE
        CALL LETLN
        CALL WAIT_KEY
        CP   KEY_BREAK
        JR   Z, PP_BRK
        CP   'B'
        JR   Z, PP_BACK
        XOR  A
        RET
PP_BACK:
        LD   A, 01H
        RET
PP_BRK:
        LD   A, 02H
        RET

; ============================================================================
; BRK_TEST - Z set if SHIFT+BREAK is being held
; ============================================================================
BRK_TEST:
        PUSH BC
        PUSH DE
        PUSH HL
        CALL MON_GETKEY
        CP   KEY_BREAK
        POP  HL
        POP  DE
        POP  BC
        RET

; ============================================================================
; PUTCHR - Show byte A as a character, blanking control codes
; ============================================================================
PUTCHR:
        CP   20H
        JR   NC, PUTC1
        LD   A, 20H             ; Control codes print as a space
PUTC1:
        CALL ADCN               ; ASCII -> display code
        CALL DISPCH
        RET

; ============================================================================
; MENU_START - Initialise and display the file menu (*FDF)
; ============================================================================
MENU_START:
        CALL COMMS_INIT         ; Safe to repeat - FDSTART may have run it

        XOR  A
        LD   (FILTER_CHR), A    ; No letter filter
        LD   (TYPE_MODE), A     ; Show every file type
        CALL RESET_VIEW

        CALL GET_FILE_COUNT     ; Returns: A = count of files
        OR   A
        JR   Z, NO_FILES

        CALL DRAW_SCREEN
        JR   MAIN_LOOP

NO_FILES:
        LD   DE, MSG_NOFIL
        CALL MON_MESSAGE
        CALL LETLN
        JP   MONITOR_80K

; ============================================================================
; RESET_VIEW - Back to page 0, top row, cache invalidated
; ============================================================================
RESET_VIEW:
        XOR  A
        LD   (PAGE_NUM), A
        LD   (CURSOR_POS), A
        LD   (CACHED_PAGE), A
        LD   A, 0FFH
        LD   (CACHED_COUNT), A  ; 0FFH marks the cache invalid
        RET

; ============================================================================
; MAIN_LOOP - Keyboard handler for the file menu
; ============================================================================
; SHIFT+BREAK (64H) and ENTER (66H) are device codes that alias onto letters
; once case-folded, so they are tested first and no masking is used at all.
; ============================================================================
MAIN_LOOP:
        CALL MON_GETKEY
        OR   A
        JR   Z, MAIN_LOOP       ; Wait for a key

        CP   KEY_BREAK
        JP   Z, KEY_EXIT
        CP   KEY_CR
        JP   Z, KEY_RUN
        CP   0DH                ; Some monitors report CR as 0DH
        JP   Z, KEY_RUN

        CP   'W'
        JP   Z, KEY_UP
        CP   'S'
        JP   Z, KEY_DOWN
        CP   ','
        JP   Z, KEY_PREV
        CP   '.'
        JP   Z, KEY_NEXT
        CP   'X'
        JP   Z, KEY_RUN
        CP   'L'
        JP   Z, KEY_LOADONLY
        CP   'H'
        JP   Z, KEY_HELP
        CP   'F'
        JP   Z, KEY_FILTER
        CP   'T'
        JP   Z, KEY_TYPE
        CP   'A'
        JP   Z, KEY_ASTART
        CP   'C'
        JP   Z, KEY_COPY
        CP   'R'
        JP   Z, KEY_RENAME
        CP   'D'
        JP   Z, KEY_DELETE
        CP   'P'
        JP   Z, KEY_PRINT

        JR   KEY_WAIT           ; Unknown key, ignore it

KEY_UP:
        CALL MOVE_UP
        JR   KEY_WAIT
KEY_DOWN:
        CALL MOVE_DOWN
        JR   KEY_WAIT
KEY_PREV:
        CALL PAGE_LEFT
        JR   KEY_WAIT
KEY_NEXT:
        CALL PAGE_RIGHT
        JR   KEY_WAIT
KEY_RUN:
        LD   A, 01H
        LD   (RUN_FLAG), A
        CALL LOAD_SELECTED      ; Only returns if the load failed
        JR   KEY_WAIT
KEY_LOADONLY:
        XOR  A
        LD   (RUN_FLAG), A
        CALL LOAD_SELECTED
        JR   KEY_WAIT
KEY_HELP:
        CALL SHOW_HELP
        JR   KEY_WAIT
KEY_FILTER:
        CALL SET_FILTER
        JR   KEY_WAIT
KEY_TYPE:
        CALL TOGGLE_TYPE
        JR   KEY_WAIT
KEY_ASTART:
        CALL DO_ASTART
        JR   KEY_WAIT
KEY_COPY:
        CALL DO_COPY
        JR   KEY_WAIT
KEY_RENAME:
        CALL DO_RENAME
        JR   KEY_WAIT
KEY_DELETE:
        CALL DO_DELETE
        JR   KEY_WAIT
KEY_PRINT:
        CALL DO_PRINT
        JR   KEY_WAIT

KEY_EXIT:
        CALL CLEAR_SCREEN
        JP   MONITOR_80K

; Debounce: wait for key release before returning to the poll loop
KEY_WAIT:
        CALL MON_GETKEY
        OR   A
        JR   NZ, KEY_WAIT
        JP   MAIN_LOOP

; ============================================================================
; WAIT_KEY / WAIT_RELEASE - keyboard helpers
; ============================================================================
WAIT_RELEASE:
        CALL MON_GETKEY
        OR   A
        JR   NZ, WAIT_RELEASE
        RET

WAIT_KEY:
        CALL WAIT_RELEASE       ; Ignore the key that got us here
WK1:
        CALL MON_GETKEY
        OR   A
        JR   Z, WK1
        RET

; ============================================================================
; SET_FILTER - 'F' then one letter limits the list to matching names
; ============================================================================
; ENTER or SHIFT+BREAK at the letter prompt clears the filter again.
; ============================================================================
SET_FILTER:
        LD   H, MSG_ROW
        LD   L, 0
        LD   (CURSOR), HL
        LD   DE, MSG_FILTER
        CALL MON_MESSAGE
        CALL WAIT_KEY
        CP   KEY_BREAK
        JR   Z, SF_CLEAR
        CP   KEY_CR
        JR   Z, SF_CLEAR
        CALL UPCASE
        LD   (FILTER_CHR), A
        JR   SF_DONE
SF_CLEAR:
        XOR  A
        LD   (FILTER_CHR), A
SF_DONE:
        CALL RESET_VIEW
        CALL DRAW_SCREEN
        RET

; ============================================================================
; TOGGLE_TYPE - 'T' cycles ALL -> BASIC -> M-CODE -> ALL
; ============================================================================
TOGGLE_TYPE:
        LD   A, (TYPE_MODE)
        INC  A
        CP   03H
        JR   C, TT1
        XOR  A
TT1:
        LD   (TYPE_MODE), A
        CALL RESET_VIEW
        CALL DRAW_SCREEN
        RET

; ============================================================================
; UPCASE - Fold a lower case letter in A to upper case
; ============================================================================
UPCASE:
        CP   'a'
        RET  C
        CP   'z'+1
        RET  NC
        SUB  20H
        RET

; ============================================================================
; GET_FILE_AT_INDEX - Fetch one directory entry from PICO
; ============================================================================
; Inputs:  A = file index (0-based)
; Outputs: FILE_ATTR = MZF type byte, WORKING_STORE = CR-terminated name
; Preserves BC, DE and HL so the paging loop can keep its counters.
; Protocol: 0xA1, ack, index, status, type byte, name bytes, NUL
; ============================================================================
GET_FILE_AT_INDEX:
        PUSH BC
        PUSH DE
        PUSH HL
        LD   E, A               ; E = index to fetch

        LD   A, SD_DIRLIST
        CALL MCMD               ; Send command, receive dispatch ack
        AND  A
        JR   NZ, GFI_ERR
        LD   A, E
        CALL MCMD               ; Send index, receive per-index status
        AND  A
        JR   NZ, GFI_ERR

        CALL RCVBYTE            ; MZF type byte
        LD   (FILE_ATTR), A

        LD   HL, WORKING_STORE
        LD   B, 32              ; Max name bytes
GFI_RX:
        CALL RCVBYTE
        OR   A                  ; NUL terminator?
        JR   Z, GFI_TERM
        LD   (HL), A
        INC  HL
        DJNZ GFI_RX
GFI_TERM:
        LD   (HL), 0DH          ; CR-terminate for MON_STRING
        POP  HL
        POP  DE
        POP  BC
        RET

GFI_ERR:
        ; Leave a blank entry so the caller shows an empty row rather than
        ; whatever the previous fetch left behind.
        XOR  A
        LD   (FILE_ATTR), A
        LD   HL, WORKING_STORE
        LD   (HL), 0DH
        POP  HL
        POP  DE
        POP  BC
        RET

; ============================================================================
; GET_FILE_COUNT - Query total file count from PICO
; ============================================================================
; Outputs: A = total files on the SD card
; ============================================================================
GET_FILE_COUNT:
        PUSH BC
        PUSH DE
        PUSH HL
        LD   A, SD_FILECOUNT
        CALL MCMD               ; Send command, receive dispatch ack
        CALL RCVBYTE            ; Receive the count
        POP  HL
        POP  DE
        POP  BC
        RET

; ============================================================================
; ENTRY_MATCH - Does the fetched entry pass the current filters?
; ============================================================================
; Inputs:  WORKING_STORE = name, FILE_ATTR = MZF type byte
; Outputs: Z set if the entry should be listed
; ============================================================================
ENTRY_MATCH:
        PUSH BC
        ; ---- file type filter ----
        LD   A, (TYPE_MODE)
        OR   A
        JR   Z, EM_NAME         ; 0 = show every type
        LD   B, A               ; B = 1 (BASIC) or 2 (machine code)
        LD   A, (FILE_ATTR)
        OR   A
        JR   Z, EM_NAME         ; Type unreadable - always show
        CP   ATTR_MCODE
        JR   Z, EM_MC
        LD   A, 01H             ; Anything that is not 01H counts as BASIC
        JR   EM_CMP
EM_MC:
        LD   A, 02H
EM_CMP:
        CP   B
        JR   NZ, EM_NO

EM_NAME:
        ; ---- first letter filter ----
        LD   A, (FILTER_CHR)
        OR   A
        JR   Z, EM_YES          ; No letter filter set
        LD   B, A
        LD   A, (WORKING_STORE)
        CALL UPCASE
        CP   B
        JR   NZ, EM_NO
EM_YES:
        POP  BC
        XOR  A                  ; Z set - show it
        RET
EM_NO:
        POP  BC
        LD   A, 01H
        OR   A                  ; Z clear - hide it
        RET

; ============================================================================
; STORE_ENTRY - Copy the fetched entry into cache slot A
; ============================================================================
; Inputs:  A = slot (0-15), B = PICO file index, WORKING_STORE / FILE_ATTR
; Outputs: PAGE_BUFFER, ATTR_BUFFER and INDEX_BUFFER updated
; Preserves BC, DE, HL.
; ============================================================================
STORE_ENTRY:
        PUSH BC
        PUSH DE
        PUSH HL

        LD   L, A
        LD   H, 0
        PUSH HL                 ; Keep the slot number

        LD   DE, ATTR_BUFFER
        ADD  HL, DE
        LD   A, (FILE_ATTR)
        LD   (HL), A

        POP  HL
        PUSH HL
        LD   DE, INDEX_BUFFER
        ADD  HL, DE
        LD   A, B               ; PICO index - read before B is reused
        LD   (HL), A

        POP  HL
        ADD  HL, HL             ; slot * 2
        PUSH HL
        ADD  HL, HL
        ADD  HL, HL
        ADD  HL, HL             ; slot * 16
        POP  DE
        ADD  HL, DE             ; slot * 18 = slot * NAME_FIELD
        LD   DE, PAGE_BUFFER
        ADD  HL, DE             ; HL -> destination field

        LD   DE, WORKING_STORE
        LD   B, NAME_CHARS      ; Last byte of the field is reserved for CR
SE1:
        LD   A, (DE)
        CP   0DH
        JR   Z, SE2
        LD   (HL), A
        INC  DE
        INC  HL
        DJNZ SE1
SE2:
        LD   (HL), 0DH          ; Terminate (truncating a long name)

        POP  HL
        POP  DE
        POP  BC
        RET

; ============================================================================
; GET_PAGE - Fill the cache with the entries belonging to page A
; ============================================================================
; Inputs:  A = page number (0-based)
; Outputs: A = CACHED_COUNT, page cache populated
; Counts only entries that pass ENTRY_MATCH, so a filtered list pages
; properly instead of showing short pages.
; ============================================================================
GET_PAGE:
        LD   E, A               ; E = requested page
        LD   A, (CACHED_COUNT)
        CP   0FFH               ; Cache invalidated?
        JR   Z, GP_LOAD
        LD   A, (CACHED_PAGE)
        CP   E
        JR   Z, GP_HIT

GP_LOAD:
        LD   A, E
        LD   (CACHED_PAGE), A   ; Remember what this cache holds
        ADD  A, A
        ADD  A, A
        ADD  A, A
        ADD  A, A               ; A = page * 16 matching entries to skip
        LD   D, A               ; D = skip counter
        XOR  A
        LD   (CACHED_COUNT), A

        CALL GET_FILE_COUNT
        LD   C, A               ; C = total files on the card
        LD   B, 0               ; B = PICO file index

GP_LOOP:
        LD   A, B
        CP   C
        JR   NC, GP_DONE        ; Ran out of files
        LD   A, B
        CALL GET_FILE_AT_INDEX
        CALL ENTRY_MATCH
        JR   NZ, GP_NEXT        ; Filtered out

        LD   A, D
        OR   A
        JR   Z, GP_TAKE
        DEC  D                  ; Still skipping earlier pages
        JR   GP_NEXT

GP_TAKE:
        LD   A, (CACHED_COUNT)
        CALL STORE_ENTRY
        LD   A, (CACHED_COUNT)
        INC  A
        LD   (CACHED_COUNT), A
        CP   ROWS_PER_PAGE
        JR   NC, GP_DONE        ; Page is full

GP_NEXT:
        INC  B
        JR   GP_LOOP

GP_DONE:
GP_HIT:
        LD   A, (CACHED_COUNT)
        RET

; ============================================================================
; NAVIGATION ROUTINES
; ============================================================================

MOVE_UP:
        LD   A, (CURSOR_POS)
        OR   A
        RET  Z                  ; Already at the top
        DEC  A
        CALL CLEAR_MARKER
        LD   (CURSOR_POS), A
        CALL DRAW_MARKER
        RET

MOVE_DOWN:
        LD   A, (CACHED_COUNT)
        OR   A
        RET  Z                  ; Empty page
        DEC  A                  ; Last valid row
        LD   C, A
        LD   A, (CURSOR_POS)
        CP   C
        RET  Z                  ; Already at the bottom
        RET  NC
        INC  A
        CALL CLEAR_MARKER
        LD   (CURSOR_POS), A
        CALL DRAW_MARKER
        RET

PAGE_LEFT:
        LD   A, (PAGE_NUM)
        OR   A
        RET  Z                  ; Already on the first page
        DEC  A
        LD   (PAGE_NUM), A
        XOR  A
        LD   (CURSOR_POS), A
        CALL DRAW_SCREEN
        RET

PAGE_RIGHT:
        LD   A, (PAGE_NUM)
        INC  A
        CALL GET_PAGE           ; Does the next page hold anything?
        OR   A
        JR   NZ, PR1
        ; Empty - restore the cache to the page still on screen
        LD   A, (PAGE_NUM)
        CALL GET_PAGE
        RET
PR1:
        LD   A, (PAGE_NUM)
        INC  A
        LD   (PAGE_NUM), A
        XOR  A
        LD   (CURSOR_POS), A
        CALL DRAW_SCREEN
        RET

; ============================================================================
; DISPLAY ROUTINES
; ============================================================================

DRAW_SCREEN:
        CALL CLEAR_SCREEN

        LD   A, (PAGE_NUM)
        CALL GET_PAGE           ; Load the current page into the cache

        ; Keep the marker on a row that actually holds a file - a filter
        ; change can leave the cursor past the end of a shorter page.
        LD   C, A               ; C = rows on this page
        LD   A, (CURSOR_POS)
        CP   C
        JR   C, DS_POSOK
        LD   A, C
        OR   A
        JR   Z, DS_POSZERO
        DEC  A
        JR   DS_POSSET
DS_POSZERO:
        XOR  A
DS_POSSET:
        LD   (CURSOR_POS), A
DS_POSOK:

        LD   HL, TITLE_MSG
        LD   D, 0
        LD   E, 7
        CALL PRINT_STR

        CALL DRAW_STATUS
        CALL DRAW_PAGE
        CALL DRAW_MARKER

        LD   HL, FOOTER_MSG
        LD   D, 24
        LD   E, 0
        CALL PRINT_STR
        RET

; ----------------------------------------------------------------------------
; DRAW_STATUS - row 1 shows which filters are active
; ----------------------------------------------------------------------------
DRAW_STATUS:
        LD   H, 1
        LD   L, 0
        LD   (CURSOR), HL
        LD   DE, MSG_TYPE
        CALL MON_MESSAGE
        LD   A, (TYPE_MODE)
        OR   A
        JR   NZ, DS1
        LD   DE, MSG_TALL
        JR   DS3
DS1:
        CP   01H
        JR   NZ, DS2
        LD   DE, MSG_TBAS
        JR   DS3
DS2:
        LD   DE, MSG_TMC
DS3:
        CALL MON_MESSAGE
        LD   DE, MSG_FIND
        CALL MON_MESSAGE
        LD   A, (FILTER_CHR)
        OR   A
        JR   NZ, DS4
        LD   DE, MSG_FNONE
        CALL MON_MESSAGE
        RET
DS4:
        CALL PUTCHR             ; The filter letter itself
        RET

DRAW_PAGE:
        LD   A, (CACHED_COUNT)
        OR   A
        RET  Z                  ; Nothing to draw

        LD   C, A               ; C = rows to draw
        LD   B, ROW_START       ; B = screen row
        LD   HL, PAGE_BUFFER

DRAW_ROW:
        LD   D, B
        LD   E, 1
        CALL PRINT_STR

        DEC  C
        RET  Z

        INC  B
        LD   DE, NAME_FIELD     ; Advance to the next name field
        ADD  HL, DE
        JR   DRAW_ROW

DRAW_MARKER:
        PUSH AF
        LD   H, ROW_START
        LD   A, (CURSOR_POS)
        ADD  A, H
        LD   H, A
        LD   L, 0
        LD   (CURSOR), HL
        LD   DE, MARKER_STR
        CALL MON_MESSAGE
        POP  AF
        RET

CLEAR_MARKER:
        PUSH AF
        LD   H, ROW_START
        LD   A, (CURSOR_POS)
        ADD  A, H
        LD   H, A
        LD   L, 0
        LD   (CURSOR), HL
        LD   DE, SPACE_STR
        CALL MON_MESSAGE
        POP  AF
        RET

CLEAR_SCREEN:
        LD   A, CLS_CHAR
        CALL MON_VIDEO
        RET

; ============================================================================
; PRINT_STR - Print the CR-terminated string at HL, at row D column E
; ============================================================================
PRINT_STR:
        PUSH DE
        PUSH HL
        LD   (CURSOR), DE       ; D = row, E = column
        LD   D, H
        LD   E, L               ; DE = string address for MON_STRING
        CALL MON_STRING
        POP  HL
        POP  DE
        RET

; ============================================================================
; MENU_MSG - Show DE on the message row, wait for a key, redraw
; ============================================================================
MENU_MSG:
        PUSH DE
        LD   H, MSG_ROW
        LD   L, 0
        LD   (CURSOR), HL
        POP  DE
        CALL MON_MESSAGE
        CALL WAIT_KEY
        CALL DRAW_SCREEN
        RET

; ============================================================================
; MENU_ERR - Report the PICO status byte in A, then redraw the menu
; ============================================================================
MENU_ERR:
        PUSH AF
        LD   H, MSG_ROW
        LD   L, 0
        LD   (CURSOR), HL
        POP  AF
        CALL SHOW_ERR
        CALL WAIT_KEY
        CALL DRAW_SCREEN
        RET

; ============================================================================
; SHOW_HELP - 'H' lists the menu keys
; ============================================================================
SHOW_HELP:
        CALL CLEAR_SCREEN
        LD   HL, HELP_TAB
        LD   B, HELP_LINES
        LD   D, 0               ; D = screen row
SH1:
        PUSH BC
        PUSH DE
        LD   E, 1               ; Column 1
        CALL PRINT_STR          ; Preserves DE and HL
        POP  DE
        POP  BC
        ; Step HL past this line's CR to reach the next one
SH2:
        LD   A, (HL)
        INC  HL
        CP   0DH
        JR   NZ, SH2
        INC  D
        DJNZ SH1
        CALL WAIT_KEY
        CALL DRAW_SCREEN
        RET

; ============================================================================
; GET_SELECTED - Fetch the highlighted entry's full name from PICO
; ============================================================================
; Outputs: WORKING_STORE = CR-terminated name, CY set if nothing is selected.
; The cached name is truncated to 15 characters for display, so the real
; name is re-fetched here before being sent back for a file operation.
; ============================================================================
GET_SELECTED:
        LD   A, (CACHED_COUNT)
        OR   A
        JR   Z, GS_NONE
        LD   A, (CURSOR_POS)
        LD   L, A
        LD   H, 0
        LD   DE, INDEX_BUFFER
        ADD  HL, DE
        LD   A, (HL)            ; PICO file index
        CALL GET_FILE_AT_INDEX
        AND  A                  ; Clear carry - selection is valid
        RET
GS_NONE:
        SCF
        RET

; ============================================================================
; ASK_NAME - Prompt with DE and read a filename into NAMEBUF
; ============================================================================
; Outputs: NAMEBUF = CR-terminated name, CY set if the user typed nothing.
; ============================================================================
ASK_NAME:
        PUSH DE
        CALL CLEAR_SCREEN
        POP  DE
        CALL MON_MESSAGE
        CALL LETLN
        LD   DE, LBUF
        CALL GETL

        LD   HL, LBUF
        LD   DE, NAMEBUF
        LD   B, 16
AN1:
        LD   A, (HL)
        CP   0DH
        JR   Z, AN2
        CP   20H
        JR   C, AN2             ; Any control character ends the name
        LD   (DE), A
        INC  HL
        INC  DE
        DJNZ AN1
AN2:
        LD   A, 0DH
        LD   (DE), A
        LD   A, (NAMEBUF)
        CP   0DH
        JR   Z, AN_EMPTY
        AND  A                  ; Clear carry - got a name
        RET
AN_EMPTY:
        SCF
        RET

; ============================================================================
; LOAD_SELECTED - Load the highlighted file (RUN_FLAG decides whether to run)
; ============================================================================
; Protocol: 0xA2, ack, index, status, then header and body.
; ============================================================================
LOAD_SELECTED:
        LD   A, (CACHED_COUNT)
        OR   A
        RET  Z                  ; Nothing to load

        LD   A, (CURSOR_POS)
        LD   L, A
        LD   H, 0
        LD   DE, INDEX_BUFFER
        ADD  HL, DE
        LD   B, (HL)            ; B = PICO file index

        LD   A, SD_LOADIDX
        CALL MCMD               ; Send command, receive dispatch ack
        AND  A
        JP   NZ, MENU_ERR
        LD   A, B
        CALL MCMD               ; Send index, receive per-index status
        AND  A
        JP   NZ, MENU_ERR

        CALL HDRCV              ; Header: name, SADRS, FSIZE, EXEAD
        CALL DBRCV              ; File body
        CALL CLEAR_SCREEN

        LD   A, (RUN_FLAG)
        OR   A
        JR   Z, LS_NORUN
        LD   HL, (EXEAD)
        JP   (HL)               ; Run it - never returns

LS_NORUN:
        ; 'L' loads without running, so report where it landed and hand
        ; back to the monitor rather than returning to a menu whose work
        ; area the loaded program may have just overwritten.
        LD   DE, MSG_LOADED
        CALL MON_MESSAGE
        LD   HL, (SADRS)
        CALL PRTWRD
        CALL LETLN
        JP   MONITOR_80K

; ============================================================================
; DO_ASTART - 'A' copies the highlighted file over 0000.mzf
; ============================================================================
; Protocol: 0x82, ack, 33-byte name, status.
; ============================================================================
DO_ASTART:
        CALL GET_SELECTED
        RET  C
        LD   A, SD_ASTART
        CALL MCMD
        AND  A
        JP   NZ, MENU_ERR
        LD   HL, WORKING_STORE
        CALL SNDNAME
        CALL RCVBYTE
        AND  A
        JP   NZ, MENU_ERR
        LD   DE, MSG_ASOK
        JP   MENU_MSG

; ============================================================================
; DO_DELETE - 'D' deletes the highlighted file after confirmation
; ============================================================================
; Protocol: 0x84, ack, 33-byte name, status, confirm byte (0 = go ahead),
;           result (0 = deleted, 1 = cancelled).
; ============================================================================
DO_DELETE:
        CALL GET_SELECTED
        RET  C
        LD   A, SD_DEL
        CALL MCMD
        AND  A
        JP   NZ, MENU_ERR
        LD   HL, WORKING_STORE
        CALL SNDNAME
        CALL RCVBYTE
        AND  A
        JP   NZ, MENU_ERR

        LD   H, MSG_ROW
        LD   L, 0
        LD   (CURSOR), HL
        LD   DE, MSG_DELQ
        CALL MON_MESSAGE
        CALL WAIT_KEY
        CALL UPCASE
        CP   'Y'
        JR   Z, DD_YES
        LD   A, 0FFH            ; Anything but Y cancels
        JR   DD_SEND
DD_YES:
        XOR  A
DD_SEND:
        CALL SNDBYTE
        CALL RCVBYTE
        AND  A
        JR   NZ, DD_NOTOK
        CALL RESET_VIEW         ; The listing changed - rebuild it
        LD   DE, MSG_DELOK
        JP   MENU_MSG
DD_NOTOK:
        CP   01H
        JP   NZ, MENU_ERR
        LD   DE, MSG_CANCEL
        JP   MENU_MSG

; ============================================================================
; DO_RENAME - 'R' renames the highlighted file
; ============================================================================
; Protocol: 0x85, ack, old name, status, new name, ack, result.
; ============================================================================
DO_RENAME:
        CALL GET_SELECTED
        RET  C
        ; Ask for the new name first: a cancelled prompt must not leave the
        ; PICO waiting part way through the exchange.
        LD   DE, MSG_NEWNAME
        CALL ASK_NAME
        JR   C, DR_ABORT

        LD   A, SD_REN
        CALL MCMD
        AND  A
        JP   NZ, MENU_ERR
        LD   HL, WORKING_STORE
        CALL SNDNAME            ; Existing name
        CALL RCVBYTE
        AND  A
        JP   NZ, MENU_ERR
        LD   HL, NAMEBUF
        CALL SNDNAME            ; New name
        CALL RCVBYTE            ; Acknowledge of the new name
        CALL RCVBYTE            ; Rename result
        AND  A
        JP   NZ, MENU_ERR
        CALL RESET_VIEW
        LD   DE, MSG_RENOK
        JP   MENU_MSG
DR_ABORT:
        CALL DRAW_SCREEN
        RET

; ============================================================================
; DO_COPY - 'C' copies the highlighted file to a new name
; ============================================================================
; Protocol: 0x87, ack, source name, status, new name, status (0xF1 if the
;           name is taken), copy result.
; ============================================================================
DO_COPY:
        CALL GET_SELECTED
        RET  C
        LD   DE, MSG_NEWNAME
        CALL ASK_NAME
        JR   C, DC_ABORT

        LD   A, SD_COPY
        CALL MCMD
        AND  A
        JP   NZ, MENU_ERR
        LD   HL, WORKING_STORE
        CALL SNDNAME            ; Source name
        CALL RCVBYTE
        AND  A
        JP   NZ, MENU_ERR
        LD   HL, NAMEBUF
        CALL SNDNAME            ; Destination name
        CALL RCVBYTE            ; 0xF1 here means the name already exists
        AND  A
        JP   NZ, MENU_ERR
        CALL RCVBYTE            ; Copy result
        AND  A
        JP   NZ, MENU_ERR
        CALL RESET_VIEW
        LD   DE, MSG_CPYOK
        JP   MENU_MSG
DC_ABORT:
        CALL DRAW_SCREEN
        RET

; ============================================================================
; DO_PRINT - 'P' dumps the highlighted file, 128 bytes per screen
; ============================================================================
; Protocol: 0x86, ack, 33-byte name, status, then repeating blocks of
;           {offset low, offset high, 128 data bytes, key byte}. An offset
;           of FFFF ends the dump and is followed by a final status byte.
;           Key byte: 0xFF break, 0x42 back one block, anything else next.
; ============================================================================
DO_PRINT:
        CALL GET_SELECTED
        RET  C
        LD   A, SD_DUMP
        CALL MCMD
        AND  A
        JP   NZ, MENU_ERR
        LD   HL, WORKING_STORE
        CALL SNDNAME
        CALL RCVBYTE
        AND  A
        JP   NZ, MENU_ERR

DP_SCREEN:
        CALL CLEAR_SCREEN
        CALL RCVBYTE
        LD   L, A
        CALL RCVBYTE
        LD   H, A
        ; FFFF marks the end of the file
        LD   A, H
        AND  L
        CP   0FFH
        JR   Z, DP_END
        LD   (DUMP_ADR), HL

        LD   C, 10H             ; 16 rows of 8 bytes
DP_ROW:
        LD   HL, (DUMP_ADR)
        CALL PRTWRD             ; Offset within the file
        CALL PRNTS

        ; Collect 8 bytes first - the mailbox must not stall mid-row
        LD   HL, LBUF
        LD   B, 08H
DP_RX:
        CALL RCVBYTE
        LD   (HL), A
        INC  HL
        DJNZ DP_RX

        LD   DE, LBUF
        LD   B, 08H
DP_HEX:
        LD   A, (DE)
        CALL PRTBYT
        CALL PRNTS
        INC  DE
        DJNZ DP_HEX

        CALL PRNTS
        LD   DE, LBUF
        LD   B, 08H
DP_CHR:
        LD   A, (DE)
        CALL PUTCHR
        INC  DE
        DJNZ DP_CHR

        CALL LETLN
        LD   HL, (DUMP_ADR)
        LD   DE, 0008H
        ADD  HL, DE
        LD   (DUMP_ADR), HL
        DEC  C
        JR   NZ, DP_ROW

        CALL PAGE_PROMPT        ; A = 0 next, 1 back, 2 break
        CP   02H
        JR   Z, DP_BRK
        CP   01H
        JR   Z, DP_BACK
        XOR  A                  ; Next block
        JR   DP_SEND
DP_BACK:
        LD   A, 42H             ; 'B' - PICO steps back 256 bytes
        JR   DP_SEND
DP_BRK:
        LD   A, 0FFH
DP_SEND:
        CALL SNDBYTE
        JR   DP_SCREEN

DP_END:
        CALL RCVBYTE            ; Trailing status byte
        CALL DRAW_SCREEN
        RET

; ============================================================================
; SD COMMUNICATION ROUTINES
; ============================================================================

; ============================================================================
; COMMS_INIT - Synchronise the mailbox: Z80 empties first, then waits
; ============================================================================
COMMS_INIT:
        LD   A, 0
        LD   (Z80_TO_PICO_FLAG), A
WAIT_EMPTY_PICO:
        LD   A, (PICO_TO_Z80_FLAG)
        OR   A
        JR   NZ, WAIT_EMPTY_PICO
        RET

; ============================================================================
; SNDBYTE - Send byte A to PICO via MAILBOX with handshake
; ============================================================================
SNDBYTE:
        PUSH BC
        LD   C, A               ; C = byte to send
SNDBYTE_WAIT:
        LD   A, (Z80_TO_PICO_FLAG)
        OR   A
        JR   NZ, SNDBYTE_WAIT   ; Wait for the mailbox to drain
        LD   A, C
        LD   (Z80_TO_PICO_DATA), A
        LD   A, 1
        LD   (Z80_TO_PICO_FLAG), A
        POP  BC
        RET

; ============================================================================
; RCVBYTE - Receive a byte from PICO via MAILBOX into A
; ============================================================================
RCVBYTE:
        PUSH BC
RCVBYTE_WAIT:
        LD   A, (PICO_TO_Z80_FLAG)
        OR   A
        JR   Z, RCVBYTE_WAIT    ; Wait for data to arrive
        LD   A, (PICO_TO_Z80_DATA)
        LD   C, A
        XOR  A
        LD   (PICO_TO_Z80_FLAG), A
        LD   A, C
        POP  BC
        RET

; ============================================================================
; SNDNAME - Send the CR-terminated name at HL as exactly 33 bytes
; ============================================================================
; The PICO's rcv_filename32() always reads 33 bytes. It then needs a CR for
; addmzf() and a NUL for addrootdir(), so the name is sent up to and
; including its CR and the rest of the field is padded with NULs.
; ============================================================================
SNDNAME:
        PUSH BC
        PUSH HL
        LD   B, 21H             ; 33 bytes
        LD   C, 0               ; 0 while still copying, 1 once the CR is sent
SNDN1:
        LD   A, C
        OR   A
        JR   NZ, SNDN3
        LD   A, (HL)
        INC  HL
        CP   0DH
        JR   NZ, SNDN4
        LD   C, 1               ; This is the CR - send it, then pad
        JR   SNDN4
SNDN3:
        XOR  A                  ; NUL padding
SNDN4:
        CALL SNDBYTE
        DJNZ SNDN1
        POP  HL
        POP  BC
        RET

; ============================================================================
; SNDIBF - Send the CR-terminated name at HL as a 17-byte IBF name field
; ============================================================================
; 16 characters then a CR, space padded, matching the MZF header layout.
; ============================================================================
SNDIBF:
        PUSH BC
        PUSH HL
        LD   B, 10H             ; 16 characters
        LD   C, 0
SNDI1:
        LD   A, C
        OR   A
        JR   NZ, SNDI3
        LD   A, (HL)
        INC  HL
        CP   0DH
        JR   NZ, SNDI4
        LD   C, 1
        JR   SNDI4
SNDI3:
        LD   A, 20H             ; Space padding after the CR
SNDI4:
        CALL SNDBYTE
        DJNZ SNDI1
        LD   A, 0DH             ; 17th byte is always the terminator
        CALL SNDBYTE
        POP  HL
        POP  BC
        RET

; ============================================================================
; HDRCV - Receive a file header from PICO
; ============================================================================
; Format: 17 name bytes, SADRS (2), FSIZE (2), EXEAD (2) - all little endian.
; ============================================================================
HDRCV:
        LD   HL, FNAME
        LD   B, 11H             ; 17 bytes of filename
HDRC1:
        CALL RCVBYTE
        LD   (HL), A
        INC  HL
        DJNZ HDRC1

        LD   HL, SADRS
        CALL RCVBYTE
        LD   (HL), A
        INC  HL
        CALL RCVBYTE
        LD   (HL), A

        LD   HL, FSIZE
        CALL RCVBYTE
        LD   (HL), A
        INC  HL
        CALL RCVBYTE
        LD   (HL), A

        LD   HL, EXEAD
        CALL RCVBYTE
        LD   (HL), A
        INC  HL
        CALL RCVBYTE
        LD   (HL), A
        RET

; ============================================================================
; STRINGS & MESSAGES
; ============================================================================

TITLE_MSG:
        DB 'MZ80K BROWSER', 0DH

FOOTER_MSG:
        DB 'H=HELP  X=RUN  ',05EH,'BREAK=EXIT', 0DH

; Help page - one CR-terminated line per entry, walked by SHOW_HELP
HELP_TAB:
        DB 'FILE MENU KEYS', 0DH
        DB ' ', 0DH
        DB 'W S    UP DOWN', 0DH
        DB ', .    PAGE BACK FORWARD', 0DH
        DB 'X CR   RUN FILE', 0DH
        DB 'L      LOAD ONLY', 0DH
        DB 'F      FILTER LETTER', 0DH
        DB 'T      TYPE TOGGLE', 0DH
        DB 'A      SET AUTOBOOT', 0DH
        DB 'C      COPY FILE', 0DH
        DB 'R      RENAME FILE', 0DH
        DB 'D      DELETE FILE', 0DH
        DB 'P      PRINT FILE', 0DH
        DB 'H      THIS HELP', 0DH
        DB 'SHIFT+BREAK  EXIT', 0DH
        DB ' ', 0DH
        DB 'PRESS ANY KEY', 0DH
HELP_LINES EQU 17

MSG_TYPE:
        DB 'TYPE:', 0DH
MSG_TALL:
        DB 'ALL    ', 0DH
MSG_TBAS:
        DB 'BASIC  ', 0DH
MSG_TMC:
        DB 'M-CODE ', 0DH
MSG_FIND:
        DB ' FIND:', 0DH
MSG_FNONE:
        DB '-', 0DH

MSG_NOFIL:
        DB 'NO FILES FOUND', 0DH
MSG_FILTER:
        DB 'FILTER LETTER? (ENTER=ALL) ', 0DH
MSG_NEWNAME:
        DB 'NEW NAME?', 0DH
MSG_DELQ:
        DB 'DELETE? Y/N ', 0DH
MSG_DELOK:
        DB 'DELETED', 0DH
MSG_CANCEL:
        DB 'CANCELLED', 0DH
MSG_RENOK:
        DB 'RENAMED', 0DH
MSG_CPYOK:
        DB 'COPIED', 0DH
MSG_ASOK:
        DB 'AUTOBOOT SET', 0DH
MSG_LOADED:
        DB 'LOADED AT ', 0DH
MSG_SVOK:
        DB 'SAVE FINISHED', 0DH
MSG_PAGEK:
        DB 'NEXT:ANY BACK:B BREAK:SHIFT+BREAK', 0DH
MSG_FDW:
        DB '*FDW ', 0DH

MSG_NONAME:
        DB 'NO FILENAME', 0DH
MSG_AD:
        DB 'ADDRESS FAILED!', 0DH
MSG_FNAME:
        DB 'FILENAME FAILED!', 0DH
MSG_CMD:
        DB 'COMMAND ERROR', 0DH
MSG_F0:
        DB 'SD-CARD ERROR', 0DH
MSG_F1:
        DB 'FILE NOT FOUND', 0DH
MSG_F3:
        DB 'FILE READ ERROR', 0DH
MSG99:
        DB ' ERROR', 0DH

DEFNAME:
        DB '0000', 0DH

MARKER_STR:
        DB ARROW, 0DH
SPACE_STR:
        DB ' ', 0DH

        END
