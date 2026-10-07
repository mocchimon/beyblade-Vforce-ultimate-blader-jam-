#include <stdint.h>

/*
 * 0x0805FEF4 is reached once during startup with (2, 0x10, 3).
 * It allocates/initializes a descriptor containing several derived pointers.
 * The surrounding allocator has not yet yielded enough evidence to assign
 * this object to a specific game subsystem, so ResourceDescriptor is a
 * deliberately neutral name.
 */
typedef struct ResourceDescriptor {
    uint8_t  byte00;
    uint8_t  byte01;
    uint8_t  byte02;
    uint8_t  byte03;
    uint8_t  byte04;
    uint8_t  byte05;
    uint8_t  byte06;
    uint8_t  pad07;
    uint32_t field08;
    uint32_t field0C;
    uint32_t field10;
    uint32_t field14;
    uint32_t field18;
    uint32_t field1C;
    uint32_t field20;
    uint32_t field24;
    uint32_t field28;
    uint32_t field2C;
    uint32_t field30;
    uint32_t field34;
    uint32_t field38;
    uint32_t field3C;
    uint32_t field40;
} ResourceDescriptor;

void ResourceDescriptor_Init(uint32_t a, uint32_t b, uint32_t c)
{
    /* Documented here as an interface while the allocator/data ownership is
     * being recovered.  The assembly remains the authoritative version. */
    (void)a; (void)b; (void)c;
}
