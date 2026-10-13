#include <stddef.h>
#include <stdint.h>

/* Field offsets used by the entry service at 0x080627CC. */
typedef struct RuntimeEntryServiceView {
    uint32_t source;          /* +0x00: resource record */
    uint32_t cursor;          /* +0x04: current source position */
    uint32_t source_length_b; /* +0x08: secondary resource boundary/length */
    uint8_t  reserved0[0x0A];
    uint8_t  status;          /* +0x16 */
    uint8_t  reserved1[0x11];
} RuntimeEntryServiceView;

_Static_assert(offsetof(RuntimeEntryServiceView, status) == 0x16,
               "runtime entry status offset mismatch");
_Static_assert(sizeof(RuntimeEntryServiceView) == 0x28,
               "runtime entry stride mismatch");

typedef void (*RuntimeEntryRefreshCallback)(RuntimeEntryServiceView *entry,
                                            uint32_t window_end,
                                            uint32_t threshold);
extern uint32_t Math_ModuloUnsigned(uint32_t numerator,
                                    uint32_t denominator);

/*
 * 0x080627CC. The caller supplies the end of the current timing window and a
 * shared threshold in r1/r2. The routine calls the callback through the ROM
 * pointer slot at 0x0807D988; the slot currently points to IWRAM 0x03006C60.
 */
void RuntimeEntry_ServiceOne(void *entry_pointer,
                             uint32_t window_end,
                             uint32_t threshold)
{
    RuntimeEntryServiceView *entry = (RuntimeEntryServiceView *)entry_pointer;
    RuntimeEntryRefreshCallback refresh;
    uint32_t source;
    uint32_t first_end;
    uint32_t second_end;
    uint32_t second_length;
    uint32_t cursor;

    if (entry->status != 1)
        return;

    refresh = (RuntimeEntryRefreshCallback)(uintptr_t)
        *(volatile const uint32_t *)(uintptr_t)0x0807D988u;
    refresh(entry, window_end, threshold);

    source = entry->source;
    first_end = source +
        *(volatile const uint32_t *)(uintptr_t)(source + 4u) + 0x10u;
    second_length = *(volatile const uint32_t *)(uintptr_t)(source + 8u);
    second_end = source + second_length + 0x10u;
    cursor = entry->cursor;

    if (cursor < first_end)
        return;

    if (second_length == 0) {
        entry->status = 0;
        return;
    }

    entry->cursor = second_end + Math_ModuloUnsigned(
        cursor - first_end, first_end - second_end);
}
