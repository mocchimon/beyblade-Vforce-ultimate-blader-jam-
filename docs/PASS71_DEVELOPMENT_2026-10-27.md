# Pass 71 — title-screen / pause-menu secret-input triage

The user clarified that the Easter egg is activated by particular inputs in the
pause menu or title screen. This changes the investigation priority: the next
passes focus on menu input paths rather than unrelated state and rendering
subsystems.

## New ROM-backed lead

The contiguous Thumb block at `0x08043D42` checks three masks through
`Input_TestMask` (`0x080517A4`): `1` at call site `0x08043D4A`, `0x100` at
`0x08043D5E`, and `4` at `0x08043D70`. Conditional paths pass arguments
`0x12`, `0x11`, or `0x13` to `0x08049250`. Nearby branches invoke the state
history helper `0x080490FC` with `0x0A` and `0x09`.

This is a strong candidate for a menu/UI input handler because it has multiple
input-mask checks followed by discrete state/event arguments. The user's clue
makes it a priority for call-context tracing. The code region has not yet been
proven to be specifically the title screen or pause menu, and the arguments are
not assigned semantic names. The three mask values are reported numerically;
button labels should be grounded in the initialized input mapping.

## Verification

`tools/audit_title_pause_input_triage_pass71.py` checks the exact 8 MiB ROM and
33 Thumb halfwords at `0x08043D42`. The tests check the ROM fingerprint, mask
and argument inventory, mutation rejection, and size rejection.

Run:

```sh
python3 tools/audit_title_pause_input_triage_pass71.py "/path/to/original.gba" --json docs/title_pause_input_triage_pass71.json
python3 -m unittest discover -s tests -p 'test_title_pause_input_triage_pass71.py' -v
```

## Next investigation

1. Trace callers and dispatch context around `0x08043D20` to identify whether
   this is a title-screen, pause, or shared menu handler.
2. Inspect `0x08049250` and the state/event targets selected by `0x11`, `0x12`,
   and `0x13`.
3. Identify which runtime mask bits correspond to physical buttons from the
   control-state setup, then examine sequence/timing logic in the menu paths.
4. Search the candidate paths for ordered multi-input comparisons, hidden
   counter increments, and branches reachable only under unusual input states.

No secret sequence or Easter egg trigger is claimed yet.
