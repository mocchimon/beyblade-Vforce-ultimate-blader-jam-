# Pass 51 — input-mask literal/control-flow clarification

## Scope

Pass 51 resolves the local code/data interpretation around the input-mask
helper at `0x080517A4`. It does not claim an Easter egg or a secret-input
sequence has been found. The focus is a ROM-backed correction to Pass 50 and a
more faithful C representation of the helper's memory access.

## Verified ROM behavior

The original 8 MiB `BEYP70` Rev.00 ROM matches these instruction halfwords:

- `0x080517A4`: `1C01 4803 6800 4A03 1880 6800 4008 4770`
- `0x080517BC`: `4902 6809 4A02 1889 6008 4770`

The Thumb literal loads resolve as follows:

| Instruction | Literal address | Literal value | Role |
|---|---:|---:|---|
| `LDR` at `0x080517A6` | `0x080517B4` | `0x03000F48` | runtime-base pointer address |
| `LDR` at `0x080517AA` | `0x080517B8` | `0x000006B4` | byte offset into runtime base |
| `LDR` at `0x080517BC` | `0x080517C8` | `0x03000F48` | runtime-base pointer address |
| `LDR` at `0x080517C0` | `0x080517CC` | `0x000006B4` | byte offset into runtime base |

This gives the following pseudocode for the helper at `0x080517A4`:

```c
return *(uint32_t *)(*(uint32_t *)0x03000F48 + 0x6B4) & mask;
```

The adjacent function at `0x080517BC` stores its input to the same base-plus-
offset location:

```c
*(uint32_t *)(*(uint32_t *)0x03000F48 + 0x6B4) = value;
```

## Pass 50 correction

Pass 50 described the word at `0x080517B8` as possibly overlapping a subsequent
instruction entry. The local control flow and literal-load calculations now
show that `0x080517B8` is the `0x6B4` literal for the helper at `0x080517A4`;
the adjacent function begins at `0x080517BC` and uses a duplicate literal pool
at `0x080517C8`/`0x080517CC`. The local overlap hypothesis is therefore not
supported and should be considered superseded by this pass.

`src/input.c` now models the ROM's pointer indirection and offset rather than
hard-coding `0x03005E98` in `Input_TestMask`. The fixed address may be the
initialized effective address if the runtime pointer at `0x03000F48` has the
expected value, but this pass does not assume or independently prove that value
at every call site.

## Reproduction

```sh
make audit-input-mask-semantics-pass51 ROM=/path/to/original.gba
make test-input-mask-semantics-pass51
make test-all
make check
```

The audit emits `docs/input_mask_semantics_pass51.json`, including the ROM
SHA-256, fingerprints, literal addresses, and confidence limits.

## Validation performed

- ROM fingerprint and literal audit passed against the supplied original ROM.
- Three new synthetic-ROM unit tests passed.
- The 62 C source files compiled for ARM7TDMI.
- The full existing regression suite is recorded separately in the pass package
  validation notes after execution.

## Remaining questions

- Establish the runtime value and initialization path for the pointer at
  `0x03000F48` before claiming the fixed address `0x03005E98` is equivalent.
- Trace confirmed callers into per-frame input processing and distinguish input
  polling from event/state helpers.
- No secret input, Easter egg, or gameplay behavior has been identified by this
  local helper analysis.
- This remains a partial reconstruction; no matching-ROM build is claimed.
