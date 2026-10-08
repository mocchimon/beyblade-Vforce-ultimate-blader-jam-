   64fc0: b5f0         	push	{r4, r5, r6, r7, lr}
   64fc2: 9c05         	ldr	r4, [sp, #0x14]
   64fc4: 9d06         	ldr	r5, [sp, #0x18]
   64fc6: 9e07         	ldr	r6, [sp, #0x1c]
   64fc8: 9f08         	ldr	r7, [sp, #0x20]
   64fca: 6004         	str	r4, [r0]
   64fcc: 2400         	movs	r4, #0x0
   64fce: 7105         	strb	r5, [r0, #0x4]
   64fd0: 6146         	str	r6, [r0, #0x14]
   64fd2: 6187         	str	r7, [r0, #0x18]
   64fd4: 6101         	str	r1, [r0, #0x10]
   64fd6: 6082         	str	r2, [r0, #0x8]
   64fd8: 3a01         	subs	r2, #0x1
   64fda: 60c2         	str	r2, [r0, #0xc]
   64fdc: 2110         	movs	r1, #0x10
   64fde: 4249         	rsbs	r1, r1, #0
   64fe0: 7942         	ldrb	r2, [r0, #0x5]
   64fe2: 4011         	ands	r1, r2
   64fe4: 2211         	movs	r2, #0x11
   64fe6: 4252         	rsbs	r2, r2, #0
   64fe8: 4011         	ands	r1, r2
   64fea: 7141         	strb	r1, [r0, #0x5]
   64fec: 6283         	str	r3, [r0, #0x28]
   64fee: 2101         	movs	r1, #0x1
   64ff0: 4249         	rsbs	r1, r1, #0
   64ff2: 62c1         	str	r1, [r0, #0x2c]
   64ff4: 80c4         	strh	r4, [r0, #0x6]
   64ff6: 2180         	movs	r1, #0x80
   64ff8: 0049         	lsls	r1, r1, #0x1
   64ffa: 8481         	strh	r1, [r0, #0x24]
   64ffc: 84c1         	strh	r1, [r0, #0x26]
   64ffe: 6204         	str	r4, [r0, #0x20]
   65000: f000 f854    	bl	0x650ac <rom+0x650ac>   @ imm = #0xa8
   65004: bcf0         	pop	{r4, r5, r6, r7}
   65006: bc01         	pop	{r0}
   65008: 4700         	bx	r0
   6500a: 0000         	movs	r0, r0
   6500c: b5f0         	push	{r4, r5, r6, r7, lr}
   6500e: 4657         	mov	r7, r10
   65010: 464e         	mov	r6, r9
   65012: 4645         	mov	r5, r8
   65014: b4e0         	push	{r5, r6, r7}
   65016: b086         	sub	sp, #0x18
   65018: 4681         	mov	r9, r0
   6501a: 9104         	str	r1, [sp, #0x10]
   6501c: 9205         	str	r2, [sp, #0x14]
   6501e: 9812         	ldr	r0, [sp, #0x48]
   65020: 041b         	lsls	r3, r3, #0x10
   65022: 0c1b         	lsrs	r3, r3, #0x10
   65024: 4698         	mov	r8, r3
   65026: 0600         	lsls	r0, r0, #0x18
   65028: 0e00         	lsrs	r0, r0, #0x18
   6502a: 4682         	mov	r10, r0
   6502c: 4640         	mov	r0, r8
   6502e: f7fd ff77    	bl	0x62f20 <rom+0x62f20>   @ imm = #-0x2112
   65032: 1c07         	adds	r7, r0, #0x0
   65034: 2f00         	cmp	r7, #0x0
   65036: d102         	bne	0x6503e <rom+0x6503e>   @ imm = #0x4
   65038: 481b         	ldr	r0, [pc, #0x6c]         @ 0x650a8 <rom+0x650a8>
   6503a: f7f2 fd91    	bl	0x57b60 <rom+0x57b60>   @ imm = #-0xd4de
   6503e: 2500         	movs	r5, #0x0
   65040: 4545         	cmp	r5, r8
   65042: d216         	bhs	0x65072 <rom+0x65072>   @ imm = #0x2c
   65044: 2600         	movs	r6, #0x0
   65046: 20c4         	movs	r0, #0xc4
   65048: 4368         	muls	r0, r5, r0
   6504a: 68bc         	ldr	r4, [r7, #0x8]
   6504c: 1824         	adds	r4, r4, r0
   6504e: 9600         	str	r6, [sp]
   65050: 9601         	str	r6, [sp, #0x4]
   65052: 9602         	str	r6, [sp, #0x8]
   65054: 1c20         	adds	r0, r4, #0x0
   65056: 990e         	ldr	r1, [sp, #0x38]
   65058: 2200         	movs	r2, #0x0
   6505a: 2300         	movs	r3, #0x0
   6505c: f7f2 fe0e    	bl	0x57c7c <rom+0x57c7c>   @ imm = #-0xd3e4
   65060: 1c20         	adds	r0, r4, #0x0
   65062: 2101         	movs	r1, #0x1
   65064: f7f3 fac2    	bl	0x585ec <rom+0x585ec>   @ imm = #-0xca7c
   65068: 1c68         	adds	r0, r5, #0x1
   6506a: 0400         	lsls	r0, r0, #0x10
   6506c: 0c05         	lsrs	r5, r0, #0x10
   6506e: 4545         	cmp	r5, r8
   65070: d3e9         	blo	0x65046 <rom+0x65046>   @ imm = #-0x2e
   65072: 68b8         	ldr	r0, [r7, #0x8]
   65074: 9000         	str	r0, [sp]
   65076: 7938         	ldrb	r0, [r7, #0x4]
   65078: 9001         	str	r0, [sp, #0x4]
   6507a: 9810         	ldr	r0, [sp, #0x40]
   6507c: 9002         	str	r0, [sp, #0x8]
   6507e: 9811         	ldr	r0, [sp, #0x44]
   65080: 9003         	str	r0, [sp, #0xc]
   65082: 4648         	mov	r0, r9
   65084: 9904         	ldr	r1, [sp, #0x10]
   65086: 9a05         	ldr	r2, [sp, #0x14]
   65088: 9b0f         	ldr	r3, [sp, #0x3c]
   6508a: f7ff ff99    	bl	0x64fc0 <rom+0x64fc0>   @ imm = #-0xce
   6508e: 4651         	mov	r1, r10
   65090: 4648         	mov	r0, r9
   65092: 80c1         	strh	r1, [r0, #0x6]
   65094: 1c38         	adds	r0, r7, #0x0
   65096: b006         	add	sp, #0x18
   65098: bc38         	pop	{r3, r4, r5}
   6509a: 4698         	mov	r8, r3
   6509c: 46a1         	mov	r9, r4
   6509e: 46aa         	mov	r10, r5
   650a0: bcf0         	pop	{r4, r5, r6, r7}
   650a2: bc02         	pop	{r1}
   650a4: 4708         	bx	r1
   650a6: 0000         	movs	r0, r0
   650a8: 6868         	ldr	r0, [r5, #0x4]
   650aa: 0875         	lsrs	r5, r6, #0x1
   650ac: b570         	push	{r4, r5, r6, lr}
   650ae: 1c02         	adds	r2, r0, #0x0
   650b0: 6955         	ldr	r5, [r2, #0x14]
   650b2: 2400         	movs	r4, #0x0
   650b4: 7910         	ldrb	r0, [r2, #0x4]
   650b6: 4284         	cmp	r4, r0
   650b8: d21c         	bhs	0x650f4 <rom+0x650f4>   @ imm = #0x38
   650ba: 2300         	movs	r3, #0x0
   650bc: 2680         	movs	r6, #0x80
   650be: 0076         	lsls	r6, r6, #0x1
   650c0: 20c4         	movs	r0, #0xc4
   650c2: 4360         	muls	r0, r4, r0
   650c4: 6811         	ldr	r1, [r2]
   650c6: 1809         	adds	r1, r1, r0
   650c8: 0228         	lsls	r0, r5, #0x8
   650ca: 6048         	str	r0, [r1, #0x4]
   650cc: 6990         	ldr	r0, [r2, #0x18]
   650ce: 0200         	lsls	r0, r0, #0x8
   650d0: 6088         	str	r0, [r1, #0x8]
   650d2: 82cb         	strh	r3, [r1, #0x16]
   650d4: 824e         	strh	r6, [r1, #0x12]
   650d6: 828e         	strh	r6, [r1, #0x14]
   650d8: 640b         	str	r3, [r1, #0x40]
   650da: 644b         	str	r3, [r1, #0x44]
   650dc: 648b         	str	r3, [r1, #0x48]
   650de: 64cb         	str	r3, [r1, #0x4c]
   650e0: 650b         	str	r3, [r1, #0x50]
   650e2: 654b         	str	r3, [r1, #0x54]
   650e4: 7c09         	ldrb	r1, [r1, #0x10]
   650e6: 194d         	adds	r5, r1, r5
   650e8: 1c60         	adds	r0, r4, #0x1
   650ea: 0400         	lsls	r0, r0, #0x10
   650ec: 0c04         	lsrs	r4, r0, #0x10
   650ee: 7910         	ldrb	r0, [r2, #0x4]
   650f0: 4284         	cmp	r4, r0
   650f2: d3e5         	blo	0x650c0 <rom+0x650c0>   @ imm = #-0x36
   650f4: 2080         	movs	r0, #0x80
   650f6: 0040         	lsls	r0, r0, #0x1
   650f8: 8490         	strh	r0, [r2, #0x24]
   650fa: 84d0         	strh	r0, [r2, #0x26]
   650fc: bc70         	pop	{r4, r5, r6}
   650fe: bc01         	pop	{r0}
   65100: 4700         	bx	r0
   65102: 0000         	movs	r0, r0
   65104: 1c02         	adds	r2, r0, #0x0
   65106: 6ad0         	ldr	r0, [r2, #0x2c]
   65108: 2800         	cmp	r0, #0x0
   6510a: d104         	bne	0x65116 <rom+0x65116>   @ imm = #0x8
   6510c: 2900         	cmp	r1, #0x0
   6510e: d002         	beq	0x65116 <rom+0x65116>   @ imm = #0x4
   65110: 6890         	ldr	r0, [r2, #0x8]
   65112: 3801         	subs	r0, #0x1
   65114: 60d0         	str	r0, [r2, #0xc]
   65116: 62d1         	str	r1, [r2, #0x2c]
   65118: 4770         	bx	lr
   6511a: 0000         	movs	r0, r0
   6511c: 6101         	str	r1, [r0, #0x10]
   6511e: 4770         	bx	lr
   65120: 2200         	movs	r2, #0x0
   65122: 6102         	str	r2, [r0, #0x10]
   65124: 6882         	ldr	r2, [r0, #0x8]
   65126: 60c2         	str	r2, [r0, #0xc]
   65128: 6081         	str	r1, [r0, #0x8]
   6512a: 4770         	bx	lr
   6512c: b530         	push	{r4, r5, lr}
   6512e: 2300         	movs	r3, #0x0
   65130: 2100         	movs	r1, #0x0
   65132: 7902         	ldrb	r2, [r0, #0x4]
   65134: 4293         	cmp	r3, r2
   65136: d20f         	bhs	0x65158 <rom+0x65158>   @ imm = #0x1e
   65138: 25c4         	movs	r5, #0xc4
   6513a: 6804         	ldr	r4, [r0]
   6513c: 1c08         	adds	r0, r1, #0x0
   6513e: 4368         	muls	r0, r5, r0
   65140: 1820         	adds	r0, r4, r0
   65142: 6f00         	ldr	r0, [r0, #0x70]
   65144: 2800         	cmp	r0, #0x0
   65146: d002         	beq	0x6514e <rom+0x6514e>   @ imm = #0x4
   65148: 1c58         	adds	r0, r3, #0x1
   6514a: 0400         	lsls	r0, r0, #0x10
   6514c: 0c03         	lsrs	r3, r0, #0x10
   6514e: 1c48         	adds	r0, r1, #0x1
   65150: 0400         	lsls	r0, r0, #0x10
   65152: 0c01         	lsrs	r1, r0, #0x10
   65154: 4291         	cmp	r1, r2
   65156: d3f1         	blo	0x6513c <rom+0x6513c>   @ imm = #-0x1e
   65158: 0618         	lsls	r0, r3, #0x18
   6515a: 0e00         	lsrs	r0, r0, #0x18
   6515c: bc30         	pop	{r4, r5}
   6515e: bc02         	pop	{r1}
   65160: 4708         	bx	r1
   65162: 0000         	movs	r0, r0
   65164: b5f0         	push	{r4, r5, r6, r7, lr}
   65166: 4657         	mov	r7, r10
   65168: 464e         	mov	r6, r9
   6516a: 4645         	mov	r5, r8
   6516c: b4e0         	push	{r5, r6, r7}
   6516e: b082         	sub	sp, #0x8
   65170: 1c05         	adds	r5, r0, #0x0
   65172: 8ca8         	ldrh	r0, [r5, #0x24]
   65174: 4681         	mov	r9, r0
   65176: 8ce9         	ldrh	r1, [r5, #0x26]
   65178: 9101         	str	r1, [sp, #0x4]
   6517a: 2200         	movs	r2, #0x0
   6517c: 4690         	mov	r8, r2
   6517e: 6aea         	ldr	r2, [r5, #0x2c]
   65180: 2a00         	cmp	r2, #0x0
   65182: dd09         	ble	0x65198 <rom+0x65198>   @ imm = #0x12
   65184: 480c         	ldr	r0, [pc, #0x30]         @ 0x651b8 <rom+0x651b8>
   65186: 6801         	ldr	r1, [r0]
   65188: 6840         	ldr	r0, [r0, #0x4]
   6518a: 1a09         	subs	r1, r1, r0
   6518c: 1a51         	subs	r1, r2, r1
   6518e: 62e9         	str	r1, [r5, #0x2c]
   65190: 2900         	cmp	r1, #0x0
   65192: da01         	bge	0x65198 <rom+0x65198>   @ imm = #0x2
   65194: 4640         	mov	r0, r8
   65196: 62e8         	str	r0, [r5, #0x2c]
   65198: 6928         	ldr	r0, [r5, #0x10]
   6519a: 2800         	cmp	r0, #0x0
   6519c: d112         	bne	0x651c4 <rom+0x651c4>   @ imm = #0x24
   6519e: 68a9         	ldr	r1, [r5, #0x8]
   651a0: 68e8         	ldr	r0, [r5, #0xc]
   651a2: 4281         	cmp	r1, r0
   651a4: d02b         	beq	0x651fe <rom+0x651fe>   @ imm = #0x56
   651a6: 2008         	movs	r0, #0x8
   651a8: 88e9         	ldrh	r1, [r5, #0x6]
   651aa: 4008         	ands	r0, r1
   651ac: 2800         	cmp	r0, #0x0
   651ae: d005         	beq	0x651bc <rom+0x651bc>   @ imm = #0xa
   651b0: 1c28         	adds	r0, r5, #0x0
   651b2: f000 f9bb    	bl	0x6552c <rom+0x6552c>   @ imm = #0x376
   651b6: e022         	b	0x651fe <rom+0x651fe>   @ imm = #0x44
   651b8: 0e30         	lsrs	r0, r6, #0x18
   651ba: 0300         	lsls	r0, r0, #0xc
   651bc: 1c28         	adds	r0, r5, #0x0
   651be: f000 f91d    	bl	0x653fc <rom+0x653fc>   @ imm = #0x23a
   651c2: e01c         	b	0x651fe <rom+0x651fe>   @ imm = #0x38
   651c4: 2004         	movs	r0, #0x4
   651c6: 88ea         	ldrh	r2, [r5, #0x6]
   651c8: 4010         	ands	r0, r2
   651ca: 2800         	cmp	r0, #0x0
   651cc: d014         	beq	0x651f8 <rom+0x651f8>   @ imm = #0x28
   651ce: 1c28         	adds	r0, r5, #0x0
   651d0: f000 fa84    	bl	0x656dc <rom+0x656dc>   @ imm = #0x508
   651d4: 1c28         	adds	r0, r5, #0x0
   651d6: f7ff ffa9    	bl	0x6512c <rom+0x6512c>   @ imm = #-0xae
   651da: 0600         	lsls	r0, r0, #0x18
   651dc: 0e00         	lsrs	r0, r0, #0x18
   651de: 7929         	ldrb	r1, [r5, #0x4]
   651e0: 4288         	cmp	r0, r1
   651e2: d20c         	bhs	0x651fe <rom+0x651fe>   @ imm = #0x18
   651e4: 68a9         	ldr	r1, [r5, #0x8]
   651e6: 792b         	ldrb	r3, [r5, #0x4]
   651e8: 1e5a         	subs	r2, r3, #0x1
   651ea: 1a1b         	subs	r3, r3, r0
   651ec: 2000         	movs	r0, #0x0
   651ee: 9000         	str	r0, [sp]
   651f0: 1c28         	adds	r0, r5, #0x0
   651f2: f000 f9f7    	bl	0x655e4 <rom+0x655e4>   @ imm = #0x3ee
   651f6: e002         	b	0x651fe <rom+0x651fe>   @ imm = #0x4
   651f8: 1c28         	adds	r0, r5, #0x0
   651fa: f000 fa6f    	bl	0x656dc <rom+0x656dc>   @ imm = #0x4de
   651fe: 68a8         	ldr	r0, [r5, #0x8]
   65200: 60e8         	str	r0, [r5, #0xc]
   65202: 2003         	movs	r0, #0x3
   65204: 88ea         	ldrh	r2, [r5, #0x6]
   65206: 4010         	ands	r0, r2
   65208: 2801         	cmp	r0, #0x1
   6520a: d00a         	beq	0x65222 <rom+0x65222>   @ imm = #0x14
   6520c: 2801         	cmp	r0, #0x1
   6520e: dc02         	bgt	0x65216 <rom+0x65216>   @ imm = #0x4
   65210: 2800         	cmp	r0, #0x0
   65212: d003         	beq	0x6521c <rom+0x6521c>   @ imm = #0x6
   65214: e019         	b	0x6524a <rom+0x6524a>   @ imm = #0x32
   65216: 2802         	cmp	r0, #0x2
   65218: d00f         	beq	0x6523a <rom+0x6523a>   @ imm = #0x1e
   6521a: e016         	b	0x6524a <rom+0x6524a>   @ imm = #0x2c
   6521c: 6968         	ldr	r0, [r5, #0x14]
   6521e: 0206         	lsls	r6, r0, #0x8
   65220: e013         	b	0x6524a <rom+0x6524a>   @ imm = #0x26
   65222: 8cac         	ldrh	r4, [r5, #0x24]
   65224: 2080         	movs	r0, #0x80
   65226: 0040         	lsls	r0, r0, #0x1
   65228: 84a8         	strh	r0, [r5, #0x24]
   6522a: 1c28         	adds	r0, r5, #0x0
   6522c: f000 f894    	bl	0x65358 <rom+0x65358>   @ imm = #0x128
   65230: 6969         	ldr	r1, [r5, #0x14]
   65232: 1a09         	subs	r1, r1, r0
   65234: 020e         	lsls	r6, r1, #0x8
   65236: 84ac         	strh	r4, [r5, #0x24]
   65238: e007         	b	0x6524a <rom+0x6524a>   @ imm = #0xe
   6523a: 1c28         	adds	r0, r5, #0x0
   6523c: f000 f88c    	bl	0x65358 <rom+0x65358>   @ imm = #0x118
   65240: 6228         	str	r0, [r5, #0x20]
   65242: 1040         	asrs	r0, r0, #0x1
   65244: 6969         	ldr	r1, [r5, #0x14]
   65246: 1a09         	subs	r1, r1, r0
   65248: 020e         	lsls	r6, r1, #0x8
   6524a: 2700         	movs	r7, #0x0
