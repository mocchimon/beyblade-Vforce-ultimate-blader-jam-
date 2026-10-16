# Pass 20 development report — 2026-10-16

## Object selection entry-table recovery

Recovered the Thumb routine at `0x08050AA0` as
`RuntimeObject_InitializeEntryTable`. It requests `count * 0x1C` bytes from
`Heap_AllocAlt`, keeps the returned allocation descriptor at manager `+0x30`
and its first-word payload at `+0x28`, and fills `count` output records at a
`0x1C` stride from source records at a `0x30` stride. The source descriptor
fields and manager/output offsets are guarded by compile-time assertions.
The body preserves the ROM's selected-index comparison, signed table
interpolation at `0x0874CC60`, arithmetic shift, diagnostic call, object
initialization call, and final selected-record dispatch. Field meaning stays
neutral where the instruction flow does not establish a higher-level role.

The small callee at `0x08063AC4` is now source-defined. It loads the word at
`0x03005E98`, adds the ROM literal `0x03005E80`, and returns the byte at that
address; its incoming `r0` is ignored. Four direct callees from the main
routine remain explicit externals: `0x08060A04`, `0x08060B8C`, `0x080611B4`,
and `0x08061684`.

## Verification

Added a saved ROM halfword listing, verifier, focused regression, and Make
targets. The verifier matched **216 halfwords across two ranges** and decoded
**20 direct Thumb call sites**: eight outgoing calls and 12 callers of the
recovered entry. These figures are measured for this pass only; they do not
represent total source coverage. The 12 incoming call targets were checked
from the supplied original ROM. All **44 Python tests passed**, and libclang
parsed **44 ARM7TDMI translation units with zero errors** using minimal
freestanding standard headers; this confirms syntax and layout assertions,
not generated machine code.

The historical **approximately 54% completion estimate is unchanged**. It is
still a rough, unmeasured estimate with no defined denominator. A candidate
ROM or ARM partial-link result is not claimed: this Windows environment has
no `make`, Clang executable, ARM GCC/linker, `nm`, or `objdump` available, and
the project still lacks the original GBA linker layout. The `make partial-link`
attempt stopped because `make` is unavailable. Source parsing and ROM-byte
checks do not establish that a complete game image can be rebuilt.
