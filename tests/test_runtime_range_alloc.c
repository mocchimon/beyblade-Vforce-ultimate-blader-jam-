#define _GNU_SOURCE
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#define BASE 0x03000000u
#define SIZE 0x10000u
#define U32(x) (*(uint32_t *)(uintptr_t)(x))
#define U16(x) (*(uint16_t *)(uintptr_t)(x))
#define ACTIVE 0x03005DC8u
#define SPARE 0x03005DD8u
#define A 0x03002000u
#define B 0x03002008u
#define C 0x03002010u
extern int32_t RuntimeRange_Alloc(uint32_t requested);
extern void RuntimeRange_Release(int32_t token, uint32_t amount);
static void reset(void) { memset((void *)(uintptr_t)BASE, 0, SIZE); }
static void node(uint32_t addr, uint16_t start, uint16_t length, uint32_t next) {
    U16(addr)=start; U16(addr+2)=length; U32(addr+4)=next;
}
int main(void) {
    void *p=mmap((void *)(uintptr_t)BASE,SIZE,PROT_READ|PROT_WRITE,
                 MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED_NOREPLACE,-1,0);
    if (p==MAP_FAILED) { perror("mmap"); return 2; }
    assert((uintptr_t)p==BASE);
    reset(); node(A,10,20,0); U32(ACTIVE)=A;
    assert(RuntimeRange_Alloc(5)==10);
    assert(U16(A)==15 && U16(A+2)==15);

    reset(); node(A,10,3,B); node(B,40,10,0); U32(ACTIVE)=A;
    assert(RuntimeRange_Alloc(5)==40);
    assert(U16(A)==10 && U16(A+2)==3 && U16(B)==45 && U16(B+2)==5);

    reset(); node(A,10,5,B); node(B,40,10,0); U32(ACTIVE)=A; U32(SPARE)=C;
    assert(RuntimeRange_Alloc(5)==10);
    assert(U32(ACTIVE)==B && U32(SPARE)==A && U32(A+4)==C);

    reset(); node(A,10,3,B); node(B,40,5,C); node(C,80,10,0); U32(ACTIVE)=A;
    assert(RuntimeRange_Alloc(5)==40);
    assert(U32(A+4)==C && U32(SPARE)==B);

    reset(); node(A,10,5,0); U32(ACTIVE)=A;
    assert(RuntimeRange_Alloc(5)==10);
    assert(U32(ACTIVE)==A && U32(SPARE)==0 && U16(A+2)==0 && U16(A)==15);
    assert(RuntimeRange_Alloc(1)==-1);

    reset(); assert(RuntimeRange_Alloc(1)==-1);

    reset(); node(A,100,20,0); U32(ACTIVE)=A; U32(SPARE)=B;
    assert(RuntimeRange_Alloc(12)==100);
    RuntimeRange_Release(100,12);
    assert(U16(A)==100 && U16(A+2)==20);

    puts("runtime range-allocation tests: PASS (7 scenarios)");
    assert(munmap(p,SIZE)==0);
    return 0;
}
