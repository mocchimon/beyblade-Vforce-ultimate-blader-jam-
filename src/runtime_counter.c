#include <stdint.h>
#include <stddef.h>

/* Original Thumb at 0x08057B78: clear two words at IWRAM 0x03000EE0. */
void sub_08057B78(void) {
    volatile uint32_t *const counter = (volatile uint32_t *)(uintptr_t)0x03000EE0u;
    counter[1] = 0;
    counter[0] = 0;
}

/* Original Thumb at 0x08057B88: increment first word, modulo 2^32. */
void sub_08057B88(void) {
    volatile uint32_t *const counter = (volatile uint32_t *)(uintptr_t)0x03000EE0u;
    counter[0] = counter[0] + 1u;
}
