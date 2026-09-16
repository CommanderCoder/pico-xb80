; Based on work by Yanataka 
; https://github.com/yanataka60/MZ80K_SD



; FDL will list the files [STLT:] [DIRLIST:]
; FDE will jump to the menu
;  menu will fetch the number of files available and then fetch the files into a page buffer
; 


; FD_rom1.s - cleaned comments and unreadable characters removed
; Purpose: Disk (FD) command handling for MZ-80K / MZ-700 monitor integration
; Description: Implements SD-card based load/save/dir/copy/delete and monitor
; Note: Only comments were removed/rewritten; code instructions unchanged.
; Improvements/Redundancies: See NOTES_AT_END label for detailed suggestions

; 0000h ; COLDSTART reset
GETL  EQU 0003H ; get a line from keyboard into buffer (line input routine)
LETLN EQU 0006H  ; output new line
NEWLIN EQU 0009H  ; output newline (CR/LF) but not if already at the start of a line
PRNTS EQU 000CH  ; print space
; 000FH ; TAB , pad with spaces
MON_VIDEO EQU 0012H  ; video driver 0x0935 - outputs a single char from A
MON_MESSAGE EQU 0015H  ; output raw text (0xD terminator)
MON_STRING EQU 0018H  ; output text with wrapping
MON_GETKEY EQU 001BH  ; get a single key (no echo)
TIMST EQU 0033H  ; timer start / read 8253 tick (used by monitor delays)

PRTWRD EQU 03BAH  ; print 16‑bit word in hex
PRTBYT EQU 03C3H  ; print 8‑bit byte in hex
HLHEX EQU 0410H  ; convert HL to hex ASCII (2‑byte)
TWOHEX EQU 041FH  ; convert A to 2‑digit hex ASCII
ADCN EQU 0BB9H  ; add with carry routine (BCD/hex adjust helper)
DISPCH EQU 0DB5H  ; display character on screen
DPCT EQU 0DDCH  ; display control character


IBUFE EQU 10F0H  ; file header buffer start (tape I/O)
FNAME EQU 10F1H  ; file name field in header
EADRS EQU 1102H  ; end address in header
FSIZE EQU 1102H  ; file size (same location as end address)
SADRS EQU 1104H  ; start address in header
EXEAD EQU 1106H  ; execution address in header
CURSOR EQU 1171H  ; position of the cursor Row/Col - in High/Low bytes
LBUF EQU 11A3H  ; line input buffer

MBUF EQU 11AEH  ; monitor work buffer


MONITOR_80K EQU 0082H ; entry point for MZ‑80K monitor
MONITOR_700 EQU 00ADH ; entry point for MZ‑700‑compatible monitor

; MENU 

ROWS_PER_PAGE EQU    16 ; NOTE this idea of 16 is used in PAGE setup by doubling 4 times
WORKING_STORE EQU    0c800H
PAGE_BUFFER EQU      0c820H
PAGE_VAR    EQU      0cb20H
CURSOR_VAR  EQU      0cb21H
CACHED_PAGE EQU      0cb22H
CACHED_COUNT EQU     0cb23H
ROW_START       EQU     02H         ; first screen row used by the list



        ORG		0F000H

		NOP
		JP		START

ENT1: 	JP		MSHED ; PHEAD (punch header)
ENT2: 	JP		MSDAT ; PDATA (punch data)
ENT3: 	JP		MLHED ; LHEAD (load header)
ENT4: 	JP		MLDAT ; LDATA (load data)
ENT5: 	JP		MVRFY ; CHECK (Checks file)

; ---------------------------------------------------------------------------
; START:
;   Command parser entry point.
;
;   This routine checks whether the line buffer (LBUF) begins with the
;   three‑character sequence "*FD". If not, control jumps to MON (the monitor).
;
;   If "*FD" is detected, the pointer DE is advanced past it and the next
;   character is examined:
;
;       - Space, '/' or CR → treat as a plain FD load command and jump to SDLOAD
;       - Otherwise, the character selects a subcommand:
;             'S' → STSV   (Save memory block to a file)
;             'A' → STAS   (Set the Auto Start program)
;             'L' → STLT   (List files on the SD)
;             'D' → STDE   (Delete a file)
;             'R' → STRN   (Rename a file)
;             'P' → STPR   (Dump a file)
;             'C' → STCP   (Copy a file)
;             'M' → STMD   (Dump memory)
;             'W' → STMW   (Write data to memory?)
;             'Z' → STMZ   (For MZ700 - FT.MZT?)
;             'U' → STURA  (For MZ700 - rear ram?)
;             'X' → DEBG   (example text to test activity)
;			  'E' → MENU   (menu for file selection)
;
;       - Any unrecognised character → CMDERR
;
;   If the command is "*FD" followed immediately by CR, space, or '/',
;   the default filename (DEFNAME) is copied into the filename buffer and
;   the loader routine SDLOAD is entered.
;
;   Registers used:
;       A  – character under test
;       DE – pointer into LBUF
;       HL, BC – used when copying DEFNAME
;
; ---------------------------------------------------------------------------
START:
		CALL    COMMS_INIT
		LD		DE,LBUF
		LD		A,(DE)
		CP		'*'
		JP		NZ,MON
		INC 	DE
		LD		A,(DE)
		CP		'F'
		JP		NZ,MON
		INC		DE
		LD		A,(DE)
		CP		'D'
		JP		NZ,MON
		INC		DE
STT2: 	LD		A,(DE)
		CP		20H ; space
		JR		Z,SDLOAD
		CP		'/'
		JR		Z,SDLOAD
		CP		0DH ; end of line
		JR		NZ,STETC
STT3: 	PUSH	DE
		LD		HL,DEFNAME
		INC		DE
		LD		BC,NEND-DEFNAME
		LDIR
		POP		DE
		JR		SDLOAD
STETC:
		CP		'S'
		JP		Z,STSV
		CP		'A'
		JP		Z,STAS
		CP		'L'
		JP		Z,STLT
		CP		'D'
		JP		Z,STDE
		CP		'R'
		JP		Z,STRN
		CP		'P'
		JP		Z,STPR
		CP		'C'
		JP		Z,STCP
		CP		'M'
		JP		Z,STMD
		CP		'W'
		JP		Z,STMW
		CP		'Z'
		JP		Z,STMZ
		CP		'U'
		JP		Z,STURA
		CP 'X' ; FDX for debug message
		JP Z, DEBG
		CP 'E' ; FDE for menu
		JP Z, MENU

		JP		CMDERR





; Routine: SDLOAD
; Purpose: Start a file LOAD from SD (FD) device. Sends a load command, receives
;          file header and file data length/address, then jumps to execution
; Inputs:  LBUF contains parsed command parameters
; Outputs: fills FNAME, SADRS, FSIZE, EXEAD; branches to MON on special cases
; Clobbers: A, DE, HL, B, C
; Notes: Uses STCMD/HDRCV/DBRCV and device I/O via RCVBYTE/SNDBYTE.
SDLOAD:	LD		A,81H
		CALL	STCMD
		CALL	HDRCV
		CALL	DBRCV
		LD		A,(LBUF+3)
		CP		'/'
		JP		Z,MON

		LD		A,00H
		LD		DE,0000H
		CALL	TIMST

		LD		HL,(EXEAD)
		JP		(HL)

; open file using index that is in E
SDFILE:	LD		A,0A2H
		CALL	STCD
		AND A
		JP		NZ,SVERR		
		LD		A,E
		CALL	STCD
		AND A
		JP		NZ,SVERR
		CALL	HDRCV
		CALL	DBRCV
		LD		A,(LBUF+3)
		CP		'/'
		JP		Z,MON

		LD		A,00H
		LD		DE,0000H
		CALL	TIMST

		LD		HL,(EXEAD)
		JP		(HL)


; Routine: HDRCV
; Purpose: Receive header information (file name and metadata) from device.
; Inputs:  none (protocol-driven)
; Outputs: stores file name at FNAME, sets SADRS, FSIZE, EXEAD
; Clobbers: A, HL, B, DE
HDRCV:	LD		HL,FNAME
		LD		B,11H
HDRC1:	CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		DEC		B
		JR		NZ,HDRC1
		LD		DE,MSG_LD
		CALL	MON_MESSAGE
		LD		DE,FNAME
		CALL	MON_MESSAGE
		CALL	LETLN
		LD		HL,SADRS
		CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		CALL	RCVBYTE
		LD		(HL),A
		LD		HL,FSIZE
		CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		CALL	RCVBYTE
		LD		(HL),A
		LD		HL,EXEAD
		CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		CALL	RCVBYTE
		LD		(HL),A
		RET



; Routine: DBRCV
; Purpose: Receive the file body/data from device into memory starting at SADRS.
; Inputs:  FSIZE (word) contains byte count, SADRS contains destination
; Outputs: memory filled with received bytes
; Clobbers: A, HL, DE
DBRCV:	LD		DE,(FSIZE)
		LD		HL,(SADRS)
DBRLOP:	CALL	RCVBYTE
		LD		(HL),A
		DEC		DE
		LD		A,D
		OR		E
		INC		HL
		JR		NZ,DBRLOP
		RET




; Routine: STSV
; Purpose: Handle SAVE command argument parsing and validate addresses/ranges.
; Inputs: command buffer in DE points into LBUF; expects ASCII hex pairs
; Outputs: sets SADRS, EADRS, EXEAD as parsed; on error jumps to ERRMSG
; Clobbers: A, HL, BC, DE
STSV:	INC		DE
		INC		DE
		PUSH	DE
		CALL	HLHEX
		JR		C,STSV1

		LD		(SADRS),HL
		POP		DE
		INC		DE
		INC		DE
		INC		DE
		INC		DE
		INC		DE
		PUSH	DE
		CALL	HLHEX
		JR		C,STSV1
		PUSH	HL
		LD		BC,(SADRS)
		SBC		HL,BC
		POP		HL
		JR		Z,STSV1
		JR		C,STSV1

		LD		(EADRS),HL
		POP		DE
		INC		DE
		INC		DE
		INC		DE
		INC		DE
		INC		DE
		PUSH	DE
		CALL	HLHEX
		JR		C,STSV1

		LD		(EXEAD),HL
		POP		DE
		INC		DE
		INC		DE
		INC		DE
		INC		DE
		INC		DE
		LD		A,(DE)
		CP		31H
		JR		C,STSV2
		EX		DE,HL
		JR		SDSAVE
STSV1:
		LD		DE,MSG_AD
		JR		ERRMSG
STSV2:
		LD		DE,MSG_FNAME
		JR		ERRMSG
CMDERR:
		LD		DE,MSG_CMD
		JR		ERRMSG




; Routine: SDSAVE
; Purpose: Perform SAVE operation to SD device: send header then data.
; Inputs: uses SADRS/EXEAD/FSIZE and buffer contents (HDSEND/DBSEND)
; Outputs: sends blocks via SNDBYTE, reports status via ERRMSG on failure
; Clobbers: A, DE, HL, BC
SDSAVE:	LD		A,80H
		CALL	STCD
		AND		A
		JP		NZ,SVERR
		CALL	HDSEND
		CALL	RCVBYTE
		AND		A
		JR		NZ,SVERR
		CALL	DBSEND
		LD		DE,MSG_SV
		JR		ERRMSG

SVER0:
		POP		DE
SVERR:
		CP		0F0H
		JR		NZ,ERR3
		LD		DE,MSG_F0
		JR		ERRMSG




ERR3:	CP		0F1H
		JR		NZ,ERR4
		LD		DE,MSG_F1
		JR		ERRMSG
ERR4:	CP		0F3H
		JR		NZ,ERR5
		LD		DE,MSG_F3
		JR		ERRMSG
ERR5:	CP		0F4H
		JR		NZ,ERR99
		LD		DE,MSG_CMD
		JR		ERRMSG
ERR99:	CALL	PRTBYT
		LD		DE,MSG99
ERRMSG:	CALL	MON_MESSAGE
		CALL	LETLN
MON:	LD		HL,014EH
		LD		A,(HL)
		CP		'P'
		JP		Z,MONITOR_80K
		CP		'N'
		JP		Z,MONITOR_80K
		LD		HL,06EBH
		LD		A,(HL)
		CP		'M'
		JP		Z,MONITOR_700
		JP		0000H





; Routine: HDSEND
; Purpose: Send file header (name, start/end addresses) to device.
; Inputs: HL points to source header buffer; SADRS/EADRS/EXEAD used
; Outputs: issues SNDBYTE calls for header fields; expects ACK via RCVBYTE
; Clobbers: A, B, HL
HDSEND:	PUSH	HL
		LD		B,20H
SS1:	LD		A,(HL)
		CALL	SNDBYTE
		INC		HL
		DEC		B
		JR		NZ,SS1
		LD		A,0DH
		CALL	SNDBYTE
		POP		HL
		LD		B,10H
SS2:	LD		A,(HL)
		CALL	SNDBYTE
		INC		HL
		DEC		B
		JR		NZ,SS2
		LD		A,0DH
		CALL	SNDBYTE
		LD		HL,SADRS
		LD		A,(HL)
		CALL	SNDBYTE
		INC		HL
		LD		A,(HL)
		CALL	SNDBYTE
		LD		HL,EADRS
		LD		A,(HL)
		CALL	SNDBYTE
		INC		HL
		LD		A,(HL)
		CALL	SNDBYTE
		LD		HL,EXEAD
		LD		A,(HL)
		CALL	SNDBYTE
		INC		HL
		LD		A,(HL)
		CALL	SNDBYTE
		RET




; Routine: DBSEND
; Purpose: Send the file body (data) from memory [SADRS..EADRS] to device.
; Inputs: HL/EADRS and SADRS define transfer range
; Outputs: streams bytes via SNDBYTE until HL==DE
; Clobbers: A, HL, DE
DBSEND:	LD		HL,(EADRS)
		EX		DE,HL
		LD		HL,(SADRS)
DBSLOP:	LD		A,(HL)
		CALL	SNDBYTE
		LD		A,H
		CP		D
		JR		NZ,DBSLP1
		LD		A,L
		CP		E
		JR		Z,DBSLP2
DBSLP1:	INC		HL
		JR		DBSLOP
DBSLP2:	RET



; Routine: STAS
; Purpose: Enable AUTO START (set monitor auto-start flag on SD/FD system).
; Inputs: none (invoked when user requests auto-start)
; Outputs: sends STCMD with value 82h; prints MSG_AS on success
; Clobbers: A, DE
STAS:	LD		A,82H
		CALL	STCMD
		LD		DE,MSG_AS
		JP		ERRMSG




; Routine: STLT
; Purpose: List directory (DIRLIST wrapper) for current DE/DEFDIR selection.
; Inputs: DE points to directory spec or default used
; Outputs: calls DIRLIST and returns to monitor
; Clobbers: A, HL, BC
STLT:	INC		DE ; skip space
		LD		HL,DEFDIR
		LD		BC,DEND-DEFDIR
		CALL	DIRLIST
		AND		A ; A <> 0 means error
		JP		NZ,SVERR
		JP		MON




; Routine: DIRLIST
; Purpose: Request directory listing from device and stream results to output.
; Inputs: HL/BC define the characters '*FD  ' to proceed each line; uses SNDBYTE/RCVBYTE protocol
; Outputs: fills LBUF with entries and displays via MON_MESSAGE
; Clobbers: A, B, HL, DE
DIRLIST:
		LD		A,83H
		CALL	STCD ; send 0x83 command - filelist
		AND		A
		JP		NZ,DLRET

		LD		B,21H ; sending 33 bytes (BC's incoming value doesn't need
		              ; preserving across this loop - DL1 reloads BC fresh)
STLT1:	LD		A,(DE)
		CP		0DH ; replace '\r' with '\0'
		JR		NZ,STLT2
		LD		A,00H ;
STLT2:	CALL	SNDBYTE
		INC		DE
		DEC		B
		JR		NZ,STLT1
; DL1 used to PUSH HL/BC here and POP them at DL3/DL4 every single entry, but
; HL (DEFDIR) and BC (DEND-DEFDIR) are compile-time constants that never
; change - reloading them costs no stack, unlike push/pop. Cutting this was
; part of narrowing down a suspected stack-overflow-into-the-interrupt-vector
; (stack lives at 0x10F0, vectors at 0x1038 - not much headroom) causing the
; intermittent FDL hangs.
DL1:	LD		HL,DEFDIR
		LD		BC,DEND-DEFDIR

		LD		DE,LBUF
		; this will prefill LBUF with '*FD  '
		LDIR ; copy BC bytes from (HL) into (DE)
		EX		DE,HL
DL2:	CALL	RCVBYTE
		CP		00H
		JR		Z,DL3
		CP		0FFH
		JR		Z,DL4
		CP		0FEH
		JR		Z,DL5
		LD		(HL),A
		INC		HL
		JR		DL2
DL3:	LD		DE,LBUF
		CALL	MON_MESSAGE
		CALL	LETLN
		JR		DL1
DL4:	CALL	RCVBYTE
		JR		DLRET

DL5:	LD		DE,MSG_KEY1
		CALL	MON_MESSAGE
		LD		A,0C2H
		CALL	DISPCH
		LD		DE,MSG_KEY2
		CALL	MON_MESSAGE
		CALL	LETLN
DL6:	CALL	MON_GETKEY
		CP		00H
		JR		Z,DL6
		CP		64H
		JR		Z,DL7
		CP		12H
		JR		Z,DL9
		CP		42H
		JR		Z,DL8
		LD		A,00H
		JR		DL8
DL9:	LD		A,0C2H
		CALL	DPCT
		LD		A,0C2H
		CALL	DPCT
DL7:	LD		A,0FFH
DL8:	CALL	SNDBYTE
		CALL	LETLN
		JR		DL2

DLRET:
		; DL1 copies "*FD  " + the current filename into LBUF (the monitor's
		; real command-line buffer) purely so each printed line reads like a
		; load command. Blank it before returning so MON doesn't pick up the
		; last entry as a command to run. Preserve A - it holds our status.
		PUSH	AF
		LD		A,0DH
		LD		(LBUF),A
		POP		AF
		RET


FILECOUNT_CMD EQU 0A0H  ; 
FILEGET_CMD   EQU 0A1H  ; 

; GET COUNT OF MZF FILES ON SD CARD
GET_FILE_COUNT:

		LD		A,FILECOUNT_CMD
		CALL	STCD 
		AND		A ; 0 means success, non-zero means error
		JP		NZ,FCERR

		CALL    RCVBYTE ; A will contain the number of files ending MZT on the SD card
		RET

FCERR:
		XOR A ; A = 0
		RET 

; GET FILE AT INDEX (in A) FROM SD CARD
GET_FILE_AT_INDEX:
		LD		E,A		; save requested index (STCD only clobbers A,B)
		LD		A,FILEGET_CMD
		CALL	STCD
		AND		A
		JP		NZ,FGRET

		LD		A,E
		CALL	STCD ; send the index of the file to get (0 based)
		AND		A ; A <> 0 means error
		JP		NZ,SVERR

		PUSH    HL
		LD		HL,WORKING_STORE
GF2:	CALL	RCVBYTE
		CP		00H
		JR		Z,GF3 ;; found terminator so done
		LD		(HL),A
		INC		HL
		JR		GF2
GF3:
		LD		(HL),0DH	; CR-terminate so MON_STRING/MON_MESSAGE stop here instead of reading stale bytes
		POP	 HL

; WORKING_STORE will contain the filename of the file at index A (0 based) on the SD card
FGRET:
		RET




; Routine: STDE
; Purpose: Delete file on SD device. Prompts user, sends delete command,
;          and reports result messages.
; Inputs: name in LBUF (set prior), user confirmation via GETKEY
; Outputs: device delete via STCMD/SNDBYTE, result via MSG_PR/ERR flows
; Clobbers: A, DE
STDE:	LD		A,84H
		CALL	STCMD

		LD		DE,MSG_DELQ
		CALL	MON_MESSAGE
		CALL	LETLN
STDE3:	CALL	MON_GETKEY
		CP		00H
		JR		Z,STDE3
		CP		59H
		JR		NZ,STDE4
		LD		A,00H
		JR		STDE5
STDE4:	LD		A,0FFH
STDE5:	CALL	SNDBYTE
		CALL	RCVBYTE
		CP		00H
		JR		NZ,STDE6
		LD		DE,MSG_DELY
		JR		STDE8
STDE6:	CP		01H
		JR		NZ,STDE7
		LD		DE,MSG_DELN
		JR		STDE8
STDE7:	JP		SVERR
STDE8:	JP		ERRMSG



; Routine: STRN
; Purpose: Rename a file on SD device. Prompts for new name and issues STCMD.
; Inputs: original name in LBUF, collects NEW name via GETL
; Outputs: calls STFS to send the name, handles ACK via RCVBYTE
; Clobbers: A, DE
STRN:	LD		A,85H
		CALL	STCMD

		LD		DE,MSG_REN
		CALL	MON_MESSAGE

		LD		A,09H
		LD		(CURSOR),A
		LD		DE,LBUF
		CALL	GETL
		LD		DE,LBUF+8
		CALL	STFN
		CALL	STFS

		CALL	RCVBYTE
		CP		00H
		JP		NZ,SVERR
		LD		DE,MSG_RENY
		JP		ERRMSG




; Routine: STPR
; Purpose: Dump (print) a file's contents via the device protocol.
; Inputs: SADRS/FSIZE provide addresses; uses RCVBYTE to stream blocks
; Outputs: prints blocks with PRTWRD/PRNTS/PRTBYT routines
; Clobbers: A, HL, B, C
STPR:	LD		A,86H
		CALL	STCMD



STPR6:	LD		HL,SADRS
		CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		CALL	RCVBYTE
		LD		(HL),A
		LD		HL,(SADRS)
		LD		A,H
		CP		0FFH
		JR		NZ,STPR7
		LD		A,L
		CP		0FFH
		JR		NZ,STPR7
		JP		STPR8
STPR7:	LD		DE,MSG_AD1
		CALL	MON_MESSAGE
		CALL	LETLN
		LD		C,10H
STPR0:	PUSH	BC
		LD		B,08H
		LD		HL,LBUF
STPR1:	CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		DEC		B
		JR		NZ,STPR1

		LD		HL,(SADRS)
		CALL	PRTWRD
		LD		DE,0008H
		ADD		HL,DE
		LD		(SADRS),HL

		LD		B,08H
		LD		DE,LBUF
STPR2:	CALL	PRNTS
		LD		A,(DE)
		CALL	PRTBYT
		INC		DE
		DEC		B
		JR		NZ,STPR2

		CALL	PRNTS
		LD		DE,LBUF
		LD		B,08H
STPR9:	LD		A,(DE)
		CP		10H
		JR		NC,STPRA
		LD		A,20H
STPRA:	CALL	ADCN
		CALL	DISPCH
		INC		DE
		DEC		B
		JR		NZ,STPR9

		CALL	LETLN
		POP		BC
		DEC		C
		JR		NZ,STPR0

		LD		DE,MSG_AD2
		CALL	MON_MESSAGE
		CALL	LETLN
		CALL	LETLN
STPR3:	CALL	MON_GETKEY
		CP		00H
		JR		Z,STPR3
		CP		64H
		JR		Z,STPR4
		CALL	SNDBYTE
		JP		STPR6
STPR4:	LD		A,0FFH
STPR5:	CALL	SNDBYTE
		CALL	RCVBYTE
		CALL	RCVBYTE
STPR8:	CALL	RCVBYTE
		JP		MON




; Routine: STCP
; Purpose: Copy a file on SD device. Prompts for new name and issues copy
;          operations using STCMD/STFS/STFN as needed.
; Inputs: source name in LBUF, prompts for target via GETL
; Outputs: calls STFS and handles ACK via RCVBYTE
; Clobbers: A, DE
STCP:	LD		A,87H
		CALL	STCMD
		LD		DE,MSG_REN
		CALL	MON_MESSAGE

		LD		A,09H
		LD		(CURSOR),A
		LD		DE,LBUF
		CALL	GETL
		LD		DE,LBUF+8
		CALL	STFN
		CALL	STFS

		CALL	RCVBYTE
		CP		00H
		JP		NZ,SVERR
		LD		DE,MSG_CPY
		JP		ERRMSG




; Routine: STMD
; Purpose: Memory dump command: parse address then show memory blocks to user.
; Inputs: ASCII address in command buffer; uses HLHEX to convert
; Outputs: prints blocks via PRTWRD/PRNTS and handles user keys for paging
; Clobbers: A, HL, DE, BC
STMD:	INC		DE
		INC		DE
		CALL	HLHEX
		JP		C,STSV1
		LD		(SADRS),HL

STMD6:	LD		DE,MSG_AD1
		CALL	MON_MESSAGE
		CALL	LETLN
		LD		C,10H
STMD7:	LD		HL,(SADRS)
		CALL	PRTWRD
		CALL	PRNTS


		LD		B,08H
STMD0:	LD		A,(HL)
		CALL	PRTBYT
		CALL	PRNTS
		CALL	MON_GETKEY
		CP		64H
		JR		Z,STMD4
		INC		HL
		DEC		B
		JR		NZ,STMD0

		LD		HL,(SADRS)
		LD		B,08H
STMD2:	LD		A,(HL)
		CP		10H
		JR		NC,STMD8
		LD		A,20H
STMD8:	CALL	ADCN
		CALL	DISPCH
		CALL	MON_GETKEY
		CP		64H
		JR		Z,STMD4
		INC		HL
		DEC		B
		JR		NZ,STMD2

		LD		(SADRS),HL
		CALL	LETLN

		DEC		C
		JR		NZ,STMD7

		LD		DE,MSG_AD2
		CALL	MON_MESSAGE
		CALL	LETLN
		CALL	LETLN
STMD3:	CALL	MON_GETKEY
		CP		00H
		JR		Z,STMD3
		CP		64H
		JR		Z,STMD4
		CP		42H
		JR		NZ,STMD5
		LD		HL,(SADRS)
		LD		DE,0100H
		SBC		HL,DE
		LD		(SADRS),HL
STMD5:	JP		STMD6
STMD4:	JP		MON




; Routine: STMW
; Purpose: Memory write from ASCII hex data in command buffer into memory at HL.
; Inputs: HL target, command text parsed by TWOHEX/HLHEX
; Outputs: writes memory, then prompts for file name to store via GETL
; Clobbers: A, HL, DE
STMW:	INC		DE
		INC		DE
		CALL	HLHEX
		JP		C,STSV1

		INC		DE
		INC		DE
		INC		DE
		INC		DE
STSP1:	LD		A,(DE)
		CP		0DH
		JR		Z,STMW9
		CP		20H
		JR		NZ,STMW1
		INC		DE
		JR		STSP1

STMW1:
		CALL	TWOHEX
		JR		C,STMW8
		LD		(HL),A
		INC		HL

STSP2:	LD		A,(DE)
		CP		0DH
		JR		Z,STMW8
		CP		20H
		JR		NZ,STMW1
		INC		DE
		JR		STSP2

STMW8:
		LD		DE,MSG_FDW
		CALL	MON_MESSAGE
		CALL	PRTWRD
		CALL	PRNTS
		LD		DE,LBUF
		CALL	GETL
		LD		DE,LBUF
		LD		A,(DE)
		CP		1BH
		JR		Z,STMW9
		LD		DE,LBUF+3
		JR		STMW
STMW9:	JP		MON




; Routine: STMZ
; Purpose: Apply MZ-700 monitor patch: copy code blocks and install monitor entries.
; Inputs: embedded tables STMZ2/STMZ3 hold addresses and entry points
; Outputs: installs hooks into monitor, prints MSG_ST and jumps to monitor
; Clobbers: A, HL, DE, BC
STMZ:	DI
		LD		HL,0000H
		LD		DE,2000H
		LD		BC,1000H
		LDIR
		OUT		(0E0H),A
		LD		HL,2000H
		LD		DE,0000H
		LD		BC,1000H
		LDIR
		LD		HL,STMZ2
		LD		DE,STMZ3
		LD		B,0FH
STMZ1:	PUSH	BC
		LD		C,(HL)
		INC		HL
		LD		B,(HL)
		LD		A,(DE)
		LD		(BC),A
		POP		BC
		INC		DE
		INC		HL
		DEC		B
		JR		NZ,STMZ1
		LD		HL,00ADH
		LD		A,(HL)
		CP		0CDH
		JP		NZ,0000H
		LD		DE,MSG_ST
		CALL	MON_MESSAGE
		CALL	LETLN
		JP		MONITOR_700

STMZ2:	DW		0437H,0438H,0439H
		DW		0476H,0477H,0478H
		DW		04D9H,04DAH,04DBH
		DW		04F9H,04FAH,04FBH
		DW		0589H,058AH,058BH

STMZ3:	DB		0C3H
		DW		ENT1
		DB		0C3H
		DW		ENT2
		DB		0C3H
		DW		ENT3
		DB		0C3H
		DW		ENT4
		DB		0C3H
		DW		ENT5



; Routine: STURA
; Purpose: Enable MZ-700 RAM mode and jump to patched monitor if present.
; Inputs: none
; Outputs: toggles RAM via port 0E0h, checks monitor signature at 00ADh
; Clobbers: A, HL, DE
STURA:	OUT		(0E0H),A
		LD		HL,00ADH
		LD		A,(HL)
		CP		0CDH
		JP		NZ,0000H
		LD		DE,MSG_ST
		CALL	MON_MESSAGE
		CALL	LETLN
		JP		MONITOR_700




Z80_TO_PICO_DATA    EQU 0FFFAh
Z80_TO_PICO_FLAG    EQU 0FFFBh

PICO_TO_Z80_DATA    EQU 0FFFCh
PICO_TO_Z80_FLAG    EQU 0FFFDh

; NOTE - IOREQ vs MREQ (worth revisiting):
; RCVBYTE/SNDBYTE below talk to these four addresses purely with
; `LD A,(nn)`/`LD (nn),A`, i.e. every handshake byte is a Z80 *memory* access
; (MREQ), never an IOREQ - the PIO side (xb_if.pio) samples NMREQ/
; NIOREQ but doesn't currently gate on either, so it can't tell the two apart
; anyway. Four scattered 16-bit addresses (0xFCF0/0xFDF2/0xFEF4/0xFFF6) also
; have to live inside the Z80's normal 64K memory map, so real RAM/ROM must
; carefully avoid them, and the Pico side needs a full 64K-entry shadow table
; (_eb_memory, see xb_if.h) just to decode which of these few
; addresses is being hit.
;
; Re-doing this handshake with IN/OUT to a handful of 8-bit I/O ports instead
; would: (1) let the PIO qualify on NIOREQ and decode only A0-A7, freeing the
; entire memory map for real RAM with no collision risk, (2) shrink the
; Pico-side address table from 64K entries to <=256, and (3) make IN/OUT
; slightly cheaper on the Z80 than the equivalent LD (nn) forms. It's a
; bigger change (new PIO gating logic + rewritten RCVBYTE/SNDBYTE using
; IN A,(n)/OUT (n),A), but worth it if this ROM is being revisited.

COMMS_INIT:

        ; z80 empties first, then expects pico to empty
        	
		; Reset the send/receive flags so both sides see an empty mailbox.
		ld a,0
		ld (Z80_TO_PICO_FLAG),a

		; wait for pico mailbox to be empty
WAIT_EMPTY_PICO:
		ld a, (PICO_TO_Z80_FLAG)
		or a
		jr nz, WAIT_EMPTY_PICO	
		RET


; Routine: RCVBYTE
; Purpose: Low-level device receive byte routine. Blocks until device signals
;          a byte available, reads DATA, clears the receive flag, returns A.
; Inputs: none (polls mailbox flag)
; Outputs: A = received byte; mailbox cleared
; Clobbers: A

;---------------------------------------
; RECEIVE_FROM_PICO
;---------------------------------------
RCVBYTE:

	PUSH BC
WAIT_DATA:
	; NOTE: If there is a delay in the pico SNDBYTE it may cause this to hang
    LD A,(PICO_TO_Z80_FLAG)

	; Hold until mailbox flag is set
    OR A
    JR Z, WAIT_DATA

RCV_READY:
    LD A,(PICO_TO_Z80_DATA)
	LD C,A

	; clear the receive flag
    LD A,0
    LD (PICO_TO_Z80_FLAG),A
	LD A,C

	POP BC

    RET


; Routine: SNDBYTE
; Purpose: Low-level device send byte routine. Writes DATA and sets the send flag.
; Inputs: A = byte to send
; Outputs: writes DATA and sets send flag; returns when mailbox was empty
; Clobbers: A
SNDBYTE:

	PUSH BC
	LD C, A

WAIT_EMPTY:
  
	; NOTE: If there is a delay in the pico RCVBYTE it may cause this to hang
	LD A,(Z80_TO_PICO_FLAG)

	; Hold while mailbox is full
    OR A
    JR NZ,WAIT_EMPTY

SND_READY:

	LD A,C
    LD (Z80_TO_PICO_DATA),A

	; indicate message in the mailbox
    LD A,1
    LD (Z80_TO_PICO_FLAG),A
	POP BC

    RET




; Routine: STFN
; Purpose: Parse and skip name field from command buffer (advances DE to name end)
; Inputs: DE points into command text where name begins
; Outputs: returns with HL set to name start (via EX DE,HL) on success
; Clobbers: A, DE, HL
STFN:	PUSH	AF
STFN1:	INC		DE
		LD		A,(DE)
		CP		20H
		JR		Z,STFN1
		CP		30H
		JP		C,STSV2
		EX		DE,HL
		POP		AF
		RET



; Routine: STCD
; Purpose: Send a single command byte (A) to device and wait for ACK via RCVBYTE.
; Inputs: A contains command code
; Outputs: returns with ACK in A from device
; Clobbers: A
STCD:	CALL	SNDBYTE
		CALL	RCVBYTE
		RET


; Routine: STFS
; Purpose: Send a filename buffer (HL) to device (20 bytes + CR) and wait ACK.
; Inputs: HL points to filename buffer (20 bytes expected)
; Outputs: issues SNDBYTE for each byte and RCVBYTE for ACK
; Clobbers: A, B, HL
STFS:	LD		B,20H
STFS1:	LD		A,(HL)
		CALL	SNDBYTE
		INC		HL
		DEC		B
		JR		NZ,STFS1
		LD		A,0DH
		CALL	SNDBYTE
		CALL	RCVBYTE
		RET



; Routine: STCMD
; Purpose: High-level command sender: obtains filename, sends command code,
;          verifies ACK, and transmits filename via STFS.
; Inputs: A contains command code, DE points into command buffer
; Outputs: returns with status in A (0=OK) or jumps to SVER0 on error
; Clobbers: A, HL, DE
STCMD:	CALL	STFN
		PUSH	HL
		CALL	STCD
		POP		HL
		AND		A
		JP		NZ,SVER0
		CALL	STFS
		AND		A
		JP		NZ,SVER0
		RET


MSG_LD:
		DB		16H
		DB		'LOADING '
		DB		0DH

WRMSG:
		DB		'WRITING '
		DB		0DH

MSG_SV:
		DB		'SAVE FINISHED!'
		DB		0DH

MSG_AS:
		DB		'ASTART FINISHED!'
		DB		0DH

MSG_ST:
		DB		'PATCHED MONITOR START!'
		DB		0DH

MSG_AD:
		DB		'ADDRESS FAILED!'
		DB		0DH

MSG_FNAME:
		DB		'FILE NAME FAILED!'
		DB		0DH

MSG_CMD:
		DB		'COMMAND FAILED!'
		DB		0DH

MSG_F0:
		DB		'SD-CARD INIT ERROR'
		DB		0DH

MSG_F1:
		DB		'FILE NOT FOUND'
		DB		0DH



MSG_F3:
		DB		'FILE EXISTS'
		DB		0DH

MSG_KEY1:
		DB		'NEXT:ANY BACK:B BREAK:'
		DB		0DH
MSG_KEY2:
		DB		' OR SHIFT+BREAK'
		DB		0DH

MSG_DELQ:
		DB		'FILE DELETE?(Y:OK N:CANCEL)'
		DB		0DH

MSG_DELY:
		DB		'DELETE OK'
		DB		0DH

MSG_DELN:
		DB		'DELETE CANCELLED'
		DB		0DH

MSG_REN:
		DB		'NEW NAME:                            '
		DB		0DH

MSG_DNAME:
		DB		'SD FILE:'
MSG_DNAMEEND:
		DB		'                            '
		DB		0DH

MSG_RENY:
		DB		'RENAME OK'
		DB		0DH

MSG_AD1:
		DB		'ADRS +0 +1 +2 +3 +4 +5 +6 +7 01234567'
		DB		0DH

MSG_AD2:
		DB		'NEXT:ANY BACK:B BREAK:SHIFT+BREAK'
		DB		0DH

MSG_CPY:
		DB		'COPY OK'
		DB		0DH

MSG_FDW:
		DB		'*FDW '
		DB		0DH

MSG99:
		DB		' ERROR'
		DB		0DH

DEFNAME:
		DB		'0000'
		DB		0DH
NEND:

DEFDIR:
		DB		'*FD  '
DEND:


; Routine: MSHED
; Purpose: MONITOR save header routine - invoked from 0436H MONITOR save.
;          Receives filename from command buffer, formats, and sends header block.
; Inputs: IBUFE contains 128-byte header, FNAME has file name
; Outputs: sends header via SNDBYTE/HDSEND and receives ACK
; Clobbers: A, HL, B, DE
MSHED:
		DI
		PUSH	DE
		PUSH	BC
		PUSH	HL

		; BASIC always resets FNAME to a bare CR before parsing the SAVE
		; argument, then overwrites it with the literal from SAVE "NAME" if one
		; was given (see BASIC_SP_5025_FD.asm around 29BFH/29EFH). A leading CR
		; here means bare SAVE with no name - fail instead of writing a file
		; with an empty name.
		LD		A,(FNAME)
		CP		0DH
		JP		Z,MSHNONAME

		LD		A,91H
		CALL	MCMD
		AND		A
		JP		NZ,MERR

        LD      B,11H              ; prepare to scan 17 bytes backward (filename max length)
        LD      HL,FNAME+10H       ; point HL to last filename character
        LD      A,0DH              ; CR terminator
        LD      (HL),A             ; ensure filename ends with CR

MSH0:   LD      A,(HL)             ; read current character
        CP      0DH                ; is it already CR?
        JR      Z,MSH1             ; yes → go trim backwards
        CP      20H                ; is it a space?
        JR      NZ,MSH2            ; no → stop trimming
        LD      A,0DH              ; replace trailing space with CR
        LD      (HL),A             ; write CR

MSH1:   DEC     HL                 ; move left one character
        DEC     B                  ; decrement counter
        JR      NZ,MSH0            ; continue trimming until B=0

MSH2:   CALL    LETLN              ; output newline (monitor routine)
        LD      DE,WRMSG           ; DE → "WRITING" message
        CALL    MON_MESSAGE              ; print message
        LD      DE,FNAME           ; DE → filename
        CALL    MON_MESSAGE              ; print filename

        LD      HL,IBUFE           ; HL → tape header buffer
        LD      B,80H              ; send 128 bytes

MSH3:   LD      A,(HL)             ; get next header byte
        CALL    SNDBYTE            ; send byte to tape
        INC     HL                 ; next byte
        DEC     B                  ; count down
        JR      NZ,MSH3            ; loop until 128 bytes sent

        CALL    RCVBYTE            ; receive checksum byte
        AND     A                  ; test if zero (OK)
        JP      NZ,MERR            ; non‑zero → checksum error

        JP      MRET               ; return to monitor

; No filename was given to SAVE - report an error (via the same path MERR
; uses) instead of writing a file with a blank name.
MSHNONAME:
        LD      DE,MSG_FNAME
        CALL    MON_MESSAGE
        CALL    LETLN
        POP     HL
        POP     BC
        POP     DE
        LD      A,02H
        SCF
        RET




; Routine: MSDAT
; Purpose: MONITOR save data routine - invoked from 0475H MONITOR save.
;          Sends data block contents (FSIZE bytes from SADRS) to device.
; Inputs: FSIZE contains byte count, SADRS points to data start
; Outputs: streams data bytes via SNDBYTE until FSIZE exhausted
; Clobbers: A, HL, DE
MSDAT:
		DI
		PUSH	DE
		PUSH	BC
		PUSH	HL
		LD		A,92H
		CALL	MCMD
		AND		A
		JP		NZ,MERR

		LD		HL,FSIZE
		LD		A,(HL)
		CALL	SNDBYTE
		INC		HL
		LD		A,(HL)
		CALL	SNDBYTE

		CALL	RCVBYTE
		AND		A
		JP		NZ,MERR

		LD		DE,(FSIZE)
		LD		HL,(SADRS)
MSD1:	LD		A,(HL)
		CALL	SNDBYTE
		DEC		DE
		LD		A,D
		OR		E
		INC		HL
		JR		NZ,MSD1

		JP		MRET



; Routine: MLHED
; Purpose: MONITOR load header routine - invoked from 04D8H MONITOR load.
;          Prompts user for file name and processes header/command options.
; Inputs: prompts user via MSGPR/GETL, supports FDL directory listing
; Outputs: stores data in IBUFE, handles special FDL command and directory flow
; Clobbers: A, HL, B, DE
MLHED:
		DI
		PUSH	DE
		PUSH	BC
		PUSH	HL


		LD		A,00H
		LD		DE,0000H
		CALL	TIMST

		LD		B,08H
		LD		DE,LBUF
		LD		A,0DH
MLH0:	LD		(DE),A
		INC		DE
		DEC		B
		JR		NZ,MLH0

		LD		A,03H
		LD		(CURSOR),A
		LD		A,0C7H
		CALL	DPCT
		CALL	DPCT
		CALL	DPCT
; MLH6 used to print "SD FILE:" and CALL GETL, interactively asking the user
; to type a name every time this ran - including when BASIC got here via
; LOAD "NAME", which just hung waiting on a keypress BASIC could never send.
; BASIC parses the LOAD argument before calling here (see BASIC_SP_5025_FD.asm
; around 2A3FH-2A63H) and leaves the result at two fixed BASIC-workspace
; locations instead: (458EH) is 0 for a bare LOAD with no name, non-zero if a
; name was given; when non-zero, (458FH) points at the requested name's text
; (quote- or CR-terminated). Reading those directly instead of prompting means
; a plain monitor "L" with no BASIC running (the only other caller of this
; entry, via the STMZ monitor patch) now also needs a name up front rather
; than being asked interactively - out of scope for the LOAD/SAVE "NAME"
; behaviour this was changed for, but worth knowing if "L" alone regresses.
MLH6:
		LD		A,(458EH)
		AND		A
		JP		Z,MLHNONAME

		LD		HL,(458FH)
		LD		DE,MBUF+9
		LD		B,10H              ; BASIC already rejects names over 16 chars
MLH7:	LD		A,(HL)
		CP		22H                ; closing quote ends the literal
		JR		Z,MLH7E
		CP		0DH
		JR		Z,MLH7E
		CP		20H
		JR		C,MLH7E            ; control byte/token also ends it
		LD		(DE),A
		INC		HL
		INC		DE
		DJNZ	MLH7
MLH7E:	LD		A,0DH
		LD		(DE),A

		LD		DE,MBUF+9
		CALL	MON_MESSAGE
		CALL	LETLN

		LD		DE,MBUF+9

		LD		A,93H
		CALL	MCMD
		AND		A
		JP		NZ,MERR

MLH1:	LD		A,(DE)
		CP		20H
		JR		NZ,MLH2
		INC		DE
		JR		MLH1

MLH2:	LD		B,20H
MLH4:	LD		A,(DE)
		CALL	SNDBYTE
		INC		DE
		DEC		B
		JR		NZ,MLH4
		LD		A,0DH
		CALL	SNDBYTE

		CALL	RCVBYTE
		AND		A
		JP		NZ,MERR

		CALL	RCVBYTE
		AND		A
		JP		NZ,MERR

		LD		HL,IBUFE
		LD		B,80H
MLH5:	CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		DEC		B
		JR		NZ,MLH5

		CALL	RCVBYTE
		AND		A
		JP		NZ,MERR

		; Force FNAME to the name we actually requested, rather than trusting
		; whatever name happens to be embedded in the file's own header, so
		; BASIC's post-load name compare (BASIC_SP_5025_FD.asm around 2A86H)
		; always matches on the first try instead of calling back into MLHED
		; looking for "the next file".
		LD		HL,MBUF+9
		LD		DE,FNAME
		LD		B,11H
MLH9:	LD		A,(HL)
		LD		(DE),A
		INC		HL
		INC		DE
		DJNZ	MLH9

		JP		MRET

; No filename was given to LOAD - report an error (via the same path MERR
; uses) instead of blocking on a keyboard prompt BASIC has no way to answer.
MLHNONAME:
		LD		DE,MSG_FNAME
		CALL	MON_MESSAGE
		CALL	LETLN
		POP		HL
		POP		BC
		POP		DE
		LD		A,02H
		SCF
		RET



; Routine: MLDAT
; Purpose: MONITOR load data routine - invoked from MLHED load sequence.
;          Receives file data block from device into memory via DBRCV.
; Inputs: protocol-driven, FSIZE and SADRS prepared by MLHED
; Outputs: receives data via DBRCV, reports result
; Clobbers: A, HL, B, DE
MLDAT:
		DI
		PUSH	DE
		PUSH	BC
		PUSH	HL
		LD		A,94H
		CALL	MCMD
		AND		A
		JP		NZ,MERR

		CALL	RCVBYTE
		AND		A
		JP		NZ,MERR

		CALL	RCVBYTE
		AND		A
		JP		NZ,MERR

		LD		DE,FSIZE
		LD		A,(DE)
		CALL	SNDBYTE
		INC		DE
		LD		A,(DE)
		CALL	SNDBYTE
		CALL	DBRCV

		CALL	RCVBYTE
		AND		A
		JP		NZ,MERR

		JR		MRET



; Routine: MVRFY
; Purpose: MONITOR verify routine - stub/placeholder for verify operation.
;          Currently minimal implementation; sets zero flag and returns.
; Inputs: none
; Outputs: A cleared (zero flag set)
; Clobbers: A
MVRFY:
		; DI
		XOR		A


		RET



MCMD:


		CALL	SNDBYTE
		CALL	RCVBYTE
		RET



MRET:	POP		HL
		POP		BC
		POP		DE
		XOR		A


		RET



; 0F0H means SD-CARD INITIALIZE ERROR
; 0F1H means NOT FIND FILE

MERR:
		CP		0F0H
		JR		NZ,MERR3
		LD		DE,MSG_F0 ; SD-CARD INITIALIZE ERROR
		JR		MERRMSG




MERR3:	CP		0F1H
		JR		NZ,MERR99
		LD		DE,MSG_F1 ; NOT FIND FILE
		JR		MERRMSG

MERR99:	CALL	PRTBYT
		LD		DE,MSG99 ; ' ERROR'

MERRMSG:
		CALL	MON_MESSAGE
		CALL	LETLN
		POP		HL
		POP		BC
		POP		DE
		LD		A,02H
		SCF


		RET



MENU:

		; zero the vars and put a sentinel value in CACHED_PAGE to force a page load
		XOR     A ;  A = 0
		LD      (PAGE_VAR),A
		LD      (CACHED_COUNT),A
		LD      (CURSOR_VAR),A
		LD      A,0FFH
		LD      (CACHED_PAGE),A
		CALL    DRAW_SCREEN

MAIN_LOOP:
		CALL    MON_GETKEY
		AND     5FH
		CP      'W'
		JR      Z,DO_UP
		CP      'S'
		JR      Z,DO_DOWN
		CP      'A'
		JR      Z,DO_LEFT
		CP      'D'
		JR      Z,DO_RIGHT
		CP      'O'
		JR      Z,DO_OPEN
		CP      0DH             ; ENTER loads the highlighted file
		JR      Z,DO_OPEN
		CP      'Q'
		JR      Z,DO_QUIT
		JR      MAIN_LOOP

DO_UP:
            CALL    MOVE_UP
            JR      DEBOUNCE

DO_DOWN:
            CALL    MOVE_DOWN
            JR      DEBOUNCE

DO_LEFT:
            CALL    PAGE_LEFT
            JR      DEBOUNCE

DO_RIGHT:
            CALL    PAGE_RIGHT
            JR      DEBOUNCE

DO_OPEN:
            CALL    OPEN_SELECTED
            JR      DEBOUNCE
DO_QUIT:
			JP MON

; MON_GETKEY reports whatever key is down at the instant it's polled, with no
; repeat-rate limiting, so MAIN_LOOP's tight poll could see the same physical
; keypress several times before the key is released. Wait for MON_GETKEY to
; go back to 0 (key released) before returning to the poll loop so one
; keypress always produces exactly one action.
DEBOUNCE:
            CALL    MON_GETKEY
            AND     A
            JR      NZ,DEBOUNCE
            JR      MAIN_LOOP

DEBG:
		LD   DE, MSG_LD1
        CALL MON_MESSAGE
        CALL NEWLIN
        LD   DE, MSG_LD2
        CALL MON_MESSAGE
		CALL LETLN

		LD   A, (MSG_LD2)
		CALL PRTBYT
		CALL NEWLIN

		LD   A, 0
		INC A
		INC A
		LD  (MSG_LD2), A
		INC A
		INC A
		LD   A, (MSG_LD2)
		INC A
		INC A

		CALL PRTBYT
		CALL NEWLIN

        JP   MON


CURSORHOME		EQU		16H

MSG_LD1: DB   CURSORHOME, 'HELLO ANDREW AND KAREN', 0DH
MSG_LD2: DB   'THIS TEXT IS FOR TESTING', 0DH
MSG_BYT: DB   0DH


; Layer 1: copy a fetched record into the page buffer
COPY_ENTRY_TO_PAGE_BUFFER:
            ; HL = destination in PAGE_BUFFER
            ; WORKING_STORE already contains the fetched 32-byte record
            PUSH    BC
            PUSH    DE
            LD      DE,WORKING_STORE
            LD      B,32
COPY_ENTRY_LOOP:
            LD      A,(DE)
            LD      (HL),A
            INC     DE
            INC     HL
            DJNZ    COPY_ENTRY_LOOP
            POP     DE
            POP     BC
            RET

; Layer 2: GET_PAGE
GET_PAGE:
            ; A=requested page, returns HL->PAGE_BUFFER and A=count
            LD      E,A
            LD      A,(CACHED_PAGE)
            CP      E
            JR      Z,GET_PAGE_HIT ; same cached page, no need to rebuild it
            CALL    GET_FILE_COUNT

            LD      C,A
            LD      H,00H
            LD      L,E
            ADD     HL,HL
            ADD     HL,HL
            ADD     HL,HL
            ADD     HL,HL
            LD      A,L  ; HL is page number * 16
            LD      D,A ; D therefore, is the first entry of the THIS page
            LD      HL,PAGE_BUFFER
            LD      B,ROWS_PER_PAGE 
            XOR     A
            LD      (CACHED_COUNT),A ; reset set cached count to 0
GET_PAGE_LOOP:  ; iterate through ROWS_PER_PAGE entries
            LD      A,D
            CP      C
            JR      NC,GET_PAGE_DONE ; if TOTAL ENTIRES == CURRENT ENTRY OF THIS PAGE then done (overflowing end of list)
            LD      A,D
            CALL    GET_FILE_AT_INDEX ; get current entry

            ; HL holds the current position in PAGE_BUFFER
            CALL    COPY_ENTRY_TO_PAGE_BUFFER ; copy entry to page - this moves forward on the page buffer

            INC     D ; move to next entry

            LD      A,(CACHED_COUNT)
            INC     A
            LD      (CACHED_COUNT),A ; count of files on this page is cached

            DJNZ    GET_PAGE_LOOP ; decrement B and loop
GET_PAGE_DONE:
            LD      A,E
            LD      (CACHED_PAGE),A ; remember the current page id
            JR      GET_PAGE_RET
GET_PAGE_HIT:
            LD      A,(CACHED_COUNT)

GET_PAGE_RET:
            LD      HL,PAGE_BUFFER
            RET

; Layer 3: UI
MOVE_UP:
            LD      A,(CURSOR_VAR)
            OR      A 
            RET     Z ; return if CURSOR_VAR = 0
            DEC     A
            CALL CLEAR_ARROW
            LD      (CURSOR_VAR),A
            CALL    DRAW_ARROW
            RET

MOVE_DOWN:
            LD      A,(CACHED_COUNT)
            DEC A
            LD      C,A
            LD      A,(CURSOR_VAR)
            CP      C
            JR      Z,DOWN_DONE ; return if CURSOR_VAR = CACHED_COUNT
            INC     A
            CALL CLEAR_ARROW
            LD      (CURSOR_VAR),A
            CALL    DRAW_ARROW
DOWN_DONE:
            RET

PAGE_LEFT:
            LD      A,(PAGE_VAR)
            OR      A
            RET     Z ; return if PAGE_VAR = 0
            DEC     A
            LD      (PAGE_VAR),A
            CALL    DRAW_SCREEN
            RET

PAGE_RIGHT:
            LD      A,(PAGE_VAR)
            INC     A
            CALL    GET_PAGE ; page count can change if FILE ENTRIES are modified
            LD      A,(CACHED_COUNT)
            OR      A
            JR      NZ,PAGE_RIGHT_GO ; next page has entries - advance to it
            ; next page is empty - the speculative GET_PAGE above just clobbered
            ; CACHED_PAGE/CACHED_COUNT, so re-fetch the page still on screen
            LD      A,(PAGE_VAR)
            CALL    GET_PAGE
            RET
PAGE_RIGHT_GO:
            LD      A,(PAGE_VAR)
            INC     A
            LD      (PAGE_VAR),A
            CALL    DRAW_SCREEN
            RET

DRAW_SCREEN:
            CALL    CLEAR_SCREEN
            LD      A,(PAGE_VAR)
            CALL    GET_PAGE


            LD      HL,TITLE_MSG
            LD D,00H // row 0
            LD E,0aH // col 2
            CALL    PRINT_STR
            LD      HL,HEADER_MSG
            LD D,01H
            LD E,01H
            CALL    PRINT_STR
            LD      HL,FOOTER_MSG
            LD D,18H
            LD E,01H
            CALL    PRINT_STR


            CALL DRAW_PAGE

            RET

DRAW_ARROW:
            PUSH AF
            LD      DE, ARROW_CHAR
            jr      DRAW_ARROW_CHAR
CLEAR_ARROW:
            PUSH AF
            LD      DE, SPACE_CHAR
DRAW_ARROW_CHAR:
            LD      H, ROW_START  ; screen row
            LD      A, (CURSOR_VAR)
            ADD     A,H
            LD      H,A 
            LD      L,00H          ; screen column
            LD (CURSOR),HL
            CALL    MON_MESSAGE
            POP AF
            ret


DRAW_PAGE:
            ; draw the PAGE BUFFER - row by row
            LD      A,(CACHED_COUNT)
            OR      A
            JR      Z,DRAW_DONE    ; nothing to draw
            LD      C,A            ; C = number of rows to draw

            LD      B, ROW_START          ; screen row start for the first entry
            LD      HL,PAGE_BUFFER

DRAW_ROW:
            LD      D,B            ; screen row
            LD      E,02H          ; screen column
            CALL    PRINT_STR

            DEC     C
            JR      Z,DRAW_DONE

            INC     B              ; next screen row
            LD      DE,32          ; advance to next 32-byte record in the page buffer
            ADD     HL,DE
            JR      DRAW_ROW

DRAW_DONE:
            CALL DRAW_ARROW
            RET

CLEAR_SCREEN:
            LD A,CURSORHOME
            CALL MON_VIDEO
            XOR     A
            LD      (CURSOR_VAR),A ; put cursor to position 0
            RET

PRINT_STR:
; HL is string
; D = screen row
; E = screen column
            PUSH DE
            PUSH HL
            LD (CURSOR), DE ; use DE for string row/col
            LD DE, HL ; put address of string into DR
            CALL MON_STRING
            POP HL
            POP DE
            RET


OPEN_SELECTED:
            ; Run the highlighted file: absolute index = PAGE_VAR*ROWS_PER_PAGE + CURSOR_VAR
            LD      A,(CACHED_COUNT)
            OR      A
            RET     Z              ; nothing on this page to open

            LD      A,(PAGE_VAR)
            LD      L,A
            LD      H,00H
            ADD     HL,HL
            ADD     HL,HL
            ADD     HL,HL
            ADD     HL,HL          ; HL = PAGE_VAR * ROWS_PER_PAGE
            LD      A,(CURSOR_VAR)
            ADD     A,L
            LD      E,A            ; E = absolute file index to load
            JP      SDFILE         ; loads header/data and jumps into the program - does not return here

ROWBUF:     DEFS    18      ; 1 marker + 16 chars + CR terminator

TITLE_MSG:
            DB      'MZ80K FILE BROWSER',0DH
HEADER_MSG:
            DB      'NAME TYPE SIZE LOAD EXEC',0DH
FOOTER_MSG:
            DB      'W/S MOVE  A/D PAGE  O/CR RUN',0DH
ARROW_CHAR:
            DB      0C6H,0DH
SPACE_CHAR:
            DB      ' ',0DH


		END

; NOTES_AT_END:
; - Several loops wait for device handshakes; consider adding timeout handling
; - Inline protocol status constants could be grouped and documented earlier
; - Many message strings are defined; verify lengths and trailing CR usage
; - Consider centralizing SD error handling (SVERR/ERRMSG flows) to reduce duplication
; - Remove unused labels or consolidate similar routines (e.g., STSV1 handling)
; - Ensure register push/pop pairs are balanced across all call paths
; - Consider replacing blocking waits with non-blocking or timeout-based retries
