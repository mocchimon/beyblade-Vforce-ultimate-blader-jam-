#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
static uint32_t seen[64];
static unsigned count;
static void callback(uint32_t value, void *unused) { (void)unused; seen[count++] = value; }
extern void RuntimePending_ServiceBuffer(volatile uint8_t *, volatile uint32_t *, void (*)(uint32_t, void *), void *);
static void put32(uint8_t *p, uint32_t v) { for (int i=0;i<4;i++) p[i]=(uint8_t)(v>>(8*i)); }
typedef volatile uint8_t *(*Provider)(void *);
extern void RuntimePending_ServiceDynamic(Provider, void *, volatile uint32_t *,
                                          void (*)(uint32_t, void *), void *);
typedef struct { uint8_t *current; uint8_t *replacement; unsigned calls; } Swap;
static volatile uint8_t *get_table(void *ctx) {
    Swap *s=(Swap *)ctx; s->calls++; return s->current;
}
static void swap_callback(uint32_t value, void *ctx) {
    Swap *s=(Swap *)ctx; seen[count++]=value; s->current=s->replacement;
}
void RuntimeEntry_Deactivate(uint32_t serial) { callback(serial, NULL); }
int main(void) {
    uint8_t b[16*36+4] = {0}; uint32_t enabled=0;
    b[4]=1; put32(b+8,0x12345678);
    RuntimePending_ServiceBuffer(b,&enabled,callback,0);
    assert(count==0 && b[4]==1);
    enabled=1; RuntimePending_ServiceBuffer(b,&enabled,callback,0);
    assert(count==1 && seen[0]==0x12345678 && b[4]==0 && enabled==0);
    memset(b,0,sizeof b); enabled=1; count=0;
    b[4]=1; put32(b+8,11); b[36+3*8+4]=1; put32(b+36+3*8+8,22);
    b[15*36+4]=1; put32(b+15*36+8,33);
    RuntimePending_ServiceBuffer(b,&enabled,callback,0);
    assert(count==3 && seen[0]==11 && seen[1]==22 && seen[2]==33);
    /* Callback switches table; clear must target the NEW table, not old. */
    {
        uint8_t old[16*36+4]={0}, newer[16*36+4]={0};
        Swap sw={old,newer,0};
        old[4]=1; newer[4]=1; put32(old+8,0xdeadbeef);
        enabled=1; count=0;
        RuntimePending_ServiceDynamic(get_table,&sw,&enabled,swap_callback,&sw);
        assert(count==1 && seen[0]==0xdeadbeef);
        assert(old[4]==1 && newer[4]==0 && enabled==0 && sw.calls>=2);
    }
    puts("pending service tests passed");
}
