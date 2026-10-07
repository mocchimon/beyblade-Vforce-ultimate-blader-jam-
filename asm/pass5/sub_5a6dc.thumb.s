
00000000 <rom>:
   5a6dc: b5f0         	push	{r4, r5, r6, r7, lr}
   5a6de: 4657         	mov	r7, r10
   5a6e0: 464e         	mov	r6, r9
   5a6e2: 4645         	mov	r5, r8
   5a6e4: b4e0         	push	{r5, r6, r7}
   5a6e6: 4809         	ldr	r0, [pc, #0x24]         @ 0x5a70c <rom+0x5a70c>
   5a6e8: 1c04         	adds	r4, r0, #0x0
   5a6ea: 8820         	ldrh	r0, [r4]
   5a6ec: 2802         	cmp	r0, #0x2
   5a6ee: d118         	bne	0x5a722 <rom+0x5a722>   @ imm = #0x30
   5a6f0: 4b07         	ldr	r3, [pc, #0x1c]         @ 0x5a710 <rom+0x5a710>
   5a6f2: 881a         	ldrh	r2, [r3]
   5a6f4: 1c10         	adds	r0, r2, #0x0
   5a6f6: 2800         	cmp	r0, #0x0
   5a6f8: d00e         	beq	0x5a718 <rom+0x5a718>   @ imm = #0x1c
   5a6fa: 4806         	ldr	r0, [pc, #0x18]         @ 0x5a714 <rom+0x5a714>
   5a6fc: 6801         	ldr	r1, [r0]
   5a6fe: 880d         	ldrh	r5, [r1]
   5a700: 3102         	adds	r1, #0x2
   5a702: 6001         	str	r1, [r0]
   5a704: 1e50         	subs	r0, r2, #0x1
   5a706: 8018         	strh	r0, [r3]
   5a708: e007         	b	0x5a71a <rom+0x5a71a>   @ imm = #0xe
   5a70a: 0000         	movs	r0, r0
   5a70c: 5ca4         	ldrb	r4, [r4, r2]
   5a70e: 0300         	lsls	r0, r0, #0xc
   5a710: 5db4         	ldrb	r4, [r6, r6]
   5a712: 0300         	lsls	r0, r0, #0xc
   5a714: 5db0         	ldrb	r0, [r6, r6]
   5a716: 0300         	lsls	r0, r0, #0xc
   5a718: 8020         	strh	r0, [r4]
   5a71a: 482a         	ldr	r0, [pc, #0xa8]         @ 0x5a7c4 <rom+0x5a7c4>
   5a71c: 492a         	ldr	r1, [pc, #0xa8]         @ 0x5a7c8 <rom+0x5a7c8>
   5a71e: 6809         	ldr	r1, [r1]
   5a720: 6001         	str	r1, [r0]
   5a722: 8821         	ldrh	r1, [r4]
   5a724: 2902         	cmp	r1, #0x2
   5a726: d01b         	beq	0x5a760 <rom+0x5a760>   @ imm = #0x36
   5a728: 4828         	ldr	r0, [pc, #0xa0]         @ 0x5a7cc <rom+0x5a7cc>
   5a72a: 8800         	ldrh	r0, [r0]
   5a72c: 43c0         	mvns	r0, r0
   5a72e: 0400         	lsls	r0, r0, #0x10
   5a730: 0c05         	lsrs	r5, r0, #0x10
   5a732: 4827         	ldr	r0, [pc, #0x9c]         @ 0x5a7d0 <rom+0x5a7d0>
   5a734: 4028         	ands	r0, r5
   5a736: 2800         	cmp	r0, #0x0
   5a738: d003         	beq	0x5a742 <rom+0x5a742>   @ imm = #0x6
   5a73a: 4822         	ldr	r0, [pc, #0x88]         @ 0x5a7c4 <rom+0x5a7c4>
   5a73c: 4922         	ldr	r1, [pc, #0x88]         @ 0x5a7c8 <rom+0x5a7c8>
   5a73e: 6809         	ldr	r1, [r1]
   5a740: 6001         	str	r1, [r0]
   5a742: 8824         	ldrh	r4, [r4]
   5a744: 2c01         	cmp	r4, #0x1
   5a746: d10b         	bne	0x5a760 <rom+0x5a760>   @ imm = #0x16
   5a748: 4a22         	ldr	r2, [pc, #0x88]         @ 0x5a7d4 <rom+0x5a7d4>
   5a74a: 8810         	ldrh	r0, [r2]
   5a74c: 2800         	cmp	r0, #0x0
   5a74e: d007         	beq	0x5a760 <rom+0x5a760>   @ imm = #0xe
   5a750: 4821         	ldr	r0, [pc, #0x84]         @ 0x5a7d8 <rom+0x5a7d8>
   5a752: 6801         	ldr	r1, [r0]
   5a754: 800d         	strh	r5, [r1]
   5a756: 3102         	adds	r1, #0x2
   5a758: 6001         	str	r1, [r0]
   5a75a: 8810         	ldrh	r0, [r2]
   5a75c: 3801         	subs	r0, #0x1
   5a75e: 8010         	strh	r0, [r2]
   5a760: 4c1e         	ldr	r4, [pc, #0x78]         @ 0x5a7dc <rom+0x5a7dc>
   5a762: 491f         	ldr	r1, [pc, #0x7c]         @ 0x5a7e0 <rom+0x5a7e0>
   5a764: 880a         	ldrh	r2, [r1]
   5a766: 1c28         	adds	r0, r5, #0x0
   5a768: 4390         	bics	r0, r2
   5a76a: 8020         	strh	r0, [r4]
   5a76c: 4b1d         	ldr	r3, [pc, #0x74]         @ 0x5a7e4 <rom+0x5a7e4>
   5a76e: 2000         	movs	r0, #0x0
   5a770: 8018         	strh	r0, [r3]
   5a772: 481d         	ldr	r0, [pc, #0x74]         @ 0x5a7e8 <rom+0x5a7e8>
   5a774: 8002         	strh	r2, [r0]
   5a776: 800d         	strh	r5, [r1]
   5a778: 2500         	movs	r5, #0x0
   5a77a: 469a         	mov	r10, r3
   5a77c: 2201         	movs	r2, #0x1
   5a77e: 4691         	mov	r9, r2
   5a780: 4f11         	ldr	r7, [pc, #0x44]         @ 0x5a7c8 <rom+0x5a7c8>
   5a782: 4e1a         	ldr	r6, [pc, #0x68]         @ 0x5a7ec <rom+0x5a7ec>
   5a784: 1d34         	adds	r4, r6, #0x4
   5a786: 46a0         	mov	r8, r4
   5a788: 2008         	movs	r0, #0x8
   5a78a: 1980         	adds	r0, r0, r6
   5a78c: 4684         	mov	r12, r0
   5a78e: 4648         	mov	r0, r9
   5a790: 40a8         	lsls	r0, r5
   5a792: 4912         	ldr	r1, [pc, #0x48]         @ 0x5a7dc <rom+0x5a7dc>
   5a794: 8809         	ldrh	r1, [r1]
   5a796: 4008         	ands	r0, r1
   5a798: 2800         	cmp	r0, #0x0
   5a79a: dd37         	ble	0x5a80c <rom+0x5a80c>   @ imm = #0x6e
   5a79c: 4c13         	ldr	r4, [pc, #0x4c]         @ 0x5a7ec <rom+0x5a7ec>
   5a79e: 006a         	lsls	r2, r5, #0x1
   5a7a0: 1950         	adds	r0, r2, r5
   5a7a2: 00c3         	lsls	r3, r0, #0x3
   5a7a4: 4640         	mov	r0, r8
   5a7a6: 1819         	adds	r1, r3, r0
   5a7a8: 1c20         	adds	r0, r4, #0x0
   5a7aa: 300c         	adds	r0, #0xc
   5a7ac: 1818         	adds	r0, r3, r0
   5a7ae: 6809         	ldr	r1, [r1]
   5a7b0: 6800         	ldr	r0, [r0]
   5a7b2: 1809         	adds	r1, r1, r0
   5a7b4: 6838         	ldr	r0, [r7]
   5a7b6: 4288         	cmp	r0, r1
   5a7b8: d91a         	bls	0x5a7f0 <rom+0x5a7f0>   @ imm = #0x34
   5a7ba: 1918         	adds	r0, r3, r4
   5a7bc: 4649         	mov	r1, r9
   5a7be: 8201         	strh	r1, [r0, #0x10]
   5a7c0: e01a         	b	0x5a7f8 <rom+0x5a7f8>   @ imm = #0x34
   5a7c2: 0000         	movs	r0, r0
   5a7c4: 5da8         	ldrb	r0, [r5, r6]
   5a7c6: 0300         	lsls	r0, r0, #0xc
   5a7c8: 0e30         	lsrs	r0, r6, #0x18
   5a7ca: 0300         	lsls	r0, r0, #0xc
   5a7cc: 0130         	lsls	r0, r6, #0x4
   5a7ce: 0400         	lsls	r0, r0, #0x10
   5a7d0: 03ff         	lsls	r7, r7, #0xf
   5a7d2: 0000         	movs	r0, r0
   5a7d4: 5db4         	ldrb	r4, [r6, r6]
   5a7d6: 0300         	lsls	r0, r0, #0xc
   5a7d8: 5db0         	ldrb	r0, [r6, r6]
   5a7da: 0300         	lsls	r0, r0, #0xc
   5a7dc: 5da0         	ldrb	r0, [r4, r6]
   5a7de: 0300         	lsls	r0, r0, #0xc
   5a7e0: 5ca0         	ldrb	r0, [r4, r2]
   5a7e2: 0300         	lsls	r0, r0, #0xc
   5a7e4: 5dac         	ldrb	r4, [r5, r6]
   5a7e6: 0300         	lsls	r0, r0, #0xc
   5a7e8: 5da4         	ldrb	r4, [r4, r6]
   5a7ea: 0300         	lsls	r0, r0, #0xc
   5a7ec: 5cb0         	ldrb	r0, [r6, r2]
   5a7ee: 0300         	lsls	r0, r0, #0xc
   5a7f0: 1919         	adds	r1, r3, r4
   5a7f2: 8a08         	ldrh	r0, [r1, #0x10]
   5a7f4: 3001         	adds	r0, #0x1
   5a7f6: 8208         	strh	r0, [r1, #0x10]
   5a7f8: 1950         	adds	r0, r2, r5
   5a7fa: 00c0         	lsls	r0, r0, #0x3
   5a7fc: 1c32         	adds	r2, r6, #0x0
   5a7fe: 3214         	adds	r2, #0x14
   5a800: 1882         	adds	r2, r0, r2
   5a802: 1980         	adds	r0, r0, r6
   5a804: 6801         	ldr	r1, [r0]
   5a806: 6011         	str	r1, [r2]
   5a808: 6839         	ldr	r1, [r7]
   5a80a: 6001         	str	r1, [r0]
   5a80c: 2401         	movs	r4, #0x1
   5a80e: 1c23         	adds	r3, r4, #0x0
   5a810: 40ab         	lsls	r3, r5
   5a812: 1c18         	adds	r0, r3, #0x0
   5a814: 4a1c         	ldr	r2, [pc, #0x70]         @ 0x5a888 <rom+0x5a888>
   5a816: 8812         	ldrh	r2, [r2]
   5a818: 4010         	ands	r0, r2
   5a81a: 2800         	cmp	r0, #0x0
   5a81c: dd09         	ble	0x5a832 <rom+0x5a832>   @ imm = #0x12
   5a81e: 0068         	lsls	r0, r5, #0x1
   5a820: 1940         	adds	r0, r0, r5
   5a822: 00c0         	lsls	r0, r0, #0x3
   5a824: 4661         	mov	r1, r12
   5a826: 1842         	adds	r2, r0, r1
   5a828: 1980         	adds	r0, r0, r6
   5a82a: 6839         	ldr	r1, [r7]
   5a82c: 6800         	ldr	r0, [r0]
   5a82e: 1a09         	subs	r1, r1, r0
   5a830: 6011         	str	r1, [r2]
   5a832: 4a15         	ldr	r2, [pc, #0x54]         @ 0x5a888 <rom+0x5a888>
   5a834: 8810         	ldrh	r0, [r2]
   5a836: 4128         	asrs	r0, r5
   5a838: 4020         	ands	r0, r4
   5a83a: 2800         	cmp	r0, #0x0
   5a83c: d117         	bne	0x5a86e <rom+0x5a86e>   @ imm = #0x2e
   5a83e: 1c18         	adds	r0, r3, #0x0
   5a840: 4c12         	ldr	r4, [pc, #0x48]         @ 0x5a88c <rom+0x5a88c>
   5a842: 8824         	ldrh	r4, [r4]
   5a844: 4020         	ands	r0, r4
   5a846: 2800         	cmp	r0, #0x0
   5a848: dd11         	ble	0x5a86e <rom+0x5a86e>   @ imm = #0x22
   5a84a: 0068         	lsls	r0, r5, #0x1
   5a84c: 1940         	adds	r0, r0, r5
   5a84e: 00c0         	lsls	r0, r0, #0x3
   5a850: 4641         	mov	r1, r8
   5a852: 1842         	adds	r2, r0, r1
   5a854: 6839         	ldr	r1, [r7]
   5a856: 6011         	str	r1, [r2]
   5a858: 4664         	mov	r4, r12
   5a85a: 1902         	adds	r2, r0, r4
   5a85c: 1980         	adds	r0, r0, r6
   5a85e: 6800         	ldr	r0, [r0]
   5a860: 1a09         	subs	r1, r1, r0
   5a862: 6011         	str	r1, [r2]
   5a864: 4650         	mov	r0, r10
   5a866: 8800         	ldrh	r0, [r0]
   5a868: 4303         	orrs	r3, r0
   5a86a: 4651         	mov	r1, r10
   5a86c: 800b         	strh	r3, [r1]
   5a86e: 1c68         	adds	r0, r5, #0x1
   5a870: 0400         	lsls	r0, r0, #0x10
   5a872: 0c05         	lsrs	r5, r0, #0x10
   5a874: 2d09         	cmp	r5, #0x9
   5a876: d98a         	bls	0x5a78e <rom+0x5a78e>   @ imm = #-0xec
   5a878: bc38         	pop	{r3, r4, r5}
   5a87a: 4698         	mov	r8, r3
   5a87c: 46a1         	mov	r9, r4
   5a87e: 46aa         	mov	r10, r5
   5a880: bcf0         	pop	{r4, r5, r6, r7}
   5a882: bc01         	pop	{r0}
   5a884: 4700         	bx	r0
   5a886: 0000         	movs	r0, r0
   5a888: 5ca0         	ldrb	r0, [r4, r2]
   5a88a: 0300         	lsls	r0, r0, #0xc
   5a88c: 5da4         	ldrb	r4, [r4, r6]
   5a88e: 0300         	lsls	r0, r0, #0xc
   5a890: b5f0         	push	{r4, r5, r6, r7, lr}
   5a892: 464f         	mov	r7, r9
   5a894: 4646         	mov	r6, r8
   5a896: b4c0         	push	{r6, r7}
   5a898: 4a1e         	ldr	r2, [pc, #0x78]         @ 0x5a914 <rom+0x5a914>
   5a89a: 481f         	ldr	r0, [pc, #0x7c]         @ 0x5a918 <rom+0x5a918>
   5a89c: 8801         	ldrh	r1, [r0]
   5a89e: 43c9         	mvns	r1, r1
   5a8a0: 8011         	strh	r1, [r2]
   5a8a2: 481e         	ldr	r0, [pc, #0x78]         @ 0x5a91c <rom+0x5a91c>
   5a8a4: 8001         	strh	r1, [r0]
   5a8a6: 4a1e         	ldr	r2, [pc, #0x78]         @ 0x5a920 <rom+0x5a920>
   5a8a8: 2000         	movs	r0, #0x0
   5a8aa: 8010         	strh	r0, [r2]
   5a8ac: 481d         	ldr	r0, [pc, #0x74]         @ 0x5a924 <rom+0x5a924>
   5a8ae: 8001         	strh	r1, [r0]
   5a8b0: 481d         	ldr	r0, [pc, #0x74]         @ 0x5a928 <rom+0x5a928>
   5a8b2: 2100         	movs	r1, #0x0
   5a8b4: 6001         	str	r1, [r0]
   5a8b6: 481d         	ldr	r0, [pc, #0x74]         @ 0x5a92c <rom+0x5a92c>
   5a8b8: 6001         	str	r1, [r0]
   5a8ba: 2500         	movs	r5, #0x0
   5a8bc: 481c         	ldr	r0, [pc, #0x70]         @ 0x5a930 <rom+0x5a930>
   5a8be: 4681         	mov	r9, r0
   5a8c0: 491c         	ldr	r1, [pc, #0x70]         @ 0x5a934 <rom+0x5a934>
   5a8c2: 468c         	mov	r12, r1
   5a8c4: 2400         	movs	r4, #0x0
   5a8c6: 2008         	movs	r0, #0x8
   5a8c8: 4460         	add	r0, r12
   5a8ca: 4680         	mov	r8, r0
   5a8cc: 4667         	mov	r7, r12
   5a8ce: 3704         	adds	r7, #0x4
   5a8d0: 4666         	mov	r6, r12
   5a8d2: 3614         	adds	r6, #0x14
   5a8d4: 006a         	lsls	r2, r5, #0x1
   5a8d6: 1952         	adds	r2, r2, r5
   5a8d8: 00d2         	lsls	r2, r2, #0x3
   5a8da: 4661         	mov	r1, r12
   5a8dc: 1853         	adds	r3, r2, r1
   5a8de: 601c         	str	r4, [r3]
   5a8e0: 19d0         	adds	r0, r2, r7
   5a8e2: 6004         	str	r4, [r0]
   5a8e4: 1990         	adds	r0, r2, r6
   5a8e6: 6004         	str	r4, [r0]
   5a8e8: 4660         	mov	r0, r12
   5a8ea: 300c         	adds	r0, #0xc
   5a8ec: 1810         	adds	r0, r2, r0
   5a8ee: 2164         	movs	r1, #0x64
   5a8f0: 6001         	str	r1, [r0]
   5a8f2: 4442         	add	r2, r8
   5a8f4: 6014         	str	r4, [r2]
   5a8f6: 821c         	strh	r4, [r3, #0x10]
   5a8f8: 1c68         	adds	r0, r5, #0x1
   5a8fa: 0600         	lsls	r0, r0, #0x18
   5a8fc: 0e05         	lsrs	r5, r0, #0x18
   5a8fe: 2d09         	cmp	r5, #0x9
