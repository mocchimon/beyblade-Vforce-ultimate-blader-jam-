# 0x08062B50: callback-induced table replacement

Source evidence: `asm/pass5/sub_62b44.thumb.s`, especially 0x08062B6A,
0x08062B80-0x08062B90. The routine reads the active flag from the current
`[0x03005E28]` table, invokes 0x08062AB4 with the selected word, then **reloads**
`[0x03005E28]` before clearing the flag. The previously reconstructed buffer
helper cached the pointer and could therefore clear the wrong table if a
callback replaced it.

This pass adds `RuntimePending_ServiceDynamic`, a table-provider variant used
by `sub_08062B50`, and retains the fixed-buffer wrapper for existing tests.
The new regression swaps the table in the callback and confirms that the
replacement table's active flag is cleared while the old flag remains set.

## Important reconciliation

`src/runtime_script.c` already has `RuntimeScript_Stop` assigned to the *same*
ROM address, 0x08062B50, while `src/runtime_pending_service.c` exports
`sub_08062B50`. These are two C representations of one original routine, not
two separately recovered functions. Do not count them twice or link both as
independent game functionality. A future integration pass should unify the
interface, and verify whether `RuntimeEntry_Deactivate` corresponds to the
0x08062AB4 callback. This pass does not claim that equivalence.

Verification: `make check`, `make test-pending`, and `make test-all` passed.
No original ROM or byte-matching build was available. Source recovery estimate
remains 54%.
