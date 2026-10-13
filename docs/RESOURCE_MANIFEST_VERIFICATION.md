# Resource manifest verification against the original ROM

The resource manifest is checked against the original GBA ROM without exporting any copyrighted ROM bytes. Run:

```sh
make verify-resources ROM=/path/to/your/owned.gba
make test-resource-manifest ROM=/path/to/your/owned.gba
```

On the verified 8 MiB `BEYP` revision-0 image, the checker validates **110 manifest records across 9 banks** (banks 0–6 contain the 108 primary records; banks 7–8 contain two alias-reachable records). The checks compare each manifest pointer with the actual bank pointer table, each record's header `+0x04` data size, the 4-byte-aligned record span, the ROM bounds, and each adjacent pointer boundary. Tests deliberately corrupt a header size and a pointer in an in-memory ROM copy and require detection.

This verifies metadata consistency, **not** that resource payloads are understood, that rendering is correct, or that a matching ROM can be built. The manifest itself is metadata-only. The checker does not save ROM bytes.
