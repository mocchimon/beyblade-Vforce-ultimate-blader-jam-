# ARM rasterizer vertex-parameter recovery

## Entry and register contract

The ARM image entry at ROM `0x08064A14` is reconstructed as
`ArmRaster_ApplyVertexParameters` in `src/arm_rasterizer.c` and declared in
`include/arm_rasterizer.h`. The observed entry registers are `r0` = descriptor,
`r1` = parameter record, and `r2` = phase/packing value. The fourth argument is
not read by this routine. The caller and higher-level meaning of these values
have not yet been recovered.

The descriptor's `+0` pointer leads to a signed halfword count at `+4`; its
`+0x10` pointer leads to the output record area. The parameter record fields
used by the routine are:

| Offset | Access | Observed use |
|---:|---|---|
| `+0x0E` | unsigned halfword | Index transformed as `255 - value` into the parameter table |
| `+0x24..+0x26` | three signed bytes | Two components are combined with table coefficients; the middle component is applied per row |
| `+0x2C`, `+0x2E` | signed halfwords | Subtracted from the first two output words |
| `+0x30` | signed halfword store | Receives a running signed maximum, starting at `-65281` |

## Recovered operations

The pointer literal at ROM `0x08064AF8` is `0x0874CC60` in the supplied ROM.
The routine reads signed halfwords at table index `i` and `i + 64`, where
`i = 255 - parameter[0x0E]`. It combines the signed bytes at `+0x24` and `+0x26`
with those coefficients using wrapped 32-bit multiply/add/subtract operations,
then arithmetic-shifts the two results by eight bits.

It subtracts the two signed offsets from the first two 32-bit output words.
The adjusted second word updates a signed maximum initialized to `-65281`.
Starting at output offset `+12`, it processes the descriptor count in a
do/while loop. Each four-byte row record supplies three signed bytes; the
routine forms a wrapped 32-bit weighted sum, arithmetic-shifts by seven,
adds `128` and `phase >> 3`, logically shifts by `phase & 7`, clamps with the
ARM signed `GT` condition against `255`, and stores one byte at the start of
the row record. The stored maximum is written back at parameter offset `+0x30`.

The source preserves the do/while behavior; the input count is expected to be
nonzero. It does not claim how the row bytes or table coefficients map to a
named graphics format.

## Linkage and validation limits

`src/arm_rasterizer.c` is compiled in ARM state by the project Makefile, as is
the rest of the recovered image code. The C frontend parsed all source units
with their configured ARM/Thumb modes, and static source-integration checks
confirm the entry and table literal. No caller-side execution fixture or
rendered-output comparison is available. No ARM object or matching ROM build
was produced in this environment; see
`docs/PASS13_DEVELOPMENT_2026-10-16.md` for toolchain limitations.
