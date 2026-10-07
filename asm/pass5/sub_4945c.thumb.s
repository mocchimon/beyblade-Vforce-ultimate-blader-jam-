
00000000 <rom>:
   4945c: b5f0         	push	{r4, r5, r6, r7, lr}
   4945e: 2700         	movs	r7, #0x0
   49460: f7ff fddc    	bl	0x4901c <rom+0x4901c>   @ imm = #-0x448
   49464: f00e fa4a    	bl	0x578fc <rom+0x578fc>   @ imm = #0xe494
   49468: 4c4f         	ldr	r4, [pc, #0x13c]        @ 0x495a8 <rom+0x495a8>
   4946a: 1c20         	adds	r0, r4, #0x0
   4946c: f000 ff0a    	bl	0x4a284 <rom+0x4a284>   @ imm = #0xe14
   49470: f019 f9d0    	bl	0x62814 <rom+0x62814>   @ imm = #0x193a0
   49474: 494d         	ldr	r1, [pc, #0x134]        @ 0x495ac <rom+0x495ac>
   49476: 2001         	movs	r0, #0x1
   49478: 7008         	strb	r0, [r1]
   4947a: 484d         	ldr	r0, [pc, #0x134]        @ 0x495b0 <rom+0x495b0>
   4947c: 7007         	strb	r7, [r0]
   4947e: f7ff fe75    	bl	0x4916c <rom+0x4916c>   @ imm = #-0x316
   49482: 68e0         	ldr	r0, [r4, #0xc]
   49484: f7ff fe3a    	bl	0x490fc <rom+0x490fc>   @ imm = #-0x38c
   49488: 6821         	ldr	r1, [r4]
   4948a: 2001         	movs	r0, #0x1
   4948c: 4240         	rsbs	r0, r0, #0
   4948e: 4281         	cmp	r1, r0
   49490: d103         	bne	0x4949a <rom+0x4949a>   @ imm = #0x6
   49492: 6860         	ldr	r0, [r4, #0x4]
   49494: 4288         	cmp	r0, r1
   49496: d100         	bne	0x4949a <rom+0x4949a>   @ imm = #0x0
   49498: e07f         	b	0x4959a <rom+0x4959a>   @ imm = #0xfe
   4949a: f00e fa2f    	bl	0x578fc <rom+0x578fc>   @ imm = #0xe45e
   4949e: f011 f91d    	bl	0x5a6dc <rom+0x5a6dc>   @ imm = #0x1123a
   494a2: 4c41         	ldr	r4, [pc, #0x104]        @ 0x495a8 <rom+0x495a8>
   494a4: 1c20         	adds	r0, r4, #0x0
   494a6: f000 feed    	bl	0x4a284 <rom+0x4a284>   @ imm = #0xdda
   494aa: f019 f9b3    	bl	0x62814 <rom+0x62814>   @ imm = #0x19366
   494ae: f7ff ff8d    	bl	0x493cc <rom+0x493cc>   @ imm = #-0xe6
   494b2: 483e         	ldr	r0, [pc, #0xf8]         @ 0x495ac <rom+0x495ac>
   494b4: 7801         	ldrb	r1, [r0]
   494b6: 2001         	movs	r0, #0x1
   494b8: f7ff fe0a    	bl	0x490d0 <rom+0x490d0>   @ imm = #-0x3ec
   494bc: 483d         	ldr	r0, [pc, #0xf4]         @ 0x495b4 <rom+0x495b4>
   494be: 6800         	ldr	r0, [r0]
   494c0: f01c fbba    	bl	0x65c38 <rom+0x65c38>   @ imm = #0x1c774
   494c4: 6821         	ldr	r1, [r4]
   494c6: 6860         	ldr	r0, [r4, #0x4]
   494c8: 4281         	cmp	r1, r0
   494ca: d00a         	beq	0x494e2 <rom+0x494e2>   @ imm = #0x14
   494cc: 483a         	ldr	r0, [pc, #0xe8]         @ 0x495b8 <rom+0x495b8>
   494ce: 1821         	adds	r1, r4, r0
   494d0: 4a3a         	ldr	r2, [pc, #0xe8]         @ 0x495bc <rom+0x495bc>
   494d2: 18a0         	adds	r0, r4, r2
   494d4: 7809         	ldrb	r1, [r1]
   494d6: 7800         	ldrb	r0, [r0]
   494d8: 4281         	cmp	r1, r0
   494da: d102         	bne	0x494e2 <rom+0x494e2>   @ imm = #0x4
   494dc: 2700         	movs	r7, #0x0
   494de: f000 f8cf    	bl	0x49680 <rom+0x49680>   @ imm = #0x19e
   494e2: 4d31         	ldr	r5, [pc, #0xc4]         @ 0x495a8 <rom+0x495a8>
   494e4: 1c2e         	adds	r6, r5, #0x0
   494e6: 36b4         	adds	r6, #0xb4
   494e8: 6830         	ldr	r0, [r6]
   494ea: 2800         	cmp	r0, #0x0
   494ec: d055         	beq	0x4959a <rom+0x4959a>   @ imm = #0xaa
   494ee: 23b2         	movs	r3, #0xb2
   494f0: 00db         	lsls	r3, r3, #0x3
   494f2: 18e8         	adds	r0, r5, r3
   494f4: f007 fabe    	bl	0x50a74 <rom+0x50a74>   @ imm = #0x757c
   494f8: 4931         	ldr	r1, [pc, #0xc4]         @ 0x495c0 <rom+0x495c0>
   494fa: 1868         	adds	r0, r5, r1
   494fc: 2200         	movs	r2, #0x0
   494fe: 5e80         	ldrsh	r0, [r0, r2]
   49500: 2800         	cmp	r0, #0x0
   49502: d004         	beq	0x4950e <rom+0x4950e>   @ imm = #0x8
   49504: 238b         	movs	r3, #0x8b
   49506: 00db         	lsls	r3, r3, #0x3
   49508: 18e8         	adds	r0, r5, r3
   4950a: f006 ff89    	bl	0x50420 <rom+0x50420>   @ imm = #0x6f12
   4950e: 6830         	ldr	r0, [r6]
   49510: 6840         	ldr	r0, [r0, #0x4]
   49512: 6940         	ldr	r0, [r0, #0x14]
   49514: 2800         	cmp	r0, #0x0
   49516: d001         	beq	0x4951c <rom+0x4951c>   @ imm = #0x2
   49518: f000 fdfc    	bl	0x4a114 <rom+0x4a114>   @ imm = #0xbf8
   4951c: 1c28         	adds	r0, r5, #0x0
   4951e: f7f9 ffe5    	bl	0x434ec <rom+0x434ec>   @ imm = #-0x6036
   49522: 2004         	movs	r0, #0x4
   49524: f7ff ff10    	bl	0x49348 <rom+0x49348>   @ imm = #-0x1e0
   49528: 4823         	ldr	r0, [pc, #0x8c]         @ 0x495b8 <rom+0x495b8>
   4952a: 1829         	adds	r1, r5, r0
   4952c: 4a25         	ldr	r2, [pc, #0x94]         @ 0x495c4 <rom+0x495c4>
   4952e: 18ac         	adds	r4, r5, r2
   49530: 780b         	ldrb	r3, [r1]
   49532: 7822         	ldrb	r2, [r4]
   49534: 1898         	adds	r0, r3, r2
   49536: 7008         	strb	r0, [r1]
   49538: f00e fa0c    	bl	0x57954 <rom+0x57954>   @ imm = #0xe418
   4953c: 1c39         	adds	r1, r7, #0x0
   4953e: 3701         	adds	r7, #0x1
   49540: 2008         	movs	r0, #0x8
   49542: f7ff fdc5    	bl	0x490d0 <rom+0x490d0>   @ imm = #-0x476
   49546: 2000         	movs	r0, #0x0
   49548: 5620         	ldrsb	r0, [r4, r0]
   4954a: 2800         	cmp	r0, #0x0
   4954c: d10b         	bne	0x49566 <rom+0x49566>   @ imm = #0x16
   4954e: 6830         	ldr	r0, [r6]
   49550: 6840         	ldr	r0, [r0, #0x4]
   49552: 6a00         	ldr	r0, [r0, #0x20]
   49554: 2800         	cmp	r0, #0x0
   49556: d002         	beq	0x4955e <rom+0x4955e>   @ imm = #0x4
   49558: 1c28         	adds	r0, r5, #0x0
   4955a: f7fa f8f7    	bl	0x4374c <rom+0x4374c>   @ imm = #-0x5e12
   4955e: 2002         	movs	r0, #0x2
   49560: 2100         	movs	r1, #0x0
   49562: f7ff fdb5    	bl	0x490d0 <rom+0x490d0>   @ imm = #-0x496
   49566: 4d10         	ldr	r5, [pc, #0x40]         @ 0x495a8 <rom+0x495a8>
   49568: 4b13         	ldr	r3, [pc, #0x4c]         @ 0x495b8 <rom+0x495b8>
   4956a: 18ea         	adds	r2, r5, r3
   4956c: 4913         	ldr	r1, [pc, #0x4c]         @ 0x495bc <rom+0x495bc>
   4956e: 1868         	adds	r0, r5, r1
   49570: 7801         	ldrb	r1, [r0]
   49572: 7813         	ldrb	r3, [r2]
   49574: 428b         	cmp	r3, r1
   49576: d107         	bne	0x49588 <rom+0x49588>   @ imm = #0xe
   49578: 2400         	movs	r4, #0x0
   4957a: 7011         	strb	r1, [r2]
   4957c: 2001         	movs	r0, #0x1
   4957e: f7ff fee3    	bl	0x49348 <rom+0x49348>   @ imm = #-0x23a
   49582: 4910         	ldr	r1, [pc, #0x40]         @ 0x495c4 <rom+0x495c4>
   49584: 1868         	adds	r0, r5, r1
   49586: 7004         	strb	r4, [r0]
   49588: 6829         	ldr	r1, [r5]
   4958a: 2001         	movs	r0, #0x1
   4958c: 4240         	rsbs	r0, r0, #0
   4958e: 4281         	cmp	r1, r0
   49590: d183         	bne	0x4949a <rom+0x4949a>   @ imm = #-0xfa
   49592: 6868         	ldr	r0, [r5, #0x4]
   49594: 4288         	cmp	r0, r1
   49596: d000         	beq	0x4959a <rom+0x4959a>   @ imm = #0x0
   49598: e77f         	b	0x4949a <rom+0x4949a>   @ imm = #-0x102
   4959a: 4803         	ldr	r0, [pc, #0xc]          @ 0x495a8 <rom+0x495a8>
   4959c: f000 fe72    	bl	0x4a284 <rom+0x4a284>   @ imm = #0xce4
