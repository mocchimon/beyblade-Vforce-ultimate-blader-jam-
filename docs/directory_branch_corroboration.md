# Directory literal-load branch corroboration

Run `make corroborate-directory-loads ROM=/path/to/original.gba` to scan raw ROM bytes for direct ARM B/BL and Thumb B/Bcond references to previously identified literal-load candidates. This produces JSON with branch source addresses and counts. `make test-directory-branch-corroboration` runs four synthetic tests.

Limitations: both load and branch encodings may be ordinary data; mixed ARM/Thumb mode and code boundaries are not established; Thumb BL/BLX and indirect branches are not modeled; a direct branch to a candidate does not prove reachability or gameplay semantics. Inspect ROM-specific candidates manually before marking any function recovered. No ROM was included in this archive or used to validate game-specific findings. Estimated source recovery remains 54%.
