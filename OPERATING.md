# Operator Guide

## Preparing SD Card

All files must be within a subfolder called /MZ_FD and they must be binary files (no zips *yet*) and they must have the extension `.mzf` (case insensitive)

## `*FD`

Boot the file named 0000.mzf on the SD card use.  This is a convenience to startup any application quickly on the machine. A copy of BASIC is usually a good choice for this file.

## `*FDF`

Boot a File Menu which lists all files on the SD card.

# File Menu

## Help

> H

Display a help page explaining these navigation keys using 1 or 2 word phrases.

## Navigation

> W S

Use W/S to move up and down the list.

> , .

Use `,` and `.` to turn pages backward and forward (if there are multiple pages of files).

> X or ENTER

Load and execute (run) the file

> L

Load the file but do not execute it.  The load address is reported and you are returned to the monitor, so the loaded program can be started with `G` when you are ready.

> F

Filter the list by the next letter that you type. e.g. `F  B` would list only files beginning with B.

Press ENTER or SHIFT+BREAK at the `FILTER LETTER?` prompt to clear the filter and show every file again.

> T

Toggle between showing Basic and Machine code file types.  Each press cycles `ALL` → `BASIC` → `M-CODE` → `ALL`, and the current setting is shown on the status line at the top of the screen.

A file counts as machine code when its MZF header type byte is 01H, and as Basic for the other type codes.

> A

Copy the file to `0000.mzf`.  This enables changing the autoboot file from within the file menu.

> C 

Copy this file.  You will be prompted for a new filename.  If the new filename is the same as another [IBF filename](#ibf-filename) then the operation will fail.

The new name is applied to both the [IBF filename](#ibf-filename) and the SDCard filename of the copy, so the copy does not inherit the original's name.

> R

Rename this file.  You will be prompted for a new filename.  If the new filename is the same as another [IBF filename](#ibf-filename) then the operation will fail.

The new name is applied to both the [IBF filename](#ibf-filename) and the SDCard filename, exactly as it is when saving.  This is the way to give a file a name of its own when it shares one with another file.

> D

Delete this file. You will be prompted to confirm.

> P

Printout (Dump to screen) the contents of the file as 128 bytes per screen.

Once one screen is displayed, it will show "NEXT:ANY BACK:B BREAK:SHIFT+BREAK" and wait for instructions. Press B to display the previous 128 bytes, SHIFT+BREAK to cancel, and any other key to display the next 128 bytes.

If the file size is not divisible by 128 bytes, the last page will be filled with 00H until it reaches 128 bytes.

> SHIFT+BREAK

Exit back to the monitor.

## Filenames

Filenames on cassette are limited to 16 characters (plus a terminator character).

Filenames on the SD card have a much larger limit, but when listing filenames and referencing files from programs like BASIC, the [IBF filename](#ibf-filename) is used from with in the file header.

### IBF filename

Because files on tape or punch cards came sequentially, the filename is stored within the header of the file and not in a file table like they are on hard drives.  This filename is called the IBF by Yanataka.

The File Menu lists IBF filenames, and every command that takes a filename matches on the IBF filename first, falling back to the SDCard filename if nothing matches.  That fallback is what lets `*FD` find `0000.mzf`, whose IBF filename is whatever program it happens to hold.

### Duplicate IBF filenames

Nothing stops two files having the same IBF filename, and it happens easily: a patched copy of a program usually keeps the header of the original it was made from.

Where several files share an IBF filename, the listing tags each one `<1`, `<2`, `<3` and so on, in the order they are found on the card:

```
BASIC SP-5025<1
BASIC SP-5025<2
```

The tag is added to the end of the name, or replaces the last few characters when the name is already too long to grow.

In the File Menu the tags are only there so you can tell the rows apart: every operation (`X`, `L`, `A`, `C`, `R`, `D`, `P`) acts on the highlighted row itself, never on its name, so it always affects exactly the file you are pointing at.

> The tags exist only in the listing.  **The files on the card are not altered** and their headers still hold the original name, so a tag can move if you add or remove files.  Use `R` to give a file a name of its own if you want one that will not change.

Where a file must be named — from BASIC or the command line — the tagged name picks out one particular file, and an untagged name finds the first file carrying it.

## Loading from BASIC and other programs patched for `Pico-XB80`

BASIC and other programs will call routines within the monitor to load and save (*punch*) files.  These would take the file in memory and save it to cassette (or punch card!) starting at a known address, for a known length, and with a known execution address when it is loaded again.

> ⚠️ SAVE filenames must have fewer than 17 characters.

Just like with Cassette (CMT), please enter the file name and other information according to the input method and rules specified by the application and save it.

When saving, the entered filename will be applied to both the [IBF filename](#ibf-filename) and the SDCard filename.

The `.mzf` extension is automatically added to the SDCard filename.

For example, in BASIC SP-5030...

`SAVE "TEST"`

Will create a BASIC file called TEST.mzf with the IBF filename `TEST`.

> ⚠️ LOAD filenames must have fewer than 17 characters.

Although you can specify an IBF file name after commands such as L and LOAD specified by the application, simply press the ENTER key after the command such as L or LOAD without specifying an IBF filename will display the File Menu.

# Additional Command Line (after Yanataka MZ80K-SD)

## FD

The following commands are available from the MONITOR command input.  That is the `*` prompt.  All filenames are their [IBF filename](#ibf-filename) not the filename on the SDCard.

> FDS saddr eaddr xaddr filename

This command saves the data from the save start address to the save end address using the given filename.  The filename must have fewer than 17 characters and it will be the IBF filename, and the SDCard filename suffixed with `.mzf`

The save start address, save end address, and execution start address are specified using 4-digit hexadecimal numbers.

`*FDS　1200　2FFF　1200　TEST`


> FDM saddr

This displays the memory contents of the MZ-80K, starting from the address, in 128-byte segments per screen.

Once one screen is displayed, it will show "NEXT:ANY BACK:B BREAK:SHIFT+BREAK" and wait for instructions. Press B to display the previous 128 bytes, SHIFT+BREAK to cancel, and any other key to display the next 128 bytes.

You can cancel the display at any time by pressing SHIFT+BREAK, even while a single screen is being displayed.

> FDW saddr hexbytes* [CR]

The hexbyte (multiple 2-digit hexadecimal values), starting from the address, is written to the MZ-80K's memory.

Enter the data to be written as two hexadecimal digits after the starting address, and then press the ENTER key. Spaces separating the data will be ignored, so they can be included or omitted.

You can have any number of byte data entries in a 2-digit hexadecimal format, as long as they fit on a single line.

Enter a line of data and press the ENTER key to write it into memory. The next address will then be displayed, allowing you to continue entering data.

Furthermore, by correcting the address, it is possible to go back and make corrections or write data to a different address.

To stop writing data, press the ENTER key without writing any data to the displayed address.

If you enter a number other than hexadecimal and press the ENTER key, the system will write the valid data up to the point immediately before the non-hexadecimal input and display the next address.

`*FDW　1200　01　02　03　04　05　06　07　08`

`*FDW　1200　0102030405060708`

`*FDW 1200` (when stopping)

`*FDW 1200 12 34 5/` (Written up to 12 34)




# MZ700

    There is no support for MZ700 yet.

Note that while the MZ-700's floppy disk drive startup command is actually just the letter 'F', we've standardized the operation method to use 'FD'.

FDZ[CR]
　[For MZ-700 only] This program functions the same as "FT.MZT," which was created for the MZ-700. After copying MONITOR 1Z-009A or 1Z-009B to the back RAM and applying the patch, the MONITOR on the back RAM will start.

　If executed on an MZ-80K, it will result in a RESET operation.

FDU[CR]
　[For MZ-700 only, only when resetting while operating with the rear RAM MONITOR] Switches to rear RAM and starts the rear RAM MONITOR.

　Note: Running this program without the MONITOR module in the background RAM will cause it to malfunction.

　If executed on an MZ-80K, it will result in a RESET operation.

# S-OS SWORD

    This is untested.


When using [S-OS SWORD](https://handwiki.org/wiki/Software%3AS-OS), immediately after startup, set the device to "DV S:" and configure each device as a SYSTEM device.

This might only be the case with FUZZY BASIC, but when using a common format device, I couldn't omit the IBF file name with the LOAD command.

