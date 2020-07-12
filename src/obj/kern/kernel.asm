
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
f010004b:	83 3d 80 1e 20 f0 00 	cmpl   $0x0,0xf0201e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 1e 20 f0    	mov    %esi,0xf0201e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 0f 67 00 00       	call   f0106773 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 80 6e 10 f0 	movl   $0xf0106e80,(%esp)
f010007d:	e8 1b 3f 00 00       	call   f0103f9d <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 dc 3e 00 00       	call   f0103f6a <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 fe 76 10 f0 	movl   $0xf01076fe,(%esp)
f0100095:	e8 03 3f 00 00       	call   f0103f9d <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 6a 09 00 00       	call   f0100a10 <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <i386_init>:
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	53                   	push   %ebx
f01000ac:	83 ec 14             	sub    $0x14,%esp
	memset(edata, 0, end - edata);
f01000af:	b8 08 30 24 f0       	mov    $0xf0243008,%eax
f01000b4:	2d 00 10 20 f0       	sub    $0xf0201000,%eax
f01000b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000c4:	00 
f01000c5:	c7 04 24 00 10 20 f0 	movl   $0xf0201000,(%esp)
f01000cc:	e8 08 60 00 00       	call   f01060d9 <memset>
	cons_init();
f01000d1:	e8 e9 05 00 00       	call   f01006bf <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000dd:	00 
f01000de:	c7 04 24 ec 6e 10 f0 	movl   $0xf0106eec,(%esp)
f01000e5:	e8 b3 3e 00 00       	call   f0103f9d <cprintf>
	mem_init();
f01000ea:	e8 4c 14 00 00       	call   f010153b <mem_init>
	env_init();
f01000ef:	e8 a3 36 00 00       	call   f0103797 <env_init>
	trap_init();
f01000f4:	e8 95 3f 00 00       	call   f010408e <trap_init>
	mp_init();
f01000f9:	e8 5b 63 00 00       	call   f0106459 <mp_init>
	lapic_init();
f01000fe:	66 90                	xchg   %ax,%ax
f0100100:	e8 89 66 00 00       	call   f010678e <lapic_init>
	pic_init();
f0100105:	e8 c3 3d 00 00       	call   f0103ecd <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010010a:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100111:	e8 db 68 00 00       	call   f01069f1 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100116:	83 3d 88 1e 20 f0 07 	cmpl   $0x7,0xf0201e88
f010011d:	77 24                	ja     f0100143 <i386_init+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100126:	00 
f0100127:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f010012e:	f0 
f010012f:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0100136:	00 
f0100137:	c7 04 24 07 6f 10 f0 	movl   $0xf0106f07,(%esp)
f010013e:	e8 fd fe ff ff       	call   f0100040 <_panic>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100143:	b8 86 63 10 f0       	mov    $0xf0106386,%eax
f0100148:	2d 0c 63 10 f0       	sub    $0xf010630c,%eax
f010014d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100151:	c7 44 24 04 0c 63 10 	movl   $0xf010630c,0x4(%esp)
f0100158:	f0 
f0100159:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100160:	e8 c1 5f 00 00       	call   f0106126 <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100165:	6b 05 c4 23 20 f0 74 	imul   $0x74,0xf02023c4,%eax
f010016c:	05 20 20 20 f0       	add    $0xf0202020,%eax
f0100171:	3d 20 20 20 f0       	cmp    $0xf0202020,%eax
f0100176:	76 62                	jbe    f01001da <i386_init+0x132>
f0100178:	bb 20 20 20 f0       	mov    $0xf0202020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f010017d:	e8 f1 65 00 00       	call   f0106773 <cpunum>
f0100182:	6b c0 74             	imul   $0x74,%eax,%eax
f0100185:	05 20 20 20 f0       	add    $0xf0202020,%eax
f010018a:	39 c3                	cmp    %eax,%ebx
f010018c:	74 39                	je     f01001c7 <i386_init+0x11f>
f010018e:	89 d8                	mov    %ebx,%eax
f0100190:	2d 20 20 20 f0       	sub    $0xf0202020,%eax
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100195:	c1 f8 02             	sar    $0x2,%eax
f0100198:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010019e:	c1 e0 0f             	shl    $0xf,%eax
f01001a1:	8d 80 00 b0 20 f0    	lea    -0xfdf5000(%eax),%eax
f01001a7:	a3 84 1e 20 f0       	mov    %eax,0xf0201e84
		lapic_startap(c->cpu_id, PADDR(code));
f01001ac:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f01001b3:	00 
f01001b4:	0f b6 03             	movzbl (%ebx),%eax
f01001b7:	89 04 24             	mov    %eax,(%esp)
f01001ba:	e8 1f 67 00 00       	call   f01068de <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f01001bf:	8b 43 04             	mov    0x4(%ebx),%eax
f01001c2:	83 f8 01             	cmp    $0x1,%eax
f01001c5:	75 f8                	jne    f01001bf <i386_init+0x117>
	for (c = cpus; c < cpus + ncpu; c++) {
f01001c7:	83 c3 74             	add    $0x74,%ebx
f01001ca:	6b 05 c4 23 20 f0 74 	imul   $0x74,0xf02023c4,%eax
f01001d1:	05 20 20 20 f0       	add    $0xf0202020,%eax
f01001d6:	39 c3                	cmp    %eax,%ebx
f01001d8:	72 a3                	jb     f010017d <i386_init+0xd5>
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01001da:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01001e1:	00 
f01001e2:	c7 44 24 04 fc 51 01 	movl   $0x151fc,0x4(%esp)
f01001e9:	00 
f01001ea:	c7 04 24 e8 22 1c f0 	movl   $0xf01c22e8,(%esp)
f01001f1:	e8 6a 37 00 00       	call   f0103960 <env_create>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01001fd:	00 
f01001fe:	c7 44 24 04 8c 4e 00 	movl   $0x4e8c,0x4(%esp)
f0100205:	00 
f0100206:	c7 04 24 a4 0e 1f f0 	movl   $0xf01f0ea4,(%esp)
f010020d:	e8 4e 37 00 00       	call   f0103960 <env_create>
	kbd_intr();
f0100212:	e8 4c 04 00 00       	call   f0100663 <kbd_intr>
	sched_yield();
f0100217:	e8 6b 4a 00 00       	call   f0104c87 <sched_yield>

f010021c <mp_main>:
{
f010021c:	55                   	push   %ebp
f010021d:	89 e5                	mov    %esp,%ebp
f010021f:	83 ec 18             	sub    $0x18,%esp
	lcr3(PADDR(kern_pgdir));
f0100222:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0100227:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010022c:	77 20                	ja     f010024e <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010022e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100232:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0100239:	f0 
f010023a:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
f0100241:	00 
f0100242:	c7 04 24 07 6f 10 f0 	movl   $0xf0106f07,(%esp)
f0100249:	e8 f2 fd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010024e:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100253:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100256:	e8 18 65 00 00       	call   f0106773 <cpunum>
f010025b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010025f:	c7 04 24 13 6f 10 f0 	movl   $0xf0106f13,(%esp)
f0100266:	e8 32 3d 00 00       	call   f0103f9d <cprintf>
	lapic_init();
f010026b:	e8 1e 65 00 00       	call   f010678e <lapic_init>
	env_init_percpu();
f0100270:	e8 f8 34 00 00       	call   f010376d <env_init_percpu>
	trap_init_percpu();
f0100275:	e8 46 3d 00 00       	call   f0103fc0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010027a:	e8 f4 64 00 00       	call   f0106773 <cpunum>
f010027f:	6b d0 74             	imul   $0x74,%eax,%edx
f0100282:	81 c2 20 20 20 f0    	add    $0xf0202020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100288:	b8 01 00 00 00       	mov    $0x1,%eax
f010028d:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100291:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100298:	e8 54 67 00 00       	call   f01069f1 <spin_lock>
	sched_yield();
f010029d:	e8 e5 49 00 00       	call   f0104c87 <sched_yield>

f01002a2 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002a2:	55                   	push   %ebp
f01002a3:	89 e5                	mov    %esp,%ebp
f01002a5:	53                   	push   %ebx
f01002a6:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01002a9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
f01002af:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01002b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002ba:	c7 04 24 29 6f 10 f0 	movl   $0xf0106f29,(%esp)
f01002c1:	e8 d7 3c 00 00       	call   f0103f9d <cprintf>
	vcprintf(fmt, ap);
f01002c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002ca:	8b 45 10             	mov    0x10(%ebp),%eax
f01002cd:	89 04 24             	mov    %eax,(%esp)
f01002d0:	e8 95 3c 00 00       	call   f0103f6a <vcprintf>
	cprintf("\n");
f01002d5:	c7 04 24 fe 76 10 f0 	movl   $0xf01076fe,(%esp)
f01002dc:	e8 bc 3c 00 00       	call   f0103f9d <cprintf>
	va_end(ap);
}
f01002e1:	83 c4 14             	add    $0x14,%esp
f01002e4:	5b                   	pop    %ebx
f01002e5:	5d                   	pop    %ebp
f01002e6:	c3                   	ret    
f01002e7:	66 90                	xchg   %ax,%ax
f01002e9:	66 90                	xchg   %ax,%ax
f01002eb:	66 90                	xchg   %ax,%ax
f01002ed:	66 90                	xchg   %ax,%ax
f01002ef:	90                   	nop

f01002f0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002f0:	55                   	push   %ebp
f01002f1:	89 e5                	mov    %esp,%ebp
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002f8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002f9:	a8 01                	test   $0x1,%al
f01002fb:	74 08                	je     f0100305 <serial_proc_data+0x15>
f01002fd:	b2 f8                	mov    $0xf8,%dl
f01002ff:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100300:	0f b6 c0             	movzbl %al,%eax
f0100303:	eb 05                	jmp    f010030a <serial_proc_data+0x1a>
		return -1;
f0100305:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010030a:	5d                   	pop    %ebp
f010030b:	c3                   	ret    

f010030c <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010030c:	55                   	push   %ebp
f010030d:	89 e5                	mov    %esp,%ebp
f010030f:	53                   	push   %ebx
f0100310:	83 ec 04             	sub    $0x4,%esp
f0100313:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100315:	eb 2a                	jmp    f0100341 <cons_intr+0x35>
		if (c == 0)
f0100317:	85 d2                	test   %edx,%edx
f0100319:	74 26                	je     f0100341 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f010031b:	a1 24 12 20 f0       	mov    0xf0201224,%eax
f0100320:	8d 48 01             	lea    0x1(%eax),%ecx
f0100323:	89 0d 24 12 20 f0    	mov    %ecx,0xf0201224
f0100329:	88 90 20 10 20 f0    	mov    %dl,-0xfdfefe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010032f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100335:	75 0a                	jne    f0100341 <cons_intr+0x35>
			cons.wpos = 0;
f0100337:	c7 05 24 12 20 f0 00 	movl   $0x0,0xf0201224
f010033e:	00 00 00 
	while ((c = (*proc)()) != -1) {
f0100341:	ff d3                	call   *%ebx
f0100343:	89 c2                	mov    %eax,%edx
f0100345:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100348:	75 cd                	jne    f0100317 <cons_intr+0xb>
	}
}
f010034a:	83 c4 04             	add    $0x4,%esp
f010034d:	5b                   	pop    %ebx
f010034e:	5d                   	pop    %ebp
f010034f:	c3                   	ret    

f0100350 <kbd_proc_data>:
f0100350:	ba 64 00 00 00       	mov    $0x64,%edx
f0100355:	ec                   	in     (%dx),%al
	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100356:	a8 01                	test   $0x1,%al
f0100358:	0f 84 ef 00 00 00    	je     f010044d <kbd_proc_data+0xfd>
f010035e:	b2 60                	mov    $0x60,%dl
f0100360:	ec                   	in     (%dx),%al
f0100361:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100363:	3c e0                	cmp    $0xe0,%al
f0100365:	75 0d                	jne    f0100374 <kbd_proc_data+0x24>
		shift |= E0ESC;
f0100367:	83 0d 00 10 20 f0 40 	orl    $0x40,0xf0201000
		return 0;
f010036e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100373:	c3                   	ret    
{
f0100374:	55                   	push   %ebp
f0100375:	89 e5                	mov    %esp,%ebp
f0100377:	53                   	push   %ebx
f0100378:	83 ec 14             	sub    $0x14,%esp
	} else if (data & 0x80) {
f010037b:	84 c0                	test   %al,%al
f010037d:	79 37                	jns    f01003b6 <kbd_proc_data+0x66>
		data = (shift & E0ESC ? data : data & 0x7F);
f010037f:	8b 0d 00 10 20 f0    	mov    0xf0201000,%ecx
f0100385:	89 cb                	mov    %ecx,%ebx
f0100387:	83 e3 40             	and    $0x40,%ebx
f010038a:	83 e0 7f             	and    $0x7f,%eax
f010038d:	85 db                	test   %ebx,%ebx
f010038f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100392:	0f b6 d2             	movzbl %dl,%edx
f0100395:	0f b6 82 a0 70 10 f0 	movzbl -0xfef8f60(%edx),%eax
f010039c:	83 c8 40             	or     $0x40,%eax
f010039f:	0f b6 c0             	movzbl %al,%eax
f01003a2:	f7 d0                	not    %eax
f01003a4:	21 c1                	and    %eax,%ecx
f01003a6:	89 0d 00 10 20 f0    	mov    %ecx,0xf0201000
		return 0;
f01003ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01003b1:	e9 9d 00 00 00       	jmp    f0100453 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f01003b6:	8b 0d 00 10 20 f0    	mov    0xf0201000,%ecx
f01003bc:	f6 c1 40             	test   $0x40,%cl
f01003bf:	74 0e                	je     f01003cf <kbd_proc_data+0x7f>
		data |= 0x80;
f01003c1:	83 c8 80             	or     $0xffffff80,%eax
f01003c4:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01003c6:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003c9:	89 0d 00 10 20 f0    	mov    %ecx,0xf0201000
	shift |= shiftcode[data];
f01003cf:	0f b6 d2             	movzbl %dl,%edx
f01003d2:	0f b6 82 a0 70 10 f0 	movzbl -0xfef8f60(%edx),%eax
f01003d9:	0b 05 00 10 20 f0    	or     0xf0201000,%eax
	shift ^= togglecode[data];
f01003df:	0f b6 8a a0 6f 10 f0 	movzbl -0xfef9060(%edx),%ecx
f01003e6:	31 c8                	xor    %ecx,%eax
f01003e8:	a3 00 10 20 f0       	mov    %eax,0xf0201000
	c = charcode[shift & (CTL | SHIFT)][data];
f01003ed:	89 c1                	mov    %eax,%ecx
f01003ef:	83 e1 03             	and    $0x3,%ecx
f01003f2:	8b 0c 8d 80 6f 10 f0 	mov    -0xfef9080(,%ecx,4),%ecx
f01003f9:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003fd:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100400:	a8 08                	test   $0x8,%al
f0100402:	74 1b                	je     f010041f <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f0100404:	89 da                	mov    %ebx,%edx
f0100406:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100409:	83 f9 19             	cmp    $0x19,%ecx
f010040c:	77 05                	ja     f0100413 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f010040e:	83 eb 20             	sub    $0x20,%ebx
f0100411:	eb 0c                	jmp    f010041f <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f0100413:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100416:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100419:	83 fa 19             	cmp    $0x19,%edx
f010041c:	0f 46 d9             	cmovbe %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010041f:	f7 d0                	not    %eax
f0100421:	89 c2                	mov    %eax,%edx
	return c;
f0100423:	89 d8                	mov    %ebx,%eax
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100425:	f6 c2 06             	test   $0x6,%dl
f0100428:	75 29                	jne    f0100453 <kbd_proc_data+0x103>
f010042a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100430:	75 21                	jne    f0100453 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f0100432:	c7 04 24 43 6f 10 f0 	movl   $0xf0106f43,(%esp)
f0100439:	e8 5f 3b 00 00       	call   f0103f9d <cprintf>
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010043e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100443:	b8 03 00 00 00       	mov    $0x3,%eax
f0100448:	ee                   	out    %al,(%dx)
	return c;
f0100449:	89 d8                	mov    %ebx,%eax
f010044b:	eb 06                	jmp    f0100453 <kbd_proc_data+0x103>
		return -1;
f010044d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100452:	c3                   	ret    
}
f0100453:	83 c4 14             	add    $0x14,%esp
f0100456:	5b                   	pop    %ebx
f0100457:	5d                   	pop    %ebp
f0100458:	c3                   	ret    

f0100459 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100459:	55                   	push   %ebp
f010045a:	89 e5                	mov    %esp,%ebp
f010045c:	57                   	push   %edi
f010045d:	56                   	push   %esi
f010045e:	53                   	push   %ebx
f010045f:	83 ec 1c             	sub    $0x1c,%esp
f0100462:	89 c7                	mov    %eax,%edi
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100464:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100469:	ec                   	in     (%dx),%al
	for (i = 0;
f010046a:	a8 20                	test   $0x20,%al
f010046c:	75 21                	jne    f010048f <cons_putc+0x36>
f010046e:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100473:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100478:	be fd 03 00 00       	mov    $0x3fd,%esi
f010047d:	89 ca                	mov    %ecx,%edx
f010047f:	ec                   	in     (%dx),%al
f0100480:	ec                   	in     (%dx),%al
f0100481:	ec                   	in     (%dx),%al
f0100482:	ec                   	in     (%dx),%al
f0100483:	89 f2                	mov    %esi,%edx
f0100485:	ec                   	in     (%dx),%al
f0100486:	a8 20                	test   $0x20,%al
f0100488:	75 05                	jne    f010048f <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010048a:	83 eb 01             	sub    $0x1,%ebx
f010048d:	75 ee                	jne    f010047d <cons_putc+0x24>
	outb(COM1 + COM_TX, c);
f010048f:	89 f8                	mov    %edi,%eax
f0100491:	0f b6 c0             	movzbl %al,%eax
f0100494:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100497:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010049c:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010049d:	b2 79                	mov    $0x79,%dl
f010049f:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01004a0:	84 c0                	test   %al,%al
f01004a2:	78 21                	js     f01004c5 <cons_putc+0x6c>
f01004a4:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01004a9:	b9 84 00 00 00       	mov    $0x84,%ecx
f01004ae:	be 79 03 00 00       	mov    $0x379,%esi
f01004b3:	89 ca                	mov    %ecx,%edx
f01004b5:	ec                   	in     (%dx),%al
f01004b6:	ec                   	in     (%dx),%al
f01004b7:	ec                   	in     (%dx),%al
f01004b8:	ec                   	in     (%dx),%al
f01004b9:	89 f2                	mov    %esi,%edx
f01004bb:	ec                   	in     (%dx),%al
f01004bc:	84 c0                	test   %al,%al
f01004be:	78 05                	js     f01004c5 <cons_putc+0x6c>
f01004c0:	83 eb 01             	sub    $0x1,%ebx
f01004c3:	75 ee                	jne    f01004b3 <cons_putc+0x5a>
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004c5:	ba 78 03 00 00       	mov    $0x378,%edx
f01004ca:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01004ce:	ee                   	out    %al,(%dx)
f01004cf:	b2 7a                	mov    $0x7a,%dl
f01004d1:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004d6:	ee                   	out    %al,(%dx)
f01004d7:	b8 08 00 00 00       	mov    $0x8,%eax
f01004dc:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01004dd:	89 fa                	mov    %edi,%edx
f01004df:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004e5:	89 f8                	mov    %edi,%eax
f01004e7:	80 cc 07             	or     $0x7,%ah
f01004ea:	85 d2                	test   %edx,%edx
f01004ec:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f01004ef:	89 f8                	mov    %edi,%eax
f01004f1:	0f b6 c0             	movzbl %al,%eax
f01004f4:	83 f8 09             	cmp    $0x9,%eax
f01004f7:	74 79                	je     f0100572 <cons_putc+0x119>
f01004f9:	83 f8 09             	cmp    $0x9,%eax
f01004fc:	7f 0a                	jg     f0100508 <cons_putc+0xaf>
f01004fe:	83 f8 08             	cmp    $0x8,%eax
f0100501:	74 19                	je     f010051c <cons_putc+0xc3>
f0100503:	e9 9e 00 00 00       	jmp    f01005a6 <cons_putc+0x14d>
f0100508:	83 f8 0a             	cmp    $0xa,%eax
f010050b:	90                   	nop
f010050c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100510:	74 3a                	je     f010054c <cons_putc+0xf3>
f0100512:	83 f8 0d             	cmp    $0xd,%eax
f0100515:	74 3d                	je     f0100554 <cons_putc+0xfb>
f0100517:	e9 8a 00 00 00       	jmp    f01005a6 <cons_putc+0x14d>
		if (crt_pos > 0) {
f010051c:	0f b7 05 28 12 20 f0 	movzwl 0xf0201228,%eax
f0100523:	66 85 c0             	test   %ax,%ax
f0100526:	0f 84 e5 00 00 00    	je     f0100611 <cons_putc+0x1b8>
			crt_pos--;
f010052c:	83 e8 01             	sub    $0x1,%eax
f010052f:	66 a3 28 12 20 f0    	mov    %ax,0xf0201228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100535:	0f b7 c0             	movzwl %ax,%eax
f0100538:	66 81 e7 00 ff       	and    $0xff00,%di
f010053d:	83 cf 20             	or     $0x20,%edi
f0100540:	8b 15 2c 12 20 f0    	mov    0xf020122c,%edx
f0100546:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010054a:	eb 78                	jmp    f01005c4 <cons_putc+0x16b>
		crt_pos += CRT_COLS;
f010054c:	66 83 05 28 12 20 f0 	addw   $0x50,0xf0201228
f0100553:	50 
		crt_pos -= (crt_pos % CRT_COLS);
f0100554:	0f b7 05 28 12 20 f0 	movzwl 0xf0201228,%eax
f010055b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100561:	c1 e8 16             	shr    $0x16,%eax
f0100564:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100567:	c1 e0 04             	shl    $0x4,%eax
f010056a:	66 a3 28 12 20 f0    	mov    %ax,0xf0201228
f0100570:	eb 52                	jmp    f01005c4 <cons_putc+0x16b>
		cons_putc(' ');
f0100572:	b8 20 00 00 00       	mov    $0x20,%eax
f0100577:	e8 dd fe ff ff       	call   f0100459 <cons_putc>
		cons_putc(' ');
f010057c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100581:	e8 d3 fe ff ff       	call   f0100459 <cons_putc>
		cons_putc(' ');
f0100586:	b8 20 00 00 00       	mov    $0x20,%eax
f010058b:	e8 c9 fe ff ff       	call   f0100459 <cons_putc>
		cons_putc(' ');
f0100590:	b8 20 00 00 00       	mov    $0x20,%eax
f0100595:	e8 bf fe ff ff       	call   f0100459 <cons_putc>
		cons_putc(' ');
f010059a:	b8 20 00 00 00       	mov    $0x20,%eax
f010059f:	e8 b5 fe ff ff       	call   f0100459 <cons_putc>
f01005a4:	eb 1e                	jmp    f01005c4 <cons_putc+0x16b>
		crt_buf[crt_pos++] = c;		/* write the character */
f01005a6:	0f b7 05 28 12 20 f0 	movzwl 0xf0201228,%eax
f01005ad:	8d 50 01             	lea    0x1(%eax),%edx
f01005b0:	66 89 15 28 12 20 f0 	mov    %dx,0xf0201228
f01005b7:	0f b7 c0             	movzwl %ax,%eax
f01005ba:	8b 15 2c 12 20 f0    	mov    0xf020122c,%edx
f01005c0:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
	if (crt_pos >= CRT_SIZE) {
f01005c4:	66 81 3d 28 12 20 f0 	cmpw   $0x7cf,0xf0201228
f01005cb:	cf 07 
f01005cd:	76 42                	jbe    f0100611 <cons_putc+0x1b8>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005cf:	a1 2c 12 20 f0       	mov    0xf020122c,%eax
f01005d4:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005db:	00 
f01005dc:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005e2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005e6:	89 04 24             	mov    %eax,(%esp)
f01005e9:	e8 38 5b 00 00       	call   f0106126 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005ee:	8b 15 2c 12 20 f0    	mov    0xf020122c,%edx
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005f4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005f9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005ff:	83 c0 01             	add    $0x1,%eax
f0100602:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100607:	75 f0                	jne    f01005f9 <cons_putc+0x1a0>
		crt_pos -= CRT_COLS;
f0100609:	66 83 2d 28 12 20 f0 	subw   $0x50,0xf0201228
f0100610:	50 
	outb(addr_6845, 14);
f0100611:	8b 0d 30 12 20 f0    	mov    0xf0201230,%ecx
f0100617:	b8 0e 00 00 00       	mov    $0xe,%eax
f010061c:	89 ca                	mov    %ecx,%edx
f010061e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010061f:	0f b7 1d 28 12 20 f0 	movzwl 0xf0201228,%ebx
f0100626:	8d 71 01             	lea    0x1(%ecx),%esi
f0100629:	89 d8                	mov    %ebx,%eax
f010062b:	66 c1 e8 08          	shr    $0x8,%ax
f010062f:	89 f2                	mov    %esi,%edx
f0100631:	ee                   	out    %al,(%dx)
f0100632:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100637:	89 ca                	mov    %ecx,%edx
f0100639:	ee                   	out    %al,(%dx)
f010063a:	89 d8                	mov    %ebx,%eax
f010063c:	89 f2                	mov    %esi,%edx
f010063e:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010063f:	83 c4 1c             	add    $0x1c,%esp
f0100642:	5b                   	pop    %ebx
f0100643:	5e                   	pop    %esi
f0100644:	5f                   	pop    %edi
f0100645:	5d                   	pop    %ebp
f0100646:	c3                   	ret    

f0100647 <serial_intr>:
	if (serial_exists)
f0100647:	80 3d 34 12 20 f0 00 	cmpb   $0x0,0xf0201234
f010064e:	74 11                	je     f0100661 <serial_intr+0x1a>
{
f0100650:	55                   	push   %ebp
f0100651:	89 e5                	mov    %esp,%ebp
f0100653:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100656:	b8 f0 02 10 f0       	mov    $0xf01002f0,%eax
f010065b:	e8 ac fc ff ff       	call   f010030c <cons_intr>
}
f0100660:	c9                   	leave  
f0100661:	f3 c3                	repz ret 

f0100663 <kbd_intr>:
{
f0100663:	55                   	push   %ebp
f0100664:	89 e5                	mov    %esp,%ebp
f0100666:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100669:	b8 50 03 10 f0       	mov    $0xf0100350,%eax
f010066e:	e8 99 fc ff ff       	call   f010030c <cons_intr>
}
f0100673:	c9                   	leave  
f0100674:	c3                   	ret    

f0100675 <cons_getc>:
{
f0100675:	55                   	push   %ebp
f0100676:	89 e5                	mov    %esp,%ebp
f0100678:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010067b:	e8 c7 ff ff ff       	call   f0100647 <serial_intr>
	kbd_intr();
f0100680:	e8 de ff ff ff       	call   f0100663 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100685:	a1 20 12 20 f0       	mov    0xf0201220,%eax
f010068a:	3b 05 24 12 20 f0    	cmp    0xf0201224,%eax
f0100690:	74 26                	je     f01006b8 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100692:	8d 50 01             	lea    0x1(%eax),%edx
f0100695:	89 15 20 12 20 f0    	mov    %edx,0xf0201220
f010069b:	0f b6 88 20 10 20 f0 	movzbl -0xfdfefe0(%eax),%ecx
		return c;
f01006a2:	89 c8                	mov    %ecx,%eax
		if (cons.rpos == CONSBUFSIZE)
f01006a4:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01006aa:	75 11                	jne    f01006bd <cons_getc+0x48>
			cons.rpos = 0;
f01006ac:	c7 05 20 12 20 f0 00 	movl   $0x0,0xf0201220
f01006b3:	00 00 00 
f01006b6:	eb 05                	jmp    f01006bd <cons_getc+0x48>
	return 0;
f01006b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01006bd:	c9                   	leave  
f01006be:	c3                   	ret    

f01006bf <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01006bf:	55                   	push   %ebp
f01006c0:	89 e5                	mov    %esp,%ebp
f01006c2:	57                   	push   %edi
f01006c3:	56                   	push   %esi
f01006c4:	53                   	push   %ebx
f01006c5:	83 ec 1c             	sub    $0x1c,%esp
	was = *cp;
f01006c8:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01006cf:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006d6:	5a a5 
	if (*cp != 0xA55A) {
f01006d8:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006df:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006e3:	74 11                	je     f01006f6 <cons_init+0x37>
		addr_6845 = MONO_BASE;
f01006e5:	c7 05 30 12 20 f0 b4 	movl   $0x3b4,0xf0201230
f01006ec:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006ef:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006f4:	eb 16                	jmp    f010070c <cons_init+0x4d>
		*cp = was;
f01006f6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006fd:	c7 05 30 12 20 f0 d4 	movl   $0x3d4,0xf0201230
f0100704:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100707:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
	outb(addr_6845, 14);
f010070c:	8b 0d 30 12 20 f0    	mov    0xf0201230,%ecx
f0100712:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100717:	89 ca                	mov    %ecx,%edx
f0100719:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010071a:	8d 59 01             	lea    0x1(%ecx),%ebx
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010071d:	89 da                	mov    %ebx,%edx
f010071f:	ec                   	in     (%dx),%al
f0100720:	0f b6 f0             	movzbl %al,%esi
f0100723:	c1 e6 08             	shl    $0x8,%esi
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100726:	b8 0f 00 00 00       	mov    $0xf,%eax
f010072b:	89 ca                	mov    %ecx,%edx
f010072d:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010072e:	89 da                	mov    %ebx,%edx
f0100730:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100731:	89 3d 2c 12 20 f0    	mov    %edi,0xf020122c
	pos |= inb(addr_6845 + 1);
f0100737:	0f b6 d8             	movzbl %al,%ebx
f010073a:	09 de                	or     %ebx,%esi
	crt_pos = pos;
f010073c:	66 89 35 28 12 20 f0 	mov    %si,0xf0201228
	kbd_intr();
f0100743:	e8 1b ff ff ff       	call   f0100663 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100748:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010074f:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100754:	89 04 24             	mov    %eax,(%esp)
f0100757:	e8 02 37 00 00       	call   f0103e5e <irq_setmask_8259A>
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010075c:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100761:	b8 00 00 00 00       	mov    $0x0,%eax
f0100766:	89 f2                	mov    %esi,%edx
f0100768:	ee                   	out    %al,(%dx)
f0100769:	b2 fb                	mov    $0xfb,%dl
f010076b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100770:	ee                   	out    %al,(%dx)
f0100771:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100776:	b8 0c 00 00 00       	mov    $0xc,%eax
f010077b:	89 da                	mov    %ebx,%edx
f010077d:	ee                   	out    %al,(%dx)
f010077e:	b2 f9                	mov    $0xf9,%dl
f0100780:	b8 00 00 00 00       	mov    $0x0,%eax
f0100785:	ee                   	out    %al,(%dx)
f0100786:	b2 fb                	mov    $0xfb,%dl
f0100788:	b8 03 00 00 00       	mov    $0x3,%eax
f010078d:	ee                   	out    %al,(%dx)
f010078e:	b2 fc                	mov    $0xfc,%dl
f0100790:	b8 00 00 00 00       	mov    $0x0,%eax
f0100795:	ee                   	out    %al,(%dx)
f0100796:	b2 f9                	mov    $0xf9,%dl
f0100798:	b8 01 00 00 00       	mov    $0x1,%eax
f010079d:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010079e:	b2 fd                	mov    $0xfd,%dl
f01007a0:	ec                   	in     (%dx),%al
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01007a1:	3c ff                	cmp    $0xff,%al
f01007a3:	0f 95 c1             	setne  %cl
f01007a6:	88 0d 34 12 20 f0    	mov    %cl,0xf0201234
f01007ac:	89 f2                	mov    %esi,%edx
f01007ae:	ec                   	in     (%dx),%al
f01007af:	89 da                	mov    %ebx,%edx
f01007b1:	ec                   	in     (%dx),%al
	if (serial_exists)
f01007b2:	84 c9                	test   %cl,%cl
f01007b4:	74 1d                	je     f01007d3 <cons_init+0x114>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f01007b6:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f01007bd:	25 ef ff 00 00       	and    $0xffef,%eax
f01007c2:	89 04 24             	mov    %eax,(%esp)
f01007c5:	e8 94 36 00 00       	call   f0103e5e <irq_setmask_8259A>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007ca:	80 3d 34 12 20 f0 00 	cmpb   $0x0,0xf0201234
f01007d1:	75 0c                	jne    f01007df <cons_init+0x120>
		cprintf("Serial port does not exist!\n");
f01007d3:	c7 04 24 4f 6f 10 f0 	movl   $0xf0106f4f,(%esp)
f01007da:	e8 be 37 00 00       	call   f0103f9d <cprintf>
}
f01007df:	83 c4 1c             	add    $0x1c,%esp
f01007e2:	5b                   	pop    %ebx
f01007e3:	5e                   	pop    %esi
f01007e4:	5f                   	pop    %edi
f01007e5:	5d                   	pop    %ebp
f01007e6:	c3                   	ret    

f01007e7 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007e7:	55                   	push   %ebp
f01007e8:	89 e5                	mov    %esp,%ebp
f01007ea:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01007f0:	e8 64 fc ff ff       	call   f0100459 <cons_putc>
}
f01007f5:	c9                   	leave  
f01007f6:	c3                   	ret    

f01007f7 <getchar>:

int
getchar(void)
{
f01007f7:	55                   	push   %ebp
f01007f8:	89 e5                	mov    %esp,%ebp
f01007fa:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007fd:	e8 73 fe ff ff       	call   f0100675 <cons_getc>
f0100802:	85 c0                	test   %eax,%eax
f0100804:	74 f7                	je     f01007fd <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100806:	c9                   	leave  
f0100807:	c3                   	ret    

f0100808 <iscons>:

int
iscons(int fdnum)
{
f0100808:	55                   	push   %ebp
f0100809:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010080b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100810:	5d                   	pop    %ebp
f0100811:	c3                   	ret    
f0100812:	66 90                	xchg   %ax,%ax
f0100814:	66 90                	xchg   %ax,%ax
f0100816:	66 90                	xchg   %ax,%ax
f0100818:	66 90                	xchg   %ax,%ax
f010081a:	66 90                	xchg   %ax,%ax
f010081c:	66 90                	xchg   %ax,%ax
f010081e:	66 90                	xchg   %ax,%ax

f0100820 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100820:	55                   	push   %ebp
f0100821:	89 e5                	mov    %esp,%ebp
f0100823:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100826:	c7 44 24 08 a0 71 10 	movl   $0xf01071a0,0x8(%esp)
f010082d:	f0 
f010082e:	c7 44 24 04 be 71 10 	movl   $0xf01071be,0x4(%esp)
f0100835:	f0 
f0100836:	c7 04 24 c3 71 10 f0 	movl   $0xf01071c3,(%esp)
f010083d:	e8 5b 37 00 00       	call   f0103f9d <cprintf>
f0100842:	c7 44 24 08 74 72 10 	movl   $0xf0107274,0x8(%esp)
f0100849:	f0 
f010084a:	c7 44 24 04 cc 71 10 	movl   $0xf01071cc,0x4(%esp)
f0100851:	f0 
f0100852:	c7 04 24 c3 71 10 f0 	movl   $0xf01071c3,(%esp)
f0100859:	e8 3f 37 00 00       	call   f0103f9d <cprintf>
f010085e:	c7 44 24 08 9c 72 10 	movl   $0xf010729c,0x8(%esp)
f0100865:	f0 
f0100866:	c7 44 24 04 d5 71 10 	movl   $0xf01071d5,0x4(%esp)
f010086d:	f0 
f010086e:	c7 04 24 c3 71 10 f0 	movl   $0xf01071c3,(%esp)
f0100875:	e8 23 37 00 00       	call   f0103f9d <cprintf>
	return 0;
}
f010087a:	b8 00 00 00 00       	mov    $0x0,%eax
f010087f:	c9                   	leave  
f0100880:	c3                   	ret    

f0100881 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100881:	55                   	push   %ebp
f0100882:	89 e5                	mov    %esp,%ebp
f0100884:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100887:	c7 04 24 df 71 10 f0 	movl   $0xf01071df,(%esp)
f010088e:	e8 0a 37 00 00       	call   f0103f9d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100893:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010089a:	00 
f010089b:	c7 04 24 d0 72 10 f0 	movl   $0xf01072d0,(%esp)
f01008a2:	e8 f6 36 00 00       	call   f0103f9d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01008a7:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01008ae:	00 
f01008af:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01008b6:	f0 
f01008b7:	c7 04 24 f8 72 10 f0 	movl   $0xf01072f8,(%esp)
f01008be:	e8 da 36 00 00       	call   f0103f9d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008c3:	c7 44 24 08 77 6e 10 	movl   $0x106e77,0x8(%esp)
f01008ca:	00 
f01008cb:	c7 44 24 04 77 6e 10 	movl   $0xf0106e77,0x4(%esp)
f01008d2:	f0 
f01008d3:	c7 04 24 1c 73 10 f0 	movl   $0xf010731c,(%esp)
f01008da:	e8 be 36 00 00       	call   f0103f9d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008df:	c7 44 24 08 00 10 20 	movl   $0x201000,0x8(%esp)
f01008e6:	00 
f01008e7:	c7 44 24 04 00 10 20 	movl   $0xf0201000,0x4(%esp)
f01008ee:	f0 
f01008ef:	c7 04 24 40 73 10 f0 	movl   $0xf0107340,(%esp)
f01008f6:	e8 a2 36 00 00       	call   f0103f9d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008fb:	c7 44 24 08 08 30 24 	movl   $0x243008,0x8(%esp)
f0100902:	00 
f0100903:	c7 44 24 04 08 30 24 	movl   $0xf0243008,0x4(%esp)
f010090a:	f0 
f010090b:	c7 04 24 64 73 10 f0 	movl   $0xf0107364,(%esp)
f0100912:	e8 86 36 00 00       	call   f0103f9d <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100917:	b8 07 34 24 f0       	mov    $0xf0243407,%eax
f010091c:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100921:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100926:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010092c:	85 c0                	test   %eax,%eax
f010092e:	0f 48 c2             	cmovs  %edx,%eax
f0100931:	c1 f8 0a             	sar    $0xa,%eax
f0100934:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100938:	c7 04 24 88 73 10 f0 	movl   $0xf0107388,(%esp)
f010093f:	e8 59 36 00 00       	call   f0103f9d <cprintf>
	return 0;
}
f0100944:	b8 00 00 00 00       	mov    $0x0,%eax
f0100949:	c9                   	leave  
f010094a:	c3                   	ret    

f010094b <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010094b:	55                   	push   %ebp
f010094c:	89 e5                	mov    %esp,%ebp
f010094e:	57                   	push   %edi
f010094f:	56                   	push   %esi
f0100950:	53                   	push   %ebx
f0100951:	83 ec 4c             	sub    $0x4c,%esp
	cprintf("Stack backtrace:\n");
f0100954:	c7 04 24 f8 71 10 f0 	movl   $0xf01071f8,(%esp)
f010095b:	e8 3d 36 00 00       	call   f0103f9d <cprintf>
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100960:	89 e8                	mov    %ebp,%eax
f0100962:	89 c6                	mov    %eax,%esi
    unsigned int ebp, esp, eip;
    ebp = read_ebp(); 
    while(ebp){
f0100964:	85 c0                	test   %eax,%eax
f0100966:	0f 84 97 00 00 00    	je     f0100a03 <mon_backtrace+0xb8>
        eip = *(unsigned int *)(ebp + 4);
f010096c:	8d 5e 04             	lea    0x4(%esi),%ebx
f010096f:	8b 46 04             	mov    0x4(%esi),%eax
f0100972:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        esp = ebp + 4;
        cprintf("ebp %08x eip %08x args", ebp, eip);
f0100975:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100979:	89 74 24 04          	mov    %esi,0x4(%esp)
f010097d:	c7 04 24 0a 72 10 f0 	movl   $0xf010720a,(%esp)
f0100984:	e8 14 36 00 00       	call   f0103f9d <cprintf>
f0100989:	8d 7e 18             	lea    0x18(%esi),%edi
		int i;
        for(i = 0; i < 5; ++i){
            esp += 4;
f010098c:	83 c3 04             	add    $0x4,%ebx
            cprintf(" %08x", *(unsigned int *)esp);
f010098f:	8b 03                	mov    (%ebx),%eax
f0100991:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100995:	c7 04 24 21 72 10 f0 	movl   $0xf0107221,(%esp)
f010099c:	e8 fc 35 00 00       	call   f0103f9d <cprintf>
        for(i = 0; i < 5; ++i){
f01009a1:	39 fb                	cmp    %edi,%ebx
f01009a3:	75 e7                	jne    f010098c <mon_backtrace+0x41>
        }   
        cprintf("\n");
f01009a5:	c7 04 24 fe 76 10 f0 	movl   $0xf01076fe,(%esp)
f01009ac:	e8 ec 35 00 00       	call   f0103f9d <cprintf>
        struct Eipdebuginfo info;
		if (-1 == debuginfo_eip(eip, &info))
f01009b1:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01009b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009b8:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01009bb:	89 3c 24             	mov    %edi,(%esp)
f01009be:	e8 19 4b 00 00       	call   f01054dc <debuginfo_eip>
f01009c3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01009c6:	74 3b                	je     f0100a03 <mon_backtrace+0xb8>
			break;
        cprintf("%s:%d: %.*s+%u\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
f01009c8:	89 f8                	mov    %edi,%eax
f01009ca:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01009cd:	89 44 24 14          	mov    %eax,0x14(%esp)
f01009d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009d4:	89 44 24 10          	mov    %eax,0x10(%esp)
f01009d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01009db:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01009e2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01009e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009ed:	c7 04 24 27 72 10 f0 	movl   $0xf0107227,(%esp)
f01009f4:	e8 a4 35 00 00       	call   f0103f9d <cprintf>
        ebp = *(unsigned int *)ebp;
f01009f9:	8b 36                	mov    (%esi),%esi
    while(ebp){
f01009fb:	85 f6                	test   %esi,%esi
f01009fd:	0f 85 69 ff ff ff    	jne    f010096c <mon_backtrace+0x21>
    }   
	return 0;
}
f0100a03:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a08:	83 c4 4c             	add    $0x4c,%esp
f0100a0b:	5b                   	pop    %ebx
f0100a0c:	5e                   	pop    %esi
f0100a0d:	5f                   	pop    %edi
f0100a0e:	5d                   	pop    %ebp
f0100a0f:	c3                   	ret    

f0100a10 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100a10:	55                   	push   %ebp
f0100a11:	89 e5                	mov    %esp,%ebp
f0100a13:	57                   	push   %edi
f0100a14:	56                   	push   %esi
f0100a15:	53                   	push   %ebx
f0100a16:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100a19:	c7 04 24 b4 73 10 f0 	movl   $0xf01073b4,(%esp)
f0100a20:	e8 78 35 00 00       	call   f0103f9d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100a25:	c7 04 24 d8 73 10 f0 	movl   $0xf01073d8,(%esp)
f0100a2c:	e8 6c 35 00 00       	call   f0103f9d <cprintf>

	if (tf != NULL)
f0100a31:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100a35:	74 0b                	je     f0100a42 <monitor+0x32>
		print_trapframe(tf);
f0100a37:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a3a:	89 04 24             	mov    %eax,(%esp)
f0100a3d:	e8 33 3b 00 00       	call   f0104575 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100a42:	c7 04 24 37 72 10 f0 	movl   $0xf0107237,(%esp)
f0100a49:	e8 a2 53 00 00       	call   f0105df0 <readline>
f0100a4e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a50:	85 c0                	test   %eax,%eax
f0100a52:	74 ee                	je     f0100a42 <monitor+0x32>
	argv[argc] = 0;
f0100a54:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a5b:	be 00 00 00 00       	mov    $0x0,%esi
f0100a60:	eb 0a                	jmp    f0100a6c <monitor+0x5c>
			*buf++ = 0;
f0100a62:	c6 03 00             	movb   $0x0,(%ebx)
f0100a65:	89 f7                	mov    %esi,%edi
f0100a67:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a6a:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a6c:	0f b6 03             	movzbl (%ebx),%eax
f0100a6f:	84 c0                	test   %al,%al
f0100a71:	74 6a                	je     f0100add <monitor+0xcd>
f0100a73:	0f be c0             	movsbl %al,%eax
f0100a76:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a7a:	c7 04 24 3b 72 10 f0 	movl   $0xf010723b,(%esp)
f0100a81:	e8 f3 55 00 00       	call   f0106079 <strchr>
f0100a86:	85 c0                	test   %eax,%eax
f0100a88:	75 d8                	jne    f0100a62 <monitor+0x52>
		if (*buf == 0)
f0100a8a:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a8d:	74 4e                	je     f0100add <monitor+0xcd>
		if (argc == MAXARGS-1) {
f0100a8f:	83 fe 0f             	cmp    $0xf,%esi
f0100a92:	75 16                	jne    f0100aaa <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a94:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a9b:	00 
f0100a9c:	c7 04 24 40 72 10 f0 	movl   $0xf0107240,(%esp)
f0100aa3:	e8 f5 34 00 00       	call   f0103f9d <cprintf>
f0100aa8:	eb 98                	jmp    f0100a42 <monitor+0x32>
		argv[argc++] = buf;
f0100aaa:	8d 7e 01             	lea    0x1(%esi),%edi
f0100aad:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ab1:	0f b6 03             	movzbl (%ebx),%eax
f0100ab4:	84 c0                	test   %al,%al
f0100ab6:	75 0c                	jne    f0100ac4 <monitor+0xb4>
f0100ab8:	eb b0                	jmp    f0100a6a <monitor+0x5a>
			buf++;
f0100aba:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100abd:	0f b6 03             	movzbl (%ebx),%eax
f0100ac0:	84 c0                	test   %al,%al
f0100ac2:	74 a6                	je     f0100a6a <monitor+0x5a>
f0100ac4:	0f be c0             	movsbl %al,%eax
f0100ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100acb:	c7 04 24 3b 72 10 f0 	movl   $0xf010723b,(%esp)
f0100ad2:	e8 a2 55 00 00       	call   f0106079 <strchr>
f0100ad7:	85 c0                	test   %eax,%eax
f0100ad9:	74 df                	je     f0100aba <monitor+0xaa>
f0100adb:	eb 8d                	jmp    f0100a6a <monitor+0x5a>
	argv[argc] = 0;
f0100add:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100ae4:	00 
	if (argc == 0)
f0100ae5:	85 f6                	test   %esi,%esi
f0100ae7:	0f 84 55 ff ff ff    	je     f0100a42 <monitor+0x32>
f0100aed:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100af2:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		if (strcmp(argv[0], commands[i].name) == 0)
f0100af5:	8b 04 85 00 74 10 f0 	mov    -0xfef8c00(,%eax,4),%eax
f0100afc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b00:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100b03:	89 04 24             	mov    %eax,(%esp)
f0100b06:	e8 ea 54 00 00       	call   f0105ff5 <strcmp>
f0100b0b:	85 c0                	test   %eax,%eax
f0100b0d:	75 24                	jne    f0100b33 <monitor+0x123>
			return commands[i].func(argc, argv, tf);
f0100b0f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b12:	8b 55 08             	mov    0x8(%ebp),%edx
f0100b15:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100b19:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100b1c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100b20:	89 34 24             	mov    %esi,(%esp)
f0100b23:	ff 14 85 08 74 10 f0 	call   *-0xfef8bf8(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100b2a:	85 c0                	test   %eax,%eax
f0100b2c:	78 25                	js     f0100b53 <monitor+0x143>
f0100b2e:	e9 0f ff ff ff       	jmp    f0100a42 <monitor+0x32>
	for (i = 0; i < NCOMMANDS; i++) {
f0100b33:	83 c3 01             	add    $0x1,%ebx
f0100b36:	83 fb 03             	cmp    $0x3,%ebx
f0100b39:	75 b7                	jne    f0100af2 <monitor+0xe2>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100b3b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b42:	c7 04 24 5d 72 10 f0 	movl   $0xf010725d,(%esp)
f0100b49:	e8 4f 34 00 00       	call   f0103f9d <cprintf>
f0100b4e:	e9 ef fe ff ff       	jmp    f0100a42 <monitor+0x32>
				break;
	}
}
f0100b53:	83 c4 5c             	add    $0x5c,%esp
f0100b56:	5b                   	pop    %ebx
f0100b57:	5e                   	pop    %esi
f0100b58:	5f                   	pop    %edi
f0100b59:	5d                   	pop    %ebp
f0100b5a:	c3                   	ret    
f0100b5b:	66 90                	xchg   %ax,%ax
f0100b5d:	66 90                	xchg   %ax,%ax
f0100b5f:	90                   	nop

f0100b60 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b60:	55                   	push   %ebp
f0100b61:	89 e5                	mov    %esp,%ebp
f0100b63:	53                   	push   %ebx
f0100b64:	83 ec 14             	sub    $0x14,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b67:	83 3d 38 12 20 f0 00 	cmpl   $0x0,0xf0201238
f0100b6e:	75 11                	jne    f0100b81 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b70:	ba 07 40 24 f0       	mov    $0xf0244007,%edx
f0100b75:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b7b:	89 15 38 12 20 f0    	mov    %edx,0xf0201238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if((unsigned)nextfree + n > KERNBASE + npages * PGSIZE)
f0100b81:	8b 15 38 12 20 f0    	mov    0xf0201238,%edx
f0100b87:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
f0100b8a:	8b 0d 88 1e 20 f0    	mov    0xf0201e88,%ecx
f0100b90:	81 c1 00 00 0f 00    	add    $0xf0000,%ecx
f0100b96:	c1 e1 0c             	shl    $0xc,%ecx
f0100b99:	39 cb                	cmp    %ecx,%ebx
f0100b9b:	76 1c                	jbe    f0100bb9 <boot_alloc+0x59>
    	panic("boot_alloc: out of memory\n");
f0100b9d:	c7 44 24 08 24 74 10 	movl   $0xf0107424,0x8(%esp)
f0100ba4:	f0 
f0100ba5:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
f0100bac:	00 
f0100bad:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0100bb4:	e8 87 f4 ff ff       	call   f0100040 <_panic>
	result = nextfree;
	nextfree = ROUNDUP((char *)(nextfree + n), PGSIZE);
f0100bb9:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100bc0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bc5:	a3 38 12 20 f0       	mov    %eax,0xf0201238
	return result;
}
f0100bca:	89 d0                	mov    %edx,%eax
f0100bcc:	83 c4 14             	add    $0x14,%esp
f0100bcf:	5b                   	pop    %ebx
f0100bd0:	5d                   	pop    %ebp
f0100bd1:	c3                   	ret    

f0100bd2 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bd2:	2b 05 90 1e 20 f0    	sub    0xf0201e90,%eax
f0100bd8:	c1 f8 03             	sar    $0x3,%eax
f0100bdb:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100bde:	89 c2                	mov    %eax,%edx
f0100be0:	c1 ea 0c             	shr    $0xc,%edx
f0100be3:	3b 15 88 1e 20 f0    	cmp    0xf0201e88,%edx
f0100be9:	72 26                	jb     f0100c11 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100beb:	55                   	push   %ebp
f0100bec:	89 e5                	mov    %esp,%ebp
f0100bee:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bf1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bf5:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f0100bfc:	f0 
f0100bfd:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100c04:	00 
f0100c05:	c7 04 24 4b 74 10 f0 	movl   $0xf010744b,(%esp)
f0100c0c:	e8 2f f4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100c11:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return KADDR(page2pa(pp));
}
f0100c16:	c3                   	ret    

f0100c17 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100c17:	89 d1                	mov    %edx,%ecx
f0100c19:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100c1c:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100c1f:	a8 01                	test   $0x1,%al
f0100c21:	74 5d                	je     f0100c80 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100c23:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100c28:	89 c1                	mov    %eax,%ecx
f0100c2a:	c1 e9 0c             	shr    $0xc,%ecx
f0100c2d:	3b 0d 88 1e 20 f0    	cmp    0xf0201e88,%ecx
f0100c33:	72 26                	jb     f0100c5b <check_va2pa+0x44>
{
f0100c35:	55                   	push   %ebp
f0100c36:	89 e5                	mov    %esp,%ebp
f0100c38:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c3f:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f0100c46:	f0 
f0100c47:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f0100c4e:	00 
f0100c4f:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0100c56:	e8 e5 f3 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100c5b:	c1 ea 0c             	shr    $0xc,%edx
f0100c5e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100c64:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100c6b:	89 c2                	mov    %eax,%edx
f0100c6d:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100c70:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c75:	85 d2                	test   %edx,%edx
f0100c77:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100c7c:	0f 44 c2             	cmove  %edx,%eax
f0100c7f:	c3                   	ret    
		return ~0;
f0100c80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100c85:	c3                   	ret    

f0100c86 <check_page_free_list>:
{
f0100c86:	55                   	push   %ebp
f0100c87:	89 e5                	mov    %esp,%ebp
f0100c89:	57                   	push   %edi
f0100c8a:	56                   	push   %esi
f0100c8b:	53                   	push   %ebx
f0100c8c:	83 ec 4c             	sub    $0x4c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c8f:	84 c0                	test   %al,%al
f0100c91:	0f 85 6a 03 00 00    	jne    f0101001 <check_page_free_list+0x37b>
f0100c97:	e9 77 03 00 00       	jmp    f0101013 <check_page_free_list+0x38d>
		panic("'page_free_list' is a null pointer!");
f0100c9c:	c7 44 24 08 30 77 10 	movl   $0xf0107730,0x8(%esp)
f0100ca3:	f0 
f0100ca4:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f0100cab:	00 
f0100cac:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0100cb3:	e8 88 f3 ff ff       	call   f0100040 <_panic>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100cb8:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100cbb:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100cbe:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100cc1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100cc4:	89 c2                	mov    %eax,%edx
f0100cc6:	2b 15 90 1e 20 f0    	sub    0xf0201e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100ccc:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100cd2:	0f 95 c2             	setne  %dl
f0100cd5:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100cd8:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100cdc:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100cde:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ce2:	8b 00                	mov    (%eax),%eax
f0100ce4:	85 c0                	test   %eax,%eax
f0100ce6:	75 dc                	jne    f0100cc4 <check_page_free_list+0x3e>
		*tp[1] = 0;
f0100ce8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ceb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100cf1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cf4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cf7:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100cf9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100cfc:	a3 40 12 20 f0       	mov    %eax,0xf0201240
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d01:	89 c3                	mov    %eax,%ebx
f0100d03:	85 c0                	test   %eax,%eax
f0100d05:	74 6c                	je     f0100d73 <check_page_free_list+0xed>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d07:	be 01 00 00 00       	mov    $0x1,%esi
f0100d0c:	89 d8                	mov    %ebx,%eax
f0100d0e:	2b 05 90 1e 20 f0    	sub    0xf0201e90,%eax
f0100d14:	c1 f8 03             	sar    $0x3,%eax
f0100d17:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100d1a:	89 c2                	mov    %eax,%edx
f0100d1c:	c1 ea 16             	shr    $0x16,%edx
f0100d1f:	39 f2                	cmp    %esi,%edx
f0100d21:	73 4a                	jae    f0100d6d <check_page_free_list+0xe7>
	if (PGNUM(pa) >= npages)
f0100d23:	89 c2                	mov    %eax,%edx
f0100d25:	c1 ea 0c             	shr    $0xc,%edx
f0100d28:	3b 15 88 1e 20 f0    	cmp    0xf0201e88,%edx
f0100d2e:	72 20                	jb     f0100d50 <check_page_free_list+0xca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d30:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d34:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f0100d3b:	f0 
f0100d3c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100d43:	00 
f0100d44:	c7 04 24 4b 74 10 f0 	movl   $0xf010744b,(%esp)
f0100d4b:	e8 f0 f2 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100d50:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100d57:	00 
f0100d58:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100d5f:	00 
	return (void *)(pa + KERNBASE);
f0100d60:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d65:	89 04 24             	mov    %eax,(%esp)
f0100d68:	e8 6c 53 00 00       	call   f01060d9 <memset>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d6d:	8b 1b                	mov    (%ebx),%ebx
f0100d6f:	85 db                	test   %ebx,%ebx
f0100d71:	75 99                	jne    f0100d0c <check_page_free_list+0x86>
	first_free_page = (char *) boot_alloc(0);
f0100d73:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d78:	e8 e3 fd ff ff       	call   f0100b60 <boot_alloc>
f0100d7d:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d80:	8b 15 40 12 20 f0    	mov    0xf0201240,%edx
f0100d86:	85 d2                	test   %edx,%edx
f0100d88:	0f 84 27 02 00 00    	je     f0100fb5 <check_page_free_list+0x32f>
		assert(pp >= pages);
f0100d8e:	8b 3d 90 1e 20 f0    	mov    0xf0201e90,%edi
f0100d94:	39 fa                	cmp    %edi,%edx
f0100d96:	72 3f                	jb     f0100dd7 <check_page_free_list+0x151>
		assert(pp < pages + npages);
f0100d98:	a1 88 1e 20 f0       	mov    0xf0201e88,%eax
f0100d9d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100da0:	8d 04 c7             	lea    (%edi,%eax,8),%eax
f0100da3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100da6:	39 c2                	cmp    %eax,%edx
f0100da8:	73 56                	jae    f0100e00 <check_page_free_list+0x17a>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100daa:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0100dad:	89 d0                	mov    %edx,%eax
f0100daf:	29 f8                	sub    %edi,%eax
f0100db1:	a8 07                	test   $0x7,%al
f0100db3:	75 78                	jne    f0100e2d <check_page_free_list+0x1a7>
	return (pp - pages) << PGSHIFT;
f0100db5:	c1 f8 03             	sar    $0x3,%eax
f0100db8:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100dbb:	85 c0                	test   %eax,%eax
f0100dbd:	0f 84 98 00 00 00    	je     f0100e5b <check_page_free_list+0x1d5>
		assert(page2pa(pp) != IOPHYSMEM);
f0100dc3:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100dc8:	0f 85 dc 00 00 00    	jne    f0100eaa <check_page_free_list+0x224>
f0100dce:	e9 b3 00 00 00       	jmp    f0100e86 <check_page_free_list+0x200>
		assert(pp >= pages);
f0100dd3:	39 d7                	cmp    %edx,%edi
f0100dd5:	76 24                	jbe    f0100dfb <check_page_free_list+0x175>
f0100dd7:	c7 44 24 0c 59 74 10 	movl   $0xf0107459,0xc(%esp)
f0100dde:	f0 
f0100ddf:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0100de6:	f0 
f0100de7:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0100dee:	00 
f0100def:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0100df6:	e8 45 f2 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100dfb:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100dfe:	72 24                	jb     f0100e24 <check_page_free_list+0x19e>
f0100e00:	c7 44 24 0c 7a 74 10 	movl   $0xf010747a,0xc(%esp)
f0100e07:	f0 
f0100e08:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0100e0f:	f0 
f0100e10:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f0100e17:	00 
f0100e18:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0100e1f:	e8 1c f2 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e24:	89 d0                	mov    %edx,%eax
f0100e26:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100e29:	a8 07                	test   $0x7,%al
f0100e2b:	74 24                	je     f0100e51 <check_page_free_list+0x1cb>
f0100e2d:	c7 44 24 0c 54 77 10 	movl   $0xf0107754,0xc(%esp)
f0100e34:	f0 
f0100e35:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0100e3c:	f0 
f0100e3d:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f0100e44:	00 
f0100e45:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0100e4c:	e8 ef f1 ff ff       	call   f0100040 <_panic>
f0100e51:	c1 f8 03             	sar    $0x3,%eax
f0100e54:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100e57:	85 c0                	test   %eax,%eax
f0100e59:	75 24                	jne    f0100e7f <check_page_free_list+0x1f9>
f0100e5b:	c7 44 24 0c 8e 74 10 	movl   $0xf010748e,0xc(%esp)
f0100e62:	f0 
f0100e63:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0100e6a:	f0 
f0100e6b:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0100e72:	00 
f0100e73:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0100e7a:	e8 c1 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e7f:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e84:	75 31                	jne    f0100eb7 <check_page_free_list+0x231>
f0100e86:	c7 44 24 0c 9f 74 10 	movl   $0xf010749f,0xc(%esp)
f0100e8d:	f0 
f0100e8e:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0100e95:	f0 
f0100e96:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
f0100e9d:	00 
f0100e9e:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0100ea5:	e8 96 f1 ff ff       	call   f0100040 <_panic>
	int nfree_basemem = 0, nfree_extmem = 0;
f0100eaa:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100eaf:	be 00 00 00 00       	mov    $0x0,%esi
f0100eb4:	89 5d cc             	mov    %ebx,-0x34(%ebp)
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100eb7:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ebc:	75 24                	jne    f0100ee2 <check_page_free_list+0x25c>
f0100ebe:	c7 44 24 0c 88 77 10 	movl   $0xf0107788,0xc(%esp)
f0100ec5:	f0 
f0100ec6:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0100ecd:	f0 
f0100ece:	c7 44 24 04 da 02 00 	movl   $0x2da,0x4(%esp)
f0100ed5:	00 
f0100ed6:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0100edd:	e8 5e f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ee2:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100ee7:	75 24                	jne    f0100f0d <check_page_free_list+0x287>
f0100ee9:	c7 44 24 0c b8 74 10 	movl   $0xf01074b8,0xc(%esp)
f0100ef0:	f0 
f0100ef1:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0100ef8:	f0 
f0100ef9:	c7 44 24 04 db 02 00 	movl   $0x2db,0x4(%esp)
f0100f00:	00 
f0100f01:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0100f08:	e8 33 f1 ff ff       	call   f0100040 <_panic>
f0100f0d:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100f0f:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100f14:	0f 86 0b 01 00 00    	jbe    f0101025 <check_page_free_list+0x39f>
	if (PGNUM(pa) >= npages)
f0100f1a:	89 c3                	mov    %eax,%ebx
f0100f1c:	c1 eb 0c             	shr    $0xc,%ebx
f0100f1f:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0100f22:	77 20                	ja     f0100f44 <check_page_free_list+0x2be>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f24:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f28:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f0100f2f:	f0 
f0100f30:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100f37:	00 
f0100f38:	c7 04 24 4b 74 10 f0 	movl   $0xf010744b,(%esp)
f0100f3f:	e8 fc f0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100f44:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0100f4a:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100f4d:	0f 86 e2 00 00 00    	jbe    f0101035 <check_page_free_list+0x3af>
f0100f53:	c7 44 24 0c ac 77 10 	movl   $0xf01077ac,0xc(%esp)
f0100f5a:	f0 
f0100f5b:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0100f62:	f0 
f0100f63:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f0100f6a:	00 
f0100f6b:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0100f72:	e8 c9 f0 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100f77:	c7 44 24 0c d2 74 10 	movl   $0xf01074d2,0xc(%esp)
f0100f7e:	f0 
f0100f7f:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0100f86:	f0 
f0100f87:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f0100f8e:	00 
f0100f8f:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0100f96:	e8 a5 f0 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100f9b:	83 c6 01             	add    $0x1,%esi
f0100f9e:	eb 04                	jmp    f0100fa4 <check_page_free_list+0x31e>
			++nfree_extmem;
f0100fa0:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fa4:	8b 12                	mov    (%edx),%edx
f0100fa6:	85 d2                	test   %edx,%edx
f0100fa8:	0f 85 25 fe ff ff    	jne    f0100dd3 <check_page_free_list+0x14d>
f0100fae:	8b 5d cc             	mov    -0x34(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100fb1:	85 f6                	test   %esi,%esi
f0100fb3:	7f 24                	jg     f0100fd9 <check_page_free_list+0x353>
f0100fb5:	c7 44 24 0c ef 74 10 	movl   $0xf01074ef,0xc(%esp)
f0100fbc:	f0 
f0100fbd:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0100fc4:	f0 
f0100fc5:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f0100fcc:	00 
f0100fcd:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0100fd4:	e8 67 f0 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100fd9:	85 db                	test   %ebx,%ebx
f0100fdb:	7f 78                	jg     f0101055 <check_page_free_list+0x3cf>
f0100fdd:	c7 44 24 0c 01 75 10 	movl   $0xf0107501,0xc(%esp)
f0100fe4:	f0 
f0100fe5:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0100fec:	f0 
f0100fed:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f0100ff4:	00 
f0100ff5:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0100ffc:	e8 3f f0 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0101001:	a1 40 12 20 f0       	mov    0xf0201240,%eax
f0101006:	85 c0                	test   %eax,%eax
f0101008:	0f 85 aa fc ff ff    	jne    f0100cb8 <check_page_free_list+0x32>
f010100e:	e9 89 fc ff ff       	jmp    f0100c9c <check_page_free_list+0x16>
f0101013:	83 3d 40 12 20 f0 00 	cmpl   $0x0,0xf0201240
f010101a:	75 29                	jne    f0101045 <check_page_free_list+0x3bf>
f010101c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101020:	e9 77 fc ff ff       	jmp    f0100c9c <check_page_free_list+0x16>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101025:	3d 00 70 00 00       	cmp    $0x7000,%eax
f010102a:	0f 85 6b ff ff ff    	jne    f0100f9b <check_page_free_list+0x315>
f0101030:	e9 42 ff ff ff       	jmp    f0100f77 <check_page_free_list+0x2f1>
f0101035:	3d 00 70 00 00       	cmp    $0x7000,%eax
f010103a:	0f 85 60 ff ff ff    	jne    f0100fa0 <check_page_free_list+0x31a>
f0101040:	e9 32 ff ff ff       	jmp    f0100f77 <check_page_free_list+0x2f1>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101045:	8b 1d 40 12 20 f0    	mov    0xf0201240,%ebx
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010104b:	be 00 04 00 00       	mov    $0x400,%esi
f0101050:	e9 b7 fc ff ff       	jmp    f0100d0c <check_page_free_list+0x86>
}
f0101055:	83 c4 4c             	add    $0x4c,%esp
f0101058:	5b                   	pop    %ebx
f0101059:	5e                   	pop    %esi
f010105a:	5f                   	pop    %edi
f010105b:	5d                   	pop    %ebp
f010105c:	c3                   	ret    

f010105d <page_init>:
{
f010105d:	55                   	push   %ebp
f010105e:	89 e5                	mov    %esp,%ebp
f0101060:	57                   	push   %edi
f0101061:	56                   	push   %esi
f0101062:	53                   	push   %ebx
f0101063:	83 ec 4c             	sub    $0x4c,%esp
	physaddr_t nextfree_paddr = PADDR((pde_t *)boot_alloc(0));
f0101066:	b8 00 00 00 00       	mov    $0x0,%eax
f010106b:	e8 f0 fa ff ff       	call   f0100b60 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0101070:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101075:	77 20                	ja     f0101097 <page_init+0x3a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101077:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010107b:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0101082:	f0 
f0101083:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
f010108a:	00 
f010108b:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101092:	e8 a9 ef ff ff       	call   f0100040 <_panic>
	physaddr_t used_interval[3][2] = {{0, PGSIZE}, {MPENTRY_PADDR, MPENTRY_PADDR + PGSIZE}, {IOPHYSMEM, nextfree_paddr}};
f0101097:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f010109e:	c7 45 d4 00 10 00 00 	movl   $0x1000,-0x2c(%ebp)
f01010a5:	c7 45 d8 00 70 00 00 	movl   $0x7000,-0x28(%ebp)
f01010ac:	c7 45 dc 00 80 00 00 	movl   $0x8000,-0x24(%ebp)
f01010b3:	c7 45 e0 00 00 0a 00 	movl   $0xa0000,-0x20(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01010ba:	05 00 00 00 10       	add    $0x10000000,%eax
f01010bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i = 0; i < npages; ++i){
f01010c2:	83 3d 88 1e 20 f0 00 	cmpl   $0x0,0xf0201e88
f01010c9:	0f 84 99 00 00 00    	je     f0101168 <page_init+0x10b>
f01010cf:	8b 3d 40 12 20 f0    	mov    0xf0201240,%edi
f01010d5:	be 00 00 00 00       	mov    $0x0,%esi
f01010da:	b9 00 00 00 00       	mov    $0x0,%ecx
	int used_interval_pointer = 0;
f01010df:	b8 00 00 00 00       	mov    $0x0,%eax
f01010e4:	eb 58                	jmp    f010113e <page_init+0xe1>
			used_interval_pointer++;
f01010e6:	83 c0 01             	add    $0x1,%eax
		while(used_interval_pointer < kUsed_interval_length && used_interval[used_interval_pointer][1] <= page2pa(pages + i))
f01010e9:	83 f8 03             	cmp    $0x3,%eax
f01010ec:	74 08                	je     f01010f6 <page_init+0x99>
f01010ee:	39 54 c5 d4          	cmp    %edx,-0x2c(%ebp,%eax,8)
f01010f2:	76 f2                	jbe    f01010e6 <page_init+0x89>
f01010f4:	eb 6a                	jmp    f0101160 <page_init+0x103>
			pages[i].pp_ref = 0;
f01010f6:	c1 e6 03             	shl    $0x3,%esi
f01010f9:	89 f2                	mov    %esi,%edx
f01010fb:	03 15 90 1e 20 f0    	add    0xf0201e90,%edx
f0101101:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0101107:	89 3a                	mov    %edi,(%edx)
			page_free_list = pages + i;
f0101109:	89 f7                	mov    %esi,%edi
f010110b:	03 3d 90 1e 20 f0    	add    0xf0201e90,%edi
f0101111:	eb 16                	jmp    f0101129 <page_init+0xcc>
			pages[i].pp_ref = 1;
f0101113:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0101116:	66 c7 46 04 01 00    	movw   $0x1,0x4(%esi)
			pages[i].pp_link = NULL;
f010111c:	8b 15 90 1e 20 f0    	mov    0xf0201e90,%edx
f0101122:	c7 04 1a 00 00 00 00 	movl   $0x0,(%edx,%ebx,1)
	for(i = 0; i < npages; ++i){
f0101129:	83 c1 01             	add    $0x1,%ecx
f010112c:	89 ce                	mov    %ecx,%esi
f010112e:	3b 0d 88 1e 20 f0    	cmp    0xf0201e88,%ecx
f0101134:	72 08                	jb     f010113e <page_init+0xe1>
f0101136:	89 3d 40 12 20 f0    	mov    %edi,0xf0201240
f010113c:	eb 2a                	jmp    f0101168 <page_init+0x10b>
		while(used_interval_pointer < kUsed_interval_length && used_interval[used_interval_pointer][1] <= page2pa(pages + i))
f010113e:	83 f8 02             	cmp    $0x2,%eax
f0101141:	7f b3                	jg     f01010f6 <page_init+0x99>
f0101143:	8d 1c f5 00 00 00 00 	lea    0x0(,%esi,8),%ebx
f010114a:	89 da                	mov    %ebx,%edx
f010114c:	03 15 90 1e 20 f0    	add    0xf0201e90,%edx
f0101152:	89 55 c4             	mov    %edx,-0x3c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101155:	89 da                	mov    %ebx,%edx
f0101157:	c1 e2 09             	shl    $0x9,%edx
f010115a:	39 54 c5 d4          	cmp    %edx,-0x2c(%ebp,%eax,8)
f010115e:	76 86                	jbe    f01010e6 <page_init+0x89>
		if(used_interval_pointer >= kUsed_interval_length || page2pa(pages + i) < used_interval[used_interval_pointer][0]){
f0101160:	39 54 c5 d0          	cmp    %edx,-0x30(%ebp,%eax,8)
f0101164:	77 90                	ja     f01010f6 <page_init+0x99>
f0101166:	eb ab                	jmp    f0101113 <page_init+0xb6>
}
f0101168:	83 c4 4c             	add    $0x4c,%esp
f010116b:	5b                   	pop    %ebx
f010116c:	5e                   	pop    %esi
f010116d:	5f                   	pop    %edi
f010116e:	5d                   	pop    %ebp
f010116f:	c3                   	ret    

f0101170 <page_alloc>:
{
f0101170:	55                   	push   %ebp
f0101171:	89 e5                	mov    %esp,%ebp
f0101173:	53                   	push   %ebx
f0101174:	83 ec 14             	sub    $0x14,%esp
	if(!page_free_list) return NULL;
f0101177:	8b 1d 40 12 20 f0    	mov    0xf0201240,%ebx
f010117d:	85 db                	test   %ebx,%ebx
f010117f:	74 6f                	je     f01011f0 <page_alloc+0x80>
	page_free_list = page_free_list->pp_link;
f0101181:	8b 03                	mov    (%ebx),%eax
f0101183:	a3 40 12 20 f0       	mov    %eax,0xf0201240
	new_page->pp_link = NULL;
f0101188:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return new_page;
f010118e:	89 d8                	mov    %ebx,%eax
	if(alloc_flags & ALLOC_ZERO)
f0101190:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101194:	74 5f                	je     f01011f5 <page_alloc+0x85>
f0101196:	2b 05 90 1e 20 f0    	sub    0xf0201e90,%eax
f010119c:	c1 f8 03             	sar    $0x3,%eax
f010119f:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01011a2:	89 c2                	mov    %eax,%edx
f01011a4:	c1 ea 0c             	shr    $0xc,%edx
f01011a7:	3b 15 88 1e 20 f0    	cmp    0xf0201e88,%edx
f01011ad:	72 20                	jb     f01011cf <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011af:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011b3:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f01011ba:	f0 
f01011bb:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01011c2:	00 
f01011c3:	c7 04 24 4b 74 10 f0 	movl   $0xf010744b,(%esp)
f01011ca:	e8 71 ee ff ff       	call   f0100040 <_panic>
		memset(page2kva(new_page), 0, PGSIZE);
f01011cf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01011d6:	00 
f01011d7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01011de:	00 
	return (void *)(pa + KERNBASE);
f01011df:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01011e4:	89 04 24             	mov    %eax,(%esp)
f01011e7:	e8 ed 4e 00 00       	call   f01060d9 <memset>
	return new_page;
f01011ec:	89 d8                	mov    %ebx,%eax
f01011ee:	eb 05                	jmp    f01011f5 <page_alloc+0x85>
	if(!page_free_list) return NULL;
f01011f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01011f5:	83 c4 14             	add    $0x14,%esp
f01011f8:	5b                   	pop    %ebx
f01011f9:	5d                   	pop    %ebp
f01011fa:	c3                   	ret    

f01011fb <page_free>:
{
f01011fb:	55                   	push   %ebp
f01011fc:	89 e5                	mov    %esp,%ebp
f01011fe:	8b 45 08             	mov    0x8(%ebp),%eax
	if(!pp || pp->pp_ref) return;
f0101201:	85 c0                	test   %eax,%eax
f0101203:	74 14                	je     f0101219 <page_free+0x1e>
f0101205:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010120a:	75 0d                	jne    f0101219 <page_free+0x1e>
	pp->pp_link = page_free_list;
f010120c:	8b 15 40 12 20 f0    	mov    0xf0201240,%edx
f0101212:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101214:	a3 40 12 20 f0       	mov    %eax,0xf0201240
}
f0101219:	5d                   	pop    %ebp
f010121a:	c3                   	ret    

f010121b <page_decref>:
{
f010121b:	55                   	push   %ebp
f010121c:	89 e5                	mov    %esp,%ebp
f010121e:	83 ec 04             	sub    $0x4,%esp
f0101221:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101224:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f0101228:	8d 51 ff             	lea    -0x1(%ecx),%edx
f010122b:	66 89 50 04          	mov    %dx,0x4(%eax)
f010122f:	66 85 d2             	test   %dx,%dx
f0101232:	75 08                	jne    f010123c <page_decref+0x21>
		page_free(pp);
f0101234:	89 04 24             	mov    %eax,(%esp)
f0101237:	e8 bf ff ff ff       	call   f01011fb <page_free>
}
f010123c:	c9                   	leave  
f010123d:	c3                   	ret    

f010123e <pgdir_walk>:
{
f010123e:	55                   	push   %ebp
f010123f:	89 e5                	mov    %esp,%ebp
f0101241:	56                   	push   %esi
f0101242:	53                   	push   %ebx
f0101243:	83 ec 10             	sub    $0x10,%esp
f0101246:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t *pgdir_entry = pgdir + PDX(va);
f0101249:	89 f3                	mov    %esi,%ebx
f010124b:	c1 eb 16             	shr    $0x16,%ebx
f010124e:	c1 e3 02             	shl    $0x2,%ebx
f0101251:	03 5d 08             	add    0x8(%ebp),%ebx
	if(!(*pgdir_entry & PTE_P)){
f0101254:	f6 03 01             	testb  $0x1,(%ebx)
f0101257:	75 2d                	jne    f0101286 <pgdir_walk+0x48>
		if(create){
f0101259:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010125d:	74 6d                	je     f01012cc <pgdir_walk+0x8e>
			struct PageInfo *new_pageinfo = page_alloc(ALLOC_ZERO);
f010125f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101266:	e8 05 ff ff ff       	call   f0101170 <page_alloc>
			if(!new_pageinfo) return NULL;
f010126b:	85 c0                	test   %eax,%eax
f010126d:	74 64                	je     f01012d3 <pgdir_walk+0x95>
			new_pageinfo->pp_ref = 1;
f010126f:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101275:	2b 05 90 1e 20 f0    	sub    0xf0201e90,%eax
f010127b:	c1 f8 03             	sar    $0x3,%eax
f010127e:	c1 e0 0c             	shl    $0xc,%eax
			*pgdir_entry = page2pa(new_pageinfo) | PTE_P | PTE_U | PTE_W;
f0101281:	83 c8 07             	or     $0x7,%eax
f0101284:	89 03                	mov    %eax,(%ebx)
	pte_t *pg_address = KADDR(PTE_ADDR(*pgdir_entry));
f0101286:	8b 03                	mov    (%ebx),%eax
f0101288:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010128d:	89 c2                	mov    %eax,%edx
f010128f:	c1 ea 0c             	shr    $0xc,%edx
f0101292:	3b 15 88 1e 20 f0    	cmp    0xf0201e88,%edx
f0101298:	72 20                	jb     f01012ba <pgdir_walk+0x7c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010129a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010129e:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f01012a5:	f0 
f01012a6:	c7 44 24 04 ad 01 00 	movl   $0x1ad,0x4(%esp)
f01012ad:	00 
f01012ae:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01012b5:	e8 86 ed ff ff       	call   f0100040 <_panic>
	return pg_address + PTX(va);
f01012ba:	c1 ee 0a             	shr    $0xa,%esi
f01012bd:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01012c3:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f01012ca:	eb 0c                	jmp    f01012d8 <pgdir_walk+0x9a>
			return NULL;
f01012cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01012d1:	eb 05                	jmp    f01012d8 <pgdir_walk+0x9a>
			if(!new_pageinfo) return NULL;
f01012d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01012d8:	83 c4 10             	add    $0x10,%esp
f01012db:	5b                   	pop    %ebx
f01012dc:	5e                   	pop    %esi
f01012dd:	5d                   	pop    %ebp
f01012de:	c3                   	ret    

f01012df <boot_map_region>:
{
f01012df:	55                   	push   %ebp
f01012e0:	89 e5                	mov    %esp,%ebp
f01012e2:	57                   	push   %edi
f01012e3:	56                   	push   %esi
f01012e4:	53                   	push   %ebx
f01012e5:	83 ec 2c             	sub    $0x2c,%esp
f01012e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01012eb:	8b 7d 08             	mov    0x8(%ebp),%edi
	unsigned length = (size + PGSIZE - 1) / PGSIZE;
f01012ee:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f01012f4:	c1 e9 0c             	shr    $0xc,%ecx
f01012f7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(i = 0; i < length; ++i){
f01012fa:	85 c9                	test   %ecx,%ecx
f01012fc:	74 46                	je     f0101344 <boot_map_region+0x65>
f01012fe:	89 d6                	mov    %edx,%esi
f0101300:	bb 00 00 00 00       	mov    $0x0,%ebx
		*pg_entry = cur_pa | perm | PTE_P;
f0101305:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101308:	83 c8 01             	or     $0x1,%eax
f010130b:	89 45 dc             	mov    %eax,-0x24(%ebp)
		pte_t *pg_entry = pgdir_walk(pgdir, (void *)cur_va, true);
f010130e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101315:	00 
f0101316:	89 74 24 04          	mov    %esi,0x4(%esp)
f010131a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010131d:	89 04 24             	mov    %eax,(%esp)
f0101320:	e8 19 ff ff ff       	call   f010123e <pgdir_walk>
		if(!pg_entry) continue;
f0101325:	85 c0                	test   %eax,%eax
f0101327:	74 13                	je     f010133c <boot_map_region+0x5d>
		*pg_entry = cur_pa | perm | PTE_P;
f0101329:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010132c:	09 fa                	or     %edi,%edx
f010132e:	89 10                	mov    %edx,(%eax)
		cur_va += PGSIZE;
f0101330:	81 c6 00 10 00 00    	add    $0x1000,%esi
		cur_pa += PGSIZE;
f0101336:	81 c7 00 10 00 00    	add    $0x1000,%edi
	for(i = 0; i < length; ++i){
f010133c:	83 c3 01             	add    $0x1,%ebx
f010133f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101342:	75 ca                	jne    f010130e <boot_map_region+0x2f>
}
f0101344:	83 c4 2c             	add    $0x2c,%esp
f0101347:	5b                   	pop    %ebx
f0101348:	5e                   	pop    %esi
f0101349:	5f                   	pop    %edi
f010134a:	5d                   	pop    %ebp
f010134b:	c3                   	ret    

f010134c <page_lookup>:
{
f010134c:	55                   	push   %ebp
f010134d:	89 e5                	mov    %esp,%ebp
f010134f:	53                   	push   %ebx
f0101350:	83 ec 14             	sub    $0x14,%esp
f0101353:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pg_entry = pgdir_walk(pgdir, va, 0);
f0101356:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010135d:	00 
f010135e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101361:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101365:	8b 45 08             	mov    0x8(%ebp),%eax
f0101368:	89 04 24             	mov    %eax,(%esp)
f010136b:	e8 ce fe ff ff       	call   f010123e <pgdir_walk>
f0101370:	89 c2                	mov    %eax,%edx
	if(!pg_entry || !(*pg_entry & PTE_P)) return NULL;
f0101372:	85 c0                	test   %eax,%eax
f0101374:	74 3e                	je     f01013b4 <page_lookup+0x68>
f0101376:	8b 00                	mov    (%eax),%eax
f0101378:	a8 01                	test   $0x1,%al
f010137a:	74 3f                	je     f01013bb <page_lookup+0x6f>
	if (PGNUM(pa) >= npages)
f010137c:	c1 e8 0c             	shr    $0xc,%eax
f010137f:	3b 05 88 1e 20 f0    	cmp    0xf0201e88,%eax
f0101385:	72 1c                	jb     f01013a3 <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0101387:	c7 44 24 08 f4 77 10 	movl   $0xf01077f4,0x8(%esp)
f010138e:	f0 
f010138f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101396:	00 
f0101397:	c7 04 24 4b 74 10 f0 	movl   $0xf010744b,(%esp)
f010139e:	e8 9d ec ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01013a3:	8b 0d 90 1e 20 f0    	mov    0xf0201e90,%ecx
f01013a9:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
	if(pte_store)
f01013ac:	85 db                	test   %ebx,%ebx
f01013ae:	74 10                	je     f01013c0 <page_lookup+0x74>
		*pte_store = pg_entry;
f01013b0:	89 13                	mov    %edx,(%ebx)
f01013b2:	eb 0c                	jmp    f01013c0 <page_lookup+0x74>
	if(!pg_entry || !(*pg_entry & PTE_P)) return NULL;
f01013b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01013b9:	eb 05                	jmp    f01013c0 <page_lookup+0x74>
f01013bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013c0:	83 c4 14             	add    $0x14,%esp
f01013c3:	5b                   	pop    %ebx
f01013c4:	5d                   	pop    %ebp
f01013c5:	c3                   	ret    

f01013c6 <tlb_invalidate>:
{
f01013c6:	55                   	push   %ebp
f01013c7:	89 e5                	mov    %esp,%ebp
f01013c9:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01013cc:	e8 a2 53 00 00       	call   f0106773 <cpunum>
f01013d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01013d4:	83 b8 28 20 20 f0 00 	cmpl   $0x0,-0xfdfdfd8(%eax)
f01013db:	74 16                	je     f01013f3 <tlb_invalidate+0x2d>
f01013dd:	e8 91 53 00 00       	call   f0106773 <cpunum>
f01013e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01013e5:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f01013eb:	8b 55 08             	mov    0x8(%ebp),%edx
f01013ee:	39 50 60             	cmp    %edx,0x60(%eax)
f01013f1:	75 06                	jne    f01013f9 <tlb_invalidate+0x33>
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01013f3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013f6:	0f 01 38             	invlpg (%eax)
}
f01013f9:	c9                   	leave  
f01013fa:	c3                   	ret    

f01013fb <page_remove>:
{
f01013fb:	55                   	push   %ebp
f01013fc:	89 e5                	mov    %esp,%ebp
f01013fe:	56                   	push   %esi
f01013ff:	53                   	push   %ebx
f0101400:	83 ec 20             	sub    $0x20,%esp
f0101403:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101406:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pg_entry = NULL;
f0101409:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo* pg_entry_info = page_lookup(pgdir, va, &pg_entry);
f0101410:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101413:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101417:	89 74 24 04          	mov    %esi,0x4(%esp)
f010141b:	89 1c 24             	mov    %ebx,(%esp)
f010141e:	e8 29 ff ff ff       	call   f010134c <page_lookup>
	if(!pg_entry_info) return;
f0101423:	85 c0                	test   %eax,%eax
f0101425:	74 1d                	je     f0101444 <page_remove+0x49>
	page_decref(pg_entry_info);
f0101427:	89 04 24             	mov    %eax,(%esp)
f010142a:	e8 ec fd ff ff       	call   f010121b <page_decref>
	*pg_entry = 0;
f010142f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101432:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f0101438:	89 74 24 04          	mov    %esi,0x4(%esp)
f010143c:	89 1c 24             	mov    %ebx,(%esp)
f010143f:	e8 82 ff ff ff       	call   f01013c6 <tlb_invalidate>
}
f0101444:	83 c4 20             	add    $0x20,%esp
f0101447:	5b                   	pop    %ebx
f0101448:	5e                   	pop    %esi
f0101449:	5d                   	pop    %ebp
f010144a:	c3                   	ret    

f010144b <page_insert>:
{
f010144b:	55                   	push   %ebp
f010144c:	89 e5                	mov    %esp,%ebp
f010144e:	57                   	push   %edi
f010144f:	56                   	push   %esi
f0101450:	53                   	push   %ebx
f0101451:	83 ec 1c             	sub    $0x1c,%esp
f0101454:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101457:	8b 7d 0c             	mov    0xc(%ebp),%edi
	pte_t* pg_entry = pgdir_walk(pgdir, va, 1);
f010145a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101461:	00 
f0101462:	8b 45 10             	mov    0x10(%ebp),%eax
f0101465:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101469:	89 1c 24             	mov    %ebx,(%esp)
f010146c:	e8 cd fd ff ff       	call   f010123e <pgdir_walk>
f0101471:	89 c6                	mov    %eax,%esi
	if(!pg_entry) return -E_NO_MEM;
f0101473:	85 c0                	test   %eax,%eax
f0101475:	74 48                	je     f01014bf <page_insert+0x74>
	return (pp - pages) << PGSHIFT;
f0101477:	89 f8                	mov    %edi,%eax
f0101479:	2b 05 90 1e 20 f0    	sub    0xf0201e90,%eax
f010147f:	c1 f8 03             	sar    $0x3,%eax
f0101482:	c1 e0 0c             	shl    $0xc,%eax
f0101485:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pp->pp_ref += 1;
f0101488:	66 83 47 04 01       	addw   $0x1,0x4(%edi)
	if(*pg_entry & PTE_P)
f010148d:	f6 06 01             	testb  $0x1,(%esi)
f0101490:	74 0f                	je     f01014a1 <page_insert+0x56>
		page_remove(pgdir, va);
f0101492:	8b 45 10             	mov    0x10(%ebp),%eax
f0101495:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101499:	89 1c 24             	mov    %ebx,(%esp)
f010149c:	e8 5a ff ff ff       	call   f01013fb <page_remove>
	*pg_entry = pg_paddr | perm | PTE_P;
f01014a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01014a4:	83 c8 01             	or     $0x1,%eax
f01014a7:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01014aa:	89 06                	mov    %eax,(%esi)
	pgdir[PDX(va)] |= perm;
f01014ac:	8b 45 10             	mov    0x10(%ebp),%eax
f01014af:	c1 e8 16             	shr    $0x16,%eax
f01014b2:	8b 55 14             	mov    0x14(%ebp),%edx
f01014b5:	09 14 83             	or     %edx,(%ebx,%eax,4)
	return 0;
f01014b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01014bd:	eb 05                	jmp    f01014c4 <page_insert+0x79>
	if(!pg_entry) return -E_NO_MEM;
f01014bf:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f01014c4:	83 c4 1c             	add    $0x1c,%esp
f01014c7:	5b                   	pop    %ebx
f01014c8:	5e                   	pop    %esi
f01014c9:	5f                   	pop    %edi
f01014ca:	5d                   	pop    %ebp
f01014cb:	c3                   	ret    

f01014cc <mmio_map_region>:
{
f01014cc:	55                   	push   %ebp
f01014cd:	89 e5                	mov    %esp,%ebp
f01014cf:	53                   	push   %ebx
f01014d0:	83 ec 14             	sub    $0x14,%esp
	size_t align_size = ROUNDUP(size, PGSIZE);
f01014d3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014d6:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01014dc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(base + align_size > MMIOLIM)
f01014e2:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f01014e8:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01014eb:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01014f0:	76 1c                	jbe    f010150e <mmio_map_region+0x42>
		panic("mmio_map_region: overflow MMIOLIM");
f01014f2:	c7 44 24 08 14 78 10 	movl   $0xf0107814,0x8(%esp)
f01014f9:	f0 
f01014fa:	c7 44 24 04 62 02 00 	movl   $0x262,0x4(%esp)
f0101501:	00 
f0101502:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101509:	e8 32 eb ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, align_size, pa, PTE_W|PTE_PCD|PTE_PWT);
f010150e:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101515:	00 
f0101516:	8b 45 08             	mov    0x8(%ebp),%eax
f0101519:	89 04 24             	mov    %eax,(%esp)
f010151c:	89 d9                	mov    %ebx,%ecx
f010151e:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0101523:	e8 b7 fd ff ff       	call   f01012df <boot_map_region>
	uintptr_t result = base;
f0101528:	a1 00 13 12 f0       	mov    0xf0121300,%eax
	base += align_size;
f010152d:	01 c3                	add    %eax,%ebx
f010152f:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
}
f0101535:	83 c4 14             	add    $0x14,%esp
f0101538:	5b                   	pop    %ebx
f0101539:	5d                   	pop    %ebp
f010153a:	c3                   	ret    

f010153b <mem_init>:
{
f010153b:	55                   	push   %ebp
f010153c:	89 e5                	mov    %esp,%ebp
f010153e:	57                   	push   %edi
f010153f:	56                   	push   %esi
f0101540:	53                   	push   %ebx
f0101541:	83 ec 4c             	sub    $0x4c,%esp
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101544:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f010154b:	e8 e4 28 00 00       	call   f0103e34 <mc146818_read>
f0101550:	89 c3                	mov    %eax,%ebx
f0101552:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101559:	e8 d6 28 00 00       	call   f0103e34 <mc146818_read>
f010155e:	c1 e0 08             	shl    $0x8,%eax
f0101561:	09 c3                	or     %eax,%ebx
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101563:	89 d8                	mov    %ebx,%eax
f0101565:	c1 e0 0a             	shl    $0xa,%eax
f0101568:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010156e:	85 c0                	test   %eax,%eax
f0101570:	0f 48 c2             	cmovs  %edx,%eax
f0101573:	c1 f8 0c             	sar    $0xc,%eax
f0101576:	a3 44 12 20 f0       	mov    %eax,0xf0201244
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010157b:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101582:	e8 ad 28 00 00       	call   f0103e34 <mc146818_read>
f0101587:	89 c3                	mov    %eax,%ebx
f0101589:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101590:	e8 9f 28 00 00       	call   f0103e34 <mc146818_read>
f0101595:	c1 e0 08             	shl    $0x8,%eax
f0101598:	09 c3                	or     %eax,%ebx
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010159a:	89 d8                	mov    %ebx,%eax
f010159c:	c1 e0 0a             	shl    $0xa,%eax
f010159f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01015a5:	85 c0                	test   %eax,%eax
f01015a7:	0f 48 c2             	cmovs  %edx,%eax
f01015aa:	c1 f8 0c             	sar    $0xc,%eax
	if (npages_extmem)
f01015ad:	85 c0                	test   %eax,%eax
f01015af:	74 0e                	je     f01015bf <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01015b1:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01015b7:	89 15 88 1e 20 f0    	mov    %edx,0xf0201e88
f01015bd:	eb 0c                	jmp    f01015cb <mem_init+0x90>
		npages = npages_basemem;
f01015bf:	8b 15 44 12 20 f0    	mov    0xf0201244,%edx
f01015c5:	89 15 88 1e 20 f0    	mov    %edx,0xf0201e88
		npages_extmem * PGSIZE / 1024);
f01015cb:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015ce:	c1 e8 0a             	shr    $0xa,%eax
f01015d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages_basemem * PGSIZE / 1024,
f01015d5:	a1 44 12 20 f0       	mov    0xf0201244,%eax
f01015da:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015dd:	c1 e8 0a             	shr    $0xa,%eax
f01015e0:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01015e4:	a1 88 1e 20 f0       	mov    0xf0201e88,%eax
f01015e9:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015ec:	c1 e8 0a             	shr    $0xa,%eax
f01015ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015f3:	c7 04 24 38 78 10 f0 	movl   $0xf0107838,(%esp)
f01015fa:	e8 9e 29 00 00       	call   f0103f9d <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01015ff:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101604:	e8 57 f5 ff ff       	call   f0100b60 <boot_alloc>
f0101609:	a3 8c 1e 20 f0       	mov    %eax,0xf0201e8c
	memset(kern_pgdir, 0, PGSIZE);
f010160e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101615:	00 
f0101616:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010161d:	00 
f010161e:	89 04 24             	mov    %eax,(%esp)
f0101621:	e8 b3 4a 00 00       	call   f01060d9 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101626:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010162b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101630:	77 20                	ja     f0101652 <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101632:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101636:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f010163d:	f0 
f010163e:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0101645:	00 
f0101646:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010164d:	e8 ee e9 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101652:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101658:	83 ca 05             	or     $0x5,%edx
f010165b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo) * npages);
f0101661:	a1 88 1e 20 f0       	mov    0xf0201e88,%eax
f0101666:	c1 e0 03             	shl    $0x3,%eax
f0101669:	e8 f2 f4 ff ff       	call   f0100b60 <boot_alloc>
f010166e:	a3 90 1e 20 f0       	mov    %eax,0xf0201e90
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f0101673:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101678:	e8 e3 f4 ff ff       	call   f0100b60 <boot_alloc>
f010167d:	a3 48 12 20 f0       	mov    %eax,0xf0201248
	page_init();
f0101682:	e8 d6 f9 ff ff       	call   f010105d <page_init>
	check_page_free_list(1);
f0101687:	b8 01 00 00 00       	mov    $0x1,%eax
f010168c:	e8 f5 f5 ff ff       	call   f0100c86 <check_page_free_list>
	if (!pages)
f0101691:	83 3d 90 1e 20 f0 00 	cmpl   $0x0,0xf0201e90
f0101698:	75 1c                	jne    f01016b6 <mem_init+0x17b>
		panic("'pages' is a null pointer!");
f010169a:	c7 44 24 08 12 75 10 	movl   $0xf0107512,0x8(%esp)
f01016a1:	f0 
f01016a2:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f01016a9:	00 
f01016aa:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01016b1:	e8 8a e9 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016b6:	a1 40 12 20 f0       	mov    0xf0201240,%eax
f01016bb:	85 c0                	test   %eax,%eax
f01016bd:	74 10                	je     f01016cf <mem_init+0x194>
f01016bf:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f01016c4:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016c7:	8b 00                	mov    (%eax),%eax
f01016c9:	85 c0                	test   %eax,%eax
f01016cb:	75 f7                	jne    f01016c4 <mem_init+0x189>
f01016cd:	eb 05                	jmp    f01016d4 <mem_init+0x199>
f01016cf:	bb 00 00 00 00       	mov    $0x0,%ebx
	assert((pp0 = page_alloc(0)));
f01016d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016db:	e8 90 fa ff ff       	call   f0101170 <page_alloc>
f01016e0:	89 c7                	mov    %eax,%edi
f01016e2:	85 c0                	test   %eax,%eax
f01016e4:	75 24                	jne    f010170a <mem_init+0x1cf>
f01016e6:	c7 44 24 0c 2d 75 10 	movl   $0xf010752d,0xc(%esp)
f01016ed:	f0 
f01016ee:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01016f5:	f0 
f01016f6:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f01016fd:	00 
f01016fe:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101705:	e8 36 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010170a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101711:	e8 5a fa ff ff       	call   f0101170 <page_alloc>
f0101716:	89 c6                	mov    %eax,%esi
f0101718:	85 c0                	test   %eax,%eax
f010171a:	75 24                	jne    f0101740 <mem_init+0x205>
f010171c:	c7 44 24 0c 43 75 10 	movl   $0xf0107543,0xc(%esp)
f0101723:	f0 
f0101724:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010172b:	f0 
f010172c:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0101733:	00 
f0101734:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010173b:	e8 00 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101740:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101747:	e8 24 fa ff ff       	call   f0101170 <page_alloc>
f010174c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010174f:	85 c0                	test   %eax,%eax
f0101751:	75 24                	jne    f0101777 <mem_init+0x23c>
f0101753:	c7 44 24 0c 59 75 10 	movl   $0xf0107559,0xc(%esp)
f010175a:	f0 
f010175b:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101762:	f0 
f0101763:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f010176a:	00 
f010176b:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101772:	e8 c9 e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101777:	39 f7                	cmp    %esi,%edi
f0101779:	75 24                	jne    f010179f <mem_init+0x264>
f010177b:	c7 44 24 0c 6f 75 10 	movl   $0xf010756f,0xc(%esp)
f0101782:	f0 
f0101783:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010178a:	f0 
f010178b:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f0101792:	00 
f0101793:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010179a:	e8 a1 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010179f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017a2:	39 c6                	cmp    %eax,%esi
f01017a4:	74 04                	je     f01017aa <mem_init+0x26f>
f01017a6:	39 c7                	cmp    %eax,%edi
f01017a8:	75 24                	jne    f01017ce <mem_init+0x293>
f01017aa:	c7 44 24 0c 74 78 10 	movl   $0xf0107874,0xc(%esp)
f01017b1:	f0 
f01017b2:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01017b9:	f0 
f01017ba:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f01017c1:	00 
f01017c2:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01017c9:	e8 72 e8 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f01017ce:	8b 15 90 1e 20 f0    	mov    0xf0201e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01017d4:	a1 88 1e 20 f0       	mov    0xf0201e88,%eax
f01017d9:	c1 e0 0c             	shl    $0xc,%eax
f01017dc:	89 f9                	mov    %edi,%ecx
f01017de:	29 d1                	sub    %edx,%ecx
f01017e0:	c1 f9 03             	sar    $0x3,%ecx
f01017e3:	c1 e1 0c             	shl    $0xc,%ecx
f01017e6:	39 c1                	cmp    %eax,%ecx
f01017e8:	72 24                	jb     f010180e <mem_init+0x2d3>
f01017ea:	c7 44 24 0c 81 75 10 	movl   $0xf0107581,0xc(%esp)
f01017f1:	f0 
f01017f2:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01017f9:	f0 
f01017fa:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f0101801:	00 
f0101802:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101809:	e8 32 e8 ff ff       	call   f0100040 <_panic>
f010180e:	89 f1                	mov    %esi,%ecx
f0101810:	29 d1                	sub    %edx,%ecx
f0101812:	c1 f9 03             	sar    $0x3,%ecx
f0101815:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101818:	39 c8                	cmp    %ecx,%eax
f010181a:	77 24                	ja     f0101840 <mem_init+0x305>
f010181c:	c7 44 24 0c 9e 75 10 	movl   $0xf010759e,0xc(%esp)
f0101823:	f0 
f0101824:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010182b:	f0 
f010182c:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f0101833:	00 
f0101834:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010183b:	e8 00 e8 ff ff       	call   f0100040 <_panic>
f0101840:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101843:	29 d1                	sub    %edx,%ecx
f0101845:	89 ca                	mov    %ecx,%edx
f0101847:	c1 fa 03             	sar    $0x3,%edx
f010184a:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010184d:	39 d0                	cmp    %edx,%eax
f010184f:	77 24                	ja     f0101875 <mem_init+0x33a>
f0101851:	c7 44 24 0c bb 75 10 	movl   $0xf01075bb,0xc(%esp)
f0101858:	f0 
f0101859:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101860:	f0 
f0101861:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f0101868:	00 
f0101869:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101870:	e8 cb e7 ff ff       	call   f0100040 <_panic>
	fl = page_free_list;
f0101875:	a1 40 12 20 f0       	mov    0xf0201240,%eax
f010187a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010187d:	c7 05 40 12 20 f0 00 	movl   $0x0,0xf0201240
f0101884:	00 00 00 
	assert(!page_alloc(0));
f0101887:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010188e:	e8 dd f8 ff ff       	call   f0101170 <page_alloc>
f0101893:	85 c0                	test   %eax,%eax
f0101895:	74 24                	je     f01018bb <mem_init+0x380>
f0101897:	c7 44 24 0c d8 75 10 	movl   $0xf01075d8,0xc(%esp)
f010189e:	f0 
f010189f:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01018a6:	f0 
f01018a7:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f01018ae:	00 
f01018af:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01018b6:	e8 85 e7 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f01018bb:	89 3c 24             	mov    %edi,(%esp)
f01018be:	e8 38 f9 ff ff       	call   f01011fb <page_free>
	page_free(pp1);
f01018c3:	89 34 24             	mov    %esi,(%esp)
f01018c6:	e8 30 f9 ff ff       	call   f01011fb <page_free>
	page_free(pp2);
f01018cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018ce:	89 04 24             	mov    %eax,(%esp)
f01018d1:	e8 25 f9 ff ff       	call   f01011fb <page_free>
	assert((pp0 = page_alloc(0)));
f01018d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018dd:	e8 8e f8 ff ff       	call   f0101170 <page_alloc>
f01018e2:	89 c6                	mov    %eax,%esi
f01018e4:	85 c0                	test   %eax,%eax
f01018e6:	75 24                	jne    f010190c <mem_init+0x3d1>
f01018e8:	c7 44 24 0c 2d 75 10 	movl   $0xf010752d,0xc(%esp)
f01018ef:	f0 
f01018f0:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01018f7:	f0 
f01018f8:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f01018ff:	00 
f0101900:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101907:	e8 34 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010190c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101913:	e8 58 f8 ff ff       	call   f0101170 <page_alloc>
f0101918:	89 c7                	mov    %eax,%edi
f010191a:	85 c0                	test   %eax,%eax
f010191c:	75 24                	jne    f0101942 <mem_init+0x407>
f010191e:	c7 44 24 0c 43 75 10 	movl   $0xf0107543,0xc(%esp)
f0101925:	f0 
f0101926:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010192d:	f0 
f010192e:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f0101935:	00 
f0101936:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010193d:	e8 fe e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101942:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101949:	e8 22 f8 ff ff       	call   f0101170 <page_alloc>
f010194e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101951:	85 c0                	test   %eax,%eax
f0101953:	75 24                	jne    f0101979 <mem_init+0x43e>
f0101955:	c7 44 24 0c 59 75 10 	movl   $0xf0107559,0xc(%esp)
f010195c:	f0 
f010195d:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101964:	f0 
f0101965:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f010196c:	00 
f010196d:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101974:	e8 c7 e6 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101979:	39 fe                	cmp    %edi,%esi
f010197b:	75 24                	jne    f01019a1 <mem_init+0x466>
f010197d:	c7 44 24 0c 6f 75 10 	movl   $0xf010756f,0xc(%esp)
f0101984:	f0 
f0101985:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010198c:	f0 
f010198d:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f0101994:	00 
f0101995:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010199c:	e8 9f e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019a4:	39 c7                	cmp    %eax,%edi
f01019a6:	74 04                	je     f01019ac <mem_init+0x471>
f01019a8:	39 c6                	cmp    %eax,%esi
f01019aa:	75 24                	jne    f01019d0 <mem_init+0x495>
f01019ac:	c7 44 24 0c 74 78 10 	movl   $0xf0107874,0xc(%esp)
f01019b3:	f0 
f01019b4:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01019bb:	f0 
f01019bc:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f01019c3:	00 
f01019c4:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01019cb:	e8 70 e6 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01019d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019d7:	e8 94 f7 ff ff       	call   f0101170 <page_alloc>
f01019dc:	85 c0                	test   %eax,%eax
f01019de:	74 24                	je     f0101a04 <mem_init+0x4c9>
f01019e0:	c7 44 24 0c d8 75 10 	movl   $0xf01075d8,0xc(%esp)
f01019e7:	f0 
f01019e8:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01019ef:	f0 
f01019f0:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f01019f7:	00 
f01019f8:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01019ff:	e8 3c e6 ff ff       	call   f0100040 <_panic>
f0101a04:	89 f0                	mov    %esi,%eax
f0101a06:	2b 05 90 1e 20 f0    	sub    0xf0201e90,%eax
f0101a0c:	c1 f8 03             	sar    $0x3,%eax
f0101a0f:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101a12:	89 c2                	mov    %eax,%edx
f0101a14:	c1 ea 0c             	shr    $0xc,%edx
f0101a17:	3b 15 88 1e 20 f0    	cmp    0xf0201e88,%edx
f0101a1d:	72 20                	jb     f0101a3f <mem_init+0x504>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101a23:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f0101a2a:	f0 
f0101a2b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101a32:	00 
f0101a33:	c7 04 24 4b 74 10 f0 	movl   $0xf010744b,(%esp)
f0101a3a:	e8 01 e6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp0), 1, PGSIZE);
f0101a3f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a46:	00 
f0101a47:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101a4e:	00 
	return (void *)(pa + KERNBASE);
f0101a4f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a54:	89 04 24             	mov    %eax,(%esp)
f0101a57:	e8 7d 46 00 00       	call   f01060d9 <memset>
	page_free(pp0);
f0101a5c:	89 34 24             	mov    %esi,(%esp)
f0101a5f:	e8 97 f7 ff ff       	call   f01011fb <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a64:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a6b:	e8 00 f7 ff ff       	call   f0101170 <page_alloc>
f0101a70:	85 c0                	test   %eax,%eax
f0101a72:	75 24                	jne    f0101a98 <mem_init+0x55d>
f0101a74:	c7 44 24 0c e7 75 10 	movl   $0xf01075e7,0xc(%esp)
f0101a7b:	f0 
f0101a7c:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101a83:	f0 
f0101a84:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f0101a8b:	00 
f0101a8c:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101a93:	e8 a8 e5 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101a98:	39 c6                	cmp    %eax,%esi
f0101a9a:	74 24                	je     f0101ac0 <mem_init+0x585>
f0101a9c:	c7 44 24 0c 05 76 10 	movl   $0xf0107605,0xc(%esp)
f0101aa3:	f0 
f0101aa4:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101aab:	f0 
f0101aac:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f0101ab3:	00 
f0101ab4:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101abb:	e8 80 e5 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0101ac0:	89 f2                	mov    %esi,%edx
f0101ac2:	2b 15 90 1e 20 f0    	sub    0xf0201e90,%edx
f0101ac8:	c1 fa 03             	sar    $0x3,%edx
f0101acb:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101ace:	89 d0                	mov    %edx,%eax
f0101ad0:	c1 e8 0c             	shr    $0xc,%eax
f0101ad3:	3b 05 88 1e 20 f0    	cmp    0xf0201e88,%eax
f0101ad9:	72 20                	jb     f0101afb <mem_init+0x5c0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101adb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101adf:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f0101ae6:	f0 
f0101ae7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101aee:	00 
f0101aef:	c7 04 24 4b 74 10 f0 	movl   $0xf010744b,(%esp)
f0101af6:	e8 45 e5 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f0101afb:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101b02:	75 11                	jne    f0101b15 <mem_init+0x5da>
f0101b04:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
f0101b0a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f0101b10:	80 38 00             	cmpb   $0x0,(%eax)
f0101b13:	74 24                	je     f0101b39 <mem_init+0x5fe>
f0101b15:	c7 44 24 0c 15 76 10 	movl   $0xf0107615,0xc(%esp)
f0101b1c:	f0 
f0101b1d:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101b24:	f0 
f0101b25:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0101b2c:	00 
f0101b2d:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101b34:	e8 07 e5 ff ff       	call   f0100040 <_panic>
f0101b39:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101b3c:	39 d0                	cmp    %edx,%eax
f0101b3e:	75 d0                	jne    f0101b10 <mem_init+0x5d5>
	page_free_list = fl;
f0101b40:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b43:	a3 40 12 20 f0       	mov    %eax,0xf0201240
	page_free(pp0);
f0101b48:	89 34 24             	mov    %esi,(%esp)
f0101b4b:	e8 ab f6 ff ff       	call   f01011fb <page_free>
	page_free(pp1);
f0101b50:	89 3c 24             	mov    %edi,(%esp)
f0101b53:	e8 a3 f6 ff ff       	call   f01011fb <page_free>
	page_free(pp2);
f0101b58:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b5b:	89 04 24             	mov    %eax,(%esp)
f0101b5e:	e8 98 f6 ff ff       	call   f01011fb <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b63:	a1 40 12 20 f0       	mov    0xf0201240,%eax
f0101b68:	85 c0                	test   %eax,%eax
f0101b6a:	74 09                	je     f0101b75 <mem_init+0x63a>
		--nfree;
f0101b6c:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b6f:	8b 00                	mov    (%eax),%eax
f0101b71:	85 c0                	test   %eax,%eax
f0101b73:	75 f7                	jne    f0101b6c <mem_init+0x631>
	assert(nfree == 0);
f0101b75:	85 db                	test   %ebx,%ebx
f0101b77:	74 24                	je     f0101b9d <mem_init+0x662>
f0101b79:	c7 44 24 0c 1f 76 10 	movl   $0xf010761f,0xc(%esp)
f0101b80:	f0 
f0101b81:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101b88:	f0 
f0101b89:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f0101b90:	00 
f0101b91:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101b98:	e8 a3 e4 ff ff       	call   f0100040 <_panic>
	cprintf("check_page_alloc() succeeded!\n");
f0101b9d:	c7 04 24 94 78 10 f0 	movl   $0xf0107894,(%esp)
f0101ba4:	e8 f4 23 00 00       	call   f0103f9d <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ba9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bb0:	e8 bb f5 ff ff       	call   f0101170 <page_alloc>
f0101bb5:	89 c6                	mov    %eax,%esi
f0101bb7:	85 c0                	test   %eax,%eax
f0101bb9:	75 24                	jne    f0101bdf <mem_init+0x6a4>
f0101bbb:	c7 44 24 0c 2d 75 10 	movl   $0xf010752d,0xc(%esp)
f0101bc2:	f0 
f0101bc3:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101bca:	f0 
f0101bcb:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0101bd2:	00 
f0101bd3:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101bda:	e8 61 e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101bdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101be6:	e8 85 f5 ff ff       	call   f0101170 <page_alloc>
f0101beb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101bee:	85 c0                	test   %eax,%eax
f0101bf0:	75 24                	jne    f0101c16 <mem_init+0x6db>
f0101bf2:	c7 44 24 0c 43 75 10 	movl   $0xf0107543,0xc(%esp)
f0101bf9:	f0 
f0101bfa:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101c01:	f0 
f0101c02:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f0101c09:	00 
f0101c0a:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101c11:	e8 2a e4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c1d:	e8 4e f5 ff ff       	call   f0101170 <page_alloc>
f0101c22:	89 c3                	mov    %eax,%ebx
f0101c24:	85 c0                	test   %eax,%eax
f0101c26:	75 24                	jne    f0101c4c <mem_init+0x711>
f0101c28:	c7 44 24 0c 59 75 10 	movl   $0xf0107559,0xc(%esp)
f0101c2f:	f0 
f0101c30:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101c37:	f0 
f0101c38:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f0101c3f:	00 
f0101c40:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101c47:	e8 f4 e3 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c4c:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101c4f:	75 24                	jne    f0101c75 <mem_init+0x73a>
f0101c51:	c7 44 24 0c 6f 75 10 	movl   $0xf010756f,0xc(%esp)
f0101c58:	f0 
f0101c59:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101c60:	f0 
f0101c61:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0101c68:	00 
f0101c69:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101c70:	e8 cb e3 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c75:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101c78:	74 04                	je     f0101c7e <mem_init+0x743>
f0101c7a:	39 c6                	cmp    %eax,%esi
f0101c7c:	75 24                	jne    f0101ca2 <mem_init+0x767>
f0101c7e:	c7 44 24 0c 74 78 10 	movl   $0xf0107874,0xc(%esp)
f0101c85:	f0 
f0101c86:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101c8d:	f0 
f0101c8e:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0101c95:	00 
f0101c96:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101c9d:	e8 9e e3 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101ca2:	a1 40 12 20 f0       	mov    0xf0201240,%eax
f0101ca7:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101caa:	c7 05 40 12 20 f0 00 	movl   $0x0,0xf0201240
f0101cb1:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101cb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cbb:	e8 b0 f4 ff ff       	call   f0101170 <page_alloc>
f0101cc0:	85 c0                	test   %eax,%eax
f0101cc2:	74 24                	je     f0101ce8 <mem_init+0x7ad>
f0101cc4:	c7 44 24 0c d8 75 10 	movl   $0xf01075d8,0xc(%esp)
f0101ccb:	f0 
f0101ccc:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101cd3:	f0 
f0101cd4:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0101cdb:	00 
f0101cdc:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101ce3:	e8 58 e3 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ce8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ceb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101cef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101cf6:	00 
f0101cf7:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0101cfc:	89 04 24             	mov    %eax,(%esp)
f0101cff:	e8 48 f6 ff ff       	call   f010134c <page_lookup>
f0101d04:	85 c0                	test   %eax,%eax
f0101d06:	74 24                	je     f0101d2c <mem_init+0x7f1>
f0101d08:	c7 44 24 0c b4 78 10 	movl   $0xf01078b4,0xc(%esp)
f0101d0f:	f0 
f0101d10:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101d17:	f0 
f0101d18:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0101d1f:	00 
f0101d20:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101d27:	e8 14 e3 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d2c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d33:	00 
f0101d34:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d3b:	00 
f0101d3c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d43:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0101d48:	89 04 24             	mov    %eax,(%esp)
f0101d4b:	e8 fb f6 ff ff       	call   f010144b <page_insert>
f0101d50:	85 c0                	test   %eax,%eax
f0101d52:	78 24                	js     f0101d78 <mem_init+0x83d>
f0101d54:	c7 44 24 0c ec 78 10 	movl   $0xf01078ec,0xc(%esp)
f0101d5b:	f0 
f0101d5c:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101d63:	f0 
f0101d64:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f0101d6b:	00 
f0101d6c:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101d73:	e8 c8 e2 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d78:	89 34 24             	mov    %esi,(%esp)
f0101d7b:	e8 7b f4 ff ff       	call   f01011fb <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d80:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d87:	00 
f0101d88:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d8f:	00 
f0101d90:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d93:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d97:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0101d9c:	89 04 24             	mov    %eax,(%esp)
f0101d9f:	e8 a7 f6 ff ff       	call   f010144b <page_insert>
f0101da4:	85 c0                	test   %eax,%eax
f0101da6:	74 24                	je     f0101dcc <mem_init+0x891>
f0101da8:	c7 44 24 0c 1c 79 10 	movl   $0xf010791c,0xc(%esp)
f0101daf:	f0 
f0101db0:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101db7:	f0 
f0101db8:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0101dbf:	00 
f0101dc0:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101dc7:	e8 74 e2 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101dcc:	8b 3d 8c 1e 20 f0    	mov    0xf0201e8c,%edi
	return (pp - pages) << PGSHIFT;
f0101dd2:	a1 90 1e 20 f0       	mov    0xf0201e90,%eax
f0101dd7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101dda:	8b 17                	mov    (%edi),%edx
f0101ddc:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101de2:	89 f1                	mov    %esi,%ecx
f0101de4:	29 c1                	sub    %eax,%ecx
f0101de6:	89 c8                	mov    %ecx,%eax
f0101de8:	c1 f8 03             	sar    $0x3,%eax
f0101deb:	c1 e0 0c             	shl    $0xc,%eax
f0101dee:	39 c2                	cmp    %eax,%edx
f0101df0:	74 24                	je     f0101e16 <mem_init+0x8db>
f0101df2:	c7 44 24 0c 4c 79 10 	movl   $0xf010794c,0xc(%esp)
f0101df9:	f0 
f0101dfa:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101e01:	f0 
f0101e02:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0101e09:	00 
f0101e0a:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101e11:	e8 2a e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101e16:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e1b:	89 f8                	mov    %edi,%eax
f0101e1d:	e8 f5 ed ff ff       	call   f0100c17 <check_va2pa>
f0101e22:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101e25:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101e28:	c1 fa 03             	sar    $0x3,%edx
f0101e2b:	c1 e2 0c             	shl    $0xc,%edx
f0101e2e:	39 d0                	cmp    %edx,%eax
f0101e30:	74 24                	je     f0101e56 <mem_init+0x91b>
f0101e32:	c7 44 24 0c 74 79 10 	movl   $0xf0107974,0xc(%esp)
f0101e39:	f0 
f0101e3a:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101e41:	f0 
f0101e42:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f0101e49:	00 
f0101e4a:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101e51:	e8 ea e1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101e56:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e59:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e5e:	74 24                	je     f0101e84 <mem_init+0x949>
f0101e60:	c7 44 24 0c 2a 76 10 	movl   $0xf010762a,0xc(%esp)
f0101e67:	f0 
f0101e68:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101e6f:	f0 
f0101e70:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f0101e77:	00 
f0101e78:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101e7f:	e8 bc e1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101e84:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e89:	74 24                	je     f0101eaf <mem_init+0x974>
f0101e8b:	c7 44 24 0c 3b 76 10 	movl   $0xf010763b,0xc(%esp)
f0101e92:	f0 
f0101e93:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101e9a:	f0 
f0101e9b:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0101ea2:	00 
f0101ea3:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101eaa:	e8 91 e1 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101eaf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101eb6:	00 
f0101eb7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ebe:	00 
f0101ebf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ec3:	89 3c 24             	mov    %edi,(%esp)
f0101ec6:	e8 80 f5 ff ff       	call   f010144b <page_insert>
f0101ecb:	85 c0                	test   %eax,%eax
f0101ecd:	74 24                	je     f0101ef3 <mem_init+0x9b8>
f0101ecf:	c7 44 24 0c a4 79 10 	movl   $0xf01079a4,0xc(%esp)
f0101ed6:	f0 
f0101ed7:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101ede:	f0 
f0101edf:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0101ee6:	00 
f0101ee7:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101eee:	e8 4d e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ef3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ef8:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0101efd:	e8 15 ed ff ff       	call   f0100c17 <check_va2pa>
f0101f02:	89 da                	mov    %ebx,%edx
f0101f04:	2b 15 90 1e 20 f0    	sub    0xf0201e90,%edx
f0101f0a:	c1 fa 03             	sar    $0x3,%edx
f0101f0d:	c1 e2 0c             	shl    $0xc,%edx
f0101f10:	39 d0                	cmp    %edx,%eax
f0101f12:	74 24                	je     f0101f38 <mem_init+0x9fd>
f0101f14:	c7 44 24 0c e0 79 10 	movl   $0xf01079e0,0xc(%esp)
f0101f1b:	f0 
f0101f1c:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101f23:	f0 
f0101f24:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101f2b:	00 
f0101f2c:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101f33:	e8 08 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f38:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f3d:	74 24                	je     f0101f63 <mem_init+0xa28>
f0101f3f:	c7 44 24 0c 4c 76 10 	movl   $0xf010764c,0xc(%esp)
f0101f46:	f0 
f0101f47:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101f4e:	f0 
f0101f4f:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0101f56:	00 
f0101f57:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101f5e:	e8 dd e0 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f6a:	e8 01 f2 ff ff       	call   f0101170 <page_alloc>
f0101f6f:	85 c0                	test   %eax,%eax
f0101f71:	74 24                	je     f0101f97 <mem_init+0xa5c>
f0101f73:	c7 44 24 0c d8 75 10 	movl   $0xf01075d8,0xc(%esp)
f0101f7a:	f0 
f0101f7b:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101f82:	f0 
f0101f83:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0101f8a:	00 
f0101f8b:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101f92:	e8 a9 e0 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f97:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f9e:	00 
f0101f9f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101fa6:	00 
f0101fa7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101fab:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0101fb0:	89 04 24             	mov    %eax,(%esp)
f0101fb3:	e8 93 f4 ff ff       	call   f010144b <page_insert>
f0101fb8:	85 c0                	test   %eax,%eax
f0101fba:	74 24                	je     f0101fe0 <mem_init+0xaa5>
f0101fbc:	c7 44 24 0c a4 79 10 	movl   $0xf01079a4,0xc(%esp)
f0101fc3:	f0 
f0101fc4:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0101fcb:	f0 
f0101fcc:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0101fd3:	00 
f0101fd4:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0101fdb:	e8 60 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fe0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fe5:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0101fea:	e8 28 ec ff ff       	call   f0100c17 <check_va2pa>
f0101fef:	89 da                	mov    %ebx,%edx
f0101ff1:	2b 15 90 1e 20 f0    	sub    0xf0201e90,%edx
f0101ff7:	c1 fa 03             	sar    $0x3,%edx
f0101ffa:	c1 e2 0c             	shl    $0xc,%edx
f0101ffd:	39 d0                	cmp    %edx,%eax
f0101fff:	74 24                	je     f0102025 <mem_init+0xaea>
f0102001:	c7 44 24 0c e0 79 10 	movl   $0xf01079e0,0xc(%esp)
f0102008:	f0 
f0102009:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102010:	f0 
f0102011:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0102018:	00 
f0102019:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102020:	e8 1b e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102025:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010202a:	74 24                	je     f0102050 <mem_init+0xb15>
f010202c:	c7 44 24 0c 4c 76 10 	movl   $0xf010764c,0xc(%esp)
f0102033:	f0 
f0102034:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010203b:	f0 
f010203c:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0102043:	00 
f0102044:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010204b:	e8 f0 df ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102050:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102057:	e8 14 f1 ff ff       	call   f0101170 <page_alloc>
f010205c:	85 c0                	test   %eax,%eax
f010205e:	74 24                	je     f0102084 <mem_init+0xb49>
f0102060:	c7 44 24 0c d8 75 10 	movl   $0xf01075d8,0xc(%esp)
f0102067:	f0 
f0102068:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010206f:	f0 
f0102070:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0102077:	00 
f0102078:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010207f:	e8 bc df ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102084:	8b 15 8c 1e 20 f0    	mov    0xf0201e8c,%edx
f010208a:	8b 02                	mov    (%edx),%eax
f010208c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0102091:	89 c1                	mov    %eax,%ecx
f0102093:	c1 e9 0c             	shr    $0xc,%ecx
f0102096:	3b 0d 88 1e 20 f0    	cmp    0xf0201e88,%ecx
f010209c:	72 20                	jb     f01020be <mem_init+0xb83>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010209e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01020a2:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f01020a9:	f0 
f01020aa:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f01020b1:	00 
f01020b2:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01020b9:	e8 82 df ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01020be:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01020c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020cd:	00 
f01020ce:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020d5:	00 
f01020d6:	89 14 24             	mov    %edx,(%esp)
f01020d9:	e8 60 f1 ff ff       	call   f010123e <pgdir_walk>
f01020de:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01020e1:	8d 51 04             	lea    0x4(%ecx),%edx
f01020e4:	39 d0                	cmp    %edx,%eax
f01020e6:	74 24                	je     f010210c <mem_init+0xbd1>
f01020e8:	c7 44 24 0c 10 7a 10 	movl   $0xf0107a10,0xc(%esp)
f01020ef:	f0 
f01020f0:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01020f7:	f0 
f01020f8:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f01020ff:	00 
f0102100:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102107:	e8 34 df ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010210c:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102113:	00 
f0102114:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010211b:	00 
f010211c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102120:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0102125:	89 04 24             	mov    %eax,(%esp)
f0102128:	e8 1e f3 ff ff       	call   f010144b <page_insert>
f010212d:	85 c0                	test   %eax,%eax
f010212f:	74 24                	je     f0102155 <mem_init+0xc1a>
f0102131:	c7 44 24 0c 50 7a 10 	movl   $0xf0107a50,0xc(%esp)
f0102138:	f0 
f0102139:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102140:	f0 
f0102141:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0102148:	00 
f0102149:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102150:	e8 eb de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102155:	8b 3d 8c 1e 20 f0    	mov    0xf0201e8c,%edi
f010215b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102160:	89 f8                	mov    %edi,%eax
f0102162:	e8 b0 ea ff ff       	call   f0100c17 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0102167:	89 da                	mov    %ebx,%edx
f0102169:	2b 15 90 1e 20 f0    	sub    0xf0201e90,%edx
f010216f:	c1 fa 03             	sar    $0x3,%edx
f0102172:	c1 e2 0c             	shl    $0xc,%edx
f0102175:	39 d0                	cmp    %edx,%eax
f0102177:	74 24                	je     f010219d <mem_init+0xc62>
f0102179:	c7 44 24 0c e0 79 10 	movl   $0xf01079e0,0xc(%esp)
f0102180:	f0 
f0102181:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102188:	f0 
f0102189:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0102190:	00 
f0102191:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102198:	e8 a3 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010219d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01021a2:	74 24                	je     f01021c8 <mem_init+0xc8d>
f01021a4:	c7 44 24 0c 4c 76 10 	movl   $0xf010764c,0xc(%esp)
f01021ab:	f0 
f01021ac:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01021b3:	f0 
f01021b4:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f01021bb:	00 
f01021bc:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01021c3:	e8 78 de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01021c8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021cf:	00 
f01021d0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021d7:	00 
f01021d8:	89 3c 24             	mov    %edi,(%esp)
f01021db:	e8 5e f0 ff ff       	call   f010123e <pgdir_walk>
f01021e0:	f6 00 04             	testb  $0x4,(%eax)
f01021e3:	75 24                	jne    f0102209 <mem_init+0xcce>
f01021e5:	c7 44 24 0c 90 7a 10 	movl   $0xf0107a90,0xc(%esp)
f01021ec:	f0 
f01021ed:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01021f4:	f0 
f01021f5:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f01021fc:	00 
f01021fd:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102204:	e8 37 de ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102209:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f010220e:	f6 00 04             	testb  $0x4,(%eax)
f0102211:	75 24                	jne    f0102237 <mem_init+0xcfc>
f0102213:	c7 44 24 0c 5d 76 10 	movl   $0xf010765d,0xc(%esp)
f010221a:	f0 
f010221b:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102222:	f0 
f0102223:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f010222a:	00 
f010222b:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102232:	e8 09 de ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102237:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010223e:	00 
f010223f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102246:	00 
f0102247:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010224b:	89 04 24             	mov    %eax,(%esp)
f010224e:	e8 f8 f1 ff ff       	call   f010144b <page_insert>
f0102253:	85 c0                	test   %eax,%eax
f0102255:	74 24                	je     f010227b <mem_init+0xd40>
f0102257:	c7 44 24 0c a4 79 10 	movl   $0xf01079a4,0xc(%esp)
f010225e:	f0 
f010225f:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102266:	f0 
f0102267:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f010226e:	00 
f010226f:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102276:	e8 c5 dd ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010227b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102282:	00 
f0102283:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010228a:	00 
f010228b:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0102290:	89 04 24             	mov    %eax,(%esp)
f0102293:	e8 a6 ef ff ff       	call   f010123e <pgdir_walk>
f0102298:	f6 00 02             	testb  $0x2,(%eax)
f010229b:	75 24                	jne    f01022c1 <mem_init+0xd86>
f010229d:	c7 44 24 0c c4 7a 10 	movl   $0xf0107ac4,0xc(%esp)
f01022a4:	f0 
f01022a5:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01022ac:	f0 
f01022ad:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f01022b4:	00 
f01022b5:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01022bc:	e8 7f dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01022c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01022c8:	00 
f01022c9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01022d0:	00 
f01022d1:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f01022d6:	89 04 24             	mov    %eax,(%esp)
f01022d9:	e8 60 ef ff ff       	call   f010123e <pgdir_walk>
f01022de:	f6 00 04             	testb  $0x4,(%eax)
f01022e1:	74 24                	je     f0102307 <mem_init+0xdcc>
f01022e3:	c7 44 24 0c f8 7a 10 	movl   $0xf0107af8,0xc(%esp)
f01022ea:	f0 
f01022eb:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01022f2:	f0 
f01022f3:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f01022fa:	00 
f01022fb:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102302:	e8 39 dd ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102307:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010230e:	00 
f010230f:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102316:	00 
f0102317:	89 74 24 04          	mov    %esi,0x4(%esp)
f010231b:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0102320:	89 04 24             	mov    %eax,(%esp)
f0102323:	e8 23 f1 ff ff       	call   f010144b <page_insert>
f0102328:	85 c0                	test   %eax,%eax
f010232a:	78 24                	js     f0102350 <mem_init+0xe15>
f010232c:	c7 44 24 0c 30 7b 10 	movl   $0xf0107b30,0xc(%esp)
f0102333:	f0 
f0102334:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010233b:	f0 
f010233c:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0102343:	00 
f0102344:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010234b:	e8 f0 dc ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102350:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102357:	00 
f0102358:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010235f:	00 
f0102360:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102363:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102367:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f010236c:	89 04 24             	mov    %eax,(%esp)
f010236f:	e8 d7 f0 ff ff       	call   f010144b <page_insert>
f0102374:	85 c0                	test   %eax,%eax
f0102376:	74 24                	je     f010239c <mem_init+0xe61>
f0102378:	c7 44 24 0c 68 7b 10 	movl   $0xf0107b68,0xc(%esp)
f010237f:	f0 
f0102380:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102387:	f0 
f0102388:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f010238f:	00 
f0102390:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102397:	e8 a4 dc ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010239c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01023a3:	00 
f01023a4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01023ab:	00 
f01023ac:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f01023b1:	89 04 24             	mov    %eax,(%esp)
f01023b4:	e8 85 ee ff ff       	call   f010123e <pgdir_walk>
f01023b9:	f6 00 04             	testb  $0x4,(%eax)
f01023bc:	74 24                	je     f01023e2 <mem_init+0xea7>
f01023be:	c7 44 24 0c f8 7a 10 	movl   $0xf0107af8,0xc(%esp)
f01023c5:	f0 
f01023c6:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01023cd:	f0 
f01023ce:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f01023d5:	00 
f01023d6:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01023dd:	e8 5e dc ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01023e2:	8b 3d 8c 1e 20 f0    	mov    0xf0201e8c,%edi
f01023e8:	ba 00 00 00 00       	mov    $0x0,%edx
f01023ed:	89 f8                	mov    %edi,%eax
f01023ef:	e8 23 e8 ff ff       	call   f0100c17 <check_va2pa>
f01023f4:	89 c1                	mov    %eax,%ecx
f01023f6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01023f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023fc:	2b 05 90 1e 20 f0    	sub    0xf0201e90,%eax
f0102402:	c1 f8 03             	sar    $0x3,%eax
f0102405:	c1 e0 0c             	shl    $0xc,%eax
f0102408:	39 c1                	cmp    %eax,%ecx
f010240a:	74 24                	je     f0102430 <mem_init+0xef5>
f010240c:	c7 44 24 0c a4 7b 10 	movl   $0xf0107ba4,0xc(%esp)
f0102413:	f0 
f0102414:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010241b:	f0 
f010241c:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f0102423:	00 
f0102424:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010242b:	e8 10 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102430:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102435:	89 f8                	mov    %edi,%eax
f0102437:	e8 db e7 ff ff       	call   f0100c17 <check_va2pa>
f010243c:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010243f:	74 24                	je     f0102465 <mem_init+0xf2a>
f0102441:	c7 44 24 0c d0 7b 10 	movl   $0xf0107bd0,0xc(%esp)
f0102448:	f0 
f0102449:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102450:	f0 
f0102451:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0102458:	00 
f0102459:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102460:	e8 db db ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102465:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102468:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f010246d:	74 24                	je     f0102493 <mem_init+0xf58>
f010246f:	c7 44 24 0c 73 76 10 	movl   $0xf0107673,0xc(%esp)
f0102476:	f0 
f0102477:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010247e:	f0 
f010247f:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0102486:	00 
f0102487:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010248e:	e8 ad db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102493:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102498:	74 24                	je     f01024be <mem_init+0xf83>
f010249a:	c7 44 24 0c 84 76 10 	movl   $0xf0107684,0xc(%esp)
f01024a1:	f0 
f01024a2:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01024a9:	f0 
f01024aa:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f01024b1:	00 
f01024b2:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01024b9:	e8 82 db ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01024be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024c5:	e8 a6 ec ff ff       	call   f0101170 <page_alloc>
f01024ca:	85 c0                	test   %eax,%eax
f01024cc:	74 04                	je     f01024d2 <mem_init+0xf97>
f01024ce:	39 c3                	cmp    %eax,%ebx
f01024d0:	74 24                	je     f01024f6 <mem_init+0xfbb>
f01024d2:	c7 44 24 0c 00 7c 10 	movl   $0xf0107c00,0xc(%esp)
f01024d9:	f0 
f01024da:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01024e1:	f0 
f01024e2:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f01024e9:	00 
f01024ea:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01024f1:	e8 4a db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01024f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01024fd:	00 
f01024fe:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0102503:	89 04 24             	mov    %eax,(%esp)
f0102506:	e8 f0 ee ff ff       	call   f01013fb <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010250b:	8b 3d 8c 1e 20 f0    	mov    0xf0201e8c,%edi
f0102511:	ba 00 00 00 00       	mov    $0x0,%edx
f0102516:	89 f8                	mov    %edi,%eax
f0102518:	e8 fa e6 ff ff       	call   f0100c17 <check_va2pa>
f010251d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102520:	74 24                	je     f0102546 <mem_init+0x100b>
f0102522:	c7 44 24 0c 24 7c 10 	movl   $0xf0107c24,0xc(%esp)
f0102529:	f0 
f010252a:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102531:	f0 
f0102532:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0102539:	00 
f010253a:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102541:	e8 fa da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102546:	ba 00 10 00 00       	mov    $0x1000,%edx
f010254b:	89 f8                	mov    %edi,%eax
f010254d:	e8 c5 e6 ff ff       	call   f0100c17 <check_va2pa>
f0102552:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102555:	2b 15 90 1e 20 f0    	sub    0xf0201e90,%edx
f010255b:	c1 fa 03             	sar    $0x3,%edx
f010255e:	c1 e2 0c             	shl    $0xc,%edx
f0102561:	39 d0                	cmp    %edx,%eax
f0102563:	74 24                	je     f0102589 <mem_init+0x104e>
f0102565:	c7 44 24 0c d0 7b 10 	movl   $0xf0107bd0,0xc(%esp)
f010256c:	f0 
f010256d:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102574:	f0 
f0102575:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f010257c:	00 
f010257d:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102584:	e8 b7 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102589:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010258c:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102591:	74 24                	je     f01025b7 <mem_init+0x107c>
f0102593:	c7 44 24 0c 2a 76 10 	movl   $0xf010762a,0xc(%esp)
f010259a:	f0 
f010259b:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01025a2:	f0 
f01025a3:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f01025aa:	00 
f01025ab:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01025b2:	e8 89 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025b7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01025bc:	74 24                	je     f01025e2 <mem_init+0x10a7>
f01025be:	c7 44 24 0c 84 76 10 	movl   $0xf0107684,0xc(%esp)
f01025c5:	f0 
f01025c6:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01025cd:	f0 
f01025ce:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f01025d5:	00 
f01025d6:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01025dd:	e8 5e da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01025e2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025e9:	00 
f01025ea:	89 3c 24             	mov    %edi,(%esp)
f01025ed:	e8 09 ee ff ff       	call   f01013fb <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025f2:	8b 3d 8c 1e 20 f0    	mov    0xf0201e8c,%edi
f01025f8:	ba 00 00 00 00       	mov    $0x0,%edx
f01025fd:	89 f8                	mov    %edi,%eax
f01025ff:	e8 13 e6 ff ff       	call   f0100c17 <check_va2pa>
f0102604:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102607:	74 24                	je     f010262d <mem_init+0x10f2>
f0102609:	c7 44 24 0c 24 7c 10 	movl   $0xf0107c24,0xc(%esp)
f0102610:	f0 
f0102611:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102618:	f0 
f0102619:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0102620:	00 
f0102621:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102628:	e8 13 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010262d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102632:	89 f8                	mov    %edi,%eax
f0102634:	e8 de e5 ff ff       	call   f0100c17 <check_va2pa>
f0102639:	83 f8 ff             	cmp    $0xffffffff,%eax
f010263c:	74 24                	je     f0102662 <mem_init+0x1127>
f010263e:	c7 44 24 0c 48 7c 10 	movl   $0xf0107c48,0xc(%esp)
f0102645:	f0 
f0102646:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010264d:	f0 
f010264e:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0102655:	00 
f0102656:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010265d:	e8 de d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102662:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102665:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010266a:	74 24                	je     f0102690 <mem_init+0x1155>
f010266c:	c7 44 24 0c 95 76 10 	movl   $0xf0107695,0xc(%esp)
f0102673:	f0 
f0102674:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010267b:	f0 
f010267c:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f0102683:	00 
f0102684:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010268b:	e8 b0 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102690:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102695:	74 24                	je     f01026bb <mem_init+0x1180>
f0102697:	c7 44 24 0c 84 76 10 	movl   $0xf0107684,0xc(%esp)
f010269e:	f0 
f010269f:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01026a6:	f0 
f01026a7:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f01026ae:	00 
f01026af:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01026b6:	e8 85 d9 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01026bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026c2:	e8 a9 ea ff ff       	call   f0101170 <page_alloc>
f01026c7:	85 c0                	test   %eax,%eax
f01026c9:	74 05                	je     f01026d0 <mem_init+0x1195>
f01026cb:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01026ce:	74 24                	je     f01026f4 <mem_init+0x11b9>
f01026d0:	c7 44 24 0c 70 7c 10 	movl   $0xf0107c70,0xc(%esp)
f01026d7:	f0 
f01026d8:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01026df:	f0 
f01026e0:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f01026e7:	00 
f01026e8:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01026ef:	e8 4c d9 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01026f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026fb:	e8 70 ea ff ff       	call   f0101170 <page_alloc>
f0102700:	85 c0                	test   %eax,%eax
f0102702:	74 24                	je     f0102728 <mem_init+0x11ed>
f0102704:	c7 44 24 0c d8 75 10 	movl   $0xf01075d8,0xc(%esp)
f010270b:	f0 
f010270c:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102713:	f0 
f0102714:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f010271b:	00 
f010271c:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102723:	e8 18 d9 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102728:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f010272d:	8b 08                	mov    (%eax),%ecx
f010272f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102735:	89 f2                	mov    %esi,%edx
f0102737:	2b 15 90 1e 20 f0    	sub    0xf0201e90,%edx
f010273d:	c1 fa 03             	sar    $0x3,%edx
f0102740:	c1 e2 0c             	shl    $0xc,%edx
f0102743:	39 d1                	cmp    %edx,%ecx
f0102745:	74 24                	je     f010276b <mem_init+0x1230>
f0102747:	c7 44 24 0c 4c 79 10 	movl   $0xf010794c,0xc(%esp)
f010274e:	f0 
f010274f:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102756:	f0 
f0102757:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f010275e:	00 
f010275f:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102766:	e8 d5 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010276b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102771:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102776:	74 24                	je     f010279c <mem_init+0x1261>
f0102778:	c7 44 24 0c 3b 76 10 	movl   $0xf010763b,0xc(%esp)
f010277f:	f0 
f0102780:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102787:	f0 
f0102788:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f010278f:	00 
f0102790:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102797:	e8 a4 d8 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010279c:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01027a2:	89 34 24             	mov    %esi,(%esp)
f01027a5:	e8 51 ea ff ff       	call   f01011fb <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01027aa:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01027b1:	00 
f01027b2:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01027b9:	00 
f01027ba:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f01027bf:	89 04 24             	mov    %eax,(%esp)
f01027c2:	e8 77 ea ff ff       	call   f010123e <pgdir_walk>
f01027c7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01027ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01027cd:	8b 15 8c 1e 20 f0    	mov    0xf0201e8c,%edx
f01027d3:	8b 7a 04             	mov    0x4(%edx),%edi
f01027d6:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f01027dc:	8b 0d 88 1e 20 f0    	mov    0xf0201e88,%ecx
f01027e2:	89 f8                	mov    %edi,%eax
f01027e4:	c1 e8 0c             	shr    $0xc,%eax
f01027e7:	39 c8                	cmp    %ecx,%eax
f01027e9:	72 20                	jb     f010280b <mem_init+0x12d0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01027ef:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f01027f6:	f0 
f01027f7:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f01027fe:	00 
f01027ff:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102806:	e8 35 d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010280b:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0102811:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0102814:	74 24                	je     f010283a <mem_init+0x12ff>
f0102816:	c7 44 24 0c a6 76 10 	movl   $0xf01076a6,0xc(%esp)
f010281d:	f0 
f010281e:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102825:	f0 
f0102826:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f010282d:	00 
f010282e:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102835:	e8 06 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010283a:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102841:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
	return (pp - pages) << PGSHIFT;
f0102847:	89 f0                	mov    %esi,%eax
f0102849:	2b 05 90 1e 20 f0    	sub    0xf0201e90,%eax
f010284f:	c1 f8 03             	sar    $0x3,%eax
f0102852:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102855:	89 c2                	mov    %eax,%edx
f0102857:	c1 ea 0c             	shr    $0xc,%edx
f010285a:	39 d1                	cmp    %edx,%ecx
f010285c:	77 20                	ja     f010287e <mem_init+0x1343>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010285e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102862:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f0102869:	f0 
f010286a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102871:	00 
f0102872:	c7 04 24 4b 74 10 f0 	movl   $0xf010744b,(%esp)
f0102879:	e8 c2 d7 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010287e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102885:	00 
f0102886:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010288d:	00 
	return (void *)(pa + KERNBASE);
f010288e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102893:	89 04 24             	mov    %eax,(%esp)
f0102896:	e8 3e 38 00 00       	call   f01060d9 <memset>
	page_free(pp0);
f010289b:	89 34 24             	mov    %esi,(%esp)
f010289e:	e8 58 e9 ff ff       	call   f01011fb <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01028a3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01028aa:	00 
f01028ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01028b2:	00 
f01028b3:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f01028b8:	89 04 24             	mov    %eax,(%esp)
f01028bb:	e8 7e e9 ff ff       	call   f010123e <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01028c0:	89 f2                	mov    %esi,%edx
f01028c2:	2b 15 90 1e 20 f0    	sub    0xf0201e90,%edx
f01028c8:	c1 fa 03             	sar    $0x3,%edx
f01028cb:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01028ce:	89 d0                	mov    %edx,%eax
f01028d0:	c1 e8 0c             	shr    $0xc,%eax
f01028d3:	3b 05 88 1e 20 f0    	cmp    0xf0201e88,%eax
f01028d9:	72 20                	jb     f01028fb <mem_init+0x13c0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028db:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01028df:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f01028e6:	f0 
f01028e7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01028ee:	00 
f01028ef:	c7 04 24 4b 74 10 f0 	movl   $0xf010744b,(%esp)
f01028f6:	e8 45 d7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01028fb:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102901:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102904:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f010290b:	75 11                	jne    f010291e <mem_init+0x13e3>
f010290d:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
f0102913:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f0102919:	f6 00 01             	testb  $0x1,(%eax)
f010291c:	74 24                	je     f0102942 <mem_init+0x1407>
f010291e:	c7 44 24 0c be 76 10 	movl   $0xf01076be,0xc(%esp)
f0102925:	f0 
f0102926:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010292d:	f0 
f010292e:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f0102935:	00 
f0102936:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010293d:	e8 fe d6 ff ff       	call   f0100040 <_panic>
f0102942:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102945:	39 d0                	cmp    %edx,%eax
f0102947:	75 d0                	jne    f0102919 <mem_init+0x13de>
	kern_pgdir[0] = 0;
f0102949:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f010294e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102954:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f010295a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010295d:	a3 40 12 20 f0       	mov    %eax,0xf0201240

	// free the pages we took
	page_free(pp0);
f0102962:	89 34 24             	mov    %esi,(%esp)
f0102965:	e8 91 e8 ff ff       	call   f01011fb <page_free>
	page_free(pp1);
f010296a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010296d:	89 04 24             	mov    %eax,(%esp)
f0102970:	e8 86 e8 ff ff       	call   f01011fb <page_free>
	page_free(pp2);
f0102975:	89 1c 24             	mov    %ebx,(%esp)
f0102978:	e8 7e e8 ff ff       	call   f01011fb <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010297d:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102984:	00 
f0102985:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010298c:	e8 3b eb ff ff       	call   f01014cc <mmio_map_region>
f0102991:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102993:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010299a:	00 
f010299b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029a2:	e8 25 eb ff ff       	call   f01014cc <mmio_map_region>
f01029a7:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01029a9:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01029af:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01029b4:	77 08                	ja     f01029be <mem_init+0x1483>
f01029b6:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01029bc:	77 24                	ja     f01029e2 <mem_init+0x14a7>
f01029be:	c7 44 24 0c 94 7c 10 	movl   $0xf0107c94,0xc(%esp)
f01029c5:	f0 
f01029c6:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01029cd:	f0 
f01029ce:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f01029d5:	00 
f01029d6:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01029dd:	e8 5e d6 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01029e2:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01029e8:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01029ee:	77 08                	ja     f01029f8 <mem_init+0x14bd>
f01029f0:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01029f6:	77 24                	ja     f0102a1c <mem_init+0x14e1>
f01029f8:	c7 44 24 0c bc 7c 10 	movl   $0xf0107cbc,0xc(%esp)
f01029ff:	f0 
f0102a00:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102a07:	f0 
f0102a08:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f0102a0f:	00 
f0102a10:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102a17:	e8 24 d6 ff ff       	call   f0100040 <_panic>
f0102a1c:	89 da                	mov    %ebx,%edx
f0102a1e:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102a20:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102a26:	74 24                	je     f0102a4c <mem_init+0x1511>
f0102a28:	c7 44 24 0c e4 7c 10 	movl   $0xf0107ce4,0xc(%esp)
f0102a2f:	f0 
f0102a30:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102a37:	f0 
f0102a38:	c7 44 24 04 24 04 00 	movl   $0x424,0x4(%esp)
f0102a3f:	00 
f0102a40:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102a47:	e8 f4 d5 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102a4c:	39 c6                	cmp    %eax,%esi
f0102a4e:	73 24                	jae    f0102a74 <mem_init+0x1539>
f0102a50:	c7 44 24 0c d5 76 10 	movl   $0xf01076d5,0xc(%esp)
f0102a57:	f0 
f0102a58:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102a5f:	f0 
f0102a60:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f0102a67:	00 
f0102a68:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102a6f:	e8 cc d5 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102a74:	8b 3d 8c 1e 20 f0    	mov    0xf0201e8c,%edi
f0102a7a:	89 da                	mov    %ebx,%edx
f0102a7c:	89 f8                	mov    %edi,%eax
f0102a7e:	e8 94 e1 ff ff       	call   f0100c17 <check_va2pa>
f0102a83:	85 c0                	test   %eax,%eax
f0102a85:	74 24                	je     f0102aab <mem_init+0x1570>
f0102a87:	c7 44 24 0c 0c 7d 10 	movl   $0xf0107d0c,0xc(%esp)
f0102a8e:	f0 
f0102a8f:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102a96:	f0 
f0102a97:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f0102a9e:	00 
f0102a9f:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102aa6:	e8 95 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102aab:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102ab1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102ab4:	89 c2                	mov    %eax,%edx
f0102ab6:	89 f8                	mov    %edi,%eax
f0102ab8:	e8 5a e1 ff ff       	call   f0100c17 <check_va2pa>
f0102abd:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102ac2:	74 24                	je     f0102ae8 <mem_init+0x15ad>
f0102ac4:	c7 44 24 0c 30 7d 10 	movl   $0xf0107d30,0xc(%esp)
f0102acb:	f0 
f0102acc:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102ad3:	f0 
f0102ad4:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f0102adb:	00 
f0102adc:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102ae3:	e8 58 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102ae8:	89 f2                	mov    %esi,%edx
f0102aea:	89 f8                	mov    %edi,%eax
f0102aec:	e8 26 e1 ff ff       	call   f0100c17 <check_va2pa>
f0102af1:	85 c0                	test   %eax,%eax
f0102af3:	74 24                	je     f0102b19 <mem_init+0x15de>
f0102af5:	c7 44 24 0c 60 7d 10 	movl   $0xf0107d60,0xc(%esp)
f0102afc:	f0 
f0102afd:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102b04:	f0 
f0102b05:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f0102b0c:	00 
f0102b0d:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102b14:	e8 27 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102b19:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102b1f:	89 f8                	mov    %edi,%eax
f0102b21:	e8 f1 e0 ff ff       	call   f0100c17 <check_va2pa>
f0102b26:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b29:	74 24                	je     f0102b4f <mem_init+0x1614>
f0102b2b:	c7 44 24 0c 84 7d 10 	movl   $0xf0107d84,0xc(%esp)
f0102b32:	f0 
f0102b33:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102b3a:	f0 
f0102b3b:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0102b42:	00 
f0102b43:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102b4a:	e8 f1 d4 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102b4f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b56:	00 
f0102b57:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b5b:	89 3c 24             	mov    %edi,(%esp)
f0102b5e:	e8 db e6 ff ff       	call   f010123e <pgdir_walk>
f0102b63:	f6 00 1a             	testb  $0x1a,(%eax)
f0102b66:	75 24                	jne    f0102b8c <mem_init+0x1651>
f0102b68:	c7 44 24 0c b0 7d 10 	movl   $0xf0107db0,0xc(%esp)
f0102b6f:	f0 
f0102b70:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102b77:	f0 
f0102b78:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f0102b7f:	00 
f0102b80:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102b87:	e8 b4 d4 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102b8c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b93:	00 
f0102b94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b98:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0102b9d:	89 04 24             	mov    %eax,(%esp)
f0102ba0:	e8 99 e6 ff ff       	call   f010123e <pgdir_walk>
f0102ba5:	f6 00 04             	testb  $0x4,(%eax)
f0102ba8:	74 24                	je     f0102bce <mem_init+0x1693>
f0102baa:	c7 44 24 0c f4 7d 10 	movl   $0xf0107df4,0xc(%esp)
f0102bb1:	f0 
f0102bb2:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102bb9:	f0 
f0102bba:	c7 44 24 04 2e 04 00 	movl   $0x42e,0x4(%esp)
f0102bc1:	00 
f0102bc2:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102bc9:	e8 72 d4 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102bce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102bd5:	00 
f0102bd6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102bda:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0102bdf:	89 04 24             	mov    %eax,(%esp)
f0102be2:	e8 57 e6 ff ff       	call   f010123e <pgdir_walk>
f0102be7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102bed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102bf4:	00 
f0102bf5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102bfc:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0102c01:	89 04 24             	mov    %eax,(%esp)
f0102c04:	e8 35 e6 ff ff       	call   f010123e <pgdir_walk>
f0102c09:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102c0f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c16:	00 
f0102c17:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102c1b:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0102c20:	89 04 24             	mov    %eax,(%esp)
f0102c23:	e8 16 e6 ff ff       	call   f010123e <pgdir_walk>
f0102c28:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102c2e:	c7 04 24 e7 76 10 f0 	movl   $0xf01076e7,(%esp)
f0102c35:	e8 63 13 00 00       	call   f0103f9d <cprintf>
	boot_map_region(kern_pgdir, UPAGES, sizeof(struct PageInfo) * npages, PADDR(pages), PTE_U | PTE_W);
f0102c3a:	a1 90 1e 20 f0       	mov    0xf0201e90,%eax
	if ((uint32_t)kva < KERNBASE)
f0102c3f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c44:	77 20                	ja     f0102c66 <mem_init+0x172b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c46:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c4a:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0102c51:	f0 
f0102c52:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
f0102c59:	00 
f0102c5a:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102c61:	e8 da d3 ff ff       	call   f0100040 <_panic>
f0102c66:	8b 0d 88 1e 20 f0    	mov    0xf0201e88,%ecx
f0102c6c:	c1 e1 03             	shl    $0x3,%ecx
f0102c6f:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
f0102c76:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c77:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c7c:	89 04 24             	mov    %eax,(%esp)
f0102c7f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102c84:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0102c89:	e8 51 e6 ff ff       	call   f01012df <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, sizeof(struct Env) * NENV, PADDR(envs), PTE_U | PTE_W);
f0102c8e:	a1 48 12 20 f0       	mov    0xf0201248,%eax
	if ((uint32_t)kva < KERNBASE)
f0102c93:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c98:	77 20                	ja     f0102cba <mem_init+0x177f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c9e:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0102ca5:	f0 
f0102ca6:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f0102cad:	00 
f0102cae:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102cb5:	e8 86 d3 ff ff       	call   f0100040 <_panic>
f0102cba:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
f0102cc1:	00 
	return (physaddr_t)kva - KERNBASE;
f0102cc2:	05 00 00 00 10       	add    $0x10000000,%eax
f0102cc7:	89 04 24             	mov    %eax,(%esp)
f0102cca:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102ccf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102cd4:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0102cd9:	e8 01 e6 ff ff       	call   f01012df <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102cde:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102ce3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ce8:	77 20                	ja     f0102d0a <mem_init+0x17cf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cee:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0102cf5:	f0 
f0102cf6:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
f0102cfd:	00 
f0102cfe:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102d05:	e8 36 d3 ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102d0a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102d11:	00 
f0102d12:	c7 04 24 00 70 11 00 	movl   $0x117000,(%esp)
f0102d19:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d1e:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102d23:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0102d28:	e8 b2 e5 ff ff       	call   f01012df <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffffu - KERNBASE, 0, PTE_W);
f0102d2d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102d34:	00 
f0102d35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d3c:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102d41:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102d46:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0102d4b:	e8 8f e5 ff ff       	call   f01012df <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102d50:	b8 00 30 20 f0       	mov    $0xf0203000,%eax
f0102d55:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d5a:	0f 87 30 07 00 00    	ja     f0103490 <mem_init+0x1f55>
f0102d60:	eb 0c                	jmp    f0102d6e <mem_init+0x1833>
		boot_map_region(kern_pgdir, start, KSTKSIZE, PADDR(percpu_kstacks + i), PTE_W);
f0102d62:	89 d8                	mov    %ebx,%eax
f0102d64:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102d6a:	77 27                	ja     f0102d93 <mem_init+0x1858>
f0102d6c:	eb 05                	jmp    f0102d73 <mem_init+0x1838>
f0102d6e:	b8 00 30 20 f0       	mov    $0xf0203000,%eax
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d73:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d77:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0102d7e:	f0 
f0102d7f:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
f0102d86:	00 
f0102d87:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102d8e:	e8 ad d2 ff ff       	call   f0100040 <_panic>
f0102d93:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102d9a:	00 
f0102d9b:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102da1:	89 04 24             	mov    %eax,(%esp)
f0102da4:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102da9:	89 f2                	mov    %esi,%edx
f0102dab:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0102db0:	e8 2a e5 ff ff       	call   f01012df <boot_map_region>
f0102db5:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102dbb:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for(i = 0; i < NCPU; ++i){
f0102dc1:	39 fb                	cmp    %edi,%ebx
f0102dc3:	75 9d                	jne    f0102d62 <mem_init+0x1827>
	pgdir = kern_pgdir;
f0102dc5:	8b 3d 8c 1e 20 f0    	mov    0xf0201e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102dcb:	a1 88 1e 20 f0       	mov    0xf0201e88,%eax
f0102dd0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102dd3:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
	for (i = 0; i < n; i += PGSIZE)
f0102dda:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102ddf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102de2:	75 30                	jne    f0102e14 <mem_init+0x18d9>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102de4:	8b 1d 48 12 20 f0    	mov    0xf0201248,%ebx
	if ((uint32_t)kva < KERNBASE)
f0102dea:	89 de                	mov    %ebx,%esi
f0102dec:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102df1:	89 f8                	mov    %edi,%eax
f0102df3:	e8 1f de ff ff       	call   f0100c17 <check_va2pa>
f0102df8:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102dfe:	0f 86 94 00 00 00    	jbe    f0102e98 <mem_init+0x195d>
f0102e04:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102e09:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0102e0f:	e9 a4 00 00 00       	jmp    f0102eb8 <mem_init+0x197d>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e14:	8b 1d 90 1e 20 f0    	mov    0xf0201e90,%ebx
	return (physaddr_t)kva - KERNBASE;
f0102e1a:	8d b3 00 00 00 10    	lea    0x10000000(%ebx),%esi
f0102e20:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102e25:	89 f8                	mov    %edi,%eax
f0102e27:	e8 eb dd ff ff       	call   f0100c17 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102e2c:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102e32:	77 20                	ja     f0102e54 <mem_init+0x1919>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e34:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102e38:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0102e3f:	f0 
f0102e40:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0102e47:	00 
f0102e48:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102e4f:	e8 ec d1 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102e54:	ba 00 00 00 00       	mov    $0x0,%edx
f0102e59:	8d 0c 16             	lea    (%esi,%edx,1),%ecx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e5c:	39 c1                	cmp    %eax,%ecx
f0102e5e:	74 24                	je     f0102e84 <mem_init+0x1949>
f0102e60:	c7 44 24 0c 28 7e 10 	movl   $0xf0107e28,0xc(%esp)
f0102e67:	f0 
f0102e68:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102e6f:	f0 
f0102e70:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0102e77:	00 
f0102e78:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102e7f:	e8 bc d1 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102e84:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
f0102e8a:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102e8d:	0f 87 52 06 00 00    	ja     f01034e5 <mem_init+0x1faa>
f0102e93:	e9 4c ff ff ff       	jmp    f0102de4 <mem_init+0x18a9>
f0102e98:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102e9c:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0102ea3:	f0 
f0102ea4:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0102eab:	00 
f0102eac:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102eb3:	e8 88 d1 ff ff       	call   f0100040 <_panic>
f0102eb8:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ebb:	39 d0                	cmp    %edx,%eax
f0102ebd:	74 24                	je     f0102ee3 <mem_init+0x19a8>
f0102ebf:	c7 44 24 0c 5c 7e 10 	movl   $0xf0107e5c,0xc(%esp)
f0102ec6:	f0 
f0102ec7:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102ece:	f0 
f0102ecf:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0102ed6:	00 
f0102ed7:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102ede:	e8 5d d1 ff ff       	call   f0100040 <_panic>
f0102ee3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102ee9:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102eef:	0f 85 e0 05 00 00    	jne    f01034d5 <mem_init+0x1f9a>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ef5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102ef8:	c1 e6 0c             	shl    $0xc,%esi
f0102efb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f00:	85 f6                	test   %esi,%esi
f0102f02:	75 22                	jne    f0102f26 <mem_init+0x19eb>
f0102f04:	c7 45 d0 00 30 20 f0 	movl   $0xf0203000,-0x30(%ebp)
f0102f0b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102f12:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102f17:	b8 00 30 20 f0       	mov    $0xf0203000,%eax
f0102f1c:	05 00 80 00 20       	add    $0x20008000,%eax
f0102f21:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102f24:	eb 41                	jmp    f0102f67 <mem_init+0x1a2c>
f0102f26:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102f2c:	89 f8                	mov    %edi,%eax
f0102f2e:	e8 e4 dc ff ff       	call   f0100c17 <check_va2pa>
f0102f33:	39 c3                	cmp    %eax,%ebx
f0102f35:	74 24                	je     f0102f5b <mem_init+0x1a20>
f0102f37:	c7 44 24 0c 90 7e 10 	movl   $0xf0107e90,0xc(%esp)
f0102f3e:	f0 
f0102f3f:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102f46:	f0 
f0102f47:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0102f4e:	00 
f0102f4f:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102f56:	e8 e5 d0 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f5b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f61:	39 de                	cmp    %ebx,%esi
f0102f63:	77 c1                	ja     f0102f26 <mem_init+0x19eb>
f0102f65:	eb 9d                	jmp    f0102f04 <mem_init+0x19c9>
f0102f67:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102f6d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f70:	89 f2                	mov    %esi,%edx
f0102f72:	89 f8                	mov    %edi,%eax
f0102f74:	e8 9e dc ff ff       	call   f0100c17 <check_va2pa>
f0102f79:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if ((uint32_t)kva < KERNBASE)
f0102f7c:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0102f82:	77 20                	ja     f0102fa4 <mem_init+0x1a69>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f84:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102f88:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0102f8f:	f0 
f0102f90:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0102f97:	00 
f0102f98:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102f9f:	e8 9c d0 ff ff       	call   f0100040 <_panic>
	if ((uint32_t)kva < KERNBASE)
f0102fa4:	89 f3                	mov    %esi,%ebx
f0102fa6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102fa9:	03 4d c4             	add    -0x3c(%ebp),%ecx
f0102fac:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102faf:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102fb2:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102fb5:	39 c2                	cmp    %eax,%edx
f0102fb7:	74 24                	je     f0102fdd <mem_init+0x1aa2>
f0102fb9:	c7 44 24 0c b8 7e 10 	movl   $0xf0107eb8,0xc(%esp)
f0102fc0:	f0 
f0102fc1:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0102fc8:	f0 
f0102fc9:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0102fd0:	00 
f0102fd1:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0102fd8:	e8 63 d0 ff ff       	call   f0100040 <_panic>
f0102fdd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102fe3:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f0102fe6:	0f 85 db 04 00 00    	jne    f01034c7 <mem_init+0x1f8c>
f0102fec:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102ff2:	89 da                	mov    %ebx,%edx
f0102ff4:	89 f8                	mov    %edi,%eax
f0102ff6:	e8 1c dc ff ff       	call   f0100c17 <check_va2pa>
f0102ffb:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102ffe:	74 24                	je     f0103024 <mem_init+0x1ae9>
f0103000:	c7 44 24 0c 00 7f 10 	movl   $0xf0107f00,0xc(%esp)
f0103007:	f0 
f0103008:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010300f:	f0 
f0103010:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0103017:	00 
f0103018:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010301f:	e8 1c d0 ff ff       	call   f0100040 <_panic>
f0103024:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010302a:	39 f3                	cmp    %esi,%ebx
f010302c:	75 c4                	jne    f0102ff2 <mem_init+0x1ab7>
f010302e:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0103034:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f010303b:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (n = 0; n < NCPU; n++) {
f0103042:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103048:	0f 85 19 ff ff ff    	jne    f0102f67 <mem_init+0x1a2c>
f010304e:	b8 00 00 00 00       	mov    $0x0,%eax
		switch (i) {
f0103053:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103059:	83 fa 04             	cmp    $0x4,%edx
f010305c:	77 2e                	ja     f010308c <mem_init+0x1b51>
			assert(pgdir[i] & PTE_P);
f010305e:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0103062:	0f 85 aa 00 00 00    	jne    f0103112 <mem_init+0x1bd7>
f0103068:	c7 44 24 0c 00 77 10 	movl   $0xf0107700,0xc(%esp)
f010306f:	f0 
f0103070:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0103077:	f0 
f0103078:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f010307f:	00 
f0103080:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0103087:	e8 b4 cf ff ff       	call   f0100040 <_panic>
			if (i >= PDX(KERNBASE)) {
f010308c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103091:	76 55                	jbe    f01030e8 <mem_init+0x1bad>
				assert(pgdir[i] & PTE_P);
f0103093:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103096:	f6 c2 01             	test   $0x1,%dl
f0103099:	75 24                	jne    f01030bf <mem_init+0x1b84>
f010309b:	c7 44 24 0c 00 77 10 	movl   $0xf0107700,0xc(%esp)
f01030a2:	f0 
f01030a3:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01030aa:	f0 
f01030ab:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f01030b2:	00 
f01030b3:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01030ba:	e8 81 cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01030bf:	f6 c2 02             	test   $0x2,%dl
f01030c2:	75 4e                	jne    f0103112 <mem_init+0x1bd7>
f01030c4:	c7 44 24 0c 11 77 10 	movl   $0xf0107711,0xc(%esp)
f01030cb:	f0 
f01030cc:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01030d3:	f0 
f01030d4:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f01030db:	00 
f01030dc:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01030e3:	e8 58 cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f01030e8:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01030ec:	74 24                	je     f0103112 <mem_init+0x1bd7>
f01030ee:	c7 44 24 0c 22 77 10 	movl   $0xf0107722,0xc(%esp)
f01030f5:	f0 
f01030f6:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01030fd:	f0 
f01030fe:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0103105:	00 
f0103106:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010310d:	e8 2e cf ff ff       	call   f0100040 <_panic>
	for (i = 0; i < NPDENTRIES; i++) {
f0103112:	83 c0 01             	add    $0x1,%eax
f0103115:	3d 00 04 00 00       	cmp    $0x400,%eax
f010311a:	0f 85 33 ff ff ff    	jne    f0103053 <mem_init+0x1b18>
	cprintf("check_kern_pgdir() succeeded!\n");
f0103120:	c7 04 24 24 7f 10 f0 	movl   $0xf0107f24,(%esp)
f0103127:	e8 71 0e 00 00       	call   f0103f9d <cprintf>
	lcr3(PADDR(kern_pgdir));
f010312c:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0103131:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103136:	77 20                	ja     f0103158 <mem_init+0x1c1d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103138:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010313c:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0103143:	f0 
f0103144:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
f010314b:	00 
f010314c:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0103153:	e8 e8 ce ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103158:	05 00 00 00 10       	add    $0x10000000,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010315d:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0103160:	b8 00 00 00 00       	mov    $0x0,%eax
f0103165:	e8 1c db ff ff       	call   f0100c86 <check_page_free_list>
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010316a:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010316d:	83 e0 f3             	and    $0xfffffff3,%eax
f0103170:	0d 23 00 05 80       	or     $0x80050023,%eax
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103175:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103178:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010317f:	e8 ec df ff ff       	call   f0101170 <page_alloc>
f0103184:	89 c3                	mov    %eax,%ebx
f0103186:	85 c0                	test   %eax,%eax
f0103188:	75 24                	jne    f01031ae <mem_init+0x1c73>
f010318a:	c7 44 24 0c 2d 75 10 	movl   $0xf010752d,0xc(%esp)
f0103191:	f0 
f0103192:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0103199:	f0 
f010319a:	c7 44 24 04 43 04 00 	movl   $0x443,0x4(%esp)
f01031a1:	00 
f01031a2:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01031a9:	e8 92 ce ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01031ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031b5:	e8 b6 df ff ff       	call   f0101170 <page_alloc>
f01031ba:	89 c7                	mov    %eax,%edi
f01031bc:	85 c0                	test   %eax,%eax
f01031be:	75 24                	jne    f01031e4 <mem_init+0x1ca9>
f01031c0:	c7 44 24 0c 43 75 10 	movl   $0xf0107543,0xc(%esp)
f01031c7:	f0 
f01031c8:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01031cf:	f0 
f01031d0:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f01031d7:	00 
f01031d8:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01031df:	e8 5c ce ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01031e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031eb:	e8 80 df ff ff       	call   f0101170 <page_alloc>
f01031f0:	89 c6                	mov    %eax,%esi
f01031f2:	85 c0                	test   %eax,%eax
f01031f4:	75 24                	jne    f010321a <mem_init+0x1cdf>
f01031f6:	c7 44 24 0c 59 75 10 	movl   $0xf0107559,0xc(%esp)
f01031fd:	f0 
f01031fe:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0103205:	f0 
f0103206:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f010320d:	00 
f010320e:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0103215:	e8 26 ce ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f010321a:	89 1c 24             	mov    %ebx,(%esp)
f010321d:	e8 d9 df ff ff       	call   f01011fb <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0103222:	89 f8                	mov    %edi,%eax
f0103224:	e8 a9 d9 ff ff       	call   f0100bd2 <page2kva>
f0103229:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103230:	00 
f0103231:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103238:	00 
f0103239:	89 04 24             	mov    %eax,(%esp)
f010323c:	e8 98 2e 00 00       	call   f01060d9 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103241:	89 f0                	mov    %esi,%eax
f0103243:	e8 8a d9 ff ff       	call   f0100bd2 <page2kva>
f0103248:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010324f:	00 
f0103250:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103257:	00 
f0103258:	89 04 24             	mov    %eax,(%esp)
f010325b:	e8 79 2e 00 00       	call   f01060d9 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103260:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103267:	00 
f0103268:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010326f:	00 
f0103270:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103274:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0103279:	89 04 24             	mov    %eax,(%esp)
f010327c:	e8 ca e1 ff ff       	call   f010144b <page_insert>
	assert(pp1->pp_ref == 1);
f0103281:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103286:	74 24                	je     f01032ac <mem_init+0x1d71>
f0103288:	c7 44 24 0c 2a 76 10 	movl   $0xf010762a,0xc(%esp)
f010328f:	f0 
f0103290:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0103297:	f0 
f0103298:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f010329f:	00 
f01032a0:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01032a7:	e8 94 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01032ac:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01032b3:	01 01 01 
f01032b6:	74 24                	je     f01032dc <mem_init+0x1da1>
f01032b8:	c7 44 24 0c 44 7f 10 	movl   $0xf0107f44,0xc(%esp)
f01032bf:	f0 
f01032c0:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01032c7:	f0 
f01032c8:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f01032cf:	00 
f01032d0:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01032d7:	e8 64 cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01032dc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01032e3:	00 
f01032e4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032eb:	00 
f01032ec:	89 74 24 04          	mov    %esi,0x4(%esp)
f01032f0:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f01032f5:	89 04 24             	mov    %eax,(%esp)
f01032f8:	e8 4e e1 ff ff       	call   f010144b <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01032fd:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103304:	02 02 02 
f0103307:	74 24                	je     f010332d <mem_init+0x1df2>
f0103309:	c7 44 24 0c 68 7f 10 	movl   $0xf0107f68,0xc(%esp)
f0103310:	f0 
f0103311:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0103318:	f0 
f0103319:	c7 44 24 04 4d 04 00 	movl   $0x44d,0x4(%esp)
f0103320:	00 
f0103321:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0103328:	e8 13 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010332d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103332:	74 24                	je     f0103358 <mem_init+0x1e1d>
f0103334:	c7 44 24 0c 4c 76 10 	movl   $0xf010764c,0xc(%esp)
f010333b:	f0 
f010333c:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0103343:	f0 
f0103344:	c7 44 24 04 4e 04 00 	movl   $0x44e,0x4(%esp)
f010334b:	00 
f010334c:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f0103353:	e8 e8 cc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103358:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010335d:	74 24                	je     f0103383 <mem_init+0x1e48>
f010335f:	c7 44 24 0c 95 76 10 	movl   $0xf0107695,0xc(%esp)
f0103366:	f0 
f0103367:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010336e:	f0 
f010336f:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0103376:	00 
f0103377:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010337e:	e8 bd cc ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103383:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010338a:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010338d:	89 f0                	mov    %esi,%eax
f010338f:	e8 3e d8 ff ff       	call   f0100bd2 <page2kva>
f0103394:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f010339a:	74 24                	je     f01033c0 <mem_init+0x1e85>
f010339c:	c7 44 24 0c 8c 7f 10 	movl   $0xf0107f8c,0xc(%esp)
f01033a3:	f0 
f01033a4:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01033ab:	f0 
f01033ac:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f01033b3:	00 
f01033b4:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01033bb:	e8 80 cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01033c0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01033c7:	00 
f01033c8:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f01033cd:	89 04 24             	mov    %eax,(%esp)
f01033d0:	e8 26 e0 ff ff       	call   f01013fb <page_remove>
	assert(pp2->pp_ref == 0);
f01033d5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01033da:	74 24                	je     f0103400 <mem_init+0x1ec5>
f01033dc:	c7 44 24 0c 84 76 10 	movl   $0xf0107684,0xc(%esp)
f01033e3:	f0 
f01033e4:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f01033eb:	f0 
f01033ec:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f01033f3:	00 
f01033f4:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f01033fb:	e8 40 cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103400:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f0103405:	8b 08                	mov    (%eax),%ecx
f0103407:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	return (pp - pages) << PGSHIFT;
f010340d:	89 da                	mov    %ebx,%edx
f010340f:	2b 15 90 1e 20 f0    	sub    0xf0201e90,%edx
f0103415:	c1 fa 03             	sar    $0x3,%edx
f0103418:	c1 e2 0c             	shl    $0xc,%edx
f010341b:	39 d1                	cmp    %edx,%ecx
f010341d:	74 24                	je     f0103443 <mem_init+0x1f08>
f010341f:	c7 44 24 0c 4c 79 10 	movl   $0xf010794c,0xc(%esp)
f0103426:	f0 
f0103427:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010342e:	f0 
f010342f:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f0103436:	00 
f0103437:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010343e:	e8 fd cb ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103443:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103449:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010344e:	74 24                	je     f0103474 <mem_init+0x1f39>
f0103450:	c7 44 24 0c 3b 76 10 	movl   $0xf010763b,0xc(%esp)
f0103457:	f0 
f0103458:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f010345f:	f0 
f0103460:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f0103467:	00 
f0103468:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010346f:	e8 cc cb ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103474:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010347a:	89 1c 24             	mov    %ebx,(%esp)
f010347d:	e8 79 dd ff ff       	call   f01011fb <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103482:	c7 04 24 b8 7f 10 f0 	movl   $0xf0107fb8,(%esp)
f0103489:	e8 0f 0b 00 00       	call   f0103f9d <cprintf>
f010348e:	eb 69                	jmp    f01034f9 <mem_init+0x1fbe>
		boot_map_region(kern_pgdir, start, KSTKSIZE, PADDR(percpu_kstacks + i), PTE_W);
f0103490:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103497:	00 
f0103498:	c7 04 24 00 30 20 00 	movl   $0x203000,(%esp)
f010349f:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01034a4:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01034a9:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
f01034ae:	e8 2c de ff ff       	call   f01012df <boot_map_region>
f01034b3:	bb 00 b0 20 f0       	mov    $0xf020b000,%ebx
f01034b8:	bf 00 30 24 f0       	mov    $0xf0243000,%edi
f01034bd:	be 00 80 fe ef       	mov    $0xeffe8000,%esi
f01034c2:	e9 9b f8 ff ff       	jmp    f0102d62 <mem_init+0x1827>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01034c7:	89 da                	mov    %ebx,%edx
f01034c9:	89 f8                	mov    %edi,%eax
f01034cb:	e8 47 d7 ff ff       	call   f0100c17 <check_va2pa>
f01034d0:	e9 da fa ff ff       	jmp    f0102faf <mem_init+0x1a74>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01034d5:	89 da                	mov    %ebx,%edx
f01034d7:	89 f8                	mov    %edi,%eax
f01034d9:	e8 39 d7 ff ff       	call   f0100c17 <check_va2pa>
f01034de:	66 90                	xchg   %ax,%ax
f01034e0:	e9 d3 f9 ff ff       	jmp    f0102eb8 <mem_init+0x197d>
f01034e5:	81 ea 00 f0 ff 10    	sub    $0x10fff000,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01034eb:	89 f8                	mov    %edi,%eax
f01034ed:	e8 25 d7 ff ff       	call   f0100c17 <check_va2pa>
	for (i = 0; i < n; i += PGSIZE)
f01034f2:	89 da                	mov    %ebx,%edx
f01034f4:	e9 60 f9 ff ff       	jmp    f0102e59 <mem_init+0x191e>
}
f01034f9:	83 c4 4c             	add    $0x4c,%esp
f01034fc:	5b                   	pop    %ebx
f01034fd:	5e                   	pop    %esi
f01034fe:	5f                   	pop    %edi
f01034ff:	5d                   	pop    %ebp
f0103500:	c3                   	ret    

f0103501 <user_mem_check>:
{
f0103501:	55                   	push   %ebp
f0103502:	89 e5                	mov    %esp,%ebp
f0103504:	57                   	push   %edi
f0103505:	56                   	push   %esi
f0103506:	53                   	push   %ebx
f0103507:	83 ec 1c             	sub    $0x1c,%esp
	unsigned cur_va = ROUNDDOWN((unsigned)va, PGSIZE);
f010350a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010350d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    unsigned end_va = ROUNDUP((unsigned)va + len, PGSIZE);
f0103513:	8b 45 10             	mov    0x10(%ebp),%eax
f0103516:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103519:	8d bc 07 ff 0f 00 00 	lea    0xfff(%edi,%eax,1),%edi
f0103520:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	perm |= PTE_P;
f0103526:	8b 75 14             	mov    0x14(%ebp),%esi
f0103529:	83 ce 01             	or     $0x1,%esi
    while(cur_va < end_va){
f010352c:	39 fb                	cmp    %edi,%ebx
f010352e:	0f 83 93 00 00 00    	jae    f01035c7 <user_mem_check+0xc6>
        pde_t *pgdir = curenv->env_pgdir;
f0103534:	e8 3a 32 00 00       	call   f0106773 <cpunum>
f0103539:	6b c0 74             	imul   $0x74,%eax,%eax
f010353c:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
        pde_t pgdir_entry = pgdir[PDX(cur_va)];
f0103542:	89 da                	mov    %ebx,%edx
f0103544:	c1 ea 16             	shr    $0x16,%edx
f0103547:	8b 40 60             	mov    0x60(%eax),%eax
f010354a:	8b 04 90             	mov    (%eax,%edx,4),%eax
        if(cur_va > ULIM || (pgdir_entry & perm) != perm)
f010354d:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0103553:	77 5e                	ja     f01035b3 <user_mem_check+0xb2>
f0103555:	89 c2                	mov    %eax,%edx
f0103557:	21 f2                	and    %esi,%edx
f0103559:	39 d6                	cmp    %edx,%esi
f010355b:	75 56                	jne    f01035b3 <user_mem_check+0xb2>
        pte_t *pg_address = KADDR(PTE_ADDR(pgdir_entry));
f010355d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0103562:	89 c2                	mov    %eax,%edx
f0103564:	c1 ea 0c             	shr    $0xc,%edx
f0103567:	3b 15 88 1e 20 f0    	cmp    0xf0201e88,%edx
f010356d:	72 20                	jb     f010358f <user_mem_check+0x8e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010356f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103573:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f010357a:	f0 
f010357b:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
f0103582:	00 
f0103583:	c7 04 24 3f 74 10 f0 	movl   $0xf010743f,(%esp)
f010358a:	e8 b1 ca ff ff       	call   f0100040 <_panic>
        pte_t pg_entry = pg_address[PTX(cur_va)];
f010358f:	89 da                	mov    %ebx,%edx
f0103591:	c1 ea 0c             	shr    $0xc,%edx
f0103594:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
        if(cur_va > ULIM || (pg_entry & perm) != perm)
f010359a:	89 f1                	mov    %esi,%ecx
f010359c:	23 8c 90 00 00 00 f0 	and    -0x10000000(%eax,%edx,4),%ecx
f01035a3:	39 ce                	cmp    %ecx,%esi
f01035a5:	75 0c                	jne    f01035b3 <user_mem_check+0xb2>
        cur_va += PGSIZE;
f01035a7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    while(cur_va < end_va){
f01035ad:	39 df                	cmp    %ebx,%edi
f01035af:	77 83                	ja     f0103534 <user_mem_check+0x33>
f01035b1:	eb 1b                	jmp    f01035ce <user_mem_check+0xcd>
	user_mem_check_addr = (cur_va > (unsigned)va ? cur_va : (unsigned)va);
f01035b3:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01035b6:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f01035ba:	89 1d 3c 12 20 f0    	mov    %ebx,0xf020123c
	return -E_FAULT;
f01035c0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01035c5:	eb 0c                	jmp    f01035d3 <user_mem_check+0xd2>
    return 0;
f01035c7:	b8 00 00 00 00       	mov    $0x0,%eax
f01035cc:	eb 05                	jmp    f01035d3 <user_mem_check+0xd2>
f01035ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01035d3:	83 c4 1c             	add    $0x1c,%esp
f01035d6:	5b                   	pop    %ebx
f01035d7:	5e                   	pop    %esi
f01035d8:	5f                   	pop    %edi
f01035d9:	5d                   	pop    %ebp
f01035da:	c3                   	ret    

f01035db <user_mem_assert>:
{
f01035db:	55                   	push   %ebp
f01035dc:	89 e5                	mov    %esp,%ebp
f01035de:	53                   	push   %ebx
f01035df:	83 ec 14             	sub    $0x14,%esp
f01035e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01035e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01035e8:	83 c8 04             	or     $0x4,%eax
f01035eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035ef:	8b 45 10             	mov    0x10(%ebp),%eax
f01035f2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035fd:	89 1c 24             	mov    %ebx,(%esp)
f0103600:	e8 fc fe ff ff       	call   f0103501 <user_mem_check>
f0103605:	85 c0                	test   %eax,%eax
f0103607:	79 24                	jns    f010362d <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103609:	a1 3c 12 20 f0       	mov    0xf020123c,%eax
f010360e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103612:	8b 43 48             	mov    0x48(%ebx),%eax
f0103615:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103619:	c7 04 24 e4 7f 10 f0 	movl   $0xf0107fe4,(%esp)
f0103620:	e8 78 09 00 00       	call   f0103f9d <cprintf>
		env_destroy(env);	// may not return
f0103625:	89 1c 24             	mov    %ebx,(%esp)
f0103628:	e8 78 06 00 00       	call   f0103ca5 <env_destroy>
}
f010362d:	83 c4 14             	add    $0x14,%esp
f0103630:	5b                   	pop    %ebx
f0103631:	5d                   	pop    %ebp
f0103632:	c3                   	ret    

f0103633 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103633:	55                   	push   %ebp
f0103634:	89 e5                	mov    %esp,%ebp
f0103636:	57                   	push   %edi
f0103637:	56                   	push   %esi
f0103638:	53                   	push   %ebx
f0103639:	83 ec 1c             	sub    $0x1c,%esp
f010363c:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	unsigned start = ROUNDDOWN((unsigned)va, PGSIZE);
f010363e:	89 d3                	mov    %edx,%ebx
f0103640:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	unsigned end = ROUNDUP((unsigned)va + len, PGSIZE);
f0103646:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f010364d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for(; start < end; start += PGSIZE){
f0103653:	39 f3                	cmp    %esi,%ebx
f0103655:	73 71                	jae    f01036c8 <region_alloc+0x95>
		struct PageInfo *page = page_alloc(0); //不需要ALLOC_ZERO
f0103657:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010365e:	e8 0d db ff ff       	call   f0101170 <page_alloc>
		if(!page)
f0103663:	85 c0                	test   %eax,%eax
f0103665:	75 1c                	jne    f0103683 <region_alloc+0x50>
			panic("region_alloc: page_alloc error");
f0103667:	c7 44 24 08 1c 80 10 	movl   $0xf010801c,0x8(%esp)
f010366e:	f0 
f010366f:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
f0103676:	00 
f0103677:	c7 04 24 b3 80 10 f0 	movl   $0xf01080b3,(%esp)
f010367e:	e8 bd c9 ff ff       	call   f0100040 <_panic>
		int result = page_insert(e->env_pgdir, page, (void *)start, PTE_U | PTE_W);
f0103683:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010368a:	00 
f010368b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010368f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103693:	8b 47 60             	mov    0x60(%edi),%eax
f0103696:	89 04 24             	mov    %eax,(%esp)
f0103699:	e8 ad dd ff ff       	call   f010144b <page_insert>
		if(result < 0)
f010369e:	85 c0                	test   %eax,%eax
f01036a0:	79 1c                	jns    f01036be <region_alloc+0x8b>
			panic("region_alloc: page_insert error");
f01036a2:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f01036a9:	f0 
f01036aa:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
f01036b1:	00 
f01036b2:	c7 04 24 b3 80 10 f0 	movl   $0xf01080b3,(%esp)
f01036b9:	e8 82 c9 ff ff       	call   f0100040 <_panic>
	for(; start < end; start += PGSIZE){
f01036be:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01036c4:	39 de                	cmp    %ebx,%esi
f01036c6:	77 8f                	ja     f0103657 <region_alloc+0x24>
	}
}
f01036c8:	83 c4 1c             	add    $0x1c,%esp
f01036cb:	5b                   	pop    %ebx
f01036cc:	5e                   	pop    %esi
f01036cd:	5f                   	pop    %edi
f01036ce:	5d                   	pop    %ebp
f01036cf:	c3                   	ret    

f01036d0 <envid2env>:
{
f01036d0:	55                   	push   %ebp
f01036d1:	89 e5                	mov    %esp,%ebp
f01036d3:	56                   	push   %esi
f01036d4:	53                   	push   %ebx
f01036d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01036d8:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f01036db:	85 c0                	test   %eax,%eax
f01036dd:	75 1a                	jne    f01036f9 <envid2env+0x29>
		*env_store = curenv;
f01036df:	e8 8f 30 00 00       	call   f0106773 <cpunum>
f01036e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01036e7:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f01036ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01036f0:	89 01                	mov    %eax,(%ecx)
		return 0;
f01036f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01036f7:	eb 70                	jmp    f0103769 <envid2env+0x99>
	e = &envs[ENVX(envid)];
f01036f9:	89 c3                	mov    %eax,%ebx
f01036fb:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103701:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103704:	03 1d 48 12 20 f0    	add    0xf0201248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010370a:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010370e:	74 05                	je     f0103715 <envid2env+0x45>
f0103710:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103713:	74 10                	je     f0103725 <envid2env+0x55>
		*env_store = 0;
f0103715:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103718:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010371e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103723:	eb 44                	jmp    f0103769 <envid2env+0x99>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103725:	84 d2                	test   %dl,%dl
f0103727:	74 36                	je     f010375f <envid2env+0x8f>
f0103729:	e8 45 30 00 00       	call   f0106773 <cpunum>
f010372e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103731:	39 98 28 20 20 f0    	cmp    %ebx,-0xfdfdfd8(%eax)
f0103737:	74 26                	je     f010375f <envid2env+0x8f>
f0103739:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010373c:	e8 32 30 00 00       	call   f0106773 <cpunum>
f0103741:	6b c0 74             	imul   $0x74,%eax,%eax
f0103744:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f010374a:	3b 70 48             	cmp    0x48(%eax),%esi
f010374d:	74 10                	je     f010375f <envid2env+0x8f>
		*env_store = 0;
f010374f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103752:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103758:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010375d:	eb 0a                	jmp    f0103769 <envid2env+0x99>
	*env_store = e;
f010375f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103762:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103764:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103769:	5b                   	pop    %ebx
f010376a:	5e                   	pop    %esi
f010376b:	5d                   	pop    %ebp
f010376c:	c3                   	ret    

f010376d <env_init_percpu>:
{
f010376d:	55                   	push   %ebp
f010376e:	89 e5                	mov    %esp,%ebp
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103770:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f0103775:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103778:	b8 23 00 00 00       	mov    $0x23,%eax
f010377d:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010377f:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103781:	b0 10                	mov    $0x10,%al
f0103783:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103785:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103787:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103789:	ea 90 37 10 f0 08 00 	ljmp   $0x8,$0xf0103790
	__asm __volatile("lldt %0" : : "r" (sel));
f0103790:	b0 00                	mov    $0x0,%al
f0103792:	0f 00 d0             	lldt   %ax
}
f0103795:	5d                   	pop    %ebp
f0103796:	c3                   	ret    

f0103797 <env_init>:
{
f0103797:	55                   	push   %ebp
f0103798:	89 e5                	mov    %esp,%ebp
f010379a:	56                   	push   %esi
f010379b:	53                   	push   %ebx
		envs[i].env_status = ENV_FREE;
f010379c:	8b 35 48 12 20 f0    	mov    0xf0201248,%esi
f01037a2:	8b 0d 4c 12 20 f0    	mov    0xf020124c,%ecx
f01037a8:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01037ae:	ba 00 04 00 00       	mov    $0x400,%edx
f01037b3:	89 c3                	mov    %eax,%ebx
f01037b5:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f01037bc:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01037c3:	89 48 44             	mov    %ecx,0x44(%eax)
f01037c6:	83 e8 7c             	sub    $0x7c,%eax
	for(i = NENV - 1; i >= 0; --i){
f01037c9:	83 ea 01             	sub    $0x1,%edx
f01037cc:	74 04                	je     f01037d2 <env_init+0x3b>
		env_free_list = &envs[i];
f01037ce:	89 d9                	mov    %ebx,%ecx
f01037d0:	eb e1                	jmp    f01037b3 <env_init+0x1c>
f01037d2:	89 35 4c 12 20 f0    	mov    %esi,0xf020124c
	env_init_percpu();
f01037d8:	e8 90 ff ff ff       	call   f010376d <env_init_percpu>
}
f01037dd:	5b                   	pop    %ebx
f01037de:	5e                   	pop    %esi
f01037df:	5d                   	pop    %ebp
f01037e0:	c3                   	ret    

f01037e1 <env_alloc>:
{
f01037e1:	55                   	push   %ebp
f01037e2:	89 e5                	mov    %esp,%ebp
f01037e4:	53                   	push   %ebx
f01037e5:	83 ec 14             	sub    $0x14,%esp
	if (!(e = env_free_list))
f01037e8:	8b 1d 4c 12 20 f0    	mov    0xf020124c,%ebx
f01037ee:	85 db                	test   %ebx,%ebx
f01037f0:	0f 84 58 01 00 00    	je     f010394e <env_alloc+0x16d>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01037f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01037fd:	e8 6e d9 ff ff       	call   f0101170 <page_alloc>
f0103802:	85 c0                	test   %eax,%eax
f0103804:	0f 84 4b 01 00 00    	je     f0103955 <env_alloc+0x174>
	return (pp - pages) << PGSHIFT;
f010380a:	89 c2                	mov    %eax,%edx
f010380c:	2b 15 90 1e 20 f0    	sub    0xf0201e90,%edx
f0103812:	c1 fa 03             	sar    $0x3,%edx
f0103815:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103818:	89 d1                	mov    %edx,%ecx
f010381a:	c1 e9 0c             	shr    $0xc,%ecx
f010381d:	3b 0d 88 1e 20 f0    	cmp    0xf0201e88,%ecx
f0103823:	72 20                	jb     f0103845 <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103825:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103829:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f0103830:	f0 
f0103831:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103838:	00 
f0103839:	c7 04 24 4b 74 10 f0 	movl   $0xf010744b,(%esp)
f0103840:	e8 fb c7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103845:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010384b:	89 53 60             	mov    %edx,0x60(%ebx)
	p->pp_ref = 1;
f010384e:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
f0103854:	b8 ec 0e 00 00       	mov    $0xeec,%eax
		e->env_pgdir[i] = kern_pgdir[i];
f0103859:	8b 15 8c 1e 20 f0    	mov    0xf0201e8c,%edx
f010385f:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103862:	8b 53 60             	mov    0x60(%ebx),%edx
f0103865:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103868:	83 c0 04             	add    $0x4,%eax
	for(i = PDX(UTOP); i < NPDENTRIES; ++i)
f010386b:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103870:	75 e7                	jne    f0103859 <env_alloc+0x78>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103872:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103875:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010387a:	77 20                	ja     f010389c <env_alloc+0xbb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010387c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103880:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0103887:	f0 
f0103888:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f010388f:	00 
f0103890:	c7 04 24 b3 80 10 f0 	movl   $0xf01080b3,(%esp)
f0103897:	e8 a4 c7 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010389c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01038a2:	83 ca 05             	or     $0x5,%edx
f01038a5:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01038ab:	8b 43 48             	mov    0x48(%ebx),%eax
f01038ae:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01038b3:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01038b8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01038bd:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01038c0:	89 da                	mov    %ebx,%edx
f01038c2:	2b 15 48 12 20 f0    	sub    0xf0201248,%edx
f01038c8:	c1 fa 02             	sar    $0x2,%edx
f01038cb:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01038d1:	09 d0                	or     %edx,%eax
f01038d3:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f01038d6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038d9:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01038dc:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01038e3:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01038ea:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01038f1:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01038f8:	00 
f01038f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103900:	00 
f0103901:	89 1c 24             	mov    %ebx,(%esp)
f0103904:	e8 d0 27 00 00       	call   f01060d9 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103909:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010390f:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103915:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010391b:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103922:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f0103928:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f010392f:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103936:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f010393a:	8b 43 44             	mov    0x44(%ebx),%eax
f010393d:	a3 4c 12 20 f0       	mov    %eax,0xf020124c
	*newenv_store = e;
f0103942:	8b 45 08             	mov    0x8(%ebp),%eax
f0103945:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103947:	b8 00 00 00 00       	mov    $0x0,%eax
f010394c:	eb 0c                	jmp    f010395a <env_alloc+0x179>
		return -E_NO_FREE_ENV;
f010394e:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103953:	eb 05                	jmp    f010395a <env_alloc+0x179>
		return -E_NO_MEM;
f0103955:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f010395a:	83 c4 14             	add    $0x14,%esp
f010395d:	5b                   	pop    %ebx
f010395e:	5d                   	pop    %ebp
f010395f:	c3                   	ret    

f0103960 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103960:	55                   	push   %ebp
f0103961:	89 e5                	mov    %esp,%ebp
f0103963:	57                   	push   %edi
f0103964:	56                   	push   %esi
f0103965:	53                   	push   %ebx
f0103966:	83 ec 3c             	sub    $0x3c,%esp
f0103969:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *env;
	int result = env_alloc(&env, 0);
f010396c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103973:	00 
f0103974:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103977:	89 04 24             	mov    %eax,(%esp)
f010397a:	e8 62 fe ff ff       	call   f01037e1 <env_alloc>
	if(result < 0)
f010397f:	85 c0                	test   %eax,%eax
f0103981:	79 1c                	jns    f010399f <env_create+0x3f>
		panic("env_create: env_alloc error");
f0103983:	c7 44 24 08 be 80 10 	movl   $0xf01080be,0x8(%esp)
f010398a:	f0 
f010398b:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
f0103992:	00 
f0103993:	c7 04 24 b3 80 10 f0 	movl   $0xf01080b3,(%esp)
f010399a:	e8 a1 c6 ff ff       	call   f0100040 <_panic>
	load_icode(env, binary, size);
f010399f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if(ELF_MAGIC != elf->e_magic)
f01039a5:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01039ab:	74 1c                	je     f01039c9 <env_create+0x69>
		panic("load icode: e_magic is not equal to ELF_MAGIC");
f01039ad:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f01039b4:	f0 
f01039b5:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
f01039bc:	00 
f01039bd:	c7 04 24 b3 80 10 f0 	movl   $0xf01080b3,(%esp)
f01039c4:	e8 77 c6 ff ff       	call   f0100040 <_panic>
	if(!elf->e_entry)
f01039c9:	8b 47 18             	mov    0x18(%edi),%eax
f01039cc:	85 c0                	test   %eax,%eax
f01039ce:	75 1c                	jne    f01039ec <env_create+0x8c>
		panic("load icode: e_entry is NULL");
f01039d0:	c7 44 24 08 da 80 10 	movl   $0xf01080da,0x8(%esp)
f01039d7:	f0 
f01039d8:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
f01039df:	00 
f01039e0:	c7 04 24 b3 80 10 f0 	movl   $0xf01080b3,(%esp)
f01039e7:	e8 54 c6 ff ff       	call   f0100040 <_panic>
	e->env_tf.tf_eip = elf->e_entry;
f01039ec:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01039ef:	89 41 30             	mov    %eax,0x30(%ecx)
	struct Proghdr *ph = (struct Proghdr *)(binary + elf->e_phoff);
f01039f2:	89 fb                	mov    %edi,%ebx
f01039f4:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr *eph = ph + elf->e_phnum;
f01039f7:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01039fb:	c1 e6 05             	shl    $0x5,%esi
f01039fe:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));
f0103a00:	8b 41 60             	mov    0x60(%ecx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103a03:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a08:	77 20                	ja     f0103a2a <env_create+0xca>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a0e:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0103a15:	f0 
f0103a16:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
f0103a1d:	00 
f0103a1e:	c7 04 24 b3 80 10 f0 	movl   $0xf01080b3,(%esp)
f0103a25:	e8 16 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a2a:	05 00 00 00 10       	add    $0x10000000,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103a2f:	0f 22 d8             	mov    %eax,%cr3
	for(; ph < eph; ++ph)
f0103a32:	39 f3                	cmp    %esi,%ebx
f0103a34:	73 75                	jae    f0103aab <env_create+0x14b>
		if(ELF_PROG_LOAD == ph->p_type){
f0103a36:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103a39:	75 69                	jne    f0103aa4 <env_create+0x144>
			if(ph->p_filesz > ph->p_memsz)
f0103a3b:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103a3e:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103a41:	76 1c                	jbe    f0103a5f <env_create+0xff>
				panic("load icode: ph->p_filesz > ph->p_memsz");
f0103a43:	c7 44 24 08 8c 80 10 	movl   $0xf010808c,0x8(%esp)
f0103a4a:	f0 
f0103a4b:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f0103a52:	00 
f0103a53:	c7 04 24 b3 80 10 f0 	movl   $0xf01080b3,(%esp)
f0103a5a:	e8 e1 c5 ff ff       	call   f0100040 <_panic>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103a5f:	8b 53 08             	mov    0x8(%ebx),%edx
f0103a62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a65:	e8 c9 fb ff ff       	call   f0103633 <region_alloc>
			memmove((char *)ph->p_va, (void *)(binary + ph->p_offset), ph->p_filesz);
f0103a6a:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a6d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a71:	89 f8                	mov    %edi,%eax
f0103a73:	03 43 04             	add    0x4(%ebx),%eax
f0103a76:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a7a:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a7d:	89 04 24             	mov    %eax,(%esp)
f0103a80:	e8 a1 26 00 00       	call   f0106126 <memmove>
			memset((char *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f0103a85:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a88:	8b 53 14             	mov    0x14(%ebx),%edx
f0103a8b:	29 c2                	sub    %eax,%edx
f0103a8d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103a91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a98:	00 
f0103a99:	03 43 08             	add    0x8(%ebx),%eax
f0103a9c:	89 04 24             	mov    %eax,(%esp)
f0103a9f:	e8 35 26 00 00       	call   f01060d9 <memset>
	for(; ph < eph; ++ph)
f0103aa4:	83 c3 20             	add    $0x20,%ebx
f0103aa7:	39 de                	cmp    %ebx,%esi
f0103aa9:	77 8b                	ja     f0103a36 <env_create+0xd6>
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103aab:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103ab0:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103ab5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103ab8:	e8 76 fb ff ff       	call   f0103633 <region_alloc>
	env->env_type = type;
f0103abd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ac0:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103ac3:	89 78 50             	mov    %edi,0x50(%eax)
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	if(type == ENV_TYPE_FS)
f0103ac6:	83 ff 01             	cmp    $0x1,%edi
f0103ac9:	75 07                	jne    f0103ad2 <env_create+0x172>
		env->env_tf.tf_eflags |= FL_IOPL_MASK;
f0103acb:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
}
f0103ad2:	83 c4 3c             	add    $0x3c,%esp
f0103ad5:	5b                   	pop    %ebx
f0103ad6:	5e                   	pop    %esi
f0103ad7:	5f                   	pop    %edi
f0103ad8:	5d                   	pop    %ebp
f0103ad9:	c3                   	ret    

f0103ada <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103ada:	55                   	push   %ebp
f0103adb:	89 e5                	mov    %esp,%ebp
f0103add:	57                   	push   %edi
f0103ade:	56                   	push   %esi
f0103adf:	53                   	push   %ebx
f0103ae0:	83 ec 2c             	sub    $0x2c,%esp
f0103ae3:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103ae6:	e8 88 2c 00 00       	call   f0106773 <cpunum>
f0103aeb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103aee:	39 b8 28 20 20 f0    	cmp    %edi,-0xfdfdfd8(%eax)
f0103af4:	74 09                	je     f0103aff <env_free+0x25>
{
f0103af6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103afd:	eb 36                	jmp    f0103b35 <env_free+0x5b>
		lcr3(PADDR(kern_pgdir));
f0103aff:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103b04:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103b09:	77 20                	ja     f0103b2b <env_free+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b0f:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0103b16:	f0 
f0103b17:	c7 44 24 04 af 01 00 	movl   $0x1af,0x4(%esp)
f0103b1e:	00 
f0103b1f:	c7 04 24 b3 80 10 f0 	movl   $0xf01080b3,(%esp)
f0103b26:	e8 15 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103b2b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103b30:	0f 22 d8             	mov    %eax,%cr3
f0103b33:	eb c1                	jmp    f0103af6 <env_free+0x1c>
f0103b35:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103b38:	89 c8                	mov    %ecx,%eax
f0103b3a:	c1 e0 02             	shl    $0x2,%eax
f0103b3d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b40:	8b 47 60             	mov    0x60(%edi),%eax
f0103b43:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103b46:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103b4c:	0f 84 b7 00 00 00    	je     f0103c09 <env_free+0x12f>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b52:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0103b58:	89 f0                	mov    %esi,%eax
f0103b5a:	c1 e8 0c             	shr    $0xc,%eax
f0103b5d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b60:	3b 05 88 1e 20 f0    	cmp    0xf0201e88,%eax
f0103b66:	72 20                	jb     f0103b88 <env_free+0xae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b68:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b6c:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f0103b73:	f0 
f0103b74:	c7 44 24 04 be 01 00 	movl   $0x1be,0x4(%esp)
f0103b7b:	00 
f0103b7c:	c7 04 24 b3 80 10 f0 	movl   $0xf01080b3,(%esp)
f0103b83:	e8 b8 c4 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b88:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b8b:	c1 e0 16             	shl    $0x16,%eax
f0103b8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b91:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103b96:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103b9d:	01 
f0103b9e:	74 17                	je     f0103bb7 <env_free+0xdd>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103ba0:	89 d8                	mov    %ebx,%eax
f0103ba2:	c1 e0 0c             	shl    $0xc,%eax
f0103ba5:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bac:	8b 47 60             	mov    0x60(%edi),%eax
f0103baf:	89 04 24             	mov    %eax,(%esp)
f0103bb2:	e8 44 d8 ff ff       	call   f01013fb <page_remove>
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103bb7:	83 c3 01             	add    $0x1,%ebx
f0103bba:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103bc0:	75 d4                	jne    f0103b96 <env_free+0xbc>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103bc2:	8b 47 60             	mov    0x60(%edi),%eax
f0103bc5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103bc8:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103bcf:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103bd2:	3b 05 88 1e 20 f0    	cmp    0xf0201e88,%eax
f0103bd8:	72 1c                	jb     f0103bf6 <env_free+0x11c>
		panic("pa2page called with invalid pa");
f0103bda:	c7 44 24 08 f4 77 10 	movl   $0xf01077f4,0x8(%esp)
f0103be1:	f0 
f0103be2:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103be9:	00 
f0103bea:	c7 04 24 4b 74 10 f0 	movl   $0xf010744b,(%esp)
f0103bf1:	e8 4a c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103bf6:	a1 90 1e 20 f0       	mov    0xf0201e90,%eax
f0103bfb:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103bfe:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103c01:	89 04 24             	mov    %eax,(%esp)
f0103c04:	e8 12 d6 ff ff       	call   f010121b <page_decref>
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103c09:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103c0d:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103c14:	0f 85 1b ff ff ff    	jne    f0103b35 <env_free+0x5b>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103c1a:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103c1d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c22:	77 20                	ja     f0103c44 <env_free+0x16a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c24:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c28:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0103c2f:	f0 
f0103c30:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
f0103c37:	00 
f0103c38:	c7 04 24 b3 80 10 f0 	movl   $0xf01080b3,(%esp)
f0103c3f:	e8 fc c3 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103c44:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103c4b:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103c50:	c1 e8 0c             	shr    $0xc,%eax
f0103c53:	3b 05 88 1e 20 f0    	cmp    0xf0201e88,%eax
f0103c59:	72 1c                	jb     f0103c77 <env_free+0x19d>
		panic("pa2page called with invalid pa");
f0103c5b:	c7 44 24 08 f4 77 10 	movl   $0xf01077f4,0x8(%esp)
f0103c62:	f0 
f0103c63:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c6a:	00 
f0103c6b:	c7 04 24 4b 74 10 f0 	movl   $0xf010744b,(%esp)
f0103c72:	e8 c9 c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c77:	8b 15 90 1e 20 f0    	mov    0xf0201e90,%edx
f0103c7d:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103c80:	89 04 24             	mov    %eax,(%esp)
f0103c83:	e8 93 d5 ff ff       	call   f010121b <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c88:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103c8f:	a1 4c 12 20 f0       	mov    0xf020124c,%eax
f0103c94:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103c97:	89 3d 4c 12 20 f0    	mov    %edi,0xf020124c
}
f0103c9d:	83 c4 2c             	add    $0x2c,%esp
f0103ca0:	5b                   	pop    %ebx
f0103ca1:	5e                   	pop    %esi
f0103ca2:	5f                   	pop    %edi
f0103ca3:	5d                   	pop    %ebp
f0103ca4:	c3                   	ret    

f0103ca5 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103ca5:	55                   	push   %ebp
f0103ca6:	89 e5                	mov    %esp,%ebp
f0103ca8:	53                   	push   %ebx
f0103ca9:	83 ec 14             	sub    $0x14,%esp
f0103cac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103caf:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103cb3:	75 19                	jne    f0103cce <env_destroy+0x29>
f0103cb5:	e8 b9 2a 00 00       	call   f0106773 <cpunum>
f0103cba:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cbd:	39 98 28 20 20 f0    	cmp    %ebx,-0xfdfdfd8(%eax)
f0103cc3:	74 09                	je     f0103cce <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103cc5:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103ccc:	eb 2f                	jmp    f0103cfd <env_destroy+0x58>
	}

	env_free(e);
f0103cce:	89 1c 24             	mov    %ebx,(%esp)
f0103cd1:	e8 04 fe ff ff       	call   f0103ada <env_free>

	if (curenv == e) {
f0103cd6:	e8 98 2a 00 00       	call   f0106773 <cpunum>
f0103cdb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cde:	39 98 28 20 20 f0    	cmp    %ebx,-0xfdfdfd8(%eax)
f0103ce4:	75 17                	jne    f0103cfd <env_destroy+0x58>
		curenv = NULL;
f0103ce6:	e8 88 2a 00 00       	call   f0106773 <cpunum>
f0103ceb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cee:	c7 80 28 20 20 f0 00 	movl   $0x0,-0xfdfdfd8(%eax)
f0103cf5:	00 00 00 
		sched_yield();
f0103cf8:	e8 8a 0f 00 00       	call   f0104c87 <sched_yield>
	}
}
f0103cfd:	83 c4 14             	add    $0x14,%esp
f0103d00:	5b                   	pop    %ebx
f0103d01:	5d                   	pop    %ebp
f0103d02:	c3                   	ret    

f0103d03 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103d03:	55                   	push   %ebp
f0103d04:	89 e5                	mov    %esp,%ebp
f0103d06:	53                   	push   %ebx
f0103d07:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103d0a:	e8 64 2a 00 00       	call   f0106773 <cpunum>
f0103d0f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d12:	8b 98 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%ebx
f0103d18:	e8 56 2a 00 00       	call   f0106773 <cpunum>
f0103d1d:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103d20:	8b 65 08             	mov    0x8(%ebp),%esp
f0103d23:	61                   	popa   
f0103d24:	07                   	pop    %es
f0103d25:	1f                   	pop    %ds
f0103d26:	83 c4 08             	add    $0x8,%esp
f0103d29:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103d2a:	c7 44 24 08 f6 80 10 	movl   $0xf01080f6,0x8(%esp)
f0103d31:	f0 
f0103d32:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
f0103d39:	00 
f0103d3a:	c7 04 24 b3 80 10 f0 	movl   $0xf01080b3,(%esp)
f0103d41:	e8 fa c2 ff ff       	call   f0100040 <_panic>

f0103d46 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d46:	55                   	push   %ebp
f0103d47:	89 e5                	mov    %esp,%ebp
f0103d49:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// 修改原来的env状态
	if(curenv && ENV_RUNNING == curenv->env_status){
f0103d4c:	e8 22 2a 00 00       	call   f0106773 <cpunum>
f0103d51:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d54:	83 b8 28 20 20 f0 00 	cmpl   $0x0,-0xfdfdfd8(%eax)
f0103d5b:	74 3b                	je     f0103d98 <env_run+0x52>
f0103d5d:	e8 11 2a 00 00       	call   f0106773 <cpunum>
f0103d62:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d65:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0103d6b:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d6f:	75 27                	jne    f0103d98 <env_run+0x52>
		curenv->env_status = ENV_RUNNABLE;
f0103d71:	e8 fd 29 00 00       	call   f0106773 <cpunum>
f0103d76:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d79:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0103d7f:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv->env_runs--;
f0103d86:	e8 e8 29 00 00       	call   f0106773 <cpunum>
f0103d8b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d8e:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0103d94:	83 68 58 01          	subl   $0x1,0x58(%eax)
	}
	// 修改curenv为当前env并且修改状态
	curenv = e;
f0103d98:	e8 d6 29 00 00       	call   f0106773 <cpunum>
f0103d9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103da0:	8b 55 08             	mov    0x8(%ebp),%edx
f0103da3:	89 90 28 20 20 f0    	mov    %edx,-0xfdfdfd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103da9:	e8 c5 29 00 00       	call   f0106773 <cpunum>
f0103dae:	6b c0 74             	imul   $0x74,%eax,%eax
f0103db1:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0103db7:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103dbe:	e8 b0 29 00 00       	call   f0106773 <cpunum>
f0103dc3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dc6:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0103dcc:	83 40 58 01          	addl   $0x1,0x58(%eax)
	// 切换地址空间，恢复寄存器
	lcr3(PADDR(curenv->env_pgdir));
f0103dd0:	e8 9e 29 00 00       	call   f0106773 <cpunum>
f0103dd5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dd8:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0103dde:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103de1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103de6:	77 20                	ja     f0103e08 <env_run+0xc2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103de8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103dec:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0103df3:	f0 
f0103df4:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
f0103dfb:	00 
f0103dfc:	c7 04 24 b3 80 10 f0 	movl   $0xf01080b3,(%esp)
f0103e03:	e8 38 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103e08:	05 00 00 00 10       	add    $0x10000000,%eax
f0103e0d:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103e10:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0103e17:	e8 ab 2c 00 00       	call   f0106ac7 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103e1c:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f0103e1e:	e8 50 29 00 00       	call   f0106773 <cpunum>
f0103e23:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e26:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0103e2c:	89 04 24             	mov    %eax,(%esp)
f0103e2f:	e8 cf fe ff ff       	call   f0103d03 <env_pop_tf>

f0103e34 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e34:	55                   	push   %ebp
f0103e35:	89 e5                	mov    %esp,%ebp
f0103e37:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e3b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e40:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e41:	b2 71                	mov    $0x71,%dl
f0103e43:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e44:	0f b6 c0             	movzbl %al,%eax
}
f0103e47:	5d                   	pop    %ebp
f0103e48:	c3                   	ret    

f0103e49 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e49:	55                   	push   %ebp
f0103e4a:	89 e5                	mov    %esp,%ebp
f0103e4c:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e50:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e55:	ee                   	out    %al,(%dx)
f0103e56:	b2 71                	mov    $0x71,%dl
f0103e58:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e5b:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e5c:	5d                   	pop    %ebp
f0103e5d:	c3                   	ret    

f0103e5e <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e5e:	55                   	push   %ebp
f0103e5f:	89 e5                	mov    %esp,%ebp
f0103e61:	56                   	push   %esi
f0103e62:	53                   	push   %ebx
f0103e63:	83 ec 10             	sub    $0x10,%esp
f0103e66:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103e69:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103e6f:	80 3d 50 12 20 f0 00 	cmpb   $0x0,0xf0201250
f0103e76:	74 4e                	je     f0103ec6 <irq_setmask_8259A+0x68>
f0103e78:	89 c6                	mov    %eax,%esi
f0103e7a:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e7f:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e80:	66 c1 e8 08          	shr    $0x8,%ax
f0103e84:	b2 a1                	mov    $0xa1,%dl
f0103e86:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e87:	c7 04 24 02 81 10 f0 	movl   $0xf0108102,(%esp)
f0103e8e:	e8 0a 01 00 00       	call   f0103f9d <cprintf>
	for (i = 0; i < 16; i++)
f0103e93:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e98:	0f b7 f6             	movzwl %si,%esi
f0103e9b:	f7 d6                	not    %esi
f0103e9d:	0f a3 de             	bt     %ebx,%esi
f0103ea0:	73 10                	jae    f0103eb2 <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f0103ea2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103ea6:	c7 04 24 df 85 10 f0 	movl   $0xf01085df,(%esp)
f0103ead:	e8 eb 00 00 00       	call   f0103f9d <cprintf>
	for (i = 0; i < 16; i++)
f0103eb2:	83 c3 01             	add    $0x1,%ebx
f0103eb5:	83 fb 10             	cmp    $0x10,%ebx
f0103eb8:	75 e3                	jne    f0103e9d <irq_setmask_8259A+0x3f>
	cprintf("\n");
f0103eba:	c7 04 24 fe 76 10 f0 	movl   $0xf01076fe,(%esp)
f0103ec1:	e8 d7 00 00 00       	call   f0103f9d <cprintf>
}
f0103ec6:	83 c4 10             	add    $0x10,%esp
f0103ec9:	5b                   	pop    %ebx
f0103eca:	5e                   	pop    %esi
f0103ecb:	5d                   	pop    %ebp
f0103ecc:	c3                   	ret    

f0103ecd <pic_init>:
	didinit = 1;
f0103ecd:	c6 05 50 12 20 f0 01 	movb   $0x1,0xf0201250
f0103ed4:	ba 21 00 00 00       	mov    $0x21,%edx
f0103ed9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ede:	ee                   	out    %al,(%dx)
f0103edf:	b2 a1                	mov    $0xa1,%dl
f0103ee1:	ee                   	out    %al,(%dx)
f0103ee2:	b2 20                	mov    $0x20,%dl
f0103ee4:	b8 11 00 00 00       	mov    $0x11,%eax
f0103ee9:	ee                   	out    %al,(%dx)
f0103eea:	b2 21                	mov    $0x21,%dl
f0103eec:	b8 20 00 00 00       	mov    $0x20,%eax
f0103ef1:	ee                   	out    %al,(%dx)
f0103ef2:	b8 04 00 00 00       	mov    $0x4,%eax
f0103ef7:	ee                   	out    %al,(%dx)
f0103ef8:	b8 03 00 00 00       	mov    $0x3,%eax
f0103efd:	ee                   	out    %al,(%dx)
f0103efe:	b2 a0                	mov    $0xa0,%dl
f0103f00:	b8 11 00 00 00       	mov    $0x11,%eax
f0103f05:	ee                   	out    %al,(%dx)
f0103f06:	b2 a1                	mov    $0xa1,%dl
f0103f08:	b8 28 00 00 00       	mov    $0x28,%eax
f0103f0d:	ee                   	out    %al,(%dx)
f0103f0e:	b8 02 00 00 00       	mov    $0x2,%eax
f0103f13:	ee                   	out    %al,(%dx)
f0103f14:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f19:	ee                   	out    %al,(%dx)
f0103f1a:	b2 20                	mov    $0x20,%dl
f0103f1c:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f21:	ee                   	out    %al,(%dx)
f0103f22:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f27:	ee                   	out    %al,(%dx)
f0103f28:	b2 a0                	mov    $0xa0,%dl
f0103f2a:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f2f:	ee                   	out    %al,(%dx)
f0103f30:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f35:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103f36:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103f3d:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f41:	74 12                	je     f0103f55 <pic_init+0x88>
{
f0103f43:	55                   	push   %ebp
f0103f44:	89 e5                	mov    %esp,%ebp
f0103f46:	83 ec 18             	sub    $0x18,%esp
		irq_setmask_8259A(irq_mask_8259A);
f0103f49:	0f b7 c0             	movzwl %ax,%eax
f0103f4c:	89 04 24             	mov    %eax,(%esp)
f0103f4f:	e8 0a ff ff ff       	call   f0103e5e <irq_setmask_8259A>
}
f0103f54:	c9                   	leave  
f0103f55:	f3 c3                	repz ret 

f0103f57 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f57:	55                   	push   %ebp
f0103f58:	89 e5                	mov    %esp,%ebp
f0103f5a:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103f5d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f60:	89 04 24             	mov    %eax,(%esp)
f0103f63:	e8 7f c8 ff ff       	call   f01007e7 <cputchar>
	*cnt++;
}
f0103f68:	c9                   	leave  
f0103f69:	c3                   	ret    

f0103f6a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f6a:	55                   	push   %ebp
f0103f6b:	89 e5                	mov    %esp,%ebp
f0103f6d:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103f70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f77:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f7e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f81:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f85:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f88:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f8c:	c7 04 24 57 3f 10 f0 	movl   $0xf0103f57,(%esp)
f0103f93:	e8 ec 19 00 00       	call   f0105984 <vprintfmt>
	return cnt;
}
f0103f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f9b:	c9                   	leave  
f0103f9c:	c3                   	ret    

f0103f9d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f9d:	55                   	push   %ebp
f0103f9e:	89 e5                	mov    %esp,%ebp
f0103fa0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103fa3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103fa6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103faa:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fad:	89 04 24             	mov    %eax,(%esp)
f0103fb0:	e8 b5 ff ff ff       	call   f0103f6a <vcprintf>
	va_end(ap);

	return cnt;
}
f0103fb5:	c9                   	leave  
f0103fb6:	c3                   	ret    
f0103fb7:	66 90                	xchg   %ax,%ax
f0103fb9:	66 90                	xchg   %ax,%ax
f0103fbb:	66 90                	xchg   %ax,%ax
f0103fbd:	66 90                	xchg   %ax,%ax
f0103fbf:	90                   	nop

f0103fc0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103fc0:	55                   	push   %ebp
f0103fc1:	89 e5                	mov    %esp,%ebp
f0103fc3:	57                   	push   %edi
f0103fc4:	56                   	push   %esi
f0103fc5:	53                   	push   %ebx
f0103fc6:	83 ec 1c             	sub    $0x1c,%esp
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	int cpu_id = thiscpu->cpu_id;
f0103fc9:	e8 a5 27 00 00       	call   f0106773 <cpunum>
f0103fce:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fd1:	0f b6 80 20 20 20 f0 	movzbl -0xfdfdfe0(%eax),%eax
f0103fd8:	88 45 e7             	mov    %al,-0x19(%ebp)
f0103fdb:	0f b6 d8             	movzbl %al,%ebx
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id * (KSTKSIZE + KSTKGAP);
f0103fde:	e8 90 27 00 00       	call   f0106773 <cpunum>
f0103fe3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fe6:	89 da                	mov    %ebx,%edx
f0103fe8:	f7 da                	neg    %edx
f0103fea:	c1 e2 10             	shl    $0x10,%edx
f0103fed:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103ff3:	89 90 30 20 20 f0    	mov    %edx,-0xfdfdfd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103ff9:	e8 75 27 00 00       	call   f0106773 <cpunum>
f0103ffe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104001:	66 c7 80 34 20 20 f0 	movw   $0x10,-0xfdfdfcc(%eax)
f0104008:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts), sizeof(struct Taskstate), 0);
f010400a:	83 c3 05             	add    $0x5,%ebx
f010400d:	e8 61 27 00 00       	call   f0106773 <cpunum>
f0104012:	89 c7                	mov    %eax,%edi
f0104014:	e8 5a 27 00 00       	call   f0106773 <cpunum>
f0104019:	89 c6                	mov    %eax,%esi
f010401b:	e8 53 27 00 00       	call   f0106773 <cpunum>
f0104020:	66 c7 04 dd 40 13 12 	movw   $0x68,-0xfedecc0(,%ebx,8)
f0104027:	f0 68 00 
f010402a:	6b ff 74             	imul   $0x74,%edi,%edi
f010402d:	81 c7 2c 20 20 f0    	add    $0xf020202c,%edi
f0104033:	66 89 3c dd 42 13 12 	mov    %di,-0xfedecbe(,%ebx,8)
f010403a:	f0 
f010403b:	6b d6 74             	imul   $0x74,%esi,%edx
f010403e:	81 c2 2c 20 20 f0    	add    $0xf020202c,%edx
f0104044:	c1 ea 10             	shr    $0x10,%edx
f0104047:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f010404e:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f0104055:	40 
f0104056:	6b c0 74             	imul   $0x74,%eax,%eax
f0104059:	05 2c 20 20 f0       	add    $0xf020202c,%eax
f010405e:	c1 e8 18             	shr    $0x18,%eax
f0104061:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0104068:	c6 04 dd 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%ebx,8)
f010406f:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpu_id << 3));
f0104070:	0f b6 75 e7          	movzbl -0x19(%ebp),%esi
f0104074:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
	__asm __volatile("ltr %0" : : "r" (sel));
f010407b:	0f 00 de             	ltr    %si
	__asm __volatile("lidt (%0)" : : "r" (p));
f010407e:	b8 aa 13 12 f0       	mov    $0xf01213aa,%eax
f0104083:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0104086:	83 c4 1c             	add    $0x1c,%esp
f0104089:	5b                   	pop    %ebx
f010408a:	5e                   	pop    %esi
f010408b:	5f                   	pop    %edi
f010408c:	5d                   	pop    %ebp
f010408d:	c3                   	ret    

f010408e <trap_init>:
{
f010408e:	55                   	push   %ebp
f010408f:	89 e5                	mov    %esp,%ebp
f0104091:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0104094:	b8 08 4b 10 f0       	mov    $0xf0104b08,%eax
f0104099:	66 a3 60 12 20 f0    	mov    %ax,0xf0201260
f010409f:	66 c7 05 62 12 20 f0 	movw   $0x8,0xf0201262
f01040a6:	08 00 
f01040a8:	c6 05 64 12 20 f0 00 	movb   $0x0,0xf0201264
f01040af:	c6 05 65 12 20 f0 8e 	movb   $0x8e,0xf0201265
f01040b6:	c1 e8 10             	shr    $0x10,%eax
f01040b9:	66 a3 66 12 20 f0    	mov    %ax,0xf0201266
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f01040bf:	b8 12 4b 10 f0       	mov    $0xf0104b12,%eax
f01040c4:	66 a3 68 12 20 f0    	mov    %ax,0xf0201268
f01040ca:	66 c7 05 6a 12 20 f0 	movw   $0x8,0xf020126a
f01040d1:	08 00 
f01040d3:	c6 05 6c 12 20 f0 00 	movb   $0x0,0xf020126c
f01040da:	c6 05 6d 12 20 f0 8e 	movb   $0x8e,0xf020126d
f01040e1:	c1 e8 10             	shr    $0x10,%eax
f01040e4:	66 a3 6e 12 20 f0    	mov    %ax,0xf020126e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f01040ea:	b8 18 4b 10 f0       	mov    $0xf0104b18,%eax
f01040ef:	66 a3 70 12 20 f0    	mov    %ax,0xf0201270
f01040f5:	66 c7 05 72 12 20 f0 	movw   $0x8,0xf0201272
f01040fc:	08 00 
f01040fe:	c6 05 74 12 20 f0 00 	movb   $0x0,0xf0201274
f0104105:	c6 05 75 12 20 f0 8e 	movb   $0x8e,0xf0201275
f010410c:	c1 e8 10             	shr    $0x10,%eax
f010410f:	66 a3 76 12 20 f0    	mov    %ax,0xf0201276
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0104115:	b8 1e 4b 10 f0       	mov    $0xf0104b1e,%eax
f010411a:	66 a3 78 12 20 f0    	mov    %ax,0xf0201278
f0104120:	66 c7 05 7a 12 20 f0 	movw   $0x8,0xf020127a
f0104127:	08 00 
f0104129:	c6 05 7c 12 20 f0 00 	movb   $0x0,0xf020127c
f0104130:	c6 05 7d 12 20 f0 ee 	movb   $0xee,0xf020127d
f0104137:	c1 e8 10             	shr    $0x10,%eax
f010413a:	66 a3 7e 12 20 f0    	mov    %ax,0xf020127e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f0104140:	b8 24 4b 10 f0       	mov    $0xf0104b24,%eax
f0104145:	66 a3 80 12 20 f0    	mov    %ax,0xf0201280
f010414b:	66 c7 05 82 12 20 f0 	movw   $0x8,0xf0201282
f0104152:	08 00 
f0104154:	c6 05 84 12 20 f0 00 	movb   $0x0,0xf0201284
f010415b:	c6 05 85 12 20 f0 8e 	movb   $0x8e,0xf0201285
f0104162:	c1 e8 10             	shr    $0x10,%eax
f0104165:	66 a3 86 12 20 f0    	mov    %ax,0xf0201286
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f010416b:	b8 2a 4b 10 f0       	mov    $0xf0104b2a,%eax
f0104170:	66 a3 88 12 20 f0    	mov    %ax,0xf0201288
f0104176:	66 c7 05 8a 12 20 f0 	movw   $0x8,0xf020128a
f010417d:	08 00 
f010417f:	c6 05 8c 12 20 f0 00 	movb   $0x0,0xf020128c
f0104186:	c6 05 8d 12 20 f0 8e 	movb   $0x8e,0xf020128d
f010418d:	c1 e8 10             	shr    $0x10,%eax
f0104190:	66 a3 8e 12 20 f0    	mov    %ax,0xf020128e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0104196:	b8 30 4b 10 f0       	mov    $0xf0104b30,%eax
f010419b:	66 a3 90 12 20 f0    	mov    %ax,0xf0201290
f01041a1:	66 c7 05 92 12 20 f0 	movw   $0x8,0xf0201292
f01041a8:	08 00 
f01041aa:	c6 05 94 12 20 f0 00 	movb   $0x0,0xf0201294
f01041b1:	c6 05 95 12 20 f0 8e 	movb   $0x8e,0xf0201295
f01041b8:	c1 e8 10             	shr    $0x10,%eax
f01041bb:	66 a3 96 12 20 f0    	mov    %ax,0xf0201296
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f01041c1:	b8 36 4b 10 f0       	mov    $0xf0104b36,%eax
f01041c6:	66 a3 98 12 20 f0    	mov    %ax,0xf0201298
f01041cc:	66 c7 05 9a 12 20 f0 	movw   $0x8,0xf020129a
f01041d3:	08 00 
f01041d5:	c6 05 9c 12 20 f0 00 	movb   $0x0,0xf020129c
f01041dc:	c6 05 9d 12 20 f0 8e 	movb   $0x8e,0xf020129d
f01041e3:	c1 e8 10             	shr    $0x10,%eax
f01041e6:	66 a3 9e 12 20 f0    	mov    %ax,0xf020129e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f01041ec:	b8 3c 4b 10 f0       	mov    $0xf0104b3c,%eax
f01041f1:	66 a3 a0 12 20 f0    	mov    %ax,0xf02012a0
f01041f7:	66 c7 05 a2 12 20 f0 	movw   $0x8,0xf02012a2
f01041fe:	08 00 
f0104200:	c6 05 a4 12 20 f0 00 	movb   $0x0,0xf02012a4
f0104207:	c6 05 a5 12 20 f0 8e 	movb   $0x8e,0xf02012a5
f010420e:	c1 e8 10             	shr    $0x10,%eax
f0104211:	66 a3 a6 12 20 f0    	mov    %ax,0xf02012a6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0104217:	b8 40 4b 10 f0       	mov    $0xf0104b40,%eax
f010421c:	66 a3 b0 12 20 f0    	mov    %ax,0xf02012b0
f0104222:	66 c7 05 b2 12 20 f0 	movw   $0x8,0xf02012b2
f0104229:	08 00 
f010422b:	c6 05 b4 12 20 f0 00 	movb   $0x0,0xf02012b4
f0104232:	c6 05 b5 12 20 f0 8e 	movb   $0x8e,0xf02012b5
f0104239:	c1 e8 10             	shr    $0x10,%eax
f010423c:	66 a3 b6 12 20 f0    	mov    %ax,0xf02012b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0104242:	b8 44 4b 10 f0       	mov    $0xf0104b44,%eax
f0104247:	66 a3 b8 12 20 f0    	mov    %ax,0xf02012b8
f010424d:	66 c7 05 ba 12 20 f0 	movw   $0x8,0xf02012ba
f0104254:	08 00 
f0104256:	c6 05 bc 12 20 f0 00 	movb   $0x0,0xf02012bc
f010425d:	c6 05 bd 12 20 f0 8e 	movb   $0x8e,0xf02012bd
f0104264:	c1 e8 10             	shr    $0x10,%eax
f0104267:	66 a3 be 12 20 f0    	mov    %ax,0xf02012be
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f010426d:	b8 4a 4b 10 f0       	mov    $0xf0104b4a,%eax
f0104272:	66 a3 c0 12 20 f0    	mov    %ax,0xf02012c0
f0104278:	66 c7 05 c2 12 20 f0 	movw   $0x8,0xf02012c2
f010427f:	08 00 
f0104281:	c6 05 c4 12 20 f0 00 	movb   $0x0,0xf02012c4
f0104288:	c6 05 c5 12 20 f0 8e 	movb   $0x8e,0xf02012c5
f010428f:	c1 e8 10             	shr    $0x10,%eax
f0104292:	66 a3 c6 12 20 f0    	mov    %ax,0xf02012c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0104298:	b8 4e 4b 10 f0       	mov    $0xf0104b4e,%eax
f010429d:	66 a3 c8 12 20 f0    	mov    %ax,0xf02012c8
f01042a3:	66 c7 05 ca 12 20 f0 	movw   $0x8,0xf02012ca
f01042aa:	08 00 
f01042ac:	c6 05 cc 12 20 f0 00 	movb   $0x0,0xf02012cc
f01042b3:	c6 05 cd 12 20 f0 8e 	movb   $0x8e,0xf02012cd
f01042ba:	c1 e8 10             	shr    $0x10,%eax
f01042bd:	66 a3 ce 12 20 f0    	mov    %ax,0xf02012ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f01042c3:	b8 52 4b 10 f0       	mov    $0xf0104b52,%eax
f01042c8:	66 a3 d0 12 20 f0    	mov    %ax,0xf02012d0
f01042ce:	66 c7 05 d2 12 20 f0 	movw   $0x8,0xf02012d2
f01042d5:	08 00 
f01042d7:	c6 05 d4 12 20 f0 00 	movb   $0x0,0xf02012d4
f01042de:	c6 05 d5 12 20 f0 8e 	movb   $0x8e,0xf02012d5
f01042e5:	c1 e8 10             	shr    $0x10,%eax
f01042e8:	66 a3 d6 12 20 f0    	mov    %ax,0xf02012d6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f01042ee:	b8 56 4b 10 f0       	mov    $0xf0104b56,%eax
f01042f3:	66 a3 e0 12 20 f0    	mov    %ax,0xf02012e0
f01042f9:	66 c7 05 e2 12 20 f0 	movw   $0x8,0xf02012e2
f0104300:	08 00 
f0104302:	c6 05 e4 12 20 f0 00 	movb   $0x0,0xf02012e4
f0104309:	c6 05 e5 12 20 f0 8e 	movb   $0x8e,0xf02012e5
f0104310:	c1 e8 10             	shr    $0x10,%eax
f0104313:	66 a3 e6 12 20 f0    	mov    %ax,0xf02012e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0104319:	b8 5c 4b 10 f0       	mov    $0xf0104b5c,%eax
f010431e:	66 a3 e8 12 20 f0    	mov    %ax,0xf02012e8
f0104324:	66 c7 05 ea 12 20 f0 	movw   $0x8,0xf02012ea
f010432b:	08 00 
f010432d:	c6 05 ec 12 20 f0 00 	movb   $0x0,0xf02012ec
f0104334:	c6 05 ed 12 20 f0 8e 	movb   $0x8e,0xf02012ed
f010433b:	c1 e8 10             	shr    $0x10,%eax
f010433e:	66 a3 ee 12 20 f0    	mov    %ax,0xf02012ee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0104344:	b8 60 4b 10 f0       	mov    $0xf0104b60,%eax
f0104349:	66 a3 f0 12 20 f0    	mov    %ax,0xf02012f0
f010434f:	66 c7 05 f2 12 20 f0 	movw   $0x8,0xf02012f2
f0104356:	08 00 
f0104358:	c6 05 f4 12 20 f0 00 	movb   $0x0,0xf02012f4
f010435f:	c6 05 f5 12 20 f0 8e 	movb   $0x8e,0xf02012f5
f0104366:	c1 e8 10             	shr    $0x10,%eax
f0104369:	66 a3 f6 12 20 f0    	mov    %ax,0xf02012f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f010436f:	b8 66 4b 10 f0       	mov    $0xf0104b66,%eax
f0104374:	66 a3 f8 12 20 f0    	mov    %ax,0xf02012f8
f010437a:	66 c7 05 fa 12 20 f0 	movw   $0x8,0xf02012fa
f0104381:	08 00 
f0104383:	c6 05 fc 12 20 f0 00 	movb   $0x0,0xf02012fc
f010438a:	c6 05 fd 12 20 f0 8e 	movb   $0x8e,0xf02012fd
f0104391:	c1 e8 10             	shr    $0x10,%eax
f0104394:	66 a3 fe 12 20 f0    	mov    %ax,0xf02012fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f010439a:	b8 6c 4b 10 f0       	mov    $0xf0104b6c,%eax
f010439f:	66 a3 e0 13 20 f0    	mov    %ax,0xf02013e0
f01043a5:	66 c7 05 e2 13 20 f0 	movw   $0x8,0xf02013e2
f01043ac:	08 00 
f01043ae:	c6 05 e4 13 20 f0 00 	movb   $0x0,0xf02013e4
f01043b5:	c6 05 e5 13 20 f0 ee 	movb   $0xee,0xf02013e5
f01043bc:	c1 e8 10             	shr    $0x10,%eax
f01043bf:	66 a3 e6 13 20 f0    	mov    %ax,0xf02013e6
	SETGATE(idt[IRQ_TIMER + IRQ_OFFSET], 0, GD_KT, irq_timer, 0);
f01043c5:	b8 72 4b 10 f0       	mov    $0xf0104b72,%eax
f01043ca:	66 a3 60 13 20 f0    	mov    %ax,0xf0201360
f01043d0:	66 c7 05 62 13 20 f0 	movw   $0x8,0xf0201362
f01043d7:	08 00 
f01043d9:	c6 05 64 13 20 f0 00 	movb   $0x0,0xf0201364
f01043e0:	c6 05 65 13 20 f0 8e 	movb   $0x8e,0xf0201365
f01043e7:	c1 e8 10             	shr    $0x10,%eax
f01043ea:	66 a3 66 13 20 f0    	mov    %ax,0xf0201366
	SETGATE(idt[IRQ_KBD + IRQ_OFFSET], 0, GD_KT, irq_kbd, 0);
f01043f0:	b8 78 4b 10 f0       	mov    $0xf0104b78,%eax
f01043f5:	66 a3 68 13 20 f0    	mov    %ax,0xf0201368
f01043fb:	66 c7 05 6a 13 20 f0 	movw   $0x8,0xf020136a
f0104402:	08 00 
f0104404:	c6 05 6c 13 20 f0 00 	movb   $0x0,0xf020136c
f010440b:	c6 05 6d 13 20 f0 8e 	movb   $0x8e,0xf020136d
f0104412:	c1 e8 10             	shr    $0x10,%eax
f0104415:	66 a3 6e 13 20 f0    	mov    %ax,0xf020136e
	SETGATE(idt[IRQ_SERIAL + IRQ_OFFSET], 0, GD_KT, irq_serial, 0);
f010441b:	b8 7e 4b 10 f0       	mov    $0xf0104b7e,%eax
f0104420:	66 a3 80 13 20 f0    	mov    %ax,0xf0201380
f0104426:	66 c7 05 82 13 20 f0 	movw   $0x8,0xf0201382
f010442d:	08 00 
f010442f:	c6 05 84 13 20 f0 00 	movb   $0x0,0xf0201384
f0104436:	c6 05 85 13 20 f0 8e 	movb   $0x8e,0xf0201385
f010443d:	c1 e8 10             	shr    $0x10,%eax
f0104440:	66 a3 86 13 20 f0    	mov    %ax,0xf0201386
	SETGATE(idt[IRQ_SPURIOUS + IRQ_OFFSET], 0, GD_KT, irq_spurious, 0);
f0104446:	b8 84 4b 10 f0       	mov    $0xf0104b84,%eax
f010444b:	66 a3 98 13 20 f0    	mov    %ax,0xf0201398
f0104451:	66 c7 05 9a 13 20 f0 	movw   $0x8,0xf020139a
f0104458:	08 00 
f010445a:	c6 05 9c 13 20 f0 00 	movb   $0x0,0xf020139c
f0104461:	c6 05 9d 13 20 f0 8e 	movb   $0x8e,0xf020139d
f0104468:	c1 e8 10             	shr    $0x10,%eax
f010446b:	66 a3 9e 13 20 f0    	mov    %ax,0xf020139e
	SETGATE(idt[IRQ_IDE + IRQ_OFFSET], 0, GD_KT, irq_ide, 0);
f0104471:	b8 8a 4b 10 f0       	mov    $0xf0104b8a,%eax
f0104476:	66 a3 d0 13 20 f0    	mov    %ax,0xf02013d0
f010447c:	66 c7 05 d2 13 20 f0 	movw   $0x8,0xf02013d2
f0104483:	08 00 
f0104485:	c6 05 d4 13 20 f0 00 	movb   $0x0,0xf02013d4
f010448c:	c6 05 d5 13 20 f0 8e 	movb   $0x8e,0xf02013d5
f0104493:	c1 e8 10             	shr    $0x10,%eax
f0104496:	66 a3 d6 13 20 f0    	mov    %ax,0xf02013d6
	SETGATE(idt[IRQ_ERROR + IRQ_OFFSET], 0, GD_KT, irq_error, 0);
f010449c:	b8 90 4b 10 f0       	mov    $0xf0104b90,%eax
f01044a1:	66 a3 f8 13 20 f0    	mov    %ax,0xf02013f8
f01044a7:	66 c7 05 fa 13 20 f0 	movw   $0x8,0xf02013fa
f01044ae:	08 00 
f01044b0:	c6 05 fc 13 20 f0 00 	movb   $0x0,0xf02013fc
f01044b7:	c6 05 fd 13 20 f0 8e 	movb   $0x8e,0xf02013fd
f01044be:	c1 e8 10             	shr    $0x10,%eax
f01044c1:	66 a3 fe 13 20 f0    	mov    %ax,0xf02013fe
	trap_init_percpu();
f01044c7:	e8 f4 fa ff ff       	call   f0103fc0 <trap_init_percpu>
}
f01044cc:	c9                   	leave  
f01044cd:	c3                   	ret    

f01044ce <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01044ce:	55                   	push   %ebp
f01044cf:	89 e5                	mov    %esp,%ebp
f01044d1:	53                   	push   %ebx
f01044d2:	83 ec 14             	sub    $0x14,%esp
f01044d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01044d8:	8b 03                	mov    (%ebx),%eax
f01044da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044de:	c7 04 24 16 81 10 f0 	movl   $0xf0108116,(%esp)
f01044e5:	e8 b3 fa ff ff       	call   f0103f9d <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01044ea:	8b 43 04             	mov    0x4(%ebx),%eax
f01044ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044f1:	c7 04 24 25 81 10 f0 	movl   $0xf0108125,(%esp)
f01044f8:	e8 a0 fa ff ff       	call   f0103f9d <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01044fd:	8b 43 08             	mov    0x8(%ebx),%eax
f0104500:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104504:	c7 04 24 34 81 10 f0 	movl   $0xf0108134,(%esp)
f010450b:	e8 8d fa ff ff       	call   f0103f9d <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104510:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104513:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104517:	c7 04 24 43 81 10 f0 	movl   $0xf0108143,(%esp)
f010451e:	e8 7a fa ff ff       	call   f0103f9d <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104523:	8b 43 10             	mov    0x10(%ebx),%eax
f0104526:	89 44 24 04          	mov    %eax,0x4(%esp)
f010452a:	c7 04 24 52 81 10 f0 	movl   $0xf0108152,(%esp)
f0104531:	e8 67 fa ff ff       	call   f0103f9d <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104536:	8b 43 14             	mov    0x14(%ebx),%eax
f0104539:	89 44 24 04          	mov    %eax,0x4(%esp)
f010453d:	c7 04 24 61 81 10 f0 	movl   $0xf0108161,(%esp)
f0104544:	e8 54 fa ff ff       	call   f0103f9d <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104549:	8b 43 18             	mov    0x18(%ebx),%eax
f010454c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104550:	c7 04 24 70 81 10 f0 	movl   $0xf0108170,(%esp)
f0104557:	e8 41 fa ff ff       	call   f0103f9d <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010455c:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010455f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104563:	c7 04 24 7f 81 10 f0 	movl   $0xf010817f,(%esp)
f010456a:	e8 2e fa ff ff       	call   f0103f9d <cprintf>
}
f010456f:	83 c4 14             	add    $0x14,%esp
f0104572:	5b                   	pop    %ebx
f0104573:	5d                   	pop    %ebp
f0104574:	c3                   	ret    

f0104575 <print_trapframe>:
{
f0104575:	55                   	push   %ebp
f0104576:	89 e5                	mov    %esp,%ebp
f0104578:	56                   	push   %esi
f0104579:	53                   	push   %ebx
f010457a:	83 ec 10             	sub    $0x10,%esp
f010457d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104580:	e8 ee 21 00 00       	call   f0106773 <cpunum>
f0104585:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104589:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010458d:	c7 04 24 e3 81 10 f0 	movl   $0xf01081e3,(%esp)
f0104594:	e8 04 fa ff ff       	call   f0103f9d <cprintf>
	print_regs(&tf->tf_regs);
f0104599:	89 1c 24             	mov    %ebx,(%esp)
f010459c:	e8 2d ff ff ff       	call   f01044ce <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01045a1:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01045a5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045a9:	c7 04 24 01 82 10 f0 	movl   $0xf0108201,(%esp)
f01045b0:	e8 e8 f9 ff ff       	call   f0103f9d <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01045b5:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01045b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045bd:	c7 04 24 14 82 10 f0 	movl   $0xf0108214,(%esp)
f01045c4:	e8 d4 f9 ff ff       	call   f0103f9d <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01045c9:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01045cc:	83 f8 13             	cmp    $0x13,%eax
f01045cf:	77 09                	ja     f01045da <print_trapframe+0x65>
		return excnames[trapno];
f01045d1:	8b 14 85 c0 84 10 f0 	mov    -0xfef7b40(,%eax,4),%edx
f01045d8:	eb 1f                	jmp    f01045f9 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01045da:	83 f8 30             	cmp    $0x30,%eax
f01045dd:	74 15                	je     f01045f4 <print_trapframe+0x7f>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01045df:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f01045e2:	83 fa 0f             	cmp    $0xf,%edx
f01045e5:	ba 9a 81 10 f0       	mov    $0xf010819a,%edx
f01045ea:	b9 ad 81 10 f0       	mov    $0xf01081ad,%ecx
f01045ef:	0f 47 d1             	cmova  %ecx,%edx
f01045f2:	eb 05                	jmp    f01045f9 <print_trapframe+0x84>
		return "System call";
f01045f4:	ba 8e 81 10 f0       	mov    $0xf010818e,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01045f9:	89 54 24 08          	mov    %edx,0x8(%esp)
f01045fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104601:	c7 04 24 27 82 10 f0 	movl   $0xf0108227,(%esp)
f0104608:	e8 90 f9 ff ff       	call   f0103f9d <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010460d:	3b 1d 60 1a 20 f0    	cmp    0xf0201a60,%ebx
f0104613:	75 19                	jne    f010462e <print_trapframe+0xb9>
f0104615:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104619:	75 13                	jne    f010462e <print_trapframe+0xb9>
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010461b:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010461e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104622:	c7 04 24 39 82 10 f0 	movl   $0xf0108239,(%esp)
f0104629:	e8 6f f9 ff ff       	call   f0103f9d <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010462e:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104631:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104635:	c7 04 24 48 82 10 f0 	movl   $0xf0108248,(%esp)
f010463c:	e8 5c f9 ff ff       	call   f0103f9d <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104641:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104645:	75 51                	jne    f0104698 <print_trapframe+0x123>
			tf->tf_err & 1 ? "protection" : "not-present");
f0104647:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f010464a:	89 c2                	mov    %eax,%edx
f010464c:	83 e2 01             	and    $0x1,%edx
f010464f:	ba bc 81 10 f0       	mov    $0xf01081bc,%edx
f0104654:	b9 c7 81 10 f0       	mov    $0xf01081c7,%ecx
f0104659:	0f 45 ca             	cmovne %edx,%ecx
f010465c:	89 c2                	mov    %eax,%edx
f010465e:	83 e2 02             	and    $0x2,%edx
f0104661:	ba d3 81 10 f0       	mov    $0xf01081d3,%edx
f0104666:	be d9 81 10 f0       	mov    $0xf01081d9,%esi
f010466b:	0f 44 d6             	cmove  %esi,%edx
f010466e:	83 e0 04             	and    $0x4,%eax
f0104671:	b8 de 81 10 f0       	mov    $0xf01081de,%eax
f0104676:	be 13 83 10 f0       	mov    $0xf0108313,%esi
f010467b:	0f 44 c6             	cmove  %esi,%eax
f010467e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104682:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104686:	89 44 24 04          	mov    %eax,0x4(%esp)
f010468a:	c7 04 24 56 82 10 f0 	movl   $0xf0108256,(%esp)
f0104691:	e8 07 f9 ff ff       	call   f0103f9d <cprintf>
f0104696:	eb 0c                	jmp    f01046a4 <print_trapframe+0x12f>
		cprintf("\n");
f0104698:	c7 04 24 fe 76 10 f0 	movl   $0xf01076fe,(%esp)
f010469f:	e8 f9 f8 ff ff       	call   f0103f9d <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01046a4:	8b 43 30             	mov    0x30(%ebx),%eax
f01046a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046ab:	c7 04 24 65 82 10 f0 	movl   $0xf0108265,(%esp)
f01046b2:	e8 e6 f8 ff ff       	call   f0103f9d <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01046b7:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01046bb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046bf:	c7 04 24 74 82 10 f0 	movl   $0xf0108274,(%esp)
f01046c6:	e8 d2 f8 ff ff       	call   f0103f9d <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01046cb:	8b 43 38             	mov    0x38(%ebx),%eax
f01046ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046d2:	c7 04 24 87 82 10 f0 	movl   $0xf0108287,(%esp)
f01046d9:	e8 bf f8 ff ff       	call   f0103f9d <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01046de:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01046e2:	74 27                	je     f010470b <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01046e4:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01046e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046eb:	c7 04 24 96 82 10 f0 	movl   $0xf0108296,(%esp)
f01046f2:	e8 a6 f8 ff ff       	call   f0103f9d <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01046f7:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01046fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046ff:	c7 04 24 a5 82 10 f0 	movl   $0xf01082a5,(%esp)
f0104706:	e8 92 f8 ff ff       	call   f0103f9d <cprintf>
}
f010470b:	83 c4 10             	add    $0x10,%esp
f010470e:	5b                   	pop    %ebx
f010470f:	5e                   	pop    %esi
f0104710:	5d                   	pop    %ebp
f0104711:	c3                   	ret    

f0104712 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104712:	55                   	push   %ebp
f0104713:	89 e5                	mov    %esp,%ebp
f0104715:	57                   	push   %edi
f0104716:	56                   	push   %esi
f0104717:	53                   	push   %ebx
f0104718:	83 ec 2c             	sub    $0x2c,%esp
f010471b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010471e:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if(!(tf->tf_cs & 3))
f0104721:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104725:	75 1c                	jne    f0104743 <page_fault_handler+0x31>
		panic("page_fault_handler: a page fault occurred in the kernel");
f0104727:	c7 44 24 08 60 84 10 	movl   $0xf0108460,0x8(%esp)
f010472e:	f0 
f010472f:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
f0104736:	00 
f0104737:	c7 04 24 b8 82 10 f0 	movl   $0xf01082b8,(%esp)
f010473e:	e8 fd b8 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if(curenv->env_pgfault_upcall){
f0104743:	e8 2b 20 00 00       	call   f0106773 <cpunum>
f0104748:	6b c0 74             	imul   $0x74,%eax,%eax
f010474b:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104751:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104755:	0f 84 05 01 00 00    	je     f0104860 <page_fault_handler+0x14e>
		struct UTrapframe *utrapframe;
		unsigned curenv_esp = curenv->env_tf.tf_esp;
f010475b:	e8 13 20 00 00       	call   f0106773 <cpunum>
f0104760:	6b c0 74             	imul   $0x74,%eax,%eax
f0104763:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104769:	8b 40 3c             	mov    0x3c(%eax),%eax
		if(curenv_esp >= UXSTACKTOP-PGSIZE && curenv_esp < UXSTACKTOP){
f010476c:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			//已经处理过一次页面异常了
			//push空的32位字和UTrapframe
			utrapframe = (struct UTrapframe *)(curenv_esp - 4 - sizeof(struct UTrapframe));
f0104772:	83 e8 38             	sub    $0x38,%eax
f0104775:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010477b:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0104780:	0f 46 d0             	cmovbe %eax,%edx
f0104783:	89 d7                	mov    %edx,%edi
f0104785:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		}
		else
			//第一次处理，push UTrapframe
			utrapframe = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
		//保证UTrapframe的地址是可写的
		user_mem_assert(curenv, (void*)utrapframe, sizeof(struct UTrapframe), PTE_W);
f0104788:	e8 e6 1f 00 00       	call   f0106773 <cpunum>
f010478d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104794:	00 
f0104795:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f010479c:	00 
f010479d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01047a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01047a4:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f01047aa:	89 04 24             	mov    %eax,(%esp)
f01047ad:	e8 29 ee ff ff       	call   f01035db <user_mem_assert>
		//utrapframe是异常栈帧，压栈是为了保存之前的状态以便还原
		utrapframe->utf_fault_va = fault_va;
f01047b2:	89 37                	mov    %esi,(%edi)
		utrapframe->utf_err = tf->tf_err;
f01047b4:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01047b7:	89 47 04             	mov    %eax,0x4(%edi)
		utrapframe->utf_regs = tf->tf_regs;
f01047ba:	8d 7f 08             	lea    0x8(%edi),%edi
f01047bd:	89 de                	mov    %ebx,%esi
f01047bf:	b8 20 00 00 00       	mov    $0x20,%eax
f01047c4:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01047ca:	74 03                	je     f01047cf <page_fault_handler+0xbd>
f01047cc:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01047cd:	b0 1f                	mov    $0x1f,%al
f01047cf:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01047d5:	74 05                	je     f01047dc <page_fault_handler+0xca>
f01047d7:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01047d9:	83 e8 02             	sub    $0x2,%eax
f01047dc:	89 c1                	mov    %eax,%ecx
f01047de:	c1 e9 02             	shr    $0x2,%ecx
f01047e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01047e3:	ba 00 00 00 00       	mov    $0x0,%edx
f01047e8:	a8 02                	test   $0x2,%al
f01047ea:	74 0b                	je     f01047f7 <page_fault_handler+0xe5>
f01047ec:	0f b7 16             	movzwl (%esi),%edx
f01047ef:	66 89 17             	mov    %dx,(%edi)
f01047f2:	ba 02 00 00 00       	mov    $0x2,%edx
f01047f7:	a8 01                	test   $0x1,%al
f01047f9:	74 07                	je     f0104802 <page_fault_handler+0xf0>
f01047fb:	0f b6 04 16          	movzbl (%esi,%edx,1),%eax
f01047ff:	88 04 17             	mov    %al,(%edi,%edx,1)
		utrapframe->utf_eip = tf->tf_eip;
f0104802:	8b 43 30             	mov    0x30(%ebx),%eax
f0104805:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104808:	89 46 28             	mov    %eax,0x28(%esi)
		utrapframe->utf_eflags = tf->tf_eflags;
f010480b:	8b 43 38             	mov    0x38(%ebx),%eax
f010480e:	89 46 2c             	mov    %eax,0x2c(%esi)
		utrapframe->utf_esp = tf->tf_esp;
f0104811:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104814:	89 46 30             	mov    %eax,0x30(%esi)
		
		//修改当前栈指针
		curenv->env_tf.tf_eip = (unsigned)curenv->env_pgfault_upcall;
f0104817:	e8 57 1f 00 00       	call   f0106773 <cpunum>
f010481c:	6b c0 74             	imul   $0x74,%eax,%eax
f010481f:	8b 98 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%ebx
f0104825:	e8 49 1f 00 00       	call   f0106773 <cpunum>
f010482a:	6b c0 74             	imul   $0x74,%eax,%eax
f010482d:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104833:	8b 40 64             	mov    0x64(%eax),%eax
f0104836:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = (unsigned)utrapframe;
f0104839:	e8 35 1f 00 00       	call   f0106773 <cpunum>
f010483e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104841:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104847:	89 70 3c             	mov    %esi,0x3c(%eax)
		//重新执行env
		env_run(curenv);
f010484a:	e8 24 1f 00 00       	call   f0106773 <cpunum>
f010484f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104852:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104858:	89 04 24             	mov    %eax,(%esp)
f010485b:	e8 e6 f4 ff ff       	call   f0103d46 <env_run>
	}
	else{
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104860:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f0104863:	e8 0b 1f 00 00       	call   f0106773 <cpunum>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104868:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010486c:	89 74 24 08          	mov    %esi,0x8(%esp)
			curenv->env_id, fault_va, tf->tf_eip);
f0104870:	6b c0 74             	imul   $0x74,%eax,%eax
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104873:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104879:	8b 40 48             	mov    0x48(%eax),%eax
f010487c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104880:	c7 04 24 98 84 10 f0 	movl   $0xf0108498,(%esp)
f0104887:	e8 11 f7 ff ff       	call   f0103f9d <cprintf>
		print_trapframe(tf);
f010488c:	89 1c 24             	mov    %ebx,(%esp)
f010488f:	e8 e1 fc ff ff       	call   f0104575 <print_trapframe>
		env_destroy(curenv);
f0104894:	e8 da 1e 00 00       	call   f0106773 <cpunum>
f0104899:	6b c0 74             	imul   $0x74,%eax,%eax
f010489c:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f01048a2:	89 04 24             	mov    %eax,(%esp)
f01048a5:	e8 fb f3 ff ff       	call   f0103ca5 <env_destroy>
	}
}
f01048aa:	83 c4 2c             	add    $0x2c,%esp
f01048ad:	5b                   	pop    %ebx
f01048ae:	5e                   	pop    %esi
f01048af:	5f                   	pop    %edi
f01048b0:	5d                   	pop    %ebp
f01048b1:	c3                   	ret    

f01048b2 <trap>:
{
f01048b2:	55                   	push   %ebp
f01048b3:	89 e5                	mov    %esp,%ebp
f01048b5:	57                   	push   %edi
f01048b6:	56                   	push   %esi
f01048b7:	83 ec 20             	sub    $0x20,%esp
f01048ba:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f01048bd:	fc                   	cld    
	if (panicstr)
f01048be:	83 3d 80 1e 20 f0 00 	cmpl   $0x0,0xf0201e80
f01048c5:	74 01                	je     f01048c8 <trap+0x16>
		asm volatile("hlt");
f01048c7:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01048c8:	e8 a6 1e 00 00       	call   f0106773 <cpunum>
f01048cd:	6b d0 74             	imul   $0x74,%eax,%edx
f01048d0:	81 c2 20 20 20 f0    	add    $0xf0202020,%edx
	asm volatile("lock; xchgl %0, %1" :
f01048d6:	b8 01 00 00 00       	mov    $0x1,%eax
f01048db:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01048df:	83 f8 02             	cmp    $0x2,%eax
f01048e2:	75 0c                	jne    f01048f0 <trap+0x3e>
	spin_lock(&kernel_lock);
f01048e4:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f01048eb:	e8 01 21 00 00       	call   f01069f1 <spin_lock>
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01048f0:	9c                   	pushf  
f01048f1:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f01048f2:	f6 c4 02             	test   $0x2,%ah
f01048f5:	74 24                	je     f010491b <trap+0x69>
f01048f7:	c7 44 24 0c c4 82 10 	movl   $0xf01082c4,0xc(%esp)
f01048fe:	f0 
f01048ff:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0104906:	f0 
f0104907:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
f010490e:	00 
f010490f:	c7 04 24 b8 82 10 f0 	movl   $0xf01082b8,(%esp)
f0104916:	e8 25 b7 ff ff       	call   f0100040 <_panic>
	if ((tf->tf_cs & 3) == 3) {
f010491b:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010491f:	83 e0 03             	and    $0x3,%eax
f0104922:	66 83 f8 03          	cmp    $0x3,%ax
f0104926:	0f 85 a7 00 00 00    	jne    f01049d3 <trap+0x121>
f010492c:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104933:	e8 b9 20 00 00       	call   f01069f1 <spin_lock>
		assert(curenv);
f0104938:	e8 36 1e 00 00       	call   f0106773 <cpunum>
f010493d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104940:	83 b8 28 20 20 f0 00 	cmpl   $0x0,-0xfdfdfd8(%eax)
f0104947:	75 24                	jne    f010496d <trap+0xbb>
f0104949:	c7 44 24 0c dd 82 10 	movl   $0xf01082dd,0xc(%esp)
f0104950:	f0 
f0104951:	c7 44 24 08 65 74 10 	movl   $0xf0107465,0x8(%esp)
f0104958:	f0 
f0104959:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
f0104960:	00 
f0104961:	c7 04 24 b8 82 10 f0 	movl   $0xf01082b8,(%esp)
f0104968:	e8 d3 b6 ff ff       	call   f0100040 <_panic>
		if (curenv->env_status == ENV_DYING) {
f010496d:	e8 01 1e 00 00       	call   f0106773 <cpunum>
f0104972:	6b c0 74             	imul   $0x74,%eax,%eax
f0104975:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f010497b:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010497f:	75 2d                	jne    f01049ae <trap+0xfc>
			env_free(curenv);
f0104981:	e8 ed 1d 00 00       	call   f0106773 <cpunum>
f0104986:	6b c0 74             	imul   $0x74,%eax,%eax
f0104989:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f010498f:	89 04 24             	mov    %eax,(%esp)
f0104992:	e8 43 f1 ff ff       	call   f0103ada <env_free>
			curenv = NULL;
f0104997:	e8 d7 1d 00 00       	call   f0106773 <cpunum>
f010499c:	6b c0 74             	imul   $0x74,%eax,%eax
f010499f:	c7 80 28 20 20 f0 00 	movl   $0x0,-0xfdfdfd8(%eax)
f01049a6:	00 00 00 
			sched_yield();
f01049a9:	e8 d9 02 00 00       	call   f0104c87 <sched_yield>
		curenv->env_tf = *tf;
f01049ae:	e8 c0 1d 00 00       	call   f0106773 <cpunum>
f01049b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01049b6:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f01049bc:	b9 11 00 00 00       	mov    $0x11,%ecx
f01049c1:	89 c7                	mov    %eax,%edi
f01049c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01049c5:	e8 a9 1d 00 00       	call   f0106773 <cpunum>
f01049ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01049cd:	8b b0 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%esi
	last_tf = tf;
f01049d3:	89 35 60 1a 20 f0    	mov    %esi,0xf0201a60
	switch(tf->tf_trapno){
f01049d9:	8b 46 28             	mov    0x28(%esi),%eax
f01049dc:	83 f8 20             	cmp    $0x20,%eax
f01049df:	74 7d                	je     f0104a5e <trap+0x1ac>
f01049e1:	83 f8 20             	cmp    $0x20,%eax
f01049e4:	77 11                	ja     f01049f7 <trap+0x145>
f01049e6:	83 f8 03             	cmp    $0x3,%eax
f01049e9:	74 27                	je     f0104a12 <trap+0x160>
f01049eb:	83 f8 0e             	cmp    $0xe,%eax
f01049ee:	66 90                	xchg   %ax,%ax
f01049f0:	74 2d                	je     f0104a1f <trap+0x16d>
f01049f2:	e9 90 00 00 00       	jmp    f0104a87 <trap+0x1d5>
f01049f7:	83 f8 27             	cmp    $0x27,%eax
f01049fa:	74 6c                	je     f0104a68 <trap+0x1b6>
f01049fc:	83 f8 30             	cmp    $0x30,%eax
f01049ff:	90                   	nop
f0104a00:	74 2a                	je     f0104a2c <trap+0x17a>
f0104a02:	83 f8 21             	cmp    $0x21,%eax
f0104a05:	0f 85 7c 00 00 00    	jne    f0104a87 <trap+0x1d5>
f0104a0b:	90                   	nop
f0104a0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104a10:	eb 6c                	jmp    f0104a7e <trap+0x1cc>
			monitor(tf);
f0104a12:	89 34 24             	mov    %esi,(%esp)
f0104a15:	e8 f6 bf ff ff       	call   f0100a10 <monitor>
f0104a1a:	e9 a9 00 00 00       	jmp    f0104ac8 <trap+0x216>
			page_fault_handler(tf);
f0104a1f:	89 34 24             	mov    %esi,(%esp)
f0104a22:	e8 eb fc ff ff       	call   f0104712 <page_fault_handler>
f0104a27:	e9 9c 00 00 00       	jmp    f0104ac8 <trap+0x216>
			tf->tf_regs.reg_eax = syscall(eax, edx, ecx, ebx, edi, esi);
f0104a2c:	8b 46 04             	mov    0x4(%esi),%eax
f0104a2f:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104a33:	8b 06                	mov    (%esi),%eax
f0104a35:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104a39:	8b 46 10             	mov    0x10(%esi),%eax
f0104a3c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a40:	8b 46 18             	mov    0x18(%esi),%eax
f0104a43:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a47:	8b 46 14             	mov    0x14(%esi),%eax
f0104a4a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a4e:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104a51:	89 04 24             	mov    %eax,(%esp)
f0104a54:	e8 f7 02 00 00       	call   f0104d50 <syscall>
f0104a59:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104a5c:	eb 6a                	jmp    f0104ac8 <trap+0x216>
			lapic_eoi();
f0104a5e:	e8 5d 1e 00 00       	call   f01068c0 <lapic_eoi>
			sched_yield();
f0104a63:	e8 1f 02 00 00       	call   f0104c87 <sched_yield>
			cprintf("Spurious interrupt on irq 7\n");
f0104a68:	c7 04 24 e4 82 10 f0 	movl   $0xf01082e4,(%esp)
f0104a6f:	e8 29 f5 ff ff       	call   f0103f9d <cprintf>
			print_trapframe(tf);
f0104a74:	89 34 24             	mov    %esi,(%esp)
f0104a77:	e8 f9 fa ff ff       	call   f0104575 <print_trapframe>
f0104a7c:	eb 4a                	jmp    f0104ac8 <trap+0x216>
			serial_intr();
f0104a7e:	66 90                	xchg   %ax,%ax
f0104a80:	e8 c2 bb ff ff       	call   f0100647 <serial_intr>
f0104a85:	eb 41                	jmp    f0104ac8 <trap+0x216>
			print_trapframe(tf);
f0104a87:	89 34 24             	mov    %esi,(%esp)
f0104a8a:	e8 e6 fa ff ff       	call   f0104575 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f0104a8f:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104a94:	75 1c                	jne    f0104ab2 <trap+0x200>
				panic("unhandled trap in kernel");
f0104a96:	c7 44 24 08 01 83 10 	movl   $0xf0108301,0x8(%esp)
f0104a9d:	f0 
f0104a9e:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
f0104aa5:	00 
f0104aa6:	c7 04 24 b8 82 10 f0 	movl   $0xf01082b8,(%esp)
f0104aad:	e8 8e b5 ff ff       	call   f0100040 <_panic>
				env_destroy(curenv);
f0104ab2:	e8 bc 1c 00 00       	call   f0106773 <cpunum>
f0104ab7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aba:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104ac0:	89 04 24             	mov    %eax,(%esp)
f0104ac3:	e8 dd f1 ff ff       	call   f0103ca5 <env_destroy>
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104ac8:	e8 a6 1c 00 00       	call   f0106773 <cpunum>
f0104acd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ad0:	83 b8 28 20 20 f0 00 	cmpl   $0x0,-0xfdfdfd8(%eax)
f0104ad7:	74 2a                	je     f0104b03 <trap+0x251>
f0104ad9:	e8 95 1c 00 00       	call   f0106773 <cpunum>
f0104ade:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae1:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104ae7:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104aeb:	75 16                	jne    f0104b03 <trap+0x251>
		env_run(curenv);
f0104aed:	e8 81 1c 00 00       	call   f0106773 <cpunum>
f0104af2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104af5:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104afb:	89 04 24             	mov    %eax,(%esp)
f0104afe:	e8 43 f2 ff ff       	call   f0103d46 <env_run>
		sched_yield();
f0104b03:	e8 7f 01 00 00       	call   f0104c87 <sched_yield>

f0104b08 <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f0104b08:	6a 00                	push   $0x0
f0104b0a:	6a 00                	push   $0x0
f0104b0c:	e9 85 00 00 00       	jmp    f0104b96 <_alltraps>
f0104b11:	90                   	nop

f0104b12 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0104b12:	6a 00                	push   $0x0
f0104b14:	6a 01                	push   $0x1
f0104b16:	eb 7e                	jmp    f0104b96 <_alltraps>

f0104b18 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f0104b18:	6a 00                	push   $0x0
f0104b1a:	6a 02                	push   $0x2
f0104b1c:	eb 78                	jmp    f0104b96 <_alltraps>

f0104b1e <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f0104b1e:	6a 00                	push   $0x0
f0104b20:	6a 03                	push   $0x3
f0104b22:	eb 72                	jmp    f0104b96 <_alltraps>

f0104b24 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f0104b24:	6a 00                	push   $0x0
f0104b26:	6a 04                	push   $0x4
f0104b28:	eb 6c                	jmp    f0104b96 <_alltraps>

f0104b2a <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f0104b2a:	6a 00                	push   $0x0
f0104b2c:	6a 05                	push   $0x5
f0104b2e:	eb 66                	jmp    f0104b96 <_alltraps>

f0104b30 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f0104b30:	6a 00                	push   $0x0
f0104b32:	6a 06                	push   $0x6
f0104b34:	eb 60                	jmp    f0104b96 <_alltraps>

f0104b36 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f0104b36:	6a 00                	push   $0x0
f0104b38:	6a 07                	push   $0x7
f0104b3a:	eb 5a                	jmp    f0104b96 <_alltraps>

f0104b3c <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f0104b3c:	6a 08                	push   $0x8
f0104b3e:	eb 56                	jmp    f0104b96 <_alltraps>

f0104b40 <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f0104b40:	6a 0a                	push   $0xa
f0104b42:	eb 52                	jmp    f0104b96 <_alltraps>

f0104b44 <t_segnp>:
TRAPHANDLER_NOEC(t_segnp, T_SEGNP)
f0104b44:	6a 00                	push   $0x0
f0104b46:	6a 0b                	push   $0xb
f0104b48:	eb 4c                	jmp    f0104b96 <_alltraps>

f0104b4a <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f0104b4a:	6a 0c                	push   $0xc
f0104b4c:	eb 48                	jmp    f0104b96 <_alltraps>

f0104b4e <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f0104b4e:	6a 0d                	push   $0xd
f0104b50:	eb 44                	jmp    f0104b96 <_alltraps>

f0104b52 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f0104b52:	6a 0e                	push   $0xe
f0104b54:	eb 40                	jmp    f0104b96 <_alltraps>

f0104b56 <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f0104b56:	6a 00                	push   $0x0
f0104b58:	6a 10                	push   $0x10
f0104b5a:	eb 3a                	jmp    f0104b96 <_alltraps>

f0104b5c <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f0104b5c:	6a 11                	push   $0x11
f0104b5e:	eb 36                	jmp    f0104b96 <_alltraps>

f0104b60 <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f0104b60:	6a 00                	push   $0x0
f0104b62:	6a 12                	push   $0x12
f0104b64:	eb 30                	jmp    f0104b96 <_alltraps>

f0104b66 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f0104b66:	6a 00                	push   $0x0
f0104b68:	6a 13                	push   $0x13
f0104b6a:	eb 2a                	jmp    f0104b96 <_alltraps>

f0104b6c <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f0104b6c:	6a 00                	push   $0x0
f0104b6e:	6a 30                	push   $0x30
f0104b70:	eb 24                	jmp    f0104b96 <_alltraps>

f0104b72 <irq_timer>:

TRAPHANDLER_NOEC(irq_timer, IRQ_TIMER + IRQ_OFFSET)
f0104b72:	6a 00                	push   $0x0
f0104b74:	6a 20                	push   $0x20
f0104b76:	eb 1e                	jmp    f0104b96 <_alltraps>

f0104b78 <irq_kbd>:
TRAPHANDLER_NOEC(irq_kbd, IRQ_KBD + IRQ_OFFSET)
f0104b78:	6a 00                	push   $0x0
f0104b7a:	6a 21                	push   $0x21
f0104b7c:	eb 18                	jmp    f0104b96 <_alltraps>

f0104b7e <irq_serial>:
TRAPHANDLER_NOEC(irq_serial, IRQ_SERIAL + IRQ_OFFSET)
f0104b7e:	6a 00                	push   $0x0
f0104b80:	6a 24                	push   $0x24
f0104b82:	eb 12                	jmp    f0104b96 <_alltraps>

f0104b84 <irq_spurious>:
TRAPHANDLER_NOEC(irq_spurious, IRQ_SPURIOUS + IRQ_OFFSET)
f0104b84:	6a 00                	push   $0x0
f0104b86:	6a 27                	push   $0x27
f0104b88:	eb 0c                	jmp    f0104b96 <_alltraps>

f0104b8a <irq_ide>:
TRAPHANDLER_NOEC(irq_ide, IRQ_IDE + IRQ_OFFSET)
f0104b8a:	6a 00                	push   $0x0
f0104b8c:	6a 2e                	push   $0x2e
f0104b8e:	eb 06                	jmp    f0104b96 <_alltraps>

f0104b90 <irq_error>:
TRAPHANDLER_NOEC(irq_error, IRQ_ERROR + IRQ_OFFSET)
f0104b90:	6a 00                	push   $0x0
f0104b92:	6a 33                	push   $0x33
f0104b94:	eb 00                	jmp    f0104b96 <_alltraps>

f0104b96 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
// 构造trapframe
	pushl %ds
f0104b96:	1e                   	push   %ds
	pushl %es
f0104b97:	06                   	push   %es
	pushal
f0104b98:	60                   	pusha  
	// 将GD_KD加载到ds和es寄存器
	movl %ss, %eax
f0104b99:	8c d0                	mov    %ss,%eax
	movw %ax, %ds
f0104b9b:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104b9d:	8e c0                	mov    %eax,%es
	// 传递trapframe指针给trap参数
	pushl %esp
f0104b9f:	54                   	push   %esp
	// 调用trap
	call trap
f0104ba0:	e8 0d fd ff ff       	call   f01048b2 <trap>

f0104ba5 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104ba5:	55                   	push   %ebp
f0104ba6:	89 e5                	mov    %esp,%ebp
f0104ba8:	83 ec 18             	sub    $0x18,%esp
	int i;
	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104bab:	8b 15 48 12 20 f0    	mov    0xf0201248,%edx
		     envs[i].env_status == ENV_RUNNING ||
f0104bb1:	8b 42 54             	mov    0x54(%edx),%eax
f0104bb4:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104bb7:	83 f8 02             	cmp    $0x2,%eax
f0104bba:	76 43                	jbe    f0104bff <sched_halt+0x5a>
	for (i = 0; i < NENV; i++) {
f0104bbc:	b8 01 00 00 00       	mov    $0x1,%eax
		     envs[i].env_status == ENV_RUNNING ||
f0104bc1:	8b 8a d0 00 00 00    	mov    0xd0(%edx),%ecx
f0104bc7:	83 e9 01             	sub    $0x1,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104bca:	83 f9 02             	cmp    $0x2,%ecx
f0104bcd:	76 0f                	jbe    f0104bde <sched_halt+0x39>
	for (i = 0; i < NENV; i++) {
f0104bcf:	83 c0 01             	add    $0x1,%eax
f0104bd2:	83 c2 7c             	add    $0x7c,%edx
f0104bd5:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104bda:	75 e5                	jne    f0104bc1 <sched_halt+0x1c>
f0104bdc:	eb 07                	jmp    f0104be5 <sched_halt+0x40>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104bde:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104be3:	75 1a                	jne    f0104bff <sched_halt+0x5a>
		cprintf("No runnable environments in the system!\n");
f0104be5:	c7 04 24 10 85 10 f0 	movl   $0xf0108510,(%esp)
f0104bec:	e8 ac f3 ff ff       	call   f0103f9d <cprintf>
		while (1)
			monitor(NULL);
f0104bf1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104bf8:	e8 13 be ff ff       	call   f0100a10 <monitor>
f0104bfd:	eb f2                	jmp    f0104bf1 <sched_halt+0x4c>
	}
	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104bff:	e8 6f 1b 00 00       	call   f0106773 <cpunum>
f0104c04:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c07:	c7 80 28 20 20 f0 00 	movl   $0x0,-0xfdfdfd8(%eax)
f0104c0e:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104c11:	a1 8c 1e 20 f0       	mov    0xf0201e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104c16:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104c1b:	77 20                	ja     f0104c3d <sched_halt+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104c1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104c21:	c7 44 24 08 c8 6e 10 	movl   $0xf0106ec8,0x8(%esp)
f0104c28:	f0 
f0104c29:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
f0104c30:	00 
f0104c31:	c7 04 24 39 85 10 f0 	movl   $0xf0108539,(%esp)
f0104c38:	e8 03 b4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104c3d:	05 00 00 00 10       	add    $0x10000000,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104c42:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104c45:	e8 29 1b 00 00       	call   f0106773 <cpunum>
f0104c4a:	6b d0 74             	imul   $0x74,%eax,%edx
f0104c4d:	81 c2 20 20 20 f0    	add    $0xf0202020,%edx
	asm volatile("lock; xchgl %0, %1" :
f0104c53:	b8 02 00 00 00       	mov    $0x2,%eax
f0104c58:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
	spin_unlock(&kernel_lock);
f0104c5c:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104c63:	e8 5f 1e 00 00       	call   f0106ac7 <spin_unlock>
	asm volatile("pause");
f0104c68:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104c6a:	e8 04 1b 00 00       	call   f0106773 <cpunum>
f0104c6f:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f0104c72:	8b 80 30 20 20 f0    	mov    -0xfdfdfd0(%eax),%eax
f0104c78:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104c7d:	89 c4                	mov    %eax,%esp
f0104c7f:	6a 00                	push   $0x0
f0104c81:	6a 00                	push   $0x0
f0104c83:	fb                   	sti    
f0104c84:	f4                   	hlt    
}
f0104c85:	c9                   	leave  
f0104c86:	c3                   	ret    

f0104c87 <sched_yield>:
{
f0104c87:	55                   	push   %ebp
f0104c88:	89 e5                	mov    %esp,%ebp
f0104c8a:	56                   	push   %esi
f0104c8b:	53                   	push   %ebx
f0104c8c:	83 ec 10             	sub    $0x10,%esp
	int curenv_index = (curenv?(curenv - envs + 1):0);	
f0104c8f:	e8 df 1a 00 00       	call   f0106773 <cpunum>
f0104c94:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c97:	be 00 00 00 00       	mov    $0x0,%esi
f0104c9c:	83 b8 28 20 20 f0 00 	cmpl   $0x0,-0xfdfdfd8(%eax)
f0104ca3:	74 20                	je     f0104cc5 <sched_yield+0x3e>
f0104ca5:	e8 c9 1a 00 00       	call   f0106773 <cpunum>
f0104caa:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cad:	8b b0 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%esi
f0104cb3:	2b 35 48 12 20 f0    	sub    0xf0201248,%esi
f0104cb9:	c1 fe 02             	sar    $0x2,%esi
f0104cbc:	69 f6 df 7b ef bd    	imul   $0xbdef7bdf,%esi,%esi
f0104cc2:	83 c6 01             	add    $0x1,%esi
		idle = envs + ((curenv_index + offset) % NENV);
f0104cc5:	8b 1d 48 12 20 f0    	mov    0xf0201248,%ebx
	for(offset = 0; offset < NENV; ++offset){
f0104ccb:	b8 00 00 00 00       	mov    $0x0,%eax
f0104cd0:	8d 14 30             	lea    (%eax,%esi,1),%edx
		idle = envs + ((curenv_index + offset) % NENV);
f0104cd3:	89 d1                	mov    %edx,%ecx
f0104cd5:	c1 f9 1f             	sar    $0x1f,%ecx
f0104cd8:	c1 e9 16             	shr    $0x16,%ecx
f0104cdb:	01 ca                	add    %ecx,%edx
f0104cdd:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0104ce3:	29 ca                	sub    %ecx,%edx
f0104ce5:	6b d2 7c             	imul   $0x7c,%edx,%edx
		if(idle && ENV_RUNNABLE == idle->env_status){
f0104ce8:	01 da                	add    %ebx,%edx
f0104cea:	74 0e                	je     f0104cfa <sched_yield+0x73>
f0104cec:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104cf0:	75 08                	jne    f0104cfa <sched_yield+0x73>
			env_run(idle);
f0104cf2:	89 14 24             	mov    %edx,(%esp)
f0104cf5:	e8 4c f0 ff ff       	call   f0103d46 <env_run>
	for(offset = 0; offset < NENV; ++offset){
f0104cfa:	83 c0 01             	add    $0x1,%eax
f0104cfd:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104d02:	75 cc                	jne    f0104cd0 <sched_yield+0x49>
	if(curenv && ENV_RUNNING == curenv->env_status)
f0104d04:	e8 6a 1a 00 00       	call   f0106773 <cpunum>
f0104d09:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d0c:	83 b8 28 20 20 f0 00 	cmpl   $0x0,-0xfdfdfd8(%eax)
f0104d13:	74 2a                	je     f0104d3f <sched_yield+0xb8>
f0104d15:	e8 59 1a 00 00       	call   f0106773 <cpunum>
f0104d1a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d1d:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104d23:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104d27:	75 16                	jne    f0104d3f <sched_yield+0xb8>
		env_run(curenv);
f0104d29:	e8 45 1a 00 00       	call   f0106773 <cpunum>
f0104d2e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d31:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104d37:	89 04 24             	mov    %eax,(%esp)
f0104d3a:	e8 07 f0 ff ff       	call   f0103d46 <env_run>
		sched_halt();
f0104d3f:	e8 61 fe ff ff       	call   f0104ba5 <sched_halt>
}
f0104d44:	83 c4 10             	add    $0x10,%esp
f0104d47:	5b                   	pop    %ebx
f0104d48:	5e                   	pop    %esi
f0104d49:	5d                   	pop    %ebp
f0104d4a:	c3                   	ret    
f0104d4b:	66 90                	xchg   %ax,%ax
f0104d4d:	66 90                	xchg   %ax,%ax
f0104d4f:	90                   	nop

f0104d50 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104d50:	55                   	push   %ebp
f0104d51:	89 e5                	mov    %esp,%ebp
f0104d53:	57                   	push   %edi
f0104d54:	56                   	push   %esi
f0104d55:	53                   	push   %ebx
f0104d56:	83 ec 2c             	sub    $0x2c,%esp
f0104d59:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch(syscallno){
f0104d5c:	83 f8 0d             	cmp    $0xd,%eax
f0104d5f:	0f 87 37 06 00 00    	ja     f010539c <syscall+0x64c>
f0104d65:	ff 24 85 80 85 10 f0 	jmp    *-0xfef7a80(,%eax,4)
	user_mem_assert(curenv, (void *)s, len, 0);
f0104d6c:	e8 02 1a 00 00       	call   f0106773 <cpunum>
f0104d71:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104d78:	00 
f0104d79:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104d7c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104d83:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104d87:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d8a:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104d90:	89 04 24             	mov    %eax,(%esp)
f0104d93:	e8 43 e8 ff ff       	call   f01035db <user_mem_assert>
	cprintf("%.*s", len, s);
f0104d98:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d9b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d9f:	8b 45 10             	mov    0x10(%ebp),%eax
f0104da2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104da6:	c7 04 24 46 85 10 f0 	movl   $0xf0108546,(%esp)
f0104dad:	e8 eb f1 ff ff       	call   f0103f9d <cprintf>
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
f0104db2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104db7:	e9 ec 05 00 00       	jmp    f01053a8 <syscall+0x658>
	return cons_getc();
f0104dbc:	e8 b4 b8 ff ff       	call   f0100675 <cons_getc>
		case SYS_cgetc:
			return sys_cgetc();
f0104dc1:	e9 e2 05 00 00       	jmp    f01053a8 <syscall+0x658>
	return curenv->env_id;
f0104dc6:	e8 a8 19 00 00       	call   f0106773 <cpunum>
f0104dcb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dce:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104dd4:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_getenvid:
			return sys_getenvid();
f0104dd7:	e9 cc 05 00 00       	jmp    f01053a8 <syscall+0x658>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104ddc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104de3:	00 
f0104de4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104de7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104deb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104dee:	89 04 24             	mov    %eax,(%esp)
f0104df1:	e8 da e8 ff ff       	call   f01036d0 <envid2env>
		return r;
f0104df6:	89 c2                	mov    %eax,%edx
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104df8:	85 c0                	test   %eax,%eax
f0104dfa:	78 6e                	js     f0104e6a <syscall+0x11a>
	if (e == curenv)
f0104dfc:	e8 72 19 00 00       	call   f0106773 <cpunum>
f0104e01:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e04:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e07:	39 90 28 20 20 f0    	cmp    %edx,-0xfdfdfd8(%eax)
f0104e0d:	75 23                	jne    f0104e32 <syscall+0xe2>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104e0f:	e8 5f 19 00 00       	call   f0106773 <cpunum>
f0104e14:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e17:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104e1d:	8b 40 48             	mov    0x48(%eax),%eax
f0104e20:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e24:	c7 04 24 4b 85 10 f0 	movl   $0xf010854b,(%esp)
f0104e2b:	e8 6d f1 ff ff       	call   f0103f9d <cprintf>
f0104e30:	eb 28                	jmp    f0104e5a <syscall+0x10a>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104e32:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104e35:	e8 39 19 00 00       	call   f0106773 <cpunum>
f0104e3a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104e3e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e41:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104e47:	8b 40 48             	mov    0x48(%eax),%eax
f0104e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e4e:	c7 04 24 66 85 10 f0 	movl   $0xf0108566,(%esp)
f0104e55:	e8 43 f1 ff ff       	call   f0103f9d <cprintf>
	env_destroy(e);
f0104e5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e5d:	89 04 24             	mov    %eax,(%esp)
f0104e60:	e8 40 ee ff ff       	call   f0103ca5 <env_destroy>
	return 0;
f0104e65:	ba 00 00 00 00       	mov    $0x0,%edx
		case SYS_env_destroy:
			return sys_env_destroy(a1);
f0104e6a:	89 d0                	mov    %edx,%eax
f0104e6c:	e9 37 05 00 00       	jmp    f01053a8 <syscall+0x658>
	sched_yield();
f0104e71:	e8 11 fe ff ff       	call   f0104c87 <sched_yield>
	int result = env_alloc(&new_env, curenv->env_id);
f0104e76:	e8 f8 18 00 00       	call   f0106773 <cpunum>
f0104e7b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e7e:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0104e84:	8b 40 48             	mov    0x48(%eax),%eax
f0104e87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e8b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e8e:	89 04 24             	mov    %eax,(%esp)
f0104e91:	e8 4b e9 ff ff       	call   f01037e1 <env_alloc>
		return result;
f0104e96:	89 c2                	mov    %eax,%edx
	if(result < 0)
f0104e98:	85 c0                	test   %eax,%eax
f0104e9a:	78 2e                	js     f0104eca <syscall+0x17a>
	new_env->env_tf = curenv->env_tf;
f0104e9c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104e9f:	e8 cf 18 00 00       	call   f0106773 <cpunum>
f0104ea4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ea7:	8b b0 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%esi
f0104ead:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104eb2:	89 df                	mov    %ebx,%edi
f0104eb4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	new_env->env_status = ENV_NOT_RUNNABLE;
f0104eb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104eb9:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	new_env->env_tf.tf_regs.reg_eax = 0;
f0104ec0:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return new_env->env_id;
f0104ec7:	8b 50 48             	mov    0x48(%eax),%edx
		case SYS_yield:
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
f0104eca:	89 d0                	mov    %edx,%eax
f0104ecc:	e9 d7 04 00 00       	jmp    f01053a8 <syscall+0x658>
	if(status < ENV_FREE || status > ENV_NOT_RUNNABLE)
f0104ed1:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104ed5:	77 35                	ja     f0104f0c <syscall+0x1bc>
	int result = envid2env(envid, &env, 1);
f0104ed7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ede:	00 
f0104edf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ee2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ee6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104ee9:	89 04 24             	mov    %eax,(%esp)
f0104eec:	e8 df e7 ff ff       	call   f01036d0 <envid2env>
	if(result < 0)
f0104ef1:	85 c0                	test   %eax,%eax
f0104ef3:	0f 88 af 04 00 00    	js     f01053a8 <syscall+0x658>
	env->env_status = status;
f0104ef9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104efc:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104eff:	89 48 54             	mov    %ecx,0x54(%eax)
	return 0;	
f0104f02:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f07:	e9 9c 04 00 00       	jmp    f01053a8 <syscall+0x658>
		return -E_INVAL;
f0104f0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f11:	e9 92 04 00 00       	jmp    f01053a8 <syscall+0x658>
	int result = envid2env(envid, &env, 1);
f0104f16:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f1d:	00 
f0104f1e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f21:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f25:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f28:	89 04 24             	mov    %eax,(%esp)
f0104f2b:	e8 a0 e7 ff ff       	call   f01036d0 <envid2env>
	if(result < 0)
f0104f30:	85 c0                	test   %eax,%eax
f0104f32:	0f 88 70 04 00 00    	js     f01053a8 <syscall+0x658>
	env->env_pgfault_upcall = func;
f0104f38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f3b:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f3e:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f0104f41:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f46:	e9 5d 04 00 00       	jmp    f01053a8 <syscall+0x658>
	int result = envid2env(envid, &env, 1);
f0104f4b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f52:	00 
f0104f53:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f56:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f5d:	89 04 24             	mov    %eax,(%esp)
f0104f60:	e8 6b e7 ff ff       	call   f01036d0 <envid2env>
	if(result < 0)
f0104f65:	85 c0                	test   %eax,%eax
f0104f67:	78 65                	js     f0104fce <syscall+0x27e>
	if((unsigned)va >= UTOP || (unsigned)va & (PGSIZE - 1))
f0104f69:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104f70:	77 60                	ja     f0104fd2 <syscall+0x282>
f0104f72:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104f79:	75 5e                	jne    f0104fd9 <syscall+0x289>
	if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & (~(PTE_P | PTE_U | PTE_W | PTE_AVAIL))))
f0104f7b:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f7e:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104f83:	83 f8 05             	cmp    $0x5,%eax
f0104f86:	75 58                	jne    f0104fe0 <syscall+0x290>
	struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f0104f88:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104f8f:	e8 dc c1 ff ff       	call   f0101170 <page_alloc>
f0104f94:	89 c3                	mov    %eax,%ebx
	if(!new_page)
f0104f96:	85 c0                	test   %eax,%eax
f0104f98:	74 4d                	je     f0104fe7 <syscall+0x297>
	result = page_insert(env->env_pgdir, new_page, va, perm);
f0104f9a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104fa1:	8b 45 10             	mov    0x10(%ebp),%eax
f0104fa4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104fa8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104fac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104faf:	8b 40 60             	mov    0x60(%eax),%eax
f0104fb2:	89 04 24             	mov    %eax,(%esp)
f0104fb5:	e8 91 c4 ff ff       	call   f010144b <page_insert>
f0104fba:	89 c6                	mov    %eax,%esi
	return result;
f0104fbc:	89 c2                	mov    %eax,%edx
	if(result < 0)
f0104fbe:	85 c0                	test   %eax,%eax
f0104fc0:	79 2a                	jns    f0104fec <syscall+0x29c>
		page_free(new_page);
f0104fc2:	89 1c 24             	mov    %ebx,(%esp)
f0104fc5:	e8 31 c2 ff ff       	call   f01011fb <page_free>
	return result;
f0104fca:	89 f2                	mov    %esi,%edx
f0104fcc:	eb 1e                	jmp    f0104fec <syscall+0x29c>
		return result;
f0104fce:	89 c2                	mov    %eax,%edx
f0104fd0:	eb 1a                	jmp    f0104fec <syscall+0x29c>
		return -E_INVAL;
f0104fd2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104fd7:	eb 13                	jmp    f0104fec <syscall+0x29c>
f0104fd9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104fde:	eb 0c                	jmp    f0104fec <syscall+0x29c>
		return -E_INVAL;
f0104fe0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104fe5:	eb 05                	jmp    f0104fec <syscall+0x29c>
		return -E_NO_MEM;
f0104fe7:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
		case SYS_env_set_status:
			return sys_env_set_status(a1, (int)a2);	
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void *)a2);
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void *)a2, (int)a3);
f0104fec:	89 d0                	mov    %edx,%eax
f0104fee:	e9 b5 03 00 00       	jmp    f01053a8 <syscall+0x658>
	int result = envid2env(srcenvid, &src_env, 1);
f0104ff3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ffa:	00 
f0104ffb:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105002:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105005:	89 04 24             	mov    %eax,(%esp)
f0105008:	e8 c3 e6 ff ff       	call   f01036d0 <envid2env>
		return result;
f010500d:	89 c2                	mov    %eax,%edx
	if(result < 0)
f010500f:	85 c0                	test   %eax,%eax
f0105011:	0f 88 fa 00 00 00    	js     f0105111 <syscall+0x3c1>
	result = envid2env(dstenvid, &dst_env, 1);
f0105017:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010501e:	00 
f010501f:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105022:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105026:	8b 45 14             	mov    0x14(%ebp),%eax
f0105029:	89 04 24             	mov    %eax,(%esp)
f010502c:	e8 9f e6 ff ff       	call   f01036d0 <envid2env>
	if(result < 0)
f0105031:	85 c0                	test   %eax,%eax
f0105033:	0f 88 a5 00 00 00    	js     f01050de <syscall+0x38e>
	if((unsigned)srcva >= UTOP || (unsigned)srcva & (PGSIZE - 1) ||
f0105039:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105040:	0f 87 9c 00 00 00    	ja     f01050e2 <syscall+0x392>
f0105046:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010504d:	0f 85 96 00 00 00    	jne    f01050e9 <syscall+0x399>
f0105053:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010505a:	0f 87 90 00 00 00    	ja     f01050f0 <syscall+0x3a0>
		(unsigned)dstva >= UTOP || (unsigned)dstva & (PGSIZE - 1))
f0105060:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0105067:	0f 85 8a 00 00 00    	jne    f01050f7 <syscall+0x3a7>
	struct PageInfo *page_info = page_lookup(src_env->env_pgdir, srcva, &page_table_entry);
f010506d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105070:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105074:	8b 45 10             	mov    0x10(%ebp),%eax
f0105077:	89 44 24 04          	mov    %eax,0x4(%esp)
f010507b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010507e:	8b 40 60             	mov    0x60(%eax),%eax
f0105081:	89 04 24             	mov    %eax,(%esp)
f0105084:	e8 c3 c2 ff ff       	call   f010134c <page_lookup>
f0105089:	89 c3                	mov    %eax,%ebx
	if(!page_info)
f010508b:	85 c0                	test   %eax,%eax
f010508d:	74 6f                	je     f01050fe <syscall+0x3ae>
	if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & (~(PTE_P | PTE_U | PTE_W | PTE_AVAIL))))
f010508f:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0105092:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0105097:	83 f8 05             	cmp    $0x5,%eax
f010509a:	75 69                	jne    f0105105 <syscall+0x3b5>
	if((perm & PTE_W) && !(*page_table_entry & PTE_W))
f010509c:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01050a0:	74 08                	je     f01050aa <syscall+0x35a>
f01050a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050a5:	f6 00 02             	testb  $0x2,(%eax)
f01050a8:	74 62                	je     f010510c <syscall+0x3bc>
	result = page_insert(dst_env->env_pgdir, page_info, dstva, perm);
f01050aa:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01050ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01050b1:	8b 45 18             	mov    0x18(%ebp),%eax
f01050b4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01050b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01050bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050bf:	8b 40 60             	mov    0x60(%eax),%eax
f01050c2:	89 04 24             	mov    %eax,(%esp)
f01050c5:	e8 81 c3 ff ff       	call   f010144b <page_insert>
f01050ca:	89 c6                	mov    %eax,%esi
	return result;
f01050cc:	89 c2                	mov    %eax,%edx
	if(result < 0)
f01050ce:	85 c0                	test   %eax,%eax
f01050d0:	79 3f                	jns    f0105111 <syscall+0x3c1>
		page_free(page_info);
f01050d2:	89 1c 24             	mov    %ebx,(%esp)
f01050d5:	e8 21 c1 ff ff       	call   f01011fb <page_free>
	return result;
f01050da:	89 f2                	mov    %esi,%edx
f01050dc:	eb 33                	jmp    f0105111 <syscall+0x3c1>
		return result;
f01050de:	89 c2                	mov    %eax,%edx
f01050e0:	eb 2f                	jmp    f0105111 <syscall+0x3c1>
		return -E_INVAL;
f01050e2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f01050e7:	eb 28                	jmp    f0105111 <syscall+0x3c1>
f01050e9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f01050ee:	eb 21                	jmp    f0105111 <syscall+0x3c1>
f01050f0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f01050f5:	eb 1a                	jmp    f0105111 <syscall+0x3c1>
f01050f7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f01050fc:	eb 13                	jmp    f0105111 <syscall+0x3c1>
		return -E_INVAL;
f01050fe:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105103:	eb 0c                	jmp    f0105111 <syscall+0x3c1>
		return -E_INVAL;
f0105105:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010510a:	eb 05                	jmp    f0105111 <syscall+0x3c1>
		return -E_INVAL;
f010510c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
		case SYS_page_map:
			return sys_page_map(a1, (void *)a2, a3, (void *)a4, (int)a5);
f0105111:	89 d0                	mov    %edx,%eax
f0105113:	e9 90 02 00 00       	jmp    f01053a8 <syscall+0x658>
	int result = envid2env(envid, &env, 1);
f0105118:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010511f:	00 
f0105120:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105123:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105127:	8b 45 0c             	mov    0xc(%ebp),%eax
f010512a:	89 04 24             	mov    %eax,(%esp)
f010512d:	e8 9e e5 ff ff       	call   f01036d0 <envid2env>
	if(result < 0)
f0105132:	85 c0                	test   %eax,%eax
f0105134:	0f 88 6e 02 00 00    	js     f01053a8 <syscall+0x658>
	if((unsigned)va >= UTOP || (unsigned)va & (PGSIZE - 1))
f010513a:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105141:	77 28                	ja     f010516b <syscall+0x41b>
f0105143:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010514a:	75 29                	jne    f0105175 <syscall+0x425>
	page_remove(env->env_pgdir, va);
f010514c:	8b 45 10             	mov    0x10(%ebp),%eax
f010514f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105153:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105156:	8b 40 60             	mov    0x60(%eax),%eax
f0105159:	89 04 24             	mov    %eax,(%esp)
f010515c:	e8 9a c2 ff ff       	call   f01013fb <page_remove>
	return 0;
f0105161:	b8 00 00 00 00       	mov    $0x0,%eax
f0105166:	e9 3d 02 00 00       	jmp    f01053a8 <syscall+0x658>
		return -E_INVAL;
f010516b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105170:	e9 33 02 00 00       	jmp    f01053a8 <syscall+0x658>
f0105175:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void *)a2);
f010517a:	e9 29 02 00 00       	jmp    f01053a8 <syscall+0x658>
	int result = envid2env(envid, &target_env, 0);
f010517f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105186:	00 
f0105187:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010518a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010518e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105191:	89 04 24             	mov    %eax,(%esp)
f0105194:	e8 37 e5 ff ff       	call   f01036d0 <envid2env>
	if(result < 0)
f0105199:	85 c0                	test   %eax,%eax
f010519b:	0f 88 2e 01 00 00    	js     f01052cf <syscall+0x57f>
	if(!target_env->env_ipc_recving || target_env->env_ipc_from)
f01051a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051a4:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01051a8:	0f 84 25 01 00 00    	je     f01052d3 <syscall+0x583>
f01051ae:	8b 58 74             	mov    0x74(%eax),%ebx
f01051b1:	85 db                	test   %ebx,%ebx
f01051b3:	0f 85 21 01 00 00    	jne    f01052da <syscall+0x58a>
	if(srcva && (unsigned)srcva < UTOP){
f01051b9:	8b 45 14             	mov    0x14(%ebp),%eax
f01051bc:	83 e8 01             	sub    $0x1,%eax
f01051bf:	3d fe ff bf ee       	cmp    $0xeebffffe,%eax
f01051c4:	0f 87 d1 00 00 00    	ja     f010529b <syscall+0x54b>
		if((unsigned)srcva & (PGSIZE - 1))
f01051ca:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01051d1:	0f 85 0a 01 00 00    	jne    f01052e1 <syscall+0x591>
		if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & (~(PTE_P | PTE_U | PTE_W | PTE_AVAIL))))
f01051d7:	8b 45 18             	mov    0x18(%ebp),%eax
f01051da:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01051df:	83 f8 05             	cmp    $0x5,%eax
f01051e2:	0f 85 00 01 00 00    	jne    f01052e8 <syscall+0x598>
		if(perm & PTE_W)
f01051e8:	8b 45 18             	mov    0x18(%ebp),%eax
f01051eb:	83 e0 02             	and    $0x2,%eax
		unsigned check_perm = PTE_U | PTE_P;
f01051ee:	83 f8 01             	cmp    $0x1,%eax
f01051f1:	19 f6                	sbb    %esi,%esi
f01051f3:	83 e6 fe             	and    $0xfffffffe,%esi
f01051f6:	83 c6 07             	add    $0x7,%esi
		if(user_mem_check(curenv, srcva, PGSIZE, check_perm) < 0)
f01051f9:	e8 75 15 00 00       	call   f0106773 <cpunum>
f01051fe:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105202:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0105209:	00 
f010520a:	8b 7d 14             	mov    0x14(%ebp),%edi
f010520d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105211:	6b c0 74             	imul   $0x74,%eax,%eax
f0105214:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f010521a:	89 04 24             	mov    %eax,(%esp)
f010521d:	e8 df e2 ff ff       	call   f0103501 <user_mem_check>
f0105222:	85 c0                	test   %eax,%eax
f0105224:	0f 88 c5 00 00 00    	js     f01052ef <syscall+0x59f>
		if(target_env->env_ipc_dstva){
f010522a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010522d:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
f0105231:	74 68                	je     f010529b <syscall+0x54b>
			if (!(page_info = page_lookup(curenv->env_pgdir, srcva, &pte)))
f0105233:	e8 3b 15 00 00       	call   f0106773 <cpunum>
f0105238:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010523b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010523f:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0105242:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105246:	6b c0 74             	imul   $0x74,%eax,%eax
f0105249:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f010524f:	8b 40 60             	mov    0x60(%eax),%eax
f0105252:	89 04 24             	mov    %eax,(%esp)
f0105255:	e8 f2 c0 ff ff       	call   f010134c <page_lookup>
f010525a:	85 c0                	test   %eax,%eax
f010525c:	74 2f                	je     f010528d <syscall+0x53d>
			result = page_insert(target_env->env_pgdir, page_info, target_env->env_ipc_dstva, perm);
f010525e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105261:	8b 7d 18             	mov    0x18(%ebp),%edi
f0105264:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105268:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f010526b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010526f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105273:	8b 42 60             	mov    0x60(%edx),%eax
f0105276:	89 04 24             	mov    %eax,(%esp)
f0105279:	e8 cd c1 ff ff       	call   f010144b <page_insert>
			if(result < 0)
f010527e:	85 c0                	test   %eax,%eax
f0105280:	78 12                	js     f0105294 <syscall+0x544>
			target_env->env_ipc_perm = perm;
f0105282:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105285:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105288:	89 48 78             	mov    %ecx,0x78(%eax)
f010528b:	eb 0e                	jmp    f010529b <syscall+0x54b>
				return -E_INVAL;
f010528d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105292:	eb 60                	jmp    f01052f4 <syscall+0x5a4>
				return -E_NO_MEM;
f0105294:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0105299:	eb 59                	jmp    f01052f4 <syscall+0x5a4>
	target_env->env_ipc_value = value;
f010529b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010529e:	8b 45 10             	mov    0x10(%ebp),%eax
f01052a1:	89 46 70             	mov    %eax,0x70(%esi)
	target_env->env_ipc_from = curenv->env_id;
f01052a4:	e8 ca 14 00 00       	call   f0106773 <cpunum>
f01052a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01052ac:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f01052b2:	8b 40 48             	mov    0x48(%eax),%eax
f01052b5:	89 46 74             	mov    %eax,0x74(%esi)
	target_env->env_status = ENV_RUNNABLE;
f01052b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052bb:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	target_env->env_ipc_recving = false;
f01052c2:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	target_env->env_tf.tf_regs.reg_eax = 0;
f01052c6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f01052cd:	eb 25                	jmp    f01052f4 <syscall+0x5a4>
		return result;
f01052cf:	89 c3                	mov    %eax,%ebx
f01052d1:	eb 21                	jmp    f01052f4 <syscall+0x5a4>
		return -E_IPC_NOT_RECV;
f01052d3:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f01052d8:	eb 1a                	jmp    f01052f4 <syscall+0x5a4>
f01052da:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f01052df:	eb 13                	jmp    f01052f4 <syscall+0x5a4>
			return -E_INVAL;
f01052e1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01052e6:	eb 0c                	jmp    f01052f4 <syscall+0x5a4>
			return -E_INVAL;
f01052e8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01052ed:	eb 05                	jmp    f01052f4 <syscall+0x5a4>
			return -E_INVAL;
f01052ef:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f01052f4:	89 d8                	mov    %ebx,%eax
f01052f6:	e9 ad 00 00 00       	jmp    f01053a8 <syscall+0x658>
	if(dstva && (unsigned)dstva < UTOP && (unsigned)dstva & (PGSIZE - 1))
f01052fb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01052fe:	83 e8 01             	sub    $0x1,%eax
f0105301:	3d fe ff bf ee       	cmp    $0xeebffffe,%eax
f0105306:	77 0d                	ja     f0105315 <syscall+0x5c5>
f0105308:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f010530f:	0f 85 8e 00 00 00    	jne    f01053a3 <syscall+0x653>
	curenv->env_ipc_recving = true;
f0105315:	e8 59 14 00 00       	call   f0106773 <cpunum>
f010531a:	6b c0 74             	imul   $0x74,%eax,%eax
f010531d:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0105323:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f0105327:	e8 47 14 00 00       	call   f0106773 <cpunum>
f010532c:	6b c0 74             	imul   $0x74,%eax,%eax
f010532f:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0105335:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	curenv->env_ipc_dstva = dstva;
f010533c:	e8 32 14 00 00       	call   f0106773 <cpunum>
f0105341:	6b c0 74             	imul   $0x74,%eax,%eax
f0105344:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f010534a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010534d:	89 48 6c             	mov    %ecx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0105350:	e8 1e 14 00 00       	call   f0106773 <cpunum>
f0105355:	6b c0 74             	imul   $0x74,%eax,%eax
f0105358:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f010535e:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0105365:	e8 1d f9 ff ff       	call   f0104c87 <sched_yield>
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
f010536a:	8b 75 10             	mov    0x10(%ebp),%esi
	int result = envid2env(envid, &env, 1);
f010536d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105374:	00 
f0105375:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105378:	89 44 24 04          	mov    %eax,0x4(%esp)
f010537c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010537f:	89 04 24             	mov    %eax,(%esp)
f0105382:	e8 49 e3 ff ff       	call   f01036d0 <envid2env>
	if(result < 0)
f0105387:	85 c0                	test   %eax,%eax
f0105389:	78 1d                	js     f01053a8 <syscall+0x658>
	env->env_tf = *tf;
f010538b:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105393:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return 0;
f0105395:	b8 00 00 00 00       	mov    $0x0,%eax
f010539a:	eb 0c                	jmp    f01053a8 <syscall+0x658>
		default:
			return -E_INVAL;
f010539c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01053a1:	eb 05                	jmp    f01053a8 <syscall+0x658>
			return sys_ipc_recv((void *)a1);
f01053a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f01053a8:	83 c4 2c             	add    $0x2c,%esp
f01053ab:	5b                   	pop    %ebx
f01053ac:	5e                   	pop    %esi
f01053ad:	5f                   	pop    %edi
f01053ae:	5d                   	pop    %ebp
f01053af:	c3                   	ret    

f01053b0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01053b0:	55                   	push   %ebp
f01053b1:	89 e5                	mov    %esp,%ebp
f01053b3:	57                   	push   %edi
f01053b4:	56                   	push   %esi
f01053b5:	53                   	push   %ebx
f01053b6:	83 ec 14             	sub    $0x14,%esp
f01053b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01053bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01053bf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01053c2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01053c5:	8b 1a                	mov    (%edx),%ebx
f01053c7:	8b 01                	mov    (%ecx),%eax
f01053c9:	89 45 f0             	mov    %eax,-0x10(%ebp)

	while (l <= r) {
f01053cc:	39 c3                	cmp    %eax,%ebx
f01053ce:	0f 8f 9a 00 00 00    	jg     f010546e <stab_binsearch+0xbe>
	int l = *region_left, r = *region_right, any_matches = 0;
f01053d4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f01053db:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01053de:	01 d8                	add    %ebx,%eax
f01053e0:	89 c7                	mov    %eax,%edi
f01053e2:	c1 ef 1f             	shr    $0x1f,%edi
f01053e5:	01 c7                	add    %eax,%edi
f01053e7:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01053e9:	39 df                	cmp    %ebx,%edi
f01053eb:	0f 8c c4 00 00 00    	jl     f01054b5 <stab_binsearch+0x105>
f01053f1:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01053f4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01053f7:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01053fa:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f01053fe:	39 f0                	cmp    %esi,%eax
f0105400:	0f 84 b4 00 00 00    	je     f01054ba <stab_binsearch+0x10a>
		int true_m = (l + r) / 2, m = true_m;
f0105406:	89 f8                	mov    %edi,%eax
			m--;
f0105408:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f010540b:	39 d8                	cmp    %ebx,%eax
f010540d:	0f 8c a2 00 00 00    	jl     f01054b5 <stab_binsearch+0x105>
f0105413:	0f b6 4a f8          	movzbl -0x8(%edx),%ecx
f0105417:	83 ea 0c             	sub    $0xc,%edx
f010541a:	39 f1                	cmp    %esi,%ecx
f010541c:	75 ea                	jne    f0105408 <stab_binsearch+0x58>
f010541e:	e9 99 00 00 00       	jmp    f01054bc <stab_binsearch+0x10c>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0105423:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105426:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0105428:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f010542b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105432:	eb 2b                	jmp    f010545f <stab_binsearch+0xaf>
		} else if (stabs[m].n_value > addr) {
f0105434:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105437:	76 14                	jbe    f010544d <stab_binsearch+0x9d>
			*region_right = m - 1;
f0105439:	83 e8 01             	sub    $0x1,%eax
f010543c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010543f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105442:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0105444:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010544b:	eb 12                	jmp    f010545f <stab_binsearch+0xaf>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010544d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105450:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0105452:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105456:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0105458:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f010545f:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105462:	0f 8e 73 ff ff ff    	jle    f01053db <stab_binsearch+0x2b>
		}
	}

	if (!any_matches)
f0105468:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010546c:	75 0f                	jne    f010547d <stab_binsearch+0xcd>
		*region_right = *region_left - 1;
f010546e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105471:	8b 00                	mov    (%eax),%eax
f0105473:	83 e8 01             	sub    $0x1,%eax
f0105476:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105479:	89 06                	mov    %eax,(%esi)
f010547b:	eb 57                	jmp    f01054d4 <stab_binsearch+0x124>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010547d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105480:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105485:	8b 0f                	mov    (%edi),%ecx
		for (l = *region_right;
f0105487:	39 c8                	cmp    %ecx,%eax
f0105489:	7e 23                	jle    f01054ae <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f010548b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010548e:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0105491:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0105494:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0105498:	39 f3                	cmp    %esi,%ebx
f010549a:	74 12                	je     f01054ae <stab_binsearch+0xfe>
		     l--)
f010549c:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f010549f:	39 c8                	cmp    %ecx,%eax
f01054a1:	7e 0b                	jle    f01054ae <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f01054a3:	0f b6 5a f8          	movzbl -0x8(%edx),%ebx
f01054a7:	83 ea 0c             	sub    $0xc,%edx
f01054aa:	39 f3                	cmp    %esi,%ebx
f01054ac:	75 ee                	jne    f010549c <stab_binsearch+0xec>
			/* do nothing */;
		*region_left = l;
f01054ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01054b1:	89 06                	mov    %eax,(%esi)
f01054b3:	eb 1f                	jmp    f01054d4 <stab_binsearch+0x124>
			l = true_m + 1;
f01054b5:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01054b8:	eb a5                	jmp    f010545f <stab_binsearch+0xaf>
		int true_m = (l + r) / 2, m = true_m;
f01054ba:	89 f8                	mov    %edi,%eax
		if (stabs[m].n_value < addr) {
f01054bc:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01054bf:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01054c2:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01054c6:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01054c9:	0f 82 54 ff ff ff    	jb     f0105423 <stab_binsearch+0x73>
f01054cf:	e9 60 ff ff ff       	jmp    f0105434 <stab_binsearch+0x84>
	}
}
f01054d4:	83 c4 14             	add    $0x14,%esp
f01054d7:	5b                   	pop    %ebx
f01054d8:	5e                   	pop    %esi
f01054d9:	5f                   	pop    %edi
f01054da:	5d                   	pop    %ebp
f01054db:	c3                   	ret    

f01054dc <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01054dc:	55                   	push   %ebp
f01054dd:	89 e5                	mov    %esp,%ebp
f01054df:	57                   	push   %edi
f01054e0:	56                   	push   %esi
f01054e1:	53                   	push   %ebx
f01054e2:	83 ec 4c             	sub    $0x4c,%esp
f01054e5:	8b 7d 08             	mov    0x8(%ebp),%edi
f01054e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01054eb:	c7 03 b8 85 10 f0    	movl   $0xf01085b8,(%ebx)
	info->eip_line = 0;
f01054f1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01054f8:	c7 43 08 b8 85 10 f0 	movl   $0xf01085b8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01054ff:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105506:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105509:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105510:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0105516:	0f 87 c1 00 00 00    	ja     f01055dd <debuginfo_eip+0x101>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010551c:	e8 52 12 00 00       	call   f0106773 <cpunum>
f0105521:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105528:	00 
f0105529:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105530:	00 
f0105531:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105538:	00 
f0105539:	6b c0 74             	imul   $0x74,%eax,%eax
f010553c:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0105542:	89 04 24             	mov    %eax,(%esp)
f0105545:	e8 b7 df ff ff       	call   f0103501 <user_mem_check>
f010554a:	85 c0                	test   %eax,%eax
f010554c:	0f 85 6a 02 00 00    	jne    f01057bc <debuginfo_eip+0x2e0>
			return -1;

		stabs = usd->stabs;
f0105552:	a1 00 00 20 00       	mov    0x200000,%eax
f0105557:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010555a:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0105560:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0105566:	89 55 c0             	mov    %edx,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0105569:	a1 0c 00 20 00       	mov    0x20000c,%eax
f010556e:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, stabs, sizeof(struct Stab) * (stab_end - stabs), PTE_U))
f0105571:	e8 fd 11 00 00       	call   f0106773 <cpunum>
f0105576:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010557d:	00 
f010557e:	89 f2                	mov    %esi,%edx
f0105580:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105583:	29 ca                	sub    %ecx,%edx
f0105585:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105589:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010558d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105590:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f0105596:	89 04 24             	mov    %eax,(%esp)
f0105599:	e8 63 df ff ff       	call   f0103501 <user_mem_check>
f010559e:	85 c0                	test   %eax,%eax
f01055a0:	0f 85 1d 02 00 00    	jne    f01057c3 <debuginfo_eip+0x2e7>
			return -1;
		if(user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
f01055a6:	e8 c8 11 00 00       	call   f0106773 <cpunum>
f01055ab:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01055b2:	00 
f01055b3:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01055b6:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01055b9:	29 ca                	sub    %ecx,%edx
f01055bb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01055bf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01055c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01055c6:	8b 80 28 20 20 f0    	mov    -0xfdfdfd8(%eax),%eax
f01055cc:	89 04 24             	mov    %eax,(%esp)
f01055cf:	e8 2d df ff ff       	call   f0103501 <user_mem_check>
f01055d4:	85 c0                	test   %eax,%eax
f01055d6:	74 1f                	je     f01055f7 <debuginfo_eip+0x11b>
f01055d8:	e9 ed 01 00 00       	jmp    f01057ca <debuginfo_eip+0x2ee>
		stabstr_end = __STABSTR_END__;
f01055dd:	c7 45 bc 5e 6b 11 f0 	movl   $0xf0116b5e,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01055e4:	c7 45 c0 81 33 11 f0 	movl   $0xf0113381,-0x40(%ebp)
		stab_end = __STAB_END__;
f01055eb:	be 80 33 11 f0       	mov    $0xf0113380,%esi
		stabs = __STAB_BEGIN__;
f01055f0:	c7 45 c4 50 8b 10 f0 	movl   $0xf0108b50,-0x3c(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01055f7:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01055fa:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f01055fd:	0f 83 ce 01 00 00    	jae    f01057d1 <debuginfo_eip+0x2f5>
f0105603:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0105607:	0f 85 cb 01 00 00    	jne    f01057d8 <debuginfo_eip+0x2fc>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010560d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105614:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f0105617:	c1 fe 02             	sar    $0x2,%esi
f010561a:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0105620:	83 e8 01             	sub    $0x1,%eax
f0105623:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105626:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010562a:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105631:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105634:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105637:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010563a:	89 f0                	mov    %esi,%eax
f010563c:	e8 6f fd ff ff       	call   f01053b0 <stab_binsearch>
	if (lfile == 0)
f0105641:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105644:	85 c0                	test   %eax,%eax
f0105646:	0f 84 93 01 00 00    	je     f01057df <debuginfo_eip+0x303>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010564c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010564f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105652:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105655:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105659:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105660:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105663:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105666:	89 f0                	mov    %esi,%eax
f0105668:	e8 43 fd ff ff       	call   f01053b0 <stab_binsearch>

	if (lfun <= rfun) {
f010566d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105670:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105673:	39 f0                	cmp    %esi,%eax
f0105675:	7f 32                	jg     f01056a9 <debuginfo_eip+0x1cd>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105677:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010567a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010567d:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0105680:	8b 0a                	mov    (%edx),%ecx
f0105682:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f0105685:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0105688:	2b 4d c0             	sub    -0x40(%ebp),%ecx
f010568b:	39 4d b8             	cmp    %ecx,-0x48(%ebp)
f010568e:	73 09                	jae    f0105699 <debuginfo_eip+0x1bd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105690:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0105693:	03 4d c0             	add    -0x40(%ebp),%ecx
f0105696:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105699:	8b 52 08             	mov    0x8(%edx),%edx
f010569c:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010569f:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f01056a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01056a4:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01056a7:	eb 0f                	jmp    f01056b8 <debuginfo_eip+0x1dc>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01056a9:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f01056ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01056b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01056b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01056b8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01056bf:	00 
f01056c0:	8b 43 08             	mov    0x8(%ebx),%eax
f01056c3:	89 04 24             	mov    %eax,(%esp)
f01056c6:	e8 e4 09 00 00       	call   f01060af <strfind>
f01056cb:	2b 43 08             	sub    0x8(%ebx),%eax
f01056ce:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01056d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01056d5:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01056dc:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01056df:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01056e2:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01056e5:	89 f0                	mov    %esi,%eax
f01056e7:	e8 c4 fc ff ff       	call   f01053b0 <stab_binsearch>
	if (lline <= rline)
f01056ec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01056ef:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01056f2:	0f 8f ee 00 00 00    	jg     f01057e6 <debuginfo_eip+0x30a>
		info->eip_line = stabs[lline].n_desc;
f01056f8:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01056fb:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0105700:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105703:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0105706:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105709:	39 f9                	cmp    %edi,%ecx
f010570b:	7c 62                	jl     f010576f <debuginfo_eip+0x293>
	       && stabs[lline].n_type != N_SOL
f010570d:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0105710:	c1 e0 02             	shl    $0x2,%eax
f0105713:	8d 14 06             	lea    (%esi,%eax,1),%edx
f0105716:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0105719:	0f b6 52 04          	movzbl 0x4(%edx),%edx
f010571d:	80 fa 84             	cmp    $0x84,%dl
f0105720:	74 35                	je     f0105757 <debuginfo_eip+0x27b>
f0105722:	8d 44 06 f4          	lea    -0xc(%esi,%eax,1),%eax
f0105726:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0105729:	eb 1a                	jmp    f0105745 <debuginfo_eip+0x269>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010572b:	83 e9 01             	sub    $0x1,%ecx
	while (lline >= lfile
f010572e:	39 f9                	cmp    %edi,%ecx
f0105730:	7c 3d                	jl     f010576f <debuginfo_eip+0x293>
	       && stabs[lline].n_type != N_SOL
f0105732:	89 c6                	mov    %eax,%esi
f0105734:	83 e8 0c             	sub    $0xc,%eax
f0105737:	0f b6 50 10          	movzbl 0x10(%eax),%edx
f010573b:	80 fa 84             	cmp    $0x84,%dl
f010573e:	75 05                	jne    f0105745 <debuginfo_eip+0x269>
f0105740:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0105743:	eb 12                	jmp    f0105757 <debuginfo_eip+0x27b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105745:	80 fa 64             	cmp    $0x64,%dl
f0105748:	75 e1                	jne    f010572b <debuginfo_eip+0x24f>
f010574a:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f010574e:	74 db                	je     f010572b <debuginfo_eip+0x24f>
f0105750:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105753:	39 cf                	cmp    %ecx,%edi
f0105755:	7f 18                	jg     f010576f <debuginfo_eip+0x293>
f0105757:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f010575a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010575d:	8b 04 87             	mov    (%edi,%eax,4),%eax
f0105760:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105763:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0105766:	39 d0                	cmp    %edx,%eax
f0105768:	73 05                	jae    f010576f <debuginfo_eip+0x293>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010576a:	03 45 c0             	add    -0x40(%ebp),%eax
f010576d:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010576f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105772:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105775:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f010577a:	39 f2                	cmp    %esi,%edx
f010577c:	0f 8d 85 00 00 00    	jge    f0105807 <debuginfo_eip+0x32b>
		for (lline = lfun + 1;
f0105782:	8d 42 01             	lea    0x1(%edx),%eax
f0105785:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105788:	39 c6                	cmp    %eax,%esi
f010578a:	7e 61                	jle    f01057ed <debuginfo_eip+0x311>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010578c:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f010578f:	c1 e1 02             	shl    $0x2,%ecx
f0105792:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105795:	80 7c 0f 04 a0       	cmpb   $0xa0,0x4(%edi,%ecx,1)
f010579a:	75 58                	jne    f01057f4 <debuginfo_eip+0x318>
f010579c:	8d 42 02             	lea    0x2(%edx),%eax
f010579f:	8d 54 0f f4          	lea    -0xc(%edi,%ecx,1),%edx
			info->eip_fn_narg++;
f01057a3:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f01057a7:	39 f0                	cmp    %esi,%eax
f01057a9:	74 50                	je     f01057fb <debuginfo_eip+0x31f>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01057ab:	0f b6 4a 1c          	movzbl 0x1c(%edx),%ecx
f01057af:	83 c0 01             	add    $0x1,%eax
f01057b2:	83 c2 0c             	add    $0xc,%edx
f01057b5:	80 f9 a0             	cmp    $0xa0,%cl
f01057b8:	74 e9                	je     f01057a3 <debuginfo_eip+0x2c7>
f01057ba:	eb 46                	jmp    f0105802 <debuginfo_eip+0x326>
			return -1;
f01057bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057c1:	eb 44                	jmp    f0105807 <debuginfo_eip+0x32b>
			return -1;
f01057c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057c8:	eb 3d                	jmp    f0105807 <debuginfo_eip+0x32b>
			return -1;
f01057ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057cf:	eb 36                	jmp    f0105807 <debuginfo_eip+0x32b>
		return -1;
f01057d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057d6:	eb 2f                	jmp    f0105807 <debuginfo_eip+0x32b>
f01057d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057dd:	eb 28                	jmp    f0105807 <debuginfo_eip+0x32b>
		return -1;
f01057df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057e4:	eb 21                	jmp    f0105807 <debuginfo_eip+0x32b>
		return -1;
f01057e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057eb:	eb 1a                	jmp    f0105807 <debuginfo_eip+0x32b>
	return 0;
f01057ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01057f2:	eb 13                	jmp    f0105807 <debuginfo_eip+0x32b>
f01057f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01057f9:	eb 0c                	jmp    f0105807 <debuginfo_eip+0x32b>
f01057fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0105800:	eb 05                	jmp    f0105807 <debuginfo_eip+0x32b>
f0105802:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105807:	83 c4 4c             	add    $0x4c,%esp
f010580a:	5b                   	pop    %ebx
f010580b:	5e                   	pop    %esi
f010580c:	5f                   	pop    %edi
f010580d:	5d                   	pop    %ebp
f010580e:	c3                   	ret    
f010580f:	90                   	nop

f0105810 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105810:	55                   	push   %ebp
f0105811:	89 e5                	mov    %esp,%ebp
f0105813:	57                   	push   %edi
f0105814:	56                   	push   %esi
f0105815:	53                   	push   %ebx
f0105816:	83 ec 3c             	sub    $0x3c,%esp
f0105819:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010581c:	89 d7                	mov    %edx,%edi
f010581e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105821:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105824:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105827:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010582a:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010582d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105832:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105835:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105838:	39 f1                	cmp    %esi,%ecx
f010583a:	72 14                	jb     f0105850 <printnum+0x40>
f010583c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f010583f:	76 0f                	jbe    f0105850 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105841:	8b 45 14             	mov    0x14(%ebp),%eax
f0105844:	8d 70 ff             	lea    -0x1(%eax),%esi
f0105847:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010584a:	85 f6                	test   %esi,%esi
f010584c:	7f 60                	jg     f01058ae <printnum+0x9e>
f010584e:	eb 72                	jmp    f01058c2 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105850:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105853:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105857:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010585a:	8d 51 ff             	lea    -0x1(%ecx),%edx
f010585d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105861:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105865:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105869:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010586d:	89 c3                	mov    %eax,%ebx
f010586f:	89 d6                	mov    %edx,%esi
f0105871:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105874:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105877:	89 54 24 08          	mov    %edx,0x8(%esp)
f010587b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010587f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105882:	89 04 24             	mov    %eax,(%esp)
f0105885:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105888:	89 44 24 04          	mov    %eax,0x4(%esp)
f010588c:	e8 5f 13 00 00       	call   f0106bf0 <__udivdi3>
f0105891:	89 d9                	mov    %ebx,%ecx
f0105893:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105897:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010589b:	89 04 24             	mov    %eax,(%esp)
f010589e:	89 54 24 04          	mov    %edx,0x4(%esp)
f01058a2:	89 fa                	mov    %edi,%edx
f01058a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058a7:	e8 64 ff ff ff       	call   f0105810 <printnum>
f01058ac:	eb 14                	jmp    f01058c2 <printnum+0xb2>
			putch(padc, putdat);
f01058ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01058b2:	8b 45 18             	mov    0x18(%ebp),%eax
f01058b5:	89 04 24             	mov    %eax,(%esp)
f01058b8:	ff d3                	call   *%ebx
		while (--width > 0)
f01058ba:	83 ee 01             	sub    $0x1,%esi
f01058bd:	75 ef                	jne    f01058ae <printnum+0x9e>
f01058bf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01058c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01058c6:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01058ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01058cd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01058d0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01058d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01058d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058db:	89 04 24             	mov    %eax,(%esp)
f01058de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01058e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058e5:	e8 36 14 00 00       	call   f0106d20 <__umoddi3>
f01058ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01058ee:	0f be 80 c2 85 10 f0 	movsbl -0xfef7a3e(%eax),%eax
f01058f5:	89 04 24             	mov    %eax,(%esp)
f01058f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058fb:	ff d0                	call   *%eax
}
f01058fd:	83 c4 3c             	add    $0x3c,%esp
f0105900:	5b                   	pop    %ebx
f0105901:	5e                   	pop    %esi
f0105902:	5f                   	pop    %edi
f0105903:	5d                   	pop    %ebp
f0105904:	c3                   	ret    

f0105905 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105905:	55                   	push   %ebp
f0105906:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105908:	83 fa 01             	cmp    $0x1,%edx
f010590b:	7e 0e                	jle    f010591b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010590d:	8b 10                	mov    (%eax),%edx
f010590f:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105912:	89 08                	mov    %ecx,(%eax)
f0105914:	8b 02                	mov    (%edx),%eax
f0105916:	8b 52 04             	mov    0x4(%edx),%edx
f0105919:	eb 22                	jmp    f010593d <getuint+0x38>
	else if (lflag)
f010591b:	85 d2                	test   %edx,%edx
f010591d:	74 10                	je     f010592f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010591f:	8b 10                	mov    (%eax),%edx
f0105921:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105924:	89 08                	mov    %ecx,(%eax)
f0105926:	8b 02                	mov    (%edx),%eax
f0105928:	ba 00 00 00 00       	mov    $0x0,%edx
f010592d:	eb 0e                	jmp    f010593d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010592f:	8b 10                	mov    (%eax),%edx
f0105931:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105934:	89 08                	mov    %ecx,(%eax)
f0105936:	8b 02                	mov    (%edx),%eax
f0105938:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010593d:	5d                   	pop    %ebp
f010593e:	c3                   	ret    

f010593f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010593f:	55                   	push   %ebp
f0105940:	89 e5                	mov    %esp,%ebp
f0105942:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105945:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105949:	8b 10                	mov    (%eax),%edx
f010594b:	3b 50 04             	cmp    0x4(%eax),%edx
f010594e:	73 0a                	jae    f010595a <sprintputch+0x1b>
		*b->buf++ = ch;
f0105950:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105953:	89 08                	mov    %ecx,(%eax)
f0105955:	8b 45 08             	mov    0x8(%ebp),%eax
f0105958:	88 02                	mov    %al,(%edx)
}
f010595a:	5d                   	pop    %ebp
f010595b:	c3                   	ret    

f010595c <printfmt>:
{
f010595c:	55                   	push   %ebp
f010595d:	89 e5                	mov    %esp,%ebp
f010595f:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
f0105962:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105965:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105969:	8b 45 10             	mov    0x10(%ebp),%eax
f010596c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105970:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105973:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105977:	8b 45 08             	mov    0x8(%ebp),%eax
f010597a:	89 04 24             	mov    %eax,(%esp)
f010597d:	e8 02 00 00 00       	call   f0105984 <vprintfmt>
}
f0105982:	c9                   	leave  
f0105983:	c3                   	ret    

f0105984 <vprintfmt>:
{
f0105984:	55                   	push   %ebp
f0105985:	89 e5                	mov    %esp,%ebp
f0105987:	57                   	push   %edi
f0105988:	56                   	push   %esi
f0105989:	53                   	push   %ebx
f010598a:	83 ec 3c             	sub    $0x3c,%esp
f010598d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105990:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105993:	eb 18                	jmp    f01059ad <vprintfmt+0x29>
			if (ch == '\0')
f0105995:	85 c0                	test   %eax,%eax
f0105997:	0f 84 c3 03 00 00    	je     f0105d60 <vprintfmt+0x3dc>
			putch(ch, putdat);
f010599d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01059a1:	89 04 24             	mov    %eax,(%esp)
f01059a4:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01059a7:	89 f3                	mov    %esi,%ebx
f01059a9:	eb 02                	jmp    f01059ad <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
f01059ab:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01059ad:	8d 73 01             	lea    0x1(%ebx),%esi
f01059b0:	0f b6 03             	movzbl (%ebx),%eax
f01059b3:	83 f8 25             	cmp    $0x25,%eax
f01059b6:	75 dd                	jne    f0105995 <vprintfmt+0x11>
f01059b8:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
f01059bc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01059c3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f01059ca:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01059d1:	ba 00 00 00 00       	mov    $0x0,%edx
f01059d6:	eb 1d                	jmp    f01059f5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
f01059d8:	89 de                	mov    %ebx,%esi
			padc = '-';
f01059da:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
f01059de:	eb 15                	jmp    f01059f5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
f01059e0:	89 de                	mov    %ebx,%esi
			padc = '0';
f01059e2:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
f01059e6:	eb 0d                	jmp    f01059f5 <vprintfmt+0x71>
				width = precision, precision = -1;
f01059e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01059eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01059ee:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01059f5:	8d 5e 01             	lea    0x1(%esi),%ebx
f01059f8:	0f b6 06             	movzbl (%esi),%eax
f01059fb:	0f b6 c8             	movzbl %al,%ecx
f01059fe:	83 e8 23             	sub    $0x23,%eax
f0105a01:	3c 55                	cmp    $0x55,%al
f0105a03:	0f 87 2f 03 00 00    	ja     f0105d38 <vprintfmt+0x3b4>
f0105a09:	0f b6 c0             	movzbl %al,%eax
f0105a0c:	ff 24 85 00 87 10 f0 	jmp    *-0xfef7900(,%eax,4)
				precision = precision * 10 + ch - '0';
f0105a13:	8d 41 d0             	lea    -0x30(%ecx),%eax
f0105a16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
f0105a19:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0105a1d:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0105a20:	83 f9 09             	cmp    $0x9,%ecx
f0105a23:	77 50                	ja     f0105a75 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
f0105a25:	89 de                	mov    %ebx,%esi
f0105a27:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
f0105a2a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0105a2d:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0105a30:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0105a34:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105a37:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0105a3a:	83 fb 09             	cmp    $0x9,%ebx
f0105a3d:	76 eb                	jbe    f0105a2a <vprintfmt+0xa6>
f0105a3f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0105a42:	eb 33                	jmp    f0105a77 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
f0105a44:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a47:	8d 48 04             	lea    0x4(%eax),%ecx
f0105a4a:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105a4d:	8b 00                	mov    (%eax),%eax
f0105a4f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105a52:	89 de                	mov    %ebx,%esi
			goto process_precision;
f0105a54:	eb 21                	jmp    f0105a77 <vprintfmt+0xf3>
f0105a56:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105a59:	85 c9                	test   %ecx,%ecx
f0105a5b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a60:	0f 49 c1             	cmovns %ecx,%eax
f0105a63:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105a66:	89 de                	mov    %ebx,%esi
f0105a68:	eb 8b                	jmp    f01059f5 <vprintfmt+0x71>
f0105a6a:	89 de                	mov    %ebx,%esi
			altflag = 1;
f0105a6c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105a73:	eb 80                	jmp    f01059f5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
f0105a75:	89 de                	mov    %ebx,%esi
			if (width < 0)
f0105a77:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105a7b:	0f 89 74 ff ff ff    	jns    f01059f5 <vprintfmt+0x71>
f0105a81:	e9 62 ff ff ff       	jmp    f01059e8 <vprintfmt+0x64>
			lflag++;
f0105a86:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
f0105a89:	89 de                	mov    %ebx,%esi
			goto reswitch;
f0105a8b:	e9 65 ff ff ff       	jmp    f01059f5 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
f0105a90:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a93:	8d 50 04             	lea    0x4(%eax),%edx
f0105a96:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a99:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a9d:	8b 00                	mov    (%eax),%eax
f0105a9f:	89 04 24             	mov    %eax,(%esp)
f0105aa2:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105aa5:	e9 03 ff ff ff       	jmp    f01059ad <vprintfmt+0x29>
			err = va_arg(ap, int);
f0105aaa:	8b 45 14             	mov    0x14(%ebp),%eax
f0105aad:	8d 50 04             	lea    0x4(%eax),%edx
f0105ab0:	89 55 14             	mov    %edx,0x14(%ebp)
f0105ab3:	8b 00                	mov    (%eax),%eax
f0105ab5:	99                   	cltd   
f0105ab6:	31 d0                	xor    %edx,%eax
f0105ab8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105aba:	83 f8 0f             	cmp    $0xf,%eax
f0105abd:	7f 0b                	jg     f0105aca <vprintfmt+0x146>
f0105abf:	8b 14 85 60 88 10 f0 	mov    -0xfef77a0(,%eax,4),%edx
f0105ac6:	85 d2                	test   %edx,%edx
f0105ac8:	75 20                	jne    f0105aea <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
f0105aca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ace:	c7 44 24 08 da 85 10 	movl   $0xf01085da,0x8(%esp)
f0105ad5:	f0 
f0105ad6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105ada:	8b 45 08             	mov    0x8(%ebp),%eax
f0105add:	89 04 24             	mov    %eax,(%esp)
f0105ae0:	e8 77 fe ff ff       	call   f010595c <printfmt>
f0105ae5:	e9 c3 fe ff ff       	jmp    f01059ad <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
f0105aea:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105aee:	c7 44 24 08 77 74 10 	movl   $0xf0107477,0x8(%esp)
f0105af5:	f0 
f0105af6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105afa:	8b 45 08             	mov    0x8(%ebp),%eax
f0105afd:	89 04 24             	mov    %eax,(%esp)
f0105b00:	e8 57 fe ff ff       	call   f010595c <printfmt>
f0105b05:	e9 a3 fe ff ff       	jmp    f01059ad <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
f0105b0a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0105b0d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f0105b10:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b13:	8d 50 04             	lea    0x4(%eax),%edx
f0105b16:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b19:	8b 00                	mov    (%eax),%eax
				p = "(null)";
f0105b1b:	85 c0                	test   %eax,%eax
f0105b1d:	ba d3 85 10 f0       	mov    $0xf01085d3,%edx
f0105b22:	0f 45 d0             	cmovne %eax,%edx
f0105b25:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0105b28:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
f0105b2c:	74 04                	je     f0105b32 <vprintfmt+0x1ae>
f0105b2e:	85 f6                	test   %esi,%esi
f0105b30:	7f 19                	jg     f0105b4b <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105b32:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105b35:	8d 70 01             	lea    0x1(%eax),%esi
f0105b38:	0f b6 10             	movzbl (%eax),%edx
f0105b3b:	0f be c2             	movsbl %dl,%eax
f0105b3e:	85 c0                	test   %eax,%eax
f0105b40:	0f 85 95 00 00 00    	jne    f0105bdb <vprintfmt+0x257>
f0105b46:	e9 85 00 00 00       	jmp    f0105bd0 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105b4b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105b4f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105b52:	89 04 24             	mov    %eax,(%esp)
f0105b55:	e8 98 03 00 00       	call   f0105ef2 <strnlen>
f0105b5a:	29 c6                	sub    %eax,%esi
f0105b5c:	89 f0                	mov    %esi,%eax
f0105b5e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0105b61:	85 f6                	test   %esi,%esi
f0105b63:	7e cd                	jle    f0105b32 <vprintfmt+0x1ae>
					putch(padc, putdat);
f0105b65:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0105b69:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105b6c:	89 c3                	mov    %eax,%ebx
f0105b6e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105b72:	89 34 24             	mov    %esi,(%esp)
f0105b75:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0105b78:	83 eb 01             	sub    $0x1,%ebx
f0105b7b:	75 f1                	jne    f0105b6e <vprintfmt+0x1ea>
f0105b7d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0105b80:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105b83:	eb ad                	jmp    f0105b32 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
f0105b85:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105b89:	74 1e                	je     f0105ba9 <vprintfmt+0x225>
f0105b8b:	0f be d2             	movsbl %dl,%edx
f0105b8e:	83 ea 20             	sub    $0x20,%edx
f0105b91:	83 fa 5e             	cmp    $0x5e,%edx
f0105b94:	76 13                	jbe    f0105ba9 <vprintfmt+0x225>
					putch('?', putdat);
f0105b96:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b99:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b9d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105ba4:	ff 55 08             	call   *0x8(%ebp)
f0105ba7:	eb 0d                	jmp    f0105bb6 <vprintfmt+0x232>
					putch(ch, putdat);
f0105ba9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105bac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105bb0:	89 04 24             	mov    %eax,(%esp)
f0105bb3:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105bb6:	83 ef 01             	sub    $0x1,%edi
f0105bb9:	83 c6 01             	add    $0x1,%esi
f0105bbc:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f0105bc0:	0f be c2             	movsbl %dl,%eax
f0105bc3:	85 c0                	test   %eax,%eax
f0105bc5:	75 20                	jne    f0105be7 <vprintfmt+0x263>
f0105bc7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105bca:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105bcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
f0105bd0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105bd4:	7f 25                	jg     f0105bfb <vprintfmt+0x277>
f0105bd6:	e9 d2 fd ff ff       	jmp    f01059ad <vprintfmt+0x29>
f0105bdb:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105bde:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105be1:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105be4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105be7:	85 db                	test   %ebx,%ebx
f0105be9:	78 9a                	js     f0105b85 <vprintfmt+0x201>
f0105beb:	83 eb 01             	sub    $0x1,%ebx
f0105bee:	79 95                	jns    f0105b85 <vprintfmt+0x201>
f0105bf0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105bf3:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105bf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105bf9:	eb d5                	jmp    f0105bd0 <vprintfmt+0x24c>
f0105bfb:	8b 75 08             	mov    0x8(%ebp),%esi
f0105bfe:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105c01:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
f0105c04:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105c08:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105c0f:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105c11:	83 eb 01             	sub    $0x1,%ebx
f0105c14:	75 ee                	jne    f0105c04 <vprintfmt+0x280>
f0105c16:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105c19:	e9 8f fd ff ff       	jmp    f01059ad <vprintfmt+0x29>
	if (lflag >= 2)
f0105c1e:	83 fa 01             	cmp    $0x1,%edx
f0105c21:	7e 16                	jle    f0105c39 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
f0105c23:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c26:	8d 50 08             	lea    0x8(%eax),%edx
f0105c29:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c2c:	8b 50 04             	mov    0x4(%eax),%edx
f0105c2f:	8b 00                	mov    (%eax),%eax
f0105c31:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105c34:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105c37:	eb 32                	jmp    f0105c6b <vprintfmt+0x2e7>
	else if (lflag)
f0105c39:	85 d2                	test   %edx,%edx
f0105c3b:	74 18                	je     f0105c55 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
f0105c3d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c40:	8d 50 04             	lea    0x4(%eax),%edx
f0105c43:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c46:	8b 30                	mov    (%eax),%esi
f0105c48:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0105c4b:	89 f0                	mov    %esi,%eax
f0105c4d:	c1 f8 1f             	sar    $0x1f,%eax
f0105c50:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105c53:	eb 16                	jmp    f0105c6b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
f0105c55:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c58:	8d 50 04             	lea    0x4(%eax),%edx
f0105c5b:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c5e:	8b 30                	mov    (%eax),%esi
f0105c60:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0105c63:	89 f0                	mov    %esi,%eax
f0105c65:	c1 f8 1f             	sar    $0x1f,%eax
f0105c68:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
f0105c6b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105c6e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
f0105c71:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
f0105c76:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105c7a:	0f 89 80 00 00 00    	jns    f0105d00 <vprintfmt+0x37c>
				putch('-', putdat);
f0105c80:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105c84:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105c8b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105c8e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105c91:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105c94:	f7 d8                	neg    %eax
f0105c96:	83 d2 00             	adc    $0x0,%edx
f0105c99:	f7 da                	neg    %edx
			base = 10;
f0105c9b:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105ca0:	eb 5e                	jmp    f0105d00 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
f0105ca2:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ca5:	e8 5b fc ff ff       	call   f0105905 <getuint>
			base = 10;
f0105caa:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105caf:	eb 4f                	jmp    f0105d00 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
f0105cb1:	8d 45 14             	lea    0x14(%ebp),%eax
f0105cb4:	e8 4c fc ff ff       	call   f0105905 <getuint>
			base = 8;
f0105cb9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105cbe:	eb 40                	jmp    f0105d00 <vprintfmt+0x37c>
			putch('0', putdat);
f0105cc0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105cc4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105ccb:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105cce:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105cd2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105cd9:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
f0105cdc:	8b 45 14             	mov    0x14(%ebp),%eax
f0105cdf:	8d 50 04             	lea    0x4(%eax),%edx
f0105ce2:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
f0105ce5:	8b 00                	mov    (%eax),%eax
f0105ce7:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
f0105cec:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105cf1:	eb 0d                	jmp    f0105d00 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
f0105cf3:	8d 45 14             	lea    0x14(%ebp),%eax
f0105cf6:	e8 0a fc ff ff       	call   f0105905 <getuint>
			base = 16;
f0105cfb:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
f0105d00:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0105d04:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105d08:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105d0b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105d0f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105d13:	89 04 24             	mov    %eax,(%esp)
f0105d16:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105d1a:	89 fa                	mov    %edi,%edx
f0105d1c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d1f:	e8 ec fa ff ff       	call   f0105810 <printnum>
			break;
f0105d24:	e9 84 fc ff ff       	jmp    f01059ad <vprintfmt+0x29>
			putch(ch, putdat);
f0105d29:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d2d:	89 0c 24             	mov    %ecx,(%esp)
f0105d30:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105d33:	e9 75 fc ff ff       	jmp    f01059ad <vprintfmt+0x29>
			putch('%', putdat);
f0105d38:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d3c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105d43:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105d46:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105d4a:	0f 84 5b fc ff ff    	je     f01059ab <vprintfmt+0x27>
f0105d50:	89 f3                	mov    %esi,%ebx
f0105d52:	83 eb 01             	sub    $0x1,%ebx
f0105d55:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0105d59:	75 f7                	jne    f0105d52 <vprintfmt+0x3ce>
f0105d5b:	e9 4d fc ff ff       	jmp    f01059ad <vprintfmt+0x29>
}
f0105d60:	83 c4 3c             	add    $0x3c,%esp
f0105d63:	5b                   	pop    %ebx
f0105d64:	5e                   	pop    %esi
f0105d65:	5f                   	pop    %edi
f0105d66:	5d                   	pop    %ebp
f0105d67:	c3                   	ret    

f0105d68 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105d68:	55                   	push   %ebp
f0105d69:	89 e5                	mov    %esp,%ebp
f0105d6b:	83 ec 28             	sub    $0x28,%esp
f0105d6e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d71:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105d74:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105d77:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105d7b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105d7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105d85:	85 c0                	test   %eax,%eax
f0105d87:	74 30                	je     f0105db9 <vsnprintf+0x51>
f0105d89:	85 d2                	test   %edx,%edx
f0105d8b:	7e 2c                	jle    f0105db9 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105d8d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d90:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105d94:	8b 45 10             	mov    0x10(%ebp),%eax
f0105d97:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d9b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105d9e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105da2:	c7 04 24 3f 59 10 f0 	movl   $0xf010593f,(%esp)
f0105da9:	e8 d6 fb ff ff       	call   f0105984 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105dae:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105db1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105db7:	eb 05                	jmp    f0105dbe <vsnprintf+0x56>
		return -E_INVAL;
f0105db9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
f0105dbe:	c9                   	leave  
f0105dbf:	c3                   	ret    

f0105dc0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105dc0:	55                   	push   %ebp
f0105dc1:	89 e5                	mov    %esp,%ebp
f0105dc3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105dc6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105dc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105dcd:	8b 45 10             	mov    0x10(%ebp),%eax
f0105dd0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105dd7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ddb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dde:	89 04 24             	mov    %eax,(%esp)
f0105de1:	e8 82 ff ff ff       	call   f0105d68 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105de6:	c9                   	leave  
f0105de7:	c3                   	ret    
f0105de8:	66 90                	xchg   %ax,%ax
f0105dea:	66 90                	xchg   %ax,%ax
f0105dec:	66 90                	xchg   %ax,%ax
f0105dee:	66 90                	xchg   %ax,%ax

f0105df0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105df0:	55                   	push   %ebp
f0105df1:	89 e5                	mov    %esp,%ebp
f0105df3:	57                   	push   %edi
f0105df4:	56                   	push   %esi
f0105df5:	53                   	push   %ebx
f0105df6:	83 ec 1c             	sub    $0x1c,%esp
f0105df9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105dfc:	85 c0                	test   %eax,%eax
f0105dfe:	74 10                	je     f0105e10 <readline+0x20>
		cprintf("%s", prompt);
f0105e00:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e04:	c7 04 24 77 74 10 f0 	movl   $0xf0107477,(%esp)
f0105e0b:	e8 8d e1 ff ff       	call   f0103f9d <cprintf>
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105e10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105e17:	e8 ec a9 ff ff       	call   f0100808 <iscons>
f0105e1c:	89 c7                	mov    %eax,%edi
	i = 0;
f0105e1e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0105e23:	e8 cf a9 ff ff       	call   f01007f7 <getchar>
f0105e28:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105e2a:	85 c0                	test   %eax,%eax
f0105e2c:	79 25                	jns    f0105e53 <readline+0x63>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105e2e:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
f0105e33:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105e36:	0f 84 89 00 00 00    	je     f0105ec5 <readline+0xd5>
				cprintf("read error: %e\n", c);
f0105e3c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e40:	c7 04 24 bf 88 10 f0 	movl   $0xf01088bf,(%esp)
f0105e47:	e8 51 e1 ff ff       	call   f0103f9d <cprintf>
			return NULL;
f0105e4c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e51:	eb 72                	jmp    f0105ec5 <readline+0xd5>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105e53:	83 f8 7f             	cmp    $0x7f,%eax
f0105e56:	74 05                	je     f0105e5d <readline+0x6d>
f0105e58:	83 f8 08             	cmp    $0x8,%eax
f0105e5b:	75 1a                	jne    f0105e77 <readline+0x87>
f0105e5d:	85 f6                	test   %esi,%esi
f0105e5f:	90                   	nop
f0105e60:	7e 15                	jle    f0105e77 <readline+0x87>
			if (echoing)
f0105e62:	85 ff                	test   %edi,%edi
f0105e64:	74 0c                	je     f0105e72 <readline+0x82>
				cputchar('\b');
f0105e66:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105e6d:	e8 75 a9 ff ff       	call   f01007e7 <cputchar>
			i--;
f0105e72:	83 ee 01             	sub    $0x1,%esi
f0105e75:	eb ac                	jmp    f0105e23 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105e77:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105e7d:	7f 1c                	jg     f0105e9b <readline+0xab>
f0105e7f:	83 fb 1f             	cmp    $0x1f,%ebx
f0105e82:	7e 17                	jle    f0105e9b <readline+0xab>
			if (echoing)
f0105e84:	85 ff                	test   %edi,%edi
f0105e86:	74 08                	je     f0105e90 <readline+0xa0>
				cputchar(c);
f0105e88:	89 1c 24             	mov    %ebx,(%esp)
f0105e8b:	e8 57 a9 ff ff       	call   f01007e7 <cputchar>
			buf[i++] = c;
f0105e90:	88 9e 80 1a 20 f0    	mov    %bl,-0xfdfe580(%esi)
f0105e96:	8d 76 01             	lea    0x1(%esi),%esi
f0105e99:	eb 88                	jmp    f0105e23 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105e9b:	83 fb 0d             	cmp    $0xd,%ebx
f0105e9e:	74 09                	je     f0105ea9 <readline+0xb9>
f0105ea0:	83 fb 0a             	cmp    $0xa,%ebx
f0105ea3:	0f 85 7a ff ff ff    	jne    f0105e23 <readline+0x33>
			if (echoing)
f0105ea9:	85 ff                	test   %edi,%edi
f0105eab:	74 0c                	je     f0105eb9 <readline+0xc9>
				cputchar('\n');
f0105ead:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105eb4:	e8 2e a9 ff ff       	call   f01007e7 <cputchar>
			buf[i] = 0;
f0105eb9:	c6 86 80 1a 20 f0 00 	movb   $0x0,-0xfdfe580(%esi)
			return buf;
f0105ec0:	b8 80 1a 20 f0       	mov    $0xf0201a80,%eax
		}
	}
}
f0105ec5:	83 c4 1c             	add    $0x1c,%esp
f0105ec8:	5b                   	pop    %ebx
f0105ec9:	5e                   	pop    %esi
f0105eca:	5f                   	pop    %edi
f0105ecb:	5d                   	pop    %ebp
f0105ecc:	c3                   	ret    
f0105ecd:	66 90                	xchg   %ax,%ax
f0105ecf:	90                   	nop

f0105ed0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105ed0:	55                   	push   %ebp
f0105ed1:	89 e5                	mov    %esp,%ebp
f0105ed3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105ed6:	80 3a 00             	cmpb   $0x0,(%edx)
f0105ed9:	74 10                	je     f0105eeb <strlen+0x1b>
f0105edb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105ee0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0105ee3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105ee7:	75 f7                	jne    f0105ee0 <strlen+0x10>
f0105ee9:	eb 05                	jmp    f0105ef0 <strlen+0x20>
f0105eeb:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
f0105ef0:	5d                   	pop    %ebp
f0105ef1:	c3                   	ret    

f0105ef2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105ef2:	55                   	push   %ebp
f0105ef3:	89 e5                	mov    %esp,%ebp
f0105ef5:	53                   	push   %ebx
f0105ef6:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105ef9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105efc:	85 c9                	test   %ecx,%ecx
f0105efe:	74 1c                	je     f0105f1c <strnlen+0x2a>
f0105f00:	80 3b 00             	cmpb   $0x0,(%ebx)
f0105f03:	74 1e                	je     f0105f23 <strnlen+0x31>
f0105f05:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0105f0a:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105f0c:	39 ca                	cmp    %ecx,%edx
f0105f0e:	74 18                	je     f0105f28 <strnlen+0x36>
f0105f10:	83 c2 01             	add    $0x1,%edx
f0105f13:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0105f18:	75 f0                	jne    f0105f0a <strnlen+0x18>
f0105f1a:	eb 0c                	jmp    f0105f28 <strnlen+0x36>
f0105f1c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f21:	eb 05                	jmp    f0105f28 <strnlen+0x36>
f0105f23:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
f0105f28:	5b                   	pop    %ebx
f0105f29:	5d                   	pop    %ebp
f0105f2a:	c3                   	ret    

f0105f2b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105f2b:	55                   	push   %ebp
f0105f2c:	89 e5                	mov    %esp,%ebp
f0105f2e:	53                   	push   %ebx
f0105f2f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105f35:	89 c2                	mov    %eax,%edx
f0105f37:	83 c2 01             	add    $0x1,%edx
f0105f3a:	83 c1 01             	add    $0x1,%ecx
f0105f3d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105f41:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105f44:	84 db                	test   %bl,%bl
f0105f46:	75 ef                	jne    f0105f37 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105f48:	5b                   	pop    %ebx
f0105f49:	5d                   	pop    %ebp
f0105f4a:	c3                   	ret    

f0105f4b <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105f4b:	55                   	push   %ebp
f0105f4c:	89 e5                	mov    %esp,%ebp
f0105f4e:	53                   	push   %ebx
f0105f4f:	83 ec 08             	sub    $0x8,%esp
f0105f52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105f55:	89 1c 24             	mov    %ebx,(%esp)
f0105f58:	e8 73 ff ff ff       	call   f0105ed0 <strlen>
	strcpy(dst + len, src);
f0105f5d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f60:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105f64:	01 d8                	add    %ebx,%eax
f0105f66:	89 04 24             	mov    %eax,(%esp)
f0105f69:	e8 bd ff ff ff       	call   f0105f2b <strcpy>
	return dst;
}
f0105f6e:	89 d8                	mov    %ebx,%eax
f0105f70:	83 c4 08             	add    $0x8,%esp
f0105f73:	5b                   	pop    %ebx
f0105f74:	5d                   	pop    %ebp
f0105f75:	c3                   	ret    

f0105f76 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105f76:	55                   	push   %ebp
f0105f77:	89 e5                	mov    %esp,%ebp
f0105f79:	56                   	push   %esi
f0105f7a:	53                   	push   %ebx
f0105f7b:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f7e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105f84:	85 db                	test   %ebx,%ebx
f0105f86:	74 17                	je     f0105f9f <strncpy+0x29>
f0105f88:	01 f3                	add    %esi,%ebx
f0105f8a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f0105f8c:	83 c1 01             	add    $0x1,%ecx
f0105f8f:	0f b6 02             	movzbl (%edx),%eax
f0105f92:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105f95:	80 3a 01             	cmpb   $0x1,(%edx)
f0105f98:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0105f9b:	39 d9                	cmp    %ebx,%ecx
f0105f9d:	75 ed                	jne    f0105f8c <strncpy+0x16>
	}
	return ret;
}
f0105f9f:	89 f0                	mov    %esi,%eax
f0105fa1:	5b                   	pop    %ebx
f0105fa2:	5e                   	pop    %esi
f0105fa3:	5d                   	pop    %ebp
f0105fa4:	c3                   	ret    

f0105fa5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105fa5:	55                   	push   %ebp
f0105fa6:	89 e5                	mov    %esp,%ebp
f0105fa8:	57                   	push   %edi
f0105fa9:	56                   	push   %esi
f0105faa:	53                   	push   %ebx
f0105fab:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105fae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105fb1:	8b 75 10             	mov    0x10(%ebp),%esi
f0105fb4:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105fb6:	85 f6                	test   %esi,%esi
f0105fb8:	74 34                	je     f0105fee <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
f0105fba:	83 fe 01             	cmp    $0x1,%esi
f0105fbd:	74 26                	je     f0105fe5 <strlcpy+0x40>
f0105fbf:	0f b6 0b             	movzbl (%ebx),%ecx
f0105fc2:	84 c9                	test   %cl,%cl
f0105fc4:	74 23                	je     f0105fe9 <strlcpy+0x44>
f0105fc6:	83 ee 02             	sub    $0x2,%esi
f0105fc9:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
f0105fce:	83 c0 01             	add    $0x1,%eax
f0105fd1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105fd4:	39 f2                	cmp    %esi,%edx
f0105fd6:	74 13                	je     f0105feb <strlcpy+0x46>
f0105fd8:	83 c2 01             	add    $0x1,%edx
f0105fdb:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105fdf:	84 c9                	test   %cl,%cl
f0105fe1:	75 eb                	jne    f0105fce <strlcpy+0x29>
f0105fe3:	eb 06                	jmp    f0105feb <strlcpy+0x46>
f0105fe5:	89 f8                	mov    %edi,%eax
f0105fe7:	eb 02                	jmp    f0105feb <strlcpy+0x46>
f0105fe9:	89 f8                	mov    %edi,%eax
		*dst = '\0';
f0105feb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105fee:	29 f8                	sub    %edi,%eax
}
f0105ff0:	5b                   	pop    %ebx
f0105ff1:	5e                   	pop    %esi
f0105ff2:	5f                   	pop    %edi
f0105ff3:	5d                   	pop    %ebp
f0105ff4:	c3                   	ret    

f0105ff5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105ff5:	55                   	push   %ebp
f0105ff6:	89 e5                	mov    %esp,%ebp
f0105ff8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105ffb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105ffe:	0f b6 01             	movzbl (%ecx),%eax
f0106001:	84 c0                	test   %al,%al
f0106003:	74 15                	je     f010601a <strcmp+0x25>
f0106005:	3a 02                	cmp    (%edx),%al
f0106007:	75 11                	jne    f010601a <strcmp+0x25>
		p++, q++;
f0106009:	83 c1 01             	add    $0x1,%ecx
f010600c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f010600f:	0f b6 01             	movzbl (%ecx),%eax
f0106012:	84 c0                	test   %al,%al
f0106014:	74 04                	je     f010601a <strcmp+0x25>
f0106016:	3a 02                	cmp    (%edx),%al
f0106018:	74 ef                	je     f0106009 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010601a:	0f b6 c0             	movzbl %al,%eax
f010601d:	0f b6 12             	movzbl (%edx),%edx
f0106020:	29 d0                	sub    %edx,%eax
}
f0106022:	5d                   	pop    %ebp
f0106023:	c3                   	ret    

f0106024 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0106024:	55                   	push   %ebp
f0106025:	89 e5                	mov    %esp,%ebp
f0106027:	56                   	push   %esi
f0106028:	53                   	push   %ebx
f0106029:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010602c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010602f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f0106032:	85 f6                	test   %esi,%esi
f0106034:	74 29                	je     f010605f <strncmp+0x3b>
f0106036:	0f b6 03             	movzbl (%ebx),%eax
f0106039:	84 c0                	test   %al,%al
f010603b:	74 30                	je     f010606d <strncmp+0x49>
f010603d:	3a 02                	cmp    (%edx),%al
f010603f:	75 2c                	jne    f010606d <strncmp+0x49>
f0106041:	8d 43 01             	lea    0x1(%ebx),%eax
f0106044:	01 de                	add    %ebx,%esi
		n--, p++, q++;
f0106046:	89 c3                	mov    %eax,%ebx
f0106048:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f010604b:	39 f0                	cmp    %esi,%eax
f010604d:	74 17                	je     f0106066 <strncmp+0x42>
f010604f:	0f b6 08             	movzbl (%eax),%ecx
f0106052:	84 c9                	test   %cl,%cl
f0106054:	74 17                	je     f010606d <strncmp+0x49>
f0106056:	83 c0 01             	add    $0x1,%eax
f0106059:	3a 0a                	cmp    (%edx),%cl
f010605b:	74 e9                	je     f0106046 <strncmp+0x22>
f010605d:	eb 0e                	jmp    f010606d <strncmp+0x49>
	if (n == 0)
		return 0;
f010605f:	b8 00 00 00 00       	mov    $0x0,%eax
f0106064:	eb 0f                	jmp    f0106075 <strncmp+0x51>
f0106066:	b8 00 00 00 00       	mov    $0x0,%eax
f010606b:	eb 08                	jmp    f0106075 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010606d:	0f b6 03             	movzbl (%ebx),%eax
f0106070:	0f b6 12             	movzbl (%edx),%edx
f0106073:	29 d0                	sub    %edx,%eax
}
f0106075:	5b                   	pop    %ebx
f0106076:	5e                   	pop    %esi
f0106077:	5d                   	pop    %ebp
f0106078:	c3                   	ret    

f0106079 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0106079:	55                   	push   %ebp
f010607a:	89 e5                	mov    %esp,%ebp
f010607c:	53                   	push   %ebx
f010607d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106080:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f0106083:	0f b6 18             	movzbl (%eax),%ebx
f0106086:	84 db                	test   %bl,%bl
f0106088:	74 1d                	je     f01060a7 <strchr+0x2e>
f010608a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
f010608c:	38 d3                	cmp    %dl,%bl
f010608e:	75 06                	jne    f0106096 <strchr+0x1d>
f0106090:	eb 1a                	jmp    f01060ac <strchr+0x33>
f0106092:	38 ca                	cmp    %cl,%dl
f0106094:	74 16                	je     f01060ac <strchr+0x33>
	for (; *s; s++)
f0106096:	83 c0 01             	add    $0x1,%eax
f0106099:	0f b6 10             	movzbl (%eax),%edx
f010609c:	84 d2                	test   %dl,%dl
f010609e:	75 f2                	jne    f0106092 <strchr+0x19>
			return (char *) s;
	return 0;
f01060a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01060a5:	eb 05                	jmp    f01060ac <strchr+0x33>
f01060a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01060ac:	5b                   	pop    %ebx
f01060ad:	5d                   	pop    %ebp
f01060ae:	c3                   	ret    

f01060af <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01060af:	55                   	push   %ebp
f01060b0:	89 e5                	mov    %esp,%ebp
f01060b2:	53                   	push   %ebx
f01060b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01060b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f01060b9:	0f b6 18             	movzbl (%eax),%ebx
f01060bc:	84 db                	test   %bl,%bl
f01060be:	74 16                	je     f01060d6 <strfind+0x27>
f01060c0:	89 d1                	mov    %edx,%ecx
		if (*s == c)
f01060c2:	38 d3                	cmp    %dl,%bl
f01060c4:	75 06                	jne    f01060cc <strfind+0x1d>
f01060c6:	eb 0e                	jmp    f01060d6 <strfind+0x27>
f01060c8:	38 ca                	cmp    %cl,%dl
f01060ca:	74 0a                	je     f01060d6 <strfind+0x27>
	for (; *s; s++)
f01060cc:	83 c0 01             	add    $0x1,%eax
f01060cf:	0f b6 10             	movzbl (%eax),%edx
f01060d2:	84 d2                	test   %dl,%dl
f01060d4:	75 f2                	jne    f01060c8 <strfind+0x19>
			break;
	return (char *) s;
}
f01060d6:	5b                   	pop    %ebx
f01060d7:	5d                   	pop    %ebp
f01060d8:	c3                   	ret    

f01060d9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01060d9:	55                   	push   %ebp
f01060da:	89 e5                	mov    %esp,%ebp
f01060dc:	57                   	push   %edi
f01060dd:	56                   	push   %esi
f01060de:	53                   	push   %ebx
f01060df:	8b 7d 08             	mov    0x8(%ebp),%edi
f01060e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01060e5:	85 c9                	test   %ecx,%ecx
f01060e7:	74 36                	je     f010611f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01060e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01060ef:	75 28                	jne    f0106119 <memset+0x40>
f01060f1:	f6 c1 03             	test   $0x3,%cl
f01060f4:	75 23                	jne    f0106119 <memset+0x40>
		c &= 0xFF;
f01060f6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01060fa:	89 d3                	mov    %edx,%ebx
f01060fc:	c1 e3 08             	shl    $0x8,%ebx
f01060ff:	89 d6                	mov    %edx,%esi
f0106101:	c1 e6 18             	shl    $0x18,%esi
f0106104:	89 d0                	mov    %edx,%eax
f0106106:	c1 e0 10             	shl    $0x10,%eax
f0106109:	09 f0                	or     %esi,%eax
f010610b:	09 c2                	or     %eax,%edx
f010610d:	89 d0                	mov    %edx,%eax
f010610f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0106111:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0106114:	fc                   	cld    
f0106115:	f3 ab                	rep stos %eax,%es:(%edi)
f0106117:	eb 06                	jmp    f010611f <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0106119:	8b 45 0c             	mov    0xc(%ebp),%eax
f010611c:	fc                   	cld    
f010611d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010611f:	89 f8                	mov    %edi,%eax
f0106121:	5b                   	pop    %ebx
f0106122:	5e                   	pop    %esi
f0106123:	5f                   	pop    %edi
f0106124:	5d                   	pop    %ebp
f0106125:	c3                   	ret    

f0106126 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106126:	55                   	push   %ebp
f0106127:	89 e5                	mov    %esp,%ebp
f0106129:	57                   	push   %edi
f010612a:	56                   	push   %esi
f010612b:	8b 45 08             	mov    0x8(%ebp),%eax
f010612e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106131:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106134:	39 c6                	cmp    %eax,%esi
f0106136:	73 35                	jae    f010616d <memmove+0x47>
f0106138:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010613b:	39 d0                	cmp    %edx,%eax
f010613d:	73 2e                	jae    f010616d <memmove+0x47>
		s += n;
		d += n;
f010613f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0106142:	89 d6                	mov    %edx,%esi
f0106144:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106146:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010614c:	75 13                	jne    f0106161 <memmove+0x3b>
f010614e:	f6 c1 03             	test   $0x3,%cl
f0106151:	75 0e                	jne    f0106161 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0106153:	83 ef 04             	sub    $0x4,%edi
f0106156:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106159:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010615c:	fd                   	std    
f010615d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010615f:	eb 09                	jmp    f010616a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0106161:	83 ef 01             	sub    $0x1,%edi
f0106164:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0106167:	fd                   	std    
f0106168:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010616a:	fc                   	cld    
f010616b:	eb 1d                	jmp    f010618a <memmove+0x64>
f010616d:	89 f2                	mov    %esi,%edx
f010616f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106171:	f6 c2 03             	test   $0x3,%dl
f0106174:	75 0f                	jne    f0106185 <memmove+0x5f>
f0106176:	f6 c1 03             	test   $0x3,%cl
f0106179:	75 0a                	jne    f0106185 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010617b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010617e:	89 c7                	mov    %eax,%edi
f0106180:	fc                   	cld    
f0106181:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106183:	eb 05                	jmp    f010618a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
f0106185:	89 c7                	mov    %eax,%edi
f0106187:	fc                   	cld    
f0106188:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010618a:	5e                   	pop    %esi
f010618b:	5f                   	pop    %edi
f010618c:	5d                   	pop    %ebp
f010618d:	c3                   	ret    

f010618e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010618e:	55                   	push   %ebp
f010618f:	89 e5                	mov    %esp,%ebp
f0106191:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106194:	8b 45 10             	mov    0x10(%ebp),%eax
f0106197:	89 44 24 08          	mov    %eax,0x8(%esp)
f010619b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010619e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01061a5:	89 04 24             	mov    %eax,(%esp)
f01061a8:	e8 79 ff ff ff       	call   f0106126 <memmove>
}
f01061ad:	c9                   	leave  
f01061ae:	c3                   	ret    

f01061af <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01061af:	55                   	push   %ebp
f01061b0:	89 e5                	mov    %esp,%ebp
f01061b2:	57                   	push   %edi
f01061b3:	56                   	push   %esi
f01061b4:	53                   	push   %ebx
f01061b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01061b8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01061bb:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01061be:	8d 78 ff             	lea    -0x1(%eax),%edi
f01061c1:	85 c0                	test   %eax,%eax
f01061c3:	74 36                	je     f01061fb <memcmp+0x4c>
		if (*s1 != *s2)
f01061c5:	0f b6 03             	movzbl (%ebx),%eax
f01061c8:	0f b6 0e             	movzbl (%esi),%ecx
f01061cb:	ba 00 00 00 00       	mov    $0x0,%edx
f01061d0:	38 c8                	cmp    %cl,%al
f01061d2:	74 1c                	je     f01061f0 <memcmp+0x41>
f01061d4:	eb 10                	jmp    f01061e6 <memcmp+0x37>
f01061d6:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f01061db:	83 c2 01             	add    $0x1,%edx
f01061de:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01061e2:	38 c8                	cmp    %cl,%al
f01061e4:	74 0a                	je     f01061f0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f01061e6:	0f b6 c0             	movzbl %al,%eax
f01061e9:	0f b6 c9             	movzbl %cl,%ecx
f01061ec:	29 c8                	sub    %ecx,%eax
f01061ee:	eb 10                	jmp    f0106200 <memcmp+0x51>
	while (n-- > 0) {
f01061f0:	39 fa                	cmp    %edi,%edx
f01061f2:	75 e2                	jne    f01061d6 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
f01061f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01061f9:	eb 05                	jmp    f0106200 <memcmp+0x51>
f01061fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106200:	5b                   	pop    %ebx
f0106201:	5e                   	pop    %esi
f0106202:	5f                   	pop    %edi
f0106203:	5d                   	pop    %ebp
f0106204:	c3                   	ret    

f0106205 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106205:	55                   	push   %ebp
f0106206:	89 e5                	mov    %esp,%ebp
f0106208:	53                   	push   %ebx
f0106209:	8b 45 08             	mov    0x8(%ebp),%eax
f010620c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
f010620f:	89 c2                	mov    %eax,%edx
f0106211:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106214:	39 d0                	cmp    %edx,%eax
f0106216:	73 13                	jae    f010622b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106218:	89 d9                	mov    %ebx,%ecx
f010621a:	38 18                	cmp    %bl,(%eax)
f010621c:	75 06                	jne    f0106224 <memfind+0x1f>
f010621e:	eb 0b                	jmp    f010622b <memfind+0x26>
f0106220:	38 08                	cmp    %cl,(%eax)
f0106222:	74 07                	je     f010622b <memfind+0x26>
	for (; s < ends; s++)
f0106224:	83 c0 01             	add    $0x1,%eax
f0106227:	39 d0                	cmp    %edx,%eax
f0106229:	75 f5                	jne    f0106220 <memfind+0x1b>
			break;
	return (void *) s;
}
f010622b:	5b                   	pop    %ebx
f010622c:	5d                   	pop    %ebp
f010622d:	c3                   	ret    

f010622e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010622e:	55                   	push   %ebp
f010622f:	89 e5                	mov    %esp,%ebp
f0106231:	57                   	push   %edi
f0106232:	56                   	push   %esi
f0106233:	53                   	push   %ebx
f0106234:	8b 55 08             	mov    0x8(%ebp),%edx
f0106237:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010623a:	0f b6 0a             	movzbl (%edx),%ecx
f010623d:	80 f9 09             	cmp    $0x9,%cl
f0106240:	74 05                	je     f0106247 <strtol+0x19>
f0106242:	80 f9 20             	cmp    $0x20,%cl
f0106245:	75 10                	jne    f0106257 <strtol+0x29>
		s++;
f0106247:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f010624a:	0f b6 0a             	movzbl (%edx),%ecx
f010624d:	80 f9 09             	cmp    $0x9,%cl
f0106250:	74 f5                	je     f0106247 <strtol+0x19>
f0106252:	80 f9 20             	cmp    $0x20,%cl
f0106255:	74 f0                	je     f0106247 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
f0106257:	80 f9 2b             	cmp    $0x2b,%cl
f010625a:	75 0a                	jne    f0106266 <strtol+0x38>
		s++;
f010625c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f010625f:	bf 00 00 00 00       	mov    $0x0,%edi
f0106264:	eb 11                	jmp    f0106277 <strtol+0x49>
f0106266:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
f010626b:	80 f9 2d             	cmp    $0x2d,%cl
f010626e:	75 07                	jne    f0106277 <strtol+0x49>
		s++, neg = 1;
f0106270:	83 c2 01             	add    $0x1,%edx
f0106273:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106277:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f010627c:	75 15                	jne    f0106293 <strtol+0x65>
f010627e:	80 3a 30             	cmpb   $0x30,(%edx)
f0106281:	75 10                	jne    f0106293 <strtol+0x65>
f0106283:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0106287:	75 0a                	jne    f0106293 <strtol+0x65>
		s += 2, base = 16;
f0106289:	83 c2 02             	add    $0x2,%edx
f010628c:	b8 10 00 00 00       	mov    $0x10,%eax
f0106291:	eb 10                	jmp    f01062a3 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
f0106293:	85 c0                	test   %eax,%eax
f0106295:	75 0c                	jne    f01062a3 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106297:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
f0106299:	80 3a 30             	cmpb   $0x30,(%edx)
f010629c:	75 05                	jne    f01062a3 <strtol+0x75>
		s++, base = 8;
f010629e:	83 c2 01             	add    $0x1,%edx
f01062a1:	b0 08                	mov    $0x8,%al
		base = 10;
f01062a3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01062a8:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01062ab:	0f b6 0a             	movzbl (%edx),%ecx
f01062ae:	8d 71 d0             	lea    -0x30(%ecx),%esi
f01062b1:	89 f0                	mov    %esi,%eax
f01062b3:	3c 09                	cmp    $0x9,%al
f01062b5:	77 08                	ja     f01062bf <strtol+0x91>
			dig = *s - '0';
f01062b7:	0f be c9             	movsbl %cl,%ecx
f01062ba:	83 e9 30             	sub    $0x30,%ecx
f01062bd:	eb 20                	jmp    f01062df <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
f01062bf:	8d 71 9f             	lea    -0x61(%ecx),%esi
f01062c2:	89 f0                	mov    %esi,%eax
f01062c4:	3c 19                	cmp    $0x19,%al
f01062c6:	77 08                	ja     f01062d0 <strtol+0xa2>
			dig = *s - 'a' + 10;
f01062c8:	0f be c9             	movsbl %cl,%ecx
f01062cb:	83 e9 57             	sub    $0x57,%ecx
f01062ce:	eb 0f                	jmp    f01062df <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
f01062d0:	8d 71 bf             	lea    -0x41(%ecx),%esi
f01062d3:	89 f0                	mov    %esi,%eax
f01062d5:	3c 19                	cmp    $0x19,%al
f01062d7:	77 16                	ja     f01062ef <strtol+0xc1>
			dig = *s - 'A' + 10;
f01062d9:	0f be c9             	movsbl %cl,%ecx
f01062dc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01062df:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f01062e2:	7d 0f                	jge    f01062f3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01062e4:	83 c2 01             	add    $0x1,%edx
f01062e7:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f01062eb:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f01062ed:	eb bc                	jmp    f01062ab <strtol+0x7d>
f01062ef:	89 d8                	mov    %ebx,%eax
f01062f1:	eb 02                	jmp    f01062f5 <strtol+0xc7>
f01062f3:	89 d8                	mov    %ebx,%eax

	if (endptr)
f01062f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01062f9:	74 05                	je     f0106300 <strtol+0xd2>
		*endptr = (char *) s;
f01062fb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01062fe:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0106300:	f7 d8                	neg    %eax
f0106302:	85 ff                	test   %edi,%edi
f0106304:	0f 44 c3             	cmove  %ebx,%eax
}
f0106307:	5b                   	pop    %ebx
f0106308:	5e                   	pop    %esi
f0106309:	5f                   	pop    %edi
f010630a:	5d                   	pop    %ebp
f010630b:	c3                   	ret    

f010630c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010630c:	fa                   	cli    

	xorw    %ax, %ax
f010630d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010630f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106311:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106313:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106315:	0f 01 16             	lgdtl  (%esi)
f0106318:	74 70                	je     f010638a <mpentry_end+0x4>
	movl    %cr0, %eax
f010631a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010631d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106321:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106324:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010632a:	08 00                	or     %al,(%eax)

f010632c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010632c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106330:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106332:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106334:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106336:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010633a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010633c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010633e:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0106343:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106346:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106349:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010634e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106351:	8b 25 84 1e 20 f0    	mov    0xf0201e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106357:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010635c:	b8 1c 02 10 f0       	mov    $0xf010021c,%eax
	call    *%eax
f0106361:	ff d0                	call   *%eax

f0106363 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106363:	eb fe                	jmp    f0106363 <spin>
f0106365:	8d 76 00             	lea    0x0(%esi),%esi

f0106368 <gdt>:
	...
f0106370:	ff                   	(bad)  
f0106371:	ff 00                	incl   (%eax)
f0106373:	00 00                	add    %al,(%eax)
f0106375:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010637c:	00                   	.byte 0x0
f010637d:	92                   	xchg   %eax,%edx
f010637e:	cf                   	iret   
	...

f0106380 <gdtdesc>:
f0106380:	17                   	pop    %ss
f0106381:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106386 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106386:	90                   	nop
f0106387:	66 90                	xchg   %ax,%ax
f0106389:	66 90                	xchg   %ax,%ax
f010638b:	66 90                	xchg   %ax,%ax
f010638d:	66 90                	xchg   %ax,%ax
f010638f:	90                   	nop

f0106390 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106390:	55                   	push   %ebp
f0106391:	89 e5                	mov    %esp,%ebp
f0106393:	56                   	push   %esi
f0106394:	53                   	push   %ebx
f0106395:	83 ec 10             	sub    $0x10,%esp
	if (PGNUM(pa) >= npages)
f0106398:	8b 0d 88 1e 20 f0    	mov    0xf0201e88,%ecx
f010639e:	89 c3                	mov    %eax,%ebx
f01063a0:	c1 eb 0c             	shr    $0xc,%ebx
f01063a3:	39 cb                	cmp    %ecx,%ebx
f01063a5:	72 20                	jb     f01063c7 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01063ab:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f01063b2:	f0 
f01063b3:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01063ba:	00 
f01063bb:	c7 04 24 5d 8a 10 f0 	movl   $0xf0108a5d,(%esp)
f01063c2:	e8 79 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01063c7:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01063cd:	01 d0                	add    %edx,%eax
	if (PGNUM(pa) >= npages)
f01063cf:	89 c2                	mov    %eax,%edx
f01063d1:	c1 ea 0c             	shr    $0xc,%edx
f01063d4:	39 d1                	cmp    %edx,%ecx
f01063d6:	77 20                	ja     f01063f8 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01063dc:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f01063e3:	f0 
f01063e4:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01063eb:	00 
f01063ec:	c7 04 24 5d 8a 10 f0 	movl   $0xf0108a5d,(%esp)
f01063f3:	e8 48 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01063f8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01063fe:	39 f3                	cmp    %esi,%ebx
f0106400:	73 40                	jae    f0106442 <mpsearch1+0xb2>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106402:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106409:	00 
f010640a:	c7 44 24 04 6d 8a 10 	movl   $0xf0108a6d,0x4(%esp)
f0106411:	f0 
f0106412:	89 1c 24             	mov    %ebx,(%esp)
f0106415:	e8 95 fd ff ff       	call   f01061af <memcmp>
f010641a:	85 c0                	test   %eax,%eax
f010641c:	75 17                	jne    f0106435 <mpsearch1+0xa5>
f010641e:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f0106423:	0f b6 0c 03          	movzbl (%ebx,%eax,1),%ecx
f0106427:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f0106429:	83 c0 01             	add    $0x1,%eax
f010642c:	83 f8 10             	cmp    $0x10,%eax
f010642f:	75 f2                	jne    f0106423 <mpsearch1+0x93>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106431:	84 d2                	test   %dl,%dl
f0106433:	74 14                	je     f0106449 <mpsearch1+0xb9>
	for (; mp < end; mp++)
f0106435:	83 c3 10             	add    $0x10,%ebx
f0106438:	39 f3                	cmp    %esi,%ebx
f010643a:	72 c6                	jb     f0106402 <mpsearch1+0x72>
f010643c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106440:	eb 0b                	jmp    f010644d <mpsearch1+0xbd>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0106442:	b8 00 00 00 00       	mov    $0x0,%eax
f0106447:	eb 09                	jmp    f0106452 <mpsearch1+0xc2>
f0106449:	89 d8                	mov    %ebx,%eax
f010644b:	eb 05                	jmp    f0106452 <mpsearch1+0xc2>
f010644d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106452:	83 c4 10             	add    $0x10,%esp
f0106455:	5b                   	pop    %ebx
f0106456:	5e                   	pop    %esi
f0106457:	5d                   	pop    %ebp
f0106458:	c3                   	ret    

f0106459 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106459:	55                   	push   %ebp
f010645a:	89 e5                	mov    %esp,%ebp
f010645c:	57                   	push   %edi
f010645d:	56                   	push   %esi
f010645e:	53                   	push   %ebx
f010645f:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106462:	c7 05 c0 23 20 f0 20 	movl   $0xf0202020,0xf02023c0
f0106469:	20 20 f0 
	if (PGNUM(pa) >= npages)
f010646c:	83 3d 88 1e 20 f0 00 	cmpl   $0x0,0xf0201e88
f0106473:	75 24                	jne    f0106499 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106475:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f010647c:	00 
f010647d:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f0106484:	f0 
f0106485:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f010648c:	00 
f010648d:	c7 04 24 5d 8a 10 f0 	movl   $0xf0108a5d,(%esp)
f0106494:	e8 a7 9b ff ff       	call   f0100040 <_panic>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106499:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01064a0:	85 c0                	test   %eax,%eax
f01064a2:	74 16                	je     f01064ba <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f01064a4:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01064a7:	ba 00 04 00 00       	mov    $0x400,%edx
f01064ac:	e8 df fe ff ff       	call   f0106390 <mpsearch1>
f01064b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01064b4:	85 c0                	test   %eax,%eax
f01064b6:	75 3c                	jne    f01064f4 <mp_init+0x9b>
f01064b8:	eb 20                	jmp    f01064da <mp_init+0x81>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01064ba:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01064c1:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01064c4:	2d 00 04 00 00       	sub    $0x400,%eax
f01064c9:	ba 00 04 00 00       	mov    $0x400,%edx
f01064ce:	e8 bd fe ff ff       	call   f0106390 <mpsearch1>
f01064d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01064d6:	85 c0                	test   %eax,%eax
f01064d8:	75 1a                	jne    f01064f4 <mp_init+0x9b>
	return mpsearch1(0xF0000, 0x10000);
f01064da:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064df:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01064e4:	e8 a7 fe ff ff       	call   f0106390 <mpsearch1>
f01064e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f01064ec:	85 c0                	test   %eax,%eax
f01064ee:	0f 84 5f 02 00 00    	je     f0106753 <mp_init+0x2fa>
	if (mp->physaddr == 0 || mp->type != 0) {
f01064f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01064f7:	8b 70 04             	mov    0x4(%eax),%esi
f01064fa:	85 f6                	test   %esi,%esi
f01064fc:	74 06                	je     f0106504 <mp_init+0xab>
f01064fe:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106502:	74 11                	je     f0106515 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0106504:	c7 04 24 d0 88 10 f0 	movl   $0xf01088d0,(%esp)
f010650b:	e8 8d da ff ff       	call   f0103f9d <cprintf>
f0106510:	e9 3e 02 00 00       	jmp    f0106753 <mp_init+0x2fa>
	if (PGNUM(pa) >= npages)
f0106515:	89 f0                	mov    %esi,%eax
f0106517:	c1 e8 0c             	shr    $0xc,%eax
f010651a:	3b 05 88 1e 20 f0    	cmp    0xf0201e88,%eax
f0106520:	72 20                	jb     f0106542 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106522:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106526:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f010652d:	f0 
f010652e:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106535:	00 
f0106536:	c7 04 24 5d 8a 10 f0 	movl   $0xf0108a5d,(%esp)
f010653d:	e8 fe 9a ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106542:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106548:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010654f:	00 
f0106550:	c7 44 24 04 72 8a 10 	movl   $0xf0108a72,0x4(%esp)
f0106557:	f0 
f0106558:	89 1c 24             	mov    %ebx,(%esp)
f010655b:	e8 4f fc ff ff       	call   f01061af <memcmp>
f0106560:	85 c0                	test   %eax,%eax
f0106562:	74 11                	je     f0106575 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106564:	c7 04 24 00 89 10 f0 	movl   $0xf0108900,(%esp)
f010656b:	e8 2d da ff ff       	call   f0103f9d <cprintf>
f0106570:	e9 de 01 00 00       	jmp    f0106753 <mp_init+0x2fa>
	if (sum(conf, conf->length) != 0) {
f0106575:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0106579:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f010657d:	0f b7 f8             	movzwl %ax,%edi
	for (i = 0; i < len; i++)
f0106580:	85 ff                	test   %edi,%edi
f0106582:	7e 30                	jle    f01065b4 <mp_init+0x15b>
	sum = 0;
f0106584:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106589:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f010658e:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0106595:	f0 
f0106596:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f0106598:	83 c0 01             	add    $0x1,%eax
f010659b:	39 c7                	cmp    %eax,%edi
f010659d:	7f ef                	jg     f010658e <mp_init+0x135>
	if (sum(conf, conf->length) != 0) {
f010659f:	84 d2                	test   %dl,%dl
f01065a1:	74 11                	je     f01065b4 <mp_init+0x15b>
		cprintf("SMP: Bad MP configuration checksum\n");
f01065a3:	c7 04 24 34 89 10 f0 	movl   $0xf0108934,(%esp)
f01065aa:	e8 ee d9 ff ff       	call   f0103f9d <cprintf>
f01065af:	e9 9f 01 00 00       	jmp    f0106753 <mp_init+0x2fa>
	if (conf->version != 1 && conf->version != 4) {
f01065b4:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01065b8:	3c 04                	cmp    $0x4,%al
f01065ba:	74 1e                	je     f01065da <mp_init+0x181>
f01065bc:	3c 01                	cmp    $0x1,%al
f01065be:	66 90                	xchg   %ax,%ax
f01065c0:	74 18                	je     f01065da <mp_init+0x181>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01065c2:	0f b6 c0             	movzbl %al,%eax
f01065c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065c9:	c7 04 24 58 89 10 f0 	movl   $0xf0108958,(%esp)
f01065d0:	e8 c8 d9 ff ff       	call   f0103f9d <cprintf>
f01065d5:	e9 79 01 00 00       	jmp    f0106753 <mp_init+0x2fa>
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f01065da:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f01065de:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f01065e2:	01 df                	add    %ebx,%edi
	for (i = 0; i < len; i++)
f01065e4:	85 f6                	test   %esi,%esi
f01065e6:	7e 19                	jle    f0106601 <mp_init+0x1a8>
	sum = 0;
f01065e8:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01065ed:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f01065f2:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f01065f6:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f01065f8:	83 c0 01             	add    $0x1,%eax
f01065fb:	39 c6                	cmp    %eax,%esi
f01065fd:	7f f3                	jg     f01065f2 <mp_init+0x199>
f01065ff:	eb 05                	jmp    f0106606 <mp_init+0x1ad>
	sum = 0;
f0106601:	ba 00 00 00 00       	mov    $0x0,%edx
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0106606:	38 53 2a             	cmp    %dl,0x2a(%ebx)
f0106609:	74 11                	je     f010661c <mp_init+0x1c3>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010660b:	c7 04 24 78 89 10 f0 	movl   $0xf0108978,(%esp)
f0106612:	e8 86 d9 ff ff       	call   f0103f9d <cprintf>
f0106617:	e9 37 01 00 00       	jmp    f0106753 <mp_init+0x2fa>
	if ((conf = mpconfig(&mp)) == 0)
f010661c:	85 db                	test   %ebx,%ebx
f010661e:	0f 84 2f 01 00 00    	je     f0106753 <mp_init+0x2fa>
		return;
	ismp = 1;
f0106624:	c7 05 00 20 20 f0 01 	movl   $0x1,0xf0202000
f010662b:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010662e:	8b 43 24             	mov    0x24(%ebx),%eax
f0106631:	a3 00 30 24 f0       	mov    %eax,0xf0243000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106636:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0106639:	66 83 7b 22 00       	cmpw   $0x0,0x22(%ebx)
f010663e:	0f 84 94 00 00 00    	je     f01066d8 <mp_init+0x27f>
f0106644:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f0106649:	0f b6 07             	movzbl (%edi),%eax
f010664c:	84 c0                	test   %al,%al
f010664e:	74 06                	je     f0106656 <mp_init+0x1fd>
f0106650:	3c 04                	cmp    $0x4,%al
f0106652:	77 54                	ja     f01066a8 <mp_init+0x24f>
f0106654:	eb 4d                	jmp    f01066a3 <mp_init+0x24a>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106656:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010665a:	74 11                	je     f010666d <mp_init+0x214>
				bootcpu = &cpus[ncpu];
f010665c:	6b 05 c4 23 20 f0 74 	imul   $0x74,0xf02023c4,%eax
f0106663:	05 20 20 20 f0       	add    $0xf0202020,%eax
f0106668:	a3 c0 23 20 f0       	mov    %eax,0xf02023c0
			if (ncpu < NCPU) {
f010666d:	a1 c4 23 20 f0       	mov    0xf02023c4,%eax
f0106672:	83 f8 07             	cmp    $0x7,%eax
f0106675:	7f 13                	jg     f010668a <mp_init+0x231>
				cpus[ncpu].cpu_id = ncpu;
f0106677:	6b d0 74             	imul   $0x74,%eax,%edx
f010667a:	88 82 20 20 20 f0    	mov    %al,-0xfdfdfe0(%edx)
				ncpu++;
f0106680:	83 c0 01             	add    $0x1,%eax
f0106683:	a3 c4 23 20 f0       	mov    %eax,0xf02023c4
f0106688:	eb 14                	jmp    f010669e <mp_init+0x245>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010668a:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f010668e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106692:	c7 04 24 a8 89 10 f0 	movl   $0xf01089a8,(%esp)
f0106699:	e8 ff d8 ff ff       	call   f0103f9d <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010669e:	83 c7 14             	add    $0x14,%edi
			continue;
f01066a1:	eb 26                	jmp    f01066c9 <mp_init+0x270>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01066a3:	83 c7 08             	add    $0x8,%edi
			continue;
f01066a6:	eb 21                	jmp    f01066c9 <mp_init+0x270>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01066a8:	0f b6 c0             	movzbl %al,%eax
f01066ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066af:	c7 04 24 d0 89 10 f0 	movl   $0xf01089d0,(%esp)
f01066b6:	e8 e2 d8 ff ff       	call   f0103f9d <cprintf>
			ismp = 0;
f01066bb:	c7 05 00 20 20 f0 00 	movl   $0x0,0xf0202000
f01066c2:	00 00 00 
			i = conf->entry;
f01066c5:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01066c9:	83 c6 01             	add    $0x1,%esi
f01066cc:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01066d0:	39 f0                	cmp    %esi,%eax
f01066d2:	0f 87 71 ff ff ff    	ja     f0106649 <mp_init+0x1f0>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01066d8:	a1 c0 23 20 f0       	mov    0xf02023c0,%eax
f01066dd:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01066e4:	83 3d 00 20 20 f0 00 	cmpl   $0x0,0xf0202000
f01066eb:	75 22                	jne    f010670f <mp_init+0x2b6>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01066ed:	c7 05 c4 23 20 f0 01 	movl   $0x1,0xf02023c4
f01066f4:	00 00 00 
		lapicaddr = 0;
f01066f7:	c7 05 00 30 24 f0 00 	movl   $0x0,0xf0243000
f01066fe:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106701:	c7 04 24 f0 89 10 f0 	movl   $0xf01089f0,(%esp)
f0106708:	e8 90 d8 ff ff       	call   f0103f9d <cprintf>
		return;
f010670d:	eb 44                	jmp    f0106753 <mp_init+0x2fa>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010670f:	8b 15 c4 23 20 f0    	mov    0xf02023c4,%edx
f0106715:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106719:	0f b6 00             	movzbl (%eax),%eax
f010671c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106720:	c7 04 24 77 8a 10 f0 	movl   $0xf0108a77,(%esp)
f0106727:	e8 71 d8 ff ff       	call   f0103f9d <cprintf>

	if (mp->imcrp) {
f010672c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010672f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106733:	74 1e                	je     f0106753 <mp_init+0x2fa>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106735:	c7 04 24 1c 8a 10 f0 	movl   $0xf0108a1c,(%esp)
f010673c:	e8 5c d8 ff ff       	call   f0103f9d <cprintf>
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106741:	ba 22 00 00 00       	mov    $0x22,%edx
f0106746:	b8 70 00 00 00       	mov    $0x70,%eax
f010674b:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010674c:	b2 23                	mov    $0x23,%dl
f010674e:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010674f:	83 c8 01             	or     $0x1,%eax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106752:	ee                   	out    %al,(%dx)
	}
}
f0106753:	83 c4 2c             	add    $0x2c,%esp
f0106756:	5b                   	pop    %ebx
f0106757:	5e                   	pop    %esi
f0106758:	5f                   	pop    %edi
f0106759:	5d                   	pop    %ebp
f010675a:	c3                   	ret    

f010675b <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010675b:	55                   	push   %ebp
f010675c:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010675e:	8b 0d 04 30 24 f0    	mov    0xf0243004,%ecx
f0106764:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106767:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106769:	a1 04 30 24 f0       	mov    0xf0243004,%eax
f010676e:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106771:	5d                   	pop    %ebp
f0106772:	c3                   	ret    

f0106773 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106773:	55                   	push   %ebp
f0106774:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106776:	a1 04 30 24 f0       	mov    0xf0243004,%eax
f010677b:	85 c0                	test   %eax,%eax
f010677d:	74 08                	je     f0106787 <cpunum+0x14>
		return lapic[ID] >> 24;
f010677f:	8b 40 20             	mov    0x20(%eax),%eax
f0106782:	c1 e8 18             	shr    $0x18,%eax
f0106785:	eb 05                	jmp    f010678c <cpunum+0x19>
	return 0;
f0106787:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010678c:	5d                   	pop    %ebp
f010678d:	c3                   	ret    

f010678e <lapic_init>:
	if (!lapicaddr)
f010678e:	a1 00 30 24 f0       	mov    0xf0243000,%eax
f0106793:	85 c0                	test   %eax,%eax
f0106795:	0f 84 23 01 00 00    	je     f01068be <lapic_init+0x130>
{
f010679b:	55                   	push   %ebp
f010679c:	89 e5                	mov    %esp,%ebp
f010679e:	83 ec 18             	sub    $0x18,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f01067a1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01067a8:	00 
f01067a9:	89 04 24             	mov    %eax,(%esp)
f01067ac:	e8 1b ad ff ff       	call   f01014cc <mmio_map_region>
f01067b1:	a3 04 30 24 f0       	mov    %eax,0xf0243004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01067b6:	ba 27 01 00 00       	mov    $0x127,%edx
f01067bb:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01067c0:	e8 96 ff ff ff       	call   f010675b <lapicw>
	lapicw(TDCR, X1);
f01067c5:	ba 0b 00 00 00       	mov    $0xb,%edx
f01067ca:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01067cf:	e8 87 ff ff ff       	call   f010675b <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01067d4:	ba 20 00 02 00       	mov    $0x20020,%edx
f01067d9:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01067de:	e8 78 ff ff ff       	call   f010675b <lapicw>
	lapicw(TICR, 10000000); 
f01067e3:	ba 80 96 98 00       	mov    $0x989680,%edx
f01067e8:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01067ed:	e8 69 ff ff ff       	call   f010675b <lapicw>
	if (thiscpu != bootcpu)
f01067f2:	e8 7c ff ff ff       	call   f0106773 <cpunum>
f01067f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01067fa:	05 20 20 20 f0       	add    $0xf0202020,%eax
f01067ff:	39 05 c0 23 20 f0    	cmp    %eax,0xf02023c0
f0106805:	74 0f                	je     f0106816 <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0106807:	ba 00 00 01 00       	mov    $0x10000,%edx
f010680c:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106811:	e8 45 ff ff ff       	call   f010675b <lapicw>
	lapicw(LINT1, MASKED);
f0106816:	ba 00 00 01 00       	mov    $0x10000,%edx
f010681b:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106820:	e8 36 ff ff ff       	call   f010675b <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106825:	a1 04 30 24 f0       	mov    0xf0243004,%eax
f010682a:	8b 40 30             	mov    0x30(%eax),%eax
f010682d:	c1 e8 10             	shr    $0x10,%eax
f0106830:	3c 03                	cmp    $0x3,%al
f0106832:	76 0f                	jbe    f0106843 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f0106834:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106839:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010683e:	e8 18 ff ff ff       	call   f010675b <lapicw>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106843:	ba 33 00 00 00       	mov    $0x33,%edx
f0106848:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010684d:	e8 09 ff ff ff       	call   f010675b <lapicw>
	lapicw(ESR, 0);
f0106852:	ba 00 00 00 00       	mov    $0x0,%edx
f0106857:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010685c:	e8 fa fe ff ff       	call   f010675b <lapicw>
	lapicw(ESR, 0);
f0106861:	ba 00 00 00 00       	mov    $0x0,%edx
f0106866:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010686b:	e8 eb fe ff ff       	call   f010675b <lapicw>
	lapicw(EOI, 0);
f0106870:	ba 00 00 00 00       	mov    $0x0,%edx
f0106875:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010687a:	e8 dc fe ff ff       	call   f010675b <lapicw>
	lapicw(ICRHI, 0);
f010687f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106884:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106889:	e8 cd fe ff ff       	call   f010675b <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010688e:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106893:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106898:	e8 be fe ff ff       	call   f010675b <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010689d:	8b 15 04 30 24 f0    	mov    0xf0243004,%edx
f01068a3:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01068a9:	f6 c4 10             	test   $0x10,%ah
f01068ac:	75 f5                	jne    f01068a3 <lapic_init+0x115>
	lapicw(TPR, 0);
f01068ae:	ba 00 00 00 00       	mov    $0x0,%edx
f01068b3:	b8 20 00 00 00       	mov    $0x20,%eax
f01068b8:	e8 9e fe ff ff       	call   f010675b <lapicw>
}
f01068bd:	c9                   	leave  
f01068be:	f3 c3                	repz ret 

f01068c0 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01068c0:	83 3d 04 30 24 f0 00 	cmpl   $0x0,0xf0243004
f01068c7:	74 13                	je     f01068dc <lapic_eoi+0x1c>
{
f01068c9:	55                   	push   %ebp
f01068ca:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f01068cc:	ba 00 00 00 00       	mov    $0x0,%edx
f01068d1:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01068d6:	e8 80 fe ff ff       	call   f010675b <lapicw>
}
f01068db:	5d                   	pop    %ebp
f01068dc:	f3 c3                	repz ret 

f01068de <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01068de:	55                   	push   %ebp
f01068df:	89 e5                	mov    %esp,%ebp
f01068e1:	56                   	push   %esi
f01068e2:	53                   	push   %ebx
f01068e3:	83 ec 10             	sub    $0x10,%esp
f01068e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01068e9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01068ec:	ba 70 00 00 00       	mov    $0x70,%edx
f01068f1:	b8 0f 00 00 00       	mov    $0xf,%eax
f01068f6:	ee                   	out    %al,(%dx)
f01068f7:	b2 71                	mov    $0x71,%dl
f01068f9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01068fe:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f01068ff:	83 3d 88 1e 20 f0 00 	cmpl   $0x0,0xf0201e88
f0106906:	75 24                	jne    f010692c <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106908:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f010690f:	00 
f0106910:	c7 44 24 08 a4 6e 10 	movl   $0xf0106ea4,0x8(%esp)
f0106917:	f0 
f0106918:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f010691f:	00 
f0106920:	c7 04 24 94 8a 10 f0 	movl   $0xf0108a94,(%esp)
f0106927:	e8 14 97 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010692c:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106933:	00 00 
	wrv[1] = addr >> 4;
f0106935:	89 f0                	mov    %esi,%eax
f0106937:	c1 e8 04             	shr    $0x4,%eax
f010693a:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106940:	c1 e3 18             	shl    $0x18,%ebx
f0106943:	89 da                	mov    %ebx,%edx
f0106945:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010694a:	e8 0c fe ff ff       	call   f010675b <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010694f:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106954:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106959:	e8 fd fd ff ff       	call   f010675b <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010695e:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106963:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106968:	e8 ee fd ff ff       	call   f010675b <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010696d:	c1 ee 0c             	shr    $0xc,%esi
f0106970:	81 ce 00 06 00 00    	or     $0x600,%esi
		lapicw(ICRHI, apicid << 24);
f0106976:	89 da                	mov    %ebx,%edx
f0106978:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010697d:	e8 d9 fd ff ff       	call   f010675b <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106982:	89 f2                	mov    %esi,%edx
f0106984:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106989:	e8 cd fd ff ff       	call   f010675b <lapicw>
		lapicw(ICRHI, apicid << 24);
f010698e:	89 da                	mov    %ebx,%edx
f0106990:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106995:	e8 c1 fd ff ff       	call   f010675b <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010699a:	89 f2                	mov    %esi,%edx
f010699c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01069a1:	e8 b5 fd ff ff       	call   f010675b <lapicw>
		microdelay(200);
	}
}
f01069a6:	83 c4 10             	add    $0x10,%esp
f01069a9:	5b                   	pop    %ebx
f01069aa:	5e                   	pop    %esi
f01069ab:	5d                   	pop    %ebp
f01069ac:	c3                   	ret    

f01069ad <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01069ad:	55                   	push   %ebp
f01069ae:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01069b0:	8b 55 08             	mov    0x8(%ebp),%edx
f01069b3:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01069b9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01069be:	e8 98 fd ff ff       	call   f010675b <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01069c3:	8b 15 04 30 24 f0    	mov    0xf0243004,%edx
f01069c9:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01069cf:	f6 c4 10             	test   $0x10,%ah
f01069d2:	75 f5                	jne    f01069c9 <lapic_ipi+0x1c>
		;
}
f01069d4:	5d                   	pop    %ebp
f01069d5:	c3                   	ret    

f01069d6 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01069d6:	55                   	push   %ebp
f01069d7:	89 e5                	mov    %esp,%ebp
f01069d9:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01069dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01069e2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01069e5:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01069e8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01069ef:	5d                   	pop    %ebp
f01069f0:	c3                   	ret    

f01069f1 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01069f1:	55                   	push   %ebp
f01069f2:	89 e5                	mov    %esp,%ebp
f01069f4:	56                   	push   %esi
f01069f5:	53                   	push   %ebx
f01069f6:	83 ec 20             	sub    $0x20,%esp
f01069f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f01069fc:	83 3b 00             	cmpl   $0x0,(%ebx)
f01069ff:	74 14                	je     f0106a15 <spin_lock+0x24>
f0106a01:	8b 73 08             	mov    0x8(%ebx),%esi
f0106a04:	e8 6a fd ff ff       	call   f0106773 <cpunum>
f0106a09:	6b c0 74             	imul   $0x74,%eax,%eax
f0106a0c:	05 20 20 20 f0       	add    $0xf0202020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106a11:	39 c6                	cmp    %eax,%esi
f0106a13:	74 15                	je     f0106a2a <spin_lock+0x39>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106a15:	89 da                	mov    %ebx,%edx
	asm volatile("lock; xchgl %0, %1" :
f0106a17:	b8 01 00 00 00       	mov    $0x1,%eax
f0106a1c:	f0 87 03             	lock xchg %eax,(%ebx)
f0106a1f:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106a24:	85 c0                	test   %eax,%eax
f0106a26:	75 2e                	jne    f0106a56 <spin_lock+0x65>
f0106a28:	eb 37                	jmp    f0106a61 <spin_lock+0x70>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106a2a:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106a2d:	e8 41 fd ff ff       	call   f0106773 <cpunum>
f0106a32:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106a36:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106a3a:	c7 44 24 08 a4 8a 10 	movl   $0xf0108aa4,0x8(%esp)
f0106a41:	f0 
f0106a42:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106a49:	00 
f0106a4a:	c7 04 24 08 8b 10 f0 	movl   $0xf0108b08,(%esp)
f0106a51:	e8 ea 95 ff ff       	call   f0100040 <_panic>
		asm volatile ("pause");
f0106a56:	f3 90                	pause  
f0106a58:	89 c8                	mov    %ecx,%eax
f0106a5a:	f0 87 02             	lock xchg %eax,(%edx)
	while (xchg(&lk->locked, 1) != 0)
f0106a5d:	85 c0                	test   %eax,%eax
f0106a5f:	75 f5                	jne    f0106a56 <spin_lock+0x65>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106a61:	e8 0d fd ff ff       	call   f0106773 <cpunum>
f0106a66:	6b c0 74             	imul   $0x74,%eax,%eax
f0106a69:	05 20 20 20 f0       	add    $0xf0202020,%eax
f0106a6e:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106a71:	8d 4b 0c             	lea    0xc(%ebx),%ecx
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0106a74:	89 e8                	mov    %ebp,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106a76:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0106a7b:	77 34                	ja     f0106ab1 <spin_lock+0xc0>
f0106a7d:	eb 2b                	jmp    f0106aaa <spin_lock+0xb9>
f0106a7f:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106a85:	76 12                	jbe    f0106a99 <spin_lock+0xa8>
		pcs[i] = ebp[1];          // saved %eip
f0106a87:	8b 5a 04             	mov    0x4(%edx),%ebx
f0106a8a:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106a8d:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106a8f:	83 c0 01             	add    $0x1,%eax
f0106a92:	83 f8 0a             	cmp    $0xa,%eax
f0106a95:	75 e8                	jne    f0106a7f <spin_lock+0x8e>
f0106a97:	eb 27                	jmp    f0106ac0 <spin_lock+0xcf>
		pcs[i] = 0;
f0106a99:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
	for (; i < 10; i++)
f0106aa0:	83 c0 01             	add    $0x1,%eax
f0106aa3:	83 f8 09             	cmp    $0x9,%eax
f0106aa6:	7e f1                	jle    f0106a99 <spin_lock+0xa8>
f0106aa8:	eb 16                	jmp    f0106ac0 <spin_lock+0xcf>
	for (i = 0; i < 10; i++){
f0106aaa:	b8 00 00 00 00       	mov    $0x0,%eax
f0106aaf:	eb e8                	jmp    f0106a99 <spin_lock+0xa8>
		pcs[i] = ebp[1];          // saved %eip
f0106ab1:	8b 50 04             	mov    0x4(%eax),%edx
f0106ab4:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106ab7:	8b 10                	mov    (%eax),%edx
	for (i = 0; i < 10; i++){
f0106ab9:	b8 01 00 00 00       	mov    $0x1,%eax
f0106abe:	eb bf                	jmp    f0106a7f <spin_lock+0x8e>
#endif
}
f0106ac0:	83 c4 20             	add    $0x20,%esp
f0106ac3:	5b                   	pop    %ebx
f0106ac4:	5e                   	pop    %esi
f0106ac5:	5d                   	pop    %ebp
f0106ac6:	c3                   	ret    

f0106ac7 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106ac7:	55                   	push   %ebp
f0106ac8:	89 e5                	mov    %esp,%ebp
f0106aca:	57                   	push   %edi
f0106acb:	56                   	push   %esi
f0106acc:	53                   	push   %ebx
f0106acd:	83 ec 6c             	sub    $0x6c,%esp
f0106ad0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106ad3:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106ad6:	74 18                	je     f0106af0 <spin_unlock+0x29>
f0106ad8:	8b 73 08             	mov    0x8(%ebx),%esi
f0106adb:	e8 93 fc ff ff       	call   f0106773 <cpunum>
f0106ae0:	6b c0 74             	imul   $0x74,%eax,%eax
f0106ae3:	05 20 20 20 f0       	add    $0xf0202020,%eax
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106ae8:	39 c6                	cmp    %eax,%esi
f0106aea:	0f 84 d4 00 00 00    	je     f0106bc4 <spin_unlock+0xfd>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106af0:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106af7:	00 
f0106af8:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106afb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106aff:	8d 45 c0             	lea    -0x40(%ebp),%eax
f0106b02:	89 04 24             	mov    %eax,(%esp)
f0106b05:	e8 1c f6 ff ff       	call   f0106126 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106b0a:	8b 43 08             	mov    0x8(%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106b0d:	0f b6 30             	movzbl (%eax),%esi
f0106b10:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106b13:	e8 5b fc ff ff       	call   f0106773 <cpunum>
f0106b18:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106b1c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106b20:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b24:	c7 04 24 d0 8a 10 f0 	movl   $0xf0108ad0,(%esp)
f0106b2b:	e8 6d d4 ff ff       	call   f0103f9d <cprintf>
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106b30:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0106b33:	85 c0                	test   %eax,%eax
f0106b35:	74 71                	je     f0106ba8 <spin_unlock+0xe1>
f0106b37:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106b3a:	8d 7d e4             	lea    -0x1c(%ebp),%edi
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106b3d:	8d 75 a8             	lea    -0x58(%ebp),%esi
f0106b40:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106b44:	89 04 24             	mov    %eax,(%esp)
f0106b47:	e8 90 e9 ff ff       	call   f01054dc <debuginfo_eip>
f0106b4c:	85 c0                	test   %eax,%eax
f0106b4e:	78 39                	js     f0106b89 <spin_unlock+0xc2>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106b50:	8b 03                	mov    (%ebx),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106b52:	89 c2                	mov    %eax,%edx
f0106b54:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106b57:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106b5b:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0106b5e:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106b62:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106b65:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106b69:	8b 55 ac             	mov    -0x54(%ebp),%edx
f0106b6c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106b70:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0106b73:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106b77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b7b:	c7 04 24 18 8b 10 f0 	movl   $0xf0108b18,(%esp)
f0106b82:	e8 16 d4 ff ff       	call   f0103f9d <cprintf>
f0106b87:	eb 12                	jmp    f0106b9b <spin_unlock+0xd4>
			else
				cprintf("  %08x\n", pcs[i]);
f0106b89:	8b 03                	mov    (%ebx),%eax
f0106b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b8f:	c7 04 24 2f 8b 10 f0 	movl   $0xf0108b2f,(%esp)
f0106b96:	e8 02 d4 ff ff       	call   f0103f9d <cprintf>
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106b9b:	39 fb                	cmp    %edi,%ebx
f0106b9d:	74 09                	je     f0106ba8 <spin_unlock+0xe1>
f0106b9f:	83 c3 04             	add    $0x4,%ebx
f0106ba2:	8b 03                	mov    (%ebx),%eax
f0106ba4:	85 c0                	test   %eax,%eax
f0106ba6:	75 98                	jne    f0106b40 <spin_unlock+0x79>
		}
		panic("spin_unlock");
f0106ba8:	c7 44 24 08 37 8b 10 	movl   $0xf0108b37,0x8(%esp)
f0106baf:	f0 
f0106bb0:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106bb7:	00 
f0106bb8:	c7 04 24 08 8b 10 f0 	movl   $0xf0108b08,(%esp)
f0106bbf:	e8 7c 94 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106bc4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106bcb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	asm volatile("lock; xchgl %0, %1" :
f0106bd2:	b8 00 00 00 00       	mov    $0x0,%eax
f0106bd7:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106bda:	83 c4 6c             	add    $0x6c,%esp
f0106bdd:	5b                   	pop    %ebx
f0106bde:	5e                   	pop    %esi
f0106bdf:	5f                   	pop    %edi
f0106be0:	5d                   	pop    %ebp
f0106be1:	c3                   	ret    
f0106be2:	66 90                	xchg   %ax,%ax
f0106be4:	66 90                	xchg   %ax,%ax
f0106be6:	66 90                	xchg   %ax,%ax
f0106be8:	66 90                	xchg   %ax,%ax
f0106bea:	66 90                	xchg   %ax,%ax
f0106bec:	66 90                	xchg   %ax,%ax
f0106bee:	66 90                	xchg   %ax,%ax

f0106bf0 <__udivdi3>:
f0106bf0:	55                   	push   %ebp
f0106bf1:	57                   	push   %edi
f0106bf2:	56                   	push   %esi
f0106bf3:	83 ec 0c             	sub    $0xc,%esp
f0106bf6:	8b 44 24 28          	mov    0x28(%esp),%eax
f0106bfa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0106bfe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0106c02:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106c06:	85 c0                	test   %eax,%eax
f0106c08:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106c0c:	89 ea                	mov    %ebp,%edx
f0106c0e:	89 0c 24             	mov    %ecx,(%esp)
f0106c11:	75 2d                	jne    f0106c40 <__udivdi3+0x50>
f0106c13:	39 e9                	cmp    %ebp,%ecx
f0106c15:	77 61                	ja     f0106c78 <__udivdi3+0x88>
f0106c17:	85 c9                	test   %ecx,%ecx
f0106c19:	89 ce                	mov    %ecx,%esi
f0106c1b:	75 0b                	jne    f0106c28 <__udivdi3+0x38>
f0106c1d:	b8 01 00 00 00       	mov    $0x1,%eax
f0106c22:	31 d2                	xor    %edx,%edx
f0106c24:	f7 f1                	div    %ecx
f0106c26:	89 c6                	mov    %eax,%esi
f0106c28:	31 d2                	xor    %edx,%edx
f0106c2a:	89 e8                	mov    %ebp,%eax
f0106c2c:	f7 f6                	div    %esi
f0106c2e:	89 c5                	mov    %eax,%ebp
f0106c30:	89 f8                	mov    %edi,%eax
f0106c32:	f7 f6                	div    %esi
f0106c34:	89 ea                	mov    %ebp,%edx
f0106c36:	83 c4 0c             	add    $0xc,%esp
f0106c39:	5e                   	pop    %esi
f0106c3a:	5f                   	pop    %edi
f0106c3b:	5d                   	pop    %ebp
f0106c3c:	c3                   	ret    
f0106c3d:	8d 76 00             	lea    0x0(%esi),%esi
f0106c40:	39 e8                	cmp    %ebp,%eax
f0106c42:	77 24                	ja     f0106c68 <__udivdi3+0x78>
f0106c44:	0f bd e8             	bsr    %eax,%ebp
f0106c47:	83 f5 1f             	xor    $0x1f,%ebp
f0106c4a:	75 3c                	jne    f0106c88 <__udivdi3+0x98>
f0106c4c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106c50:	39 34 24             	cmp    %esi,(%esp)
f0106c53:	0f 86 9f 00 00 00    	jbe    f0106cf8 <__udivdi3+0x108>
f0106c59:	39 d0                	cmp    %edx,%eax
f0106c5b:	0f 82 97 00 00 00    	jb     f0106cf8 <__udivdi3+0x108>
f0106c61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106c68:	31 d2                	xor    %edx,%edx
f0106c6a:	31 c0                	xor    %eax,%eax
f0106c6c:	83 c4 0c             	add    $0xc,%esp
f0106c6f:	5e                   	pop    %esi
f0106c70:	5f                   	pop    %edi
f0106c71:	5d                   	pop    %ebp
f0106c72:	c3                   	ret    
f0106c73:	90                   	nop
f0106c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106c78:	89 f8                	mov    %edi,%eax
f0106c7a:	f7 f1                	div    %ecx
f0106c7c:	31 d2                	xor    %edx,%edx
f0106c7e:	83 c4 0c             	add    $0xc,%esp
f0106c81:	5e                   	pop    %esi
f0106c82:	5f                   	pop    %edi
f0106c83:	5d                   	pop    %ebp
f0106c84:	c3                   	ret    
f0106c85:	8d 76 00             	lea    0x0(%esi),%esi
f0106c88:	89 e9                	mov    %ebp,%ecx
f0106c8a:	8b 3c 24             	mov    (%esp),%edi
f0106c8d:	d3 e0                	shl    %cl,%eax
f0106c8f:	89 c6                	mov    %eax,%esi
f0106c91:	b8 20 00 00 00       	mov    $0x20,%eax
f0106c96:	29 e8                	sub    %ebp,%eax
f0106c98:	89 c1                	mov    %eax,%ecx
f0106c9a:	d3 ef                	shr    %cl,%edi
f0106c9c:	89 e9                	mov    %ebp,%ecx
f0106c9e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106ca2:	8b 3c 24             	mov    (%esp),%edi
f0106ca5:	09 74 24 08          	or     %esi,0x8(%esp)
f0106ca9:	89 d6                	mov    %edx,%esi
f0106cab:	d3 e7                	shl    %cl,%edi
f0106cad:	89 c1                	mov    %eax,%ecx
f0106caf:	89 3c 24             	mov    %edi,(%esp)
f0106cb2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106cb6:	d3 ee                	shr    %cl,%esi
f0106cb8:	89 e9                	mov    %ebp,%ecx
f0106cba:	d3 e2                	shl    %cl,%edx
f0106cbc:	89 c1                	mov    %eax,%ecx
f0106cbe:	d3 ef                	shr    %cl,%edi
f0106cc0:	09 d7                	or     %edx,%edi
f0106cc2:	89 f2                	mov    %esi,%edx
f0106cc4:	89 f8                	mov    %edi,%eax
f0106cc6:	f7 74 24 08          	divl   0x8(%esp)
f0106cca:	89 d6                	mov    %edx,%esi
f0106ccc:	89 c7                	mov    %eax,%edi
f0106cce:	f7 24 24             	mull   (%esp)
f0106cd1:	39 d6                	cmp    %edx,%esi
f0106cd3:	89 14 24             	mov    %edx,(%esp)
f0106cd6:	72 30                	jb     f0106d08 <__udivdi3+0x118>
f0106cd8:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106cdc:	89 e9                	mov    %ebp,%ecx
f0106cde:	d3 e2                	shl    %cl,%edx
f0106ce0:	39 c2                	cmp    %eax,%edx
f0106ce2:	73 05                	jae    f0106ce9 <__udivdi3+0xf9>
f0106ce4:	3b 34 24             	cmp    (%esp),%esi
f0106ce7:	74 1f                	je     f0106d08 <__udivdi3+0x118>
f0106ce9:	89 f8                	mov    %edi,%eax
f0106ceb:	31 d2                	xor    %edx,%edx
f0106ced:	e9 7a ff ff ff       	jmp    f0106c6c <__udivdi3+0x7c>
f0106cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106cf8:	31 d2                	xor    %edx,%edx
f0106cfa:	b8 01 00 00 00       	mov    $0x1,%eax
f0106cff:	e9 68 ff ff ff       	jmp    f0106c6c <__udivdi3+0x7c>
f0106d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106d08:	8d 47 ff             	lea    -0x1(%edi),%eax
f0106d0b:	31 d2                	xor    %edx,%edx
f0106d0d:	83 c4 0c             	add    $0xc,%esp
f0106d10:	5e                   	pop    %esi
f0106d11:	5f                   	pop    %edi
f0106d12:	5d                   	pop    %ebp
f0106d13:	c3                   	ret    
f0106d14:	66 90                	xchg   %ax,%ax
f0106d16:	66 90                	xchg   %ax,%ax
f0106d18:	66 90                	xchg   %ax,%ax
f0106d1a:	66 90                	xchg   %ax,%ax
f0106d1c:	66 90                	xchg   %ax,%ax
f0106d1e:	66 90                	xchg   %ax,%ax

f0106d20 <__umoddi3>:
f0106d20:	55                   	push   %ebp
f0106d21:	57                   	push   %edi
f0106d22:	56                   	push   %esi
f0106d23:	83 ec 14             	sub    $0x14,%esp
f0106d26:	8b 44 24 28          	mov    0x28(%esp),%eax
f0106d2a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106d2e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0106d32:	89 c7                	mov    %eax,%edi
f0106d34:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d38:	8b 44 24 30          	mov    0x30(%esp),%eax
f0106d3c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106d40:	89 34 24             	mov    %esi,(%esp)
f0106d43:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106d47:	85 c0                	test   %eax,%eax
f0106d49:	89 c2                	mov    %eax,%edx
f0106d4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106d4f:	75 17                	jne    f0106d68 <__umoddi3+0x48>
f0106d51:	39 fe                	cmp    %edi,%esi
f0106d53:	76 4b                	jbe    f0106da0 <__umoddi3+0x80>
f0106d55:	89 c8                	mov    %ecx,%eax
f0106d57:	89 fa                	mov    %edi,%edx
f0106d59:	f7 f6                	div    %esi
f0106d5b:	89 d0                	mov    %edx,%eax
f0106d5d:	31 d2                	xor    %edx,%edx
f0106d5f:	83 c4 14             	add    $0x14,%esp
f0106d62:	5e                   	pop    %esi
f0106d63:	5f                   	pop    %edi
f0106d64:	5d                   	pop    %ebp
f0106d65:	c3                   	ret    
f0106d66:	66 90                	xchg   %ax,%ax
f0106d68:	39 f8                	cmp    %edi,%eax
f0106d6a:	77 54                	ja     f0106dc0 <__umoddi3+0xa0>
f0106d6c:	0f bd e8             	bsr    %eax,%ebp
f0106d6f:	83 f5 1f             	xor    $0x1f,%ebp
f0106d72:	75 5c                	jne    f0106dd0 <__umoddi3+0xb0>
f0106d74:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0106d78:	39 3c 24             	cmp    %edi,(%esp)
f0106d7b:	0f 87 e7 00 00 00    	ja     f0106e68 <__umoddi3+0x148>
f0106d81:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106d85:	29 f1                	sub    %esi,%ecx
f0106d87:	19 c7                	sbb    %eax,%edi
f0106d89:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106d8d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106d91:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106d95:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106d99:	83 c4 14             	add    $0x14,%esp
f0106d9c:	5e                   	pop    %esi
f0106d9d:	5f                   	pop    %edi
f0106d9e:	5d                   	pop    %ebp
f0106d9f:	c3                   	ret    
f0106da0:	85 f6                	test   %esi,%esi
f0106da2:	89 f5                	mov    %esi,%ebp
f0106da4:	75 0b                	jne    f0106db1 <__umoddi3+0x91>
f0106da6:	b8 01 00 00 00       	mov    $0x1,%eax
f0106dab:	31 d2                	xor    %edx,%edx
f0106dad:	f7 f6                	div    %esi
f0106daf:	89 c5                	mov    %eax,%ebp
f0106db1:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106db5:	31 d2                	xor    %edx,%edx
f0106db7:	f7 f5                	div    %ebp
f0106db9:	89 c8                	mov    %ecx,%eax
f0106dbb:	f7 f5                	div    %ebp
f0106dbd:	eb 9c                	jmp    f0106d5b <__umoddi3+0x3b>
f0106dbf:	90                   	nop
f0106dc0:	89 c8                	mov    %ecx,%eax
f0106dc2:	89 fa                	mov    %edi,%edx
f0106dc4:	83 c4 14             	add    $0x14,%esp
f0106dc7:	5e                   	pop    %esi
f0106dc8:	5f                   	pop    %edi
f0106dc9:	5d                   	pop    %ebp
f0106dca:	c3                   	ret    
f0106dcb:	90                   	nop
f0106dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106dd0:	8b 04 24             	mov    (%esp),%eax
f0106dd3:	be 20 00 00 00       	mov    $0x20,%esi
f0106dd8:	89 e9                	mov    %ebp,%ecx
f0106dda:	29 ee                	sub    %ebp,%esi
f0106ddc:	d3 e2                	shl    %cl,%edx
f0106dde:	89 f1                	mov    %esi,%ecx
f0106de0:	d3 e8                	shr    %cl,%eax
f0106de2:	89 e9                	mov    %ebp,%ecx
f0106de4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106de8:	8b 04 24             	mov    (%esp),%eax
f0106deb:	09 54 24 04          	or     %edx,0x4(%esp)
f0106def:	89 fa                	mov    %edi,%edx
f0106df1:	d3 e0                	shl    %cl,%eax
f0106df3:	89 f1                	mov    %esi,%ecx
f0106df5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106df9:	8b 44 24 10          	mov    0x10(%esp),%eax
f0106dfd:	d3 ea                	shr    %cl,%edx
f0106dff:	89 e9                	mov    %ebp,%ecx
f0106e01:	d3 e7                	shl    %cl,%edi
f0106e03:	89 f1                	mov    %esi,%ecx
f0106e05:	d3 e8                	shr    %cl,%eax
f0106e07:	89 e9                	mov    %ebp,%ecx
f0106e09:	09 f8                	or     %edi,%eax
f0106e0b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0106e0f:	f7 74 24 04          	divl   0x4(%esp)
f0106e13:	d3 e7                	shl    %cl,%edi
f0106e15:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106e19:	89 d7                	mov    %edx,%edi
f0106e1b:	f7 64 24 08          	mull   0x8(%esp)
f0106e1f:	39 d7                	cmp    %edx,%edi
f0106e21:	89 c1                	mov    %eax,%ecx
f0106e23:	89 14 24             	mov    %edx,(%esp)
f0106e26:	72 2c                	jb     f0106e54 <__umoddi3+0x134>
f0106e28:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0106e2c:	72 22                	jb     f0106e50 <__umoddi3+0x130>
f0106e2e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106e32:	29 c8                	sub    %ecx,%eax
f0106e34:	19 d7                	sbb    %edx,%edi
f0106e36:	89 e9                	mov    %ebp,%ecx
f0106e38:	89 fa                	mov    %edi,%edx
f0106e3a:	d3 e8                	shr    %cl,%eax
f0106e3c:	89 f1                	mov    %esi,%ecx
f0106e3e:	d3 e2                	shl    %cl,%edx
f0106e40:	89 e9                	mov    %ebp,%ecx
f0106e42:	d3 ef                	shr    %cl,%edi
f0106e44:	09 d0                	or     %edx,%eax
f0106e46:	89 fa                	mov    %edi,%edx
f0106e48:	83 c4 14             	add    $0x14,%esp
f0106e4b:	5e                   	pop    %esi
f0106e4c:	5f                   	pop    %edi
f0106e4d:	5d                   	pop    %ebp
f0106e4e:	c3                   	ret    
f0106e4f:	90                   	nop
f0106e50:	39 d7                	cmp    %edx,%edi
f0106e52:	75 da                	jne    f0106e2e <__umoddi3+0x10e>
f0106e54:	8b 14 24             	mov    (%esp),%edx
f0106e57:	89 c1                	mov    %eax,%ecx
f0106e59:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0106e5d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0106e61:	eb cb                	jmp    f0106e2e <__umoddi3+0x10e>
f0106e63:	90                   	nop
f0106e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106e68:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0106e6c:	0f 82 0f ff ff ff    	jb     f0106d81 <__umoddi3+0x61>
f0106e72:	e9 1a ff ff ff       	jmp    f0106d91 <__umoddi3+0x71>
