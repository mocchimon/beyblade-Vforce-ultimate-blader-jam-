# Pass 54 — control-flow review of `sub_08051090`

## Objective

Continue the Pass 53 investigation of the candidate write to the runtime-base
slot at `0x03000F48`, while checking the surrounding control flow rather than
promoting a local byte-pattern match to a proven initializer.

## ROM-backed observations

The routine starts at `0x08051090`. The local decoder resolves these calls and
branch from the original ROM:

| Address | Instruction | Target / result |
|---|---|---|
| `0x08051096` | `BL` | `0x0805A444` |
| `0x0805109A` | `MOV r4, r0` | Saves the first callee's return value in `r4` |
| `0x0805109C` | `CMP r4, #0` | Tests that value |
| `0x0805109E` | `BNE` | Branches to `0x080510A8` when `r4 != 0` |
| `0x080510A4` | `BL` | `0x08057C5C`, on the zero fall-through path |
| `0x080510A8` | `LDR r3, [PC, #0x58]` | Literal at `0x08051104` is `0x03000F48` |
| `0x080510AA` | `LDR r1, [r4, #0]` | Reads the first word through `r4` |
| `0x080510AC` | `STR r1, [r3, #0]` | Writes that word through the slot address |
| `0x080510F0` | `BL` | `0x08051120` |

The BNE at `0x0805109E` targets `0x080510A8`, skipping the fallback call
when the first callee returns a nonzero value. Both paths converge at the slot
load/store sequence. This sharpens the Pass 53 finding: the store is not
unconditional with respect to earlier setup, and its source depends on the
value held in `r4`.

## Important unresolved edge case

On the `r4 == 0` path, the code calls `0x08057C5C`, whose first four halfwords
are `B40F B004 4770 0000`. This local byte pattern resembles a short stack
adjustment/return stub, but this pass does not establish the function's intended
semantics or explain why execution subsequently performs `LDR r1, [r4]`. Do not
assume this path is reachable during normal startup, and do not claim the slot
initializer is fully understood until the return-value provenance and runtime
state are verified.

## Artifacts

- `tools/audit_sub_08051090.py`: bounded Thumb local decoder for BL targets,
  conditional branch targets, and literal references in this routine.
- `docs/sub_08051090_control_flow_pass54.json`: report generated from the
  supplied original ROM, including its SHA-256 fingerprint and callee bytes.
- `tests/test_sub_08051090_audit.py`: synthetic checks for BL decoding, literal
  PC alignment, invalid BL input, and malformed ROM size.

The tool is deliberately a local decoder, not a full disassembler or control-
flow proof. No Easter egg or secret input sequence is claimed in this pass.
