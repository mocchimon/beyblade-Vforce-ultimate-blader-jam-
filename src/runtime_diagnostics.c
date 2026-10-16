#include <stdint.h>

/* BEYP revision 0, Thumb at 0x08057B64: bx lr (0x4770).
 * The ROM vector stores 0x08057B65 (Thumb-state pointer). */
void sub_08057B64(void) {}

/* BEYP revision 0, Thumb at 0x08057C5C:
 * push {r0-r3}; add sp,#16; bx lr.
 * The register save/stack discard is semantically a no-op. The ROM
 * vector stores 0x08057C5D. No diagnostic output occurs here. */
void sub_08057C5C(const void *message, uint32_t argument) {
    (void)message;
    (void)argument;
}
