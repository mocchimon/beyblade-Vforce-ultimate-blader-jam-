#include <stdint.h>

typedef struct ResourceIndexRange { const uint32_t *begin; const uint32_t *end; } ResourceIndexRange;
#define RESOURCE_INDEX_TABLE ((const ResourceIndexRange *)0x08075640u)
#define RESOURCE_INDEX_TABLE_COUNT 32u
#define RESOURCE_INDEX_PRIMARY_COUNT 7u
#define RESOURCE_INDEX_BANK0_COUNT 16u
#define RESOURCE_INDEX_BANK1_COUNT 19u
#define RESOURCE_INDEX_BANK2_COUNT 19u
#define RESOURCE_INDEX_BANK3_COUNT 13u
#define RESOURCE_INDEX_BANK4_COUNT 32u
#define RESOURCE_INDEX_BANK5_COUNT 8u
#define RESOURCE_INDEX_BANK6_POINTERS 2u /* one resource + end sentinel */
#define RESOURCE_INDEX_PRIMARY_RESOURCE_COUNT 108u
#define RESOURCE_INDEX_ALIAS_RESOURCE_COUNT 2u
#define RESOURCE_INDEX_UNIQUE_RESOURCE_COUNT 110u

/* Resource record recovered from 0x08058ACC.
 *
 * The +0x04 value is the length of the inline data following this 16-byte
 * header.  The pointer table advances by align4(sizeof(header) + data_size),
 * so it must not be treated as a complete physical record span.
 */
typedef struct ResourceBlobHeader {
    uint32_t field_00;
    uint32_t data_size;
    uint32_t field_08;
    uint32_t source_offset;
    uint8_t data[];
} ResourceBlobHeader;

static inline uint32_t ResourceBlob_StorageSize(const ResourceBlobHeader *r)
{
    return (0x10u + r->data_size + 3u) & ~3u;
}

#define RESOURCE_BLOB_HEADER_SIZE 0x10u
#define RESOURCE_BLOB_MODE_OFFSET 0x18u
#define RESOURCE_BLOB_MODE2_OFFSET 0x19u
#define RESOURCE_BLOB_PARAM_A_OFFSET 0x1Cu
#define RESOURCE_BLOB_PARAM_B_OFFSET 0x1Eu

/* Recovered address/size manifest lives in data/resource_blob_manifest.inc. */
