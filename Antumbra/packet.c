#include "packet.h"

#include "frame.h"

uint8_t packet_checksum(const packet_packet *pkt)
{
    uint8_t csum = pkt->op;
    size_t i;
    for (i = 0; i < pkt->data_len; ++i)
        csum += pkt->data[i];
    return csum;
}

bool packet_load(packet_packet *pkt, const uint8_t *buf, size_t size)
{
    if (size < 2)
        return false;

    pkt->op = buf[0];
    pkt->data = buf + 1;
    pkt->data_len = size - 2;
    pkt->csum = buf[size - 1];
    return true;
}

bool packet_check(const packet_packet *pkt)
{
    return packet_checksum(pkt) == pkt->csum;
}

void packet_send(const packet_packet *pkt, bool (*sendfn)(uint8_t))
{
    frame_begin(sendfn);
    frame_write(&pkt->op, 1);
    frame_write(pkt->data, pkt->data_len);
    frame_write(&pkt->csum, 1);
    frame_end();
}

void packet_respond(uint8_t status, const void *data, size_t data_len,
                    bool (*sendfn)(uint8_t))
{
    packet_packet pkt;
    pkt.op = status;
    pkt.data = data;
    pkt.data_len = data_len;
    pkt.csum = packet_checksum(&pkt);
    packet_send(&pkt, sendfn);
}

void packet_main_loop(void (*process)(packet_packet *pkt))
{
    /*
    uint8_t b;
    if (acm_recv(&b))
        frame_pump(b);

    if (!frame_avail())
        return;

    packet_packet pkt;
    if (!packet_load(&pkt, frame_current(), frame_size())) {
       packet_respond(0x81, NULL, 0, acm_send);
        goto drop;
    }
    else if (!packet_check(&pkt)) {
       packet_respond(0x80, NULL, 0, acm_send);
        goto drop;
    }

    if (process)
        process(&pkt);
    else
       packet_respond(0x00, NULL, 0, acm_send);

    drop:
    frame_drop();
     */
}
