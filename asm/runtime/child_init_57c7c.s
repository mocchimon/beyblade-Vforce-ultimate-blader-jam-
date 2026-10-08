   57c7c: b5f0         	push	{r4, r5, r6, r7, lr}
   57c7e: b081         	sub	sp, #0x4
   57c80: 1c07         	adds	r7, r0, #0x0
   57c82: 9c06         	ldr	r4, [sp, #0x18]
   57c84: 9d07         	ldr	r5, [sp, #0x1c]
   57c86: 9e08         	ldr	r6, [sp, #0x20]
   57c88: 6039         	str	r1, [r7]
   57c8a: 4846         	ldr	r0, [pc, #0x118]        @ 0x57da4 <rom+0x57da4>
   57c8c: 6800         	ldr	r0, [r0]
   57c8e: 65b8         	str	r0, [r7, #0x58]
   57c90: 63fa         	str	r2, [r7, #0x3c]
   57c92: 673e         	str	r6, [r7, #0x70]
   57c94: 021b         	lsls	r3, r3, #0x8
   57c96: 607b         	str	r3, [r7, #0x4]
   57c98: 0224         	lsls	r4, r4, #0x8
   57c9a: 60bc         	str	r4, [r7, #0x8]
   57c9c: 022d         	lsls	r5, r5, #0x8
   57c9e: 60fd         	str	r5, [r7, #0xc]
   57ca0: 2500         	movs	r5, #0x0
   57ca2: 2400         	movs	r4, #0x0
   57ca4: 82fc         	strh	r4, [r7, #0x16]
   57ca6: 2080         	movs	r0, #0x80
   57ca8: 0040         	lsls	r0, r0, #0x1
   57caa: 8278         	strh	r0, [r7, #0x12]
   57cac: 82b8         	strh	r0, [r7, #0x14]
   57cae: 1c38         	adds	r0, r7, #0x0
   57cb0: 30a0         	adds	r0, #0xa0
   57cb2: 8004         	strh	r4, [r0]
   57cb4: 3002         	adds	r0, #0x2
   57cb6: 8004         	strh	r4, [r0]
   57cb8: 3002         	adds	r0, #0x2
   57cba: 7005         	strb	r5, [r0]
   57cbc: 3001         	adds	r0, #0x1
   57cbe: 7005         	strb	r5, [r0]
   57cc0: 643c         	str	r4, [r7, #0x40]
   57cc2: 647c         	str	r4, [r7, #0x44]
   57cc4: 64bc         	str	r4, [r7, #0x48]
   57cc6: 64fc         	str	r4, [r7, #0x4c]
   57cc8: 653c         	str	r4, [r7, #0x50]
   57cca: 657c         	str	r4, [r7, #0x54]
   57ccc: 2010         	movs	r0, #0x10
   57cce: 66b8         	str	r0, [r7, #0x68]
   57cd0: 833c         	strh	r4, [r7, #0x18]
   57cd2: 667c         	str	r4, [r7, #0x64]
   57cd4: 847c         	strh	r4, [r7, #0x22]
   57cd6: 1c3b         	adds	r3, r7, #0x0
   57cd8: 3360         	adds	r3, #0x60
   57cda: 4833         	ldr	r0, [pc, #0xcc]         @ 0x57da8 <rom+0x57da8>
   57cdc: 1c02         	adds	r2, r0, #0x0
   57cde: 8818         	ldrh	r0, [r3]
   57ce0: 4310         	orrs	r0, r2
   57ce2: 8018         	strh	r0, [r3]
   57ce4: 8b78         	ldrh	r0, [r7, #0x1a]
   57ce6: 4310         	orrs	r0, r2
   57ce8: 8378         	strh	r0, [r7, #0x1a]
   57cea: 83bc         	strh	r4, [r7, #0x1c]
   57cec: 83fc         	strh	r4, [r7, #0x1e]
   57cee: 843c         	strh	r4, [r7, #0x20]
   57cf0: 85bc         	strh	r4, [r7, #0x2c]
   57cf2: 8df8         	ldrh	r0, [r7, #0x2e]
   57cf4: 4302         	orrs	r2, r0
   57cf6: 85fa         	strh	r2, [r7, #0x2e]
   57cf8: 7908         	ldrb	r0, [r1, #0x4]
   57cfa: 7438         	strb	r0, [r7, #0x10]
   57cfc: 7948         	ldrb	r0, [r1, #0x5]
   57cfe: 7478         	strb	r0, [r7, #0x11]
   57d00: 798a         	ldrb	r2, [r1, #0x6]
   57d02: 1c38         	adds	r0, r7, #0x0
   57d04: 3030         	adds	r0, #0x30
   57d06: 7002         	strb	r2, [r0]
   57d08: 6888         	ldr	r0, [r1, #0x8]
   57d0a: 8578         	strh	r0, [r7, #0x2a]
   57d0c: 79ca         	ldrb	r2, [r1, #0x7]
   57d0e: 1c38         	adds	r0, r7, #0x0
   57d10: 3038         	adds	r0, #0x38
   57d12: 7002         	strb	r2, [r0]
   57d14: 6948         	ldr	r0, [r1, #0x14]
   57d16: 8538         	strh	r0, [r7, #0x28]
   57d18: 1c38         	adds	r0, r7, #0x0
   57d1a: 3031         	adds	r0, #0x31
   57d1c: 7005         	strb	r5, [r0]
   57d1e: 3008         	adds	r0, #0x8
   57d20: 7005         	strb	r5, [r0]
   57d22: 3002         	adds	r0, #0x2
   57d24: 7005         	strb	r5, [r0]
   57d26: 7b08         	ldrb	r0, [r1, #0xc]
   57d28: 1c39         	adds	r1, r7, #0x0
   57d2a: 313a         	adds	r1, #0x3a
   57d2c: 7008         	strb	r0, [r1]
   57d2e: 66fc         	str	r4, [r7, #0x6c]
   57d30: 2101         	movs	r1, #0x1
   57d32: 4249         	rsbs	r1, r1, #0
   57d34: 6779         	str	r1, [r7, #0x74]
   57d36: 67bc         	str	r4, [r7, #0x78]
   57d38: 67fc         	str	r4, [r7, #0x7c]
   57d3a: 1c38         	adds	r0, r7, #0x0
   57d3c: 3080         	adds	r0, #0x80
   57d3e: 6004         	str	r4, [r0]
   57d40: 3004         	adds	r0, #0x4
   57d42: 6001         	str	r1, [r0]
   57d44: 3004         	adds	r0, #0x4
   57d46: 6004         	str	r4, [r0]
   57d48: 3004         	adds	r0, #0x4
   57d4a: 7005         	strb	r5, [r0]
   57d4c: 3001         	adds	r0, #0x1
   57d4e: 7005         	strb	r5, [r0]
   57d50: 300b         	adds	r0, #0xb
   57d52: 7005         	strb	r5, [r0]
   57d54: 3808         	subs	r0, #0x8
   57d56: 6004         	str	r4, [r0]
   57d58: 3004         	adds	r0, #0x4
   57d5a: 6004         	str	r4, [r0]
   57d5c: 301c         	adds	r0, #0x1c
   57d5e: 6004         	str	r4, [r0]
   57d60: 3004         	adds	r0, #0x4
   57d62: 6004         	str	r4, [r0]
   57d64: 7c38         	ldrb	r0, [r7, #0x10]
   57d66: 0841         	lsrs	r1, r0, #0x1
   57d68: 7c7a         	ldrb	r2, [r7, #0x11]
   57d6a: 1c38         	adds	r0, r7, #0x0
   57d6c: 2300         	movs	r3, #0x0
   57d6e: f000 fc63    	bl	0x58638 <rom+0x58638>   @ imm = #0x8c6
   57d72: 7c3b         	ldrb	r3, [r7, #0x10]
   57d74: 7c78         	ldrb	r0, [r7, #0x11]
   57d76: 9000         	str	r0, [sp]
   57d78: 1c38         	adds	r0, r7, #0x0
   57d7a: 2100         	movs	r1, #0x0
   57d7c: 2200         	movs	r2, #0x0
   57d7e: f000 fc4d    	bl	0x5861c <rom+0x5861c>   @ imm = #0x89a
   57d82: 1c38         	adds	r0, r7, #0x0
   57d84: 30b8         	adds	r0, #0xb8
   57d86: 6004         	str	r4, [r0]
   57d88: 3004         	adds	r0, #0x4
   57d8a: 8004         	strh	r4, [r0]
   57d8c: 1c38         	adds	r0, r7, #0x0
   57d8e: 2100         	movs	r1, #0x0
   57d90: f000 fa58    	bl	0x58244 <rom+0x58244>   @ imm = #0x4b0
   57d94: 1c38         	adds	r0, r7, #0x0
   57d96: 30c0         	adds	r0, #0xc0
   57d98: 6004         	str	r4, [r0]
   57d9a: b001         	add	sp, #0x4
   57d9c: bcf0         	pop	{r4, r5, r6, r7}
   57d9e: bc01         	pop	{r0}
   57da0: 4700         	bx	r0
   57da2: 0000         	movs	r0, r0
