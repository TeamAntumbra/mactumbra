#ifndef AN_CTX_H
#define AN_CTX_H

#include "libusb.h"

#include "error.h"

typedef struct AnCtx AnCtx;

/* Create a new context and return its pointer via `ctx`. */
AnError AnCtx_Init(AnCtx **ctx);

/* Free resources and destroy context. */
void AnCtx_Deinit(AnCtx *ctx);

#endif
