    DEVICE NONE
    OUTPUT "FD_rom.bin"

    ; Load the first binary at the start
    INCBIN "FD_rom1.bin"

; --- Part 2: Explicit Padding ---
    ; We calculate the remaining space needed to reach 0x1000.
    ; '$' represents the current physical location in the file.
    ASSERT $ <= 0x1000, "Error: bin1.bin is already larger than 0x1000!"


  ; Don't worry about the ROM2. It is outside the address space at $10000  
;    BLOCK 0x1000 - $, 0x00
    
    ; Load the second binary at this offset
 ;   INCBIN "FD_rom2.bin"

    OUTEND