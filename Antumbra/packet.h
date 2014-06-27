#ifndef PACKET_H
#define PACKET_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

typedef struct {
    uint8_t op;
    const uint8_t *data;
    size_t data_len;
    uint8_t csum;
} packet_packet;

// Load fields into packet from buffer; false if too short
bool packet_load(packet_packet *pkt, const uint8_t *buf, size_t size);
// Verify checksum; false if mismatch
bool packet_check(const packet_packet *pkt);
// Send packet using sendfn via packet_*()
void packet_send(const packet_packet *pkt, bool (*sendfn)(uint8_t));
// Assemble and send packet
void packet_respond(uint8_t status, const void *data, size_t data_len,
                    bool (*sendfn)(uint8_t));
uint8_t packet_checksum(const packet_packet *pkt);

void packet_main_loop(void (*process)(packet_packet *pkt));

#endif
