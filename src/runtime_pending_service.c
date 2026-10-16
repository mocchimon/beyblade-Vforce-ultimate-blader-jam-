#include <stdint.h>
#include <stddef.h>

/* Recovered from asm/pass5/sub_62b44.thumb.s at ROM 0x08062B50.
 * The outer loop has 16 records of 36 bytes, each with four 8-byte entries.
 * Each entry stores an active byte at +4 and a callback argument at +8.
 * The +8 word overlaps the following entry: preserve this exact layout.
 * This is a behavioral reconstruction, not a matching-code claim.
 */
typedef void (*PendingCallback)(uint32_t value, void *context);

/* The original reloads the buffer pointer after each callback. A callback can
 * replace the table; retaining the old pointer would clear the wrong entry.
 * The callback argument is read from the current table before invocation.
 */
typedef volatile uint8_t *(*PendingBufferProvider)(void *context);

static uint32_t Pending_Read32(volatile uint8_t *p)
{
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
           ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

void RuntimePending_ServiceDynamic(PendingBufferProvider provider, void *provider_context,
                                   volatile uint32_t *enabled,
                                   PendingCallback callback, void *callback_context)
{
    unsigned row, slot;
    if (*enabled != 1u)
        return;
    for (row = 0; row < 16; ++row) {
        for (slot = 0; slot < 4; ++slot) {
            unsigned offset = row * 36u + slot * 8u;
            volatile uint8_t *table = provider(provider_context);
            if (table[offset + 4] != 0) {
                uint32_t value = Pending_Read32(table + offset + 8);
                callback(value, callback_context);
                /* Re-read provider exactly as the Thumb code re-reads [r2]. */
                table = provider(provider_context);
                table[offset + 4] = 0;
            }
        }
    }
    *enabled = 0;
}

static volatile uint8_t *Pending_FixedBuffer(void *context)
{
    return (volatile uint8_t *)context;
}

void RuntimePending_ServiceBuffer(volatile uint8_t *buffer,
                                  volatile uint32_t *enabled,
                                  PendingCallback callback, void *context)
{
    RuntimePending_ServiceDynamic(Pending_FixedBuffer, (void *)buffer,
                                  enabled, callback, context);
}

static volatile uint8_t *Pending_GameBuffer(void *context)
{
    (void)context;
    return *(volatile uint8_t **)(uintptr_t)0x03005E28u;
}

extern void RuntimeEntry_Deactivate(uint32_t serial);

static void RuntimePending_Dispatch(uint32_t value, void *context)
{
    (void)context;
    RuntimeEntry_Deactivate(value);
}

void sub_08062B50(void)
{
    volatile uint32_t *enabled = (volatile uint32_t *)(uintptr_t)0x03005E0Cu;
    /* If disabled, the original never dereferences the buffer. */
    if (*enabled == 1u)
        RuntimePending_ServiceDynamic(Pending_GameBuffer, NULL, enabled,
                                      RuntimePending_Dispatch, NULL);
}
