# Resource directory reference trace (2026-10-12)

This pass inventories **aligned, exact 32-bit pointer occurrences** in the original ROM. It does not infer a call graph from data references alone.

- Directory base `0x08075640` has one aligned direct ROM reference at `0x0804AF50`. The surrounding code/literal-pool owner is the next target for instruction-level investigation.
- Odd alias pointer-table location `0x08074DCC` has 14 aligned occurrences in the directory region, beginning `0x08075678` and ending `0x08075748`.
- Even alias pointer-table location `0x08074DD0` has 14 aligned occurrences in the directory region, beginning `0x0807567C` and ending `0x0807574C`.
- Odd alias record `0x0807DCA4` is pointed to at `0x08074DCC`.
- Even alias record `0x080BE234` is pointed to at `0x08074DD4`. The word at `0x08074DD0` is `0xFFFF0000`, so this table must **not** be interpreted as an identical one-word structure to the odd table.
- Bank-6 second record `0x0821AAF4` has one aligned reference at `0x08075200`; its 87 data bytes are all `0xE4`.

The resource directory references the **alias table addresses**, not the resource payload addresses directly. The recovered pointer chain is a reliable structural finding, but the consumer's control flow and semantic payload types remain unresolved.

Run `make trace-resource-references ROM=/path/to/your.gba` to repeat the audit. `make test-resource-references` tests the reference scanner with synthetic ROM buffers. This tool only reads ROM bytes; it does not copy payloads into the project.
