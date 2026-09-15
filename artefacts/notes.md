Pick a region in the 64K shadow RAM.

0xFF00  COMMAND
0xFF01  STATUS
0xFF02  PARAM_LEN
0xFF10  DATA BUFFER

Protocol:
| STATUS | Meaning        |
| ------ | -------------- |
| 0      | idle           |
| 1      | command ready  |
| 2      | busy           |
| 3      | response ready |

Replace rcv1byte()/snd1byte()

cmd = rcv1byte(); becomes
cmd = shared_ram[0xFF00];

snd1byte(value); becomes
shared_ram[0xFF10] = value;

SD Task:

void loop() {

    if (z80mem[STATUS] == CMD_READY) {

        z80mem[STATUS] = BUSY;

        execute_command();

        z80mem[STATUS] = RESPONSE_READY;
    }
}


To copy a buffer of data:
memcpy(&z80mem[DATA], s_data, 128);

Or with length:
cmd = z80mem[CMD];
len = z80mem[PARAM_LEN];
memcpy(f_name, &z80mem[DATA], len);

Suggested modernized mailbox layout

FF00 CMD
FF01 STATUS
FF02 ERR
FF03 LEN
FF04 TRACK
FF05 SECTOR
FF10 DATA (240 bytes)

commands:
01 = OPEN
02 = READ
03 = WRITE
04 = DIR
05 = CLOSE

status model:
0 = idle
1 = request pending
2 = busy
3 = completed
FF = error


==== Z80

instead of
OUT (port),A
WAIT
IN A,(port)
WAIT

use
LD A,(address)
LD (address),A


# Example command send

Suppose command 01h = OPEN FILE

Z80 side

        LD      A,01H
        LD      (0FF00H),A      ; command

        LD      A,08H
        LD      (0FF02H),A      ; filename length

        LD      HL,FILENAME
        LD      DE,0FF10H
        LD      BC,8
        LDIR

        LD      A,01H
        LD      (0FF01H),A      ; STATUS=REQUEST

RP2040 side

if(mem[0xFF01] == 1) {

    mem[0xFF01] = 2; // busy

    execute_command();

    mem[0xFF01] = 3; // done
}


Z80 waits for completion

Your old:

CALL F1CHK

becomes:

WAITDONE:
        LD      A,(0FF01H)
        CP      03H
        JR      NZ,WAITDONE

    File transfer becomes massively faster

Your old 128-byte send:

LOOP:
    LD A,(HL)
    CALL SNDBYTE
    INC HL
    DJNZ LOOP

becomes:

        LD      HL,BUFFER
        LD      DE,0FF10H
        LD      BC,128
        LDIR

This is a gigantic speed improvement.   



======


registers
FE00 - command
FE01 - status
FE02 - result
FE03 - length
FE80..FEFF - shared data (128 bytes)

Process 
z80 write data to RP2040
1. write data into 80-FF
2. write length into FE02
3. write PUT command into FE00
4. (RP2040 will write busy into FE01)
5. wait until READY in FE01
8. write 0 into FE01

when RP2040 finished, write READY into FE01

Status bitfields -
x01 - BUSY
x02 - READY
x04 - ERROR
x06 - READY + ERROR

Process 
z80 read data from RP2040
1. write data into 80-FF
2. write length into FE02
3. write GET command into FE00
5. wait until READY in FE01
6. read length from FE02
7. read data from 80-to length
8. write 0 into FE01


when RP2040 finished writing data into 80-FF, write READY into FE01 and OK into FE02


