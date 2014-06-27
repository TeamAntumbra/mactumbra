#ifndef FRAME_H
#define FRAME_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

// Pump received raw data
void frame_pump(uint8_t b);

// Test frame avail
bool frame_avail(void);
// Drop current frame
void frame_drop(void);
// Pointer to current frame, only valid if frame_avail()
const uint8_t *frame_current(void);
// Size of current frame, only valid if frame_avail()
size_t frame_size(void);

void frame_begin(bool (*sendfn)(uint8_t));
void frame_write(const void *buf, size_t count);
void frame_end(void);

#endif
