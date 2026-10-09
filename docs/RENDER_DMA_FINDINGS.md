# Render/DMA recovery

## 0x08059520 — 16-bit DMA3 rectangle backend

The routine at `0x08059520` is a concrete transfer backend selected by the
render path. It is not a generic decoder.

Confirmed behavior:

- reads the source surface pointer from child `+0x70`;
- reads the source row width/stride from child `+0x00`;
- computes a source offset from the supplied Y coordinate and X coordinate;
- treats the source as 16-bit pixels (the final address arithmetic doubles the
  horizontal offset);
- derives a VRAM destination from child `+0x5C`, using an `0x800`-byte tile
  increment, plus the horizontal destination offset;
- iterates over the requested row range;
- programs DMA channel 3 at `0x040000D4` for each row:

```text
0x040000D4  source
0x040000D8  destination
0x040000DC  count/control
```

The control word has bit 31 set and the low 16 bits contain the number of
16-bit units to transfer. This is therefore a direct VRAM DMA path.

## Backend selection

`0x08059334` selects this backend by loading `r9 = 0x08059521` when the child
flag at `+0x64` has bit 0 set, then branches to `0x08065C5C`.

The alternate path loads a function pointer from `0x0300646C`. Its exact
implementation is the next render target; it is not safe to assume it has the
same DMA ABI yet.

## Updated render chain

```text
resource record
    |
    +--> ChildResource_Init
    |       |
    |       +--> source surface at child +0x70
    |       +--> dimensions/layout
    |
    +--> 0x08059334
            |
            +--> clip rectangle
            +--> choose backend
            |
            +--> 0x08065C5C
                    |
                    +--> 0x08059520  [confirmed DMA3 backend]
                    |       |
                    |       +--> source surface
                    |       +--> VRAM
                    |       +--> DMA3 per row
                    |
                    +--> *(0x0300646C) [alternate backend]
```

## 0x08059620 — related surface/attribute writer

The following routine at `0x08059620` is also part of this render cluster. It
builds a destination address from child `+0x5C`, the child tile dimensions,
and a supplied coordinate, then iterates across a rectangular region while
reading 16-bit values and masking/repacking their low 12 bits with a supplied
mode value. It writes the resulting halfwords back into a linear surface.

This is consistent with a **surface/attribute conversion or preparation**
operation, but the exact destination object and semantic name remain
unresolved. It is deliberately kept provisional rather than being called a
palette or tile decoder without stronger evidence.
