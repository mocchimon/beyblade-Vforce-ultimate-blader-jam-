#define _GNU_SOURCE
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#define BASE 0x03000000u
#define SIZE 0x00010000u
#define U32(x) (*(uint32_t *)(uintptr_t)(x))
#define U16(x) (*(uint16_t *)(uintptr_t)(x))
#define ACTIVE 0x03005DC8u
#define SPARE 0x03005DD8u
#define A 0x03002000u
#define B 0x03002010u
#define C 0x03002020u
#define D 0x03002030u
extern void RuntimeRange_Release(int32_t token, uint32_t amount);
static void reset(void) { memset((void *)(uintptr_t)BASE, 0, SIZE); }
static void node(uint32_t a, uint16_t start, uint16_t length, uint32_t next) {
    U16(a)=start; U16(a+2)=length; U32(a+4)=next;
}
int main(void) {
    void *p=mmap((void *)(uintptr_t)BASE,SIZE,PROT_READ|PROT_WRITE,
                 MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED_NOREPLACE,-1,0);
    if(p==MAP_FAILED) { perror("mmap"); return 2; }
    assert((uintptr_t)p==BASE);
    /* Extend an interval backward. */
    reset(); node(A,100,20,0); U32(ACTIVE)=A;
    RuntimeRange_Release(80,20);
    assert(U16(A)==80 && U16(A+2)==40 && U32(ACTIVE)==A);
    /* Extend an interval forward. */
    reset(); node(A,100,20,0); U32(ACTIVE)=A;
    RuntimeRange_Release(120,15);
    assert(U16(A)==100 && U16(A+2)==35);
    /* Insert a disjoint interval before the head using a spare. */
    reset(); node(A,100,20,0); node(B,0,0,C); node(C,0,0,0);
    U32(ACTIVE)=A; U32(SPARE)=B;
    RuntimeRange_Release(50,10);
    assert(U32(ACTIVE)==B && U16(B)==50 && U16(B+2)==10);
    assert(U32(B+4)==A && U32(SPARE)==C);
    /* Bridge two intervals and recycle the absorbed successor. */
    reset(); node(A,100,20,B); node(B,140,20,0); U32(ACTIVE)=A;
    RuntimeRange_Release(120,20);
    assert(U16(A)==100 && U16(A+2)==60 && U32(A+4)==0);
    assert(U32(SPARE)==B && U32(B+4)==0);
    /* Coalesce a chain of consecutive successors. */
    reset(); node(A,100,20,B); node(B,140,10,C); node(C,150,10,0);
    U32(ACTIVE)=A; U32(SPARE)=D;
    RuntimeRange_Release(120,20);
    assert(U16(A)==100 && U16(A+2)==60 && U32(A+4)==0);
    assert(U32(SPARE)==C && U32(C+4)==B && U32(B+4)==D);
    /* Spare exhaustion preserves an unmodified list. */
    reset(); node(A,100,20,0); U32(ACTIVE)=A;
    RuntimeRange_Release(50,10);
    assert(U32(ACTIVE)==A && U16(A)==100 && U16(A+2)==20);
    /* Empty-list guard in C reconstruction. */
    reset(); RuntimeRange_Release(100,10);
    assert(U32(ACTIVE)==0);
    puts("runtime range-release tests: PASS (7 scenarios)");
    assert(munmap(p,SIZE)==0);
    return 0;
}
