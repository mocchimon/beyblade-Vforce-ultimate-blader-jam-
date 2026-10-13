# Independent upstream matching decomp: compatibility check (2026-10-12)

Independent source: https://github.com/marijnvdwerf/gba-beyblade-vforce

Its CMakeLists.txt contains validated fingerprints:

- US: `cd527c8c24e20e33913fc45199e64b3e6138a6e5`
- EU: `6d20a586e7bb52b4a9352bbeaec9d7be65e93369`
- debug (unvalidated): `9210a12ce01fefbf7994af2a8d51351ed82d7253`

The local user-supplied 8 MiB ROM SHA-1 is
`8d2cdd3ece0ab7d2f982b0a83e3ecb878f514a72`, which matches **none** of these.
Therefore upstream's matching-ROM status **must not** be attributed to this ROM.
The cause of the mismatch has not been established: a different dump, revision,
region, header/padding or other modifications are all hypotheses, not findings.

The upstream project is still a potentially useful independent reference for
function names, algorithms, and layout. Before importing any findings, compare
actual instruction bytes and addresses, establish relocations/variant mapping,
and preserve provenance. No upstream source was imported in this pass.

Run `make check-upstream-rom ROM=/path/to/owned.gba` to check fingerprints.
