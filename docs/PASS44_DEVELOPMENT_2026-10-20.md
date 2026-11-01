# Pass 44 — static copy/decompression call-site inventory

## Purpose

Continue the search for the code installer behind IWRAM callback `0x03007034`
by enumerating statically encoded Thumb `BL` calls to already identified copy,
decompression, and DMA helper routines. This adds call-site evidence without
assuming that any data transfer writes executable code.

## ROM identity

- Size: 8,388,608 bytes
- SHA-256: `a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce`

## Results

The main code scan range `0x08040000..0x08070000` yielded seven statically
encoded calls to four known helpers:

| Call site | Target | Count |
|---|---|---:|
| `0x0805070A` | `System_CpuSet` wrapper (`0x080578E4`) | 1 |
| `0x08055CA8`, `0x080572F8` | `System_LZ77UnCompWram` wrapper (`0x080578F4`) | 2 |
| `0x080505B2` | startup IWRAM installer (`0x08057968`) | 1 |
| `0x08065A76`, `0x08065A80`, `0x08065B54` | DMA3 transfer backend (`0x08065994`) | 3 |

The two LZ77 wrapper call sites prepare their source/destination arguments from
registers and loaded fields rather than loading `0x03007034` as a direct
immediate in the immediately adjacent instructions. This means a destination
range cannot be established from a short call-site scan alone. They remain
possible resource-loading paths to investigate, but no connection to the
missing callback has been proven.

The known startup installer call at `0x080505B2` still targets the existing
transfer from ROM `0x08000168` to IWRAM `0x03000FE0..0x030010E4`; it does not
cover the callback at `0x03007034`.

## Tooling

Added `tools/audit_runtime_copy_paths.py` and `make audit-runtime-copy-paths`
to emit call-site instruction windows and a machine-readable JSON report.
The audit is intentionally conservative: it scans Thumb BL pairs in the main
code range and records raw halfwords without emulating arguments.

Run:

```sh
make audit-runtime-copy-paths ROM=/path/to/original.gba
make test-runtime-copy-paths
```

Four synthetic tests pass: known-target detection, unknown-target exclusion,
short-ROM rejection, and context-window bounds. The existing full `make test-all`
suite is being rerun separately; this pass does not claim its completion until
that command exits successfully.

## Status and next step

No matching ROM was produced. Matching remains **0% verified**. The historical
54% source-recovery estimate remains unmeasured and unchanged.

Next: trace both LZ77 callers through their callers and data structures, recover
the destination allocation/ownership semantics, and compare candidate output
ranges against the IWRAM pointer table. If neither path can reach the upper
IWRAM range, continue with the DMA backend callers and resource-directory
loaders. Do not label any resource as executable code without corroborating
address/data evidence.
