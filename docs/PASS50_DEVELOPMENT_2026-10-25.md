# Pass 50 — input-mask call-site triage and reconstruction discrepancy

## Scope

This pass starts mapping the game's input-related code as a foundation for
later analysis of platforming controls and any potential secret-input logic.
It does not claim to have found an Easter egg.

## ROM-backed result

The original `BEYP70` Rev.00 ROM was audited at `0x080517A4`. Eight Thumb
halfwords match the expected fingerprint:

`1C01 4803 6800 4A03 1880 6800 4008 4770`

The first PC-relative literal at `0x080517B4` is `0x03000F48`. The second
PC-relative load resolves to `0x080517B8`, where the bytes are `06 B4 00 00`
(`0x000006B4`) and also appear to begin a subsequent instruction entry. This
creates a code/data-overlap ambiguity that needs to be resolved before assigning
full semantics to the routine.

## Important correction to confidence

The existing `src/input.c` reconstruction for `Input_TestMask` directly reads
`0x03005E98`. That behavior is **not supported by the instruction sequence
currently fingerprinted at `0x080517A4`**. The pass therefore does not silently
rewrite it or treat its name/semantics as settled. The new audit reports the
mismatch and preserves the unresolved literal/code overlap for further control
flow analysis.

A whole-ROM scan found raw Thumb BL-shaped pairs that decode to this address.
These are reported as candidate references only: a linear scan can encounter
embedded data, so the list is not treated as a definitive list of executed
callers. See `docs/input_mask_callers_pass50.json` for the per-site context.

## Reproduction

```sh
make audit-input-mask-callers ROM=/path/to/original.gba
make test-input-mask-callers
make test-all
make check
```

## Limitations and next steps

- No Easter egg or secret-input sequence has been identified in this pass.
- Resolve the overlapping literal/code interpretation around `0x080517B8` and
  inspect confirmed callers before changing `src/input.c`.
- Continue mapping per-frame input polling and player movement/collision paths;
  don't infer platformer-specific behavior from input helper names alone.
- This remains a partial source reconstruction; no matching-ROM build is claimed.

## Pass 51 erratum

The initial interpretation of `0x080517B8` as possibly overlapping a following
instruction entry has been superseded. Pass 51 verifies that it is the `0x6B4`
literal used by the helper at `0x080517A4`; the adjacent routine begins at
`0x080517BC` and uses a separate literal pool. See
`docs/PASS51_DEVELOPMENT_2026-10-25.md` and
`docs/input_mask_semantics_pass51.json` for the corrected audit.
