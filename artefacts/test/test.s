    	OUTPUT "test.bin"

MSGPR   EQU  0015H
MONIT7   EQU  00ADH  ; Monitor entry point
MONIT8   EQU  0082H  ; Monitor entry point
NEWLIN		EQU		0009H ; newline

CURSORHOME		EQU		16H ; clear screen

        ORG  0F000H
        NOP ; 0 here so *FD works and *GOTO$F000
START:  LD   DE, MSG_LD
        CALL MSGPR
        CALL NEWLIN
        LD   DE, MSG_LD2
        CALL MSGPR
        JP   MONIT8  ; Jump back to Monitor instead of RET

MSG_LD: DB   CURSORHOME, 'HELLO ANDREW AND KAREN', 0DH
MSG_LD2: DB   'THIS IS A PROGRAM', 0DH

        OUTEND