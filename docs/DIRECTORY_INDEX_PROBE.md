# Signed-index directory probe (2026-10-14)

Added a read-only ROM probe for the selection chain `0x0804AF08` -> `0x080629B4` -> `0x08062974`.
The latter uses `ldrsh`, so both negative and positive signed halfword indices are
valid *arithmetic inputs*. Whether the game actually changes any descriptor is unknown.

`make probe-directory-index ROM=/path/to/game.gba SLOT=0 INDEX=1` explores the
resource pointer at `table + 4 * 1` without modifying the ROM. Omit INDEX to
read the descriptor's stored index. This is an exploratory tool, **not** evidence
of gameplay selection or a safe bound for a particular table. A pointer resolving
to a valid resource header does not prove that it belongs to that table.

`make test-directory-index-probe` uses a synthetic ROM with a pointer immediately
before the table, a second pointer after it, shared directory aliases, and
malformed cases. No original ROM bytes are bundled.

Next reverse-engineering question: identify all writes or runtime mutations to
resource selection indices and map the 0x28-byte entry's consumers. The initial
ROM descriptor bytes are immutable; any dynamic changes may instead involve
other descriptors or runtime copies and must be demonstrated by instruction evidence.
