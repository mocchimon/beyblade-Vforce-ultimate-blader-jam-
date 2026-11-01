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
| `0x08057B60` | `sub_08057B60` | confirmed return-only entry; ignores its one message-pointer argument |
| `0x08057C5C` | `sub_08057C5C` | confirmed return-only entry; preserves stack while ignoring `r0-r3` |
| `0x08063A74` | `Input_ResetTable` | clears 0x15-byte table at `0x03005E80` |
| `0x08063A8C` | `Input_SetMapping` | writes a byte for mapping index <= 0x14 |
| `0x08063AA0` | `Input_SetState` | stores 32-bit state value |
| `0x080517A4` | `Input_TestMask` | returns `(input_state & mask)` |
| `0x08049000` | `StateFlagBit0Test` (provisional) | reads halfword at pointer-from-`0x03000BEC` + `0xEC`; returns whether bit 0 is set; flag meaning unknown |
| `0x0804901C` | `StateMotionFields_Clear` (provisional) | clears four words at state offsets `+0x84/+0x88/+0x8C/+0x90` |
| `0x08049040` | `StateMotionFields_SetTargets` (provisional) | stores two arguments as 8-fractional-bit targets at state `+0x8C/+0x90`; seeds current values `+0x84/+0x88` from signed source halfwords `+0x48/+0x4A` |
| `0x08049078` | `StateMotionFields_SmoothToTarget` (provisional) | updates current values toward targets using `0x080491E4`, then writes integer portions back to source `+0x48/+0x4A`; coordinate-like interpretation provisional |
| `0x080495C8` | `State_DescriptorFollowup` (provisional) | indexes 0x18-byte descriptor table at `0x08069FEC`; conditional record processing and shared follow-up |
| `0x080504E8` | `StateRecord_BuildFields10_14` (provisional) | iterates signed count and writes scaled values at output offsets +0x10/+0x14, stride 0x18 |
| `0x08050530` | `StateRecord_BuildFields08_0C` (provisional) | companion builder writing output offsets +0x08/+0x0C, stride 0x18 |
| `0x0805057C` | `StateRecord_WriteFields10_14` (provisional) | writes word +0x10 and sign-extended halfword value as word at +0x14 |
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
0805FEF4  ResourceDescriptor_Init (heap-backed surface/context constructor)
08062490  unknown/resource-related
08062B44  unknown
08062E94  unknown
08060544  unknown
080532DC  unknown
08051090  RuntimeContext_AllocateAndSeed (provisional; 0xC6C allocation + base-field seeding)
08055CDC  unknown
08058940  unknown
0805EFC0  ArmRaster_LoadModule (DMA image copy + selected pointer rebasing)
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
| `0x0805FEF4` | `ResourceDescriptor_Init` | allocates a heap-backed surface context and derives region pointers; exact graphics semantics unresolved |

## Pass 4 additions

| ROM address | Provisional name | Evidence |
|---|---|---|
| `0x080623CC` | `ResourceTable_Init` | loops exactly 0x80 entries, writes a 32-bit table result, then updates resource/timing globals |
| `0x08062490` | `RuntimeObjectTable_Init` | caps count at 0x10, allocates `0x28 * count`, installs a descriptor and per-entry state |
| `0x08062E94` | `RuntimeMemory_Init` | allocates `0xC400` and `0x1400` byte regions and installs their pointers |
| `0x08062814` | `FrameEvent_Service` | services the runtime-entry pool, tracks Timer0 wrap, and submits one or two segments through `0x03000D8C`; higher-level subsystem meaning unresolved |
| `0x08062B44` | `RuntimeScript_SetDescriptor` | installs the script descriptor at `0x03005E14` |
| `0x08062B50` | `RuntimeScript_Stop` | deactivates script-owned runtime entries and disables the interpreter |
| `0x08062BCC` | `RuntimeScript_Start` | validates script index, loads cursor pair, resets timing state, and enables the interpreter |
| `0x08062C48` | `RuntimeScript_Service` | bytecode interpreter for countdown delays, entry add/remove, source selection, cursor jumps, and timing-step updates |

The names above are provisional and intentionally describe observed behavior
rather than asserting game-specific semantics.

## Pass 5 additions

| ROM address | Provisional name | Evidence |
|---|---|---|
| `0x08049268` | `GameState_FramePrepare` | prepares the context at `0x03000650`, resets verified fields, clears its runtime-record manager, and separately resets the object selected by the pointer at `0x03000FB0` |
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
| `0x08049348` | `GameState_Dispatch` | five-entry indirect state-handler dispatch |

## Pass 8 additions

| ROM address | Provisional name | Evidence |
|---|---|---|
| `0x08049348` | `GameState_Dispatch` (shared-tail dispatcher) | five-entry indirect dispatch with shared register state and optional override context |
| `0x0804A284` | `RuntimeContext_CheckSync` | compares context indices/entry state and conditionally invokes synchronization handlers |
| `0x08050388` | `RuntimeRecord_Clear` | clears manager fields at +0x04..+0x17 while preserving the record pointer at +0x00 |
| `0x08050398` | `RuntimeRecord_Init` | stores alternate-heap descriptor and initializes linked-source 0x18-byte position/velocity records |

| `0x0804AF08` | `RuntimeResource_Select` | selects an indexed runtime resource and updates its handle |
| `0x0804AF60` | `RuntimeResource_ReleaseSelected` | releases selected runtime resource and resets selector |
| `0x08062A74` | `RuntimeEntry_Find` | searches 0x28-byte runtime entries by serial |
| `0x08062E74` | `RuntimeEntry_IsActive` | returns true when the matching entry status byte is nonzero |
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
| `0x08062C20` | `RuntimeTable_AllocateIndexed` | bounds-checks a descriptor index and allocates an entry from its pointer table |
| `0x08062F20` | `RuntimeBlock_Allocate` | allocates a run of 0xC4-byte slots, appending or delegating gap insertion |
| `0x08062FCC` | `RuntimeBlock_FindFree` | scans the 256-entry descriptor pool for an unused slot |
| `0x08063004` | `RuntimeBlock_Free` | cleans each 0xC4-byte child, unlinks its descriptor, and clears payload |
| `0x08063090` | `RuntimeBlock_Insert` | inserts a descriptor into a sufficiently large interior gap and repairs links |
| `0x0806307C` | `RuntimeBlock_FindTail` | follows +0x10 links to the final runtime block descriptor |
| `0x080631B4` | `RuntimeBlock_Get` | returns the `0xC4`-stride block for an index |
| `0x080631D4` | `RuntimeBuffer_Create` | allocates and describes an even-width/height buffer |
| `0x08063210` | `RuntimeBuffer_CopyRow` | bounds-checks a row and dispatches `(source, destination, byte_count)` through callback slot `0x0807D998`, whose value is the unresolved ARM IWRAM target `0x03007034` |
| `0x08063244` | `RuntimeBuffer_Repack` | repacks six 5-bit channels from descriptor data |

| `0x08064FC0` | `Object_Init` | initializes a larger object record and its flags/links |
| `0x0806500C` | `Object_CreateChildren` | allocates a 0xC4-stride child block and initializes each child |
| `0x080650AC` | `Object_InitChildren` | initializes child fields across the object child array |
| `0x0806512C` | `Object_CountActiveChildren` | counts child records with a nonzero field at +0x70 |
| `0x08065164` | `Object_Update` | services timing/flags and dispatches object state |

## Consolidated object/runtime continuation

| `0x0804A7EC` | `RuntimeDisplay_DisableRecordBackground` | clears the BG enable bit selected by record byte +0x5E |
| `0x0804A7FC` | `RuntimeDisplay_InvokeRecordBackgroundOperation` | follows the pointer at record `+0x88`, reads its byte `+0x5D`, then dispatches `(0, VRAM + index * 0x4000, 0x8000)`; backend behavior unresolved |
| `0x0805B268` | `RuntimeDisplayState_InitializeRecord` | writes owner/source words, one caller byte, a copied source byte, and active halfword 1 into a 16-byte record |
| `0x0805B284` | `RuntimeDisplayState_SetFields_0805B284` | writes words at +0x08/+0x04 and the low byte at +0x0C |
| `0x0805B28C` | `RuntimeDisplayState_SetByteAtOffset0D` | stores the low argument byte at record +0x0D |
| `0x0805B290` | `RuntimeDisplayState_SetByteAtOffset0C` | stores the low argument byte at record +0x0C |
| `0x0805B294` | `RuntimeDisplayState_GetIndexedBlockAddress` | returns base + ((index & 0x03FF) << 5); four direct uses in the containing routine |
| `0x0805B2A4` | `RuntimeDisplay_BlitIndexed4bppTile` | shifts eight packed-pixel rows across up to four map-selected tiles and ORs them into destination memory; coordinate clipping is preserved |
| `0x0805B3B8` | `RuntimeDisplayState_InvokeRecordOperations` | dispatches two operations using object bytes +0x5D/+0x5C and length at +0x74, then stores halfword 1 at record +0x0E; IWRAM backend behavior remains unresolved |
| `0x0805B400` | `RuntimeDisplay_ComputeSequenceMetric` | scans a zero-terminated byte sequence, gives byte 0x20 metric 5, and applies an optional table-derived adjustment to other bytes; direct caller subtracts the result or half of it for two alignment modes |
| `0x0805B440` | `RuntimeDisplay_DrawGlyphSequence` | reserves palette-tagged map entries, dispatches initialization for newly allocated tile memory, resolves indexed glyph data, blits its 8x8 blocks, and returns the final X coordinate; backend and language-specific control bytes remain unresolved |
| `0x0805B814` | `RuntimeDisplaySequence_GetGlyphSource` | resolves a glyph byte pointer from descriptor offset +0x10 and the glyph index shifted by descriptor byte +0x06 |
| `0x0805B824` | `RuntimeDisplay_ProcessByteStream` | buffers bytes for the glyph renderer; `0xFB` updates record +0x0D, `0xFC` flushes and updates +0x0C, line feed flushes/resets X/advances Y, and `0xFF` or later NUL flushes and returns; no direct BL/branch or stored Thumb pointer to this entry was found |
| `0x0805B95C` | `CollisionData_InitializeOwnedSegments` | stores selected flags, allocates a combined alternate-heap block, dispatches selected segments through the same three-argument callback at `0x0807D998` (`0x03007034`), then builds the spline pointer cache; implementation remains unresolved |
| `0x0805B8E8` | `CollisionData_BuildSplineIndex` | resolves three source-relative pointers, caps the signed count at 64, fills the record's spline pointer cache, then clears observed state fields; nine direct Thumb callers |
| `0x0805DBA4` | `CollisionData_GetSplineByIndex` | walks packed spline records using each entry's `+0x04` byte stride; nine direct Thumb callers |
| `0x08050388` | `RuntimeRecord_Clear` | clears the manager's six control fields |
| `0x08050398` | `RuntimeRecord_Init` | allocates linked-source 0x18-byte records and recovers zero-size/allocation-failure returns |
| `0x08050420` | `RuntimeRecord_Update` | integrates position/velocity and applies flag-controlled boundary handling |
| `0x08050A74` | `RuntimeObject_UpdateRecordArray` | adds the two halfword counts, then dispatches entries at a 0x88-byte stride |
| `0x08050AA0` | `RuntimeObject_InitializeEntryTable` | allocates and fills 0x1C-byte output records from 0x30-byte source records; 12 direct Thumb callers |
| `0x08058F18` | `RuntimeObject_UpdateRecord` | updates words at +0x14/+0x18 from +0x1C/+0x20, mirrors to +0x54/+0x58, and follows verified conditional calls |
| `0x08058F84` | `RuntimeObject_ApplyRecordTransform` | advances fixed-point record fields, updates affine state, writes BG2/BG3 reference points, and applies scale |
| `0x080596D0` | `RuntimeObject_UpdateDisplayRegion` | applies the caller's two word adjustments, clips/wraps six bounds words, and updates BG offsets or affine reference points |
| `0x08059928` | `RuntimeObject_UpdateDisplayRegionFromFrame` | derives two display-region adjustments from frame and record words before calling `RuntimeObject_UpdateDisplayRegion` |
| `0x08059958` | `RuntimeObject_InitializeDisplayState` | clears observed IWRAM state and BG scroll offsets, then initializes BG2/BG3 affine state |
| `0x080599B8` | `RuntimeObject_TestFlagsAt64` | returns whether the record halfword at +0x64 intersects the supplied mask |
| `0x080599CC` | `ChildResource_HorizontalOffsetRegister` | selects BG0HOFS through BG3HOFS register addresses |
| `0x08059A0C` | `ChildResource_VerticalOffsetRegister` | selects BG0VOFS through BG3VOFS register addresses |
| `0x08059A4C` | `ChildResource_BackgroundControlRegister` | selects BG0CNT through BG3CNT register addresses |
| `0x08059A8C` | `RuntimeObject_SetAffineReferencePoint` | writes the 32-bit BG2X/BG2Y or BG3X/BG3Y reference values |
| `0x08059ADC` | `RuntimeObject_SetAffineCoefficients` | writes PA/PB/PC/PD halfwords for BG2 or BG3 |
| `0x08059B24` | `RuntimeObject_UpdateAffineTransform` | stores one of three 0x18-byte IWRAM entries and derives four coefficients from two ROM tables |
| `0x08059C3C` | `RuntimeDisplay_SetAllBackgroundControlLowBits` | replaces the low two bits in BG0CNT–BG3CNT from four inputs |
| `0x08059CD8` | `RuntimeDisplay_GetRecordBackgroundControlLowBits` | reads the selected BG control low bits using record byte +0x5E |
| `0x08059CEC` | `RuntimeDisplay_SetBackgroundControlLowBits` | replaces the low two bits of the selected BGxCNT register |
| `0x08059D14` | `RuntimeDisplay_GetBackgroundControlLowBits` | reads the low two bits of the selected BGxCNT register |
| `0x08059D28` | `RuntimeDisplay_SetBackgroundEnabled` | sets or clears the selected BG0–BG3 enable bit in DISPCNT |
| `0x08059FC4` | `RuntimeObject_MultiplyAffineCoefficients` | multiplies signed halfwords, scales by 1/256 with truncation toward zero, then wraps to a signed halfword |
| `0x08060C40` | `ResourceNode_AllocateChain` | removes a contiguous batch from the free chain, tags it with a class, and inserts it into the ordered active list |
| `0x08060D00` | `ResourceNode_ReleaseChain` | releases a counted contiguous active-list segment, recycles auxiliary/range ownership, repairs links, prepends it to the free chain, and clears head/tail/count |
| `0x08060DBC` | `ResourceNode_ResizeChain` | keeps an equal-size chain, appends free nodes when growing, and releases/recreates on shrink |
| `0x08061154` | `RuntimeObjectSelection_AddStateBits` | ORs the low two input bits into context word `+0x10`, bits 10–11 |
| `0x08061170` | `RuntimeObjectSelection_GetStateBits` | returns context word `+0x10`, bits 10–11 |
| `0x0806117C` | `RuntimeObjectSelection_SetByte19ToOne` | stores byte value 1 at context `+0x19` |
| `0x08061184` | `RuntimeObjectSelection_SetByte19ToZero` | stores byte value 0 at context `+0x19` |
| `0x0806118C` | `RuntimeObjectSelection_SetControlNibble` | replaces the high nibble of the halfword at context `+0x14` |
| `0x080611B4` | `RuntimeObjectSelection_InitializeContext` | initializes scaled X/Y, selection flags at +0x08, cursor at +0x0A, extent at +0x0C, the node chain, and fixed 0x100 fields |
| `0x0806124C` | `RuntimeObjectSelection_ResetContext` | calls `ResourceNode_ReleaseChain` on context `+0x14`, then clears halfword `+0x0A` |
| `0x08061260` | `RuntimeObjectSelection_ApplyLayout` | assigns fixed-point X/Y positions to node segments, wraps them against the context extent, applies the optional scale, and adjusts vertical centering from flags |
| `0x080614D4` | `RuntimeObjectSelection_SetFlagsAndApplyLayout` | stores the low halfword at context `+0x08` and calls `RuntimeObjectSelection_ApplyLayout` |
| `0x080614E0` | `RuntimeObjectSelection_Finalize` | counts a zero-terminated code stream, resizes the embedded chain, configures ordinary entries, carries code 32 as a cursor marker, then applies node layout |
| `0x08061684` | `RuntimeObjectSelection_Dispatch` | truncates its control-byte argument, resets context, calls `RuntimeObjectSelection_Finalize`, and returns its low byte |
| `0x08064F5C` | `RuntimeObjectSelection_CountEntries` | counts nonzero stream bytes except the special value 32 |
| `0x08063AC4` | `sub_08063AC4` | reads one byte through the pointer at 0x03005E98 plus literal 0x03005E80; ignores incoming r0 |
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
| `0x08065994` | `Runtime_Dma3CopyHalfwords_Guarded` (provisional) | ROM-verified three-argument helper: r0 source, r1 destination, r2 halfword count; programs DMA3 and waits for completion while temporarily modifying/restoring BG2 affine registers |
| `0x08059620` | `RuntimeDisplay_ApplyAttributeMask` (provisional) | traverses a child-selected VRAM tile-map region, preserves low 12 bits per halfword, and replaces the high nibble unless child `+0x64` bit 0 is set; no direct Thumb BL callers found |
| `0x080584DC` | `ChildMotion_Update` | advances three fixed-point accumulators and an activity timer |
| `0x080585EC` | `Child_SetModeByte` | updates child byte at +0x98 and refreshes +0x58 when it changes |
| `0x0805861C` | `Child_SetTransform4` | stores four halfword parameters at +0xA8..+0xAE |
| `0x08058638` | `Child_SetTransform3` | stores three halfword parameters at +0x9A..+0x9E |
| `0x08058778` | `Child_GetMotionState` | copies child motion fields or delegates to a callback at +0xB0 |
| `0x0805879C` | `Child_ResetModeByte` | delegates mode reset to `0x08057DAC` |
| `0x080587B8` | `ChildQueue_Append` | allocates/uses a four-entry 0x10-byte queue at +0x74..+0x7C |
| `0x080588CC` | `ObjectChild_Cleanup` | releases the child resource-node handle and queue heap block |
| `0x08058900` | `ChildQueue_Clear` | clears queued entry activity words and resets queue count |

### Continued render/runtime cluster
| `0x08058948` | `RuntimeTable_NextElement` | indexed pointer helper; semantics neutral |
| `0x08058960` | `RuntimeTable_GetIndexed` | flag-gated indexed table lookup |
| `0x0805898C` | `ChildRuntime_InitVariantA` | initializes nested runtime state and child defaults |
| `0x08058A4C` | `ChildRuntime_InitVariantB` | related initializer using caller-supplied dimensions/flags |
| `0x08058ACC` | `ChildResource_Init` | resource-backed child initializer; consumes the 16-byte resource record header and establishes source/end pointers |
| `0x08058C98` | `ChildRuntime_InitVariantC` | initializes an internally allocated child display record, tracks its 0x4000-byte block cursor, dispatches its layout operation, and updates BGxCNT; operation semantics remain opaque |

## Object-selection layout follow-up

The former downstream gap at `0x08061260` is now source-defined as
`RuntimeObjectSelection_ApplyLayout`; the measurement and ROM-byte evidence
for this recovery are recorded in `docs/PASS25_DEVELOPMENT_2026-10-17.md`.

## Runtime configuration / render backend follow-up

| Address | Name/status | Evidence |
|---|---|---|
| `0x0807D920` | mixed runtime configuration/data block (provisional) | Contains runtime-global addresses, Thumb pointers, scalars, and byte lookup data; not a flat callback array |
| `0x08060170` | runtime/config consumer (entry boundary provisional) | At `0x0806027E`, loads `0x0807D920`, dereferences its first word (`0x0300717C`), then calls the `bx r0` trampoline at `0x08065C38`; see `docs/RUNTIME_CONFIG_CONSUMER_FINDINGS.md` |
| `0x0806027E` | literal load referencing configuration block | PC-relative load resolves to literal at `0x080602C0`, whose word is `0x0807D920` |
| `0x08065C38` | `Runtime_Dispatch_R0` (mechanical name) | Single-instruction indirect branch `bx r0`; not a normal C function body |
| `0x0300646C` | IWRAM render branch target | Reached through an indirect branch; installed code/source remains unresolved |
| `0x08059428` | `sub_08059428` (neutral) | Row-oriented DMA3 transfer routine; relation to IWRAM targets `0x0300646C` / `0x0300682C` not proven |

## ARM-state rasterizer image (`0x080641B8–0x08064EDB`)

| Address | Working name | Status |
|---|---|---|
| `0x080641B8` | `ArmRaster_EmitSamples` | C sample-sequence reconstruction; output semantics remain provisional |
| `0x08064218` | `ArmRaster_EmitPackedSamples` | C reciprocal-table sample reconstruction; packed stores expressed as byte writes |
| `0x08064364` | `ArmRaster_ProcessPrimitiveEdges` | C behavior reconstruction: sorts three coordinate records, computes reciprocal-table slopes, and writes the edge descriptor; output semantics remain provisional |
| `0x080645EC` | `ArmRaster_ProcessAlternateEdgeCase` | Implemented branch within `ArmRaster_ProcessPrimitiveEdges`; not a standalone entry |
| `0x08064724` | `ArmRaster_ClampSpan` | Implemented repeated-index branch within `ArmRaster_ProcessPrimitiveEdges`; not a standalone entry |
| `0x08064850` | `ArmRaster_DrawRows` | C row/span reconstruction with 0x40-byte stride; pixel equivalence unverified |
| `0x08064A14` | `ArmRaster_ApplyVertexParameters` | C behavior reconstruction of table-based signed per-row transform; caller semantics provisional |
| `0x08064AFC` | `ArmRaster_TransformVertexRows` | C behavior reconstruction of optional interpolation, matrix transform, projection, and 10/6/16-byte record flow; caller semantics provisional |
| `0x08064C38` | `ArmRaster_InsertBucketItem` | Appends a signed-halfword item to a bucket-linked node table; high confidence |
| `0x08064C8C` | `ArmRaster_BuildEdgeBuckets` | Applies the primitive orientation test, maps a fixed-point attribute into a 32-bucket domain, and inserts record indices; reconstructed in C with raw descriptor offsets |
| `0x08064DE0` | `ArmRaster_ProcessEdgeBuckets` | Traverses bucket-linked vertex records, invokes primitive-edge processing, and conditionally draws rows; high confidence in control flow |
| `0x08064E50` | `ArmRaster_Helper_C98` | Relocation-table entry; unresolved |

See `docs/ARM_RASTERIZER_FINDINGS.md` for evidence and caveats. This module has not been proven to supply IWRAM branch targets `0x0300646C` / `0x0300682C`.

| `0x08064E54` | `ArmRaster_CopyEightRowSlices` | ARM-state helper that gathers eight 8-byte source slices at a supplied stride into each 64-byte output block; exact graphics layout remains unresolved. |

### Pass 10 corrections

| Address | Working name | Updated interpretation |
|---|---|---|
| `0x08062370` | `RuntimeObject_Prepare` | Stops associated registers, frees stored heap descriptors, clears runtime payload pointers and the primary descriptor slot. |
| `0x08062490` | `RuntimeObjectTable_Init` | Computes an aligned count-derived size and allocates `3*n + 40*count` through `Heap_Alloc`; allocates the auxiliary `0x440` block through `Heap_AllocAlt`. |
| `0x080661E4` | `System_Udiv` (working label) | Unsigned division helper; not an allocator. |

## Pass 11 — runtime record helpers

| ROM address | Provisional name | Evidence |
|---|---|---|
| `0x0805AC4C` | `RuntimeRecord_Create` | allocates a 0x10-byte alternate-heap payload and writes fields at +0x00/+0x04/+0x08/+0x0C |
| `0x0805AC80` | `RuntimeRecord_SetCurrent` | stores its argument at `0x03005DC0` |

| `0x080604F8` | `ResourceNode_ValidateActiveList` | walks the active list and checks head/neighbor links; passes one of three ROM message pointers to the return-only diagnostic entry on mismatch |
| `0x080609E8` | `ResourceNode_FindInsertionPoint` | returns the first active node whose halfword at +0x22 is at least the requested value, or the list tail |
| `0x08060A04` | `ResourceNode_AcquireByClass` | removes one node from the free chain, inserts it into the active chain, decrements the available-node counter, and validates the list |
| `0x08060AB8` | `ResourceNode_Unlink` | removes a resource node from the active doubly linked list, releases its range token when applicable, pushes it onto the free list, releases an auxiliary node, increments the recycle counter, and validates active-list links |
| `0x08060B5C` | `ResourceNode_UnlinkAuxiliary` | conditionally unlinks an auxiliary node from the list at `0x03005DF8` and recycles it through the free chain at `0x03005DE8` |
| `0x08060B8C` | `ResourceNode_ConfigureSelectionEntry` | initializes recovered entry fields, encoded words, sentinels, and a metadata-derived payload pointer |

- `0x0806082C` — `RuntimeRange_Release`: return 16-bit range to sorted free-range list, merge adjacent nodes, recycle absorbed nodes (`src/runtime_range.c`).
- `0x08060958` — `RuntimeRange_Reset`: reset the 0x400-unit range arena, release old resource tokens, and seed 31 spare descriptors (`src/runtime_range_init.c`).

| `0x08051120` | `RuntimeContext_InitializeFollowup` (provisional) | Clears/sets additional runtime-base offsets, then initializes 56 table-backed records and 10 auxiliary entries; clears `+0x6B4` after the preceding routine seeded it to 1. Callback and field semantics remain unresolved. See Pass 56 audit. |

Pass 58: `0x080517BC` writes a caller-provided value to runtime-context offset `+0x6B4`; direct call paths at `0x08045A4A` and `0x08045A5C` supply values 1 and 1/4 respectively. Semantics unresolved; see `docs/PASS58_DEVELOPMENT_2026-10-25.md`.

Pass 57: helper `0x08051744` indexes 56 objects at runtime +4 (stride 0x18); `0x08051704` indexes 10 entries at +0x544 (stride 8). Indirect trampoline `0x08065C44` branches to a callback dynamically stored in RAM `0x03006FAC`; see `docs/PASS57_DEVELOPMENT_2026-10-25.md`.


## Pass 59 addition

| ROM address | Provisional name | Evidence |
|---|---|---|
| `0x08045A08` | `ContextSelector_Dispatch5` | loads selector at enclosing-context offset `+0x4B4`, bounds-checks 0–4, dispatches through a five-entry ROM table; case actions verified, semantic meaning unresolved |

## Pass 60 addition

| `0x08043C8C` | `ContextSelector_Dispatch5_Parallel` (provisional) | reads the same selector field `+0x4B4` as `0x08045A08`; selectors 0–4 pass values 0, 3, 4, 5, 7 to `0x08063AA0`, then write `0x20` to `0x03000168`; semantic meaning unresolved |

## Pass 64 additions

| ROM address | Provisional name | Evidence |
|---|---|---|
| `0x080495C8` | `GameState_ApplySelectionDescriptor` | reads selected state ID, indexes 0x18-byte descriptor table at `0x08069FEC`, conditionally forwards descriptor/record fields to helper routines; semantic naming remains provisional |

- `0x080491E4`: signed magnitude-dependent step quantizer, r1=0x80 in motion consumer.
- `0x08049000`: bit-zero predicate at `[0x03000BEC]+0xEC`.

## Pass 71 input candidate

| `0x08043D42` | `MenuInput_TriageCandidate` (provisional) | checks masks 1, 0x100, 4 and conditionally forwards 0x11/0x12/0x13 to 0x08049250; nearby branches pass 0x0A/0x09 to state-history helper 0x080490FC; title/pause identity unconfirmed |
