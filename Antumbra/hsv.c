#include "hsv.h"

#include <math.h>

#define RANGE(a, x, b) ((a) <= (x) && (x) < (b))

void hsv2rgb(float H, float S, float V, uint8_t *R, uint8_t *G, uint8_t *B)
{
    float Hp = fmodf(H, 360) / 60;
    float C = V * S;
    float X = 1 - fabsf(fmodf(Hp, 2) - 1);
    float R1, G1, B1;
    float m = V - C;
    if (RANGE(0, Hp, 1)) {
        R1 = C;
        G1 = X;
        B1 = 0;
    }
    else if (RANGE(1, Hp, 2)) {
        R1 = X;
        G1 = C;
        B1 = 0;
    }
    else if (RANGE(2, Hp, 3)) {
        R1 = 0;
        G1 = C;
        B1 = X;
    }
    else if (RANGE(3, Hp, 4)) {
        R1 = 0;
        G1 = X;
        B1 = C;
    }
    else if (RANGE(4, Hp, 5)) {
        R1 = X;
        G1 = 0;
        B1 = C;
    }
    else { //if (RANGE(5, Hp, 6)) {
        R1 = C;
        G1 = 0;
        B1 = X;
    }
    *R = 0xff * (R1 + m);
    *G = 0xff * (G1 + m);
    *B = 0xff * (B1 + m);
}
