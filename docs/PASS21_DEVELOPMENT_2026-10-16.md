# Pass 21 development report — 2026-10-16

## Resource-node selection path recovery

Recovered the helper at `0x080609E8` as a scan for the insertion point in the
active resource-node list. It compares the unsigned halfword at node `+0x22`
with the requested class and returns the first node whose value is at least
the request, or the last node if the scan reaches the end.

Recovered `0x08060A04` as `ResourceNode_AcquireByClass`. It takes the head of
the free chain at `0x03005DEC`, stores the low halfword of its first argument
at node `+0x22`, removes that node from the free chain, and inserts it into the
active chain at the position returned by `0x080609E8`. It decrements the
counter at `0x03005DF4` on success. If no free node exists it calls the
ROM-confirmed return-only diagnostic at `0x08057B60`, then validates the active
chain and returns null. The incoming second argument is ignored.

Recovered `0x08060B8C` as `ResourceNode_ConfigureSelectionEntry`. It writes
the confirmed fields at `+0x08`, `+0x0C`, `+0x10`, `+0x14`, `+0x16`,
`+0x18`, `+0x1A`, `+0x1C`, `+0x20`, `+0x24`, `+0x28`, and `+0x2C`. The packed
words preserve the signed-byte extension, source-byte masks, parameter
truncation, and `0xFFFFFFFF` sentinels. Fields without established meanings
remain neutral. The separate context initializer at `0x080611B4` now has a C
definition with a compile-time-checked 0x30-byte layout; it initializes the
observed coordinate, extent, unit, object, and trailing-byte fields and
ignores its final input word as the ROM does.

These definitions replace three of the four address-named direct callees in
`RuntimeObject_InitializeEntryTable`. The final call at `0x08061684` remains
unresolved; no behavior was invented for it or its complex downstream path.

## Verification

The new ROM verifier matched **214 Thumb halfwords across three ranges** and
decoded **seven direct BL targets**: three calls made by the recovered
resource-node code and four integration sites in the object-selection
builder. The existing pass-20 verifier still matches 216 halfwords and 20
calls. The resource-node validator verifier and alias-resource ROM checks
also pass. All **47 Python unit cases** in the non-ROM suite pass, and
libclang parsed all **44 ARM7TDMI translation units with zero errors** using
minimal freestanding standard headers. These checks cover source syntax,
selected ROM bytes, and direct-call bindings; they do not establish generated
object equivalence.

`make partial-link` was attempted but could not start because `make` is not
installed. No ARM object files or candidate ROM were produced. A matching ROM
build also remains gated by the unavailable ARM compiler/linker and the
unrecovered GBA section/linker layout.

The overall completion figure remains **approximately 54%**. It is the same
rough historical estimate, with no defined denominator, and is not measured
coverage. The counts above are measured checks for this pass only.
