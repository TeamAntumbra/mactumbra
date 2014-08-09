#include <stdint.h>
#include "libusb.h"

struct AnDevice {
    uint16_t vid;
    uint16_t pid;
    char serial[33];

    unsigned int state;
    /* AnDevice holds one ref to libusb_device. When AnDevice_Free is called,
       the ref is dropped. If device becomes DEAD, dev and devh are set to NULL
       and ref is dropped. */
    libusb_device *dev;
    libusb_device_handle *devh;
};

#define An__ERRORDISCONNECT(ctx, dev, expr) AnDevice__ErrorDisconnect(   \
        (ctx), (dev), (expr), #expr)

/* Log message with logexpr if err is nonzero. If err is LIBUSB_ERROR_NO_DEVICE,
   set device state to DEAD and free libusb resources. Return either
   AnError_DISCONNECTED or AnError_LIBUSB as appropriate. */
int AnDevice__ErrorDisconnect(AnCtx *ctx, AnDevice *dev, int err, const char *logexpr);
