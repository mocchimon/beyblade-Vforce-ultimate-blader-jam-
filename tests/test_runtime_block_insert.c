#include <assert.h>
#include <stdint.h>
#include <stdio.h>

typedef struct RuntimeBlockRecord {
    uint32_t start_index;
    uint32_t slot_count;
    uint32_t payload;
    struct RuntimeBlockRecord *previous;
    struct RuntimeBlockRecord *next;
} RuntimeBlockRecord;

int32_t RuntimeBlock_InsertInList(uint32_t slot_count,
                                  RuntimeBlockRecord *head,
                                  RuntimeBlockRecord *record);

int main(void)
{
    RuntimeBlockRecord a = {0, 40, 1, 0, 0};
    RuntimeBlockRecord b = {80, 30, 2, &a, 0};
    RuntimeBlockRecord c = {0, 0, 0, 0, 0};
    int32_t result;

    a.next = &b;
    result = RuntimeBlock_InsertInList(32, &a, &c);
    assert(result == 40);
    assert(a.next == &c && c.previous == &a);
    assert(c.next == &b && b.previous == &c);
    assert(c.start_index == 0); /* caller fills descriptor payload fields */

    /* The 40-slot gap is now occupied by the caller-selected record size. */
    c.start_index = (uint32_t)result;
    c.slot_count = 32;
    {
        RuntimeBlockRecord d = {0, 0, 0, 0, 0};
        assert(RuntimeBlock_InsertInList(9, &a, &d) == -1);
        assert(d.previous == 0 && d.next == 0);
    }

    /* No tail gap is returned; the allocator's high-water path owns append. */
    {
        RuntimeBlockRecord only = {0, 20, 1, 0, 0};
        RuntimeBlockRecord d = {0, 0, 0, 0, 0};
        assert(RuntimeBlock_InsertInList(4, &only, &d) == -1);
    }

    puts("Runtime block insertion: gap placement and list links passed");
    return 0;
}
