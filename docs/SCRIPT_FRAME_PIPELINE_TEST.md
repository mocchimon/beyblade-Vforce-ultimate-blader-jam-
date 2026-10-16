# Script-to-frame pipeline integration test

`tests/test_script_frame_pipeline.c` links five real reconstructed C modules:
`runtime_script.c`, `runtime_entries.c`, `runtime_entry_service.c`,
`math_runtime.c`, and `frame_dispatch.c`.

The harness maps synthetic IWRAM, IO, and a small ROM pointer region at their
GBA addresses. It runs a script selecting source index 3, allocating runtime
entry ID 7 with limit 12, then invokes `FrameEvent_Service` on a normal Timer0
interval. It asserts that:

- the interpreter allocates the real entry with serial `0x123`;
- the source pointer and entry limit are correct;
- the frame service calls the actual per-entry service;
- the callback sees window length 20 and threshold 77;
- the transfer callback sees one segment of length 20;
- the cursor advances by 20 bytes.

The callback itself and DMA/backend remain mocked: the test validates the
reconstructed control flow, **not** ROM matching, sound/graphics output,
real GBA hardware behavior, or unresolved IWRAM callback internals.

Run `make test-script-frame-pipeline` or `make test-all` on a Linux host with
low-address `mmap` support and non-PIE executable linking.
