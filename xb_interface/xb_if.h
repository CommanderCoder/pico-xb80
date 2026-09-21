/* 

  Expansion Bus Interface for Z80 bus
  using PIO and DMA on the RP2350B (Olimex Pico2-XXL)

  Inspired by the work of Chris Moulang on the Atom-DVI project, 
  and adapted for the Z80 bus by Andrew Hague.
*/

/*

PIO/DMA interface to the 6502 bus

Copyright 2021-2025 Chris Moulang

This file is part of Atom-DVI

Atom-DVI is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

Atom-DVI is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
Atom-DVI. If not, see <https://www.gnu.org/licenses/>.

*/


#pragma once

#include "pico/stdlib.h"
#include "hardware/dma.h"
#include "hardware/pio.h"
#include "hardware/watchdog.h"
#include "hardware/clocks.h"
#include "xb_if.pio.h"
#include <string.h>
#include <stdio.h>

#define SYS_FREQ 240000

#define EB_ADD_BITS 16
#define EB_ADDRESS_HIGH 0x10000
#define EB_BUFFER_LENGTH 0x10000
#define EB_ADDRESS_LOW 0x0

#define _EB_WRITE_FLAG 0b010
#define _EB_READ_FLAG 0b001
#define _EB_READ_SNOOP_FLAG 0b100


#ifndef USBDEBUG
#define USBDEBUG 1
#endif


#if USBDEBUG
 #define _DEBUG(...) printf(__VA_ARGS__)
#else
 #define _DEBUG(...) {}
#endif

#ifdef __cplusplus
extern "C"
{
#endif

// Sized in xb_if.c (currently EB_BUFFER_LENGTH plus a few guard
// elements used by a temporary diagnostic) — declared without a bound here so
// this doesn't need to track that.
//
// NOTE - this shadows the Z80's *entire* 64K memory map (128KB of Pico RAM,
// data+permission byte per address) purely so a handful of memory-mapped
// handshake registers (Z80_TO_PICO_DATA/FLAG etc, see "Z80 Asm/FD_rom1.s")
// and the FD ROM shadow can be decoded by raw 16-bit address. If the Z80
// side moves to IN/OUT (IOREQ) for the handshake instead of LD (nn) (MREQ),
// this table only needs to cover the 8-bit I/O port space (<=256 entries)
// - a large RAM and address-decode simplification. See the matching note in
// xb_if.pio next to PIN_NMREQ/PIN_NIOREQ.
extern volatile uint16_t _Alignas(EB_BUFFER_LENGTH * 2) _eb_memory[] __attribute__((section(".uninitialized_dma_buffer")));
extern uint eb_event_chan;

enum eb_perm
{
    EB_PERM_NONE = 0,
    EB_PERM_READ_ONLY = _EB_READ_FLAG,
    EB_PERM_WRITE_ONLY = _EB_WRITE_FLAG,
    EB_PERM_READ_WRITE = (_EB_WRITE_FLAG | _EB_READ_FLAG),
    EB_PERM_READ_SNOOP = _EB_READ_SNOOP_FLAG,
};

static void eb_setup_dma();



/// @brief initialise and start the PIO and DMA interface to the Z80 bus
void eb_init();

static int perm_high = 0;
static int perm_low = EB_ADDRESS_HIGH;

static inline void print_perm_range()
{
    _DEBUG("perm range. low=%x high=%x\n", perm_low, perm_high);
}

/// @brief set the read/write permissions for an address
/// @param address 6502 address
/// @param  perm see enum for possible values
static inline void eb_set_perm_byte(uint16_t address, enum eb_perm perm) {
    if (perm != EB_PERM_NONE) {
        if (address > perm_high) perm_high = address;
        if (address < perm_low) perm_low = address;
    }

    volatile uint8_t *p = (uint8_t *)&_eb_memory[address] + 1;
    *p = perm;
}

/// @brief set the read/write permissions for a range of addresses
/// @param start 6502 starting address
/// @param  perm see enum for possible values
/// @param size number of bytes to set
static inline void eb_set_perm(uint16_t start, enum eb_perm perm, size_t size)
{
    hard_assert(start + size <= EB_ADDRESS_HIGH);
    for (size_t i = 0; i < size; i++)
    {
        eb_set_perm_byte(start + i, perm);
    }
}

/// @brief get a byte value
/// @param address the 6502 address
/// @return the value of the byte
static inline uint8_t eb_get(uint16_t address)
{
    return _eb_memory[address] & 0xFF;
}

/// @brief set a byte to a new value
/// @param address the 6502 address
/// @param value the new value
static inline void eb_set(uint16_t address, unsigned char value)
{
        volatile uint8_t *p = (uint8_t *)&_eb_memory[address];
        *p = value;
}

/// @brief get a string of chars
/// @param buffer destination buffer
/// @param size number of chars to get
/// @param address  address of source
static inline void eb_get_chars(char *buffer, size_t size, uint16_t address)
{
    for (size_t i = 0; i < size; i++)
    {
        buffer[i] = eb_get(address + i);
    }
}

/// @brief copy a string of chars to memory
/// @param address  address of destination
/// @param buffer source
/// @param size number of chars to copy
static inline void eb_set_chars(uint16_t address, const char *buffer, size_t size)
{
    hard_assert(address + size <= EB_ADDRESS_HIGH);
    for (size_t i = 0; i < size; i++)
    {
        eb_set(address + i, buffer[i]);
    }
}

/// @brief copy a null terminated string to memory
/// @param address  address of destination
/// @param str source
static inline void eb_set_string(uint16_t address, const char *str)
{
    eb_set_chars(address, str, strlen(str));
}

/// @brief copies a value to each location starting at address
/// @param address the address to start at
/// @param c the value to copy
/// @param size the number of loactions to set
static inline void eb_memset(uint16_t address, char c, size_t size)
{
    hard_assert(address + size <= EB_ADDRESS_HIGH);
    for (size_t i = address; i < address + size; i++)
    {
        eb_set(i, c);
    }
}


extern void mzcmd_init();
extern void mzcmd_commandwait();
extern uint8_t recbyte();
extern void sndbyte(uint8_t response);
extern void start_xb_interface();
extern void wait_z80_mailbox_empty();

#define SAVE 0x80 // using filename
#define LOAD 0x81 // using filename
#define ASTART 0x82
#define FILELIST 0x83 // list all filenames
#define FILEDEL 0x84
#define FILEREN 0x85
#define FILEDUMP 0x86
#define FILECOPY 0x87
#define MONITOR_WHEAD 0x91
#define MONITOR_WDATA 0x92
#define MONITOR_LHEAD 0x93
#define MONITOR_LDATA 0x94
#define BOOTLOAD 0x95

// Index-based commands. The index refers to the listing built by the last
// FILECOUNT, which is what the menu on the Z80 is showing, so these always act
// on exactly the row the user picked even when several files share a name.
#define FILECOUNT 0xA0 // get file count
#define FILEINFO 0xA1 // get file info by index
#define FILELOAD 0xA2 // load using INDEX not filename
#define FILEDEL_IDX 0xA3
#define FILEREN_IDX 0xA4
#define FILEDUMP_IDX 0xA5
#define FILECOPY_IDX 0xA6
#define ASTART_IDX 0xA7


#ifdef __cplusplus
}
#endif

