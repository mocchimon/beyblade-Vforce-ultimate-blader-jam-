   58400: b5f0         	push	{r4, r5, r6, r7, lr}
   58402: 4647         	mov	r7, r8
   58404: b480         	push	{r7}
   58406: 1c04         	adds	r4, r0, #0x0
   58408: 1c0f         	adds	r7, r1, #0x0
   5840a: 0412         	lsls	r2, r2, #0x10
   5840c: 0c12         	lsrs	r2, r2, #0x10
   5840e: 4690         	mov	r8, r2
   58410: f7ff fe62    	bl	0x580d8 <rom+0x580d8>   @ imm = #-0x33c
   58414: 1c05         	adds	r5, r0, #0x0
   58416: 6822         	ldr	r2, [r4]
   58418: 6810         	ldr	r0, [r2]
   5841a: 0041         	lsls	r1, r0, #0x1
   5841c: 2002         	movs	r0, #0x2
   5841e: 4008         	ands	r0, r1
   58420: 2800         	cmp	r0, #0x0
   58422: d000         	beq	0x58426 <rom+0x58426>   @ imm = #0x0
   58424: 3102         	adds	r1, #0x2
   58426: 2010         	movs	r0, #0x10
   58428: 79d3         	ldrb	r3, [r2, #0x7]
   5842a: 4018         	ands	r0, r3
   5842c: 2800         	cmp	r0, #0x0
   5842e: d010         	beq	0x58452 <rom+0x58452>   @ imm = #0x20
   58430: 6890         	ldr	r0, [r2, #0x8]
   58432: 00c0         	lsls	r0, r0, #0x3
   58434: 3020         	adds	r0, #0x20
   58436: 1810         	adds	r0, r2, r0
   58438: 1842         	adds	r2, r0, r1
   5843a: 2a00         	cmp	r2, #0x0
   5843c: d009         	beq	0x58452 <rom+0x58452>   @ imm = #0x12
   5843e: 0138         	lsls	r0, r7, #0x4
   58440: 1812         	adds	r2, r2, r0
   58442: 7811         	ldrb	r1, [r2]
   58444: 1c20         	adds	r0, r4, #0x0
   58446: 30a4         	adds	r0, #0xa4
   58448: 7001         	strb	r1, [r0]
   5844a: 7850         	ldrb	r0, [r2, #0x1]
   5844c: 1c22         	adds	r2, r4, #0x0
   5844e: 32a5         	adds	r2, #0xa5
   58450: 7010         	strb	r0, [r2]
   58452: 8828         	ldrh	r0, [r5]
   58454: 4684         	mov	r12, r0
   58456: 886e         	ldrh	r6, [r5, #0x2]
   58458: 45b0         	cmp	r8, r6
   5845a: d21a         	bhs	0x58492 <rom+0x58492>   @ imm = #0x34
   5845c: 79e9         	ldrb	r1, [r5, #0x7]
   5845e: 79a8         	ldrb	r0, [r5, #0x6]
   58460: 1c22         	adds	r2, r4, #0x0
   58462: 3232         	adds	r2, #0x32
   58464: 2300         	movs	r3, #0x0
   58466: 7010         	strb	r0, [r2]
   58468: 1c20         	adds	r0, r4, #0x0
   5846a: 3033         	adds	r0, #0x33
   5846c: 7001         	strb	r1, [r0]
   5846e: 88a8         	ldrh	r0, [r5, #0x4]
   58470: 2200         	movs	r2, #0x0
   58472: 86a0         	strh	r0, [r4, #0x34]
   58474: 86e3         	strh	r3, [r4, #0x36]
   58476: 84e6         	strh	r6, [r4, #0x26]
   58478: 8427         	strh	r7, [r4, #0x20]
   5847a: 1c20         	adds	r0, r4, #0x0
   5847c: 3024         	adds	r0, #0x24
   5847e: 7002         	strb	r2, [r0]
   58480: 4660         	mov	r0, r12
   58482: 4440         	add	r0, r8
   58484: 8460         	strh	r0, [r4, #0x22]
   58486: 200c         	movs	r0, #0xc
   58488: 4001         	ands	r1, r0
   5848a: 0889         	lsrs	r1, r1, #0x2
   5848c: 1c20         	adds	r0, r4, #0x0
   5848e: 3031         	adds	r0, #0x31
   58490: 7001         	strb	r1, [r0]
   58492: bc08         	pop	{r3}
   58494: 4698         	mov	r8, r3
   58496: bcf0         	pop	{r4, r5, r6, r7}
   58498: bc01         	pop	{r0}
   5849a: 4700         	bx	r0
   5849c: b570         	push	{r4, r5, r6, lr}
   5849e: 1c05         	adds	r5, r0, #0x0
   584a0: 1c0e         	adds	r6, r1, #0x0
   584a2: 8c29         	ldrh	r1, [r5, #0x20]
   584a4: f7ff fe18    	bl	0x580d8 <rom+0x580d8>   @ imm = #-0x3d0
   584a8: 1c04         	adds	r4, r0, #0x0
   584aa: 1c28         	adds	r0, r5, #0x0
   584ac: 1c31         	adds	r1, r6, #0x0
   584ae: f7ff fe13    	bl	0x580d8 <rom+0x580d8>   @ imm = #-0x3da
   584b2: 2222         	movs	r2, #0x22
   584b4: 5ea9         	ldrsh	r1, [r5, r2]
   584b6: 8824         	ldrh	r4, [r4]
   584b8: 1b09         	subs	r1, r1, r4
   584ba: 8840         	ldrh	r0, [r0, #0x2]
   584bc: 4281         	cmp	r1, r0
   584be: da06         	bge	0x584ce <rom+0x584ce>   @ imm = #0xc
   584c0: 040a         	lsls	r2, r1, #0x10
   584c2: 0c12         	lsrs	r2, r2, #0x10
   584c4: 1c28         	adds	r0, r5, #0x0
   584c6: 1c31         	adds	r1, r6, #0x0
   584c8: f7ff ff9a    	bl	0x58400 <rom+0x58400>   @ imm = #-0xcc
   584cc: e003         	b	0x584d6 <rom+0x584d6>   @ imm = #0x6
   584ce: 1c28         	adds	r0, r5, #0x0
   584d0: 1c31         	adds	r1, r6, #0x0
   584d2: f7ff feb7    	bl	0x58244 <rom+0x58244>   @ imm = #-0x292
   584d6: bc70         	pop	{r4, r5, r6}
   584d8: bc01         	pop	{r0}
   584da: 4700         	bx	r0
   584dc: b5f0         	push	{r4, r5, r6, r7, lr}
   584de: 1c04         	adds	r4, r0, #0x0
   584e0: f000 f9bc    	bl	0x5885c <rom+0x5885c>   @ imm = #0x378
   584e4: 1c25         	adds	r5, r4, #0x0
   584e6: 3580         	adds	r5, #0x80
   584e8: 6828         	ldr	r0, [r5]
   584ea: 2800         	cmp	r0, #0x0
   584ec: d00d         	beq	0x5850a <rom+0x5850a>   @ imm = #0x1a
   584ee: 1c20         	adds	r0, r4, #0x0
   584f0: 3084         	adds	r0, #0x84
   584f2: 6800         	ldr	r0, [r0]
   584f4: 2800         	cmp	r0, #0x0
   584f6: db02         	blt	0x584fe <rom+0x584fe>   @ imm = #0x4
   584f8: 1c20         	adds	r0, r4, #0x0
   584fa: f005 f8bb    	bl	0x5d674 <rom+0x5d674>   @ imm = #0x5176
   584fe: 6828         	ldr	r0, [r5]
   58500: 6c22         	ldr	r2, [r4, #0x40]
   58502: 6c63         	ldr	r3, [r4, #0x44]
   58504: 6ca7         	ldr	r7, [r4, #0x48]
   58506: 2800         	cmp	r0, #0x0
   58508: d112         	bne	0x58530 <rom+0x58530>   @ imm = #0x24
   5850a: 1c20         	adds	r0, r4, #0x0
   5850c: 3084         	adds	r0, #0x84
   5850e: 6801         	ldr	r1, [r0]
   58510: 2001         	movs	r0, #0x1
   58512: 4240         	rsbs	r0, r0, #0
   58514: 6c22         	ldr	r2, [r4, #0x40]
   58516: 6c63         	ldr	r3, [r4, #0x44]
   58518: 6ca7         	ldr	r7, [r4, #0x48]
   5851a: 4281         	cmp	r1, r0
   5851c: d108         	bne	0x58530 <rom+0x58530>   @ imm = #0x10
   5851e: 6860         	ldr	r0, [r4, #0x4]
   58520: 1880         	adds	r0, r0, r2
   58522: 6060         	str	r0, [r4, #0x4]
   58524: 68a0         	ldr	r0, [r4, #0x8]
   58526: 18c0         	adds	r0, r0, r3
   58528: 60a0         	str	r0, [r4, #0x8]
   5852a: 68e0         	ldr	r0, [r4, #0xc]
   5852c: 19c0         	adds	r0, r0, r7
   5852e: 60e0         	str	r0, [r4, #0xc]
   58530: 6ce0         	ldr	r0, [r4, #0x4c]
   58532: 1816         	adds	r6, r2, r0
   58534: 6426         	str	r6, [r4, #0x40]
   58536: 6d20         	ldr	r0, [r4, #0x50]
   58538: 181d         	adds	r5, r3, r0
   5853a: 6465         	str	r5, [r4, #0x44]
   5853c: 6d60         	ldr	r0, [r4, #0x54]
   5853e: 183b         	adds	r3, r7, r0
   58540: 64a3         	str	r3, [r4, #0x48]
   58542: 6ea2         	ldr	r2, [r4, #0x68]
   58544: 2a00         	cmp	r2, #0x0
   58546: d031         	beq	0x585ac <rom+0x585ac>   @ imm = #0x62
   58548: 1c31         	adds	r1, r6, #0x0
   5854a: 4351         	muls	r1, r2, r1
   5854c: 1209         	asrs	r1, r1, #0x8
   5854e: 1c28         	adds	r0, r5, #0x0
   58550: 4350         	muls	r0, r2, r0
   58552: 1207         	asrs	r7, r0, #0x8
   58554: 1c18         	adds	r0, r3, #0x0
   58556: 4350         	muls	r0, r2, r0
   58558: 1200         	asrs	r0, r0, #0x8
   5855a: 4684         	mov	r12, r0
   5855c: 1a72         	subs	r2, r6, r1
   5855e: 6422         	str	r2, [r4, #0x40]
   58560: 1be8         	subs	r0, r5, r7
   58562: 6460         	str	r0, [r4, #0x44]
   58564: 4665         	mov	r5, r12
   58566: 1b58         	subs	r0, r3, r5
   58568: 64a0         	str	r0, [r4, #0x48]
   5856a: 2900         	cmp	r1, #0x0
   5856c: d107         	bne	0x5857e <rom+0x5857e>   @ imm = #0xe
   5856e: 2a00         	cmp	r2, #0x0
   58570: d005         	beq	0x5857e <rom+0x5857e>   @ imm = #0xa
   58572: 2a00         	cmp	r2, #0x0
   58574: dd01         	ble	0x5857a <rom+0x5857a>   @ imm = #0x2
   58576: 1e50         	subs	r0, r2, #0x1
   58578: e000         	b	0x5857c <rom+0x5857c>   @ imm = #0x0
   5857a: 1c50         	adds	r0, r2, #0x1
   5857c: 6420         	str	r0, [r4, #0x40]
   5857e: 2f00         	cmp	r7, #0x0
   58580: d108         	bne	0x58594 <rom+0x58594>   @ imm = #0x10
   58582: 6c60         	ldr	r0, [r4, #0x44]
   58584: 2800         	cmp	r0, #0x0
   58586: d005         	beq	0x58594 <rom+0x58594>   @ imm = #0xa
   58588: 2800         	cmp	r0, #0x0
   5858a: dd01         	ble	0x58590 <rom+0x58590>   @ imm = #0x2
   5858c: 3801         	subs	r0, #0x1
   5858e: e000         	b	0x58592 <rom+0x58592>   @ imm = #0x0
   58590: 3001         	adds	r0, #0x1
   58592: 6460         	str	r0, [r4, #0x44]
   58594: 4660         	mov	r0, r12
   58596: 2800         	cmp	r0, #0x0
   58598: d108         	bne	0x585ac <rom+0x585ac>   @ imm = #0x10
   5859a: 6ca0         	ldr	r0, [r4, #0x48]
   5859c: 2800         	cmp	r0, #0x0
   5859e: d005         	beq	0x585ac <rom+0x585ac>   @ imm = #0xa
   585a0: 2800         	cmp	r0, #0x0
   585a2: dd01         	ble	0x585a8 <rom+0x585a8>   @ imm = #0x2
   585a4: 3801         	subs	r0, #0x1
   585a6: e000         	b	0x585aa <rom+0x585aa>   @ imm = #0x0
   585a8: 3001         	adds	r0, #0x1
   585aa: 64a0         	str	r0, [r4, #0x48]
   585ac: 6f22         	ldr	r2, [r4, #0x70]
   585ae: 2a00         	cmp	r2, #0x0
   585b0: dd09         	ble	0x585c6 <rom+0x585c6>   @ imm = #0x12
   585b2: 480d         	ldr	r0, [pc, #0x34]         @ 0x585e8 <rom+0x585e8>
   585b4: 6801         	ldr	r1, [r0]
   585b6: 6840         	ldr	r0, [r0, #0x4]
   585b8: 1a09         	subs	r1, r1, r0
   585ba: 1a51         	subs	r1, r2, r1
   585bc: 6721         	str	r1, [r4, #0x70]
   585be: 2900         	cmp	r1, #0x0
   585c0: da01         	bge	0x585c6 <rom+0x585c6>   @ imm = #0x2
   585c2: 2000         	movs	r0, #0x0
   585c4: 6720         	str	r0, [r4, #0x70]
   585c6: 6ee0         	ldr	r0, [r4, #0x6c]
   585c8: 2800         	cmp	r0, #0x0
   585ca: d109         	bne	0x585e0 <rom+0x585e0>   @ imm = #0x12
   585cc: 1c21         	adds	r1, r4, #0x0
   585ce: 3198         	adds	r1, #0x98
   585d0: 2001         	movs	r0, #0x1
   585d2: 7809         	ldrb	r1, [r1]
   585d4: 4008         	ands	r0, r1
   585d6: 2800         	cmp	r0, #0x0
   585d8: d102         	bne	0x585e0 <rom+0x585e0>   @ imm = #0x4
   585da: 1c20         	adds	r0, r4, #0x0
   585dc: f000 f83e    	bl	0x5865c <rom+0x5865c>   @ imm = #0x7c
   585e0: bcf0         	pop	{r4, r5, r6, r7}
   585e2: bc01         	pop	{r0}
   585e4: 4700         	bx	r0
   585e6: 0000         	movs	r0, r0
   585e8: 0e30         	lsrs	r0, r6, #0x18
   585ea: 0300         	lsls	r0, r0, #0xc
   585ec: 1c03         	adds	r3, r0, #0x0
   585ee: 0609         	lsls	r1, r1, #0x18
   585f0: 0e09         	lsrs	r1, r1, #0x18
   585f2: 1c1a         	adds	r2, r3, #0x0
   585f4: 3298         	adds	r2, #0x98
   585f6: 7810         	ldrb	r0, [r2]
   585f8: 4281         	cmp	r1, r0
   585fa: d002         	beq	0x58602 <rom+0x58602>   @ imm = #0x4
   585fc: 4802         	ldr	r0, [pc, #0x8]          @ 0x58608 <rom+0x58608>
   585fe: 6800         	ldr	r0, [r0]
   58600: 6598         	str	r0, [r3, #0x58]
   58602: 7011         	strb	r1, [r2]
   58604: 4770         	bx	lr
   58606: 0000         	movs	r0, r0
   58608: 0e30         	lsrs	r0, r6, #0x18
   5860a: 0300         	lsls	r0, r0, #0xc
   5860c: 308c         	adds	r0, #0x8c
   5860e: 7001         	strb	r1, [r0]
   58610: 4770         	bx	lr
   58612: 0000         	movs	r0, r0
   58614: 308d         	adds	r0, #0x8d
   58616: 7001         	strb	r1, [r0]
   58618: 4770         	bx	lr
   5861a: 0000         	movs	r0, r0
   5861c: b510         	push	{r4, lr}
   5861e: 4684         	mov	r12, r0
   58620: 9c02         	ldr	r4, [sp, #0x8]
   58622: 30a8         	adds	r0, #0xa8
   58624: 8001         	strh	r1, [r0]
   58626: 3002         	adds	r0, #0x2
   58628: 8002         	strh	r2, [r0]
   5862a: 3002         	adds	r0, #0x2
   5862c: 8003         	strh	r3, [r0]
   5862e: 3002         	adds	r0, #0x2
   58630: 8004         	strh	r4, [r0]
   58632: bc10         	pop	{r4}
   58634: bc01         	pop	{r0}
   58636: 4700         	bx	r0
   58638: 4684         	mov	r12, r0
   5863a: 309a         	adds	r0, #0x9a
   5863c: 8001         	strh	r1, [r0]
   5863e: 3002         	adds	r0, #0x2
   58640: 8002         	strh	r2, [r0]
   58642: 3002         	adds	r0, #0x2
   58644: 8003         	strh	r3, [r0]
   58646: 4770         	bx	lr
   58648: 1c03         	adds	r3, r0, #0x0
