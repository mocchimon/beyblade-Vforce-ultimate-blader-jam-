# Full resource directory coverage (2026-10-12)

The original ROM's 32-entry directory at `0x08075640` contains **134 total
pointer-table entries**. The entries resolve to **111 distinct physical resource
records**. All 111 records are now represented exactly once in
`data/resource_blob_manifest.inc`. Repeated alias-bank pointers are deliberately
not duplicated in the manifest.

This independently confirms that bank 6 entry 1 at `0x0821AAF4` is a genuine
resource (inline data size `0x57`, aligned span `0x68`) rather than a sentinel.
The old comments/constants in `src/resource_data_table.c` and
`docs/RESOURCE_DATA_FINDINGS.md` have been corrected: 109 primary records plus
two unique alias records = 111 distinct records.

`tools/check_resource_coverage.py` checks all 32 directory slots, validates
bounds and 16-byte record headers, checks alias consistency, and ensures the
manifest covers every unique pointer with no extra or duplicate records.
`tests/test_resource_coverage.py` exercises missing bank-6 and alias records,
header corruption and malformed directory pointers.

Run `make check-resource-coverage ROM=/path/to/your.gba` and
`make test-resource-coverage ROM=/path/to/your.gba`. Neither command writes
resource payload bytes or includes the ROM in the source tree.

**Scope:** directory/record framing is established. The two large alias
payloads' semantic type and the code consuming their bytes are still not
identified. This is metadata and regression-test progress, not recovery of a
new gameplay routine or proof of a matching ROM build.
