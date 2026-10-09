/* Focused evidence excerpt for the runtime configuration consumer.
 * Addresses/words are taken from the supplied ROM; no ROM bytes are included.
 * See docs/RUNTIME_CONFIG_CONSUMER_FINDINGS.md for the control-flow caveat.
 *
 * 0806027E  4810  ldr r0, [pc, #0x40]  ; literal at 080602C0 = 0807D920
 * 08060280  6800  ldr r0, [r0]         ; [0807D920] = 0300717C
 * 08060282  F005 FCD9  bl 08065C38     ; 08065C38 is bx r0
 *
 * 08065C38  4700  bx r0
 * 08065C3A  46C0  mov r8, r8           ; alignment/padding
 */
