# Pass 49 — DMA3 helper recovery and register-label correction

## Input provenance

Original ROM: `BEYP70` Rev.00, 8,388,608 bytes, SHA-256
`a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce`.
The ROM is not included in this archive.

## Verified findings

- `tools/audit_dma3_transfer_08065994.py` verifies 47 Thumb halfwords beginning
  at `0x08065994`, plus all eight literal-pool values used by the routine.
- The routine's ABI is `r0 = source`, `r1 = destination`, `r2 = halfword count`.
  `r2` is truncated to 16 bits; the routine sets DMA enable with `0x80000000`
  and does not set the 32-bit transfer bit, so the count unit is halfwords.
- It writes DMA3 source `0x040000D4`, destination `0x040000D8`, and the 32-bit
  count/control pair beginning at `0x040000DC`; it polls bit 15 at
  `0x040000DE` until the transfer completes.
- The routine also temporarily writes zero to `0x04000208` and restores its
  saved halfword after DMA. It updates the word at `0x04000204` using the
  halfword at `0x03005E9C + 6`. The exact graphics rationale for these side
  effects is not established.
- Corrected `tools/audit_iwram_install_candidates.py` register names. The
  previous mapping incorrectly called `0x040000D0` DMA3SAD and `0x040000D4`
  DMA3DAD. Correct mapping: `0x040000D0` DMA2CNT_L, `0x040000D4` DMA3SAD,
  `0x040000D8` DMA3DAD, `0x040000DC` DMA3CNT_L, `0x040000DE` DMA3CNT_H.
- Re-scanning the original ROM with the corrected mapping yields 24 candidate
  literal references: 8 IWRAM-address references and 16 DMA-register references.

## Interpretation and limits

The routine is a real ROM-resident DMA3 helper with a copy-like three-argument
ABI, but it is **not** evidence of the installer for `0x03007034`. The callback
installer and callback's executable bytes remain unresolved. Literal-reference
scans are conservative candidate inventories, not proof that every hit is code.

## Reproduction

```sh
make test-dma3-transfer-08065994
make test-iwram-install-candidates
make audit-dma3-transfer-08065994 ROM=/path/to/original.gba
python3 tools/audit_iwram_install_candidates.py /path/to/original.gba \\
  --json docs/iwram_install_candidates_pass49.json
```

The test suite checks the ROM instruction fingerprint and prevents regression
in DMA register labels. The project remains a partial reconstruction, not a
matching-ROM build.
