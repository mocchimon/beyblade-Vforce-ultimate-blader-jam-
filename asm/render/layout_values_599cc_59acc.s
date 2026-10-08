 80599cc: 0600         	lsls	r0, r0, #0x18
 80599ce: 0e00         	lsrs	r0, r0, #0x18
 80599d0: 1c01         	adds	r1, r0, #0x0
 80599d2: 2801         	cmp	r0, #0x1
 80599d4: d00e         	beq	0x80599f4 <rom+0x599f4> @ imm = #0x1c
 80599d6: 2801         	cmp	r0, #0x1
 80599d8: dc02         	bgt	0x80599e0 <rom+0x599e0> @ imm = #0x4
 80599da: 2800         	cmp	r0, #0x0
 80599dc: d005         	beq	0x80599ea <rom+0x599ea> @ imm = #0xa
 80599de: e012         	b	0x8059a06 <rom+0x59a06> @ imm = #0x24
 80599e0: 2902         	cmp	r1, #0x2
 80599e2: d00b         	beq	0x80599fc <rom+0x599fc> @ imm = #0x16
 80599e4: 2903         	cmp	r1, #0x3
 80599e6: d00d         	beq	0x8059a04 <rom+0x59a04> @ imm = #0x1a
 80599e8: e00d         	b	0x8059a06 <rom+0x59a06> @ imm = #0x1a
 80599ea: 4801         	ldr	r0, [pc, #0x4]          @ 0x80599f0 <rom+0x599f0>
 80599ec: e00b         	b	0x8059a06 <rom+0x59a06> @ imm = #0x16
 80599ee: 0000         	movs	r0, r0
 80599f0: 0010         	movs	r0, r2
 80599f2: 0400         	lsls	r0, r0, #0x10
 80599f4: 4800         	ldr	r0, [pc, #0x0]          @ 0x80599f8 <rom+0x599f8>
 80599f6: e006         	b	0x8059a06 <rom+0x59a06> @ imm = #0xc
 80599f8: 0014         	movs	r4, r2
 80599fa: 0400         	lsls	r0, r0, #0x10
 80599fc: 4800         	ldr	r0, [pc, #0x0]          @ 0x8059a00 <rom+0x59a00>
 80599fe: e002         	b	0x8059a06 <rom+0x59a06> @ imm = #0x4
 8059a00: 0018         	movs	r0, r3
 8059a02: 0400         	lsls	r0, r0, #0x10
 8059a04: 4800         	ldr	r0, [pc, #0x0]          @ 0x8059a08 <rom+0x59a08>
 8059a06: 4770         	bx	lr
 8059a08: 001c         	movs	r4, r3
 8059a0a: 0400         	lsls	r0, r0, #0x10
 8059a0c: 0600         	lsls	r0, r0, #0x18
 8059a0e: 0e00         	lsrs	r0, r0, #0x18
 8059a10: 1c01         	adds	r1, r0, #0x0
 8059a12: 2801         	cmp	r0, #0x1
 8059a14: d00e         	beq	0x8059a34 <rom+0x59a34> @ imm = #0x1c
 8059a16: 2801         	cmp	r0, #0x1
 8059a18: dc02         	bgt	0x8059a20 <rom+0x59a20> @ imm = #0x4
 8059a1a: 2800         	cmp	r0, #0x0
 8059a1c: d005         	beq	0x8059a2a <rom+0x59a2a> @ imm = #0xa
 8059a1e: e012         	b	0x8059a46 <rom+0x59a46> @ imm = #0x24
 8059a20: 2902         	cmp	r1, #0x2
 8059a22: d00b         	beq	0x8059a3c <rom+0x59a3c> @ imm = #0x16
 8059a24: 2903         	cmp	r1, #0x3
 8059a26: d00d         	beq	0x8059a44 <rom+0x59a44> @ imm = #0x1a
 8059a28: e00d         	b	0x8059a46 <rom+0x59a46> @ imm = #0x1a
 8059a2a: 4801         	ldr	r0, [pc, #0x4]          @ 0x8059a30 <rom+0x59a30>
 8059a2c: e00b         	b	0x8059a46 <rom+0x59a46> @ imm = #0x16
 8059a2e: 0000         	movs	r0, r0
 8059a30: 0012         	movs	r2, r2
 8059a32: 0400         	lsls	r0, r0, #0x10
 8059a34: 4800         	ldr	r0, [pc, #0x0]          @ 0x8059a38 <rom+0x59a38>
 8059a36: e006         	b	0x8059a46 <rom+0x59a46> @ imm = #0xc
 8059a38: 0016         	movs	r6, r2
 8059a3a: 0400         	lsls	r0, r0, #0x10
 8059a3c: 4800         	ldr	r0, [pc, #0x0]          @ 0x8059a40 <rom+0x59a40>
 8059a3e: e002         	b	0x8059a46 <rom+0x59a46> @ imm = #0x4
 8059a40: 001a         	movs	r2, r3
 8059a42: 0400         	lsls	r0, r0, #0x10
 8059a44: 4800         	ldr	r0, [pc, #0x0]          @ 0x8059a48 <rom+0x59a48>
 8059a46: 4770         	bx	lr
 8059a48: 001e         	movs	r6, r3
 8059a4a: 0400         	lsls	r0, r0, #0x10
 8059a4c: 0600         	lsls	r0, r0, #0x18
 8059a4e: 0e00         	lsrs	r0, r0, #0x18
 8059a50: 1c01         	adds	r1, r0, #0x0
 8059a52: 2801         	cmp	r0, #0x1
 8059a54: d00e         	beq	0x8059a74 <rom+0x59a74> @ imm = #0x1c
 8059a56: 2801         	cmp	r0, #0x1
 8059a58: dc02         	bgt	0x8059a60 <rom+0x59a60> @ imm = #0x4
 8059a5a: 2800         	cmp	r0, #0x0
 8059a5c: d005         	beq	0x8059a6a <rom+0x59a6a> @ imm = #0xa
 8059a5e: e012         	b	0x8059a86 <rom+0x59a86> @ imm = #0x24
 8059a60: 2902         	cmp	r1, #0x2
 8059a62: d00b         	beq	0x8059a7c <rom+0x59a7c> @ imm = #0x16
 8059a64: 2903         	cmp	r1, #0x3
 8059a66: d00d         	beq	0x8059a84 <rom+0x59a84> @ imm = #0x1a
 8059a68: e00d         	b	0x8059a86 <rom+0x59a86> @ imm = #0x1a
 8059a6a: 4801         	ldr	r0, [pc, #0x4]          @ 0x8059a70 <rom+0x59a70>
 8059a6c: e00b         	b	0x8059a86 <rom+0x59a86> @ imm = #0x16
 8059a6e: 0000         	movs	r0, r0
 8059a70: 0008         	movs	r0, r1
 8059a72: 0400         	lsls	r0, r0, #0x10
 8059a74: 4800         	ldr	r0, [pc, #0x0]          @ 0x8059a78 <rom+0x59a78>
 8059a76: e006         	b	0x8059a86 <rom+0x59a86> @ imm = #0xc
 8059a78: 000a         	movs	r2, r1
 8059a7a: 0400         	lsls	r0, r0, #0x10
 8059a7c: 4800         	ldr	r0, [pc, #0x0]          @ 0x8059a80 <rom+0x59a80>
 8059a7e: e002         	b	0x8059a86 <rom+0x59a86> @ imm = #0x4
 8059a80: 000c         	movs	r4, r1
 8059a82: 0400         	lsls	r0, r0, #0x10
 8059a84: 4800         	ldr	r0, [pc, #0x0]          @ 0x8059a88 <rom+0x59a88>
 8059a86: 4770         	bx	lr
 8059a88: 000e         	movs	r6, r1
 8059a8a: 0400         	lsls	r0, r0, #0x10
 8059a8c: 1c0b         	adds	r3, r1, #0x0
 8059a8e: 0600         	lsls	r0, r0, #0x18
 8059a90: 0e00         	lsrs	r0, r0, #0x18
 8059a92: 2802         	cmp	r0, #0x2
 8059a94: d002         	beq	0x8059a9c <rom+0x59a9c> @ imm = #0x4
 8059a96: 2803         	cmp	r0, #0x3
 8059a98: d00e         	beq	0x8059ab8 <rom+0x59ab8> @ imm = #0x1c
 8059a9a: e017         	b	0x8059acc <rom+0x59acc> @ imm = #0x2e
 8059a9c: 4803         	ldr	r0, [pc, #0xc]          @ 0x8059aac <rom+0x59aac>
 8059a9e: 8003         	strh	r3, [r0]
 8059aa0: 4903         	ldr	r1, [pc, #0xc]          @ 0x8059ab0 <rom+0x59ab0>
 8059aa2: 1418         	asrs	r0, r3, #0x10
 8059aa4: 8008         	strh	r0, [r1]
 8059aa6: 4803         	ldr	r0, [pc, #0xc]          @ 0x8059ab4 <rom+0x59ab4>
 8059aa8: e00c         	b	0x8059ac4 <rom+0x59ac4> @ imm = #0x18
 8059aaa: 0000         	movs	r0, r0
 8059aac: 0028         	movs	r0, r5
 8059aae: 0400         	lsls	r0, r0, #0x10
 8059ab0: 002a         	movs	r2, r5
 8059ab2: 0400         	lsls	r0, r0, #0x10
 8059ab4: 002c         	movs	r4, r5
 8059ab6: 0400         	lsls	r0, r0, #0x10
 8059ab8: 4805         	ldr	r0, [pc, #0x14]         @ 0x8059ad0 <rom+0x59ad0>
 8059aba: 8003         	strh	r3, [r0]
 8059abc: 4905         	ldr	r1, [pc, #0x14]         @ 0x8059ad4 <rom+0x59ad4>
 8059abe: 1418         	asrs	r0, r3, #0x10
 8059ac0: 8008         	strh	r0, [r1]
 8059ac2: 4805         	ldr	r0, [pc, #0x14]         @ 0x8059ad8 <rom+0x59ad8>
 8059ac4: 8002         	strh	r2, [r0]
 8059ac6: 3104         	adds	r1, #0x4
 8059ac8: 1410         	asrs	r0, r2, #0x10
 8059aca: 8008         	strh	r0, [r1]
 8059acc: 4770         	bx	lr
