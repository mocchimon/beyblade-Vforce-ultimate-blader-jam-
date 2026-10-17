# Bounded candidate CFG exploration

`make trace-candidate-cfg ROM=/path/to/original.gba` traces up to 20 directory-load candidates, with a limit of 64 decoded instruction positions per seed.

For a targeted address:

`python3 tools/trace_candidate_cfg.py /path/to/original.gba --address 0x08000000 --isa ARM --max-instructions 128`

The tracer supports ARM B/BL and Thumb B/Bcond, and stops at recognized BX or Thumb POP {PC} returns. ARM BL callees are recorded as edges but not traversed. Thumb long branches are deliberately stopped rather than misdecoded. It does not handle indirect calls, mode transitions, full Thumb BL decoding, code/data separation, or verified function boundaries. Any reported control-flow graph is a hypothesis requiring independent ROM disassembly and dynamic verification.
