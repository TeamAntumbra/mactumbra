#include "log.h"
#include "ctx_internal.h"

void AnLog_Log(AnCtx *ctx, const char *fmt, ...)
{
    if (!ctx->logf)
        return;
    va_list ap;
    va_start(ap, fmt);
    vfprintf(ctx->logf, fmt, ap);
    va_end(ap);
}

void AnLog_SetLogFile(AnCtx *ctx, FILE *f)
{
    ctx->logf = f;
}
