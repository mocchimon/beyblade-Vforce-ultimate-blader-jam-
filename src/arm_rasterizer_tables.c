#include <stddef.h>
#include <stdint.h>

/*
 * Source reconstruction of ARM image helper 0x08064C38.
 *
 * The routine appends a signed 16-bit item to an indexed node table and links
 * that node into the selected bucket. The structure names are intentionally
 * layout-oriented: original type names and the larger subsystem's semantics
 * are not known yet.
 */
typedef struct {
    uint8_t unknown_00[4];
    int16_t node_count;             /* +0x04 */
    uint8_t unknown_06[2];
    int16_t *bucket_links;          /* +0x08: 4-byte bucket records */
    int16_t *node_links;            /* +0x0C: 4-byte node records */
} ArmRaster_LinkTable;

void ArmRaster_InsertBucketItem(ArmRaster_LinkTable *table,
                                uint32_t bucket_index,
                                int16_t item)
{
    uint32_t index = (uint16_t)table->node_count;
    int16_t *node = table->node_links + index * 2u;
    int16_t *bucket = table->bucket_links + bucket_index * 2u;

    node[0] = item;
    node[1] = -1;

    if (bucket[0] < 0) {
        /* Empty bucket: initialize both words to this node index. */
        bucket[0] = (int16_t)index;
        bucket[1] = (int16_t)index;
    } else {
        /* Non-empty bucket: append after its current tail. */
        int16_t tail = bucket[1];
        table->node_links[(uint16_t)tail * 2u + 1u] = (int16_t)index;
        bucket[1] = (int16_t)index;
    }

    table->node_count = (int16_t)(table->node_count + 1);
}

/*
 * Source reconstruction of ARM image helper 0x08064C8C.
 *
 * The input descriptor offsets are retained directly from the ROM because
 * their original C structure is unknown. A selection list may restrict the
 * primitive records processed; each selection-map entry is {start,count}.
 */
static void ArmRaster_AddPrimitiveToBucket(ArmRaster_LinkTable *bucket_table,
                                           const uint8_t *primitive_ref,
                                           const uint8_t *vertex_records,
                                           uint32_t primitive_index)
{
    const uint32_t *refs = (const uint32_t *)primitive_ref;
    uint16_t a = (uint16_t)refs[0];
    uint16_t b = (uint16_t)(refs[0] >> 16);
    uint16_t c = (uint16_t)refs[1];
    uint16_t flags = (uint16_t)(refs[1] >> 16);
    const uint8_t *va = vertex_records + (uint32_t)a * 0x10u;
    const uint8_t *vb = vertex_records + (uint32_t)b * 0x10u;
    const uint8_t *vc = vertex_records + (uint32_t)c * 0x10u;
    int alternate_bucket = (b == c) || ((flags & 1u) != 0);
    int32_t bucket_value;

    if (!alternate_bucket) {
        int32_t dx_ab = *(const int32_t *)(va + 0x00) -
                        *(const int32_t *)(vb + 0x00);
        int32_t dy_ab = *(const int32_t *)(va + 0x04) -
                        *(const int32_t *)(vb + 0x04);
        int32_t dx_cb = *(const int32_t *)(vc + 0x00) -
                        *(const int32_t *)(vb + 0x00);
        int32_t dy_cb = *(const int32_t *)(vc + 0x04) -
                        *(const int32_t *)(vb + 0x04);
        uint32_t determinant = (uint32_t)dx_ab * (uint32_t)dy_cb -
                               (uint32_t)dy_ab * (uint32_t)dx_cb;

        /* ARM's CMP/BGT observes the signed 32-bit result after wraparound. */
        if ((int32_t)determinant > 0)
            return;
    }

    /* Preserve the ARM 32-bit add/ASR sequence used to choose the bucket. */
    uint32_t first_sum = (uint32_t)*(const int32_t *)(va + 0x08) +
                         (uint32_t)*(const int32_t *)(vb + 0x08);
    int32_t half_sum = (int32_t)first_sum >> 1;
    uint32_t second_sum = (uint32_t)half_sum +
                          (uint32_t)*(const int32_t *)(vc + 0x08);
    bucket_value = (int32_t)second_sum >> 8;
    bucket_value += alternate_bucket ? 17 : 16;
    bucket_value &= 31;

    ArmRaster_InsertBucketItem(bucket_table,
                               (uint32_t)(31 - bucket_value),
                               (int16_t)primitive_index);
}

void ArmRaster_BuildEdgeBuckets(const void *input_descriptor,
                                ArmRaster_LinkTable *bucket_table,
                                const int16_t *selection_list)
{
    const uint8_t *input = (const uint8_t *)input_descriptor;
    const uint8_t *header = *(const uint8_t * const *)(input + 0x00);
    const uint8_t *primitive_refs =
        *(const uint8_t * const *)(input + 0x08);
    const uint8_t *vertex_records =
        *(const uint8_t * const *)(input + 0x10);
    const uint8_t *selection_map = selection_list != NULL
        ? *(const uint8_t * const *)(input + 0x64) : NULL;
    uint32_t default_count = *(const uint16_t *)(header + 0x06);

    if (selection_list == NULL) {
        uint32_t index = 0;
        uint32_t remaining = default_count;
        do {
            ArmRaster_AddPrimitiveToBucket(bucket_table,
                                           primitive_refs + index * 8u,
                                           vertex_records, index);
            ++index;
            --remaining;
        } while (remaining != 0);
        return;
    }

    while (*selection_list >= 0) {
        uint16_t selection = (uint16_t)*selection_list++;
        const int16_t *range =
            (const int16_t *)(selection_map + (uint32_t)selection * 4u);
        uint32_t index = (uint16_t)range[0];
        int32_t remaining = range[1];

        do {
            ArmRaster_AddPrimitiveToBucket(bucket_table,
                                           primitive_refs + index * 8u,
                                           vertex_records, index);
            ++index;
            --remaining;
        } while (remaining != 0);
    }
}

/*
 * Reconstructed loop at ARM image offset +0xC28 (ROM 0x08064DE0).
 *
 * bucket_count is a halfword at +0; bucket_heads points at +8; node_links
 * points at +0x0C. vertex_records is at +8 in the second descriptor, and
 * row_parameters at +0x10. Each bucket head and node link is a signed
 * halfword index; each node occupies four bytes and stores {vertex_index,next}.
 *
 * The called primitive/row routines are declared as externs because their
 * source-level equivalents are still being recovered independently.
 */
extern int ArmRaster_ProcessPrimitiveEdges(void *output,
                                           const void *row_parameters,
                                           const void *vertex_record);
extern void ArmRaster_DrawRows(void *output, const void *draw_list);

void ArmRaster_ProcessEdgeBuckets(const void *bucket_descriptor,
                                  const void *vertex_descriptor,
                                  const void *draw_list,
                                  void *output)
{
    const uint8_t *bucket_bytes = (const uint8_t *)bucket_descriptor;
    const uint8_t *vertex_bytes = (const uint8_t *)vertex_descriptor;
    uint32_t bucket_count = *(const uint16_t *)(bucket_bytes + 0x00);
    const int16_t *bucket_heads =
        *(const int16_t * const *)(bucket_bytes + 0x08);
    const int16_t *node_links =
        *(const int16_t * const *)(bucket_bytes + 0x0C);
    const uint8_t *vertex_records =
        *(const uint8_t * const *)(vertex_bytes + 0x08);
    const void *row_parameters =
        *(const void * const *)(vertex_bytes + 0x10);

    for (uint32_t bucket_index = 0; bucket_index < bucket_count;
         ++bucket_index) {
        int16_t node_index = bucket_heads[bucket_index * 2u];
        while (node_index >= 0) {
            const int16_t *node = node_links + (uint16_t)node_index * 2u;
            uint16_t vertex_index = (uint16_t)node[0];
            const void *vertex_record = vertex_records + vertex_index * 8u;

            if (ArmRaster_ProcessPrimitiveEdges(output, row_parameters,
                                                vertex_record) != 0) {
                ArmRaster_DrawRows(output, draw_list);
            }
            node_index = node[1];
        }
    }
}
