#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

typedef struct { uint32_t source, plus10, table, field0c; uint16_t limit; uint8_t unk[2]; uint16_t field14; uint8_t status, field17; uint32_t serial, field1c, field20; uint16_t field24; uint8_t pad[2]; } Entry;
extern int32_t RuntimeEntry_Alloc(uint32_t,uint32_t);
extern int32_t RuntimeEntry_AllocIndexed(uint32_t,uint32_t);
extern Entry *RuntimeEntry_Find(uint32_t);
extern void RuntimeEntry_Deactivate(uint32_t);
extern void RuntimeEntry_SetStatus2(uint32_t);
extern void RuntimeEntry_AdvanceStatus(uint32_t);
extern void RuntimeEntry_SetLimit(uint32_t,uint32_t);
extern void RuntimeEntry_SetPointer(uint32_t,uint32_t);
extern int RuntimeEntry_IsActive(uint32_t);
#define AT32(a) (*(uint32_t *)(uintptr_t)(a))
#define CHECK(x) do { if (!(x)) { fprintf(stderr,"failed line %d: %s\n",__LINE__,#x); return 1; } } while(0)
int main(void) {
 void *ram=mmap((void *)0x03000000u,0x10000,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED,-1,0);
 CHECK(ram!=MAP_FAILED); memset(ram,0,0x10000);
 Entry *e=(Entry *)(uintptr_t)0x03003000u;
 uint32_t *table=(uint32_t *)(uintptr_t)0x03004000u;
 AT32(0x03005E24)=0x03003000u; *(uint8_t *)(uintptr_t)0x03005E04u=2;
 AT32(0x03005E9C)=100; AT32(0x03000D98)=0x03004000u;
 table[0]=0x1111; table[127]=0x7777;
 CHECK(sizeof(Entry)==0x28);
 CHECK(RuntimeEntry_Alloc(0x08001000,250)==100);
 CHECK(e[0].status==1 && e[0].source==0x08001000 && e[0].plus10==0x08001010);
 CHECK(e[0].table==0x7777 && e[0].limit==256);
 CHECK(RuntimeEntry_Alloc(0x08002000,0)==101);
 CHECK(RuntimeEntry_Alloc(0x08003000,0)==-1);
 CHECK(RuntimeEntry_Find(100)==&e[0] && RuntimeEntry_IsActive(101));
 RuntimeEntry_SetLimit(100,999); CHECK(e[0].limit==256);
 RuntimeEntry_SetLimit(100,17); CHECK(e[0].limit==17);
 RuntimeEntry_SetStatus2(100); CHECK(e[0].status==2);
 RuntimeEntry_AdvanceStatus(100); CHECK(e[0].status==1);
 RuntimeEntry_SetPointer(100,0); CHECK(e[0].table==0x1111);
 RuntimeEntry_Deactivate(100); CHECK(!RuntimeEntry_IsActive(100));
 CHECK(RuntimeEntry_Alloc(0x08004000,0)==102 && e[0].serial==102);
 CHECK(RuntimeEntry_Find(100)==0 && RuntimeEntry_Find(102)==&e[0]);
 /* Indexed allocation reads signed 16-bit index from secondary descriptor. */
 uint32_t *sources=(uint32_t *)(uintptr_t)0x03005000u;
 int16_t *secondary=(int16_t *)(uintptr_t)0x03006000u;
 sources[1]=0x08009000u; *secondary=1;
 RuntimeEntry_Deactivate(101);
 CHECK(RuntimeEntry_AllocIndexed(0x03005000u,0x03006000u)==103);
 CHECK(e[1].source==0x08009000u && e[1].field1c==0x03005000u && e[1].field20==0x03006000u && e[1].field24==1);
 CHECK(e[1].table==0x1111);
 puts("runtime entry lifecycle tests passed"); return 0;
}
