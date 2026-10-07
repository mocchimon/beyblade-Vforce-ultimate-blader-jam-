
00000000 <rom>:
   623cc: b5f0         	push	{r4, r5, r6, r7, lr}
   623ce: 4657         	mov	r7, r10
   623d0: 464e         	mov	r6, r9
   623d2: 4645         	mov	r5, r8
   623d4: b4e0         	push	{r5, r6, r7}
   623d6: 4680         	mov	r8, r0
   623d8: 4820         	ldr	r0, [pc, #0x80]         @ 0x6245c <rom+0x6245c>
   623da: 6807         	ldr	r7, [r0]
   623dc: 4820         	ldr	r0, [pc, #0x80]         @ 0x62460 <rom+0x62460>
   623de: 4681         	mov	r9, r0
   623e0: 267f         	movs	r6, #0x7f
   623e2: 4920         	ldr	r1, [pc, #0x80]         @ 0x62464 <rom+0x62464>
   623e4: 468a         	mov	r10, r1
   623e6: 464a         	mov	r2, r9
   623e8: 3204         	adds	r2, #0x4
   623ea: 4691         	mov	r9, r2
   623ec: 3a04         	subs	r2, #0x4
   623ee: ca01         	ldm	r2!, {r0}
   623f0: 2100         	movs	r1, #0x0
   623f2: 4a1d         	ldr	r2, [pc, #0x74]         @ 0x62468 <rom+0x62468>
   623f4: 4b1d         	ldr	r3, [pc, #0x74]         @ 0x6246c <rom+0x6246c>
   623f6: f003 febd    	bl	0x66174 <rom+0x66174>   @ imm = #0x3d7a
   623fa: 1c0b         	adds	r3, r1, #0x0
   623fc: 1c02         	adds	r2, r0, #0x0
   623fe: 0d15         	lsrs	r5, r2, #0x14
   62400: 031c         	lsls	r4, r3, #0xc
   62402: 1c29         	adds	r1, r5, #0x0
   62404: 4321         	orrs	r1, r4
   62406: 0310         	lsls	r0, r2, #0xc
   62408: 4a19         	ldr	r2, [pc, #0x64]         @ 0x62470 <rom+0x62470>
   6240a: 4b1a         	ldr	r3, [pc, #0x68]         @ 0x62474 <rom+0x62474>
   6240c: f003 fc32    	bl	0x65c74 <rom+0x65c74>   @ imm = #0x3864
   62410: 4642         	mov	r2, r8
   62412: 2300         	movs	r3, #0x0
   62414: f003 fc2e    	bl	0x65c74 <rom+0x65c74>   @ imm = #0x385c
   62418: c701         	stm	r7!, {r0}
   6241a: 3e01         	subs	r6, #0x1
   6241c: 2001         	movs	r0, #0x1
   6241e: 4240         	rsbs	r0, r0, #0
   62420: 4286         	cmp	r6, r0
   62422: d1e0         	bne	0x623e6 <rom+0x623e6>   @ imm = #-0x40
   62424: 4651         	mov	r1, r10
   62426: 6808         	ldr	r0, [r1]
   62428: 4a13         	ldr	r2, [pc, #0x4c]         @ 0x62478 <rom+0x62478>
   6242a: 6010         	str	r0, [r2]
   6242c: 2080         	movs	r0, #0x80
   6242e: 0240         	lsls	r0, r0, #0x9
   62430: 4912         	ldr	r1, [pc, #0x48]         @ 0x6247c <rom+0x6247c>
   62432: 8809         	ldrh	r1, [r1]
   62434: 1a40         	subs	r0, r0, r1
   62436: 4a12         	ldr	r2, [pc, #0x48]         @ 0x62480 <rom+0x62480>
   62438: 6010         	str	r0, [r2]
   6243a: 4912         	ldr	r1, [pc, #0x48]         @ 0x62484 <rom+0x62484>
   6243c: 1c08         	adds	r0, r1, #0x0
   6243e: 4a12         	ldr	r2, [pc, #0x48]         @ 0x62488 <rom+0x62488>
   62440: 8010         	strh	r0, [r2]
   62442: 2180         	movs	r1, #0x80
   62444: 0049         	lsls	r1, r1, #0x1
   62446: 1c08         	adds	r0, r1, #0x0
   62448: 4a10         	ldr	r2, [pc, #0x40]         @ 0x6248c <rom+0x6248c>
   6244a: 8010         	strh	r0, [r2]
   6244c: bc38         	pop	{r3, r4, r5}
   6244e: 4698         	mov	r8, r3
   62450: 46a1         	mov	r9, r4
   62452: 46aa         	mov	r10, r5
   62454: bcf0         	pop	{r4, r5, r6, r7}
   62456: bc01         	pop	{r0}
   62458: 4700         	bx	r0
   6245a: 0000         	movs	r0, r0
   6245c: 0d98         	lsrs	r0, r3, #0x16
   6245e: 0300         	lsls	r0, r0, #0xc
   62460: 5bb4         	ldrh	r4, [r6, r6]
   62462: 0875         	lsrs	r5, r6, #0x1
   62464: 5e1c         	ldrsh	r4, [r3, r0]
   62466: 0300         	lsls	r0, r0, #0xc
   62468: 2b11         	cmp	r3, #0x11
   6246a: 0000         	movs	r0, r0
   6246c: 0000         	movs	r0, r0
   6246e: 0000         	movs	r0, r0
   62470: 0105         	lsls	r5, r0, #0x4
   62472: 0000         	movs	r0, r0
   62474: 0000         	movs	r0, r0
   62476: 0000         	movs	r0, r0
   62478: 0d90         	lsrs	r0, r2, #0x16
   6247a: 0300         	lsls	r0, r0, #0xc
   6247c: 5e4c         	ldrsh	r4, [r1, r1]
   6247e: 0300         	lsls	r0, r0, #0xc
   62480: 0d94         	lsrs	r4, r2, #0x16
   62482: 0300         	lsls	r0, r0, #0xc
   62484: ffff 0000    	<unknown>
   62488: 0da2         	lsrs	r2, r4, #0x16
   6248a: 0300         	lsls	r0, r0, #0xc
   6248c: 0da0         	lsrs	r0, r4, #0x16
   6248e: 0300         	lsls	r0, r0, #0xc
