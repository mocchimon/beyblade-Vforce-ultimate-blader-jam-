# Pass 68: signed step helper and state predicate

## Evidence

`0x080491E4` takes a signed difference in r0 and a threshold in r1. The two known calls at `0x0804908E` and `0x080490A8` pass r1=0x80. If the difference is zero, the helper returns zero. Otherwise it extracts the sign and absolute magnitude, repeatedly arithmetic-shifts r1 right by one while `abs(diff) <= (r1 << 8)`, then returns signed r1, or signed one if r1 reaches zero. For the observed positive r1=128, the resulting magnitude is 1..128. The caller shifts this step left five bits and adds it to the current fixed-point state. This is a **quantized, magnitude-dependent step**, not a conventional proportional interpolation. With a large enough difference the step is 128 (4096 raw units or 16 units in Q8); smaller differences get smaller steps, with a minimum nonzero step of 32 raw units. The routine does not clamp to the target and can overshoot by a fraction of a unit.

At `0x08049000`, the literal at `0x08049014` is `0x03000BE0`. The code loads `[0x03000BE0+0x0C]` = pointer slot `0x03000BEC`, then tests bit 0 of the halfword at pointer+0xEC. No writer of this particular bit is confirmed by this pass. The meaning of the bit and the source object remain unknown.

## Limits and next work

The audit fingerprints 45 instruction halfwords across the helper, predicate and motion-loop call sites, plus two pointer literals. The Python reference model covers ordinary deltas and the observed threshold; it is not a CPU emulator for extreme overflow cases. Next trace allocation and writes of the pointer stored at `0x03000BEC`, and inspect uses of the record halfwords at +0x48/+0x4A. No Easter egg has been identified.
