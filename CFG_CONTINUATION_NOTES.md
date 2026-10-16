# CFG continuation: conditional SWI and indirect interworking calls

- Conditional ARM SWI now preserves the non-taken fallthrough path.
- ARM and Thumb BLX(register) are recognized as indirect interworking calls, and the tracer follows the possible return continuation without guessing the callee ISA or destination.
- BX remains an indirect transfer and is not followed into unknown target code.
- Three regression tests cover the changes. `make test-all` passed.

This is tooling correctness work, not verified decompiled gameplay code. Source recovery estimate remains 54% pending ROM-backed analysis.
