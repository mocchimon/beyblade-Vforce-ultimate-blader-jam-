# Full 32-slot resource-directory audit (2026-10-11)

Source: user-provided original 8 MiB BEYP ROM, directory at `0x08075640`.

This pass extends the 110-record manifest verifier to inspect all **32 directory slots**.
Each slot contains a pointer-table begin/end pair, with four-byte entries.

## Verified findings

- Slots 0–5 contain 16, 19, 19, 13, 32 and 8 pointers respectively.
- Slot 6 contains **two** pointers, whereas the existing manifest describes only its first record. The second is at `0x0821AAF4`. It remains unclassified and should not be silently treated as verified manifest coverage.
- Odd slots 7–31 alias the same single-entry pointer table at `0x08074DCC..0x08074DD0`, pointing to `0x0807DCA4`.
- Even slots 8–30 alias `0x08074DD4..0x08074DD8`, pointing to `0x080BE234`.
- All 110 manifested record headers contain the word pattern `{0, data_size, 0, 0}` at offsets `+0,+4,+8,+12`. These reserved zero fields are now verified explicitly.
- No claim is made that these two alias targets are ordinary graphics blobs, or that every pointer in slot 6 is accounted for.

## Reproducibility

`make audit-resource-directory ROM=/path/to/your.gba`

`make test-resource-directory ROM=/path/to/your.gba`

The test intentionally corrupts a reserved header word, directory end pointer and manifested record pointer, checking that each error is caught. Only metadata and assertions are stored; the ROM is not copied into the project.
