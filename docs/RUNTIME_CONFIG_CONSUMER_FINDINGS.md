# Runtime configuration block: first consumer recovered

## New evidence

The code region beginning at `0x08060170` contains a reference to the mixed ROM block at `0x0807D920`. The load at `0x0806027E` resolves through its literal pool at `0x080602C0`:

```asm
0806027E  ldr r0, [pc, #0x40]   ; literal at 0x080602C0
08060280  ldr r0, [r0]          ; first word of 0x0807D920 = 0x0300717C
08060282  bl  0x08065C38       ; trampoline: bx r0
```

The shared dispatch stub at `0x08065C38` is exactly `bx r0` (with alignment padding after it). This establishes that the first table entry is dereferenced and used as an indirect control-flow target by this routine. Because `0x0300717C` lies in GBA IWRAM, the address may identify executable runtime code or a runtime-installed entry; it should not be described as a normal EWRAM data pointer based on the address value alone.

The region at `0x0807D920` therefore has mixed semantics at the word level. The first entries are not necessarily ordinary global-variable addresses; some may be pointers to runtime-installed IWRAM code. The block also contains clear Thumb ROM pointers (for example `0x08057B65` and `0x080607B5`), scalar configuration words, and subsequent compact lookup bytes. It is not a single flat callback array.

## Important boundary

This finding explains how one entry is consumed, but does **not** prove the entire block's record boundaries or identify the code that installs the value at `0x0300646C`. In particular, the table word at `0x0807D968` equals the address `0x0300646C`; that is not itself proof that it initializes that global. The alternate render pointer's actual write remains an open question.

## Immediate follow-up

1. Trace the runtime setup of IWRAM addresses in the `0x03007xxx` range.
2. Determine whether `0x0300717C` contains executable code or a pointer/dispatch record at runtime.
3. Trace all other loads from `0x0807D920` and nearby literal-pool values.
4. Continue searching for the actual write to `0x0300646C`; keep `0x08059428` provisional until that is proven.

## Follow-up: literal-reference scan for the alternate renderer slot

A whole-ROM aligned-word scan confirms that the literal value `0x0300646C` occurs only once as a 32-bit word in the ROM, at `0x0807D968`. It is embedded in the mixed block beginning at `0x0807D920`. There is no Thumb `LDR (literal)` instruction in the nearby code that directly loads the address literal at `0x0807D968`.

This narrows the initialization hypothesis: the slot is likely reached through a base pointer, indexed structure, copied/configuration data, or address arithmetic rather than a straightforward `ldr rN, =0x0300646C` literal reference. This is a negative search result, not proof that no code writes the slot.

The consumer at `0x0805921C` loads the address `0x0300646C` from its own literal pool at `0x08059254`, dereferences the slot, then passes the resulting target through the shared `bx r4` stub at `0x08065C48`. The alternate target therefore comes from mutable runtime state; its concrete value must be recovered from the initialization path or a dynamic runtime snapshot.

## Confirmed address words in the mixed block

| ROM address | Word | Conservative interpretation |
|---|---:|---|
| `0x0807D920` | `0x0300717C` | runtime address consumed as an indirect control target by code around `0x0806027E` |
| `0x0807D924` | `0x030071D0` | runtime address; role unresolved |
| `0x0807D928` | `0x030072F8` | runtime address; role unresolved |
| `0x0807D92C` | `0x03007478` | runtime address; role unresolved |
| `0x0807D950` | `0x08057B65` | Thumb ROM pointer |
| `0x0807D954` | `0x08057C5D` | Thumb ROM pointer |
| `0x0807D958` | `0x080607B5` | Thumb ROM pointer |
| `0x0807D95C` | `0x0806082D` | Thumb ROM pointer |
| `0x0807D960` | `0x0300616C` | runtime address; role unresolved |
| `0x0807D964` | `0x08057C5D` | Thumb ROM pointer |
| `0x0807D968` | `0x0300646C` | alternate render function-pointer slot address |

These values are documented as words, not assumed to form one homogeneous array. The surrounding block includes scalar/byte lookup data and needs further structure recovery.
