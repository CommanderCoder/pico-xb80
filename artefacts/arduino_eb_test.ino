/*
 * Arduino Mega ExpansionBus Test Harness
 * 
 * Hardware Configuration:
 * - Addresses (A0-A7): Arduino Mega analog pins A0-A7 (configured as outputs)
 * - Data (D14-D21): Arduino Mega digital pins 14-21 (configured as outputs)
 * - Control Lines:
 *   - Pin 22: MREQ (Memory Request)
 *   - Pin 24: RD (Read)
 *   - Pin 26: WR (Write)
 *   - Pin 28: IORQ (I/O Request)
 * 
 * Pico Connection:
 * - Pico GPIO pins receive these signals and capture via PIO state machines
 * - Pico serial output (115200 baud) logs shadow memory contents for verification
 */

// ============================================================================
// PIN DEFINITIONS
// ============================================================================

// Address pins: A0-A7 on Arduino Mega (analog pins, output)
#define PIN_ADDR_BASE     54
#define ADDR_PIN_COUNT    8

// Data pins: D14-D21 on Arduino Mega (digital pins, output)
#define PIN_DATA_BASE     14
#define DATA_PIN_COUNT    8

// Control pins (digital outputs)
#define PIN_IORQ          22
#define PIN_MREQ          24
#define PIN_RD            26
#define PIN_WR            28

// ============================================================================
// CONFIGURATION
// ============================================================================

#define SERIAL_BAUD       115200
#define TEST_PAUSE_MS     100    // Pause between tests to let Pico capture
#define PULSE_WIDTH_US    1    // Control signal pulse width in microseconds (should be 1us)

// ============================================================================
// TEST PARAMETERS
// ============================================================================

// Phase 2: Sequential write/read range
#define TEST_ADDR_START   0x00
#define TEST_ADDR_COUNT   0x14  // Test 16 addresses (0x00-0x0F)

// Phase 3: Number of random test cycles
#define RANDOM_TEST_COUNT 32

// ============================================================================
// GLOBAL STATE
// ============================================================================

struct {
  uint32_t tests_run;
  uint32_t tests_passed;
  uint32_t tests_failed;
  uint32_t last_test_addr;
  uint8_t  last_test_data;
} test_stats = {0, 0, 0, 0, 0};

// ============================================================================
// LOW-LEVEL SIGNAL DRIVERS
// ============================================================================

/**
 * Set address on A0-A7 pins
 * @param addr 8-bit address value
 */
void set_address(uint8_t addr) {
  for (int i = 0; i < ADDR_PIN_COUNT; i++) {
    digitalWrite(PIN_ADDR_BASE + i, (addr >> i) & 1);
  }
}

/**
 * Set data on D14-D21 pins
 * @param data 8-bit data value
 */
void set_data(uint8_t data) {
  for (int i = 0; i < DATA_PIN_COUNT; i++) {
    digitalWrite(PIN_DATA_BASE + i, (data >> i) & 1);
  }
}

/**
 * Read data from D14-D21 pins
 * @return 8-bit data value read from pins
 */
uint8_t read_data_pins() {
  uint8_t data = 0;
  for (int i = 0; i < DATA_PIN_COUNT; i++) {
    if (digitalRead(PIN_DATA_BASE + i) == HIGH) {
      data |= (1 << i);
    }
  }
  return data;
}

/**
 * Pulse a control signal (MREQ, RD, WR, IORQ)
 * Assumes active-low signals: pulls pin LOW for pulse_us, then releases HIGH
 * 
 * @param pin Control pin number (PIN_MREQ, PIN_RD, PIN_WR, or PIN_IORQ)
 * @param pulse_us Pulse width in microseconds
 */
void pulse_control(uint8_t pin, uint16_t pulse_us) {
  digitalWrite(pin, LOW);
  delayMicroseconds(pulse_us);
  digitalWrite(pin, HIGH);
}

/**
 * Sleep for specified milliseconds (wrapper around delay)
 * @param ms Milliseconds to sleep
 */
void sleep_cycles(uint16_t ms) {
  delay(ms);
}

// ============================================================================
// PHASE 1: INFRASTRUCTURE TEST
// ============================================================================

/**
 * Verify pin I/O is working correctly
 * Cycles through each address/data pin and toggles, reports to serial
 */
void test_phase1_infrastructure() {
  Serial.println("\n========== PHASE 1: INFRASTRUCTURE TEST ==========");
  Serial.println("Testing pin I/O setup...");
  
  // Test address pins
  Serial.print("Setting addresses 0x00-0xFF: ");
  for (int addr = 0; addr <= 255; addr += 16) {
    set_address(addr);
    Serial.print(addr, HEX);
    Serial.print(" ");
    delay(10);
  }
  Serial.println("✓");
  
  // Test data pins
  Serial.print("Setting data 0x00-0xFF: ");
  for (int data = 0; data <= 255; data += 16) {
    set_data(data);
    Serial.print(data, HEX);
    Serial.print(" ");
    delay(10);
  }
  Serial.println("✓");
  
  // Test control pins
  Serial.print("Testing control pulses: ");
  pulse_control(PIN_MREQ, PULSE_WIDTH_US);
  Serial.print("MREQ ");
  pulse_control(PIN_RD, PULSE_WIDTH_US);
  Serial.print("RD ");
  pulse_control(PIN_WR, PULSE_WIDTH_US);
  Serial.print("WR ");
  pulse_control(PIN_IORQ, PULSE_WIDTH_US);
  Serial.println("IORQ ✓");
  
  Serial.println("Phase 1 Infrastructure: READY\n");
}

// ============================================================================
// PHASE 2: SEQUENTIAL WRITE TEST
// ============================================================================

/**
 * Write test: Send bytes to addresses 0x00-0x0F with data = address pattern
 * Pico should capture these writes in shadow memory
 * Verification: Pico dumps shadow memory, we check if data matches addresses
 */
void test_phase2_sequential_write() {
  Serial.println("========== PHASE 2.1: SEQUENTIAL WRITE TEST ==========");
  Serial.print("Writing to addresses 0x");
  Serial.print(TEST_ADDR_START, HEX);
  Serial.print(" through 0x");
  Serial.print(TEST_ADDR_START + TEST_ADDR_COUNT - 1, HEX);
  Serial.println(" (pattern: data = address)");

  for (int i = 0; i < DATA_PIN_COUNT; i++) {
    pinMode(PIN_DATA_BASE + i, OUTPUT);
  }
  
  for (uint8_t addr = TEST_ADDR_START; addr < TEST_ADDR_START + TEST_ADDR_COUNT; addr++) {
    set_address(addr);
    uint8_t data = addr<<1;
    set_data(data);  // Write pattern: data = address<<2

    // Bring MREQ low when address is set
    digitalWrite(PIN_MREQ, LOW);
    
    delayMicroseconds(PULSE_WIDTH_US);

    digitalWrite(PIN_WR, LOW); // too slow to set PIN_WR after MREQ.  MREQ is used on pico to trigger it all off

    // delay 1us 
    delayMicroseconds(PULSE_WIDTH_US);
    
    // Bring MREQ high after data has been pulsed
    digitalWrite(PIN_WR, HIGH);
    digitalWrite(PIN_MREQ, HIGH);
    
    Serial.print("  [");
    Serial.print(test_stats.tests_run + 1, DEC);
    Serial.print("] WR: addr=0x");
    Serial.print(addr, HEX);
    Serial.print(" data=0x");
    Serial.println(data, HEX);
    
    test_stats.tests_run++;
    test_stats.last_test_addr = addr;
    test_stats.last_test_data = data;
    
    sleep_cycles(TEST_PAUSE_MS);
  }
  
  Serial.println("\n>>> WRITE phase complete. Pico should now dump shadow memory 0x00-0x0F");
  Serial.println(">>> Expected pattern: Each address should contain its own value\n");
  sleep_cycles(1000);  // Give Pico time to log and dump
}

// ============================================================================
// PHASE 2: SEQUENTIAL READ TEST
// ============================================================================

/**
 * Read test: Request data from addresses 0x10-0x1F via MREQ + RD pulses
 * Pico should have pre-populated shadow memory with pattern (data = address XOR 0xFF)
 * Arduino reads the data lines to verify correct values are driven
 */
void test_phase2_sequential_read() {
  uint32_t startaddr = TEST_ADDR_START + TEST_ADDR_COUNT;
  // read from different address or just the same address as just written
  startaddr = TEST_ADDR_START;
  
  Serial.println("========== PHASE 2.2: SEQUENTIAL READ TEST ==========");
  Serial.print("Reading from addresses 0x");
  Serial.print(startaddr, HEX);
  Serial.print(" through 0x");
  Serial.print(startaddr + TEST_ADDR_COUNT  - 1, HEX);
  Serial.println(" (pattern: data = address XOR 0xFF)");
  
  for (int i = 0; i < DATA_PIN_COUNT; i++) {
    pinMode(PIN_DATA_BASE + i, INPUT);
  }

  for (uint8_t addr = startaddr; 
       addr < startaddr + TEST_ADDR_COUNT; 
       addr++) {
    set_address(addr);
    
    // Bring MREQ low when address is set
    
    digitalWrite(PIN_RD, LOW);
    digitalWrite(PIN_MREQ, LOW);
    
    // The minimum read cycle is 3 T-states (no wait states), at 2 MHz that's 1500 ns — plenty of time for fast SRAM.
    // /MREQ and /RD go low in tandem but /RD is released slightly later, ensuring the data bus isn't confused with a write.
    // The data bus is high-impedance until the memory drives it — the Z80 never drives D0–D7 during a read.

    delayMicroseconds(PULSE_WIDTH_US);
    //delay(5);

    // read the data pins here
    uint8_t read_data = read_data_pins();
    
    // Bring MREQ high after data has been pulsed
    digitalWrite(PIN_MREQ, HIGH);
    delayMicroseconds(200); // wait 1.5ms before releasing RD
    digitalWrite(PIN_RD, HIGH);

    
    char char_repr = (read_data >= 32 && read_data <= 126) ? read_data : '.'; // printable ASCII or dot

    Serial.print("  [");
    Serial.print(test_stats.tests_run + 1, DEC);
    Serial.print("] RD: addr=0x");
    Serial.print(addr, HEX);
    Serial.print(" data=0x");
    Serial.print(read_data, HEX);
    Serial.print(" (char: ");
    Serial.print(char_repr);
    Serial.println(")");
    
    test_stats.tests_run++;
    test_stats.last_test_addr = addr;
    
    sleep_cycles(TEST_PAUSE_MS);
  }
  
  Serial.println("\n>>> READ phase complete. Pico should have driven data on output pins");
  Serial.println(">>> Expected pattern: Data = Address XOR 0xFF\n");
  sleep_cycles(1000);
}

// ============================================================================
// PHASE 3: PATTERN TEST SUITE
// ============================================================================

/**
 * Test a single pattern across TEST_ADDR_COUNT addresses
 * @param pattern Data pattern to write
 * @param pattern_name Description of the pattern (e.g., "0x00", "0xFF", "0xAA")
 */
void test_pattern(uint8_t pattern, const char* pattern_name) {
  Serial.print("Testing pattern ");
  Serial.print(pattern_name);
  Serial.print(" at addresses 0x");
  Serial.print(TEST_ADDR_START, HEX);
  Serial.print("-0x");
  Serial.print(TEST_ADDR_START + TEST_ADDR_COUNT - 1, HEX);
  Serial.println("...");
  
  for (uint8_t addr = TEST_ADDR_START; addr < TEST_ADDR_START + TEST_ADDR_COUNT; addr++) {
    set_address(addr);
    
    // Bring MREQ low when address is set
    digitalWrite(PIN_MREQ, LOW);
    
    set_data(pattern);
    pulse_control(PIN_WR, PULSE_WIDTH_US);
    
    // Bring MREQ high after data has been pulsed
    digitalWrite(PIN_MREQ, HIGH);
    
    Serial.print("  addr=0x");
    Serial.print(addr, HEX);
    Serial.print(" data=");
    Serial.println(pattern_name);
    
    test_stats.tests_run++;
    test_stats.last_test_data = pattern;
    sleep_cycles(TEST_PAUSE_MS);
  }
}

/**
 * Phase 3: Test 4 predefined patterns
 */
void test_phase3_patterns() {
  Serial.println("\n========== PHASE 3: PATTERN TEST SUITE ==========");
  
  test_pattern(0x00, "0x00 (zeros)");
  sleep_cycles(500);
  
  test_pattern(0xFF, "0xFF (ones)");
  sleep_cycles(500);
  
  test_pattern(0xAA, "0xAA (alternating 10)");
  sleep_cycles(500);
  
  test_pattern(0x55, "0x55 (alternating 01)");
  sleep_cycles(500);
  
  Serial.println("\n>>> PATTERN phase complete. Pico should show all 4 patterns in memory\n");
}

// ============================================================================
// PHASE 3: RANDOM ADDRESS TEST
// ============================================================================

/**
 * Phase 3: Random address and data write/read test
 * Generates random addresses and data, writes them, then reads back
 */
void test_phase3_random() {
  Serial.println("========== PHASE 3.2: RANDOM ADDRESS TEST ==========");
  Serial.print("Running ");
  Serial.print(RANDOM_TEST_COUNT, DEC);
  Serial.println(" random write/read cycles...");
  
  for (int i = 0; i < RANDOM_TEST_COUNT; i++) {
    uint8_t addr = random(0, 256);  // Random address 0-255
    uint8_t data = random(0, 256);  // Random data 0-255
    
    // Write
    set_address(addr);
    digitalWrite(PIN_MREQ, LOW);
    set_data(data);
    pulse_control(PIN_WR, PULSE_WIDTH_US);
    digitalWrite(PIN_MREQ, HIGH);
    
    sleep_cycles(TEST_PAUSE_MS / 2);
    
    // Read back
    set_address(addr);
    digitalWrite(PIN_MREQ, LOW);
    pulse_control(PIN_RD, PULSE_WIDTH_US);
    digitalWrite(PIN_MREQ, HIGH);
    
    Serial.print("  [");
    Serial.print(i + 1, DEC);
    Serial.print("] addr=0x");
    Serial.print(addr, HEX);
    Serial.print(" write=0x");
    Serial.print(data, HEX);
    Serial.println(" (awaiting read response)");
    
    test_stats.tests_run += 2;  // One write + one read
    sleep_cycles(TEST_PAUSE_MS);
  }
  
  Serial.println("\n>>> RANDOM phase complete. Pico should show random pattern in memory\n");
}

// ============================================================================
// PHASE 4: CONTROL SIGNAL EDGE CASES
// ============================================================================

/**
 * Test: Back-to-back writes without delay
 */
void test_phase4_backtoback_write() {
  Serial.println("========== PHASE 4.1: BACK-TO-BACK WRITE TEST ==========");
  Serial.println("Writing to sequential addresses without inter-operation delay...");
  
  for (uint8_t i = 0; i < 8; i++) {
    uint8_t addr = 0x40 + i;
    uint8_t data = addr;
    
    set_address(addr);
    digitalWrite(PIN_MREQ, LOW);
    set_data(data);
    pulse_control(PIN_WR, PULSE_WIDTH_US);
    digitalWrite(PIN_MREQ, HIGH);
    
    Serial.print("  addr=0x");
    Serial.print(addr, HEX);
    Serial.print(" data=0x");
    Serial.println(data, HEX);
    
    test_stats.tests_run++;
    // No sleep between operations
  }
  
  Serial.println(">>> Back-to-back write complete. Verify no data loss.\n");
  sleep_cycles(1000);
}

/**
 * Test: RD pulse without MREQ (should have no effect)
 */
void test_phase4_rd_without_mreq() {
  Serial.println("========== PHASE 4.2: RD WITHOUT MREQ TEST ==========");
  Serial.println("Pulsing RD alone (without MREQ) - should not capture address...");
  
  set_address(0xFF);
  pulse_control(PIN_RD, PULSE_WIDTH_US);
  
  Serial.println("  RD pulse sent without MREQ");
  test_stats.tests_run++;
  
  sleep_cycles(TEST_PAUSE_MS);
  Serial.println(">>> RD-only pulse complete. Address should NOT be captured.\n");
}

/**
 * Test: Write then immediately read same address
 */
void test_phase4_write_read_same() {
  Serial.println("========== PHASE 4.3: WRITE-THEN-READ SAME ADDRESS TEST ==========");
  Serial.println("Write 0xAA to 0x50, then immediately read back...");
  
  // Write
  set_address(0x50);
  digitalWrite(PIN_MREQ, LOW);
  set_data(0xAA);
  pulse_control(PIN_WR, PULSE_WIDTH_US);
  digitalWrite(PIN_MREQ, HIGH);
  
  Serial.println("  Wrote 0xAA to 0x50");
  test_stats.tests_run++;
  
  sleep_cycles(TEST_PAUSE_MS);
  
  // Read (without clearing address/data lines)
  digitalWrite(PIN_MREQ, LOW);
  pulse_control(PIN_RD, PULSE_WIDTH_US);
  digitalWrite(PIN_MREQ, HIGH);
  
  Serial.println("  Read from 0x50 (expecting 0xAA)");
  test_stats.tests_run++;
  
  Serial.println(">>> Write-read test complete. Verify read returned written data.\n");
  sleep_cycles(TEST_PAUSE_MS);
}

// ============================================================================
// TEST SUMMARY & REPORTING
// ============================================================================

/**
 * Print test statistics and summary
 */
void print_test_summary() {
  Serial.println("\n========== TEST SUMMARY ==========");
  Serial.print("Total operations run: ");
  Serial.println(test_stats.tests_run, DEC);
  Serial.print("Last address tested: 0x");
  Serial.println(test_stats.last_test_addr, HEX);
  Serial.print("Last data value: 0x");
  Serial.println(test_stats.last_test_data, HEX);
  Serial.println("\nCheck Pico serial output for shadow memory verification.");
  Serial.println("=================================\n");
}

// ============================================================================
// INITIALIZATION & MAIN LOOP
// ============================================================================

void setup() {
  // Initialize serial communication
  Serial.begin(SERIAL_BAUD);
  delay(100);  // Wait for serial to stabilize
  
  Serial.println("\n\n");
  Serial.println("╔════════════════════════════════════════════════════╗");
  Serial.println("║   Arduino Mega ExpansionBus Test Harness v1.0      ║");
  Serial.println("╚════════════════════════════════════════════════════╝");
  Serial.println();
  
  // Configure address pins as outputs
  Serial.print("Configuring address pins (A0-A7)...");
  for (int i = 0; i < ADDR_PIN_COUNT; i++) {
    pinMode(PIN_ADDR_BASE + i, OUTPUT);
    digitalWrite(PIN_ADDR_BASE + i, LOW);
  }
  Serial.println(" ✓");
  
  // Configure data pins as outputs
  Serial.print("Configuring data pins (D14-D21)...");
  for (int i = 0; i < DATA_PIN_COUNT; i++) {
    pinMode(PIN_DATA_BASE + i, INPUT);
    digitalWrite(PIN_DATA_BASE + i, LOW);
  }
  Serial.println(" ✓");
  
  // Configure control pins as outputs (active-low, so init HIGH)
  Serial.print("Configuring control pins (22, 24, 26, 28)...");
  pinMode(PIN_MREQ, OUTPUT);
  pinMode(PIN_RD, OUTPUT);
  pinMode(PIN_WR, OUTPUT);
  pinMode(PIN_IORQ, OUTPUT);
  digitalWrite(PIN_MREQ, HIGH);
  digitalWrite(PIN_RD, HIGH);
  digitalWrite(PIN_WR, HIGH);
  digitalWrite(PIN_IORQ, HIGH);
  Serial.println(" ✓");
  
  Serial.println("\nInitialization complete. Starting test sequence...\n");
  delay(500);
}

void loop() {
  // Run test phases sequentially

  test_phase2_sequential_write();
  delay(50);

  test_phase2_sequential_read();
  delay(50);

//----

//   test_phase1_infrastructure();
//   delay(500);
  
//   test_phase2_sequential_write();
//   delay(500);
  
//   test_phase2_sequential_read();
//   delay(500);
  
//   test_phase3_patterns();
//   delay(500);
  
//   test_phase3_random();
//   delay(500);
  
//   test_phase4_backtoback_write();
//   delay(500);
  
//   test_phase4_rd_without_mreq();
//   delay(500);
  
//   test_phase4_write_read_same();
//   delay(500);
  
//   // Print summary and loop
//   print_test_summary();
  
  Serial.println("====================================");
  Serial.println("Waiting 5 seconds before next cycle...");
  Serial.println("====================================\n");
  delay(5000);
}
