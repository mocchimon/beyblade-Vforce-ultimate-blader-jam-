# Initial function map

Target ROM: `BEYP70` Rev.00, 8 MiB.

## Confirmed high-level entry

- `0x080505A8` — Thumb entry reached by the relocated startup.

## High-confidence system functions

| ROM address | Name | Evidence |
|---|---|---|
| `0x080578E4` | `System_CpuSet` | direct BIOS SWI `0x0B` wrapper |
| `0x080578E8` | `System_Div` | BIOS SWI `0x06`, returns r0 |
| `0x080578EC` | `System_Mod` | BIOS SWI `0x06`, returns r1 |
| `0x080578F4` | `System_LZ77UnCompWram` | BIOS SWI `0x11` |
| `0x080578F8` | `System_Sqrt` | BIOS SWI `0x08` |
| `0x080578FC` | `System_VBlankWait` | BIOS SWI `0x05` |
| `0x08057940` | `System_Dma3StateInit` | initializes `0x03000E30` triple |
| `0x08057968` | `System_InstallIwramBlock` | DMA3 copies `0x104` bytes from ROM `0x08000168` to IWRAM `0x03000FE0`; records destination at `0x03007FFC` |
| `0x080579CC` | `System_DisplayInit` | IME/IE/IF/DISPSTAT + DMA3 setup |
| `0x08057A18` | `System_SetDisplayFlags` | OR into `DISPCNT` |
| `0x08063A74` | `Input_ResetTable` | clears 0x15-byte table at `0x03005E80` |
| `0x08063A8C` | `Input_SetMapping` | writes a byte for mapping index <= 0x14 |
| `0x08063AA0` | `Input_SetState` | stores 32-bit state value |
| `0x080517A4` | `Input_TestMask` | returns `(input_state & mask)` |
| `0x0805A374` | `System_ResetGlobals` | clears a group of `0x03005cxx` globals |
| `0x0805A890` | `Input_Init` (preliminary) | reads `KEYINPUT` and initializes input globals |

## Important call targets from `0x080505A8`

```text
08057968  System_InstallIwramBlock
080579CC  System_DisplayInit
08057A18  System_SetDisplayFlags
08057940  System_Dma3StateInit
0805A374  System_ResetGlobals
0805A890  Input_Init [preliminary]
080574CC  unknown
08063A74  Input_ResetTable
08063A8C  Input_SetMapping
08063AA0  Input_SetState
0805FEF4  unknown/resource-related
08062490  unknown/resource-related
08062B44  unknown
08062E94  unknown
08060544  unknown
080532DC  unknown
08051090  unknown
08055CDC  unknown
08058940  unknown
0805EFC0  unknown
08052538  unknown
080578FC  System_VBlankWait
08062814  unknown/update-related
0805A6DC  unknown
08053398  unknown
0805193C  unknown
08053BB8  unknown
08053CD8  unknown
080517A4  Input_TestMask
080512D0  unknown
08062798  unknown
0805AC4C  unknown/event-related
080578EC  System_Mod
080578E8  System_Div
080578E4  System_CpuSet
080578F8  System_Sqrt
```

## Next targets

1. `0x0805A890` input structure and per-frame input path.
2. `0x080574CC` and its `0x08065828` / `0x08065890` callees.
3. `0x0805FEF4`, `0x08062490`, `0x08062B44`, `0x08062E94` — resource/object initialization cluster.
4. `0x0805EFC0` and `0x08052538` — first routines reached by the persistent loop.
5. `0x08062814`, `0x0805A6DC`, `0x08053398`, `0x0805193C` — per-frame subsystem cluster.

## Newly reconstructed structures/helpers

| ROM address | Provisional name | Evidence |
|---|---|---|
| `0x0805A3CC` | `Heap_Alloc` | allocation front-end; obtains a 0x20-byte descriptor and delegates to block placement |
| `0x0805A444` | `Heap_AllocAlt` | parallel allocation front-end using the alternate pool globals |
| `0x0805A4BC` | `Heap_Free` | unlinks a block and returns it to the free-list |
| `0x0805A560` | `Heap_InsertBlock` | splits/inserts a block and fixes neighboring links |
| `0x0805A608` | `Heap_FindAvailable` | scans allocator metadata for a usable block |
| `0x08060544` | `Runtime_ResetPools` | allocates/reset runtime pools; invoked repeatedly from the frame path |
| `0x0805A890` | `ControlState_Init` | KEYINPUT + ten 0x18-byte control records |
| `0x0805FEF4` | `ResourceDescriptor_Init` | startup resource descriptor construction; exact subsystem unresolved |

## Pass 4 additions

| ROM address | Provisional name | Evidence |
|---|---|---|
| `0x080623CC` | `ResourceTable_Init` | loops exactly 0x80 entries, writes a 32-bit table result, then updates resource/timing globals |
| `0x08062490` | `RuntimeObjectTable_Init` | caps count at 0x10, allocates `0x28 * count`, installs a descriptor and per-entry state |
| `0x08062E94` | `RuntimeMemory_Init` | allocates `0xC400` and `0x1400` byte regions and installs their pointers |
| `0x08062814` | `FrameEvent_Service` | checks runtime state and enters timing/event dispatch; gameplay meaning unresolved |

The names above are provisional and intentionally describe observed behavior
rather than asserting game-specific semantics.

## Pass 5 additions

| ROM address | Provisional name | Evidence |
|---|---|---|
| `0x08049268` | `GameState_FramePrepare` | resets/prepares a large state context and clears per-frame fields |
| `0x0804945C` | `GameState_FrameDispatch` | VBlank + state/context processing, event/object checks, repeated frame dispatch |
| `0x080512D0` | `ControlEvent_Service` | indexed control-record scan and event-bit updates |
| `0x0805A6DC` | `ControlQueue_Service` | consumes queued 16-bit values and updates queue state |
| `0x08062B44` | `Runtime_SetContext` | stores one startup pointer into `0x03005E14` |
| `0x08062BCC` | `DeferredEvent_Begin` | bounds-checks event index and loads an 8-byte table entry into globals |

## Pass 6 additions

| ROM address | Provisional name | Evidence |
|---|---|---|
| `0x08062490` | `RuntimeObjectTable_Init` | exact descriptor/buffer setup and 0x80-entry table initialization |
| `0x08062E94` | `RuntimeMemory_Init` | exact 0xC400/0x1400 allocations and descriptor writes |

## Pass 7 additions

| ROM address | Provisional name | Evidence |
|---|---|---|
| `0x0804901C` | `GameState_ResetTimers` | writes paired timing fields in the `0x03000650` context |
| `0x080490D0` | `GameState_QueueContext` | updates the two-entry context history and invokes runtime callback |
| `0x080490FC` | `GameState_SelectContext` | rotates/stores context pointer and advances a 15-entry history |
| `0x08049160` | `GameState_GetContext` | returns context field `+0x08` |
| `0x0804916C` | `GameState_ClearPendingIndex` | clears context byte `+0x7C` |
| `0x0804917C` | `GameState_AdvancePending` | consumes pending index and selects a queued context |
| `0x080491E4` | `GameState_ScaleStep` | signed magnitude/power-of-two scaling helper |
| `0x08049214` | `GameState_SetActiveIndex` | clamps index against active object's limit and stores `index+1` |
| `0x08049238` | `GameState_SetContextA` | stores pointer at context `+0x0C` |
| `0x08049244` | `GameState_GetContextA` | reads context `+0x0C` |
| `0x08049250` | `GameState_SetContextB` | stores pointer at context `+0x10` |
| `0x0804925C` | `GameState_GetContextB` | reads context `+0x10` |
| `0x08049268` | `GameState_Init` | initializes main state record rooted at `0x03000FB0` |
| `0x08049348` | `GameState_Dispatch` | five-entry indirect state-handler dispatch |

## Pass 8 additions

| ROM address | Provisional name | Evidence |
|---|---|---|
| `0x08049348` | `GameState_Dispatch` (shared-tail dispatcher) | five-entry indirect dispatch with shared register state and optional override context |
| `0x0804A284` | `RuntimeContext_Service` | compares context indices/entry state and conditionally invokes synchronization handlers |
| `0x08050388` | `RuntimeRecord_Clear` | clears the fixed fields of a 0x1C-byte runtime record |
| `0x08050398` | `RuntimeRecord_Init` | allocates `count * 0x1C` bytes and initializes a sequence of runtime records |

| `0x0804AF08` | `RuntimeResource_Select` | selects an indexed runtime resource and updates its handle |
| `0x0804AF60` | `RuntimeResource_ReleaseSelected` | releases selected runtime resource and resets selector |
| `0x08062A74` | `RuntimeEntry_Find` | searches 0x28-byte runtime entries by key |
| `0x08062AB4` | `RuntimeEntry_Deactivate` | clears runtime entry status byte |
| `0x08062AC8` | `RuntimeEntry_SetStatus2` | sets runtime entry status to 2 |
| `0x08062ADC` | `RuntimeEntry_AdvanceStatus` | transitions runtime entry status 2 to 1 |
| `0x08062AF8` | `RuntimeEntry_SetLimit` | updates runtime entry halfword at +0x10, capped at 0x100 |
| `0x08062B18` | `RuntimeEntry_SetPointer` | updates runtime entry pointer from the 0x03000D98 table |

## Consolidated runtime cluster
| `0x08062934` | `RuntimeEntry_Init` | initializes a 0x28-byte runtime entry |
| `0x08062974` | `RuntimeEntry_InitIndexed` | initializes an entry from a secondary indexed table |
| `0x080629B4` | `RuntimeEntry_AllocIndexed` | allocates an inactive runtime entry and returns its serial |
| `0x08062A14` | `RuntimeEntry_Alloc` | allocates an inactive runtime entry from source/index |
| `0x08062C20` | `RuntimeTable_CopyIndexed` | bounds-checks an index and dispatches a table entry through a copy helper |
| `0x08062FCC` | `RuntimeBlock_FindFree` | scans the runtime block list for a free slot |
| `0x08063004` | `RuntimeBlock_Free` | releases a block and relinks the block list |
| `0x08063090` | `RuntimeBlock_Insert` | inserts a block into the size-ordered runtime list |
| `0x080631B4` | `RuntimeBlock_Get` | returns the `0xC4`-stride block for an index |
| `0x080631D4` | `RuntimeBuffer_Create` | allocates and describes an even-width/height buffer |
| `0x08063210` | `RuntimeBuffer_CopyRow` | copies one indexed row/plane through the GBA copy helper |
| `0x08063244` | `RuntimeBuffer_Repack` | repacks six 5-bit channels from descriptor data |

| `0x08064FC0` | `Object_Init` | initializes a larger object record and its flags/links |
| `0x0806500C` | `Object_CreateChildren` | allocates a 0xC4-stride child block and initializes each child |
| `0x080650AC` | `Object_InitChildren` | initializes child fields across the object child array |
| `0x0806512C` | `Object_CountActiveChildren` | counts child records with a nonzero field at +0x70 |
| `0x08065164` | `Object_Update` | services timing/flags and dispatches object state |

## Consolidated object/runtime continuation

| `0x08050388` | `RuntimeRecord_Clear` | clears the manager's six control fields |
| `0x08050398` | `RuntimeRecord_Init` | allocates `count * 0x18` bytes and initializes 0x18-byte records |
| `0x08050420` | `RuntimeRecord_Update` | advances the 0x18-byte records using the manager flag field |
| `0x08064FC0` | `Object_Init` | initializes a larger object containing 0xC4-byte children |
| `0x0806512C` | `Object_CountActiveChildren` | counts children with nonzero field at +0x70 |
| `0x08065164` | `Object_Update` | flag-driven object update/dispatch |
| `0x080656DC` | `Object_ClearChildActivity` | scans child modes and clears activity fields |
| `0x08065730` | `Object_ProcessChildren` | processes all children through a common helper |
| `0x08065784` | `Object_ProcessChildrenLimited` | bounded child-processing variant |
| `0x080657E8` | `Object_ServiceChildren` | invokes a common service routine for each child |

## Continued object/render cluster

| ROM address | Provisional name | Evidence |
|---|---|---|
| `0x08057C7C` | `ChildRecord_Init` | initializes a 0xC4-byte child, including +0x74 queue state and transform/control fields through +0xC0 |
| `0x08058400` | `ChildResource_Apply` | reads resource metadata and applies it to child fields; exact asset semantics unresolved |
| `0x08059334` | `ChildResource_RenderCopy` | clips a rectangle and dispatches the selected transfer backend through `0x08065C5C` |
| `0x08059520` | `Render_CopyRect16_DMA3` | copies a 16-bit rectangle row-by-row by programming GBA DMA3 into VRAM |
| `0x080584DC` | `ChildMotion_Update` | advances three fixed-point accumulators and an activity timer |
| `0x080585EC` | `Child_SetModeByte` | updates child byte at +0x98 and refreshes +0x58 when it changes |
| `0x0805861C` | `Child_SetTransform4` | stores four halfword parameters at +0xA8..+0xAE |
| `0x08058638` | `Child_SetTransform3` | stores three halfword parameters at +0x9A..+0x9E |
| `0x08058778` | `Child_GetMotionState` | copies child motion fields or delegates to a callback at +0xB0 |
| `0x0805879C` | `Child_ResetModeByte` | delegates mode reset to `0x08057DAC` |
| `0x080587B8` | `ChildQueue_Append` | allocates/uses a four-entry 0x10-byte queue at +0x74..+0x7C |
| `0x08058900` | `ChildQueue_Clear` | clears queued entry activity words and resets queue count |

### Continued render/runtime cluster
| `0x08058948` | `RuntimeTable_NextElement` | indexed pointer helper; semantics neutral |
| `0x08058960` | `RuntimeTable_GetIndexed` | flag-gated indexed table lookup |
| `0x0805898C` | `ChildRuntime_InitVariantA` | initializes nested runtime state and child defaults |
| `0x08058A4C` | `ChildRuntime_InitVariantB` | related initializer using caller-supplied dimensions/flags |
| `0x08058ACC` | `ChildResource_Init` | resource-backed child initializer; consumes the 16-byte resource record header and establishes source/end pointers |
| `0x08058C98` | `ChildRuntime_InitVariantC` | related runtime initializer |

## Runtime configuration / render backend follow-up

| Address | Name/status | Evidence |
|---|---|---|
| `0x0807D920` | mixed runtime configuration/data block (provisional) | Contains runtime-global addresses, Thumb pointers, scalars, and byte lookup data; not a flat callback array |
| `0x08060170` | runtime/config consumer (entry boundary provisional) | At `0x0806027E`, loads `0x0807D920`, dereferences its first word (`0x0300717C`), then calls the `bx r0` trampoline at `0x08065C38`; see `docs/RUNTIME_CONFIG_CONSUMER_FINDINGS.md` |
| `0x0806027E` | literal load referencing configuration block | PC-relative load resolves to literal at `0x080602C0`, whose word is `0x0807D920` |
| `0x08065C38` | `Runtime_Dispatch_R0` (mechanical name) | Single-instruction indirect branch `bx r0`; not a normal C function body |
| `0x0300646C` | alternate render backend pointer slot | Read by render-transfer code; initialization/store and exact target remain unproven |
| `0x08059428` | `sub_08059428` (neutral) | Row-oriented DMA3 transfer routine; relation to IWRAM targets `0x0300646C` / `0x0300682C` not proven |
