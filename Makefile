# Compile-only support for the reconstructed source tree.
# This is NOT a linkable/matching-ROM build; many original functions/data
# symbols remain unresolved and original linker layout is not recovered.

CC = clang
TARGET_FLAGS := --target=armv4t-none-eabi -mcpu=arm7tdmi -ffreestanding -fno-builtin -Iinclude
C_SOURCES := $(wildcard src/*.c)
OBJECTS := $(patsubst src/%.c,build/objects/%.o,$(C_SOURCES))
ARM_STATE_SOURCES := src/arm_rasterizer.c src/arm_rasterizer_tables.c

.PHONY: all check clean
all: check

check: $(OBJECTS)
	@echo "Compiled $(words $(OBJECTS)) source files to ARM7TDMI object files."
	@echo "This validates compilation only; it does not produce a ROM."

build/objects/%.o: src/%.c
	@mkdir -p build/objects
	@if echo " $(ARM_STATE_SOURCES) " | grep -q " $< "; then \
	  $(CC) $(TARGET_FLAGS) -marm -std=c11 -Wall -Wextra -c "$<" -o "$@"; \
	else \
	  $(CC) $(TARGET_FLAGS) -mthumb -std=c11 -Wall -Wextra -c "$<" -o "$@"; \
	fi

clean:
	rm -rf build

.PHONY: test-math
test-math:
	@mkdir -p build/tests
	$(CC) -std=c11 -Wall -Wextra -Werror src/math_runtime.c tests/test_math_runtime.c -o build/tests/test_math_runtime
	./build/tests/test_math_runtime

.PHONY: test-script
test-script:
	@mkdir -p build/tests
	$(CC) -std=c11 -Wall -Wextra -Werror src/runtime_script.c src/runtime_pending_service.c tests/test_runtime_script.c -o build/tests/test_runtime_script
	./build/tests/test_runtime_script


.PHONY: test-block
test-block:
	@mkdir -p build/tests
	$(CC) -std=c11 -Wall -Wextra -Werror src/runtime_block_insert.c tests/test_runtime_block_insert.c -o build/tests/test_runtime_block_insert
	./build/tests/test_runtime_block_insert


.PHONY: test-resource-node
test-resource-node:
	@mkdir -p build/tests
	$(CC) -std=c11 -Wall -Wextra -Werror -Iinclude src/resource_node.c tests/test_resource_node.c -o build/tests/test_resource_node
	./build/tests/test_resource_node

.PHONY: test-all
test-all: test-math test-script test-block test-resource-node

.PHONY: test-range
test-range:
	@mkdir -p build/tests
	$(CC) -std=c11 -Wall -Wextra -Werror src/runtime_range.c tests/test_runtime_range.c -o build/tests/test_runtime_range
	./build/tests/test_runtime_range

test-all: test-range

.PHONY: test-range-init
test-range-init:
	@mkdir -p build/tests
	$(CC) -std=c11 -Wall -Wextra -Werror src/runtime_range_init.c tests/test_runtime_range_init.c -o build/tests/test_runtime_range_init
	./build/tests/test_runtime_range_init

test-all: test-range-init

.PHONY: test-range-alloc
test-range-alloc:
	@mkdir -p build/tests
	$(CC) -std=c11 -Wall -Wextra -Werror src/runtime_range_alloc.c src/runtime_range.c tests/test_runtime_range_alloc.c -o build/tests/test_runtime_range_alloc
	./build/tests/test_runtime_range_alloc

test-all: test-range-alloc

# Resource metadata verification requires a locally supplied original ROM.
# No ROM bytes are emitted or included in project archives.
.PHONY: verify-resources test-resource-manifest
verify-resources:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_resource_manifest.py "$(ROM)"

test-resource-manifest:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tests/test_resource_manifest.py "$(ROM)"

.PHONY: audit-resource-directory test-resource-directory
audit-resource-directory:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/audit_resource_directory.py "$(ROM)"

test-resource-directory:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tests/test_resource_directory_audit.py "$(ROM)"

.PHONY: verify-alias-resources test-alias-resources
verify-alias-resources:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_alias_resources.py "$(ROM)"

.PHONY: verify-resource-node-validator
verify-resource-node-validator:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_resource_node_validator.py "$(ROM)"

.PHONY: verify-record-manager
verify-record-manager:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_record_manager.py "$(ROM)"

.PHONY: verify-runtime-object-records
verify-runtime-object-records:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_runtime_object_records.py "$(ROM)"

.PHONY: verify-runtime-object-selection test-runtime-object-selection
verify-runtime-object-selection:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_runtime_object_selection.py "$(ROM)"

test-runtime-object-selection:
	python3 -m unittest discover -s tests -p 'test_runtime_object_selection.py' -v

test-all: test-runtime-object-selection

.PHONY: verify-resource-node-selection test-resource-node-selection
verify-resource-node-selection:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_resource_node_selection.py "$(ROM)"

test-resource-node-selection:
	python3 -m unittest discover -s tests -p 'test_resource_node_selection.py' -v

test-all: test-resource-node-selection

test-alias-resources:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tests/test_alias_resources.py "$(ROM)"

.PHONY: check-resource-coverage test-resource-coverage
check-resource-coverage:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/check_resource_coverage.py "$(ROM)"

test-resource-coverage:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tests/test_resource_coverage.py "$(ROM)"

.PHONY: trace-resource-references test-resource-references
trace-resource-references:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/trace_resource_references.py "$(ROM)"

test-resource-references:
	python3 tests/test_resource_references.py

test-all: test-resource-references

.PHONY: trace-directory-runtime test-directory-runtime
trace-directory-runtime:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/trace_directory_runtime.py "$(ROM)"

test-directory-runtime:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tests/test_directory_runtime.py "$(ROM)"

.PHONY: audit-directory-descriptors test-directory-descriptors
audit-directory-descriptors:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/audit_directory_descriptor_storage.py "$(ROM)"

test-directory-descriptors:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tests/test_directory_descriptor_storage.py "$(ROM)"

# Deterministic directory tests that do not require copyrighted ROM data.
.PHONY: test-directory-synthetic
test-directory-synthetic:
	python3 tests/test_directory_synthetic.py

test-all: test-directory-synthetic

.PHONY: probe-directory-index test-directory-index-probe
probe-directory-index:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	@test -n "$(SLOT)" || (echo 'Set SLOT=0..31' && exit 1)
	python3 tools/probe_directory_indices.py "$(ROM)" --slot "$(SLOT)" $(if $(INDEX),--index "$(INDEX)",)

test-directory-index-probe:
	python3 tests/test_directory_index_probe.py

test-all: test-directory-index-probe

.PHONY: analyze-directory-aliases test-directory-alias-analysis
analyze-directory-aliases:
	@test -n "$(ROM)" || (echo "Set ROM=/path/to/original.gba"; exit 1)
	python3 tools/analyze_directory_aliases.py "$(ROM)" --summary

test-directory-alias-analysis:
	python3 tests/test_directory_alias_analysis.py

test-all: test-directory-alias-analysis

.PHONY: scan-directory-xrefs test-directory-xrefs
scan-directory-xrefs:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/original.gba' && exit 1)
	python3 tools/scan_directory_xrefs.py "$(ROM)"

test-directory-xrefs:
	python3 tests/test_directory_xrefs.py

test-all: test-directory-xrefs

.PHONY: classify-directory-literals test-directory-literals
classify-directory-literals:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/original.gba' && exit 1)
	python3 tools/classify_directory_literals.py "$(ROM)"

test-directory-literals:
	python3 tests/test_directory_literal_candidates.py

test-all: test-directory-literals

.PHONY: corroborate-directory-loads test-directory-branch-corroboration
corroborate-directory-loads:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/original.gba' && exit 1)
	python3 tools/corroborate_directory_loads.py "$(ROM)"

test-directory-branch-corroboration:
	python3 tests/test_directory_branch_corroboration.py

test-all: test-directory-branch-corroboration

.PHONY: trace-candidate-cfg test-candidate-cfg
trace-candidate-cfg:
	@test -n "$(ROM)" || (echo "Set ROM=/path/to/original.gba"; exit 1)
	python3 tools/trace_candidate_cfg.py "$(ROM)"

test-candidate-cfg:
	cd tools && python3 -m unittest -v test_candidate_cfg

test-all: test-candidate-cfg

.PHONY: audit-linkage test-linkage-audit
audit-linkage: check
	python3 tools/audit_linkage.py

test-linkage-audit:
	python3 -m unittest discover -s tests -p 'test_linkage_audit.py' -v

test-all: test-linkage-audit

.PHONY: triage-unresolved test-unresolved-triage
triage-unresolved: audit-linkage
	python3 tools/triage_unresolved.py

test-unresolved-triage:
	python3 -m unittest discover -s tests -p 'test_unresolved_triage.py' -v

test-all: test-unresolved-triage

.PHONY: audit-assembly-evidence test-assembly-evidence
audit-assembly-evidence:
	python3 tools/audit_assembly_evidence.py

test-assembly-evidence:
	python3 -m unittest discover -s tests -p 'test_assembly_evidence.py' -v

.PHONY: test-pending
test-pending:
	@mkdir -p build/tests
	$(CC) -std=c11 -Wall -Wextra -Werror src/runtime_pending_service.c tests/test_runtime_pending_service.c -o build/tests/test_runtime_pending_service
	./build/tests/test_runtime_pending_service

test-all: test-pending

# A true byte-for-byte ROM comparison requires a separately built candidate ROM.
# This target never fabricates a candidate from source objects.
.PHONY: compare-rom test-compare-rom
compare-rom:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/original.gba'; exit 1)
	@test -n "$(CANDIDATE)" || (echo 'Set CANDIDATE=/path/to/rebuilt.gba'; exit 1)
	python3 tools/compare_rom.py "$(ROM)" "$(CANDIDATE)" --json build/reports/rom_comparison.json

test-compare-rom:
	python3 -m unittest discover -s tests -p 'test_compare_rom.py' -v

test-all: test-compare-rom

.PHONY: test-entries partial-link
# Host-based behavioral checks for the recovered runtime entry pool.
test-entries:
	@mkdir -p build/tests
	$(CC) -std=c11 -Wall -Wextra -Werror src/runtime_entries.c tests/test_runtime_entries.c -o build/tests/test_runtime_entries
	./build/tests/test_runtime_entries

test-all: test-entries

# Relocatable integration link: catches duplicate definitions and ABI-level
# relocation issues, but does not imply that the game can boot.
partial-link: check
	$(CC) --target=armv4t-none-eabi -fuse-ld=lld -nostdlib -Wl,-r $(OBJECTS) -o build/ultimate_blader_jam.partial.o
	@echo 'Produced relocatable integration object (not a ROM).'
