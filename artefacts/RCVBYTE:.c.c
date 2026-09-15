RCVBYTE:


RCV_WAIT_CHECK_HI:
        LD      A, (CHECK)
        CP      PICO_SENDING
        JR      NZ, RCV_WAIT_CHECK_HI


        LD      A, (DATA)
		push AF


		LD A, 	RCV_ACK
        LD      (STATUS), A

RCV_WAIT_CHECK_LO:
        LD      A, (CHECK)
        CP      PICO_DONE
        JR      NZ, RCV_WAIT_CHECK_LO

; STUCK BECAuSE RCVR_IDLE not set

		LD A, RCVR_IDLE
        LD      (STATUS), A

		POP AF

        RET




void sndbyte_z80(uint8_t odata)
{
  
    eb_set(SD_DATA, odata);

    /* tell z80 that pico is ready to send */
    eb_set(SD_CHECK, PICO_SENDING);
 

    while (eb_get(SD_STATUS) != RCV_ACK)
    {
    }
    /* tell z80 pico is done with send */
    eb_set(SD_CHECK, PICO_DONE);

    // get stuck waiting for RCVR_IDLE
    while (eb_get(SD_STATUS) != RCVR_IDLE)
    {

    }

    // reset
    eb_set(SD_CHECK, CHECK_IDLE);  
}



SNDBYTE:

        LD      (DATA), A
		LD A, SNDR_READY
        LD      (STATUS), A

SND_WAIT_CHECK_HI:
        LD      A, (CHECK)
        CP      PICO_RECEIVED
        JR      NZ, SND_WAIT_CHECK_HI


		LD A, SNDR_ACK
        LD      (STATUS), A


SND_WAIT_CHECK_LO:
        LD      A, (CHECK)
        CP      PICO_IDLE
        JR      NZ, SND_WAIT_CHECK_LO
        RET




uint8_t recbyte_z80()
{
    /* wait for z80 to be ready to send */

    while (eb_get(SD_STATUS) != SNDR_READY)
    {
    }
    /* Read data */
    idata = eb_get(SD_DATA);

    /* tell z80 we've got the data */
    eb_set(SD_CHECK, PICO_RECEIVED);

    /* wait for z80 to ACK send done */
    while (eb_get(SD_STATUS) != SNDR_ACK)
    {
    }
    /* tell z80 pico is done receiving */
    eb_set(SD_CHECK, PICO_IDLE);
    return idata;
}
