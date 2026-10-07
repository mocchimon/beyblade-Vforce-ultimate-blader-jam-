
00000000 <rom>:
   62490: b5f0         	push	{r4, r5, r6, r7, lr}
   62492: 4657         	mov	r7, r10
   62494: 464e         	mov	r6, r9
   62496: 4645         	mov	r5, r8
   62498: b4e0         	push	{r5, r6, r7}
   6249a: b081         	sub	sp, #0x4
   6249c: 4680         	mov	r8, r0
   6249e: 1c0c         	adds	r4, r1, #0x0
   624a0: f7ff ff66    	bl	0x62370 <rom+0x62370>   @ imm = #-0x134
   624a4: 2c10         	cmp	r4, #0x10
   624a6: d900         	bls	0x624aa <rom+0x624aa>   @ imm = #0x0
   624a8: 2410         	movs	r4, #0x10
   624aa: 484d         	ldr	r0, [pc, #0x134]        @ 0x625e0 <rom+0x625e0>
   624ac: 4580         	cmp	r8, r0
   624ae: d900         	bls	0x624b2 <rom+0x624b2>   @ imm = #0x0
   624b0: 4680         	mov	r8, r0
   624b2: 494c         	ldr	r1, [pc, #0x130]        @ 0x625e4 <rom+0x625e4>
   624b4: 4640         	mov	r0, r8
   624b6: 6008         	str	r0, [r1]
   624b8: 2001         	movs	r0, #0x1
   624ba: 6048         	str	r0, [r1, #0x4]
   624bc: 2200         	movs	r2, #0x0
   624be: 608a         	str	r2, [r1, #0x8]
   624c0: 4e49         	ldr	r6, [pc, #0x124]        @ 0x625e8 <rom+0x625e8>
   624c2: 46b1         	mov	r9, r6
   624c4: 4640         	mov	r0, r8
   624c6: 2128         	movs	r1, #0x28
   624c8: f003 fe8c    	bl	0x661e4 <rom+0x661e4>   @ imm = #0x3d18
   624cc: 300f         	adds	r0, #0xf
   624ce: 4a47         	ldr	r2, [pc, #0x11c]        @ 0x625ec <rom+0x625ec>
   624d0: 1c11         	adds	r1, r2, #0x0
   624d2: 4008         	ands	r0, r1
   624d4: 8030         	strh	r0, [r6]
   624d6: 4240         	rsbs	r0, r0, #0
   624d8: 4e45         	ldr	r6, [pc, #0x114]        @ 0x625f0 <rom+0x625f0>
   624da: 8030         	strh	r0, [r6]
   624dc: 4648         	mov	r0, r9
   624de: 8800         	ldrh	r0, [r0]
   624e0: 0041         	lsls	r1, r0, #0x1
   624e2: 464a         	mov	r2, r9
   624e4: 8812         	ldrh	r2, [r2]
   624e6: 1889         	adds	r1, r1, r2
   624e8: 00a0         	lsls	r0, r4, #0x2
   624ea: 1900         	adds	r0, r0, r4
   624ec: 00c0         	lsls	r0, r0, #0x3
   624ee: 180d         	adds	r5, r1, r0
   624f0: 1c28         	adds	r0, r5, #0x0
   624f2: f7f7 ff6b    	bl	0x5a3cc <rom+0x5a3cc>   @ imm = #-0x812a
   624f6: 4e3f         	ldr	r6, [pc, #0xfc]         @ 0x625f4 <rom+0x625f4>
   624f8: 6030         	str	r0, [r6]
   624fa: 2800         	cmp	r0, #0x0
   624fc: d103         	bne	0x62506 <rom+0x62506>   @ imm = #0x6
   624fe: 483e         	ldr	r0, [pc, #0xf8]         @ 0x625f8 <rom+0x625f8>
   62500: 1c29         	adds	r1, r5, #0x0
   62502: f7f5 fbab    	bl	0x57c5c <rom+0x57c5c>   @ imm = #-0xa8aa
   62506: 483d         	ldr	r0, [pc, #0xf4]         @ 0x625fc <rom+0x625fc>
   62508: 4682         	mov	r10, r0
   6250a: 6830         	ldr	r0, [r6]
   6250c: 6800         	ldr	r0, [r0]
   6250e: 4651         	mov	r1, r10
   62510: 6008         	str	r0, [r1]
   62512: 2688         	movs	r6, #0x88
   62514: 00f6         	lsls	r6, r6, #0x3
   62516: 1c30         	adds	r0, r6, #0x0
   62518: f7f7 ff94    	bl	0x5a444 <rom+0x5a444>   @ imm = #-0x80d8
   6251c: 4f38         	ldr	r7, [pc, #0xe0]         @ 0x62600 <rom+0x62600>
   6251e: 6038         	str	r0, [r7]
   62520: 2800         	cmp	r0, #0x0
   62522: d103         	bne	0x6252c <rom+0x6252c>   @ imm = #0x6
   62524: 4837         	ldr	r0, [pc, #0xdc]         @ 0x62604 <rom+0x62604>
   62526: 1c31         	adds	r1, r6, #0x0
   62528: f7f5 fb98    	bl	0x57c5c <rom+0x57c5c>   @ imm = #-0xa8d0
   6252c: 4936         	ldr	r1, [pc, #0xd8]         @ 0x62608 <rom+0x62608>
   6252e: 6838         	ldr	r0, [r7]
   62530: 6800         	ldr	r0, [r0]
   62532: 6008         	str	r0, [r1]
   62534: 4935         	ldr	r1, [pc, #0xd4]         @ 0x6260c <rom+0x6260c>
   62536: 2280         	movs	r2, #0x80
   62538: 0092         	lsls	r2, r2, #0x2
   6253a: 1880         	adds	r0, r0, r2
   6253c: 6008         	str	r0, [r1]
   6253e: 4834         	ldr	r0, [pc, #0xd0]         @ 0x62610 <rom+0x62610>
   62540: 4656         	mov	r6, r10
   62542: 6833         	ldr	r3, [r6]
   62544: 464a         	mov	r2, r9
   62546: 8812         	ldrh	r2, [r2]
   62548: 18d1         	adds	r1, r2, r3
   6254a: 6001         	str	r1, [r0]
   6254c: 4831         	ldr	r0, [pc, #0xc4]         @ 0x62614 <rom+0x62614>
   6254e: 7004         	strb	r4, [r0]
   62550: 4a31         	ldr	r2, [pc, #0xc4]         @ 0x62618 <rom+0x62618>
   62552: 464c         	mov	r4, r9
   62554: 8824         	ldrh	r4, [r4]
   62556: 0060         	lsls	r0, r4, #0x1
   62558: 1809         	adds	r1, r1, r0
   6255a: 6011         	str	r1, [r2]
   6255c: 2600         	movs	r6, #0x0
   6255e: 9600         	str	r6, [sp]
   62560: 4a2e         	ldr	r2, [pc, #0xb8]         @ 0x6261c <rom+0x6261c>
   62562: 4668         	mov	r0, sp
   62564: 6010         	str	r0, [r2]
   62566: 6053         	str	r3, [r2, #0x4]
   62568: 08a8         	lsrs	r0, r5, #0x2
   6256a: 2185         	movs	r1, #0x85
   6256c: 0609         	lsls	r1, r1, #0x18
   6256e: 4308         	orrs	r0, r1
   62570: 6090         	str	r0, [r2, #0x8]
   62572: 6890         	ldr	r0, [r2, #0x8]
   62574: 4640         	mov	r0, r8
   62576: f7ff ff29    	bl	0x623cc <rom+0x623cc>   @ imm = #-0x1ae
   6257a: 4929         	ldr	r1, [pc, #0xa4]         @ 0x62620 <rom+0x62620>
   6257c: 2080         	movs	r0, #0x80
   6257e: 8008         	strh	r0, [r1]
   62580: 3902         	subs	r1, #0x2
   62582: 4a28         	ldr	r2, [pc, #0xa0]         @ 0x62624 <rom+0x62624>
   62584: 1c10         	adds	r0, r2, #0x0
   62586: 8008         	strh	r0, [r1]
   62588: 313a         	adds	r1, #0x3a
   6258a: 4654         	mov	r4, r10
   6258c: 6820         	ldr	r0, [r4]
   6258e: 6008         	str	r0, [r1]
   62590: 3104         	adds	r1, #0x4
   62592: 4825         	ldr	r0, [pc, #0x94]         @ 0x62628 <rom+0x62628>
   62594: 6008         	str	r0, [r1]
   62596: 3104         	adds	r1, #0x4
   62598: 20b6         	movs	r0, #0xb6
   6259a: 0600         	lsls	r0, r0, #0x18
   6259c: 6008         	str	r0, [r1]
   6259e: 4a23         	ldr	r2, [pc, #0x8c]         @ 0x6262c <rom+0x6262c>
   625a0: 4e13         	ldr	r6, [pc, #0x4c]         @ 0x625f0 <rom+0x625f0>
   625a2: 8830         	ldrh	r0, [r6]
   625a4: 3802         	subs	r0, #0x2
   625a6: 21c4         	movs	r1, #0xc4
   625a8: 0409         	lsls	r1, r1, #0x10
   625aa: 4308         	orrs	r0, r1
   625ac: 6010         	str	r0, [r2]
   625ae: 4c20         	ldr	r4, [pc, #0x80]         @ 0x62630 <rom+0x62630>
   625b0: 4820         	ldr	r0, [pc, #0x80]         @ 0x62634 <rom+0x62634>
   625b2: 4641         	mov	r1, r8
   625b4: f003 fe16    	bl	0x661e4 <rom+0x661e4>   @ imm = #0x3c2c
   625b8: 2180         	movs	r1, #0x80
   625ba: 0249         	lsls	r1, r1, #0x9
   625bc: 1a09         	subs	r1, r1, r0
   625be: 2080         	movs	r0, #0x80
