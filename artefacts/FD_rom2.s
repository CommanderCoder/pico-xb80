			ORG	0F000H

			DB	0FFH             ;ROM�Ȃ����ʃR�[�h
			JP		START
;******************** MONITOR CMT���[�`���փ��^�[�� *************************************
			JP		MSHED
			JP		MSDAT
			JP		MLHED
			JP		MLDAT
			JP		MVRFY
START:							;���ʃR�[�h��ROM����(00H)�ɕύX���AFD�R�}���h��L���ɂ����ꍇ�A���̏������N��
			LD	HL,DATA			;DATA����LENGTH�o�C�g��TRNS�ɃR�s�[����DSTRT������s
			LD	DE,(TRNS)
			LD	BC,(LENGTH)
			LDIR
			LD	HL,(DSTRT)
			JP	(HL)
LENGTH:
			DW 03C0H
TRNS:
			DW 5A40H
DSTRT:
			DW 5B00H
MSHED:							;JUMP���Ă�����Ƀ��^�[��
			PUSH	DE			;PUSH���߂��Ԃ���JUMP���Ă��Ă���̂ő����PUSH�͂��Ă���
			PUSH	BC
			PUSH	HL
			JP	043AH
MSDAT:
			PUSH	DE
			PUSH	BC
			PUSH	HL
			JP	0479H
MLHED:
			PUSH	DE
			PUSH	BC
			PUSH	HL
			JP	04DCH
MLDAT:
			PUSH	DE
			PUSH	BC
			PUSH	HL
			JP 04FCH
MVRFY:
			PUSH	DE
			PUSH	BC
			PUSH	HL
			JP	058CH
DATA:							;��������N���������v���O������W�J(4023Byte���p�\)
			END
