#include <stdint.h>

/*
 * Confirmed return-only ROM entry at 0x08057B60 (Thumb BX LR).
 * Callers pass a message pointer, but the entry does not read or write it.
 */
void sub_08057B60(const void *message)
{
    (void)message;
}

/*
 * Confirmed return-only entry at 0x08057C5C. Its original sequence saves
 * r0-r3 in temporary stack space, restores the stack pointer, and returns
 * without reading arguments or producing caller-visible outputs.
 */
void sub_08057C5C(const void *message, ...)
{
    (void)message;
}
