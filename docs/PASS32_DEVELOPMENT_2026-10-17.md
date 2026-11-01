# Development pass 32 — 2026-10-17

## Child display-state helper cluster

Added source for four adjacent Thumb entries in
`src/runtime_display_state_helpers.c`:

- `0x0805B284` writes word fields at `+0x08` and `+0x04`, then the low byte of
  its fourth argument at `+0x0C`.
- `0x0805B28C` and `0x0805B290` write the low argument byte at `+0x0D` and
  `+0x0C`, respectively.
- `0x0805B294` returns `base + ((index & 0x03FF) << 5)`.

The larger routine at `0x0805B2A4` calls the address helper four times. Its
four direct Thumb `BL` instructions all resolve back to `0x0805B294`, using
four halfword indices. The new ROM verifier checks 22 Thumb halfwords across
the helper bodies and four call edges, plus the `0x000003FF` literal. The
helper names stay tied to observed offsets; higher-level record semantics and
the containing routine remain open.

## IWRAM operation target at `0x03006FAC`

Added a reproducible whole-ROM pointer scan. The only byte-aligned occurrence
of the target word is the configuration entry at `0x0807D994`. The address of
that table slot occurs 34 times in ROM; these are reference candidates and
have not been fully decoded. The verified Thumb `BX r3` thunk transfers to
the even IWRAM pointer in ARM state. Existing copy-site audits still do not
locate the code image or an installer for `0x03006FAC`, so the callback
behavior and producer remain unresolved. The audit explicitly does not treat
pointer uniqueness as proof that compressed or generated code is absent.

## Verification and remaining limits

- ROM verifiers for passes 26–32 all passed. Pass 32 matched 22 Thumb
  halfwords, four call destinations, and one mask literal across five ranges.
- The complete ROM-enabled Python suite passed **107 tests with zero skips**.
- Libclang parsed **55 C translation units** for ARM7TDMI with zero
  diagnostics. This is a frontend syntax check, not object generation.
- No ARM object files, relocatable link, candidate ROM, or matching-ROM
  comparison was produced. This host has no `make`, `clang`, or ARM GCC/linker
  commands available, and the original section/link layout is still missing.
- The historical source-recovery estimate remains **about 54%**. It is rough
  and unmeasured; no denominator or measured coverage counter was introduced.
  Matching-ROM progress remains **0%**.
