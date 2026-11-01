# Pass 47 — VRAM tile-map attribute masking

## Recovered entry

`0x08059620` is now represented by `RuntimeDisplay_ApplyAttributeMask` in
`src/runtime_display_attribute_mask.c`. The ROM routine traverses a rectangular
region of halfwords in the VRAM map selected by the child record. It preserves
bits `0..11` and replaces bits `12..15` with the low nibble of a palette/tag
argument. If child halfword `+0x64` has bit 0 set, the routine returns without
writing. The base tile index is read from child byte `+0x5C`, and the map stride
shift comes from byte `+0x5F`.

The C name and argument names are semantic reconstructions, not recovered
original symbols. A whole-ROM Thumb `BL` scan found no direct call to
`0x08059620`, so the incoming dispatch/call ABI is not yet independently
identified. The body has an explicit ROM fingerprint at
`asm/pass47/runtime_display_attribute_mask.thumb.txt`.

## Verification

`tools/verify_runtime_display_attribute_mask.py` checks 85 Thumb halfwords,
the `0x00000FFF` mask literal, and five conditional branch destinations against
the supplied original ROM. The five focused tests cover the saved listing,
branch/literal metadata, synthetic verifier operation, corruption rejection,
and source-level mask/guard structure.

Commands:

```sh
make verify-runtime-display-attribute-mask ROM=/path/to/original.gba
make test-runtime-display-attribute-mask
```

## Matching-ROM status

This is additional source recovery and does not produce a ROM image. The
historical overall estimate remains approximately 54%, unmeasured. No
source-built ROM has been compared byte-for-byte; verified matching progress
remains 0%. The unresolved IWRAM installer at `0x03007034`, original linker
layout, toolchain/code-generation match, and missing source/data remain major
blockers.
