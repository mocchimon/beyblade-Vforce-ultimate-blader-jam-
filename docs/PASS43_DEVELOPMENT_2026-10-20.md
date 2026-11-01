# Pass 43 — IWRAM installation candidate audit

## Goal

Continue the unresolved installer investigation for IWRAM callback target
`0x03007034` without assuming the pointer table tells us where its code bytes
come from. This pass adds a reproducible whole-ROM inventory of Thumb
`LDR Rd, [PC, #imm]` instructions whose literal words point into the upper
IWRAM range or to DMA registers.

## Results against the supplied ROM

ROM size is 8,388,608 bytes; SHA-256 is
`a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce`.
The scan found 23 candidate literal-load references: 8 literals with values in
`0x03006000..0x03007FFF` and 15 references to DMA register addresses.

The upper-IWRAM literal references in the main code region are:

| LDR site | Literal value | Conservative interpretation |
|---|---:|---|
| `0x080506C0` | `0x03007FF8` | IWRAM address literal; usage needs caller-level tracing |
| `0x08052A9A` | `0x03007FA0` | IWRAM address literal |
| `0x08052AC2` | `0x03007FA0` | IWRAM address literal |
| `0x08052ADE` | `0x03007EC0` | IWRAM address literal |
| `0x08052B06` | `0x03007EC0` | IWRAM address literal |
| `0x0805798C` | `0x03007FFC` | matches the already documented published startup-copy destination pointer |

Two additional apparent hits at `0x0841CCF4` and `0x0842429C` occur in the
upper ROM/resource area, and are retained as lower-confidence candidates rather
than treated as code.

The DMA-register literal sites in the main code range are
`0x0805790A`, `0x08057968`, `0x08057A40`, `0x08058E9C`, `0x08059484`,
`0x08059592`, `0x0805EFF8`, `0x0805F408`, `0x0805FE40`, `0x08062560`,
`0x0806279E`, `0x08062EE0`, and `0x080659B6..0x080659BE` (the last group
references DMA3 source, destination, and control registers).

## What this tells us

- The ROM has several DMA3-related code sites worth auditing for copy ranges.
- A direct Thumb literal reference to `0x03007034` was **not** found by this
  scan. This does not exclude computed addresses, a descriptor-driven loader,
  BIOS decompression, or generated/copied code.
- The only confirmed ROM-to-IWRAM copy remains the `0x08057968` startup
  transfer to `0x03000FE0..0x030010E4`, which does not cover `0x03007034`.
- No implementation for `0x03007034` is claimed in this pass.

## Tooling and validation

Added `tools/audit_iwram_install_candidates.py`, a JSON-producing audit target,
and three synthetic regression tests. The scan explicitly labels its output as
candidate xrefs because halfword data can resemble Thumb instructions. It does
not infer source/destination/count from a DMA register reference alone.

Run:

```sh
make audit-iwram-install-candidates ROM=/path/to/original.gba
make test-iwram-install-candidates
```

## Matching-ROM status

No candidate ROM has been built or byte-compared. Matching remains 0% verified.
The historical 54% source-recovery figure remains an unmeasured estimate.
