; ============================================================================
; MZ80K FileMenu ROM - Final Production Version (Simplified - No Extension Filter)
; ============================================================================
; Purpose: FreHD-style file browser for MZ80K with SD card via PICO MAILBOX
; Location: 0xF000 (4KB ROM)
; 
; NOTE: SD card interface handles all file filtering - this code assumes
;       only valid files are returned by the SD card interface
; 
; Features:
;   - Browse files from SD card
;   - Display filename only (compact)
;   - Navigation: W/S (up/down), A/D (page), Enter/R (load)
;   - Search/filter by filename
;   - BREAK to return to Monitor
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
PRTBYT      EQU 03C3H       ; Print 8-bit byte in hex

; Monitor RAM Locations
IBUFE       EQU 10F0H       ; File header buffer (128 bytes)
FNAME       EQU 10F1H       ; Filename in file header
FSIZE       EQU 1102H       ; File size in header
SADRS       EQU 1104H       ; Start address for file load
EXEAD       EQU 1106H       ; Execution address (where to jump after load)
CURSOR      EQU 1171H       ; Cursor position (Row=high byte, Col=low byte)
LBUF        EQU 11A3H       ; Line input buffer from keyboard
MBUF        EQU 11B0H       ; Monitor work buffer for file operations

; MAILBOX Addresses (Memory-mapped I/O to PICO)
Z80_TO_PICO_DATA    EQU 0FFFAh  ; Write data byte to PICO
Z80_TO_PICO_FLAG    EQU 0FFFBh  ; Write 1 when data ready, PICO clears when read
PICO_TO_Z80_DATA    EQU 0FFFCh  ; Read data byte from PICO
PICO_TO_Z80_FLAG    EQU 0FFFDh  ; Read 1 when data ready, Z80 clears when read

; Menu RAM Storage (High RAM, doesn't conflict with user programs)
WORKING_STORE   EQU 0C800H  ; 32-byte buffer for current file entry from PICO
PAGE_BUFFER     EQU 0C820H  ; Cache of 16 filenames (16 bytes each = 256 bytes)
PAGE_NUM        EQU 0CB20H  ; Current page number (0-based)
CURSOR_POS      EQU 0CB21H  ; Cursor row within current page (0-15)
FILE_COUNT      EQU 0CB22H  ; Total files on SD
CACHED_PAGE     EQU 0CB23H  ; Which page number is currently cached
CACHED_COUNT    EQU 0CB24H  ; How many files are on the cached page
SEARCH_ACTIVE   EQU 0CB25H  ; Flag: is search filter currently applied? (0=no, 1=yes)
SEARCH_BUF      EQU 0CB26H  ; Search filter string buffer (max 16 bytes + null)

; Constants
ROWS_PER_PAGE   EQU 16      ; Files displayed per page
ROW_START       EQU 2       ; First screen row for file list (row 0=title, row 1=header)
CLS_CHAR        EQU 16H     ; Character to clear screen and home cursor
ARROW           EQU 0C6H    ; Right arrow character for cursor marker

; SD Card Commands (values sent to PICO)
SD_FILECOUNT    EQU 0A0H    ; Query total file count
SD_DIRLIST      EQU 0A1H    ; Get directory entry (filename) at index
SD_LOAD         EQU 0A2H    ; Load file at index

; ============================================================================
; ROM Start (0xF000) - TAPE LOADER BYPASS with File I/O Handlers
; ============================================================================
; This ROM replaces the standard MZ80K tape loader/writer with SD card I/O
; The 5 entry points below handle actual file operations (SAVE/LOAD/VERIFY)
; sent from the monitor, bypassing the old tape routines completely.
; ============================================================================
        ORG 0F000H
        
        NOP                     ; Padding (required by some ROM programmers)
        JP  MENU_START          ; Jump to main file menu entry point

; ============================================================================
; ENTRY POINTS - File I/O Handlers (Tape Loader Bypass)
; ============================================================================
; These 5 entry points intercept file operations from the monitor and
; redirect them to SD card operations via PICO MAILBOX. Each uses a
; different command code (0x91-0x95) to tell PICO what operation to perform.
;
; Entry Point Layout (0xF000-0xF010):
;   0xF000: NOP (padding)
;   0xF001: JP MENU_START (main file browser)
;   0xF004: JP ENT1 (PHEAD - Save header, uses 0x91)
;   0xF007: JP ENT2 (PDATA - Save data, uses 0x92)
;   0xF00A: JP ENT3 (LHEAD - Load header, uses 0x93)
;   0xF00D: JP ENT4 (LDATA - Load data, uses 0x94)
;   0xF010: JP ENT5 (CHECK - Verify, uses 0x95)
; ============================================================================

; ============================================================================
; ENT1: MSHED - Save/Punch file header to SD card
; ============================================================================
; Purpose: Write file header to SD card (invoked by monitor SAVE command)
; Inputs:  FNAME = filename, IBUFE = 128-byte header buffer
; Outputs: Header sent to PICO via command 0x91
; Command protocol: Send 0x91, receive status, send 128 header bytes,
;                   receive checksum
; ============================================================================
ENT1:   JP  MSHED               ; PHEAD entry - Save header

; ============================================================================
; ENT2: MSDAT - Save/Punch file data to SD card
; ============================================================================
; Purpose: Write file data to SD card (invoked by monitor SAVE command)
; Inputs:  SADRS = data start address, FSIZE = number of bytes
; Outputs: File data sent to PICO via command 0x92
; Command protocol: Send 0x92, send FSIZE (2 bytes), send all data bytes,
;                   receive checksum
; ============================================================================
ENT2:   JP  MSDAT               ; PDATA entry - Save data

; ============================================================================
; ENT3: MLHED - Load file header from SD card
; ============================================================================
; Purpose: Load file header from SD card (invoked by monitor LOAD command)
; Inputs:  Prompts for filename via BASIC workspace (458EH/458FH)
; Outputs: 128-byte header received into IBUFE via command 0x93
; Command protocol: Send 0x93, send filename, receive 128 header bytes,
;                   receive checksum
; ============================================================================
ENT3:   JP  MLHED               ; LHEAD entry - Load header

; ============================================================================
; ENT4: MLDAT - Load file data from SD card
; ============================================================================
; Purpose: Load file data from SD card (invoked by monitor LOAD command)
; Inputs:  SADRS = destination address, FSIZE = number of bytes to read
; Outputs: File data received from PICO via command 0x94, stored at SADRS
; Command protocol: Send 0x94, send FSIZE (2 bytes), receive all data bytes,
;                   receive checksum
; ============================================================================
ENT4:   JP  MLDAT               ; LDATA entry - Load data

; ============================================================================
; ENT5: MVRFY - Verify file (stub)
; ============================================================================
; Purpose: Verify file operation (invoked by monitor VERIFY command)
; Inputs:  None
; Outputs: Currently stub - returns success
; Notes:   Full implementation would use command 0x95 if needed
; ============================================================================
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
; Protocol: Command 0x92 + 2-byte size + data bytes + receive checksum
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
        
        ; Copy filename from BASIC workspace to buffer
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
        
        ; Send filename (33 bytes: PICO's rcv_filename32 expects 32
        ; plus one extra byte; it only scans up to the CR we wrote
        ; above, so the extra byte's value doesn't matter)
        LD   DE, MBUF+9
        LD   B, 21H
MLH4:
        LD   A, (DE)
        CALL SNDBYTE
        INC  DE
        DEC  B
        JR   NZ, MLH4
        
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
; Currently minimal - just returns success
; Could be expanded to use command 0x95 if full verify is needed
; ============================================================================
MVRFY:
        XOR  A                  ; Clear A (return success)
        RET

; ============================================================================
; DBRCV - Receive multiple bytes into memory
; ============================================================================
; Receives FSIZE bytes from PICO and stores them at SADRS location
; Input:  FSIZE = number of bytes to receive
;         SADRS = destination address
; Output: Memory at SADRS filled with received bytes
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
; MCMD - Send command and receive response
; ============================================================================
; Sends command byte in A, receives response status
; Input:  A = command byte (0x91-0x95)
; Output: A = response status from PICO
; ============================================================================
MCMD:
        CALL SNDBYTE            ; Send command
        CALL RCVBYTE            ; Receive status
        RET

; ============================================================================
; MRET - Return from file operation handler
; ============================================================================
; Restores registers and returns to monitor
; ============================================================================
MRET:
        POP  HL
        POP  BC
        POP  DE
        XOR  A
        RET

; ============================================================================
; MERR - Error handler
; ============================================================================
; Displays error message and returns with error flag
; ============================================================================
MERR:
        CP   0F0H
        JR   NZ, MERR3
        LD   DE, MSG_F0
        JR   MERRMSG
        
MERR3:
        CP   0F1H
        JR   NZ, MERR99
        LD   DE, MSG_F1
        JR   MERRMSG
        
MERR99:
        CALL PRTBYT
        LD   DE, MSG99
        
MERRMSG:
        CALL MON_MESSAGE
        CALL LETLN
        POP  HL
        POP  BC
        POP  DE
        LD   A, 02H
        SCF
        RET

; ============================================================================
; MENU_START - Initialize menu system and display
; ============================================================================
; Purpose: Main entry point when *FD command is executed
; Inputs:  None
; Outputs: Displays menu or error message, enters main loop or returns to monitor
; Registers clobbered: All
; ============================================================================
MENU_START:
        ; Initialize mailbox communication
        CALL COMMS_INIT          ; Clear mailbox flags
        
        ; Initialize all state variables to known values
        XOR  A                  ; A = 0
        LD   (PAGE_NUM), A      ; Start at page 0
        LD   (CURSOR_POS), A    ; Cursor at top of page
        LD   (CACHED_PAGE), A   ; No page cached yet
        LD   (SEARCH_ACTIVE), A ; No search filter active
        DEC  A                  ; A = 0xFF (invalid cache marker)
        LD   (CACHED_COUNT), A  ; Invalidate page cache
        
        ; Query SD card for file count
        CALL GET_FILE_COUNT     ; Returns: A = count of files
        OR   A                  ; Test if A = 0 (no files found)
        JR   Z, NO_FILES        ; Jump if no files
        
        ; Files found, initialize display
        LD   (FILE_COUNT), A    ; Store file count
        CALL DRAW_SCREEN        ; Display title, header, first page of files
        JR   MAIN_LOOP          ; Enter keyboard input loop

NO_FILES:
        ; No files found on SD card
        LD   DE, MSG_NOFIL      ; Point to error message
        CALL MON_MESSAGE        ; Display message
        CALL LETLN              ; Output newline
        JP   0082H              ; Return to Monitor prompt

; ============================================================================
; MAIN_LOOP - Keyboard input handler
; ============================================================================
; Purpose: Poll keyboard, handle user input, dispatch to appropriate routine
; Inputs:  None (reads from keyboard)
; Outputs: Calls appropriate action routine or jumps to exit/monitor
; Registers clobbered: A
; Notes:   Tight loop polling MON_GETKEY, waits for key press then debounces
; ============================================================================
MAIN_LOOP:

        CALL MON_GETKEY         ; Get current key (0 if none pressed)
        OR   A                  ; Test if A = 0 (no key)
        JR   Z, MAIN_LOOP       ; Wait for key press
        CP      64H             ; check for BREAK key (0x64)
        JR      Z,KEY_EXIT     ; Z = 1 means BREAK pressed
        
        CP      66H             ; check for ENTER key (0x66)      
        JR      Z,KEY_LOAD


        ; Key was pressed, check what it was
        CP   'W'                ; Move cursor up
        JR   Z, KEY_UP
        
        CP   'S'                ; Move cursor down
        JR   Z, KEY_DOWN
        
        CP   'A'                ; Previous page
        JR   Z, KEY_PREV
        
        CP   'D'                ; Next page
        JR   Z, KEY_NEXT
        
        CP   'R'                ; 'R' key also loads file
        JR   Z, KEY_LOAD

        CP   0DH                ; Enter key (load file)
        JR   Z, KEY_LOAD
                
        CP   '/'                ; Search trigger
        JR   Z, KEY_SEARCH
        
        
        ; Unknown key, ignore it
        JR   KEY_WAIT

; Key action handlers
KEY_UP:
        CALL MOVE_UP            ; Move cursor up one row
        JR   KEY_WAIT

KEY_DOWN:
        CALL MOVE_DOWN          ; Move cursor down one row
        JR   KEY_WAIT

KEY_PREV:
        CALL PAGE_LEFT          ; Go to previous page
        JR   KEY_WAIT

KEY_NEXT:
        CALL PAGE_RIGHT         ; Go to next page
        JR   KEY_WAIT

KEY_LOAD:
        CALL LOAD_SELECTED      ; Load and run selected file
        JR   MAIN_LOOP          ; Return here only if load failed

KEY_SEARCH:
        CALL SEARCH_PROMPT      ; Get search string from user
        JR   MAIN_LOOP          ; Return and redraw menu

KEY_EXIT:
        CALL CLEAR_SCREEN       ; Clear screen before jumping to program

        JP   0082H              ; Jump directly to Monitor entry point

; Debounce: wait for key release before returning to main loop
KEY_WAIT:
        CALL MON_GETKEY         ; Poll key again
        OR   A                  ; Test if still pressed
        JR   NZ, KEY_WAIT       ; Loop while key is held
        JR   MAIN_LOOP          ; Key released, back to main loop

; ============================================================================
; SEARCH_PROMPT - Get search filter string from user
; ============================================================================
; Purpose: Display search prompt, get user input, apply filter to file list
; Inputs:  None
; Outputs: Sets SEARCH_ACTIVE flag, updates filtered file list, redraws screen
; Registers clobbered: A, B, D, E, H, L
; ============================================================================
SEARCH_PROMPT:
        LD   DE, MSG_SEARCH     ; Point to "SEARCH: " message
        CALL MON_MESSAGE        ; Display prompt
        CALL LETLN              ; Output newline
        
        ; Get search string from user
        CALL GETL               ; Monitor's line input routine (reads into LBUF)
        
        ; Copy search string from LBUF to SEARCH_BUF
        LD   HL, LBUF           ; Source: line input buffer
        LD   DE, SEARCH_BUF     ; Destination: search buffer
        LD   B, 16              ; Maximum 16 characters
COPY_SEARCH:
        LD   A, (HL)            ; Read character
        CP   0DH                ; CR (end of line)?
        JR   Z, SEARCH_DONE     ; Jump if end of input
        LD   (DE), A            ; Write to search buffer
        INC  HL
        INC  DE
        DJNZ COPY_SEARCH        ; Loop until 16 chars copied
        
SEARCH_DONE:
        LD   A, 0               ; Null terminator
        LD   (DE), A            ; Terminate search string
        
        ; Activate search filter and reset view
        LD   A, 1
        LD   (SEARCH_ACTIVE), A ; Set search active flag
        XOR  A
        LD   (PAGE_NUM), A      ; Reset to page 0
        LD   (CURSOR_POS), A    ; Reset cursor to top
        LD   (CACHED_PAGE), A   ; Invalidate page cache
        DEC  A                  ; A = 0xFF
        LD   (CACHED_COUNT), A  ; Mark cache invalid
        
        ; Redraw menu with filtered results
        CALL DRAW_SCREEN
        RET

; ============================================================================
; GET_FILE_AT_INDEX - Fetch file entry from PICO
; ============================================================================
; Purpose: Request file entry at specified index from PICO via SD_DIRLIST
; Inputs:  A = file index (0-based)
; Outputs: WORKING_STORE contains CR-terminated filename from PICO
;          (CR termination matches MON_STRING's expected format)
; Registers clobbered: A, B, C, D, E
; Notes:   Sends command 0xA1 (ack), then index (status), then a
;          null-terminated filename of up to 32 bytes; the null is
;          replaced with CR (0DH) when stored
; ============================================================================
GET_FILE_AT_INDEX:
        PUSH BC
        PUSH DE
        LD   E, A               ; E = index to fetch

        ; Send directory list command
        LD   A, SD_DIRLIST      ; Command: get directory entry
        CALL MCMD                ; Send command, receive dispatch ack
        LD   A, E               ; A = file index
        CALL MCMD                ; Send index, receive per-index status
        AND  A                  ; Test status
        JR   NZ, GET_FILE_ERR   ; Jump if error

        ; Receive filename bytes into WORKING_STORE until null terminator
        LD   HL, WORKING_STORE
        LD   B, 32              ; Max bytes to receive
GET_FILE_RX:
        CALL RCVBYTE            ; Receive one byte
        OR   A                  ; Was it the null terminator?
        JR   Z, GET_FILE_TERM   ; Yes, stop (don't store the null)
        LD   (HL), A            ; Store in buffer
        INC  HL
        DJNZ GET_FILE_RX        ; Loop up to 32 times
GET_FILE_TERM:
        LD   (HL), 0DH          ; CR-terminate for MON_STRING/search use

GET_FILE_ERR:
        POP  DE
        POP  BC
        RET

; ============================================================================
; COPY_ENTRY_TO_PAGE - Copy filename to page buffer
; ============================================================================
; Purpose: Copy current file entry filename to page cache
; Inputs:  HL = destination address in PAGE_BUFFER
; Outputs: Copies filename field (16 bytes), always CR-terminated within
;          the field; names longer than 15 characters are truncated so
;          MON_STRING never overruns into the next entry
; Registers clobbered: A, B, D, E, H, L
; ============================================================================
COPY_ENTRY_TO_PAGE:
        PUSH BC
        PUSH DE

        ; Copy up to 15 bytes, stopping early at CR (end of source name)
        LD   DE, WORKING_STORE  ; Source
        LD   B, 15              ; Reserve last byte of field for CR
COPY_NAME:
        LD   A, (DE)            ; Read byte
        CP   0DH                ; End of source name?
        JR   Z, COPY_NAME_DONE
        LD   (HL), A            ; Write byte
        INC  DE
        INC  HL
        DJNZ COPY_NAME          ; Loop
COPY_NAME_DONE:
        LD   (HL), 0DH          ; Terminate field (truncates if name is long)

        POP  DE
        POP  BC
        RET

; ============================================================================
; GET_PAGE - Load page of files into cache
; ============================================================================
; Purpose: Build page cache with filenames that match search filter (if active)
; Inputs:  A = page number (0-based)
; Outputs: PAGE_BUFFER filled with up to 16 filenames, CACHED_COUNT = count
; Registers clobbered: A, B, C, D, E, H, L
; Logic:   
;   1. Get total file count
;   2. Calculate starting index for page (page * 16)
;   3. Scan through files starting at that index
;   4. For each file, check if it matches search filter (if active)
;   5. Cache matching files in PAGE_BUFFER
; ============================================================================
GET_PAGE:
        LD   E, A               ; E = requested page number
        LD   A, (CACHED_COUNT)
        CP   0FFH               ; Is the cache marked invalid?
        JR   Z, GET_PAGE_LOAD   ; Yes, must (re)load - not a cache hit
        LD   A, (CACHED_PAGE)
        CP   E
        JR   Z, GET_PAGE_HIT    ; If same page cached, return cached result

GET_PAGE_LOAD:
        ; Need to load new page
        CALL GET_FILE_COUNT     ; Get total file count
        LD   C, A               ; C = total count
        
        ; Calculate starting file index for this page (page * 16)
        LD   H, 0
        LD   L, E               ; L = page number
        ADD  HL, HL
        ADD  HL, HL
        ADD  HL, HL
        ADD  HL, HL             ; HL = E * 16
        LD   A, L               ; A = starting index
        LD   B, ROWS_PER_PAGE   ; B = rows to load (16)
        PUSH AF                 ; Save starting index across CACHED_COUNT reset
        XOR  A
        LD   (CACHED_COUNT), A  ; Start with count = 0
        POP  AF                 ; Restore starting index

GET_PAGE_LOOP:
        ; Check if index A is within range
        CP   C                  ; Compare index with total count
        JR   NC, GET_PAGE_DONE  ; If A >= C, we're done with page

        ; Fetch file entry at index A
        LD   D, A               ; D = current file index (survives the call)
        CALL GET_FILE_AT_INDEX  ; Get file D into WORKING_STORE

        ; Check search filter if active
        LD   A, (SEARCH_ACTIVE)
        OR   A
        CALL NZ, CHECK_SEARCH_MATCH ; Check if matches search string

        ; If search active and no match, skip this file
        JR   NZ, SKIP_TO_NEXT   ; Jump if no match (Z flag clear)

        ; File matches filter: compute this entry's slot address fresh from
        ; CACHED_COUNT (COPY_ENTRY_TO_PAGE does not return HL at the field
        ; start, so a carried pointer can't be trusted across calls)
        LD   A, (CACHED_COUNT)
        LD   L, A
        LD   H, 0
        ADD  HL, HL
        ADD  HL, HL
        ADD  HL, HL
        ADD  HL, HL             ; HL = CACHED_COUNT * 16
        PUSH DE                 ; Preserve D (index) and E (page number)
        LD   DE, PAGE_BUFFER
        ADD  HL, DE             ; HL = destination address for this entry
        POP  DE
        CALL COPY_ENTRY_TO_PAGE

        LD   A, (CACHED_COUNT)
        INC  A
        LD   (CACHED_COUNT), A

SKIP_TO_NEXT:
        LD   A, D               ; Restore current index
        INC  A                  ; Move to next file
        DJNZ GET_PAGE_LOOP      ; Continue looping
        
GET_PAGE_DONE:
        LD   A, E
        LD   (CACHED_PAGE), A   ; Remember which page is cached
        JR   GET_PAGE_RET
        
GET_PAGE_HIT:
        LD   A, (CACHED_COUNT)  ; Return cached count
        
GET_PAGE_RET:
        RET

; ============================================================================
; GET_FILE_COUNT - Query total file count from PICO
; ============================================================================
; Purpose: Send file count query to PICO, receive total file count
; Inputs:  None
; Outputs: A = total files on SD card
; Registers clobbered: A, B, C, D, E
; ============================================================================
GET_FILE_COUNT:
        PUSH BC
        PUSH DE
        LD   A, SD_FILECOUNT    ; Command: get file count
        CALL MCMD               ; Send command, receive dispatch ack
        CALL RCVBYTE            ; Receive: count
        POP  DE
        POP  BC
        RET

; ============================================================================
; CHECK_SEARCH_MATCH - Test if filename matches search filter
; ============================================================================
; Purpose: Compare filename with search string (case-insensitive)
; Inputs:  WORKING_STORE = filename, SEARCH_BUF = search pattern
; Outputs: Z flag if match, NZ flag if no match
; Registers clobbered: A, H, L, D, E, B, C
; Notes:   Simple substring search, case-insensitive
; ============================================================================
CHECK_SEARCH_MATCH:
        PUSH HL
        PUSH DE
        PUSH BC
        
        LD   HL, WORKING_STORE  ; Filename
        LD   DE, SEARCH_BUF     ; Search string
        
SEARCH_MATCH_LOOP:
        LD   A, (DE)            ; Character from search string
        OR   A                  ; End of search string?
        JR   Z, SEARCH_FOUND    ; If yes, whole pattern matched
        
        LD   B, A               ; B = search character
        LD   A, (HL)            ; A = filename character
        CP   0DH                ; End of filename (CR-terminated)?
        JR   Z, SEARCH_NOT_FOUND ; If yes, pattern not found
        
        ; Convert both to uppercase for case-insensitive compare
        CP   'a'
        JR   C, UPPER_B
        CP   'z'+1
        JR   NC, UPPER_B
        SUB  20H                ; Convert to uppercase
        
UPPER_B:
        LD   C, A               ; C = uppercase filename char
        LD   A, B               ; A = search char
        CP   'a'
        JR   C, CMP_NOW
        CP   'z'+1
        JR   NC, CMP_NOW
        SUB  20H                ; Convert to uppercase
        
CMP_NOW:
        CP   C                  ; Compare
        JR   NZ, SEARCH_NOT_FOUND ; Jump if not equal
        
        ; Characters match, advance pointers
        INC  HL
        INC  DE
        JR   SEARCH_MATCH_LOOP
        
SEARCH_FOUND:
        POP  BC
        POP  DE
        POP  HL
        XOR  A                  ; Set Z flag
        RET
        
SEARCH_NOT_FOUND:
        POP  BC
        POP  DE
        POP  HL
        LD   A, 1               ; Clear Z flag
        RET

; ============================================================================
; NAVIGATION ROUTINES
; ============================================================================

; ============================================================================
; MOVE_UP - Move cursor up one row
; ============================================================================
; Purpose: Decrement cursor position, redraw cursor marker
; Inputs:  None
; Outputs: CURSOR_POS decremented, screen updated
; Notes:   Does nothing if already at top (row 0)
; ============================================================================
MOVE_UP:
        LD   A, (CURSOR_POS)
        OR   A                  ; At top?
        RET  Z                  ; Yes, do nothing
        DEC  A
        CALL CLEAR_MARKER       ; Remove old marker
        LD   (CURSOR_POS), A    ; Update position
        CALL DRAW_MARKER        ; Draw new marker
        RET

; ============================================================================
; MOVE_DOWN - Move cursor down one row
; ============================================================================
; Purpose: Increment cursor position, redraw cursor marker
; Inputs:  None
; Outputs: CURSOR_POS incremented, screen updated
; Notes:   Does nothing if already at bottom of current page
; ============================================================================
MOVE_DOWN:
        LD   A, (CACHED_COUNT)
        DEC  A                  ; Last valid row
        LD   C, A
        LD   A, (CURSOR_POS)
        CP   C                  ; At bottom?
        RET  Z                  ; Yes, do nothing
        INC  A
        CALL CLEAR_MARKER       ; Remove old marker
        LD   (CURSOR_POS), A    ; Update position
        CALL DRAW_MARKER        ; Draw new marker
        RET

; ============================================================================
; PAGE_LEFT - Go to previous page
; ============================================================================
; Purpose: Decrement page number, redraw entire screen
; Inputs:  None
; Outputs: PAGE_NUM decremented, screen redrawn
; Notes:   Does nothing if already on first page (page 0)
; ============================================================================
PAGE_LEFT:
        LD   A, (PAGE_NUM)
        OR   A                  ; At first page?
        RET  Z                  ; Yes, do nothing
        DEC  A
        LD   (PAGE_NUM), A      ; Update page
        XOR  A
        LD   (CURSOR_POS), A    ; Reset cursor to top of new page
        CALL DRAW_SCREEN        ; Redraw entire screen
        RET

; ============================================================================
; PAGE_RIGHT - Go to next page
; ============================================================================
; Purpose: Increment page number, redraw entire screen
; Inputs:  None
; Outputs: PAGE_NUM incremented, screen redrawn
; Notes:   Does nothing if next page would be empty
; ============================================================================
PAGE_RIGHT:
        LD   A, (PAGE_NUM)
        INC  A
        CALL GET_PAGE           ; Check if next page has files
        LD   A, (CACHED_COUNT)
        OR   A                  ; Any files on next page?
        RET  Z                  ; No, stay on current page
        LD   A, (PAGE_NUM)
        INC  A
        LD   (PAGE_NUM), A      ; Update page
        XOR  A
        LD   (CURSOR_POS), A    ; Reset cursor to top of new page
        CALL DRAW_SCREEN        ; Redraw entire screen
        RET

; ============================================================================
; DISPLAY ROUTINES
; ============================================================================

; ============================================================================
; DRAW_SCREEN - Full screen redraw
; ============================================================================
; Purpose: Clear screen and redraw title, header, file list, footer
; Inputs:  None
; Outputs: Complete screen display
; Registers clobbered: All
; ============================================================================
DRAW_SCREEN:
        CALL CLEAR_SCREEN       ; Clear screen and reset cursor
        
        LD   A, (PAGE_NUM)
        CALL GET_PAGE           ; Load current page into cache
        
        ; Display title at top
        LD   HL, TITLE_MSG
        LD   D, 0               ; Row 0
        LD   E, 7               ; Column 7 (centered)
        CALL PRINT_STR
        
        ; Display header
        LD   HL, HEADER_MSG
        LD   D, 1               ; Row 1
        LD   E, 0               ; Column 0
        CALL PRINT_STR
        
        ; Display file list
        CALL DRAW_PAGE
        CALL DRAW_MARKER        ; Show cursor arrow at initial position

        ; Display footer
        LD   HL, FOOTER_MSG
        LD   D, 24              ; Row 24 (bottom)
        LD   E, 0               ; Column 0
        CALL PRINT_STR
        
        RET

; ============================================================================
; DRAW_PAGE - Display cached files with cursor marker
; ============================================================================
; Purpose: Draw file list from PAGE_BUFFER on screen
; Inputs:  PAGE_BUFFER = cached filenames, CACHED_COUNT = how many
; Outputs: Files displayed on rows ROW_START through ROW_START+count
; ============================================================================
DRAW_PAGE:
        LD   A, (CACHED_COUNT)
        OR   A
        RET  Z                  ; Nothing to draw
        
        LD   C, A               ; C = count of files to draw
        LD   B, ROW_START       ; B = starting screen row
        LD   HL, PAGE_BUFFER    ; HL = start of file data
        
DRAW_ROW:
        LD   D, B               ; D = row
        LD   E, 1               ; E = column
        CALL PRINT_STR          ; Print filename at this position
        
        DEC  C                  ; Decrement file count
        RET  Z                  ; Done if no more files
        
        INC  B                  ; Next row
        LD   DE, 16             ; Advance to next filename (16 bytes)
        ADD  HL, DE
        JR   DRAW_ROW

; ============================================================================
; DRAW_MARKER - Draw cursor arrow at current position
; ============================================================================
; Purpose: Display arrow character at cursor row
; Inputs:  CURSOR_POS = row within page
; Outputs: Arrow displayed at left of current row
; ============================================================================
DRAW_MARKER:
        PUSH AF
        LD   H, ROW_START       ; Base screen row
        LD   A, (CURSOR_POS)    ; Cursor offset
        ADD  A, H               ; Calculate absolute row
        LD   H, A
        LD   L, 0               ; Column 0
        LD   (CURSOR), HL       ; Set cursor position
        LD   DE, MARKER_STR     ; Point to arrow character
        CALL MON_MESSAGE        ; Display it
        POP  AF
        RET

; ============================================================================
; CLEAR_MARKER - Erase cursor arrow at current position
; ============================================================================
; Purpose: Overwrite arrow with space
; Inputs:  CURSOR_POS = row within page
; Outputs: Space displayed at left of current row
; ============================================================================
CLEAR_MARKER:
        PUSH AF
        LD   H, ROW_START       ; Base screen row
        LD   A, (CURSOR_POS)    ; Cursor offset
        ADD  A, H               ; Calculate absolute row
        LD   H, A
        LD   L, 0               ; Column 0
        LD   (CURSOR), HL       ; Set cursor position
        LD   DE, SPACE_STR      ; Point to space character
        CALL MON_MESSAGE        ; Display it
        POP  AF
        RET

; ============================================================================
; CLEAR_SCREEN - Clear display and home cursor
; ============================================================================
; Purpose: Send clear screen command and reset cursor position
; Inputs:  None
; Outputs: Screen cleared, cursor at home
; ============================================================================
CLEAR_SCREEN:
        LD   A, CLS_CHAR        ; Cursor home/clear character
        CALL MON_VIDEO          ; Send to display
        XOR  A
        LD   (CURSOR_POS), A    ; Reset cursor position variable
        RET

; ============================================================================
; PRINT_STR - Print string at specified row/column
; ============================================================================
; Purpose: Set cursor position and print string
; Inputs:  HL = string address, D = row, E = column
; Outputs: String displayed on screen
; Notes:   Uses monitor's MON_STRING routine
; ============================================================================
PRINT_STR:
        PUSH DE                 ; Save row/column
        PUSH HL                 ; Save string pointer
        LD   (CURSOR), DE       ; Set cursor position (D=row, E=col)
        LD   DE, HL             ; DE = string address (for MON_STRING)
        CALL MON_STRING         ; Call monitor's string output
        POP  HL
        POP  DE
        RET

; ============================================================================
; FILE LOADING
; ============================================================================

; ============================================================================
; LOAD_SELECTED - Load and execute selected file
; ============================================================================
; Purpose: Find actual file index of selected file, load from SD, execute
; Inputs:  CURSOR_POS = selected row, PAGE_NUM = current page
; Outputs: File loaded into memory and executed (no return on success)
;          Returns only if load fails
; Registers clobbered: All
; Logic:   
;   1. Calculate absolute index from page and cursor
;   2. Scan through files to find the Nth file
;   3. Send load command (0x81) with that index
;   4. Receive header and file data
;   5. Jump to execution address
; ============================================================================
LOAD_SELECTED:
        LD   A, (CACHED_COUNT)
        OR   A
        RET  Z                  ; Nothing to load
        
        ; Calculate absolute file index
        LD   A, (PAGE_NUM)
        LD   L, A
        LD   H, 0
        ADD  HL, HL
        ADD  HL, HL
        ADD  HL, HL
        ADD  HL, HL             ; HL = PAGE_NUM * 16
        
        LD   A, (CURSOR_POS)
        ADD  A, L
        LD   E, A               ; E = absolute index in filtered list
        
        ; Find the E-th file (scan through all files)
        LD   D, 0               ; D = current file count
        LD   B, 0               ; B = current raw index
        
FIND_FILE:
        ; Bounds check: have we scanned too many files?
        CALL GET_FILE_COUNT     ; Get total count
        LD   C, A               ; C = total count
        LD   A, B               ; A = current raw index
        CP   C                  ; Carry set if B < total (continue)
        JR   C, FILE_INDEX_OK   ; Continue if B < total
        RET                     ; ERROR: file index not found, return
        
FILE_INDEX_OK:
        LD   A, B
        CALL GET_FILE_AT_INDEX  ; Get file B into WORKING_STORE
        
        ; Check if search filter is active
        LD   A, (SEARCH_ACTIVE)
        OR   A
        CALL NZ, CHECK_SEARCH_MATCH ; Check search match
        JR   NZ, NEXT_RAW_FILE  ; Skip if doesn't match filter
        
        ; It's a matching file, is it the one we want?
        LD   A, D
        CP   E                  ; D == E?
        JR   Z, LOAD_THIS_FILE  ; Yes, load it
        
        INC  D                  ; No, increment count
        
NEXT_RAW_FILE:
        INC  B
        JR   FIND_FILE
        
LOAD_THIS_FILE:
        ; Load file by raw index B
        LD   A, SD_LOAD         ; Command: load file
        CALL MCMD                ; Send command, receive dispatch ack
        LD   A, B               ; A = file index
        CALL MCMD                ; Send index, receive per-index status
        AND  A                  ; Check for error
        RET  NZ                 ; Return if error
        
        CALL HDRCV              ; Receive header (filename, addresses)
        CALL DBRCV              ; Receive file data into memory

        CALL CLEAR_SCREEN       ; Clear screen before jumping to program
        
        ; Jump to program
        LD   HL, (EXEAD)        ; Get execution address
        JP   (HL)               ; Jump to program (no return)

; ============================================================================
; SD COMMUNICATION ROUTINES
; ============================================================================

; ============================================================================
; COMMS_INIT - Initialize MAILBOX communication
; ============================================================================
; Purpose: Synchronize Z80 and PICO mailbox, clear all flags
; Inputs:  None
; Outputs: Both Z80 and PICO see empty mailbox
; Notes:   Call once at startup before any communication
; ============================================================================
COMMS_INIT:
        ; Z80 empties first, then waits for PICO to empty its side
        
        ; Reset the Z80->PICO flag to indicate mailbox empty
        LD   A, 0
        LD   (Z80_TO_PICO_FLAG), A
        
        ; Wait for PICO to clear its flag (PICO->Z80 flag should be 0)
WAIT_EMPTY_PICO:
        LD   A, (PICO_TO_Z80_FLAG)
        OR   A                  ; Test if 0
        JR   NZ, WAIT_EMPTY_PICO ; Loop while PICO flag is set
        RET

; ============================================================================
; STCMD - Send command byte to PICO
; ============================================================================
; Purpose: Wrapper for SNDBYTE (sends command code)
; Inputs:  A = command byte to send
; Outputs: Sent via MAILBOX
; ============================================================================
STCMD:
        CALL SNDBYTE            ; Send the byte
        RET

; ============================================================================
; SNDBYTE - Send byte to PICO via MAILBOX with handshake
; ============================================================================
; Purpose: Send single byte to PICO with polling handshake
; Inputs:  A = byte to send
; Outputs: Byte sent to MAILBOX, PICO receives and clears flag
; Registers clobbered: A, B, C
; Protocol:
;   1. Poll Z80_TO_PICO_FLAG until 0 (mailbox empty)
;   2. Write data to Z80_TO_PICO_DATA
;   3. Set Z80_TO_PICO_FLAG to 1 (data ready)
;   4. PICO reads data and clears flag
; ============================================================================
SNDBYTE:
        PUSH BC
        LD   C, A               ; C = byte to send
        
        ; Poll until mailbox is empty (flag = 0)
SNDBYTE_WAIT:
        LD   A, (Z80_TO_PICO_FLAG)
        OR   A                  ; Test if 0
        JR   NZ, SNDBYTE_WAIT   ; Loop while flag is set
        
        ; Mailbox is empty, send data
        LD   A, C               ; A = data byte
        LD   (Z80_TO_PICO_DATA), A ; Write data
        LD   A, 1               ; A = 1 (data ready flag)
        LD   (Z80_TO_PICO_FLAG), A ; Set flag
        
        POP  BC
        RET

; ============================================================================
; RCVBYTE - Receive byte from PICO via MAILBOX with handshake
; ============================================================================
; Purpose: Receive single byte from PICO with polling handshake
; Inputs:  None
; Outputs: A = received byte
; Registers clobbered: A, B, C
; Protocol:
;   1. Poll PICO_TO_Z80_FLAG until 1 (data ready)
;   2. Read data from PICO_TO_Z80_DATA
;   3. Clear PICO_TO_Z80_FLAG to 0 (data consumed)
;   4. PICO resumes sending
; ============================================================================
RCVBYTE:
        PUSH BC
        
        ; Poll until data is ready (flag = 1)
RCVBYTE_WAIT:
        LD   A, (PICO_TO_Z80_FLAG)
        OR   A                  ; Test if 1
        JR   Z, RCVBYTE_WAIT    ; Loop while flag is clear
        
        ; Data is ready, read it
        LD   A, (PICO_TO_Z80_DATA) ; Read data
        LD   C, A               ; C = received byte
        
        ; Clear the flag to indicate data consumed
        XOR  A                  ; A = 0
        LD   (PICO_TO_Z80_FLAG), A ; Clear flag
        
        LD   A, C               ; A = received byte
        POP  BC
        RET

; ============================================================================
; HDRCV - Receive file header from PICO
; ============================================================================
; Purpose: Receive file header with metadata
; Inputs:  None
; Outputs: Fills FNAME, SADRS, FSIZE, EXEAD with file info
; Format received:
;   - 11 bytes: filename
;   - 2 bytes: start address (little-endian)
;   - 2 bytes: file size (little-endian)
;   - 2 bytes: execution address (little-endian)
; ============================================================================
HDRCV:
        LD   HL, FNAME          ; Point to filename storage
        LD   B, 11H             ; 17 bytes for filename
HDRC1:
        CALL RCVBYTE            ; Receive byte
        LD   (HL), A            ; Store it
        INC  HL
        DJNZ HDRC1              ; Loop 17 times
        
        ; Receive start address (2 bytes, little-endian)
        LD   HL, SADRS
        CALL RCVBYTE
        LD   (HL), A            ; Low byte
        INC  HL
        CALL RCVBYTE
        LD   (HL), A            ; High byte
        
        ; Receive file size (2 bytes, little-endian)
        LD   HL, FSIZE
        CALL RCVBYTE
        LD   (HL), A            ; Low byte
        INC  HL
        CALL RCVBYTE
        LD   (HL), A            ; High byte
        
        ; Receive execution address (2 bytes, little-endian)
        LD   HL, EXEAD
        CALL RCVBYTE
        LD   (HL), A            ; Low byte
        INC  HL
        CALL RCVBYTE
        LD   (HL), A            ; High byte
        RET

; ============================================================================
; STRINGS & MESSAGES
; ============================================================================

TITLE_MSG:
        DB 'MZ80K BROWSER', 0DH

HEADER_MSG:
        DB 'PICO-XB80 VERSION 1.0', 0DH

FOOTER_MSG:
        DB 'W/S A/D  R=RUN /=FIND ',05EH,'BREAK=EXIT', 0DH

MSG_NOFIL:
        DB 'NO FILES FOUND', 0DH

MSG_SEARCH:
        DB 'SEARCH: ', 0DH

MSG_NONAME:
        DB 'NO FILENAME', 0DH

MSG_F0:
        DB 'SD-CARD ERROR', 0DH

MSG_F1:
        DB 'FILE NOT FOUND', 0DH

MSG99:
        DB ' ERROR', 0DH

MARKER_STR:
        DB ARROW, 0DH

SPACE_STR:
        DB ' ', 0DH

        END
