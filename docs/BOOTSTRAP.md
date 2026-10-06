# Bootstrap reconstruction

## Cartridge entry

`0x08000000` contains `EA1FF9EB`, an ARM branch to `0x087FE7B4`.

## Relocation stub

`0x087FE7B4` copies `0x184C` bytes from `0x087FE7E4` to `0x020000C0`, then branches to the relocated block.

## Relocated block

The relocated startup:

1. Copies/clears the startup memory regions.
2. Initializes GBA display/hardware registers.
3. Builds the 0x03000014 table from data at `0x02000474`.
4. Copies a small routine to `0x03000000` and transfers execution there.
5. The IWRAM routine eventually transfers control to the main ROM startup at `0x080000C0`.

## ROM startup at 0x080000C0

The ARM startup:

- switches CPU modes and establishes stacks;
- clears IWRAM;
- copies initialized data into IWRAM;
- installs/dispatches the interrupt-related entry;
- selects a function pointer from the table around `0x03000DF0`;
- the relevant game entry pointer resolves to `0x080505A9` (Thumb).

`0x080505A9` therefore becomes the first major high-level game entry for the decompilation.
