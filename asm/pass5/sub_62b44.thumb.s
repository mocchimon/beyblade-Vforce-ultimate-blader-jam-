
00000000 <rom>:
   62b44: 4901         	ldr	r1, [pc, #0x4]          @ 0x62b4c <rom+0x62b4c>
   62b46: 6008         	str	r0, [r1]
   62b48: 4770         	bx	lr
   62b4a: 0000         	movs	r0, r0
   62b4c: 5e14         	ldrsh	r4, [r2, r0]
   62b4e: 0300         	lsls	r0, r0, #0xc
   62b50: b5f0         	push	{r4, r5, r6, r7, lr}
   62b52: b081         	sub	sp, #0x4
   62b54: 4815         	ldr	r0, [pc, #0x54]         @ 0x62bac <rom+0x62bac>
   62b56: 6800         	ldr	r0, [r0]
   62b58: 2801         	cmp	r0, #0x1
   62b5a: d123         	bne	0x62ba4 <rom+0x62ba4>   @ imm = #0x46
   62b5c: 2100         	movs	r1, #0x0
   62b5e: 4a14         	ldr	r2, [pc, #0x50]         @ 0x62bb0 <rom+0x62bb0>
   62b60: 2600         	movs	r6, #0x0
   62b62: 00c8         	lsls	r0, r1, #0x3
   62b64: 1c4f         	adds	r7, r1, #0x1
   62b66: 1840         	adds	r0, r0, r1
   62b68: 0085         	lsls	r5, r0, #0x2
   62b6a: 6810         	ldr	r0, [r2]
   62b6c: 1829         	adds	r1, r5, r0
   62b6e: 00f4         	lsls	r4, r6, #0x3
   62b70: 1908         	adds	r0, r1, r4
   62b72: 7900         	ldrb	r0, [r0, #0x4]
   62b74: 2800         	cmp	r0, #0x0
   62b76: d00c         	beq	0x62b92 <rom+0x62b92>   @ imm = #0x18
   62b78: 1c08         	adds	r0, r1, #0x0
   62b7a: 3008         	adds	r0, #0x8
   62b7c: 1900         	adds	r0, r0, r4
   62b7e: 6800         	ldr	r0, [r0]
   62b80: 9200         	str	r2, [sp]
   62b82: f7ff ff97    	bl	0x62ab4 <rom+0x62ab4>   @ imm = #-0xd2
   62b86: 9a00         	ldr	r2, [sp]
   62b88: 6810         	ldr	r0, [r2]
   62b8a: 1828         	adds	r0, r5, r0
   62b8c: 1900         	adds	r0, r0, r4
   62b8e: 2100         	movs	r1, #0x0
   62b90: 7101         	strb	r1, [r0, #0x4]
   62b92: 3601         	adds	r6, #0x1
   62b94: 2e03         	cmp	r6, #0x3
   62b96: d9e8         	bls	0x62b6a <rom+0x62b6a>   @ imm = #-0x30
   62b98: 1c39         	adds	r1, r7, #0x0
   62b9a: 290f         	cmp	r1, #0xf
   62b9c: d9e0         	bls	0x62b60 <rom+0x62b60>   @ imm = #-0x40
   62b9e: 4903         	ldr	r1, [pc, #0xc]          @ 0x62bac <rom+0x62bac>
   62ba0: 2000         	movs	r0, #0x0
   62ba2: 6008         	str	r0, [r1]
   62ba4: b001         	add	sp, #0x4
   62ba6: bcf0         	pop	{r4, r5, r6, r7}
   62ba8: bc01         	pop	{r0}
   62baa: 4700         	bx	r0
   62bac: 5e0c         	ldrsh	r4, [r1, r0]
   62bae: 0300         	lsls	r0, r0, #0xc
   62bb0: 5e28         	ldrsh	r0, [r5, r0]
   62bb2: 0300         	lsls	r0, r0, #0xc
   62bb4: 4803         	ldr	r0, [pc, #0xc]          @ 0x62bc4 <rom+0x62bc4>
   62bb6: 6800         	ldr	r0, [r0]
   62bb8: 2800         	cmp	r0, #0x0
   62bba: d002         	beq	0x62bc2 <rom+0x62bc2>   @ imm = #0x4
   62bbc: 4902         	ldr	r1, [pc, #0x8]          @ 0x62bc8 <rom+0x62bc8>
   62bbe: 2001         	movs	r0, #0x1
