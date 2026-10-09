/* Instruction-level evidence for indirect render branches.
 * Addresses and instructions are transcribed from the supplied ROM.
 * No original ROM bytes are included in this project.
 */

/* 0x0805921C path: ROM table word -> direct IWRAM code target. */
/*
0805921C  4A0D  ldr  r2, [pc, #0x34]   ; literal 0x08059254 = 0x0807D968
0805923A  6814  ldr  r4, [r2]          ; [0x0807D968] = 0x0300646C
08059244  F00C FD00 bl   0x08065C48    ; shared tail: bx r4
08065C48  4720  bx   r4
*/

/* 0x08059334 path: alternate dispatch through r9. */
/*
08059374  4821  ldr  r0, [pc, #0x84]   ; literal 0x080593FC = 0x0807D968
08059376  6800  ldr  r0, [r0]          ; 0x0300646C
... r9 is set to the selected backend target ...
080593C8  F00C FC48 bl   0x08065C5C    ; shared tail: bx r9
08065C5C  4748  bx   r9
*/

/* Separate branch around 0x08059400:
08059400  4808  ldr  r0, [pc, #0x20]   ; literal 0x08059424 = 0x0807D96C
08059406  6804  ldr  r4, [r0]          ; [0x0807D96C] = 0x0300682C
08059410  F00C FC1A bl   0x08065C48    ; shared tail: bx r4
*/

/* Important: 0x0300646C and 0x0300682C are direct IWRAM branch targets,
 * not pointer variables at those addresses. The code installed there and
 * its ROM source are still unresolved. Do not alias them to 0x08059428
 * without proving the copy/installation relationship.
 */
