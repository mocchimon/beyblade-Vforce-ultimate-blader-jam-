# Pass 46 — startup IWRAM installer fingerprint

## Verified from the supplied ROM

`tools/audit_startup_iwram_installer.py` checks 21 Thumb halfwords at
`0x08057968` and five adjacent literal values. It verifies the routine's
DMA3 setup constants:

- DMA3 register block base literal: `0x040000D4`
- ROM source: `0x08000168`
- IWRAM destination: `0x03000FE0`
- endpoint constant used by the count expression: `0x0800026C`
- count expression: `((endpoint - source) + 0x20) >> 2`, yielding `0x49` words
- control word assembled by the routine: `0x84000049`
- published IWRAM-base slot: `0x03007FFC`

This is a concrete, exact fingerprint of the startup installer. The destination
`0x03000FE0` is far below the later callback region around `0x03007034`; this
routine does not by itself explain the runtime function table at `0x0807D920`.
The audit intentionally records the count expression and constants rather than
claiming hardware execution was emulated.

## Validation

- Exact instruction/literal audit passes against the supplied original ROM.
- Four unit tests cover the expected fingerprint, instruction corruption,
  literal corruption, and short-ROM rejection.
- The audit emits JSON to `build/reports/startup_iwram_installer_pass46.json`.

Run:

```sh
make audit-startup-iwram-installer ROM=/path/to/original.gba
make test-startup-iwram-installer
```

## Matching-ROM status

No source-built candidate ROM was generated. The historical 54% source recovery
estimate remains unmeasured and unchanged; byte-for-byte matching remains 0%
verified. Fixed placement, original toolchain settings, unresolved code/data,
and final container/header details remain blockers. The next target is a
separate writer/loader for the upper-IWRAM callback table.
