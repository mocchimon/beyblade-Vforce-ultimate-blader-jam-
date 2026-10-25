# Pass 58 — trace writes to runtime-context offset `+0x6B4`

## Finding

The adjacent Thumb routine at `0x080517BC` is a setter, not just a helper with an unresolved role. Its six verified halfwords load the pointer slot `0x03000F48`, dereference it, add literal offset `0x6B4`, and store `r0` to that address:

```c
*(u32 *)(*(u32 *)0x03000F48 + 0x6B4) = value;
```

Two direct BL callsites were decoded:

- `0x08045A4A`: the immediately preceding instruction loads `r0 = 1`.
- `0x08045A5C`: two branch paths converge here; one loads `r0 = 1`, the other `r0 = 4`.

This demonstrates runtime writes of `1` and `4` to the field, beyond Pass 56's initializer clearing it to zero. It does not prove what those values mean or when each path executes at runtime. The surrounding code has a switch-like indirect jump table and still needs fuller control-flow naming.

## Validation

- Audit fingerprints the setter's six Thumb halfwords and both literals.
- Audit decodes both callsite BL targets to `0x080517BC`.
- Five synthetic-ROM regression tests cover success, changed instruction, changed offset literal, corrupted callsite, and malformed odd-length input.
- Expected original ROM SHA-256: `a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce`.

## Limits / next step

No Easter egg or secret-input sequence is identified. Next, recover the switch-like routine around `0x08045A00` and map the state/event values that lead to these setter calls, then compare those paths with verified reads through the `+0x6B4` mask helper.
