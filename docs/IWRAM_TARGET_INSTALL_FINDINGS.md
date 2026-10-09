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

## Next tracing step

Enumerate all memory-copy/decompression sites and their destination construction, then check for destination ranges covering `0x0300646C` or `0x0300682C`. Also trace the setup of the first table entries `0x0300717C`, `0x030071D0`, `0x030072F8`, and `0x03007478`, since the consumer at `0x0806027E` branches directly to `0x0300717C`.
