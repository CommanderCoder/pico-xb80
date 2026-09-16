#include "sharp_mz.h"
#include "xb_interface/xb_if.h"


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