I wanted to be able to load programs quickly onto my Sharp MZ80K.  Quicker than the super speedy in-built tape deck.

I hunted around and found this:
https://github.com/yanataka60/MZ80K_SD

After looking at the design I thought I might be able to use a different microprocessor
than an arduino.  An Arduino Mega maybe?  

I'd spoken with someone recently about bus sniffing with a Pico2B (RP2350B).  The 'B' model has 48 GPIO pins so that can connect to all 16 address lines, 8 data lines and 4 control lines on the MZ80K expansion bus.

So that's what I did.  I bought an Olimex Pico2-XXL https://github.com/OLIMEX/RP2350-PICO2-XXL/tree/main (it has the 48 GPIO's exposed) and it has an Micro-SD card slot.

After a couple of months of tinkering I got the Olimex to sniff read/writes on the bus so that it could intercept memory writes and reads.  This means it could respond to reads and writes between 0F000H and 0FFFFH. (I've made it possible to make individual address inactive, read-only, write-only and read-write)

The Olimex Pico2-XXL has two varients.  One with 1-bit MMC access and the other with 4-bit access.  Mine has 1 bit mmc which doesn't have that much example code.  CoPilot helped here, with some support from Claude.AI, and my own tinkering.

So now I have an SD card containing Z80 programs, SP-5025 Basic and Basic programs.  The Pico has a version of the ROM from Yanataka's site embedded into it and now I can use *FD to load binary programs, and a patched version of SP-5025 Basic to load Basic programs.

No other hardware is needed apart from ribbon cables and a USB power supply.

NOTE: The RP2350 nominally operates at 3.3v but the internet suggests it is 5v tolerant with some caveats. (A4 version of the chip is definitely tolerant but A2, which is the same as mine, requires 5V on IOVCC pin before drive the other pins.)

--

If you're interested in this, then get in touch.  I don't plan to release any code until I've tidied it up a lot.

I don't have an MZ700 so I cannot test it.



