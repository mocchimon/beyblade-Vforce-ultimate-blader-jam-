#include "gba.h"
#include <stdint.h>

/*
 * High-level startup entry recovered at ROM address 0x080505A8 (Thumb).
 *
 * This is deliberately kept close to the recovered control flow.  The old
 * draft incorrectly treated this as a conventional "main game loop" and
 * assigned arbitrary subsystem names.  At this stage it is more accurate to
 * preserve the call graph and name only functions whose behavior is known.
 */

void System_InstallIwramBlock(void);          /* 0x08057968 */
void System_DisplayInit(uint16_t);          /* 0x080579CC */
void System_SetDisplayFlags(uint16_t);      /* 0x08057A18 */
void System_Dma3StateInit(void);             /* 0x08057940 */

void sub_0805A374(void);
void ControlState_Init(void);
void sub_080574CC(void);
void Input_ResetMappings(void);
void Input_SetMapping(int, int);
void Input_SetState(int);
void sub_0805FEF4(int, int, int);
void sub_08062490(void *, int);
void sub_08062B44(int);
void sub_08062E94(void);
void Runtime_ResetPools(int, int);
void sub_080532DC(void);
void sub_08051090(void);
void sub_08055CDC(void);
void sub_08058940(void);
void sub_0805EFC0(void *, int);
void sub_08052538(void);
void sub_080578FC(void);
void sub_08062814(void);
void sub_0805A6DC(void);
void sub_08053398(void);
void sub_0805193C(void);
void sub_08053BB8(void);
void sub_08053CD8(void);
int  Input_TestMask(int);
void sub_080512D0(void);
void sub_08062798(void);
void sub_08049268(void);
void sub_0804945C(void);
void sub_0805AC4C(int, int, int, int);
void sub_080578EC(int, int);
void sub_080578E8(int, int);
void sub_080578E4(int, void *, uint32_t);
void sub_080578F8(uint32_t);

void UBJ_Startup(void)
{
    /* 0x080505B2 .. 0x080505CE */
    System_InstallIwramBlock();
    System_DisplayInit(8);
    System_SetDisplayFlags(0x11);
    System_Dma3StateInit();
    sub_0805A374();
    ControlState_Init();
    sub_080574CC();

    /* 0x080505D2 .. 0x08050600 */
    Input_ResetMappings();
    Input_SetMapping(0, 0);
    Input_SetMapping(3, 1);
    Input_SetMapping(4, 2);
    Input_SetMapping(5, 3);
    Input_SetMapping(7, 4);
    Input_SetState(0);

    /* 0x08050604 onward: subsystem/resource initialization. */
    sub_0805FEF4(2, 0x10, 3);
    sub_08062490((void *)0x08112B2Cu, 2);
    sub_08062B44(0x08040CC4);
    sub_08062E94();
    Runtime_ResetPools(0x80, 0x20);
    sub_080532DC();
    sub_08051090();
    sub_08055CDC();
    sub_08058940();

    /*
     * The original code does NOT simply fall through into a generic game
     * tick.  It repeatedly performs VBlank/display work and then polls a
     * state function.  Keep that structure intact until the callees are
     * semantically identified.
     */
    for (;;) {
        sub_0805EFC0((void *)((*(uint32_t *)0x03000FB0u) + 0xBA0), 0);
        sub_08052538();

        sub_08049268(); /* 0x08049268: provisional GameState_FramePrepare */

        /* 0x08050656 .. 0x08050694 */
        Runtime_ResetPools(0x80, 0x20);
        sub_0804945C(); /* 0x0804945C: provisional GameState_FrameDispatch */
        sub_080578FC();
        sub_08062814();
        sub_0805A6DC();
        Runtime_ResetPools(0x80, 0x20);
        sub_08053398();
        sub_0805193C();
        sub_08053BB8();
        sub_08053CD8();
        /* The original tests the same mask once here. */
        if (Input_TestMask(2) == 0)
            sub_080512D0();
    }
}
