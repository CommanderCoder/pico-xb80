# bugs

W and R from the arduino is not working; detected by pulling wires and touching to low.


# New Plan:

PIO0 and SM0 will read all pins between 28 and 47 incl. (20 pins)

28-31 are the control lines
32-47 are the address lines

It will RX these to the CORE and the CORE will decide to wait for read or write based on the WR/RD lines.

PIO0 SM1 will service a READ.  CORE will TX data to the SM which will IN values on the Data lines and it will wait for MREQ to deactivate.  It will need MREQ as jmp pin

PIO1 SM0 will service a WRITE.  The SM will OUT values to the Data lines and push it will wait for MREQ to deactivate, and the CORE will RX from the SM.  It will need MREQ as jmp pin  

====
# Alternative Plan: (BAD)

Servicing read is a problem.  The CORE sends data to the READ service even if the Z80 isn't going to read it. I will set up this PIO to read IN from MREQ. jmp pin is RD. Then when READ is serviced (i.e. FIFO is filled), it will be checking if RD is low, then present the data, then wait for RD to go high.  However, while waiting for RD to go low, if MREQ goes high, then it returns to waiting for FIFO to fill.



====

the CPU will wait for data to appear on the RX FIFO SM1 - this will be the address, so it will get it.

the CPU will use that address to get the data at that location, and present that to the READ SM - however READ may never use it.

the CPU will see if any data is on the RX FIFO SM2 - this will be the data to WRITE into memory.  It will use the address to change the memory.

The problem is that the READ will block waiting for the NRD signal to go low.  If the NMREQ goes high, then it was a WRITE and the SM can start waiting for a READ again.



====

Can't bloody fix the ability for Z80_TO_PICO_FLAG to be read and written at the same time by PICO and by Z80

This is the first memory location used by eb_get() and doing that read must block the ability to write.

* only writing to (HL) in z80
* only reading from FLAGS in C, and sleep(10)
ok-

* only reading from (HL) in z80
* only reading from FLAGS in C, and sleep(10)
ok-


LD      (HL), A
LD      A, (HL)

This struggles - say A = 0xff, write it to (HL) and read it from (HL), ... then

using FC... FE has top address

-- 
IMPORTANT: Got same error when not using eb_get()!
---


added __dmb and sleep_ms(1) to give the z80 time to write data