# Linkage integration pass — 2026-10-15

This pass audited all 40 reconstructed ARMv4T C translation units using `nm -g` on compiled objects. It adds `tools/audit_linkage.py`, a JSON dependency report, and three parser tests.

## Verified integration improvements

Six calls in `src/main.c` that formerly referred to unresolved `sub_` address placeholders now invoke already reconstructed source functions:

| Original address label | Existing recovered function |
| --- | --- |
| `sub_0805FEF4` | `ResourceDescriptor_Init` |
| `sub_08062490` | `RuntimeObjectTable_Init` |
| `sub_08062B44` | `RuntimeScript_SetDescriptor` |
| `sub_08062E94` | `RuntimeMemory_Init` |
| `sub_080578FC` | `System_VBlankWait` |
| `sub_08062814` | `FrameEvent_Service` |

Function prototypes and the script-descriptor pointer argument were updated to match the existing implementations. No speculative new game behavior was introduced.

The object audit now reports **47 resolved cross-unit symbol references** and **32 unresolved external symbol names**, versus **42** and **37** before integration. The six replacements overlap with the `System_VBlankWait` situation because the original object symbol was not previously emitted as an undefined import on this compiler; these counts are observed object-symbol metrics, not function coverage. There remain unlinked BIOS helpers, external stubs, original ROM routines and assembly code. Some unresolved names may correspond to reconstructed code that still needs contract verification; they must not be blindly aliased.

## Reproduce

```sh
make clean && make check
make audit-linkage
make test-all
```

`build/reports/linkage.json` records unresolved names, their caller units, resolved cross-unit dependencies and duplicate definitions. The full regression suite passed after integration. `make check` is compile-only and does not imply a working or matching ROM.

## Recovery estimate

**54% remains a historical working estimate**, not a measurement inferred from exported symbols. This pass improves integration of already recovered code and is not evidence for increasing the source-recovery estimate. A ROM-backed function inventory is needed to substantiate 75%.

## Follow-up on 2026-10-15

`src/resource_directory_dispatch.c` now delegates to the full
`RuntimeResource_Select` reconstruction in `src/resource_handle.c`. That
routine uses the existing implementations identified by ROM tracing:
`RuntimeResource_ReleaseSelected`, `RuntimeEntry_AllocIndexed`, and
`RuntimeEntry_SetLimit`. The divide helpers at
`0x080660A8` and `0x080661E4` are represented in `src/math_runtime.c`, and
`System_VBlankWait` now has its direct SWI wrapper in `src/bios.c`. The
return-only entries at `0x08057B60` and `0x08057C5C` are also represented from
their observed Thumb instructions in `src/runtime_noop.c`.

The eight formerly unresolved import names covered by those changes are listed in
`docs/PASS11_DEVELOPMENT_2026-10-15.md`. The 40-object/47-cross-reference/32-
unresolved-symbol figures above are the prior object audit; no new object audit
was run for this follow-up because the execution environment did not have the
ARM compiler or linker.
