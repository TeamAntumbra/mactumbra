#include "frame.h"

#define FLAG_ESC 0x7d
#define FLAG_START 0x7e
#define FLAG_END 0x7f

// Waiting for frame start
#define STATE_IDLE 0
// Receiving frame data
#define STATE_INFRAME 1
// Waiting for escaped byte
#define STATE_ESC 2
// Frame done, must be dropped to receive another
#define STATE_DONE 3

static uint8_t state = STATE_IDLE;
static uint8_t framebuf[140];
static size_t frameind = 0;
bool (*send_function)(uint8_t b) = NULL;

void frame_pump(uint8_t b)
{
    if (state == STATE_IDLE) {
        if (b == FLAG_START) {
            state = STATE_INFRAME;
            frameind = 0;
        }
    }

    else if (state == STATE_INFRAME) {
        if (b == FLAG_START) {
            state = STATE_INFRAME;
            frameind = 0;
        }
        else if (b == FLAG_END)
            state = STATE_DONE;
        else if (b == FLAG_ESC)
            state = STATE_ESC;
        else if (frameind < sizeof framebuf)
            framebuf[frameind++] = b;
    }

    else if (state == STATE_ESC) {
        if (b == FLAG_START) {
            state = STATE_INFRAME;
            frameind = 0;
        }
        else if (b == FLAG_END)
            state = STATE_DONE;
        else {
            if (frameind < sizeof framebuf)
                framebuf[frameind++] = b ^ 0x20;
            state = STATE_INFRAME;
        }
    }
}

bool frame_avail(void)
{
    return state == STATE_DONE;
}

void frame_drop(void)
{
    state = STATE_IDLE;
    frameind = 0;
}

const uint8_t *frame_current(void)
{
    return framebuf;
}

size_t frame_size(void)
{
    return frameind;
}

static void sendraw(uint8_t b)
{
    while (!send_function(b));
}

void frame_begin(bool (*sendfn)(uint8_t))
{
    send_function = sendfn;
    sendraw(FLAG_START);
}

void frame_write(const void *buf, size_t count)
{
    size_t i;
    for (i = 0; i < count; ++i) {
        uint8_t b = ((uint8_t *)buf)[i];
        if (b == FLAG_START || b == FLAG_END || b == FLAG_ESC) {
            sendraw(FLAG_ESC);
            sendraw(b ^ 0x20);
        }
        else
            sendraw(b);
    }
}

void frame_end(void){
    sendraw(FLAG_END);
}
