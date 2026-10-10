
/tmp/rom.elf:	file format elf32-littlearm

Disassembly of section .text:

08000000 <rom_start>:
 8062370: b530         	push	{r4, r5, lr}
 8062372: 4d10         	ldr	r5, [pc, #0x40]         @ 0x80623b4 <rom_start+0x623b4>
 8062374: 6829         	ldr	r1, [r5]
 8062376: 2900         	cmp	r1, #0x0
 8062378: d018         	beq	0x80623ac <rom_start+0x623ac> @ imm = #0x30
 806237a: 480f         	ldr	r0, [pc, #0x3c]         @ 0x80623b8 <rom_start+0x623b8>
 806237c: 2400         	movs	r4, #0x0
 806237e: 6004         	str	r4, [r0]
 8062380: 300c         	adds	r0, #0xc
 8062382: 6004         	str	r4, [r0]
 8062384: 3034         	adds	r0, #0x34
 8062386: 6004         	str	r4, [r0]
 8062388: 3804         	subs	r0, #0x4
 806238a: 6004         	str	r4, [r0]
 806238c: 1c08         	adds	r0, r1, #0x0
 806238e: f7f8 f895    	bl	0x805a4bc <rom_start+0x5a4bc> @ imm = #-0x7ed6
 8062392: 480a         	ldr	r0, [pc, #0x28]         @ 0x80623bc <rom_start+0x623bc>
 8062394: 6800         	ldr	r0, [r0]
 8062396: 2800         	cmp	r0, #0x0
 8062398: d001         	beq	0x806239e <rom_start+0x6239e> @ imm = #0x2
 806239a: f7f8 f88f    	bl	0x805a4bc <rom_start+0x5a4bc> @ imm = #-0x7ee2
 806239e: 4808         	ldr	r0, [pc, #0x20]         @ 0x80623c0 <rom_start+0x623c0>
 80623a0: 6004         	str	r4, [r0]
 80623a2: 602c         	str	r4, [r5]
 80623a4: 4807         	ldr	r0, [pc, #0x1c]         @ 0x80623c4 <rom_start+0x623c4>
 80623a6: 6004         	str	r4, [r0]
 80623a8: 4807         	ldr	r0, [pc, #0x1c]         @ 0x80623c8 <rom_start+0x623c8>
 80623aa: 6004         	str	r4, [r0]
 80623ac: bc30         	pop	{r4, r5}
 80623ae: bc01         	pop	{r0}
 80623b0: 4700         	bx	r0
 80623b2: 0000         	movs	r0, r0
 80623b4: 5e2c         	ldrsh	r4, [r5, r0]
 80623b6: 0300         	lsls	r0, r0, #0xc
 80623b8: 00c4         	lsls	r4, r0, #0x3
 80623ba: 0400         	lsls	r0, r0, #0x10
 80623bc: 5e30         	ldrsh	r0, [r6, r0]
 80623be: 0300         	lsls	r0, r0, #0xc
 80623c0: 5e28         	ldrsh	r0, [r5, r0]
 80623c2: 0300         	lsls	r0, r0, #0xc
 80623c4: 5e1c         	ldrsh	r4, [r3, r0]
 80623c6: 0300         	lsls	r0, r0, #0xc
 80623c8: 5e50         	ldrsh	r0, [r2, r1]
 80623ca: 0300         	lsls	r0, r0, #0xc
 80623cc: b5f0         	push	{r4, r5, r6, r7, lr}
 80623ce: 4657         	mov	r7, r10
 80623d0: 464e         	mov	r6, r9
 80623d2: 4645         	mov	r5, r8
 80623d4: b4e0         	push	{r5, r6, r7}
 80623d6: 4680         	mov	r8, r0
 80623d8: 4820         	ldr	r0, [pc, #0x80]         @ 0x806245c <rom_start+0x6245c>
 80623da: 6807         	ldr	r7, [r0]
 80623dc: 4820         	ldr	r0, [pc, #0x80]         @ 0x8062460 <rom_start+0x62460>
 80623de: 4681         	mov	r9, r0
 80623e0: 267f         	movs	r6, #0x7f
 80623e2: 4920         	ldr	r1, [pc, #0x80]         @ 0x8062464 <rom_start+0x62464>
 80623e4: 468a         	mov	r10, r1
 80623e6: 464a         	mov	r2, r9
 80623e8: 3204         	adds	r2, #0x4
 80623ea: 4691         	mov	r9, r2
 80623ec: 3a04         	subs	r2, #0x4
 80623ee: ca01         	ldm	r2!, {r0}
 80623f0: 2100         	movs	r1, #0x0
 80623f2: 4a1d         	ldr	r2, [pc, #0x74]         @ 0x8062468 <rom_start+0x62468>
 80623f4: 4b1d         	ldr	r3, [pc, #0x74]         @ 0x806246c <rom_start+0x6246c>
 80623f6: f003 febd    	bl	0x8066174 <rom_start+0x66174> @ imm = #0x3d7a
 80623fa: 1c0b         	adds	r3, r1, #0x0
 80623fc: 1c02         	adds	r2, r0, #0x0
 80623fe: 0d15         	lsrs	r5, r2, #0x14
 8062400: 031c         	lsls	r4, r3, #0xc
 8062402: 1c29         	adds	r1, r5, #0x0
 8062404: 4321         	orrs	r1, r4
 8062406: 0310         	lsls	r0, r2, #0xc
 8062408: 4a19         	ldr	r2, [pc, #0x64]         @ 0x8062470 <rom_start+0x62470>
 806240a: 4b1a         	ldr	r3, [pc, #0x68]         @ 0x8062474 <rom_start+0x62474>
 806240c: f003 fc32    	bl	0x8065c74 <rom_start+0x65c74> @ imm = #0x3864
 8062410: 4642         	mov	r2, r8
 8062412: 2300         	movs	r3, #0x0
 8062414: f003 fc2e    	bl	0x8065c74 <rom_start+0x65c74> @ imm = #0x385c
 8062418: c701         	stm	r7!, {r0}
 806241a: 3e01         	subs	r6, #0x1
 806241c: 2001         	movs	r0, #0x1
 806241e: 4240         	rsbs	r0, r0, #0
 8062420: 4286         	cmp	r6, r0
 8062422: d1e0         	bne	0x80623e6 <rom_start+0x623e6> @ imm = #-0x40
 8062424: 4651         	mov	r1, r10
 8062426: 6808         	ldr	r0, [r1]
 8062428: 4a13         	ldr	r2, [pc, #0x4c]         @ 0x8062478 <rom_start+0x62478>
 806242a: 6010         	str	r0, [r2]
 806242c: 2080         	movs	r0, #0x80
 806242e: 0240         	lsls	r0, r0, #0x9
 8062430: 4912         	ldr	r1, [pc, #0x48]         @ 0x806247c <rom_start+0x6247c>
 8062432: 8809         	ldrh	r1, [r1]
 8062434: 1a40         	subs	r0, r0, r1
 8062436: 4a12         	ldr	r2, [pc, #0x48]         @ 0x8062480 <rom_start+0x62480>
 8062438: 6010         	str	r0, [r2]
 806243a: 4912         	ldr	r1, [pc, #0x48]         @ 0x8062484 <rom_start+0x62484>
 806243c: 1c08         	adds	r0, r1, #0x0
 806243e: 4a12         	ldr	r2, [pc, #0x48]         @ 0x8062488 <rom_start+0x62488>
 8062440: 8010         	strh	r0, [r2]
 8062442: 2180         	movs	r1, #0x80
 8062444: 0049         	lsls	r1, r1, #0x1
 8062446: 1c08         	adds	r0, r1, #0x0
 8062448: 4a10         	ldr	r2, [pc, #0x40]         @ 0x806248c <rom_start+0x6248c>
 806244a: 8010         	strh	r0, [r2]
 806244c: bc38         	pop	{r3, r4, r5}
 806244e: 4698         	mov	r8, r3
 8062450: 46a1         	mov	r9, r4
 8062452: 46aa         	mov	r10, r5
 8062454: bcf0         	pop	{r4, r5, r6, r7}
 8062456: bc01         	pop	{r0}
 8062458: 4700         	bx	r0
 806245a: 0000         	movs	r0, r0
 806245c: 0d98         	lsrs	r0, r3, #0x16
 806245e: 0300         	lsls	r0, r0, #0xc
 8062460: 5bb4         	ldrh	r4, [r6, r6]
 8062462: 0875         	lsrs	r5, r6, #0x1
 8062464: 5e1c         	ldrsh	r4, [r3, r0]
 8062466: 0300         	lsls	r0, r0, #0xc
 8062468: 2b11         	cmp	r3, #0x11
 806246a: 0000         	movs	r0, r0
 806246c: 0000         	movs	r0, r0
 806246e: 0000         	movs	r0, r0
 8062470: 0105         	lsls	r5, r0, #0x4
 8062472: 0000         	movs	r0, r0
 8062474: 0000         	movs	r0, r0
 8062476: 0000         	movs	r0, r0
 8062478: 0d90         	lsrs	r0, r2, #0x16
 806247a: 0300         	lsls	r0, r0, #0xc
 806247c: 5e4c         	ldrsh	r4, [r1, r1]
 806247e: 0300         	lsls	r0, r0, #0xc
 8062480: 0d94         	lsrs	r4, r2, #0x16
 8062482: 0300         	lsls	r0, r0, #0xc
 8062484: ffff 0000    	<unknown>
 8062488: 0da2         	lsrs	r2, r4, #0x16
 806248a: 0300         	lsls	r0, r0, #0xc
 806248c: 0da0         	lsrs	r0, r4, #0x16
 806248e: 0300         	lsls	r0, r0, #0xc
 8062490: b5f0         	push	{r4, r5, r6, r7, lr}
 8062492: 4657         	mov	r7, r10
 8062494: 464e         	mov	r6, r9
 8062496: 4645         	mov	r5, r8
 8062498: b4e0         	push	{r5, r6, r7}
 806249a: b081         	sub	sp, #0x4
 806249c: 4680         	mov	r8, r0
 806249e: 1c0c         	adds	r4, r1, #0x0
 80624a0: f7ff ff66    	bl	0x8062370 <rom_start+0x62370> @ imm = #-0x134
 80624a4: 2c10         	cmp	r4, #0x10
 80624a6: d900         	bls	0x80624aa <rom_start+0x624aa> @ imm = #0x0
 80624a8: 2410         	movs	r4, #0x10
 80624aa: 484d         	ldr	r0, [pc, #0x134]        @ 0x80625e0 <rom_start+0x625e0>
 80624ac: 4580         	cmp	r8, r0
 80624ae: d900         	bls	0x80624b2 <rom_start+0x624b2> @ imm = #0x0
 80624b0: 4680         	mov	r8, r0
 80624b2: 494c         	ldr	r1, [pc, #0x130]        @ 0x80625e4 <rom_start+0x625e4>
 80624b4: 4640         	mov	r0, r8
 80624b6: 6008         	str	r0, [r1]
 80624b8: 2001         	movs	r0, #0x1
 80624ba: 6048         	str	r0, [r1, #0x4]
 80624bc: 2200         	movs	r2, #0x0
 80624be: 608a         	str	r2, [r1, #0x8]
 80624c0: 4e49         	ldr	r6, [pc, #0x124]        @ 0x80625e8 <rom_start+0x625e8>
 80624c2: 46b1         	mov	r9, r6
 80624c4: 4640         	mov	r0, r8
 80624c6: 2128         	movs	r1, #0x28
 80624c8: f003 fe8c    	bl	0x80661e4 <rom_start+0x661e4> @ imm = #0x3d18
 80624cc: 300f         	adds	r0, #0xf
 80624ce: 4a47         	ldr	r2, [pc, #0x11c]        @ 0x80625ec <rom_start+0x625ec>
 80624d0: 1c11         	adds	r1, r2, #0x0
 80624d2: 4008         	ands	r0, r1
 80624d4: 8030         	strh	r0, [r6]
 80624d6: 4240         	rsbs	r0, r0, #0
 80624d8: 4e45         	ldr	r6, [pc, #0x114]        @ 0x80625f0 <rom_start+0x625f0>
 80624da: 8030         	strh	r0, [r6]
 80624dc: 4648         	mov	r0, r9
 80624de: 8800         	ldrh	r0, [r0]
 80624e0: 0041         	lsls	r1, r0, #0x1
 80624e2: 464a         	mov	r2, r9
 80624e4: 8812         	ldrh	r2, [r2]
 80624e6: 1889         	adds	r1, r1, r2
 80624e8: 00a0         	lsls	r0, r4, #0x2
 80624ea: 1900         	adds	r0, r0, r4
 80624ec: 00c0         	lsls	r0, r0, #0x3
 80624ee: 180d         	adds	r5, r1, r0
 80624f0: 1c28         	adds	r0, r5, #0x0
 80624f2: f7f7 ff6b    	bl	0x805a3cc <rom_start+0x5a3cc> @ imm = #-0x812a
 80624f6: 4e3f         	ldr	r6, [pc, #0xfc]         @ 0x80625f4 <rom_start+0x625f4>
 80624f8: 6030         	str	r0, [r6]
 80624fa: 2800         	cmp	r0, #0x0
 80624fc: d103         	bne	0x8062506 <rom_start+0x62506> @ imm = #0x6
 80624fe: 483e         	ldr	r0, [pc, #0xf8]         @ 0x80625f8 <rom_start+0x625f8>
 8062500: 1c29         	adds	r1, r5, #0x0
 8062502: f7f5 fbab    	bl	0x8057c5c <rom_start+0x57c5c> @ imm = #-0xa8aa
 8062506: 483d         	ldr	r0, [pc, #0xf4]         @ 0x80625fc <rom_start+0x625fc>
 8062508: 4682         	mov	r10, r0
 806250a: 6830         	ldr	r0, [r6]
 806250c: 6800         	ldr	r0, [r0]
 806250e: 4651         	mov	r1, r10
 8062510: 6008         	str	r0, [r1]
 8062512: 2688         	movs	r6, #0x88
 8062514: 00f6         	lsls	r6, r6, #0x3
 8062516: 1c30         	adds	r0, r6, #0x0
 8062518: f7f7 ff94    	bl	0x805a444 <rom_start+0x5a444> @ imm = #-0x80d8
 806251c: 4f38         	ldr	r7, [pc, #0xe0]         @ 0x8062600 <rom_start+0x62600>
 806251e: 6038         	str	r0, [r7]
 8062520: 2800         	cmp	r0, #0x0
 8062522: d103         	bne	0x806252c <rom_start+0x6252c> @ imm = #0x6
 8062524: 4837         	ldr	r0, [pc, #0xdc]         @ 0x8062604 <rom_start+0x62604>
 8062526: 1c31         	adds	r1, r6, #0x0
 8062528: f7f5 fb98    	bl	0x8057c5c <rom_start+0x57c5c> @ imm = #-0xa8d0
 806252c: 4936         	ldr	r1, [pc, #0xd8]         @ 0x8062608 <rom_start+0x62608>
 806252e: 6838         	ldr	r0, [r7]
 8062530: 6800         	ldr	r0, [r0]
 8062532: 6008         	str	r0, [r1]
 8062534: 4935         	ldr	r1, [pc, #0xd4]         @ 0x806260c <rom_start+0x6260c>
 8062536: 2280         	movs	r2, #0x80
 8062538: 0092         	lsls	r2, r2, #0x2
 806253a: 1880         	adds	r0, r0, r2
 806253c: 6008         	str	r0, [r1]
 806253e: 4834         	ldr	r0, [pc, #0xd0]         @ 0x8062610 <rom_start+0x62610>
 8062540: 4656         	mov	r6, r10
 8062542: 6833         	ldr	r3, [r6]
 8062544: 464a         	mov	r2, r9
 8062546: 8812         	ldrh	r2, [r2]
 8062548: 18d1         	adds	r1, r2, r3
 806254a: 6001         	str	r1, [r0]
 806254c: 4831         	ldr	r0, [pc, #0xc4]         @ 0x8062614 <rom_start+0x62614>
 806254e: 7004         	strb	r4, [r0]
 8062550: 4a31         	ldr	r2, [pc, #0xc4]         @ 0x8062618 <rom_start+0x62618>
 8062552: 464c         	mov	r4, r9
 8062554: 8824         	ldrh	r4, [r4]
 8062556: 0060         	lsls	r0, r4, #0x1
 8062558: 1809         	adds	r1, r1, r0
 806255a: 6011         	str	r1, [r2]
 806255c: 2600         	movs	r6, #0x0
 806255e: 9600         	str	r6, [sp]
 8062560: 4a2e         	ldr	r2, [pc, #0xb8]         @ 0x806261c <rom_start+0x6261c>
 8062562: 4668         	mov	r0, sp
 8062564: 6010         	str	r0, [r2]
 8062566: 6053         	str	r3, [r2, #0x4]
 8062568: 08a8         	lsrs	r0, r5, #0x2
 806256a: 2185         	movs	r1, #0x85
 806256c: 0609         	lsls	r1, r1, #0x18
 806256e: 4308         	orrs	r0, r1
 8062570: 6090         	str	r0, [r2, #0x8]
 8062572: 6890         	ldr	r0, [r2, #0x8]
 8062574: 4640         	mov	r0, r8
 8062576: f7ff ff29    	bl	0x80623cc <rom_start+0x623cc> @ imm = #-0x1ae
 806257a: 4929         	ldr	r1, [pc, #0xa4]         @ 0x8062620 <rom_start+0x62620>
 806257c: 2080         	movs	r0, #0x80
 806257e: 8008         	strh	r0, [r1]
 8062580: 3902         	subs	r1, #0x2
 8062582: 4a28         	ldr	r2, [pc, #0xa0]         @ 0x8062624 <rom_start+0x62624>
 8062584: 1c10         	adds	r0, r2, #0x0
 8062586: 8008         	strh	r0, [r1]
 8062588: 313a         	adds	r1, #0x3a
 806258a: 4654         	mov	r4, r10
 806258c: 6820         	ldr	r0, [r4]
 806258e: 6008         	str	r0, [r1]
 8062590: 3104         	adds	r1, #0x4
 8062592: 4825         	ldr	r0, [pc, #0x94]         @ 0x8062628 <rom_start+0x62628>
 8062594: 6008         	str	r0, [r1]
 8062596: 3104         	adds	r1, #0x4
 8062598: 20b6         	movs	r0, #0xb6
 806259a: 0600         	lsls	r0, r0, #0x18
 806259c: 6008         	str	r0, [r1]
 806259e: 4a23         	ldr	r2, [pc, #0x8c]         @ 0x806262c <rom_start+0x6262c>
 80625a0: 4e13         	ldr	r6, [pc, #0x4c]         @ 0x80625f0 <rom_start+0x625f0>
 80625a2: 8830         	ldrh	r0, [r6]
 80625a4: 3802         	subs	r0, #0x2
 80625a6: 21c4         	movs	r1, #0xc4
 80625a8: 0409         	lsls	r1, r1, #0x10
 80625aa: 4308         	orrs	r0, r1
 80625ac: 6010         	str	r0, [r2]
 80625ae: 4c20         	ldr	r4, [pc, #0x80]         @ 0x8062630 <rom_start+0x62630>
 80625b0: 4820         	ldr	r0, [pc, #0x80]         @ 0x8062634 <rom_start+0x62634>
 80625b2: 4641         	mov	r1, r8
 80625b4: f003 fe16    	bl	0x80661e4 <rom_start+0x661e4> @ imm = #0x3c2c
 80625b8: 2180         	movs	r1, #0x80
 80625ba: 0249         	lsls	r1, r1, #0x9
 80625bc: 1a09         	subs	r1, r1, r0
 80625be: 2080         	movs	r0, #0x80
 80625c0: 0400         	lsls	r0, r0, #0x10
 80625c2: 4301         	orrs	r1, r0
 80625c4: 6021         	str	r1, [r4]
 80625c6: 481c         	ldr	r0, [pc, #0x70]         @ 0x8062638 <rom_start+0x62638>
 80625c8: 2100         	movs	r1, #0x0
 80625ca: 6001         	str	r1, [r0]
 80625cc: 481b         	ldr	r0, [pc, #0x6c]         @ 0x806263c <rom_start+0x6263c>
 80625ce: 6001         	str	r1, [r0]
 80625d0: b001         	add	sp, #0x4
 80625d2: bc38         	pop	{r3, r4, r5}
 80625d4: 4698         	mov	r8, r3
 80625d6: 46a1         	mov	r9, r4
 80625d8: 46aa         	mov	r10, r5
 80625da: bcf0         	pop	{r4, r5, r6, r7}
 80625dc: bc01         	pop	{r0}
 80625de: 4700         	bx	r0
 80625e0: abea         	add	r3, sp, #0x3a8
 80625e2: 0000         	movs	r0, r0
 80625e4: 5e40         	ldrsh	r0, [r0, r1]
 80625e6: 0300         	lsls	r0, r0, #0xc
 80625e8: 5e4c         	ldrsh	r4, [r1, r1]
 80625ea: 0300         	lsls	r0, r0, #0xc
 80625ec: fff0 0000    	<unknown>
 80625f0: 5e18         	ldrsh	r0, [r3, r0]
 80625f2: 0300         	lsls	r0, r0, #0xc
 80625f4: 5e2c         	ldrsh	r4, [r5, r0]
 80625f6: 0300         	lsls	r0, r0, #0xc
 80625f8: 5db4         	ldrb	r4, [r6, r6]
 80625fa: 0875         	lsrs	r5, r6, #0x1
 80625fc: 5e1c         	ldrsh	r4, [r3, r0]
 80625fe: 0300         	lsls	r0, r0, #0xc
 8062600: 5e30         	ldrsh	r0, [r6, r0]
 8062602: 0300         	lsls	r0, r0, #0xc
 8062604: 5de8         	ldrb	r0, [r5, r7]
 8062606: 0875         	lsrs	r5, r6, #0x1
 8062608: 0d98         	lsrs	r0, r3, #0x16
 806260a: 0300         	lsls	r0, r0, #0xc
 806260c: 5e28         	ldrsh	r0, [r5, r0]
 806260e: 0300         	lsls	r0, r0, #0xc
 8062610: 5e50         	ldrsh	r0, [r2, r1]
 8062612: 0300         	lsls	r0, r0, #0xc
 8062614: 5e04         	ldrsh	r4, [r0, r0]
 8062616: 0300         	lsls	r0, r0, #0xc
 8062618: 5e24         	ldrsh	r4, [r4, r0]
 806261a: 0300         	lsls	r0, r0, #0xc
 806261c: 00d4         	lsls	r4, r2, #0x3
 806261e: 0400         	lsls	r0, r0, #0x10
 8062620: 0084         	lsls	r4, r0, #0x2
 8062622: 0400         	lsls	r0, r0, #0x10
 8062624: 0b04         	lsrs	r4, r0, #0xc
 8062626: 0000         	movs	r0, r0
 8062628: 00a0         	lsls	r0, r4, #0x2
 806262a: 0400         	lsls	r0, r0, #0x10
 806262c: 0104         	lsls	r4, r0, #0x4
 806262e: 0400         	lsls	r0, r0, #0x10
 8062630: 0100         	lsls	r0, r0, #0x4
 8062632: 0400         	lsls	r0, r0, #0x10
 8062634: 0ae0         	lsrs	r0, r4, #0xb
 8062636: 0100         	lsls	r0, r0, #0x4
 8062638: 5e00         	ldrsh	r0, [r0, r0]
 806263a: 0300         	lsls	r0, r0, #0xc
 806263c: 5e0c         	ldrsh	r4, [r1, r0]
 806263e: 0300         	lsls	r0, r0, #0xc
