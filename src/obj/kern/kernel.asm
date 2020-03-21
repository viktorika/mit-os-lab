
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
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 78 0a ff ff    	lea    -0xf588(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 d8 0a 00 00       	call   f0100b3b <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7f 2b                	jg     f0100095 <test_backtrace+0x55>
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
f010006a:	83 ec 04             	sub    $0x4,%esp
f010006d:	6a 00                	push   $0x0
f010006f:	6a 00                	push   $0x0
f0100071:	6a 00                	push   $0x0
f0100073:	e8 23 08 00 00       	call   f010089b <mon_backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 94 0a ff ff    	lea    -0xf56c(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 b0 0a 00 00       	call   f0100b3b <cprintf>
}
f010008b:	83 c4 10             	add    $0x10,%esp
f010008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100091:	5b                   	pop    %ebx
f0100092:	5e                   	pop    %esi
f0100093:	5d                   	pop    %ebp
f0100094:	c3                   	ret    
		test_backtrace(x-1);
f0100095:	83 ec 0c             	sub    $0xc,%esp
f0100098:	8d 46 ff             	lea    -0x1(%esi),%eax
f010009b:	50                   	push   %eax
f010009c:	e8 9f ff ff ff       	call   f0100040 <test_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d5                	jmp    f010007b <test_backtrace+0x3b>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 a4 36 11 f0    	mov    $0xf01136a4,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 3a 18 00 00       	call   f0101909 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3e 05 00 00       	call   f0100612 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 af 0a ff ff    	lea    -0xf551(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 53 0a 00 00       	call   f0100b3b <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 7e 08 00 00       	call   f010097f <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	57                   	push   %edi
f010010a:	56                   	push   %esi
f010010b:	53                   	push   %ebx
f010010c:	83 ec 0c             	sub    $0xc,%esp
f010010f:	e8 a8 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100114:	81 c3 f4 11 01 00    	add    $0x111f4,%ebx
f010011a:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f010011d:	c7 c0 a0 36 11 f0    	mov    $0xf01136a0,%eax
f0100123:	83 38 00             	cmpl   $0x0,(%eax)
f0100126:	74 0f                	je     f0100137 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100128:	83 ec 0c             	sub    $0xc,%esp
f010012b:	6a 00                	push   $0x0
f010012d:	e8 4d 08 00 00       	call   f010097f <monitor>
f0100132:	83 c4 10             	add    $0x10,%esp
f0100135:	eb f1                	jmp    f0100128 <_panic+0x22>
	panicstr = fmt;
f0100137:	89 38                	mov    %edi,(%eax)
	__asm __volatile("cli; cld");
f0100139:	fa                   	cli    
f010013a:	fc                   	cld    
	va_start(ap, fmt);
f010013b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013e:	83 ec 04             	sub    $0x4,%esp
f0100141:	ff 75 0c             	pushl  0xc(%ebp)
f0100144:	ff 75 08             	pushl  0x8(%ebp)
f0100147:	8d 83 ca 0a ff ff    	lea    -0xf536(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 e8 09 00 00       	call   f0100b3b <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 a7 09 00 00       	call   f0100b04 <vcprintf>
	cprintf("\n");
f010015d:	8d 83 06 0b ff ff    	lea    -0xf4fa(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 d0 09 00 00       	call   f0100b3b <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb b8                	jmp    f0100128 <_panic+0x22>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8e 11 01 00    	add    $0x1118e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	pushl  0xc(%ebp)
f0100189:	ff 75 08             	pushl  0x8(%ebp)
f010018c:	8d 83 e2 0a ff ff    	lea    -0xf51e(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 a3 09 00 00       	call   f0100b3b <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 60 09 00 00       	call   f0100b04 <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 06 0b ff ff    	lea    -0xf4fa(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 89 09 00 00       	call   f0100b3b <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c9:	a8 01                	test   $0x1,%al
f01001cb:	74 0b                	je     f01001d8 <serial_proc_data+0x18>
f01001cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d3:	0f b6 c0             	movzbl %al,%eax
}
f01001d6:	5d                   	pop    %ebp
f01001d7:	c3                   	ret    
		return -1;
f01001d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001dd:	eb f7                	jmp    f01001d6 <serial_proc_data+0x16>

f01001df <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001df:	55                   	push   %ebp
f01001e0:	89 e5                	mov    %esp,%ebp
f01001e2:	56                   	push   %esi
f01001e3:	53                   	push   %ebx
f01001e4:	e8 d3 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01001e9:	81 c3 1f 11 01 00    	add    $0x1111f,%ebx
f01001ef:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001f1:	ff d6                	call   *%esi
f01001f3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f6:	74 2e                	je     f0100226 <cons_intr+0x47>
		if (c == 0)
f01001f8:	85 c0                	test   %eax,%eax
f01001fa:	74 f5                	je     f01001f1 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001fc:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f0100202:	8d 51 01             	lea    0x1(%ecx),%edx
f0100205:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f010020b:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100212:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100218:	75 d7                	jne    f01001f1 <cons_intr+0x12>
			cons.wpos = 0;
f010021a:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
f0100221:	00 00 00 
f0100224:	eb cb                	jmp    f01001f1 <cons_intr+0x12>
	}
}
f0100226:	5b                   	pop    %ebx
f0100227:	5e                   	pop    %esi
f0100228:	5d                   	pop    %ebp
f0100229:	c3                   	ret    

f010022a <kbd_proc_data>:
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
f010022d:	56                   	push   %esi
f010022e:	53                   	push   %ebx
f010022f:	e8 88 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100234:	81 c3 d4 10 01 00    	add    $0x110d4,%ebx
f010023a:	ba 64 00 00 00       	mov    $0x64,%edx
f010023f:	ec                   	in     (%dx),%al
	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100240:	a8 01                	test   $0x1,%al
f0100242:	0f 84 fe 00 00 00    	je     f0100346 <kbd_proc_data+0x11c>
f0100248:	ba 60 00 00 00       	mov    $0x60,%edx
f010024d:	ec                   	in     (%dx),%al
f010024e:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100250:	3c e0                	cmp    $0xe0,%al
f0100252:	0f 84 93 00 00 00    	je     f01002eb <kbd_proc_data+0xc1>
	} else if (data & 0x80) {
f0100258:	84 c0                	test   %al,%al
f010025a:	0f 88 a0 00 00 00    	js     f0100300 <kbd_proc_data+0xd6>
	} else if (shift & E0ESC) {
f0100260:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100266:	f6 c1 40             	test   $0x40,%cl
f0100269:	74 0e                	je     f0100279 <kbd_proc_data+0x4f>
		data |= 0x80;
f010026b:	83 c8 80             	or     $0xffffff80,%eax
f010026e:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100270:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100273:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f0100279:	0f b6 d2             	movzbl %dl,%edx
f010027c:	0f b6 84 13 38 0c ff 	movzbl -0xf3c8(%ebx,%edx,1),%eax
f0100283:	ff 
f0100284:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f010028a:	0f b6 8c 13 38 0b ff 	movzbl -0xf4c8(%ebx,%edx,1),%ecx
f0100291:	ff 
f0100292:	31 c8                	xor    %ecx,%eax
f0100294:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f010029a:	89 c1                	mov    %eax,%ecx
f010029c:	83 e1 03             	and    $0x3,%ecx
f010029f:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002a6:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002aa:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002ad:	a8 08                	test   $0x8,%al
f01002af:	74 0d                	je     f01002be <kbd_proc_data+0x94>
		if ('a' <= c && c <= 'z')
f01002b1:	89 f2                	mov    %esi,%edx
f01002b3:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002b6:	83 f9 19             	cmp    $0x19,%ecx
f01002b9:	77 7a                	ja     f0100335 <kbd_proc_data+0x10b>
			c += 'A' - 'a';
f01002bb:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002be:	f7 d0                	not    %eax
f01002c0:	a8 06                	test   $0x6,%al
f01002c2:	75 33                	jne    f01002f7 <kbd_proc_data+0xcd>
f01002c4:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002ca:	75 2b                	jne    f01002f7 <kbd_proc_data+0xcd>
		cprintf("Rebooting!\n");
f01002cc:	83 ec 0c             	sub    $0xc,%esp
f01002cf:	8d 83 fc 0a ff ff    	lea    -0xf504(%ebx),%eax
f01002d5:	50                   	push   %eax
f01002d6:	e8 60 08 00 00       	call   f0100b3b <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002db:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e0:	ba 92 00 00 00       	mov    $0x92,%edx
f01002e5:	ee                   	out    %al,(%dx)
f01002e6:	83 c4 10             	add    $0x10,%esp
f01002e9:	eb 0c                	jmp    f01002f7 <kbd_proc_data+0xcd>
		shift |= E0ESC;
f01002eb:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002f2:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002f7:	89 f0                	mov    %esi,%eax
f01002f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002fc:	5b                   	pop    %ebx
f01002fd:	5e                   	pop    %esi
f01002fe:	5d                   	pop    %ebp
f01002ff:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100300:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100306:	89 ce                	mov    %ecx,%esi
f0100308:	83 e6 40             	and    $0x40,%esi
f010030b:	83 e0 7f             	and    $0x7f,%eax
f010030e:	85 f6                	test   %esi,%esi
f0100310:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100313:	0f b6 d2             	movzbl %dl,%edx
f0100316:	0f b6 84 13 38 0c ff 	movzbl -0xf3c8(%ebx,%edx,1),%eax
f010031d:	ff 
f010031e:	83 c8 40             	or     $0x40,%eax
f0100321:	0f b6 c0             	movzbl %al,%eax
f0100324:	f7 d0                	not    %eax
f0100326:	21 c8                	and    %ecx,%eax
f0100328:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f010032e:	be 00 00 00 00       	mov    $0x0,%esi
f0100333:	eb c2                	jmp    f01002f7 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f0100335:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100338:	8d 4e 20             	lea    0x20(%esi),%ecx
f010033b:	83 fa 1a             	cmp    $0x1a,%edx
f010033e:	0f 42 f1             	cmovb  %ecx,%esi
f0100341:	e9 78 ff ff ff       	jmp    f01002be <kbd_proc_data+0x94>
		return -1;
f0100346:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010034b:	eb aa                	jmp    f01002f7 <kbd_proc_data+0xcd>

f010034d <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010034d:	55                   	push   %ebp
f010034e:	89 e5                	mov    %esp,%ebp
f0100350:	57                   	push   %edi
f0100351:	56                   	push   %esi
f0100352:	53                   	push   %ebx
f0100353:	83 ec 1c             	sub    $0x1c,%esp
f0100356:	e8 61 fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010035b:	81 c3 ad 0f 01 00    	add    $0x10fad,%ebx
f0100361:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100364:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100369:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010036a:	a8 20                	test   $0x20,%al
f010036c:	75 27                	jne    f0100395 <cons_putc+0x48>
	for (i = 0;
f010036e:	be 00 00 00 00       	mov    $0x0,%esi
f0100373:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100378:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010037d:	89 ca                	mov    %ecx,%edx
f010037f:	ec                   	in     (%dx),%al
f0100380:	ec                   	in     (%dx),%al
f0100381:	ec                   	in     (%dx),%al
f0100382:	ec                   	in     (%dx),%al
	     i++)
f0100383:	83 c6 01             	add    $0x1,%esi
f0100386:	89 fa                	mov    %edi,%edx
f0100388:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100389:	a8 20                	test   $0x20,%al
f010038b:	75 08                	jne    f0100395 <cons_putc+0x48>
f010038d:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100393:	7e e8                	jle    f010037d <cons_putc+0x30>
	outb(COM1 + COM_TX, c);
f0100395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100398:	89 f8                	mov    %edi,%eax
f010039a:	88 45 e3             	mov    %al,-0x1d(%ebp)
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010039d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a2:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003a3:	ba 79 03 00 00       	mov    $0x379,%edx
f01003a8:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003a9:	84 c0                	test   %al,%al
f01003ab:	78 27                	js     f01003d4 <cons_putc+0x87>
f01003ad:	be 00 00 00 00       	mov    $0x0,%esi
f01003b2:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b7:	bf 79 03 00 00       	mov    $0x379,%edi
f01003bc:	89 ca                	mov    %ecx,%edx
f01003be:	ec                   	in     (%dx),%al
f01003bf:	ec                   	in     (%dx),%al
f01003c0:	ec                   	in     (%dx),%al
f01003c1:	ec                   	in     (%dx),%al
f01003c2:	83 c6 01             	add    $0x1,%esi
f01003c5:	89 fa                	mov    %edi,%edx
f01003c7:	ec                   	in     (%dx),%al
f01003c8:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003ce:	7f 04                	jg     f01003d4 <cons_putc+0x87>
f01003d0:	84 c0                	test   %al,%al
f01003d2:	79 e8                	jns    f01003bc <cons_putc+0x6f>
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d4:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d9:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003dd:	ee                   	out    %al,(%dx)
f01003de:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e3:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003e8:	ee                   	out    %al,(%dx)
f01003e9:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ee:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f2:	89 fa                	mov    %edi,%edx
f01003f4:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003fa:	89 f8                	mov    %edi,%eax
f01003fc:	80 cc 07             	or     $0x7,%ah
f01003ff:	85 d2                	test   %edx,%edx
f0100401:	0f 45 c7             	cmovne %edi,%eax
f0100404:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100407:	0f b6 c0             	movzbl %al,%eax
f010040a:	83 f8 09             	cmp    $0x9,%eax
f010040d:	0f 84 b9 00 00 00    	je     f01004cc <cons_putc+0x17f>
f0100413:	83 f8 09             	cmp    $0x9,%eax
f0100416:	7e 74                	jle    f010048c <cons_putc+0x13f>
f0100418:	83 f8 0a             	cmp    $0xa,%eax
f010041b:	0f 84 9e 00 00 00    	je     f01004bf <cons_putc+0x172>
f0100421:	83 f8 0d             	cmp    $0xd,%eax
f0100424:	0f 85 d9 00 00 00    	jne    f0100503 <cons_putc+0x1b6>
		crt_pos -= (crt_pos % CRT_COLS);
f010042a:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100431:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100437:	c1 e8 16             	shr    $0x16,%eax
f010043a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043d:	c1 e0 04             	shl    $0x4,%eax
f0100440:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100447:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010044e:	cf 07 
f0100450:	0f 87 d4 00 00 00    	ja     f010052a <cons_putc+0x1dd>
	outb(addr_6845, 14);
f0100456:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f010045c:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100461:	89 ca                	mov    %ecx,%edx
f0100463:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100464:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f010046b:	8d 71 01             	lea    0x1(%ecx),%esi
f010046e:	89 d8                	mov    %ebx,%eax
f0100470:	66 c1 e8 08          	shr    $0x8,%ax
f0100474:	89 f2                	mov    %esi,%edx
f0100476:	ee                   	out    %al,(%dx)
f0100477:	b8 0f 00 00 00       	mov    $0xf,%eax
f010047c:	89 ca                	mov    %ecx,%edx
f010047e:	ee                   	out    %al,(%dx)
f010047f:	89 d8                	mov    %ebx,%eax
f0100481:	89 f2                	mov    %esi,%edx
f0100483:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100484:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100487:	5b                   	pop    %ebx
f0100488:	5e                   	pop    %esi
f0100489:	5f                   	pop    %edi
f010048a:	5d                   	pop    %ebp
f010048b:	c3                   	ret    
	switch (c & 0xff) {
f010048c:	83 f8 08             	cmp    $0x8,%eax
f010048f:	75 72                	jne    f0100503 <cons_putc+0x1b6>
		if (crt_pos > 0) {
f0100491:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100498:	66 85 c0             	test   %ax,%ax
f010049b:	74 b9                	je     f0100456 <cons_putc+0x109>
			crt_pos--;
f010049d:	83 e8 01             	sub    $0x1,%eax
f01004a0:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a7:	0f b7 c0             	movzwl %ax,%eax
f01004aa:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ae:	b2 00                	mov    $0x0,%dl
f01004b0:	83 ca 20             	or     $0x20,%edx
f01004b3:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f01004b9:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004bd:	eb 88                	jmp    f0100447 <cons_putc+0xfa>
		crt_pos += CRT_COLS;
f01004bf:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f01004c6:	50 
f01004c7:	e9 5e ff ff ff       	jmp    f010042a <cons_putc+0xdd>
		cons_putc(' ');
f01004cc:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d1:	e8 77 fe ff ff       	call   f010034d <cons_putc>
		cons_putc(' ');
f01004d6:	b8 20 00 00 00       	mov    $0x20,%eax
f01004db:	e8 6d fe ff ff       	call   f010034d <cons_putc>
		cons_putc(' ');
f01004e0:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e5:	e8 63 fe ff ff       	call   f010034d <cons_putc>
		cons_putc(' ');
f01004ea:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ef:	e8 59 fe ff ff       	call   f010034d <cons_putc>
		cons_putc(' ');
f01004f4:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f9:	e8 4f fe ff ff       	call   f010034d <cons_putc>
f01004fe:	e9 44 ff ff ff       	jmp    f0100447 <cons_putc+0xfa>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100503:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010050a:	8d 50 01             	lea    0x1(%eax),%edx
f010050d:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100514:	0f b7 c0             	movzwl %ax,%eax
f0100517:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010051d:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100521:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100525:	e9 1d ff ff ff       	jmp    f0100447 <cons_putc+0xfa>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010052a:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f0100530:	83 ec 04             	sub    $0x4,%esp
f0100533:	68 00 0f 00 00       	push   $0xf00
f0100538:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010053e:	52                   	push   %edx
f010053f:	50                   	push   %eax
f0100540:	e8 11 14 00 00       	call   f0101956 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100545:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010054b:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100551:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100557:	83 c4 10             	add    $0x10,%esp
f010055a:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010055f:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100562:	39 d0                	cmp    %edx,%eax
f0100564:	75 f4                	jne    f010055a <cons_putc+0x20d>
		crt_pos -= CRT_COLS;
f0100566:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010056d:	50 
f010056e:	e9 e3 fe ff ff       	jmp    f0100456 <cons_putc+0x109>

f0100573 <serial_intr>:
{
f0100573:	e8 e7 01 00 00       	call   f010075f <__x86.get_pc_thunk.ax>
f0100578:	05 90 0d 01 00       	add    $0x10d90,%eax
	if (serial_exists)
f010057d:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100584:	75 02                	jne    f0100588 <serial_intr+0x15>
f0100586:	f3 c3                	repz ret 
{
f0100588:	55                   	push   %ebp
f0100589:	89 e5                	mov    %esp,%ebp
f010058b:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010058e:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f0100594:	e8 46 fc ff ff       	call   f01001df <cons_intr>
}
f0100599:	c9                   	leave  
f010059a:	c3                   	ret    

f010059b <kbd_intr>:
{
f010059b:	55                   	push   %ebp
f010059c:	89 e5                	mov    %esp,%ebp
f010059e:	83 ec 08             	sub    $0x8,%esp
f01005a1:	e8 b9 01 00 00       	call   f010075f <__x86.get_pc_thunk.ax>
f01005a6:	05 62 0d 01 00       	add    $0x10d62,%eax
	cons_intr(kbd_proc_data);
f01005ab:	8d 80 22 ef fe ff    	lea    -0x110de(%eax),%eax
f01005b1:	e8 29 fc ff ff       	call   f01001df <cons_intr>
}
f01005b6:	c9                   	leave  
f01005b7:	c3                   	ret    

f01005b8 <cons_getc>:
{
f01005b8:	55                   	push   %ebp
f01005b9:	89 e5                	mov    %esp,%ebp
f01005bb:	53                   	push   %ebx
f01005bc:	83 ec 04             	sub    $0x4,%esp
f01005bf:	e8 f8 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005c4:	81 c3 44 0d 01 00    	add    $0x10d44,%ebx
	serial_intr();
f01005ca:	e8 a4 ff ff ff       	call   f0100573 <serial_intr>
	kbd_intr();
f01005cf:	e8 c7 ff ff ff       	call   f010059b <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005d4:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	return 0;
f01005da:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005df:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f01005e5:	74 19                	je     f0100600 <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005e7:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005ea:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f01005f0:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f01005f7:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005f8:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005fe:	74 06                	je     f0100606 <cons_getc+0x4e>
}
f0100600:	83 c4 04             	add    $0x4,%esp
f0100603:	5b                   	pop    %ebx
f0100604:	5d                   	pop    %ebp
f0100605:	c3                   	ret    
			cons.rpos = 0;
f0100606:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f010060d:	00 00 00 
f0100610:	eb ee                	jmp    f0100600 <cons_getc+0x48>

f0100612 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100612:	55                   	push   %ebp
f0100613:	89 e5                	mov    %esp,%ebp
f0100615:	57                   	push   %edi
f0100616:	56                   	push   %esi
f0100617:	53                   	push   %ebx
f0100618:	83 ec 1c             	sub    $0x1c,%esp
f010061b:	e8 9c fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100620:	81 c3 e8 0c 01 00    	add    $0x10ce8,%ebx
	was = *cp;
f0100626:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100634:	5a a5 
	if (*cp != 0xA55A) {
f0100636:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063d:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100641:	0f 84 bc 00 00 00    	je     f0100703 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100647:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f010064e:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100651:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100658:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f010065e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100663:	89 fa                	mov    %edi,%edx
f0100665:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100666:	8d 4f 01             	lea    0x1(%edi),%ecx
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100669:	89 ca                	mov    %ecx,%edx
f010066b:	ec                   	in     (%dx),%al
f010066c:	0f b6 f0             	movzbl %al,%esi
f010066f:	c1 e6 08             	shl    $0x8,%esi
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100672:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100677:	89 fa                	mov    %edi,%edx
f0100679:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010067a:	89 ca                	mov    %ecx,%edx
f010067c:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010067d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100680:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100686:	0f b6 c0             	movzbl %al,%eax
f0100689:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010068b:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100692:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100697:	89 c8                	mov    %ecx,%eax
f0100699:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010069e:	ee                   	out    %al,(%dx)
f010069f:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006a4:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a9:	89 fa                	mov    %edi,%edx
f01006ab:	ee                   	out    %al,(%dx)
f01006ac:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006b1:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b6:	ee                   	out    %al,(%dx)
f01006b7:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006bc:	89 c8                	mov    %ecx,%eax
f01006be:	89 f2                	mov    %esi,%edx
f01006c0:	ee                   	out    %al,(%dx)
f01006c1:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c6:	89 fa                	mov    %edi,%edx
f01006c8:	ee                   	out    %al,(%dx)
f01006c9:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006ce:	89 c8                	mov    %ecx,%eax
f01006d0:	ee                   	out    %al,(%dx)
f01006d1:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d6:	89 f2                	mov    %esi,%edx
f01006d8:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d9:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006de:	ec                   	in     (%dx),%al
f01006df:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006e1:	3c ff                	cmp    $0xff,%al
f01006e3:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f01006ea:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006ef:	ec                   	in     (%dx),%al
f01006f0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006f5:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f6:	80 f9 ff             	cmp    $0xff,%cl
f01006f9:	74 25                	je     f0100720 <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006fe:	5b                   	pop    %ebx
f01006ff:	5e                   	pop    %esi
f0100700:	5f                   	pop    %edi
f0100701:	5d                   	pop    %ebp
f0100702:	c3                   	ret    
		*cp = was;
f0100703:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010070a:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f0100711:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100714:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010071b:	e9 38 ff ff ff       	jmp    f0100658 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f0100720:	83 ec 0c             	sub    $0xc,%esp
f0100723:	8d 83 08 0b ff ff    	lea    -0xf4f8(%ebx),%eax
f0100729:	50                   	push   %eax
f010072a:	e8 0c 04 00 00       	call   f0100b3b <cprintf>
f010072f:	83 c4 10             	add    $0x10,%esp
}
f0100732:	eb c7                	jmp    f01006fb <cons_init+0xe9>

f0100734 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100734:	55                   	push   %ebp
f0100735:	89 e5                	mov    %esp,%ebp
f0100737:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010073a:	8b 45 08             	mov    0x8(%ebp),%eax
f010073d:	e8 0b fc ff ff       	call   f010034d <cons_putc>
}
f0100742:	c9                   	leave  
f0100743:	c3                   	ret    

f0100744 <getchar>:

int
getchar(void)
{
f0100744:	55                   	push   %ebp
f0100745:	89 e5                	mov    %esp,%ebp
f0100747:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010074a:	e8 69 fe ff ff       	call   f01005b8 <cons_getc>
f010074f:	85 c0                	test   %eax,%eax
f0100751:	74 f7                	je     f010074a <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100753:	c9                   	leave  
f0100754:	c3                   	ret    

f0100755 <iscons>:

int
iscons(int fdnum)
{
f0100755:	55                   	push   %ebp
f0100756:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100758:	b8 01 00 00 00       	mov    $0x1,%eax
f010075d:	5d                   	pop    %ebp
f010075e:	c3                   	ret    

f010075f <__x86.get_pc_thunk.ax>:
f010075f:	8b 04 24             	mov    (%esp),%eax
f0100762:	c3                   	ret    

f0100763 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100763:	55                   	push   %ebp
f0100764:	89 e5                	mov    %esp,%ebp
f0100766:	56                   	push   %esi
f0100767:	53                   	push   %ebx
f0100768:	e8 4f fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010076d:	81 c3 9b 0b 01 00    	add    $0x10b9b,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100773:	83 ec 04             	sub    $0x4,%esp
f0100776:	8d 83 38 0d ff ff    	lea    -0xf2c8(%ebx),%eax
f010077c:	50                   	push   %eax
f010077d:	8d 83 56 0d ff ff    	lea    -0xf2aa(%ebx),%eax
f0100783:	50                   	push   %eax
f0100784:	8d b3 5b 0d ff ff    	lea    -0xf2a5(%ebx),%esi
f010078a:	56                   	push   %esi
f010078b:	e8 ab 03 00 00       	call   f0100b3b <cprintf>
f0100790:	83 c4 0c             	add    $0xc,%esp
f0100793:	8d 83 0c 0e ff ff    	lea    -0xf1f4(%ebx),%eax
f0100799:	50                   	push   %eax
f010079a:	8d 83 64 0d ff ff    	lea    -0xf29c(%ebx),%eax
f01007a0:	50                   	push   %eax
f01007a1:	56                   	push   %esi
f01007a2:	e8 94 03 00 00       	call   f0100b3b <cprintf>
f01007a7:	83 c4 0c             	add    $0xc,%esp
f01007aa:	8d 83 34 0e ff ff    	lea    -0xf1cc(%ebx),%eax
f01007b0:	50                   	push   %eax
f01007b1:	8d 83 6d 0d ff ff    	lea    -0xf293(%ebx),%eax
f01007b7:	50                   	push   %eax
f01007b8:	56                   	push   %esi
f01007b9:	e8 7d 03 00 00       	call   f0100b3b <cprintf>
	return 0;
}
f01007be:	b8 00 00 00 00       	mov    $0x0,%eax
f01007c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007c6:	5b                   	pop    %ebx
f01007c7:	5e                   	pop    %esi
f01007c8:	5d                   	pop    %ebp
f01007c9:	c3                   	ret    

f01007ca <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007ca:	55                   	push   %ebp
f01007cb:	89 e5                	mov    %esp,%ebp
f01007cd:	57                   	push   %edi
f01007ce:	56                   	push   %esi
f01007cf:	53                   	push   %ebx
f01007d0:	83 ec 18             	sub    $0x18,%esp
f01007d3:	e8 e4 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007d8:	81 c3 30 0b 01 00    	add    $0x10b30,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007de:	8d 83 77 0d ff ff    	lea    -0xf289(%ebx),%eax
f01007e4:	50                   	push   %eax
f01007e5:	e8 51 03 00 00       	call   f0100b3b <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ea:	83 c4 08             	add    $0x8,%esp
f01007ed:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007f3:	8d 83 68 0e ff ff    	lea    -0xf198(%ebx),%eax
f01007f9:	50                   	push   %eax
f01007fa:	e8 3c 03 00 00       	call   f0100b3b <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007ff:	83 c4 0c             	add    $0xc,%esp
f0100802:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100808:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f010080e:	50                   	push   %eax
f010080f:	57                   	push   %edi
f0100810:	8d 83 90 0e ff ff    	lea    -0xf170(%ebx),%eax
f0100816:	50                   	push   %eax
f0100817:	e8 1f 03 00 00       	call   f0100b3b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010081c:	83 c4 0c             	add    $0xc,%esp
f010081f:	c7 c0 69 1d 10 f0    	mov    $0xf0101d69,%eax
f0100825:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010082b:	52                   	push   %edx
f010082c:	50                   	push   %eax
f010082d:	8d 83 b4 0e ff ff    	lea    -0xf14c(%ebx),%eax
f0100833:	50                   	push   %eax
f0100834:	e8 02 03 00 00       	call   f0100b3b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100839:	83 c4 0c             	add    $0xc,%esp
f010083c:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f0100842:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100848:	52                   	push   %edx
f0100849:	50                   	push   %eax
f010084a:	8d 83 d8 0e ff ff    	lea    -0xf128(%ebx),%eax
f0100850:	50                   	push   %eax
f0100851:	e8 e5 02 00 00       	call   f0100b3b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100856:	83 c4 0c             	add    $0xc,%esp
f0100859:	c7 c6 a4 36 11 f0    	mov    $0xf01136a4,%esi
f010085f:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100865:	50                   	push   %eax
f0100866:	56                   	push   %esi
f0100867:	8d 83 fc 0e ff ff    	lea    -0xf104(%ebx),%eax
f010086d:	50                   	push   %eax
f010086e:	e8 c8 02 00 00       	call   f0100b3b <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100873:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100876:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010087c:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f010087e:	c1 fe 0a             	sar    $0xa,%esi
f0100881:	56                   	push   %esi
f0100882:	8d 83 20 0f ff ff    	lea    -0xf0e0(%ebx),%eax
f0100888:	50                   	push   %eax
f0100889:	e8 ad 02 00 00       	call   f0100b3b <cprintf>
	return 0;
}
f010088e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100893:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100896:	5b                   	pop    %ebx
f0100897:	5e                   	pop    %esi
f0100898:	5f                   	pop    %edi
f0100899:	5d                   	pop    %ebp
f010089a:	c3                   	ret    

f010089b <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010089b:	55                   	push   %ebp
f010089c:	89 e5                	mov    %esp,%ebp
f010089e:	57                   	push   %edi
f010089f:	56                   	push   %esi
f01008a0:	53                   	push   %ebx
f01008a1:	83 ec 58             	sub    $0x58,%esp
f01008a4:	e8 13 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01008a9:	81 c3 5f 0a 01 00    	add    $0x10a5f,%ebx
	cprintf("Stack backtrace:\n");
f01008af:	8d 83 90 0d ff ff    	lea    -0xf270(%ebx),%eax
f01008b5:	50                   	push   %eax
f01008b6:	e8 80 02 00 00       	call   f0100b3b <cprintf>

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008bb:	89 e8                	mov    %ebp,%eax
    unsigned int ebp, esp, eip;
    ebp = read_ebp(); 
    while(ebp){
f01008bd:	83 c4 10             	add    $0x10,%esp
f01008c0:	85 c0                	test   %eax,%eax
f01008c2:	0f 84 aa 00 00 00    	je     f0100972 <mon_backtrace+0xd7>
f01008c8:	89 c7                	mov    %eax,%edi
        eip = *(unsigned int *)(ebp + 4);
        esp = ebp + 4;
        cprintf("ebp %08x eip %08x args", ebp, eip);
f01008ca:	8d 83 a2 0d ff ff    	lea    -0xf25e(%ebx),%eax
f01008d0:	89 45 b8             	mov    %eax,-0x48(%ebp)
        for(int i = 0; i < 5; ++i){
            esp += 4;
            cprintf(" %08x", *(unsigned int *)esp);
f01008d3:	8d 83 b9 0d ff ff    	lea    -0xf247(%ebx),%eax
f01008d9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f01008dc:	eb 54                	jmp    f0100932 <mon_backtrace+0x97>
f01008de:	8b 7d bc             	mov    -0x44(%ebp),%edi
        }   
        cprintf("\n");
f01008e1:	83 ec 0c             	sub    $0xc,%esp
f01008e4:	8d 83 06 0b ff ff    	lea    -0xf4fa(%ebx),%eax
f01008ea:	50                   	push   %eax
f01008eb:	e8 4b 02 00 00       	call   f0100b3b <cprintf>
        struct Eipdebuginfo info;
		if (-1 == debuginfo_eip(eip, &info))
f01008f0:	83 c4 08             	add    $0x8,%esp
f01008f3:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008f6:	50                   	push   %eax
f01008f7:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01008fa:	56                   	push   %esi
f01008fb:	e8 6e 03 00 00       	call   f0100c6e <debuginfo_eip>
f0100900:	83 c4 10             	add    $0x10,%esp
f0100903:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100906:	74 6a                	je     f0100972 <mon_backtrace+0xd7>
			break;
        cprintf("%s:%d: %.*s+%u\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
f0100908:	83 ec 08             	sub    $0x8,%esp
f010090b:	89 f0                	mov    %esi,%eax
f010090d:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100910:	50                   	push   %eax
f0100911:	ff 75 d8             	pushl  -0x28(%ebp)
f0100914:	ff 75 dc             	pushl  -0x24(%ebp)
f0100917:	ff 75 d4             	pushl  -0x2c(%ebp)
f010091a:	ff 75 d0             	pushl  -0x30(%ebp)
f010091d:	8d 83 bf 0d ff ff    	lea    -0xf241(%ebx),%eax
f0100923:	50                   	push   %eax
f0100924:	e8 12 02 00 00       	call   f0100b3b <cprintf>
        ebp = *(unsigned int *)ebp;
f0100929:	8b 3f                	mov    (%edi),%edi
    while(ebp){
f010092b:	83 c4 20             	add    $0x20,%esp
f010092e:	85 ff                	test   %edi,%edi
f0100930:	74 40                	je     f0100972 <mon_backtrace+0xd7>
        eip = *(unsigned int *)(ebp + 4);
f0100932:	8d 77 04             	lea    0x4(%edi),%esi
f0100935:	8b 47 04             	mov    0x4(%edi),%eax
f0100938:	89 45 c0             	mov    %eax,-0x40(%ebp)
        cprintf("ebp %08x eip %08x args", ebp, eip);
f010093b:	83 ec 04             	sub    $0x4,%esp
f010093e:	50                   	push   %eax
f010093f:	57                   	push   %edi
f0100940:	ff 75 b8             	pushl  -0x48(%ebp)
f0100943:	e8 f3 01 00 00       	call   f0100b3b <cprintf>
f0100948:	8d 47 18             	lea    0x18(%edi),%eax
f010094b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010094e:	83 c4 10             	add    $0x10,%esp
f0100951:	89 7d bc             	mov    %edi,-0x44(%ebp)
f0100954:	8b 7d b4             	mov    -0x4c(%ebp),%edi
            esp += 4;
f0100957:	83 c6 04             	add    $0x4,%esi
            cprintf(" %08x", *(unsigned int *)esp);
f010095a:	83 ec 08             	sub    $0x8,%esp
f010095d:	ff 36                	pushl  (%esi)
f010095f:	57                   	push   %edi
f0100960:	e8 d6 01 00 00       	call   f0100b3b <cprintf>
        for(int i = 0; i < 5; ++i){
f0100965:	83 c4 10             	add    $0x10,%esp
f0100968:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f010096b:	75 ea                	jne    f0100957 <mon_backtrace+0xbc>
f010096d:	e9 6c ff ff ff       	jmp    f01008de <mon_backtrace+0x43>
    }   
	return 0;
}
f0100972:	b8 00 00 00 00       	mov    $0x0,%eax
f0100977:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010097a:	5b                   	pop    %ebx
f010097b:	5e                   	pop    %esi
f010097c:	5f                   	pop    %edi
f010097d:	5d                   	pop    %ebp
f010097e:	c3                   	ret    

f010097f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010097f:	55                   	push   %ebp
f0100980:	89 e5                	mov    %esp,%ebp
f0100982:	57                   	push   %edi
f0100983:	56                   	push   %esi
f0100984:	53                   	push   %ebx
f0100985:	83 ec 68             	sub    $0x68,%esp
f0100988:	e8 2f f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010098d:	81 c3 7b 09 01 00    	add    $0x1097b,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100993:	8d 83 4c 0f ff ff    	lea    -0xf0b4(%ebx),%eax
f0100999:	50                   	push   %eax
f010099a:	e8 9c 01 00 00       	call   f0100b3b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010099f:	8d 83 70 0f ff ff    	lea    -0xf090(%ebx),%eax
f01009a5:	89 04 24             	mov    %eax,(%esp)
f01009a8:	e8 8e 01 00 00       	call   f0100b3b <cprintf>
f01009ad:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01009b0:	8d bb d3 0d ff ff    	lea    -0xf22d(%ebx),%edi
f01009b6:	e9 ce 00 00 00       	jmp    f0100a89 <monitor+0x10a>
f01009bb:	83 ec 08             	sub    $0x8,%esp
f01009be:	0f be c0             	movsbl %al,%eax
f01009c1:	50                   	push   %eax
f01009c2:	57                   	push   %edi
f01009c3:	e8 e3 0e 00 00       	call   f01018ab <strchr>
f01009c8:	83 c4 10             	add    $0x10,%esp
f01009cb:	85 c0                	test   %eax,%eax
f01009cd:	74 08                	je     f01009d7 <monitor+0x58>
			*buf++ = 0;
f01009cf:	c6 06 00             	movb   $0x0,(%esi)
f01009d2:	8d 76 01             	lea    0x1(%esi),%esi
f01009d5:	eb 41                	jmp    f0100a18 <monitor+0x99>
		if (*buf == 0)
f01009d7:	80 3e 00             	cmpb   $0x0,(%esi)
f01009da:	74 43                	je     f0100a1f <monitor+0xa0>
		if (argc == MAXARGS-1) {
f01009dc:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009e0:	0f 84 8f 00 00 00    	je     f0100a75 <monitor+0xf6>
		argv[argc++] = buf;
f01009e6:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009e9:	8d 48 01             	lea    0x1(%eax),%ecx
f01009ec:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009ef:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009f3:	0f b6 06             	movzbl (%esi),%eax
f01009f6:	84 c0                	test   %al,%al
f01009f8:	74 1e                	je     f0100a18 <monitor+0x99>
f01009fa:	83 ec 08             	sub    $0x8,%esp
f01009fd:	0f be c0             	movsbl %al,%eax
f0100a00:	50                   	push   %eax
f0100a01:	57                   	push   %edi
f0100a02:	e8 a4 0e 00 00       	call   f01018ab <strchr>
f0100a07:	83 c4 10             	add    $0x10,%esp
f0100a0a:	85 c0                	test   %eax,%eax
f0100a0c:	75 0a                	jne    f0100a18 <monitor+0x99>
			buf++;
f0100a0e:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a11:	0f b6 06             	movzbl (%esi),%eax
f0100a14:	84 c0                	test   %al,%al
f0100a16:	75 e2                	jne    f01009fa <monitor+0x7b>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a18:	0f b6 06             	movzbl (%esi),%eax
f0100a1b:	84 c0                	test   %al,%al
f0100a1d:	75 9c                	jne    f01009bb <monitor+0x3c>
	argv[argc] = 0;
f0100a1f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a22:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a29:	00 
	if (argc == 0)
f0100a2a:	85 c0                	test   %eax,%eax
f0100a2c:	74 5b                	je     f0100a89 <monitor+0x10a>
f0100a2e:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < NCOMMANDS; i++) {
f0100a34:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%ebp)
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a3b:	83 ec 08             	sub    $0x8,%esp
f0100a3e:	ff 36                	pushl  (%esi)
f0100a40:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a43:	e8 e8 0d 00 00       	call   f0101830 <strcmp>
f0100a48:	83 c4 10             	add    $0x10,%esp
f0100a4b:	85 c0                	test   %eax,%eax
f0100a4d:	74 6a                	je     f0100ab9 <monitor+0x13a>
	for (i = 0; i < NCOMMANDS; i++) {
f0100a4f:	83 45 a0 01          	addl   $0x1,-0x60(%ebp)
f0100a53:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0100a56:	83 c6 0c             	add    $0xc,%esi
f0100a59:	83 f8 03             	cmp    $0x3,%eax
f0100a5c:	75 dd                	jne    f0100a3b <monitor+0xbc>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a5e:	83 ec 08             	sub    $0x8,%esp
f0100a61:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a64:	8d 83 f5 0d ff ff    	lea    -0xf20b(%ebx),%eax
f0100a6a:	50                   	push   %eax
f0100a6b:	e8 cb 00 00 00       	call   f0100b3b <cprintf>
f0100a70:	83 c4 10             	add    $0x10,%esp
f0100a73:	eb 14                	jmp    f0100a89 <monitor+0x10a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a75:	83 ec 08             	sub    $0x8,%esp
f0100a78:	6a 10                	push   $0x10
f0100a7a:	8d 83 d8 0d ff ff    	lea    -0xf228(%ebx),%eax
f0100a80:	50                   	push   %eax
f0100a81:	e8 b5 00 00 00       	call   f0100b3b <cprintf>
f0100a86:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100a89:	8d 83 cf 0d ff ff    	lea    -0xf231(%ebx),%eax
f0100a8f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100a92:	83 ec 0c             	sub    $0xc,%esp
f0100a95:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a98:	e8 88 0b 00 00       	call   f0101625 <readline>
f0100a9d:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100a9f:	83 c4 10             	add    $0x10,%esp
f0100aa2:	85 c0                	test   %eax,%eax
f0100aa4:	74 ec                	je     f0100a92 <monitor+0x113>
	argv[argc] = 0;
f0100aa6:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100aad:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100ab4:	e9 5f ff ff ff       	jmp    f0100a18 <monitor+0x99>
			return commands[i].func(argc, argv, tf);
f0100ab9:	83 ec 04             	sub    $0x4,%esp
f0100abc:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0100abf:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100ac2:	ff 75 08             	pushl  0x8(%ebp)
f0100ac5:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ac8:	52                   	push   %edx
f0100ac9:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100acc:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100ad3:	83 c4 10             	add    $0x10,%esp
f0100ad6:	85 c0                	test   %eax,%eax
f0100ad8:	79 af                	jns    f0100a89 <monitor+0x10a>
				break;
	}
}
f0100ada:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100add:	5b                   	pop    %ebx
f0100ade:	5e                   	pop    %esi
f0100adf:	5f                   	pop    %edi
f0100ae0:	5d                   	pop    %ebp
f0100ae1:	c3                   	ret    

f0100ae2 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100ae2:	55                   	push   %ebp
f0100ae3:	89 e5                	mov    %esp,%ebp
f0100ae5:	53                   	push   %ebx
f0100ae6:	83 ec 10             	sub    $0x10,%esp
f0100ae9:	e8 ce f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100aee:	81 c3 1a 08 01 00    	add    $0x1081a,%ebx
	cputchar(ch);
f0100af4:	ff 75 08             	pushl  0x8(%ebp)
f0100af7:	e8 38 fc ff ff       	call   f0100734 <cputchar>
	*cnt++;
}
f0100afc:	83 c4 10             	add    $0x10,%esp
f0100aff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b02:	c9                   	leave  
f0100b03:	c3                   	ret    

f0100b04 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100b04:	55                   	push   %ebp
f0100b05:	89 e5                	mov    %esp,%ebp
f0100b07:	53                   	push   %ebx
f0100b08:	83 ec 14             	sub    $0x14,%esp
f0100b0b:	e8 ac f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100b10:	81 c3 f8 07 01 00    	add    $0x107f8,%ebx
	int cnt = 0;
f0100b16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b1d:	ff 75 0c             	pushl  0xc(%ebp)
f0100b20:	ff 75 08             	pushl  0x8(%ebp)
f0100b23:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b26:	50                   	push   %eax
f0100b27:	8d 83 da f7 fe ff    	lea    -0x10826(%ebx),%eax
f0100b2d:	50                   	push   %eax
f0100b2e:	e8 1e 05 00 00       	call   f0101051 <vprintfmt>
	return cnt;
}
f0100b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b39:	c9                   	leave  
f0100b3a:	c3                   	ret    

f0100b3b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b3b:	55                   	push   %ebp
f0100b3c:	89 e5                	mov    %esp,%ebp
f0100b3e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b41:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b44:	50                   	push   %eax
f0100b45:	ff 75 08             	pushl  0x8(%ebp)
f0100b48:	e8 b7 ff ff ff       	call   f0100b04 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b4d:	c9                   	leave  
f0100b4e:	c3                   	ret    

f0100b4f <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b4f:	55                   	push   %ebp
f0100b50:	89 e5                	mov    %esp,%ebp
f0100b52:	57                   	push   %edi
f0100b53:	56                   	push   %esi
f0100b54:	53                   	push   %ebx
f0100b55:	83 ec 14             	sub    $0x14,%esp
f0100b58:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b5b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b5e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b61:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b64:	8b 32                	mov    (%edx),%esi
f0100b66:	8b 01                	mov    (%ecx),%eax
f0100b68:	89 45 f0             	mov    %eax,-0x10(%ebp)

	while (l <= r) {
f0100b6b:	39 c6                	cmp    %eax,%esi
f0100b6d:	7f 79                	jg     f0100be8 <stab_binsearch+0x99>
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b6f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0100b76:	e9 84 00 00 00       	jmp    f0100bff <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100b7b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b7e:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100b80:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100b83:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b8a:	eb 6e                	jmp    f0100bfa <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100b8c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b8f:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100b91:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100b95:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100b97:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b9e:	eb 5a                	jmp    f0100bfa <stab_binsearch+0xab>
		}
	}

	if (!any_matches)
f0100ba0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100ba4:	74 42                	je     f0100be8 <stab_binsearch+0x99>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ba6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ba9:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100bab:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bae:	8b 16                	mov    (%esi),%edx
		for (l = *region_right;
f0100bb0:	39 d0                	cmp    %edx,%eax
f0100bb2:	7e 27                	jle    f0100bdb <stab_binsearch+0x8c>
		     l > *region_left && stabs[l].n_type != type;
f0100bb4:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100bb7:	c1 e1 02             	shl    $0x2,%ecx
f0100bba:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100bbd:	0f b6 5c 0e 04       	movzbl 0x4(%esi,%ecx,1),%ebx
f0100bc2:	39 df                	cmp    %ebx,%edi
f0100bc4:	74 15                	je     f0100bdb <stab_binsearch+0x8c>
f0100bc6:	8d 4c 0e f8          	lea    -0x8(%esi,%ecx,1),%ecx
		     l--)
f0100bca:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100bcd:	39 d0                	cmp    %edx,%eax
f0100bcf:	74 0a                	je     f0100bdb <stab_binsearch+0x8c>
		     l > *region_left && stabs[l].n_type != type;
f0100bd1:	0f b6 19             	movzbl (%ecx),%ebx
f0100bd4:	83 e9 0c             	sub    $0xc,%ecx
f0100bd7:	39 fb                	cmp    %edi,%ebx
f0100bd9:	75 ef                	jne    f0100bca <stab_binsearch+0x7b>
			/* do nothing */;
		*region_left = l;
f0100bdb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bde:	89 07                	mov    %eax,(%edi)
	}
}
f0100be0:	83 c4 14             	add    $0x14,%esp
f0100be3:	5b                   	pop    %ebx
f0100be4:	5e                   	pop    %esi
f0100be5:	5f                   	pop    %edi
f0100be6:	5d                   	pop    %ebp
f0100be7:	c3                   	ret    
		*region_right = *region_left - 1;
f0100be8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100beb:	8b 00                	mov    (%eax),%eax
f0100bed:	83 e8 01             	sub    $0x1,%eax
f0100bf0:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100bf3:	89 07                	mov    %eax,(%edi)
f0100bf5:	eb e9                	jmp    f0100be0 <stab_binsearch+0x91>
			l = true_m + 1;
f0100bf7:	8d 73 01             	lea    0x1(%ebx),%esi
	while (l <= r) {
f0100bfa:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100bfd:	7f a1                	jg     f0100ba0 <stab_binsearch+0x51>
		int true_m = (l + r) / 2, m = true_m;
f0100bff:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100c02:	01 f0                	add    %esi,%eax
f0100c04:	89 c3                	mov    %eax,%ebx
f0100c06:	c1 eb 1f             	shr    $0x1f,%ebx
f0100c09:	01 c3                	add    %eax,%ebx
f0100c0b:	d1 fb                	sar    %ebx
		while (m >= l && stabs[m].n_type != type)
f0100c0d:	39 f3                	cmp    %esi,%ebx
f0100c0f:	7c e6                	jl     f0100bf7 <stab_binsearch+0xa8>
f0100c11:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100c14:	c1 e0 02             	shl    $0x2,%eax
f0100c17:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100c1a:	0f b6 54 01 04       	movzbl 0x4(%ecx,%eax,1),%edx
f0100c1f:	39 d7                	cmp    %edx,%edi
f0100c21:	74 47                	je     f0100c6a <stab_binsearch+0x11b>
f0100c23:	8d 54 01 f8          	lea    -0x8(%ecx,%eax,1),%edx
		int true_m = (l + r) / 2, m = true_m;
f0100c27:	89 d8                	mov    %ebx,%eax
			m--;
f0100c29:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100c2c:	39 f0                	cmp    %esi,%eax
f0100c2e:	7c c7                	jl     f0100bf7 <stab_binsearch+0xa8>
f0100c30:	0f b6 0a             	movzbl (%edx),%ecx
f0100c33:	83 ea 0c             	sub    $0xc,%edx
f0100c36:	39 f9                	cmp    %edi,%ecx
f0100c38:	75 ef                	jne    f0100c29 <stab_binsearch+0xda>
		if (stabs[m].n_value < addr) {
f0100c3a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c3d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100c40:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100c44:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100c47:	0f 82 2e ff ff ff    	jb     f0100b7b <stab_binsearch+0x2c>
		} else if (stabs[m].n_value > addr) {
f0100c4d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100c50:	0f 86 36 ff ff ff    	jbe    f0100b8c <stab_binsearch+0x3d>
			*region_right = m - 1;
f0100c56:	83 e8 01             	sub    $0x1,%eax
f0100c59:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100c5c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100c5f:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100c61:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100c68:	eb 90                	jmp    f0100bfa <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f0100c6a:	89 d8                	mov    %ebx,%eax
f0100c6c:	eb cc                	jmp    f0100c3a <stab_binsearch+0xeb>

f0100c6e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c6e:	55                   	push   %ebp
f0100c6f:	89 e5                	mov    %esp,%ebp
f0100c71:	57                   	push   %edi
f0100c72:	56                   	push   %esi
f0100c73:	53                   	push   %ebx
f0100c74:	83 ec 3c             	sub    $0x3c,%esp
f0100c77:	e8 40 f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100c7c:	81 c3 8c 06 01 00    	add    $0x1068c,%ebx
f0100c82:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100c85:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c88:	8d 83 98 0f ff ff    	lea    -0xf068(%ebx),%eax
f0100c8e:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100c90:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100c97:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100c9a:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100ca1:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100ca4:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100cab:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100cb1:	0f 86 67 01 00 00    	jbe    f0100e1e <debuginfo_eip+0x1b0>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100cb7:	c7 c0 b1 63 10 f0    	mov    $0xf01063b1,%eax
f0100cbd:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100cc3:	0f 86 1b 02 00 00    	jbe    f0100ee4 <debuginfo_eip+0x276>
f0100cc9:	c7 c0 21 7d 10 f0    	mov    $0xf0107d21,%eax
f0100ccf:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100cd3:	0f 85 12 02 00 00    	jne    f0100eeb <debuginfo_eip+0x27d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100cd9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100ce0:	c7 c0 bc 24 10 f0    	mov    $0xf01024bc,%eax
f0100ce6:	c7 c2 b0 63 10 f0    	mov    $0xf01063b0,%edx
f0100cec:	29 c2                	sub    %eax,%edx
f0100cee:	c1 fa 02             	sar    $0x2,%edx
f0100cf1:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100cf7:	83 ea 01             	sub    $0x1,%edx
f0100cfa:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100cfd:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100d00:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100d03:	83 ec 08             	sub    $0x8,%esp
f0100d06:	57                   	push   %edi
f0100d07:	6a 64                	push   $0x64
f0100d09:	e8 41 fe ff ff       	call   f0100b4f <stab_binsearch>
	if (lfile == 0)
f0100d0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d11:	83 c4 10             	add    $0x10,%esp
f0100d14:	85 c0                	test   %eax,%eax
f0100d16:	0f 84 d6 01 00 00    	je     f0100ef2 <debuginfo_eip+0x284>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100d1c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100d1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d22:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100d25:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100d28:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d2b:	83 ec 08             	sub    $0x8,%esp
f0100d2e:	57                   	push   %edi
f0100d2f:	6a 24                	push   $0x24
f0100d31:	c7 c0 bc 24 10 f0    	mov    $0xf01024bc,%eax
f0100d37:	e8 13 fe ff ff       	call   f0100b4f <stab_binsearch>

	if (lfun <= rfun) {
f0100d3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d3f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100d42:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100d45:	83 c4 10             	add    $0x10,%esp
f0100d48:	39 c8                	cmp    %ecx,%eax
f0100d4a:	0f 8f e6 00 00 00    	jg     f0100e36 <debuginfo_eip+0x1c8>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d50:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d53:	c7 c1 bc 24 10 f0    	mov    $0xf01024bc,%ecx
f0100d59:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100d5c:	8b 11                	mov    (%ecx),%edx
f0100d5e:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100d61:	c7 c2 21 7d 10 f0    	mov    $0xf0107d21,%edx
f0100d67:	81 ea b1 63 10 f0    	sub    $0xf01063b1,%edx
f0100d6d:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0100d70:	73 0c                	jae    f0100d7e <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d72:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100d75:	81 c2 b1 63 10 f0    	add    $0xf01063b1,%edx
f0100d7b:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d7e:	8b 51 08             	mov    0x8(%ecx),%edx
f0100d81:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100d84:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100d86:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100d89:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100d8c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d8f:	83 ec 08             	sub    $0x8,%esp
f0100d92:	6a 3a                	push   $0x3a
f0100d94:	ff 76 08             	pushl  0x8(%esi)
f0100d97:	e8 45 0b 00 00       	call   f01018e1 <strfind>
f0100d9c:	2b 46 08             	sub    0x8(%esi),%eax
f0100d9f:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100da2:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100da5:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100da8:	83 c4 08             	add    $0x8,%esp
f0100dab:	57                   	push   %edi
f0100dac:	6a 44                	push   $0x44
f0100dae:	c7 c0 bc 24 10 f0    	mov    $0xf01024bc,%eax
f0100db4:	e8 96 fd ff ff       	call   f0100b4f <stab_binsearch>
	if (lline <= rline)
f0100db9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100dbc:	83 c4 10             	add    $0x10,%esp
f0100dbf:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100dc2:	0f 8f 31 01 00 00    	jg     f0100ef9 <debuginfo_eip+0x28b>
		info->eip_line = stabs[lline].n_desc;
f0100dc8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100dcb:	c1 e2 02             	shl    $0x2,%edx
f0100dce:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0100dd1:	89 d1                	mov    %edx,%ecx
f0100dd3:	81 c1 bc 24 10 f0    	add    $0xf01024bc,%ecx
f0100dd9:	0f b7 51 06          	movzwl 0x6(%ecx),%edx
f0100ddd:	89 56 04             	mov    %edx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100de0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100de3:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0100de6:	39 d0                	cmp    %edx,%eax
f0100de8:	0f 8c 9f 00 00 00    	jl     f0100e8d <debuginfo_eip+0x21f>
	       && stabs[lline].n_type != N_SOL
f0100dee:	0f b6 51 04          	movzbl 0x4(%ecx),%edx
f0100df2:	88 55 c0             	mov    %dl,-0x40(%ebp)
f0100df5:	80 fa 84             	cmp    $0x84,%dl
f0100df8:	0f 84 23 01 00 00    	je     f0100f21 <debuginfo_eip+0x2b3>
f0100dfe:	c7 c7 bc 24 10 f0    	mov    $0xf01024bc,%edi
f0100e04:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100e07:	8d 7c 3a f8          	lea    -0x8(%edx,%edi,1),%edi
f0100e0b:	83 c1 08             	add    $0x8,%ecx
f0100e0e:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0100e12:	0f b6 55 c0          	movzbl -0x40(%ebp),%edx
f0100e16:	89 75 0c             	mov    %esi,0xc(%ebp)
f0100e19:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0100e1c:	eb 49                	jmp    f0100e67 <debuginfo_eip+0x1f9>
  	        panic("User address");
f0100e1e:	83 ec 04             	sub    $0x4,%esp
f0100e21:	8d 83 a2 0f ff ff    	lea    -0xf05e(%ebx),%eax
f0100e27:	50                   	push   %eax
f0100e28:	6a 7f                	push   $0x7f
f0100e2a:	8d 83 af 0f ff ff    	lea    -0xf051(%ebx),%eax
f0100e30:	50                   	push   %eax
f0100e31:	e8 d0 f2 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100e36:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100e39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e3c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100e3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e42:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e45:	e9 45 ff ff ff       	jmp    f0100d8f <debuginfo_eip+0x121>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100e4a:	83 e8 01             	sub    $0x1,%eax
	while (lline >= lfile
f0100e4d:	39 f0                	cmp    %esi,%eax
f0100e4f:	7c 39                	jl     f0100e8a <debuginfo_eip+0x21c>
	       && stabs[lline].n_type != N_SOL
f0100e51:	0f b6 17             	movzbl (%edi),%edx
f0100e54:	83 ef 0c             	sub    $0xc,%edi
f0100e57:	83 e9 0c             	sub    $0xc,%ecx
f0100e5a:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0100e5e:	80 fa 84             	cmp    $0x84,%dl
f0100e61:	0f 84 b4 00 00 00    	je     f0100f1b <debuginfo_eip+0x2ad>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e67:	80 fa 64             	cmp    $0x64,%dl
f0100e6a:	75 de                	jne    f0100e4a <debuginfo_eip+0x1dc>
f0100e6c:	83 39 00             	cmpl   $0x0,(%ecx)
f0100e6f:	74 d9                	je     f0100e4a <debuginfo_eip+0x1dc>
f0100e71:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100e74:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100e78:	75 0b                	jne    f0100e85 <debuginfo_eip+0x217>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e7a:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f0100e7d:	0f 8e 9e 00 00 00    	jle    f0100f21 <debuginfo_eip+0x2b3>
f0100e83:	eb 08                	jmp    f0100e8d <debuginfo_eip+0x21f>
f0100e85:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100e88:	eb f0                	jmp    f0100e7a <debuginfo_eip+0x20c>
f0100e8a:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100e8d:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100e90:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e93:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100e98:	39 cf                	cmp    %ecx,%edi
f0100e9a:	7d 77                	jge    f0100f13 <debuginfo_eip+0x2a5>
		for (lline = lfun + 1;
f0100e9c:	8d 47 01             	lea    0x1(%edi),%eax
f0100e9f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100ea2:	39 c1                	cmp    %eax,%ecx
f0100ea4:	7e 5a                	jle    f0100f00 <debuginfo_eip+0x292>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ea6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100ea9:	c1 e0 02             	shl    $0x2,%eax
f0100eac:	c7 c2 bc 24 10 f0    	mov    $0xf01024bc,%edx
f0100eb2:	80 7c 10 04 a0       	cmpb   $0xa0,0x4(%eax,%edx,1)
f0100eb7:	75 4e                	jne    f0100f07 <debuginfo_eip+0x299>
f0100eb9:	8d 54 10 10          	lea    0x10(%eax,%edx,1),%edx
f0100ebd:	83 e9 02             	sub    $0x2,%ecx
f0100ec0:	29 f9                	sub    %edi,%ecx
f0100ec2:	b8 00 00 00 00       	mov    $0x0,%eax
			info->eip_fn_narg++;
f0100ec7:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100ecb:	39 c8                	cmp    %ecx,%eax
f0100ecd:	74 3f                	je     f0100f0e <debuginfo_eip+0x2a0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ecf:	0f b6 1a             	movzbl (%edx),%ebx
f0100ed2:	83 c0 01             	add    $0x1,%eax
f0100ed5:	83 c2 0c             	add    $0xc,%edx
f0100ed8:	80 fb a0             	cmp    $0xa0,%bl
f0100edb:	74 ea                	je     f0100ec7 <debuginfo_eip+0x259>
	return 0;
f0100edd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ee2:	eb 2f                	jmp    f0100f13 <debuginfo_eip+0x2a5>
		return -1;
f0100ee4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ee9:	eb 28                	jmp    f0100f13 <debuginfo_eip+0x2a5>
f0100eeb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ef0:	eb 21                	jmp    f0100f13 <debuginfo_eip+0x2a5>
		return -1;
f0100ef2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ef7:	eb 1a                	jmp    f0100f13 <debuginfo_eip+0x2a5>
		return -1;
f0100ef9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100efe:	eb 13                	jmp    f0100f13 <debuginfo_eip+0x2a5>
	return 0;
f0100f00:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f05:	eb 0c                	jmp    f0100f13 <debuginfo_eip+0x2a5>
f0100f07:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f0c:	eb 05                	jmp    f0100f13 <debuginfo_eip+0x2a5>
f0100f0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f13:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f16:	5b                   	pop    %ebx
f0100f17:	5e                   	pop    %esi
f0100f18:	5f                   	pop    %edi
f0100f19:	5d                   	pop    %ebp
f0100f1a:	c3                   	ret    
f0100f1b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100f1e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100f21:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100f24:	c7 c0 bc 24 10 f0    	mov    $0xf01024bc,%eax
f0100f2a:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100f2d:	c7 c0 21 7d 10 f0    	mov    $0xf0107d21,%eax
f0100f33:	81 e8 b1 63 10 f0    	sub    $0xf01063b1,%eax
f0100f39:	39 c2                	cmp    %eax,%edx
f0100f3b:	0f 83 4c ff ff ff    	jae    f0100e8d <debuginfo_eip+0x21f>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100f41:	81 c2 b1 63 10 f0    	add    $0xf01063b1,%edx
f0100f47:	89 16                	mov    %edx,(%esi)
f0100f49:	e9 3f ff ff ff       	jmp    f0100e8d <debuginfo_eip+0x21f>

f0100f4e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100f4e:	55                   	push   %ebp
f0100f4f:	89 e5                	mov    %esp,%ebp
f0100f51:	57                   	push   %edi
f0100f52:	56                   	push   %esi
f0100f53:	53                   	push   %ebx
f0100f54:	83 ec 2c             	sub    $0x2c,%esp
f0100f57:	e8 c5 06 00 00       	call   f0101621 <__x86.get_pc_thunk.cx>
f0100f5c:	81 c1 ac 03 01 00    	add    $0x103ac,%ecx
f0100f62:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100f65:	89 c7                	mov    %eax,%edi
f0100f67:	89 d6                	mov    %edx,%esi
f0100f69:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f6c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100f6f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f72:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100f75:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100f78:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f7d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0100f80:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0100f83:	39 d3                	cmp    %edx,%ebx
f0100f85:	72 56                	jb     f0100fdd <printnum+0x8f>
f0100f87:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100f8a:	76 51                	jbe    f0100fdd <printnum+0x8f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100f8c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f8f:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100f92:	85 db                	test   %ebx,%ebx
f0100f94:	7e 11                	jle    f0100fa7 <printnum+0x59>
			putch(padc, putdat);
f0100f96:	83 ec 08             	sub    $0x8,%esp
f0100f99:	56                   	push   %esi
f0100f9a:	ff 75 18             	pushl  0x18(%ebp)
f0100f9d:	ff d7                	call   *%edi
		while (--width > 0)
f0100f9f:	83 c4 10             	add    $0x10,%esp
f0100fa2:	83 eb 01             	sub    $0x1,%ebx
f0100fa5:	75 ef                	jne    f0100f96 <printnum+0x48>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100fa7:	83 ec 08             	sub    $0x8,%esp
f0100faa:	56                   	push   %esi
f0100fab:	83 ec 04             	sub    $0x4,%esp
f0100fae:	ff 75 dc             	pushl  -0x24(%ebp)
f0100fb1:	ff 75 d8             	pushl  -0x28(%ebp)
f0100fb4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100fb7:	ff 75 d0             	pushl  -0x30(%ebp)
f0100fba:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100fbd:	89 f3                	mov    %esi,%ebx
f0100fbf:	e8 8c 0c 00 00       	call   f0101c50 <__umoddi3>
f0100fc4:	83 c4 14             	add    $0x14,%esp
f0100fc7:	0f be 84 06 bd 0f ff 	movsbl -0xf043(%esi,%eax,1),%eax
f0100fce:	ff 
f0100fcf:	50                   	push   %eax
f0100fd0:	ff d7                	call   *%edi
}
f0100fd2:	83 c4 10             	add    $0x10,%esp
f0100fd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fd8:	5b                   	pop    %ebx
f0100fd9:	5e                   	pop    %esi
f0100fda:	5f                   	pop    %edi
f0100fdb:	5d                   	pop    %ebp
f0100fdc:	c3                   	ret    
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100fdd:	83 ec 0c             	sub    $0xc,%esp
f0100fe0:	ff 75 18             	pushl  0x18(%ebp)
f0100fe3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fe6:	83 e8 01             	sub    $0x1,%eax
f0100fe9:	50                   	push   %eax
f0100fea:	ff 75 10             	pushl  0x10(%ebp)
f0100fed:	83 ec 08             	sub    $0x8,%esp
f0100ff0:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ff3:	ff 75 d8             	pushl  -0x28(%ebp)
f0100ff6:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100ff9:	ff 75 d0             	pushl  -0x30(%ebp)
f0100ffc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100fff:	e8 2c 0b 00 00       	call   f0101b30 <__udivdi3>
f0101004:	83 c4 18             	add    $0x18,%esp
f0101007:	52                   	push   %edx
f0101008:	50                   	push   %eax
f0101009:	89 f2                	mov    %esi,%edx
f010100b:	89 f8                	mov    %edi,%eax
f010100d:	e8 3c ff ff ff       	call   f0100f4e <printnum>
f0101012:	83 c4 20             	add    $0x20,%esp
f0101015:	eb 90                	jmp    f0100fa7 <printnum+0x59>

f0101017 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101017:	55                   	push   %ebp
f0101018:	89 e5                	mov    %esp,%ebp
f010101a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010101d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101021:	8b 10                	mov    (%eax),%edx
f0101023:	3b 50 04             	cmp    0x4(%eax),%edx
f0101026:	73 0a                	jae    f0101032 <sprintputch+0x1b>
		*b->buf++ = ch;
f0101028:	8d 4a 01             	lea    0x1(%edx),%ecx
f010102b:	89 08                	mov    %ecx,(%eax)
f010102d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101030:	88 02                	mov    %al,(%edx)
}
f0101032:	5d                   	pop    %ebp
f0101033:	c3                   	ret    

f0101034 <printfmt>:
{
f0101034:	55                   	push   %ebp
f0101035:	89 e5                	mov    %esp,%ebp
f0101037:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f010103a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010103d:	50                   	push   %eax
f010103e:	ff 75 10             	pushl  0x10(%ebp)
f0101041:	ff 75 0c             	pushl  0xc(%ebp)
f0101044:	ff 75 08             	pushl  0x8(%ebp)
f0101047:	e8 05 00 00 00       	call   f0101051 <vprintfmt>
}
f010104c:	83 c4 10             	add    $0x10,%esp
f010104f:	c9                   	leave  
f0101050:	c3                   	ret    

f0101051 <vprintfmt>:
{
f0101051:	55                   	push   %ebp
f0101052:	89 e5                	mov    %esp,%ebp
f0101054:	57                   	push   %edi
f0101055:	56                   	push   %esi
f0101056:	53                   	push   %ebx
f0101057:	83 ec 2c             	sub    $0x2c,%esp
f010105a:	e8 00 f7 ff ff       	call   f010075f <__x86.get_pc_thunk.ax>
f010105f:	05 a9 02 01 00       	add    $0x102a9,%eax
f0101064:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101067:	8b 7d 08             	mov    0x8(%ebp),%edi
f010106a:	8b 75 0c             	mov    0xc(%ebp),%esi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010106d:	8b 45 10             	mov    0x10(%ebp),%eax
f0101070:	8d 58 01             	lea    0x1(%eax),%ebx
f0101073:	0f b6 00             	movzbl (%eax),%eax
f0101076:	83 f8 25             	cmp    $0x25,%eax
f0101079:	74 2b                	je     f01010a6 <vprintfmt+0x55>
			if (ch == '\0')
f010107b:	85 c0                	test   %eax,%eax
f010107d:	74 1a                	je     f0101099 <vprintfmt+0x48>
			putch(ch, putdat);
f010107f:	83 ec 08             	sub    $0x8,%esp
f0101082:	56                   	push   %esi
f0101083:	50                   	push   %eax
f0101084:	ff d7                	call   *%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101086:	83 c3 01             	add    $0x1,%ebx
f0101089:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f010108d:	83 c4 10             	add    $0x10,%esp
f0101090:	83 f8 25             	cmp    $0x25,%eax
f0101093:	74 11                	je     f01010a6 <vprintfmt+0x55>
			if (ch == '\0')
f0101095:	85 c0                	test   %eax,%eax
f0101097:	75 e6                	jne    f010107f <vprintfmt+0x2e>
}
f0101099:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010109c:	5b                   	pop    %ebx
f010109d:	5e                   	pop    %esi
f010109e:	5f                   	pop    %edi
f010109f:	5d                   	pop    %ebp
f01010a0:	c3                   	ret    
			for (fmt--; fmt[-1] != '%'; fmt--)
f01010a1:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01010a4:	eb c7                	jmp    f010106d <vprintfmt+0x1c>
		padc = ' ';
f01010a6:	c6 45 d7 20          	movb   $0x20,-0x29(%ebp)
		altflag = 0;
f01010aa:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f01010b1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f01010b8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01010bf:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010c4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01010c7:	89 75 0c             	mov    %esi,0xc(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010ca:	8d 43 01             	lea    0x1(%ebx),%eax
f01010cd:	89 45 10             	mov    %eax,0x10(%ebp)
f01010d0:	0f b6 13             	movzbl (%ebx),%edx
f01010d3:	8d 42 dd             	lea    -0x23(%edx),%eax
f01010d6:	3c 55                	cmp    $0x55,%al
f01010d8:	0f 87 5d 04 00 00    	ja     f010153b <.L24>
f01010de:	0f b6 c0             	movzbl %al,%eax
f01010e1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01010e4:	89 ce                	mov    %ecx,%esi
f01010e6:	03 b4 81 4c 10 ff ff 	add    -0xefb4(%ecx,%eax,4),%esi
f01010ed:	ff e6                	jmp    *%esi

f01010ef <.L72>:
f01010ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
			padc = '-';
f01010f2:	c6 45 d7 2d          	movb   $0x2d,-0x29(%ebp)
f01010f6:	eb d2                	jmp    f01010ca <vprintfmt+0x79>

f01010f8 <.L30>:
		switch (ch = *(unsigned char *) fmt++) {
f01010f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
			padc = '0';
f01010fb:	c6 45 d7 30          	movb   $0x30,-0x29(%ebp)
f01010ff:	eb c9                	jmp    f01010ca <vprintfmt+0x79>

f0101101 <.L31>:
		switch (ch = *(unsigned char *) fmt++) {
f0101101:	0f b6 d2             	movzbl %dl,%edx
				precision = precision * 10 + ch - '0';
f0101104:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0101107:	89 4d d0             	mov    %ecx,-0x30(%ebp)
				ch = *fmt;
f010110a:	0f be 43 01          	movsbl 0x1(%ebx),%eax
				if (ch < '0' || ch > '9')
f010110e:	8d 50 d0             	lea    -0x30(%eax),%edx
f0101111:	83 fa 09             	cmp    $0x9,%edx
f0101114:	77 7e                	ja     f0101194 <.L25+0xf>
f0101116:	89 ca                	mov    %ecx,%edx
f0101118:	8b 75 0c             	mov    0xc(%ebp),%esi
f010111b:	8b 4d 10             	mov    0x10(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
f010111e:	83 c1 01             	add    $0x1,%ecx
				precision = precision * 10 + ch - '0';
f0101121:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0101124:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0101128:	0f be 01             	movsbl (%ecx),%eax
				if (ch < '0' || ch > '9')
f010112b:	8d 58 d0             	lea    -0x30(%eax),%ebx
f010112e:	83 fb 09             	cmp    $0x9,%ebx
f0101131:	76 eb                	jbe    f010111e <.L31+0x1d>
f0101133:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0101136:	89 75 0c             	mov    %esi,0xc(%ebp)
			for (precision = 0; ; ++fmt) {
f0101139:	89 cb                	mov    %ecx,%ebx
f010113b:	eb 14                	jmp    f0101151 <.L28+0x14>

f010113d <.L28>:
			precision = va_arg(ap, int);
f010113d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101140:	8b 00                	mov    (%eax),%eax
f0101142:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101145:	8b 45 14             	mov    0x14(%ebp),%eax
f0101148:	8d 40 04             	lea    0x4(%eax),%eax
f010114b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010114e:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (width < 0)
f0101151:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101155:	0f 89 6f ff ff ff    	jns    f01010ca <vprintfmt+0x79>
				width = precision, precision = -1;
f010115b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010115e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101161:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101168:	e9 5d ff ff ff       	jmp    f01010ca <vprintfmt+0x79>

f010116d <.L29>:
f010116d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101170:	85 c0                	test   %eax,%eax
f0101172:	ba 00 00 00 00       	mov    $0x0,%edx
f0101177:	0f 49 d0             	cmovns %eax,%edx
f010117a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010117d:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0101180:	e9 45 ff ff ff       	jmp    f01010ca <vprintfmt+0x79>

f0101185 <.L25>:
f0101185:	8b 5d 10             	mov    0x10(%ebp),%ebx
			altflag = 1;
f0101188:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010118f:	e9 36 ff ff ff       	jmp    f01010ca <vprintfmt+0x79>
		switch (ch = *(unsigned char *) fmt++) {
f0101194:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0101197:	eb b8                	jmp    f0101151 <.L28+0x14>

f0101199 <.L35>:
			lflag++;
f0101199:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010119d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			goto reswitch;
f01011a0:	e9 25 ff ff ff       	jmp    f01010ca <vprintfmt+0x79>

f01011a5 <.L32>:
f01011a5:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f01011a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01011ab:	8d 58 04             	lea    0x4(%eax),%ebx
f01011ae:	83 ec 08             	sub    $0x8,%esp
f01011b1:	56                   	push   %esi
f01011b2:	ff 30                	pushl  (%eax)
f01011b4:	ff d7                	call   *%edi
			break;
f01011b6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01011b9:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f01011bc:	e9 ac fe ff ff       	jmp    f010106d <vprintfmt+0x1c>

f01011c1 <.L34>:
f01011c1:	8b 75 0c             	mov    0xc(%ebp),%esi
			err = va_arg(ap, int);
f01011c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01011c7:	8d 58 04             	lea    0x4(%eax),%ebx
f01011ca:	8b 00                	mov    (%eax),%eax
f01011cc:	99                   	cltd   
f01011cd:	31 d0                	xor    %edx,%eax
f01011cf:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01011d1:	83 f8 06             	cmp    $0x6,%eax
f01011d4:	7f 2b                	jg     f0101201 <.L34+0x40>
f01011d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01011d9:	8b 94 82 3c 1d 00 00 	mov    0x1d3c(%edx,%eax,4),%edx
f01011e0:	85 d2                	test   %edx,%edx
f01011e2:	74 1d                	je     f0101201 <.L34+0x40>
				printfmt(putch, putdat, "%s", p);
f01011e4:	52                   	push   %edx
f01011e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011e8:	8d 80 de 0f ff ff    	lea    -0xf022(%eax),%eax
f01011ee:	50                   	push   %eax
f01011ef:	56                   	push   %esi
f01011f0:	57                   	push   %edi
f01011f1:	e8 3e fe ff ff       	call   f0101034 <printfmt>
f01011f6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01011f9:	89 5d 14             	mov    %ebx,0x14(%ebp)
f01011fc:	e9 6c fe ff ff       	jmp    f010106d <vprintfmt+0x1c>
				printfmt(putch, putdat, "error %d", err);
f0101201:	50                   	push   %eax
f0101202:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101205:	8d 80 d5 0f ff ff    	lea    -0xf02b(%eax),%eax
f010120b:	50                   	push   %eax
f010120c:	56                   	push   %esi
f010120d:	57                   	push   %edi
f010120e:	e8 21 fe ff ff       	call   f0101034 <printfmt>
f0101213:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101216:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0101219:	e9 4f fe ff ff       	jmp    f010106d <vprintfmt+0x1c>

f010121e <.L38>:
f010121e:	8b 75 0c             	mov    0xc(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f0101221:	8b 45 14             	mov    0x14(%ebp),%eax
f0101224:	83 c0 04             	add    $0x4,%eax
f0101227:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010122a:	8b 45 14             	mov    0x14(%ebp),%eax
f010122d:	8b 00                	mov    (%eax),%eax
f010122f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101232:	85 c0                	test   %eax,%eax
f0101234:	0f 84 3a 03 00 00    	je     f0101574 <.L24+0x39>
			if (width > 0 && padc != '-')
f010123a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010123e:	7e 06                	jle    f0101246 <.L38+0x28>
f0101240:	80 7d d7 2d          	cmpb   $0x2d,-0x29(%ebp)
f0101244:	75 31                	jne    f0101277 <.L38+0x59>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101246:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101249:	8d 58 01             	lea    0x1(%eax),%ebx
f010124c:	0f b6 10             	movzbl (%eax),%edx
f010124f:	0f be c2             	movsbl %dl,%eax
f0101252:	85 c0                	test   %eax,%eax
f0101254:	0f 84 cd 00 00 00    	je     f0101327 <.L38+0x109>
f010125a:	89 7d 08             	mov    %edi,0x8(%ebp)
f010125d:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0101260:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101263:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101266:	e9 84 00 00 00       	jmp    f01012ef <.L38+0xd1>
				p = "(null)";
f010126b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010126e:	8d 80 ce 0f ff ff    	lea    -0xf032(%eax),%eax
f0101274:	89 45 c8             	mov    %eax,-0x38(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101277:	83 ec 08             	sub    $0x8,%esp
f010127a:	ff 75 d0             	pushl  -0x30(%ebp)
f010127d:	ff 75 c8             	pushl  -0x38(%ebp)
f0101280:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101283:	e8 bc 04 00 00       	call   f0101744 <strnlen>
f0101288:	29 45 e0             	sub    %eax,-0x20(%ebp)
f010128b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010128e:	83 c4 10             	add    $0x10,%esp
f0101291:	85 d2                	test   %edx,%edx
f0101293:	7e 14                	jle    f01012a9 <.L38+0x8b>
					putch(padc, putdat);
f0101295:	0f be 5d d7          	movsbl -0x29(%ebp),%ebx
f0101299:	83 ec 08             	sub    $0x8,%esp
f010129c:	56                   	push   %esi
f010129d:	53                   	push   %ebx
f010129e:	ff d7                	call   *%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f01012a0:	83 c4 10             	add    $0x10,%esp
f01012a3:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01012a7:	75 f0                	jne    f0101299 <.L38+0x7b>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01012a9:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01012ac:	8d 58 01             	lea    0x1(%eax),%ebx
f01012af:	0f b6 10             	movzbl (%eax),%edx
f01012b2:	0f be c2             	movsbl %dl,%eax
f01012b5:	85 c0                	test   %eax,%eax
f01012b7:	0f 84 ac 02 00 00    	je     f0101569 <.L24+0x2e>
f01012bd:	89 7d 08             	mov    %edi,0x8(%ebp)
f01012c0:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01012c3:	89 75 0c             	mov    %esi,0xc(%ebp)
f01012c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01012c9:	eb 24                	jmp    f01012ef <.L38+0xd1>
				if (altflag && (ch < ' ' || ch > '~'))
f01012cb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01012cf:	75 32                	jne    f0101303 <.L38+0xe5>
					putch(ch, putdat);
f01012d1:	83 ec 08             	sub    $0x8,%esp
f01012d4:	ff 75 0c             	pushl  0xc(%ebp)
f01012d7:	50                   	push   %eax
f01012d8:	ff 55 08             	call   *0x8(%ebp)
f01012db:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01012de:	83 ee 01             	sub    $0x1,%esi
f01012e1:	83 c3 01             	add    $0x1,%ebx
f01012e4:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
f01012e8:	0f be c2             	movsbl %dl,%eax
f01012eb:	85 c0                	test   %eax,%eax
f01012ed:	74 2f                	je     f010131e <.L38+0x100>
f01012ef:	85 ff                	test   %edi,%edi
f01012f1:	78 d8                	js     f01012cb <.L38+0xad>
f01012f3:	83 ef 01             	sub    $0x1,%edi
f01012f6:	79 d3                	jns    f01012cb <.L38+0xad>
f01012f8:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01012fb:	8b 7d 08             	mov    0x8(%ebp),%edi
f01012fe:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101301:	eb 24                	jmp    f0101327 <.L38+0x109>
				if (altflag && (ch < ' ' || ch > '~'))
f0101303:	0f be d2             	movsbl %dl,%edx
f0101306:	83 ea 20             	sub    $0x20,%edx
f0101309:	83 fa 5e             	cmp    $0x5e,%edx
f010130c:	76 c3                	jbe    f01012d1 <.L38+0xb3>
					putch('?', putdat);
f010130e:	83 ec 08             	sub    $0x8,%esp
f0101311:	ff 75 0c             	pushl  0xc(%ebp)
f0101314:	6a 3f                	push   $0x3f
f0101316:	ff 55 08             	call   *0x8(%ebp)
f0101319:	83 c4 10             	add    $0x10,%esp
f010131c:	eb c0                	jmp    f01012de <.L38+0xc0>
f010131e:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0101321:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101324:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101327:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			for (; width > 0; width--)
f010132a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010132e:	7e 1b                	jle    f010134b <.L38+0x12d>
				putch(' ', putdat);
f0101330:	83 ec 08             	sub    $0x8,%esp
f0101333:	56                   	push   %esi
f0101334:	6a 20                	push   $0x20
f0101336:	ff d7                	call   *%edi
			for (; width > 0; width--)
f0101338:	83 c4 10             	add    $0x10,%esp
f010133b:	83 eb 01             	sub    $0x1,%ebx
f010133e:	75 f0                	jne    f0101330 <.L38+0x112>
			if ((p = va_arg(ap, char *)) == NULL)
f0101340:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101343:	89 45 14             	mov    %eax,0x14(%ebp)
f0101346:	e9 22 fd ff ff       	jmp    f010106d <vprintfmt+0x1c>
f010134b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010134e:	89 45 14             	mov    %eax,0x14(%ebp)
f0101351:	e9 17 fd ff ff       	jmp    f010106d <vprintfmt+0x1c>

f0101356 <.L33>:
f0101356:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101359:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (lflag >= 2)
f010135c:	83 f9 01             	cmp    $0x1,%ecx
f010135f:	7e 3f                	jle    f01013a0 <.L33+0x4a>
		return va_arg(*ap, long long);
f0101361:	8b 45 14             	mov    0x14(%ebp),%eax
f0101364:	8b 50 04             	mov    0x4(%eax),%edx
f0101367:	8b 00                	mov    (%eax),%eax
f0101369:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010136c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010136f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101372:	8d 40 08             	lea    0x8(%eax),%eax
f0101375:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101378:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010137c:	79 54                	jns    f01013d2 <.L33+0x7c>
				putch('-', putdat);
f010137e:	83 ec 08             	sub    $0x8,%esp
f0101381:	56                   	push   %esi
f0101382:	6a 2d                	push   $0x2d
f0101384:	ff d7                	call   *%edi
				num = -(long long) num;
f0101386:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0101389:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010138c:	f7 d9                	neg    %ecx
f010138e:	83 d3 00             	adc    $0x0,%ebx
f0101391:	f7 db                	neg    %ebx
f0101393:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101396:	ba 0a 00 00 00       	mov    $0xa,%edx
f010139b:	e9 17 01 00 00       	jmp    f01014b7 <.L37+0x2b>
	else if (lflag)
f01013a0:	85 c9                	test   %ecx,%ecx
f01013a2:	75 17                	jne    f01013bb <.L33+0x65>
		return va_arg(*ap, int);
f01013a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01013a7:	8b 00                	mov    (%eax),%eax
f01013a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01013ac:	99                   	cltd   
f01013ad:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01013b0:	8b 45 14             	mov    0x14(%ebp),%eax
f01013b3:	8d 40 04             	lea    0x4(%eax),%eax
f01013b6:	89 45 14             	mov    %eax,0x14(%ebp)
f01013b9:	eb bd                	jmp    f0101378 <.L33+0x22>
		return va_arg(*ap, long);
f01013bb:	8b 45 14             	mov    0x14(%ebp),%eax
f01013be:	8b 00                	mov    (%eax),%eax
f01013c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01013c3:	99                   	cltd   
f01013c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01013c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01013ca:	8d 40 04             	lea    0x4(%eax),%eax
f01013cd:	89 45 14             	mov    %eax,0x14(%ebp)
f01013d0:	eb a6                	jmp    f0101378 <.L33+0x22>
			num = getint(&ap, lflag);
f01013d2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01013d5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f01013d8:	ba 0a 00 00 00       	mov    $0xa,%edx
f01013dd:	e9 d5 00 00 00       	jmp    f01014b7 <.L37+0x2b>

f01013e2 <.L39>:
f01013e2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01013e5:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (lflag >= 2)
f01013e8:	83 f9 01             	cmp    $0x1,%ecx
f01013eb:	7e 18                	jle    f0101405 <.L39+0x23>
		return va_arg(*ap, unsigned long long);
f01013ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01013f0:	8b 08                	mov    (%eax),%ecx
f01013f2:	8b 58 04             	mov    0x4(%eax),%ebx
f01013f5:	8d 40 08             	lea    0x8(%eax),%eax
f01013f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01013fb:	ba 0a 00 00 00       	mov    $0xa,%edx
f0101400:	e9 b2 00 00 00       	jmp    f01014b7 <.L37+0x2b>
	else if (lflag)
f0101405:	85 c9                	test   %ecx,%ecx
f0101407:	75 1a                	jne    f0101423 <.L39+0x41>
		return va_arg(*ap, unsigned int);
f0101409:	8b 45 14             	mov    0x14(%ebp),%eax
f010140c:	8b 08                	mov    (%eax),%ecx
f010140e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101413:	8d 40 04             	lea    0x4(%eax),%eax
f0101416:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101419:	ba 0a 00 00 00       	mov    $0xa,%edx
f010141e:	e9 94 00 00 00       	jmp    f01014b7 <.L37+0x2b>
		return va_arg(*ap, unsigned long);
f0101423:	8b 45 14             	mov    0x14(%ebp),%eax
f0101426:	8b 08                	mov    (%eax),%ecx
f0101428:	bb 00 00 00 00       	mov    $0x0,%ebx
f010142d:	8d 40 04             	lea    0x4(%eax),%eax
f0101430:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101433:	ba 0a 00 00 00       	mov    $0xa,%edx
f0101438:	eb 7d                	jmp    f01014b7 <.L37+0x2b>

f010143a <.L36>:
f010143a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010143d:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (lflag >= 2)
f0101440:	83 f9 01             	cmp    $0x1,%ecx
f0101443:	7e 15                	jle    f010145a <.L36+0x20>
		return va_arg(*ap, unsigned long long);
f0101445:	8b 45 14             	mov    0x14(%ebp),%eax
f0101448:	8b 08                	mov    (%eax),%ecx
f010144a:	8b 58 04             	mov    0x4(%eax),%ebx
f010144d:	8d 40 08             	lea    0x8(%eax),%eax
f0101450:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f0101453:	ba 08 00 00 00       	mov    $0x8,%edx
f0101458:	eb 5d                	jmp    f01014b7 <.L37+0x2b>
	else if (lflag)
f010145a:	85 c9                	test   %ecx,%ecx
f010145c:	75 17                	jne    f0101475 <.L36+0x3b>
		return va_arg(*ap, unsigned int);
f010145e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101461:	8b 08                	mov    (%eax),%ecx
f0101463:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101468:	8d 40 04             	lea    0x4(%eax),%eax
f010146b:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f010146e:	ba 08 00 00 00       	mov    $0x8,%edx
f0101473:	eb 42                	jmp    f01014b7 <.L37+0x2b>
		return va_arg(*ap, unsigned long);
f0101475:	8b 45 14             	mov    0x14(%ebp),%eax
f0101478:	8b 08                	mov    (%eax),%ecx
f010147a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010147f:	8d 40 04             	lea    0x4(%eax),%eax
f0101482:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f0101485:	ba 08 00 00 00       	mov    $0x8,%edx
f010148a:	eb 2b                	jmp    f01014b7 <.L37+0x2b>

f010148c <.L37>:
f010148c:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch('0', putdat);
f010148f:	83 ec 08             	sub    $0x8,%esp
f0101492:	56                   	push   %esi
f0101493:	6a 30                	push   $0x30
f0101495:	ff d7                	call   *%edi
			putch('x', putdat);
f0101497:	83 c4 08             	add    $0x8,%esp
f010149a:	56                   	push   %esi
f010149b:	6a 78                	push   $0x78
f010149d:	ff d7                	call   *%edi
			num = (unsigned long long)
f010149f:	8b 45 14             	mov    0x14(%ebp),%eax
f01014a2:	8b 08                	mov    (%eax),%ecx
f01014a4:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f01014a9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01014ac:	8d 40 04             	lea    0x4(%eax),%eax
f01014af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01014b2:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f01014b7:	83 ec 0c             	sub    $0xc,%esp
f01014ba:	0f be 45 d7          	movsbl -0x29(%ebp),%eax
f01014be:	50                   	push   %eax
f01014bf:	ff 75 e0             	pushl  -0x20(%ebp)
f01014c2:	52                   	push   %edx
f01014c3:	53                   	push   %ebx
f01014c4:	51                   	push   %ecx
f01014c5:	89 f2                	mov    %esi,%edx
f01014c7:	89 f8                	mov    %edi,%eax
f01014c9:	e8 80 fa ff ff       	call   f0100f4e <printnum>
			break;
f01014ce:	83 c4 20             	add    $0x20,%esp
f01014d1:	e9 97 fb ff ff       	jmp    f010106d <vprintfmt+0x1c>

f01014d6 <.L40>:
f01014d6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01014d9:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (lflag >= 2)
f01014dc:	83 f9 01             	cmp    $0x1,%ecx
f01014df:	7e 15                	jle    f01014f6 <.L40+0x20>
		return va_arg(*ap, unsigned long long);
f01014e1:	8b 45 14             	mov    0x14(%ebp),%eax
f01014e4:	8b 08                	mov    (%eax),%ecx
f01014e6:	8b 58 04             	mov    0x4(%eax),%ebx
f01014e9:	8d 40 08             	lea    0x8(%eax),%eax
f01014ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01014ef:	ba 10 00 00 00       	mov    $0x10,%edx
f01014f4:	eb c1                	jmp    f01014b7 <.L37+0x2b>
	else if (lflag)
f01014f6:	85 c9                	test   %ecx,%ecx
f01014f8:	75 17                	jne    f0101511 <.L40+0x3b>
		return va_arg(*ap, unsigned int);
f01014fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01014fd:	8b 08                	mov    (%eax),%ecx
f01014ff:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101504:	8d 40 04             	lea    0x4(%eax),%eax
f0101507:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010150a:	ba 10 00 00 00       	mov    $0x10,%edx
f010150f:	eb a6                	jmp    f01014b7 <.L37+0x2b>
		return va_arg(*ap, unsigned long);
f0101511:	8b 45 14             	mov    0x14(%ebp),%eax
f0101514:	8b 08                	mov    (%eax),%ecx
f0101516:	bb 00 00 00 00       	mov    $0x0,%ebx
f010151b:	8d 40 04             	lea    0x4(%eax),%eax
f010151e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101521:	ba 10 00 00 00       	mov    $0x10,%edx
f0101526:	eb 8f                	jmp    f01014b7 <.L37+0x2b>

f0101528 <.L27>:
f0101528:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(ch, putdat);
f010152b:	83 ec 08             	sub    $0x8,%esp
f010152e:	56                   	push   %esi
f010152f:	6a 25                	push   $0x25
f0101531:	ff d7                	call   *%edi
			break;
f0101533:	83 c4 10             	add    $0x10,%esp
f0101536:	e9 32 fb ff ff       	jmp    f010106d <vprintfmt+0x1c>

f010153b <.L24>:
f010153b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch('%', putdat);
f010153e:	83 ec 08             	sub    $0x8,%esp
f0101541:	56                   	push   %esi
f0101542:	6a 25                	push   $0x25
f0101544:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101546:	83 c4 10             	add    $0x10,%esp
f0101549:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f010154d:	0f 84 4e fb ff ff    	je     f01010a1 <vprintfmt+0x50>
f0101553:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101556:	89 d8                	mov    %ebx,%eax
f0101558:	83 e8 01             	sub    $0x1,%eax
f010155b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010155f:	75 f7                	jne    f0101558 <.L24+0x1d>
f0101561:	89 45 10             	mov    %eax,0x10(%ebp)
f0101564:	e9 04 fb ff ff       	jmp    f010106d <vprintfmt+0x1c>
			if ((p = va_arg(ap, char *)) == NULL)
f0101569:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010156c:	89 45 14             	mov    %eax,0x14(%ebp)
f010156f:	e9 f9 fa ff ff       	jmp    f010106d <vprintfmt+0x1c>
			if (width > 0 && padc != '-')
f0101574:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101578:	7e 0a                	jle    f0101584 <.L24+0x49>
f010157a:	80 7d d7 2d          	cmpb   $0x2d,-0x29(%ebp)
f010157e:	0f 85 e7 fc ff ff    	jne    f010126b <.L38+0x4d>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101584:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101587:	8d 98 cf 0f ff ff    	lea    -0xf031(%eax),%ebx
f010158d:	b8 28 00 00 00       	mov    $0x28,%eax
f0101592:	ba 28 00 00 00       	mov    $0x28,%edx
f0101597:	89 7d 08             	mov    %edi,0x8(%ebp)
f010159a:	8b 7d d0             	mov    -0x30(%ebp),%edi
f010159d:	89 75 0c             	mov    %esi,0xc(%ebp)
f01015a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01015a3:	e9 47 fd ff ff       	jmp    f01012ef <.L38+0xd1>

f01015a8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01015a8:	55                   	push   %ebp
f01015a9:	89 e5                	mov    %esp,%ebp
f01015ab:	53                   	push   %ebx
f01015ac:	83 ec 14             	sub    $0x14,%esp
f01015af:	e8 08 ec ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01015b4:	81 c3 54 fd 00 00    	add    $0xfd54,%ebx
f01015ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01015bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01015c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01015c3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01015c7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01015ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01015d1:	85 c0                	test   %eax,%eax
f01015d3:	74 2b                	je     f0101600 <vsnprintf+0x58>
f01015d5:	85 d2                	test   %edx,%edx
f01015d7:	7e 27                	jle    f0101600 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01015d9:	ff 75 14             	pushl  0x14(%ebp)
f01015dc:	ff 75 10             	pushl  0x10(%ebp)
f01015df:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01015e2:	50                   	push   %eax
f01015e3:	8d 83 0f fd fe ff    	lea    -0x102f1(%ebx),%eax
f01015e9:	50                   	push   %eax
f01015ea:	e8 62 fa ff ff       	call   f0101051 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01015ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01015f2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01015f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015f8:	83 c4 10             	add    $0x10,%esp
}
f01015fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01015fe:	c9                   	leave  
f01015ff:	c3                   	ret    
		return -E_INVAL;
f0101600:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101605:	eb f4                	jmp    f01015fb <vsnprintf+0x53>

f0101607 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101607:	55                   	push   %ebp
f0101608:	89 e5                	mov    %esp,%ebp
f010160a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010160d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101610:	50                   	push   %eax
f0101611:	ff 75 10             	pushl  0x10(%ebp)
f0101614:	ff 75 0c             	pushl  0xc(%ebp)
f0101617:	ff 75 08             	pushl  0x8(%ebp)
f010161a:	e8 89 ff ff ff       	call   f01015a8 <vsnprintf>
	va_end(ap);

	return rc;
}
f010161f:	c9                   	leave  
f0101620:	c3                   	ret    

f0101621 <__x86.get_pc_thunk.cx>:
f0101621:	8b 0c 24             	mov    (%esp),%ecx
f0101624:	c3                   	ret    

f0101625 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101625:	55                   	push   %ebp
f0101626:	89 e5                	mov    %esp,%ebp
f0101628:	57                   	push   %edi
f0101629:	56                   	push   %esi
f010162a:	53                   	push   %ebx
f010162b:	83 ec 1c             	sub    $0x1c,%esp
f010162e:	e8 89 eb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0101633:	81 c3 d5 fc 00 00    	add    $0xfcd5,%ebx
f0101639:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010163c:	85 c0                	test   %eax,%eax
f010163e:	74 13                	je     f0101653 <readline+0x2e>
		cprintf("%s", prompt);
f0101640:	83 ec 08             	sub    $0x8,%esp
f0101643:	50                   	push   %eax
f0101644:	8d 83 de 0f ff ff    	lea    -0xf022(%ebx),%eax
f010164a:	50                   	push   %eax
f010164b:	e8 eb f4 ff ff       	call   f0100b3b <cprintf>
f0101650:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101653:	83 ec 0c             	sub    $0xc,%esp
f0101656:	6a 00                	push   $0x0
f0101658:	e8 f8 f0 ff ff       	call   f0100755 <iscons>
f010165d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101660:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101663:	bf 00 00 00 00       	mov    $0x0,%edi
f0101668:	eb 46                	jmp    f01016b0 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010166a:	83 ec 08             	sub    $0x8,%esp
f010166d:	50                   	push   %eax
f010166e:	8d 83 a4 11 ff ff    	lea    -0xee5c(%ebx),%eax
f0101674:	50                   	push   %eax
f0101675:	e8 c1 f4 ff ff       	call   f0100b3b <cprintf>
			return NULL;
f010167a:	83 c4 10             	add    $0x10,%esp
f010167d:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0101682:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101685:	5b                   	pop    %ebx
f0101686:	5e                   	pop    %esi
f0101687:	5f                   	pop    %edi
f0101688:	5d                   	pop    %ebp
f0101689:	c3                   	ret    
			if (echoing)
f010168a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010168e:	75 05                	jne    f0101695 <readline+0x70>
			i--;
f0101690:	83 ef 01             	sub    $0x1,%edi
f0101693:	eb 1b                	jmp    f01016b0 <readline+0x8b>
				cputchar('\b');
f0101695:	83 ec 0c             	sub    $0xc,%esp
f0101698:	6a 08                	push   $0x8
f010169a:	e8 95 f0 ff ff       	call   f0100734 <cputchar>
f010169f:	83 c4 10             	add    $0x10,%esp
f01016a2:	eb ec                	jmp    f0101690 <readline+0x6b>
			buf[i++] = c;
f01016a4:	89 f0                	mov    %esi,%eax
f01016a6:	88 84 3b 98 1f 00 00 	mov    %al,0x1f98(%ebx,%edi,1)
f01016ad:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01016b0:	e8 8f f0 ff ff       	call   f0100744 <getchar>
f01016b5:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01016b7:	85 c0                	test   %eax,%eax
f01016b9:	78 af                	js     f010166a <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01016bb:	83 f8 08             	cmp    $0x8,%eax
f01016be:	0f 94 c2             	sete   %dl
f01016c1:	83 f8 7f             	cmp    $0x7f,%eax
f01016c4:	0f 94 c0             	sete   %al
f01016c7:	08 c2                	or     %al,%dl
f01016c9:	74 04                	je     f01016cf <readline+0xaa>
f01016cb:	85 ff                	test   %edi,%edi
f01016cd:	7f bb                	jg     f010168a <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01016cf:	83 fe 1f             	cmp    $0x1f,%esi
f01016d2:	7e 1c                	jle    f01016f0 <readline+0xcb>
f01016d4:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01016da:	7f 14                	jg     f01016f0 <readline+0xcb>
			if (echoing)
f01016dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01016e0:	74 c2                	je     f01016a4 <readline+0x7f>
				cputchar(c);
f01016e2:	83 ec 0c             	sub    $0xc,%esp
f01016e5:	56                   	push   %esi
f01016e6:	e8 49 f0 ff ff       	call   f0100734 <cputchar>
f01016eb:	83 c4 10             	add    $0x10,%esp
f01016ee:	eb b4                	jmp    f01016a4 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f01016f0:	83 fe 0a             	cmp    $0xa,%esi
f01016f3:	74 05                	je     f01016fa <readline+0xd5>
f01016f5:	83 fe 0d             	cmp    $0xd,%esi
f01016f8:	75 b6                	jne    f01016b0 <readline+0x8b>
			if (echoing)
f01016fa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01016fe:	75 13                	jne    f0101713 <readline+0xee>
			buf[i] = 0;
f0101700:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f0101707:	00 
			return buf;
f0101708:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f010170e:	e9 6f ff ff ff       	jmp    f0101682 <readline+0x5d>
				cputchar('\n');
f0101713:	83 ec 0c             	sub    $0xc,%esp
f0101716:	6a 0a                	push   $0xa
f0101718:	e8 17 f0 ff ff       	call   f0100734 <cputchar>
f010171d:	83 c4 10             	add    $0x10,%esp
f0101720:	eb de                	jmp    f0101700 <readline+0xdb>

f0101722 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101722:	55                   	push   %ebp
f0101723:	89 e5                	mov    %esp,%ebp
f0101725:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101728:	80 3a 00             	cmpb   $0x0,(%edx)
f010172b:	74 10                	je     f010173d <strlen+0x1b>
f010172d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0101732:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0101735:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101739:	75 f7                	jne    f0101732 <strlen+0x10>
	return n;
}
f010173b:	5d                   	pop    %ebp
f010173c:	c3                   	ret    
	for (n = 0; *s != '\0'; s++)
f010173d:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
f0101742:	eb f7                	jmp    f010173b <strlen+0x19>

f0101744 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101744:	55                   	push   %ebp
f0101745:	89 e5                	mov    %esp,%ebp
f0101747:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010174a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010174d:	85 d2                	test   %edx,%edx
f010174f:	74 19                	je     f010176a <strnlen+0x26>
f0101751:	80 39 00             	cmpb   $0x0,(%ecx)
f0101754:	74 1b                	je     f0101771 <strnlen+0x2d>
f0101756:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f010175b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010175e:	39 c2                	cmp    %eax,%edx
f0101760:	74 06                	je     f0101768 <strnlen+0x24>
f0101762:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101766:	75 f3                	jne    f010175b <strnlen+0x17>
	return n;
}
f0101768:	5d                   	pop    %ebp
f0101769:	c3                   	ret    
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010176a:	b8 00 00 00 00       	mov    $0x0,%eax
f010176f:	eb f7                	jmp    f0101768 <strnlen+0x24>
f0101771:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
f0101776:	eb f0                	jmp    f0101768 <strnlen+0x24>

f0101778 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101778:	55                   	push   %ebp
f0101779:	89 e5                	mov    %esp,%ebp
f010177b:	53                   	push   %ebx
f010177c:	8b 45 08             	mov    0x8(%ebp),%eax
f010177f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101782:	89 c2                	mov    %eax,%edx
f0101784:	83 c1 01             	add    $0x1,%ecx
f0101787:	83 c2 01             	add    $0x1,%edx
f010178a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010178e:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101791:	84 db                	test   %bl,%bl
f0101793:	75 ef                	jne    f0101784 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101795:	5b                   	pop    %ebx
f0101796:	5d                   	pop    %ebp
f0101797:	c3                   	ret    

f0101798 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101798:	55                   	push   %ebp
f0101799:	89 e5                	mov    %esp,%ebp
f010179b:	53                   	push   %ebx
f010179c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010179f:	53                   	push   %ebx
f01017a0:	e8 7d ff ff ff       	call   f0101722 <strlen>
f01017a5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01017a8:	ff 75 0c             	pushl  0xc(%ebp)
f01017ab:	01 d8                	add    %ebx,%eax
f01017ad:	50                   	push   %eax
f01017ae:	e8 c5 ff ff ff       	call   f0101778 <strcpy>
	return dst;
}
f01017b3:	89 d8                	mov    %ebx,%eax
f01017b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01017b8:	c9                   	leave  
f01017b9:	c3                   	ret    

f01017ba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01017ba:	55                   	push   %ebp
f01017bb:	89 e5                	mov    %esp,%ebp
f01017bd:	56                   	push   %esi
f01017be:	53                   	push   %ebx
f01017bf:	8b 75 08             	mov    0x8(%ebp),%esi
f01017c2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01017c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01017c8:	85 db                	test   %ebx,%ebx
f01017ca:	74 17                	je     f01017e3 <strncpy+0x29>
f01017cc:	01 f3                	add    %esi,%ebx
f01017ce:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f01017d0:	83 c1 01             	add    $0x1,%ecx
f01017d3:	0f b6 02             	movzbl (%edx),%eax
f01017d6:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01017d9:	80 3a 01             	cmpb   $0x1,(%edx)
f01017dc:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f01017df:	39 cb                	cmp    %ecx,%ebx
f01017e1:	75 ed                	jne    f01017d0 <strncpy+0x16>
	}
	return ret;
}
f01017e3:	89 f0                	mov    %esi,%eax
f01017e5:	5b                   	pop    %ebx
f01017e6:	5e                   	pop    %esi
f01017e7:	5d                   	pop    %ebp
f01017e8:	c3                   	ret    

f01017e9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01017e9:	55                   	push   %ebp
f01017ea:	89 e5                	mov    %esp,%ebp
f01017ec:	57                   	push   %edi
f01017ed:	56                   	push   %esi
f01017ee:	53                   	push   %ebx
f01017ef:	8b 75 08             	mov    0x8(%ebp),%esi
f01017f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01017f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01017f8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01017fa:	85 db                	test   %ebx,%ebx
f01017fc:	74 2b                	je     f0101829 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f01017fe:	83 fb 01             	cmp    $0x1,%ebx
f0101801:	74 23                	je     f0101826 <strlcpy+0x3d>
f0101803:	0f b6 0f             	movzbl (%edi),%ecx
f0101806:	84 c9                	test   %cl,%cl
f0101808:	74 1c                	je     f0101826 <strlcpy+0x3d>
f010180a:	8d 57 01             	lea    0x1(%edi),%edx
f010180d:	8d 5c 1f ff          	lea    -0x1(%edi,%ebx,1),%ebx
			*dst++ = *src++;
f0101811:	83 c0 01             	add    $0x1,%eax
f0101814:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0101817:	39 da                	cmp    %ebx,%edx
f0101819:	74 0b                	je     f0101826 <strlcpy+0x3d>
f010181b:	83 c2 01             	add    $0x1,%edx
f010181e:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
f0101822:	84 c9                	test   %cl,%cl
f0101824:	75 eb                	jne    f0101811 <strlcpy+0x28>
		*dst = '\0';
f0101826:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101829:	29 f0                	sub    %esi,%eax
}
f010182b:	5b                   	pop    %ebx
f010182c:	5e                   	pop    %esi
f010182d:	5f                   	pop    %edi
f010182e:	5d                   	pop    %ebp
f010182f:	c3                   	ret    

f0101830 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101830:	55                   	push   %ebp
f0101831:	89 e5                	mov    %esp,%ebp
f0101833:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101836:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101839:	0f b6 01             	movzbl (%ecx),%eax
f010183c:	84 c0                	test   %al,%al
f010183e:	74 15                	je     f0101855 <strcmp+0x25>
f0101840:	3a 02                	cmp    (%edx),%al
f0101842:	75 11                	jne    f0101855 <strcmp+0x25>
		p++, q++;
f0101844:	83 c1 01             	add    $0x1,%ecx
f0101847:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f010184a:	0f b6 01             	movzbl (%ecx),%eax
f010184d:	84 c0                	test   %al,%al
f010184f:	74 04                	je     f0101855 <strcmp+0x25>
f0101851:	3a 02                	cmp    (%edx),%al
f0101853:	74 ef                	je     f0101844 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101855:	0f b6 c0             	movzbl %al,%eax
f0101858:	0f b6 12             	movzbl (%edx),%edx
f010185b:	29 d0                	sub    %edx,%eax
}
f010185d:	5d                   	pop    %ebp
f010185e:	c3                   	ret    

f010185f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010185f:	55                   	push   %ebp
f0101860:	89 e5                	mov    %esp,%ebp
f0101862:	53                   	push   %ebx
f0101863:	8b 45 08             	mov    0x8(%ebp),%eax
f0101866:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101869:	8b 5d 10             	mov    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010186c:	85 db                	test   %ebx,%ebx
f010186e:	74 2d                	je     f010189d <strncmp+0x3e>
f0101870:	0f b6 08             	movzbl (%eax),%ecx
f0101873:	84 c9                	test   %cl,%cl
f0101875:	74 1b                	je     f0101892 <strncmp+0x33>
f0101877:	3a 0a                	cmp    (%edx),%cl
f0101879:	75 17                	jne    f0101892 <strncmp+0x33>
f010187b:	01 c3                	add    %eax,%ebx
		n--, p++, q++;
f010187d:	83 c0 01             	add    $0x1,%eax
f0101880:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0101883:	39 d8                	cmp    %ebx,%eax
f0101885:	74 1d                	je     f01018a4 <strncmp+0x45>
f0101887:	0f b6 08             	movzbl (%eax),%ecx
f010188a:	84 c9                	test   %cl,%cl
f010188c:	74 04                	je     f0101892 <strncmp+0x33>
f010188e:	3a 0a                	cmp    (%edx),%cl
f0101890:	74 eb                	je     f010187d <strncmp+0x1e>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101892:	0f b6 00             	movzbl (%eax),%eax
f0101895:	0f b6 12             	movzbl (%edx),%edx
f0101898:	29 d0                	sub    %edx,%eax
}
f010189a:	5b                   	pop    %ebx
f010189b:	5d                   	pop    %ebp
f010189c:	c3                   	ret    
		return 0;
f010189d:	b8 00 00 00 00       	mov    $0x0,%eax
f01018a2:	eb f6                	jmp    f010189a <strncmp+0x3b>
f01018a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01018a9:	eb ef                	jmp    f010189a <strncmp+0x3b>

f01018ab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01018ab:	55                   	push   %ebp
f01018ac:	89 e5                	mov    %esp,%ebp
f01018ae:	53                   	push   %ebx
f01018af:	8b 45 08             	mov    0x8(%ebp),%eax
f01018b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
f01018b5:	0f b6 10             	movzbl (%eax),%edx
f01018b8:	84 d2                	test   %dl,%dl
f01018ba:	74 1e                	je     f01018da <strchr+0x2f>
f01018bc:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
f01018be:	38 d3                	cmp    %dl,%bl
f01018c0:	74 15                	je     f01018d7 <strchr+0x2c>
	for (; *s; s++)
f01018c2:	83 c0 01             	add    $0x1,%eax
f01018c5:	0f b6 10             	movzbl (%eax),%edx
f01018c8:	84 d2                	test   %dl,%dl
f01018ca:	74 06                	je     f01018d2 <strchr+0x27>
		if (*s == c)
f01018cc:	38 ca                	cmp    %cl,%dl
f01018ce:	75 f2                	jne    f01018c2 <strchr+0x17>
f01018d0:	eb 05                	jmp    f01018d7 <strchr+0x2c>
			return (char *) s;
	return 0;
f01018d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01018d7:	5b                   	pop    %ebx
f01018d8:	5d                   	pop    %ebp
f01018d9:	c3                   	ret    
	return 0;
f01018da:	b8 00 00 00 00       	mov    $0x0,%eax
f01018df:	eb f6                	jmp    f01018d7 <strchr+0x2c>

f01018e1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01018e1:	55                   	push   %ebp
f01018e2:	89 e5                	mov    %esp,%ebp
f01018e4:	53                   	push   %ebx
f01018e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01018e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f01018eb:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
f01018ee:	38 d3                	cmp    %dl,%bl
f01018f0:	74 14                	je     f0101906 <strfind+0x25>
f01018f2:	89 d1                	mov    %edx,%ecx
f01018f4:	84 db                	test   %bl,%bl
f01018f6:	74 0e                	je     f0101906 <strfind+0x25>
	for (; *s; s++)
f01018f8:	83 c0 01             	add    $0x1,%eax
f01018fb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01018fe:	38 ca                	cmp    %cl,%dl
f0101900:	74 04                	je     f0101906 <strfind+0x25>
f0101902:	84 d2                	test   %dl,%dl
f0101904:	75 f2                	jne    f01018f8 <strfind+0x17>
			break;
	return (char *) s;
}
f0101906:	5b                   	pop    %ebx
f0101907:	5d                   	pop    %ebp
f0101908:	c3                   	ret    

f0101909 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101909:	55                   	push   %ebp
f010190a:	89 e5                	mov    %esp,%ebp
f010190c:	57                   	push   %edi
f010190d:	56                   	push   %esi
f010190e:	53                   	push   %ebx
f010190f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101912:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101915:	85 c9                	test   %ecx,%ecx
f0101917:	74 13                	je     f010192c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101919:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010191f:	75 05                	jne    f0101926 <memset+0x1d>
f0101921:	f6 c1 03             	test   $0x3,%cl
f0101924:	74 0d                	je     f0101933 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101926:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101929:	fc                   	cld    
f010192a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010192c:	89 f8                	mov    %edi,%eax
f010192e:	5b                   	pop    %ebx
f010192f:	5e                   	pop    %esi
f0101930:	5f                   	pop    %edi
f0101931:	5d                   	pop    %ebp
f0101932:	c3                   	ret    
		c &= 0xFF;
f0101933:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101937:	89 d3                	mov    %edx,%ebx
f0101939:	c1 e3 08             	shl    $0x8,%ebx
f010193c:	89 d0                	mov    %edx,%eax
f010193e:	c1 e0 18             	shl    $0x18,%eax
f0101941:	89 d6                	mov    %edx,%esi
f0101943:	c1 e6 10             	shl    $0x10,%esi
f0101946:	09 f0                	or     %esi,%eax
f0101948:	09 c2                	or     %eax,%edx
f010194a:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f010194c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010194f:	89 d0                	mov    %edx,%eax
f0101951:	fc                   	cld    
f0101952:	f3 ab                	rep stos %eax,%es:(%edi)
f0101954:	eb d6                	jmp    f010192c <memset+0x23>

f0101956 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101956:	55                   	push   %ebp
f0101957:	89 e5                	mov    %esp,%ebp
f0101959:	57                   	push   %edi
f010195a:	56                   	push   %esi
f010195b:	8b 45 08             	mov    0x8(%ebp),%eax
f010195e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101961:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101964:	39 c6                	cmp    %eax,%esi
f0101966:	73 35                	jae    f010199d <memmove+0x47>
f0101968:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010196b:	39 c2                	cmp    %eax,%edx
f010196d:	76 2e                	jbe    f010199d <memmove+0x47>
		s += n;
		d += n;
f010196f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101972:	89 d6                	mov    %edx,%esi
f0101974:	09 fe                	or     %edi,%esi
f0101976:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010197c:	74 0c                	je     f010198a <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010197e:	83 ef 01             	sub    $0x1,%edi
f0101981:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101984:	fd                   	std    
f0101985:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101987:	fc                   	cld    
f0101988:	eb 21                	jmp    f01019ab <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010198a:	f6 c1 03             	test   $0x3,%cl
f010198d:	75 ef                	jne    f010197e <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010198f:	83 ef 04             	sub    $0x4,%edi
f0101992:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101995:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101998:	fd                   	std    
f0101999:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010199b:	eb ea                	jmp    f0101987 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010199d:	89 f2                	mov    %esi,%edx
f010199f:	09 c2                	or     %eax,%edx
f01019a1:	f6 c2 03             	test   $0x3,%dl
f01019a4:	74 09                	je     f01019af <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01019a6:	89 c7                	mov    %eax,%edi
f01019a8:	fc                   	cld    
f01019a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01019ab:	5e                   	pop    %esi
f01019ac:	5f                   	pop    %edi
f01019ad:	5d                   	pop    %ebp
f01019ae:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01019af:	f6 c1 03             	test   $0x3,%cl
f01019b2:	75 f2                	jne    f01019a6 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01019b4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01019b7:	89 c7                	mov    %eax,%edi
f01019b9:	fc                   	cld    
f01019ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01019bc:	eb ed                	jmp    f01019ab <memmove+0x55>

f01019be <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01019be:	55                   	push   %ebp
f01019bf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01019c1:	ff 75 10             	pushl  0x10(%ebp)
f01019c4:	ff 75 0c             	pushl  0xc(%ebp)
f01019c7:	ff 75 08             	pushl  0x8(%ebp)
f01019ca:	e8 87 ff ff ff       	call   f0101956 <memmove>
}
f01019cf:	c9                   	leave  
f01019d0:	c3                   	ret    

f01019d1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01019d1:	55                   	push   %ebp
f01019d2:	89 e5                	mov    %esp,%ebp
f01019d4:	57                   	push   %edi
f01019d5:	56                   	push   %esi
f01019d6:	53                   	push   %ebx
f01019d7:	8b 75 08             	mov    0x8(%ebp),%esi
f01019da:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01019dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01019e0:	85 db                	test   %ebx,%ebx
f01019e2:	74 37                	je     f0101a1b <memcmp+0x4a>
		if (*s1 != *s2)
f01019e4:	0f b6 16             	movzbl (%esi),%edx
f01019e7:	0f b6 0f             	movzbl (%edi),%ecx
f01019ea:	38 ca                	cmp    %cl,%dl
f01019ec:	75 19                	jne    f0101a07 <memcmp+0x36>
f01019ee:	b8 01 00 00 00       	mov    $0x1,%eax
	while (n-- > 0) {
f01019f3:	39 d8                	cmp    %ebx,%eax
f01019f5:	74 1d                	je     f0101a14 <memcmp+0x43>
		if (*s1 != *s2)
f01019f7:	0f b6 14 06          	movzbl (%esi,%eax,1),%edx
f01019fb:	83 c0 01             	add    $0x1,%eax
f01019fe:	0f b6 4c 07 ff       	movzbl -0x1(%edi,%eax,1),%ecx
f0101a03:	38 ca                	cmp    %cl,%dl
f0101a05:	74 ec                	je     f01019f3 <memcmp+0x22>
			return (int) *s1 - (int) *s2;
f0101a07:	0f b6 c2             	movzbl %dl,%eax
f0101a0a:	0f b6 c9             	movzbl %cl,%ecx
f0101a0d:	29 c8                	sub    %ecx,%eax
		s1++, s2++;
	}

	return 0;
}
f0101a0f:	5b                   	pop    %ebx
f0101a10:	5e                   	pop    %esi
f0101a11:	5f                   	pop    %edi
f0101a12:	5d                   	pop    %ebp
f0101a13:	c3                   	ret    
	return 0;
f0101a14:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a19:	eb f4                	jmp    f0101a0f <memcmp+0x3e>
f0101a1b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a20:	eb ed                	jmp    f0101a0f <memcmp+0x3e>

f0101a22 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101a22:	55                   	push   %ebp
f0101a23:	89 e5                	mov    %esp,%ebp
f0101a25:	53                   	push   %ebx
f0101a26:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
f0101a2c:	89 c2                	mov    %eax,%edx
f0101a2e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101a31:	39 d0                	cmp    %edx,%eax
f0101a33:	73 11                	jae    f0101a46 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101a35:	89 d9                	mov    %ebx,%ecx
f0101a37:	38 18                	cmp    %bl,(%eax)
f0101a39:	74 0b                	je     f0101a46 <memfind+0x24>
	for (; s < ends; s++)
f0101a3b:	83 c0 01             	add    $0x1,%eax
f0101a3e:	39 c2                	cmp    %eax,%edx
f0101a40:	74 04                	je     f0101a46 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101a42:	38 08                	cmp    %cl,(%eax)
f0101a44:	75 f5                	jne    f0101a3b <memfind+0x19>
			break;
	return (void *) s;
}
f0101a46:	5b                   	pop    %ebx
f0101a47:	5d                   	pop    %ebp
f0101a48:	c3                   	ret    

f0101a49 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101a49:	55                   	push   %ebp
f0101a4a:	89 e5                	mov    %esp,%ebp
f0101a4c:	57                   	push   %edi
f0101a4d:	56                   	push   %esi
f0101a4e:	53                   	push   %ebx
f0101a4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101a52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101a55:	0f b6 01             	movzbl (%ecx),%eax
f0101a58:	3c 20                	cmp    $0x20,%al
f0101a5a:	74 04                	je     f0101a60 <strtol+0x17>
f0101a5c:	3c 09                	cmp    $0x9,%al
f0101a5e:	75 0e                	jne    f0101a6e <strtol+0x25>
		s++;
f0101a60:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101a63:	0f b6 01             	movzbl (%ecx),%eax
f0101a66:	3c 20                	cmp    $0x20,%al
f0101a68:	74 f6                	je     f0101a60 <strtol+0x17>
f0101a6a:	3c 09                	cmp    $0x9,%al
f0101a6c:	74 f2                	je     f0101a60 <strtol+0x17>

	// plus/minus sign
	if (*s == '+')
f0101a6e:	3c 2b                	cmp    $0x2b,%al
f0101a70:	74 2e                	je     f0101aa0 <strtol+0x57>
	int neg = 0;
f0101a72:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101a77:	3c 2d                	cmp    $0x2d,%al
f0101a79:	74 2f                	je     f0101aaa <strtol+0x61>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101a7b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101a81:	75 05                	jne    f0101a88 <strtol+0x3f>
f0101a83:	80 39 30             	cmpb   $0x30,(%ecx)
f0101a86:	74 2c                	je     f0101ab4 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101a88:	85 db                	test   %ebx,%ebx
f0101a8a:	75 0a                	jne    f0101a96 <strtol+0x4d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101a8c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0101a91:	80 39 30             	cmpb   $0x30,(%ecx)
f0101a94:	74 28                	je     f0101abe <strtol+0x75>
		base = 10;
f0101a96:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a9b:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101a9e:	eb 50                	jmp    f0101af0 <strtol+0xa7>
		s++;
f0101aa0:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0101aa3:	bf 00 00 00 00       	mov    $0x0,%edi
f0101aa8:	eb d1                	jmp    f0101a7b <strtol+0x32>
		s++, neg = 1;
f0101aaa:	83 c1 01             	add    $0x1,%ecx
f0101aad:	bf 01 00 00 00       	mov    $0x1,%edi
f0101ab2:	eb c7                	jmp    f0101a7b <strtol+0x32>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101ab4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101ab8:	74 0e                	je     f0101ac8 <strtol+0x7f>
	else if (base == 0 && s[0] == '0')
f0101aba:	85 db                	test   %ebx,%ebx
f0101abc:	75 d8                	jne    f0101a96 <strtol+0x4d>
		s++, base = 8;
f0101abe:	83 c1 01             	add    $0x1,%ecx
f0101ac1:	bb 08 00 00 00       	mov    $0x8,%ebx
f0101ac6:	eb ce                	jmp    f0101a96 <strtol+0x4d>
		s += 2, base = 16;
f0101ac8:	83 c1 02             	add    $0x2,%ecx
f0101acb:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101ad0:	eb c4                	jmp    f0101a96 <strtol+0x4d>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0101ad2:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101ad5:	89 f3                	mov    %esi,%ebx
f0101ad7:	80 fb 19             	cmp    $0x19,%bl
f0101ada:	77 29                	ja     f0101b05 <strtol+0xbc>
			dig = *s - 'a' + 10;
f0101adc:	0f be d2             	movsbl %dl,%edx
f0101adf:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101ae2:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101ae5:	7d 30                	jge    f0101b17 <strtol+0xce>
			break;
		s++, val = (val * base) + dig;
f0101ae7:	83 c1 01             	add    $0x1,%ecx
f0101aea:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101aee:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101af0:	0f b6 11             	movzbl (%ecx),%edx
f0101af3:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101af6:	89 f3                	mov    %esi,%ebx
f0101af8:	80 fb 09             	cmp    $0x9,%bl
f0101afb:	77 d5                	ja     f0101ad2 <strtol+0x89>
			dig = *s - '0';
f0101afd:	0f be d2             	movsbl %dl,%edx
f0101b00:	83 ea 30             	sub    $0x30,%edx
f0101b03:	eb dd                	jmp    f0101ae2 <strtol+0x99>
		else if (*s >= 'A' && *s <= 'Z')
f0101b05:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101b08:	89 f3                	mov    %esi,%ebx
f0101b0a:	80 fb 19             	cmp    $0x19,%bl
f0101b0d:	77 08                	ja     f0101b17 <strtol+0xce>
			dig = *s - 'A' + 10;
f0101b0f:	0f be d2             	movsbl %dl,%edx
f0101b12:	83 ea 37             	sub    $0x37,%edx
f0101b15:	eb cb                	jmp    f0101ae2 <strtol+0x99>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101b17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101b1b:	74 05                	je     f0101b22 <strtol+0xd9>
		*endptr = (char *) s;
f0101b1d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101b20:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0101b22:	89 c2                	mov    %eax,%edx
f0101b24:	f7 da                	neg    %edx
f0101b26:	85 ff                	test   %edi,%edi
f0101b28:	0f 45 c2             	cmovne %edx,%eax
}
f0101b2b:	5b                   	pop    %ebx
f0101b2c:	5e                   	pop    %esi
f0101b2d:	5f                   	pop    %edi
f0101b2e:	5d                   	pop    %ebp
f0101b2f:	c3                   	ret    

f0101b30 <__udivdi3>:
f0101b30:	55                   	push   %ebp
f0101b31:	57                   	push   %edi
f0101b32:	56                   	push   %esi
f0101b33:	53                   	push   %ebx
f0101b34:	83 ec 1c             	sub    $0x1c,%esp
f0101b37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101b3b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101b3f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101b43:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101b47:	85 d2                	test   %edx,%edx
f0101b49:	75 35                	jne    f0101b80 <__udivdi3+0x50>
f0101b4b:	39 f3                	cmp    %esi,%ebx
f0101b4d:	0f 87 bd 00 00 00    	ja     f0101c10 <__udivdi3+0xe0>
f0101b53:	85 db                	test   %ebx,%ebx
f0101b55:	89 d9                	mov    %ebx,%ecx
f0101b57:	75 0b                	jne    f0101b64 <__udivdi3+0x34>
f0101b59:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b5e:	31 d2                	xor    %edx,%edx
f0101b60:	f7 f3                	div    %ebx
f0101b62:	89 c1                	mov    %eax,%ecx
f0101b64:	31 d2                	xor    %edx,%edx
f0101b66:	89 f0                	mov    %esi,%eax
f0101b68:	f7 f1                	div    %ecx
f0101b6a:	89 c6                	mov    %eax,%esi
f0101b6c:	89 e8                	mov    %ebp,%eax
f0101b6e:	89 f7                	mov    %esi,%edi
f0101b70:	f7 f1                	div    %ecx
f0101b72:	89 fa                	mov    %edi,%edx
f0101b74:	83 c4 1c             	add    $0x1c,%esp
f0101b77:	5b                   	pop    %ebx
f0101b78:	5e                   	pop    %esi
f0101b79:	5f                   	pop    %edi
f0101b7a:	5d                   	pop    %ebp
f0101b7b:	c3                   	ret    
f0101b7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b80:	39 f2                	cmp    %esi,%edx
f0101b82:	77 7c                	ja     f0101c00 <__udivdi3+0xd0>
f0101b84:	0f bd fa             	bsr    %edx,%edi
f0101b87:	83 f7 1f             	xor    $0x1f,%edi
f0101b8a:	0f 84 98 00 00 00    	je     f0101c28 <__udivdi3+0xf8>
f0101b90:	89 f9                	mov    %edi,%ecx
f0101b92:	b8 20 00 00 00       	mov    $0x20,%eax
f0101b97:	29 f8                	sub    %edi,%eax
f0101b99:	d3 e2                	shl    %cl,%edx
f0101b9b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101b9f:	89 c1                	mov    %eax,%ecx
f0101ba1:	89 da                	mov    %ebx,%edx
f0101ba3:	d3 ea                	shr    %cl,%edx
f0101ba5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101ba9:	09 d1                	or     %edx,%ecx
f0101bab:	89 f2                	mov    %esi,%edx
f0101bad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101bb1:	89 f9                	mov    %edi,%ecx
f0101bb3:	d3 e3                	shl    %cl,%ebx
f0101bb5:	89 c1                	mov    %eax,%ecx
f0101bb7:	d3 ea                	shr    %cl,%edx
f0101bb9:	89 f9                	mov    %edi,%ecx
f0101bbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101bbf:	d3 e6                	shl    %cl,%esi
f0101bc1:	89 eb                	mov    %ebp,%ebx
f0101bc3:	89 c1                	mov    %eax,%ecx
f0101bc5:	d3 eb                	shr    %cl,%ebx
f0101bc7:	09 de                	or     %ebx,%esi
f0101bc9:	89 f0                	mov    %esi,%eax
f0101bcb:	f7 74 24 08          	divl   0x8(%esp)
f0101bcf:	89 d6                	mov    %edx,%esi
f0101bd1:	89 c3                	mov    %eax,%ebx
f0101bd3:	f7 64 24 0c          	mull   0xc(%esp)
f0101bd7:	39 d6                	cmp    %edx,%esi
f0101bd9:	72 0c                	jb     f0101be7 <__udivdi3+0xb7>
f0101bdb:	89 f9                	mov    %edi,%ecx
f0101bdd:	d3 e5                	shl    %cl,%ebp
f0101bdf:	39 c5                	cmp    %eax,%ebp
f0101be1:	73 5d                	jae    f0101c40 <__udivdi3+0x110>
f0101be3:	39 d6                	cmp    %edx,%esi
f0101be5:	75 59                	jne    f0101c40 <__udivdi3+0x110>
f0101be7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101bea:	31 ff                	xor    %edi,%edi
f0101bec:	89 fa                	mov    %edi,%edx
f0101bee:	83 c4 1c             	add    $0x1c,%esp
f0101bf1:	5b                   	pop    %ebx
f0101bf2:	5e                   	pop    %esi
f0101bf3:	5f                   	pop    %edi
f0101bf4:	5d                   	pop    %ebp
f0101bf5:	c3                   	ret    
f0101bf6:	8d 76 00             	lea    0x0(%esi),%esi
f0101bf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101c00:	31 ff                	xor    %edi,%edi
f0101c02:	31 c0                	xor    %eax,%eax
f0101c04:	89 fa                	mov    %edi,%edx
f0101c06:	83 c4 1c             	add    $0x1c,%esp
f0101c09:	5b                   	pop    %ebx
f0101c0a:	5e                   	pop    %esi
f0101c0b:	5f                   	pop    %edi
f0101c0c:	5d                   	pop    %ebp
f0101c0d:	c3                   	ret    
f0101c0e:	66 90                	xchg   %ax,%ax
f0101c10:	31 ff                	xor    %edi,%edi
f0101c12:	89 e8                	mov    %ebp,%eax
f0101c14:	89 f2                	mov    %esi,%edx
f0101c16:	f7 f3                	div    %ebx
f0101c18:	89 fa                	mov    %edi,%edx
f0101c1a:	83 c4 1c             	add    $0x1c,%esp
f0101c1d:	5b                   	pop    %ebx
f0101c1e:	5e                   	pop    %esi
f0101c1f:	5f                   	pop    %edi
f0101c20:	5d                   	pop    %ebp
f0101c21:	c3                   	ret    
f0101c22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101c28:	39 f2                	cmp    %esi,%edx
f0101c2a:	72 06                	jb     f0101c32 <__udivdi3+0x102>
f0101c2c:	31 c0                	xor    %eax,%eax
f0101c2e:	39 eb                	cmp    %ebp,%ebx
f0101c30:	77 d2                	ja     f0101c04 <__udivdi3+0xd4>
f0101c32:	b8 01 00 00 00       	mov    $0x1,%eax
f0101c37:	eb cb                	jmp    f0101c04 <__udivdi3+0xd4>
f0101c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101c40:	89 d8                	mov    %ebx,%eax
f0101c42:	31 ff                	xor    %edi,%edi
f0101c44:	eb be                	jmp    f0101c04 <__udivdi3+0xd4>
f0101c46:	66 90                	xchg   %ax,%ax
f0101c48:	66 90                	xchg   %ax,%ax
f0101c4a:	66 90                	xchg   %ax,%ax
f0101c4c:	66 90                	xchg   %ax,%ax
f0101c4e:	66 90                	xchg   %ax,%ax

f0101c50 <__umoddi3>:
f0101c50:	55                   	push   %ebp
f0101c51:	57                   	push   %edi
f0101c52:	56                   	push   %esi
f0101c53:	53                   	push   %ebx
f0101c54:	83 ec 1c             	sub    $0x1c,%esp
f0101c57:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0101c5b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101c5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101c63:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101c67:	85 ed                	test   %ebp,%ebp
f0101c69:	89 f0                	mov    %esi,%eax
f0101c6b:	89 da                	mov    %ebx,%edx
f0101c6d:	75 19                	jne    f0101c88 <__umoddi3+0x38>
f0101c6f:	39 df                	cmp    %ebx,%edi
f0101c71:	0f 86 b1 00 00 00    	jbe    f0101d28 <__umoddi3+0xd8>
f0101c77:	f7 f7                	div    %edi
f0101c79:	89 d0                	mov    %edx,%eax
f0101c7b:	31 d2                	xor    %edx,%edx
f0101c7d:	83 c4 1c             	add    $0x1c,%esp
f0101c80:	5b                   	pop    %ebx
f0101c81:	5e                   	pop    %esi
f0101c82:	5f                   	pop    %edi
f0101c83:	5d                   	pop    %ebp
f0101c84:	c3                   	ret    
f0101c85:	8d 76 00             	lea    0x0(%esi),%esi
f0101c88:	39 dd                	cmp    %ebx,%ebp
f0101c8a:	77 f1                	ja     f0101c7d <__umoddi3+0x2d>
f0101c8c:	0f bd cd             	bsr    %ebp,%ecx
f0101c8f:	83 f1 1f             	xor    $0x1f,%ecx
f0101c92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101c96:	0f 84 b4 00 00 00    	je     f0101d50 <__umoddi3+0x100>
f0101c9c:	b8 20 00 00 00       	mov    $0x20,%eax
f0101ca1:	89 c2                	mov    %eax,%edx
f0101ca3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101ca7:	29 c2                	sub    %eax,%edx
f0101ca9:	89 c1                	mov    %eax,%ecx
f0101cab:	89 f8                	mov    %edi,%eax
f0101cad:	d3 e5                	shl    %cl,%ebp
f0101caf:	89 d1                	mov    %edx,%ecx
f0101cb1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101cb5:	d3 e8                	shr    %cl,%eax
f0101cb7:	09 c5                	or     %eax,%ebp
f0101cb9:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101cbd:	89 c1                	mov    %eax,%ecx
f0101cbf:	d3 e7                	shl    %cl,%edi
f0101cc1:	89 d1                	mov    %edx,%ecx
f0101cc3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101cc7:	89 df                	mov    %ebx,%edi
f0101cc9:	d3 ef                	shr    %cl,%edi
f0101ccb:	89 c1                	mov    %eax,%ecx
f0101ccd:	89 f0                	mov    %esi,%eax
f0101ccf:	d3 e3                	shl    %cl,%ebx
f0101cd1:	89 d1                	mov    %edx,%ecx
f0101cd3:	89 fa                	mov    %edi,%edx
f0101cd5:	d3 e8                	shr    %cl,%eax
f0101cd7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101cdc:	09 d8                	or     %ebx,%eax
f0101cde:	f7 f5                	div    %ebp
f0101ce0:	d3 e6                	shl    %cl,%esi
f0101ce2:	89 d1                	mov    %edx,%ecx
f0101ce4:	f7 64 24 08          	mull   0x8(%esp)
f0101ce8:	39 d1                	cmp    %edx,%ecx
f0101cea:	89 c3                	mov    %eax,%ebx
f0101cec:	89 d7                	mov    %edx,%edi
f0101cee:	72 06                	jb     f0101cf6 <__umoddi3+0xa6>
f0101cf0:	75 0e                	jne    f0101d00 <__umoddi3+0xb0>
f0101cf2:	39 c6                	cmp    %eax,%esi
f0101cf4:	73 0a                	jae    f0101d00 <__umoddi3+0xb0>
f0101cf6:	2b 44 24 08          	sub    0x8(%esp),%eax
f0101cfa:	19 ea                	sbb    %ebp,%edx
f0101cfc:	89 d7                	mov    %edx,%edi
f0101cfe:	89 c3                	mov    %eax,%ebx
f0101d00:	89 ca                	mov    %ecx,%edx
f0101d02:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101d07:	29 de                	sub    %ebx,%esi
f0101d09:	19 fa                	sbb    %edi,%edx
f0101d0b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0101d0f:	89 d0                	mov    %edx,%eax
f0101d11:	d3 e0                	shl    %cl,%eax
f0101d13:	89 d9                	mov    %ebx,%ecx
f0101d15:	d3 ee                	shr    %cl,%esi
f0101d17:	d3 ea                	shr    %cl,%edx
f0101d19:	09 f0                	or     %esi,%eax
f0101d1b:	83 c4 1c             	add    $0x1c,%esp
f0101d1e:	5b                   	pop    %ebx
f0101d1f:	5e                   	pop    %esi
f0101d20:	5f                   	pop    %edi
f0101d21:	5d                   	pop    %ebp
f0101d22:	c3                   	ret    
f0101d23:	90                   	nop
f0101d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101d28:	85 ff                	test   %edi,%edi
f0101d2a:	89 f9                	mov    %edi,%ecx
f0101d2c:	75 0b                	jne    f0101d39 <__umoddi3+0xe9>
f0101d2e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101d33:	31 d2                	xor    %edx,%edx
f0101d35:	f7 f7                	div    %edi
f0101d37:	89 c1                	mov    %eax,%ecx
f0101d39:	89 d8                	mov    %ebx,%eax
f0101d3b:	31 d2                	xor    %edx,%edx
f0101d3d:	f7 f1                	div    %ecx
f0101d3f:	89 f0                	mov    %esi,%eax
f0101d41:	f7 f1                	div    %ecx
f0101d43:	e9 31 ff ff ff       	jmp    f0101c79 <__umoddi3+0x29>
f0101d48:	90                   	nop
f0101d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101d50:	39 dd                	cmp    %ebx,%ebp
f0101d52:	72 08                	jb     f0101d5c <__umoddi3+0x10c>
f0101d54:	39 f7                	cmp    %esi,%edi
f0101d56:	0f 87 21 ff ff ff    	ja     f0101c7d <__umoddi3+0x2d>
f0101d5c:	89 da                	mov    %ebx,%edx
f0101d5e:	89 f0                	mov    %esi,%eax
f0101d60:	29 f8                	sub    %edi,%eax
f0101d62:	19 ea                	sbb    %ebp,%edx
f0101d64:	e9 14 ff ff ff       	jmp    f0101c7d <__umoddi3+0x2d>
