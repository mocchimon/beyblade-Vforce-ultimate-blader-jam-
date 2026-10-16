# Directory pointer cross-reference inventory (2026-10-14)

`tools/scan_directory_xrefs.py` scans the supplied original ROM for aligned
32-bit occurrences of every unique table pointer and signed-index descriptor
address in the 32-slot resource directory at `0x08075640`.

It separates occurrences **inside the directory** (expected table entries)
from occurrences **outside the directory** (candidates for further study),
reports which slots share each target, and emits machine-readable JSON.

Run `make scan-directory-xrefs ROM=/path/to/original.gba`.
Run `make test-directory-xrefs` without a ROM using synthetic fixtures.

**Interpretation limits:** A raw 32-bit pointer occurrence may be ordinary
asset data, a pointer table, or a literal pool. It does not establish a code
reference or a store instruction. Since the original index descriptors are
ROM-backed, modifying those ROM bytes is not evidence of gameplay-time index
mutation. Before claiming a runtime setter, verify the relevant instruction
sequence, address space, and actual writes to RAM-backed state.

This pass improves static triage and tests; it does not recover new gameplay
functions, change the 54% estimate, or establish a matching ROM build.
