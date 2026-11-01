# Pass 69 — shared state base and halfword read cross-references

## Confirmed ROM evidence

A scan of 8 MiB ROM for the little-endian word `0x03000BE0` located **ten occurrences**, at `0x08049014`, `0x08049948`, `0x080499B0`, `0x08049A18`, `0x08049A7C`, `0x08049AE4`, `0x08049B58`, `0x08049BE4`, `0x08049C60`, and `0x08049CD4`. Each is consistent with a literal pool for a function in the state-related code region. This is a cross-reference inventory, not proof that each routine accesses the same member.

At `0x08049000`, `LDR r0, [pc,#0x10]` obtains `0x03000BE0`; `LDR r1,[r0,#0x0C]` reads the pointer at `0x03000BEC`; the code adds `0xEC`, reads a halfword, masks with `1`, and returns a Boolean. This **does not establish** who sets that bit or what the flag means.

At `0x08049040`, the source record's signed halfwords `+0x48` and `+0x4A` are loaded with `LDRSH`, shifted left by eight, and stored to the RAM motion state. This confirms a consumer of both fields; the earlier `0x08049078` routine writes them after applying an adjustment. The pair forms a read/update/write-back path. The object identity and units are not yet confirmed.

## Next investigation

Trace the pointer stored at `0x03000BEC` back through initialization and object allocation. The ten literal sites above narrow the relevant code neighborhood but do not independently prove a writer of bit 0 at object offset `+0xEC`. Inspect the downstream use of the record halfwords beyond the motion-state routines before naming them coordinates.

No Easter egg confirmed.
