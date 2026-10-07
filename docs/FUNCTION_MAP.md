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
| `0x08057968` | `System_CopyStartupData` | programs DMA3 ROM→EWRAM, 32-bit immediate |
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
08057968  System_CopyStartupData
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
