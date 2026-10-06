# Ultimate Blader Jam — initial reverse-engineering map
- ROM size: 0x800000 bytes
- CRC32: `9C93DE35`
- SHA-1: `8d2cdd3ece0ab7d2f982b0a83e3ecb878f514a72`
- Header game code: `BEYP`
- Entry instruction: `EA1FF9EB` at `0x08000000`
- Entry branch target: `0x087FE7B4`

## Confirmed relocation bootstrap

The cartridge entry branches to `0x087FE7B4`. The routine copies `0x184C` bytes from ROM `0x087FE7E4` into EWRAM `0x020000C0`, then jumps to `0x020000C0`.

```c
static void Boot_RelocateStartup(void)
{
    const uint32_t *src = (const uint32_t *)0x087FE7E4;
    uint32_t *dst = (uint32_t *)0x020000C0;
    uint32_t bytes = 0x184C;

    while (bytes != 0) {
        *dst++ = *src++;
        bytes -= 4;
    }

    ((void (*)(void))0x020000C0)();
}
```

This is a semantic reconstruction; the original source names are not recoverable from the binary alone.

## Relocated bootstrap routines

| EWRAM address | ROM source | preliminary role |
|---|---|---|
| `0x020000C0` | relocated from ROM `0x080000C0` | startup / memory initialization |
| `0x020001D0` | relocated from ROM `0x080001D0` | hardware/video initialization |
| `0x02000178` | relocated from ROM `0x08000178` | table/data transformation |
| `0x0200010C` | relocated from ROM `0x0800010C` | wait for display status |
| `0x0200012C` | relocated from ROM `0x0800012C` | wait for display status / scanline |
| `0x0200014C` | relocated from ROM `0x0800014C` | register write helper |
| `0x0200015C` | relocated from ROM `0x0800015C` | display register configuration |

## Important distinction

The bytes after the initial bootstrap routines are not being classified as code merely because they occur inside the relocated 0x184C-byte block. The next pass must classify the remaining block as startup code, tables, and data before creating higher-level C.
