
/tmp/dis.o:	file format elf32-littlearm

Disassembly of section .text:

00000000 <rom>:
   62f20: b570         	push	{r4, r5, r6, lr}
   62f22: 1c06         	adds	r6, r0, #0x0
   62f24: 2500         	movs	r5, #0x0
   62f26: 4a11         	ldr	r2, [pc, #0x44]         @ 0x62f6c <rom+0x62f6c>
   62f28: 6810         	ldr	r0, [r2]
   62f2a: 4911         	ldr	r1, [pc, #0x44]         @ 0x62f70 <rom+0x62f70>
   62f2c: 2800         	cmp	r0, #0x0
   62f2e: d105         	bne	0x62f3c <rom+0x62f3c>   @ imm = #0xa
   62f30: 4810         	ldr	r0, [pc, #0x40]         @ 0x62f74 <rom+0x62f74>
   62f32: 6800         	ldr	r0, [r0]
   62f34: 6010         	str	r0, [r2]
   62f36: 4810         	ldr	r0, [pc, #0x40]         @ 0x62f78 <rom+0x62f78>
   62f38: 6005         	str	r5, [r0]
   62f3a: 600d         	str	r5, [r1]
   62f3c: 6808         	ldr	r0, [r1]
   62f3e: 28ff         	cmp	r0, #0xff
   62f40: dc11         	bgt	0x62f66 <rom+0x62f66>   @ imm = #0x22
   62f42: f000 f843    	bl	0x62fcc <rom+0x62fcc>   @ imm = #0x86
   62f46: 1c04         	adds	r4, r0, #0x0
   62f48: 480b         	ldr	r0, [pc, #0x2c]         @ 0x62f78 <rom+0x62f78>
   62f4a: 6802         	ldr	r2, [r0]
   62f4c: 1991         	adds	r1, r2, r6
   62f4e: 2080         	movs	r0, #0x80
   62f50: 0040         	lsls	r0, r0, #0x1
   62f52: 4281         	cmp	r1, r0
   62f54: dd12         	ble	0x62f7c <rom+0x62f7c>   @ imm = #0x24
   62f56: 2501         	movs	r5, #0x1
   62f58: 1c30         	adds	r0, r6, #0x0
   62f5a: 1c21         	adds	r1, r4, #0x0
   62f5c: f000 f898    	bl	0x63090 <rom+0x63090>   @ imm = #0x130
   62f60: 1c03         	adds	r3, r0, #0x0
   62f62: 2b00         	cmp	r3, #0x0
   62f64: da16         	bge	0x62f94 <rom+0x62f94>   @ imm = #0x2c
   62f66: 2000         	movs	r0, #0x0
   62f68: e026         	b	0x62fb8 <rom+0x62fb8>   @ imm = #0x4c
   62f6a: 0000         	movs	r0, r0
   62f6c: 5e60         	ldrsh	r0, [r4, r1]
   62f6e: 0300         	lsls	r0, r0, #0xc
   62f70: 5e5c         	ldrsh	r4, [r3, r1]
   62f72: 0300         	lsls	r0, r0, #0xc
   62f74: 5e54         	ldrsh	r4, [r2, r1]
   62f76: 0300         	lsls	r0, r0, #0xc
   62f78: 5e64         	ldrsh	r4, [r4, r1]
   62f7a: 0300         	lsls	r0, r0, #0xc
   62f7c: 1c13         	adds	r3, r2, #0x0
   62f7e: 4803         	ldr	r0, [pc, #0xc]          @ 0x62f8c <rom+0x62f8c>
   62f80: 6800         	ldr	r0, [r0]
   62f82: 2800         	cmp	r0, #0x0
   62f84: d004         	beq	0x62f90 <rom+0x62f90>   @ imm = #0x8
   62f86: 6104         	str	r4, [r0, #0x10]
   62f88: 60e0         	str	r0, [r4, #0xc]
   62f8a: e002         	b	0x62f92 <rom+0x62f92>   @ imm = #0x4
   62f8c: 5e58         	ldrsh	r0, [r3, r1]
   62f8e: 0300         	lsls	r0, r0, #0xc
   62f90: 60e5         	str	r5, [r4, #0xc]
   62f92: 6125         	str	r5, [r4, #0x10]
   62f94: 4a0a         	ldr	r2, [pc, #0x28]         @ 0x62fc0 <rom+0x62fc0>
   62f96: 20c4         	movs	r0, #0xc4
   62f98: 1c19         	adds	r1, r3, #0x0
   62f9a: 4341         	muls	r1, r0, r1
   62f9c: 6810         	ldr	r0, [r2]
   62f9e: 1840         	adds	r0, r0, r1
   62fa0: 60a0         	str	r0, [r4, #0x8]
   62fa2: 6066         	str	r6, [r4, #0x4]
   62fa4: 6023         	str	r3, [r4]
   62fa6: 4807         	ldr	r0, [pc, #0x1c]         @ 0x62fc4 <rom+0x62fc4>
   62fa8: 6004         	str	r4, [r0]
   62faa: 2d00         	cmp	r5, #0x0
   62fac: d103         	bne	0x62fb6 <rom+0x62fb6>   @ imm = #0x6
   62fae: 4906         	ldr	r1, [pc, #0x18]         @ 0x62fc8 <rom+0x62fc8>
   62fb0: 6808         	ldr	r0, [r1]
   62fb2: 1980         	adds	r0, r0, r6
   62fb4: 6008         	str	r0, [r1]
   62fb6: 1c20         	adds	r0, r4, #0x0
   62fb8: bc70         	pop	{r4, r5, r6}
   62fba: bc02         	pop	{r1}
   62fbc: 4708         	bx	r1
   62fbe: 0000         	movs	r0, r0
   62fc0: 5e68         	ldrsh	r0, [r5, r1]
   62fc2: 0300         	lsls	r0, r0, #0xc
   62fc4: 5e58         	ldrsh	r0, [r3, r1]
   62fc6: 0300         	lsls	r0, r0, #0xc
   62fc8: 5e64         	ldrsh	r4, [r4, r1]
   62fca: 0300         	lsls	r0, r0, #0xc
   62fcc: b500         	push	{lr}
   62fce: 2200         	movs	r2, #0x0
   62fd0: 4801         	ldr	r0, [pc, #0x4]          @ 0x62fd8 <rom+0x62fd8>
   62fd2: 6801         	ldr	r1, [r0]
   62fd4: e010         	b	0x62ff8 <rom+0x62ff8>   @ imm = #0x20
   62fd6: 0000         	movs	r0, r0
   62fd8: 5e54         	ldrsh	r4, [r2, r1]
   62fda: 0300         	lsls	r0, r0, #0xc
   62fdc: 2aff         	cmp	r2, #0xff
   62fde: d907         	bls	0x62ff0 <rom+0x62ff0>   @ imm = #0xe
   62fe0: 4802         	ldr	r0, [pc, #0x8]          @ 0x62fec <rom+0x62fec>
   62fe2: f7f4 fdbd    	bl	0x57b60 <rom+0x57b60>   @ imm = #-0xb486
   62fe6: 2000         	movs	r0, #0x0
   62fe8: e00a         	b	0x63000 <rom+0x63000>   @ imm = #0x14
   62fea: 0000         	movs	r0, r0
   62fec: 5eb0         	ldrsh	r0, [r6, r2]
   62fee: 0875         	lsrs	r5, r6, #0x1
   62ff0: 1c50         	adds	r0, r2, #0x1
   62ff2: 0400         	lsls	r0, r0, #0x10
   62ff4: 0c02         	lsrs	r2, r0, #0x10
   62ff6: 3114         	adds	r1, #0x14
   62ff8: 6888         	ldr	r0, [r1, #0x8]
   62ffa: 2800         	cmp	r0, #0x0
   62ffc: d1ee         	bne	0x62fdc <rom+0x62fdc>   @ imm = #-0x24
   62ffe: 1c08         	adds	r0, r1, #0x0
   63000: bc02         	pop	{r1}
   63002: 4708         	bx	r1
   63004: b5f0         	push	{r4, r5, r6, r7, lr}
   63006: b081         	sub	sp, #0x4
   63008: 1c06         	adds	r6, r0, #0x0
   6300a: 68b5         	ldr	r5, [r6, #0x8]
   6300c: 6874         	ldr	r4, [r6, #0x4]
   6300e: 68f1         	ldr	r1, [r6, #0xc]
   63010: 6937         	ldr	r7, [r6, #0x10]
   63012: 1c20         	adds	r0, r4, #0x0
   63014: 3c01         	subs	r4, #0x1
   63016: 2800         	cmp	r0, #0x0
   63018: d009         	beq	0x6302e <rom+0x6302e>   @ imm = #0x12
   6301a: 1c28         	adds	r0, r5, #0x0
   6301c: 9100         	str	r1, [sp]
   6301e: f7f5 fc55    	bl	0x588cc <rom+0x588cc>   @ imm = #-0xa756
   63022: 35c4         	adds	r5, #0xc4
   63024: 1c20         	adds	r0, r4, #0x0
   63026: 3c01         	subs	r4, #0x1
   63028: 9900         	ldr	r1, [sp]
   6302a: 2800         	cmp	r0, #0x0
   6302c: d1f5         	bne	0x6301a <rom+0x6301a>   @ imm = #-0x16
   6302e: 4a06         	ldr	r2, [pc, #0x18]         @ 0x63048 <rom+0x63048>
   63030: 6810         	ldr	r0, [r2]
   63032: 42b0         	cmp	r0, r6
   63034: d101         	bne	0x6303a <rom+0x6303a>   @ imm = #0x2
   63036: 68f0         	ldr	r0, [r6, #0xc]
   63038: 6010         	str	r0, [r2]
   6303a: 2900         	cmp	r1, #0x0
   6303c: d10c         	bne	0x63058 <rom+0x63058>   @ imm = #0x18
   6303e: 2f00         	cmp	r7, #0x0
   63040: d104         	bne	0x6304c <rom+0x6304c>   @ imm = #0x8
   63042: f7ff ff27    	bl	0x62e94 <rom+0x62e94>   @ imm = #-0x1b2
   63046: e011         	b	0x6306c <rom+0x6306c>   @ imm = #0x22
   63048: 5e58         	ldrsh	r0, [r3, r1]
   6304a: 0300         	lsls	r0, r0, #0xc
   6304c: 4801         	ldr	r0, [pc, #0x4]          @ 0x63054 <rom+0x63054>
   6304e: 6007         	str	r7, [r0]
   63050: 60f9         	str	r1, [r7, #0xc]
   63052: e00b         	b	0x6306c <rom+0x6306c>   @ imm = #0x16
   63054: 5e60         	ldrsh	r0, [r4, r1]
   63056: 0300         	lsls	r0, r0, #0xc
   63058: 610f         	str	r7, [r1, #0x10]
   6305a: 2f00         	cmp	r7, #0x0
   6305c: d001         	beq	0x63062 <rom+0x63062>   @ imm = #0x2
   6305e: 60f9         	str	r1, [r7, #0xc]
   63060: e004         	b	0x6306c <rom+0x6306c>   @ imm = #0x8
   63062: 4805         	ldr	r0, [pc, #0x14]         @ 0x63078 <rom+0x63078>
   63064: 6801         	ldr	r1, [r0]
   63066: 6872         	ldr	r2, [r6, #0x4]
   63068: 1a89         	subs	r1, r1, r2
   6306a: 6001         	str	r1, [r0]
   6306c: 2000         	movs	r0, #0x0
   6306e: 60b0         	str	r0, [r6, #0x8]
   63070: b001         	add	sp, #0x4
   63072: bcf0         	pop	{r4, r5, r6, r7}
   63074: bc01         	pop	{r0}
   63076: 4700         	bx	r0
   63078: 5e64         	ldrsh	r4, [r4, r1]
   6307a: 0300         	lsls	r0, r0, #0xc
   6307c: 4803         	ldr	r0, [pc, #0xc]          @ 0x6308c <rom+0x6308c>
   6307e: 6800         	ldr	r0, [r0]
   63080: 2800         	cmp	r0, #0x0
   63082: d002         	beq	0x6308a <rom+0x6308a>   @ imm = #0x4
   63084: 6900         	ldr	r0, [r0, #0x10]
   63086: 2800         	cmp	r0, #0x0
   63088: d1fc         	bne	0x63084 <rom+0x63084>   @ imm = #-0x8
   6308a: 4770         	bx	lr
   6308c: 5e60         	ldrsh	r0, [r4, r1]
   6308e: 0300         	lsls	r0, r0, #0xc
   63090: b5f0         	push	{r4, r5, r6, r7, lr}
   63092: 1c05         	adds	r5, r0, #0x0
   63094: 1c0e         	adds	r6, r1, #0x0
   63096: 4804         	ldr	r0, [pc, #0x10]         @ 0x630a8 <rom+0x630a8>
   63098: 6803         	ldr	r3, [r0]
   6309a: 2700         	movs	r7, #0x0
   6309c: 6819         	ldr	r1, [r3]
   6309e: 4684         	mov	r12, r0
   630a0: 42a9         	cmp	r1, r5
   630a2: db03         	blt	0x630ac <rom+0x630ac>   @ imm = #0x6
   630a4: 2701         	movs	r7, #0x1
   630a6: e01a         	b	0x630de <rom+0x630de>   @ imm = #0x34
   630a8: 5e60         	ldrsh	r0, [r4, r1]
   630aa: 0300         	lsls	r0, r0, #0xc
   630ac: 691c         	ldr	r4, [r3, #0x10]
   630ae: 2c00         	cmp	r4, #0x0
   630b0: d005         	beq	0x630be <rom+0x630be>   @ imm = #0xa
   630b2: 6858         	ldr	r0, [r3, #0x4]
   630b4: 1808         	adds	r0, r1, r0
   630b6: 6821         	ldr	r1, [r4]
   630b8: 1a09         	subs	r1, r1, r0
   630ba: 42a9         	cmp	r1, r5
   630bc: da11         	bge	0x630e2 <rom+0x630e2>   @ imm = #0x22
   630be: 1c23         	adds	r3, r4, #0x0
   630c0: 2b00         	cmp	r3, #0x0
   630c2: d00c         	beq	0x630de <rom+0x630de>   @ imm = #0x18
   630c4: 42a9         	cmp	r1, r5
   630c6: da0c         	bge	0x630e2 <rom+0x630e2>   @ imm = #0x18
   630c8: 691a         	ldr	r2, [r3, #0x10]
   630ca: 1c14         	adds	r4, r2, #0x0
   630cc: 2a00         	cmp	r2, #0x0
   630ce: d0f6         	beq	0x630be <rom+0x630be>   @ imm = #-0x14
   630d0: 6818         	ldr	r0, [r3]
   630d2: 6859         	ldr	r1, [r3, #0x4]
   630d4: 1840         	adds	r0, r0, r1
   630d6: 6811         	ldr	r1, [r2]
   630d8: 1a09         	subs	r1, r1, r0
   630da: 42a9         	cmp	r1, r5
   630dc: dbef         	blt	0x630be <rom+0x630be>   @ imm = #-0x22
   630de: 42a9         	cmp	r1, r5
   630e0: db0b         	blt	0x630fa <rom+0x630fa>   @ imm = #0x16
   630e2: 2f00         	cmp	r7, #0x0
   630e4: d109         	bne	0x630fa <rom+0x630fa>   @ imm = #0x12
   630e6: 60f3         	str	r3, [r6, #0xc]
   630e8: 6918         	ldr	r0, [r3, #0x10]
   630ea: 6130         	str	r0, [r6, #0x10]
   630ec: 6918         	ldr	r0, [r3, #0x10]
   630ee: 60c6         	str	r6, [r0, #0xc]
   630f0: 611e         	str	r6, [r3, #0x10]
   630f2: 6818         	ldr	r0, [r3]
   630f4: 6859         	ldr	r1, [r3, #0x4]
   630f6: 1840         	adds	r0, r0, r1
   630f8: e00b         	b	0x63112 <rom+0x63112>   @ imm = #0x16
   630fa: 2f01         	cmp	r7, #0x1
   630fc: d002         	beq	0x63104 <rom+0x63104>   @ imm = #0x4
   630fe: 2001         	movs	r0, #0x1
   63100: 4240         	rsbs	r0, r0, #0
   63102: e006         	b	0x63112 <rom+0x63112>   @ imm = #0xc
   63104: 60de         	str	r6, [r3, #0xc]
   63106: 6133         	str	r3, [r6, #0x10]
   63108: 2000         	movs	r0, #0x0
   6310a: 60f0         	str	r0, [r6, #0xc]
   6310c: 4660         	mov	r0, r12
   6310e: 6006         	str	r6, [r0]
   63110: 2000         	movs	r0, #0x0
   63112: bcf0         	pop	{r4, r5, r6, r7}
   63114: bc02         	pop	{r1}
   63116: 4708         	bx	r1
   63118: b530         	push	{r4, r5, lr}
   6311a: 1c05         	adds	r5, r0, #0x0
   6311c: 2200         	movs	r2, #0x0
   6311e: 6868         	ldr	r0, [r5, #0x4]
   63120: 4282         	cmp	r2, r0
   63122: da10         	bge	0x63146 <rom+0x63146>   @ imm = #0x20
   63124: 0410         	lsls	r0, r2, #0x10
   63126: 1404         	asrs	r4, r0, #0x10
   63128: 1c28         	adds	r0, r5, #0x0
   6312a: 1c21         	adds	r1, r4, #0x0
   6312c: f000 f842    	bl	0x631b4 <rom+0x631b4>   @ imm = #0x84
   63130: 2800         	cmp	r0, #0x0
   63132: d001         	beq	0x63138 <rom+0x63138>   @ imm = #0x2
   63134: f7f5 f9d2    	bl	0x584dc <rom+0x584dc>   @ imm = #-0xac5c
   63138: 1c60         	adds	r0, r4, #0x1
   6313a: 0400         	lsls	r0, r0, #0x10
   6313c: 0c02         	lsrs	r2, r0, #0x10
   6313e: 1400         	asrs	r0, r0, #0x10
   63140: 6869         	ldr	r1, [r5, #0x4]
   63142: 4288         	cmp	r0, r1
   63144: dbee         	blt	0x63124 <rom+0x63124>   @ imm = #-0x24
   63146: bc30         	pop	{r4, r5}
   63148: bc01         	pop	{r0}
   6314a: 4700         	bx	r0
   6314c: b530         	push	{r4, r5, lr}
   6314e: 1c05         	adds	r5, r0, #0x0
   63150: 2200         	movs	r2, #0x0
   63152: 6868         	ldr	r0, [r5, #0x4]
   63154: 4282         	cmp	r2, r0
   63156: da10         	bge	0x6317a <rom+0x6317a>   @ imm = #0x20
   63158: 0410         	lsls	r0, r2, #0x10
   6315a: 1404         	asrs	r4, r0, #0x10
   6315c: 1c28         	adds	r0, r5, #0x0
   6315e: 1c21         	adds	r1, r4, #0x0
   63160: f000 f828    	bl	0x631b4 <rom+0x631b4>   @ imm = #0x50
   63164: 2800         	cmp	r0, #0x0
   63166: d001         	beq	0x6316c <rom+0x6316c>   @ imm = #0x2
   63168: f7f5 fb18    	bl	0x5879c <rom+0x5879c>   @ imm = #-0xa9d0
   6316c: 1c60         	adds	r0, r4, #0x1
   6316e: 0400         	lsls	r0, r0, #0x10
   63170: 0c02         	lsrs	r2, r0, #0x10
   63172: 1400         	asrs	r0, r0, #0x10
   63174: 6869         	ldr	r1, [r5, #0x4]
   63176: 4288         	cmp	r0, r1
   63178: dbee         	blt	0x63158 <rom+0x63158>   @ imm = #-0x24
   6317a: bc30         	pop	{r4, r5}
   6317c: bc01         	pop	{r0}
   6317e: 4700         	bx	r0
   63180: b530         	push	{r4, r5, lr}
   63182: 1c05         	adds	r5, r0, #0x0
   63184: 2200         	movs	r2, #0x0
   63186: 6868         	ldr	r0, [r5, #0x4]
   63188: 4282         	cmp	r2, r0
   6318a: da10         	bge	0x631ae <rom+0x631ae>   @ imm = #0x20
   6318c: 0410         	lsls	r0, r2, #0x10
   6318e: 1404         	asrs	r4, r0, #0x10
   63190: 1c28         	adds	r0, r5, #0x0
   63192: 1c21         	adds	r1, r4, #0x0
   63194: f000 f80e    	bl	0x631b4 <rom+0x631b4>   @ imm = #0x1c
   63198: 2800         	cmp	r0, #0x0
   6319a: d001         	beq	0x631a0 <rom+0x631a0>   @ imm = #0x2
   6319c: f7f5 fb96    	bl	0x588cc <rom+0x588cc>   @ imm = #-0xa8d4
   631a0: 1c60         	adds	r0, r4, #0x1
   631a2: 0400         	lsls	r0, r0, #0x10
   631a4: 0c02         	lsrs	r2, r0, #0x10
   631a6: 1400         	asrs	r0, r0, #0x10
   631a8: 6869         	ldr	r1, [r5, #0x4]
   631aa: 4288         	cmp	r0, r1
   631ac: dbee         	blt	0x6318c <rom+0x6318c>   @ imm = #-0x24
   631ae: bc30         	pop	{r4, r5}
   631b0: bc01         	pop	{r0}
   631b2: 4700         	bx	r0
   631b4: 1c03         	adds	r3, r0, #0x0
   631b6: 6858         	ldr	r0, [r3, #0x4]
   631b8: 4281         	cmp	r1, r0
   631ba: da09         	bge	0x631d0 <rom+0x631d0>   @ imm = #0x12
   631bc: 4a03         	ldr	r2, [pc, #0xc]          @ 0x631cc <rom+0x631cc>
   631be: 6818         	ldr	r0, [r3]
   631c0: 1840         	adds	r0, r0, r1
   631c2: 21c4         	movs	r1, #0xc4
   631c4: 4341         	muls	r1, r0, r1
   631c6: 6810         	ldr	r0, [r2]
   631c8: 1840         	adds	r0, r0, r1
   631ca: e002         	b	0x631d2 <rom+0x631d2>   @ imm = #0x4
   631cc: 5e68         	ldrsh	r0, [r5, r1]
   631ce: 0300         	lsls	r0, r0, #0xc
   631d0: 2000         	movs	r0, #0x0
   631d2: 4770         	bx	lr
   631d4: b5f0         	push	{r4, r5, r6, r7, lr}
   631d6: 4647         	mov	r7, r8
   631d8: b480         	push	{r7}
   631da: 1c05         	adds	r5, r0, #0x0
   631dc: 4688         	mov	r8, r1
   631de: 1c16         	adds	r6, r2, #0x0
   631e0: 1c1c         	adds	r4, r3, #0x0
   631e2: 9f06         	ldr	r7, [sp, #0x18]
   631e4: 2002         	movs	r0, #0x2
   631e6: 4240         	rsbs	r0, r0, #0
   631e8: 4006         	ands	r6, r0
   631ea: 4004         	ands	r4, r0
   631ec: 0060         	lsls	r0, r4, #0x1
   631ee: 4378         	muls	r0, r7, r0
   631f0: f7f7 f928    	bl	0x5a444 <rom+0x5a444>   @ imm = #-0x8db0
   631f4: 6128         	str	r0, [r5, #0x10]
   631f6: 80ae         	strh	r6, [r5, #0x4]
   631f8: 80ec         	strh	r4, [r5, #0x6]
   631fa: 812f         	strh	r7, [r5, #0x8]
   631fc: 4641         	mov	r1, r8
   631fe: 6029         	str	r1, [r5]
   63200: 6800         	ldr	r0, [r0]
   63202: 60e8         	str	r0, [r5, #0xc]
   63204: bc08         	pop	{r3}
   63206: 4698         	mov	r8, r3
   63208: bcf0         	pop	{r4, r5, r6, r7}
   6320a: bc01         	pop	{r0}
   6320c: 4700         	bx	r0
   6320e: 0000         	movs	r0, r0
   63210: b530         	push	{r4, r5, lr}
   63212: 1c04         	adds	r4, r0, #0x0
   63214: 1c0d         	adds	r5, r1, #0x0
   63216: 1c11         	adds	r1, r2, #0x0
   63218: 2208         	movs	r2, #0x8
   6321a: 5ea0         	ldrsh	r0, [r4, r2]
   6321c: 4281         	cmp	r1, r0
   6321e: da0c         	bge	0x6323a <rom+0x6323a>   @ imm = #0x18
   63220: 4b07         	ldr	r3, [pc, #0x1c]         @ 0x63240 <rom+0x63240>
   63222: 88e2         	ldrh	r2, [r4, #0x6]
   63224: 4351         	muls	r1, r2, r1
   63226: 0049         	lsls	r1, r1, #0x1
   63228: 68e0         	ldr	r0, [r4, #0xc]
   6322a: 1840         	adds	r0, r0, r1
   6322c: 88a4         	ldrh	r4, [r4, #0x4]
   6322e: 0061         	lsls	r1, r4, #0x1
   63230: 1869         	adds	r1, r5, r1
   63232: 0052         	lsls	r2, r2, #0x1
   63234: 681b         	ldr	r3, [r3]
   63236: f002 fd05    	bl	0x65c44 <rom+0x65c44>   @ imm = #0x2a0a
   6323a: bc30         	pop	{r4, r5}
   6323c: bc01         	pop	{r0}
   6323e: 4700         	bx	r0
   63240: d998         	bls	0x63174 <rom+0x63174>   @ imm = #-0xd0
   63242: 0807         	lsrs	r7, r0, #0x20
