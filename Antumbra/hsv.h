#ifndef HSV_H
#define HSV_H

#include <stdint.h>

void hsv2rgb(float H, float S, float V, uint8_t *R, uint8_t *G, uint8_t *B);

#endif
