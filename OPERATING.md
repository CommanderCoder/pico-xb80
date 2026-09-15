

Operating method
　The following commands are available while waiting for the MONITOR command input.

　Note that while the MZ-700's floppy disk drive startup command is actually just the letter 'F', we've standardized the operation method to use 'FD'.

　In the following, the filenames assigned to files within the SD-CARD will be referred to as DOS filenames, and the filenames within the information block of MZT format files will be referred to as IBF filenames.

FD[CR]
　The DOS file named "0000.MZT" will be loaded and executed using only the floppy disk.

　You can create "0000.MZT" by renaming and copying files like BASIC SP-5030 on your PC, but you can also create it using FDA commands.

FD DOS file name [CR]
　This program loads and executes the binary file specified by its DOS filename.

　The ".MZT" extension is optional.

　This can be used as an alternative to the MONITOR's LOAD command. Note that the LOAD command can also be used, but it will be treated the same as a LOAD command from an application.

example)

FD　TEST[CR]

FD/DOS file name[CR] or FD/DOS file name[CR]
　This command loads the binary file specified by its DOS filename. It does not execute the file.

　The ".MZT" extension is optional.

example)

FD/TEST[CR]

FD/　TEST[CR]

FDL[CR]
　This displays a list of files in the SD-CARD root directory. After displaying 20 items, it will wait for further instructions. To stop, press SHIFT+BREAK or the up arrow key. Press the B key to return to the previous 20 items. Press any other key to display the next 20 items.

　Since the files are displayed with "*FD" appended to the beginning of each line, you can load and execute them simply by moving the cursor to the file you want to run and pressing the [CR] key.

　The displayed order is the order in which the files were registered; it is not possible to display them in a sorted order such as alphabetical order of filenames.

FDL　x[CR]
This displays a list of files whose filenames begin with "x". It will wait for instructions after displaying 20 files. To stop, press SHIFT+BREAK or the up arrow key. Press the B key to return to the previous 20 files. Press any other key to display the next 20 files.

x represents a string of up to 32 characters that can be entered from the MZ keyboard (numbers, symbols, and letters).

example)

FDL S[CR]

FDL SP[CR]

FDL BASIC S[CR]

FDA DOS file name [CR]
　This command renames and copies the file specified by its DOS filename to "0000.MZT".

　It's easy: simply select the filename displayed by the FDL command with the cursor, add only "A" to "*FD" at the beginning of the line, and press the [CR] key. 

FDS SAVE start address SAVE end address Execution start address DOS file name [CR]
　This command saves the data from the save start address to the save end address using a DOS filename.

　The save start address, save end address, and execution start address are specified using 4-digit hexadecimal numbers. The ".MZT" in the DOS filename is optional.

example)

FDS　1200　2FFF　1200　TEST[CR]

FDC DOS file name [CR]
　This will copy the file specified by its DOS filename.

　It's easy: simply select the filename displayed by the FDL command with the cursor, add only "C" to "*FD" at the beginning of the line, and press the [CR] key.

　Enter a DOS file name and press the [CR] key. It will then ask "NEW NAME:", so enter the new DOS file name and press the [CR] key again.

　If you specify an existing DOS file name as the new DOS file name, the copy process will be interrupted.

example)

FDC　TEST[CR]

NEW NAME:TEST2[CR]

FDR DOS file name [CR]
　This renames the file specified by its DOS filename.

　It's easy: simply select the filename displayed by the FDL command with the cursor, add only "R" to "*FD" at the beginning of the line, and press the [CR] key.

　Enter a DOS file name and press the [CR] key. It will then ask "NEW NAME:", so enter the new DOS file name and press the [CR] key again.

　If you specify an existing DOS file name as the new DOS file name, the process will be interrupted without renaming.

example)

FDR　TEST[CR]

NEW NAME:TEST2[CR]

FDD DOS file name [CR]
　This command deletes the file specified by its DOS filename.

　It's easy: simply select the filename displayed by the FDL command with the cursor, add only "D" to "*FD" at the beginning of the line, and press the [CR] key.

　Enter a DOS file name and press the [CR] key. You will be prompted with "FILE DELETE? (Y:OK ELSE:CANSEL)". Press Y to delete the file. Pressing any other key will cancel the deletion.

FDP DOS filename [CR]
　This program will dump the contents of the file specified by the DOS filename.

　It's easy: simply select the filename displayed by the FDL command with the cursor, add only "P" to "*FD" at the beginning of the line, and press the [CR] key.

　Enter a DOS file name and press the [CR] key to display the file contents as 128 bytes per screen.

　Once one screen is displayed, it will show "NEXT:ANY BACK:B BREAK:SHIFT+BREAK" and wait for instructions. Press B to display the previous 128 bytes, SHIFT+BREAK to cancel, and any other key to display the next 128 bytes.

　If the file size is not divisible by 128 bytes, the last page will be filled with 00H until it reaches 128 bytes.

　You cannot rewrite the file contents.

FDM start address [CR]
　This displays the memory contents of the MZ-80K, starting from the address, in 128-byte segments per screen.

　Once one screen is displayed, it will show "NEXT:ANY BACK:B BREAK:SHIFT+BREAK" and wait for instructions. Press B to display the previous 128 bytes, SHIFT+BREAK to cancel, and any other key to display the next 128 bytes.

　You can cancel the display at any time by pressing SHIFT+BREAK, even while a single screen is being displayed.

FDW start address 1 byte (2 hexadecimal digits) data [CR]
　The 2-digit hexadecimal data, starting from the address, is written to the MZ-80K's memory.

　Enter the data to be written as two hexadecimal digits after the starting address, and then press the [CR] key. Spaces separating the data will be ignored, so they can be included or omitted.

　You can have any number of byte data entries in a 2-digit hexadecimal format, as long as they fit on a single line.

　Enter a line of data and press the [CR] key to write it down. The next address will then be displayed, allowing you to continue entering data.

　Furthermore, by correcting the address, it is possible to go back and make corrections or write data to a different address.

　To stop writing data, press the [CR] key without writing any data to the displayed address.

　If you enter a number other than hexadecimal and press the [CR] key, the system will write the valid data up to the point immediately before the non-hexadecimal input and display the next address.

example)

*FDW　1200　01　02　03　04　05　06　07　08[CR]

*FDW　1200　0102030405060708[CR]

*FDW 1200[CR] (when stopping)

*FDW 1200 12 34 5/[CR] (Written up to 12 34)

FDZ[CR]
　[For MZ-700 only] This program functions the same as "FT.MZT," which was created for the MZ-700. After copying MONITOR 1Z-009A or 1Z-009B to the back RAM and applying the patch, the MONITOR on the back RAM will start.

　If executed on an MZ-80K, it will result in a RESET operation.

FDU[CR]
　[For MZ-700 only, only when resetting while operating with the rear RAM MONITOR] Switches to rear RAM and starts the rear RAM MONITOR.

　Note: Running this program without the MONITOR module in the background RAM will cause it to malfunction.

　If executed on an MZ-80K, it will result in a RESET operation.

Loading from the application
　Although you can specify an IBF file name after commands such as L and LOAD specified by the application, simply press the [CR] key after the command such as L or LOAD without specifying an IBF file name.

　In the case of CMT, you would normally be instructed to press the PLAY button here, but it will display "DOS FILE:" and wait for input, so enter the DOS file name and press the [CR] key. At this point, you can omit entering ".MZT".

　DOS filenames are limited to 32 characters, excluding ".MZT" extensions. However, half-width katakana characters and certain symbols are not recognized by Arduino and cannot be used. When naming files on a computer, please use only letters, numbers, and spaces.

For example, in BASIC SP-5030...

× LOAD "TEST"[CR]

○ LOAD[CR]

　DOS FILE:TEST[CR]

○ LOAD[CR]

　DOS FILE:TEST.MZT[CR]

**Reference**

　When using S-OS SWORD, immediately after startup, set the device to "DV S:" and configure each device as a SYSTEM device.

　This might only be the case with FUZZY BASIC, but when using a common format device, I couldn't omit the IBF file name with the LOAD command.

Special commands during LOAD
　When "DOS FILE:" is displayed and the system is waiting for input, the following special commands can be used.

*FDL[CR]
*FDL x[CR]
　You can use file listing functionality that is exactly the same as FDL and FDL x, after waiting for the MONITOR command input.

　The search results are displayed with "DOS FILE:" appended to the beginning of each line, so you can load a file simply by moving the cursor to the file you want and pressing the [CR] key.

　Some applications revert to "DOS FILE:" when you search for "*FDL" and select it with the cursor to try and load it. However, you can load it by placing the cursor again and pressing [CR].

SAVE from application
　Just like with CMT, please enter the file name and other information according to the input method and rules specified by the application and save it.

　However, half-width katakana characters cannot be used because Arduino cannot recognize them. Please specify using letters, numbers, and spaces.

　When saving, the entered file name will be applied to both the IBF file name and the DOS file name.

　The ".MZT" extension is automatically added to the filename as a DOS file.

For example, in BASIC SP-5030...

○ SAVE "TEST"[CR]