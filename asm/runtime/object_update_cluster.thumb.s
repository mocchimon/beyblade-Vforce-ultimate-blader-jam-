
/tmp/ubj_current/rom.elf:	file format elf32-littlearm

Disassembly of section .text:

08000000 <.text>:
 8064fc0: b5f0         	push	{r4, r5, r6, r7, lr}
 8064fc2: 9c05         	ldr	r4, [sp, #0x14]
 8064fc4: 9d06         	ldr	r5, [sp, #0x18]
 8064fc6: 9e07         	ldr	r6, [sp, #0x1c]
 8064fc8: 9f08         	ldr	r7, [sp, #0x20]
 8064fca: 6004         	str	r4, [r0]
 8064fcc: 2400         	movs	r4, #0x0
 8064fce: 7105         	strb	r5, [r0, #0x4]
 8064fd0: 6146         	str	r6, [r0, #0x14]
 8064fd2: 6187         	str	r7, [r0, #0x18]
 8064fd4: 6101         	str	r1, [r0, #0x10]
 8064fd6: 6082         	str	r2, [r0, #0x8]
 8064fd8: 3a01         	subs	r2, #0x1
 8064fda: 60c2         	str	r2, [r0, #0xc]
 8064fdc: 2110         	movs	r1, #0x10
 8064fde: 4249         	rsbs	r1, r1, #0
 8064fe0: 7942         	ldrb	r2, [r0, #0x5]
 8064fe2: 4011         	ands	r1, r2
 8064fe4: 2211         	movs	r2, #0x11
 8064fe6: 4252         	rsbs	r2, r2, #0
 8064fe8: 4011         	ands	r1, r2
 8064fea: 7141         	strb	r1, [r0, #0x5]
 8064fec: 6283         	str	r3, [r0, #0x28]
 8064fee: 2101         	movs	r1, #0x1
 8064ff0: 4249         	rsbs	r1, r1, #0
 8064ff2: 62c1         	str	r1, [r0, #0x2c]
 8064ff4: 80c4         	strh	r4, [r0, #0x6]
 8064ff6: 2180         	movs	r1, #0x80
 8064ff8: 0049         	lsls	r1, r1, #0x1
 8064ffa: 8481         	strh	r1, [r0, #0x24]
 8064ffc: 84c1         	strh	r1, [r0, #0x26]
 8064ffe: 6204         	str	r4, [r0, #0x20]
 8065000: f000 f854    	bl	0x80650ac <.text+0x650ac> @ imm = #0xa8
 8065004: bcf0         	pop	{r4, r5, r6, r7}
 8065006: bc01         	pop	{r0}
 8065008: 4700         	bx	r0
 806500a: 0000         	movs	r0, r0
 806500c: b5f0         	push	{r4, r5, r6, r7, lr}
 806500e: 4657         	mov	r7, r10
 8065010: 464e         	mov	r6, r9
 8065012: 4645         	mov	r5, r8
 8065014: b4e0         	push	{r5, r6, r7}
 8065016: b086         	sub	sp, #0x18
 8065018: 4681         	mov	r9, r0
 806501a: 9104         	str	r1, [sp, #0x10]
 806501c: 9205         	str	r2, [sp, #0x14]
 806501e: 9812         	ldr	r0, [sp, #0x48]
 8065020: 041b         	lsls	r3, r3, #0x10
 8065022: 0c1b         	lsrs	r3, r3, #0x10
 8065024: 4698         	mov	r8, r3
 8065026: 0600         	lsls	r0, r0, #0x18
 8065028: 0e00         	lsrs	r0, r0, #0x18
 806502a: 4682         	mov	r10, r0
 806502c: 4640         	mov	r0, r8
 806502e: f7fd ff77    	bl	0x8062f20 <.text+0x62f20> @ imm = #-0x2112
 8065032: 1c07         	adds	r7, r0, #0x0
 8065034: 2f00         	cmp	r7, #0x0
 8065036: d102         	bne	0x806503e <.text+0x6503e> @ imm = #0x4
 8065038: 481b         	ldr	r0, [pc, #0x6c]         @ 0x80650a8 <.text+0x650a8>
 806503a: f7f2 fd91    	bl	0x8057b60 <.text+0x57b60> @ imm = #-0xd4de
 806503e: 2500         	movs	r5, #0x0
 8065040: 4545         	cmp	r5, r8
 8065042: d216         	bhs	0x8065072 <.text+0x65072> @ imm = #0x2c
 8065044: 2600         	movs	r6, #0x0
 8065046: 20c4         	movs	r0, #0xc4
 8065048: 4368         	muls	r0, r5, r0
 806504a: 68bc         	ldr	r4, [r7, #0x8]
 806504c: 1824         	adds	r4, r4, r0
 806504e: 9600         	str	r6, [sp]
 8065050: 9601         	str	r6, [sp, #0x4]
 8065052: 9602         	str	r6, [sp, #0x8]
 8065054: 1c20         	adds	r0, r4, #0x0
 8065056: 990e         	ldr	r1, [sp, #0x38]
 8065058: 2200         	movs	r2, #0x0
 806505a: 2300         	movs	r3, #0x0
 806505c: f7f2 fe0e    	bl	0x8057c7c <.text+0x57c7c> @ imm = #-0xd3e4
 8065060: 1c20         	adds	r0, r4, #0x0
 8065062: 2101         	movs	r1, #0x1
 8065064: f7f3 fac2    	bl	0x80585ec <.text+0x585ec> @ imm = #-0xca7c
 8065068: 1c68         	adds	r0, r5, #0x1
 806506a: 0400         	lsls	r0, r0, #0x10
 806506c: 0c05         	lsrs	r5, r0, #0x10
 806506e: 4545         	cmp	r5, r8
 8065070: d3e9         	blo	0x8065046 <.text+0x65046> @ imm = #-0x2e
 8065072: 68b8         	ldr	r0, [r7, #0x8]
 8065074: 9000         	str	r0, [sp]
 8065076: 7938         	ldrb	r0, [r7, #0x4]
 8065078: 9001         	str	r0, [sp, #0x4]
 806507a: 9810         	ldr	r0, [sp, #0x40]
 806507c: 9002         	str	r0, [sp, #0x8]
 806507e: 9811         	ldr	r0, [sp, #0x44]
 8065080: 9003         	str	r0, [sp, #0xc]
 8065082: 4648         	mov	r0, r9
 8065084: 9904         	ldr	r1, [sp, #0x10]
 8065086: 9a05         	ldr	r2, [sp, #0x14]
 8065088: 9b0f         	ldr	r3, [sp, #0x3c]
 806508a: f7ff ff99    	bl	0x8064fc0 <.text+0x64fc0> @ imm = #-0xce
 806508e: 4651         	mov	r1, r10
 8065090: 4648         	mov	r0, r9
 8065092: 80c1         	strh	r1, [r0, #0x6]
 8065094: 1c38         	adds	r0, r7, #0x0
 8065096: b006         	add	sp, #0x18
 8065098: bc38         	pop	{r3, r4, r5}
 806509a: 4698         	mov	r8, r3
 806509c: 46a1         	mov	r9, r4
 806509e: 46aa         	mov	r10, r5
 80650a0: bcf0         	pop	{r4, r5, r6, r7}
 80650a2: bc02         	pop	{r1}
 80650a4: 4708         	bx	r1
 80650a6: 0000         	movs	r0, r0
 80650a8: 6868         	ldr	r0, [r5, #0x4]
 80650aa: 0875         	lsrs	r5, r6, #0x1
 80650ac: b570         	push	{r4, r5, r6, lr}
 80650ae: 1c02         	adds	r2, r0, #0x0
 80650b0: 6955         	ldr	r5, [r2, #0x14]
 80650b2: 2400         	movs	r4, #0x0
 80650b4: 7910         	ldrb	r0, [r2, #0x4]
 80650b6: 4284         	cmp	r4, r0
 80650b8: d21c         	bhs	0x80650f4 <.text+0x650f4> @ imm = #0x38
 80650ba: 2300         	movs	r3, #0x0
 80650bc: 2680         	movs	r6, #0x80
 80650be: 0076         	lsls	r6, r6, #0x1
 80650c0: 20c4         	movs	r0, #0xc4
 80650c2: 4360         	muls	r0, r4, r0
 80650c4: 6811         	ldr	r1, [r2]
 80650c6: 1809         	adds	r1, r1, r0
 80650c8: 0228         	lsls	r0, r5, #0x8
 80650ca: 6048         	str	r0, [r1, #0x4]
 80650cc: 6990         	ldr	r0, [r2, #0x18]
 80650ce: 0200         	lsls	r0, r0, #0x8
 80650d0: 6088         	str	r0, [r1, #0x8]
 80650d2: 82cb         	strh	r3, [r1, #0x16]
 80650d4: 824e         	strh	r6, [r1, #0x12]
 80650d6: 828e         	strh	r6, [r1, #0x14]
 80650d8: 640b         	str	r3, [r1, #0x40]
 80650da: 644b         	str	r3, [r1, #0x44]
 80650dc: 648b         	str	r3, [r1, #0x48]
 80650de: 64cb         	str	r3, [r1, #0x4c]
 80650e0: 650b         	str	r3, [r1, #0x50]
 80650e2: 654b         	str	r3, [r1, #0x54]
 80650e4: 7c09         	ldrb	r1, [r1, #0x10]
 80650e6: 194d         	adds	r5, r1, r5
 80650e8: 1c60         	adds	r0, r4, #0x1
 80650ea: 0400         	lsls	r0, r0, #0x10
 80650ec: 0c04         	lsrs	r4, r0, #0x10
 80650ee: 7910         	ldrb	r0, [r2, #0x4]
 80650f0: 4284         	cmp	r4, r0
 80650f2: d3e5         	blo	0x80650c0 <.text+0x650c0> @ imm = #-0x36
 80650f4: 2080         	movs	r0, #0x80
 80650f6: 0040         	lsls	r0, r0, #0x1
 80650f8: 8490         	strh	r0, [r2, #0x24]
 80650fa: 84d0         	strh	r0, [r2, #0x26]
 80650fc: bc70         	pop	{r4, r5, r6}
 80650fe: bc01         	pop	{r0}
 8065100: 4700         	bx	r0
 8065102: 0000         	movs	r0, r0
 8065104: 1c02         	adds	r2, r0, #0x0
 8065106: 6ad0         	ldr	r0, [r2, #0x2c]
 8065108: 2800         	cmp	r0, #0x0
 806510a: d104         	bne	0x8065116 <.text+0x65116> @ imm = #0x8
 806510c: 2900         	cmp	r1, #0x0
 806510e: d002         	beq	0x8065116 <.text+0x65116> @ imm = #0x4
 8065110: 6890         	ldr	r0, [r2, #0x8]
 8065112: 3801         	subs	r0, #0x1
 8065114: 60d0         	str	r0, [r2, #0xc]
 8065116: 62d1         	str	r1, [r2, #0x2c]
 8065118: 4770         	bx	lr
 806511a: 0000         	movs	r0, r0
 806511c: 6101         	str	r1, [r0, #0x10]
 806511e: 4770         	bx	lr
 8065120: 2200         	movs	r2, #0x0
 8065122: 6102         	str	r2, [r0, #0x10]
 8065124: 6882         	ldr	r2, [r0, #0x8]
 8065126: 60c2         	str	r2, [r0, #0xc]
 8065128: 6081         	str	r1, [r0, #0x8]
 806512a: 4770         	bx	lr
 806512c: b530         	push	{r4, r5, lr}
 806512e: 2300         	movs	r3, #0x0
 8065130: 2100         	movs	r1, #0x0
 8065132: 7902         	ldrb	r2, [r0, #0x4]
 8065134: 4293         	cmp	r3, r2
 8065136: d20f         	bhs	0x8065158 <.text+0x65158> @ imm = #0x1e
 8065138: 25c4         	movs	r5, #0xc4
 806513a: 6804         	ldr	r4, [r0]
 806513c: 1c08         	adds	r0, r1, #0x0
 806513e: 4368         	muls	r0, r5, r0
 8065140: 1820         	adds	r0, r4, r0
 8065142: 6f00         	ldr	r0, [r0, #0x70]
 8065144: 2800         	cmp	r0, #0x0
 8065146: d002         	beq	0x806514e <.text+0x6514e> @ imm = #0x4
 8065148: 1c58         	adds	r0, r3, #0x1
 806514a: 0400         	lsls	r0, r0, #0x10
 806514c: 0c03         	lsrs	r3, r0, #0x10
 806514e: 1c48         	adds	r0, r1, #0x1
 8065150: 0400         	lsls	r0, r0, #0x10
 8065152: 0c01         	lsrs	r1, r0, #0x10
 8065154: 4291         	cmp	r1, r2
 8065156: d3f1         	blo	0x806513c <.text+0x6513c> @ imm = #-0x1e
 8065158: 0618         	lsls	r0, r3, #0x18
 806515a: 0e00         	lsrs	r0, r0, #0x18
 806515c: bc30         	pop	{r4, r5}
 806515e: bc02         	pop	{r1}
 8065160: 4708         	bx	r1
 8065162: 0000         	movs	r0, r0
 8065164: b5f0         	push	{r4, r5, r6, r7, lr}
 8065166: 4657         	mov	r7, r10
 8065168: 464e         	mov	r6, r9
 806516a: 4645         	mov	r5, r8
 806516c: b4e0         	push	{r5, r6, r7}
 806516e: b082         	sub	sp, #0x8
 8065170: 1c05         	adds	r5, r0, #0x0
 8065172: 8ca8         	ldrh	r0, [r5, #0x24]
 8065174: 4681         	mov	r9, r0
 8065176: 8ce9         	ldrh	r1, [r5, #0x26]
 8065178: 9101         	str	r1, [sp, #0x4]
 806517a: 2200         	movs	r2, #0x0
 806517c: 4690         	mov	r8, r2
 806517e: 6aea         	ldr	r2, [r5, #0x2c]
 8065180: 2a00         	cmp	r2, #0x0
 8065182: dd09         	ble	0x8065198 <.text+0x65198> @ imm = #0x12
 8065184: 480c         	ldr	r0, [pc, #0x30]         @ 0x80651b8 <.text+0x651b8>
 8065186: 6801         	ldr	r1, [r0]
 8065188: 6840         	ldr	r0, [r0, #0x4]
 806518a: 1a09         	subs	r1, r1, r0
 806518c: 1a51         	subs	r1, r2, r1
 806518e: 62e9         	str	r1, [r5, #0x2c]
 8065190: 2900         	cmp	r1, #0x0
 8065192: da01         	bge	0x8065198 <.text+0x65198> @ imm = #0x2
 8065194: 4640         	mov	r0, r8
 8065196: 62e8         	str	r0, [r5, #0x2c]
 8065198: 6928         	ldr	r0, [r5, #0x10]
 806519a: 2800         	cmp	r0, #0x0
 806519c: d112         	bne	0x80651c4 <.text+0x651c4> @ imm = #0x24
 806519e: 68a9         	ldr	r1, [r5, #0x8]
 80651a0: 68e8         	ldr	r0, [r5, #0xc]
 80651a2: 4281         	cmp	r1, r0
 80651a4: d02b         	beq	0x80651fe <.text+0x651fe> @ imm = #0x56
 80651a6: 2008         	movs	r0, #0x8
 80651a8: 88e9         	ldrh	r1, [r5, #0x6]
 80651aa: 4008         	ands	r0, r1
 80651ac: 2800         	cmp	r0, #0x0
 80651ae: d005         	beq	0x80651bc <.text+0x651bc> @ imm = #0xa
 80651b0: 1c28         	adds	r0, r5, #0x0
 80651b2: f000 f9bb    	bl	0x806552c <.text+0x6552c> @ imm = #0x376
 80651b6: e022         	b	0x80651fe <.text+0x651fe> @ imm = #0x44
 80651b8: 0e30         	lsrs	r0, r6, #0x18
 80651ba: 0300         	lsls	r0, r0, #0xc
 80651bc: 1c28         	adds	r0, r5, #0x0
 80651be: f000 f91d    	bl	0x80653fc <.text+0x653fc> @ imm = #0x23a
 80651c2: e01c         	b	0x80651fe <.text+0x651fe> @ imm = #0x38
 80651c4: 2004         	movs	r0, #0x4
 80651c6: 88ea         	ldrh	r2, [r5, #0x6]
 80651c8: 4010         	ands	r0, r2
 80651ca: 2800         	cmp	r0, #0x0
 80651cc: d014         	beq	0x80651f8 <.text+0x651f8> @ imm = #0x28
 80651ce: 1c28         	adds	r0, r5, #0x0
 80651d0: f000 fa84    	bl	0x80656dc <.text+0x656dc> @ imm = #0x508
 80651d4: 1c28         	adds	r0, r5, #0x0
 80651d6: f7ff ffa9    	bl	0x806512c <.text+0x6512c> @ imm = #-0xae
 80651da: 0600         	lsls	r0, r0, #0x18
 80651dc: 0e00         	lsrs	r0, r0, #0x18
 80651de: 7929         	ldrb	r1, [r5, #0x4]
 80651e0: 4288         	cmp	r0, r1
 80651e2: d20c         	bhs	0x80651fe <.text+0x651fe> @ imm = #0x18
 80651e4: 68a9         	ldr	r1, [r5, #0x8]
 80651e6: 792b         	ldrb	r3, [r5, #0x4]
 80651e8: 1e5a         	subs	r2, r3, #0x1
 80651ea: 1a1b         	subs	r3, r3, r0
 80651ec: 2000         	movs	r0, #0x0
 80651ee: 9000         	str	r0, [sp]
 80651f0: 1c28         	adds	r0, r5, #0x0
 80651f2: f000 f9f7    	bl	0x80655e4 <.text+0x655e4> @ imm = #0x3ee
 80651f6: e002         	b	0x80651fe <.text+0x651fe> @ imm = #0x4
 80651f8: 1c28         	adds	r0, r5, #0x0
 80651fa: f000 fa6f    	bl	0x80656dc <.text+0x656dc> @ imm = #0x4de
 80651fe: 68a8         	ldr	r0, [r5, #0x8]
 8065200: 60e8         	str	r0, [r5, #0xc]
 8065202: 2003         	movs	r0, #0x3
 8065204: 88ea         	ldrh	r2, [r5, #0x6]
 8065206: 4010         	ands	r0, r2
 8065208: 2801         	cmp	r0, #0x1
 806520a: d00a         	beq	0x8065222 <.text+0x65222> @ imm = #0x14
 806520c: 2801         	cmp	r0, #0x1
 806520e: dc02         	bgt	0x8065216 <.text+0x65216> @ imm = #0x4
 8065210: 2800         	cmp	r0, #0x0
 8065212: d003         	beq	0x806521c <.text+0x6521c> @ imm = #0x6
 8065214: e019         	b	0x806524a <.text+0x6524a> @ imm = #0x32
 8065216: 2802         	cmp	r0, #0x2
 8065218: d00f         	beq	0x806523a <.text+0x6523a> @ imm = #0x1e
 806521a: e016         	b	0x806524a <.text+0x6524a> @ imm = #0x2c
 806521c: 6968         	ldr	r0, [r5, #0x14]
 806521e: 0206         	lsls	r6, r0, #0x8
 8065220: e013         	b	0x806524a <.text+0x6524a> @ imm = #0x26
 8065222: 8cac         	ldrh	r4, [r5, #0x24]
 8065224: 2080         	movs	r0, #0x80
 8065226: 0040         	lsls	r0, r0, #0x1
 8065228: 84a8         	strh	r0, [r5, #0x24]
 806522a: 1c28         	adds	r0, r5, #0x0
 806522c: f000 f894    	bl	0x8065358 <.text+0x65358> @ imm = #0x128
 8065230: 6969         	ldr	r1, [r5, #0x14]
 8065232: 1a09         	subs	r1, r1, r0
 8065234: 020e         	lsls	r6, r1, #0x8
 8065236: 84ac         	strh	r4, [r5, #0x24]
 8065238: e007         	b	0x806524a <.text+0x6524a> @ imm = #0xe
 806523a: 1c28         	adds	r0, r5, #0x0
 806523c: f000 f88c    	bl	0x8065358 <.text+0x65358> @ imm = #0x118
 8065240: 6228         	str	r0, [r5, #0x20]
 8065242: 1040         	asrs	r0, r0, #0x1
 8065244: 6969         	ldr	r1, [r5, #0x14]
 8065246: 1a09         	subs	r1, r1, r0
 8065248: 020e         	lsls	r6, r1, #0x8
 806524a: 2700         	movs	r7, #0x0
 806524c: 7928         	ldrb	r0, [r5, #0x4]
 806524e: 4287         	cmp	r7, r0
 8065250: d266         	bhs	0x8065320 <.text+0x65320> @ imm = #0xcc
 8065252: 2180         	movs	r1, #0x80
 8065254: 0049         	lsls	r1, r1, #0x1
 8065256: 468a         	mov	r10, r1
 8065258: 6929         	ldr	r1, [r5, #0x10]
 806525a: 2900         	cmp	r1, #0x0
 806525c: d00d         	beq	0x806527a <.text+0x6527a> @ imm = #0x1a
 806525e: 4642         	mov	r2, r8
 8065260: 18b8         	adds	r0, r7, r2
 8065262: 1808         	adds	r0, r1, r0
 8065264: 7800         	ldrb	r0, [r0]
 8065266: 2820         	cmp	r0, #0x20
 8065268: d107         	bne	0x806527a <.text+0x6527a> @ imm = #0xe
 806526a: 20a0         	movs	r0, #0xa0
 806526c: 00c0         	lsls	r0, r0, #0x3
 806526e: 1836         	adds	r6, r6, r0
 8065270: 4640         	mov	r0, r8
 8065272: 3001         	adds	r0, #0x1
 8065274: 0600         	lsls	r0, r0, #0x18
 8065276: 0e00         	lsrs	r0, r0, #0x18
 8065278: 4680         	mov	r8, r0
 806527a: 20c4         	movs	r0, #0xc4
 806527c: 1c39         	adds	r1, r7, #0x0
 806527e: 4341         	muls	r1, r0, r1
 8065280: 6828         	ldr	r0, [r5]
 8065282: 1844         	adds	r4, r0, r1
 8065284: 2310         	movs	r3, #0x10
 8065286: 1c18         	adds	r0, r3, #0x0
 8065288: 7969         	ldrb	r1, [r5, #0x5]
 806528a: 4008         	ands	r0, r1
 806528c: 2800         	cmp	r0, #0x0
 806528e: d00a         	beq	0x80652a6 <.text+0x652a6> @ imm = #0x14
 8065290: 1c22         	adds	r2, r4, #0x0
 8065292: 323a         	adds	r2, #0x3a
 8065294: 21e1         	movs	r1, #0xe1
 8065296: 7810         	ldrb	r0, [r2]
 8065298: 4001         	ands	r1, r0
 806529a: 7011         	strb	r1, [r2]
 806529c: 7968         	ldrb	r0, [r5, #0x5]
 806529e: 0700         	lsls	r0, r0, #0x1c
 80652a0: 0ec0         	lsrs	r0, r0, #0x1b
 80652a2: 4301         	orrs	r1, r0
 80652a4: 7011         	strb	r1, [r2]
 80652a6: 2020         	movs	r0, #0x20
 80652a8: 88e9         	ldrh	r1, [r5, #0x6]
 80652aa: 4008         	ands	r0, r1
 80652ac: 2800         	cmp	r0, #0x0
 80652ae: d100         	bne	0x80652b2 <.text+0x652b2> @ imm = #0x0
 80652b0: 6066         	str	r6, [r4, #0x4]
 80652b2: 1c18         	adds	r0, r3, #0x0
 80652b4: 88ea         	ldrh	r2, [r5, #0x6]
 80652b6: 4010         	ands	r0, r2
 80652b8: 2800         	cmp	r0, #0x0
 80652ba: d002         	beq	0x80652c2 <.text+0x652c2> @ imm = #0x4
 80652bc: 69a8         	ldr	r0, [r5, #0x18]
 80652be: 0200         	lsls	r0, r0, #0x8
 80652c0: 60a0         	str	r0, [r4, #0x8]
 80652c2: 2040         	movs	r0, #0x40
 80652c4: 88e9         	ldrh	r1, [r5, #0x6]
 80652c6: 4008         	ands	r0, r1
 80652c8: 2800         	cmp	r0, #0x0
 80652ca: d104         	bne	0x80652d6 <.text+0x652d6> @ imm = #0x8
 80652cc: 464a         	mov	r2, r9
 80652ce: 8262         	strh	r2, [r4, #0x12]
 80652d0: 4668         	mov	r0, sp
 80652d2: 8880         	ldrh	r0, [r0, #0x4]
 80652d4: 82a0         	strh	r0, [r4, #0x14]
 80652d6: 6ae8         	ldr	r0, [r5, #0x2c]
 80652d8: 2800         	cmp	r0, #0x0
 80652da: d100         	bne	0x80652de <.text+0x652de> @ imm = #0x0
 80652dc: 6720         	str	r0, [r4, #0x70]
 80652de: 1c20         	adds	r0, r4, #0x0
 80652e0: f7f3 f8fc    	bl	0x80584dc <.text+0x584dc> @ imm = #-0xce08
 80652e4: 6f20         	ldr	r0, [r4, #0x70]
 80652e6: 2800         	cmp	r0, #0x0
 80652e8: d014         	beq	0x8065314 <.text+0x65314> @ imm = #0x28
 80652ea: 6aa9         	ldr	r1, [r5, #0x28]
 80652ec: 2900         	cmp	r1, #0x0
 80652ee: d00e         	beq	0x806530e <.text+0x6530e> @ imm = #0x1c
 80652f0: 2222         	movs	r2, #0x22
 80652f2: 5ea0         	ldrsh	r0, [r4, r2]
 80652f4: 1808         	adds	r0, r1, r0
 80652f6: 7c24         	ldrb	r4, [r4, #0x10]
 80652f8: 7800         	ldrb	r0, [r0]
 80652fa: 1a20         	subs	r0, r4, r0
 80652fc: 0201         	lsls	r1, r0, #0x8
 80652fe: 464a         	mov	r2, r9
 8065300: 0410         	lsls	r0, r2, #0x10
 8065302: 1400         	asrs	r0, r0, #0x10
 8065304: 4550         	cmp	r0, r10
 8065306: d004         	beq	0x8065312 <.text+0x65312> @ imm = #0x8
 8065308: 4348         	muls	r0, r1, r0
 806530a: 1201         	asrs	r1, r0, #0x8
 806530c: e001         	b	0x8065312 <.text+0x65312> @ imm = #0x2
 806530e: 7c24         	ldrb	r4, [r4, #0x10]
 8065310: 0221         	lsls	r1, r4, #0x8
 8065312: 1876         	adds	r6, r6, r1
 8065314: 1c78         	adds	r0, r7, #0x1
 8065316: 0400         	lsls	r0, r0, #0x10
 8065318: 0c07         	lsrs	r7, r0, #0x10
 806531a: 7928         	ldrb	r0, [r5, #0x4]
 806531c: 4287         	cmp	r7, r0
 806531e: d39b         	blo	0x8065258 <.text+0x65258> @ imm = #-0xca
 8065320: b002         	add	sp, #0x8
 8065322: bc38         	pop	{r3, r4, r5}
 8065324: 4698         	mov	r8, r3
 8065326: 46a1         	mov	r9, r4
 8065328: 46aa         	mov	r10, r5
 806532a: bcf0         	pop	{r4, r5, r6, r7}
 806532c: bc01         	pop	{r0}
 806532e: 4700         	bx	r0
 8065330: b530         	push	{r4, r5, lr}
 8065332: 1c05         	adds	r5, r0, #0x0
 8065334: 2400         	movs	r4, #0x0
 8065336: e009         	b	0x806534c <.text+0x6534c> @ imm = #0x12
 8065338: 20c4         	movs	r0, #0xc4
 806533a: 1c21         	adds	r1, r4, #0x0
 806533c: 4341         	muls	r1, r0, r1
 806533e: 6828         	ldr	r0, [r5]
 8065340: 1840         	adds	r0, r0, r1
 8065342: f7f3 f8cb    	bl	0x80584dc <.text+0x584dc> @ imm = #-0xce6a
 8065346: 1c60         	adds	r0, r4, #0x1
 8065348: 0400         	lsls	r0, r0, #0x10
 806534a: 0c04         	lsrs	r4, r0, #0x10
 806534c: 7928         	ldrb	r0, [r5, #0x4]
 806534e: 4284         	cmp	r4, r0
 8065350: d3f2         	blo	0x8065338 <.text+0x65338> @ imm = #-0x1c
 8065352: bc30         	pop	{r4, r5}
 8065354: bc01         	pop	{r0}
 8065356: 4700         	bx	r0
 8065358: b5f0         	push	{r4, r5, r6, r7, lr}
 806535a: 4647         	mov	r7, r8
 806535c: b480         	push	{r7}
 806535e: 1c04         	adds	r4, r0, #0x0
 8065360: 2700         	movs	r7, #0x0
 8065362: 2300         	movs	r3, #0x0
 8065364: 2500         	movs	r5, #0x0
 8065366: 7920         	ldrb	r0, [r4, #0x4]
 8065368: 4283         	cmp	r3, r0
 806536a: d228         	bhs	0x80653be <.text+0x653be> @ imm = #0x50
 806536c: 6921         	ldr	r1, [r4, #0x10]
 806536e: 4688         	mov	r8, r1
 8065370: 4684         	mov	r12, r0
 8065372: 20c4         	movs	r0, #0xc4
 8065374: 1c29         	adds	r1, r5, #0x0
 8065376: 4341         	muls	r1, r0, r1
 8065378: 6820         	ldr	r0, [r4]
 806537a: 1842         	adds	r2, r0, r1
 806537c: 4646         	mov	r6, r8
 806537e: 2e00         	cmp	r6, #0x0
 8065380: d008         	beq	0x8065394 <.text+0x65394> @ imm = #0x10
 8065382: 19e8         	adds	r0, r5, r7
 8065384: 4440         	add	r0, r8
 8065386: 7800         	ldrb	r0, [r0]
 8065388: 2820         	cmp	r0, #0x20
 806538a: d103         	bne	0x8065394 <.text+0x65394> @ imm = #0x6
 806538c: 3305         	adds	r3, #0x5
 806538e: 1c78         	adds	r0, r7, #0x1
 8065390: 0400         	lsls	r0, r0, #0x10
 8065392: 0c07         	lsrs	r7, r0, #0x10
 8065394: 6f10         	ldr	r0, [r2, #0x70]
 8065396: 2800         	cmp	r0, #0x0
 8065398: d00c         	beq	0x80653b4 <.text+0x653b4> @ imm = #0x18
 806539a: 6aa1         	ldr	r1, [r4, #0x28]
 806539c: 2900         	cmp	r1, #0x0
 806539e: d007         	beq	0x80653b0 <.text+0x653b0> @ imm = #0xe
 80653a0: 2622         	movs	r6, #0x22
 80653a2: 5f90         	ldrsh	r0, [r2, r6]
 80653a4: 1808         	adds	r0, r1, r0
 80653a6: 7c12         	ldrb	r2, [r2, #0x10]
 80653a8: 7800         	ldrb	r0, [r0]
 80653aa: 1a10         	subs	r0, r2, r0
 80653ac: 181b         	adds	r3, r3, r0
 80653ae: e001         	b	0x80653b4 <.text+0x653b4> @ imm = #0x2
 80653b0: 7c12         	ldrb	r2, [r2, #0x10]
 80653b2: 18d3         	adds	r3, r2, r3
 80653b4: 1c68         	adds	r0, r5, #0x1
 80653b6: 0400         	lsls	r0, r0, #0x10
 80653b8: 0c05         	lsrs	r5, r0, #0x10
 80653ba: 4565         	cmp	r5, r12
 80653bc: d3d9         	blo	0x8065372 <.text+0x65372> @ imm = #-0x4e
 80653be: 2124         	movs	r1, #0x24
 80653c0: 5e60         	ldrsh	r0, [r4, r1]
 80653c2: 4358         	muls	r0, r3, r0
 80653c4: 1203         	asrs	r3, r0, #0x8
 80653c6: 1c18         	adds	r0, r3, #0x0
 80653c8: bc08         	pop	{r3}
 80653ca: 4698         	mov	r8, r3
 80653cc: bcf0         	pop	{r4, r5, r6, r7}
 80653ce: bc02         	pop	{r1}
 80653d0: 4708         	bx	r1
 80653d2: 0000         	movs	r0, r0
 80653d4: b530         	push	{r4, r5, lr}
 80653d6: 1c05         	adds	r5, r0, #0x0
 80653d8: 2400         	movs	r4, #0x0
 80653da: e009         	b	0x80653f0 <.text+0x653f0> @ imm = #0x12
 80653dc: 20c4         	movs	r0, #0xc4
 80653de: 1c21         	adds	r1, r4, #0x0
 80653e0: 4341         	muls	r1, r0, r1
 80653e2: 6828         	ldr	r0, [r5]
 80653e4: 1840         	adds	r0, r0, r1
 80653e6: f7f3 f9d9    	bl	0x805879c <.text+0x5879c> @ imm = #-0xcc4e
 80653ea: 1c60         	adds	r0, r4, #0x1
 80653ec: 0400         	lsls	r0, r0, #0x10
 80653ee: 0c04         	lsrs	r4, r0, #0x10
 80653f0: 7928         	ldrb	r0, [r5, #0x4]
 80653f2: 4284         	cmp	r4, r0
 80653f4: d3f2         	blo	0x80653dc <.text+0x653dc> @ imm = #-0x1c
 80653f6: bc30         	pop	{r4, r5}
 80653f8: bc01         	pop	{r0}
 80653fa: 4700         	bx	r0
 80653fc: b5f0         	push	{r4, r5, r6, r7, lr}
 80653fe: 4657         	mov	r7, r10
 8065400: 464e         	mov	r6, r9
 8065402: 4645         	mov	r5, r8
 8065404: b4e0         	push	{r5, r6, r7}
 8065406: b083         	sub	sp, #0xc
 8065408: 9000         	str	r0, [sp]
 806540a: 2000         	movs	r0, #0x0
 806540c: 4682         	mov	r10, r0
 806540e: 2100         	movs	r1, #0x0
 8065410: 9101         	str	r1, [sp, #0x4]
 8065412: 2200         	movs	r2, #0x0
 8065414: 9202         	str	r2, [sp, #0x8]
 8065416: 9900         	ldr	r1, [sp]
 8065418: 6888         	ldr	r0, [r1, #0x8]
 806541a: 2800         	cmp	r0, #0x0
 806541c: da00         	bge	0x8065420 <.text+0x65420> @ imm = #0x0
 806541e: 4240         	rsbs	r0, r0, #0
 8065420: 1c07         	adds	r7, r0, #0x0
 8065422: 9a00         	ldr	r2, [sp]
 8065424: 7910         	ldrb	r0, [r2, #0x4]
 8065426: 3801         	subs	r0, #0x1
 8065428: 0400         	lsls	r0, r0, #0x10
 806542a: e070         	b	0x806550e <.text+0x6550e> @ imm = #0xe0
 806542c: 1409         	asrs	r1, r1, #0x10
 806542e: 20c4         	movs	r0, #0xc4
 8065430: 4341         	muls	r1, r0, r1
 8065432: 9a00         	ldr	r2, [sp]
 8065434: 6810         	ldr	r0, [r2]
 8065436: 1844         	adds	r4, r0, r1
 8065438: 2f00         	cmp	r7, #0x0
 806543a: dd05         	ble	0x8065448 <.text+0x65448> @ imm = #0xa
 806543c: 1c38         	adds	r0, r7, #0x0
 806543e: 210a         	movs	r1, #0xa
 8065440: f7f2 fa54    	bl	0x80578ec <.text+0x578ec> @ imm = #-0xdb58
 8065444: 1c02         	adds	r2, r0, #0x0
 8065446: e000         	b	0x806544a <.text+0x6544a> @ imm = #0x0
 8065448: 2200         	movs	r2, #0x0
 806544a: 9901         	ldr	r1, [sp, #0x4]
 806544c: 0408         	lsls	r0, r1, #0x10
 806544e: 1401         	asrs	r1, r0, #0x10
 8065450: 4680         	mov	r8, r0
 8065452: 2902         	cmp	r1, #0x2
 8065454: dd18         	ble	0x8065488 <.text+0x65488> @ imm = #0x30
 8065456: 2f00         	cmp	r7, #0x0
 8065458: dd16         	ble	0x8065488 <.text+0x65488> @ imm = #0x2c
 806545a: 1ec8         	subs	r0, r1, #0x3
 806545c: 0400         	lsls	r0, r0, #0x10
 806545e: 0c00         	lsrs	r0, r0, #0x10
 8065460: 9001         	str	r0, [sp, #0x4]
 8065462: 2201         	movs	r2, #0x1
 8065464: 4252         	rsbs	r2, r2, #0
 8065466: 6722         	str	r2, [r4, #0x70]
 8065468: 4806         	ldr	r0, [pc, #0x18]         @ 0x8065484 <.text+0x65484>
 806546a: 7802         	ldrb	r2, [r0]
 806546c: 1c20         	adds	r0, r4, #0x0
 806546e: 2100         	movs	r1, #0x0
 8065470: f7f2 ffc6    	bl	0x8058400 <.text+0x58400> @ imm = #-0xd074
 8065474: 4651         	mov	r1, r10
 8065476: 0408         	lsls	r0, r1, #0x10
 8065478: 2280         	movs	r2, #0x80
 806547a: 0252         	lsls	r2, r2, #0x9
 806547c: 1880         	adds	r0, r0, r2
 806547e: 0c00         	lsrs	r0, r0, #0x10
 8065480: 4682         	mov	r10, r0
 8065482: e040         	b	0x8065506 <.text+0x65506> @ imm = #0x80
 8065484: d9d0         	bls	0x8065428 <.text+0x65428> @ imm = #-0x60
 8065486: 0807         	lsrs	r7, r0, #0x20
 8065488: 4650         	mov	r0, r10
 806548a: 0406         	lsls	r6, r0, #0x10
 806548c: 2a00         	cmp	r2, #0x0
 806548e: d120         	bne	0x80654d2 <.text+0x654d2> @ imm = #0x40
 8065490: 2f00         	cmp	r7, #0x0
 8065492: d11e         	bne	0x80654d2 <.text+0x654d2> @ imm = #0x3c
 8065494: 1435         	asrs	r5, r6, #0x10
 8065496: 2d00         	cmp	r5, #0x0
 8065498: d01b         	beq	0x80654d2 <.text+0x654d2> @ imm = #0x36
 806549a: 9900         	ldr	r1, [sp]
 806549c: 6888         	ldr	r0, [r1, #0x8]
 806549e: 2800         	cmp	r0, #0x0
 80654a0: da14         	bge	0x80654cc <.text+0x654cc> @ imm = #0x28
 80654a2: 9a02         	ldr	r2, [sp, #0x8]
 80654a4: 2a00         	cmp	r2, #0x0
 80654a6: d111         	bne	0x80654cc <.text+0x654cc> @ imm = #0x22
 80654a8: 2001         	movs	r0, #0x1
 80654aa: 4240         	rsbs	r0, r0, #0
 80654ac: 6720         	str	r0, [r4, #0x70]
 80654ae: 4906         	ldr	r1, [pc, #0x18]         @ 0x80654c8 <.text+0x654c8>
 80654b0: 780a         	ldrb	r2, [r1]
 80654b2: 1c20         	adds	r0, r4, #0x0
 80654b4: 2100         	movs	r1, #0x0
 80654b6: f7f2 ffa3    	bl	0x8058400 <.text+0x58400> @ imm = #-0xd0ba
 80654ba: 2201         	movs	r2, #0x1
 80654bc: 9202         	str	r2, [sp, #0x8]
 80654be: 1c68         	adds	r0, r5, #0x1
 80654c0: 0400         	lsls	r0, r0, #0x10
 80654c2: 0c00         	lsrs	r0, r0, #0x10
 80654c4: 4682         	mov	r10, r0
 80654c6: e017         	b	0x80654f8 <.text+0x654f8> @ imm = #0x2e
 80654c8: d9d1         	bls	0x806546e <.text+0x6546e> @ imm = #-0x5e
 80654ca: 0807         	lsrs	r7, r0, #0x20
 80654cc: 2000         	movs	r0, #0x0
 80654ce: 6720         	str	r0, [r4, #0x70]
 80654d0: e012         	b	0x80654f8 <.text+0x654f8> @ imm = #0x24
 80654d2: 2001         	movs	r0, #0x1
 80654d4: 4240         	rsbs	r0, r0, #0
 80654d6: 6720         	str	r0, [r4, #0x70]
 80654d8: 3234         	adds	r2, #0x34
 80654da: 0412         	lsls	r2, r2, #0x10
 80654dc: 0c12         	lsrs	r2, r2, #0x10
 80654de: 1c20         	adds	r0, r4, #0x0
 80654e0: 2100         	movs	r1, #0x0
 80654e2: f7f2 ff8d    	bl	0x8058400 <.text+0x58400> @ imm = #-0xd0e6
 80654e6: 2180         	movs	r1, #0x80
 80654e8: 0249         	lsls	r1, r1, #0x9
 80654ea: 1870         	adds	r0, r6, r1
 80654ec: 0c00         	lsrs	r0, r0, #0x10
 80654ee: 4682         	mov	r10, r0
 80654f0: 1c08         	adds	r0, r1, #0x0
 80654f2: 4440         	add	r0, r8
 80654f4: 0c00         	lsrs	r0, r0, #0x10
 80654f6: 9001         	str	r0, [sp, #0x4]
 80654f8: 2f00         	cmp	r7, #0x0
 80654fa: dd04         	ble	0x8065506 <.text+0x65506> @ imm = #0x8
 80654fc: 1c38         	adds	r0, r7, #0x0
 80654fe: 210a         	movs	r1, #0xa
 8065500: f7f2 f9f2    	bl	0x80578e8 <.text+0x578e8> @ imm = #-0xdc1c
 8065504: 1c07         	adds	r7, r0, #0x0
 8065506: 464a         	mov	r2, r9
 8065508: 0410         	lsls	r0, r2, #0x10
 806550a: 4907         	ldr	r1, [pc, #0x1c]         @ 0x8065528 <.text+0x65528>
 806550c: 1840         	adds	r0, r0, r1
 806550e: 0c00         	lsrs	r0, r0, #0x10
 8065510: 4681         	mov	r9, r0
 8065512: 0401         	lsls	r1, r0, #0x10
 8065514: 2900         	cmp	r1, #0x0
 8065516: da89         	bge	0x806542c <.text+0x6542c> @ imm = #-0xee
 8065518: b003         	add	sp, #0xc
 806551a: bc38         	pop	{r3, r4, r5}
 806551c: 4698         	mov	r8, r3
 806551e: 46a1         	mov	r9, r4
 8065520: 46aa         	mov	r10, r5
 8065522: bcf0         	pop	{r4, r5, r6, r7}
 8065524: bc01         	pop	{r0}
 8065526: 4700         	bx	r0
 8065528: 0000         	movs	r0, r0
 806552a: ffff b5f0    	<unknown>
 806552e: b081         	sub	sp, #0x4
 8065530: 1c06         	adds	r6, r0, #0x0
 8065532: 68b7         	ldr	r7, [r6, #0x8]
 8065534: 2100         	movs	r1, #0x0
 8065536: 7930         	ldrb	r0, [r6, #0x4]
 8065538: 4281         	cmp	r1, r0
 806553a: d20c         	bhs	0x8065556 <.text+0x65556> @ imm = #0x18
 806553c: 24c4         	movs	r4, #0xc4
 806553e: 6832         	ldr	r2, [r6]
 8065540: 2300         	movs	r3, #0x0
 8065542: 1c08         	adds	r0, r1, #0x0
 8065544: 4360         	muls	r0, r4, r0
 8065546: 1810         	adds	r0, r2, r0
 8065548: 6703         	str	r3, [r0, #0x70]
 806554a: 1c48         	adds	r0, r1, #0x1
 806554c: 0400         	lsls	r0, r0, #0x10
 806554e: 0c01         	lsrs	r1, r0, #0x10
 8065550: 7930         	ldrb	r0, [r6, #0x4]
 8065552: 4281         	cmp	r1, r0
 8065554: d3f5         	blo	0x8065542 <.text+0x65542> @ imm = #-0x16
 8065556: 2f00         	cmp	r7, #0x0
 8065558: da00         	bge	0x806555c <.text+0x6555c> @ imm = #0x0
 806555a: 427f         	rsbs	r7, r7, #0
 806555c: 1c38         	adds	r0, r7, #0x0
 806555e: 213c         	movs	r1, #0x3c
 8065560: f7f2 f9c4    	bl	0x80578ec <.text+0x578ec> @ imm = #-0xdc78
 8065564: 1c01         	adds	r1, r0, #0x0
 8065566: 7932         	ldrb	r2, [r6, #0x4]
 8065568: 3a01         	subs	r2, #0x1
 806556a: 2001         	movs	r0, #0x1
 806556c: 9000         	str	r0, [sp]
 806556e: 1c30         	adds	r0, r6, #0x0
 8065570: 2302         	movs	r3, #0x2
 8065572: f000 f837    	bl	0x80655e4 <.text+0x655e4> @ imm = #0x6e
 8065576: 1c38         	adds	r0, r7, #0x0
 8065578: 213c         	movs	r1, #0x3c
 806557a: f7f2 f9b5    	bl	0x80578e8 <.text+0x578e8> @ imm = #-0xdc96
 806557e: 1c07         	adds	r7, r0, #0x0
 8065580: 24c4         	movs	r4, #0xc4
 8065582: 7932         	ldrb	r2, [r6, #0x4]
 8065584: 1c11         	adds	r1, r2, #0x0
 8065586: 4361         	muls	r1, r4, r1
 8065588: 4d0d         	ldr	r5, [pc, #0x34]         @ 0x80655c0 <.text+0x655c0>
 806558a: 1949         	adds	r1, r1, r5
 806558c: 6830         	ldr	r0, [r6]
 806558e: 1840         	adds	r0, r0, r1
 8065590: 490c         	ldr	r1, [pc, #0x30]         @ 0x80655c4 <.text+0x655c4>
 8065592: 313a         	adds	r1, #0x3a
 8065594: 780a         	ldrb	r2, [r1]
 8065596: 2100         	movs	r1, #0x0
 8065598: f7f2 ff32    	bl	0x8058400 <.text+0x58400> @ imm = #-0xd19c
 806559c: 6831         	ldr	r1, [r6]
 806559e: 7932         	ldrb	r2, [r6, #0x4]
 80655a0: 1c10         	adds	r0, r2, #0x0
 80655a2: 4360         	muls	r0, r4, r0
 80655a4: 1840         	adds	r0, r0, r1
 80655a6: 1940         	adds	r0, r0, r5
 80655a8: 2101         	movs	r1, #0x1
 80655aa: 4249         	rsbs	r1, r1, #0
 80655ac: 6701         	str	r1, [r0, #0x70]
 80655ae: 2f00         	cmp	r7, #0x0
 80655b0: d00a         	beq	0x80655c8 <.text+0x655c8> @ imm = #0x14
 80655b2: 1c38         	adds	r0, r7, #0x0
 80655b4: 213c         	movs	r1, #0x3c
 80655b6: f7f2 f999    	bl	0x80578ec <.text+0x578ec> @ imm = #-0xdcce
 80655ba: 1c01         	adds	r1, r0, #0x0
 80655bc: e005         	b	0x80655ca <.text+0x655ca> @ imm = #0xa
 80655be: 0000         	movs	r0, r0
 80655c0: fdb4 ffff    	<unknown>
 80655c4: d9a4         	bls	0x8065510 <.text+0x65510> @ imm = #-0xb8
 80655c6: 0807         	lsrs	r7, r0, #0x20
 80655c8: 2100         	movs	r1, #0x0
 80655ca: 7932         	ldrb	r2, [r6, #0x4]
 80655cc: 3a04         	subs	r2, #0x4
 80655ce: 2000         	movs	r0, #0x0
 80655d0: 9000         	str	r0, [sp]
 80655d2: 1c30         	adds	r0, r6, #0x0
 80655d4: 2302         	movs	r3, #0x2
 80655d6: f000 f805    	bl	0x80655e4 <.text+0x655e4> @ imm = #0xa
 80655da: b001         	add	sp, #0x4
 80655dc: bcf0         	pop	{r4, r5, r6, r7}
 80655de: bc01         	pop	{r0}
 80655e0: 4700         	bx	r0
 80655e2: 0000         	movs	r0, r0
 80655e4: b5f0         	push	{r4, r5, r6, r7, lr}
 80655e6: 4657         	mov	r7, r10
 80655e8: 464e         	mov	r6, r9
 80655ea: 4645         	mov	r5, r8
 80655ec: b4e0         	push	{r5, r6, r7}
 80655ee: b081         	sub	sp, #0x4
 80655f0: 4681         	mov	r9, r0
 80655f2: 9809         	ldr	r0, [sp, #0x24]
 80655f4: 0412         	lsls	r2, r2, #0x10
 80655f6: 0c12         	lsrs	r2, r2, #0x10
 80655f8: 041b         	lsls	r3, r3, #0x10
 80655fa: 0c1b         	lsrs	r3, r3, #0x10
 80655fc: 0600         	lsls	r0, r0, #0x18
 80655fe: 0e00         	lsrs	r0, r0, #0x18
 8065600: 9000         	str	r0, [sp]
 8065602: 2000         	movs	r0, #0x0
 8065604: 4680         	mov	r8, r0
 8065606: 2900         	cmp	r1, #0x0
 8065608: da00         	bge	0x806560c <.text+0x6560c> @ imm = #0x0
 806560a: 4249         	rsbs	r1, r1, #0
 806560c: 1c0e         	adds	r6, r1, #0x0
 806560e: 0410         	lsls	r0, r2, #0x10
 8065610: 1404         	asrs	r4, r0, #0x10
 8065612: 4649         	mov	r1, r9
 8065614: 7909         	ldrb	r1, [r1, #0x4]
 8065616: 428c         	cmp	r4, r1
 8065618: db01         	blt	0x806561e <.text+0x6561e> @ imm = #0x2
 806561a: 2000         	movs	r0, #0x0
 806561c: e053         	b	0x80656c6 <.text+0x656c6> @ imm = #0xa6
 806561e: 0c07         	lsrs	r7, r0, #0x10
 8065620: 043a         	lsls	r2, r7, #0x10
 8065622: 1411         	asrs	r1, r2, #0x10
 8065624: 0418         	lsls	r0, r3, #0x10
 8065626: 1400         	asrs	r0, r0, #0x10
 8065628: 1a20         	subs	r0, r4, r0
 806562a: 2300         	movs	r3, #0x0
 806562c: 4281         	cmp	r1, r0
 806562e: dd49         	ble	0x80656c4 <.text+0x656c4> @ imm = #0x92
 8065630: 4682         	mov	r10, r0
 8065632: 1411         	asrs	r1, r2, #0x10
 8065634: 20c4         	movs	r0, #0xc4
 8065636: 4341         	muls	r1, r0, r1
 8065638: 464a         	mov	r2, r9
 806563a: 6810         	ldr	r0, [r2]
 806563c: 1844         	adds	r4, r0, r1
 806563e: 2e00         	cmp	r6, #0x0
 8065640: dd05         	ble	0x806564e <.text+0x6564e> @ imm = #0xa
 8065642: 1c30         	adds	r0, r6, #0x0
 8065644: 210a         	movs	r1, #0xa
 8065646: f7f2 f951    	bl	0x80578ec <.text+0x578ec> @ imm = #-0xdd5e
 806564a: 1c02         	adds	r2, r0, #0x0
 806564c: e000         	b	0x8065650 <.text+0x65650> @ imm = #0x0
 806564e: 2200         	movs	r2, #0x0
 8065650: 2a00         	cmp	r2, #0x0
 8065652: d115         	bne	0x8065680 <.text+0x65680> @ imm = #0x2a
 8065654: 2e00         	cmp	r6, #0x0
 8065656: d113         	bne	0x8065680 <.text+0x65680> @ imm = #0x26
 8065658: 4641         	mov	r1, r8
 806565a: 0408         	lsls	r0, r1, #0x10
 806565c: 1405         	asrs	r5, r0, #0x10
 806565e: 1c03         	adds	r3, r0, #0x0
 8065660: 2d00         	cmp	r5, #0x0
 8065662: d00d         	beq	0x8065680 <.text+0x65680> @ imm = #0x1a
 8065664: 9a00         	ldr	r2, [sp]
 8065666: 2a00         	cmp	r2, #0x0
 8065668: d02c         	beq	0x80656c4 <.text+0x656c4> @ imm = #0x58
 806566a: 2001         	movs	r0, #0x1
 806566c: 4240         	rsbs	r0, r0, #0
 806566e: 6720         	str	r0, [r4, #0x70]
 8065670: 1c20         	adds	r0, r4, #0x0
 8065672: 2100         	movs	r1, #0x0
 8065674: 2234         	movs	r2, #0x34
 8065676: f7f2 fec3    	bl	0x8058400 <.text+0x58400> @ imm = #-0xd27a
 806567a: 1c68         	adds	r0, r5, #0x1
 806567c: 0400         	lsls	r0, r0, #0x10
 806567e: e00e         	b	0x806569e <.text+0x6569e> @ imm = #0x1c
 8065680: 2001         	movs	r0, #0x1
 8065682: 4240         	rsbs	r0, r0, #0
 8065684: 6720         	str	r0, [r4, #0x70]
 8065686: 3234         	adds	r2, #0x34
 8065688: 0412         	lsls	r2, r2, #0x10
 806568a: 0c12         	lsrs	r2, r2, #0x10
 806568c: 1c20         	adds	r0, r4, #0x0
 806568e: 2100         	movs	r1, #0x0
 8065690: f7f2 feb6    	bl	0x8058400 <.text+0x58400> @ imm = #-0xd294
 8065694: 4641         	mov	r1, r8
 8065696: 0408         	lsls	r0, r1, #0x10
 8065698: 2280         	movs	r2, #0x80
 806569a: 0252         	lsls	r2, r2, #0x9
 806569c: 1880         	adds	r0, r0, r2
 806569e: 0c00         	lsrs	r0, r0, #0x10
 80656a0: 4680         	mov	r8, r0
 80656a2: 2e00         	cmp	r6, #0x0
 80656a4: dd04         	ble	0x80656b0 <.text+0x656b0> @ imm = #0x8
 80656a6: 1c30         	adds	r0, r6, #0x0
 80656a8: 210a         	movs	r1, #0xa
 80656aa: f7f2 f91d    	bl	0x80578e8 <.text+0x578e8> @ imm = #-0xddc6
 80656ae: 1c06         	adds	r6, r0, #0x0
 80656b0: 0438         	lsls	r0, r7, #0x10
 80656b2: 4909         	ldr	r1, [pc, #0x24]         @ 0x80656d8 <.text+0x656d8>
 80656b4: 1840         	adds	r0, r0, r1
 80656b6: 0c07         	lsrs	r7, r0, #0x10
 80656b8: 043a         	lsls	r2, r7, #0x10
 80656ba: 1410         	asrs	r0, r2, #0x10
 80656bc: 4641         	mov	r1, r8
 80656be: 040b         	lsls	r3, r1, #0x10
 80656c0: 4550         	cmp	r0, r10
 80656c2: dcb6         	bgt	0x8065632 <.text+0x65632> @ imm = #-0x94
 80656c4: 0c18         	lsrs	r0, r3, #0x10
 80656c6: b001         	add	sp, #0x4
 80656c8: bc38         	pop	{r3, r4, r5}
 80656ca: 4698         	mov	r8, r3
 80656cc: 46a1         	mov	r9, r4
 80656ce: 46aa         	mov	r10, r5
 80656d0: bcf0         	pop	{r4, r5, r6, r7}
 80656d2: bc02         	pop	{r1}
 80656d4: 4708         	bx	r1
 80656d6: 0000         	movs	r0, r0
 80656d8: 0000         	movs	r0, r0
 80656da: ffff b570    	<unknown>
 80656de: 7904         	ldrb	r4, [r0, #0x4]
 80656e0: 6906         	ldr	r6, [r0, #0x10]
 80656e2: 6805         	ldr	r5, [r0]
 80656e4: e00d         	b	0x8065702 <.text+0x65702> @ imm = #0x1a
 80656e6: 2920         	cmp	r1, #0x20
 80656e8: d00b         	beq	0x8065702 <.text+0x65702> @ imm = #0x16
 80656ea: 4810         	ldr	r0, [pc, #0x40]         @ 0x806572c <.text+0x6572c>
 80656ec: 1808         	adds	r0, r1, r0
 80656ee: 7802         	ldrb	r2, [r0]
 80656f0: 1c28         	adds	r0, r5, #0x0
 80656f2: 2100         	movs	r1, #0x0
 80656f4: f7f2 fe84    	bl	0x8058400 <.text+0x58400> @ imm = #-0xd2f8
 80656f8: 2001         	movs	r0, #0x1
 80656fa: 4240         	rsbs	r0, r0, #0
 80656fc: 6728         	str	r0, [r5, #0x70]
 80656fe: 35c4         	adds	r5, #0xc4
 8065700: 3c01         	subs	r4, #0x1
 8065702: 2c00         	cmp	r4, #0x0
 8065704: d003         	beq	0x806570e <.text+0x6570e> @ imm = #0x6
 8065706: 7831         	ldrb	r1, [r6]
 8065708: 3601         	adds	r6, #0x1
 806570a: 2900         	cmp	r1, #0x0
 806570c: d1eb         	bne	0x80656e6 <.text+0x656e6> @ imm = #-0x2a
 806570e: 1c20         	adds	r0, r4, #0x0
 8065710: 3c01         	subs	r4, #0x1
 8065712: 2800         	cmp	r0, #0x0
 8065714: d006         	beq	0x8065724 <.text+0x65724> @ imm = #0xc
 8065716: 2100         	movs	r1, #0x0
 8065718: 6729         	str	r1, [r5, #0x70]
 806571a: 35c4         	adds	r5, #0xc4
 806571c: 1c20         	adds	r0, r4, #0x0
 806571e: 3c01         	subs	r4, #0x1
 8065720: 2800         	cmp	r0, #0x0
 8065722: d1f9         	bne	0x8065718 <.text+0x65718> @ imm = #-0xe
 8065724: bc70         	pop	{r4, r5, r6}
 8065726: bc01         	pop	{r0}
 8065728: 4700         	bx	r0
 806572a: 0000         	movs	r0, r0
 806572c: d9a4         	bls	0x8065678 <.text+0x65678> @ imm = #-0xb8
 806572e: 0807         	lsrs	r7, r0, #0x20
 8065730: b5f0         	push	{r4, r5, r6, r7, lr}
 8065732: 464f         	mov	r7, r9
 8065734: 4646         	mov	r6, r8
 8065736: b4c0         	push	{r6, r7}
 8065738: b081         	sub	sp, #0x4
 806573a: 1c05         	adds	r5, r0, #0x0
 806573c: 4689         	mov	r9, r1
 806573e: 4690         	mov	r8, r2
 8065740: 1c1f         	adds	r7, r3, #0x0
 8065742: 2600         	movs	r6, #0x0
 8065744: 2400         	movs	r4, #0x0
 8065746: 7928         	ldrb	r0, [r5, #0x4]
 8065748: 4284         	cmp	r4, r0
 806574a: d214         	bhs	0x8065776 <.text+0x65776> @ imm = #0x28
 806574c: 20c4         	movs	r0, #0xc4
 806574e: 1c21         	adds	r1, r4, #0x0
 8065750: 4341         	muls	r1, r0, r1
 8065752: 6828         	ldr	r0, [r5]
 8065754: 1840         	adds	r0, r0, r1
 8065756: 9a08         	ldr	r2, [sp, #0x20]
 8065758: 1991         	adds	r1, r2, r6
 806575a: 9100         	str	r1, [sp]
 806575c: 4649         	mov	r1, r9
 806575e: 4642         	mov	r2, r8
 8065760: 1c3b         	adds	r3, r7, #0x0
 8065762: f7f3 f829    	bl	0x80587b8 <.text+0x587b8> @ imm = #-0xcfae
 8065766: 9809         	ldr	r0, [sp, #0x24]
 8065768: 1836         	adds	r6, r6, r0
 806576a: 1c60         	adds	r0, r4, #0x1
 806576c: 0400         	lsls	r0, r0, #0x10
 806576e: 0c04         	lsrs	r4, r0, #0x10
 8065770: 792a         	ldrb	r2, [r5, #0x4]
 8065772: 4294         	cmp	r4, r2
 8065774: d3ea         	blo	0x806574c <.text+0x6574c> @ imm = #-0x2c
 8065776: b001         	add	sp, #0x4
 8065778: bc18         	pop	{r3, r4}
 806577a: 4698         	mov	r8, r3
 806577c: 46a1         	mov	r9, r4
 806577e: bcf0         	pop	{r4, r5, r6, r7}
 8065780: bc01         	pop	{r0}
 8065782: 4700         	bx	r0
 8065784: b5f0         	push	{r4, r5, r6, r7, lr}
 8065786: 4657         	mov	r7, r10
 8065788: 464e         	mov	r6, r9
 806578a: 4645         	mov	r5, r8
 806578c: b4e0         	push	{r5, r6, r7}
 806578e: b081         	sub	sp, #0x4
 8065790: 1c07         	adds	r7, r0, #0x0
 8065792: 468a         	mov	r10, r1
 8065794: 4691         	mov	r9, r2
 8065796: 4698         	mov	r8, r3
 8065798: 980b         	ldr	r0, [sp, #0x2c]
 806579a: 0400         	lsls	r0, r0, #0x10
 806579c: 0c05         	lsrs	r5, r0, #0x10
 806579e: 2600         	movs	r6, #0x0
 80657a0: 7938         	ldrb	r0, [r7, #0x4]
 80657a2: 4285         	cmp	r5, r0
 80657a4: d900         	bls	0x80657a8 <.text+0x657a8> @ imm = #0x0
 80657a6: 1c05         	adds	r5, r0, #0x0
 80657a8: 2400         	movs	r4, #0x0
 80657aa: 42ac         	cmp	r4, r5
 80657ac: d213         	bhs	0x80657d6 <.text+0x657d6> @ imm = #0x26
 80657ae: 20c4         	movs	r0, #0xc4
 80657b0: 1c21         	adds	r1, r4, #0x0
 80657b2: 4341         	muls	r1, r0, r1
 80657b4: 6838         	ldr	r0, [r7]
 80657b6: 1840         	adds	r0, r0, r1
 80657b8: 9a09         	ldr	r2, [sp, #0x24]
 80657ba: 1991         	adds	r1, r2, r6
 80657bc: 9100         	str	r1, [sp]
 80657be: 4651         	mov	r1, r10
 80657c0: 464a         	mov	r2, r9
 80657c2: 4643         	mov	r3, r8
 80657c4: f7f2 fff8    	bl	0x80587b8 <.text+0x587b8> @ imm = #-0xd010
 80657c8: 980a         	ldr	r0, [sp, #0x28]
 80657ca: 1836         	adds	r6, r6, r0
 80657cc: 1c60         	adds	r0, r4, #0x1
 80657ce: 0400         	lsls	r0, r0, #0x10
 80657d0: 0c04         	lsrs	r4, r0, #0x10
 80657d2: 42ac         	cmp	r4, r5
 80657d4: d3eb         	blo	0x80657ae <.text+0x657ae> @ imm = #-0x2a
 80657d6: b001         	add	sp, #0x4
 80657d8: bc38         	pop	{r3, r4, r5}
 80657da: 4698         	mov	r8, r3
 80657dc: 46a1         	mov	r9, r4
 80657de: 46aa         	mov	r10, r5
 80657e0: bcf0         	pop	{r4, r5, r6, r7}
 80657e2: bc01         	pop	{r0}
 80657e4: 4700         	bx	r0
 80657e6: 0000         	movs	r0, r0
 80657e8: b530         	push	{r4, r5, lr}
 80657ea: 1c05         	adds	r5, r0, #0x0
 80657ec: 2400         	movs	r4, #0x0
 80657ee: e009         	b	0x8065804 <.text+0x65804> @ imm = #0x12
 80657f0: 20c4         	movs	r0, #0xc4
 80657f2: 1c21         	adds	r1, r4, #0x0
 80657f4: 4341         	muls	r1, r0, r1
 80657f6: 6828         	ldr	r0, [r5]
 80657f8: 1840         	adds	r0, r0, r1
 80657fa: f7f3 f881    	bl	0x8058900 <.text+0x58900> @ imm = #-0xcefe
 80657fe: 1c60         	adds	r0, r4, #0x1
 8065800: 0400         	lsls	r0, r0, #0x10
 8065802: 0c04         	lsrs	r4, r0, #0x10
 8065804: 7928         	ldrb	r0, [r5, #0x4]
 8065806: 4284         	cmp	r4, r0
 8065808: d3f2         	blo	0x80657f0 <.text+0x657f0> @ imm = #-0x1c
 806580a: bc30         	pop	{r4, r5}
 806580c: bc01         	pop	{r0}
 806580e: 4700         	bx	r0
