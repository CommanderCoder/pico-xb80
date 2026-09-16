; ============================================================================
; Sharp MZ-80K BASIC - "SP-6015 EXT / 80K" variant (adds SD/FD disk support)
;
; Loaded at 1200H; the tape/disk header's designated execution address is
; 21F7H (see label ENTRY below) - 1200H-21F6H is a small block of
; utility trampolines/data that is only reached via individual CALLs, not by
; falling into it from the top.
;
; This listing was regenerated from a raw byte-accurate disassembly dump by:
;   - re-decoding every instruction with a Z80 opcode table (z80dis) instead of
;     trusting the original tool's text output, so operand/byte-length bugs in
;     the dump itself are gone;
;   - resolving stray-byte misalignments (places where a CALL or JP elsewhere
;     targets an address that fell mid-instruction in the naive linear decode)
;     by re-synchronising from the true target and emitting the orphan byte(s)
;     as DB - see the 'stray byte(s)' comments;
;   - extracting the BASIC keyword/token table (KWTABLE) as text DB data instead
;     of bogus opcodes;
;   - inventing SUB_xxxx labels for every address called from elsewhere, LOC_xxxx
;     for addresses only ever reached by JP/JR/DJNZ, and DATA_xxxx for the more
;     heavily-referenced in-ROM data cells;
;   - naming monitor ROM/workarea calls (addresses < 1200H) using the EQUs already
;     established in this project's "Z80 Asm/FD_rom1.s", extended with names from
;     the published SP-1002 monitor subprogram reference where FD_rom1.s had none
;     (unnamed ones are MON_xxxx);
;   - naming BASIC's own RAM workspace variables (addresses > 5FFFH) WS_xxxx, with
;     a handful of the hottest ones given a *guessed* semantic name - flagged
;     'guessed' below since there is no surviving source to confirm them.
;
; A small number of addresses (flagged 'UNRESOLVED ALIGNMENT' below) are targeted
; from elsewhere but still don't land on an instruction boundary in this listing;
; automatic re-synchronisation for those was ambiguous (it could plausibly land on
; more than one later boundary), so they were left as-is rather than guessed.
; ============================================================================

; ---------------------------------------------------------------------------
; Monitor ROM / workarea entry points used by this ROM (addresses < 1200H)
; ---------------------------------------------------------------------------
MONIT         EQU 0000H   ; cold start entry (power-on / reset)
GETL          EQU 0003H   ; get a line from keyboard into buffer (line input routine)
LETLN         EQU 0006H   ; output new line
NEWLIN        EQU 0009H   ; output CR/LF but not if already at start of a line
TABUL         EQU 000FH   ; tab: pad with spaces to next stop
MON_VIDEO     EQU 0012H   ; video driver - output one character from A
MON_MESSAGE   EQU 0015H   ; output raw text, terminated by 0DH
MON_GETKEY    EQU 001BH   ; get a single key, no echo
BRKEY         EQU 001EH   ; test SHIFT+BREAK
WOPEN         EQU 0021H   ; write tape header
WRITE         EQU 0024H   ; write data to cassette tape
ROPEN         EQU 0027H   ; read next tape header
READ          EQU 002AH   ; read tape file data
MELDY         EQU 0030H   ; play a music sequence
TIMST         EQU 0033H   ; timer start / read 8253 tick
TIMRD         EQU 003BH   ; read real-time clock
BELL          EQU 003EH   ; short beep
XTEMP         EQU 0041H   ; set music tempo
MON_004E      EQU 004EH   ; unnamed monitor ROM / workarea routine
MON_0054      EQU 0054H   ; unnamed monitor ROM / workarea routine
MON_0058      EQU 0058H   ; unnamed monitor ROM / workarea routine
MON_00E1      EQU 00E1H   ; unnamed monitor ROM / workarea routine
MON_0131      EQU 0131H   ; unnamed monitor ROM / workarea routine
CMPSTR        EQU 0180H   ; compare two strings (DE/HL, length B)
MON_0625      EQU 0625H   ; unnamed monitor ROM / workarea routine
MON_0823      EQU 0823H   ; unnamed monitor ROM / workarea routine
GETKYD        EQU 08CAH   ; read keyboard char in display-code form
PRTCH         EQU 0946H   ; display ASCII char from C
MON_09EF      EQU 09EFH   ; unnamed monitor ROM / workarea routine
MON_09FF      EQU 09FFH   ; unnamed monitor ROM / workarea routine
MON_0A0F      EQU 0A0FH   ; unnamed monitor ROM / workarea routine
MON_0A3D      EQU 0A3DH   ; unnamed monitor ROM / workarea address
MON_0B6B      EQU 0B6BH   ; unnamed monitor ROM / workarea address
ADCN          EQU 0BB9H   ; monitor helper @0BB9 (BCD/hex adjust)
MON_0C41      EQU 0C41H   ; unnamed monitor ROM / workarea routine
SNCV          EQU 0DA6H   ; wait for video blanking
MON_0E32      EQU 0E32H   ; unnamed monitor ROM / workarea routine
MON_0E39      EQU 0E39H   ; unnamed monitor ROM / workarea routine
GETVAD        EQU 0FB1H   ; get cursor position (0-999) in HL
MON_1000      EQU 1000H   ; unnamed monitor ROM / workarea address
MON_1001      EQU 1001H   ; unnamed monitor ROM / workarea address
MON_1002      EQU 1002H   ; unnamed monitor ROM / workarea address
MON_1003      EQU 1003H   ; unnamed monitor ROM / workarea address
MON_1004      EQU 1004H   ; unnamed monitor ROM / workarea address
MON_1005      EQU 1005H   ; unnamed monitor ROM / workarea address
MON_1006      EQU 1006H   ; unnamed monitor ROM / workarea address
MON_1007      EQU 1007H   ; unnamed monitor ROM / workarea address
MON_1008      EQU 1008H   ; unnamed monitor ROM / workarea address
MON_1009      EQU 1009H   ; unnamed monitor ROM / workarea address
MON_100A      EQU 100AH   ; unnamed monitor ROM / workarea address
MON_100B      EQU 100BH   ; unnamed monitor ROM / workarea routine
MON_100E      EQU 100EH   ; unnamed monitor ROM / workarea address
MON_100F      EQU 100FH   ; unnamed monitor ROM / workarea address
MON_1101      EQU 1101H   ; unnamed monitor ROM / workarea address
EADRS         EQU 1102H   ; end address / file size in header
SADRS         EQU 1104H   ; start (load) address in header
MON_1162      EQU 1162H   ; unnamed monitor ROM / workarea address
MON_116E      EQU 116EH   ; unnamed monitor ROM / workarea address
MON_1170      EQU 1170H   ; unnamed monitor ROM / workarea address
CURSOR        EQU 1171H   ; cursor position, row/col
MON_1172      EQU 1172H   ; unnamed monitor ROM / workarea address
MON_118E      EQU 118EH   ; unnamed monitor ROM / workarea address
MON_118F      EQU 118FH   ; unnamed monitor ROM / workarea address
MON_1191      EQU 1191H   ; unnamed monitor ROM / workarea address
MON_1194      EQU 1194H   ; unnamed monitor ROM / workarea address
MON_119C      EQU 119CH   ; unnamed monitor ROM / workarea address
LBUF          EQU 11A3H   ; line input buffer

; ---------------------------------------------------------------------------
; BASIC RAM workspace variables used by this ROM (addresses > 5FFFH)
; names marked 'guessed' are inferred from usage only, not from any surviving
; source - treat them as a reading aid, not as fact.
; ---------------------------------------------------------------------------
WS_6055       EQU 6055H   ; referenced x2 - purpose not determined
WS_6057       EQU 6057H   ; guessed: work cell
WS_6059       EQU 6059H   ; referenced x2 - purpose not determined
WS_6163       EQU 6163H   ; referenced x5 - purpose not determined
WS_6165       EQU 6165H   ; guessed: work cell
WS_6167       EQU 6167H   ; referenced x5 - purpose not determined
WS_616E       EQU 616EH   ; referenced x1 - purpose not determined
WS_6170       EQU 6170H   ; referenced x3 - purpose not determined
WS_6173       EQU 6173H   ; referenced x2 - purpose not determined
WS_6174       EQU 6174H   ; referenced x1 - purpose not determined
WS_6179       EQU 6179H   ; referenced x4 - purpose not determined
WS_617A       EQU 617AH   ; referenced x3 - purpose not determined
WS_617C       EQU 617CH   ; referenced x1 - purpose not determined
WS_6180       EQU 6180H   ; referenced x5 - purpose not determined
WS_6182       EQU 6182H   ; referenced x6 - purpose not determined
WS_61B0       EQU 61B0H   ; referenced x1 - purpose not determined
WS_61B1       EQU 61B1H   ; referenced x3 - purpose not determined
WS_61B2       EQU 61B2H   ; referenced x2 - purpose not determined
WS_62B4       EQU 62B4H   ; referenced x3 - purpose not determined
WS_62B6       EQU 62B6H   ; referenced x4 - purpose not determined
WS_62B8       EQU 62B8H   ; referenced x1 - purpose not determined
WS_62B9       EQU 62B9H   ; guessed: interpreter work cell
WS_62BA       EQU 62BAH   ; guessed: interpreter work cell
WS_62BB       EQU 62BBH   ; guessed: interpreter work cell
WS_62BC       EQU 62BCH   ; referenced x12 - purpose not determined
WS_62BD       EQU 62BDH   ; referenced x2 - purpose not determined
WS_62C2       EQU 62C2H   ; referenced x3 - purpose not determined
WS_62C4       EQU 62C4H   ; referenced x3 - purpose not determined
VAR_PTR       EQU 62C6H   ; guessed: variable table pointer
WS_62C8       EQU 62C8H   ; referenced x4 - purpose not determined
WS_62CA       EQU 62CAH   ; referenced x5 - purpose not determined
WS_62CC       EQU 62CCH   ; referenced x4 - purpose not determined
WS_62CE       EQU 62CEH   ; guessed: interpreter work cell
WS_62D0       EQU 62D0H   ; referenced x3 - purpose not determined
WS_633A       EQU 633AH   ; referenced x1 - purpose not determined
WS_633C       EQU 633CH   ; referenced x6 - purpose not determined
WS_6344       EQU 6344H   ; referenced x2 - purpose not determined
WS_6356       EQU 6356H   ; referenced x1 - purpose not determined
WS_6358       EQU 6358H   ; referenced x2 - purpose not determined
WS_635A       EQU 635AH   ; referenced x5 - purpose not determined
WS_6360       EQU 6360H   ; referenced x1 - purpose not determined
WS_6366       EQU 6366H   ; referenced x1 - purpose not determined
WS_6368       EQU 6368H   ; referenced x4 - purpose not determined
FREE_PTR      EQU 636AH   ; guessed: free-memory / stack-limit pointer
WS_636C       EQU 636CH   ; referenced x5 - purpose not determined
STR_PTR       EQU 636EH   ; guessed: string-space pointer
ARRAY_PTR     EQU 6370H   ; guessed: array table pointer
WS_6516       EQU 6516H   ; referenced x2 - purpose not determined
WS_651D       EQU 651DH   ; referenced x1 - purpose not determined
WS_6523       EQU 6523H   ; referenced x1 - purpose not determined
CUR_LINE      EQU 6525H   ; guessed: current program line number
CUR_STMT      EQU 6527H   ; guessed: current statement / text pointer (heavily used)
WS_6529       EQU 6529H   ; referenced x2 - purpose not determined
WS_652C       EQU 652CH   ; referenced x1 - purpose not determined
WS_652E       EQU 652EH   ; referenced x1 - purpose not determined
WS_77AA       EQU 77AAH   ; referenced x1 - purpose not determined
WS_84E7       EQU 84E7H   ; referenced x1 - purpose not determined
WS_C312       EQU C312H   ; referenced x1 - purpose not determined
WS_C77B       EQU C77BH   ; referenced x1 - purpose not determined
WS_CD0D       EQU CD0DH   ; referenced x1 - purpose not determined
WS_CD24       EQU CD24H   ; referenced x1 - purpose not determined
WS_D2CD       EQU D2CDH   ; referenced x1 - purpose not determined
WS_E003       EQU E003H   ; referenced x3 - purpose not determined
WS_FEC5       EQU FEC5H   ; referenced x1 - purpose not determined
WS_FFFF       EQU FFFFH   ; referenced x1 - purpose not determined

; ---------------------------------------------------------------------------
; code
; ---------------------------------------------------------------------------

        ORG 1200H

        JP SUB_253E                 ; 1200  C3 3E 25
        DB CDH                      ; 1203  CD   (stray byte(s): disassembly boundary correction)
; --- SUB_1204: called from 15 places ---
SUB_1204:
        EXX                         ; 1204  D9
        LD BC,0005H                 ; 1205  01 05 00
        CALL SUB_1218               ; 1208  CD 18 12
        CALL SUB_1A58               ; 120B  CD 58 1A
        CALL SUB_296C               ; 120E  CD 6C 29
        CALL SUB_2AE0               ; 1211  CD E0 2A
SUB_1214:
        EXX                         ; 1214  D9
        LD BC,FFFBH                 ; 1215  01 FB FF
; --- SUB_1218: called from 3 places ---
SUB_1218:
        LD HL,(FREE_PTR)            ; 1218  2A 6A 63
        ADD HL,BC                   ; 121B  09
        LD (FREE_PTR),HL            ; 121C  22 6A 63
        EXX                         ; 121F  D9
        RET                         ; 1220  C9
; --- SUB_1221: called from 22 places ---
SUB_1221:
        CALL SUB_1204               ; 1221  CD 04 12
        LD A,D                      ; 1224  7A
        OR A                        ; 1225  B7
        RET Z                       ; 1226  C8
        JP LOC_237A                 ; 1227  C3 7A 23
LOC_122A:
        LD HL,(CUR_STMT)            ; 122A  2A 27 65
LOC_122D:
        CALL SUB_277B               ; 122D  CD 7B 27
LOC_1230:
        CP 0DH                      ; 1230  FE 0D
        JP Z,LOC_123F               ; 1232  CA 3F 12
        JP LOC_1DF1                 ; 1235  C3 F1 1D
DATA_1238:
        LD BC,2722H                 ; 1238  01 22 27
        LD H,L                      ; 123B  65
        JP LOC_1259                 ; 123C  C3 59 12
LOC_123F:
        LD HL,(WS_6523)             ; 123F  2A 23 65
        LD A,H                      ; 1242  7C
        OR L                        ; 1243  B5
        JP Z,LOC_2245               ; 1244  CA 45 22
LOC_1247:
        LD A,(HL)                   ; 1247  7E
        INC HL                      ; 1248  23
        OR (HL)                     ; 1249  B6
        DEC HL                      ; 124A  2B
        JP Z,LOC_1412               ; 124B  CA 12 14
        LD DE,6523H                 ; 124E  11 23 65
        LD BC,0004H                 ; 1251  01 04 00
        LDIR                        ; 1254  ED B0
        LD (CUR_STMT),HL            ; 1256  22 27 65
LOC_1259:
        CALL SUB_12A2               ; 1259  CD A2 12
        LD HL,E000H                 ; 125C  21 00 E0
        LD (HL),F8H                 ; 125F  36 F8
        INC HL                      ; 1261  23
        LD A,(HL)                   ; 1262  7E
        INC A                       ; 1263  3C
        JR Z,LOC_1271               ; 1264  28 0B
        CALL BRKEY                  ; 1266  CD 1E 00
        JR NZ,LOC_1271              ; 1269  20 06
        CALL SUB_24C3               ; 126B  CD C3 24
        JP LOC_2354                 ; 126E  C3 54 23
LOC_1271:
        LD HL,(WS_6368)             ; 1271  2A 68 63
        CALL SUB_2A2B               ; 1274  CD 2B 2A
        LD (FREE_PTR),HL            ; 1277  22 6A 63
        LD HL,(CUR_STMT)            ; 127A  2A 27 65
        LD A,(HL)                   ; 127D  7E
        OR A                        ; 127E  B7
        JP P,LOC_1916               ; 127F  F2 16 19
        CP B0H                      ; 1282  FE B0
        JP NC,LOC_2190              ; 1284  D2 90 21
        LD DE,586CH                 ; 1287  11 6C 58
LOC_128A:
        INC HL                      ; 128A  23
        EX DE,HL                    ; 128B  EB
        ADD A,A                     ; 128C  87
        LD C,A                      ; 128D  4F
        LD B,00H                    ; 128E  06 00
        ADD HL,BC                   ; 1290  09
        LD C,(HL)                   ; 1291  4E
        INC HL                      ; 1292  23
        LD B,(HL)                   ; 1293  46
        EX DE,HL                    ; 1294  EB
        PUSH BC                     ; 1295  C5
        RET                         ; 1296  C9
LOC_1297:
        SUB 28H                     ; 1297  D6 28
        JP C,LOC_5A5A               ; 1299  DA 5A 5A
        LD DE,593CH                 ; 129C  11 3C 59
        JP LOC_128A                 ; 129F  C3 8A 12
SUB_12A2:
        LD A,(DATA_2345)            ; 12A2  3A 45 23
        DEC A                       ; 12A5  3D
        RET NZ                      ; 12A6  C0
        LD HL,(CUR_LINE)            ; 12A7  2A 25 65
        LD A,H                      ; 12AA  7C
        OR L                        ; 12AB  B5
        RET Z                       ; 12AC  C8
        LD BC,0006H                 ; 12AD  01 06 00
        LD HL,6523H                 ; 12B0  21 23 65
        LD DE,2347H                 ; 12B3  11 47 23
        LDIR                        ; 12B6  ED B0
        RET                         ; 12B8  C9
LOC_12B9:
        PUSH AF                     ; 12B9  F5
        PUSH BC                     ; 12BA  C5
        PUSH DE                     ; 12BB  D5
        PUSH HL                     ; 12BC  E5
LOC_12BD:
        LD BC,0000H                 ; 12BD  01 00 00
        LD HL,(CURSOR)              ; 12C0  2A 71 11
        LD A,28H                    ; 12C3  3E 28
        SUB L                       ; 12C5  95
        LD B,A                      ; 12C6  47
        LD HL,3B8AH                 ; 12C7  21 8A 3B
LOC_12CA:
        LD A,(DE)                   ; 12CA  1A
        CP 0DH                      ; 12CB  FE 0D
        JP Z,LOC_3AFC               ; 12CD  CA FC 3A
        INC DE                      ; 12D0  13
        CALL ADCN                   ; 12D1  CD B9 0B
        LD (HL),A                   ; 12D4  77
        INC HL                      ; 12D5  23
        INC C                       ; 12D6  0C
        DEC B                       ; 12D7  05
        JR NZ,LOC_12CA              ; 12D8  20 F0
        CALL SUB_3B27               ; 12DA  CD 27 3B
        JR LOC_12BD                 ; 12DD  18 DE
        CALL SUB_27D2               ; 12DF  CD D2 27
        EX (SP),HL                  ; 12E2  E3
        ADD A,E                     ; 12E3  83
        LD A,(21CDH)                ; 12E4  3A CD 21
        LD (DE),A                   ; 12E7  12
        CALL SUB_27E1               ; 12E8  CD E1 27
        ADD HL,HL                   ; 12EB  29
        LD A,(WS_62B9)              ; 12EC  3A B9 62
        OR A                        ; 12EF  B7
        JP NZ,LOC_2372              ; 12F0  C2 72 23
        LD A,18H                    ; 12F3  3E 18
        SUB E                       ; 12F5  93
        JP C,LOC_237A               ; 12F6  DA 7A 23
        LD A,(MON_1172)             ; 12F9  3A 72 11
        LD B,A                      ; 12FC  47
        LD A,E                      ; 12FD  7B
        INC B                       ; 12FE  04
        SUB B                       ; 12FF  90
        JP C,LOC_3A1D               ; 1300  DA 1D 3A
        INC A                       ; 1303  3C
        LD B,A                      ; 1304  47
        PUSH HL                     ; 1305  E5
        LD HL,6000H                 ; 1306  21 00 60
        PUSH HL                     ; 1309  E5
LOC_130A:
        LD (HL),11H                 ; 130A  36 11
        INC HL                      ; 130C  23
        DJNZ LOC_130A               ; 130D  10 FB
        JP LOC_3A7D                 ; 130F  C3 7D 3A
LOC_1312:
        CP 3AH                      ; 1312  FE 3A
        RET Z                       ; 1314  C8
        CP ACH                      ; 1315  FE AC
        RET                         ; 1317  C9
        RST 38H                     ; 1318  FF
        RST 38H                     ; 1319  FF
        RST 38H                     ; 131A  FF
        RST 38H                     ; 131B  FF
        RST 38H                     ; 131C  FF
        NOP                         ; 131D  00
        NOP                         ; 131E  00
LOC_131F:
        CALL SUB_5068               ; 131F  CD 68 50
        JP LOC_2245                 ; 1322  C3 45 22
        CALL C,MONIT                ; 1325  DC 00 00
        NOP                         ; 1328  00
        NOP                         ; 1329  00
        CALL SUB_13C4               ; 132A  CD C4 13
        PUSH HL                     ; 132D  E5
        OR A                        ; 132E  B7
        CALL NZ,SUB_3D9D            ; 132F  C4 9D 3D
        CALL SUB_13AC               ; 1332  CD AC 13
        LD HL,6180H                 ; 1335  21 80 61
        CALL SUB_2A2B               ; 1338  CD 2B 2A
        DEC A                       ; 133B  3D
        CALL SUB_2A2C               ; 133C  CD 2C 2A
        POP HL                      ; 133F  E1
        CALL SUB_2981               ; 1340  CD 81 29
        CALL NZ,SUB_1389            ; 1343  C4 89 13
        LD (CUR_STMT),HL            ; 1346  22 27 65
        LD HL,652CH                 ; 1349  21 2C 65
LOC_134C:
        PUSH HL                     ; 134C  E5
        CALL SUB_28B2               ; 134D  CD B2 28
        POP HL                      ; 1350  E1
        JP Z,LOC_123F               ; 1351  CA 3F 12
        CALL SUB_2940               ; 1354  CD 40 29
        LD DE,6055H                 ; 1357  11 55 60
        CALL SUB_28F1               ; 135A  CD F1 28
        LD HL,(WS_6180)             ; 135D  2A 80 61
        EX DE,HL                    ; 1360  EB
        LD HL,(WS_6057)             ; 1361  2A 57 60
        CALL SUB_27B0               ; 1364  CD B0 27
        JP C,LOC_1383               ; 1367  DA 83 13
        EX DE,HL                    ; 136A  EB
        LD HL,(WS_6182)             ; 136B  2A 82 61
        CALL SUB_27B0               ; 136E  CD B0 27
        JP C,LOC_1383               ; 1371  DA 83 13
        CALL SUB_253E               ; 1374  CD 3E 25
        LD DE,6000H                 ; 1377  11 00 60
        CALL SUB_13B6               ; 137A  CD B6 13
        CALL SUB_4AB3               ; 137D  CD B3 4A
        JP Z,LOC_2245               ; 1380  CA 45 22
LOC_1383:
        LD HL,(WS_6055)             ; 1383  2A 55 60
        JP LOC_134C                 ; 1386  C3 4C 13
SUB_1389:
        CALL SUB_2840               ; 1389  CD 40 28
        LD (WS_6180),DE             ; 138C  ED 53 80 61
        CALL SUB_2981               ; 1390  CD 81 29
        JP Z,LOC_13A1               ; 1393  CA A1 13
        CALL SUB_27E1               ; 1396  CD E1 27
        CP L                        ; 1399  BD
        CALL SUB_2981               ; 139A  CD 81 29
        RET Z                       ; 139D  C8
SUB_139E:
        CALL SUB_2840               ; 139E  CD 40 28
LOC_13A1:
        LD (WS_6182),DE             ; 13A1  ED 53 82 61
        CALL SUB_2981               ; 13A5  CD 81 29
        RET Z                       ; 13A8  C8
        JP LOC_2372                 ; 13A9  C3 72 23
SUB_13AC:
        LD A,(1326H)                ; 13AC  3A 26 13
        OR A                        ; 13AF  B7
        JP Z,NEWLIN                 ; 13B0  CA 09 00
        JP SUB_3D0D                 ; 13B3  C3 0D 3D
SUB_13B6:
        LD BC,13ACH                 ; 13B6  01 AC 13
        PUSH BC                     ; 13B9  C5
        LD A,(1326H)                ; 13BA  3A 26 13
        OR A                        ; 13BD  B7
        JP Z,LOC_12B9               ; 13BE  CA B9 12
        JP LOC_3D28                 ; 13C1  C3 28 3D
SUB_13C4:
        CALL SUB_27D2               ; 13C4  CD D2 27
        CP A                        ; 13C7  BF
        JP NC,WS_CD13               ; 13C8  D2 13 CD
        POP HL                      ; 13CB  E1
        DAA                         ; 13CC  27
        LD D,B                      ; 13CD  50
        LD A,01H                    ; 13CE  3E 01
        JR LOC_13D3                 ; 13D0  18 01
        XOR A                       ; 13D2  AF
LOC_13D3:
        LD (1326H),A                ; 13D3  32 26 13
        RET                         ; 13D6  C9
        CALL SUB_2840               ; 13D7  CD 40 28
        CALL SUB_2981               ; 13DA  CD 81 29
        JP NZ,LOC_2372              ; 13DD  C2 72 23
        LD (CUR_STMT),HL            ; 13E0  22 27 65
        LD BC,122AH                 ; 13E3  01 2A 12
        PUSH BC                     ; 13E6  C5
        LD A,D                      ; 13E7  7A
        OR E                        ; 13E8  B3
        JP Z,SUB_2B1A               ; 13E9  CA 1A 2B
        EX DE,HL                    ; 13EC  EB
        CALL SUB_5E8A               ; 13ED  CD 8A 5E
        XOR (HL)                    ; 13F0  AE
        INC HL                      ; 13F1  23
        JP NZ,LOC_23AE              ; 13F2  C2 AE 23
        JP LOC_41A4                 ; 13F5  C3 A4 41
LOC_13F8:
        CALL SUB_278B               ; 13F8  CD 8B 27
        JP LOC_1230                 ; 13FB  C3 30 12
DATA_13FE:
        NOP                         ; 13FE  00
        CALL SUB_2B2A               ; 13FF  CD 2A 2B
        LD A,(DATA_13FE)            ; 1402  3A FE 13
        OR A                        ; 1405  B7
        JP NZ,LOC_4721              ; 1406  C2 21 47
        CALL SUB_24BF               ; 1409  CD BF 24
        LD (CUR_STMT),HL            ; 140C  22 27 65
        JP LOC_2245                 ; 140F  C3 45 22
LOC_1412:
        LD A,(DATA_13FE)            ; 1412  3A FE 13
        OR A                        ; 1415  B7
        JP Z,LOC_2245               ; 1416  CA 45 22
        JP LOC_4721                 ; 1419  C3 21 47
        CALL SUB_2B2A               ; 141C  CD 2A 2B
        CALL SUB_24BF               ; 141F  CD BF 24
        LD (CUR_STMT),HL            ; 1422  22 27 65
        JP LOC_2354                 ; 1425  C3 54 23
LOC_1428:
        PUSH HL                     ; 1428  E5
LOC_1429:
        CALL SUB_2981               ; 1429  CD 81 29
        JP Z,LOC_2372               ; 142C  CA 72 23
        CP B6H                      ; 142F  FE B6
        INC HL                      ; 1431  23
        JR NZ,LOC_1429              ; 1432  20 F5
        CALL SUB_1A58               ; 1434  CD 58 1A
        LD (CUR_STMT),HL            ; 1437  22 27 65
        CALL SUB_2B09               ; 143A  CD 09 2B
        POP HL                      ; 143D  E1
        CALL SUB_1DBE               ; 143E  CD BE 1D
        CALL SUB_1BDF               ; 1441  CD DF 1B
LOC_1444:
        CALL SUB_27E1               ; 1444  CD E1 27
        OR (HL)                     ; 1447  B6
        CALL SUB_2B0E               ; 1448  CD 0E 2B
        CALL SUB_1453               ; 144B  CD 53 14
        LD A,(HL)                   ; 144E  7E
        INC HL                      ; 144F  23
        JP LOC_122A                 ; 1450  C3 2A 12
; --- SUB_1453: called from 4 places ---
SUB_1453:
        LD HL,6171H                 ; 1453  21 71 61
        LD B,(HL)                   ; 1456  46
        INC HL                      ; 1457  23
        LD C,(HL)                   ; 1458  4E
        INC HL                      ; 1459  23
        LD A,(HL)                   ; 145A  7E
        LD DE,(WS_6174)             ; 145B  ED 5B 74 61
        OR A                        ; 145F  B7
        JP NZ,LOC_146D              ; 1460  C2 6D 14
        OR B                        ; 1463  B0
        JP NZ,LOC_27B7              ; 1464  C2 B7 27
        CALL SUB_297C               ; 1467  CD 7C 29
        JP LOC_27C1                 ; 146A  C3 C1 27
LOC_146D:
        XOR A                       ; 146D  AF
        OR B                        ; 146E  B0
        JP Z,LOC_27B7               ; 146F  CA B7 27
        LD HL,6159H                 ; 1472  21 59 61
        XOR A                       ; 1475  AF
        LD B,A                      ; 1476  47
        SBC HL,DE                   ; 1477  ED 52
        JP Z,LOC_14AC               ; 1479  CA AC 14
        LD HL,(WS_616E)             ; 147C  2A 6E 61
        PUSH HL                     ; 147F  E5
        XOR A                       ; 1480  AF
        SBC HL,BC                   ; 1481  ED 42
        LD B,H                      ; 1483  44
        LD C,L                      ; 1484  4D
        JR C,LOC_148C               ; 1485  38 05
        CALL SUB_28D4               ; 1487  CD D4 28
        JR LOC_1494                 ; 148A  18 08
LOC_148C:
        PUSH BC                     ; 148C  C5
        CALL SUB_279F               ; 148D  CD 9F 27
        CALL SUB_28BE               ; 1490  CD BE 28
        POP BC                      ; 1493  C1
LOC_1494:
        CALL SUB_2A31               ; 1494  CD 31 2A
        LD HL,(WS_6170)             ; 1497  2A 70 61
        EX DE,HL                    ; 149A  EB
        CALL SUB_2959               ; 149B  CD 59 29
        POP BC                      ; 149E  C1
        DEC HL                      ; 149F  2B
        LD (HL),C                   ; 14A0  71
        INC HL                      ; 14A1  23
        EX DE,HL                    ; 14A2  EB
        LD A,C                      ; 14A3  79
        OR A                        ; 14A4  B7
        JR Z,LOC_14A9               ; 14A5  28 02
        LDIR                        ; 14A7  ED B0
LOC_14A9:
        JP LOC_27C1                 ; 14A9  C3 C1 27
LOC_14AC:
        LD HL,(WS_6170)             ; 14AC  2A 70 61
        EX DE,HL                    ; 14AF  EB
        CALL SUB_2959               ; 14B0  CD 59 29
        EX DE,HL                    ; 14B3  EB
        LD DE,6159H                 ; 14B4  11 59 61
        PUSH DE                     ; 14B7  D5
        LD B,03H                    ; 14B8  06 03
LOC_14BA:
        LD C,02H                    ; 14BA  0E 02
LOC_14BC:
        CALL SUB_27A7               ; 14BC  CD A7 27
        JP NC,LOC_237A              ; 14BF  D2 7A 23
        LD (DE),A                   ; 14C2  12
        INC DE                      ; 14C3  13
        INC HL                      ; 14C4  23
        DEC C                       ; 14C5  0D
        JR NZ,LOC_14BC              ; 14C6  20 F4
        LD A,0DH                    ; 14C8  3E 0D
        LD (DE),A                   ; 14CA  12
        INC DE                      ; 14CB  13
        DEC B                       ; 14CC  05
        JR NZ,LOC_14BA              ; 14CD  20 EB
        CALL SUB_27D2               ; 14CF  CD D2 27
        DEC C                       ; 14D2  0D
        LD A,D                      ; 14D3  7A
        INC HL                      ; 14D4  23
        POP HL                      ; 14D5  E1
        CALL SUB_1204               ; 14D6  CD 04 12
        LD B,00H                    ; 14D9  06 00
        LD A,E                      ; 14DB  7B
        CP 18H                      ; 14DC  FE 18
        JP NC,LOC_237A              ; 14DE  D2 7A 23
        SUB 0CH                     ; 14E1  D6 0C
        JR C,LOC_14E7               ; 14E3  38 02
        LD E,A                      ; 14E5  5F
        INC B                       ; 14E6  04
LOC_14E7:
        LD A,B                      ; 14E7  78
        PUSH AF                     ; 14E8  F5
        PUSH HL                     ; 14E9  E5
        LD HL,0E10H                 ; 14EA  21 10 0E
        CALL SUB_2817               ; 14ED  CD 17 28
        POP HL                      ; 14F0  E1
        PUSH DE                     ; 14F1  D5
        INC HL                      ; 14F2  23
        CALL SUB_1204               ; 14F3  CD 04 12
        LD A,E                      ; 14F6  7B
        CP 3CH                      ; 14F7  FE 3C
        JP NC,LOC_237A              ; 14F9  D2 7A 23
        PUSH HL                     ; 14FC  E5
        LD HL,003CH                 ; 14FD  21 3C 00
        CALL SUB_2817               ; 1500  CD 17 28
        POP HL                      ; 1503  E1
        EX (SP),HL                  ; 1504  E3
        ADD HL,DE                   ; 1505  19
        EX (SP),HL                  ; 1506  E3
        INC HL                      ; 1507  23
        CALL SUB_1204               ; 1508  CD 04 12
        LD A,E                      ; 150B  7B
        CP 3CH                      ; 150C  FE 3C
        JP NC,LOC_237A              ; 150E  D2 7A 23
        POP HL                      ; 1511  E1
        ADD HL,DE                   ; 1512  19
        EX DE,HL                    ; 1513  EB
        POP AF                      ; 1514  F1
        CALL TIMST                  ; 1515  CD 33 00
        JP LOC_27C1                 ; 1518  C3 C1 27
LOC_151B:
        CALL SUB_27D2               ; 151B  CD D2 27
        INC L                       ; 151E  2C
        LD HL,CD15H                 ; 151F  21 15 CD
        LD A,(DE)                   ; 1522  1A
        DEC HL                      ; 1523  2B
        XOR A                       ; 1524  AF
        LD (WS_617C),A              ; 1525  32 7C 61
        LD (WS_6167),A              ; 1528  32 67 61
        CALL SUB_27A7               ; 152B  CD A7 27
        JP NC,LOC_1540              ; 152E  D2 40 15
LOC_1531:
        CALL SUB_2840               ; 1531  CD 40 28
LOC_1534:
        EX DE,HL                    ; 1534  EB
LOC_1535:
        CALL SUB_5E8A               ; 1535  CD 8A 5E
        XOR (HL)                    ; 1538  AE
        INC HL                      ; 1539  23
        JP NZ,LOC_23AE              ; 153A  C2 AE 23
        JP LOC_1247                 ; 153D  C3 47 12
LOC_1540:
        CALL SUB_2981               ; 1540  CD 81 29
        JP NZ,LOC_4507              ; 1543  C2 07 45
LOC_1546:
        CALL SUB_234F               ; 1546  CD 4F 23
        XOR A                       ; 1549  AF
        LD (DATA_13FE),A            ; 154A  32 FE 13
        CALL SUB_29AF               ; 154D  CD AF 29
        CALL SUB_29DA               ; 1550  CD DA 29
        LD HL,652CH                 ; 1553  21 2C 65
        JP LOC_1247                 ; 1556  C3 47 12
LOC_1559:
        CALL SUB_2B2A               ; 1559  CD 2A 2B
        CALL SUB_2840               ; 155C  CD 40 28
LOC_155F:
        LD (CUR_STMT),HL            ; 155F  22 27 65
        EX DE,HL                    ; 1562  EB
        CALL SUB_5E8A               ; 1563  CD 8A 5E
        XOR (HL)                    ; 1566  AE
        INC HL                      ; 1567  23
        JP NZ,LOC_23AE              ; 1568  C2 AE 23
        CALL SUB_5FC8               ; 156B  CD C8 5F
        JP LOC_1247                 ; 156E  C3 47 12
        LD C,A                      ; 1571  4F
        LD B,D                      ; 1572  42
        LD C,D                      ; 1573  4A
        DEC C                       ; 1574  0D
        LD B,D                      ; 1575  42
        LD D,H                      ; 1576  54
        LD E,B                      ; 1577  58
        DEC C                       ; 1578  0D
        LD B,D                      ; 1579  42
        LD D,E                      ; 157A  53
        LD B,H                      ; 157B  44
        DEC C                       ; 157C  0D
        LD B,D                      ; 157D  42
        LD D,D                      ; 157E  52
        LD B,H                      ; 157F  44
        DEC C                       ; 1580  0D
        JR NZ,LOC_15C2              ; 1581  20 3F
        JR NZ,LOC_1592              ; 1583  20 0D
        LD B,C                      ; 1585  41
        LD D,E                      ; 1586  53
        LD D,E                      ; 1587  53
        DEC C                       ; 1588  0D
        LD B,L                      ; 1589  45
        LD B,H                      ; 158A  44
        LD D,H                      ; 158B  54
        DEC C                       ; 158C  0D
        DEC C                       ; 158D  0D
        DEC C                       ; 158E  0D
        DEC C                       ; 158F  0D
        DB CDH,9EH                  ; 1590  CD 9E   (stray byte(s): disassembly boundary correction)
LOC_1592:
        DEC D                       ; 1592  15
        LD DE,6523H                 ; 1593  11 23 65
        LDIR                        ; 1596  ED B0
        LD (ARRAY_PTR),HL           ; 1598  22 70 63
        JP LOC_122A                 ; 159B  C3 2A 12
SUB_159E:
        LD HL,652BH                 ; 159E  21 2B 65
        XOR A                       ; 15A1  AF
        CP (HL)                     ; 15A2  BE
        JP Z,LOC_23A6               ; 15A3  CA A6 23
        DEC (HL)                    ; 15A6  35
        LD BC,0013H                 ; 15A7  01 13 00
LOC_15AA:
        LD HL,6529H                 ; 15AA  21 29 65
        LD A,(HL)                   ; 15AD  7E
        OR A                        ; 15AE  B7
        JR Z,LOC_15BD               ; 15AF  28 0C
        DEC (HL)                    ; 15B1  35
        INC HL                      ; 15B2  23
        DEC (HL)                    ; 15B3  35
        LD HL,(STR_PTR)             ; 15B4  2A 6E 63
        ADD HL,BC                   ; 15B7  09
        LD (STR_PTR),HL             ; 15B8  22 6E 63
        JR LOC_15AA                 ; 15BB  18 ED
LOC_15BD:
        LD HL,(ARRAY_PTR)           ; 15BD  2A 70 63
        DB 01H,07H                  ; 15C0  01 07   (stray byte(s): disassembly boundary correction)
LOC_15C2:
        NOP                         ; 15C2  00
        RET                         ; 15C3  C9
        NOP                         ; 15C4  00
        CALL SUB_1DBE               ; 15C5  CD BE 1D
        CALL SUB_27E1               ; 15C8  CD E1 27
        OR (HL)                     ; 15CB  B6
        PUSH DE                     ; 15CC  D5
        CALL SUB_1654               ; 15CD  CD 54 16
        POP HL                      ; 15D0  E1
        LD (WS_6516),HL             ; 15D1  22 16 65
        EX DE,HL                    ; 15D4  EB
        CALL SUB_1BEA               ; 15D5  CD EA 1B
        CALL SUB_297C               ; 15D8  CD 7C 29
        CALL SUB_27DE               ; 15DB  CD DE 27
        XOR (HL)                    ; 15DE  AE
        CALL SUB_1654               ; 15DF  CD 54 16
        LD DE,651EH                 ; 15E2  11 1E 65
        CALL SUB_297C               ; 15E5  CD 7C 29
        CALL SUB_27CF               ; 15E8  CD CF 27
        XOR A                       ; 15EB  AF
        OR 15H                      ; 15EC  F6 15
        CALL SUB_1654               ; 15EE  CD 54 16
        LD HL,(FREE_PTR)            ; 15F1  2A 6A 63
        JR LOC_15F9                 ; 15F4  18 03
        LD HL,2762H                 ; 15F6  21 62 27
LOC_15F9:
        LD DE,6518H                 ; 15F9  11 18 65
        LD A,(HL)                   ; 15FC  7E
        LD (WS_651D),A              ; 15FD  32 1D 65
        LD BC,0005H                 ; 1600  01 05 00
        LDIR                        ; 1603  ED B0
        LD HL,(STR_PTR)             ; 1605  2A 6E 63
        LD DE,(WS_6516)             ; 1608  ED 5B 16 65
        LD A,(WS_6529)              ; 160C  3A 29 65
        INC A                       ; 160F  3C
LOC_1610:
        DEC A                       ; 1610  3D
        JP Z,LOC_1635               ; 1611  CA 35 16
        EX AF,AF_                   ; 1614  08
        LD A,(HL)                   ; 1615  7E
        SUB E                       ; 1616  93
        LD B,A                      ; 1617  47
        INC HL                      ; 1618  23
        LD A,(HL)                   ; 1619  7E
        SUB D                       ; 161A  92
        OR B                        ; 161B  B0
        LD BC,0012H                 ; 161C  01 12 00
        ADD HL,BC                   ; 161F  09
        JP Z,LOC_1627               ; 1620  CA 27 16
        EX AF,AF_                   ; 1623  08
        JP LOC_1610                 ; 1624  C3 10 16
LOC_1627:
        LD (STR_PTR),HL             ; 1627  22 6E 63
        EX AF,AF_                   ; 162A  08
        DEC A                       ; 162B  3D
        LD HL,6529H                 ; 162C  21 29 65
        LD B,(HL)                   ; 162F  46
        LD (HL),A                   ; 1630  77
        SUB B                       ; 1631  90
        INC HL                      ; 1632  23
        ADD A,(HL)                  ; 1633  86
        LD (HL),A                   ; 1634  77
LOC_1635:
        LD HL,652AH                 ; 1635  21 2A 65
        LD A,(HL)                   ; 1638  7E
        CP 0FH                      ; 1639  FE 0F
        JP Z,LOC_239A               ; 163B  CA 9A 23
        INC (HL)                    ; 163E  34
        DEC HL                      ; 163F  2B
        INC (HL)                    ; 1640  34
        DEC HL                      ; 1641  2B
        LD DE,(STR_PTR)             ; 1642  ED 5B 6E 63
        LD BC,0013H                 ; 1646  01 13 00
        DEC DE                      ; 1649  1B
        LDDR                        ; 164A  ED B8
        INC DE                      ; 164C  13
        EX DE,HL                    ; 164D  EB
        LD (STR_PTR),HL             ; 164E  22 6E 63
        JP LOC_122A                 ; 1651  C3 2A 12
; --- SUB_1654: called from 3 places ---
SUB_1654:
        CALL SUB_1A58               ; 1654  CD 58 1A
        LD (CUR_STMT),HL            ; 1657  22 27 65
        JP SUB_296C                 ; 165A  C3 6C 29
SUB_165D:
        LD A,(WS_6529)              ; 165D  3A 29 65
        OR A                        ; 1660  B7
        JP Z,LOC_23A2               ; 1661  CA A2 23
        CALL SUB_1D78               ; 1664  CD 78 1D
        LD (CUR_STMT),HL            ; 1667  22 27 65
        LD HL,(STR_PTR)             ; 166A  2A 6E 63
        CALL NC,SUB_16E0            ; 166D  D4 E0 16
LOC_1670:
        LD A,E                      ; 1670  7B
        SUB (HL)                    ; 1671  96
        INC HL                      ; 1672  23
        LD B,A                      ; 1673  47
        LD A,D                      ; 1674  7A
        SUB (HL)                    ; 1675  96
        OR B                        ; 1676  B0
        RET Z                       ; 1677  C8
        NOP                         ; 1678  00
        NOP                         ; 1679  00
        EXX                         ; 167A  D9
        LD HL,6529H                 ; 167B  21 29 65
        LD A,(HL)                   ; 167E  7E
        DEC A                       ; 167F  3D
        JP Z,LOC_23A2               ; 1680  CA A2 23
        LD (HL),A                   ; 1683  77
        INC HL                      ; 1684  23
        DEC (HL)                    ; 1685  35
        EXX                         ; 1686  D9
        LD BC,0012H                 ; 1687  01 12 00
        ADD HL,BC                   ; 168A  09
        LD (STR_PTR),HL             ; 168B  22 6E 63
        JP LOC_1670                 ; 168E  C3 70 16
LOC_1691:
        INC HL                      ; 1691  23
        CALL SUB_1BEA               ; 1692  CD EA 1B
        PUSH DE                     ; 1695  D5
        PUSH HL                     ; 1696  E5
        CALL SUB_2B3B               ; 1697  CD 3B 2B
        POP HL                      ; 169A  E1
        POP DE                      ; 169B  D1
        LD BC,0005H                 ; 169C  01 05 00
        ADD HL,BC                   ; 169F  09
        LD A,(HL)                   ; 16A0  7E
        INC HL                      ; 16A1  23
        PUSH HL                     ; 16A2  E5
        OR A                        ; 16A3  B7
        JP P,LOC_16C0               ; 16A4  F2 C0 16
        EX DE,HL                    ; 16A7  EB
        CALL SUB_31DC               ; 16A8  CD DC 31
        POP HL                      ; 16AB  E1
        LD BC,0005H                 ; 16AC  01 05 00
        JP C,LOC_16CB               ; 16AF  DA CB 16
LOC_16B2:
        ADD HL,BC                   ; 16B2  09
        LD DE,6523H                 ; 16B3  11 23 65
        INC C                       ; 16B6  0C
        LDIR                        ; 16B7  ED B0
        LD HL,(CUR_STMT)            ; 16B9  2A 27 65
        LD A,(HL)                   ; 16BC  7E
        JP LOC_1230                 ; 16BD  C3 30 12
LOC_16C0:
        CALL SUB_31DC               ; 16C0  CD DC 31
        POP HL                      ; 16C3  E1
        LD BC,0005H                 ; 16C4  01 05 00
        CCF                         ; 16C7  3F
        JP C,LOC_16B2               ; 16C8  DA B2 16
LOC_16CB:
        LD C,0BH                    ; 16CB  0E 0B
        ADD HL,BC                   ; 16CD  09
        LD (STR_PTR),HL             ; 16CE  22 6E 63
        LD HL,6529H                 ; 16D1  21 29 65
        DEC (HL)                    ; 16D4  35
        INC HL                      ; 16D5  23
        DEC (HL)                    ; 16D6  35
        CALL SUB_27CF               ; 16D7  CD CF 27
        INC L                       ; 16DA  2C
        LD HL,(WS_C312)             ; 16DB  2A 12 C3
        INC BC                      ; 16DE  03
        ADD HL,DE                   ; 16DF  19
SUB_16E0:
        LD E,(HL)                   ; 16E0  5E
        INC HL                      ; 16E1  23
        LD D,(HL)                   ; 16E2  56
        DEC HL                      ; 16E3  2B
        RET                         ; 16E4  C9
        CALL SUB_2B2A               ; 16E5  CD 2A 2B
        CALL SUB_27D2               ; 16E8  CD D2 27
        RET PO                      ; 16EB  E0
        RLCA                        ; 16EC  07
        RLA                         ; 16ED  17
        CALL SUB_27E1               ; 16EE  CD E1 27
        ADC A,C                     ; 16F1  89
        CALL SUB_2840               ; 16F2  CD 40 28
        EX DE,HL                    ; 16F5  EB
        LD A,H                      ; 16F6  7C
        OR L                        ; 16F7  B5
        JP Z,LOC_5BF7               ; 16F8  CA F7 5B
        LD (234DH),HL               ; 16FB  22 4D 23
        LD A,01H                    ; 16FE  3E 01
LOC_1700:
        LD (DATA_2345),A            ; 1700  32 45 23
        EX DE,HL                    ; 1703  EB
        JP LOC_122D                 ; 1704  C3 2D 12
        CALL SUB_1A58               ; 1707  CD 58 1A
        CALL SUB_296C               ; 170A  CD 6C 29
        LD DE,(FREE_PTR)            ; 170D  ED 5B 6A 63
        LD A,(DE)                   ; 1711  1A
        LD DE,0000H                 ; 1712  11 00 00
        CP C1H                      ; 1715  FE C1
        JP C,LOC_172A               ; 1717  DA 2A 17
        SUB D1H                     ; 171A  D6 D1
        JP NC,LOC_172A              ; 171C  D2 2A 17
        LD BC,172AH                 ; 171F  01 2A 17
        PUSH BC                     ; 1722  C5
        PUSH HL                     ; 1723  E5
        LD HL,(FREE_PTR)            ; 1724  2A 6A 63
        JP LOC_2AF6                 ; 1727  C3 F6 2A
LOC_172A:
        LD A,(HL)                   ; 172A  7E
        INC HL                      ; 172B  23
        SUB 89H                     ; 172C  D6 89
        JR Z,LOC_1735               ; 172E  28 05
        CP 02H                      ; 1730  FE 02
        JP NZ,LOC_2372              ; 1732  C2 72 23
LOC_1735:
        EX AF,AF_                   ; 1735  08
        LD A,E                      ; 1736  7B
        OR A                        ; 1737  B7
        JP Z,LOC_13F8               ; 1738  CA F8 13
        LD A,D                      ; 173B  7A
        OR A                        ; 173C  B7
        DB C2H,F8H                  ; 173D  C2 F8   (stray byte(s): disassembly boundary correction)
SUB_173F:
        INC DE                      ; 173F  13
LOC_1740:
        DEC E                       ; 1740  1D
        JP Z,LOC_1753               ; 1741  CA 53 17
LOC_1744:
        CALL SUB_2981               ; 1744  CD 81 29
        JP Z,LOC_1230               ; 1747  CA 30 12
        CP 2CH                      ; 174A  FE 2C
        INC HL                      ; 174C  23
        JP NZ,LOC_1744              ; 174D  C2 44 17
        JP LOC_1740                 ; 1750  C3 40 17
LOC_1753:
        CALL SUB_2840               ; 1753  CD 40 28
        CALL SUB_278B               ; 1756  CD 8B 27
        EX AF,AF_                   ; 1759  08
        OR A                        ; 175A  B7
        JP NZ,LOC_155F              ; 175B  C2 5F 15
        JP LOC_1534                 ; 175E  C3 34 15
        CALL SUB_2B2A               ; 1761  CD 2A 2B
        LD A,(DATA_2345)            ; 1764  3A 45 23
        CP 02H                      ; 1767  FE 02
        JP NZ,LOC_23C2              ; 1769  C2 C2 23
        CALL SUB_2981               ; 176C  CD 81 29
        JP NZ,LOC_1778              ; 176F  C2 78 17
        LD HL,1259H                 ; 1772  21 59 12
        JP LOC_178E                 ; 1775  C3 8E 17
LOC_1778:
        CALL SUB_27D2               ; 1778  CD D2 27
        ADC A,L                     ; 177B  8D
        AND C                       ; 177C  A1
        RLA                         ; 177D  17
        LD HL,(234BH)               ; 177E  2A 4B 23
        DEC HL                      ; 1781  2B
LOC_1782:
        INC HL                      ; 1782  23
        CALL SUB_2981               ; 1783  CD 81 29
        JR NZ,LOC_1782              ; 1786  20 FA
        LD (234BH),HL               ; 1788  22 4B 23
        LD HL,122AH                 ; 178B  21 2A 12
LOC_178E:
        PUSH HL                     ; 178E  E5
        LD HL,2347H                 ; 178F  21 47 23
        LD DE,6523H                 ; 1792  11 23 65
        LD BC,0006H                 ; 1795  01 06 00
        LDIR                        ; 1798  ED B0
        LD A,01H                    ; 179A  3E 01
LOC_179C:
        LD (DATA_2345),A            ; 179C  32 45 23
        POP HL                      ; 179F  E1
        JP (HL)                     ; 17A0  E9
        CALL SUB_2840               ; 17A1  CD 40 28
LOC_17A4:
        LD A,D                      ; 17A4  7A
        OR E                        ; 17A5  B3
        JP Z,LOC_17BA               ; 17A6  CA BA 17
        EX DE,HL                    ; 17A9  EB
        CALL SUB_28FD               ; 17AA  CD FD 28
        CP (HL)                     ; 17AD  BE
        INC HL                      ; 17AE  23
        JP NZ,LOC_23BE              ; 17AF  C2 BE 23
        LD A,01H                    ; 17B2  3E 01
        LD (DATA_2345),A            ; 17B4  32 45 23
        JP LOC_1247                 ; 17B7  C3 47 12
LOC_17BA:
        CALL SUB_2981               ; 17BA  CD 81 29
        JP NZ,LOC_2372              ; 17BD  C2 72 23
        CALL SUB_234F               ; 17C0  CD 4F 23
        JP LOC_1546                 ; 17C3  C3 46 15
LOC_17C6:
        CALL SUB_1DBE               ; 17C6  CD BE 1D
        LD BC,0000H                 ; 17C9  01 00 00
        CP 24H                      ; 17CC  FE 24
        JR NZ,LOC_17D2              ; 17CE  20 02
        INC HL                      ; 17D0  23
        INC B                       ; 17D1  04
LOC_17D2:
        CALL SUB_27E1               ; 17D2  CD E1 27
        JR Z,LOC_17A4               ; 17D5  28 CD
        LD D,H                      ; 17D7  54
        JR LOC_179C                 ; 17D8  18 C2
        JR NC,LOC_17F4              ; 17DA  30 18
        PUSH HL                     ; 17DC  E5
        LD HL,(DATA_1852)           ; 17DD  2A 52 18
        LD E,H                      ; 17E0  5C
        LD D,A                      ; 17E1  57
        LD H,A                      ; 17E2  67
        INC HL                      ; 17E3  23
        INC DE                      ; 17E4  13
        CALL SUB_27EE               ; 17E5  CD EE 27
        ADD A,(HL)                  ; 17E8  86
        INC HL                      ; 17E9  23
        LD A,(DATA_1851)            ; 17EA  3A 51 18
        OR A                        ; 17ED  B7
        POP HL                      ; 17EE  E1
        PUSH DE                     ; 17EF  D5
        PUSH HL                     ; 17F0  E5
        LD HL,0002H                 ; 17F1  21 02 00
LOC_17F4:
        JR NZ,LOC_17F8              ; 17F4  20 02
        LD L,05H                    ; 17F6  2E 05
LOC_17F8:
        CALL SUB_27EE               ; 17F8  CD EE 27
        ADD A,(HL)                  ; 17FB  86
        INC HL                      ; 17FC  23
        LD HL,0004H                 ; 17FD  21 04 00
        ADD HL,DE                   ; 1800  19
        JP C,LOC_2386               ; 1801  DA 86 23
        LD B,H                      ; 1804  44
        LD C,L                      ; 1805  4D
        POP DE                      ; 1806  D1
        CALL SUB_28D4               ; 1807  CD D4 28
        CALL SUB_2A31               ; 180A  CD 31 2A
        LD HL,(WS_62B6)             ; 180D  2A B6 62
        EX DE,HL                    ; 1810  EB
        LD (HL),E                   ; 1811  73
        INC HL                      ; 1812  23
        LD (HL),D                   ; 1813  72
        INC HL                      ; 1814  23
        LD DE,(DATA_1852)           ; 1815  ED 5B 52 18
        LD (HL),E                   ; 1819  73
        INC HL                      ; 181A  23
        LD (HL),D                   ; 181B  72
        INC HL                      ; 181C  23
        POP BC                      ; 181D  C1
        LD A,(DATA_1851)            ; 181E  3A 51 18
        OR A                        ; 1821  B7
        JP Z,LOC_183C               ; 1822  CA 3C 18
LOC_1825:
        LD (HL),00H                 ; 1825  36 00
        INC HL                      ; 1827  23
        LD (HL),0DH                 ; 1828  36 0D
        INC HL                      ; 182A  23
        DEC BC                      ; 182B  0B
        LD A,B                      ; 182C  78
        OR C                        ; 182D  B1
        JR NZ,LOC_1825              ; 182E  20 F5
LOC_1830:
        LD HL,(184FH)               ; 1830  2A 4F 18
        CALL SUB_27D2               ; 1833  CD D2 27
        INC L                       ; 1836  2C
        DEC L                       ; 1837  2D
        LD (DE),A                   ; 1838  12
        JP LOC_17C6                 ; 1839  C3 C6 17
LOC_183C:
        EX DE,HL                    ; 183C  EB
LOC_183D:
        PUSH BC                     ; 183D  C5
        LD HL,2767H                 ; 183E  21 67 27
        LD BC,0005H                 ; 1841  01 05 00
        LDIR                        ; 1844  ED B0
        POP BC                      ; 1846  C1
        DEC BC                      ; 1847  0B
        LD A,B                      ; 1848  78
        OR C                        ; 1849  B1
        JR NZ,LOC_183D              ; 184A  20 F1
        JP LOC_1830                 ; 184C  C3 30 18
        LD H,D                      ; 184F  62
        LD H,B                      ; 1850  60
DATA_1851:
        NOP                         ; 1851  00
DATA_1852:
        DB 01H,00H                  ; 1852  01 00   (stray byte(s): disassembly boundary correction)
SUB_1854:
        PUSH DE                     ; 1854  D5
        PUSH BC                     ; 1855  C5
        DB CDH,21H                  ; 1856  CD 21   (stray byte(s): disassembly boundary correction)
LOC_1858:
        LD (DE),A                   ; 1858  12
        POP BC                      ; 1859  C1
        LD A,(HL)                   ; 185A  7E
        CP 2CH                      ; 185B  FE 2C
        CALL Z,SUB_18D6             ; 185D  CC D6 18
        CALL SUB_27E1               ; 1860  CD E1 27
        ADD HL,HL                   ; 1863  29
        LD (184FH),HL               ; 1864  22 4F 18
        POP HL                      ; 1867  E1
        LD (WS_62B6),HL             ; 1868  22 B6 62
        EX DE,HL                    ; 186B  EB
        LD (DATA_1852),HL           ; 186C  22 52 18
        LD A,B                      ; 186F  78
        LD (DATA_1851),A            ; 1870  32 51 18
        LD HL,635CH                 ; 1873  21 5C 63
        LD DE,0006H                 ; 1876  11 06 00
        OR A                        ; 1879  B7
        JR Z,LOC_187D               ; 187A  28 01
        ADD HL,DE                   ; 187C  19
LOC_187D:
        LD A,C                      ; 187D  79
        LD E,02H                    ; 187E  1E 02
        OR A                        ; 1880  B7
        JR NZ,LOC_1884              ; 1881  20 01
        ADD HL,DE                   ; 1883  19
LOC_1884:
        LD E,(HL)                   ; 1884  5E
        INC HL                      ; 1885  23
        LD D,(HL)                   ; 1886  56
        EX DE,HL                    ; 1887  EB
LOC_1888:
        CALL SUB_291C               ; 1888  CD 1C 29
        CP A                        ; 188B  BF
        JR LOC_1858                 ; 188C  18 CA
        POP BC                      ; 188E  C1
        JR LOC_18EF                 ; 188F  18 5E
        INC HL                      ; 1891  23
        PUSH HL                     ; 1892  E5
        LD L,(HL)                   ; 1893  6E
        LD D,00H                    ; 1894  16 00
        LD H,D                      ; 1896  62
        INC HL                      ; 1897  23
        INC DE                      ; 1898  13
        CALL SUB_2817               ; 1899  CD 17 28
        LD A,(DATA_1851)            ; 189C  3A 51 18
        OR A                        ; 189F  B7
        JP NZ,LOC_18AF              ; 18A0  C2 AF 18
        LD HL,0005H                 ; 18A3  21 05 00
        CALL SUB_2817               ; 18A6  CD 17 28
        POP HL                      ; 18A9  E1
        ADD HL,DE                   ; 18AA  19
        INC HL                      ; 18AB  23
        JP LOC_1888                 ; 18AC  C3 88 18
LOC_18AF:
        POP HL                      ; 18AF  E1
        INC HL                      ; 18B0  23
        LD B,00H                    ; 18B1  06 00
LOC_18B3:
        LD C,(HL)                   ; 18B3  4E
        INC HL                      ; 18B4  23
        INC HL                      ; 18B5  23
        ADD HL,BC                   ; 18B6  09
        DEC DE                      ; 18B7  1B
        LD A,D                      ; 18B8  7A
        OR E                        ; 18B9  B3
        JR NZ,LOC_18B3              ; 18BA  20 F7
        JP LOC_1888                 ; 18BC  C3 88 18
        XOR A                       ; 18BF  AF
        RET                         ; 18C0  C9
        LD C,(HL)                   ; 18C1  4E
        INC HL                      ; 18C2  23
        LD B,(HL)                   ; 18C3  46
        INC HL                      ; 18C4  23
        LD DE,(DATA_1852)           ; 18C5  ED 5B 52 18
        LD A,B                      ; 18C9  78
        CP D                        ; 18CA  BA
        JR C,LOC_18CF               ; 18CB  38 02
        LD A,C                      ; 18CD  79
        CP E                        ; 18CE  BB
LOC_18CF:
        JP C,LOC_238A               ; 18CF  DA 8A 23
        LD A,01H                    ; 18D2  3E 01
        OR A                        ; 18D4  B7
        RET                         ; 18D5  C9
SUB_18D6:
        INC C                       ; 18D6  0C
        PUSH BC                     ; 18D7  C5
        PUSH DE                     ; 18D8  D5
        INC HL                      ; 18D9  23
        CALL SUB_1221               ; 18DA  CD 21 12
        LD A,E                      ; 18DD  7B
        POP DE                      ; 18DE  D1
        LD D,A                      ; 18DF  57
        POP BC                      ; 18E0  C1
        RET                         ; 18E1  C9
        CALL SUB_1204               ; 18E2  CD 04 12
        PUSH DE                     ; 18E5  D5
        CALL SUB_27E1               ; 18E6  CD E1 27
        INC L                       ; 18E9  2C
        CALL SUB_1204               ; 18EA  CD 04 12
        LD A,D                      ; 18ED  7A
        OR A                        ; 18EE  B7
LOC_18EF:
        JP NZ,LOC_237A              ; 18EF  C2 7A 23
        EX (SP),HL                  ; 18F2  E3
        LD (HL),E                   ; 18F3  73
        POP HL                      ; 18F4  E1
        JP LOC_122D                 ; 18F5  C3 2D 12
LOC_18F8:
        PUSH HL                     ; 18F8  E5
        CALL SUB_47DE               ; 18F9  CD DE 47
        CALL SUB_29D0               ; 18FC  CD D0 29
        POP HL                      ; 18FF  E1
        JP LOC_122D                 ; 1900  C3 2D 12
        CALL SUB_165D               ; 1903  CD 5D 16
        JP LOC_1691                 ; 1906  C3 91 16
        NOP                         ; 1909  00
        NOP                         ; 190A  00
LOC_190B:
        PUSH AF                     ; 190B  F5
        PUSH BC                     ; 190C  C5
        PUSH DE                     ; 190D  D5
        PUSH HL                     ; 190E  E5
        OR A                        ; 190F  B7
        JP Z,MON_0E32               ; 1910  CA 32 0E
        JP MON_0E39                 ; 1913  C3 39 0E
LOC_1916:
        SUB 76H                     ; 1916  D6 76
        CP 0BH                      ; 1918  FE 0B
        JP NC,LOC_1428              ; 191A  D2 28 14
        LD DE,5858H                 ; 191D  11 58 58
        JP LOC_128A                 ; 1920  C3 8A 12
SUB_1923:
        LD B,00H                    ; 1923  06 00
        JP SUB_2EC7                 ; 1925  C3 C7 2E
        CALL SUB_2B2A               ; 1928  CD 2A 2B
        CALL SUB_1A01               ; 192B  CD 01 1A
        CALL SUB_296C               ; 192E  CD 6C 29
        LD IX,(FREE_PTR)            ; 1931  DD 2A 6A 63
        BIT 7,(IX+4H)               ; 1935  DD CB 04 7E
        JP Z,LOC_1DD3               ; 1939  CA D3 1D
        LD A,(HL)                   ; 193C  7E
        INC HL                      ; 193D  23
        CP 89H                      ; 193E  FE 89
LOC_1940:
        JP Z,LOC_1531               ; 1940  CA 31 15
        CP 8BH                      ; 1943  FE 8B
        JP Z,LOC_1559               ; 1945  CA 59 15
        CP ADH                      ; 1948  FE AD
        JP NZ,LOC_2372              ; 194A  C2 72 23
LOC_194D:
        CALL SUB_27A7               ; 194D  CD A7 27
        JP C,LOC_1531               ; 1950  DA 31 15
        LD (CUR_STMT),HL            ; 1953  22 27 65
        JP LOC_1259                 ; 1956  C3 59 12
        CALL SUB_277B               ; 1959  CD 7B 27
        SUB 41H                     ; 195C  D6 41
        CP 1AH                      ; 195E  FE 1A
        JP NC,LOC_2372              ; 1960  D2 72 23
        LD E,(HL)                   ; 1963  5E
        INC HL                      ; 1964  23
        CALL SUB_27E1               ; 1965  CD E1 27
        JR Z,LOC_1940               ; 1968  28 D6
        LD B,C                      ; 196A  41
        CP 1AH                      ; 196B  FE 1A
        JP NC,LOC_2372              ; 196D  D2 72 23
        LD D,(HL)                   ; 1970  56
        INC HL                      ; 1971  23
        CALL SUB_27E1               ; 1972  CD E1 27
        ADD HL,HL                   ; 1975  29
        CALL SUB_27E1               ; 1976  CD E1 27
        OR (HL)                     ; 1979  B6
        PUSH HL                     ; 197A  E5
        CALL SUB_278B               ; 197B  CD 8B 27
        POP BC                      ; 197E  C1
        PUSH HL                     ; 197F  E5
        XOR A                       ; 1980  AF
        SBC HL,BC                   ; 1981  ED 42
        PUSH BC                     ; 1983  C5
        PUSH HL                     ; 1984  E5
        LD HL,(WS_635A)             ; 1985  2A 5A 63
LOC_1988:
        LD A,(HL)                   ; 1988  7E
        CP E                        ; 1989  BB
        JP Z,LOC_19AD               ; 198A  CA AD 19
        CP 00H                      ; 198D  FE 00
        JR Z,LOC_1998               ; 198F  28 07
        INC HL                      ; 1991  23
        INC HL                      ; 1992  23
        CALL SUB_2781               ; 1993  CD 81 27
        JR LOC_1988                 ; 1996  18 F0
LOC_1998:
        EX DE,HL                    ; 1998  EB
        LD BC,0003H                 ; 1999  01 03 00
        CALL SUB_28D4               ; 199C  CD D4 28
        CALL SUB_2A31               ; 199F  CD 31 2A
        EX DE,HL                    ; 19A2  EB
        LD (HL),E                   ; 19A3  73
        INC HL                      ; 19A4  23
        LD (HL),D                   ; 19A5  72
        INC HL                      ; 19A6  23
        LD (HL),0DH                 ; 19A7  36 0D
        EX DE,HL                    ; 19A9  EB
        JP LOC_19C3                 ; 19AA  C3 C3 19
LOC_19AD:
        INC HL                      ; 19AD  23
        LD (HL),D                   ; 19AE  72
        INC HL                      ; 19AF  23
        PUSH HL                     ; 19B0  E5
        CALL SUB_278B               ; 19B1  CD 8B 27
        POP DE                      ; 19B4  D1
        XOR A                       ; 19B5  AF
        SBC HL,DE                   ; 19B6  ED 52
        LD B,H                      ; 19B8  44
        LD C,L                      ; 19B9  4D
        CALL SUB_28BE               ; 19BA  CD BE 28
        CALL SUB_279F               ; 19BD  CD 9F 27
        CALL SUB_2A31               ; 19C0  CD 31 2A
LOC_19C3:
        POP BC                      ; 19C3  C1
        POP HL                      ; 19C4  E1
        CALL SUB_28EE               ; 19C5  CD EE 28
        CALL SUB_2A31               ; 19C8  CD 31 2A
        POP HL                      ; 19CB  E1
        JP LOC_122D                 ; 19CC  C3 2D 12
LOC_19CF:
        CALL SUB_2981               ; 19CF  CD 81 29
        JP Z,LOC_122D               ; 19D2  CA 2D 12
        CALL SUB_1A58               ; 19D5  CD 58 1A
        CALL SUB_2981               ; 19D8  CD 81 29
        JR Z,LOC_19DE               ; 19DB  28 01
        INC HL                      ; 19DD  23
LOC_19DE:
        PUSH HL                     ; 19DE  E5
        CALL SUB_2967               ; 19DF  CD 67 29
        CALL SUB_2959               ; 19E2  CD 59 29
        CALL MELDY                  ; 19E5  CD 30 00
        JP C,LOC_2354               ; 19E8  DA 54 23
        POP HL                      ; 19EB  E1
        JP LOC_19CF                 ; 19EC  C3 CF 19
        CALL SUB_1221               ; 19EF  CD 21 12
        LD A,E                      ; 19F2  7B
        DEC A                       ; 19F3  3D
        CP 07H                      ; 19F4  FE 07
        JP NC,LOC_237A              ; 19F6  D2 7A 23
        INC A                       ; 19F9  3C
        CALL XTEMP                  ; 19FA  CD 41 00
        JP LOC_13F8                 ; 19FD  C3 F8 13
SUB_1A00:
        INC HL                      ; 1A00  23
SUB_1A01:
        CALL SUB_1A58               ; 1A01  CD 58 1A
LOC_1A04:
        CP B0H                      ; 1A04  FE B0
        RET C                       ; 1A06  D8
        CP BCH                      ; 1A07  FE BC
        RET NC                      ; 1A09  D0
        EX AF,AF_                   ; 1A0A  08
        LD A,D                      ; 1A0B  7A
        OR A                        ; 1A0C  B7
        JP NZ,LOC_1A1B              ; 1A0D  C2 1B 1A
        EX AF,AF_                   ; 1A10  08
        EXX                         ; 1A11  D9
        LD BC,1A04H                 ; 1A12  01 04 1A
        LD DE,1A57H                 ; 1A15  11 57 1A
        JP LOC_1AE2                 ; 1A18  C3 E2 1A
LOC_1A1B:
        EX AF,AF_                   ; 1A1B  08
        CP B6H                      ; 1A1C  FE B6
        JP NZ,LOC_5CBF              ; 1A1E  C2 BF 5C
        LD A,C                      ; 1A21  79
        PUSH DE                     ; 1A22  D5
        PUSH AF                     ; 1A23  F5
        CALL SUB_1A57               ; 1A24  CD 57 1A
        CALL SUB_2967               ; 1A27  CD 67 29
        POP AF                      ; 1A2A  F1
        EX (SP),HL                  ; 1A2B  E3
        LD B,A                      ; 1A2C  47
        SUB C                       ; 1A2D  91
        JP NZ,LOC_1A4A              ; 1A2E  C2 4A 1A
        OR B                        ; 1A31  B0
        JP Z,LOC_1A45               ; 1A32  CA 45 1A
        CALL SUB_2959               ; 1A35  CD 59 29
        EX DE,HL                    ; 1A38  EB
        CALL SUB_2959               ; 1A39  CD 59 29
LOC_1A3C:
        LD A,(DE)                   ; 1A3C  1A
        CP (HL)                     ; 1A3D  BE
        INC HL                      ; 1A3E  23
        INC DE                      ; 1A3F  13
        JP NZ,LOC_1A4A              ; 1A40  C2 4A 1A
        DJNZ LOC_1A3C               ; 1A43  10 F7
LOC_1A45:
        LD DE,276CH                 ; 1A45  11 6C 27
        JR Z,LOC_1A4D               ; 1A48  28 03
LOC_1A4A:
        LD DE,2767H                 ; 1A4A  11 67 27
LOC_1A4D:
        CALL SUB_2972               ; 1A4D  CD 72 29
        POP HL                      ; 1A50  E1
        CALL SUB_1B24               ; 1A51  CD 24 1B
        JP LOC_1A04                 ; 1A54  C3 04 1A
; --- SUB_1A57: called from 3 places ---
SUB_1A57:
        INC HL                      ; 1A57  23
; --- SUB_1A58: called from 33 places ---
SUB_1A58:
        LD A,(HL)                   ; 1A58  7E
        CP 20H                      ; 1A59  FE 20
        JR Z,SUB_1A57               ; 1A5B  28 FA
        CP BCH                      ; 1A5D  FE BC
        JP Z,LOC_1A70               ; 1A5F  CA 70 1A
        CP BDH                      ; 1A62  FE BD
        JP NZ,LOC_1A71              ; 1A64  C2 71 1A
        CALL SUB_1ABE               ; 1A67  CD BE 1A
        CALL SUB_1B3C               ; 1A6A  CD 3C 1B
        JP LOC_1A74                 ; 1A6D  C3 74 1A
LOC_1A70:
        INC HL                      ; 1A70  23
LOC_1A71:
        CALL SUB_1ABF               ; 1A71  CD BF 1A
LOC_1A74:
        CP BCH                      ; 1A74  FE BC
        RET C                       ; 1A76  D8
        CP BEH                      ; 1A77  FE BE
        RET NC                      ; 1A79  D0
        EX AF,AF_                   ; 1A7A  08
        LD A,D                      ; 1A7B  7A
        OR A                        ; 1A7C  B7
        JP NZ,LOC_1A8B              ; 1A7D  C2 8B 1A
        EX AF,AF_                   ; 1A80  08
        EXX                         ; 1A81  D9
        LD BC,1A74H                 ; 1A82  01 74 1A
        LD DE,1ABEH                 ; 1A85  11 BE 1A
        JP LOC_1AE2                 ; 1A88  C3 E2 1A
LOC_1A8B:
        EX AF,AF_                   ; 1A8B  08
        CP BCH                      ; 1A8C  FE BC
        JP NZ,LOC_2372              ; 1A8E  C2 72 23
        PUSH DE                     ; 1A91  D5
        PUSH BC                     ; 1A92  C5
        CALL SUB_1ABE               ; 1A93  CD BE 1A
        CALL SUB_2967               ; 1A96  CD 67 29
        LD A,C                      ; 1A99  79
        EXX                         ; 1A9A  D9
        POP BC                      ; 1A9B  C1
        POP DE                      ; 1A9C  D1
        ADD A,C                     ; 1A9D  81
        JP C,LOC_2382               ; 1A9E  DA 82 23
        LD H,B                      ; 1AA1  60
        LD L,A                      ; 1AA2  6F
        PUSH HL                     ; 1AA3  E5
        EXX                         ; 1AA4  D9
        PUSH HL                     ; 1AA5  E5
        PUSH DE                     ; 1AA6  D5
        EXX                         ; 1AA7  D9
        POP HL                      ; 1AA8  E1
        PUSH HL                     ; 1AA9  E5
        CALL SUB_2959               ; 1AAA  CD 59 29
        EX DE,HL                    ; 1AAD  EB
        CALL SUB_2959               ; 1AAE  CD 59 29
        CALL SUB_28EE               ; 1AB1  CD EE 28
        CALL SUB_2A31               ; 1AB4  CD 31 2A
        POP DE                      ; 1AB7  D1
        POP HL                      ; 1AB8  E1
        POP BC                      ; 1AB9  C1
        LD A,(HL)                   ; 1ABA  7E
        JP LOC_1A74                 ; 1ABB  C3 74 1A
SUB_1ABE:
        INC HL                      ; 1ABE  23
SUB_1ABF:
        CALL SUB_1AD3               ; 1ABF  CD D3 1A
        CP BEH                      ; 1AC2  FE BE
        RET C                       ; 1AC4  D8
        CP C0H                      ; 1AC5  FE C0
        RET NC                      ; 1AC7  D0
        EXX                         ; 1AC8  D9
        LD BC,1AC2H                 ; 1AC9  01 C2 1A
        LD DE,1AD2H                 ; 1ACC  11 D2 1A
        JP LOC_1AE2                 ; 1ACF  C3 E2 1A
        INC HL                      ; 1AD2  23
SUB_1AD3:
        CALL SUB_1B2C               ; 1AD3  CD 2C 1B
        CP CFH                      ; 1AD6  FE CF
        RET NZ                      ; 1AD8  C0
        LD A,CFH                    ; 1AD9  3E CF
        EXX                         ; 1ADB  D9
        LD BC,1AD6H                 ; 1ADC  01 D6 1A
        LD DE,1B2BH                 ; 1ADF  11 2B 1B
LOC_1AE2:
        PUSH BC                     ; 1AE2  C5
        LD HL,(FREE_PTR)            ; 1AE3  2A 6A 63
        LD BC,0005H                 ; 1AE6  01 05 00
        ADD HL,BC                   ; 1AE9  09
        LD (FREE_PTR),HL            ; 1AEA  22 6A 63
        SUB B0H                     ; 1AED  D6 B0
        ADD A,A                     ; 1AEF  87
        LD HL,58CCH                 ; 1AF0  21 CC 58
        LD C,A                      ; 1AF3  4F
        ADD HL,BC                   ; 1AF4  09
        LD C,(HL)                   ; 1AF5  4E
        INC HL                      ; 1AF6  23
        LD B,(HL)                   ; 1AF7  46
        PUSH BC                     ; 1AF8  C5
        LD HL,1B05H                 ; 1AF9  21 05 1B
        PUSH HL                     ; 1AFC  E5
        PUSH DE                     ; 1AFD  D5
        EXX                         ; 1AFE  D9
        LD A,D                      ; 1AFF  7A
        OR A                        ; 1B00  B7
        RET Z                       ; 1B01  C8
        JP LOC_237E                 ; 1B02  C3 7E 23
        LD A,D                      ; 1B05  7A
        OR A                        ; 1B06  B7
        JP NZ,LOC_237E              ; 1B07  C2 7E 23
        POP IY                      ; 1B0A  FD E1
        PUSH HL                     ; 1B0C  E5
        LD HL,(FREE_PTR)            ; 1B0D  2A 6A 63
        LD BC,FFFBH                 ; 1B10  01 FB FF
        LD E,L                      ; 1B13  5D
        LD D,H                      ; 1B14  54
        ADD HL,BC                   ; 1B15  09
        LD (FREE_PTR),HL            ; 1B16  22 6A 63
        EX DE,HL                    ; 1B19  EB
        LD BC,1B23H                 ; 1B1A  01 23 1B
        PUSH BC                     ; 1B1D  C5
        JP (IY+0H)                  ; 1B1E  FD E9
LOC_1B20:
        CALL SUB_2972               ; 1B20  CD 72 29
LOC_1B23:
        POP HL                      ; 1B23  E1
SUB_1B24:
        LD BC,0005H                 ; 1B24  01 05 00
        LD D,B                      ; 1B27  50
        LD E,B                      ; 1B28  58
        LD A,(HL)                   ; 1B29  7E
        RET                         ; 1B2A  C9
        INC HL                      ; 1B2B  23
SUB_1B2C:
        CALL SUB_277B               ; 1B2C  CD 7B 27
        CP BCH                      ; 1B2F  FE BC
        JP Z,SUB_1B51               ; 1B31  CA 51 1B
        CP BDH                      ; 1B34  FE BD
        JP NZ,LOC_1B52              ; 1B36  C2 52 1B
        CALL SUB_1B51               ; 1B39  CD 51 1B
SUB_1B3C:
        EXX                         ; 1B3C  D9
        LD HL,(FREE_PTR)            ; 1B3D  2A 6A 63
        PUSH HL                     ; 1B40  E5
        LD BC,0004H                 ; 1B41  01 04 00
        ADD HL,BC                   ; 1B44  09
        LD A,(HL)                   ; 1B45  7E
        POP HL                      ; 1B46  E1
        OR A                        ; 1B47  B7
        JR Z,LOC_1B4E               ; 1B48  28 04
        LD A,(HL)                   ; 1B4A  7E
        ADD A,80H                   ; 1B4B  C6 80
        LD (HL),A                   ; 1B4D  77
LOC_1B4E:
        EXX                         ; 1B4E  D9
        LD A,(HL)                   ; 1B4F  7E
        RET                         ; 1B50  C9
SUB_1B51:
        INC HL                      ; 1B51  23
LOC_1B52:
        CALL SUB_1D78               ; 1B52  CD 78 1D
        JP NC,LOC_1B75              ; 1B55  D2 75 1B
        LD A,46H                    ; 1B58  3E 46
        CP E                        ; 1B5A  BB
        JR NZ,LOC_1B63              ; 1B5B  20 06
        LD A,4EH                    ; 1B5D  3E 4E
        CP D                        ; 1B5F  BA
        JP Z,LOC_1C1F               ; 1B60  CA 1F 1C
LOC_1B63:
        CALL SUB_1BDF               ; 1B63  CD DF 1B
        PUSH HL                     ; 1B66  E5
        LD A,B                      ; 1B67  78
        OR A                        ; 1B68  B7
        JP Z,LOC_1B20               ; 1B69  CA 20 1B
        EX DE,HL                    ; 1B6C  EB
        LD B,00H                    ; 1B6D  06 00
        CALL SUB_2A74               ; 1B6F  CD 74 2A
        POP HL                      ; 1B72  E1
        LD A,(HL)                   ; 1B73  7E
        RET                         ; 1B74  C9
LOC_1B75:
        CP 28H                      ; 1B75  FE 28
        JP Z,LOC_1B9B               ; 1B77  CA 9B 1B
        CP 22H                      ; 1B7A  FE 22
        JP Z,SUB_2A59               ; 1B7C  CA 59 2A
        CALL SUB_2AD0               ; 1B7F  CD D0 2A
        JP NZ,LOC_1B8C              ; 1B82  C2 8C 1B
        LD DE,(FREE_PTR)            ; 1B85  ED 5B 6A 63
        JP LOC_2DC7                 ; 1B89  C3 C7 2D
LOC_1B8C:
        CP FFH                      ; 1B8C  FE FF
        JP NZ,LOC_1BA9              ; 1B8E  C2 A9 1B
        CALL SUB_277A               ; 1B91  CD 7A 27
        PUSH HL                     ; 1B94  E5
        LD DE,2771H                 ; 1B95  11 71 27
        JP LOC_1B20                 ; 1B98  C3 20 1B
LOC_1B9B:
        LD BC,0000H                 ; 1B9B  01 00 00
        CALL SUB_28AA               ; 1B9E  CD AA 28
        CALL SUB_1A00               ; 1BA1  CD 00 1A
        CALL SUB_27E1               ; 1BA4  CD E1 27
        ADD HL,HL                   ; 1BA7  29
        RET                         ; 1BA8  C9
LOC_1BA9:
        SUB C0H                     ; 1BA9  D6 C0
        CP 0FH                      ; 1BAB  FE 0F
        JP NC,LOC_1BB6              ; 1BAD  D2 B6 1B
        LD DE,58ECH                 ; 1BB0  11 EC 58
        JP LOC_128A                 ; 1BB3  C3 8A 12
LOC_1BB6:
        SUB 10H                     ; 1BB6  D6 10
        CP 0EH                      ; 1BB8  FE 0E
        JP NC,LOC_596C              ; 1BBA  D2 6C 59
        PUSH AF                     ; 1BBD  F5
        CALL SUB_1A57               ; 1BBE  CD 57 1A
        CALL SUB_296C               ; 1BC1  CD 6C 29
        CALL SUB_27E1               ; 1BC4  CD E1 27
        ADD HL,HL                   ; 1BC7  29
        POP AF                      ; 1BC8  F1
        PUSH HL                     ; 1BC9  E5
        LD HL,1B23H                 ; 1BCA  21 23 1B
        PUSH HL                     ; 1BCD  E5
        LD HL,(FREE_PTR)            ; 1BCE  2A 6A 63
        EX DE,HL                    ; 1BD1  EB
        LD HL,590CH                 ; 1BD2  21 0C 59
        ADD A,A                     ; 1BD5  87
        LD C,A                      ; 1BD6  4F
        LD B,00H                    ; 1BD7  06 00
        ADD HL,BC                   ; 1BD9  09
        LD A,(HL)                   ; 1BDA  7E
        INC HL                      ; 1BDB  23
        LD H,(HL)                   ; 1BDC  66
        LD L,A                      ; 1BDD  6F
        JP (HL)                     ; 1BDE  E9
; --- SUB_1BDF: called from 7 places ---
SUB_1BDF:
        LD A,(HL)                   ; 1BDF  7E
        CP 24H                      ; 1BE0  FE 24
        JP Z,LOC_1CA0               ; 1BE2  CA A0 1C
        CP 28H                      ; 1BE5  FE 28
        JP Z,LOC_1D33               ; 1BE7  CA 33 1D
; --- SUB_1BEA: called from 4 places ---
SUB_1BEA:
        PUSH HL                     ; 1BEA  E5
        LD HL,(WS_6360)             ; 1BEB  2A 60 63
        LD BC,0005H                 ; 1BEE  01 05 00
LOC_1BF1:
        LD A,(HL)                   ; 1BF1  7E
        CP E                        ; 1BF2  BB
        INC HL                      ; 1BF3  23
        JR NZ,LOC_1BFB              ; 1BF4  20 05
        LD A,(HL)                   ; 1BF6  7E
        CP D                        ; 1BF7  BA
        JP Z,LOC_1C1A               ; 1BF8  CA 1A 1C
LOC_1BFB:
        OR A                        ; 1BFB  B7
        JR Z,LOC_1C03               ; 1BFC  28 05
        INC HL                      ; 1BFE  23
        ADD HL,BC                   ; 1BFF  09
        JP LOC_1BF1                 ; 1C00  C3 F1 1B
LOC_1C03:
        LD C,07H                    ; 1C03  0E 07
        DEC HL                      ; 1C05  2B
        PUSH DE                     ; 1C06  D5
        EX DE,HL                    ; 1C07  EB
        LD HL,2767H                 ; 1C08  21 67 27
        DEC HL                      ; 1C0B  2B
        DEC HL                      ; 1C0C  2B
        CALL SUB_28EE               ; 1C0D  CD EE 28
        CALL SUB_2A31               ; 1C10  CD 31 2A
        EX DE,HL                    ; 1C13  EB
        POP DE                      ; 1C14  D1
        LD (HL),E                   ; 1C15  73
        INC HL                      ; 1C16  23
        LD (HL),D                   ; 1C17  72
        LD C,05H                    ; 1C18  0E 05
LOC_1C1A:
        INC HL                      ; 1C1A  23
        EX DE,HL                    ; 1C1B  EB
        POP HL                      ; 1C1C  E1
        LD A,(HL)                   ; 1C1D  7E
        RET                         ; 1C1E  C9
LOC_1C1F:
        LD A,(HL)                   ; 1C1F  7E
        SUB 41H                     ; 1C20  D6 41
        CP 1AH                      ; 1C22  FE 1A
        JP NC,LOC_2372              ; 1C24  D2 72 23
        LD E,(HL)                   ; 1C27  5E
        INC HL                      ; 1C28  23
        CALL SUB_27E1               ; 1C29  CD E1 27
        JR Z,LOC_1C03               ; 1C2C  28 D5
        CALL SUB_1A58               ; 1C2E  CD 58 1A
        CALL SUB_296C               ; 1C31  CD 6C 29
        CALL SUB_27E1               ; 1C34  CD E1 27
        ADD HL,HL                   ; 1C37  29
        POP DE                      ; 1C38  D1
        PUSH HL                     ; 1C39  E5
        LD HL,(WS_635A)             ; 1C3A  2A 5A 63
LOC_1C3D:
        LD A,(HL)                   ; 1C3D  7E
        CP 00H                      ; 1C3E  FE 00
        JP Z,LOC_23AA               ; 1C40  CA AA 23
        CP E                        ; 1C43  BB
        JR Z,LOC_1C4D               ; 1C44  28 07
        INC HL                      ; 1C46  23
        INC HL                      ; 1C47  23
        CALL SUB_2781               ; 1C48  CD 81 27
        JR LOC_1C3D                 ; 1C4B  18 F0
LOC_1C4D:
        INC HL                      ; 1C4D  23
        LD E,(HL)                   ; 1C4E  5E
        INC HL                      ; 1C4F  23
        PUSH HL                     ; 1C50  E5
        PUSH DE                     ; 1C51  D5
        LD D,20H                    ; 1C52  16 20
        CALL SUB_1BEA               ; 1C54  CD EA 1B
        POP HL                      ; 1C57  E1
        PUSH DE                     ; 1C58  D5
        PUSH HL                     ; 1C59  E5
        LD HL,(WS_636C)             ; 1C5A  2A 6C 63
        LD DE,6372H                 ; 1C5D  11 72 63
        CALL SUB_27B0               ; 1C60  CD B0 27
        JP Z,LOC_239E               ; 1C63  CA 9E 23
        LD BC,FFFAH                 ; 1C66  01 FA FF
        ADD HL,BC                   ; 1C69  09
        LD (WS_636C),HL             ; 1C6A  22 6C 63
        POP DE                      ; 1C6D  D1
        LD (HL),E                   ; 1C6E  73
        INC HL                      ; 1C6F  23
        POP DE                      ; 1C70  D1
        LD BC,0005H                 ; 1C71  01 05 00
        EX DE,HL                    ; 1C74  EB
        CALL SUB_28F1               ; 1C75  CD F1 28
        EX DE,HL                    ; 1C78  EB
        LD HL,(FREE_PTR)            ; 1C79  2A 6A 63
        CALL SUB_28F1               ; 1C7C  CD F1 28
        POP HL                      ; 1C7F  E1
        CALL SUB_1A58               ; 1C80  CD 58 1A
        CALL SUB_296C               ; 1C83  CD 6C 29
        CALL SUB_2981               ; 1C86  CD 81 29
        JP NZ,LOC_2372              ; 1C89  C2 72 23
        LD HL,(WS_636C)             ; 1C8C  2A 6C 63
        LD E,(HL)                   ; 1C8F  5E
        INC HL                      ; 1C90  23
        LD D,20H                    ; 1C91  16 20
        CALL SUB_1BEA               ; 1C93  CD EA 1B
        CALL SUB_28F1               ; 1C96  CD F1 28
        ADD HL,BC                   ; 1C99  09
        LD (WS_636C),HL             ; 1C9A  22 6C 63
        JP LOC_1B23                 ; 1C9D  C3 23 1B
LOC_1CA0:
        CALL SUB_277A               ; 1CA0  CD 7A 27
        CP 28H                      ; 1CA3  FE 28
        JP Z,LOC_1D2E               ; 1CA5  CA 2E 1D
        PUSH HL                     ; 1CA8  E5
        LD HL,4954H                 ; 1CA9  21 54 49
        XOR A                       ; 1CAC  AF
        SBC HL,DE                   ; 1CAD  ED 52
        JP Z,LOC_1CE7               ; 1CAF  CA E7 1C
        EX DE,HL                    ; 1CB2  EB
        LD (WS_62B6),HL             ; 1CB3  22 B6 62
        LD HL,(WS_6366)             ; 1CB6  2A 66 63
LOC_1CB9:
        CALL SUB_291C               ; 1CB9  CD 1C 29
        JP Z,WS_CA1C                ; 1CBC  CA 1C CA
        RST 18H                     ; 1CBF  DF
        INC E                       ; 1CC0  1C
        LD B,00H                    ; 1CC1  06 00
        LD C,(HL)                   ; 1CC3  4E
        ADD HL,BC                   ; 1CC4  09
        INC HL                      ; 1CC5  23
        INC HL                      ; 1CC6  23
        JP LOC_1CB9                 ; 1CC7  C3 B9 1C
        LD BC,0004H                 ; 1CCA  01 04 00
        EX DE,HL                    ; 1CCD  EB
        LD HL,62B6H                 ; 1CCE  21 B6 62
        CALL SUB_28EE               ; 1CD1  CD EE 28
        CALL SUB_2A31               ; 1CD4  CD 31 2A
        EX DE,HL                    ; 1CD7  EB
        INC HL                      ; 1CD8  23
        INC HL                      ; 1CD9  23
        LD (HL),B                   ; 1CDA  70
        INC HL                      ; 1CDB  23
        LD (HL),0DH                 ; 1CDC  36 0D
        DEC HL                      ; 1CDE  2B
        LD C,(HL)                   ; 1CDF  4E
        INC HL                      ; 1CE0  23
        LD B,01H                    ; 1CE1  06 01
        EX DE,HL                    ; 1CE3  EB
        POP HL                      ; 1CE4  E1
        LD A,(HL)                   ; 1CE5  7E
        RET                         ; 1CE6  C9
LOC_1CE7:
        CALL TIMRD                  ; 1CE7  CD 3B 00
        EX DE,HL                    ; 1CEA  EB
        OR A                        ; 1CEB  B7
        JR Z,LOC_1CF0               ; 1CEC  28 02
        LD A,0CH                    ; 1CEE  3E 0C
LOC_1CF0:
        EXX                         ; 1CF0  D9
        LD HL,6159H                 ; 1CF1  21 59 61
        PUSH HL                     ; 1CF4  E5
        EXX                         ; 1CF5  D9
        LD DE,F1F0H                 ; 1CF6  11 F0 F1
        CALL SUB_1D0E               ; 1CF9  CD 0E 1D
        LD DE,FFC4H                 ; 1CFC  11 C4 FF
        CALL SUB_1D0D               ; 1CFF  CD 0D 1D
        LD A,L                      ; 1D02  7D
        CALL SUB_1D17               ; 1D03  CD 17 1D
        POP DE                      ; 1D06  D1
        LD BC,0106H                 ; 1D07  01 06 01
        POP HL                      ; 1D0A  E1
        LD A,(HL)                   ; 1D0B  7E
        RET                         ; 1D0C  C9
SUB_1D0D:
        XOR A                       ; 1D0D  AF
SUB_1D0E:
        ADD HL,DE                   ; 1D0E  19
        JR NC,LOC_1D14              ; 1D0F  30 03
        INC A                       ; 1D11  3C
        JR SUB_1D0E                 ; 1D12  18 FA
LOC_1D14:
        OR A                        ; 1D14  B7
        SBC HL,DE                   ; 1D15  ED 52
SUB_1D17:
        LD BC,30F6H                 ; 1D17  01 F6 30
LOC_1D1A:
        ADD A,C                     ; 1D1A  81
        JR NC,LOC_1D20              ; 1D1B  30 03
        INC B                       ; 1D1D  04
        JR LOC_1D1A                 ; 1D1E  18 FA
LOC_1D20:
        ADD A,3AH                   ; 1D20  C6 3A
        EX AF,AF_                   ; 1D22  08
        LD A,B                      ; 1D23  78
        EXX                         ; 1D24  D9
        LD (HL),A                   ; 1D25  77
        INC HL                      ; 1D26  23
        EX AF,AF_                   ; 1D27  08
        LD (HL),A                   ; 1D28  77
        INC HL                      ; 1D29  23
        LD (HL),0DH                 ; 1D2A  36 0D
        EXX                         ; 1D2C  D9
        RET                         ; 1D2D  C9
LOC_1D2E:
        LD BC,0100H                 ; 1D2E  01 00 01
        JR LOC_1D36                 ; 1D31  18 03
LOC_1D33:
        LD BC,0000H                 ; 1D33  01 00 00
LOC_1D36:
        INC HL                      ; 1D36  23
        CALL SUB_1854               ; 1D37  CD 54 18
        JP Z,LOC_238A               ; 1D3A  CA 8A 23
        PUSH HL                     ; 1D3D  E5
        LD L,C                      ; 1D3E  69
        LD H,00H                    ; 1D3F  26 00
        LD C,E                      ; 1D41  4B
        LD E,D                      ; 1D42  5A
        LD B,H                      ; 1D43  44
        LD D,H                      ; 1D44  54
        PUSH BC                     ; 1D45  C5
        INC HL                      ; 1D46  23
        CALL SUB_2817               ; 1D47  CD 17 28
        POP HL                      ; 1D4A  E1
        ADD HL,DE                   ; 1D4B  19
        EX DE,HL                    ; 1D4C  EB
        LD A,(DATA_1851)            ; 1D4D  3A 51 18
        OR A                        ; 1D50  B7
        JP NZ,LOC_1D62              ; 1D51  C2 62 1D
        LD HL,0005H                 ; 1D54  21 05 00
        CALL SUB_2817               ; 1D57  CD 17 28
        POP HL                      ; 1D5A  E1
        ADD HL,DE                   ; 1D5B  19
        LD BC,0005H                 ; 1D5C  01 05 00
        JP LOC_1D71                 ; 1D5F  C3 71 1D
LOC_1D62:
        POP HL                      ; 1D62  E1
        LD B,00H                    ; 1D63  06 00
LOC_1D65:
        LD C,(HL)                   ; 1D65  4E
        INC HL                      ; 1D66  23
        LD A,D                      ; 1D67  7A
        OR E                        ; 1D68  B3
        JR Z,LOC_1D70               ; 1D69  28 05
        ADD HL,BC                   ; 1D6B  09
        INC HL                      ; 1D6C  23
        DEC DE                      ; 1D6D  1B
        JR LOC_1D65                 ; 1D6E  18 F5
LOC_1D70:
        INC B                       ; 1D70  04
LOC_1D71:
        EX DE,HL                    ; 1D71  EB
        LD HL,(184FH)               ; 1D72  2A 4F 18
        LD A,(HL)                   ; 1D75  7E
        RET                         ; 1D76  C9
LOC_1D77:
        INC HL                      ; 1D77  23
; --- SUB_1D78: called from 3 places ---
SUB_1D78:
        LD A,(HL)                   ; 1D78  7E
        CP 20H                      ; 1D79  FE 20
        JR Z,LOC_1D77               ; 1D7B  28 FA
        SUB 41H                     ; 1D7D  D6 41
        CP 1AH                      ; 1D7F  FE 1A
        LD A,(HL)                   ; 1D81  7E
        RET NC                      ; 1D82  D0
        LD E,(HL)                   ; 1D83  5E
        LD D,20H                    ; 1D84  16 20
LOC_1D86:
        INC HL                      ; 1D86  23
        LD A,(HL)                   ; 1D87  7E
        CP D                        ; 1D88  BA
        JR Z,LOC_1D86               ; 1D89  28 FB
        SUB 30H                     ; 1D8B  D6 30
        CP 0AH                      ; 1D8D  FE 0A
        JR C,LOC_1D98               ; 1D8F  38 07
        SUB 11H                     ; 1D91  D6 11
        CP 1AH                      ; 1D93  FE 1A
        LD A,(HL)                   ; 1D95  7E
        CCF                         ; 1D96  3F
        RET C                       ; 1D97  D8
LOC_1D98:
        LD D,(HL)                   ; 1D98  56
        LD A,46H                    ; 1D99  3E 46
        CP E                        ; 1D9B  BB
        JR NZ,LOC_1DA4              ; 1D9C  20 06
        LD A,4EH                    ; 1D9E  3E 4E
        CP D                        ; 1DA0  BA
        JP Z,LOC_1DB9               ; 1DA1  CA B9 1D
LOC_1DA4:
        INC HL                      ; 1DA4  23
        LD A,(HL)                   ; 1DA5  7E
        CP 20H                      ; 1DA6  FE 20
        JR Z,LOC_1DA4               ; 1DA8  28 FA
        SUB 30H                     ; 1DAA  D6 30
        CP 0AH                      ; 1DAC  FE 0A
        JR C,LOC_1DA4               ; 1DAE  38 F4
        SUB 11H                     ; 1DB0  D6 11
        CP 1AH                      ; 1DB2  FE 1A
        JR C,LOC_1DA4               ; 1DB4  38 EE
LOC_1DB6:
        LD A,(HL)                   ; 1DB6  7E
        SCF                         ; 1DB7  37
        RET                         ; 1DB8  C9
LOC_1DB9:
        CALL SUB_277A               ; 1DB9  CD 7A 27
        SCF                         ; 1DBC  37
        RET                         ; 1DBD  C9
; --- SUB_1DBE: called from 7 places ---
SUB_1DBE:
        CALL SUB_1D78               ; 1DBE  CD 78 1D
        JP NC,LOC_2372              ; 1DC1  D2 72 23
        LD A,46H                    ; 1DC4  3E 46
        CP E                        ; 1DC6  BB
        JP NZ,LOC_1DB6              ; 1DC7  C2 B6 1D
        LD A,4EH                    ; 1DCA  3E 4E
        CP D                        ; 1DCC  BA
        JP NZ,LOC_1DB6              ; 1DCD  C2 B6 1D
        JP LOC_2372                 ; 1DD0  C3 72 23
LOC_1DD3:
        CALL SUB_278B               ; 1DD3  CD 8B 27
        CP 0DH                      ; 1DD6  FE 0D
        JP Z,LOC_123F               ; 1DD8  CA 3F 12
        CALL SUB_27D2               ; 1DDB  CD D2 27
        XOR H                       ; 1DDE  AC
        CALL PO,WS_C31D             ; 1DDF  E4 1D C3
        LD C,L                      ; 1DE2  4D
        ADD HL,DE                   ; 1DE3  19
        CALL SUB_27E1               ; 1DE4  CD E1 27
        LD A,(WS_D2CD)              ; 1DE7  3A CD D2
        DAA                         ; 1DEA  27
        XOR H                       ; 1DEB  AC
        OUT (1DH),A                 ; 1DEC  D3 1D
        JP LOC_194D                 ; 1DEE  C3 4D 19
LOC_1DF1:
        CALL SUB_27D2               ; 1DF1  CD D2 27
        XOR H                       ; 1DF4  AC
        JP M,WS_C31D                ; 1DF5  FA 1D C3
        CCF                         ; 1DF8  3F
        LD (DE),A                   ; 1DF9  12
        CALL SUB_27E1               ; 1DFA  CD E1 27
        LD A,(39C3H)                ; 1DFD  3A C3 39
        LD (DE),A                   ; 1E00  12
        CALL SUB_2981               ; 1E01  CD 81 29
        JR NZ,LOC_1E0D              ; 1E04  20 07
        LD (CUR_STMT),HL            ; 1E06  22 27 65
        HALT                        ; 1E09  76
        JP LOC_122A                 ; 1E0A  C3 2A 12
LOC_1E0D:
        CALL SUB_1221               ; 1E0D  CD 21 12
        LD (CUR_STMT),HL            ; 1E10  22 27 65
        LD B,E                      ; 1E13  43
        INC B                       ; 1E14  04
LOC_1E15:
        DEC B                       ; 1E15  05
        JP Z,LOC_122A               ; 1E16  CA 2A 12
        CALL TIMRD                  ; 1E19  CD 3B 00
        EX DE,HL                    ; 1E1C  EB
LOC_1E1D:
        CALL TIMRD                  ; 1E1D  CD 3B 00
        CALL SUB_27B0               ; 1E20  CD B0 27
        JR NZ,LOC_1E15              ; 1E23  20 F0
        JR LOC_1E1D                 ; 1E25  18 F6
        LD A,A                      ; 1E27  7F
        RST 38H                     ; 1E28  FF
        RST 38H                     ; 1E29  FF
        RST 38H                     ; 1E2A  FF
        RST 38H                     ; 1E2B  FF
        NOP                         ; 1E2C  00
        CALL SUB_1A58               ; 1E2D  CD 58 1A
        CALL SUB_2967               ; 1E30  CD 67 29
        PUSH DE                     ; 1E33  D5
        PUSH BC                     ; 1E34  C5
LOC_1E35:
        CALL SUB_27E1               ; 1E35  CD E1 27
        INC L                       ; 1E38  2C
        CALL SUB_1221               ; 1E39  CD 21 12
        CALL SUB_27E1               ; 1E3C  CD E1 27
        ADD HL,HL                   ; 1E3F  29
        POP BC                      ; 1E40  C1
        EX (SP),HL                  ; 1E41  E3
        EX DE,HL                    ; 1E42  EB
        LD A,C                      ; 1E43  79
        SUB L                       ; 1E44  95
        JP C,LOC_1E5B               ; 1E45  DA 5B 1E
        PUSH HL                     ; 1E48  E5
        LD C,A                      ; 1E49  4F
        PUSH DE                     ; 1E4A  D5
        CALL SUB_2959               ; 1E4B  CD 59 29
        ADD HL,DE                   ; 1E4E  19
        EX DE,HL                    ; 1E4F  EB
LOC_1E50:
        CALL SUB_28BE               ; 1E50  CD BE 28
        CALL SUB_279F               ; 1E53  CD 9F 27
        CALL SUB_2A31               ; 1E56  CD 31 2A
        POP DE                      ; 1E59  D1
        POP BC                      ; 1E5A  C1
LOC_1E5B:
        POP HL                      ; 1E5B  E1
        JP SUB_277B                 ; 1E5C  C3 7B 27
        CALL SUB_1A58               ; 1E5F  CD 58 1A
        CALL SUB_2967               ; 1E62  CD 67 29
        PUSH DE                     ; 1E65  D5
        PUSH BC                     ; 1E66  C5
        CALL SUB_27E1               ; 1E67  CD E1 27
        INC L                       ; 1E6A  2C
        CALL SUB_1221               ; 1E6B  CD 21 12
        CALL SUB_27E1               ; 1E6E  CD E1 27
        ADD HL,HL                   ; 1E71  29
        POP BC                      ; 1E72  C1
        EX (SP),HL                  ; 1E73  E3
        EX DE,HL                    ; 1E74  EB
        LD A,C                      ; 1E75  79
        SUB L                       ; 1E76  95
        JP C,LOC_1E5B               ; 1E77  DA 5B 1E
        PUSH HL                     ; 1E7A  E5
        LD C,A                      ; 1E7B  4F
        PUSH DE                     ; 1E7C  D5
        CALL SUB_2959               ; 1E7D  CD 59 29
        JP LOC_1E50                 ; 1E80  C3 50 1E
        CALL SUB_1A58               ; 1E83  CD 58 1A
        CALL SUB_2967               ; 1E86  CD 67 29
        PUSH DE                     ; 1E89  D5
        PUSH BC                     ; 1E8A  C5
        CALL SUB_27E1               ; 1E8B  CD E1 27
        INC L                       ; 1E8E  2C
        CALL SUB_1221               ; 1E8F  CD 21 12
        LD A,E                      ; 1E92  7B
        DEC A                       ; 1E93  3D
        JP Z,LOC_1EBB               ; 1E94  CA BB 1E
        JP C,LOC_1EBB               ; 1E97  DA BB 1E
        POP BC                      ; 1E9A  C1
        LD E,A                      ; 1E9B  5F
        LD A,C                      ; 1E9C  79
        SUB E                       ; 1E9D  93
        JP NC,LOC_1EA3              ; 1E9E  D2 A3 1E
        XOR A                       ; 1EA1  AF
        LD E,C                      ; 1EA2  59
LOC_1EA3:
        LD C,E                      ; 1EA3  4B
        LD B,D                      ; 1EA4  42
        POP DE                      ; 1EA5  D1
        PUSH DE                     ; 1EA6  D5
        PUSH AF                     ; 1EA7  F5
        PUSH BC                     ; 1EA8  C5
        CALL SUB_2959               ; 1EA9  CD 59 29
        POP BC                      ; 1EAC  C1
        CALL SUB_28BE               ; 1EAD  CD BE 28
        CALL SUB_279F               ; 1EB0  CD 9F 27
        CALL SUB_2A31               ; 1EB3  CD 31 2A
        POP AF                      ; 1EB6  F1
        LD C,A                      ; 1EB7  4F
        LD B,00H                    ; 1EB8  06 00
        PUSH BC                     ; 1EBA  C5
LOC_1EBB:
        JP LOC_1E35                 ; 1EBB  C3 35 1E
        JP LOC_2372                 ; 1EBE  C3 72 23
        JP LOC_2372                 ; 1EC1  C3 72 23
        JP LOC_2372                 ; 1EC4  C3 72 23
        CALL SUB_1A58               ; 1EC7  CD 58 1A
        CALL SUB_2967               ; 1ECA  CD 67 29
        CALL SUB_27E1               ; 1ECD  CD E1 27
        ADD HL,HL                   ; 1ED0  29
        PUSH HL                     ; 1ED1  E5
        LD A,C                      ; 1ED2  79
        JP LOC_1F43                 ; 1ED3  C3 43 1F
        CALL SUB_1221               ; 1ED6  CD 21 12
        CALL SUB_27E1               ; 1ED9  CD E1 27
        ADD HL,HL                   ; 1EDC  29
        PUSH HL                     ; 1EDD  E5
        LD BC,0001H                 ; 1EDE  01 01 00
        LD A,E                      ; 1EE1  7B
        CP 20H                      ; 1EE2  FE 20
        JR NC,LOC_1EE9              ; 1EE4  30 03
        DEC BC                      ; 1EE6  0B
        LD E,0DH                    ; 1EE7  1E 0D
LOC_1EE9:
        LD HL,6181H                 ; 1EE9  21 81 61
        LD (HL),0DH                 ; 1EEC  36 0D
        DEC HL                      ; 1EEE  2B
        LD (HL),E                   ; 1EEF  73
        CALL SUB_2A74               ; 1EF0  CD 74 2A
        POP HL                      ; 1EF3  E1
        LD A,(HL)                   ; 1EF4  7E
        RET                         ; 1EF5  C9
        CALL SUB_1A58               ; 1EF6  CD 58 1A
        CALL SUB_296C               ; 1EF9  CD 6C 29
        CALL SUB_27E1               ; 1EFC  CD E1 27
        ADD HL,HL                   ; 1EFF  29
        PUSH HL                     ; 1F00  E5
        LD HL,(FREE_PTR)            ; 1F01  2A 6A 63
        LD DE,6180H                 ; 1F04  11 80 61
        PUSH DE                     ; 1F07  D5
        CALL SUB_301B               ; 1F08  CD 1B 30
LOC_1F0B:
        POP HL                      ; 1F0B  E1
        CALL SUB_2A59               ; 1F0C  CD 59 2A
        POP HL                      ; 1F0F  E1
        LD A,(HL)                   ; 1F10  7E
        RET                         ; 1F11  C9
        CALL SUB_1A58               ; 1F12  CD 58 1A
        CALL SUB_2967               ; 1F15  CD 67 29
        CALL SUB_27E1               ; 1F18  CD E1 27
        ADD HL,HL                   ; 1F1B  29
        PUSH HL                     ; 1F1C  E5
        CALL SUB_2959               ; 1F1D  CD 59 29
        EX DE,HL                    ; 1F20  EB
        CALL SUB_2AA0               ; 1F21  CD A0 2A
        ADD HL,HL                   ; 1F24  29
        RRA                         ; 1F25  1F
        JP LOC_1E5B                 ; 1F26  C3 5B 1E
        LD DE,2767H                 ; 1F29  11 67 27
        JP LOC_1B20                 ; 1F2C  C3 20 1B
        CALL SUB_1A58               ; 1F2F  CD 58 1A
        CALL SUB_2967               ; 1F32  CD 67 29
        CALL SUB_27E1               ; 1F35  CD E1 27
        ADD HL,HL                   ; 1F38  29
        PUSH HL                     ; 1F39  E5
        CALL SUB_2959               ; 1F3A  CD 59 29
        LD A,(DE)                   ; 1F3D  1A
        CP 0DH                      ; 1F3E  FE 0D
        JP Z,LOC_237A               ; 1F40  CA 7A 23
LOC_1F43:
        OR A                        ; 1F43  B7
        LD BC,8000H                 ; 1F44  01 00 80
        CALL NZ,SUB_1F5F            ; 1F47  C4 5F 1F
        LD HL,(FREE_PTR)            ; 1F4A  2A 6A 63
        LD DE,0003H                 ; 1F4D  11 03 00
        LD (HL),B                   ; 1F50  70
        INC HL                      ; 1F51  23
LOC_1F52:
        LD (HL),D                   ; 1F52  72
        INC HL                      ; 1F53  23
        DEC E                       ; 1F54  1D
        JR NZ,LOC_1F52              ; 1F55  20 FB
        LD (HL),C                   ; 1F57  71
        LD BC,0005H                 ; 1F58  01 05 00
        POP HL                      ; 1F5B  E1
        JP SUB_277B                 ; 1F5C  C3 7B 27
SUB_1F5F:
        LD E,08H                    ; 1F5F  1E 08
LOC_1F61:
        OR A                        ; 1F61  B7
        JP M,LOC_1F6A               ; 1F62  FA 6A 1F
        RLA                         ; 1F65  17
        DEC E                       ; 1F66  1D
        JP LOC_1F61                 ; 1F67  C3 61 1F
LOC_1F6A:
        LD C,A                      ; 1F6A  4F
        LD A,C0H                    ; 1F6B  3E C0
        ADD A,E                     ; 1F6D  83
        LD B,A                      ; 1F6E  47
        RET                         ; 1F6F  C9
        NOP                         ; 1F70  00
        CALL SUB_1204               ; 1F71  CD 04 12
        CALL SUB_27E1               ; 1F74  CD E1 27
        ADD HL,HL                   ; 1F77  29
        PUSH HL                     ; 1F78  E5
        LD A,(DATA_1238)            ; 1F79  3A 38 12
        OR A                        ; 1F7C  B7
        JP NZ,LOC_1F8A              ; 1F7D  C2 8A 1F
        LD HL,(WS_6165)             ; 1F80  2A 65 61
        DEC HL                      ; 1F83  2B
        CALL SUB_27B0               ; 1F84  CD B0 27
        JP NC,LOC_1F8D              ; 1F87  D2 8D 1F
LOC_1F8A:
        LD A,(DE)                   ; 1F8A  1A
        JR LOC_1F8F                 ; 1F8B  18 02
LOC_1F8D:
        LD A,20H                    ; 1F8D  3E 20
LOC_1F8F:
        JP LOC_1F43                 ; 1F8F  C3 43 1F
        JP LOC_2372                 ; 1F92  C3 72 23
        CALL SUB_1221               ; 1F95  CD 21 12
        LD B,20H                    ; 1F98  06 20
        CALL SUB_27E1               ; 1F9A  CD E1 27
        ADD HL,HL                   ; 1F9D  29
        LD A,E                      ; 1F9E  7B
        PUSH HL                     ; 1F9F  E5
        LD HL,6000H                 ; 1FA0  21 00 60
        PUSH HL                     ; 1FA3  E5
        LD C,A                      ; 1FA4  4F
LOC_1FA5:
        OR A                        ; 1FA5  B7
        JP Z,LOC_1FAF               ; 1FA6  CA AF 1F
        LD (HL),B                   ; 1FA9  70
        INC HL                      ; 1FAA  23
        DEC A                       ; 1FAB  3D
        JP LOC_1FA5                 ; 1FAC  C3 A5 1F
LOC_1FAF:
        LD (HL),0DH                 ; 1FAF  36 0D
        LD B,00H                    ; 1FB1  06 00
        POP HL                      ; 1FB3  E1
        CALL SUB_2A74               ; 1FB4  CD 74 2A
        POP HL                      ; 1FB7  E1
        JP SUB_277B                 ; 1FB8  C3 7B 27
        PUSH HL                     ; 1FBB  E5
        CALL SUB_2894               ; 1FBC  CD 94 28
LOC_1FBF:
        CALL SUB_288B               ; 1FBF  CD 8B 28
        EX DE,HL                    ; 1FC2  EB
        CALL SUB_1A58               ; 1FC3  CD 58 1A
        POP HL                      ; 1FC6  E1
        LD A,(HL)                   ; 1FC7  7E
        RET                         ; 1FC8  C9
        PUSH HL                     ; 1FC9  E5
        LD A,(DATA_2345)            ; 1FCA  3A 45 23
        LD HL,0000H                 ; 1FCD  21 00 00
        CP 02H                      ; 1FD0  FE 02
        JP NZ,LOC_1FBF              ; 1FD2  C2 BF 1F
        LD HL,(2349H)               ; 1FD5  2A 49 23
        JP LOC_1FBF                 ; 1FD8  C3 BF 1F
        PUSH HL                     ; 1FDB  E5
        LD A,(DATA_2345)            ; 1FDC  3A 45 23
        LD HL,0000H                 ; 1FDF  21 00 00
        CP 02H                      ; 1FE2  FE 02
        JP NZ,LOC_1FBF              ; 1FE4  C2 BF 1F
        LD A,(2346H)                ; 1FE7  3A 46 23
        LD L,A                      ; 1FEA  6F
        JP LOC_1FBF                 ; 1FEB  C3 BF 1F
        LD A,(DE)                   ; 1FEE  1A
        OR 80H                      ; 1FEF  F6 80
        LD (DE),A                   ; 1FF1  12
        RET                         ; 1FF2  C9
        LD A,(DE)                   ; 1FF3  1A
        LD DE,276CH                 ; 1FF4  11 6C 27
        OR A                        ; 1FF7  B7
        JP P,LOC_2006               ; 1FF8  F2 06 20
        LD DE,2762H                 ; 1FFB  11 62 27
        CP 80H                      ; 1FFE  FE 80
        JP NZ,LOC_2006              ; 2000  C2 06 20
        LD DE,2767H                 ; 2003  11 67 27
LOC_2006:
        JP SUB_2972                 ; 2006  C3 72 29
        JP MONIT                    ; 2009  C3 00 00
        CALL SUB_1221               ; 200C  CD 21 12
        LD A,E                      ; 200F  7B
        CP 28H                      ; 2010  FE 28
        JP NC,LOC_23C6              ; 2012  D2 C6 23
        PUSH AF                     ; 2015  F5
        CALL SUB_27E1               ; 2016  CD E1 27
        INC L                       ; 2019  2C
        CALL SUB_1221               ; 201A  CD 21 12
        LD A,E                      ; 201D  7B
        CP 19H                      ; 201E  FE 19
        JP NC,LOC_23C6              ; 2020  D2 C6 23
        EX DE,HL                    ; 2023  EB
        LD H,L                      ; 2024  65
        POP AF                      ; 2025  F1
        LD L,A                      ; 2026  6F
        LD (CURSOR),HL              ; 2027  22 71 11
        LD (MON_1194),A             ; 202A  32 94 11
        EX DE,HL                    ; 202D  EB
        JP LOC_122D                 ; 202E  C3 2D 12
        CALL SUB_2B2A               ; 2031  CD 2A 2B
        LD (CUR_STMT),HL            ; 2034  22 27 65
        CALL SUB_5FC8               ; 2037  CD C8 5F
        JP LOC_122A                 ; 203A  C3 2A 12
        NOP                         ; 203D  00
        NOP                         ; 203E  00
        NOP                         ; 203F  00
        LD HL,CD21H                 ; 2040  21 21 CD
        CP (HL)                     ; 2043  BE
        DEC E                       ; 2044  1D
        CALL SUB_1BDF               ; 2045  CD DF 1B
        LD (CUR_STMT),HL            ; 2048  22 27 65
        CALL SUB_2B0E               ; 204B  CD 0E 2B
        CALL MON_GETKEY             ; 204E  CD 1B 00
        CP 1BH                      ; 2051  FE 1B
        JR NZ,LOC_2056              ; 2053  20 01
        XOR A                       ; 2055  AF
LOC_2056:
        LD HL,2041H                 ; 2056  21 41 20
        OR A                        ; 2059  B7
        JP NZ,LOC_208B              ; 205A  C2 8B 20
        LD (HL),A                   ; 205D  77
LOC_205E:
        LD A,(WS_6173)              ; 205E  3A 73 61
        LD BC,3000H                 ; 2061  01 00 30
        OR A                        ; 2064  B7
        JR NZ,LOC_2069              ; 2065  20 02
LOC_2067:
        LD C,01H                    ; 2067  0E 01
LOC_2069:
        DEC HL                      ; 2069  2B
        LD (HL),B                   ; 206A  70
        LD B,00H                    ; 206B  06 00
        CALL SUB_2A74               ; 206D  CD 74 2A
        LD A,(WS_6173)              ; 2070  3A 73 61
        OR A                        ; 2073  B7
        JP NZ,LOC_2080              ; 2074  C2 80 20
        CALL SUB_2959               ; 2077  CD 59 29
        EX DE,HL                    ; 207A  EB
LOC_207B:
        CALL SUB_2AA0               ; 207B  CD A0 2A
        DB 2AH,12H                  ; 207E  2A 12   (stray byte(s): disassembly boundary correction)
LOC_2080:
        CALL SUB_2B09               ; 2080  CD 09 2B
        CALL SUB_1453               ; 2083  CD 53 14
        LD A,(HL)                   ; 2086  7E
        INC HL                      ; 2087  23
        JP LOC_122A                 ; 2088  C3 2A 12
LOC_208B:
        CP (HL)                     ; 208B  BE
        JP Z,LOC_205E               ; 208C  CA 5E 20
        LD (HL),A                   ; 208F  77
        LD B,A                      ; 2090  47
        JP LOC_2067                 ; 2091  C3 67 20
        CALL SUB_1204               ; 2094  CD 04 12
        CALL SUB_27E1               ; 2097  CD E1 27
        ADD HL,HL                   ; 209A  29
        LD (CUR_STMT),HL            ; 209B  22 27 65
        CALL SUB_3AC0               ; 209E  CD C0 3A
        LD HL,122AH                 ; 20A1  21 2A 12
        PUSH HL                     ; 20A4  E5
        EX DE,HL                    ; 20A5  EB
        JP (HL)                     ; 20A6  E9
        CALL SUB_27D2               ; 20A7  CD D2 27
        LD C,L                      ; 20AA  4D
        CP L                        ; 20AB  BD
        JR NZ,LOC_207B              ; 20AC  20 CD
        POP HL                      ; 20AE  E1
        DAA                         ; 20AF  27
        LD B,C                      ; 20B0  41
        CALL SUB_27E1               ; 20B1  CD E1 27
        LD E,B                      ; 20B4  58
        LD (CUR_STMT),HL            ; 20B5  22 27 65
        LD HL,(WS_6163)             ; 20B8  2A 63 61
        JR LOC_20DA                 ; 20BB  18 1D
        CALL SUB_1204               ; 20BD  CD 04 12
        LD (CUR_STMT),HL            ; 20C0  22 27 65
        LD HL,(WS_6163)             ; 20C3  2A 63 61
        CALL SUB_27B0               ; 20C6  CD B0 27
        JP C,LOC_237A               ; 20C9  DA 7A 23
        LD HL,(FREE_PTR)            ; 20CC  2A 6A 63
        LD BC,00C8H                 ; 20CF  01 C8 00
        ADD HL,BC                   ; 20D2  09
        CALL SUB_27B0               ; 20D3  CD B0 27
        JP NC,LOC_23B6              ; 20D6  D2 B6 23
        EX DE,HL                    ; 20D9  EB
LOC_20DA:
        LD (WS_6165),HL             ; 20DA  22 65 61
        LD SP,HL                    ; 20DD  F9
        JP LOC_122A                 ; 20DE  C3 2A 12
        SUB 30H                     ; 20E1  D6 30
        CP 02H                      ; 20E3  FE 02
        JP NC,LOC_2372              ; 20E5  D2 72 23
        LD BC,0000H                 ; 20E8  01 00 00
        LD D,B                      ; 20EB  50
        LD E,C                      ; 20EC  59
LOC_20ED:
        CP 01H                      ; 20ED  FE 01
        CCF                         ; 20EF  3F
        CALL SUB_274E               ; 20F0  CD 4E 27
        JP C,LOC_2376               ; 20F3  DA 76 23
        CALL SUB_277A               ; 20F6  CD 7A 27
        SUB 30H                     ; 20F9  D6 30
        CP 02H                      ; 20FB  FE 02
        JR C,LOC_20ED               ; 20FD  38 EE
LOC_20FF:
        PUSH HL                     ; 20FF  E5
        LD A,E0H                    ; 2100  3E E0
        CALL SUB_344F               ; 2102  CD 4F 34
        LD HL,(FREE_PTR)            ; 2105  2A 6A 63
        CALL SUB_2BD2               ; 2108  CD D2 2B
        JP LOC_1B23                 ; 210B  C3 23 1B
SUB_210E:
        SUB 30H                     ; 210E  D6 30
        CP 08H                      ; 2110  FE 08
        RET                         ; 2112  C9
        LD HL,(CUR_LINE)            ; 2113  2A 25 65
        LD A,L                      ; 2116  7D
        OR H                        ; 2117  B4
        JP NZ,LOC_23B2              ; 2118  C2 B2 23
        LD A,(WS_6167)              ; 211B  3A 67 61
        OR A                        ; 211E  B7
        JP Z,LOC_23B2               ; 211F  CA B2 23
        PUSH AF                     ; 2122  F5
        CALL SUB_24BC               ; 2123  CD BC 24
        LD BC,0006H                 ; 2126  01 06 00
        LD DE,6523H                 ; 2129  11 23 65
        LD HL,6168H                 ; 212C  21 68 61
        CALL SUB_28F1               ; 212F  CD F1 28
        POP AF                      ; 2132  F1
        LD HL,(CUR_STMT)            ; 2133  2A 27 65
        OR A                        ; 2136  B7
        JP M,LOC_3E9E               ; 2137  FA 9E 3E
        DEC A                       ; 213A  3D
        JP Z,LOC_122A               ; 213B  CA 2A 12
        JP LOC_1259                 ; 213E  C3 59 12
; --- SUB_2141: called from 3 places ---
SUB_2141:
        CALL SUB_1A58               ; 2141  CD 58 1A
        JP SUB_2967                 ; 2144  C3 67 29
SUB_2147:
        CALL SUB_2959               ; 2147  CD 59 29
        EX DE,HL                    ; 214A  EB
        JP SUB_2959                 ; 214B  C3 59 29
SUB_214E:
        CALL SUB_2141               ; 214E  CD 41 21
        CALL SUB_27E1               ; 2151  CD E1 27
        ADD HL,HL                   ; 2154  29
        CALL SUB_27E1               ; 2155  CD E1 27
        OR (HL)                     ; 2158  B6
        PUSH BC                     ; 2159  C5
        PUSH DE                     ; 215A  D5
        CALL SUB_2141               ; 215B  CD 41 21
        LD (CUR_STMT),HL            ; 215E  22 27 65
        POP HL                      ; 2161  E1
        PUSH BC                     ; 2162  C5
        EXX                         ; 2163  D9
        POP BC                      ; 2164  C1
        POP DE                      ; 2165  D1
        LD A,C                      ; 2166  79
        CP E                        ; 2167  BB
        RET C                       ; 2168  D8
        EXX                         ; 2169  D9
        POP AF                      ; 216A  F1
LOC_216B:
        CALL SUB_2B09               ; 216B  CD 09 2B
        POP HL                      ; 216E  E1
        CALL SUB_1DBE               ; 216F  CD BE 1D
        CALL SUB_1BDF               ; 2172  CD DF 1B
        JP LOC_5EB7                 ; 2175  C3 B7 5E
        PUSH HL                     ; 2178  E5
        CALL SUB_214E               ; 2179  CD 4E 21
        PUSH DE                     ; 217C  D5
        EXX                         ; 217D  D9
        PUSH HL                     ; 217E  E5
        CALL SUB_2147               ; 217F  CD 47 21
LOC_2182:
        CALL SUB_28F1               ; 2182  CD F1 28
        POP DE                      ; 2185  D1
        POP BC                      ; 2186  C1
        JP LOC_216B                 ; 2187  C3 6B 21
        LD A,B                      ; 218A  78
        LD HL,5EA2H                 ; 218B  21 A2 5E
        LD (HL),D                   ; 218E  72
        INC HL                      ; 218F  23
LOC_2190:
        SUB C0H                     ; 2190  D6 C0
        JP C,LOC_2372               ; 2192  DA 72 23
        CP 02H                      ; 2195  FE 02
        JP NC,LOC_1297              ; 2197  D2 97 12
        LD DE,218AH                 ; 219A  11 8A 21
        JP LOC_128A                 ; 219D  C3 8A 12
        CALL BELL                   ; 21A0  CD 3E 00
        JP LOC_122D                 ; 21A3  C3 2D 12
        CALL SUB_1221               ; 21A6  CD 21 12
        CALL SUB_27E1               ; 21A9  CD E1 27
        INC L                       ; 21AC  2C
        LD A,E                      ; 21AD  7B
        LD (21C0H),A                ; 21AE  32 C0 21
        CALL SUB_1DBE               ; 21B1  CD BE 1D
        CALL SUB_1BDF               ; 21B4  CD DF 1B
        LD (CUR_STMT),HL            ; 21B7  22 27 65
        LD A,B                      ; 21BA  78
        OR A                        ; 21BB  B7
        JP NZ,LOC_237E              ; 21BC  C2 7E 23
        IN A,(FFH)                  ; 21BF  DB FF
        OR A                        ; 21C1  B7
        LD B,A                      ; 21C2  47
        JP Z,LOC_21D3               ; 21C3  CA D3 21
        LD A,C8H                    ; 21C6  3E C8
LOC_21C8:
        BIT 7,B                     ; 21C8  CB 78
        JP NZ,LOC_21D5              ; 21CA  C2 D5 21
        SLA B                       ; 21CD  CB 20
        DEC A                       ; 21CF  3D
        JP LOC_21C8                 ; 21D0  C3 C8 21
LOC_21D3:
        LD A,80H                    ; 21D3  3E 80
LOC_21D5:
        EX DE,HL                    ; 21D5  EB
        LD (HL),A                   ; 21D6  77
        INC HL                      ; 21D7  23
        XOR A                       ; 21D8  AF
        LD (HL),A                   ; 21D9  77
        INC HL                      ; 21DA  23
        LD (HL),A                   ; 21DB  77
        INC HL                      ; 21DC  23
        LD (HL),A                   ; 21DD  77
        INC HL                      ; 21DE  23
        LD (HL),B                   ; 21DF  70
        JP LOC_122A                 ; 21E0  C3 2A 12
        CALL SUB_1221               ; 21E3  CD 21 12
        LD A,E                      ; 21E6  7B
        LD (21F3H),A                ; 21E7  32 F3 21
        CALL SUB_27E1               ; 21EA  CD E1 27
        INC L                       ; 21ED  2C
        CALL SUB_1221               ; 21EE  CD 21 12
        LD A,E                      ; 21F1  7B
        OUT (FFH),A                 ; 21F2  D3 FF
        JP LOC_122D                 ; 21F4  C3 2D 12

ENTRY:                          ; documented execution/start address
        JR LOC_21FA                 ; 21F7  18 01
        NOP                         ; 21F9  00
LOC_21FA:
        LD HL,5FFFH                 ; 21FA  21 FF 5F
        LD D,D0H                    ; 21FD  16 D0
LOC_21FF:
        INC HL                      ; 21FF  23
        LD A,H                      ; 2200  7C
        CP D                        ; 2201  BA
        JR Z,LOC_220E               ; 2202  28 0A
        LD A,FFH                    ; 2204  3E FF
        LD (HL),A                   ; 2206  77
        SUB (HL)                    ; 2207  96
        JR NZ,LOC_220E              ; 2208  20 04
        LD (HL),A                   ; 220A  77
        CP (HL)                     ; 220B  BE
        JR Z,LOC_21FF               ; 220C  28 F1
LOC_220E:
        LD (WS_6163),HL             ; 220E  22 63 61
        LD (WS_6165),HL             ; 2211  22 65 61
        LD SP,HL                    ; 2214  F9
        CALL BELL                   ; 2215  CD 3E 00
        CALL LETLN                  ; 2218  CD 06 00
        LD DE,553CH                 ; 221B  11 3C 55
        CALL MON_MESSAGE            ; 221E  CD 15 00
        DB CDH,8AH                  ; 2221  CD 8A   (stray byte(s): disassembly boundary correction)
LOC_2223:
        ADD HL,HL                   ; 2223  29
        LD BC,000AH                 ; 2224  01 0A 00
        CALL SUB_2897               ; 2227  CD 97 28
        CALL SUB_288B               ; 222A  CD 8B 28
        CALL SUB_2335               ; 222D  CD 35 23
        LD DE,232EH                 ; 2230  11 2E 23
        CALL MON_MESSAGE            ; 2233  CD 15 00
        XOR A                       ; 2236  AF
        LD D,A                      ; 2237  57
        LD E,A                      ; 2238  5F
        CALL TIMST                  ; 2239  CD 33 00
        DB CDH,66H                  ; 223C  CD 66   (stray byte(s): disassembly boundary correction)
SUB_223E:
        INC HL                      ; 223E  23
        LD HL,6055H                 ; 223F  21 55 60
        LD (MON_100F),HL            ; 2242  22 0F 10
LOC_2245:
        LD DE,231FH                 ; 2245  11 1F 23
        CALL MELDY                  ; 2248  CD 30 00
        CALL SUB_5204               ; 224B  CD 04 52
        LD DE,231AH                 ; 224E  11 1A 23
        CALL SUB_2335               ; 2251  CD 35 23
LOC_2254:
        LD A,(WS_6167)              ; 2254  3A 67 61
        OR A                        ; 2257  B7
        JP Z,LOC_2271               ; 2258  CA 71 22
        LD HL,(CUR_LINE)            ; 225B  2A 25 65
        LD A,H                      ; 225E  7C
        OR L                        ; 225F  B5
        JP Z,LOC_2275               ; 2260  CA 75 22
        LD BC,0006H                 ; 2263  01 06 00
        LD DE,6168H                 ; 2266  11 68 61
        LD HL,6523H                 ; 2269  21 23 65
        CALL SUB_28F1               ; 226C  CD F1 28
        JR LOC_2275                 ; 226F  18 04
LOC_2271:
        LD HL,(WS_6165)             ; 2271  2A 65 61
        LD SP,HL                    ; 2274  F9
LOC_2275:
        CALL SUB_29A6               ; 2275  CD A6 29
        LD A,01H                    ; 2278  3E 01
        LD (WS_E003),A              ; 227A  32 03 E0
        CALL NEWLIN                 ; 227D  CD 09 00
        LD DE,6000H                 ; 2280  11 00 60
        CALL GETL                   ; 2283  CD 03 00
LOC_2286:
        XOR A                       ; 2286  AF
        LD (MON_1170),A             ; 2287  32 70 11
        LD A,05H                    ; 228A  3E 05
        LD (WS_E003),A              ; 228C  32 03 E0
        CALL SUB_24C9               ; 228F  CD C9 24
        CALL SUB_253E               ; 2292  CD 3E 25
        LD HL,(WS_6057)             ; 2295  2A 57 60
        LD A,L                      ; 2298  7D
        OR H                        ; 2299  B4
        JP NZ,LOC_5BF1              ; 229A  C2 F1 5B
        LD HL,6059H                 ; 229D  21 59 60
        LD (CUR_STMT),HL            ; 22A0  22 27 65
        CALL SUB_27D2               ; 22A3  CD D2 27
        DEC C                       ; 22A6  0D
        LD E,C                      ; 22A7  59
        LD (DE),A                   ; 22A8  12
        JP LOC_2275                 ; 22A9  C3 75 22
LOC_22AC:
        CALL NEWLIN                 ; 22AC  CD 09 00
        LD DE,6000H                 ; 22AF  11 00 60
        CALL GETL                   ; 22B2  CD 03 00
        LD A,(DE)                   ; 22B5  1A
        CP 0DH                      ; 22B6  FE 0D
        RET Z                       ; 22B8  C8
        LD HL,(WS_6165)             ; 22B9  2A 65 61
        LD SP,HL                    ; 22BC  F9
        JP LOC_2286                 ; 22BD  C3 86 22   <-- UNRESOLVED ALIGNMENT: also targeted as 22BEH
; --- SUB_22C0: called from 3 places ---
SUB_22C0:
        CALL SUB_2B1A               ; 22C0  CD 1A 2B
        CALL SUB_24BC               ; 22C3  CD BC 24
        CALL SUB_28FD               ; 22C6  CD FD 28
        SBC A,22H                   ; 22C9  DE 22
        JR NZ,LOC_22DE              ; 22CB  20 11
        CALL SUB_2940               ; 22CD  CD 40 29
        EX DE,HL                    ; 22D0  EB
        CALL SUB_28BE               ; 22D1  CD BE 28
        CALL SUB_279F               ; 22D4  CD 9F 27
        CALL SUB_2A31               ; 22D7  CD 31 2A
        EX DE,HL                    ; 22DA  EB
        CALL SUB_2938               ; 22DB  CD 38 29
LOC_22DE:
        LD A,(WS_6059)              ; 22DE  3A 59 60
        CP 0DH                      ; 22E1  FE 0D
        RET Z                       ; 22E3  C8
        NOP                         ; 22E4  00
        NOP                         ; 22E5  00
        CALL SUB_2900               ; 22E6  CD 00 29
        EX DE,HL                    ; 22E9  EB
        LD (5522H),HL               ; 22EA  22 22 55
        LD H,B                      ; 22ED  60
        EX DE,HL                    ; 22EE  EB
        LD HL,6055H                 ; 22EF  21 55 60
        CALL SUB_2940               ; 22F2  CD 40 29
        CALL SUB_28EE               ; 22F5  CD EE 28
        CALL SUB_2A31               ; 22F8  CD 31 2A
        EX DE,HL                    ; 22FB  EB
        CALL SUB_2938               ; 22FC  CD 38 29
        RET                         ; 22FF  C9
        NOP                         ; 2300  00
        NOP                         ; 2301  00
LOC_2302:
        SUB 8FH                     ; 2302  D6 8F
        CP 08H                      ; 2304  FE 08
        JP NC,LOC_2372              ; 2306  D2 72 23
        LD DE,5846H                 ; 2309  11 46 58
        JP LOC_128A                 ; 230C  C3 8A 12
SUB_230F:
        CALL SUB_2940               ; 230F  CD 40 29
        LD DE,6055H                 ; 2312  11 55 60
        CALL SUB_28F1               ; 2315  CD F1 28
        RET                         ; 2318  C9
        LD BC,4552H                 ; 2319  01 52 45
        LD B,C                      ; 231C  41
        LD B,H                      ; 231D  44
        LD E,C                      ; 231E  59
        DEC C                       ; 231F  0D
        LD HL,(5245H)               ; 2320  2A 45 52
        DEC C                       ; 2323  0D
        JR NZ,LOC_236F              ; 2324  20 49
        LD C,(HL)                   ; 2326  4E
        DEC C                       ; 2327  0D
        LD B,D                      ; 2328  42
        LD D,D                      ; 2329  52
        LD B,L                      ; 232A  45
        LD B,C                      ; 232B  41
        LD C,E                      ; 232C  4B
        DEC C                       ; 232D  0D
        JR NZ,LOC_2372              ; 232E  20 42
        LD E,C                      ; 2330  59
        LD D,H                      ; 2331  54
        LD B,L                      ; 2332  45
        LD D,E                      ; 2333  53
        DEC C                       ; 2334  0D
; --- SUB_2335: called from 5 places ---
SUB_2335:
        CALL NEWLIN                 ; 2335  CD 09 00
        JP MON_MESSAGE              ; 2338  C3 15 00
LOC_233B:
        DEC D                       ; 233B  15
        XOR E                       ; 233C  AB
        LD D,(HL)                   ; 233D  56
        ADC A,1AH                   ; 233E  CE 1A
        ADD A,D                     ; 2340  82
        LD B,C                      ; 2341  41
        SUB 23H                     ; 2342  D6 23
        AND 00H                     ; 2344  E6 00
        SUB B                       ; 2346  90
        LD A,(DE)                   ; 2347  1A
        LD H,83H                    ; 2348  26 83
        LD H,B                      ; 234A  60
        JP NZ,WS_B627               ; 234B  C2 27 B6
        LD (HL),D                   ; 234E  72
; --- SUB_234F: called from 5 places ---
SUB_234F:
        XOR A                       ; 234F  AF
        LD (DATA_2345),A            ; 2350  32 45 23
        RET                         ; 2353  C9
LOC_2354:
        LD DE,2328H                 ; 2354  11 28 23
        CALL SUB_2335               ; 2357  CD 35 23
        LD HL,(CUR_LINE)            ; 235A  2A 25 65
        JP LOC_24A6                 ; 235D  C3 A6 24
        LD A,(MON_1008)             ; 2360  3A 08 10
        JP LOC_2460                 ; 2363  C3 60 24
        LD A,C3H                    ; 2366  3E C3
        LD (MON_100B),A             ; 2368  32 0B 10
        LD HL,2360H                 ; 236B  21 60 23
        DB 22H                      ; 236E  22   (stray byte(s): disassembly boundary correction)
LOC_236F:
        INC C                       ; 236F  0C
        DJNZ LOC_233B               ; 2370  10 C9
LOC_2372:
        LD A,01H                    ; 2372  3E 01
        JR LOC_2378                 ; 2374  18 02
LOC_2376:
        LD A,02H                    ; 2376  3E 02
LOC_2378:
        JR LOC_237C                 ; 2378  18 02
LOC_237A:
        LD A,03H                    ; 237A  3E 03
LOC_237C:
        JR LOC_2380                 ; 237C  18 02
LOC_237E:
        LD A,04H                    ; 237E  3E 04
LOC_2380:
        JR LOC_2384                 ; 2380  18 02
LOC_2382:
        LD A,05H                    ; 2382  3E 05
LOC_2384:
        JR LOC_2388                 ; 2384  18 02
LOC_2386:
        LD A,06H                    ; 2386  3E 06
LOC_2388:
        JR LOC_238C                 ; 2388  18 02
LOC_238A:
        LD A,07H                    ; 238A  3E 07
LOC_238C:
        JR LOC_2390                 ; 238C  18 02
LOC_238E:
        LD A,08H                    ; 238E  3E 08
LOC_2390:
        JR LOC_2394                 ; 2390  18 02
        LD A,09H                    ; 2392  3E 09
LOC_2394:
        JR LOC_2398                 ; 2394  18 02
LOC_2396:
        LD A,0AH                    ; 2396  3E 0A
LOC_2398:
        JR LOC_239C                 ; 2398  18 02
LOC_239A:
        LD A,0BH                    ; 239A  3E 0B
LOC_239C:
        JR LOC_23A0                 ; 239C  18 02
LOC_239E:
        LD A,0CH                    ; 239E  3E 0C
LOC_23A0:
        JR LOC_23A4                 ; 23A0  18 02
LOC_23A2:
        LD A,0DH                    ; 23A2  3E 0D
LOC_23A4:
        JR LOC_23A8                 ; 23A4  18 02
LOC_23A6:
        LD A,0EH                    ; 23A6  3E 0E
LOC_23A8:
        JR LOC_23AC                 ; 23A8  18 02
LOC_23AA:
        LD A,0FH                    ; 23AA  3E 0F
LOC_23AC:
        JR LOC_23B0                 ; 23AC  18 02
LOC_23AE:
        LD A,10H                    ; 23AE  3E 10
LOC_23B0:
        JR LOC_23B4                 ; 23B0  18 02
LOC_23B2:
        LD A,11H                    ; 23B2  3E 11
LOC_23B4:
        JR LOC_23B8                 ; 23B4  18 02
LOC_23B6:
        LD A,12H                    ; 23B6  3E 12
LOC_23B8:
        JR LOC_23BC                 ; 23B8  18 02
LOC_23BA:
        LD A,13H                    ; 23BA  3E 13
LOC_23BC:
        JR LOC_23C0                 ; 23BC  18 02
LOC_23BE:
        LD A,14H                    ; 23BE  3E 14
LOC_23C0:
        JR LOC_23C4                 ; 23C0  18 02
LOC_23C2:
        LD A,15H                    ; 23C2  3E 15
LOC_23C4:
        JR LOC_23C8                 ; 23C4  18 02
LOC_23C6:
        LD A,16H                    ; 23C6  3E 16
LOC_23C8:
        JR LOC_23CC                 ; 23C8  18 02
        LD A,17H                    ; 23CA  3E 17
LOC_23CC:
        JR LOC_23D0                 ; 23CC  18 02
LOC_23CE:
        LD A,18H                    ; 23CE  3E 18
LOC_23D0:
        JR LOC_23D4                 ; 23D0  18 02
LOC_23D2:
        LD A,19H                    ; 23D2  3E 19
LOC_23D4:
        JR LOC_23D8                 ; 23D4  18 02
LOC_23D6:
        LD A,1AH                    ; 23D6  3E 1A
LOC_23D8:
        JR LOC_23DC                 ; 23D8  18 02
LOC_23DA:
        LD A,1BH                    ; 23DA  3E 1B
LOC_23DC:
        JR LOC_23E0                 ; 23DC  18 02
LOC_23DE:
        LD A,1CH                    ; 23DE  3E 1C
LOC_23E0:
        JR LOC_23E4                 ; 23E0  18 02
LOC_23E2:
        LD A,28H                    ; 23E2  3E 28
LOC_23E4:
        JR LOC_23E8                 ; 23E4  18 02
        LD A,29H                    ; 23E6  3E 29
LOC_23E8:
        JR LOC_23EC                 ; 23E8  18 02
LOC_23EA:
        LD A,2AH                    ; 23EA  3E 2A
LOC_23EC:
        JR LOC_23F0                 ; 23EC  18 02
LOC_23EE:
        LD A,2BH                    ; 23EE  3E 2B
LOC_23F0:
        JR LOC_23F4                 ; 23F0  18 02
LOC_23F2:
        LD A,2CH                    ; 23F2  3E 2C
LOC_23F4:
        JR LOC_23F8                 ; 23F4  18 02
        LD A,2DH                    ; 23F6  3E 2D
LOC_23F8:
        JR LOC_23FC                 ; 23F8  18 02
LOC_23FA:
        LD A,2EH                    ; 23FA  3E 2E
LOC_23FC:
        JR LOC_2400                 ; 23FC  18 02
        LD A,2FH                    ; 23FE  3E 2F
LOC_2400:
        JR LOC_2404                 ; 2400  18 02
        LD A,30H                    ; 2402  3E 30
LOC_2404:
        JR LOC_2408                 ; 2404  18 02
        LD A,31H                    ; 2406  3E 31
LOC_2408:
        JR LOC_240C                 ; 2408  18 02
        LD A,FFH                    ; 240A  3E FF
LOC_240C:
        JR LOC_2410                 ; 240C  18 02
LOC_240E:
        LD A,33H                    ; 240E  3E 33
LOC_2410:
        JR LOC_2414                 ; 2410  18 02
LOC_2412:
        LD A,34H                    ; 2412  3E 34
LOC_2414:
        JR LOC_2418                 ; 2414  18 02
LOC_2416:
        LD A,35H                    ; 2416  3E 35
LOC_2418:
        JR LOC_241C                 ; 2418  18 02
        LD A,36H                    ; 241A  3E 36
LOC_241C:
        JR LOC_2420                 ; 241C  18 02
        LD A,37H                    ; 241E  3E 37
LOC_2420:
        JR LOC_2424                 ; 2420  18 02
        LD A,38H                    ; 2422  3E 38
LOC_2424:
        JR LOC_2428                 ; 2424  18 02
LOC_2426:
        LD A,39H                    ; 2426  3E 39
LOC_2428:
        JR LOC_242C                 ; 2428  18 02
        LD A,3AH                    ; 242A  3E 3A
LOC_242C:
        JR LOC_2430                 ; 242C  18 02
LOC_242E:
        LD A,3BH                    ; 242E  3E 3B
LOC_2430:
        JR LOC_2434                 ; 2430  18 02
LOC_2432:
        LD A,3CH                    ; 2432  3E 3C
LOC_2434:
        JR LOC_2438                 ; 2434  18 02
        LD A,3DH                    ; 2436  3E 3D
LOC_2438:
        JR LOC_243C                 ; 2438  18 02
        LD A,3EH                    ; 243A  3E 3E
LOC_243C:
        JR LOC_2440                 ; 243C  18 02
LOC_243E:
        LD A,3FH                    ; 243E  3E 3F
LOC_2440:
        JR LOC_2444                 ; 2440  18 02
LOC_2442:
        LD A,40H                    ; 2442  3E 40
LOC_2444:
        JR LOC_2448                 ; 2444  18 02
LOC_2446:
        LD A,41H                    ; 2446  3E 41
LOC_2448:
        JR LOC_244C                 ; 2448  18 02
LOC_244A:
        LD A,42H                    ; 244A  3E 42
LOC_244C:
        JR LOC_2450                 ; 244C  18 02
LOC_244E:
        LD A,43H                    ; 244E  3E 43
LOC_2450:
        JR LOC_2454                 ; 2450  18 02
        LD A,44H                    ; 2452  3E 44
LOC_2454:
        JR LOC_2458                 ; 2454  18 02
        LD A,45H                    ; 2456  3E 45
LOC_2458:
        JR LOC_245C                 ; 2458  18 02
LOC_245A:
        LD A,46H                    ; 245A  3E 46
LOC_245C:
        JR LOC_2460                 ; 245C  18 02
        LD A,64H                    ; 245E  3E 64
LOC_2460:
        PUSH AF                     ; 2460  F5
        CALL SUB_5204               ; 2461  CD 04 52
        LD HL,(CUR_LINE)            ; 2464  2A 25 65
        LD A,H                      ; 2467  7C
        OR L                        ; 2468  B5
        JP Z,LOC_2493               ; 2469  CA 93 24
        LD A,(DATA_2345)            ; 246C  3A 45 23
        CP 01H                      ; 246F  FE 01
        JP NZ,LOC_248A              ; 2471  C2 8A 24
        POP AF                      ; 2474  F1
        LD (2346H),A                ; 2475  32 46 23
LOC_2478:
        LD A,02H                    ; 2478  3E 02
        LD (DATA_2345),A            ; 247A  32 45 23
        LD HL,(WS_6165)             ; 247D  2A 65 61
        LD SP,HL                    ; 2480  F9
        CALL SUB_4978               ; 2481  CD 78 49
        LD HL,(234DH)               ; 2484  2A 4D 23
        JP LOC_1535                 ; 2487  C3 35 15
LOC_248A:
        CALL SUB_234F               ; 248A  CD 4F 23
        CALL SUB_29DA               ; 248D  CD DA 29
        CALL SUB_29F4               ; 2490  CD F4 29
LOC_2493:
        CALL SUB_4978               ; 2493  CD 78 49
        LD DE,2320H                 ; 2496  11 20 23
        CALL SUB_2335               ; 2499  CD 35 23
        POP AF                      ; 249C  F1
        LD L,A                      ; 249D  6F
        LD H,00H                    ; 249E  26 00
        CALL SUB_24B6               ; 24A0  CD B6 24
        LD HL,(CUR_LINE)            ; 24A3  2A 25 65
LOC_24A6:
        CALL BELL                   ; 24A6  CD 3E 00
        LD BC,2245H                 ; 24A9  01 45 22
        PUSH BC                     ; 24AC  C5
        LD A,H                      ; 24AD  7C
        OR L                        ; 24AE  B5
        RET Z                       ; 24AF  C8
        LD DE,2324H                 ; 24B0  11 24 23
        CALL MON_MESSAGE            ; 24B3  CD 15 00
SUB_24B6:
        CALL SUB_288B               ; 24B6  CD 8B 28
        JP MON_MESSAGE              ; 24B9  C3 15 00
; --- SUB_24BC: called from 3 places ---
SUB_24BC:
        XOR A                       ; 24BC  AF
        JR LOC_24C1                 ; 24BD  18 02
SUB_24BF:
        LD A,01H                    ; 24BF  3E 01
LOC_24C1:
        JR LOC_24C5                 ; 24C1  18 02
SUB_24C3:
        LD A,02H                    ; 24C3  3E 02
LOC_24C5:
        LD (WS_6167),A              ; 24C5  32 67 61
        RET                         ; 24C8  C9
SUB_24C9:
        LD HL,6000H                 ; 24C9  21 00 60
        CALL SUB_2840               ; 24CC  CD 40 28
        EX DE,HL                    ; 24CF  EB
        LD (WS_6057),HL             ; 24D0  22 57 60
        LD HL,6059H                 ; 24D3  21 59 60
        LD C,00H                    ; 24D6  0E 00
        EX DE,HL                    ; 24D8  EB
        CALL SUB_277B               ; 24D9  CD 7B 27
LOC_24DC:
        CALL SUB_258C               ; 24DC  CD 8C 25
        RET Z                       ; 24DF  C8
        DEC DE                      ; 24E0  1B
        CP 3FH                      ; 24E1  FE 3F
        JR NZ,LOC_24EB              ; 24E3  20 06
        LD A,85H                    ; 24E5  3E 85
        LD (DE),A                   ; 24E7  12
        INC DE                      ; 24E8  13
        JR LOC_24DC                 ; 24E9  18 F1
LOC_24EB:
        DEC HL                      ; 24EB  2B
        EX DE,HL                    ; 24EC  EB
        PUSH HL                     ; 24ED  E5
        LD HL,5606H                 ; 24EE  21 06 56
        LD B,6CH                    ; 24F1  06 6C
LOC_24F3:
        PUSH DE                     ; 24F3  D5
LOC_24F4:
        CALL SUB_277B               ; 24F4  CD 7B 27
        EX DE,HL                    ; 24F7  EB
        CALL SUB_277B               ; 24F8  CD 7B 27
        EX DE,HL                    ; 24FB  EB
        CP (HL)                     ; 24FC  BE
        INC HL                      ; 24FD  23
        INC DE                      ; 24FE  13
        JR Z,LOC_24F4               ; 24FF  28 F3
        DEC HL                      ; 2501  2B
        CP FFH                      ; 2502  FE FF
        JP Z,LOC_2510               ; 2504  CA 10 25
        ADD A,80H                   ; 2507  C6 80
        JP C,LOC_2372               ; 2509  DA 72 23
        CP (HL)                     ; 250C  BE
        JP Z,LOC_2522               ; 250D  CA 22 25
LOC_2510:
        INC B                       ; 2510  04
        LD A,FFH                    ; 2511  3E FF
        CP B                        ; 2513  B8
        JP Z,LOC_2536               ; 2514  CA 36 25
        LD A,7FH                    ; 2517  3E 7F
LOC_2519:
        CP (HL)                     ; 2519  BE
        INC HL                      ; 251A  23
        JP NC,LOC_2519              ; 251B  D2 19 25
        POP DE                      ; 251E  D1
        JP LOC_24F3                 ; 251F  C3 F3 24
LOC_2522:
        POP AF                      ; 2522  F1
        POP HL                      ; 2523  E1
        LD (HL),B                   ; 2524  70
        INC HL                      ; 2525  23
        EX DE,HL                    ; 2526  EB
        LD A,B                      ; 2527  78
        SUB 7FH                     ; 2528  D6 7F
        CP 03H                      ; 252A  FE 03
        JR NC,LOC_24DC              ; 252C  30 AE
        CALL SUB_25C0               ; 252E  CD C0 25
        CP 3AH                      ; 2531  FE 3A
        JR Z,LOC_24DC               ; 2533  28 A7
        RET                         ; 2535  C9
LOC_2536:
        POP DE                      ; 2536  D1
        POP HL                      ; 2537  E1
        INC DE                      ; 2538  13
        INC HL                      ; 2539  23
        EX DE,HL                    ; 253A  EB
        JP LOC_24DC                 ; 253B  C3 DC 24
; --- SUB_253E: called from 4 places ---
SUB_253E:
        LD HL,(WS_6057)             ; 253E  2A 57 60
        LD DE,6000H                 ; 2541  11 00 60
        LD C,B2H                    ; 2544  0E B2
        CALL SUB_2848               ; 2546  CD 48 28
        LD A,20H                    ; 2549  3E 20
        LD (DE),A                   ; 254B  12
        INC DE                      ; 254C  13
        LD HL,6059H                 ; 254D  21 59 60
LOC_2550:
        CALL SUB_258C               ; 2550  CD 8C 25
        RET Z                       ; 2553  C8
        SUB 6CH                     ; 2554  D6 6C
        JP C,LOC_2550               ; 2556  DA 50 25
        DEC C                       ; 2559  0D
        PUSH AF                     ; 255A  F5
        DEC DE                      ; 255B  1B
        PUSH HL                     ; 255C  E5
        LD HL,5606H                 ; 255D  21 06 56
LOC_2560:
        OR A                        ; 2560  B7
        JP Z,LOC_2570               ; 2561  CA 70 25
        PUSH AF                     ; 2564  F5
        LD A,7FH                    ; 2565  3E 7F
LOC_2567:
        CP (HL)                     ; 2567  BE
        INC HL                      ; 2568  23
        JR NC,LOC_2567              ; 2569  30 FC
        POP AF                      ; 256B  F1
        DEC A                       ; 256C  3D
        JP LOC_2560                 ; 256D  C3 60 25
LOC_2570:
        CALL SUB_25B5               ; 2570  CD B5 25
        OR A                        ; 2573  B7
        JP P,LOC_2570               ; 2574  F2 70 25
        DEC DE                      ; 2577  1B
        AND 7FH                     ; 2578  E6 7F
        LD (DE),A                   ; 257A  12
        INC DE                      ; 257B  13
        POP HL                      ; 257C  E1
        POP AF                      ; 257D  F1
        SUB 13H                     ; 257E  D6 13
        CP 03H                      ; 2580  FE 03
        JR NC,LOC_2550              ; 2582  30 CC
        CALL SUB_25C0               ; 2584  CD C0 25
        CP 3AH                      ; 2587  FE 3A
        JR Z,LOC_2550               ; 2589  28 C5
        RET                         ; 258B  C9
SUB_258C:
        CALL SUB_25B5               ; 258C  CD B5 25
        RET Z                       ; 258F  C8
        CALL SUB_25A0               ; 2590  CD A0 25
        JR Z,SUB_258C               ; 2593  28 F7
        CP 22H                      ; 2595  FE 22
        RET NZ                      ; 2597  C0
        CALL SUB_25AC               ; 2598  CD AC 25
        CP 0DH                      ; 259B  FE 0D
        JR NZ,SUB_258C              ; 259D  20 ED
        RET                         ; 259F  C9
SUB_25A0:
        CP 20H                      ; 25A0  FE 20
        RET Z                       ; 25A2  C8
        CP FFH                      ; 25A3  FE FF
        RET Z                       ; 25A5  C8
        CP 28H                      ; 25A6  FE 28
        RET Z                       ; 25A8  C8
        CP 29H                      ; 25A9  FE 29
        RET                         ; 25AB  C9
SUB_25AC:
        CALL SUB_25B5               ; 25AC  CD B5 25
        RET Z                       ; 25AF  C8
        CP 22H                      ; 25B0  FE 22
        JR NZ,SUB_25AC              ; 25B2  20 F8
        RET                         ; 25B4  C9
; --- SUB_25B5: called from 4 places ---
SUB_25B5:
        LD A,(HL)                   ; 25B5  7E
        LD (DE),A                   ; 25B6  12
        INC HL                      ; 25B7  23
        INC DE                      ; 25B8  13
        INC C                       ; 25B9  0C
        JP Z,LOC_238E               ; 25BA  CA 8E 23
        CP 0DH                      ; 25BD  FE 0D
        RET                         ; 25BF  C9
SUB_25C0:
        CALL SUB_25B5               ; 25C0  CD B5 25
        RET Z                       ; 25C3  C8
        CP 3AH                      ; 25C4  FE 3A
        RET Z                       ; 25C6  C8
        CP 22H                      ; 25C7  FE 22
        JR NZ,SUB_25C0              ; 25C9  20 F5
        CALL SUB_25AC               ; 25CB  CD AC 25
        CP 0DH                      ; 25CE  FE 0D
        JR NZ,SUB_25C0              ; 25D0  20 EE
        RET                         ; 25D2  C9
        CALL SUB_1204               ; 25D3  CD 04 12
        PUSH DE                     ; 25D6  D5
        CALL SUB_27E1               ; 25D7  CD E1 27
        INC L                       ; 25DA  2C
        CALL SUB_1204               ; 25DB  CD 04 12
        EX (SP),HL                  ; 25DE  E3
        LD (HL),E                   ; 25DF  73
        INC HL                      ; 25E0  23
        LD (HL),D                   ; 25E1  72
        POP HL                      ; 25E2  E1
        JP LOC_122D                 ; 25E3  C3 2D 12
        CALL SUB_27D2               ; 25E6  CD D2 27
        LD D,B                      ; 25E9  50
        RET M                       ; 25EA  F8
        DEC H                       ; 25EB  25
        LD DE,3E41H                 ; 25EC  11 41 3E
LOC_25EF:
        CALL SUB_27E1               ; 25EF  CD E1 27
        ADD HL,HL                   ; 25F2  29
        PUSH HL                     ; 25F3  E5
        LD A,(DE)                   ; 25F4  1A
        JP LOC_1F43                 ; 25F5  C3 43 1F
        CALL SUB_27D2               ; 25F8  CD D2 27
        LD C,B                      ; 25FB  48
        INC BC                      ; 25FC  03
        LD H,11H                    ; 25FD  26 11
        LD (HL),C                   ; 25FF  71
        DB 11H                      ; 2600  11   (stray byte(s): disassembly boundary correction)
LOC_2601:
        JR LOC_25EF                 ; 2601  18 EC
        CALL SUB_27E1               ; 2603  CD E1 27
        LD D,(HL)                   ; 2606  56
        LD DE,1172H                 ; 2607  11 72 11
        JR LOC_2601                 ; 260A  18 F5
        LD DE,1E27H                 ; 260C  11 27 1E
        LD A,D4H                    ; 260F  3E D4
        JR LOC_2618                 ; 2611  18 05
        LD DE,1318H                 ; 2613  11 18 13
        LD A,DCH                    ; 2616  3E DC
LOC_2618:
        PUSH AF                     ; 2618  F5
        PUSH HL                     ; 2619  E5
        LD HL,(FREE_PTR)            ; 261A  2A 6A 63
        CALL SUB_32D8               ; 261D  CD D8 32
        LD (FREE_PTR),DE            ; 2620  ED 53 6A 63
        POP HL                      ; 2624  E1
        CALL SUB_1A58               ; 2625  CD 58 1A
        CALL SUB_296C               ; 2628  CD 6C 29
        EX (SP),HL                  ; 262B  E3
        PUSH HL                     ; 262C  E5
        LD HL,(FREE_PTR)            ; 262D  2A 6A 63
        LD D,H                      ; 2630  54
        LD E,L                      ; 2631  5D
        LD BC,FFFBH                 ; 2632  01 FB FF
        ADD HL,BC                   ; 2635  09
        POP AF                      ; 2636  F1
        LD (2642H),A                ; 2637  32 42 26
        PUSH AF                     ; 263A  F5
        PUSH HL                     ; 263B  E5
        PUSH DE                     ; 263C  D5
        CALL SUB_31D9               ; 263D  CD D9 31
        POP DE                      ; 2640  D1
        POP HL                      ; 2641  E1
        CALL SUB_32D8               ; 2642  CD D8 32
        POP HL                      ; 2645  E1
        EX (SP),HL                  ; 2646  E3
        CALL SUB_27D2               ; 2647  CD D2 27
        INC L                       ; 264A  2C
        LD C,A                      ; 264B  4F
        LD H,18H                    ; 264C  26 18
        SUB F1H                     ; 264E  D6 F1
        CALL SUB_27E1               ; 2650  CD E1 27
        ADD HL,HL                   ; 2653  29
        CALL SUB_1214               ; 2654  CD 14 12
        JP SUB_1B24                 ; 2657  C3 24 1B
        CALL SUB_165D               ; 265A  CD 5D 16
        LD HL,6529H                 ; 265D  21 29 65
        LD A,(HL)                   ; 2660  7E
        OR A                        ; 2661  B7
        JP Z,LOC_23A2               ; 2662  CA A2 23
        DEC (HL)                    ; 2665  35
        INC HL                      ; 2666  23
        DEC (HL)                    ; 2667  35
        LD HL,(STR_PTR)             ; 2668  2A 6E 63
        LD BC,0013H                 ; 266B  01 13 00
        ADD HL,BC                   ; 266E  09
        LD (STR_PTR),HL             ; 266F  22 6E 63
        JP LOC_122A                 ; 2672  C3 2A 12
        NOP                         ; 2675  00
        NOP                         ; 2676  00
SUB_2677:
        PUSH DE                     ; 2677  D5
        LD A,(DE)                   ; 2678  1A
        AND 7FH                     ; 2679  E6 7F
        SUB 40H                     ; 267B  D6 40
        JP C,LOC_2BCE               ; 267D  DA CE 2B
        LD B,A                      ; 2680  47
        LD A,20H                    ; 2681  3E 20
        SUB B                       ; 2683  90
        POP HL                      ; 2684  E1
        RET C                       ; 2685  D8
        RET Z                       ; 2686  C8
        PUSH HL                     ; 2687  E5
        INC HL                      ; 2688  23
        LD E,(HL)                   ; 2689  5E
        INC HL                      ; 268A  23
        LD D,(HL)                   ; 268B  56
        INC HL                      ; 268C  23
        LD C,(HL)                   ; 268D  4E
        INC HL                      ; 268E  23
        LD B,(HL)                   ; 268F  46
        PUSH AF                     ; 2690  F5
LOC_2691:
        SRL B                       ; 2691  CB 38
        RR C                        ; 2693  CB 19
        RR D                        ; 2695  CB 1A
        RR E                        ; 2697  CB 1B
        DEC A                       ; 2699  3D
        JR NZ,LOC_2691              ; 269A  20 F5
        POP AF                      ; 269C  F1
        POP HL                      ; 269D  E1
        PUSH HL                     ; 269E  E5
        ADD A,(HL)                  ; 269F  86
LOC_26A0:
        CALL SUB_344F               ; 26A0  CD 4F 34
        JP LOC_2BD1                 ; 26A3  C3 D1 2B
        PUSH DE                     ; 26A6  D5
        EX DE,HL                    ; 26A7  EB
        LD DE,3385H                 ; 26A8  11 85 33
        PUSH DE                     ; 26AB  D5
        CALL SUB_32D9               ; 26AC  CD D9 32
        POP DE                      ; 26AF  D1
        PUSH DE                     ; 26B0  D5
        CALL SUB_2677               ; 26B1  CD 77 26
        POP HL                      ; 26B4  E1
        POP DE                      ; 26B5  D1
        JP SUB_2B38                 ; 26B6  C3 38 2B
        CALL SUB_1A58               ; 26B9  CD 58 1A
        EXX                         ; 26BC  D9
        LD BC,0005H                 ; 26BD  01 05 00
        CALL SUB_1218               ; 26C0  CD 18 12
        CALL SUB_27E1               ; 26C3  CD E1 27
        INC L                       ; 26C6  2C
        CALL SUB_1A58               ; 26C7  CD 58 1A
        PUSH HL                     ; 26CA  E5
        LD HL,(FREE_PTR)            ; 26CB  2A 6A 63
        LD BC,FFFBH                 ; 26CE  01 FB FF
        ADD HL,BC                   ; 26D1  09
        PUSH HL                     ; 26D2  E5
        LD DE,3376H                 ; 26D3  11 76 33
        PUSH DE                     ; 26D6  D5
        CALL SUB_32D9               ; 26D7  CD D9 32
        POP DE                      ; 26DA  D1
        LD HL,(FREE_PTR)            ; 26DB  2A 6A 63
        PUSH HL                     ; 26DE  E5
        PUSH DE                     ; 26DF  D5
        CALL SUB_2D1E               ; 26E0  CD 1E 2D
        POP DE                      ; 26E3  D1
        CALL SUB_2677               ; 26E4  CD 77 26
        POP HL                      ; 26E7  E1
        CALL SUB_3396               ; 26E8  CD 96 33
        POP HL                      ; 26EB  E1
        LD (FREE_PTR),HL            ; 26EC  22 6A 63
        LD DE,3376H                 ; 26EF  11 76 33
        EX DE,HL                    ; 26F2  EB
        CALL SUB_2B38               ; 26F3  CD 38 2B
LOC_26F6:
        POP HL                      ; 26F6  E1
        CALL SUB_27E1               ; 26F7  CD E1 27
        ADD HL,HL                   ; 26FA  29
        JP SUB_1B24                 ; 26FB  C3 24 1B
        CALL SUB_1221               ; 26FE  CD 21 12
        PUSH HL                     ; 2701  E5
        LD A,E                      ; 2702  7B
        CP 15H                      ; 2703  FE 15
        JP NC,LOC_237A              ; 2705  D2 7A 23
        INC A                       ; 2708  3C
        LD HL,5974H                 ; 2709  21 74 59
        LD BC,0005H                 ; 270C  01 05 00
LOC_270F:
        ADD HL,BC                   ; 270F  09
        DEC A                       ; 2710  3D
        JR NZ,LOC_270F              ; 2711  20 FC
        EX DE,HL                    ; 2713  EB
LOC_2714:
        CALL SUB_2972               ; 2714  CD 72 29
        JP LOC_26F6                 ; 2717  C3 F6 26
; --- SUB_271A: called from 3 places ---
SUB_271A:
        PUSH HL                     ; 271A  E5
        LD A,(HL)                   ; 271B  7E
        AND 7FH                     ; 271C  E6 7F
        SUB 60H                     ; 271E  D6 60
        JP NC,LOC_237A              ; 2720  D2 7A 23
        ADD A,20H                   ; 2723  C6 20
        INC HL                      ; 2725  23
        LD E,(HL)                   ; 2726  5E
        INC HL                      ; 2727  23
        LD D,(HL)                   ; 2728  56
        INC HL                      ; 2729  23
        LD C,(HL)                   ; 272A  4E
        INC HL                      ; 272B  23
        LD B,(HL)                   ; 272C  46
        LD H,A                      ; 272D  67
        LD A,20H                    ; 272E  3E 20
        SUB H                       ; 2730  94
LOC_2731:
        SRL B                       ; 2731  CB 38
        RR C                        ; 2733  CB 19
        RR D                        ; 2735  CB 1A
        RR E                        ; 2737  CB 1B
        DEC A                       ; 2739  3D
        JR NZ,LOC_2731              ; 273A  20 F5
        POP HL                      ; 273C  E1
        LD A,(HL)                   ; 273D  7E
        AND 80H                     ; 273E  E6 80
        RET NZ                      ; 2740  C0
SUB_2741:
        LD H,A                      ; 2741  67
        LD L,A                      ; 2742  6F
        SBC HL,DE                   ; 2743  ED 52
        EX DE,HL                    ; 2745  EB
        LD HL,0000H                 ; 2746  21 00 00
        SBC HL,BC                   ; 2749  ED 42
        LD C,L                      ; 274B  4D
        LD B,H                      ; 274C  44
        RET                         ; 274D  C9
; --- SUB_274E: called from 6 places ---
SUB_274E:
        RL E                        ; 274E  CB 13
        RL D                        ; 2750  CB 12
        RL C                        ; 2752  CB 11
        RL B                        ; 2754  CB 10
        RET                         ; 2756  C9
SUB_2757:
        CALL SUB_1A58               ; 2757  CD 58 1A
        CALL SUB_296C               ; 275A  CD 6C 29
        CALL SUB_27E1               ; 275D  CD E1 27
        ADD HL,HL                   ; 2760  29
        RET                         ; 2761  C9
        POP BC                      ; 2762  C1
        NOP                         ; 2763  00
        NOP                         ; 2764  00
        NOP                         ; 2765  00
        ADD A,B                     ; 2766  80
        ADD A,B                     ; 2767  80
        NOP                         ; 2768  00
        NOP                         ; 2769  00
        NOP                         ; 276A  00
        NOP                         ; 276B  00
        LD B,C                      ; 276C  41
        NOP                         ; 276D  00
        NOP                         ; 276E  00
        NOP                         ; 276F  00
        ADD A,B                     ; 2770  80
        JP NZ,WS_DAA1               ; 2771  C2 A1 DA
        RRCA                        ; 2774  0F
        RET                         ; 2775  C9
        LD HL,(CUR_STMT)            ; 2776  2A 27 65
        DEC HL                      ; 2779  2B
; --- SUB_277A: called from 11 places ---
SUB_277A:
        INC HL                      ; 277A  23
; --- SUB_277B: called from 15 places ---
SUB_277B:
        LD A,(HL)                   ; 277B  7E
        CP 20H                      ; 277C  FE 20
        RET NZ                      ; 277E  C0
        JR SUB_277A                 ; 277F  18 F9
; --- SUB_2781: called from 4 places ---
SUB_2781:
        PUSH AF                     ; 2781  F5
        LD A,0DH                    ; 2782  3E 0D
LOC_2784:
        CP (HL)                     ; 2784  BE
        INC HL                      ; 2785  23
        JR NZ,LOC_2784              ; 2786  20 FC
        POP AF                      ; 2788  F1
        RET                         ; 2789  C9
LOC_278A:
        INC HL                      ; 278A  23
; --- SUB_278B: called from 7 places ---
SUB_278B:
        CALL SUB_2981               ; 278B  CD 81 29
        RET Z                       ; 278E  C8
        CP 22H                      ; 278F  FE 22
        JR NZ,LOC_278A              ; 2791  20 F7
LOC_2793:
        CALL SUB_277A               ; 2793  CD 7A 27
        CP 0DH                      ; 2796  FE 0D
        RET Z                       ; 2798  C8
        CP 22H                      ; 2799  FE 22
        JR NZ,LOC_2793              ; 279B  20 F6
        JR LOC_278A                 ; 279D  18 EB
; --- SUB_279F: called from 7 places ---
SUB_279F:
        LD A,C                      ; 279F  79
        CPL                         ; 27A0  2F
        LD C,A                      ; 27A1  4F
        LD A,B                      ; 27A2  78
        CPL                         ; 27A3  2F
        LD B,A                      ; 27A4  47
        INC BC                      ; 27A5  03
        RET                         ; 27A6  C9
; --- SUB_27A7: called from 8 places ---
SUB_27A7:
        CALL SUB_277B               ; 27A7  CD 7B 27
        SUB 30H                     ; 27AA  D6 30
        CP 0AH                      ; 27AC  FE 0A
        LD A,(HL)                   ; 27AE  7E
        RET                         ; 27AF  C9
; --- SUB_27B0: called from 23 places ---
SUB_27B0:
        LD A,H                      ; 27B0  7C
        SUB D                       ; 27B1  92
        RET NZ                      ; 27B2  C0
        LD A,L                      ; 27B3  7D
        SUB E                       ; 27B4  93
        RET                         ; 27B5  C9
LOC_27B6:
        POP HL                      ; 27B6  E1
LOC_27B7:
        EX (SP),HL                  ; 27B7  E3
LOC_27B8:
        PUSH AF                     ; 27B8  F5
        LD A,(HL)                   ; 27B9  7E
        INC HL                      ; 27BA  23
        LD H,(HL)                   ; 27BB  66
        LD L,A                      ; 27BC  6F
        POP AF                      ; 27BD  F1
        EX (SP),HL                  ; 27BE  E3
        RET                         ; 27BF  C9
LOC_27C0:
        POP HL                      ; 27C0  E1
LOC_27C1:
        EX (SP),HL                  ; 27C1  E3
        INC HL                      ; 27C2  23
        INC HL                      ; 27C3  23
        EX (SP),HL                  ; 27C4  E3
        RET                         ; 27C5  C9
SUB_27C6:
        LD HL,(FREE_PTR)            ; 27C6  2A 6A 63
        INC HL                      ; 27C9  23
        INC HL                      ; 27CA  23
        INC HL                      ; 27CB  23
        INC HL                      ; 27CC  23
        INC HL                      ; 27CD  23
        RET                         ; 27CE  C9
; --- SUB_27CF: called from 4 places ---
SUB_27CF:
        LD HL,(CUR_STMT)            ; 27CF  2A 27 65
; --- SUB_27D2: called from 41 places ---
SUB_27D2:
        CALL SUB_277B               ; 27D2  CD 7B 27
        EX (SP),HL                  ; 27D5  E3
        CP (HL)                     ; 27D6  BE
        INC HL                      ; 27D7  23
        JP NZ,LOC_27B8              ; 27D8  C2 B8 27
        INC HL                      ; 27DB  23
        JR LOC_27E9                 ; 27DC  18 0B
SUB_27DE:
        LD HL,(CUR_STMT)            ; 27DE  2A 27 65
; --- SUB_27E1: called from 65 places ---
SUB_27E1:
        CALL SUB_277B               ; 27E1  CD 7B 27
        EX (SP),HL                  ; 27E4  E3
        CP (HL)                     ; 27E5  BE
        JP NZ,LOC_2372              ; 27E6  C2 72 23
LOC_27E9:
        INC HL                      ; 27E9  23
        EX (SP),HL                  ; 27EA  E3
        JP SUB_277A                 ; 27EB  C3 7A 27
; --- SUB_27EE: called from 5 places ---
SUB_27EE:
        XOR A                       ; 27EE  AF
        CP H                        ; 27EF  BC
        JR Z,LOC_27F8               ; 27F0  28 06
        EX DE,HL                    ; 27F2  EB
        XOR A                       ; 27F3  AF
        CP H                        ; 27F4  BC
        JP NZ,LOC_27B7              ; 27F5  C2 B7 27
LOC_27F8:
        LD A,L                      ; 27F8  7D
        LD L,H                      ; 27F9  6C
LOC_27FA:
        OR A                        ; 27FA  B7
        JR NZ,LOC_2801              ; 27FB  20 04
LOC_27FD:
        EX DE,HL                    ; 27FD  EB
        JP LOC_27C1                 ; 27FE  C3 C1 27
LOC_2801:
        SRL A                       ; 2801  CB 3F
        JR NC,LOC_2809              ; 2803  30 04
        ADD HL,DE                   ; 2805  19
        JP C,LOC_27B7               ; 2806  DA B7 27
LOC_2809:
        OR A                        ; 2809  B7
        JP Z,LOC_27FD               ; 280A  CA FD 27
        SLA E                       ; 280D  CB 23
        RL D                        ; 280F  CB 12
        JP NC,LOC_27FA              ; 2811  D2 FA 27
        JP LOC_27B7                 ; 2814  C3 B7 27
; --- SUB_2817: called from 7 places ---
SUB_2817:
        CALL SUB_27EE               ; 2817  CD EE 27
        LD A,D                      ; 281A  7A
        INC HL                      ; 281B  23
        RET                         ; 281C  C9
SUB_281D:
        LD DE,0000H                 ; 281D  11 00 00
LOC_2820:
        CALL SUB_27A7               ; 2820  CD A7 27
        JP NC,LOC_27C1              ; 2823  D2 C1 27
        PUSH HL                     ; 2826  E5
        LD HL,000AH                 ; 2827  21 0A 00
        CALL SUB_27EE               ; 282A  CD EE 27
        OR (HL)                     ; 282D  B6
        DAA                         ; 282E  27
        POP HL                      ; 282F  E1
        LD A,(HL)                   ; 2830  7E
        AND 0FH                     ; 2831  E6 0F
        ADD A,E                     ; 2833  83
        LD E,A                      ; 2834  5F
        LD A,D                      ; 2835  7A
        ADC A,00H                   ; 2836  CE 00
        LD D,A                      ; 2838  57
        JP C,LOC_27B7               ; 2839  DA B7 27
        INC HL                      ; 283C  23
        JP LOC_2820                 ; 283D  C3 20 28
; --- SUB_2840: called from 9 places ---
SUB_2840:
        CALL SUB_281D               ; 2840  CD 1D 28
        LD (HL),D                   ; 2843  72
        INC HL                      ; 2844  23
        RET                         ; 2845  C9
SUB_2846:
        LD C,00H                    ; 2846  0E 00
SUB_2848:
        LD A,20H                    ; 2848  3E 20
        LD (DE),A                   ; 284A  12
        INC DE                      ; 284B  13
        PUSH DE                     ; 284C  D5
        LD B,00H                    ; 284D  06 00
        LD DE,2710H                 ; 284F  11 10 27
        CALL SUB_2871               ; 2852  CD 71 28
        LD DE,03E8H                 ; 2855  11 E8 03
        CALL SUB_2871               ; 2858  CD 71 28
        LD DE,0064H                 ; 285B  11 64 00
        CALL SUB_2871               ; 285E  CD 71 28
        LD DE,000AH                 ; 2861  11 0A 00
        CALL SUB_2871               ; 2864  CD 71 28
        LD A,L                      ; 2867  7D
        POP DE                      ; 2868  D1
        OR 30H                      ; 2869  F6 30
        LD (DE),A                   ; 286B  12
        INC DE                      ; 286C  13
        LD A,0DH                    ; 286D  3E 0D
        LD (DE),A                   ; 286F  12
        RET                         ; 2870  C9
; --- SUB_2871: called from 4 places ---
SUB_2871:
        LD A,FFH                    ; 2871  3E FF
LOC_2873:
        INC A                       ; 2873  3C
        OR A                        ; 2874  B7
        SBC HL,DE                   ; 2875  ED 52
        JR NC,LOC_2873              ; 2877  30 FA
        ADD HL,DE                   ; 2879  19
        OR A                        ; 287A  B7
        JR NZ,LOC_2880              ; 287B  20 03
        OR B                        ; 287D  B0
        RET Z                       ; 287E  C8
        XOR A                       ; 287F  AF
LOC_2880:
        INC B                       ; 2880  04
        OR 30H                      ; 2881  F6 30
        POP DE                      ; 2883  D1
        EX (SP),HL                  ; 2884  E3
        LD (HL),A                   ; 2885  77
        INC HL                      ; 2886  23
        EX (SP),HL                  ; 2887  E3
        PUSH DE                     ; 2888  D5
        INC C                       ; 2889  0C
        RET                         ; 288A  C9
; --- SUB_288B: called from 6 places ---
SUB_288B:
        LD DE,6180H                 ; 288B  11 80 61
        PUSH DE                     ; 288E  D5
        CALL SUB_2846               ; 288F  CD 46 28
        POP DE                      ; 2892  D1
        RET                         ; 2893  C9
SUB_2894:
        LD BC,0000H                 ; 2894  01 00 00
SUB_2897:
        LD HL,(FREE_PTR)            ; 2897  2A 6A 63
        ADD HL,BC                   ; 289A  09
        JP C,LOC_2386               ; 289B  DA 86 23
        EX DE,HL                    ; 289E  EB
        LD HL,FF9CH                 ; 289F  21 9C FF
        ADD HL,SP                   ; 28A2  39
        XOR A                       ; 28A3  AF
        SBC HL,DE                   ; 28A4  ED 52
        RET NC                      ; 28A6  D0
        JP LOC_2386                 ; 28A7  C3 86 23
SUB_28AA:
        PUSH HL                     ; 28AA  E5
        PUSH DE                     ; 28AB  D5
        CALL SUB_2897               ; 28AC  CD 97 28
        POP DE                      ; 28AF  D1
        POP HL                      ; 28B0  E1
        RET                         ; 28B1  C9
; --- SUB_28B2: called from 4 places ---
SUB_28B2:
        LD E,(HL)                   ; 28B2  5E
        INC HL                      ; 28B3  23
        LD D,(HL)                   ; 28B4  56
        INC HL                      ; 28B5  23
        LD A,(HL)                   ; 28B6  7E
        INC HL                      ; 28B7  23
        LD H,(HL)                   ; 28B8  66
        LD L,A                      ; 28B9  6F
        EX DE,HL                    ; 28BA  EB
        LD A,L                      ; 28BB  7D
        OR H                        ; 28BC  B4
        RET                         ; 28BD  C9
; --- SUB_28BE: called from 8 places ---
SUB_28BE:
        PUSH BC                     ; 28BE  C5
        PUSH HL                     ; 28BF  E5
        PUSH DE                     ; 28C0  D5
        EX DE,HL                    ; 28C1  EB
        ADD HL,BC                   ; 28C2  09
        EX DE,HL                    ; 28C3  EB
        CALL SUB_27C6               ; 28C4  CD C6 27
        LD A,L                      ; 28C7  7D
        SUB E                       ; 28C8  93
        LD C,A                      ; 28C9  4F
        LD A,H                      ; 28CA  7C
        SBC A,D                     ; 28CB  9A
        LD B,A                      ; 28CC  47
        INC BC                      ; 28CD  03
        POP HL                      ; 28CE  E1
        PUSH HL                     ; 28CF  E5
        EX DE,HL                    ; 28D0  EB
        JP LOC_28F4                 ; 28D1  C3 F4 28
; --- SUB_28D4: called from 9 places ---
SUB_28D4:
        CALL SUB_28AA               ; 28D4  CD AA 28
        PUSH BC                     ; 28D7  C5
        PUSH HL                     ; 28D8  E5
        PUSH DE                     ; 28D9  D5
        CALL SUB_27C6               ; 28DA  CD C6 27
        PUSH HL                     ; 28DD  E5
        ADD HL,BC                   ; 28DE  09
        EX (SP),HL                  ; 28DF  E3
        LD A,L                      ; 28E0  7D
        SUB E                       ; 28E1  93
        LD C,A                      ; 28E2  4F
        LD A,H                      ; 28E3  7C
        SBC A,D                     ; 28E4  9A
        LD B,A                      ; 28E5  47
        INC BC                      ; 28E6  03
        POP DE                      ; 28E7  D1
        LDDR                        ; 28E8  ED B8
LOC_28EA:
        POP DE                      ; 28EA  D1
        POP HL                      ; 28EB  E1
        POP BC                      ; 28EC  C1
        RET                         ; 28ED  C9
; --- SUB_28EE: called from 6 places ---
SUB_28EE:
        CALL SUB_28D4               ; 28EE  CD D4 28
; --- SUB_28F1: called from 9 places ---
SUB_28F1:
        PUSH BC                     ; 28F1  C5
        PUSH HL                     ; 28F2  E5
        PUSH DE                     ; 28F3  D5
LOC_28F4:
        LD A,C                      ; 28F4  79
        OR B                        ; 28F5  B0
        JR Z,LOC_28FA               ; 28F6  28 02
        LDIR                        ; 28F8  ED B0
LOC_28FA:
        JP LOC_28EA                 ; 28FA  C3 EA 28
; --- SUB_28FD: called from 3 places ---
SUB_28FD:
        LD (WS_62B4),HL             ; 28FD  22 B4 62
SUB_2900:
        LD HL,652CH                 ; 2900  21 2C 65
LOC_2903:
        PUSH HL                     ; 2903  E5
        CALL SUB_28B2               ; 2904  CD B2 28
        JP Z,LOC_27B6               ; 2907  CA B6 27
        PUSH HL                     ; 290A  E5
        LD HL,(WS_62B4)             ; 290B  2A B4 62
        CALL SUB_27B0               ; 290E  CD B0 27
        POP HL                      ; 2911  E1
        JP Z,LOC_27C0               ; 2912  CA C0 27
        JP C,LOC_27C0               ; 2915  DA C0 27
        POP AF                      ; 2918  F1
        JP LOC_2903                 ; 2919  C3 03 29
SUB_291C:
        PUSH HL                     ; 291C  E5
        LD E,(HL)                   ; 291D  5E
        INC HL                      ; 291E  23
        LD D,(HL)                   ; 291F  56
        LD A,E                      ; 2920  7B
        OR D                        ; 2921  B2
        JP Z,LOC_27B6               ; 2922  CA B6 27
        LD HL,(WS_62B6)             ; 2925  2A B6 62
        CALL SUB_27B0               ; 2928  CD B0 27
        POP HL                      ; 292B  E1
        INC HL                      ; 292C  23
        INC HL                      ; 292D  23
        JP LOC_27C1                 ; 292E  C3 C1 27
LOC_2931:
        ADD HL,BC                   ; 2931  09
        EX DE,HL                    ; 2932  EB
        POP HL                      ; 2933  E1
        LD (HL),E                   ; 2934  73
        INC HL                      ; 2935  23
        LD (HL),D                   ; 2936  72
        EX DE,HL                    ; 2937  EB
SUB_2938:
        PUSH HL                     ; 2938  E5
        CALL SUB_28B2               ; 2939  CD B2 28
        JR NZ,LOC_2931              ; 293C  20 F3
        POP HL                      ; 293E  E1
        RET                         ; 293F  C9
; --- SUB_2940: called from 4 places ---
SUB_2940:
        PUSH HL                     ; 2940  E5
        LD BC,0004H                 ; 2941  01 04 00
        ADD HL,BC                   ; 2944  09
        CALL SUB_294E               ; 2945  CD 4E 29
        INC BC                      ; 2948  03
        POP HL                      ; 2949  E1
        RET                         ; 294A  C9
; --- SUB_294B: called from 4 places ---
SUB_294B:
        LD BC,0000H                 ; 294B  01 00 00
SUB_294E:
        PUSH HL                     ; 294E  E5
        LD A,0DH                    ; 294F  3E 0D
LOC_2951:
        CP (HL)                     ; 2951  BE
        INC HL                      ; 2952  23
        INC BC                      ; 2953  03
        JR NZ,LOC_2951              ; 2954  20 FB
        DEC BC                      ; 2956  0B
        POP HL                      ; 2957  E1
        RET                         ; 2958  C9
; --- SUB_2959: called from 27 places ---
SUB_2959:
        LD A,E                      ; 2959  7B
        EX DE,HL                    ; 295A  EB
        LD HL,(WS_6368)             ; 295B  2A 68 63
        INC A                       ; 295E  3C
LOC_295F:
        DEC A                       ; 295F  3D
        CALL NZ,SUB_2781            ; 2960  C4 81 27
        JR NZ,LOC_295F              ; 2963  20 FA
        EX DE,HL                    ; 2965  EB
        RET                         ; 2966  C9
; --- SUB_2967: called from 13 places ---
SUB_2967:
        LD A,D                      ; 2967  7A
        OR A                        ; 2968  B7
        RET NZ                      ; 2969  C0
        JR LOC_296F                 ; 296A  18 03
; --- SUB_296C: called from 9 places ---
SUB_296C:
        LD A,D                      ; 296C  7A
        OR A                        ; 296D  B7
        RET Z                       ; 296E  C8
LOC_296F:
        JP LOC_237E                 ; 296F  C3 7E 23
; --- SUB_2972: called from 3 places ---
SUB_2972:
        LD HL,(FREE_PTR)            ; 2972  2A 6A 63
        EX DE,HL                    ; 2975  EB
LOC_2976:
        LD BC,0005H                 ; 2976  01 05 00
        LDIR                        ; 2979  ED B0
        RET                         ; 297B  C9
; --- SUB_297C: called from 3 places ---
SUB_297C:
        LD HL,(FREE_PTR)            ; 297C  2A 6A 63
        JR LOC_2976                 ; 297F  18 F5
; --- SUB_2981: called from 28 places ---
SUB_2981:
        CALL SUB_277B               ; 2981  CD 7B 27
        CP 0DH                      ; 2984  FE 0D
        RET Z                       ; 2986  C8
        JP LOC_1312                 ; 2987  C3 12 13
; --- SUB_298A: called from 3 places ---
SUB_298A:
        LD HL,0000H                 ; 298A  21 00 00
        LD (WS_633A),HL             ; 298D  22 3A 63
        LD HL,652CH                 ; 2990  21 2C 65
        CALL SUB_2A2B               ; 2993  CD 2B 2A
        LD (WS_633C),HL             ; 2996  22 3C 63
        XOR A                       ; 2999  AF
        LD (4977H),A                ; 299A  32 77 49
        CALL SUB_24BC               ; 299D  CD BC 24
        CALL SUB_29AF               ; 29A0  CD AF 29
        CALL SUB_29DA               ; 29A3  CD DA 29
SUB_29A6:
        LD HL,6523H                 ; 29A6  21 23 65
        CALL SUB_2A2B               ; 29A9  CD 2B 2A   <-- UNRESOLVED ALIGNMENT: also targeted as 29ABH
        JP SUB_2A2B                 ; 29AC  C3 2B 2A
SUB_29AF:
        LD HL,62D7H                 ; 29AF  21 D7 62
        LD DE,0009H                 ; 29B2  11 09 00
        LD B,0BH                    ; 29B5  06 0B
LOC_29B7:
        LD (HL),00H                 ; 29B7  36 00
        ADD HL,DE                   ; 29B9  19
        DJNZ LOC_29B7               ; 29BA  10 FB
        LD HL,633CH                 ; 29BC  21 3C 63
        LD B,18H                    ; 29BF  06 18
        XOR A                       ; 29C1  AF
        LD E,(HL)                   ; 29C2  5E
        INC HL                      ; 29C3  23
        LD D,(HL)                   ; 29C4  56
        DEC HL                      ; 29C5  2B
LOC_29C6:
        LD (HL),E                   ; 29C6  73
        INC HL                      ; 29C7  23
        LD (HL),D                   ; 29C8  72
        INC HL                      ; 29C9  23
        LD (DE),A                   ; 29CA  12
        INC DE                      ; 29CB  13
        LD (DE),A                   ; 29CC  12
        INC DE                      ; 29CD  13
        DJNZ LOC_29C6               ; 29CE  10 F6
SUB_29D0:
        LD HL,(WS_6368)             ; 29D0  2A 68 63
        CALL SUB_2A2B               ; 29D3  CD 2B 2A
        LD (FREE_PTR),HL            ; 29D6  22 6A 63
        RET                         ; 29D9  C9
; --- SUB_29DA: called from 6 places ---
SUB_29DA:
        LD HL,6516H                 ; 29DA  21 16 65
        LD (ARRAY_PTR),HL           ; 29DD  22 70 63
        LD HL,64ADH                 ; 29E0  21 AD 64
        LD (STR_PTR),HL             ; 29E3  22 6E 63
        LD HL,6390H                 ; 29E6  21 90 63
        LD (WS_636C),HL             ; 29E9  22 6C 63
        LD HL,6529H                 ; 29EC  21 29 65
        CALL SUB_2A2B               ; 29EF  CD 2B 2A
        LD (HL),A                   ; 29F2  77
        RET                         ; 29F3  C9
SUB_29F4:
        LD HL,62D7H                 ; 29F4  21 D7 62
        LD DE,0009H                 ; 29F7  11 09 00
        LD B,0BH                    ; 29FA  06 0B
LOC_29FC:
        LD (HL),00H                 ; 29FC  36 00
        ADD HL,DE                   ; 29FE  19
        DJNZ LOC_29FC               ; 29FF  10 FB
        LD HL,(WS_633C)             ; 2A01  2A 3C 63
        PUSH HL                     ; 2A04  E5
        LD BC,001EH                 ; 2A05  01 1E 00
        ADD HL,BC                   ; 2A08  09
        EX DE,HL                    ; 2A09  EB
        LD HL,(WS_635A)             ; 2A0A  2A 5A 63
        XOR A                       ; 2A0D  AF
        SBC HL,DE                   ; 2A0E  ED 52
        LD C,L                      ; 2A10  4D
        LD B,H                      ; 2A11  44
        POP DE                      ; 2A12  D1
        CALL SUB_28BE               ; 2A13  CD BE 28
        LD HL,0000H                 ; 2A16  21 00 00
        LD (WS_FFFF),HL             ; 2A19  22 FF FF
        CALL SUB_279F               ; 2A1C  CD 9F 27
        CALL SUB_2A31               ; 2A1F  CD 31 2A
        LD HL,633CH                 ; 2A22  21 3C 63
        LD B,0FH                    ; 2A25  06 0F
        XOR A                       ; 2A27  AF
        JP LOC_29C6                 ; 2A28  C3 C6 29
; --- SUB_2A2B: called from 12 places ---
SUB_2A2B:
        XOR A                       ; 2A2B  AF
; --- SUB_2A2C: called from 4 places ---
SUB_2A2C:
        LD (HL),A                   ; 2A2C  77
        INC HL                      ; 2A2D  23
        LD (HL),A                   ; 2A2E  77
        INC HL                      ; 2A2F  23
        RET                         ; 2A30  C9
; --- SUB_2A31: called from 18 places ---
SUB_2A31:
        PUSH HL                     ; 2A31  E5
        LD A,E                      ; 2A32  7B
        EX AF,AF_                   ; 2A33  08
        LD A,D                      ; 2A34  7A
        LD HL,636AH                 ; 2A35  21 6A 63
LOC_2A38:
        LD E,(HL)                   ; 2A38  5E
        INC HL                      ; 2A39  23
        LD D,(HL)                   ; 2A3A  56
        CP D                        ; 2A3B  BA
        JP C,LOC_2A48               ; 2A3C  DA 48 2A
        JP NZ,LOC_2A54              ; 2A3F  C2 54 2A
        EX AF,AF_                   ; 2A42  08
        CP E                        ; 2A43  BB
        JP NC,LOC_2A53              ; 2A44  D2 53 2A
        EX AF,AF_                   ; 2A47  08
LOC_2A48:
        EX DE,HL                    ; 2A48  EB
        ADD HL,BC                   ; 2A49  09
        EX DE,HL                    ; 2A4A  EB
        LD (HL),D                   ; 2A4B  72
        DEC HL                      ; 2A4C  2B
        LD (HL),E                   ; 2A4D  73
        DEC HL                      ; 2A4E  2B
        DEC HL                      ; 2A4F  2B
        JP LOC_2A38                 ; 2A50  C3 38 2A
LOC_2A53:
        EX AF,AF_                   ; 2A53  08
LOC_2A54:
        LD D,A                      ; 2A54  57
        EX AF,AF_                   ; 2A55  08
        LD E,A                      ; 2A56  5F
        POP HL                      ; 2A57  E1
        RET                         ; 2A58  C9
; --- SUB_2A59: called from 4 places ---
SUB_2A59:
        CALL SUB_277B               ; 2A59  CD 7B 27
SUB_2A5C:
        LD BC,0000H                 ; 2A5C  01 00 00
        LD DE,0D2CH                 ; 2A5F  11 2C 0D
        CP 22H                      ; 2A62  FE 22
        JR NZ,LOC_2A68              ; 2A64  20 02
        LD E,A                      ; 2A66  5F
        INC HL                      ; 2A67  23
LOC_2A68:
        PUSH HL                     ; 2A68  E5
LOC_2A69:
        LD A,(HL)                   ; 2A69  7E
        CP D                        ; 2A6A  BA
        JR Z,LOC_2A75               ; 2A6B  28 08
        CP E                        ; 2A6D  BB
        INC HL                      ; 2A6E  23
        JR Z,LOC_2A75               ; 2A6F  28 04
        INC BC                      ; 2A71  03
        JR LOC_2A69                 ; 2A72  18 F5
; --- SUB_2A74: called from 7 places ---
SUB_2A74:
        PUSH HL                     ; 2A74  E5
LOC_2A75:
        EX (SP),HL                  ; 2A75  E3
        EX DE,HL                    ; 2A76  EB
        LD HL,(WS_6368)             ; 2A77  2A 68 63
        XOR A                       ; 2A7A  AF
LOC_2A7B:
        PUSH AF                     ; 2A7B  F5
        LD A,(HL)                   ; 2A7C  7E
        OR A                        ; 2A7D  B7
        JR Z,LOC_2A87               ; 2A7E  28 07
        CALL SUB_2781               ; 2A80  CD 81 27
        POP AF                      ; 2A83  F1
        INC A                       ; 2A84  3C
        JR LOC_2A7B                 ; 2A85  18 F4
LOC_2A87:
        EX DE,HL                    ; 2A87  EB
        INC BC                      ; 2A88  03
        CALL SUB_28EE               ; 2A89  CD EE 28
        LD HL,(FREE_PTR)            ; 2A8C  2A 6A 63
        ADD HL,BC                   ; 2A8F  09
        LD (FREE_PTR),HL            ; 2A90  22 6A 63
        EX DE,HL                    ; 2A93  EB
        DEC BC                      ; 2A94  0B
        ADD HL,BC                   ; 2A95  09
        LD (HL),0DH                 ; 2A96  36 0D
        POP AF                      ; 2A98  F1
        LD E,A                      ; 2A99  5F
        LD D,01H                    ; 2A9A  16 01
        POP HL                      ; 2A9C  E1
        JP SUB_277B                 ; 2A9D  C3 7B 27
; --- SUB_2AA0: called from 3 places ---
SUB_2AA0:
        CALL SUB_277B               ; 2AA0  CD 7B 27
        CP 0DH                      ; 2AA3  FE 0D
        JP Z,LOC_27B7               ; 2AA5  CA B7 27
        PUSH HL                     ; 2AA8  E5
        DEC HL                      ; 2AA9  2B
LOC_2AAA:
        INC HL                      ; 2AAA  23
        CALL SUB_277B               ; 2AAB  CD 7B 27
        CP 2BH                      ; 2AAE  FE 2B
        JR NZ,LOC_2AB4              ; 2AB0  20 02
        LD A,BCH                    ; 2AB2  3E BC
LOC_2AB4:
        CP 2DH                      ; 2AB4  FE 2D
        JR NZ,LOC_2ABA              ; 2AB6  20 02
        LD A,BDH                    ; 2AB8  3E BD
LOC_2ABA:
        LD (HL),A                   ; 2ABA  77
        CALL SUB_2AD0               ; 2ABB  CD D0 2A
        JR Z,LOC_2AAA               ; 2ABE  28 EA
        CP 45H                      ; 2AC0  FE 45
        JR Z,LOC_2AAA               ; 2AC2  28 E6
        CP 0DH                      ; 2AC4  FE 0D
        JP NZ,LOC_5CE2              ; 2AC6  C2 E2 5C
LOC_2AC9:
        POP HL                      ; 2AC9  E1
        CALL SUB_1A58               ; 2ACA  CD 58 1A
        JP LOC_27C1                 ; 2ACD  C3 C1 27
SUB_2AD0:
        CALL SUB_27A7               ; 2AD0  CD A7 27
        JR NC,LOC_2AD7              ; 2AD3  30 02
        CP (HL)                     ; 2AD5  BE
        RET                         ; 2AD6  C9
LOC_2AD7:
        CP 2EH                      ; 2AD7  FE 2E
        RET Z                       ; 2AD9  C8
        CP BDH                      ; 2ADA  FE BD
        RET Z                       ; 2ADC  C8
        CP BCH                      ; 2ADD  FE BC
        RET                         ; 2ADF  C9
SUB_2AE0:
        PUSH HL                     ; 2AE0  E5
        LD HL,(FREE_PTR)            ; 2AE1  2A 6A 63
        LD DE,0000H                 ; 2AE4  11 00 00
        LD A,(HL)                   ; 2AE7  7E
        OR A                        ; 2AE8  B7
        JP P,LOC_237A               ; 2AE9  F2 7A 23
        CP C1H                      ; 2AEC  FE C1
        JP C,LOC_2B07               ; 2AEE  DA 07 2B
        SUB D1H                     ; 2AF1  D6 D1
        JP NC,LOC_237A              ; 2AF3  D2 7A 23
LOC_2AF6:
        LD E,03H                    ; 2AF6  1E 03
        ADD HL,DE                   ; 2AF8  19
        LD E,(HL)                   ; 2AF9  5E
        INC HL                      ; 2AFA  23
        LD D,(HL)                   ; 2AFB  56
        JP LOC_2B03                 ; 2AFC  C3 03 2B
LOC_2AFF:
        SRL D                       ; 2AFF  CB 3A
        RR E                        ; 2B01  CB 1B
LOC_2B03:
        INC A                       ; 2B03  3C
        JP NZ,LOC_2AFF              ; 2B04  C2 FF 2A
LOC_2B07:
        POP HL                      ; 2B07  E1
        RET                         ; 2B08  C9
; --- SUB_2B09: called from 7 places ---
SUB_2B09:
        LD HL,616EH                 ; 2B09  21 6E 61
        JR LOC_2B11                 ; 2B0C  18 03
; --- SUB_2B0E: called from 4 places ---
SUB_2B0E:
        LD HL,6172H                 ; 2B0E  21 72 61
LOC_2B11:
        LD (HL),C                   ; 2B11  71
        INC HL                      ; 2B12  23
        LD (HL),B                   ; 2B13  70
        INC HL                      ; 2B14  23
        LD (HL),E                   ; 2B15  73
        INC HL                      ; 2B16  23
        LD (HL),D                   ; 2B17  72
        INC HL                      ; 2B18  23
        RET                         ; 2B19  C9
; --- SUB_2B1A: called from 3 places ---
SUB_2B1A:
        XOR A                       ; 2B1A  AF
        LD (WS_6179),A              ; 2B1B  32 79 61
        RET                         ; 2B1E  C9
; --- SUB_2B1F: called from 5 places ---
SUB_2B1F:
        PUSH HL                     ; 2B1F  E5
        LD HL,(CUR_LINE)            ; 2B20  2A 25 65
        LD A,L                      ; 2B23  7D
        OR H                        ; 2B24  B4
        JP NZ,LOC_23BA              ; 2B25  C2 BA 23
        POP HL                      ; 2B28  E1
        RET                         ; 2B29  C9
; --- SUB_2B2A: called from 15 places ---
SUB_2B2A:
        PUSH HL                     ; 2B2A  E5
        LD HL,(CUR_LINE)            ; 2B2B  2A 25 65
        LD A,L                      ; 2B2E  7D
        OR H                        ; 2B2F  B4
        JP Z,LOC_23BA               ; 2B30  CA BA 23
        POP HL                      ; 2B33  E1
        RET                         ; 2B34  C9
DATA_2B35:
        NOP                         ; 2B35  00
DATA_2B36:
        ADD A,B                     ; 2B36  80
DATA_2B37:
        ADD A,(HL)                  ; 2B37  86
; --- SUB_2B38: called from 7 places ---
SUB_2B38:
        XOR A                       ; 2B38  AF
        JR LOC_2B3D                 ; 2B39  18 02
SUB_2B3B:
        LD A,80H                    ; 2B3B  3E 80
LOC_2B3D:
        PUSH DE                     ; 2B3D  D5
        XOR (HL)                    ; 2B3E  AE
        CPL                         ; 2B3F  2F
        LD C,A                      ; 2B40  4F
        LD A,(DE)                   ; 2B41  1A
        AND 80H                     ; 2B42  E6 80
        LD B,A                      ; 2B44  47
        XOR C                       ; 2B45  A9
        CPL                         ; 2B46  2F
        AND 80H                     ; 2B47  E6 80
        LD C,A                      ; 2B49  4F
LOC_2B4A:
        PUSH BC                     ; 2B4A  C5
        LD B,(HL)                   ; 2B4B  46
        RES 7,B                     ; 2B4C  CB B8
        LD A,(DE)                   ; 2B4E  1A
        AND 7FH                     ; 2B4F  E6 7F
        CP B                        ; 2B51  B8
        JP NC,LOC_2B60              ; 2B52  D2 60 2B
        POP BC                      ; 2B55  C1
        EX DE,HL                    ; 2B56  EB
        LD A,B                      ; 2B57  78
        XOR C                       ; 2B58  A9
        CPL                         ; 2B59  2F
        AND 80H                     ; 2B5A  E6 80
        LD B,A                      ; 2B5C  47
        JP LOC_2B4A                 ; 2B5D  C3 4A 2B
LOC_2B60:
        LD C,A                      ; 2B60  4F
        ADD A,40H                   ; 2B61  C6 40
        LD (DATA_2B37),A            ; 2B63  32 37 2B
        LD A,C                      ; 2B66  79
        SUB B                       ; 2B67  90
        POP BC                      ; 2B68  C1
        LD (DATA_2B35),BC           ; 2B69  ED 43 35 2B
        PUSH DE                     ; 2B6D  D5
        INC HL                      ; 2B6E  23
        LD E,(HL)                   ; 2B6F  5E
        INC HL                      ; 2B70  23
        LD D,(HL)                   ; 2B71  56
        INC HL                      ; 2B72  23
        LD C,(HL)                   ; 2B73  4E
        INC HL                      ; 2B74  23
        LD B,(HL)                   ; 2B75  46
        POP HL                      ; 2B76  E1
        INC HL                      ; 2B77  23
        JP Z,LOC_2B99               ; 2B78  CA 99 2B
LOC_2B7B:
        CP 08H                      ; 2B7B  FE 08
        JP NC,LOC_2B8F              ; 2B7D  D2 8F 2B
LOC_2B80:
        SRL B                       ; 2B80  CB 38
        RR C                        ; 2B82  CB 19
        RR D                        ; 2B84  CB 1A
        RR E                        ; 2B86  CB 1B
        DEC A                       ; 2B88  3D
        JP NZ,LOC_2B80              ; 2B89  C2 80 2B
        JP LOC_2B99                 ; 2B8C  C3 99 2B
LOC_2B8F:
        LD E,D                      ; 2B8F  5A
        LD D,C                      ; 2B90  51
        LD C,B                      ; 2B91  48
        LD B,00H                    ; 2B92  06 00
        SUB 08H                     ; 2B94  D6 08
        JP NZ,LOC_2B7B              ; 2B96  C2 7B 2B
LOC_2B99:
        LD A,(DATA_2B35)            ; 2B99  3A 35 2B
        OR A                        ; 2B9C  B7
        JP Z,LOC_2BDC               ; 2B9D  CA DC 2B
        LD A,(HL)                   ; 2BA0  7E
        INC HL                      ; 2BA1  23
        ADD A,E                     ; 2BA2  83
        LD E,A                      ; 2BA3  5F
        LD A,(HL)                   ; 2BA4  7E
        INC HL                      ; 2BA5  23
        ADC A,D                     ; 2BA6  8A
        LD D,A                      ; 2BA7  57
        LD A,(HL)                   ; 2BA8  7E
        INC HL                      ; 2BA9  23
        ADC A,C                     ; 2BAA  89
        LD C,A                      ; 2BAB  4F
        LD A,(HL)                   ; 2BAC  7E
        ADC A,B                     ; 2BAD  88
        LD B,A                      ; 2BAE  47
        JP NC,LOC_2BBE              ; 2BAF  D2 BE 2B
        RR B                        ; 2BB2  CB 18
        RR C                        ; 2BB4  CB 19
        RR D                        ; 2BB6  CB 1A
        RR E                        ; 2BB8  CB 1B
        LD HL,2B37H                 ; 2BBA  21 37 2B
        INC (HL)                    ; 2BBD  34
LOC_2BBE:
        LD HL,2B37H                 ; 2BBE  21 37 2B
        LD A,(HL)                   ; 2BC1  7E
        SUB 40H                     ; 2BC2  D6 40
        JP C,LOC_2BCE               ; 2BC4  DA CE 2B
        JP M,LOC_2376               ; 2BC7  FA 76 23
        DEC HL                      ; 2BCA  2B
        OR (HL)                     ; 2BCB  B6
        JR LOC_2BD1                 ; 2BCC  18 03
LOC_2BCE:
        CALL SUB_3469               ; 2BCE  CD 69 34
LOC_2BD1:
        POP HL                      ; 2BD1  E1
; --- SUB_2BD2: called from 3 places ---
SUB_2BD2:
        LD (HL),A                   ; 2BD2  77
        INC HL                      ; 2BD3  23
        LD (HL),E                   ; 2BD4  73
        INC HL                      ; 2BD5  23
        LD (HL),D                   ; 2BD6  72
        INC HL                      ; 2BD7  23
        LD (HL),C                   ; 2BD8  71
        INC HL                      ; 2BD9  23
        LD (HL),B                   ; 2BDA  70
        RET                         ; 2BDB  C9
LOC_2BDC:
        LD A,(HL)                   ; 2BDC  7E
        INC HL                      ; 2BDD  23
        SUB E                       ; 2BDE  93
        LD E,A                      ; 2BDF  5F
        LD A,(HL)                   ; 2BE0  7E
        INC HL                      ; 2BE1  23
        SBC A,D                     ; 2BE2  9A
        LD D,A                      ; 2BE3  57
        LD A,(HL)                   ; 2BE4  7E
        INC HL                      ; 2BE5  23
        SBC A,C                     ; 2BE6  99
        LD C,A                      ; 2BE7  4F
        LD A,(HL)                   ; 2BE8  7E
        SBC A,B                     ; 2BE9  98
        LD B,A                      ; 2BEA  47
        CALL C,SUB_2C2B             ; 2BEB  DC 2B 2C
        OR C                        ; 2BEE  B1
        OR D                        ; 2BEF  B2
        JP NZ,LOC_2BF9              ; 2BF0  C2 F9 2B
        LD A,E                      ; 2BF3  7B
        CP 3FH                      ; 2BF4  FE 3F
        JP C,LOC_2BCE               ; 2BF6  DA CE 2B
LOC_2BF9:
        LD HL,2B37H                 ; 2BF9  21 37 2B
LOC_2BFC:
        LD A,B                      ; 2BFC  78
        OR A                        ; 2BFD  B7
        JP M,LOC_2BBE               ; 2BFE  FA BE 2B
        JP NZ,LOC_2C19              ; 2C01  C2 19 2C
        LD A,(HL)                   ; 2C04  7E
        SUB 08H                     ; 2C05  D6 08
        JP C,LOC_2BCE               ; 2C07  DA CE 2B
        LD (HL),A                   ; 2C0A  77
        LD A,C                      ; 2C0B  79
        OR D                        ; 2C0C  B2
        OR E                        ; 2C0D  B3
        JP Z,LOC_2BCE               ; 2C0E  CA CE 2B
        LD B,C                      ; 2C11  41
        LD C,D                      ; 2C12  4A
        LD D,E                      ; 2C13  53
        LD E,00H                    ; 2C14  1E 00
        JP LOC_2BFC                 ; 2C16  C3 FC 2B
LOC_2C19:
        DEC (HL)                    ; 2C19  35
        JP C,LOC_2BCE               ; 2C1A  DA CE 2B
        SLA E                       ; 2C1D  CB 23
        RL D                        ; 2C1F  CB 12
        RL C                        ; 2C21  CB 11
        RL B                        ; 2C23  CB 10
        JP P,LOC_2C19               ; 2C25  F2 19 2C
        JP LOC_2BBE                 ; 2C28  C3 BE 2B
SUB_2C2B:
        LD HL,2B36H                 ; 2C2B  21 36 2B
        LD A,(HL)                   ; 2C2E  7E
        ADD A,80H                   ; 2C2F  C6 80
        LD (HL),A                   ; 2C31  77
        LD A,E                      ; 2C32  7B
        CPL                         ; 2C33  2F
        ADD A,01H                   ; 2C34  C6 01
        LD E,A                      ; 2C36  5F
        LD A,D                      ; 2C37  7A
        CPL                         ; 2C38  2F
        ADC A,00H                   ; 2C39  CE 00
        LD D,A                      ; 2C3B  57
        LD A,C                      ; 2C3C  79
        CPL                         ; 2C3D  2F
        ADC A,00H                   ; 2C3E  CE 00
        LD C,A                      ; 2C40  4F
        LD A,B                      ; 2C41  78
        CPL                         ; 2C42  2F
        ADC A,00H                   ; 2C43  CE 00
        LD B,A                      ; 2C45  47
        RET                         ; 2C46  C9
; --- SUB_2C47: called from 4 places ---
SUB_2C47:
        PUSH DE                     ; 2C47  D5
        LD A,(DE)                   ; 2C48  1A
        XOR (HL)                    ; 2C49  AE
        CPL                         ; 2C4A  2F
        AND 80H                     ; 2C4B  E6 80
        LD (DATA_2B36),A            ; 2C4D  32 36 2B
        LD B,(HL)                   ; 2C50  46
        RES 7,B                     ; 2C51  CB B8
        LD A,(DE)                   ; 2C53  1A
        AND 7FH                     ; 2C54  E6 7F
        ADD A,B                     ; 2C56  80
        JP Z,LOC_2BCE               ; 2C57  CA CE 2B
        DEC A                       ; 2C5A  3D
LOC_2C5B:
        CP 30H                      ; 2C5B  FE 30
        JP C,LOC_2BCE               ; 2C5D  DA CE 2B
        CP E0H                      ; 2C60  FE E0
        JP NC,LOC_2376              ; 2C62  D2 76 23
        LD (DATA_2B37),A            ; 2C65  32 37 2B
        XOR A                       ; 2C68  AF
        LD (DATA_2B35),A            ; 2C69  32 35 2B
        LD BC,0004H                 ; 2C6C  01 04 00
        ADD HL,BC                   ; 2C6F  09
        LD A,(HL)                   ; 2C70  7E
        OR A                        ; 2C71  B7
        JP P,LOC_2BCE               ; 2C72  F2 CE 2B
        PUSH HL                     ; 2C75  E5
        POP IY                      ; 2C76  FD E1
        LD C,B                      ; 2C78  48
        EX DE,HL                    ; 2C79  EB
        INC HL                      ; 2C7A  23
        LD E,(HL)                   ; 2C7B  5E
        INC HL                      ; 2C7C  23
        LD D,(HL)                   ; 2C7D  56
        INC HL                      ; 2C7E  23
        PUSH HL                     ; 2C7F  E5
        LD H,B                      ; 2C80  60
        LD L,B                      ; 2C81  68
        EXX                         ; 2C82  D9
        POP HL                      ; 2C83  E1
        LD E,(HL)                   ; 2C84  5E
        INC HL                      ; 2C85  23
        LD D,(HL)                   ; 2C86  56
        LD HL,0000H                 ; 2C87  21 00 00
        LD A,D                      ; 2C8A  7A
        OR A                        ; 2C8B  B7
        JP P,LOC_2BCE               ; 2C8C  F2 CE 2B
        LD C,04H                    ; 2C8F  0E 04
LOC_2C91:
        LD A,(IY+0H)                ; 2C91  FD 7E 00
        LD B,08H                    ; 2C94  06 08
        OR A                        ; 2C96  B7
        JP Z,LOC_2D12               ; 2C97  CA 12 2D
LOC_2C9A:
        RLA                         ; 2C9A  17
        JP NC,LOC_2CB3              ; 2C9B  D2 B3 2C
        EX AF,AF_                   ; 2C9E  08
        EXX                         ; 2C9F  D9
        LD A,B                      ; 2CA0  78
        ADD A,C                     ; 2CA1  81
        LD C,A                      ; 2CA2  4F
        ADC HL,DE                   ; 2CA3  ED 5A
        EXX                         ; 2CA5  D9
        ADC HL,DE                   ; 2CA6  ED 5A
        JP NC,LOC_2CB2              ; 2CA8  D2 B2 2C
        LD A,(DATA_2B35)            ; 2CAB  3A 35 2B
        INC A                       ; 2CAE  3C
        LD (DATA_2B35),A            ; 2CAF  32 35 2B
LOC_2CB2:
        EX AF,AF_                   ; 2CB2  08
LOC_2CB3:
        SRL D                       ; 2CB3  CB 3A
        RR E                        ; 2CB5  CB 1B
        EXX                         ; 2CB7  D9
        RR D                        ; 2CB8  CB 1A
        RR E                        ; 2CBA  CB 1B
        RR B                        ; 2CBC  CB 18
        EXX                         ; 2CBE  D9
        DJNZ LOC_2C9A               ; 2CBF  10 D9
LOC_2CC1:
        DEC IY                      ; 2CC1  FD 2B
        DEC C                       ; 2CC3  0D
        JP NZ,LOC_2C91              ; 2CC4  C2 91 2C
        LD A,(DATA_2B35)            ; 2CC7  3A 35 2B
        OR A                        ; 2CCA  B7
        JP Z,LOC_2CE5               ; 2CCB  CA E5 2C
        LD B,A                      ; 2CCE  47
        LD A,(DATA_2B37)            ; 2CCF  3A 37 2B
        ADD A,B                     ; 2CD2  80
        LD (DATA_2B37),A            ; 2CD3  32 37 2B
LOC_2CD6:
        SCF                         ; 2CD6  37
        RR H                        ; 2CD7  CB 1C
        RR L                        ; 2CD9  CB 1D
        EXX                         ; 2CDB  D9
        RR H                        ; 2CDC  CB 1C
        RR L                        ; 2CDE  CB 1D
        RR C                        ; 2CE0  CB 19
        EXX                         ; 2CE2  D9
        DJNZ LOC_2CD6               ; 2CE3  10 F1
LOC_2CE5:
        EXX                         ; 2CE5  D9
        LD A,C                      ; 2CE6  79
        OR A                        ; 2CE7  B7
        JP P,LOC_2D0A               ; 2CE8  F2 0A 2D
        LD DE,0001H                 ; 2CEB  11 01 00
        ADD HL,DE                   ; 2CEE  19
        EXX                         ; 2CEF  D9
        LD DE,0000H                 ; 2CF0  11 00 00
        ADC HL,DE                   ; 2CF3  ED 5A
        JP NC,LOC_2D09              ; 2CF5  D2 09 2D
        RR H                        ; 2CF8  CB 1C
        RR L                        ; 2CFA  CB 1D
        EXX                         ; 2CFC  D9
        RR H                        ; 2CFD  CB 1C
        RR L                        ; 2CFF  CB 1D
        EXX                         ; 2D01  D9
        LD A,(DATA_2B37)            ; 2D02  3A 37 2B
        INC A                       ; 2D05  3C
        LD (DATA_2B37),A            ; 2D06  32 37 2B
LOC_2D09:
        EXX                         ; 2D09  D9
LOC_2D0A:
        PUSH HL                     ; 2D0A  E5
        EXX                         ; 2D0B  D9
        LD B,H                      ; 2D0C  44
        LD C,L                      ; 2D0D  4D
        POP DE                      ; 2D0E  D1
        JP LOC_2BF9                 ; 2D0F  C3 F9 2B
LOC_2D12:
        LD A,E                      ; 2D12  7B
        LD E,D                      ; 2D13  5A
        LD D,00H                    ; 2D14  16 00
        EXX                         ; 2D16  D9
        LD B,E                      ; 2D17  43
        LD E,D                      ; 2D18  5A
        LD D,A                      ; 2D19  57
        EXX                         ; 2D1A  D9
        JP LOC_2CC1                 ; 2D1B  C3 C1 2C
; --- SUB_2D1E: called from 8 places ---
SUB_2D1E:
        PUSH DE                     ; 2D1E  D5
        LD A,(DE)                   ; 2D1F  1A
        XOR (HL)                    ; 2D20  AE
        CPL                         ; 2D21  2F
        AND 80H                     ; 2D22  E6 80
        LD (DATA_2B36),A            ; 2D24  32 36 2B
        LD B,(HL)                   ; 2D27  46
        RES 7,B                     ; 2D28  CB B8
        LD A,(DE)                   ; 2D2A  1A
        AND 7FH                     ; 2D2B  E6 7F
        SUB B                       ; 2D2D  90
        ADD A,81H                   ; 2D2E  C6 81
LOC_2D30:
        CP 30H                      ; 2D30  FE 30
        JP C,LOC_2BCE               ; 2D32  DA CE 2B
        CP E0H                      ; 2D35  FE E0
        JP NC,LOC_2376              ; 2D37  D2 76 23
        LD (DATA_2B37),A            ; 2D3A  32 37 2B
        INC HL                      ; 2D3D  23
        INC DE                      ; 2D3E  13
        EX DE,HL                    ; 2D3F  EB
        LD C,(HL)                   ; 2D40  4E
        INC HL                      ; 2D41  23
        LD B,(HL)                   ; 2D42  46
        INC HL                      ; 2D43  23
        PUSH HL                     ; 2D44  E5
        EX DE,HL                    ; 2D45  EB
        LD E,(HL)                   ; 2D46  5E
        INC HL                      ; 2D47  23
        LD D,(HL)                   ; 2D48  56
        INC HL                      ; 2D49  23
        LD A,L                      ; 2D4A  7D
        EX AF,AF_                   ; 2D4B  08
        LD A,H                      ; 2D4C  7C
        LD H,B                      ; 2D4D  60
        LD L,C                      ; 2D4E  69
        EXX                         ; 2D4F  D9
        POP HL                      ; 2D50  E1
        LD C,(HL)                   ; 2D51  4E
        INC HL                      ; 2D52  23
        LD B,(HL)                   ; 2D53  46
        LD H,A                      ; 2D54  67
        EX AF,AF_                   ; 2D55  08
        LD L,A                      ; 2D56  6F
        LD E,(HL)                   ; 2D57  5E
        INC HL                      ; 2D58  23
        LD D,(HL)                   ; 2D59  56
        LD H,B                      ; 2D5A  60
        LD L,C                      ; 2D5B  69
        LD A,D                      ; 2D5C  7A
        OR A                        ; 2D5D  B7
        JP P,LOC_2376               ; 2D5E  F2 76 23
        LD C,04H                    ; 2D61  0E 04
LOC_2D63:
        LD B,08H                    ; 2D63  06 08
LOC_2D65:
        BIT 7,H                     ; 2D65  CB 7C
        JP NZ,LOC_2D83              ; 2D67  C2 83 2D
        OR A                        ; 2D6A  B7
LOC_2D6B:
        RLA                         ; 2D6B  17
        EXX                         ; 2D6C  D9
        ADD HL,HL                   ; 2D6D  29
        EXX                         ; 2D6E  D9
        ADC HL,HL                   ; 2D6F  ED 6A
        DJNZ LOC_2D65               ; 2D71  10 F2
        PUSH AF                     ; 2D73  F5
        DEC C                       ; 2D74  0D
        JP NZ,LOC_2D63              ; 2D75  C2 63 2D
LOC_2D78:
        POP AF                      ; 2D78  F1
        LD E,A                      ; 2D79  5F
        POP AF                      ; 2D7A  F1
        LD D,A                      ; 2D7B  57
        POP AF                      ; 2D7C  F1
        LD C,A                      ; 2D7D  4F
        POP AF                      ; 2D7E  F1
        LD B,A                      ; 2D7F  47
        JP LOC_2BF9                 ; 2D80  C3 F9 2B
LOC_2D83:
        EXX                         ; 2D83  D9
        OR A                        ; 2D84  B7
        SBC HL,DE                   ; 2D85  ED 52
        EXX                         ; 2D87  D9
        SBC HL,DE                   ; 2D88  ED 52
        CCF                         ; 2D8A  3F
        JP C,LOC_2D6B               ; 2D8B  DA 6B 2D
        EXX                         ; 2D8E  D9
        ADD HL,DE                   ; 2D8F  19
        EXX                         ; 2D90  D9
        ADC HL,DE                   ; 2D91  ED 5A
        OR A                        ; 2D93  B7
        RLA                         ; 2D94  17
        EXX                         ; 2D95  D9
        ADD HL,HL                   ; 2D96  29
        EXX                         ; 2D97  D9
        ADC HL,HL                   ; 2D98  ED 6A
        DEC B                       ; 2D9A  05
        JP NZ,LOC_2DA5              ; 2D9B  C2 A5 2D
        PUSH AF                     ; 2D9E  F5
        LD B,08H                    ; 2D9F  06 08
        DEC C                       ; 2DA1  0D
        JP Z,LOC_2D78               ; 2DA2  CA 78 2D
LOC_2DA5:
        EXX                         ; 2DA5  D9
        OR A                        ; 2DA6  B7
        SBC HL,DE                   ; 2DA7  ED 52
        EXX                         ; 2DA9  D9
        SBC HL,DE                   ; 2DAA  ED 52
        SCF                         ; 2DAC  37
        RLA                         ; 2DAD  17
        DEC B                       ; 2DAE  05
        JP NZ,LOC_2DB9              ; 2DAF  C2 B9 2D
        PUSH AF                     ; 2DB2  F5
        LD B,08H                    ; 2DB3  06 08
        DEC C                       ; 2DB5  0D
        JP Z,LOC_2D78               ; 2DB6  CA 78 2D
LOC_2DB9:
        EXX                         ; 2DB9  D9
        ADD HL,HL                   ; 2DBA  29
        EXX                         ; 2DBB  D9
        ADC HL,HL                   ; 2DBC  ED 6A
        JP NC,LOC_2D65              ; 2DBE  D2 65 2D
        JP LOC_2DA5                 ; 2DC1  C3 A5 2D
DATA_2DC4:
        DEC E                       ; 2DC4  1D
DATA_2DC5:
        LD L,B                      ; 2DC5  68
        LD H,L                      ; 2DC6  65
LOC_2DC7:
        LD A,(HL)                   ; 2DC7  7E
        PUSH HL                     ; 2DC8  E5
        POP IX                      ; 2DC9  DD E1
        EX DE,HL                    ; 2DCB  EB
        LD (DATA_2DC5),HL           ; 2DCC  22 C5 2D
        EX AF,AF_                   ; 2DCF  08
        XOR A                       ; 2DD0  AF
        LD (DATA_2DC4),A            ; 2DD1  32 C4 2D
        LD H,A                      ; 2DD4  67
        LD L,A                      ; 2DD5  6F
        EXX                         ; 2DD6  D9
        LD H,A                      ; 2DD7  67
        LD L,A                      ; 2DD8  6F
        LD B,A                      ; 2DD9  47
        LD C,A                      ; 2DDA  4F
        EX AF,AF_                   ; 2DDB  08
        CP 2EH                      ; 2DDC  FE 2E
        JP Z,LOC_2DF6               ; 2DDE  CA F6 2D
        JR LOC_2DE9                 ; 2DE1  18 06
LOC_2DE3:
        CALL SUB_2ED1               ; 2DE3  CD D1 2E
        CALL SUB_2EC7               ; 2DE6  CD C7 2E
LOC_2DE9:
        SUB 30H                     ; 2DE9  D6 30
        CP 0AH                      ; 2DEB  FE 0A
        JR C,LOC_2DE3               ; 2DED  38 F4
        ADD A,30H                   ; 2DEF  C6 30
        CP 2EH                      ; 2DF1  FE 2E
        JP NZ,LOC_2E07              ; 2DF3  C2 07 2E
LOC_2DF6:
        CALL SUB_2EC7               ; 2DF6  CD C7 2E
        SUB 30H                     ; 2DF9  D6 30
        CP 0AH                      ; 2DFB  FE 0A
        JP NC,LOC_2E05              ; 2DFD  D2 05 2E
        CALL SUB_2EE0               ; 2E00  CD E0 2E
        JR LOC_2DF6                 ; 2E03  18 F1
LOC_2E05:
        ADD A,30H                   ; 2E05  C6 30
LOC_2E07:
        CP 45H                      ; 2E07  FE 45
        JP NZ,LOC_2E52              ; 2E09  C2 52 2E
        EXX                         ; 2E0C  D9
        CALL SUB_2EC7               ; 2E0D  CD C7 2E
        LD B,01H                    ; 2E10  06 01
        CP BCH                      ; 2E12  FE BC
        JR Z,LOC_2E1C               ; 2E14  28 06
        CP BDH                      ; 2E16  FE BD
        JP NZ,LOC_2372              ; 2E18  C2 72 23
        DEC B                       ; 2E1B  05
LOC_2E1C:
        LD A,B                      ; 2E1C  78
        OR A                        ; 2E1D  B7
        EX AF,AF_                   ; 2E1E  08
LOC_2E1F:
        CALL SUB_1923               ; 2E1F  CD 23 19
        SUB 30H                     ; 2E22  D6 30
        JR Z,LOC_2E1F               ; 2E24  28 F9
        CP 0AH                      ; 2E26  FE 0A
        JP NC,LOC_2E48              ; 2E28  D2 48 2E
        LD B,A                      ; 2E2B  47
        CALL SUB_2EC7               ; 2E2C  CD C7 2E
        SUB 30H                     ; 2E2F  D6 30
        CP 0AH                      ; 2E31  FE 0A
        JP NC,LOC_2E48              ; 2E33  D2 48 2E
        LD C,A                      ; 2E36  4F
        CALL SUB_2EC7               ; 2E37  CD C7 2E
        SUB 30H                     ; 2E3A  D6 30
        CP 0AH                      ; 2E3C  FE 0A
        JP C,LOC_2376               ; 2E3E  DA 76 23
        LD A,B                      ; 2E41  78
        ADD A,A                     ; 2E42  87
        ADD A,A                     ; 2E43  87
        ADD A,B                     ; 2E44  80
        ADD A,A                     ; 2E45  87
        ADD A,C                     ; 2E46  81
        LD B,A                      ; 2E47  47
LOC_2E48:
        EX AF,AF_                   ; 2E48  08
        LD A,B                      ; 2E49  78
        JR NZ,LOC_2E4E              ; 2E4A  20 02
        CPL                         ; 2E4C  2F
        INC A                       ; 2E4D  3C
LOC_2E4E:
        LD (DATA_2DC4),A            ; 2E4E  32 C4 2D
        EXX                         ; 2E51  D9
LOC_2E52:
        PUSH IX                     ; 2E52  DD E5
        LD A,(DATA_2DC4)            ; 2E54  3A C4 2D
        ADD A,1DH                   ; 2E57  C6 1D
        ADD A,C                     ; 2E59  81
        LD (DATA_2DC4),A            ; 2E5A  32 C4 2D
        CP 30H                      ; 2E5D  FE 30
        JP C,LOC_2E6A               ; 2E5F  DA 6A 2E
        CP 80H                      ; 2E62  FE 80
        JP C,LOC_2376               ; 2E64  DA 76 23
        JP LOC_2EBC                 ; 2E67  C3 BC 2E
LOC_2E6A:
        LD A,80H                    ; 2E6A  3E 80
        LD (DATA_2B36),A            ; 2E6C  32 36 2B
        LD A,A0H                    ; 2E6F  3E A0
        LD (DATA_2B37),A            ; 2E71  32 37 2B
        PUSH HL                     ; 2E74  E5
        EXX                         ; 2E75  D9
        POP BC                      ; 2E76  C1
        LD D,H                      ; 2E77  54
        LD E,L                      ; 2E78  5D
        LD HL,2E84H                 ; 2E79  21 84 2E
        PUSH HL                     ; 2E7C  E5
        LD HL,(DATA_2DC5)           ; 2E7D  2A C5 2D
        PUSH HL                     ; 2E80  E5
        JP LOC_2BF9                 ; 2E81  C3 F9 2B
        LD A,(DATA_2DC4)            ; 2E84  3A C4 2D
        LD L,A                      ; 2E87  6F
        LD C,A                      ; 2E88  4F
        LD H,00H                    ; 2E89  26 00
        LD B,H                      ; 2E8B  44
        ADD HL,HL                   ; 2E8C  29
        ADD HL,HL                   ; 2E8D  29
        ADD HL,BC                   ; 2E8E  09
        LD BC,2F0EH                 ; 2E8F  01 0E 2F
        ADD HL,BC                   ; 2E92  09
        LD DE,(DATA_2DC5)           ; 2E93  ED 5B C5 2D
        LD A,80H                    ; 2E97  3E 80
        LD (DATA_2B36),A            ; 2E99  32 36 2B
        LD A,20H                    ; 2E9C  3E 20
        ADD A,(HL)                  ; 2E9E  86
        LD B,A                      ; 2E9F  47
        LD A,(DE)                   ; 2EA0  1A
        AND 7FH                     ; 2EA1  E6 7F
        ADD A,B                     ; 2EA3  80
        JP C,LOC_2376               ; 2EA4  DA 76 23
        SUB 21H                     ; 2EA7  D6 21
        JR NC,LOC_2EAC              ; 2EA9  30 01
        XOR A                       ; 2EAB  AF
LOC_2EAC:
        LD BC,2EB4H                 ; 2EAC  01 B4 2E
        PUSH BC                     ; 2EAF  C5
        PUSH DE                     ; 2EB0  D5
        JP LOC_2C5B                 ; 2EB1  C3 5B 2C
        POP HL                      ; 2EB4  E1
        LD BC,0005H                 ; 2EB5  01 05 00
        LD D,B                      ; 2EB8  50
        LD E,B                      ; 2EB9  58
        LD A,(HL)                   ; 2EBA  7E
        RET                         ; 2EBB  C9
LOC_2EBC:
        LD HL,2EB4H                 ; 2EBC  21 B4 2E
        PUSH HL                     ; 2EBF  E5
        LD HL,(DATA_2DC5)           ; 2EC0  2A C5 2D
        PUSH HL                     ; 2EC3  E5
        JP LOC_2BCE                 ; 2EC4  C3 CE 2B
; --- SUB_2EC7: called from 5 places ---
SUB_2EC7:
        INC IX                      ; 2EC7  DD 23
        LD A,(IX+0H)                ; 2EC9  DD 7E 00
        CP 20H                      ; 2ECC  FE 20
        RET NZ                      ; 2ECE  C0
        JR SUB_2EC7                 ; 2ECF  18 F6
SUB_2ED1:
        OR A                        ; 2ED1  B7
        JR NZ,LOC_2ED7              ; 2ED2  20 03
        OR B                        ; 2ED4  B0
        RET Z                       ; 2ED5  C8
        XOR A                       ; 2ED6  AF
LOC_2ED7:
        EX AF,AF_                   ; 2ED7  08
        LD A,B                      ; 2ED8  78
        CP 09H                      ; 2ED9  FE 09
        JP NZ,LOC_2EEE              ; 2EDB  C2 EE 2E
        INC C                       ; 2EDE  0C
        RET                         ; 2EDF  C9
SUB_2EE0:
        OR A                        ; 2EE0  B7
        JR NZ,LOC_2EE8              ; 2EE1  20 05
        DEC C                       ; 2EE3  0D
        OR B                        ; 2EE4  B0
        RET Z                       ; 2EE5  C8
        INC C                       ; 2EE6  0C
        XOR A                       ; 2EE7  AF
LOC_2EE8:
        EX AF,AF_                   ; 2EE8  08
        LD A,B                      ; 2EE9  78
        CP 09H                      ; 2EEA  FE 09
        RET Z                       ; 2EEC  C8
        DEC C                       ; 2EED  0D
LOC_2EEE:
        INC B                       ; 2EEE  04
        LD D,H                      ; 2EEF  54
        LD E,L                      ; 2EF0  5D
        EXX                         ; 2EF1  D9
        LD D,H                      ; 2EF2  54
        LD E,L                      ; 2EF3  5D
        XOR A                       ; 2EF4  AF
        ADD HL,HL                   ; 2EF5  29
        RLA                         ; 2EF6  17
        ADD HL,HL                   ; 2EF7  29
        RLA                         ; 2EF8  17
        ADD HL,DE                   ; 2EF9  19
        LD D,00H                    ; 2EFA  16 00
        ADC A,D                     ; 2EFC  8A
        ADD HL,HL                   ; 2EFD  29
        RLA                         ; 2EFE  17
        EX AF,AF_                   ; 2EFF  08
        LD E,A                      ; 2F00  5F
        EX AF,AF_                   ; 2F01  08
        ADD HL,DE                   ; 2F02  19
        ADC A,D                     ; 2F03  8A
        EXX                         ; 2F04  D9
        ADD HL,HL                   ; 2F05  29
        ADD HL,HL                   ; 2F06  29
        ADD HL,DE                   ; 2F07  19
        ADD HL,HL                   ; 2F08  29
        LD D,00H                    ; 2F09  16 00
        LD E,A                      ; 2F0B  5F
        ADD HL,DE                   ; 2F0C  19
        RET                         ; 2F0D  C9
        RET PO                      ; 2F0E  E0
        PUSH AF                     ; 2F0F  F5
        RST 30H                     ; 2F10  F7
        JP NC,WS_E3CA               ; 2F11  D2 CA E3
        DI                          ; 2F14  F3
        OR L                        ; 2F15  B5
        ADD A,A                     ; 2F16  87
        RST 20H                     ; 2F17  FD E7
        CP B                        ; 2F19  B8
        POP DE                      ; 2F1A  D1
        LD (HL),H                   ; 2F1B  74
        SBC A,(HL)                  ; 2F1C  9E
        JP PE,MON_0625              ; 2F1D  EA 25 06
        LD (DE),A                   ; 2F20  12
        ADD A,EDH                   ; 2F21  C6 ED
        XOR A                       ; 2F23  AF
        ADD A,A                     ; 2F24  87
        SUB (HL)                    ; 2F25  96
        RST 30H                     ; 2F26  F7
        POP AF                      ; 2F27  F1
        CALL WS_BE14                ; 2F28  CD 14 BE
        SBC A,D                     ; 2F2B  9A
        CALL P,WS_9A01              ; 2F2C  F4 01 9A
        LD L,L                      ; 2F2F  6D
        POP BC                      ; 2F30  C1
        RST 30H                     ; 2F31  F7
        ADD A,C                     ; 2F32  81
        NOP                         ; 2F33  00
        RET                         ; 2F34  C9
        POP AF                      ; 2F35  F1
        EI                          ; 2F36  FB
        LD D,B                      ; 2F37  50
        AND B                       ; 2F38  A0
        DEC E                       ; 2F39  1D
        SUB A                       ; 2F3A  97
        CP 65H                      ; 2F3B  FE 65
        EX AF,AF_                   ; 2F3D  08
        PUSH HL                     ; 2F3E  E5
        CP H                        ; 2F3F  BC
        LD BC,4A7EH                 ; 2F40  01 7E 4A
        LD E,ECH                    ; 2F43  1E EC
        DEC B                       ; 2F45  05
        ADC A,A                     ; 2F46  8F
        XOR 92H                     ; 2F47  EE 92
        SUB E                       ; 2F49  93
        EX AF,AF_                   ; 2F4A  08
        LD (WS_77AA),A              ; 2F4B  32 AA 77
        CP B                        ; 2F4E  B8
        DEC BC                      ; 2F4F  0B
        CP A                        ; 2F50  BF
        SUB H                       ; 2F51  94
        SUB L                       ; 2F52  95
        AND 0FH                     ; 2F53  E6 0F
        RST 30H                     ; 2F55  F7
        LD A,H                      ; 2F56  7C
        DEC E                       ; 2F57  1D
        SUB B                       ; 2F58  90
        LD (DE),A                   ; 2F59  12
        DEC (HL)                    ; 2F5A  35
        CALL C,WS_B424              ; 2F5B  DC 24 B4
        DEC D                       ; 2F5E  15
        LD B,D                      ; 2F5F  42
        INC DE                      ; 2F60  13
        LD L,E1H                    ; 2F61  2E E1
        ADD HL,DE                   ; 2F63  19
        ADD HL,BC                   ; 2F64  09
        CALL Z,WS_8CBC              ; 2F65  CC BC 8C
        INC E                       ; 2F68  1C
        INC C                       ; 2F69  0C
        RST 38H                     ; 2F6A  FF
        EX DE,HL                    ; 2F6B  EB
        XOR A                       ; 2F6C  AF
        RRA                         ; 2F6D  1F
        RST 08H                     ; 2F6E  CF
        CP E6H                      ; 2F6F  FE E6
        IN A,(23H)                  ; 2F71  DB 23
        LD B,C                      ; 2F73  41
        LD E,A                      ; 2F74  5F
        LD (HL),B                   ; 2F75  70
        ADC A,C                     ; 2F76  89
        LD H,12H                    ; 2F77  26 12
        LD (HL),A                   ; 2F79  77
        CALL Z,SUB_29AB             ; 2F7A  CC AB 29
        SUB 94H                     ; 2F7D  D6 94
        CP A                        ; 2F7F  BF
        SUB 2DH                     ; 2F80  D6 2D
        DB 06H                      ; 2F82  06   (stray byte(s): disassembly boundary correction)
LOC_2F83:
        CP L                        ; 2F83  BD
        SCF                         ; 2F84  37
        ADD A,(HL)                  ; 2F85  86
        DB 30H                      ; 2F86  30   (stray byte(s): disassembly boundary correction)
LOC_2F87:
        LD B,A                      ; 2F87  47
        XOR H                       ; 2F88  AC
        PUSH BC                     ; 2F89  C5
        AND A                       ; 2F8A  A7
        INC SP                      ; 2F8B  33
        LD E,C                      ; 2F8C  59
        RLA                         ; 2F8D  17
        OR A                        ; 2F8E  B7
        POP DE                      ; 2F8F  D1
        SCF                         ; 2F90  37
        SBC A,B                     ; 2F91  98
        LD L,(HL)                   ; 2F92  6E
        LD (DE),A                   ; 2F93  12
        ADD A,E                     ; 2F94  83
        LD A,(MON_0A3D)             ; 2F95  3A 3D 0A
        RST 10H                     ; 2F98  D7
        AND E                       ; 2F99  A3
        DEC A                       ; 2F9A  3D
        CALL WS_CCCC                ; 2F9B  CD CC CC
        CALL Z,XTEMP                ; 2F9E  CC 41 00
        NOP                         ; 2FA1  00
        NOP                         ; 2FA2  00
        ADD A,B                     ; 2FA3  80
        LD B,H                      ; 2FA4  44
        NOP                         ; 2FA5  00
        NOP                         ; 2FA6  00
        NOP                         ; 2FA7  00
        AND B                       ; 2FA8  A0
        LD B,A                      ; 2FA9  47
        NOP                         ; 2FAA  00
        NOP                         ; 2FAB  00
        NOP                         ; 2FAC  00
        RET Z                       ; 2FAD  C8
        LD C,D                      ; 2FAE  4A
        NOP                         ; 2FAF  00
        NOP                         ; 2FB0  00
        NOP                         ; 2FB1  00
        JP M,MON_004E               ; 2FB2  FA 4E 00
        NOP                         ; 2FB5  00
        LD B,B                      ; 2FB6  40
        SBC A,H                     ; 2FB7  9C
        LD D,C                      ; 2FB8  51
        NOP                         ; 2FB9  00
        NOP                         ; 2FBA  00
        LD D,B                      ; 2FBB  50
        JP MON_0054                 ; 2FBC  C3 54 00
        NOP                         ; 2FBF  00
        INC H                       ; 2FC0  24
        CALL P,MON_0058             ; 2FC1  F4 58 00
        ADD A,B                     ; 2FC4  80
        SUB (HL)                    ; 2FC5  96
        SBC A,B                     ; 2FC6  98
        LD E,E                      ; 2FC7  5B
        NOP                         ; 2FC8  00
        JR NZ,LOC_2F87              ; 2FC9  20 BC
        CP (HL)                     ; 2FCB  BE
        LD E,(HL)                   ; 2FCC  5E
        NOP                         ; 2FCD  00
        DB 28H                      ; 2FCE  28   (stray byte(s): disassembly boundary correction)
LOC_2FCF:
        LD L,E                      ; 2FCF  6B
        XOR 62H                     ; 2FD0  EE 62
        NOP                         ; 2FD2  00
        LD SP,HL                    ; 2FD3  F9
        LD (BC),A                   ; 2FD4  02
        SUB L                       ; 2FD5  95
        LD H,L                      ; 2FD6  65
        LD B,B                      ; 2FD7  40
        OR A                        ; 2FD8  B7
        LD B,E                      ; 2FD9  43
LOC_2FDA:
        CP D                        ; 2FDA  BA
        LD L,B                      ; 2FDB  68
        DJNZ LOC_2F83               ; 2FDC  10 A5
        CALL NC,WS_6CE8             ; 2FDE  D4 E8 6C
        LD HL,(WS_84E7)             ; 2FE1  2A E7 84
        SUB C                       ; 2FE4  91
        LD L,A                      ; 2FE5  6F
        PUSH AF                     ; 2FE6  F5
        JR NZ,LOC_2FCF              ; 2FE7  20 E6
        OR L                        ; 2FE9  B5
        LD (HL),D                   ; 2FEA  72
        LD (5FA9H),A                ; 2FEB  32 A9 5F
        EX (SP),HL                  ; 2FEE  E3
        HALT                        ; 2FEF  76
        CP A                        ; 2FF0  BF
        RET                         ; 2FF1  C9
        DEC DE                      ; 2FF2  1B
        ADC A,(HL)                  ; 2FF3  8E
        LD A,C                      ; 2FF4  79
        CPL                         ; 2FF5  2F
        CP H                        ; 2FF6  BC
        AND D                       ; 2FF7  A2
        OR C                        ; 2FF8  B1
        LD A,H                      ; 2FF9  7C
        LD A,(MON_0B6B)             ; 2FFA  3A 6B 0B
        SBC A,80H                   ; 2FFD  DE 80
        DEC B                       ; 2FFF  05
        INC HL                      ; 3000  23
        RST 00H                     ; 3001  C7
        ADC A,D                     ; 3002  8A
DATA_3003:
        LD H,E                      ; 3003  63
        LD H,L                      ; 3004  65
DATA_3005:
        NONI                        ; 3005  ED 20
        LD L,00H                    ; 3007  2E 00
        NOP                         ; 3009  00
        NOP                         ; 300A  00
        NOP                         ; 300B  00
        NOP                         ; 300C  00
        NOP                         ; 300D  00
        NOP                         ; 300E  00
        NOP                         ; 300F  00
        NOP                         ; 3010  00
        CALL M,WS_9DF9              ; 3011  FC F9 9D
        DI                          ; 3014  F3
        RST 18H                     ; 3015  DF
        DI                          ; 3016  F3
        RST 38H                     ; 3017  FF
        POP AF                      ; 3018  F1
        DEC A                       ; 3019  3D
        JP M,WS_CDD5                ; 301A  FA D5 CD   <-- UNRESOLVED ALIGNMENT: also targeted as 301BH
        INC B                       ; 301D  04
        LD SP,053AH                 ; 301E  31 3A 05
        JR NC,LOC_2FDA              ; 3021  30 B7
        JP Z,LOC_30CA               ; 3023  CA CA 30
        JP M,LOC_3030               ; 3026  FA 30 30
        CP 09H                      ; 3029  FE 09
        JP C,LOC_308F               ; 302B  DA 8F 30
        JR LOC_3035                 ; 302E  18 05
LOC_3030:
        CP FFH                      ; 3030  FE FF
        JP NC,LOC_30C4              ; 3032  D2 C4 30
LOC_3035:
        LD A,2EH                    ; 3035  3E 2E
        LD (3007H),A                ; 3037  32 07 30
        DB 21H                      ; 303A  21   (stray byte(s): disassembly boundary correction)
        DJNZ LOC_306D               ; 303B  10 30
        XOR A                       ; 303D  AF
LOC_303E:
        DEC HL                      ; 303E  2B
        CP (HL)                     ; 303F  BE
        JR Z,LOC_303E               ; 3040  28 FC
        LD A,(HL)                   ; 3042  7E
        CP 2EH                      ; 3043  FE 2E
        JP Z,LOC_30F7               ; 3045  CA F7 30
        INC HL                      ; 3048  23
        LD (HL),45H                 ; 3049  36 45
        INC HL                      ; 304B  23
        LD A,(DATA_3005)            ; 304C  3A 05 30
        LD B,2BH                    ; 304F  06 2B
        OR A                        ; 3051  B7
        JP P,LOC_305E               ; 3052  F2 5E 30
        CP EDH                      ; 3055  FE ED
        JP C,LOC_30F7               ; 3057  DA F7 30
        LD B,2DH                    ; 305A  06 2D
        CPL                         ; 305C  2F
        INC A                       ; 305D  3C
LOC_305E:
        LD (HL),B                   ; 305E  70
        INC HL                      ; 305F  23
        LD BC,FF0AH                 ; 3060  01 0A FF
LOC_3063:
        INC B                       ; 3063  04
        SUB C                       ; 3064  91
        JR NC,LOC_3063              ; 3065  30 FC
        ADD A,C                     ; 3067  81
        LD (HL),B                   ; 3068  70
        INC HL                      ; 3069  23
        LD (HL),A                   ; 306A  77
        INC HL                      ; 306B  23
        LD (HL),0DH                 ; 306C  36 0D
LOC_306E:
        LD HL,3006H                 ; 306E  21 06 30
LOC_3071:
        INC HL                      ; 3071  23
        LD A,(HL)                   ; 3072  7E
        CP 0DH                      ; 3073  FE 0D
        JP Z,LOC_3081               ; 3075  CA 81 30
        JP NC,LOC_3071              ; 3078  D2 71 30
        OR 30H                      ; 307B  F6 30
        LD (HL),A                   ; 307D  77
        JP LOC_3071                 ; 307E  C3 71 30
LOC_3081:
        LD DE,3006H                 ; 3081  11 06 30
        XOR A                       ; 3084  AF
        SBC HL,DE                   ; 3085  ED 52
        LD B,H                      ; 3087  44
        LD C,L                      ; 3088  4D
        POP HL                      ; 3089  E1
        EX DE,HL                    ; 308A  EB
        INC BC                      ; 308B  03
        LDIR                        ; 308C  ED B0
        RET                         ; 308E  C9
LOC_308F:
        LD HL,3008H                 ; 308F  21 08 30
        LD DE,3007H                 ; 3092  11 07 30
        LD B,A                      ; 3095  47
        INC B                       ; 3096  04
LOC_3097:
        DEC B                       ; 3097  05
        JP Z,LOC_30A2               ; 3098  CA A2 30
        LD A,(HL)                   ; 309B  7E
        LD (DE),A                   ; 309C  12
        INC HL                      ; 309D  23
        INC DE                      ; 309E  13
        JP LOC_3097                 ; 309F  C3 97 30
LOC_30A2:
        LD A,2EH                    ; 30A2  3E 2E
        LD (DE),A                   ; 30A4  12
        LD HL,3010H                 ; 30A5  21 10 30
LOC_30A8:
        LD (HL),0DH                 ; 30A8  36 0D
        DEC HL                      ; 30AA  2B
        LD A,(HL)                   ; 30AB  7E
        OR A                        ; 30AC  B7
        JR Z,LOC_30A8               ; 30AD  28 F9
        CP 2EH                      ; 30AF  FE 2E
        JP NZ,LOC_30B6              ; 30B1  C2 B6 30
        LD (HL),0DH                 ; 30B4  36 0D
LOC_30B6:
        LD HL,3007H                 ; 30B6  21 07 30
        LD A,(HL)                   ; 30B9  7E
        CP 0DH                      ; 30BA  FE 0D
        JP NZ,LOC_306E              ; 30BC  C2 6E 30
        LD (HL),00H                 ; 30BF  36 00
        JP LOC_306E                 ; 30C1  C3 6E 30
LOC_30C4:
        LD DE,3012H                 ; 30C4  11 12 30
        JP LOC_30CD                 ; 30C7  C3 CD 30
LOC_30CA:
        LD DE,3011H                 ; 30CA  11 11 30
LOC_30CD:
        LD HL,300FH                 ; 30CD  21 0F 30
        LD A,0DH                    ; 30D0  3E 0D
        LD (DE),A                   ; 30D2  12
        PUSH DE                     ; 30D3  D5
        DEC DE                      ; 30D4  1B
        LD BC,0008H                 ; 30D5  01 08 00
        LDDR                        ; 30D8  ED B8
        EX DE,HL                    ; 30DA  EB
        LD A,(DATA_3005)            ; 30DB  3A 05 30
        OR A                        ; 30DE  B7
        JP Z,LOC_30E5               ; 30DF  CA E5 30
        LD (HL),00H                 ; 30E2  36 00
        DEC HL                      ; 30E4  2B
LOC_30E5:
        LD (HL),2EH                 ; 30E5  36 2E
        DEC HL                      ; 30E7  2B
        LD (HL),00H                 ; 30E8  36 00
        POP HL                      ; 30EA  E1
LOC_30EB:
        DEC HL                      ; 30EB  2B
        LD A,(HL)                   ; 30EC  7E
        CP 00H                      ; 30ED  FE 00
        JP NZ,LOC_306E              ; 30EF  C2 6E 30
        LD (HL),0DH                 ; 30F2  36 0D
        JP LOC_30EB                 ; 30F4  C3 EB 30
LOC_30F7:
        LD HL,3101H                 ; 30F7  21 01 31
        LD BC,0003H                 ; 30FA  01 03 00
        POP DE                      ; 30FD  D1
        LDIR                        ; 30FE  ED B0
        RET                         ; 3100  C9
        JR NZ,LOC_3133              ; 3101  20 30
        DEC C                       ; 3103  0D
SUB_3104:
        LD (DATA_3003),HL           ; 3104  22 03 30
        LD A,(HL)                   ; 3107  7E
        LD B,20H                    ; 3108  06 20
LOC_310A:
        OR A                        ; 310A  B7
        JP M,LOC_3110               ; 310B  FA 10 31
        LD B,2DH                    ; 310E  06 2D
LOC_3110:
        AND 7FH                     ; 3110  E6 7F
        LD (HL),A                   ; 3112  77
        LD A,B                      ; 3113  78
        LD (3006H),A                ; 3114  32 06 30
        EX DE,HL                    ; 3117  EB
        LD HL,2F3BH                 ; 3118  21 3B 2F
        LD A,ECH                    ; 311B  3E EC
        EX AF,AF_                   ; 311D  08
LOC_311E:
        EX AF,AF_                   ; 311E  08
        INC A                       ; 311F  3C
        EX AF,AF_                   ; 3120  08
        LD BC,0005H                 ; 3121  01 05 00
        ADD HL,BC                   ; 3124  09
        PUSH HL                     ; 3125  E5
        PUSH DE                     ; 3126  D5
        LD A,(DE)                   ; 3127  1A
        CALL SUB_31E9               ; 3128  CD E9 31
        POP DE                      ; 312B  D1
        POP HL                      ; 312C  E1
        JP NC,LOC_311E              ; 312D  D2 1E 31
        EX AF,AF_                   ; 3130  08
        DB 32H,05H                  ; 3131  32 05   (stray byte(s): disassembly boundary correction)
LOC_3133:
        JR NC,LOC_310A              ; 3133  30 D5
        LD BC,3146H                 ; 3135  01 46 31
        PUSH BC                     ; 3138  C5
        PUSH DE                     ; 3139  D5
        LD A,80H                    ; 313A  3E 80
        LD (DATA_2B36),A            ; 313C  32 36 2B
        LD A,(DE)                   ; 313F  1A
        SUB (HL)                    ; 3140  96
        ADD A,81H                   ; 3141  C6 81
        JP LOC_2D30                 ; 3143  C3 30 2D
        LD HL,3007H                 ; 3146  21 07 30
        LD (HL),00H                 ; 3149  36 00
        INC HL                      ; 314B  23
        EX (SP),HL                  ; 314C  E3
        LD A,(HL)                   ; 314D  7E
        INC HL                      ; 314E  23
        LD E,(HL)                   ; 314F  5E
        INC HL                      ; 3150  23
        LD D,(HL)                   ; 3151  56
        INC HL                      ; 3152  23
        PUSH HL                     ; 3153  E5
        EX DE,HL                    ; 3154  EB
        EXX                         ; 3155  D9
        POP HL                      ; 3156  E1
        LD E,(HL)                   ; 3157  5E
        INC HL                      ; 3158  23
        LD D,(HL)                   ; 3159  56
        EX DE,HL                    ; 315A  EB
        SUB C0H                     ; 315B  D6 C0
        JP NC,LOC_316E              ; 315D  D2 6E 31
LOC_3160:
        SRL H                       ; 3160  CB 3C
        RR L                        ; 3162  CB 1D
        EXX                         ; 3164  D9
        RR H                        ; 3165  CB 1C
        RR L                        ; 3167  CB 1D
        EXX                         ; 3169  D9
        INC A                       ; 316A  3C
        JP NZ,LOC_3160              ; 316B  C2 60 31
LOC_316E:
        POP BC                      ; 316E  C1
        LD A,09H                    ; 316F  3E 09
LOC_3171:
        EX AF,AF_                   ; 3171  08
        XOR A                       ; 3172  AF
        LD D,H                      ; 3173  54
        LD E,L                      ; 3174  5D
        EXX                         ; 3175  D9
        LD D,H                      ; 3176  54
        LD E,L                      ; 3177  5D
        ADD HL,HL                   ; 3178  29
        EXX                         ; 3179  D9
        ADC HL,HL                   ; 317A  ED 6A
        RLA                         ; 317C  17
        EXX                         ; 317D  D9
        ADD HL,HL                   ; 317E  29
        EXX                         ; 317F  D9
        ADC HL,HL                   ; 3180  ED 6A
        RLA                         ; 3182  17
        EXX                         ; 3183  D9
        ADD HL,DE                   ; 3184  19
        EXX                         ; 3185  D9
        ADC HL,DE                   ; 3186  ED 5A
        LD D,00H                    ; 3188  16 00
        ADC A,D                     ; 318A  8A
        EXX                         ; 318B  D9
        ADD HL,HL                   ; 318C  29
        EXX                         ; 318D  D9
        ADC HL,HL                   ; 318E  ED 6A
        RLA                         ; 3190  17
        LD (BC),A                   ; 3191  02
        INC BC                      ; 3192  03
        EX AF,AF_                   ; 3193  08
        DEC A                       ; 3194  3D
        JP NZ,LOC_3171              ; 3195  C2 71 31
LOC_3198:
        LD HL,3010H                 ; 3198  21 10 30
        LD A,(HL)                   ; 319B  7E
        LD (HL),00H                 ; 319C  36 00
        CP 05H                      ; 319E  FE 05
        LD C,00H                    ; 31A0  0E 00
        JP C,LOC_31A6               ; 31A2  DA A6 31
        INC C                       ; 31A5  0C
LOC_31A6:
        LD B,0AH                    ; 31A6  06 0A
LOC_31A8:
        DEC B                       ; 31A8  05
        JP Z,LOC_31BC               ; 31A9  CA BC 31
        DEC HL                      ; 31AC  2B
        LD A,(HL)                   ; 31AD  7E
        ADD A,C                     ; 31AE  81
        LD (HL),A                   ; 31AF  77
        SUB 0AH                     ; 31B0  D6 0A
        LD C,00H                    ; 31B2  0E 00
        JP C,LOC_31A8               ; 31B4  DA A8 31
        INC C                       ; 31B7  0C
        LD (HL),A                   ; 31B8  77
        JP LOC_31A8                 ; 31B9  C3 A8 31
LOC_31BC:
        LD A,(3007H)                ; 31BC  3A 07 30
        OR A                        ; 31BF  B7
        RET Z                       ; 31C0  C8
        LD HL,300FH                 ; 31C1  21 0F 30
        LD DE,3010H                 ; 31C4  11 10 30
        LD BC,0009H                 ; 31C7  01 09 00
        LDDR                        ; 31CA  ED B8
        EX DE,HL                    ; 31CC  EB
        LD (HL),00H                 ; 31CD  36 00
        LD A,(DATA_3005)            ; 31CF  3A 05 30
        INC A                       ; 31D2  3C
        LD (DATA_3005),A            ; 31D3  32 05 30
        JP LOC_3198                 ; 31D6  C3 98 31
; --- SUB_31D9: called from 6 places ---
SUB_31D9:
        LD BC,0005H                 ; 31D9  01 05 00
SUB_31DC:
        LD A,(DE)                   ; 31DC  1A
        OR A                        ; 31DD  B7
        JP M,SUB_31E9               ; 31DE  FA E9 31
        BIT 7,(HL)                  ; 31E1  CB 7E
        JR Z,LOC_31E7               ; 31E3  28 02
        SCF                         ; 31E5  37
        RET                         ; 31E6  C9
LOC_31E7:
        EX DE,HL                    ; 31E7  EB
        LD A,(DE)                   ; 31E8  1A
SUB_31E9:
        CP (HL)                     ; 31E9  BE
        RET NZ                      ; 31EA  C0
        DEC C                       ; 31EB  0D
        ADD HL,BC                   ; 31EC  09
        EX DE,HL                    ; 31ED  EB
        ADD HL,BC                   ; 31EE  09
        EX DE,HL                    ; 31EF  EB
        LD B,03H                    ; 31F0  06 03
LOC_31F2:
        LD A,(DE)                   ; 31F2  1A
        CP (HL)                     ; 31F3  BE
        RET NZ                      ; 31F4  C0
        DEC HL                      ; 31F5  2B
        DEC DE                      ; 31F6  1B
        DJNZ LOC_31F2               ; 31F7  10 F9
        LD A,(DE)                   ; 31F9  1A
        CP (HL)                     ; 31FA  BE
        RET                         ; 31FB  C9
SUB_31FC:
        EX DE,HL                    ; 31FC  EB
        CALL SUB_3104               ; 31FD  CD 04 31
        LD A,(3006H)                ; 3200  3A 06 30
        LD B,80H                    ; 3203  06 80
        CP 20H                      ; 3205  FE 20
        JP Z,LOC_320C               ; 3207  CA 0C 32
        LD B,00H                    ; 320A  06 00
LOC_320C:
        LD A,B                      ; 320C  78
        LD (DATA_2B36),A            ; 320D  32 36 2B
        OR A                        ; 3210  B7
        JP Z,LOC_3295               ; 3211  CA 95 32
        LD A,(DATA_3005)            ; 3214  3A 05 30
        DEC A                       ; 3217  3D
        JP M,LOC_32CD               ; 3218  FA CD 32
        LD HL,3010H                 ; 321B  21 10 30
        LD B,0DH                    ; 321E  06 0D
        LD (HL),B                   ; 3220  70
        SUB 08H                     ; 3221  D6 08
        JR NC,LOC_322B              ; 3223  30 06
LOC_3225:
        LD (HL),B                   ; 3225  70
        DEC HL                      ; 3226  2B
        INC A                       ; 3227  3C
        JR NZ,LOC_3225              ; 3228  20 FB
        DEC A                       ; 322A  3D
LOC_322B:
        INC A                       ; 322B  3C
        LD (DATA_2DC4),A            ; 322C  32 C4 2D
        LD IX,3007H                 ; 322F  DD 21 07 30
        XOR A                       ; 3233  AF
        LD H,A                      ; 3234  67
        LD L,A                      ; 3235  6F
        EXX                         ; 3236  D9
        LD B,A                      ; 3237  47
        LD C,A                      ; 3238  4F
        LD H,A                      ; 3239  67
        LD L,A                      ; 323A  6F
LOC_323B:
        LD A,(IX+0H)                ; 323B  DD 7E 00
        CP 0DH                      ; 323E  FE 0D
        JP Z,LOC_324B               ; 3240  CA 4B 32
        CALL SUB_2ED1               ; 3243  CD D1 2E
        INC IX                      ; 3246  DD 23
        JP LOC_323B                 ; 3248  C3 3B 32
LOC_324B:
        LD A,(DATA_2DC4)            ; 324B  3A C4 2D
        ADD A,1DH                   ; 324E  C6 1D
        ADD A,C                     ; 3250  81
        LD (DATA_2DC4),A            ; 3251  32 C4 2D
        LD A,A0H                    ; 3254  3E A0
        LD (DATA_2B37),A            ; 3256  32 37 2B
        PUSH HL                     ; 3259  E5
        EXX                         ; 325A  D9
        POP BC                      ; 325B  C1
        LD D,H                      ; 325C  54
        LD E,L                      ; 325D  5D
        LD HL,3269H                 ; 325E  21 69 32
        PUSH HL                     ; 3261  E5
        LD HL,(DATA_3003)           ; 3262  2A 03 30
        PUSH HL                     ; 3265  E5
        JP LOC_2BF9                 ; 3266  C3 F9 2B
        LD A,(DATA_2DC4)            ; 3269  3A C4 2D
        LD C,A                      ; 326C  4F
        LD L,A                      ; 326D  6F
        LD H,00H                    ; 326E  26 00
        LD B,H                      ; 3270  44
        ADD HL,HL                   ; 3271  29
        ADD HL,HL                   ; 3272  29
        ADD HL,BC                   ; 3273  09
        LD BC,2F0EH                 ; 3274  01 0E 2F
        ADD HL,BC                   ; 3277  09
        LD DE,(DATA_3003)           ; 3278  ED 5B 03 30
        XOR A                       ; 327C  AF
        LD (DATA_2B35),A            ; 327D  32 35 2B
        LD A,20H                    ; 3280  3E 20
        ADD A,(HL)                  ; 3282  86
        LD B,A                      ; 3283  47
        LD A,(DE)                   ; 3284  1A
        AND 7FH                     ; 3285  E6 7F
        ADD A,B                     ; 3287  80
        JP C,LOC_2376               ; 3288  DA 76 23
        SUB 21H                     ; 328B  D6 21
        JP NC,LOC_3291              ; 328D  D2 91 32
        XOR A                       ; 3290  AF
LOC_3291:
        PUSH DE                     ; 3291  D5
        JP LOC_2C5B                 ; 3292  C3 5B 2C
LOC_3295:
        LD A,(DATA_3005)            ; 3295  3A 05 30
        DEC A                       ; 3298  3D
        JP M,LOC_32D2               ; 3299  FA D2 32
        LD HL,3010H                 ; 329C  21 10 30
        LD BC,0D00H                 ; 329F  01 00 0D
        LD (HL),B                   ; 32A2  70
        SUB 08H                     ; 32A3  D6 08
        JP NC,LOC_32B8              ; 32A5  D2 B8 32
        JP LOC_32B3                 ; 32A8  C3 B3 32
LOC_32AB:
        EX AF,AF_                   ; 32AB  08
        LD A,(HL)                   ; 32AC  7E
        OR A                        ; 32AD  B7
        JR Z,LOC_32B1               ; 32AE  28 01
        INC C                       ; 32B0  0C
LOC_32B1:
        LD (HL),B                   ; 32B1  70
        EX AF,AF_                   ; 32B2  08
LOC_32B3:
        DEC HL                      ; 32B3  2B
        INC A                       ; 32B4  3C
        JR NZ,LOC_32AB              ; 32B5  20 F4
        DEC A                       ; 32B7  3D
LOC_32B8:
        EX AF,AF_                   ; 32B8  08
        LD A,C                      ; 32B9  79
        OR A                        ; 32BA  B7
        JR Z,LOC_32C9               ; 32BB  28 0C
LOC_32BD:
        LD A,(HL)                   ; 32BD  7E
        INC A                       ; 32BE  3C
        LD (HL),A                   ; 32BF  77
        CP 0AH                      ; 32C0  FE 0A
        JR NZ,LOC_32C9              ; 32C2  20 05
        LD (HL),00H                 ; 32C4  36 00
        DEC HL                      ; 32C6  2B
        JR LOC_32BD                 ; 32C7  18 F4
LOC_32C9:
        EX AF,AF_                   ; 32C9  08
        JP LOC_322B                 ; 32CA  C3 2B 32
LOC_32CD:
        LD DE,2767H                 ; 32CD  11 67 27
        JR LOC_32D5                 ; 32D0  18 03
LOC_32D2:
        LD DE,276CH                 ; 32D2  11 6C 27
LOC_32D5:
        LD HL,(DATA_3003)           ; 32D5  2A 03 30
SUB_32D8:
        EX DE,HL                    ; 32D8  EB
; --- SUB_32D9: called from 30 places ---
SUB_32D9:
        LD BC,0005H                 ; 32D9  01 05 00
        LDIR                        ; 32DC  ED B0
        RET                         ; 32DE  C9
        PUSH DE                     ; 32DF  D5
        CALL SUB_31D9               ; 32E0  CD D9 31
        JP Z,LOC_32EB               ; 32E3  CA EB 32
LOC_32E6:
        LD HL,276CH                 ; 32E6  21 6C 27
        JR LOC_32EE                 ; 32E9  18 03
LOC_32EB:
        LD HL,2767H                 ; 32EB  21 67 27
LOC_32EE:
        POP DE                      ; 32EE  D1
        JP SUB_32D9                 ; 32EF  C3 D9 32
        PUSH DE                     ; 32F2  D5
        EX DE,HL                    ; 32F3  EB
        JR LOC_32F7                 ; 32F4  18 01
        PUSH DE                     ; 32F6  D5
LOC_32F7:
        CALL SUB_31D9               ; 32F7  CD D9 31   <-- UNRESOLVED ALIGNMENT: also targeted as 32F8H
        JP C,LOC_32E6               ; 32FA  DA E6 32
        JP LOC_32EB                 ; 32FD  C3 EB 32
        PUSH DE                     ; 3300  D5
        CALL SUB_31D9               ; 3301  CD D9 31
        JP Z,LOC_32E6               ; 3304  CA E6 32
        JP LOC_32EB                 ; 3307  C3 EB 32
        PUSH DE                     ; 330A  D5
        EX DE,HL                    ; 330B  EB
        JR LOC_330F                 ; 330C  18 01
        PUSH DE                     ; 330E  D5
LOC_330F:
        CALL SUB_31D9               ; 330F  CD D9 31
        JP C,LOC_32EB               ; 3312  DA EB 32
        JP LOC_32E6                 ; 3315  C3 E6 32
        CP (HL)                     ; 3318  BE
        DEC (HL)                    ; 3319  35
        JR Z,LOC_32F8               ; 331A  28 DC
        RST 08H                     ; 331C  CF
        PUSH DE                     ; 331D  D5
        EX DE,HL                    ; 331E  EB
        LD A,(HL)                   ; 331F  7E
        LD BC,0004H                 ; 3320  01 04 00
        ADD HL,BC                   ; 3323  09
        XOR (HL)                    ; 3324  AE
        JP M,LOC_334A               ; 3325  FA 4A 33
        LD DE,3318H                 ; 3328  11 18 33
        PUSH DE                     ; 332B  D5
        LD HL,3371H                 ; 332C  21 71 33
        CALL SUB_2C47               ; 332F  CD 47 2C
        POP HL                      ; 3332  E1
        PUSH HL                     ; 3333  E5
        LD A,(HL)                   ; 3334  7E
        INC HL                      ; 3335  23
        LD E,(HL)                   ; 3336  5E
        INC HL                      ; 3337  23
        LD D,(HL)                   ; 3338  56
        INC HL                      ; 3339  23
        LD C,(HL)                   ; 333A  4E
        INC HL                      ; 333B  23
        LD B,(HL)                   ; 333C  46
        CP C1H                      ; 333D  FE C1
        CALL NC,SUB_3359            ; 333F  D4 59 33
        POP HL                      ; 3342  E1
        PUSH HL                     ; 3343  E5
        CALL SUB_2BD2               ; 3344  CD D2 2B
        JP LOC_3354                 ; 3347  C3 54 33
LOC_334A:
        DB 11H,18H                  ; 334A  11 18   (stray byte(s): disassembly boundary correction)
LOC_334C:
        INC SP                      ; 334C  33
        LD HL,336CH                 ; 334D  21 6C 33
        PUSH DE                     ; 3350  D5
        CALL SUB_32D9               ; 3351  CD D9 32
LOC_3354:
        POP HL                      ; 3354  E1
        POP DE                      ; 3355  D1
        JP SUB_32D9                 ; 3356  C3 D9 32
SUB_3359:
        SUB C0H                     ; 3359  D6 C0
LOC_335B:
        SLA E                       ; 335B  CB 23
        RL D                        ; 335D  CB 12
        RL C                        ; 335F  CB 11
        RL B                        ; 3361  CB 10
        DEC A                       ; 3363  3D
        JP NZ,LOC_335B              ; 3364  C2 5B 33
        LD A,C0H                    ; 3367  3E C0
        JP SUB_344F                 ; 3369  C3 4F 34
        CP (HL)                     ; 336C  BE
        DEC (HL)                    ; 336D  35
        JR Z,LOC_334C               ; 336E  28 DC
        RST 08H                     ; 3370  CF
        PUSH BC                     ; 3371  C5
        NOP                         ; 3372  00
        NOP                         ; 3373  00
        NOP                         ; 3374  00
        CP B                        ; 3375  B8
        NOP                         ; 3376  00
        INC E                       ; 3377  1C
        NOP                         ; 3378  00
        INC E                       ; 3379  1C
        LD SP,1014H                 ; 337A  31 14 10
        INC B                       ; 337D  04
        JR NC,SUB_3390              ; 337E  30 10
        JP C,LOC_5A4E               ; 3380  DA 4E 5A
        LD A,A                      ; 3383  7F
        LD (HL),D                   ; 3384  72
        RST 28H                     ; 3385  EF
        JR NZ,LOC_33BE              ; 3386  20 36
        LD H,B                      ; 3388  60
        LD E,(HL)                   ; 3389  5E
; --- SUB_338A: called from 14 places ---
SUB_338A:
        LD DE,3376H                 ; 338A  11 76 33
        JP SUB_2B3B                 ; 338D  C3 3B 2B
; --- SUB_3390: called from 13 places ---
SUB_3390:
        CALL SUB_338A               ; 3390  CD 8A 33
SUB_3393:
        LD HL,337BH                 ; 3393  21 7B 33
; --- SUB_3396: called from 16 places ---
SUB_3396:
        LD DE,3376H                 ; 3396  11 76 33
        JP SUB_2C47                 ; 3399  C3 47 2C
        LD A,D                      ; 339C  7A
        LD E,E                      ; 339D  5B
SUB_339E:
        PUSH DE                     ; 339E  D5
        LD HL,3472H                 ; 339F  21 72 34
        CALL SUB_2D1E               ; 33A2  CD 1E 2D
        POP HL                      ; 33A5  E1
        PUSH HL                     ; 33A6  E5
        LD A,(HL)                   ; 33A7  7E
        LD (339DH),A                ; 33A8  32 9D 33
        OR 80H                      ; 33AB  F6 80
        INC HL                      ; 33AD  23
        LD E,(HL)                   ; 33AE  5E
        INC HL                      ; 33AF  23
        LD D,(HL)                   ; 33B0  56
        INC HL                      ; 33B1  23
        LD C,(HL)                   ; 33B2  4E
        INC HL                      ; 33B3  23
        LD B,(HL)                   ; 33B4  46
        CP C3H                      ; 33B5  FE C3
        JP C,LOC_33CD               ; 33B7  DA CD 33
        SUB C2H                     ; 33BA  D6 C2
LOC_33BC:
        SLA E                       ; 33BC  CB 23
LOC_33BE:
        RL D                        ; 33BE  CB 12
        RL C                        ; 33C0  CB 11
        RL B                        ; 33C2  CB 10
        DEC A                       ; 33C4  3D
        JP NZ,LOC_33BC              ; 33C5  C2 BC 33
        LD A,C2H                    ; 33C8  3E C2
        CALL SUB_344F               ; 33CA  CD 4F 34
LOC_33CD:
        LD HL,8000H                 ; 33CD  21 00 80
        CP C2H                      ; 33D0  FE C2
        JR C,LOC_33DA               ; 33D2  38 06
        LD H,L                      ; 33D4  65
        RES 7,B                     ; 33D5  CB B8
        CALL SUB_344F               ; 33D7  CD 4F 34
LOC_33DA:
        CP C1H                      ; 33DA  FE C1
        JR C,LOC_33E4               ; 33DC  38 06
        INC L                       ; 33DE  2C
        RES 7,B                     ; 33DF  CB B8
        CALL SUB_344F               ; 33E1  CD 4F 34
LOC_33E4:
        EX AF,AF_                   ; 33E4  08
        LD A,(339DH)                ; 33E5  3A 9D 33
        XOR H                       ; 33E8  AC
        CPL                         ; 33E9  2F
        AND 80H                     ; 33EA  E6 80
        LD H,A                      ; 33EC  67
        LD (339CH),HL               ; 33ED  22 9C 33
        EX AF,AF_                   ; 33F0  08
        POP HL                      ; 33F1  E1
        PUSH HL                     ; 33F2  E5
        CALL SUB_2BD2               ; 33F3  CD D2 2B
        LD A,(339CH)                ; 33F6  3A 9C 33
        OR A                        ; 33F9  B7
        JR Z,LOC_3404               ; 33FA  28 08
        POP DE                      ; 33FC  D1
        PUSH DE                     ; 33FD  D5
        LD HL,2762H                 ; 33FE  21 62 27
        CALL SUB_2B38               ; 3401  CD 38 2B
LOC_3404:
        POP HL                      ; 3404  E1
        PUSH HL                     ; 3405  E5
        LD A,(HL)                   ; 3406  7E
        AND 7FH                     ; 3407  E6 7F
        LD B,A                      ; 3409  47
        LD A,(339DH)                ; 340A  3A 9D 33
        OR B                        ; 340D  B0
        LD (HL),A                   ; 340E  77
        LD DE,3376H                 ; 340F  11 76 33
        CALL SUB_32D9               ; 3412  CD D9 32
        LD DE,337BH                 ; 3415  11 7B 33
        LD HL,3376H                 ; 3418  21 76 33
        CALL SUB_32D9               ; 341B  CD D9 32
        CALL SUB_3393               ; 341E  CD 93 33
        LD DE,337BH                 ; 3421  11 7B 33
        LD HL,3376H                 ; 3424  21 76 33
        CALL SUB_32D9               ; 3427  CD D9 32
        LD HL,3477H                 ; 342A  21 77 34
        CALL SUB_3396               ; 342D  CD 96 33
        LD HL,347CH                 ; 3430  21 7C 34
        CALL SUB_3390               ; 3433  CD 90 33
        LD HL,3481H                 ; 3436  21 81 34
        CALL SUB_3390               ; 3439  CD 90 33
        LD HL,3486H                 ; 343C  21 86 34
        CALL SUB_3390               ; 343F  CD 90 33
        LD HL,348BH                 ; 3442  21 8B 34
        CALL SUB_338A               ; 3445  CD 8A 33
        POP DE                      ; 3448  D1
        LD HL,3376H                 ; 3449  21 76 33
        JP SUB_2C47                 ; 344C  C3 47 2C
; --- SUB_344F: called from 6 places ---
SUB_344F:
        BIT 7,B                     ; 344F  CB 78
        RET NZ                      ; 3451  C0
        EX AF,AF_                   ; 3452  08
        LD A,B                      ; 3453  78
        OR C                        ; 3454  B1
        OR E                        ; 3455  B3
        OR D                        ; 3456  B2
        JP Z,SUB_3469               ; 3457  CA 69 34
        EX AF,AF_                   ; 345A  08
LOC_345B:
        BIT 7,B                     ; 345B  CB 78
        RET NZ                      ; 345D  C0
        SLA E                       ; 345E  CB 23
        RL D                        ; 3460  CB 12
        RL C                        ; 3462  CB 11
        RL B                        ; 3464  CB 10
        DEC A                       ; 3466  3D
        JR NZ,LOC_345B              ; 3467  20 F2
SUB_3469:
        LD BC,0000H                 ; 3469  01 00 00
        LD DE,0000H                 ; 346C  11 00 00
        LD A,80H                    ; 346F  3E 80
        RET                         ; 3471  C9
        POP BC                      ; 3472  C1
        AND C                       ; 3473  A1
        JP C,WS_C90F                ; 3474  DA 0F C9
        OR H                        ; 3477  B4
        CALL C,MON_0A0F             ; 3478  DC 0F 0A
        SBC A,A                     ; 347B  9F
        ADD HL,SP                   ; 347C  39
        LD H,C                      ; 347D  61
        ADC A,A                     ; 347E  8F
        ADD HL,HL                   ; 347F  29
        SBC A,C                     ; 3480  99
        CP L                        ; 3481  BD
        RET Z                       ; 3482  C8
        LD (HL),A                   ; 3483  77
        INC (HL)                    ; 3484  34
        AND E                       ; 3485  A3
        LD B,B                      ; 3486  40
        ADD A,L                     ; 3487  85
        POP HL                      ; 3488  E1
        LD E,L                      ; 3489  5D
        AND L                       ; 348A  A5
        POP BC                      ; 348B  C1
        SUB H                       ; 348C  94
        JP C,WS_C90F                ; 348D  DA 0F C9
SUB_3490:
        PUSH DE                     ; 3490  D5
        LD HL,3472H                 ; 3491  21 72 34
        CALL SUB_2B38               ; 3494  CD 38 2B
        POP HL                      ; 3497  E1
        CALL SUB_3933               ; 3498  CD 33 39
        EX DE,HL                    ; 349B  EB
        JP SUB_339E                 ; 349C  C3 9E 33
        PUSH DE                     ; 349F  D5
        EX DE,HL                    ; 34A0  EB
        LD DE,3385H                 ; 34A1  11 85 33
        CALL SUB_32D9               ; 34A4  CD D9 32
        POP DE                      ; 34A7  D1
        PUSH DE                     ; 34A8  D5
        CALL SUB_3490               ; 34A9  CD 90 34
        POP HL                      ; 34AC  E1
        PUSH HL                     ; 34AD  E5
        LD DE,3380H                 ; 34AE  11 80 33
        CALL SUB_32D9               ; 34B1  CD D9 32
        POP DE                      ; 34B4  D1
        PUSH DE                     ; 34B5  D5
        LD HL,3385H                 ; 34B6  21 85 33
        CALL SUB_32D9               ; 34B9  CD D9 32
        POP DE                      ; 34BC  D1
        PUSH DE                     ; 34BD  D5
        CALL SUB_339E               ; 34BE  CD 9E 33
        POP DE                      ; 34C1  D1
        LD HL,3380H                 ; 34C2  21 80 33
        JP SUB_2D1E                 ; 34C5  C3 1E 2D
        NOP                         ; 34C8  00
        RST 38H                     ; 34C9  FF
SUB_34CA:
        LD A,03H                    ; 34CA  3E 03
        LD (34C8H),A                ; 34CC  32 C8 34
        PUSH DE                     ; 34CF  D5
        EX DE,HL                    ; 34D0  EB
        LD A,(HL)                   ; 34D1  7E
        ADD A,80H                   ; 34D2  C6 80
        JP NC,LOC_237A              ; 34D4  D2 7A 23
        JP NZ,LOC_34E7              ; 34D7  C2 E7 34
        EX AF,AF_                   ; 34DA  08
        LD BC,0004H                 ; 34DB  01 04 00
        ADD HL,BC                   ; 34DE  09
        LD A,(HL)                   ; 34DF  7E
        SBC HL,BC                   ; 34E0  ED 42
        OR A                        ; 34E2  B7
        JP P,LOC_354A               ; 34E3  F2 4A 35
        EX AF,AF_                   ; 34E6  08
LOC_34E7:
        BIT 0,A                     ; 34E7  CB 47
        JP NZ,LOC_3566              ; 34E9  C2 66 35
        LD (34C9H),A                ; 34EC  32 C9 34
        LD (HL),C0H                 ; 34EF  36 C0
        LD DE,3376H                 ; 34F1  11 76 33
        CALL SUB_32D9               ; 34F4  CD D9 32
        LD HL,357EH                 ; 34F7  21 7E 35
        CALL SUB_3396               ; 34FA  CD 96 33
        LD HL,3583H                 ; 34FD  21 83 35
LOC_3500:
        CALL SUB_338A               ; 3500  CD 8A 33
LOC_3503:
        LD DE,337BH                 ; 3503  11 7B 33
        POP HL                      ; 3506  E1
        PUSH HL                     ; 3507  E5
        CALL SUB_32D9               ; 3508  CD D9 32
        LD DE,337BH                 ; 350B  11 7B 33
        LD HL,3376H                 ; 350E  21 76 33
        CALL SUB_2D1E               ; 3511  CD 1E 2D
        LD HL,337BH                 ; 3514  21 7B 33
        CALL SUB_338A               ; 3517  CD 8A 33
        LD HL,3376H                 ; 351A  21 76 33
        LD A,(HL)                   ; 351D  7E
        AND 7FH                     ; 351E  E6 7F
        DEC A                       ; 3520  3D
        JP C,LOC_354A               ; 3521  DA 4A 35
        OR 80H                      ; 3524  F6 80
        LD (HL),A                   ; 3526  77
        LD A,(34C8H)                ; 3527  3A C8 34
        DEC A                       ; 352A  3D
        LD (34C8H),A                ; 352B  32 C8 34
        JP NZ,LOC_3503              ; 352E  C2 03 35
        LD A,(34C9H)                ; 3531  3A C9 34
        CP 40H                      ; 3534  FE 40
        CALL NZ,SUB_3551            ; 3536  C4 51 35
        LD B,(HL)                   ; 3539  46
        RES 7,B                     ; 353A  CB B8
        ADD A,B                     ; 353C  80
        SUB 40H                     ; 353D  D6 40
        JP C,LOC_354A               ; 353F  DA 4A 35
        JP M,LOC_2376               ; 3542  FA 76 23
        OR 80H                      ; 3545  F6 80
        LD (HL),A                   ; 3547  77
        JR LOC_354D                 ; 3548  18 03
LOC_354A:
        LD HL,2767H                 ; 354A  21 67 27
LOC_354D:
        POP DE                      ; 354D  D1
        JP SUB_32D9                 ; 354E  C3 D9 32
SUB_3551:
        JP C,LOC_355B               ; 3551  DA 5B 35
        SUB 40H                     ; 3554  D6 40
        SRL A                       ; 3556  CB 3F
        ADD A,40H                   ; 3558  C6 40
        RET                         ; 355A  C9
LOC_355B:
        LD B,A                      ; 355B  47
        LD A,40H                    ; 355C  3E 40
        SUB B                       ; 355E  90
        SRL A                       ; 355F  CB 3F
        LD B,A                      ; 3561  47
        LD A,40H                    ; 3562  3E 40
        SUB B                       ; 3564  90
        RET                         ; 3565  C9
LOC_3566:
        INC A                       ; 3566  3C
        LD (34C9H),A                ; 3567  32 C9 34
        LD (HL),BFH                 ; 356A  36 BF
        LD DE,3376H                 ; 356C  11 76 33
        CALL SUB_32D9               ; 356F  CD D9 32
        LD HL,3588H                 ; 3572  21 88 35
        CALL SUB_3396               ; 3575  CD 96 33
        LD HL,358DH                 ; 3578  21 8D 35
        JP LOC_3500                 ; 357B  C3 00 35
        RET NZ                      ; 357E  C0
        NOP                         ; 357F  00
        NOP                         ; 3580  00
        NOP                         ; 3581  00
        SUB B                       ; 3582  90
        CP A                        ; 3583  BF
        NOP                         ; 3584  00
        NOP                         ; 3585  00
        NOP                         ; 3586  00
        RET PO                      ; 3587  E0
        RET NZ                      ; 3588  C0
        NOP                         ; 3589  00
        NOP                         ; 358A  00
        NOP                         ; 358B  00
        RET PO                      ; 358C  E0
        CP A                        ; 358D  BF
        NOP                         ; 358E  00
        NOP                         ; 358F  00
        NOP                         ; 3590  00
        SUB B                       ; 3591  90
DATA_3592:
        EX AF,AF_                   ; 3592  08
        DB D3H                      ; 3593  D3   (stray byte(s): disassembly boundary correction)
SUB_3594:
        PUSH DE                     ; 3594  D5
        LD A,(DE)                   ; 3595  1A
        AND 80H                     ; 3596  E6 80
        LD (DATA_3592),A            ; 3598  32 92 35
        LD A,(DE)                   ; 359B  1A
        OR 80H                      ; 359C  F6 80
        LD (DE),A                   ; 359E  12
        LD HL,36C5H                 ; 359F  21 C5 36
        CALL SUB_2D1E               ; 35A2  CD 1E 2D
        POP HL                      ; 35A5  E1
        PUSH HL                     ; 35A6  E5
        LD A,40H                    ; 35A7  3E 40
        LD (3593H),A                ; 35A9  32 93 35
        LD A,(HL)                   ; 35AC  7E
        SUB C1H                     ; 35AD  D6 C1
        CALL NC,SUB_364F            ; 35AF  D4 4F 36
        POP DE                      ; 35B2  D1
        PUSH DE                     ; 35B3  D5
        LD HL,36C0H                 ; 35B4  21 C0 36
        CALL SUB_2B38               ; 35B7  CD 38 2B
        POP HL                      ; 35BA  E1
        PUSH HL                     ; 35BB  E5
        LD DE,3376H                 ; 35BC  11 76 33
        CALL SUB_32D9               ; 35BF  CD D9 32
        LD HL,369DH                 ; 35C2  21 9D 36
        CALL SUB_3396               ; 35C5  CD 96 33
        LD HL,36A2H                 ; 35C8  21 A2 36
        CALL SUB_338A               ; 35CB  CD 8A 33
        POP HL                      ; 35CE  E1
        PUSH HL                     ; 35CF  E5
        CALL SUB_3396               ; 35D0  CD 96 33
        LD HL,36A7H                 ; 35D3  21 A7 36
        CALL SUB_338A               ; 35D6  CD 8A 33
        POP HL                      ; 35D9  E1
        PUSH HL                     ; 35DA  E5
        CALL SUB_3396               ; 35DB  CD 96 33
        LD HL,36ACH                 ; 35DE  21 AC 36
        CALL SUB_338A               ; 35E1  CD 8A 33
        POP HL                      ; 35E4  E1
        PUSH HL                     ; 35E5  E5
        CALL SUB_3396               ; 35E6  CD 96 33
        LD HL,36B1H                 ; 35E9  21 B1 36
        CALL SUB_338A               ; 35EC  CD 8A 33
        POP HL                      ; 35EF  E1
        PUSH HL                     ; 35F0  E5
        CALL SUB_3396               ; 35F1  CD 96 33
        LD HL,36B6H                 ; 35F4  21 B6 36
        CALL SUB_338A               ; 35F7  CD 8A 33
        POP HL                      ; 35FA  E1
        PUSH HL                     ; 35FB  E5
        CALL SUB_3396               ; 35FC  CD 96 33
        LD HL,36BBH                 ; 35FF  21 BB 36
        CALL SUB_338A               ; 3602  CD 8A 33
        LD HL,3376H                 ; 3605  21 76 33
        LD B,(HL)                   ; 3608  46
        RES 7,B                     ; 3609  CB B8
        LD A,(3593H)                ; 360B  3A 93 35
        ADD A,B                     ; 360E  80
        JP C,LOC_3693               ; 360F  DA 93 36
        SUB 3FH                     ; 3612  D6 3F
        JP C,LOC_3683               ; 3614  DA 83 36
        JP M,LOC_3693               ; 3617  FA 93 36
        OR 80H                      ; 361A  F6 80
        LD (HL),A                   ; 361C  77
        LD A,(DATA_3592)            ; 361D  3A 92 35
        OR A                        ; 3620  B7
        JP Z,LOC_362B               ; 3621  CA 2B 36
        LD HL,3376H                 ; 3624  21 76 33
        POP DE                      ; 3627  D1
        JP SUB_32D9                 ; 3628  C3 D9 32
LOC_362B:
        POP DE                      ; 362B  D1
        PUSH DE                     ; 362C  D5
        LD HL,2762H                 ; 362D  21 62 27
        CALL SUB_32D9               ; 3630  CD D9 32
        POP DE                      ; 3633  D1
        PUSH DE                     ; 3634  D5
        LD A,(DE)                   ; 3635  1A
        CP FCH                      ; 3636  FE FC
        PUSH AF                     ; 3638  F5
        JP C,LOC_363E               ; 3639  DA 3E 36
        DEC A                       ; 363C  3D
        LD (DE),A                   ; 363D  12
LOC_363E:
        LD HL,3376H                 ; 363E  21 76 33
        CALL SUB_2D1E               ; 3641  CD 1E 2D
        POP AF                      ; 3644  F1
        POP HL                      ; 3645  E1
        RET C                       ; 3646  D8
        LD A,(HL)                   ; 3647  7E
        DEC A                       ; 3648  3D
        LD (HL),A                   ; 3649  77
        RET M                       ; 364A  F8
        PUSH HL                     ; 364B  E5
        JP LOC_2BCE                 ; 364C  C3 CE 2B
SUB_364F:
        INC HL                      ; 364F  23
        LD E,(HL)                   ; 3650  5E
        INC HL                      ; 3651  23
        LD D,(HL)                   ; 3652  56
        INC HL                      ; 3653  23
        LD C,(HL)                   ; 3654  4E
        INC HL                      ; 3655  23
        LD B,(HL)                   ; 3656  46
        PUSH HL                     ; 3657  E5
        INC A                       ; 3658  3C
        LD H,A                      ; 3659  67
        XOR A                       ; 365A  AF
LOC_365B:
        SLA E                       ; 365B  CB 23
        RL D                        ; 365D  CB 12
        RL C                        ; 365F  CB 11
        RL B                        ; 3661  CB 10
        RLA                         ; 3663  17
        JP C,LOC_3691               ; 3664  DA 91 36
        DEC H                       ; 3667  25
        JP NZ,LOC_365B              ; 3668  C2 5B 36
        ADD A,40H                   ; 366B  C6 40
        JP C,LOC_3691               ; 366D  DA 91 36
        LD (3593H),A                ; 3670  32 93 35
        LD A,C0H                    ; 3673  3E C0
        CALL SUB_344F               ; 3675  CD 4F 34
        POP HL                      ; 3678  E1
        LD (HL),B                   ; 3679  70
        DEC HL                      ; 367A  2B
        LD (HL),C                   ; 367B  71
        DEC HL                      ; 367C  2B
        LD (HL),D                   ; 367D  72
        DEC HL                      ; 367E  2B
        LD (HL),E                   ; 367F  73
        DEC HL                      ; 3680  2B
        LD (HL),A                   ; 3681  77
        RET                         ; 3682  C9
LOC_3683:
        LD A,(DATA_3592)            ; 3683  3A 92 35
        OR A                        ; 3686  B7
        JP Z,LOC_2376               ; 3687  CA 76 23
LOC_368A:
        LD HL,2767H                 ; 368A  21 67 27
        POP DE                      ; 368D  D1
        JP SUB_32D9                 ; 368E  C3 D9 32
LOC_3691:
        POP AF                      ; 3691  F1
        POP AF                      ; 3692  F1
LOC_3693:
        LD A,(DATA_3592)            ; 3693  3A 92 35
        OR A                        ; 3696  B7
        JP NZ,LOC_2376              ; 3697  C2 76 23
        JP LOC_368A                 ; 369A  C3 8A 36
        OR E                        ; 369D  B3
        LD A,H                      ; 369E  7C
        ADC A,H                     ; 369F  8C
        SUB B                       ; 36A0  90
        EX (SP),HL                  ; 36A1  E3
        OR (HL)                     ; 36A2  B6
        RRA                         ; 36A3  1F
        RST 18H                     ; 36A4  DF
        LD H,D                      ; 36A5  62
        RET M                       ; 36A6  F8
        CP C                        ; 36A7  B9
        JP PO,WS_DD6D               ; 36A8  E2 6D DD
        SBC A,BCH                   ; 36AB  DE BC
        ADC A,E                     ; 36AD  8B
        INC SP                      ; 36AE  33
        POP BC                      ; 36AF  C1
        AND B                       ; 36B0  A0
        CP (HL)                     ; 36B1  BE
        ADC A,C                     ; 36B2  89
        LD C,D                      ; 36B3  4A
        POP AF                      ; 36B4  F1
        XOR L                       ; 36B5  AD
        CP A                        ; 36B6  BF
        INC (HL)                    ; 36B7  34
        INC SP                      ; 36B8  33
        JP P,WS_C0FA                ; 36B9  F2 FA C0
        LD (HL),F3H                 ; 36BC  36 F3
        INC B                       ; 36BE  04
        OR L                        ; 36BF  B5
        RET NZ                      ; 36C0  C0
        NOP                         ; 36C1  00
        NOP                         ; 36C2  00
        NOP                         ; 36C3  00
        ADD A,B                     ; 36C4  80
        RET NZ                      ; 36C5  C0
        RET M                       ; 36C6  F8
        RLA                         ; 36C7  17
        LD (HL),D                   ; 36C8  72
        OR C                        ; 36C9  B1
        ADD A,C                     ; 36CA  81
        DEC D                       ; 36CB  15
        DB 10H                      ; 36CC  10   (stray byte(s): disassembly boundary correction)
SUB_36CD:
        PUSH DE                     ; 36CD  D5
        LD A,80H                    ; 36CE  3E 80
        LD (36CBH),A                ; 36D0  32 CB 36
        LD (36CAH),A                ; 36D3  32 CA 36
        EX DE,HL                    ; 36D6  EB
        LD A,(HL)                   ; 36D7  7E
        OR A                        ; 36D8  B7
        JP P,LOC_2376               ; 36D9  F2 76 23
        CP 8AH                      ; 36DC  FE 8A
        JP NC,LOC_36EC              ; 36DE  D2 EC 36
        XOR A                       ; 36E1  AF
        LD (36CAH),A                ; 36E2  32 CA 36
        EX DE,HL                    ; 36E5  EB
        CALL SUB_34CA               ; 36E6  CD CA 34
        POP HL                      ; 36E9  E1
        PUSH HL                     ; 36EA  E5
        LD A,(HL)                   ; 36EB  7E
LOC_36EC:
        CP C1H                      ; 36EC  FE C1
        CALL C,SUB_37AD             ; 36EE  DC AD 37
        LD B,00H                    ; 36F1  06 00
        CP C1H                      ; 36F3  FE C1
        JP Z,LOC_36FE               ; 36F5  CA FE 36
        SUB C1H                     ; 36F8  D6 C1
        LD B,A                      ; 36FA  47
        LD A,C1H                    ; 36FB  3E C1
        LD (HL),A                   ; 36FD  77
LOC_36FE:
        LD A,B                      ; 36FE  78
        LD (36CCH),A                ; 36FF  32 CC 36
        LD DE,3376H                 ; 3702  11 76 33
        CALL SUB_32D9               ; 3705  CD D9 32
        POP DE                      ; 3708  D1
        PUSH DE                     ; 3709  D5
        LD HL,37F2H                 ; 370A  21 F2 37
        CALL SUB_2B38               ; 370D  CD 38 2B
        LD HL,37F2H                 ; 3710  21 F2 37
        CALL SUB_338A               ; 3713  CD 8A 33
        POP DE                      ; 3716  D1
        PUSH DE                     ; 3717  D5
        LD HL,3376H                 ; 3718  21 76 33
        CALL SUB_2D1E               ; 371B  CD 1E 2D
        POP DE                      ; 371E  D1
        PUSH DE                     ; 371F  D5
        LD HL,37F7H                 ; 3720  21 F7 37
        CALL SUB_2C47               ; 3723  CD 47 2C
        POP HL                      ; 3726  E1
        PUSH HL                     ; 3727  E5
        LD DE,337BH                 ; 3728  11 7B 33
        CALL SUB_32D9               ; 372B  CD D9 32
        POP HL                      ; 372E  E1
        PUSH HL                     ; 372F  E5
        LD DE,337BH                 ; 3730  11 7B 33
        CALL SUB_2C47               ; 3733  CD 47 2C
        LD DE,3376H                 ; 3736  11 76 33
        LD HL,337BH                 ; 3739  21 7B 33
        CALL SUB_32D9               ; 373C  CD D9 32
        LD HL,37DEH                 ; 373F  21 DE 37
        CALL SUB_3396               ; 3742  CD 96 33
        LD HL,37E3H                 ; 3745  21 E3 37
        CALL SUB_3390               ; 3748  CD 90 33
        LD HL,37E8H                 ; 374B  21 E8 37
        CALL SUB_3390               ; 374E  CD 90 33
        LD HL,37EDH                 ; 3751  21 ED 37
        CALL SUB_338A               ; 3754  CD 8A 33
        POP HL                      ; 3757  E1
        PUSH HL                     ; 3758  E5
        CALL SUB_3396               ; 3759  CD 96 33
        LD DE,337BH                 ; 375C  11 7B 33
        LD HL,3376H                 ; 375F  21 76 33
        CALL SUB_32D9               ; 3762  CD D9 32
        LD A,(36CCH)                ; 3765  3A CC 36
        ADD A,A                     ; 3768  87
        INC A                       ; 3769  3C
        LD B,A                      ; 376A  47
        LD A,08H                    ; 376B  3E 08
LOC_376D:
        BIT 7,B                     ; 376D  CB 78
        JP NZ,LOC_3778              ; 376F  C2 78 37
        SLA B                       ; 3772  CB 20
        DEC A                       ; 3774  3D
        JP NZ,LOC_376D              ; 3775  C2 6D 37
LOC_3778:
        ADD A,C0H                   ; 3778  C6 C0
        LD HL,3376H                 ; 377A  21 76 33
        LD (HL),A                   ; 377D  77
        INC HL                      ; 377E  23
        XOR A                       ; 377F  AF
        LD (HL),A                   ; 3780  77
        INC HL                      ; 3781  23
        LD (HL),A                   ; 3782  77
        INC HL                      ; 3783  23
        LD (HL),A                   ; 3784  77
        INC HL                      ; 3785  23
        LD (HL),B                   ; 3786  70
        LD HL,37FCH                 ; 3787  21 FC 37
        CALL SUB_3396               ; 378A  CD 96 33
        LD HL,337BH                 ; 378D  21 7B 33
        CALL SUB_338A               ; 3790  CD 8A 33
        LD HL,3376H                 ; 3793  21 76 33
        LD A,(36CBH)                ; 3796  3A CB 36
        CALL SUB_3931               ; 3799  CD 31 39
        POP DE                      ; 379C  D1
        PUSH DE                     ; 379D  D5
        CALL SUB_32D9               ; 379E  CD D9 32
        POP DE                      ; 37A1  D1
        LD A,(36CAH)                ; 37A2  3A CA 36
        OR A                        ; 37A5  B7
        RET NZ                      ; 37A6  C0
        LD HL,3376H                 ; 37A7  21 76 33
        JP SUB_2B3B                 ; 37AA  C3 3B 2B
SUB_37AD:
        PUSH HL                     ; 37AD  E5
        LD DE,3376H                 ; 37AE  11 76 33
        CALL SUB_32D9               ; 37B1  CD D9 32
        POP DE                      ; 37B4  D1
        PUSH DE                     ; 37B5  D5
        LD HL,2762H                 ; 37B6  21 62 27
        CALL SUB_32D9               ; 37B9  CD D9 32
        POP DE                      ; 37BC  D1
        PUSH DE                     ; 37BD  D5
        LD HL,3376H                 ; 37BE  21 76 33
        CALL SUB_2D1E               ; 37C1  CD 1E 2D
        POP HL                      ; 37C4  E1
        LD A,(HL)                   ; 37C5  7E
        CP C1H                      ; 37C6  FE C1
        JP NC,LOC_37D6              ; 37C8  D2 D6 37
        PUSH HL                     ; 37CB  E5
        EX DE,HL                    ; 37CC  EB
        LD HL,2762H                 ; 37CD  21 62 27
        CALL SUB_32D9               ; 37D0  CD D9 32
        POP HL                      ; 37D3  E1
        LD A,C1H                    ; 37D4  3E C1
LOC_37D6:
        EX AF,AF_                   ; 37D6  08
        LD A,00H                    ; 37D7  3E 00
        LD (36CBH),A                ; 37D9  32 CB 36
        EX AF,AF_                   ; 37DC  08
        RET                         ; 37DD  C9
        XOR L                       ; 37DE  AD
        AND H                       ; 37DF  A4
        LD H,D                      ; 37E0  62
        CALL Z,WS_B2AF              ; 37E1  CC AF B2
        SBC A,A                     ; 37E4  9F
        JP (HL)                     ; 37E5  E9
        LD B,A                      ; 37E6  47
        LD SP,HL                    ; 37E7  F9
        CP B                        ; 37E8  B8
        AND H                       ; 37E9  A4
        ADD A,D                     ; 37EA  82
        XOR D                       ; 37EB  AA
        CALL C,WS_BFBF              ; 37EC  DC BF BF
        CALL Z,WS_AFB0              ; 37EF  CC B0 AF
        POP BC                      ; 37F2  C1
        INC SP                      ; 37F3  33
        DI                          ; 37F4  F3
        INC B                       ; 37F5  04
        OR L                        ; 37F6  B5
        JP WS_7999                  ; 37F7  C3 99 79
        ADD A,D                     ; 37FA  82
        CP D                        ; 37FB  BA
        CP A                        ; 37FC  BF
        RET M                       ; 37FD  F8
        RLA                         ; 37FE  17
        LD (HL),D                   ; 37FF  72
        OR C                        ; 3800  B1
        PUSH DE                     ; 3801  D5
        CALL SUB_36CD               ; 3802  CD CD 36
        POP DE                      ; 3805  D1
        LD HL,380CH                 ; 3806  21 0C 38
        JP SUB_2C47                 ; 3809  C3 47 2C
        CP A                        ; 380C  BF
        XOR C                       ; 380D  A9
        RET C                       ; 380E  D8
        LD E,E                      ; 380F  5B
        SBC A,FDH                   ; 3810  DE FD
        RLA                         ; 3812  17
        PUSH DE                     ; 3813  D5
        EX DE,HL                    ; 3814  EB
        LD A,(HL)                   ; 3815  7E
        AND 80H                     ; 3816  E6 80
        LD (3811H),A                ; 3818  32 11 38
        SET 7,(HL)                  ; 381B  CB FE
        LD DE,2762H                 ; 381D  11 62 27
        CALL SUB_31D9               ; 3820  CD D9 31
        LD A,80H                    ; 3823  3E 80
        JP NC,LOC_3841              ; 3825  D2 41 38
        LD DE,3376H                 ; 3828  11 76 33
        POP HL                      ; 382B  E1
        PUSH HL                     ; 382C  E5
        CALL SUB_32D9               ; 382D  CD D9 32
        POP DE                      ; 3830  D1
        PUSH DE                     ; 3831  D5
        LD HL,2762H                 ; 3832  21 62 27
        CALL SUB_32D9               ; 3835  CD D9 32
        POP DE                      ; 3838  D1
        PUSH DE                     ; 3839  D5
        LD HL,3376H                 ; 383A  21 76 33
        CALL SUB_2D1E               ; 383D  CD 1E 2D
        XOR A                       ; 3840  AF
LOC_3841:
        LD (3812H),A                ; 3841  32 12 38
        POP HL                      ; 3844  E1
        PUSH HL                     ; 3845  E5
        LD DE,3376H                 ; 3846  11 76 33
        CALL SUB_32D9               ; 3849  CD D9 32
        POP HL                      ; 384C  E1
        PUSH HL                     ; 384D  E5
        CALL SUB_3396               ; 384E  CD 96 33
        LD HL,3376H                 ; 3851  21 76 33
        LD DE,337BH                 ; 3854  11 7B 33
        CALL SUB_32D9               ; 3857  CD D9 32
        LD HL,38C1H                 ; 385A  21 C1 38
        CALL SUB_3396               ; 385D  CD 96 33
        LD HL,38C6H                 ; 3860  21 C6 38
        CALL SUB_3390               ; 3863  CD 90 33
        LD HL,38CBH                 ; 3866  21 CB 38
        CALL SUB_3390               ; 3869  CD 90 33
        LD HL,38D0H                 ; 386C  21 D0 38
        CALL SUB_3390               ; 386F  CD 90 33
        LD HL,38D5H                 ; 3872  21 D5 38
        CALL SUB_3390               ; 3875  CD 90 33
        LD HL,38DAH                 ; 3878  21 DA 38
        CALL SUB_3390               ; 387B  CD 90 33
        LD HL,38DFH                 ; 387E  21 DF 38
        CALL SUB_3390               ; 3881  CD 90 33
        LD HL,38E4H                 ; 3884  21 E4 38
        CALL SUB_3390               ; 3887  CD 90 33
        LD HL,38E9H                 ; 388A  21 E9 38
        CALL SUB_3390               ; 388D  CD 90 33
        LD HL,2762H                 ; 3890  21 62 27
        CALL SUB_338A               ; 3893  CD 8A 33
        POP HL                      ; 3896  E1
        PUSH HL                     ; 3897  E5
        CALL SUB_3396               ; 3898  CD 96 33
        POP DE                      ; 389B  D1
        PUSH DE                     ; 389C  D5
        LD HL,3376H                 ; 389D  21 76 33
        CALL SUB_32D9               ; 38A0  CD D9 32
        LD A,(3812H)                ; 38A3  3A 12 38
        OR A                        ; 38A6  B7
        JP NZ,LOC_38BA              ; 38A7  C2 BA 38
        POP DE                      ; 38AA  D1
        PUSH DE                     ; 38AB  D5
        LD HL,3472H                 ; 38AC  21 72 34
        CALL SUB_32D9               ; 38AF  CD D9 32
        POP DE                      ; 38B2  D1
        PUSH DE                     ; 38B3  D5
        LD HL,3376H                 ; 38B4  21 76 33
        CALL SUB_2B38               ; 38B7  CD 38 2B
LOC_38BA:
        POP HL                      ; 38BA  E1
        LD A,(3811H)                ; 38BB  3A 11 38
        JP SUB_3931                 ; 38BE  C3 31 39
        SCF                         ; 38C1  37
        JP Z,KWTABLE+106            ; 38C2  CA 9A 56
        RST 18H                     ; 38C5  DF
        CP D                        ; 38C6  BA
        LD (DE),A                   ; 38C7  12
        LD (HL),A                   ; 38C8  77
        CALL Z,SUB_3BAB             ; 38C9  CC AB 3B
        INC HL                      ; 38CC  23
        OR D                        ; 38CD  B2
        LD E,(HL)                   ; 38CE  5E
        RET M                       ; 38CF  F8
        CP H                        ; 38D0  BC
        JR NZ,LOC_3936              ; 38D1  20 63
        SUB B                       ; 38D3  90
        JP (HL)                     ; 38D4  E9
        DEC A                       ; 38D5  3D
        XOR 3DH                     ; 38D6  EE 3D
        RET PO                      ; 38D8  E0
        XOR D                       ; 38D9  AA
        CP L                        ; 38DA  BD
        LD C,A                      ; 38DB  4F
        LD A,(DE)                   ; 38DC  1A
        PUSH DE                     ; 38DD  D5
        RST 18H                     ; 38DE  DF
        LD A,E3H                    ; 38DF  3E E3
        XOR A                       ; 38E1  AF
        INC BC                      ; 38E2  03
        SUB D                       ; 38E3  92
        CP (HL)                     ; 38E4  BE
        LD HL,(WS_C77B)             ; 38E5  2A 7B C7
        CALL Z,SUB_173F             ; 38E8  CC 3F 17
        SUB (HL)                    ; 38EB  96
        XOR D                       ; 38EC  AA
        XOR D                       ; 38ED  AA
        NOP                         ; 38EE  00
        JR NZ,LOC_38F1              ; 38EF  20 00
LOC_38F1:
        JR NZ,LOC_38F3              ; 38F1  20 00
LOC_38F3:
        OR B                        ; 38F3  B0
        LD DE,00B0H                 ; 38F4  11 B0 00
        LD (HL),B                   ; 38F7  70
        NOP                         ; 38F8  00
        PUSH DE                     ; 38F9  D5
        LD DE,38F4H                 ; 38FA  11 F4 38
        CALL SUB_32D9               ; 38FD  CD D9 32
        POP HL                      ; 3900  E1
        PUSH HL                     ; 3901  E5
        LD BC,0004H                 ; 3902  01 04 00
        ADD HL,BC                   ; 3905  09
        LD A,(HL)                   ; 3906  7E
        OR A                        ; 3907  B7
        POP HL                      ; 3908  E1
        PUSH HL                     ; 3909  E5
        JP P,LOC_2BCE               ; 390A  F2 CE 2B
        LD A,(HL)                   ; 390D  7E
        AND 80H                     ; 390E  E6 80
        LD (LOC_38F3),A             ; 3910  32 F3 38
        SET 7,(HL)                  ; 3913  CB FE
        EX DE,HL                    ; 3915  EB
        CALL SUB_36CD               ; 3916  CD CD 36
        LD A,(LOC_38F3)             ; 3919  3A F3 38
        OR A                        ; 391C  B7
        CALL Z,SUB_3944             ; 391D  CC 44 39
        POP DE                      ; 3920  D1
        PUSH DE                     ; 3921  D5
        LD HL,38F4H                 ; 3922  21 F4 38
        CALL SUB_2C47               ; 3925  CD 47 2C
        POP DE                      ; 3928  D1
        PUSH DE                     ; 3929  D5
        CALL SUB_3594               ; 392A  CD 94 35
        POP HL                      ; 392D  E1
        LD A,(LOC_38F3)             ; 392E  3A F3 38
SUB_3931:
        OR A                        ; 3931  B7
        RET NZ                      ; 3932  C0
SUB_3933:
        LD BC,0004H                 ; 3933  01 04 00
LOC_3936:
        ADD HL,BC                   ; 3936  09
        BIT 7,(HL)                  ; 3937  CB 7E
        PUSH AF                     ; 3939  F5
        XOR A                       ; 393A  AF
        SBC HL,BC                   ; 393B  ED 42
        POP AF                      ; 393D  F1
        RET Z                       ; 393E  C8
        LD A,(HL)                   ; 393F  7E
        ADD A,80H                   ; 3940  C6 80
        LD (HL),A                   ; 3942  77
        RET                         ; 3943  C9
SUB_3944:
        LD HL,38F4H                 ; 3944  21 F4 38
        LD DE,38EEH                 ; 3947  11 EE 38
        CALL SUB_32D9               ; 394A  CD D9 32
        LD DE,38F4H                 ; 394D  11 F4 38
        CALL SUB_31FC               ; 3950  CD FC 31
        LD DE,38EEH                 ; 3953  11 EE 38
        LD HL,38F4H                 ; 3956  21 F4 38
        CALL SUB_2B38               ; 3959  CD 38 2B
        LD HL,38F2H                 ; 395C  21 F2 38
        LD A,(HL)                   ; 395F  7E
        OR A                        ; 3960  B7
        JP M,LOC_237A               ; 3961  FA 7A 23
        LD HL,38F4H                 ; 3964  21 F4 38
        LD A,(HL)                   ; 3967  7E
        INC HL                      ; 3968  23
        LD E,(HL)                   ; 3969  5E
        INC HL                      ; 396A  23
        LD D,(HL)                   ; 396B  56
        INC HL                      ; 396C  23
        LD C,(HL)                   ; 396D  4E
        INC HL                      ; 396E  23
        LD B,(HL)                   ; 396F  46
        AND 7FH                     ; 3970  E6 7F
        SUB 41H                     ; 3972  D6 41
        JP C,LOC_3989               ; 3974  DA 89 39
        JP Z,LOC_3986               ; 3977  CA 86 39
LOC_397A:
        SLA E                       ; 397A  CB 23
        RL D                        ; 397C  CB 12
        RL C                        ; 397E  CB 11
        RL B                        ; 3980  CB 10
        DEC A                       ; 3982  3D
        JP NZ,LOC_397A              ; 3983  C2 7A 39
LOC_3986:
        RL B                        ; 3986  CB 10
        RET C                       ; 3988  D8
LOC_3989:
        LD A,80H                    ; 3989  3E 80
        LD (LOC_38F3),A             ; 398B  32 F3 38
        RET                         ; 398E  C9
        CALL SUB_3F1E               ; 398F  CD 1E 3F
        CALL SUB_27D2               ; 3992  CD D2 27
        CP A                        ; 3995  BF
        AND H                       ; 3996  A4
        ADD HL,SP                   ; 3997  39
        CALL SUB_27E1               ; 3998  CD E1 27
        LD D,B                      ; 399B  50
        DB 3EH                      ; 399C  3E   (stray byte(s): disassembly boundary correction)
LOC_399D:
        ADD A,B                     ; 399D  80
        LD (WS_62B9),A              ; 399E  32 B9 62
        JP LOC_39E5                 ; 39A1  C3 E5 39
        DB CDH,F9H                  ; 39A4  CD F9   (stray byte(s): disassembly boundary correction)
LOC_39A6:
        LD C,L                      ; 39A6  4D
        LD A,(WS_62B9)              ; 39A7  3A B9 62
        OR A                        ; 39AA  B7
        JP Z,LOC_39E5               ; 39AB  CA E5 39
        LD A,(WS_62BA)              ; 39AE  3A BA 62
        OR A                        ; 39B1  B7
        JP Z,LOC_243E               ; 39B2  CA 3E 24
        CP 03H                      ; 39B5  FE 03
        JP NC,LOC_243E              ; 39B7  D2 3E 24
        LD (3BB2H),A                ; 39BA  32 B2 3B
        CP 01H                      ; 39BD  FE 01
        JP NZ,LOC_39CB              ; 39BF  C2 CB 39
        CALL SUB_27D2               ; 39C2  CD D2 27
        JR Z,LOC_39A6               ; 39C5  28 DF
        ADD HL,SP                   ; 39C7  39
        JP LOC_2372                 ; 39C8  C3 72 23
LOC_39CB:
        CALL SUB_27E1               ; 39CB  CD E1 27
        JR Z,LOC_399D               ; 39CE  28 CD
        INC B                       ; 39D0  04
        LD (DE),A                   ; 39D1  12
        LD (DATA_3BB3),DE           ; 39D2  ED 53 B3 3B
        LD A,D                      ; 39D6  7A
        OR E                        ; 39D7  B3
        JP Z,LOC_237A               ; 39D8  CA 7A 23
        CALL SUB_27E1               ; 39DB  CD E1 27
        ADD HL,HL                   ; 39DE  29
        CALL SUB_27D2               ; 39DF  CD D2 27
        INC L                       ; 39E2  2C
        PUSH HL                     ; 39E3  E5
        ADD HL,SP                   ; 39E4  39
LOC_39E5:
        CALL SUB_2981               ; 39E5  CD 81 29
        JP NZ,LOC_3A1D              ; 39E8  C2 1D 3A
        LD (CUR_STMT),HL            ; 39EB  22 27 65
        LD BC,122AH                 ; 39EE  01 2A 12
        PUSH BC                     ; 39F1  C5
        LD A,(WS_62B9)              ; 39F2  3A B9 62
        OR A                        ; 39F5  B7
        JP Z,LETLN                  ; 39F6  CA 06 00
        CP 80H                      ; 39F9  FE 80
        JP Z,LOC_3D12               ; 39FB  CA 12 3D
        LD A,(WS_62BB)              ; 39FE  3A BB 62
        OR A                        ; 3A01  B7
        JP Z,LOC_3A15               ; 3A02  CA 15 3A
        LD DE,6000H                 ; 3A05  11 00 60
        LD A,0DH                    ; 3A08  3E 0D
        LD (DE),A                   ; 3A0A  12
        LD BC,0000H                 ; 3A0B  01 00 00
        JP LOC_3AAA                 ; 3A0E  C3 AA 3A
LOC_3A11:
        LD BC,122AH                 ; 3A11  01 2A 12
        PUSH BC                     ; 3A14  C5
LOC_3A15:
        LD A,(DATA_3F23)            ; 3A15  3A 23 3F
        OR A                        ; 3A18  B7
        RET Z                       ; 3A19  C8
        JP SUB_402C                 ; 3A1A  C3 2C 40
LOC_3A1D:
        CALL SUB_27D2               ; 3A1D  CD D2 27
        DEC SP                      ; 3A20  3B
        INC HL                      ; 3A21  23
        LD A,(3801H)                ; 3A22  3A 01 38
        LD A,(WS_FEC5)              ; 3A25  3A C5 FE
        INC L                       ; 3A28  2C
        RET NZ                      ; 3A29  C0
        INC HL                      ; 3A2A  23
        LD A,(WS_62B9)              ; 3A2B  3A B9 62
        OR A                        ; 3A2E  B7
        JP Z,TABUL                  ; 3A2F  CA 0F 00
        CP 80H                      ; 3A32  FE 80
        JP Z,LOC_3DC5               ; 3A34  CA C5 3D
        RET                         ; 3A37  C9
        CALL SUB_2981               ; 3A38  CD 81 29
        LD (CUR_STMT),HL            ; 3A3B  22 27 65
        JP Z,LOC_3A11               ; 3A3E  CA 11 3A
        CP 3BH                      ; 3A41  FE 3B
        JR Z,LOC_3A47               ; 3A43  28 02
        CP 2CH                      ; 3A45  FE 2C
LOC_3A47:
        JP Z,LOC_3A1D               ; 3A47  CA 1D 3A
        CALL SUB_27D2               ; 3A4A  CD D2 27
        RET                         ; 3A4D  C9
        RST 18H                     ; 3A4E  DF
        LD (DE),A                   ; 3A4F  12
        CALL SUB_1221               ; 3A50  CD 21 12
        CALL SUB_27E1               ; 3A53  CD E1 27
        ADD HL,HL                   ; 3A56  29
        LD A,(MON_1194)             ; 3A57  3A 94 11
        LD B,A                      ; 3A5A  47
        LD A,(WS_62B9)              ; 3A5B  3A B9 62
        OR A                        ; 3A5E  B7
        JP Z,LOC_3A6B               ; 3A5F  CA 6B 3A
        CP 80H                      ; 3A62  FE 80
        JP NZ,LOC_2372              ; 3A64  C2 72 23
        LD A,(DATA_3E41)            ; 3A67  3A 41 3E
        LD B,A                      ; 3A6A  47
LOC_3A6B:
        LD A,E                      ; 3A6B  7B
        INC B                       ; 3A6C  04
        SUB B                       ; 3A6D  90
        JP C,LOC_3A1D               ; 3A6E  DA 1D 3A
        INC A                       ; 3A71  3C
        LD B,A                      ; 3A72  47
        PUSH HL                     ; 3A73  E5
        LD HL,6000H                 ; 3A74  21 00 60
        PUSH HL                     ; 3A77  E5
LOC_3A78:
        LD (HL),13H                 ; 3A78  36 13
        INC HL                      ; 3A7A  23
        DJNZ LOC_3A78               ; 3A7B  10 FB
LOC_3A7D:
        LD (HL),0DH                 ; 3A7D  36 0D
        POP DE                      ; 3A7F  D1
        JP LOC_3A97                 ; 3A80  C3 97 3A
        CALL SUB_1A58               ; 3A83  CD 58 1A
        PUSH HL                     ; 3A86  E5
        LD A,D                      ; 3A87  7A
        OR A                        ; 3A88  B7
        JP NZ,LOC_3ADE              ; 3A89  C2 DE 3A
        LD HL,(FREE_PTR)            ; 3A8C  2A 6A 63
        LD DE,6000H                 ; 3A8F  11 00 60
        PUSH DE                     ; 3A92  D5
        CALL SUB_301B               ; 3A93  CD 1B 30
        POP DE                      ; 3A96  D1
LOC_3A97:
        LD BC,3ACDH                 ; 3A97  01 CD 3A
        PUSH BC                     ; 3A9A  C5
        LD A,(WS_62B9)              ; 3A9B  3A B9 62
        OR A                        ; 3A9E  B7
        JP Z,LOC_3AE5               ; 3A9F  CA E5 3A
        CP 80H                      ; 3AA2  FE 80
        JP Z,SUB_3D23               ; 3AA4  CA 23 3D
        LD BC,FFFFH                 ; 3AA7  01 FF FF
LOC_3AAA:
        PUSH DE                     ; 3AAA  D5
LOC_3AAB:
        LD A,(DE)                   ; 3AAB  1A
        INC DE                      ; 3AAC  13
        INC BC                      ; 3AAD  03
        CP 0DH                      ; 3AAE  FE 0D
        JR NZ,LOC_3AAB              ; 3AB0  20 F9
        POP DE                      ; 3AB2  D1
        CALL SUB_3AC0               ; 3AB3  CD C0 3A
        LD A,(WS_62BB)              ; 3AB6  3A BB 62
        LD HL,3AC9H                 ; 3AB9  21 C9 3A
        CALL SUB_4F62               ; 3ABC  CD 62 4F
        JP (HL)                     ; 3ABF  E9
; --- SUB_3AC0: called from 3 places ---
SUB_3AC0:
        LD IX,100BH                 ; 3AC0  DD 21 0B 10
        LD IY,1008H                 ; 3AC4  FD 21 08 10
        RET                         ; 3AC8  C9
        OR L                        ; 3AC9  B5
        DEC SP                      ; 3ACA  3B
        LD H,(HL)                   ; 3ACB  66
        LD B,B                      ; 3ACC  40
        LD HL,39E5H                 ; 3ACD  21 E5 39
        EX (SP),HL                  ; 3AD0  E3
        CALL SUB_2981               ; 3AD1  CD 81 29
        RET Z                       ; 3AD4  C8
        CP 3BH                      ; 3AD5  FE 3B
        RET Z                       ; 3AD7  C8
        CP 2CH                      ; 3AD8  FE 2C
        RET Z                       ; 3ADA  C8
        JP LOC_2372                 ; 3ADB  C3 72 23
LOC_3ADE:
        CALL SUB_2959               ; 3ADE  CD 59 29
        JP LOC_3A97                 ; 3AE1  C3 97 3A
        DEC C                       ; 3AE4  0D
LOC_3AE5:
        PUSH AF                     ; 3AE5  F5
        PUSH BC                     ; 3AE6  C5
        PUSH DE                     ; 3AE7  D5
        PUSH HL                     ; 3AE8  E5
LOC_3AE9:
        LD BC,0000H                 ; 3AE9  01 00 00
        LD HL,(CURSOR)              ; 3AEC  2A 71 11
        LD A,28H                    ; 3AEF  3E 28
        SUB L                       ; 3AF1  95
        LD B,A                      ; 3AF2  47
        LD HL,3B8AH                 ; 3AF3  21 8A 3B
LOC_3AF6:
        LD A,(DE)                   ; 3AF6  1A
        CP 0DH                      ; 3AF7  FE 0D
        JP NZ,LOC_3B04              ; 3AF9  C2 04 3B
LOC_3AFC:
        CALL SUB_3B27               ; 3AFC  CD 27 3B
        POP HL                      ; 3AFF  E1
        POP DE                      ; 3B00  D1
        POP BC                      ; 3B01  C1
        POP AF                      ; 3B02  F1
        RET                         ; 3B03  C9
LOC_3B04:
        CP 20H                      ; 3B04  FE 20
        JP NC,LOC_3B15              ; 3B06  D2 15 3B
        CALL SUB_3B27               ; 3B09  CD 27 3B
        LD A,(DE)                   ; 3B0C  1A
        INC DE                      ; 3B0D  13
        LD C,A                      ; 3B0E  4F
        CALL PRTCH                  ; 3B0F  CD 46 09
        JP LOC_3AE9                 ; 3B12  C3 E9 3A
LOC_3B15:
        LD A,(DE)                   ; 3B15  1A
        INC DE                      ; 3B16  13
        CALL ADCN                   ; 3B17  CD B9 0B
        LD (HL),A                   ; 3B1A  77
        INC HL                      ; 3B1B  23
        INC C                       ; 3B1C  0C
        DEC B                       ; 3B1D  05
        JP NZ,LOC_3AF6              ; 3B1E  C2 F6 3A
        CALL SUB_3B27               ; 3B21  CD 27 3B
        JP LOC_3AE9                 ; 3B24  C3 E9 3A
; --- SUB_3B27: called from 4 places ---
SUB_3B27:
        LD A,C                      ; 3B27  79
        OR A                        ; 3B28  B7
        RET Z                       ; 3B29  C8
        PUSH DE                     ; 3B2A  D5
        LD B,00H                    ; 3B2B  06 00
        LD A,(MON_1194)             ; 3B2D  3A 94 11
        ADD A,C                     ; 3B30  81
        CP 50H                      ; 3B31  FE 50
        JP C,LOC_3B38               ; 3B33  DA 38 3B
        SUB 50H                     ; 3B36  D6 50
LOC_3B38:
        LD (MON_1194),A             ; 3B38  32 94 11
        CALL GETVAD                 ; 3B3B  CD B1 0F
        LD A,(CURSOR)               ; 3B3E  3A 71 11
        ADD A,C                     ; 3B41  81
        LD (CURSOR),A               ; 3B42  32 71 11
        EX DE,HL                    ; 3B45  EB
        LD HL,3B8AH                 ; 3B46  21 8A 3B
        CALL SUB_3B80               ; 3B49  CD 80 3B
        POP DE                      ; 3B4C  D1
        LD HL,(CURSOR)              ; 3B4D  2A 71 11
        LD A,L                      ; 3B50  7D
        CP 28H                      ; 3B51  FE 28
        RET NZ                      ; 3B53  C0
        PUSH DE                     ; 3B54  D5
        LD E,H                      ; 3B55  5C
        LD D,00H                    ; 3B56  16 00
        DB 21H                      ; 3B58  21   (stray byte(s): disassembly boundary correction)
LOC_3B59:
        LD (HL),E                   ; 3B59  73
        LD DE,7E19H                 ; 3B5A  11 19 7E
        OR A                        ; 3B5D  B7
        JP NZ,LOC_3B67              ; 3B5E  C2 67 3B
        INC HL                      ; 3B61  23
        LD (HL),01H                 ; 3B62  36 01
        INC HL                      ; 3B64  23
        LD (HL),00H                 ; 3B65  36 00
LOC_3B67:
        POP DE                      ; 3B67  D1
        LD HL,(CURSOR)              ; 3B68  2A 71 11
        LD L,00H                    ; 3B6B  2E 00
        INC H                       ; 3B6D  24
        LD (CURSOR),HL              ; 3B6E  22 71 11
        LD A,H                      ; 3B71  7C
        CP 19H                      ; 3B72  FE 19
        RET NZ                      ; 3B74  C0
        LD H,18H                    ; 3B75  26 18
        LD (CURSOR),HL              ; 3B77  22 71 11
        LD A,(21F9H)                ; 3B7A  3A F9 21
        JP LOC_190B                 ; 3B7D  C3 0B 19
SUB_3B80:
        LD A,(21F9H)                ; 3B80  3A F9 21
        OR A                        ; 3B83  B7
        CALL Z,SNCV                 ; 3B84  CC A6 0D
        LDIR                        ; 3B87  ED B0
        RET                         ; 3B89  C9
        NOP                         ; 3B8A  00
        JR NZ,LOC_3BB0              ; 3B8B  20 23
        LD H,28H                    ; 3B8D  26 28
        JR NZ,LOC_3B91              ; 3B8F  20 00
LOC_3B91:
        DJNZ LOC_3BA5               ; 3B91  10 12
        ADD HL,BC                   ; 3B93  09
        LD C,14H                    ; 3B94  0E 14
        LD H,D                      ; 3B96  62
        ADD A,62H                   ; 3B97  C6 62
        INC L                       ; 3B99  2C
        LD C,A                      ; 3B9A  4F
        RLCA                        ; 3B9B  07
        RRCA                        ; 3B9C  0F
        INC D                       ; 3B9D  14
        RRCA                        ; 3B9E  0F
        LD H,25H                    ; 3B9F  26 25
        DEC H                       ; 3BA1  25
        INC HL                      ; 3BA2  23
        DEC H                       ; 3BA3  25
        INC D                       ; 3BA4  14
LOC_3BA5:
        ADD HL,BC                   ; 3BA5  09
        CPL                         ; 3BA6  2F
        DJNZ LOC_3BAE               ; 3BA7  10 05
        DEC B                       ; 3BA9  05
        DEC BC                      ; 3BAA  0B
SUB_3BAB:
        LD L,B                      ; 3BAB  68
        ADD HL,BC                   ; 3BAC  09
        LD L,C                      ; 3BAD  69
LOC_3BAE:
        CPL                         ; 3BAE  2F
        INC BC                      ; 3BAF  03
LOC_3BB0:
        EX AF,AF_                   ; 3BB0  08
        LD (DE),A                   ; 3BB1  12
        INC B                       ; 3BB2  04
DATA_3BB3:
        ADC A,B                     ; 3BB3  88
        LD BC,B23AH                 ; 3BB4  01 3A B2
        DEC SP                      ; 3BB7  3B
        CP 01H                      ; 3BB8  FE 01
        JP Z,LOC_3CA2               ; 3BBA  CA A2 3C
        PUSH BC                     ; 3BBD  C5
        LD HL,6180H                 ; 3BBE  21 80 61
        PUSH HL                     ; 3BC1  E5
        LD B,08H                    ; 3BC2  06 08
        LD A,20H                    ; 3BC4  3E 20
LOC_3BC6:
        CALL SUB_2A2C               ; 3BC6  CD 2C 2A
        DJNZ LOC_3BC6               ; 3BC9  10 FB
        POP HL                      ; 3BCB  E1
        POP BC                      ; 3BCC  C1
        LD A,C                      ; 3BCD  79
        OR A                        ; 3BCE  B7
        JP Z,LOC_3BDB               ; 3BCF  CA DB 3B
        SUB 10H                     ; 3BD2  D6 10
        JR C,LOC_3BD8               ; 3BD4  38 02
        LD C,10H                    ; 3BD6  0E 10
LOC_3BD8:
        EX DE,HL                    ; 3BD8  EB
        LDIR                        ; 3BD9  ED B0
LOC_3BDB:
        LD HL,(VAR_PTR)             ; 3BDB  2A C6 62
        LD BC,0013H                 ; 3BDE  01 13 00
        ADD HL,BC                   ; 3BE1  09
        LD A,(HL)                   ; 3BE2  7E
        OR A                        ; 3BE3  B7
        JP NZ,LOC_23FA              ; 3BE4  C2 FA 23
        LD HL,(WS_62CE)             ; 3BE7  2A CE 62
        LD E,(HL)                   ; 3BEA  5E
        INC HL                      ; 3BEB  23
        LD D,(HL)                   ; 3BEC  56
        LD HL,(DATA_3BB3)           ; 3BED  2A B3 3B
        EX DE,HL                    ; 3BF0  EB
        CALL SUB_27B0               ; 3BF1  CD B0 27
        JP NC,LOC_3C90              ; 3BF4  D2 90 3C
        LD HL,(WS_62CE)             ; 3BF7  2A CE 62
        LD (HL),E                   ; 3BFA  73
        INC HL                      ; 3BFB  23
        LD (HL),D                   ; 3BFC  72
        DEC DE                      ; 3BFD  1B
        LD A,E                      ; 3BFE  7B
        RLA                         ; 3BFF  17
        LD A,D                      ; 3C00  7A
        ADC A,A                     ; 3C01  8F
        JP C,LOC_2416               ; 3C02  DA 16 24
        CP 41H                      ; 3C05  FE 41
        JP NC,LOC_2416              ; 3C07  D2 16 24
        INC A                       ; 3C0A  3C
        LD B,A                      ; 3C0B  47
LOC_3C0C:
        INC HL                      ; 3C0C  23
        LD A,(HL)                   ; 3C0D  7E
        OR A                        ; 3C0E  B7
        JR Z,LOC_3C16               ; 3C0F  28 05
        DJNZ LOC_3C0C               ; 3C11  10 F9
        JP LOC_3C30                 ; 3C13  C3 30 3C
LOC_3C16:
        LD (4F2EH),HL               ; 3C16  22 2E 4F
        PUSH HL                     ; 3C19  E5
        LD HL,10F0H                 ; 3C1A  21 F0 10
        LD C,80H                    ; 3C1D  0E 80
LOC_3C1F:
        LD (HL),20H                 ; 3C1F  36 20
        INC HL                      ; 3C21  23
        DEC C                       ; 3C22  0D
        JR NZ,LOC_3C1F              ; 3C23  20 FA
        POP HL                      ; 3C25  E1
LOC_3C26:
        CALL SUB_3C4A               ; 3C26  CD 4A 3C
        LD (HL),E                   ; 3C29  73
        INC HL                      ; 3C2A  23
        DJNZ LOC_3C26               ; 3C2B  10 F9
        CALL SUB_4F2A               ; 3C2D  CD 2A 4F
LOC_3C30:
        LD HL,(VAR_PTR)             ; 3C30  2A C6 62
        LD BC,0040H                 ; 3C33  01 40 00
        ADD HL,BC                   ; 3C36  09
        LD E,(HL)                   ; 3C37  5E
        INC HL                      ; 3C38  23
        LD D,(HL)                   ; 3C39  56
        EX DE,HL                    ; 3C3A  EB
        LD (DATA_50D4),HL           ; 3C3B  22 D4 50
        LD HL,(WS_62CE)             ; 3C3E  2A CE 62
        LD (DATA_50D8),HL           ; 3C41  22 D8 50
        CALL SUB_50B5               ; 3C44  CD B5 50
        JP LOC_3C90                 ; 3C47  C3 90 3C
SUB_3C4A:
        PUSH HL                     ; 3C4A  E5
        PUSH BC                     ; 3C4B  C5
        LD HL,(WS_62C4)             ; 3C4C  2A C4 62
        LD DE,0003H                 ; 3C4F  11 03 00
        ADD HL,DE                   ; 3C52  19
        PUSH HL                     ; 3C53  E5
        ADD HL,DE                   ; 3C54  19
LOC_3C55:
        INC E                       ; 3C55  1C
        LD A,46H                    ; 3C56  3E 46
        CP E                        ; 3C58  BB
        JP Z,LOC_2416               ; 3C59  CA 16 24
        LD A,(HL)                   ; 3C5C  7E
        INC HL                      ; 3C5D  23
        OR (HL)                     ; 3C5E  B6
        INC HL                      ; 3C5F  23
        JR NZ,LOC_3C55              ; 3C60  20 F3
        DEC HL                      ; 3C62  2B
        LD (HL),FFH                 ; 3C63  36 FF
        DEC HL                      ; 3C65  2B
        LD (HL),FFH                 ; 3C66  36 FF
        POP HL                      ; 3C68  E1
        INC HL                      ; 3C69  23
        LD A,10H                    ; 3C6A  3E 10
        ADD A,(HL)                  ; 3C6C  86
        LD (HL),A                   ; 3C6D  77
        INC HL                      ; 3C6E  23
        LD A,00H                    ; 3C6F  3E 00
        ADC A,(HL)                  ; 3C71  8E
        LD (HL),A                   ; 3C72  77
        PUSH DE                     ; 3C73  D5
        LD HL,10F0H                 ; 3C74  21 F0 10
        LD (DATA_50D8),HL           ; 3C77  22 D8 50
        LD L,E                      ; 3C7A  6B
        LD H,01H                    ; 3C7B  26 01
        LD (DATA_50D4),HL           ; 3C7D  22 D4 50
LOC_3C80:
        CALL SUB_50B5               ; 3C80  CD B5 50
        LD HL,50D5H                 ; 3C83  21 D5 50
        INC (HL)                    ; 3C86  34
        LD A,11H                    ; 3C87  3E 11
        CP (HL)                     ; 3C89  BE
        JR NZ,LOC_3C80              ; 3C8A  20 F4
        POP DE                      ; 3C8C  D1
        POP BC                      ; 3C8D  C1
        POP HL                      ; 3C8E  E1
        RET                         ; 3C8F  C9
LOC_3C90:
        LD HL,(DATA_3BB3)           ; 3C90  2A B3 3B
        DEC HL                      ; 3C93  2B
        EX DE,HL                    ; 3C94  EB
        LD A,01H                    ; 3C95  3E 01
        CALL SUB_3FA9               ; 3C97  CD A9 3F
        LD HL,(DATA_3BB3)           ; 3C9A  2A B3 3B
        INC HL                      ; 3C9D  23
        LD (DATA_3BB3),HL           ; 3C9E  22 B3 3B
        RET                         ; 3CA1  C9
LOC_3CA2:
        INC BC                      ; 3CA2  03
SUB_3CA3:
        LD HL,(WS_62CC)             ; 3CA3  2A CC 62
        PUSH HL                     ; 3CA6  E5
        PUSH BC                     ; 3CA7  C5
        LD C,(HL)                   ; 3CA8  4E
        INC HL                      ; 3CA9  23
        LD B,(HL)                   ; 3CAA  46
        LD HL,(WS_62CE)             ; 3CAB  2A CE 62
        ADD HL,BC                   ; 3CAE  09
LOC_3CAF:
        CALL SUB_3CC5               ; 3CAF  CD C5 3C
        LD A,(DE)                   ; 3CB2  1A
        LD (HL),A                   ; 3CB3  77
        INC HL                      ; 3CB4  23
        INC DE                      ; 3CB5  13
        INC BC                      ; 3CB6  03
        EX (SP),HL                  ; 3CB7  E3
        DEC HL                      ; 3CB8  2B
        LD A,H                      ; 3CB9  7C
        OR L                        ; 3CBA  B5
        EX (SP),HL                  ; 3CBB  E3
        JP NZ,LOC_3CAF              ; 3CBC  C2 AF 3C
        POP HL                      ; 3CBF  E1
        POP HL                      ; 3CC0  E1
        LD (HL),C                   ; 3CC1  71
        INC HL                      ; 3CC2  23
        LD (HL),B                   ; 3CC3  70
        RET                         ; 3CC4  C9
SUB_3CC5:
        LD A,7EH                    ; 3CC5  3E 7E
        CP C                        ; 3CC7  B9
        RET NZ                      ; 3CC8  C0
        LD A,01H                    ; 3CC9  3E 01
SUB_3CCB:
        OR A                        ; 3CCB  B7
        PUSH DE                     ; 3CCC  D5
        PUSH AF                     ; 3CCD  F5
        LD HL,(WS_62CA)             ; 3CCE  2A CA 62
        LD E,(HL)                   ; 3CD1  5E
        INC HL                      ; 3CD2  23
        LD D,(HL)                   ; 3CD3  56
        DEC HL                      ; 3CD4  2B
        EX DE,HL                    ; 3CD5  EB
        ADD HL,BC                   ; 3CD6  09
        EX DE,HL                    ; 3CD7  EB
        LD (HL),E                   ; 3CD8  73
        INC HL                      ; 3CD9  23
        LD (HL),D                   ; 3CDA  72
        INC HL                      ; 3CDB  23
        CALL SUB_2A2B               ; 3CDC  CD 2B 2A
        POP AF                      ; 3CDF  F1
        CALL Z,SUB_3D0A             ; 3CE0  CC 0A 3D
        CALL NZ,SUB_50DD            ; 3CE3  C4 DD 50
        LD HL,(WS_62D0)             ; 3CE6  2A D0 62
        LD (HL),E                   ; 3CE9  73
        INC HL                      ; 3CEA  23
        LD (HL),D                   ; 3CEB  72
        LD HL,(WS_62C8)             ; 3CEC  2A C8 62
        LD C,(HL)                   ; 3CEF  4E
        INC HL                      ; 3CF0  23
        LD B,(HL)                   ; 3CF1  46
        DEC HL                      ; 3CF2  2B
        LD (DATA_50D4),BC           ; 3CF3  ED 43 D4 50
        LD (HL),E                   ; 3CF7  73
        INC HL                      ; 3CF8  23
        LD (HL),D                   ; 3CF9  72
        LD HL,(WS_62CE)             ; 3CFA  2A CE 62
        LD (DATA_50D8),HL           ; 3CFD  22 D8 50
        PUSH HL                     ; 3D00  E5
        CALL SUB_50B5               ; 3D01  CD B5 50
        LD BC,0000H                 ; 3D04  01 00 00
        POP HL                      ; 3D07  E1
        POP DE                      ; 3D08  D1
        RET                         ; 3D09  C9
SUB_3D0A:
        LD D,A                      ; 3D0A  57
        LD E,A                      ; 3D0B  5F
        RET                         ; 3D0C  C9
SUB_3D0D:
        LD A,(DATA_3E41)            ; 3D0D  3A 41 3E
        OR A                        ; 3D10  B7
        RET Z                       ; 3D11  C8
LOC_3D12:
        CALL SUB_3DE1               ; 3D12  CD E1 3D
        RET C                       ; 3D15  D8
        CALL SUB_3E30               ; 3D16  CD 30 3E
        LD A,0DH                    ; 3D19  3E 0D
        CALL SUB_3DFB               ; 3D1B  CD FB 3D
        XOR A                       ; 3D1E  AF
        LD (DATA_3E41),A            ; 3D1F  32 41 3E
        RET                         ; 3D22  C9
; --- SUB_3D23: called from 3 places ---
SUB_3D23:
        LD A,01H                    ; 3D23  3E 01
        JR LOC_3D29                 ; 3D25  18 02
        INC HL                      ; 3D27  23
LOC_3D28:
        XOR A                       ; 3D28  AF
LOC_3D29:
        LD (3D27H),A                ; 3D29  32 27 3D
        CALL SUB_3DE1               ; 3D2C  CD E1 3D
        RET C                       ; 3D2F  D8
        PUSH BC                     ; 3D30  C5
        PUSH DE                     ; 3D31  D5
        LD A,(DATA_3E41)            ; 3D32  3A 41 3E
        LD B,A                      ; 3D35  47
LOC_3D36:
        LD A,(DE)                   ; 3D36  1A
        CP 0DH                      ; 3D37  FE 0D
        JP Z,LOC_3D55               ; 3D39  CA 55 3D
        LD A,(3D27H)                ; 3D3C  3A 27 3D
        OR A                        ; 3D3F  B7
        LD A,(DE)                   ; 3D40  1A
        CALL NZ,SUB_3D65            ; 3D41  C4 65 3D
        INC B                       ; 3D44  04
        CALL SUB_3DFB               ; 3D45  CD FB 3D
        INC DE                      ; 3D48  13
        LD A,B                      ; 3D49  78
        CP 50H                      ; 3D4A  FE 50
        JP C,LOC_3D36               ; 3D4C  DA 36 3D
        SUB 50H                     ; 3D4F  D6 50
        LD B,A                      ; 3D51  47
        JP LOC_3D36                 ; 3D52  C3 36 3D
LOC_3D55:
        LD A,B                      ; 3D55  78
        CP 50H                      ; 3D56  FE 50
        JP C,LOC_3D5D               ; 3D58  DA 5D 3D
        SUB 50H                     ; 3D5B  D6 50
LOC_3D5D:
        LD (DATA_3E41),A            ; 3D5D  32 41 3E
        POP DE                      ; 3D60  D1
        POP BC                      ; 3D61  C1
        JP SUB_3E30                 ; 3D62  C3 30 3E
SUB_3D65:
        CP 20H                      ; 3D65  FE 20
        RET NC                      ; 3D67  D0
        CP 13H                      ; 3D68  FE 13
        JR NZ,LOC_3D6F              ; 3D6A  20 03
        LD A,20H                    ; 3D6C  3E 20
        RET                         ; 3D6E  C9
LOC_3D6F:
        CP 15H                      ; 3D6F  FE 15
        JP Z,LOC_3D84               ; 3D71  CA 84 3D
        CP 12H                      ; 3D74  FE 12
        JP Z,LOC_3D89               ; 3D76  CA 89 3D
        CP 11H                      ; 3D79  FE 11
        JP Z,LOC_3D8E               ; 3D7B  CA 8E 3D
        CP 16H                      ; 3D7E  FE 16
        JP Z,LOC_3D93               ; 3D80  CA 93 3D
        RET                         ; 3D83  C9
LOC_3D84:
        LD A,0FH                    ; 3D84  3E 0F
        LD B,FFH                    ; 3D86  06 FF
        RET                         ; 3D88  C9
LOC_3D89:
        LD A,0BH                    ; 3D89  3E 0B
        LD B,FFH                    ; 3D8B  06 FF
        RET                         ; 3D8D  C9
LOC_3D8E:
        LD A,09H                    ; 3D8E  3E 09
        LD B,FFH                    ; 3D90  06 FF
        RET                         ; 3D92  C9
LOC_3D93:
        LD A,0CH                    ; 3D93  3E 0C
        CALL SUB_3DFB               ; 3D95  CD FB 3D
        LD A,0AH                    ; 3D98  3E 0A
        LD B,FFH                    ; 3D9A  06 FF
        RET                         ; 3D9C  C9
SUB_3D9D:
        PUSH DE                     ; 3D9D  D5
        LD DE,3DA6H                 ; 3D9E  11 A6 3D
        CALL SUB_3D23               ; 3DA1  CD 23 3D
        POP DE                      ; 3DA4  D1
        RET                         ; 3DA5  C9
        LD D,0DH                    ; 3DA6  16 0D
        CP 0DH                      ; 3DA8  FE 0D
        JP Z,WS_FFFF                ; 3DAA  CA FF FF
        PUSH BC                     ; 3DAD  C5
        PUSH DE                     ; 3DAE  D5
        LD C,A                      ; 3DAF  4F
        LD A,(DATA_3E41)            ; 3DB0  3A 41 3E
        LD B,A                      ; 3DB3  47
        CALL SUB_3DE1               ; 3DB4  CD E1 3D
        JP NC,LOC_3DBD              ; 3DB7  D2 BD 3D
        POP DE                      ; 3DBA  D1
        POP BC                      ; 3DBB  C1
        RET                         ; 3DBC  C9
LOC_3DBD:
        LD A,C                      ; 3DBD  79
        CALL SUB_3DFB               ; 3DBE  CD FB 3D
        INC B                       ; 3DC1  04
        JP LOC_3D55                 ; 3DC2  C3 55 3D
LOC_3DC5:
        CALL SUB_3DE1               ; 3DC5  CD E1 3D
        RET C                       ; 3DC8  D8
        PUSH BC                     ; 3DC9  C5
        PUSH DE                     ; 3DCA  D5
        LD A,(DATA_3E41)            ; 3DCB  3A 41 3E
        LD B,A                      ; 3DCE  47
LOC_3DCF:
        LD A,20H                    ; 3DCF  3E 20
        CALL SUB_3DFB               ; 3DD1  CD FB 3D
        INC B                       ; 3DD4  04
        LD A,B                      ; 3DD5  78
LOC_3DD6:
        SUB 0AH                     ; 3DD6  D6 0A
        JP C,LOC_3DCF               ; 3DD8  DA CF 3D
        JP NZ,LOC_3DD6              ; 3DDB  C2 D6 3D
        JP LOC_3D55                 ; 3DDE  C3 55 3D
; --- SUB_3DE1: called from 4 places ---
SUB_3DE1:
        LD A,05H                    ; 3DE1  3E 05
        CALL SUB_3DEE               ; 3DE3  CD EE 3D
        RET C                       ; 3DE6  D8
        LD A,06H                    ; 3DE7  3E 06
        CALL SUB_3DEE               ; 3DE9  CD EE 3D
        CCF                         ; 3DEC  3F
        RET                         ; 3DED  C9
; --- SUB_3DEE: called from 4 places ---
SUB_3DEE:
        CALL SUB_3DFB               ; 3DEE  CD FB 3D
        LD A,00H                    ; 3DF1  3E 00
        CALL SUB_3E10               ; 3DF3  CD 10 3E
        IN A,(FEH)                  ; 3DF6  DB FE
        RRCA                        ; 3DF8  0F
        RRCA                        ; 3DF9  0F
        RET                         ; 3DFA  C9
; --- SUB_3DFB: called from 7 places ---
SUB_3DFB:
        PUSH AF                     ; 3DFB  F5
        XOR A                       ; 3DFC  AF
        CALL SUB_3E10               ; 3DFD  CD 10 3E
        POP AF                      ; 3E00  F1
        OUT (FFH),A                 ; 3E01  D3 FF
        LD A,80H                    ; 3E03  3E 80
        OUT (FEH),A                 ; 3E05  D3 FE
        LD A,01H                    ; 3E07  3E 01
        CALL SUB_3E10               ; 3E09  CD 10 3E
        XOR A                       ; 3E0C  AF
        OUT (FEH),A                 ; 3E0D  D3 FE
        RET                         ; 3E0F  C9
; --- SUB_3E10: called from 3 places ---
SUB_3E10:
        PUSH BC                     ; 3E10  C5
        PUSH DE                     ; 3E11  D5
        LD D,A                      ; 3E12  57
        LD E,06H                    ; 3E13  1E 06
        LD BC,0000H                 ; 3E15  01 00 00
LOC_3E18:
        IN A,(FEH)                  ; 3E18  DB FE
        AND 0DH                     ; 3E1A  E6 0D
        CP D                        ; 3E1C  BA
        JP NZ,LOC_3E23              ; 3E1D  C2 23 3E
        POP DE                      ; 3E20  D1
        POP BC                      ; 3E21  C1
        RET                         ; 3E22  C9
LOC_3E23:
        DEC BC                      ; 3E23  0B
        LD A,B                      ; 3E24  78
        OR C                        ; 3E25  B1
        JP NZ,LOC_3E18              ; 3E26  C2 18 3E
        DEC E                       ; 3E29  1D
        JP NZ,LOC_3E18              ; 3E2A  C2 18 3E
        JP LOC_2446                 ; 3E2D  C3 46 24
SUB_3E30:
        LD A,07H                    ; 3E30  3E 07
        CALL SUB_3DEE               ; 3E32  CD EE 3D
        JP NC,LOC_244E              ; 3E35  D2 4E 24
        LD A,08H                    ; 3E38  3E 08
        CALL SUB_3DEE               ; 3E3A  CD EE 3D
        RET C                       ; 3E3D  D8
        JP LOC_244A                 ; 3E3E  C3 4A 24
DATA_3E41:
        NOP                         ; 3E41  00
        CALL SUB_3F1E               ; 3E42  CD 1E 3F
        CALL SUB_2B2A               ; 3E45  CD 2A 2B
        CALL SUB_4DF9               ; 3E48  CD F9 4D
        LD A,(WS_62B9)              ; 3E4B  3A B9 62
        OR A                        ; 3E4E  B7
        JP M,LOC_2372               ; 3E4F  FA 72 23
        JP NZ,LOC_3EAA              ; 3E52  C2 AA 3E
        CALL SUB_277B               ; 3E55  CD 7B 27
        CP 22H                      ; 3E58  FE 22
        LD DE,3EA7H                 ; 3E5A  11 A7 3E
        JP NZ,LOC_3E6A              ; 3E5D  C2 6A 3E
        CALL SUB_1A58               ; 3E60  CD 58 1A
        CALL SUB_27E1               ; 3E63  CD E1 27
        DEC SP                      ; 3E66  3B
        CALL SUB_2959               ; 3E67  CD 59 29
LOC_3E6A:
        LD (CUR_STMT),HL            ; 3E6A  22 27 65
LOC_3E6D:
        CALL MON_MESSAGE            ; 3E6D  CD 15 00
        LD A,(MON_1194)             ; 3E70  3A 94 11
        LD B,A                      ; 3E73  47
        LD L,A                      ; 3E74  6F
        LD H,00H                    ; 3E75  26 00
        LD DE,6055H                 ; 3E77  11 55 60
        ADD HL,DE                   ; 3E7A  19
        LD (DATA_40E4),HL           ; 3E7B  22 E4 40
        PUSH DE                     ; 3E7E  D5
        CALL GETL                   ; 3E7F  CD 03 00
        POP HL                      ; 3E82  E1
        LD A,(HL)                   ; 3E83  7E
        CP 1BH                      ; 3E84  FE 1B
        JP NZ,LOC_3E91              ; 3E86  C2 91 3E
        LD A,80H                    ; 3E89  3E 80
        LD (WS_6167),A              ; 3E8B  32 67 61
        JP LOC_2354                 ; 3E8E  C3 54 23
LOC_3E91:
        INC B                       ; 3E91  04
        LD A,0DH                    ; 3E92  3E 0D
LOC_3E94:
        CP (HL)                     ; 3E94  BE
        JP Z,LOC_3E9E               ; 3E95  CA 9E 3E
        INC HL                      ; 3E98  23
        DJNZ LOC_3E94               ; 3E99  10 F9
        JP LOC_40E6                 ; 3E9B  C3 E6 40
LOC_3E9E:
        CALL NEWLIN                 ; 3E9E  CD 09 00
        LD DE,3EA7H                 ; 3EA1  11 A7 3E
        JP LOC_3E6D                 ; 3EA4  C3 6D 3E
        CCF                         ; 3EA7  3F
        JR NZ,LOC_3EB7              ; 3EA8  20 0D
LOC_3EAA:
        LD A,(WS_62BA)              ; 3EAA  3A BA 62
        CP 02H                      ; 3EAD  FE 02
        JP Z,LOC_3EE2               ; 3EAF  CA E2 3E
        DB CDH,E1H                  ; 3EB2  CD E1   (stray byte(s): disassembly boundary correction)
LOC_3EB4:
        DAA                         ; 3EB4  27
        INC L                       ; 3EB5  2C
        DB 22H                      ; 3EB6  22   (stray byte(s): disassembly boundary correction)
LOC_3EB7:
        DAA                         ; 3EB7  27
        LD H,L                      ; 3EB8  65
        LD HL,3ECDH                 ; 3EB9  21 CD 3E
        PUSH HL                     ; 3EBC  E5
        LD DE,6055H                 ; 3EBD  11 55 60
        CALL SUB_3AC0               ; 3EC0  CD C0 3A
        LD A,(WS_62BB)              ; 3EC3  3A BB 62
        LD HL,3EDCH                 ; 3EC6  21 DC 3E
        CALL SUB_4F62               ; 3EC9  CD 62 4F
        JP (HL)                     ; 3ECC  E9
        LD HL,6055H                 ; 3ECD  21 55 60
        CALL SUB_294B               ; 3ED0  CD 4B 29
        CALL SUB_2A74               ; 3ED3  CD 74 2A
        LD HL,3EB9H                 ; 3ED6  21 B9 3E
        JP LOC_4120                 ; 3ED9  C3 20 41
        LD L,D                      ; 3EDC  6A
        LD B,B                      ; 3EDD  40
        LD H,(HL)                   ; 3EDE  66
        LD B,B                      ; 3EDF  40
DATA_3EE0:
        POP BC                      ; 3EE0  C1
        LD (BC),A                   ; 3EE1  02
LOC_3EE2:
        CALL SUB_27E1               ; 3EE2  CD E1 27
        JR Z,LOC_3EB4               ; 3EE5  28 CD
        INC B                       ; 3EE7  04
        LD (DE),A                   ; 3EE8  12
        CALL SUB_27E1               ; 3EE9  CD E1 27
        ADD HL,HL                   ; 3EEC  29
        LD (DATA_3EE0),DE           ; 3EED  ED 53 E0 3E
        LD A,D                      ; 3EF1  7A
        OR E                        ; 3EF2  B3
        JP Z,LOC_237A               ; 3EF3  CA 7A 23
        CALL SUB_27D2               ; 3EF6  CD D2 27
        INC L                       ; 3EF9  2C
        CALL M,SUB_223E             ; 3EFA  FC 3E 22
        DAA                         ; 3EFD  27
        LD H,L                      ; 3EFE  65
        LD HL,(WS_62CE)             ; 3EFF  2A CE 62
        LD E,(HL)                   ; 3F02  5E
        INC HL                      ; 3F03  23
        LD D,(HL)                   ; 3F04  56
        LD HL,(DATA_3EE0)           ; 3F05  2A E0 3E
        EX DE,HL                    ; 3F08  EB
        CALL SUB_27B0               ; 3F09  CD B0 27
        JP C,LOC_403C               ; 3F0C  DA 3C 40
        DEC DE                      ; 3F0F  1B
        XOR A                       ; 3F10  AF
        CALL SUB_3FA9               ; 3F11  CD A9 3F
        LD HL,(DATA_3EE0)           ; 3F14  2A E0 3E
        INC HL                      ; 3F17  23
        LD (DATA_3EE0),HL           ; 3F18  22 E0 3E
        JP LOC_4045                 ; 3F1B  C3 45 40
SUB_3F1E:
        XOR A                       ; 3F1E  AF
        LD (DATA_3F23),A            ; 3F1F  32 23 3F
        RET                         ; 3F22  C9
DATA_3F23:
        NOP                         ; 3F23  00
        ADD A,B                     ; 3F24  80
        DAA                         ; 3F25  27
        AND B                       ; 3F26  A0
        DAA                         ; 3F27  27
        SUB B                       ; 3F28  90
        LD H,90H                    ; 3F29  26 90
        LD H,(HL)                   ; 3F2B  66
        NOP                         ; 3F2C  00
        LD (HL),10H                 ; 3F2D  36 10
        LD H,80H                    ; 3F2F  26 80
        LD H,10H                    ; 3F31  26 10
        RLCA                        ; 3F33  07
        DJNZ LOC_3F58               ; 3F34  10 22
        SUB B                       ; 3F36  90
        LD H,90H                    ; 3F37  26 90
        SCF                         ; 3F39  37
        NOP                         ; 3F3A  00
        LD H,10H                    ; 3F3B  26 10
        INC B                       ; 3F3D  04
        NOP                         ; 3F3E  00
        LD H,E8H                    ; 3F3F  26 E8
        AND D                       ; 3F41  A2
        RET NC                      ; 3F42  D0
        AND D                       ; 3F43  A2
        RET NZ                      ; 3F44  C0
        LD L,(HL)                   ; 3F45  6E
        JP NC,WS_90AE               ; 3F46  D2 AE 90
        LD H,(HL)                   ; 3F49  66
        RET NC                      ; 3F4A  D0
        AND E                       ; 3F4B  A3
        RET NZ                      ; 3F4C  C0
        AND (HL)                    ; 3F4D  A6
        CALL P,WS_E8EA              ; 3F4E  F4 EA E8
        AND 80H                     ; 3F51  E6 80
        LD L,D                      ; 3F53  6A
        RET PO                      ; 3F54  E0
        LD H,E8H                    ; 3F55  26 E8
        DB E6H                      ; 3F57  E6   (stray byte(s): disassembly boundary correction)
LOC_3F58:
        RET NZ                      ; 3F58  C0
        LD L,(HL)                   ; 3F59  6E
        SUB B                       ; 3F5A  90
        LD B,(HL)                   ; 3F5B  46
        ADD A,B                     ; 3F5C  80
        CPL                         ; 3F5D  2F
        INC H                       ; 3F5E  24
        AND (HL)                    ; 3F5F  A6
        ADD A,B                     ; 3F60  80
        LD A,00H                    ; 3F61  3E 00
        DAA                         ; 3F63  27
        DJNZ LOC_3F6C               ; 3F64  10 06
        ADD A,B                     ; 3F66  80
        LD (2600H),HL               ; 3F67  22 00 26
        DJNZ LOC_3F72               ; 3F6A  10 06
LOC_3F6C:
        ADD A,B                     ; 3F6C  80
        INC BC                      ; 3F6D  03
        DJNZ LOC_3F96               ; 3F6E  10 26
        SUB B                       ; 3F70  90
        AND (HL)                    ; 3F71  A6
LOC_3F72:
        DJNZ LOC_3F9A               ; 3F72  10 26
        DJNZ LOC_3F9C               ; 3F74  10 26
        NOP                         ; 3F76  00
        LD (2690H),HL               ; 3F77  22 90 26
        ADD A,B                     ; 3F7A  80
        INC H                       ; 3F7B  24
        ADD A,B                     ; 3F7C  80
        LD (2290H),A                ; 3F7D  32 90 22
        ADD A,B                     ; 3F80  80
        LD L,D                      ; 3F81  6A
        RET NC                      ; 3F82  D0
        XOR (HL)                    ; 3F83  AE
        RET NZ                      ; 3F84  C0
        LD C,80H                    ; 3F85  0E 80
        JP PO,WS_A680               ; 3F87  E2 80 A6
        SUB B                       ; 3F8A  90
        LD H,D                      ; 3F8B  62
        RET NZ                      ; 3F8C  C0
        LD H,(HL)                   ; 3F8D  66
        SUB B                       ; 3F8E  90
        XOR A                       ; 3F8F  AF
        LD D,B                      ; 3F90  50
        LD H,(HL)                   ; 3F91  66
        SUB B                       ; 3F92  90
        LD H,B                      ; 3F93  60
        RET NZ                      ; 3F94  C0
        LD (HL),D                   ; 3F95  72
LOC_3F96:
        RET NZ                      ; 3F96  C0
        LD H,(HL)                   ; 3F97  66
        ADD A,B                     ; 3F98  80
        DB EAH                      ; 3F99  EA   (stray byte(s): disassembly boundary correction)
LOC_3F9A:
        RET NZ                      ; 3F9A  C0
        POP DE                      ; 3F9B  D1
LOC_3F9C:
        ADD A,B                     ; 3F9C  80
        LD H,D0H                    ; 3F9D  26 D0
        LD (BC),A                   ; 3F9F  02
        ADD A,B                     ; 3FA0  80
        INC H                       ; 3FA1  24
        ADD A,B                     ; 3FA2  80
        LD H,90H                    ; 3FA3  26 90
        RLCA                        ; 3FA5  07
        NOP                         ; 3FA6  00
        INC HL                      ; 3FA7  23
        DB 10H                      ; 3FA8  10   (stray byte(s): disassembly boundary correction)
SUB_3FA9:
        LD (3FA8H),A                ; 3FA9  32 A8 3F
        LD A,E                      ; 3FAC  7B
        AND 07H                     ; 3FAD  E6 07
        ADD A,A                     ; 3FAF  87
        ADD A,A                     ; 3FB0  87
        ADD A,A                     ; 3FB1  87
        ADD A,A                     ; 3FB2  87
        LD (3FF8H),A                ; 3FB3  32 F8 3F
        LD A,E                      ; 3FB6  7B
        SRL A                       ; 3FB7  CB 3F
        SRL A                       ; 3FB9  CB 3F
        SRL A                       ; 3FBB  CB 3F
        AND 0FH                     ; 3FBD  E6 0F
        INC A                       ; 3FBF  3C
        LD (3F25H),A                ; 3FC0  32 25 3F
        LD A,E                      ; 3FC3  7B
        RLA                         ; 3FC4  17
        LD A,D                      ; 3FC5  7A
        ADC A,A                     ; 3FC6  8F
        LD C,A                      ; 3FC7  4F
        LD B,00H                    ; 3FC8  06 00
        LD HL,(WS_62CE)             ; 3FCA  2A CE 62
        INC HL                      ; 3FCD  23
        INC HL                      ; 3FCE  23
        ADD HL,BC                   ; 3FCF  09
        LD A,(HL)                   ; 3FD0  7E
        LD (3F24H),A                ; 3FD1  32 24 3F
        LD A,(DATA_3F23)            ; 3FD4  3A 23 3F
        OR A                        ; 3FD7  B7
        CALL Z,SUB_4014             ; 3FD8  CC 14 40
        DB 2AH                      ; 3FDB  2A   (stray byte(s): disassembly boundary correction)
        INC H                       ; 3FDC  24
        CCF                         ; 3FDD  3F
        EX DE,HL                    ; 3FDE  EB
        LD HL,(3F26H)               ; 3FDF  2A 26 3F
        CALL SUB_27B0               ; 3FE2  CD B0 27
        JP Z,LOC_3FF2               ; 3FE5  CA F2 3F
        LD A,(3FA8H)                ; 3FE8  3A A8 3F
        OR A                        ; 3FEB  B7
        CALL NZ,SUB_402C            ; 3FEC  C4 2C 40
        CALL SUB_4019               ; 3FEF  CD 19 40
LOC_3FF2:
        LD HL,3F28H                 ; 3FF2  21 28 3F
        LD B,00H                    ; 3FF5  06 00
        LD C,FFH                    ; 3FF7  0E FF
        ADD HL,BC                   ; 3FF9  09
        LD A,(3FA8H)                ; 3FFA  3A A8 3F
        OR A                        ; 3FFD  B7
        DB 01H,10H                  ; 3FFE  01 10   (stray byte(s): disassembly boundary correction)
LOC_4000:
        NOP                         ; 4000  00
        JP NZ,LOC_400D              ; 4001  C2 0D 40
        LD DE,6055H                 ; 4004  11 55 60
        LDIR                        ; 4007  ED B0
        LD A,0DH                    ; 4009  3E 0D
        LD (DE),A                   ; 400B  12
        RET                         ; 400C  C9
LOC_400D:
        LD DE,6180H                 ; 400D  11 80 61
        EX DE,HL                    ; 4010  EB
        LDIR                        ; 4011  ED B0
        RET                         ; 4013  C9
SUB_4014:
        LD A,01H                    ; 4014  3E 01
        LD (DATA_3F23),A            ; 4016  32 23 3F
SUB_4019:
        LD HL,(3F24H)               ; 4019  2A 24 3F
        LD (3F26H),HL               ; 401C  22 26 3F
        LD (DATA_50D4),HL           ; 401F  22 D4 50
        LD HL,3F28H                 ; 4022  21 28 3F
        LD (DATA_50D8),HL           ; 4025  22 D8 50
        CALL SUB_50BA               ; 4028  CD BA 50
        RET                         ; 402B  C9
SUB_402C:
        LD HL,(3F26H)               ; 402C  2A 26 3F
        LD (DATA_50D4),HL           ; 402F  22 D4 50
        LD HL,3F28H                 ; 4032  21 28 3F
        LD (DATA_50D8),HL           ; 4035  22 D8 50
        CALL SUB_50B5               ; 4038  CD B5 50
        RET                         ; 403B  C9
LOC_403C:
        LD A,0DH                    ; 403C  3E 0D
        LD (WS_6055),A              ; 403E  32 55 60
        LD A,01H                    ; 4041  3E 01
        JR LOC_4046                 ; 4043  18 01
LOC_4045:
        XOR A                       ; 4045  AF
LOC_4046:
        LD (4056H),A                ; 4046  32 56 40
        LD A,(WS_62B9)              ; 4049  3A B9 62
        CALL SUB_4DE1               ; 404C  CD E1 4D
        LD (HL),D                   ; 404F  72
        INC HL                      ; 4050  23
        LD BC,0008H                 ; 4051  01 08 00
        ADD HL,BC                   ; 4054  09
        LD (HL),FFH                 ; 4055  36 FF
        LD HL,6055H                 ; 4057  21 55 60
        CALL SUB_294B               ; 405A  CD 4B 29
        CALL SUB_2A74               ; 405D  CD 74 2A
        LD HL,3EF6H                 ; 4060  21 F6 3E
        JP LOC_4120                 ; 4063  C3 20 41
        LD HL,(WS_62BC)             ; 4066  2A BC 62
        JP (HL)                     ; 4069  E9
        LD HL,(WS_62CC)             ; 406A  2A CC 62
        PUSH HL                     ; 406D  E5
        LD C,(HL)                   ; 406E  4E
        INC HL                      ; 406F  23
        LD B,(HL)                   ; 4070  46
        LD HL,(WS_62CE)             ; 4071  2A CE 62
        ADD HL,BC                   ; 4074  09
LOC_4075:
        CALL SUB_4097               ; 4075  CD 97 40
        JP Z,LOC_408A               ; 4078  CA 8A 40
        LD A,(HL)                   ; 407B  7E
        INC HL                      ; 407C  23
        INC BC                      ; 407D  03
        LD (DE),A                   ; 407E  12
        INC DE                      ; 407F  13
        CP 0DH                      ; 4080  FE 0D
        JP NZ,LOC_4075              ; 4082  C2 75 40
        POP HL                      ; 4085  E1
        LD (HL),C                   ; 4086  71
        INC HL                      ; 4087  23
        LD (HL),B                   ; 4088  70
        RET                         ; 4089  C9
LOC_408A:
        LD HL,(WS_62C2)             ; 408A  2A C2 62
        LD BC,0008H                 ; 408D  01 08 00
        ADD HL,BC                   ; 4090  09
        LD (HL),C                   ; 4091  71
        POP AF                      ; 4092  F1
        EX DE,HL                    ; 4093  EB
        LD (HL),0DH                 ; 4094  36 0D
        RET                         ; 4096  C9
SUB_4097:
        PUSH HL                     ; 4097  E5
        LD HL,(WS_62CA)             ; 4098  2A CA 62
        LD A,(HL)                   ; 409B  7E
        INC HL                      ; 409C  23
        LD H,(HL)                   ; 409D  66
        LD L,A                      ; 409E  6F
        XOR A                       ; 409F  AF
        SBC HL,BC                   ; 40A0  ED 42
        POP HL                      ; 40A2  E1
        RET Z                       ; 40A3  C8
LOC_40A4:
        LD A,7EH                    ; 40A4  3E 7E
        CP C                        ; 40A6  B9
        RET NZ                      ; 40A7  C0
        PUSH DE                     ; 40A8  D5
        LD HL,(WS_62CA)             ; 40A9  2A CA 62
        LD E,(HL)                   ; 40AC  5E
        INC HL                      ; 40AD  23
        LD D,(HL)                   ; 40AE  56
        DEC HL                      ; 40AF  2B
        EX DE,HL                    ; 40B0  EB
        XOR A                       ; 40B1  AF
        SBC HL,BC                   ; 40B2  ED 42
        EX DE,HL                    ; 40B4  EB
        LD (HL),E                   ; 40B5  73
        INC HL                      ; 40B6  23
        LD (HL),D                   ; 40B7  72
        INC HL                      ; 40B8  23
        CALL SUB_2A2B               ; 40B9  CD 2B 2A
        LD HL,(WS_62CE)             ; 40BC  2A CE 62
        LD (DATA_50D8),HL           ; 40BF  22 D8 50
        LD HL,(WS_62C8)             ; 40C2  2A C8 62
        LD E,(HL)                   ; 40C5  5E
        INC HL                      ; 40C6  23
        LD D,(HL)                   ; 40C7  56
        LD (DATA_50D4),DE           ; 40C8  ED 53 D4 50
        PUSH HL                     ; 40CC  E5
        CALL SUB_50BA               ; 40CD  CD BA 50
        LD HL,(WS_62D0)             ; 40D0  2A D0 62
        LD E,(HL)                   ; 40D3  5E
        INC HL                      ; 40D4  23
        LD D,(HL)                   ; 40D5  56
        POP HL                      ; 40D6  E1
        LD (HL),D                   ; 40D7  72
        DEC HL                      ; 40D8  2B
        LD (HL),E                   ; 40D9  73
        LD BC,0000H                 ; 40DA  01 00 00
        LD HL,(WS_62CE)             ; 40DD  2A CE 62
        POP DE                      ; 40E0  D1
        JP LOC_40A4                 ; 40E1  C3 A4 40
DATA_40E4:
        LD E,D                      ; 40E4  5A
        LD H,B                      ; 40E5  60
LOC_40E6:
        LD A,(WS_62B9)              ; 40E6  3A B9 62
        OR A                        ; 40E9  B7
        JP M,LOC_4178               ; 40EA  FA 78 41
        LD HL,(DATA_40E4)           ; 40ED  2A E4 40
        CALL SUB_294B               ; 40F0  CD 4B 29
        LD DE,6055H                 ; 40F3  11 55 60
        PUSH DE                     ; 40F6  D5
        INC BC                      ; 40F7  03
        LDIR                        ; 40F8  ED B0
        POP HL                      ; 40FA  E1
        LD (DATA_40E4),HL           ; 40FB  22 E4 40
        CALL SUB_277B               ; 40FE  CD 7B 27
        CP 0DH                      ; 4101  FE 0D
        JP Z,LOC_3E9E               ; 4103  CA 9E 3E
        CALL SUB_27D2               ; 4106  CD D2 27
        INC L                       ; 4109  2C
        RLA                         ; 410A  17
        LD B,C                      ; 410B  41
        PUSH HL                     ; 410C  E5
        LD DE,4169H                 ; 410D  11 69 41
        CALL SUB_2A59               ; 4110  CD 59 2A
        POP HL                      ; 4113  E1
        JP LOC_411A                 ; 4114  C3 1A 41
        CALL SUB_2A59               ; 4117  CD 59 2A
LOC_411A:
        LD (DATA_40E4),HL           ; 411A  22 E4 40
        LD HL,40E6H                 ; 411D  21 E6 40
LOC_4120:
        PUSH HL                     ; 4120  E5
        CALL SUB_2B09               ; 4121  CD 09 2B
        LD HL,(CUR_STMT)            ; 4124  2A 27 65
        CALL SUB_1DBE               ; 4127  CD BE 1D
        CALL SUB_1BDF               ; 412A  CD DF 1B
        LD (CUR_STMT),HL            ; 412D  22 27 65
        CALL SUB_2B0E               ; 4130  CD 0E 2B
LOC_4133:
        CALL SUB_1453               ; 4133  CD 53 14
        LD C,H                      ; 4136  4C
        LD B,C                      ; 4137  41
        LD HL,(CUR_STMT)            ; 4138  2A 27 65
        CALL SUB_2981               ; 413B  CD 81 29
        JR NZ,LOC_4144              ; 413E  20 04
        POP AF                      ; 4140  F1
        JP LOC_122A                 ; 4141  C3 2A 12
LOC_4144:
        CALL SUB_27E1               ; 4144  CD E1 27
        INC L                       ; 4147  2C
        LD (CUR_STMT),HL            ; 4148  22 27 65
        RET                         ; 414B  C9
        LD DE,(WS_6170)             ; 414C  ED 5B 70 61
        CALL SUB_2959               ; 4150  CD 59 29
        EX DE,HL                    ; 4153  EB
        CALL SUB_27D2               ; 4154  CD D2 27
        DEC C                       ; 4157  0D
        LD E,L                      ; 4158  5D
        LD B,C                      ; 4159  41
        LD HL,4168H                 ; 415A  21 68 41
        CALL SUB_2AA0               ; 415D  CD A0 2A
        LD A,(HL)                   ; 4160  7E
        INC HL                      ; 4161  23
        CALL SUB_2B09               ; 4162  CD 09 2B
        JP LOC_4133                 ; 4165  C3 33 41
        JR NC,LOC_4177              ; 4168  30 0D
        CP (HL)                     ; 416A  BE
        JP P,LOC_22BE               ; 416B  F2 BE 22
        DAA                         ; 416E  27
        LD H,L                      ; 416F  65
        LD A,80H                    ; 4170  3E 80
        LD (WS_62B9),A              ; 4172  32 B9 62
        DB CDH,2AH                  ; 4175  CD 2A   (stray byte(s): disassembly boundary correction)
LOC_4177:
        DEC HL                      ; 4177  2B
LOC_4178:
        LD A,(WS_6179)              ; 4178  3A 79 61
        OR A                        ; 417B  B7
        CALL Z,SUB_41A1             ; 417C  CC A1 41
        LD HL,(WS_617A)             ; 417F  2A 7A 61
        CALL SUB_2981               ; 4182  CD 81 29
        JR NZ,LOC_418D              ; 4185  20 06
        CALL SUB_41C3               ; 4187  CD C3 41
        JP LOC_4178                 ; 418A  C3 78 41
LOC_418D:
        CALL SUB_2A59               ; 418D  CD 59 2A
        CALL SUB_27D2               ; 4190  CD D2 27
        INC L                       ; 4193  2C
        SUB (HL)                    ; 4194  96
        LD B,C                      ; 4195  41
        LD (WS_617A),HL             ; 4196  22 7A 61
        LD HL,6055H                 ; 4199  21 55 60
        LD (HL),0DH                 ; 419C  36 0D
        JP LOC_411A                 ; 419E  C3 1A 41
SUB_41A1:
        LD HL,652CH                 ; 41A1  21 2C 65
LOC_41A4:
        XOR A                       ; 41A4  AF
        LD (WS_6179),A              ; 41A5  32 79 61
LOC_41A8:
        LD A,(HL)                   ; 41A8  7E
        INC HL                      ; 41A9  23
        OR (HL)                     ; 41AA  B6
        JP Z,LOC_23CE               ; 41AB  CA CE 23
        INC HL                      ; 41AE  23
        INC HL                      ; 41AF  23
        INC HL                      ; 41B0  23
LOC_41B1:
        CALL SUB_27D2               ; 41B1  CD D2 27
        ADD A,C                     ; 41B4  81
        RET NZ                      ; 41B5  C0
        LD B,C                      ; 41B6  41
        LD (WS_617A),HL             ; 41B7  22 7A 61
        LD A,01H                    ; 41BA  3E 01
        LD (WS_6179),A              ; 41BC  32 79 61
        RET                         ; 41BF  C9
        CALL SUB_278B               ; 41C0  CD 8B 27
SUB_41C3:
        INC HL                      ; 41C3  23
        CP 3AH                      ; 41C4  FE 3A
        JP Z,LOC_41B1               ; 41C6  CA B1 41
        JP LOC_41A8                 ; 41C9  C3 A8 41
        LD A,02H                    ; 41CC  3E 02
        LD (WS_62BA),A              ; 41CE  32 BA 62
        LD A,04H                    ; 41D1  3E 04
        JP LOC_41E1                 ; 41D3  C3 E1 41
        LD (BC),A                   ; 41D6  02
        LD A,01H                    ; 41D7  3E 01
        JR LOC_41DC                 ; 41D9  18 01
        XOR A                       ; 41DB  AF
LOC_41DC:
        LD (WS_62BA),A              ; 41DC  32 BA 62
        LD A,03H                    ; 41DF  3E 03
LOC_41E1:
        LD (DATA_5146),A            ; 41E1  32 46 51
        CALL SUB_4DC0               ; 41E4  CD C0 4D
        JP Z,LOC_2442               ; 41E7  CA 42 24
        CALL SUB_2B2A               ; 41EA  CD 2A 2B
        CALL SUB_515A               ; 41ED  CD 5A 51
        LD (CUR_STMT),HL            ; 41F0  22 27 65
        LD A,(WS_62BB)              ; 41F3  3A BB 62
        OR A                        ; 41F6  B7
        JP NZ,LOC_423D              ; 41F7  C2 3D 42
        LD HL,62D7H                 ; 41FA  21 D7 62
        LD DE,0009H                 ; 41FD  11 09 00
        LD BC,0000H                 ; 4200  01 00 00
LOC_4203:
        LD A,(HL)                   ; 4203  7E
        OR A                        ; 4204  B7
        JP Z,LOC_4235               ; 4205  CA 35 42
        PUSH HL                     ; 4208  E5
        INC HL                      ; 4209  23
        LD A,(WS_62BA)              ; 420A  3A BA 62
        OR (HL)                     ; 420D  B6
        JP Z,LOC_4234               ; 420E  CA 34 42
        INC HL                      ; 4211  23
        LD A,(HL)                   ; 4212  7E
        OR A                        ; 4213  B7
        JP NZ,LOC_4234              ; 4214  C2 34 42
        INC HL                      ; 4217  23
        LD A,(WS_62BC)              ; 4218  3A BC 62
        CP (HL)                     ; 421B  BE
        JP NZ,LOC_4234              ; 421C  C2 34 42
        PUSH DE                     ; 421F  D5
        PUSH BC                     ; 4220  C5
        LD HL,6344H                 ; 4221  21 44 63
        ADD HL,BC                   ; 4224  09
        ADD HL,BC                   ; 4225  09
        LD A,(HL)                   ; 4226  7E
        INC HL                      ; 4227  23
        LD H,(HL)                   ; 4228  66
        LD L,A                      ; 4229  6F
        INC HL                      ; 422A  23
        INC HL                      ; 422B  23
        CALL SUB_5048               ; 422C  CD 48 50
        JP Z,LOC_23EE               ; 422F  CA EE 23
        POP BC                      ; 4232  C1
        POP DE                      ; 4233  D1
LOC_4234:
        POP HL                      ; 4234  E1
LOC_4235:
        ADD HL,DE                   ; 4235  19
        INC C                       ; 4236  0C
        LD A,0AH                    ; 4237  3E 0A
        CP C                        ; 4239  B9
        JP NZ,LOC_4203              ; 423A  C2 03 42
LOC_423D:
        LD A,(WS_62B9)              ; 423D  3A B9 62
        CALL SUB_4DE1               ; 4240  CD E1 4D
        LD C,B                      ; 4243  48
        LD B,D                      ; 4244  42
        JP LOC_242E                 ; 4245  C3 2E 24
        XOR A                       ; 4248  AF
        LD (DATA_4272),A            ; 4249  32 72 42
        CALL SUB_4DE1               ; 424C  CD E1 4D
        LD A,(WS_CD24)              ; 424F  3A 24 CD
        LD (HL),E                   ; 4252  73
        LD B,D                      ; 4253  42
        JP LOC_122A                 ; 4254  C3 2A 12
SUB_4257:
        LD A,02H                    ; 4257  3E 02
        LD (DATA_5146),A            ; 4259  32 46 51
        LD A,01H                    ; 425C  3E 01
        JR LOC_4264                 ; 425E  18 04
SUB_4260:
        XOR A                       ; 4260  AF
        LD (DATA_5146),A            ; 4261  32 46 51
LOC_4264:
        LD (DATA_4272),A            ; 4264  32 72 42
        CALL SUB_4851               ; 4267  CD 51 48
        LD HL,6331H                 ; 426A  21 31 63
        LD A,0AH                    ; 426D  3E 0A
        JP LOC_4273                 ; 426F  C3 73 42
DATA_4272:
        DB 21H                      ; 4272  21   (stray byte(s): disassembly boundary correction)
LOC_4273:
        LD DE,62B8H                 ; 4273  11 B8 62
        LD (DE),A                   ; 4276  12
        INC DE                      ; 4277  13
        LD BC,0009H                 ; 4278  01 09 00
        EX DE,HL                    ; 427B  EB
        LDIR                        ; 427C  ED B0
        CALL SUB_4E21               ; 427E  CD 21 4E
        LD A,(WS_62BB)              ; 4281  3A BB 62
        OR A                        ; 4284  B7
        JP NZ,LOC_4296              ; 4285  C2 96 42
        LD HL,(VAR_PTR)             ; 4288  2A C6 62
        INC HL                      ; 428B  23
        INC HL                      ; 428C  23
        EX DE,HL                    ; 428D  EB
        LD HL,5146H                 ; 428E  21 46 51
        LD BC,0011H                 ; 4291  01 11 00
        LDIR                        ; 4294  ED B0
LOC_4296:
        LD A,(WS_62BA)              ; 4296  3A BA 62
        OR A                        ; 4299  B7
        LD HL,42AFH                 ; 429A  21 AF 42
        JP Z,LOC_42A8               ; 429D  CA A8 42
        LD HL,42B3H                 ; 42A0  21 B3 42
        CP 02H                      ; 42A3  FE 02
        JP Z,LOC_42B9               ; 42A5  CA B9 42
LOC_42A8:
        LD A,(WS_62BB)              ; 42A8  3A BB 62
        CALL SUB_4F62               ; 42AB  CD 62 4F
        JP (HL)                     ; 42AE  E9
        LD HL,B743H                 ; 42AF  21 43 B7
        LD B,D                      ; 42B2  42
        ADC A,H                     ; 42B3  8C
        LD B,E                      ; 42B4  43
        CP B                        ; 42B5  B8
        LD B,D                      ; 42B6  42
        RET                         ; 42B7  C9
        RET                         ; 42B8  C9
LOC_42B9:
        CALL SUB_4FAC               ; 42B9  CD AC 4F
        CALL SUB_4FF7               ; 42BC  CD F7 4F
        CALL NZ,WS_C342             ; 42BF  C4 42 C3
        LD C,24H                    ; 42C2  0E 24
        JP Z,LOC_42EF               ; 42C4  CA EF 42
        CALL SUB_5048               ; 42C7  CD 48 50
        RET NZ                      ; 42CA  C0
        POP AF                      ; 42CB  F1
        LD A,(HL)                   ; 42CC  7E
        CP 04H                      ; 42CD  FE 04
        JP NZ,LOC_243E              ; 42CF  C2 3E 24
        LD DE,(VAR_PTR)             ; 42D2  ED 5B C6 62
        INC DE                      ; 42D6  13
        INC DE                      ; 42D7  13
        LD BC,0040H                 ; 42D8  01 40 00
        LDIR                        ; 42DB  ED B0
        DEC HL                      ; 42DD  2B
        LD D,(HL)                   ; 42DE  56
        DEC HL                      ; 42DF  2B
        LD E,(HL)                   ; 42E0  5E
        LD (DATA_50D4),DE           ; 42E1  ED 53 D4 50
        LD HL,(WS_62CE)             ; 42E5  2A CE 62
        LD (DATA_50D8),HL           ; 42E8  22 D8 50
        CALL SUB_50BA               ; 42EB  CD BA 50
        RET                         ; 42EE  C9
LOC_42EF:
        POP AF                      ; 42EF  F1
        PUSH HL                     ; 42F0  E5
        CALL SUB_50DD               ; 42F1  CD DD 50
        LD HL,(VAR_PTR)             ; 42F4  2A C6 62
        LD BC,0040H                 ; 42F7  01 40 00
        ADD HL,BC                   ; 42FA  09
        LD (HL),E                   ; 42FB  73
        INC HL                      ; 42FC  23
        LD (HL),D                   ; 42FD  72
        POP HL                      ; 42FE  E1
        PUSH DE                     ; 42FF  D5
        EX DE,HL                    ; 4300  EB
        LD HL,(VAR_PTR)             ; 4301  2A C6 62
        INC HL                      ; 4304  23
        INC HL                      ; 4305  23
        LD BC,0040H                 ; 4306  01 40 00
        LDIR                        ; 4309  ED B0
        CALL SUB_50B5               ; 430B  CD B5 50
        POP HL                      ; 430E  E1
        PUSH HL                     ; 430F  E5
        LD (DATA_50D4),HL           ; 4310  22 D4 50
        LD HL,(WS_62CE)             ; 4313  2A CE 62
        LD (DATA_50D8),HL           ; 4316  22 D8 50
        CALL SUB_50B5               ; 4319  CD B5 50
        POP HL                      ; 431C  E1
        CALL SUB_4EF2               ; 431D  CD F2 4E
        RET                         ; 4320  C9
        CALL SUB_4FAC               ; 4321  CD AC 4F
        LD A,(DATA_4272)            ; 4324  3A 72 42
        OR A                        ; 4327  B7
        JP NZ,LOC_4333              ; 4328  C2 33 43
        CALL SUB_4FF7               ; 432B  CD F7 4F
        LD B,A                      ; 432E  47
        LD B,E                      ; 432F  43
        JP LOC_23E2                 ; 4330  C3 E2 23
LOC_4333:
        LD HL,1003H                 ; 4333  21 03 10
        LD (DATA_50D4),HL           ; 4336  22 D4 50
        LD HL,10F0H                 ; 4339  21 F0 10
        LD (DATA_50D8),HL           ; 433C  22 D8 50
        PUSH HL                     ; 433F  E5
        CALL SUB_50BA               ; 4340  CD BA 50
        POP HL                      ; 4343  E1
        JP LOC_435A                 ; 4344  C3 5A 43
        JP Z,LOC_23E2               ; 4347  CA E2 23
        CALL SUB_5048               ; 434A  CD 48 50
        RET NZ                      ; 434D  C0
        LD A,(DATA_5146)            ; 434E  3A 46 51
        OR A                        ; 4351  B7
        JP Z,LOC_4359               ; 4352  CA 59 43
        CP (HL)                     ; 4355  BE
        JP NZ,LOC_243E              ; 4356  C2 3E 24
LOC_4359:
        POP AF                      ; 4359  F1
LOC_435A:
        EX DE,HL                    ; 435A  EB
        LD HL,(VAR_PTR)             ; 435B  2A C6 62
        INC HL                      ; 435E  23
        INC HL                      ; 435F  23
        LD BC,0040H                 ; 4360  01 40 00
        EX DE,HL                    ; 4363  EB
        LDIR                        ; 4364  ED B0
        EX DE,HL                    ; 4366  EB
        DEC HL                      ; 4367  2B
        LD D,(HL)                   ; 4368  56
        DEC HL                      ; 4369  2B
        LD E,(HL)                   ; 436A  5E
        LD HL,(WS_62C8)             ; 436B  2A C8 62
        LD (HL),E                   ; 436E  73
        INC HL                      ; 436F  23
        LD (HL),D                   ; 4370  72
        INC HL                      ; 4371  23
        PUSH HL                     ; 4372  E5
        LD HL,(VAR_PTR)             ; 4373  2A C6 62
        LD BC,0014H                 ; 4376  01 14 00
        ADD HL,BC                   ; 4379  09
        LD E,(HL)                   ; 437A  5E
        INC HL                      ; 437B  23
        LD D,(HL)                   ; 437C  56
        EX DE,HL                    ; 437D  EB
        LD BC,007EH                 ; 437E  01 7E 00
        ADD HL,BC                   ; 4381  09
        EX DE,HL                    ; 4382  EB
        POP HL                      ; 4383  E1
        LD (HL),E                   ; 4384  73
        INC HL                      ; 4385  23
        LD (HL),D                   ; 4386  72
        INC HL                      ; 4387  23
        LD (HL),C                   ; 4388  71
        INC HL                      ; 4389  23
        LD (HL),B                   ; 438A  70
        RET                         ; 438B  C9
        CALL SUB_4FAC               ; 438C  CD AC 4F
        LD A,(DATA_4272)            ; 438F  3A 72 42
        OR A                        ; 4392  B7
        JP NZ,LOC_439F              ; 4393  C2 9F 43
        CALL SUB_4FF7               ; 4396  CD F7 4F
        OR D                        ; 4399  B2
        LD B,E                      ; 439A  43
        JP LOC_240E                 ; 439B  C3 0E 24
LOC_439E:
        POP AF                      ; 439E  F1
LOC_439F:
        CALL SUB_50DD               ; 439F  CD DD 50
        LD HL,(VAR_PTR)             ; 43A2  2A C6 62
        LD BC,0040H                 ; 43A5  01 40 00
        CALL SUB_43AD               ; 43A8  CD AD 43
        LD C,09H                    ; 43AB  0E 09
SUB_43AD:
        ADD HL,BC                   ; 43AD  09
        LD (HL),E                   ; 43AE  73
        INC HL                      ; 43AF  23
        LD (HL),D                   ; 43B0  72
        RET                         ; 43B1  C9
        JP Z,LOC_439E               ; 43B2  CA 9E 43
        CALL SUB_5048               ; 43B5  CD 48 50
        RET NZ                      ; 43B8  C0
        JP LOC_23EA                 ; 43B9  C3 EA 23
        CALL SUB_27D2               ; 43BC  CD D2 27
        CP A                        ; 43BF  BF
        LD E,C                      ; 43C0  59
        LD B,H                      ; 43C1  44
        CALL SUB_27E1               ; 43C2  CD E1 27
        LD D,H                      ; 43C5  54
        CALL SUB_2B1F               ; 43C6  CD 1F 2B
        LD BC,43D0H                 ; 43C9  01 D0 43
        PUSH BC                     ; 43CC  C5
        JP LOC_45D1                 ; 43CD  C3 D1 45
LOC_43D0:
        CALL ROPEN                  ; 43D0  CD 27 00
        JP C,LOC_2354               ; 43D3  DA 54 23
        CALL SUB_4422               ; 43D6  CD 22 44
        LD HL,10F0H                 ; 43D9  21 F0 10
        LD A,(HL)                   ; 43DC  7E
        CP 02H                      ; 43DD  FE 02
        JP NZ,LOC_43D0              ; 43DF  C2 D0 43
        LD DE,5147H                 ; 43E2  11 47 51
        LD A,(DE)                   ; 43E5  1A
        CP 0DH                      ; 43E6  FE 0D
        JP Z,LOC_43F1               ; 43E8  CA F1 43
        CALL SUB_5048               ; 43EB  CD 48 50
        JP NZ,LOC_43D0              ; 43EE  C2 D0 43
LOC_43F1:
        CALL SUB_298A               ; 43F1  CD 8A 29
        LD HL,(EADRS)               ; 43F4  2A 02 11
        DEC HL                      ; 43F7  2B
        DEC HL                      ; 43F8  2B
        LD C,L                      ; 43F9  4D
        LD B,H                      ; 43FA  44
        LD DE,652CH                 ; 43FB  11 2C 65
        CALL SUB_28D4               ; 43FE  CD D4 28
        CALL SUB_2A31               ; 4401  CD 31 2A
        LD (SADRS),DE               ; 4404  ED 53 04 11
        CALL SUB_4427               ; 4408  CD 27 44
        CALL READ                   ; 440B  CD 2A 00
        JP C,LOC_4417               ; 440E  DA 17 44
        CALL SUB_4978               ; 4411  CD 78 49
        JP LOC_122A                 ; 4414  C3 2A 12
LOC_4417:
        PUSH AF                     ; 4417  F5
        CALL SUB_4867               ; 4418  CD 67 48
        POP AF                      ; 441B  F1
        JP Z,LOC_245A               ; 441C  CA 5A 24
        JP LOC_2354                 ; 441F  C3 54 23
SUB_4422:
        LD DE,4447H                 ; 4422  11 47 44
        JR LOC_442A                 ; 4425  18 03
SUB_4427:
        LD DE,444EH                 ; 4427  11 4E 44
LOC_442A:
        CALL SUB_2335               ; 442A  CD 35 23
        LD DE,10F1H                 ; 442D  11 F1 10
        LD A,(DE)                   ; 4430  1A
        CP 0DH                      ; 4431  FE 0D
        RET Z                       ; 4433  C8
        PUSH DE                     ; 4434  D5
        CALL SUB_4441               ; 4435  CD 41 44
        POP DE                      ; 4438  D1
        LD A,0DH                    ; 4439  3E 0D
        LD (MON_1101),A             ; 443B  32 01 11
        CALL MON_MESSAGE            ; 443E  CD 15 00
SUB_4441:
        LD DE,4457H                 ; 4441  11 57 44
        JP MON_MESSAGE              ; 4444  C3 15 00
        LD B,(HL)                   ; 4447  46
        LD C,A                      ; 4448  4F
        LD D,L                      ; 4449  55
        LD C,(HL)                   ; 444A  4E
        LD B,H                      ; 444B  44
        JR NZ,LOC_445B              ; 444C  20 0D
        LD C,H                      ; 444E  4C
        LD C,A                      ; 444F  4F
        LD B,C                      ; 4450  41
        LD B,H                      ; 4451  44
        LD C,C                      ; 4452  49
        LD C,(HL)                   ; 4453  4E
        LD B,A                      ; 4454  47
        JR NZ,LOC_4464              ; 4455  20 0D
        LD (WS_CD0D),HL             ; 4457  22 0D CD
        DB CAH                      ; 445A  CA   (stray byte(s): disassembly boundary correction)
LOC_445B:
        LD B,A                      ; 445B  47
        XOR A                       ; 445C  AF
        LD (WS_62BA),A              ; 445D  32 BA 62
        CALL SUB_47B5               ; 4460  CD B5 47
        DB 2AH                      ; 4463  2A   (stray byte(s): disassembly boundary correction)
LOC_4464:
        ADD A,62H                   ; 4464  C6 62
        INC HL                      ; 4466  23
        INC HL                      ; 4467  23
        LD A,(HL)                   ; 4468  7E
        CP 02H                      ; 4469  FE 02
        JP NZ,LOC_44AE              ; 446B  C2 AE 44
        CALL SUB_2B1F               ; 446E  CD 1F 2B
LOC_4471:
        CALL SUB_47CF               ; 4471  CD CF 47
LOC_4474:
        CALL SUB_483E               ; 4474  CD 3E 48
        CALL SUB_2B1A               ; 4477  CD 1A 2B
        CALL SUB_234F               ; 447A  CD 4F 23
        CALL SUB_4807               ; 447D  CD 07 48
        CALL SUB_4867               ; 4480  CD 67 48
        CALL SUB_47D9               ; 4483  CD D9 47
        CALL SUB_4848               ; 4486  CD 48 48
        CALL SUB_4E21               ; 4489  CD 21 4E
        CALL SUB_4701               ; 448C  CD 01 47
        CALL SUB_4851               ; 448F  CD 51 48
        CALL SUB_4E86               ; 4492  CD 86 4E
        LD A,(47C5H)                ; 4495  3A C5 47
        OR A                        ; 4498  B7
        JP Z,LOC_122A               ; 4499  CA 2A 12
        LD HL,(WS_652C)             ; 449C  2A 2C 65
        LD A,H                      ; 449F  7C
        OR L                        ; 44A0  B5
        JP Z,LOC_2245               ; 44A1  CA 45 22
        LD HL,(WS_652E)             ; 44A4  2A 2E 65
        CALL SUB_288B               ; 44A7  CD 8B 28
        EX DE,HL                    ; 44AA  EB
        JP LOC_151B                 ; 44AB  C3 1B 15
LOC_44AE:
        CP 01H                      ; 44AE  FE 01
        JP NZ,LOC_243E              ; 44B0  C2 3E 24
        LD HL,(VAR_PTR)             ; 44B3  2A C6 62
        LD BC,0014H                 ; 44B6  01 14 00
        ADD HL,BC                   ; 44B9  09
        LD C,(HL)                   ; 44BA  4E
        INC HL                      ; 44BB  23
        LD B,(HL)                   ; 44BC  46
        INC HL                      ; 44BD  23
        LD E,(HL)                   ; 44BE  5E
        INC HL                      ; 44BF  23
        LD D,(HL)                   ; 44C0  56
        PUSH DE                     ; 44C1  D5
        LD HL,(WS_6165)             ; 44C2  2A 65 61
        EX DE,HL                    ; 44C5  EB
        CALL SUB_27B0               ; 44C6  CD B0 27
        JP C,LOC_23B6               ; 44C9  DA B6 23
        ADD HL,BC                   ; 44CC  09
        EX DE,HL                    ; 44CD  EB
        LD HL,(WS_6163)             ; 44CE  2A 63 61
        CALL SUB_27B0               ; 44D1  CD B0 27
        JP C,LOC_2386               ; 44D4  DA 86 23
        POP DE                      ; 44D7  D1
        CALL SUB_47A2               ; 44D8  CD A2 47
        CALL SUB_4851               ; 44DB  CD 51 48
        CALL SUB_4E86               ; 44DE  CD 86 4E
        JP LOC_122A                 ; 44E1  C3 2A 12
        CALL SUB_2B2A               ; 44E4  CD 2A 2B
LOC_44E7:
        PUSH HL                     ; 44E7  E5
        CALL SUB_47C6               ; 44E8  CD C6 47
        CALL SUB_4807               ; 44EB  CD 07 48
        XOR A                       ; 44EE  AF
        LD (WS_62BA),A              ; 44EF  32 BA 62
        POP HL                      ; 44F2  E1
        CALL SUB_47B5               ; 44F3  CD B5 47
        LD HL,(VAR_PTR)             ; 44F6  2A C6 62
        INC HL                      ; 44F9  23
        INC HL                      ; 44FA  23
        LD A,(HL)                   ; 44FB  7E
        CP 02H                      ; 44FC  FE 02
        JP NZ,LOC_243E              ; 44FE  C2 3E 24
        CALL SUB_47D3               ; 4501  CD D3 47
        JP LOC_4474                 ; 4504  C3 74 44
LOC_4507:
        CALL SUB_515A               ; 4507  CD 5A 51
        LD (CUR_STMT),HL            ; 450A  22 27 65
        LD A,(WS_62BB)              ; 450D  3A BB 62
        OR A                        ; 4510  B7
        JP NZ,LOC_2372              ; 4511  C2 72 23
        CALL SUB_47C6               ; 4514  CD C6 47
        XOR A                       ; 4517  AF
        LD (DATA_13FE),A            ; 4518  32 FE 13
        CALL SUB_2B1F               ; 451B  CD 1F 2B
        CALL SUB_298A               ; 451E  CD 8A 29
        XOR A                       ; 4521  AF
        LD (WS_62BA),A              ; 4522  32 BA 62
        CALL SUB_4260               ; 4525  CD 60 42
        LD HL,(WS_6163)             ; 4528  2A 63 61
        LD (WS_6165),HL             ; 452B  22 65 61
        LD SP,HL                    ; 452E  F9
        LD HL,(VAR_PTR)             ; 452F  2A C6 62
        INC HL                      ; 4532  23
        INC HL                      ; 4533  23
        LD A,(HL)                   ; 4534  7E
        CP 02H                      ; 4535  FE 02
        JP Z,LOC_4471               ; 4537  CA 71 44
        CP 01H                      ; 453A  FE 01
        JP NZ,LOC_243E              ; 453C  C2 3E 24
        LD HL,(VAR_PTR)             ; 453F  2A C6 62
        DB 01H,14H                  ; 4542  01 14   (stray byte(s): disassembly boundary correction)
        NOP                         ; 4544  00
        ADD HL,BC                   ; 4545  09
        LD C,(HL)                   ; 4546  4E
        INC HL                      ; 4547  23
        LD B,(HL)                   ; 4548  46
        INC HL                      ; 4549  23
        DB CDH,AAH                  ; 454A  CD AA   (stray byte(s): disassembly boundary correction)
        JR Z,LOC_45AC               ; 454C  28 5E
        INC HL                      ; 454E  23
        LD D,(HL)                   ; 454F  56
        INC HL                      ; 4550  23
        LD A,(HL)                   ; 4551  7E
        INC HL                      ; 4552  23
        LD H,(HL)                   ; 4553  66
        LD L,A                      ; 4554  6F
        OR H                        ; 4555  B4
        JR NZ,LOC_455A              ; 4556  20 02
        LD L,E                      ; 4558  6B
        LD H,D                      ; 4559  62
LOC_455A:
        LD A,H                      ; 455A  7C
        CP 12H                      ; 455B  FE 12
        JP C,LOC_2372               ; 455D  DA 72 23
        LD (45AFH),HL               ; 4560  22 AF 45
        LD HL,B0EDH                 ; 4563  21 ED B0
        LD (45A1H),HL               ; 4566  22 A1 45
        LD HL,(FREE_PTR)            ; 4569  2A 6A 63
        CALL SUB_27B0               ; 456C  CD B0 27
        CALL C,SUB_45B1             ; 456F  DC B1 45
        LD (459FH),HL               ; 4572  22 9F 45
        EX DE,HL                    ; 4575  EB
        LD (459CH),HL               ; 4576  22 9C 45
        LD L,C                      ; 4579  69
        LD H,B                      ; 457A  60
        LD (4599H),HL               ; 457B  22 99 45
        LD BC,001EH                 ; 457E  01 1E 00
        LD DE,11A3H                 ; 4581  11 A3 11
        LD HL,4598H                 ; 4584  21 98 45
        LDIR                        ; 4587  ED B0
        LD HL,(FREE_PTR)            ; 4589  2A 6A 63
        EX DE,HL                    ; 458C  EB
        CALL SUB_47A2               ; 458D  CD A2 47
        CALL SUB_5204               ; 4590  CD 04 52
        JP LBUF                     ; 4593  C3 A3 11
        LD D,0DH                    ; 4596  16 0D
        LD BC,FFFFH                 ; 4598  01 FF FF
        LD DE,FFFFH                 ; 459B  11 FF FF
        LD HL,FFFFH                 ; 459E  21 FF FF
        LD L,H                      ; 45A1  6C
        DEC H                       ; 45A2  25
        LD SP,10F0H                 ; 45A3  31 F0 10
        LD A,16H                    ; 45A6  3E 16
        CALL MON_VIDEO              ; 45A8  CD 12 00
        CALL BELL                   ; 45AB  CD 3E 00
        JP WS_FFFF                  ; 45AE  C3 FF FF
SUB_45B1:
        PUSH HL                     ; 45B1  E5
        LD HL,B8EDH                 ; 45B2  21 ED B8
        LD (45A1H),HL               ; 45B5  22 A1 45
        POP HL                      ; 45B8  E1
        ADD HL,BC                   ; 45B9  09
        EX DE,HL                    ; 45BA  EB
        ADD HL,BC                   ; 45BB  09
        EX DE,HL                    ; 45BC  EB
        DEC HL                      ; 45BD  2B
        DEC DE                      ; 45BE  1B
        RET                         ; 45BF  C9
        CALL SUB_2B1F               ; 45C0  CD 1F 2B
        CALL SUB_27D2               ; 45C3  CD D2 27
        CP A                        ; 45C6  BF
        LD C,D                      ; 45C7  4A
        LD B,(HL)                   ; 45C8  46
        CALL SUB_27E1               ; 45C9  CD E1 27
        LD D,H                      ; 45CC  54
        LD BC,460FH                 ; 45CD  01 0F 46
        PUSH BC                     ; 45D0  C5
LOC_45D1:
        CALL SUB_27D2               ; 45D1  CD D2 27
        INC L                       ; 45D4  2C
        RST 10H                     ; 45D5  D7
        LD B,L                      ; 45D6  45
        PUSH HL                     ; 45D7  E5
        LD HL,5146H                 ; 45D8  21 46 51
        LD (HL),02H                 ; 45DB  36 02
        LD B,10H                    ; 45DD  06 10
LOC_45DF:
        INC HL                      ; 45DF  23
        LD (HL),0DH                 ; 45E0  36 0D
        DJNZ LOC_45DF               ; 45E2  10 FB
        POP HL                      ; 45E4  E1
        CALL SUB_2981               ; 45E5  CD 81 29
        LD (CUR_STMT),HL            ; 45E8  22 27 65
        RET Z                       ; 45EB  C8
        CALL SUB_1A58               ; 45EC  CD 58 1A
        CALL SUB_2981               ; 45EF  CD 81 29
        JP NZ,LOC_2372              ; 45F2  C2 72 23
        LD (CUR_STMT),HL            ; 45F5  22 27 65
        LD A,D                      ; 45F8  7A
        OR A                        ; 45F9  B7
        JP Z,LOC_2432               ; 45FA  CA 32 24
        CALL SUB_2959               ; 45FD  CD 59 29
        LD A,C                      ; 4600  79
        OR A                        ; 4601  B7
        RET Z                       ; 4602  C8
        CP 11H                      ; 4603  FE 11
        JP NC,LOC_2432              ; 4605  D2 32 24
        EX DE,HL                    ; 4608  EB
        LD DE,5147H                 ; 4609  11 47 51
        LDIR                        ; 460C  ED B0
        RET                         ; 460E  C9
        LD DE,10F0H                 ; 460F  11 F0 10
        LD HL,5146H                 ; 4612  21 46 51
        LD BC,0011H                 ; 4615  01 11 00
        LDIR                        ; 4618  ED B0
        LD B,6FH                    ; 461A  06 6F
LOC_461C:
        XOR A                       ; 461C  AF
        LD (DE),A                   ; 461D  12
        INC DE                      ; 461E  13
        DJNZ LOC_461C               ; 461F  10 FB
        LD HL,652CH                 ; 4621  21 2C 65
        LD (SADRS),HL               ; 4624  22 04 11
        LD DE,652CH                 ; 4627  11 2C 65
        LD HL,(WS_633C)             ; 462A  2A 3C 63
        XOR A                       ; 462D  AF
        SBC HL,DE                   ; 462E  ED 52
        LD (EADRS),HL               ; 4630  22 02 11
        CALL WOPEN                  ; 4633  CD 21 00
        JP C,LOC_2354               ; 4636  DA 54 23
        CALL SUB_4990               ; 4639  CD 90 49
        CALL WRITE                  ; 463C  CD 24 00
        PUSH AF                     ; 463F  F5
        CALL SUB_4978               ; 4640  CD 78 49
        POP AF                      ; 4643  F1
        JP C,LOC_2354               ; 4644  DA 54 23
        JP LOC_2245                 ; 4647  C3 45 22
        LD A,01H                    ; 464A  3E 01
        LD (WS_62BA),A              ; 464C  32 BA 62
        CALL SUB_47B5               ; 464F  CD B5 47
        LD HL,(VAR_PTR)             ; 4652  2A C6 62
        INC HL                      ; 4655  23
        INC HL                      ; 4656  23
        LD (HL),02H                 ; 4657  36 02
        LD HL,(WS_633C)             ; 4659  2A 3C 63
        LD DE,652EH                 ; 465C  11 2E 65
        XOR A                       ; 465F  AF
        SBC HL,DE                   ; 4660  ED 52
        PUSH HL                     ; 4662  E5
        CALL SUB_4990               ; 4663  CD 90 49
        POP BC                      ; 4666  C1
        LD DE,652CH                 ; 4667  11 2C 65
        CALL SUB_3CA3               ; 466A  CD A3 3C
        CALL SUB_48FF               ; 466D  CD FF 48
        CALL SUB_4978               ; 4670  CD 78 49
        CALL SUB_4E86               ; 4673  CD 86 4E
        JP LOC_122A                 ; 4676  C3 2A 12
        PUSH HL                     ; 4679  E5
        CALL SUB_2B2A               ; 467A  CD 2A 2B
        LD HL,13FEH                 ; 467D  21 FE 13
        LD A,(HL)                   ; 4680  7E
        OR A                        ; 4681  B7
        JP Z,LOC_468A               ; 4682  CA 8A 46
        LD (HL),00H                 ; 4685  36 00
        JP LOC_23D2                 ; 4687  C3 D2 23
LOC_468A:
        INC A                       ; 468A  3C
        LD (HL),A                   ; 468B  77
        LD BC,000AH                 ; 468C  01 0A 00
        LD HL,2345H                 ; 468F  21 45 23
        LD DE,233BH                 ; 4692  11 3B 23
        LDIR                        ; 4695  ED B0
        CALL SUB_234F               ; 4697  CD 4F 23
        LD BC,0003H                 ; 469A  01 03 00
        LD HL,6179H                 ; 469D  21 79 61
        LD DE,416AH                 ; 46A0  11 6A 41
        LDIR                        ; 46A3  ED B0
        CALL SUB_2B1A               ; 46A5  CD 1A 2B
        CALL SUB_4807               ; 46A8  CD 07 48
        LD HL,62BAH                 ; 46AB  21 BA 62
        CALL SUB_2A2B               ; 46AE  CD 2B 2A
        LD A,(DATA_49AC)            ; 46B1  3A AC 49
        LD (HL),A                   ; 46B4  77
        INC HL                      ; 46B5  23
        LD (HL),00H                 ; 46B6  36 00
        LD HL,1003H                 ; 46B8  21 03 10
        LD (DATA_50D4),HL           ; 46BB  22 D4 50
        LD HL,10F0H                 ; 46BE  21 F0 10
        LD (DATA_50D8),HL           ; 46C1  22 D8 50
        CALL SUB_50BA               ; 46C4  CD BA 50
        LD HL,10F0H                 ; 46C7  21 F0 10
        LD A,(HL)                   ; 46CA  7E
        OR A                        ; 46CB  B7
        JP Z,LOC_46DA               ; 46CC  CA DA 46
        LD BC,003EH                 ; 46CF  01 3E 00
        ADD HL,BC                   ; 46D2  09
        LD E,(HL)                   ; 46D3  5E
        INC HL                      ; 46D4  23
        LD D,(HL)                   ; 46D5  56
        EX DE,HL                    ; 46D6  EB
        CALL SUB_4EF6               ; 46D7  CD F6 4E
LOC_46DA:
        LD A,01H                    ; 46DA  3E 01
        LD (WS_62BA),A              ; 46DC  32 BA 62
        CALL SUB_4257               ; 46DF  CD 57 42
        POP HL                      ; 46E2  E1
        PUSH HL                     ; 46E3  E5
        CALL SUB_278B               ; 46E4  CD 8B 27
        LD (CUR_STMT),HL            ; 46E7  22 27 65
        LD HL,(WS_633C)             ; 46EA  2A 3C 63
        LD DE,636EH                 ; 46ED  11 6E 63
        XOR A                       ; 46F0  AF
        SBC HL,DE                   ; 46F1  ED 52
        LD B,H                      ; 46F3  44
        LD C,L                      ; 46F4  4D
        DEC DE                      ; 46F5  1B
        DEC DE                      ; 46F6  1B
        CALL SUB_3CA3               ; 46F7  CD A3 3C
        CALL SUB_48E4               ; 46FA  CD E4 48
        POP HL                      ; 46FD  E1
        JP LOC_44E7                 ; 46FE  C3 E7 44
SUB_4701:
        LD HL,(VAR_PTR)             ; 4701  2A C6 62
        LD BC,0014H                 ; 4704  01 14 00
        ADD HL,BC                   ; 4707  09
        LD C,(HL)                   ; 4708  4E
        INC HL                      ; 4709  23
        LD B,(HL)                   ; 470A  46
        LD DE,652CH                 ; 470B  11 2C 65
        CALL SUB_28D4               ; 470E  CD D4 28
        CALL SUB_2A31               ; 4711  CD 31 2A
        CALL SUB_4E21               ; 4714  CD 21 4E
        LD DE,652CH                 ; 4717  11 2C 65
        CALL SUB_47A2               ; 471A  CD A2 47
        CALL SUB_4978               ; 471D  CD 78 49
        RET                         ; 4720  C9
LOC_4721:
        XOR A                       ; 4721  AF
        LD (DATA_13FE),A            ; 4722  32 FE 13
        LD BC,000AH                 ; 4725  01 0A 00
        LD HL,233BH                 ; 4728  21 3B 23
        LD DE,2345H                 ; 472B  11 45 23
        LDIR                        ; 472E  ED B0
        LD BC,0003H                 ; 4730  01 03 00
        LD HL,416AH                 ; 4733  21 6A 41
        LD DE,6179H                 ; 4736  11 79 61
        LDIR                        ; 4739  ED B0
        LD HL,62BAH                 ; 473B  21 BA 62
        CALL SUB_2A2B               ; 473E  CD 2B 2A
        LD A,(DATA_49AC)            ; 4741  3A AC 49
        LD (HL),A                   ; 4744  77
        INC HL                      ; 4745  23
        LD (HL),00H                 ; 4746  36 00
        CALL SUB_4867               ; 4748  CD 67 48
        CALL SUB_4807               ; 474B  CD 07 48
        CALL SUB_4257               ; 474E  CD 57 42
        LD HL,(VAR_PTR)             ; 4751  2A C6 62
        INC HL                      ; 4754  23
        INC HL                      ; 4755  23
        LD A,(HL)                   ; 4756  7E
        OR A                        ; 4757  B7
        JP Z,LOC_23D6               ; 4758  CA D6 23
        LD BC,0012H                 ; 475B  01 12 00
        ADD HL,BC                   ; 475E  09
        LD C,(HL)                   ; 475F  4E
        INC HL                      ; 4760  23
        LD B,(HL)                   ; 4761  46
        LD HL,FE40H                 ; 4762  21 40 FE
        ADD HL,BC                   ; 4765  09
        LD C,L                      ; 4766  4D
        LD B,H                      ; 4767  44
        LD DE,652CH                 ; 4768  11 2C 65
        CALL SUB_28D4               ; 476B  CD D4 28
        CALL SUB_2A31               ; 476E  CD 31 2A
        CALL SUB_4E21               ; 4771  CD 21 4E
        LD DE,636CH                 ; 4774  11 6C 63
        CALL SUB_47A2               ; 4777  CD A2 47
        LD HL,1003H                 ; 477A  21 03 10
        LD (DATA_50D4),HL           ; 477D  22 D4 50
        LD HL,10F0H                 ; 4780  21 F0 10
        LD (HL),00H                 ; 4783  36 00
        LD (DATA_50D8),HL           ; 4785  22 D8 50
        CALL SUB_50B5               ; 4788  CD B5 50
        LD HL,(VAR_PTR)             ; 478B  2A C6 62
        LD BC,0040H                 ; 478E  01 40 00
        ADD HL,BC                   ; 4791  09
        LD A,(HL)                   ; 4792  7E
        INC HL                      ; 4793  23
        LD H,(HL)                   ; 4794  66
        LD L,A                      ; 4795  6F
        CALL SUB_4EF6               ; 4796  CD F6 4E
        CALL SUB_4851               ; 4799  CD 51 48
        CALL SUB_4E86               ; 479C  CD 86 4E
        JP LOC_122A                 ; 479F  C3 2A 12
; --- SUB_47A2: called from 4 places ---
SUB_47A2:
        LD HL,(WS_62CE)             ; 47A2  2A CE 62
        LD BC,007EH                 ; 47A5  01 7E 00
        ADD HL,BC                   ; 47A8  09
LOC_47A9:
        CALL SUB_4097               ; 47A9  CD 97 40
        RET Z                       ; 47AC  C8
        LD A,(HL)                   ; 47AD  7E
        LD (DE),A                   ; 47AE  12
        INC HL                      ; 47AF  23
        INC DE                      ; 47B0  13
        INC BC                      ; 47B1  03
        JP LOC_47A9                 ; 47B2  C3 A9 47
; --- SUB_47B5: called from 3 places ---
SUB_47B5:
        CALL SUB_515A               ; 47B5  CD 5A 51
        LD (CUR_STMT),HL            ; 47B8  22 27 65
        LD A,(WS_62BB)              ; 47BB  3A BB 62
        OR A                        ; 47BE  B7
        JP NZ,LOC_2372              ; 47BF  C2 72 23
        JP SUB_4260                 ; 47C2  C3 60 42
        NOP                         ; 47C5  00
SUB_47C6:
        LD A,01H                    ; 47C6  3E 01
        JR LOC_47CB                 ; 47C8  18 01
        XOR A                       ; 47CA  AF
LOC_47CB:
        LD (47C5H),A                ; 47CB  32 C5 47
        RET                         ; 47CE  C9
SUB_47CF:
        LD A,01H                    ; 47CF  3E 01
        JR LOC_47D4                 ; 47D1  18 01
SUB_47D3:
        XOR A                       ; 47D3  AF
LOC_47D4:
        LD (47D8H),A                ; 47D4  32 D8 47
        RET                         ; 47D7  C9
        INC D                       ; 47D8  14
SUB_47D9:
        LD A,(47D8H)                ; 47D9  3A D8 47
        OR A                        ; 47DC  B7
        RET Z                       ; 47DD  C8
SUB_47DE:
        LD HL,(WS_635A)             ; 47DE  2A 5A 63
        LD DE,0010H                 ; 47E1  11 10 00
        ADD HL,DE                   ; 47E4  19
        EX DE,HL                    ; 47E5  EB
        LD HL,(FREE_PTR)            ; 47E6  2A 6A 63
        XOR A                       ; 47E9  AF
        SBC HL,DE                   ; 47EA  ED 52
        RET Z                       ; 47EC  C8
        LD C,L                      ; 47ED  4D
        LD B,H                      ; 47EE  44
        LD HL,(WS_635A)             ; 47EF  2A 5A 63
        EX DE,HL                    ; 47F2  EB
        CALL SUB_28BE               ; 47F3  CD BE 28
        LD HL,635AH                 ; 47F6  21 5A 63
        LD B,09H                    ; 47F9  06 09
SUB_47FB:
        LD (HL),E                   ; 47FB  73
        INC HL                      ; 47FC  23
        LD (HL),D                   ; 47FD  72
        INC HL                      ; 47FE  23
        XOR A                       ; 47FF  AF
        LD (DE),A                   ; 4800  12
        INC DE                      ; 4801  13
        LD (DE),A                   ; 4802  12
        INC DE                      ; 4803  13
        DJNZ SUB_47FB               ; 4804  10 F5
        RET                         ; 4806  C9
; --- SUB_4807: called from 4 places ---
SUB_4807:
        LD HL,62D7H                 ; 4807  21 D7 62
        LD DE,0009H                 ; 480A  11 09 00
        LD B,0AH                    ; 480D  06 0A
LOC_480F:
        LD (HL),00H                 ; 480F  36 00
        ADD HL,DE                   ; 4811  19
        DJNZ LOC_480F               ; 4812  10 FB
        LD HL,(WS_6344)             ; 4814  2A 44 63
        LD DE,0014H                 ; 4817  11 14 00
        ADD HL,DE                   ; 481A  19
        EX DE,HL                    ; 481B  EB
        LD HL,(WS_6358)             ; 481C  2A 58 63
        XOR A                       ; 481F  AF
        SBC HL,DE                   ; 4820  ED 52
        RET Z                       ; 4822  C8
        LD C,L                      ; 4823  4D
        LD B,H                      ; 4824  44
        LD HL,(WS_6344)             ; 4825  2A 44 63
        EX DE,HL                    ; 4828  EB
        LD HL,0000H                 ; 4829  21 00 00
        LD (WS_6356),HL             ; 482C  22 56 63
        CALL SUB_4875               ; 482F  CD 75 48
        LD HL,6344H                 ; 4832  21 44 63
        LD B,0AH                    ; 4835  06 0A
        CALL SUB_47FB               ; 4837  CD FB 47
        CALL SUB_4E86               ; 483A  CD 86 4E
        RET                         ; 483D  C9
SUB_483E:
        LD A,01H                    ; 483E  3E 01
        JR LOC_4843                 ; 4840  18 01
        XOR A                       ; 4842  AF
LOC_4843:
        LD (4847H),A                ; 4843  32 47 48
        RET                         ; 4846  C9
        AND A                       ; 4847  A7
SUB_4848:
        LD A,(4847H)                ; 4848  3A 47 48
        OR A                        ; 484B  B7
        RET Z                       ; 484C  C8
        CALL SUB_29DA               ; 484D  CD DA 29
        RET                         ; 4850  C9
; --- SUB_4851: called from 4 places ---
SUB_4851:
        LD HL,6331H                 ; 4851  21 31 63
        LD (HL),00H                 ; 4854  36 00
        LD HL,(WS_6358)             ; 4856  2A 58 63
        LD A,(HL)                   ; 4859  7E
        OR A                        ; 485A  B7
        RET Z                       ; 485B  C8
        EX DE,HL                    ; 485C  EB
        LD BC,00D0H                 ; 485D  01 D0 00
        CALL SUB_4875               ; 4860  CD 75 48
        CALL SUB_4E86               ; 4863  CD 86 4E
        RET                         ; 4866  C9
; --- SUB_4867: called from 3 places ---
SUB_4867:
        LD DE,652EH                 ; 4867  11 2E 65
        LD HL,(WS_633C)             ; 486A  2A 3C 63
        XOR A                       ; 486D  AF
        SBC HL,DE                   ; 486E  ED 52
        RET Z                       ; 4870  C8
        LD C,L                      ; 4871  4D
        LD B,H                      ; 4872  44
        DEC DE                      ; 4873  1B
        DEC DE                      ; 4874  1B
; --- SUB_4875: called from 5 places ---
SUB_4875:
        CALL SUB_28BE               ; 4875  CD BE 28
        CALL SUB_279F               ; 4878  CD 9F 27
        JP SUB_2A31                 ; 487B  C3 31 2A
LOC_487E:
        CALL SUB_2B2A               ; 487E  CD 2A 2B
        CALL SUB_4DC0               ; 4881  CD C0 4D
        LD (CUR_STMT),HL            ; 4884  22 27 65
        JP NZ,LOC_489D              ; 4887  C2 9D 48
LOC_488A:
        LD HL,62B9H                 ; 488A  21 B9 62
        INC (HL)                    ; 488D  34
        JP M,LOC_48B1               ; 488E  FA B1 48
        LD A,(HL)                   ; 4891  7E
        CALL SUB_4DE1               ; 4892  CD E1 4D
        ADC A,D                     ; 4895  8A
        LD C,B                      ; 4896  48
        CALL SUB_48B7               ; 4897  CD B7 48
        JP LOC_488A                 ; 489A  C3 8A 48
LOC_489D:
        CALL SUB_4DE1               ; 489D  CD E1 4D
        JP P,WS_CD23                ; 48A0  F2 23 CD
        OR A                        ; 48A3  B7
        LD C,B                      ; 48A4  48
        LD HL,(CUR_STMT)            ; 48A5  2A 27 65
        CALL SUB_27D2               ; 48A8  CD D2 27
        INC L                       ; 48AB  2C
        OR C                        ; 48AC  B1
        LD C,B                      ; 48AD  48
        JP LOC_487E                 ; 48AE  C3 7E 48
LOC_48B1:
        CALL SUB_4E86               ; 48B1  CD 86 4E
        JP LOC_122A                 ; 48B4  C3 2A 12
SUB_48B7:
        LD A,(WS_62B9)              ; 48B7  3A B9 62
        CALL SUB_4E09               ; 48BA  CD 09 4E
        LD A,(WS_62BA)              ; 48BD  3A BA 62
        CP 02H                      ; 48C0  FE 02
        JP Z,LOC_495B               ; 48C2  CA 5B 49
        LD HL,48D6H                 ; 48C5  21 D6 48
        OR A                        ; 48C8  B7
        JP NZ,LOC_48CF              ; 48C9  C2 CF 48
        LD HL,48DAH                 ; 48CC  21 DA 48
LOC_48CF:
        LD A,(WS_62BB)              ; 48CF  3A BB 62
        CALL SUB_4F62               ; 48D2  CD 62 4F
        JP (HL)                     ; 48D5  E9
        RST 38H                     ; 48D6  FF
        LD C,B                      ; 48D7  48
        LD (HL),C                   ; 48D8  71
        LD C,C                      ; 48D9  49
        LD E,E                      ; 48DA  5B
        LD C,C                      ; 48DB  49
        LD (HL),C                   ; 48DC  71
        LD C,C                      ; 48DD  49
        CALL SUB_3D0D               ; 48DE  CD 0D 3D
        JP LOC_4971                 ; 48E1  C3 71 49
SUB_48E4:
        LD A,01H                    ; 48E4  3E 01
        JP LOC_4900                 ; 48E6  C3 00 49
LOC_48E9:
        LD HL,1003H                 ; 48E9  21 03 10
        LD (DATA_50D4),HL           ; 48EC  22 D4 50
        LD HL,10F0H                 ; 48EF  21 F0 10
        LD (DATA_50D8),HL           ; 48F2  22 D8 50
        LD A,(DATA_49AC)            ; 48F5  3A AC 49
        LD (WS_62BC),A              ; 48F8  32 BC 62
        JP LOC_4944                 ; 48FB  C3 44 49
        JP (HL)                     ; 48FE  E9
SUB_48FF:
        XOR A                       ; 48FF  AF
LOC_4900:
        LD (48FEH),A                ; 4900  32 FE 48
        LD HL,(WS_62CC)             ; 4903  2A CC 62
        LD C,(HL)                   ; 4906  4E
        INC HL                      ; 4907  23
        LD B,(HL)                   ; 4908  46
        XOR A                       ; 4909  AF
        CALL SUB_3CCB               ; 490A  CD CB 3C
        LD HL,(WS_62CA)             ; 490D  2A CA 62
        LD E,(HL)                   ; 4910  5E
        INC HL                      ; 4911  23
        LD D,(HL)                   ; 4912  56
        LD HL,(VAR_PTR)             ; 4913  2A C6 62
        LD BC,0014H                 ; 4916  01 14 00
        ADD HL,BC                   ; 4919  09
        LD (HL),E                   ; 491A  73
        INC HL                      ; 491B  23
        LD (HL),D                   ; 491C  72
        LD A,(48FEH)                ; 491D  3A FE 48
        OR A                        ; 4920  B7
        JP NZ,LOC_48E9              ; 4921  C2 E9 48
        LD HL,(VAR_PTR)             ; 4924  2A C6 62
        INC HL                      ; 4927  23
        INC HL                      ; 4928  23
        LD DE,5146H                 ; 4929  11 46 51
        LD BC,0011H                 ; 492C  01 11 00
        LDIR                        ; 492F  ED B0
        CALL SUB_4FF7               ; 4931  CD F7 4F
        ADD HL,SP                   ; 4934  39
        LD C,C                      ; 4935  49
        JP LOC_240E                 ; 4936  C3 0E 24
        JP Z,LOC_4943               ; 4939  CA 43 49
        CALL SUB_5048               ; 493C  CD 48 50
        RET NZ                      ; 493F  C0
        JP LOC_23EA                 ; 4940  C3 EA 23
LOC_4943:
        POP AF                      ; 4943  F1
LOC_4944:
        EX DE,HL                    ; 4944  EB
        DB 2AH                      ; 4945  2A   (stray byte(s): disassembly boundary correction)
        ADD A,62H                   ; 4946  C6 62
        INC HL                      ; 4948  23
        INC HL                      ; 4949  23
        LD BC,0040H                 ; 494A  01 40 00
        LDIR                        ; 494D  ED B0
        DEC HL                      ; 494F  2B
        LD D,(HL)                   ; 4950  56
        DEC HL                      ; 4951  2B
        LD E,(HL)                   ; 4952  5E
        PUSH DE                     ; 4953  D5
        CALL SUB_50B5               ; 4954  CD B5 50
        POP HL                      ; 4957  E1
        CALL SUB_4EF2               ; 4958  CD F2 4E
LOC_495B:
        LD A,(WS_62BB)              ; 495B  3A BB 62
        OR A                        ; 495E  B7
        JP NZ,LOC_4971              ; 495F  C2 71 49
        LD HL,(VAR_PTR)             ; 4962  2A C6 62
        LD A,(HL)                   ; 4965  7E
        OR A                        ; 4966  B7
        JP Z,LOC_4971               ; 4967  CA 71 49
        EX DE,HL                    ; 496A  EB
        LD BC,00D0H                 ; 496B  01 D0 00
        CALL SUB_4875               ; 496E  CD 75 48
LOC_4971:
        LD HL,(WS_62C2)             ; 4971  2A C2 62
        LD (HL),00H                 ; 4974  36 00
        RET                         ; 4976  C9
        NOP                         ; 4977  00
; --- SUB_4978: called from 6 places ---
SUB_4978:
        LD HL,652CH                 ; 4978  21 2C 65
LOC_497B:
        LD E,(HL)                   ; 497B  5E
        INC HL                      ; 497C  23
        LD D,(HL)                   ; 497D  56
        DEC HL                      ; 497E  2B
        LD A,E                      ; 497F  7B
        OR D                        ; 4980  B2
        RET Z                       ; 4981  C8
        CALL SUB_27B0               ; 4982  CD B0 27
        RET C                       ; 4985  D8
        EX DE,HL                    ; 4986  EB
        ADD HL,DE                   ; 4987  19
        EX DE,HL                    ; 4988  EB
        LD (HL),E                   ; 4989  73
        INC HL                      ; 498A  23
        LD (HL),D                   ; 498B  72
        EX DE,HL                    ; 498C  EB
        JP LOC_497B                 ; 498D  C3 7B 49
SUB_4990:
        LD HL,652CH                 ; 4990  21 2C 65
LOC_4993:
        LD E,(HL)                   ; 4993  5E
        INC HL                      ; 4994  23
        LD D,(HL)                   ; 4995  56
        DEC HL                      ; 4996  2B
        LD A,D                      ; 4997  7A
        OR E                        ; 4998  B3
        RET Z                       ; 4999  C8
        CALL SUB_27B0               ; 499A  CD B0 27
        RET NC                      ; 499D  D0
        PUSH DE                     ; 499E  D5
        EX DE,HL                    ; 499F  EB
        XOR A                       ; 49A0  AF
        SBC HL,DE                   ; 49A1  ED 52
        EX DE,HL                    ; 49A3  EB
        LD (HL),E                   ; 49A4  73
        INC HL                      ; 49A5  23
        LD (HL),D                   ; 49A6  72
        POP HL                      ; 49A7  E1
        JP LOC_4993                 ; 49A8  C3 93 49
DATA_49AB:
        NOP                         ; 49AB  00
DATA_49AC:
        NOP                         ; 49AC  00
        CALL SUB_2B1F               ; 49AD  CD 1F 2B
        CALL SUB_27A7               ; 49B0  CD A7 27
        JR C,LOC_49B8               ; 49B3  38 03
        LD A,01H                    ; 49B5  3E 01
        DEC HL                      ; 49B7  2B
LOC_49B8:
        INC HL                      ; 49B8  23
        AND 0FH                     ; 49B9  E6 0F
        DEC A                       ; 49BB  3D
        CP 04H                      ; 49BC  FE 04
        JP NC,LOC_2372              ; 49BE  D2 72 23
        LD (WS_62BC),A              ; 49C1  32 BC 62
        LD (DATA_49AC),A            ; 49C4  32 AC 49
        XOR A                       ; 49C7  AF
        LD (DATA_49AB),A            ; 49C8  32 AB 49
        CALL SUB_27D2               ; 49CB  CD D2 27
        CP A                        ; 49CE  BF
        JP C,WS_CD49                ; 49CF  DA 49 CD
        POP HL                      ; 49D2  E1
        DAA                         ; 49D3  27
        LD D,B                      ; 49D4  50
        LD A,01H                    ; 49D5  3E 01
        LD (DATA_49AB),A            ; 49D7  32 AB 49
        CALL SUB_2981               ; 49DA  CD 81 29
        JP NZ,LOC_2372              ; 49DD  C2 72 23
        LD (CUR_STMT),HL            ; 49E0  22 27 65
        XOR A                       ; 49E3  AF
        LD (4AE7H),A                ; 49E4  32 E7 4A
        CALL SUB_5094               ; 49E7  CD 94 50
        LD A,(WS_61B0)              ; 49EA  3A B0 61
        OR A                        ; 49ED  B7
        CALL NZ,SUB_5061            ; 49EE  C4 61 50
        LD A,(WS_62BC)              ; 49F1  3A BC 62
        LD HL,633CH                 ; 49F4  21 3C 63
        CALL SUB_4F62               ; 49F7  CD 62 4F
        LD A,(HL)                   ; 49FA  7E
        OR A                        ; 49FB  B7
        JP Z,LOC_4A09               ; 49FC  CA 09 4A
        INC HL                      ; 49FF  23
        INC HL                      ; 4A00  23
        INC HL                      ; 4A01  23
        LD A,(WS_61B1)              ; 4A02  3A B1 61
        CP (HL)                     ; 4A05  BE
        JP NZ,LOC_2412              ; 4A06  C2 12 24
LOC_4A09:
        CALL SUB_4AE8               ; 4A09  CD E8 4A
        LD DE,4ACBH                 ; 4A0C  11 CB 4A
        CALL SUB_4AFC               ; 4A0F  CD FC 4A
        LD A,(WS_61B1)              ; 4A12  3A B1 61
        LD DE,4AD0H                 ; 4A15  11 D0 4A
        OR A                        ; 4A18  B7
        JP Z,LOC_4A22               ; 4A19  CA 22 4A
        LD L,A                      ; 4A1C  6F
        LD H,00H                    ; 4A1D  26 00
        CALL SUB_288B               ; 4A1F  CD 8B 28
LOC_4A22:
        CALL SUB_4AFC               ; 4A22  CD FC 4A
        LD HL,(WS_61B2)             ; 4A25  2A B2 61
        EX DE,HL                    ; 4A28  EB
        LD HL,0420H                 ; 4A29  21 20 04
        XOR A                       ; 4A2C  AF
        SBC HL,DE                   ; 4A2D  ED 52
        LD DE,4ADDH                 ; 4A2F  11 DD 4A
        PUSH DE                     ; 4A32  D5
        CALL SUB_2846               ; 4A33  CD 46 28
        POP DE                      ; 4A36  D1
        LD A,2EH                    ; 4A37  3E 2E
        LD (DE),A                   ; 4A39  12
        DEC DE                      ; 4A3A  1B
        DEC DE                      ; 4A3B  1B
        CALL SUB_4AFC               ; 4A3C  CD FC 4A
        LD DE,4AD9H                 ; 4A3F  11 D9 4A
        CALL SUB_4AFC               ; 4A42  CD FC 4A
        CALL SUB_4AF2               ; 4A45  CD F2 4A
        CALL SUB_4FF7               ; 4A48  CD F7 4F
        LD D,B                      ; 4A4B  50
        LD C,D                      ; 4A4C  4A
        JP LOC_122A                 ; 4A4D  C3 2A 12
        JP NZ,LOC_4A57              ; 4A50  C2 57 4A
        POP AF                      ; 4A53  F1
        JP LOC_122A                 ; 4A54  C3 2A 12
LOC_4A57:
        PUSH HL                     ; 4A57  E5
        LD (4B06H),HL               ; 4A58  22 06 4B
        DEC A                       ; 4A5B  3D
        CP 07H                      ; 4A5C  FE 07
        JP C,LOC_4A63               ; 4A5E  DA 63 4A
        LD A,04H                    ; 4A61  3E 04
LOC_4A63:
        LD L,A                      ; 4A63  6F
        LD H,00H                    ; 4A64  26 00
        ADD HL,HL                   ; 4A66  29
        ADD HL,HL                   ; 4A67  29
        LD DE,1571H                 ; 4A68  11 71 15
        ADD HL,DE                   ; 4A6B  19
        EX DE,HL                    ; 4A6C  EB
        CALL SUB_4AFC               ; 4A6D  CD FC 4A
        POP HL                      ; 4A70  E1
        PUSH HL                     ; 4A71  E5
        LD DE,1583H                 ; 4A72  11 83 15
        CALL SUB_4CA5               ; 4A75  CD A5 4C
        JR Z,LOC_4A7D               ; 4A78  28 03
        LD DE,4AD7H                 ; 4A7A  11 D7 4A
LOC_4A7D:
        CALL SUB_4AFC               ; 4A7D  CD FC 4A
        LD DE,4AC7H                 ; 4A80  11 C7 4A
        CALL SUB_4AFC               ; 4A83  CD FC 4A
        POP HL                      ; 4A86  E1
        PUSH HL                     ; 4A87  E5
        LD BC,0011H                 ; 4A88  01 11 00
        ADD HL,BC                   ; 4A8B  09
        LD (HL),0DH                 ; 4A8C  36 0D
        POP DE                      ; 4A8E  D1
        INC DE                      ; 4A8F  13
        CALL SUB_4AFC               ; 4A90  CD FC 4A
        LD DE,4AC9H                 ; 4A93  11 C9 4A
        CALL SUB_4AFC               ; 4A96  CD FC 4A
        LD A,(DATA_49AB)            ; 4A99  3A AB 49
        OR A                        ; 4A9C  B7
        JP NZ,LOC_4B08              ; 4A9D  C2 08 4B
        CALL NEWLIN                 ; 4AA0  CD 09 00
        LD HL,4AE7H                 ; 4AA3  21 E7 4A
        INC (HL)                    ; 4AA6  34
        LD A,(HL)                   ; 4AA7  7E
        CP 14H                      ; 4AA8  FE 14
        RET NZ                      ; 4AAA  C0
        LD (HL),00H                 ; 4AAB  36 00
        CALL SUB_5204               ; 4AAD  CD 04 52
        JP LOC_22AC                 ; 4AB0  C3 AC 22
SUB_4AB3:
        CALL BRKEY                  ; 4AB3  CD 1E 00
        RET Z                       ; 4AB6  C8
        CALL MON_GETKEY             ; 4AB7  CD 1B 00
        CP 20H                      ; 4ABA  FE 20
        RET NZ                      ; 4ABC  C0
        CALL SUB_55DB               ; 4ABD  CD DB 55
        CP CBH                      ; 4AC0  FE CB
        RET                         ; 4AC2  C9
        NOP                         ; 4AC3  00
        NOP                         ; 4AC4  00
        NOP                         ; 4AC5  00
        NOP                         ; 4AC6  00
        JR NZ,LOC_4AE9              ; 4AC7  20 20
        LD (560DH),HL               ; 4AC9  22 0D 56
        LD C,A                      ; 4ACC  4F
        LD C,H                      ; 4ACD  4C
        LD L,0DH                    ; 4ACE  2E 0D
        LD C,L                      ; 4AD0  4D
        LD B,C                      ; 4AD1  41
        LD D,E                      ; 4AD2  53
        LD D,H                      ; 4AD3  54
        LD B,L                      ; 4AD4  45
        LD D,D                      ; 4AD5  52
        DEC C                       ; 4AD6  0D
        LD HL,(290DH)               ; 4AD7  2A 0D 29
        DEC C                       ; 4ADA  0D
        JR Z,LOC_4B30               ; 4ADB  28 53
        LD L,31H                    ; 4ADD  2E 31
        JR NC,LOC_4B16              ; 4ADF  30 35
        LD (HL),0DH                 ; 4AE1  36 0D
        INC H                       ; 4AE3  24
        LD HL,(3DF5H)               ; 4AE4  2A F5 3D
        DB 01H                      ; 4AE7  01   (stray byte(s): disassembly boundary correction)
SUB_4AE8:
        LD A,(DATA_49AB)            ; 4AE8  3A AB 49
        OR A                        ; 4AEB  B7
        JP Z,NEWLIN                 ; 4AEC  CA 09 00
        JP SUB_3D9D                 ; 4AEF  C3 9D 3D
SUB_4AF2:
        LD A,(DATA_49AB)            ; 4AF2  3A AB 49
        OR A                        ; 4AF5  B7
        JP Z,NEWLIN                 ; 4AF6  CA 09 00
        JP LOC_3D12                 ; 4AF9  C3 12 3D
; --- SUB_4AFC: called from 9 places ---
SUB_4AFC:
        LD A,(DATA_49AB)            ; 4AFC  3A AB 49
        OR A                        ; 4AFF  B7
        JP Z,MON_MESSAGE            ; 4B00  CA 15 00
        JP SUB_3D23                 ; 4B03  C3 23 3D
        RET P                       ; 4B06  F0
        DB 10H                      ; 4B07  10   (stray byte(s): disassembly boundary correction)
LOC_4B08:
        LD HL,(4B06H)               ; 4B08  2A 06 4B
        LD A,(HL)                   ; 4B0B  7E
        CP 04H                      ; 4B0C  FE 04
        JP Z,LOC_4B60               ; 4B0E  CA 60 4B
        JP NC,LOC_3D12              ; 4B11  D2 12 3D
        DB 01H,12H                  ; 4B14  01 12   (stray byte(s): disassembly boundary correction)
LOC_4B16:
        NOP                         ; 4B16  00
        ADD HL,BC                   ; 4B17  09
        LD A,(HL)                   ; 4B18  7E
        INC HL                      ; 4B19  23
        LD H,(HL)                   ; 4B1A  66
        LD L,A                      ; 4B1B  6F
        LD BC,0000H                 ; 4B1C  01 00 00
        LD DE,007EH                 ; 4B1F  11 7E 00
LOC_4B22:
        XOR A                       ; 4B22  AF
        SBC HL,DE                   ; 4B23  ED 52
        INC BC                      ; 4B25  03
        JP Z,LOC_4B2C               ; 4B26  CA 2C 4B
        JP NC,LOC_4B22              ; 4B29  D2 22 4B
LOC_4B2C:
        LD L,C                      ; 4B2C  69
        LD H,B                      ; 4B2D  60
        CALL SUB_288B               ; 4B2E  CD 8B 28   <-- UNRESOLVED ALIGNMENT: also targeted as 4B30H
        DB 3AH,41H                  ; 4B31  3A 41   (stray byte(s): disassembly boundary correction)
        LD A,47H                    ; 4B33  3E 47
        LD HL,6180H                 ; 4B35  21 80 61
        LD A,0DH                    ; 4B38  3E 0D
LOC_4B3A:
        INC B                       ; 4B3A  04
        CP (HL)                     ; 4B3B  BE
        INC HL                      ; 4B3C  23
        JP NZ,LOC_4B3A              ; 4B3D  C2 3A 4B
        LD A,21H                    ; 4B40  3E 21
        SUB B                       ; 4B42  90
        LD B,A                      ; 4B43  47
LOC_4B44:
        LD A,20H                    ; 4B44  3E 20
        CALL SUB_3DFB               ; 4B46  CD FB 3D
        DJNZ LOC_4B44               ; 4B49  10 F9
        LD DE,6180H                 ; 4B4B  11 80 61
        CALL SUB_3D23               ; 4B4E  CD 23 3D
        LD DE,4B5AH                 ; 4B51  11 5A 4B
        CALL SUB_3D23               ; 4B54  CD 23 3D
        JP LOC_3D12                 ; 4B57  C3 12 3D
        JR NZ,LOC_4BAF              ; 4B5A  20 53
        LD B,L                      ; 4B5C  45
        LD B,E                      ; 4B5D  43
        LD D,H                      ; 4B5E  54
        DEC C                       ; 4B5F  0D
LOC_4B60:
        LD BC,003EH                 ; 4B60  01 3E 00
        ADD HL,BC                   ; 4B63  09
        LD E,(HL)                   ; 4B64  5E
        INC HL                      ; 4B65  23
        LD D,(HL)                   ; 4B66  56
        LD HL,(DATA_50D4)           ; 4B67  2A D4 50
        PUSH HL                     ; 4B6A  E5
        EX DE,HL                    ; 4B6B  EB
        LD (DATA_50D4),HL           ; 4B6C  22 D4 50
        CALL SUB_50BA               ; 4B6F  CD BA 50
        LD HL,10F0H                 ; 4B72  21 F0 10
        LD A,(HL)                   ; 4B75  7E
        INC HL                      ; 4B76  23
        LD H,(HL)                   ; 4B77  66
        LD L,A                      ; 4B78  6F
        OR H                        ; 4B79  B4
        JP Z,LOC_4B8D               ; 4B7A  CA 8D 4B
        DEC HL                      ; 4B7D  2B
        SLA L                       ; 4B7E  CB 25
        LD A,H                      ; 4B80  7C
        ADC A,H                     ; 4B81  8C
        LD L,A                      ; 4B82  6F
        LD H,00H                    ; 4B83  26 00
        INC HL                      ; 4B85  23
        LD DE,0010H                 ; 4B86  11 10 00
        CALL SUB_2817               ; 4B89  CD 17 28
        EX DE,HL                    ; 4B8C  EB
LOC_4B8D:
        INC HL                      ; 4B8D  23
        EX (SP),HL                  ; 4B8E  E3
        LD (DATA_50D4),HL           ; 4B8F  22 D4 50
        CALL SUB_50BA               ; 4B92  CD BA 50
        POP BC                      ; 4B95  C1
        JP LOC_4B2C                 ; 4B96  C3 2C 4B
        CALL SUB_515A               ; 4B99  CD 5A 51
        LD A,(WS_62BB)              ; 4B9C  3A BB 62
        OR A                        ; 4B9F  B7
        JP NZ,LOC_2372              ; 4BA0  C2 72 23
        CALL SUB_2981               ; 4BA3  CD 81 29
        JP NZ,LOC_2372              ; 4BA6  C2 72 23
        LD (CUR_STMT),HL            ; 4BA9  22 27 65
        CALL SUB_4FAC               ; 4BAC  CD AC 4F
LOC_4BAF:
        CALL SUB_4E86               ; 4BAF  CD 86 4E
        CALL SUB_4FF7               ; 4BB2  CD F7 4F
        CP (HL)                     ; 4BB5  BE
        LD C,E                      ; 4BB6  4B
        JP LOC_23E2                 ; 4BB7  C3 E2 23
        LD C,D                      ; 4BBA  4A
        LD (25ECH),A                ; 4BBB  32 EC 25
        JP Z,LOC_23E2               ; 4BBE  CA E2 23
        CALL SUB_5048               ; 4BC1  CD 48 50
        RET NZ                      ; 4BC4  C0
        EX (SP),HL                  ; 4BC5  E3
        CALL SUB_4F6D               ; 4BC6  CD 6D 4F
        LD HL,(DATA_50D4)           ; 4BC9  2A D4 50
        LD (4BBAH),HL               ; 4BCC  22 BA 4B
        POP HL                      ; 4BCF  E1
        LD (4BBCH),HL               ; 4BD0  22 BC 4B
        CALL SUB_4CA5               ; 4BD3  CD A5 4C
        JP NZ,LOC_23FA              ; 4BD6  C2 FA 23
        LD A,(HL)                   ; 4BD9  7E
        LD BC,003EH                 ; 4BDA  01 3E 00
        ADD HL,BC                   ; 4BDD  09
        LD E,(HL)                   ; 4BDE  5E
        INC HL                      ; 4BDF  23
        LD D,(HL)                   ; 4BE0  56
        EX DE,HL                    ; 4BE1  EB
        CP 04H                      ; 4BE2  FE 04
        CALL Z,SUB_4C7C             ; 4BE4  CC 7C 4C
        CALL SUB_4EF6               ; 4BE7  CD F6 4E
        LD HL,(4BBAH)               ; 4BEA  2A BA 4B
        LD (DATA_50D4),HL           ; 4BED  22 D4 50
        LD HL,10F0H                 ; 4BF0  21 F0 10
        LD (DATA_50D8),HL           ; 4BF3  22 D8 50
        CALL SUB_50BA               ; 4BF6  CD BA 50
        LD HL,(4BBCH)               ; 4BF9  2A BC 4B
        LD DE,10F0H                 ; 4BFC  11 F0 10
        EX DE,HL                    ; 4BFF  EB
        CALL SUB_27B0               ; 4C00  CD B0 27
        JP NZ,LOC_4C0E              ; 4C03  C2 0E 4C
        LD BC,0040H                 ; 4C06  01 40 00
        LD HL,1130H                 ; 4C09  21 30 11
        LDIR                        ; 4C0C  ED B0
LOC_4C0E:
        XOR A                       ; 4C0E  AF
        LD (DE),A                   ; 4C0F  12
        LD HL,(DATA_50D4)           ; 4C10  2A D4 50
        INC H                       ; 4C13  24
        LD A,H                      ; 4C14  7C
        CP 11H                      ; 4C15  FE 11
        JP NZ,LOC_4C1D              ; 4C17  C2 1D 4C
        INC L                       ; 4C1A  2C
        LD H,01H                    ; 4C1B  26 01
LOC_4C1D:
        LD DE,1003H                 ; 4C1D  11 03 10
        CALL SUB_27B0               ; 4C20  CD B0 27
        JP Z,LOC_4C73               ; 4C23  CA 73 4C
        PUSH HL                     ; 4C26  E5
        LD HL,(DATA_50D4)           ; 4C27  2A D4 50
        EX (SP),HL                  ; 4C2A  E3
        LD (DATA_50D4),HL           ; 4C2B  22 D4 50
        LD HL,61B0H                 ; 4C2E  21 B0 61
        LD (DATA_50D8),HL           ; 4C31  22 D8 50
        CALL SUB_50BA               ; 4C34  CD BA 50
        LD HL,61B0H                 ; 4C37  21 B0 61
        LD A,(HL)                   ; 4C3A  7E
        OR A                        ; 4C3B  B7
        JP Z,LOC_4C69               ; 4C3C  CA 69 4C
        LD DE,1130H                 ; 4C3F  11 30 11
        LD BC,0040H                 ; 4C42  01 40 00
        LDIR                        ; 4C45  ED B0
        LD HL,(DATA_50D4)           ; 4C47  2A D4 50
        EX (SP),HL                  ; 4C4A  E3
        LD (DATA_50D4),HL           ; 4C4B  22 D4 50
        LD HL,10F0H                 ; 4C4E  21 F0 10
        LD (DATA_50D8),HL           ; 4C51  22 D8 50
        CALL SUB_50B5               ; 4C54  CD B5 50
        LD HL,61F0H                 ; 4C57  21 F0 61
        LD DE,10F0H                 ; 4C5A  11 F0 10
        LD BC,0040H                 ; 4C5D  01 40 00
        LDIR                        ; 4C60  ED B0
        POP HL                      ; 4C62  E1
        LD (DATA_50D4),HL           ; 4C63  22 D4 50
        JP LOC_4C0E                 ; 4C66  C3 0E 4C
LOC_4C69:
        POP HL                      ; 4C69  E1
        LD (DATA_50D4),HL           ; 4C6A  22 D4 50
        LD HL,10F0H                 ; 4C6D  21 F0 10
        LD (DATA_50D8),HL           ; 4C70  22 D8 50
LOC_4C73:
        CALL SUB_50B5               ; 4C73  CD B5 50
        CALL SUB_4E86               ; 4C76  CD 86 4E
        JP LOC_122A                 ; 4C79  C3 2A 12
SUB_4C7C:
        PUSH HL                     ; 4C7C  E5
        LD (DATA_50D4),HL           ; 4C7D  22 D4 50
        LD HL,10F0H                 ; 4C80  21 F0 10
        LD (DATA_50D8),HL           ; 4C83  22 D8 50
        CALL SUB_50BA               ; 4C86  CD BA 50
        LD HL,10F0H                 ; 4C89  21 F0 10
        INC HL                      ; 4C8C  23
        INC HL                      ; 4C8D  23
        LD (4F2EH),HL               ; 4C8E  22 2E 4F
        CALL SUB_4F30               ; 4C91  CD 30 4F
        LD HL,(4BBAH)               ; 4C94  2A BA 4B
        LD (DATA_50D4),HL           ; 4C97  22 D4 50
        LD HL,10F0H                 ; 4C9A  21 F0 10
        LD (DATA_50D8),HL           ; 4C9D  22 D8 50
        CALL SUB_50BA               ; 4CA0  CD BA 50
        POP HL                      ; 4CA3  E1
        RET                         ; 4CA4  C9
; --- SUB_4CA5: called from 3 places ---
SUB_4CA5:
        PUSH HL                     ; 4CA5  E5
        LD BC,0011H                 ; 4CA6  01 11 00
        ADD HL,BC                   ; 4CA9  09
        LD A,(HL)                   ; 4CAA  7E
        POP HL                      ; 4CAB  E1
        OR A                        ; 4CAC  B7
        RET                         ; 4CAD  C9
LOC_4CAE:
        CALL SUB_4DC0               ; 4CAE  CD C0 4D
        LD (CUR_STMT),HL            ; 4CB1  22 27 65
        JP NZ,LOC_4CCC              ; 4CB4  C2 CC 4C
LOC_4CB7:
        LD A,(WS_62B9)              ; 4CB7  3A B9 62
        INC A                       ; 4CBA  3C
        JP M,LOC_4CDD               ; 4CBB  FA DD 4C
        LD (WS_62B9),A              ; 4CBE  32 B9 62
        CALL SUB_4DE1               ; 4CC1  CD E1 4D
        OR A                        ; 4CC4  B7
        LD C,H                      ; 4CC5  4C
        CALL SUB_4CE3               ; 4CC6  CD E3 4C
        JP LOC_4CB7                 ; 4CC9  C3 B7 4C
LOC_4CCC:
        CALL SUB_4DE1               ; 4CCC  CD E1 4D
        JP P,WS_CD23                ; 4CCF  F2 23 CD
        EX (SP),HL                  ; 4CD2  E3
        LD C,H                      ; 4CD3  4C
        CALL SUB_27CF               ; 4CD4  CD CF 27
        INC L                       ; 4CD7  2C
        LD C,IXH                    ; 4CD8  DD 4C
        JP LOC_4CAE                 ; 4CDA  C3 AE 4C
LOC_4CDD:
        CALL SUB_4E86               ; 4CDD  CD 86 4E
        JP LOC_122A                 ; 4CE0  C3 2A 12
SUB_4CE3:
        LD (WS_62C2),HL             ; 4CE3  22 C2 62
        LD DE,62B8H                 ; 4CE6  11 B8 62
        LD (DE),A                   ; 4CE9  12
        INC DE                      ; 4CEA  13
        LD BC,0009H                 ; 4CEB  01 09 00
        LDIR                        ; 4CEE  ED B0
        LD HL,6344H                 ; 4CF0  21 44 63
        CALL SUB_4F62               ; 4CF3  CD 62 4F
        LD (VAR_PTR),HL             ; 4CF6  22 C6 62
        JP LOC_495B                 ; 4CF9  C3 5B 49
        XOR A                       ; 4CFC  AF
        JR LOC_4D01                 ; 4CFD  18 02
        LD A,01H                    ; 4CFF  3E 01
LOC_4D01:
        LD (4D2CH),A                ; 4D01  32 2C 4D
        CALL SUB_515A               ; 4D04  CD 5A 51
        LD (CUR_STMT),HL            ; 4D07  22 27 65
        LD A,(WS_62BB)              ; 4D0A  3A BB 62
        OR A                        ; 4D0D  B7
        JP NZ,LOC_2372              ; 4D0E  C2 72 23
        CALL SUB_4FF7               ; 4D11  CD F7 4F
        DEC DE                      ; 4D14  1B
        LD C,L                      ; 4D15  4D
        JP LOC_23E2                 ; 4D16  C3 E2 23
        INC D                       ; 4D19  14
        INC D                       ; 4D1A  14
        JP Z,LOC_23E2               ; 4D1B  CA E2 23
        CALL SUB_5048               ; 4D1E  CD 48 50
        RET NZ                      ; 4D21  C0
        EX (SP),HL                  ; 4D22  E3
        CALL SUB_4F6D               ; 4D23  CD 6D 4F
        POP HL                      ; 4D26  E1
        LD BC,0011H                 ; 4D27  01 11 00
        ADD HL,BC                   ; 4D2A  09
        LD (HL),FFH                 ; 4D2B  36 FF
        CALL SUB_50B5               ; 4D2D  CD B5 50
        CALL SUB_5204               ; 4D30  CD 04 52
        JP LOC_122A                 ; 4D33  C3 2A 12
        CP E                        ; 4D36  BB
        EI                          ; 4D37  FB
        LD D,9EH                    ; 4D38  16 9E
        DJNZ LOC_4D60               ; 4D3A  10 24
        RST 38H                     ; 4D3C  FF
        RST 38H                     ; 4D3D  FF
        RST 38H                     ; 4D3E  FF
        RST 08H                     ; 4D3F  CF
        LD D,(HL)                   ; 4D40  56
        LD B,B                      ; 4D41  40
        ADD A,(HL)                  ; 4D42  86
        CPL                         ; 4D43  2F
        DEC SP                      ; 4D44  3B
        DEC SP                      ; 4D45  3B
        CALL SUB_515A               ; 4D46  CD 5A 51
        LD A,(WS_62BB)              ; 4D49  3A BB 62
        OR A                        ; 4D4C  B7
        JP NZ,LOC_2372              ; 4D4D  C2 72 23
        CALL SUB_27D2               ; 4D50  CD D2 27
        INC L                       ; 4D53  2C
        LD D,(HL)                   ; 4D54  56
        LD C,L                      ; 4D55  4D
        CALL SUB_1A58               ; 4D56  CD 58 1A
        LD A,D                      ; 4D59  7A
        OR A                        ; 4D5A  B7
        JP Z,LOC_2432               ; 4D5B  CA 32 24
        DB 22H,27H                  ; 4D5E  22 27   (stray byte(s): disassembly boundary correction)
LOC_4D60:
        LD H,L                      ; 4D60  65
        LD A,C                      ; 4D61  79
        DEC A                       ; 4D62  3D
        CP 10H                      ; 4D63  FE 10
        JP NC,LOC_2432              ; 4D65  D2 32 24
        CALL SUB_2959               ; 4D68  CD 59 29
        PUSH DE                     ; 4D6B  D5
        PUSH BC                     ; 4D6C  C5
        LD HL,4D36H                 ; 4D6D  21 36 4D
        PUSH HL                     ; 4D70  E5
        LD B,10H                    ; 4D71  06 10
LOC_4D73:
        LD (HL),0DH                 ; 4D73  36 0D
        INC HL                      ; 4D75  23
        DJNZ LOC_4D73               ; 4D76  10 FB
        POP DE                      ; 4D78  D1
        POP BC                      ; 4D79  C1
        POP HL                      ; 4D7A  E1
        LDIR                        ; 4D7B  ED B0
        CALL SUB_4FF7               ; 4D7D  CD F7 4F
        ADD A,L                     ; 4D80  85
        LD C,L                      ; 4D81  4D
        JP LOC_4D93                 ; 4D82  C3 93 4D
        JP Z,LOC_4D92               ; 4D85  CA 92 4D
        LD DE,4D36H                 ; 4D88  11 36 4D
        CALL SUB_504B               ; 4D8B  CD 4B 50
        RET NZ                      ; 4D8E  C0
        JP LOC_23EA                 ; 4D8F  C3 EA 23
LOC_4D92:
        POP AF                      ; 4D92  F1
LOC_4D93:
        CALL SUB_4FF7               ; 4D93  CD F7 4F
        SBC A,E                     ; 4D96  9B
        LD C,L                      ; 4D97  4D
        JP LOC_23E2                 ; 4D98  C3 E2 23
        JP Z,LOC_23E2               ; 4D9B  CA E2 23
        CALL SUB_5048               ; 4D9E  CD 48 50
        RET NZ                      ; 4DA1  C0
        EX (SP),HL                  ; 4DA2  E3
        CALL SUB_4F6D               ; 4DA3  CD 6D 4F
        POP HL                      ; 4DA6  E1
        CALL SUB_4CA5               ; 4DA7  CD A5 4C
        JP NZ,LOC_23FA              ; 4DAA  C2 FA 23
        LD DE,4D36H                 ; 4DAD  11 36 4D
        INC HL                      ; 4DB0  23
        EX DE,HL                    ; 4DB1  EB
        LD BC,0010H                 ; 4DB2  01 10 00
        LDIR                        ; 4DB5  ED B0
        CALL SUB_50B5               ; 4DB7  CD B5 50
        DB CDH,04H                  ; 4DBA  CD 04   (stray byte(s): disassembly boundary correction)
LOC_4DBC:
        LD D,D                      ; 4DBC  52
        JP LOC_122A                 ; 4DBD  C3 2A 12
; --- SUB_4DC0: called from 5 places ---
SUB_4DC0:
        CALL SUB_27D2               ; 4DC0  CD D2 27
        INC HL                      ; 4DC3  23
        CALL C,WS_CD4D              ; 4DC4  DC 4D CD
        DEC E                       ; 4DC7  1D
        JR Z,LOC_4DBC               ; 4DC8  28 F2
        INC HL                      ; 4DCA  23
        LD A,D                      ; 4DCB  7A
        OR A                        ; 4DCC  B7
        JP NZ,LOC_23F2              ; 4DCD  C2 F2 23
        LD A,E                      ; 4DD0  7B
        DEC A                       ; 4DD1  3D
        CP 7FH                      ; 4DD2  FE 7F
        JP NC,LOC_23F2              ; 4DD4  D2 F2 23
        INC A                       ; 4DD7  3C
        OR A                        ; 4DD8  B7
        JP LOC_4DDD                 ; 4DD9  C3 DD 4D
        XOR A                       ; 4DDC  AF
LOC_4DDD:
        LD (WS_62B9),A              ; 4DDD  32 B9 62
        RET                         ; 4DE0  C9
; --- SUB_4DE1: called from 9 places ---
SUB_4DE1:
        LD HL,62D7H                 ; 4DE1  21 D7 62
        LD DE,0009H                 ; 4DE4  11 09 00
        LD B,0AH                    ; 4DE7  06 0A
LOC_4DE9:
        CP (HL)                     ; 4DE9  BE
        JP Z,LOC_4DF3               ; 4DEA  CA F3 4D
        ADD HL,DE                   ; 4DED  19
        DJNZ LOC_4DE9               ; 4DEE  10 F9
        JP LOC_27B7                 ; 4DF0  C3 B7 27
LOC_4DF3:
        LD A,0AH                    ; 4DF3  3E 0A
        SUB B                       ; 4DF5  90
        JP LOC_27C1                 ; 4DF6  C3 C1 27
SUB_4DF9:
        PUSH HL                     ; 4DF9  E5
        LD HL,62BBH                 ; 4DFA  21 BB 62
        LD B,07H                    ; 4DFD  06 07
LOC_4DFF:
        LD (HL),00H                 ; 4DFF  36 00
        INC HL                      ; 4E01  23
        DJNZ LOC_4DFF               ; 4E02  10 FB
        POP HL                      ; 4E04  E1
        CALL SUB_4DC0               ; 4E05  CD C0 4D
        RET Z                       ; 4E08  C8
SUB_4E09:
        PUSH HL                     ; 4E09  E5
        CALL SUB_4DE1               ; 4E0A  CD E1 4D
        JP P,LOC_2223               ; 4E0D  F2 23 22
        JP NZ,MON_1162              ; 4E10  C2 62 11
        CP B                        ; 4E13  B8
        LD H,D                      ; 4E14  62
        LD (DE),A                   ; 4E15  12
        INC DE                      ; 4E16  13
        LD BC,0009H                 ; 4E17  01 09 00
        LDIR                        ; 4E1A  ED B0
        CALL SUB_4E21               ; 4E1C  CD 21 4E
        POP HL                      ; 4E1F  E1
        RET                         ; 4E20  C9
; --- SUB_4E21: called from 5 places ---
SUB_4E21:
        LD A,(WS_62BB)              ; 4E21  3A BB 62
        CP 01H                      ; 4E24  FE 01
        RET NC                      ; 4E26  D0
        LD A,(WS_62BC)              ; 4E27  3A BC 62
        LD HL,633CH                 ; 4E2A  21 3C 63
        CALL SUB_4F62               ; 4E2D  CD 62 4F
        LD A,(HL)                   ; 4E30  7E
        OR A                        ; 4E31  B7
        LD (WS_62C4),HL             ; 4E32  22 C4 62
        CALL Z,SUB_4FAC             ; 4E35  CC AC 4F
        LD A,(WS_62B8)              ; 4E38  3A B8 62
        LD HL,6344H                 ; 4E3B  21 44 63
        CALL SUB_4F62               ; 4E3E  CD 62 4F
        LD A,(HL)                   ; 4E41  7E
        OR A                        ; 4E42  B7
        CALL Z,SUB_4E67             ; 4E43  CC 67 4E
        LD (VAR_PTR),HL             ; 4E46  22 C6 62
        LD BC,004AH                 ; 4E49  01 4A 00
        ADD HL,BC                   ; 4E4C  09
        LD (WS_62C8),HL             ; 4E4D  22 C8 62
        LD BC,0002H                 ; 4E50  01 02 00
        ADD HL,BC                   ; 4E53  09
        LD (WS_62CA),HL             ; 4E54  22 CA 62
        ADD HL,BC                   ; 4E57  09
        LD (WS_62CC),HL             ; 4E58  22 CC 62
        ADD HL,BC                   ; 4E5B  09
        LD (WS_62CE),HL             ; 4E5C  22 CE 62
        LD BC,007EH                 ; 4E5F  01 7E 00
        ADD HL,BC                   ; 4E62  09
        LD (WS_62D0),HL             ; 4E63  22 D0 62
        RET                         ; 4E66  C9
SUB_4E67:
        LD BC,00D0H                 ; 4E67  01 D0 00
SUB_4E6A:
        PUSH HL                     ; 4E6A  E5
        EX DE,HL                    ; 4E6B  EB
        CALL SUB_28D4               ; 4E6C  CD D4 28
        CALL SUB_2A31               ; 4E6F  CD 31 2A
        EX DE,HL                    ; 4E72  EB
        LD A,01H                    ; 4E73  3E 01
        CALL SUB_2A2C               ; 4E75  CD 2C 2A
        DEC BC                      ; 4E78  0B
        DEC BC                      ; 4E79  0B
LOC_4E7A:
        LD (HL),00H                 ; 4E7A  36 00
        INC HL                      ; 4E7C  23
        DEC BC                      ; 4E7D  0B
        LD A,B                      ; 4E7E  78
        OR C                        ; 4E7F  B1
        JP NZ,LOC_4E7A              ; 4E80  C2 7A 4E
        POP HL                      ; 4E83  E1
        RET                         ; 4E84  C9
        INC B                       ; 4E85  04
; --- SUB_4E86: called from 10 places ---
SUB_4E86:
        LD A,FFH                    ; 4E86  3E FF
        LD (4E85H),A                ; 4E88  32 85 4E
        LD HL,4E85H                 ; 4E8B  21 85 4E
        INC (HL)                    ; 4E8E  34
        LD A,(HL)                   ; 4E8F  7E
        CP 04H                      ; 4E90  FE 04
        JP Z,LOC_4ED4               ; 4E92  CA D4 4E
        LD HL,62D7H                 ; 4E95  21 D7 62
        LD DE,0009H                 ; 4E98  11 09 00
        LD BC,0A00H                 ; 4E9B  01 00 0A
LOC_4E9E:
        LD A,(HL)                   ; 4E9E  7E
        OR A                        ; 4E9F  B7
        CALL NZ,SUB_4EC1            ; 4EA0  C4 C1 4E
        ADD HL,DE                   ; 4EA3  19
        DJNZ LOC_4E9E               ; 4EA4  10 F8
        LD DE,4E8BH                 ; 4EA6  11 8B 4E
        PUSH DE                     ; 4EA9  D5
        LD A,C                      ; 4EAA  79
        OR A                        ; 4EAB  B7
        RET NZ                      ; 4EAC  C0
        LD HL,633CH                 ; 4EAD  21 3C 63
        LD A,(4E85H)                ; 4EB0  3A 85 4E
        CALL SUB_4F62               ; 4EB3  CD 62 4F
        LD A,(HL)                   ; 4EB6  7E
        OR A                        ; 4EB7  B7
        RET Z                       ; 4EB8  C8
        LD BC,0102H                 ; 4EB9  01 02 01
        EX DE,HL                    ; 4EBC  EB
        CALL SUB_4875               ; 4EBD  CD 75 48
        RET                         ; 4EC0  C9
SUB_4EC1:
        PUSH HL                     ; 4EC1  E5
        INC HL                      ; 4EC2  23
        INC HL                      ; 4EC3  23
        LD A,(HL)                   ; 4EC4  7E
        OR A                        ; 4EC5  B7
        JP NZ,LOC_4ED2              ; 4EC6  C2 D2 4E
        INC HL                      ; 4EC9  23
        LD A,(4E85H)                ; 4ECA  3A 85 4E
        CP (HL)                     ; 4ECD  BE
        JP NZ,LOC_4ED2              ; 4ECE  C2 D2 4E
        INC C                       ; 4ED1  0C
LOC_4ED2:
        POP HL                      ; 4ED2  E1
        RET                         ; 4ED3  C9
LOC_4ED4:
        LD HL,633AH                 ; 4ED4  21 3A 63
        LD BC,0400H                 ; 4ED7  01 00 04
LOC_4EDA:
        INC HL                      ; 4EDA  23
        INC HL                      ; 4EDB  23
        PUSH HL                     ; 4EDC  E5
        LD A,(HL)                   ; 4EDD  7E
        INC HL                      ; 4EDE  23
        LD H,(HL)                   ; 4EDF  66
        LD L,A                      ; 4EE0  6F
        LD A,(HL)                   ; 4EE1  7E
        OR A                        ; 4EE2  B7
        JP Z,LOC_4EE7               ; 4EE3  CA E7 4E
        INC C                       ; 4EE6  0C
LOC_4EE7:
        POP HL                      ; 4EE7  E1
        DEC B                       ; 4EE8  05
        JP NZ,LOC_4EDA              ; 4EE9  C2 DA 4E
        LD A,C                      ; 4EEC  79
        OR A                        ; 4EED  B7
        CALL Z,SUB_5204             ; 4EEE  CC 04 52
        RET                         ; 4EF1  C9
SUB_4EF2:
        LD A,01H                    ; 4EF2  3E 01
        JR LOC_4EF7                 ; 4EF4  18 01
; --- SUB_4EF6: called from 3 places ---
SUB_4EF6:
        XOR A                       ; 4EF6  AF
LOC_4EF7:
        OR A                        ; 4EF7  B7
        PUSH AF                     ; 4EF8  F5
        PUSH HL                     ; 4EF9  E5
        CALL SUB_5094               ; 4EFA  CD 94 50
        LD HL,10F0H                 ; 4EFD  21 F0 10
        LD (DATA_50D8),HL           ; 4F00  22 D8 50
        POP HL                      ; 4F03  E1
LOC_4F04:
        LD (DATA_50D4),HL           ; 4F04  22 D4 50
        LD A,H                      ; 4F07  7C
        OR L                        ; 4F08  B5
        JP Z,LOC_4F25               ; 4F09  CA 25 4F
        POP AF                      ; 4F0C  F1
        PUSH AF                     ; 4F0D  F5
        LD BC,4F1CH                 ; 4F0E  01 1C 4F
        PUSH BC                     ; 4F11  C5
        EX DE,HL                    ; 4F12  EB
        LD HL,61B0H                 ; 4F13  21 B0 61
        JP Z,LOC_5112               ; 4F16  CA 12 51
        JP SUB_510E                 ; 4F19  C3 0E 51
        CALL SUB_50BA               ; 4F1C  CD BA 50
        LD HL,(MON_116E)            ; 4F1F  2A 6E 11
        JP LOC_4F04                 ; 4F22  C3 04 4F
LOC_4F25:
        CALL SUB_5090               ; 4F25  CD 90 50
        POP AF                      ; 4F28  F1
        RET                         ; 4F29  C9
SUB_4F2A:
        LD A,FFH                    ; 4F2A  3E FF
        JR LOC_4F31                 ; 4F2C  18 03
        PUSH HL                     ; 4F2E  E5
        EX (SP),HL                  ; 4F2F  E3
SUB_4F30:
        XOR A                       ; 4F30  AF
LOC_4F31:
        LD (4F4AH),A                ; 4F31  32 4A 4F
        CALL SUB_5094               ; 4F34  CD 94 50
        LD HL,(4F2EH)               ; 4F37  2A 2E 4F
LOC_4F3A:
        LD A,(HL)                   ; 4F3A  7E
        OR A                        ; 4F3B  B7
        JP Z,SUB_5090               ; 4F3C  CA 90 50
        INC HL                      ; 4F3F  23
        PUSH HL                     ; 4F40  E5
        LD L,A                      ; 4F41  6F
        DB 26H                      ; 4F42  26   (stray byte(s): disassembly boundary correction)
        NOP                         ; 4F43  00
        DB 01H                      ; 4F44  01   (stray byte(s): disassembly boundary correction)
        XOR H                       ; 4F45  AC
        LD H,C                      ; 4F46  61
        ADD HL,HL                   ; 4F47  29
        ADD HL,BC                   ; 4F48  09
        LD A,FFH                    ; 4F49  3E FF
        LD (HL),A                   ; 4F4B  77
        INC HL                      ; 4F4C  23
        LD (HL),A                   ; 4F4D  77
        DB 2AH,B2H                  ; 4F4E  2A B2   (stray byte(s): disassembly boundary correction)
        LD H,C                      ; 4F50  61
        DB 01H,10H                  ; 4F51  01 10   (stray byte(s): disassembly boundary correction)
SUB_4F53:
        NOP                         ; 4F53  00
        OR A                        ; 4F54  B7
        JR NZ,LOC_4F5A              ; 4F55  20 03
        LD BC,FFF0H                 ; 4F57  01 F0 FF
LOC_4F5A:
        ADD HL,BC                   ; 4F5A  09
        LD (WS_61B2),HL             ; 4F5B  22 B2 61
        POP HL                      ; 4F5E  E1
        JP LOC_4F3A                 ; 4F5F  C3 3A 4F
; --- SUB_4F62: called from 10 places ---
SUB_4F62:
        ADD A,A                     ; 4F62  87
        ADD A,L                     ; 4F63  85
        LD L,A                      ; 4F64  6F
        JR NC,LOC_4F68              ; 4F65  30 01
        INC H                       ; 4F67  24
LOC_4F68:
        LD A,(HL)                   ; 4F68  7E
        INC HL                      ; 4F69  23
        LD H,(HL)                   ; 4F6A  66
        LD L,A                      ; 4F6B  6F
        RET                         ; 4F6C  C9
; --- SUB_4F6D: called from 3 places ---
SUB_4F6D:
        LD HL,62D7H                 ; 4F6D  21 D7 62
        LD DE,0009H                 ; 4F70  11 09 00
        LD BC,0000H                 ; 4F73  01 00 00
LOC_4F76:
        LD A,(HL)                   ; 4F76  7E
        OR A                        ; 4F77  B7
        JP Z,LOC_4FA1               ; 4F78  CA A1 4F
        PUSH HL                     ; 4F7B  E5
        INC HL                      ; 4F7C  23
        INC HL                      ; 4F7D  23
        LD A,(HL)                   ; 4F7E  7E
        OR A                        ; 4F7F  B7
        JP NZ,LOC_4FA0              ; 4F80  C2 A0 4F
        INC HL                      ; 4F83  23
        LD A,(WS_62BC)              ; 4F84  3A BC 62
        CP (HL)                     ; 4F87  BE
        JP NZ,LOC_4FA0              ; 4F88  C2 A0 4F
        PUSH DE                     ; 4F8B  D5
        PUSH BC                     ; 4F8C  C5
        LD HL,6344H                 ; 4F8D  21 44 63
        ADD HL,BC                   ; 4F90  09
        ADD HL,BC                   ; 4F91  09
        LD A,(HL)                   ; 4F92  7E
        INC HL                      ; 4F93  23
        LD H,(HL)                   ; 4F94  66
        LD L,A                      ; 4F95  6F
        INC HL                      ; 4F96  23
        INC HL                      ; 4F97  23
        CALL SUB_5048               ; 4F98  CD 48 50
        JP Z,LOC_23EE               ; 4F9B  CA EE 23
        POP BC                      ; 4F9E  C1
        POP DE                      ; 4F9F  D1
LOC_4FA0:
        POP HL                      ; 4FA0  E1
LOC_4FA1:
        ADD HL,DE                   ; 4FA1  19
        INC C                       ; 4FA2  0C
        LD A,0AH                    ; 4FA3  3E 0A
        CP C                        ; 4FA5  B9
        JP NZ,LOC_4F76              ; 4FA6  C2 76 4F
        RET                         ; 4FA9  C9
        PUSH HL                     ; 4FAA  E5
        RET P                       ; 4FAB  F0
; --- SUB_4FAC: called from 5 places ---
SUB_4FAC:
        CALL SUB_5094               ; 4FAC  CD 94 50
        LD HL,61B0H                 ; 4FAF  21 B0 61
        LD A,(HL)                   ; 4FB2  7E
        OR A                        ; 4FB3  B7
        CALL NZ,SUB_5061            ; 4FB4  C4 61 50
        INC HL                      ; 4FB7  23
        LD A,(WS_62BD)              ; 4FB8  3A BD 62
        OR A                        ; 4FBB  B7
        JP Z,LOC_4FC3               ; 4FBC  CA C3 4F
        CP (HL)                     ; 4FBF  BE
        JP NZ,LOC_2412              ; 4FC0  C2 12 24
LOC_4FC3:
        LD HL,633CH                 ; 4FC3  21 3C 63
        LD A,(WS_62BC)              ; 4FC6  3A BC 62
        CALL SUB_4F62               ; 4FC9  CD 62 4F
        LD (4FAAH),HL               ; 4FCC  22 AA 4F
        LD A,(HL)                   ; 4FCF  7E
        OR A                        ; 4FD0  B7
        CALL Z,SUB_4FDF             ; 4FD1  CC DF 4F
        INC HL                      ; 4FD4  23
        INC HL                      ; 4FD5  23
        INC HL                      ; 4FD6  23
        LD A,(WS_61B1)              ; 4FD7  3A B1 61
        CP (HL)                     ; 4FDA  BE
        JP NZ,LOC_2412              ; 4FDB  C2 12 24
        RET                         ; 4FDE  C9
SUB_4FDF:
        LD BC,0102H                 ; 4FDF  01 02 01
        CALL SUB_4E6A               ; 4FE2  CD 6A 4E
        PUSH HL                     ; 4FE5  E5
        INC HL                      ; 4FE6  23
        INC HL                      ; 4FE7  23
        EX DE,HL                    ; 4FE8  EB
        LD HL,61B0H                 ; 4FE9  21 B0 61
        LD BC,0100H                 ; 4FEC  01 00 01
        LDIR                        ; 4FEF  ED B0
        POP HL                      ; 4FF1  E1
        RET                         ; 4FF2  C9
        LD C,L                      ; 4FF3  4D
        LD C,D                      ; 4FF4  4A
        LD D,B                      ; 4FF5  50
        LD C,D                      ; 4FF6  4A
; --- SUB_4FF7: called from 9 places ---
SUB_4FF7:
        POP HL                      ; 4FF7  E1
        LD E,(HL)                   ; 4FF8  5E
        INC HL                      ; 4FF9  23
        LD D,(HL)                   ; 4FFA  56
        INC HL                      ; 4FFB  23
        LD (4FF3H),HL               ; 4FFC  22 F3 4F
        EX DE,HL                    ; 4FFF  EB
        LD (4FF5H),HL               ; 5000  22 F5 4F
        LD HL,0001H                 ; 5003  21 01 00
        LD (DATA_50D4),HL           ; 5006  22 D4 50
        LD HL,10F0H                 ; 5009  21 F0 10
        LD (DATA_50D8),HL           ; 500C  22 D8 50
        LD HL,(DATA_50D4)           ; 500F  2A D4 50
        INC H                       ; 5012  24
        LD A,H                      ; 5013  7C
        CP 11H                      ; 5014  FE 11
        CALL Z,SUB_5044             ; 5016  CC 44 50
        LD DE,1003H                 ; 5019  11 03 10
        CALL SUB_27B0               ; 501C  CD B0 27
        JP Z,LOC_5040               ; 501F  CA 40 50
        LD (DATA_50D4),HL           ; 5022  22 D4 50
        CALL SUB_50BA               ; 5025  CD BA 50
        LD BC,5031H                 ; 5028  01 31 50
        LD DE,10F0H                 ; 502B  11 F0 10
        JP LOC_5037                 ; 502E  C3 37 50
        LD BC,500FH                 ; 5031  01 0F 50
        LD DE,1130H                 ; 5034  11 30 11
LOC_5037:
        LD HL,(4FF5H)               ; 5037  2A F5 4F
        PUSH BC                     ; 503A  C5
        PUSH HL                     ; 503B  E5
        EX DE,HL                    ; 503C  EB
        LD A,(HL)                   ; 503D  7E
        OR A                        ; 503E  B7
        RET                         ; 503F  C9
LOC_5040:
        LD HL,(4FF3H)               ; 5040  2A F3 4F
        JP (HL)                     ; 5043  E9
SUB_5044:
        LD H,01H                    ; 5044  26 01
        INC L                       ; 5046  2C
        RET                         ; 5047  C9
; --- SUB_5048: called from 10 places ---
SUB_5048:
        LD DE,5147H                 ; 5048  11 47 51
SUB_504B:
        PUSH HL                     ; 504B  E5
        INC HL                      ; 504C  23
        LD B,10H                    ; 504D  06 10
LOC_504F:
        LD A,(DE)                   ; 504F  1A
        CP (HL)                     ; 5050  BE
        JP NZ,LOC_505F              ; 5051  C2 5F 50
        INC HL                      ; 5054  23
        INC DE                      ; 5055  13
        CP 0DH                      ; 5056  FE 0D
        JP Z,LOC_505F               ; 5058  CA 5F 50
        DEC B                       ; 505B  05
        JP NZ,LOC_504F              ; 505C  C2 4F 50
LOC_505F:
        POP HL                      ; 505F  E1
        RET                         ; 5060  C9
SUB_5061:
        PUSH HL                     ; 5061  E5
        LD HL,245EH                 ; 5062  21 5E 24
        PUSH HL                     ; 5065  E5
        JR LOC_5073                 ; 5066  18 0B
SUB_5068:
        PUSH HL                     ; 5068  E5
        CALL SUB_298A               ; 5069  CD 8A 29
        LD HL,132AH                 ; 506C  21 2A 13
        PUSH HL                     ; 506F  E5
        LD HL,45C0H                 ; 5070  21 C0 45
LOC_5073:
        LD (5890H),HL               ; 5073  22 90 58
        POP HL                      ; 5076  E1
        LD (5870H),HL               ; 5077  22 70 58
        POP HL                      ; 507A  E1
        RET                         ; 507B  C9
        XOR H                       ; 507C  AC
        CP H                        ; 507D  BC
        OR A                        ; 507E  B7
        LD B,(HL)                   ; 507F  46
        CP C                        ; 5080  B9
        CP D                        ; 5081  BA
        XOR L                       ; 5082  AD
        JP Z,WS_CBCB                ; 5083  CA CB CB
        ADC A,B4H                   ; 5086  CE B4
        OR (HL)                     ; 5088  B6
        XOR L                       ; 5089  AD
        CP H                        ; 508A  BC
        OR A                        ; 508B  B7
        XOR B                       ; 508C  A8
        CP (HL)                     ; 508D  BE
        OR E                        ; 508E  B3
        CP E                        ; 508F  BB
SUB_5090:
        LD A,01H                    ; 5090  3E 01
        JR LOC_5095                 ; 5092  18 01
; --- SUB_5094: called from 4 places ---
SUB_5094:
        XOR A                       ; 5094  AF
LOC_5095:
        LD (50A3H),A                ; 5095  32 A3 50
        LD A,(WS_62BC)              ; 5098  3A BC 62
        LD (50ABH),A                ; 509B  32 AB 50
        LD IX,50ABH                 ; 509E  DD 21 AB 50
        LD A,00H                    ; 50A2  3E 00
        OR A                        ; 50A4  B7
        JP Z,LOC_51FE               ; 50A5  CA FE 51
        JP LOC_5201                 ; 50A8  C3 01 52
        NOP                         ; 50AB  00
        NOP                         ; 50AC  00
        RRCA                        ; 50AD  0F
        NOP                         ; 50AE  00
        LD BC,61B0H                 ; 50AF  01 B0 61
        RST 38H                     ; 50B2  FF
        NOP                         ; 50B3  00
        RST 38H                     ; 50B4  FF
; --- SUB_50B5: called from 12 places ---
SUB_50B5:
        LD A,01H                    ; 50B5  3E 01
        JP LOC_50BB                 ; 50B7  C3 BB 50
; --- SUB_50BA: called from 13 places ---
SUB_50BA:
        XOR A                       ; 50BA  AF
LOC_50BB:
        LD (50D2H),A                ; 50BB  32 D2 50
        LD A,(WS_62BC)              ; 50BE  3A BC 62
        LD IX,50D3H                 ; 50C1  DD 21 D3 50
        LD (50D3H),A                ; 50C5  32 D3 50
        LD A,(50D2H)                ; 50C8  3A D2 50
        OR A                        ; 50CB  B7
        JP Z,LOC_51FE               ; 50CC  CA FE 51
        JP LOC_5201                 ; 50CF  C3 01 52
        NOP                         ; 50D2  00
        NOP                         ; 50D3  00
DATA_50D4:
        LD BC,8001H                 ; 50D4  01 01 80
        NOP                         ; 50D7  00
DATA_50D8:
        RET P                       ; 50D8  F0
        DB 10H                      ; 50D9  10   (stray byte(s): disassembly boundary correction)
        RST 38H                     ; 50DA  FF
        NOP                         ; 50DB  00
        RST 38H                     ; 50DC  FF
; --- SUB_50DD: called from 3 places ---
SUB_50DD:
        LD HL,(WS_62C4)             ; 50DD  2A C4 62
        INC HL                      ; 50E0  23
        INC HL                      ; 50E1  23
        PUSH HL                     ; 50E2  E5
        INC HL                      ; 50E3  23
        INC HL                      ; 50E4  23
        INC HL                      ; 50E5  23
        LD E,03H                    ; 50E6  1E 03
LOC_50E8:
        INC E                       ; 50E8  1C
        LD A,46H                    ; 50E9  3E 46
        CP E                        ; 50EB  BB
        JP Z,LOC_2416               ; 50EC  CA 16 24
        LD D,00H                    ; 50EF  16 00
        CALL SUB_50FC               ; 50F1  CD FC 50
        LD D,08H                    ; 50F4  16 08
        CALL SUB_50FC               ; 50F6  CD FC 50
        JP LOC_50E8                 ; 50F9  C3 E8 50
SUB_50FC:
        INC HL                      ; 50FC  23
        LD A,(HL)                   ; 50FD  7E
        CP FFH                      ; 50FE  FE FF
        RET Z                       ; 5100  C8
        INC SP                      ; 5101  33
        INC SP                      ; 5102  33
LOC_5103:
        INC D                       ; 5103  14
        SRL A                       ; 5104  CB 3F
        JP C,LOC_5103               ; 5106  DA 03 51
        POP HL                      ; 5109  E1
        CALL SUB_510E               ; 510A  CD 0E 51
        RET                         ; 510D  C9
SUB_510E:
        LD A,C6H                    ; 510E  3E C6
        JR LOC_5114                 ; 5110  18 02
LOC_5112:
        LD A,86H                    ; 5112  3E 86
LOC_5114:
        LD (513DH),A                ; 5114  32 3D 51
        PUSH HL                     ; 5117  E5
        PUSH DE                     ; 5118  D5
        INC HL                      ; 5119  23
        INC HL                      ; 511A  23
        LD C,(HL)                   ; 511B  4E
        INC HL                      ; 511C  23
        LD B,(HL)                   ; 511D  46
        CP C6H                      ; 511E  FE C6
        JR NZ,LOC_5124              ; 5120  20 02
        INC BC                      ; 5122  03
        INC BC                      ; 5123  03
LOC_5124:
        DEC BC                      ; 5124  0B
        LD (HL),B                   ; 5125  70
        DEC HL                      ; 5126  2B
        LD (HL),C                   ; 5127  71
        LD B,E                      ; 5128  43
        DEC B                       ; 5129  05
        DEC B                       ; 512A  05
        DEC B                       ; 512B  05
LOC_512C:
        INC HL                      ; 512C  23
        INC HL                      ; 512D  23
        DJNZ LOC_512C               ; 512E  10 FC
        LD A,D                      ; 5130  7A
        DEC A                       ; 5131  3D
        CP 08H                      ; 5132  FE 08
        JR C,LOC_5137               ; 5134  38 01
        INC HL                      ; 5136  23
LOC_5137:
        ADD A,A                     ; 5137  87
        ADD A,A                     ; 5138  87
        ADD A,A                     ; 5139  87
        AND 38H                     ; 513A  E6 38
        OR FFH                      ; 513C  F6 FF
        LD (5142H),A                ; 513E  32 42 51
        SET 7,A                     ; 5141  CB FF
        POP DE                      ; 5143  D1
        POP HL                      ; 5144  E1
        RET                         ; 5145  C9
DATA_5146:
        LD (BC),A                   ; 5146  02
        DEC C                       ; 5147  0D
        DEC C                       ; 5148  0D
        DEC C                       ; 5149  0D
        DEC C                       ; 514A  0D
        DEC C                       ; 514B  0D
        DEC C                       ; 514C  0D
        DEC C                       ; 514D  0D
        DEC C                       ; 514E  0D
        DEC C                       ; 514F  0D
        DEC C                       ; 5150  0D
        DEC C                       ; 5151  0D
        DEC C                       ; 5152  0D
        DEC C                       ; 5153  0D
        DEC C                       ; 5154  0D
        DEC C                       ; 5155  0D
        DEC C                       ; 5156  0D
        NOP                         ; 5157  00
        RST 38H                     ; 5158  FF
        NOP                         ; 5159  00
; --- SUB_515A: called from 6 places ---
SUB_515A:
        PUSH HL                     ; 515A  E5
        LD HL,62BBH                 ; 515B  21 BB 62
        LD B,07H                    ; 515E  06 07
LOC_5160:
        LD (HL),00H                 ; 5160  36 00
        INC HL                      ; 5162  23
        DJNZ LOC_5160               ; 5163  10 FB
        LD HL,5147H                 ; 5165  21 47 51
        LD B,10H                    ; 5168  06 10
LOC_516A:
        LD (HL),0DH                 ; 516A  36 0D
        INC HL                      ; 516C  23
        DJNZ LOC_516A               ; 516D  10 FB
        LD (HL),00H                 ; 516F  36 00
        POP HL                      ; 5171  E1
        CALL SUB_27D2               ; 5172  CD D2 27
        INC L                       ; 5175  2C
        LD A,B                      ; 5176  78
        LD D,C                      ; 5177  51
        CP 9CH                      ; 5178  FE 9C
        JP NZ,LOC_5191              ; 517A  C2 91 51
        INC HL                      ; 517D  23
        CALL SUB_1204               ; 517E  CD 04 12
        CALL SUB_27E1               ; 5181  CD E1 27
        ADD HL,HL                   ; 5184  29
        PUSH HL                     ; 5185  E5
        LD HL,62BBH                 ; 5186  21 BB 62
        LD (HL),01H                 ; 5189  36 01
        INC HL                      ; 518B  23
        LD (HL),E                   ; 518C  73
        INC HL                      ; 518D  23
        LD (HL),D                   ; 518E  72
        POP HL                      ; 518F  E1
        RET                         ; 5190  C9
LOC_5191:
        LD A,(DATA_49AC)            ; 5191  3A AC 49
        LD (WS_62BC),A              ; 5194  32 BC 62
        PUSH HL                     ; 5197  E5
        CALL SUB_27D2               ; 5198  CD D2 27
        LD B,(HL)                   ; 519B  46
        SUB 51H                     ; 519C  D6 51
        CALL SUB_27D2               ; 519E  CD D2 27
        LD B,H                      ; 51A1  44
        SUB 51H                     ; 51A2  D6 51
        POP AF                      ; 51A4  F1
        CALL SUB_27A7               ; 51A5  CD A7 27
        CALL C,SUB_51AE             ; 51A8  DC AE 51
        JP LOC_51DD                 ; 51AB  C3 DD 51
SUB_51AE:
        AND 0FH                     ; 51AE  E6 0F
        DEC A                       ; 51B0  3D
        CP 04H                      ; 51B1  FE 04
        JP NC,LOC_2442              ; 51B3  D2 42 24
        LD (WS_62BC),A              ; 51B6  32 BC 62
        CALL SUB_277A               ; 51B9  CD 7A 27
        CP 40H                      ; 51BC  FE 40
        RET NZ                      ; 51BE  C0
SUB_51BF:
        INC HL                      ; 51BF  23
        CALL SUB_281D               ; 51C0  CD 1D 28
        LD (DE),A                   ; 51C3  12
        INC H                       ; 51C4  24
        LD A,D                      ; 51C5  7A
        OR A                        ; 51C6  B7
        JP NZ,LOC_2412              ; 51C7  C2 12 24
        LD A,E                      ; 51CA  7B
        DEC A                       ; 51CB  3D
        CP 7FH                      ; 51CC  FE 7F
        JP NC,LOC_2412              ; 51CE  D2 12 24
        INC A                       ; 51D1  3C
        LD (WS_62BD),A              ; 51D2  32 BD 62
        RET                         ; 51D5  C9
        POP HL                      ; 51D6  E1
        LD A,(HL)                   ; 51D7  7E
        CP 40H                      ; 51D8  FE 40
        CALL Z,SUB_51BF             ; 51DA  CC BF 51
LOC_51DD:
        CALL SUB_27D2               ; 51DD  CD D2 27
        INC L                       ; 51E0  2C
        EX (SP),HL                  ; 51E1  E3
        LD D,C                      ; 51E2  51
        CALL SUB_1A58               ; 51E3  CD 58 1A
        LD A,D                      ; 51E6  7A
        OR A                        ; 51E7  B7
        JP Z,LOC_2426               ; 51E8  CA 26 24
        LD A,C                      ; 51EB  79
        DEC A                       ; 51EC  3D
        CP 10H                      ; 51ED  FE 10
        JP NC,LOC_2426              ; 51EF  D2 26 24
        PUSH HL                     ; 51F2  E5
        CALL SUB_2959               ; 51F3  CD 59 29
        LD HL,5147H                 ; 51F6  21 47 51
        EX DE,HL                    ; 51F9  EB
        LDIR                        ; 51FA  ED B0
        POP HL                      ; 51FC  E1
        RET                         ; 51FD  C9
LOC_51FE:
        JP LOC_5216                 ; 51FE  C3 16 52
LOC_5201:
        JP LOC_5219                 ; 5201  C3 19 52
; --- SUB_5204: called from 6 places ---
SUB_5204:
        JP LOC_5210                 ; 5204  C3 10 52
        NOP                         ; 5207  00
        RST 38H                     ; 5208  FF
        NOP                         ; 5209  00
        RST 38H                     ; 520A  FF
        NOP                         ; 520B  00
        RST 38H                     ; 520C  FF
        NOP                         ; 520D  00
        RST 38H                     ; 520E  FF
        NOP                         ; 520F  00
LOC_5210:
        JP SUB_5236                 ; 5210  C3 36 52
        JP SUB_54B5                 ; 5213  C3 B5 54
LOC_5216:
        JP LOC_533C                 ; 5216  C3 3C 53
LOC_5219:
        JP LOC_5407                 ; 5219  C3 07 54
        JP LOC_553C                 ; 521C  C3 3C 55
SUB_521F:
        PUSH BC                     ; 521F  C5
        LD BC,08F8H                 ; 5220  01 F8 08
        IN A,(C)                    ; 5223  ED 78
        LD BC,0000H                 ; 5225  01 00 00
LOC_5228:
        DEC BC                      ; 5228  0B
        NOP                         ; 5229  00
        NOP                         ; 522A  00
        LD A,B                      ; 522B  78
        OR C                        ; 522C  B1
        JR NZ,LOC_5228              ; 522D  20 F9
        LD A,01H                    ; 522F  3E 01
        LD (MON_1002),A             ; 5231  32 02 10
        POP BC                      ; 5234  C1
        RET                         ; 5235  C9
; --- SUB_5236: called from 4 places ---
SUB_5236:
        PUSH BC                     ; 5236  C5
        CALL SUB_53FC               ; 5237  CD FC 53
        LD BC,00F8H                 ; 523A  01 F8 00
        IN A,(C)                    ; 523D  ED 78
        XOR A                       ; 523F  AF
        LD (MON_1002),A             ; 5240  32 02 10
        LD (MON_1003),A             ; 5243  32 03 10   <-- UNRESOLVED ALIGNMENT: also targeted as 5245H
        LD (MON_1004),A             ; 5246  32 04 10
        LD (MON_1005),A             ; 5249  32 05 10
        LD (MON_1006),A             ; 524C  32 06 10
        POP BC                      ; 524F  C1
        RET                         ; 5250  C9
; --- SUB_5251: called from 4 places ---
SUB_5251:
        CALL SUB_525C               ; 5251  CD 5C 52
        XOR A                       ; 5254  AF
        OUT (F9H),A                 ; 5255  D3 F9
        LD (MON_1000),A             ; 5257  32 00 10
        OUT (FAH),A                 ; 525A  D3 FA
; --- SUB_525C: called from 4 places ---
SUB_525C:
        PUSH BC                     ; 525C  C5
        LD BC,0000H                 ; 525D  01 00 00
LOC_5260:
        IN A,(F9H)                  ; 5260  DB F9
        AND 03H                     ; 5262  E6 03
        CP 02H                      ; 5264  FE 02
        JR NZ,LOC_526A              ; 5266  20 02
        POP BC                      ; 5268  C1
        RET                         ; 5269  C9
LOC_526A:
        DEC BC                      ; 526A  0B
        LD A,B                      ; 526B  78
        OR C                        ; 526C  B1
        JR NZ,LOC_5260              ; 526D  20 F1
        POP BC                      ; 526F  C1
        LD A,32H                    ; 5270  3E 32
        LD (MON_1008),A             ; 5272  32 08 10
        CALL SUB_5236               ; 5275  CD 36 52
        JP MON_100B                 ; 5278  C3 0B 10
; --- SUB_527B: called from 3 places ---
SUB_527B:
        IN A,(FAH)                  ; 527B  DB FA
        AND F0H                     ; 527D  E6 F0
        RLCA                        ; 527F  07
        JR NC,SUB_527B              ; 5280  30 F9
        AND F0H                     ; 5282  E6 F0
        RRCA                        ; 5284  0F
        RRCA                        ; 5285  0F
        RRCA                        ; 5286  0F
        RRCA                        ; 5287  0F
        OR A                        ; 5288  B7
        RET Z                       ; 5289  C8
        CP 06H                      ; 528A  FE 06
        JR Z,LOC_52A0               ; 528C  28 12
        CP 0CH                      ; 528E  FE 0C
        JR NZ,LOC_5296              ; 5290  20 04
        LD A,32H                    ; 5292  3E 32
        JR LOC_52A0                 ; 5294  18 0A
LOC_5296:
        CP 04H                      ; 5296  FE 04
        JR NZ,LOC_529E              ; 5298  20 04
        LD A,36H                    ; 529A  3E 36
        JR LOC_52A0                 ; 529C  18 02
LOC_529E:
        LD A,29H                    ; 529E  3E 29
LOC_52A0:
        LD (MON_1008),A             ; 52A0  32 08 10
        SCF                         ; 52A3  37
        RET                         ; 52A4  C9
; --- SUB_52A5: called from 3 places ---
SUB_52A5:
        PUSH BC                     ; 52A5  C5
        PUSH HL                     ; 52A6  E5
        LD A,(MON_1002)             ; 52A7  3A 02 10
        RRCA                        ; 52AA  0F
        CALL NC,SUB_521F            ; 52AB  D4 1F 52
        LD A,(IX+0H)                ; 52AE  DD 7E 00
        AND 03H                     ; 52B1  E6 03
        OR 1CH                      ; 52B3  F6 1C
        LD (MON_1001),A             ; 52B5  32 01 10
        AND 0FH                     ; 52B8  E6 0F
        LD B,A                      ; 52BA  47
        LD C,F8H                    ; 52BB  0E F8
        IN H,(C)                    ; 52BD  ED 60
        LD A,32H                    ; 52BF  3E 32
LOC_52C1:
        CALL SUB_53FC               ; 52C1  CD FC 53
        DEC A                       ; 52C4  3D
        JR NZ,LOC_52C1              ; 52C5  20 FA
        LD BC,0000H                 ; 52C7  01 00 00
LOC_52CA:
        IN A,(F9H)                  ; 52CA  DB F9
        AND 07H                     ; 52CC  E6 07
        CP 06H                      ; 52CE  FE 06
        JR NZ,LOC_52E9              ; 52D0  20 17
        LD C,(IX+0H)                ; 52D2  DD 4E 00
        LD B,00H                    ; 52D5  06 00
        LD HL,1003H                 ; 52D7  21 03 10
        ADD HL,BC                   ; 52DA  09
        BIT 0,(HL)                  ; 52DB  CB 46
        JR Z,LOC_52E2               ; 52DD  28 03
LOC_52DF:
        POP HL                      ; 52DF  E1
        POP BC                      ; 52E0  C1
        RET                         ; 52E1  C9
LOC_52E2:
        CALL SUB_5251               ; 52E2  CD 51 52
        SET 0,(HL)                  ; 52E5  CB C6
        JR LOC_52DF                 ; 52E7  18 F6
LOC_52E9:
        DEC BC                      ; 52E9  0B
        LD A,B                      ; 52EA  78
        OR C                        ; 52EB  B1
        JR NZ,LOC_52CA              ; 52EC  20 DC
        LD A,32H                    ; 52EE  3E 32
        LD (MON_1008),A             ; 52F0  32 08 10
        CALL SUB_5236               ; 52F3  CD 36 52
        JP MON_100B                 ; 52F6  C3 0B 10
; --- SUB_52F9: called from 3 places ---
SUB_52F9:
        LD A,(IX+0H)                ; 52F9  DD 7E 00
        CP 04H                      ; 52FC  FE 04
        JR NC,LOC_5318              ; 52FE  30 18
        LD A,(IX+1H)                ; 5300  DD 7E 01
        CP 46H                      ; 5303  FE 46
        JR NC,LOC_5318              ; 5305  30 11
        LD A,(IX+2H)                ; 5307  DD 7E 02
        OR A                        ; 530A  B7
        JR Z,LOC_5318               ; 530B  28 0B
        CP 11H                      ; 530D  FE 11
        JR NC,LOC_5318              ; 530F  30 07
        LD A,(IX+3H)                ; 5311  DD 7E 03
        OR (IX+4H)                  ; 5314  DD B6 04
        RET NZ                      ; 5317  C0
LOC_5318:
        LD A,38H                    ; 5318  3E 38
        LD (MON_1008),A             ; 531A  32 08 10
        CALL SUB_5236               ; 531D  CD 36 52
        JP MON_100B                 ; 5320  C3 0B 10
SUB_5323:
        PUSH AF                     ; 5323  F5
        PUSH BC                     ; 5324  C5
        CALL SUB_53FC               ; 5325  CD FC 53
        LD C,F8H                    ; 5328  0E F8
        LD B,08H                    ; 532A  06 08
        IN A,(C)                    ; 532C  ED 78
        POP BC                      ; 532E  C1
        POP AF                      ; 532F  F1
        RET                         ; 5330  C9
; --- SUB_5331: called from 3 places ---
SUB_5331:
        PUSH AF                     ; 5331  F5
        LD A,(MON_119C)             ; 5332  3A 9C 11
        CP F0H                      ; 5335  FE F0
        JR NZ,LOC_533A              ; 5337  20 01
        EI                          ; 5339  FB
LOC_533A:
        POP AF                      ; 533A  F1
        RET                         ; 533B  C9
LOC_533C:
        CALL SUB_52F9               ; 533C  CD F9 52
        LD A,0AH                    ; 533F  3E 0A
        LD (MON_1007),A             ; 5341  32 07 10
LOC_5344:
        CALL SUB_52A5               ; 5344  CD A5 52
        LD A,(MON_1001)             ; 5347  3A 01 10
        LD B,A                      ; 534A  47
        LD C,F8H                    ; 534B  0E F8
        EXX                         ; 534D  D9
        LD C,FBH                    ; 534E  0E FB
        LD E,(IX+3H)                ; 5350  DD 5E 03
        LD D,(IX+4H)                ; 5353  DD 56 04
        RL E                        ; 5356  CB 13
        RL D                        ; 5358  CB 12
        LD E,03H                    ; 535A  1E 03
        LD L,(IX+5H)                ; 535C  DD 6E 05
        LD H,(IX+6H)                ; 535F  DD 66 06
        LD A,(IX+1H)                ; 5362  DD 7E 01
        LD (IX+7H),A                ; 5365  DD 77 07
        LD A,(IX+2H)                ; 5368  DD 7E 02
        LD (IX+8H),A                ; 536B  DD 77 08
LOC_536E:
        CALL SUB_525C               ; 536E  CD 5C 52
        XOR A                       ; 5371  AF
        LD A,(IX+7H)                ; 5372  DD 7E 07
        RRA                         ; 5375  1F
        OUT (F9H),A                 ; 5376  D3 F9
        LD A,(IX+8H)                ; 5378  DD 7E 08
        JR NC,LOC_537F              ; 537B  30 02
        OR 80H                      ; 537D  F6 80
LOC_537F:
        OUT (F8H),A                 ; 537F  D3 F8
        CALL SUB_53F4               ; 5381  CD F4 53
        LD A,70H                    ; 5384  3E 70
        LD (MON_1000),A             ; 5386  32 00 10
        DI                          ; 5389  F3
        OUT (FAH),A                 ; 538A  D3 FA
LOC_538C:
        LD B,80H                    ; 538C  06 80
LOC_538E:
        IN A,(F9H)                  ; 538E  DB F9
        AND E                       ; 5390  A3
        JR Z,LOC_538E               ; 5391  28 FB
        RRCA                        ; 5393  0F
        JR NC,LOC_53A5              ; 5394  30 0F
        INI                         ; 5396  ED A2
        JP NZ,LOC_538E              ; 5398  C2 8E 53
        INC (IX+8H)                 ; 539B  DD 34 08
        DEC D                       ; 539E  15
        JP NZ,LOC_538C              ; 539F  C2 8C 53
        EXX                         ; 53A2  D9
        IN A,(C)                    ; 53A3  ED 78
LOC_53A5:
        CALL SUB_527B               ; 53A5  CD 7B 52
        JR C,LOC_53C1               ; 53A8  38 17
        PUSH AF                     ; 53AA  F5
        LD A,(IX+8H)                ; 53AB  DD 7E 08
        CP 11H                      ; 53AE  FE 11
        JR C,LOC_53B9               ; 53B0  38 07
        LD (IX+8H),01H              ; 53B2  DD 36 08 01
        INC (IX+7H)                 ; 53B6  DD 34 07
LOC_53B9:
        POP AF                      ; 53B9  F1
        CALL SUB_5323               ; 53BA  CD 23 53
        CALL SUB_5331               ; 53BD  CD 31 53
        RET                         ; 53C0  C9
LOC_53C1:
        CP 06H                      ; 53C1  FE 06
        JR NZ,LOC_53CF              ; 53C3  20 0A
        INC (IX+7H)                 ; 53C5  DD 34 07
        LD (IX+8H),01H              ; 53C8  DD 36 08 01
        JP LOC_536E                 ; 53CC  C3 6E 53
LOC_53CF:
        LD A,(MON_1007)             ; 53CF  3A 07 10
        DEC A                       ; 53D2  3D
        LD (MON_1007),A             ; 53D3  32 07 10
        JP Z,LOC_53DF               ; 53D6  CA DF 53
        CALL SUB_5251               ; 53D9  CD 51 52
        JP LOC_5344                 ; 53DC  C3 44 53
LOC_53DF:
        LD A,(IX+7H)                ; 53DF  DD 7E 07
        LD (MON_1009),A             ; 53E2  32 09 10
        LD A,(IX+8H)                ; 53E5  DD 7E 08
        LD (MON_100A),A             ; 53E8  32 0A 10
LOC_53EB:
        CALL SUB_5236               ; 53EB  CD 36 52
        CALL SUB_5331               ; 53EE  CD 31 53
        JP MON_100B                 ; 53F1  C3 0B 10
; --- SUB_53F4: called from 4 places ---
SUB_53F4:
        PUSH AF                     ; 53F4  F5
        LD A,0AH                    ; 53F5  3E 0A
LOC_53F7:
        DEC A                       ; 53F7  3D
        JR NZ,LOC_53F7              ; 53F8  20 FD
        POP AF                      ; 53FA  F1
        RET                         ; 53FB  C9
; --- SUB_53FC: called from 3 places ---
SUB_53FC:
        PUSH AF                     ; 53FC  F5
        LD A,0AH                    ; 53FD  3E 0A
LOC_53FF:
        CALL SUB_53F4               ; 53FF  CD F4 53
        DEC A                       ; 5402  3D
        JR NZ,LOC_53FF              ; 5403  20 FA
        POP AF                      ; 5405  F1
        RET                         ; 5406  C9
LOC_5407:
        CALL SUB_52F9               ; 5407  CD F9 52
        LD A,0AH                    ; 540A  3E 0A
        LD (MON_1007),A             ; 540C  32 07 10
LOC_540F:
        CALL SUB_52A5               ; 540F  CD A5 52
        LD A,(MON_1001)             ; 5412  3A 01 10
        LD B,A                      ; 5415  47
        LD C,F8H                    ; 5416  0E F8
        EXX                         ; 5418  D9
        LD C,FBH                    ; 5419  0E FB
        LD E,(IX+3H)                ; 541B  DD 5E 03
        LD D,(IX+4H)                ; 541E  DD 56 04
        RL E                        ; 5421  CB 13
        RL D                        ; 5423  CB 12
        LD E,03H                    ; 5425  1E 03
        LD L,(IX+5H)                ; 5427  DD 6E 05
        LD H,(IX+6H)                ; 542A  DD 66 06
        LD A,(IX+1H)                ; 542D  DD 7E 01
        LD (IX+7H),A                ; 5430  DD 77 07
        LD A,(IX+2H)                ; 5433  DD 7E 02
        LD (IX+8H),A                ; 5436  DD 77 08
LOC_5439:
        CALL SUB_525C               ; 5439  CD 5C 52
        XOR A                       ; 543C  AF
        LD A,(IX+7H)                ; 543D  DD 7E 07
        RRA                         ; 5440  1F
        OUT (F9H),A                 ; 5441  D3 F9
        LD A,(IX+8H)                ; 5443  DD 7E 08
        JR NC,LOC_544A              ; 5446  30 02
LOC_5448:
        OR 80H                      ; 5448  F6 80
LOC_544A:
        OUT (F8H),A                 ; 544A  D3 F8
        CALL SUB_53F4               ; 544C  CD F4 53
        LD A,B0H                    ; 544F  3E B0
        DB 32H,00H                  ; 5451  32 00   (stray byte(s): disassembly boundary correction)
        DJNZ LOC_5448               ; 5453  10 F3
        OUT (FAH),A                 ; 5455  D3 FA
LOC_5457:
        LD B,80H                    ; 5457  06 80
LOC_5459:
        IN A,(F9H)                  ; 5459  DB F9
        AND E                       ; 545B  A3
        JR Z,LOC_5459               ; 545C  28 FB
        RRCA                        ; 545E  0F
        JR NC,LOC_5470              ; 545F  30 0F
        OUTI                        ; 5461  ED A3
        JP NZ,LOC_5459              ; 5463  C2 59 54
        INC (IX+8H)                 ; 5466  DD 34 08
        DEC D                       ; 5469  15
        JP NZ,LOC_5457              ; 546A  C2 57 54
        EXX                         ; 546D  D9
        IN A,(C)                    ; 546E  ED 78
LOC_5470:
        CALL SUB_527B               ; 5470  CD 7B 52
        JR C,LOC_5486               ; 5473  38 11
        LD A,(IX+8H)                ; 5475  DD 7E 08
        CP 11H                      ; 5478  FE 11
        JR C,LOC_54A4               ; 547A  38 28
        LD (IX+8H),01H              ; 547C  DD 36 08 01
        INC (IX+7H)                 ; 5480  DD 34 07
        JP LOC_54A4                 ; 5483  C3 A4 54
LOC_5486:
        CP 06H                      ; 5486  FE 06
        JR NZ,LOC_5494              ; 5488  20 0A
        INC (IX+7H)                 ; 548A  DD 34 07
        LD (IX+8H),01H              ; 548D  DD 36 08 01
        JP LOC_5439                 ; 5491  C3 39 54
LOC_5494:
        LD A,(MON_1007)             ; 5494  3A 07 10
        DEC A                       ; 5497  3D
        LD (MON_1007),A             ; 5498  32 07 10
        JP Z,LOC_53DF               ; 549B  CA DF 53
        CALL SUB_5251               ; 549E  CD 51 52
        JP LOC_540F                 ; 54A1  C3 0F 54
LOC_54A4:
        CALL SUB_54B5               ; 54A4  CD B5 54
        RET NC                      ; 54A7  D0
        LD A,(MON_1007)             ; 54A8  3A 07 10
        DEC A                       ; 54AB  3D
        LD (MON_1007),A             ; 54AC  32 07 10
        JP NZ,LOC_540F              ; 54AF  C2 0F 54
        JP LOC_53EB                 ; 54B2  C3 EB 53
SUB_54B5:
        CALL SUB_52F9               ; 54B5  CD F9 52
        LD A,02H                    ; 54B8  3E 02
        LD (MON_100E),A             ; 54BA  32 0E 10
LOC_54BD:
        CALL SUB_52A5               ; 54BD  CD A5 52
        LD A,(MON_1001)             ; 54C0  3A 01 10
        LD B,A                      ; 54C3  47
        LD C,F8H                    ; 54C4  0E F8
        EXX                         ; 54C6  D9
        LD C,FBH                    ; 54C7  0E FB
        LD H,(IX+1H)                ; 54C9  DD 66 01
        LD L,(IX+2H)                ; 54CC  DD 6E 02
        LD E,(IX+3H)                ; 54CF  DD 5E 03
        LD D,(IX+4H)                ; 54D2  DD 56 04
        RL E                        ; 54D5  CB 13
        RL D                        ; 54D7  CB 12
LOC_54D9:
        CALL SUB_525C               ; 54D9  CD 5C 52
        XOR A                       ; 54DC  AF
        LD A,H                      ; 54DD  7C
        RRA                         ; 54DE  1F
        OUT (F9H),A                 ; 54DF  D3 F9
        LD A,L                      ; 54E1  7D
        JR NC,LOC_54E6              ; 54E2  30 02
        OR 80H                      ; 54E4  F6 80
LOC_54E6:
        OUT (F8H),A                 ; 54E6  D3 F8
        CALL SUB_53F4               ; 54E8  CD F4 53
        LD A,70H                    ; 54EB  3E 70
        LD (MON_1000),A             ; 54ED  32 00 10
        DI                          ; 54F0  F3
        OUT (FAH),A                 ; 54F1  D3 FA
LOC_54F3:
        LD B,80H                    ; 54F3  06 80
LOC_54F5:
        IN A,(F9H)                  ; 54F5  DB F9
        AND 03H                     ; 54F7  E6 03
        JR Z,LOC_54F5               ; 54F9  28 FA
        RRCA                        ; 54FB  0F
        JR NC,LOC_550A              ; 54FC  30 0C
        IN A,(C)                    ; 54FE  ED 78
        DJNZ LOC_54F5               ; 5500  10 F3
        INC L                       ; 5502  2C
        DEC D                       ; 5503  15
        JR NZ,LOC_54F3              ; 5504  20 ED
        EXX                         ; 5506  D9
        IN A,(C)                    ; 5507  ED 78
        EXX                         ; 5509  D9
LOC_550A:
        CALL SUB_527B               ; 550A  CD 7B 52
        JR C,LOC_5516               ; 550D  38 07
LOC_550F:
        CALL SUB_5323               ; 550F  CD 23 53
        CALL SUB_5331               ; 5512  CD 31 53
        RET                         ; 5515  C9
LOC_5516:
        CP 06H                      ; 5516  FE 06
        JR NZ,LOC_5520              ; 5518  20 06
        INC H                       ; 551A  24
        LD L,01H                    ; 551B  2E 01
        JP LOC_54D9                 ; 551D  C3 D9 54
LOC_5520:
        LD A,H                      ; 5520  7C
        LD (MON_1009),A             ; 5521  32 09 10
        LD A,L                      ; 5524  7D
        LD (MON_100A),A             ; 5525  32 0A 10
        LD A,(MON_100E)             ; 5528  3A 0E 10
        DEC A                       ; 552B  3D
        LD (MON_100E),A             ; 552C  32 0E 10
        JP Z,LOC_5538               ; 552F  CA 38 55
        CALL SUB_5251               ; 5532  CD 51 52
        JP LOC_54BD                 ; 5535  C3 BD 54
LOC_5538:
        SCF                         ; 5538  37
        JP LOC_550F                 ; 5539  C3 0F 55
LOC_553C:
        LD D,45H                    ; 553C  16 45
        SBC A,E                     ; 553E  9B
        SUB (HL)                    ; 553F  96
        SUB D                       ; 5540  92
        OR B                        ; 5541  B0
        SBC A,H                     ; 5542  9C
        SUB D                       ; 5543  92
        SBC A,H                     ; 5544  9C
        JR NZ,LOC_559A              ; 5545  20 53
        LD D,B                      ; 5547  50
        DEC L                       ; 5548  2D
        LD (HL),30H                 ; 5549  36 30
        DB 31H,35H                  ; 554B  31 35   (stray byte(s): disassembly boundary correction)
        JR NZ,LOC_556F              ; 554D  20 20
        LD D,(HL)                   ; 554F  56
        SUB D                       ; 5550  92
        SBC A,L                     ; 5551  9D
        AND H                       ; 5552  A4
        AND (HL)                    ; 5553  A6
        OR A                        ; 5554  B7
        OR B                        ; 5555  B0
        JR NZ,LOC_558A              ; 5556  20 32
        LD L,35H                    ; 5558  2E 35
        DEC C                       ; 555A  0D
        CALL SUB_2B2A               ; 555B  CD 2A 2B
        CALL SUB_1204               ; 555E  CD 04 12
        CALL SUB_27E1               ; 5561  CD E1 27
        ADD HL,HL                   ; 5564  29
        PUSH HL                     ; 5565  E5
        EX DE,HL                    ; 5566  EB
        CALL SUB_28FD               ; 5567  CD FD 28
        LD A,A                      ; 556A  7F
        LD D,L                      ; 556B  55
        JR NZ,LOC_557F              ; 556C  20 11
        CALL SUB_230F               ; 556E  CD 0F 23
        CALL SUB_253E               ; 5571  CD 3E 25
        LD HL,6000H                 ; 5574  21 00 60
LOC_5577:
        CALL SUB_294B               ; 5577  CD 4B 29
        CALL SUB_2A74               ; 557A  CD 74 2A
        JR LOC_55D8                 ; 557D  18 59
LOC_557F:
        LD HL,231FH                 ; 557F  21 1F 23
        JR LOC_5577                 ; 5582  18 F3
        CALL SUB_1221               ; 5584  CD 21 12
        PUSH DE                     ; 5587  D5
        DB CDH,E1H                  ; 5588  CD E1   (stray byte(s): disassembly boundary correction)
LOC_558A:
        DAA                         ; 558A  27
        INC L                       ; 558B  2C
        CALL SUB_2141               ; 558C  CD 41 21
        CALL SUB_27E1               ; 558F  CD E1 27
        ADD HL,HL                   ; 5592  29
        EX (SP),HL                  ; 5593  E3
        LD H,L                      ; 5594  65
        PUSH HL                     ; 5595  E5
        LD H,00H                    ; 5596  26 00
        PUSH DE                     ; 5598  D5
        PUSH BC                     ; 5599  C5
LOC_559A:
        POP DE                      ; 559A  D1
        PUSH DE                     ; 559B  D5
        CALL SUB_27EE               ; 559C  CD EE 27
        ADD A,D                     ; 559F  82
        INC HL                      ; 55A0  23
        LD A,D                      ; 55A1  7A
        OR A                        ; 55A2  B7
        JP NZ,LOC_2382              ; 55A3  C2 82 23
        LD HL,231FH                 ; 55A6  21 1F 23
        PUSH DE                     ; 55A9  D5
        CALL SUB_2A5C               ; 55AA  CD 5C 2A
        PUSH DE                     ; 55AD  D5
        CALL SUB_2959               ; 55AE  CD 59 29
        EXX                         ; 55B1  D9
        POP DE                      ; 55B2  D1
        POP BC                      ; 55B3  C1
        PUSH BC                     ; 55B4  C5
        EXX                         ; 55B5  D9
        POP BC                      ; 55B6  C1
        CALL SUB_28D4               ; 55B7  CD D4 28
        CALL SUB_2A31               ; 55BA  CD 31 2A
        POP BC                      ; 55BD  C1
        POP HL                      ; 55BE  E1
        POP AF                      ; 55BF  F1
        OR A                        ; 55C0  B7
        JR Z,LOC_55D7               ; 55C1  28 14
        EX AF,AF_                   ; 55C3  08
        LD A,C                      ; 55C4  79
        OR A                        ; 55C5  B7
        JR Z,LOC_55D7               ; 55C6  28 0F
        EX DE,HL                    ; 55C8  EB
        CALL SUB_2959               ; 55C9  CD 59 29
        EX DE,HL                    ; 55CC  EB
        EX AF,AF_                   ; 55CD  08
LOC_55CE:
        PUSH HL                     ; 55CE  E5
        PUSH BC                     ; 55CF  C5
        LDIR                        ; 55D0  ED B0
        POP BC                      ; 55D2  C1
        POP HL                      ; 55D3  E1
        DEC A                       ; 55D4  3D
        JR NZ,LOC_55CE              ; 55D5  20 F7
LOC_55D7:
        EXX                         ; 55D7  D9
LOC_55D8:
        POP HL                      ; 55D8  E1
        LD A,(HL)                   ; 55D9  7E
        RET                         ; 55DA  C9
SUB_55DB:
        PUSH BC                     ; 55DB  C5
        PUSH DE                     ; 55DC  D5
        PUSH HL                     ; 55DD  E5
        CALL GETVAD                 ; 55DE  CD B1 0F
        CALL SNCV                   ; 55E1  CD A6 0D
        LD A,(HL)                   ; 55E4  7E
        LD (MON_118E),A             ; 55E5  32 8E 11
        LD (MON_118F),HL            ; 55E8  22 8F 11
        LD HL,1192H                 ; 55EB  21 92 11
        LD (HL),C0H                 ; 55EE  36 C0
        XOR A                       ; 55F0  AF
        LD (MON_1191),A             ; 55F1  32 91 11
LOC_55F4:
        CALL MON_09FF               ; 55F4  CD FF 09
        CALL GETKYD                 ; 55F7  CD CA 08
        CP CBH                      ; 55FA  FE CB
        JP Z,MON_09EF               ; 55FC  CA EF 09
        CP CDH                      ; 55FF  FE CD
        JP Z,MON_09EF               ; 5601  CA EF 09
        JR LOC_55F4                 ; 5604  18 EE
        LD D,L                      ; 5606  55
        LD D,E                      ; 5607  53
        LD C,C                      ; 5608  49
        LD C,(HL)                   ; 5609  4E
        LD B,A                      ; 560A  47
        XOR B                       ; 560B  A8
        LD D,E                      ; 560C  53
        LD D,H                      ; 560D  54
        LD D,D                      ; 560E  52
        LD C,C                      ; 560F  49
        LD C,(HL)                   ; 5610  4E
        LD B,A                      ; 5611  47
        XOR B                       ; 5612  A8
        LD C,H                      ; 5613  4C
        LD C,C                      ; 5614  49
        LD C,(HL)                   ; 5615  4E
        LD B,L                      ; 5616  45
        XOR B                       ; 5617  A8
        LD D,(HL)                   ; 5618  56
        LD B,C                      ; 5619  41
        LD D,D                      ; 561A  52
        LD D,B                      ; 561B  50
        LD D,H                      ; 561C  54
        LD D,D                      ; 561D  52
        XOR B                       ; 561E  A8
        LD D,H                      ; 561F  54
        LD C,A                      ; 5620  4F
        RET NC                      ; 5621  D0
        RST 38H                     ; 5622  FF
        RST 38H                     ; 5623  FF
        RST 38H                     ; 5624  FF
        LD B,H                      ; 5625  44
        LD D,E                      ; 5626  53
        LD C,A                      ; 5627  4F
        LD D,D                      ; 5628  52
        CALL NC,SUB_4F53            ; 5629  D4 53 4F
        LD D,D                      ; 562C  52
        CALL NC,WS_FFFF             ; 562D  D4 FF FF

KWTABLE:
; BASIC keyword/token table - last character of each word has bit 7 set
        DB 'S','H','U',D4H             ; 5630  "SHUT"
        DB 'P','U','S',C8H             ; 5634  "PUSH"
        DB 'E','X',D8H                 ; 5638  "EXX"
        DB 'D','A','R',CBH             ; 563B  "DARK"
        DB 'L','I','G','H',D4H         ; 563F  "LIGHT"
        DB 'P','O',D0H                 ; 5644  "POP"
        DB 'B','E','L',CCH             ; 5647  "BELL"
        DB 'I','M','A','G',C5H         ; 564B  "IMAGE"
        DB 'R','E',CDH                 ; 5650  "REM"
        DB 'D','A','T',C1H             ; 5653  "DATA"
        DB 'L','I','S',D4H             ; 5657  "LIST"
        DB 'R','U',CEH                 ; 565B  "RUN"
        DB 'N','E',D7H                 ; 565E  "NEW"
        DB 'P','R','I','N',D4H         ; 5661  "PRINT"
        DB 'L','E',D4H                 ; 5666  "LET"
        DB 'F','O',D2H                 ; 5669  "FOR"
        DB 'I',C6H                     ; 566C  "IF"
        DB 'G','O','T',CFH             ; 566E  "GOTO"
        DB 'R','E','A',C4H             ; 5672  "READ"
        DB 'G','O','S','U',C2H         ; 5676  "GOSUB"
        DB 'R','E','T','U','R',CEH     ; 567B  "RETURN"
        DB 'N','E','X',D4H             ; 5681  "NEXT"
        DB 'S','T','O',D0H             ; 5685  "STOP"
        DB 'E','N',C4H                 ; 5689  "END"
        DB 'O',CEH                     ; 568C  "ON"
        DB 'L','O','A',C4H             ; 568E  "LOAD"
        DB 'S','A','V',C5H             ; 5692  "SAVE"
        DB 'V','E','R','I','F',D9H     ; 5696  "VERIFY"
        DB 'P','O','K',C5H             ; 569C  "POKE"
        DB 'D','I',CDH                 ; 56A0  "DIM"
        DB 'D','E','F',' ','F',CEH     ; 56A3  "DEF FN"
        DB 'I','N','P','U',D4H         ; 56A9  "INPUT"
        DB 'R','E','S','T','O','R',C5H ; 56AE  "RESTORE"
        DB 'C','L',D2H                 ; 56B5  "CLR"
        DB 'M','U','S','I',C3H         ; 56B8  "MUSIC"
        DB 'T','E','M','P',CFH         ; 56BD  "TEMPO"
        DB 'U','S','R',A8H             ; 56C2  "USR("
        DB 'W','O','P','E',CEH         ; 56C6  "WOPEN"
        DB 'R','O','P','E',CEH         ; 56CB  "ROPEN"
        DB 'C','L','O','S',C5H         ; 56D0  "CLOSE"
        DB 'B','Y',C5H                 ; 56D5  "BYE"
        DB 'L','I','M','I',D4H         ; 56D8  "LIMIT"
        DB 'C','O','N',D4H             ; 56DD  "CONT"
        DB 'S','E',D4H                 ; 56E1  "SET"
        DB 'R','E','S','E',D4H         ; 56E4  "RESET"
        DB 'G','E',D4H                 ; 56E9  "GET"
        DB 'I','N','P',C0H             ; 56EC  "INP@"
        DB 'O','U','T',C0H             ; 56F0  "OUT@"
        DB 'A','U','T',CFH             ; 56F4  "AUTO"
        DB 'A','P','P','E','N',C4H     ; 56F8  "APPEND"
        DB 'D','O','K',C5H             ; 56FE  "DOKE"
        DB 'R','E','N','U',CDH         ; 5702  "RENUM"
        DB 'E','L','S',C5H             ; 5707  "ELSE"
        DB 'T','H','E',CEH             ; 570B  "THEN"
        DB 'T',CFH                     ; 570F  "TO"
        DB 'S','T','E',D0H             ; 5711  "STEP"
        DB '>',BCH                     ; 5715  "><"
        DB '<',BEH                     ; 5717  "<>"
        DB '=',BCH                     ; 5719  "=<"
        DB '<',BDH                     ; 571B  "<="
        DB '=',BEH                     ; 571D  "=>"
        DB '>',BDH                     ; 571F  ">="
        DB BDH                         ; 5721  "="
        DB BEH                         ; 5722  ">"
        DB BCH                         ; 5723  "<"
        DB 'A','N',C4H                 ; 5724  "AND"
        DB 'O',D2H                     ; 5727  "OR"
        DB 'N','O',D4H                 ; 5729  "NOT"
        DB ABH                         ; 572C  "+"
        DB ADH                         ; 572D  "-"
        DB AAH                         ; 572E  "*"
        DB AFH                         ; 572F  "/"
        DB 'L','E','F','T','$',A8H     ; 5730  "LEFT$("
        DB 'R','I','G','H','T','$',A8H ; 5736  "RIGHT$("
        DB 'M','I','D','$',A8H         ; 573D  "MID$("
        DB 'L','E','N',A8H             ; 5742  "LEN("
        DB 'C','H','R','$',A8H         ; 5746  "CHR$("
        DB 'S','T','R','$',A8H         ; 574B  "STR$("
        DB 'A','S','C',A8H             ; 5750  "ASC("
        DB 'V','A','L',A8H             ; 5754  "VAL("
        DB 'P','E','E','K',A8H         ; 5758  "PEEK("
        DB 'T','A','B',A8H             ; 575D  "TAB("
        DB 'S','P','C',A8H             ; 5761  "SPC("
        DB 'S','I','Z',C5H             ; 5765  "SIZE"
        DB 'E','R',CCH                 ; 5769  "ERL"
        DB 'E','R',CEH                 ; 576C  "ERN"
        DB 'P','O','I','N','T',A8H     ; 576F  "POINT("
        DB DEH                         ; 5775  "^"
        DB 'R','N','D',A8H             ; 5776  "RND("
        DB 'S','I','N',A8H             ; 577A  "SIN("
        DB 'C','O','S',A8H             ; 577E  "COS("
        DB 'T','A','N',A8H             ; 5782  "TAN("
        DB 'A','T','N',A8H             ; 5786  "ATN("
        DB 'E','X','P',A8H             ; 578A  "EXP("
        DB 'G','A','U',A8H             ; 578E  "GAU("
        DB 'L','O','G',A8H             ; 5792  "LOG("
        DB 'L','N',A8H                 ; 5796  "LN("
        DB 'A','B','S',A8H             ; 5799  "ABS("
        DB 'S','G','N',A8H             ; 579D  "SGN("
        DB 'S','Q','R',A8H             ; 57A1  "SQR("
        DB 'F','R','A','C',A8H         ; 57A5  "FRAC("
        DB 'I','N','T',A8H             ; 57AA  "INT("
        DB 'M','O','D',A8H             ; 57AE  "MOD("
        DB 'I','N','S','T','R',A8H     ; 57B2  "INSTR("
        DB 'E','R','R','O',D2H         ; 57B8  "ERROR"
        DB 'E','O','F',A8H             ; 57BD  "EOF("
        DB 'P','O','S',A8H             ; 57C1  "POS("
        DB 'V','T','A','B',A8H         ; 57C5  "VTAB("
        DB 'D','E','E','K',A8H         ; 57CA  "DEEK("
        DB 'F','A','K',A8H             ; 57CF  "FAK("
        DB 'M','A','X',A8H             ; 57D3  "MAX("
        DB 'M','I','N',A8H             ; 57D7  "MIN("
        DB 'D','I',D2H                 ; 57DB  "DIR"
        DB 'D','E','L','E','T',C5H     ; 57DE  "DELETE"
        DB 'S','W','A',D0H             ; 57E4  "SWAP"
        DB 'K','I','L',CCH             ; 57E8  "KILL"
        DB 'R','E','N','A','M',C5H     ; 57EC  "RENAME"
        DB 'L','O','C',CBH             ; 57F2  "LOCK"
        DB 'C','H','A','I',CEH         ; 57F6  "CHAIN"
        DB 'U','N','L','O','C',CBH     ; 57FB  "UNLOCK"
        DB 'R','E','S','U','M',C5H     ; 5801  "RESUME"
        DB 'X','O','P','E',CEH         ; 5807  "XOPEN"
        DB 'C','U','R','S','O',D2H     ; 580C  "CURSOR"
        DB 'T','R','A','C',C5H         ; 5812  "TRACE"
        DB 'L','I','N',CBH             ; 5817  "LINK"
        DB 'D','U','M',D0H             ; 581B  "DUMP"
        DB 'W','A','I',D4H             ; 581F  "WAIT"
        DB 'O','F',C6H                 ; 5823  "OFF"
        DB 'H','E','L',D0H             ; 5826  "HELP"
        DB 'B','R','E','A',CBH         ; 582A  "BREAK"
        DB 'W','H','I','L',C5H         ; 582F  "WHILE"
        DB 'W','E','N',C4H             ; 5834  "WEND"
        DB 'F','I','N',C4H             ; 5838  "FIND"
        DB 'C','O','P',D9H             ; 583C  "COPY"
        DB 'I','N','S','E','R',D4H     ; 5840  "INSERT"

        ADD A,H                     ; 5846  84
        LD D,L                      ; 5847  55
        LD E,E                      ; 5848  5B
        LD D,L                      ; 5849  55
        LD A,(BC)                   ; 584A  0A
        INC H                       ; 584B  24
        LD A,(BC)                   ; 584C  0A
        INC H                       ; 584D  24
        LD A,(BC)                   ; 584E  0A
        INC H                       ; 584F  24
        LD A,(BC)                   ; 5850  0A
        INC H                       ; 5851  24
        LD A,(BC)                   ; 5852  0A
        INC H                       ; 5853  24
        LD A,(BC)                   ; 5854  0A
        INC H                       ; 5855  24
LOC_5856:
        LD A,(BC)                   ; 5856  0A
        INC H                       ; 5857  24
        LD A,(BC)                   ; 5858  0A
        INC H                       ; 5859  24
        LD A,(BC)                   ; 585A  0A
        INC H                       ; 585B  24
        LD E,D                      ; 585C  5A
        LD H,31H                    ; 585D  26 31
LOC_585F:
        JR NZ,KWTABLE+449           ; 585F  20 90
        LD E,A                      ; 5861  5F
        LD (HL),L                   ; 5862  75
        LD E,A                      ; 5863  5F
        LD (HL),C                   ; 5864  71
        LD E,A                      ; 5865  5F
        LD H,L                      ; 5866  65
        LD E,A                      ; 5867  5F
        AND B                       ; 5868  A0
        LD HL,13F8H                 ; 5869  21 F8 13
        RET M                       ; 586C  F8
        INC DE                      ; 586D  13
        RET M                       ; 586E  F8
        INC DE                      ; 586F  13
        LD HL,(1B13H)               ; 5870  2A 13 1B
        DEC D                       ; 5873  15
        EI                          ; 5874  FB
        LD E,E                      ; 5875  5B
        ADC A,A                     ; 5876  8F
        ADD HL,SP                   ; 5877  39
        JR Z,LOC_588E               ; 5878  28 14
        PUSH BC                     ; 587A  C5
        DEC D                       ; 587B  15
        JR Z,LOC_5897               ; 587C  28 19
LOC_587E:
        LD SP,6D15H                 ; 587E  31 15 6D
        LD B,C                      ; 5881  41
        LD E,C                      ; 5882  59
        DEC D                       ; 5883  15
        SUB B                       ; 5884  90
        DEC D                       ; 5885  15
        INC BC                      ; 5886  03
        ADD HL,DE                   ; 5887  19
        INC E                       ; 5888  1C
        INC D                       ; 5889  14
        RST 38H                     ; 588A  FF
        INC DE                      ; 588B  13
        PUSH HL                     ; 588C  E5
        DB 16H                      ; 588D  16   (stray byte(s): disassembly boundary correction)
LOC_588E:
        CP H                        ; 588E  BC
        LD B,E                      ; 588F  43
        RET NZ                      ; 5890  C0
        LD B,L                      ; 5891  45
        LD A,(BC)                   ; 5892  0A
        INC H                       ; 5893  24
        JP PO,WS_C618               ; 5894  E2 18 C6
LOC_5897:
        RLA                         ; 5897  17
        LD E,C                      ; 5898  59
        ADD HL,DE                   ; 5899  19
        LD B,D                      ; 589A  42
        LD A,D7H                    ; 589B  3E D7
        INC DE                      ; 589D  13
        EI                          ; 589E  FB
        LD E,(HL)                   ; 589F  5E
        RST 08H                     ; 58A0  CF
        ADD HL,DE                   ; 58A1  19
        RST 28H                     ; 58A2  EF
        ADD HL,DE                   ; 58A3  19
        SUB H                       ; 58A4  94
        JR NZ,LOC_587E              ; 58A5  20 D7
        LD B,C                      ; 58A7  41
        IN A,(41H)                  ; 58A8  DB 41
        LD A,(HL)                   ; 58AA  7E
LOC_58AB:
        LD C,B                      ; 58AB  48
        ADD HL,BC                   ; 58AC  09
        JR NZ,LOC_5856              ; 58AD  20 A7
        JR NZ,LOC_58C4              ; 58AF  20 13
        LD HL,5D29H                 ; 58B1  21 29 5D
        DEC L                       ; 58B4  2D
        LD E,L                      ; 58B5  5D
        LD B,D                      ; 58B6  42
        JR NZ,LOC_585F              ; 58B7  20 A6
        LD HL,21E3H                 ; 58B9  21 E3 21
        LD A,(BC)                   ; 58BC  0A
        INC H                       ; 58BD  24
        LD A,(BC)                   ; 58BE  0A
        INC H                       ; 58BF  24
        OUT (25H),A                 ; 58C0  D3 25
        LD A,(BC)                   ; 58C2  0A
        INC H                       ; 58C3  24
LOC_58C4:
        CCF                         ; 58C4  3F
        LD (DE),A                   ; 58C5  12
        LD (HL),D                   ; 58C6  72
        INC HL                      ; 58C7  23
        LD (HL),D                   ; 58C8  72
        INC HL                      ; 58C9  23
        LD (HL),D                   ; 58CA  72
        INC HL                      ; 58CB  23
        RST 18H                     ; 58CC  DF
        LD (32DFH),A                ; 58CD  32 DF 32
        LD A,(BC)                   ; 58D0  0A
        INC SP                      ; 58D1  33
        LD A,(BC)                   ; 58D2  0A
        INC SP                      ; 58D3  33
        LD C,33H                    ; 58D4  0E 33
        LD C,33H                    ; 58D6  0E 33
        NOP                         ; 58D8  00
        INC SP                      ; 58D9  33
        JP P,WS_F632                ; 58DA  F2 32 F6
        LD (59E2H),A                ; 58DD  32 E2 59
        AND 59H                     ; 58E0  E6 59
        JP PE,LOC_3B59              ; 58E2  EA 59 3B
        DEC HL                      ; 58E5  2B
        JR C,LOC_5913               ; 58E6  38 2B
        LD B,A                      ; 58E8  47
        INC L                       ; 58E9  2C
LOC_58EA:
        LD E,2DH                    ; 58EA  1E 2D
        DEC L                       ; 58EC  2D
        LD E,5FH                    ; 58ED  1E 5F
        LD E,83H                    ; 58EF  1E 83
        LD E,C7H                    ; 58F1  1E C7
        LD E,D6H                    ; 58F3  1E D6
        LD E,F6H                    ; 58F5  1E F6
        LD E,2FH                    ; 58F7  1E 2F
        RRA                         ; 58F9  1F
        LD (DE),A                   ; 58FA  12
        RRA                         ; 58FB  1F
        LD (HL),C                   ; 58FC  71
        RRA                         ; 58FD  1F
        SUB D                       ; 58FE  92
        RRA                         ; 58FF  1F
        SUB L                       ; 5900  95
        RRA                         ; 5901  1F
        CP E                        ; 5902  BB
        RRA                         ; 5903  1F
        RET                         ; 5904  C9
        RRA                         ; 5905  1F
        IN A,(1FH)                  ; 5906  DB 1F
        DEC H                       ; 5908  25
        LD E,L                      ; 5909  5D
        LD SP,HL                    ; 590A  F9
        JR C,LOC_592A               ; 590B  38 1D
        INC SP                      ; 590D  33
        SBC A,(HL)                  ; 590E  9E
        INC SP                      ; 590F  33
        SUB B                       ; 5910  90
        INC (HL)                    ; 5911  34
        SBC A,A                     ; 5912  9F
LOC_5913:
        INC (HL)                    ; 5913  34
        INC DE                      ; 5914  13
        JR C,LOC_58AB               ; 5915  38 94
        DEC (HL)                    ; 5917  35
        CALL M,MON_0131             ; 5918  FC 31 01
        JR C,LOC_58EA               ; 591B  38 CD
        LD (HL),EEH                 ; 591D  36 EE
        RRA                         ; 591F  1F
        DI                          ; 5920  F3
        RRA                         ; 5921  1F
        JP Z,WS_A634                ; 5922  CA 34 A6
        LD H,77H                    ; 5925  26 77
        LD H,B9H                    ; 5927  26 B9
        DB 26H                      ; 5929  26   (stray byte(s): disassembly boundary correction)
LOC_592A:
        OR H                        ; 592A  B4
        LD E,L                      ; 592B  5D
        LD (HL),D                   ; 592C  72
        INC HL                      ; 592D  23
        CP (HL)                     ; 592E  BE
        LD E,(HL)                   ; 592F  5E
        AND 25H                     ; 5930  E6 25
        LD (HL),D                   ; 5932  72
        INC HL                      ; 5933  23
        POP DE                      ; 5934  D1
        LD E,E                      ; 5935  5B
        CP 26H                      ; 5936  FE 26
        INC C                       ; 5938  0C
        LD H,13H                    ; 5939  26 13
        LD H,ADH                    ; 593B  26 AD
        LD C,C                      ; 593D  49
        SBC A,C                     ; 593E  99
        LD C,E                      ; 593F  4B
        LD A,C                      ; 5940  79
        LD B,(HL)                   ; 5941  46
        XOR (HL)                    ; 5942  AE
        LD C,H                      ; 5943  4C
        LD B,(HL)                   ; 5944  46
        LD C,L                      ; 5945  4D
        RST 38H                     ; 5946  FF
        LD C,H                      ; 5947  4C
        CALL PO,WS_FC44             ; 5948  E4 44 FC
        LD C,H                      ; 594B  4C
        LD H,C                      ; 594C  61
        RLA                         ; 594D  17
        CALL Z,MON_0C41             ; 594E  CC 41 0C
        JR NZ,LOC_595D              ; 5951  20 0A
        INC H                       ; 5953  24
        LD A,(BC)                   ; 5954  0A
        INC H                       ; 5955  24
        LD A,(BC)                   ; 5956  0A
        INC H                       ; 5957  24
        LD BC,0A1EH                 ; 5958  01 1E 0A
        INC H                       ; 595B  24
LOC_595C:
        LD A,(BC)                   ; 595C  0A
LOC_595D:
        INC H                       ; 595D  24
        LD A,(BC)                   ; 595E  0A
        INC H                       ; 595F  24
        LD A,(BC)                   ; 5960  0A
        INC H                       ; 5961  24
        LD A,(BC)                   ; 5962  0A
        INC H                       ; 5963  24
        LD A,(BC)                   ; 5964  0A
        INC H                       ; 5965  24
        LD A,(BC)                   ; 5966  0A
        INC H                       ; 5967  24
        CCF                         ; 5968  3F
        LD E,(HL)                   ; 5969  5E
        LD (HL),D                   ; 596A  72
        INC HL                      ; 596B  23
LOC_596C:
        SUB 0EH                     ; 596C  D6 0E
        CP 0AH                      ; 596E  FE 0A
        JP NC,LOC_5A2E              ; 5970  D2 2E 5A
        LD DE,5928H                 ; 5973  11 28 59
        JP LOC_128A                 ; 5976  C3 8A 12
        POP BC                      ; 5979  C1
        NOP                         ; 597A  00
        NOP                         ; 597B  00
        NOP                         ; 597C  00
        ADD A,B                     ; 597D  80
        POP BC                      ; 597E  C1
        NOP                         ; 597F  00
        NOP                         ; 5980  00
        NOP                         ; 5981  00
        ADD A,B                     ; 5982  80
        JP NZ,MONIT                 ; 5983  C2 00 00
        NOP                         ; 5986  00
        ADD A,B                     ; 5987  80
        JP MONIT                    ; 5988  C3 00 00
        NOP                         ; 598B  00
        RET NZ                      ; 598C  C0
        PUSH BC                     ; 598D  C5
        NOP                         ; 598E  00
        NOP                         ; 598F  00
        NOP                         ; 5990  00
        RET NZ                      ; 5991  C0
        RST 00H                     ; 5992  C7
        NOP                         ; 5993  00
        NOP                         ; 5994  00
        NOP                         ; 5995  00
        RET P                       ; 5996  F0
        JP Z,MONIT                  ; 5997  CA 00 00
        NOP                         ; 599A  00
        OR H                        ; 599B  B4
        CALL MONIT                  ; 599C  CD 00 00
        ADD A,B                     ; 599F  80
        SBC A,L                     ; 59A0  9D
        RET NC                      ; 59A1  D0
        NOP                         ; 59A2  00
        NOP                         ; 59A3  00
        ADD A,B                     ; 59A4  80
        SBC A,L                     ; 59A5  9D
        OUT (00H),A                 ; 59A6  D3 00
        NOP                         ; 59A8  00
        JR NC,LOC_595C              ; 59A9  30 B1
        SUB 00H                     ; 59AB  D6 00
        NOP                         ; 59AD  00
        LD A,H                      ; 59AE  7C
        JP C,LOC_4000               ; 59AF  DD DA 00 40
        LD B,L                      ; 59B3  45
        SBC A,B                     ; 59B4  98
        NOP                         ; 59B5  DD 00
        RET PO                      ; 59B7  E0
        LD H,A                      ; 59B8  67
        CALL PO,MON_00E1            ; 59B9  E4 E1 00
        LD H,(HL)                   ; 59BC  66
        SUB H                       ; 59BD  94
        CP C                        ; 59BE  B9
        PUSH HL                     ; 59BF  E5
        LD B,B                      ; 59C0  40
        EXX                         ; 59C1  D9
        LD H,C                      ; 59C2  61
        AND D                       ; 59C3  A2
        JP (HL)                     ; 59C4  E9
        XOR H                       ; 59C5  AC
        CP E                        ; 59C6  BB
        DEC SP                      ; 59C7  3B
        SBC A,B                     ; 59C8  98
        NONI                        ; 59C9  ED AC
        CP E                        ; 59CB  BB
        DEC SP                      ; 59CC  3B
        SBC A,B                     ; 59CD  98
        POP AF                      ; 59CE  F1
        LD H,A                      ; 59CF  67
        LD (HL),A                   ; 59D0  77
        CP A                        ; 59D1  BF
        AND C                       ; 59D2  A1
        PUSH AF                     ; 59D3  F5
        LD D,H                      ; 59D4  54
        LD H,(HL)                   ; 59D5  66
        RST 30H                     ; 59D6  F7
        OR L                        ; 59D7  B5
        LD SP,HL                    ; 59D8  F9
        ADD A,H                     ; 59D9  84
        RET                         ; 59DA  C9
        DEC D                       ; 59DB  15
        RET C                       ; 59DC  D8
        CP F3H                      ; 59DD  FE F3
        SBC A,L                     ; 59DF  9D
        DEC C                       ; 59E0  0D
        ADD A,A                     ; 59E1  87
        LD C,20H                    ; 59E2  0E 20
        JR LOC_59EC                 ; 59E4  18 06
        LD C,30H                    ; 59E6  0E 30
        JR LOC_59EC                 ; 59E8  18 02
        LD C,28H                    ; 59EA  0E 28
LOC_59EC:
        PUSH DE                     ; 59EC  D5
        PUSH HL                     ; 59ED  E5
        LD B,04H                    ; 59EE  06 04
        LD HL,5A0AH                 ; 59F0  21 0A 5A
        LD DE,0005H                 ; 59F3  11 05 00
LOC_59F6:
        LD A,(HL)                   ; 59F6  7E
        AND 87H                     ; 59F7  E6 87
        OR C                        ; 59F9  B1
        LD (HL),A                   ; 59FA  77
        ADD HL,DE                   ; 59FB  19
        DJNZ LOC_59F6               ; 59FC  10 F8
        POP HL                      ; 59FE  E1
        CALL SUB_271A               ; 59FF  CD 1A 27
        EXX                         ; 5A02  D9
        POP HL                      ; 5A03  E1
        PUSH HL                     ; 5A04  E5
        CALL SUB_271A               ; 5A05  CD 1A 27
        LD A,B                      ; 5A08  78
        EXX                         ; 5A09  D9
        AND B                       ; 5A0A  A0
        LD B,A                      ; 5A0B  47
        EXX                         ; 5A0C  D9
        LD A,C                      ; 5A0D  79
        EXX                         ; 5A0E  D9
        AND C                       ; 5A0F  A1
        LD C,A                      ; 5A10  4F
        EXX                         ; 5A11  D9
        LD A,D                      ; 5A12  7A
        EXX                         ; 5A13  D9
        AND D                       ; 5A14  A2
        LD D,A                      ; 5A15  57
        EXX                         ; 5A16  D9
        LD A,E                      ; 5A17  7B
        EXX                         ; 5A18  D9
        AND E                       ; 5A19  A3
        LD E,A                      ; 5A1A  5F
LOC_5A1B:
        LD A,B                      ; 5A1B  78
        AND 80H                     ; 5A1C  E6 80
        JR Z,LOC_5A29               ; 5A1E  28 09
        LD A,00H                    ; 5A20  3E 00
        CALL SUB_2741               ; 5A22  CD 41 27
        LD A,60H                    ; 5A25  3E 60
        JR LOC_5A2B                 ; 5A27  18 02
LOC_5A29:
        LD A,E0H                    ; 5A29  3E E0
LOC_5A2B:
        JP LOC_26A0                 ; 5A2B  C3 A0 26
LOC_5A2E:
        CP DDH                      ; 5A2E  FE DD
        JP NZ,LOC_5ACC              ; 5A30  C2 CC 5A
        INC HL                      ; 5A33  23
        CALL SUB_1A58               ; 5A34  CD 58 1A
        PUSH HL                     ; 5A37  E5
        LD HL,(FREE_PTR)            ; 5A38  2A 6A 63
        PUSH HL                     ; 5A3B  E5
        CALL SUB_271A               ; 5A3C  CD 1A 27
        LD A,E                      ; 5A3F  7B
        CPL                         ; 5A40  2F
        LD E,A                      ; 5A41  5F
        LD A,D                      ; 5A42  7A
        CPL                         ; 5A43  2F
        LD D,A                      ; 5A44  57
        LD A,C                      ; 5A45  79
        CPL                         ; 5A46  2F
        LD C,A                      ; 5A47  4F
        LD A,B                      ; 5A48  78
        CPL                         ; 5A49  2F
        LD B,A                      ; 5A4A  47
        LD HL,5A53H                 ; 5A4B  21 53 5A
LOC_5A4E:
        EX (SP),HL                  ; 5A4E  E3
        PUSH HL                     ; 5A4F  E5
        JP LOC_5A1B                 ; 5A50  C3 1B 5A
        POP HL                      ; 5A53  E1
        CALL SUB_1B24               ; 5A54  CD 24 1B
        JP SUB_277B                 ; 5A57  C3 7B 27
LOC_5A5A:
        CP F8H                      ; 5A5A  FE F8
        JR NZ,LOC_5A6C              ; 5A5C  20 0E
        CALL SUB_2B2A               ; 5A5E  CD 2A 2B
        LD A,(DATA_2345)            ; 5A61  3A 45 23
        CP 01H                      ; 5A64  FE 01
        JP Z,LOC_2478               ; 5A66  CA 78 24
        JP LOC_23DA                 ; 5A69  C3 DA 23
LOC_5A6C:
        CP E5H                      ; 5A6C  FE E5
        JP NZ,LOC_2372              ; 5A6E  C2 72 23
        INC HL                      ; 5A71  23
        CALL SUB_27E1               ; 5A72  CD E1 27
        OR (HL)                     ; 5A75  B6
        CALL SUB_1221               ; 5A76  CD 21 12
        LD A,E                      ; 5A79  7B
        LD (2346H),A                ; 5A7A  32 46 23
        JP LOC_122D                 ; 5A7D  C3 2D 12
SUB_5A80:
        PUSH HL                     ; 5A80  E5
        INC HL                      ; 5A81  23
        LD E,(HL)                   ; 5A82  5E
        INC HL                      ; 5A83  23
        LD D,(HL)                   ; 5A84  56
        INC HL                      ; 5A85  23
        LD C,(HL)                   ; 5A86  4E
        INC HL                      ; 5A87  23
        LD B,(HL)                   ; 5A88  46
        POP HL                      ; 5A89  E1
        LD A,(HL)                   ; 5A8A  7E
        RET                         ; 5A8B  C9
; --- SUB_5A8C: called from 3 places ---
SUB_5A8C:
        PUSH AF                     ; 5A8C  F5
        LD HL,(FREE_PTR)            ; 5A8D  2A 6A 63
        CALL SUB_5A80               ; 5A90  CD 80 5A
        LD IX,3B8CH                 ; 5A93  DD 21 8C 3B
        AND 80H                     ; 5A97  E6 80
        LD A,2DH                    ; 5A99  3E 2D
        JR Z,LOC_5A9F               ; 5A9B  28 02
        LD A,20H                    ; 5A9D  3E 20
LOC_5A9F:
        LD (IX-2H),A                ; 5A9F  DD 77 FE
        POP AF                      ; 5AA2  F1
        LD (IX-1H),A                ; 5AA3  DD 77 FF
LOC_5AA6:
        LD A,(HL)                   ; 5AA6  7E
        AND 7FH                     ; 5AA7  E6 7F
        CP 40H                      ; 5AA9  FE 40
        JR C,LOC_5AB6               ; 5AAB  38 09
        SUB 40H                     ; 5AAD  D6 40
        CP 21H                      ; 5AAF  FE 21
        JP NC,LOC_237A              ; 5AB1  D2 7A 23
        OR A                        ; 5AB4  B7
        RET NZ                      ; 5AB5  C0
LOC_5AB6:
        LD (IX-2H),20H              ; 5AB6  DD 36 FE 20
        LD (IX+0H),30H              ; 5ABA  DD 36 00 30
        POP HL                      ; 5ABE  E1
        INC IX                      ; 5ABF  DD 23
LOC_5AC1:
        LD (IX+0H),0DH              ; 5AC1  DD 36 00 0D
        LD HL,3B8AH                 ; 5AC5  21 8A 3B
        PUSH HL                     ; 5AC8  E5
        JP LOC_1F0B                 ; 5AC9  C3 0B 1F
LOC_5ACC:
        CP 47H                      ; 5ACC  FE 47
        JP NZ,LOC_5B2F              ; 5ACE  C2 2F 5B
        INC HL                      ; 5AD1  23
        CALL SUB_27D2               ; 5AD2  CD D2 27
        PUSH BC                     ; 5AD5  C5
        POP HL                      ; 5AD6  E1
        JR NZ,LOC_5AA6              ; 5AD7  20 CD
        LD D,A                      ; 5AD9  57
        DAA                         ; 5ADA  27
        PUSH HL                     ; 5ADB  E5
        LD A,25H                    ; 5ADC  3E 25
        CALL SUB_5A8C               ; 5ADE  CD 8C 5A
        LD H,A                      ; 5AE1  67
LOC_5AE2:
        CALL SUB_274E               ; 5AE2  CD 4E 27
        LD A,30H                    ; 5AE5  3E 30
        JR NC,LOC_5AEA              ; 5AE7  30 01
        INC A                       ; 5AE9  3C
LOC_5AEA:
        LD (IX+0H),A                ; 5AEA  DD 77 00
        INC IX                      ; 5AED  DD 23
        DEC H                       ; 5AEF  25
        JR NZ,LOC_5AE2              ; 5AF0  20 F0
        JP LOC_5AC1                 ; 5AF2  C3 C1 5A
SUB_5AF5:
        SUB 30H                     ; 5AF5  D6 30
        CP 0AH                      ; 5AF7  FE 0A
        RET C                       ; 5AF9  D8
        SUB 11H                     ; 5AFA  D6 11
        CP 06H                      ; 5AFC  FE 06
        RET NC                      ; 5AFE  D0
        ADD A,0AH                   ; 5AFF  C6 0A
        SCF                         ; 5B01  37
        RET                         ; 5B02  C9
        CALL SUB_5AF5               ; 5B03  CD F5 5A
        JP NC,LOC_2372              ; 5B06  D2 72 23
        LD BC,0000H                 ; 5B09  01 00 00
        LD D,B                      ; 5B0C  50
        LD E,C                      ; 5B0D  59
LOC_5B0E:
        PUSH HL                     ; 5B0E  E5
        LD H,04H                    ; 5B0F  26 04
LOC_5B11:
        SLA A                       ; 5B11  CB 27
        DEC H                       ; 5B13  25
        JR NZ,LOC_5B11              ; 5B14  20 FB
        LD H,04H                    ; 5B16  26 04
LOC_5B18:
        SLA A                       ; 5B18  CB 27
        CALL SUB_274E               ; 5B1A  CD 4E 27
        JP C,LOC_2376               ; 5B1D  DA 76 23
        DEC H                       ; 5B20  25
        JR NZ,LOC_5B18              ; 5B21  20 F5
        POP HL                      ; 5B23  E1
        CALL SUB_277A               ; 5B24  CD 7A 27
        CALL SUB_5AF5               ; 5B27  CD F5 5A
        JR C,LOC_5B0E               ; 5B2A  38 E2
        JP LOC_20FF                 ; 5B2C  C3 FF 20
LOC_5B2F:
        CP 46H                      ; 5B2F  FE 46
        JP NZ,LOC_5B99              ; 5B31  C2 99 5B
        INC HL                      ; 5B34  23
        CALL SUB_27D2               ; 5B35  CD D2 27
        PUSH BC                     ; 5B38  C5
        INC BC                      ; 5B39  03
        LD E,E                      ; 5B3A  5B
        CALL SUB_2757               ; 5B3B  CD 57 27
        PUSH HL                     ; 5B3E  E5
        LD A,24H                    ; 5B3F  3E 24
        CALL SUB_5A8C               ; 5B41  CD 8C 5A
        LD H,A                      ; 5B44  67
LOC_5B45:
        LD L,04H                    ; 5B45  2E 04
LOC_5B47:
        SUB L                       ; 5B47  95
        JR Z,LOC_5B4C               ; 5B48  28 02
        JR NC,LOC_5B47              ; 5B4A  30 FB
LOC_5B4C:
        ADD A,L                     ; 5B4C  85
        LD L,A                      ; 5B4D  6F
        LD A,H                      ; 5B4E  7C
        SUB L                       ; 5B4F  95
        LD H,A                      ; 5B50  67
        XOR A                       ; 5B51  AF
LOC_5B52:
        CALL SUB_274E               ; 5B52  CD 4E 27
        RLA                         ; 5B55  17
        DEC L                       ; 5B56  2D
        JR NZ,LOC_5B52              ; 5B57  20 F9
        CP 0AH                      ; 5B59  FE 0A
        JR C,LOC_5B5F               ; 5B5B  38 02
        ADD A,07H                   ; 5B5D  C6 07
LOC_5B5F:
        ADD A,30H                   ; 5B5F  C6 30
        LD (IX+0H),A                ; 5B61  DD 77 00
        INC IX                      ; 5B64  DD 23
        LD A,H                      ; 5B66  7C
        OR A                        ; 5B67  B7
        JP Z,LOC_5AC1               ; 5B68  CA C1 5A
        JR LOC_5B45                 ; 5B6B  18 D8
        CALL SUB_210E               ; 5B6D  CD 0E 21
        JP NC,LOC_2372              ; 5B70  D2 72 23
        LD BC,0000H                 ; 5B73  01 00 00
        LD D,B                      ; 5B76  50
        LD E,C                      ; 5B77  59
LOC_5B78:
        PUSH HL                     ; 5B78  E5
        LD H,05H                    ; 5B79  26 05
LOC_5B7B:
        SLA A                       ; 5B7B  CB 27
        DEC H                       ; 5B7D  25
        JR NZ,LOC_5B7B              ; 5B7E  20 FB
        LD H,03H                    ; 5B80  26 03
LOC_5B82:
        SLA A                       ; 5B82  CB 27
        CALL SUB_274E               ; 5B84  CD 4E 27
        JP C,LOC_2376               ; 5B87  DA 76 23
        DEC H                       ; 5B8A  25
        JR NZ,LOC_5B82              ; 5B8B  20 F5
        POP HL                      ; 5B8D  E1
        CALL SUB_277A               ; 5B8E  CD 7A 27
        CALL SUB_210E               ; 5B91  CD 0E 21
        JR C,LOC_5B78               ; 5B94  38 E2
        JP LOC_20FF                 ; 5B96  C3 FF 20
LOC_5B99:
        CP 48H                      ; 5B99  FE 48
        JP NZ,LOC_2302              ; 5B9B  C2 02 23
        INC HL                      ; 5B9E  23
        CALL SUB_27D2               ; 5B9F  CD D2 27
        PUSH BC                     ; 5BA2  C5
        LD L,L                      ; 5BA3  6D
        LD E,E                      ; 5BA4  5B
        CALL SUB_2757               ; 5BA5  CD 57 27
        PUSH HL                     ; 5BA8  E5
        LD A,26H                    ; 5BA9  3E 26
        CALL SUB_5A8C               ; 5BAB  CD 8C 5A
        LD H,A                      ; 5BAE  67
LOC_5BAF:
        LD L,03H                    ; 5BAF  2E 03
LOC_5BB1:
        SUB L                       ; 5BB1  95
        JR Z,LOC_5BB6               ; 5BB2  28 02
        JR NC,LOC_5BB1              ; 5BB4  30 FB
LOC_5BB6:
        ADD A,L                     ; 5BB6  85
        LD L,A                      ; 5BB7  6F
        LD A,H                      ; 5BB8  7C
        SUB L                       ; 5BB9  95
        LD H,A                      ; 5BBA  67
        XOR A                       ; 5BBB  AF
LOC_5BBC:
        CALL SUB_274E               ; 5BBC  CD 4E 27
        RLA                         ; 5BBF  17
        DEC L                       ; 5BC0  2D
        JR NZ,LOC_5BBC              ; 5BC1  20 F9
        OR 30H                      ; 5BC3  F6 30
        LD (IX+0H),A                ; 5BC5  DD 77 00
        INC IX                      ; 5BC8  DD 23
        LD A,H                      ; 5BCA  7C
        OR A                        ; 5BCB  B7
        JP Z,LOC_5AC1               ; 5BCC  CA C1 5A
        JR LOC_5BAF                 ; 5BCF  18 DE
        CALL SUB_1204               ; 5BD1  CD 04 12
        CALL SUB_27E1               ; 5BD4  CD E1 27
        ADD HL,HL                   ; 5BD7  29
        PUSH HL                     ; 5BD8  E5
        LD A,(DATA_1238)            ; 5BD9  3A 38 12
        OR A                        ; 5BDC  B7
        JR NZ,LOC_5BE9              ; 5BDD  20 0A
        LD HL,(WS_6165)             ; 5BDF  2A 65 61
        DEC HL                      ; 5BE2  2B
        CALL SUB_27B0               ; 5BE3  CD B0 27
        JP NC,LOC_1F8D              ; 5BE6  D2 8D 1F
LOC_5BE9:
        EX DE,HL                    ; 5BE9  EB
        LD E,(HL)                   ; 5BEA  5E
        INC HL                      ; 5BEB  23
        LD D,(HL)                   ; 5BEC  56
        EX DE,HL                    ; 5BED  EB
        JP LOC_1FBF                 ; 5BEE  C3 BF 1F
LOC_5BF1:
        CALL SUB_22C0               ; 5BF1  CD C0 22
        JP LOC_2254                 ; 5BF4  C3 54 22
LOC_5BF7:
        XOR A                       ; 5BF7  AF
        JP LOC_1700                 ; 5BF8  C3 00 17
        CALL SUB_2981               ; 5BFB  CD 81 29
        JP Z,LOC_131F               ; 5BFE  CA 1F 13
        PUSH HL                     ; 5C01  E5
        LD HL,6180H                 ; 5C02  21 80 61
        LD A,01H                    ; 5C05  3E 01
        LD (HL),A                   ; 5C07  77
        INC HL                      ; 5C08  23
        DEC A                       ; 5C09  3D
        LD (HL),A                   ; 5C0A  77
        INC HL                      ; 5C0B  23
        DEC A                       ; 5C0C  3D
        CALL SUB_2A2C               ; 5C0D  CD 2C 2A
        POP HL                      ; 5C10  E1
        CALL SUB_27D2               ; 5C11  CD D2 27
        CP L                        ; 5C14  BD
        INC E                       ; 5C15  1C
        LD E,H                      ; 5C16  5C
        CALL SUB_139E               ; 5C17  CD 9E 13
        JR LOC_5C1F                 ; 5C1A  18 03
        CALL SUB_1389               ; 5C1C  CD 89 13
LOC_5C1F:
        LD (CUR_STMT),HL            ; 5C1F  22 27 65
        LD HL,(WS_6182)             ; 5C22  2A 82 61
        LD DE,(WS_6180)             ; 5C25  ED 5B 80 61
        XOR A                       ; 5C29  AF
        SBC HL,DE                   ; 5C2A  ED 52
        JP C,LOC_122A               ; 5C2C  DA 2A 12
        INC HL                      ; 5C2F  23
        LD (WS_6182),HL             ; 5C30  22 82 61
        LD HL,(CUR_LINE)            ; 5C33  2A 25 65
        SBC HL,DE                   ; 5C36  ED 52
        JP NC,LOC_23DE              ; 5C38  D2 DE 23
        LD HL,5C54H                 ; 5C3B  21 54 5C
        CALL SUB_29DA               ; 5C3E  CD DA 29
LOC_5C41:
        LD HL,(WS_6180)             ; 5C41  2A 80 61
        LD (WS_6057),HL             ; 5C44  22 57 60
        INC HL                      ; 5C47  23
        LD (WS_6180),HL             ; 5C48  22 80 61
        DEC HL                      ; 5C4B  2B
        LD A,0DH                    ; 5C4C  3E 0D
        LD (WS_6059),A              ; 5C4E  32 59 60
        CALL SUB_22C0               ; 5C51  CD C0 22
        LD HL,(WS_6182)             ; 5C54  2A 82 61
        DEC HL                      ; 5C57  2B
        LD (WS_6182),HL             ; 5C58  22 82 61
        LD A,H                      ; 5C5B  7C
        OR L                        ; 5C5C  B5
        JR NZ,LOC_5C41              ; 5C5D  20 E2
        NOP                         ; 5C5F  00
        NOP                         ; 5C60  00
        NOP                         ; 5C61  00
        JP LOC_122A                 ; 5C62  C3 2A 12
; --- SUB_5C65: called from 5 places ---
SUB_5C65:
        PUSH DE                     ; 5C65  D5
        CALL SUB_1A57               ; 5C66  CD 57 1A
        CALL SUB_2967               ; 5C69  CD 67 29
        EX (SP),HL                  ; 5C6C  E3
        CALL SUB_2959               ; 5C6D  CD 59 29
        EX DE,HL                    ; 5C70  EB
        CALL SUB_2959               ; 5C71  CD 59 29
        POP BC                      ; 5C74  C1
        POP IX                      ; 5C75  DD E1
        PUSH BC                     ; 5C77  C5
        JP (IX+0H)                  ; 5C78  DD E9
LOC_5C7A:
        LD DE,276CH                 ; 5C7A  11 6C 27
        JP LOC_1A4D                 ; 5C7D  C3 4D 1A
LOC_5C80:
        CALL SUB_5C65               ; 5C80  CD 65 5C
LOC_5C83:
        LD A,(DE)                   ; 5C83  1A
        CP (HL)                     ; 5C84  BE
        INC HL                      ; 5C85  23
        INC DE                      ; 5C86  13
        JR NZ,LOC_5C7A              ; 5C87  20 F1
        CP 0DH                      ; 5C89  FE 0D
LOC_5C8B:
        JP Z,LOC_1A4A               ; 5C8B  CA 4A 1A
        JR LOC_5C83                 ; 5C8E  18 F3
LOC_5C90:
        CALL SUB_5C65               ; 5C90  CD 65 5C
LOC_5C93:
        LD A,(DE)                   ; 5C93  1A
        CP (HL)                     ; 5C94  BE
        INC HL                      ; 5C95  23
        INC DE                      ; 5C96  13
        JR C,LOC_5C7A               ; 5C97  38 E1
LOC_5C99:
        JP NZ,LOC_1A4A              ; 5C99  C2 4A 1A
        CP 0DH                      ; 5C9C  FE 0D
        JR Z,LOC_5C8B               ; 5C9E  28 EB
        JR LOC_5C93                 ; 5CA0  18 F1
LOC_5CA2:
        CALL SUB_5C65               ; 5CA2  CD 65 5C
LOC_5CA5:
        LD A,(DE)                   ; 5CA5  1A
        CP (HL)                     ; 5CA6  BE
        INC HL                      ; 5CA7  23
        INC DE                      ; 5CA8  13
        JR C,LOC_5C7A               ; 5CA9  38 CF
        JR NZ,LOC_5C99              ; 5CAB  20 EC
        CP 0DH                      ; 5CAD  FE 0D
        JR Z,LOC_5C7A               ; 5CAF  28 C9
        JR LOC_5CA5                 ; 5CB1  18 F2
LOC_5CB3:
        CALL SUB_5C65               ; 5CB3  CD 65 5C
        EX DE,HL                    ; 5CB6  EB
        JR LOC_5C93                 ; 5CB7  18 DA
LOC_5CB9:
        CALL SUB_5C65               ; 5CB9  CD 65 5C
        EX DE,HL                    ; 5CBC  EB
        JR LOC_5CA5                 ; 5CBD  18 E6
LOC_5CBF:
        CP B0H                      ; 5CBF  FE B0
        JR Z,LOC_5C80               ; 5CC1  28 BD
        CP B1H                      ; 5CC3  FE B1
        JR Z,LOC_5C80               ; 5CC5  28 B9
        CP B2H                      ; 5CC7  FE B2
        JR Z,LOC_5CA2               ; 5CC9  28 D7
        CP B3H                      ; 5CCB  FE B3
        JR Z,LOC_5CA2               ; 5CCD  28 D3
        CP B4H                      ; 5CCF  FE B4
        JR Z,LOC_5CB9               ; 5CD1  28 E6
        CP B5H                      ; 5CD3  FE B5
        JR Z,LOC_5CB9               ; 5CD5  28 E2
        CP B7H                      ; 5CD7  FE B7
        JR Z,LOC_5CB3               ; 5CD9  28 D8
        CP B8H                      ; 5CDB  FE B8
        JR Z,LOC_5C90               ; 5CDD  28 B1
        JP LOC_2372                 ; 5CDF  C3 72 23
LOC_5CE2:
        CP 25H                      ; 5CE2  FE 25
        JR NZ,LOC_5CF5              ; 5CE4  20 0F
LOC_5CE6:
        CALL SUB_277A               ; 5CE6  CD 7A 27
        CP 30H                      ; 5CE9  FE 30
LOC_5CEB:
        JP C,LOC_5D1D               ; 5CEB  DA 1D 5D
        CP 32H                      ; 5CEE  FE 32
LOC_5CF0:
        JP NC,LOC_27B6              ; 5CF0  D2 B6 27
        JR LOC_5CE6                 ; 5CF3  18 F1
LOC_5CF5:
        CP 26H                      ; 5CF5  FE 26
        JR NZ,LOC_5D06              ; 5CF7  20 0D
LOC_5CF9:
        CALL SUB_277A               ; 5CF9  CD 7A 27
        CP 30H                      ; 5CFC  FE 30
        JR C,LOC_5CEB               ; 5CFE  38 EB
        CP 39H                      ; 5D00  FE 39
        JR NC,LOC_5CF0              ; 5D02  30 EC
        JR LOC_5CF9                 ; 5D04  18 F3
LOC_5D06:
        CP 24H                      ; 5D06  FE 24
        JP NZ,LOC_27B6              ; 5D08  C2 B6 27
LOC_5D0B:
        CALL SUB_277A               ; 5D0B  CD 7A 27
        CALL SUB_27A7               ; 5D0E  CD A7 27
        JR C,LOC_5D0B               ; 5D11  38 F8
        CP 41H                      ; 5D13  FE 41
        JR C,LOC_5CEB               ; 5D15  38 D4
        CP 47H                      ; 5D17  FE 47
        JR NC,LOC_5CF0              ; 5D19  30 D5
        JR LOC_5D0B                 ; 5D1B  18 EE
LOC_5D1D:
        CP 0DH                      ; 5D1D  FE 0D
        JP NZ,LOC_27B6              ; 5D1F  C2 B6 27
        JP LOC_2AC9                 ; 5D22  C3 C9 2A
        LD A,FFH                    ; 5D25  3E FF
        JR LOC_5D2E                 ; 5D27  18 05
        LD A,01H                    ; 5D29  3E 01
        JR LOC_5D2E                 ; 5D2B  18 01
        XOR A                       ; 5D2D  AF
LOC_5D2E:
        LD (DATA_1238),A            ; 5D2E  32 38 12
        CALL SUB_1221               ; 5D31  CD 21 12
        PUSH DE                     ; 5D34  D5
        CALL SUB_27E1               ; 5D35  CD E1 27
        INC L                       ; 5D38  2C
        CALL SUB_1221               ; 5D39  CD 21 12
        EX (SP),HL                  ; 5D3C  E3
        PUSH HL                     ; 5D3D  E5
        LD A,E                      ; 5D3E  7B
LOC_5D3F:
        SUB 32H                     ; 5D3F  D6 32
        JR NC,LOC_5D3F              ; 5D41  30 FC
        ADD A,32H                   ; 5D43  C6 32
        LD E,A                      ; 5D45  5F
        POP BC                      ; 5D46  C1
        LD A,C                      ; 5D47  79
LOC_5D48:
        SUB 50H                     ; 5D48  D6 50
        JR NC,LOC_5D48              ; 5D4A  30 FC
        ADD A,50H                   ; 5D4C  C6 50
        LD C,A                      ; 5D4E  4F
        XOR A                       ; 5D4F  AF
        SRL C                       ; 5D50  CB 39
        JR NC,LOC_5D62              ; 5D52  30 0E
        SRL E                       ; 5D54  CB 3B
        JR NC,LOC_5D5C              ; 5D56  30 04
        ADD A,04H                   ; 5D58  C6 04
LOC_5D5A:
        ADD A,02H                   ; 5D5A  C6 02
LOC_5D5C:
        ADD A,01H                   ; 5D5C  C6 01
LOC_5D5E:
        ADD A,01H                   ; 5D5E  C6 01
        JR LOC_5D68                 ; 5D60  18 06
LOC_5D62:
        SRL E                       ; 5D62  CB 3B
        JR NC,LOC_5D5E              ; 5D64  30 F8
        JR LOC_5D5A                 ; 5D66  18 F2
LOC_5D68:
        PUSH AF                     ; 5D68  F5
        LD HL,D000H                 ; 5D69  21 00 D0
        LD A,28H                    ; 5D6C  3E 28
LOC_5D6E:
        ADD HL,DE                   ; 5D6E  19
        DEC A                       ; 5D6F  3D
        JR NZ,LOC_5D6E              ; 5D70  20 FC
        ADD HL,BC                   ; 5D72  09
        LD A,(1E2CH)                ; 5D73  3A 2C 1E
        OR A                        ; 5D76  B7
        CALL NZ,SNCV                ; 5D77  C4 A6 0D
        LD A,(HL)                   ; 5D7A  7E
        EX AF,AF_                   ; 5D7B  08
        LD A,(DATA_1238)            ; 5D7C  3A 38 12
        CP FFH                      ; 5D7F  FE FF
        JR Z,LOC_5DA0               ; 5D81  28 1D
        EX AF,AF_                   ; 5D83  08
        CP F0H                      ; 5D84  FE F0
        JR NC,LOC_5D8A              ; 5D86  30 02
        LD A,F0H                    ; 5D88  3E F0
LOC_5D8A:
        POP BC                      ; 5D8A  C1
        LD C,A                      ; 5D8B  4F
        EX AF,AF_                   ; 5D8C  08
        OR A                        ; 5D8D  B7
        LD A,B                      ; 5D8E  78
        JR Z,LOC_5D94               ; 5D8F  28 03
        OR C                        ; 5D91  B1
        JR LOC_5D96                 ; 5D92  18 02
LOC_5D94:
        CPL                         ; 5D94  2F
        AND C                       ; 5D95  A1
LOC_5D96:
        CP F0H                      ; 5D96  FE F0
        JR NZ,LOC_5D9B              ; 5D98  20 01
        XOR A                       ; 5D9A  AF
LOC_5D9B:
        LD (HL),A                   ; 5D9B  77
        POP HL                      ; 5D9C  E1
        JP LOC_122D                 ; 5D9D  C3 2D 12
LOC_5DA0:
        EX AF,AF_                   ; 5DA0  08
        SUB F0H                     ; 5DA1  D6 F0
        POP BC                      ; 5DA3  C1
        JR C,LOC_5DAE               ; 5DA4  38 08
        AND B                       ; 5DA6  A0
        JR Z,LOC_5DAE               ; 5DA7  28 05
        LD DE,276CH                 ; 5DA9  11 6C 27
        JR LOC_5DB1                 ; 5DAC  18 03
LOC_5DAE:
        LD DE,2767H                 ; 5DAE  11 67 27
LOC_5DB1:
        JP LOC_2714                 ; 5DB1  C3 14 27
        CALL SUB_1A58               ; 5DB4  CD 58 1A
        CALL SUB_2967               ; 5DB7  CD 67 29
        PUSH DE                     ; 5DBA  D5
        LD A,C                      ; 5DBB  79
        PUSH AF                     ; 5DBC  F5
        CALL SUB_27E1               ; 5DBD  CD E1 27
        INC L                       ; 5DC0  2C
        CALL SUB_1A58               ; 5DC1  CD 58 1A
        CALL SUB_2967               ; 5DC4  CD 67 29
        POP AF                      ; 5DC7  F1
        PUSH DE                     ; 5DC8  D5
        LD B,A                      ; 5DC9  47
        PUSH BC                     ; 5DCA  C5
        LD BC,01FFH                 ; 5DCB  01 FF 01
        PUSH BC                     ; 5DCE  C5
        CALL SUB_27D2               ; 5DCF  CD D2 27
        INC L                       ; 5DD2  2C
        RET P                       ; 5DD3  F0
        LD E,L                      ; 5DD4  5D
        CALL SUB_1221               ; 5DD5  CD 21 12
        LD A,E                      ; 5DD8  7B
        OR A                        ; 5DD9  B7
LOC_5DDA:
        JP Z,LOC_237A               ; 5DDA  CA 7A 23
        POP BC                      ; 5DDD  C1
        LD B,A                      ; 5DDE  47
        PUSH BC                     ; 5DDF  C5
        CALL SUB_27D2               ; 5DE0  CD D2 27
        INC L                       ; 5DE3  2C
        RET P                       ; 5DE4  F0
        LD E,L                      ; 5DE5  5D
        CALL SUB_1221               ; 5DE6  CD 21 12
        LD A,E                      ; 5DE9  7B
        OR A                        ; 5DEA  B7
        JR Z,LOC_5DDA               ; 5DEB  28 ED
        POP BC                      ; 5DED  C1
        LD C,A                      ; 5DEE  4F
        PUSH BC                     ; 5DEF  C5
        CALL SUB_27E1               ; 5DF0  CD E1 27
        ADD HL,HL                   ; 5DF3  29
        POP BC                      ; 5DF4  C1
        POP DE                      ; 5DF5  D1
        PUSH HL                     ; 5DF6  E5
        EXX                         ; 5DF7  D9
        POP HL                      ; 5DF8  E1
        EX (SP),HL                  ; 5DF9  E3
        EX DE,HL                    ; 5DFA  EB
        POP HL                      ; 5DFB  E1
        EX (SP),HL                  ; 5DFC  E3
        CALL SUB_2959               ; 5DFD  CD 59 29
        EX DE,HL                    ; 5E00  EB
        CALL SUB_2959               ; 5E01  CD 59 29
        EXX                         ; 5E04  D9
        LD A,C                      ; 5E05  79
        CP D                        ; 5E06  BA
        JR C,LOC_5E0A               ; 5E07  38 01
        LD A,D                      ; 5E09  7A
LOC_5E0A:
        LD C,A                      ; 5E0A  4F
        LD D,A                      ; 5E0B  57
        CP B                        ; 5E0C  B8
        JR C,LOC_5E39               ; 5E0D  38 2A
        LD A,E                      ; 5E0F  7B
        OR A                        ; 5E10  B7
        JR Z,LOC_5E39               ; 5E11  28 26
        LD A,B                      ; 5E13  78
        LD L,00H                    ; 5E14  2E 00
LOC_5E16:
        INC L                       ; 5E16  2C
        DEC B                       ; 5E17  05
        JR Z,LOC_5E20               ; 5E18  28 06
        DEC D                       ; 5E1A  15
        EXX                         ; 5E1B  D9
        INC DE                      ; 5E1C  13
        EXX                         ; 5E1D  D9
        JR LOC_5E16                 ; 5E1E  18 F6
LOC_5E20:
        LD A,D                      ; 5E20  7A
        SUB E                       ; 5E21  93
        JR C,LOC_5E39               ; 5E22  38 15
        INC A                       ; 5E24  3C
        LD H,E                      ; 5E25  63
        PUSH HL                     ; 5E26  E5
        EXX                         ; 5E27  D9
        POP BC                      ; 5E28  C1
        EX DE,HL                    ; 5E29  EB
        INC A                       ; 5E2A  3C
LOC_5E2B:
        DEC A                       ; 5E2B  3D
        JR Z,LOC_5E39               ; 5E2C  28 0B
        EX AF,AF_                   ; 5E2E  08
        CALL CMPSTR                 ; 5E2F  CD 80 01
        JR Z,LOC_5E3B               ; 5E32  28 07
        INC C                       ; 5E34  0C
        INC HL                      ; 5E35  23
        EX AF,AF_                   ; 5E36  08
        JR LOC_5E2B                 ; 5E37  18 F2
LOC_5E39:
        LD C,00H                    ; 5E39  0E 00
LOC_5E3B:
        LD A,C                      ; 5E3B  79
        JP LOC_1F43                 ; 5E3C  C3 43 1F
        CALL SUB_2B2A               ; 5E3F  CD 2A 2B
        CALL SUB_1204               ; 5E42  CD 04 12
        PUSH HL                     ; 5E45  E5
        LD HL,(CUR_LINE)            ; 5E46  2A 25 65
        CALL SUB_27B0               ; 5E49  CD B0 27
        JP NC,LOC_23DE              ; 5E4C  D2 DE 23
        EX DE,HL                    ; 5E4F  EB
        EX (SP),HL                  ; 5E50  E3
        CALL SUB_27E1               ; 5E51  CD E1 27
        INC L                       ; 5E54  2C
        CALL SUB_1A58               ; 5E55  CD 58 1A
        CALL SUB_2967               ; 5E58  CD 67 29
        LD (CUR_STMT),HL            ; 5E5B  22 27 65
        CALL SUB_2959               ; 5E5E  CD 59 29
        POP HL                      ; 5E61  E1
        PUSH DE                     ; 5E62  D5
        PUSH BC                     ; 5E63  C5
        LD DE,6000H                 ; 5E64  11 00 60
        CALL SUB_2848               ; 5E67  CD 48 28
        LD A,50H                    ; 5E6A  3E 50
        CP C                        ; 5E6C  B9
        JP C,LOC_238E               ; 5E6D  DA 8E 23
        POP BC                      ; 5E70  C1
        POP HL                      ; 5E71  E1
        LD B,00H                    ; 5E72  06 00
        INC C                       ; 5E74  0C
        CALL SUB_28F1               ; 5E75  CD F1 28
        CALL SUB_24C9               ; 5E78  CD C9 24
        CALL SUB_253E               ; 5E7B  CD 3E 25
        LD HL,(WS_6057)             ; 5E7E  2A 57 60
        CALL SUB_22C0               ; 5E81  CD C0 22
        CALL SUB_29DA               ; 5E84  CD DA 29
        JP LOC_122A                 ; 5E87  C3 2A 12
; --- SUB_5E8A: called from 3 places ---
SUB_5E8A:
        LD (WS_62B4),HL             ; 5E8A  22 B4 62
        EX DE,HL                    ; 5E8D  EB
        LD HL,(CUR_LINE)            ; 5E8E  2A 25 65
        LD A,L                      ; 5E91  7D
        OR H                        ; 5E92  B4
        JP Z,SUB_2900               ; 5E93  CA 00 29
        CALL SUB_27B0               ; 5E96  CD B0 27
        JP NC,SUB_2900              ; 5E99  D2 00 29
        LD HL,6523H                 ; 5E9C  21 23 65
        JP LOC_2903                 ; 5E9F  C3 03 29
        PUSH HL                     ; 5EA2  E5
        CALL SUB_214E               ; 5EA3  CD 4E 21
        PUSH DE                     ; 5EA6  D5
        LD A,E                      ; 5EA7  7B
        SUB C                       ; 5EA8  91
        EXX                         ; 5EA9  D9
        PUSH HL                     ; 5EAA  E5
        PUSH AF                     ; 5EAB  F5
        CALL SUB_2147               ; 5EAC  CD 47 21
        POP AF                      ; 5EAF  F1
LOC_5EB0:
        INC DE                      ; 5EB0  13
        DEC A                       ; 5EB1  3D
        JR NZ,LOC_5EB0              ; 5EB2  20 FC
        JP LOC_2182                 ; 5EB4  C3 82 21
LOC_5EB7:
        CALL SUB_27E1               ; 5EB7  CD E1 27
        ADD HL,HL                   ; 5EBA  29
        JP LOC_1444                 ; 5EBB  C3 44 14
        LD A,(WS_62B9)              ; 5EBE  3A B9 62
        EX AF,AF_                   ; 5EC1  08
        CALL SUB_4DC0               ; 5EC2  CD C0 4D
        JP Z,LOC_2372               ; 5EC5  CA 72 23
        PUSH HL                     ; 5EC8  E5
        CALL SUB_4DE1               ; 5EC9  CD E1 4D
        JP P,MON_0823               ; 5ECC  F2 23 08
        LD (WS_62B9),A              ; 5ECF  32 B9 62
        LD BC,0008H                 ; 5ED2  01 08 00
        ADD HL,BC                   ; 5ED5  09
        LD A,(HL)                   ; 5ED6  7E
        OR A                        ; 5ED7  B7
        LD DE,276CH                 ; 5ED8  11 6C 27
        JR NZ,LOC_5EDF              ; 5EDB  20 02
        LD E,67H                    ; 5EDD  1E 67
LOC_5EDF:
        JP LOC_2714                 ; 5EDF  C3 14 27
LOC_5EE2:
        LD HL,635AH                 ; 5EE2  21 5A 63
LOC_5EE5:
        CALL SUB_28B2               ; 5EE5  CD B2 28
        CALL SUB_2A2B               ; 5EE8  CD 2B 2A
        EX DE,HL                    ; 5EEB  EB
        SBC HL,DE                   ; 5EEC  ED 52
        PUSH HL                     ; 5EEE  E5
        POP BC                      ; 5EEF  C1
        CALL NZ,SUB_4875            ; 5EF0  C4 75 48
LOC_5EF3:
        CALL SUB_27CF               ; 5EF3  CD CF 27
        INC L                       ; 5EF6  2C
        JR NC,LOC_5F0B              ; 5EF7  30 12
        JR LOC_5F03                 ; 5EF9  18 08
        PUSH HL                     ; 5EFB  E5
        CALL SUB_2981               ; 5EFC  CD 81 29
        POP HL                      ; 5EFF  E1
        JP Z,LOC_18F8               ; 5F00  CA F8 18
LOC_5F03:
        CALL SUB_1221               ; 5F03  CD 21 12
        LD (CUR_STMT),HL            ; 5F06  22 27 65
        LD B,03H                    ; 5F09  06 03
LOC_5F0B:
        LD HL,6360H                 ; 5F0B  21 60 63
LOC_5F0E:
        DEC E                       ; 5F0E  1D
        JR Z,LOC_5EE5               ; 5F0F  28 D4
        DEC HL                      ; 5F11  2B
        DEC HL                      ; 5F12  2B
        DJNZ LOC_5F0E               ; 5F13  10 F9
        LD B,03H                    ; 5F15  06 03
        LD HL,6366H                 ; 5F17  21 66 63
LOC_5F1A:
        DEC E                       ; 5F1A  1D
        JR Z,LOC_5EE5               ; 5F1B  28 C8
        DEC HL                      ; 5F1D  2B
        DEC HL                      ; 5F1E  2B
        DJNZ LOC_5F1A               ; 5F1F  10 F9
        DEC E                       ; 5F21  1D
        JR Z,LOC_5EE2               ; 5F22  28 BE
        DEC E                       ; 5F24  1D
        JR NZ,LOC_5F41              ; 5F25  20 1A
        LD HL,64ADH                 ; 5F27  21 AD 64
        LD (STR_PTR),HL             ; 5F2A  22 6E 63
        LD HL,6529H                 ; 5F2D  21 29 65
        CALL SUB_2A2B               ; 5F30  CD 2B 2A
        LD HL,64B3H                 ; 5F33  21 B3 64
        LD DE,0007H                 ; 5F36  11 07 00
        LD B,0FH                    ; 5F39  06 0F
LOC_5F3B:
        LD (HL),A                   ; 5F3B  77
        ADD HL,DE                   ; 5F3C  19
        DJNZ LOC_5F3B               ; 5F3D  10 FC
        JR LOC_5EF3                 ; 5F3F  18 B2
LOC_5F41:
        DEC E                       ; 5F41  1D
        JR NZ,LOC_5F55              ; 5F42  20 11
        LD HL,6516H                 ; 5F44  21 16 65
        LD (ARRAY_PTR),HL           ; 5F47  22 70 63
        LD HL,652BH                 ; 5F4A  21 2B 65
        LD (HL),00H                 ; 5F4D  36 00
        DEC HL                      ; 5F4F  2B
        LD A,(HL)                   ; 5F50  7E
        DEC HL                      ; 5F51  2B
        LD (HL),A                   ; 5F52  77
        JR LOC_5EF3                 ; 5F53  18 9E
LOC_5F55:
        DEC E                       ; 5F55  1D
        JP NZ,LOC_237A              ; 5F56  C2 7A 23
        LD HL,0000H                 ; 5F59  21 00 00
        LD (MONIT),HL               ; 5F5C  22 00 00
        XOR A                       ; 5F5F  AF
        LD (MONIT),A                ; 5F60  32 00 00
        JR LOC_5EF3                 ; 5F63  18 8E
        PUSH HL                     ; 5F65  E5
        CALL SUB_159E               ; 5F66  CD 9E 15
        ADD HL,BC                   ; 5F69  09
        LD (ARRAY_PTR),HL           ; 5F6A  22 70 63
        POP HL                      ; 5F6D  E1
        JP LOC_122D                 ; 5F6E  C3 2D 12
        LD A,01H                    ; 5F71  3E 01
        JR LOC_5F76                 ; 5F73  18 01
        XOR A                       ; 5F75  AF
LOC_5F76:
        CALL SNCV                   ; 5F76  CD A6 0D
        LD (WS_E003),A              ; 5F79  32 03 E0
        JP LOC_122D                 ; 5F7C  C3 2D 12
SUB_5F7F:
        CALL SUB_1DBE               ; 5F7F  CD BE 1D
        CALL SUB_1BDF               ; 5F82  CD DF 1B
        PUSH HL                     ; 5F85  E5
        CALL SUB_2B0E               ; 5F86  CD 0E 2B
        CALL SUB_1453               ; 5F89  CD 53 14
        LD A,(HL)                   ; 5F8C  7E
        INC HL                      ; 5F8D  23
        POP HL                      ; 5F8E  E1
        RET                         ; 5F8F  C9
        PUSH HL                     ; 5F90  E5
        CALL SUB_1A58               ; 5F91  CD 58 1A
        EXX                         ; 5F94  D9
        LD BC,0005H                 ; 5F95  01 05 00
        CALL SUB_1218               ; 5F98  CD 18 12
        PUSH DE                     ; 5F9B  D5
        PUSH BC                     ; 5F9C  C5
        CALL SUB_27E1               ; 5F9D  CD E1 27
        INC L                       ; 5FA0  2C
        CALL SUB_1A58               ; 5FA1  CD 58 1A
        CALL SUB_2981               ; 5FA4  CD 81 29
        JP NZ,LOC_2372              ; 5FA7  C2 72 23
        CALL SUB_2B09               ; 5FAA  CD 09 2B
        POP DE                      ; 5FAD  D1
        POP HL                      ; 5FAE  E1
        EX (SP),HL                  ; 5FAF  E3
        PUSH DE                     ; 5FB0  D5
        CALL SUB_5F7F               ; 5FB1  CD 7F 5F
        POP BC                      ; 5FB4  C1
        POP DE                      ; 5FB5  D1
        PUSH HL                     ; 5FB6  E5
        CALL SUB_2B09               ; 5FB7  CD 09 2B
        POP HL                      ; 5FBA  E1
        CALL SUB_27E1               ; 5FBB  CD E1 27
        INC L                       ; 5FBE  2C
        CALL SUB_1214               ; 5FBF  CD 14 12
        CALL SUB_5F7F               ; 5FC2  CD 7F 5F
        JP LOC_122D                 ; 5FC5  C3 2D 12
SUB_5FC8:
        EXX                         ; 5FC8  D9
        LD HL,652BH                 ; 5FC9  21 2B 65
        LD A,(HL)                   ; 5FCC  7E
        CP 0FH                      ; 5FCD  FE 0F
        JP Z,LOC_2396               ; 5FCF  CA 96 23
        INC (HL)                    ; 5FD2  34
        DEC HL                      ; 5FD3  2B
        DEC HL                      ; 5FD4  2B
        LD DE,(ARRAY_PTR)           ; 5FD5  ED 5B 70 63
        DEC DE                      ; 5FD9  1B
        LD BC,0007H                 ; 5FDA  01 07 00
        LDDR                        ; 5FDD  ED B8
        INC DE                      ; 5FDF  13
        LD (ARRAY_PTR),DE           ; 5FE0  ED 53 70 63
        LD HL,6529H                 ; 5FE4  21 29 65
        LD (HL),00H                 ; 5FE7  36 00
        EXX                         ; 5FE9  D9
        RET                         ; 5FEA  C9
        NOP                         ; 5FEB  00
        NOP                         ; 5FEC  00
        NOP                         ; 5FED  00
        NOP                         ; 5FEE  00
        NOP                         ; 5FEF  00
        NOP                         ; 5FF0  00
        NOP                         ; 5FF1  00
        NOP                         ; 5FF2  00
        NOP                         ; 5FF3  00
        NOP                         ; 5FF4  00
        NOP                         ; 5FF5  00
        NOP                         ; 5FF6  00
        NOP                         ; 5FF7  00
        NOP                         ; 5FF8  00
        NOP                         ; 5FF9  00
        NOP                         ; 5FFA  00
        NOP                         ; 5FFB  00
        NOP                         ; 5FFC  00
        NOP                         ; 5FFD  00
        NOP                         ; 5FFE  00
        NOP                         ; 5FFF  00
