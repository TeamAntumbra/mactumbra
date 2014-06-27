#ifndef ANTUMBRA_SERIAL_H
#define ANTUMBRA_SERIAL_H

#include <stddef.h>

/* To be called once outside the dedicated thread. This sets up the serial
   connection. Call before using any of the functions below. */
void ser_init();

bool ser_command(uint8_t cop, uint8_t *cdata, uint8_t clen,
                 uint8_t *rop, const uint8_t **rdata, uint8_t *rlen);

void ser_set_mode(uint8_t m);
void ser_set_color(uint8_t r, uint8_t g, uint8_t b);
void ser_set_brightness(uint8_t br);

#if 0
/* To be called as the dedicated thread body. Will not return. */
void ser_main_loop();

/* The following functions require the dedicated serial thread to be running. */

/* Send a raw command packet; returns immediately (if serial thread is not
   hung, which should not happen), and the response will be ignored.

   op: operation code

   data: byte buffer to send as data field of command packet

   len: length of data */
void ser_send_raw_packet_nonblocking(uint8_t op, const void *data, uint8_t len);

/* Send a raw command packet; return when a response is received. Return the
   response code. 0 is success, any other value is failure.

   First three parameters as in ser_send_raw_packet_nonblocking().

   rdata: returns pointer to statically allocated buffer containing response
   packet data (will be overwritten by subsequent calls; caller should copy if
   needed)

   rlen: returns length of response packet data */
uint8_t ser_send_raw_packet_sync(uint8_t op, const void *data, uint8_t len,
                                 const void **rdata, uint8_t *rlen);

#endif
#endif
