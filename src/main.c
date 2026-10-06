#include "gba.h"

/*
 * Reconstructed high-level entry reached by the original startup code.
 *
 * Original entry pointer: 0x080505A9 (Thumb)
 * Code address:           0x080505A8
 *
 * This is intentionally semantic C, not claimed to be the exact original
 * source. Function names will be replaced as each callee is understood.
 */

void sub_08057968(void);
void sub_080579CC(void);
void sub_08057A18(void);
void sub_08057940(void);
void sub_0805A374(void);
void sub_0805A890(void);
void sub_080574CC(void);
void sub_08063A74(void);
void sub_08063A8C(int, int);
void sub_08063AA0(int);
void sub_0805FEF4(void);
void sub_08062490(void);
void sub_08062B44(void);
void sub_08062E94(void);
void sub_08060544(void);
void sub_080532DC(void);
void sub_08051090(void);
void sub_08055CDC(void);
void sub_08058940(void);
void sub_0805EFC0(void);
void sub_08052538(void);
void sub_080578FC(void);
void sub_08062814(void);
void sub_0805A6DC(void);
void sub_08053398(void);
void sub_0805193C(void);
void sub_08053BB8(void);
void sub_08053CD8(void);
void sub_080517A4(void);
void sub_080512D0(void);
void sub_08062798(void);
void sub_0805AC4C(void);
void sub_080578EC(void);
void sub_080578E8(void);
void sub_080578E4(void);
void sub_080578F8(void);

/* The original code stores a pointer into this global during startup. */
volatile uint32_t *const g_MainHardwarePtr = (volatile uint32_t *)0x03000FB0;

void Game_Main(void)
{
    /* Initial hardware/state setup. */
    sub_08057968();
    sub_080579CC();
    sub_08057A18();
    sub_08057940();
    sub_0805A374();
    sub_0805A890();
    sub_080574CC();

    /* Register/configuration table setup. */
    sub_08063A74();
    sub_08063A8C(0, 0);
    sub_08063A8C(3, 1);
    sub_08063A8C(4, 2);
    sub_08063A8C(5, 3);
    sub_08063A8C(7, 4);
    sub_08063AA0(0);

    /* Remaining subsystem initialization. */
    sub_0805FEF4();
    sub_08062490();
    sub_08062B44();
    sub_08062E94();
    sub_08060544();
    sub_080532DC();
    sub_08051090();
    sub_08055CDC();
    sub_08058940();

    /* Main game enters its persistent update path below. */
    for (;;) {
        sub_0805EFC0();
        sub_08052538();

        /* More initialization/update work follows in the original block. */
        sub_080578FC();
        sub_08062814();
        sub_0805A6DC();
        sub_08053398();
        sub_0805193C();
        sub_08053BB8();
        sub_08053CD8();
        sub_080517A4();
        sub_080512D0();
        sub_08062798();
        sub_0805AC4C();
        sub_080578EC();
        sub_080578E8();
        sub_080578E4();
        sub_080578F8();
    }
}
