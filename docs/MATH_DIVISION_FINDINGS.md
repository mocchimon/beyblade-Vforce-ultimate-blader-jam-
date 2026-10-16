# Signed and unsigned division recovery (2026-10-15)

Two compiler-runtime routines in the supplied BEYP ROM are now represented in
C as `Math_DivideSigned` and `Math_DivideUnsigned` in `src/math_runtime.c`.

- `0x080660A8` normalizes signed operands, performs a scaled subtract/shift
  division, and negates the quotient when the operand signs differ.
- `0x080661E4` performs the corresponding unsigned quotient operation.
- Both zero-divisor paths converge on `0x0806613C` and return zero.
- `0x0806625C`, already reconstructed as `Math_ModuloUnsigned`, computes the
  matching unsigned remainder.

The recovered source uses unsigned magnitude arithmetic so the signed path does
not invoke C signed-overflow behavior for `INT32_MIN`. The `__aeabi_uidiv`
definition is compiler ABI support that delegates to the unsigned helper; it is
not claimed as an original game symbol. `ResourceDescriptor_Init` now calls the
signed helper, and the runtime object-table sizing path calls the unsigned
helper directly instead of leaving a compiler division import.

`tests/test_math_runtime.c` covers all numerator/divisor pairs in the small
range 0..2047 by 0..256, plus 32-bit edge cases and signed combinations. The
test source is ready for the project's `make test-math` target. This archive
was prepared in an environment without a C compiler, so that native test and
ARM object compilation still need to be run with the project's toolchain.

The C is a behavior-level reconstruction, not a byte match for either ROM
routine.
