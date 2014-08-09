#ifndef AN_DEVICE_H
#define AN_DEVICE_H

/* Disconnected / no longer available. */
#define AnDeviceState_DEAD 0
/* Handle open, but no interface in use. */
#define AnDeviceState_IDLE 1
/* Open and interface in use. */
#define AnDeviceState_OPEN 2

#include "ctx.h"
#include "error.h"

typedef struct AnDevice AnDevice;

/* Populate context with all available Antumbra devices. Calling
   AnDevice_Populate on an already populated context does not AnDevice_Free any
   devices in the device list, but it makes them inaccessible via
   AnDevice_Get. Devices start in IDLE state. */
AnError AnDevice_Populate(AnCtx *ctx);

/* Return number of devices available to context. If AnDevice_Populate has not
   yet been called, this will be 0. */
int AnDevice_GetCount(AnCtx *ctx);

/* Get device by index; 0 <= i < AnDevice_GetCount(). If i is out of range,
   undefined behavior occurs. */
AnDevice *AnDevice_Get(AnCtx *ctx, int i);

/* Return USB info through pointers: vendor ID, product ID, null-terminated
   serial string. If a given out pointer is NULL, the corresponding value is not
   returned. Serial string lifetime is tied to AnDevice lifetime. */
void AnDevice_Info(AnDevice *dev, uint16_t *vid, uint16_t *pid,
                   const char **serial);

/* Get state of device (AnDeviceState_*). */
int AnDevice_State(AnDevice *dev);

/* Set USB configuration and claim interface. */
AnError AnDevice_Open(AnCtx *ctx, AnDevice *dev);

/* Release interface. */
AnError AnDevice_Close(AnCtx *ctx, AnDevice *dev);

/* Free device and associated resources. */
void AnDevice_Free(AnDevice *dev);

/* Synchronously transmit a bulk packet. */
AnError AnDevice_SendBulkPacket_S(AnCtx *ctx, AnDevice *dev, int sz,
                                  const void *data);

#endif
