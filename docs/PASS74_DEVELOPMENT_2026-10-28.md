# Pass 74 — conservative Thumb entry discovery

## ROM-wide candidate inventory

- Input SHA-256: `a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce`; matches the original ROM: `True`.
- Full 8 MiB word-aligned scan: **1547** odd-valued words targeting the ROM.
- Of those, **161** point to a Thumb `PUSH {…,LR}` pattern, spanning **79** distinct targets.
- Linear Thumb BL-pattern scan of the first **524,288** bytes: **4286** patterns.
- **3** candidate entry targets occur in both scans.

## Caution about false positives

These are candidates, **not verified functions**. A word can resemble a ROM pointer by coincidence, a halfword can resemble `PUSH` by coincidence, and an instruction-shaped `BL` can occur inside a literal pool or asset. Linear scanning cannot distinguish those cases. No source-level or byte-level reconstruction coverage is credited to these results.

## Reproduction

```bash
python3 tools/scan_thumb_entry_candidates_pass74.py /path/to/game.gba --json docs/thumb_entry_candidates_pass74.json
python3 -m unittest discover -s tests -p 'test_thumb_entry_candidates_pass74.py' -v
```

## Next pass

Use recursive control-flow traversal from known entry points, branch destinations, and verified callsites, with explicit ARM/Thumb state tracking. Mark literal pools and undecoded regions separately. Validate candidate functions against callers and control-flow termination before crediting code coverage.

## Progress

Estimated 1:1 reconstruction completion remains **under 5%** (qualitative). The 79 entry candidates are not a percentage of completed functions. A defensible numeric progress percentage requires an exhaustive, validated code/data map plus source and asset reconstruction status.
