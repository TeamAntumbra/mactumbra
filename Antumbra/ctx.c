#include "ctx.h"
#include "ctx_internal.h"

#include <stdlib.h>

AnError AnCtx_Init(AnCtx **ctx)
{
    AnCtx *newctx = malloc(sizeof *newctx);
    if (!newctx)
        return AnError_MALLOCFAILED;

    if (libusb_init(&newctx->uctx)) {
        free(newctx);
        return AnError_LIBUSB;
    }

    newctx->logf = stderr;
    newctx->ndevs = 0;
    newctx->devs = NULL;

    *ctx = newctx;
    return AnError_SUCCESS;
}

void AnCtx_Deinit(AnCtx *ctx)
{
    libusb_exit(ctx->uctx);
    free(ctx->devs);
    free(ctx);
}
