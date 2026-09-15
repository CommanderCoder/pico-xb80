# PICO tools to upload the 


cmake -S . -B build -G Ninja



# ARDUINO-CLI tool to upload to arduino

# List all available boards
arduino-cli board listall | grep -i mega

# Detect connected boards
arduino-cli board list


cd arduino_eb_test
arduino-cli compile --fqbn arduino:avr:mega arduino_eb_test.ino

arduino-cli upload -p /dev/cu.usbserial-0001 --fqbn arduino:avr:mega arduino_eb_test.ino

# build arduino mega - mimics the Z80 cpu
ARDUINO_PORT=/dev/cu.usbserial-0001
arduino-cli compile --upload -p "$ARDUINO_PORT" --fqbn arduino:avr:mega arduino_eb_test.ino && arduino-cli monitor -c 115200 -b arduino:avr:mega -p "$ARDUINO_PORT"


# to view the output

# from pico
minicom -b 115200 -D /dev/tty.usbmodem1101

# from arduino
minicom -b 115200 -D /dev/cu.usbserial-0001

or


arduino-cli monitor -p /dev/cu.usbserial-0001 -c 115200 -b arduino:avr:mega


# build Z80

./sjasmplus test.s --lst && hexdump -v -e '8/1 "0x%02x, " "\n"' test.bin > rom1.h 


https://mz-80a.com/Files/Manuals/Monitor-Disassembly-80K.pdf


	
	; just show a message...
	    LD   DE, MSG_LD1
        CALL MSGPR
        CALL NEWLIN
        LD   DE, MSG_LD2
        CALL MSGPR
		CALL LETLN
        JP   MON  ; Jump back to Monitor instead of RET

CURSORHOME		EQU		16H ; clear screen

MSG_LD1: DB   CURSORHOME, 'HELLO ANDREW AND KAREN', 0DH
MSG_LD2: DB   'THIS PROGRAM IS SITTING INSIDE MY LITTLE BOX', 0DH


# MZ80K Memory Map

RAM - 48K runs from 0x1000-0xCFFF (0xC000 bytes or 49152)
Workspace RAM for Monitor - 0x1000-0x11FF
RAM for programs 0x1200-0xcfff

## Basic
0x1200-0x4806

## Monitor
0x0000-0x0fff

## Video
0xD000-0xD3FF
Only 1000 locations seen. The other 24 are never shown
The locations are repeated 4 times, so making the 4096 addresses up to DFFF

MZ80A has 2k of video ram but each 1k selected in a special way.

## Memory Expansion & Addressing

## I/O At $E000 Locations

E000 keyboard driver
E001 keyboard receiver
E002 read-curser timer, cassette sense
E003 motor pulse, led

*8522 PIA*
E000 BEING PORT A
E001 BEING PORT B
E002 BEING PORT C
E003 BEING THE CONTROL WORD

all the peripherals ; 

*8253 TIMER*
E007 CONTROL WORD.
E006 COUNTER 2
E005 COUNTER 1
E004 COUNTER 0

*555 TEMPO TIMER*
E008 timer

### MZ80A EXTRAS
E00C MEMORY MONITOR EXCHANGE
E010  MEMORY MONITOR NORMAL
E014 STADNARD SCREEN DISPLAY
E015 REVERSE SCREEN DISPLAY
E200-E2FF DISPLAY RAM


_Maybe use 0xE300 for moving data to and from the PICO, But F000-FFFF is reserved and available_


MZ80A - has user ram/rom slot addressed at E800-EFFF - if E800 is NULL then this rom will run on powerup
..
plenty more
