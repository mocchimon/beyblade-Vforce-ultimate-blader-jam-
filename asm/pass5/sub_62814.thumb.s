
00000000 <rom>:
   62814: b5f0         	push	{r4, r5, r6, r7, lr}
   62816: 4657         	mov	r7, r10
   62818: 464e         	mov	r6, r9
   6281a: 4645         	mov	r5, r8
   6281c: b4e0         	push	{r5, r6, r7}
   6281e: 4812         	ldr	r0, [pc, #0x48]         @ 0x62868 <rom+0x62868>
   62820: 6806         	ldr	r6, [r0]
   62822: 4812         	ldr	r0, [pc, #0x48]         @ 0x6286c <rom+0x6286c>
   62824: 7804         	ldrb	r4, [r0]
   62826: 4812         	ldr	r0, [pc, #0x48]         @ 0x62870 <rom+0x62870>
   62828: 6800         	ldr	r0, [r0]
   6282a: 2800         	cmp	r0, #0x0
   6282c: d06c         	beq	0x62908 <rom+0x62908>   @ imm = #0xd8
   6282e: 4d11         	ldr	r5, [pc, #0x44]         @ 0x62874 <rom+0x62874>
   62830: 6868         	ldr	r0, [r5, #0x4]
   62832: 2800         	cmp	r0, #0x0
   62834: d068         	beq	0x62908 <rom+0x62908>   @ imm = #0xd0
   62836: f000 fa07    	bl	0x62c48 <rom+0x62c48>   @ imm = #0x40e
   6283a: 4f0f         	ldr	r7, [pc, #0x3c]         @ 0x62878 <rom+0x62878>
   6283c: 683a         	ldr	r2, [r7]
   6283e: 68a8         	ldr	r0, [r5, #0x8]
   62840: 3001         	adds	r0, #0x1
   62842: 2502         	movs	r5, #0x2
   62844: 426d         	rsbs	r5, r5, #0
   62846: 4028         	ands	r0, r5
   62848: 2380         	movs	r3, #0x80
   6284a: 025b         	lsls	r3, r3, #0x9
   6284c: 480b         	ldr	r0, [pc, #0x2c]         @ 0x6287c <rom+0x6287c>
   6284e: 8800         	ldrh	r0, [r0]
   62850: 1c41         	adds	r1, r0, #0x1
   62852: 4029         	ands	r1, r5
   62854: 4299         	cmp	r1, r3
   62856: d101         	bne	0x6285c <rom+0x6285c>   @ imm = #0x2
   62858: 4809         	ldr	r0, [pc, #0x24]         @ 0x62880 <rom+0x62880>
   6285a: 8801         	ldrh	r1, [r0]
   6285c: 6039         	str	r1, [r7]
   6285e: 4291         	cmp	r1, r2
   62860: d910         	bls	0x62884 <rom+0x62884>   @ imm = #0x20
   62862: 1a8d         	subs	r5, r1, r2
   62864: 2000         	movs	r0, #0x0
   62866: e013         	b	0x62890 <rom+0x62890>   @ imm = #0x26
   62868: 5e24         	ldrsh	r4, [r4, r0]
   6286a: 0300         	lsls	r0, r0, #0xc
   6286c: 5e04         	ldrsh	r4, [r0, r0]
   6286e: 0300         	lsls	r0, r0, #0xc
   62870: 5e1c         	ldrsh	r4, [r3, r0]
   62872: 0300         	lsls	r0, r0, #0xc
   62874: 5e40         	ldrsh	r0, [r0, r1]
   62876: 0300         	lsls	r0, r0, #0xc
   62878: 0d94         	lsrs	r4, r2, #0x16
   6287a: 0300         	lsls	r0, r0, #0xc
   6287c: 0104         	lsls	r4, r0, #0x4
   6287e: 0400         	lsls	r0, r0, #0x10
   62880: 5e18         	ldrsh	r0, [r3, r0]
   62882: 0300         	lsls	r0, r0, #0xc
   62884: 1a9d         	subs	r5, r3, r2
   62886: 4824         	ldr	r0, [pc, #0x90]         @ 0x62918 <rom+0x62918>
   62888: 8800         	ldrh	r0, [r0]
   6288a: 4a24         	ldr	r2, [pc, #0x90]         @ 0x6291c <rom+0x6291c>
   6288c: 1880         	adds	r0, r0, r2
   6288e: 1840         	adds	r0, r0, r1
   62890: 4682         	mov	r10, r0
   62892: 4650         	mov	r0, r10
   62894: 182f         	adds	r7, r5, r0
   62896: 4922         	ldr	r1, [pc, #0x88]         @ 0x62920 <rom+0x62920>
   62898: 2000         	movs	r0, #0x0
   6289a: 7008         	strb	r0, [r1]
   6289c: 3c01         	subs	r4, #0x1
   6289e: 2001         	movs	r0, #0x1
   628a0: 4240         	rsbs	r0, r0, #0
   628a2: 4284         	cmp	r4, r0
   628a4: d00c         	beq	0x628c0 <rom+0x628c0>   @ imm = #0x18
   628a6: 491f         	ldr	r1, [pc, #0x7c]         @ 0x62924 <rom+0x62924>
   628a8: 4689         	mov	r9, r1
   628aa: 4680         	mov	r8, r0
   628ac: 4648         	mov	r0, r9
   628ae: 8802         	ldrh	r2, [r0]
   628b0: 1c30         	adds	r0, r6, #0x0
   628b2: 1c39         	adds	r1, r7, #0x0
   628b4: f7ff ff8a    	bl	0x627cc <rom+0x627cc>   @ imm = #-0xec
   628b8: 3628         	adds	r6, #0x28
   628ba: 3c01         	subs	r4, #0x1
   628bc: 4544         	cmp	r4, r8
   628be: d1f5         	bne	0x628ac <rom+0x628ac>   @ imm = #-0x16
   628c0: 4e19         	ldr	r6, [pc, #0x64]         @ 0x62928 <rom+0x62928>
   628c2: 4c1a         	ldr	r4, [pc, #0x68]         @ 0x6292c <rom+0x6292c>
   628c4: 6820         	ldr	r0, [r4]
   628c6: 6833         	ldr	r3, [r6]
   628c8: 1c29         	adds	r1, r5, #0x0
   628ca: 2200         	movs	r2, #0x0
   628cc: f003 f9ba    	bl	0x65c44 <rom+0x65c44>   @ imm = #0x3374
   628d0: 6820         	ldr	r0, [r4]
   628d2: 1941         	adds	r1, r0, r5
   628d4: 6021         	str	r1, [r4]
   628d6: 4652         	mov	r2, r10
   628d8: 2a00         	cmp	r2, #0x0
   628da: d00b         	beq	0x628f4 <rom+0x628f4>   @ imm = #0x16
   628dc: 480e         	ldr	r0, [pc, #0x38]         @ 0x62918 <rom+0x62918>
   628de: 8800         	ldrh	r0, [r0]
   628e0: 1a08         	subs	r0, r1, r0
   628e2: 6020         	str	r0, [r4]
   628e4: 6833         	ldr	r3, [r6]
   628e6: 4651         	mov	r1, r10
   628e8: 1c2a         	adds	r2, r5, #0x0
   628ea: f003 f9ab    	bl	0x65c44 <rom+0x65c44>   @ imm = #0x3356
   628ee: 6820         	ldr	r0, [r4]
   628f0: 4450         	add	r0, r10
   628f2: 6020         	str	r0, [r4]
   628f4: 490e         	ldr	r1, [pc, #0x38]         @ 0x62930 <rom+0x62930>
   628f6: 4808         	ldr	r0, [pc, #0x20]         @ 0x62918 <rom+0x62918>
   628f8: 8802         	ldrh	r2, [r0]
   628fa: 6808         	ldr	r0, [r1]
   628fc: 1880         	adds	r0, r0, r2
   628fe: 6821         	ldr	r1, [r4]
   62900: 4281         	cmp	r1, r0
   62902: d101         	bne	0x62908 <rom+0x62908>   @ imm = #0x2
   62904: 1a88         	subs	r0, r1, r2
   62906: 6020         	str	r0, [r4]
   62908: bc38         	pop	{r3, r4, r5}
   6290a: 4698         	mov	r8, r3
   6290c: 46a1         	mov	r9, r4
   6290e: 46aa         	mov	r10, r5
   62910: bcf0         	pop	{r4, r5, r6, r7}
   62912: bc01         	pop	{r0}
   62914: 4700         	bx	r0
   62916: 0000         	movs	r0, r0
   62918: 5e4c         	ldrsh	r4, [r1, r1]
   6291a: 0300         	lsls	r0, r0, #0xc
   6291c: 0000         	movs	r0, r0
   6291e: ffff 5e78    	<unknown>
   62922: 0300         	lsls	r0, r0, #0xc
   62924: 0da0         	lsrs	r0, r4, #0x16
   62926: 0300         	lsls	r0, r0, #0xc
   62928: d98c         	bls	0x62844 <rom+0x62844>   @ imm = #-0xe8
   6292a: 0807         	lsrs	r7, r0, #0x20
   6292c: 0d90         	lsrs	r0, r2, #0x16
   6292e: 0300         	lsls	r0, r0, #0xc
   62930: 5e1c         	ldrsh	r4, [r3, r0]
   62932: 0300         	lsls	r0, r0, #0xc
   62934: b510         	push	{r4, lr}
   62936: 1c03         	adds	r3, r0, #0x0
   62938: 2400         	movs	r4, #0x0
   6293a: 2001         	movs	r0, #0x1
   6293c: 7598         	strb	r0, [r3, #0x16]
   6293e: 6019         	str	r1, [r3]
