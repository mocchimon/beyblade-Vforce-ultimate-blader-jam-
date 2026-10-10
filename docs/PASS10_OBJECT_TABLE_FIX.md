# Runtime object-table allocation correction (`0x08062370`, `0x08062490`)

A fresh instruction-by-instruction pass found that the previous C draft had
misidentified `0x080661E4` as an allocator. It is an unsigned division helper.
The allocation at `0x080624F0` is the main heap entry `0x0805A3CC`, and the
second allocation at `0x08062518` is the alternate heap entry `0x0805A444`.

## Corrected allocation-size derivation

The initializer first clamps the requested count to `0x10` and the base value
to `0xABEA`. It then computes:

```c
n = ((base / 0x28) + 0x0F) & ~0x0F;
*(u16 *)0x03005E4C = n;
*(u16 *)0x03005E18 = -n;
main_heap_descriptor = Heap_Alloc(3 * n + 40 * count);
aux_heap_descriptor = Heap_AllocAlt(0x440);
```

The previous source had incorrectly multiplied the entire size expression by
eight and called an unresolved `RuntimeObject_Alloc`. This is now corrected.
The returned values are descriptors: the routine stores the descriptors at
`0x03005E2C` and `0x03005E30`, then reads their first words as payload
addresses for `0x03005E1C` and `0x03005E28`.

## Cleanup path at `0x08062370`

`RuntimeObject_Prepare` now reflects the observed cleanup path: when the main
descriptor exists, the routine clears four hardware control/data registers,
frees the main descriptor and (if present) the auxiliary descriptor, then
clears the recorded payload pointers, derived table pointer, descriptor slot,
and derived table pointer. It does not attempt to free the payload addresses.

## Confidence boundaries

The division, alignment, byte-count expression, allocator call targets, and
payload-vs-descriptor distinction are directly supported by the instructions.
The semantic names of the allocated tables and the broader hardware role of
the four cleared registers remain provisional.
