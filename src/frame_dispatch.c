#include "gba.h"
#include <stdint.h>

/*
 * Recovered from 0x08062814. This routine services the runtime-entry array,
 * tracks a wrapping Timer0 counter, and submits one or two transfer segments
 * through a runtime-installed callback. Names describe observed behavior;
 * higher-level audio/video semantics are not proven.
 */
typedef struct RuntimeEntryView {
    uint8_t bytes[0x28];
} RuntimeEntryView;

_Static_assert(sizeof(RuntimeEntryView) == 0x28,
               "runtime-entry stride mismatch");

typedef void (*RuntimeTransferCallback)(uint32_t cursor,
                                        uint32_t length,
                                        uint32_t previous_segment);

extern void RuntimeScript_Service(void); /* 0x08062C48 */
extern void RuntimeEntry_ServiceOne(void *entry, uint32_t window_end,
                                    uint32_t threshold); /* 0x080627CC */

#define GBA_PTR(type, address) ((volatile type *)(uintptr_t)(address))

void FrameEvent_Service(void)
{
    uint32_t context = *GBA_PTR(uint32_t, 0x03005E1Cu);
    uint32_t enabled = *GBA_PTR(uint32_t, 0x03005E44u);
    RuntimeEntryView *entries = (RuntimeEntryView *)(uintptr_t)
        *GBA_PTR(uint32_t, 0x03005E24u);
    uint32_t count = *GBA_PTR(uint8_t, 0x03005E04u);
    uint32_t previous_timer;
    uint32_t current_timer;
    uint32_t first_segment;
    uint32_t wrapped_segment = 0;
    uint32_t elapsed;
    uint32_t interval;
    uint32_t cursor;
    uint32_t i;
    RuntimeTransferCallback transfer;

    if (context == 0 || enabled == 0)
        return;

    RuntimeScript_Service();

    /* Timer0 is rounded to an even count. 0x10000 means it just wrapped. */
    previous_timer = *GBA_PTR(uint32_t, 0x03000D94u);
    current_timer = (uint32_t)*GBA_PTR(uint16_t, 0x04000100u) + 1u;
    current_timer &= ~1u;
    if (current_timer == 0x10000u)
        current_timer = *GBA_PTR(uint16_t, 0x03005E18u);
    *GBA_PTR(uint32_t, 0x03000D94u) = current_timer;

    interval = *GBA_PTR(uint16_t, 0x03005E4Cu);
    if (current_timer > previous_timer) {
        first_segment = current_timer - previous_timer;
    } else {
        first_segment = 0x10000u - previous_timer;
        wrapped_segment = interval + current_timer - 0x10000u;
    }
    elapsed = first_segment + wrapped_segment;

    /* Every entry receives the end of the elapsed window and a shared limit. */
    for (i = 0; i < count; ++i) {
        uint16_t threshold = *GBA_PTR(uint16_t, 0x03000DA0u);
        RuntimeEntry_ServiceOne(&entries[i], elapsed, threshold);
    }

    transfer = (RuntimeTransferCallback)(uintptr_t)
        *GBA_PTR(uint32_t, 0x03000D8Cu);

    /* The installed callback consumes the first contiguous segment. */
    cursor = *GBA_PTR(uint32_t, 0x03000D90u);
    transfer(cursor, first_segment, 0);
    cursor += first_segment;
    *GBA_PTR(uint32_t, 0x03000D90u) = cursor;

    /* If Timer0 wrapped, continue at the start of the ring buffer. */
    if (wrapped_segment != 0) {
        cursor -= interval;
        *GBA_PTR(uint32_t, 0x03000D90u) = cursor;
        transfer(cursor, wrapped_segment, first_segment);
        cursor += wrapped_segment;
        *GBA_PTR(uint32_t, 0x03000D90u) = cursor;
    }

    /* Normalize the exact end pointer back to the context's ring-buffer base. */
    if (cursor == context + interval) {
        cursor -= interval;
        *GBA_PTR(uint32_t, 0x03000D90u) = cursor;
    }
}

