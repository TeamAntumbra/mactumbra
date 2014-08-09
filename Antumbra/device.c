#include "device.h"
#include "device_internal.h"
#include "ctx_internal.h"
#include "log.h"

#include <stdlib.h>
#include <string.h>

AnError AnDevice_Populate(AnCtx *ctx)
{
    libusb_device **udevs;
    ssize_t ndevs = libusb_get_device_list(ctx->uctx, &udevs);
    if (ndevs < 0) {
        An_LOG(ctx, "libusb_get_device_list: %s", libusb_strerror(ndevs));
        return AnError_LIBUSB;
    }

    free(ctx->devs);
    ctx->devs = malloc(ndevs * sizeof *ctx->devs);
    if (!ctx->devs) {
        An_LOG(ctx, "malloc ctx->devs failed");
        libusb_free_device_list(udevs, 1);
        return AnError_MALLOCFAILED;
    }
    for (int i = 0; i < ndevs; ++i)
        ctx->devs[i] = NULL;

    int devidx = 0;
    for (int i = 0; i < ndevs; ++i) {
        int err;
        struct libusb_device_descriptor devdes;

        err = libusb_get_device_descriptor(udevs[i], &devdes);
        if (err) {
            An_LOG(ctx, "libusb_get_device_descriptor: %s", libusb_strerror(err));
            continue;
        }

        An_LOG(ctx, "enumerate device: vid 0x%04x pid 0x%04x", devdes.idVendor,
               devdes.idProduct);
        if (!(devdes.idVendor == 0x03eb && devdes.idProduct == 0x2040)) {
            An_LOG(ctx, " (unknown vid/pid; ignore)");
            continue;
        }

        struct libusb_device_handle *devhnd;
        err = libusb_open(udevs[i], &devhnd);
        if (err) {
            An_LOG(ctx, " libusb_open: %s", libusb_strerror(err));
            continue;
        }

        char serial[sizeof ctx->devs[0]->serial];
        int nchr;
        nchr = libusb_get_string_descriptor_ascii(
            devhnd, devdes.iSerialNumber, (unsigned char *)serial, sizeof serial
        );
        serial[sizeof serial - 1] = 0;
        if (nchr < 0) {
            An_LOG(ctx, " libusb_get_string_descriptor_ascii: %s",
                   libusb_strerror(nchr));
            libusb_close(devhnd);
            continue;
        }
        An_LOG(ctx, " serial %.*s", nchr, serial);

        AnDevice *dev = malloc(sizeof *dev);
        if (!dev) {
            An_LOG(ctx, " malloc AnDevice failed");
            libusb_close(devhnd);
            continue;
        }

        dev->vid = devdes.idVendor;
        dev->pid = devdes.idProduct;
        memcpy(dev->serial, serial, sizeof dev->serial);
        dev->state = AnDeviceState_IDLE;
        dev->dev = udevs[i];
        dev->devh = devhnd;

        ctx->devs[devidx++] = dev;
    }
    ctx->ndevs = devidx;

    libusb_free_device_list(udevs, 1);
    return AnError_SUCCESS;
}

int AnDevice_GetCount(AnCtx *ctx)
{
    return ctx->ndevs;
}

AnDevice *AnDevice_Get(AnCtx *ctx, int i)
{
    if (0 <= i && i < ctx->ndevs)
        return ctx->devs[i];

    An_LOG(ctx, "index out of range");
    return NULL;
}

void AnDevice_Info(AnDevice *dev, uint16_t *vid, uint16_t *pid,
                   const char **serial)
{
    if (vid) *vid = dev->vid;
    if (pid) *pid = dev->pid;
    if (serial) *serial = dev->serial;
}

int AnDevice_State(AnDevice *dev)
{
    return dev->state;
}

AnError AnDevice_Open(AnCtx *ctx, AnDevice *dev)
{
    if (dev->state != AnDeviceState_IDLE) {
        An_LOG(ctx, "cannot open AnDevice: not in state IDLE");
        return AnError_WRONGSTATE;
    }

    An_LOG(ctx, "open device: vid 0x%04x pid 0x%04x serial %s",
           dev->vid, dev->pid, dev->serial);

    struct libusb_device_descriptor devdes;
    int err = An__ERRORDISCONNECT(ctx, dev,
                                 libusb_get_device_descriptor(dev->dev, &devdes));
    if (err)
        return err;

    if (devdes.bNumConfigurations < 1) {
        An_LOG(ctx, " device reports no available configuration");
        return AnError_LIBUSB;
    }

    An_LOG(ctx, " set configuration 1");
    err = An__ERRORDISCONNECT(ctx, dev, libusb_set_configuration(dev->devh, 1));
    if (err)
        return err;

    err = An__ERRORDISCONNECT(ctx, dev, libusb_claim_interface(dev->devh, 0));
    if (err)
        return err;

    dev->state = AnDeviceState_OPEN;
    return AnError_SUCCESS;
}

void AnDevice_Free(AnDevice *dev)
{
    if (dev->devh)
        libusb_close(dev->devh);
    free(dev);
}

AnError AnDevice_Close(AnCtx *ctx, AnDevice *dev)
{
    An_LOG(ctx, "close device: vid 0x%04x pid 0x%04x serial %s", dev->vid,
           dev->pid, dev->serial);
    if (dev->state != AnDeviceState_OPEN) {
        An_LOG(ctx, "cannot close AnDevice: not in state OPEN");
        return AnError_WRONGSTATE;
    }

    return An__ERRORDISCONNECT(ctx, dev, libusb_release_interface(dev->devh, 0));
}

int AnDevice__ErrorDisconnect(AnCtx *ctx, AnDevice *dev, int err, const char *logexpr)
{
    if (err >= 0)
        return AnError_SUCCESS;

    An_LOG(ctx, "%s: %s", logexpr, libusb_strerror(err));

    if (err == LIBUSB_ERROR_NO_DEVICE) {
        An_LOG(ctx, " set device to state DEAD");
        if (dev->devh)
            libusb_close(dev->devh);
        dev->state = AnDeviceState_DEAD;
        dev->dev = NULL;
        dev->devh = NULL;
        return AnError_DISCONNECTED;
    }

    return AnError_LIBUSB;
}

AnError AnDevice_SendBulkPacket_S(AnCtx *ctx, AnDevice *dev, int sz,
                                  const void *data)
{
    if (dev->state != AnDeviceState_OPEN)
    if (sz > 16) {
        An_LOG(ctx, "too many bytes for bulk packet (max 16): %d", sz);
        return AnError_OUTOFRANGE;
    }

    int xout;
    int err = An__ERRORDISCONNECT(
        ctx, dev, libusb_bulk_transfer(dev->devh, 0x01, (unsigned char *)data,
                                       sz, &xout, 1000)
    );
    if (err)
        return err;

    return AnError_SUCCESS;
}
