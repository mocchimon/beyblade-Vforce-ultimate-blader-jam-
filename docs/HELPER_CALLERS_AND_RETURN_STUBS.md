# Batch investigation: caller cross-references and return stubs

ROM: BEYP, 8 MiB; no ROM bytes are included in the project archive.

## Independent task A: Thumb BL cross-reference scan

`tools/audit_helper_callers.py` scans halfword-aligned Thumb-1 BL encodings with signed 23-bit PC-relative displacement. These are *candidate* callers: ROM data can mimic Thumb opcodes, and indirect calls (`BX`/function tables) are not covered. The scanner also searches word-aligned 32-bit references to the counter state.

| Target | Candidate direct BL sites |
| --- | ---: |
| `0x08057B54` two-word writer | 0 |
| `0x08057B78` counter reset | 0 |
| `0x08057B88` counter increment | 0 |
| `0x08057C64` IWRAM reader | 62 |
| `0x08057C70` VCOUNT reader | 0 |

The `0x03000EE0` address occurs as an aligned literal at exactly `0x08057B84` and `0x08057B94`, inside the two counter helpers. No direct BL to either helper was found. This does **not** mean the routines are unused: function pointers, other instruction forms, and RAM-copied code remain possible. Run `make audit-helper-callers ROM=...` to reproduce the full candidate list. Unit tests cover forward/backward BL, malformed instructions, synthetic ROM, and corrupted game header.

## Independent task B: ROM-verified return stubs

Nine Thumb entries at `0x08057B5C`, `0x08057B60`, `0x08057B68`, `0x08057B6C`, `0x08057B70`, `0x08057B74`, `0x08057B98`, `0x08057B9C`, `0x08057BA0` contain `0x4770` (`bx lr`) followed by alignment halfword `0x0000`. The entry `0x08057B60` is referenced in runtime vector slot `0x0807D97C` as Thumb pointer `0x08057B61`. Source is in `src/runtime_return_stubs.c` and byte tests in `tests/test_runtime_return_stubs.py`.

The existing `0x08057B64` return stub is in `src/runtime_diagnostics.c` and is intentionally not duplicated.

## Limitations

No installer for unresolved IWRAM targets has been identified, no callback body is claimed recovered, and a matching ROM is not built. Source recovery estimate remains 54%.
