#define _GNU_SOURCE
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#define U32(x) (*(uint32_t *)(uintptr_t)(x))
#define U16(x) (*(uint16_t *)(uintptr_t)(x))
extern void RuntimeRange_Reset(uint32_t reserved);
static unsigned releases;
void RuntimeRange_Release(int32_t token, uint32_t size) { assert(token==48 && size==8); releases++; }
int main(void) {
 void *p=mmap((void*)0x03000000,65536,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED_NOREPLACE,-1,0);
 assert(p!=(void*)-1); memset(p,0,65536);
 U32(0x03005DCC)=0x03002000;
 U32(0x03005DE4)=0x03003000;
 U16(0x03003000+0x20)=0; U16(0x03003000+0x16)=8; U32(0x03003000+0x24)=48;
 RuntimeRange_Reset(0x24);
 assert(releases==1 && U32(0x03003000+0x24)==UINT32_MAX);
 assert(U32(0x03005DC8)==0x03002000 && U32(0x03005DD8)==0x03002008);
 assert(U16(0x03002000)==0x24 && U16(0x03002002)==0x3dc);
 assert(U32(0x03002004)==0 && U32(0x03005E6C)==0x24);
 uint32_t n=U32(0x03005DD8); unsigned count=0;
 while(n){assert(n==0x03002008+count*8);n=U32(n+4);assert(++count<=31);}
 assert(count==31);
 puts("runtime range initialization: PASS");
 return 0;
}
