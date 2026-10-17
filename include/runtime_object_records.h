#ifndef UBJ_RUNTIME_OBJECT_RECORDS_H
#define UBJ_RUNTIME_OBJECT_RECORDS_H

#include <stdint.h>

/* Recovered from the frame call at 0x080494F4 and routines at
 * 0x08050A74/0x08058F18/0x08058F84. Field meaning remains provisional. */
void RuntimeObject_UpdateRecordArray(void *array_header);
void RuntimeObject_UpdateRecord(void *record);
void RuntimeObject_UpdateDisplayRegion(void *record,
                                       uint32_t delta_x, uint32_t delta_y);
void RuntimeObject_UpdateDisplayRegionFromFrame(void *record,
                                                const void *frame);
void RuntimeObject_ApplyRecordTransform(void *record);

/* Source entries for the affine-transform path. The argument and field names
 * describe the observed data flow; higher-level game meaning is provisional. */
void RuntimeObject_UpdateAffineTransform(uint8_t mode, uint8_t angle,
                                         uint16_t x, uint16_t y);
void RuntimeObject_SetAffineReferencePoint(uint8_t mode,
                                           uint32_t x, uint32_t y);
void RuntimeObject_SetAffineCoefficients(uint8_t mode,
                                         uint16_t pa, uint16_t pb,
                                         uint16_t pc, uint16_t pd);
int32_t RuntimeObject_MultiplyAffineCoefficients(int32_t lhs, int32_t rhs);

#endif
