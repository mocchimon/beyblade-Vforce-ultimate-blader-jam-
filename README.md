# Beyblade V-Force: Ultimate Blader Jam — decompilation

Source-reconstruction project for the supplied `BEYP70` Rev.00 GBA ROM.

This is **not** a Windows recompiler. The goal is readable source, recovered structures/data, and eventually a conventional GBA decompilation project that can serve as the technical source of truth for an Unreal remake.

## Verified ROM

- Size: 8 MiB
- Game code: `BEYP70`
- Revision: `00`
- CRC32: `9C93DE35`
- SHA-1: `8d2cdd3ece0ab7d2f982b0a83e3ecb878f514a72`

## Current RE milestones

1. Cartridge entry `0x08000000` resolved to relocation bootstrap `0x087FE7B4`.
2. Bootstrap relocation recovered: `0x184C` bytes from `0x087FE7E4` → `0x020000C0`.
3. Relocated startup path mapped through IWRAM setup.
4. ARM startup at `0x080000C0` analyzed far enough to resolve the high-level game entry.
5. High-level entry identified at `0x080505A9` (Thumb).
6. Initial Thumb initialization call graph extracted.

See `docs/BOOTSTRAP.md`, `docs/MAIN_ENTRY.md`, and `src/main.c`.
