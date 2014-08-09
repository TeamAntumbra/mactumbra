#ifndef AN_LOG_H
#define AN_LOG_H

#include "ctx.h"

#include <stdarg.h>
#include <stdio.h>

/* Log message with file/line/func context. */
#define An_LOG(ctx, fmt, ...) AnLog_Log((ctx), ("[%s:%d:%s] " fmt "\n"), __FILE__, \
                                        __LINE__, __func__, ##__VA_ARGS__)

/* Log message. */
void AnLog_Log(AnCtx *ctx, const char *fmt, ...);

/* Set output file for logging, or NULL to disable. */
void AnLog_SetLogFile(AnCtx *ctx, FILE *f);

#endif
