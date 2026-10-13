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
	$(CC) -std=c11 -Wall -Wextra -Werror src/runtime_script.c tests/test_runtime_script.c -o build/tests/test_runtime_script
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

.PHONY: check-upstream-rom test-upstream-rom
check-upstream-rom:
	@test -n "$(ROM)" || (echo 'Set ROM=/path/to/your.gba' && exit 1)
	python3 tools/check_upstream_rom.py "$(ROM)"

test-upstream-rom:
	python3 tests/test_upstream_rom.py

test-all: test-upstream-rom

.PHONY: test-runtime-entries
test-runtime-entries:
	@mkdir -p build/tests
	$(CC) -std=c11 -Wall -Wextra -Werror src/runtime_entries.c tests/test_runtime_entries.c -o build/tests/test_runtime_entries
	./build/tests/test_runtime_entries

test-all: test-runtime-entries
