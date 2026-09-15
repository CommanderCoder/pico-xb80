# Prototypes

1. Getting the state machines in a state where I am confident they work is first.
2. Then get the DMA to received addresses, chain this as the address in a buffer, to either prepare for a Z80 read or a Z80 write.  If Z80 write, then chain that to an event buffer 

## Testing state machines

1. Use LEDs to check data can be 'read' by a Z80 - activate data liines - READ

2. use READ signals to activate some LEDs, then WRITE to send those signals back into the Pico. Thus using it's own pins to drive.  NOTE: Loopback Behaviour: values latched for 'out' can be use for 'in' without losing the value.

2. use switches (or just GND some pins), to check SM0 is working.  Use a switch to trigger NMREQ.


## Test with Arduino (IMPLEMENTED)

### Hardware Setup
- Arduino Mega: A0-A7 (addresses), D14-D21 (data), pins 22/24/26/28 (MREQ/RD/WR/IORQ control)
- Pico connection: Receives signals via PIO state machines
- Verification: Pico dumps shadow memory (`_eb_memory`) to serial for comparison

### Test Phases (arduino_eb_test.ino)

**Phase 1: Infrastructure Test**
- Verify all pins (address, data, control) toggle correctly
- Serial communication at 115200 baud

**Phase 2: Sequential Read/Write Tests**
1. **Write test**: Send bytes to addresses 0x00-0x0F with data = address pattern
   - Pulse WR pin to signal write operation
   - Pico captures writes in shadow memory via PIO state machines
   
2. **Read test**: Request data from addresses 0x10-0x1F
   - Pulse MREQ (memory request) then RD (read)
   - Pico provides data on output pins (pattern: data = address XOR 0xFF)
   - Arduino can optionally read back values

**Phase 3: Pattern & Random Tests**
- Pattern suite: Test 4 patterns (0x00, 0xFF, 0xAA, 0x55) across 16 addresses each
- Random test: 32 random write/read cycles with random addresses and data
- Verify 100% match rate in shadow memory

**Phase 4: Control Signal Edge Cases**
- Back-to-back writes (verify no data loss)
- RD pulse without MREQ (should not capture address)
- Write-then-read same address (verify data latching)
- Address hold time after MREQ deassertion

**Phase 5: Verification & Reporting**
- Pico logs shadow memory every 5 seconds
- Per-phase summaries: addresses tested, operation counts, CRC16 checksums
- Full memory dumps for manual inspection
- Test counter tracking on both Arduino and Pico sides


## Testing DMA and chaining

1. set up the DMA to set data into a memory block (write from arduino)

2. use the DMA to respond with the right data (read from arduino)
