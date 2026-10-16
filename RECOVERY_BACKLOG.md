# Unresolved linkage recovery backlog

Generated with `make triage-unresolved`. Machine-readable evidence is in
`build/reports/unresolved_triage.json`. This is an inventory, **not** ROM matching.

## Prioritization

1. **Address-named game routines:** inspect `sub_08...` callers in the JSON report,
   then compare against original ROM disassembly. Assembly filename hits are only
   filename clues, not proof of function identity.
2. **Resource directory:** `ResourceDirectory_Create`, `Prepare`, and `Apply`
   are an interconnected missing pipeline. Reconstruct them together from ROM.
3. **Resource tables:** `ResourceTable_Generate`, `Transform`, and `Combine`
   form another missing group; verify input/output layout before implementing.
4. **Rasterizer:** `ArmRaster_DrawRows` and `ArmRaster_ProcessPrimitiveEdges`
   require ARM-side evidence and rendering fixtures.
5. **Error and runtime services:** `FatalError`, `Runtime_Fatal`,
   `ResourceNode_ValidateActiveList`, `System_VBlankWait` need behavior evidence.
6. **Toolchain:** `__aeabi_uidiv` is a compiler support dependency, not a
   recovered game routine. Linking against the appropriate runtime is different
   from reconstructing gameplay.

Do not replace unresolved functions with silent stubs to make a link succeed.
Current source-recovery estimate is unchanged at 54%; this audit adds no
verified original game functions.
