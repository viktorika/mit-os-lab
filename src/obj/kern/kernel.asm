
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
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
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
f0100034:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/pmap.h>
#include <kern/kclock.h>

void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 03 01 00 00       	call   f010014f <__x86.get_pc_thunk.bx>
f010004c:	81 c3 bc 72 01 00    	add    $0x172bc,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c2 60 90 11 f0    	mov    $0xf0119060,%edx
f0100058:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 e1 3c 00 00       	call   f0103d4a <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 37 05 00 00       	call   f01005a5 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 b8 ce fe ff    	lea    -0x13148(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 fe 2e 00 00       	call   f0102f80 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 f7 12 00 00       	call   f010137e <mem_init>
f0100087:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010008a:	83 ec 0c             	sub    $0xc,%esp
f010008d:	6a 00                	push   $0x0
f010008f:	e8 7e 08 00 00       	call   f0100912 <monitor>
f0100094:	83 c4 10             	add    $0x10,%esp
f0100097:	eb f1                	jmp    f010008a <i386_init+0x4a>

f0100099 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100099:	55                   	push   %ebp
f010009a:	89 e5                	mov    %esp,%ebp
f010009c:	57                   	push   %edi
f010009d:	56                   	push   %esi
f010009e:	53                   	push   %ebx
f010009f:	83 ec 0c             	sub    $0xc,%esp
f01000a2:	e8 a8 00 00 00       	call   f010014f <__x86.get_pc_thunk.bx>
f01000a7:	81 c3 61 72 01 00    	add    $0x17261,%ebx
f01000ad:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f01000b0:	c7 c0 c0 96 11 f0    	mov    $0xf01196c0,%eax
f01000b6:	83 38 00             	cmpl   $0x0,(%eax)
f01000b9:	74 0f                	je     f01000ca <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000bb:	83 ec 0c             	sub    $0xc,%esp
f01000be:	6a 00                	push   $0x0
f01000c0:	e8 4d 08 00 00       	call   f0100912 <monitor>
f01000c5:	83 c4 10             	add    $0x10,%esp
f01000c8:	eb f1                	jmp    f01000bb <_panic+0x22>
	panicstr = fmt;
f01000ca:	89 38                	mov    %edi,(%eax)
	__asm __volatile("cli; cld");
f01000cc:	fa                   	cli    
f01000cd:	fc                   	cld    
	va_start(ap, fmt);
f01000ce:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01000d1:	83 ec 04             	sub    $0x4,%esp
f01000d4:	ff 75 0c             	pushl  0xc(%ebp)
f01000d7:	ff 75 08             	pushl  0x8(%ebp)
f01000da:	8d 83 d3 ce fe ff    	lea    -0x1312d(%ebx),%eax
f01000e0:	50                   	push   %eax
f01000e1:	e8 9a 2e 00 00       	call   f0102f80 <cprintf>
	vcprintf(fmt, ap);
f01000e6:	83 c4 08             	add    $0x8,%esp
f01000e9:	56                   	push   %esi
f01000ea:	57                   	push   %edi
f01000eb:	e8 59 2e 00 00       	call   f0102f49 <vcprintf>
	cprintf("\n");
f01000f0:	8d 83 40 d6 fe ff    	lea    -0x129c0(%ebx),%eax
f01000f6:	89 04 24             	mov    %eax,(%esp)
f01000f9:	e8 82 2e 00 00       	call   f0102f80 <cprintf>
f01000fe:	83 c4 10             	add    $0x10,%esp
f0100101:	eb b8                	jmp    f01000bb <_panic+0x22>

f0100103 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100103:	55                   	push   %ebp
f0100104:	89 e5                	mov    %esp,%ebp
f0100106:	56                   	push   %esi
f0100107:	53                   	push   %ebx
f0100108:	e8 42 00 00 00       	call   f010014f <__x86.get_pc_thunk.bx>
f010010d:	81 c3 fb 71 01 00    	add    $0x171fb,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100113:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100116:	83 ec 04             	sub    $0x4,%esp
f0100119:	ff 75 0c             	pushl  0xc(%ebp)
f010011c:	ff 75 08             	pushl  0x8(%ebp)
f010011f:	8d 83 eb ce fe ff    	lea    -0x13115(%ebx),%eax
f0100125:	50                   	push   %eax
f0100126:	e8 55 2e 00 00       	call   f0102f80 <cprintf>
	vcprintf(fmt, ap);
f010012b:	83 c4 08             	add    $0x8,%esp
f010012e:	56                   	push   %esi
f010012f:	ff 75 10             	pushl  0x10(%ebp)
f0100132:	e8 12 2e 00 00       	call   f0102f49 <vcprintf>
	cprintf("\n");
f0100137:	8d 83 40 d6 fe ff    	lea    -0x129c0(%ebx),%eax
f010013d:	89 04 24             	mov    %eax,(%esp)
f0100140:	e8 3b 2e 00 00       	call   f0102f80 <cprintf>
	va_end(ap);
}
f0100145:	83 c4 10             	add    $0x10,%esp
f0100148:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010014b:	5b                   	pop    %ebx
f010014c:	5e                   	pop    %esi
f010014d:	5d                   	pop    %ebp
f010014e:	c3                   	ret    

f010014f <__x86.get_pc_thunk.bx>:
f010014f:	8b 1c 24             	mov    (%esp),%ebx
f0100152:	c3                   	ret    

f0100153 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100153:	55                   	push   %ebp
f0100154:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100156:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010015b:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010015c:	a8 01                	test   $0x1,%al
f010015e:	74 0b                	je     f010016b <serial_proc_data+0x18>
f0100160:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100165:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100166:	0f b6 c0             	movzbl %al,%eax
}
f0100169:	5d                   	pop    %ebp
f010016a:	c3                   	ret    
		return -1;
f010016b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100170:	eb f7                	jmp    f0100169 <serial_proc_data+0x16>

f0100172 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100172:	55                   	push   %ebp
f0100173:	89 e5                	mov    %esp,%ebp
f0100175:	56                   	push   %esi
f0100176:	53                   	push   %ebx
f0100177:	e8 d3 ff ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010017c:	81 c3 8c 71 01 00    	add    $0x1718c,%ebx
f0100182:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f0100184:	ff d6                	call   *%esi
f0100186:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100189:	74 2e                	je     f01001b9 <cons_intr+0x47>
		if (c == 0)
f010018b:	85 c0                	test   %eax,%eax
f010018d:	74 f5                	je     f0100184 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f010018f:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f0100195:	8d 51 01             	lea    0x1(%ecx),%edx
f0100198:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f010019e:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001a5:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001ab:	75 d7                	jne    f0100184 <cons_intr+0x12>
			cons.wpos = 0;
f01001ad:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
f01001b4:	00 00 00 
f01001b7:	eb cb                	jmp    f0100184 <cons_intr+0x12>
	}
}
f01001b9:	5b                   	pop    %ebx
f01001ba:	5e                   	pop    %esi
f01001bb:	5d                   	pop    %ebp
f01001bc:	c3                   	ret    

f01001bd <kbd_proc_data>:
{
f01001bd:	55                   	push   %ebp
f01001be:	89 e5                	mov    %esp,%ebp
f01001c0:	56                   	push   %esi
f01001c1:	53                   	push   %ebx
f01001c2:	e8 88 ff ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01001c7:	81 c3 41 71 01 00    	add    $0x17141,%ebx
f01001cd:	ba 64 00 00 00       	mov    $0x64,%edx
f01001d2:	ec                   	in     (%dx),%al
	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001d3:	a8 01                	test   $0x1,%al
f01001d5:	0f 84 fe 00 00 00    	je     f01002d9 <kbd_proc_data+0x11c>
f01001db:	ba 60 00 00 00       	mov    $0x60,%edx
f01001e0:	ec                   	in     (%dx),%al
f01001e1:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01001e3:	3c e0                	cmp    $0xe0,%al
f01001e5:	0f 84 93 00 00 00    	je     f010027e <kbd_proc_data+0xc1>
	} else if (data & 0x80) {
f01001eb:	84 c0                	test   %al,%al
f01001ed:	0f 88 a0 00 00 00    	js     f0100293 <kbd_proc_data+0xd6>
	} else if (shift & E0ESC) {
f01001f3:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f01001f9:	f6 c1 40             	test   $0x40,%cl
f01001fc:	74 0e                	je     f010020c <kbd_proc_data+0x4f>
		data |= 0x80;
f01001fe:	83 c8 80             	or     $0xffffff80,%eax
f0100201:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100203:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100206:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f010020c:	0f b6 d2             	movzbl %dl,%edx
f010020f:	0f b6 84 13 38 d0 fe 	movzbl -0x12fc8(%ebx,%edx,1),%eax
f0100216:	ff 
f0100217:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f010021d:	0f b6 8c 13 38 cf fe 	movzbl -0x130c8(%ebx,%edx,1),%ecx
f0100224:	ff 
f0100225:	31 c8                	xor    %ecx,%eax
f0100227:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f010022d:	89 c1                	mov    %eax,%ecx
f010022f:	83 e1 03             	and    $0x3,%ecx
f0100232:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f0100239:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010023d:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f0100240:	a8 08                	test   $0x8,%al
f0100242:	74 0d                	je     f0100251 <kbd_proc_data+0x94>
		if ('a' <= c && c <= 'z')
f0100244:	89 f2                	mov    %esi,%edx
f0100246:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100249:	83 f9 19             	cmp    $0x19,%ecx
f010024c:	77 7a                	ja     f01002c8 <kbd_proc_data+0x10b>
			c += 'A' - 'a';
f010024e:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100251:	f7 d0                	not    %eax
f0100253:	a8 06                	test   $0x6,%al
f0100255:	75 33                	jne    f010028a <kbd_proc_data+0xcd>
f0100257:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010025d:	75 2b                	jne    f010028a <kbd_proc_data+0xcd>
		cprintf("Rebooting!\n");
f010025f:	83 ec 0c             	sub    $0xc,%esp
f0100262:	8d 83 05 cf fe ff    	lea    -0x130fb(%ebx),%eax
f0100268:	50                   	push   %eax
f0100269:	e8 12 2d 00 00       	call   f0102f80 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010026e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100273:	ba 92 00 00 00       	mov    $0x92,%edx
f0100278:	ee                   	out    %al,(%dx)
f0100279:	83 c4 10             	add    $0x10,%esp
f010027c:	eb 0c                	jmp    f010028a <kbd_proc_data+0xcd>
		shift |= E0ESC;
f010027e:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f0100285:	be 00 00 00 00       	mov    $0x0,%esi
}
f010028a:	89 f0                	mov    %esi,%eax
f010028c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010028f:	5b                   	pop    %ebx
f0100290:	5e                   	pop    %esi
f0100291:	5d                   	pop    %ebp
f0100292:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100293:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100299:	89 ce                	mov    %ecx,%esi
f010029b:	83 e6 40             	and    $0x40,%esi
f010029e:	83 e0 7f             	and    $0x7f,%eax
f01002a1:	85 f6                	test   %esi,%esi
f01002a3:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002a6:	0f b6 d2             	movzbl %dl,%edx
f01002a9:	0f b6 84 13 38 d0 fe 	movzbl -0x12fc8(%ebx,%edx,1),%eax
f01002b0:	ff 
f01002b1:	83 c8 40             	or     $0x40,%eax
f01002b4:	0f b6 c0             	movzbl %al,%eax
f01002b7:	f7 d0                	not    %eax
f01002b9:	21 c8                	and    %ecx,%eax
f01002bb:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f01002c1:	be 00 00 00 00       	mov    $0x0,%esi
f01002c6:	eb c2                	jmp    f010028a <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f01002c8:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002cb:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002ce:	83 fa 1a             	cmp    $0x1a,%edx
f01002d1:	0f 42 f1             	cmovb  %ecx,%esi
f01002d4:	e9 78 ff ff ff       	jmp    f0100251 <kbd_proc_data+0x94>
		return -1;
f01002d9:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01002de:	eb aa                	jmp    f010028a <kbd_proc_data+0xcd>

f01002e0 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002e0:	55                   	push   %ebp
f01002e1:	89 e5                	mov    %esp,%ebp
f01002e3:	57                   	push   %edi
f01002e4:	56                   	push   %esi
f01002e5:	53                   	push   %ebx
f01002e6:	83 ec 1c             	sub    $0x1c,%esp
f01002e9:	e8 61 fe ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01002ee:	81 c3 1a 70 01 00    	add    $0x1701a,%ebx
f01002f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f7:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002fc:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002fd:	a8 20                	test   $0x20,%al
f01002ff:	75 27                	jne    f0100328 <cons_putc+0x48>
	for (i = 0;
f0100301:	be 00 00 00 00       	mov    $0x0,%esi
f0100306:	b9 84 00 00 00       	mov    $0x84,%ecx
f010030b:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100310:	89 ca                	mov    %ecx,%edx
f0100312:	ec                   	in     (%dx),%al
f0100313:	ec                   	in     (%dx),%al
f0100314:	ec                   	in     (%dx),%al
f0100315:	ec                   	in     (%dx),%al
	     i++)
f0100316:	83 c6 01             	add    $0x1,%esi
f0100319:	89 fa                	mov    %edi,%edx
f010031b:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010031c:	a8 20                	test   $0x20,%al
f010031e:	75 08                	jne    f0100328 <cons_putc+0x48>
f0100320:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100326:	7e e8                	jle    f0100310 <cons_putc+0x30>
	outb(COM1 + COM_TX, c);
f0100328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010032b:	89 f8                	mov    %edi,%eax
f010032d:	88 45 e3             	mov    %al,-0x1d(%ebp)
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100330:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100335:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100336:	ba 79 03 00 00       	mov    $0x379,%edx
f010033b:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010033c:	84 c0                	test   %al,%al
f010033e:	78 27                	js     f0100367 <cons_putc+0x87>
f0100340:	be 00 00 00 00       	mov    $0x0,%esi
f0100345:	b9 84 00 00 00       	mov    $0x84,%ecx
f010034a:	bf 79 03 00 00       	mov    $0x379,%edi
f010034f:	89 ca                	mov    %ecx,%edx
f0100351:	ec                   	in     (%dx),%al
f0100352:	ec                   	in     (%dx),%al
f0100353:	ec                   	in     (%dx),%al
f0100354:	ec                   	in     (%dx),%al
f0100355:	83 c6 01             	add    $0x1,%esi
f0100358:	89 fa                	mov    %edi,%edx
f010035a:	ec                   	in     (%dx),%al
f010035b:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100361:	7f 04                	jg     f0100367 <cons_putc+0x87>
f0100363:	84 c0                	test   %al,%al
f0100365:	79 e8                	jns    f010034f <cons_putc+0x6f>
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100367:	ba 78 03 00 00       	mov    $0x378,%edx
f010036c:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0100370:	ee                   	out    %al,(%dx)
f0100371:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100376:	b8 0d 00 00 00       	mov    $0xd,%eax
f010037b:	ee                   	out    %al,(%dx)
f010037c:	b8 08 00 00 00       	mov    $0x8,%eax
f0100381:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100385:	89 fa                	mov    %edi,%edx
f0100387:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010038d:	89 f8                	mov    %edi,%eax
f010038f:	80 cc 07             	or     $0x7,%ah
f0100392:	85 d2                	test   %edx,%edx
f0100394:	0f 45 c7             	cmovne %edi,%eax
f0100397:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f010039a:	0f b6 c0             	movzbl %al,%eax
f010039d:	83 f8 09             	cmp    $0x9,%eax
f01003a0:	0f 84 b9 00 00 00    	je     f010045f <cons_putc+0x17f>
f01003a6:	83 f8 09             	cmp    $0x9,%eax
f01003a9:	7e 74                	jle    f010041f <cons_putc+0x13f>
f01003ab:	83 f8 0a             	cmp    $0xa,%eax
f01003ae:	0f 84 9e 00 00 00    	je     f0100452 <cons_putc+0x172>
f01003b4:	83 f8 0d             	cmp    $0xd,%eax
f01003b7:	0f 85 d9 00 00 00    	jne    f0100496 <cons_putc+0x1b6>
		crt_pos -= (crt_pos % CRT_COLS);
f01003bd:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f01003c4:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003ca:	c1 e8 16             	shr    $0x16,%eax
f01003cd:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003d0:	c1 e0 04             	shl    $0x4,%eax
f01003d3:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01003da:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f01003e1:	cf 07 
f01003e3:	0f 87 d4 00 00 00    	ja     f01004bd <cons_putc+0x1dd>
	outb(addr_6845, 14);
f01003e9:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f01003ef:	b8 0e 00 00 00       	mov    $0xe,%eax
f01003f4:	89 ca                	mov    %ecx,%edx
f01003f6:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003f7:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f01003fe:	8d 71 01             	lea    0x1(%ecx),%esi
f0100401:	89 d8                	mov    %ebx,%eax
f0100403:	66 c1 e8 08          	shr    $0x8,%ax
f0100407:	89 f2                	mov    %esi,%edx
f0100409:	ee                   	out    %al,(%dx)
f010040a:	b8 0f 00 00 00       	mov    $0xf,%eax
f010040f:	89 ca                	mov    %ecx,%edx
f0100411:	ee                   	out    %al,(%dx)
f0100412:	89 d8                	mov    %ebx,%eax
f0100414:	89 f2                	mov    %esi,%edx
f0100416:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100417:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010041a:	5b                   	pop    %ebx
f010041b:	5e                   	pop    %esi
f010041c:	5f                   	pop    %edi
f010041d:	5d                   	pop    %ebp
f010041e:	c3                   	ret    
	switch (c & 0xff) {
f010041f:	83 f8 08             	cmp    $0x8,%eax
f0100422:	75 72                	jne    f0100496 <cons_putc+0x1b6>
		if (crt_pos > 0) {
f0100424:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010042b:	66 85 c0             	test   %ax,%ax
f010042e:	74 b9                	je     f01003e9 <cons_putc+0x109>
			crt_pos--;
f0100430:	83 e8 01             	sub    $0x1,%eax
f0100433:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010043a:	0f b7 c0             	movzwl %ax,%eax
f010043d:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100441:	b2 00                	mov    $0x0,%dl
f0100443:	83 ca 20             	or     $0x20,%edx
f0100446:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f010044c:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100450:	eb 88                	jmp    f01003da <cons_putc+0xfa>
		crt_pos += CRT_COLS;
f0100452:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f0100459:	50 
f010045a:	e9 5e ff ff ff       	jmp    f01003bd <cons_putc+0xdd>
		cons_putc(' ');
f010045f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100464:	e8 77 fe ff ff       	call   f01002e0 <cons_putc>
		cons_putc(' ');
f0100469:	b8 20 00 00 00       	mov    $0x20,%eax
f010046e:	e8 6d fe ff ff       	call   f01002e0 <cons_putc>
		cons_putc(' ');
f0100473:	b8 20 00 00 00       	mov    $0x20,%eax
f0100478:	e8 63 fe ff ff       	call   f01002e0 <cons_putc>
		cons_putc(' ');
f010047d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100482:	e8 59 fe ff ff       	call   f01002e0 <cons_putc>
		cons_putc(' ');
f0100487:	b8 20 00 00 00       	mov    $0x20,%eax
f010048c:	e8 4f fe ff ff       	call   f01002e0 <cons_putc>
f0100491:	e9 44 ff ff ff       	jmp    f01003da <cons_putc+0xfa>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100496:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010049d:	8d 50 01             	lea    0x1(%eax),%edx
f01004a0:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f01004a7:	0f b7 c0             	movzwl %ax,%eax
f01004aa:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f01004b0:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004b4:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004b8:	e9 1d ff ff ff       	jmp    f01003da <cons_putc+0xfa>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004bd:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f01004c3:	83 ec 04             	sub    $0x4,%esp
f01004c6:	68 00 0f 00 00       	push   $0xf00
f01004cb:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004d1:	52                   	push   %edx
f01004d2:	50                   	push   %eax
f01004d3:	e8 bf 38 00 00       	call   f0103d97 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004d8:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f01004de:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004e4:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004ea:	83 c4 10             	add    $0x10,%esp
f01004ed:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004f2:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004f5:	39 d0                	cmp    %edx,%eax
f01004f7:	75 f4                	jne    f01004ed <cons_putc+0x20d>
		crt_pos -= CRT_COLS;
f01004f9:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f0100500:	50 
f0100501:	e9 e3 fe ff ff       	jmp    f01003e9 <cons_putc+0x109>

f0100506 <serial_intr>:
{
f0100506:	e8 e7 01 00 00       	call   f01006f2 <__x86.get_pc_thunk.ax>
f010050b:	05 fd 6d 01 00       	add    $0x16dfd,%eax
	if (serial_exists)
f0100510:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100517:	75 02                	jne    f010051b <serial_intr+0x15>
f0100519:	f3 c3                	repz ret 
{
f010051b:	55                   	push   %ebp
f010051c:	89 e5                	mov    %esp,%ebp
f010051e:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100521:	8d 80 4b 8e fe ff    	lea    -0x171b5(%eax),%eax
f0100527:	e8 46 fc ff ff       	call   f0100172 <cons_intr>
}
f010052c:	c9                   	leave  
f010052d:	c3                   	ret    

f010052e <kbd_intr>:
{
f010052e:	55                   	push   %ebp
f010052f:	89 e5                	mov    %esp,%ebp
f0100531:	83 ec 08             	sub    $0x8,%esp
f0100534:	e8 b9 01 00 00       	call   f01006f2 <__x86.get_pc_thunk.ax>
f0100539:	05 cf 6d 01 00       	add    $0x16dcf,%eax
	cons_intr(kbd_proc_data);
f010053e:	8d 80 b5 8e fe ff    	lea    -0x1714b(%eax),%eax
f0100544:	e8 29 fc ff ff       	call   f0100172 <cons_intr>
}
f0100549:	c9                   	leave  
f010054a:	c3                   	ret    

f010054b <cons_getc>:
{
f010054b:	55                   	push   %ebp
f010054c:	89 e5                	mov    %esp,%ebp
f010054e:	53                   	push   %ebx
f010054f:	83 ec 04             	sub    $0x4,%esp
f0100552:	e8 f8 fb ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100557:	81 c3 b1 6d 01 00    	add    $0x16db1,%ebx
	serial_intr();
f010055d:	e8 a4 ff ff ff       	call   f0100506 <serial_intr>
	kbd_intr();
f0100562:	e8 c7 ff ff ff       	call   f010052e <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100567:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	return 0;
f010056d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100572:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f0100578:	74 19                	je     f0100593 <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f010057a:	8d 4a 01             	lea    0x1(%edx),%ecx
f010057d:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f0100583:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f010058a:	00 
		if (cons.rpos == CONSBUFSIZE)
f010058b:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100591:	74 06                	je     f0100599 <cons_getc+0x4e>
}
f0100593:	83 c4 04             	add    $0x4,%esp
f0100596:	5b                   	pop    %ebx
f0100597:	5d                   	pop    %ebp
f0100598:	c3                   	ret    
			cons.rpos = 0;
f0100599:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f01005a0:	00 00 00 
f01005a3:	eb ee                	jmp    f0100593 <cons_getc+0x48>

f01005a5 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005a5:	55                   	push   %ebp
f01005a6:	89 e5                	mov    %esp,%ebp
f01005a8:	57                   	push   %edi
f01005a9:	56                   	push   %esi
f01005aa:	53                   	push   %ebx
f01005ab:	83 ec 1c             	sub    $0x1c,%esp
f01005ae:	e8 9c fb ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01005b3:	81 c3 55 6d 01 00    	add    $0x16d55,%ebx
	was = *cp;
f01005b9:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005c0:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005c7:	5a a5 
	if (*cp != 0xA55A) {
f01005c9:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005d0:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005d4:	0f 84 bc 00 00 00    	je     f0100696 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f01005da:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f01005e1:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005e4:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f01005eb:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f01005f1:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005f6:	89 fa                	mov    %edi,%edx
f01005f8:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005f9:	8d 4f 01             	lea    0x1(%edi),%ecx
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005fc:	89 ca                	mov    %ecx,%edx
f01005fe:	ec                   	in     (%dx),%al
f01005ff:	0f b6 f0             	movzbl %al,%esi
f0100602:	c1 e6 08             	shl    $0x8,%esi
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100605:	b8 0f 00 00 00       	mov    $0xf,%eax
f010060a:	89 fa                	mov    %edi,%edx
f010060c:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010060d:	89 ca                	mov    %ecx,%edx
f010060f:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100610:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100613:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100619:	0f b6 c0             	movzbl %al,%eax
f010061c:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010061e:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100625:	b9 00 00 00 00       	mov    $0x0,%ecx
f010062a:	89 c8                	mov    %ecx,%eax
f010062c:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100631:	ee                   	out    %al,(%dx)
f0100632:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100637:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010063c:	89 fa                	mov    %edi,%edx
f010063e:	ee                   	out    %al,(%dx)
f010063f:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100644:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100649:	ee                   	out    %al,(%dx)
f010064a:	be f9 03 00 00       	mov    $0x3f9,%esi
f010064f:	89 c8                	mov    %ecx,%eax
f0100651:	89 f2                	mov    %esi,%edx
f0100653:	ee                   	out    %al,(%dx)
f0100654:	b8 03 00 00 00       	mov    $0x3,%eax
f0100659:	89 fa                	mov    %edi,%edx
f010065b:	ee                   	out    %al,(%dx)
f010065c:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100661:	89 c8                	mov    %ecx,%eax
f0100663:	ee                   	out    %al,(%dx)
f0100664:	b8 01 00 00 00       	mov    $0x1,%eax
f0100669:	89 f2                	mov    %esi,%edx
f010066b:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010066c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100671:	ec                   	in     (%dx),%al
f0100672:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100674:	3c ff                	cmp    $0xff,%al
f0100676:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f010067d:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100682:	ec                   	in     (%dx),%al
f0100683:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100688:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100689:	80 f9 ff             	cmp    $0xff,%cl
f010068c:	74 25                	je     f01006b3 <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f010068e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100691:	5b                   	pop    %ebx
f0100692:	5e                   	pop    %esi
f0100693:	5f                   	pop    %edi
f0100694:	5d                   	pop    %ebp
f0100695:	c3                   	ret    
		*cp = was;
f0100696:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010069d:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f01006a4:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006a7:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f01006ae:	e9 38 ff ff ff       	jmp    f01005eb <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f01006b3:	83 ec 0c             	sub    $0xc,%esp
f01006b6:	8d 83 11 cf fe ff    	lea    -0x130ef(%ebx),%eax
f01006bc:	50                   	push   %eax
f01006bd:	e8 be 28 00 00       	call   f0102f80 <cprintf>
f01006c2:	83 c4 10             	add    $0x10,%esp
}
f01006c5:	eb c7                	jmp    f010068e <cons_init+0xe9>

f01006c7 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006c7:	55                   	push   %ebp
f01006c8:	89 e5                	mov    %esp,%ebp
f01006ca:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01006d0:	e8 0b fc ff ff       	call   f01002e0 <cons_putc>
}
f01006d5:	c9                   	leave  
f01006d6:	c3                   	ret    

f01006d7 <getchar>:

int
getchar(void)
{
f01006d7:	55                   	push   %ebp
f01006d8:	89 e5                	mov    %esp,%ebp
f01006da:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006dd:	e8 69 fe ff ff       	call   f010054b <cons_getc>
f01006e2:	85 c0                	test   %eax,%eax
f01006e4:	74 f7                	je     f01006dd <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006e6:	c9                   	leave  
f01006e7:	c3                   	ret    

f01006e8 <iscons>:

int
iscons(int fdnum)
{
f01006e8:	55                   	push   %ebp
f01006e9:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01006eb:	b8 01 00 00 00       	mov    $0x1,%eax
f01006f0:	5d                   	pop    %ebp
f01006f1:	c3                   	ret    

f01006f2 <__x86.get_pc_thunk.ax>:
f01006f2:	8b 04 24             	mov    (%esp),%eax
f01006f5:	c3                   	ret    

f01006f6 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006f6:	55                   	push   %ebp
f01006f7:	89 e5                	mov    %esp,%ebp
f01006f9:	56                   	push   %esi
f01006fa:	53                   	push   %ebx
f01006fb:	e8 4f fa ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100700:	81 c3 08 6c 01 00    	add    $0x16c08,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100706:	83 ec 04             	sub    $0x4,%esp
f0100709:	8d 83 38 d1 fe ff    	lea    -0x12ec8(%ebx),%eax
f010070f:	50                   	push   %eax
f0100710:	8d 83 56 d1 fe ff    	lea    -0x12eaa(%ebx),%eax
f0100716:	50                   	push   %eax
f0100717:	8d b3 5b d1 fe ff    	lea    -0x12ea5(%ebx),%esi
f010071d:	56                   	push   %esi
f010071e:	e8 5d 28 00 00       	call   f0102f80 <cprintf>
f0100723:	83 c4 0c             	add    $0xc,%esp
f0100726:	8d 83 0c d2 fe ff    	lea    -0x12df4(%ebx),%eax
f010072c:	50                   	push   %eax
f010072d:	8d 83 64 d1 fe ff    	lea    -0x12e9c(%ebx),%eax
f0100733:	50                   	push   %eax
f0100734:	56                   	push   %esi
f0100735:	e8 46 28 00 00       	call   f0102f80 <cprintf>
f010073a:	83 c4 0c             	add    $0xc,%esp
f010073d:	8d 83 34 d2 fe ff    	lea    -0x12dcc(%ebx),%eax
f0100743:	50                   	push   %eax
f0100744:	8d 83 6d d1 fe ff    	lea    -0x12e93(%ebx),%eax
f010074a:	50                   	push   %eax
f010074b:	56                   	push   %esi
f010074c:	e8 2f 28 00 00       	call   f0102f80 <cprintf>
	return 0;
}
f0100751:	b8 00 00 00 00       	mov    $0x0,%eax
f0100756:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100759:	5b                   	pop    %ebx
f010075a:	5e                   	pop    %esi
f010075b:	5d                   	pop    %ebp
f010075c:	c3                   	ret    

f010075d <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010075d:	55                   	push   %ebp
f010075e:	89 e5                	mov    %esp,%ebp
f0100760:	57                   	push   %edi
f0100761:	56                   	push   %esi
f0100762:	53                   	push   %ebx
f0100763:	83 ec 18             	sub    $0x18,%esp
f0100766:	e8 e4 f9 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010076b:	81 c3 9d 6b 01 00    	add    $0x16b9d,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100771:	8d 83 77 d1 fe ff    	lea    -0x12e89(%ebx),%eax
f0100777:	50                   	push   %eax
f0100778:	e8 03 28 00 00       	call   f0102f80 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010077d:	83 c4 08             	add    $0x8,%esp
f0100780:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0100786:	8d 83 68 d2 fe ff    	lea    -0x12d98(%ebx),%eax
f010078c:	50                   	push   %eax
f010078d:	e8 ee 27 00 00       	call   f0102f80 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100792:	83 c4 0c             	add    $0xc,%esp
f0100795:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010079b:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007a1:	50                   	push   %eax
f01007a2:	57                   	push   %edi
f01007a3:	8d 83 90 d2 fe ff    	lea    -0x12d70(%ebx),%eax
f01007a9:	50                   	push   %eax
f01007aa:	e8 d1 27 00 00       	call   f0102f80 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007af:	83 c4 0c             	add    $0xc,%esp
f01007b2:	c7 c0 b9 41 10 f0    	mov    $0xf01041b9,%eax
f01007b8:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007be:	52                   	push   %edx
f01007bf:	50                   	push   %eax
f01007c0:	8d 83 b4 d2 fe ff    	lea    -0x12d4c(%ebx),%eax
f01007c6:	50                   	push   %eax
f01007c7:	e8 b4 27 00 00       	call   f0102f80 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007cc:	83 c4 0c             	add    $0xc,%esp
f01007cf:	c7 c0 60 90 11 f0    	mov    $0xf0119060,%eax
f01007d5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007db:	52                   	push   %edx
f01007dc:	50                   	push   %eax
f01007dd:	8d 83 d8 d2 fe ff    	lea    -0x12d28(%ebx),%eax
f01007e3:	50                   	push   %eax
f01007e4:	e8 97 27 00 00       	call   f0102f80 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007e9:	83 c4 0c             	add    $0xc,%esp
f01007ec:	c7 c6 d0 96 11 f0    	mov    $0xf01196d0,%esi
f01007f2:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01007f8:	50                   	push   %eax
f01007f9:	56                   	push   %esi
f01007fa:	8d 83 fc d2 fe ff    	lea    -0x12d04(%ebx),%eax
f0100800:	50                   	push   %eax
f0100801:	e8 7a 27 00 00       	call   f0102f80 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100806:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100809:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010080f:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100811:	c1 fe 0a             	sar    $0xa,%esi
f0100814:	56                   	push   %esi
f0100815:	8d 83 20 d3 fe ff    	lea    -0x12ce0(%ebx),%eax
f010081b:	50                   	push   %eax
f010081c:	e8 5f 27 00 00       	call   f0102f80 <cprintf>
	return 0;
}
f0100821:	b8 00 00 00 00       	mov    $0x0,%eax
f0100826:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100829:	5b                   	pop    %ebx
f010082a:	5e                   	pop    %esi
f010082b:	5f                   	pop    %edi
f010082c:	5d                   	pop    %ebp
f010082d:	c3                   	ret    

f010082e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010082e:	55                   	push   %ebp
f010082f:	89 e5                	mov    %esp,%ebp
f0100831:	57                   	push   %edi
f0100832:	56                   	push   %esi
f0100833:	53                   	push   %ebx
f0100834:	83 ec 58             	sub    $0x58,%esp
f0100837:	e8 13 f9 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010083c:	81 c3 cc 6a 01 00    	add    $0x16acc,%ebx
	cprintf("Stack backtrace:\n");
f0100842:	8d 83 90 d1 fe ff    	lea    -0x12e70(%ebx),%eax
f0100848:	50                   	push   %eax
f0100849:	e8 32 27 00 00       	call   f0102f80 <cprintf>

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010084e:	89 e8                	mov    %ebp,%eax
    unsigned int ebp, esp, eip;
    ebp = read_ebp(); 
    while(ebp){
f0100850:	83 c4 10             	add    $0x10,%esp
f0100853:	85 c0                	test   %eax,%eax
f0100855:	0f 84 aa 00 00 00    	je     f0100905 <mon_backtrace+0xd7>
f010085b:	89 c7                	mov    %eax,%edi
        eip = *(unsigned int *)(ebp + 4);
        esp = ebp + 4;
        cprintf("ebp %08x eip %08x args", ebp, eip);
f010085d:	8d 83 a2 d1 fe ff    	lea    -0x12e5e(%ebx),%eax
f0100863:	89 45 b8             	mov    %eax,-0x48(%ebp)
        for(int i = 0; i < 5; ++i){
            esp += 4;
            cprintf(" %08x", *(unsigned int *)esp);
f0100866:	8d 83 b9 d1 fe ff    	lea    -0x12e47(%ebx),%eax
f010086c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f010086f:	eb 54                	jmp    f01008c5 <mon_backtrace+0x97>
f0100871:	8b 7d bc             	mov    -0x44(%ebp),%edi
        }   
        cprintf("\n");
f0100874:	83 ec 0c             	sub    $0xc,%esp
f0100877:	8d 83 40 d6 fe ff    	lea    -0x129c0(%ebx),%eax
f010087d:	50                   	push   %eax
f010087e:	e8 fd 26 00 00       	call   f0102f80 <cprintf>
        struct Eipdebuginfo info;
		if (-1 == debuginfo_eip(eip, &info))
f0100883:	83 c4 08             	add    $0x8,%esp
f0100886:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100889:	50                   	push   %eax
f010088a:	8b 75 c0             	mov    -0x40(%ebp),%esi
f010088d:	56                   	push   %esi
f010088e:	e8 20 28 00 00       	call   f01030b3 <debuginfo_eip>
f0100893:	83 c4 10             	add    $0x10,%esp
f0100896:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100899:	74 6a                	je     f0100905 <mon_backtrace+0xd7>
			break;
        cprintf("%s:%d: %.*s+%u\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
f010089b:	83 ec 08             	sub    $0x8,%esp
f010089e:	89 f0                	mov    %esi,%eax
f01008a0:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008a3:	50                   	push   %eax
f01008a4:	ff 75 d8             	pushl  -0x28(%ebp)
f01008a7:	ff 75 dc             	pushl  -0x24(%ebp)
f01008aa:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008ad:	ff 75 d0             	pushl  -0x30(%ebp)
f01008b0:	8d 83 bf d1 fe ff    	lea    -0x12e41(%ebx),%eax
f01008b6:	50                   	push   %eax
f01008b7:	e8 c4 26 00 00       	call   f0102f80 <cprintf>
        ebp = *(unsigned int *)ebp;
f01008bc:	8b 3f                	mov    (%edi),%edi
    while(ebp){
f01008be:	83 c4 20             	add    $0x20,%esp
f01008c1:	85 ff                	test   %edi,%edi
f01008c3:	74 40                	je     f0100905 <mon_backtrace+0xd7>
        eip = *(unsigned int *)(ebp + 4);
f01008c5:	8d 77 04             	lea    0x4(%edi),%esi
f01008c8:	8b 47 04             	mov    0x4(%edi),%eax
f01008cb:	89 45 c0             	mov    %eax,-0x40(%ebp)
        cprintf("ebp %08x eip %08x args", ebp, eip);
f01008ce:	83 ec 04             	sub    $0x4,%esp
f01008d1:	50                   	push   %eax
f01008d2:	57                   	push   %edi
f01008d3:	ff 75 b8             	pushl  -0x48(%ebp)
f01008d6:	e8 a5 26 00 00       	call   f0102f80 <cprintf>
f01008db:	8d 47 18             	lea    0x18(%edi),%eax
f01008de:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01008e1:	83 c4 10             	add    $0x10,%esp
f01008e4:	89 7d bc             	mov    %edi,-0x44(%ebp)
f01008e7:	8b 7d b4             	mov    -0x4c(%ebp),%edi
            esp += 4;
f01008ea:	83 c6 04             	add    $0x4,%esi
            cprintf(" %08x", *(unsigned int *)esp);
f01008ed:	83 ec 08             	sub    $0x8,%esp
f01008f0:	ff 36                	pushl  (%esi)
f01008f2:	57                   	push   %edi
f01008f3:	e8 88 26 00 00       	call   f0102f80 <cprintf>
        for(int i = 0; i < 5; ++i){
f01008f8:	83 c4 10             	add    $0x10,%esp
f01008fb:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f01008fe:	75 ea                	jne    f01008ea <mon_backtrace+0xbc>
f0100900:	e9 6c ff ff ff       	jmp    f0100871 <mon_backtrace+0x43>
    }   
	return 0;
}
f0100905:	b8 00 00 00 00       	mov    $0x0,%eax
f010090a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010090d:	5b                   	pop    %ebx
f010090e:	5e                   	pop    %esi
f010090f:	5f                   	pop    %edi
f0100910:	5d                   	pop    %ebp
f0100911:	c3                   	ret    

f0100912 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100912:	55                   	push   %ebp
f0100913:	89 e5                	mov    %esp,%ebp
f0100915:	57                   	push   %edi
f0100916:	56                   	push   %esi
f0100917:	53                   	push   %ebx
f0100918:	83 ec 68             	sub    $0x68,%esp
f010091b:	e8 2f f8 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100920:	81 c3 e8 69 01 00    	add    $0x169e8,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100926:	8d 83 4c d3 fe ff    	lea    -0x12cb4(%ebx),%eax
f010092c:	50                   	push   %eax
f010092d:	e8 4e 26 00 00       	call   f0102f80 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100932:	8d 83 70 d3 fe ff    	lea    -0x12c90(%ebx),%eax
f0100938:	89 04 24             	mov    %eax,(%esp)
f010093b:	e8 40 26 00 00       	call   f0102f80 <cprintf>
f0100940:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100943:	8d bb d3 d1 fe ff    	lea    -0x12e2d(%ebx),%edi
f0100949:	e9 ce 00 00 00       	jmp    f0100a1c <monitor+0x10a>
f010094e:	83 ec 08             	sub    $0x8,%esp
f0100951:	0f be c0             	movsbl %al,%eax
f0100954:	50                   	push   %eax
f0100955:	57                   	push   %edi
f0100956:	e8 91 33 00 00       	call   f0103cec <strchr>
f010095b:	83 c4 10             	add    $0x10,%esp
f010095e:	85 c0                	test   %eax,%eax
f0100960:	74 08                	je     f010096a <monitor+0x58>
			*buf++ = 0;
f0100962:	c6 06 00             	movb   $0x0,(%esi)
f0100965:	8d 76 01             	lea    0x1(%esi),%esi
f0100968:	eb 41                	jmp    f01009ab <monitor+0x99>
		if (*buf == 0)
f010096a:	80 3e 00             	cmpb   $0x0,(%esi)
f010096d:	74 43                	je     f01009b2 <monitor+0xa0>
		if (argc == MAXARGS-1) {
f010096f:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f0100973:	0f 84 8f 00 00 00    	je     f0100a08 <monitor+0xf6>
		argv[argc++] = buf;
f0100979:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010097c:	8d 48 01             	lea    0x1(%eax),%ecx
f010097f:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100982:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100986:	0f b6 06             	movzbl (%esi),%eax
f0100989:	84 c0                	test   %al,%al
f010098b:	74 1e                	je     f01009ab <monitor+0x99>
f010098d:	83 ec 08             	sub    $0x8,%esp
f0100990:	0f be c0             	movsbl %al,%eax
f0100993:	50                   	push   %eax
f0100994:	57                   	push   %edi
f0100995:	e8 52 33 00 00       	call   f0103cec <strchr>
f010099a:	83 c4 10             	add    $0x10,%esp
f010099d:	85 c0                	test   %eax,%eax
f010099f:	75 0a                	jne    f01009ab <monitor+0x99>
			buf++;
f01009a1:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009a4:	0f b6 06             	movzbl (%esi),%eax
f01009a7:	84 c0                	test   %al,%al
f01009a9:	75 e2                	jne    f010098d <monitor+0x7b>
		while (*buf && strchr(WHITESPACE, *buf))
f01009ab:	0f b6 06             	movzbl (%esi),%eax
f01009ae:	84 c0                	test   %al,%al
f01009b0:	75 9c                	jne    f010094e <monitor+0x3c>
	argv[argc] = 0;
f01009b2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009b5:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f01009bc:	00 
	if (argc == 0)
f01009bd:	85 c0                	test   %eax,%eax
f01009bf:	74 5b                	je     f0100a1c <monitor+0x10a>
f01009c1:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < NCOMMANDS; i++) {
f01009c7:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%ebp)
		if (strcmp(argv[0], commands[i].name) == 0)
f01009ce:	83 ec 08             	sub    $0x8,%esp
f01009d1:	ff 36                	pushl  (%esi)
f01009d3:	ff 75 a8             	pushl  -0x58(%ebp)
f01009d6:	e8 96 32 00 00       	call   f0103c71 <strcmp>
f01009db:	83 c4 10             	add    $0x10,%esp
f01009de:	85 c0                	test   %eax,%eax
f01009e0:	74 6a                	je     f0100a4c <monitor+0x13a>
	for (i = 0; i < NCOMMANDS; i++) {
f01009e2:	83 45 a0 01          	addl   $0x1,-0x60(%ebp)
f01009e6:	8b 45 a0             	mov    -0x60(%ebp),%eax
f01009e9:	83 c6 0c             	add    $0xc,%esi
f01009ec:	83 f8 03             	cmp    $0x3,%eax
f01009ef:	75 dd                	jne    f01009ce <monitor+0xbc>
	cprintf("Unknown command '%s'\n", argv[0]);
f01009f1:	83 ec 08             	sub    $0x8,%esp
f01009f4:	ff 75 a8             	pushl  -0x58(%ebp)
f01009f7:	8d 83 f5 d1 fe ff    	lea    -0x12e0b(%ebx),%eax
f01009fd:	50                   	push   %eax
f01009fe:	e8 7d 25 00 00       	call   f0102f80 <cprintf>
f0100a03:	83 c4 10             	add    $0x10,%esp
f0100a06:	eb 14                	jmp    f0100a1c <monitor+0x10a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a08:	83 ec 08             	sub    $0x8,%esp
f0100a0b:	6a 10                	push   $0x10
f0100a0d:	8d 83 d8 d1 fe ff    	lea    -0x12e28(%ebx),%eax
f0100a13:	50                   	push   %eax
f0100a14:	e8 67 25 00 00       	call   f0102f80 <cprintf>
f0100a19:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100a1c:	8d 83 cf d1 fe ff    	lea    -0x12e31(%ebx),%eax
f0100a22:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100a25:	83 ec 0c             	sub    $0xc,%esp
f0100a28:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a2b:	e8 36 30 00 00       	call   f0103a66 <readline>
f0100a30:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100a32:	83 c4 10             	add    $0x10,%esp
f0100a35:	85 c0                	test   %eax,%eax
f0100a37:	74 ec                	je     f0100a25 <monitor+0x113>
	argv[argc] = 0;
f0100a39:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a40:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100a47:	e9 5f ff ff ff       	jmp    f01009ab <monitor+0x99>
			return commands[i].func(argc, argv, tf);
f0100a4c:	83 ec 04             	sub    $0x4,%esp
f0100a4f:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0100a52:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a55:	ff 75 08             	pushl  0x8(%ebp)
f0100a58:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a5b:	52                   	push   %edx
f0100a5c:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a5f:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a66:	83 c4 10             	add    $0x10,%esp
f0100a69:	85 c0                	test   %eax,%eax
f0100a6b:	79 af                	jns    f0100a1c <monitor+0x10a>
				break;
	}
}
f0100a6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a70:	5b                   	pop    %ebx
f0100a71:	5e                   	pop    %esi
f0100a72:	5f                   	pop    %edi
f0100a73:	5d                   	pop    %ebp
f0100a74:	c3                   	ret    

f0100a75 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a75:	55                   	push   %ebp
f0100a76:	89 e5                	mov    %esp,%ebp
f0100a78:	56                   	push   %esi
f0100a79:	53                   	push   %ebx
f0100a7a:	e8 72 24 00 00       	call   f0102ef1 <__x86.get_pc_thunk.cx>
f0100a7f:	81 c1 89 68 01 00    	add    $0x16889,%ecx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a85:	83 b9 90 1f 00 00 00 	cmpl   $0x0,0x1f90(%ecx)
f0100a8c:	74 39                	je     f0100ac7 <boot_alloc+0x52>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if((unsigned)nextfree + n > KERNBASE + npages * PGSIZE)
f0100a8e:	8b 99 90 1f 00 00    	mov    0x1f90(%ecx),%ebx
f0100a94:	8d 34 03             	lea    (%ebx,%eax,1),%esi
f0100a97:	c7 c2 c4 96 11 f0    	mov    $0xf01196c4,%edx
f0100a9d:	8b 12                	mov    (%edx),%edx
f0100a9f:	81 c2 00 00 0f 00    	add    $0xf0000,%edx
f0100aa5:	c1 e2 0c             	shl    $0xc,%edx
f0100aa8:	39 d6                	cmp    %edx,%esi
f0100aaa:	77 35                	ja     f0100ae1 <boot_alloc+0x6c>
    	panic("boot_alloc: out of memory\n");
	result = nextfree;
	nextfree = ROUNDUP((char *)(nextfree + n), PGSIZE);
f0100aac:	8d 84 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%eax
f0100ab3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ab8:	89 81 90 1f 00 00    	mov    %eax,0x1f90(%ecx)
	return result;
}
f0100abe:	89 d8                	mov    %ebx,%eax
f0100ac0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ac3:	5b                   	pop    %ebx
f0100ac4:	5e                   	pop    %esi
f0100ac5:	5d                   	pop    %ebp
f0100ac6:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ac7:	c7 c2 d0 96 11 f0    	mov    $0xf01196d0,%edx
f0100acd:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100ad3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ad9:	89 91 90 1f 00 00    	mov    %edx,0x1f90(%ecx)
f0100adf:	eb ad                	jmp    f0100a8e <boot_alloc+0x19>
    	panic("boot_alloc: out of memory\n");
f0100ae1:	83 ec 04             	sub    $0x4,%esp
f0100ae4:	8d 81 95 d3 fe ff    	lea    -0x12c6b(%ecx),%eax
f0100aea:	50                   	push   %eax
f0100aeb:	6a 66                	push   $0x66
f0100aed:	8d 81 b0 d3 fe ff    	lea    -0x12c50(%ecx),%eax
f0100af3:	50                   	push   %eax
f0100af4:	89 cb                	mov    %ecx,%ebx
f0100af6:	e8 9e f5 ff ff       	call   f0100099 <_panic>

f0100afb <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100afb:	55                   	push   %ebp
f0100afc:	89 e5                	mov    %esp,%ebp
f0100afe:	56                   	push   %esi
f0100aff:	53                   	push   %ebx
f0100b00:	e8 ec 23 00 00       	call   f0102ef1 <__x86.get_pc_thunk.cx>
f0100b05:	81 c1 03 68 01 00    	add    $0x16803,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b0b:	89 d3                	mov    %edx,%ebx
f0100b0d:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f0100b10:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100b13:	a8 01                	test   $0x1,%al
f0100b15:	74 5a                	je     f0100b71 <check_va2pa+0x76>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b17:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b1c:	89 c6                	mov    %eax,%esi
f0100b1e:	c1 ee 0c             	shr    $0xc,%esi
f0100b21:	c7 c3 c4 96 11 f0    	mov    $0xf01196c4,%ebx
f0100b27:	3b 33                	cmp    (%ebx),%esi
f0100b29:	73 2b                	jae    f0100b56 <check_va2pa+0x5b>
	if (!(p[PTX(va)] & PTE_P))
f0100b2b:	c1 ea 0c             	shr    $0xc,%edx
f0100b2e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b34:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b3b:	89 c2                	mov    %eax,%edx
f0100b3d:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b45:	85 d2                	test   %edx,%edx
f0100b47:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b4c:	0f 44 c2             	cmove  %edx,%eax
}
f0100b4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b52:	5b                   	pop    %ebx
f0100b53:	5e                   	pop    %esi
f0100b54:	5d                   	pop    %ebp
f0100b55:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b56:	50                   	push   %eax
f0100b57:	8d 81 74 d6 fe ff    	lea    -0x1298c(%ecx),%eax
f0100b5d:	50                   	push   %eax
f0100b5e:	68 d2 02 00 00       	push   $0x2d2
f0100b63:	8d 81 b0 d3 fe ff    	lea    -0x12c50(%ecx),%eax
f0100b69:	50                   	push   %eax
f0100b6a:	89 cb                	mov    %ecx,%ebx
f0100b6c:	e8 28 f5 ff ff       	call   f0100099 <_panic>
		return ~0;
f0100b71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b76:	eb d7                	jmp    f0100b4f <check_va2pa+0x54>

f0100b78 <check_page_free_list>:
{
f0100b78:	55                   	push   %ebp
f0100b79:	89 e5                	mov    %esp,%ebp
f0100b7b:	57                   	push   %edi
f0100b7c:	56                   	push   %esi
f0100b7d:	53                   	push   %ebx
f0100b7e:	83 ec 3c             	sub    $0x3c,%esp
f0100b81:	e8 6f 23 00 00       	call   f0102ef5 <__x86.get_pc_thunk.di>
f0100b86:	81 c7 82 67 01 00    	add    $0x16782,%edi
f0100b8c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b8f:	84 c0                	test   %al,%al
f0100b91:	0f 85 0e 03 00 00    	jne    f0100ea5 <check_page_free_list+0x32d>
	if (!page_free_list)
f0100b97:	8b b7 94 1f 00 00    	mov    0x1f94(%edi),%esi
f0100b9d:	85 f6                	test   %esi,%esi
f0100b9f:	74 1b                	je     f0100bbc <check_page_free_list+0x44>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ba1:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ba8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100bab:	c7 c7 cc 96 11 f0    	mov    $0xf01196cc,%edi
	if (PGNUM(pa) >= npages)
f0100bb1:	c7 c0 c4 96 11 f0    	mov    $0xf01196c4,%eax
f0100bb7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100bba:	eb 3d                	jmp    f0100bf9 <check_page_free_list+0x81>
		panic("'page_free_list' is a null pointer!");
f0100bbc:	83 ec 04             	sub    $0x4,%esp
f0100bbf:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100bc2:	8d 83 98 d6 fe ff    	lea    -0x12968(%ebx),%eax
f0100bc8:	50                   	push   %eax
f0100bc9:	68 16 02 00 00       	push   $0x216
f0100bce:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0100bd4:	50                   	push   %eax
f0100bd5:	e8 bf f4 ff ff       	call   f0100099 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bda:	50                   	push   %eax
f0100bdb:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100bde:	8d 83 74 d6 fe ff    	lea    -0x1298c(%ebx),%eax
f0100be4:	50                   	push   %eax
f0100be5:	6a 52                	push   $0x52
f0100be7:	8d 83 bc d3 fe ff    	lea    -0x12c44(%ebx),%eax
f0100bed:	50                   	push   %eax
f0100bee:	e8 a6 f4 ff ff       	call   f0100099 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bf3:	8b 36                	mov    (%esi),%esi
f0100bf5:	85 f6                	test   %esi,%esi
f0100bf7:	74 40                	je     f0100c39 <check_page_free_list+0xc1>
	return (pp - pages) << PGSHIFT;
f0100bf9:	89 f0                	mov    %esi,%eax
f0100bfb:	2b 07                	sub    (%edi),%eax
f0100bfd:	c1 f8 03             	sar    $0x3,%eax
f0100c00:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c03:	89 c2                	mov    %eax,%edx
f0100c05:	c1 ea 16             	shr    $0x16,%edx
f0100c08:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c0b:	73 e6                	jae    f0100bf3 <check_page_free_list+0x7b>
	if (PGNUM(pa) >= npages)
f0100c0d:	89 c2                	mov    %eax,%edx
f0100c0f:	c1 ea 0c             	shr    $0xc,%edx
f0100c12:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100c15:	3b 11                	cmp    (%ecx),%edx
f0100c17:	73 c1                	jae    f0100bda <check_page_free_list+0x62>
			memset(page2kva(pp), 0x97, 128);
f0100c19:	83 ec 04             	sub    $0x4,%esp
f0100c1c:	68 80 00 00 00       	push   $0x80
f0100c21:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c26:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c2b:	50                   	push   %eax
f0100c2c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c2f:	e8 16 31 00 00       	call   f0103d4a <memset>
f0100c34:	83 c4 10             	add    $0x10,%esp
f0100c37:	eb ba                	jmp    f0100bf3 <check_page_free_list+0x7b>
	first_free_page = (char *) boot_alloc(0);
f0100c39:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c3e:	e8 32 fe ff ff       	call   f0100a75 <boot_alloc>
f0100c43:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c46:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100c49:	8b 97 94 1f 00 00    	mov    0x1f94(%edi),%edx
f0100c4f:	85 d2                	test   %edx,%edx
f0100c51:	0f 84 0a 02 00 00    	je     f0100e61 <check_page_free_list+0x2e9>
		assert(pp >= pages);
f0100c57:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0100c5d:	8b 08                	mov    (%eax),%ecx
f0100c5f:	39 ca                	cmp    %ecx,%edx
f0100c61:	72 48                	jb     f0100cab <check_page_free_list+0x133>
		assert(pp < pages + npages);
f0100c63:	c7 c0 c4 96 11 f0    	mov    $0xf01196c4,%eax
f0100c69:	8b 00                	mov    (%eax),%eax
f0100c6b:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c6e:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
f0100c71:	39 da                	cmp    %ebx,%edx
f0100c73:	73 58                	jae    f0100ccd <check_page_free_list+0x155>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c75:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100c78:	89 d0                	mov    %edx,%eax
f0100c7a:	29 c8                	sub    %ecx,%eax
f0100c7c:	a8 07                	test   $0x7,%al
f0100c7e:	75 6f                	jne    f0100cef <check_page_free_list+0x177>
	return (pp - pages) << PGSHIFT;
f0100c80:	c1 f8 03             	sar    $0x3,%eax
f0100c83:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100c86:	85 c0                	test   %eax,%eax
f0100c88:	0f 84 83 00 00 00    	je     f0100d11 <check_page_free_list+0x199>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c8e:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c93:	0f 84 9a 00 00 00    	je     f0100d33 <check_page_free_list+0x1bb>
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c99:	be 00 00 00 00       	mov    $0x0,%esi
f0100c9e:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ca3:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0100ca6:	e9 46 01 00 00       	jmp    f0100df1 <check_page_free_list+0x279>
		assert(pp >= pages);
f0100cab:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cae:	8d 83 ca d3 fe ff    	lea    -0x12c36(%ebx),%eax
f0100cb4:	50                   	push   %eax
f0100cb5:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0100cbb:	50                   	push   %eax
f0100cbc:	68 30 02 00 00       	push   $0x230
f0100cc1:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0100cc7:	50                   	push   %eax
f0100cc8:	e8 cc f3 ff ff       	call   f0100099 <_panic>
		assert(pp < pages + npages);
f0100ccd:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cd0:	8d 83 eb d3 fe ff    	lea    -0x12c15(%ebx),%eax
f0100cd6:	50                   	push   %eax
f0100cd7:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0100cdd:	50                   	push   %eax
f0100cde:	68 31 02 00 00       	push   $0x231
f0100ce3:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0100ce9:	50                   	push   %eax
f0100cea:	e8 aa f3 ff ff       	call   f0100099 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cef:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cf2:	8d 83 bc d6 fe ff    	lea    -0x12944(%ebx),%eax
f0100cf8:	50                   	push   %eax
f0100cf9:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0100cff:	50                   	push   %eax
f0100d00:	68 32 02 00 00       	push   $0x232
f0100d05:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0100d0b:	50                   	push   %eax
f0100d0c:	e8 88 f3 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != 0);
f0100d11:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d14:	8d 83 ff d3 fe ff    	lea    -0x12c01(%ebx),%eax
f0100d1a:	50                   	push   %eax
f0100d1b:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0100d21:	50                   	push   %eax
f0100d22:	68 35 02 00 00       	push   $0x235
f0100d27:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0100d2d:	50                   	push   %eax
f0100d2e:	e8 66 f3 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d33:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d36:	8d 83 10 d4 fe ff    	lea    -0x12bf0(%ebx),%eax
f0100d3c:	50                   	push   %eax
f0100d3d:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0100d43:	50                   	push   %eax
f0100d44:	68 36 02 00 00       	push   $0x236
f0100d49:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0100d4f:	50                   	push   %eax
f0100d50:	e8 44 f3 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d55:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d58:	8d 83 f0 d6 fe ff    	lea    -0x12910(%ebx),%eax
f0100d5e:	50                   	push   %eax
f0100d5f:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0100d65:	50                   	push   %eax
f0100d66:	68 37 02 00 00       	push   $0x237
f0100d6b:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0100d71:	50                   	push   %eax
f0100d72:	e8 22 f3 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d77:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d7a:	8d 83 29 d4 fe ff    	lea    -0x12bd7(%ebx),%eax
f0100d80:	50                   	push   %eax
f0100d81:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0100d87:	50                   	push   %eax
f0100d88:	68 38 02 00 00       	push   $0x238
f0100d8d:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0100d93:	50                   	push   %eax
f0100d94:	e8 00 f3 ff ff       	call   f0100099 <_panic>
	if (PGNUM(pa) >= npages)
f0100d99:	89 c6                	mov    %eax,%esi
f0100d9b:	c1 ee 0c             	shr    $0xc,%esi
f0100d9e:	39 75 c8             	cmp    %esi,-0x38(%ebp)
f0100da1:	76 70                	jbe    f0100e13 <check_page_free_list+0x29b>
	return (void *)(pa + KERNBASE);
f0100da3:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100da8:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100dab:	77 7f                	ja     f0100e2c <check_page_free_list+0x2b4>
			++nfree_extmem;
f0100dad:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100db1:	8b 12                	mov    (%edx),%edx
f0100db3:	85 d2                	test   %edx,%edx
f0100db5:	0f 84 93 00 00 00    	je     f0100e4e <check_page_free_list+0x2d6>
		assert(pp >= pages);
f0100dbb:	39 ca                	cmp    %ecx,%edx
f0100dbd:	0f 82 e8 fe ff ff    	jb     f0100cab <check_page_free_list+0x133>
		assert(pp < pages + npages);
f0100dc3:	39 da                	cmp    %ebx,%edx
f0100dc5:	0f 83 02 ff ff ff    	jae    f0100ccd <check_page_free_list+0x155>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100dcb:	89 d0                	mov    %edx,%eax
f0100dcd:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100dd0:	a8 07                	test   $0x7,%al
f0100dd2:	0f 85 17 ff ff ff    	jne    f0100cef <check_page_free_list+0x177>
	return (pp - pages) << PGSHIFT;
f0100dd8:	c1 f8 03             	sar    $0x3,%eax
f0100ddb:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100dde:	85 c0                	test   %eax,%eax
f0100de0:	0f 84 2b ff ff ff    	je     f0100d11 <check_page_free_list+0x199>
		assert(page2pa(pp) != IOPHYSMEM);
f0100de6:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100deb:	0f 84 42 ff ff ff    	je     f0100d33 <check_page_free_list+0x1bb>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100df1:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100df6:	0f 84 59 ff ff ff    	je     f0100d55 <check_page_free_list+0x1dd>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100dfc:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e01:	0f 84 70 ff ff ff    	je     f0100d77 <check_page_free_list+0x1ff>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e07:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e0c:	77 8b                	ja     f0100d99 <check_page_free_list+0x221>
			++nfree_basemem;
f0100e0e:	83 c7 01             	add    $0x1,%edi
f0100e11:	eb 9e                	jmp    f0100db1 <check_page_free_list+0x239>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e13:	50                   	push   %eax
f0100e14:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e17:	8d 83 74 d6 fe ff    	lea    -0x1298c(%ebx),%eax
f0100e1d:	50                   	push   %eax
f0100e1e:	6a 52                	push   $0x52
f0100e20:	8d 83 bc d3 fe ff    	lea    -0x12c44(%ebx),%eax
f0100e26:	50                   	push   %eax
f0100e27:	e8 6d f2 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e2c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e2f:	8d 83 14 d7 fe ff    	lea    -0x128ec(%ebx),%eax
f0100e35:	50                   	push   %eax
f0100e36:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0100e3c:	50                   	push   %eax
f0100e3d:	68 39 02 00 00       	push   $0x239
f0100e42:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0100e48:	50                   	push   %eax
f0100e49:	e8 4b f2 ff ff       	call   f0100099 <_panic>
f0100e4e:	8b 75 d0             	mov    -0x30(%ebp),%esi
	assert(nfree_basemem > 0);
f0100e51:	85 ff                	test   %edi,%edi
f0100e53:	7e 0c                	jle    f0100e61 <check_page_free_list+0x2e9>
	assert(nfree_extmem > 0);
f0100e55:	85 f6                	test   %esi,%esi
f0100e57:	7e 2a                	jle    f0100e83 <check_page_free_list+0x30b>
}
f0100e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e5c:	5b                   	pop    %ebx
f0100e5d:	5e                   	pop    %esi
f0100e5e:	5f                   	pop    %edi
f0100e5f:	5d                   	pop    %ebp
f0100e60:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e61:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e64:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0100e6a:	50                   	push   %eax
f0100e6b:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0100e71:	50                   	push   %eax
f0100e72:	68 41 02 00 00       	push   $0x241
f0100e77:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0100e7d:	50                   	push   %eax
f0100e7e:	e8 16 f2 ff ff       	call   f0100099 <_panic>
	assert(nfree_extmem > 0);
f0100e83:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e86:	8d 83 55 d4 fe ff    	lea    -0x12bab(%ebx),%eax
f0100e8c:	50                   	push   %eax
f0100e8d:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0100e93:	50                   	push   %eax
f0100e94:	68 42 02 00 00       	push   $0x242
f0100e99:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0100e9f:	50                   	push   %eax
f0100ea0:	e8 f4 f1 ff ff       	call   f0100099 <_panic>
	if (!page_free_list)
f0100ea5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100ea8:	8b 80 94 1f 00 00    	mov    0x1f94(%eax),%eax
f0100eae:	85 c0                	test   %eax,%eax
f0100eb0:	0f 84 06 fd ff ff    	je     f0100bbc <check_page_free_list+0x44>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100eb6:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100eb9:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ebc:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ebf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100ec2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100ec5:	c7 c3 cc 96 11 f0    	mov    $0xf01196cc,%ebx
f0100ecb:	89 c2                	mov    %eax,%edx
f0100ecd:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100ecf:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ed5:	0f 95 c2             	setne  %dl
f0100ed8:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100edb:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100edf:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ee1:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ee5:	8b 00                	mov    (%eax),%eax
f0100ee7:	85 c0                	test   %eax,%eax
f0100ee9:	75 e0                	jne    f0100ecb <check_page_free_list+0x353>
		*tp[1] = 0;
f0100eeb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100eee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ef4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ef7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100efa:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100efc:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0100eff:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100f02:	89 b0 94 1f 00 00    	mov    %esi,0x1f94(%eax)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f08:	85 f6                	test   %esi,%esi
f0100f0a:	0f 84 29 fd ff ff    	je     f0100c39 <check_page_free_list+0xc1>
f0100f10:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
f0100f17:	e9 8c fc ff ff       	jmp    f0100ba8 <check_page_free_list+0x30>

f0100f1c <page_init>:
{
f0100f1c:	55                   	push   %ebp
f0100f1d:	89 e5                	mov    %esp,%ebp
f0100f1f:	57                   	push   %edi
f0100f20:	56                   	push   %esi
f0100f21:	53                   	push   %ebx
f0100f22:	83 ec 3c             	sub    $0x3c,%esp
f0100f25:	e8 c8 f7 ff ff       	call   f01006f2 <__x86.get_pc_thunk.ax>
f0100f2a:	05 de 63 01 00       	add    $0x163de,%eax
f0100f2f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	physaddr_t nextfree_paddr = PADDR((pde_t *)boot_alloc(0));
f0100f32:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f37:	e8 39 fb ff ff       	call   f0100a75 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100f3c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f41:	76 60                	jbe    f0100fa3 <page_init+0x87>
	physaddr_t used_interval[2][2] = {{0, PGSIZE}, {IOPHYSMEM, nextfree_paddr}};
f0100f43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100f4a:	c7 45 dc 00 10 00 00 	movl   $0x1000,-0x24(%ebp)
f0100f51:	c7 45 e0 00 00 0a 00 	movl   $0xa0000,-0x20(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0100f58:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(int i = 0; i < npages; ++i){
f0100f60:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0100f63:	c7 c0 c4 96 11 f0    	mov    $0xf01196c4,%eax
f0100f69:	83 38 00             	cmpl   $0x0,(%eax)
f0100f6c:	0f 84 c5 00 00 00    	je     f0101037 <page_init+0x11b>
f0100f72:	8b be 94 1f 00 00    	mov    0x1f94(%esi),%edi
f0100f78:	c6 45 cb 00          	movb   $0x0,-0x35(%ebp)
f0100f7c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int used_interval_pointer = 0;
f0100f81:	b8 00 00 00 00       	mov    $0x0,%eax
		while(used_interval_pointer < kUsed_interval_length && used_interval[used_interval_pointer][1] <= page2pa(pages + i))
f0100f86:	8d 4d d8             	lea    -0x28(%ebp),%ecx
		if(used_interval_pointer >= kUsed_interval_length || page2pa(pages + i) < used_interval[used_interval_pointer][0]){
f0100f89:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0100f8f:	89 55 c0             	mov    %edx,-0x40(%ebp)
			pages[i].pp_ref = 0;
f0100f92:	89 55 d0             	mov    %edx,-0x30(%ebp)
	for(int i = 0; i < npages; ++i){
f0100f95:	c7 c6 c4 96 11 f0    	mov    $0xf01196c4,%esi
f0100f9b:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0100f9e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100fa1:	eb 4a                	jmp    f0100fed <page_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100fa3:	50                   	push   %eax
f0100fa4:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100fa7:	8d 83 5c d7 fe ff    	lea    -0x128a4(%ebx),%eax
f0100fad:	50                   	push   %eax
f0100fae:	68 05 01 00 00       	push   $0x105
f0100fb3:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0100fb9:	50                   	push   %eax
f0100fba:	e8 da f0 ff ff       	call   f0100099 <_panic>
f0100fbf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100fc2:	8d 14 dd 00 00 00 00 	lea    0x0(,%ebx,8),%edx
			pages[i].pp_ref = 0;
f0100fc9:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fcc:	89 d1                	mov    %edx,%ecx
f0100fce:	03 0e                	add    (%esi),%ecx
f0100fd0:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = page_free_list;
f0100fd6:	89 39                	mov    %edi,(%ecx)
			page_free_list = pages + i;
f0100fd8:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fdb:	89 d7                	mov    %edx,%edi
f0100fdd:	03 3e                	add    (%esi),%edi
f0100fdf:	c6 45 cb 01          	movb   $0x1,-0x35(%ebp)
	for(int i = 0; i < npages; ++i){
f0100fe3:	83 c3 01             	add    $0x1,%ebx
f0100fe6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100fe9:	3b 19                	cmp    (%ecx),%ebx
f0100feb:	73 44                	jae    f0101031 <page_init+0x115>
		while(used_interval_pointer < kUsed_interval_length && used_interval[used_interval_pointer][1] <= page2pa(pages + i))
f0100fed:	83 f8 01             	cmp    $0x1,%eax
f0100ff0:	7f d0                	jg     f0100fc2 <page_init+0xa6>
f0100ff2:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
	return (pp - pages) << PGSHIFT;
f0100ff9:	89 f2                	mov    %esi,%edx
f0100ffb:	c1 e2 09             	shl    $0x9,%edx
f0100ffe:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101001:	39 54 c5 dc          	cmp    %edx,-0x24(%ebp,%eax,8)
f0101005:	77 11                	ja     f0101018 <page_init+0xfc>
			used_interval_pointer++;
f0101007:	83 c0 01             	add    $0x1,%eax
		while(used_interval_pointer < kUsed_interval_length && used_interval[used_interval_pointer][1] <= page2pa(pages + i))
f010100a:	83 f8 02             	cmp    $0x2,%eax
f010100d:	74 b0                	je     f0100fbf <page_init+0xa3>
f010100f:	39 54 c1 04          	cmp    %edx,0x4(%ecx,%eax,8)
f0101013:	76 f2                	jbe    f0101007 <page_init+0xeb>
f0101015:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		if(used_interval_pointer >= kUsed_interval_length || page2pa(pages + i) < used_interval[used_interval_pointer][0]){
f0101018:	39 54 c5 d8          	cmp    %edx,-0x28(%ebp,%eax,8)
f010101c:	77 a4                	ja     f0100fc2 <page_init+0xa6>
f010101e:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0101021:	03 31                	add    (%ecx),%esi
			pages[i].pp_ref = 1;
f0101023:	66 c7 46 04 01 00    	movw   $0x1,0x4(%esi)
			pages[i].pp_link = NULL;
f0101029:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f010102f:	eb b2                	jmp    f0100fe3 <page_init+0xc7>
f0101031:	80 7d cb 00          	cmpb   $0x0,-0x35(%ebp)
f0101035:	75 08                	jne    f010103f <page_init+0x123>
}
f0101037:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010103a:	5b                   	pop    %ebx
f010103b:	5e                   	pop    %esi
f010103c:	5f                   	pop    %edi
f010103d:	5d                   	pop    %ebp
f010103e:	c3                   	ret    
f010103f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0101042:	89 b8 94 1f 00 00    	mov    %edi,0x1f94(%eax)
f0101048:	eb ed                	jmp    f0101037 <page_init+0x11b>

f010104a <page_alloc>:
{
f010104a:	55                   	push   %ebp
f010104b:	89 e5                	mov    %esp,%ebp
f010104d:	56                   	push   %esi
f010104e:	53                   	push   %ebx
f010104f:	e8 fb f0 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0101054:	81 c3 b4 62 01 00    	add    $0x162b4,%ebx
	if(!page_free_list) return NULL;
f010105a:	8b b3 94 1f 00 00    	mov    0x1f94(%ebx),%esi
f0101060:	85 f6                	test   %esi,%esi
f0101062:	74 14                	je     f0101078 <page_alloc+0x2e>
	page_free_list = page_free_list->pp_link;
f0101064:	8b 06                	mov    (%esi),%eax
f0101066:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
	new_page->pp_link = NULL;
f010106c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(alloc_flags & ALLOC_ZERO)
f0101072:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101076:	75 09                	jne    f0101081 <page_alloc+0x37>
}
f0101078:	89 f0                	mov    %esi,%eax
f010107a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010107d:	5b                   	pop    %ebx
f010107e:	5e                   	pop    %esi
f010107f:	5d                   	pop    %ebp
f0101080:	c3                   	ret    
f0101081:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101087:	89 f2                	mov    %esi,%edx
f0101089:	2b 10                	sub    (%eax),%edx
f010108b:	89 d0                	mov    %edx,%eax
f010108d:	c1 f8 03             	sar    $0x3,%eax
f0101090:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101093:	89 c1                	mov    %eax,%ecx
f0101095:	c1 e9 0c             	shr    $0xc,%ecx
f0101098:	c7 c2 c4 96 11 f0    	mov    $0xf01196c4,%edx
f010109e:	3b 0a                	cmp    (%edx),%ecx
f01010a0:	73 1a                	jae    f01010bc <page_alloc+0x72>
		memset(page2kva(new_page), 0, PGSIZE);
f01010a2:	83 ec 04             	sub    $0x4,%esp
f01010a5:	68 00 10 00 00       	push   $0x1000
f01010aa:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01010ac:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010b1:	50                   	push   %eax
f01010b2:	e8 93 2c 00 00       	call   f0103d4a <memset>
f01010b7:	83 c4 10             	add    $0x10,%esp
f01010ba:	eb bc                	jmp    f0101078 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010bc:	50                   	push   %eax
f01010bd:	8d 83 74 d6 fe ff    	lea    -0x1298c(%ebx),%eax
f01010c3:	50                   	push   %eax
f01010c4:	6a 52                	push   $0x52
f01010c6:	8d 83 bc d3 fe ff    	lea    -0x12c44(%ebx),%eax
f01010cc:	50                   	push   %eax
f01010cd:	e8 c7 ef ff ff       	call   f0100099 <_panic>

f01010d2 <page_free>:
{
f01010d2:	55                   	push   %ebp
f01010d3:	89 e5                	mov    %esp,%ebp
f01010d5:	e8 13 1e 00 00       	call   f0102eed <__x86.get_pc_thunk.dx>
f01010da:	81 c2 2e 62 01 00    	add    $0x1622e,%edx
f01010e0:	8b 45 08             	mov    0x8(%ebp),%eax
	if(!pp || pp->pp_ref) return;
f01010e3:	85 c0                	test   %eax,%eax
f01010e5:	74 15                	je     f01010fc <page_free+0x2a>
f01010e7:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010ec:	75 0e                	jne    f01010fc <page_free+0x2a>
	pp->pp_link = page_free_list;
f01010ee:	8b 8a 94 1f 00 00    	mov    0x1f94(%edx),%ecx
f01010f4:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f01010f6:	89 82 94 1f 00 00    	mov    %eax,0x1f94(%edx)
}
f01010fc:	5d                   	pop    %ebp
f01010fd:	c3                   	ret    

f01010fe <page_decref>:
{
f01010fe:	55                   	push   %ebp
f01010ff:	89 e5                	mov    %esp,%ebp
f0101101:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101104:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101108:	83 e8 01             	sub    $0x1,%eax
f010110b:	66 89 42 04          	mov    %ax,0x4(%edx)
f010110f:	66 85 c0             	test   %ax,%ax
f0101112:	74 02                	je     f0101116 <page_decref+0x18>
}
f0101114:	c9                   	leave  
f0101115:	c3                   	ret    
		page_free(pp);
f0101116:	52                   	push   %edx
f0101117:	e8 b6 ff ff ff       	call   f01010d2 <page_free>
f010111c:	83 c4 04             	add    $0x4,%esp
}
f010111f:	eb f3                	jmp    f0101114 <page_decref+0x16>

f0101121 <pgdir_walk>:
{
f0101121:	55                   	push   %ebp
f0101122:	89 e5                	mov    %esp,%ebp
f0101124:	57                   	push   %edi
f0101125:	56                   	push   %esi
f0101126:	53                   	push   %ebx
f0101127:	83 ec 0c             	sub    $0xc,%esp
f010112a:	e8 20 f0 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010112f:	81 c3 d9 61 01 00    	add    $0x161d9,%ebx
f0101135:	8b 7d 0c             	mov    0xc(%ebp),%edi
	pde_t *pgdir_entry = pgdir + PDX(va);
f0101138:	89 fe                	mov    %edi,%esi
f010113a:	c1 ee 16             	shr    $0x16,%esi
f010113d:	c1 e6 02             	shl    $0x2,%esi
f0101140:	03 75 08             	add    0x8(%ebp),%esi
	if(!(*pgdir_entry & PTE_P)){
f0101143:	f6 06 01             	testb  $0x1,(%esi)
f0101146:	75 30                	jne    f0101178 <pgdir_walk+0x57>
		if(create){
f0101148:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010114c:	74 71                	je     f01011bf <pgdir_walk+0x9e>
			struct PageInfo *new_pageinfo = page_alloc(ALLOC_ZERO);
f010114e:	83 ec 0c             	sub    $0xc,%esp
f0101151:	6a 01                	push   $0x1
f0101153:	e8 f2 fe ff ff       	call   f010104a <page_alloc>
			if(!new_pageinfo) return NULL;
f0101158:	83 c4 10             	add    $0x10,%esp
f010115b:	85 c0                	test   %eax,%eax
f010115d:	74 67                	je     f01011c6 <pgdir_walk+0xa5>
			new_pageinfo->pp_ref = 1;
f010115f:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101165:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f010116b:	2b 02                	sub    (%edx),%eax
f010116d:	c1 f8 03             	sar    $0x3,%eax
f0101170:	c1 e0 0c             	shl    $0xc,%eax
			*pgdir_entry = page2pa(new_pageinfo) | PTE_P | PTE_U | PTE_W;
f0101173:	83 c8 07             	or     $0x7,%eax
f0101176:	89 06                	mov    %eax,(%esi)
	pte_t *pg_address = KADDR(PTE_ADDR(*pgdir_entry));
f0101178:	8b 06                	mov    (%esi),%eax
f010117a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010117f:	89 c1                	mov    %eax,%ecx
f0101181:	c1 e9 0c             	shr    $0xc,%ecx
f0101184:	c7 c2 c4 96 11 f0    	mov    $0xf01196c4,%edx
f010118a:	3b 0a                	cmp    (%edx),%ecx
f010118c:	73 18                	jae    f01011a6 <pgdir_walk+0x85>
	return pg_address + PTX(va);
f010118e:	c1 ef 0a             	shr    $0xa,%edi
f0101191:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f0101197:	8d 84 38 00 00 00 f0 	lea    -0x10000000(%eax,%edi,1),%eax
}
f010119e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011a1:	5b                   	pop    %ebx
f01011a2:	5e                   	pop    %esi
f01011a3:	5f                   	pop    %edi
f01011a4:	5d                   	pop    %ebp
f01011a5:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011a6:	50                   	push   %eax
f01011a7:	8d 83 74 d6 fe ff    	lea    -0x1298c(%ebx),%eax
f01011ad:	50                   	push   %eax
f01011ae:	68 73 01 00 00       	push   $0x173
f01011b3:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01011b9:	50                   	push   %eax
f01011ba:	e8 da ee ff ff       	call   f0100099 <_panic>
			return NULL;
f01011bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01011c4:	eb d8                	jmp    f010119e <pgdir_walk+0x7d>
			if(!new_pageinfo) return NULL;
f01011c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01011cb:	eb d1                	jmp    f010119e <pgdir_walk+0x7d>

f01011cd <boot_map_region>:
{
f01011cd:	55                   	push   %ebp
f01011ce:	89 e5                	mov    %esp,%ebp
f01011d0:	57                   	push   %edi
f01011d1:	56                   	push   %esi
f01011d2:	53                   	push   %ebx
f01011d3:	83 ec 1c             	sub    $0x1c,%esp
f01011d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01011d9:	8b 7d 08             	mov    0x8(%ebp),%edi
	unsigned length = (size + PGSIZE - 1) / PGSIZE;
f01011dc:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f01011e2:	c1 e9 0c             	shr    $0xc,%ecx
f01011e5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(unsigned i = 0; i < length; ++i){
f01011e8:	85 c9                	test   %ecx,%ecx
f01011ea:	74 44                	je     f0101230 <boot_map_region+0x63>
f01011ec:	89 d6                	mov    %edx,%esi
f01011ee:	bb 00 00 00 00       	mov    $0x0,%ebx
		*pg_entry = cur_pa | perm | PTE_P;
f01011f3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011f6:	83 c8 01             	or     $0x1,%eax
f01011f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01011fc:	eb 08                	jmp    f0101206 <boot_map_region+0x39>
	for(unsigned i = 0; i < length; ++i){
f01011fe:	83 c3 01             	add    $0x1,%ebx
f0101201:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0101204:	74 2a                	je     f0101230 <boot_map_region+0x63>
		pte_t *pg_entry = pgdir_walk(pgdir, (void *)cur_va, true);
f0101206:	83 ec 04             	sub    $0x4,%esp
f0101209:	6a 01                	push   $0x1
f010120b:	56                   	push   %esi
f010120c:	ff 75 e0             	pushl  -0x20(%ebp)
f010120f:	e8 0d ff ff ff       	call   f0101121 <pgdir_walk>
		if(!pg_entry) continue;
f0101214:	83 c4 10             	add    $0x10,%esp
f0101217:	85 c0                	test   %eax,%eax
f0101219:	74 e3                	je     f01011fe <boot_map_region+0x31>
		*pg_entry = cur_pa | perm | PTE_P;
f010121b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010121e:	09 fa                	or     %edi,%edx
f0101220:	89 10                	mov    %edx,(%eax)
		cur_va += PGSIZE;
f0101222:	81 c6 00 10 00 00    	add    $0x1000,%esi
		cur_pa += PGSIZE;
f0101228:	81 c7 00 10 00 00    	add    $0x1000,%edi
f010122e:	eb ce                	jmp    f01011fe <boot_map_region+0x31>
}
f0101230:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101233:	5b                   	pop    %ebx
f0101234:	5e                   	pop    %esi
f0101235:	5f                   	pop    %edi
f0101236:	5d                   	pop    %ebp
f0101237:	c3                   	ret    

f0101238 <page_lookup>:
{
f0101238:	55                   	push   %ebp
f0101239:	89 e5                	mov    %esp,%ebp
f010123b:	56                   	push   %esi
f010123c:	53                   	push   %ebx
f010123d:	e8 0d ef ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0101242:	81 c3 c6 60 01 00    	add    $0x160c6,%ebx
f0101248:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t *pg_entry = pgdir_walk(pgdir, va, 0);
f010124b:	83 ec 04             	sub    $0x4,%esp
f010124e:	6a 00                	push   $0x0
f0101250:	ff 75 0c             	pushl  0xc(%ebp)
f0101253:	ff 75 08             	pushl  0x8(%ebp)
f0101256:	e8 c6 fe ff ff       	call   f0101121 <pgdir_walk>
	if(!pg_entry || !(*pg_entry & PTE_P)) return NULL;
f010125b:	83 c4 10             	add    $0x10,%esp
f010125e:	85 c0                	test   %eax,%eax
f0101260:	74 46                	je     f01012a8 <page_lookup+0x70>
f0101262:	89 c1                	mov    %eax,%ecx
f0101264:	8b 10                	mov    (%eax),%edx
f0101266:	f6 c2 01             	test   $0x1,%dl
f0101269:	74 44                	je     f01012af <page_lookup+0x77>
f010126b:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010126e:	c7 c0 c4 96 11 f0    	mov    $0xf01196c4,%eax
f0101274:	39 10                	cmp    %edx,(%eax)
f0101276:	76 18                	jbe    f0101290 <page_lookup+0x58>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101278:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f010127e:	8b 00                	mov    (%eax),%eax
f0101280:	8d 04 d0             	lea    (%eax,%edx,8),%eax
	if(pte_store)
f0101283:	85 f6                	test   %esi,%esi
f0101285:	74 02                	je     f0101289 <page_lookup+0x51>
		*pte_store = pg_entry;
f0101287:	89 0e                	mov    %ecx,(%esi)
}
f0101289:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010128c:	5b                   	pop    %ebx
f010128d:	5e                   	pop    %esi
f010128e:	5d                   	pop    %ebp
f010128f:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101290:	83 ec 04             	sub    $0x4,%esp
f0101293:	8d 83 80 d7 fe ff    	lea    -0x12880(%ebx),%eax
f0101299:	50                   	push   %eax
f010129a:	6a 4b                	push   $0x4b
f010129c:	8d 83 bc d3 fe ff    	lea    -0x12c44(%ebx),%eax
f01012a2:	50                   	push   %eax
f01012a3:	e8 f1 ed ff ff       	call   f0100099 <_panic>
	if(!pg_entry || !(*pg_entry & PTE_P)) return NULL;
f01012a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01012ad:	eb da                	jmp    f0101289 <page_lookup+0x51>
f01012af:	b8 00 00 00 00       	mov    $0x0,%eax
f01012b4:	eb d3                	jmp    f0101289 <page_lookup+0x51>

f01012b6 <page_remove>:
{
f01012b6:	55                   	push   %ebp
f01012b7:	89 e5                	mov    %esp,%ebp
f01012b9:	53                   	push   %ebx
f01012ba:	83 ec 18             	sub    $0x18,%esp
f01012bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pg_entry = NULL;
f01012c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo* pg_entry_info = page_lookup(pgdir, va, &pg_entry);
f01012c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01012ca:	50                   	push   %eax
f01012cb:	53                   	push   %ebx
f01012cc:	ff 75 08             	pushl  0x8(%ebp)
f01012cf:	e8 64 ff ff ff       	call   f0101238 <page_lookup>
	if(!pg_entry_info) return;
f01012d4:	83 c4 10             	add    $0x10,%esp
f01012d7:	85 c0                	test   %eax,%eax
f01012d9:	75 05                	jne    f01012e0 <page_remove+0x2a>
}
f01012db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012de:	c9                   	leave  
f01012df:	c3                   	ret    
	page_decref(pg_entry_info);
f01012e0:	83 ec 0c             	sub    $0xc,%esp
f01012e3:	50                   	push   %eax
f01012e4:	e8 15 fe ff ff       	call   f01010fe <page_decref>
	*pg_entry = 0;
f01012e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01012ec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01012f2:	0f 01 3b             	invlpg (%ebx)
f01012f5:	83 c4 10             	add    $0x10,%esp
f01012f8:	eb e1                	jmp    f01012db <page_remove+0x25>

f01012fa <page_insert>:
{
f01012fa:	55                   	push   %ebp
f01012fb:	89 e5                	mov    %esp,%ebp
f01012fd:	57                   	push   %edi
f01012fe:	56                   	push   %esi
f01012ff:	53                   	push   %ebx
f0101300:	83 ec 10             	sub    $0x10,%esp
f0101303:	e8 ed 1b 00 00       	call   f0102ef5 <__x86.get_pc_thunk.di>
f0101308:	81 c7 00 60 01 00    	add    $0x16000,%edi
f010130e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pte_t* pg_entry = pgdir_walk(pgdir, va, 1);
f0101311:	6a 01                	push   $0x1
f0101313:	ff 75 10             	pushl  0x10(%ebp)
f0101316:	53                   	push   %ebx
f0101317:	e8 05 fe ff ff       	call   f0101121 <pgdir_walk>
	if(!pg_entry) return -E_NO_MEM;
f010131c:	83 c4 10             	add    $0x10,%esp
f010131f:	85 c0                	test   %eax,%eax
f0101321:	74 54                	je     f0101377 <page_insert+0x7d>
f0101323:	89 c6                	mov    %eax,%esi
	return (pp - pages) << PGSHIFT;
f0101325:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f010132b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010132e:	2b 38                	sub    (%eax),%edi
f0101330:	c1 ff 03             	sar    $0x3,%edi
f0101333:	c1 e7 0c             	shl    $0xc,%edi
	pp->pp_ref += 1;
f0101336:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101339:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	if(*pg_entry & PTE_P)
f010133e:	f6 06 01             	testb  $0x1,(%esi)
f0101341:	75 23                	jne    f0101366 <page_insert+0x6c>
	*pg_entry = pg_paddr | perm | PTE_P;
f0101343:	8b 45 14             	mov    0x14(%ebp),%eax
f0101346:	83 c8 01             	or     $0x1,%eax
f0101349:	09 c7                	or     %eax,%edi
f010134b:	89 3e                	mov    %edi,(%esi)
	pgdir[PDX(va)] |= perm;
f010134d:	8b 45 10             	mov    0x10(%ebp),%eax
f0101350:	c1 e8 16             	shr    $0x16,%eax
f0101353:	8b 55 14             	mov    0x14(%ebp),%edx
f0101356:	09 14 83             	or     %edx,(%ebx,%eax,4)
	return 0;
f0101359:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010135e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101361:	5b                   	pop    %ebx
f0101362:	5e                   	pop    %esi
f0101363:	5f                   	pop    %edi
f0101364:	5d                   	pop    %ebp
f0101365:	c3                   	ret    
		page_remove(pgdir, va);
f0101366:	83 ec 08             	sub    $0x8,%esp
f0101369:	ff 75 10             	pushl  0x10(%ebp)
f010136c:	53                   	push   %ebx
f010136d:	e8 44 ff ff ff       	call   f01012b6 <page_remove>
f0101372:	83 c4 10             	add    $0x10,%esp
f0101375:	eb cc                	jmp    f0101343 <page_insert+0x49>
	if(!pg_entry) return -E_NO_MEM;
f0101377:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010137c:	eb e0                	jmp    f010135e <page_insert+0x64>

f010137e <mem_init>:
{
f010137e:	55                   	push   %ebp
f010137f:	89 e5                	mov    %esp,%ebp
f0101381:	57                   	push   %edi
f0101382:	56                   	push   %esi
f0101383:	53                   	push   %ebx
f0101384:	83 ec 48             	sub    $0x48,%esp
f0101387:	e8 c3 ed ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010138c:	81 c3 7c 5f 01 00    	add    $0x15f7c,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101392:	6a 15                	push   $0x15
f0101394:	e8 60 1b 00 00       	call   f0102ef9 <mc146818_read>
f0101399:	89 c6                	mov    %eax,%esi
f010139b:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01013a2:	e8 52 1b 00 00       	call   f0102ef9 <mc146818_read>
f01013a7:	c1 e0 08             	shl    $0x8,%eax
f01013aa:	09 f0                	or     %esi,%eax
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01013ac:	c1 e0 0a             	shl    $0xa,%eax
f01013af:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01013b5:	85 c0                	test   %eax,%eax
f01013b7:	0f 48 c2             	cmovs  %edx,%eax
f01013ba:	c1 f8 0c             	sar    $0xc,%eax
f01013bd:	89 83 98 1f 00 00    	mov    %eax,0x1f98(%ebx)
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01013c3:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01013ca:	e8 2a 1b 00 00       	call   f0102ef9 <mc146818_read>
f01013cf:	89 c6                	mov    %eax,%esi
f01013d1:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01013d8:	e8 1c 1b 00 00       	call   f0102ef9 <mc146818_read>
f01013dd:	c1 e0 08             	shl    $0x8,%eax
f01013e0:	09 f0                	or     %esi,%eax
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01013e2:	c1 e0 0a             	shl    $0xa,%eax
f01013e5:	89 c2                	mov    %eax,%edx
f01013e7:	8d 80 ff 0f 00 00    	lea    0xfff(%eax),%eax
f01013ed:	83 c4 10             	add    $0x10,%esp
f01013f0:	85 d2                	test   %edx,%edx
f01013f2:	0f 49 c2             	cmovns %edx,%eax
f01013f5:	c1 f8 0c             	sar    $0xc,%eax
	if (npages_extmem)
f01013f8:	85 c0                	test   %eax,%eax
f01013fa:	0f 85 c0 0b 00 00    	jne    f0101fc0 <mem_init+0xc42>
		npages = npages_basemem;
f0101400:	c7 c2 c4 96 11 f0    	mov    $0xf01196c4,%edx
f0101406:	8b 8b 98 1f 00 00    	mov    0x1f98(%ebx),%ecx
f010140c:	89 0a                	mov    %ecx,(%edx)
		npages_extmem * PGSIZE / 1024);
f010140e:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101411:	c1 e8 0a             	shr    $0xa,%eax
f0101414:	50                   	push   %eax
		npages_basemem * PGSIZE / 1024,
f0101415:	8b 83 98 1f 00 00    	mov    0x1f98(%ebx),%eax
f010141b:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010141e:	c1 e8 0a             	shr    $0xa,%eax
f0101421:	50                   	push   %eax
		npages * PGSIZE / 1024,
f0101422:	c7 c0 c4 96 11 f0    	mov    $0xf01196c4,%eax
f0101428:	8b 00                	mov    (%eax),%eax
f010142a:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010142d:	c1 e8 0a             	shr    $0xa,%eax
f0101430:	50                   	push   %eax
f0101431:	8d 83 a0 d7 fe ff    	lea    -0x12860(%ebx),%eax
f0101437:	50                   	push   %eax
f0101438:	e8 43 1b 00 00       	call   f0102f80 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010143d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101442:	e8 2e f6 ff ff       	call   f0100a75 <boot_alloc>
f0101447:	c7 c6 c8 96 11 f0    	mov    $0xf01196c8,%esi
f010144d:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f010144f:	83 c4 0c             	add    $0xc,%esp
f0101452:	68 00 10 00 00       	push   $0x1000
f0101457:	6a 00                	push   $0x0
f0101459:	50                   	push   %eax
f010145a:	e8 eb 28 00 00       	call   f0103d4a <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010145f:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0101461:	83 c4 10             	add    $0x10,%esp
f0101464:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101469:	0f 86 64 0b 00 00    	jbe    f0101fd3 <mem_init+0xc55>
	return (physaddr_t)kva - KERNBASE;
f010146f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101475:	83 ca 05             	or     $0x5,%edx
f0101478:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo) * npages);
f010147e:	c7 c0 c4 96 11 f0    	mov    $0xf01196c4,%eax
f0101484:	8b 00                	mov    (%eax),%eax
f0101486:	c1 e0 03             	shl    $0x3,%eax
f0101489:	e8 e7 f5 ff ff       	call   f0100a75 <boot_alloc>
f010148e:	c7 c6 cc 96 11 f0    	mov    $0xf01196cc,%esi
f0101494:	89 06                	mov    %eax,(%esi)
	page_init();
f0101496:	e8 81 fa ff ff       	call   f0100f1c <page_init>
	check_page_free_list(1);
f010149b:	b8 01 00 00 00       	mov    $0x1,%eax
f01014a0:	e8 d3 f6 ff ff       	call   f0100b78 <check_page_free_list>
	if (!pages)
f01014a5:	83 3e 00             	cmpl   $0x0,(%esi)
f01014a8:	0f 84 3e 0b 00 00    	je     f0101fec <mem_init+0xc6e>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014ae:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f01014b4:	85 c0                	test   %eax,%eax
f01014b6:	0f 84 4b 0b 00 00    	je     f0102007 <mem_init+0xc89>
f01014bc:	be 00 00 00 00       	mov    $0x0,%esi
		++nfree;
f01014c1:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014c4:	8b 00                	mov    (%eax),%eax
f01014c6:	85 c0                	test   %eax,%eax
f01014c8:	75 f7                	jne    f01014c1 <mem_init+0x143>
	assert((pp0 = page_alloc(0)));
f01014ca:	83 ec 0c             	sub    $0xc,%esp
f01014cd:	6a 00                	push   $0x0
f01014cf:	e8 76 fb ff ff       	call   f010104a <page_alloc>
f01014d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014d7:	83 c4 10             	add    $0x10,%esp
f01014da:	85 c0                	test   %eax,%eax
f01014dc:	0f 84 2f 0b 00 00    	je     f0102011 <mem_init+0xc93>
	assert((pp1 = page_alloc(0)));
f01014e2:	83 ec 0c             	sub    $0xc,%esp
f01014e5:	6a 00                	push   $0x0
f01014e7:	e8 5e fb ff ff       	call   f010104a <page_alloc>
f01014ec:	89 c7                	mov    %eax,%edi
f01014ee:	83 c4 10             	add    $0x10,%esp
f01014f1:	85 c0                	test   %eax,%eax
f01014f3:	0f 84 37 0b 00 00    	je     f0102030 <mem_init+0xcb2>
	assert((pp2 = page_alloc(0)));
f01014f9:	83 ec 0c             	sub    $0xc,%esp
f01014fc:	6a 00                	push   $0x0
f01014fe:	e8 47 fb ff ff       	call   f010104a <page_alloc>
f0101503:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101506:	83 c4 10             	add    $0x10,%esp
f0101509:	85 c0                	test   %eax,%eax
f010150b:	0f 84 3e 0b 00 00    	je     f010204f <mem_init+0xcd1>
	assert(pp1 && pp1 != pp0);
f0101511:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0101514:	0f 84 54 0b 00 00    	je     f010206e <mem_init+0xcf0>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010151a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010151d:	39 c7                	cmp    %eax,%edi
f010151f:	0f 84 68 0b 00 00    	je     f010208d <mem_init+0xd0f>
f0101525:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101528:	0f 84 5f 0b 00 00    	je     f010208d <mem_init+0xd0f>
	return (pp - pages) << PGSHIFT;
f010152e:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101534:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101536:	c7 c0 c4 96 11 f0    	mov    $0xf01196c4,%eax
f010153c:	8b 10                	mov    (%eax),%edx
f010153e:	c1 e2 0c             	shl    $0xc,%edx
f0101541:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101544:	29 c8                	sub    %ecx,%eax
f0101546:	c1 f8 03             	sar    $0x3,%eax
f0101549:	c1 e0 0c             	shl    $0xc,%eax
f010154c:	39 d0                	cmp    %edx,%eax
f010154e:	0f 83 58 0b 00 00    	jae    f01020ac <mem_init+0xd2e>
f0101554:	89 f8                	mov    %edi,%eax
f0101556:	29 c8                	sub    %ecx,%eax
f0101558:	c1 f8 03             	sar    $0x3,%eax
f010155b:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f010155e:	39 c2                	cmp    %eax,%edx
f0101560:	0f 86 65 0b 00 00    	jbe    f01020cb <mem_init+0xd4d>
f0101566:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101569:	29 c8                	sub    %ecx,%eax
f010156b:	c1 f8 03             	sar    $0x3,%eax
f010156e:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101571:	39 c2                	cmp    %eax,%edx
f0101573:	0f 86 71 0b 00 00    	jbe    f01020ea <mem_init+0xd6c>
	fl = page_free_list;
f0101579:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f010157f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101582:	c7 83 94 1f 00 00 00 	movl   $0x0,0x1f94(%ebx)
f0101589:	00 00 00 
	assert(!page_alloc(0));
f010158c:	83 ec 0c             	sub    $0xc,%esp
f010158f:	6a 00                	push   $0x0
f0101591:	e8 b4 fa ff ff       	call   f010104a <page_alloc>
f0101596:	83 c4 10             	add    $0x10,%esp
f0101599:	85 c0                	test   %eax,%eax
f010159b:	0f 85 68 0b 00 00    	jne    f0102109 <mem_init+0xd8b>
	page_free(pp0);
f01015a1:	83 ec 0c             	sub    $0xc,%esp
f01015a4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015a7:	e8 26 fb ff ff       	call   f01010d2 <page_free>
	page_free(pp1);
f01015ac:	89 3c 24             	mov    %edi,(%esp)
f01015af:	e8 1e fb ff ff       	call   f01010d2 <page_free>
	page_free(pp2);
f01015b4:	83 c4 04             	add    $0x4,%esp
f01015b7:	ff 75 d0             	pushl  -0x30(%ebp)
f01015ba:	e8 13 fb ff ff       	call   f01010d2 <page_free>
	assert((pp0 = page_alloc(0)));
f01015bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015c6:	e8 7f fa ff ff       	call   f010104a <page_alloc>
f01015cb:	89 c7                	mov    %eax,%edi
f01015cd:	83 c4 10             	add    $0x10,%esp
f01015d0:	85 c0                	test   %eax,%eax
f01015d2:	0f 84 50 0b 00 00    	je     f0102128 <mem_init+0xdaa>
	assert((pp1 = page_alloc(0)));
f01015d8:	83 ec 0c             	sub    $0xc,%esp
f01015db:	6a 00                	push   $0x0
f01015dd:	e8 68 fa ff ff       	call   f010104a <page_alloc>
f01015e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015e5:	83 c4 10             	add    $0x10,%esp
f01015e8:	85 c0                	test   %eax,%eax
f01015ea:	0f 84 57 0b 00 00    	je     f0102147 <mem_init+0xdc9>
	assert((pp2 = page_alloc(0)));
f01015f0:	83 ec 0c             	sub    $0xc,%esp
f01015f3:	6a 00                	push   $0x0
f01015f5:	e8 50 fa ff ff       	call   f010104a <page_alloc>
f01015fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01015fd:	83 c4 10             	add    $0x10,%esp
f0101600:	85 c0                	test   %eax,%eax
f0101602:	0f 84 5e 0b 00 00    	je     f0102166 <mem_init+0xde8>
	assert(pp1 && pp1 != pp0);
f0101608:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010160b:	0f 84 74 0b 00 00    	je     f0102185 <mem_init+0xe07>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101611:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101614:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101617:	0f 84 87 0b 00 00    	je     f01021a4 <mem_init+0xe26>
f010161d:	39 c7                	cmp    %eax,%edi
f010161f:	0f 84 7f 0b 00 00    	je     f01021a4 <mem_init+0xe26>
	assert(!page_alloc(0));
f0101625:	83 ec 0c             	sub    $0xc,%esp
f0101628:	6a 00                	push   $0x0
f010162a:	e8 1b fa ff ff       	call   f010104a <page_alloc>
f010162f:	83 c4 10             	add    $0x10,%esp
f0101632:	85 c0                	test   %eax,%eax
f0101634:	0f 85 89 0b 00 00    	jne    f01021c3 <mem_init+0xe45>
f010163a:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101640:	89 f9                	mov    %edi,%ecx
f0101642:	2b 08                	sub    (%eax),%ecx
f0101644:	89 c8                	mov    %ecx,%eax
f0101646:	c1 f8 03             	sar    $0x3,%eax
f0101649:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010164c:	89 c1                	mov    %eax,%ecx
f010164e:	c1 e9 0c             	shr    $0xc,%ecx
f0101651:	c7 c2 c4 96 11 f0    	mov    $0xf01196c4,%edx
f0101657:	3b 0a                	cmp    (%edx),%ecx
f0101659:	0f 83 83 0b 00 00    	jae    f01021e2 <mem_init+0xe64>
	memset(page2kva(pp0), 1, PGSIZE);
f010165f:	83 ec 04             	sub    $0x4,%esp
f0101662:	68 00 10 00 00       	push   $0x1000
f0101667:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101669:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010166e:	50                   	push   %eax
f010166f:	e8 d6 26 00 00       	call   f0103d4a <memset>
	page_free(pp0);
f0101674:	89 3c 24             	mov    %edi,(%esp)
f0101677:	e8 56 fa ff ff       	call   f01010d2 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010167c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101683:	e8 c2 f9 ff ff       	call   f010104a <page_alloc>
f0101688:	83 c4 10             	add    $0x10,%esp
f010168b:	85 c0                	test   %eax,%eax
f010168d:	0f 84 65 0b 00 00    	je     f01021f8 <mem_init+0xe7a>
	assert(pp && pp0 == pp);
f0101693:	39 c7                	cmp    %eax,%edi
f0101695:	0f 85 7c 0b 00 00    	jne    f0102217 <mem_init+0xe99>
	return (pp - pages) << PGSHIFT;
f010169b:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f01016a1:	89 fa                	mov    %edi,%edx
f01016a3:	2b 10                	sub    (%eax),%edx
f01016a5:	c1 fa 03             	sar    $0x3,%edx
f01016a8:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01016ab:	89 d1                	mov    %edx,%ecx
f01016ad:	c1 e9 0c             	shr    $0xc,%ecx
f01016b0:	c7 c0 c4 96 11 f0    	mov    $0xf01196c4,%eax
f01016b6:	3b 08                	cmp    (%eax),%ecx
f01016b8:	0f 83 78 0b 00 00    	jae    f0102236 <mem_init+0xeb8>
		assert(c[i] == 0);
f01016be:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f01016c5:	0f 85 81 0b 00 00    	jne    f010224c <mem_init+0xece>
f01016cb:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
f01016d1:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f01016d7:	80 38 00             	cmpb   $0x0,(%eax)
f01016da:	0f 85 6c 0b 00 00    	jne    f010224c <mem_init+0xece>
f01016e0:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f01016e3:	39 d0                	cmp    %edx,%eax
f01016e5:	75 f0                	jne    f01016d7 <mem_init+0x359>
	page_free_list = fl;
f01016e7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01016ea:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
	page_free(pp0);
f01016f0:	83 ec 0c             	sub    $0xc,%esp
f01016f3:	57                   	push   %edi
f01016f4:	e8 d9 f9 ff ff       	call   f01010d2 <page_free>
	page_free(pp1);
f01016f9:	83 c4 04             	add    $0x4,%esp
f01016fc:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016ff:	e8 ce f9 ff ff       	call   f01010d2 <page_free>
	page_free(pp2);
f0101704:	83 c4 04             	add    $0x4,%esp
f0101707:	ff 75 d0             	pushl  -0x30(%ebp)
f010170a:	e8 c3 f9 ff ff       	call   f01010d2 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010170f:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f0101715:	83 c4 10             	add    $0x10,%esp
f0101718:	85 c0                	test   %eax,%eax
f010171a:	74 09                	je     f0101725 <mem_init+0x3a7>
		--nfree;
f010171c:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010171f:	8b 00                	mov    (%eax),%eax
f0101721:	85 c0                	test   %eax,%eax
f0101723:	75 f7                	jne    f010171c <mem_init+0x39e>
	assert(nfree == 0);
f0101725:	85 f6                	test   %esi,%esi
f0101727:	0f 85 3e 0b 00 00    	jne    f010226b <mem_init+0xeed>
	cprintf("check_page_alloc() succeeded!\n");
f010172d:	83 ec 0c             	sub    $0xc,%esp
f0101730:	8d 83 fc d7 fe ff    	lea    -0x12804(%ebx),%eax
f0101736:	50                   	push   %eax
f0101737:	e8 44 18 00 00       	call   f0102f80 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010173c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101743:	e8 02 f9 ff ff       	call   f010104a <page_alloc>
f0101748:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010174b:	83 c4 10             	add    $0x10,%esp
f010174e:	85 c0                	test   %eax,%eax
f0101750:	0f 84 34 0b 00 00    	je     f010228a <mem_init+0xf0c>
	assert((pp1 = page_alloc(0)));
f0101756:	83 ec 0c             	sub    $0xc,%esp
f0101759:	6a 00                	push   $0x0
f010175b:	e8 ea f8 ff ff       	call   f010104a <page_alloc>
f0101760:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101763:	83 c4 10             	add    $0x10,%esp
f0101766:	85 c0                	test   %eax,%eax
f0101768:	0f 84 3b 0b 00 00    	je     f01022a9 <mem_init+0xf2b>
	assert((pp2 = page_alloc(0)));
f010176e:	83 ec 0c             	sub    $0xc,%esp
f0101771:	6a 00                	push   $0x0
f0101773:	e8 d2 f8 ff ff       	call   f010104a <page_alloc>
f0101778:	89 c7                	mov    %eax,%edi
f010177a:	83 c4 10             	add    $0x10,%esp
f010177d:	85 c0                	test   %eax,%eax
f010177f:	0f 84 43 0b 00 00    	je     f01022c8 <mem_init+0xf4a>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101785:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101788:	39 4d d0             	cmp    %ecx,-0x30(%ebp)
f010178b:	0f 84 56 0b 00 00    	je     f01022e7 <mem_init+0xf69>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101791:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101794:	0f 84 6c 0b 00 00    	je     f0102306 <mem_init+0xf88>
f010179a:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010179d:	0f 84 63 0b 00 00    	je     f0102306 <mem_init+0xf88>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01017a3:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f01017a9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	page_free_list = 0;
f01017ac:	c7 83 94 1f 00 00 00 	movl   $0x0,0x1f94(%ebx)
f01017b3:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01017b6:	83 ec 0c             	sub    $0xc,%esp
f01017b9:	6a 00                	push   $0x0
f01017bb:	e8 8a f8 ff ff       	call   f010104a <page_alloc>
f01017c0:	83 c4 10             	add    $0x10,%esp
f01017c3:	85 c0                	test   %eax,%eax
f01017c5:	0f 85 5a 0b 00 00    	jne    f0102325 <mem_init+0xfa7>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01017cb:	83 ec 04             	sub    $0x4,%esp
f01017ce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01017d1:	50                   	push   %eax
f01017d2:	6a 00                	push   $0x0
f01017d4:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f01017da:	ff 30                	pushl  (%eax)
f01017dc:	e8 57 fa ff ff       	call   f0101238 <page_lookup>
f01017e1:	83 c4 10             	add    $0x10,%esp
f01017e4:	85 c0                	test   %eax,%eax
f01017e6:	0f 85 58 0b 00 00    	jne    f0102344 <mem_init+0xfc6>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01017ec:	6a 02                	push   $0x2
f01017ee:	6a 00                	push   $0x0
f01017f0:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017f3:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f01017f9:	ff 30                	pushl  (%eax)
f01017fb:	e8 fa fa ff ff       	call   f01012fa <page_insert>
f0101800:	83 c4 10             	add    $0x10,%esp
f0101803:	85 c0                	test   %eax,%eax
f0101805:	0f 89 58 0b 00 00    	jns    f0102363 <mem_init+0xfe5>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010180b:	83 ec 0c             	sub    $0xc,%esp
f010180e:	ff 75 d0             	pushl  -0x30(%ebp)
f0101811:	e8 bc f8 ff ff       	call   f01010d2 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101816:	6a 02                	push   $0x2
f0101818:	6a 00                	push   $0x0
f010181a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010181d:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101823:	ff 30                	pushl  (%eax)
f0101825:	e8 d0 fa ff ff       	call   f01012fa <page_insert>
f010182a:	83 c4 20             	add    $0x20,%esp
f010182d:	85 c0                	test   %eax,%eax
f010182f:	0f 85 4d 0b 00 00    	jne    f0102382 <mem_init+0x1004>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101835:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f010183b:	8b 08                	mov    (%eax),%ecx
f010183d:	89 ce                	mov    %ecx,%esi
	return (pp - pages) << PGSHIFT;
f010183f:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101845:	8b 00                	mov    (%eax),%eax
f0101847:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010184a:	8b 09                	mov    (%ecx),%ecx
f010184c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010184f:	89 ca                	mov    %ecx,%edx
f0101851:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101857:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010185a:	29 c1                	sub    %eax,%ecx
f010185c:	89 c8                	mov    %ecx,%eax
f010185e:	c1 f8 03             	sar    $0x3,%eax
f0101861:	c1 e0 0c             	shl    $0xc,%eax
f0101864:	39 c2                	cmp    %eax,%edx
f0101866:	0f 85 35 0b 00 00    	jne    f01023a1 <mem_init+0x1023>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010186c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101871:	89 f0                	mov    %esi,%eax
f0101873:	e8 83 f2 ff ff       	call   f0100afb <check_va2pa>
f0101878:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010187b:	2b 55 cc             	sub    -0x34(%ebp),%edx
f010187e:	c1 fa 03             	sar    $0x3,%edx
f0101881:	c1 e2 0c             	shl    $0xc,%edx
f0101884:	39 d0                	cmp    %edx,%eax
f0101886:	0f 85 34 0b 00 00    	jne    f01023c0 <mem_init+0x1042>
	assert(pp1->pp_ref == 1);
f010188c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010188f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101894:	0f 85 45 0b 00 00    	jne    f01023df <mem_init+0x1061>
	assert(pp0->pp_ref == 1);
f010189a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010189d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01018a2:	0f 85 56 0b 00 00    	jne    f01023fe <mem_init+0x1080>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01018a8:	6a 02                	push   $0x2
f01018aa:	68 00 10 00 00       	push   $0x1000
f01018af:	57                   	push   %edi
f01018b0:	56                   	push   %esi
f01018b1:	e8 44 fa ff ff       	call   f01012fa <page_insert>
f01018b6:	83 c4 10             	add    $0x10,%esp
f01018b9:	85 c0                	test   %eax,%eax
f01018bb:	0f 85 5c 0b 00 00    	jne    f010241d <mem_init+0x109f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018c1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018c6:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f01018cc:	8b 00                	mov    (%eax),%eax
f01018ce:	e8 28 f2 ff ff       	call   f0100afb <check_va2pa>
f01018d3:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f01018d9:	89 f9                	mov    %edi,%ecx
f01018db:	2b 0a                	sub    (%edx),%ecx
f01018dd:	89 ca                	mov    %ecx,%edx
f01018df:	c1 fa 03             	sar    $0x3,%edx
f01018e2:	c1 e2 0c             	shl    $0xc,%edx
f01018e5:	39 d0                	cmp    %edx,%eax
f01018e7:	0f 85 4f 0b 00 00    	jne    f010243c <mem_init+0x10be>
	assert(pp2->pp_ref == 1);
f01018ed:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01018f2:	0f 85 63 0b 00 00    	jne    f010245b <mem_init+0x10dd>

	// should be no free memory
	assert(!page_alloc(0));
f01018f8:	83 ec 0c             	sub    $0xc,%esp
f01018fb:	6a 00                	push   $0x0
f01018fd:	e8 48 f7 ff ff       	call   f010104a <page_alloc>
f0101902:	83 c4 10             	add    $0x10,%esp
f0101905:	85 c0                	test   %eax,%eax
f0101907:	0f 85 6d 0b 00 00    	jne    f010247a <mem_init+0x10fc>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010190d:	6a 02                	push   $0x2
f010190f:	68 00 10 00 00       	push   $0x1000
f0101914:	57                   	push   %edi
f0101915:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f010191b:	ff 30                	pushl  (%eax)
f010191d:	e8 d8 f9 ff ff       	call   f01012fa <page_insert>
f0101922:	83 c4 10             	add    $0x10,%esp
f0101925:	85 c0                	test   %eax,%eax
f0101927:	0f 85 6c 0b 00 00    	jne    f0102499 <mem_init+0x111b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010192d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101932:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101938:	8b 00                	mov    (%eax),%eax
f010193a:	e8 bc f1 ff ff       	call   f0100afb <check_va2pa>
f010193f:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0101945:	89 f9                	mov    %edi,%ecx
f0101947:	2b 0a                	sub    (%edx),%ecx
f0101949:	89 ca                	mov    %ecx,%edx
f010194b:	c1 fa 03             	sar    $0x3,%edx
f010194e:	c1 e2 0c             	shl    $0xc,%edx
f0101951:	39 d0                	cmp    %edx,%eax
f0101953:	0f 85 5f 0b 00 00    	jne    f01024b8 <mem_init+0x113a>
	assert(pp2->pp_ref == 1);
f0101959:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010195e:	0f 85 73 0b 00 00    	jne    f01024d7 <mem_init+0x1159>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101964:	83 ec 0c             	sub    $0xc,%esp
f0101967:	6a 00                	push   $0x0
f0101969:	e8 dc f6 ff ff       	call   f010104a <page_alloc>
f010196e:	83 c4 10             	add    $0x10,%esp
f0101971:	85 c0                	test   %eax,%eax
f0101973:	0f 85 7d 0b 00 00    	jne    f01024f6 <mem_init+0x1178>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101979:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f010197f:	8b 10                	mov    (%eax),%edx
f0101981:	8b 02                	mov    (%edx),%eax
f0101983:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101988:	89 c1                	mov    %eax,%ecx
f010198a:	c1 e9 0c             	shr    $0xc,%ecx
f010198d:	89 ce                	mov    %ecx,%esi
f010198f:	c7 c1 c4 96 11 f0    	mov    $0xf01196c4,%ecx
f0101995:	3b 31                	cmp    (%ecx),%esi
f0101997:	0f 83 78 0b 00 00    	jae    f0102515 <mem_init+0x1197>
	return (void *)(pa + KERNBASE);
f010199d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01019a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01019a5:	83 ec 04             	sub    $0x4,%esp
f01019a8:	6a 00                	push   $0x0
f01019aa:	68 00 10 00 00       	push   $0x1000
f01019af:	52                   	push   %edx
f01019b0:	e8 6c f7 ff ff       	call   f0101121 <pgdir_walk>
f01019b5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01019b8:	8d 51 04             	lea    0x4(%ecx),%edx
f01019bb:	83 c4 10             	add    $0x10,%esp
f01019be:	39 d0                	cmp    %edx,%eax
f01019c0:	0f 85 68 0b 00 00    	jne    f010252e <mem_init+0x11b0>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01019c6:	6a 06                	push   $0x6
f01019c8:	68 00 10 00 00       	push   $0x1000
f01019cd:	57                   	push   %edi
f01019ce:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f01019d4:	ff 30                	pushl  (%eax)
f01019d6:	e8 1f f9 ff ff       	call   f01012fa <page_insert>
f01019db:	83 c4 10             	add    $0x10,%esp
f01019de:	85 c0                	test   %eax,%eax
f01019e0:	0f 85 67 0b 00 00    	jne    f010254d <mem_init+0x11cf>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019e6:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f01019ec:	8b 00                	mov    (%eax),%eax
f01019ee:	89 c6                	mov    %eax,%esi
f01019f0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019f5:	e8 01 f1 ff ff       	call   f0100afb <check_va2pa>
	return (pp - pages) << PGSHIFT;
f01019fa:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0101a00:	89 f9                	mov    %edi,%ecx
f0101a02:	2b 0a                	sub    (%edx),%ecx
f0101a04:	89 ca                	mov    %ecx,%edx
f0101a06:	c1 fa 03             	sar    $0x3,%edx
f0101a09:	c1 e2 0c             	shl    $0xc,%edx
f0101a0c:	39 d0                	cmp    %edx,%eax
f0101a0e:	0f 85 58 0b 00 00    	jne    f010256c <mem_init+0x11ee>
	assert(pp2->pp_ref == 1);
f0101a14:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a19:	0f 85 6c 0b 00 00    	jne    f010258b <mem_init+0x120d>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101a1f:	83 ec 04             	sub    $0x4,%esp
f0101a22:	6a 00                	push   $0x0
f0101a24:	68 00 10 00 00       	push   $0x1000
f0101a29:	56                   	push   %esi
f0101a2a:	e8 f2 f6 ff ff       	call   f0101121 <pgdir_walk>
f0101a2f:	83 c4 10             	add    $0x10,%esp
f0101a32:	f6 00 04             	testb  $0x4,(%eax)
f0101a35:	0f 84 6f 0b 00 00    	je     f01025aa <mem_init+0x122c>
	assert(kern_pgdir[0] & PTE_U);
f0101a3b:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101a41:	8b 00                	mov    (%eax),%eax
f0101a43:	f6 00 04             	testb  $0x4,(%eax)
f0101a46:	0f 84 7d 0b 00 00    	je     f01025c9 <mem_init+0x124b>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a4c:	6a 02                	push   $0x2
f0101a4e:	68 00 10 00 00       	push   $0x1000
f0101a53:	57                   	push   %edi
f0101a54:	50                   	push   %eax
f0101a55:	e8 a0 f8 ff ff       	call   f01012fa <page_insert>
f0101a5a:	83 c4 10             	add    $0x10,%esp
f0101a5d:	85 c0                	test   %eax,%eax
f0101a5f:	0f 85 83 0b 00 00    	jne    f01025e8 <mem_init+0x126a>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101a65:	83 ec 04             	sub    $0x4,%esp
f0101a68:	6a 00                	push   $0x0
f0101a6a:	68 00 10 00 00       	push   $0x1000
f0101a6f:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101a75:	ff 30                	pushl  (%eax)
f0101a77:	e8 a5 f6 ff ff       	call   f0101121 <pgdir_walk>
f0101a7c:	83 c4 10             	add    $0x10,%esp
f0101a7f:	f6 00 02             	testb  $0x2,(%eax)
f0101a82:	0f 84 7f 0b 00 00    	je     f0102607 <mem_init+0x1289>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101a88:	83 ec 04             	sub    $0x4,%esp
f0101a8b:	6a 00                	push   $0x0
f0101a8d:	68 00 10 00 00       	push   $0x1000
f0101a92:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101a98:	ff 30                	pushl  (%eax)
f0101a9a:	e8 82 f6 ff ff       	call   f0101121 <pgdir_walk>
f0101a9f:	83 c4 10             	add    $0x10,%esp
f0101aa2:	f6 00 04             	testb  $0x4,(%eax)
f0101aa5:	0f 85 7b 0b 00 00    	jne    f0102626 <mem_init+0x12a8>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101aab:	6a 02                	push   $0x2
f0101aad:	68 00 00 40 00       	push   $0x400000
f0101ab2:	ff 75 d0             	pushl  -0x30(%ebp)
f0101ab5:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101abb:	ff 30                	pushl  (%eax)
f0101abd:	e8 38 f8 ff ff       	call   f01012fa <page_insert>
f0101ac2:	83 c4 10             	add    $0x10,%esp
f0101ac5:	85 c0                	test   %eax,%eax
f0101ac7:	0f 89 78 0b 00 00    	jns    f0102645 <mem_init+0x12c7>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101acd:	6a 02                	push   $0x2
f0101acf:	68 00 10 00 00       	push   $0x1000
f0101ad4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101ad7:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101add:	ff 30                	pushl  (%eax)
f0101adf:	e8 16 f8 ff ff       	call   f01012fa <page_insert>
f0101ae4:	83 c4 10             	add    $0x10,%esp
f0101ae7:	85 c0                	test   %eax,%eax
f0101ae9:	0f 85 75 0b 00 00    	jne    f0102664 <mem_init+0x12e6>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101aef:	83 ec 04             	sub    $0x4,%esp
f0101af2:	6a 00                	push   $0x0
f0101af4:	68 00 10 00 00       	push   $0x1000
f0101af9:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101aff:	ff 30                	pushl  (%eax)
f0101b01:	e8 1b f6 ff ff       	call   f0101121 <pgdir_walk>
f0101b06:	83 c4 10             	add    $0x10,%esp
f0101b09:	f6 00 04             	testb  $0x4,(%eax)
f0101b0c:	0f 85 71 0b 00 00    	jne    f0102683 <mem_init+0x1305>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101b12:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101b18:	8b 00                	mov    (%eax),%eax
f0101b1a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b1d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b22:	e8 d4 ef ff ff       	call   f0100afb <check_va2pa>
f0101b27:	89 c6                	mov    %eax,%esi
f0101b29:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101b2f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b32:	2b 08                	sub    (%eax),%ecx
f0101b34:	89 c8                	mov    %ecx,%eax
f0101b36:	c1 f8 03             	sar    $0x3,%eax
f0101b39:	c1 e0 0c             	shl    $0xc,%eax
f0101b3c:	39 c6                	cmp    %eax,%esi
f0101b3e:	0f 85 5e 0b 00 00    	jne    f01026a2 <mem_init+0x1324>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101b44:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b49:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101b4c:	e8 aa ef ff ff       	call   f0100afb <check_va2pa>
f0101b51:	39 c6                	cmp    %eax,%esi
f0101b53:	0f 85 68 0b 00 00    	jne    f01026c1 <mem_init+0x1343>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101b59:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b5c:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0101b61:	0f 85 79 0b 00 00    	jne    f01026e0 <mem_init+0x1362>
	assert(pp2->pp_ref == 0);
f0101b67:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101b6c:	0f 85 8d 0b 00 00    	jne    f01026ff <mem_init+0x1381>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101b72:	83 ec 0c             	sub    $0xc,%esp
f0101b75:	6a 00                	push   $0x0
f0101b77:	e8 ce f4 ff ff       	call   f010104a <page_alloc>
f0101b7c:	83 c4 10             	add    $0x10,%esp
f0101b7f:	39 c7                	cmp    %eax,%edi
f0101b81:	0f 85 97 0b 00 00    	jne    f010271e <mem_init+0x13a0>
f0101b87:	85 c0                	test   %eax,%eax
f0101b89:	0f 84 8f 0b 00 00    	je     f010271e <mem_init+0x13a0>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101b8f:	83 ec 08             	sub    $0x8,%esp
f0101b92:	6a 00                	push   $0x0
f0101b94:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101b9a:	89 c6                	mov    %eax,%esi
f0101b9c:	ff 30                	pushl  (%eax)
f0101b9e:	e8 13 f7 ff ff       	call   f01012b6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ba3:	8b 06                	mov    (%esi),%eax
f0101ba5:	89 c6                	mov    %eax,%esi
f0101ba7:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bac:	e8 4a ef ff ff       	call   f0100afb <check_va2pa>
f0101bb1:	83 c4 10             	add    $0x10,%esp
f0101bb4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101bb7:	0f 85 80 0b 00 00    	jne    f010273d <mem_init+0x13bf>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101bbd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bc2:	89 f0                	mov    %esi,%eax
f0101bc4:	e8 32 ef ff ff       	call   f0100afb <check_va2pa>
f0101bc9:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0101bcf:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101bd2:	2b 0a                	sub    (%edx),%ecx
f0101bd4:	89 ca                	mov    %ecx,%edx
f0101bd6:	c1 fa 03             	sar    $0x3,%edx
f0101bd9:	c1 e2 0c             	shl    $0xc,%edx
f0101bdc:	39 d0                	cmp    %edx,%eax
f0101bde:	0f 85 78 0b 00 00    	jne    f010275c <mem_init+0x13de>
	assert(pp1->pp_ref == 1);
f0101be4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101be7:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bec:	0f 85 89 0b 00 00    	jne    f010277b <mem_init+0x13fd>
	assert(pp2->pp_ref == 0);
f0101bf2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101bf7:	0f 85 9d 0b 00 00    	jne    f010279a <mem_init+0x141c>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101bfd:	83 ec 08             	sub    $0x8,%esp
f0101c00:	68 00 10 00 00       	push   $0x1000
f0101c05:	56                   	push   %esi
f0101c06:	e8 ab f6 ff ff       	call   f01012b6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c0b:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101c11:	8b 00                	mov    (%eax),%eax
f0101c13:	89 c6                	mov    %eax,%esi
f0101c15:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c1a:	e8 dc ee ff ff       	call   f0100afb <check_va2pa>
f0101c1f:	83 c4 10             	add    $0x10,%esp
f0101c22:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c25:	0f 85 8e 0b 00 00    	jne    f01027b9 <mem_init+0x143b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101c2b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c30:	89 f0                	mov    %esi,%eax
f0101c32:	e8 c4 ee ff ff       	call   f0100afb <check_va2pa>
f0101c37:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c3a:	0f 85 98 0b 00 00    	jne    f01027d8 <mem_init+0x145a>
	assert(pp1->pp_ref == 0);
f0101c40:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c43:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101c48:	0f 85 a9 0b 00 00    	jne    f01027f7 <mem_init+0x1479>
	assert(pp2->pp_ref == 0);
f0101c4e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101c53:	0f 85 bd 0b 00 00    	jne    f0102816 <mem_init+0x1498>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101c59:	83 ec 0c             	sub    $0xc,%esp
f0101c5c:	6a 00                	push   $0x0
f0101c5e:	e8 e7 f3 ff ff       	call   f010104a <page_alloc>
f0101c63:	83 c4 10             	add    $0x10,%esp
f0101c66:	85 c0                	test   %eax,%eax
f0101c68:	0f 84 c7 0b 00 00    	je     f0102835 <mem_init+0x14b7>
f0101c6e:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101c71:	0f 85 be 0b 00 00    	jne    f0102835 <mem_init+0x14b7>

	// should be no free memory
	assert(!page_alloc(0));
f0101c77:	83 ec 0c             	sub    $0xc,%esp
f0101c7a:	6a 00                	push   $0x0
f0101c7c:	e8 c9 f3 ff ff       	call   f010104a <page_alloc>
f0101c81:	83 c4 10             	add    $0x10,%esp
f0101c84:	85 c0                	test   %eax,%eax
f0101c86:	0f 85 c8 0b 00 00    	jne    f0102854 <mem_init+0x14d6>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c8c:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101c92:	8b 08                	mov    (%eax),%ecx
f0101c94:	8b 11                	mov    (%ecx),%edx
f0101c96:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c9c:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101ca2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101ca5:	2b 30                	sub    (%eax),%esi
f0101ca7:	89 f0                	mov    %esi,%eax
f0101ca9:	c1 f8 03             	sar    $0x3,%eax
f0101cac:	c1 e0 0c             	shl    $0xc,%eax
f0101caf:	39 c2                	cmp    %eax,%edx
f0101cb1:	0f 85 bc 0b 00 00    	jne    f0102873 <mem_init+0x14f5>
	kern_pgdir[0] = 0;
f0101cb7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101cbd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101cc0:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101cc5:	0f 85 c7 0b 00 00    	jne    f0102892 <mem_init+0x1514>
	pp0->pp_ref = 0;
f0101ccb:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101cce:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101cd4:	83 ec 0c             	sub    $0xc,%esp
f0101cd7:	50                   	push   %eax
f0101cd8:	e8 f5 f3 ff ff       	call   f01010d2 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101cdd:	83 c4 0c             	add    $0xc,%esp
f0101ce0:	6a 01                	push   $0x1
f0101ce2:	68 00 10 40 00       	push   $0x401000
f0101ce7:	c7 c6 c8 96 11 f0    	mov    $0xf01196c8,%esi
f0101ced:	ff 36                	pushl  (%esi)
f0101cef:	e8 2d f4 ff ff       	call   f0101121 <pgdir_walk>
f0101cf4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101cf7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101cfa:	8b 06                	mov    (%esi),%eax
f0101cfc:	8b 50 04             	mov    0x4(%eax),%edx
f0101cff:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101d05:	c7 c1 c4 96 11 f0    	mov    $0xf01196c4,%ecx
f0101d0b:	8b 09                	mov    (%ecx),%ecx
f0101d0d:	89 d6                	mov    %edx,%esi
f0101d0f:	c1 ee 0c             	shr    $0xc,%esi
f0101d12:	83 c4 10             	add    $0x10,%esp
f0101d15:	39 ce                	cmp    %ecx,%esi
f0101d17:	0f 83 94 0b 00 00    	jae    f01028b1 <mem_init+0x1533>
	assert(ptep == ptep1 + PTX(va));
f0101d1d:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101d23:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0101d26:	0f 85 9e 0b 00 00    	jne    f01028ca <mem_init+0x154c>
	kern_pgdir[PDX(va)] = 0;
f0101d2c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101d33:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101d36:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
	return (pp - pages) << PGSHIFT;
f0101d3c:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101d42:	2b 30                	sub    (%eax),%esi
f0101d44:	89 f0                	mov    %esi,%eax
f0101d46:	c1 f8 03             	sar    $0x3,%eax
f0101d49:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101d4c:	89 c2                	mov    %eax,%edx
f0101d4e:	c1 ea 0c             	shr    $0xc,%edx
f0101d51:	39 d1                	cmp    %edx,%ecx
f0101d53:	0f 86 90 0b 00 00    	jbe    f01028e9 <mem_init+0x156b>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101d59:	83 ec 04             	sub    $0x4,%esp
f0101d5c:	68 00 10 00 00       	push   $0x1000
f0101d61:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101d66:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d6b:	50                   	push   %eax
f0101d6c:	e8 d9 1f 00 00       	call   f0103d4a <memset>
	page_free(pp0);
f0101d71:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101d74:	89 34 24             	mov    %esi,(%esp)
f0101d77:	e8 56 f3 ff ff       	call   f01010d2 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101d7c:	83 c4 0c             	add    $0xc,%esp
f0101d7f:	6a 01                	push   $0x1
f0101d81:	6a 00                	push   $0x0
f0101d83:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101d89:	ff 30                	pushl  (%eax)
f0101d8b:	e8 91 f3 ff ff       	call   f0101121 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101d90:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101d96:	89 f2                	mov    %esi,%edx
f0101d98:	2b 10                	sub    (%eax),%edx
f0101d9a:	c1 fa 03             	sar    $0x3,%edx
f0101d9d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101da0:	89 d1                	mov    %edx,%ecx
f0101da2:	c1 e9 0c             	shr    $0xc,%ecx
f0101da5:	83 c4 10             	add    $0x10,%esp
f0101da8:	c7 c0 c4 96 11 f0    	mov    $0xf01196c4,%eax
f0101dae:	3b 08                	cmp    (%eax),%ecx
f0101db0:	0f 83 49 0b 00 00    	jae    f01028ff <mem_init+0x1581>
	return (void *)(pa + KERNBASE);
f0101db6:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101dbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101dbf:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0101dc6:	0f 85 49 0b 00 00    	jne    f0102915 <mem_init+0x1597>
f0101dcc:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
f0101dd2:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f0101dd8:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101ddb:	f6 00 01             	testb  $0x1,(%eax)
f0101dde:	0f 85 31 0b 00 00    	jne    f0102915 <mem_init+0x1597>
f0101de4:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101de7:	39 c2                	cmp    %eax,%edx
f0101de9:	75 f0                	jne    f0101ddb <mem_init+0xa5d>
	kern_pgdir[0] = 0;
f0101deb:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101df1:	8b 00                	mov    (%eax),%eax
f0101df3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101df9:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0101dff:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0101e02:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)

	// free the pages we took
	page_free(pp0);
f0101e08:	83 ec 0c             	sub    $0xc,%esp
f0101e0b:	56                   	push   %esi
f0101e0c:	e8 c1 f2 ff ff       	call   f01010d2 <page_free>
	page_free(pp1);
f0101e11:	83 c4 04             	add    $0x4,%esp
f0101e14:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e17:	e8 b6 f2 ff ff       	call   f01010d2 <page_free>
	page_free(pp2);
f0101e1c:	89 3c 24             	mov    %edi,(%esp)
f0101e1f:	e8 ae f2 ff ff       	call   f01010d2 <page_free>

	cprintf("check_page() succeeded!\n");
f0101e24:	8d 83 29 d6 fe ff    	lea    -0x129d7(%ebx),%eax
f0101e2a:	89 04 24             	mov    %eax,(%esp)
f0101e2d:	e8 4e 11 00 00       	call   f0102f80 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, sizeof(struct PageInfo) * npages, PADDR(pages), PTE_W);
f0101e32:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101e38:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0101e3a:	83 c4 10             	add    $0x10,%esp
f0101e3d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101e42:	0f 86 ec 0a 00 00    	jbe    f0102934 <mem_init+0x15b6>
f0101e48:	c7 c2 c4 96 11 f0    	mov    $0xf01196c4,%edx
f0101e4e:	8b 0a                	mov    (%edx),%ecx
f0101e50:	c1 e1 03             	shl    $0x3,%ecx
f0101e53:	83 ec 08             	sub    $0x8,%esp
f0101e56:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f0101e58:	05 00 00 00 10       	add    $0x10000000,%eax
f0101e5d:	50                   	push   %eax
f0101e5e:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101e63:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101e69:	8b 00                	mov    (%eax),%eax
f0101e6b:	e8 5d f3 ff ff       	call   f01011cd <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0101e70:	c7 c0 00 e0 10 f0    	mov    $0xf010e000,%eax
f0101e76:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101e79:	83 c4 10             	add    $0x10,%esp
f0101e7c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101e81:	0f 86 c6 0a 00 00    	jbe    f010294d <mem_init+0x15cf>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0101e87:	c7 c6 c8 96 11 f0    	mov    $0xf01196c8,%esi
f0101e8d:	83 ec 08             	sub    $0x8,%esp
f0101e90:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f0101e92:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101e95:	05 00 00 00 10       	add    $0x10000000,%eax
f0101e9a:	50                   	push   %eax
f0101e9b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101ea0:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0101ea5:	8b 06                	mov    (%esi),%eax
f0101ea7:	e8 21 f3 ff ff       	call   f01011cd <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffffu - KERNBASE, 0, PTE_W);
f0101eac:	83 c4 08             	add    $0x8,%esp
f0101eaf:	6a 02                	push   $0x2
f0101eb1:	6a 00                	push   $0x0
f0101eb3:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0101eb8:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101ebd:	8b 06                	mov    (%esi),%eax
f0101ebf:	e8 09 f3 ff ff       	call   f01011cd <boot_map_region>
	pgdir = kern_pgdir;
f0101ec4:	8b 36                	mov    (%esi),%esi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101ec6:	c7 c0 c4 96 11 f0    	mov    $0xf01196c4,%eax
f0101ecc:	8b 00                	mov    (%eax),%eax
f0101ece:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101ed1:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
	for (i = 0; i < n; i += PGSIZE)
f0101ed8:	83 c4 10             	add    $0x10,%esp
f0101edb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101ee0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ee3:	74 51                	je     f0101f36 <mem_init+0xbb8>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101ee5:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101eeb:	8b 00                	mov    (%eax),%eax
f0101eed:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0101ef0:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0101ef3:	05 00 00 00 10       	add    $0x10000000,%eax
	for (i = 0; i < n; i += PGSIZE)
f0101ef8:	bf 00 00 00 00       	mov    $0x0,%edi
f0101efd:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0101f00:	89 c6                	mov    %eax,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101f02:	8d 97 00 00 00 ef    	lea    -0x11000000(%edi),%edx
f0101f08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f0b:	e8 eb eb ff ff       	call   f0100afb <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0101f10:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0101f17:	0f 86 49 0a 00 00    	jbe    f0102966 <mem_init+0x15e8>
f0101f1d:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0101f20:	39 c2                	cmp    %eax,%edx
f0101f22:	0f 85 59 0a 00 00    	jne    f0102981 <mem_init+0x1603>
	for (i = 0; i < n; i += PGSIZE)
f0101f28:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0101f2e:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101f31:	77 cf                	ja     f0101f02 <mem_init+0xb84>
f0101f33:	8b 75 d4             	mov    -0x2c(%ebp),%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0101f36:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0101f39:	c1 e0 0c             	shl    $0xc,%eax
f0101f3c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f3f:	85 c0                	test   %eax,%eax
f0101f41:	0f 84 78 0a 00 00    	je     f01029bf <mem_init+0x1641>
f0101f47:	bf 00 00 00 00       	mov    $0x0,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0101f4c:	8d 97 00 00 00 f0    	lea    -0x10000000(%edi),%edx
f0101f52:	89 f0                	mov    %esi,%eax
f0101f54:	e8 a2 eb ff ff       	call   f0100afb <check_va2pa>
f0101f59:	39 f8                	cmp    %edi,%eax
f0101f5b:	0f 85 3f 0a 00 00    	jne    f01029a0 <mem_init+0x1622>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0101f61:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0101f67:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101f6a:	72 e0                	jb     f0101f4c <mem_init+0xbce>
f0101f6c:	bf 00 80 ff ef       	mov    $0xefff8000,%edi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0101f71:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101f74:	05 00 80 00 20       	add    $0x20008000,%eax
f0101f79:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f7c:	89 fa                	mov    %edi,%edx
f0101f7e:	89 f0                	mov    %esi,%eax
f0101f80:	e8 76 eb ff ff       	call   f0100afb <check_va2pa>
f0101f85:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101f88:	8d 14 39             	lea    (%ecx,%edi,1),%edx
f0101f8b:	39 c2                	cmp    %eax,%edx
f0101f8d:	0f 85 36 0a 00 00    	jne    f01029c9 <mem_init+0x164b>
f0101f93:	81 c7 00 10 00 00    	add    $0x1000,%edi
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0101f99:	81 ff 00 00 00 f0    	cmp    $0xf0000000,%edi
f0101f9f:	75 db                	jne    f0101f7c <mem_init+0xbfe>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0101fa1:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0101fa6:	89 f0                	mov    %esi,%eax
f0101fa8:	e8 4e eb ff ff       	call   f0100afb <check_va2pa>
f0101fad:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fb0:	0f 85 32 0a 00 00    	jne    f01029e8 <mem_init+0x166a>
	for (i = 0; i < NPDENTRIES; i++) {
f0101fb6:	b8 00 00 00 00       	mov    $0x0,%eax
f0101fbb:	e9 5b 0a 00 00       	jmp    f0102a1b <mem_init+0x169d>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101fc0:	8d 88 00 01 00 00    	lea    0x100(%eax),%ecx
f0101fc6:	c7 c2 c4 96 11 f0    	mov    $0xf01196c4,%edx
f0101fcc:	89 0a                	mov    %ecx,(%edx)
f0101fce:	e9 3b f4 ff ff       	jmp    f010140e <mem_init+0x90>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101fd3:	50                   	push   %eax
f0101fd4:	8d 83 5c d7 fe ff    	lea    -0x128a4(%ebx),%eax
f0101fda:	50                   	push   %eax
f0101fdb:	68 8d 00 00 00       	push   $0x8d
f0101fe0:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0101fe6:	50                   	push   %eax
f0101fe7:	e8 ad e0 ff ff       	call   f0100099 <_panic>
		panic("'pages' is a null pointer!");
f0101fec:	83 ec 04             	sub    $0x4,%esp
f0101fef:	8d 83 66 d4 fe ff    	lea    -0x12b9a(%ebx),%eax
f0101ff5:	50                   	push   %eax
f0101ff6:	68 53 02 00 00       	push   $0x253
f0101ffb:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102001:	50                   	push   %eax
f0102002:	e8 92 e0 ff ff       	call   f0100099 <_panic>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102007:	be 00 00 00 00       	mov    $0x0,%esi
f010200c:	e9 b9 f4 ff ff       	jmp    f01014ca <mem_init+0x14c>
	assert((pp0 = page_alloc(0)));
f0102011:	8d 83 81 d4 fe ff    	lea    -0x12b7f(%ebx),%eax
f0102017:	50                   	push   %eax
f0102018:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f010201e:	50                   	push   %eax
f010201f:	68 5b 02 00 00       	push   $0x25b
f0102024:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010202a:	50                   	push   %eax
f010202b:	e8 69 e0 ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f0102030:	8d 83 97 d4 fe ff    	lea    -0x12b69(%ebx),%eax
f0102036:	50                   	push   %eax
f0102037:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f010203d:	50                   	push   %eax
f010203e:	68 5c 02 00 00       	push   $0x25c
f0102043:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102049:	50                   	push   %eax
f010204a:	e8 4a e0 ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f010204f:	8d 83 ad d4 fe ff    	lea    -0x12b53(%ebx),%eax
f0102055:	50                   	push   %eax
f0102056:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f010205c:	50                   	push   %eax
f010205d:	68 5d 02 00 00       	push   $0x25d
f0102062:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102068:	50                   	push   %eax
f0102069:	e8 2b e0 ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f010206e:	8d 83 c3 d4 fe ff    	lea    -0x12b3d(%ebx),%eax
f0102074:	50                   	push   %eax
f0102075:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f010207b:	50                   	push   %eax
f010207c:	68 60 02 00 00       	push   $0x260
f0102081:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102087:	50                   	push   %eax
f0102088:	e8 0c e0 ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010208d:	8d 83 dc d7 fe ff    	lea    -0x12824(%ebx),%eax
f0102093:	50                   	push   %eax
f0102094:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f010209a:	50                   	push   %eax
f010209b:	68 61 02 00 00       	push   $0x261
f01020a0:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01020a6:	50                   	push   %eax
f01020a7:	e8 ed df ff ff       	call   f0100099 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01020ac:	8d 83 d5 d4 fe ff    	lea    -0x12b2b(%ebx),%eax
f01020b2:	50                   	push   %eax
f01020b3:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01020b9:	50                   	push   %eax
f01020ba:	68 62 02 00 00       	push   $0x262
f01020bf:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01020c5:	50                   	push   %eax
f01020c6:	e8 ce df ff ff       	call   f0100099 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01020cb:	8d 83 f2 d4 fe ff    	lea    -0x12b0e(%ebx),%eax
f01020d1:	50                   	push   %eax
f01020d2:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01020d8:	50                   	push   %eax
f01020d9:	68 63 02 00 00       	push   $0x263
f01020de:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01020e4:	50                   	push   %eax
f01020e5:	e8 af df ff ff       	call   f0100099 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01020ea:	8d 83 0f d5 fe ff    	lea    -0x12af1(%ebx),%eax
f01020f0:	50                   	push   %eax
f01020f1:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01020f7:	50                   	push   %eax
f01020f8:	68 64 02 00 00       	push   $0x264
f01020fd:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102103:	50                   	push   %eax
f0102104:	e8 90 df ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f0102109:	8d 83 2c d5 fe ff    	lea    -0x12ad4(%ebx),%eax
f010210f:	50                   	push   %eax
f0102110:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102116:	50                   	push   %eax
f0102117:	68 6b 02 00 00       	push   $0x26b
f010211c:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102122:	50                   	push   %eax
f0102123:	e8 71 df ff ff       	call   f0100099 <_panic>
	assert((pp0 = page_alloc(0)));
f0102128:	8d 83 81 d4 fe ff    	lea    -0x12b7f(%ebx),%eax
f010212e:	50                   	push   %eax
f010212f:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102135:	50                   	push   %eax
f0102136:	68 72 02 00 00       	push   $0x272
f010213b:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102141:	50                   	push   %eax
f0102142:	e8 52 df ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f0102147:	8d 83 97 d4 fe ff    	lea    -0x12b69(%ebx),%eax
f010214d:	50                   	push   %eax
f010214e:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102154:	50                   	push   %eax
f0102155:	68 73 02 00 00       	push   $0x273
f010215a:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102160:	50                   	push   %eax
f0102161:	e8 33 df ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f0102166:	8d 83 ad d4 fe ff    	lea    -0x12b53(%ebx),%eax
f010216c:	50                   	push   %eax
f010216d:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102173:	50                   	push   %eax
f0102174:	68 74 02 00 00       	push   $0x274
f0102179:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010217f:	50                   	push   %eax
f0102180:	e8 14 df ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f0102185:	8d 83 c3 d4 fe ff    	lea    -0x12b3d(%ebx),%eax
f010218b:	50                   	push   %eax
f010218c:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102192:	50                   	push   %eax
f0102193:	68 76 02 00 00       	push   $0x276
f0102198:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010219e:	50                   	push   %eax
f010219f:	e8 f5 de ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01021a4:	8d 83 dc d7 fe ff    	lea    -0x12824(%ebx),%eax
f01021aa:	50                   	push   %eax
f01021ab:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01021b1:	50                   	push   %eax
f01021b2:	68 77 02 00 00       	push   $0x277
f01021b7:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01021bd:	50                   	push   %eax
f01021be:	e8 d6 de ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f01021c3:	8d 83 2c d5 fe ff    	lea    -0x12ad4(%ebx),%eax
f01021c9:	50                   	push   %eax
f01021ca:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01021d0:	50                   	push   %eax
f01021d1:	68 78 02 00 00       	push   $0x278
f01021d6:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01021dc:	50                   	push   %eax
f01021dd:	e8 b7 de ff ff       	call   f0100099 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021e2:	50                   	push   %eax
f01021e3:	8d 83 74 d6 fe ff    	lea    -0x1298c(%ebx),%eax
f01021e9:	50                   	push   %eax
f01021ea:	6a 52                	push   $0x52
f01021ec:	8d 83 bc d3 fe ff    	lea    -0x12c44(%ebx),%eax
f01021f2:	50                   	push   %eax
f01021f3:	e8 a1 de ff ff       	call   f0100099 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01021f8:	8d 83 3b d5 fe ff    	lea    -0x12ac5(%ebx),%eax
f01021fe:	50                   	push   %eax
f01021ff:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102205:	50                   	push   %eax
f0102206:	68 7d 02 00 00       	push   $0x27d
f010220b:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102211:	50                   	push   %eax
f0102212:	e8 82 de ff ff       	call   f0100099 <_panic>
	assert(pp && pp0 == pp);
f0102217:	8d 83 59 d5 fe ff    	lea    -0x12aa7(%ebx),%eax
f010221d:	50                   	push   %eax
f010221e:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102224:	50                   	push   %eax
f0102225:	68 7e 02 00 00       	push   $0x27e
f010222a:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102230:	50                   	push   %eax
f0102231:	e8 63 de ff ff       	call   f0100099 <_panic>
f0102236:	52                   	push   %edx
f0102237:	8d 83 74 d6 fe ff    	lea    -0x1298c(%ebx),%eax
f010223d:	50                   	push   %eax
f010223e:	6a 52                	push   $0x52
f0102240:	8d 83 bc d3 fe ff    	lea    -0x12c44(%ebx),%eax
f0102246:	50                   	push   %eax
f0102247:	e8 4d de ff ff       	call   f0100099 <_panic>
		assert(c[i] == 0);
f010224c:	8d 83 69 d5 fe ff    	lea    -0x12a97(%ebx),%eax
f0102252:	50                   	push   %eax
f0102253:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102259:	50                   	push   %eax
f010225a:	68 81 02 00 00       	push   $0x281
f010225f:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102265:	50                   	push   %eax
f0102266:	e8 2e de ff ff       	call   f0100099 <_panic>
	assert(nfree == 0);
f010226b:	8d 83 73 d5 fe ff    	lea    -0x12a8d(%ebx),%eax
f0102271:	50                   	push   %eax
f0102272:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102278:	50                   	push   %eax
f0102279:	68 8e 02 00 00       	push   $0x28e
f010227e:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102284:	50                   	push   %eax
f0102285:	e8 0f de ff ff       	call   f0100099 <_panic>
	assert((pp0 = page_alloc(0)));
f010228a:	8d 83 81 d4 fe ff    	lea    -0x12b7f(%ebx),%eax
f0102290:	50                   	push   %eax
f0102291:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102297:	50                   	push   %eax
f0102298:	68 e6 02 00 00       	push   $0x2e6
f010229d:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01022a3:	50                   	push   %eax
f01022a4:	e8 f0 dd ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f01022a9:	8d 83 97 d4 fe ff    	lea    -0x12b69(%ebx),%eax
f01022af:	50                   	push   %eax
f01022b0:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01022b6:	50                   	push   %eax
f01022b7:	68 e7 02 00 00       	push   $0x2e7
f01022bc:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01022c2:	50                   	push   %eax
f01022c3:	e8 d1 dd ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f01022c8:	8d 83 ad d4 fe ff    	lea    -0x12b53(%ebx),%eax
f01022ce:	50                   	push   %eax
f01022cf:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01022d5:	50                   	push   %eax
f01022d6:	68 e8 02 00 00       	push   $0x2e8
f01022db:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01022e1:	50                   	push   %eax
f01022e2:	e8 b2 dd ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f01022e7:	8d 83 c3 d4 fe ff    	lea    -0x12b3d(%ebx),%eax
f01022ed:	50                   	push   %eax
f01022ee:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01022f4:	50                   	push   %eax
f01022f5:	68 eb 02 00 00       	push   $0x2eb
f01022fa:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102300:	50                   	push   %eax
f0102301:	e8 93 dd ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102306:	8d 83 dc d7 fe ff    	lea    -0x12824(%ebx),%eax
f010230c:	50                   	push   %eax
f010230d:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102313:	50                   	push   %eax
f0102314:	68 ec 02 00 00       	push   $0x2ec
f0102319:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010231f:	50                   	push   %eax
f0102320:	e8 74 dd ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f0102325:	8d 83 2c d5 fe ff    	lea    -0x12ad4(%ebx),%eax
f010232b:	50                   	push   %eax
f010232c:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102332:	50                   	push   %eax
f0102333:	68 f3 02 00 00       	push   $0x2f3
f0102338:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010233e:	50                   	push   %eax
f010233f:	e8 55 dd ff ff       	call   f0100099 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102344:	8d 83 1c d8 fe ff    	lea    -0x127e4(%ebx),%eax
f010234a:	50                   	push   %eax
f010234b:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102351:	50                   	push   %eax
f0102352:	68 f6 02 00 00       	push   $0x2f6
f0102357:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010235d:	50                   	push   %eax
f010235e:	e8 36 dd ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102363:	8d 83 54 d8 fe ff    	lea    -0x127ac(%ebx),%eax
f0102369:	50                   	push   %eax
f010236a:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102370:	50                   	push   %eax
f0102371:	68 f9 02 00 00       	push   $0x2f9
f0102376:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010237c:	50                   	push   %eax
f010237d:	e8 17 dd ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102382:	8d 83 84 d8 fe ff    	lea    -0x1277c(%ebx),%eax
f0102388:	50                   	push   %eax
f0102389:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f010238f:	50                   	push   %eax
f0102390:	68 fd 02 00 00       	push   $0x2fd
f0102395:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010239b:	50                   	push   %eax
f010239c:	e8 f8 dc ff ff       	call   f0100099 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023a1:	8d 83 b4 d8 fe ff    	lea    -0x1274c(%ebx),%eax
f01023a7:	50                   	push   %eax
f01023a8:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01023ae:	50                   	push   %eax
f01023af:	68 fe 02 00 00       	push   $0x2fe
f01023b4:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01023ba:	50                   	push   %eax
f01023bb:	e8 d9 dc ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01023c0:	8d 83 dc d8 fe ff    	lea    -0x12724(%ebx),%eax
f01023c6:	50                   	push   %eax
f01023c7:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01023cd:	50                   	push   %eax
f01023ce:	68 ff 02 00 00       	push   $0x2ff
f01023d3:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01023d9:	50                   	push   %eax
f01023da:	e8 ba dc ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 1);
f01023df:	8d 83 7e d5 fe ff    	lea    -0x12a82(%ebx),%eax
f01023e5:	50                   	push   %eax
f01023e6:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01023ec:	50                   	push   %eax
f01023ed:	68 00 03 00 00       	push   $0x300
f01023f2:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01023f8:	50                   	push   %eax
f01023f9:	e8 9b dc ff ff       	call   f0100099 <_panic>
	assert(pp0->pp_ref == 1);
f01023fe:	8d 83 8f d5 fe ff    	lea    -0x12a71(%ebx),%eax
f0102404:	50                   	push   %eax
f0102405:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f010240b:	50                   	push   %eax
f010240c:	68 01 03 00 00       	push   $0x301
f0102411:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102417:	50                   	push   %eax
f0102418:	e8 7c dc ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010241d:	8d 83 0c d9 fe ff    	lea    -0x126f4(%ebx),%eax
f0102423:	50                   	push   %eax
f0102424:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f010242a:	50                   	push   %eax
f010242b:	68 04 03 00 00       	push   $0x304
f0102430:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102436:	50                   	push   %eax
f0102437:	e8 5d dc ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010243c:	8d 83 48 d9 fe ff    	lea    -0x126b8(%ebx),%eax
f0102442:	50                   	push   %eax
f0102443:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102449:	50                   	push   %eax
f010244a:	68 05 03 00 00       	push   $0x305
f010244f:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102455:	50                   	push   %eax
f0102456:	e8 3e dc ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f010245b:	8d 83 a0 d5 fe ff    	lea    -0x12a60(%ebx),%eax
f0102461:	50                   	push   %eax
f0102462:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102468:	50                   	push   %eax
f0102469:	68 06 03 00 00       	push   $0x306
f010246e:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102474:	50                   	push   %eax
f0102475:	e8 1f dc ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f010247a:	8d 83 2c d5 fe ff    	lea    -0x12ad4(%ebx),%eax
f0102480:	50                   	push   %eax
f0102481:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102487:	50                   	push   %eax
f0102488:	68 09 03 00 00       	push   $0x309
f010248d:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102493:	50                   	push   %eax
f0102494:	e8 00 dc ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102499:	8d 83 0c d9 fe ff    	lea    -0x126f4(%ebx),%eax
f010249f:	50                   	push   %eax
f01024a0:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01024a6:	50                   	push   %eax
f01024a7:	68 0c 03 00 00       	push   $0x30c
f01024ac:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01024b2:	50                   	push   %eax
f01024b3:	e8 e1 db ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024b8:	8d 83 48 d9 fe ff    	lea    -0x126b8(%ebx),%eax
f01024be:	50                   	push   %eax
f01024bf:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01024c5:	50                   	push   %eax
f01024c6:	68 0d 03 00 00       	push   $0x30d
f01024cb:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01024d1:	50                   	push   %eax
f01024d2:	e8 c2 db ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f01024d7:	8d 83 a0 d5 fe ff    	lea    -0x12a60(%ebx),%eax
f01024dd:	50                   	push   %eax
f01024de:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01024e4:	50                   	push   %eax
f01024e5:	68 0e 03 00 00       	push   $0x30e
f01024ea:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01024f0:	50                   	push   %eax
f01024f1:	e8 a3 db ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f01024f6:	8d 83 2c d5 fe ff    	lea    -0x12ad4(%ebx),%eax
f01024fc:	50                   	push   %eax
f01024fd:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102503:	50                   	push   %eax
f0102504:	68 12 03 00 00       	push   $0x312
f0102509:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010250f:	50                   	push   %eax
f0102510:	e8 84 db ff ff       	call   f0100099 <_panic>
f0102515:	50                   	push   %eax
f0102516:	8d 83 74 d6 fe ff    	lea    -0x1298c(%ebx),%eax
f010251c:	50                   	push   %eax
f010251d:	68 15 03 00 00       	push   $0x315
f0102522:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102528:	50                   	push   %eax
f0102529:	e8 6b db ff ff       	call   f0100099 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010252e:	8d 83 78 d9 fe ff    	lea    -0x12688(%ebx),%eax
f0102534:	50                   	push   %eax
f0102535:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f010253b:	50                   	push   %eax
f010253c:	68 16 03 00 00       	push   $0x316
f0102541:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102547:	50                   	push   %eax
f0102548:	e8 4c db ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010254d:	8d 83 b8 d9 fe ff    	lea    -0x12648(%ebx),%eax
f0102553:	50                   	push   %eax
f0102554:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f010255a:	50                   	push   %eax
f010255b:	68 19 03 00 00       	push   $0x319
f0102560:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102566:	50                   	push   %eax
f0102567:	e8 2d db ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010256c:	8d 83 48 d9 fe ff    	lea    -0x126b8(%ebx),%eax
f0102572:	50                   	push   %eax
f0102573:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102579:	50                   	push   %eax
f010257a:	68 1a 03 00 00       	push   $0x31a
f010257f:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102585:	50                   	push   %eax
f0102586:	e8 0e db ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f010258b:	8d 83 a0 d5 fe ff    	lea    -0x12a60(%ebx),%eax
f0102591:	50                   	push   %eax
f0102592:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102598:	50                   	push   %eax
f0102599:	68 1b 03 00 00       	push   $0x31b
f010259e:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01025a4:	50                   	push   %eax
f01025a5:	e8 ef da ff ff       	call   f0100099 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01025aa:	8d 83 f8 d9 fe ff    	lea    -0x12608(%ebx),%eax
f01025b0:	50                   	push   %eax
f01025b1:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01025b7:	50                   	push   %eax
f01025b8:	68 1c 03 00 00       	push   $0x31c
f01025bd:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01025c3:	50                   	push   %eax
f01025c4:	e8 d0 da ff ff       	call   f0100099 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01025c9:	8d 83 b1 d5 fe ff    	lea    -0x12a4f(%ebx),%eax
f01025cf:	50                   	push   %eax
f01025d0:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01025d6:	50                   	push   %eax
f01025d7:	68 1d 03 00 00       	push   $0x31d
f01025dc:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01025e2:	50                   	push   %eax
f01025e3:	e8 b1 da ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01025e8:	8d 83 0c d9 fe ff    	lea    -0x126f4(%ebx),%eax
f01025ee:	50                   	push   %eax
f01025ef:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01025f5:	50                   	push   %eax
f01025f6:	68 20 03 00 00       	push   $0x320
f01025fb:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102601:	50                   	push   %eax
f0102602:	e8 92 da ff ff       	call   f0100099 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102607:	8d 83 2c da fe ff    	lea    -0x125d4(%ebx),%eax
f010260d:	50                   	push   %eax
f010260e:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102614:	50                   	push   %eax
f0102615:	68 21 03 00 00       	push   $0x321
f010261a:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102620:	50                   	push   %eax
f0102621:	e8 73 da ff ff       	call   f0100099 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102626:	8d 83 60 da fe ff    	lea    -0x125a0(%ebx),%eax
f010262c:	50                   	push   %eax
f010262d:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102633:	50                   	push   %eax
f0102634:	68 22 03 00 00       	push   $0x322
f0102639:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010263f:	50                   	push   %eax
f0102640:	e8 54 da ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102645:	8d 83 98 da fe ff    	lea    -0x12568(%ebx),%eax
f010264b:	50                   	push   %eax
f010264c:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102652:	50                   	push   %eax
f0102653:	68 25 03 00 00       	push   $0x325
f0102658:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010265e:	50                   	push   %eax
f010265f:	e8 35 da ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102664:	8d 83 d0 da fe ff    	lea    -0x12530(%ebx),%eax
f010266a:	50                   	push   %eax
f010266b:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102671:	50                   	push   %eax
f0102672:	68 28 03 00 00       	push   $0x328
f0102677:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010267d:	50                   	push   %eax
f010267e:	e8 16 da ff ff       	call   f0100099 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102683:	8d 83 60 da fe ff    	lea    -0x125a0(%ebx),%eax
f0102689:	50                   	push   %eax
f010268a:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102690:	50                   	push   %eax
f0102691:	68 29 03 00 00       	push   $0x329
f0102696:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010269c:	50                   	push   %eax
f010269d:	e8 f7 d9 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01026a2:	8d 83 0c db fe ff    	lea    -0x124f4(%ebx),%eax
f01026a8:	50                   	push   %eax
f01026a9:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01026af:	50                   	push   %eax
f01026b0:	68 2c 03 00 00       	push   $0x32c
f01026b5:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01026bb:	50                   	push   %eax
f01026bc:	e8 d8 d9 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026c1:	8d 83 38 db fe ff    	lea    -0x124c8(%ebx),%eax
f01026c7:	50                   	push   %eax
f01026c8:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01026ce:	50                   	push   %eax
f01026cf:	68 2d 03 00 00       	push   $0x32d
f01026d4:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01026da:	50                   	push   %eax
f01026db:	e8 b9 d9 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 2);
f01026e0:	8d 83 c7 d5 fe ff    	lea    -0x12a39(%ebx),%eax
f01026e6:	50                   	push   %eax
f01026e7:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01026ed:	50                   	push   %eax
f01026ee:	68 2f 03 00 00       	push   $0x32f
f01026f3:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01026f9:	50                   	push   %eax
f01026fa:	e8 9a d9 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f01026ff:	8d 83 d8 d5 fe ff    	lea    -0x12a28(%ebx),%eax
f0102705:	50                   	push   %eax
f0102706:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f010270c:	50                   	push   %eax
f010270d:	68 30 03 00 00       	push   $0x330
f0102712:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102718:	50                   	push   %eax
f0102719:	e8 7b d9 ff ff       	call   f0100099 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f010271e:	8d 83 68 db fe ff    	lea    -0x12498(%ebx),%eax
f0102724:	50                   	push   %eax
f0102725:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f010272b:	50                   	push   %eax
f010272c:	68 33 03 00 00       	push   $0x333
f0102731:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102737:	50                   	push   %eax
f0102738:	e8 5c d9 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010273d:	8d 83 8c db fe ff    	lea    -0x12474(%ebx),%eax
f0102743:	50                   	push   %eax
f0102744:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f010274a:	50                   	push   %eax
f010274b:	68 37 03 00 00       	push   $0x337
f0102750:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102756:	50                   	push   %eax
f0102757:	e8 3d d9 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010275c:	8d 83 38 db fe ff    	lea    -0x124c8(%ebx),%eax
f0102762:	50                   	push   %eax
f0102763:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102769:	50                   	push   %eax
f010276a:	68 38 03 00 00       	push   $0x338
f010276f:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102775:	50                   	push   %eax
f0102776:	e8 1e d9 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 1);
f010277b:	8d 83 7e d5 fe ff    	lea    -0x12a82(%ebx),%eax
f0102781:	50                   	push   %eax
f0102782:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102788:	50                   	push   %eax
f0102789:	68 39 03 00 00       	push   $0x339
f010278e:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102794:	50                   	push   %eax
f0102795:	e8 ff d8 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f010279a:	8d 83 d8 d5 fe ff    	lea    -0x12a28(%ebx),%eax
f01027a0:	50                   	push   %eax
f01027a1:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01027a7:	50                   	push   %eax
f01027a8:	68 3a 03 00 00       	push   $0x33a
f01027ad:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01027b3:	50                   	push   %eax
f01027b4:	e8 e0 d8 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027b9:	8d 83 8c db fe ff    	lea    -0x12474(%ebx),%eax
f01027bf:	50                   	push   %eax
f01027c0:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01027c6:	50                   	push   %eax
f01027c7:	68 3e 03 00 00       	push   $0x33e
f01027cc:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01027d2:	50                   	push   %eax
f01027d3:	e8 c1 d8 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01027d8:	8d 83 b0 db fe ff    	lea    -0x12450(%ebx),%eax
f01027de:	50                   	push   %eax
f01027df:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01027e5:	50                   	push   %eax
f01027e6:	68 3f 03 00 00       	push   $0x33f
f01027eb:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01027f1:	50                   	push   %eax
f01027f2:	e8 a2 d8 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 0);
f01027f7:	8d 83 e9 d5 fe ff    	lea    -0x12a17(%ebx),%eax
f01027fd:	50                   	push   %eax
f01027fe:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102804:	50                   	push   %eax
f0102805:	68 40 03 00 00       	push   $0x340
f010280a:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102810:	50                   	push   %eax
f0102811:	e8 83 d8 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f0102816:	8d 83 d8 d5 fe ff    	lea    -0x12a28(%ebx),%eax
f010281c:	50                   	push   %eax
f010281d:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102823:	50                   	push   %eax
f0102824:	68 41 03 00 00       	push   $0x341
f0102829:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010282f:	50                   	push   %eax
f0102830:	e8 64 d8 ff ff       	call   f0100099 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102835:	8d 83 d8 db fe ff    	lea    -0x12428(%ebx),%eax
f010283b:	50                   	push   %eax
f010283c:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102842:	50                   	push   %eax
f0102843:	68 44 03 00 00       	push   $0x344
f0102848:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010284e:	50                   	push   %eax
f010284f:	e8 45 d8 ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f0102854:	8d 83 2c d5 fe ff    	lea    -0x12ad4(%ebx),%eax
f010285a:	50                   	push   %eax
f010285b:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102861:	50                   	push   %eax
f0102862:	68 47 03 00 00       	push   $0x347
f0102867:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010286d:	50                   	push   %eax
f010286e:	e8 26 d8 ff ff       	call   f0100099 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102873:	8d 83 b4 d8 fe ff    	lea    -0x1274c(%ebx),%eax
f0102879:	50                   	push   %eax
f010287a:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102880:	50                   	push   %eax
f0102881:	68 4a 03 00 00       	push   $0x34a
f0102886:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010288c:	50                   	push   %eax
f010288d:	e8 07 d8 ff ff       	call   f0100099 <_panic>
	assert(pp0->pp_ref == 1);
f0102892:	8d 83 8f d5 fe ff    	lea    -0x12a71(%ebx),%eax
f0102898:	50                   	push   %eax
f0102899:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f010289f:	50                   	push   %eax
f01028a0:	68 4c 03 00 00       	push   $0x34c
f01028a5:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01028ab:	50                   	push   %eax
f01028ac:	e8 e8 d7 ff ff       	call   f0100099 <_panic>
f01028b1:	52                   	push   %edx
f01028b2:	8d 83 74 d6 fe ff    	lea    -0x1298c(%ebx),%eax
f01028b8:	50                   	push   %eax
f01028b9:	68 53 03 00 00       	push   $0x353
f01028be:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01028c4:	50                   	push   %eax
f01028c5:	e8 cf d7 ff ff       	call   f0100099 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01028ca:	8d 83 fa d5 fe ff    	lea    -0x12a06(%ebx),%eax
f01028d0:	50                   	push   %eax
f01028d1:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01028d7:	50                   	push   %eax
f01028d8:	68 54 03 00 00       	push   $0x354
f01028dd:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01028e3:	50                   	push   %eax
f01028e4:	e8 b0 d7 ff ff       	call   f0100099 <_panic>
f01028e9:	50                   	push   %eax
f01028ea:	8d 83 74 d6 fe ff    	lea    -0x1298c(%ebx),%eax
f01028f0:	50                   	push   %eax
f01028f1:	6a 52                	push   $0x52
f01028f3:	8d 83 bc d3 fe ff    	lea    -0x12c44(%ebx),%eax
f01028f9:	50                   	push   %eax
f01028fa:	e8 9a d7 ff ff       	call   f0100099 <_panic>
f01028ff:	52                   	push   %edx
f0102900:	8d 83 74 d6 fe ff    	lea    -0x1298c(%ebx),%eax
f0102906:	50                   	push   %eax
f0102907:	6a 52                	push   $0x52
f0102909:	8d 83 bc d3 fe ff    	lea    -0x12c44(%ebx),%eax
f010290f:	50                   	push   %eax
f0102910:	e8 84 d7 ff ff       	call   f0100099 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102915:	8d 83 12 d6 fe ff    	lea    -0x129ee(%ebx),%eax
f010291b:	50                   	push   %eax
f010291c:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102922:	50                   	push   %eax
f0102923:	68 5e 03 00 00       	push   $0x35e
f0102928:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010292e:	50                   	push   %eax
f010292f:	e8 65 d7 ff ff       	call   f0100099 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102934:	50                   	push   %eax
f0102935:	8d 83 5c d7 fe ff    	lea    -0x128a4(%ebx),%eax
f010293b:	50                   	push   %eax
f010293c:	68 ad 00 00 00       	push   $0xad
f0102941:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102947:	50                   	push   %eax
f0102948:	e8 4c d7 ff ff       	call   f0100099 <_panic>
f010294d:	50                   	push   %eax
f010294e:	8d 83 5c d7 fe ff    	lea    -0x128a4(%ebx),%eax
f0102954:	50                   	push   %eax
f0102955:	68 ba 00 00 00       	push   $0xba
f010295a:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102960:	50                   	push   %eax
f0102961:	e8 33 d7 ff ff       	call   f0100099 <_panic>
f0102966:	ff 75 c0             	pushl  -0x40(%ebp)
f0102969:	8d 83 5c d7 fe ff    	lea    -0x128a4(%ebx),%eax
f010296f:	50                   	push   %eax
f0102970:	68 a6 02 00 00       	push   $0x2a6
f0102975:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010297b:	50                   	push   %eax
f010297c:	e8 18 d7 ff ff       	call   f0100099 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102981:	8d 83 fc db fe ff    	lea    -0x12404(%ebx),%eax
f0102987:	50                   	push   %eax
f0102988:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f010298e:	50                   	push   %eax
f010298f:	68 a6 02 00 00       	push   $0x2a6
f0102994:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f010299a:	50                   	push   %eax
f010299b:	e8 f9 d6 ff ff       	call   f0100099 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029a0:	8d 83 30 dc fe ff    	lea    -0x123d0(%ebx),%eax
f01029a6:	50                   	push   %eax
f01029a7:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01029ad:	50                   	push   %eax
f01029ae:	68 aa 02 00 00       	push   $0x2aa
f01029b3:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01029b9:	50                   	push   %eax
f01029ba:	e8 da d6 ff ff       	call   f0100099 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029bf:	bf 00 80 ff ef       	mov    $0xefff8000,%edi
f01029c4:	e9 a8 f5 ff ff       	jmp    f0101f71 <mem_init+0xbf3>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01029c9:	8d 83 58 dc fe ff    	lea    -0x123a8(%ebx),%eax
f01029cf:	50                   	push   %eax
f01029d0:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01029d6:	50                   	push   %eax
f01029d7:	68 ae 02 00 00       	push   $0x2ae
f01029dc:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01029e2:	50                   	push   %eax
f01029e3:	e8 b1 d6 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01029e8:	8d 83 a0 dc fe ff    	lea    -0x12360(%ebx),%eax
f01029ee:	50                   	push   %eax
f01029ef:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f01029f5:	50                   	push   %eax
f01029f6:	68 af 02 00 00       	push   $0x2af
f01029fb:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102a01:	50                   	push   %eax
f0102a02:	e8 92 d6 ff ff       	call   f0100099 <_panic>
			assert(pgdir[i] & PTE_P);
f0102a07:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102a0b:	74 4f                	je     f0102a5c <mem_init+0x16de>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a0d:	83 c0 01             	add    $0x1,%eax
f0102a10:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102a15:	0f 84 ab 00 00 00    	je     f0102ac6 <mem_init+0x1748>
		switch (i) {
f0102a1b:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102a20:	72 0e                	jb     f0102a30 <mem_init+0x16b2>
f0102a22:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102a27:	76 de                	jbe    f0102a07 <mem_init+0x1689>
f0102a29:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a2e:	74 d7                	je     f0102a07 <mem_init+0x1689>
			if (i >= PDX(KERNBASE)) {
f0102a30:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a35:	77 44                	ja     f0102a7b <mem_init+0x16fd>
				assert(pgdir[i] == 0);
f0102a37:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102a3b:	74 d0                	je     f0102a0d <mem_init+0x168f>
f0102a3d:	8d 83 64 d6 fe ff    	lea    -0x1299c(%ebx),%eax
f0102a43:	50                   	push   %eax
f0102a44:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102a4a:	50                   	push   %eax
f0102a4b:	68 be 02 00 00       	push   $0x2be
f0102a50:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102a56:	50                   	push   %eax
f0102a57:	e8 3d d6 ff ff       	call   f0100099 <_panic>
			assert(pgdir[i] & PTE_P);
f0102a5c:	8d 83 42 d6 fe ff    	lea    -0x129be(%ebx),%eax
f0102a62:	50                   	push   %eax
f0102a63:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102a69:	50                   	push   %eax
f0102a6a:	68 b7 02 00 00       	push   $0x2b7
f0102a6f:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102a75:	50                   	push   %eax
f0102a76:	e8 1e d6 ff ff       	call   f0100099 <_panic>
				assert(pgdir[i] & PTE_P);
f0102a7b:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102a7e:	f6 c2 01             	test   $0x1,%dl
f0102a81:	74 24                	je     f0102aa7 <mem_init+0x1729>
				assert(pgdir[i] & PTE_W);
f0102a83:	f6 c2 02             	test   $0x2,%dl
f0102a86:	75 85                	jne    f0102a0d <mem_init+0x168f>
f0102a88:	8d 83 53 d6 fe ff    	lea    -0x129ad(%ebx),%eax
f0102a8e:	50                   	push   %eax
f0102a8f:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102a95:	50                   	push   %eax
f0102a96:	68 bc 02 00 00       	push   $0x2bc
f0102a9b:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102aa1:	50                   	push   %eax
f0102aa2:	e8 f2 d5 ff ff       	call   f0100099 <_panic>
				assert(pgdir[i] & PTE_P);
f0102aa7:	8d 83 42 d6 fe ff    	lea    -0x129be(%ebx),%eax
f0102aad:	50                   	push   %eax
f0102aae:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102ab4:	50                   	push   %eax
f0102ab5:	68 bb 02 00 00       	push   $0x2bb
f0102aba:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102ac0:	50                   	push   %eax
f0102ac1:	e8 d3 d5 ff ff       	call   f0100099 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102ac6:	83 ec 0c             	sub    $0xc,%esp
f0102ac9:	8d 83 d0 dc fe ff    	lea    -0x12330(%ebx),%eax
f0102acf:	50                   	push   %eax
f0102ad0:	e8 ab 04 00 00       	call   f0102f80 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102ad5:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0102adb:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102add:	83 c4 10             	add    $0x10,%esp
f0102ae0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ae5:	0f 86 28 02 00 00    	jbe    f0102d13 <mem_init+0x1995>
	return (physaddr_t)kva - KERNBASE;
f0102aeb:	05 00 00 00 10       	add    $0x10000000,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102af0:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102af3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102af8:	e8 7b e0 ff ff       	call   f0100b78 <check_page_free_list>
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102afd:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b00:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b03:	0d 23 00 05 80       	or     $0x80050023,%eax
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102b08:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b0b:	83 ec 0c             	sub    $0xc,%esp
f0102b0e:	6a 00                	push   $0x0
f0102b10:	e8 35 e5 ff ff       	call   f010104a <page_alloc>
f0102b15:	89 c6                	mov    %eax,%esi
f0102b17:	83 c4 10             	add    $0x10,%esp
f0102b1a:	85 c0                	test   %eax,%eax
f0102b1c:	0f 84 0a 02 00 00    	je     f0102d2c <mem_init+0x19ae>
	assert((pp1 = page_alloc(0)));
f0102b22:	83 ec 0c             	sub    $0xc,%esp
f0102b25:	6a 00                	push   $0x0
f0102b27:	e8 1e e5 ff ff       	call   f010104a <page_alloc>
f0102b2c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b2f:	83 c4 10             	add    $0x10,%esp
f0102b32:	85 c0                	test   %eax,%eax
f0102b34:	0f 84 11 02 00 00    	je     f0102d4b <mem_init+0x19cd>
	assert((pp2 = page_alloc(0)));
f0102b3a:	83 ec 0c             	sub    $0xc,%esp
f0102b3d:	6a 00                	push   $0x0
f0102b3f:	e8 06 e5 ff ff       	call   f010104a <page_alloc>
f0102b44:	89 c7                	mov    %eax,%edi
f0102b46:	83 c4 10             	add    $0x10,%esp
f0102b49:	85 c0                	test   %eax,%eax
f0102b4b:	0f 84 19 02 00 00    	je     f0102d6a <mem_init+0x19ec>
	page_free(pp0);
f0102b51:	83 ec 0c             	sub    $0xc,%esp
f0102b54:	56                   	push   %esi
f0102b55:	e8 78 e5 ff ff       	call   f01010d2 <page_free>
	return (pp - pages) << PGSHIFT;
f0102b5a:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0102b60:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102b63:	2b 08                	sub    (%eax),%ecx
f0102b65:	89 c8                	mov    %ecx,%eax
f0102b67:	c1 f8 03             	sar    $0x3,%eax
f0102b6a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102b6d:	89 c1                	mov    %eax,%ecx
f0102b6f:	c1 e9 0c             	shr    $0xc,%ecx
f0102b72:	83 c4 10             	add    $0x10,%esp
f0102b75:	c7 c2 c4 96 11 f0    	mov    $0xf01196c4,%edx
f0102b7b:	3b 0a                	cmp    (%edx),%ecx
f0102b7d:	0f 83 06 02 00 00    	jae    f0102d89 <mem_init+0x1a0b>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b83:	83 ec 04             	sub    $0x4,%esp
f0102b86:	68 00 10 00 00       	push   $0x1000
f0102b8b:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102b8d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b92:	50                   	push   %eax
f0102b93:	e8 b2 11 00 00       	call   f0103d4a <memset>
	return (pp - pages) << PGSHIFT;
f0102b98:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0102b9e:	89 f9                	mov    %edi,%ecx
f0102ba0:	2b 08                	sub    (%eax),%ecx
f0102ba2:	89 c8                	mov    %ecx,%eax
f0102ba4:	c1 f8 03             	sar    $0x3,%eax
f0102ba7:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102baa:	89 c1                	mov    %eax,%ecx
f0102bac:	c1 e9 0c             	shr    $0xc,%ecx
f0102baf:	83 c4 10             	add    $0x10,%esp
f0102bb2:	c7 c2 c4 96 11 f0    	mov    $0xf01196c4,%edx
f0102bb8:	3b 0a                	cmp    (%edx),%ecx
f0102bba:	0f 83 df 01 00 00    	jae    f0102d9f <mem_init+0x1a21>
	memset(page2kva(pp2), 2, PGSIZE);
f0102bc0:	83 ec 04             	sub    $0x4,%esp
f0102bc3:	68 00 10 00 00       	push   $0x1000
f0102bc8:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102bca:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102bcf:	50                   	push   %eax
f0102bd0:	e8 75 11 00 00       	call   f0103d4a <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102bd5:	6a 02                	push   $0x2
f0102bd7:	68 00 10 00 00       	push   $0x1000
f0102bdc:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102bdf:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0102be5:	ff 30                	pushl  (%eax)
f0102be7:	e8 0e e7 ff ff       	call   f01012fa <page_insert>
	assert(pp1->pp_ref == 1);
f0102bec:	83 c4 20             	add    $0x20,%esp
f0102bef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bf2:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102bf7:	0f 85 b8 01 00 00    	jne    f0102db5 <mem_init+0x1a37>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102bfd:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c04:	01 01 01 
f0102c07:	0f 85 c7 01 00 00    	jne    f0102dd4 <mem_init+0x1a56>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c0d:	6a 02                	push   $0x2
f0102c0f:	68 00 10 00 00       	push   $0x1000
f0102c14:	57                   	push   %edi
f0102c15:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0102c1b:	ff 30                	pushl  (%eax)
f0102c1d:	e8 d8 e6 ff ff       	call   f01012fa <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c22:	83 c4 10             	add    $0x10,%esp
f0102c25:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c2c:	02 02 02 
f0102c2f:	0f 85 be 01 00 00    	jne    f0102df3 <mem_init+0x1a75>
	assert(pp2->pp_ref == 1);
f0102c35:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c3a:	0f 85 d2 01 00 00    	jne    f0102e12 <mem_init+0x1a94>
	assert(pp1->pp_ref == 0);
f0102c40:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c43:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102c48:	0f 85 e3 01 00 00    	jne    f0102e31 <mem_init+0x1ab3>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c4e:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c55:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102c58:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0102c5e:	89 f9                	mov    %edi,%ecx
f0102c60:	2b 08                	sub    (%eax),%ecx
f0102c62:	89 c8                	mov    %ecx,%eax
f0102c64:	c1 f8 03             	sar    $0x3,%eax
f0102c67:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c6a:	89 c1                	mov    %eax,%ecx
f0102c6c:	c1 e9 0c             	shr    $0xc,%ecx
f0102c6f:	c7 c2 c4 96 11 f0    	mov    $0xf01196c4,%edx
f0102c75:	3b 0a                	cmp    (%edx),%ecx
f0102c77:	0f 83 d3 01 00 00    	jae    f0102e50 <mem_init+0x1ad2>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c7d:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c84:	03 03 03 
f0102c87:	0f 85 d9 01 00 00    	jne    f0102e66 <mem_init+0x1ae8>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c8d:	83 ec 08             	sub    $0x8,%esp
f0102c90:	68 00 10 00 00       	push   $0x1000
f0102c95:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0102c9b:	ff 30                	pushl  (%eax)
f0102c9d:	e8 14 e6 ff ff       	call   f01012b6 <page_remove>
	assert(pp2->pp_ref == 0);
f0102ca2:	83 c4 10             	add    $0x10,%esp
f0102ca5:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102caa:	0f 85 d5 01 00 00    	jne    f0102e85 <mem_init+0x1b07>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102cb0:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0102cb6:	8b 08                	mov    (%eax),%ecx
f0102cb8:	8b 11                	mov    (%ecx),%edx
f0102cba:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102cc0:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0102cc6:	89 f7                	mov    %esi,%edi
f0102cc8:	2b 38                	sub    (%eax),%edi
f0102cca:	89 f8                	mov    %edi,%eax
f0102ccc:	c1 f8 03             	sar    $0x3,%eax
f0102ccf:	c1 e0 0c             	shl    $0xc,%eax
f0102cd2:	39 c2                	cmp    %eax,%edx
f0102cd4:	0f 85 ca 01 00 00    	jne    f0102ea4 <mem_init+0x1b26>
	kern_pgdir[0] = 0;
f0102cda:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102ce0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102ce5:	0f 85 d8 01 00 00    	jne    f0102ec3 <mem_init+0x1b45>
	pp0->pp_ref = 0;
f0102ceb:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102cf1:	83 ec 0c             	sub    $0xc,%esp
f0102cf4:	56                   	push   %esi
f0102cf5:	e8 d8 e3 ff ff       	call   f01010d2 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102cfa:	8d 83 64 dd fe ff    	lea    -0x1229c(%ebx),%eax
f0102d00:	89 04 24             	mov    %eax,(%esp)
f0102d03:	e8 78 02 00 00       	call   f0102f80 <cprintf>
}
f0102d08:	83 c4 10             	add    $0x10,%esp
f0102d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d0e:	5b                   	pop    %ebx
f0102d0f:	5e                   	pop    %esi
f0102d10:	5f                   	pop    %edi
f0102d11:	5d                   	pop    %ebp
f0102d12:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d13:	50                   	push   %eax
f0102d14:	8d 83 5c d7 fe ff    	lea    -0x128a4(%ebx),%eax
f0102d1a:	50                   	push   %eax
f0102d1b:	68 d0 00 00 00       	push   $0xd0
f0102d20:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102d26:	50                   	push   %eax
f0102d27:	e8 6d d3 ff ff       	call   f0100099 <_panic>
	assert((pp0 = page_alloc(0)));
f0102d2c:	8d 83 81 d4 fe ff    	lea    -0x12b7f(%ebx),%eax
f0102d32:	50                   	push   %eax
f0102d33:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102d39:	50                   	push   %eax
f0102d3a:	68 79 03 00 00       	push   $0x379
f0102d3f:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102d45:	50                   	push   %eax
f0102d46:	e8 4e d3 ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f0102d4b:	8d 83 97 d4 fe ff    	lea    -0x12b69(%ebx),%eax
f0102d51:	50                   	push   %eax
f0102d52:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102d58:	50                   	push   %eax
f0102d59:	68 7a 03 00 00       	push   $0x37a
f0102d5e:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102d64:	50                   	push   %eax
f0102d65:	e8 2f d3 ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f0102d6a:	8d 83 ad d4 fe ff    	lea    -0x12b53(%ebx),%eax
f0102d70:	50                   	push   %eax
f0102d71:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102d77:	50                   	push   %eax
f0102d78:	68 7b 03 00 00       	push   $0x37b
f0102d7d:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102d83:	50                   	push   %eax
f0102d84:	e8 10 d3 ff ff       	call   f0100099 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d89:	50                   	push   %eax
f0102d8a:	8d 83 74 d6 fe ff    	lea    -0x1298c(%ebx),%eax
f0102d90:	50                   	push   %eax
f0102d91:	6a 52                	push   $0x52
f0102d93:	8d 83 bc d3 fe ff    	lea    -0x12c44(%ebx),%eax
f0102d99:	50                   	push   %eax
f0102d9a:	e8 fa d2 ff ff       	call   f0100099 <_panic>
f0102d9f:	50                   	push   %eax
f0102da0:	8d 83 74 d6 fe ff    	lea    -0x1298c(%ebx),%eax
f0102da6:	50                   	push   %eax
f0102da7:	6a 52                	push   $0x52
f0102da9:	8d 83 bc d3 fe ff    	lea    -0x12c44(%ebx),%eax
f0102daf:	50                   	push   %eax
f0102db0:	e8 e4 d2 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 1);
f0102db5:	8d 83 7e d5 fe ff    	lea    -0x12a82(%ebx),%eax
f0102dbb:	50                   	push   %eax
f0102dbc:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102dc2:	50                   	push   %eax
f0102dc3:	68 80 03 00 00       	push   $0x380
f0102dc8:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102dce:	50                   	push   %eax
f0102dcf:	e8 c5 d2 ff ff       	call   f0100099 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102dd4:	8d 83 f0 dc fe ff    	lea    -0x12310(%ebx),%eax
f0102dda:	50                   	push   %eax
f0102ddb:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102de1:	50                   	push   %eax
f0102de2:	68 81 03 00 00       	push   $0x381
f0102de7:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102ded:	50                   	push   %eax
f0102dee:	e8 a6 d2 ff ff       	call   f0100099 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102df3:	8d 83 14 dd fe ff    	lea    -0x122ec(%ebx),%eax
f0102df9:	50                   	push   %eax
f0102dfa:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102e00:	50                   	push   %eax
f0102e01:	68 83 03 00 00       	push   $0x383
f0102e06:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102e0c:	50                   	push   %eax
f0102e0d:	e8 87 d2 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f0102e12:	8d 83 a0 d5 fe ff    	lea    -0x12a60(%ebx),%eax
f0102e18:	50                   	push   %eax
f0102e19:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102e1f:	50                   	push   %eax
f0102e20:	68 84 03 00 00       	push   $0x384
f0102e25:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102e2b:	50                   	push   %eax
f0102e2c:	e8 68 d2 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 0);
f0102e31:	8d 83 e9 d5 fe ff    	lea    -0x12a17(%ebx),%eax
f0102e37:	50                   	push   %eax
f0102e38:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102e3e:	50                   	push   %eax
f0102e3f:	68 85 03 00 00       	push   $0x385
f0102e44:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102e4a:	50                   	push   %eax
f0102e4b:	e8 49 d2 ff ff       	call   f0100099 <_panic>
f0102e50:	50                   	push   %eax
f0102e51:	8d 83 74 d6 fe ff    	lea    -0x1298c(%ebx),%eax
f0102e57:	50                   	push   %eax
f0102e58:	6a 52                	push   $0x52
f0102e5a:	8d 83 bc d3 fe ff    	lea    -0x12c44(%ebx),%eax
f0102e60:	50                   	push   %eax
f0102e61:	e8 33 d2 ff ff       	call   f0100099 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e66:	8d 83 38 dd fe ff    	lea    -0x122c8(%ebx),%eax
f0102e6c:	50                   	push   %eax
f0102e6d:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102e73:	50                   	push   %eax
f0102e74:	68 87 03 00 00       	push   $0x387
f0102e79:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102e7f:	50                   	push   %eax
f0102e80:	e8 14 d2 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f0102e85:	8d 83 d8 d5 fe ff    	lea    -0x12a28(%ebx),%eax
f0102e8b:	50                   	push   %eax
f0102e8c:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102e92:	50                   	push   %eax
f0102e93:	68 89 03 00 00       	push   $0x389
f0102e98:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102e9e:	50                   	push   %eax
f0102e9f:	e8 f5 d1 ff ff       	call   f0100099 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ea4:	8d 83 b4 d8 fe ff    	lea    -0x1274c(%ebx),%eax
f0102eaa:	50                   	push   %eax
f0102eab:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102eb1:	50                   	push   %eax
f0102eb2:	68 8c 03 00 00       	push   $0x38c
f0102eb7:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102ebd:	50                   	push   %eax
f0102ebe:	e8 d6 d1 ff ff       	call   f0100099 <_panic>
	assert(pp0->pp_ref == 1);
f0102ec3:	8d 83 8f d5 fe ff    	lea    -0x12a71(%ebx),%eax
f0102ec9:	50                   	push   %eax
f0102eca:	8d 83 d6 d3 fe ff    	lea    -0x12c2a(%ebx),%eax
f0102ed0:	50                   	push   %eax
f0102ed1:	68 8e 03 00 00       	push   $0x38e
f0102ed6:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102edc:	50                   	push   %eax
f0102edd:	e8 b7 d1 ff ff       	call   f0100099 <_panic>

f0102ee2 <tlb_invalidate>:
{
f0102ee2:	55                   	push   %ebp
f0102ee3:	89 e5                	mov    %esp,%ebp
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102ee5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ee8:	0f 01 38             	invlpg (%eax)
}
f0102eeb:	5d                   	pop    %ebp
f0102eec:	c3                   	ret    

f0102eed <__x86.get_pc_thunk.dx>:
f0102eed:	8b 14 24             	mov    (%esp),%edx
f0102ef0:	c3                   	ret    

f0102ef1 <__x86.get_pc_thunk.cx>:
f0102ef1:	8b 0c 24             	mov    (%esp),%ecx
f0102ef4:	c3                   	ret    

f0102ef5 <__x86.get_pc_thunk.di>:
f0102ef5:	8b 3c 24             	mov    (%esp),%edi
f0102ef8:	c3                   	ret    

f0102ef9 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102ef9:	55                   	push   %ebp
f0102efa:	89 e5                	mov    %esp,%ebp
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102efc:	8b 45 08             	mov    0x8(%ebp),%eax
f0102eff:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f04:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102f05:	ba 71 00 00 00       	mov    $0x71,%edx
f0102f0a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102f0b:	0f b6 c0             	movzbl %al,%eax
}
f0102f0e:	5d                   	pop    %ebp
f0102f0f:	c3                   	ret    

f0102f10 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102f10:	55                   	push   %ebp
f0102f11:	89 e5                	mov    %esp,%ebp
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f13:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f16:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f1b:	ee                   	out    %al,(%dx)
f0102f1c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f1f:	ba 71 00 00 00       	mov    $0x71,%edx
f0102f24:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102f25:	5d                   	pop    %ebp
f0102f26:	c3                   	ret    

f0102f27 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102f27:	55                   	push   %ebp
f0102f28:	89 e5                	mov    %esp,%ebp
f0102f2a:	53                   	push   %ebx
f0102f2b:	83 ec 10             	sub    $0x10,%esp
f0102f2e:	e8 1c d2 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0102f33:	81 c3 d5 43 01 00    	add    $0x143d5,%ebx
	cputchar(ch);
f0102f39:	ff 75 08             	pushl  0x8(%ebp)
f0102f3c:	e8 86 d7 ff ff       	call   f01006c7 <cputchar>
	*cnt++;
}
f0102f41:	83 c4 10             	add    $0x10,%esp
f0102f44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f47:	c9                   	leave  
f0102f48:	c3                   	ret    

f0102f49 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102f49:	55                   	push   %ebp
f0102f4a:	89 e5                	mov    %esp,%ebp
f0102f4c:	53                   	push   %ebx
f0102f4d:	83 ec 14             	sub    $0x14,%esp
f0102f50:	e8 fa d1 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0102f55:	81 c3 b3 43 01 00    	add    $0x143b3,%ebx
	int cnt = 0;
f0102f5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102f62:	ff 75 0c             	pushl  0xc(%ebp)
f0102f65:	ff 75 08             	pushl  0x8(%ebp)
f0102f68:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102f6b:	50                   	push   %eax
f0102f6c:	8d 83 1f bc fe ff    	lea    -0x143e1(%ebx),%eax
f0102f72:	50                   	push   %eax
f0102f73:	e8 1e 05 00 00       	call   f0103496 <vprintfmt>
	return cnt;
}
f0102f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f7e:	c9                   	leave  
f0102f7f:	c3                   	ret    

f0102f80 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102f80:	55                   	push   %ebp
f0102f81:	89 e5                	mov    %esp,%ebp
f0102f83:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102f86:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102f89:	50                   	push   %eax
f0102f8a:	ff 75 08             	pushl  0x8(%ebp)
f0102f8d:	e8 b7 ff ff ff       	call   f0102f49 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102f92:	c9                   	leave  
f0102f93:	c3                   	ret    

f0102f94 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102f94:	55                   	push   %ebp
f0102f95:	89 e5                	mov    %esp,%ebp
f0102f97:	57                   	push   %edi
f0102f98:	56                   	push   %esi
f0102f99:	53                   	push   %ebx
f0102f9a:	83 ec 14             	sub    $0x14,%esp
f0102f9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102fa0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102fa3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102fa6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102fa9:	8b 32                	mov    (%edx),%esi
f0102fab:	8b 01                	mov    (%ecx),%eax
f0102fad:	89 45 f0             	mov    %eax,-0x10(%ebp)

	while (l <= r) {
f0102fb0:	39 c6                	cmp    %eax,%esi
f0102fb2:	7f 79                	jg     f010302d <stab_binsearch+0x99>
	int l = *region_left, r = *region_right, any_matches = 0;
f0102fb4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0102fbb:	e9 84 00 00 00       	jmp    f0103044 <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102fc0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102fc3:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0102fc5:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0102fc8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102fcf:	eb 6e                	jmp    f010303f <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102fd1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102fd4:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102fd6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0102fda:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0102fdc:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102fe3:	eb 5a                	jmp    f010303f <stab_binsearch+0xab>
		}
	}

	if (!any_matches)
f0102fe5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102fe9:	74 42                	je     f010302d <stab_binsearch+0x99>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102feb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102fee:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102ff0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102ff3:	8b 16                	mov    (%esi),%edx
		for (l = *region_right;
f0102ff5:	39 d0                	cmp    %edx,%eax
f0102ff7:	7e 27                	jle    f0103020 <stab_binsearch+0x8c>
		     l > *region_left && stabs[l].n_type != type;
f0102ff9:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102ffc:	c1 e1 02             	shl    $0x2,%ecx
f0102fff:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0103002:	0f b6 5c 0e 04       	movzbl 0x4(%esi,%ecx,1),%ebx
f0103007:	39 df                	cmp    %ebx,%edi
f0103009:	74 15                	je     f0103020 <stab_binsearch+0x8c>
f010300b:	8d 4c 0e f8          	lea    -0x8(%esi,%ecx,1),%ecx
		     l--)
f010300f:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0103012:	39 d0                	cmp    %edx,%eax
f0103014:	74 0a                	je     f0103020 <stab_binsearch+0x8c>
		     l > *region_left && stabs[l].n_type != type;
f0103016:	0f b6 19             	movzbl (%ecx),%ebx
f0103019:	83 e9 0c             	sub    $0xc,%ecx
f010301c:	39 fb                	cmp    %edi,%ebx
f010301e:	75 ef                	jne    f010300f <stab_binsearch+0x7b>
			/* do nothing */;
		*region_left = l;
f0103020:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103023:	89 07                	mov    %eax,(%edi)
	}
}
f0103025:	83 c4 14             	add    $0x14,%esp
f0103028:	5b                   	pop    %ebx
f0103029:	5e                   	pop    %esi
f010302a:	5f                   	pop    %edi
f010302b:	5d                   	pop    %ebp
f010302c:	c3                   	ret    
		*region_right = *region_left - 1;
f010302d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103030:	8b 00                	mov    (%eax),%eax
f0103032:	83 e8 01             	sub    $0x1,%eax
f0103035:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103038:	89 07                	mov    %eax,(%edi)
f010303a:	eb e9                	jmp    f0103025 <stab_binsearch+0x91>
			l = true_m + 1;
f010303c:	8d 73 01             	lea    0x1(%ebx),%esi
	while (l <= r) {
f010303f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0103042:	7f a1                	jg     f0102fe5 <stab_binsearch+0x51>
		int true_m = (l + r) / 2, m = true_m;
f0103044:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103047:	01 f0                	add    %esi,%eax
f0103049:	89 c3                	mov    %eax,%ebx
f010304b:	c1 eb 1f             	shr    $0x1f,%ebx
f010304e:	01 c3                	add    %eax,%ebx
f0103050:	d1 fb                	sar    %ebx
		while (m >= l && stabs[m].n_type != type)
f0103052:	39 f3                	cmp    %esi,%ebx
f0103054:	7c e6                	jl     f010303c <stab_binsearch+0xa8>
f0103056:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103059:	c1 e0 02             	shl    $0x2,%eax
f010305c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010305f:	0f b6 54 01 04       	movzbl 0x4(%ecx,%eax,1),%edx
f0103064:	39 d7                	cmp    %edx,%edi
f0103066:	74 47                	je     f01030af <stab_binsearch+0x11b>
f0103068:	8d 54 01 f8          	lea    -0x8(%ecx,%eax,1),%edx
		int true_m = (l + r) / 2, m = true_m;
f010306c:	89 d8                	mov    %ebx,%eax
			m--;
f010306e:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0103071:	39 f0                	cmp    %esi,%eax
f0103073:	7c c7                	jl     f010303c <stab_binsearch+0xa8>
f0103075:	0f b6 0a             	movzbl (%edx),%ecx
f0103078:	83 ea 0c             	sub    $0xc,%edx
f010307b:	39 f9                	cmp    %edi,%ecx
f010307d:	75 ef                	jne    f010306e <stab_binsearch+0xda>
		if (stabs[m].n_value < addr) {
f010307f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103082:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103085:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103089:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010308c:	0f 82 2e ff ff ff    	jb     f0102fc0 <stab_binsearch+0x2c>
		} else if (stabs[m].n_value > addr) {
f0103092:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103095:	0f 86 36 ff ff ff    	jbe    f0102fd1 <stab_binsearch+0x3d>
			*region_right = m - 1;
f010309b:	83 e8 01             	sub    $0x1,%eax
f010309e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01030a1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01030a4:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f01030a6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01030ad:	eb 90                	jmp    f010303f <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f01030af:	89 d8                	mov    %ebx,%eax
f01030b1:	eb cc                	jmp    f010307f <stab_binsearch+0xeb>

f01030b3 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01030b3:	55                   	push   %ebp
f01030b4:	89 e5                	mov    %esp,%ebp
f01030b6:	57                   	push   %edi
f01030b7:	56                   	push   %esi
f01030b8:	53                   	push   %ebx
f01030b9:	83 ec 3c             	sub    $0x3c,%esp
f01030bc:	e8 8e d0 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01030c1:	81 c3 47 42 01 00    	add    $0x14247,%ebx
f01030c7:	8b 7d 08             	mov    0x8(%ebp),%edi
f01030ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01030cd:	8d 83 90 dd fe ff    	lea    -0x12270(%ebx),%eax
f01030d3:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f01030d5:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01030dc:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f01030df:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01030e6:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f01030e9:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01030f0:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01030f6:	0f 86 67 01 00 00    	jbe    f0103263 <debuginfo_eip+0x1b0>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01030fc:	c7 c0 dd bc 10 f0    	mov    $0xf010bcdd,%eax
f0103102:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0103108:	0f 86 1b 02 00 00    	jbe    f0103329 <debuginfo_eip+0x276>
f010310e:	c7 c0 4c db 10 f0    	mov    $0xf010db4c,%eax
f0103114:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0103118:	0f 85 12 02 00 00    	jne    f0103330 <debuginfo_eip+0x27d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010311e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103125:	c7 c0 b0 52 10 f0    	mov    $0xf01052b0,%eax
f010312b:	c7 c2 dc bc 10 f0    	mov    $0xf010bcdc,%edx
f0103131:	29 c2                	sub    %eax,%edx
f0103133:	c1 fa 02             	sar    $0x2,%edx
f0103136:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010313c:	83 ea 01             	sub    $0x1,%edx
f010313f:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103142:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103145:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103148:	83 ec 08             	sub    $0x8,%esp
f010314b:	57                   	push   %edi
f010314c:	6a 64                	push   $0x64
f010314e:	e8 41 fe ff ff       	call   f0102f94 <stab_binsearch>
	if (lfile == 0)
f0103153:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103156:	83 c4 10             	add    $0x10,%esp
f0103159:	85 c0                	test   %eax,%eax
f010315b:	0f 84 d6 01 00 00    	je     f0103337 <debuginfo_eip+0x284>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103161:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103164:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103167:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010316a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010316d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103170:	83 ec 08             	sub    $0x8,%esp
f0103173:	57                   	push   %edi
f0103174:	6a 24                	push   $0x24
f0103176:	c7 c0 b0 52 10 f0    	mov    $0xf01052b0,%eax
f010317c:	e8 13 fe ff ff       	call   f0102f94 <stab_binsearch>

	if (lfun <= rfun) {
f0103181:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103184:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103187:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f010318a:	83 c4 10             	add    $0x10,%esp
f010318d:	39 c8                	cmp    %ecx,%eax
f010318f:	0f 8f e6 00 00 00    	jg     f010327b <debuginfo_eip+0x1c8>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103195:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103198:	c7 c1 b0 52 10 f0    	mov    $0xf01052b0,%ecx
f010319e:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f01031a1:	8b 11                	mov    (%ecx),%edx
f01031a3:	89 55 c0             	mov    %edx,-0x40(%ebp)
f01031a6:	c7 c2 4c db 10 f0    	mov    $0xf010db4c,%edx
f01031ac:	81 ea dd bc 10 f0    	sub    $0xf010bcdd,%edx
f01031b2:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f01031b5:	73 0c                	jae    f01031c3 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01031b7:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01031ba:	81 c2 dd bc 10 f0    	add    $0xf010bcdd,%edx
f01031c0:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01031c3:	8b 51 08             	mov    0x8(%ecx),%edx
f01031c6:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f01031c9:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f01031cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01031ce:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01031d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01031d4:	83 ec 08             	sub    $0x8,%esp
f01031d7:	6a 3a                	push   $0x3a
f01031d9:	ff 76 08             	pushl  0x8(%esi)
f01031dc:	e8 41 0b 00 00       	call   f0103d22 <strfind>
f01031e1:	2b 46 08             	sub    0x8(%esi),%eax
f01031e4:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01031e7:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01031ea:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01031ed:	83 c4 08             	add    $0x8,%esp
f01031f0:	57                   	push   %edi
f01031f1:	6a 44                	push   $0x44
f01031f3:	c7 c0 b0 52 10 f0    	mov    $0xf01052b0,%eax
f01031f9:	e8 96 fd ff ff       	call   f0102f94 <stab_binsearch>
	if (lline <= rline)
f01031fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103201:	83 c4 10             	add    $0x10,%esp
f0103204:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103207:	0f 8f 31 01 00 00    	jg     f010333e <debuginfo_eip+0x28b>
		info->eip_line = stabs[lline].n_desc;
f010320d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103210:	c1 e2 02             	shl    $0x2,%edx
f0103213:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0103216:	89 d1                	mov    %edx,%ecx
f0103218:	81 c1 b0 52 10 f0    	add    $0xf01052b0,%ecx
f010321e:	0f b7 51 06          	movzwl 0x6(%ecx),%edx
f0103222:	89 56 04             	mov    %edx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103225:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103228:	89 55 bc             	mov    %edx,-0x44(%ebp)
f010322b:	39 d0                	cmp    %edx,%eax
f010322d:	0f 8c 9f 00 00 00    	jl     f01032d2 <debuginfo_eip+0x21f>
	       && stabs[lline].n_type != N_SOL
f0103233:	0f b6 51 04          	movzbl 0x4(%ecx),%edx
f0103237:	88 55 c0             	mov    %dl,-0x40(%ebp)
f010323a:	80 fa 84             	cmp    $0x84,%dl
f010323d:	0f 84 23 01 00 00    	je     f0103366 <debuginfo_eip+0x2b3>
f0103243:	c7 c7 b0 52 10 f0    	mov    $0xf01052b0,%edi
f0103249:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010324c:	8d 7c 3a f8          	lea    -0x8(%edx,%edi,1),%edi
f0103250:	83 c1 08             	add    $0x8,%ecx
f0103253:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0103257:	0f b6 55 c0          	movzbl -0x40(%ebp),%edx
f010325b:	89 75 0c             	mov    %esi,0xc(%ebp)
f010325e:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0103261:	eb 49                	jmp    f01032ac <debuginfo_eip+0x1f9>
  	        panic("User address");
f0103263:	83 ec 04             	sub    $0x4,%esp
f0103266:	8d 83 9a dd fe ff    	lea    -0x12266(%ebx),%eax
f010326c:	50                   	push   %eax
f010326d:	6a 7f                	push   $0x7f
f010326f:	8d 83 a7 dd fe ff    	lea    -0x12259(%ebx),%eax
f0103275:	50                   	push   %eax
f0103276:	e8 1e ce ff ff       	call   f0100099 <_panic>
		info->eip_fn_addr = addr;
f010327b:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f010327e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103281:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103284:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103287:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010328a:	e9 45 ff ff ff       	jmp    f01031d4 <debuginfo_eip+0x121>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010328f:	83 e8 01             	sub    $0x1,%eax
	while (lline >= lfile
f0103292:	39 f0                	cmp    %esi,%eax
f0103294:	7c 39                	jl     f01032cf <debuginfo_eip+0x21c>
	       && stabs[lline].n_type != N_SOL
f0103296:	0f b6 17             	movzbl (%edi),%edx
f0103299:	83 ef 0c             	sub    $0xc,%edi
f010329c:	83 e9 0c             	sub    $0xc,%ecx
f010329f:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01032a3:	80 fa 84             	cmp    $0x84,%dl
f01032a6:	0f 84 b4 00 00 00    	je     f0103360 <debuginfo_eip+0x2ad>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01032ac:	80 fa 64             	cmp    $0x64,%dl
f01032af:	75 de                	jne    f010328f <debuginfo_eip+0x1dc>
f01032b1:	83 39 00             	cmpl   $0x0,(%ecx)
f01032b4:	74 d9                	je     f010328f <debuginfo_eip+0x1dc>
f01032b6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01032b9:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01032bd:	75 0b                	jne    f01032ca <debuginfo_eip+0x217>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01032bf:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f01032c2:	0f 8e 9e 00 00 00    	jle    f0103366 <debuginfo_eip+0x2b3>
f01032c8:	eb 08                	jmp    f01032d2 <debuginfo_eip+0x21f>
f01032ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01032cd:	eb f0                	jmp    f01032bf <debuginfo_eip+0x20c>
f01032cf:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01032d2:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01032d5:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01032d8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01032dd:	39 cf                	cmp    %ecx,%edi
f01032df:	7d 77                	jge    f0103358 <debuginfo_eip+0x2a5>
		for (lline = lfun + 1;
f01032e1:	8d 47 01             	lea    0x1(%edi),%eax
f01032e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01032e7:	39 c1                	cmp    %eax,%ecx
f01032e9:	7e 5a                	jle    f0103345 <debuginfo_eip+0x292>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01032eb:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01032ee:	c1 e0 02             	shl    $0x2,%eax
f01032f1:	c7 c2 b0 52 10 f0    	mov    $0xf01052b0,%edx
f01032f7:	80 7c 10 04 a0       	cmpb   $0xa0,0x4(%eax,%edx,1)
f01032fc:	75 4e                	jne    f010334c <debuginfo_eip+0x299>
f01032fe:	8d 54 10 10          	lea    0x10(%eax,%edx,1),%edx
f0103302:	83 e9 02             	sub    $0x2,%ecx
f0103305:	29 f9                	sub    %edi,%ecx
f0103307:	b8 00 00 00 00       	mov    $0x0,%eax
			info->eip_fn_narg++;
f010330c:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0103310:	39 c8                	cmp    %ecx,%eax
f0103312:	74 3f                	je     f0103353 <debuginfo_eip+0x2a0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103314:	0f b6 1a             	movzbl (%edx),%ebx
f0103317:	83 c0 01             	add    $0x1,%eax
f010331a:	83 c2 0c             	add    $0xc,%edx
f010331d:	80 fb a0             	cmp    $0xa0,%bl
f0103320:	74 ea                	je     f010330c <debuginfo_eip+0x259>
	return 0;
f0103322:	b8 00 00 00 00       	mov    $0x0,%eax
f0103327:	eb 2f                	jmp    f0103358 <debuginfo_eip+0x2a5>
		return -1;
f0103329:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010332e:	eb 28                	jmp    f0103358 <debuginfo_eip+0x2a5>
f0103330:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103335:	eb 21                	jmp    f0103358 <debuginfo_eip+0x2a5>
		return -1;
f0103337:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010333c:	eb 1a                	jmp    f0103358 <debuginfo_eip+0x2a5>
		return -1;
f010333e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103343:	eb 13                	jmp    f0103358 <debuginfo_eip+0x2a5>
	return 0;
f0103345:	b8 00 00 00 00       	mov    $0x0,%eax
f010334a:	eb 0c                	jmp    f0103358 <debuginfo_eip+0x2a5>
f010334c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103351:	eb 05                	jmp    f0103358 <debuginfo_eip+0x2a5>
f0103353:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103358:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010335b:	5b                   	pop    %ebx
f010335c:	5e                   	pop    %esi
f010335d:	5f                   	pop    %edi
f010335e:	5d                   	pop    %ebp
f010335f:	c3                   	ret    
f0103360:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103363:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103366:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103369:	c7 c0 b0 52 10 f0    	mov    $0xf01052b0,%eax
f010336f:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0103372:	c7 c0 4c db 10 f0    	mov    $0xf010db4c,%eax
f0103378:	81 e8 dd bc 10 f0    	sub    $0xf010bcdd,%eax
f010337e:	39 c2                	cmp    %eax,%edx
f0103380:	0f 83 4c ff ff ff    	jae    f01032d2 <debuginfo_eip+0x21f>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103386:	81 c2 dd bc 10 f0    	add    $0xf010bcdd,%edx
f010338c:	89 16                	mov    %edx,(%esi)
f010338e:	e9 3f ff ff ff       	jmp    f01032d2 <debuginfo_eip+0x21f>

f0103393 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103393:	55                   	push   %ebp
f0103394:	89 e5                	mov    %esp,%ebp
f0103396:	57                   	push   %edi
f0103397:	56                   	push   %esi
f0103398:	53                   	push   %ebx
f0103399:	83 ec 2c             	sub    $0x2c,%esp
f010339c:	e8 50 fb ff ff       	call   f0102ef1 <__x86.get_pc_thunk.cx>
f01033a1:	81 c1 67 3f 01 00    	add    $0x13f67,%ecx
f01033a7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01033aa:	89 c7                	mov    %eax,%edi
f01033ac:	89 d6                	mov    %edx,%esi
f01033ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01033b1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01033b7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01033ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01033bd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01033c2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f01033c5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f01033c8:	39 d3                	cmp    %edx,%ebx
f01033ca:	72 56                	jb     f0103422 <printnum+0x8f>
f01033cc:	39 45 10             	cmp    %eax,0x10(%ebp)
f01033cf:	76 51                	jbe    f0103422 <printnum+0x8f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01033d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01033d4:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01033d7:	85 db                	test   %ebx,%ebx
f01033d9:	7e 11                	jle    f01033ec <printnum+0x59>
			putch(padc, putdat);
f01033db:	83 ec 08             	sub    $0x8,%esp
f01033de:	56                   	push   %esi
f01033df:	ff 75 18             	pushl  0x18(%ebp)
f01033e2:	ff d7                	call   *%edi
		while (--width > 0)
f01033e4:	83 c4 10             	add    $0x10,%esp
f01033e7:	83 eb 01             	sub    $0x1,%ebx
f01033ea:	75 ef                	jne    f01033db <printnum+0x48>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01033ec:	83 ec 08             	sub    $0x8,%esp
f01033ef:	56                   	push   %esi
f01033f0:	83 ec 04             	sub    $0x4,%esp
f01033f3:	ff 75 dc             	pushl  -0x24(%ebp)
f01033f6:	ff 75 d8             	pushl  -0x28(%ebp)
f01033f9:	ff 75 d4             	pushl  -0x2c(%ebp)
f01033fc:	ff 75 d0             	pushl  -0x30(%ebp)
f01033ff:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103402:	89 f3                	mov    %esi,%ebx
f0103404:	e8 97 0c 00 00       	call   f01040a0 <__umoddi3>
f0103409:	83 c4 14             	add    $0x14,%esp
f010340c:	0f be 84 06 b5 dd fe 	movsbl -0x1224b(%esi,%eax,1),%eax
f0103413:	ff 
f0103414:	50                   	push   %eax
f0103415:	ff d7                	call   *%edi
}
f0103417:	83 c4 10             	add    $0x10,%esp
f010341a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010341d:	5b                   	pop    %ebx
f010341e:	5e                   	pop    %esi
f010341f:	5f                   	pop    %edi
f0103420:	5d                   	pop    %ebp
f0103421:	c3                   	ret    
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103422:	83 ec 0c             	sub    $0xc,%esp
f0103425:	ff 75 18             	pushl  0x18(%ebp)
f0103428:	8b 45 14             	mov    0x14(%ebp),%eax
f010342b:	83 e8 01             	sub    $0x1,%eax
f010342e:	50                   	push   %eax
f010342f:	ff 75 10             	pushl  0x10(%ebp)
f0103432:	83 ec 08             	sub    $0x8,%esp
f0103435:	ff 75 dc             	pushl  -0x24(%ebp)
f0103438:	ff 75 d8             	pushl  -0x28(%ebp)
f010343b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010343e:	ff 75 d0             	pushl  -0x30(%ebp)
f0103441:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103444:	e8 37 0b 00 00       	call   f0103f80 <__udivdi3>
f0103449:	83 c4 18             	add    $0x18,%esp
f010344c:	52                   	push   %edx
f010344d:	50                   	push   %eax
f010344e:	89 f2                	mov    %esi,%edx
f0103450:	89 f8                	mov    %edi,%eax
f0103452:	e8 3c ff ff ff       	call   f0103393 <printnum>
f0103457:	83 c4 20             	add    $0x20,%esp
f010345a:	eb 90                	jmp    f01033ec <printnum+0x59>

f010345c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010345c:	55                   	push   %ebp
f010345d:	89 e5                	mov    %esp,%ebp
f010345f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103462:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103466:	8b 10                	mov    (%eax),%edx
f0103468:	3b 50 04             	cmp    0x4(%eax),%edx
f010346b:	73 0a                	jae    f0103477 <sprintputch+0x1b>
		*b->buf++ = ch;
f010346d:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103470:	89 08                	mov    %ecx,(%eax)
f0103472:	8b 45 08             	mov    0x8(%ebp),%eax
f0103475:	88 02                	mov    %al,(%edx)
}
f0103477:	5d                   	pop    %ebp
f0103478:	c3                   	ret    

f0103479 <printfmt>:
{
f0103479:	55                   	push   %ebp
f010347a:	89 e5                	mov    %esp,%ebp
f010347c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f010347f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103482:	50                   	push   %eax
f0103483:	ff 75 10             	pushl  0x10(%ebp)
f0103486:	ff 75 0c             	pushl  0xc(%ebp)
f0103489:	ff 75 08             	pushl  0x8(%ebp)
f010348c:	e8 05 00 00 00       	call   f0103496 <vprintfmt>
}
f0103491:	83 c4 10             	add    $0x10,%esp
f0103494:	c9                   	leave  
f0103495:	c3                   	ret    

f0103496 <vprintfmt>:
{
f0103496:	55                   	push   %ebp
f0103497:	89 e5                	mov    %esp,%ebp
f0103499:	57                   	push   %edi
f010349a:	56                   	push   %esi
f010349b:	53                   	push   %ebx
f010349c:	83 ec 2c             	sub    $0x2c,%esp
f010349f:	e8 4e d2 ff ff       	call   f01006f2 <__x86.get_pc_thunk.ax>
f01034a4:	05 64 3e 01 00       	add    $0x13e64,%eax
f01034a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01034ac:	8b 7d 08             	mov    0x8(%ebp),%edi
f01034af:	8b 75 0c             	mov    0xc(%ebp),%esi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01034b2:	8b 45 10             	mov    0x10(%ebp),%eax
f01034b5:	8d 58 01             	lea    0x1(%eax),%ebx
f01034b8:	0f b6 00             	movzbl (%eax),%eax
f01034bb:	83 f8 25             	cmp    $0x25,%eax
f01034be:	74 2b                	je     f01034eb <vprintfmt+0x55>
			if (ch == '\0')
f01034c0:	85 c0                	test   %eax,%eax
f01034c2:	74 1a                	je     f01034de <vprintfmt+0x48>
			putch(ch, putdat);
f01034c4:	83 ec 08             	sub    $0x8,%esp
f01034c7:	56                   	push   %esi
f01034c8:	50                   	push   %eax
f01034c9:	ff d7                	call   *%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01034cb:	83 c3 01             	add    $0x1,%ebx
f01034ce:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01034d2:	83 c4 10             	add    $0x10,%esp
f01034d5:	83 f8 25             	cmp    $0x25,%eax
f01034d8:	74 11                	je     f01034eb <vprintfmt+0x55>
			if (ch == '\0')
f01034da:	85 c0                	test   %eax,%eax
f01034dc:	75 e6                	jne    f01034c4 <vprintfmt+0x2e>
}
f01034de:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034e1:	5b                   	pop    %ebx
f01034e2:	5e                   	pop    %esi
f01034e3:	5f                   	pop    %edi
f01034e4:	5d                   	pop    %ebp
f01034e5:	c3                   	ret    
			for (fmt--; fmt[-1] != '%'; fmt--)
f01034e6:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01034e9:	eb c7                	jmp    f01034b2 <vprintfmt+0x1c>
		padc = ' ';
f01034eb:	c6 45 d7 20          	movb   $0x20,-0x29(%ebp)
		altflag = 0;
f01034ef:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f01034f6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f01034fd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0103504:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103509:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010350c:	89 75 0c             	mov    %esi,0xc(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010350f:	8d 43 01             	lea    0x1(%ebx),%eax
f0103512:	89 45 10             	mov    %eax,0x10(%ebp)
f0103515:	0f b6 13             	movzbl (%ebx),%edx
f0103518:	8d 42 dd             	lea    -0x23(%edx),%eax
f010351b:	3c 55                	cmp    $0x55,%al
f010351d:	0f 87 5d 04 00 00    	ja     f0103980 <.L24>
f0103523:	0f b6 c0             	movzbl %al,%eax
f0103526:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103529:	89 ce                	mov    %ecx,%esi
f010352b:	03 b4 81 40 de fe ff 	add    -0x121c0(%ecx,%eax,4),%esi
f0103532:	ff e6                	jmp    *%esi

f0103534 <.L72>:
f0103534:	8b 5d 10             	mov    0x10(%ebp),%ebx
			padc = '-';
f0103537:	c6 45 d7 2d          	movb   $0x2d,-0x29(%ebp)
f010353b:	eb d2                	jmp    f010350f <vprintfmt+0x79>

f010353d <.L30>:
		switch (ch = *(unsigned char *) fmt++) {
f010353d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			padc = '0';
f0103540:	c6 45 d7 30          	movb   $0x30,-0x29(%ebp)
f0103544:	eb c9                	jmp    f010350f <vprintfmt+0x79>

f0103546 <.L31>:
		switch (ch = *(unsigned char *) fmt++) {
f0103546:	0f b6 d2             	movzbl %dl,%edx
				precision = precision * 10 + ch - '0';
f0103549:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010354c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
				ch = *fmt;
f010354f:	0f be 43 01          	movsbl 0x1(%ebx),%eax
				if (ch < '0' || ch > '9')
f0103553:	8d 50 d0             	lea    -0x30(%eax),%edx
f0103556:	83 fa 09             	cmp    $0x9,%edx
f0103559:	77 7e                	ja     f01035d9 <.L25+0xf>
f010355b:	89 ca                	mov    %ecx,%edx
f010355d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103560:	8b 4d 10             	mov    0x10(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
f0103563:	83 c1 01             	add    $0x1,%ecx
				precision = precision * 10 + ch - '0';
f0103566:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0103569:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f010356d:	0f be 01             	movsbl (%ecx),%eax
				if (ch < '0' || ch > '9')
f0103570:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0103573:	83 fb 09             	cmp    $0x9,%ebx
f0103576:	76 eb                	jbe    f0103563 <.L31+0x1d>
f0103578:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010357b:	89 75 0c             	mov    %esi,0xc(%ebp)
			for (precision = 0; ; ++fmt) {
f010357e:	89 cb                	mov    %ecx,%ebx
f0103580:	eb 14                	jmp    f0103596 <.L28+0x14>

f0103582 <.L28>:
			precision = va_arg(ap, int);
f0103582:	8b 45 14             	mov    0x14(%ebp),%eax
f0103585:	8b 00                	mov    (%eax),%eax
f0103587:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010358a:	8b 45 14             	mov    0x14(%ebp),%eax
f010358d:	8d 40 04             	lea    0x4(%eax),%eax
f0103590:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103593:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (width < 0)
f0103596:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010359a:	0f 89 6f ff ff ff    	jns    f010350f <vprintfmt+0x79>
				width = precision, precision = -1;
f01035a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01035a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01035a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01035ad:	e9 5d ff ff ff       	jmp    f010350f <vprintfmt+0x79>

f01035b2 <.L29>:
f01035b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035b5:	85 c0                	test   %eax,%eax
f01035b7:	ba 00 00 00 00       	mov    $0x0,%edx
f01035bc:	0f 49 d0             	cmovns %eax,%edx
f01035bf:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01035c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01035c5:	e9 45 ff ff ff       	jmp    f010350f <vprintfmt+0x79>

f01035ca <.L25>:
f01035ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
			altflag = 1;
f01035cd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01035d4:	e9 36 ff ff ff       	jmp    f010350f <vprintfmt+0x79>
		switch (ch = *(unsigned char *) fmt++) {
f01035d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01035dc:	eb b8                	jmp    f0103596 <.L28+0x14>

f01035de <.L35>:
			lflag++;
f01035de:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01035e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
			goto reswitch;
f01035e5:	e9 25 ff ff ff       	jmp    f010350f <vprintfmt+0x79>

f01035ea <.L32>:
f01035ea:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f01035ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01035f0:	8d 58 04             	lea    0x4(%eax),%ebx
f01035f3:	83 ec 08             	sub    $0x8,%esp
f01035f6:	56                   	push   %esi
f01035f7:	ff 30                	pushl  (%eax)
f01035f9:	ff d7                	call   *%edi
			break;
f01035fb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01035fe:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0103601:	e9 ac fe ff ff       	jmp    f01034b2 <vprintfmt+0x1c>

f0103606 <.L34>:
f0103606:	8b 75 0c             	mov    0xc(%ebp),%esi
			err = va_arg(ap, int);
f0103609:	8b 45 14             	mov    0x14(%ebp),%eax
f010360c:	8d 58 04             	lea    0x4(%eax),%ebx
f010360f:	8b 00                	mov    (%eax),%eax
f0103611:	99                   	cltd   
f0103612:	31 d0                	xor    %edx,%eax
f0103614:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103616:	83 f8 06             	cmp    $0x6,%eax
f0103619:	7f 2b                	jg     f0103646 <.L34+0x40>
f010361b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010361e:	8b 94 82 3c 1d 00 00 	mov    0x1d3c(%edx,%eax,4),%edx
f0103625:	85 d2                	test   %edx,%edx
f0103627:	74 1d                	je     f0103646 <.L34+0x40>
				printfmt(putch, putdat, "%s", p);
f0103629:	52                   	push   %edx
f010362a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010362d:	8d 80 e8 d3 fe ff    	lea    -0x12c18(%eax),%eax
f0103633:	50                   	push   %eax
f0103634:	56                   	push   %esi
f0103635:	57                   	push   %edi
f0103636:	e8 3e fe ff ff       	call   f0103479 <printfmt>
f010363b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010363e:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0103641:	e9 6c fe ff ff       	jmp    f01034b2 <vprintfmt+0x1c>
				printfmt(putch, putdat, "error %d", err);
f0103646:	50                   	push   %eax
f0103647:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010364a:	8d 80 cd dd fe ff    	lea    -0x12233(%eax),%eax
f0103650:	50                   	push   %eax
f0103651:	56                   	push   %esi
f0103652:	57                   	push   %edi
f0103653:	e8 21 fe ff ff       	call   f0103479 <printfmt>
f0103658:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010365b:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010365e:	e9 4f fe ff ff       	jmp    f01034b2 <vprintfmt+0x1c>

f0103663 <.L38>:
f0103663:	8b 75 0c             	mov    0xc(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f0103666:	8b 45 14             	mov    0x14(%ebp),%eax
f0103669:	83 c0 04             	add    $0x4,%eax
f010366c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010366f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103672:	8b 00                	mov    (%eax),%eax
f0103674:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103677:	85 c0                	test   %eax,%eax
f0103679:	0f 84 3a 03 00 00    	je     f01039b9 <.L24+0x39>
			if (width > 0 && padc != '-')
f010367f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103683:	7e 06                	jle    f010368b <.L38+0x28>
f0103685:	80 7d d7 2d          	cmpb   $0x2d,-0x29(%ebp)
f0103689:	75 31                	jne    f01036bc <.L38+0x59>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010368b:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010368e:	8d 58 01             	lea    0x1(%eax),%ebx
f0103691:	0f b6 10             	movzbl (%eax),%edx
f0103694:	0f be c2             	movsbl %dl,%eax
f0103697:	85 c0                	test   %eax,%eax
f0103699:	0f 84 cd 00 00 00    	je     f010376c <.L38+0x109>
f010369f:	89 7d 08             	mov    %edi,0x8(%ebp)
f01036a2:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01036a5:	89 75 0c             	mov    %esi,0xc(%ebp)
f01036a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01036ab:	e9 84 00 00 00       	jmp    f0103734 <.L38+0xd1>
				p = "(null)";
f01036b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01036b3:	8d 80 c6 dd fe ff    	lea    -0x1223a(%eax),%eax
f01036b9:	89 45 c8             	mov    %eax,-0x38(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01036bc:	83 ec 08             	sub    $0x8,%esp
f01036bf:	ff 75 d0             	pushl  -0x30(%ebp)
f01036c2:	ff 75 c8             	pushl  -0x38(%ebp)
f01036c5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01036c8:	e8 b8 04 00 00       	call   f0103b85 <strnlen>
f01036cd:	29 45 e0             	sub    %eax,-0x20(%ebp)
f01036d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01036d3:	83 c4 10             	add    $0x10,%esp
f01036d6:	85 d2                	test   %edx,%edx
f01036d8:	7e 14                	jle    f01036ee <.L38+0x8b>
					putch(padc, putdat);
f01036da:	0f be 5d d7          	movsbl -0x29(%ebp),%ebx
f01036de:	83 ec 08             	sub    $0x8,%esp
f01036e1:	56                   	push   %esi
f01036e2:	53                   	push   %ebx
f01036e3:	ff d7                	call   *%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f01036e5:	83 c4 10             	add    $0x10,%esp
f01036e8:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01036ec:	75 f0                	jne    f01036de <.L38+0x7b>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01036ee:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01036f1:	8d 58 01             	lea    0x1(%eax),%ebx
f01036f4:	0f b6 10             	movzbl (%eax),%edx
f01036f7:	0f be c2             	movsbl %dl,%eax
f01036fa:	85 c0                	test   %eax,%eax
f01036fc:	0f 84 ac 02 00 00    	je     f01039ae <.L24+0x2e>
f0103702:	89 7d 08             	mov    %edi,0x8(%ebp)
f0103705:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0103708:	89 75 0c             	mov    %esi,0xc(%ebp)
f010370b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010370e:	eb 24                	jmp    f0103734 <.L38+0xd1>
				if (altflag && (ch < ' ' || ch > '~'))
f0103710:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103714:	75 32                	jne    f0103748 <.L38+0xe5>
					putch(ch, putdat);
f0103716:	83 ec 08             	sub    $0x8,%esp
f0103719:	ff 75 0c             	pushl  0xc(%ebp)
f010371c:	50                   	push   %eax
f010371d:	ff 55 08             	call   *0x8(%ebp)
f0103720:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103723:	83 ee 01             	sub    $0x1,%esi
f0103726:	83 c3 01             	add    $0x1,%ebx
f0103729:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
f010372d:	0f be c2             	movsbl %dl,%eax
f0103730:	85 c0                	test   %eax,%eax
f0103732:	74 2f                	je     f0103763 <.L38+0x100>
f0103734:	85 ff                	test   %edi,%edi
f0103736:	78 d8                	js     f0103710 <.L38+0xad>
f0103738:	83 ef 01             	sub    $0x1,%edi
f010373b:	79 d3                	jns    f0103710 <.L38+0xad>
f010373d:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0103740:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103743:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103746:	eb 24                	jmp    f010376c <.L38+0x109>
				if (altflag && (ch < ' ' || ch > '~'))
f0103748:	0f be d2             	movsbl %dl,%edx
f010374b:	83 ea 20             	sub    $0x20,%edx
f010374e:	83 fa 5e             	cmp    $0x5e,%edx
f0103751:	76 c3                	jbe    f0103716 <.L38+0xb3>
					putch('?', putdat);
f0103753:	83 ec 08             	sub    $0x8,%esp
f0103756:	ff 75 0c             	pushl  0xc(%ebp)
f0103759:	6a 3f                	push   $0x3f
f010375b:	ff 55 08             	call   *0x8(%ebp)
f010375e:	83 c4 10             	add    $0x10,%esp
f0103761:	eb c0                	jmp    f0103723 <.L38+0xc0>
f0103763:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0103766:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103769:	8b 75 0c             	mov    0xc(%ebp),%esi
f010376c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			for (; width > 0; width--)
f010376f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103773:	7e 1b                	jle    f0103790 <.L38+0x12d>
				putch(' ', putdat);
f0103775:	83 ec 08             	sub    $0x8,%esp
f0103778:	56                   	push   %esi
f0103779:	6a 20                	push   $0x20
f010377b:	ff d7                	call   *%edi
			for (; width > 0; width--)
f010377d:	83 c4 10             	add    $0x10,%esp
f0103780:	83 eb 01             	sub    $0x1,%ebx
f0103783:	75 f0                	jne    f0103775 <.L38+0x112>
			if ((p = va_arg(ap, char *)) == NULL)
f0103785:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103788:	89 45 14             	mov    %eax,0x14(%ebp)
f010378b:	e9 22 fd ff ff       	jmp    f01034b2 <vprintfmt+0x1c>
f0103790:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103793:	89 45 14             	mov    %eax,0x14(%ebp)
f0103796:	e9 17 fd ff ff       	jmp    f01034b2 <vprintfmt+0x1c>

f010379b <.L33>:
f010379b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010379e:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (lflag >= 2)
f01037a1:	83 f9 01             	cmp    $0x1,%ecx
f01037a4:	7e 3f                	jle    f01037e5 <.L33+0x4a>
		return va_arg(*ap, long long);
f01037a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01037a9:	8b 50 04             	mov    0x4(%eax),%edx
f01037ac:	8b 00                	mov    (%eax),%eax
f01037ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01037b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01037b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01037b7:	8d 40 08             	lea    0x8(%eax),%eax
f01037ba:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01037bd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01037c1:	79 54                	jns    f0103817 <.L33+0x7c>
				putch('-', putdat);
f01037c3:	83 ec 08             	sub    $0x8,%esp
f01037c6:	56                   	push   %esi
f01037c7:	6a 2d                	push   $0x2d
f01037c9:	ff d7                	call   *%edi
				num = -(long long) num;
f01037cb:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01037ce:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01037d1:	f7 d9                	neg    %ecx
f01037d3:	83 d3 00             	adc    $0x0,%ebx
f01037d6:	f7 db                	neg    %ebx
f01037d8:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01037db:	ba 0a 00 00 00       	mov    $0xa,%edx
f01037e0:	e9 17 01 00 00       	jmp    f01038fc <.L37+0x2b>
	else if (lflag)
f01037e5:	85 c9                	test   %ecx,%ecx
f01037e7:	75 17                	jne    f0103800 <.L33+0x65>
		return va_arg(*ap, int);
f01037e9:	8b 45 14             	mov    0x14(%ebp),%eax
f01037ec:	8b 00                	mov    (%eax),%eax
f01037ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01037f1:	99                   	cltd   
f01037f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01037f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01037f8:	8d 40 04             	lea    0x4(%eax),%eax
f01037fb:	89 45 14             	mov    %eax,0x14(%ebp)
f01037fe:	eb bd                	jmp    f01037bd <.L33+0x22>
		return va_arg(*ap, long);
f0103800:	8b 45 14             	mov    0x14(%ebp),%eax
f0103803:	8b 00                	mov    (%eax),%eax
f0103805:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103808:	99                   	cltd   
f0103809:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010380c:	8b 45 14             	mov    0x14(%ebp),%eax
f010380f:	8d 40 04             	lea    0x4(%eax),%eax
f0103812:	89 45 14             	mov    %eax,0x14(%ebp)
f0103815:	eb a6                	jmp    f01037bd <.L33+0x22>
			num = getint(&ap, lflag);
f0103817:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010381a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f010381d:	ba 0a 00 00 00       	mov    $0xa,%edx
f0103822:	e9 d5 00 00 00       	jmp    f01038fc <.L37+0x2b>

f0103827 <.L39>:
f0103827:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010382a:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (lflag >= 2)
f010382d:	83 f9 01             	cmp    $0x1,%ecx
f0103830:	7e 18                	jle    f010384a <.L39+0x23>
		return va_arg(*ap, unsigned long long);
f0103832:	8b 45 14             	mov    0x14(%ebp),%eax
f0103835:	8b 08                	mov    (%eax),%ecx
f0103837:	8b 58 04             	mov    0x4(%eax),%ebx
f010383a:	8d 40 08             	lea    0x8(%eax),%eax
f010383d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103840:	ba 0a 00 00 00       	mov    $0xa,%edx
f0103845:	e9 b2 00 00 00       	jmp    f01038fc <.L37+0x2b>
	else if (lflag)
f010384a:	85 c9                	test   %ecx,%ecx
f010384c:	75 1a                	jne    f0103868 <.L39+0x41>
		return va_arg(*ap, unsigned int);
f010384e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103851:	8b 08                	mov    (%eax),%ecx
f0103853:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103858:	8d 40 04             	lea    0x4(%eax),%eax
f010385b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010385e:	ba 0a 00 00 00       	mov    $0xa,%edx
f0103863:	e9 94 00 00 00       	jmp    f01038fc <.L37+0x2b>
		return va_arg(*ap, unsigned long);
f0103868:	8b 45 14             	mov    0x14(%ebp),%eax
f010386b:	8b 08                	mov    (%eax),%ecx
f010386d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103872:	8d 40 04             	lea    0x4(%eax),%eax
f0103875:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103878:	ba 0a 00 00 00       	mov    $0xa,%edx
f010387d:	eb 7d                	jmp    f01038fc <.L37+0x2b>

f010387f <.L36>:
f010387f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103882:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (lflag >= 2)
f0103885:	83 f9 01             	cmp    $0x1,%ecx
f0103888:	7e 15                	jle    f010389f <.L36+0x20>
		return va_arg(*ap, unsigned long long);
f010388a:	8b 45 14             	mov    0x14(%ebp),%eax
f010388d:	8b 08                	mov    (%eax),%ecx
f010388f:	8b 58 04             	mov    0x4(%eax),%ebx
f0103892:	8d 40 08             	lea    0x8(%eax),%eax
f0103895:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f0103898:	ba 08 00 00 00       	mov    $0x8,%edx
f010389d:	eb 5d                	jmp    f01038fc <.L37+0x2b>
	else if (lflag)
f010389f:	85 c9                	test   %ecx,%ecx
f01038a1:	75 17                	jne    f01038ba <.L36+0x3b>
		return va_arg(*ap, unsigned int);
f01038a3:	8b 45 14             	mov    0x14(%ebp),%eax
f01038a6:	8b 08                	mov    (%eax),%ecx
f01038a8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01038ad:	8d 40 04             	lea    0x4(%eax),%eax
f01038b0:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f01038b3:	ba 08 00 00 00       	mov    $0x8,%edx
f01038b8:	eb 42                	jmp    f01038fc <.L37+0x2b>
		return va_arg(*ap, unsigned long);
f01038ba:	8b 45 14             	mov    0x14(%ebp),%eax
f01038bd:	8b 08                	mov    (%eax),%ecx
f01038bf:	bb 00 00 00 00       	mov    $0x0,%ebx
f01038c4:	8d 40 04             	lea    0x4(%eax),%eax
f01038c7:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f01038ca:	ba 08 00 00 00       	mov    $0x8,%edx
f01038cf:	eb 2b                	jmp    f01038fc <.L37+0x2b>

f01038d1 <.L37>:
f01038d1:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch('0', putdat);
f01038d4:	83 ec 08             	sub    $0x8,%esp
f01038d7:	56                   	push   %esi
f01038d8:	6a 30                	push   $0x30
f01038da:	ff d7                	call   *%edi
			putch('x', putdat);
f01038dc:	83 c4 08             	add    $0x8,%esp
f01038df:	56                   	push   %esi
f01038e0:	6a 78                	push   $0x78
f01038e2:	ff d7                	call   *%edi
			num = (unsigned long long)
f01038e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01038e7:	8b 08                	mov    (%eax),%ecx
f01038e9:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f01038ee:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01038f1:	8d 40 04             	lea    0x4(%eax),%eax
f01038f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01038f7:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f01038fc:	83 ec 0c             	sub    $0xc,%esp
f01038ff:	0f be 45 d7          	movsbl -0x29(%ebp),%eax
f0103903:	50                   	push   %eax
f0103904:	ff 75 e0             	pushl  -0x20(%ebp)
f0103907:	52                   	push   %edx
f0103908:	53                   	push   %ebx
f0103909:	51                   	push   %ecx
f010390a:	89 f2                	mov    %esi,%edx
f010390c:	89 f8                	mov    %edi,%eax
f010390e:	e8 80 fa ff ff       	call   f0103393 <printnum>
			break;
f0103913:	83 c4 20             	add    $0x20,%esp
f0103916:	e9 97 fb ff ff       	jmp    f01034b2 <vprintfmt+0x1c>

f010391b <.L40>:
f010391b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010391e:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (lflag >= 2)
f0103921:	83 f9 01             	cmp    $0x1,%ecx
f0103924:	7e 15                	jle    f010393b <.L40+0x20>
		return va_arg(*ap, unsigned long long);
f0103926:	8b 45 14             	mov    0x14(%ebp),%eax
f0103929:	8b 08                	mov    (%eax),%ecx
f010392b:	8b 58 04             	mov    0x4(%eax),%ebx
f010392e:	8d 40 08             	lea    0x8(%eax),%eax
f0103931:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103934:	ba 10 00 00 00       	mov    $0x10,%edx
f0103939:	eb c1                	jmp    f01038fc <.L37+0x2b>
	else if (lflag)
f010393b:	85 c9                	test   %ecx,%ecx
f010393d:	75 17                	jne    f0103956 <.L40+0x3b>
		return va_arg(*ap, unsigned int);
f010393f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103942:	8b 08                	mov    (%eax),%ecx
f0103944:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103949:	8d 40 04             	lea    0x4(%eax),%eax
f010394c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010394f:	ba 10 00 00 00       	mov    $0x10,%edx
f0103954:	eb a6                	jmp    f01038fc <.L37+0x2b>
		return va_arg(*ap, unsigned long);
f0103956:	8b 45 14             	mov    0x14(%ebp),%eax
f0103959:	8b 08                	mov    (%eax),%ecx
f010395b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103960:	8d 40 04             	lea    0x4(%eax),%eax
f0103963:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103966:	ba 10 00 00 00       	mov    $0x10,%edx
f010396b:	eb 8f                	jmp    f01038fc <.L37+0x2b>

f010396d <.L27>:
f010396d:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(ch, putdat);
f0103970:	83 ec 08             	sub    $0x8,%esp
f0103973:	56                   	push   %esi
f0103974:	6a 25                	push   $0x25
f0103976:	ff d7                	call   *%edi
			break;
f0103978:	83 c4 10             	add    $0x10,%esp
f010397b:	e9 32 fb ff ff       	jmp    f01034b2 <vprintfmt+0x1c>

f0103980 <.L24>:
f0103980:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch('%', putdat);
f0103983:	83 ec 08             	sub    $0x8,%esp
f0103986:	56                   	push   %esi
f0103987:	6a 25                	push   $0x25
f0103989:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010398b:	83 c4 10             	add    $0x10,%esp
f010398e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0103992:	0f 84 4e fb ff ff    	je     f01034e6 <vprintfmt+0x50>
f0103998:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010399b:	89 d8                	mov    %ebx,%eax
f010399d:	83 e8 01             	sub    $0x1,%eax
f01039a0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01039a4:	75 f7                	jne    f010399d <.L24+0x1d>
f01039a6:	89 45 10             	mov    %eax,0x10(%ebp)
f01039a9:	e9 04 fb ff ff       	jmp    f01034b2 <vprintfmt+0x1c>
			if ((p = va_arg(ap, char *)) == NULL)
f01039ae:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01039b1:	89 45 14             	mov    %eax,0x14(%ebp)
f01039b4:	e9 f9 fa ff ff       	jmp    f01034b2 <vprintfmt+0x1c>
			if (width > 0 && padc != '-')
f01039b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01039bd:	7e 0a                	jle    f01039c9 <.L24+0x49>
f01039bf:	80 7d d7 2d          	cmpb   $0x2d,-0x29(%ebp)
f01039c3:	0f 85 e7 fc ff ff    	jne    f01036b0 <.L38+0x4d>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01039c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039cc:	8d 98 c7 dd fe ff    	lea    -0x12239(%eax),%ebx
f01039d2:	b8 28 00 00 00       	mov    $0x28,%eax
f01039d7:	ba 28 00 00 00       	mov    $0x28,%edx
f01039dc:	89 7d 08             	mov    %edi,0x8(%ebp)
f01039df:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01039e2:	89 75 0c             	mov    %esi,0xc(%ebp)
f01039e5:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01039e8:	e9 47 fd ff ff       	jmp    f0103734 <.L38+0xd1>

f01039ed <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01039ed:	55                   	push   %ebp
f01039ee:	89 e5                	mov    %esp,%ebp
f01039f0:	53                   	push   %ebx
f01039f1:	83 ec 14             	sub    $0x14,%esp
f01039f4:	e8 56 c7 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01039f9:	81 c3 0f 39 01 00    	add    $0x1390f,%ebx
f01039ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a02:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103a05:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103a08:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103a0c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103a0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103a16:	85 c0                	test   %eax,%eax
f0103a18:	74 2b                	je     f0103a45 <vsnprintf+0x58>
f0103a1a:	85 d2                	test   %edx,%edx
f0103a1c:	7e 27                	jle    f0103a45 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103a1e:	ff 75 14             	pushl  0x14(%ebp)
f0103a21:	ff 75 10             	pushl  0x10(%ebp)
f0103a24:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103a27:	50                   	push   %eax
f0103a28:	8d 83 54 c1 fe ff    	lea    -0x13eac(%ebx),%eax
f0103a2e:	50                   	push   %eax
f0103a2f:	e8 62 fa ff ff       	call   f0103496 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103a34:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103a37:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a3d:	83 c4 10             	add    $0x10,%esp
}
f0103a40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a43:	c9                   	leave  
f0103a44:	c3                   	ret    
		return -E_INVAL;
f0103a45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103a4a:	eb f4                	jmp    f0103a40 <vsnprintf+0x53>

f0103a4c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103a4c:	55                   	push   %ebp
f0103a4d:	89 e5                	mov    %esp,%ebp
f0103a4f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103a52:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103a55:	50                   	push   %eax
f0103a56:	ff 75 10             	pushl  0x10(%ebp)
f0103a59:	ff 75 0c             	pushl  0xc(%ebp)
f0103a5c:	ff 75 08             	pushl  0x8(%ebp)
f0103a5f:	e8 89 ff ff ff       	call   f01039ed <vsnprintf>
	va_end(ap);

	return rc;
}
f0103a64:	c9                   	leave  
f0103a65:	c3                   	ret    

f0103a66 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103a66:	55                   	push   %ebp
f0103a67:	89 e5                	mov    %esp,%ebp
f0103a69:	57                   	push   %edi
f0103a6a:	56                   	push   %esi
f0103a6b:	53                   	push   %ebx
f0103a6c:	83 ec 1c             	sub    $0x1c,%esp
f0103a6f:	e8 db c6 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0103a74:	81 c3 94 38 01 00    	add    $0x13894,%ebx
f0103a7a:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103a7d:	85 c0                	test   %eax,%eax
f0103a7f:	74 13                	je     f0103a94 <readline+0x2e>
		cprintf("%s", prompt);
f0103a81:	83 ec 08             	sub    $0x8,%esp
f0103a84:	50                   	push   %eax
f0103a85:	8d 83 e8 d3 fe ff    	lea    -0x12c18(%ebx),%eax
f0103a8b:	50                   	push   %eax
f0103a8c:	e8 ef f4 ff ff       	call   f0102f80 <cprintf>
f0103a91:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103a94:	83 ec 0c             	sub    $0xc,%esp
f0103a97:	6a 00                	push   $0x0
f0103a99:	e8 4a cc ff ff       	call   f01006e8 <iscons>
f0103a9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103aa1:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103aa4:	bf 00 00 00 00       	mov    $0x0,%edi
f0103aa9:	eb 46                	jmp    f0103af1 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0103aab:	83 ec 08             	sub    $0x8,%esp
f0103aae:	50                   	push   %eax
f0103aaf:	8d 83 98 df fe ff    	lea    -0x12068(%ebx),%eax
f0103ab5:	50                   	push   %eax
f0103ab6:	e8 c5 f4 ff ff       	call   f0102f80 <cprintf>
			return NULL;
f0103abb:	83 c4 10             	add    $0x10,%esp
f0103abe:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0103ac3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103ac6:	5b                   	pop    %ebx
f0103ac7:	5e                   	pop    %esi
f0103ac8:	5f                   	pop    %edi
f0103ac9:	5d                   	pop    %ebp
f0103aca:	c3                   	ret    
			if (echoing)
f0103acb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103acf:	75 05                	jne    f0103ad6 <readline+0x70>
			i--;
f0103ad1:	83 ef 01             	sub    $0x1,%edi
f0103ad4:	eb 1b                	jmp    f0103af1 <readline+0x8b>
				cputchar('\b');
f0103ad6:	83 ec 0c             	sub    $0xc,%esp
f0103ad9:	6a 08                	push   $0x8
f0103adb:	e8 e7 cb ff ff       	call   f01006c7 <cputchar>
f0103ae0:	83 c4 10             	add    $0x10,%esp
f0103ae3:	eb ec                	jmp    f0103ad1 <readline+0x6b>
			buf[i++] = c;
f0103ae5:	89 f0                	mov    %esi,%eax
f0103ae7:	88 84 3b b8 1f 00 00 	mov    %al,0x1fb8(%ebx,%edi,1)
f0103aee:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0103af1:	e8 e1 cb ff ff       	call   f01006d7 <getchar>
f0103af6:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0103af8:	85 c0                	test   %eax,%eax
f0103afa:	78 af                	js     f0103aab <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103afc:	83 f8 08             	cmp    $0x8,%eax
f0103aff:	0f 94 c2             	sete   %dl
f0103b02:	83 f8 7f             	cmp    $0x7f,%eax
f0103b05:	0f 94 c0             	sete   %al
f0103b08:	08 c2                	or     %al,%dl
f0103b0a:	74 04                	je     f0103b10 <readline+0xaa>
f0103b0c:	85 ff                	test   %edi,%edi
f0103b0e:	7f bb                	jg     f0103acb <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103b10:	83 fe 1f             	cmp    $0x1f,%esi
f0103b13:	7e 1c                	jle    f0103b31 <readline+0xcb>
f0103b15:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0103b1b:	7f 14                	jg     f0103b31 <readline+0xcb>
			if (echoing)
f0103b1d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103b21:	74 c2                	je     f0103ae5 <readline+0x7f>
				cputchar(c);
f0103b23:	83 ec 0c             	sub    $0xc,%esp
f0103b26:	56                   	push   %esi
f0103b27:	e8 9b cb ff ff       	call   f01006c7 <cputchar>
f0103b2c:	83 c4 10             	add    $0x10,%esp
f0103b2f:	eb b4                	jmp    f0103ae5 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0103b31:	83 fe 0a             	cmp    $0xa,%esi
f0103b34:	74 05                	je     f0103b3b <readline+0xd5>
f0103b36:	83 fe 0d             	cmp    $0xd,%esi
f0103b39:	75 b6                	jne    f0103af1 <readline+0x8b>
			if (echoing)
f0103b3b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103b3f:	75 13                	jne    f0103b54 <readline+0xee>
			buf[i] = 0;
f0103b41:	c6 84 3b b8 1f 00 00 	movb   $0x0,0x1fb8(%ebx,%edi,1)
f0103b48:	00 
			return buf;
f0103b49:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f0103b4f:	e9 6f ff ff ff       	jmp    f0103ac3 <readline+0x5d>
				cputchar('\n');
f0103b54:	83 ec 0c             	sub    $0xc,%esp
f0103b57:	6a 0a                	push   $0xa
f0103b59:	e8 69 cb ff ff       	call   f01006c7 <cputchar>
f0103b5e:	83 c4 10             	add    $0x10,%esp
f0103b61:	eb de                	jmp    f0103b41 <readline+0xdb>

f0103b63 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103b63:	55                   	push   %ebp
f0103b64:	89 e5                	mov    %esp,%ebp
f0103b66:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103b69:	80 3a 00             	cmpb   $0x0,(%edx)
f0103b6c:	74 10                	je     f0103b7e <strlen+0x1b>
f0103b6e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0103b73:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0103b76:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103b7a:	75 f7                	jne    f0103b73 <strlen+0x10>
	return n;
}
f0103b7c:	5d                   	pop    %ebp
f0103b7d:	c3                   	ret    
	for (n = 0; *s != '\0'; s++)
f0103b7e:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
f0103b83:	eb f7                	jmp    f0103b7c <strlen+0x19>

f0103b85 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103b85:	55                   	push   %ebp
f0103b86:	89 e5                	mov    %esp,%ebp
f0103b88:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103b8b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103b8e:	85 d2                	test   %edx,%edx
f0103b90:	74 19                	je     f0103bab <strnlen+0x26>
f0103b92:	80 39 00             	cmpb   $0x0,(%ecx)
f0103b95:	74 1b                	je     f0103bb2 <strnlen+0x2d>
f0103b97:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0103b9c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103b9f:	39 c2                	cmp    %eax,%edx
f0103ba1:	74 06                	je     f0103ba9 <strnlen+0x24>
f0103ba3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103ba7:	75 f3                	jne    f0103b9c <strnlen+0x17>
	return n;
}
f0103ba9:	5d                   	pop    %ebp
f0103baa:	c3                   	ret    
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103bab:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bb0:	eb f7                	jmp    f0103ba9 <strnlen+0x24>
f0103bb2:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
f0103bb7:	eb f0                	jmp    f0103ba9 <strnlen+0x24>

f0103bb9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103bb9:	55                   	push   %ebp
f0103bba:	89 e5                	mov    %esp,%ebp
f0103bbc:	53                   	push   %ebx
f0103bbd:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103bc3:	89 c2                	mov    %eax,%edx
f0103bc5:	83 c1 01             	add    $0x1,%ecx
f0103bc8:	83 c2 01             	add    $0x1,%edx
f0103bcb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103bcf:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103bd2:	84 db                	test   %bl,%bl
f0103bd4:	75 ef                	jne    f0103bc5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103bd6:	5b                   	pop    %ebx
f0103bd7:	5d                   	pop    %ebp
f0103bd8:	c3                   	ret    

f0103bd9 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103bd9:	55                   	push   %ebp
f0103bda:	89 e5                	mov    %esp,%ebp
f0103bdc:	53                   	push   %ebx
f0103bdd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103be0:	53                   	push   %ebx
f0103be1:	e8 7d ff ff ff       	call   f0103b63 <strlen>
f0103be6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103be9:	ff 75 0c             	pushl  0xc(%ebp)
f0103bec:	01 d8                	add    %ebx,%eax
f0103bee:	50                   	push   %eax
f0103bef:	e8 c5 ff ff ff       	call   f0103bb9 <strcpy>
	return dst;
}
f0103bf4:	89 d8                	mov    %ebx,%eax
f0103bf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103bf9:	c9                   	leave  
f0103bfa:	c3                   	ret    

f0103bfb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103bfb:	55                   	push   %ebp
f0103bfc:	89 e5                	mov    %esp,%ebp
f0103bfe:	56                   	push   %esi
f0103bff:	53                   	push   %ebx
f0103c00:	8b 75 08             	mov    0x8(%ebp),%esi
f0103c03:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103c06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103c09:	85 db                	test   %ebx,%ebx
f0103c0b:	74 17                	je     f0103c24 <strncpy+0x29>
f0103c0d:	01 f3                	add    %esi,%ebx
f0103c0f:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f0103c11:	83 c1 01             	add    $0x1,%ecx
f0103c14:	0f b6 02             	movzbl (%edx),%eax
f0103c17:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103c1a:	80 3a 01             	cmpb   $0x1,(%edx)
f0103c1d:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0103c20:	39 cb                	cmp    %ecx,%ebx
f0103c22:	75 ed                	jne    f0103c11 <strncpy+0x16>
	}
	return ret;
}
f0103c24:	89 f0                	mov    %esi,%eax
f0103c26:	5b                   	pop    %ebx
f0103c27:	5e                   	pop    %esi
f0103c28:	5d                   	pop    %ebp
f0103c29:	c3                   	ret    

f0103c2a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103c2a:	55                   	push   %ebp
f0103c2b:	89 e5                	mov    %esp,%ebp
f0103c2d:	57                   	push   %edi
f0103c2e:	56                   	push   %esi
f0103c2f:	53                   	push   %ebx
f0103c30:	8b 75 08             	mov    0x8(%ebp),%esi
f0103c33:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103c36:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0103c39:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103c3b:	85 db                	test   %ebx,%ebx
f0103c3d:	74 2b                	je     f0103c6a <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f0103c3f:	83 fb 01             	cmp    $0x1,%ebx
f0103c42:	74 23                	je     f0103c67 <strlcpy+0x3d>
f0103c44:	0f b6 0f             	movzbl (%edi),%ecx
f0103c47:	84 c9                	test   %cl,%cl
f0103c49:	74 1c                	je     f0103c67 <strlcpy+0x3d>
f0103c4b:	8d 57 01             	lea    0x1(%edi),%edx
f0103c4e:	8d 5c 1f ff          	lea    -0x1(%edi,%ebx,1),%ebx
			*dst++ = *src++;
f0103c52:	83 c0 01             	add    $0x1,%eax
f0103c55:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0103c58:	39 da                	cmp    %ebx,%edx
f0103c5a:	74 0b                	je     f0103c67 <strlcpy+0x3d>
f0103c5c:	83 c2 01             	add    $0x1,%edx
f0103c5f:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
f0103c63:	84 c9                	test   %cl,%cl
f0103c65:	75 eb                	jne    f0103c52 <strlcpy+0x28>
		*dst = '\0';
f0103c67:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103c6a:	29 f0                	sub    %esi,%eax
}
f0103c6c:	5b                   	pop    %ebx
f0103c6d:	5e                   	pop    %esi
f0103c6e:	5f                   	pop    %edi
f0103c6f:	5d                   	pop    %ebp
f0103c70:	c3                   	ret    

f0103c71 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103c71:	55                   	push   %ebp
f0103c72:	89 e5                	mov    %esp,%ebp
f0103c74:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103c77:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103c7a:	0f b6 01             	movzbl (%ecx),%eax
f0103c7d:	84 c0                	test   %al,%al
f0103c7f:	74 15                	je     f0103c96 <strcmp+0x25>
f0103c81:	3a 02                	cmp    (%edx),%al
f0103c83:	75 11                	jne    f0103c96 <strcmp+0x25>
		p++, q++;
f0103c85:	83 c1 01             	add    $0x1,%ecx
f0103c88:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0103c8b:	0f b6 01             	movzbl (%ecx),%eax
f0103c8e:	84 c0                	test   %al,%al
f0103c90:	74 04                	je     f0103c96 <strcmp+0x25>
f0103c92:	3a 02                	cmp    (%edx),%al
f0103c94:	74 ef                	je     f0103c85 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103c96:	0f b6 c0             	movzbl %al,%eax
f0103c99:	0f b6 12             	movzbl (%edx),%edx
f0103c9c:	29 d0                	sub    %edx,%eax
}
f0103c9e:	5d                   	pop    %ebp
f0103c9f:	c3                   	ret    

f0103ca0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103ca0:	55                   	push   %ebp
f0103ca1:	89 e5                	mov    %esp,%ebp
f0103ca3:	53                   	push   %ebx
f0103ca4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ca7:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103caa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103cad:	85 db                	test   %ebx,%ebx
f0103caf:	74 2d                	je     f0103cde <strncmp+0x3e>
f0103cb1:	0f b6 08             	movzbl (%eax),%ecx
f0103cb4:	84 c9                	test   %cl,%cl
f0103cb6:	74 1b                	je     f0103cd3 <strncmp+0x33>
f0103cb8:	3a 0a                	cmp    (%edx),%cl
f0103cba:	75 17                	jne    f0103cd3 <strncmp+0x33>
f0103cbc:	01 c3                	add    %eax,%ebx
		n--, p++, q++;
f0103cbe:	83 c0 01             	add    $0x1,%eax
f0103cc1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0103cc4:	39 d8                	cmp    %ebx,%eax
f0103cc6:	74 1d                	je     f0103ce5 <strncmp+0x45>
f0103cc8:	0f b6 08             	movzbl (%eax),%ecx
f0103ccb:	84 c9                	test   %cl,%cl
f0103ccd:	74 04                	je     f0103cd3 <strncmp+0x33>
f0103ccf:	3a 0a                	cmp    (%edx),%cl
f0103cd1:	74 eb                	je     f0103cbe <strncmp+0x1e>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103cd3:	0f b6 00             	movzbl (%eax),%eax
f0103cd6:	0f b6 12             	movzbl (%edx),%edx
f0103cd9:	29 d0                	sub    %edx,%eax
}
f0103cdb:	5b                   	pop    %ebx
f0103cdc:	5d                   	pop    %ebp
f0103cdd:	c3                   	ret    
		return 0;
f0103cde:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ce3:	eb f6                	jmp    f0103cdb <strncmp+0x3b>
f0103ce5:	b8 00 00 00 00       	mov    $0x0,%eax
f0103cea:	eb ef                	jmp    f0103cdb <strncmp+0x3b>

f0103cec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103cec:	55                   	push   %ebp
f0103ced:	89 e5                	mov    %esp,%ebp
f0103cef:	53                   	push   %ebx
f0103cf0:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cf3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
f0103cf6:	0f b6 10             	movzbl (%eax),%edx
f0103cf9:	84 d2                	test   %dl,%dl
f0103cfb:	74 1e                	je     f0103d1b <strchr+0x2f>
f0103cfd:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
f0103cff:	38 d3                	cmp    %dl,%bl
f0103d01:	74 15                	je     f0103d18 <strchr+0x2c>
	for (; *s; s++)
f0103d03:	83 c0 01             	add    $0x1,%eax
f0103d06:	0f b6 10             	movzbl (%eax),%edx
f0103d09:	84 d2                	test   %dl,%dl
f0103d0b:	74 06                	je     f0103d13 <strchr+0x27>
		if (*s == c)
f0103d0d:	38 ca                	cmp    %cl,%dl
f0103d0f:	75 f2                	jne    f0103d03 <strchr+0x17>
f0103d11:	eb 05                	jmp    f0103d18 <strchr+0x2c>
			return (char *) s;
	return 0;
f0103d13:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d18:	5b                   	pop    %ebx
f0103d19:	5d                   	pop    %ebp
f0103d1a:	c3                   	ret    
	return 0;
f0103d1b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d20:	eb f6                	jmp    f0103d18 <strchr+0x2c>

f0103d22 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103d22:	55                   	push   %ebp
f0103d23:	89 e5                	mov    %esp,%ebp
f0103d25:	53                   	push   %ebx
f0103d26:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d29:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f0103d2c:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
f0103d2f:	38 d3                	cmp    %dl,%bl
f0103d31:	74 14                	je     f0103d47 <strfind+0x25>
f0103d33:	89 d1                	mov    %edx,%ecx
f0103d35:	84 db                	test   %bl,%bl
f0103d37:	74 0e                	je     f0103d47 <strfind+0x25>
	for (; *s; s++)
f0103d39:	83 c0 01             	add    $0x1,%eax
f0103d3c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103d3f:	38 ca                	cmp    %cl,%dl
f0103d41:	74 04                	je     f0103d47 <strfind+0x25>
f0103d43:	84 d2                	test   %dl,%dl
f0103d45:	75 f2                	jne    f0103d39 <strfind+0x17>
			break;
	return (char *) s;
}
f0103d47:	5b                   	pop    %ebx
f0103d48:	5d                   	pop    %ebp
f0103d49:	c3                   	ret    

f0103d4a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103d4a:	55                   	push   %ebp
f0103d4b:	89 e5                	mov    %esp,%ebp
f0103d4d:	57                   	push   %edi
f0103d4e:	56                   	push   %esi
f0103d4f:	53                   	push   %ebx
f0103d50:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103d53:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103d56:	85 c9                	test   %ecx,%ecx
f0103d58:	74 13                	je     f0103d6d <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103d5a:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103d60:	75 05                	jne    f0103d67 <memset+0x1d>
f0103d62:	f6 c1 03             	test   $0x3,%cl
f0103d65:	74 0d                	je     f0103d74 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103d67:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d6a:	fc                   	cld    
f0103d6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103d6d:	89 f8                	mov    %edi,%eax
f0103d6f:	5b                   	pop    %ebx
f0103d70:	5e                   	pop    %esi
f0103d71:	5f                   	pop    %edi
f0103d72:	5d                   	pop    %ebp
f0103d73:	c3                   	ret    
		c &= 0xFF;
f0103d74:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103d78:	89 d3                	mov    %edx,%ebx
f0103d7a:	c1 e3 08             	shl    $0x8,%ebx
f0103d7d:	89 d0                	mov    %edx,%eax
f0103d7f:	c1 e0 18             	shl    $0x18,%eax
f0103d82:	89 d6                	mov    %edx,%esi
f0103d84:	c1 e6 10             	shl    $0x10,%esi
f0103d87:	09 f0                	or     %esi,%eax
f0103d89:	09 c2                	or     %eax,%edx
f0103d8b:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0103d8d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103d90:	89 d0                	mov    %edx,%eax
f0103d92:	fc                   	cld    
f0103d93:	f3 ab                	rep stos %eax,%es:(%edi)
f0103d95:	eb d6                	jmp    f0103d6d <memset+0x23>

f0103d97 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103d97:	55                   	push   %ebp
f0103d98:	89 e5                	mov    %esp,%ebp
f0103d9a:	57                   	push   %edi
f0103d9b:	56                   	push   %esi
f0103d9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d9f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103da2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103da5:	39 c6                	cmp    %eax,%esi
f0103da7:	73 35                	jae    f0103dde <memmove+0x47>
f0103da9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103dac:	39 c2                	cmp    %eax,%edx
f0103dae:	76 2e                	jbe    f0103dde <memmove+0x47>
		s += n;
		d += n;
f0103db0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103db3:	89 d6                	mov    %edx,%esi
f0103db5:	09 fe                	or     %edi,%esi
f0103db7:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103dbd:	74 0c                	je     f0103dcb <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103dbf:	83 ef 01             	sub    $0x1,%edi
f0103dc2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0103dc5:	fd                   	std    
f0103dc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103dc8:	fc                   	cld    
f0103dc9:	eb 21                	jmp    f0103dec <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103dcb:	f6 c1 03             	test   $0x3,%cl
f0103dce:	75 ef                	jne    f0103dbf <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103dd0:	83 ef 04             	sub    $0x4,%edi
f0103dd3:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103dd6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0103dd9:	fd                   	std    
f0103dda:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103ddc:	eb ea                	jmp    f0103dc8 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103dde:	89 f2                	mov    %esi,%edx
f0103de0:	09 c2                	or     %eax,%edx
f0103de2:	f6 c2 03             	test   $0x3,%dl
f0103de5:	74 09                	je     f0103df0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103de7:	89 c7                	mov    %eax,%edi
f0103de9:	fc                   	cld    
f0103dea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103dec:	5e                   	pop    %esi
f0103ded:	5f                   	pop    %edi
f0103dee:	5d                   	pop    %ebp
f0103def:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103df0:	f6 c1 03             	test   $0x3,%cl
f0103df3:	75 f2                	jne    f0103de7 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103df5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0103df8:	89 c7                	mov    %eax,%edi
f0103dfa:	fc                   	cld    
f0103dfb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103dfd:	eb ed                	jmp    f0103dec <memmove+0x55>

f0103dff <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103dff:	55                   	push   %ebp
f0103e00:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103e02:	ff 75 10             	pushl  0x10(%ebp)
f0103e05:	ff 75 0c             	pushl  0xc(%ebp)
f0103e08:	ff 75 08             	pushl  0x8(%ebp)
f0103e0b:	e8 87 ff ff ff       	call   f0103d97 <memmove>
}
f0103e10:	c9                   	leave  
f0103e11:	c3                   	ret    

f0103e12 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103e12:	55                   	push   %ebp
f0103e13:	89 e5                	mov    %esp,%ebp
f0103e15:	57                   	push   %edi
f0103e16:	56                   	push   %esi
f0103e17:	53                   	push   %ebx
f0103e18:	8b 75 08             	mov    0x8(%ebp),%esi
f0103e1b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103e1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103e21:	85 db                	test   %ebx,%ebx
f0103e23:	74 37                	je     f0103e5c <memcmp+0x4a>
		if (*s1 != *s2)
f0103e25:	0f b6 16             	movzbl (%esi),%edx
f0103e28:	0f b6 0f             	movzbl (%edi),%ecx
f0103e2b:	38 ca                	cmp    %cl,%dl
f0103e2d:	75 19                	jne    f0103e48 <memcmp+0x36>
f0103e2f:	b8 01 00 00 00       	mov    $0x1,%eax
	while (n-- > 0) {
f0103e34:	39 d8                	cmp    %ebx,%eax
f0103e36:	74 1d                	je     f0103e55 <memcmp+0x43>
		if (*s1 != *s2)
f0103e38:	0f b6 14 06          	movzbl (%esi,%eax,1),%edx
f0103e3c:	83 c0 01             	add    $0x1,%eax
f0103e3f:	0f b6 4c 07 ff       	movzbl -0x1(%edi,%eax,1),%ecx
f0103e44:	38 ca                	cmp    %cl,%dl
f0103e46:	74 ec                	je     f0103e34 <memcmp+0x22>
			return (int) *s1 - (int) *s2;
f0103e48:	0f b6 c2             	movzbl %dl,%eax
f0103e4b:	0f b6 c9             	movzbl %cl,%ecx
f0103e4e:	29 c8                	sub    %ecx,%eax
		s1++, s2++;
	}

	return 0;
}
f0103e50:	5b                   	pop    %ebx
f0103e51:	5e                   	pop    %esi
f0103e52:	5f                   	pop    %edi
f0103e53:	5d                   	pop    %ebp
f0103e54:	c3                   	ret    
	return 0;
f0103e55:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e5a:	eb f4                	jmp    f0103e50 <memcmp+0x3e>
f0103e5c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e61:	eb ed                	jmp    f0103e50 <memcmp+0x3e>

f0103e63 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103e63:	55                   	push   %ebp
f0103e64:	89 e5                	mov    %esp,%ebp
f0103e66:	53                   	push   %ebx
f0103e67:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
f0103e6d:	89 c2                	mov    %eax,%edx
f0103e6f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103e72:	39 d0                	cmp    %edx,%eax
f0103e74:	73 11                	jae    f0103e87 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103e76:	89 d9                	mov    %ebx,%ecx
f0103e78:	38 18                	cmp    %bl,(%eax)
f0103e7a:	74 0b                	je     f0103e87 <memfind+0x24>
	for (; s < ends; s++)
f0103e7c:	83 c0 01             	add    $0x1,%eax
f0103e7f:	39 c2                	cmp    %eax,%edx
f0103e81:	74 04                	je     f0103e87 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103e83:	38 08                	cmp    %cl,(%eax)
f0103e85:	75 f5                	jne    f0103e7c <memfind+0x19>
			break;
	return (void *) s;
}
f0103e87:	5b                   	pop    %ebx
f0103e88:	5d                   	pop    %ebp
f0103e89:	c3                   	ret    

f0103e8a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103e8a:	55                   	push   %ebp
f0103e8b:	89 e5                	mov    %esp,%ebp
f0103e8d:	57                   	push   %edi
f0103e8e:	56                   	push   %esi
f0103e8f:	53                   	push   %ebx
f0103e90:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103e93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103e96:	0f b6 01             	movzbl (%ecx),%eax
f0103e99:	3c 20                	cmp    $0x20,%al
f0103e9b:	74 04                	je     f0103ea1 <strtol+0x17>
f0103e9d:	3c 09                	cmp    $0x9,%al
f0103e9f:	75 0e                	jne    f0103eaf <strtol+0x25>
		s++;
f0103ea1:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0103ea4:	0f b6 01             	movzbl (%ecx),%eax
f0103ea7:	3c 20                	cmp    $0x20,%al
f0103ea9:	74 f6                	je     f0103ea1 <strtol+0x17>
f0103eab:	3c 09                	cmp    $0x9,%al
f0103ead:	74 f2                	je     f0103ea1 <strtol+0x17>

	// plus/minus sign
	if (*s == '+')
f0103eaf:	3c 2b                	cmp    $0x2b,%al
f0103eb1:	74 2e                	je     f0103ee1 <strtol+0x57>
	int neg = 0;
f0103eb3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0103eb8:	3c 2d                	cmp    $0x2d,%al
f0103eba:	74 2f                	je     f0103eeb <strtol+0x61>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103ebc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103ec2:	75 05                	jne    f0103ec9 <strtol+0x3f>
f0103ec4:	80 39 30             	cmpb   $0x30,(%ecx)
f0103ec7:	74 2c                	je     f0103ef5 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103ec9:	85 db                	test   %ebx,%ebx
f0103ecb:	75 0a                	jne    f0103ed7 <strtol+0x4d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103ecd:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0103ed2:	80 39 30             	cmpb   $0x30,(%ecx)
f0103ed5:	74 28                	je     f0103eff <strtol+0x75>
		base = 10;
f0103ed7:	b8 00 00 00 00       	mov    $0x0,%eax
f0103edc:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103edf:	eb 50                	jmp    f0103f31 <strtol+0xa7>
		s++;
f0103ee1:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0103ee4:	bf 00 00 00 00       	mov    $0x0,%edi
f0103ee9:	eb d1                	jmp    f0103ebc <strtol+0x32>
		s++, neg = 1;
f0103eeb:	83 c1 01             	add    $0x1,%ecx
f0103eee:	bf 01 00 00 00       	mov    $0x1,%edi
f0103ef3:	eb c7                	jmp    f0103ebc <strtol+0x32>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103ef5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103ef9:	74 0e                	je     f0103f09 <strtol+0x7f>
	else if (base == 0 && s[0] == '0')
f0103efb:	85 db                	test   %ebx,%ebx
f0103efd:	75 d8                	jne    f0103ed7 <strtol+0x4d>
		s++, base = 8;
f0103eff:	83 c1 01             	add    $0x1,%ecx
f0103f02:	bb 08 00 00 00       	mov    $0x8,%ebx
f0103f07:	eb ce                	jmp    f0103ed7 <strtol+0x4d>
		s += 2, base = 16;
f0103f09:	83 c1 02             	add    $0x2,%ecx
f0103f0c:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103f11:	eb c4                	jmp    f0103ed7 <strtol+0x4d>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0103f13:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103f16:	89 f3                	mov    %esi,%ebx
f0103f18:	80 fb 19             	cmp    $0x19,%bl
f0103f1b:	77 29                	ja     f0103f46 <strtol+0xbc>
			dig = *s - 'a' + 10;
f0103f1d:	0f be d2             	movsbl %dl,%edx
f0103f20:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103f23:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103f26:	7d 30                	jge    f0103f58 <strtol+0xce>
			break;
		s++, val = (val * base) + dig;
f0103f28:	83 c1 01             	add    $0x1,%ecx
f0103f2b:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103f2f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0103f31:	0f b6 11             	movzbl (%ecx),%edx
f0103f34:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103f37:	89 f3                	mov    %esi,%ebx
f0103f39:	80 fb 09             	cmp    $0x9,%bl
f0103f3c:	77 d5                	ja     f0103f13 <strtol+0x89>
			dig = *s - '0';
f0103f3e:	0f be d2             	movsbl %dl,%edx
f0103f41:	83 ea 30             	sub    $0x30,%edx
f0103f44:	eb dd                	jmp    f0103f23 <strtol+0x99>
		else if (*s >= 'A' && *s <= 'Z')
f0103f46:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103f49:	89 f3                	mov    %esi,%ebx
f0103f4b:	80 fb 19             	cmp    $0x19,%bl
f0103f4e:	77 08                	ja     f0103f58 <strtol+0xce>
			dig = *s - 'A' + 10;
f0103f50:	0f be d2             	movsbl %dl,%edx
f0103f53:	83 ea 37             	sub    $0x37,%edx
f0103f56:	eb cb                	jmp    f0103f23 <strtol+0x99>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103f58:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103f5c:	74 05                	je     f0103f63 <strtol+0xd9>
		*endptr = (char *) s;
f0103f5e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103f61:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0103f63:	89 c2                	mov    %eax,%edx
f0103f65:	f7 da                	neg    %edx
f0103f67:	85 ff                	test   %edi,%edi
f0103f69:	0f 45 c2             	cmovne %edx,%eax
}
f0103f6c:	5b                   	pop    %ebx
f0103f6d:	5e                   	pop    %esi
f0103f6e:	5f                   	pop    %edi
f0103f6f:	5d                   	pop    %ebp
f0103f70:	c3                   	ret    
f0103f71:	66 90                	xchg   %ax,%ax
f0103f73:	66 90                	xchg   %ax,%ax
f0103f75:	66 90                	xchg   %ax,%ax
f0103f77:	66 90                	xchg   %ax,%ax
f0103f79:	66 90                	xchg   %ax,%ax
f0103f7b:	66 90                	xchg   %ax,%ax
f0103f7d:	66 90                	xchg   %ax,%ax
f0103f7f:	90                   	nop

f0103f80 <__udivdi3>:
f0103f80:	55                   	push   %ebp
f0103f81:	57                   	push   %edi
f0103f82:	56                   	push   %esi
f0103f83:	53                   	push   %ebx
f0103f84:	83 ec 1c             	sub    $0x1c,%esp
f0103f87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0103f8b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0103f8f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103f93:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0103f97:	85 d2                	test   %edx,%edx
f0103f99:	75 35                	jne    f0103fd0 <__udivdi3+0x50>
f0103f9b:	39 f3                	cmp    %esi,%ebx
f0103f9d:	0f 87 bd 00 00 00    	ja     f0104060 <__udivdi3+0xe0>
f0103fa3:	85 db                	test   %ebx,%ebx
f0103fa5:	89 d9                	mov    %ebx,%ecx
f0103fa7:	75 0b                	jne    f0103fb4 <__udivdi3+0x34>
f0103fa9:	b8 01 00 00 00       	mov    $0x1,%eax
f0103fae:	31 d2                	xor    %edx,%edx
f0103fb0:	f7 f3                	div    %ebx
f0103fb2:	89 c1                	mov    %eax,%ecx
f0103fb4:	31 d2                	xor    %edx,%edx
f0103fb6:	89 f0                	mov    %esi,%eax
f0103fb8:	f7 f1                	div    %ecx
f0103fba:	89 c6                	mov    %eax,%esi
f0103fbc:	89 e8                	mov    %ebp,%eax
f0103fbe:	89 f7                	mov    %esi,%edi
f0103fc0:	f7 f1                	div    %ecx
f0103fc2:	89 fa                	mov    %edi,%edx
f0103fc4:	83 c4 1c             	add    $0x1c,%esp
f0103fc7:	5b                   	pop    %ebx
f0103fc8:	5e                   	pop    %esi
f0103fc9:	5f                   	pop    %edi
f0103fca:	5d                   	pop    %ebp
f0103fcb:	c3                   	ret    
f0103fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103fd0:	39 f2                	cmp    %esi,%edx
f0103fd2:	77 7c                	ja     f0104050 <__udivdi3+0xd0>
f0103fd4:	0f bd fa             	bsr    %edx,%edi
f0103fd7:	83 f7 1f             	xor    $0x1f,%edi
f0103fda:	0f 84 98 00 00 00    	je     f0104078 <__udivdi3+0xf8>
f0103fe0:	89 f9                	mov    %edi,%ecx
f0103fe2:	b8 20 00 00 00       	mov    $0x20,%eax
f0103fe7:	29 f8                	sub    %edi,%eax
f0103fe9:	d3 e2                	shl    %cl,%edx
f0103feb:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103fef:	89 c1                	mov    %eax,%ecx
f0103ff1:	89 da                	mov    %ebx,%edx
f0103ff3:	d3 ea                	shr    %cl,%edx
f0103ff5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103ff9:	09 d1                	or     %edx,%ecx
f0103ffb:	89 f2                	mov    %esi,%edx
f0103ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104001:	89 f9                	mov    %edi,%ecx
f0104003:	d3 e3                	shl    %cl,%ebx
f0104005:	89 c1                	mov    %eax,%ecx
f0104007:	d3 ea                	shr    %cl,%edx
f0104009:	89 f9                	mov    %edi,%ecx
f010400b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010400f:	d3 e6                	shl    %cl,%esi
f0104011:	89 eb                	mov    %ebp,%ebx
f0104013:	89 c1                	mov    %eax,%ecx
f0104015:	d3 eb                	shr    %cl,%ebx
f0104017:	09 de                	or     %ebx,%esi
f0104019:	89 f0                	mov    %esi,%eax
f010401b:	f7 74 24 08          	divl   0x8(%esp)
f010401f:	89 d6                	mov    %edx,%esi
f0104021:	89 c3                	mov    %eax,%ebx
f0104023:	f7 64 24 0c          	mull   0xc(%esp)
f0104027:	39 d6                	cmp    %edx,%esi
f0104029:	72 0c                	jb     f0104037 <__udivdi3+0xb7>
f010402b:	89 f9                	mov    %edi,%ecx
f010402d:	d3 e5                	shl    %cl,%ebp
f010402f:	39 c5                	cmp    %eax,%ebp
f0104031:	73 5d                	jae    f0104090 <__udivdi3+0x110>
f0104033:	39 d6                	cmp    %edx,%esi
f0104035:	75 59                	jne    f0104090 <__udivdi3+0x110>
f0104037:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010403a:	31 ff                	xor    %edi,%edi
f010403c:	89 fa                	mov    %edi,%edx
f010403e:	83 c4 1c             	add    $0x1c,%esp
f0104041:	5b                   	pop    %ebx
f0104042:	5e                   	pop    %esi
f0104043:	5f                   	pop    %edi
f0104044:	5d                   	pop    %ebp
f0104045:	c3                   	ret    
f0104046:	8d 76 00             	lea    0x0(%esi),%esi
f0104049:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0104050:	31 ff                	xor    %edi,%edi
f0104052:	31 c0                	xor    %eax,%eax
f0104054:	89 fa                	mov    %edi,%edx
f0104056:	83 c4 1c             	add    $0x1c,%esp
f0104059:	5b                   	pop    %ebx
f010405a:	5e                   	pop    %esi
f010405b:	5f                   	pop    %edi
f010405c:	5d                   	pop    %ebp
f010405d:	c3                   	ret    
f010405e:	66 90                	xchg   %ax,%ax
f0104060:	31 ff                	xor    %edi,%edi
f0104062:	89 e8                	mov    %ebp,%eax
f0104064:	89 f2                	mov    %esi,%edx
f0104066:	f7 f3                	div    %ebx
f0104068:	89 fa                	mov    %edi,%edx
f010406a:	83 c4 1c             	add    $0x1c,%esp
f010406d:	5b                   	pop    %ebx
f010406e:	5e                   	pop    %esi
f010406f:	5f                   	pop    %edi
f0104070:	5d                   	pop    %ebp
f0104071:	c3                   	ret    
f0104072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104078:	39 f2                	cmp    %esi,%edx
f010407a:	72 06                	jb     f0104082 <__udivdi3+0x102>
f010407c:	31 c0                	xor    %eax,%eax
f010407e:	39 eb                	cmp    %ebp,%ebx
f0104080:	77 d2                	ja     f0104054 <__udivdi3+0xd4>
f0104082:	b8 01 00 00 00       	mov    $0x1,%eax
f0104087:	eb cb                	jmp    f0104054 <__udivdi3+0xd4>
f0104089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104090:	89 d8                	mov    %ebx,%eax
f0104092:	31 ff                	xor    %edi,%edi
f0104094:	eb be                	jmp    f0104054 <__udivdi3+0xd4>
f0104096:	66 90                	xchg   %ax,%ax
f0104098:	66 90                	xchg   %ax,%ax
f010409a:	66 90                	xchg   %ax,%ax
f010409c:	66 90                	xchg   %ax,%ax
f010409e:	66 90                	xchg   %ax,%ax

f01040a0 <__umoddi3>:
f01040a0:	55                   	push   %ebp
f01040a1:	57                   	push   %edi
f01040a2:	56                   	push   %esi
f01040a3:	53                   	push   %ebx
f01040a4:	83 ec 1c             	sub    $0x1c,%esp
f01040a7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01040ab:	8b 74 24 30          	mov    0x30(%esp),%esi
f01040af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01040b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01040b7:	85 ed                	test   %ebp,%ebp
f01040b9:	89 f0                	mov    %esi,%eax
f01040bb:	89 da                	mov    %ebx,%edx
f01040bd:	75 19                	jne    f01040d8 <__umoddi3+0x38>
f01040bf:	39 df                	cmp    %ebx,%edi
f01040c1:	0f 86 b1 00 00 00    	jbe    f0104178 <__umoddi3+0xd8>
f01040c7:	f7 f7                	div    %edi
f01040c9:	89 d0                	mov    %edx,%eax
f01040cb:	31 d2                	xor    %edx,%edx
f01040cd:	83 c4 1c             	add    $0x1c,%esp
f01040d0:	5b                   	pop    %ebx
f01040d1:	5e                   	pop    %esi
f01040d2:	5f                   	pop    %edi
f01040d3:	5d                   	pop    %ebp
f01040d4:	c3                   	ret    
f01040d5:	8d 76 00             	lea    0x0(%esi),%esi
f01040d8:	39 dd                	cmp    %ebx,%ebp
f01040da:	77 f1                	ja     f01040cd <__umoddi3+0x2d>
f01040dc:	0f bd cd             	bsr    %ebp,%ecx
f01040df:	83 f1 1f             	xor    $0x1f,%ecx
f01040e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01040e6:	0f 84 b4 00 00 00    	je     f01041a0 <__umoddi3+0x100>
f01040ec:	b8 20 00 00 00       	mov    $0x20,%eax
f01040f1:	89 c2                	mov    %eax,%edx
f01040f3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01040f7:	29 c2                	sub    %eax,%edx
f01040f9:	89 c1                	mov    %eax,%ecx
f01040fb:	89 f8                	mov    %edi,%eax
f01040fd:	d3 e5                	shl    %cl,%ebp
f01040ff:	89 d1                	mov    %edx,%ecx
f0104101:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104105:	d3 e8                	shr    %cl,%eax
f0104107:	09 c5                	or     %eax,%ebp
f0104109:	8b 44 24 04          	mov    0x4(%esp),%eax
f010410d:	89 c1                	mov    %eax,%ecx
f010410f:	d3 e7                	shl    %cl,%edi
f0104111:	89 d1                	mov    %edx,%ecx
f0104113:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104117:	89 df                	mov    %ebx,%edi
f0104119:	d3 ef                	shr    %cl,%edi
f010411b:	89 c1                	mov    %eax,%ecx
f010411d:	89 f0                	mov    %esi,%eax
f010411f:	d3 e3                	shl    %cl,%ebx
f0104121:	89 d1                	mov    %edx,%ecx
f0104123:	89 fa                	mov    %edi,%edx
f0104125:	d3 e8                	shr    %cl,%eax
f0104127:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010412c:	09 d8                	or     %ebx,%eax
f010412e:	f7 f5                	div    %ebp
f0104130:	d3 e6                	shl    %cl,%esi
f0104132:	89 d1                	mov    %edx,%ecx
f0104134:	f7 64 24 08          	mull   0x8(%esp)
f0104138:	39 d1                	cmp    %edx,%ecx
f010413a:	89 c3                	mov    %eax,%ebx
f010413c:	89 d7                	mov    %edx,%edi
f010413e:	72 06                	jb     f0104146 <__umoddi3+0xa6>
f0104140:	75 0e                	jne    f0104150 <__umoddi3+0xb0>
f0104142:	39 c6                	cmp    %eax,%esi
f0104144:	73 0a                	jae    f0104150 <__umoddi3+0xb0>
f0104146:	2b 44 24 08          	sub    0x8(%esp),%eax
f010414a:	19 ea                	sbb    %ebp,%edx
f010414c:	89 d7                	mov    %edx,%edi
f010414e:	89 c3                	mov    %eax,%ebx
f0104150:	89 ca                	mov    %ecx,%edx
f0104152:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0104157:	29 de                	sub    %ebx,%esi
f0104159:	19 fa                	sbb    %edi,%edx
f010415b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010415f:	89 d0                	mov    %edx,%eax
f0104161:	d3 e0                	shl    %cl,%eax
f0104163:	89 d9                	mov    %ebx,%ecx
f0104165:	d3 ee                	shr    %cl,%esi
f0104167:	d3 ea                	shr    %cl,%edx
f0104169:	09 f0                	or     %esi,%eax
f010416b:	83 c4 1c             	add    $0x1c,%esp
f010416e:	5b                   	pop    %ebx
f010416f:	5e                   	pop    %esi
f0104170:	5f                   	pop    %edi
f0104171:	5d                   	pop    %ebp
f0104172:	c3                   	ret    
f0104173:	90                   	nop
f0104174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104178:	85 ff                	test   %edi,%edi
f010417a:	89 f9                	mov    %edi,%ecx
f010417c:	75 0b                	jne    f0104189 <__umoddi3+0xe9>
f010417e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104183:	31 d2                	xor    %edx,%edx
f0104185:	f7 f7                	div    %edi
f0104187:	89 c1                	mov    %eax,%ecx
f0104189:	89 d8                	mov    %ebx,%eax
f010418b:	31 d2                	xor    %edx,%edx
f010418d:	f7 f1                	div    %ecx
f010418f:	89 f0                	mov    %esi,%eax
f0104191:	f7 f1                	div    %ecx
f0104193:	e9 31 ff ff ff       	jmp    f01040c9 <__umoddi3+0x29>
f0104198:	90                   	nop
f0104199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01041a0:	39 dd                	cmp    %ebx,%ebp
f01041a2:	72 08                	jb     f01041ac <__umoddi3+0x10c>
f01041a4:	39 f7                	cmp    %esi,%edi
f01041a6:	0f 87 21 ff ff ff    	ja     f01040cd <__umoddi3+0x2d>
f01041ac:	89 da                	mov    %ebx,%edx
f01041ae:	89 f0                	mov    %esi,%eax
f01041b0:	29 f8                	sub    %edi,%eax
f01041b2:	19 ea                	sbb    %ebp,%edx
f01041b4:	e9 14 ff ff ff       	jmp    f01040cd <__umoddi3+0x2d>
