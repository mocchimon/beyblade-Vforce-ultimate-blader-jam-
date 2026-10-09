# Alternate render path: corrected dispatch evidence

## Dispatch stubs

- `0x08065C48`: `bx r4`.
- `0x08065C5C`: `bx r9`.

These are tail-dispatch stubs. They do not transform arguments.

## Confirmed branch in `0x08059334`

The renderer tests bit 0 of the halfword at child offset `+0x64`:

```asm
0805935C  adds r1, r6, #0
0805935E  adds r1, #0x64
08059362  ldrh r1, [r1]
08059364  ands r0, r1       ; r0 = field_64 & 1
08059368  beq 0x08059374
0805936A  ldr r1, [pc, #4]  ; literal at 0x08059370 = 0x08059521
0805936C  mov r9, r1
08059374  ldr r0, [pc, #0x84] ; literal at 0x080593FC = 0x0807D968
08059376  ldr r0, [r0]         ; [0x0807D968] = 0x0300646C
08059378  mov r9, r0
```

Correction: the two-way control flow is the inverse of the earlier prose description. When bit 0 is **set**, `r9` receives Thumb address `0x08059521`. When bit 0 is **clear**, the code reads the word at ROM `0x0807D968` (`0x0300646C`) and puts that value into `r9`. The exact branch target is subsequently reached through the `bx r9` tail dispatcher at `0x08065C5C`.

The code at `0x08059374` does not dereference `0x0300646C` in this excerpt: it loads the ROM word `0x0300646C` into `r9`. This distinction matters. The runtime slot itself is accessed by a different nearby path (consumer at `0x0805921C`), while this clipping path's register setup must be interpreted in its full calling context. Do not infer a final backend from the word value alone.

## Separate indirect path around `0x08059400`

When child byte `+0x7C` has bit 3 set, code at `0x080593D4–0x080593F4` routes through `0x08065C5C` using `r9`. When bit 3 is clear, code at `0x08059400` loads the ROM word at `0x0807D96C`, which is `0x0300682C`, into `r4` and calls the `bx r4` dispatcher at `0x08065C48`.

That establishes an indirect target of `0x0300682C` for this path, but not the origin of the executable bytes at that IWRAM address. One plausible explanation is that an IWRAM code fragment is installed there from ROM, but that requires proving the copy/setup path. The nearby routine beginning at `0x08059428` contains row-oriented DMA3 transfer code; it is **not yet proven** to be the value installed in either runtime slot.

## Current conclusions

- `0x08059520` is the confirmed DMA3 rectangle backend selected by child `+0x64` bit 0 set.
- `0x0807D968` contains the IWRAM address `0x0300646C`; that is a ROM table word, not the slot contents.
- `0x0807D96C` contains `0x0300682C`, used as an indirect target in a separate branch.
- The contents/installation of runtime code at `0x0300646C` and `0x0300682C` remain unresolved.
- `0x08059428` is retained as a neutral `sub_08059428` until its relationship to the IWRAM targets is demonstrated.

## Next proof target

Trace the code/data initialization that populates IWRAM addresses around `0x0300646C` and `0x0300682C`. Compare any discovered copy source against the candidate ROM routine bytes. Until that is established, no source-level alias is assigned to either runtime target.
