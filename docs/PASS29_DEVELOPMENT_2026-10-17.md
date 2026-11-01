# Development pass 29 — 2026-10-17

## Background control and enable fields

Recovered five routines in the display-control block:

- `0x08059C3C` replaces the low two bits in BG0CNT through BG3CNT from four
  byte-truncated arguments, retaining each register's other low-byte bits.
- `0x08059CEC` performs the same update for one selected BG control register.
- `0x08059D14` reads the low two bits of one selected BG control register.
- `0x08059CD8` selects a register using the byte at record `+0x5E`, then reads
  its low two bits.
- `0x08059D28` sets or clears the selected BG0–BG3 enable bit in DISPCNT and
  ignores indices above three.

The ROM check matched **218 Thumb halfwords across ten ranges**, decoded
**12 direct calls** (five incoming calls and seven calls to the existing BG
control-register selector), and checked **four DISPCNT mask literals**. The
four-register and single-register writers both preserve all bits except the
low two. The standalone getter at `0x08059D14` has no direct caller in the
full-ROM Thumb-BL scan; all five confirmed incoming callers remain unrecovered
in C.

All **84 Python tests** passed, and libclang parsed all **51 C translation
units** for ARM7TDMI with zero diagnostics. The historical overall completion
estimate remains **~54%**, unchanged and not measured coverage. Matching-ROM
progress remains **0%**.

The new translation unit is in the Makefile's default Thumb source set. Actual
object ISA/interworking properties cannot be checked without the ARM compiler
and object inspection tools.

No ARM objects, partial link, or candidate ROM were produced: this host lacks
an ARM C compiler/linker and `make`, and the original GBA linker layout is not
recovered. The display transfer at `0x08059334` remains an indirect-dispatch
placeholder, so pixel equivalence is still unverified.
