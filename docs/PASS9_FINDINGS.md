# Pass 9 findings

## Runtime resource selector: 0x0804AF08 / 0x0804AF60

The two routines are part of a small resource-handle lifecycle rather than
being gameplay handlers.

`0x0804AF60` checks the halfword at `0x03000FB0 + 0xC26`.  A value of `-1`
means no resource is selected. Otherwise it loads the handle at
`0x03000FB0 + 0xC2C`, passes it to `0x08062AB4`, and finally writes `0xFFFF`
to the selector field.

`0x0804AF08` writes its argument to the same selector field. It indexes the
ROM table at `0x08075640` using an 8-byte stride, passing the two table words
to `0x080629B4`. The returned value is stored at `+0xC2C`. It then loads the
halfword at `*(0x03000F48) + 0x6E6` and passes the handle and that value to
`0x08062AF8`.

## Entry status helpers

`0x08062A74` searches a runtime list for a matching key. Each list entry is
0x28 bytes and its status byte is at `+0x16`.

- `0x08062AB4`: status -> 0
- `0x08062AC8`: status -> 2
- `0x08062ADC`: status 2 -> 1
- `0x08062AF8`: updates the found entry's halfword at `+0x10`, capped at 0x100
- `0x08062B18`: updates the found entry's pointer at `+0x08` from the table at
  `0x03000D98`, with the index capped at 0x7F

These names remain intentionally resource-oriented/neutral; the actual
meaning of the resource table entries is still unresolved.
