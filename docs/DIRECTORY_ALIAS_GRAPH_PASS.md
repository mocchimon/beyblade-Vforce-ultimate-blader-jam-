# Directory alias graph pass (2026-10-14)

Added `tools/analyze_directory_aliases.py`, a read-only ROM-backed report over all 32 directory slots. It distinguishes four separate sharing relationships: descriptor address, pointer-table base, selected pointer-entry address, and selected resource record. These are **not interchangeable**; shared descriptors may be used with different tables.

Run `make analyze-directory-aliases ROM=/path/to/original.gba` for a summary JSON report. Run `python3 tools/analyze_directory_aliases.py /path/to/original.gba` for per-slot details. No original ROM data is included in this repository.

`make test-directory-alias-analysis` validates the grouping logic using a synthetic ROM buffer, including forced alias sharing and the case where a descriptor is shared but tables differ. This is infrastructure evidence only: it does not identify resource types, prove runtime selection behavior, or establish ROM matching.

Next step: with the original ROM supplied locally, inspect the resulting descriptor/table cross-product groups and disassemble the code that mutates signed selection indices; then connect observed selections to resource consumers.
