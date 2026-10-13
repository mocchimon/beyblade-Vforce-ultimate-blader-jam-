# Runtime script interpreter (`0x08062C48`)

The routine at `0x08062C48` is a compact bytecode interpreter. It is now reconstructed in `src/runtime_script.c` (`RuntimeScript_Service`); the original
Thumb instructions are preserved in
`asm/runtime/runtime_script_62c48_62e74.thumb.dis.txt`.

## State and pacing

- `0x03005E0C`: interpreter state; processing occurs only when it equals `1`.
- `0x03005E08`: signed countdown. Each service call subtracts the step value;
  if the result remains positive, no bytecode is consumed.
- `0x03005E10`: countdown step. Opcode `0xB2` replaces this with a big-endian
  32-bit immediate.
- `0x03005E00`: pointer to the current bytecode cursor.
- `0x03005E20`: saved cursor used by opcode `0xB0`.
- `0x03005E28`: 16-record table, each record `0x24` bytes with four 8-byte
  runtime-entry slots beginning at offset `+4`.
- `0x03005E14`: descriptor whose `+0x0C` field points to the table used by
  opcode family `0xC`.

The interpreter continues consuming commands while the countdown is zero or
negative. A non-high-bit opcode and its following byte form a 16-bit delay,
shifted left by 16 and added to the countdown.

## Opcode families observed

| High nibble | Recovered behavior |
|---|---|
| `0x8` | Read an identifier and remove the matching runtime entry from one of four slots in the selected record. The second operand byte is skipped. |
| `0x9` | Read identifier and limit; if not already present, allocate a runtime entry from the selected record's source pointer, set its limit, and store its serial in a free slot. |
| `0xA` | No-op in the observed dispatch path. |
| `0xB0` | Replace the current bytecode cursor with the saved cursor at `0x03005E20`. |
| `0xB1` | Skip one byte. |
| `0xB2` | Read a big-endian 32-bit value into the countdown step at `0x03005E10`. |
| `0xB3` | Call the game's error/report routine with message pointer `0x08755E38`; the message's exact intent remains unverified. |
| `0xC` | Read an index byte and replace the selected record's source pointer using the pointer table reached through descriptor `0x03005E14 + 0x0C`. |
| `0xD` | Skip one byte. |

All families use the low nibble to select one of the 16 script records when the
operation is record-indexed. Names above describe instruction behavior rather
than claiming the script's gameplay purpose.

## Validation and open questions

The interpreter and its helper structures compile for ARM7TDMI with no
warnings. The bytecode has not yet been replayed under an emulator, so exact
runtime equivalence is not claimed. The meanings of the source-record fields,
script opcodes at the game-design level, and the error message remain open.

## Descriptor and lifecycle controls

The adjacent control routines are also represented in `src/runtime_script.c`:

- `0x08062B44` stores the descriptor pointer at `0x03005E14`.
- `0x08062B50` stops an active interpreter, deactivates each occupied entry in
  all 16 records, clears those slot-active bytes, and sets state `0x03005E0C`
  to zero. If the interpreter is not active, it returns without clearing.
- `0x08062BCC` checks the requested index against the count at descriptor
  offset `+0`, stops an already active interpreter, loads a pair of cursor
  values from the descriptor table at `+8` (8-byte entries), clears countdown
  and step, and enables the interpreter.

The corresponding original instructions are preserved in
`asm/runtime/runtime_script_control_62b44_62c48.thumb.dis.txt`.

## Host-side behavioral tests

`make test-script` runs the interpreter against a small simulated IWRAM region
and stubbed entry-manager functions. It currently verifies descriptor/indexed
start, delay scheduling, entry creation and removal, `0xB2` step replacement,
`0xB0` cursor jump, `0xC` source-pointer selection, and stop cleanup. These
checks exercise the recovered C logic but are not a substitute for comparing
against real game execution in a GBA emulator.
