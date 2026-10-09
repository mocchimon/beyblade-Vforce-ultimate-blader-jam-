# Render transfer recovery

## 0x08059334 — transfer preparation / clipping

The routine beginning at `0x08059334` is a rectangular transfer preparation
stage, not the resource decoder itself.

Confirmed operations:

- reads the source surface pointer from child `+0x70`;
- derives a destination base from child `+0x5C` and GBA VRAM base `0x06000000`;
- reads the child dimensions from the runtime fields established by the
  resource/layout initialization;
- clips the requested rectangle when the X or Y origin is negative or when
  the requested extent exceeds the child dimensions;
- adjusts source/destination offsets when clipping removes part of the
  requested rectangle;
- calls the shared transfer tail-dispatch at `0x08065C5C` after preparing the
  surviving rectangle.

The branch table at `0x08065C5C` is not the renderer itself. Its six entries are:

```text
0x08065C5C  bx r9
0x08065C60  bx r10
0x08065C64  bx r11
0x08065C68  bx r12
0x08065C6C  bx sp
0x08065C70  bx lr
```

The intervening `mov r8,r8` instructions are alignment/padding. Callers select
one of these targets by loading the appropriate register before entering the
shared tail. This is why the backend should not yet be represented as six
ordinary C functions with guessed signatures.

## Why this matters for the resource format

The resource path is now separated into three layers:

```text
resource record
    |
    +--> ChildResource_Init
    |       |
    |       +--> layout/dimension setup
    |       +--> child +0x70 source surface
    |
    +--> Render_PrepareTransfer (0x08059334)
            |
            +--> rectangle clipping
            +--> transfer parameter preparation
            +--> 0x08065C5C tail dispatch
```

One backend is now confirmed: `r9` is loaded with `0x08059521` when child
`+0x64` bit 0 is set, and the resulting transfer is a direct DMA3 copy. The
remaining high-value target is the alternate function pointer at `0x0300646C`.
