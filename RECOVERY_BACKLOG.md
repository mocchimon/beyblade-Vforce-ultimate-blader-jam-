# Unresolved linkage recovery backlog

Generate the current inventory with `make triage-unresolved`; its machine-
readable report is written to `build/reports/unresolved_triage.json`. Build
reports are regenerated artifacts and are not included in this source archive.
This is an inventory, **not** ROM matching.

## Prioritization

1. **Address-named game routines:** inspect `sub_08...` callers in a freshly
   generated linkage report, then compare against original ROM disassembly.
   Assembly filename hits are only filename clues, not proof of function identity.
   `RuntimeObject_UpdateRecordArray` (`0x08050A74`) and
   `RuntimeObject_UpdateRecord` (`0x08058F18`) now replace the address-named
   gap in the caller at `0x080494F4`; exact local call targets are checked by
   `make verify-runtime-object-records ROM=...`. `RuntimeObject_InitializeEntryTable`
   (`0x08050AA0`) and the byte lookup at `0x08063AC4` are also recovered and
   checked by `make verify-runtime-object-selection ROM=...`. The builder's
    callees at `0x080609E8`, `0x08060A04`, `0x08060B8C`, and `0x080611B4` now
    have source definitions. Check them with
    `make verify-resource-node-selection ROM=...`. Its final dispatcher at
    `0x08061684` remains unresolved; the
    earlier record updater's callees at `0x080596D0` and `0x08058F84` also
    remain open.
2. **Resource tables:** `ResourceTable_Generate`, `Transform`, and `Combine`
   form a missing group; verify input/output layout before implementing.
3. **Rasterizer:** `ArmRaster_ProcessPrimitiveEdges`, `ArmRaster_DrawRows`,
   `ArmRaster_ApplyVertexParameters`, `ArmRaster_TransformVertexRows`, and the two sample emitters now have C
   behavior reconstructions. Compare their output against rendering fixtures
   before assigning broader meaning, and recover the dynamic entry callers.
4. **Error and runtime services:** `ResourceNode_ValidateActiveList` and the
   record-manager diagnostics now bind to ROM-confirmed return-only entries.
   Former `FatalError` calls were also mapped to `sub_08057B60` or
   `sub_08057C5C`; keep auditing the unresolved-symbol report for remaining
   address-named helpers. `RuntimeRange_Release` has a C implementation.
5. **ARM/Thumb and ROM build:** regenerate ARM objects, run `make partial-link`,
   and recover the original section layout and toolchain before attempting a
   candidate `.gba`.

The source-level name mismatch at `0x08050388` is resolved:
`GameState_FramePrepare` calls `RuntimeRecord_Clear`, whose writes preserve
the alternate-heap descriptor at manager `+0x00`. The initializer and updater
at `0x08050398`/`0x08050420` now track the saved linked-list, descriptor/payload,
and boundary-handling behavior. The `0x08049268` source recovery
also now uses the disassembly-confirmed context base `0x03000650` and keeps the
separate object pointer at `0x03000FB0`. This is not an object-level
unresolved-symbol audit; that report still requires the unavailable object
build and symbol tools.

Do not invent behavior for unresolved functions to make a link succeed. The
return-only routines at `0x08057B60` and `0x08057C5C` were added only after
their ROM instructions confirmed no visible effects. The arithmetic,
resource-dispatch, and return-only service recoveries are documented in
`docs/PASS11_DEVELOPMENT_2026-10-15.md` and
`docs/EXTERNAL_NOOP_FINDINGS.md`; rasterizer work is in
`docs/ARM_RASTERIZER_PRIMITIVE_RECOVERY.md`. The historical 54% source-recovery
estimate remains unchanged and is not a measured coverage value. Current
rasterizer source and verification limits are recorded in
`docs/ARM_RASTERIZER_PRIMITIVE_RECOVERY.md` and
`docs/ARM_RASTERIZER_ROW_DRAWING_RECOVERY.md` and
`docs/ARM_RASTERIZER_VERTEX_PARAMETERS_RECOVERY.md` and
`docs/ARM_RASTERIZER_VERTEX_ROWS_RECOVERY.md`.
