# Runtime dispatch consolidation

The original Thumb listing `asm/runtime/resource_runtime_cluster.thumb.s` shows
`0x08062B50` calling `0x08062AB4`, which looks up a runtime entry by serial
and clears its status at offset `+0x16`. This is the behavior reconstructed as
`RuntimeEntry_Deactivate` in `src/runtime_entries.c`.

The pending-service implementation now calls `RuntimeEntry_Deactivate` by
symbol instead of calling the hard-coded ROM address in Thumb state.
`RuntimeScript_Stop` delegates to `sub_08062B50` rather than duplicating its
loop. The dynamic table-pointer reload behavior is retained.

Host tests use a stub `RuntimeEntry_Deactivate`; the ROM implementation is
compiled separately. This establishes source-level linkage and behavioral
regression coverage, **not** a byte-matching ROM build. Source recovery
remains estimated at 54% until measured against the original ROM.
