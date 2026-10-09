# IWRAM install routine: confirmed copy range

## Directly recovered from `0x08057968`

This routine is not a generic EWRAM startup copy. It programs DMA3 for an immediate 32-bit transfer:

- Source: `0x08000168`
- Destination: `0x03000FE0` (IWRAM)
- End source address: `0x0800026C` (exclusive)
- Transfer size: `0x104` bytes = `0x41` 32-bit words
- DMA control: `0x84000041` (enable, 32-bit transfer, immediate timing, 65 words)
- After programming DMA3, stores `0x03000FE0` at `0x03007FFC`

The transfer is initiated by the DMA enable bit. This proves that a ROM block is installed into IWRAM during startup, and that the destination is published through `0x03007FFC`. It does **not** yet prove that this block populates the separate runtime addresses `0x0300646C`, `0x0300682C`, or `0x0300717C`; those are far outside the copied `0x03000FE0..0x030010E4` range.

## Why this matters for the outstanding render target

The mixed table at `0x0807D920` contains IWRAM addresses, and code around `0x0806027E` indirectly branches through the first word (`0x0300717C`). The startup-installed block is a real example of ROM-to-IWRAM code/data setup, but it cannot explain the render target slots by itself because its destination range does not overlap them. The next step is to identify other DMA3/CPU copy sites or resource-install routines whose destination range covers the `0x03006xxx` / `0x03007xxx` regions.

## Evidence limits

The source bytes at `0x08000168` are ARM-mode code/data rather than a Thumb stream; do not interpret that block as ordinary Thumb instructions. Its runtime role should be established from how the installed destination at `0x03000FE0` is called or read.
