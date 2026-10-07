
00000000 <rom>:
   512d0: b5f0         	push	{r4, r5, r6, r7, lr}
   512d2: 4657         	mov	r7, r10
   512d4: 464e         	mov	r6, r9
   512d6: 4645         	mov	r5, r8
   512d8: b4e0         	push	{r5, r6, r7}
   512da: 480f         	ldr	r0, [pc, #0x3c]         @ 0x51318 <rom+0x51318>
   512dc: 6800         	ldr	r0, [r0]
   512de: 490f         	ldr	r1, [pc, #0x3c]         @ 0x5131c <rom+0x5131c>
   512e0: 1840         	adds	r0, r0, r1
   512e2: 490f         	ldr	r1, [pc, #0x3c]         @ 0x51320 <rom+0x51320>
   512e4: 8001         	strh	r1, [r0]
   512e6: 2000         	movs	r0, #0x0
   512e8: 4680         	mov	r8, r0
   512ea: 4640         	mov	r0, r8
   512ec: f000 fa2a    	bl	0x51744 <rom+0x51744>   @ imm = #0x454
   512f0: 1c07         	adds	r7, r0, #0x0
   512f2: 4640         	mov	r0, r8
   512f4: f000 fa1e    	bl	0x51734 <rom+0x51734>   @ imm = #0x43c
   512f8: 1c06         	adds	r6, r0, #0x0
   512fa: 2002         	movs	r0, #0x2
   512fc: 8839         	ldrh	r1, [r7]
   512fe: 4008         	ands	r0, r1
   51300: 2101         	movs	r1, #0x1
   51302: 4441         	add	r1, r8
   51304: 468a         	mov	r10, r1
   51306: 2800         	cmp	r0, #0x0
   51308: d13f         	bne	0x5138a <rom+0x5138a>   @ imm = #0x7e
   5130a: 7f30         	ldrb	r0, [r6, #0x1c]
   5130c: 2800         	cmp	r0, #0x0
   5130e: d02d         	beq	0x5136c <rom+0x5136c>   @ imm = #0x5a
   51310: 2001         	movs	r0, #0x1
   51312: 4681         	mov	r9, r0
   51314: 6a75         	ldr	r5, [r6, #0x24]
   51316: e006         	b	0x51326 <rom+0x51326>   @ imm = #0xc
   51318: 0f48         	lsrs	r0, r1, #0x1d
   5131a: 0300         	lsls	r0, r0, #0xc
   5131c: 06ea         	lsls	r2, r5, #0x1b
   5131e: 0000         	movs	r0, r0
   51320: ffff 0000    	<unknown>
   51324: 3501         	adds	r5, #0x1
   51326: 6ab0         	ldr	r0, [r6, #0x28]
   51328: 4285         	cmp	r5, r0
   5132a: dc0d         	bgt	0x51348 <rom+0x51348>   @ imm = #0x1a
   5132c: 1c28         	adds	r0, r5, #0x0
   5132e: f000 fa01    	bl	0x51734 <rom+0x51734>   @ imm = #0x402
   51332: 1c04         	adds	r4, r0, #0x0
   51334: 1c28         	adds	r0, r5, #0x0
   51336: f000 fa05    	bl	0x51744 <rom+0x51744>   @ imm = #0x40a
   5133a: 1c01         	adds	r1, r0, #0x0
   5133c: 6849         	ldr	r1, [r1, #0x4]
   5133e: 68a0         	ldr	r0, [r4, #0x8]
   51340: 4281         	cmp	r1, r0
   51342: ddef         	ble	0x51324 <rom+0x51324>   @ imm = #-0x22
   51344: 2100         	movs	r1, #0x0
   51346: 4689         	mov	r9, r1
   51348: 4648         	mov	r0, r9
   5134a: 2800         	cmp	r0, #0x0
   5134c: d01d         	beq	0x5138a <rom+0x5138a>   @ imm = #0x3a
   5134e: 2002         	movs	r0, #0x2
   51350: 8839         	ldrh	r1, [r7]
   51352: 4308         	orrs	r0, r1
   51354: 8038         	strh	r0, [r7]
   51356: 4803         	ldr	r0, [pc, #0xc]          @ 0x51364 <rom+0x51364>
   51358: 6800         	ldr	r0, [r0]
   5135a: 4903         	ldr	r1, [pc, #0xc]          @ 0x51368 <rom+0x51368>
   5135c: 1840         	adds	r0, r0, r1
   5135e: 4641         	mov	r1, r8
   51360: 8001         	strh	r1, [r0]
   51362: e012         	b	0x5138a <rom+0x5138a>   @ imm = #0x24
   51364: 0f48         	lsrs	r0, r1, #0x1d
   51366: 0300         	lsls	r0, r0, #0xc
   51368: 06ea         	lsls	r2, r5, #0x1b
   5136a: 0000         	movs	r0, r0
   5136c: 6a30         	ldr	r0, [r6, #0x20]
   5136e: 2800         	cmp	r0, #0x0
   51370: db0b         	blt	0x5138a <rom+0x5138a>   @ imm = #0x16
   51372: f000 f9e7    	bl	0x51744 <rom+0x51744>   @ imm = #0x3ce
   51376: 1c01         	adds	r1, r0, #0x0
   51378: 2001         	movs	r0, #0x1
   5137a: 8809         	ldrh	r1, [r1]
   5137c: 4008         	ands	r0, r1
   5137e: 2800         	cmp	r0, #0x0
   51380: d003         	beq	0x5138a <rom+0x5138a>   @ imm = #0x6
   51382: 2002         	movs	r0, #0x2
   51384: 8839         	ldrh	r1, [r7]
   51386: 4308         	orrs	r0, r1
   51388: 8038         	strh	r0, [r7]
   5138a: 46d0         	mov	r8, r10
   5138c: 4640         	mov	r0, r8
   5138e: 2837         	cmp	r0, #0x37
   51390: ddab         	ble	0x512ea <rom+0x512ea>   @ imm = #-0xaa
   51392: bc38         	pop	{r3, r4, r5}
   51394: 4698         	mov	r8, r3
   51396: 46a1         	mov	r9, r4
   51398: 46aa         	mov	r10, r5
   5139a: bcf0         	pop	{r4, r5, r6, r7}
   5139c: bc01         	pop	{r0}
   5139e: 4700         	bx	r0
   513a0: b570         	push	{r4, r5, r6, lr}
   513a2: 2600         	movs	r6, #0x0
   513a4: 2500         	movs	r5, #0x0
   513a6: 1c28         	adds	r0, r5, #0x0
   513a8: f000 f9cc    	bl	0x51744 <rom+0x51744>   @ imm = #0x398
   513ac: 1c04         	adds	r4, r0, #0x0
   513ae: 1c28         	adds	r0, r5, #0x0
   513b0: f000 f9c0    	bl	0x51734 <rom+0x51734>   @ imm = #0x380
   513b4: 2002         	movs	r0, #0x2
   513b6: 8824         	ldrh	r4, [r4]
   513b8: 4020         	ands	r0, r4
   513ba: 2800         	cmp	r0, #0x0
   513bc: d000         	beq	0x513c0 <rom+0x513c0>   @ imm = #0x0
   513be: 1c2e         	adds	r6, r5, #0x0
