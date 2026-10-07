
00000000 <rom>:
   62e94: b570         	push	{r4, r5, r6, lr}
   62e96: b081         	sub	sp, #0x4
   62e98: 4817         	ldr	r0, [pc, #0x5c]         @ 0x62ef8 <rom+0x62ef8>
   62e9a: 2400         	movs	r4, #0x0
   62e9c: 6004         	str	r4, [r0]
   62e9e: 4817         	ldr	r0, [pc, #0x5c]         @ 0x62efc <rom+0x62efc>
   62ea0: 6004         	str	r4, [r0]
   62ea2: 4817         	ldr	r0, [pc, #0x5c]         @ 0x62f00 <rom+0x62f00>
   62ea4: 6004         	str	r4, [r0]
   62ea6: 20c4         	movs	r0, #0xc4
   62ea8: 0200         	lsls	r0, r0, #0x8
   62eaa: f7f7 facb    	bl	0x5a444 <rom+0x5a444>   @ imm = #-0x8a6a
   62eae: 1c06         	adds	r6, r0, #0x0
   62eb0: 20a0         	movs	r0, #0xa0
   62eb2: 0140         	lsls	r0, r0, #0x5
   62eb4: f7f7 fac6    	bl	0x5a444 <rom+0x5a444>   @ imm = #-0x8a74
   62eb8: 1c05         	adds	r5, r0, #0x0
   62eba: 2e00         	cmp	r6, #0x0
   62ebc: d102         	bne	0x62ec4 <rom+0x62ec4>   @ imm = #0x4
   62ebe: 4811         	ldr	r0, [pc, #0x44]         @ 0x62f04 <rom+0x62f04>
   62ec0: f7f4 fe4e    	bl	0x57b60 <rom+0x57b60>   @ imm = #-0xb364
   62ec4: 2d00         	cmp	r5, #0x0
   62ec6: d102         	bne	0x62ece <rom+0x62ece>   @ imm = #0x4
   62ec8: 480f         	ldr	r0, [pc, #0x3c]         @ 0x62f08 <rom+0x62f08>
   62eca: f7f4 fe49    	bl	0x57b60 <rom+0x57b60>   @ imm = #-0xb36e
   62ece: 490f         	ldr	r1, [pc, #0x3c]         @ 0x62f0c <rom+0x62f0c>
   62ed0: 6830         	ldr	r0, [r6]
   62ed2: 6008         	str	r0, [r1]
   62ed4: 480e         	ldr	r0, [pc, #0x38]         @ 0x62f10 <rom+0x62f10>
   62ed6: 6829         	ldr	r1, [r5]
   62ed8: 6001         	str	r1, [r0]
   62eda: 480e         	ldr	r0, [pc, #0x38]         @ 0x62f14 <rom+0x62f14>
   62edc: 6004         	str	r4, [r0]
   62ede: 9400         	str	r4, [sp]
   62ee0: 480d         	ldr	r0, [pc, #0x34]         @ 0x62f18 <rom+0x62f18>
   62ee2: 466a         	mov	r2, sp
   62ee4: 6002         	str	r2, [r0]
   62ee6: 6041         	str	r1, [r0, #0x4]
   62ee8: 490c         	ldr	r1, [pc, #0x30]         @ 0x62f1c <rom+0x62f1c>
   62eea: 6081         	str	r1, [r0, #0x8]
   62eec: 6880         	ldr	r0, [r0, #0x8]
   62eee: b001         	add	sp, #0x4
   62ef0: bc70         	pop	{r4, r5, r6}
   62ef2: bc01         	pop	{r0}
   62ef4: 4700         	bx	r0
   62ef6: 0000         	movs	r0, r0
   62ef8: 5e64         	ldrsh	r4, [r4, r1]
   62efa: 0300         	lsls	r0, r0, #0xc
   62efc: 5e5c         	ldrsh	r4, [r3, r1]
   62efe: 0300         	lsls	r0, r0, #0xc
   62f00: 5e60         	ldrsh	r0, [r4, r1]
   62f02: 0300         	lsls	r0, r0, #0xc
   62f04: 5e48         	ldrsh	r0, [r1, r1]
   62f06: 0875         	lsrs	r5, r6, #0x1
   62f08: 5e78         	ldrsh	r0, [r7, r1]
   62f0a: 0875         	lsrs	r5, r6, #0x1
   62f0c: 5e68         	ldrsh	r0, [r5, r1]
   62f0e: 0300         	lsls	r0, r0, #0xc
   62f10: 5e54         	ldrsh	r4, [r2, r1]
   62f12: 0300         	lsls	r0, r0, #0xc
   62f14: 5e58         	ldrsh	r0, [r3, r1]
   62f16: 0300         	lsls	r0, r0, #0xc
   62f18: 00d4         	lsls	r4, r2, #0x3
   62f1a: 0400         	lsls	r0, r0, #0x10
   62f1c: 0500         	lsls	r0, r0, #0x14
   62f1e: 8500         	strh	r0, [r0, #0x28]
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
