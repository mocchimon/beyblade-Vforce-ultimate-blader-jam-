
/tmp/dis.o:	file format elf32-littlearm

Disassembly of section .text:

00000000 <rom>:
   62934: b510         	push	{r4, lr}
   62936: 1c03         	adds	r3, r0, #0x0
   62938: 2400         	movs	r4, #0x0
   6293a: 2001         	movs	r0, #0x1
   6293c: 7598         	strb	r0, [r3, #0x16]
   6293e: 6019         	str	r1, [r3]
   62940: 2000         	movs	r0, #0x0
   62942: 829c         	strh	r4, [r3, #0x14]
   62944: 75d8         	strb	r0, [r3, #0x17]
   62946: 2080         	movs	r0, #0x80
   62948: 0040         	lsls	r0, r0, #0x1
   6294a: 8218         	strh	r0, [r3, #0x10]
   6294c: 3110         	adds	r1, #0x10
   6294e: 6059         	str	r1, [r3, #0x4]
   62950: 2a7f         	cmp	r2, #0x7f
   62952: d900         	bls	0x62956 <rom+0x62956>   @ imm = #0x0
   62954: 227f         	movs	r2, #0x7f
   62956: 4806         	ldr	r0, [pc, #0x18]         @ 0x62970 <rom+0x62970>
   62958: 6801         	ldr	r1, [r0]
   6295a: 0090         	lsls	r0, r2, #0x2
   6295c: 1840         	adds	r0, r0, r1
   6295e: 6800         	ldr	r0, [r0]
   62960: 6098         	str	r0, [r3, #0x8]
   62962: 60dc         	str	r4, [r3, #0xc]
   62964: 61dc         	str	r4, [r3, #0x1c]
   62966: 621c         	str	r4, [r3, #0x20]
   62968: 849c         	strh	r4, [r3, #0x24]
   6296a: bc10         	pop	{r4}
   6296c: bc01         	pop	{r0}
   6296e: 4700         	bx	r0
   62970: 0d98         	lsrs	r0, r3, #0x16
   62972: 0300         	lsls	r0, r0, #0xc
   62974: b570         	push	{r4, r5, r6, lr}
   62976: 2400         	movs	r4, #0x0
   62978: 5f13         	ldrsh	r3, [r2, r4]
   6297a: 009b         	lsls	r3, r3, #0x2
   6297c: 185b         	adds	r3, r3, r1
   6297e: 681c         	ldr	r4, [r3]
   62980: 2500         	movs	r5, #0x0
   62982: 2601         	movs	r6, #0x1
   62984: 7586         	strb	r6, [r0, #0x16]
   62986: 6004         	str	r4, [r0]
   62988: 2300         	movs	r3, #0x0
   6298a: 8285         	strh	r5, [r0, #0x14]
   6298c: 75c3         	strb	r3, [r0, #0x17]
   6298e: 2380         	movs	r3, #0x80
   62990: 005b         	lsls	r3, r3, #0x1
   62992: 8203         	strh	r3, [r0, #0x10]
   62994: 3410         	adds	r4, #0x10
   62996: 6044         	str	r4, [r0, #0x4]
   62998: 4b05         	ldr	r3, [pc, #0x14]         @ 0x629b0 <rom+0x629b0>
   6299a: 681b         	ldr	r3, [r3]
   6299c: 681b         	ldr	r3, [r3]
   6299e: 6083         	str	r3, [r0, #0x8]
   629a0: 60c5         	str	r5, [r0, #0xc]
   629a2: 61c1         	str	r1, [r0, #0x1c]
   629a4: 6202         	str	r2, [r0, #0x20]
   629a6: 8486         	strh	r6, [r0, #0x24]
   629a8: bc70         	pop	{r4, r5, r6}
   629aa: bc01         	pop	{r0}
   629ac: 4700         	bx	r0
   629ae: 0000         	movs	r0, r0
   629b0: 0d98         	lsrs	r0, r3, #0x16
   629b2: 0300         	lsls	r0, r0, #0xc
   629b4: b530         	push	{r4, r5, lr}
   629b6: 1c03         	adds	r3, r0, #0x0
   629b8: 1c0a         	adds	r2, r1, #0x0
   629ba: 480b         	ldr	r0, [pc, #0x2c]         @ 0x629e8 <rom+0x629e8>
   629bc: 6804         	ldr	r4, [r0]
   629be: 480b         	ldr	r0, [pc, #0x2c]         @ 0x629ec <rom+0x629ec>
   629c0: 7801         	ldrb	r1, [r0]
   629c2: 3901         	subs	r1, #0x1
   629c4: 2001         	movs	r0, #0x1
   629c6: 4240         	rsbs	r0, r0, #0
   629c8: 4281         	cmp	r1, r0
   629ca: d019         	beq	0x62a00 <rom+0x62a00>   @ imm = #0x32
   629cc: 4d08         	ldr	r5, [pc, #0x20]         @ 0x629f0 <rom+0x629f0>
   629ce: 7da0         	ldrb	r0, [r4, #0x16]
   629d0: 2800         	cmp	r0, #0x0
   629d2: d10f         	bne	0x629f4 <rom+0x629f4>   @ imm = #0x1e
   629d4: 1c20         	adds	r0, r4, #0x0
   629d6: 1c19         	adds	r1, r3, #0x0
   629d8: f7ff ffcc    	bl	0x62974 <rom+0x62974>   @ imm = #-0x68
   629dc: 6828         	ldr	r0, [r5]
   629de: 61a0         	str	r0, [r4, #0x18]
   629e0: 3001         	adds	r0, #0x1
   629e2: 6028         	str	r0, [r5]
   629e4: 69a0         	ldr	r0, [r4, #0x18]
   629e6: e010         	b	0x62a0a <rom+0x62a0a>   @ imm = #0x20
   629e8: 5e24         	ldrsh	r4, [r4, r0]
   629ea: 0300         	lsls	r0, r0, #0xc
   629ec: 5e04         	ldrsh	r4, [r0, r0]
   629ee: 0300         	lsls	r0, r0, #0xc
   629f0: 0d9c         	lsrs	r4, r3, #0x16
   629f2: 0300         	lsls	r0, r0, #0xc
   629f4: 3428         	adds	r4, #0x28
   629f6: 3901         	subs	r1, #0x1
   629f8: 2001         	movs	r0, #0x1
   629fa: 4240         	rsbs	r0, r0, #0
   629fc: 4281         	cmp	r1, r0
   629fe: d1e6         	bne	0x629ce <rom+0x629ce>   @ imm = #-0x34
   62a00: 4803         	ldr	r0, [pc, #0xc]          @ 0x62a10 <rom+0x62a10>
   62a02: f7f5 f92b    	bl	0x57c5c <rom+0x57c5c>   @ imm = #-0xadaa
   62a06: 2001         	movs	r0, #0x1
   62a08: 4240         	rsbs	r0, r0, #0
   62a0a: bc30         	pop	{r4, r5}
   62a0c: bc02         	pop	{r1}
   62a0e: 4708         	bx	r1
   62a10: 5e20         	ldrsh	r0, [r4, r0]
   62a12: 0875         	lsrs	r5, r6, #0x1
   62a14: b530         	push	{r4, r5, lr}
   62a16: 1c03         	adds	r3, r0, #0x0
   62a18: 1c0a         	adds	r2, r1, #0x0
   62a1a: 480b         	ldr	r0, [pc, #0x2c]         @ 0x62a48 <rom+0x62a48>
   62a1c: 6804         	ldr	r4, [r0]
   62a1e: 480b         	ldr	r0, [pc, #0x2c]         @ 0x62a4c <rom+0x62a4c>
   62a20: 7801         	ldrb	r1, [r0]
   62a22: 3901         	subs	r1, #0x1
   62a24: 2001         	movs	r0, #0x1
   62a26: 4240         	rsbs	r0, r0, #0
   62a28: 4281         	cmp	r1, r0
   62a2a: d019         	beq	0x62a60 <rom+0x62a60>   @ imm = #0x32
   62a2c: 4d08         	ldr	r5, [pc, #0x20]         @ 0x62a50 <rom+0x62a50>
   62a2e: 7da0         	ldrb	r0, [r4, #0x16]
   62a30: 2800         	cmp	r0, #0x0
   62a32: d10f         	bne	0x62a54 <rom+0x62a54>   @ imm = #0x1e
   62a34: 1c20         	adds	r0, r4, #0x0
   62a36: 1c19         	adds	r1, r3, #0x0
   62a38: f7ff ff7c    	bl	0x62934 <rom+0x62934>   @ imm = #-0x108
   62a3c: 6828         	ldr	r0, [r5]
   62a3e: 61a0         	str	r0, [r4, #0x18]
   62a40: 3001         	adds	r0, #0x1
   62a42: 6028         	str	r0, [r5]
   62a44: 69a0         	ldr	r0, [r4, #0x18]
   62a46: e010         	b	0x62a6a <rom+0x62a6a>   @ imm = #0x20
   62a48: 5e24         	ldrsh	r4, [r4, r0]
   62a4a: 0300         	lsls	r0, r0, #0xc
   62a4c: 5e04         	ldrsh	r4, [r0, r0]
   62a4e: 0300         	lsls	r0, r0, #0xc
   62a50: 0d9c         	lsrs	r4, r3, #0x16
   62a52: 0300         	lsls	r0, r0, #0xc
   62a54: 3428         	adds	r4, #0x28
   62a56: 3901         	subs	r1, #0x1
   62a58: 2001         	movs	r0, #0x1
   62a5a: 4240         	rsbs	r0, r0, #0
   62a5c: 4281         	cmp	r1, r0
   62a5e: d1e6         	bne	0x62a2e <rom+0x62a2e>   @ imm = #-0x34
   62a60: 4803         	ldr	r0, [pc, #0xc]          @ 0x62a70 <rom+0x62a70>
   62a62: f7f5 f8fb    	bl	0x57c5c <rom+0x57c5c>   @ imm = #-0xae0a
   62a66: 2001         	movs	r0, #0x1
   62a68: 4240         	rsbs	r0, r0, #0
   62a6a: bc30         	pop	{r4, r5}
   62a6c: bc02         	pop	{r1}
   62a6e: 4708         	bx	r1
   62a70: 5e20         	ldrsh	r0, [r4, r0]
   62a72: 0875         	lsrs	r5, r6, #0x1
   62a74: b510         	push	{r4, lr}
   62a76: 1c03         	adds	r3, r0, #0x0
   62a78: 4808         	ldr	r0, [pc, #0x20]         @ 0x62a9c <rom+0x62a9c>
   62a7a: 6801         	ldr	r1, [r0]
   62a7c: 4808         	ldr	r0, [pc, #0x20]         @ 0x62aa0 <rom+0x62aa0>
   62a7e: 7802         	ldrb	r2, [r0]
   62a80: 3a01         	subs	r2, #0x1
   62a82: 2001         	movs	r0, #0x1
   62a84: 4240         	rsbs	r0, r0, #0
   62a86: 4282         	cmp	r2, r0
   62a88: d010         	beq	0x62aac <rom+0x62aac>   @ imm = #0x20
   62a8a: 1c04         	adds	r4, r0, #0x0
   62a8c: 7d88         	ldrb	r0, [r1, #0x16]
   62a8e: 2800         	cmp	r0, #0x0
   62a90: d008         	beq	0x62aa4 <rom+0x62aa4>   @ imm = #0x10
   62a92: 6988         	ldr	r0, [r1, #0x18]
   62a94: 4298         	cmp	r0, r3
   62a96: d105         	bne	0x62aa4 <rom+0x62aa4>   @ imm = #0xa
   62a98: 1c08         	adds	r0, r1, #0x0
   62a9a: e008         	b	0x62aae <rom+0x62aae>   @ imm = #0x10
   62a9c: 5e24         	ldrsh	r4, [r4, r0]
   62a9e: 0300         	lsls	r0, r0, #0xc
   62aa0: 5e04         	ldrsh	r4, [r0, r0]
   62aa2: 0300         	lsls	r0, r0, #0xc
   62aa4: 3128         	adds	r1, #0x28
   62aa6: 3a01         	subs	r2, #0x1
   62aa8: 42a2         	cmp	r2, r4
   62aaa: d1ef         	bne	0x62a8c <rom+0x62a8c>   @ imm = #-0x22
   62aac: 2000         	movs	r0, #0x0
   62aae: bc10         	pop	{r4}
   62ab0: bc02         	pop	{r1}
   62ab2: 4708         	bx	r1
   62ab4: b500         	push	{lr}
   62ab6: f7ff ffdd    	bl	0x62a74 <rom+0x62a74>   @ imm = #-0x46
   62aba: 1c01         	adds	r1, r0, #0x0
   62abc: 2900         	cmp	r1, #0x0
   62abe: d001         	beq	0x62ac4 <rom+0x62ac4>   @ imm = #0x2
   62ac0: 2000         	movs	r0, #0x0
   62ac2: 7588         	strb	r0, [r1, #0x16]
   62ac4: bc01         	pop	{r0}
   62ac6: 4700         	bx	r0
   62ac8: b500         	push	{lr}
   62aca: f7ff ffd3    	bl	0x62a74 <rom+0x62a74>   @ imm = #-0x5a
   62ace: 1c01         	adds	r1, r0, #0x0
   62ad0: 2900         	cmp	r1, #0x0
   62ad2: d001         	beq	0x62ad8 <rom+0x62ad8>   @ imm = #0x2
   62ad4: 2002         	movs	r0, #0x2
   62ad6: 7588         	strb	r0, [r1, #0x16]
   62ad8: bc01         	pop	{r0}
   62ada: 4700         	bx	r0
   62adc: b500         	push	{lr}
   62ade: f7ff ffc9    	bl	0x62a74 <rom+0x62a74>   @ imm = #-0x6e
   62ae2: 1c01         	adds	r1, r0, #0x0
   62ae4: 2900         	cmp	r1, #0x0
   62ae6: d004         	beq	0x62af2 <rom+0x62af2>   @ imm = #0x8
   62ae8: 7d88         	ldrb	r0, [r1, #0x16]
   62aea: 2802         	cmp	r0, #0x2
   62aec: d101         	bne	0x62af2 <rom+0x62af2>   @ imm = #0x2
   62aee: 2001         	movs	r0, #0x1
   62af0: 7588         	strb	r0, [r1, #0x16]
   62af2: bc01         	pop	{r0}
   62af4: 4700         	bx	r0
   62af6: 0000         	movs	r0, r0
   62af8: b510         	push	{r4, lr}
   62afa: 1c0c         	adds	r4, r1, #0x0
   62afc: f7ff ffba    	bl	0x62a74 <rom+0x62a74>   @ imm = #-0x8c
   62b00: 2800         	cmp	r0, #0x0
   62b02: d005         	beq	0x62b10 <rom+0x62b10>   @ imm = #0xa
   62b04: 2180         	movs	r1, #0x80
   62b06: 0049         	lsls	r1, r1, #0x1
   62b08: 428c         	cmp	r4, r1
   62b0a: d900         	bls	0x62b0e <rom+0x62b0e>   @ imm = #0x0
   62b0c: 1c0c         	adds	r4, r1, #0x0
   62b0e: 8204         	strh	r4, [r0, #0x10]
   62b10: bc10         	pop	{r4}
   62b12: bc01         	pop	{r0}
   62b14: 4700         	bx	r0
   62b16: 0000         	movs	r0, r0
   62b18: b510         	push	{r4, lr}
   62b1a: 1c0c         	adds	r4, r1, #0x0
   62b1c: f7ff ffaa    	bl	0x62a74 <rom+0x62a74>   @ imm = #-0xac
   62b20: 1c02         	adds	r2, r0, #0x0
   62b22: 2a00         	cmp	r2, #0x0
   62b24: d008         	beq	0x62b38 <rom+0x62b38>   @ imm = #0x10
   62b26: 2c7f         	cmp	r4, #0x7f
   62b28: d900         	bls	0x62b2c <rom+0x62b2c>   @ imm = #0x0
   62b2a: 247f         	movs	r4, #0x7f
   62b2c: 4804         	ldr	r0, [pc, #0x10]         @ 0x62b40 <rom+0x62b40>
   62b2e: 6801         	ldr	r1, [r0]
   62b30: 00a0         	lsls	r0, r4, #0x2
   62b32: 1840         	adds	r0, r0, r1
   62b34: 6800         	ldr	r0, [r0]
   62b36: 6090         	str	r0, [r2, #0x8]
   62b38: bc10         	pop	{r4}
   62b3a: bc01         	pop	{r0}
   62b3c: 4700         	bx	r0
   62b3e: 0000         	movs	r0, r0
   62b40: 0d98         	lsrs	r0, r3, #0x16
   62b42: 0300         	lsls	r0, r0, #0xc
   62b44: 4901         	ldr	r1, [pc, #0x4]          @ 0x62b4c <rom+0x62b4c>
   62b46: 6008         	str	r0, [r1]
   62b48: 4770         	bx	lr
   62b4a: 0000         	movs	r0, r0
   62b4c: 5e14         	ldrsh	r4, [r2, r0]
   62b4e: 0300         	lsls	r0, r0, #0xc
   62b50: b5f0         	push	{r4, r5, r6, r7, lr}
   62b52: b081         	sub	sp, #0x4
   62b54: 4815         	ldr	r0, [pc, #0x54]         @ 0x62bac <rom+0x62bac>
   62b56: 6800         	ldr	r0, [r0]
   62b58: 2801         	cmp	r0, #0x1
   62b5a: d123         	bne	0x62ba4 <rom+0x62ba4>   @ imm = #0x46
   62b5c: 2100         	movs	r1, #0x0
   62b5e: 4a14         	ldr	r2, [pc, #0x50]         @ 0x62bb0 <rom+0x62bb0>
   62b60: 2600         	movs	r6, #0x0
   62b62: 00c8         	lsls	r0, r1, #0x3
   62b64: 1c4f         	adds	r7, r1, #0x1
   62b66: 1840         	adds	r0, r0, r1
   62b68: 0085         	lsls	r5, r0, #0x2
   62b6a: 6810         	ldr	r0, [r2]
   62b6c: 1829         	adds	r1, r5, r0
   62b6e: 00f4         	lsls	r4, r6, #0x3
   62b70: 1908         	adds	r0, r1, r4
   62b72: 7900         	ldrb	r0, [r0, #0x4]
   62b74: 2800         	cmp	r0, #0x0
   62b76: d00c         	beq	0x62b92 <rom+0x62b92>   @ imm = #0x18
   62b78: 1c08         	adds	r0, r1, #0x0
   62b7a: 3008         	adds	r0, #0x8
   62b7c: 1900         	adds	r0, r0, r4
   62b7e: 6800         	ldr	r0, [r0]
   62b80: 9200         	str	r2, [sp]
   62b82: f7ff ff97    	bl	0x62ab4 <rom+0x62ab4>   @ imm = #-0xd2
   62b86: 9a00         	ldr	r2, [sp]
   62b88: 6810         	ldr	r0, [r2]
   62b8a: 1828         	adds	r0, r5, r0
   62b8c: 1900         	adds	r0, r0, r4
   62b8e: 2100         	movs	r1, #0x0
   62b90: 7101         	strb	r1, [r0, #0x4]
   62b92: 3601         	adds	r6, #0x1
   62b94: 2e03         	cmp	r6, #0x3
   62b96: d9e8         	bls	0x62b6a <rom+0x62b6a>   @ imm = #-0x30
   62b98: 1c39         	adds	r1, r7, #0x0
   62b9a: 290f         	cmp	r1, #0xf
   62b9c: d9e0         	bls	0x62b60 <rom+0x62b60>   @ imm = #-0x40
   62b9e: 4903         	ldr	r1, [pc, #0xc]          @ 0x62bac <rom+0x62bac>
   62ba0: 2000         	movs	r0, #0x0
   62ba2: 6008         	str	r0, [r1]
   62ba4: b001         	add	sp, #0x4
   62ba6: bcf0         	pop	{r4, r5, r6, r7}
   62ba8: bc01         	pop	{r0}
   62baa: 4700         	bx	r0
   62bac: 5e0c         	ldrsh	r4, [r1, r0]
   62bae: 0300         	lsls	r0, r0, #0xc
   62bb0: 5e28         	ldrsh	r0, [r5, r0]
   62bb2: 0300         	lsls	r0, r0, #0xc
   62bb4: 4803         	ldr	r0, [pc, #0xc]          @ 0x62bc4 <rom+0x62bc4>
   62bb6: 6800         	ldr	r0, [r0]
   62bb8: 2800         	cmp	r0, #0x0
   62bba: d002         	beq	0x62bc2 <rom+0x62bc2>   @ imm = #0x4
   62bbc: 4902         	ldr	r1, [pc, #0x8]          @ 0x62bc8 <rom+0x62bc8>
   62bbe: 2001         	movs	r0, #0x1
   62bc0: 6008         	str	r0, [r1]
   62bc2: 4770         	bx	lr
   62bc4: 5e00         	ldrsh	r0, [r0, r0]
   62bc6: 0300         	lsls	r0, r0, #0xc
   62bc8: 5e0c         	ldrsh	r4, [r1, r0]
   62bca: 0300         	lsls	r0, r0, #0xc
   62bcc: b530         	push	{r4, r5, lr}
   62bce: 1c04         	adds	r4, r0, #0x0
   62bd0: 4d0d         	ldr	r5, [pc, #0x34]         @ 0x62c08 <rom+0x62c08>
   62bd2: 6828         	ldr	r0, [r5]
   62bd4: 6800         	ldr	r0, [r0]
   62bd6: 4284         	cmp	r4, r0
   62bd8: d213         	bhs	0x62c02 <rom+0x62c02>   @ imm = #0x26
   62bda: f7ff ffb9    	bl	0x62b50 <rom+0x62b50>   @ imm = #-0x8e
   62bde: 4a0b         	ldr	r2, [pc, #0x2c]         @ 0x62c0c <rom+0x62c0c>
   62be0: 6828         	ldr	r0, [r5]
   62be2: 6881         	ldr	r1, [r0, #0x8]
   62be4: 00e0         	lsls	r0, r4, #0x3
   62be6: 1840         	adds	r0, r0, r1
   62be8: 6801         	ldr	r1, [r0]
   62bea: 6011         	str	r1, [r2]
   62bec: 4908         	ldr	r1, [pc, #0x20]         @ 0x62c10 <rom+0x62c10>
   62bee: 6840         	ldr	r0, [r0, #0x4]
   62bf0: 6008         	str	r0, [r1]
   62bf2: 4808         	ldr	r0, [pc, #0x20]         @ 0x62c14 <rom+0x62c14>
   62bf4: 2100         	movs	r1, #0x0
   62bf6: 6001         	str	r1, [r0]
   62bf8: 4807         	ldr	r0, [pc, #0x1c]         @ 0x62c18 <rom+0x62c18>
   62bfa: 6001         	str	r1, [r0]
   62bfc: 4907         	ldr	r1, [pc, #0x1c]         @ 0x62c1c <rom+0x62c1c>
   62bfe: 2001         	movs	r0, #0x1
   62c00: 6008         	str	r0, [r1]
   62c02: bc30         	pop	{r4, r5}
   62c04: bc01         	pop	{r0}
   62c06: 4700         	bx	r0
   62c08: 5e14         	ldrsh	r4, [r2, r0]
   62c0a: 0300         	lsls	r0, r0, #0xc
   62c0c: 5e00         	ldrsh	r0, [r0, r0]
   62c0e: 0300         	lsls	r0, r0, #0xc
   62c10: 5e20         	ldrsh	r0, [r4, r0]
   62c12: 0300         	lsls	r0, r0, #0xc
   62c14: 5e08         	ldrsh	r0, [r1, r0]
   62c16: 0300         	lsls	r0, r0, #0xc
   62c18: 5e10         	ldrsh	r0, [r2, r0]
   62c1a: 0300         	lsls	r0, r0, #0xc
   62c1c: 5e0c         	ldrsh	r4, [r1, r0]
   62c1e: 0300         	lsls	r0, r0, #0xc
   62c20: b500         	push	{lr}
   62c22: 1c02         	adds	r2, r0, #0x0
   62c24: 1c0b         	adds	r3, r1, #0x0
   62c26: 4807         	ldr	r0, [pc, #0x1c]         @ 0x62c44 <rom+0x62c44>
   62c28: 6801         	ldr	r1, [r0]
   62c2a: 6848         	ldr	r0, [r1, #0x4]
   62c2c: 4282         	cmp	r2, r0
   62c2e: d206         	bhs	0x62c3e <rom+0x62c3e>   @ imm = #0xc
   62c30: 68c9         	ldr	r1, [r1, #0xc]
   62c32: 0090         	lsls	r0, r2, #0x2
   62c34: 1840         	adds	r0, r0, r1
   62c36: 6800         	ldr	r0, [r0]
   62c38: 1c19         	adds	r1, r3, #0x0
   62c3a: f7ff feeb    	bl	0x62a14 <rom+0x62a14>   @ imm = #-0x22a
   62c3e: bc02         	pop	{r1}
   62c40: 4708         	bx	r1
   62c42: 0000         	movs	r0, r0
   62c44: 5e14         	ldrsh	r4, [r2, r0]
   62c46: 0300         	lsls	r0, r0, #0xc
   62c48: b5f0         	push	{r4, r5, r6, r7, lr}
   62c4a: 4811         	ldr	r0, [pc, #0x44]         @ 0x62c90 <rom+0x62c90>
   62c4c: 6800         	ldr	r0, [r0]
   62c4e: 2801         	cmp	r0, #0x1
   62c50: d000         	beq	0x62c54 <rom+0x62c54>   @ imm = #0x0
   62c52: e10c         	b	0x62e6e <rom+0x62e6e>   @ imm = #0x218
   62c54: 4a0f         	ldr	r2, [pc, #0x3c]         @ 0x62c94 <rom+0x62c94>
   62c56: 4910         	ldr	r1, [pc, #0x40]         @ 0x62c98 <rom+0x62c98>
   62c58: 6810         	ldr	r0, [r2]
   62c5a: 6809         	ldr	r1, [r1]
   62c5c: 1a40         	subs	r0, r0, r1
   62c5e: 6010         	str	r0, [r2]
   62c60: 2800         	cmp	r0, #0x0
   62c62: dd00         	ble	0x62c66 <rom+0x62c66>   @ imm = #0x0
   62c64: e103         	b	0x62e6e <rom+0x62e6e>   @ imm = #0x206
   62c66: 4b0d         	ldr	r3, [pc, #0x34]         @ 0x62c9c <rom+0x62c9c>
   62c68: 681a         	ldr	r2, [r3]
   62c6a: 7815         	ldrb	r5, [r2]
   62c6c: 3201         	adds	r2, #0x1
   62c6e: 601a         	str	r2, [r3]
   62c70: 2080         	movs	r0, #0x80
   62c72: 4028         	ands	r0, r5
   62c74: 1c1c         	adds	r4, r3, #0x0
   62c76: 2800         	cmp	r0, #0x0
   62c78: d100         	bne	0x62c7c <rom+0x62c7c>   @ imm = #0x0
   62c7a: e0e9         	b	0x62e50 <rom+0x62e50>   @ imm = #0x1d2
   62c7c: 0928         	lsrs	r0, r5, #0x4
   62c7e: 3808         	subs	r0, #0x8
   62c80: 2805         	cmp	r0, #0x5
   62c82: d900         	bls	0x62c86 <rom+0x62c86>   @ imm = #0x0
   62c84: e0ee         	b	0x62e64 <rom+0x62e64>   @ imm = #0x1dc
   62c86: 0080         	lsls	r0, r0, #0x2
   62c88: 4905         	ldr	r1, [pc, #0x14]         @ 0x62ca0 <rom+0x62ca0>
   62c8a: 1840         	adds	r0, r0, r1
   62c8c: 6800         	ldr	r0, [r0]
   62c8e: 4687         	mov	pc, r0
   62c90: 5e0c         	ldrsh	r4, [r1, r0]
   62c92: 0300         	lsls	r0, r0, #0xc
   62c94: 5e08         	ldrsh	r0, [r1, r0]
   62c96: 0300         	lsls	r0, r0, #0xc
   62c98: 5e10         	ldrsh	r0, [r2, r0]
   62c9a: 0300         	lsls	r0, r0, #0xc
   62c9c: 5e00         	ldrsh	r0, [r0, r0]
   62c9e: 0300         	lsls	r0, r0, #0xc
   62ca0: 2ca4         	cmp	r4, #0xa4
   62ca2: 0806         	lsrs	r6, r0, #0x20
   62ca4: 2cbc         	cmp	r4, #0xbc
   62ca6: 0806         	lsrs	r6, r0, #0x20
   62ca8: 2d04         	cmp	r5, #0x4
   62caa: 0806         	lsrs	r6, r0, #0x20
   62cac: 2e64         	cmp	r6, #0x64
   62cae: 0806         	lsrs	r6, r0, #0x20
   62cb0: 2daa         	cmp	r5, #0xaa
   62cb2: 0806         	lsrs	r6, r0, #0x20
   62cb4: 2e18         	cmp	r6, #0x18
   62cb6: 0806         	lsrs	r6, r0, #0x20
   62cb8: 2e48         	cmp	r6, #0x48
   62cba: 0806         	lsrs	r6, r0, #0x20
   62cbc: 6820         	ldr	r0, [r4]
   62cbe: 7803         	ldrb	r3, [r0]
   62cc0: 3002         	adds	r0, #0x2
   62cc2: 6020         	str	r0, [r4]
   62cc4: 4a05         	ldr	r2, [pc, #0x14]         @ 0x62cdc <rom+0x62cdc>
   62cc6: 200f         	movs	r0, #0xf
   62cc8: 4028         	ands	r0, r5
   62cca: 00c1         	lsls	r1, r0, #0x3
   62ccc: 1809         	adds	r1, r1, r0
   62cce: 0089         	lsls	r1, r1, #0x2
   62cd0: 6810         	ldr	r0, [r2]
   62cd2: 1840         	adds	r0, r0, r1
   62cd4: 1d04         	adds	r4, r0, #0x4
   62cd6: 2104         	movs	r1, #0x4
   62cd8: e003         	b	0x62ce2 <rom+0x62ce2>   @ imm = #0x6
   62cda: 0000         	movs	r0, r0
   62cdc: 5e28         	ldrsh	r0, [r5, r0]
   62cde: 0300         	lsls	r0, r0, #0xc
   62ce0: 3408         	adds	r4, #0x8
   62ce2: 1c08         	adds	r0, r1, #0x0
   62ce4: 3901         	subs	r1, #0x1
   62ce6: 2800         	cmp	r0, #0x0
   62ce8: d100         	bne	0x62cec <rom+0x62cec>   @ imm = #0x0
   62cea: e0bb         	b	0x62e64 <rom+0x62e64>   @ imm = #0x176
   62cec: 7820         	ldrb	r0, [r4]
   62cee: 2800         	cmp	r0, #0x0
   62cf0: d0f6         	beq	0x62ce0 <rom+0x62ce0>   @ imm = #-0x14
   62cf2: 7860         	ldrb	r0, [r4, #0x1]
   62cf4: 4298         	cmp	r0, r3
   62cf6: d1f3         	bne	0x62ce0 <rom+0x62ce0>   @ imm = #-0x1a
   62cf8: 6860         	ldr	r0, [r4, #0x4]
   62cfa: f7ff fedb    	bl	0x62ab4 <rom+0x62ab4>   @ imm = #-0x24a
   62cfe: 2000         	movs	r0, #0x0
   62d00: 7020         	strb	r0, [r4]
   62d02: e0af         	b	0x62e64 <rom+0x62e64>   @ imm = #0x15e
   62d04: 6820         	ldr	r0, [r4]
   62d06: 7806         	ldrb	r6, [r0]
   62d08: 3001         	adds	r0, #0x1
   62d0a: 6020         	str	r0, [r4]
   62d0c: 7807         	ldrb	r7, [r0]
   62d0e: 3001         	adds	r0, #0x1
   62d10: 6020         	str	r0, [r4]
   62d12: 210f         	movs	r1, #0xf
   62d14: 4029         	ands	r1, r5
   62d16: 4b20         	ldr	r3, [pc, #0x80]         @ 0x62d98 <rom+0x62d98>
   62d18: 681a         	ldr	r2, [r3]
   62d1a: 00c8         	lsls	r0, r1, #0x3
   62d1c: 1840         	adds	r0, r0, r1
   62d1e: 0080         	lsls	r0, r0, #0x2
   62d20: 1880         	adds	r0, r0, r2
   62d22: 6802         	ldr	r2, [r0]
   62d24: 469c         	mov	r12, r3
   62d26: 2a00         	cmp	r2, #0x0
   62d28: d100         	bne	0x62d2c <rom+0x62d2c>   @ imm = #0x0
   62d2a: e09b         	b	0x62e64 <rom+0x62e64>   @ imm = #0x136
   62d2c: 1d04         	adds	r4, r0, #0x4
   62d2e: 2300         	movs	r3, #0x0
   62d30: 2103         	movs	r1, #0x3
   62d32: 7900         	ldrb	r0, [r0, #0x4]
   62d34: 2800         	cmp	r0, #0x0
   62d36: d003         	beq	0x62d40 <rom+0x62d40>   @ imm = #0x6
   62d38: 7860         	ldrb	r0, [r4, #0x1]
   62d3a: 42b0         	cmp	r0, r6
   62d3c: d100         	bne	0x62d40 <rom+0x62d40>   @ imm = #0x0
   62d3e: e091         	b	0x62e64 <rom+0x62e64>   @ imm = #0x122
   62d40: 3408         	adds	r4, #0x8
   62d42: 3901         	subs	r1, #0x1
   62d44: 2001         	movs	r0, #0x1
   62d46: 4240         	rsbs	r0, r0, #0
   62d48: 4281         	cmp	r1, r0
   62d4a: d006         	beq	0x62d5a <rom+0x62d5a>   @ imm = #0xc
   62d4c: 7820         	ldrb	r0, [r4]
   62d4e: 2800         	cmp	r0, #0x0
   62d50: d0f6         	beq	0x62d40 <rom+0x62d40>   @ imm = #-0x14
   62d52: 7860         	ldrb	r0, [r4, #0x1]
   62d54: 42b0         	cmp	r0, r6
   62d56: d1f3         	bne	0x62d40 <rom+0x62d40>   @ imm = #-0x1a
   62d58: 2301         	movs	r3, #0x1
   62d5a: 2b00         	cmp	r3, #0x0
   62d5c: d000         	beq	0x62d60 <rom+0x62d60>   @ imm = #0x0
   62d5e: e081         	b	0x62e64 <rom+0x62e64>   @ imm = #0x102
   62d60: 200f         	movs	r0, #0xf
   62d62: 4028         	ands	r0, r5
   62d64: 00c1         	lsls	r1, r0, #0x3
   62d66: 1809         	adds	r1, r1, r0
   62d68: 0089         	lsls	r1, r1, #0x2
   62d6a: 4663         	mov	r3, r12
   62d6c: 6818         	ldr	r0, [r3]
   62d6e: 1840         	adds	r0, r0, r1
   62d70: 1d04         	adds	r4, r0, #0x4
   62d72: 2103         	movs	r1, #0x3
   62d74: 7820         	ldrb	r0, [r4]
   62d76: 2800         	cmp	r0, #0x0
   62d78: d110         	bne	0x62d9c <rom+0x62d9c>   @ imm = #0x20
   62d7a: 2a00         	cmp	r2, #0x0
   62d7c: d072         	beq	0x62e64 <rom+0x62e64>   @ imm = #0xe4
   62d7e: 1c10         	adds	r0, r2, #0x0
   62d80: 1c31         	adds	r1, r6, #0x0
   62d82: f7ff fe47    	bl	0x62a14 <rom+0x62a14>   @ imm = #-0x372
   62d86: 6060         	str	r0, [r4, #0x4]
   62d88: 1c39         	adds	r1, r7, #0x0
   62d8a: f7ff feb5    	bl	0x62af8 <rom+0x62af8>   @ imm = #-0x296
   62d8e: 2001         	movs	r0, #0x1
   62d90: 7020         	strb	r0, [r4]
   62d92: 7066         	strb	r6, [r4, #0x1]
   62d94: e066         	b	0x62e64 <rom+0x62e64>   @ imm = #0xcc
   62d96: 0000         	movs	r0, r0
   62d98: 5e28         	ldrsh	r0, [r5, r0]
   62d9a: 0300         	lsls	r0, r0, #0xc
   62d9c: 3408         	adds	r4, #0x8
   62d9e: 3901         	subs	r1, #0x1
   62da0: 2001         	movs	r0, #0x1
   62da2: 4240         	rsbs	r0, r0, #0
   62da4: 4281         	cmp	r1, r0
   62da6: d1e5         	bne	0x62d74 <rom+0x62d74>   @ imm = #-0x36
   62da8: e05c         	b	0x62e64 <rom+0x62e64>   @ imm = #0xb8
   62daa: 200f         	movs	r0, #0xf
   62dac: 4028         	ands	r0, r5
   62dae: 2801         	cmp	r0, #0x1
   62db0: d04a         	beq	0x62e48 <rom+0x62e48>   @ imm = #0x94
   62db2: 2801         	cmp	r0, #0x1
   62db4: dc02         	bgt	0x62dbc <rom+0x62dbc>   @ imm = #0x4
   62db6: 2800         	cmp	r0, #0x0
   62db8: d005         	beq	0x62dc6 <rom+0x62dc6>   @ imm = #0xa
   62dba: e053         	b	0x62e64 <rom+0x62e64>   @ imm = #0xa6
   62dbc: 2802         	cmp	r0, #0x2
   62dbe: d009         	beq	0x62dd4 <rom+0x62dd4>   @ imm = #0x12
   62dc0: 2803         	cmp	r0, #0x3
   62dc2: d023         	beq	0x62e0c <rom+0x62e0c>   @ imm = #0x46
   62dc4: e04e         	b	0x62e64 <rom+0x62e64>   @ imm = #0x9c
   62dc6: 4802         	ldr	r0, [pc, #0x8]          @ 0x62dd0 <rom+0x62dd0>
   62dc8: 6800         	ldr	r0, [r0]
   62dca: 6020         	str	r0, [r4]
   62dcc: e04a         	b	0x62e64 <rom+0x62e64>   @ imm = #0x94
   62dce: 0000         	movs	r0, r0
   62dd0: 5e20         	ldrsh	r0, [r4, r0]
   62dd2: 0300         	lsls	r0, r0, #0xc
   62dd4: 4b0c         	ldr	r3, [pc, #0x30]         @ 0x62e08 <rom+0x62e08>
   62dd6: 6820         	ldr	r0, [r4]
   62dd8: 7805         	ldrb	r5, [r0]
   62dda: 062a         	lsls	r2, r5, #0x18
   62ddc: 601a         	str	r2, [r3]
   62dde: 3001         	adds	r0, #0x1
   62de0: 6020         	str	r0, [r4]
   62de2: 7805         	ldrb	r5, [r0]
   62de4: 0429         	lsls	r1, r5, #0x10
   62de6: 4311         	orrs	r1, r2
   62de8: 6019         	str	r1, [r3]
   62dea: 1c42         	adds	r2, r0, #0x1
   62dec: 6022         	str	r2, [r4]
   62dee: 7840         	ldrb	r0, [r0, #0x1]
   62df0: 0200         	lsls	r0, r0, #0x8
   62df2: 4308         	orrs	r0, r1
   62df4: 6018         	str	r0, [r3]
   62df6: 1c51         	adds	r1, r2, #0x1
   62df8: 6021         	str	r1, [r4]
   62dfa: 7852         	ldrb	r2, [r2, #0x1]
   62dfc: 4310         	orrs	r0, r2
   62dfe: 6018         	str	r0, [r3]
   62e00: 3101         	adds	r1, #0x1
   62e02: 6021         	str	r1, [r4]
   62e04: e02e         	b	0x62e64 <rom+0x62e64>   @ imm = #0x5c
   62e06: 0000         	movs	r0, r0
   62e08: 5e10         	ldrsh	r0, [r2, r0]
   62e0a: 0300         	lsls	r0, r0, #0xc
   62e0c: 4801         	ldr	r0, [pc, #0x4]          @ 0x62e14 <rom+0x62e14>
   62e0e: f7f4 ff25    	bl	0x57c5c <rom+0x57c5c>   @ imm = #-0xb1b6
   62e12: e027         	b	0x62e64 <rom+0x62e64>   @ imm = #0x4e
   62e14: 5e38         	ldrsh	r0, [r7, r0]
   62e16: 0875         	lsrs	r5, r6, #0x1
   62e18: 6820         	ldr	r0, [r4]
   62e1a: 7803         	ldrb	r3, [r0]
   62e1c: 3001         	adds	r0, #0x1
   62e1e: 6020         	str	r0, [r4]
   62e20: 220f         	movs	r2, #0xf
   62e22: 402a         	ands	r2, r5
   62e24: 4806         	ldr	r0, [pc, #0x18]         @ 0x62e40 <rom+0x62e40>
   62e26: 6800         	ldr	r0, [r0]
   62e28: 00d1         	lsls	r1, r2, #0x3
   62e2a: 1889         	adds	r1, r1, r2
   62e2c: 0089         	lsls	r1, r1, #0x2
   62e2e: 1809         	adds	r1, r1, r0
   62e30: 4804         	ldr	r0, [pc, #0x10]         @ 0x62e44 <rom+0x62e44>
   62e32: 6800         	ldr	r0, [r0]
   62e34: 68c0         	ldr	r0, [r0, #0xc]
   62e36: 009b         	lsls	r3, r3, #0x2
   62e38: 181b         	adds	r3, r3, r0
   62e3a: 6818         	ldr	r0, [r3]
   62e3c: 6008         	str	r0, [r1]
   62e3e: e011         	b	0x62e64 <rom+0x62e64>   @ imm = #0x22
   62e40: 5e28         	ldrsh	r0, [r5, r0]
   62e42: 0300         	lsls	r0, r0, #0xc
   62e44: 5e14         	ldrsh	r4, [r2, r0]
   62e46: 0300         	lsls	r0, r0, #0xc
   62e48: 6820         	ldr	r0, [r4]
   62e4a: 3001         	adds	r0, #0x1
   62e4c: 6020         	str	r0, [r4]
   62e4e: e009         	b	0x62e64 <rom+0x62e64>   @ imm = #0x12
   62e50: 0229         	lsls	r1, r5, #0x8
   62e52: 7810         	ldrb	r0, [r2]
   62e54: 4301         	orrs	r1, r0
   62e56: 1c50         	adds	r0, r2, #0x1
   62e58: 6018         	str	r0, [r3]
   62e5a: 4a06         	ldr	r2, [pc, #0x18]         @ 0x62e74 <rom+0x62e74>
   62e5c: 0409         	lsls	r1, r1, #0x10
   62e5e: 6810         	ldr	r0, [r2]
   62e60: 1840         	adds	r0, r0, r1
   62e62: 6010         	str	r0, [r2]
   62e64: 4803         	ldr	r0, [pc, #0xc]          @ 0x62e74 <rom+0x62e74>
   62e66: 6800         	ldr	r0, [r0]
   62e68: 2800         	cmp	r0, #0x0
   62e6a: dc00         	bgt	0x62e6e <rom+0x62e6e>   @ imm = #0x0
   62e6c: e6fb         	b	0x62c66 <rom+0x62c66>   @ imm = #-0x20a
   62e6e: bcf0         	pop	{r4, r5, r6, r7}
   62e70: bc01         	pop	{r0}
   62e72: 4700         	bx	r0
   62e74: 5e08         	ldrsh	r0, [r1, r0]
   62e76: 0300         	lsls	r0, r0, #0xc
   62e78: b500         	push	{lr}
   62e7a: f7ff fdfb    	bl	0x62a74 <rom+0x62a74>   @ imm = #-0x40a
   62e7e: 2800         	cmp	r0, #0x0
   62e80: d004         	beq	0x62e8c <rom+0x62e8c>   @ imm = #0x8
   62e82: 7d80         	ldrb	r0, [r0, #0x16]
   62e84: 2800         	cmp	r0, #0x0
   62e86: d001         	beq	0x62e8c <rom+0x62e8c>   @ imm = #0x2
   62e88: 2001         	movs	r0, #0x1
   62e8a: e000         	b	0x62e8e <rom+0x62e8e>   @ imm = #0x0
   62e8c: 2000         	movs	r0, #0x0
   62e8e: bc02         	pop	{r1}
   62e90: 4708         	bx	r1
   62e92: 0000         	movs	r0, r0
