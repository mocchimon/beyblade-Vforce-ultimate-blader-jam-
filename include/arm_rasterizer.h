#ifndef ARM_RASTERIZER_H
#define ARM_RASTERIZER_H

#include <stdint.h>

/* Entries compiled in ARM state for the relocated GBA rasterizer image. */
int ArmRaster_ProcessPrimitiveEdges(void *output_record,
                                    const void *coordinate_records,
                                    const void *primitive_record);
void ArmRaster_DrawRows(void *output_record, const void *destination_rows);
void ArmRaster_ApplyVertexParameters(const void *descriptor,
                                     const void *parameter_record,
                                     uint32_t phase);
void ArmRaster_TransformVertexRows(const void *descriptor,
                                   const void *unused_argument,
                                   const void *transform_context,
                                   const void *vertex_values);

#endif
