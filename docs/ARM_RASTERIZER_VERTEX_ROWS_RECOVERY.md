# ARM rasterizer vertex-row transform (`0x08064AFC`)

## Evidence and confidence

The function starts at ROM `0x08064AFC`, image offset `0x944`, immediately
after the `0x08064A14` entry and its literal pool. The implementation in
`src/arm_rasterizer.c` follows the ARM instructions at this entry. The
caller-level record types and graphics meaning are not established.

## Observed record flow

The first argument points to a descriptor with these observed pointer fields:

| Descriptor offset | Use |
|---:|---|
| `+0x00` | Pointer to a count descriptor; signed halfword count is at `+4` there. |
| `+0x04` | Input records, each 10 bytes. |
| `+0x10` | Output records, each 16 bytes. |

Each input record has two unsigned halfwords copied together to output `+0x0C`,
then three signed halfwords at `+4`, `+6`, and `+8`. The fourth argument is a
target-value stream; the code begins reading at argument `+4` and advances by
six bytes per record. Those target values are only loaded when the signed
interpolation field is nonzero.

For every record, the routine writes three transformed 32-bit coordinates at
output offsets `+0`, `+4`, and `+8`; the packed pair at `+0x0C` is preserved.
Input, target, and output pointers advance by 10, 6, and 16 bytes respectively.
The routine uses a do/while loop, so a zero count still executes one iteration;
whether callers can supply zero is unknown.

## Transform sequence

1. If context halfword `+0x1A` is nonzero, interpolate each input coordinate
   toward its corresponding target using a signed 32-bit product and an
   arithmetic shift by 10.
2. Multiply each coordinate by the signed word at context `+0x58`. The
   arithmetic-shifted products by 10 become the three coordinate terms used
   by the matrix.
3. Accumulate the scale product and nine coefficient products with ARM `MLA`
   semantics (wrapped 32-bit addition):

   | Output accumulator | First coordinate term | Second coordinate term | Third coordinate term |
   |---|---:|---:|---:|
   | `x` | context `+0x34` × `coord_x` | `+0x40` × `coord_y` | `+0x4C` × `coord_z` |
   | `y` | context `+0x38` × `coord_x` | `+0x44` × `coord_y` | `+0x50` × `coord_z` |
   | `z` | context `+0x3C` × `coord_x` | `+0x48` × `coord_y` | `+0x54` × `coord_z` |
4. Arithmetic-shift each matrix result by 10.
5. If context halfword `+0x32` is zero, project with `x = x + z` and
   `y = y + ((x - z) >> 1)`, using the pre-projection `x`; `z` is unchanged.

After projection, the routine tracks signed minima for `x` and `y`, starting
from `0x00FF0000`. At return it stores the low halfword of `minimum_y` at
context `+0x2E` and the low halfword of `minimum_x - 64` at `+0x2C`.

## Validation limits

The source has frontend and static integration checks. The supplied disassembly
was used to preserve the multiply-accumulate direction and field/stride flow.
There is no ARM object build, numerical execution fixture, caller trace, or
rendered-output comparison yet, so this is an instruction-based source
reconstruction rather than a demonstrated runtime match.
