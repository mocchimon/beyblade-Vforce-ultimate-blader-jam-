   58778: b500         	push	{lr}
   5877a: 1c02         	adds	r2, r0, #0x0
   5877c: 30b0         	adds	r0, #0xb0
   5877e: 6803         	ldr	r3, [r0]
   58780: 2b00         	cmp	r3, #0x0
   58782: d003         	beq	0x5878c <rom+0x5878c>   @ imm = #0x6
   58784: 1c10         	adds	r0, r2, #0x0
   58786: f00d fa5d    	bl	0x65c44 <rom+0x65c44>   @ imm = #0xd4ba
   5878a: e005         	b	0x58798 <rom+0x58798>   @ imm = #0xa
   5878c: 6850         	ldr	r0, [r2, #0x4]
   5878e: 6008         	str	r0, [r1]
   58790: 6890         	ldr	r0, [r2, #0x8]
   58792: 6048         	str	r0, [r1, #0x4]
   58794: 68d0         	ldr	r0, [r2, #0xc]
   58796: 6088         	str	r0, [r1, #0x8]
   58798: bc01         	pop	{r0}
   5879a: 4700         	bx	r0
   5879c: b500         	push	{lr}
   5879e: 2100         	movs	r1, #0x0
   587a0: f7ff fb04    	bl	0x57dac <rom+0x57dac>   @ imm = #-0x9f8
   587a4: bc01         	pop	{r0}
   587a6: 4700         	bx	r0
   587a8: 0609         	lsls	r1, r1, #0x18
   587aa: 0e09         	lsrs	r1, r1, #0x18
   587ac: 3031         	adds	r0, #0x31
   587ae: 7802         	ldrb	r2, [r0]
   587b0: 4051         	eors	r1, r2
   587b2: 7001         	strb	r1, [r0]
   587b4: 4770         	bx	lr
   587b6: 0000         	movs	r0, r0
   587b8: b5f0         	push	{r4, r5, r6, r7, lr}
   587ba: 464f         	mov	r7, r9
   587bc: 4646         	mov	r6, r8
   587be: b4c0         	push	{r6, r7}
   587c0: 1c04         	adds	r4, r0, #0x0
   587c2: 4688         	mov	r8, r1
   587c4: 4691         	mov	r9, r2
   587c6: 1c1f         	adds	r7, r3, #0x0
   587c8: 6f61         	ldr	r1, [r4, #0x74]
   587ca: 2001         	movs	r0, #0x1
   587cc: 4240         	rsbs	r0, r0, #0
   587ce: 4281         	cmp	r1, r0
   587d0: d10f         	bne	0x587f2 <rom+0x587f2>   @ imm = #0x1e
   587d2: 2000         	movs	r0, #0x0
   587d4: 6760         	str	r0, [r4, #0x74]
   587d6: 2040         	movs	r0, #0x40
   587d8: f001 fe34    	bl	0x5a444 <rom+0x5a444>   @ imm = #0x1c68
   587dc: 2800         	cmp	r0, #0x0
   587de: d105         	bne	0x587ec <rom+0x587ec>   @ imm = #0xa
   587e0: 4801         	ldr	r0, [pc, #0x4]          @ 0x587e8 <rom+0x587e8>
   587e2: f7ff f9bd    	bl	0x57b60 <rom+0x57b60>   @ imm = #-0xc86
   587e6: e033         	b	0x58850 <rom+0x58850>   @ imm = #0x66
   587e8: cbf0         	ldm	r3!, {r4, r5, r6, r7}
   587ea: 0872         	lsrs	r2, r6, #0x1
   587ec: 67e0         	str	r0, [r4, #0x7c]
   587ee: 6800         	ldr	r0, [r0]
   587f0: 67a0         	str	r0, [r4, #0x78]
   587f2: 6f61         	ldr	r1, [r4, #0x74]
   587f4: 2903         	cmp	r1, #0x3
   587f6: dd1e         	ble	0x58836 <rom+0x58836>   @ imm = #0x3c
   587f8: 2501         	movs	r5, #0x1
   587fa: 426d         	rsbs	r5, r5, #0
   587fc: 2600         	movs	r6, #0x0
   587fe: 2200         	movs	r2, #0x0
   58800: 6fa3         	ldr	r3, [r4, #0x78]
   58802: 1c19         	adds	r1, r3, #0x0
   58804: 6808         	ldr	r0, [r1]
   58806: 2800         	cmp	r0, #0x0
   58808: d103         	bne	0x58812 <rom+0x58812>   @ imm = #0x6
   5880a: 2d00         	cmp	r5, #0x0
   5880c: da00         	bge	0x58810 <rom+0x58810>   @ imm = #0x0
   5880e: 1c15         	adds	r5, r2, #0x0
   58810: 3601         	adds	r6, #0x1
   58812: 3110         	adds	r1, #0x10
   58814: 3201         	adds	r2, #0x1
   58816: 2a03         	cmp	r2, #0x3
   58818: ddf4         	ble	0x58804 <rom+0x58804>   @ imm = #-0x18
   5881a: 2001         	movs	r0, #0x1
   5881c: 4240         	rsbs	r0, r0, #0
   5881e: 4285         	cmp	r5, r0
   58820: d101         	bne	0x58826 <rom+0x58826>   @ imm = #0x2
   58822: 1c19         	adds	r1, r3, #0x0
   58824: e001         	b	0x5882a <rom+0x5882a>   @ imm = #0x2
   58826: 0128         	lsls	r0, r5, #0x4
   58828: 1819         	adds	r1, r3, r0
   5882a: 2e04         	cmp	r6, #0x4
   5882c: d106         	bne	0x5883c <rom+0x5883c>   @ imm = #0xc
   5882e: 2000         	movs	r0, #0x0
   58830: 6760         	str	r0, [r4, #0x74]
   58832: 1c19         	adds	r1, r3, #0x0
   58834: e002         	b	0x5883c <rom+0x5883c>   @ imm = #0x4
   58836: 0109         	lsls	r1, r1, #0x4
   58838: 6fa0         	ldr	r0, [r4, #0x78]
   5883a: 1841         	adds	r1, r0, r1
   5883c: 4640         	mov	r0, r8
   5883e: 6088         	str	r0, [r1, #0x8]
   58840: 600f         	str	r7, [r1]
   58842: 9807         	ldr	r0, [sp, #0x1c]
   58844: 6048         	str	r0, [r1, #0x4]
   58846: 4648         	mov	r0, r9
   58848: 60c8         	str	r0, [r1, #0xc]
   5884a: 6f60         	ldr	r0, [r4, #0x74]
   5884c: 3001         	adds	r0, #0x1
   5884e: 6760         	str	r0, [r4, #0x74]
   58850: bc18         	pop	{r3, r4}
   58852: 4698         	mov	r8, r3
   58854: 46a1         	mov	r9, r4
   58856: bcf0         	pop	{r4, r5, r6, r7}
   58858: bc01         	pop	{r0}
   5885a: 4700         	bx	r0
   5885c: b5f0         	push	{r4, r5, r6, r7, lr}
   5885e: 1c06         	adds	r6, r0, #0x0
   58860: 6f77         	ldr	r7, [r6, #0x74]
   58862: 2001         	movs	r0, #0x1
   58864: 4240         	rsbs	r0, r0, #0
   58866: 4287         	cmp	r7, r0
   58868: d02c         	beq	0x588c4 <rom+0x588c4>   @ imm = #0x58
   5886a: 2500         	movs	r5, #0x0
   5886c: 42bd         	cmp	r5, r7
   5886e: da29         	bge	0x588c4 <rom+0x588c4>   @ imm = #0x52
   58870: 0129         	lsls	r1, r5, #0x4
   58872: 6fb0         	ldr	r0, [r6, #0x78]
   58874: 1844         	adds	r4, r0, r1
   58876: 68a2         	ldr	r2, [r4, #0x8]
   58878: 2a00         	cmp	r2, #0x0
   5887a: d009         	beq	0x58890 <rom+0x58890>   @ imm = #0x12
   5887c: 6820         	ldr	r0, [r4]
   5887e: 2800         	cmp	r0, #0x0
   58880: d01d         	beq	0x588be <rom+0x588be>   @ imm = #0x3a
   58882: 6860         	ldr	r0, [r4, #0x4]
   58884: 2800         	cmp	r0, #0x0
   58886: dc03         	bgt	0x58890 <rom+0x58890>   @ imm = #0x6
   58888: 1c30         	adds	r0, r6, #0x0
   5888a: 1c21         	adds	r1, r4, #0x0
   5888c: f00d f9d8    	bl	0x65c40 <rom+0x65c40>   @ imm = #0xd3b0
   58890: 6822         	ldr	r2, [r4]
   58892: 2a00         	cmp	r2, #0x0
   58894: dd13         	ble	0x588be <rom+0x588be>   @ imm = #0x26
   58896: 4805         	ldr	r0, [pc, #0x14]         @ 0x588ac <rom+0x588ac>
   58898: 6801         	ldr	r1, [r0]
   5889a: 6840         	ldr	r0, [r0, #0x4]
   5889c: 1a09         	subs	r1, r1, r0
   5889e: 6860         	ldr	r0, [r4, #0x4]
   588a0: 2800         	cmp	r0, #0x0
   588a2: dd05         	ble	0x588b0 <rom+0x588b0>   @ imm = #0xa
   588a4: 1a40         	subs	r0, r0, r1
   588a6: 6060         	str	r0, [r4, #0x4]
   588a8: e004         	b	0x588b4 <rom+0x588b4>   @ imm = #0x8
   588aa: 0000         	movs	r0, r0
   588ac: 0e30         	lsrs	r0, r6, #0x18
   588ae: 0300         	lsls	r0, r0, #0xc
   588b0: 1a50         	subs	r0, r2, r1
   588b2: 6020         	str	r0, [r4]
   588b4: 6820         	ldr	r0, [r4]
   588b6: 2800         	cmp	r0, #0x0
   588b8: da01         	bge	0x588be <rom+0x588be>   @ imm = #0x2
   588ba: 2000         	movs	r0, #0x0
   588bc: 6020         	str	r0, [r4]
   588be: 3501         	adds	r5, #0x1
   588c0: 42bd         	cmp	r5, r7
   588c2: dbd5         	blt	0x58870 <rom+0x58870>   @ imm = #-0x56
   588c4: bcf0         	pop	{r4, r5, r6, r7}
   588c6: bc01         	pop	{r0}
   588c8: 4700         	bx	r0
   588ca: 0000         	movs	r0, r0
   588cc: b530         	push	{r4, r5, lr}
   588ce: 1c04         	adds	r4, r0, #0x0
   588d0: 1c25         	adds	r5, r4, #0x0
   588d2: 35b8         	adds	r5, #0xb8
   588d4: 6828         	ldr	r0, [r5]
   588d6: 2800         	cmp	r0, #0x0
   588d8: d003         	beq	0x588e2 <rom+0x588e2>   @ imm = #0x6
   588da: f008 f8ed    	bl	0x60ab8 <rom+0x60ab8>   @ imm = #0x81da
   588de: 2000         	movs	r0, #0x0
   588e0: 6028         	str	r0, [r5]
   588e2: 6fe0         	ldr	r0, [r4, #0x7c]
   588e4: 2800         	cmp	r0, #0x0
   588e6: d001         	beq	0x588ec <rom+0x588ec>   @ imm = #0x2
   588e8: f001 fde8    	bl	0x5a4bc <rom+0x5a4bc>   @ imm = #0x1bd0
   588ec: 2001         	movs	r0, #0x1
   588ee: 4240         	rsbs	r0, r0, #0
   588f0: 6760         	str	r0, [r4, #0x74]
   588f2: 2000         	movs	r0, #0x0
   588f4: 67a0         	str	r0, [r4, #0x78]
   588f6: 67e0         	str	r0, [r4, #0x7c]
   588f8: bc30         	pop	{r4, r5}
   588fa: bc01         	pop	{r0}
   588fc: 4700         	bx	r0
   588fe: 0000         	movs	r0, r0
   58900: b530         	push	{r4, r5, lr}
   58902: 1c03         	adds	r3, r0, #0x0
   58904: 6f5a         	ldr	r2, [r3, #0x74]
   58906: 2001         	movs	r0, #0x1
   58908: 4240         	rsbs	r0, r0, #0
   5890a: 4282         	cmp	r2, r0
   5890c: d011         	beq	0x58932 <rom+0x58932>   @ imm = #0x22
   5890e: 2000         	movs	r0, #0x0
   58910: 4290         	cmp	r0, r2
   58912: da0c         	bge	0x5892e <rom+0x5892e>   @ imm = #0x18
   58914: 6f9c         	ldr	r4, [r3, #0x78]
   58916: 2500         	movs	r5, #0x0
   58918: 0401         	lsls	r1, r0, #0x10
   5891a: 1409         	asrs	r1, r1, #0x10
   5891c: 0108         	lsls	r0, r1, #0x4
   5891e: 1820         	adds	r0, r4, r0
   58920: 6005         	str	r5, [r0]
   58922: 3101         	adds	r1, #0x1
   58924: 0409         	lsls	r1, r1, #0x10
   58926: 0c08         	lsrs	r0, r1, #0x10
   58928: 1409         	asrs	r1, r1, #0x10
   5892a: 4291         	cmp	r1, r2
   5892c: dbf4         	blt	0x58918 <rom+0x58918>   @ imm = #-0x18
   5892e: 2000         	movs	r0, #0x0
   58930: 6758         	str	r0, [r3, #0x74]
   58932: bc30         	pop	{r4, r5}
   58934: bc01         	pop	{r0}
   58936: 4700         	bx	r0
   58938: 4770         	bx	lr
   5893a: 0000         	movs	r0, r0
   5893c: 4770         	bx	lr
   5893e: 0000         	movs	r0, r0
   58940: 4770         	bx	lr
   58942: 0000         	movs	r0, r0
   58944: 4770         	bx	lr
   58946: 0000         	movs	r0, r0
   58948: 6881         	ldr	r1, [r0, #0x8]
   5894a: 00c9         	lsls	r1, r1, #0x3
   5894c: 3120         	adds	r1, #0x20
   5894e: 1842         	adds	r2, r0, r1
   58950: 6981         	ldr	r1, [r0, #0x18]
   58952: 1840         	adds	r0, r0, r1
   58954: 4282         	cmp	r2, r0
   58956: d001         	beq	0x5895c <rom+0x5895c>   @ imm = #0x2
   58958: 1c10         	adds	r0, r2, #0x0
   5895a: e000         	b	0x5895e <rom+0x5895e>   @ imm = #0x0
   5895c: 2000         	movs	r0, #0x0
   5895e: 4770         	bx	lr
   58960: 6801         	ldr	r1, [r0]
   58962: 6808         	ldr	r0, [r1]
   58964: 0042         	lsls	r2, r0, #0x1
   58966: 2002         	movs	r0, #0x2
   58968: 4010         	ands	r0, r2
   5896a: 2800         	cmp	r0, #0x0
   5896c: d000         	beq	0x58970 <rom+0x58970>   @ imm = #0x0
   5896e: 3202         	adds	r2, #0x2
   58970: 2010         	movs	r0, #0x10
   58972: 79cb         	ldrb	r3, [r1, #0x7]
   58974: 4018         	ands	r0, r3
   58976: 2800         	cmp	r0, #0x0
   58978: d005         	beq	0x58986 <rom+0x58986>   @ imm = #0xa
   5897a: 6888         	ldr	r0, [r1, #0x8]
   5897c: 00c0         	lsls	r0, r0, #0x3
   5897e: 3020         	adds	r0, #0x20
   58980: 1808         	adds	r0, r1, r0
   58982: 1880         	adds	r0, r0, r2
   58984: e000         	b	0x58988 <rom+0x58988>   @ imm = #0x0
   58986: 2000         	movs	r0, #0x0
   58988: 4770         	bx	lr
   5898a: 0000         	movs	r0, r0
   5898c: b5f0         	push	{r4, r5, r6, r7, lr}
   5898e: 4647         	mov	r7, r8
   58990: b480         	push	{r7}
