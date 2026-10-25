# Pass 59 — five-way context selector dispatch

## Confirmed from original ROM

The Thumb code at `0x08045A08` loads a 32-bit selector from `[r6 + 0x4B4]`. Values above four branch to the shared epilogue at `0x08045A76`. Values `0..4` index a five-entry 32-bit ROM jump table at `0x08045A34`, followed by `MOV PC,r0`.

| Selector | Target | Observed actions |
|---:|---:|---|
| 0 | `0x08045A48` | writes `1` to runtime-base `+0x6B4`; calls `GameState_SelectContext(0x19)` |
| 1 | `0x08045A5A` | writes `4` to runtime-base `+0x6B4`; calls `GameState_SelectContext(0x0F)` |
| 2 | `0x08045A56` | writes `1` to runtime-base `+0x6B4`; calls `GameState_SelectContext(0x0F)` |
| 3 | `0x08045A70` | calls `GameState_SelectContext(0x0C)` |
| 4 | `0x08045A68` | calls `GameState_SelectContext(0x28)` |

The setter values previously discovered in Pass 58 are now placed in a verified control-flow context. The selector offset and context arguments are factual; their game-specific meanings are not yet known. The order in the jump table is non-monotonic for cases 1–4, so it should be preserved exactly.

## Validation

`tools/audit_state_switch_pass59.py` fingerprints the dispatch instructions, offset/table literals, all five jump-table targets, and representative case instructions against the supplied ROM. `tests/test_state_switch_pass59.py` has five tests: original ROM success, dispatch mutation, jump-table mutation, case-argument mutation, and malformed odd-length image.

Expected ROM SHA-256: `a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce`.

## Limits and next step

No Easter egg is established. Next, cross-reference reads of `runtime_base + 0x6B4` through `0x080517A4`, and inspect how the enclosing context field at `+0x4B4` is written. This can determine whether the selector represents a general state, a UI mode, or another dispatch variable without guessing from the numeric values.
