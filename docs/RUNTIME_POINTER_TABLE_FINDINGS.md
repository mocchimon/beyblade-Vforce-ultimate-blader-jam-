# Runtime pointer/configuration table investigation

## ROM table at `0x0807D920`

The word-aligned region beginning at `0x0807D920` is structured data, not a homogeneous callback array. Its entries mix:

- EWRAM destinations / runtime-global addresses (`0x0300717C`, `0x030071D0`, `0x030072F8`, `0x03007478`, etc.);
- scalar configuration words and packed byte sequences;
- Thumb code pointers (`0x08057B65`, `0x08057C5D`, `0x080607B5`, `0x0806082D`);
- additional runtime-global addresses including `0x0300616C` and `0x0300646C`.

The surrounding region also contains compact byte lookup tables, so the whole area must not be treated as one flat function-pointer table. The current best description is **a mixed runtime configuration/data block containing address and callback-like entries**, with its exact record boundaries still unresolved.

## Cross-reference evidence

A raw aligned-word scan finds the address `0x0807D920` at ROM address `0x080602C0`. The code immediately preceding that literal pool contains a PC-relative load at `0x0806027E` that resolves to `0x080602C0`; thus code in the `0x080602xx` region obtains a pointer to this block. This is a concrete code-to-data reference, but the routine's full entry boundary and the table's per-field semantics still require control-flow reconstruction.

The word `0x0300646C` occurs in this block at `0x0807D968`. The same EWRAM address is loaded by render-transfer code at `0x08059254` and `0x080593FC`, supporting its interpretation as a runtime global rather than a literal source-data pointer. The render path reads the word stored at that EWRAM address as an indirect backend target.

## What is and is not established

Established:

1. The block contains a mixture of runtime addresses, Thumb pointers, and scalar/lookup data.
2. Code in the `0x080602xx` region references the block through a PC-relative literal.
3. `0x0300646C` is a runtime function-pointer slot consumed by render-transfer code.
4. `0x08059428` is structurally a sibling 16-bit DMA3 rectangle-transfer routine.

Not yet established:

1. That every function-looking word in this block is a callback rather than a handler address embedded in a larger record.
2. The exact code path that writes `0x0300646C`.
3. That `0x08059429` is definitely the value installed there.
4. A complete structure/stride for the `0x0807D920` block.

## Next reverse-engineering actions

- Reconstruct the complete function containing the `0x0806027E` literal load and identify the offsets it reads from the block.
- Trace startup copy/initialization tables that populate EWRAM globals in the `0x03006xxx` range.
- Inspect all code references to the other literal-pool words that point into `0x0807D920` and distinguish true code from data references.
- Keep the alternate backend name provisional until the actual store to `0x0300646C` is located.


## Render-table dispatch correction (2026-10-08)

A closer instruction-level read of `0x08059334–0x08059410` shows two distinct indirect paths. The child `+0x64` bit-0-set path selects `0x08059521`; the bit-clear path loads the ROM table word at `0x0807D968`, whose value is `0x0300646C`, into `r9`. A separate child `+0x7C` bit-3-clear branch loads `0x0300682C` from `0x0807D96C` and dispatches through `bx r4`. The code at `0x08059428` is therefore not confirmed as either runtime target. The previous provisional name `Render_CopyRect16_DMA3_Alt` has been withdrawn pending proof of the IWRAM installation/copy path. See `RENDER_ALT_BACKEND_FINDINGS.md`.
