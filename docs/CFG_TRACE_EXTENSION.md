# CFG trace extension (October 2026)

The candidate tracer now recognizes Thumb-1 two-halfword BL calls (including signed backwards displacements), and stops at ARM MOV PC,LR / LDMIA SP!,{...,PC} returns and Thumb SWI. It refuses malformed or truncated BL pairs. Callees are reported as call edges but are **not** traversed. This is still a heuristic: ROM data can decode as instructions, conditional ARM return detection is incomplete, and instruction sets/function boundaries are not verified.

Run `make test-candidate-cfg` for 12 synthetic tests. Run `make trace-candidate-cfg ROM=/path/to/legally-obtained.gba` for ROM-dependent candidate reports. No original ROM is bundled. Estimated 54% source recovery is unchanged; a 75% claim requires newly reconstructed, verified game code and an auditable coverage denominator.
