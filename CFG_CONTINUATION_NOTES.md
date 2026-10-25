# CFG continuation: conditional SWI and indirect interworking calls

- Conditional ARM SWI now preserves the non-taken fallthrough path.
- ARM and Thumb BLX(register) are recognized as indirect interworking calls, and the tracer follows the possible return continuation without guessing the callee ISA or destination.
- BX remains an indirect transfer and is not followed into unknown target code.
- Three regression tests cover the changes. `make test-all` passed.

This is tooling correctness work, not verified decompiled gameplay code. Source recovery estimate remains 54% pending ROM-backed analysis.

# Pass 43: IWRAM installer candidate inventory

Added `tools/audit_iwram_install_candidates.py` to inventory Thumb PC-relative
literal loads pointing at upper-IWRAM address literals and DMA registers. The
supplied ROM scan finds 23 candidates (8 IWRAM-address literals, 15 DMA-register
references); no direct literal reference to `0x03007034` appears. This narrows
only direct-literal hypotheses and does not rule out computed/resource-driven
installers. See `docs/PASS43_DEVELOPMENT_2026-10-20.md`.

# Pass 44: copy/decompression call-site inventory

Added `tools/audit_runtime_copy_paths.py` to inventory direct Thumb BL callers
of the BIOS CpuSet wrapper, LZ77 WRAM decompression wrapper, known startup
IWRAM installer, and DMA3 transfer backend. Against the supplied ROM it found
7 calls in the main-code scan range, including two LZ77 wrapper callers at
`0x08055CA8` and `0x080572F8`. The call-site register values are field-derived;
this pass does not establish that either writes the callback target `0x03007034`.
See `docs/PASS44_DEVELOPMENT_2026-10-20.md`.

# Pass 46: startup DMA installer fingerprint

The Thumb routine at `0x08057968` is now verified against 21 exact halfwords
and five literal words. It programs DMA3 with source `0x08000168`, destination
`0x03000FE0`, a count expression yielding `0x49` words, and publishes the
startup IWRAM base through `0x03007FFC`. This small startup transfer does not
explain the later callback table around `0x03007034`. See
`docs/PASS46_DEVELOPMENT_2026-10-20.md` and
`tools/audit_startup_iwram_installer.py`.
