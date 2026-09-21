// Copyright (c) Andrew Hague (Commander Coder), 21 September 2026
//
// This code may not be reused, in whole or in part, without attribution
// to the author, Andrew Hague (Commander Coder).

/* Heavily based on ATOM-DVI EB methods */

#include "xb_if.h"
#include "pico/rand.h"

#include "hardware/sync.h"

// using 0xFFFA-0xFFFD in shadow memory as a communication area - Z80 writes commands and data here, and we can read it and respond accordingly

#define Z80_TO_PICO_DATA     0xFFFA
#define Z80_TO_PICO_FLAG     0xFFFB

#define PICO_TO_Z80_DATA     0xFFFC
#define PICO_TO_Z80_FLAG     0xFFFD


volatile uint16_t _Alignas(EB_BUFFER_LENGTH * 2) _eb_memory[EB_BUFFER_LENGTH] __attribute__((section(".uninitialized_dma_buffer")));

// we need two pios because NWR and NRD are on different pins.  Have a pio running the address program and read program.  Another pio responds to writes and handles events
static PIO eb2_dataread_pio = pio0;
static PIO eb2_datawrite_pio = pio1;

static uint eb2_dataread_sm = -1;
static uint eb2_dataread_sm_offset;

static uint eb2_datawrite_sm=-1;
static uint eb2_datawrite_sm_offset;


#define DATA_COUNT 8
#define ADDRESS_COUNT 16

// GPIO
static void eb_gpio_init()
{
    // Initialize all GPIO pins for the expansion bus
    // Data pins: 16-23
    // Control pins: 28-31 (NWR, NRD, NMREQ, NIOREQ)
    // Address pins: 32-47
    
    // Initialize pins for address/data/control: 16-47
    for (int i = PIN_D0; i < PIN_A0 + ADDRESS_COUNT; i++) {
        pio_gpio_init(eb2_dataread_pio, i);
    }

    // pio_gpio_init(eb2_datawrite_pio, PICO_DEFAULT_LED_PIN);

    // Pull-ups for address lines
    for (int pin = PIN_A0; pin < PIN_A0 + ADDRESS_COUNT; pin++) {
        gpio_pull_up(pin);
    }

    // Pull-ups for control lines
    gpio_pull_up(PIN_NWR);
    gpio_pull_up(PIN_NRD);
    gpio_pull_up(PIN_NMREQ);
    gpio_pull_up(PIN_NIOREQ);

    // Pull-ups for data lines
    for (int i = PIN_D0; i < PIN_D0 + DATA_COUNT; i++) {
        gpio_pull_up(i);
    }

}

// PIO
static void eb2_read_program_init()
{
    eb2_dataread_pio = pio0;
    PIO pio = eb2_dataread_pio;

    // NEEDED!!
    bool success = pio_set_gpio_base(pio, 16); // set the gpio base to 16 so we can use pins 16-47 for the address and data lines
    assert(success);

    // Add read program and claim an unused state machine
    eb2_dataread_sm_offset = pio_add_program(pio, &eb2_read_program);
    eb2_dataread_sm = pio_claim_unused_sm(pio, true);

    uint sm = eb2_dataread_sm;
    uint offset = eb2_dataread_sm_offset;

    // NOT NEEDED! - all set as input - outputs will be set later
    // pio_sm_set_consecutive_pindirs(pio, sm, PIN_D0, 32, false);


    pio_sm_config c = eb2_read_program_get_default_config(offset);
    sm_config_set_in_pins(&c, PIN_A0); // starting here
    sm_config_set_out_pins(&c, PIN_D0, DATA_COUNT);

    sm_config_set_in_shift(&c, false, false, 0);

    uint address = (uint)&_eb_memory >> 17;

     uint zadd = ((uint)&_eb_memory >> 1) & 0xffff;
        printf("read _eb_memory  = %08lx (%04lx)\n",
       _eb_memory,zadd);

    int status;
    status = pio_sm_init(pio, sm, offset, &c);
    hard_assert(status == PICO_OK);
    pio_sm_put(pio, sm, address);
    pio_sm_exec(pio, sm, pio_encode_pull(false, true) );
    pio_sm_exec(pio, sm, pio_encode_mov(pio_x, pio_osr));
    pio_sm_exec(pio, sm, pio_encode_nop() );

}

static void eb2_write_program_init()
{
    eb2_datawrite_pio = pio1;
    PIO pio = eb2_datawrite_pio;

    // NEEDED!!
    bool success = pio_set_gpio_base(pio, 16); // set the gpio base to 16 so we can use pins 16-47 for the address and data lines
    assert(success);

    // Add read program and claim an unused state machine
    eb2_datawrite_sm_offset = pio_add_program(pio, &eb2_write_program);
    assert(eb2_datawrite_sm_offset);
    eb2_datawrite_sm = pio_claim_unused_sm(pio, true);
    assert(eb2_datawrite_sm);

    uint sm = eb2_datawrite_sm;
    uint offset = eb2_datawrite_sm_offset;

    // Ensure data pins are configured as inputs for the write state machine
    // default for PIO is input
    // NOT NEEDD
    // pio_sm_set_consecutive_pindirs(pio, sm, PIN_D0, DATA_COUNT+8+ADDRESS_COUNT, false);
    
    //pio_sm_set_consecutive_pindirs(pio, sm, PICO_DEFAULT_LED_PIN, 1, true);

    pio_sm_config c = eb2_write_program_get_default_config(offset);
    sm_config_set_in_pins(&c, PIN_A0); // starting here (will wrap if ask for 32 bits)
    // no need to set out_pins as all data is coming in from Z80
    
    //sm_config_set_set_pins(&c, PICO_DEFAULT_LED_PIN, 1);

    sm_config_set_jmp_pin(&c, PIN_NWR);
    
    sm_config_set_in_shift(&c, false, false, 0);
    sm_config_set_out_shift(&c, true, false, 0); // out doesn't go to PINS, just used for data manipulation

    // float freq = 0.1f;
    // float div = (float)clock_get_hz(clk_sys) / (freq * 128.0f);
    // sm_config_set_clkdiv(&c, div);


    uint address = (uint)&_eb_memory >> 17;

     uint zadd = ((uint)&_eb_memory >> 1) & 0xffff;
        printf("write _eb_memory  = %08lx (%04lx)\n",
       _eb_memory,zadd);

    int status;
    status = pio_sm_init(pio, sm, offset, &c);
    hard_assert(status == PICO_OK);

    pio_sm_put(pio, sm, address);
    pio_sm_exec(pio, sm, pio_encode_pull(false, true) );
    pio_sm_exec(pio, sm, pio_encode_mov(pio_x, pio_osr));
    pio_sm_exec(pio, sm, pio_encode_nop() );

    // address base sent to write code so it can read/write to the correct area


}

// DMA
uint address_chan   ;
uint read_data_chan ;
uint write_data_chan;
uint write_read_data_chan;
uint save_addr_chan;

static void eb_setup_dma_read()
{
    uint address_chan = dma_claim_unused_channel(true); // READS THE ADDRESS
     read_data_chan = dma_claim_unused_channel(true); // WRITES THE DATA

    dma_channel_config c;


    //---


    // Configure DMA channel to transfer addresses from PIO FIFO to the read data channel
    // This channel moves each incoming address to trigger a subsequent memory read
    c = dma_channel_get_default_config(address_chan);

    // Give this channel high priority to ensure addresses are captured promptly
    channel_config_set_high_priority(&c, true);

    // Pace transfers using the PIO RX FIFO data request signal
    // (transfer occurs when the address state machine has data available)
    channel_config_set_dreq(&c, pio_get_dreq(eb2_dataread_pio, eb2_dataread_sm, false));

    // Transfer 32-bit words (one full address per transfer)
    channel_config_set_transfer_data_size(&c, DMA_SIZE_32);

    // Fixed source address: always read from the same FIFO location
    channel_config_set_read_increment(&c, false);

    // Fixed destination address: always write to the same control register
    channel_config_set_write_increment(&c, false);

    // Apply the configuration and start the channel
    dma_channel_configure(
        address_chan,                                              // Channel to configure
        &c,                                                        // Configuration struct
        &dma_channel_hw_addr(read_data_chan)->al3_read_addr_trig,  // Destination: read_data_chan's read-address register (alias 3 triggers the channel)
        &eb2_dataread_pio->rxf[eb2_dataread_sm],            // Source: PIO RX FIFO for the address state machine
        1,                                                         // Transfer count: 1 word per trigger
        true);                                                     // Start immediately

    //---

    // Configure the DMA channel that transfers data from EB2 memory to the PIO TX FIFO
    // This feeds the PIO state machine with the data it needs to drive the external bus read operation
    c = dma_channel_get_default_config(read_data_chan);

    // Elevate priority so this transfer is not delayed by lower-priority DMA activity
    channel_config_set_high_priority(&c, true);

    // DREQ pacing disabled — transfer runs at full DMA speed without waiting for PIO FIFO ready signal
    // Uncomment below to re-enable PIO-paced transfers (avoids overrunning the TX FIFO):
    // channel_config_set_dreq(&c, pio_get_dreq(eb2_address_dataread_pio, eb2_dataread_sm, true));

    // Transfer 16 bits per beat to match the EB2 bus data width
    channel_config_set_transfer_data_size(&c, DMA_SIZE_16);

    // Fixed read address — always reads from the same memory location (address updated externally or by chain)
    channel_config_set_read_increment(&c, false);

    // Fixed write address — always targets the same PIO TX FIFO register, not a buffer
    channel_config_set_write_increment(&c, false);

    // When this transfer completes, automatically trigger address_chan to set up the next read address
    channel_config_set_chain_to(&c, address_chan); 

    dma_channel_configure(
        read_data_chan,                 // DMA channel being configured
        &c,                            // Channel config built above
        &eb2_dataread_pio->txf[eb2_dataread_sm],    // Destination: TX FIFO of the EB2 data-read state machine
        NULL,                       // Source: let the chained DMA channel set the read address; supplied by address_chan
        1,                             // Transfer 1 x 16-bit word per trigger
        false                          // Do not start immediately — awaits explicit trigger or chain
    );

}

static void eb_setup_dma_write(void)
{
    /*
     * DMA cycle:
     *
     *   PIO PUSH address
     *          |
     *          v
     *   address_chan
     *          |
     *          +----> write_read_data_chan.READ_ADDR + TRIGGER
     *
     *   write_read_data_chan:
     *          RAM[address] ---> PIO TX FIFO
     *                 |
     *                 +--> chain to save_addr_chan
     *
     *   save_addr_chan:
     *          write_read_data_chan.READ_ADDR ---> write_data_chan.WRITE_ADDR
     *
     *   PIO:
     *          PULL BLOCK
     *          ...
     *          PUSH new value
     *
     *   write_data_chan:
     *          PIO RX FIFO ---> RAM[address]
     *                              |
     *                              +--> chain to address_chan
     *
     * Then the whole cycle repeats.
     */


    // -------------------------------------------------------------------------
    // Allocate DMA channels
    // -------------------------------------------------------------------------

     address_chan   = dma_claim_unused_channel(true);
     write_read_data_chan = dma_claim_unused_channel(true);
     save_addr_chan = dma_claim_unused_channel(true);
     write_data_chan = dma_claim_unused_channel(true);

    dma_channel_config c;


    // =========================================================================
    // 1. address_chan
    //
    // PIO RX FIFO contains the address.
    //
    // Copy:
    //
    //      PIO RX FIFO
    //           |
    //           v
    //      write_read_data_chan.AL3_READ_ADDR_TRIG
    //
    // Writing AL3_READ_ADDR_TRIG does TWO things:
    //
    //   1. loads write_read_data_chan.READ_ADDR
    //   2. triggers write_read_data_chan
    //
    // address_chan itself has no chain_to — once write_read_data_chan finishes
    // its transfer, IT chains to save_addr_chan (see section 2 below).
    // =========================================================================

    c = dma_channel_get_default_config(address_chan);

    channel_config_set_high_priority(&c, true);

    // Wait for a word in the PIO RX FIFO.
    channel_config_set_dreq(
        &c,
        pio_get_dreq(
            eb2_datawrite_pio,
            eb2_datawrite_sm,
            false       // RX
        )
    );

    channel_config_set_transfer_data_size(&c, DMA_SIZE_32);

    channel_config_set_read_increment(&c, false);
    channel_config_set_write_increment(&c, false);

    dma_channel_configure(
        address_chan,

        &c,

        // IMPORTANT:
        // This is NOT ordinary read_addr.
        //
        // Writing here loads write_read_data_chan.READ_ADDR
        // AND triggers write_read_data_chan.
        &dma_channel_hw_addr(write_read_data_chan)->al3_read_addr_trig,

        // Source = PIO RX FIFO containing the address
        &eb2_datawrite_pio->rxf[eb2_datawrite_sm],

        1,              // one address
        true            // enable channel; waits for PIO RX DREQ
    );

    // =========================================================================
    // 2. write_read_data_chan
    //
    // RAM[address] ---> PIO TX FIFO
    //
    // READ_ADDR is supplied dynamically by address_chan.
    //
    // The destination is the PIO TX FIFO.
    //
    // DMA_SIZE_16 is intentional here: the memory entry is 16 bits.
    //
    // A narrow 16-bit write to the PIO FIFO is replicated into the 32-bit
    // FIFO word on RP2040/RP2350, which is suitable for a subsequent PULL.
    // =========================================================================

    c = dma_channel_get_default_config(write_read_data_chan);

    channel_config_set_high_priority(&c, true);
 
    channel_config_set_transfer_data_size(&c, DMA_SIZE_16);

    channel_config_set_read_increment(&c, false);
    channel_config_set_write_increment(&c, false);

    channel_config_set_chain_to(&c, save_addr_chan);

    /*
     * Do NOT give this channel a DREQ.
     *
     * address_chan starts it by writing AL3_READ_ADDR_TRIG.
     *
     * If you want, the PIO TX DREQ could also be used, but it isn't
     * necessary for a single transfer because the PIO is sitting at:
     *
     *      pull block
     *
     * waiting for us.
     */

    dma_channel_configure(
        write_read_data_chan,

        &c,

        // Destination = PIO TX FIFO
        &eb2_datawrite_pio->txf[eb2_datawrite_sm],

        // READ_ADDR is supplied by address_chan.
        // This initial value is never used before address_chan runs.
        NULL,

        1,              // one 16-bit memory entry
        false           // started by address_chan
    );


    // =========================================================================
    // 3. save_addr_chan
    //
    // Preserve the address for the eventual WRITE.
    //
    // Source:
    //
    //      write_read_data_chan.READ_ADDR
    //
    // Destination:
    //
    //      write_data_chan.WRITE_ADDR
    //
    // This channel is started by write_read_data_chan's chain_to (not address_chan's —
    // address_chan only triggers write_read_data_chan directly, via AL3_READ_ADDR_TRIG).
    //
    // IMPORTANT:
    // write_data_chan is NOT triggered here.
    //
    // It merely gets its destination address prepared.
    //
    // The eventual PIO PUSH of the new value triggers write_data_chan
    // through its PIO RX DREQ.
    // =========================================================================

    c = dma_channel_get_default_config(save_addr_chan);

    channel_config_set_high_priority(&c, true);

    channel_config_set_transfer_data_size(&c, DMA_SIZE_32);

    channel_config_set_read_increment(&c, false);
    channel_config_set_write_increment(&c, false);

    channel_config_set_chain_to(&c, write_data_chan);

    dma_channel_configure(
        save_addr_chan,

        &c,

        // Destination = write DMA's WRITE_ADDR register
        &dma_channel_hw_addr(write_data_chan)->write_addr,

        // Source = read DMA's current READ_ADDR
        &dma_channel_hw_addr(write_read_data_chan)->read_addr,

        1,              // one 32-bit address
        false           // started by chain from write_read_data_chan
    );


    // =========================================================================
    // 4. write_data_chan
    //
    // PIO PUSH new value ---> RAM[address]
    //
    // The destination address was already installed by save_addr_chan.
    //
    // This DMA waits for the PIO RX FIFO DREQ.
    //
    // Once it completes, it chains back to address_chan.
    //
    // Therefore:
    //
    //      PIO PUSH new value
    //              |
    //              v
    //      write_data_chan
    //              |
    //              v
    //         RAM[address]
    //              |
    //              v
    //       chain address_chan
    //              |
    //              v
    //       wait for next PIO address
    // =========================================================================

    c = dma_channel_get_default_config(write_data_chan);

    channel_config_set_high_priority(&c, true);
    

          // Wait for a word rqeuested by the PIO RX FIFO.
    channel_config_set_dreq(
        &c,
        pio_get_dreq(
            eb2_datawrite_pio,
            eb2_datawrite_sm,
            false       // RX
        )
    );

    channel_config_set_transfer_data_size(&c, DMA_SIZE_16);

    channel_config_set_read_increment(&c, false);
    channel_config_set_write_increment(&c, false);

    
    // After writing the new value, wait for the next address.
    channel_config_set_chain_to(&c, address_chan);

    dma_channel_configure(
        write_data_chan,

        &c,

        // Destination address was installed by save_addr_chan.
        NULL,

        // Source = PIO RX FIFO containing the new value
        &eb2_datawrite_pio->rxf[eb2_datawrite_sm],

        1,              // one 16-bit value
        false           // started by PIO RX DREQ
    );
}


// MAILBOXES

void wait_z80_mailbox_empty()
{
    // Mirror of the Z80's COMMS_INIT (FD_rom.s): the Z80 clears Z80_TO_PICO_FLAG
    // and then waits for PICO_TO_Z80_FLAG to clear. Wait for its side to be
    // empty, then mark ours empty.
    _DEBUG("Waiting for empty recv mailbox from Z80...\n");

    // hold here while mailbox is not empty
    while (eb_get(Z80_TO_PICO_FLAG) != 0)
    {
        sleep_ms(1);
    }


    _DEBUG("Set empty snd mailbox to Z80...\n");
    // initialize data for the communication area
    eb_set(PICO_TO_Z80_DATA, 0);

    // mark mailbox empty
    eb_set(PICO_TO_Z80_FLAG, 0);
}


// XB_IF INITIALISE
void eb_init()
{
    // Initialize GPIO first
    eb_gpio_init();

    _DEBUG("Initializing Expansion Bus...\n");

    // Initialize PIO state machines: read, then write
    eb2_read_program_init();
    eb2_write_program_init();
    _DEBUG("Combined program initialized.\n");

    eb_setup_dma_read();
    eb_setup_dma_write();
    _DEBUG("DMA combined setup complete.\n");
    
 //   pio_enable_sm_mask_in_sync(eb2_dataread_pio, (1<< eb2_dataread_sm) );
    
    pio_sm_set_enabled(eb2_dataread_pio, eb2_dataread_sm, true);
    pio_sm_set_enabled(eb2_datawrite_pio, eb2_datawrite_sm, true);
}


// ============================================================================
// XB_IF STARTUP
// ============================================================================

void start_xb_interface()
{
    eb_set_perm(0x0000, EB_PERM_NONE, 0x10000);

    // the SD card interface - for now just a simple command/status register, but could be expanded to include a data buffer and more control registers if needed
    eb_set_perm(Z80_TO_PICO_DATA, EB_PERM_READ_WRITE, 2); // SD card interface
    eb_set_perm(Z80_TO_PICO_FLAG, EB_PERM_READ_WRITE, 2); // SD card interface
    
    eb_set_perm(PICO_TO_Z80_DATA, EB_PERM_READ_WRITE, 2); // SD card interface
    eb_set_perm(PICO_TO_Z80_FLAG, EB_PERM_READ_WRITE, 2); // SD card interface  
    
    // PIOs claimed automatically
    eb_init();
}





// TEMPORARY DIAGNOSTIC: fires every EB_STALL_THRESHOLD spins while a mailbox
// wait loop below is stalled, dumping the flag byte we're waiting on plus the
// write DMA chain's last-captured-address vs current-write-target (same pair
// the earlier "addr chain" diagnostic compared) to help catch a Z80 write
// (typically the PICO_TO_Z80_FLAG/Z80_TO_PICO_FLAG clear in RCVBYTE/SNDBYTE)
// that never landed. Does NOT change behavior — the caller keeps waiting.
// Only wired into sndbyte_z80 at present; the recbyte_z80 call is commented
// out. Remove once the FDL stall is root-caused.
#define EB_STALL_THRESHOLD 2000000u

static void eb_stall_report(const char *where, uint16_t flag_addr, uint16_t data_addr)
{
    uint32_t rd = dma_hw->ch[write_read_data_chan].read_addr;
    uint32_t wr = dma_hw->ch[write_data_chan].write_addr;
    uint16_t z_captured = (uint16_t)((rd >> 1) & 0xFFFF);
    uint16_t z_target   = (uint16_t)((wr >> 1) & 0xFFFF);

    printf("STALL in %s: flag@0x%04X=0x%02X data@0x%04X=0x%02X | "
           "write chain: last captured addr=0x%04X, current write target=0x%04X%s\n",
           where, flag_addr, eb_get(flag_addr), data_addr, eb_get(data_addr),
           z_captured, z_target,
           (z_captured != z_target) ? "  <-- MISMATCH" : "");
}

void sndbyte_z80(uint8_t odata)
{
    // DO NOT PUT DEBUG OR DELAYS IN HERE AS THE Z80 WILL LOOP A LOT AND THEN GET STUCK
    // hold here while mailbox is full
    uint32_t spins = 0;
    while (eb_get(PICO_TO_Z80_FLAG) != 0)
    {
        // Tight loop waiting for Z80 ACK
        if ((++spins % EB_STALL_THRESHOLD) == 0) {
            eb_stall_report("sndbyte_z80 (waiting for PICO_TO_Z80_FLAG==0)", PICO_TO_Z80_FLAG, PICO_TO_Z80_DATA);
        }
    }

    eb_set(PICO_TO_Z80_DATA, odata);
    /* Ensure DATA write is globally visible before publishing ODATA */
    __dmb();

    eb_set(PICO_TO_Z80_FLAG, 1);
    /* Ensure DATA write is globally visible before publishing FLAG */
    __dmb();
}


uint8_t recbyte_z80()
{
    // DO NOT PUT DEBUG OR DELAYS IN HERE AS THE Z80 WILL LOOP A LOT AND THEN GET STUCK

    uint32_t spins = 0;
    while (eb_get(Z80_TO_PICO_FLAG) == 0)
    {
        // wait for Z80 to publish a byte
        // sleep_ms(1);
        // __dmb();
        if ((++spins % EB_STALL_THRESHOLD) == 0) {
            // eb_stall_report("recbyte_z80 (waiting for Z80_TO_PICO_FLAG!=0)", Z80_TO_PICO_FLAG, Z80_TO_PICO_DATA);
        }
    }

    uint8_t idata = eb_get(Z80_TO_PICO_DATA);
    /* Ensure DATA has been read before acknowledging */
    __dmb();

    // set mailbox empty again
    eb_set(Z80_TO_PICO_FLAG, 0);
    __dmb(); // Ensure FLAG is published

    return idata;
}
 
void sndbyte(uint8_t response)
{
    sndbyte_z80(response); 
}

uint8_t recbyte()
{
    return recbyte_z80();
}


