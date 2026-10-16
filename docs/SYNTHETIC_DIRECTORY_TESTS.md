# ROM-free directory regression tests (2026-10-14)

`make test-directory-synthetic` constructs a minimal synthetic 32-slot directory
in memory. Alternating slots share one of two ROM-backed signed-halfword
index descriptors, pointer tables and resource records. The test exercises
`trace_directory_runtime.trace` and `audit_directory_descriptor_storage.audit`
without distributing or needing original game bytes.

Negative tests cover out-of-range signed index, RAM descriptor pointer,
nonzero resource-header sentinel, and resource payload extending beyond ROM.

This validates the directory parsers' behavior on a controlled fixture, **not**
that the game's real resource selection changes at runtime or that the
reconstructed implementation matches original code. For the real BEYP ROM,
continue using the ROM-dependent audit and directory-runtime tests.
