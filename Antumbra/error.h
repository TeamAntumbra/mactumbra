#ifndef AN_ERROR_H
#define AN_ERROR_H

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

#endif
