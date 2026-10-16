# Directory literal-load candidates

`make classify-directory-literals ROM=/path/to/original.gba` takes the raw aligned
non-directory xrefs from `scan_directory_xrefs.py` and searches for nearby ARM
and Thumb PC-relative word loads whose computed address equals the literal's
ROM address. It reports the candidate instruction address, ISA, and destination
register. ARM negative-offset loads are included.

**Interpretation:** A match is only a possible literal-pool reference. This
scanner does not distinguish code from data, does not resolve branch targets,
does not show stores to signed selection descriptors, and does not prove runtime
execution. Check candidate addresses in a real disassembler before assigning
functions or gameplay semantics. The original ROM is required for real findings.

Synthetic tests: `make test-directory-literals`.
