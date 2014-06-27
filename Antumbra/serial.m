#include "frame.h"
#include "packet.h"

#include <dirent.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <poll.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pthread.h>

#include <Foundation/Foundation.h>

static int serfd = -1;

static pthread_mutex_t mutex;

bool ser_init()
{
    pthread_mutex_init(&mutex, NULL);

    DIR *dir = opendir("/dev");
    if (!dir) {
        NSLog(@"failed to open /dev: %s", strerror(errno));
        return false;
    }

    struct dirent dirf, *dirfp;
    while (!readdir_r(dir, &dirf, &dirfp) && dirfp) {
        NSLog(@"looked at %s", dirf.d_name);

        if (strstr(dirf.d_name, "cu.usbmodem") == dirf.d_name) {
            char fullpath[sizeof "/dev/" + sizeof dirf.d_name];
            sprintf(fullpath, "/dev/%s", dirf.d_name);
            serfd = open(fullpath, O_RDWR);
            if (serfd == -1) {
                NSLog(@"failed to open %s in /dev: %s", dirf.d_name,
                      strerror(errno));
                closedir(dir);
                return false;
            }

            const char cmd[] = "stty -f ";
            const char args[] = " raw 9600 -echo -echoe -echok -echoctl -echonl -echoke";
            char syscmd[sizeof cmd + sizeof fullpath + sizeof args];
            sprintf(syscmd, "%s%s%s", cmd, fullpath, args);
            system(syscmd);

            NSLog(@"opened %s in /dev", dirf.d_name);
            closedir(dir);
            return true;
        }
    }

    NSLog(@"could not find a serial device");
    return false;
}

static bool sendfn(uint8_t b)
{
    if (serfd == -1)
        return false;
    if (write(serfd, &b, 1) < 1)
        NSLog(@"write() on serial fd failed: %s", strerror(errno));
    return true;
}

bool ser_command(uint8_t cop, uint8_t *cdata, uint8_t clen,
                 uint8_t *rop, const uint8_t **rdata, uint8_t *rlen)
{
    pthread_mutex_lock(&mutex);

    packet_packet cpkt;
    cpkt.op = cop;
    cpkt.data = cdata;
    cpkt.data_len = clen;
    cpkt.csum = packet_checksum(&cpkt);

    packet_send(&cpkt, sendfn);

    while (1) {
        uint8_t b;
        if (read(serfd, &b, 1) < 1) {
            NSLog(@"read() on serial fd failed: %s", strerror(errno));
            goto fail;
        }
        frame_pump(b);

        if (frame_avail()) {
            packet_packet rpkt;
            packet_load(&rpkt, frame_current(), frame_size());
            if (!packet_check(&rpkt)) {
                NSLog(@"packet checksum failed");
                goto fail;
            }

            *rop = rpkt.op;
            *rdata = rpkt.data;
            *rlen = rpkt.data_len;
            goto succ;
        }
    }

 fail:
    pthread_mutex_unlock(&mutex);
    return false;
 succ:
    pthread_mutex_unlock(&mutex);
    return true;
}

void ser_set_mode(uint8_t m)
{
    uint8_t rop;
    const uint8_t *rdata;
    uint8_t rlen;
    ser_command(0x00, &m, 1,
                &rop, &rdata, &rlen);
}

void ser_set_color(uint8_t r, uint8_t g, uint8_t b)
{
    uint8_t cdata[3];
    cdata[0] = r;
    cdata[1] = g;
    cdata[2] = b;

    uint8_t rop;
    const uint8_t *rdata;
    uint8_t rlen;
    ser_command(0x02, cdata, sizeof cdata,
                &rop, &rdata, &rlen);
}

void ser_set_brightness(uint8_t br)
{
    uint8_t rop;
    const uint8_t *rdata;
    uint8_t rlen;
    ser_command(0x04, &br, 1,
                &rop, &rdata, &rlen);
}

#if 0
void ser_init()
{
    int socks[2];
    socketpair(AF_UNIX, SOCK_STREAM, 0, socks);
    thread_ipcsock = socks[0];
    extern_ipcsock = socks[1];
}

void ser_main_loop()
{
    struct pollfd pollfds[2];
    pollfds[0].fd = thread_ipcsock;
    pollfds[0].events = POLLIN;

    ser_init();
    ser_open();
    while (1) {
        if (serfd == -1) {
            if (!ser_open())
                goto restart;
        }

        pollfds[1].fd = serfd;
        pollfds[1].events = POLLIN;

        poll(pollfds, sizeof pollfds / sizeof *pollfds, -1);

        if (pollfds[0].revents & POLLIN) {
            uint8_t type, op, len, csum, data[255];
            if (read(thread_ipcsock, &type, 1) <= 1 ||
                read(thread_ipcsock, &op, 1) <= 1 ||
                read(thread_ipcsock, &len, 1) <= 1 ||
                read(thread_ipcsock, &csum, 1) <= 1) {
                NSLog(@"read() from thread_ipcsock failed: %s", strerror(errno));
                goto threadout;
            }

            int nr = 0;
            while (nr < len) {
                ssize_t st = read(thread_ipcsock, data + nr, len - nr);
                if (st <= 0) {
                    NSLog(@"read() packet data from thread_ipcsock failed: %s", strerror(errno));
                    goto threadout;
                }
                nr += st;
            }

            packet_packet pkt;
            pkt.op = op;
            pkt.data = data;
            pkt.data_len = len;
            pkt.csum = csum;

            packet_send(&pkt, sendfn);

            if (type == COM_SYNC) {
            }

        threadout:
        }

        if (pollfds[1].revents & POLLIN) {
            uint8_t buf[64];
            int nr = read(serfd, buf, sizeof buf);
            if (nr == -1) {
                NSLog(@"read() failed: %s", strerror(errno));
                goto restart;
            }

            int i;
            for (i = 0; i < sizeof buf; ++i)
                frame_pump(buf[i]);

            if (frame_avail()) {
                NSLog(@"got frame of length %d", (int)frame_size());

                packet_packet pkt;
                if (!packet_load(&pkt, frame_current(), frame_size())) {
                    NSLog(@"not a valid packet");
                    frame_drop();
                    continue;
                }

                if (!packet_check(&pkt)) {
                    NSLog(@"packet failed checksum");
                    frame_drop();
                    continue;
                }

                char hexbuf[2 * pkt.data_len + 1];
                int j;
                for (j = 0; j < pkt.data_len; ++j) {
                    snprintf(hexbuf + 2 * i, 3, "%02x", (int)pkt.data[j]);
                }
                NSLog(@"packet: code 0x%02x, data 0x%s", (int)pkt.op, hexbuf);

                frame_drop();
            }
        }

        continue;

    restart:
        serfd = -1;
        frame_drop();
        sleep(1);
    }
}

static void send_raw(uint8_t type, uint8_t op, const void *data, uint8_t len)
{
    packet_packet pkt;
    pkt.op = op;
    pkt.data = data;
    pkt.data_len = len;
    pkt.csum = packet_checksum(&pkt);

    size_t buflen = 4 + len;
    uint8_t buf[buflen];
    buf[0] = type;
    buf[1] = op;
    buf[2] = len;
    buf[3] = pkt.csum;
    memcpy(buf + 4, data, len);

    int nw = 0;
    while (nw < comlen) {
        ssize_t st = write(extern_ipcsock, buf + nw, comlen - nw);
        if (st <= 0) {
            NSLog("Something terrible happened!"
                  " write() to extern_ipcsock failed: %s", strerror(errno));
            return;
        }
        nw += st;
    }
}

void ser_send_raw_packet_nonblocking(uint8_t op, const void *data, uint8_t len)
{
    send_raw(COM_NONBLOCK, op, data, len);
}

static uint8_t static_com_data[255];

uint8_t ser_send_raw_packet_sync(uint8_t op, const void *data, uint8_t len,
                                 const void **rdata, uint8_t *rlen)
{
    send_raw(COM_SYNC, op, data, len);

    uint8_t type, rstat, rcsum;
    if (read(extern_ipcsock, &type, 1) <= 1 ||
        read(extern_ipsock, &rstat, 1) <= 1 ||
        read(extern_ipsock, rlen, 1) <= 1 ||
        read(extern_ipsock, &rcsum, 1) <= 1) {
        NSLog("Bollards! Failed to read from extern_ipcsock: %s", strerror(errno));
        return;
    }

    int nr = 0;
    while (nr < rlen) {
        ssize_t st = read(extern_ipcsock, static_com_data + nr, rlen - nr);
        if (st <= 0) {
            NSLog("read() of packet data from extern_ipcsock failed: %s",
                  strerror(errno));
            return;
        }
        nr += st;
    }

    *rdata = static_com_data;
    return rstat;
}

#endif
