#ifndef AN_ANTUMBRA_H
#define AN_ANTUMBRA_H

#include <stdio.h>
#include <stdint.h>

#ifdef ANTUMBRA_WINDOWS
#define An_DLL __cdecl __declspec(dllexport)
#else
#define An_DLL
#endif

/* All is peachy. */
#define AnError_SUCCESS 0
/* Device evaporated while our back was turned. */
#define AnError_DISCONNECTED 1
/* Couldn't allocate memory. */
#define AnError_MALLOCFAILED 2
/* libusb choked. */
#define AnError_LIBUSB 3
/* Device in inapplicable state for operation. */
#define AnError_WRONGSTATE 4
/* Index or size out of range. */
#define AnError_OUTOFRANGE 5

/* Error value. Zero is success, nonzero is flaming death. */
typedef int AnError;

/* Get string message for error. */
const char *AnError_String(AnError e);

typedef struct AnCtx AnCtx;

/* Create a new context and return its pointer via `ctx`. */
An_DLL AnError AnCtx_Init(AnCtx **ctx);

/* Free resources and destroy context. */
An_DLL void AnCtx_Deinit(AnCtx *ctx);

/* Disconnected / no longer available. */
#define AnDeviceState_DEAD 0
/* Handle open, but no interface in use. */
#define AnDeviceState_IDLE 1
/* Open and interface in use. */
#define AnDeviceState_OPEN 2

typedef struct AnDevice AnDevice;

/* Populate context with all available Antumbra devices. Calling
   AnDevice_Populate on an already populated context does not AnDevice_Free any
   devices in the device list, but it makes them inaccessible via
   AnDevice_Get. Devices start in IDLE state. */
An_DLL AnError AnDevice_Populate(AnCtx *ctx);

/* Return number of devices available to context. If AnDevice_Populate has not
   yet been called, this will be 0. */
An_DLL int AnDevice_GetCount(AnCtx *ctx);

/* Get device by index; 0 <= i < AnDevice_GetCount(). If i is out of range,
   undefined behavior occurs. */
An_DLL AnDevice *AnDevice_Get(AnCtx *ctx, int i);

/* Return USB info through pointers: vendor ID, product ID, null-terminated
   serial string. If a given out pointer is NULL, the corresponding value is not
   returned. Serial string lifetime is tied to AnDevice lifetime. */
An_DLL void AnDevice_Info(AnDevice *dev, uint16_t *vid, uint16_t *pid,
                          const char **serial);

/* Get state of device (AnDeviceState_*). */
An_DLL int AnDevice_State(AnDevice *dev);

/* Set USB configuration and claim interface. */
An_DLL AnError AnDevice_Open(AnCtx *ctx, AnDevice *dev);

/* Release interface. */
An_DLL AnError AnDevice_Close(AnCtx *ctx, AnDevice *dev);

/* Free device and associated resources. */
An_DLL void AnDevice_Free(AnDevice *dev);

/* Synchronously set RGB. */
An_DLL AnError AnDevice_SetRGB_S(AnCtx *ctx, AnDevice *dev,
                                 uint8_t r, uint8_t g, uint8_t b);

#define AnLog_NONE (-1)
#define AnLog_ERROR 0
#define AnLog_WARN 1
#define AnLog_INFO 2
#define AnLog_DEBUG 3

typedef int AnLogLevel;

/* Log message with file/line/func context. */
#define An_LOG(ctx, lvl, fmt, ...) AnLog_Log(       \
        (ctx), (lvl), ("[%s:%d:%s %s] " fmt "\n"), __FILE__, __LINE__,  \
        __func__, AnLogLevel_Sigil((lvl)), ##__VA_ARGS__)

/* Log message. */
void AnLog_Log(AnCtx *ctx, AnLogLevel lvl, const char *fmt, ...);

/* Set minimum level and output file for logging, or NULL to disable. */
void AnLog_SetLogging(AnCtx *ctx, AnLogLevel lvl, FILE *f);

/* Return a sigil (DD/II/WW/EE) for a given error level, or ?? for unknown
   level. */
const char *AnLogLevel_Sigil(AnLogLevel lvl);

#endif
