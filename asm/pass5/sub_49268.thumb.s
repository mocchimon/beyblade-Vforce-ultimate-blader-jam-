
00000000 <rom>:
   49268: b570         	push	{r4, r5, r6, lr}
   4926a: 4827         	ldr	r0, [pc, #0x9c]         @ 0x49308 <rom+0x49308>
   4926c: 6800         	ldr	r0, [r0]
   4926e: 4927         	ldr	r1, [pc, #0x9c]         @ 0x4930c <rom+0x4930c>
   49270: 1840         	adds	r0, r0, r1
   49272: 4927         	ldr	r1, [pc, #0x9c]         @ 0x49310 <rom+0x49310>
   49274: 8001         	strh	r1, [r0]
   49276: 4c27         	ldr	r4, [pc, #0x9c]         @ 0x49314 <rom+0x49314>
   49278: 2500         	movs	r5, #0x0
   4927a: 6065         	str	r5, [r4, #0x4]
   4927c: 60e5         	str	r5, [r4, #0xc]
   4927e: 2007         	movs	r0, #0x7
   49280: f7ff ffe6    	bl	0x49250 <rom+0x49250>   @ imm = #-0x34
   49284: 2001         	movs	r0, #0x1
   49286: 4240         	rsbs	r0, r0, #0
   49288: 6020         	str	r0, [r4]
   4928a: 60a0         	str	r0, [r4, #0x8]
   4928c: 1c20         	adds	r0, r4, #0x0
   4928e: 307c         	adds	r0, #0x7c
   49290: 7005         	strb	r5, [r0]
   49292: 228b         	movs	r2, #0x8b
   49294: 00d2         	lsls	r2, r2, #0x3
   49296: 18a0         	adds	r0, r4, r2
   49298: f007 f876    	bl	0x50388 <rom+0x50388>   @ imm = #0x70ec
   4929c: 4e1e         	ldr	r6, [pc, #0x78]         @ 0x49318 <rom+0x49318>
   4929e: 19a0         	adds	r0, r4, r6
   492a0: 6005         	str	r5, [r0]
   492a2: 218e         	movs	r1, #0x8e
   492a4: 00c9         	lsls	r1, r1, #0x3
   492a6: 1860         	adds	r0, r4, r1
   492a8: 6005         	str	r5, [r0]
   492aa: 4a1c         	ldr	r2, [pc, #0x70]         @ 0x4931c <rom+0x4931c>
   492ac: 18a0         	adds	r0, r4, r2
   492ae: 2100         	movs	r1, #0x0
   492b0: 8005         	strh	r5, [r0]
   492b2: 365d         	adds	r6, #0x5d
   492b4: 19a0         	adds	r0, r4, r6
   492b6: 7001         	strb	r1, [r0]
   492b8: 20af         	movs	r0, #0xaf
   492ba: 00c0         	lsls	r0, r0, #0x3
   492bc: 1823         	adds	r3, r4, r0
   492be: 36fb         	adds	r6, #0xfb
   492c0: 19a2         	adds	r2, r4, r6
   492c2: 3604         	adds	r6, #0x4
   492c4: 19a0         	adds	r0, r4, r6
   492c6: 6005         	str	r5, [r0]
   492c8: 6015         	str	r5, [r2]
   492ca: 601d         	str	r5, [r3]
   492cc: 1c20         	adds	r0, r4, #0x0
   492ce: 3080         	adds	r0, #0x80
   492d0: 7001         	strb	r1, [r0]
   492d2: 3801         	subs	r0, #0x1
   492d4: 7001         	strb	r1, [r0]
   492d6: 4a12         	ldr	r2, [pc, #0x48]         @ 0x49320 <rom+0x49320>
   492d8: 18a0         	adds	r0, r4, r2
   492da: 7001         	strb	r1, [r0]
   492dc: 3605         	adds	r6, #0x5
   492de: 19a0         	adds	r0, r4, r6
   492e0: 7001         	strb	r1, [r0]
   492e2: 3202         	adds	r2, #0x2
   492e4: 18a0         	adds	r0, r4, r2
   492e6: 7001         	strb	r1, [r0]
   492e8: 3603         	adds	r6, #0x3
   492ea: 19a0         	adds	r0, r4, r6
   492ec: 6005         	str	r5, [r0]
   492ee: 3206         	adds	r2, #0x6
   492f0: 18a0         	adds	r0, r4, r2
   492f2: 6005         	str	r5, [r0]
   492f4: 1c20         	adds	r0, r4, #0x0
   492f6: 3081         	adds	r0, #0x81
   492f8: 7001         	strb	r1, [r0]
   492fa: 3620         	adds	r6, #0x20
   492fc: 19a4         	adds	r4, r4, r6
   492fe: 6025         	str	r5, [r4]
   49300: bc70         	pop	{r4, r5, r6}
   49302: bc01         	pop	{r0}
