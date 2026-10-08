
/tmp/dis.o:	file format elf32-littlearm

Disassembly of section .text:

00000000 <rom>:
   63244: b5f0         	push	{r4, r5, r6, r7, lr}
   63246: 4657         	mov	r7, r10
   63248: 464e         	mov	r6, r9
   6324a: 4645         	mov	r5, r8
   6324c: b4e0         	push	{r5, r6, r7}
   6324e: b08a         	sub	sp, #0x28
   63250: 1c04         	adds	r4, r0, #0x0
   63252: 9100         	str	r1, [sp]
   63254: 9201         	str	r2, [sp, #0x4]
   63256: 9302         	str	r3, [sp, #0x8]
   63258: 2008         	movs	r0, #0x8
   6325a: 5e25         	ldrsh	r5, [r4, r0]
   6325c: 2080         	movs	r0, #0x80
   6325e: 00c0         	lsls	r0, r0, #0x3
   63260: 1c29         	adds	r1, r5, #0x0
   63262: f002 ff21    	bl	0x660a8 <rom+0x660a8>   @ imm = #0x2e42
   63266: 9003         	str	r0, [sp, #0xc]
   63268: 2100         	movs	r1, #0x0
   6326a: 468c         	mov	r12, r1
   6326c: 88e2         	ldrh	r2, [r4, #0x6]
   6326e: 0852         	lsrs	r2, r2, #0x1
   63270: 4692         	mov	r10, r2
   63272: 88a3         	ldrh	r3, [r4, #0x4]
   63274: 0059         	lsls	r1, r3, #0x1
   63276: 6820         	ldr	r0, [r4]
   63278: 1840         	adds	r0, r0, r1
   6327a: 9004         	str	r0, [sp, #0x10]
   6327c: 68e4         	ldr	r4, [r4, #0xc]
   6327e: 9405         	str	r4, [sp, #0x14]
   63280: 9e00         	ldr	r6, [sp]
   63282: 9f01         	ldr	r7, [sp, #0x4]
   63284: 19f0         	adds	r0, r6, r7
   63286: 9902         	ldr	r1, [sp, #0x8]
   63288: 42c8         	cmn	r0, r1
   6328a: d15d         	bne	0x63348 <rom+0x63348>   @ imm = #0xba
   6328c: 3d02         	subs	r5, #0x2
   6328e: 2001         	movs	r0, #0x1
   63290: 4240         	rsbs	r0, r0, #0
   63292: 0092         	lsls	r2, r2, #0x2
   63294: 9208         	str	r2, [sp, #0x20]
   63296: 4285         	cmp	r5, r0
   63298: d04c         	beq	0x63334 <rom+0x63334>   @ imm = #0x98
   6329a: 9a04         	ldr	r2, [sp, #0x10]
   6329c: 4690         	mov	r8, r2
   6329e: 2300         	movs	r3, #0x0
   632a0: 4699         	mov	r9, r3
   632a2: 3d01         	subs	r5, #0x1
   632a4: 9507         	str	r5, [sp, #0x1c]
   632a6: 9d03         	ldr	r5, [sp, #0xc]
   632a8: 4465         	add	r5, r12
   632aa: 9506         	str	r5, [sp, #0x18]
   632ac: 45d1         	cmp	r9, r10
   632ae: d23a         	bhs	0x63326 <rom+0x63326>   @ imm = #0x74
   632b0: 271f         	movs	r7, #0x1f
   632b2: 4646         	mov	r6, r8
   632b4: 3604         	adds	r6, #0x4
   632b6: 46b0         	mov	r8, r6
   632b8: 3e04         	subs	r6, #0x4
   632ba: ce01         	ldm	r6!, {r0}
   632bc: 1c04         	adds	r4, r0, #0x0
   632be: 403c         	ands	r4, r7
   632c0: 0941         	lsrs	r1, r0, #0x5
   632c2: 4039         	ands	r1, r7
   632c4: 0a82         	lsrs	r2, r0, #0xa
   632c6: 403a         	ands	r2, r7
   632c8: 0c03         	lsrs	r3, r0, #0x10
   632ca: 403b         	ands	r3, r7
   632cc: 0d45         	lsrs	r5, r0, #0x15
   632ce: 403d         	ands	r5, r7
   632d0: 0e86         	lsrs	r6, r0, #0x1a
   632d2: 403e         	ands	r6, r7
   632d4: 4660         	mov	r0, r12
   632d6: 4360         	muls	r0, r4, r0
   632d8: 1280         	asrs	r0, r0, #0xa
   632da: 1a24         	subs	r4, r4, r0
   632dc: 4660         	mov	r0, r12
   632de: 4348         	muls	r0, r1, r0
   632e0: 1280         	asrs	r0, r0, #0xa
   632e2: 1a09         	subs	r1, r1, r0
   632e4: 4660         	mov	r0, r12
   632e6: 4350         	muls	r0, r2, r0
   632e8: 1280         	asrs	r0, r0, #0xa
   632ea: 1a12         	subs	r2, r2, r0
   632ec: 4660         	mov	r0, r12
   632ee: 4358         	muls	r0, r3, r0
   632f0: 1280         	asrs	r0, r0, #0xa
   632f2: 1a1b         	subs	r3, r3, r0
   632f4: 4660         	mov	r0, r12
   632f6: 4368         	muls	r0, r5, r0
   632f8: 1280         	asrs	r0, r0, #0xa
   632fa: 1a2d         	subs	r5, r5, r0
   632fc: 4660         	mov	r0, r12
   632fe: 4370         	muls	r0, r6, r0
   63300: 1280         	asrs	r0, r0, #0xa
   63302: 1a36         	subs	r6, r6, r0
   63304: 0148         	lsls	r0, r1, #0x5
   63306: 4304         	orrs	r4, r0
   63308: 0290         	lsls	r0, r2, #0xa
   6330a: 4304         	orrs	r4, r0
   6330c: 0418         	lsls	r0, r3, #0x10
   6330e: 4304         	orrs	r4, r0
   63310: 0568         	lsls	r0, r5, #0x15
   63312: 4304         	orrs	r4, r0
   63314: 06b0         	lsls	r0, r6, #0x1a
   63316: 4304         	orrs	r4, r0
   63318: 9805         	ldr	r0, [sp, #0x14]
   6331a: c010         	stm	r0!, {r4}
   6331c: 9005         	str	r0, [sp, #0x14]
   6331e: 2101         	movs	r1, #0x1
   63320: 4489         	add	r9, r1
   63322: 45d1         	cmp	r9, r10
   63324: d3c5         	blo	0x632b2 <rom+0x632b2>   @ imm = #-0x76
   63326: 9a06         	ldr	r2, [sp, #0x18]
   63328: 4694         	mov	r12, r2
   6332a: 9d07         	ldr	r5, [sp, #0x1c]
   6332c: 2001         	movs	r0, #0x1
   6332e: 4240         	rsbs	r0, r0, #0
   63330: 4285         	cmp	r5, r0
   63332: d1b2         	bne	0x6329a <rom+0x6329a>   @ imm = #-0x9c
   63334: 4d03         	ldr	r5, [pc, #0xc]          @ 0x63344 <rom+0x63344>
   63336: 682b         	ldr	r3, [r5]
   63338: 2000         	movs	r0, #0x0
   6333a: 9905         	ldr	r1, [sp, #0x14]
   6333c: 9a08         	ldr	r2, [sp, #0x20]
   6333e: f002 fc81    	bl	0x65c44 <rom+0x65c44>   @ imm = #0x2902
   63342: e090         	b	0x63466 <rom+0x63466>   @ imm = #0x120
   63344: d994         	bls	0x63270 <rom+0x63270>   @ imm = #-0xd8
   63346: 0807         	lsrs	r7, r0, #0x20
   63348: 3d01         	subs	r5, #0x1
   6334a: e087         	b	0x6345c <rom+0x6345c>   @ imm = #0x10e
   6334c: 9e04         	ldr	r6, [sp, #0x10]
   6334e: 46b0         	mov	r8, r6
   63350: 2700         	movs	r7, #0x0
   63352: 46b9         	mov	r9, r7
   63354: 3d01         	subs	r5, #0x1
   63356: 9507         	str	r5, [sp, #0x1c]
   63358: 9803         	ldr	r0, [sp, #0xc]
   6335a: 4460         	add	r0, r12
   6335c: 9006         	str	r0, [sp, #0x18]
   6335e: 45d1         	cmp	r9, r10
   63360: d279         	bhs	0x63456 <rom+0x63456>   @ imm = #0xf2
   63362: 4641         	mov	r1, r8
   63364: 6808         	ldr	r0, [r1]
   63366: 1c04         	adds	r4, r0, #0x0
   63368: 221f         	movs	r2, #0x1f
   6336a: 4014         	ands	r4, r2
   6336c: 0941         	lsrs	r1, r0, #0x5
   6336e: 4011         	ands	r1, r2
   63370: 0a82         	lsrs	r2, r0, #0xa
   63372: 231f         	movs	r3, #0x1f
   63374: 401a         	ands	r2, r3
   63376: 0c03         	lsrs	r3, r0, #0x10
   63378: 251f         	movs	r5, #0x1f
   6337a: 402b         	ands	r3, r5
   6337c: 0d45         	lsrs	r5, r0, #0x15
   6337e: 261f         	movs	r6, #0x1f
   63380: 4035         	ands	r5, r6
   63382: 0e86         	lsrs	r6, r0, #0x1a
   63384: 271f         	movs	r7, #0x1f
   63386: 403e         	ands	r6, r7
   63388: 9800         	ldr	r0, [sp]
   6338a: 1b00         	subs	r0, r0, r4
   6338c: 9009         	str	r0, [sp, #0x24]
   6338e: 1c07         	adds	r7, r0, #0x0
   63390: 4660         	mov	r0, r12
   63392: 4378         	muls	r0, r7, r0
   63394: 1280         	asrs	r0, r0, #0xa
   63396: 1824         	adds	r4, r4, r0
   63398: 9801         	ldr	r0, [sp, #0x4]
   6339a: 1a40         	subs	r0, r0, r1
   6339c: 9009         	str	r0, [sp, #0x24]
   6339e: 1c07         	adds	r7, r0, #0x0
   633a0: 4660         	mov	r0, r12
   633a2: 4378         	muls	r0, r7, r0
   633a4: 1280         	asrs	r0, r0, #0xa
   633a6: 1809         	adds	r1, r1, r0
   633a8: 9802         	ldr	r0, [sp, #0x8]
   633aa: 1a80         	subs	r0, r0, r2
   633ac: 9009         	str	r0, [sp, #0x24]
   633ae: 1c07         	adds	r7, r0, #0x0
   633b0: 4660         	mov	r0, r12
   633b2: 4378         	muls	r0, r7, r0
   633b4: 1280         	asrs	r0, r0, #0xa
   633b6: 1812         	adds	r2, r2, r0
   633b8: 9800         	ldr	r0, [sp]
   633ba: 1ac0         	subs	r0, r0, r3
   633bc: 9009         	str	r0, [sp, #0x24]
   633be: 1c07         	adds	r7, r0, #0x0
   633c0: 4660         	mov	r0, r12
   633c2: 4378         	muls	r0, r7, r0
   633c4: 1280         	asrs	r0, r0, #0xa
   633c6: 181b         	adds	r3, r3, r0
   633c8: 9801         	ldr	r0, [sp, #0x4]
   633ca: 1b40         	subs	r0, r0, r5
   633cc: 9009         	str	r0, [sp, #0x24]
   633ce: 1c07         	adds	r7, r0, #0x0
   633d0: 4660         	mov	r0, r12
   633d2: 4378         	muls	r0, r7, r0
   633d4: 1280         	asrs	r0, r0, #0xa
   633d6: 182d         	adds	r5, r5, r0
   633d8: 9802         	ldr	r0, [sp, #0x8]
   633da: 1b80         	subs	r0, r0, r6
   633dc: 9009         	str	r0, [sp, #0x24]
   633de: 1c07         	adds	r7, r0, #0x0
   633e0: 4660         	mov	r0, r12
   633e2: 4378         	muls	r0, r7, r0
   633e4: 1280         	asrs	r0, r0, #0xa
   633e6: 1836         	adds	r6, r6, r0
   633e8: 2c1f         	cmp	r4, #0x1f
   633ea: dd00         	ble	0x633ee <rom+0x633ee>   @ imm = #0x0
   633ec: 241f         	movs	r4, #0x1f
   633ee: 291f         	cmp	r1, #0x1f
   633f0: dd00         	ble	0x633f4 <rom+0x633f4>   @ imm = #0x0
   633f2: 211f         	movs	r1, #0x1f
   633f4: 2a1f         	cmp	r2, #0x1f
   633f6: dd00         	ble	0x633fa <rom+0x633fa>   @ imm = #0x0
   633f8: 221f         	movs	r2, #0x1f
   633fa: 2b1f         	cmp	r3, #0x1f
   633fc: dd00         	ble	0x63400 <rom+0x63400>   @ imm = #0x0
   633fe: 231f         	movs	r3, #0x1f
