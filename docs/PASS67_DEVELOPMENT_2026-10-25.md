# Pass 67 — State motion-field consumers

## Findings grounded in ROM instructions

This pass follows the four fields written by `0x08049040`. The state base is `0x03000650`.

- `+0x84` (`0x030006D4`) and `+0x88` (`0x030006D8`) behave as current values.
- `+0x8C` (`0x030006DC`) and `+0x90` (`0x030006E0`) behave as targets.
- `0x08049040` shifts the two target arguments left by eight and seeds the current values from signed halfwords at source record offsets `+0x48` and `+0x4A`, also shifted left by eight.
- The routine at `0x08049078` subtracts each current value from its target, calls `0x080491E4` with `0x80`, shifts the returned adjustment left by five, and adds it to the current value. It then arithmetic-shifts the current values right by eight and writes the low halfwords back to source record `+0x48/+0x4A`.
- The helper at `0x0804901C` clears all four current/target fields. It is called at `0x08049460`.
- The descriptor follow-up routine at `0x080495C8` calls predicate `0x08049000` at `0x08049654` and field writer `0x08049040` at `0x0804966A` on the conditional path.

## Interpretation limits

The code supports calling this a smoothed/interpolated pair of signed coordinate-like fields. It does **not** establish whether they represent screen coordinates, world coordinates, a visual effect, or a particular animation. The precise behavior of the adjustment routine `0x080491E4` and the semantics of the flag read through pointer slot `0x03000BEC` remain open. No write to that flag bit has yet been attributed confidently, and no Easter egg trigger is established.

## Reproducible checks

Run:

```sh
python3 tools/audit_state_motion_field_consumers_pass67.py "/path/to/original.gba" --json docs/state_motion_field_consumers_pass67.json
python3 -m unittest discover -s tests -p 'test_state_motion_field_consumers_pass67.py' -v
```

The audit verifies the original ROM fingerprint and selected Thumb instructions/call sites. The original ROM is not redistributed in this archive.
