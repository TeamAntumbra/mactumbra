#include <stdio.h>
#include "libusb.h"

#include "device.h"

struct AnCtx {
    FILE *logf;
    libusb_context *uctx;

    int ndevs;
    AnDevice **devs;
};
