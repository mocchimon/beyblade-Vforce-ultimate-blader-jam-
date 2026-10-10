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
