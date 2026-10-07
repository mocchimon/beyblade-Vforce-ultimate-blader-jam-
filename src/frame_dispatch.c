#include "gba.h"
#include <stdint.h>

/*
 * 0x08062814 is a frame/event service. It is not yet safe to call it a
 * gameplay update: it first checks several global enable/state flags,
 * advances an aligned timing value, and then dispatches through a table.
 */
void FrameEvent_Service(void)
{
    uint32_t *state = *(uint32_t **)0x03005E78;
    uint8_t mode = *(uint8_t *)0x03005E4C;

    if (state == 0 || state[1] == 0)
        return;

    FrameEvent_UpdateTiming();

    /* Further event-table dispatch is being reconstructed. */
    (void)mode;
}

void FrameEvent_UpdateTiming(void);
