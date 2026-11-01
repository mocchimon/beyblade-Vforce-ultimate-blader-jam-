# Pass 73 — conservative full-ROM inventory

ROM: 8,388,608 bytes; SHA-256 `a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce`; known ROM match: True.

All 2,048 pages of 4,096 bytes were inspected and hashed. Page classes: {'unresolved': 1883, 'all_zero_fill': 165}.

**Verified full-page fill coverage: 8.057%.** This measures only entirely zero or entirely 0xFF pages, **not** decompilation progress. All other pages are unresolved, even if entropy is high. No code/data/asset boundaries are inferred from entropy.

**Estimated overall 1:1 reconstruction: under 5% (qualitative, not byte-verified).**

Next: control-flow-based function discovery, literal-pool recognition, and ROM-range ownership for assets and tables.
