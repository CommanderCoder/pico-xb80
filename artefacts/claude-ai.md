/*

GETBYTE / send_byte        SENDBYTE / recv_byte
                    ───────────────────        ────────────────────
Who writes DATA:    Peripheral                 Z80
When DATA written:  Before DATA_READY          Before CMD_READY
Who reads DATA:     Z80                        Peripheral
Z80 writes STATUS:  CMD_READY, ACK             CMD_READY, ACK
Periph writes STATUS: DATA_READY, IDLE         DATA_READY, IDLE



GET


Z80 (Master)                    STATUS          Peripheral (Slave)
────────────────────────────────────────────────────────────────────
Waits for IDLE             ←── 0x00 ───→  Waits doing nothing

Writes CMD to COMMAND
Sets STATUS = CMD_READY    ──→ 0x01 ───→  Detects CMD_READY
                                           Reads COMMAND
                                           Processes command
                                           Writes result to DATA
                           ←── 0x02 ───←  Sets STATUS = DATA_READY

Detects DATA_READY
Reads DATA
Sets STATUS = ACK          ──→ 0x03 ───→  Detects ACK
                                           Clears DATA register
                           ←── 0x00 ───←  Sets STATUS = IDLE

Both sides back to IDLE


SEND

Z80 (Master)                    STATUS          Peripheral (Slave)
────────────────────────────────────────────────────────────────────
Waits for IDLE             ←── 0x00 ───→  Waits doing nothing

Writes CMD to COMMAND
Writes byte to DATA
Sets STATUS = CMD_READY    ──→ 0x01 ───→  Detects CMD_READY
                                           Reads COMMAND
                                           Reads DATA
                           ←── 0x02 ───←  Sets STATUS = DATA_READY

Detects DATA_READY
Sets STATUS = ACK          ──→ 0x03 ───→  Detects ACK
                                           Clears DATA register
                           ←── 0x00 ───←  Sets STATUS = IDLE

Both sides back to IDLE




*/

=== Z80 ==


; Constants
IDLE        EQU 00H
CMD_READY   EQU 01H
DATA_READY  EQU 02H
ACK         EQU 03H

;------------------------------------------------
; GETBYTE - Request one byte from peripheral
; In:  A = command to send
; Out: A = received byte
;      Carry set on timeout/error
;------------------------------------------------
GETBYTE:
        PUSH BC

        ; --- Phase 1: wait for peripheral to be IDLE ---
        LD B, 0             ; timeout outer loop
WAIT_IDLE:
        LD A, (STATUS)
        CP IDLE
        JR Z, DO_CMD        ; good, peripheral is idle
        DJNZ WAIT_IDLE
        SCF                 ; timeout — set carry = error
        POP BC
        RET

        ; --- Phase 2: write command, signal CMD_READY ---
DO_CMD:
        LD A, (PENDING_CMD) ; load the command we want to send
        LD (COMMAND), A     ; write command
        LD A, CMD_READY
        LD (STATUS), A      ; signal peripheral

        ; --- Phase 3: wait for DATA_READY ---
        LD B, 0             ; timeout counter
WAIT_DATA:
        LD A, (STATUS)
        CP DATA_READY
        JR Z, DO_READ
        DJNZ WAIT_DATA
        SCF
        POP BC
        RET

        ; --- Phase 4: read data, send ACK ---
DO_READ:
        LD A, (DATA)        ; read before ACK to ensure data is stable
        PUSH AF             ; save received byte
        LD A, ACK
        LD (STATUS), A      ; acknowledge

        ; --- Phase 5: wait for peripheral to return to IDLE ---
        LD B, 0
WAIT_IDLE2:
        LD A, (STATUS)
        CP IDLE
        JR Z, DONE
        DJNZ WAIT_IDLE2
        POP AF
        SCF
        POP BC
        RET

DONE:
        POP AF              ; restore received byte into A
        POP BC
        OR A                ; clear carry = success
        RET


;------------------------------------------------
; SENDBYTE - Send one byte to peripheral
; In:  A = byte to send
;      (PENDING_CMD) = command to send
; Out: Carry set on timeout/error
;      Carry clear on success
;------------------------------------------------
SENDBYTE:
        PUSH BC
        PUSH AF             ; save byte to send

        ; --- Phase 1: wait for peripheral to be IDLE ---
        LD B, 0             ; 256 iteration timeout
SEND_WAIT_IDLE:
        LD A, (STATUS)
        CP IDLE
        JR Z, SEND_DO_CMD
        DJNZ SEND_WAIT_IDLE
        POP AF
        SCF                 ; timeout
        POP BC
        RET

        ; --- Phase 2: write command AND data, then signal CMD_READY ---
        ; Both must be written before status changes
SEND_DO_CMD:
        LD A, (PENDING_CMD)
        LD (COMMAND), A     ; write command first
        POP AF              ; restore byte to send
        LD (DATA), A        ; write data second
        LD A, CMD_READY
        LD (STATUS), A      ; signal peripheral last

        ; --- Phase 3: wait for peripheral to signal DATA_READY ---
        ; Peripheral sets this once it has safely read DATA
        LD B, 0
SEND_WAIT_ACK:
        LD A, (STATUS)
        CP DATA_READY
        JR Z, SEND_ACK
        DJNZ SEND_WAIT_ACK
        SCF                 ; timeout
        POP BC
        RET

        ; --- Phase 4: acknowledge, wait for IDLE ---
SEND_ACK:
        LD A, ACK
        LD (STATUS), A

        LD B, 0
SEND_WAIT_IDLE2:
        LD A, (STATUS)
        CP IDLE
        JR Z, SEND_DONE
        DJNZ SEND_WAIT_IDLE2
        SCF                 ; timeout
        POP BC
        RET

SEND_DONE:
        OR A                ; clear carry = success
        POP BC
        RET



=== C ===

#define IDLE        0x00
#define CMD_READY   0x01
#define DATA_READY  0x02
#define ACK         0x03

#define TIMEOUT_MS  500

typedef enum {
    BUS_OK = 0,
    BUS_TIMEOUT,
    BUS_UNEXPECTED_STATE,
} bus_result_t;

// Wait for STATUS to reach expected value within timeout
static bus_result_t wait_for_status(uint8_t expected, uint32_t timeout_ms) {
    uint32_t elapsed = 0;
    while (eb_get(SD_STATUS) != expected) {
        sleep_ms(1);
        if (++elapsed >= timeout_ms) {
            return BUS_TIMEOUT;
        }
    }
    return BUS_OK;
}

// Receive a command from Z80 and send back one byte response
bus_result_t send_byte(uint8_t response) {
    bus_result_t res;

    // --- Phase 1: assert IDLE so Z80 knows we are ready ---
    eb_set(SD_STATUS, IDLE);

    // --- Phase 2: wait for Z80 to issue CMD_READY ---
    res = wait_for_status(CMD_READY, TIMEOUT_MS);
    if (res != BUS_OK) {
        printf("[BUS] Timeout waiting for CMD_READY\n");
        return res;
    }

    // --- Phase 3: read command, prepare response, signal DATA_READY ---
    uint8_t cmd = eb_get(SD_CMD);
    printf("[RX CMD] 0x%02X\n", cmd);

    eb_set(SD_DATA, response);  // write data BEFORE setting status
    printf("[TX] 0x%02X [%c]\n", response,
           (response >= 32 && response <= 126) ? response : '.');
    eb_set(SD_STATUS, DATA_READY);  // now signal Z80

    // --- Phase 4: wait for Z80 to ACK ---
    res = wait_for_status(ACK, TIMEOUT_MS);
    if (res != BUS_OK) {
        printf("[BUS] Timeout waiting for ACK\n");
        return res;
    }

    // --- Phase 5: clean up and return to IDLE ---
    eb_set(SD_DATA, 0x00);      // clear data register
    eb_set(SD_STATUS, IDLE);    // release bus

    return BUS_OK;
}

//------------------------------------------------
// recv_byte - Receive one byte sent by the Z80
// Out: received byte via *out
//      returns BUS_OK on success
//------------------------------------------------
bus_result_t recv_byte(uint8_t *out) {
    bus_result_t res;

    // --- Phase 1: assert IDLE so Z80 knows we are ready ---
    eb_set(SD_STATUS, IDLE);

    // --- Phase 2: wait for Z80 to write command + data and signal CMD_READY ---
    res = wait_for_status(CMD_READY, TIMEOUT_MS);
    if (res != BUS_OK) {
        printf("[BUS] Timeout waiting for CMD_READY\n");
        return res;
    }

    // --- Phase 3: read command and data before touching STATUS ---
    // Both are guaranteed stable because Z80 wrote them before CMD_READY
    uint8_t cmd  = eb_get(SD_CMD);
    uint8_t data = eb_get(SD_DATA);

    printf("[RX CMD] 0x%02X  [RX DATA] 0x%02X [%c]\n",
           cmd, data,
           (data >= 32 && data <= 126) ? data : '.');

    // --- Phase 4: signal Z80 that we have safely read the data ---
    eb_set(SD_STATUS, DATA_READY);

    // --- Phase 5: wait for Z80 to ACK ---
    res = wait_for_status(ACK, TIMEOUT_MS);
    if (res != BUS_OK) {
        printf("[BUS] Timeout waiting for ACK\n");
        return res;
    }

    // --- Phase 6: clean up and return to IDLE ---
    eb_set(SD_DATA, 0x00);   // clear data register
    eb_set(SD_STATUS, IDLE); // release bus — Z80 can proceed

    *out = data;
    return BUS_OK;
}