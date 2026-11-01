# Pass 42 — IWRAM callback family table audit

## Finding

The mixed configuration table at `0x0807D920..0x0807D9A4` contains 25
verified words in this pass's explicit inventory. It includes several pointers
to IWRAM routines surrounding the unresolved copy callback:

- `0x0807D994 -> 0x03006FAC`
- `0x0807D998 -> 0x03007034` (shared copy-like callback slot)
- `0x0807D99C -> 0x030070B8`
- `0x0807D9A0 -> 0x0300711C`

Other IWRAM targets in the same table include `0x0300717C`, `0x030071D0`,
`0x030072F8`, and `0x03007478`. This indicates the callback is part of a
larger runtime IWRAM function family rather than an isolated target. The
address differences are not function sizes, and the table alone does not show
where/how the routines are installed.

## Tooling

- Added `tools/audit_iwram_function_table.py` to verify exact table values
  against the original ROM and emit a JSON evidence report.
- Added synthetic regression tests for the table inventory, callback-slot
  corruption detection, and truncated ROM handling.
- Added `make audit-iwram-function-table ROM=...` and
  `make test-iwram-function-table` targets.

## Validation

The audit passed against the supplied original ROM. The focused test suite
passes. This is table recovery and evidence gathering, not yet a recovered
implementation of `0x03007034`.

## Matching-ROM status

No source-built candidate ROM exists. Matching remains **0% verified**. The
historical 54% source recovery figure is an unmeasured estimate and is not
changed by this table audit. The next target is the installer/loader for the
cluster of IWRAM pointers, prioritizing the group at `0x03006FAC..0x0300711C`.
