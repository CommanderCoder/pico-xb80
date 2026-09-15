# Z80 memory

eb_memory is 64K block of 16bit words (2 bytes).  The low byte is the data, high byte is permission bits.

Get a mem req (or io req) and address can be pushed to the FIFO.  Probably have a bit of a delay.  X register has the top 15 bits, allowing the bottom 17 bits to come from the 16 bits of the address and another bit (null).  

The 0 means this is the address of the data
A 1 is the next byte, and this is used for the permission byte.

the DMA will chain between channels to get the data for that address from the EB buffer, and also prep to receive data via a write from the Z80.

Set up for READ (by putting data on the pins), and put a 9th bit (read access flag) into y.  if RW pin is low, then 10th bit from FIFO will be write access flag. if both read access is false, then simply snoop. otherwise set all pins to out so the CPU can read the data.  11th bit will be true, if snoop allowed and this 




There are 4 pins,  MREQ going low will grab the address, and then DMA that back,
the DMA will trigger a second channel to read the data from memory and back to
FIFO.  This will trigger the eb2_access.  it will pull the FIFO data and
put the 8 bits to the output (to satisfy the READ).
If RD is low, it will simply switch the direction to output (all 1s)
ELSE IF WR is low, it will get data from the pins into OSR


NOTE: The original just used 8 pins, and a MUX - this mean the 8 pins would be reused
a lot and switched from in to 8.  same 8 pins and 3 side pins.

New version will use 8 pins for data the same
New version will use 16 pins for address which is different.
No mux.
Need to have two SMs - one to get the address, and one to get the WR/RD
bit and get/set the data.  Address SM run from GPIO2-17.  data DM from from 18-25
control signals in 26-29
Register content cannot be moved between state machines 
but X is only used for the address and not data.

# 3 State Machines

Need 3 state machines (read address, write data, read data).  The original had 2 as it used the R_NW jmp_pin to switch between them.



# 6502 memory

. two parts to the address get, it gets the HI and then the LOW.  high address and then low address but pushes the whole ISR after falling edge of 1MHZ pin and a bit of a delay.



The architecture has a shadow memory.  The pico is constantly monitoring the address and data bus and copying any writes into the shadow memory.  The pico can then query that shadow memory to draw things on the screen.

Shadow memory (_eb_memory) 

Functions include:
eb_set_perm_byte - to set the permissions for a memory address
eb_set_perm - to set perms on a block of bytes

eb_get - get a byte
eb_get32 - get a word

# PIO eb2_address
config - in_shift ; shift left, no autopush, 0 bits (actually 32 bits)

# PIO eb2_access
config - in_shift ; shift left, autopush, 8 bit threshold

. pull data from TX FIFO into OSR
. move 8 bits in OSR to pins
. move 1 bit in OSR to y
. if JMP PIN is HIGH (i.e. read) jump to read
. write:
. move 1 bit in OSR to y
. if y is 0, go back to start
. wait for 1  on GPIO 1MHZ
. wait for 0  on GPIO 1MHZ
. move 8 bits from pins into ISR
. jmp loop (does this PUSH?)
. read:
. if y is 0, go to snoop
. move all 1s into OSR
. move 8 bits from OSR into pindirs (1s means out, thus 8 pins the are outputs)
. jump to loop (does this PUSH)
. snoop:
. move 1 bit from OSR into y
. move 1 bit from OSR into y
. if y is 0 got back to start
. move 8 bits from ISR into nowhere
. wrap (and autopush)

# DMA

DMA config - sets write address, then read address

Uses 4 channels (read means z80 is reading, write is z80 writing)
1. address (from fifo to read) [32] (chain)
2. read data (from memory to fifo) [16] (chain)
3. address channel (from read to write) [32] (chain)
4. write data (from fifo to memory) [8] (chain)
5. eb_events (words) (ring buffer)


- The event handler is just recording a sequence of addresses that have been accessed.  Useful for debugging or by the SID.
EVENT HANDLER used by SID
DMA is writing data into the event buffer, and get_event reads from it.




    dma_channel_configure(
        address_chan,
        &c,
        &dma_channel_hw_addr(read_data_chan)->al3_read_addr_trig,
        &pio->rxf[eb2_address_sm],
        1,
        true);
    channel_config_set_chain_to(&c, address_chan2);

    dma_channel_configure(
        read_data_chan,
        &c,
        &pio->txf[eb2_access_sm],
        NULL, // read address set by DMA
        1,
        false);
    channel_config_set_chain_to(&c, address_chan);

    dma_channel_configure(
        address_chan2,
        &c,
        &dma_channel_hw_addr(write_data_chan)->al2_write_addr_trig,
        &dma_channel_hw_addr(read_data_chan)->read_addr,
        1,
        false);
    channel_config_set_chain_to(&c, eb_event_chan);
    dma_channel_configure(
        write_data_chan,
        &c,
        NULL, // write address set by DMA
        &pio->rxf[eb2_access_sm],
        1,
        false);

