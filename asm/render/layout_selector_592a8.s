 80592a8: b530         	push	{r4, r5, lr}
 80592aa: 1c03         	adds	r3, r0, #0x0
 80592ac: 0409         	lsls	r1, r1, #0x10
 80592ae: 0412         	lsls	r2, r2, #0x10
 80592b0: 0c12         	lsrs	r2, r2, #0x10
 80592b2: 0f89         	lsrs	r1, r1, #0x1e
 80592b4: 1c08         	adds	r0, r1, #0x0
 80592b6: 2501         	movs	r5, #0x1
 80592b8: 402a         	ands	r2, r5
 80592ba: 2a00         	cmp	r2, #0x0
 80592bc: d007         	beq	0x80592ce <rom+0x592ce> @ imm = #0xe
 80592be: 0048         	lsls	r0, r1, #0x1
 80592c0: 3008         	adds	r0, #0x8
 80592c2: 1c2c         	adds	r4, r5, #0x0
 80592c4: 4084         	lsls	r4, r0
 80592c6: 3104         	adds	r1, #0x4
 80592c8: 1c18         	adds	r0, r3, #0x0
 80592ca: 305f         	adds	r0, #0x5f
 80592cc: e02a         	b	0x8059324 <rom+0x59324> @ imm = #0x54
 80592ce: 2901         	cmp	r1, #0x1
 80592d0: d00f         	beq	0x80592f2 <rom+0x592f2> @ imm = #0x1e
 80592d2: 2901         	cmp	r1, #0x1
 80592d4: dc02         	bgt	0x80592dc <rom+0x592dc> @ imm = #0x4
 80592d6: 2900         	cmp	r1, #0x0
 80592d8: d005         	beq	0x80592e6 <rom+0x592e6> @ imm = #0xa
 80592da: e026         	b	0x805932a <rom+0x5932a> @ imm = #0x4c
 80592dc: 2802         	cmp	r0, #0x2
 80592de: d012         	beq	0x8059306 <rom+0x59306> @ imm = #0x24
 80592e0: 2803         	cmp	r0, #0x3
 80592e2: d01a         	beq	0x805931a <rom+0x5931a> @ imm = #0x34
 80592e4: e021         	b	0x805932a <rom+0x5932a> @ imm = #0x42
 80592e6: 2480         	movs	r4, #0x80
 80592e8: 0124         	lsls	r4, r4, #0x4
 80592ea: 1c18         	adds	r0, r3, #0x0
 80592ec: 305f         	adds	r0, #0x5f
 80592ee: 2105         	movs	r1, #0x5
 80592f0: e018         	b	0x8059324 <rom+0x59324> @ imm = #0x30
 80592f2: 2480         	movs	r4, #0x80
 80592f4: 0164         	lsls	r4, r4, #0x5
 80592f6: 1c19         	adds	r1, r3, #0x0
 80592f8: 315f         	adds	r1, #0x5f
 80592fa: 2006         	movs	r0, #0x6
 80592fc: 7008         	strb	r0, [r1]
 80592fe: 3101         	adds	r1, #0x1
 8059300: 2005         	movs	r0, #0x5
 8059302: 7008         	strb	r0, [r1]
 8059304: e011         	b	0x805932a <rom+0x5932a> @ imm = #0x22
 8059306: 2480         	movs	r4, #0x80
 8059308: 0164         	lsls	r4, r4, #0x5
 805930a: 1c19         	adds	r1, r3, #0x0
 805930c: 315f         	adds	r1, #0x5f
 805930e: 2005         	movs	r0, #0x5
 8059310: 7008         	strb	r0, [r1]
 8059312: 3101         	adds	r1, #0x1
 8059314: 2006         	movs	r0, #0x6
 8059316: 7008         	strb	r0, [r1]
 8059318: e007         	b	0x805932a <rom+0x5932a> @ imm = #0xe
 805931a: 2480         	movs	r4, #0x80
 805931c: 01a4         	lsls	r4, r4, #0x6
 805931e: 1c18         	adds	r0, r3, #0x0
 8059320: 305f         	adds	r0, #0x5f
 8059322: 2106         	movs	r1, #0x6
 8059324: 7001         	strb	r1, [r0]
 8059326: 3001         	adds	r0, #0x1
 8059328: 7001         	strb	r1, [r0]
 805932a: 1c20         	adds	r0, r4, #0x0
 805932c: bc30         	pop	{r4, r5}
 805932e: bc02         	pop	{r1}
 8059330: 4708         	bx	r1
 8059332: 0000         	movs	r0, r0
 8059334: b5f0         	push	{r4, r5, r6, r7, lr}
