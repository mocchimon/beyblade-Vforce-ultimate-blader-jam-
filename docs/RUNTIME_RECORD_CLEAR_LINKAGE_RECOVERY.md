# Runtime-record clear linkage (`0x08050388`)

## Recovery

`GameState_FramePrepare` calls ROM entry `0x08050388` with its state record at
`+0x458`. The source previously retained the address-named import
`sub_08050388`, while the recovered implementation already existed as
`RuntimeRecord_Clear` in `src/object_record.c`. The caller now uses that
recovered name through `include/runtime_record.h`, closing this source-level
linkage gap.

## Corrected writes

The original instructions at `0x08050388` write zero to manager offsets `+4`,
`+8`, `+0xC`, `+0xE`, `+0x10`, and `+0x14`. They do not write the record pointer
at `+0x00`. The earlier C body incorrectly cleared that pointer; it now leaves
it intact and clears only the observed fields. The manager is 0x18 bytes, and
its child records also use a 0x18-byte stride.

## Validation limits

The call-to-definition match is verified at source level, and the C frontend
parses the updated ARM7TDMI-targeted units. The regression suite checks the
caller name and the fields changed by the clear routine. No object-symbol
inventory or partial link is available in this environment because `make`,
the command-line compiler, and ARM object tools are missing. This correction
does not change the historical overall completion estimate.
