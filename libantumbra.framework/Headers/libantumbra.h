#ifndef AN_LIBANTUMBRA_H
#define AN_LIBANTUMBRA_H

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

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
/* Protocol command not supported. */
#define AnError_UNSUPPORTED 6
/* Protocol command failed (whatever that may mean). */
#define AnError_CMDFAILURE 7

/* Error value. Zero is success, nonzero is flaming death. */
typedef int AnError;

/* Get string message for error. */
An_DLL const char *AnError_String(AnError e);

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

typedef struct AnDeviceInfo AnDeviceInfo;

An_DLL void AnDeviceInfo_UsbInfo(AnDeviceInfo *info,
                                 uint8_t *bus, uint8_t *addr,
                                 uint16_t *vid, uint16_t *pid);

typedef struct AnDevice AnDevice;

An_DLL void AnDevice_Info(AnDevice *dev, AnDeviceInfo **info);

An_DLL AnError AnDevice_Open(AnCtx *ctx, AnDeviceInfo *info, AnDevice **devout);

An_DLL void AnDevice_Close(AnCtx *ctx, AnDevice *dev);

An_DLL AnError AnDevice_GetList(AnCtx *ctx, AnDeviceInfo ***outdevs,
                                size_t *outndevs);

An_DLL void AnDevice_FreeList(AnDeviceInfo **devs);

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
An_DLL void AnLog_Log(AnCtx *ctx, AnLogLevel lvl, const char *fmt, ...);

/* Set minimum level and output file for logging, or NULL to disable. */
An_DLL void AnLog_SetLogging(AnCtx *ctx, AnLogLevel lvl, FILE *f);

/* Return a sigil (DD/II/WW/EE) for a given error level, or ?? for unknown
   level. */
An_DLL const char *AnLogLevel_Sigil(AnLogLevel lvl);

/* Synchronously send packet of <=64 bytes on OUT endpoint. Actual sent packet
   is padded to 64 bytes and zero-filled. May time out.

   If `sz` is 0, a zero-filled packet is sent. `buf` may be NULL in this
   case. */
An_DLL AnError AnCmd_SendRaw_S(AnCtx *ctx, AnDevice *dev, const void *buf,
                               unsigned int sz);

/* Synchronously receive packet of <=64 bytes on IN endpoint. Actual received
   packet is 64 bytes, but only `sz` bytes are copied into buffer. May time
   out.

   If `sz` is 0, the packet is discarded. `buf` may be NULL in this case. */
An_DLL AnError AnCmd_RecvRaw_S(AnCtx *ctx, AnDevice *dev, void *buf,
                               unsigned int sz);

/* Synchronously send command and receive response. Given command data is <=56
   bytes and zero-padded to 56. Response data is 56 bytes but only `rspdata_sz`
   bytes are copied to `rspdata`. May time out.

   If `cmddata_sz` is 0, a zero-filled command payload is sent. `cmddata` may be
   NULL in this case.

   If `rspdata_sz` is 0, the response payload is discarded. `rspdata` may be
   NULL in this case. */
An_DLL AnError AnCmd_Invoke_S(AnCtx *ctx, AnDevice *dev,
                              uint32_t api, uint16_t cmd,
                              const void *cmddata, unsigned int cmddata_sz,
                              void *rspdata, unsigned int rspdata_sz);

#define AnCore_API 0x00000000

#define AnCore_CMD_ASK 0x0001
#define AnCore_CMD_RESET 0x0005

An_DLL AnError AnCore_Ask_S(AnCtx *ctx, AnDevice *dev,
                            uint32_t api, bool *supp);

An_DLL AnError AnCore_Reset_S(AnCtx *ctx, AnDevice *dev);

#define AnFlash_API 0x00000003

#define AnFlash_CMD_INFO 0x0000
#define AnFlash_CMD_BUFREAD 0x0001
#define AnFlash_CMD_BUFWRITE 0x0002
#define AnFlash_CMD_PAGEREAD 0x0003
#define AnFlash_CMD_PAGEWRITE 0x0004

typedef struct {
    uint16_t pagesize;
    uint32_t numpages;
} AnFlashInfo;

An_DLL AnError AnFlash_Info_S(AnCtx *ctx, AnDevice *dev, AnFlashInfo *info);

An_DLL AnError AnFlash_ReadPage_S(AnCtx *ctx, AnDevice *dev,
                                  AnFlashInfo *info,
                                  uint32_t pageidx, uint8_t *page);

An_DLL AnError AnFlash_WritePage_S(AnCtx *ctx, AnDevice *dev,
                                   AnFlashInfo *info,
                                   uint32_t pageidx, const uint8_t *page);

#define AnBoot_API 0x00000001

#define AnBoot_CMD_SET 0x0000

An_DLL AnError AnBoot_SetForceLoader_S(AnCtx *ctx, AnDevice *dev, bool ldrp);

#define AnEeprom_API 0x00000002

#define AnEeprom_CMD_INFO 0x0000
#define AnEeprom_CMD_READ 0x0001
#define AnEeprom_CMD_WRITE 0x0002

typedef struct {
    uint16_t size;
} AnEepromInfo;

An_DLL AnError AnEeprom_Info_S(AnCtx *ctx, AnDevice *dev, AnEepromInfo *info);

An_DLL AnError AnEeprom_Read_S(AnCtx *ctx, AnDevice *dev, AnEepromInfo *info,
                               uint16_t off, uint8_t len, uint8_t *out);

An_DLL AnError AnEeprom_Write_S(AnCtx *ctx, AnDevice *dev, AnEepromInfo *info,
                                uint16_t off, uint8_t len, const uint8_t *in);

#define AnLight_API 0x00000004

#define AnLight_CMD_GETENDPOINT 0x0000

typedef struct {
    uint8_t endpoint;
} AnLightInfo;

An_DLL AnError AnLight_Info_S(AnCtx *ctx, AnDevice *dev, AnLightInfo *info);

An_DLL AnError AnLight_Set_S(AnCtx *ctx, AnDevice *dev, AnLightInfo *info,
                             uint16_t r, uint16_t g, uint16_t b);

#endif
