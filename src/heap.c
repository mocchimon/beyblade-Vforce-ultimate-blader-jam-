#include <stdint.h>
#include "runtime.h"

/*
 * Recovered from 0x0805A3CC-0x0805A608.
 *
 * Heap_Alloc/Heap_AllocAlt return a 0x10-byte allocation descriptor, not the
 * allocated payload.  Descriptor layout is { address, size, prev, next }.
 * The main heap uses IWRAM [0x03001160, 0x03005C80); the alternate heap uses
 * EWRAM [0x02000400, 0x02040000).  Each heap has a 0x20-entry descriptor pool.
 */
typedef struct HeapBlock {
    uint32_t address;
    uint32_t size;
    struct HeapBlock *prev;
    struct HeapBlock *next;
} HeapBlock;

#define REG32(addr) (*(volatile uint32_t *)(uintptr_t)(addr))
#define MAIN_DESCRIPTOR_POOL REG32(0x03005C80u)
#define ALT_DESCRIPTOR_POOL  REG32(0x03005C90u)
#define MAIN_HEAD            ((HeapBlock **)(uintptr_t)0x03005C84u)
#define MAIN_ALLOC_COUNT     REG32(0x03005C88u)
#define ALT_HEAD             ((HeapBlock **)(uintptr_t)0x03001150u)
#define ALT_ARENA_BASE       REG32(0x03001154u)
#define ALT_ALLOC_COUNT      REG32(0x0300115Cu)
#define MAIN_ARENA_BASE      0x03001160u
#define MAIN_ARENA_SIZE      0x00004B20u
#define ALT_ARENA_SIZE       0x0003FC00u
#define EWRAM_LIMIT          0x0203FFFFu

extern void sub_08057C5C(const void *message, uint32_t argument);

void *Heap_FindAvailable(void *pool, uint32_t count)
{
    HeapBlock *block = (HeapBlock *)pool;

    while (count != 0) {
        if (block->size == 0 && block->address == 0)
            return block;
        ++block;
        --count;
    }

    sub_08057C5C((const void *)0x08755278u, 0);
    return 0;
}

/*
 * Insert a newly allocated range into the address-sorted list.  The original
 * routine accepts the arena bounds, current list head, free descriptor, and
 * address of the head pointer as stack arguments.
 */
void *Heap_InsertBlock(uint32_t size, uint32_t arena_base,
                       uint32_t arena_size, void *current_head,
                       void *descriptor, void *head_pointer)
{
    HeapBlock *block = (HeapBlock *)descriptor;
    HeapBlock *current = (HeapBlock *)current_head;
    HeapBlock **head = (HeapBlock **)head_pointer;
    uint32_t arena_end = arena_base + arena_size;

    if (size == 0 || size > arena_size)
        return 0;

    if (current == 0) {
        block->address = arena_base;
        block->size = size;
        block->prev = 0;
        block->next = 0;
        *head = block;
        return block;
    }

    /* The first block may leave a sufficiently large gap before it. */
    if (current->address >= arena_base &&
        current->address - arena_base >= size) {
        block->address = arena_base;
        block->size = size;
        block->prev = 0;
        block->next = current;
        current->prev = block;
        *head = block;
        return block;
    }

    while (current != 0) {
        uint32_t current_end = current->address + current->size;
        HeapBlock *next = current->next;

        if (next != 0) {
            if (next->address >= current_end &&
                next->address - current_end >= size) {
                block->address = current_end;
                block->size = size;
                block->prev = current;
                block->next = next;
                current->next = block;
                next->prev = block;
                return block;
            }
        } else if (current_end <= arena_end &&
                   arena_end - current_end >= size) {
            block->address = current_end;
            block->size = size;
            block->prev = current;
            block->next = 0;
            current->next = block;
            return block;
        }

        current = next;
    }

    return 0;
}

static void *Heap_AllocFrom(uint32_t size, uint32_t pool_base,
                            uint32_t arena_base, uint32_t arena_size,
                            HeapBlock **head, uint32_t *allocation_count,
                            const void *failure_message)
{
    HeapBlock *descriptor = (HeapBlock *)Heap_FindAvailable(
        (void *)(uintptr_t)pool_base, 0x20);
    HeapBlock *result;

    if (descriptor == 0)
        return 0;

    result = (HeapBlock *)Heap_InsertBlock(size, arena_base, arena_size,
                                           *head, descriptor, head);
    if (result == 0) {
        sub_08057C5C(failure_message, size);
        return 0;
    }

    ++*allocation_count;
    return result;
}

/* 0x0805A3CC — small-object IWRAM heap. */
void *Heap_Alloc(uint32_t size)
{
    return Heap_AllocFrom(size, MAIN_DESCRIPTOR_POOL, MAIN_ARENA_BASE,
                          MAIN_ARENA_SIZE, MAIN_HEAD,
                          (uint32_t *)(uintptr_t)0x03005C88u,
                          (const void *)0x087551E4u);
}

/* 0x0805A444 — larger EWRAM heap. */
void *Heap_AllocAlt(uint32_t size)
{
    return Heap_AllocFrom(size, ALT_DESCRIPTOR_POOL, ALT_ARENA_BASE,
                          ALT_ARENA_SIZE, ALT_HEAD,
                          (uint32_t *)(uintptr_t)0x0300115Cu,
                          (const void *)0x0875521Cu);
}

/* 0x0805A4BC — unlink a descriptor and return its slot to the zero pool. */
void Heap_Free(void *descriptor)
{
    HeapBlock *block = (HeapBlock *)descriptor;
    HeapBlock *prev = block->prev;
    HeapBlock *next = block->next;
    uint32_t address = block->address;

    if (address == 0)
        sub_08057C5C((const void *)0x08755254u, 0);

    if (prev != 0) {
        prev->next = next;
    } else if (address <= EWRAM_LIMIT) {
        *ALT_HEAD = next;
    } else {
        *MAIN_HEAD = next;
    }

    if (next != 0)
        next->prev = prev;

    if (address <= EWRAM_LIMIT)
        --ALT_ALLOC_COUNT;
    else
        --MAIN_ALLOC_COUNT;

    block->address = 0;
    block->size = 0;
    block->prev = 0;
    block->next = 0;
}
