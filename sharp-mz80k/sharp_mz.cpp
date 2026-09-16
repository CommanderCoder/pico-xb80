#include "sharp_mz.h"
#include "xb_interface/xb_if.h"
#include "FD_rom.h"


// PORTO at 0xE000 is the decoder which
// drives The keyboard rows

// NOTE: the Original FD; MZ-80FD + MZ-80FIO needed to be plugged into the IO Interface Unit MZ-80I/O
// when it was installed type FD would read the program from ROM at 0xf000-0xf3ff 
// It would use the 4 port addresses 0xf8-0xfb to interface and grab the first 14 sectors from
// track 0 into ram address 0x9800 (i.e. machine needs > 36Kb) and then executed at that address. 
// (128 bytes per sector)

// Possibly do the same by loading boot.mzf into 0x9800 and running it when FD is used (only if boot.mzf exists)
// and use *FDS to skip booting.





void SharpMZ_cmdloop()
{
    mzcmd_init();
 
    _DEBUG("\nEntering Sharp MZ command loop. Waiting for commands from Z80...\n");

    uint8_t last_command = 0;
    while(1)
    {
        mzcmd_commandwait();
    }
    
}

void SharpMZ_initialise()
{
    // Initialise the FD Rom
    const int fd_rom_start = 0xF000;

    assert(fd_rom_size <= 0x0ff9); // Cannot drift into the bytes used for the SD card interface (0xFFFA-0xFFFF)
    // initialise the shadow memory
    for (int i = 0; i < EB_BUFFER_LENGTH; i++) {
        if (i >= fd_rom_start && i <= fd_rom_start + fd_rom_size) {
            eb_set(i, fd_rom_data[i-fd_rom_start]); // data byte in lower 8 bits
        } else {
            eb_set(i, 0); // default to 0 
        }
    }

    // the ROM - permissions 0x01 (read-only) in upper 8 bits
    eb_set_perm(0xF000, EB_PERM_READ_ONLY, 0x0FF9);


    // z80 empties first, then expects pico to empty - this means the
    // ROM is ready to be read by the Z80 and the SD card interface is ready to be used
    wait_z80_mailbox_empty();

}