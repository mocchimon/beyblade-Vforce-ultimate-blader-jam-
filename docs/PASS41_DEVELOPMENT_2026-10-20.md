# Pass 41 — runtime-image bounds audit

## Goal

Continue toward a source-built matching ROM by resolving whether the already
identified ARM runtime image at ROM `0x080641B8` can account for the outstanding
IWRAM targets.

## Result

The known image occupies ROM `[0x080641B8, 0x08064EDC)`, exactly `0xD24`
bytes. Its SHA-256 in the supplied original image is
`9fe54fc4f884e226ba5912fe0a5ee219722d577b84e799f8ec74cac482ee8eed`.

Under the previously discussed **hypothetical, unproven** runtime base
`0x030061B8`, targets `0x0300646C` and `0x0300682C` would land at image offsets
`0x2B4` and `0x674`, respectively. However:

- `0x03006FAC` would land at offset `0xDF4`, `0xD0` bytes beyond the image.
- `0x03007034` would land at offset `0xE7C`, `0x158` bytes beyond the image.

This definitively rules out those latter two targets being contained in this
`0xD24`-byte image **if** that base hypothesis is used. It does not prove the
base hypothesis, nor does it identify the real installer/source. The two render
targets fitting the range is only a range-consistency observation, not proof that
the image is loaded at `0x030061B8`.

## Tooling added

- `tools/audit_runtime_image_bounds.py` performs explicit ROM-bound checks,
  hashes the image slice, and reports target offsets/range membership while
  marking the assumed base as unproven.
- `tests/test_runtime_image_bounds.py` covers image bounds, target range math,
  and truncated input rejection.
- `make audit-runtime-image-bounds ROM=/path/to/original.gba`
  runs the audit; `make test-runtime-image-bounds` runs its tests.
- `docs/runtime_image_bounds_pass41.json` records the result against the supplied
  original ROM for reproducibility.

## Validation

- New runtime-image bounds tests: 3 passed.
- Runtime-copy callback verifier against the supplied original ROM: passed.
- Collision-owned-segment verifier against the supplied original ROM: passed.
- This pass does not claim a recovered implementation for `0x03007034` and does
  not produce a candidate ROM. Matching-ROM progress remains 0% until a genuine
  source-built candidate can be linked and byte-compared.

## Next target

Find another installer or resource-loading path whose destination range covers
`0x03006FAC` / `0x03007034`, or recover the descriptor that selects a different
runtime image. Do not alias either target to nearby ROM code based on address
proximity alone.
