#include <stdint.h>
#include <stdio.h>
void sub_08057B64(void);
void sub_08057C5C(const void *, uint32_t);
int main(void) {
    sub_08057B64();
    sub_08057C5C((const void *)(uintptr_t)0x08755278u, 0xDEADBEEFu);
    puts("PASS: diagnostic stubs return normally");
    return 0;
}
