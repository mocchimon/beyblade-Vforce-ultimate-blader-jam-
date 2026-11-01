# IWRAM branch-target installation: current evidence

## Corrected interpretation

The ROM words at `0x0807D968` and `0x0807D96C` contain `0x0300646C` and `0x0300682C`, respectively. These are IWRAM addresses used as **direct executable branch targets**, not RAM slots that hold a second function pointer.

### Render path

- At `0x0805921C`, code loads the ROM table address `0x0807D968` from its literal pool (`0x08059254`).
- At `0x0805923A`, it loads the table word (`0x0300646C`) and dispatches through `0x08065C48` (`bx r4`).
- At `0x08059374`, the clipping path loads the same table entry into `r9`; the common tail dispatcher at `0x08065C5C` (`bx r9`) transfers control to that IWRAM address.
- A separate path around `0x08059400` loads the table word at `0x0807D96C` (`0x0300682C`) and dispatches through `bx r4`.

The GBA memory map identifies `0x03000000–0x03007FFF` as the 32 KiB IWRAM region. The two targets therefore lie in internal work RAM, but the ROM evidence alone does not establish which routine's bytes occupy those addresses at runtime.

## What is not yet proven

- The ROM source range used to populate either IWRAM target.
- Whether code is copied/decompressed there during startup or installed later by a resource/runtime subsystem.
- Whether the nearby ROM routine at `0x08059428` is the source for either target. Its proximity is not sufficient evidence.

## Separate operation target at `0x03006FAC`

The configuration word at `0x0807D994` contains the even address
`0x03006FAC`. The background-operation path reaches it through the verified
Thumb `BX r3` interworking thunk at `0x08065C44`; the even target address
therefore selects ARM state. A whole-ROM byte-aligned scan finds the literal
word `0x03006FAC` only at `0x0807D994`. The table slot itself has multiple
PC-relative references, but those loads do not identify who fills the target
memory. Reproduce the pointer-occurrence check with
`make audit-iwram-target-03006fac ROM=...`.

The existing copy-site audits did not establish a ROM copy/decompression
range covering `0x03006FAC`. This is still an unresolved installer/source
question: searching for the pointer word cannot find compressed or generated
code, and no runtime image has been proven to contain this routine. Its
behavior remains opaque in C.

### Pass 35 range check

The known `0xD24`-byte ARM image cannot supply this callback at offset
`0x03006FAC - 0x030061B8 = 0xDF4` under the earlier hypothetical base
`0x030061B8`; that offset is `0xD0` beyond the image. The loader's actual
destination is allocator-provided EWRAM, so this arithmetic rules out only
that specific base mapping. It does not identify the callback's real installer
or source.

### Pass 36 display-sequence call site

The newly recovered routine at `0x0805B440` calls the same `0x08065C44`
Thumb-to-ARM thunk at `0x0805B5A6`. When its tile-map allocation cursor has
advanced, it passes `r0 = 0`, `r1 = VRAM + owner[0x5D] * 0x4000 +
initial_tile * 0x20`, and `r2 = (final_tile - initial_tile) * 0x20`; `r3` is
loaded from the slot at `0x0807D994`. This identifies a newly allocated
character-tile span as another callback destination. The zero argument and
allocation context are consistent with initialization, but the implementation
at `0x03006FAC` remains unavailable, so the operation is still named and
modeled generically. This is a second recovered call-site family through the
same ARM-state target; it does not resolve how that target is installed.

## Next tracing step

Enumerate all memory-copy/decompression sites and their destination construction, then check for destination ranges covering `0x0300646C` or `0x0300682C`. Also trace the setup of the first table entries `0x0300717C`, `0x030071D0`, `0x030072F8`, and `0x03007478`, since the consumer at `0x0806027E` branches directly to `0x0300717C`.
