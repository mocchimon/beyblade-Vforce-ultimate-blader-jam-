# Matching-ROM plan and current blockers

A matching ROM means that a ROM built from the reconstruction compares byte for
byte with the supplied original image, not merely that it boots or has matching
recovered functions.

## Current validated baseline

- Original image: GBA ROM, 8,388,608 bytes; game code `BEYP`, revision 0.
- Original image SHA-256: `a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce`.
- Reconstructed C units: 61, compile successfully with the available Clang
  ARM7TDMI target.
- Relocatable integration object: `build/ultimate_blader_jam.partial.o`;
  `.text` is `0x84E6` bytes before final placement and still has relocations.
- `make test-all` passes, including ROM-verifier unit tests; Pass 39/40 focused
  verifiers also pass against the supplied original image.
- No candidate `.gba` has been produced. Matching progress is therefore still
  0%; source-recovery estimates are not byte-coverage metrics.

## Blockers before a meaningful comparison

1. **Fixed memory map:** recovered functions need to be placed at original
   addresses, including Thumb/ARM state boundaries, literal pools, alignment,
   and section order.
2. **Original toolchain:** compiler version, optimization settings, ABI flags,
   assembler behavior, and linker behavior are not yet identified. Different
   compilers can produce different machine code for semantically equivalent C.
3. **Missing code/data:** some IWRAM code is installed at runtime; the installer
   and source bytes for targets including `0x03007034` remain unresolved.
   Numerous functions, tables, compressed resources, and assets are also not
   fully reconstructed.
4. **ROM container details:** a final build must preserve the exact ROM size,
   header, padding, embedded data, and any checksums/fixed fields at the correct
   offsets.

## Comparison workflow

1. Keep a clean copy of the original ROM outside the repository.
2. Build a candidate only after the linker map and placement are explicit.
3. Run `make compare-rom ROM=/path/to/original.gba CANDIDATE=/path/to/candidate.gba`.
4. Use the emitted mismatch spans to prioritize the earliest and largest
   differences. A matching source function with different machine code is a
   toolchain/codegen issue; an absent region is a recovery/layout issue.
5. Repeat until the candidate size and every byte match. Never fill unknown
   regions by silently copying bytes from the original into the candidate and
   then describe the result as a source-built matching ROM.
