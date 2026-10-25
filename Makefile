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
	$(CC) -Iinclude -std=c11 -Wall -Wextra -Werror src/runtime_script.c src/runtime_pending_service.c tests/test_runtime_script.c -o build/tests/test_runtime_script
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

.PHONY: verify-resource-node-release-chain test-resource-node-release-chain
verify-resource-node-release-chain:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_resource_node_release_chain.py "$(ROM)"

test-resource-node-release-chain:
	python3 -m unittest discover -s tests -p 'test_resource_node_release_chain.py' -v

test-all: test-resource-node-release-chain

.PHONY: verify-resource-node-chain-ops test-resource-node-chain-ops
verify-resource-node-chain-ops:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_resource_node_chain_ops.py "$(ROM)"

test-resource-node-chain-ops:
	python3 -m unittest discover -s tests -p 'test_resource_node_chain_ops.py' -v

test-all: test-resource-node-chain-ops

.PHONY: verify-record-manager
verify-record-manager:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_record_manager.py "$(ROM)"

.PHONY: verify-runtime-object-records
verify-runtime-object-records:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_runtime_object_records.py "$(ROM)"

.PHONY: verify-runtime-object-record-transform test-runtime-object-record-transform
verify-runtime-object-record-transform:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_runtime_object_record_transform.py "$(ROM)"

test-runtime-object-record-transform:
	python3 -m unittest discover -s tests -p 'test_runtime_object_record_transform.py' -v

test-all: test-runtime-object-record-transform

.PHONY: verify-runtime-object-display-region test-runtime-object-display-region
verify-runtime-object-display-region:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_runtime_object_display_region.py "$(ROM)"

test-runtime-object-display-region:
	python3 -m unittest discover -s tests -p 'test_runtime_object_display_region.py' -v

test-all: test-runtime-object-display-region

.PHONY: verify-runtime-object-display-init test-runtime-object-display-init
verify-runtime-object-display-init:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_runtime_object_display_init.py "$(ROM)"

test-runtime-object-display-init:
	python3 -m unittest discover -s tests -p 'test_runtime_object_display_init.py' -v

test-all: test-runtime-object-display-init

.PHONY: verify-runtime-display-controls test-runtime-display-controls
verify-runtime-display-controls:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_runtime_display_controls.py "$(ROM)"

test-runtime-display-controls:
	python3 -m unittest discover -s tests -p 'test_runtime_display_controls.py' -v

test-all: test-runtime-display-controls

.PHONY: verify-runtime-background-dispatch test-runtime-background-dispatch
verify-runtime-background-dispatch:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_runtime_background_dispatch.py "$(ROM)"

test-runtime-background-dispatch:
	python3 -m unittest discover -s tests -p 'test_runtime_background_dispatch.py' -v

test-all: test-runtime-background-dispatch

.PHONY: verify-child-runtime-init-variant-c test-child-runtime-init-variant-c
verify-child-runtime-init-variant-c:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/the/original.gba' && exit 1)
	python3 tools/verify_child_runtime_init_variant_c.py "$(ROM)"

test-child-runtime-init-variant-c:
	python3 -m unittest discover -s tests -p 'test_child_runtime_init_variant_c.py' -v

test-all: test-child-runtime-init-variant-c

.PHONY: verify-runtime-display-state-record test-runtime-display-state-record
verify-runtime-display-state-record:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/the/original.gba' && exit 1)
	python3 tools/verify_runtime_display_state_record.py "$(ROM)"

test-runtime-display-state-record:
	python3 -m unittest discover -s tests -p 'test_runtime_display_state_record.py' -v

test-all: test-runtime-display-state-record

.PHONY: verify-runtime-display-state-helpers test-runtime-display-state-helpers
verify-runtime-display-state-helpers:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/the/original.gba' && exit 1)
	python3 tools/verify_runtime_display_state_helpers.py "$(ROM)"

test-runtime-display-state-helpers:
	python3 -m unittest discover -s tests -p 'test_runtime_display_state_helpers.py' -v

test-all: test-runtime-display-state-helpers

.PHONY: audit-iwram-target-03006fac test-iwram-target-03006fac
audit-iwram-target-03006fac:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/the/original.gba' && exit 1)
	python3 tools/audit_iwram_target_03006fac.py "$(ROM)"

test-iwram-target-03006fac:
	python3 -m unittest discover -s tests -p 'test_iwram_target_03006fac.py' -v

test-all: test-iwram-target-03006fac

.PHONY: verify-runtime-display-tile-blit test-runtime-display-tile-blit
verify-runtime-display-tile-blit:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/the/original.gba' && exit 1)
	python3 tools/verify_runtime_display_tile_blit.py "$(ROM)"

test-runtime-display-tile-blit:
	python3 -m unittest discover -s tests -p 'test_runtime_display_tile_blit.py' -v

test-all: test-runtime-display-tile-blit

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

.PHONY: verify-runtime-object-dispatch test-runtime-object-dispatch
verify-runtime-object-dispatch:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_runtime_object_dispatch.py "$(ROM)"

test-runtime-object-dispatch:
	python3 -m unittest discover -s tests -p 'test_runtime_object_dispatch.py' -v
	@mkdir -p build/tests
	$(CC) -std=c11 -Wall -Wextra -Werror -Iinclude src/runtime_object_selection_dispatch.c tests/test_runtime_object_selection_dispatch.c -o build/tests/test_runtime_object_selection_dispatch
	./build/tests/test_runtime_object_selection_dispatch

test-all: test-runtime-object-dispatch

.PHONY: verify-runtime-object-selection-finalize test-runtime-object-selection-finalize
verify-runtime-object-selection-finalize:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_runtime_object_selection_finalize.py "$(ROM)"

test-runtime-object-selection-finalize:
	python3 -m unittest discover -s tests -p 'test_runtime_object_selection_finalize.py' -v

test-all: test-runtime-object-selection-finalize

.PHONY: verify-runtime-object-selection-layout test-runtime-object-selection-layout
verify-runtime-object-selection-layout:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/the/original.gba' && exit 1)
	python3 tools/verify_runtime_object_selection_layout.py "$(ROM)"

test-runtime-object-selection-layout:
	python3 -m unittest discover -s tests -p 'test_runtime_object_selection_layout.py' -v

test-all: test-runtime-object-selection-layout

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

.PHONY: verify-runtime-display-state-operations test-runtime-display-state-operations
verify-runtime-display-state-operations:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_runtime_display_state_operations.py "$(ROM)"

test-runtime-display-state-operations:
	python3 -m unittest discover -s tests -p 'test_runtime_display_state_operations.py' -v

test-all: test-runtime-display-state-operations

.PHONY: verify-runtime-display-metric test-runtime-display-metric
verify-runtime-display-metric:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_runtime_display_metric.py "$(ROM)"

test-runtime-display-metric:
	python3 -m unittest discover -s tests -p 'test_runtime_display_metric.py' -v

test-all: test-runtime-display-metric

.PHONY: verify-runtime-display-sequence test-runtime-display-sequence
verify-runtime-display-sequence:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_runtime_display_sequence.py "$(ROM)"

test-runtime-display-sequence:
	python3 -m unittest discover -s tests -p 'test_runtime_display_sequence.py' -v

test-all: test-runtime-display-sequence

.PHONY: verify-runtime-display-byte-stream test-runtime-display-byte-stream
verify-runtime-display-byte-stream:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_runtime_display_byte_stream.py "$(ROM)"

test-runtime-display-byte-stream:
	python3 -m unittest discover -s tests -p 'test_runtime_display_byte_stream.py' -v

test-all: test-runtime-display-byte-stream

.PHONY: verify-collision-data-spline test-collision-data-spline
verify-collision-data-spline:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_collision_data_spline.py "$(ROM)"

test-collision-data-spline:
	python3 -m unittest discover -s tests -p 'test_collision_data_spline.py' -v

test-all: test-collision-data-spline


.PHONY: verify-collision-owned-segments test-collision-owned-segments
verify-collision-owned-segments:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/the/original.gba' && exit 1)
	python3 tools/verify_collision_data_owned_segments.py "$(ROM)"

test-collision-owned-segments:
	python3 -m unittest discover -s tests -p 'test_collision_data_owned_segments.py' -v

test-all: test-collision-owned-segments

.PHONY: verify-runtime-copy-callback test-runtime-copy-callback
verify-runtime-copy-callback:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/verify_runtime_copy_callback.py "$(ROM)"

test-runtime-copy-callback:
	python3 -m unittest discover -s tests -p 'test_runtime_copy_callback.py' -v

test-all: test-runtime-copy-callback

.PHONY: audit-runtime-image-bounds test-runtime-image-bounds
audit-runtime-image-bounds:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/audit_runtime_image_bounds.py "$(ROM)"

test-runtime-image-bounds:
	python3 -m unittest discover -s tests -p 'test_runtime_image_bounds.py' -v

test-all: test-runtime-image-bounds

.PHONY: audit-iwram-function-table test-iwram-function-table
audit-iwram-function-table:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/original.gba' && exit 2)
	python3 tools/audit_iwram_function_table.py "$(ROM)" --json build/reports/iwram_function_table_pass42.json

test-iwram-function-table:
	python3 -m unittest discover -s tests -p 'test_iwram_function_table.py' -v

.PHONY: audit-iwram-install-candidates test-iwram-install-candidates
audit-iwram-install-candidates:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/audit_iwram_install_candidates.py "$(ROM)" --json build/reports/iwram_install_candidates.json

test-iwram-install-candidates:
	python3 -m unittest discover -s tests -p 'test_iwram_install_candidates.py' -v

test-all: test-iwram-install-candidates

.PHONY: audit-runtime-copy-paths test-runtime-copy-paths
audit-runtime-copy-paths:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/original.gba' && exit 1)
	python3 tools/audit_runtime_copy_paths.py "$(ROM)" --json build/reports/runtime_copy_paths_pass44.json

test-runtime-copy-paths:
	python3 -m unittest discover -s tests -p 'test_runtime_copy_paths.py' -v

test-all: test-runtime-copy-paths

.PHONY: audit-arm-runtime-module test-arm-runtime-module
audit-arm-runtime-module:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/original.gba' && exit 1)
	python3 tools/audit_arm_runtime_module.py "$(ROM)" --json build/reports/arm_runtime_module_pass45.json

test-arm-runtime-module:
	python3 -m unittest discover -s tests -p 'test_arm_runtime_module.py' -v

test-all: test-arm-runtime-module

.PHONY: audit-startup-iwram-installer test-startup-iwram-installer verify-startup-iwram-installer
# Exact startup-installer audit; the ROM is supplied locally and never copied into the archive.
audit-startup-iwram-installer:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/original.gba' && exit 1)
	python3 tools/audit_startup_iwram_installer.py "$(ROM)" --json build/reports/startup_iwram_installer_pass46.json

verify-startup-iwram-installer: audit-startup-iwram-installer

test-startup-iwram-installer:
	python3 -m unittest discover -s tests -p 'test_startup_iwram_installer.py' -v

test-all: test-startup-iwram-installer

.PHONY: verify-runtime-display-attribute-mask test-runtime-display-attribute-mask
verify-runtime-display-attribute-mask:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/original.gba' && exit 1)
	python3 tools/verify_runtime_display_attribute_mask.py "$(ROM)"

test-runtime-display-attribute-mask:
	python3 -m unittest discover -s tests -p 'test_runtime_display_attribute_mask.py' -v

test-all: test-runtime-display-attribute-mask


.PHONY: audit-dma3-transfer-08065994 test-dma3-transfer-08065994
audit-dma3-transfer-08065994:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/audit_dma3_transfer_08065994.py "$(ROM)" --json build/reports/dma3_transfer_08065994.json

test-dma3-transfer-08065994:
	python3 -m unittest discover -s tests -p 'test_dma3_transfer_08065994.py' -v

test-all: test-dma3-transfer-08065994

.PHONY: audit-input-mask-callers test-input-mask-callers
audit-input-mask-callers:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/audit_input_mask_callers.py "$(ROM)" --json docs/input_mask_callers_pass50.json

test-input-mask-callers:
	python3 -m unittest discover -s tests -p 'test_input_mask_callers.py' -v

test-all: test-input-mask-callers

.PHONY: audit-input-mask-semantics-pass51 test-input-mask-semantics-pass51
audit-input-mask-semantics-pass51:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/audit_input_mask_semantics_pass51.py "$(ROM)" --json docs/input_mask_semantics_pass51.json

test-input-mask-semantics-pass51:
	python3 -m unittest discover -s tests -p 'test_input_mask_semantics_pass51.py' -v

test-all: test-input-mask-semantics-pass51

.PHONY: audit-runtime-base-pointer test-runtime-base-pointer
audit-runtime-base-pointer:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/audit_runtime_base_pointer.py "$(ROM)" --json docs/runtime_base_pointer_xrefs_pass52.json

test-runtime-base-pointer:
	python3 -m unittest discover -s tests -p 'test_runtime_base_pointer.py' -v

test-all: test-runtime-base-pointer

.PHONY: audit-runtime-base-slot-writes test-runtime-base-slot-writes
audit-runtime-base-slot-writes:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/audit_runtime_base_slot_writes.py "$(ROM)" --json docs/runtime_base_slot_write_candidates_pass53.json

test-runtime-base-slot-writes:
	python3 -m unittest discover -s tests -p 'test_runtime_base_slot_writes.py' -v

test-all: test-runtime-base-slot-writes

.PHONY: audit-sub-08051090 test-sub-08051090
audit-sub-08051090:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/audit_sub_08051090.py "$(ROM)" --json docs/sub_08051090_control_flow_pass54.json

test-sub-08051090:
	python3 -m unittest discover -s tests -p 'test_sub_08051090_audit.py' -v

test-all: test-sub-08051090

.PHONY: audit-runtime-context-init-pass55 test-runtime-context-init-pass55
audit-runtime-context-init-pass55:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/audit_runtime_context_init_pass55.py "$(ROM)" --json docs/runtime_context_init_pass55.json

test-runtime-context-init-pass55:
	python3 -m unittest discover -s tests -p 'test_runtime_context_init_pass55.py' -v

test-all: test-runtime-context-init-pass55

.PHONY: audit-runtime-context-followup-pass56 test-runtime-context-followup-pass56
audit-runtime-context-followup-pass56:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/audit_runtime_context_followup_pass56.py "$(ROM)" --json docs/runtime_context_followup_pass56.json

test-runtime-context-followup-pass56:
	python3 -m unittest discover -s tests -p 'test_runtime_context_followup_pass56.py' -v

test-all: test-runtime-context-followup-pass56

.PHONY: audit-runtime-helpers-pass57 test-runtime-helpers-pass57
audit-runtime-helpers-pass57:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/audit_runtime_helpers_pass57.py "$(ROM)" --json docs/runtime_helpers_pass57.json
test-runtime-helpers-pass57:
	python3 -m unittest discover -s tests -p 'test_runtime_helpers_pass57.py' -v
test-all: test-runtime-helpers-pass57


.PHONY: audit-runtime-state-setter-pass58 test-runtime-state-setter-pass58
audit-runtime-state-setter-pass58:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/audit_runtime_state_setter_pass58.py "$(ROM)" --json docs/runtime_state_setter_pass58.json

test-runtime-state-setter-pass58:
	python3 -m unittest discover -s tests -p 'test_runtime_state_setter_pass58.py' -v

test-all: test-runtime-state-setter-pass58

.PHONY: audit-state-switch-pass59 test-state-switch-pass59
audit-state-switch-pass59:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/audit_state_switch_pass59.py "$(ROM)" --json docs/state_switch_pass59.json

test-state-switch-pass59:
	python3 -m unittest discover -s tests -p 'test_state_switch_pass59.py' -v

test-all: test-state-switch-pass59
