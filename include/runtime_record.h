#ifndef UBJ_RUNTIME_RECORD_H
#define UBJ_RUNTIME_RECORD_H

#include <stdint.h>

typedef struct RuntimeRecordManager RuntimeRecordManager;

/* ROM 0x08050388 clears fields +0x04..+0x17 and preserves its descriptor. */
void RuntimeRecord_Clear(volatile RuntimeRecordManager *manager);

/* Recovered from the linked source list and 0x18-byte records at 0x08050398. */
void RuntimeRecord_Init(RuntimeRecordManager *manager,
                        const uint32_t *source, uint16_t flags);
void RuntimeRecord_Update(RuntimeRecordManager *manager);

#endif
