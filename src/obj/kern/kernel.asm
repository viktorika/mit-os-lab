
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6a 00 00 00       	call   f01000a8 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 6e 22 f0 00 	cmpl   $0x0,0xf0226e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 6e 22 f0    	mov    %esi,0xf0226e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 ef 66 00 00       	call   f0106753 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 60 6e 10 f0 	movl   $0xf0106e60,(%esp)
f010007d:	e8 47 3f 00 00       	call   f0103fc9 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 08 3f 00 00       	call   f0103f96 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 de 76 10 f0 	movl   $0xf01076de,(%esp)
f0100095:	e8 2f 3f 00 00       	call   f0103fc9 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 2a 09 00 00       	call   f01009d0 <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <i386_init>:
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	53                   	push   %ebx
f01000ac:	83 ec 14             	sub    $0x14,%esp
	memset(edata, 0, end - edata);
f01000af:	b8 08 80 26 f0       	mov    $0xf0268008,%eax
f01000b4:	2d 00 60 22 f0       	sub    $0xf0226000,%eax
f01000b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000c4:	00 
f01000c5:	c7 04 24 00 60 22 f0 	movl   $0xf0226000,(%esp)
f01000cc:	e8 e8 5f 00 00       	call   f01060b9 <memset>
	cons_init();
f01000d1:	e8 c9 05 00 00       	call   f010069f <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000dd:	00 
f01000de:	c7 04 24 cc 6e 10 f0 	movl   $0xf0106ecc,(%esp)
f01000e5:	e8 df 3e 00 00       	call   f0103fc9 <cprintf>
	mem_init();
f01000ea:	e8 0c 14 00 00       	call   f01014fb <mem_init>
	env_init();
f01000ef:	e8 63 36 00 00       	call   f0103757 <env_init>
	trap_init();
f01000f4:	e8 c5 3f 00 00       	call   f01040be <trap_init>
	mp_init();
f01000f9:	e8 3b 63 00 00       	call   f0106439 <mp_init>
	lapic_init();
f01000fe:	66 90                	xchg   %ax,%ax
f0100100:	e8 69 66 00 00       	call   f010676e <lapic_init>
	pic_init();
f0100105:	e8 ef 3d 00 00       	call   f0103ef9 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010010a:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100111:	e8 bb 68 00 00       	call   f01069d1 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100116:	83 3d 88 6e 22 f0 07 	cmpl   $0x7,0xf0226e88
f010011d:	77 24                	ja     f0100143 <i386_init+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100126:	00 
f0100127:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f010012e:	f0 
f010012f:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f0100136:	00 
f0100137:	c7 04 24 e7 6e 10 f0 	movl   $0xf0106ee7,(%esp)
f010013e:	e8 fd fe ff ff       	call   f0100040 <_panic>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100143:	b8 66 63 10 f0       	mov    $0xf0106366,%eax
f0100148:	2d ec 62 10 f0       	sub    $0xf01062ec,%eax
f010014d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100151:	c7 44 24 04 ec 62 10 	movl   $0xf01062ec,0x4(%esp)
f0100158:	f0 
f0100159:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100160:	e8 a1 5f 00 00       	call   f0106106 <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100165:	6b 05 c4 73 22 f0 74 	imul   $0x74,0xf02273c4,%eax
f010016c:	05 20 70 22 f0       	add    $0xf0227020,%eax
f0100171:	3d 20 70 22 f0       	cmp    $0xf0227020,%eax
f0100176:	76 62                	jbe    f01001da <i386_init+0x132>
f0100178:	bb 20 70 22 f0       	mov    $0xf0227020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f010017d:	e8 d1 65 00 00       	call   f0106753 <cpunum>
f0100182:	6b c0 74             	imul   $0x74,%eax,%eax
f0100185:	05 20 70 22 f0       	add    $0xf0227020,%eax
f010018a:	39 c3                	cmp    %eax,%ebx
f010018c:	74 39                	je     f01001c7 <i386_init+0x11f>
f010018e:	89 d8                	mov    %ebx,%eax
f0100190:	2d 20 70 22 f0       	sub    $0xf0227020,%eax
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100195:	c1 f8 02             	sar    $0x2,%eax
f0100198:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010019e:	c1 e0 0f             	shl    $0xf,%eax
f01001a1:	8d 80 00 00 23 f0    	lea    -0xfdd0000(%eax),%eax
f01001a7:	a3 84 6e 22 f0       	mov    %eax,0xf0226e84
		lapic_startap(c->cpu_id, PADDR(code));
f01001ac:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f01001b3:	00 
f01001b4:	0f b6 03             	movzbl (%ebx),%eax
f01001b7:	89 04 24             	mov    %eax,(%esp)
f01001ba:	e8 ff 66 00 00       	call   f01068be <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f01001bf:	8b 43 04             	mov    0x4(%ebx),%eax
f01001c2:	83 f8 01             	cmp    $0x1,%eax
f01001c5:	75 f8                	jne    f01001bf <i386_init+0x117>
	for (c = cpus; c < cpus + ncpu; c++) {
f01001c7:	83 c3 74             	add    $0x74,%ebx
f01001ca:	6b 05 c4 73 22 f0 74 	imul   $0x74,0xf02273c4,%eax
f01001d1:	05 20 70 22 f0       	add    $0xf0227020,%eax
f01001d6:	39 c3                	cmp    %eax,%ebx
f01001d8:	72 a3                	jb     f010017d <i386_init+0xd5>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01001e1:	00 
f01001e2:	c7 44 24 04 44 9a 00 	movl   $0x9a44,0x4(%esp)
f01001e9:	00 
f01001ea:	c7 04 24 6c c4 21 f0 	movl   $0xf021c46c,(%esp)
f01001f1:	e8 68 37 00 00       	call   f010395e <env_create>
	sched_yield();
f01001f6:	e8 b0 4a 00 00       	call   f0104cab <sched_yield>

f01001fb <mp_main>:
{
f01001fb:	55                   	push   %ebp
f01001fc:	89 e5                	mov    %esp,%ebp
f01001fe:	83 ec 18             	sub    $0x18,%esp
	lcr3(PADDR(kern_pgdir));
f0100201:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0100206:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010020b:	77 20                	ja     f010022d <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010020d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100211:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0100218:	f0 
f0100219:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f0100220:	00 
f0100221:	c7 04 24 e7 6e 10 f0 	movl   $0xf0106ee7,(%esp)
f0100228:	e8 13 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010022d:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100232:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100235:	e8 19 65 00 00       	call   f0106753 <cpunum>
f010023a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010023e:	c7 04 24 f3 6e 10 f0 	movl   $0xf0106ef3,(%esp)
f0100245:	e8 7f 3d 00 00       	call   f0103fc9 <cprintf>
	lapic_init();
f010024a:	e8 1f 65 00 00       	call   f010676e <lapic_init>
	env_init_percpu();
f010024f:	e8 d9 34 00 00       	call   f010372d <env_init_percpu>
	trap_init_percpu();
f0100254:	e8 97 3d 00 00       	call   f0103ff0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100259:	e8 f5 64 00 00       	call   f0106753 <cpunum>
f010025e:	6b d0 74             	imul   $0x74,%eax,%edx
f0100261:	81 c2 20 70 22 f0    	add    $0xf0227020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100267:	b8 01 00 00 00       	mov    $0x1,%eax
f010026c:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100270:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100277:	e8 55 67 00 00       	call   f01069d1 <spin_lock>
	sched_yield();
f010027c:	e8 2a 4a 00 00       	call   f0104cab <sched_yield>

f0100281 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100281:	55                   	push   %ebp
f0100282:	89 e5                	mov    %esp,%ebp
f0100284:	53                   	push   %ebx
f0100285:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100288:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010028b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010028e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100292:	8b 45 08             	mov    0x8(%ebp),%eax
f0100295:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100299:	c7 04 24 09 6f 10 f0 	movl   $0xf0106f09,(%esp)
f01002a0:	e8 24 3d 00 00       	call   f0103fc9 <cprintf>
	vcprintf(fmt, ap);
f01002a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002a9:	8b 45 10             	mov    0x10(%ebp),%eax
f01002ac:	89 04 24             	mov    %eax,(%esp)
f01002af:	e8 e2 3c 00 00       	call   f0103f96 <vcprintf>
	cprintf("\n");
f01002b4:	c7 04 24 de 76 10 f0 	movl   $0xf01076de,(%esp)
f01002bb:	e8 09 3d 00 00       	call   f0103fc9 <cprintf>
	va_end(ap);
}
f01002c0:	83 c4 14             	add    $0x14,%esp
f01002c3:	5b                   	pop    %ebx
f01002c4:	5d                   	pop    %ebp
f01002c5:	c3                   	ret    
f01002c6:	66 90                	xchg   %ax,%ax
f01002c8:	66 90                	xchg   %ax,%ax
f01002ca:	66 90                	xchg   %ax,%ax
f01002cc:	66 90                	xchg   %ax,%ax
f01002ce:	66 90                	xchg   %ax,%ax

f01002d0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002d0:	55                   	push   %ebp
f01002d1:	89 e5                	mov    %esp,%ebp
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002d8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002d9:	a8 01                	test   $0x1,%al
f01002db:	74 08                	je     f01002e5 <serial_proc_data+0x15>
f01002dd:	b2 f8                	mov    $0xf8,%dl
f01002df:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002e0:	0f b6 c0             	movzbl %al,%eax
f01002e3:	eb 05                	jmp    f01002ea <serial_proc_data+0x1a>
		return -1;
f01002e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01002ea:	5d                   	pop    %ebp
f01002eb:	c3                   	ret    

f01002ec <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002ec:	55                   	push   %ebp
f01002ed:	89 e5                	mov    %esp,%ebp
f01002ef:	53                   	push   %ebx
f01002f0:	83 ec 04             	sub    $0x4,%esp
f01002f3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002f5:	eb 2a                	jmp    f0100321 <cons_intr+0x35>
		if (c == 0)
f01002f7:	85 d2                	test   %edx,%edx
f01002f9:	74 26                	je     f0100321 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002fb:	a1 24 62 22 f0       	mov    0xf0226224,%eax
f0100300:	8d 48 01             	lea    0x1(%eax),%ecx
f0100303:	89 0d 24 62 22 f0    	mov    %ecx,0xf0226224
f0100309:	88 90 20 60 22 f0    	mov    %dl,-0xfdd9fe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010030f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100315:	75 0a                	jne    f0100321 <cons_intr+0x35>
			cons.wpos = 0;
f0100317:	c7 05 24 62 22 f0 00 	movl   $0x0,0xf0226224
f010031e:	00 00 00 
	while ((c = (*proc)()) != -1) {
f0100321:	ff d3                	call   *%ebx
f0100323:	89 c2                	mov    %eax,%edx
f0100325:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100328:	75 cd                	jne    f01002f7 <cons_intr+0xb>
	}
}
f010032a:	83 c4 04             	add    $0x4,%esp
f010032d:	5b                   	pop    %ebx
f010032e:	5d                   	pop    %ebp
f010032f:	c3                   	ret    

f0100330 <kbd_proc_data>:
f0100330:	ba 64 00 00 00       	mov    $0x64,%edx
f0100335:	ec                   	in     (%dx),%al
	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100336:	a8 01                	test   $0x1,%al
f0100338:	0f 84 ef 00 00 00    	je     f010042d <kbd_proc_data+0xfd>
f010033e:	b2 60                	mov    $0x60,%dl
f0100340:	ec                   	in     (%dx),%al
f0100341:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100343:	3c e0                	cmp    $0xe0,%al
f0100345:	75 0d                	jne    f0100354 <kbd_proc_data+0x24>
		shift |= E0ESC;
f0100347:	83 0d 00 60 22 f0 40 	orl    $0x40,0xf0226000
		return 0;
f010034e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100353:	c3                   	ret    
{
f0100354:	55                   	push   %ebp
f0100355:	89 e5                	mov    %esp,%ebp
f0100357:	53                   	push   %ebx
f0100358:	83 ec 14             	sub    $0x14,%esp
	} else if (data & 0x80) {
f010035b:	84 c0                	test   %al,%al
f010035d:	79 37                	jns    f0100396 <kbd_proc_data+0x66>
		data = (shift & E0ESC ? data : data & 0x7F);
f010035f:	8b 0d 00 60 22 f0    	mov    0xf0226000,%ecx
f0100365:	89 cb                	mov    %ecx,%ebx
f0100367:	83 e3 40             	and    $0x40,%ebx
f010036a:	83 e0 7f             	and    $0x7f,%eax
f010036d:	85 db                	test   %ebx,%ebx
f010036f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100372:	0f b6 d2             	movzbl %dl,%edx
f0100375:	0f b6 82 80 70 10 f0 	movzbl -0xfef8f80(%edx),%eax
f010037c:	83 c8 40             	or     $0x40,%eax
f010037f:	0f b6 c0             	movzbl %al,%eax
f0100382:	f7 d0                	not    %eax
f0100384:	21 c1                	and    %eax,%ecx
f0100386:	89 0d 00 60 22 f0    	mov    %ecx,0xf0226000
		return 0;
f010038c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100391:	e9 9d 00 00 00       	jmp    f0100433 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100396:	8b 0d 00 60 22 f0    	mov    0xf0226000,%ecx
f010039c:	f6 c1 40             	test   $0x40,%cl
f010039f:	74 0e                	je     f01003af <kbd_proc_data+0x7f>
		data |= 0x80;
f01003a1:	83 c8 80             	or     $0xffffff80,%eax
f01003a4:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01003a6:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003a9:	89 0d 00 60 22 f0    	mov    %ecx,0xf0226000
	shift |= shiftcode[data];
f01003af:	0f b6 d2             	movzbl %dl,%edx
f01003b2:	0f b6 82 80 70 10 f0 	movzbl -0xfef8f80(%edx),%eax
f01003b9:	0b 05 00 60 22 f0    	or     0xf0226000,%eax
	shift ^= togglecode[data];
f01003bf:	0f b6 8a 80 6f 10 f0 	movzbl -0xfef9080(%edx),%ecx
f01003c6:	31 c8                	xor    %ecx,%eax
f01003c8:	a3 00 60 22 f0       	mov    %eax,0xf0226000
	c = charcode[shift & (CTL | SHIFT)][data];
f01003cd:	89 c1                	mov    %eax,%ecx
f01003cf:	83 e1 03             	and    $0x3,%ecx
f01003d2:	8b 0c 8d 60 6f 10 f0 	mov    -0xfef90a0(,%ecx,4),%ecx
f01003d9:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003dd:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003e0:	a8 08                	test   $0x8,%al
f01003e2:	74 1b                	je     f01003ff <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f01003e4:	89 da                	mov    %ebx,%edx
f01003e6:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003e9:	83 f9 19             	cmp    $0x19,%ecx
f01003ec:	77 05                	ja     f01003f3 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f01003ee:	83 eb 20             	sub    $0x20,%ebx
f01003f1:	eb 0c                	jmp    f01003ff <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f01003f3:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003f6:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003f9:	83 fa 19             	cmp    $0x19,%edx
f01003fc:	0f 46 d9             	cmovbe %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003ff:	f7 d0                	not    %eax
f0100401:	89 c2                	mov    %eax,%edx
	return c;
f0100403:	89 d8                	mov    %ebx,%eax
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100405:	f6 c2 06             	test   $0x6,%dl
f0100408:	75 29                	jne    f0100433 <kbd_proc_data+0x103>
f010040a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100410:	75 21                	jne    f0100433 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f0100412:	c7 04 24 23 6f 10 f0 	movl   $0xf0106f23,(%esp)
f0100419:	e8 ab 3b 00 00       	call   f0103fc9 <cprintf>
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010041e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100423:	b8 03 00 00 00       	mov    $0x3,%eax
f0100428:	ee                   	out    %al,(%dx)
	return c;
f0100429:	89 d8                	mov    %ebx,%eax
f010042b:	eb 06                	jmp    f0100433 <kbd_proc_data+0x103>
		return -1;
f010042d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100432:	c3                   	ret    
}
f0100433:	83 c4 14             	add    $0x14,%esp
f0100436:	5b                   	pop    %ebx
f0100437:	5d                   	pop    %ebp
f0100438:	c3                   	ret    

f0100439 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100439:	55                   	push   %ebp
f010043a:	89 e5                	mov    %esp,%ebp
f010043c:	57                   	push   %edi
f010043d:	56                   	push   %esi
f010043e:	53                   	push   %ebx
f010043f:	83 ec 1c             	sub    $0x1c,%esp
f0100442:	89 c7                	mov    %eax,%edi
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100444:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100449:	ec                   	in     (%dx),%al
	for (i = 0;
f010044a:	a8 20                	test   $0x20,%al
f010044c:	75 21                	jne    f010046f <cons_putc+0x36>
f010044e:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100453:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100458:	be fd 03 00 00       	mov    $0x3fd,%esi
f010045d:	89 ca                	mov    %ecx,%edx
f010045f:	ec                   	in     (%dx),%al
f0100460:	ec                   	in     (%dx),%al
f0100461:	ec                   	in     (%dx),%al
f0100462:	ec                   	in     (%dx),%al
f0100463:	89 f2                	mov    %esi,%edx
f0100465:	ec                   	in     (%dx),%al
f0100466:	a8 20                	test   $0x20,%al
f0100468:	75 05                	jne    f010046f <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010046a:	83 eb 01             	sub    $0x1,%ebx
f010046d:	75 ee                	jne    f010045d <cons_putc+0x24>
	outb(COM1 + COM_TX, c);
f010046f:	89 f8                	mov    %edi,%eax
f0100471:	0f b6 c0             	movzbl %al,%eax
f0100474:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100477:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010047c:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010047d:	b2 79                	mov    $0x79,%dl
f010047f:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100480:	84 c0                	test   %al,%al
f0100482:	78 21                	js     f01004a5 <cons_putc+0x6c>
f0100484:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100489:	b9 84 00 00 00       	mov    $0x84,%ecx
f010048e:	be 79 03 00 00       	mov    $0x379,%esi
f0100493:	89 ca                	mov    %ecx,%edx
f0100495:	ec                   	in     (%dx),%al
f0100496:	ec                   	in     (%dx),%al
f0100497:	ec                   	in     (%dx),%al
f0100498:	ec                   	in     (%dx),%al
f0100499:	89 f2                	mov    %esi,%edx
f010049b:	ec                   	in     (%dx),%al
f010049c:	84 c0                	test   %al,%al
f010049e:	78 05                	js     f01004a5 <cons_putc+0x6c>
f01004a0:	83 eb 01             	sub    $0x1,%ebx
f01004a3:	75 ee                	jne    f0100493 <cons_putc+0x5a>
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004a5:	ba 78 03 00 00       	mov    $0x378,%edx
f01004aa:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01004ae:	ee                   	out    %al,(%dx)
f01004af:	b2 7a                	mov    $0x7a,%dl
f01004b1:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004b6:	ee                   	out    %al,(%dx)
f01004b7:	b8 08 00 00 00       	mov    $0x8,%eax
f01004bc:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01004bd:	89 fa                	mov    %edi,%edx
f01004bf:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004c5:	89 f8                	mov    %edi,%eax
f01004c7:	80 cc 07             	or     $0x7,%ah
f01004ca:	85 d2                	test   %edx,%edx
f01004cc:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f01004cf:	89 f8                	mov    %edi,%eax
f01004d1:	0f b6 c0             	movzbl %al,%eax
f01004d4:	83 f8 09             	cmp    $0x9,%eax
f01004d7:	74 79                	je     f0100552 <cons_putc+0x119>
f01004d9:	83 f8 09             	cmp    $0x9,%eax
f01004dc:	7f 0a                	jg     f01004e8 <cons_putc+0xaf>
f01004de:	83 f8 08             	cmp    $0x8,%eax
f01004e1:	74 19                	je     f01004fc <cons_putc+0xc3>
f01004e3:	e9 9e 00 00 00       	jmp    f0100586 <cons_putc+0x14d>
f01004e8:	83 f8 0a             	cmp    $0xa,%eax
f01004eb:	90                   	nop
f01004ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01004f0:	74 3a                	je     f010052c <cons_putc+0xf3>
f01004f2:	83 f8 0d             	cmp    $0xd,%eax
f01004f5:	74 3d                	je     f0100534 <cons_putc+0xfb>
f01004f7:	e9 8a 00 00 00       	jmp    f0100586 <cons_putc+0x14d>
		if (crt_pos > 0) {
f01004fc:	0f b7 05 28 62 22 f0 	movzwl 0xf0226228,%eax
f0100503:	66 85 c0             	test   %ax,%ax
f0100506:	0f 84 e5 00 00 00    	je     f01005f1 <cons_putc+0x1b8>
			crt_pos--;
f010050c:	83 e8 01             	sub    $0x1,%eax
f010050f:	66 a3 28 62 22 f0    	mov    %ax,0xf0226228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100515:	0f b7 c0             	movzwl %ax,%eax
f0100518:	66 81 e7 00 ff       	and    $0xff00,%di
f010051d:	83 cf 20             	or     $0x20,%edi
f0100520:	8b 15 2c 62 22 f0    	mov    0xf022622c,%edx
f0100526:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010052a:	eb 78                	jmp    f01005a4 <cons_putc+0x16b>
		crt_pos += CRT_COLS;
f010052c:	66 83 05 28 62 22 f0 	addw   $0x50,0xf0226228
f0100533:	50 
		crt_pos -= (crt_pos % CRT_COLS);
f0100534:	0f b7 05 28 62 22 f0 	movzwl 0xf0226228,%eax
f010053b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100541:	c1 e8 16             	shr    $0x16,%eax
f0100544:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100547:	c1 e0 04             	shl    $0x4,%eax
f010054a:	66 a3 28 62 22 f0    	mov    %ax,0xf0226228
f0100550:	eb 52                	jmp    f01005a4 <cons_putc+0x16b>
		cons_putc(' ');
f0100552:	b8 20 00 00 00       	mov    $0x20,%eax
f0100557:	e8 dd fe ff ff       	call   f0100439 <cons_putc>
		cons_putc(' ');
f010055c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100561:	e8 d3 fe ff ff       	call   f0100439 <cons_putc>
		cons_putc(' ');
f0100566:	b8 20 00 00 00       	mov    $0x20,%eax
f010056b:	e8 c9 fe ff ff       	call   f0100439 <cons_putc>
		cons_putc(' ');
f0100570:	b8 20 00 00 00       	mov    $0x20,%eax
f0100575:	e8 bf fe ff ff       	call   f0100439 <cons_putc>
		cons_putc(' ');
f010057a:	b8 20 00 00 00       	mov    $0x20,%eax
f010057f:	e8 b5 fe ff ff       	call   f0100439 <cons_putc>
f0100584:	eb 1e                	jmp    f01005a4 <cons_putc+0x16b>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100586:	0f b7 05 28 62 22 f0 	movzwl 0xf0226228,%eax
f010058d:	8d 50 01             	lea    0x1(%eax),%edx
f0100590:	66 89 15 28 62 22 f0 	mov    %dx,0xf0226228
f0100597:	0f b7 c0             	movzwl %ax,%eax
f010059a:	8b 15 2c 62 22 f0    	mov    0xf022622c,%edx
f01005a0:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
	if (crt_pos >= CRT_SIZE) {
f01005a4:	66 81 3d 28 62 22 f0 	cmpw   $0x7cf,0xf0226228
f01005ab:	cf 07 
f01005ad:	76 42                	jbe    f01005f1 <cons_putc+0x1b8>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005af:	a1 2c 62 22 f0       	mov    0xf022622c,%eax
f01005b4:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005bb:	00 
f01005bc:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005c2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005c6:	89 04 24             	mov    %eax,(%esp)
f01005c9:	e8 38 5b 00 00       	call   f0106106 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005ce:	8b 15 2c 62 22 f0    	mov    0xf022622c,%edx
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005d4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005d9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005df:	83 c0 01             	add    $0x1,%eax
f01005e2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005e7:	75 f0                	jne    f01005d9 <cons_putc+0x1a0>
		crt_pos -= CRT_COLS;
f01005e9:	66 83 2d 28 62 22 f0 	subw   $0x50,0xf0226228
f01005f0:	50 
	outb(addr_6845, 14);
f01005f1:	8b 0d 30 62 22 f0    	mov    0xf0226230,%ecx
f01005f7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005fc:	89 ca                	mov    %ecx,%edx
f01005fe:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005ff:	0f b7 1d 28 62 22 f0 	movzwl 0xf0226228,%ebx
f0100606:	8d 71 01             	lea    0x1(%ecx),%esi
f0100609:	89 d8                	mov    %ebx,%eax
f010060b:	66 c1 e8 08          	shr    $0x8,%ax
f010060f:	89 f2                	mov    %esi,%edx
f0100611:	ee                   	out    %al,(%dx)
f0100612:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100617:	89 ca                	mov    %ecx,%edx
f0100619:	ee                   	out    %al,(%dx)
f010061a:	89 d8                	mov    %ebx,%eax
f010061c:	89 f2                	mov    %esi,%edx
f010061e:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010061f:	83 c4 1c             	add    $0x1c,%esp
f0100622:	5b                   	pop    %ebx
f0100623:	5e                   	pop    %esi
f0100624:	5f                   	pop    %edi
f0100625:	5d                   	pop    %ebp
f0100626:	c3                   	ret    

f0100627 <serial_intr>:
	if (serial_exists)
f0100627:	80 3d 34 62 22 f0 00 	cmpb   $0x0,0xf0226234
f010062e:	74 11                	je     f0100641 <serial_intr+0x1a>
{
f0100630:	55                   	push   %ebp
f0100631:	89 e5                	mov    %esp,%ebp
f0100633:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100636:	b8 d0 02 10 f0       	mov    $0xf01002d0,%eax
f010063b:	e8 ac fc ff ff       	call   f01002ec <cons_intr>
}
f0100640:	c9                   	leave  
f0100641:	f3 c3                	repz ret 

f0100643 <kbd_intr>:
{
f0100643:	55                   	push   %ebp
f0100644:	89 e5                	mov    %esp,%ebp
f0100646:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100649:	b8 30 03 10 f0       	mov    $0xf0100330,%eax
f010064e:	e8 99 fc ff ff       	call   f01002ec <cons_intr>
}
f0100653:	c9                   	leave  
f0100654:	c3                   	ret    

f0100655 <cons_getc>:
{
f0100655:	55                   	push   %ebp
f0100656:	89 e5                	mov    %esp,%ebp
f0100658:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010065b:	e8 c7 ff ff ff       	call   f0100627 <serial_intr>
	kbd_intr();
f0100660:	e8 de ff ff ff       	call   f0100643 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100665:	a1 20 62 22 f0       	mov    0xf0226220,%eax
f010066a:	3b 05 24 62 22 f0    	cmp    0xf0226224,%eax
f0100670:	74 26                	je     f0100698 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100672:	8d 50 01             	lea    0x1(%eax),%edx
f0100675:	89 15 20 62 22 f0    	mov    %edx,0xf0226220
f010067b:	0f b6 88 20 60 22 f0 	movzbl -0xfdd9fe0(%eax),%ecx
		return c;
f0100682:	89 c8                	mov    %ecx,%eax
		if (cons.rpos == CONSBUFSIZE)
f0100684:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010068a:	75 11                	jne    f010069d <cons_getc+0x48>
			cons.rpos = 0;
f010068c:	c7 05 20 62 22 f0 00 	movl   $0x0,0xf0226220
f0100693:	00 00 00 
f0100696:	eb 05                	jmp    f010069d <cons_getc+0x48>
	return 0;
f0100698:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010069d:	c9                   	leave  
f010069e:	c3                   	ret    

f010069f <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010069f:	55                   	push   %ebp
f01006a0:	89 e5                	mov    %esp,%ebp
f01006a2:	57                   	push   %edi
f01006a3:	56                   	push   %esi
f01006a4:	53                   	push   %ebx
f01006a5:	83 ec 1c             	sub    $0x1c,%esp
	was = *cp;
f01006a8:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01006af:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006b6:	5a a5 
	if (*cp != 0xA55A) {
f01006b8:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006bf:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006c3:	74 11                	je     f01006d6 <cons_init+0x37>
		addr_6845 = MONO_BASE;
f01006c5:	c7 05 30 62 22 f0 b4 	movl   $0x3b4,0xf0226230
f01006cc:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006cf:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006d4:	eb 16                	jmp    f01006ec <cons_init+0x4d>
		*cp = was;
f01006d6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006dd:	c7 05 30 62 22 f0 d4 	movl   $0x3d4,0xf0226230
f01006e4:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006e7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
	outb(addr_6845, 14);
f01006ec:	8b 0d 30 62 22 f0    	mov    0xf0226230,%ecx
f01006f2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006f7:	89 ca                	mov    %ecx,%edx
f01006f9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006fa:	8d 59 01             	lea    0x1(%ecx),%ebx
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006fd:	89 da                	mov    %ebx,%edx
f01006ff:	ec                   	in     (%dx),%al
f0100700:	0f b6 f0             	movzbl %al,%esi
f0100703:	c1 e6 08             	shl    $0x8,%esi
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100706:	b8 0f 00 00 00       	mov    $0xf,%eax
f010070b:	89 ca                	mov    %ecx,%edx
f010070d:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010070e:	89 da                	mov    %ebx,%edx
f0100710:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100711:	89 3d 2c 62 22 f0    	mov    %edi,0xf022622c
	pos |= inb(addr_6845 + 1);
f0100717:	0f b6 d8             	movzbl %al,%ebx
f010071a:	09 de                	or     %ebx,%esi
	crt_pos = pos;
f010071c:	66 89 35 28 62 22 f0 	mov    %si,0xf0226228
	kbd_intr();
f0100723:	e8 1b ff ff ff       	call   f0100643 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100728:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010072f:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100734:	89 04 24             	mov    %eax,(%esp)
f0100737:	e8 4e 37 00 00       	call   f0103e8a <irq_setmask_8259A>
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010073c:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100741:	b8 00 00 00 00       	mov    $0x0,%eax
f0100746:	89 f2                	mov    %esi,%edx
f0100748:	ee                   	out    %al,(%dx)
f0100749:	b2 fb                	mov    $0xfb,%dl
f010074b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100750:	ee                   	out    %al,(%dx)
f0100751:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100756:	b8 0c 00 00 00       	mov    $0xc,%eax
f010075b:	89 da                	mov    %ebx,%edx
f010075d:	ee                   	out    %al,(%dx)
f010075e:	b2 f9                	mov    $0xf9,%dl
f0100760:	b8 00 00 00 00       	mov    $0x0,%eax
f0100765:	ee                   	out    %al,(%dx)
f0100766:	b2 fb                	mov    $0xfb,%dl
f0100768:	b8 03 00 00 00       	mov    $0x3,%eax
f010076d:	ee                   	out    %al,(%dx)
f010076e:	b2 fc                	mov    $0xfc,%dl
f0100770:	b8 00 00 00 00       	mov    $0x0,%eax
f0100775:	ee                   	out    %al,(%dx)
f0100776:	b2 f9                	mov    $0xf9,%dl
f0100778:	b8 01 00 00 00       	mov    $0x1,%eax
f010077d:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010077e:	b2 fd                	mov    $0xfd,%dl
f0100780:	ec                   	in     (%dx),%al
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100781:	3c ff                	cmp    $0xff,%al
f0100783:	0f 95 c1             	setne  %cl
f0100786:	88 0d 34 62 22 f0    	mov    %cl,0xf0226234
f010078c:	89 f2                	mov    %esi,%edx
f010078e:	ec                   	in     (%dx),%al
f010078f:	89 da                	mov    %ebx,%edx
f0100791:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100792:	84 c9                	test   %cl,%cl
f0100794:	75 0c                	jne    f01007a2 <cons_init+0x103>
		cprintf("Serial port does not exist!\n");
f0100796:	c7 04 24 2f 6f 10 f0 	movl   $0xf0106f2f,(%esp)
f010079d:	e8 27 38 00 00       	call   f0103fc9 <cprintf>
}
f01007a2:	83 c4 1c             	add    $0x1c,%esp
f01007a5:	5b                   	pop    %ebx
f01007a6:	5e                   	pop    %esi
f01007a7:	5f                   	pop    %edi
f01007a8:	5d                   	pop    %ebp
f01007a9:	c3                   	ret    

f01007aa <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007aa:	55                   	push   %ebp
f01007ab:	89 e5                	mov    %esp,%ebp
f01007ad:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01007b3:	e8 81 fc ff ff       	call   f0100439 <cons_putc>
}
f01007b8:	c9                   	leave  
f01007b9:	c3                   	ret    

f01007ba <getchar>:

int
getchar(void)
{
f01007ba:	55                   	push   %ebp
f01007bb:	89 e5                	mov    %esp,%ebp
f01007bd:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007c0:	e8 90 fe ff ff       	call   f0100655 <cons_getc>
f01007c5:	85 c0                	test   %eax,%eax
f01007c7:	74 f7                	je     f01007c0 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007c9:	c9                   	leave  
f01007ca:	c3                   	ret    

f01007cb <iscons>:

int
iscons(int fdnum)
{
f01007cb:	55                   	push   %ebp
f01007cc:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007ce:	b8 01 00 00 00       	mov    $0x1,%eax
f01007d3:	5d                   	pop    %ebp
f01007d4:	c3                   	ret    
f01007d5:	66 90                	xchg   %ax,%ax
f01007d7:	66 90                	xchg   %ax,%ax
f01007d9:	66 90                	xchg   %ax,%ax
f01007db:	66 90                	xchg   %ax,%ax
f01007dd:	66 90                	xchg   %ax,%ax
f01007df:	90                   	nop

f01007e0 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007e0:	55                   	push   %ebp
f01007e1:	89 e5                	mov    %esp,%ebp
f01007e3:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007e6:	c7 44 24 08 80 71 10 	movl   $0xf0107180,0x8(%esp)
f01007ed:	f0 
f01007ee:	c7 44 24 04 9e 71 10 	movl   $0xf010719e,0x4(%esp)
f01007f5:	f0 
f01007f6:	c7 04 24 a3 71 10 f0 	movl   $0xf01071a3,(%esp)
f01007fd:	e8 c7 37 00 00       	call   f0103fc9 <cprintf>
f0100802:	c7 44 24 08 54 72 10 	movl   $0xf0107254,0x8(%esp)
f0100809:	f0 
f010080a:	c7 44 24 04 ac 71 10 	movl   $0xf01071ac,0x4(%esp)
f0100811:	f0 
f0100812:	c7 04 24 a3 71 10 f0 	movl   $0xf01071a3,(%esp)
f0100819:	e8 ab 37 00 00       	call   f0103fc9 <cprintf>
f010081e:	c7 44 24 08 7c 72 10 	movl   $0xf010727c,0x8(%esp)
f0100825:	f0 
f0100826:	c7 44 24 04 b5 71 10 	movl   $0xf01071b5,0x4(%esp)
f010082d:	f0 
f010082e:	c7 04 24 a3 71 10 f0 	movl   $0xf01071a3,(%esp)
f0100835:	e8 8f 37 00 00       	call   f0103fc9 <cprintf>
	return 0;
}
f010083a:	b8 00 00 00 00       	mov    $0x0,%eax
f010083f:	c9                   	leave  
f0100840:	c3                   	ret    

f0100841 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100841:	55                   	push   %ebp
f0100842:	89 e5                	mov    %esp,%ebp
f0100844:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100847:	c7 04 24 bf 71 10 f0 	movl   $0xf01071bf,(%esp)
f010084e:	e8 76 37 00 00       	call   f0103fc9 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100853:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010085a:	00 
f010085b:	c7 04 24 b0 72 10 f0 	movl   $0xf01072b0,(%esp)
f0100862:	e8 62 37 00 00       	call   f0103fc9 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100867:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010086e:	00 
f010086f:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100876:	f0 
f0100877:	c7 04 24 d8 72 10 f0 	movl   $0xf01072d8,(%esp)
f010087e:	e8 46 37 00 00       	call   f0103fc9 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100883:	c7 44 24 08 57 6e 10 	movl   $0x106e57,0x8(%esp)
f010088a:	00 
f010088b:	c7 44 24 04 57 6e 10 	movl   $0xf0106e57,0x4(%esp)
f0100892:	f0 
f0100893:	c7 04 24 fc 72 10 f0 	movl   $0xf01072fc,(%esp)
f010089a:	e8 2a 37 00 00       	call   f0103fc9 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010089f:	c7 44 24 08 00 60 22 	movl   $0x226000,0x8(%esp)
f01008a6:	00 
f01008a7:	c7 44 24 04 00 60 22 	movl   $0xf0226000,0x4(%esp)
f01008ae:	f0 
f01008af:	c7 04 24 20 73 10 f0 	movl   $0xf0107320,(%esp)
f01008b6:	e8 0e 37 00 00       	call   f0103fc9 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008bb:	c7 44 24 08 08 80 26 	movl   $0x268008,0x8(%esp)
f01008c2:	00 
f01008c3:	c7 44 24 04 08 80 26 	movl   $0xf0268008,0x4(%esp)
f01008ca:	f0 
f01008cb:	c7 04 24 44 73 10 f0 	movl   $0xf0107344,(%esp)
f01008d2:	e8 f2 36 00 00       	call   f0103fc9 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01008d7:	b8 07 84 26 f0       	mov    $0xf0268407,%eax
f01008dc:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01008e1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008e6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008ec:	85 c0                	test   %eax,%eax
f01008ee:	0f 48 c2             	cmovs  %edx,%eax
f01008f1:	c1 f8 0a             	sar    $0xa,%eax
f01008f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008f8:	c7 04 24 68 73 10 f0 	movl   $0xf0107368,(%esp)
f01008ff:	e8 c5 36 00 00       	call   f0103fc9 <cprintf>
	return 0;
}
f0100904:	b8 00 00 00 00       	mov    $0x0,%eax
f0100909:	c9                   	leave  
f010090a:	c3                   	ret    

f010090b <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010090b:	55                   	push   %ebp
f010090c:	89 e5                	mov    %esp,%ebp
f010090e:	57                   	push   %edi
f010090f:	56                   	push   %esi
f0100910:	53                   	push   %ebx
f0100911:	83 ec 4c             	sub    $0x4c,%esp
	cprintf("Stack backtrace:\n");
f0100914:	c7 04 24 d8 71 10 f0 	movl   $0xf01071d8,(%esp)
f010091b:	e8 a9 36 00 00       	call   f0103fc9 <cprintf>
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100920:	89 e8                	mov    %ebp,%eax
f0100922:	89 c6                	mov    %eax,%esi
    unsigned int ebp, esp, eip;
    ebp = read_ebp(); 
    while(ebp){
f0100924:	85 c0                	test   %eax,%eax
f0100926:	0f 84 97 00 00 00    	je     f01009c3 <mon_backtrace+0xb8>
        eip = *(unsigned int *)(ebp + 4);
f010092c:	8d 5e 04             	lea    0x4(%esi),%ebx
f010092f:	8b 46 04             	mov    0x4(%esi),%eax
f0100932:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        esp = ebp + 4;
        cprintf("ebp %08x eip %08x args", ebp, eip);
f0100935:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100939:	89 74 24 04          	mov    %esi,0x4(%esp)
f010093d:	c7 04 24 ea 71 10 f0 	movl   $0xf01071ea,(%esp)
f0100944:	e8 80 36 00 00       	call   f0103fc9 <cprintf>
f0100949:	8d 7e 18             	lea    0x18(%esi),%edi
		int i;
        for(i = 0; i < 5; ++i){
            esp += 4;
f010094c:	83 c3 04             	add    $0x4,%ebx
            cprintf(" %08x", *(unsigned int *)esp);
f010094f:	8b 03                	mov    (%ebx),%eax
f0100951:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100955:	c7 04 24 01 72 10 f0 	movl   $0xf0107201,(%esp)
f010095c:	e8 68 36 00 00       	call   f0103fc9 <cprintf>
        for(i = 0; i < 5; ++i){
f0100961:	39 fb                	cmp    %edi,%ebx
f0100963:	75 e7                	jne    f010094c <mon_backtrace+0x41>
        }   
        cprintf("\n");
f0100965:	c7 04 24 de 76 10 f0 	movl   $0xf01076de,(%esp)
f010096c:	e8 58 36 00 00       	call   f0103fc9 <cprintf>
        struct Eipdebuginfo info;
		if (-1 == debuginfo_eip(eip, &info))
f0100971:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100974:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100978:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010097b:	89 3c 24             	mov    %edi,(%esp)
f010097e:	e8 40 4b 00 00       	call   f01054c3 <debuginfo_eip>
f0100983:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100986:	74 3b                	je     f01009c3 <mon_backtrace+0xb8>
			break;
        cprintf("%s:%d: %.*s+%u\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
f0100988:	89 f8                	mov    %edi,%eax
f010098a:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010098d:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100991:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100994:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100998:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010099b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010099f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01009a2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009a6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01009a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009ad:	c7 04 24 07 72 10 f0 	movl   $0xf0107207,(%esp)
f01009b4:	e8 10 36 00 00       	call   f0103fc9 <cprintf>
        ebp = *(unsigned int *)ebp;
f01009b9:	8b 36                	mov    (%esi),%esi
    while(ebp){
f01009bb:	85 f6                	test   %esi,%esi
f01009bd:	0f 85 69 ff ff ff    	jne    f010092c <mon_backtrace+0x21>
    }   
	return 0;
}
f01009c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01009c8:	83 c4 4c             	add    $0x4c,%esp
f01009cb:	5b                   	pop    %ebx
f01009cc:	5e                   	pop    %esi
f01009cd:	5f                   	pop    %edi
f01009ce:	5d                   	pop    %ebp
f01009cf:	c3                   	ret    

f01009d0 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009d0:	55                   	push   %ebp
f01009d1:	89 e5                	mov    %esp,%ebp
f01009d3:	57                   	push   %edi
f01009d4:	56                   	push   %esi
f01009d5:	53                   	push   %ebx
f01009d6:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009d9:	c7 04 24 94 73 10 f0 	movl   $0xf0107394,(%esp)
f01009e0:	e8 e4 35 00 00       	call   f0103fc9 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009e5:	c7 04 24 b8 73 10 f0 	movl   $0xf01073b8,(%esp)
f01009ec:	e8 d8 35 00 00       	call   f0103fc9 <cprintf>

	if (tf != NULL)
f01009f1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009f5:	74 0b                	je     f0100a02 <monitor+0x32>
		print_trapframe(tf);
f01009f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01009fa:	89 04 24             	mov    %eax,(%esp)
f01009fd:	e8 a3 3b 00 00       	call   f01045a5 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100a02:	c7 04 24 17 72 10 f0 	movl   $0xf0107217,(%esp)
f0100a09:	e8 d2 53 00 00       	call   f0105de0 <readline>
f0100a0e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a10:	85 c0                	test   %eax,%eax
f0100a12:	74 ee                	je     f0100a02 <monitor+0x32>
	argv[argc] = 0;
f0100a14:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a1b:	be 00 00 00 00       	mov    $0x0,%esi
f0100a20:	eb 0a                	jmp    f0100a2c <monitor+0x5c>
			*buf++ = 0;
f0100a22:	c6 03 00             	movb   $0x0,(%ebx)
f0100a25:	89 f7                	mov    %esi,%edi
f0100a27:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a2a:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a2c:	0f b6 03             	movzbl (%ebx),%eax
f0100a2f:	84 c0                	test   %al,%al
f0100a31:	74 6a                	je     f0100a9d <monitor+0xcd>
f0100a33:	0f be c0             	movsbl %al,%eax
f0100a36:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a3a:	c7 04 24 1b 72 10 f0 	movl   $0xf010721b,(%esp)
f0100a41:	e8 13 56 00 00       	call   f0106059 <strchr>
f0100a46:	85 c0                	test   %eax,%eax
f0100a48:	75 d8                	jne    f0100a22 <monitor+0x52>
		if (*buf == 0)
f0100a4a:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a4d:	74 4e                	je     f0100a9d <monitor+0xcd>
		if (argc == MAXARGS-1) {
f0100a4f:	83 fe 0f             	cmp    $0xf,%esi
f0100a52:	75 16                	jne    f0100a6a <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a54:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a5b:	00 
f0100a5c:	c7 04 24 20 72 10 f0 	movl   $0xf0107220,(%esp)
f0100a63:	e8 61 35 00 00       	call   f0103fc9 <cprintf>
f0100a68:	eb 98                	jmp    f0100a02 <monitor+0x32>
		argv[argc++] = buf;
f0100a6a:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a6d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a71:	0f b6 03             	movzbl (%ebx),%eax
f0100a74:	84 c0                	test   %al,%al
f0100a76:	75 0c                	jne    f0100a84 <monitor+0xb4>
f0100a78:	eb b0                	jmp    f0100a2a <monitor+0x5a>
			buf++;
f0100a7a:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a7d:	0f b6 03             	movzbl (%ebx),%eax
f0100a80:	84 c0                	test   %al,%al
f0100a82:	74 a6                	je     f0100a2a <monitor+0x5a>
f0100a84:	0f be c0             	movsbl %al,%eax
f0100a87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a8b:	c7 04 24 1b 72 10 f0 	movl   $0xf010721b,(%esp)
f0100a92:	e8 c2 55 00 00       	call   f0106059 <strchr>
f0100a97:	85 c0                	test   %eax,%eax
f0100a99:	74 df                	je     f0100a7a <monitor+0xaa>
f0100a9b:	eb 8d                	jmp    f0100a2a <monitor+0x5a>
	argv[argc] = 0;
f0100a9d:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100aa4:	00 
	if (argc == 0)
f0100aa5:	85 f6                	test   %esi,%esi
f0100aa7:	0f 84 55 ff ff ff    	je     f0100a02 <monitor+0x32>
f0100aad:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ab2:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		if (strcmp(argv[0], commands[i].name) == 0)
f0100ab5:	8b 04 85 e0 73 10 f0 	mov    -0xfef8c20(,%eax,4),%eax
f0100abc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ac0:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100ac3:	89 04 24             	mov    %eax,(%esp)
f0100ac6:	e8 0a 55 00 00       	call   f0105fd5 <strcmp>
f0100acb:	85 c0                	test   %eax,%eax
f0100acd:	75 24                	jne    f0100af3 <monitor+0x123>
			return commands[i].func(argc, argv, tf);
f0100acf:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ad2:	8b 55 08             	mov    0x8(%ebp),%edx
f0100ad5:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100ad9:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100adc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100ae0:	89 34 24             	mov    %esi,(%esp)
f0100ae3:	ff 14 85 e8 73 10 f0 	call   *-0xfef8c18(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100aea:	85 c0                	test   %eax,%eax
f0100aec:	78 25                	js     f0100b13 <monitor+0x143>
f0100aee:	e9 0f ff ff ff       	jmp    f0100a02 <monitor+0x32>
	for (i = 0; i < NCOMMANDS; i++) {
f0100af3:	83 c3 01             	add    $0x1,%ebx
f0100af6:	83 fb 03             	cmp    $0x3,%ebx
f0100af9:	75 b7                	jne    f0100ab2 <monitor+0xe2>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100afb:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100afe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b02:	c7 04 24 3d 72 10 f0 	movl   $0xf010723d,(%esp)
f0100b09:	e8 bb 34 00 00       	call   f0103fc9 <cprintf>
f0100b0e:	e9 ef fe ff ff       	jmp    f0100a02 <monitor+0x32>
				break;
	}
}
f0100b13:	83 c4 5c             	add    $0x5c,%esp
f0100b16:	5b                   	pop    %ebx
f0100b17:	5e                   	pop    %esi
f0100b18:	5f                   	pop    %edi
f0100b19:	5d                   	pop    %ebp
f0100b1a:	c3                   	ret    
f0100b1b:	66 90                	xchg   %ax,%ax
f0100b1d:	66 90                	xchg   %ax,%ax
f0100b1f:	90                   	nop

f0100b20 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b20:	55                   	push   %ebp
f0100b21:	89 e5                	mov    %esp,%ebp
f0100b23:	53                   	push   %ebx
f0100b24:	83 ec 14             	sub    $0x14,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b27:	83 3d 38 62 22 f0 00 	cmpl   $0x0,0xf0226238
f0100b2e:	75 11                	jne    f0100b41 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b30:	ba 07 90 26 f0       	mov    $0xf0269007,%edx
f0100b35:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b3b:	89 15 38 62 22 f0    	mov    %edx,0xf0226238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if((unsigned)nextfree + n > KERNBASE + npages * PGSIZE)
f0100b41:	8b 15 38 62 22 f0    	mov    0xf0226238,%edx
f0100b47:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
f0100b4a:	8b 0d 88 6e 22 f0    	mov    0xf0226e88,%ecx
f0100b50:	81 c1 00 00 0f 00    	add    $0xf0000,%ecx
f0100b56:	c1 e1 0c             	shl    $0xc,%ecx
f0100b59:	39 cb                	cmp    %ecx,%ebx
f0100b5b:	76 1c                	jbe    f0100b79 <boot_alloc+0x59>
    	panic("boot_alloc: out of memory\n");
f0100b5d:	c7 44 24 08 04 74 10 	movl   $0xf0107404,0x8(%esp)
f0100b64:	f0 
f0100b65:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
f0100b6c:	00 
f0100b6d:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0100b74:	e8 c7 f4 ff ff       	call   f0100040 <_panic>
	result = nextfree;
	nextfree = ROUNDUP((char *)(nextfree + n), PGSIZE);
f0100b79:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b85:	a3 38 62 22 f0       	mov    %eax,0xf0226238
	return result;
}
f0100b8a:	89 d0                	mov    %edx,%eax
f0100b8c:	83 c4 14             	add    $0x14,%esp
f0100b8f:	5b                   	pop    %ebx
f0100b90:	5d                   	pop    %ebp
f0100b91:	c3                   	ret    

f0100b92 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b92:	2b 05 90 6e 22 f0    	sub    0xf0226e90,%eax
f0100b98:	c1 f8 03             	sar    $0x3,%eax
f0100b9b:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100b9e:	89 c2                	mov    %eax,%edx
f0100ba0:	c1 ea 0c             	shr    $0xc,%edx
f0100ba3:	3b 15 88 6e 22 f0    	cmp    0xf0226e88,%edx
f0100ba9:	72 26                	jb     f0100bd1 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100bab:	55                   	push   %ebp
f0100bac:	89 e5                	mov    %esp,%ebp
f0100bae:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bb1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bb5:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0100bbc:	f0 
f0100bbd:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100bc4:	00 
f0100bc5:	c7 04 24 2b 74 10 f0 	movl   $0xf010742b,(%esp)
f0100bcc:	e8 6f f4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100bd1:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return KADDR(page2pa(pp));
}
f0100bd6:	c3                   	ret    

f0100bd7 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100bd7:	89 d1                	mov    %edx,%ecx
f0100bd9:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100bdc:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100bdf:	a8 01                	test   $0x1,%al
f0100be1:	74 5d                	je     f0100c40 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100be3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100be8:	89 c1                	mov    %eax,%ecx
f0100bea:	c1 e9 0c             	shr    $0xc,%ecx
f0100bed:	3b 0d 88 6e 22 f0    	cmp    0xf0226e88,%ecx
f0100bf3:	72 26                	jb     f0100c1b <check_va2pa+0x44>
{
f0100bf5:	55                   	push   %ebp
f0100bf6:	89 e5                	mov    %esp,%ebp
f0100bf8:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bfb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bff:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0100c06:	f0 
f0100c07:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f0100c0e:	00 
f0100c0f:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0100c16:	e8 25 f4 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100c1b:	c1 ea 0c             	shr    $0xc,%edx
f0100c1e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100c24:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100c2b:	89 c2                	mov    %eax,%edx
f0100c2d:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100c30:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c35:	85 d2                	test   %edx,%edx
f0100c37:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100c3c:	0f 44 c2             	cmove  %edx,%eax
f0100c3f:	c3                   	ret    
		return ~0;
f0100c40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100c45:	c3                   	ret    

f0100c46 <check_page_free_list>:
{
f0100c46:	55                   	push   %ebp
f0100c47:	89 e5                	mov    %esp,%ebp
f0100c49:	57                   	push   %edi
f0100c4a:	56                   	push   %esi
f0100c4b:	53                   	push   %ebx
f0100c4c:	83 ec 4c             	sub    $0x4c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c4f:	84 c0                	test   %al,%al
f0100c51:	0f 85 6a 03 00 00    	jne    f0100fc1 <check_page_free_list+0x37b>
f0100c57:	e9 77 03 00 00       	jmp    f0100fd3 <check_page_free_list+0x38d>
		panic("'page_free_list' is a null pointer!");
f0100c5c:	c7 44 24 08 10 77 10 	movl   $0xf0107710,0x8(%esp)
f0100c63:	f0 
f0100c64:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f0100c6b:	00 
f0100c6c:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0100c73:	e8 c8 f3 ff ff       	call   f0100040 <_panic>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c78:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c7b:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c7e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c81:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100c84:	89 c2                	mov    %eax,%edx
f0100c86:	2b 15 90 6e 22 f0    	sub    0xf0226e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c8c:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c92:	0f 95 c2             	setne  %dl
f0100c95:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100c98:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c9c:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c9e:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca2:	8b 00                	mov    (%eax),%eax
f0100ca4:	85 c0                	test   %eax,%eax
f0100ca6:	75 dc                	jne    f0100c84 <check_page_free_list+0x3e>
		*tp[1] = 0;
f0100ca8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100cb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cb4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cb7:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100cb9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100cbc:	a3 40 62 22 f0       	mov    %eax,0xf0226240
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cc1:	89 c3                	mov    %eax,%ebx
f0100cc3:	85 c0                	test   %eax,%eax
f0100cc5:	74 6c                	je     f0100d33 <check_page_free_list+0xed>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cc7:	be 01 00 00 00       	mov    $0x1,%esi
f0100ccc:	89 d8                	mov    %ebx,%eax
f0100cce:	2b 05 90 6e 22 f0    	sub    0xf0226e90,%eax
f0100cd4:	c1 f8 03             	sar    $0x3,%eax
f0100cd7:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100cda:	89 c2                	mov    %eax,%edx
f0100cdc:	c1 ea 16             	shr    $0x16,%edx
f0100cdf:	39 f2                	cmp    %esi,%edx
f0100ce1:	73 4a                	jae    f0100d2d <check_page_free_list+0xe7>
	if (PGNUM(pa) >= npages)
f0100ce3:	89 c2                	mov    %eax,%edx
f0100ce5:	c1 ea 0c             	shr    $0xc,%edx
f0100ce8:	3b 15 88 6e 22 f0    	cmp    0xf0226e88,%edx
f0100cee:	72 20                	jb     f0100d10 <check_page_free_list+0xca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cf0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cf4:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0100cfb:	f0 
f0100cfc:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100d03:	00 
f0100d04:	c7 04 24 2b 74 10 f0 	movl   $0xf010742b,(%esp)
f0100d0b:	e8 30 f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100d10:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100d17:	00 
f0100d18:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100d1f:	00 
	return (void *)(pa + KERNBASE);
f0100d20:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d25:	89 04 24             	mov    %eax,(%esp)
f0100d28:	e8 8c 53 00 00       	call   f01060b9 <memset>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d2d:	8b 1b                	mov    (%ebx),%ebx
f0100d2f:	85 db                	test   %ebx,%ebx
f0100d31:	75 99                	jne    f0100ccc <check_page_free_list+0x86>
	first_free_page = (char *) boot_alloc(0);
f0100d33:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d38:	e8 e3 fd ff ff       	call   f0100b20 <boot_alloc>
f0100d3d:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d40:	8b 15 40 62 22 f0    	mov    0xf0226240,%edx
f0100d46:	85 d2                	test   %edx,%edx
f0100d48:	0f 84 27 02 00 00    	je     f0100f75 <check_page_free_list+0x32f>
		assert(pp >= pages);
f0100d4e:	8b 3d 90 6e 22 f0    	mov    0xf0226e90,%edi
f0100d54:	39 fa                	cmp    %edi,%edx
f0100d56:	72 3f                	jb     f0100d97 <check_page_free_list+0x151>
		assert(pp < pages + npages);
f0100d58:	a1 88 6e 22 f0       	mov    0xf0226e88,%eax
f0100d5d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100d60:	8d 04 c7             	lea    (%edi,%eax,8),%eax
f0100d63:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100d66:	39 c2                	cmp    %eax,%edx
f0100d68:	73 56                	jae    f0100dc0 <check_page_free_list+0x17a>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d6a:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0100d6d:	89 d0                	mov    %edx,%eax
f0100d6f:	29 f8                	sub    %edi,%eax
f0100d71:	a8 07                	test   $0x7,%al
f0100d73:	75 78                	jne    f0100ded <check_page_free_list+0x1a7>
	return (pp - pages) << PGSHIFT;
f0100d75:	c1 f8 03             	sar    $0x3,%eax
f0100d78:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100d7b:	85 c0                	test   %eax,%eax
f0100d7d:	0f 84 98 00 00 00    	je     f0100e1b <check_page_free_list+0x1d5>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d83:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d88:	0f 85 dc 00 00 00    	jne    f0100e6a <check_page_free_list+0x224>
f0100d8e:	e9 b3 00 00 00       	jmp    f0100e46 <check_page_free_list+0x200>
		assert(pp >= pages);
f0100d93:	39 d7                	cmp    %edx,%edi
f0100d95:	76 24                	jbe    f0100dbb <check_page_free_list+0x175>
f0100d97:	c7 44 24 0c 39 74 10 	movl   $0xf0107439,0xc(%esp)
f0100d9e:	f0 
f0100d9f:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0100da6:	f0 
f0100da7:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0100dae:	00 
f0100daf:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0100db6:	e8 85 f2 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100dbb:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100dbe:	72 24                	jb     f0100de4 <check_page_free_list+0x19e>
f0100dc0:	c7 44 24 0c 5a 74 10 	movl   $0xf010745a,0xc(%esp)
f0100dc7:	f0 
f0100dc8:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0100dcf:	f0 
f0100dd0:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f0100dd7:	00 
f0100dd8:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0100ddf:	e8 5c f2 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100de4:	89 d0                	mov    %edx,%eax
f0100de6:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100de9:	a8 07                	test   $0x7,%al
f0100deb:	74 24                	je     f0100e11 <check_page_free_list+0x1cb>
f0100ded:	c7 44 24 0c 34 77 10 	movl   $0xf0107734,0xc(%esp)
f0100df4:	f0 
f0100df5:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0100dfc:	f0 
f0100dfd:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f0100e04:	00 
f0100e05:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0100e0c:	e8 2f f2 ff ff       	call   f0100040 <_panic>
f0100e11:	c1 f8 03             	sar    $0x3,%eax
f0100e14:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100e17:	85 c0                	test   %eax,%eax
f0100e19:	75 24                	jne    f0100e3f <check_page_free_list+0x1f9>
f0100e1b:	c7 44 24 0c 6e 74 10 	movl   $0xf010746e,0xc(%esp)
f0100e22:	f0 
f0100e23:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0100e2a:	f0 
f0100e2b:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0100e32:	00 
f0100e33:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0100e3a:	e8 01 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e3f:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e44:	75 31                	jne    f0100e77 <check_page_free_list+0x231>
f0100e46:	c7 44 24 0c 7f 74 10 	movl   $0xf010747f,0xc(%esp)
f0100e4d:	f0 
f0100e4e:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0100e55:	f0 
f0100e56:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
f0100e5d:	00 
f0100e5e:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0100e65:	e8 d6 f1 ff ff       	call   f0100040 <_panic>
	int nfree_basemem = 0, nfree_extmem = 0;
f0100e6a:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e6f:	be 00 00 00 00       	mov    $0x0,%esi
f0100e74:	89 5d cc             	mov    %ebx,-0x34(%ebp)
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e77:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e7c:	75 24                	jne    f0100ea2 <check_page_free_list+0x25c>
f0100e7e:	c7 44 24 0c 68 77 10 	movl   $0xf0107768,0xc(%esp)
f0100e85:	f0 
f0100e86:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0100e8d:	f0 
f0100e8e:	c7 44 24 04 da 02 00 	movl   $0x2da,0x4(%esp)
f0100e95:	00 
f0100e96:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0100e9d:	e8 9e f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ea2:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100ea7:	75 24                	jne    f0100ecd <check_page_free_list+0x287>
f0100ea9:	c7 44 24 0c 98 74 10 	movl   $0xf0107498,0xc(%esp)
f0100eb0:	f0 
f0100eb1:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0100eb8:	f0 
f0100eb9:	c7 44 24 04 db 02 00 	movl   $0x2db,0x4(%esp)
f0100ec0:	00 
f0100ec1:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0100ec8:	e8 73 f1 ff ff       	call   f0100040 <_panic>
f0100ecd:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ecf:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ed4:	0f 86 0b 01 00 00    	jbe    f0100fe5 <check_page_free_list+0x39f>
	if (PGNUM(pa) >= npages)
f0100eda:	89 c3                	mov    %eax,%ebx
f0100edc:	c1 eb 0c             	shr    $0xc,%ebx
f0100edf:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0100ee2:	77 20                	ja     f0100f04 <check_page_free_list+0x2be>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ee4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ee8:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0100eef:	f0 
f0100ef0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100ef7:	00 
f0100ef8:	c7 04 24 2b 74 10 f0 	movl   $0xf010742b,(%esp)
f0100eff:	e8 3c f1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100f04:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0100f0a:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100f0d:	0f 86 e2 00 00 00    	jbe    f0100ff5 <check_page_free_list+0x3af>
f0100f13:	c7 44 24 0c 8c 77 10 	movl   $0xf010778c,0xc(%esp)
f0100f1a:	f0 
f0100f1b:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0100f22:	f0 
f0100f23:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f0100f2a:	00 
f0100f2b:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0100f32:	e8 09 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100f37:	c7 44 24 0c b2 74 10 	movl   $0xf01074b2,0xc(%esp)
f0100f3e:	f0 
f0100f3f:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0100f46:	f0 
f0100f47:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f0100f4e:	00 
f0100f4f:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0100f56:	e8 e5 f0 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100f5b:	83 c6 01             	add    $0x1,%esi
f0100f5e:	eb 04                	jmp    f0100f64 <check_page_free_list+0x31e>
			++nfree_extmem;
f0100f60:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f64:	8b 12                	mov    (%edx),%edx
f0100f66:	85 d2                	test   %edx,%edx
f0100f68:	0f 85 25 fe ff ff    	jne    f0100d93 <check_page_free_list+0x14d>
f0100f6e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100f71:	85 f6                	test   %esi,%esi
f0100f73:	7f 24                	jg     f0100f99 <check_page_free_list+0x353>
f0100f75:	c7 44 24 0c cf 74 10 	movl   $0xf01074cf,0xc(%esp)
f0100f7c:	f0 
f0100f7d:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0100f84:	f0 
f0100f85:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f0100f8c:	00 
f0100f8d:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0100f94:	e8 a7 f0 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100f99:	85 db                	test   %ebx,%ebx
f0100f9b:	7f 78                	jg     f0101015 <check_page_free_list+0x3cf>
f0100f9d:	c7 44 24 0c e1 74 10 	movl   $0xf01074e1,0xc(%esp)
f0100fa4:	f0 
f0100fa5:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0100fac:	f0 
f0100fad:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f0100fb4:	00 
f0100fb5:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0100fbc:	e8 7f f0 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100fc1:	a1 40 62 22 f0       	mov    0xf0226240,%eax
f0100fc6:	85 c0                	test   %eax,%eax
f0100fc8:	0f 85 aa fc ff ff    	jne    f0100c78 <check_page_free_list+0x32>
f0100fce:	e9 89 fc ff ff       	jmp    f0100c5c <check_page_free_list+0x16>
f0100fd3:	83 3d 40 62 22 f0 00 	cmpl   $0x0,0xf0226240
f0100fda:	75 29                	jne    f0101005 <check_page_free_list+0x3bf>
f0100fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100fe0:	e9 77 fc ff ff       	jmp    f0100c5c <check_page_free_list+0x16>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100fe5:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100fea:	0f 85 6b ff ff ff    	jne    f0100f5b <check_page_free_list+0x315>
f0100ff0:	e9 42 ff ff ff       	jmp    f0100f37 <check_page_free_list+0x2f1>
f0100ff5:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ffa:	0f 85 60 ff ff ff    	jne    f0100f60 <check_page_free_list+0x31a>
f0101000:	e9 32 ff ff ff       	jmp    f0100f37 <check_page_free_list+0x2f1>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101005:	8b 1d 40 62 22 f0    	mov    0xf0226240,%ebx
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010100b:	be 00 04 00 00       	mov    $0x400,%esi
f0101010:	e9 b7 fc ff ff       	jmp    f0100ccc <check_page_free_list+0x86>
}
f0101015:	83 c4 4c             	add    $0x4c,%esp
f0101018:	5b                   	pop    %ebx
f0101019:	5e                   	pop    %esi
f010101a:	5f                   	pop    %edi
f010101b:	5d                   	pop    %ebp
f010101c:	c3                   	ret    

f010101d <page_init>:
{
f010101d:	55                   	push   %ebp
f010101e:	89 e5                	mov    %esp,%ebp
f0101020:	57                   	push   %edi
f0101021:	56                   	push   %esi
f0101022:	53                   	push   %ebx
f0101023:	83 ec 4c             	sub    $0x4c,%esp
	physaddr_t nextfree_paddr = PADDR((pde_t *)boot_alloc(0));
f0101026:	b8 00 00 00 00       	mov    $0x0,%eax
f010102b:	e8 f0 fa ff ff       	call   f0100b20 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0101030:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101035:	77 20                	ja     f0101057 <page_init+0x3a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101037:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010103b:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0101042:	f0 
f0101043:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
f010104a:	00 
f010104b:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101052:	e8 e9 ef ff ff       	call   f0100040 <_panic>
	physaddr_t used_interval[3][2] = {{0, PGSIZE}, {MPENTRY_PADDR, MPENTRY_PADDR + PGSIZE}, {IOPHYSMEM, nextfree_paddr}};
f0101057:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f010105e:	c7 45 d4 00 10 00 00 	movl   $0x1000,-0x2c(%ebp)
f0101065:	c7 45 d8 00 70 00 00 	movl   $0x7000,-0x28(%ebp)
f010106c:	c7 45 dc 00 80 00 00 	movl   $0x8000,-0x24(%ebp)
f0101073:	c7 45 e0 00 00 0a 00 	movl   $0xa0000,-0x20(%ebp)
	return (physaddr_t)kva - KERNBASE;
f010107a:	05 00 00 00 10       	add    $0x10000000,%eax
f010107f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i = 0; i < npages; ++i){
f0101082:	83 3d 88 6e 22 f0 00 	cmpl   $0x0,0xf0226e88
f0101089:	0f 84 99 00 00 00    	je     f0101128 <page_init+0x10b>
f010108f:	8b 3d 40 62 22 f0    	mov    0xf0226240,%edi
f0101095:	be 00 00 00 00       	mov    $0x0,%esi
f010109a:	b9 00 00 00 00       	mov    $0x0,%ecx
	int used_interval_pointer = 0;
f010109f:	b8 00 00 00 00       	mov    $0x0,%eax
f01010a4:	eb 58                	jmp    f01010fe <page_init+0xe1>
			used_interval_pointer++;
f01010a6:	83 c0 01             	add    $0x1,%eax
		while(used_interval_pointer < kUsed_interval_length && used_interval[used_interval_pointer][1] <= page2pa(pages + i))
f01010a9:	83 f8 03             	cmp    $0x3,%eax
f01010ac:	74 08                	je     f01010b6 <page_init+0x99>
f01010ae:	39 54 c5 d4          	cmp    %edx,-0x2c(%ebp,%eax,8)
f01010b2:	76 f2                	jbe    f01010a6 <page_init+0x89>
f01010b4:	eb 6a                	jmp    f0101120 <page_init+0x103>
			pages[i].pp_ref = 0;
f01010b6:	c1 e6 03             	shl    $0x3,%esi
f01010b9:	89 f2                	mov    %esi,%edx
f01010bb:	03 15 90 6e 22 f0    	add    0xf0226e90,%edx
f01010c1:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f01010c7:	89 3a                	mov    %edi,(%edx)
			page_free_list = pages + i;
f01010c9:	89 f7                	mov    %esi,%edi
f01010cb:	03 3d 90 6e 22 f0    	add    0xf0226e90,%edi
f01010d1:	eb 16                	jmp    f01010e9 <page_init+0xcc>
			pages[i].pp_ref = 1;
f01010d3:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01010d6:	66 c7 46 04 01 00    	movw   $0x1,0x4(%esi)
			pages[i].pp_link = NULL;
f01010dc:	8b 15 90 6e 22 f0    	mov    0xf0226e90,%edx
f01010e2:	c7 04 1a 00 00 00 00 	movl   $0x0,(%edx,%ebx,1)
	for(i = 0; i < npages; ++i){
f01010e9:	83 c1 01             	add    $0x1,%ecx
f01010ec:	89 ce                	mov    %ecx,%esi
f01010ee:	3b 0d 88 6e 22 f0    	cmp    0xf0226e88,%ecx
f01010f4:	72 08                	jb     f01010fe <page_init+0xe1>
f01010f6:	89 3d 40 62 22 f0    	mov    %edi,0xf0226240
f01010fc:	eb 2a                	jmp    f0101128 <page_init+0x10b>
		while(used_interval_pointer < kUsed_interval_length && used_interval[used_interval_pointer][1] <= page2pa(pages + i))
f01010fe:	83 f8 02             	cmp    $0x2,%eax
f0101101:	7f b3                	jg     f01010b6 <page_init+0x99>
f0101103:	8d 1c f5 00 00 00 00 	lea    0x0(,%esi,8),%ebx
f010110a:	89 da                	mov    %ebx,%edx
f010110c:	03 15 90 6e 22 f0    	add    0xf0226e90,%edx
f0101112:	89 55 c4             	mov    %edx,-0x3c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101115:	89 da                	mov    %ebx,%edx
f0101117:	c1 e2 09             	shl    $0x9,%edx
f010111a:	39 54 c5 d4          	cmp    %edx,-0x2c(%ebp,%eax,8)
f010111e:	76 86                	jbe    f01010a6 <page_init+0x89>
		if(used_interval_pointer >= kUsed_interval_length || page2pa(pages + i) < used_interval[used_interval_pointer][0]){
f0101120:	39 54 c5 d0          	cmp    %edx,-0x30(%ebp,%eax,8)
f0101124:	77 90                	ja     f01010b6 <page_init+0x99>
f0101126:	eb ab                	jmp    f01010d3 <page_init+0xb6>
}
f0101128:	83 c4 4c             	add    $0x4c,%esp
f010112b:	5b                   	pop    %ebx
f010112c:	5e                   	pop    %esi
f010112d:	5f                   	pop    %edi
f010112e:	5d                   	pop    %ebp
f010112f:	c3                   	ret    

f0101130 <page_alloc>:
{
f0101130:	55                   	push   %ebp
f0101131:	89 e5                	mov    %esp,%ebp
f0101133:	53                   	push   %ebx
f0101134:	83 ec 14             	sub    $0x14,%esp
	if(!page_free_list) return NULL;
f0101137:	8b 1d 40 62 22 f0    	mov    0xf0226240,%ebx
f010113d:	85 db                	test   %ebx,%ebx
f010113f:	74 6f                	je     f01011b0 <page_alloc+0x80>
	page_free_list = page_free_list->pp_link;
f0101141:	8b 03                	mov    (%ebx),%eax
f0101143:	a3 40 62 22 f0       	mov    %eax,0xf0226240
	new_page->pp_link = NULL;
f0101148:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return new_page;
f010114e:	89 d8                	mov    %ebx,%eax
	if(alloc_flags & ALLOC_ZERO)
f0101150:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101154:	74 5f                	je     f01011b5 <page_alloc+0x85>
f0101156:	2b 05 90 6e 22 f0    	sub    0xf0226e90,%eax
f010115c:	c1 f8 03             	sar    $0x3,%eax
f010115f:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101162:	89 c2                	mov    %eax,%edx
f0101164:	c1 ea 0c             	shr    $0xc,%edx
f0101167:	3b 15 88 6e 22 f0    	cmp    0xf0226e88,%edx
f010116d:	72 20                	jb     f010118f <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010116f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101173:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f010117a:	f0 
f010117b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101182:	00 
f0101183:	c7 04 24 2b 74 10 f0 	movl   $0xf010742b,(%esp)
f010118a:	e8 b1 ee ff ff       	call   f0100040 <_panic>
		memset(page2kva(new_page), 0, PGSIZE);
f010118f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101196:	00 
f0101197:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010119e:	00 
	return (void *)(pa + KERNBASE);
f010119f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01011a4:	89 04 24             	mov    %eax,(%esp)
f01011a7:	e8 0d 4f 00 00       	call   f01060b9 <memset>
	return new_page;
f01011ac:	89 d8                	mov    %ebx,%eax
f01011ae:	eb 05                	jmp    f01011b5 <page_alloc+0x85>
	if(!page_free_list) return NULL;
f01011b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01011b5:	83 c4 14             	add    $0x14,%esp
f01011b8:	5b                   	pop    %ebx
f01011b9:	5d                   	pop    %ebp
f01011ba:	c3                   	ret    

f01011bb <page_free>:
{
f01011bb:	55                   	push   %ebp
f01011bc:	89 e5                	mov    %esp,%ebp
f01011be:	8b 45 08             	mov    0x8(%ebp),%eax
	if(!pp || pp->pp_ref) return;
f01011c1:	85 c0                	test   %eax,%eax
f01011c3:	74 14                	je     f01011d9 <page_free+0x1e>
f01011c5:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01011ca:	75 0d                	jne    f01011d9 <page_free+0x1e>
	pp->pp_link = page_free_list;
f01011cc:	8b 15 40 62 22 f0    	mov    0xf0226240,%edx
f01011d2:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01011d4:	a3 40 62 22 f0       	mov    %eax,0xf0226240
}
f01011d9:	5d                   	pop    %ebp
f01011da:	c3                   	ret    

f01011db <page_decref>:
{
f01011db:	55                   	push   %ebp
f01011dc:	89 e5                	mov    %esp,%ebp
f01011de:	83 ec 04             	sub    $0x4,%esp
f01011e1:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01011e4:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f01011e8:	8d 51 ff             	lea    -0x1(%ecx),%edx
f01011eb:	66 89 50 04          	mov    %dx,0x4(%eax)
f01011ef:	66 85 d2             	test   %dx,%dx
f01011f2:	75 08                	jne    f01011fc <page_decref+0x21>
		page_free(pp);
f01011f4:	89 04 24             	mov    %eax,(%esp)
f01011f7:	e8 bf ff ff ff       	call   f01011bb <page_free>
}
f01011fc:	c9                   	leave  
f01011fd:	c3                   	ret    

f01011fe <pgdir_walk>:
{
f01011fe:	55                   	push   %ebp
f01011ff:	89 e5                	mov    %esp,%ebp
f0101201:	56                   	push   %esi
f0101202:	53                   	push   %ebx
f0101203:	83 ec 10             	sub    $0x10,%esp
f0101206:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t *pgdir_entry = pgdir + PDX(va);
f0101209:	89 f3                	mov    %esi,%ebx
f010120b:	c1 eb 16             	shr    $0x16,%ebx
f010120e:	c1 e3 02             	shl    $0x2,%ebx
f0101211:	03 5d 08             	add    0x8(%ebp),%ebx
	if(!(*pgdir_entry & PTE_P)){
f0101214:	f6 03 01             	testb  $0x1,(%ebx)
f0101217:	75 2d                	jne    f0101246 <pgdir_walk+0x48>
		if(create){
f0101219:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010121d:	74 6d                	je     f010128c <pgdir_walk+0x8e>
			struct PageInfo *new_pageinfo = page_alloc(ALLOC_ZERO);
f010121f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101226:	e8 05 ff ff ff       	call   f0101130 <page_alloc>
			if(!new_pageinfo) return NULL;
f010122b:	85 c0                	test   %eax,%eax
f010122d:	74 64                	je     f0101293 <pgdir_walk+0x95>
			new_pageinfo->pp_ref = 1;
f010122f:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101235:	2b 05 90 6e 22 f0    	sub    0xf0226e90,%eax
f010123b:	c1 f8 03             	sar    $0x3,%eax
f010123e:	c1 e0 0c             	shl    $0xc,%eax
			*pgdir_entry = page2pa(new_pageinfo) | PTE_P | PTE_U | PTE_W;
f0101241:	83 c8 07             	or     $0x7,%eax
f0101244:	89 03                	mov    %eax,(%ebx)
	pte_t *pg_address = KADDR(PTE_ADDR(*pgdir_entry));
f0101246:	8b 03                	mov    (%ebx),%eax
f0101248:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010124d:	89 c2                	mov    %eax,%edx
f010124f:	c1 ea 0c             	shr    $0xc,%edx
f0101252:	3b 15 88 6e 22 f0    	cmp    0xf0226e88,%edx
f0101258:	72 20                	jb     f010127a <pgdir_walk+0x7c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010125a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010125e:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0101265:	f0 
f0101266:	c7 44 24 04 ad 01 00 	movl   $0x1ad,0x4(%esp)
f010126d:	00 
f010126e:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101275:	e8 c6 ed ff ff       	call   f0100040 <_panic>
	return pg_address + PTX(va);
f010127a:	c1 ee 0a             	shr    $0xa,%esi
f010127d:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101283:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f010128a:	eb 0c                	jmp    f0101298 <pgdir_walk+0x9a>
			return NULL;
f010128c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101291:	eb 05                	jmp    f0101298 <pgdir_walk+0x9a>
			if(!new_pageinfo) return NULL;
f0101293:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101298:	83 c4 10             	add    $0x10,%esp
f010129b:	5b                   	pop    %ebx
f010129c:	5e                   	pop    %esi
f010129d:	5d                   	pop    %ebp
f010129e:	c3                   	ret    

f010129f <boot_map_region>:
{
f010129f:	55                   	push   %ebp
f01012a0:	89 e5                	mov    %esp,%ebp
f01012a2:	57                   	push   %edi
f01012a3:	56                   	push   %esi
f01012a4:	53                   	push   %ebx
f01012a5:	83 ec 2c             	sub    $0x2c,%esp
f01012a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01012ab:	8b 7d 08             	mov    0x8(%ebp),%edi
	unsigned length = (size + PGSIZE - 1) / PGSIZE;
f01012ae:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f01012b4:	c1 e9 0c             	shr    $0xc,%ecx
f01012b7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(i = 0; i < length; ++i){
f01012ba:	85 c9                	test   %ecx,%ecx
f01012bc:	74 46                	je     f0101304 <boot_map_region+0x65>
f01012be:	89 d6                	mov    %edx,%esi
f01012c0:	bb 00 00 00 00       	mov    $0x0,%ebx
		*pg_entry = cur_pa | perm | PTE_P;
f01012c5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012c8:	83 c8 01             	or     $0x1,%eax
f01012cb:	89 45 dc             	mov    %eax,-0x24(%ebp)
		pte_t *pg_entry = pgdir_walk(pgdir, (void *)cur_va, true);
f01012ce:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01012d5:	00 
f01012d6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01012da:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01012dd:	89 04 24             	mov    %eax,(%esp)
f01012e0:	e8 19 ff ff ff       	call   f01011fe <pgdir_walk>
		if(!pg_entry) continue;
f01012e5:	85 c0                	test   %eax,%eax
f01012e7:	74 13                	je     f01012fc <boot_map_region+0x5d>
		*pg_entry = cur_pa | perm | PTE_P;
f01012e9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01012ec:	09 fa                	or     %edi,%edx
f01012ee:	89 10                	mov    %edx,(%eax)
		cur_va += PGSIZE;
f01012f0:	81 c6 00 10 00 00    	add    $0x1000,%esi
		cur_pa += PGSIZE;
f01012f6:	81 c7 00 10 00 00    	add    $0x1000,%edi
	for(i = 0; i < length; ++i){
f01012fc:	83 c3 01             	add    $0x1,%ebx
f01012ff:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101302:	75 ca                	jne    f01012ce <boot_map_region+0x2f>
}
f0101304:	83 c4 2c             	add    $0x2c,%esp
f0101307:	5b                   	pop    %ebx
f0101308:	5e                   	pop    %esi
f0101309:	5f                   	pop    %edi
f010130a:	5d                   	pop    %ebp
f010130b:	c3                   	ret    

f010130c <page_lookup>:
{
f010130c:	55                   	push   %ebp
f010130d:	89 e5                	mov    %esp,%ebp
f010130f:	53                   	push   %ebx
f0101310:	83 ec 14             	sub    $0x14,%esp
f0101313:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pg_entry = pgdir_walk(pgdir, va, 0);
f0101316:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010131d:	00 
f010131e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101321:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101325:	8b 45 08             	mov    0x8(%ebp),%eax
f0101328:	89 04 24             	mov    %eax,(%esp)
f010132b:	e8 ce fe ff ff       	call   f01011fe <pgdir_walk>
f0101330:	89 c2                	mov    %eax,%edx
	if(!pg_entry || !(*pg_entry & PTE_P)) return NULL;
f0101332:	85 c0                	test   %eax,%eax
f0101334:	74 3e                	je     f0101374 <page_lookup+0x68>
f0101336:	8b 00                	mov    (%eax),%eax
f0101338:	a8 01                	test   $0x1,%al
f010133a:	74 3f                	je     f010137b <page_lookup+0x6f>
	if (PGNUM(pa) >= npages)
f010133c:	c1 e8 0c             	shr    $0xc,%eax
f010133f:	3b 05 88 6e 22 f0    	cmp    0xf0226e88,%eax
f0101345:	72 1c                	jb     f0101363 <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0101347:	c7 44 24 08 d4 77 10 	movl   $0xf01077d4,0x8(%esp)
f010134e:	f0 
f010134f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101356:	00 
f0101357:	c7 04 24 2b 74 10 f0 	movl   $0xf010742b,(%esp)
f010135e:	e8 dd ec ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101363:	8b 0d 90 6e 22 f0    	mov    0xf0226e90,%ecx
f0101369:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
	if(pte_store)
f010136c:	85 db                	test   %ebx,%ebx
f010136e:	74 10                	je     f0101380 <page_lookup+0x74>
		*pte_store = pg_entry;
f0101370:	89 13                	mov    %edx,(%ebx)
f0101372:	eb 0c                	jmp    f0101380 <page_lookup+0x74>
	if(!pg_entry || !(*pg_entry & PTE_P)) return NULL;
f0101374:	b8 00 00 00 00       	mov    $0x0,%eax
f0101379:	eb 05                	jmp    f0101380 <page_lookup+0x74>
f010137b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101380:	83 c4 14             	add    $0x14,%esp
f0101383:	5b                   	pop    %ebx
f0101384:	5d                   	pop    %ebp
f0101385:	c3                   	ret    

f0101386 <tlb_invalidate>:
{
f0101386:	55                   	push   %ebp
f0101387:	89 e5                	mov    %esp,%ebp
f0101389:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f010138c:	e8 c2 53 00 00       	call   f0106753 <cpunum>
f0101391:	6b c0 74             	imul   $0x74,%eax,%eax
f0101394:	83 b8 28 70 22 f0 00 	cmpl   $0x0,-0xfdd8fd8(%eax)
f010139b:	74 16                	je     f01013b3 <tlb_invalidate+0x2d>
f010139d:	e8 b1 53 00 00       	call   f0106753 <cpunum>
f01013a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01013a5:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f01013ab:	8b 55 08             	mov    0x8(%ebp),%edx
f01013ae:	39 50 60             	cmp    %edx,0x60(%eax)
f01013b1:	75 06                	jne    f01013b9 <tlb_invalidate+0x33>
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01013b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013b6:	0f 01 38             	invlpg (%eax)
}
f01013b9:	c9                   	leave  
f01013ba:	c3                   	ret    

f01013bb <page_remove>:
{
f01013bb:	55                   	push   %ebp
f01013bc:	89 e5                	mov    %esp,%ebp
f01013be:	56                   	push   %esi
f01013bf:	53                   	push   %ebx
f01013c0:	83 ec 20             	sub    $0x20,%esp
f01013c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01013c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pg_entry = NULL;
f01013c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo* pg_entry_info = page_lookup(pgdir, va, &pg_entry);
f01013d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01013d3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01013d7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013db:	89 1c 24             	mov    %ebx,(%esp)
f01013de:	e8 29 ff ff ff       	call   f010130c <page_lookup>
	if(!pg_entry_info) return;
f01013e3:	85 c0                	test   %eax,%eax
f01013e5:	74 1d                	je     f0101404 <page_remove+0x49>
	page_decref(pg_entry_info);
f01013e7:	89 04 24             	mov    %eax,(%esp)
f01013ea:	e8 ec fd ff ff       	call   f01011db <page_decref>
	*pg_entry = 0;
f01013ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01013f2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f01013f8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013fc:	89 1c 24             	mov    %ebx,(%esp)
f01013ff:	e8 82 ff ff ff       	call   f0101386 <tlb_invalidate>
}
f0101404:	83 c4 20             	add    $0x20,%esp
f0101407:	5b                   	pop    %ebx
f0101408:	5e                   	pop    %esi
f0101409:	5d                   	pop    %ebp
f010140a:	c3                   	ret    

f010140b <page_insert>:
{
f010140b:	55                   	push   %ebp
f010140c:	89 e5                	mov    %esp,%ebp
f010140e:	57                   	push   %edi
f010140f:	56                   	push   %esi
f0101410:	53                   	push   %ebx
f0101411:	83 ec 1c             	sub    $0x1c,%esp
f0101414:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101417:	8b 7d 0c             	mov    0xc(%ebp),%edi
	pte_t* pg_entry = pgdir_walk(pgdir, va, 1);
f010141a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101421:	00 
f0101422:	8b 45 10             	mov    0x10(%ebp),%eax
f0101425:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101429:	89 1c 24             	mov    %ebx,(%esp)
f010142c:	e8 cd fd ff ff       	call   f01011fe <pgdir_walk>
f0101431:	89 c6                	mov    %eax,%esi
	if(!pg_entry) return -E_NO_MEM;
f0101433:	85 c0                	test   %eax,%eax
f0101435:	74 48                	je     f010147f <page_insert+0x74>
	return (pp - pages) << PGSHIFT;
f0101437:	89 f8                	mov    %edi,%eax
f0101439:	2b 05 90 6e 22 f0    	sub    0xf0226e90,%eax
f010143f:	c1 f8 03             	sar    $0x3,%eax
f0101442:	c1 e0 0c             	shl    $0xc,%eax
f0101445:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pp->pp_ref += 1;
f0101448:	66 83 47 04 01       	addw   $0x1,0x4(%edi)
	if(*pg_entry & PTE_P)
f010144d:	f6 06 01             	testb  $0x1,(%esi)
f0101450:	74 0f                	je     f0101461 <page_insert+0x56>
		page_remove(pgdir, va);
f0101452:	8b 45 10             	mov    0x10(%ebp),%eax
f0101455:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101459:	89 1c 24             	mov    %ebx,(%esp)
f010145c:	e8 5a ff ff ff       	call   f01013bb <page_remove>
	*pg_entry = pg_paddr | perm | PTE_P;
f0101461:	8b 45 14             	mov    0x14(%ebp),%eax
f0101464:	83 c8 01             	or     $0x1,%eax
f0101467:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010146a:	89 06                	mov    %eax,(%esi)
	pgdir[PDX(va)] |= perm;
f010146c:	8b 45 10             	mov    0x10(%ebp),%eax
f010146f:	c1 e8 16             	shr    $0x16,%eax
f0101472:	8b 55 14             	mov    0x14(%ebp),%edx
f0101475:	09 14 83             	or     %edx,(%ebx,%eax,4)
	return 0;
f0101478:	b8 00 00 00 00       	mov    $0x0,%eax
f010147d:	eb 05                	jmp    f0101484 <page_insert+0x79>
	if(!pg_entry) return -E_NO_MEM;
f010147f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f0101484:	83 c4 1c             	add    $0x1c,%esp
f0101487:	5b                   	pop    %ebx
f0101488:	5e                   	pop    %esi
f0101489:	5f                   	pop    %edi
f010148a:	5d                   	pop    %ebp
f010148b:	c3                   	ret    

f010148c <mmio_map_region>:
{
f010148c:	55                   	push   %ebp
f010148d:	89 e5                	mov    %esp,%ebp
f010148f:	53                   	push   %ebx
f0101490:	83 ec 14             	sub    $0x14,%esp
	size_t align_size = ROUNDUP(size, PGSIZE);
f0101493:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101496:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f010149c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(base + align_size > MMIOLIM)
f01014a2:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f01014a8:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01014ab:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01014b0:	76 1c                	jbe    f01014ce <mmio_map_region+0x42>
		panic("mmio_map_region: overflow MMIOLIM");
f01014b2:	c7 44 24 08 f4 77 10 	movl   $0xf01077f4,0x8(%esp)
f01014b9:	f0 
f01014ba:	c7 44 24 04 62 02 00 	movl   $0x262,0x4(%esp)
f01014c1:	00 
f01014c2:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01014c9:	e8 72 eb ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, align_size, pa, PTE_W|PTE_PCD|PTE_PWT);
f01014ce:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f01014d5:	00 
f01014d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01014d9:	89 04 24             	mov    %eax,(%esp)
f01014dc:	89 d9                	mov    %ebx,%ecx
f01014de:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f01014e3:	e8 b7 fd ff ff       	call   f010129f <boot_map_region>
	uintptr_t result = base;
f01014e8:	a1 00 13 12 f0       	mov    0xf0121300,%eax
	base += align_size;
f01014ed:	01 c3                	add    %eax,%ebx
f01014ef:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
}
f01014f5:	83 c4 14             	add    $0x14,%esp
f01014f8:	5b                   	pop    %ebx
f01014f9:	5d                   	pop    %ebp
f01014fa:	c3                   	ret    

f01014fb <mem_init>:
{
f01014fb:	55                   	push   %ebp
f01014fc:	89 e5                	mov    %esp,%ebp
f01014fe:	57                   	push   %edi
f01014ff:	56                   	push   %esi
f0101500:	53                   	push   %ebx
f0101501:	83 ec 4c             	sub    $0x4c,%esp
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101504:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f010150b:	e8 50 29 00 00       	call   f0103e60 <mc146818_read>
f0101510:	89 c3                	mov    %eax,%ebx
f0101512:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101519:	e8 42 29 00 00       	call   f0103e60 <mc146818_read>
f010151e:	c1 e0 08             	shl    $0x8,%eax
f0101521:	09 c3                	or     %eax,%ebx
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101523:	89 d8                	mov    %ebx,%eax
f0101525:	c1 e0 0a             	shl    $0xa,%eax
f0101528:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010152e:	85 c0                	test   %eax,%eax
f0101530:	0f 48 c2             	cmovs  %edx,%eax
f0101533:	c1 f8 0c             	sar    $0xc,%eax
f0101536:	a3 44 62 22 f0       	mov    %eax,0xf0226244
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010153b:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101542:	e8 19 29 00 00       	call   f0103e60 <mc146818_read>
f0101547:	89 c3                	mov    %eax,%ebx
f0101549:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101550:	e8 0b 29 00 00       	call   f0103e60 <mc146818_read>
f0101555:	c1 e0 08             	shl    $0x8,%eax
f0101558:	09 c3                	or     %eax,%ebx
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010155a:	89 d8                	mov    %ebx,%eax
f010155c:	c1 e0 0a             	shl    $0xa,%eax
f010155f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101565:	85 c0                	test   %eax,%eax
f0101567:	0f 48 c2             	cmovs  %edx,%eax
f010156a:	c1 f8 0c             	sar    $0xc,%eax
	if (npages_extmem)
f010156d:	85 c0                	test   %eax,%eax
f010156f:	74 0e                	je     f010157f <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101571:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101577:	89 15 88 6e 22 f0    	mov    %edx,0xf0226e88
f010157d:	eb 0c                	jmp    f010158b <mem_init+0x90>
		npages = npages_basemem;
f010157f:	8b 15 44 62 22 f0    	mov    0xf0226244,%edx
f0101585:	89 15 88 6e 22 f0    	mov    %edx,0xf0226e88
		npages_extmem * PGSIZE / 1024);
f010158b:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010158e:	c1 e8 0a             	shr    $0xa,%eax
f0101591:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages_basemem * PGSIZE / 1024,
f0101595:	a1 44 62 22 f0       	mov    0xf0226244,%eax
f010159a:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010159d:	c1 e8 0a             	shr    $0xa,%eax
f01015a0:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01015a4:	a1 88 6e 22 f0       	mov    0xf0226e88,%eax
f01015a9:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015ac:	c1 e8 0a             	shr    $0xa,%eax
f01015af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015b3:	c7 04 24 18 78 10 f0 	movl   $0xf0107818,(%esp)
f01015ba:	e8 0a 2a 00 00       	call   f0103fc9 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01015bf:	b8 00 10 00 00       	mov    $0x1000,%eax
f01015c4:	e8 57 f5 ff ff       	call   f0100b20 <boot_alloc>
f01015c9:	a3 8c 6e 22 f0       	mov    %eax,0xf0226e8c
	memset(kern_pgdir, 0, PGSIZE);
f01015ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01015d5:	00 
f01015d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01015dd:	00 
f01015de:	89 04 24             	mov    %eax,(%esp)
f01015e1:	e8 d3 4a 00 00       	call   f01060b9 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01015e6:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01015eb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01015f0:	77 20                	ja     f0101612 <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01015f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015f6:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f01015fd:	f0 
f01015fe:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0101605:	00 
f0101606:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010160d:	e8 2e ea ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101612:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101618:	83 ca 05             	or     $0x5,%edx
f010161b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo) * npages);
f0101621:	a1 88 6e 22 f0       	mov    0xf0226e88,%eax
f0101626:	c1 e0 03             	shl    $0x3,%eax
f0101629:	e8 f2 f4 ff ff       	call   f0100b20 <boot_alloc>
f010162e:	a3 90 6e 22 f0       	mov    %eax,0xf0226e90
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f0101633:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101638:	e8 e3 f4 ff ff       	call   f0100b20 <boot_alloc>
f010163d:	a3 48 62 22 f0       	mov    %eax,0xf0226248
	page_init();
f0101642:	e8 d6 f9 ff ff       	call   f010101d <page_init>
	check_page_free_list(1);
f0101647:	b8 01 00 00 00       	mov    $0x1,%eax
f010164c:	e8 f5 f5 ff ff       	call   f0100c46 <check_page_free_list>
	if (!pages)
f0101651:	83 3d 90 6e 22 f0 00 	cmpl   $0x0,0xf0226e90
f0101658:	75 1c                	jne    f0101676 <mem_init+0x17b>
		panic("'pages' is a null pointer!");
f010165a:	c7 44 24 08 f2 74 10 	movl   $0xf01074f2,0x8(%esp)
f0101661:	f0 
f0101662:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f0101669:	00 
f010166a:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101671:	e8 ca e9 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101676:	a1 40 62 22 f0       	mov    0xf0226240,%eax
f010167b:	85 c0                	test   %eax,%eax
f010167d:	74 10                	je     f010168f <mem_init+0x194>
f010167f:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101684:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101687:	8b 00                	mov    (%eax),%eax
f0101689:	85 c0                	test   %eax,%eax
f010168b:	75 f7                	jne    f0101684 <mem_init+0x189>
f010168d:	eb 05                	jmp    f0101694 <mem_init+0x199>
f010168f:	bb 00 00 00 00       	mov    $0x0,%ebx
	assert((pp0 = page_alloc(0)));
f0101694:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010169b:	e8 90 fa ff ff       	call   f0101130 <page_alloc>
f01016a0:	89 c7                	mov    %eax,%edi
f01016a2:	85 c0                	test   %eax,%eax
f01016a4:	75 24                	jne    f01016ca <mem_init+0x1cf>
f01016a6:	c7 44 24 0c 0d 75 10 	movl   $0xf010750d,0xc(%esp)
f01016ad:	f0 
f01016ae:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01016b5:	f0 
f01016b6:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f01016bd:	00 
f01016be:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01016c5:	e8 76 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016d1:	e8 5a fa ff ff       	call   f0101130 <page_alloc>
f01016d6:	89 c6                	mov    %eax,%esi
f01016d8:	85 c0                	test   %eax,%eax
f01016da:	75 24                	jne    f0101700 <mem_init+0x205>
f01016dc:	c7 44 24 0c 23 75 10 	movl   $0xf0107523,0xc(%esp)
f01016e3:	f0 
f01016e4:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01016eb:	f0 
f01016ec:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f01016f3:	00 
f01016f4:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01016fb:	e8 40 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101700:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101707:	e8 24 fa ff ff       	call   f0101130 <page_alloc>
f010170c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010170f:	85 c0                	test   %eax,%eax
f0101711:	75 24                	jne    f0101737 <mem_init+0x23c>
f0101713:	c7 44 24 0c 39 75 10 	movl   $0xf0107539,0xc(%esp)
f010171a:	f0 
f010171b:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101722:	f0 
f0101723:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f010172a:	00 
f010172b:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101732:	e8 09 e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101737:	39 f7                	cmp    %esi,%edi
f0101739:	75 24                	jne    f010175f <mem_init+0x264>
f010173b:	c7 44 24 0c 4f 75 10 	movl   $0xf010754f,0xc(%esp)
f0101742:	f0 
f0101743:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010174a:	f0 
f010174b:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f0101752:	00 
f0101753:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010175a:	e8 e1 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010175f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101762:	39 c6                	cmp    %eax,%esi
f0101764:	74 04                	je     f010176a <mem_init+0x26f>
f0101766:	39 c7                	cmp    %eax,%edi
f0101768:	75 24                	jne    f010178e <mem_init+0x293>
f010176a:	c7 44 24 0c 54 78 10 	movl   $0xf0107854,0xc(%esp)
f0101771:	f0 
f0101772:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101779:	f0 
f010177a:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0101781:	00 
f0101782:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101789:	e8 b2 e8 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f010178e:	8b 15 90 6e 22 f0    	mov    0xf0226e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101794:	a1 88 6e 22 f0       	mov    0xf0226e88,%eax
f0101799:	c1 e0 0c             	shl    $0xc,%eax
f010179c:	89 f9                	mov    %edi,%ecx
f010179e:	29 d1                	sub    %edx,%ecx
f01017a0:	c1 f9 03             	sar    $0x3,%ecx
f01017a3:	c1 e1 0c             	shl    $0xc,%ecx
f01017a6:	39 c1                	cmp    %eax,%ecx
f01017a8:	72 24                	jb     f01017ce <mem_init+0x2d3>
f01017aa:	c7 44 24 0c 61 75 10 	movl   $0xf0107561,0xc(%esp)
f01017b1:	f0 
f01017b2:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01017b9:	f0 
f01017ba:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f01017c1:	00 
f01017c2:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01017c9:	e8 72 e8 ff ff       	call   f0100040 <_panic>
f01017ce:	89 f1                	mov    %esi,%ecx
f01017d0:	29 d1                	sub    %edx,%ecx
f01017d2:	c1 f9 03             	sar    $0x3,%ecx
f01017d5:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01017d8:	39 c8                	cmp    %ecx,%eax
f01017da:	77 24                	ja     f0101800 <mem_init+0x305>
f01017dc:	c7 44 24 0c 7e 75 10 	movl   $0xf010757e,0xc(%esp)
f01017e3:	f0 
f01017e4:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01017eb:	f0 
f01017ec:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f01017f3:	00 
f01017f4:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01017fb:	e8 40 e8 ff ff       	call   f0100040 <_panic>
f0101800:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101803:	29 d1                	sub    %edx,%ecx
f0101805:	89 ca                	mov    %ecx,%edx
f0101807:	c1 fa 03             	sar    $0x3,%edx
f010180a:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010180d:	39 d0                	cmp    %edx,%eax
f010180f:	77 24                	ja     f0101835 <mem_init+0x33a>
f0101811:	c7 44 24 0c 9b 75 10 	movl   $0xf010759b,0xc(%esp)
f0101818:	f0 
f0101819:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101820:	f0 
f0101821:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f0101828:	00 
f0101829:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101830:	e8 0b e8 ff ff       	call   f0100040 <_panic>
	fl = page_free_list;
f0101835:	a1 40 62 22 f0       	mov    0xf0226240,%eax
f010183a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010183d:	c7 05 40 62 22 f0 00 	movl   $0x0,0xf0226240
f0101844:	00 00 00 
	assert(!page_alloc(0));
f0101847:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010184e:	e8 dd f8 ff ff       	call   f0101130 <page_alloc>
f0101853:	85 c0                	test   %eax,%eax
f0101855:	74 24                	je     f010187b <mem_init+0x380>
f0101857:	c7 44 24 0c b8 75 10 	movl   $0xf01075b8,0xc(%esp)
f010185e:	f0 
f010185f:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101866:	f0 
f0101867:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f010186e:	00 
f010186f:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101876:	e8 c5 e7 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f010187b:	89 3c 24             	mov    %edi,(%esp)
f010187e:	e8 38 f9 ff ff       	call   f01011bb <page_free>
	page_free(pp1);
f0101883:	89 34 24             	mov    %esi,(%esp)
f0101886:	e8 30 f9 ff ff       	call   f01011bb <page_free>
	page_free(pp2);
f010188b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010188e:	89 04 24             	mov    %eax,(%esp)
f0101891:	e8 25 f9 ff ff       	call   f01011bb <page_free>
	assert((pp0 = page_alloc(0)));
f0101896:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010189d:	e8 8e f8 ff ff       	call   f0101130 <page_alloc>
f01018a2:	89 c6                	mov    %eax,%esi
f01018a4:	85 c0                	test   %eax,%eax
f01018a6:	75 24                	jne    f01018cc <mem_init+0x3d1>
f01018a8:	c7 44 24 0c 0d 75 10 	movl   $0xf010750d,0xc(%esp)
f01018af:	f0 
f01018b0:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01018b7:	f0 
f01018b8:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f01018bf:	00 
f01018c0:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01018c7:	e8 74 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01018cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018d3:	e8 58 f8 ff ff       	call   f0101130 <page_alloc>
f01018d8:	89 c7                	mov    %eax,%edi
f01018da:	85 c0                	test   %eax,%eax
f01018dc:	75 24                	jne    f0101902 <mem_init+0x407>
f01018de:	c7 44 24 0c 23 75 10 	movl   $0xf0107523,0xc(%esp)
f01018e5:	f0 
f01018e6:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01018ed:	f0 
f01018ee:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f01018f5:	00 
f01018f6:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01018fd:	e8 3e e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101902:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101909:	e8 22 f8 ff ff       	call   f0101130 <page_alloc>
f010190e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101911:	85 c0                	test   %eax,%eax
f0101913:	75 24                	jne    f0101939 <mem_init+0x43e>
f0101915:	c7 44 24 0c 39 75 10 	movl   $0xf0107539,0xc(%esp)
f010191c:	f0 
f010191d:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101924:	f0 
f0101925:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f010192c:	00 
f010192d:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101934:	e8 07 e7 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101939:	39 fe                	cmp    %edi,%esi
f010193b:	75 24                	jne    f0101961 <mem_init+0x466>
f010193d:	c7 44 24 0c 4f 75 10 	movl   $0xf010754f,0xc(%esp)
f0101944:	f0 
f0101945:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010194c:	f0 
f010194d:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f0101954:	00 
f0101955:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010195c:	e8 df e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101961:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101964:	39 c7                	cmp    %eax,%edi
f0101966:	74 04                	je     f010196c <mem_init+0x471>
f0101968:	39 c6                	cmp    %eax,%esi
f010196a:	75 24                	jne    f0101990 <mem_init+0x495>
f010196c:	c7 44 24 0c 54 78 10 	movl   $0xf0107854,0xc(%esp)
f0101973:	f0 
f0101974:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010197b:	f0 
f010197c:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0101983:	00 
f0101984:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010198b:	e8 b0 e6 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101990:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101997:	e8 94 f7 ff ff       	call   f0101130 <page_alloc>
f010199c:	85 c0                	test   %eax,%eax
f010199e:	74 24                	je     f01019c4 <mem_init+0x4c9>
f01019a0:	c7 44 24 0c b8 75 10 	movl   $0xf01075b8,0xc(%esp)
f01019a7:	f0 
f01019a8:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01019af:	f0 
f01019b0:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f01019b7:	00 
f01019b8:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01019bf:	e8 7c e6 ff ff       	call   f0100040 <_panic>
f01019c4:	89 f0                	mov    %esi,%eax
f01019c6:	2b 05 90 6e 22 f0    	sub    0xf0226e90,%eax
f01019cc:	c1 f8 03             	sar    $0x3,%eax
f01019cf:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01019d2:	89 c2                	mov    %eax,%edx
f01019d4:	c1 ea 0c             	shr    $0xc,%edx
f01019d7:	3b 15 88 6e 22 f0    	cmp    0xf0226e88,%edx
f01019dd:	72 20                	jb     f01019ff <mem_init+0x504>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019df:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019e3:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f01019ea:	f0 
f01019eb:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01019f2:	00 
f01019f3:	c7 04 24 2b 74 10 f0 	movl   $0xf010742b,(%esp)
f01019fa:	e8 41 e6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp0), 1, PGSIZE);
f01019ff:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a06:	00 
f0101a07:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101a0e:	00 
	return (void *)(pa + KERNBASE);
f0101a0f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a14:	89 04 24             	mov    %eax,(%esp)
f0101a17:	e8 9d 46 00 00       	call   f01060b9 <memset>
	page_free(pp0);
f0101a1c:	89 34 24             	mov    %esi,(%esp)
f0101a1f:	e8 97 f7 ff ff       	call   f01011bb <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a24:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a2b:	e8 00 f7 ff ff       	call   f0101130 <page_alloc>
f0101a30:	85 c0                	test   %eax,%eax
f0101a32:	75 24                	jne    f0101a58 <mem_init+0x55d>
f0101a34:	c7 44 24 0c c7 75 10 	movl   $0xf01075c7,0xc(%esp)
f0101a3b:	f0 
f0101a3c:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101a43:	f0 
f0101a44:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f0101a4b:	00 
f0101a4c:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101a53:	e8 e8 e5 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101a58:	39 c6                	cmp    %eax,%esi
f0101a5a:	74 24                	je     f0101a80 <mem_init+0x585>
f0101a5c:	c7 44 24 0c e5 75 10 	movl   $0xf01075e5,0xc(%esp)
f0101a63:	f0 
f0101a64:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101a6b:	f0 
f0101a6c:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f0101a73:	00 
f0101a74:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101a7b:	e8 c0 e5 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0101a80:	89 f2                	mov    %esi,%edx
f0101a82:	2b 15 90 6e 22 f0    	sub    0xf0226e90,%edx
f0101a88:	c1 fa 03             	sar    $0x3,%edx
f0101a8b:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101a8e:	89 d0                	mov    %edx,%eax
f0101a90:	c1 e8 0c             	shr    $0xc,%eax
f0101a93:	3b 05 88 6e 22 f0    	cmp    0xf0226e88,%eax
f0101a99:	72 20                	jb     f0101abb <mem_init+0x5c0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101a9f:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0101aa6:	f0 
f0101aa7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101aae:	00 
f0101aaf:	c7 04 24 2b 74 10 f0 	movl   $0xf010742b,(%esp)
f0101ab6:	e8 85 e5 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f0101abb:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101ac2:	75 11                	jne    f0101ad5 <mem_init+0x5da>
f0101ac4:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
f0101aca:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f0101ad0:	80 38 00             	cmpb   $0x0,(%eax)
f0101ad3:	74 24                	je     f0101af9 <mem_init+0x5fe>
f0101ad5:	c7 44 24 0c f5 75 10 	movl   $0xf01075f5,0xc(%esp)
f0101adc:	f0 
f0101add:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101ae4:	f0 
f0101ae5:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0101aec:	00 
f0101aed:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101af4:	e8 47 e5 ff ff       	call   f0100040 <_panic>
f0101af9:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101afc:	39 d0                	cmp    %edx,%eax
f0101afe:	75 d0                	jne    f0101ad0 <mem_init+0x5d5>
	page_free_list = fl;
f0101b00:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b03:	a3 40 62 22 f0       	mov    %eax,0xf0226240
	page_free(pp0);
f0101b08:	89 34 24             	mov    %esi,(%esp)
f0101b0b:	e8 ab f6 ff ff       	call   f01011bb <page_free>
	page_free(pp1);
f0101b10:	89 3c 24             	mov    %edi,(%esp)
f0101b13:	e8 a3 f6 ff ff       	call   f01011bb <page_free>
	page_free(pp2);
f0101b18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b1b:	89 04 24             	mov    %eax,(%esp)
f0101b1e:	e8 98 f6 ff ff       	call   f01011bb <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b23:	a1 40 62 22 f0       	mov    0xf0226240,%eax
f0101b28:	85 c0                	test   %eax,%eax
f0101b2a:	74 09                	je     f0101b35 <mem_init+0x63a>
		--nfree;
f0101b2c:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b2f:	8b 00                	mov    (%eax),%eax
f0101b31:	85 c0                	test   %eax,%eax
f0101b33:	75 f7                	jne    f0101b2c <mem_init+0x631>
	assert(nfree == 0);
f0101b35:	85 db                	test   %ebx,%ebx
f0101b37:	74 24                	je     f0101b5d <mem_init+0x662>
f0101b39:	c7 44 24 0c ff 75 10 	movl   $0xf01075ff,0xc(%esp)
f0101b40:	f0 
f0101b41:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101b48:	f0 
f0101b49:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f0101b50:	00 
f0101b51:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101b58:	e8 e3 e4 ff ff       	call   f0100040 <_panic>
	cprintf("check_page_alloc() succeeded!\n");
f0101b5d:	c7 04 24 74 78 10 f0 	movl   $0xf0107874,(%esp)
f0101b64:	e8 60 24 00 00       	call   f0103fc9 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b70:	e8 bb f5 ff ff       	call   f0101130 <page_alloc>
f0101b75:	89 c6                	mov    %eax,%esi
f0101b77:	85 c0                	test   %eax,%eax
f0101b79:	75 24                	jne    f0101b9f <mem_init+0x6a4>
f0101b7b:	c7 44 24 0c 0d 75 10 	movl   $0xf010750d,0xc(%esp)
f0101b82:	f0 
f0101b83:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101b8a:	f0 
f0101b8b:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0101b92:	00 
f0101b93:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101b9a:	e8 a1 e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ba6:	e8 85 f5 ff ff       	call   f0101130 <page_alloc>
f0101bab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101bae:	85 c0                	test   %eax,%eax
f0101bb0:	75 24                	jne    f0101bd6 <mem_init+0x6db>
f0101bb2:	c7 44 24 0c 23 75 10 	movl   $0xf0107523,0xc(%esp)
f0101bb9:	f0 
f0101bba:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101bc1:	f0 
f0101bc2:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f0101bc9:	00 
f0101bca:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101bd1:	e8 6a e4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101bd6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bdd:	e8 4e f5 ff ff       	call   f0101130 <page_alloc>
f0101be2:	89 c3                	mov    %eax,%ebx
f0101be4:	85 c0                	test   %eax,%eax
f0101be6:	75 24                	jne    f0101c0c <mem_init+0x711>
f0101be8:	c7 44 24 0c 39 75 10 	movl   $0xf0107539,0xc(%esp)
f0101bef:	f0 
f0101bf0:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101bf7:	f0 
f0101bf8:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f0101bff:	00 
f0101c00:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101c07:	e8 34 e4 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c0c:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101c0f:	75 24                	jne    f0101c35 <mem_init+0x73a>
f0101c11:	c7 44 24 0c 4f 75 10 	movl   $0xf010754f,0xc(%esp)
f0101c18:	f0 
f0101c19:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101c20:	f0 
f0101c21:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0101c28:	00 
f0101c29:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101c30:	e8 0b e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c35:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101c38:	74 04                	je     f0101c3e <mem_init+0x743>
f0101c3a:	39 c6                	cmp    %eax,%esi
f0101c3c:	75 24                	jne    f0101c62 <mem_init+0x767>
f0101c3e:	c7 44 24 0c 54 78 10 	movl   $0xf0107854,0xc(%esp)
f0101c45:	f0 
f0101c46:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101c4d:	f0 
f0101c4e:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0101c55:	00 
f0101c56:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101c5d:	e8 de e3 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c62:	a1 40 62 22 f0       	mov    0xf0226240,%eax
f0101c67:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101c6a:	c7 05 40 62 22 f0 00 	movl   $0x0,0xf0226240
f0101c71:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c7b:	e8 b0 f4 ff ff       	call   f0101130 <page_alloc>
f0101c80:	85 c0                	test   %eax,%eax
f0101c82:	74 24                	je     f0101ca8 <mem_init+0x7ad>
f0101c84:	c7 44 24 0c b8 75 10 	movl   $0xf01075b8,0xc(%esp)
f0101c8b:	f0 
f0101c8c:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101c93:	f0 
f0101c94:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0101c9b:	00 
f0101c9c:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101ca3:	e8 98 e3 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ca8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101cab:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101caf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101cb6:	00 
f0101cb7:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0101cbc:	89 04 24             	mov    %eax,(%esp)
f0101cbf:	e8 48 f6 ff ff       	call   f010130c <page_lookup>
f0101cc4:	85 c0                	test   %eax,%eax
f0101cc6:	74 24                	je     f0101cec <mem_init+0x7f1>
f0101cc8:	c7 44 24 0c 94 78 10 	movl   $0xf0107894,0xc(%esp)
f0101ccf:	f0 
f0101cd0:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101cd7:	f0 
f0101cd8:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0101cdf:	00 
f0101ce0:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101ce7:	e8 54 e3 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101cec:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101cf3:	00 
f0101cf4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101cfb:	00 
f0101cfc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d03:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0101d08:	89 04 24             	mov    %eax,(%esp)
f0101d0b:	e8 fb f6 ff ff       	call   f010140b <page_insert>
f0101d10:	85 c0                	test   %eax,%eax
f0101d12:	78 24                	js     f0101d38 <mem_init+0x83d>
f0101d14:	c7 44 24 0c cc 78 10 	movl   $0xf01078cc,0xc(%esp)
f0101d1b:	f0 
f0101d1c:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101d23:	f0 
f0101d24:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f0101d2b:	00 
f0101d2c:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101d33:	e8 08 e3 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d38:	89 34 24             	mov    %esi,(%esp)
f0101d3b:	e8 7b f4 ff ff       	call   f01011bb <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d40:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d47:	00 
f0101d48:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d4f:	00 
f0101d50:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d53:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d57:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0101d5c:	89 04 24             	mov    %eax,(%esp)
f0101d5f:	e8 a7 f6 ff ff       	call   f010140b <page_insert>
f0101d64:	85 c0                	test   %eax,%eax
f0101d66:	74 24                	je     f0101d8c <mem_init+0x891>
f0101d68:	c7 44 24 0c fc 78 10 	movl   $0xf01078fc,0xc(%esp)
f0101d6f:	f0 
f0101d70:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101d77:	f0 
f0101d78:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0101d7f:	00 
f0101d80:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101d87:	e8 b4 e2 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d8c:	8b 3d 8c 6e 22 f0    	mov    0xf0226e8c,%edi
	return (pp - pages) << PGSHIFT;
f0101d92:	a1 90 6e 22 f0       	mov    0xf0226e90,%eax
f0101d97:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d9a:	8b 17                	mov    (%edi),%edx
f0101d9c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101da2:	89 f1                	mov    %esi,%ecx
f0101da4:	29 c1                	sub    %eax,%ecx
f0101da6:	89 c8                	mov    %ecx,%eax
f0101da8:	c1 f8 03             	sar    $0x3,%eax
f0101dab:	c1 e0 0c             	shl    $0xc,%eax
f0101dae:	39 c2                	cmp    %eax,%edx
f0101db0:	74 24                	je     f0101dd6 <mem_init+0x8db>
f0101db2:	c7 44 24 0c 2c 79 10 	movl   $0xf010792c,0xc(%esp)
f0101db9:	f0 
f0101dba:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101dc1:	f0 
f0101dc2:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0101dc9:	00 
f0101dca:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101dd1:	e8 6a e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101dd6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ddb:	89 f8                	mov    %edi,%eax
f0101ddd:	e8 f5 ed ff ff       	call   f0100bd7 <check_va2pa>
f0101de2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101de5:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101de8:	c1 fa 03             	sar    $0x3,%edx
f0101deb:	c1 e2 0c             	shl    $0xc,%edx
f0101dee:	39 d0                	cmp    %edx,%eax
f0101df0:	74 24                	je     f0101e16 <mem_init+0x91b>
f0101df2:	c7 44 24 0c 54 79 10 	movl   $0xf0107954,0xc(%esp)
f0101df9:	f0 
f0101dfa:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101e01:	f0 
f0101e02:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f0101e09:	00 
f0101e0a:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101e11:	e8 2a e2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101e16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e19:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e1e:	74 24                	je     f0101e44 <mem_init+0x949>
f0101e20:	c7 44 24 0c 0a 76 10 	movl   $0xf010760a,0xc(%esp)
f0101e27:	f0 
f0101e28:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101e2f:	f0 
f0101e30:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f0101e37:	00 
f0101e38:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101e3f:	e8 fc e1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101e44:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e49:	74 24                	je     f0101e6f <mem_init+0x974>
f0101e4b:	c7 44 24 0c 1b 76 10 	movl   $0xf010761b,0xc(%esp)
f0101e52:	f0 
f0101e53:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101e5a:	f0 
f0101e5b:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0101e62:	00 
f0101e63:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101e6a:	e8 d1 e1 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e6f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e76:	00 
f0101e77:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e7e:	00 
f0101e7f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e83:	89 3c 24             	mov    %edi,(%esp)
f0101e86:	e8 80 f5 ff ff       	call   f010140b <page_insert>
f0101e8b:	85 c0                	test   %eax,%eax
f0101e8d:	74 24                	je     f0101eb3 <mem_init+0x9b8>
f0101e8f:	c7 44 24 0c 84 79 10 	movl   $0xf0107984,0xc(%esp)
f0101e96:	f0 
f0101e97:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101e9e:	f0 
f0101e9f:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0101ea6:	00 
f0101ea7:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101eae:	e8 8d e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101eb3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101eb8:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0101ebd:	e8 15 ed ff ff       	call   f0100bd7 <check_va2pa>
f0101ec2:	89 da                	mov    %ebx,%edx
f0101ec4:	2b 15 90 6e 22 f0    	sub    0xf0226e90,%edx
f0101eca:	c1 fa 03             	sar    $0x3,%edx
f0101ecd:	c1 e2 0c             	shl    $0xc,%edx
f0101ed0:	39 d0                	cmp    %edx,%eax
f0101ed2:	74 24                	je     f0101ef8 <mem_init+0x9fd>
f0101ed4:	c7 44 24 0c c0 79 10 	movl   $0xf01079c0,0xc(%esp)
f0101edb:	f0 
f0101edc:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101ee3:	f0 
f0101ee4:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101eeb:	00 
f0101eec:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101ef3:	e8 48 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ef8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101efd:	74 24                	je     f0101f23 <mem_init+0xa28>
f0101eff:	c7 44 24 0c 2c 76 10 	movl   $0xf010762c,0xc(%esp)
f0101f06:	f0 
f0101f07:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101f0e:	f0 
f0101f0f:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0101f16:	00 
f0101f17:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101f1e:	e8 1d e1 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f2a:	e8 01 f2 ff ff       	call   f0101130 <page_alloc>
f0101f2f:	85 c0                	test   %eax,%eax
f0101f31:	74 24                	je     f0101f57 <mem_init+0xa5c>
f0101f33:	c7 44 24 0c b8 75 10 	movl   $0xf01075b8,0xc(%esp)
f0101f3a:	f0 
f0101f3b:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101f42:	f0 
f0101f43:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0101f4a:	00 
f0101f4b:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101f52:	e8 e9 e0 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f57:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f5e:	00 
f0101f5f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f66:	00 
f0101f67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f6b:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0101f70:	89 04 24             	mov    %eax,(%esp)
f0101f73:	e8 93 f4 ff ff       	call   f010140b <page_insert>
f0101f78:	85 c0                	test   %eax,%eax
f0101f7a:	74 24                	je     f0101fa0 <mem_init+0xaa5>
f0101f7c:	c7 44 24 0c 84 79 10 	movl   $0xf0107984,0xc(%esp)
f0101f83:	f0 
f0101f84:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101f8b:	f0 
f0101f8c:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0101f93:	00 
f0101f94:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101f9b:	e8 a0 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fa0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fa5:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0101faa:	e8 28 ec ff ff       	call   f0100bd7 <check_va2pa>
f0101faf:	89 da                	mov    %ebx,%edx
f0101fb1:	2b 15 90 6e 22 f0    	sub    0xf0226e90,%edx
f0101fb7:	c1 fa 03             	sar    $0x3,%edx
f0101fba:	c1 e2 0c             	shl    $0xc,%edx
f0101fbd:	39 d0                	cmp    %edx,%eax
f0101fbf:	74 24                	je     f0101fe5 <mem_init+0xaea>
f0101fc1:	c7 44 24 0c c0 79 10 	movl   $0xf01079c0,0xc(%esp)
f0101fc8:	f0 
f0101fc9:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101fd0:	f0 
f0101fd1:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0101fd8:	00 
f0101fd9:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0101fe0:	e8 5b e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101fe5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fea:	74 24                	je     f0102010 <mem_init+0xb15>
f0101fec:	c7 44 24 0c 2c 76 10 	movl   $0xf010762c,0xc(%esp)
f0101ff3:	f0 
f0101ff4:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0101ffb:	f0 
f0101ffc:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0102003:	00 
f0102004:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010200b:	e8 30 e0 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102010:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102017:	e8 14 f1 ff ff       	call   f0101130 <page_alloc>
f010201c:	85 c0                	test   %eax,%eax
f010201e:	74 24                	je     f0102044 <mem_init+0xb49>
f0102020:	c7 44 24 0c b8 75 10 	movl   $0xf01075b8,0xc(%esp)
f0102027:	f0 
f0102028:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010202f:	f0 
f0102030:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0102037:	00 
f0102038:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010203f:	e8 fc df ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102044:	8b 15 8c 6e 22 f0    	mov    0xf0226e8c,%edx
f010204a:	8b 02                	mov    (%edx),%eax
f010204c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0102051:	89 c1                	mov    %eax,%ecx
f0102053:	c1 e9 0c             	shr    $0xc,%ecx
f0102056:	3b 0d 88 6e 22 f0    	cmp    0xf0226e88,%ecx
f010205c:	72 20                	jb     f010207e <mem_init+0xb83>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010205e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102062:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0102069:	f0 
f010206a:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0102071:	00 
f0102072:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102079:	e8 c2 df ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010207e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102083:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102086:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010208d:	00 
f010208e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102095:	00 
f0102096:	89 14 24             	mov    %edx,(%esp)
f0102099:	e8 60 f1 ff ff       	call   f01011fe <pgdir_walk>
f010209e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01020a1:	8d 51 04             	lea    0x4(%ecx),%edx
f01020a4:	39 d0                	cmp    %edx,%eax
f01020a6:	74 24                	je     f01020cc <mem_init+0xbd1>
f01020a8:	c7 44 24 0c f0 79 10 	movl   $0xf01079f0,0xc(%esp)
f01020af:	f0 
f01020b0:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01020b7:	f0 
f01020b8:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f01020bf:	00 
f01020c0:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01020c7:	e8 74 df ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01020cc:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01020d3:	00 
f01020d4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01020db:	00 
f01020dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01020e0:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f01020e5:	89 04 24             	mov    %eax,(%esp)
f01020e8:	e8 1e f3 ff ff       	call   f010140b <page_insert>
f01020ed:	85 c0                	test   %eax,%eax
f01020ef:	74 24                	je     f0102115 <mem_init+0xc1a>
f01020f1:	c7 44 24 0c 30 7a 10 	movl   $0xf0107a30,0xc(%esp)
f01020f8:	f0 
f01020f9:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102100:	f0 
f0102101:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0102108:	00 
f0102109:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102110:	e8 2b df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102115:	8b 3d 8c 6e 22 f0    	mov    0xf0226e8c,%edi
f010211b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102120:	89 f8                	mov    %edi,%eax
f0102122:	e8 b0 ea ff ff       	call   f0100bd7 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0102127:	89 da                	mov    %ebx,%edx
f0102129:	2b 15 90 6e 22 f0    	sub    0xf0226e90,%edx
f010212f:	c1 fa 03             	sar    $0x3,%edx
f0102132:	c1 e2 0c             	shl    $0xc,%edx
f0102135:	39 d0                	cmp    %edx,%eax
f0102137:	74 24                	je     f010215d <mem_init+0xc62>
f0102139:	c7 44 24 0c c0 79 10 	movl   $0xf01079c0,0xc(%esp)
f0102140:	f0 
f0102141:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102148:	f0 
f0102149:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0102150:	00 
f0102151:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102158:	e8 e3 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010215d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102162:	74 24                	je     f0102188 <mem_init+0xc8d>
f0102164:	c7 44 24 0c 2c 76 10 	movl   $0xf010762c,0xc(%esp)
f010216b:	f0 
f010216c:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102173:	f0 
f0102174:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f010217b:	00 
f010217c:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102183:	e8 b8 de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102188:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010218f:	00 
f0102190:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102197:	00 
f0102198:	89 3c 24             	mov    %edi,(%esp)
f010219b:	e8 5e f0 ff ff       	call   f01011fe <pgdir_walk>
f01021a0:	f6 00 04             	testb  $0x4,(%eax)
f01021a3:	75 24                	jne    f01021c9 <mem_init+0xcce>
f01021a5:	c7 44 24 0c 70 7a 10 	movl   $0xf0107a70,0xc(%esp)
f01021ac:	f0 
f01021ad:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01021b4:	f0 
f01021b5:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f01021bc:	00 
f01021bd:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01021c4:	e8 77 de ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01021c9:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f01021ce:	f6 00 04             	testb  $0x4,(%eax)
f01021d1:	75 24                	jne    f01021f7 <mem_init+0xcfc>
f01021d3:	c7 44 24 0c 3d 76 10 	movl   $0xf010763d,0xc(%esp)
f01021da:	f0 
f01021db:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01021e2:	f0 
f01021e3:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f01021ea:	00 
f01021eb:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01021f2:	e8 49 de ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01021f7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021fe:	00 
f01021ff:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102206:	00 
f0102207:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010220b:	89 04 24             	mov    %eax,(%esp)
f010220e:	e8 f8 f1 ff ff       	call   f010140b <page_insert>
f0102213:	85 c0                	test   %eax,%eax
f0102215:	74 24                	je     f010223b <mem_init+0xd40>
f0102217:	c7 44 24 0c 84 79 10 	movl   $0xf0107984,0xc(%esp)
f010221e:	f0 
f010221f:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102226:	f0 
f0102227:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f010222e:	00 
f010222f:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102236:	e8 05 de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010223b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102242:	00 
f0102243:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010224a:	00 
f010224b:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0102250:	89 04 24             	mov    %eax,(%esp)
f0102253:	e8 a6 ef ff ff       	call   f01011fe <pgdir_walk>
f0102258:	f6 00 02             	testb  $0x2,(%eax)
f010225b:	75 24                	jne    f0102281 <mem_init+0xd86>
f010225d:	c7 44 24 0c a4 7a 10 	movl   $0xf0107aa4,0xc(%esp)
f0102264:	f0 
f0102265:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010226c:	f0 
f010226d:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0102274:	00 
f0102275:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010227c:	e8 bf dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102281:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102288:	00 
f0102289:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102290:	00 
f0102291:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0102296:	89 04 24             	mov    %eax,(%esp)
f0102299:	e8 60 ef ff ff       	call   f01011fe <pgdir_walk>
f010229e:	f6 00 04             	testb  $0x4,(%eax)
f01022a1:	74 24                	je     f01022c7 <mem_init+0xdcc>
f01022a3:	c7 44 24 0c d8 7a 10 	movl   $0xf0107ad8,0xc(%esp)
f01022aa:	f0 
f01022ab:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01022b2:	f0 
f01022b3:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f01022ba:	00 
f01022bb:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01022c2:	e8 79 dd ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01022c7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01022ce:	00 
f01022cf:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01022d6:	00 
f01022d7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01022db:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f01022e0:	89 04 24             	mov    %eax,(%esp)
f01022e3:	e8 23 f1 ff ff       	call   f010140b <page_insert>
f01022e8:	85 c0                	test   %eax,%eax
f01022ea:	78 24                	js     f0102310 <mem_init+0xe15>
f01022ec:	c7 44 24 0c 10 7b 10 	movl   $0xf0107b10,0xc(%esp)
f01022f3:	f0 
f01022f4:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01022fb:	f0 
f01022fc:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0102303:	00 
f0102304:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010230b:	e8 30 dd ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102310:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102317:	00 
f0102318:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010231f:	00 
f0102320:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102323:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102327:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f010232c:	89 04 24             	mov    %eax,(%esp)
f010232f:	e8 d7 f0 ff ff       	call   f010140b <page_insert>
f0102334:	85 c0                	test   %eax,%eax
f0102336:	74 24                	je     f010235c <mem_init+0xe61>
f0102338:	c7 44 24 0c 48 7b 10 	movl   $0xf0107b48,0xc(%esp)
f010233f:	f0 
f0102340:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102347:	f0 
f0102348:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f010234f:	00 
f0102350:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102357:	e8 e4 dc ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010235c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102363:	00 
f0102364:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010236b:	00 
f010236c:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0102371:	89 04 24             	mov    %eax,(%esp)
f0102374:	e8 85 ee ff ff       	call   f01011fe <pgdir_walk>
f0102379:	f6 00 04             	testb  $0x4,(%eax)
f010237c:	74 24                	je     f01023a2 <mem_init+0xea7>
f010237e:	c7 44 24 0c d8 7a 10 	movl   $0xf0107ad8,0xc(%esp)
f0102385:	f0 
f0102386:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010238d:	f0 
f010238e:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0102395:	00 
f0102396:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010239d:	e8 9e dc ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01023a2:	8b 3d 8c 6e 22 f0    	mov    0xf0226e8c,%edi
f01023a8:	ba 00 00 00 00       	mov    $0x0,%edx
f01023ad:	89 f8                	mov    %edi,%eax
f01023af:	e8 23 e8 ff ff       	call   f0100bd7 <check_va2pa>
f01023b4:	89 c1                	mov    %eax,%ecx
f01023b6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01023b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023bc:	2b 05 90 6e 22 f0    	sub    0xf0226e90,%eax
f01023c2:	c1 f8 03             	sar    $0x3,%eax
f01023c5:	c1 e0 0c             	shl    $0xc,%eax
f01023c8:	39 c1                	cmp    %eax,%ecx
f01023ca:	74 24                	je     f01023f0 <mem_init+0xef5>
f01023cc:	c7 44 24 0c 84 7b 10 	movl   $0xf0107b84,0xc(%esp)
f01023d3:	f0 
f01023d4:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01023db:	f0 
f01023dc:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f01023e3:	00 
f01023e4:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01023eb:	e8 50 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023f0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023f5:	89 f8                	mov    %edi,%eax
f01023f7:	e8 db e7 ff ff       	call   f0100bd7 <check_va2pa>
f01023fc:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01023ff:	74 24                	je     f0102425 <mem_init+0xf2a>
f0102401:	c7 44 24 0c b0 7b 10 	movl   $0xf0107bb0,0xc(%esp)
f0102408:	f0 
f0102409:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102410:	f0 
f0102411:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0102418:	00 
f0102419:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102420:	e8 1b dc ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102425:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102428:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f010242d:	74 24                	je     f0102453 <mem_init+0xf58>
f010242f:	c7 44 24 0c 53 76 10 	movl   $0xf0107653,0xc(%esp)
f0102436:	f0 
f0102437:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010243e:	f0 
f010243f:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0102446:	00 
f0102447:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010244e:	e8 ed db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102453:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102458:	74 24                	je     f010247e <mem_init+0xf83>
f010245a:	c7 44 24 0c 64 76 10 	movl   $0xf0107664,0xc(%esp)
f0102461:	f0 
f0102462:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102469:	f0 
f010246a:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f0102471:	00 
f0102472:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102479:	e8 c2 db ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010247e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102485:	e8 a6 ec ff ff       	call   f0101130 <page_alloc>
f010248a:	85 c0                	test   %eax,%eax
f010248c:	74 04                	je     f0102492 <mem_init+0xf97>
f010248e:	39 c3                	cmp    %eax,%ebx
f0102490:	74 24                	je     f01024b6 <mem_init+0xfbb>
f0102492:	c7 44 24 0c e0 7b 10 	movl   $0xf0107be0,0xc(%esp)
f0102499:	f0 
f010249a:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01024a1:	f0 
f01024a2:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f01024a9:	00 
f01024aa:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01024b1:	e8 8a db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01024b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01024bd:	00 
f01024be:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f01024c3:	89 04 24             	mov    %eax,(%esp)
f01024c6:	e8 f0 ee ff ff       	call   f01013bb <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01024cb:	8b 3d 8c 6e 22 f0    	mov    0xf0226e8c,%edi
f01024d1:	ba 00 00 00 00       	mov    $0x0,%edx
f01024d6:	89 f8                	mov    %edi,%eax
f01024d8:	e8 fa e6 ff ff       	call   f0100bd7 <check_va2pa>
f01024dd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024e0:	74 24                	je     f0102506 <mem_init+0x100b>
f01024e2:	c7 44 24 0c 04 7c 10 	movl   $0xf0107c04,0xc(%esp)
f01024e9:	f0 
f01024ea:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01024f1:	f0 
f01024f2:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f01024f9:	00 
f01024fa:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102501:	e8 3a db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102506:	ba 00 10 00 00       	mov    $0x1000,%edx
f010250b:	89 f8                	mov    %edi,%eax
f010250d:	e8 c5 e6 ff ff       	call   f0100bd7 <check_va2pa>
f0102512:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102515:	2b 15 90 6e 22 f0    	sub    0xf0226e90,%edx
f010251b:	c1 fa 03             	sar    $0x3,%edx
f010251e:	c1 e2 0c             	shl    $0xc,%edx
f0102521:	39 d0                	cmp    %edx,%eax
f0102523:	74 24                	je     f0102549 <mem_init+0x104e>
f0102525:	c7 44 24 0c b0 7b 10 	movl   $0xf0107bb0,0xc(%esp)
f010252c:	f0 
f010252d:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102534:	f0 
f0102535:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f010253c:	00 
f010253d:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102544:	e8 f7 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102549:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010254c:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102551:	74 24                	je     f0102577 <mem_init+0x107c>
f0102553:	c7 44 24 0c 0a 76 10 	movl   $0xf010760a,0xc(%esp)
f010255a:	f0 
f010255b:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102562:	f0 
f0102563:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f010256a:	00 
f010256b:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102572:	e8 c9 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102577:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010257c:	74 24                	je     f01025a2 <mem_init+0x10a7>
f010257e:	c7 44 24 0c 64 76 10 	movl   $0xf0107664,0xc(%esp)
f0102585:	f0 
f0102586:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010258d:	f0 
f010258e:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0102595:	00 
f0102596:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010259d:	e8 9e da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01025a2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025a9:	00 
f01025aa:	89 3c 24             	mov    %edi,(%esp)
f01025ad:	e8 09 ee ff ff       	call   f01013bb <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025b2:	8b 3d 8c 6e 22 f0    	mov    0xf0226e8c,%edi
f01025b8:	ba 00 00 00 00       	mov    $0x0,%edx
f01025bd:	89 f8                	mov    %edi,%eax
f01025bf:	e8 13 e6 ff ff       	call   f0100bd7 <check_va2pa>
f01025c4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025c7:	74 24                	je     f01025ed <mem_init+0x10f2>
f01025c9:	c7 44 24 0c 04 7c 10 	movl   $0xf0107c04,0xc(%esp)
f01025d0:	f0 
f01025d1:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01025d8:	f0 
f01025d9:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f01025e0:	00 
f01025e1:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01025e8:	e8 53 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01025ed:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025f2:	89 f8                	mov    %edi,%eax
f01025f4:	e8 de e5 ff ff       	call   f0100bd7 <check_va2pa>
f01025f9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025fc:	74 24                	je     f0102622 <mem_init+0x1127>
f01025fe:	c7 44 24 0c 28 7c 10 	movl   $0xf0107c28,0xc(%esp)
f0102605:	f0 
f0102606:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010260d:	f0 
f010260e:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0102615:	00 
f0102616:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010261d:	e8 1e da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102622:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102625:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010262a:	74 24                	je     f0102650 <mem_init+0x1155>
f010262c:	c7 44 24 0c 75 76 10 	movl   $0xf0107675,0xc(%esp)
f0102633:	f0 
f0102634:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010263b:	f0 
f010263c:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f0102643:	00 
f0102644:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010264b:	e8 f0 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102650:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102655:	74 24                	je     f010267b <mem_init+0x1180>
f0102657:	c7 44 24 0c 64 76 10 	movl   $0xf0107664,0xc(%esp)
f010265e:	f0 
f010265f:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102666:	f0 
f0102667:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f010266e:	00 
f010266f:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102676:	e8 c5 d9 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010267b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102682:	e8 a9 ea ff ff       	call   f0101130 <page_alloc>
f0102687:	85 c0                	test   %eax,%eax
f0102689:	74 05                	je     f0102690 <mem_init+0x1195>
f010268b:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010268e:	74 24                	je     f01026b4 <mem_init+0x11b9>
f0102690:	c7 44 24 0c 50 7c 10 	movl   $0xf0107c50,0xc(%esp)
f0102697:	f0 
f0102698:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010269f:	f0 
f01026a0:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f01026a7:	00 
f01026a8:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01026af:	e8 8c d9 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01026b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026bb:	e8 70 ea ff ff       	call   f0101130 <page_alloc>
f01026c0:	85 c0                	test   %eax,%eax
f01026c2:	74 24                	je     f01026e8 <mem_init+0x11ed>
f01026c4:	c7 44 24 0c b8 75 10 	movl   $0xf01075b8,0xc(%esp)
f01026cb:	f0 
f01026cc:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01026d3:	f0 
f01026d4:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f01026db:	00 
f01026dc:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01026e3:	e8 58 d9 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026e8:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f01026ed:	8b 08                	mov    (%eax),%ecx
f01026ef:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01026f5:	89 f2                	mov    %esi,%edx
f01026f7:	2b 15 90 6e 22 f0    	sub    0xf0226e90,%edx
f01026fd:	c1 fa 03             	sar    $0x3,%edx
f0102700:	c1 e2 0c             	shl    $0xc,%edx
f0102703:	39 d1                	cmp    %edx,%ecx
f0102705:	74 24                	je     f010272b <mem_init+0x1230>
f0102707:	c7 44 24 0c 2c 79 10 	movl   $0xf010792c,0xc(%esp)
f010270e:	f0 
f010270f:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102716:	f0 
f0102717:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f010271e:	00 
f010271f:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102726:	e8 15 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010272b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102731:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102736:	74 24                	je     f010275c <mem_init+0x1261>
f0102738:	c7 44 24 0c 1b 76 10 	movl   $0xf010761b,0xc(%esp)
f010273f:	f0 
f0102740:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102747:	f0 
f0102748:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f010274f:	00 
f0102750:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102757:	e8 e4 d8 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010275c:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102762:	89 34 24             	mov    %esi,(%esp)
f0102765:	e8 51 ea ff ff       	call   f01011bb <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010276a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102771:	00 
f0102772:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102779:	00 
f010277a:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f010277f:	89 04 24             	mov    %eax,(%esp)
f0102782:	e8 77 ea ff ff       	call   f01011fe <pgdir_walk>
f0102787:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010278a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010278d:	8b 15 8c 6e 22 f0    	mov    0xf0226e8c,%edx
f0102793:	8b 7a 04             	mov    0x4(%edx),%edi
f0102796:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f010279c:	8b 0d 88 6e 22 f0    	mov    0xf0226e88,%ecx
f01027a2:	89 f8                	mov    %edi,%eax
f01027a4:	c1 e8 0c             	shr    $0xc,%eax
f01027a7:	39 c8                	cmp    %ecx,%eax
f01027a9:	72 20                	jb     f01027cb <mem_init+0x12d0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01027af:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f01027b6:	f0 
f01027b7:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f01027be:	00 
f01027bf:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01027c6:	e8 75 d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01027cb:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f01027d1:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01027d4:	74 24                	je     f01027fa <mem_init+0x12ff>
f01027d6:	c7 44 24 0c 86 76 10 	movl   $0xf0107686,0xc(%esp)
f01027dd:	f0 
f01027de:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01027e5:	f0 
f01027e6:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f01027ed:	00 
f01027ee:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01027f5:	e8 46 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01027fa:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102801:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
	return (pp - pages) << PGSHIFT;
f0102807:	89 f0                	mov    %esi,%eax
f0102809:	2b 05 90 6e 22 f0    	sub    0xf0226e90,%eax
f010280f:	c1 f8 03             	sar    $0x3,%eax
f0102812:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102815:	89 c2                	mov    %eax,%edx
f0102817:	c1 ea 0c             	shr    $0xc,%edx
f010281a:	39 d1                	cmp    %edx,%ecx
f010281c:	77 20                	ja     f010283e <mem_init+0x1343>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010281e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102822:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0102829:	f0 
f010282a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102831:	00 
f0102832:	c7 04 24 2b 74 10 f0 	movl   $0xf010742b,(%esp)
f0102839:	e8 02 d8 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010283e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102845:	00 
f0102846:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010284d:	00 
	return (void *)(pa + KERNBASE);
f010284e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102853:	89 04 24             	mov    %eax,(%esp)
f0102856:	e8 5e 38 00 00       	call   f01060b9 <memset>
	page_free(pp0);
f010285b:	89 34 24             	mov    %esi,(%esp)
f010285e:	e8 58 e9 ff ff       	call   f01011bb <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102863:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010286a:	00 
f010286b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102872:	00 
f0102873:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0102878:	89 04 24             	mov    %eax,(%esp)
f010287b:	e8 7e e9 ff ff       	call   f01011fe <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102880:	89 f2                	mov    %esi,%edx
f0102882:	2b 15 90 6e 22 f0    	sub    0xf0226e90,%edx
f0102888:	c1 fa 03             	sar    $0x3,%edx
f010288b:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010288e:	89 d0                	mov    %edx,%eax
f0102890:	c1 e8 0c             	shr    $0xc,%eax
f0102893:	3b 05 88 6e 22 f0    	cmp    0xf0226e88,%eax
f0102899:	72 20                	jb     f01028bb <mem_init+0x13c0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010289b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010289f:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f01028a6:	f0 
f01028a7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01028ae:	00 
f01028af:	c7 04 24 2b 74 10 f0 	movl   $0xf010742b,(%esp)
f01028b6:	e8 85 d7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01028bb:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01028c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01028c4:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f01028cb:	75 11                	jne    f01028de <mem_init+0x13e3>
f01028cd:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
f01028d3:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f01028d9:	f6 00 01             	testb  $0x1,(%eax)
f01028dc:	74 24                	je     f0102902 <mem_init+0x1407>
f01028de:	c7 44 24 0c 9e 76 10 	movl   $0xf010769e,0xc(%esp)
f01028e5:	f0 
f01028e6:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01028ed:	f0 
f01028ee:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f01028f5:	00 
f01028f6:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01028fd:	e8 3e d7 ff ff       	call   f0100040 <_panic>
f0102902:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102905:	39 d0                	cmp    %edx,%eax
f0102907:	75 d0                	jne    f01028d9 <mem_init+0x13de>
	kern_pgdir[0] = 0;
f0102909:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f010290e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102914:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f010291a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010291d:	a3 40 62 22 f0       	mov    %eax,0xf0226240

	// free the pages we took
	page_free(pp0);
f0102922:	89 34 24             	mov    %esi,(%esp)
f0102925:	e8 91 e8 ff ff       	call   f01011bb <page_free>
	page_free(pp1);
f010292a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010292d:	89 04 24             	mov    %eax,(%esp)
f0102930:	e8 86 e8 ff ff       	call   f01011bb <page_free>
	page_free(pp2);
f0102935:	89 1c 24             	mov    %ebx,(%esp)
f0102938:	e8 7e e8 ff ff       	call   f01011bb <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010293d:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102944:	00 
f0102945:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010294c:	e8 3b eb ff ff       	call   f010148c <mmio_map_region>
f0102951:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102953:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010295a:	00 
f010295b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102962:	e8 25 eb ff ff       	call   f010148c <mmio_map_region>
f0102967:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102969:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010296f:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102974:	77 08                	ja     f010297e <mem_init+0x1483>
f0102976:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010297c:	77 24                	ja     f01029a2 <mem_init+0x14a7>
f010297e:	c7 44 24 0c 74 7c 10 	movl   $0xf0107c74,0xc(%esp)
f0102985:	f0 
f0102986:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010298d:	f0 
f010298e:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f0102995:	00 
f0102996:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010299d:	e8 9e d6 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01029a2:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01029a8:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01029ae:	77 08                	ja     f01029b8 <mem_init+0x14bd>
f01029b0:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01029b6:	77 24                	ja     f01029dc <mem_init+0x14e1>
f01029b8:	c7 44 24 0c 9c 7c 10 	movl   $0xf0107c9c,0xc(%esp)
f01029bf:	f0 
f01029c0:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01029c7:	f0 
f01029c8:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f01029cf:	00 
f01029d0:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01029d7:	e8 64 d6 ff ff       	call   f0100040 <_panic>
f01029dc:	89 da                	mov    %ebx,%edx
f01029de:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01029e0:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01029e6:	74 24                	je     f0102a0c <mem_init+0x1511>
f01029e8:	c7 44 24 0c c4 7c 10 	movl   $0xf0107cc4,0xc(%esp)
f01029ef:	f0 
f01029f0:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01029f7:	f0 
f01029f8:	c7 44 24 04 24 04 00 	movl   $0x424,0x4(%esp)
f01029ff:	00 
f0102a00:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102a07:	e8 34 d6 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102a0c:	39 c6                	cmp    %eax,%esi
f0102a0e:	73 24                	jae    f0102a34 <mem_init+0x1539>
f0102a10:	c7 44 24 0c b5 76 10 	movl   $0xf01076b5,0xc(%esp)
f0102a17:	f0 
f0102a18:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102a1f:	f0 
f0102a20:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f0102a27:	00 
f0102a28:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102a2f:	e8 0c d6 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102a34:	8b 3d 8c 6e 22 f0    	mov    0xf0226e8c,%edi
f0102a3a:	89 da                	mov    %ebx,%edx
f0102a3c:	89 f8                	mov    %edi,%eax
f0102a3e:	e8 94 e1 ff ff       	call   f0100bd7 <check_va2pa>
f0102a43:	85 c0                	test   %eax,%eax
f0102a45:	74 24                	je     f0102a6b <mem_init+0x1570>
f0102a47:	c7 44 24 0c ec 7c 10 	movl   $0xf0107cec,0xc(%esp)
f0102a4e:	f0 
f0102a4f:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102a56:	f0 
f0102a57:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f0102a5e:	00 
f0102a5f:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102a66:	e8 d5 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102a6b:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102a71:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102a74:	89 c2                	mov    %eax,%edx
f0102a76:	89 f8                	mov    %edi,%eax
f0102a78:	e8 5a e1 ff ff       	call   f0100bd7 <check_va2pa>
f0102a7d:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102a82:	74 24                	je     f0102aa8 <mem_init+0x15ad>
f0102a84:	c7 44 24 0c 10 7d 10 	movl   $0xf0107d10,0xc(%esp)
f0102a8b:	f0 
f0102a8c:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102a93:	f0 
f0102a94:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f0102a9b:	00 
f0102a9c:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102aa3:	e8 98 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102aa8:	89 f2                	mov    %esi,%edx
f0102aaa:	89 f8                	mov    %edi,%eax
f0102aac:	e8 26 e1 ff ff       	call   f0100bd7 <check_va2pa>
f0102ab1:	85 c0                	test   %eax,%eax
f0102ab3:	74 24                	je     f0102ad9 <mem_init+0x15de>
f0102ab5:	c7 44 24 0c 40 7d 10 	movl   $0xf0107d40,0xc(%esp)
f0102abc:	f0 
f0102abd:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102ac4:	f0 
f0102ac5:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f0102acc:	00 
f0102acd:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102ad4:	e8 67 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102ad9:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102adf:	89 f8                	mov    %edi,%eax
f0102ae1:	e8 f1 e0 ff ff       	call   f0100bd7 <check_va2pa>
f0102ae6:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102ae9:	74 24                	je     f0102b0f <mem_init+0x1614>
f0102aeb:	c7 44 24 0c 64 7d 10 	movl   $0xf0107d64,0xc(%esp)
f0102af2:	f0 
f0102af3:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102afa:	f0 
f0102afb:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0102b02:	00 
f0102b03:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102b0a:	e8 31 d5 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102b0f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b16:	00 
f0102b17:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b1b:	89 3c 24             	mov    %edi,(%esp)
f0102b1e:	e8 db e6 ff ff       	call   f01011fe <pgdir_walk>
f0102b23:	f6 00 1a             	testb  $0x1a,(%eax)
f0102b26:	75 24                	jne    f0102b4c <mem_init+0x1651>
f0102b28:	c7 44 24 0c 90 7d 10 	movl   $0xf0107d90,0xc(%esp)
f0102b2f:	f0 
f0102b30:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102b37:	f0 
f0102b38:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f0102b3f:	00 
f0102b40:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102b47:	e8 f4 d4 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102b4c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b53:	00 
f0102b54:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b58:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0102b5d:	89 04 24             	mov    %eax,(%esp)
f0102b60:	e8 99 e6 ff ff       	call   f01011fe <pgdir_walk>
f0102b65:	f6 00 04             	testb  $0x4,(%eax)
f0102b68:	74 24                	je     f0102b8e <mem_init+0x1693>
f0102b6a:	c7 44 24 0c d4 7d 10 	movl   $0xf0107dd4,0xc(%esp)
f0102b71:	f0 
f0102b72:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102b79:	f0 
f0102b7a:	c7 44 24 04 2e 04 00 	movl   $0x42e,0x4(%esp)
f0102b81:	00 
f0102b82:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102b89:	e8 b2 d4 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102b8e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b95:	00 
f0102b96:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b9a:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0102b9f:	89 04 24             	mov    %eax,(%esp)
f0102ba2:	e8 57 e6 ff ff       	call   f01011fe <pgdir_walk>
f0102ba7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102bad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102bb4:	00 
f0102bb5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102bbc:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0102bc1:	89 04 24             	mov    %eax,(%esp)
f0102bc4:	e8 35 e6 ff ff       	call   f01011fe <pgdir_walk>
f0102bc9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102bcf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102bd6:	00 
f0102bd7:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102bdb:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0102be0:	89 04 24             	mov    %eax,(%esp)
f0102be3:	e8 16 e6 ff ff       	call   f01011fe <pgdir_walk>
f0102be8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102bee:	c7 04 24 c7 76 10 f0 	movl   $0xf01076c7,(%esp)
f0102bf5:	e8 cf 13 00 00       	call   f0103fc9 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, sizeof(struct PageInfo) * npages, PADDR(pages), PTE_W);
f0102bfa:	a1 90 6e 22 f0       	mov    0xf0226e90,%eax
	if ((uint32_t)kva < KERNBASE)
f0102bff:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c04:	77 20                	ja     f0102c26 <mem_init+0x172b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c06:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c0a:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0102c11:	f0 
f0102c12:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
f0102c19:	00 
f0102c1a:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102c21:	e8 1a d4 ff ff       	call   f0100040 <_panic>
f0102c26:	8b 0d 88 6e 22 f0    	mov    0xf0226e88,%ecx
f0102c2c:	c1 e1 03             	shl    $0x3,%ecx
f0102c2f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102c36:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c37:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c3c:	89 04 24             	mov    %eax,(%esp)
f0102c3f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102c44:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0102c49:	e8 51 e6 ff ff       	call   f010129f <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, sizeof(struct Env) * NENV, PADDR(envs), PTE_U | PTE_W);
f0102c4e:	a1 48 62 22 f0       	mov    0xf0226248,%eax
	if ((uint32_t)kva < KERNBASE)
f0102c53:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c58:	77 20                	ja     f0102c7a <mem_init+0x177f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c5e:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0102c65:	f0 
f0102c66:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f0102c6d:	00 
f0102c6e:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102c75:	e8 c6 d3 ff ff       	call   f0100040 <_panic>
f0102c7a:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
f0102c81:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c82:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c87:	89 04 24             	mov    %eax,(%esp)
f0102c8a:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102c8f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102c94:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0102c99:	e8 01 e6 ff ff       	call   f010129f <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102c9e:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102ca3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ca8:	77 20                	ja     f0102cca <mem_init+0x17cf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102caa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cae:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0102cb5:	f0 
f0102cb6:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
f0102cbd:	00 
f0102cbe:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102cc5:	e8 76 d3 ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102cca:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102cd1:	00 
f0102cd2:	c7 04 24 00 70 11 00 	movl   $0x117000,(%esp)
f0102cd9:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102cde:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102ce3:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0102ce8:	e8 b2 e5 ff ff       	call   f010129f <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffffu - KERNBASE, 0, PTE_W);
f0102ced:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102cf4:	00 
f0102cf5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102cfc:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102d01:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102d06:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0102d0b:	e8 8f e5 ff ff       	call   f010129f <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102d10:	b8 00 80 22 f0       	mov    $0xf0228000,%eax
f0102d15:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d1a:	0f 87 30 07 00 00    	ja     f0103450 <mem_init+0x1f55>
f0102d20:	eb 0c                	jmp    f0102d2e <mem_init+0x1833>
		boot_map_region(kern_pgdir, start, KSTKSIZE, PADDR(percpu_kstacks + i), PTE_W);
f0102d22:	89 d8                	mov    %ebx,%eax
f0102d24:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102d2a:	77 27                	ja     f0102d53 <mem_init+0x1858>
f0102d2c:	eb 05                	jmp    f0102d33 <mem_init+0x1838>
f0102d2e:	b8 00 80 22 f0       	mov    $0xf0228000,%eax
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d33:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d37:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0102d3e:	f0 
f0102d3f:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
f0102d46:	00 
f0102d47:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102d4e:	e8 ed d2 ff ff       	call   f0100040 <_panic>
f0102d53:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102d5a:	00 
f0102d5b:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102d61:	89 04 24             	mov    %eax,(%esp)
f0102d64:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d69:	89 f2                	mov    %esi,%edx
f0102d6b:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0102d70:	e8 2a e5 ff ff       	call   f010129f <boot_map_region>
f0102d75:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102d7b:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for(i = 0; i < NCPU; ++i){
f0102d81:	39 fb                	cmp    %edi,%ebx
f0102d83:	75 9d                	jne    f0102d22 <mem_init+0x1827>
	pgdir = kern_pgdir;
f0102d85:	8b 3d 8c 6e 22 f0    	mov    0xf0226e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102d8b:	a1 88 6e 22 f0       	mov    0xf0226e88,%eax
f0102d90:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102d93:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
	for (i = 0; i < n; i += PGSIZE)
f0102d9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d9f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102da2:	75 30                	jne    f0102dd4 <mem_init+0x18d9>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102da4:	8b 1d 48 62 22 f0    	mov    0xf0226248,%ebx
	if ((uint32_t)kva < KERNBASE)
f0102daa:	89 de                	mov    %ebx,%esi
f0102dac:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102db1:	89 f8                	mov    %edi,%eax
f0102db3:	e8 1f de ff ff       	call   f0100bd7 <check_va2pa>
f0102db8:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102dbe:	0f 86 94 00 00 00    	jbe    f0102e58 <mem_init+0x195d>
f0102dc4:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102dc9:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0102dcf:	e9 a4 00 00 00       	jmp    f0102e78 <mem_init+0x197d>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102dd4:	8b 1d 90 6e 22 f0    	mov    0xf0226e90,%ebx
	return (physaddr_t)kva - KERNBASE;
f0102dda:	8d b3 00 00 00 10    	lea    0x10000000(%ebx),%esi
f0102de0:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102de5:	89 f8                	mov    %edi,%eax
f0102de7:	e8 eb dd ff ff       	call   f0100bd7 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102dec:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102df2:	77 20                	ja     f0102e14 <mem_init+0x1919>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102df4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102df8:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0102dff:	f0 
f0102e00:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0102e07:	00 
f0102e08:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102e0f:	e8 2c d2 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102e14:	ba 00 00 00 00       	mov    $0x0,%edx
f0102e19:	8d 0c 16             	lea    (%esi,%edx,1),%ecx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e1c:	39 c1                	cmp    %eax,%ecx
f0102e1e:	74 24                	je     f0102e44 <mem_init+0x1949>
f0102e20:	c7 44 24 0c 08 7e 10 	movl   $0xf0107e08,0xc(%esp)
f0102e27:	f0 
f0102e28:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102e2f:	f0 
f0102e30:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0102e37:	00 
f0102e38:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102e3f:	e8 fc d1 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102e44:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
f0102e4a:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102e4d:	0f 87 52 06 00 00    	ja     f01034a5 <mem_init+0x1faa>
f0102e53:	e9 4c ff ff ff       	jmp    f0102da4 <mem_init+0x18a9>
f0102e58:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102e5c:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0102e63:	f0 
f0102e64:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0102e6b:	00 
f0102e6c:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102e73:	e8 c8 d1 ff ff       	call   f0100040 <_panic>
f0102e78:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e7b:	39 d0                	cmp    %edx,%eax
f0102e7d:	74 24                	je     f0102ea3 <mem_init+0x19a8>
f0102e7f:	c7 44 24 0c 3c 7e 10 	movl   $0xf0107e3c,0xc(%esp)
f0102e86:	f0 
f0102e87:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102e8e:	f0 
f0102e8f:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0102e96:	00 
f0102e97:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102e9e:	e8 9d d1 ff ff       	call   f0100040 <_panic>
f0102ea3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102ea9:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102eaf:	0f 85 e0 05 00 00    	jne    f0103495 <mem_init+0x1f9a>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102eb5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102eb8:	c1 e6 0c             	shl    $0xc,%esi
f0102ebb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ec0:	85 f6                	test   %esi,%esi
f0102ec2:	75 22                	jne    f0102ee6 <mem_init+0x19eb>
f0102ec4:	c7 45 d0 00 80 22 f0 	movl   $0xf0228000,-0x30(%ebp)
f0102ecb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102ed2:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102ed7:	b8 00 80 22 f0       	mov    $0xf0228000,%eax
f0102edc:	05 00 80 00 20       	add    $0x20008000,%eax
f0102ee1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102ee4:	eb 41                	jmp    f0102f27 <mem_init+0x1a2c>
f0102ee6:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102eec:	89 f8                	mov    %edi,%eax
f0102eee:	e8 e4 dc ff ff       	call   f0100bd7 <check_va2pa>
f0102ef3:	39 c3                	cmp    %eax,%ebx
f0102ef5:	74 24                	je     f0102f1b <mem_init+0x1a20>
f0102ef7:	c7 44 24 0c 70 7e 10 	movl   $0xf0107e70,0xc(%esp)
f0102efe:	f0 
f0102eff:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102f06:	f0 
f0102f07:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0102f0e:	00 
f0102f0f:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102f16:	e8 25 d1 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f1b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f21:	39 de                	cmp    %ebx,%esi
f0102f23:	77 c1                	ja     f0102ee6 <mem_init+0x19eb>
f0102f25:	eb 9d                	jmp    f0102ec4 <mem_init+0x19c9>
f0102f27:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102f2d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f30:	89 f2                	mov    %esi,%edx
f0102f32:	89 f8                	mov    %edi,%eax
f0102f34:	e8 9e dc ff ff       	call   f0100bd7 <check_va2pa>
f0102f39:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if ((uint32_t)kva < KERNBASE)
f0102f3c:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0102f42:	77 20                	ja     f0102f64 <mem_init+0x1a69>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f44:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102f48:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0102f4f:	f0 
f0102f50:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0102f57:	00 
f0102f58:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102f5f:	e8 dc d0 ff ff       	call   f0100040 <_panic>
	if ((uint32_t)kva < KERNBASE)
f0102f64:	89 f3                	mov    %esi,%ebx
f0102f66:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102f69:	03 4d c4             	add    -0x3c(%ebp),%ecx
f0102f6c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102f6f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102f72:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102f75:	39 c2                	cmp    %eax,%edx
f0102f77:	74 24                	je     f0102f9d <mem_init+0x1aa2>
f0102f79:	c7 44 24 0c 98 7e 10 	movl   $0xf0107e98,0xc(%esp)
f0102f80:	f0 
f0102f81:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102f88:	f0 
f0102f89:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0102f90:	00 
f0102f91:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102f98:	e8 a3 d0 ff ff       	call   f0100040 <_panic>
f0102f9d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102fa3:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f0102fa6:	0f 85 db 04 00 00    	jne    f0103487 <mem_init+0x1f8c>
f0102fac:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102fb2:	89 da                	mov    %ebx,%edx
f0102fb4:	89 f8                	mov    %edi,%eax
f0102fb6:	e8 1c dc ff ff       	call   f0100bd7 <check_va2pa>
f0102fbb:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102fbe:	74 24                	je     f0102fe4 <mem_init+0x1ae9>
f0102fc0:	c7 44 24 0c e0 7e 10 	movl   $0xf0107ee0,0xc(%esp)
f0102fc7:	f0 
f0102fc8:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0102fcf:	f0 
f0102fd0:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0102fd7:	00 
f0102fd8:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0102fdf:	e8 5c d0 ff ff       	call   f0100040 <_panic>
f0102fe4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102fea:	39 f3                	cmp    %esi,%ebx
f0102fec:	75 c4                	jne    f0102fb2 <mem_init+0x1ab7>
f0102fee:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102ff4:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f0102ffb:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (n = 0; n < NCPU; n++) {
f0103002:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103008:	0f 85 19 ff ff ff    	jne    f0102f27 <mem_init+0x1a2c>
f010300e:	b8 00 00 00 00       	mov    $0x0,%eax
		switch (i) {
f0103013:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103019:	83 fa 04             	cmp    $0x4,%edx
f010301c:	77 2e                	ja     f010304c <mem_init+0x1b51>
			assert(pgdir[i] & PTE_P);
f010301e:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0103022:	0f 85 aa 00 00 00    	jne    f01030d2 <mem_init+0x1bd7>
f0103028:	c7 44 24 0c e0 76 10 	movl   $0xf01076e0,0xc(%esp)
f010302f:	f0 
f0103030:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0103037:	f0 
f0103038:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f010303f:	00 
f0103040:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0103047:	e8 f4 cf ff ff       	call   f0100040 <_panic>
			if (i >= PDX(KERNBASE)) {
f010304c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103051:	76 55                	jbe    f01030a8 <mem_init+0x1bad>
				assert(pgdir[i] & PTE_P);
f0103053:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103056:	f6 c2 01             	test   $0x1,%dl
f0103059:	75 24                	jne    f010307f <mem_init+0x1b84>
f010305b:	c7 44 24 0c e0 76 10 	movl   $0xf01076e0,0xc(%esp)
f0103062:	f0 
f0103063:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010306a:	f0 
f010306b:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0103072:	00 
f0103073:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010307a:	e8 c1 cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f010307f:	f6 c2 02             	test   $0x2,%dl
f0103082:	75 4e                	jne    f01030d2 <mem_init+0x1bd7>
f0103084:	c7 44 24 0c f1 76 10 	movl   $0xf01076f1,0xc(%esp)
f010308b:	f0 
f010308c:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0103093:	f0 
f0103094:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f010309b:	00 
f010309c:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01030a3:	e8 98 cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f01030a8:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01030ac:	74 24                	je     f01030d2 <mem_init+0x1bd7>
f01030ae:	c7 44 24 0c 02 77 10 	movl   $0xf0107702,0xc(%esp)
f01030b5:	f0 
f01030b6:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01030bd:	f0 
f01030be:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f01030c5:	00 
f01030c6:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01030cd:	e8 6e cf ff ff       	call   f0100040 <_panic>
	for (i = 0; i < NPDENTRIES; i++) {
f01030d2:	83 c0 01             	add    $0x1,%eax
f01030d5:	3d 00 04 00 00       	cmp    $0x400,%eax
f01030da:	0f 85 33 ff ff ff    	jne    f0103013 <mem_init+0x1b18>
	cprintf("check_kern_pgdir() succeeded!\n");
f01030e0:	c7 04 24 04 7f 10 f0 	movl   $0xf0107f04,(%esp)
f01030e7:	e8 dd 0e 00 00       	call   f0103fc9 <cprintf>
	lcr3(PADDR(kern_pgdir));
f01030ec:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f01030f1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030f6:	77 20                	ja     f0103118 <mem_init+0x1c1d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030fc:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0103103:	f0 
f0103104:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
f010310b:	00 
f010310c:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0103113:	e8 28 cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103118:	05 00 00 00 10       	add    $0x10000000,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010311d:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0103120:	b8 00 00 00 00       	mov    $0x0,%eax
f0103125:	e8 1c db ff ff       	call   f0100c46 <check_page_free_list>
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010312a:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010312d:	83 e0 f3             	and    $0xfffffff3,%eax
f0103130:	0d 23 00 05 80       	or     $0x80050023,%eax
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103135:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103138:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010313f:	e8 ec df ff ff       	call   f0101130 <page_alloc>
f0103144:	89 c3                	mov    %eax,%ebx
f0103146:	85 c0                	test   %eax,%eax
f0103148:	75 24                	jne    f010316e <mem_init+0x1c73>
f010314a:	c7 44 24 0c 0d 75 10 	movl   $0xf010750d,0xc(%esp)
f0103151:	f0 
f0103152:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0103159:	f0 
f010315a:	c7 44 24 04 43 04 00 	movl   $0x443,0x4(%esp)
f0103161:	00 
f0103162:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0103169:	e8 d2 ce ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010316e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103175:	e8 b6 df ff ff       	call   f0101130 <page_alloc>
f010317a:	89 c7                	mov    %eax,%edi
f010317c:	85 c0                	test   %eax,%eax
f010317e:	75 24                	jne    f01031a4 <mem_init+0x1ca9>
f0103180:	c7 44 24 0c 23 75 10 	movl   $0xf0107523,0xc(%esp)
f0103187:	f0 
f0103188:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010318f:	f0 
f0103190:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f0103197:	00 
f0103198:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010319f:	e8 9c ce ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01031a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031ab:	e8 80 df ff ff       	call   f0101130 <page_alloc>
f01031b0:	89 c6                	mov    %eax,%esi
f01031b2:	85 c0                	test   %eax,%eax
f01031b4:	75 24                	jne    f01031da <mem_init+0x1cdf>
f01031b6:	c7 44 24 0c 39 75 10 	movl   $0xf0107539,0xc(%esp)
f01031bd:	f0 
f01031be:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01031c5:	f0 
f01031c6:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f01031cd:	00 
f01031ce:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01031d5:	e8 66 ce ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f01031da:	89 1c 24             	mov    %ebx,(%esp)
f01031dd:	e8 d9 df ff ff       	call   f01011bb <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f01031e2:	89 f8                	mov    %edi,%eax
f01031e4:	e8 a9 d9 ff ff       	call   f0100b92 <page2kva>
f01031e9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031f0:	00 
f01031f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01031f8:	00 
f01031f9:	89 04 24             	mov    %eax,(%esp)
f01031fc:	e8 b8 2e 00 00       	call   f01060b9 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103201:	89 f0                	mov    %esi,%eax
f0103203:	e8 8a d9 ff ff       	call   f0100b92 <page2kva>
f0103208:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010320f:	00 
f0103210:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103217:	00 
f0103218:	89 04 24             	mov    %eax,(%esp)
f010321b:	e8 99 2e 00 00       	call   f01060b9 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103220:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103227:	00 
f0103228:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010322f:	00 
f0103230:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103234:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f0103239:	89 04 24             	mov    %eax,(%esp)
f010323c:	e8 ca e1 ff ff       	call   f010140b <page_insert>
	assert(pp1->pp_ref == 1);
f0103241:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103246:	74 24                	je     f010326c <mem_init+0x1d71>
f0103248:	c7 44 24 0c 0a 76 10 	movl   $0xf010760a,0xc(%esp)
f010324f:	f0 
f0103250:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0103257:	f0 
f0103258:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f010325f:	00 
f0103260:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0103267:	e8 d4 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010326c:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103273:	01 01 01 
f0103276:	74 24                	je     f010329c <mem_init+0x1da1>
f0103278:	c7 44 24 0c 24 7f 10 	movl   $0xf0107f24,0xc(%esp)
f010327f:	f0 
f0103280:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0103287:	f0 
f0103288:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f010328f:	00 
f0103290:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0103297:	e8 a4 cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010329c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01032a3:	00 
f01032a4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032ab:	00 
f01032ac:	89 74 24 04          	mov    %esi,0x4(%esp)
f01032b0:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f01032b5:	89 04 24             	mov    %eax,(%esp)
f01032b8:	e8 4e e1 ff ff       	call   f010140b <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01032bd:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01032c4:	02 02 02 
f01032c7:	74 24                	je     f01032ed <mem_init+0x1df2>
f01032c9:	c7 44 24 0c 48 7f 10 	movl   $0xf0107f48,0xc(%esp)
f01032d0:	f0 
f01032d1:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01032d8:	f0 
f01032d9:	c7 44 24 04 4d 04 00 	movl   $0x44d,0x4(%esp)
f01032e0:	00 
f01032e1:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01032e8:	e8 53 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01032ed:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01032f2:	74 24                	je     f0103318 <mem_init+0x1e1d>
f01032f4:	c7 44 24 0c 2c 76 10 	movl   $0xf010762c,0xc(%esp)
f01032fb:	f0 
f01032fc:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0103303:	f0 
f0103304:	c7 44 24 04 4e 04 00 	movl   $0x44e,0x4(%esp)
f010330b:	00 
f010330c:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f0103313:	e8 28 cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103318:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010331d:	74 24                	je     f0103343 <mem_init+0x1e48>
f010331f:	c7 44 24 0c 75 76 10 	movl   $0xf0107675,0xc(%esp)
f0103326:	f0 
f0103327:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010332e:	f0 
f010332f:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0103336:	00 
f0103337:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010333e:	e8 fd cc ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103343:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010334a:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010334d:	89 f0                	mov    %esi,%eax
f010334f:	e8 3e d8 ff ff       	call   f0100b92 <page2kva>
f0103354:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f010335a:	74 24                	je     f0103380 <mem_init+0x1e85>
f010335c:	c7 44 24 0c 6c 7f 10 	movl   $0xf0107f6c,0xc(%esp)
f0103363:	f0 
f0103364:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010336b:	f0 
f010336c:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f0103373:	00 
f0103374:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010337b:	e8 c0 cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103380:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103387:	00 
f0103388:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f010338d:	89 04 24             	mov    %eax,(%esp)
f0103390:	e8 26 e0 ff ff       	call   f01013bb <page_remove>
	assert(pp2->pp_ref == 0);
f0103395:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010339a:	74 24                	je     f01033c0 <mem_init+0x1ec5>
f010339c:	c7 44 24 0c 64 76 10 	movl   $0xf0107664,0xc(%esp)
f01033a3:	f0 
f01033a4:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01033ab:	f0 
f01033ac:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f01033b3:	00 
f01033b4:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01033bb:	e8 80 cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01033c0:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f01033c5:	8b 08                	mov    (%eax),%ecx
f01033c7:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	return (pp - pages) << PGSHIFT;
f01033cd:	89 da                	mov    %ebx,%edx
f01033cf:	2b 15 90 6e 22 f0    	sub    0xf0226e90,%edx
f01033d5:	c1 fa 03             	sar    $0x3,%edx
f01033d8:	c1 e2 0c             	shl    $0xc,%edx
f01033db:	39 d1                	cmp    %edx,%ecx
f01033dd:	74 24                	je     f0103403 <mem_init+0x1f08>
f01033df:	c7 44 24 0c 2c 79 10 	movl   $0xf010792c,0xc(%esp)
f01033e6:	f0 
f01033e7:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f01033ee:	f0 
f01033ef:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f01033f6:	00 
f01033f7:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f01033fe:	e8 3d cc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103403:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103409:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010340e:	74 24                	je     f0103434 <mem_init+0x1f39>
f0103410:	c7 44 24 0c 1b 76 10 	movl   $0xf010761b,0xc(%esp)
f0103417:	f0 
f0103418:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f010341f:	f0 
f0103420:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f0103427:	00 
f0103428:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010342f:	e8 0c cc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103434:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010343a:	89 1c 24             	mov    %ebx,(%esp)
f010343d:	e8 79 dd ff ff       	call   f01011bb <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103442:	c7 04 24 98 7f 10 f0 	movl   $0xf0107f98,(%esp)
f0103449:	e8 7b 0b 00 00       	call   f0103fc9 <cprintf>
f010344e:	eb 69                	jmp    f01034b9 <mem_init+0x1fbe>
		boot_map_region(kern_pgdir, start, KSTKSIZE, PADDR(percpu_kstacks + i), PTE_W);
f0103450:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103457:	00 
f0103458:	c7 04 24 00 80 22 00 	movl   $0x228000,(%esp)
f010345f:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103464:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0103469:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
f010346e:	e8 2c de ff ff       	call   f010129f <boot_map_region>
f0103473:	bb 00 00 23 f0       	mov    $0xf0230000,%ebx
f0103478:	bf 00 80 26 f0       	mov    $0xf0268000,%edi
f010347d:	be 00 80 fe ef       	mov    $0xeffe8000,%esi
f0103482:	e9 9b f8 ff ff       	jmp    f0102d22 <mem_init+0x1827>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103487:	89 da                	mov    %ebx,%edx
f0103489:	89 f8                	mov    %edi,%eax
f010348b:	e8 47 d7 ff ff       	call   f0100bd7 <check_va2pa>
f0103490:	e9 da fa ff ff       	jmp    f0102f6f <mem_init+0x1a74>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103495:	89 da                	mov    %ebx,%edx
f0103497:	89 f8                	mov    %edi,%eax
f0103499:	e8 39 d7 ff ff       	call   f0100bd7 <check_va2pa>
f010349e:	66 90                	xchg   %ax,%ax
f01034a0:	e9 d3 f9 ff ff       	jmp    f0102e78 <mem_init+0x197d>
f01034a5:	81 ea 00 f0 ff 10    	sub    $0x10fff000,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01034ab:	89 f8                	mov    %edi,%eax
f01034ad:	e8 25 d7 ff ff       	call   f0100bd7 <check_va2pa>
	for (i = 0; i < n; i += PGSIZE)
f01034b2:	89 da                	mov    %ebx,%edx
f01034b4:	e9 60 f9 ff ff       	jmp    f0102e19 <mem_init+0x191e>
}
f01034b9:	83 c4 4c             	add    $0x4c,%esp
f01034bc:	5b                   	pop    %ebx
f01034bd:	5e                   	pop    %esi
f01034be:	5f                   	pop    %edi
f01034bf:	5d                   	pop    %ebp
f01034c0:	c3                   	ret    

f01034c1 <user_mem_check>:
{
f01034c1:	55                   	push   %ebp
f01034c2:	89 e5                	mov    %esp,%ebp
f01034c4:	57                   	push   %edi
f01034c5:	56                   	push   %esi
f01034c6:	53                   	push   %ebx
f01034c7:	83 ec 1c             	sub    $0x1c,%esp
	unsigned cur_va = ROUNDDOWN((unsigned)va, PGSIZE);
f01034ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01034cd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    unsigned end_va = ROUNDUP((unsigned)va + len, PGSIZE);
f01034d3:	8b 45 10             	mov    0x10(%ebp),%eax
f01034d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01034d9:	8d bc 07 ff 0f 00 00 	lea    0xfff(%edi,%eax,1),%edi
f01034e0:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	perm |= PTE_P;
f01034e6:	8b 75 14             	mov    0x14(%ebp),%esi
f01034e9:	83 ce 01             	or     $0x1,%esi
    while(cur_va < end_va){
f01034ec:	39 fb                	cmp    %edi,%ebx
f01034ee:	0f 83 93 00 00 00    	jae    f0103587 <user_mem_check+0xc6>
        pde_t *pgdir = curenv->env_pgdir;
f01034f4:	e8 5a 32 00 00       	call   f0106753 <cpunum>
f01034f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01034fc:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
        pde_t pgdir_entry = pgdir[PDX(cur_va)];
f0103502:	89 da                	mov    %ebx,%edx
f0103504:	c1 ea 16             	shr    $0x16,%edx
f0103507:	8b 40 60             	mov    0x60(%eax),%eax
f010350a:	8b 04 90             	mov    (%eax,%edx,4),%eax
        if(cur_va > ULIM || (pgdir_entry & perm) != perm)
f010350d:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0103513:	77 5e                	ja     f0103573 <user_mem_check+0xb2>
f0103515:	89 c2                	mov    %eax,%edx
f0103517:	21 f2                	and    %esi,%edx
f0103519:	39 d6                	cmp    %edx,%esi
f010351b:	75 56                	jne    f0103573 <user_mem_check+0xb2>
        pte_t *pg_address = KADDR(PTE_ADDR(pgdir_entry));
f010351d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0103522:	89 c2                	mov    %eax,%edx
f0103524:	c1 ea 0c             	shr    $0xc,%edx
f0103527:	3b 15 88 6e 22 f0    	cmp    0xf0226e88,%edx
f010352d:	72 20                	jb     f010354f <user_mem_check+0x8e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010352f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103533:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f010353a:	f0 
f010353b:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
f0103542:	00 
f0103543:	c7 04 24 1f 74 10 f0 	movl   $0xf010741f,(%esp)
f010354a:	e8 f1 ca ff ff       	call   f0100040 <_panic>
        pte_t pg_entry = pg_address[PTX(cur_va)];
f010354f:	89 da                	mov    %ebx,%edx
f0103551:	c1 ea 0c             	shr    $0xc,%edx
f0103554:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
        if(cur_va > ULIM || (pg_entry & perm) != perm)
f010355a:	89 f1                	mov    %esi,%ecx
f010355c:	23 8c 90 00 00 00 f0 	and    -0x10000000(%eax,%edx,4),%ecx
f0103563:	39 ce                	cmp    %ecx,%esi
f0103565:	75 0c                	jne    f0103573 <user_mem_check+0xb2>
        cur_va += PGSIZE;
f0103567:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    while(cur_va < end_va){
f010356d:	39 df                	cmp    %ebx,%edi
f010356f:	77 83                	ja     f01034f4 <user_mem_check+0x33>
f0103571:	eb 1b                	jmp    f010358e <user_mem_check+0xcd>
	user_mem_check_addr = (cur_va > (unsigned)va ? cur_va : (unsigned)va);
f0103573:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103576:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f010357a:	89 1d 3c 62 22 f0    	mov    %ebx,0xf022623c
	return -E_FAULT;
f0103580:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103585:	eb 0c                	jmp    f0103593 <user_mem_check+0xd2>
    return 0;
f0103587:	b8 00 00 00 00       	mov    $0x0,%eax
f010358c:	eb 05                	jmp    f0103593 <user_mem_check+0xd2>
f010358e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103593:	83 c4 1c             	add    $0x1c,%esp
f0103596:	5b                   	pop    %ebx
f0103597:	5e                   	pop    %esi
f0103598:	5f                   	pop    %edi
f0103599:	5d                   	pop    %ebp
f010359a:	c3                   	ret    

f010359b <user_mem_assert>:
{
f010359b:	55                   	push   %ebp
f010359c:	89 e5                	mov    %esp,%ebp
f010359e:	53                   	push   %ebx
f010359f:	83 ec 14             	sub    $0x14,%esp
f01035a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01035a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01035a8:	83 c8 04             	or     $0x4,%eax
f01035ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035af:	8b 45 10             	mov    0x10(%ebp),%eax
f01035b2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035b6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035bd:	89 1c 24             	mov    %ebx,(%esp)
f01035c0:	e8 fc fe ff ff       	call   f01034c1 <user_mem_check>
f01035c5:	85 c0                	test   %eax,%eax
f01035c7:	79 24                	jns    f01035ed <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f01035c9:	a1 3c 62 22 f0       	mov    0xf022623c,%eax
f01035ce:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035d2:	8b 43 48             	mov    0x48(%ebx),%eax
f01035d5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035d9:	c7 04 24 c4 7f 10 f0 	movl   $0xf0107fc4,(%esp)
f01035e0:	e8 e4 09 00 00       	call   f0103fc9 <cprintf>
		env_destroy(env);	// may not return
f01035e5:	89 1c 24             	mov    %ebx,(%esp)
f01035e8:	e8 e4 06 00 00       	call   f0103cd1 <env_destroy>
}
f01035ed:	83 c4 14             	add    $0x14,%esp
f01035f0:	5b                   	pop    %ebx
f01035f1:	5d                   	pop    %ebp
f01035f2:	c3                   	ret    

f01035f3 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01035f3:	55                   	push   %ebp
f01035f4:	89 e5                	mov    %esp,%ebp
f01035f6:	57                   	push   %edi
f01035f7:	56                   	push   %esi
f01035f8:	53                   	push   %ebx
f01035f9:	83 ec 1c             	sub    $0x1c,%esp
f01035fc:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	unsigned start = ROUNDDOWN((unsigned)va, PGSIZE);
f01035fe:	89 d3                	mov    %edx,%ebx
f0103600:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	unsigned end = ROUNDUP((unsigned)va + len, PGSIZE);
f0103606:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f010360d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for(; start < end; start += PGSIZE){
f0103613:	39 f3                	cmp    %esi,%ebx
f0103615:	73 71                	jae    f0103688 <region_alloc+0x95>
		struct PageInfo *page = page_alloc(0); //不需要ALLOC_ZERO
f0103617:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010361e:	e8 0d db ff ff       	call   f0101130 <page_alloc>
		if(!page)
f0103623:	85 c0                	test   %eax,%eax
f0103625:	75 1c                	jne    f0103643 <region_alloc+0x50>
			panic("region_alloc: page_alloc error");
f0103627:	c7 44 24 08 fc 7f 10 	movl   $0xf0107ffc,0x8(%esp)
f010362e:	f0 
f010362f:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
f0103636:	00 
f0103637:	c7 04 24 93 80 10 f0 	movl   $0xf0108093,(%esp)
f010363e:	e8 fd c9 ff ff       	call   f0100040 <_panic>
		int result = page_insert(e->env_pgdir, page, (void *)start, PTE_U | PTE_W);
f0103643:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010364a:	00 
f010364b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010364f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103653:	8b 47 60             	mov    0x60(%edi),%eax
f0103656:	89 04 24             	mov    %eax,(%esp)
f0103659:	e8 ad dd ff ff       	call   f010140b <page_insert>
		if(result < 0)
f010365e:	85 c0                	test   %eax,%eax
f0103660:	79 1c                	jns    f010367e <region_alloc+0x8b>
			panic("region_alloc: page_insert error");
f0103662:	c7 44 24 08 1c 80 10 	movl   $0xf010801c,0x8(%esp)
f0103669:	f0 
f010366a:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
f0103671:	00 
f0103672:	c7 04 24 93 80 10 f0 	movl   $0xf0108093,(%esp)
f0103679:	e8 c2 c9 ff ff       	call   f0100040 <_panic>
	for(; start < end; start += PGSIZE){
f010367e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103684:	39 de                	cmp    %ebx,%esi
f0103686:	77 8f                	ja     f0103617 <region_alloc+0x24>
	}
}
f0103688:	83 c4 1c             	add    $0x1c,%esp
f010368b:	5b                   	pop    %ebx
f010368c:	5e                   	pop    %esi
f010368d:	5f                   	pop    %edi
f010368e:	5d                   	pop    %ebp
f010368f:	c3                   	ret    

f0103690 <envid2env>:
{
f0103690:	55                   	push   %ebp
f0103691:	89 e5                	mov    %esp,%ebp
f0103693:	56                   	push   %esi
f0103694:	53                   	push   %ebx
f0103695:	8b 45 08             	mov    0x8(%ebp),%eax
f0103698:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f010369b:	85 c0                	test   %eax,%eax
f010369d:	75 1a                	jne    f01036b9 <envid2env+0x29>
		*env_store = curenv;
f010369f:	e8 af 30 00 00       	call   f0106753 <cpunum>
f01036a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a7:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f01036ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01036b0:	89 01                	mov    %eax,(%ecx)
		return 0;
f01036b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01036b7:	eb 70                	jmp    f0103729 <envid2env+0x99>
	e = &envs[ENVX(envid)];
f01036b9:	89 c3                	mov    %eax,%ebx
f01036bb:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01036c1:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01036c4:	03 1d 48 62 22 f0    	add    0xf0226248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01036ca:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01036ce:	74 05                	je     f01036d5 <envid2env+0x45>
f01036d0:	39 43 48             	cmp    %eax,0x48(%ebx)
f01036d3:	74 10                	je     f01036e5 <envid2env+0x55>
		*env_store = 0;
f01036d5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036d8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01036de:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036e3:	eb 44                	jmp    f0103729 <envid2env+0x99>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01036e5:	84 d2                	test   %dl,%dl
f01036e7:	74 36                	je     f010371f <envid2env+0x8f>
f01036e9:	e8 65 30 00 00       	call   f0106753 <cpunum>
f01036ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01036f1:	39 98 28 70 22 f0    	cmp    %ebx,-0xfdd8fd8(%eax)
f01036f7:	74 26                	je     f010371f <envid2env+0x8f>
f01036f9:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01036fc:	e8 52 30 00 00       	call   f0106753 <cpunum>
f0103701:	6b c0 74             	imul   $0x74,%eax,%eax
f0103704:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f010370a:	3b 70 48             	cmp    0x48(%eax),%esi
f010370d:	74 10                	je     f010371f <envid2env+0x8f>
		*env_store = 0;
f010370f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103712:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103718:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010371d:	eb 0a                	jmp    f0103729 <envid2env+0x99>
	*env_store = e;
f010371f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103722:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103724:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103729:	5b                   	pop    %ebx
f010372a:	5e                   	pop    %esi
f010372b:	5d                   	pop    %ebp
f010372c:	c3                   	ret    

f010372d <env_init_percpu>:
{
f010372d:	55                   	push   %ebp
f010372e:	89 e5                	mov    %esp,%ebp
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103730:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f0103735:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103738:	b8 23 00 00 00       	mov    $0x23,%eax
f010373d:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010373f:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103741:	b0 10                	mov    $0x10,%al
f0103743:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103745:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103747:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103749:	ea 50 37 10 f0 08 00 	ljmp   $0x8,$0xf0103750
	__asm __volatile("lldt %0" : : "r" (sel));
f0103750:	b0 00                	mov    $0x0,%al
f0103752:	0f 00 d0             	lldt   %ax
}
f0103755:	5d                   	pop    %ebp
f0103756:	c3                   	ret    

f0103757 <env_init>:
{
f0103757:	55                   	push   %ebp
f0103758:	89 e5                	mov    %esp,%ebp
f010375a:	56                   	push   %esi
f010375b:	53                   	push   %ebx
		envs[i].env_status = ENV_FREE;
f010375c:	8b 35 48 62 22 f0    	mov    0xf0226248,%esi
f0103762:	8b 0d 4c 62 22 f0    	mov    0xf022624c,%ecx
f0103768:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f010376e:	ba 00 04 00 00       	mov    $0x400,%edx
f0103773:	89 c3                	mov    %eax,%ebx
f0103775:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f010377c:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103783:	89 48 44             	mov    %ecx,0x44(%eax)
f0103786:	83 e8 7c             	sub    $0x7c,%eax
	for(i = NENV - 1; i >= 0; --i){
f0103789:	83 ea 01             	sub    $0x1,%edx
f010378c:	74 04                	je     f0103792 <env_init+0x3b>
		env_free_list = &envs[i];
f010378e:	89 d9                	mov    %ebx,%ecx
f0103790:	eb e1                	jmp    f0103773 <env_init+0x1c>
f0103792:	89 35 4c 62 22 f0    	mov    %esi,0xf022624c
	env_init_percpu();
f0103798:	e8 90 ff ff ff       	call   f010372d <env_init_percpu>
}
f010379d:	5b                   	pop    %ebx
f010379e:	5e                   	pop    %esi
f010379f:	5d                   	pop    %ebp
f01037a0:	c3                   	ret    

f01037a1 <env_alloc>:
{
f01037a1:	55                   	push   %ebp
f01037a2:	89 e5                	mov    %esp,%ebp
f01037a4:	53                   	push   %ebx
f01037a5:	83 ec 14             	sub    $0x14,%esp
	if (!(e = env_free_list))
f01037a8:	8b 1d 4c 62 22 f0    	mov    0xf022624c,%ebx
f01037ae:	85 db                	test   %ebx,%ebx
f01037b0:	0f 84 96 01 00 00    	je     f010394c <env_alloc+0x1ab>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01037b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01037bd:	e8 6e d9 ff ff       	call   f0101130 <page_alloc>
f01037c2:	85 c0                	test   %eax,%eax
f01037c4:	0f 84 89 01 00 00    	je     f0103953 <env_alloc+0x1b2>
	return (pp - pages) << PGSHIFT;
f01037ca:	89 c2                	mov    %eax,%edx
f01037cc:	2b 15 90 6e 22 f0    	sub    0xf0226e90,%edx
f01037d2:	c1 fa 03             	sar    $0x3,%edx
f01037d5:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01037d8:	89 d1                	mov    %edx,%ecx
f01037da:	c1 e9 0c             	shr    $0xc,%ecx
f01037dd:	3b 0d 88 6e 22 f0    	cmp    0xf0226e88,%ecx
f01037e3:	72 20                	jb     f0103805 <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01037e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01037e9:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f01037f0:	f0 
f01037f1:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01037f8:	00 
f01037f9:	c7 04 24 2b 74 10 f0 	movl   $0xf010742b,(%esp)
f0103800:	e8 3b c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103805:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010380b:	89 53 60             	mov    %edx,0x60(%ebx)
	p->pp_ref = 1;
f010380e:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
f0103814:	b8 ec 0e 00 00       	mov    $0xeec,%eax
		e->env_pgdir[i] = kern_pgdir[i];
f0103819:	8b 15 8c 6e 22 f0    	mov    0xf0226e8c,%edx
f010381f:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103822:	8b 53 60             	mov    0x60(%ebx),%edx
f0103825:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103828:	83 c0 04             	add    $0x4,%eax
	for(i = PDX(UTOP); i < NPDENTRIES; ++i)
f010382b:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103830:	75 e7                	jne    f0103819 <env_alloc+0x78>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103832:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103835:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010383a:	77 20                	ja     f010385c <env_alloc+0xbb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010383c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103840:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0103847:	f0 
f0103848:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f010384f:	00 
f0103850:	c7 04 24 93 80 10 f0 	movl   $0xf0108093,(%esp)
f0103857:	e8 e4 c7 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010385c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103862:	83 ca 05             	or     $0x5,%edx
f0103865:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010386b:	8b 43 48             	mov    0x48(%ebx),%eax
f010386e:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103873:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103878:	ba 00 10 00 00       	mov    $0x1000,%edx
f010387d:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103880:	89 da                	mov    %ebx,%edx
f0103882:	2b 15 48 62 22 f0    	sub    0xf0226248,%edx
f0103888:	c1 fa 02             	sar    $0x2,%edx
f010388b:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103891:	09 d0                	or     %edx,%eax
f0103893:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103896:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103899:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010389c:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01038a3:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01038aa:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01038b1:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01038b8:	00 
f01038b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01038c0:	00 
f01038c1:	89 1c 24             	mov    %ebx,(%esp)
f01038c4:	e8 f0 27 00 00       	call   f01060b9 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f01038c9:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01038cf:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01038d5:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01038db:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01038e2:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f01038e8:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f01038ef:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f01038f6:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f01038fa:	8b 43 44             	mov    0x44(%ebx),%eax
f01038fd:	a3 4c 62 22 f0       	mov    %eax,0xf022624c
	*newenv_store = e;
f0103902:	8b 45 08             	mov    0x8(%ebp),%eax
f0103905:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103907:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010390a:	e8 44 2e 00 00       	call   f0106753 <cpunum>
f010390f:	6b d0 74             	imul   $0x74,%eax,%edx
f0103912:	b8 00 00 00 00       	mov    $0x0,%eax
f0103917:	83 ba 28 70 22 f0 00 	cmpl   $0x0,-0xfdd8fd8(%edx)
f010391e:	74 11                	je     f0103931 <env_alloc+0x190>
f0103920:	e8 2e 2e 00 00       	call   f0106753 <cpunum>
f0103925:	6b c0 74             	imul   $0x74,%eax,%eax
f0103928:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f010392e:	8b 40 48             	mov    0x48(%eax),%eax
f0103931:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103935:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103939:	c7 04 24 9e 80 10 f0 	movl   $0xf010809e,(%esp)
f0103940:	e8 84 06 00 00       	call   f0103fc9 <cprintf>
	return 0;
f0103945:	b8 00 00 00 00       	mov    $0x0,%eax
f010394a:	eb 0c                	jmp    f0103958 <env_alloc+0x1b7>
		return -E_NO_FREE_ENV;
f010394c:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103951:	eb 05                	jmp    f0103958 <env_alloc+0x1b7>
		return -E_NO_MEM;
f0103953:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f0103958:	83 c4 14             	add    $0x14,%esp
f010395b:	5b                   	pop    %ebx
f010395c:	5d                   	pop    %ebp
f010395d:	c3                   	ret    

f010395e <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f010395e:	55                   	push   %ebp
f010395f:	89 e5                	mov    %esp,%ebp
f0103961:	57                   	push   %edi
f0103962:	56                   	push   %esi
f0103963:	53                   	push   %ebx
f0103964:	83 ec 3c             	sub    $0x3c,%esp
f0103967:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *env;
	int result = env_alloc(&env, 0);
f010396a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103971:	00 
f0103972:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103975:	89 04 24             	mov    %eax,(%esp)
f0103978:	e8 24 fe ff ff       	call   f01037a1 <env_alloc>
	if(result < 0)
f010397d:	85 c0                	test   %eax,%eax
f010397f:	79 1c                	jns    f010399d <env_create+0x3f>
		panic("env_create: env_alloc error");
f0103981:	c7 44 24 08 b3 80 10 	movl   $0xf01080b3,0x8(%esp)
f0103988:	f0 
f0103989:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
f0103990:	00 
f0103991:	c7 04 24 93 80 10 f0 	movl   $0xf0108093,(%esp)
f0103998:	e8 a3 c6 ff ff       	call   f0100040 <_panic>
	load_icode(env, binary, size);
f010399d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if(ELF_MAGIC != elf->e_magic)
f01039a3:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01039a9:	74 1c                	je     f01039c7 <env_create+0x69>
		panic("load icode: e_magic is not equal to ELF_MAGIC");
f01039ab:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f01039b2:	f0 
f01039b3:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
f01039ba:	00 
f01039bb:	c7 04 24 93 80 10 f0 	movl   $0xf0108093,(%esp)
f01039c2:	e8 79 c6 ff ff       	call   f0100040 <_panic>
	if(!elf->e_entry)
f01039c7:	8b 47 18             	mov    0x18(%edi),%eax
f01039ca:	85 c0                	test   %eax,%eax
f01039cc:	75 1c                	jne    f01039ea <env_create+0x8c>
		panic("load icode: e_entry is NULL");
f01039ce:	c7 44 24 08 cf 80 10 	movl   $0xf01080cf,0x8(%esp)
f01039d5:	f0 
f01039d6:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
f01039dd:	00 
f01039de:	c7 04 24 93 80 10 f0 	movl   $0xf0108093,(%esp)
f01039e5:	e8 56 c6 ff ff       	call   f0100040 <_panic>
	e->env_tf.tf_eip = elf->e_entry;
f01039ea:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01039ed:	89 41 30             	mov    %eax,0x30(%ecx)
	struct Proghdr *ph = (struct Proghdr *)(binary + elf->e_phoff);
f01039f0:	89 fb                	mov    %edi,%ebx
f01039f2:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr *eph = ph + elf->e_phnum;
f01039f5:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01039f9:	c1 e6 05             	shl    $0x5,%esi
f01039fc:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));
f01039fe:	8b 41 60             	mov    0x60(%ecx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103a01:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a06:	77 20                	ja     f0103a28 <env_create+0xca>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a08:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a0c:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0103a13:	f0 
f0103a14:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
f0103a1b:	00 
f0103a1c:	c7 04 24 93 80 10 f0 	movl   $0xf0108093,(%esp)
f0103a23:	e8 18 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a28:	05 00 00 00 10       	add    $0x10000000,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103a2d:	0f 22 d8             	mov    %eax,%cr3
	for(; ph < eph; ++ph)
f0103a30:	39 f3                	cmp    %esi,%ebx
f0103a32:	73 75                	jae    f0103aa9 <env_create+0x14b>
		if(ELF_PROG_LOAD == ph->p_type){
f0103a34:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103a37:	75 69                	jne    f0103aa2 <env_create+0x144>
			if(ph->p_filesz > ph->p_memsz)
f0103a39:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103a3c:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103a3f:	76 1c                	jbe    f0103a5d <env_create+0xff>
				panic("load icode: ph->p_filesz > ph->p_memsz");
f0103a41:	c7 44 24 08 6c 80 10 	movl   $0xf010806c,0x8(%esp)
f0103a48:	f0 
f0103a49:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f0103a50:	00 
f0103a51:	c7 04 24 93 80 10 f0 	movl   $0xf0108093,(%esp)
f0103a58:	e8 e3 c5 ff ff       	call   f0100040 <_panic>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103a5d:	8b 53 08             	mov    0x8(%ebx),%edx
f0103a60:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a63:	e8 8b fb ff ff       	call   f01035f3 <region_alloc>
			memmove((char *)ph->p_va, (void *)(binary + ph->p_offset), ph->p_filesz);
f0103a68:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a6b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a6f:	89 f8                	mov    %edi,%eax
f0103a71:	03 43 04             	add    0x4(%ebx),%eax
f0103a74:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a78:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a7b:	89 04 24             	mov    %eax,(%esp)
f0103a7e:	e8 83 26 00 00       	call   f0106106 <memmove>
			memset((char *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f0103a83:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a86:	8b 53 14             	mov    0x14(%ebx),%edx
f0103a89:	29 c2                	sub    %eax,%edx
f0103a8b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103a8f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a96:	00 
f0103a97:	03 43 08             	add    0x8(%ebx),%eax
f0103a9a:	89 04 24             	mov    %eax,(%esp)
f0103a9d:	e8 17 26 00 00       	call   f01060b9 <memset>
	for(; ph < eph; ++ph)
f0103aa2:	83 c3 20             	add    $0x20,%ebx
f0103aa5:	39 de                	cmp    %ebx,%esi
f0103aa7:	77 8b                	ja     f0103a34 <env_create+0xd6>
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103aa9:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103aae:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103ab3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103ab6:	e8 38 fb ff ff       	call   f01035f3 <region_alloc>
	env->env_type = type;
f0103abb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103abe:	8b 55 10             	mov    0x10(%ebp),%edx
f0103ac1:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103ac4:	83 c4 3c             	add    $0x3c,%esp
f0103ac7:	5b                   	pop    %ebx
f0103ac8:	5e                   	pop    %esi
f0103ac9:	5f                   	pop    %edi
f0103aca:	5d                   	pop    %ebp
f0103acb:	c3                   	ret    

f0103acc <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103acc:	55                   	push   %ebp
f0103acd:	89 e5                	mov    %esp,%ebp
f0103acf:	57                   	push   %edi
f0103ad0:	56                   	push   %esi
f0103ad1:	53                   	push   %ebx
f0103ad2:	83 ec 2c             	sub    $0x2c,%esp
f0103ad5:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103ad8:	e8 76 2c 00 00       	call   f0106753 <cpunum>
f0103add:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ae0:	39 b8 28 70 22 f0    	cmp    %edi,-0xfdd8fd8(%eax)
f0103ae6:	75 34                	jne    f0103b1c <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0103ae8:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103aed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103af2:	77 20                	ja     f0103b14 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103af4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103af8:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0103aff:	f0 
f0103b00:	c7 44 24 04 ab 01 00 	movl   $0x1ab,0x4(%esp)
f0103b07:	00 
f0103b08:	c7 04 24 93 80 10 f0 	movl   $0xf0108093,(%esp)
f0103b0f:	e8 2c c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103b14:	05 00 00 00 10       	add    $0x10000000,%eax
f0103b19:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103b1c:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103b1f:	e8 2f 2c 00 00       	call   f0106753 <cpunum>
f0103b24:	6b d0 74             	imul   $0x74,%eax,%edx
f0103b27:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b2c:	83 ba 28 70 22 f0 00 	cmpl   $0x0,-0xfdd8fd8(%edx)
f0103b33:	74 11                	je     f0103b46 <env_free+0x7a>
f0103b35:	e8 19 2c 00 00       	call   f0106753 <cpunum>
f0103b3a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b3d:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0103b43:	8b 40 48             	mov    0x48(%eax),%eax
f0103b46:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103b4a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b4e:	c7 04 24 eb 80 10 f0 	movl   $0xf01080eb,(%esp)
f0103b55:	e8 6f 04 00 00       	call   f0103fc9 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103b5a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103b61:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103b64:	89 c8                	mov    %ecx,%eax
f0103b66:	c1 e0 02             	shl    $0x2,%eax
f0103b69:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b6c:	8b 47 60             	mov    0x60(%edi),%eax
f0103b6f:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103b72:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103b78:	0f 84 b7 00 00 00    	je     f0103c35 <env_free+0x169>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b7e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0103b84:	89 f0                	mov    %esi,%eax
f0103b86:	c1 e8 0c             	shr    $0xc,%eax
f0103b89:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b8c:	3b 05 88 6e 22 f0    	cmp    0xf0226e88,%eax
f0103b92:	72 20                	jb     f0103bb4 <env_free+0xe8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b94:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b98:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0103b9f:	f0 
f0103ba0:	c7 44 24 04 ba 01 00 	movl   $0x1ba,0x4(%esp)
f0103ba7:	00 
f0103ba8:	c7 04 24 93 80 10 f0 	movl   $0xf0108093,(%esp)
f0103baf:	e8 8c c4 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103bb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103bb7:	c1 e0 16             	shl    $0x16,%eax
f0103bba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103bbd:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103bc2:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103bc9:	01 
f0103bca:	74 17                	je     f0103be3 <env_free+0x117>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103bcc:	89 d8                	mov    %ebx,%eax
f0103bce:	c1 e0 0c             	shl    $0xc,%eax
f0103bd1:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103bd4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bd8:	8b 47 60             	mov    0x60(%edi),%eax
f0103bdb:	89 04 24             	mov    %eax,(%esp)
f0103bde:	e8 d8 d7 ff ff       	call   f01013bb <page_remove>
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103be3:	83 c3 01             	add    $0x1,%ebx
f0103be6:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103bec:	75 d4                	jne    f0103bc2 <env_free+0xf6>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103bee:	8b 47 60             	mov    0x60(%edi),%eax
f0103bf1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103bf4:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103bfb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103bfe:	3b 05 88 6e 22 f0    	cmp    0xf0226e88,%eax
f0103c04:	72 1c                	jb     f0103c22 <env_free+0x156>
		panic("pa2page called with invalid pa");
f0103c06:	c7 44 24 08 d4 77 10 	movl   $0xf01077d4,0x8(%esp)
f0103c0d:	f0 
f0103c0e:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c15:	00 
f0103c16:	c7 04 24 2b 74 10 f0 	movl   $0xf010742b,(%esp)
f0103c1d:	e8 1e c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c22:	a1 90 6e 22 f0       	mov    0xf0226e90,%eax
f0103c27:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103c2a:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103c2d:	89 04 24             	mov    %eax,(%esp)
f0103c30:	e8 a6 d5 ff ff       	call   f01011db <page_decref>
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103c35:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103c39:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103c40:	0f 85 1b ff ff ff    	jne    f0103b61 <env_free+0x95>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103c46:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103c49:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c4e:	77 20                	ja     f0103c70 <env_free+0x1a4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c50:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c54:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0103c5b:	f0 
f0103c5c:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
f0103c63:	00 
f0103c64:	c7 04 24 93 80 10 f0 	movl   $0xf0108093,(%esp)
f0103c6b:	e8 d0 c3 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103c70:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103c77:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103c7c:	c1 e8 0c             	shr    $0xc,%eax
f0103c7f:	3b 05 88 6e 22 f0    	cmp    0xf0226e88,%eax
f0103c85:	72 1c                	jb     f0103ca3 <env_free+0x1d7>
		panic("pa2page called with invalid pa");
f0103c87:	c7 44 24 08 d4 77 10 	movl   $0xf01077d4,0x8(%esp)
f0103c8e:	f0 
f0103c8f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c96:	00 
f0103c97:	c7 04 24 2b 74 10 f0 	movl   $0xf010742b,(%esp)
f0103c9e:	e8 9d c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103ca3:	8b 15 90 6e 22 f0    	mov    0xf0226e90,%edx
f0103ca9:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103cac:	89 04 24             	mov    %eax,(%esp)
f0103caf:	e8 27 d5 ff ff       	call   f01011db <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103cb4:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103cbb:	a1 4c 62 22 f0       	mov    0xf022624c,%eax
f0103cc0:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103cc3:	89 3d 4c 62 22 f0    	mov    %edi,0xf022624c
}
f0103cc9:	83 c4 2c             	add    $0x2c,%esp
f0103ccc:	5b                   	pop    %ebx
f0103ccd:	5e                   	pop    %esi
f0103cce:	5f                   	pop    %edi
f0103ccf:	5d                   	pop    %ebp
f0103cd0:	c3                   	ret    

f0103cd1 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103cd1:	55                   	push   %ebp
f0103cd2:	89 e5                	mov    %esp,%ebp
f0103cd4:	53                   	push   %ebx
f0103cd5:	83 ec 14             	sub    $0x14,%esp
f0103cd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103cdb:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103cdf:	75 19                	jne    f0103cfa <env_destroy+0x29>
f0103ce1:	e8 6d 2a 00 00       	call   f0106753 <cpunum>
f0103ce6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ce9:	39 98 28 70 22 f0    	cmp    %ebx,-0xfdd8fd8(%eax)
f0103cef:	74 09                	je     f0103cfa <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103cf1:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103cf8:	eb 2f                	jmp    f0103d29 <env_destroy+0x58>
	}

	env_free(e);
f0103cfa:	89 1c 24             	mov    %ebx,(%esp)
f0103cfd:	e8 ca fd ff ff       	call   f0103acc <env_free>

	if (curenv == e) {
f0103d02:	e8 4c 2a 00 00       	call   f0106753 <cpunum>
f0103d07:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d0a:	39 98 28 70 22 f0    	cmp    %ebx,-0xfdd8fd8(%eax)
f0103d10:	75 17                	jne    f0103d29 <env_destroy+0x58>
		curenv = NULL;
f0103d12:	e8 3c 2a 00 00       	call   f0106753 <cpunum>
f0103d17:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d1a:	c7 80 28 70 22 f0 00 	movl   $0x0,-0xfdd8fd8(%eax)
f0103d21:	00 00 00 
		sched_yield();
f0103d24:	e8 82 0f 00 00       	call   f0104cab <sched_yield>
	}
}
f0103d29:	83 c4 14             	add    $0x14,%esp
f0103d2c:	5b                   	pop    %ebx
f0103d2d:	5d                   	pop    %ebp
f0103d2e:	c3                   	ret    

f0103d2f <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103d2f:	55                   	push   %ebp
f0103d30:	89 e5                	mov    %esp,%ebp
f0103d32:	53                   	push   %ebx
f0103d33:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103d36:	e8 18 2a 00 00       	call   f0106753 <cpunum>
f0103d3b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d3e:	8b 98 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%ebx
f0103d44:	e8 0a 2a 00 00       	call   f0106753 <cpunum>
f0103d49:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103d4c:	8b 65 08             	mov    0x8(%ebp),%esp
f0103d4f:	61                   	popa   
f0103d50:	07                   	pop    %es
f0103d51:	1f                   	pop    %ds
f0103d52:	83 c4 08             	add    $0x8,%esp
f0103d55:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103d56:	c7 44 24 08 01 81 10 	movl   $0xf0108101,0x8(%esp)
f0103d5d:	f0 
f0103d5e:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
f0103d65:	00 
f0103d66:	c7 04 24 93 80 10 f0 	movl   $0xf0108093,(%esp)
f0103d6d:	e8 ce c2 ff ff       	call   f0100040 <_panic>

f0103d72 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d72:	55                   	push   %ebp
f0103d73:	89 e5                	mov    %esp,%ebp
f0103d75:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// 修改原来的env状态
	if(curenv && ENV_RUNNING == curenv->env_status){
f0103d78:	e8 d6 29 00 00       	call   f0106753 <cpunum>
f0103d7d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d80:	83 b8 28 70 22 f0 00 	cmpl   $0x0,-0xfdd8fd8(%eax)
f0103d87:	74 3b                	je     f0103dc4 <env_run+0x52>
f0103d89:	e8 c5 29 00 00       	call   f0106753 <cpunum>
f0103d8e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d91:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0103d97:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d9b:	75 27                	jne    f0103dc4 <env_run+0x52>
		curenv->env_status = ENV_RUNNABLE;
f0103d9d:	e8 b1 29 00 00       	call   f0106753 <cpunum>
f0103da2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103da5:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0103dab:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv->env_runs--;
f0103db2:	e8 9c 29 00 00       	call   f0106753 <cpunum>
f0103db7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dba:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0103dc0:	83 68 58 01          	subl   $0x1,0x58(%eax)
	}
	// 修改curenv为当前env并且修改状态
	curenv = e;
f0103dc4:	e8 8a 29 00 00       	call   f0106753 <cpunum>
f0103dc9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dcc:	8b 55 08             	mov    0x8(%ebp),%edx
f0103dcf:	89 90 28 70 22 f0    	mov    %edx,-0xfdd8fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103dd5:	e8 79 29 00 00       	call   f0106753 <cpunum>
f0103dda:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ddd:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0103de3:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103dea:	e8 64 29 00 00       	call   f0106753 <cpunum>
f0103def:	6b c0 74             	imul   $0x74,%eax,%eax
f0103df2:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0103df8:	83 40 58 01          	addl   $0x1,0x58(%eax)
	// 切换地址空间，恢复寄存器
	lcr3(PADDR(curenv->env_pgdir));
f0103dfc:	e8 52 29 00 00       	call   f0106753 <cpunum>
f0103e01:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e04:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0103e0a:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103e0d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e12:	77 20                	ja     f0103e34 <env_run+0xc2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e14:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e18:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0103e1f:	f0 
f0103e20:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
f0103e27:	00 
f0103e28:	c7 04 24 93 80 10 f0 	movl   $0xf0108093,(%esp)
f0103e2f:	e8 0c c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103e34:	05 00 00 00 10       	add    $0x10000000,%eax
f0103e39:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103e3c:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0103e43:	e8 5f 2c 00 00       	call   f0106aa7 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103e48:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f0103e4a:	e8 04 29 00 00       	call   f0106753 <cpunum>
f0103e4f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e52:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0103e58:	89 04 24             	mov    %eax,(%esp)
f0103e5b:	e8 cf fe ff ff       	call   f0103d2f <env_pop_tf>

f0103e60 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e60:	55                   	push   %ebp
f0103e61:	89 e5                	mov    %esp,%ebp
f0103e63:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e67:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e6c:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e6d:	b2 71                	mov    $0x71,%dl
f0103e6f:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e70:	0f b6 c0             	movzbl %al,%eax
}
f0103e73:	5d                   	pop    %ebp
f0103e74:	c3                   	ret    

f0103e75 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e75:	55                   	push   %ebp
f0103e76:	89 e5                	mov    %esp,%ebp
f0103e78:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e7c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e81:	ee                   	out    %al,(%dx)
f0103e82:	b2 71                	mov    $0x71,%dl
f0103e84:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e87:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e88:	5d                   	pop    %ebp
f0103e89:	c3                   	ret    

f0103e8a <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e8a:	55                   	push   %ebp
f0103e8b:	89 e5                	mov    %esp,%ebp
f0103e8d:	56                   	push   %esi
f0103e8e:	53                   	push   %ebx
f0103e8f:	83 ec 10             	sub    $0x10,%esp
f0103e92:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103e95:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103e9b:	80 3d 50 62 22 f0 00 	cmpb   $0x0,0xf0226250
f0103ea2:	74 4e                	je     f0103ef2 <irq_setmask_8259A+0x68>
f0103ea4:	89 c6                	mov    %eax,%esi
f0103ea6:	ba 21 00 00 00       	mov    $0x21,%edx
f0103eab:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103eac:	66 c1 e8 08          	shr    $0x8,%ax
f0103eb0:	b2 a1                	mov    $0xa1,%dl
f0103eb2:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103eb3:	c7 04 24 0d 81 10 f0 	movl   $0xf010810d,(%esp)
f0103eba:	e8 0a 01 00 00       	call   f0103fc9 <cprintf>
	for (i = 0; i < 16; i++)
f0103ebf:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103ec4:	0f b7 f6             	movzwl %si,%esi
f0103ec7:	f7 d6                	not    %esi
f0103ec9:	0f a3 de             	bt     %ebx,%esi
f0103ecc:	73 10                	jae    f0103ede <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f0103ece:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103ed2:	c7 04 24 fb 85 10 f0 	movl   $0xf01085fb,(%esp)
f0103ed9:	e8 eb 00 00 00       	call   f0103fc9 <cprintf>
	for (i = 0; i < 16; i++)
f0103ede:	83 c3 01             	add    $0x1,%ebx
f0103ee1:	83 fb 10             	cmp    $0x10,%ebx
f0103ee4:	75 e3                	jne    f0103ec9 <irq_setmask_8259A+0x3f>
	cprintf("\n");
f0103ee6:	c7 04 24 de 76 10 f0 	movl   $0xf01076de,(%esp)
f0103eed:	e8 d7 00 00 00       	call   f0103fc9 <cprintf>
}
f0103ef2:	83 c4 10             	add    $0x10,%esp
f0103ef5:	5b                   	pop    %ebx
f0103ef6:	5e                   	pop    %esi
f0103ef7:	5d                   	pop    %ebp
f0103ef8:	c3                   	ret    

f0103ef9 <pic_init>:
	didinit = 1;
f0103ef9:	c6 05 50 62 22 f0 01 	movb   $0x1,0xf0226250
f0103f00:	ba 21 00 00 00       	mov    $0x21,%edx
f0103f05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f0a:	ee                   	out    %al,(%dx)
f0103f0b:	b2 a1                	mov    $0xa1,%dl
f0103f0d:	ee                   	out    %al,(%dx)
f0103f0e:	b2 20                	mov    $0x20,%dl
f0103f10:	b8 11 00 00 00       	mov    $0x11,%eax
f0103f15:	ee                   	out    %al,(%dx)
f0103f16:	b2 21                	mov    $0x21,%dl
f0103f18:	b8 20 00 00 00       	mov    $0x20,%eax
f0103f1d:	ee                   	out    %al,(%dx)
f0103f1e:	b8 04 00 00 00       	mov    $0x4,%eax
f0103f23:	ee                   	out    %al,(%dx)
f0103f24:	b8 03 00 00 00       	mov    $0x3,%eax
f0103f29:	ee                   	out    %al,(%dx)
f0103f2a:	b2 a0                	mov    $0xa0,%dl
f0103f2c:	b8 11 00 00 00       	mov    $0x11,%eax
f0103f31:	ee                   	out    %al,(%dx)
f0103f32:	b2 a1                	mov    $0xa1,%dl
f0103f34:	b8 28 00 00 00       	mov    $0x28,%eax
f0103f39:	ee                   	out    %al,(%dx)
f0103f3a:	b8 02 00 00 00       	mov    $0x2,%eax
f0103f3f:	ee                   	out    %al,(%dx)
f0103f40:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f45:	ee                   	out    %al,(%dx)
f0103f46:	b2 20                	mov    $0x20,%dl
f0103f48:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f4d:	ee                   	out    %al,(%dx)
f0103f4e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f53:	ee                   	out    %al,(%dx)
f0103f54:	b2 a0                	mov    $0xa0,%dl
f0103f56:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f5b:	ee                   	out    %al,(%dx)
f0103f5c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f61:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103f62:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103f69:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f6d:	74 12                	je     f0103f81 <pic_init+0x88>
{
f0103f6f:	55                   	push   %ebp
f0103f70:	89 e5                	mov    %esp,%ebp
f0103f72:	83 ec 18             	sub    $0x18,%esp
		irq_setmask_8259A(irq_mask_8259A);
f0103f75:	0f b7 c0             	movzwl %ax,%eax
f0103f78:	89 04 24             	mov    %eax,(%esp)
f0103f7b:	e8 0a ff ff ff       	call   f0103e8a <irq_setmask_8259A>
}
f0103f80:	c9                   	leave  
f0103f81:	f3 c3                	repz ret 

f0103f83 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f83:	55                   	push   %ebp
f0103f84:	89 e5                	mov    %esp,%ebp
f0103f86:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103f89:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f8c:	89 04 24             	mov    %eax,(%esp)
f0103f8f:	e8 16 c8 ff ff       	call   f01007aa <cputchar>
	*cnt++;
}
f0103f94:	c9                   	leave  
f0103f95:	c3                   	ret    

f0103f96 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f96:	55                   	push   %ebp
f0103f97:	89 e5                	mov    %esp,%ebp
f0103f99:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103f9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103fa6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103faa:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fad:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103fb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103fb4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fb8:	c7 04 24 83 3f 10 f0 	movl   $0xf0103f83,(%esp)
f0103fbf:	e8 b0 19 00 00       	call   f0105974 <vprintfmt>
	return cnt;
}
f0103fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103fc7:	c9                   	leave  
f0103fc8:	c3                   	ret    

f0103fc9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103fc9:	55                   	push   %ebp
f0103fca:	89 e5                	mov    %esp,%ebp
f0103fcc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103fcf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103fd2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fd6:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fd9:	89 04 24             	mov    %eax,(%esp)
f0103fdc:	e8 b5 ff ff ff       	call   f0103f96 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103fe1:	c9                   	leave  
f0103fe2:	c3                   	ret    
f0103fe3:	66 90                	xchg   %ax,%ax
f0103fe5:	66 90                	xchg   %ax,%ax
f0103fe7:	66 90                	xchg   %ax,%ax
f0103fe9:	66 90                	xchg   %ax,%ax
f0103feb:	66 90                	xchg   %ax,%ax
f0103fed:	66 90                	xchg   %ax,%ax
f0103fef:	90                   	nop

f0103ff0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103ff0:	55                   	push   %ebp
f0103ff1:	89 e5                	mov    %esp,%ebp
f0103ff3:	57                   	push   %edi
f0103ff4:	56                   	push   %esi
f0103ff5:	53                   	push   %ebx
f0103ff6:	83 ec 1c             	sub    $0x1c,%esp
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	int cpu_id = thiscpu->cpu_id;
f0103ff9:	e8 55 27 00 00       	call   f0106753 <cpunum>
f0103ffe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104001:	0f b6 80 20 70 22 f0 	movzbl -0xfdd8fe0(%eax),%eax
f0104008:	88 45 e7             	mov    %al,-0x19(%ebp)
f010400b:	0f b6 d8             	movzbl %al,%ebx
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id * (KSTKSIZE + KSTKGAP);
f010400e:	e8 40 27 00 00       	call   f0106753 <cpunum>
f0104013:	6b c0 74             	imul   $0x74,%eax,%eax
f0104016:	89 da                	mov    %ebx,%edx
f0104018:	f7 da                	neg    %edx
f010401a:	c1 e2 10             	shl    $0x10,%edx
f010401d:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0104023:	89 90 30 70 22 f0    	mov    %edx,-0xfdd8fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0104029:	e8 25 27 00 00       	call   f0106753 <cpunum>
f010402e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104031:	66 c7 80 34 70 22 f0 	movw   $0x10,-0xfdd8fcc(%eax)
f0104038:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts), sizeof(struct Taskstate), 0);
f010403a:	83 c3 05             	add    $0x5,%ebx
f010403d:	e8 11 27 00 00       	call   f0106753 <cpunum>
f0104042:	89 c7                	mov    %eax,%edi
f0104044:	e8 0a 27 00 00       	call   f0106753 <cpunum>
f0104049:	89 c6                	mov    %eax,%esi
f010404b:	e8 03 27 00 00       	call   f0106753 <cpunum>
f0104050:	66 c7 04 dd 40 13 12 	movw   $0x68,-0xfedecc0(,%ebx,8)
f0104057:	f0 68 00 
f010405a:	6b ff 74             	imul   $0x74,%edi,%edi
f010405d:	81 c7 2c 70 22 f0    	add    $0xf022702c,%edi
f0104063:	66 89 3c dd 42 13 12 	mov    %di,-0xfedecbe(,%ebx,8)
f010406a:	f0 
f010406b:	6b d6 74             	imul   $0x74,%esi,%edx
f010406e:	81 c2 2c 70 22 f0    	add    $0xf022702c,%edx
f0104074:	c1 ea 10             	shr    $0x10,%edx
f0104077:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f010407e:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f0104085:	40 
f0104086:	6b c0 74             	imul   $0x74,%eax,%eax
f0104089:	05 2c 70 22 f0       	add    $0xf022702c,%eax
f010408e:	c1 e8 18             	shr    $0x18,%eax
f0104091:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0104098:	c6 04 dd 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%ebx,8)
f010409f:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpu_id << 3));
f01040a0:	0f b6 75 e7          	movzbl -0x19(%ebp),%esi
f01040a4:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
	__asm __volatile("ltr %0" : : "r" (sel));
f01040ab:	0f 00 de             	ltr    %si
	__asm __volatile("lidt (%0)" : : "r" (p));
f01040ae:	b8 aa 13 12 f0       	mov    $0xf01213aa,%eax
f01040b3:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f01040b6:	83 c4 1c             	add    $0x1c,%esp
f01040b9:	5b                   	pop    %ebx
f01040ba:	5e                   	pop    %esi
f01040bb:	5f                   	pop    %edi
f01040bc:	5d                   	pop    %ebp
f01040bd:	c3                   	ret    

f01040be <trap_init>:
{
f01040be:	55                   	push   %ebp
f01040bf:	89 e5                	mov    %esp,%ebp
f01040c1:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f01040c4:	b8 2c 4b 10 f0       	mov    $0xf0104b2c,%eax
f01040c9:	66 a3 60 62 22 f0    	mov    %ax,0xf0226260
f01040cf:	66 c7 05 62 62 22 f0 	movw   $0x8,0xf0226262
f01040d6:	08 00 
f01040d8:	c6 05 64 62 22 f0 00 	movb   $0x0,0xf0226264
f01040df:	c6 05 65 62 22 f0 8e 	movb   $0x8e,0xf0226265
f01040e6:	c1 e8 10             	shr    $0x10,%eax
f01040e9:	66 a3 66 62 22 f0    	mov    %ax,0xf0226266
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f01040ef:	b8 36 4b 10 f0       	mov    $0xf0104b36,%eax
f01040f4:	66 a3 68 62 22 f0    	mov    %ax,0xf0226268
f01040fa:	66 c7 05 6a 62 22 f0 	movw   $0x8,0xf022626a
f0104101:	08 00 
f0104103:	c6 05 6c 62 22 f0 00 	movb   $0x0,0xf022626c
f010410a:	c6 05 6d 62 22 f0 8e 	movb   $0x8e,0xf022626d
f0104111:	c1 e8 10             	shr    $0x10,%eax
f0104114:	66 a3 6e 62 22 f0    	mov    %ax,0xf022626e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f010411a:	b8 3c 4b 10 f0       	mov    $0xf0104b3c,%eax
f010411f:	66 a3 70 62 22 f0    	mov    %ax,0xf0226270
f0104125:	66 c7 05 72 62 22 f0 	movw   $0x8,0xf0226272
f010412c:	08 00 
f010412e:	c6 05 74 62 22 f0 00 	movb   $0x0,0xf0226274
f0104135:	c6 05 75 62 22 f0 8e 	movb   $0x8e,0xf0226275
f010413c:	c1 e8 10             	shr    $0x10,%eax
f010413f:	66 a3 76 62 22 f0    	mov    %ax,0xf0226276
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0104145:	b8 42 4b 10 f0       	mov    $0xf0104b42,%eax
f010414a:	66 a3 78 62 22 f0    	mov    %ax,0xf0226278
f0104150:	66 c7 05 7a 62 22 f0 	movw   $0x8,0xf022627a
f0104157:	08 00 
f0104159:	c6 05 7c 62 22 f0 00 	movb   $0x0,0xf022627c
f0104160:	c6 05 7d 62 22 f0 ee 	movb   $0xee,0xf022627d
f0104167:	c1 e8 10             	shr    $0x10,%eax
f010416a:	66 a3 7e 62 22 f0    	mov    %ax,0xf022627e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f0104170:	b8 48 4b 10 f0       	mov    $0xf0104b48,%eax
f0104175:	66 a3 80 62 22 f0    	mov    %ax,0xf0226280
f010417b:	66 c7 05 82 62 22 f0 	movw   $0x8,0xf0226282
f0104182:	08 00 
f0104184:	c6 05 84 62 22 f0 00 	movb   $0x0,0xf0226284
f010418b:	c6 05 85 62 22 f0 8e 	movb   $0x8e,0xf0226285
f0104192:	c1 e8 10             	shr    $0x10,%eax
f0104195:	66 a3 86 62 22 f0    	mov    %ax,0xf0226286
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f010419b:	b8 4e 4b 10 f0       	mov    $0xf0104b4e,%eax
f01041a0:	66 a3 88 62 22 f0    	mov    %ax,0xf0226288
f01041a6:	66 c7 05 8a 62 22 f0 	movw   $0x8,0xf022628a
f01041ad:	08 00 
f01041af:	c6 05 8c 62 22 f0 00 	movb   $0x0,0xf022628c
f01041b6:	c6 05 8d 62 22 f0 8e 	movb   $0x8e,0xf022628d
f01041bd:	c1 e8 10             	shr    $0x10,%eax
f01041c0:	66 a3 8e 62 22 f0    	mov    %ax,0xf022628e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f01041c6:	b8 54 4b 10 f0       	mov    $0xf0104b54,%eax
f01041cb:	66 a3 90 62 22 f0    	mov    %ax,0xf0226290
f01041d1:	66 c7 05 92 62 22 f0 	movw   $0x8,0xf0226292
f01041d8:	08 00 
f01041da:	c6 05 94 62 22 f0 00 	movb   $0x0,0xf0226294
f01041e1:	c6 05 95 62 22 f0 8e 	movb   $0x8e,0xf0226295
f01041e8:	c1 e8 10             	shr    $0x10,%eax
f01041eb:	66 a3 96 62 22 f0    	mov    %ax,0xf0226296
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f01041f1:	b8 5a 4b 10 f0       	mov    $0xf0104b5a,%eax
f01041f6:	66 a3 98 62 22 f0    	mov    %ax,0xf0226298
f01041fc:	66 c7 05 9a 62 22 f0 	movw   $0x8,0xf022629a
f0104203:	08 00 
f0104205:	c6 05 9c 62 22 f0 00 	movb   $0x0,0xf022629c
f010420c:	c6 05 9d 62 22 f0 8e 	movb   $0x8e,0xf022629d
f0104213:	c1 e8 10             	shr    $0x10,%eax
f0104216:	66 a3 9e 62 22 f0    	mov    %ax,0xf022629e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f010421c:	b8 60 4b 10 f0       	mov    $0xf0104b60,%eax
f0104221:	66 a3 a0 62 22 f0    	mov    %ax,0xf02262a0
f0104227:	66 c7 05 a2 62 22 f0 	movw   $0x8,0xf02262a2
f010422e:	08 00 
f0104230:	c6 05 a4 62 22 f0 00 	movb   $0x0,0xf02262a4
f0104237:	c6 05 a5 62 22 f0 8e 	movb   $0x8e,0xf02262a5
f010423e:	c1 e8 10             	shr    $0x10,%eax
f0104241:	66 a3 a6 62 22 f0    	mov    %ax,0xf02262a6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0104247:	b8 64 4b 10 f0       	mov    $0xf0104b64,%eax
f010424c:	66 a3 b0 62 22 f0    	mov    %ax,0xf02262b0
f0104252:	66 c7 05 b2 62 22 f0 	movw   $0x8,0xf02262b2
f0104259:	08 00 
f010425b:	c6 05 b4 62 22 f0 00 	movb   $0x0,0xf02262b4
f0104262:	c6 05 b5 62 22 f0 8e 	movb   $0x8e,0xf02262b5
f0104269:	c1 e8 10             	shr    $0x10,%eax
f010426c:	66 a3 b6 62 22 f0    	mov    %ax,0xf02262b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0104272:	b8 68 4b 10 f0       	mov    $0xf0104b68,%eax
f0104277:	66 a3 b8 62 22 f0    	mov    %ax,0xf02262b8
f010427d:	66 c7 05 ba 62 22 f0 	movw   $0x8,0xf02262ba
f0104284:	08 00 
f0104286:	c6 05 bc 62 22 f0 00 	movb   $0x0,0xf02262bc
f010428d:	c6 05 bd 62 22 f0 8e 	movb   $0x8e,0xf02262bd
f0104294:	c1 e8 10             	shr    $0x10,%eax
f0104297:	66 a3 be 62 22 f0    	mov    %ax,0xf02262be
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f010429d:	b8 6e 4b 10 f0       	mov    $0xf0104b6e,%eax
f01042a2:	66 a3 c0 62 22 f0    	mov    %ax,0xf02262c0
f01042a8:	66 c7 05 c2 62 22 f0 	movw   $0x8,0xf02262c2
f01042af:	08 00 
f01042b1:	c6 05 c4 62 22 f0 00 	movb   $0x0,0xf02262c4
f01042b8:	c6 05 c5 62 22 f0 8e 	movb   $0x8e,0xf02262c5
f01042bf:	c1 e8 10             	shr    $0x10,%eax
f01042c2:	66 a3 c6 62 22 f0    	mov    %ax,0xf02262c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f01042c8:	b8 72 4b 10 f0       	mov    $0xf0104b72,%eax
f01042cd:	66 a3 c8 62 22 f0    	mov    %ax,0xf02262c8
f01042d3:	66 c7 05 ca 62 22 f0 	movw   $0x8,0xf02262ca
f01042da:	08 00 
f01042dc:	c6 05 cc 62 22 f0 00 	movb   $0x0,0xf02262cc
f01042e3:	c6 05 cd 62 22 f0 8e 	movb   $0x8e,0xf02262cd
f01042ea:	c1 e8 10             	shr    $0x10,%eax
f01042ed:	66 a3 ce 62 22 f0    	mov    %ax,0xf02262ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f01042f3:	b8 76 4b 10 f0       	mov    $0xf0104b76,%eax
f01042f8:	66 a3 d0 62 22 f0    	mov    %ax,0xf02262d0
f01042fe:	66 c7 05 d2 62 22 f0 	movw   $0x8,0xf02262d2
f0104305:	08 00 
f0104307:	c6 05 d4 62 22 f0 00 	movb   $0x0,0xf02262d4
f010430e:	c6 05 d5 62 22 f0 8e 	movb   $0x8e,0xf02262d5
f0104315:	c1 e8 10             	shr    $0x10,%eax
f0104318:	66 a3 d6 62 22 f0    	mov    %ax,0xf02262d6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f010431e:	b8 7a 4b 10 f0       	mov    $0xf0104b7a,%eax
f0104323:	66 a3 e0 62 22 f0    	mov    %ax,0xf02262e0
f0104329:	66 c7 05 e2 62 22 f0 	movw   $0x8,0xf02262e2
f0104330:	08 00 
f0104332:	c6 05 e4 62 22 f0 00 	movb   $0x0,0xf02262e4
f0104339:	c6 05 e5 62 22 f0 8e 	movb   $0x8e,0xf02262e5
f0104340:	c1 e8 10             	shr    $0x10,%eax
f0104343:	66 a3 e6 62 22 f0    	mov    %ax,0xf02262e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0104349:	b8 80 4b 10 f0       	mov    $0xf0104b80,%eax
f010434e:	66 a3 e8 62 22 f0    	mov    %ax,0xf02262e8
f0104354:	66 c7 05 ea 62 22 f0 	movw   $0x8,0xf02262ea
f010435b:	08 00 
f010435d:	c6 05 ec 62 22 f0 00 	movb   $0x0,0xf02262ec
f0104364:	c6 05 ed 62 22 f0 8e 	movb   $0x8e,0xf02262ed
f010436b:	c1 e8 10             	shr    $0x10,%eax
f010436e:	66 a3 ee 62 22 f0    	mov    %ax,0xf02262ee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0104374:	b8 84 4b 10 f0       	mov    $0xf0104b84,%eax
f0104379:	66 a3 f0 62 22 f0    	mov    %ax,0xf02262f0
f010437f:	66 c7 05 f2 62 22 f0 	movw   $0x8,0xf02262f2
f0104386:	08 00 
f0104388:	c6 05 f4 62 22 f0 00 	movb   $0x0,0xf02262f4
f010438f:	c6 05 f5 62 22 f0 8e 	movb   $0x8e,0xf02262f5
f0104396:	c1 e8 10             	shr    $0x10,%eax
f0104399:	66 a3 f6 62 22 f0    	mov    %ax,0xf02262f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f010439f:	b8 8a 4b 10 f0       	mov    $0xf0104b8a,%eax
f01043a4:	66 a3 f8 62 22 f0    	mov    %ax,0xf02262f8
f01043aa:	66 c7 05 fa 62 22 f0 	movw   $0x8,0xf02262fa
f01043b1:	08 00 
f01043b3:	c6 05 fc 62 22 f0 00 	movb   $0x0,0xf02262fc
f01043ba:	c6 05 fd 62 22 f0 8e 	movb   $0x8e,0xf02262fd
f01043c1:	c1 e8 10             	shr    $0x10,%eax
f01043c4:	66 a3 fe 62 22 f0    	mov    %ax,0xf02262fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f01043ca:	b8 90 4b 10 f0       	mov    $0xf0104b90,%eax
f01043cf:	66 a3 e0 63 22 f0    	mov    %ax,0xf02263e0
f01043d5:	66 c7 05 e2 63 22 f0 	movw   $0x8,0xf02263e2
f01043dc:	08 00 
f01043de:	c6 05 e4 63 22 f0 00 	movb   $0x0,0xf02263e4
f01043e5:	c6 05 e5 63 22 f0 ee 	movb   $0xee,0xf02263e5
f01043ec:	c1 e8 10             	shr    $0x10,%eax
f01043ef:	66 a3 e6 63 22 f0    	mov    %ax,0xf02263e6
	SETGATE(idt[IRQ_TIMER + IRQ_OFFSET], 0, GD_KT, irq_timer, 0);
f01043f5:	b8 96 4b 10 f0       	mov    $0xf0104b96,%eax
f01043fa:	66 a3 60 63 22 f0    	mov    %ax,0xf0226360
f0104400:	66 c7 05 62 63 22 f0 	movw   $0x8,0xf0226362
f0104407:	08 00 
f0104409:	c6 05 64 63 22 f0 00 	movb   $0x0,0xf0226364
f0104410:	c6 05 65 63 22 f0 8e 	movb   $0x8e,0xf0226365
f0104417:	c1 e8 10             	shr    $0x10,%eax
f010441a:	66 a3 66 63 22 f0    	mov    %ax,0xf0226366
	SETGATE(idt[IRQ_KBD + IRQ_OFFSET], 0, GD_KT, irq_kbd, 0);
f0104420:	b8 9c 4b 10 f0       	mov    $0xf0104b9c,%eax
f0104425:	66 a3 68 63 22 f0    	mov    %ax,0xf0226368
f010442b:	66 c7 05 6a 63 22 f0 	movw   $0x8,0xf022636a
f0104432:	08 00 
f0104434:	c6 05 6c 63 22 f0 00 	movb   $0x0,0xf022636c
f010443b:	c6 05 6d 63 22 f0 8e 	movb   $0x8e,0xf022636d
f0104442:	c1 e8 10             	shr    $0x10,%eax
f0104445:	66 a3 6e 63 22 f0    	mov    %ax,0xf022636e
	SETGATE(idt[IRQ_SERIAL + IRQ_OFFSET], 0, GD_KT, irq_serial, 0);
f010444b:	b8 a2 4b 10 f0       	mov    $0xf0104ba2,%eax
f0104450:	66 a3 80 63 22 f0    	mov    %ax,0xf0226380
f0104456:	66 c7 05 82 63 22 f0 	movw   $0x8,0xf0226382
f010445d:	08 00 
f010445f:	c6 05 84 63 22 f0 00 	movb   $0x0,0xf0226384
f0104466:	c6 05 85 63 22 f0 8e 	movb   $0x8e,0xf0226385
f010446d:	c1 e8 10             	shr    $0x10,%eax
f0104470:	66 a3 86 63 22 f0    	mov    %ax,0xf0226386
	SETGATE(idt[IRQ_SPURIOUS + IRQ_OFFSET], 0, GD_KT, irq_spurious, 0);
f0104476:	b8 a8 4b 10 f0       	mov    $0xf0104ba8,%eax
f010447b:	66 a3 98 63 22 f0    	mov    %ax,0xf0226398
f0104481:	66 c7 05 9a 63 22 f0 	movw   $0x8,0xf022639a
f0104488:	08 00 
f010448a:	c6 05 9c 63 22 f0 00 	movb   $0x0,0xf022639c
f0104491:	c6 05 9d 63 22 f0 8e 	movb   $0x8e,0xf022639d
f0104498:	c1 e8 10             	shr    $0x10,%eax
f010449b:	66 a3 9e 63 22 f0    	mov    %ax,0xf022639e
	SETGATE(idt[IRQ_IDE + IRQ_OFFSET], 0, GD_KT, irq_ide, 0);
f01044a1:	b8 ae 4b 10 f0       	mov    $0xf0104bae,%eax
f01044a6:	66 a3 d0 63 22 f0    	mov    %ax,0xf02263d0
f01044ac:	66 c7 05 d2 63 22 f0 	movw   $0x8,0xf02263d2
f01044b3:	08 00 
f01044b5:	c6 05 d4 63 22 f0 00 	movb   $0x0,0xf02263d4
f01044bc:	c6 05 d5 63 22 f0 8e 	movb   $0x8e,0xf02263d5
f01044c3:	c1 e8 10             	shr    $0x10,%eax
f01044c6:	66 a3 d6 63 22 f0    	mov    %ax,0xf02263d6
	SETGATE(idt[IRQ_ERROR + IRQ_OFFSET], 0, GD_KT, irq_error, 0);
f01044cc:	b8 b4 4b 10 f0       	mov    $0xf0104bb4,%eax
f01044d1:	66 a3 f8 63 22 f0    	mov    %ax,0xf02263f8
f01044d7:	66 c7 05 fa 63 22 f0 	movw   $0x8,0xf02263fa
f01044de:	08 00 
f01044e0:	c6 05 fc 63 22 f0 00 	movb   $0x0,0xf02263fc
f01044e7:	c6 05 fd 63 22 f0 8e 	movb   $0x8e,0xf02263fd
f01044ee:	c1 e8 10             	shr    $0x10,%eax
f01044f1:	66 a3 fe 63 22 f0    	mov    %ax,0xf02263fe
	trap_init_percpu();
f01044f7:	e8 f4 fa ff ff       	call   f0103ff0 <trap_init_percpu>
}
f01044fc:	c9                   	leave  
f01044fd:	c3                   	ret    

f01044fe <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01044fe:	55                   	push   %ebp
f01044ff:	89 e5                	mov    %esp,%ebp
f0104501:	53                   	push   %ebx
f0104502:	83 ec 14             	sub    $0x14,%esp
f0104505:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104508:	8b 03                	mov    (%ebx),%eax
f010450a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010450e:	c7 04 24 21 81 10 f0 	movl   $0xf0108121,(%esp)
f0104515:	e8 af fa ff ff       	call   f0103fc9 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010451a:	8b 43 04             	mov    0x4(%ebx),%eax
f010451d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104521:	c7 04 24 30 81 10 f0 	movl   $0xf0108130,(%esp)
f0104528:	e8 9c fa ff ff       	call   f0103fc9 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010452d:	8b 43 08             	mov    0x8(%ebx),%eax
f0104530:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104534:	c7 04 24 3f 81 10 f0 	movl   $0xf010813f,(%esp)
f010453b:	e8 89 fa ff ff       	call   f0103fc9 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104540:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104543:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104547:	c7 04 24 4e 81 10 f0 	movl   $0xf010814e,(%esp)
f010454e:	e8 76 fa ff ff       	call   f0103fc9 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104553:	8b 43 10             	mov    0x10(%ebx),%eax
f0104556:	89 44 24 04          	mov    %eax,0x4(%esp)
f010455a:	c7 04 24 5d 81 10 f0 	movl   $0xf010815d,(%esp)
f0104561:	e8 63 fa ff ff       	call   f0103fc9 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104566:	8b 43 14             	mov    0x14(%ebx),%eax
f0104569:	89 44 24 04          	mov    %eax,0x4(%esp)
f010456d:	c7 04 24 6c 81 10 f0 	movl   $0xf010816c,(%esp)
f0104574:	e8 50 fa ff ff       	call   f0103fc9 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104579:	8b 43 18             	mov    0x18(%ebx),%eax
f010457c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104580:	c7 04 24 7b 81 10 f0 	movl   $0xf010817b,(%esp)
f0104587:	e8 3d fa ff ff       	call   f0103fc9 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010458c:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010458f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104593:	c7 04 24 8a 81 10 f0 	movl   $0xf010818a,(%esp)
f010459a:	e8 2a fa ff ff       	call   f0103fc9 <cprintf>
}
f010459f:	83 c4 14             	add    $0x14,%esp
f01045a2:	5b                   	pop    %ebx
f01045a3:	5d                   	pop    %ebp
f01045a4:	c3                   	ret    

f01045a5 <print_trapframe>:
{
f01045a5:	55                   	push   %ebp
f01045a6:	89 e5                	mov    %esp,%ebp
f01045a8:	56                   	push   %esi
f01045a9:	53                   	push   %ebx
f01045aa:	83 ec 10             	sub    $0x10,%esp
f01045ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01045b0:	e8 9e 21 00 00       	call   f0106753 <cpunum>
f01045b5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01045bd:	c7 04 24 ee 81 10 f0 	movl   $0xf01081ee,(%esp)
f01045c4:	e8 00 fa ff ff       	call   f0103fc9 <cprintf>
	print_regs(&tf->tf_regs);
f01045c9:	89 1c 24             	mov    %ebx,(%esp)
f01045cc:	e8 2d ff ff ff       	call   f01044fe <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01045d1:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01045d5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045d9:	c7 04 24 0c 82 10 f0 	movl   $0xf010820c,(%esp)
f01045e0:	e8 e4 f9 ff ff       	call   f0103fc9 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01045e5:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01045e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045ed:	c7 04 24 1f 82 10 f0 	movl   $0xf010821f,(%esp)
f01045f4:	e8 d0 f9 ff ff       	call   f0103fc9 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01045f9:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01045fc:	83 f8 13             	cmp    $0x13,%eax
f01045ff:	77 09                	ja     f010460a <print_trapframe+0x65>
		return excnames[trapno];
f0104601:	8b 14 85 e0 84 10 f0 	mov    -0xfef7b20(,%eax,4),%edx
f0104608:	eb 1f                	jmp    f0104629 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f010460a:	83 f8 30             	cmp    $0x30,%eax
f010460d:	74 15                	je     f0104624 <print_trapframe+0x7f>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010460f:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104612:	83 fa 0f             	cmp    $0xf,%edx
f0104615:	ba a5 81 10 f0       	mov    $0xf01081a5,%edx
f010461a:	b9 b8 81 10 f0       	mov    $0xf01081b8,%ecx
f010461f:	0f 47 d1             	cmova  %ecx,%edx
f0104622:	eb 05                	jmp    f0104629 <print_trapframe+0x84>
		return "System call";
f0104624:	ba 99 81 10 f0       	mov    $0xf0108199,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104629:	89 54 24 08          	mov    %edx,0x8(%esp)
f010462d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104631:	c7 04 24 32 82 10 f0 	movl   $0xf0108232,(%esp)
f0104638:	e8 8c f9 ff ff       	call   f0103fc9 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010463d:	3b 1d 60 6a 22 f0    	cmp    0xf0226a60,%ebx
f0104643:	75 19                	jne    f010465e <print_trapframe+0xb9>
f0104645:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104649:	75 13                	jne    f010465e <print_trapframe+0xb9>
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010464b:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010464e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104652:	c7 04 24 44 82 10 f0 	movl   $0xf0108244,(%esp)
f0104659:	e8 6b f9 ff ff       	call   f0103fc9 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010465e:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104661:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104665:	c7 04 24 53 82 10 f0 	movl   $0xf0108253,(%esp)
f010466c:	e8 58 f9 ff ff       	call   f0103fc9 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104671:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104675:	75 51                	jne    f01046c8 <print_trapframe+0x123>
			tf->tf_err & 1 ? "protection" : "not-present");
f0104677:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f010467a:	89 c2                	mov    %eax,%edx
f010467c:	83 e2 01             	and    $0x1,%edx
f010467f:	ba c7 81 10 f0       	mov    $0xf01081c7,%edx
f0104684:	b9 d2 81 10 f0       	mov    $0xf01081d2,%ecx
f0104689:	0f 45 ca             	cmovne %edx,%ecx
f010468c:	89 c2                	mov    %eax,%edx
f010468e:	83 e2 02             	and    $0x2,%edx
f0104691:	ba de 81 10 f0       	mov    $0xf01081de,%edx
f0104696:	be e4 81 10 f0       	mov    $0xf01081e4,%esi
f010469b:	0f 44 d6             	cmove  %esi,%edx
f010469e:	83 e0 04             	and    $0x4,%eax
f01046a1:	b8 e9 81 10 f0       	mov    $0xf01081e9,%eax
f01046a6:	be 1e 83 10 f0       	mov    $0xf010831e,%esi
f01046ab:	0f 44 c6             	cmove  %esi,%eax
f01046ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01046b2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01046b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046ba:	c7 04 24 61 82 10 f0 	movl   $0xf0108261,(%esp)
f01046c1:	e8 03 f9 ff ff       	call   f0103fc9 <cprintf>
f01046c6:	eb 0c                	jmp    f01046d4 <print_trapframe+0x12f>
		cprintf("\n");
f01046c8:	c7 04 24 de 76 10 f0 	movl   $0xf01076de,(%esp)
f01046cf:	e8 f5 f8 ff ff       	call   f0103fc9 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01046d4:	8b 43 30             	mov    0x30(%ebx),%eax
f01046d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046db:	c7 04 24 70 82 10 f0 	movl   $0xf0108270,(%esp)
f01046e2:	e8 e2 f8 ff ff       	call   f0103fc9 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01046e7:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01046eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046ef:	c7 04 24 7f 82 10 f0 	movl   $0xf010827f,(%esp)
f01046f6:	e8 ce f8 ff ff       	call   f0103fc9 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01046fb:	8b 43 38             	mov    0x38(%ebx),%eax
f01046fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104702:	c7 04 24 92 82 10 f0 	movl   $0xf0108292,(%esp)
f0104709:	e8 bb f8 ff ff       	call   f0103fc9 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010470e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104712:	74 27                	je     f010473b <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104714:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104717:	89 44 24 04          	mov    %eax,0x4(%esp)
f010471b:	c7 04 24 a1 82 10 f0 	movl   $0xf01082a1,(%esp)
f0104722:	e8 a2 f8 ff ff       	call   f0103fc9 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104727:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010472b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010472f:	c7 04 24 b0 82 10 f0 	movl   $0xf01082b0,(%esp)
f0104736:	e8 8e f8 ff ff       	call   f0103fc9 <cprintf>
}
f010473b:	83 c4 10             	add    $0x10,%esp
f010473e:	5b                   	pop    %ebx
f010473f:	5e                   	pop    %esi
f0104740:	5d                   	pop    %ebp
f0104741:	c3                   	ret    

f0104742 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104742:	55                   	push   %ebp
f0104743:	89 e5                	mov    %esp,%ebp
f0104745:	57                   	push   %edi
f0104746:	56                   	push   %esi
f0104747:	53                   	push   %ebx
f0104748:	83 ec 2c             	sub    $0x2c,%esp
f010474b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010474e:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if(!(tf->tf_cs & 3))
f0104751:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104755:	75 1c                	jne    f0104773 <page_fault_handler+0x31>
		panic("page_fault_handler: a page fault occurred in the kernel");
f0104757:	c7 44 24 08 68 84 10 	movl   $0xf0108468,0x8(%esp)
f010475e:	f0 
f010475f:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
f0104766:	00 
f0104767:	c7 04 24 c3 82 10 f0 	movl   $0xf01082c3,(%esp)
f010476e:	e8 cd b8 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if(curenv->env_pgfault_upcall){
f0104773:	e8 db 1f 00 00       	call   f0106753 <cpunum>
f0104778:	6b c0 74             	imul   $0x74,%eax,%eax
f010477b:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0104781:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104785:	0f 84 05 01 00 00    	je     f0104890 <page_fault_handler+0x14e>
		struct UTrapframe *utrapframe;
		unsigned curenv_esp = curenv->env_tf.tf_esp;
f010478b:	e8 c3 1f 00 00       	call   f0106753 <cpunum>
f0104790:	6b c0 74             	imul   $0x74,%eax,%eax
f0104793:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0104799:	8b 40 3c             	mov    0x3c(%eax),%eax
		if(curenv_esp >= UXSTACKTOP-PGSIZE && curenv_esp < UXSTACKTOP){
f010479c:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			//已经处理过一次页面异常了
			//push空的32位字和UTrapframe
			utrapframe = (struct UTrapframe *)(curenv_esp - 4 - sizeof(struct UTrapframe));
f01047a2:	83 e8 38             	sub    $0x38,%eax
f01047a5:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01047ab:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f01047b0:	0f 46 d0             	cmovbe %eax,%edx
f01047b3:	89 d7                	mov    %edx,%edi
f01047b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		}
		else
			//第一次处理，push UTrapframe
			utrapframe = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
		//保证UTrapframe的地址是可写的
		user_mem_assert(curenv, (void*)utrapframe, sizeof(struct UTrapframe), PTE_W);
f01047b8:	e8 96 1f 00 00       	call   f0106753 <cpunum>
f01047bd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01047c4:	00 
f01047c5:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f01047cc:	00 
f01047cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01047d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01047d4:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f01047da:	89 04 24             	mov    %eax,(%esp)
f01047dd:	e8 b9 ed ff ff       	call   f010359b <user_mem_assert>
		//utrapframe是异常栈帧，压栈是为了保存之前的状态以便还原
		utrapframe->utf_fault_va = fault_va;
f01047e2:	89 37                	mov    %esi,(%edi)
		utrapframe->utf_err = tf->tf_err;
f01047e4:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01047e7:	89 47 04             	mov    %eax,0x4(%edi)
		utrapframe->utf_regs = tf->tf_regs;
f01047ea:	8d 7f 08             	lea    0x8(%edi),%edi
f01047ed:	89 de                	mov    %ebx,%esi
f01047ef:	b8 20 00 00 00       	mov    $0x20,%eax
f01047f4:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01047fa:	74 03                	je     f01047ff <page_fault_handler+0xbd>
f01047fc:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01047fd:	b0 1f                	mov    $0x1f,%al
f01047ff:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104805:	74 05                	je     f010480c <page_fault_handler+0xca>
f0104807:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104809:	83 e8 02             	sub    $0x2,%eax
f010480c:	89 c1                	mov    %eax,%ecx
f010480e:	c1 e9 02             	shr    $0x2,%ecx
f0104811:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104813:	ba 00 00 00 00       	mov    $0x0,%edx
f0104818:	a8 02                	test   $0x2,%al
f010481a:	74 0b                	je     f0104827 <page_fault_handler+0xe5>
f010481c:	0f b7 16             	movzwl (%esi),%edx
f010481f:	66 89 17             	mov    %dx,(%edi)
f0104822:	ba 02 00 00 00       	mov    $0x2,%edx
f0104827:	a8 01                	test   $0x1,%al
f0104829:	74 07                	je     f0104832 <page_fault_handler+0xf0>
f010482b:	0f b6 04 16          	movzbl (%esi,%edx,1),%eax
f010482f:	88 04 17             	mov    %al,(%edi,%edx,1)
		utrapframe->utf_eip = tf->tf_eip;
f0104832:	8b 43 30             	mov    0x30(%ebx),%eax
f0104835:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104838:	89 46 28             	mov    %eax,0x28(%esi)
		utrapframe->utf_eflags = tf->tf_eflags;
f010483b:	8b 43 38             	mov    0x38(%ebx),%eax
f010483e:	89 46 2c             	mov    %eax,0x2c(%esi)
		utrapframe->utf_esp = tf->tf_esp;
f0104841:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104844:	89 46 30             	mov    %eax,0x30(%esi)
		
		//修改当前栈指针
		curenv->env_tf.tf_eip = (unsigned)curenv->env_pgfault_upcall;
f0104847:	e8 07 1f 00 00       	call   f0106753 <cpunum>
f010484c:	6b c0 74             	imul   $0x74,%eax,%eax
f010484f:	8b 98 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%ebx
f0104855:	e8 f9 1e 00 00       	call   f0106753 <cpunum>
f010485a:	6b c0 74             	imul   $0x74,%eax,%eax
f010485d:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0104863:	8b 40 64             	mov    0x64(%eax),%eax
f0104866:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = (unsigned)utrapframe;
f0104869:	e8 e5 1e 00 00       	call   f0106753 <cpunum>
f010486e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104871:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0104877:	89 70 3c             	mov    %esi,0x3c(%eax)
		//重新执行env
		env_run(curenv);
f010487a:	e8 d4 1e 00 00       	call   f0106753 <cpunum>
f010487f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104882:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0104888:	89 04 24             	mov    %eax,(%esp)
f010488b:	e8 e2 f4 ff ff       	call   f0103d72 <env_run>
	}
	else{
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104890:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f0104893:	e8 bb 1e 00 00       	call   f0106753 <cpunum>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104898:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010489c:	89 74 24 08          	mov    %esi,0x8(%esp)
			curenv->env_id, fault_va, tf->tf_eip);
f01048a0:	6b c0 74             	imul   $0x74,%eax,%eax
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01048a3:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f01048a9:	8b 40 48             	mov    0x48(%eax),%eax
f01048ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048b0:	c7 04 24 a0 84 10 f0 	movl   $0xf01084a0,(%esp)
f01048b7:	e8 0d f7 ff ff       	call   f0103fc9 <cprintf>
		print_trapframe(tf);
f01048bc:	89 1c 24             	mov    %ebx,(%esp)
f01048bf:	e8 e1 fc ff ff       	call   f01045a5 <print_trapframe>
		env_destroy(curenv);
f01048c4:	e8 8a 1e 00 00       	call   f0106753 <cpunum>
f01048c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01048cc:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f01048d2:	89 04 24             	mov    %eax,(%esp)
f01048d5:	e8 f7 f3 ff ff       	call   f0103cd1 <env_destroy>
	}
}
f01048da:	83 c4 2c             	add    $0x2c,%esp
f01048dd:	5b                   	pop    %ebx
f01048de:	5e                   	pop    %esi
f01048df:	5f                   	pop    %edi
f01048e0:	5d                   	pop    %ebp
f01048e1:	c3                   	ret    

f01048e2 <trap>:
{
f01048e2:	55                   	push   %ebp
f01048e3:	89 e5                	mov    %esp,%ebp
f01048e5:	57                   	push   %edi
f01048e6:	56                   	push   %esi
f01048e7:	83 ec 20             	sub    $0x20,%esp
f01048ea:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f01048ed:	fc                   	cld    
	if (panicstr)
f01048ee:	83 3d 80 6e 22 f0 00 	cmpl   $0x0,0xf0226e80
f01048f5:	74 01                	je     f01048f8 <trap+0x16>
		asm volatile("hlt");
f01048f7:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01048f8:	e8 56 1e 00 00       	call   f0106753 <cpunum>
f01048fd:	6b d0 74             	imul   $0x74,%eax,%edx
f0104900:	81 c2 20 70 22 f0    	add    $0xf0227020,%edx
	asm volatile("lock; xchgl %0, %1" :
f0104906:	b8 01 00 00 00       	mov    $0x1,%eax
f010490b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010490f:	83 f8 02             	cmp    $0x2,%eax
f0104912:	75 0c                	jne    f0104920 <trap+0x3e>
	spin_lock(&kernel_lock);
f0104914:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f010491b:	e8 b1 20 00 00       	call   f01069d1 <spin_lock>
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104920:	9c                   	pushf  
f0104921:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104922:	f6 c4 02             	test   $0x2,%ah
f0104925:	74 24                	je     f010494b <trap+0x69>
f0104927:	c7 44 24 0c cf 82 10 	movl   $0xf01082cf,0xc(%esp)
f010492e:	f0 
f010492f:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0104936:	f0 
f0104937:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
f010493e:	00 
f010493f:	c7 04 24 c3 82 10 f0 	movl   $0xf01082c3,(%esp)
f0104946:	e8 f5 b6 ff ff       	call   f0100040 <_panic>
	if ((tf->tf_cs & 3) == 3) {
f010494b:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010494f:	83 e0 03             	and    $0x3,%eax
f0104952:	66 83 f8 03          	cmp    $0x3,%ax
f0104956:	0f 85 a7 00 00 00    	jne    f0104a03 <trap+0x121>
f010495c:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104963:	e8 69 20 00 00       	call   f01069d1 <spin_lock>
		assert(curenv);
f0104968:	e8 e6 1d 00 00       	call   f0106753 <cpunum>
f010496d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104970:	83 b8 28 70 22 f0 00 	cmpl   $0x0,-0xfdd8fd8(%eax)
f0104977:	75 24                	jne    f010499d <trap+0xbb>
f0104979:	c7 44 24 0c e8 82 10 	movl   $0xf01082e8,0xc(%esp)
f0104980:	f0 
f0104981:	c7 44 24 08 45 74 10 	movl   $0xf0107445,0x8(%esp)
f0104988:	f0 
f0104989:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
f0104990:	00 
f0104991:	c7 04 24 c3 82 10 f0 	movl   $0xf01082c3,(%esp)
f0104998:	e8 a3 b6 ff ff       	call   f0100040 <_panic>
		if (curenv->env_status == ENV_DYING) {
f010499d:	e8 b1 1d 00 00       	call   f0106753 <cpunum>
f01049a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01049a5:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f01049ab:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01049af:	75 2d                	jne    f01049de <trap+0xfc>
			env_free(curenv);
f01049b1:	e8 9d 1d 00 00       	call   f0106753 <cpunum>
f01049b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01049b9:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f01049bf:	89 04 24             	mov    %eax,(%esp)
f01049c2:	e8 05 f1 ff ff       	call   f0103acc <env_free>
			curenv = NULL;
f01049c7:	e8 87 1d 00 00       	call   f0106753 <cpunum>
f01049cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01049cf:	c7 80 28 70 22 f0 00 	movl   $0x0,-0xfdd8fd8(%eax)
f01049d6:	00 00 00 
			sched_yield();
f01049d9:	e8 cd 02 00 00       	call   f0104cab <sched_yield>
		curenv->env_tf = *tf;
f01049de:	e8 70 1d 00 00       	call   f0106753 <cpunum>
f01049e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01049e6:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f01049ec:	b9 11 00 00 00       	mov    $0x11,%ecx
f01049f1:	89 c7                	mov    %eax,%edi
f01049f3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01049f5:	e8 59 1d 00 00       	call   f0106753 <cpunum>
f01049fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01049fd:	8b b0 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%esi
	last_tf = tf;
f0104a03:	89 35 60 6a 22 f0    	mov    %esi,0xf0226a60
	switch(tf->tf_trapno){
f0104a09:	8b 46 28             	mov    0x28(%esi),%eax
f0104a0c:	83 f8 20             	cmp    $0x20,%eax
f0104a0f:	74 76                	je     f0104a87 <trap+0x1a5>
f0104a11:	83 f8 20             	cmp    $0x20,%eax
f0104a14:	77 11                	ja     f0104a27 <trap+0x145>
f0104a16:	83 f8 03             	cmp    $0x3,%eax
f0104a19:	74 19                	je     f0104a34 <trap+0x152>
f0104a1b:	83 f8 0e             	cmp    $0xe,%eax
f0104a1e:	66 90                	xchg   %ax,%ax
f0104a20:	74 23                	je     f0104a45 <trap+0x163>
f0104a22:	e9 84 00 00 00       	jmp    f0104aab <trap+0x1c9>
f0104a27:	83 f8 27             	cmp    $0x27,%eax
f0104a2a:	74 69                	je     f0104a95 <trap+0x1b3>
f0104a2c:	83 f8 30             	cmp    $0x30,%eax
f0104a2f:	90                   	nop
f0104a30:	74 23                	je     f0104a55 <trap+0x173>
f0104a32:	eb 77                	jmp    f0104aab <trap+0x1c9>
			monitor(tf);
f0104a34:	89 34 24             	mov    %esi,(%esp)
f0104a37:	e8 94 bf ff ff       	call   f01009d0 <monitor>
f0104a3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104a40:	e9 a7 00 00 00       	jmp    f0104aec <trap+0x20a>
			page_fault_handler(tf);
f0104a45:	89 34 24             	mov    %esi,(%esp)
f0104a48:	e8 f5 fc ff ff       	call   f0104742 <page_fault_handler>
f0104a4d:	8d 76 00             	lea    0x0(%esi),%esi
f0104a50:	e9 97 00 00 00       	jmp    f0104aec <trap+0x20a>
			tf->tf_regs.reg_eax = syscall(eax, edx, ecx, ebx, edi, esi);
f0104a55:	8b 46 04             	mov    0x4(%esi),%eax
f0104a58:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104a5c:	8b 06                	mov    (%esi),%eax
f0104a5e:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104a62:	8b 46 10             	mov    0x10(%esi),%eax
f0104a65:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a69:	8b 46 18             	mov    0x18(%esi),%eax
f0104a6c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a70:	8b 46 14             	mov    0x14(%esi),%eax
f0104a73:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a77:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104a7a:	89 04 24             	mov    %eax,(%esp)
f0104a7d:	e8 ee 02 00 00       	call   f0104d70 <syscall>
f0104a82:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104a85:	eb 65                	jmp    f0104aec <trap+0x20a>
			lapic_eoi();
f0104a87:	e8 14 1e 00 00       	call   f01068a0 <lapic_eoi>
			sched_yield();
f0104a8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104a90:	e8 16 02 00 00       	call   f0104cab <sched_yield>
			cprintf("Spurious interrupt on irq 7\n");
f0104a95:	c7 04 24 ef 82 10 f0 	movl   $0xf01082ef,(%esp)
f0104a9c:	e8 28 f5 ff ff       	call   f0103fc9 <cprintf>
			print_trapframe(tf);
f0104aa1:	89 34 24             	mov    %esi,(%esp)
f0104aa4:	e8 fc fa ff ff       	call   f01045a5 <print_trapframe>
f0104aa9:	eb 41                	jmp    f0104aec <trap+0x20a>
			print_trapframe(tf);
f0104aab:	89 34 24             	mov    %esi,(%esp)
f0104aae:	e8 f2 fa ff ff       	call   f01045a5 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f0104ab3:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104ab8:	75 1c                	jne    f0104ad6 <trap+0x1f4>
				panic("unhandled trap in kernel");
f0104aba:	c7 44 24 08 0c 83 10 	movl   $0xf010830c,0x8(%esp)
f0104ac1:	f0 
f0104ac2:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
f0104ac9:	00 
f0104aca:	c7 04 24 c3 82 10 f0 	movl   $0xf01082c3,(%esp)
f0104ad1:	e8 6a b5 ff ff       	call   f0100040 <_panic>
				env_destroy(curenv);
f0104ad6:	e8 78 1c 00 00       	call   f0106753 <cpunum>
f0104adb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ade:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0104ae4:	89 04 24             	mov    %eax,(%esp)
f0104ae7:	e8 e5 f1 ff ff       	call   f0103cd1 <env_destroy>
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104aec:	e8 62 1c 00 00       	call   f0106753 <cpunum>
f0104af1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104af4:	83 b8 28 70 22 f0 00 	cmpl   $0x0,-0xfdd8fd8(%eax)
f0104afb:	74 2a                	je     f0104b27 <trap+0x245>
f0104afd:	e8 51 1c 00 00       	call   f0106753 <cpunum>
f0104b02:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b05:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0104b0b:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104b0f:	75 16                	jne    f0104b27 <trap+0x245>
		env_run(curenv);
f0104b11:	e8 3d 1c 00 00       	call   f0106753 <cpunum>
f0104b16:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b19:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0104b1f:	89 04 24             	mov    %eax,(%esp)
f0104b22:	e8 4b f2 ff ff       	call   f0103d72 <env_run>
		sched_yield();
f0104b27:	e8 7f 01 00 00       	call   f0104cab <sched_yield>

f0104b2c <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f0104b2c:	6a 00                	push   $0x0
f0104b2e:	6a 00                	push   $0x0
f0104b30:	e9 85 00 00 00       	jmp    f0104bba <_alltraps>
f0104b35:	90                   	nop

f0104b36 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0104b36:	6a 00                	push   $0x0
f0104b38:	6a 01                	push   $0x1
f0104b3a:	eb 7e                	jmp    f0104bba <_alltraps>

f0104b3c <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f0104b3c:	6a 00                	push   $0x0
f0104b3e:	6a 02                	push   $0x2
f0104b40:	eb 78                	jmp    f0104bba <_alltraps>

f0104b42 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f0104b42:	6a 00                	push   $0x0
f0104b44:	6a 03                	push   $0x3
f0104b46:	eb 72                	jmp    f0104bba <_alltraps>

f0104b48 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f0104b48:	6a 00                	push   $0x0
f0104b4a:	6a 04                	push   $0x4
f0104b4c:	eb 6c                	jmp    f0104bba <_alltraps>

f0104b4e <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f0104b4e:	6a 00                	push   $0x0
f0104b50:	6a 05                	push   $0x5
f0104b52:	eb 66                	jmp    f0104bba <_alltraps>

f0104b54 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f0104b54:	6a 00                	push   $0x0
f0104b56:	6a 06                	push   $0x6
f0104b58:	eb 60                	jmp    f0104bba <_alltraps>

f0104b5a <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f0104b5a:	6a 00                	push   $0x0
f0104b5c:	6a 07                	push   $0x7
f0104b5e:	eb 5a                	jmp    f0104bba <_alltraps>

f0104b60 <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f0104b60:	6a 08                	push   $0x8
f0104b62:	eb 56                	jmp    f0104bba <_alltraps>

f0104b64 <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f0104b64:	6a 0a                	push   $0xa
f0104b66:	eb 52                	jmp    f0104bba <_alltraps>

f0104b68 <t_segnp>:
TRAPHANDLER_NOEC(t_segnp, T_SEGNP)
f0104b68:	6a 00                	push   $0x0
f0104b6a:	6a 0b                	push   $0xb
f0104b6c:	eb 4c                	jmp    f0104bba <_alltraps>

f0104b6e <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f0104b6e:	6a 0c                	push   $0xc
f0104b70:	eb 48                	jmp    f0104bba <_alltraps>

f0104b72 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f0104b72:	6a 0d                	push   $0xd
f0104b74:	eb 44                	jmp    f0104bba <_alltraps>

f0104b76 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f0104b76:	6a 0e                	push   $0xe
f0104b78:	eb 40                	jmp    f0104bba <_alltraps>

f0104b7a <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f0104b7a:	6a 00                	push   $0x0
f0104b7c:	6a 10                	push   $0x10
f0104b7e:	eb 3a                	jmp    f0104bba <_alltraps>

f0104b80 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f0104b80:	6a 11                	push   $0x11
f0104b82:	eb 36                	jmp    f0104bba <_alltraps>

f0104b84 <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f0104b84:	6a 00                	push   $0x0
f0104b86:	6a 12                	push   $0x12
f0104b88:	eb 30                	jmp    f0104bba <_alltraps>

f0104b8a <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f0104b8a:	6a 00                	push   $0x0
f0104b8c:	6a 13                	push   $0x13
f0104b8e:	eb 2a                	jmp    f0104bba <_alltraps>

f0104b90 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f0104b90:	6a 00                	push   $0x0
f0104b92:	6a 30                	push   $0x30
f0104b94:	eb 24                	jmp    f0104bba <_alltraps>

f0104b96 <irq_timer>:

TRAPHANDLER_NOEC(irq_timer, IRQ_TIMER + IRQ_OFFSET)
f0104b96:	6a 00                	push   $0x0
f0104b98:	6a 20                	push   $0x20
f0104b9a:	eb 1e                	jmp    f0104bba <_alltraps>

f0104b9c <irq_kbd>:
TRAPHANDLER_NOEC(irq_kbd, IRQ_KBD + IRQ_OFFSET)
f0104b9c:	6a 00                	push   $0x0
f0104b9e:	6a 21                	push   $0x21
f0104ba0:	eb 18                	jmp    f0104bba <_alltraps>

f0104ba2 <irq_serial>:
TRAPHANDLER_NOEC(irq_serial, IRQ_SERIAL + IRQ_OFFSET)
f0104ba2:	6a 00                	push   $0x0
f0104ba4:	6a 24                	push   $0x24
f0104ba6:	eb 12                	jmp    f0104bba <_alltraps>

f0104ba8 <irq_spurious>:
TRAPHANDLER_NOEC(irq_spurious, IRQ_SPURIOUS + IRQ_OFFSET)
f0104ba8:	6a 00                	push   $0x0
f0104baa:	6a 27                	push   $0x27
f0104bac:	eb 0c                	jmp    f0104bba <_alltraps>

f0104bae <irq_ide>:
TRAPHANDLER_NOEC(irq_ide, IRQ_IDE + IRQ_OFFSET)
f0104bae:	6a 00                	push   $0x0
f0104bb0:	6a 2e                	push   $0x2e
f0104bb2:	eb 06                	jmp    f0104bba <_alltraps>

f0104bb4 <irq_error>:
TRAPHANDLER_NOEC(irq_error, IRQ_ERROR + IRQ_OFFSET)
f0104bb4:	6a 00                	push   $0x0
f0104bb6:	6a 33                	push   $0x33
f0104bb8:	eb 00                	jmp    f0104bba <_alltraps>

f0104bba <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
// 构造trapframe
	pushl %ds
f0104bba:	1e                   	push   %ds
	pushl %es
f0104bbb:	06                   	push   %es
	pushal
f0104bbc:	60                   	pusha  
	// 将GD_KD加载到ds和es寄存器
	movl %ss, %eax
f0104bbd:	8c d0                	mov    %ss,%eax
	movw %ax, %ds
f0104bbf:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104bc1:	8e c0                	mov    %eax,%es
	// 传递trapframe指针给trap参数
	pushl %esp
f0104bc3:	54                   	push   %esp
	// 调用trap
	call trap
f0104bc4:	e8 19 fd ff ff       	call   f01048e2 <trap>

f0104bc9 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104bc9:	55                   	push   %ebp
f0104bca:	89 e5                	mov    %esp,%ebp
f0104bcc:	83 ec 18             	sub    $0x18,%esp
	int i;
	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104bcf:	8b 15 48 62 22 f0    	mov    0xf0226248,%edx
f0104bd5:	8b 42 54             	mov    0x54(%edx),%eax
f0104bd8:	83 e8 02             	sub    $0x2,%eax
f0104bdb:	83 f8 01             	cmp    $0x1,%eax
f0104bde:	76 43                	jbe    f0104c23 <sched_halt+0x5a>
	for (i = 0; i < NENV; i++) {
f0104be0:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104be5:	8b 8a d0 00 00 00    	mov    0xd0(%edx),%ecx
f0104beb:	83 e9 02             	sub    $0x2,%ecx
f0104bee:	83 f9 01             	cmp    $0x1,%ecx
f0104bf1:	76 0f                	jbe    f0104c02 <sched_halt+0x39>
	for (i = 0; i < NENV; i++) {
f0104bf3:	83 c0 01             	add    $0x1,%eax
f0104bf6:	83 c2 7c             	add    $0x7c,%edx
f0104bf9:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104bfe:	75 e5                	jne    f0104be5 <sched_halt+0x1c>
f0104c00:	eb 07                	jmp    f0104c09 <sched_halt+0x40>
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0104c02:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104c07:	75 1a                	jne    f0104c23 <sched_halt+0x5a>
		cprintf("No runnable environments in the system!\n");
f0104c09:	c7 04 24 30 85 10 f0 	movl   $0xf0108530,(%esp)
f0104c10:	e8 b4 f3 ff ff       	call   f0103fc9 <cprintf>
		while (1)
			monitor(NULL);
f0104c15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104c1c:	e8 af bd ff ff       	call   f01009d0 <monitor>
f0104c21:	eb f2                	jmp    f0104c15 <sched_halt+0x4c>
	}
	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104c23:	e8 2b 1b 00 00       	call   f0106753 <cpunum>
f0104c28:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c2b:	c7 80 28 70 22 f0 00 	movl   $0x0,-0xfdd8fd8(%eax)
f0104c32:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104c35:	a1 8c 6e 22 f0       	mov    0xf0226e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104c3a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104c3f:	77 20                	ja     f0104c61 <sched_halt+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104c41:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104c45:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0104c4c:	f0 
f0104c4d:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
f0104c54:	00 
f0104c55:	c7 04 24 59 85 10 f0 	movl   $0xf0108559,(%esp)
f0104c5c:	e8 df b3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104c61:	05 00 00 00 10       	add    $0x10000000,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104c66:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104c69:	e8 e5 1a 00 00       	call   f0106753 <cpunum>
f0104c6e:	6b d0 74             	imul   $0x74,%eax,%edx
f0104c71:	81 c2 20 70 22 f0    	add    $0xf0227020,%edx
	asm volatile("lock; xchgl %0, %1" :
f0104c77:	b8 02 00 00 00       	mov    $0x2,%eax
f0104c7c:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
	spin_unlock(&kernel_lock);
f0104c80:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104c87:	e8 1b 1e 00 00       	call   f0106aa7 <spin_unlock>
	asm volatile("pause");
f0104c8c:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104c8e:	e8 c0 1a 00 00       	call   f0106753 <cpunum>
f0104c93:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f0104c96:	8b 80 30 70 22 f0    	mov    -0xfdd8fd0(%eax),%eax
f0104c9c:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104ca1:	89 c4                	mov    %eax,%esp
f0104ca3:	6a 00                	push   $0x0
f0104ca5:	6a 00                	push   $0x0
f0104ca7:	fb                   	sti    
f0104ca8:	f4                   	hlt    
}
f0104ca9:	c9                   	leave  
f0104caa:	c3                   	ret    

f0104cab <sched_yield>:
{
f0104cab:	55                   	push   %ebp
f0104cac:	89 e5                	mov    %esp,%ebp
f0104cae:	56                   	push   %esi
f0104caf:	53                   	push   %ebx
f0104cb0:	83 ec 10             	sub    $0x10,%esp
	int curenv_index = (curenv?(curenv - envs + 1):0);	
f0104cb3:	e8 9b 1a 00 00       	call   f0106753 <cpunum>
f0104cb8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cbb:	be 00 00 00 00       	mov    $0x0,%esi
f0104cc0:	83 b8 28 70 22 f0 00 	cmpl   $0x0,-0xfdd8fd8(%eax)
f0104cc7:	74 20                	je     f0104ce9 <sched_yield+0x3e>
f0104cc9:	e8 85 1a 00 00       	call   f0106753 <cpunum>
f0104cce:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cd1:	8b b0 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%esi
f0104cd7:	2b 35 48 62 22 f0    	sub    0xf0226248,%esi
f0104cdd:	c1 fe 02             	sar    $0x2,%esi
f0104ce0:	69 f6 df 7b ef bd    	imul   $0xbdef7bdf,%esi,%esi
f0104ce6:	83 c6 01             	add    $0x1,%esi
		idle = envs + ((curenv_index + offset) % NENV);
f0104ce9:	8b 1d 48 62 22 f0    	mov    0xf0226248,%ebx
	for(offset = 0; offset < NENV; ++offset){
f0104cef:	b8 00 00 00 00       	mov    $0x0,%eax
f0104cf4:	8d 14 30             	lea    (%eax,%esi,1),%edx
		idle = envs + ((curenv_index + offset) % NENV);
f0104cf7:	89 d1                	mov    %edx,%ecx
f0104cf9:	c1 f9 1f             	sar    $0x1f,%ecx
f0104cfc:	c1 e9 16             	shr    $0x16,%ecx
f0104cff:	01 ca                	add    %ecx,%edx
f0104d01:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0104d07:	29 ca                	sub    %ecx,%edx
f0104d09:	6b d2 7c             	imul   $0x7c,%edx,%edx
		if(idle && ENV_RUNNABLE == idle->env_status){
f0104d0c:	01 da                	add    %ebx,%edx
f0104d0e:	74 0e                	je     f0104d1e <sched_yield+0x73>
f0104d10:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104d14:	75 08                	jne    f0104d1e <sched_yield+0x73>
			env_run(idle);
f0104d16:	89 14 24             	mov    %edx,(%esp)
f0104d19:	e8 54 f0 ff ff       	call   f0103d72 <env_run>
	for(offset = 0; offset < NENV; ++offset){
f0104d1e:	83 c0 01             	add    $0x1,%eax
f0104d21:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104d26:	75 cc                	jne    f0104cf4 <sched_yield+0x49>
	if(curenv && ENV_RUNNING == curenv->env_status)
f0104d28:	e8 26 1a 00 00       	call   f0106753 <cpunum>
f0104d2d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d30:	83 b8 28 70 22 f0 00 	cmpl   $0x0,-0xfdd8fd8(%eax)
f0104d37:	74 2a                	je     f0104d63 <sched_yield+0xb8>
f0104d39:	e8 15 1a 00 00       	call   f0106753 <cpunum>
f0104d3e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d41:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0104d47:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104d4b:	75 16                	jne    f0104d63 <sched_yield+0xb8>
		env_run(curenv);
f0104d4d:	e8 01 1a 00 00       	call   f0106753 <cpunum>
f0104d52:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d55:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0104d5b:	89 04 24             	mov    %eax,(%esp)
f0104d5e:	e8 0f f0 ff ff       	call   f0103d72 <env_run>
		sched_halt();
f0104d63:	e8 61 fe ff ff       	call   f0104bc9 <sched_halt>
}
f0104d68:	83 c4 10             	add    $0x10,%esp
f0104d6b:	5b                   	pop    %ebx
f0104d6c:	5e                   	pop    %esi
f0104d6d:	5d                   	pop    %ebp
f0104d6e:	c3                   	ret    
f0104d6f:	90                   	nop

f0104d70 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104d70:	55                   	push   %ebp
f0104d71:	89 e5                	mov    %esp,%ebp
f0104d73:	57                   	push   %edi
f0104d74:	56                   	push   %esi
f0104d75:	53                   	push   %ebx
f0104d76:	83 ec 2c             	sub    $0x2c,%esp
f0104d79:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch(syscallno){
f0104d7c:	83 f8 0c             	cmp    $0xc,%eax
f0104d7f:	0f 87 fe 05 00 00    	ja     f0105383 <syscall+0x613>
f0104d85:	ff 24 85 a0 85 10 f0 	jmp    *-0xfef7a60(,%eax,4)
	user_mem_assert(curenv, (void *)s, len, 0);
f0104d8c:	e8 c2 19 00 00       	call   f0106753 <cpunum>
f0104d91:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104d98:	00 
f0104d99:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104d9c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104da3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104da7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104daa:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0104db0:	89 04 24             	mov    %eax,(%esp)
f0104db3:	e8 e3 e7 ff ff       	call   f010359b <user_mem_assert>
	cprintf("%.*s", len, s);
f0104db8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104dbb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104dbf:	8b 45 10             	mov    0x10(%ebp),%eax
f0104dc2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104dc6:	c7 04 24 66 85 10 f0 	movl   $0xf0108566,(%esp)
f0104dcd:	e8 f7 f1 ff ff       	call   f0103fc9 <cprintf>
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
f0104dd2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104dd7:	e9 b3 05 00 00       	jmp    f010538f <syscall+0x61f>
	return cons_getc();
f0104ddc:	e8 74 b8 ff ff       	call   f0100655 <cons_getc>
		case SYS_cgetc:
			return sys_cgetc();
f0104de1:	e9 a9 05 00 00       	jmp    f010538f <syscall+0x61f>
	return curenv->env_id;
f0104de6:	e8 68 19 00 00       	call   f0106753 <cpunum>
f0104deb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dee:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0104df4:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_getenvid:
			return sys_getenvid();
f0104df7:	e9 93 05 00 00       	jmp    f010538f <syscall+0x61f>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104dfc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e03:	00 
f0104e04:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e0b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e0e:	89 04 24             	mov    %eax,(%esp)
f0104e11:	e8 7a e8 ff ff       	call   f0103690 <envid2env>
		return r;
f0104e16:	89 c2                	mov    %eax,%edx
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104e18:	85 c0                	test   %eax,%eax
f0104e1a:	78 6e                	js     f0104e8a <syscall+0x11a>
	if (e == curenv)
f0104e1c:	e8 32 19 00 00       	call   f0106753 <cpunum>
f0104e21:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e24:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e27:	39 90 28 70 22 f0    	cmp    %edx,-0xfdd8fd8(%eax)
f0104e2d:	75 23                	jne    f0104e52 <syscall+0xe2>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104e2f:	e8 1f 19 00 00       	call   f0106753 <cpunum>
f0104e34:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e37:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0104e3d:	8b 40 48             	mov    0x48(%eax),%eax
f0104e40:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e44:	c7 04 24 6b 85 10 f0 	movl   $0xf010856b,(%esp)
f0104e4b:	e8 79 f1 ff ff       	call   f0103fc9 <cprintf>
f0104e50:	eb 28                	jmp    f0104e7a <syscall+0x10a>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104e52:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104e55:	e8 f9 18 00 00       	call   f0106753 <cpunum>
f0104e5a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104e5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e61:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0104e67:	8b 40 48             	mov    0x48(%eax),%eax
f0104e6a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e6e:	c7 04 24 86 85 10 f0 	movl   $0xf0108586,(%esp)
f0104e75:	e8 4f f1 ff ff       	call   f0103fc9 <cprintf>
	env_destroy(e);
f0104e7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e7d:	89 04 24             	mov    %eax,(%esp)
f0104e80:	e8 4c ee ff ff       	call   f0103cd1 <env_destroy>
	return 0;
f0104e85:	ba 00 00 00 00       	mov    $0x0,%edx
		case SYS_env_destroy:
			return sys_env_destroy(a1);
f0104e8a:	89 d0                	mov    %edx,%eax
f0104e8c:	e9 fe 04 00 00       	jmp    f010538f <syscall+0x61f>
	sched_yield();
f0104e91:	e8 15 fe ff ff       	call   f0104cab <sched_yield>
	int result = env_alloc(&new_env, curenv->env_id);
f0104e96:	e8 b8 18 00 00       	call   f0106753 <cpunum>
f0104e9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e9e:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0104ea4:	8b 40 48             	mov    0x48(%eax),%eax
f0104ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104eab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104eae:	89 04 24             	mov    %eax,(%esp)
f0104eb1:	e8 eb e8 ff ff       	call   f01037a1 <env_alloc>
		return result;
f0104eb6:	89 c2                	mov    %eax,%edx
	if(result < 0)
f0104eb8:	85 c0                	test   %eax,%eax
f0104eba:	78 2e                	js     f0104eea <syscall+0x17a>
	new_env->env_tf = curenv->env_tf;
f0104ebc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104ebf:	e8 8f 18 00 00       	call   f0106753 <cpunum>
f0104ec4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ec7:	8b b0 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%esi
f0104ecd:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104ed2:	89 df                	mov    %ebx,%edi
f0104ed4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	new_env->env_status = ENV_NOT_RUNNABLE;
f0104ed6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ed9:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	new_env->env_tf.tf_regs.reg_eax = 0;
f0104ee0:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return new_env->env_id;
f0104ee7:	8b 50 48             	mov    0x48(%eax),%edx
		case SYS_yield:
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
f0104eea:	89 d0                	mov    %edx,%eax
f0104eec:	e9 9e 04 00 00       	jmp    f010538f <syscall+0x61f>
	if(status < ENV_FREE || status > ENV_NOT_RUNNABLE)
f0104ef1:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104ef5:	77 35                	ja     f0104f2c <syscall+0x1bc>
	int result = envid2env(envid, &env, 1);
f0104ef7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104efe:	00 
f0104eff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f02:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f06:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f09:	89 04 24             	mov    %eax,(%esp)
f0104f0c:	e8 7f e7 ff ff       	call   f0103690 <envid2env>
	if(result < 0)
f0104f11:	85 c0                	test   %eax,%eax
f0104f13:	0f 88 76 04 00 00    	js     f010538f <syscall+0x61f>
	env->env_status = status;
f0104f19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f1c:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104f1f:	89 48 54             	mov    %ecx,0x54(%eax)
	return 0;	
f0104f22:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f27:	e9 63 04 00 00       	jmp    f010538f <syscall+0x61f>
		return -E_INVAL;
f0104f2c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f31:	e9 59 04 00 00       	jmp    f010538f <syscall+0x61f>
	int result = envid2env(envid, &env, 1);
f0104f36:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f3d:	00 
f0104f3e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f45:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f48:	89 04 24             	mov    %eax,(%esp)
f0104f4b:	e8 40 e7 ff ff       	call   f0103690 <envid2env>
	if(result < 0)
f0104f50:	85 c0                	test   %eax,%eax
f0104f52:	0f 88 37 04 00 00    	js     f010538f <syscall+0x61f>
	env->env_pgfault_upcall = func;
f0104f58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f5b:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f5e:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f0104f61:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f66:	e9 24 04 00 00       	jmp    f010538f <syscall+0x61f>
	int result = envid2env(envid, &env, 1);
f0104f6b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f72:	00 
f0104f73:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f76:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f7a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f7d:	89 04 24             	mov    %eax,(%esp)
f0104f80:	e8 0b e7 ff ff       	call   f0103690 <envid2env>
	if(result < 0)
f0104f85:	85 c0                	test   %eax,%eax
f0104f87:	78 65                	js     f0104fee <syscall+0x27e>
	if((unsigned)va >= UTOP || (unsigned)va & (PGSIZE - 1))
f0104f89:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104f90:	77 60                	ja     f0104ff2 <syscall+0x282>
f0104f92:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104f99:	75 5e                	jne    f0104ff9 <syscall+0x289>
	if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & (~(PTE_P | PTE_U | PTE_W | PTE_AVAIL))))
f0104f9b:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f9e:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104fa3:	83 f8 05             	cmp    $0x5,%eax
f0104fa6:	75 58                	jne    f0105000 <syscall+0x290>
	struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f0104fa8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104faf:	e8 7c c1 ff ff       	call   f0101130 <page_alloc>
f0104fb4:	89 c3                	mov    %eax,%ebx
	if(!new_page)
f0104fb6:	85 c0                	test   %eax,%eax
f0104fb8:	74 4d                	je     f0105007 <syscall+0x297>
	result = page_insert(env->env_pgdir, new_page, va, perm);
f0104fba:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104fc1:	8b 45 10             	mov    0x10(%ebp),%eax
f0104fc4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104fc8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104fcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104fcf:	8b 40 60             	mov    0x60(%eax),%eax
f0104fd2:	89 04 24             	mov    %eax,(%esp)
f0104fd5:	e8 31 c4 ff ff       	call   f010140b <page_insert>
f0104fda:	89 c6                	mov    %eax,%esi
	return result;
f0104fdc:	89 c2                	mov    %eax,%edx
	if(result < 0)
f0104fde:	85 c0                	test   %eax,%eax
f0104fe0:	79 2a                	jns    f010500c <syscall+0x29c>
		page_free(new_page);
f0104fe2:	89 1c 24             	mov    %ebx,(%esp)
f0104fe5:	e8 d1 c1 ff ff       	call   f01011bb <page_free>
	return result;
f0104fea:	89 f2                	mov    %esi,%edx
f0104fec:	eb 1e                	jmp    f010500c <syscall+0x29c>
		return result;
f0104fee:	89 c2                	mov    %eax,%edx
f0104ff0:	eb 1a                	jmp    f010500c <syscall+0x29c>
		return -E_INVAL;
f0104ff2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104ff7:	eb 13                	jmp    f010500c <syscall+0x29c>
f0104ff9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104ffe:	eb 0c                	jmp    f010500c <syscall+0x29c>
		return -E_INVAL;
f0105000:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105005:	eb 05                	jmp    f010500c <syscall+0x29c>
		return -E_NO_MEM;
f0105007:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
		case SYS_env_set_status:
			return sys_env_set_status(a1, (int)a2);	
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void *)a2);
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void *)a2, (int)a3);
f010500c:	89 d0                	mov    %edx,%eax
f010500e:	e9 7c 03 00 00       	jmp    f010538f <syscall+0x61f>
	int result = envid2env(srcenvid, &src_env, 1);
f0105013:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010501a:	00 
f010501b:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010501e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105022:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105025:	89 04 24             	mov    %eax,(%esp)
f0105028:	e8 63 e6 ff ff       	call   f0103690 <envid2env>
		return result;
f010502d:	89 c2                	mov    %eax,%edx
	if(result < 0)
f010502f:	85 c0                	test   %eax,%eax
f0105031:	0f 88 fa 00 00 00    	js     f0105131 <syscall+0x3c1>
	result = envid2env(dstenvid, &dst_env, 1);
f0105037:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010503e:	00 
f010503f:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105042:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105046:	8b 45 14             	mov    0x14(%ebp),%eax
f0105049:	89 04 24             	mov    %eax,(%esp)
f010504c:	e8 3f e6 ff ff       	call   f0103690 <envid2env>
	if(result < 0)
f0105051:	85 c0                	test   %eax,%eax
f0105053:	0f 88 a5 00 00 00    	js     f01050fe <syscall+0x38e>
	if((unsigned)srcva >= UTOP || (unsigned)srcva & (PGSIZE - 1) ||
f0105059:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105060:	0f 87 9c 00 00 00    	ja     f0105102 <syscall+0x392>
f0105066:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010506d:	0f 85 96 00 00 00    	jne    f0105109 <syscall+0x399>
f0105073:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010507a:	0f 87 90 00 00 00    	ja     f0105110 <syscall+0x3a0>
		(unsigned)dstva >= UTOP || (unsigned)dstva & (PGSIZE - 1))
f0105080:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0105087:	0f 85 8a 00 00 00    	jne    f0105117 <syscall+0x3a7>
	struct PageInfo *page_info = page_lookup(src_env->env_pgdir, srcva, &page_table_entry);
f010508d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105090:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105094:	8b 45 10             	mov    0x10(%ebp),%eax
f0105097:	89 44 24 04          	mov    %eax,0x4(%esp)
f010509b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010509e:	8b 40 60             	mov    0x60(%eax),%eax
f01050a1:	89 04 24             	mov    %eax,(%esp)
f01050a4:	e8 63 c2 ff ff       	call   f010130c <page_lookup>
f01050a9:	89 c3                	mov    %eax,%ebx
	if(!page_info)
f01050ab:	85 c0                	test   %eax,%eax
f01050ad:	74 6f                	je     f010511e <syscall+0x3ae>
	if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & (~(PTE_P | PTE_U | PTE_W | PTE_AVAIL))))
f01050af:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01050b2:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01050b7:	83 f8 05             	cmp    $0x5,%eax
f01050ba:	75 69                	jne    f0105125 <syscall+0x3b5>
	if((perm & PTE_W) && !(*page_table_entry & PTE_W))
f01050bc:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01050c0:	74 08                	je     f01050ca <syscall+0x35a>
f01050c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050c5:	f6 00 02             	testb  $0x2,(%eax)
f01050c8:	74 62                	je     f010512c <syscall+0x3bc>
	result = page_insert(dst_env->env_pgdir, page_info, dstva, perm);
f01050ca:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01050cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01050d1:	8b 45 18             	mov    0x18(%ebp),%eax
f01050d4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01050d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01050dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050df:	8b 40 60             	mov    0x60(%eax),%eax
f01050e2:	89 04 24             	mov    %eax,(%esp)
f01050e5:	e8 21 c3 ff ff       	call   f010140b <page_insert>
f01050ea:	89 c6                	mov    %eax,%esi
	return result;
f01050ec:	89 c2                	mov    %eax,%edx
	if(result < 0)
f01050ee:	85 c0                	test   %eax,%eax
f01050f0:	79 3f                	jns    f0105131 <syscall+0x3c1>
		page_free(page_info);
f01050f2:	89 1c 24             	mov    %ebx,(%esp)
f01050f5:	e8 c1 c0 ff ff       	call   f01011bb <page_free>
	return result;
f01050fa:	89 f2                	mov    %esi,%edx
f01050fc:	eb 33                	jmp    f0105131 <syscall+0x3c1>
		return result;
f01050fe:	89 c2                	mov    %eax,%edx
f0105100:	eb 2f                	jmp    f0105131 <syscall+0x3c1>
		return -E_INVAL;
f0105102:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105107:	eb 28                	jmp    f0105131 <syscall+0x3c1>
f0105109:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010510e:	eb 21                	jmp    f0105131 <syscall+0x3c1>
f0105110:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105115:	eb 1a                	jmp    f0105131 <syscall+0x3c1>
f0105117:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010511c:	eb 13                	jmp    f0105131 <syscall+0x3c1>
		return -E_INVAL;
f010511e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105123:	eb 0c                	jmp    f0105131 <syscall+0x3c1>
		return -E_INVAL;
f0105125:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010512a:	eb 05                	jmp    f0105131 <syscall+0x3c1>
		return -E_INVAL;
f010512c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
		case SYS_page_map:
			return sys_page_map(a1, (void *)a2, a3, (void *)a4, (int)a5);
f0105131:	89 d0                	mov    %edx,%eax
f0105133:	e9 57 02 00 00       	jmp    f010538f <syscall+0x61f>
	int result = envid2env(envid, &env, 1);
f0105138:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010513f:	00 
f0105140:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105143:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105147:	8b 45 0c             	mov    0xc(%ebp),%eax
f010514a:	89 04 24             	mov    %eax,(%esp)
f010514d:	e8 3e e5 ff ff       	call   f0103690 <envid2env>
	if(result < 0)
f0105152:	85 c0                	test   %eax,%eax
f0105154:	0f 88 35 02 00 00    	js     f010538f <syscall+0x61f>
	if((unsigned)va >= UTOP || (unsigned)va & (PGSIZE - 1))
f010515a:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105161:	77 28                	ja     f010518b <syscall+0x41b>
f0105163:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010516a:	75 29                	jne    f0105195 <syscall+0x425>
	page_remove(env->env_pgdir, va);
f010516c:	8b 45 10             	mov    0x10(%ebp),%eax
f010516f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105173:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105176:	8b 40 60             	mov    0x60(%eax),%eax
f0105179:	89 04 24             	mov    %eax,(%esp)
f010517c:	e8 3a c2 ff ff       	call   f01013bb <page_remove>
	return 0;
f0105181:	b8 00 00 00 00       	mov    $0x0,%eax
f0105186:	e9 04 02 00 00       	jmp    f010538f <syscall+0x61f>
		return -E_INVAL;
f010518b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105190:	e9 fa 01 00 00       	jmp    f010538f <syscall+0x61f>
f0105195:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void *)a2);
f010519a:	e9 f0 01 00 00       	jmp    f010538f <syscall+0x61f>
	int result = envid2env(envid, &target_env, 0);
f010519f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01051a6:	00 
f01051a7:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01051aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01051b1:	89 04 24             	mov    %eax,(%esp)
f01051b4:	e8 d7 e4 ff ff       	call   f0103690 <envid2env>
	if(result < 0)
f01051b9:	85 c0                	test   %eax,%eax
f01051bb:	0f 88 2e 01 00 00    	js     f01052ef <syscall+0x57f>
	if(!target_env->env_ipc_recving || target_env->env_ipc_from)
f01051c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051c4:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01051c8:	0f 84 25 01 00 00    	je     f01052f3 <syscall+0x583>
f01051ce:	8b 58 74             	mov    0x74(%eax),%ebx
f01051d1:	85 db                	test   %ebx,%ebx
f01051d3:	0f 85 21 01 00 00    	jne    f01052fa <syscall+0x58a>
	if(srcva && (unsigned)srcva < UTOP){
f01051d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01051dc:	83 e8 01             	sub    $0x1,%eax
f01051df:	3d fe ff bf ee       	cmp    $0xeebffffe,%eax
f01051e4:	0f 87 d1 00 00 00    	ja     f01052bb <syscall+0x54b>
		if((unsigned)srcva & (PGSIZE - 1))
f01051ea:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01051f1:	0f 85 0a 01 00 00    	jne    f0105301 <syscall+0x591>
		if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & (~(PTE_P | PTE_U | PTE_W | PTE_AVAIL))))
f01051f7:	8b 45 18             	mov    0x18(%ebp),%eax
f01051fa:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01051ff:	83 f8 05             	cmp    $0x5,%eax
f0105202:	0f 85 00 01 00 00    	jne    f0105308 <syscall+0x598>
		if(perm & PTE_W)
f0105208:	8b 45 18             	mov    0x18(%ebp),%eax
f010520b:	83 e0 02             	and    $0x2,%eax
		unsigned check_perm = PTE_U | PTE_P;
f010520e:	83 f8 01             	cmp    $0x1,%eax
f0105211:	19 f6                	sbb    %esi,%esi
f0105213:	83 e6 fe             	and    $0xfffffffe,%esi
f0105216:	83 c6 07             	add    $0x7,%esi
		if(user_mem_check(curenv, srcva, PGSIZE, check_perm) < 0)
f0105219:	e8 35 15 00 00       	call   f0106753 <cpunum>
f010521e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105222:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0105229:	00 
f010522a:	8b 7d 14             	mov    0x14(%ebp),%edi
f010522d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105231:	6b c0 74             	imul   $0x74,%eax,%eax
f0105234:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f010523a:	89 04 24             	mov    %eax,(%esp)
f010523d:	e8 7f e2 ff ff       	call   f01034c1 <user_mem_check>
f0105242:	85 c0                	test   %eax,%eax
f0105244:	0f 88 c5 00 00 00    	js     f010530f <syscall+0x59f>
		if(target_env->env_ipc_dstva){
f010524a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010524d:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
f0105251:	74 68                	je     f01052bb <syscall+0x54b>
			if (!(page_info = page_lookup(curenv->env_pgdir, srcva, &pte)))
f0105253:	e8 fb 14 00 00       	call   f0106753 <cpunum>
f0105258:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010525b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010525f:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0105262:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105266:	6b c0 74             	imul   $0x74,%eax,%eax
f0105269:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f010526f:	8b 40 60             	mov    0x60(%eax),%eax
f0105272:	89 04 24             	mov    %eax,(%esp)
f0105275:	e8 92 c0 ff ff       	call   f010130c <page_lookup>
f010527a:	85 c0                	test   %eax,%eax
f010527c:	74 2f                	je     f01052ad <syscall+0x53d>
			result = page_insert(target_env->env_pgdir, page_info, target_env->env_ipc_dstva, perm);
f010527e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105281:	8b 7d 18             	mov    0x18(%ebp),%edi
f0105284:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105288:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f010528b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010528f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105293:	8b 42 60             	mov    0x60(%edx),%eax
f0105296:	89 04 24             	mov    %eax,(%esp)
f0105299:	e8 6d c1 ff ff       	call   f010140b <page_insert>
			if(result < 0)
f010529e:	85 c0                	test   %eax,%eax
f01052a0:	78 12                	js     f01052b4 <syscall+0x544>
			target_env->env_ipc_perm = perm;
f01052a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052a5:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01052a8:	89 48 78             	mov    %ecx,0x78(%eax)
f01052ab:	eb 0e                	jmp    f01052bb <syscall+0x54b>
				return -E_INVAL;
f01052ad:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01052b2:	eb 60                	jmp    f0105314 <syscall+0x5a4>
				return -E_NO_MEM;
f01052b4:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01052b9:	eb 59                	jmp    f0105314 <syscall+0x5a4>
	target_env->env_ipc_value = value;
f01052bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01052be:	8b 45 10             	mov    0x10(%ebp),%eax
f01052c1:	89 46 70             	mov    %eax,0x70(%esi)
	target_env->env_ipc_from = curenv->env_id;
f01052c4:	e8 8a 14 00 00       	call   f0106753 <cpunum>
f01052c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01052cc:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f01052d2:	8b 40 48             	mov    0x48(%eax),%eax
f01052d5:	89 46 74             	mov    %eax,0x74(%esi)
	target_env->env_status = ENV_RUNNABLE;
f01052d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052db:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	target_env->env_ipc_recving = false;
f01052e2:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	target_env->env_tf.tf_regs.reg_eax = 0;
f01052e6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f01052ed:	eb 25                	jmp    f0105314 <syscall+0x5a4>
		return result;
f01052ef:	89 c3                	mov    %eax,%ebx
f01052f1:	eb 21                	jmp    f0105314 <syscall+0x5a4>
		return -E_IPC_NOT_RECV;
f01052f3:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f01052f8:	eb 1a                	jmp    f0105314 <syscall+0x5a4>
f01052fa:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f01052ff:	eb 13                	jmp    f0105314 <syscall+0x5a4>
			return -E_INVAL;
f0105301:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105306:	eb 0c                	jmp    f0105314 <syscall+0x5a4>
			return -E_INVAL;
f0105308:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010530d:	eb 05                	jmp    f0105314 <syscall+0x5a4>
			return -E_INVAL;
f010530f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0105314:	89 d8                	mov    %ebx,%eax
f0105316:	eb 77                	jmp    f010538f <syscall+0x61f>
	if(dstva && (unsigned)dstva < UTOP && (unsigned)dstva & (PGSIZE - 1))
f0105318:	8b 45 0c             	mov    0xc(%ebp),%eax
f010531b:	83 e8 01             	sub    $0x1,%eax
f010531e:	3d fe ff bf ee       	cmp    $0xeebffffe,%eax
f0105323:	77 09                	ja     f010532e <syscall+0x5be>
f0105325:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f010532c:	75 5c                	jne    f010538a <syscall+0x61a>
	curenv->env_ipc_recving = true;
f010532e:	e8 20 14 00 00       	call   f0106753 <cpunum>
f0105333:	6b c0 74             	imul   $0x74,%eax,%eax
f0105336:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f010533c:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f0105340:	e8 0e 14 00 00       	call   f0106753 <cpunum>
f0105345:	6b c0 74             	imul   $0x74,%eax,%eax
f0105348:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f010534e:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	curenv->env_ipc_dstva = dstva;
f0105355:	e8 f9 13 00 00       	call   f0106753 <cpunum>
f010535a:	6b c0 74             	imul   $0x74,%eax,%eax
f010535d:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0105363:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105366:	89 48 6c             	mov    %ecx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0105369:	e8 e5 13 00 00       	call   f0106753 <cpunum>
f010536e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105371:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0105377:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f010537e:	e8 28 f9 ff ff       	call   f0104cab <sched_yield>
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		default:
			return -E_INVAL;
f0105383:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105388:	eb 05                	jmp    f010538f <syscall+0x61f>
			return sys_ipc_recv((void *)a1);
f010538a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f010538f:	83 c4 2c             	add    $0x2c,%esp
f0105392:	5b                   	pop    %ebx
f0105393:	5e                   	pop    %esi
f0105394:	5f                   	pop    %edi
f0105395:	5d                   	pop    %ebp
f0105396:	c3                   	ret    

f0105397 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105397:	55                   	push   %ebp
f0105398:	89 e5                	mov    %esp,%ebp
f010539a:	57                   	push   %edi
f010539b:	56                   	push   %esi
f010539c:	53                   	push   %ebx
f010539d:	83 ec 14             	sub    $0x14,%esp
f01053a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01053a3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01053a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01053a9:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01053ac:	8b 1a                	mov    (%edx),%ebx
f01053ae:	8b 01                	mov    (%ecx),%eax
f01053b0:	89 45 f0             	mov    %eax,-0x10(%ebp)

	while (l <= r) {
f01053b3:	39 c3                	cmp    %eax,%ebx
f01053b5:	0f 8f 9a 00 00 00    	jg     f0105455 <stab_binsearch+0xbe>
	int l = *region_left, r = *region_right, any_matches = 0;
f01053bb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f01053c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01053c5:	01 d8                	add    %ebx,%eax
f01053c7:	89 c7                	mov    %eax,%edi
f01053c9:	c1 ef 1f             	shr    $0x1f,%edi
f01053cc:	01 c7                	add    %eax,%edi
f01053ce:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01053d0:	39 df                	cmp    %ebx,%edi
f01053d2:	0f 8c c4 00 00 00    	jl     f010549c <stab_binsearch+0x105>
f01053d8:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01053db:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01053de:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01053e1:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f01053e5:	39 f0                	cmp    %esi,%eax
f01053e7:	0f 84 b4 00 00 00    	je     f01054a1 <stab_binsearch+0x10a>
		int true_m = (l + r) / 2, m = true_m;
f01053ed:	89 f8                	mov    %edi,%eax
			m--;
f01053ef:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f01053f2:	39 d8                	cmp    %ebx,%eax
f01053f4:	0f 8c a2 00 00 00    	jl     f010549c <stab_binsearch+0x105>
f01053fa:	0f b6 4a f8          	movzbl -0x8(%edx),%ecx
f01053fe:	83 ea 0c             	sub    $0xc,%edx
f0105401:	39 f1                	cmp    %esi,%ecx
f0105403:	75 ea                	jne    f01053ef <stab_binsearch+0x58>
f0105405:	e9 99 00 00 00       	jmp    f01054a3 <stab_binsearch+0x10c>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010540a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010540d:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010540f:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0105412:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105419:	eb 2b                	jmp    f0105446 <stab_binsearch+0xaf>
		} else if (stabs[m].n_value > addr) {
f010541b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010541e:	76 14                	jbe    f0105434 <stab_binsearch+0x9d>
			*region_right = m - 1;
f0105420:	83 e8 01             	sub    $0x1,%eax
f0105423:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105426:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105429:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f010542b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105432:	eb 12                	jmp    f0105446 <stab_binsearch+0xaf>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105434:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105437:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0105439:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010543d:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f010543f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0105446:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105449:	0f 8e 73 ff ff ff    	jle    f01053c2 <stab_binsearch+0x2b>
		}
	}

	if (!any_matches)
f010544f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105453:	75 0f                	jne    f0105464 <stab_binsearch+0xcd>
		*region_right = *region_left - 1;
f0105455:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105458:	8b 00                	mov    (%eax),%eax
f010545a:	83 e8 01             	sub    $0x1,%eax
f010545d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105460:	89 06                	mov    %eax,(%esi)
f0105462:	eb 57                	jmp    f01054bb <stab_binsearch+0x124>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105464:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105467:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010546c:	8b 0f                	mov    (%edi),%ecx
		for (l = *region_right;
f010546e:	39 c8                	cmp    %ecx,%eax
f0105470:	7e 23                	jle    f0105495 <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f0105472:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105475:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0105478:	8d 14 97             	lea    (%edi,%edx,4),%edx
f010547b:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010547f:	39 f3                	cmp    %esi,%ebx
f0105481:	74 12                	je     f0105495 <stab_binsearch+0xfe>
		     l--)
f0105483:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0105486:	39 c8                	cmp    %ecx,%eax
f0105488:	7e 0b                	jle    f0105495 <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f010548a:	0f b6 5a f8          	movzbl -0x8(%edx),%ebx
f010548e:	83 ea 0c             	sub    $0xc,%edx
f0105491:	39 f3                	cmp    %esi,%ebx
f0105493:	75 ee                	jne    f0105483 <stab_binsearch+0xec>
			/* do nothing */;
		*region_left = l;
f0105495:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105498:	89 06                	mov    %eax,(%esi)
f010549a:	eb 1f                	jmp    f01054bb <stab_binsearch+0x124>
			l = true_m + 1;
f010549c:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010549f:	eb a5                	jmp    f0105446 <stab_binsearch+0xaf>
		int true_m = (l + r) / 2, m = true_m;
f01054a1:	89 f8                	mov    %edi,%eax
		if (stabs[m].n_value < addr) {
f01054a3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01054a6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01054a9:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01054ad:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01054b0:	0f 82 54 ff ff ff    	jb     f010540a <stab_binsearch+0x73>
f01054b6:	e9 60 ff ff ff       	jmp    f010541b <stab_binsearch+0x84>
	}
}
f01054bb:	83 c4 14             	add    $0x14,%esp
f01054be:	5b                   	pop    %ebx
f01054bf:	5e                   	pop    %esi
f01054c0:	5f                   	pop    %edi
f01054c1:	5d                   	pop    %ebp
f01054c2:	c3                   	ret    

f01054c3 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01054c3:	55                   	push   %ebp
f01054c4:	89 e5                	mov    %esp,%ebp
f01054c6:	57                   	push   %edi
f01054c7:	56                   	push   %esi
f01054c8:	53                   	push   %ebx
f01054c9:	83 ec 4c             	sub    $0x4c,%esp
f01054cc:	8b 7d 08             	mov    0x8(%ebp),%edi
f01054cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01054d2:	c7 03 d4 85 10 f0    	movl   $0xf01085d4,(%ebx)
	info->eip_line = 0;
f01054d8:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01054df:	c7 43 08 d4 85 10 f0 	movl   $0xf01085d4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01054e6:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01054ed:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01054f0:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01054f7:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01054fd:	0f 87 c1 00 00 00    	ja     f01055c4 <debuginfo_eip+0x101>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0105503:	e8 4b 12 00 00       	call   f0106753 <cpunum>
f0105508:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010550f:	00 
f0105510:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105517:	00 
f0105518:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f010551f:	00 
f0105520:	6b c0 74             	imul   $0x74,%eax,%eax
f0105523:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f0105529:	89 04 24             	mov    %eax,(%esp)
f010552c:	e8 90 df ff ff       	call   f01034c1 <user_mem_check>
f0105531:	85 c0                	test   %eax,%eax
f0105533:	0f 85 6a 02 00 00    	jne    f01057a3 <debuginfo_eip+0x2e0>
			return -1;

		stabs = usd->stabs;
f0105539:	a1 00 00 20 00       	mov    0x200000,%eax
f010553e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0105541:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0105547:	8b 15 08 00 20 00    	mov    0x200008,%edx
f010554d:	89 55 c0             	mov    %edx,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0105550:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0105555:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, stabs, sizeof(struct Stab) * (stab_end - stabs), PTE_U))
f0105558:	e8 f6 11 00 00       	call   f0106753 <cpunum>
f010555d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105564:	00 
f0105565:	89 f2                	mov    %esi,%edx
f0105567:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010556a:	29 ca                	sub    %ecx,%edx
f010556c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105570:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105574:	6b c0 74             	imul   $0x74,%eax,%eax
f0105577:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f010557d:	89 04 24             	mov    %eax,(%esp)
f0105580:	e8 3c df ff ff       	call   f01034c1 <user_mem_check>
f0105585:	85 c0                	test   %eax,%eax
f0105587:	0f 85 1d 02 00 00    	jne    f01057aa <debuginfo_eip+0x2e7>
			return -1;
		if(user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
f010558d:	e8 c1 11 00 00       	call   f0106753 <cpunum>
f0105592:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105599:	00 
f010559a:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010559d:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01055a0:	29 ca                	sub    %ecx,%edx
f01055a2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01055a6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01055aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01055ad:	8b 80 28 70 22 f0    	mov    -0xfdd8fd8(%eax),%eax
f01055b3:	89 04 24             	mov    %eax,(%esp)
f01055b6:	e8 06 df ff ff       	call   f01034c1 <user_mem_check>
f01055bb:	85 c0                	test   %eax,%eax
f01055bd:	74 1f                	je     f01055de <debuginfo_eip+0x11b>
f01055bf:	e9 ed 01 00 00       	jmp    f01057b1 <debuginfo_eip+0x2ee>
		stabstr_end = __STABSTR_END__;
f01055c4:	c7 45 bc 9a 69 11 f0 	movl   $0xf011699a,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01055cb:	c7 45 c0 3d 32 11 f0 	movl   $0xf011323d,-0x40(%ebp)
		stab_end = __STAB_END__;
f01055d2:	be 3c 32 11 f0       	mov    $0xf011323c,%esi
		stabs = __STAB_BEGIN__;
f01055d7:	c7 45 c4 b4 8a 10 f0 	movl   $0xf0108ab4,-0x3c(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01055de:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01055e1:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f01055e4:	0f 83 ce 01 00 00    	jae    f01057b8 <debuginfo_eip+0x2f5>
f01055ea:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01055ee:	0f 85 cb 01 00 00    	jne    f01057bf <debuginfo_eip+0x2fc>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01055f4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01055fb:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f01055fe:	c1 fe 02             	sar    $0x2,%esi
f0105601:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0105607:	83 e8 01             	sub    $0x1,%eax
f010560a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010560d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105611:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105618:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010561b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010561e:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105621:	89 f0                	mov    %esi,%eax
f0105623:	e8 6f fd ff ff       	call   f0105397 <stab_binsearch>
	if (lfile == 0)
f0105628:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010562b:	85 c0                	test   %eax,%eax
f010562d:	0f 84 93 01 00 00    	je     f01057c6 <debuginfo_eip+0x303>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105633:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105636:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105639:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010563c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105640:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105647:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010564a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010564d:	89 f0                	mov    %esi,%eax
f010564f:	e8 43 fd ff ff       	call   f0105397 <stab_binsearch>

	if (lfun <= rfun) {
f0105654:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105657:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010565a:	39 f0                	cmp    %esi,%eax
f010565c:	7f 32                	jg     f0105690 <debuginfo_eip+0x1cd>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010565e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105661:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105664:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0105667:	8b 0a                	mov    (%edx),%ecx
f0105669:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f010566c:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f010566f:	2b 4d c0             	sub    -0x40(%ebp),%ecx
f0105672:	39 4d b8             	cmp    %ecx,-0x48(%ebp)
f0105675:	73 09                	jae    f0105680 <debuginfo_eip+0x1bd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105677:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f010567a:	03 4d c0             	add    -0x40(%ebp),%ecx
f010567d:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105680:	8b 52 08             	mov    0x8(%edx),%edx
f0105683:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105686:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0105688:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010568b:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010568e:	eb 0f                	jmp    f010569f <debuginfo_eip+0x1dc>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105690:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0105693:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105696:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105699:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010569c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010569f:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01056a6:	00 
f01056a7:	8b 43 08             	mov    0x8(%ebx),%eax
f01056aa:	89 04 24             	mov    %eax,(%esp)
f01056ad:	e8 dd 09 00 00       	call   f010608f <strfind>
f01056b2:	2b 43 08             	sub    0x8(%ebx),%eax
f01056b5:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01056b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01056bc:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01056c3:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01056c6:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01056c9:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01056cc:	89 f0                	mov    %esi,%eax
f01056ce:	e8 c4 fc ff ff       	call   f0105397 <stab_binsearch>
	if (lline <= rline)
f01056d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01056d6:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01056d9:	0f 8f ee 00 00 00    	jg     f01057cd <debuginfo_eip+0x30a>
		info->eip_line = stabs[lline].n_desc;
f01056df:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01056e2:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f01056e7:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01056ea:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01056ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01056f0:	39 f9                	cmp    %edi,%ecx
f01056f2:	7c 62                	jl     f0105756 <debuginfo_eip+0x293>
	       && stabs[lline].n_type != N_SOL
f01056f4:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f01056f7:	c1 e0 02             	shl    $0x2,%eax
f01056fa:	8d 14 06             	lea    (%esi,%eax,1),%edx
f01056fd:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0105700:	0f b6 52 04          	movzbl 0x4(%edx),%edx
f0105704:	80 fa 84             	cmp    $0x84,%dl
f0105707:	74 35                	je     f010573e <debuginfo_eip+0x27b>
f0105709:	8d 44 06 f4          	lea    -0xc(%esi,%eax,1),%eax
f010570d:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0105710:	eb 1a                	jmp    f010572c <debuginfo_eip+0x269>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105712:	83 e9 01             	sub    $0x1,%ecx
	while (lline >= lfile
f0105715:	39 f9                	cmp    %edi,%ecx
f0105717:	7c 3d                	jl     f0105756 <debuginfo_eip+0x293>
	       && stabs[lline].n_type != N_SOL
f0105719:	89 c6                	mov    %eax,%esi
f010571b:	83 e8 0c             	sub    $0xc,%eax
f010571e:	0f b6 50 10          	movzbl 0x10(%eax),%edx
f0105722:	80 fa 84             	cmp    $0x84,%dl
f0105725:	75 05                	jne    f010572c <debuginfo_eip+0x269>
f0105727:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f010572a:	eb 12                	jmp    f010573e <debuginfo_eip+0x27b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010572c:	80 fa 64             	cmp    $0x64,%dl
f010572f:	75 e1                	jne    f0105712 <debuginfo_eip+0x24f>
f0105731:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0105735:	74 db                	je     f0105712 <debuginfo_eip+0x24f>
f0105737:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010573a:	39 cf                	cmp    %ecx,%edi
f010573c:	7f 18                	jg     f0105756 <debuginfo_eip+0x293>
f010573e:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0105741:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105744:	8b 04 87             	mov    (%edi,%eax,4),%eax
f0105747:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010574a:	2b 55 c0             	sub    -0x40(%ebp),%edx
f010574d:	39 d0                	cmp    %edx,%eax
f010574f:	73 05                	jae    f0105756 <debuginfo_eip+0x293>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105751:	03 45 c0             	add    -0x40(%ebp),%eax
f0105754:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105756:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105759:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010575c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0105761:	39 f2                	cmp    %esi,%edx
f0105763:	0f 8d 85 00 00 00    	jge    f01057ee <debuginfo_eip+0x32b>
		for (lline = lfun + 1;
f0105769:	8d 42 01             	lea    0x1(%edx),%eax
f010576c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010576f:	39 c6                	cmp    %eax,%esi
f0105771:	7e 61                	jle    f01057d4 <debuginfo_eip+0x311>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105773:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105776:	c1 e1 02             	shl    $0x2,%ecx
f0105779:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010577c:	80 7c 0f 04 a0       	cmpb   $0xa0,0x4(%edi,%ecx,1)
f0105781:	75 58                	jne    f01057db <debuginfo_eip+0x318>
f0105783:	8d 42 02             	lea    0x2(%edx),%eax
f0105786:	8d 54 0f f4          	lea    -0xc(%edi,%ecx,1),%edx
			info->eip_fn_narg++;
f010578a:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f010578e:	39 f0                	cmp    %esi,%eax
f0105790:	74 50                	je     f01057e2 <debuginfo_eip+0x31f>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105792:	0f b6 4a 1c          	movzbl 0x1c(%edx),%ecx
f0105796:	83 c0 01             	add    $0x1,%eax
f0105799:	83 c2 0c             	add    $0xc,%edx
f010579c:	80 f9 a0             	cmp    $0xa0,%cl
f010579f:	74 e9                	je     f010578a <debuginfo_eip+0x2c7>
f01057a1:	eb 46                	jmp    f01057e9 <debuginfo_eip+0x326>
			return -1;
f01057a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057a8:	eb 44                	jmp    f01057ee <debuginfo_eip+0x32b>
			return -1;
f01057aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057af:	eb 3d                	jmp    f01057ee <debuginfo_eip+0x32b>
			return -1;
f01057b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057b6:	eb 36                	jmp    f01057ee <debuginfo_eip+0x32b>
		return -1;
f01057b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057bd:	eb 2f                	jmp    f01057ee <debuginfo_eip+0x32b>
f01057bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057c4:	eb 28                	jmp    f01057ee <debuginfo_eip+0x32b>
		return -1;
f01057c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057cb:	eb 21                	jmp    f01057ee <debuginfo_eip+0x32b>
		return -1;
f01057cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057d2:	eb 1a                	jmp    f01057ee <debuginfo_eip+0x32b>
	return 0;
f01057d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01057d9:	eb 13                	jmp    f01057ee <debuginfo_eip+0x32b>
f01057db:	b8 00 00 00 00       	mov    $0x0,%eax
f01057e0:	eb 0c                	jmp    f01057ee <debuginfo_eip+0x32b>
f01057e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01057e7:	eb 05                	jmp    f01057ee <debuginfo_eip+0x32b>
f01057e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057ee:	83 c4 4c             	add    $0x4c,%esp
f01057f1:	5b                   	pop    %ebx
f01057f2:	5e                   	pop    %esi
f01057f3:	5f                   	pop    %edi
f01057f4:	5d                   	pop    %ebp
f01057f5:	c3                   	ret    
f01057f6:	66 90                	xchg   %ax,%ax
f01057f8:	66 90                	xchg   %ax,%ax
f01057fa:	66 90                	xchg   %ax,%ax
f01057fc:	66 90                	xchg   %ax,%ax
f01057fe:	66 90                	xchg   %ax,%ax

f0105800 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105800:	55                   	push   %ebp
f0105801:	89 e5                	mov    %esp,%ebp
f0105803:	57                   	push   %edi
f0105804:	56                   	push   %esi
f0105805:	53                   	push   %ebx
f0105806:	83 ec 3c             	sub    $0x3c,%esp
f0105809:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010580c:	89 d7                	mov    %edx,%edi
f010580e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105811:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105814:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105817:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010581a:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010581d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105822:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105825:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105828:	39 f1                	cmp    %esi,%ecx
f010582a:	72 14                	jb     f0105840 <printnum+0x40>
f010582c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f010582f:	76 0f                	jbe    f0105840 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105831:	8b 45 14             	mov    0x14(%ebp),%eax
f0105834:	8d 70 ff             	lea    -0x1(%eax),%esi
f0105837:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010583a:	85 f6                	test   %esi,%esi
f010583c:	7f 60                	jg     f010589e <printnum+0x9e>
f010583e:	eb 72                	jmp    f01058b2 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105840:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105843:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105847:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010584a:	8d 51 ff             	lea    -0x1(%ecx),%edx
f010584d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105851:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105855:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105859:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010585d:	89 c3                	mov    %eax,%ebx
f010585f:	89 d6                	mov    %edx,%esi
f0105861:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105864:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105867:	89 54 24 08          	mov    %edx,0x8(%esp)
f010586b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010586f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105872:	89 04 24             	mov    %eax,(%esp)
f0105875:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105878:	89 44 24 04          	mov    %eax,0x4(%esp)
f010587c:	e8 4f 13 00 00       	call   f0106bd0 <__udivdi3>
f0105881:	89 d9                	mov    %ebx,%ecx
f0105883:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105887:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010588b:	89 04 24             	mov    %eax,(%esp)
f010588e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105892:	89 fa                	mov    %edi,%edx
f0105894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105897:	e8 64 ff ff ff       	call   f0105800 <printnum>
f010589c:	eb 14                	jmp    f01058b2 <printnum+0xb2>
			putch(padc, putdat);
f010589e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01058a2:	8b 45 18             	mov    0x18(%ebp),%eax
f01058a5:	89 04 24             	mov    %eax,(%esp)
f01058a8:	ff d3                	call   *%ebx
		while (--width > 0)
f01058aa:	83 ee 01             	sub    $0x1,%esi
f01058ad:	75 ef                	jne    f010589e <printnum+0x9e>
f01058af:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01058b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01058b6:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01058ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01058bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01058c0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01058c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01058c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058cb:	89 04 24             	mov    %eax,(%esp)
f01058ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01058d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058d5:	e8 26 14 00 00       	call   f0106d00 <__umoddi3>
f01058da:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01058de:	0f be 80 de 85 10 f0 	movsbl -0xfef7a22(%eax),%eax
f01058e5:	89 04 24             	mov    %eax,(%esp)
f01058e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058eb:	ff d0                	call   *%eax
}
f01058ed:	83 c4 3c             	add    $0x3c,%esp
f01058f0:	5b                   	pop    %ebx
f01058f1:	5e                   	pop    %esi
f01058f2:	5f                   	pop    %edi
f01058f3:	5d                   	pop    %ebp
f01058f4:	c3                   	ret    

f01058f5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01058f5:	55                   	push   %ebp
f01058f6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01058f8:	83 fa 01             	cmp    $0x1,%edx
f01058fb:	7e 0e                	jle    f010590b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01058fd:	8b 10                	mov    (%eax),%edx
f01058ff:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105902:	89 08                	mov    %ecx,(%eax)
f0105904:	8b 02                	mov    (%edx),%eax
f0105906:	8b 52 04             	mov    0x4(%edx),%edx
f0105909:	eb 22                	jmp    f010592d <getuint+0x38>
	else if (lflag)
f010590b:	85 d2                	test   %edx,%edx
f010590d:	74 10                	je     f010591f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010590f:	8b 10                	mov    (%eax),%edx
f0105911:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105914:	89 08                	mov    %ecx,(%eax)
f0105916:	8b 02                	mov    (%edx),%eax
f0105918:	ba 00 00 00 00       	mov    $0x0,%edx
f010591d:	eb 0e                	jmp    f010592d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010591f:	8b 10                	mov    (%eax),%edx
f0105921:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105924:	89 08                	mov    %ecx,(%eax)
f0105926:	8b 02                	mov    (%edx),%eax
f0105928:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010592d:	5d                   	pop    %ebp
f010592e:	c3                   	ret    

f010592f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010592f:	55                   	push   %ebp
f0105930:	89 e5                	mov    %esp,%ebp
f0105932:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105935:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105939:	8b 10                	mov    (%eax),%edx
f010593b:	3b 50 04             	cmp    0x4(%eax),%edx
f010593e:	73 0a                	jae    f010594a <sprintputch+0x1b>
		*b->buf++ = ch;
f0105940:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105943:	89 08                	mov    %ecx,(%eax)
f0105945:	8b 45 08             	mov    0x8(%ebp),%eax
f0105948:	88 02                	mov    %al,(%edx)
}
f010594a:	5d                   	pop    %ebp
f010594b:	c3                   	ret    

f010594c <printfmt>:
{
f010594c:	55                   	push   %ebp
f010594d:	89 e5                	mov    %esp,%ebp
f010594f:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
f0105952:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105955:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105959:	8b 45 10             	mov    0x10(%ebp),%eax
f010595c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105960:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105963:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105967:	8b 45 08             	mov    0x8(%ebp),%eax
f010596a:	89 04 24             	mov    %eax,(%esp)
f010596d:	e8 02 00 00 00       	call   f0105974 <vprintfmt>
}
f0105972:	c9                   	leave  
f0105973:	c3                   	ret    

f0105974 <vprintfmt>:
{
f0105974:	55                   	push   %ebp
f0105975:	89 e5                	mov    %esp,%ebp
f0105977:	57                   	push   %edi
f0105978:	56                   	push   %esi
f0105979:	53                   	push   %ebx
f010597a:	83 ec 3c             	sub    $0x3c,%esp
f010597d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105980:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105983:	eb 18                	jmp    f010599d <vprintfmt+0x29>
			if (ch == '\0')
f0105985:	85 c0                	test   %eax,%eax
f0105987:	0f 84 c3 03 00 00    	je     f0105d50 <vprintfmt+0x3dc>
			putch(ch, putdat);
f010598d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105991:	89 04 24             	mov    %eax,(%esp)
f0105994:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105997:	89 f3                	mov    %esi,%ebx
f0105999:	eb 02                	jmp    f010599d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
f010599b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010599d:	8d 73 01             	lea    0x1(%ebx),%esi
f01059a0:	0f b6 03             	movzbl (%ebx),%eax
f01059a3:	83 f8 25             	cmp    $0x25,%eax
f01059a6:	75 dd                	jne    f0105985 <vprintfmt+0x11>
f01059a8:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
f01059ac:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01059b3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f01059ba:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01059c1:	ba 00 00 00 00       	mov    $0x0,%edx
f01059c6:	eb 1d                	jmp    f01059e5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
f01059c8:	89 de                	mov    %ebx,%esi
			padc = '-';
f01059ca:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
f01059ce:	eb 15                	jmp    f01059e5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
f01059d0:	89 de                	mov    %ebx,%esi
			padc = '0';
f01059d2:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
f01059d6:	eb 0d                	jmp    f01059e5 <vprintfmt+0x71>
				width = precision, precision = -1;
f01059d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01059db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01059de:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01059e5:	8d 5e 01             	lea    0x1(%esi),%ebx
f01059e8:	0f b6 06             	movzbl (%esi),%eax
f01059eb:	0f b6 c8             	movzbl %al,%ecx
f01059ee:	83 e8 23             	sub    $0x23,%eax
f01059f1:	3c 55                	cmp    $0x55,%al
f01059f3:	0f 87 2f 03 00 00    	ja     f0105d28 <vprintfmt+0x3b4>
f01059f9:	0f b6 c0             	movzbl %al,%eax
f01059fc:	ff 24 85 a0 86 10 f0 	jmp    *-0xfef7960(,%eax,4)
				precision = precision * 10 + ch - '0';
f0105a03:	8d 41 d0             	lea    -0x30(%ecx),%eax
f0105a06:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
f0105a09:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0105a0d:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0105a10:	83 f9 09             	cmp    $0x9,%ecx
f0105a13:	77 50                	ja     f0105a65 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
f0105a15:	89 de                	mov    %ebx,%esi
f0105a17:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
f0105a1a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0105a1d:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0105a20:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0105a24:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105a27:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0105a2a:	83 fb 09             	cmp    $0x9,%ebx
f0105a2d:	76 eb                	jbe    f0105a1a <vprintfmt+0xa6>
f0105a2f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0105a32:	eb 33                	jmp    f0105a67 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
f0105a34:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a37:	8d 48 04             	lea    0x4(%eax),%ecx
f0105a3a:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105a3d:	8b 00                	mov    (%eax),%eax
f0105a3f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105a42:	89 de                	mov    %ebx,%esi
			goto process_precision;
f0105a44:	eb 21                	jmp    f0105a67 <vprintfmt+0xf3>
f0105a46:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105a49:	85 c9                	test   %ecx,%ecx
f0105a4b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a50:	0f 49 c1             	cmovns %ecx,%eax
f0105a53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105a56:	89 de                	mov    %ebx,%esi
f0105a58:	eb 8b                	jmp    f01059e5 <vprintfmt+0x71>
f0105a5a:	89 de                	mov    %ebx,%esi
			altflag = 1;
f0105a5c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105a63:	eb 80                	jmp    f01059e5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
f0105a65:	89 de                	mov    %ebx,%esi
			if (width < 0)
f0105a67:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105a6b:	0f 89 74 ff ff ff    	jns    f01059e5 <vprintfmt+0x71>
f0105a71:	e9 62 ff ff ff       	jmp    f01059d8 <vprintfmt+0x64>
			lflag++;
f0105a76:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
f0105a79:	89 de                	mov    %ebx,%esi
			goto reswitch;
f0105a7b:	e9 65 ff ff ff       	jmp    f01059e5 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
f0105a80:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a83:	8d 50 04             	lea    0x4(%eax),%edx
f0105a86:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a89:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a8d:	8b 00                	mov    (%eax),%eax
f0105a8f:	89 04 24             	mov    %eax,(%esp)
f0105a92:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105a95:	e9 03 ff ff ff       	jmp    f010599d <vprintfmt+0x29>
			err = va_arg(ap, int);
f0105a9a:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a9d:	8d 50 04             	lea    0x4(%eax),%edx
f0105aa0:	89 55 14             	mov    %edx,0x14(%ebp)
f0105aa3:	8b 00                	mov    (%eax),%eax
f0105aa5:	99                   	cltd   
f0105aa6:	31 d0                	xor    %edx,%eax
f0105aa8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105aaa:	83 f8 08             	cmp    $0x8,%eax
f0105aad:	7f 0b                	jg     f0105aba <vprintfmt+0x146>
f0105aaf:	8b 14 85 00 88 10 f0 	mov    -0xfef7800(,%eax,4),%edx
f0105ab6:	85 d2                	test   %edx,%edx
f0105ab8:	75 20                	jne    f0105ada <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
f0105aba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105abe:	c7 44 24 08 f6 85 10 	movl   $0xf01085f6,0x8(%esp)
f0105ac5:	f0 
f0105ac6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105aca:	8b 45 08             	mov    0x8(%ebp),%eax
f0105acd:	89 04 24             	mov    %eax,(%esp)
f0105ad0:	e8 77 fe ff ff       	call   f010594c <printfmt>
f0105ad5:	e9 c3 fe ff ff       	jmp    f010599d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
f0105ada:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105ade:	c7 44 24 08 57 74 10 	movl   $0xf0107457,0x8(%esp)
f0105ae5:	f0 
f0105ae6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105aea:	8b 45 08             	mov    0x8(%ebp),%eax
f0105aed:	89 04 24             	mov    %eax,(%esp)
f0105af0:	e8 57 fe ff ff       	call   f010594c <printfmt>
f0105af5:	e9 a3 fe ff ff       	jmp    f010599d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
f0105afa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0105afd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f0105b00:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b03:	8d 50 04             	lea    0x4(%eax),%edx
f0105b06:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b09:	8b 00                	mov    (%eax),%eax
				p = "(null)";
f0105b0b:	85 c0                	test   %eax,%eax
f0105b0d:	ba ef 85 10 f0       	mov    $0xf01085ef,%edx
f0105b12:	0f 45 d0             	cmovne %eax,%edx
f0105b15:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0105b18:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
f0105b1c:	74 04                	je     f0105b22 <vprintfmt+0x1ae>
f0105b1e:	85 f6                	test   %esi,%esi
f0105b20:	7f 19                	jg     f0105b3b <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105b22:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105b25:	8d 70 01             	lea    0x1(%eax),%esi
f0105b28:	0f b6 10             	movzbl (%eax),%edx
f0105b2b:	0f be c2             	movsbl %dl,%eax
f0105b2e:	85 c0                	test   %eax,%eax
f0105b30:	0f 85 95 00 00 00    	jne    f0105bcb <vprintfmt+0x257>
f0105b36:	e9 85 00 00 00       	jmp    f0105bc0 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105b3b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105b3f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105b42:	89 04 24             	mov    %eax,(%esp)
f0105b45:	e8 88 03 00 00       	call   f0105ed2 <strnlen>
f0105b4a:	29 c6                	sub    %eax,%esi
f0105b4c:	89 f0                	mov    %esi,%eax
f0105b4e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0105b51:	85 f6                	test   %esi,%esi
f0105b53:	7e cd                	jle    f0105b22 <vprintfmt+0x1ae>
					putch(padc, putdat);
f0105b55:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0105b59:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105b5c:	89 c3                	mov    %eax,%ebx
f0105b5e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105b62:	89 34 24             	mov    %esi,(%esp)
f0105b65:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0105b68:	83 eb 01             	sub    $0x1,%ebx
f0105b6b:	75 f1                	jne    f0105b5e <vprintfmt+0x1ea>
f0105b6d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0105b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105b73:	eb ad                	jmp    f0105b22 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
f0105b75:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105b79:	74 1e                	je     f0105b99 <vprintfmt+0x225>
f0105b7b:	0f be d2             	movsbl %dl,%edx
f0105b7e:	83 ea 20             	sub    $0x20,%edx
f0105b81:	83 fa 5e             	cmp    $0x5e,%edx
f0105b84:	76 13                	jbe    f0105b99 <vprintfmt+0x225>
					putch('?', putdat);
f0105b86:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b89:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b8d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105b94:	ff 55 08             	call   *0x8(%ebp)
f0105b97:	eb 0d                	jmp    f0105ba6 <vprintfmt+0x232>
					putch(ch, putdat);
f0105b99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105b9c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105ba0:	89 04 24             	mov    %eax,(%esp)
f0105ba3:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105ba6:	83 ef 01             	sub    $0x1,%edi
f0105ba9:	83 c6 01             	add    $0x1,%esi
f0105bac:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f0105bb0:	0f be c2             	movsbl %dl,%eax
f0105bb3:	85 c0                	test   %eax,%eax
f0105bb5:	75 20                	jne    f0105bd7 <vprintfmt+0x263>
f0105bb7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105bba:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105bbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
f0105bc0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105bc4:	7f 25                	jg     f0105beb <vprintfmt+0x277>
f0105bc6:	e9 d2 fd ff ff       	jmp    f010599d <vprintfmt+0x29>
f0105bcb:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105bce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105bd1:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105bd4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105bd7:	85 db                	test   %ebx,%ebx
f0105bd9:	78 9a                	js     f0105b75 <vprintfmt+0x201>
f0105bdb:	83 eb 01             	sub    $0x1,%ebx
f0105bde:	79 95                	jns    f0105b75 <vprintfmt+0x201>
f0105be0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105be3:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105be6:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105be9:	eb d5                	jmp    f0105bc0 <vprintfmt+0x24c>
f0105beb:	8b 75 08             	mov    0x8(%ebp),%esi
f0105bee:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105bf1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
f0105bf4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105bf8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105bff:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105c01:	83 eb 01             	sub    $0x1,%ebx
f0105c04:	75 ee                	jne    f0105bf4 <vprintfmt+0x280>
f0105c06:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105c09:	e9 8f fd ff ff       	jmp    f010599d <vprintfmt+0x29>
	if (lflag >= 2)
f0105c0e:	83 fa 01             	cmp    $0x1,%edx
f0105c11:	7e 16                	jle    f0105c29 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
f0105c13:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c16:	8d 50 08             	lea    0x8(%eax),%edx
f0105c19:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c1c:	8b 50 04             	mov    0x4(%eax),%edx
f0105c1f:	8b 00                	mov    (%eax),%eax
f0105c21:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105c24:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105c27:	eb 32                	jmp    f0105c5b <vprintfmt+0x2e7>
	else if (lflag)
f0105c29:	85 d2                	test   %edx,%edx
f0105c2b:	74 18                	je     f0105c45 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
f0105c2d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c30:	8d 50 04             	lea    0x4(%eax),%edx
f0105c33:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c36:	8b 30                	mov    (%eax),%esi
f0105c38:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0105c3b:	89 f0                	mov    %esi,%eax
f0105c3d:	c1 f8 1f             	sar    $0x1f,%eax
f0105c40:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105c43:	eb 16                	jmp    f0105c5b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
f0105c45:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c48:	8d 50 04             	lea    0x4(%eax),%edx
f0105c4b:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c4e:	8b 30                	mov    (%eax),%esi
f0105c50:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0105c53:	89 f0                	mov    %esi,%eax
f0105c55:	c1 f8 1f             	sar    $0x1f,%eax
f0105c58:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
f0105c5b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105c5e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
f0105c61:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
f0105c66:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105c6a:	0f 89 80 00 00 00    	jns    f0105cf0 <vprintfmt+0x37c>
				putch('-', putdat);
f0105c70:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105c74:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105c7b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105c7e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105c81:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105c84:	f7 d8                	neg    %eax
f0105c86:	83 d2 00             	adc    $0x0,%edx
f0105c89:	f7 da                	neg    %edx
			base = 10;
f0105c8b:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105c90:	eb 5e                	jmp    f0105cf0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
f0105c92:	8d 45 14             	lea    0x14(%ebp),%eax
f0105c95:	e8 5b fc ff ff       	call   f01058f5 <getuint>
			base = 10;
f0105c9a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105c9f:	eb 4f                	jmp    f0105cf0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
f0105ca1:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ca4:	e8 4c fc ff ff       	call   f01058f5 <getuint>
			base = 8;
f0105ca9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105cae:	eb 40                	jmp    f0105cf0 <vprintfmt+0x37c>
			putch('0', putdat);
f0105cb0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105cb4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105cbb:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105cbe:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105cc2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105cc9:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
f0105ccc:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ccf:	8d 50 04             	lea    0x4(%eax),%edx
f0105cd2:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
f0105cd5:	8b 00                	mov    (%eax),%eax
f0105cd7:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
f0105cdc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105ce1:	eb 0d                	jmp    f0105cf0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
f0105ce3:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ce6:	e8 0a fc ff ff       	call   f01058f5 <getuint>
			base = 16;
f0105ceb:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
f0105cf0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0105cf4:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105cf8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105cfb:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105cff:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105d03:	89 04 24             	mov    %eax,(%esp)
f0105d06:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105d0a:	89 fa                	mov    %edi,%edx
f0105d0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d0f:	e8 ec fa ff ff       	call   f0105800 <printnum>
			break;
f0105d14:	e9 84 fc ff ff       	jmp    f010599d <vprintfmt+0x29>
			putch(ch, putdat);
f0105d19:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d1d:	89 0c 24             	mov    %ecx,(%esp)
f0105d20:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105d23:	e9 75 fc ff ff       	jmp    f010599d <vprintfmt+0x29>
			putch('%', putdat);
f0105d28:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d2c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105d33:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105d36:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105d3a:	0f 84 5b fc ff ff    	je     f010599b <vprintfmt+0x27>
f0105d40:	89 f3                	mov    %esi,%ebx
f0105d42:	83 eb 01             	sub    $0x1,%ebx
f0105d45:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0105d49:	75 f7                	jne    f0105d42 <vprintfmt+0x3ce>
f0105d4b:	e9 4d fc ff ff       	jmp    f010599d <vprintfmt+0x29>
}
f0105d50:	83 c4 3c             	add    $0x3c,%esp
f0105d53:	5b                   	pop    %ebx
f0105d54:	5e                   	pop    %esi
f0105d55:	5f                   	pop    %edi
f0105d56:	5d                   	pop    %ebp
f0105d57:	c3                   	ret    

f0105d58 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105d58:	55                   	push   %ebp
f0105d59:	89 e5                	mov    %esp,%ebp
f0105d5b:	83 ec 28             	sub    $0x28,%esp
f0105d5e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d61:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105d64:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105d67:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105d6b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105d6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105d75:	85 c0                	test   %eax,%eax
f0105d77:	74 30                	je     f0105da9 <vsnprintf+0x51>
f0105d79:	85 d2                	test   %edx,%edx
f0105d7b:	7e 2c                	jle    f0105da9 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105d7d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d80:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105d84:	8b 45 10             	mov    0x10(%ebp),%eax
f0105d87:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d8b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d92:	c7 04 24 2f 59 10 f0 	movl   $0xf010592f,(%esp)
f0105d99:	e8 d6 fb ff ff       	call   f0105974 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105d9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105da1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105da7:	eb 05                	jmp    f0105dae <vsnprintf+0x56>
		return -E_INVAL;
f0105da9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
f0105dae:	c9                   	leave  
f0105daf:	c3                   	ret    

f0105db0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105db0:	55                   	push   %ebp
f0105db1:	89 e5                	mov    %esp,%ebp
f0105db3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105db6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105db9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105dbd:	8b 45 10             	mov    0x10(%ebp),%eax
f0105dc0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105dc7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105dcb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dce:	89 04 24             	mov    %eax,(%esp)
f0105dd1:	e8 82 ff ff ff       	call   f0105d58 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105dd6:	c9                   	leave  
f0105dd7:	c3                   	ret    
f0105dd8:	66 90                	xchg   %ax,%ax
f0105dda:	66 90                	xchg   %ax,%ax
f0105ddc:	66 90                	xchg   %ax,%ax
f0105dde:	66 90                	xchg   %ax,%ax

f0105de0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105de0:	55                   	push   %ebp
f0105de1:	89 e5                	mov    %esp,%ebp
f0105de3:	57                   	push   %edi
f0105de4:	56                   	push   %esi
f0105de5:	53                   	push   %ebx
f0105de6:	83 ec 1c             	sub    $0x1c,%esp
f0105de9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105dec:	85 c0                	test   %eax,%eax
f0105dee:	74 10                	je     f0105e00 <readline+0x20>
		cprintf("%s", prompt);
f0105df0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105df4:	c7 04 24 57 74 10 f0 	movl   $0xf0107457,(%esp)
f0105dfb:	e8 c9 e1 ff ff       	call   f0103fc9 <cprintf>

	i = 0;
	echoing = iscons(0);
f0105e00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105e07:	e8 bf a9 ff ff       	call   f01007cb <iscons>
f0105e0c:	89 c7                	mov    %eax,%edi
	i = 0;
f0105e0e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0105e13:	e8 a2 a9 ff ff       	call   f01007ba <getchar>
f0105e18:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105e1a:	85 c0                	test   %eax,%eax
f0105e1c:	79 17                	jns    f0105e35 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105e1e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e22:	c7 04 24 24 88 10 f0 	movl   $0xf0108824,(%esp)
f0105e29:	e8 9b e1 ff ff       	call   f0103fc9 <cprintf>
			return NULL;
f0105e2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e33:	eb 6d                	jmp    f0105ea2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105e35:	83 f8 7f             	cmp    $0x7f,%eax
f0105e38:	74 05                	je     f0105e3f <readline+0x5f>
f0105e3a:	83 f8 08             	cmp    $0x8,%eax
f0105e3d:	75 19                	jne    f0105e58 <readline+0x78>
f0105e3f:	85 f6                	test   %esi,%esi
f0105e41:	7e 15                	jle    f0105e58 <readline+0x78>
			if (echoing)
f0105e43:	85 ff                	test   %edi,%edi
f0105e45:	74 0c                	je     f0105e53 <readline+0x73>
				cputchar('\b');
f0105e47:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105e4e:	e8 57 a9 ff ff       	call   f01007aa <cputchar>
			i--;
f0105e53:	83 ee 01             	sub    $0x1,%esi
f0105e56:	eb bb                	jmp    f0105e13 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105e58:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105e5e:	7f 1c                	jg     f0105e7c <readline+0x9c>
f0105e60:	83 fb 1f             	cmp    $0x1f,%ebx
f0105e63:	7e 17                	jle    f0105e7c <readline+0x9c>
			if (echoing)
f0105e65:	85 ff                	test   %edi,%edi
f0105e67:	74 08                	je     f0105e71 <readline+0x91>
				cputchar(c);
f0105e69:	89 1c 24             	mov    %ebx,(%esp)
f0105e6c:	e8 39 a9 ff ff       	call   f01007aa <cputchar>
			buf[i++] = c;
f0105e71:	88 9e 80 6a 22 f0    	mov    %bl,-0xfdd9580(%esi)
f0105e77:	8d 76 01             	lea    0x1(%esi),%esi
f0105e7a:	eb 97                	jmp    f0105e13 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105e7c:	83 fb 0d             	cmp    $0xd,%ebx
f0105e7f:	74 05                	je     f0105e86 <readline+0xa6>
f0105e81:	83 fb 0a             	cmp    $0xa,%ebx
f0105e84:	75 8d                	jne    f0105e13 <readline+0x33>
			if (echoing)
f0105e86:	85 ff                	test   %edi,%edi
f0105e88:	74 0c                	je     f0105e96 <readline+0xb6>
				cputchar('\n');
f0105e8a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105e91:	e8 14 a9 ff ff       	call   f01007aa <cputchar>
			buf[i] = 0;
f0105e96:	c6 86 80 6a 22 f0 00 	movb   $0x0,-0xfdd9580(%esi)
			return buf;
f0105e9d:	b8 80 6a 22 f0       	mov    $0xf0226a80,%eax
		}
	}
}
f0105ea2:	83 c4 1c             	add    $0x1c,%esp
f0105ea5:	5b                   	pop    %ebx
f0105ea6:	5e                   	pop    %esi
f0105ea7:	5f                   	pop    %edi
f0105ea8:	5d                   	pop    %ebp
f0105ea9:	c3                   	ret    
f0105eaa:	66 90                	xchg   %ax,%ax
f0105eac:	66 90                	xchg   %ax,%ax
f0105eae:	66 90                	xchg   %ax,%ax

f0105eb0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105eb0:	55                   	push   %ebp
f0105eb1:	89 e5                	mov    %esp,%ebp
f0105eb3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105eb6:	80 3a 00             	cmpb   $0x0,(%edx)
f0105eb9:	74 10                	je     f0105ecb <strlen+0x1b>
f0105ebb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105ec0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0105ec3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105ec7:	75 f7                	jne    f0105ec0 <strlen+0x10>
f0105ec9:	eb 05                	jmp    f0105ed0 <strlen+0x20>
f0105ecb:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
f0105ed0:	5d                   	pop    %ebp
f0105ed1:	c3                   	ret    

f0105ed2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105ed2:	55                   	push   %ebp
f0105ed3:	89 e5                	mov    %esp,%ebp
f0105ed5:	53                   	push   %ebx
f0105ed6:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105ed9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105edc:	85 c9                	test   %ecx,%ecx
f0105ede:	74 1c                	je     f0105efc <strnlen+0x2a>
f0105ee0:	80 3b 00             	cmpb   $0x0,(%ebx)
f0105ee3:	74 1e                	je     f0105f03 <strnlen+0x31>
f0105ee5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0105eea:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105eec:	39 ca                	cmp    %ecx,%edx
f0105eee:	74 18                	je     f0105f08 <strnlen+0x36>
f0105ef0:	83 c2 01             	add    $0x1,%edx
f0105ef3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0105ef8:	75 f0                	jne    f0105eea <strnlen+0x18>
f0105efa:	eb 0c                	jmp    f0105f08 <strnlen+0x36>
f0105efc:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f01:	eb 05                	jmp    f0105f08 <strnlen+0x36>
f0105f03:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
f0105f08:	5b                   	pop    %ebx
f0105f09:	5d                   	pop    %ebp
f0105f0a:	c3                   	ret    

f0105f0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105f0b:	55                   	push   %ebp
f0105f0c:	89 e5                	mov    %esp,%ebp
f0105f0e:	53                   	push   %ebx
f0105f0f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105f15:	89 c2                	mov    %eax,%edx
f0105f17:	83 c2 01             	add    $0x1,%edx
f0105f1a:	83 c1 01             	add    $0x1,%ecx
f0105f1d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105f21:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105f24:	84 db                	test   %bl,%bl
f0105f26:	75 ef                	jne    f0105f17 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105f28:	5b                   	pop    %ebx
f0105f29:	5d                   	pop    %ebp
f0105f2a:	c3                   	ret    

f0105f2b <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105f2b:	55                   	push   %ebp
f0105f2c:	89 e5                	mov    %esp,%ebp
f0105f2e:	53                   	push   %ebx
f0105f2f:	83 ec 08             	sub    $0x8,%esp
f0105f32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105f35:	89 1c 24             	mov    %ebx,(%esp)
f0105f38:	e8 73 ff ff ff       	call   f0105eb0 <strlen>
	strcpy(dst + len, src);
f0105f3d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f40:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105f44:	01 d8                	add    %ebx,%eax
f0105f46:	89 04 24             	mov    %eax,(%esp)
f0105f49:	e8 bd ff ff ff       	call   f0105f0b <strcpy>
	return dst;
}
f0105f4e:	89 d8                	mov    %ebx,%eax
f0105f50:	83 c4 08             	add    $0x8,%esp
f0105f53:	5b                   	pop    %ebx
f0105f54:	5d                   	pop    %ebp
f0105f55:	c3                   	ret    

f0105f56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105f56:	55                   	push   %ebp
f0105f57:	89 e5                	mov    %esp,%ebp
f0105f59:	56                   	push   %esi
f0105f5a:	53                   	push   %ebx
f0105f5b:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f5e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105f64:	85 db                	test   %ebx,%ebx
f0105f66:	74 17                	je     f0105f7f <strncpy+0x29>
f0105f68:	01 f3                	add    %esi,%ebx
f0105f6a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f0105f6c:	83 c1 01             	add    $0x1,%ecx
f0105f6f:	0f b6 02             	movzbl (%edx),%eax
f0105f72:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105f75:	80 3a 01             	cmpb   $0x1,(%edx)
f0105f78:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0105f7b:	39 d9                	cmp    %ebx,%ecx
f0105f7d:	75 ed                	jne    f0105f6c <strncpy+0x16>
	}
	return ret;
}
f0105f7f:	89 f0                	mov    %esi,%eax
f0105f81:	5b                   	pop    %ebx
f0105f82:	5e                   	pop    %esi
f0105f83:	5d                   	pop    %ebp
f0105f84:	c3                   	ret    

f0105f85 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105f85:	55                   	push   %ebp
f0105f86:	89 e5                	mov    %esp,%ebp
f0105f88:	57                   	push   %edi
f0105f89:	56                   	push   %esi
f0105f8a:	53                   	push   %ebx
f0105f8b:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105f8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105f91:	8b 75 10             	mov    0x10(%ebp),%esi
f0105f94:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105f96:	85 f6                	test   %esi,%esi
f0105f98:	74 34                	je     f0105fce <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
f0105f9a:	83 fe 01             	cmp    $0x1,%esi
f0105f9d:	74 26                	je     f0105fc5 <strlcpy+0x40>
f0105f9f:	0f b6 0b             	movzbl (%ebx),%ecx
f0105fa2:	84 c9                	test   %cl,%cl
f0105fa4:	74 23                	je     f0105fc9 <strlcpy+0x44>
f0105fa6:	83 ee 02             	sub    $0x2,%esi
f0105fa9:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
f0105fae:	83 c0 01             	add    $0x1,%eax
f0105fb1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105fb4:	39 f2                	cmp    %esi,%edx
f0105fb6:	74 13                	je     f0105fcb <strlcpy+0x46>
f0105fb8:	83 c2 01             	add    $0x1,%edx
f0105fbb:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105fbf:	84 c9                	test   %cl,%cl
f0105fc1:	75 eb                	jne    f0105fae <strlcpy+0x29>
f0105fc3:	eb 06                	jmp    f0105fcb <strlcpy+0x46>
f0105fc5:	89 f8                	mov    %edi,%eax
f0105fc7:	eb 02                	jmp    f0105fcb <strlcpy+0x46>
f0105fc9:	89 f8                	mov    %edi,%eax
		*dst = '\0';
f0105fcb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105fce:	29 f8                	sub    %edi,%eax
}
f0105fd0:	5b                   	pop    %ebx
f0105fd1:	5e                   	pop    %esi
f0105fd2:	5f                   	pop    %edi
f0105fd3:	5d                   	pop    %ebp
f0105fd4:	c3                   	ret    

f0105fd5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105fd5:	55                   	push   %ebp
f0105fd6:	89 e5                	mov    %esp,%ebp
f0105fd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105fdb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105fde:	0f b6 01             	movzbl (%ecx),%eax
f0105fe1:	84 c0                	test   %al,%al
f0105fe3:	74 15                	je     f0105ffa <strcmp+0x25>
f0105fe5:	3a 02                	cmp    (%edx),%al
f0105fe7:	75 11                	jne    f0105ffa <strcmp+0x25>
		p++, q++;
f0105fe9:	83 c1 01             	add    $0x1,%ecx
f0105fec:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105fef:	0f b6 01             	movzbl (%ecx),%eax
f0105ff2:	84 c0                	test   %al,%al
f0105ff4:	74 04                	je     f0105ffa <strcmp+0x25>
f0105ff6:	3a 02                	cmp    (%edx),%al
f0105ff8:	74 ef                	je     f0105fe9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105ffa:	0f b6 c0             	movzbl %al,%eax
f0105ffd:	0f b6 12             	movzbl (%edx),%edx
f0106000:	29 d0                	sub    %edx,%eax
}
f0106002:	5d                   	pop    %ebp
f0106003:	c3                   	ret    

f0106004 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0106004:	55                   	push   %ebp
f0106005:	89 e5                	mov    %esp,%ebp
f0106007:	56                   	push   %esi
f0106008:	53                   	push   %ebx
f0106009:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010600c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010600f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f0106012:	85 f6                	test   %esi,%esi
f0106014:	74 29                	je     f010603f <strncmp+0x3b>
f0106016:	0f b6 03             	movzbl (%ebx),%eax
f0106019:	84 c0                	test   %al,%al
f010601b:	74 30                	je     f010604d <strncmp+0x49>
f010601d:	3a 02                	cmp    (%edx),%al
f010601f:	75 2c                	jne    f010604d <strncmp+0x49>
f0106021:	8d 43 01             	lea    0x1(%ebx),%eax
f0106024:	01 de                	add    %ebx,%esi
		n--, p++, q++;
f0106026:	89 c3                	mov    %eax,%ebx
f0106028:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f010602b:	39 f0                	cmp    %esi,%eax
f010602d:	74 17                	je     f0106046 <strncmp+0x42>
f010602f:	0f b6 08             	movzbl (%eax),%ecx
f0106032:	84 c9                	test   %cl,%cl
f0106034:	74 17                	je     f010604d <strncmp+0x49>
f0106036:	83 c0 01             	add    $0x1,%eax
f0106039:	3a 0a                	cmp    (%edx),%cl
f010603b:	74 e9                	je     f0106026 <strncmp+0x22>
f010603d:	eb 0e                	jmp    f010604d <strncmp+0x49>
	if (n == 0)
		return 0;
f010603f:	b8 00 00 00 00       	mov    $0x0,%eax
f0106044:	eb 0f                	jmp    f0106055 <strncmp+0x51>
f0106046:	b8 00 00 00 00       	mov    $0x0,%eax
f010604b:	eb 08                	jmp    f0106055 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010604d:	0f b6 03             	movzbl (%ebx),%eax
f0106050:	0f b6 12             	movzbl (%edx),%edx
f0106053:	29 d0                	sub    %edx,%eax
}
f0106055:	5b                   	pop    %ebx
f0106056:	5e                   	pop    %esi
f0106057:	5d                   	pop    %ebp
f0106058:	c3                   	ret    

f0106059 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0106059:	55                   	push   %ebp
f010605a:	89 e5                	mov    %esp,%ebp
f010605c:	53                   	push   %ebx
f010605d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106060:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f0106063:	0f b6 18             	movzbl (%eax),%ebx
f0106066:	84 db                	test   %bl,%bl
f0106068:	74 1d                	je     f0106087 <strchr+0x2e>
f010606a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
f010606c:	38 d3                	cmp    %dl,%bl
f010606e:	75 06                	jne    f0106076 <strchr+0x1d>
f0106070:	eb 1a                	jmp    f010608c <strchr+0x33>
f0106072:	38 ca                	cmp    %cl,%dl
f0106074:	74 16                	je     f010608c <strchr+0x33>
	for (; *s; s++)
f0106076:	83 c0 01             	add    $0x1,%eax
f0106079:	0f b6 10             	movzbl (%eax),%edx
f010607c:	84 d2                	test   %dl,%dl
f010607e:	75 f2                	jne    f0106072 <strchr+0x19>
			return (char *) s;
	return 0;
f0106080:	b8 00 00 00 00       	mov    $0x0,%eax
f0106085:	eb 05                	jmp    f010608c <strchr+0x33>
f0106087:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010608c:	5b                   	pop    %ebx
f010608d:	5d                   	pop    %ebp
f010608e:	c3                   	ret    

f010608f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010608f:	55                   	push   %ebp
f0106090:	89 e5                	mov    %esp,%ebp
f0106092:	53                   	push   %ebx
f0106093:	8b 45 08             	mov    0x8(%ebp),%eax
f0106096:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f0106099:	0f b6 18             	movzbl (%eax),%ebx
f010609c:	84 db                	test   %bl,%bl
f010609e:	74 16                	je     f01060b6 <strfind+0x27>
f01060a0:	89 d1                	mov    %edx,%ecx
		if (*s == c)
f01060a2:	38 d3                	cmp    %dl,%bl
f01060a4:	75 06                	jne    f01060ac <strfind+0x1d>
f01060a6:	eb 0e                	jmp    f01060b6 <strfind+0x27>
f01060a8:	38 ca                	cmp    %cl,%dl
f01060aa:	74 0a                	je     f01060b6 <strfind+0x27>
	for (; *s; s++)
f01060ac:	83 c0 01             	add    $0x1,%eax
f01060af:	0f b6 10             	movzbl (%eax),%edx
f01060b2:	84 d2                	test   %dl,%dl
f01060b4:	75 f2                	jne    f01060a8 <strfind+0x19>
			break;
	return (char *) s;
}
f01060b6:	5b                   	pop    %ebx
f01060b7:	5d                   	pop    %ebp
f01060b8:	c3                   	ret    

f01060b9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01060b9:	55                   	push   %ebp
f01060ba:	89 e5                	mov    %esp,%ebp
f01060bc:	57                   	push   %edi
f01060bd:	56                   	push   %esi
f01060be:	53                   	push   %ebx
f01060bf:	8b 7d 08             	mov    0x8(%ebp),%edi
f01060c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01060c5:	85 c9                	test   %ecx,%ecx
f01060c7:	74 36                	je     f01060ff <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01060c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01060cf:	75 28                	jne    f01060f9 <memset+0x40>
f01060d1:	f6 c1 03             	test   $0x3,%cl
f01060d4:	75 23                	jne    f01060f9 <memset+0x40>
		c &= 0xFF;
f01060d6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01060da:	89 d3                	mov    %edx,%ebx
f01060dc:	c1 e3 08             	shl    $0x8,%ebx
f01060df:	89 d6                	mov    %edx,%esi
f01060e1:	c1 e6 18             	shl    $0x18,%esi
f01060e4:	89 d0                	mov    %edx,%eax
f01060e6:	c1 e0 10             	shl    $0x10,%eax
f01060e9:	09 f0                	or     %esi,%eax
f01060eb:	09 c2                	or     %eax,%edx
f01060ed:	89 d0                	mov    %edx,%eax
f01060ef:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01060f1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01060f4:	fc                   	cld    
f01060f5:	f3 ab                	rep stos %eax,%es:(%edi)
f01060f7:	eb 06                	jmp    f01060ff <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01060f9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01060fc:	fc                   	cld    
f01060fd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01060ff:	89 f8                	mov    %edi,%eax
f0106101:	5b                   	pop    %ebx
f0106102:	5e                   	pop    %esi
f0106103:	5f                   	pop    %edi
f0106104:	5d                   	pop    %ebp
f0106105:	c3                   	ret    

f0106106 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106106:	55                   	push   %ebp
f0106107:	89 e5                	mov    %esp,%ebp
f0106109:	57                   	push   %edi
f010610a:	56                   	push   %esi
f010610b:	8b 45 08             	mov    0x8(%ebp),%eax
f010610e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106111:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106114:	39 c6                	cmp    %eax,%esi
f0106116:	73 35                	jae    f010614d <memmove+0x47>
f0106118:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010611b:	39 d0                	cmp    %edx,%eax
f010611d:	73 2e                	jae    f010614d <memmove+0x47>
		s += n;
		d += n;
f010611f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0106122:	89 d6                	mov    %edx,%esi
f0106124:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106126:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010612c:	75 13                	jne    f0106141 <memmove+0x3b>
f010612e:	f6 c1 03             	test   $0x3,%cl
f0106131:	75 0e                	jne    f0106141 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0106133:	83 ef 04             	sub    $0x4,%edi
f0106136:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106139:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010613c:	fd                   	std    
f010613d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010613f:	eb 09                	jmp    f010614a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0106141:	83 ef 01             	sub    $0x1,%edi
f0106144:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0106147:	fd                   	std    
f0106148:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010614a:	fc                   	cld    
f010614b:	eb 1d                	jmp    f010616a <memmove+0x64>
f010614d:	89 f2                	mov    %esi,%edx
f010614f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106151:	f6 c2 03             	test   $0x3,%dl
f0106154:	75 0f                	jne    f0106165 <memmove+0x5f>
f0106156:	f6 c1 03             	test   $0x3,%cl
f0106159:	75 0a                	jne    f0106165 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010615b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010615e:	89 c7                	mov    %eax,%edi
f0106160:	fc                   	cld    
f0106161:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106163:	eb 05                	jmp    f010616a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
f0106165:	89 c7                	mov    %eax,%edi
f0106167:	fc                   	cld    
f0106168:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010616a:	5e                   	pop    %esi
f010616b:	5f                   	pop    %edi
f010616c:	5d                   	pop    %ebp
f010616d:	c3                   	ret    

f010616e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010616e:	55                   	push   %ebp
f010616f:	89 e5                	mov    %esp,%ebp
f0106171:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106174:	8b 45 10             	mov    0x10(%ebp),%eax
f0106177:	89 44 24 08          	mov    %eax,0x8(%esp)
f010617b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010617e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106182:	8b 45 08             	mov    0x8(%ebp),%eax
f0106185:	89 04 24             	mov    %eax,(%esp)
f0106188:	e8 79 ff ff ff       	call   f0106106 <memmove>
}
f010618d:	c9                   	leave  
f010618e:	c3                   	ret    

f010618f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010618f:	55                   	push   %ebp
f0106190:	89 e5                	mov    %esp,%ebp
f0106192:	57                   	push   %edi
f0106193:	56                   	push   %esi
f0106194:	53                   	push   %ebx
f0106195:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106198:	8b 75 0c             	mov    0xc(%ebp),%esi
f010619b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010619e:	8d 78 ff             	lea    -0x1(%eax),%edi
f01061a1:	85 c0                	test   %eax,%eax
f01061a3:	74 36                	je     f01061db <memcmp+0x4c>
		if (*s1 != *s2)
f01061a5:	0f b6 03             	movzbl (%ebx),%eax
f01061a8:	0f b6 0e             	movzbl (%esi),%ecx
f01061ab:	ba 00 00 00 00       	mov    $0x0,%edx
f01061b0:	38 c8                	cmp    %cl,%al
f01061b2:	74 1c                	je     f01061d0 <memcmp+0x41>
f01061b4:	eb 10                	jmp    f01061c6 <memcmp+0x37>
f01061b6:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f01061bb:	83 c2 01             	add    $0x1,%edx
f01061be:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01061c2:	38 c8                	cmp    %cl,%al
f01061c4:	74 0a                	je     f01061d0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f01061c6:	0f b6 c0             	movzbl %al,%eax
f01061c9:	0f b6 c9             	movzbl %cl,%ecx
f01061cc:	29 c8                	sub    %ecx,%eax
f01061ce:	eb 10                	jmp    f01061e0 <memcmp+0x51>
	while (n-- > 0) {
f01061d0:	39 fa                	cmp    %edi,%edx
f01061d2:	75 e2                	jne    f01061b6 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
f01061d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01061d9:	eb 05                	jmp    f01061e0 <memcmp+0x51>
f01061db:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01061e0:	5b                   	pop    %ebx
f01061e1:	5e                   	pop    %esi
f01061e2:	5f                   	pop    %edi
f01061e3:	5d                   	pop    %ebp
f01061e4:	c3                   	ret    

f01061e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01061e5:	55                   	push   %ebp
f01061e6:	89 e5                	mov    %esp,%ebp
f01061e8:	53                   	push   %ebx
f01061e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01061ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
f01061ef:	89 c2                	mov    %eax,%edx
f01061f1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01061f4:	39 d0                	cmp    %edx,%eax
f01061f6:	73 13                	jae    f010620b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
f01061f8:	89 d9                	mov    %ebx,%ecx
f01061fa:	38 18                	cmp    %bl,(%eax)
f01061fc:	75 06                	jne    f0106204 <memfind+0x1f>
f01061fe:	eb 0b                	jmp    f010620b <memfind+0x26>
f0106200:	38 08                	cmp    %cl,(%eax)
f0106202:	74 07                	je     f010620b <memfind+0x26>
	for (; s < ends; s++)
f0106204:	83 c0 01             	add    $0x1,%eax
f0106207:	39 d0                	cmp    %edx,%eax
f0106209:	75 f5                	jne    f0106200 <memfind+0x1b>
			break;
	return (void *) s;
}
f010620b:	5b                   	pop    %ebx
f010620c:	5d                   	pop    %ebp
f010620d:	c3                   	ret    

f010620e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010620e:	55                   	push   %ebp
f010620f:	89 e5                	mov    %esp,%ebp
f0106211:	57                   	push   %edi
f0106212:	56                   	push   %esi
f0106213:	53                   	push   %ebx
f0106214:	8b 55 08             	mov    0x8(%ebp),%edx
f0106217:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010621a:	0f b6 0a             	movzbl (%edx),%ecx
f010621d:	80 f9 09             	cmp    $0x9,%cl
f0106220:	74 05                	je     f0106227 <strtol+0x19>
f0106222:	80 f9 20             	cmp    $0x20,%cl
f0106225:	75 10                	jne    f0106237 <strtol+0x29>
		s++;
f0106227:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f010622a:	0f b6 0a             	movzbl (%edx),%ecx
f010622d:	80 f9 09             	cmp    $0x9,%cl
f0106230:	74 f5                	je     f0106227 <strtol+0x19>
f0106232:	80 f9 20             	cmp    $0x20,%cl
f0106235:	74 f0                	je     f0106227 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
f0106237:	80 f9 2b             	cmp    $0x2b,%cl
f010623a:	75 0a                	jne    f0106246 <strtol+0x38>
		s++;
f010623c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f010623f:	bf 00 00 00 00       	mov    $0x0,%edi
f0106244:	eb 11                	jmp    f0106257 <strtol+0x49>
f0106246:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
f010624b:	80 f9 2d             	cmp    $0x2d,%cl
f010624e:	75 07                	jne    f0106257 <strtol+0x49>
		s++, neg = 1;
f0106250:	83 c2 01             	add    $0x1,%edx
f0106253:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106257:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f010625c:	75 15                	jne    f0106273 <strtol+0x65>
f010625e:	80 3a 30             	cmpb   $0x30,(%edx)
f0106261:	75 10                	jne    f0106273 <strtol+0x65>
f0106263:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0106267:	75 0a                	jne    f0106273 <strtol+0x65>
		s += 2, base = 16;
f0106269:	83 c2 02             	add    $0x2,%edx
f010626c:	b8 10 00 00 00       	mov    $0x10,%eax
f0106271:	eb 10                	jmp    f0106283 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
f0106273:	85 c0                	test   %eax,%eax
f0106275:	75 0c                	jne    f0106283 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106277:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
f0106279:	80 3a 30             	cmpb   $0x30,(%edx)
f010627c:	75 05                	jne    f0106283 <strtol+0x75>
		s++, base = 8;
f010627e:	83 c2 01             	add    $0x1,%edx
f0106281:	b0 08                	mov    $0x8,%al
		base = 10;
f0106283:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106288:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010628b:	0f b6 0a             	movzbl (%edx),%ecx
f010628e:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0106291:	89 f0                	mov    %esi,%eax
f0106293:	3c 09                	cmp    $0x9,%al
f0106295:	77 08                	ja     f010629f <strtol+0x91>
			dig = *s - '0';
f0106297:	0f be c9             	movsbl %cl,%ecx
f010629a:	83 e9 30             	sub    $0x30,%ecx
f010629d:	eb 20                	jmp    f01062bf <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
f010629f:	8d 71 9f             	lea    -0x61(%ecx),%esi
f01062a2:	89 f0                	mov    %esi,%eax
f01062a4:	3c 19                	cmp    $0x19,%al
f01062a6:	77 08                	ja     f01062b0 <strtol+0xa2>
			dig = *s - 'a' + 10;
f01062a8:	0f be c9             	movsbl %cl,%ecx
f01062ab:	83 e9 57             	sub    $0x57,%ecx
f01062ae:	eb 0f                	jmp    f01062bf <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
f01062b0:	8d 71 bf             	lea    -0x41(%ecx),%esi
f01062b3:	89 f0                	mov    %esi,%eax
f01062b5:	3c 19                	cmp    $0x19,%al
f01062b7:	77 16                	ja     f01062cf <strtol+0xc1>
			dig = *s - 'A' + 10;
f01062b9:	0f be c9             	movsbl %cl,%ecx
f01062bc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01062bf:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f01062c2:	7d 0f                	jge    f01062d3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01062c4:	83 c2 01             	add    $0x1,%edx
f01062c7:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f01062cb:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f01062cd:	eb bc                	jmp    f010628b <strtol+0x7d>
f01062cf:	89 d8                	mov    %ebx,%eax
f01062d1:	eb 02                	jmp    f01062d5 <strtol+0xc7>
f01062d3:	89 d8                	mov    %ebx,%eax

	if (endptr)
f01062d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01062d9:	74 05                	je     f01062e0 <strtol+0xd2>
		*endptr = (char *) s;
f01062db:	8b 75 0c             	mov    0xc(%ebp),%esi
f01062de:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01062e0:	f7 d8                	neg    %eax
f01062e2:	85 ff                	test   %edi,%edi
f01062e4:	0f 44 c3             	cmove  %ebx,%eax
}
f01062e7:	5b                   	pop    %ebx
f01062e8:	5e                   	pop    %esi
f01062e9:	5f                   	pop    %edi
f01062ea:	5d                   	pop    %ebp
f01062eb:	c3                   	ret    

f01062ec <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01062ec:	fa                   	cli    

	xorw    %ax, %ax
f01062ed:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01062ef:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01062f1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01062f3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01062f5:	0f 01 16             	lgdtl  (%esi)
f01062f8:	74 70                	je     f010636a <mpentry_end+0x4>
	movl    %cr0, %eax
f01062fa:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01062fd:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106301:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106304:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010630a:	08 00                	or     %al,(%eax)

f010630c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010630c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106310:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106312:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106314:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106316:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010631a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010631c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010631e:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0106323:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106326:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106329:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010632e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106331:	8b 25 84 6e 22 f0    	mov    0xf0226e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106337:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010633c:	b8 fb 01 10 f0       	mov    $0xf01001fb,%eax
	call    *%eax
f0106341:	ff d0                	call   *%eax

f0106343 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106343:	eb fe                	jmp    f0106343 <spin>
f0106345:	8d 76 00             	lea    0x0(%esi),%esi

f0106348 <gdt>:
	...
f0106350:	ff                   	(bad)  
f0106351:	ff 00                	incl   (%eax)
f0106353:	00 00                	add    %al,(%eax)
f0106355:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010635c:	00                   	.byte 0x0
f010635d:	92                   	xchg   %eax,%edx
f010635e:	cf                   	iret   
	...

f0106360 <gdtdesc>:
f0106360:	17                   	pop    %ss
f0106361:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106366 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106366:	90                   	nop
f0106367:	66 90                	xchg   %ax,%ax
f0106369:	66 90                	xchg   %ax,%ax
f010636b:	66 90                	xchg   %ax,%ax
f010636d:	66 90                	xchg   %ax,%ax
f010636f:	90                   	nop

f0106370 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106370:	55                   	push   %ebp
f0106371:	89 e5                	mov    %esp,%ebp
f0106373:	56                   	push   %esi
f0106374:	53                   	push   %ebx
f0106375:	83 ec 10             	sub    $0x10,%esp
	if (PGNUM(pa) >= npages)
f0106378:	8b 0d 88 6e 22 f0    	mov    0xf0226e88,%ecx
f010637e:	89 c3                	mov    %eax,%ebx
f0106380:	c1 eb 0c             	shr    $0xc,%ebx
f0106383:	39 cb                	cmp    %ecx,%ebx
f0106385:	72 20                	jb     f01063a7 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106387:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010638b:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0106392:	f0 
f0106393:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010639a:	00 
f010639b:	c7 04 24 c1 89 10 f0 	movl   $0xf01089c1,(%esp)
f01063a2:	e8 99 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01063a7:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01063ad:	01 d0                	add    %edx,%eax
	if (PGNUM(pa) >= npages)
f01063af:	89 c2                	mov    %eax,%edx
f01063b1:	c1 ea 0c             	shr    $0xc,%edx
f01063b4:	39 d1                	cmp    %edx,%ecx
f01063b6:	77 20                	ja     f01063d8 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01063bc:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f01063c3:	f0 
f01063c4:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01063cb:	00 
f01063cc:	c7 04 24 c1 89 10 f0 	movl   $0xf01089c1,(%esp)
f01063d3:	e8 68 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01063d8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01063de:	39 f3                	cmp    %esi,%ebx
f01063e0:	73 40                	jae    f0106422 <mpsearch1+0xb2>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01063e2:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01063e9:	00 
f01063ea:	c7 44 24 04 d1 89 10 	movl   $0xf01089d1,0x4(%esp)
f01063f1:	f0 
f01063f2:	89 1c 24             	mov    %ebx,(%esp)
f01063f5:	e8 95 fd ff ff       	call   f010618f <memcmp>
f01063fa:	85 c0                	test   %eax,%eax
f01063fc:	75 17                	jne    f0106415 <mpsearch1+0xa5>
f01063fe:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f0106403:	0f b6 0c 03          	movzbl (%ebx,%eax,1),%ecx
f0106407:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f0106409:	83 c0 01             	add    $0x1,%eax
f010640c:	83 f8 10             	cmp    $0x10,%eax
f010640f:	75 f2                	jne    f0106403 <mpsearch1+0x93>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106411:	84 d2                	test   %dl,%dl
f0106413:	74 14                	je     f0106429 <mpsearch1+0xb9>
	for (; mp < end; mp++)
f0106415:	83 c3 10             	add    $0x10,%ebx
f0106418:	39 f3                	cmp    %esi,%ebx
f010641a:	72 c6                	jb     f01063e2 <mpsearch1+0x72>
f010641c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106420:	eb 0b                	jmp    f010642d <mpsearch1+0xbd>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0106422:	b8 00 00 00 00       	mov    $0x0,%eax
f0106427:	eb 09                	jmp    f0106432 <mpsearch1+0xc2>
f0106429:	89 d8                	mov    %ebx,%eax
f010642b:	eb 05                	jmp    f0106432 <mpsearch1+0xc2>
f010642d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106432:	83 c4 10             	add    $0x10,%esp
f0106435:	5b                   	pop    %ebx
f0106436:	5e                   	pop    %esi
f0106437:	5d                   	pop    %ebp
f0106438:	c3                   	ret    

f0106439 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106439:	55                   	push   %ebp
f010643a:	89 e5                	mov    %esp,%ebp
f010643c:	57                   	push   %edi
f010643d:	56                   	push   %esi
f010643e:	53                   	push   %ebx
f010643f:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106442:	c7 05 c0 73 22 f0 20 	movl   $0xf0227020,0xf02273c0
f0106449:	70 22 f0 
	if (PGNUM(pa) >= npages)
f010644c:	83 3d 88 6e 22 f0 00 	cmpl   $0x0,0xf0226e88
f0106453:	75 24                	jne    f0106479 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106455:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f010645c:	00 
f010645d:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0106464:	f0 
f0106465:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f010646c:	00 
f010646d:	c7 04 24 c1 89 10 f0 	movl   $0xf01089c1,(%esp)
f0106474:	e8 c7 9b ff ff       	call   f0100040 <_panic>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106479:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106480:	85 c0                	test   %eax,%eax
f0106482:	74 16                	je     f010649a <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0106484:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106487:	ba 00 04 00 00       	mov    $0x400,%edx
f010648c:	e8 df fe ff ff       	call   f0106370 <mpsearch1>
f0106491:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106494:	85 c0                	test   %eax,%eax
f0106496:	75 3c                	jne    f01064d4 <mp_init+0x9b>
f0106498:	eb 20                	jmp    f01064ba <mp_init+0x81>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f010649a:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01064a1:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01064a4:	2d 00 04 00 00       	sub    $0x400,%eax
f01064a9:	ba 00 04 00 00       	mov    $0x400,%edx
f01064ae:	e8 bd fe ff ff       	call   f0106370 <mpsearch1>
f01064b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01064b6:	85 c0                	test   %eax,%eax
f01064b8:	75 1a                	jne    f01064d4 <mp_init+0x9b>
	return mpsearch1(0xF0000, 0x10000);
f01064ba:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064bf:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01064c4:	e8 a7 fe ff ff       	call   f0106370 <mpsearch1>
f01064c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f01064cc:	85 c0                	test   %eax,%eax
f01064ce:	0f 84 5f 02 00 00    	je     f0106733 <mp_init+0x2fa>
	if (mp->physaddr == 0 || mp->type != 0) {
f01064d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01064d7:	8b 70 04             	mov    0x4(%eax),%esi
f01064da:	85 f6                	test   %esi,%esi
f01064dc:	74 06                	je     f01064e4 <mp_init+0xab>
f01064de:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01064e2:	74 11                	je     f01064f5 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01064e4:	c7 04 24 34 88 10 f0 	movl   $0xf0108834,(%esp)
f01064eb:	e8 d9 da ff ff       	call   f0103fc9 <cprintf>
f01064f0:	e9 3e 02 00 00       	jmp    f0106733 <mp_init+0x2fa>
	if (PGNUM(pa) >= npages)
f01064f5:	89 f0                	mov    %esi,%eax
f01064f7:	c1 e8 0c             	shr    $0xc,%eax
f01064fa:	3b 05 88 6e 22 f0    	cmp    0xf0226e88,%eax
f0106500:	72 20                	jb     f0106522 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106502:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106506:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f010650d:	f0 
f010650e:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106515:	00 
f0106516:	c7 04 24 c1 89 10 f0 	movl   $0xf01089c1,(%esp)
f010651d:	e8 1e 9b ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106522:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106528:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010652f:	00 
f0106530:	c7 44 24 04 d6 89 10 	movl   $0xf01089d6,0x4(%esp)
f0106537:	f0 
f0106538:	89 1c 24             	mov    %ebx,(%esp)
f010653b:	e8 4f fc ff ff       	call   f010618f <memcmp>
f0106540:	85 c0                	test   %eax,%eax
f0106542:	74 11                	je     f0106555 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106544:	c7 04 24 64 88 10 f0 	movl   $0xf0108864,(%esp)
f010654b:	e8 79 da ff ff       	call   f0103fc9 <cprintf>
f0106550:	e9 de 01 00 00       	jmp    f0106733 <mp_init+0x2fa>
	if (sum(conf, conf->length) != 0) {
f0106555:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0106559:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f010655d:	0f b7 f8             	movzwl %ax,%edi
	for (i = 0; i < len; i++)
f0106560:	85 ff                	test   %edi,%edi
f0106562:	7e 30                	jle    f0106594 <mp_init+0x15b>
	sum = 0;
f0106564:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106569:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f010656e:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0106575:	f0 
f0106576:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f0106578:	83 c0 01             	add    $0x1,%eax
f010657b:	39 c7                	cmp    %eax,%edi
f010657d:	7f ef                	jg     f010656e <mp_init+0x135>
	if (sum(conf, conf->length) != 0) {
f010657f:	84 d2                	test   %dl,%dl
f0106581:	74 11                	je     f0106594 <mp_init+0x15b>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106583:	c7 04 24 98 88 10 f0 	movl   $0xf0108898,(%esp)
f010658a:	e8 3a da ff ff       	call   f0103fc9 <cprintf>
f010658f:	e9 9f 01 00 00       	jmp    f0106733 <mp_init+0x2fa>
	if (conf->version != 1 && conf->version != 4) {
f0106594:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0106598:	3c 04                	cmp    $0x4,%al
f010659a:	74 1e                	je     f01065ba <mp_init+0x181>
f010659c:	3c 01                	cmp    $0x1,%al
f010659e:	66 90                	xchg   %ax,%ax
f01065a0:	74 18                	je     f01065ba <mp_init+0x181>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01065a2:	0f b6 c0             	movzbl %al,%eax
f01065a5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065a9:	c7 04 24 bc 88 10 f0 	movl   $0xf01088bc,(%esp)
f01065b0:	e8 14 da ff ff       	call   f0103fc9 <cprintf>
f01065b5:	e9 79 01 00 00       	jmp    f0106733 <mp_init+0x2fa>
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f01065ba:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f01065be:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f01065c2:	01 df                	add    %ebx,%edi
	for (i = 0; i < len; i++)
f01065c4:	85 f6                	test   %esi,%esi
f01065c6:	7e 19                	jle    f01065e1 <mp_init+0x1a8>
	sum = 0;
f01065c8:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01065cd:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f01065d2:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f01065d6:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f01065d8:	83 c0 01             	add    $0x1,%eax
f01065db:	39 c6                	cmp    %eax,%esi
f01065dd:	7f f3                	jg     f01065d2 <mp_init+0x199>
f01065df:	eb 05                	jmp    f01065e6 <mp_init+0x1ad>
	sum = 0;
f01065e1:	ba 00 00 00 00       	mov    $0x0,%edx
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f01065e6:	38 53 2a             	cmp    %dl,0x2a(%ebx)
f01065e9:	74 11                	je     f01065fc <mp_init+0x1c3>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01065eb:	c7 04 24 dc 88 10 f0 	movl   $0xf01088dc,(%esp)
f01065f2:	e8 d2 d9 ff ff       	call   f0103fc9 <cprintf>
f01065f7:	e9 37 01 00 00       	jmp    f0106733 <mp_init+0x2fa>
	if ((conf = mpconfig(&mp)) == 0)
f01065fc:	85 db                	test   %ebx,%ebx
f01065fe:	0f 84 2f 01 00 00    	je     f0106733 <mp_init+0x2fa>
		return;
	ismp = 1;
f0106604:	c7 05 00 70 22 f0 01 	movl   $0x1,0xf0227000
f010660b:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010660e:	8b 43 24             	mov    0x24(%ebx),%eax
f0106611:	a3 00 80 26 f0       	mov    %eax,0xf0268000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106616:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0106619:	66 83 7b 22 00       	cmpw   $0x0,0x22(%ebx)
f010661e:	0f 84 94 00 00 00    	je     f01066b8 <mp_init+0x27f>
f0106624:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f0106629:	0f b6 07             	movzbl (%edi),%eax
f010662c:	84 c0                	test   %al,%al
f010662e:	74 06                	je     f0106636 <mp_init+0x1fd>
f0106630:	3c 04                	cmp    $0x4,%al
f0106632:	77 54                	ja     f0106688 <mp_init+0x24f>
f0106634:	eb 4d                	jmp    f0106683 <mp_init+0x24a>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106636:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010663a:	74 11                	je     f010664d <mp_init+0x214>
				bootcpu = &cpus[ncpu];
f010663c:	6b 05 c4 73 22 f0 74 	imul   $0x74,0xf02273c4,%eax
f0106643:	05 20 70 22 f0       	add    $0xf0227020,%eax
f0106648:	a3 c0 73 22 f0       	mov    %eax,0xf02273c0
			if (ncpu < NCPU) {
f010664d:	a1 c4 73 22 f0       	mov    0xf02273c4,%eax
f0106652:	83 f8 07             	cmp    $0x7,%eax
f0106655:	7f 13                	jg     f010666a <mp_init+0x231>
				cpus[ncpu].cpu_id = ncpu;
f0106657:	6b d0 74             	imul   $0x74,%eax,%edx
f010665a:	88 82 20 70 22 f0    	mov    %al,-0xfdd8fe0(%edx)
				ncpu++;
f0106660:	83 c0 01             	add    $0x1,%eax
f0106663:	a3 c4 73 22 f0       	mov    %eax,0xf02273c4
f0106668:	eb 14                	jmp    f010667e <mp_init+0x245>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010666a:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f010666e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106672:	c7 04 24 0c 89 10 f0 	movl   $0xf010890c,(%esp)
f0106679:	e8 4b d9 ff ff       	call   f0103fc9 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010667e:	83 c7 14             	add    $0x14,%edi
			continue;
f0106681:	eb 26                	jmp    f01066a9 <mp_init+0x270>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106683:	83 c7 08             	add    $0x8,%edi
			continue;
f0106686:	eb 21                	jmp    f01066a9 <mp_init+0x270>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106688:	0f b6 c0             	movzbl %al,%eax
f010668b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010668f:	c7 04 24 34 89 10 f0 	movl   $0xf0108934,(%esp)
f0106696:	e8 2e d9 ff ff       	call   f0103fc9 <cprintf>
			ismp = 0;
f010669b:	c7 05 00 70 22 f0 00 	movl   $0x0,0xf0227000
f01066a2:	00 00 00 
			i = conf->entry;
f01066a5:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01066a9:	83 c6 01             	add    $0x1,%esi
f01066ac:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01066b0:	39 f0                	cmp    %esi,%eax
f01066b2:	0f 87 71 ff ff ff    	ja     f0106629 <mp_init+0x1f0>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01066b8:	a1 c0 73 22 f0       	mov    0xf02273c0,%eax
f01066bd:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01066c4:	83 3d 00 70 22 f0 00 	cmpl   $0x0,0xf0227000
f01066cb:	75 22                	jne    f01066ef <mp_init+0x2b6>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01066cd:	c7 05 c4 73 22 f0 01 	movl   $0x1,0xf02273c4
f01066d4:	00 00 00 
		lapicaddr = 0;
f01066d7:	c7 05 00 80 26 f0 00 	movl   $0x0,0xf0268000
f01066de:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01066e1:	c7 04 24 54 89 10 f0 	movl   $0xf0108954,(%esp)
f01066e8:	e8 dc d8 ff ff       	call   f0103fc9 <cprintf>
		return;
f01066ed:	eb 44                	jmp    f0106733 <mp_init+0x2fa>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01066ef:	8b 15 c4 73 22 f0    	mov    0xf02273c4,%edx
f01066f5:	89 54 24 08          	mov    %edx,0x8(%esp)
f01066f9:	0f b6 00             	movzbl (%eax),%eax
f01066fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106700:	c7 04 24 db 89 10 f0 	movl   $0xf01089db,(%esp)
f0106707:	e8 bd d8 ff ff       	call   f0103fc9 <cprintf>

	if (mp->imcrp) {
f010670c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010670f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106713:	74 1e                	je     f0106733 <mp_init+0x2fa>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106715:	c7 04 24 80 89 10 f0 	movl   $0xf0108980,(%esp)
f010671c:	e8 a8 d8 ff ff       	call   f0103fc9 <cprintf>
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106721:	ba 22 00 00 00       	mov    $0x22,%edx
f0106726:	b8 70 00 00 00       	mov    $0x70,%eax
f010672b:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010672c:	b2 23                	mov    $0x23,%dl
f010672e:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010672f:	83 c8 01             	or     $0x1,%eax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106732:	ee                   	out    %al,(%dx)
	}
}
f0106733:	83 c4 2c             	add    $0x2c,%esp
f0106736:	5b                   	pop    %ebx
f0106737:	5e                   	pop    %esi
f0106738:	5f                   	pop    %edi
f0106739:	5d                   	pop    %ebp
f010673a:	c3                   	ret    

f010673b <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010673b:	55                   	push   %ebp
f010673c:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010673e:	8b 0d 04 80 26 f0    	mov    0xf0268004,%ecx
f0106744:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106747:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106749:	a1 04 80 26 f0       	mov    0xf0268004,%eax
f010674e:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106751:	5d                   	pop    %ebp
f0106752:	c3                   	ret    

f0106753 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106753:	55                   	push   %ebp
f0106754:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106756:	a1 04 80 26 f0       	mov    0xf0268004,%eax
f010675b:	85 c0                	test   %eax,%eax
f010675d:	74 08                	je     f0106767 <cpunum+0x14>
		return lapic[ID] >> 24;
f010675f:	8b 40 20             	mov    0x20(%eax),%eax
f0106762:	c1 e8 18             	shr    $0x18,%eax
f0106765:	eb 05                	jmp    f010676c <cpunum+0x19>
	return 0;
f0106767:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010676c:	5d                   	pop    %ebp
f010676d:	c3                   	ret    

f010676e <lapic_init>:
	if (!lapicaddr)
f010676e:	a1 00 80 26 f0       	mov    0xf0268000,%eax
f0106773:	85 c0                	test   %eax,%eax
f0106775:	0f 84 23 01 00 00    	je     f010689e <lapic_init+0x130>
{
f010677b:	55                   	push   %ebp
f010677c:	89 e5                	mov    %esp,%ebp
f010677e:	83 ec 18             	sub    $0x18,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0106781:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106788:	00 
f0106789:	89 04 24             	mov    %eax,(%esp)
f010678c:	e8 fb ac ff ff       	call   f010148c <mmio_map_region>
f0106791:	a3 04 80 26 f0       	mov    %eax,0xf0268004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106796:	ba 27 01 00 00       	mov    $0x127,%edx
f010679b:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01067a0:	e8 96 ff ff ff       	call   f010673b <lapicw>
	lapicw(TDCR, X1);
f01067a5:	ba 0b 00 00 00       	mov    $0xb,%edx
f01067aa:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01067af:	e8 87 ff ff ff       	call   f010673b <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01067b4:	ba 20 00 02 00       	mov    $0x20020,%edx
f01067b9:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01067be:	e8 78 ff ff ff       	call   f010673b <lapicw>
	lapicw(TICR, 10000000); 
f01067c3:	ba 80 96 98 00       	mov    $0x989680,%edx
f01067c8:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01067cd:	e8 69 ff ff ff       	call   f010673b <lapicw>
	if (thiscpu != bootcpu)
f01067d2:	e8 7c ff ff ff       	call   f0106753 <cpunum>
f01067d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01067da:	05 20 70 22 f0       	add    $0xf0227020,%eax
f01067df:	39 05 c0 73 22 f0    	cmp    %eax,0xf02273c0
f01067e5:	74 0f                	je     f01067f6 <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f01067e7:	ba 00 00 01 00       	mov    $0x10000,%edx
f01067ec:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01067f1:	e8 45 ff ff ff       	call   f010673b <lapicw>
	lapicw(LINT1, MASKED);
f01067f6:	ba 00 00 01 00       	mov    $0x10000,%edx
f01067fb:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106800:	e8 36 ff ff ff       	call   f010673b <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106805:	a1 04 80 26 f0       	mov    0xf0268004,%eax
f010680a:	8b 40 30             	mov    0x30(%eax),%eax
f010680d:	c1 e8 10             	shr    $0x10,%eax
f0106810:	3c 03                	cmp    $0x3,%al
f0106812:	76 0f                	jbe    f0106823 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f0106814:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106819:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010681e:	e8 18 ff ff ff       	call   f010673b <lapicw>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106823:	ba 33 00 00 00       	mov    $0x33,%edx
f0106828:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010682d:	e8 09 ff ff ff       	call   f010673b <lapicw>
	lapicw(ESR, 0);
f0106832:	ba 00 00 00 00       	mov    $0x0,%edx
f0106837:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010683c:	e8 fa fe ff ff       	call   f010673b <lapicw>
	lapicw(ESR, 0);
f0106841:	ba 00 00 00 00       	mov    $0x0,%edx
f0106846:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010684b:	e8 eb fe ff ff       	call   f010673b <lapicw>
	lapicw(EOI, 0);
f0106850:	ba 00 00 00 00       	mov    $0x0,%edx
f0106855:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010685a:	e8 dc fe ff ff       	call   f010673b <lapicw>
	lapicw(ICRHI, 0);
f010685f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106864:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106869:	e8 cd fe ff ff       	call   f010673b <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010686e:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106873:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106878:	e8 be fe ff ff       	call   f010673b <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010687d:	8b 15 04 80 26 f0    	mov    0xf0268004,%edx
f0106883:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106889:	f6 c4 10             	test   $0x10,%ah
f010688c:	75 f5                	jne    f0106883 <lapic_init+0x115>
	lapicw(TPR, 0);
f010688e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106893:	b8 20 00 00 00       	mov    $0x20,%eax
f0106898:	e8 9e fe ff ff       	call   f010673b <lapicw>
}
f010689d:	c9                   	leave  
f010689e:	f3 c3                	repz ret 

f01068a0 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01068a0:	83 3d 04 80 26 f0 00 	cmpl   $0x0,0xf0268004
f01068a7:	74 13                	je     f01068bc <lapic_eoi+0x1c>
{
f01068a9:	55                   	push   %ebp
f01068aa:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f01068ac:	ba 00 00 00 00       	mov    $0x0,%edx
f01068b1:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01068b6:	e8 80 fe ff ff       	call   f010673b <lapicw>
}
f01068bb:	5d                   	pop    %ebp
f01068bc:	f3 c3                	repz ret 

f01068be <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01068be:	55                   	push   %ebp
f01068bf:	89 e5                	mov    %esp,%ebp
f01068c1:	56                   	push   %esi
f01068c2:	53                   	push   %ebx
f01068c3:	83 ec 10             	sub    $0x10,%esp
f01068c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01068c9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01068cc:	ba 70 00 00 00       	mov    $0x70,%edx
f01068d1:	b8 0f 00 00 00       	mov    $0xf,%eax
f01068d6:	ee                   	out    %al,(%dx)
f01068d7:	b2 71                	mov    $0x71,%dl
f01068d9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01068de:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f01068df:	83 3d 88 6e 22 f0 00 	cmpl   $0x0,0xf0226e88
f01068e6:	75 24                	jne    f010690c <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01068e8:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01068ef:	00 
f01068f0:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f01068f7:	f0 
f01068f8:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01068ff:	00 
f0106900:	c7 04 24 f8 89 10 f0 	movl   $0xf01089f8,(%esp)
f0106907:	e8 34 97 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010690c:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106913:	00 00 
	wrv[1] = addr >> 4;
f0106915:	89 f0                	mov    %esi,%eax
f0106917:	c1 e8 04             	shr    $0x4,%eax
f010691a:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106920:	c1 e3 18             	shl    $0x18,%ebx
f0106923:	89 da                	mov    %ebx,%edx
f0106925:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010692a:	e8 0c fe ff ff       	call   f010673b <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010692f:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106934:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106939:	e8 fd fd ff ff       	call   f010673b <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010693e:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106943:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106948:	e8 ee fd ff ff       	call   f010673b <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010694d:	c1 ee 0c             	shr    $0xc,%esi
f0106950:	81 ce 00 06 00 00    	or     $0x600,%esi
		lapicw(ICRHI, apicid << 24);
f0106956:	89 da                	mov    %ebx,%edx
f0106958:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010695d:	e8 d9 fd ff ff       	call   f010673b <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106962:	89 f2                	mov    %esi,%edx
f0106964:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106969:	e8 cd fd ff ff       	call   f010673b <lapicw>
		lapicw(ICRHI, apicid << 24);
f010696e:	89 da                	mov    %ebx,%edx
f0106970:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106975:	e8 c1 fd ff ff       	call   f010673b <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010697a:	89 f2                	mov    %esi,%edx
f010697c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106981:	e8 b5 fd ff ff       	call   f010673b <lapicw>
		microdelay(200);
	}
}
f0106986:	83 c4 10             	add    $0x10,%esp
f0106989:	5b                   	pop    %ebx
f010698a:	5e                   	pop    %esi
f010698b:	5d                   	pop    %ebp
f010698c:	c3                   	ret    

f010698d <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010698d:	55                   	push   %ebp
f010698e:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106990:	8b 55 08             	mov    0x8(%ebp),%edx
f0106993:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106999:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010699e:	e8 98 fd ff ff       	call   f010673b <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01069a3:	8b 15 04 80 26 f0    	mov    0xf0268004,%edx
f01069a9:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01069af:	f6 c4 10             	test   $0x10,%ah
f01069b2:	75 f5                	jne    f01069a9 <lapic_ipi+0x1c>
		;
}
f01069b4:	5d                   	pop    %ebp
f01069b5:	c3                   	ret    

f01069b6 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01069b6:	55                   	push   %ebp
f01069b7:	89 e5                	mov    %esp,%ebp
f01069b9:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01069bc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01069c2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01069c5:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01069c8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01069cf:	5d                   	pop    %ebp
f01069d0:	c3                   	ret    

f01069d1 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01069d1:	55                   	push   %ebp
f01069d2:	89 e5                	mov    %esp,%ebp
f01069d4:	56                   	push   %esi
f01069d5:	53                   	push   %ebx
f01069d6:	83 ec 20             	sub    $0x20,%esp
f01069d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f01069dc:	83 3b 00             	cmpl   $0x0,(%ebx)
f01069df:	74 14                	je     f01069f5 <spin_lock+0x24>
f01069e1:	8b 73 08             	mov    0x8(%ebx),%esi
f01069e4:	e8 6a fd ff ff       	call   f0106753 <cpunum>
f01069e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01069ec:	05 20 70 22 f0       	add    $0xf0227020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01069f1:	39 c6                	cmp    %eax,%esi
f01069f3:	74 15                	je     f0106a0a <spin_lock+0x39>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01069f5:	89 da                	mov    %ebx,%edx
	asm volatile("lock; xchgl %0, %1" :
f01069f7:	b8 01 00 00 00       	mov    $0x1,%eax
f01069fc:	f0 87 03             	lock xchg %eax,(%ebx)
f01069ff:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106a04:	85 c0                	test   %eax,%eax
f0106a06:	75 2e                	jne    f0106a36 <spin_lock+0x65>
f0106a08:	eb 37                	jmp    f0106a41 <spin_lock+0x70>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106a0a:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106a0d:	e8 41 fd ff ff       	call   f0106753 <cpunum>
f0106a12:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106a16:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106a1a:	c7 44 24 08 08 8a 10 	movl   $0xf0108a08,0x8(%esp)
f0106a21:	f0 
f0106a22:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106a29:	00 
f0106a2a:	c7 04 24 6c 8a 10 f0 	movl   $0xf0108a6c,(%esp)
f0106a31:	e8 0a 96 ff ff       	call   f0100040 <_panic>
		asm volatile ("pause");
f0106a36:	f3 90                	pause  
f0106a38:	89 c8                	mov    %ecx,%eax
f0106a3a:	f0 87 02             	lock xchg %eax,(%edx)
	while (xchg(&lk->locked, 1) != 0)
f0106a3d:	85 c0                	test   %eax,%eax
f0106a3f:	75 f5                	jne    f0106a36 <spin_lock+0x65>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106a41:	e8 0d fd ff ff       	call   f0106753 <cpunum>
f0106a46:	6b c0 74             	imul   $0x74,%eax,%eax
f0106a49:	05 20 70 22 f0       	add    $0xf0227020,%eax
f0106a4e:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106a51:	8d 4b 0c             	lea    0xc(%ebx),%ecx
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0106a54:	89 e8                	mov    %ebp,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106a56:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0106a5b:	77 34                	ja     f0106a91 <spin_lock+0xc0>
f0106a5d:	eb 2b                	jmp    f0106a8a <spin_lock+0xb9>
f0106a5f:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106a65:	76 12                	jbe    f0106a79 <spin_lock+0xa8>
		pcs[i] = ebp[1];          // saved %eip
f0106a67:	8b 5a 04             	mov    0x4(%edx),%ebx
f0106a6a:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106a6d:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106a6f:	83 c0 01             	add    $0x1,%eax
f0106a72:	83 f8 0a             	cmp    $0xa,%eax
f0106a75:	75 e8                	jne    f0106a5f <spin_lock+0x8e>
f0106a77:	eb 27                	jmp    f0106aa0 <spin_lock+0xcf>
		pcs[i] = 0;
f0106a79:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
	for (; i < 10; i++)
f0106a80:	83 c0 01             	add    $0x1,%eax
f0106a83:	83 f8 09             	cmp    $0x9,%eax
f0106a86:	7e f1                	jle    f0106a79 <spin_lock+0xa8>
f0106a88:	eb 16                	jmp    f0106aa0 <spin_lock+0xcf>
	for (i = 0; i < 10; i++){
f0106a8a:	b8 00 00 00 00       	mov    $0x0,%eax
f0106a8f:	eb e8                	jmp    f0106a79 <spin_lock+0xa8>
		pcs[i] = ebp[1];          // saved %eip
f0106a91:	8b 50 04             	mov    0x4(%eax),%edx
f0106a94:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106a97:	8b 10                	mov    (%eax),%edx
	for (i = 0; i < 10; i++){
f0106a99:	b8 01 00 00 00       	mov    $0x1,%eax
f0106a9e:	eb bf                	jmp    f0106a5f <spin_lock+0x8e>
#endif
}
f0106aa0:	83 c4 20             	add    $0x20,%esp
f0106aa3:	5b                   	pop    %ebx
f0106aa4:	5e                   	pop    %esi
f0106aa5:	5d                   	pop    %ebp
f0106aa6:	c3                   	ret    

f0106aa7 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106aa7:	55                   	push   %ebp
f0106aa8:	89 e5                	mov    %esp,%ebp
f0106aaa:	57                   	push   %edi
f0106aab:	56                   	push   %esi
f0106aac:	53                   	push   %ebx
f0106aad:	83 ec 6c             	sub    $0x6c,%esp
f0106ab0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106ab3:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106ab6:	74 18                	je     f0106ad0 <spin_unlock+0x29>
f0106ab8:	8b 73 08             	mov    0x8(%ebx),%esi
f0106abb:	e8 93 fc ff ff       	call   f0106753 <cpunum>
f0106ac0:	6b c0 74             	imul   $0x74,%eax,%eax
f0106ac3:	05 20 70 22 f0       	add    $0xf0227020,%eax
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106ac8:	39 c6                	cmp    %eax,%esi
f0106aca:	0f 84 d4 00 00 00    	je     f0106ba4 <spin_unlock+0xfd>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106ad0:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106ad7:	00 
f0106ad8:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106adb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106adf:	8d 45 c0             	lea    -0x40(%ebp),%eax
f0106ae2:	89 04 24             	mov    %eax,(%esp)
f0106ae5:	e8 1c f6 ff ff       	call   f0106106 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106aea:	8b 43 08             	mov    0x8(%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106aed:	0f b6 30             	movzbl (%eax),%esi
f0106af0:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106af3:	e8 5b fc ff ff       	call   f0106753 <cpunum>
f0106af8:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106afc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106b00:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b04:	c7 04 24 34 8a 10 f0 	movl   $0xf0108a34,(%esp)
f0106b0b:	e8 b9 d4 ff ff       	call   f0103fc9 <cprintf>
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106b10:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0106b13:	85 c0                	test   %eax,%eax
f0106b15:	74 71                	je     f0106b88 <spin_unlock+0xe1>
f0106b17:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106b1a:	8d 7d e4             	lea    -0x1c(%ebp),%edi
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106b1d:	8d 75 a8             	lea    -0x58(%ebp),%esi
f0106b20:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106b24:	89 04 24             	mov    %eax,(%esp)
f0106b27:	e8 97 e9 ff ff       	call   f01054c3 <debuginfo_eip>
f0106b2c:	85 c0                	test   %eax,%eax
f0106b2e:	78 39                	js     f0106b69 <spin_unlock+0xc2>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106b30:	8b 03                	mov    (%ebx),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106b32:	89 c2                	mov    %eax,%edx
f0106b34:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106b37:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106b3b:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0106b3e:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106b42:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106b45:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106b49:	8b 55 ac             	mov    -0x54(%ebp),%edx
f0106b4c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106b50:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0106b53:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106b57:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b5b:	c7 04 24 7c 8a 10 f0 	movl   $0xf0108a7c,(%esp)
f0106b62:	e8 62 d4 ff ff       	call   f0103fc9 <cprintf>
f0106b67:	eb 12                	jmp    f0106b7b <spin_unlock+0xd4>
			else
				cprintf("  %08x\n", pcs[i]);
f0106b69:	8b 03                	mov    (%ebx),%eax
f0106b6b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b6f:	c7 04 24 93 8a 10 f0 	movl   $0xf0108a93,(%esp)
f0106b76:	e8 4e d4 ff ff       	call   f0103fc9 <cprintf>
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106b7b:	39 fb                	cmp    %edi,%ebx
f0106b7d:	74 09                	je     f0106b88 <spin_unlock+0xe1>
f0106b7f:	83 c3 04             	add    $0x4,%ebx
f0106b82:	8b 03                	mov    (%ebx),%eax
f0106b84:	85 c0                	test   %eax,%eax
f0106b86:	75 98                	jne    f0106b20 <spin_unlock+0x79>
		}
		panic("spin_unlock");
f0106b88:	c7 44 24 08 9b 8a 10 	movl   $0xf0108a9b,0x8(%esp)
f0106b8f:	f0 
f0106b90:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106b97:	00 
f0106b98:	c7 04 24 6c 8a 10 f0 	movl   $0xf0108a6c,(%esp)
f0106b9f:	e8 9c 94 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106ba4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106bab:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	asm volatile("lock; xchgl %0, %1" :
f0106bb2:	b8 00 00 00 00       	mov    $0x0,%eax
f0106bb7:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106bba:	83 c4 6c             	add    $0x6c,%esp
f0106bbd:	5b                   	pop    %ebx
f0106bbe:	5e                   	pop    %esi
f0106bbf:	5f                   	pop    %edi
f0106bc0:	5d                   	pop    %ebp
f0106bc1:	c3                   	ret    
f0106bc2:	66 90                	xchg   %ax,%ax
f0106bc4:	66 90                	xchg   %ax,%ax
f0106bc6:	66 90                	xchg   %ax,%ax
f0106bc8:	66 90                	xchg   %ax,%ax
f0106bca:	66 90                	xchg   %ax,%ax
f0106bcc:	66 90                	xchg   %ax,%ax
f0106bce:	66 90                	xchg   %ax,%ax

f0106bd0 <__udivdi3>:
f0106bd0:	55                   	push   %ebp
f0106bd1:	57                   	push   %edi
f0106bd2:	56                   	push   %esi
f0106bd3:	83 ec 0c             	sub    $0xc,%esp
f0106bd6:	8b 44 24 28          	mov    0x28(%esp),%eax
f0106bda:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0106bde:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0106be2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106be6:	85 c0                	test   %eax,%eax
f0106be8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106bec:	89 ea                	mov    %ebp,%edx
f0106bee:	89 0c 24             	mov    %ecx,(%esp)
f0106bf1:	75 2d                	jne    f0106c20 <__udivdi3+0x50>
f0106bf3:	39 e9                	cmp    %ebp,%ecx
f0106bf5:	77 61                	ja     f0106c58 <__udivdi3+0x88>
f0106bf7:	85 c9                	test   %ecx,%ecx
f0106bf9:	89 ce                	mov    %ecx,%esi
f0106bfb:	75 0b                	jne    f0106c08 <__udivdi3+0x38>
f0106bfd:	b8 01 00 00 00       	mov    $0x1,%eax
f0106c02:	31 d2                	xor    %edx,%edx
f0106c04:	f7 f1                	div    %ecx
f0106c06:	89 c6                	mov    %eax,%esi
f0106c08:	31 d2                	xor    %edx,%edx
f0106c0a:	89 e8                	mov    %ebp,%eax
f0106c0c:	f7 f6                	div    %esi
f0106c0e:	89 c5                	mov    %eax,%ebp
f0106c10:	89 f8                	mov    %edi,%eax
f0106c12:	f7 f6                	div    %esi
f0106c14:	89 ea                	mov    %ebp,%edx
f0106c16:	83 c4 0c             	add    $0xc,%esp
f0106c19:	5e                   	pop    %esi
f0106c1a:	5f                   	pop    %edi
f0106c1b:	5d                   	pop    %ebp
f0106c1c:	c3                   	ret    
f0106c1d:	8d 76 00             	lea    0x0(%esi),%esi
f0106c20:	39 e8                	cmp    %ebp,%eax
f0106c22:	77 24                	ja     f0106c48 <__udivdi3+0x78>
f0106c24:	0f bd e8             	bsr    %eax,%ebp
f0106c27:	83 f5 1f             	xor    $0x1f,%ebp
f0106c2a:	75 3c                	jne    f0106c68 <__udivdi3+0x98>
f0106c2c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106c30:	39 34 24             	cmp    %esi,(%esp)
f0106c33:	0f 86 9f 00 00 00    	jbe    f0106cd8 <__udivdi3+0x108>
f0106c39:	39 d0                	cmp    %edx,%eax
f0106c3b:	0f 82 97 00 00 00    	jb     f0106cd8 <__udivdi3+0x108>
f0106c41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106c48:	31 d2                	xor    %edx,%edx
f0106c4a:	31 c0                	xor    %eax,%eax
f0106c4c:	83 c4 0c             	add    $0xc,%esp
f0106c4f:	5e                   	pop    %esi
f0106c50:	5f                   	pop    %edi
f0106c51:	5d                   	pop    %ebp
f0106c52:	c3                   	ret    
f0106c53:	90                   	nop
f0106c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106c58:	89 f8                	mov    %edi,%eax
f0106c5a:	f7 f1                	div    %ecx
f0106c5c:	31 d2                	xor    %edx,%edx
f0106c5e:	83 c4 0c             	add    $0xc,%esp
f0106c61:	5e                   	pop    %esi
f0106c62:	5f                   	pop    %edi
f0106c63:	5d                   	pop    %ebp
f0106c64:	c3                   	ret    
f0106c65:	8d 76 00             	lea    0x0(%esi),%esi
f0106c68:	89 e9                	mov    %ebp,%ecx
f0106c6a:	8b 3c 24             	mov    (%esp),%edi
f0106c6d:	d3 e0                	shl    %cl,%eax
f0106c6f:	89 c6                	mov    %eax,%esi
f0106c71:	b8 20 00 00 00       	mov    $0x20,%eax
f0106c76:	29 e8                	sub    %ebp,%eax
f0106c78:	89 c1                	mov    %eax,%ecx
f0106c7a:	d3 ef                	shr    %cl,%edi
f0106c7c:	89 e9                	mov    %ebp,%ecx
f0106c7e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106c82:	8b 3c 24             	mov    (%esp),%edi
f0106c85:	09 74 24 08          	or     %esi,0x8(%esp)
f0106c89:	89 d6                	mov    %edx,%esi
f0106c8b:	d3 e7                	shl    %cl,%edi
f0106c8d:	89 c1                	mov    %eax,%ecx
f0106c8f:	89 3c 24             	mov    %edi,(%esp)
f0106c92:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106c96:	d3 ee                	shr    %cl,%esi
f0106c98:	89 e9                	mov    %ebp,%ecx
f0106c9a:	d3 e2                	shl    %cl,%edx
f0106c9c:	89 c1                	mov    %eax,%ecx
f0106c9e:	d3 ef                	shr    %cl,%edi
f0106ca0:	09 d7                	or     %edx,%edi
f0106ca2:	89 f2                	mov    %esi,%edx
f0106ca4:	89 f8                	mov    %edi,%eax
f0106ca6:	f7 74 24 08          	divl   0x8(%esp)
f0106caa:	89 d6                	mov    %edx,%esi
f0106cac:	89 c7                	mov    %eax,%edi
f0106cae:	f7 24 24             	mull   (%esp)
f0106cb1:	39 d6                	cmp    %edx,%esi
f0106cb3:	89 14 24             	mov    %edx,(%esp)
f0106cb6:	72 30                	jb     f0106ce8 <__udivdi3+0x118>
f0106cb8:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106cbc:	89 e9                	mov    %ebp,%ecx
f0106cbe:	d3 e2                	shl    %cl,%edx
f0106cc0:	39 c2                	cmp    %eax,%edx
f0106cc2:	73 05                	jae    f0106cc9 <__udivdi3+0xf9>
f0106cc4:	3b 34 24             	cmp    (%esp),%esi
f0106cc7:	74 1f                	je     f0106ce8 <__udivdi3+0x118>
f0106cc9:	89 f8                	mov    %edi,%eax
f0106ccb:	31 d2                	xor    %edx,%edx
f0106ccd:	e9 7a ff ff ff       	jmp    f0106c4c <__udivdi3+0x7c>
f0106cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106cd8:	31 d2                	xor    %edx,%edx
f0106cda:	b8 01 00 00 00       	mov    $0x1,%eax
f0106cdf:	e9 68 ff ff ff       	jmp    f0106c4c <__udivdi3+0x7c>
f0106ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106ce8:	8d 47 ff             	lea    -0x1(%edi),%eax
f0106ceb:	31 d2                	xor    %edx,%edx
f0106ced:	83 c4 0c             	add    $0xc,%esp
f0106cf0:	5e                   	pop    %esi
f0106cf1:	5f                   	pop    %edi
f0106cf2:	5d                   	pop    %ebp
f0106cf3:	c3                   	ret    
f0106cf4:	66 90                	xchg   %ax,%ax
f0106cf6:	66 90                	xchg   %ax,%ax
f0106cf8:	66 90                	xchg   %ax,%ax
f0106cfa:	66 90                	xchg   %ax,%ax
f0106cfc:	66 90                	xchg   %ax,%ax
f0106cfe:	66 90                	xchg   %ax,%ax

f0106d00 <__umoddi3>:
f0106d00:	55                   	push   %ebp
f0106d01:	57                   	push   %edi
f0106d02:	56                   	push   %esi
f0106d03:	83 ec 14             	sub    $0x14,%esp
f0106d06:	8b 44 24 28          	mov    0x28(%esp),%eax
f0106d0a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106d0e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0106d12:	89 c7                	mov    %eax,%edi
f0106d14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d18:	8b 44 24 30          	mov    0x30(%esp),%eax
f0106d1c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106d20:	89 34 24             	mov    %esi,(%esp)
f0106d23:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106d27:	85 c0                	test   %eax,%eax
f0106d29:	89 c2                	mov    %eax,%edx
f0106d2b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106d2f:	75 17                	jne    f0106d48 <__umoddi3+0x48>
f0106d31:	39 fe                	cmp    %edi,%esi
f0106d33:	76 4b                	jbe    f0106d80 <__umoddi3+0x80>
f0106d35:	89 c8                	mov    %ecx,%eax
f0106d37:	89 fa                	mov    %edi,%edx
f0106d39:	f7 f6                	div    %esi
f0106d3b:	89 d0                	mov    %edx,%eax
f0106d3d:	31 d2                	xor    %edx,%edx
f0106d3f:	83 c4 14             	add    $0x14,%esp
f0106d42:	5e                   	pop    %esi
f0106d43:	5f                   	pop    %edi
f0106d44:	5d                   	pop    %ebp
f0106d45:	c3                   	ret    
f0106d46:	66 90                	xchg   %ax,%ax
f0106d48:	39 f8                	cmp    %edi,%eax
f0106d4a:	77 54                	ja     f0106da0 <__umoddi3+0xa0>
f0106d4c:	0f bd e8             	bsr    %eax,%ebp
f0106d4f:	83 f5 1f             	xor    $0x1f,%ebp
f0106d52:	75 5c                	jne    f0106db0 <__umoddi3+0xb0>
f0106d54:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0106d58:	39 3c 24             	cmp    %edi,(%esp)
f0106d5b:	0f 87 e7 00 00 00    	ja     f0106e48 <__umoddi3+0x148>
f0106d61:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106d65:	29 f1                	sub    %esi,%ecx
f0106d67:	19 c7                	sbb    %eax,%edi
f0106d69:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106d6d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106d71:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106d75:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106d79:	83 c4 14             	add    $0x14,%esp
f0106d7c:	5e                   	pop    %esi
f0106d7d:	5f                   	pop    %edi
f0106d7e:	5d                   	pop    %ebp
f0106d7f:	c3                   	ret    
f0106d80:	85 f6                	test   %esi,%esi
f0106d82:	89 f5                	mov    %esi,%ebp
f0106d84:	75 0b                	jne    f0106d91 <__umoddi3+0x91>
f0106d86:	b8 01 00 00 00       	mov    $0x1,%eax
f0106d8b:	31 d2                	xor    %edx,%edx
f0106d8d:	f7 f6                	div    %esi
f0106d8f:	89 c5                	mov    %eax,%ebp
f0106d91:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106d95:	31 d2                	xor    %edx,%edx
f0106d97:	f7 f5                	div    %ebp
f0106d99:	89 c8                	mov    %ecx,%eax
f0106d9b:	f7 f5                	div    %ebp
f0106d9d:	eb 9c                	jmp    f0106d3b <__umoddi3+0x3b>
f0106d9f:	90                   	nop
f0106da0:	89 c8                	mov    %ecx,%eax
f0106da2:	89 fa                	mov    %edi,%edx
f0106da4:	83 c4 14             	add    $0x14,%esp
f0106da7:	5e                   	pop    %esi
f0106da8:	5f                   	pop    %edi
f0106da9:	5d                   	pop    %ebp
f0106daa:	c3                   	ret    
f0106dab:	90                   	nop
f0106dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106db0:	8b 04 24             	mov    (%esp),%eax
f0106db3:	be 20 00 00 00       	mov    $0x20,%esi
f0106db8:	89 e9                	mov    %ebp,%ecx
f0106dba:	29 ee                	sub    %ebp,%esi
f0106dbc:	d3 e2                	shl    %cl,%edx
f0106dbe:	89 f1                	mov    %esi,%ecx
f0106dc0:	d3 e8                	shr    %cl,%eax
f0106dc2:	89 e9                	mov    %ebp,%ecx
f0106dc4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106dc8:	8b 04 24             	mov    (%esp),%eax
f0106dcb:	09 54 24 04          	or     %edx,0x4(%esp)
f0106dcf:	89 fa                	mov    %edi,%edx
f0106dd1:	d3 e0                	shl    %cl,%eax
f0106dd3:	89 f1                	mov    %esi,%ecx
f0106dd5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106dd9:	8b 44 24 10          	mov    0x10(%esp),%eax
f0106ddd:	d3 ea                	shr    %cl,%edx
f0106ddf:	89 e9                	mov    %ebp,%ecx
f0106de1:	d3 e7                	shl    %cl,%edi
f0106de3:	89 f1                	mov    %esi,%ecx
f0106de5:	d3 e8                	shr    %cl,%eax
f0106de7:	89 e9                	mov    %ebp,%ecx
f0106de9:	09 f8                	or     %edi,%eax
f0106deb:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0106def:	f7 74 24 04          	divl   0x4(%esp)
f0106df3:	d3 e7                	shl    %cl,%edi
f0106df5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106df9:	89 d7                	mov    %edx,%edi
f0106dfb:	f7 64 24 08          	mull   0x8(%esp)
f0106dff:	39 d7                	cmp    %edx,%edi
f0106e01:	89 c1                	mov    %eax,%ecx
f0106e03:	89 14 24             	mov    %edx,(%esp)
f0106e06:	72 2c                	jb     f0106e34 <__umoddi3+0x134>
f0106e08:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0106e0c:	72 22                	jb     f0106e30 <__umoddi3+0x130>
f0106e0e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106e12:	29 c8                	sub    %ecx,%eax
f0106e14:	19 d7                	sbb    %edx,%edi
f0106e16:	89 e9                	mov    %ebp,%ecx
f0106e18:	89 fa                	mov    %edi,%edx
f0106e1a:	d3 e8                	shr    %cl,%eax
f0106e1c:	89 f1                	mov    %esi,%ecx
f0106e1e:	d3 e2                	shl    %cl,%edx
f0106e20:	89 e9                	mov    %ebp,%ecx
f0106e22:	d3 ef                	shr    %cl,%edi
f0106e24:	09 d0                	or     %edx,%eax
f0106e26:	89 fa                	mov    %edi,%edx
f0106e28:	83 c4 14             	add    $0x14,%esp
f0106e2b:	5e                   	pop    %esi
f0106e2c:	5f                   	pop    %edi
f0106e2d:	5d                   	pop    %ebp
f0106e2e:	c3                   	ret    
f0106e2f:	90                   	nop
f0106e30:	39 d7                	cmp    %edx,%edi
f0106e32:	75 da                	jne    f0106e0e <__umoddi3+0x10e>
f0106e34:	8b 14 24             	mov    (%esp),%edx
f0106e37:	89 c1                	mov    %eax,%ecx
f0106e39:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0106e3d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0106e41:	eb cb                	jmp    f0106e0e <__umoddi3+0x10e>
f0106e43:	90                   	nop
f0106e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106e48:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0106e4c:	0f 82 0f ff ff ff    	jb     f0106d61 <__umoddi3+0x61>
f0106e52:	e9 1a ff ff ff       	jmp    f0106d71 <__umoddi3+0x71>
