# IWRAM installation audit — copy/decompression call sites

## Scope

This pass searched the full 8 MiB ROM's Thumb disassembly for direct calls to the known BIOS wrappers and inspected the callers. It is a bounded audit of *statically visible direct calls*, not proof that no indirect or custom copy loop exists.

## Confirmed direct BIOS LZ77 call sites

The ROM contains two direct Thumb `BL` instructions to `0x080578F4` (`System_LZ77UnCompWram`):

| Call site | Caller behavior supported by instructions | Assessment for IWRAM code installation |
|---|---|---|
| `0x08055CA8` | `r0` receives the resource/source pointer in `r5`; `r1` receives the dereferenced allocation address in `r6`; calls BIOS LZ77; stores the resulting allocation pointer in its resource record | Resource decompression into an allocator-returned buffer; no evidence the destination is one of the fixed IWRAM targets |
| `0x080572F8` | `r0` receives a source/resource pointer in `r5`; `r1` receives an allocation address loaded from a record; calls BIOS LZ77 and then continues with per-resource flags/state | Same general resource-buffer path; no evidence the destination is one of the fixed IWRAM targets |

These are the only direct calls found in the whole-ROM disassembly to the known wrapper address. This makes a direct LZ77 call into `0x0300646C` or `0x0300682C` unlikely, but does not exclude a function pointer to the BIOS wrapper or another wrapper address.

## CPUSet wrapper call

The known `System_CpuSet` wrapper at `0x080578E4` has one direct call site at `0x0805070A`. Immediately before the call, the caller sets:

- `r0 = 0`
- `r1 = 0`
- `r2 = 0x40000000`

This is consistent with a BIOS CpuSet fill/clear operation over the zero address range/configuration, not an obvious ROM-to-IWRAM code copy. It does not account for the fixed renderer targets.

## DMA3 copy sites

The literal `0x040000D4` (DMA3 source register) appears in multiple routines, including startup initialization, rendering transfers, and resource/runtime helpers. The confirmed startup DMA setup at `0x08057968` copies only `0x104` bytes from `0x08000168` to `0x03000FE0`, ending at `0x030010E4`; this range does not overlap the unresolved runtime targets in `0x0300616C–0x03007478`.

## Current conclusion

No direct BIOS LZ77 call found so far explains the IWRAM targets. The next likely paths are:

1. a custom CPU copy loop whose destination is calculated from a base plus an offset;
2. DMA3 programmed with source/destination values assembled from descriptor fields;
3. runtime code/overlay installation through a resource descriptor or indirect loader;
4. the possibility that the table entries have mixed roles and some are not code destinations despite being used as indirect branch targets in their consumers.

Do not mark the alternate render backend as identified until bytes copied to `0x0300646C` are tied to a source or its live instructions are otherwise reconstructed.

## Follow-up: descriptor-driven DMA candidates

A second pass inspected the additional ROM locations containing the DMA3 source-register literal. These sites demonstrate why a literal-only search cannot resolve the IWRAM targets: some transfer setup routines obtain source, destination, and transfer length from runtime state.

### `0x0805EFF8` — descriptor-driven DMA3 transfer setup

The instructions around `0x0805EFF8` program DMA3 as follows:

- source register receives a value held in `r6` (loaded earlier from a ROM literal pool);
- destination register receives the first word of the descriptor addressed by `r1`;
- transfer control is derived from the descriptor's second word, shifted right by two, then combined with `0x84000000` (immediate 32-bit transfer enable).

This is a concrete candidate for a descriptor-driven copy path, but the currently inspected slice does not establish that the destination is IWRAM. The caller and descriptor producer must be traced before assigning it to the code-installation path.

### `0x08062ED0` — DMA3 zero/fill-style operation

The routine around `0x08062ED0` stores several descriptor/global values and then programs DMA3 with a stack address as the source and a destination loaded from runtime state. Its control word is `0x05000000`, consistent with a special-timing/word-sized DMA operation rather than a ROM-to-IWRAM code copy. It is therefore a lower-priority candidate for the missing executable blocks.

### Classification outcome

- The startup transfer at `0x08057968` remains a confirmed ROM-to-IWRAM copy, but its range ends at `0x030010E4`.
- `0x0805EFF8` is the strongest newly identified *dynamic destination* candidate; its descriptor destination has not yet been proven to overlap `0x0300646C` or `0x0300682C`.
- `0x08062ED0` appears to perform a runtime-state fill/transfer and is not presently evidence of code installation.
- Other DMA3 sites at `0x0805F408`, `0x0805FE44`, and `0x08062624` are associated with resource, rendering, or hardware-state operations in their surrounding code; no fixed IWRAM target was established from the current slices.

Next: trace callers and descriptor writers for `0x0805EFF8`, and inspect the runtime record that supplies its destination and length. Do not claim the IWRAM target is resolved until the destination range or copied bytes match.

## Follow-up: trace of the `0x0805EFF8` DMA candidate

The containing routine begins at `0x0805EFC0`; `0x0805EFF8` is an instruction inside it, not a function entry. The routine is called from startup at `0x08050644` with:

- `r0 = *(uint32_t *)0x03000FB0 + 0xBA0`
- `r1 = 0`

The call occurs after startup subsystem initialization and before the first frame-loop iteration. The routine allocates a `0xD24`-byte block when the second argument is zero, stores the allocation pointer in the context, and performs a DMA3 setup using the allocation/runtime fields. It then constructs many pointer-like fields by adding offsets from a ROM-resident table to a base pointer.

This is consistent with a startup context/table setup or relocation helper. It is **not** evidence of copying code to `0x0300646C` or `0x0300682C`: the destination used by the DMA sequence is read from runtime memory, and the caller/descriptor chain has not been shown to resolve to either target range. Keep the IWRAM installation question open.

### New classification

- `0x0805EFC0`: startup context/table setup candidate; contains DMA3 programming and pointer-field relocation.
- `0x0805EFF8`: internal DMA setup site, not a standalone function.
- Caller: `0x08050644`, invoked once before the main loop.
- Target overlap: **unproven**.

Next: inspect the descriptor/context fields created by `0x0805EFC0`, and independently audit all direct callers of routines that program DMA3 source/destination/control registers.
