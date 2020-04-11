
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
f0100015:	b8 00 e0 18 00       	mov    $0x18e000,%eax
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
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 21 01 00 00       	call   f010016d <__x86.get_pc_thunk.bx>
f010004c:	81 c3 d8 cf 08 00    	add    $0x8cfd8,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 10 00 19 f0    	mov    $0xf0190010,%eax
f0100058:	c7 c2 00 f1 18 f0    	mov    $0xf018f100,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 ef 52 00 00       	call   f0105358 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 55 05 00 00       	call   f01005c3 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 9c 87 f7 ff    	lea    -0x87864(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 03 3b 00 00       	call   f0103b85 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 2a 13 00 00       	call   f01013b1 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100087:	e8 16 34 00 00       	call   f01034a2 <env_init>
	trap_init();
f010008c:	e8 9e 3b 00 00       	call   f0103c2f <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100091:	83 c4 0c             	add    $0xc,%esp
f0100094:	6a 00                	push   $0x0
f0100096:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
f010009c:	ff b3 f0 ff ff ff    	pushl  -0x10(%ebx)
f01000a2:	e8 eb 35 00 00       	call   f0103692 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a7:	83 c4 04             	add    $0x4,%esp
f01000aa:	c7 c0 4c f3 18 f0    	mov    $0xf018f34c,%eax
f01000b0:	ff 30                	pushl  (%eax)
f01000b2:	e8 ca 39 00 00       	call   f0103a81 <env_run>

f01000b7 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b7:	55                   	push   %ebp
f01000b8:	89 e5                	mov    %esp,%ebp
f01000ba:	57                   	push   %edi
f01000bb:	56                   	push   %esi
f01000bc:	53                   	push   %ebx
f01000bd:	83 ec 0c             	sub    $0xc,%esp
f01000c0:	e8 a8 00 00 00       	call   f010016d <__x86.get_pc_thunk.bx>
f01000c5:	81 c3 5f cf 08 00    	add    $0x8cf5f,%ebx
f01000cb:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f01000ce:	c7 c0 00 00 19 f0    	mov    $0xf0190000,%eax
f01000d4:	83 38 00             	cmpl   $0x0,(%eax)
f01000d7:	74 0f                	je     f01000e8 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d9:	83 ec 0c             	sub    $0xc,%esp
f01000dc:	6a 00                	push   $0x0
f01000de:	e8 4d 08 00 00       	call   f0100930 <monitor>
f01000e3:	83 c4 10             	add    $0x10,%esp
f01000e6:	eb f1                	jmp    f01000d9 <_panic+0x22>
	panicstr = fmt;
f01000e8:	89 38                	mov    %edi,(%eax)
	__asm __volatile("cli; cld");
f01000ea:	fa                   	cli    
f01000eb:	fc                   	cld    
	va_start(ap, fmt);
f01000ec:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01000ef:	83 ec 04             	sub    $0x4,%esp
f01000f2:	ff 75 0c             	pushl  0xc(%ebp)
f01000f5:	ff 75 08             	pushl  0x8(%ebp)
f01000f8:	8d 83 b7 87 f7 ff    	lea    -0x87849(%ebx),%eax
f01000fe:	50                   	push   %eax
f01000ff:	e8 81 3a 00 00       	call   f0103b85 <cprintf>
	vcprintf(fmt, ap);
f0100104:	83 c4 08             	add    $0x8,%esp
f0100107:	56                   	push   %esi
f0100108:	57                   	push   %edi
f0100109:	e8 40 3a 00 00       	call   f0103b4e <vcprintf>
	cprintf("\n");
f010010e:	8d 83 24 8f f7 ff    	lea    -0x870dc(%ebx),%eax
f0100114:	89 04 24             	mov    %eax,(%esp)
f0100117:	e8 69 3a 00 00       	call   f0103b85 <cprintf>
f010011c:	83 c4 10             	add    $0x10,%esp
f010011f:	eb b8                	jmp    f01000d9 <_panic+0x22>

f0100121 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100121:	55                   	push   %ebp
f0100122:	89 e5                	mov    %esp,%ebp
f0100124:	56                   	push   %esi
f0100125:	53                   	push   %ebx
f0100126:	e8 42 00 00 00       	call   f010016d <__x86.get_pc_thunk.bx>
f010012b:	81 c3 f9 ce 08 00    	add    $0x8cef9,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100131:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100134:	83 ec 04             	sub    $0x4,%esp
f0100137:	ff 75 0c             	pushl  0xc(%ebp)
f010013a:	ff 75 08             	pushl  0x8(%ebp)
f010013d:	8d 83 cf 87 f7 ff    	lea    -0x87831(%ebx),%eax
f0100143:	50                   	push   %eax
f0100144:	e8 3c 3a 00 00       	call   f0103b85 <cprintf>
	vcprintf(fmt, ap);
f0100149:	83 c4 08             	add    $0x8,%esp
f010014c:	56                   	push   %esi
f010014d:	ff 75 10             	pushl  0x10(%ebp)
f0100150:	e8 f9 39 00 00       	call   f0103b4e <vcprintf>
	cprintf("\n");
f0100155:	8d 83 24 8f f7 ff    	lea    -0x870dc(%ebx),%eax
f010015b:	89 04 24             	mov    %eax,(%esp)
f010015e:	e8 22 3a 00 00       	call   f0103b85 <cprintf>
	va_end(ap);
}
f0100163:	83 c4 10             	add    $0x10,%esp
f0100166:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100169:	5b                   	pop    %ebx
f010016a:	5e                   	pop    %esi
f010016b:	5d                   	pop    %ebp
f010016c:	c3                   	ret    

f010016d <__x86.get_pc_thunk.bx>:
f010016d:	8b 1c 24             	mov    (%esp),%ebx
f0100170:	c3                   	ret    

f0100171 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100171:	55                   	push   %ebp
f0100172:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100174:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100179:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010017a:	a8 01                	test   $0x1,%al
f010017c:	74 0b                	je     f0100189 <serial_proc_data+0x18>
f010017e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100183:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100184:	0f b6 c0             	movzbl %al,%eax
}
f0100187:	5d                   	pop    %ebp
f0100188:	c3                   	ret    
		return -1;
f0100189:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010018e:	eb f7                	jmp    f0100187 <serial_proc_data+0x16>

f0100190 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100190:	55                   	push   %ebp
f0100191:	89 e5                	mov    %esp,%ebp
f0100193:	56                   	push   %esi
f0100194:	53                   	push   %ebx
f0100195:	e8 d3 ff ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f010019a:	81 c3 8a ce 08 00    	add    $0x8ce8a,%ebx
f01001a0:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001a2:	ff d6                	call   *%esi
f01001a4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001a7:	74 2e                	je     f01001d7 <cons_intr+0x47>
		if (c == 0)
f01001a9:	85 c0                	test   %eax,%eax
f01001ab:	74 f5                	je     f01001a2 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001ad:	8b 8b 00 23 00 00    	mov    0x2300(%ebx),%ecx
f01001b3:	8d 51 01             	lea    0x1(%ecx),%edx
f01001b6:	89 93 00 23 00 00    	mov    %edx,0x2300(%ebx)
f01001bc:	88 84 0b fc 20 00 00 	mov    %al,0x20fc(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001c3:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c9:	75 d7                	jne    f01001a2 <cons_intr+0x12>
			cons.wpos = 0;
f01001cb:	c7 83 00 23 00 00 00 	movl   $0x0,0x2300(%ebx)
f01001d2:	00 00 00 
f01001d5:	eb cb                	jmp    f01001a2 <cons_intr+0x12>
	}
}
f01001d7:	5b                   	pop    %ebx
f01001d8:	5e                   	pop    %esi
f01001d9:	5d                   	pop    %ebp
f01001da:	c3                   	ret    

f01001db <kbd_proc_data>:
{
f01001db:	55                   	push   %ebp
f01001dc:	89 e5                	mov    %esp,%ebp
f01001de:	56                   	push   %esi
f01001df:	53                   	push   %ebx
f01001e0:	e8 88 ff ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f01001e5:	81 c3 3f ce 08 00    	add    $0x8ce3f,%ebx
f01001eb:	ba 64 00 00 00       	mov    $0x64,%edx
f01001f0:	ec                   	in     (%dx),%al
	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001f1:	a8 01                	test   $0x1,%al
f01001f3:	0f 84 fe 00 00 00    	je     f01002f7 <kbd_proc_data+0x11c>
f01001f9:	ba 60 00 00 00       	mov    $0x60,%edx
f01001fe:	ec                   	in     (%dx),%al
f01001ff:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100201:	3c e0                	cmp    $0xe0,%al
f0100203:	0f 84 93 00 00 00    	je     f010029c <kbd_proc_data+0xc1>
	} else if (data & 0x80) {
f0100209:	84 c0                	test   %al,%al
f010020b:	0f 88 a0 00 00 00    	js     f01002b1 <kbd_proc_data+0xd6>
	} else if (shift & E0ESC) {
f0100211:	8b 8b dc 20 00 00    	mov    0x20dc(%ebx),%ecx
f0100217:	f6 c1 40             	test   $0x40,%cl
f010021a:	74 0e                	je     f010022a <kbd_proc_data+0x4f>
		data |= 0x80;
f010021c:	83 c8 80             	or     $0xffffff80,%eax
f010021f:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100221:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100224:	89 8b dc 20 00 00    	mov    %ecx,0x20dc(%ebx)
	shift |= shiftcode[data];
f010022a:	0f b6 d2             	movzbl %dl,%edx
f010022d:	0f b6 84 13 1c 89 f7 	movzbl -0x876e4(%ebx,%edx,1),%eax
f0100234:	ff 
f0100235:	0b 83 dc 20 00 00    	or     0x20dc(%ebx),%eax
	shift ^= togglecode[data];
f010023b:	0f b6 8c 13 1c 88 f7 	movzbl -0x877e4(%ebx,%edx,1),%ecx
f0100242:	ff 
f0100243:	31 c8                	xor    %ecx,%eax
f0100245:	89 83 dc 20 00 00    	mov    %eax,0x20dc(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f010024b:	89 c1                	mov    %eax,%ecx
f010024d:	83 e1 03             	and    $0x3,%ecx
f0100250:	8b 8c 8b fc 1f 00 00 	mov    0x1ffc(%ebx,%ecx,4),%ecx
f0100257:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010025b:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f010025e:	a8 08                	test   $0x8,%al
f0100260:	74 0d                	je     f010026f <kbd_proc_data+0x94>
		if ('a' <= c && c <= 'z')
f0100262:	89 f2                	mov    %esi,%edx
f0100264:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100267:	83 f9 19             	cmp    $0x19,%ecx
f010026a:	77 7a                	ja     f01002e6 <kbd_proc_data+0x10b>
			c += 'A' - 'a';
f010026c:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010026f:	f7 d0                	not    %eax
f0100271:	a8 06                	test   $0x6,%al
f0100273:	75 33                	jne    f01002a8 <kbd_proc_data+0xcd>
f0100275:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010027b:	75 2b                	jne    f01002a8 <kbd_proc_data+0xcd>
		cprintf("Rebooting!\n");
f010027d:	83 ec 0c             	sub    $0xc,%esp
f0100280:	8d 83 e9 87 f7 ff    	lea    -0x87817(%ebx),%eax
f0100286:	50                   	push   %eax
f0100287:	e8 f9 38 00 00       	call   f0103b85 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010028c:	b8 03 00 00 00       	mov    $0x3,%eax
f0100291:	ba 92 00 00 00       	mov    $0x92,%edx
f0100296:	ee                   	out    %al,(%dx)
f0100297:	83 c4 10             	add    $0x10,%esp
f010029a:	eb 0c                	jmp    f01002a8 <kbd_proc_data+0xcd>
		shift |= E0ESC;
f010029c:	83 8b dc 20 00 00 40 	orl    $0x40,0x20dc(%ebx)
		return 0;
f01002a3:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002a8:	89 f0                	mov    %esi,%eax
f01002aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002ad:	5b                   	pop    %ebx
f01002ae:	5e                   	pop    %esi
f01002af:	5d                   	pop    %ebp
f01002b0:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002b1:	8b 8b dc 20 00 00    	mov    0x20dc(%ebx),%ecx
f01002b7:	89 ce                	mov    %ecx,%esi
f01002b9:	83 e6 40             	and    $0x40,%esi
f01002bc:	83 e0 7f             	and    $0x7f,%eax
f01002bf:	85 f6                	test   %esi,%esi
f01002c1:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002c4:	0f b6 d2             	movzbl %dl,%edx
f01002c7:	0f b6 84 13 1c 89 f7 	movzbl -0x876e4(%ebx,%edx,1),%eax
f01002ce:	ff 
f01002cf:	83 c8 40             	or     $0x40,%eax
f01002d2:	0f b6 c0             	movzbl %al,%eax
f01002d5:	f7 d0                	not    %eax
f01002d7:	21 c8                	and    %ecx,%eax
f01002d9:	89 83 dc 20 00 00    	mov    %eax,0x20dc(%ebx)
		return 0;
f01002df:	be 00 00 00 00       	mov    $0x0,%esi
f01002e4:	eb c2                	jmp    f01002a8 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f01002e6:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002e9:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002ec:	83 fa 1a             	cmp    $0x1a,%edx
f01002ef:	0f 42 f1             	cmovb  %ecx,%esi
f01002f2:	e9 78 ff ff ff       	jmp    f010026f <kbd_proc_data+0x94>
		return -1;
f01002f7:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01002fc:	eb aa                	jmp    f01002a8 <kbd_proc_data+0xcd>

f01002fe <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002fe:	55                   	push   %ebp
f01002ff:	89 e5                	mov    %esp,%ebp
f0100301:	57                   	push   %edi
f0100302:	56                   	push   %esi
f0100303:	53                   	push   %ebx
f0100304:	83 ec 1c             	sub    $0x1c,%esp
f0100307:	e8 61 fe ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f010030c:	81 c3 18 cd 08 00    	add    $0x8cd18,%ebx
f0100312:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100315:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010031a:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010031b:	a8 20                	test   $0x20,%al
f010031d:	75 27                	jne    f0100346 <cons_putc+0x48>
	for (i = 0;
f010031f:	be 00 00 00 00       	mov    $0x0,%esi
f0100324:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100329:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010032e:	89 ca                	mov    %ecx,%edx
f0100330:	ec                   	in     (%dx),%al
f0100331:	ec                   	in     (%dx),%al
f0100332:	ec                   	in     (%dx),%al
f0100333:	ec                   	in     (%dx),%al
	     i++)
f0100334:	83 c6 01             	add    $0x1,%esi
f0100337:	89 fa                	mov    %edi,%edx
f0100339:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010033a:	a8 20                	test   $0x20,%al
f010033c:	75 08                	jne    f0100346 <cons_putc+0x48>
f010033e:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100344:	7e e8                	jle    f010032e <cons_putc+0x30>
	outb(COM1 + COM_TX, c);
f0100346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100349:	89 f8                	mov    %edi,%eax
f010034b:	88 45 e3             	mov    %al,-0x1d(%ebp)
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010034e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100353:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100354:	ba 79 03 00 00       	mov    $0x379,%edx
f0100359:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010035a:	84 c0                	test   %al,%al
f010035c:	78 27                	js     f0100385 <cons_putc+0x87>
f010035e:	be 00 00 00 00       	mov    $0x0,%esi
f0100363:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100368:	bf 79 03 00 00       	mov    $0x379,%edi
f010036d:	89 ca                	mov    %ecx,%edx
f010036f:	ec                   	in     (%dx),%al
f0100370:	ec                   	in     (%dx),%al
f0100371:	ec                   	in     (%dx),%al
f0100372:	ec                   	in     (%dx),%al
f0100373:	83 c6 01             	add    $0x1,%esi
f0100376:	89 fa                	mov    %edi,%edx
f0100378:	ec                   	in     (%dx),%al
f0100379:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010037f:	7f 04                	jg     f0100385 <cons_putc+0x87>
f0100381:	84 c0                	test   %al,%al
f0100383:	79 e8                	jns    f010036d <cons_putc+0x6f>
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100385:	ba 78 03 00 00       	mov    $0x378,%edx
f010038a:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f010038e:	ee                   	out    %al,(%dx)
f010038f:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100394:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100399:	ee                   	out    %al,(%dx)
f010039a:	b8 08 00 00 00       	mov    $0x8,%eax
f010039f:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003a3:	89 fa                	mov    %edi,%edx
f01003a5:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003ab:	89 f8                	mov    %edi,%eax
f01003ad:	80 cc 07             	or     $0x7,%ah
f01003b0:	85 d2                	test   %edx,%edx
f01003b2:	0f 45 c7             	cmovne %edi,%eax
f01003b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f01003b8:	0f b6 c0             	movzbl %al,%eax
f01003bb:	83 f8 09             	cmp    $0x9,%eax
f01003be:	0f 84 b9 00 00 00    	je     f010047d <cons_putc+0x17f>
f01003c4:	83 f8 09             	cmp    $0x9,%eax
f01003c7:	7e 74                	jle    f010043d <cons_putc+0x13f>
f01003c9:	83 f8 0a             	cmp    $0xa,%eax
f01003cc:	0f 84 9e 00 00 00    	je     f0100470 <cons_putc+0x172>
f01003d2:	83 f8 0d             	cmp    $0xd,%eax
f01003d5:	0f 85 d9 00 00 00    	jne    f01004b4 <cons_putc+0x1b6>
		crt_pos -= (crt_pos % CRT_COLS);
f01003db:	0f b7 83 04 23 00 00 	movzwl 0x2304(%ebx),%eax
f01003e2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003e8:	c1 e8 16             	shr    $0x16,%eax
f01003eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003ee:	c1 e0 04             	shl    $0x4,%eax
f01003f1:	66 89 83 04 23 00 00 	mov    %ax,0x2304(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01003f8:	66 81 bb 04 23 00 00 	cmpw   $0x7cf,0x2304(%ebx)
f01003ff:	cf 07 
f0100401:	0f 87 d4 00 00 00    	ja     f01004db <cons_putc+0x1dd>
	outb(addr_6845, 14);
f0100407:	8b 8b 0c 23 00 00    	mov    0x230c(%ebx),%ecx
f010040d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100412:	89 ca                	mov    %ecx,%edx
f0100414:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100415:	0f b7 9b 04 23 00 00 	movzwl 0x2304(%ebx),%ebx
f010041c:	8d 71 01             	lea    0x1(%ecx),%esi
f010041f:	89 d8                	mov    %ebx,%eax
f0100421:	66 c1 e8 08          	shr    $0x8,%ax
f0100425:	89 f2                	mov    %esi,%edx
f0100427:	ee                   	out    %al,(%dx)
f0100428:	b8 0f 00 00 00       	mov    $0xf,%eax
f010042d:	89 ca                	mov    %ecx,%edx
f010042f:	ee                   	out    %al,(%dx)
f0100430:	89 d8                	mov    %ebx,%eax
f0100432:	89 f2                	mov    %esi,%edx
f0100434:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100435:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100438:	5b                   	pop    %ebx
f0100439:	5e                   	pop    %esi
f010043a:	5f                   	pop    %edi
f010043b:	5d                   	pop    %ebp
f010043c:	c3                   	ret    
	switch (c & 0xff) {
f010043d:	83 f8 08             	cmp    $0x8,%eax
f0100440:	75 72                	jne    f01004b4 <cons_putc+0x1b6>
		if (crt_pos > 0) {
f0100442:	0f b7 83 04 23 00 00 	movzwl 0x2304(%ebx),%eax
f0100449:	66 85 c0             	test   %ax,%ax
f010044c:	74 b9                	je     f0100407 <cons_putc+0x109>
			crt_pos--;
f010044e:	83 e8 01             	sub    $0x1,%eax
f0100451:	66 89 83 04 23 00 00 	mov    %ax,0x2304(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100458:	0f b7 c0             	movzwl %ax,%eax
f010045b:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f010045f:	b2 00                	mov    $0x0,%dl
f0100461:	83 ca 20             	or     $0x20,%edx
f0100464:	8b 8b 08 23 00 00    	mov    0x2308(%ebx),%ecx
f010046a:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f010046e:	eb 88                	jmp    f01003f8 <cons_putc+0xfa>
		crt_pos += CRT_COLS;
f0100470:	66 83 83 04 23 00 00 	addw   $0x50,0x2304(%ebx)
f0100477:	50 
f0100478:	e9 5e ff ff ff       	jmp    f01003db <cons_putc+0xdd>
		cons_putc(' ');
f010047d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100482:	e8 77 fe ff ff       	call   f01002fe <cons_putc>
		cons_putc(' ');
f0100487:	b8 20 00 00 00       	mov    $0x20,%eax
f010048c:	e8 6d fe ff ff       	call   f01002fe <cons_putc>
		cons_putc(' ');
f0100491:	b8 20 00 00 00       	mov    $0x20,%eax
f0100496:	e8 63 fe ff ff       	call   f01002fe <cons_putc>
		cons_putc(' ');
f010049b:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a0:	e8 59 fe ff ff       	call   f01002fe <cons_putc>
		cons_putc(' ');
f01004a5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004aa:	e8 4f fe ff ff       	call   f01002fe <cons_putc>
f01004af:	e9 44 ff ff ff       	jmp    f01003f8 <cons_putc+0xfa>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004b4:	0f b7 83 04 23 00 00 	movzwl 0x2304(%ebx),%eax
f01004bb:	8d 50 01             	lea    0x1(%eax),%edx
f01004be:	66 89 93 04 23 00 00 	mov    %dx,0x2304(%ebx)
f01004c5:	0f b7 c0             	movzwl %ax,%eax
f01004c8:	8b 93 08 23 00 00    	mov    0x2308(%ebx),%edx
f01004ce:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004d2:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004d6:	e9 1d ff ff ff       	jmp    f01003f8 <cons_putc+0xfa>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004db:	8b 83 08 23 00 00    	mov    0x2308(%ebx),%eax
f01004e1:	83 ec 04             	sub    $0x4,%esp
f01004e4:	68 00 0f 00 00       	push   $0xf00
f01004e9:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004ef:	52                   	push   %edx
f01004f0:	50                   	push   %eax
f01004f1:	e8 af 4e 00 00       	call   f01053a5 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004f6:	8b 93 08 23 00 00    	mov    0x2308(%ebx),%edx
f01004fc:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100502:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100508:	83 c4 10             	add    $0x10,%esp
f010050b:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100510:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100513:	39 d0                	cmp    %edx,%eax
f0100515:	75 f4                	jne    f010050b <cons_putc+0x20d>
		crt_pos -= CRT_COLS;
f0100517:	66 83 ab 04 23 00 00 	subw   $0x50,0x2304(%ebx)
f010051e:	50 
f010051f:	e9 e3 fe ff ff       	jmp    f0100407 <cons_putc+0x109>

f0100524 <serial_intr>:
{
f0100524:	e8 e7 01 00 00       	call   f0100710 <__x86.get_pc_thunk.ax>
f0100529:	05 fb ca 08 00       	add    $0x8cafb,%eax
	if (serial_exists)
f010052e:	80 b8 10 23 00 00 00 	cmpb   $0x0,0x2310(%eax)
f0100535:	75 02                	jne    f0100539 <serial_intr+0x15>
f0100537:	f3 c3                	repz ret 
{
f0100539:	55                   	push   %ebp
f010053a:	89 e5                	mov    %esp,%ebp
f010053c:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010053f:	8d 80 4d 31 f7 ff    	lea    -0x8ceb3(%eax),%eax
f0100545:	e8 46 fc ff ff       	call   f0100190 <cons_intr>
}
f010054a:	c9                   	leave  
f010054b:	c3                   	ret    

f010054c <kbd_intr>:
{
f010054c:	55                   	push   %ebp
f010054d:	89 e5                	mov    %esp,%ebp
f010054f:	83 ec 08             	sub    $0x8,%esp
f0100552:	e8 b9 01 00 00       	call   f0100710 <__x86.get_pc_thunk.ax>
f0100557:	05 cd ca 08 00       	add    $0x8cacd,%eax
	cons_intr(kbd_proc_data);
f010055c:	8d 80 b7 31 f7 ff    	lea    -0x8ce49(%eax),%eax
f0100562:	e8 29 fc ff ff       	call   f0100190 <cons_intr>
}
f0100567:	c9                   	leave  
f0100568:	c3                   	ret    

f0100569 <cons_getc>:
{
f0100569:	55                   	push   %ebp
f010056a:	89 e5                	mov    %esp,%ebp
f010056c:	53                   	push   %ebx
f010056d:	83 ec 04             	sub    $0x4,%esp
f0100570:	e8 f8 fb ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0100575:	81 c3 af ca 08 00    	add    $0x8caaf,%ebx
	serial_intr();
f010057b:	e8 a4 ff ff ff       	call   f0100524 <serial_intr>
	kbd_intr();
f0100580:	e8 c7 ff ff ff       	call   f010054c <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100585:	8b 93 fc 22 00 00    	mov    0x22fc(%ebx),%edx
	return 0;
f010058b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100590:	3b 93 00 23 00 00    	cmp    0x2300(%ebx),%edx
f0100596:	74 19                	je     f01005b1 <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f0100598:	8d 4a 01             	lea    0x1(%edx),%ecx
f010059b:	89 8b fc 22 00 00    	mov    %ecx,0x22fc(%ebx)
f01005a1:	0f b6 84 13 fc 20 00 	movzbl 0x20fc(%ebx,%edx,1),%eax
f01005a8:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005a9:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005af:	74 06                	je     f01005b7 <cons_getc+0x4e>
}
f01005b1:	83 c4 04             	add    $0x4,%esp
f01005b4:	5b                   	pop    %ebx
f01005b5:	5d                   	pop    %ebp
f01005b6:	c3                   	ret    
			cons.rpos = 0;
f01005b7:	c7 83 fc 22 00 00 00 	movl   $0x0,0x22fc(%ebx)
f01005be:	00 00 00 
f01005c1:	eb ee                	jmp    f01005b1 <cons_getc+0x48>

f01005c3 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005c3:	55                   	push   %ebp
f01005c4:	89 e5                	mov    %esp,%ebp
f01005c6:	57                   	push   %edi
f01005c7:	56                   	push   %esi
f01005c8:	53                   	push   %ebx
f01005c9:	83 ec 1c             	sub    $0x1c,%esp
f01005cc:	e8 9c fb ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f01005d1:	81 c3 53 ca 08 00    	add    $0x8ca53,%ebx
	was = *cp;
f01005d7:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005de:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005e5:	5a a5 
	if (*cp != 0xA55A) {
f01005e7:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005ee:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005f2:	0f 84 bc 00 00 00    	je     f01006b4 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f01005f8:	c7 83 0c 23 00 00 b4 	movl   $0x3b4,0x230c(%ebx)
f01005ff:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100602:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100609:	8b bb 0c 23 00 00    	mov    0x230c(%ebx),%edi
f010060f:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100614:	89 fa                	mov    %edi,%edx
f0100616:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100617:	8d 4f 01             	lea    0x1(%edi),%ecx
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010061a:	89 ca                	mov    %ecx,%edx
f010061c:	ec                   	in     (%dx),%al
f010061d:	0f b6 f0             	movzbl %al,%esi
f0100620:	c1 e6 08             	shl    $0x8,%esi
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100623:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100628:	89 fa                	mov    %edi,%edx
f010062a:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010062b:	89 ca                	mov    %ecx,%edx
f010062d:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010062e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100631:	89 bb 08 23 00 00    	mov    %edi,0x2308(%ebx)
	pos |= inb(addr_6845 + 1);
f0100637:	0f b6 c0             	movzbl %al,%eax
f010063a:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010063c:	66 89 b3 04 23 00 00 	mov    %si,0x2304(%ebx)
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100643:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100648:	89 c8                	mov    %ecx,%eax
f010064a:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010064f:	ee                   	out    %al,(%dx)
f0100650:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100655:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010065a:	89 fa                	mov    %edi,%edx
f010065c:	ee                   	out    %al,(%dx)
f010065d:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100662:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100667:	ee                   	out    %al,(%dx)
f0100668:	be f9 03 00 00       	mov    $0x3f9,%esi
f010066d:	89 c8                	mov    %ecx,%eax
f010066f:	89 f2                	mov    %esi,%edx
f0100671:	ee                   	out    %al,(%dx)
f0100672:	b8 03 00 00 00       	mov    $0x3,%eax
f0100677:	89 fa                	mov    %edi,%edx
f0100679:	ee                   	out    %al,(%dx)
f010067a:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010067f:	89 c8                	mov    %ecx,%eax
f0100681:	ee                   	out    %al,(%dx)
f0100682:	b8 01 00 00 00       	mov    $0x1,%eax
f0100687:	89 f2                	mov    %esi,%edx
f0100689:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010068a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010068f:	ec                   	in     (%dx),%al
f0100690:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100692:	3c ff                	cmp    $0xff,%al
f0100694:	0f 95 83 10 23 00 00 	setne  0x2310(%ebx)
f010069b:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006a0:	ec                   	in     (%dx),%al
f01006a1:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006a6:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006a7:	80 f9 ff             	cmp    $0xff,%cl
f01006aa:	74 25                	je     f01006d1 <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006af:	5b                   	pop    %ebx
f01006b0:	5e                   	pop    %esi
f01006b1:	5f                   	pop    %edi
f01006b2:	5d                   	pop    %ebp
f01006b3:	c3                   	ret    
		*cp = was;
f01006b4:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006bb:	c7 83 0c 23 00 00 d4 	movl   $0x3d4,0x230c(%ebx)
f01006c2:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006c5:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f01006cc:	e9 38 ff ff ff       	jmp    f0100609 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f01006d1:	83 ec 0c             	sub    $0xc,%esp
f01006d4:	8d 83 f5 87 f7 ff    	lea    -0x8780b(%ebx),%eax
f01006da:	50                   	push   %eax
f01006db:	e8 a5 34 00 00       	call   f0103b85 <cprintf>
f01006e0:	83 c4 10             	add    $0x10,%esp
}
f01006e3:	eb c7                	jmp    f01006ac <cons_init+0xe9>

f01006e5 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006e5:	55                   	push   %ebp
f01006e6:	89 e5                	mov    %esp,%ebp
f01006e8:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01006ee:	e8 0b fc ff ff       	call   f01002fe <cons_putc>
}
f01006f3:	c9                   	leave  
f01006f4:	c3                   	ret    

f01006f5 <getchar>:

int
getchar(void)
{
f01006f5:	55                   	push   %ebp
f01006f6:	89 e5                	mov    %esp,%ebp
f01006f8:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006fb:	e8 69 fe ff ff       	call   f0100569 <cons_getc>
f0100700:	85 c0                	test   %eax,%eax
f0100702:	74 f7                	je     f01006fb <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100704:	c9                   	leave  
f0100705:	c3                   	ret    

f0100706 <iscons>:

int
iscons(int fdnum)
{
f0100706:	55                   	push   %ebp
f0100707:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100709:	b8 01 00 00 00       	mov    $0x1,%eax
f010070e:	5d                   	pop    %ebp
f010070f:	c3                   	ret    

f0100710 <__x86.get_pc_thunk.ax>:
f0100710:	8b 04 24             	mov    (%esp),%eax
f0100713:	c3                   	ret    

f0100714 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100714:	55                   	push   %ebp
f0100715:	89 e5                	mov    %esp,%ebp
f0100717:	56                   	push   %esi
f0100718:	53                   	push   %ebx
f0100719:	e8 4f fa ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f010071e:	81 c3 06 c9 08 00    	add    $0x8c906,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100724:	83 ec 04             	sub    $0x4,%esp
f0100727:	8d 83 1c 8a f7 ff    	lea    -0x875e4(%ebx),%eax
f010072d:	50                   	push   %eax
f010072e:	8d 83 3a 8a f7 ff    	lea    -0x875c6(%ebx),%eax
f0100734:	50                   	push   %eax
f0100735:	8d b3 3f 8a f7 ff    	lea    -0x875c1(%ebx),%esi
f010073b:	56                   	push   %esi
f010073c:	e8 44 34 00 00       	call   f0103b85 <cprintf>
f0100741:	83 c4 0c             	add    $0xc,%esp
f0100744:	8d 83 f0 8a f7 ff    	lea    -0x87510(%ebx),%eax
f010074a:	50                   	push   %eax
f010074b:	8d 83 48 8a f7 ff    	lea    -0x875b8(%ebx),%eax
f0100751:	50                   	push   %eax
f0100752:	56                   	push   %esi
f0100753:	e8 2d 34 00 00       	call   f0103b85 <cprintf>
f0100758:	83 c4 0c             	add    $0xc,%esp
f010075b:	8d 83 18 8b f7 ff    	lea    -0x874e8(%ebx),%eax
f0100761:	50                   	push   %eax
f0100762:	8d 83 51 8a f7 ff    	lea    -0x875af(%ebx),%eax
f0100768:	50                   	push   %eax
f0100769:	56                   	push   %esi
f010076a:	e8 16 34 00 00       	call   f0103b85 <cprintf>
	return 0;
}
f010076f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100774:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100777:	5b                   	pop    %ebx
f0100778:	5e                   	pop    %esi
f0100779:	5d                   	pop    %ebp
f010077a:	c3                   	ret    

f010077b <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010077b:	55                   	push   %ebp
f010077c:	89 e5                	mov    %esp,%ebp
f010077e:	57                   	push   %edi
f010077f:	56                   	push   %esi
f0100780:	53                   	push   %ebx
f0100781:	83 ec 18             	sub    $0x18,%esp
f0100784:	e8 e4 f9 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0100789:	81 c3 9b c8 08 00    	add    $0x8c89b,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010078f:	8d 83 5b 8a f7 ff    	lea    -0x875a5(%ebx),%eax
f0100795:	50                   	push   %eax
f0100796:	e8 ea 33 00 00       	call   f0103b85 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010079b:	83 c4 08             	add    $0x8,%esp
f010079e:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
f01007a4:	8d 83 4c 8b f7 ff    	lea    -0x874b4(%ebx),%eax
f01007aa:	50                   	push   %eax
f01007ab:	e8 d5 33 00 00       	call   f0103b85 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007b0:	83 c4 0c             	add    $0xc,%esp
f01007b3:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007b9:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007bf:	50                   	push   %eax
f01007c0:	57                   	push   %edi
f01007c1:	8d 83 74 8b f7 ff    	lea    -0x8748c(%ebx),%eax
f01007c7:	50                   	push   %eax
f01007c8:	e8 b8 33 00 00       	call   f0103b85 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007cd:	83 c4 0c             	add    $0xc,%esp
f01007d0:	c7 c0 b9 57 10 f0    	mov    $0xf01057b9,%eax
f01007d6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007dc:	52                   	push   %edx
f01007dd:	50                   	push   %eax
f01007de:	8d 83 98 8b f7 ff    	lea    -0x87468(%ebx),%eax
f01007e4:	50                   	push   %eax
f01007e5:	e8 9b 33 00 00       	call   f0103b85 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007ea:	83 c4 0c             	add    $0xc,%esp
f01007ed:	c7 c0 00 f1 18 f0    	mov    $0xf018f100,%eax
f01007f3:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007f9:	52                   	push   %edx
f01007fa:	50                   	push   %eax
f01007fb:	8d 83 bc 8b f7 ff    	lea    -0x87444(%ebx),%eax
f0100801:	50                   	push   %eax
f0100802:	e8 7e 33 00 00       	call   f0103b85 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100807:	83 c4 0c             	add    $0xc,%esp
f010080a:	c7 c6 10 00 19 f0    	mov    $0xf0190010,%esi
f0100810:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100816:	50                   	push   %eax
f0100817:	56                   	push   %esi
f0100818:	8d 83 e0 8b f7 ff    	lea    -0x87420(%ebx),%eax
f010081e:	50                   	push   %eax
f010081f:	e8 61 33 00 00       	call   f0103b85 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100824:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100827:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010082d:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f010082f:	c1 fe 0a             	sar    $0xa,%esi
f0100832:	56                   	push   %esi
f0100833:	8d 83 04 8c f7 ff    	lea    -0x873fc(%ebx),%eax
f0100839:	50                   	push   %eax
f010083a:	e8 46 33 00 00       	call   f0103b85 <cprintf>
	return 0;
}
f010083f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100844:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100847:	5b                   	pop    %ebx
f0100848:	5e                   	pop    %esi
f0100849:	5f                   	pop    %edi
f010084a:	5d                   	pop    %ebp
f010084b:	c3                   	ret    

f010084c <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010084c:	55                   	push   %ebp
f010084d:	89 e5                	mov    %esp,%ebp
f010084f:	57                   	push   %edi
f0100850:	56                   	push   %esi
f0100851:	53                   	push   %ebx
f0100852:	83 ec 58             	sub    $0x58,%esp
f0100855:	e8 13 f9 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f010085a:	81 c3 ca c7 08 00    	add    $0x8c7ca,%ebx
	cprintf("Stack backtrace:\n");
f0100860:	8d 83 74 8a f7 ff    	lea    -0x8758c(%ebx),%eax
f0100866:	50                   	push   %eax
f0100867:	e8 19 33 00 00       	call   f0103b85 <cprintf>

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010086c:	89 e8                	mov    %ebp,%eax
    unsigned int ebp, esp, eip;
    ebp = read_ebp(); 
    while(ebp){
f010086e:	83 c4 10             	add    $0x10,%esp
f0100871:	85 c0                	test   %eax,%eax
f0100873:	0f 84 aa 00 00 00    	je     f0100923 <mon_backtrace+0xd7>
f0100879:	89 c7                	mov    %eax,%edi
        eip = *(unsigned int *)(ebp + 4);
        esp = ebp + 4;
        cprintf("ebp %08x eip %08x args", ebp, eip);
f010087b:	8d 83 86 8a f7 ff    	lea    -0x8757a(%ebx),%eax
f0100881:	89 45 b8             	mov    %eax,-0x48(%ebp)
        for(int i = 0; i < 5; ++i){
            esp += 4;
            cprintf(" %08x", *(unsigned int *)esp);
f0100884:	8d 83 9d 8a f7 ff    	lea    -0x87563(%ebx),%eax
f010088a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f010088d:	eb 54                	jmp    f01008e3 <mon_backtrace+0x97>
f010088f:	8b 7d bc             	mov    -0x44(%ebp),%edi
        }   
        cprintf("\n");
f0100892:	83 ec 0c             	sub    $0xc,%esp
f0100895:	8d 83 24 8f f7 ff    	lea    -0x870dc(%ebx),%eax
f010089b:	50                   	push   %eax
f010089c:	e8 e4 32 00 00       	call   f0103b85 <cprintf>
        struct Eipdebuginfo info;
		if (-1 == debuginfo_eip(eip, &info))
f01008a1:	83 c4 08             	add    $0x8,%esp
f01008a4:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008a7:	50                   	push   %eax
f01008a8:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01008ab:	56                   	push   %esi
f01008ac:	e8 c7 3d 00 00       	call   f0104678 <debuginfo_eip>
f01008b1:	83 c4 10             	add    $0x10,%esp
f01008b4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01008b7:	74 6a                	je     f0100923 <mon_backtrace+0xd7>
			break;
        cprintf("%s:%d: %.*s+%u\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
f01008b9:	83 ec 08             	sub    $0x8,%esp
f01008bc:	89 f0                	mov    %esi,%eax
f01008be:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008c1:	50                   	push   %eax
f01008c2:	ff 75 d8             	pushl  -0x28(%ebp)
f01008c5:	ff 75 dc             	pushl  -0x24(%ebp)
f01008c8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008cb:	ff 75 d0             	pushl  -0x30(%ebp)
f01008ce:	8d 83 a3 8a f7 ff    	lea    -0x8755d(%ebx),%eax
f01008d4:	50                   	push   %eax
f01008d5:	e8 ab 32 00 00       	call   f0103b85 <cprintf>
        ebp = *(unsigned int *)ebp;
f01008da:	8b 3f                	mov    (%edi),%edi
    while(ebp){
f01008dc:	83 c4 20             	add    $0x20,%esp
f01008df:	85 ff                	test   %edi,%edi
f01008e1:	74 40                	je     f0100923 <mon_backtrace+0xd7>
        eip = *(unsigned int *)(ebp + 4);
f01008e3:	8d 77 04             	lea    0x4(%edi),%esi
f01008e6:	8b 47 04             	mov    0x4(%edi),%eax
f01008e9:	89 45 c0             	mov    %eax,-0x40(%ebp)
        cprintf("ebp %08x eip %08x args", ebp, eip);
f01008ec:	83 ec 04             	sub    $0x4,%esp
f01008ef:	50                   	push   %eax
f01008f0:	57                   	push   %edi
f01008f1:	ff 75 b8             	pushl  -0x48(%ebp)
f01008f4:	e8 8c 32 00 00       	call   f0103b85 <cprintf>
f01008f9:	8d 47 18             	lea    0x18(%edi),%eax
f01008fc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01008ff:	83 c4 10             	add    $0x10,%esp
f0100902:	89 7d bc             	mov    %edi,-0x44(%ebp)
f0100905:	8b 7d b4             	mov    -0x4c(%ebp),%edi
            esp += 4;
f0100908:	83 c6 04             	add    $0x4,%esi
            cprintf(" %08x", *(unsigned int *)esp);
f010090b:	83 ec 08             	sub    $0x8,%esp
f010090e:	ff 36                	pushl  (%esi)
f0100910:	57                   	push   %edi
f0100911:	e8 6f 32 00 00       	call   f0103b85 <cprintf>
        for(int i = 0; i < 5; ++i){
f0100916:	83 c4 10             	add    $0x10,%esp
f0100919:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f010091c:	75 ea                	jne    f0100908 <mon_backtrace+0xbc>
f010091e:	e9 6c ff ff ff       	jmp    f010088f <mon_backtrace+0x43>
    }   
	return 0;
}
f0100923:	b8 00 00 00 00       	mov    $0x0,%eax
f0100928:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010092b:	5b                   	pop    %ebx
f010092c:	5e                   	pop    %esi
f010092d:	5f                   	pop    %edi
f010092e:	5d                   	pop    %ebp
f010092f:	c3                   	ret    

f0100930 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100930:	55                   	push   %ebp
f0100931:	89 e5                	mov    %esp,%ebp
f0100933:	57                   	push   %edi
f0100934:	56                   	push   %esi
f0100935:	53                   	push   %ebx
f0100936:	83 ec 68             	sub    $0x68,%esp
f0100939:	e8 2f f8 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f010093e:	81 c3 e6 c6 08 00    	add    $0x8c6e6,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100944:	8d 83 30 8c f7 ff    	lea    -0x873d0(%ebx),%eax
f010094a:	50                   	push   %eax
f010094b:	e8 35 32 00 00       	call   f0103b85 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100950:	8d 83 54 8c f7 ff    	lea    -0x873ac(%ebx),%eax
f0100956:	89 04 24             	mov    %eax,(%esp)
f0100959:	e8 27 32 00 00       	call   f0103b85 <cprintf>

	if (tf != NULL)
f010095e:	83 c4 10             	add    $0x10,%esp
f0100961:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100965:	74 0e                	je     f0100975 <monitor+0x45>
		print_trapframe(tf);
f0100967:	83 ec 0c             	sub    $0xc,%esp
f010096a:	ff 75 08             	pushl  0x8(%ebp)
f010096d:	e8 e7 36 00 00       	call   f0104059 <print_trapframe>
f0100972:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100975:	8d bb b7 8a f7 ff    	lea    -0x87549(%ebx),%edi
f010097b:	e9 d0 00 00 00       	jmp    f0100a50 <monitor+0x120>
f0100980:	83 ec 08             	sub    $0x8,%esp
f0100983:	0f be c0             	movsbl %al,%eax
f0100986:	50                   	push   %eax
f0100987:	57                   	push   %edi
f0100988:	e8 6d 49 00 00       	call   f01052fa <strchr>
f010098d:	83 c4 10             	add    $0x10,%esp
f0100990:	85 c0                	test   %eax,%eax
f0100992:	74 08                	je     f010099c <monitor+0x6c>
			*buf++ = 0;
f0100994:	c6 06 00             	movb   $0x0,(%esi)
f0100997:	8d 76 01             	lea    0x1(%esi),%esi
f010099a:	eb 41                	jmp    f01009dd <monitor+0xad>
		if (*buf == 0)
f010099c:	80 3e 00             	cmpb   $0x0,(%esi)
f010099f:	74 43                	je     f01009e4 <monitor+0xb4>
		if (argc == MAXARGS-1) {
f01009a1:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009a5:	0f 84 91 00 00 00    	je     f0100a3c <monitor+0x10c>
		argv[argc++] = buf;
f01009ab:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009ae:	8d 48 01             	lea    0x1(%eax),%ecx
f01009b1:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009b4:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009b8:	0f b6 06             	movzbl (%esi),%eax
f01009bb:	84 c0                	test   %al,%al
f01009bd:	74 1e                	je     f01009dd <monitor+0xad>
f01009bf:	83 ec 08             	sub    $0x8,%esp
f01009c2:	0f be c0             	movsbl %al,%eax
f01009c5:	50                   	push   %eax
f01009c6:	57                   	push   %edi
f01009c7:	e8 2e 49 00 00       	call   f01052fa <strchr>
f01009cc:	83 c4 10             	add    $0x10,%esp
f01009cf:	85 c0                	test   %eax,%eax
f01009d1:	75 0a                	jne    f01009dd <monitor+0xad>
			buf++;
f01009d3:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009d6:	0f b6 06             	movzbl (%esi),%eax
f01009d9:	84 c0                	test   %al,%al
f01009db:	75 e2                	jne    f01009bf <monitor+0x8f>
		while (*buf && strchr(WHITESPACE, *buf))
f01009dd:	0f b6 06             	movzbl (%esi),%eax
f01009e0:	84 c0                	test   %al,%al
f01009e2:	75 9c                	jne    f0100980 <monitor+0x50>
	argv[argc] = 0;
f01009e4:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009e7:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f01009ee:	00 
	if (argc == 0)
f01009ef:	85 c0                	test   %eax,%eax
f01009f1:	74 5d                	je     f0100a50 <monitor+0x120>
f01009f3:	8d b3 1c 20 00 00    	lea    0x201c(%ebx),%esi
	for (i = 0; i < NCOMMANDS; i++) {
f01009f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01009fe:	89 7d a0             	mov    %edi,-0x60(%ebp)
f0100a01:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a03:	83 ec 08             	sub    $0x8,%esp
f0100a06:	ff 36                	pushl  (%esi)
f0100a08:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a0b:	e8 6f 48 00 00       	call   f010527f <strcmp>
f0100a10:	83 c4 10             	add    $0x10,%esp
f0100a13:	85 c0                	test   %eax,%eax
f0100a15:	74 66                	je     f0100a7d <monitor+0x14d>
	for (i = 0; i < NCOMMANDS; i++) {
f0100a17:	83 c7 01             	add    $0x1,%edi
f0100a1a:	83 c6 0c             	add    $0xc,%esi
f0100a1d:	83 ff 03             	cmp    $0x3,%edi
f0100a20:	75 e1                	jne    f0100a03 <monitor+0xd3>
f0100a22:	8b 7d a0             	mov    -0x60(%ebp),%edi
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a25:	83 ec 08             	sub    $0x8,%esp
f0100a28:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a2b:	8d 83 d9 8a f7 ff    	lea    -0x87527(%ebx),%eax
f0100a31:	50                   	push   %eax
f0100a32:	e8 4e 31 00 00       	call   f0103b85 <cprintf>
f0100a37:	83 c4 10             	add    $0x10,%esp
f0100a3a:	eb 14                	jmp    f0100a50 <monitor+0x120>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a3c:	83 ec 08             	sub    $0x8,%esp
f0100a3f:	6a 10                	push   $0x10
f0100a41:	8d 83 bc 8a f7 ff    	lea    -0x87544(%ebx),%eax
f0100a47:	50                   	push   %eax
f0100a48:	e8 38 31 00 00       	call   f0103b85 <cprintf>
f0100a4d:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a50:	8d 83 b3 8a f7 ff    	lea    -0x8754d(%ebx),%eax
f0100a56:	89 c6                	mov    %eax,%esi
f0100a58:	83 ec 0c             	sub    $0xc,%esp
f0100a5b:	56                   	push   %esi
f0100a5c:	e8 13 46 00 00       	call   f0105074 <readline>
		if (buf != NULL)
f0100a61:	83 c4 10             	add    $0x10,%esp
f0100a64:	85 c0                	test   %eax,%eax
f0100a66:	74 f0                	je     f0100a58 <monitor+0x128>
f0100a68:	89 c6                	mov    %eax,%esi
	argv[argc] = 0;
f0100a6a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a71:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100a78:	e9 60 ff ff ff       	jmp    f01009dd <monitor+0xad>
f0100a7d:	89 f8                	mov    %edi,%eax
f0100a7f:	8b 7d a0             	mov    -0x60(%ebp),%edi
			return commands[i].func(argc, argv, tf);
f0100a82:	83 ec 04             	sub    $0x4,%esp
f0100a85:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a88:	ff 75 08             	pushl  0x8(%ebp)
f0100a8b:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a8e:	52                   	push   %edx
f0100a8f:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a92:	ff 94 83 24 20 00 00 	call   *0x2024(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a99:	83 c4 10             	add    $0x10,%esp
f0100a9c:	85 c0                	test   %eax,%eax
f0100a9e:	79 b0                	jns    f0100a50 <monitor+0x120>
				break;
	}
}
f0100aa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aa3:	5b                   	pop    %ebx
f0100aa4:	5e                   	pop    %esi
f0100aa5:	5f                   	pop    %edi
f0100aa6:	5d                   	pop    %ebp
f0100aa7:	c3                   	ret    

f0100aa8 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100aa8:	55                   	push   %ebp
f0100aa9:	89 e5                	mov    %esp,%ebp
f0100aab:	56                   	push   %esi
f0100aac:	53                   	push   %ebx
f0100aad:	e8 83 28 00 00       	call   f0103335 <__x86.get_pc_thunk.cx>
f0100ab2:	81 c1 72 c5 08 00    	add    $0x8c572,%ecx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ab8:	83 b9 14 23 00 00 00 	cmpl   $0x0,0x2314(%ecx)
f0100abf:	74 39                	je     f0100afa <boot_alloc+0x52>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if((unsigned)nextfree + n > KERNBASE + npages * PGSIZE)
f0100ac1:	8b 99 14 23 00 00    	mov    0x2314(%ecx),%ebx
f0100ac7:	8d 34 03             	lea    (%ebx,%eax,1),%esi
f0100aca:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0100ad0:	8b 12                	mov    (%edx),%edx
f0100ad2:	81 c2 00 00 0f 00    	add    $0xf0000,%edx
f0100ad8:	c1 e2 0c             	shl    $0xc,%edx
f0100adb:	39 d6                	cmp    %edx,%esi
f0100add:	77 35                	ja     f0100b14 <boot_alloc+0x6c>
    	panic("boot_alloc: out of memory\n");
	result = nextfree;
	nextfree = ROUNDUP((char *)(nextfree + n), PGSIZE);
f0100adf:	8d 84 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%eax
f0100ae6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100aeb:	89 81 14 23 00 00    	mov    %eax,0x2314(%ecx)
	return result;
}
f0100af1:	89 d8                	mov    %ebx,%eax
f0100af3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100af6:	5b                   	pop    %ebx
f0100af7:	5e                   	pop    %esi
f0100af8:	5d                   	pop    %ebp
f0100af9:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100afa:	c7 c2 10 00 19 f0    	mov    $0xf0190010,%edx
f0100b00:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100b06:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b0c:	89 91 14 23 00 00    	mov    %edx,0x2314(%ecx)
f0100b12:	eb ad                	jmp    f0100ac1 <boot_alloc+0x19>
    	panic("boot_alloc: out of memory\n");
f0100b14:	83 ec 04             	sub    $0x4,%esp
f0100b17:	8d 81 79 8c f7 ff    	lea    -0x87387(%ecx),%eax
f0100b1d:	50                   	push   %eax
f0100b1e:	6a 67                	push   $0x67
f0100b20:	8d 81 94 8c f7 ff    	lea    -0x8736c(%ecx),%eax
f0100b26:	50                   	push   %eax
f0100b27:	89 cb                	mov    %ecx,%ebx
f0100b29:	e8 89 f5 ff ff       	call   f01000b7 <_panic>

f0100b2e <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b2e:	55                   	push   %ebp
f0100b2f:	89 e5                	mov    %esp,%ebp
f0100b31:	56                   	push   %esi
f0100b32:	53                   	push   %ebx
f0100b33:	e8 fd 27 00 00       	call   f0103335 <__x86.get_pc_thunk.cx>
f0100b38:	81 c1 ec c4 08 00    	add    $0x8c4ec,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b3e:	89 d3                	mov    %edx,%ebx
f0100b40:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f0100b43:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100b46:	a8 01                	test   $0x1,%al
f0100b48:	74 5a                	je     f0100ba4 <check_va2pa+0x76>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b4f:	89 c6                	mov    %eax,%esi
f0100b51:	c1 ee 0c             	shr    $0xc,%esi
f0100b54:	c7 c3 04 00 19 f0    	mov    $0xf0190004,%ebx
f0100b5a:	3b 33                	cmp    (%ebx),%esi
f0100b5c:	73 2b                	jae    f0100b89 <check_va2pa+0x5b>
	if (!(p[PTX(va)] & PTE_P))
f0100b5e:	c1 ea 0c             	shr    $0xc,%edx
f0100b61:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b67:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b6e:	89 c2                	mov    %eax,%edx
f0100b70:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b78:	85 d2                	test   %edx,%edx
f0100b7a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b7f:	0f 44 c2             	cmove  %edx,%eax
}
f0100b82:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b85:	5b                   	pop    %ebx
f0100b86:	5e                   	pop    %esi
f0100b87:	5d                   	pop    %ebp
f0100b88:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b89:	50                   	push   %eax
f0100b8a:	8d 81 58 8f f7 ff    	lea    -0x870a8(%ecx),%eax
f0100b90:	50                   	push   %eax
f0100b91:	68 27 03 00 00       	push   $0x327
f0100b96:	8d 81 94 8c f7 ff    	lea    -0x8736c(%ecx),%eax
f0100b9c:	50                   	push   %eax
f0100b9d:	89 cb                	mov    %ecx,%ebx
f0100b9f:	e8 13 f5 ff ff       	call   f01000b7 <_panic>
		return ~0;
f0100ba4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ba9:	eb d7                	jmp    f0100b82 <check_va2pa+0x54>

f0100bab <check_page_free_list>:
{
f0100bab:	55                   	push   %ebp
f0100bac:	89 e5                	mov    %esp,%ebp
f0100bae:	57                   	push   %edi
f0100baf:	56                   	push   %esi
f0100bb0:	53                   	push   %ebx
f0100bb1:	83 ec 3c             	sub    $0x3c,%esp
f0100bb4:	e8 80 27 00 00       	call   f0103339 <__x86.get_pc_thunk.di>
f0100bb9:	81 c7 6b c4 08 00    	add    $0x8c46b,%edi
f0100bbf:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bc2:	84 c0                	test   %al,%al
f0100bc4:	0f 85 0e 03 00 00    	jne    f0100ed8 <check_page_free_list+0x32d>
	if (!page_free_list)
f0100bca:	8b b7 1c 23 00 00    	mov    0x231c(%edi),%esi
f0100bd0:	85 f6                	test   %esi,%esi
f0100bd2:	74 1b                	je     f0100bef <check_page_free_list+0x44>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bd4:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bdb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100bde:	c7 c7 0c 00 19 f0    	mov    $0xf019000c,%edi
	if (PGNUM(pa) >= npages)
f0100be4:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0100bea:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100bed:	eb 3d                	jmp    f0100c2c <check_page_free_list+0x81>
		panic("'page_free_list' is a null pointer!");
f0100bef:	83 ec 04             	sub    $0x4,%esp
f0100bf2:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100bf5:	8d 83 7c 8f f7 ff    	lea    -0x87084(%ebx),%eax
f0100bfb:	50                   	push   %eax
f0100bfc:	68 65 02 00 00       	push   $0x265
f0100c01:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0100c07:	50                   	push   %eax
f0100c08:	e8 aa f4 ff ff       	call   f01000b7 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c0d:	50                   	push   %eax
f0100c0e:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c11:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f0100c17:	50                   	push   %eax
f0100c18:	6a 56                	push   $0x56
f0100c1a:	8d 83 a0 8c f7 ff    	lea    -0x87360(%ebx),%eax
f0100c20:	50                   	push   %eax
f0100c21:	e8 91 f4 ff ff       	call   f01000b7 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c26:	8b 36                	mov    (%esi),%esi
f0100c28:	85 f6                	test   %esi,%esi
f0100c2a:	74 40                	je     f0100c6c <check_page_free_list+0xc1>
	return (pp - pages) << PGSHIFT;
f0100c2c:	89 f0                	mov    %esi,%eax
f0100c2e:	2b 07                	sub    (%edi),%eax
f0100c30:	c1 f8 03             	sar    $0x3,%eax
f0100c33:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c36:	89 c2                	mov    %eax,%edx
f0100c38:	c1 ea 16             	shr    $0x16,%edx
f0100c3b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c3e:	73 e6                	jae    f0100c26 <check_page_free_list+0x7b>
	if (PGNUM(pa) >= npages)
f0100c40:	89 c2                	mov    %eax,%edx
f0100c42:	c1 ea 0c             	shr    $0xc,%edx
f0100c45:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100c48:	3b 11                	cmp    (%ecx),%edx
f0100c4a:	73 c1                	jae    f0100c0d <check_page_free_list+0x62>
			memset(page2kva(pp), 0x97, 128);
f0100c4c:	83 ec 04             	sub    $0x4,%esp
f0100c4f:	68 80 00 00 00       	push   $0x80
f0100c54:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c59:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c5e:	50                   	push   %eax
f0100c5f:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c62:	e8 f1 46 00 00       	call   f0105358 <memset>
f0100c67:	83 c4 10             	add    $0x10,%esp
f0100c6a:	eb ba                	jmp    f0100c26 <check_page_free_list+0x7b>
	first_free_page = (char *) boot_alloc(0);
f0100c6c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c71:	e8 32 fe ff ff       	call   f0100aa8 <boot_alloc>
f0100c76:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c79:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100c7c:	8b 97 1c 23 00 00    	mov    0x231c(%edi),%edx
f0100c82:	85 d2                	test   %edx,%edx
f0100c84:	0f 84 0a 02 00 00    	je     f0100e94 <check_page_free_list+0x2e9>
		assert(pp >= pages);
f0100c8a:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0100c90:	8b 08                	mov    (%eax),%ecx
f0100c92:	39 ca                	cmp    %ecx,%edx
f0100c94:	72 48                	jb     f0100cde <check_page_free_list+0x133>
		assert(pp < pages + npages);
f0100c96:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0100c9c:	8b 00                	mov    (%eax),%eax
f0100c9e:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100ca1:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
f0100ca4:	39 da                	cmp    %ebx,%edx
f0100ca6:	73 58                	jae    f0100d00 <check_page_free_list+0x155>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ca8:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100cab:	89 d0                	mov    %edx,%eax
f0100cad:	29 c8                	sub    %ecx,%eax
f0100caf:	a8 07                	test   $0x7,%al
f0100cb1:	75 6f                	jne    f0100d22 <check_page_free_list+0x177>
	return (pp - pages) << PGSHIFT;
f0100cb3:	c1 f8 03             	sar    $0x3,%eax
f0100cb6:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100cb9:	85 c0                	test   %eax,%eax
f0100cbb:	0f 84 83 00 00 00    	je     f0100d44 <check_page_free_list+0x199>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cc1:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cc6:	0f 84 9a 00 00 00    	je     f0100d66 <check_page_free_list+0x1bb>
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ccc:	be 00 00 00 00       	mov    $0x0,%esi
f0100cd1:	bf 00 00 00 00       	mov    $0x0,%edi
f0100cd6:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0100cd9:	e9 46 01 00 00       	jmp    f0100e24 <check_page_free_list+0x279>
		assert(pp >= pages);
f0100cde:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100ce1:	8d 83 ae 8c f7 ff    	lea    -0x87352(%ebx),%eax
f0100ce7:	50                   	push   %eax
f0100ce8:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0100cee:	50                   	push   %eax
f0100cef:	68 7f 02 00 00       	push   $0x27f
f0100cf4:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0100cfa:	50                   	push   %eax
f0100cfb:	e8 b7 f3 ff ff       	call   f01000b7 <_panic>
		assert(pp < pages + npages);
f0100d00:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d03:	8d 83 cf 8c f7 ff    	lea    -0x87331(%ebx),%eax
f0100d09:	50                   	push   %eax
f0100d0a:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0100d10:	50                   	push   %eax
f0100d11:	68 80 02 00 00       	push   $0x280
f0100d16:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0100d1c:	50                   	push   %eax
f0100d1d:	e8 95 f3 ff ff       	call   f01000b7 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d22:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d25:	8d 83 a0 8f f7 ff    	lea    -0x87060(%ebx),%eax
f0100d2b:	50                   	push   %eax
f0100d2c:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0100d32:	50                   	push   %eax
f0100d33:	68 81 02 00 00       	push   $0x281
f0100d38:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0100d3e:	50                   	push   %eax
f0100d3f:	e8 73 f3 ff ff       	call   f01000b7 <_panic>
		assert(page2pa(pp) != 0);
f0100d44:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d47:	8d 83 e3 8c f7 ff    	lea    -0x8731d(%ebx),%eax
f0100d4d:	50                   	push   %eax
f0100d4e:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0100d54:	50                   	push   %eax
f0100d55:	68 84 02 00 00       	push   $0x284
f0100d5a:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0100d60:	50                   	push   %eax
f0100d61:	e8 51 f3 ff ff       	call   f01000b7 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d66:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d69:	8d 83 f4 8c f7 ff    	lea    -0x8730c(%ebx),%eax
f0100d6f:	50                   	push   %eax
f0100d70:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0100d76:	50                   	push   %eax
f0100d77:	68 85 02 00 00       	push   $0x285
f0100d7c:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0100d82:	50                   	push   %eax
f0100d83:	e8 2f f3 ff ff       	call   f01000b7 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d88:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d8b:	8d 83 d4 8f f7 ff    	lea    -0x8702c(%ebx),%eax
f0100d91:	50                   	push   %eax
f0100d92:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0100d98:	50                   	push   %eax
f0100d99:	68 86 02 00 00       	push   $0x286
f0100d9e:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0100da4:	50                   	push   %eax
f0100da5:	e8 0d f3 ff ff       	call   f01000b7 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100daa:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100dad:	8d 83 0d 8d f7 ff    	lea    -0x872f3(%ebx),%eax
f0100db3:	50                   	push   %eax
f0100db4:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0100dba:	50                   	push   %eax
f0100dbb:	68 87 02 00 00       	push   $0x287
f0100dc0:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0100dc6:	50                   	push   %eax
f0100dc7:	e8 eb f2 ff ff       	call   f01000b7 <_panic>
	if (PGNUM(pa) >= npages)
f0100dcc:	89 c6                	mov    %eax,%esi
f0100dce:	c1 ee 0c             	shr    $0xc,%esi
f0100dd1:	39 75 c8             	cmp    %esi,-0x38(%ebp)
f0100dd4:	76 70                	jbe    f0100e46 <check_page_free_list+0x29b>
	return (void *)(pa + KERNBASE);
f0100dd6:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ddb:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100dde:	77 7f                	ja     f0100e5f <check_page_free_list+0x2b4>
			++nfree_extmem;
f0100de0:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100de4:	8b 12                	mov    (%edx),%edx
f0100de6:	85 d2                	test   %edx,%edx
f0100de8:	0f 84 93 00 00 00    	je     f0100e81 <check_page_free_list+0x2d6>
		assert(pp >= pages);
f0100dee:	39 ca                	cmp    %ecx,%edx
f0100df0:	0f 82 e8 fe ff ff    	jb     f0100cde <check_page_free_list+0x133>
		assert(pp < pages + npages);
f0100df6:	39 da                	cmp    %ebx,%edx
f0100df8:	0f 83 02 ff ff ff    	jae    f0100d00 <check_page_free_list+0x155>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100dfe:	89 d0                	mov    %edx,%eax
f0100e00:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100e03:	a8 07                	test   $0x7,%al
f0100e05:	0f 85 17 ff ff ff    	jne    f0100d22 <check_page_free_list+0x177>
	return (pp - pages) << PGSHIFT;
f0100e0b:	c1 f8 03             	sar    $0x3,%eax
f0100e0e:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100e11:	85 c0                	test   %eax,%eax
f0100e13:	0f 84 2b ff ff ff    	je     f0100d44 <check_page_free_list+0x199>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e19:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e1e:	0f 84 42 ff ff ff    	je     f0100d66 <check_page_free_list+0x1bb>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e24:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e29:	0f 84 59 ff ff ff    	je     f0100d88 <check_page_free_list+0x1dd>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e2f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e34:	0f 84 70 ff ff ff    	je     f0100daa <check_page_free_list+0x1ff>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e3a:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e3f:	77 8b                	ja     f0100dcc <check_page_free_list+0x221>
			++nfree_basemem;
f0100e41:	83 c7 01             	add    $0x1,%edi
f0100e44:	eb 9e                	jmp    f0100de4 <check_page_free_list+0x239>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e46:	50                   	push   %eax
f0100e47:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e4a:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f0100e50:	50                   	push   %eax
f0100e51:	6a 56                	push   $0x56
f0100e53:	8d 83 a0 8c f7 ff    	lea    -0x87360(%ebx),%eax
f0100e59:	50                   	push   %eax
f0100e5a:	e8 58 f2 ff ff       	call   f01000b7 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e5f:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e62:	8d 83 f8 8f f7 ff    	lea    -0x87008(%ebx),%eax
f0100e68:	50                   	push   %eax
f0100e69:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0100e6f:	50                   	push   %eax
f0100e70:	68 88 02 00 00       	push   $0x288
f0100e75:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0100e7b:	50                   	push   %eax
f0100e7c:	e8 36 f2 ff ff       	call   f01000b7 <_panic>
f0100e81:	8b 75 d0             	mov    -0x30(%ebp),%esi
	assert(nfree_basemem > 0);
f0100e84:	85 ff                	test   %edi,%edi
f0100e86:	7e 0c                	jle    f0100e94 <check_page_free_list+0x2e9>
	assert(nfree_extmem > 0);
f0100e88:	85 f6                	test   %esi,%esi
f0100e8a:	7e 2a                	jle    f0100eb6 <check_page_free_list+0x30b>
}
f0100e8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e8f:	5b                   	pop    %ebx
f0100e90:	5e                   	pop    %esi
f0100e91:	5f                   	pop    %edi
f0100e92:	5d                   	pop    %ebp
f0100e93:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e94:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e97:	8d 83 27 8d f7 ff    	lea    -0x872d9(%ebx),%eax
f0100e9d:	50                   	push   %eax
f0100e9e:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0100ea4:	50                   	push   %eax
f0100ea5:	68 90 02 00 00       	push   $0x290
f0100eaa:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0100eb0:	50                   	push   %eax
f0100eb1:	e8 01 f2 ff ff       	call   f01000b7 <_panic>
	assert(nfree_extmem > 0);
f0100eb6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100eb9:	8d 83 39 8d f7 ff    	lea    -0x872c7(%ebx),%eax
f0100ebf:	50                   	push   %eax
f0100ec0:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0100ec6:	50                   	push   %eax
f0100ec7:	68 91 02 00 00       	push   $0x291
f0100ecc:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0100ed2:	50                   	push   %eax
f0100ed3:	e8 df f1 ff ff       	call   f01000b7 <_panic>
	if (!page_free_list)
f0100ed8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100edb:	8b 80 1c 23 00 00    	mov    0x231c(%eax),%eax
f0100ee1:	85 c0                	test   %eax,%eax
f0100ee3:	0f 84 06 fd ff ff    	je     f0100bef <check_page_free_list+0x44>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100ee9:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100eec:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100eef:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ef2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100ef5:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100ef8:	c7 c3 0c 00 19 f0    	mov    $0xf019000c,%ebx
f0100efe:	89 c2                	mov    %eax,%edx
f0100f00:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f02:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100f08:	0f 95 c2             	setne  %dl
f0100f0b:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100f0e:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100f12:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100f14:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f18:	8b 00                	mov    (%eax),%eax
f0100f1a:	85 c0                	test   %eax,%eax
f0100f1c:	75 e0                	jne    f0100efe <check_page_free_list+0x353>
		*tp[1] = 0;
f0100f1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f21:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f27:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f2d:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f2f:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0100f32:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100f35:	89 b0 1c 23 00 00    	mov    %esi,0x231c(%eax)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f3b:	85 f6                	test   %esi,%esi
f0100f3d:	0f 84 29 fd ff ff    	je     f0100c6c <check_page_free_list+0xc1>
f0100f43:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
f0100f4a:	e9 8c fc ff ff       	jmp    f0100bdb <check_page_free_list+0x30>

f0100f4f <page_init>:
{
f0100f4f:	55                   	push   %ebp
f0100f50:	89 e5                	mov    %esp,%ebp
f0100f52:	57                   	push   %edi
f0100f53:	56                   	push   %esi
f0100f54:	53                   	push   %ebx
f0100f55:	83 ec 3c             	sub    $0x3c,%esp
f0100f58:	e8 b3 f7 ff ff       	call   f0100710 <__x86.get_pc_thunk.ax>
f0100f5d:	05 c7 c0 08 00       	add    $0x8c0c7,%eax
f0100f62:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	physaddr_t nextfree_paddr = PADDR((pde_t *)boot_alloc(0));
f0100f65:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f6a:	e8 39 fb ff ff       	call   f0100aa8 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100f6f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f74:	76 60                	jbe    f0100fd6 <page_init+0x87>
	physaddr_t used_interval[2][2] = {{0, PGSIZE}, {IOPHYSMEM, nextfree_paddr}};
f0100f76:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100f7d:	c7 45 dc 00 10 00 00 	movl   $0x1000,-0x24(%ebp)
f0100f84:	c7 45 e0 00 00 0a 00 	movl   $0xa0000,-0x20(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0100f8b:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f90:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(int i = 0; i < npages; ++i){
f0100f93:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0100f96:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0100f9c:	83 38 00             	cmpl   $0x0,(%eax)
f0100f9f:	0f 84 c5 00 00 00    	je     f010106a <page_init+0x11b>
f0100fa5:	8b be 1c 23 00 00    	mov    0x231c(%esi),%edi
f0100fab:	c6 45 cb 00          	movb   $0x0,-0x35(%ebp)
f0100faf:	bb 00 00 00 00       	mov    $0x0,%ebx
	int used_interval_pointer = 0;
f0100fb4:	b8 00 00 00 00       	mov    $0x0,%eax
		while(used_interval_pointer < kUsed_interval_length && used_interval[used_interval_pointer][1] <= page2pa(pages + i))
f0100fb9:	8d 4d d8             	lea    -0x28(%ebp),%ecx
		if(used_interval_pointer >= kUsed_interval_length || page2pa(pages + i) < used_interval[used_interval_pointer][0]){
f0100fbc:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f0100fc2:	89 55 c0             	mov    %edx,-0x40(%ebp)
			pages[i].pp_ref = 0;
f0100fc5:	89 55 d0             	mov    %edx,-0x30(%ebp)
	for(int i = 0; i < npages; ++i){
f0100fc8:	c7 c6 04 00 19 f0    	mov    $0xf0190004,%esi
f0100fce:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0100fd1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100fd4:	eb 4a                	jmp    f0101020 <page_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100fd6:	50                   	push   %eax
f0100fd7:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100fda:	8d 83 40 90 f7 ff    	lea    -0x86fc0(%ebx),%eax
f0100fe0:	50                   	push   %eax
f0100fe1:	68 15 01 00 00       	push   $0x115
f0100fe6:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0100fec:	50                   	push   %eax
f0100fed:	e8 c5 f0 ff ff       	call   f01000b7 <_panic>
f0100ff2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100ff5:	8d 14 dd 00 00 00 00 	lea    0x0(,%ebx,8),%edx
			pages[i].pp_ref = 0;
f0100ffc:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fff:	89 d1                	mov    %edx,%ecx
f0101001:	03 0e                	add    (%esi),%ecx
f0101003:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = page_free_list;
f0101009:	89 39                	mov    %edi,(%ecx)
			page_free_list = pages + i;
f010100b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010100e:	89 d7                	mov    %edx,%edi
f0101010:	03 3e                	add    (%esi),%edi
f0101012:	c6 45 cb 01          	movb   $0x1,-0x35(%ebp)
	for(int i = 0; i < npages; ++i){
f0101016:	83 c3 01             	add    $0x1,%ebx
f0101019:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010101c:	3b 19                	cmp    (%ecx),%ebx
f010101e:	73 44                	jae    f0101064 <page_init+0x115>
		while(used_interval_pointer < kUsed_interval_length && used_interval[used_interval_pointer][1] <= page2pa(pages + i))
f0101020:	83 f8 01             	cmp    $0x1,%eax
f0101023:	7f d0                	jg     f0100ff5 <page_init+0xa6>
f0101025:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
	return (pp - pages) << PGSHIFT;
f010102c:	89 f2                	mov    %esi,%edx
f010102e:	c1 e2 09             	shl    $0x9,%edx
f0101031:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101034:	39 54 c5 dc          	cmp    %edx,-0x24(%ebp,%eax,8)
f0101038:	77 11                	ja     f010104b <page_init+0xfc>
			used_interval_pointer++;
f010103a:	83 c0 01             	add    $0x1,%eax
		while(used_interval_pointer < kUsed_interval_length && used_interval[used_interval_pointer][1] <= page2pa(pages + i))
f010103d:	83 f8 02             	cmp    $0x2,%eax
f0101040:	74 b0                	je     f0100ff2 <page_init+0xa3>
f0101042:	39 54 c1 04          	cmp    %edx,0x4(%ecx,%eax,8)
f0101046:	76 f2                	jbe    f010103a <page_init+0xeb>
f0101048:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		if(used_interval_pointer >= kUsed_interval_length || page2pa(pages + i) < used_interval[used_interval_pointer][0]){
f010104b:	39 54 c5 d8          	cmp    %edx,-0x28(%ebp,%eax,8)
f010104f:	77 a4                	ja     f0100ff5 <page_init+0xa6>
f0101051:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0101054:	03 31                	add    (%ecx),%esi
			pages[i].pp_ref = 1;
f0101056:	66 c7 46 04 01 00    	movw   $0x1,0x4(%esi)
			pages[i].pp_link = NULL;
f010105c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f0101062:	eb b2                	jmp    f0101016 <page_init+0xc7>
f0101064:	80 7d cb 00          	cmpb   $0x0,-0x35(%ebp)
f0101068:	75 08                	jne    f0101072 <page_init+0x123>
}
f010106a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010106d:	5b                   	pop    %ebx
f010106e:	5e                   	pop    %esi
f010106f:	5f                   	pop    %edi
f0101070:	5d                   	pop    %ebp
f0101071:	c3                   	ret    
f0101072:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0101075:	89 b8 1c 23 00 00    	mov    %edi,0x231c(%eax)
f010107b:	eb ed                	jmp    f010106a <page_init+0x11b>

f010107d <page_alloc>:
{
f010107d:	55                   	push   %ebp
f010107e:	89 e5                	mov    %esp,%ebp
f0101080:	56                   	push   %esi
f0101081:	53                   	push   %ebx
f0101082:	e8 e6 f0 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0101087:	81 c3 9d bf 08 00    	add    $0x8bf9d,%ebx
	if(!page_free_list) return NULL;
f010108d:	8b b3 1c 23 00 00    	mov    0x231c(%ebx),%esi
f0101093:	85 f6                	test   %esi,%esi
f0101095:	74 14                	je     f01010ab <page_alloc+0x2e>
	page_free_list = page_free_list->pp_link;
f0101097:	8b 06                	mov    (%esi),%eax
f0101099:	89 83 1c 23 00 00    	mov    %eax,0x231c(%ebx)
	new_page->pp_link = NULL;
f010109f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(alloc_flags & ALLOC_ZERO)
f01010a5:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01010a9:	75 09                	jne    f01010b4 <page_alloc+0x37>
}
f01010ab:	89 f0                	mov    %esi,%eax
f01010ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010b0:	5b                   	pop    %ebx
f01010b1:	5e                   	pop    %esi
f01010b2:	5d                   	pop    %ebp
f01010b3:	c3                   	ret    
f01010b4:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f01010ba:	89 f2                	mov    %esi,%edx
f01010bc:	2b 10                	sub    (%eax),%edx
f01010be:	89 d0                	mov    %edx,%eax
f01010c0:	c1 f8 03             	sar    $0x3,%eax
f01010c3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01010c6:	89 c1                	mov    %eax,%ecx
f01010c8:	c1 e9 0c             	shr    $0xc,%ecx
f01010cb:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f01010d1:	3b 0a                	cmp    (%edx),%ecx
f01010d3:	73 1a                	jae    f01010ef <page_alloc+0x72>
		memset(page2kva(new_page), 0, PGSIZE);
f01010d5:	83 ec 04             	sub    $0x4,%esp
f01010d8:	68 00 10 00 00       	push   $0x1000
f01010dd:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01010df:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010e4:	50                   	push   %eax
f01010e5:	e8 6e 42 00 00       	call   f0105358 <memset>
f01010ea:	83 c4 10             	add    $0x10,%esp
f01010ed:	eb bc                	jmp    f01010ab <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010ef:	50                   	push   %eax
f01010f0:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f01010f6:	50                   	push   %eax
f01010f7:	6a 56                	push   $0x56
f01010f9:	8d 83 a0 8c f7 ff    	lea    -0x87360(%ebx),%eax
f01010ff:	50                   	push   %eax
f0101100:	e8 b2 ef ff ff       	call   f01000b7 <_panic>

f0101105 <page_free>:
{
f0101105:	55                   	push   %ebp
f0101106:	89 e5                	mov    %esp,%ebp
f0101108:	e8 24 22 00 00       	call   f0103331 <__x86.get_pc_thunk.dx>
f010110d:	81 c2 17 bf 08 00    	add    $0x8bf17,%edx
f0101113:	8b 45 08             	mov    0x8(%ebp),%eax
	if(!pp || pp->pp_ref) return;
f0101116:	85 c0                	test   %eax,%eax
f0101118:	74 15                	je     f010112f <page_free+0x2a>
f010111a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010111f:	75 0e                	jne    f010112f <page_free+0x2a>
	pp->pp_link = page_free_list;
f0101121:	8b 8a 1c 23 00 00    	mov    0x231c(%edx),%ecx
f0101127:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f0101129:	89 82 1c 23 00 00    	mov    %eax,0x231c(%edx)
}
f010112f:	5d                   	pop    %ebp
f0101130:	c3                   	ret    

f0101131 <page_decref>:
{
f0101131:	55                   	push   %ebp
f0101132:	89 e5                	mov    %esp,%ebp
f0101134:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101137:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010113b:	83 e8 01             	sub    $0x1,%eax
f010113e:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101142:	66 85 c0             	test   %ax,%ax
f0101145:	74 02                	je     f0101149 <page_decref+0x18>
}
f0101147:	c9                   	leave  
f0101148:	c3                   	ret    
		page_free(pp);
f0101149:	52                   	push   %edx
f010114a:	e8 b6 ff ff ff       	call   f0101105 <page_free>
f010114f:	83 c4 04             	add    $0x4,%esp
}
f0101152:	eb f3                	jmp    f0101147 <page_decref+0x16>

f0101154 <pgdir_walk>:
{
f0101154:	55                   	push   %ebp
f0101155:	89 e5                	mov    %esp,%ebp
f0101157:	57                   	push   %edi
f0101158:	56                   	push   %esi
f0101159:	53                   	push   %ebx
f010115a:	83 ec 0c             	sub    $0xc,%esp
f010115d:	e8 0b f0 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0101162:	81 c3 c2 be 08 00    	add    $0x8bec2,%ebx
f0101168:	8b 7d 0c             	mov    0xc(%ebp),%edi
	pde_t *pgdir_entry = pgdir + PDX(va);
f010116b:	89 fe                	mov    %edi,%esi
f010116d:	c1 ee 16             	shr    $0x16,%esi
f0101170:	c1 e6 02             	shl    $0x2,%esi
f0101173:	03 75 08             	add    0x8(%ebp),%esi
	if(!(*pgdir_entry & PTE_P)){
f0101176:	f6 06 01             	testb  $0x1,(%esi)
f0101179:	75 30                	jne    f01011ab <pgdir_walk+0x57>
		if(create){
f010117b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010117f:	74 71                	je     f01011f2 <pgdir_walk+0x9e>
			struct PageInfo *new_pageinfo = page_alloc(ALLOC_ZERO);
f0101181:	83 ec 0c             	sub    $0xc,%esp
f0101184:	6a 01                	push   $0x1
f0101186:	e8 f2 fe ff ff       	call   f010107d <page_alloc>
			if(!new_pageinfo) return NULL;
f010118b:	83 c4 10             	add    $0x10,%esp
f010118e:	85 c0                	test   %eax,%eax
f0101190:	74 67                	je     f01011f9 <pgdir_walk+0xa5>
			new_pageinfo->pp_ref = 1;
f0101192:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101198:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f010119e:	2b 02                	sub    (%edx),%eax
f01011a0:	c1 f8 03             	sar    $0x3,%eax
f01011a3:	c1 e0 0c             	shl    $0xc,%eax
			*pgdir_entry = page2pa(new_pageinfo) | PTE_P | PTE_U | PTE_W;
f01011a6:	83 c8 07             	or     $0x7,%eax
f01011a9:	89 06                	mov    %eax,(%esi)
	pte_t *pg_address = KADDR(PTE_ADDR(*pgdir_entry));
f01011ab:	8b 06                	mov    (%esi),%eax
f01011ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01011b2:	89 c1                	mov    %eax,%ecx
f01011b4:	c1 e9 0c             	shr    $0xc,%ecx
f01011b7:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f01011bd:	3b 0a                	cmp    (%edx),%ecx
f01011bf:	73 18                	jae    f01011d9 <pgdir_walk+0x85>
	return pg_address + PTX(va);
f01011c1:	c1 ef 0a             	shr    $0xa,%edi
f01011c4:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f01011ca:	8d 84 38 00 00 00 f0 	lea    -0x10000000(%eax,%edi,1),%eax
}
f01011d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011d4:	5b                   	pop    %ebx
f01011d5:	5e                   	pop    %esi
f01011d6:	5f                   	pop    %edi
f01011d7:	5d                   	pop    %ebp
f01011d8:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011d9:	50                   	push   %eax
f01011da:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f01011e0:	50                   	push   %eax
f01011e1:	68 83 01 00 00       	push   $0x183
f01011e6:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01011ec:	50                   	push   %eax
f01011ed:	e8 c5 ee ff ff       	call   f01000b7 <_panic>
			return NULL;
f01011f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01011f7:	eb d8                	jmp    f01011d1 <pgdir_walk+0x7d>
			if(!new_pageinfo) return NULL;
f01011f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01011fe:	eb d1                	jmp    f01011d1 <pgdir_walk+0x7d>

f0101200 <boot_map_region>:
{
f0101200:	55                   	push   %ebp
f0101201:	89 e5                	mov    %esp,%ebp
f0101203:	57                   	push   %edi
f0101204:	56                   	push   %esi
f0101205:	53                   	push   %ebx
f0101206:	83 ec 1c             	sub    $0x1c,%esp
f0101209:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010120c:	8b 7d 08             	mov    0x8(%ebp),%edi
	unsigned length = (size + PGSIZE - 1) / PGSIZE;
f010120f:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0101215:	c1 e9 0c             	shr    $0xc,%ecx
f0101218:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(unsigned i = 0; i < length; ++i){
f010121b:	85 c9                	test   %ecx,%ecx
f010121d:	74 44                	je     f0101263 <boot_map_region+0x63>
f010121f:	89 d6                	mov    %edx,%esi
f0101221:	bb 00 00 00 00       	mov    $0x0,%ebx
		*pg_entry = cur_pa | perm | PTE_P;
f0101226:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101229:	83 c8 01             	or     $0x1,%eax
f010122c:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010122f:	eb 08                	jmp    f0101239 <boot_map_region+0x39>
	for(unsigned i = 0; i < length; ++i){
f0101231:	83 c3 01             	add    $0x1,%ebx
f0101234:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0101237:	74 2a                	je     f0101263 <boot_map_region+0x63>
		pte_t *pg_entry = pgdir_walk(pgdir, (void *)cur_va, true);
f0101239:	83 ec 04             	sub    $0x4,%esp
f010123c:	6a 01                	push   $0x1
f010123e:	56                   	push   %esi
f010123f:	ff 75 e0             	pushl  -0x20(%ebp)
f0101242:	e8 0d ff ff ff       	call   f0101154 <pgdir_walk>
		if(!pg_entry) continue;
f0101247:	83 c4 10             	add    $0x10,%esp
f010124a:	85 c0                	test   %eax,%eax
f010124c:	74 e3                	je     f0101231 <boot_map_region+0x31>
		*pg_entry = cur_pa | perm | PTE_P;
f010124e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101251:	09 fa                	or     %edi,%edx
f0101253:	89 10                	mov    %edx,(%eax)
		cur_va += PGSIZE;
f0101255:	81 c6 00 10 00 00    	add    $0x1000,%esi
		cur_pa += PGSIZE;
f010125b:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0101261:	eb ce                	jmp    f0101231 <boot_map_region+0x31>
}
f0101263:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101266:	5b                   	pop    %ebx
f0101267:	5e                   	pop    %esi
f0101268:	5f                   	pop    %edi
f0101269:	5d                   	pop    %ebp
f010126a:	c3                   	ret    

f010126b <page_lookup>:
{
f010126b:	55                   	push   %ebp
f010126c:	89 e5                	mov    %esp,%ebp
f010126e:	56                   	push   %esi
f010126f:	53                   	push   %ebx
f0101270:	e8 f8 ee ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0101275:	81 c3 af bd 08 00    	add    $0x8bdaf,%ebx
f010127b:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t *pg_entry = pgdir_walk(pgdir, va, 0);
f010127e:	83 ec 04             	sub    $0x4,%esp
f0101281:	6a 00                	push   $0x0
f0101283:	ff 75 0c             	pushl  0xc(%ebp)
f0101286:	ff 75 08             	pushl  0x8(%ebp)
f0101289:	e8 c6 fe ff ff       	call   f0101154 <pgdir_walk>
	if(!pg_entry || !(*pg_entry & PTE_P)) return NULL;
f010128e:	83 c4 10             	add    $0x10,%esp
f0101291:	85 c0                	test   %eax,%eax
f0101293:	74 46                	je     f01012db <page_lookup+0x70>
f0101295:	89 c1                	mov    %eax,%ecx
f0101297:	8b 10                	mov    (%eax),%edx
f0101299:	f6 c2 01             	test   $0x1,%dl
f010129c:	74 44                	je     f01012e2 <page_lookup+0x77>
f010129e:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012a1:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f01012a7:	39 10                	cmp    %edx,(%eax)
f01012a9:	76 18                	jbe    f01012c3 <page_lookup+0x58>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01012ab:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f01012b1:	8b 00                	mov    (%eax),%eax
f01012b3:	8d 04 d0             	lea    (%eax,%edx,8),%eax
	if(pte_store)
f01012b6:	85 f6                	test   %esi,%esi
f01012b8:	74 02                	je     f01012bc <page_lookup+0x51>
		*pte_store = pg_entry;
f01012ba:	89 0e                	mov    %ecx,(%esi)
}
f01012bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012bf:	5b                   	pop    %ebx
f01012c0:	5e                   	pop    %esi
f01012c1:	5d                   	pop    %ebp
f01012c2:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01012c3:	83 ec 04             	sub    $0x4,%esp
f01012c6:	8d 83 64 90 f7 ff    	lea    -0x86f9c(%ebx),%eax
f01012cc:	50                   	push   %eax
f01012cd:	6a 4f                	push   $0x4f
f01012cf:	8d 83 a0 8c f7 ff    	lea    -0x87360(%ebx),%eax
f01012d5:	50                   	push   %eax
f01012d6:	e8 dc ed ff ff       	call   f01000b7 <_panic>
	if(!pg_entry || !(*pg_entry & PTE_P)) return NULL;
f01012db:	b8 00 00 00 00       	mov    $0x0,%eax
f01012e0:	eb da                	jmp    f01012bc <page_lookup+0x51>
f01012e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01012e7:	eb d3                	jmp    f01012bc <page_lookup+0x51>

f01012e9 <page_remove>:
{
f01012e9:	55                   	push   %ebp
f01012ea:	89 e5                	mov    %esp,%ebp
f01012ec:	53                   	push   %ebx
f01012ed:	83 ec 18             	sub    $0x18,%esp
f01012f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pg_entry = NULL;
f01012f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo* pg_entry_info = page_lookup(pgdir, va, &pg_entry);
f01012fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01012fd:	50                   	push   %eax
f01012fe:	53                   	push   %ebx
f01012ff:	ff 75 08             	pushl  0x8(%ebp)
f0101302:	e8 64 ff ff ff       	call   f010126b <page_lookup>
	if(!pg_entry_info) return;
f0101307:	83 c4 10             	add    $0x10,%esp
f010130a:	85 c0                	test   %eax,%eax
f010130c:	75 05                	jne    f0101313 <page_remove+0x2a>
}
f010130e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101311:	c9                   	leave  
f0101312:	c3                   	ret    
	page_decref(pg_entry_info);
f0101313:	83 ec 0c             	sub    $0xc,%esp
f0101316:	50                   	push   %eax
f0101317:	e8 15 fe ff ff       	call   f0101131 <page_decref>
	*pg_entry = 0;
f010131c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010131f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101325:	0f 01 3b             	invlpg (%ebx)
f0101328:	83 c4 10             	add    $0x10,%esp
f010132b:	eb e1                	jmp    f010130e <page_remove+0x25>

f010132d <page_insert>:
{
f010132d:	55                   	push   %ebp
f010132e:	89 e5                	mov    %esp,%ebp
f0101330:	57                   	push   %edi
f0101331:	56                   	push   %esi
f0101332:	53                   	push   %ebx
f0101333:	83 ec 10             	sub    $0x10,%esp
f0101336:	e8 fe 1f 00 00       	call   f0103339 <__x86.get_pc_thunk.di>
f010133b:	81 c7 e9 bc 08 00    	add    $0x8bce9,%edi
f0101341:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pte_t* pg_entry = pgdir_walk(pgdir, va, 1);
f0101344:	6a 01                	push   $0x1
f0101346:	ff 75 10             	pushl  0x10(%ebp)
f0101349:	53                   	push   %ebx
f010134a:	e8 05 fe ff ff       	call   f0101154 <pgdir_walk>
	if(!pg_entry) return -E_NO_MEM;
f010134f:	83 c4 10             	add    $0x10,%esp
f0101352:	85 c0                	test   %eax,%eax
f0101354:	74 54                	je     f01013aa <page_insert+0x7d>
f0101356:	89 c6                	mov    %eax,%esi
	return (pp - pages) << PGSHIFT;
f0101358:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f010135e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101361:	2b 38                	sub    (%eax),%edi
f0101363:	c1 ff 03             	sar    $0x3,%edi
f0101366:	c1 e7 0c             	shl    $0xc,%edi
	pp->pp_ref += 1;
f0101369:	8b 45 0c             	mov    0xc(%ebp),%eax
f010136c:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	if(*pg_entry & PTE_P)
f0101371:	f6 06 01             	testb  $0x1,(%esi)
f0101374:	75 23                	jne    f0101399 <page_insert+0x6c>
	*pg_entry = pg_paddr | perm | PTE_P;
f0101376:	8b 45 14             	mov    0x14(%ebp),%eax
f0101379:	83 c8 01             	or     $0x1,%eax
f010137c:	09 c7                	or     %eax,%edi
f010137e:	89 3e                	mov    %edi,(%esi)
	pgdir[PDX(va)] |= perm;
f0101380:	8b 45 10             	mov    0x10(%ebp),%eax
f0101383:	c1 e8 16             	shr    $0x16,%eax
f0101386:	8b 55 14             	mov    0x14(%ebp),%edx
f0101389:	09 14 83             	or     %edx,(%ebx,%eax,4)
	return 0;
f010138c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101391:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101394:	5b                   	pop    %ebx
f0101395:	5e                   	pop    %esi
f0101396:	5f                   	pop    %edi
f0101397:	5d                   	pop    %ebp
f0101398:	c3                   	ret    
		page_remove(pgdir, va);
f0101399:	83 ec 08             	sub    $0x8,%esp
f010139c:	ff 75 10             	pushl  0x10(%ebp)
f010139f:	53                   	push   %ebx
f01013a0:	e8 44 ff ff ff       	call   f01012e9 <page_remove>
f01013a5:	83 c4 10             	add    $0x10,%esp
f01013a8:	eb cc                	jmp    f0101376 <page_insert+0x49>
	if(!pg_entry) return -E_NO_MEM;
f01013aa:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01013af:	eb e0                	jmp    f0101391 <page_insert+0x64>

f01013b1 <mem_init>:
{
f01013b1:	55                   	push   %ebp
f01013b2:	89 e5                	mov    %esp,%ebp
f01013b4:	57                   	push   %edi
f01013b5:	56                   	push   %esi
f01013b6:	53                   	push   %ebx
f01013b7:	83 ec 48             	sub    $0x48,%esp
f01013ba:	e8 7a 1f 00 00       	call   f0103339 <__x86.get_pc_thunk.di>
f01013bf:	81 c7 65 bc 08 00    	add    $0x8bc65,%edi
f01013c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01013c8:	6a 15                	push   $0x15
f01013ca:	89 fb                	mov    %edi,%ebx
f01013cc:	e8 2d 27 00 00       	call   f0103afe <mc146818_read>
f01013d1:	89 c6                	mov    %eax,%esi
f01013d3:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01013da:	e8 1f 27 00 00       	call   f0103afe <mc146818_read>
f01013df:	c1 e0 08             	shl    $0x8,%eax
f01013e2:	09 f0                	or     %esi,%eax
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01013e4:	c1 e0 0a             	shl    $0xa,%eax
f01013e7:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01013ed:	85 c0                	test   %eax,%eax
f01013ef:	0f 48 c2             	cmovs  %edx,%eax
f01013f2:	c1 f8 0c             	sar    $0xc,%eax
f01013f5:	89 87 20 23 00 00    	mov    %eax,0x2320(%edi)
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01013fb:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101402:	e8 f7 26 00 00       	call   f0103afe <mc146818_read>
f0101407:	89 c6                	mov    %eax,%esi
f0101409:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101410:	e8 e9 26 00 00       	call   f0103afe <mc146818_read>
f0101415:	c1 e0 08             	shl    $0x8,%eax
f0101418:	09 f0                	or     %esi,%eax
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010141a:	c1 e0 0a             	shl    $0xa,%eax
f010141d:	89 c2                	mov    %eax,%edx
f010141f:	8d 80 ff 0f 00 00    	lea    0xfff(%eax),%eax
f0101425:	83 c4 10             	add    $0x10,%esp
f0101428:	85 d2                	test   %edx,%edx
f010142a:	0f 49 c2             	cmovns %edx,%eax
f010142d:	c1 f8 0c             	sar    $0xc,%eax
	if (npages_extmem)
f0101430:	85 c0                	test   %eax,%eax
f0101432:	0f 85 9e 0c 00 00    	jne    f01020d6 <mem_init+0xd25>
		npages = npages_basemem;
f0101438:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010143b:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0101441:	8b 8e 20 23 00 00    	mov    0x2320(%esi),%ecx
f0101447:	89 0a                	mov    %ecx,(%edx)
		npages_extmem * PGSIZE / 1024);
f0101449:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010144c:	c1 e8 0a             	shr    $0xa,%eax
f010144f:	50                   	push   %eax
		npages_basemem * PGSIZE / 1024,
f0101450:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101453:	8b 87 20 23 00 00    	mov    0x2320(%edi),%eax
f0101459:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010145c:	c1 e8 0a             	shr    $0xa,%eax
f010145f:	50                   	push   %eax
		npages * PGSIZE / 1024,
f0101460:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0101466:	8b 00                	mov    (%eax),%eax
f0101468:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010146b:	c1 e8 0a             	shr    $0xa,%eax
f010146e:	50                   	push   %eax
f010146f:	8d 87 84 90 f7 ff    	lea    -0x86f7c(%edi),%eax
f0101475:	50                   	push   %eax
f0101476:	89 fb                	mov    %edi,%ebx
f0101478:	e8 08 27 00 00       	call   f0103b85 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010147d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101482:	e8 21 f6 ff ff       	call   f0100aa8 <boot_alloc>
f0101487:	c7 c6 08 00 19 f0    	mov    $0xf0190008,%esi
f010148d:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f010148f:	83 c4 0c             	add    $0xc,%esp
f0101492:	68 00 10 00 00       	push   $0x1000
f0101497:	6a 00                	push   $0x0
f0101499:	50                   	push   %eax
f010149a:	e8 b9 3e 00 00       	call   f0105358 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010149f:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f01014a1:	83 c4 10             	add    $0x10,%esp
f01014a4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01014a9:	0f 86 3a 0c 00 00    	jbe    f01020e9 <mem_init+0xd38>
	return (physaddr_t)kva - KERNBASE;
f01014af:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01014b5:	83 ca 05             	or     $0x5,%edx
f01014b8:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo) * npages);
f01014be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01014c1:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f01014c7:	8b 00                	mov    (%eax),%eax
f01014c9:	c1 e0 03             	shl    $0x3,%eax
f01014cc:	e8 d7 f5 ff ff       	call   f0100aa8 <boot_alloc>
f01014d1:	c7 c3 0c 00 19 f0    	mov    $0xf019000c,%ebx
f01014d7:	89 03                	mov    %eax,(%ebx)
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f01014d9:	b8 00 80 01 00       	mov    $0x18000,%eax
f01014de:	e8 c5 f5 ff ff       	call   f0100aa8 <boot_alloc>
f01014e3:	c7 c2 4c f3 18 f0    	mov    $0xf018f34c,%edx
f01014e9:	89 02                	mov    %eax,(%edx)
	page_init();
f01014eb:	e8 5f fa ff ff       	call   f0100f4f <page_init>
	check_page_free_list(1);
f01014f0:	b8 01 00 00 00       	mov    $0x1,%eax
f01014f5:	e8 b1 f6 ff ff       	call   f0100bab <check_page_free_list>
	if (!pages)
f01014fa:	83 3b 00             	cmpl   $0x0,(%ebx)
f01014fd:	0f 84 02 0c 00 00    	je     f0102105 <mem_init+0xd54>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101503:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101506:	8b 80 1c 23 00 00    	mov    0x231c(%eax),%eax
f010150c:	85 c0                	test   %eax,%eax
f010150e:	0f 84 0f 0c 00 00    	je     f0102123 <mem_init+0xd72>
f0101514:	be 00 00 00 00       	mov    $0x0,%esi
		++nfree;
f0101519:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010151c:	8b 00                	mov    (%eax),%eax
f010151e:	85 c0                	test   %eax,%eax
f0101520:	75 f7                	jne    f0101519 <mem_init+0x168>
	assert((pp0 = page_alloc(0)));
f0101522:	83 ec 0c             	sub    $0xc,%esp
f0101525:	6a 00                	push   $0x0
f0101527:	e8 51 fb ff ff       	call   f010107d <page_alloc>
f010152c:	89 c3                	mov    %eax,%ebx
f010152e:	83 c4 10             	add    $0x10,%esp
f0101531:	85 c0                	test   %eax,%eax
f0101533:	0f 84 f4 0b 00 00    	je     f010212d <mem_init+0xd7c>
	assert((pp1 = page_alloc(0)));
f0101539:	83 ec 0c             	sub    $0xc,%esp
f010153c:	6a 00                	push   $0x0
f010153e:	e8 3a fb ff ff       	call   f010107d <page_alloc>
f0101543:	89 c7                	mov    %eax,%edi
f0101545:	83 c4 10             	add    $0x10,%esp
f0101548:	85 c0                	test   %eax,%eax
f010154a:	0f 84 ff 0b 00 00    	je     f010214f <mem_init+0xd9e>
	assert((pp2 = page_alloc(0)));
f0101550:	83 ec 0c             	sub    $0xc,%esp
f0101553:	6a 00                	push   $0x0
f0101555:	e8 23 fb ff ff       	call   f010107d <page_alloc>
f010155a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010155d:	83 c4 10             	add    $0x10,%esp
f0101560:	85 c0                	test   %eax,%eax
f0101562:	0f 84 09 0c 00 00    	je     f0102171 <mem_init+0xdc0>
	assert(pp1 && pp1 != pp0);
f0101568:	39 fb                	cmp    %edi,%ebx
f010156a:	0f 84 23 0c 00 00    	je     f0102193 <mem_init+0xde2>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101570:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101573:	39 c7                	cmp    %eax,%edi
f0101575:	0f 84 3a 0c 00 00    	je     f01021b5 <mem_init+0xe04>
f010157b:	39 c3                	cmp    %eax,%ebx
f010157d:	0f 84 32 0c 00 00    	je     f01021b5 <mem_init+0xe04>
	return (pp - pages) << PGSHIFT;
f0101583:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101586:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f010158c:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010158e:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0101594:	8b 10                	mov    (%eax),%edx
f0101596:	c1 e2 0c             	shl    $0xc,%edx
f0101599:	89 d8                	mov    %ebx,%eax
f010159b:	29 c8                	sub    %ecx,%eax
f010159d:	c1 f8 03             	sar    $0x3,%eax
f01015a0:	c1 e0 0c             	shl    $0xc,%eax
f01015a3:	39 d0                	cmp    %edx,%eax
f01015a5:	0f 83 2c 0c 00 00    	jae    f01021d7 <mem_init+0xe26>
f01015ab:	89 f8                	mov    %edi,%eax
f01015ad:	29 c8                	sub    %ecx,%eax
f01015af:	c1 f8 03             	sar    $0x3,%eax
f01015b2:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01015b5:	39 c2                	cmp    %eax,%edx
f01015b7:	0f 86 3c 0c 00 00    	jbe    f01021f9 <mem_init+0xe48>
f01015bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015c0:	29 c8                	sub    %ecx,%eax
f01015c2:	c1 f8 03             	sar    $0x3,%eax
f01015c5:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01015c8:	39 c2                	cmp    %eax,%edx
f01015ca:	0f 86 4b 0c 00 00    	jbe    f010221b <mem_init+0xe6a>
	fl = page_free_list;
f01015d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015d3:	8b 88 1c 23 00 00    	mov    0x231c(%eax),%ecx
f01015d9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f01015dc:	c7 80 1c 23 00 00 00 	movl   $0x0,0x231c(%eax)
f01015e3:	00 00 00 
	assert(!page_alloc(0));
f01015e6:	83 ec 0c             	sub    $0xc,%esp
f01015e9:	6a 00                	push   $0x0
f01015eb:	e8 8d fa ff ff       	call   f010107d <page_alloc>
f01015f0:	83 c4 10             	add    $0x10,%esp
f01015f3:	85 c0                	test   %eax,%eax
f01015f5:	0f 85 42 0c 00 00    	jne    f010223d <mem_init+0xe8c>
	page_free(pp0);
f01015fb:	83 ec 0c             	sub    $0xc,%esp
f01015fe:	53                   	push   %ebx
f01015ff:	e8 01 fb ff ff       	call   f0101105 <page_free>
	page_free(pp1);
f0101604:	89 3c 24             	mov    %edi,(%esp)
f0101607:	e8 f9 fa ff ff       	call   f0101105 <page_free>
	page_free(pp2);
f010160c:	83 c4 04             	add    $0x4,%esp
f010160f:	ff 75 d0             	pushl  -0x30(%ebp)
f0101612:	e8 ee fa ff ff       	call   f0101105 <page_free>
	assert((pp0 = page_alloc(0)));
f0101617:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010161e:	e8 5a fa ff ff       	call   f010107d <page_alloc>
f0101623:	89 c7                	mov    %eax,%edi
f0101625:	83 c4 10             	add    $0x10,%esp
f0101628:	85 c0                	test   %eax,%eax
f010162a:	0f 84 2f 0c 00 00    	je     f010225f <mem_init+0xeae>
	assert((pp1 = page_alloc(0)));
f0101630:	83 ec 0c             	sub    $0xc,%esp
f0101633:	6a 00                	push   $0x0
f0101635:	e8 43 fa ff ff       	call   f010107d <page_alloc>
f010163a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010163d:	83 c4 10             	add    $0x10,%esp
f0101640:	85 c0                	test   %eax,%eax
f0101642:	0f 84 39 0c 00 00    	je     f0102281 <mem_init+0xed0>
	assert((pp2 = page_alloc(0)));
f0101648:	83 ec 0c             	sub    $0xc,%esp
f010164b:	6a 00                	push   $0x0
f010164d:	e8 2b fa ff ff       	call   f010107d <page_alloc>
f0101652:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101655:	83 c4 10             	add    $0x10,%esp
f0101658:	85 c0                	test   %eax,%eax
f010165a:	0f 84 43 0c 00 00    	je     f01022a3 <mem_init+0xef2>
	assert(pp1 && pp1 != pp0);
f0101660:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f0101663:	0f 84 5c 0c 00 00    	je     f01022c5 <mem_init+0xf14>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101669:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010166c:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010166f:	0f 84 72 0c 00 00    	je     f01022e7 <mem_init+0xf36>
f0101675:	39 c7                	cmp    %eax,%edi
f0101677:	0f 84 6a 0c 00 00    	je     f01022e7 <mem_init+0xf36>
	assert(!page_alloc(0));
f010167d:	83 ec 0c             	sub    $0xc,%esp
f0101680:	6a 00                	push   $0x0
f0101682:	e8 f6 f9 ff ff       	call   f010107d <page_alloc>
f0101687:	83 c4 10             	add    $0x10,%esp
f010168a:	85 c0                	test   %eax,%eax
f010168c:	0f 85 77 0c 00 00    	jne    f0102309 <mem_init+0xf58>
f0101692:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101695:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f010169b:	89 f9                	mov    %edi,%ecx
f010169d:	2b 08                	sub    (%eax),%ecx
f010169f:	89 c8                	mov    %ecx,%eax
f01016a1:	c1 f8 03             	sar    $0x3,%eax
f01016a4:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01016a7:	89 c1                	mov    %eax,%ecx
f01016a9:	c1 e9 0c             	shr    $0xc,%ecx
f01016ac:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f01016b2:	3b 0a                	cmp    (%edx),%ecx
f01016b4:	0f 83 71 0c 00 00    	jae    f010232b <mem_init+0xf7a>
	memset(page2kva(pp0), 1, PGSIZE);
f01016ba:	83 ec 04             	sub    $0x4,%esp
f01016bd:	68 00 10 00 00       	push   $0x1000
f01016c2:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01016c4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016c9:	50                   	push   %eax
f01016ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016cd:	e8 86 3c 00 00       	call   f0105358 <memset>
	page_free(pp0);
f01016d2:	89 3c 24             	mov    %edi,(%esp)
f01016d5:	e8 2b fa ff ff       	call   f0101105 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01016da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01016e1:	e8 97 f9 ff ff       	call   f010107d <page_alloc>
f01016e6:	83 c4 10             	add    $0x10,%esp
f01016e9:	85 c0                	test   %eax,%eax
f01016eb:	0f 84 50 0c 00 00    	je     f0102341 <mem_init+0xf90>
	assert(pp && pp0 == pp);
f01016f1:	39 c7                	cmp    %eax,%edi
f01016f3:	0f 85 6a 0c 00 00    	jne    f0102363 <mem_init+0xfb2>
	return (pp - pages) << PGSHIFT;
f01016f9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016fc:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101702:	89 fa                	mov    %edi,%edx
f0101704:	2b 10                	sub    (%eax),%edx
f0101706:	c1 fa 03             	sar    $0x3,%edx
f0101709:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010170c:	89 d1                	mov    %edx,%ecx
f010170e:	c1 e9 0c             	shr    $0xc,%ecx
f0101711:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0101717:	3b 08                	cmp    (%eax),%ecx
f0101719:	0f 83 66 0c 00 00    	jae    f0102385 <mem_init+0xfd4>
		assert(c[i] == 0);
f010171f:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101726:	0f 85 6f 0c 00 00    	jne    f010239b <mem_init+0xfea>
f010172c:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
f0101732:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f0101738:	80 38 00             	cmpb   $0x0,(%eax)
f010173b:	0f 85 5a 0c 00 00    	jne    f010239b <mem_init+0xfea>
f0101741:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101744:	39 d0                	cmp    %edx,%eax
f0101746:	75 f0                	jne    f0101738 <mem_init+0x387>
	page_free_list = fl;
f0101748:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010174b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010174e:	89 8b 1c 23 00 00    	mov    %ecx,0x231c(%ebx)
	page_free(pp0);
f0101754:	83 ec 0c             	sub    $0xc,%esp
f0101757:	57                   	push   %edi
f0101758:	e8 a8 f9 ff ff       	call   f0101105 <page_free>
	page_free(pp1);
f010175d:	83 c4 04             	add    $0x4,%esp
f0101760:	ff 75 d0             	pushl  -0x30(%ebp)
f0101763:	e8 9d f9 ff ff       	call   f0101105 <page_free>
	page_free(pp2);
f0101768:	83 c4 04             	add    $0x4,%esp
f010176b:	ff 75 cc             	pushl  -0x34(%ebp)
f010176e:	e8 92 f9 ff ff       	call   f0101105 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101773:	8b 83 1c 23 00 00    	mov    0x231c(%ebx),%eax
f0101779:	83 c4 10             	add    $0x10,%esp
f010177c:	85 c0                	test   %eax,%eax
f010177e:	74 09                	je     f0101789 <mem_init+0x3d8>
		--nfree;
f0101780:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101783:	8b 00                	mov    (%eax),%eax
f0101785:	85 c0                	test   %eax,%eax
f0101787:	75 f7                	jne    f0101780 <mem_init+0x3cf>
	assert(nfree == 0);
f0101789:	85 f6                	test   %esi,%esi
f010178b:	0f 85 2c 0c 00 00    	jne    f01023bd <mem_init+0x100c>
	cprintf("check_page_alloc() succeeded!\n");
f0101791:	83 ec 0c             	sub    $0xc,%esp
f0101794:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101797:	8d 83 e0 90 f7 ff    	lea    -0x86f20(%ebx),%eax
f010179d:	50                   	push   %eax
f010179e:	e8 e2 23 00 00       	call   f0103b85 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017aa:	e8 ce f8 ff ff       	call   f010107d <page_alloc>
f01017af:	89 c6                	mov    %eax,%esi
f01017b1:	83 c4 10             	add    $0x10,%esp
f01017b4:	85 c0                	test   %eax,%eax
f01017b6:	0f 84 23 0c 00 00    	je     f01023df <mem_init+0x102e>
	assert((pp1 = page_alloc(0)));
f01017bc:	83 ec 0c             	sub    $0xc,%esp
f01017bf:	6a 00                	push   $0x0
f01017c1:	e8 b7 f8 ff ff       	call   f010107d <page_alloc>
f01017c6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01017c9:	83 c4 10             	add    $0x10,%esp
f01017cc:	85 c0                	test   %eax,%eax
f01017ce:	0f 84 2d 0c 00 00    	je     f0102401 <mem_init+0x1050>
	assert((pp2 = page_alloc(0)));
f01017d4:	83 ec 0c             	sub    $0xc,%esp
f01017d7:	6a 00                	push   $0x0
f01017d9:	e8 9f f8 ff ff       	call   f010107d <page_alloc>
f01017de:	89 c7                	mov    %eax,%edi
f01017e0:	83 c4 10             	add    $0x10,%esp
f01017e3:	85 c0                	test   %eax,%eax
f01017e5:	0f 84 38 0c 00 00    	je     f0102423 <mem_init+0x1072>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017eb:	3b 75 d0             	cmp    -0x30(%ebp),%esi
f01017ee:	0f 84 51 0c 00 00    	je     f0102445 <mem_init+0x1094>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017f4:	39 c6                	cmp    %eax,%esi
f01017f6:	0f 84 6b 0c 00 00    	je     f0102467 <mem_init+0x10b6>
f01017fc:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01017ff:	0f 84 62 0c 00 00    	je     f0102467 <mem_init+0x10b6>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101805:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101808:	8b 88 1c 23 00 00    	mov    0x231c(%eax),%ecx
f010180e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101811:	c7 80 1c 23 00 00 00 	movl   $0x0,0x231c(%eax)
f0101818:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010181b:	83 ec 0c             	sub    $0xc,%esp
f010181e:	6a 00                	push   $0x0
f0101820:	e8 58 f8 ff ff       	call   f010107d <page_alloc>
f0101825:	83 c4 10             	add    $0x10,%esp
f0101828:	85 c0                	test   %eax,%eax
f010182a:	0f 85 59 0c 00 00    	jne    f0102489 <mem_init+0x10d8>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101830:	83 ec 04             	sub    $0x4,%esp
f0101833:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101836:	50                   	push   %eax
f0101837:	6a 00                	push   $0x0
f0101839:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010183c:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101842:	ff 30                	pushl  (%eax)
f0101844:	e8 22 fa ff ff       	call   f010126b <page_lookup>
f0101849:	83 c4 10             	add    $0x10,%esp
f010184c:	85 c0                	test   %eax,%eax
f010184e:	0f 85 57 0c 00 00    	jne    f01024ab <mem_init+0x10fa>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101854:	6a 02                	push   $0x2
f0101856:	6a 00                	push   $0x0
f0101858:	ff 75 d0             	pushl  -0x30(%ebp)
f010185b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010185e:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101864:	ff 30                	pushl  (%eax)
f0101866:	e8 c2 fa ff ff       	call   f010132d <page_insert>
f010186b:	83 c4 10             	add    $0x10,%esp
f010186e:	85 c0                	test   %eax,%eax
f0101870:	0f 89 57 0c 00 00    	jns    f01024cd <mem_init+0x111c>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101876:	83 ec 0c             	sub    $0xc,%esp
f0101879:	56                   	push   %esi
f010187a:	e8 86 f8 ff ff       	call   f0101105 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010187f:	6a 02                	push   $0x2
f0101881:	6a 00                	push   $0x0
f0101883:	ff 75 d0             	pushl  -0x30(%ebp)
f0101886:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101889:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f010188f:	ff 30                	pushl  (%eax)
f0101891:	e8 97 fa ff ff       	call   f010132d <page_insert>
f0101896:	83 c4 20             	add    $0x20,%esp
f0101899:	85 c0                	test   %eax,%eax
f010189b:	0f 85 4e 0c 00 00    	jne    f01024ef <mem_init+0x113e>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01018a1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01018a4:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f01018aa:	8b 18                	mov    (%eax),%ebx
	return (pp - pages) << PGSHIFT;
f01018ac:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f01018b2:	8b 08                	mov    (%eax),%ecx
f01018b4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01018b7:	8b 13                	mov    (%ebx),%edx
f01018b9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01018bf:	89 f0                	mov    %esi,%eax
f01018c1:	29 c8                	sub    %ecx,%eax
f01018c3:	c1 f8 03             	sar    $0x3,%eax
f01018c6:	c1 e0 0c             	shl    $0xc,%eax
f01018c9:	39 c2                	cmp    %eax,%edx
f01018cb:	0f 85 40 0c 00 00    	jne    f0102511 <mem_init+0x1160>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01018d1:	ba 00 00 00 00       	mov    $0x0,%edx
f01018d6:	89 d8                	mov    %ebx,%eax
f01018d8:	e8 51 f2 ff ff       	call   f0100b2e <check_va2pa>
f01018dd:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01018e0:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01018e3:	c1 fa 03             	sar    $0x3,%edx
f01018e6:	c1 e2 0c             	shl    $0xc,%edx
f01018e9:	39 d0                	cmp    %edx,%eax
f01018eb:	0f 85 42 0c 00 00    	jne    f0102533 <mem_init+0x1182>
	assert(pp1->pp_ref == 1);
f01018f1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01018f4:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01018f9:	0f 85 56 0c 00 00    	jne    f0102555 <mem_init+0x11a4>
	assert(pp0->pp_ref == 1);
f01018ff:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101904:	0f 85 6d 0c 00 00    	jne    f0102577 <mem_init+0x11c6>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010190a:	6a 02                	push   $0x2
f010190c:	68 00 10 00 00       	push   $0x1000
f0101911:	57                   	push   %edi
f0101912:	53                   	push   %ebx
f0101913:	e8 15 fa ff ff       	call   f010132d <page_insert>
f0101918:	83 c4 10             	add    $0x10,%esp
f010191b:	85 c0                	test   %eax,%eax
f010191d:	0f 85 76 0c 00 00    	jne    f0102599 <mem_init+0x11e8>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101923:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101928:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010192b:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101931:	8b 00                	mov    (%eax),%eax
f0101933:	e8 f6 f1 ff ff       	call   f0100b2e <check_va2pa>
f0101938:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f010193e:	89 f9                	mov    %edi,%ecx
f0101940:	2b 0a                	sub    (%edx),%ecx
f0101942:	89 ca                	mov    %ecx,%edx
f0101944:	c1 fa 03             	sar    $0x3,%edx
f0101947:	c1 e2 0c             	shl    $0xc,%edx
f010194a:	39 d0                	cmp    %edx,%eax
f010194c:	0f 85 69 0c 00 00    	jne    f01025bb <mem_init+0x120a>
	assert(pp2->pp_ref == 1);
f0101952:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101957:	0f 85 80 0c 00 00    	jne    f01025dd <mem_init+0x122c>

	// should be no free memory
	assert(!page_alloc(0));
f010195d:	83 ec 0c             	sub    $0xc,%esp
f0101960:	6a 00                	push   $0x0
f0101962:	e8 16 f7 ff ff       	call   f010107d <page_alloc>
f0101967:	83 c4 10             	add    $0x10,%esp
f010196a:	85 c0                	test   %eax,%eax
f010196c:	0f 85 8d 0c 00 00    	jne    f01025ff <mem_init+0x124e>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101972:	6a 02                	push   $0x2
f0101974:	68 00 10 00 00       	push   $0x1000
f0101979:	57                   	push   %edi
f010197a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010197d:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101983:	ff 30                	pushl  (%eax)
f0101985:	e8 a3 f9 ff ff       	call   f010132d <page_insert>
f010198a:	83 c4 10             	add    $0x10,%esp
f010198d:	85 c0                	test   %eax,%eax
f010198f:	0f 85 8c 0c 00 00    	jne    f0102621 <mem_init+0x1270>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101995:	ba 00 10 00 00       	mov    $0x1000,%edx
f010199a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010199d:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f01019a3:	8b 00                	mov    (%eax),%eax
f01019a5:	e8 84 f1 ff ff       	call   f0100b2e <check_va2pa>
f01019aa:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f01019b0:	89 f9                	mov    %edi,%ecx
f01019b2:	2b 0a                	sub    (%edx),%ecx
f01019b4:	89 ca                	mov    %ecx,%edx
f01019b6:	c1 fa 03             	sar    $0x3,%edx
f01019b9:	c1 e2 0c             	shl    $0xc,%edx
f01019bc:	39 d0                	cmp    %edx,%eax
f01019be:	0f 85 7f 0c 00 00    	jne    f0102643 <mem_init+0x1292>
	assert(pp2->pp_ref == 1);
f01019c4:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01019c9:	0f 85 96 0c 00 00    	jne    f0102665 <mem_init+0x12b4>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01019cf:	83 ec 0c             	sub    $0xc,%esp
f01019d2:	6a 00                	push   $0x0
f01019d4:	e8 a4 f6 ff ff       	call   f010107d <page_alloc>
f01019d9:	83 c4 10             	add    $0x10,%esp
f01019dc:	85 c0                	test   %eax,%eax
f01019de:	0f 85 a3 0c 00 00    	jne    f0102687 <mem_init+0x12d6>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01019e4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01019e7:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f01019ed:	8b 10                	mov    (%eax),%edx
f01019ef:	8b 02                	mov    (%edx),%eax
f01019f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01019f6:	89 c3                	mov    %eax,%ebx
f01019f8:	c1 eb 0c             	shr    $0xc,%ebx
f01019fb:	c7 c1 04 00 19 f0    	mov    $0xf0190004,%ecx
f0101a01:	3b 19                	cmp    (%ecx),%ebx
f0101a03:	0f 83 a0 0c 00 00    	jae    f01026a9 <mem_init+0x12f8>
	return (void *)(pa + KERNBASE);
f0101a09:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a11:	83 ec 04             	sub    $0x4,%esp
f0101a14:	6a 00                	push   $0x0
f0101a16:	68 00 10 00 00       	push   $0x1000
f0101a1b:	52                   	push   %edx
f0101a1c:	e8 33 f7 ff ff       	call   f0101154 <pgdir_walk>
f0101a21:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a24:	8d 51 04             	lea    0x4(%ecx),%edx
f0101a27:	83 c4 10             	add    $0x10,%esp
f0101a2a:	39 d0                	cmp    %edx,%eax
f0101a2c:	0f 85 93 0c 00 00    	jne    f01026c5 <mem_init+0x1314>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a32:	6a 06                	push   $0x6
f0101a34:	68 00 10 00 00       	push   $0x1000
f0101a39:	57                   	push   %edi
f0101a3a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a3d:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101a43:	ff 30                	pushl  (%eax)
f0101a45:	e8 e3 f8 ff ff       	call   f010132d <page_insert>
f0101a4a:	83 c4 10             	add    $0x10,%esp
f0101a4d:	85 c0                	test   %eax,%eax
f0101a4f:	0f 85 92 0c 00 00    	jne    f01026e7 <mem_init+0x1336>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a55:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a58:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101a5e:	8b 18                	mov    (%eax),%ebx
f0101a60:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a65:	89 d8                	mov    %ebx,%eax
f0101a67:	e8 c2 f0 ff ff       	call   f0100b2e <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101a6c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101a6f:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f0101a75:	89 f9                	mov    %edi,%ecx
f0101a77:	2b 0a                	sub    (%edx),%ecx
f0101a79:	89 ca                	mov    %ecx,%edx
f0101a7b:	c1 fa 03             	sar    $0x3,%edx
f0101a7e:	c1 e2 0c             	shl    $0xc,%edx
f0101a81:	39 d0                	cmp    %edx,%eax
f0101a83:	0f 85 80 0c 00 00    	jne    f0102709 <mem_init+0x1358>
	assert(pp2->pp_ref == 1);
f0101a89:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a8e:	0f 85 97 0c 00 00    	jne    f010272b <mem_init+0x137a>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101a94:	83 ec 04             	sub    $0x4,%esp
f0101a97:	6a 00                	push   $0x0
f0101a99:	68 00 10 00 00       	push   $0x1000
f0101a9e:	53                   	push   %ebx
f0101a9f:	e8 b0 f6 ff ff       	call   f0101154 <pgdir_walk>
f0101aa4:	83 c4 10             	add    $0x10,%esp
f0101aa7:	f6 00 04             	testb  $0x4,(%eax)
f0101aaa:	0f 84 9d 0c 00 00    	je     f010274d <mem_init+0x139c>
	assert(kern_pgdir[0] & PTE_U);
f0101ab0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ab3:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101ab9:	8b 00                	mov    (%eax),%eax
f0101abb:	f6 00 04             	testb  $0x4,(%eax)
f0101abe:	0f 84 ab 0c 00 00    	je     f010276f <mem_init+0x13be>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ac4:	6a 02                	push   $0x2
f0101ac6:	68 00 10 00 00       	push   $0x1000
f0101acb:	57                   	push   %edi
f0101acc:	50                   	push   %eax
f0101acd:	e8 5b f8 ff ff       	call   f010132d <page_insert>
f0101ad2:	83 c4 10             	add    $0x10,%esp
f0101ad5:	85 c0                	test   %eax,%eax
f0101ad7:	0f 85 b4 0c 00 00    	jne    f0102791 <mem_init+0x13e0>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101add:	83 ec 04             	sub    $0x4,%esp
f0101ae0:	6a 00                	push   $0x0
f0101ae2:	68 00 10 00 00       	push   $0x1000
f0101ae7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101aea:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101af0:	ff 30                	pushl  (%eax)
f0101af2:	e8 5d f6 ff ff       	call   f0101154 <pgdir_walk>
f0101af7:	83 c4 10             	add    $0x10,%esp
f0101afa:	f6 00 02             	testb  $0x2,(%eax)
f0101afd:	0f 84 b0 0c 00 00    	je     f01027b3 <mem_init+0x1402>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b03:	83 ec 04             	sub    $0x4,%esp
f0101b06:	6a 00                	push   $0x0
f0101b08:	68 00 10 00 00       	push   $0x1000
f0101b0d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b10:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101b16:	ff 30                	pushl  (%eax)
f0101b18:	e8 37 f6 ff ff       	call   f0101154 <pgdir_walk>
f0101b1d:	83 c4 10             	add    $0x10,%esp
f0101b20:	f6 00 04             	testb  $0x4,(%eax)
f0101b23:	0f 85 ac 0c 00 00    	jne    f01027d5 <mem_init+0x1424>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b29:	6a 02                	push   $0x2
f0101b2b:	68 00 00 40 00       	push   $0x400000
f0101b30:	56                   	push   %esi
f0101b31:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b34:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101b3a:	ff 30                	pushl  (%eax)
f0101b3c:	e8 ec f7 ff ff       	call   f010132d <page_insert>
f0101b41:	83 c4 10             	add    $0x10,%esp
f0101b44:	85 c0                	test   %eax,%eax
f0101b46:	0f 89 ab 0c 00 00    	jns    f01027f7 <mem_init+0x1446>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b4c:	6a 02                	push   $0x2
f0101b4e:	68 00 10 00 00       	push   $0x1000
f0101b53:	ff 75 d0             	pushl  -0x30(%ebp)
f0101b56:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b59:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101b5f:	ff 30                	pushl  (%eax)
f0101b61:	e8 c7 f7 ff ff       	call   f010132d <page_insert>
f0101b66:	83 c4 10             	add    $0x10,%esp
f0101b69:	85 c0                	test   %eax,%eax
f0101b6b:	0f 85 a8 0c 00 00    	jne    f0102819 <mem_init+0x1468>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b71:	83 ec 04             	sub    $0x4,%esp
f0101b74:	6a 00                	push   $0x0
f0101b76:	68 00 10 00 00       	push   $0x1000
f0101b7b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b7e:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101b84:	ff 30                	pushl  (%eax)
f0101b86:	e8 c9 f5 ff ff       	call   f0101154 <pgdir_walk>
f0101b8b:	83 c4 10             	add    $0x10,%esp
f0101b8e:	f6 00 04             	testb  $0x4,(%eax)
f0101b91:	0f 85 a4 0c 00 00    	jne    f010283b <mem_init+0x148a>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101b97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b9a:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101ba0:	8b 18                	mov    (%eax),%ebx
f0101ba2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ba7:	89 d8                	mov    %ebx,%eax
f0101ba9:	e8 80 ef ff ff       	call   f0100b2e <check_va2pa>
f0101bae:	89 c2                	mov    %eax,%edx
f0101bb0:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101bb3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101bb6:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101bbc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101bbf:	2b 08                	sub    (%eax),%ecx
f0101bc1:	89 c8                	mov    %ecx,%eax
f0101bc3:	c1 f8 03             	sar    $0x3,%eax
f0101bc6:	c1 e0 0c             	shl    $0xc,%eax
f0101bc9:	39 c2                	cmp    %eax,%edx
f0101bcb:	0f 85 8c 0c 00 00    	jne    f010285d <mem_init+0x14ac>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101bd1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bd6:	89 d8                	mov    %ebx,%eax
f0101bd8:	e8 51 ef ff ff       	call   f0100b2e <check_va2pa>
f0101bdd:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101be0:	0f 85 99 0c 00 00    	jne    f010287f <mem_init+0x14ce>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101be6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101be9:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0101bee:	0f 85 ad 0c 00 00    	jne    f01028a1 <mem_init+0x14f0>
	assert(pp2->pp_ref == 0);
f0101bf4:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101bf9:	0f 85 c4 0c 00 00    	jne    f01028c3 <mem_init+0x1512>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101bff:	83 ec 0c             	sub    $0xc,%esp
f0101c02:	6a 00                	push   $0x0
f0101c04:	e8 74 f4 ff ff       	call   f010107d <page_alloc>
f0101c09:	83 c4 10             	add    $0x10,%esp
f0101c0c:	39 c7                	cmp    %eax,%edi
f0101c0e:	0f 85 d1 0c 00 00    	jne    f01028e5 <mem_init+0x1534>
f0101c14:	85 c0                	test   %eax,%eax
f0101c16:	0f 84 c9 0c 00 00    	je     f01028e5 <mem_init+0x1534>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c1c:	83 ec 08             	sub    $0x8,%esp
f0101c1f:	6a 00                	push   $0x0
f0101c21:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c24:	c7 c3 08 00 19 f0    	mov    $0xf0190008,%ebx
f0101c2a:	ff 33                	pushl  (%ebx)
f0101c2c:	e8 b8 f6 ff ff       	call   f01012e9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c31:	8b 1b                	mov    (%ebx),%ebx
f0101c33:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c38:	89 d8                	mov    %ebx,%eax
f0101c3a:	e8 ef ee ff ff       	call   f0100b2e <check_va2pa>
f0101c3f:	83 c4 10             	add    $0x10,%esp
f0101c42:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c45:	0f 85 bc 0c 00 00    	jne    f0102907 <mem_init+0x1556>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c4b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c50:	89 d8                	mov    %ebx,%eax
f0101c52:	e8 d7 ee ff ff       	call   f0100b2e <check_va2pa>
f0101c57:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101c5a:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f0101c60:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101c63:	2b 0a                	sub    (%edx),%ecx
f0101c65:	89 ca                	mov    %ecx,%edx
f0101c67:	c1 fa 03             	sar    $0x3,%edx
f0101c6a:	c1 e2 0c             	shl    $0xc,%edx
f0101c6d:	39 d0                	cmp    %edx,%eax
f0101c6f:	0f 85 b4 0c 00 00    	jne    f0102929 <mem_init+0x1578>
	assert(pp1->pp_ref == 1);
f0101c75:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c78:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c7d:	0f 85 c8 0c 00 00    	jne    f010294b <mem_init+0x159a>
	assert(pp2->pp_ref == 0);
f0101c83:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101c88:	0f 85 df 0c 00 00    	jne    f010296d <mem_init+0x15bc>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101c8e:	83 ec 08             	sub    $0x8,%esp
f0101c91:	68 00 10 00 00       	push   $0x1000
f0101c96:	53                   	push   %ebx
f0101c97:	e8 4d f6 ff ff       	call   f01012e9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c9c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c9f:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101ca5:	8b 18                	mov    (%eax),%ebx
f0101ca7:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cac:	89 d8                	mov    %ebx,%eax
f0101cae:	e8 7b ee ff ff       	call   f0100b2e <check_va2pa>
f0101cb3:	83 c4 10             	add    $0x10,%esp
f0101cb6:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cb9:	0f 85 d0 0c 00 00    	jne    f010298f <mem_init+0x15de>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101cbf:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cc4:	89 d8                	mov    %ebx,%eax
f0101cc6:	e8 63 ee ff ff       	call   f0100b2e <check_va2pa>
f0101ccb:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cce:	0f 85 dd 0c 00 00    	jne    f01029b1 <mem_init+0x1600>
	assert(pp1->pp_ref == 0);
f0101cd4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101cd7:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101cdc:	0f 85 f1 0c 00 00    	jne    f01029d3 <mem_init+0x1622>
	assert(pp2->pp_ref == 0);
f0101ce2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101ce7:	0f 85 08 0d 00 00    	jne    f01029f5 <mem_init+0x1644>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101ced:	83 ec 0c             	sub    $0xc,%esp
f0101cf0:	6a 00                	push   $0x0
f0101cf2:	e8 86 f3 ff ff       	call   f010107d <page_alloc>
f0101cf7:	83 c4 10             	add    $0x10,%esp
f0101cfa:	85 c0                	test   %eax,%eax
f0101cfc:	0f 84 15 0d 00 00    	je     f0102a17 <mem_init+0x1666>
f0101d02:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101d05:	0f 85 0c 0d 00 00    	jne    f0102a17 <mem_init+0x1666>

	// should be no free memory
	assert(!page_alloc(0));
f0101d0b:	83 ec 0c             	sub    $0xc,%esp
f0101d0e:	6a 00                	push   $0x0
f0101d10:	e8 68 f3 ff ff       	call   f010107d <page_alloc>
f0101d15:	83 c4 10             	add    $0x10,%esp
f0101d18:	85 c0                	test   %eax,%eax
f0101d1a:	0f 85 19 0d 00 00    	jne    f0102a39 <mem_init+0x1688>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d20:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d23:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101d29:	8b 08                	mov    (%eax),%ecx
f0101d2b:	8b 11                	mov    (%ecx),%edx
f0101d2d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d33:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101d39:	89 f3                	mov    %esi,%ebx
f0101d3b:	2b 18                	sub    (%eax),%ebx
f0101d3d:	89 d8                	mov    %ebx,%eax
f0101d3f:	c1 f8 03             	sar    $0x3,%eax
f0101d42:	c1 e0 0c             	shl    $0xc,%eax
f0101d45:	39 c2                	cmp    %eax,%edx
f0101d47:	0f 85 0e 0d 00 00    	jne    f0102a5b <mem_init+0x16aa>
	kern_pgdir[0] = 0;
f0101d4d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101d53:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d58:	0f 85 1f 0d 00 00    	jne    f0102a7d <mem_init+0x16cc>
	pp0->pp_ref = 0;
f0101d5e:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101d64:	83 ec 0c             	sub    $0xc,%esp
f0101d67:	56                   	push   %esi
f0101d68:	e8 98 f3 ff ff       	call   f0101105 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101d6d:	83 c4 0c             	add    $0xc,%esp
f0101d70:	6a 01                	push   $0x1
f0101d72:	68 00 10 40 00       	push   $0x401000
f0101d77:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d7a:	c7 c3 08 00 19 f0    	mov    $0xf0190008,%ebx
f0101d80:	ff 33                	pushl  (%ebx)
f0101d82:	e8 cd f3 ff ff       	call   f0101154 <pgdir_walk>
f0101d87:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101d8d:	8b 1b                	mov    (%ebx),%ebx
f0101d8f:	8b 53 04             	mov    0x4(%ebx),%edx
f0101d92:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101d98:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d9b:	c7 c1 04 00 19 f0    	mov    $0xf0190004,%ecx
f0101da1:	8b 09                	mov    (%ecx),%ecx
f0101da3:	89 d0                	mov    %edx,%eax
f0101da5:	c1 e8 0c             	shr    $0xc,%eax
f0101da8:	83 c4 10             	add    $0x10,%esp
f0101dab:	39 c8                	cmp    %ecx,%eax
f0101dad:	0f 83 ec 0c 00 00    	jae    f0102a9f <mem_init+0x16ee>
	assert(ptep == ptep1 + PTX(va));
f0101db3:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101db9:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0101dbc:	0f 85 f9 0c 00 00    	jne    f0102abb <mem_init+0x170a>
	kern_pgdir[PDX(va)] = 0;
f0101dc2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0101dc9:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
	return (pp - pages) << PGSHIFT;
f0101dcf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dd2:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101dd8:	89 f3                	mov    %esi,%ebx
f0101dda:	2b 18                	sub    (%eax),%ebx
f0101ddc:	89 d8                	mov    %ebx,%eax
f0101dde:	c1 f8 03             	sar    $0x3,%eax
f0101de1:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101de4:	89 c2                	mov    %eax,%edx
f0101de6:	c1 ea 0c             	shr    $0xc,%edx
f0101de9:	39 d1                	cmp    %edx,%ecx
f0101deb:	0f 86 ec 0c 00 00    	jbe    f0102add <mem_init+0x172c>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101df1:	83 ec 04             	sub    $0x4,%esp
f0101df4:	68 00 10 00 00       	push   $0x1000
f0101df9:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101dfe:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e03:	50                   	push   %eax
f0101e04:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e07:	e8 4c 35 00 00       	call   f0105358 <memset>
	page_free(pp0);
f0101e0c:	89 34 24             	mov    %esi,(%esp)
f0101e0f:	e8 f1 f2 ff ff       	call   f0101105 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e14:	83 c4 0c             	add    $0xc,%esp
f0101e17:	6a 01                	push   $0x1
f0101e19:	6a 00                	push   $0x0
f0101e1b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e1e:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101e24:	ff 30                	pushl  (%eax)
f0101e26:	e8 29 f3 ff ff       	call   f0101154 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101e2b:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101e31:	89 f2                	mov    %esi,%edx
f0101e33:	2b 10                	sub    (%eax),%edx
f0101e35:	c1 fa 03             	sar    $0x3,%edx
f0101e38:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101e3b:	89 d1                	mov    %edx,%ecx
f0101e3d:	c1 e9 0c             	shr    $0xc,%ecx
f0101e40:	83 c4 10             	add    $0x10,%esp
f0101e43:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0101e49:	3b 08                	cmp    (%eax),%ecx
f0101e4b:	0f 83 a5 0c 00 00    	jae    f0102af6 <mem_init+0x1745>
	return (void *)(pa + KERNBASE);
f0101e51:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101e57:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101e5a:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0101e61:	0f 85 a8 0c 00 00    	jne    f0102b0f <mem_init+0x175e>
f0101e67:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
f0101e6d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f0101e73:	f6 00 01             	testb  $0x1,(%eax)
f0101e76:	0f 85 93 0c 00 00    	jne    f0102b0f <mem_init+0x175e>
f0101e7c:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101e7f:	39 d0                	cmp    %edx,%eax
f0101e81:	75 f0                	jne    f0101e73 <mem_init+0xac2>
	kern_pgdir[0] = 0;
f0101e83:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e86:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101e8c:	8b 00                	mov    (%eax),%eax
f0101e8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101e94:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0101e9a:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101e9d:	89 83 1c 23 00 00    	mov    %eax,0x231c(%ebx)

	// free the pages we took
	page_free(pp0);
f0101ea3:	83 ec 0c             	sub    $0xc,%esp
f0101ea6:	56                   	push   %esi
f0101ea7:	e8 59 f2 ff ff       	call   f0101105 <page_free>
	page_free(pp1);
f0101eac:	83 c4 04             	add    $0x4,%esp
f0101eaf:	ff 75 d0             	pushl  -0x30(%ebp)
f0101eb2:	e8 4e f2 ff ff       	call   f0101105 <page_free>
	page_free(pp2);
f0101eb7:	89 3c 24             	mov    %edi,(%esp)
f0101eba:	e8 46 f2 ff ff       	call   f0101105 <page_free>

	cprintf("check_page() succeeded!\n");
f0101ebf:	8d 83 0d 8f f7 ff    	lea    -0x870f3(%ebx),%eax
f0101ec5:	89 04 24             	mov    %eax,(%esp)
f0101ec8:	e8 b8 1c 00 00       	call   f0103b85 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, sizeof(struct PageInfo) * npages, PADDR(pages), PTE_U | PTE_W);
f0101ecd:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101ed3:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0101ed5:	83 c4 10             	add    $0x10,%esp
f0101ed8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101edd:	0f 86 4e 0c 00 00    	jbe    f0102b31 <mem_init+0x1780>
f0101ee3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101ee6:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0101eec:	8b 0a                	mov    (%edx),%ecx
f0101eee:	c1 e1 03             	shl    $0x3,%ecx
f0101ef1:	83 ec 08             	sub    $0x8,%esp
f0101ef4:	6a 06                	push   $0x6
	return (physaddr_t)kva - KERNBASE;
f0101ef6:	05 00 00 00 10       	add    $0x10000000,%eax
f0101efb:	50                   	push   %eax
f0101efc:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101f01:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101f07:	8b 00                	mov    (%eax),%eax
f0101f09:	e8 f2 f2 ff ff       	call   f0101200 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, sizeof(struct Env) * NENV, PADDR(envs), PTE_U | PTE_W);
f0101f0e:	c7 c0 4c f3 18 f0    	mov    $0xf018f34c,%eax
f0101f14:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0101f16:	83 c4 10             	add    $0x10,%esp
f0101f19:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101f1e:	0f 86 29 0c 00 00    	jbe    f0102b4d <mem_init+0x179c>
f0101f24:	83 ec 08             	sub    $0x8,%esp
f0101f27:	6a 06                	push   $0x6
	return (physaddr_t)kva - KERNBASE;
f0101f29:	05 00 00 00 10       	add    $0x10000000,%eax
f0101f2e:	50                   	push   %eax
f0101f2f:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0101f34:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0101f39:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101f3c:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101f42:	8b 00                	mov    (%eax),%eax
f0101f44:	e8 b7 f2 ff ff       	call   f0101200 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0101f49:	c7 c0 00 30 11 f0    	mov    $0xf0113000,%eax
f0101f4f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101f52:	83 c4 10             	add    $0x10,%esp
f0101f55:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101f5a:	0f 86 09 0c 00 00    	jbe    f0102b69 <mem_init+0x17b8>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0101f60:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101f63:	c7 c3 08 00 19 f0    	mov    $0xf0190008,%ebx
f0101f69:	83 ec 08             	sub    $0x8,%esp
f0101f6c:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f0101f6e:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101f71:	05 00 00 00 10       	add    $0x10000000,%eax
f0101f76:	50                   	push   %eax
f0101f77:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101f7c:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0101f81:	8b 03                	mov    (%ebx),%eax
f0101f83:	e8 78 f2 ff ff       	call   f0101200 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffffu - KERNBASE, 0, PTE_W);
f0101f88:	83 c4 08             	add    $0x8,%esp
f0101f8b:	6a 02                	push   $0x2
f0101f8d:	6a 00                	push   $0x0
f0101f8f:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0101f94:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101f99:	8b 03                	mov    (%ebx),%eax
f0101f9b:	e8 60 f2 ff ff       	call   f0101200 <boot_map_region>
	pgdir = kern_pgdir;
f0101fa0:	8b 33                	mov    (%ebx),%esi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101fa2:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0101fa8:	8b 00                	mov    (%eax),%eax
f0101faa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101fad:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
	for (i = 0; i < n; i += PGSIZE)
f0101fb4:	83 c4 10             	add    $0x10,%esp
f0101fb7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101fbc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101fbf:	74 49                	je     f010200a <mem_init+0xc59>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101fc1:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101fc7:	8b 00                	mov    (%eax),%eax
f0101fc9:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0101fcc:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0101fcf:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
	for (i = 0; i < n; i += PGSIZE)
f0101fd5:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101fda:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0101fe0:	89 f0                	mov    %esi,%eax
f0101fe2:	e8 47 eb ff ff       	call   f0100b2e <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0101fe7:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0101fee:	0f 86 96 0b 00 00    	jbe    f0102b8a <mem_init+0x17d9>
f0101ff4:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0101ff7:	39 c2                	cmp    %eax,%edx
f0101ff9:	0f 85 a9 0b 00 00    	jne    f0102ba8 <mem_init+0x17f7>
	for (i = 0; i < n; i += PGSIZE)
f0101fff:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102005:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102008:	77 d0                	ja     f0101fda <mem_init+0xc29>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010200a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010200d:	c7 c0 4c f3 18 f0    	mov    $0xf018f34c,%eax
f0102013:	8b 00                	mov    (%eax),%eax
f0102015:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102018:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010201b:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0102020:	8d 98 00 00 40 21    	lea    0x21400000(%eax),%ebx
f0102026:	89 fa                	mov    %edi,%edx
f0102028:	89 f0                	mov    %esi,%eax
f010202a:	e8 ff ea ff ff       	call   f0100b2e <check_va2pa>
f010202f:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102036:	0f 86 8e 0b 00 00    	jbe    f0102bca <mem_init+0x1819>
f010203c:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f010203f:	39 c2                	cmp    %eax,%edx
f0102041:	0f 85 a1 0b 00 00    	jne    f0102be8 <mem_init+0x1837>
f0102047:	81 c7 00 10 00 00    	add    $0x1000,%edi
	for (i = 0; i < n; i += PGSIZE)
f010204d:	81 ff 00 80 c1 ee    	cmp    $0xeec18000,%edi
f0102053:	75 d1                	jne    f0102026 <mem_init+0xc75>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102055:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102058:	c1 e7 0c             	shl    $0xc,%edi
f010205b:	85 ff                	test   %edi,%edi
f010205d:	0f 84 c9 0b 00 00    	je     f0102c2c <mem_init+0x187b>
f0102063:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102068:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010206e:	89 f0                	mov    %esi,%eax
f0102070:	e8 b9 ea ff ff       	call   f0100b2e <check_va2pa>
f0102075:	39 d8                	cmp    %ebx,%eax
f0102077:	0f 85 8d 0b 00 00    	jne    f0102c0a <mem_init+0x1859>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010207d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102083:	39 fb                	cmp    %edi,%ebx
f0102085:	72 e1                	jb     f0102068 <mem_init+0xcb7>
f0102087:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010208c:	8b 7d c8             	mov    -0x38(%ebp),%edi
f010208f:	81 c7 00 80 00 20    	add    $0x20008000,%edi
f0102095:	89 da                	mov    %ebx,%edx
f0102097:	89 f0                	mov    %esi,%eax
f0102099:	e8 90 ea ff ff       	call   f0100b2e <check_va2pa>
f010209e:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f01020a1:	39 c2                	cmp    %eax,%edx
f01020a3:	0f 85 8d 0b 00 00    	jne    f0102c36 <mem_init+0x1885>
f01020a9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01020af:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f01020b5:	75 de                	jne    f0102095 <mem_init+0xce4>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01020b7:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01020bc:	89 f0                	mov    %esi,%eax
f01020be:	e8 6b ea ff ff       	call   f0100b2e <check_va2pa>
f01020c3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020c6:	0f 85 8c 0b 00 00    	jne    f0102c58 <mem_init+0x18a7>
	for (i = 0; i < NPDENTRIES; i++) {
f01020cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01020d1:	e9 b8 0b 00 00       	jmp    f0102c8e <mem_init+0x18dd>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01020d6:	8d 88 00 01 00 00    	lea    0x100(%eax),%ecx
f01020dc:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f01020e2:	89 0a                	mov    %ecx,(%edx)
f01020e4:	e9 60 f3 ff ff       	jmp    f0101449 <mem_init+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01020e9:	50                   	push   %eax
f01020ea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020ed:	8d 83 40 90 f7 ff    	lea    -0x86fc0(%ebx),%eax
f01020f3:	50                   	push   %eax
f01020f4:	68 8e 00 00 00       	push   $0x8e
f01020f9:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01020ff:	50                   	push   %eax
f0102100:	e8 b2 df ff ff       	call   f01000b7 <_panic>
		panic("'pages' is a null pointer!");
f0102105:	83 ec 04             	sub    $0x4,%esp
f0102108:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010210b:	8d 83 4a 8d f7 ff    	lea    -0x872b6(%ebx),%eax
f0102111:	50                   	push   %eax
f0102112:	68 a2 02 00 00       	push   $0x2a2
f0102117:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010211d:	50                   	push   %eax
f010211e:	e8 94 df ff ff       	call   f01000b7 <_panic>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102123:	be 00 00 00 00       	mov    $0x0,%esi
f0102128:	e9 f5 f3 ff ff       	jmp    f0101522 <mem_init+0x171>
	assert((pp0 = page_alloc(0)));
f010212d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102130:	8d 83 65 8d f7 ff    	lea    -0x8729b(%ebx),%eax
f0102136:	50                   	push   %eax
f0102137:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010213d:	50                   	push   %eax
f010213e:	68 aa 02 00 00       	push   $0x2aa
f0102143:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102149:	50                   	push   %eax
f010214a:	e8 68 df ff ff       	call   f01000b7 <_panic>
	assert((pp1 = page_alloc(0)));
f010214f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102152:	8d 83 7b 8d f7 ff    	lea    -0x87285(%ebx),%eax
f0102158:	50                   	push   %eax
f0102159:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010215f:	50                   	push   %eax
f0102160:	68 ab 02 00 00       	push   $0x2ab
f0102165:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010216b:	50                   	push   %eax
f010216c:	e8 46 df ff ff       	call   f01000b7 <_panic>
	assert((pp2 = page_alloc(0)));
f0102171:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102174:	8d 83 91 8d f7 ff    	lea    -0x8726f(%ebx),%eax
f010217a:	50                   	push   %eax
f010217b:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102181:	50                   	push   %eax
f0102182:	68 ac 02 00 00       	push   $0x2ac
f0102187:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010218d:	50                   	push   %eax
f010218e:	e8 24 df ff ff       	call   f01000b7 <_panic>
	assert(pp1 && pp1 != pp0);
f0102193:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102196:	8d 83 a7 8d f7 ff    	lea    -0x87259(%ebx),%eax
f010219c:	50                   	push   %eax
f010219d:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01021a3:	50                   	push   %eax
f01021a4:	68 af 02 00 00       	push   $0x2af
f01021a9:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01021af:	50                   	push   %eax
f01021b0:	e8 02 df ff ff       	call   f01000b7 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01021b5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021b8:	8d 83 c0 90 f7 ff    	lea    -0x86f40(%ebx),%eax
f01021be:	50                   	push   %eax
f01021bf:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01021c5:	50                   	push   %eax
f01021c6:	68 b0 02 00 00       	push   $0x2b0
f01021cb:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01021d1:	50                   	push   %eax
f01021d2:	e8 e0 de ff ff       	call   f01000b7 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01021d7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021da:	8d 83 b9 8d f7 ff    	lea    -0x87247(%ebx),%eax
f01021e0:	50                   	push   %eax
f01021e1:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01021e7:	50                   	push   %eax
f01021e8:	68 b1 02 00 00       	push   $0x2b1
f01021ed:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01021f3:	50                   	push   %eax
f01021f4:	e8 be de ff ff       	call   f01000b7 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01021f9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021fc:	8d 83 d6 8d f7 ff    	lea    -0x8722a(%ebx),%eax
f0102202:	50                   	push   %eax
f0102203:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102209:	50                   	push   %eax
f010220a:	68 b2 02 00 00       	push   $0x2b2
f010220f:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102215:	50                   	push   %eax
f0102216:	e8 9c de ff ff       	call   f01000b7 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010221b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010221e:	8d 83 f3 8d f7 ff    	lea    -0x8720d(%ebx),%eax
f0102224:	50                   	push   %eax
f0102225:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010222b:	50                   	push   %eax
f010222c:	68 b3 02 00 00       	push   $0x2b3
f0102231:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102237:	50                   	push   %eax
f0102238:	e8 7a de ff ff       	call   f01000b7 <_panic>
	assert(!page_alloc(0));
f010223d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102240:	8d 83 10 8e f7 ff    	lea    -0x871f0(%ebx),%eax
f0102246:	50                   	push   %eax
f0102247:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010224d:	50                   	push   %eax
f010224e:	68 ba 02 00 00       	push   $0x2ba
f0102253:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102259:	50                   	push   %eax
f010225a:	e8 58 de ff ff       	call   f01000b7 <_panic>
	assert((pp0 = page_alloc(0)));
f010225f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102262:	8d 83 65 8d f7 ff    	lea    -0x8729b(%ebx),%eax
f0102268:	50                   	push   %eax
f0102269:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010226f:	50                   	push   %eax
f0102270:	68 c1 02 00 00       	push   $0x2c1
f0102275:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010227b:	50                   	push   %eax
f010227c:	e8 36 de ff ff       	call   f01000b7 <_panic>
	assert((pp1 = page_alloc(0)));
f0102281:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102284:	8d 83 7b 8d f7 ff    	lea    -0x87285(%ebx),%eax
f010228a:	50                   	push   %eax
f010228b:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102291:	50                   	push   %eax
f0102292:	68 c2 02 00 00       	push   $0x2c2
f0102297:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010229d:	50                   	push   %eax
f010229e:	e8 14 de ff ff       	call   f01000b7 <_panic>
	assert((pp2 = page_alloc(0)));
f01022a3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022a6:	8d 83 91 8d f7 ff    	lea    -0x8726f(%ebx),%eax
f01022ac:	50                   	push   %eax
f01022ad:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01022b3:	50                   	push   %eax
f01022b4:	68 c3 02 00 00       	push   $0x2c3
f01022b9:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01022bf:	50                   	push   %eax
f01022c0:	e8 f2 dd ff ff       	call   f01000b7 <_panic>
	assert(pp1 && pp1 != pp0);
f01022c5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022c8:	8d 83 a7 8d f7 ff    	lea    -0x87259(%ebx),%eax
f01022ce:	50                   	push   %eax
f01022cf:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01022d5:	50                   	push   %eax
f01022d6:	68 c5 02 00 00       	push   $0x2c5
f01022db:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01022e1:	50                   	push   %eax
f01022e2:	e8 d0 dd ff ff       	call   f01000b7 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01022e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022ea:	8d 83 c0 90 f7 ff    	lea    -0x86f40(%ebx),%eax
f01022f0:	50                   	push   %eax
f01022f1:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01022f7:	50                   	push   %eax
f01022f8:	68 c6 02 00 00       	push   $0x2c6
f01022fd:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102303:	50                   	push   %eax
f0102304:	e8 ae dd ff ff       	call   f01000b7 <_panic>
	assert(!page_alloc(0));
f0102309:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010230c:	8d 83 10 8e f7 ff    	lea    -0x871f0(%ebx),%eax
f0102312:	50                   	push   %eax
f0102313:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102319:	50                   	push   %eax
f010231a:	68 c7 02 00 00       	push   $0x2c7
f010231f:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102325:	50                   	push   %eax
f0102326:	e8 8c dd ff ff       	call   f01000b7 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010232b:	50                   	push   %eax
f010232c:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f0102332:	50                   	push   %eax
f0102333:	6a 56                	push   $0x56
f0102335:	8d 83 a0 8c f7 ff    	lea    -0x87360(%ebx),%eax
f010233b:	50                   	push   %eax
f010233c:	e8 76 dd ff ff       	call   f01000b7 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102341:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102344:	8d 83 1f 8e f7 ff    	lea    -0x871e1(%ebx),%eax
f010234a:	50                   	push   %eax
f010234b:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102351:	50                   	push   %eax
f0102352:	68 cc 02 00 00       	push   $0x2cc
f0102357:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010235d:	50                   	push   %eax
f010235e:	e8 54 dd ff ff       	call   f01000b7 <_panic>
	assert(pp && pp0 == pp);
f0102363:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102366:	8d 83 3d 8e f7 ff    	lea    -0x871c3(%ebx),%eax
f010236c:	50                   	push   %eax
f010236d:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102373:	50                   	push   %eax
f0102374:	68 cd 02 00 00       	push   $0x2cd
f0102379:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010237f:	50                   	push   %eax
f0102380:	e8 32 dd ff ff       	call   f01000b7 <_panic>
f0102385:	52                   	push   %edx
f0102386:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f010238c:	50                   	push   %eax
f010238d:	6a 56                	push   $0x56
f010238f:	8d 83 a0 8c f7 ff    	lea    -0x87360(%ebx),%eax
f0102395:	50                   	push   %eax
f0102396:	e8 1c dd ff ff       	call   f01000b7 <_panic>
		assert(c[i] == 0);
f010239b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010239e:	8d 83 4d 8e f7 ff    	lea    -0x871b3(%ebx),%eax
f01023a4:	50                   	push   %eax
f01023a5:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01023ab:	50                   	push   %eax
f01023ac:	68 d0 02 00 00       	push   $0x2d0
f01023b1:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01023b7:	50                   	push   %eax
f01023b8:	e8 fa dc ff ff       	call   f01000b7 <_panic>
	assert(nfree == 0);
f01023bd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023c0:	8d 83 57 8e f7 ff    	lea    -0x871a9(%ebx),%eax
f01023c6:	50                   	push   %eax
f01023c7:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01023cd:	50                   	push   %eax
f01023ce:	68 dd 02 00 00       	push   $0x2dd
f01023d3:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01023d9:	50                   	push   %eax
f01023da:	e8 d8 dc ff ff       	call   f01000b7 <_panic>
	assert((pp0 = page_alloc(0)));
f01023df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023e2:	8d 83 65 8d f7 ff    	lea    -0x8729b(%ebx),%eax
f01023e8:	50                   	push   %eax
f01023e9:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01023ef:	50                   	push   %eax
f01023f0:	68 3b 03 00 00       	push   $0x33b
f01023f5:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01023fb:	50                   	push   %eax
f01023fc:	e8 b6 dc ff ff       	call   f01000b7 <_panic>
	assert((pp1 = page_alloc(0)));
f0102401:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102404:	8d 83 7b 8d f7 ff    	lea    -0x87285(%ebx),%eax
f010240a:	50                   	push   %eax
f010240b:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102411:	50                   	push   %eax
f0102412:	68 3c 03 00 00       	push   $0x33c
f0102417:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010241d:	50                   	push   %eax
f010241e:	e8 94 dc ff ff       	call   f01000b7 <_panic>
	assert((pp2 = page_alloc(0)));
f0102423:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102426:	8d 83 91 8d f7 ff    	lea    -0x8726f(%ebx),%eax
f010242c:	50                   	push   %eax
f010242d:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102433:	50                   	push   %eax
f0102434:	68 3d 03 00 00       	push   $0x33d
f0102439:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010243f:	50                   	push   %eax
f0102440:	e8 72 dc ff ff       	call   f01000b7 <_panic>
	assert(pp1 && pp1 != pp0);
f0102445:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102448:	8d 83 a7 8d f7 ff    	lea    -0x87259(%ebx),%eax
f010244e:	50                   	push   %eax
f010244f:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102455:	50                   	push   %eax
f0102456:	68 40 03 00 00       	push   $0x340
f010245b:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102461:	50                   	push   %eax
f0102462:	e8 50 dc ff ff       	call   f01000b7 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102467:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010246a:	8d 83 c0 90 f7 ff    	lea    -0x86f40(%ebx),%eax
f0102470:	50                   	push   %eax
f0102471:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102477:	50                   	push   %eax
f0102478:	68 41 03 00 00       	push   $0x341
f010247d:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102483:	50                   	push   %eax
f0102484:	e8 2e dc ff ff       	call   f01000b7 <_panic>
	assert(!page_alloc(0));
f0102489:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010248c:	8d 83 10 8e f7 ff    	lea    -0x871f0(%ebx),%eax
f0102492:	50                   	push   %eax
f0102493:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102499:	50                   	push   %eax
f010249a:	68 48 03 00 00       	push   $0x348
f010249f:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01024a5:	50                   	push   %eax
f01024a6:	e8 0c dc ff ff       	call   f01000b7 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01024ab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024ae:	8d 83 00 91 f7 ff    	lea    -0x86f00(%ebx),%eax
f01024b4:	50                   	push   %eax
f01024b5:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01024bb:	50                   	push   %eax
f01024bc:	68 4b 03 00 00       	push   $0x34b
f01024c1:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01024c7:	50                   	push   %eax
f01024c8:	e8 ea db ff ff       	call   f01000b7 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01024cd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024d0:	8d 83 38 91 f7 ff    	lea    -0x86ec8(%ebx),%eax
f01024d6:	50                   	push   %eax
f01024d7:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01024dd:	50                   	push   %eax
f01024de:	68 4e 03 00 00       	push   $0x34e
f01024e3:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01024e9:	50                   	push   %eax
f01024ea:	e8 c8 db ff ff       	call   f01000b7 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01024ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024f2:	8d 83 68 91 f7 ff    	lea    -0x86e98(%ebx),%eax
f01024f8:	50                   	push   %eax
f01024f9:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01024ff:	50                   	push   %eax
f0102500:	68 52 03 00 00       	push   $0x352
f0102505:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010250b:	50                   	push   %eax
f010250c:	e8 a6 db ff ff       	call   f01000b7 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102511:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102514:	8d 83 98 91 f7 ff    	lea    -0x86e68(%ebx),%eax
f010251a:	50                   	push   %eax
f010251b:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102521:	50                   	push   %eax
f0102522:	68 53 03 00 00       	push   $0x353
f0102527:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010252d:	50                   	push   %eax
f010252e:	e8 84 db ff ff       	call   f01000b7 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102533:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102536:	8d 83 c0 91 f7 ff    	lea    -0x86e40(%ebx),%eax
f010253c:	50                   	push   %eax
f010253d:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102543:	50                   	push   %eax
f0102544:	68 54 03 00 00       	push   $0x354
f0102549:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010254f:	50                   	push   %eax
f0102550:	e8 62 db ff ff       	call   f01000b7 <_panic>
	assert(pp1->pp_ref == 1);
f0102555:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102558:	8d 83 62 8e f7 ff    	lea    -0x8719e(%ebx),%eax
f010255e:	50                   	push   %eax
f010255f:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102565:	50                   	push   %eax
f0102566:	68 55 03 00 00       	push   $0x355
f010256b:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102571:	50                   	push   %eax
f0102572:	e8 40 db ff ff       	call   f01000b7 <_panic>
	assert(pp0->pp_ref == 1);
f0102577:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010257a:	8d 83 73 8e f7 ff    	lea    -0x8718d(%ebx),%eax
f0102580:	50                   	push   %eax
f0102581:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102587:	50                   	push   %eax
f0102588:	68 56 03 00 00       	push   $0x356
f010258d:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102593:	50                   	push   %eax
f0102594:	e8 1e db ff ff       	call   f01000b7 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102599:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010259c:	8d 83 f0 91 f7 ff    	lea    -0x86e10(%ebx),%eax
f01025a2:	50                   	push   %eax
f01025a3:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01025a9:	50                   	push   %eax
f01025aa:	68 59 03 00 00       	push   $0x359
f01025af:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01025b5:	50                   	push   %eax
f01025b6:	e8 fc da ff ff       	call   f01000b7 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01025bb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025be:	8d 83 2c 92 f7 ff    	lea    -0x86dd4(%ebx),%eax
f01025c4:	50                   	push   %eax
f01025c5:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01025cb:	50                   	push   %eax
f01025cc:	68 5a 03 00 00       	push   $0x35a
f01025d1:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01025d7:	50                   	push   %eax
f01025d8:	e8 da da ff ff       	call   f01000b7 <_panic>
	assert(pp2->pp_ref == 1);
f01025dd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025e0:	8d 83 84 8e f7 ff    	lea    -0x8717c(%ebx),%eax
f01025e6:	50                   	push   %eax
f01025e7:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01025ed:	50                   	push   %eax
f01025ee:	68 5b 03 00 00       	push   $0x35b
f01025f3:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01025f9:	50                   	push   %eax
f01025fa:	e8 b8 da ff ff       	call   f01000b7 <_panic>
	assert(!page_alloc(0));
f01025ff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102602:	8d 83 10 8e f7 ff    	lea    -0x871f0(%ebx),%eax
f0102608:	50                   	push   %eax
f0102609:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010260f:	50                   	push   %eax
f0102610:	68 5e 03 00 00       	push   $0x35e
f0102615:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010261b:	50                   	push   %eax
f010261c:	e8 96 da ff ff       	call   f01000b7 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102621:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102624:	8d 83 f0 91 f7 ff    	lea    -0x86e10(%ebx),%eax
f010262a:	50                   	push   %eax
f010262b:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102631:	50                   	push   %eax
f0102632:	68 61 03 00 00       	push   $0x361
f0102637:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010263d:	50                   	push   %eax
f010263e:	e8 74 da ff ff       	call   f01000b7 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102643:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102646:	8d 83 2c 92 f7 ff    	lea    -0x86dd4(%ebx),%eax
f010264c:	50                   	push   %eax
f010264d:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102653:	50                   	push   %eax
f0102654:	68 62 03 00 00       	push   $0x362
f0102659:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010265f:	50                   	push   %eax
f0102660:	e8 52 da ff ff       	call   f01000b7 <_panic>
	assert(pp2->pp_ref == 1);
f0102665:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102668:	8d 83 84 8e f7 ff    	lea    -0x8717c(%ebx),%eax
f010266e:	50                   	push   %eax
f010266f:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102675:	50                   	push   %eax
f0102676:	68 63 03 00 00       	push   $0x363
f010267b:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102681:	50                   	push   %eax
f0102682:	e8 30 da ff ff       	call   f01000b7 <_panic>
	assert(!page_alloc(0));
f0102687:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010268a:	8d 83 10 8e f7 ff    	lea    -0x871f0(%ebx),%eax
f0102690:	50                   	push   %eax
f0102691:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102697:	50                   	push   %eax
f0102698:	68 67 03 00 00       	push   $0x367
f010269d:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01026a3:	50                   	push   %eax
f01026a4:	e8 0e da ff ff       	call   f01000b7 <_panic>
f01026a9:	50                   	push   %eax
f01026aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026ad:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f01026b3:	50                   	push   %eax
f01026b4:	68 6a 03 00 00       	push   $0x36a
f01026b9:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01026bf:	50                   	push   %eax
f01026c0:	e8 f2 d9 ff ff       	call   f01000b7 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01026c5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026c8:	8d 83 5c 92 f7 ff    	lea    -0x86da4(%ebx),%eax
f01026ce:	50                   	push   %eax
f01026cf:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01026d5:	50                   	push   %eax
f01026d6:	68 6b 03 00 00       	push   $0x36b
f01026db:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01026e1:	50                   	push   %eax
f01026e2:	e8 d0 d9 ff ff       	call   f01000b7 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01026e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026ea:	8d 83 9c 92 f7 ff    	lea    -0x86d64(%ebx),%eax
f01026f0:	50                   	push   %eax
f01026f1:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01026f7:	50                   	push   %eax
f01026f8:	68 6e 03 00 00       	push   $0x36e
f01026fd:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102703:	50                   	push   %eax
f0102704:	e8 ae d9 ff ff       	call   f01000b7 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102709:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010270c:	8d 83 2c 92 f7 ff    	lea    -0x86dd4(%ebx),%eax
f0102712:	50                   	push   %eax
f0102713:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102719:	50                   	push   %eax
f010271a:	68 6f 03 00 00       	push   $0x36f
f010271f:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102725:	50                   	push   %eax
f0102726:	e8 8c d9 ff ff       	call   f01000b7 <_panic>
	assert(pp2->pp_ref == 1);
f010272b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010272e:	8d 83 84 8e f7 ff    	lea    -0x8717c(%ebx),%eax
f0102734:	50                   	push   %eax
f0102735:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010273b:	50                   	push   %eax
f010273c:	68 70 03 00 00       	push   $0x370
f0102741:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102747:	50                   	push   %eax
f0102748:	e8 6a d9 ff ff       	call   f01000b7 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010274d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102750:	8d 83 dc 92 f7 ff    	lea    -0x86d24(%ebx),%eax
f0102756:	50                   	push   %eax
f0102757:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010275d:	50                   	push   %eax
f010275e:	68 71 03 00 00       	push   $0x371
f0102763:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102769:	50                   	push   %eax
f010276a:	e8 48 d9 ff ff       	call   f01000b7 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010276f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102772:	8d 83 95 8e f7 ff    	lea    -0x8716b(%ebx),%eax
f0102778:	50                   	push   %eax
f0102779:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010277f:	50                   	push   %eax
f0102780:	68 72 03 00 00       	push   $0x372
f0102785:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010278b:	50                   	push   %eax
f010278c:	e8 26 d9 ff ff       	call   f01000b7 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102791:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102794:	8d 83 f0 91 f7 ff    	lea    -0x86e10(%ebx),%eax
f010279a:	50                   	push   %eax
f010279b:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01027a1:	50                   	push   %eax
f01027a2:	68 75 03 00 00       	push   $0x375
f01027a7:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01027ad:	50                   	push   %eax
f01027ae:	e8 04 d9 ff ff       	call   f01000b7 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01027b3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027b6:	8d 83 10 93 f7 ff    	lea    -0x86cf0(%ebx),%eax
f01027bc:	50                   	push   %eax
f01027bd:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01027c3:	50                   	push   %eax
f01027c4:	68 76 03 00 00       	push   $0x376
f01027c9:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01027cf:	50                   	push   %eax
f01027d0:	e8 e2 d8 ff ff       	call   f01000b7 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01027d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027d8:	8d 83 44 93 f7 ff    	lea    -0x86cbc(%ebx),%eax
f01027de:	50                   	push   %eax
f01027df:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01027e5:	50                   	push   %eax
f01027e6:	68 77 03 00 00       	push   $0x377
f01027eb:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01027f1:	50                   	push   %eax
f01027f2:	e8 c0 d8 ff ff       	call   f01000b7 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01027f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027fa:	8d 83 7c 93 f7 ff    	lea    -0x86c84(%ebx),%eax
f0102800:	50                   	push   %eax
f0102801:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102807:	50                   	push   %eax
f0102808:	68 7a 03 00 00       	push   $0x37a
f010280d:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102813:	50                   	push   %eax
f0102814:	e8 9e d8 ff ff       	call   f01000b7 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102819:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010281c:	8d 83 b4 93 f7 ff    	lea    -0x86c4c(%ebx),%eax
f0102822:	50                   	push   %eax
f0102823:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102829:	50                   	push   %eax
f010282a:	68 7d 03 00 00       	push   $0x37d
f010282f:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102835:	50                   	push   %eax
f0102836:	e8 7c d8 ff ff       	call   f01000b7 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010283b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010283e:	8d 83 44 93 f7 ff    	lea    -0x86cbc(%ebx),%eax
f0102844:	50                   	push   %eax
f0102845:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010284b:	50                   	push   %eax
f010284c:	68 7e 03 00 00       	push   $0x37e
f0102851:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102857:	50                   	push   %eax
f0102858:	e8 5a d8 ff ff       	call   f01000b7 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010285d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102860:	8d 83 f0 93 f7 ff    	lea    -0x86c10(%ebx),%eax
f0102866:	50                   	push   %eax
f0102867:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010286d:	50                   	push   %eax
f010286e:	68 81 03 00 00       	push   $0x381
f0102873:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102879:	50                   	push   %eax
f010287a:	e8 38 d8 ff ff       	call   f01000b7 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010287f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102882:	8d 83 1c 94 f7 ff    	lea    -0x86be4(%ebx),%eax
f0102888:	50                   	push   %eax
f0102889:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010288f:	50                   	push   %eax
f0102890:	68 82 03 00 00       	push   $0x382
f0102895:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f010289b:	50                   	push   %eax
f010289c:	e8 16 d8 ff ff       	call   f01000b7 <_panic>
	assert(pp1->pp_ref == 2);
f01028a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028a4:	8d 83 ab 8e f7 ff    	lea    -0x87155(%ebx),%eax
f01028aa:	50                   	push   %eax
f01028ab:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01028b1:	50                   	push   %eax
f01028b2:	68 84 03 00 00       	push   $0x384
f01028b7:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01028bd:	50                   	push   %eax
f01028be:	e8 f4 d7 ff ff       	call   f01000b7 <_panic>
	assert(pp2->pp_ref == 0);
f01028c3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028c6:	8d 83 bc 8e f7 ff    	lea    -0x87144(%ebx),%eax
f01028cc:	50                   	push   %eax
f01028cd:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01028d3:	50                   	push   %eax
f01028d4:	68 85 03 00 00       	push   $0x385
f01028d9:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01028df:	50                   	push   %eax
f01028e0:	e8 d2 d7 ff ff       	call   f01000b7 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01028e5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028e8:	8d 83 4c 94 f7 ff    	lea    -0x86bb4(%ebx),%eax
f01028ee:	50                   	push   %eax
f01028ef:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01028f5:	50                   	push   %eax
f01028f6:	68 88 03 00 00       	push   $0x388
f01028fb:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102901:	50                   	push   %eax
f0102902:	e8 b0 d7 ff ff       	call   f01000b7 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102907:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010290a:	8d 83 70 94 f7 ff    	lea    -0x86b90(%ebx),%eax
f0102910:	50                   	push   %eax
f0102911:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102917:	50                   	push   %eax
f0102918:	68 8c 03 00 00       	push   $0x38c
f010291d:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102923:	50                   	push   %eax
f0102924:	e8 8e d7 ff ff       	call   f01000b7 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102929:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010292c:	8d 83 1c 94 f7 ff    	lea    -0x86be4(%ebx),%eax
f0102932:	50                   	push   %eax
f0102933:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102939:	50                   	push   %eax
f010293a:	68 8d 03 00 00       	push   $0x38d
f010293f:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102945:	50                   	push   %eax
f0102946:	e8 6c d7 ff ff       	call   f01000b7 <_panic>
	assert(pp1->pp_ref == 1);
f010294b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010294e:	8d 83 62 8e f7 ff    	lea    -0x8719e(%ebx),%eax
f0102954:	50                   	push   %eax
f0102955:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010295b:	50                   	push   %eax
f010295c:	68 8e 03 00 00       	push   $0x38e
f0102961:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102967:	50                   	push   %eax
f0102968:	e8 4a d7 ff ff       	call   f01000b7 <_panic>
	assert(pp2->pp_ref == 0);
f010296d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102970:	8d 83 bc 8e f7 ff    	lea    -0x87144(%ebx),%eax
f0102976:	50                   	push   %eax
f0102977:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010297d:	50                   	push   %eax
f010297e:	68 8f 03 00 00       	push   $0x38f
f0102983:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102989:	50                   	push   %eax
f010298a:	e8 28 d7 ff ff       	call   f01000b7 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010298f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102992:	8d 83 70 94 f7 ff    	lea    -0x86b90(%ebx),%eax
f0102998:	50                   	push   %eax
f0102999:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010299f:	50                   	push   %eax
f01029a0:	68 93 03 00 00       	push   $0x393
f01029a5:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01029ab:	50                   	push   %eax
f01029ac:	e8 06 d7 ff ff       	call   f01000b7 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01029b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029b4:	8d 83 94 94 f7 ff    	lea    -0x86b6c(%ebx),%eax
f01029ba:	50                   	push   %eax
f01029bb:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01029c1:	50                   	push   %eax
f01029c2:	68 94 03 00 00       	push   $0x394
f01029c7:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01029cd:	50                   	push   %eax
f01029ce:	e8 e4 d6 ff ff       	call   f01000b7 <_panic>
	assert(pp1->pp_ref == 0);
f01029d3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029d6:	8d 83 cd 8e f7 ff    	lea    -0x87133(%ebx),%eax
f01029dc:	50                   	push   %eax
f01029dd:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01029e3:	50                   	push   %eax
f01029e4:	68 95 03 00 00       	push   $0x395
f01029e9:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01029ef:	50                   	push   %eax
f01029f0:	e8 c2 d6 ff ff       	call   f01000b7 <_panic>
	assert(pp2->pp_ref == 0);
f01029f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029f8:	8d 83 bc 8e f7 ff    	lea    -0x87144(%ebx),%eax
f01029fe:	50                   	push   %eax
f01029ff:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102a05:	50                   	push   %eax
f0102a06:	68 96 03 00 00       	push   $0x396
f0102a0b:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102a11:	50                   	push   %eax
f0102a12:	e8 a0 d6 ff ff       	call   f01000b7 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102a17:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a1a:	8d 83 bc 94 f7 ff    	lea    -0x86b44(%ebx),%eax
f0102a20:	50                   	push   %eax
f0102a21:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102a27:	50                   	push   %eax
f0102a28:	68 99 03 00 00       	push   $0x399
f0102a2d:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102a33:	50                   	push   %eax
f0102a34:	e8 7e d6 ff ff       	call   f01000b7 <_panic>
	assert(!page_alloc(0));
f0102a39:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a3c:	8d 83 10 8e f7 ff    	lea    -0x871f0(%ebx),%eax
f0102a42:	50                   	push   %eax
f0102a43:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102a49:	50                   	push   %eax
f0102a4a:	68 9c 03 00 00       	push   $0x39c
f0102a4f:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102a55:	50                   	push   %eax
f0102a56:	e8 5c d6 ff ff       	call   f01000b7 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102a5b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a5e:	8d 83 98 91 f7 ff    	lea    -0x86e68(%ebx),%eax
f0102a64:	50                   	push   %eax
f0102a65:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102a6b:	50                   	push   %eax
f0102a6c:	68 9f 03 00 00       	push   $0x39f
f0102a71:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102a77:	50                   	push   %eax
f0102a78:	e8 3a d6 ff ff       	call   f01000b7 <_panic>
	assert(pp0->pp_ref == 1);
f0102a7d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a80:	8d 83 73 8e f7 ff    	lea    -0x8718d(%ebx),%eax
f0102a86:	50                   	push   %eax
f0102a87:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102a8d:	50                   	push   %eax
f0102a8e:	68 a1 03 00 00       	push   $0x3a1
f0102a93:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102a99:	50                   	push   %eax
f0102a9a:	e8 18 d6 ff ff       	call   f01000b7 <_panic>
f0102a9f:	52                   	push   %edx
f0102aa0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102aa3:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f0102aa9:	50                   	push   %eax
f0102aaa:	68 a8 03 00 00       	push   $0x3a8
f0102aaf:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102ab5:	50                   	push   %eax
f0102ab6:	e8 fc d5 ff ff       	call   f01000b7 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102abb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102abe:	8d 83 de 8e f7 ff    	lea    -0x87122(%ebx),%eax
f0102ac4:	50                   	push   %eax
f0102ac5:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102acb:	50                   	push   %eax
f0102acc:	68 a9 03 00 00       	push   $0x3a9
f0102ad1:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102ad7:	50                   	push   %eax
f0102ad8:	e8 da d5 ff ff       	call   f01000b7 <_panic>
f0102add:	50                   	push   %eax
f0102ade:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ae1:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f0102ae7:	50                   	push   %eax
f0102ae8:	6a 56                	push   $0x56
f0102aea:	8d 83 a0 8c f7 ff    	lea    -0x87360(%ebx),%eax
f0102af0:	50                   	push   %eax
f0102af1:	e8 c1 d5 ff ff       	call   f01000b7 <_panic>
f0102af6:	52                   	push   %edx
f0102af7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102afa:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f0102b00:	50                   	push   %eax
f0102b01:	6a 56                	push   $0x56
f0102b03:	8d 83 a0 8c f7 ff    	lea    -0x87360(%ebx),%eax
f0102b09:	50                   	push   %eax
f0102b0a:	e8 a8 d5 ff ff       	call   f01000b7 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102b0f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b12:	8d 83 f6 8e f7 ff    	lea    -0x8710a(%ebx),%eax
f0102b18:	50                   	push   %eax
f0102b19:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102b1f:	50                   	push   %eax
f0102b20:	68 b3 03 00 00       	push   $0x3b3
f0102b25:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102b2b:	50                   	push   %eax
f0102b2c:	e8 86 d5 ff ff       	call   f01000b7 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b31:	50                   	push   %eax
f0102b32:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b35:	8d 83 40 90 f7 ff    	lea    -0x86fc0(%ebx),%eax
f0102b3b:	50                   	push   %eax
f0102b3c:	68 b4 00 00 00       	push   $0xb4
f0102b41:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102b47:	50                   	push   %eax
f0102b48:	e8 6a d5 ff ff       	call   f01000b7 <_panic>
f0102b4d:	50                   	push   %eax
f0102b4e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b51:	8d 83 40 90 f7 ff    	lea    -0x86fc0(%ebx),%eax
f0102b57:	50                   	push   %eax
f0102b58:	68 bd 00 00 00       	push   $0xbd
f0102b5d:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102b63:	50                   	push   %eax
f0102b64:	e8 4e d5 ff ff       	call   f01000b7 <_panic>
f0102b69:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b6c:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0102b72:	8d 83 40 90 f7 ff    	lea    -0x86fc0(%ebx),%eax
f0102b78:	50                   	push   %eax
f0102b79:	68 ca 00 00 00       	push   $0xca
f0102b7e:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102b84:	50                   	push   %eax
f0102b85:	e8 2d d5 ff ff       	call   f01000b7 <_panic>
f0102b8a:	ff 75 c0             	pushl  -0x40(%ebp)
f0102b8d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b90:	8d 83 40 90 f7 ff    	lea    -0x86fc0(%ebx),%eax
f0102b96:	50                   	push   %eax
f0102b97:	68 f5 02 00 00       	push   $0x2f5
f0102b9c:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102ba2:	50                   	push   %eax
f0102ba3:	e8 0f d5 ff ff       	call   f01000b7 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102ba8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bab:	8d 83 e0 94 f7 ff    	lea    -0x86b20(%ebx),%eax
f0102bb1:	50                   	push   %eax
f0102bb2:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102bb8:	50                   	push   %eax
f0102bb9:	68 f5 02 00 00       	push   $0x2f5
f0102bbe:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102bc4:	50                   	push   %eax
f0102bc5:	e8 ed d4 ff ff       	call   f01000b7 <_panic>
f0102bca:	ff 75 cc             	pushl  -0x34(%ebp)
f0102bcd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bd0:	8d 83 40 90 f7 ff    	lea    -0x86fc0(%ebx),%eax
f0102bd6:	50                   	push   %eax
f0102bd7:	68 fa 02 00 00       	push   $0x2fa
f0102bdc:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102be2:	50                   	push   %eax
f0102be3:	e8 cf d4 ff ff       	call   f01000b7 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102be8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102beb:	8d 83 14 95 f7 ff    	lea    -0x86aec(%ebx),%eax
f0102bf1:	50                   	push   %eax
f0102bf2:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102bf8:	50                   	push   %eax
f0102bf9:	68 fa 02 00 00       	push   $0x2fa
f0102bfe:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102c04:	50                   	push   %eax
f0102c05:	e8 ad d4 ff ff       	call   f01000b7 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102c0a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c0d:	8d 83 48 95 f7 ff    	lea    -0x86ab8(%ebx),%eax
f0102c13:	50                   	push   %eax
f0102c14:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102c1a:	50                   	push   %eax
f0102c1b:	68 fe 02 00 00       	push   $0x2fe
f0102c20:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102c26:	50                   	push   %eax
f0102c27:	e8 8b d4 ff ff       	call   f01000b7 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102c2c:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f0102c31:	e9 56 f4 ff ff       	jmp    f010208c <mem_init+0xcdb>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102c36:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c39:	8d 83 70 95 f7 ff    	lea    -0x86a90(%ebx),%eax
f0102c3f:	50                   	push   %eax
f0102c40:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102c46:	50                   	push   %eax
f0102c47:	68 02 03 00 00       	push   $0x302
f0102c4c:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102c52:	50                   	push   %eax
f0102c53:	e8 5f d4 ff ff       	call   f01000b7 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102c58:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c5b:	8d 83 b8 95 f7 ff    	lea    -0x86a48(%ebx),%eax
f0102c61:	50                   	push   %eax
f0102c62:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102c68:	50                   	push   %eax
f0102c69:	68 03 03 00 00       	push   $0x303
f0102c6e:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102c74:	50                   	push   %eax
f0102c75:	e8 3d d4 ff ff       	call   f01000b7 <_panic>
			assert(pgdir[i] & PTE_P);
f0102c7a:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102c7e:	74 52                	je     f0102cd2 <mem_init+0x1921>
	for (i = 0; i < NPDENTRIES; i++) {
f0102c80:	83 c0 01             	add    $0x1,%eax
f0102c83:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102c88:	0f 84 bb 00 00 00    	je     f0102d49 <mem_init+0x1998>
		switch (i) {
f0102c8e:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102c93:	72 0e                	jb     f0102ca3 <mem_init+0x18f2>
f0102c95:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102c9a:	76 de                	jbe    f0102c7a <mem_init+0x18c9>
f0102c9c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102ca1:	74 d7                	je     f0102c7a <mem_init+0x18c9>
			if (i >= PDX(KERNBASE)) {
f0102ca3:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102ca8:	77 4a                	ja     f0102cf4 <mem_init+0x1943>
				assert(pgdir[i] == 0);
f0102caa:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102cae:	74 d0                	je     f0102c80 <mem_init+0x18cf>
f0102cb0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cb3:	8d 83 48 8f f7 ff    	lea    -0x870b8(%ebx),%eax
f0102cb9:	50                   	push   %eax
f0102cba:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102cc0:	50                   	push   %eax
f0102cc1:	68 13 03 00 00       	push   $0x313
f0102cc6:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102ccc:	50                   	push   %eax
f0102ccd:	e8 e5 d3 ff ff       	call   f01000b7 <_panic>
			assert(pgdir[i] & PTE_P);
f0102cd2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cd5:	8d 83 26 8f f7 ff    	lea    -0x870da(%ebx),%eax
f0102cdb:	50                   	push   %eax
f0102cdc:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102ce2:	50                   	push   %eax
f0102ce3:	68 0c 03 00 00       	push   $0x30c
f0102ce8:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102cee:	50                   	push   %eax
f0102cef:	e8 c3 d3 ff ff       	call   f01000b7 <_panic>
				assert(pgdir[i] & PTE_P);
f0102cf4:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102cf7:	f6 c2 01             	test   $0x1,%dl
f0102cfa:	74 2b                	je     f0102d27 <mem_init+0x1976>
				assert(pgdir[i] & PTE_W);
f0102cfc:	f6 c2 02             	test   $0x2,%dl
f0102cff:	0f 85 7b ff ff ff    	jne    f0102c80 <mem_init+0x18cf>
f0102d05:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d08:	8d 83 37 8f f7 ff    	lea    -0x870c9(%ebx),%eax
f0102d0e:	50                   	push   %eax
f0102d0f:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102d15:	50                   	push   %eax
f0102d16:	68 11 03 00 00       	push   $0x311
f0102d1b:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102d21:	50                   	push   %eax
f0102d22:	e8 90 d3 ff ff       	call   f01000b7 <_panic>
				assert(pgdir[i] & PTE_P);
f0102d27:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d2a:	8d 83 26 8f f7 ff    	lea    -0x870da(%ebx),%eax
f0102d30:	50                   	push   %eax
f0102d31:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102d37:	50                   	push   %eax
f0102d38:	68 10 03 00 00       	push   $0x310
f0102d3d:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102d43:	50                   	push   %eax
f0102d44:	e8 6e d3 ff ff       	call   f01000b7 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102d49:	83 ec 0c             	sub    $0xc,%esp
f0102d4c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102d4f:	8d 87 e8 95 f7 ff    	lea    -0x86a18(%edi),%eax
f0102d55:	50                   	push   %eax
f0102d56:	89 fb                	mov    %edi,%ebx
f0102d58:	e8 28 0e 00 00       	call   f0103b85 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102d5d:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102d63:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102d65:	83 c4 10             	add    $0x10,%esp
f0102d68:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d6d:	0f 86 44 02 00 00    	jbe    f0102fb7 <mem_init+0x1c06>
	return (physaddr_t)kva - KERNBASE;
f0102d73:	05 00 00 00 10       	add    $0x10000000,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102d78:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102d7b:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d80:	e8 26 de ff ff       	call   f0100bab <check_page_free_list>
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102d85:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102d88:	83 e0 f3             	and    $0xfffffff3,%eax
f0102d8b:	0d 23 00 05 80       	or     $0x80050023,%eax
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102d90:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102d93:	83 ec 0c             	sub    $0xc,%esp
f0102d96:	6a 00                	push   $0x0
f0102d98:	e8 e0 e2 ff ff       	call   f010107d <page_alloc>
f0102d9d:	89 c6                	mov    %eax,%esi
f0102d9f:	83 c4 10             	add    $0x10,%esp
f0102da2:	85 c0                	test   %eax,%eax
f0102da4:	0f 84 29 02 00 00    	je     f0102fd3 <mem_init+0x1c22>
	assert((pp1 = page_alloc(0)));
f0102daa:	83 ec 0c             	sub    $0xc,%esp
f0102dad:	6a 00                	push   $0x0
f0102daf:	e8 c9 e2 ff ff       	call   f010107d <page_alloc>
f0102db4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102db7:	83 c4 10             	add    $0x10,%esp
f0102dba:	85 c0                	test   %eax,%eax
f0102dbc:	0f 84 33 02 00 00    	je     f0102ff5 <mem_init+0x1c44>
	assert((pp2 = page_alloc(0)));
f0102dc2:	83 ec 0c             	sub    $0xc,%esp
f0102dc5:	6a 00                	push   $0x0
f0102dc7:	e8 b1 e2 ff ff       	call   f010107d <page_alloc>
f0102dcc:	89 c7                	mov    %eax,%edi
f0102dce:	83 c4 10             	add    $0x10,%esp
f0102dd1:	85 c0                	test   %eax,%eax
f0102dd3:	0f 84 3e 02 00 00    	je     f0103017 <mem_init+0x1c66>
	page_free(pp0);
f0102dd9:	83 ec 0c             	sub    $0xc,%esp
f0102ddc:	56                   	push   %esi
f0102ddd:	e8 23 e3 ff ff       	call   f0101105 <page_free>
	return (pp - pages) << PGSHIFT;
f0102de2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102de5:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0102deb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102dee:	2b 08                	sub    (%eax),%ecx
f0102df0:	89 c8                	mov    %ecx,%eax
f0102df2:	c1 f8 03             	sar    $0x3,%eax
f0102df5:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102df8:	89 c1                	mov    %eax,%ecx
f0102dfa:	c1 e9 0c             	shr    $0xc,%ecx
f0102dfd:	83 c4 10             	add    $0x10,%esp
f0102e00:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0102e06:	3b 0a                	cmp    (%edx),%ecx
f0102e08:	0f 83 2b 02 00 00    	jae    f0103039 <mem_init+0x1c88>
	memset(page2kva(pp1), 1, PGSIZE);
f0102e0e:	83 ec 04             	sub    $0x4,%esp
f0102e11:	68 00 10 00 00       	push   $0x1000
f0102e16:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102e18:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e1d:	50                   	push   %eax
f0102e1e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e21:	e8 32 25 00 00       	call   f0105358 <memset>
	return (pp - pages) << PGSHIFT;
f0102e26:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e29:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0102e2f:	89 f9                	mov    %edi,%ecx
f0102e31:	2b 08                	sub    (%eax),%ecx
f0102e33:	89 c8                	mov    %ecx,%eax
f0102e35:	c1 f8 03             	sar    $0x3,%eax
f0102e38:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102e3b:	89 c1                	mov    %eax,%ecx
f0102e3d:	c1 e9 0c             	shr    $0xc,%ecx
f0102e40:	83 c4 10             	add    $0x10,%esp
f0102e43:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0102e49:	3b 0a                	cmp    (%edx),%ecx
f0102e4b:	0f 83 fe 01 00 00    	jae    f010304f <mem_init+0x1c9e>
	memset(page2kva(pp2), 2, PGSIZE);
f0102e51:	83 ec 04             	sub    $0x4,%esp
f0102e54:	68 00 10 00 00       	push   $0x1000
f0102e59:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102e5b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e60:	50                   	push   %eax
f0102e61:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e64:	e8 ef 24 00 00       	call   f0105358 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102e69:	6a 02                	push   $0x2
f0102e6b:	68 00 10 00 00       	push   $0x1000
f0102e70:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102e73:	53                   	push   %ebx
f0102e74:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e77:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102e7d:	ff 30                	pushl  (%eax)
f0102e7f:	e8 a9 e4 ff ff       	call   f010132d <page_insert>
	assert(pp1->pp_ref == 1);
f0102e84:	83 c4 20             	add    $0x20,%esp
f0102e87:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102e8c:	0f 85 d3 01 00 00    	jne    f0103065 <mem_init+0x1cb4>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e92:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102e99:	01 01 01 
f0102e9c:	0f 85 e5 01 00 00    	jne    f0103087 <mem_init+0x1cd6>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ea2:	6a 02                	push   $0x2
f0102ea4:	68 00 10 00 00       	push   $0x1000
f0102ea9:	57                   	push   %edi
f0102eaa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ead:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102eb3:	ff 30                	pushl  (%eax)
f0102eb5:	e8 73 e4 ff ff       	call   f010132d <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102eba:	83 c4 10             	add    $0x10,%esp
f0102ebd:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102ec4:	02 02 02 
f0102ec7:	0f 85 dc 01 00 00    	jne    f01030a9 <mem_init+0x1cf8>
	assert(pp2->pp_ref == 1);
f0102ecd:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ed2:	0f 85 f3 01 00 00    	jne    f01030cb <mem_init+0x1d1a>
	assert(pp1->pp_ref == 0);
f0102ed8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102edb:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102ee0:	0f 85 07 02 00 00    	jne    f01030ed <mem_init+0x1d3c>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102ee6:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102eed:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102ef0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ef3:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0102ef9:	89 f9                	mov    %edi,%ecx
f0102efb:	2b 08                	sub    (%eax),%ecx
f0102efd:	89 c8                	mov    %ecx,%eax
f0102eff:	c1 f8 03             	sar    $0x3,%eax
f0102f02:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102f05:	89 c1                	mov    %eax,%ecx
f0102f07:	c1 e9 0c             	shr    $0xc,%ecx
f0102f0a:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0102f10:	3b 0a                	cmp    (%edx),%ecx
f0102f12:	0f 83 f7 01 00 00    	jae    f010310f <mem_init+0x1d5e>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f18:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102f1f:	03 03 03 
f0102f22:	0f 85 fd 01 00 00    	jne    f0103125 <mem_init+0x1d74>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102f28:	83 ec 08             	sub    $0x8,%esp
f0102f2b:	68 00 10 00 00       	push   $0x1000
f0102f30:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f33:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102f39:	ff 30                	pushl  (%eax)
f0102f3b:	e8 a9 e3 ff ff       	call   f01012e9 <page_remove>
	assert(pp2->pp_ref == 0);
f0102f40:	83 c4 10             	add    $0x10,%esp
f0102f43:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102f48:	0f 85 f9 01 00 00    	jne    f0103147 <mem_init+0x1d96>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f4e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102f51:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102f57:	8b 08                	mov    (%eax),%ecx
f0102f59:	8b 11                	mov    (%ecx),%edx
f0102f5b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102f61:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0102f67:	89 f7                	mov    %esi,%edi
f0102f69:	2b 38                	sub    (%eax),%edi
f0102f6b:	89 f8                	mov    %edi,%eax
f0102f6d:	c1 f8 03             	sar    $0x3,%eax
f0102f70:	c1 e0 0c             	shl    $0xc,%eax
f0102f73:	39 c2                	cmp    %eax,%edx
f0102f75:	0f 85 ee 01 00 00    	jne    f0103169 <mem_init+0x1db8>
	kern_pgdir[0] = 0;
f0102f7b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102f81:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102f86:	0f 85 ff 01 00 00    	jne    f010318b <mem_init+0x1dda>
	pp0->pp_ref = 0;
f0102f8c:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102f92:	83 ec 0c             	sub    $0xc,%esp
f0102f95:	56                   	push   %esi
f0102f96:	e8 6a e1 ff ff       	call   f0101105 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f9b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f9e:	8d 83 7c 96 f7 ff    	lea    -0x86984(%ebx),%eax
f0102fa4:	89 04 24             	mov    %eax,(%esp)
f0102fa7:	e8 d9 0b 00 00       	call   f0103b85 <cprintf>
}
f0102fac:	83 c4 10             	add    $0x10,%esp
f0102faf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fb2:	5b                   	pop    %ebx
f0102fb3:	5e                   	pop    %esi
f0102fb4:	5f                   	pop    %edi
f0102fb5:	5d                   	pop    %ebp
f0102fb6:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fb7:	50                   	push   %eax
f0102fb8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fbb:	8d 83 40 90 f7 ff    	lea    -0x86fc0(%ebx),%eax
f0102fc1:	50                   	push   %eax
f0102fc2:	68 e0 00 00 00       	push   $0xe0
f0102fc7:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102fcd:	50                   	push   %eax
f0102fce:	e8 e4 d0 ff ff       	call   f01000b7 <_panic>
	assert((pp0 = page_alloc(0)));
f0102fd3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fd6:	8d 83 65 8d f7 ff    	lea    -0x8729b(%ebx),%eax
f0102fdc:	50                   	push   %eax
f0102fdd:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0102fe3:	50                   	push   %eax
f0102fe4:	68 ce 03 00 00       	push   $0x3ce
f0102fe9:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102fef:	50                   	push   %eax
f0102ff0:	e8 c2 d0 ff ff       	call   f01000b7 <_panic>
	assert((pp1 = page_alloc(0)));
f0102ff5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ff8:	8d 83 7b 8d f7 ff    	lea    -0x87285(%ebx),%eax
f0102ffe:	50                   	push   %eax
f0102fff:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0103005:	50                   	push   %eax
f0103006:	68 cf 03 00 00       	push   $0x3cf
f010300b:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0103011:	50                   	push   %eax
f0103012:	e8 a0 d0 ff ff       	call   f01000b7 <_panic>
	assert((pp2 = page_alloc(0)));
f0103017:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010301a:	8d 83 91 8d f7 ff    	lea    -0x8726f(%ebx),%eax
f0103020:	50                   	push   %eax
f0103021:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0103027:	50                   	push   %eax
f0103028:	68 d0 03 00 00       	push   $0x3d0
f010302d:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0103033:	50                   	push   %eax
f0103034:	e8 7e d0 ff ff       	call   f01000b7 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103039:	50                   	push   %eax
f010303a:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f0103040:	50                   	push   %eax
f0103041:	6a 56                	push   $0x56
f0103043:	8d 83 a0 8c f7 ff    	lea    -0x87360(%ebx),%eax
f0103049:	50                   	push   %eax
f010304a:	e8 68 d0 ff ff       	call   f01000b7 <_panic>
f010304f:	50                   	push   %eax
f0103050:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f0103056:	50                   	push   %eax
f0103057:	6a 56                	push   $0x56
f0103059:	8d 83 a0 8c f7 ff    	lea    -0x87360(%ebx),%eax
f010305f:	50                   	push   %eax
f0103060:	e8 52 d0 ff ff       	call   f01000b7 <_panic>
	assert(pp1->pp_ref == 1);
f0103065:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103068:	8d 83 62 8e f7 ff    	lea    -0x8719e(%ebx),%eax
f010306e:	50                   	push   %eax
f010306f:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0103075:	50                   	push   %eax
f0103076:	68 d5 03 00 00       	push   $0x3d5
f010307b:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0103081:	50                   	push   %eax
f0103082:	e8 30 d0 ff ff       	call   f01000b7 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103087:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010308a:	8d 83 08 96 f7 ff    	lea    -0x869f8(%ebx),%eax
f0103090:	50                   	push   %eax
f0103091:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0103097:	50                   	push   %eax
f0103098:	68 d6 03 00 00       	push   $0x3d6
f010309d:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01030a3:	50                   	push   %eax
f01030a4:	e8 0e d0 ff ff       	call   f01000b7 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01030a9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030ac:	8d 83 2c 96 f7 ff    	lea    -0x869d4(%ebx),%eax
f01030b2:	50                   	push   %eax
f01030b3:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01030b9:	50                   	push   %eax
f01030ba:	68 d8 03 00 00       	push   $0x3d8
f01030bf:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01030c5:	50                   	push   %eax
f01030c6:	e8 ec cf ff ff       	call   f01000b7 <_panic>
	assert(pp2->pp_ref == 1);
f01030cb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030ce:	8d 83 84 8e f7 ff    	lea    -0x8717c(%ebx),%eax
f01030d4:	50                   	push   %eax
f01030d5:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01030db:	50                   	push   %eax
f01030dc:	68 d9 03 00 00       	push   $0x3d9
f01030e1:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01030e7:	50                   	push   %eax
f01030e8:	e8 ca cf ff ff       	call   f01000b7 <_panic>
	assert(pp1->pp_ref == 0);
f01030ed:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030f0:	8d 83 cd 8e f7 ff    	lea    -0x87133(%ebx),%eax
f01030f6:	50                   	push   %eax
f01030f7:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01030fd:	50                   	push   %eax
f01030fe:	68 da 03 00 00       	push   $0x3da
f0103103:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0103109:	50                   	push   %eax
f010310a:	e8 a8 cf ff ff       	call   f01000b7 <_panic>
f010310f:	50                   	push   %eax
f0103110:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f0103116:	50                   	push   %eax
f0103117:	6a 56                	push   $0x56
f0103119:	8d 83 a0 8c f7 ff    	lea    -0x87360(%ebx),%eax
f010311f:	50                   	push   %eax
f0103120:	e8 92 cf ff ff       	call   f01000b7 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103125:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103128:	8d 83 50 96 f7 ff    	lea    -0x869b0(%ebx),%eax
f010312e:	50                   	push   %eax
f010312f:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0103135:	50                   	push   %eax
f0103136:	68 dc 03 00 00       	push   $0x3dc
f010313b:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0103141:	50                   	push   %eax
f0103142:	e8 70 cf ff ff       	call   f01000b7 <_panic>
	assert(pp2->pp_ref == 0);
f0103147:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010314a:	8d 83 bc 8e f7 ff    	lea    -0x87144(%ebx),%eax
f0103150:	50                   	push   %eax
f0103151:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0103157:	50                   	push   %eax
f0103158:	68 de 03 00 00       	push   $0x3de
f010315d:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0103163:	50                   	push   %eax
f0103164:	e8 4e cf ff ff       	call   f01000b7 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103169:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010316c:	8d 83 98 91 f7 ff    	lea    -0x86e68(%ebx),%eax
f0103172:	50                   	push   %eax
f0103173:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f0103179:	50                   	push   %eax
f010317a:	68 e1 03 00 00       	push   $0x3e1
f010317f:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0103185:	50                   	push   %eax
f0103186:	e8 2c cf ff ff       	call   f01000b7 <_panic>
	assert(pp0->pp_ref == 1);
f010318b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010318e:	8d 83 73 8e f7 ff    	lea    -0x8718d(%ebx),%eax
f0103194:	50                   	push   %eax
f0103195:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010319b:	50                   	push   %eax
f010319c:	68 e3 03 00 00       	push   $0x3e3
f01031a1:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01031a7:	50                   	push   %eax
f01031a8:	e8 0a cf ff ff       	call   f01000b7 <_panic>

f01031ad <tlb_invalidate>:
{
f01031ad:	55                   	push   %ebp
f01031ae:	89 e5                	mov    %esp,%ebp
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01031b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031b3:	0f 01 38             	invlpg (%eax)
}
f01031b6:	5d                   	pop    %ebp
f01031b7:	c3                   	ret    

f01031b8 <user_mem_check>:
{
f01031b8:	55                   	push   %ebp
f01031b9:	89 e5                	mov    %esp,%ebp
f01031bb:	57                   	push   %edi
f01031bc:	56                   	push   %esi
f01031bd:	53                   	push   %ebx
f01031be:	83 ec 1c             	sub    $0x1c,%esp
f01031c1:	e8 a7 cf ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f01031c6:	81 c3 5e 9e 08 00    	add    $0x89e5e,%ebx
f01031cc:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	unsigned cur_va = ROUNDDOWN((unsigned)va, PGSIZE);
f01031cf:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    unsigned end_va = ROUNDUP((unsigned)va + len, PGSIZE);
f01031d7:	8b 55 10             	mov    0x10(%ebp),%edx
f01031da:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01031dd:	8d 94 17 ff 0f 00 00 	lea    0xfff(%edi,%edx,1),%edx
f01031e4:	89 d7                	mov    %edx,%edi
f01031e6:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01031ec:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	perm |= PTE_P;
f01031ef:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01031f2:	83 c9 01             	or     $0x1,%ecx
    while(cur_va < end_va){
f01031f5:	39 f8                	cmp    %edi,%eax
f01031f7:	0f 83 d4 00 00 00    	jae    f01032d1 <user_mem_check+0x119>
        pde_t *pgdir = curenv->env_pgdir;
f01031fd:	c7 c2 48 f3 18 f0    	mov    $0xf018f348,%edx
f0103203:	8b 12                	mov    (%edx),%edx
f0103205:	8b 7a 5c             	mov    0x5c(%edx),%edi
        pde_t pgdir_entry = pgdir[PDX(cur_va)];
f0103208:	89 c2                	mov    %eax,%edx
f010320a:	c1 ea 16             	shr    $0x16,%edx
f010320d:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(cur_va > ULIM || (pgdir_entry & perm) != perm)
f0103210:	3d 00 00 80 ef       	cmp    $0xef800000,%eax
f0103215:	0f 87 99 00 00 00    	ja     f01032b4 <user_mem_check+0xfc>
f010321b:	89 cb                	mov    %ecx,%ebx
f010321d:	89 d6                	mov    %edx,%esi
f010321f:	21 ce                	and    %ecx,%esi
f0103221:	39 f1                	cmp    %esi,%ecx
f0103223:	0f 85 8b 00 00 00    	jne    f01032b4 <user_mem_check+0xfc>
        pte_t *pg_address = KADDR(PTE_ADDR(pgdir_entry));
f0103229:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f010322f:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103232:	c7 c1 04 00 19 f0    	mov    $0xf0190004,%ecx
f0103238:	8b 31                	mov    (%ecx),%esi
f010323a:	89 75 e0             	mov    %esi,-0x20(%ebp)
f010323d:	89 d1                	mov    %edx,%ecx
f010323f:	c1 e9 0c             	shr    $0xc,%ecx
f0103242:	39 f1                	cmp    %esi,%ecx
f0103244:	73 4b                	jae    f0103291 <user_mem_check+0xd9>
        pte_t pg_entry = pg_address[PTX(cur_va)];
f0103246:	89 c1                	mov    %eax,%ecx
f0103248:	c1 e9 0c             	shr    $0xc,%ecx
f010324b:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
        if(cur_va > ULIM || (pg_entry & perm) != perm)
f0103251:	89 de                	mov    %ebx,%esi
f0103253:	23 b4 8a 00 00 00 f0 	and    -0x10000000(%edx,%ecx,4),%esi
f010325a:	89 f1                	mov    %esi,%ecx
f010325c:	39 de                	cmp    %ebx,%esi
f010325e:	75 54                	jne    f01032b4 <user_mem_check+0xfc>
        cur_va += PGSIZE;
f0103260:	05 00 10 00 00       	add    $0x1000,%eax
    while(cur_va < end_va){
f0103265:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0103268:	76 43                	jbe    f01032ad <user_mem_check+0xf5>
        pde_t pgdir_entry = pgdir[PDX(cur_va)];
f010326a:	89 c2                	mov    %eax,%edx
f010326c:	c1 ea 16             	shr    $0x16,%edx
f010326f:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(cur_va > ULIM || (pgdir_entry & perm) != perm)
f0103272:	3d 00 10 80 ef       	cmp    $0xef801000,%eax
f0103277:	74 3b                	je     f01032b4 <user_mem_check+0xfc>
f0103279:	89 ce                	mov    %ecx,%esi
f010327b:	21 d6                	and    %edx,%esi
f010327d:	39 ce                	cmp    %ecx,%esi
f010327f:	75 33                	jne    f01032b4 <user_mem_check+0xfc>
        pte_t *pg_address = KADDR(PTE_ADDR(pgdir_entry));
f0103281:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103287:	89 d1                	mov    %edx,%ecx
f0103289:	c1 e9 0c             	shr    $0xc,%ecx
f010328c:	3b 4d e0             	cmp    -0x20(%ebp),%ecx
f010328f:	72 b5                	jb     f0103246 <user_mem_check+0x8e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103291:	52                   	push   %edx
f0103292:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103295:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f010329b:	50                   	push   %eax
f010329c:	68 37 02 00 00       	push   $0x237
f01032a1:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f01032a7:	50                   	push   %eax
f01032a8:	e8 0a ce ff ff       	call   f01000b7 <_panic>
    return 0;
f01032ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01032b2:	eb 15                	jmp    f01032c9 <user_mem_check+0x111>
	user_mem_check_addr = (cur_va > (unsigned)va ? cur_va : (unsigned)va);
f01032b4:	39 45 0c             	cmp    %eax,0xc(%ebp)
f01032b7:	0f 43 45 0c          	cmovae 0xc(%ebp),%eax
f01032bb:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01032be:	89 87 18 23 00 00    	mov    %eax,0x2318(%edi)
	return -E_FAULT;
f01032c4:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f01032c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032cc:	5b                   	pop    %ebx
f01032cd:	5e                   	pop    %esi
f01032ce:	5f                   	pop    %edi
f01032cf:	5d                   	pop    %ebp
f01032d0:	c3                   	ret    
    return 0;
f01032d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01032d6:	eb f1                	jmp    f01032c9 <user_mem_check+0x111>

f01032d8 <user_mem_assert>:
{
f01032d8:	55                   	push   %ebp
f01032d9:	89 e5                	mov    %esp,%ebp
f01032db:	56                   	push   %esi
f01032dc:	53                   	push   %ebx
f01032dd:	e8 8b ce ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f01032e2:	81 c3 42 9d 08 00    	add    $0x89d42,%ebx
f01032e8:	8b 75 08             	mov    0x8(%ebp),%esi
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01032eb:	8b 45 14             	mov    0x14(%ebp),%eax
f01032ee:	83 c8 04             	or     $0x4,%eax
f01032f1:	50                   	push   %eax
f01032f2:	ff 75 10             	pushl  0x10(%ebp)
f01032f5:	ff 75 0c             	pushl  0xc(%ebp)
f01032f8:	56                   	push   %esi
f01032f9:	e8 ba fe ff ff       	call   f01031b8 <user_mem_check>
f01032fe:	83 c4 10             	add    $0x10,%esp
f0103301:	85 c0                	test   %eax,%eax
f0103303:	78 07                	js     f010330c <user_mem_assert+0x34>
		}
f0103305:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103308:	5b                   	pop    %ebx
f0103309:	5e                   	pop    %esi
f010330a:	5d                   	pop    %ebp
f010330b:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f010330c:	83 ec 04             	sub    $0x4,%esp
f010330f:	ff b3 18 23 00 00    	pushl  0x2318(%ebx)
f0103315:	ff 76 48             	pushl  0x48(%esi)
f0103318:	8d 83 a8 96 f7 ff    	lea    -0x86958(%ebx),%eax
f010331e:	50                   	push   %eax
f010331f:	e8 61 08 00 00       	call   f0103b85 <cprintf>
		env_destroy(env);	// may not return
f0103324:	89 34 24             	mov    %esi,(%esp)
f0103327:	e8 e7 06 00 00       	call   f0103a13 <env_destroy>
f010332c:	83 c4 10             	add    $0x10,%esp
		}
f010332f:	eb d4                	jmp    f0103305 <user_mem_assert+0x2d>

f0103331 <__x86.get_pc_thunk.dx>:
f0103331:	8b 14 24             	mov    (%esp),%edx
f0103334:	c3                   	ret    

f0103335 <__x86.get_pc_thunk.cx>:
f0103335:	8b 0c 24             	mov    (%esp),%ecx
f0103338:	c3                   	ret    

f0103339 <__x86.get_pc_thunk.di>:
f0103339:	8b 3c 24             	mov    (%esp),%edi
f010333c:	c3                   	ret    

f010333d <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010333d:	55                   	push   %ebp
f010333e:	89 e5                	mov    %esp,%ebp
f0103340:	57                   	push   %edi
f0103341:	56                   	push   %esi
f0103342:	53                   	push   %ebx
f0103343:	83 ec 1c             	sub    $0x1c,%esp
f0103346:	e8 22 ce ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f010334b:	81 c3 d9 9c 08 00    	add    $0x89cd9,%ebx
f0103351:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	unsigned start = ROUNDDOWN((unsigned)va, PGSIZE);
f0103353:	89 d6                	mov    %edx,%esi
f0103355:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	unsigned end = ROUNDUP((unsigned)va + len, PGSIZE);
f010335b:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103362:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103367:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(; start < end; start += PGSIZE){
f010336a:	39 c6                	cmp    %eax,%esi
f010336c:	73 2f                	jae    f010339d <region_alloc+0x60>
		struct PageInfo *page = page_alloc(0); //不需要ALLOC_ZERO
f010336e:	83 ec 0c             	sub    $0xc,%esp
f0103371:	6a 00                	push   $0x0
f0103373:	e8 05 dd ff ff       	call   f010107d <page_alloc>
		if(!page)
f0103378:	83 c4 10             	add    $0x10,%esp
f010337b:	85 c0                	test   %eax,%eax
f010337d:	74 26                	je     f01033a5 <region_alloc+0x68>
			panic("region_alloc: page_alloc error");
		int result = page_insert(e->env_pgdir, page, (void *)start, PTE_U | PTE_W);
f010337f:	6a 06                	push   $0x6
f0103381:	56                   	push   %esi
f0103382:	50                   	push   %eax
f0103383:	ff 77 5c             	pushl  0x5c(%edi)
f0103386:	e8 a2 df ff ff       	call   f010132d <page_insert>
		if(result < 0)
f010338b:	83 c4 10             	add    $0x10,%esp
f010338e:	85 c0                	test   %eax,%eax
f0103390:	78 2e                	js     f01033c0 <region_alloc+0x83>
	for(; start < end; start += PGSIZE){
f0103392:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103398:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f010339b:	77 d1                	ja     f010336e <region_alloc+0x31>
			panic("region_alloc: page_insert error");
	}
}
f010339d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033a0:	5b                   	pop    %ebx
f01033a1:	5e                   	pop    %esi
f01033a2:	5f                   	pop    %edi
f01033a3:	5d                   	pop    %ebp
f01033a4:	c3                   	ret    
			panic("region_alloc: page_alloc error");
f01033a5:	83 ec 04             	sub    $0x4,%esp
f01033a8:	8d 83 e0 96 f7 ff    	lea    -0x86920(%ebx),%eax
f01033ae:	50                   	push   %eax
f01033af:	68 20 01 00 00       	push   $0x120
f01033b4:	8d 83 ae 97 f7 ff    	lea    -0x86852(%ebx),%eax
f01033ba:	50                   	push   %eax
f01033bb:	e8 f7 cc ff ff       	call   f01000b7 <_panic>
			panic("region_alloc: page_insert error");
f01033c0:	83 ec 04             	sub    $0x4,%esp
f01033c3:	8d 83 00 97 f7 ff    	lea    -0x86900(%ebx),%eax
f01033c9:	50                   	push   %eax
f01033ca:	68 23 01 00 00       	push   $0x123
f01033cf:	8d 83 ae 97 f7 ff    	lea    -0x86852(%ebx),%eax
f01033d5:	50                   	push   %eax
f01033d6:	e8 dc cc ff ff       	call   f01000b7 <_panic>

f01033db <envid2env>:
{
f01033db:	55                   	push   %ebp
f01033dc:	89 e5                	mov    %esp,%ebp
f01033de:	53                   	push   %ebx
f01033df:	e8 51 ff ff ff       	call   f0103335 <__x86.get_pc_thunk.cx>
f01033e4:	81 c1 40 9c 08 00    	add    $0x89c40,%ecx
f01033ea:	8b 55 08             	mov    0x8(%ebp),%edx
f01033ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if (envid == 0) {
f01033f0:	85 d2                	test   %edx,%edx
f01033f2:	74 41                	je     f0103435 <envid2env+0x5a>
	e = &envs[ENVX(envid)];
f01033f4:	89 d0                	mov    %edx,%eax
f01033f6:	25 ff 03 00 00       	and    $0x3ff,%eax
f01033fb:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01033fe:	c1 e0 05             	shl    $0x5,%eax
f0103401:	03 81 28 23 00 00    	add    0x2328(%ecx),%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103407:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f010340b:	74 3a                	je     f0103447 <envid2env+0x6c>
f010340d:	39 50 48             	cmp    %edx,0x48(%eax)
f0103410:	75 35                	jne    f0103447 <envid2env+0x6c>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103412:	84 db                	test   %bl,%bl
f0103414:	74 12                	je     f0103428 <envid2env+0x4d>
f0103416:	8b 91 24 23 00 00    	mov    0x2324(%ecx),%edx
f010341c:	39 c2                	cmp    %eax,%edx
f010341e:	74 08                	je     f0103428 <envid2env+0x4d>
f0103420:	8b 5a 48             	mov    0x48(%edx),%ebx
f0103423:	39 58 4c             	cmp    %ebx,0x4c(%eax)
f0103426:	75 2f                	jne    f0103457 <envid2env+0x7c>
	*env_store = e;
f0103428:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010342b:	89 03                	mov    %eax,(%ebx)
	return 0;
f010342d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103432:	5b                   	pop    %ebx
f0103433:	5d                   	pop    %ebp
f0103434:	c3                   	ret    
		*env_store = curenv;
f0103435:	8b 81 24 23 00 00    	mov    0x2324(%ecx),%eax
f010343b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010343e:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103440:	b8 00 00 00 00       	mov    $0x0,%eax
f0103445:	eb eb                	jmp    f0103432 <envid2env+0x57>
		*env_store = 0;
f0103447:	8b 45 0c             	mov    0xc(%ebp),%eax
f010344a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103450:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103455:	eb db                	jmp    f0103432 <envid2env+0x57>
		*env_store = 0;
f0103457:	8b 45 0c             	mov    0xc(%ebp),%eax
f010345a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103460:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103465:	eb cb                	jmp    f0103432 <envid2env+0x57>

f0103467 <env_init_percpu>:
{
f0103467:	55                   	push   %ebp
f0103468:	89 e5                	mov    %esp,%ebp
f010346a:	e8 a1 d2 ff ff       	call   f0100710 <__x86.get_pc_thunk.ax>
f010346f:	05 b5 9b 08 00       	add    $0x89bb5,%eax
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103474:	8d 80 dc 1f 00 00    	lea    0x1fdc(%eax),%eax
f010347a:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010347d:	b8 23 00 00 00       	mov    $0x23,%eax
f0103482:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103484:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103486:	b8 10 00 00 00       	mov    $0x10,%eax
f010348b:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010348d:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010348f:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103491:	ea 98 34 10 f0 08 00 	ljmp   $0x8,$0xf0103498
	__asm __volatile("lldt %0" : : "r" (sel));
f0103498:	b8 00 00 00 00       	mov    $0x0,%eax
f010349d:	0f 00 d0             	lldt   %ax
}
f01034a0:	5d                   	pop    %ebp
f01034a1:	c3                   	ret    

f01034a2 <env_init>:
{
f01034a2:	55                   	push   %ebp
f01034a3:	89 e5                	mov    %esp,%ebp
f01034a5:	57                   	push   %edi
f01034a6:	56                   	push   %esi
f01034a7:	53                   	push   %ebx
f01034a8:	e8 4d 06 00 00       	call   f0103afa <__x86.get_pc_thunk.si>
f01034ad:	81 c6 77 9b 08 00    	add    $0x89b77,%esi
		envs[i].env_status = ENV_FREE;
f01034b3:	8b be 28 23 00 00    	mov    0x2328(%esi),%edi
f01034b9:	8b 96 2c 23 00 00    	mov    0x232c(%esi),%edx
f01034bf:	8d 87 a0 7f 01 00    	lea    0x17fa0(%edi),%eax
f01034c5:	8d 5f a0             	lea    -0x60(%edi),%ebx
f01034c8:	89 c1                	mov    %eax,%ecx
f01034ca:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f01034d1:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01034d8:	89 50 44             	mov    %edx,0x44(%eax)
f01034db:	83 e8 60             	sub    $0x60,%eax
		env_free_list = &envs[i];
f01034de:	89 ca                	mov    %ecx,%edx
	for(int i = NENV - 1; i >= 0; --i){
f01034e0:	39 d8                	cmp    %ebx,%eax
f01034e2:	75 e4                	jne    f01034c8 <env_init+0x26>
f01034e4:	89 be 2c 23 00 00    	mov    %edi,0x232c(%esi)
	env_init_percpu();
f01034ea:	e8 78 ff ff ff       	call   f0103467 <env_init_percpu>
}
f01034ef:	5b                   	pop    %ebx
f01034f0:	5e                   	pop    %esi
f01034f1:	5f                   	pop    %edi
f01034f2:	5d                   	pop    %ebp
f01034f3:	c3                   	ret    

f01034f4 <env_alloc>:
{
f01034f4:	55                   	push   %ebp
f01034f5:	89 e5                	mov    %esp,%ebp
f01034f7:	57                   	push   %edi
f01034f8:	56                   	push   %esi
f01034f9:	53                   	push   %ebx
f01034fa:	83 ec 0c             	sub    $0xc,%esp
f01034fd:	e8 6b cc ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0103502:	81 c3 22 9b 08 00    	add    $0x89b22,%ebx
	if (!(e = env_free_list))
f0103508:	8b b3 2c 23 00 00    	mov    0x232c(%ebx),%esi
f010350e:	85 f6                	test   %esi,%esi
f0103510:	0f 84 6e 01 00 00    	je     f0103684 <env_alloc+0x190>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103516:	83 ec 0c             	sub    $0xc,%esp
f0103519:	6a 01                	push   $0x1
f010351b:	e8 5d db ff ff       	call   f010107d <page_alloc>
f0103520:	83 c4 10             	add    $0x10,%esp
f0103523:	85 c0                	test   %eax,%eax
f0103525:	0f 84 60 01 00 00    	je     f010368b <env_alloc+0x197>
	return (pp - pages) << PGSHIFT;
f010352b:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f0103531:	89 c7                	mov    %eax,%edi
f0103533:	2b 3a                	sub    (%edx),%edi
f0103535:	89 fa                	mov    %edi,%edx
f0103537:	c1 fa 03             	sar    $0x3,%edx
f010353a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010353d:	89 d7                	mov    %edx,%edi
f010353f:	c1 ef 0c             	shr    $0xc,%edi
f0103542:	c7 c1 04 00 19 f0    	mov    $0xf0190004,%ecx
f0103548:	3b 39                	cmp    (%ecx),%edi
f010354a:	0f 83 05 01 00 00    	jae    f0103655 <env_alloc+0x161>
	return (void *)(pa + KERNBASE);
f0103550:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103556:	89 56 5c             	mov    %edx,0x5c(%esi)
	p->pp_ref = 1;
f0103559:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
f010355f:	b8 ec 0e 00 00       	mov    $0xeec,%eax
		e->env_pgdir[i] = kern_pgdir[i];
f0103564:	c7 c7 08 00 19 f0    	mov    $0xf0190008,%edi
f010356a:	8b 17                	mov    (%edi),%edx
f010356c:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f010356f:	8b 56 5c             	mov    0x5c(%esi),%edx
f0103572:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103575:	83 c0 04             	add    $0x4,%eax
	for(int i = PDX(UTOP); i < NPDENTRIES; ++i)
f0103578:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010357d:	75 eb                	jne    f010356a <env_alloc+0x76>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010357f:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103582:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103587:	0f 86 de 00 00 00    	jbe    f010366b <env_alloc+0x177>
	return (physaddr_t)kva - KERNBASE;
f010358d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103593:	83 ca 05             	or     $0x5,%edx
f0103596:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010359c:	8b 46 48             	mov    0x48(%esi),%eax
f010359f:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01035a4:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01035a9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01035ae:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01035b1:	89 f2                	mov    %esi,%edx
f01035b3:	2b 93 28 23 00 00    	sub    0x2328(%ebx),%edx
f01035b9:	c1 fa 05             	sar    $0x5,%edx
f01035bc:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01035c2:	09 d0                	or     %edx,%eax
f01035c4:	89 46 48             	mov    %eax,0x48(%esi)
	e->env_parent_id = parent_id;
f01035c7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035ca:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f01035cd:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f01035d4:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f01035db:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01035e2:	83 ec 04             	sub    $0x4,%esp
f01035e5:	6a 44                	push   $0x44
f01035e7:	6a 00                	push   $0x0
f01035e9:	56                   	push   %esi
f01035ea:	e8 69 1d 00 00       	call   f0105358 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f01035ef:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f01035f5:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f01035fb:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f0103601:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f0103608:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	env_free_list = e->env_link;
f010360e:	8b 46 44             	mov    0x44(%esi),%eax
f0103611:	89 83 2c 23 00 00    	mov    %eax,0x232c(%ebx)
	*newenv_store = e;
f0103617:	8b 45 08             	mov    0x8(%ebp),%eax
f010361a:	89 30                	mov    %esi,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010361c:	8b 4e 48             	mov    0x48(%esi),%ecx
f010361f:	8b 83 24 23 00 00    	mov    0x2324(%ebx),%eax
f0103625:	83 c4 10             	add    $0x10,%esp
f0103628:	ba 00 00 00 00       	mov    $0x0,%edx
f010362d:	85 c0                	test   %eax,%eax
f010362f:	74 03                	je     f0103634 <env_alloc+0x140>
f0103631:	8b 50 48             	mov    0x48(%eax),%edx
f0103634:	83 ec 04             	sub    $0x4,%esp
f0103637:	51                   	push   %ecx
f0103638:	52                   	push   %edx
f0103639:	8d 83 b9 97 f7 ff    	lea    -0x86847(%ebx),%eax
f010363f:	50                   	push   %eax
f0103640:	e8 40 05 00 00       	call   f0103b85 <cprintf>
	return 0;
f0103645:	83 c4 10             	add    $0x10,%esp
f0103648:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010364d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103650:	5b                   	pop    %ebx
f0103651:	5e                   	pop    %esi
f0103652:	5f                   	pop    %edi
f0103653:	5d                   	pop    %ebp
f0103654:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103655:	52                   	push   %edx
f0103656:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f010365c:	50                   	push   %eax
f010365d:	6a 56                	push   $0x56
f010365f:	8d 83 a0 8c f7 ff    	lea    -0x87360(%ebx),%eax
f0103665:	50                   	push   %eax
f0103666:	e8 4c ca ff ff       	call   f01000b7 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010366b:	50                   	push   %eax
f010366c:	8d 83 40 90 f7 ff    	lea    -0x86fc0(%ebx),%eax
f0103672:	50                   	push   %eax
f0103673:	68 c6 00 00 00       	push   $0xc6
f0103678:	8d 83 ae 97 f7 ff    	lea    -0x86852(%ebx),%eax
f010367e:	50                   	push   %eax
f010367f:	e8 33 ca ff ff       	call   f01000b7 <_panic>
		return -E_NO_FREE_ENV;
f0103684:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103689:	eb c2                	jmp    f010364d <env_alloc+0x159>
		return -E_NO_MEM;
f010368b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103690:	eb bb                	jmp    f010364d <env_alloc+0x159>

f0103692 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103692:	55                   	push   %ebp
f0103693:	89 e5                	mov    %esp,%ebp
f0103695:	57                   	push   %edi
f0103696:	56                   	push   %esi
f0103697:	53                   	push   %ebx
f0103698:	83 ec 34             	sub    $0x34,%esp
f010369b:	e8 cd ca ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f01036a0:	81 c3 84 99 08 00    	add    $0x89984,%ebx
	// LAB 3: Your code here.
	struct Env *env;
	int result = env_alloc(&env, 0);
f01036a6:	6a 00                	push   $0x0
f01036a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01036ab:	50                   	push   %eax
f01036ac:	e8 43 fe ff ff       	call   f01034f4 <env_alloc>
	if(result < 0)
f01036b1:	83 c4 10             	add    $0x10,%esp
f01036b4:	85 c0                	test   %eax,%eax
f01036b6:	78 7b                	js     f0103733 <env_create+0xa1>
		panic("env_create: env_alloc error");
	load_icode(env, binary, size);
f01036b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01036bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if(ELF_MAGIC != elf->e_magic)
f01036be:	8b 45 08             	mov    0x8(%ebp),%eax
f01036c1:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01036c7:	0f 85 81 00 00 00    	jne    f010374e <env_create+0xbc>
	if(!elf->e_entry)
f01036cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01036d0:	8b 40 18             	mov    0x18(%eax),%eax
f01036d3:	85 c0                	test   %eax,%eax
f01036d5:	0f 84 8e 00 00 00    	je     f0103769 <env_create+0xd7>
	e->env_tf.tf_eip = elf->e_entry;
f01036db:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01036de:	89 41 30             	mov    %eax,0x30(%ecx)
	struct Proghdr *ph = (struct Proghdr *)(binary + elf->e_phoff);
f01036e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01036e4:	89 c6                	mov    %eax,%esi
f01036e6:	03 70 1c             	add    0x1c(%eax),%esi
	struct Proghdr *eph = ph + elf->e_phnum;
f01036e9:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f01036ed:	c1 e7 05             	shl    $0x5,%edi
f01036f0:	01 f7                	add    %esi,%edi
	lcr3(PADDR(e->env_pgdir));
f01036f2:	8b 41 5c             	mov    0x5c(%ecx),%eax
	if ((uint32_t)kva < KERNBASE)
f01036f5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036fa:	0f 86 84 00 00 00    	jbe    f0103784 <env_create+0xf2>
	return (physaddr_t)kva - KERNBASE;
f0103700:	05 00 00 00 10       	add    $0x10000000,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103705:	0f 22 d8             	mov    %eax,%cr3
	for(; ph < eph; ++ph)
f0103708:	39 fe                	cmp    %edi,%esi
f010370a:	0f 82 b3 00 00 00    	jb     f01037c3 <env_create+0x131>
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103710:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103715:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010371a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010371d:	e8 1b fc ff ff       	call   f010333d <region_alloc>
	env->env_type = type;
f0103722:	8b 55 10             	mov    0x10(%ebp),%edx
f0103725:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103728:	89 50 50             	mov    %edx,0x50(%eax)
}
f010372b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010372e:	5b                   	pop    %ebx
f010372f:	5e                   	pop    %esi
f0103730:	5f                   	pop    %edi
f0103731:	5d                   	pop    %ebp
f0103732:	c3                   	ret    
		panic("env_create: env_alloc error");
f0103733:	83 ec 04             	sub    $0x4,%esp
f0103736:	8d 83 ce 97 f7 ff    	lea    -0x86832(%ebx),%eax
f010373c:	50                   	push   %eax
f010373d:	68 8b 01 00 00       	push   $0x18b
f0103742:	8d 83 ae 97 f7 ff    	lea    -0x86852(%ebx),%eax
f0103748:	50                   	push   %eax
f0103749:	e8 69 c9 ff ff       	call   f01000b7 <_panic>
		panic("load icode: e_magic is not equal to ELF_MAGIC");
f010374e:	83 ec 04             	sub    $0x4,%esp
f0103751:	8d 83 20 97 f7 ff    	lea    -0x868e0(%ebx),%eax
f0103757:	50                   	push   %eax
f0103758:	68 5f 01 00 00       	push   $0x15f
f010375d:	8d 83 ae 97 f7 ff    	lea    -0x86852(%ebx),%eax
f0103763:	50                   	push   %eax
f0103764:	e8 4e c9 ff ff       	call   f01000b7 <_panic>
		panic("load icode: e_entry is NULL");
f0103769:	83 ec 04             	sub    $0x4,%esp
f010376c:	8d 83 ea 97 f7 ff    	lea    -0x86816(%ebx),%eax
f0103772:	50                   	push   %eax
f0103773:	68 61 01 00 00       	push   $0x161
f0103778:	8d 83 ae 97 f7 ff    	lea    -0x86852(%ebx),%eax
f010377e:	50                   	push   %eax
f010377f:	e8 33 c9 ff ff       	call   f01000b7 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103784:	50                   	push   %eax
f0103785:	8d 83 40 90 f7 ff    	lea    -0x86fc0(%ebx),%eax
f010378b:	50                   	push   %eax
f010378c:	68 67 01 00 00       	push   $0x167
f0103791:	8d 83 ae 97 f7 ff    	lea    -0x86852(%ebx),%eax
f0103797:	50                   	push   %eax
f0103798:	e8 1a c9 ff ff       	call   f01000b7 <_panic>
				panic("load icode: ph->p_filesz > ph->p_memsz");
f010379d:	83 ec 04             	sub    $0x4,%esp
f01037a0:	8d 83 50 97 f7 ff    	lea    -0x868b0(%ebx),%eax
f01037a6:	50                   	push   %eax
f01037a7:	68 6d 01 00 00       	push   $0x16d
f01037ac:	8d 83 ae 97 f7 ff    	lea    -0x86852(%ebx),%eax
f01037b2:	50                   	push   %eax
f01037b3:	e8 ff c8 ff ff       	call   f01000b7 <_panic>
	for(; ph < eph; ++ph)
f01037b8:	83 c6 20             	add    $0x20,%esi
f01037bb:	39 f7                	cmp    %esi,%edi
f01037bd:	0f 86 4d ff ff ff    	jbe    f0103710 <env_create+0x7e>
		if(ELF_PROG_LOAD == ph->p_type){
f01037c3:	83 3e 01             	cmpl   $0x1,(%esi)
f01037c6:	75 f0                	jne    f01037b8 <env_create+0x126>
			if(ph->p_filesz > ph->p_memsz)
f01037c8:	8b 4e 14             	mov    0x14(%esi),%ecx
f01037cb:	39 4e 10             	cmp    %ecx,0x10(%esi)
f01037ce:	77 cd                	ja     f010379d <env_create+0x10b>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01037d0:	8b 56 08             	mov    0x8(%esi),%edx
f01037d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01037d6:	e8 62 fb ff ff       	call   f010333d <region_alloc>
			memmove((char *)ph->p_va, (void *)(binary + ph->p_offset), ph->p_filesz);
f01037db:	83 ec 04             	sub    $0x4,%esp
f01037de:	ff 76 10             	pushl  0x10(%esi)
f01037e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01037e4:	03 46 04             	add    0x4(%esi),%eax
f01037e7:	50                   	push   %eax
f01037e8:	ff 76 08             	pushl  0x8(%esi)
f01037eb:	e8 b5 1b 00 00       	call   f01053a5 <memmove>
			memset((char *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f01037f0:	8b 46 10             	mov    0x10(%esi),%eax
f01037f3:	83 c4 0c             	add    $0xc,%esp
f01037f6:	8b 56 14             	mov    0x14(%esi),%edx
f01037f9:	29 c2                	sub    %eax,%edx
f01037fb:	52                   	push   %edx
f01037fc:	6a 00                	push   $0x0
f01037fe:	03 46 08             	add    0x8(%esi),%eax
f0103801:	50                   	push   %eax
f0103802:	e8 51 1b 00 00       	call   f0105358 <memset>
f0103807:	83 c4 10             	add    $0x10,%esp
f010380a:	eb ac                	jmp    f01037b8 <env_create+0x126>

f010380c <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010380c:	55                   	push   %ebp
f010380d:	89 e5                	mov    %esp,%ebp
f010380f:	57                   	push   %edi
f0103810:	56                   	push   %esi
f0103811:	53                   	push   %ebx
f0103812:	83 ec 2c             	sub    $0x2c,%esp
f0103815:	e8 53 c9 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f010381a:	81 c3 0a 98 08 00    	add    $0x8980a,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103820:	8b 93 24 23 00 00    	mov    0x2324(%ebx),%edx
f0103826:	3b 55 08             	cmp    0x8(%ebp),%edx
f0103829:	75 17                	jne    f0103842 <env_free+0x36>
		lcr3(PADDR(kern_pgdir));
f010382b:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0103831:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103833:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103838:	76 46                	jbe    f0103880 <env_free+0x74>
	return (physaddr_t)kva - KERNBASE;
f010383a:	05 00 00 00 10       	add    $0x10000000,%eax
f010383f:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103842:	8b 45 08             	mov    0x8(%ebp),%eax
f0103845:	8b 48 48             	mov    0x48(%eax),%ecx
f0103848:	b8 00 00 00 00       	mov    $0x0,%eax
f010384d:	85 d2                	test   %edx,%edx
f010384f:	74 03                	je     f0103854 <env_free+0x48>
f0103851:	8b 42 48             	mov    0x48(%edx),%eax
f0103854:	83 ec 04             	sub    $0x4,%esp
f0103857:	51                   	push   %ecx
f0103858:	50                   	push   %eax
f0103859:	8d 83 06 98 f7 ff    	lea    -0x867fa(%ebx),%eax
f010385f:	50                   	push   %eax
f0103860:	e8 20 03 00 00       	call   f0103b85 <cprintf>
f0103865:	83 c4 10             	add    $0x10,%esp
f0103868:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	if (PGNUM(pa) >= npages)
f010386f:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0103875:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (PGNUM(pa) >= npages)
f0103878:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010387b:	e9 9f 00 00 00       	jmp    f010391f <env_free+0x113>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103880:	50                   	push   %eax
f0103881:	8d 83 40 90 f7 ff    	lea    -0x86fc0(%ebx),%eax
f0103887:	50                   	push   %eax
f0103888:	68 9e 01 00 00       	push   $0x19e
f010388d:	8d 83 ae 97 f7 ff    	lea    -0x86852(%ebx),%eax
f0103893:	50                   	push   %eax
f0103894:	e8 1e c8 ff ff       	call   f01000b7 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103899:	50                   	push   %eax
f010389a:	8d 83 58 8f f7 ff    	lea    -0x870a8(%ebx),%eax
f01038a0:	50                   	push   %eax
f01038a1:	68 ad 01 00 00       	push   $0x1ad
f01038a6:	8d 83 ae 97 f7 ff    	lea    -0x86852(%ebx),%eax
f01038ac:	50                   	push   %eax
f01038ad:	e8 05 c8 ff ff       	call   f01000b7 <_panic>
f01038b2:	83 c6 04             	add    $0x4,%esi
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01038b5:	39 f7                	cmp    %esi,%edi
f01038b7:	74 24                	je     f01038dd <env_free+0xd1>
			if (pt[pteno] & PTE_P)
f01038b9:	f6 06 01             	testb  $0x1,(%esi)
f01038bc:	74 f4                	je     f01038b2 <env_free+0xa6>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01038be:	83 ec 08             	sub    $0x8,%esp
f01038c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038c4:	01 f0                	add    %esi,%eax
f01038c6:	c1 e0 0a             	shl    $0xa,%eax
f01038c9:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01038cc:	50                   	push   %eax
f01038cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01038d0:	ff 70 5c             	pushl  0x5c(%eax)
f01038d3:	e8 11 da ff ff       	call   f01012e9 <page_remove>
f01038d8:	83 c4 10             	add    $0x10,%esp
f01038db:	eb d5                	jmp    f01038b2 <env_free+0xa6>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01038dd:	8b 45 08             	mov    0x8(%ebp),%eax
f01038e0:	8b 40 5c             	mov    0x5c(%eax),%eax
f01038e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01038e6:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01038ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01038f0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01038f3:	3b 10                	cmp    (%eax),%edx
f01038f5:	73 6f                	jae    f0103966 <env_free+0x15a>
		page_decref(pa2page(pa));
f01038f7:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01038fa:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0103900:	8b 00                	mov    (%eax),%eax
f0103902:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103905:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103908:	50                   	push   %eax
f0103909:	e8 23 d8 ff ff       	call   f0101131 <page_decref>
f010390e:	83 c4 10             	add    $0x10,%esp
f0103911:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f0103915:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103918:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f010391d:	74 5f                	je     f010397e <env_free+0x172>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010391f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103922:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103925:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103928:	8b 04 10             	mov    (%eax,%edx,1),%eax
f010392b:	a8 01                	test   $0x1,%al
f010392d:	74 e2                	je     f0103911 <env_free+0x105>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010392f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0103934:	89 c2                	mov    %eax,%edx
f0103936:	c1 ea 0c             	shr    $0xc,%edx
f0103939:	89 55 d8             	mov    %edx,-0x28(%ebp)
f010393c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010393f:	39 11                	cmp    %edx,(%ecx)
f0103941:	0f 86 52 ff ff ff    	jbe    f0103899 <env_free+0x8d>
	return (void *)(pa + KERNBASE);
f0103947:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010394d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103950:	c1 e2 14             	shl    $0x14,%edx
f0103953:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103956:	8d b8 00 10 00 f0    	lea    -0xffff000(%eax),%edi
f010395c:	f7 d8                	neg    %eax
f010395e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103961:	e9 53 ff ff ff       	jmp    f01038b9 <env_free+0xad>
		panic("pa2page called with invalid pa");
f0103966:	83 ec 04             	sub    $0x4,%esp
f0103969:	8d 83 64 90 f7 ff    	lea    -0x86f9c(%ebx),%eax
f010396f:	50                   	push   %eax
f0103970:	6a 4f                	push   $0x4f
f0103972:	8d 83 a0 8c f7 ff    	lea    -0x87360(%ebx),%eax
f0103978:	50                   	push   %eax
f0103979:	e8 39 c7 ff ff       	call   f01000b7 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010397e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103981:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103984:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103989:	76 57                	jbe    f01039e2 <env_free+0x1d6>
	e->env_pgdir = 0;
f010398b:	8b 55 08             	mov    0x8(%ebp),%edx
f010398e:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
	return (physaddr_t)kva - KERNBASE;
f0103995:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f010399a:	c1 e8 0c             	shr    $0xc,%eax
f010399d:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f01039a3:	3b 02                	cmp    (%edx),%eax
f01039a5:	73 54                	jae    f01039fb <env_free+0x1ef>
	page_decref(pa2page(pa));
f01039a7:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01039aa:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f01039b0:	8b 12                	mov    (%edx),%edx
f01039b2:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01039b5:	50                   	push   %eax
f01039b6:	e8 76 d7 ff ff       	call   f0101131 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01039bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01039be:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f01039c5:	8b 83 2c 23 00 00    	mov    0x232c(%ebx),%eax
f01039cb:	8b 55 08             	mov    0x8(%ebp),%edx
f01039ce:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f01039d1:	89 93 2c 23 00 00    	mov    %edx,0x232c(%ebx)
}
f01039d7:	83 c4 10             	add    $0x10,%esp
f01039da:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01039dd:	5b                   	pop    %ebx
f01039de:	5e                   	pop    %esi
f01039df:	5f                   	pop    %edi
f01039e0:	5d                   	pop    %ebp
f01039e1:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039e2:	50                   	push   %eax
f01039e3:	8d 83 40 90 f7 ff    	lea    -0x86fc0(%ebx),%eax
f01039e9:	50                   	push   %eax
f01039ea:	68 bb 01 00 00       	push   $0x1bb
f01039ef:	8d 83 ae 97 f7 ff    	lea    -0x86852(%ebx),%eax
f01039f5:	50                   	push   %eax
f01039f6:	e8 bc c6 ff ff       	call   f01000b7 <_panic>
		panic("pa2page called with invalid pa");
f01039fb:	83 ec 04             	sub    $0x4,%esp
f01039fe:	8d 83 64 90 f7 ff    	lea    -0x86f9c(%ebx),%eax
f0103a04:	50                   	push   %eax
f0103a05:	6a 4f                	push   $0x4f
f0103a07:	8d 83 a0 8c f7 ff    	lea    -0x87360(%ebx),%eax
f0103a0d:	50                   	push   %eax
f0103a0e:	e8 a4 c6 ff ff       	call   f01000b7 <_panic>

f0103a13 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103a13:	55                   	push   %ebp
f0103a14:	89 e5                	mov    %esp,%ebp
f0103a16:	53                   	push   %ebx
f0103a17:	83 ec 10             	sub    $0x10,%esp
f0103a1a:	e8 4e c7 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0103a1f:	81 c3 05 96 08 00    	add    $0x89605,%ebx
	env_free(e);
f0103a25:	ff 75 08             	pushl  0x8(%ebp)
f0103a28:	e8 df fd ff ff       	call   f010380c <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103a2d:	8d 83 78 97 f7 ff    	lea    -0x86888(%ebx),%eax
f0103a33:	89 04 24             	mov    %eax,(%esp)
f0103a36:	e8 4a 01 00 00       	call   f0103b85 <cprintf>
f0103a3b:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0103a3e:	83 ec 0c             	sub    $0xc,%esp
f0103a41:	6a 00                	push   $0x0
f0103a43:	e8 e8 ce ff ff       	call   f0100930 <monitor>
f0103a48:	83 c4 10             	add    $0x10,%esp
f0103a4b:	eb f1                	jmp    f0103a3e <env_destroy+0x2b>

f0103a4d <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103a4d:	55                   	push   %ebp
f0103a4e:	89 e5                	mov    %esp,%ebp
f0103a50:	53                   	push   %ebx
f0103a51:	83 ec 08             	sub    $0x8,%esp
f0103a54:	e8 14 c7 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0103a59:	81 c3 cb 95 08 00    	add    $0x895cb,%ebx
	__asm __volatile("movl %0,%%esp\n"
f0103a5f:	8b 65 08             	mov    0x8(%ebp),%esp
f0103a62:	61                   	popa   
f0103a63:	07                   	pop    %es
f0103a64:	1f                   	pop    %ds
f0103a65:	83 c4 08             	add    $0x8,%esp
f0103a68:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103a69:	8d 83 1c 98 f7 ff    	lea    -0x867e4(%ebx),%eax
f0103a6f:	50                   	push   %eax
f0103a70:	68 e3 01 00 00       	push   $0x1e3
f0103a75:	8d 83 ae 97 f7 ff    	lea    -0x86852(%ebx),%eax
f0103a7b:	50                   	push   %eax
f0103a7c:	e8 36 c6 ff ff       	call   f01000b7 <_panic>

f0103a81 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103a81:	55                   	push   %ebp
f0103a82:	89 e5                	mov    %esp,%ebp
f0103a84:	53                   	push   %ebx
f0103a85:	83 ec 04             	sub    $0x4,%esp
f0103a88:	e8 e0 c6 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0103a8d:	81 c3 97 95 08 00    	add    $0x89597,%ebx
f0103a93:	8b 45 08             	mov    0x8(%ebp),%eax
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// 修改原来的env状态
	if(curenv && ENV_RUNNING == curenv->env_status){
f0103a96:	8b 93 24 23 00 00    	mov    0x2324(%ebx),%edx
f0103a9c:	85 d2                	test   %edx,%edx
f0103a9e:	74 06                	je     f0103aa6 <env_run+0x25>
f0103aa0:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103aa4:	74 35                	je     f0103adb <env_run+0x5a>
		curenv->env_status = ENV_RUNNABLE;
		curenv->env_runs--;
	}
	// 修改curenv为当前env并且修改状态
	curenv = e;
f0103aa6:	89 83 24 23 00 00    	mov    %eax,0x2324(%ebx)
	curenv->env_status = ENV_RUNNING;
f0103aac:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103ab3:	83 40 58 01          	addl   $0x1,0x58(%eax)
	// 切换地址空间，恢复寄存器
	lcr3(PADDR(curenv->env_pgdir));
f0103ab7:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f0103aba:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103ac0:	77 26                	ja     f0103ae8 <env_run+0x67>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ac2:	52                   	push   %edx
f0103ac3:	8d 83 40 90 f7 ff    	lea    -0x86fc0(%ebx),%eax
f0103ac9:	50                   	push   %eax
f0103aca:	68 0b 02 00 00       	push   $0x20b
f0103acf:	8d 83 ae 97 f7 ff    	lea    -0x86852(%ebx),%eax
f0103ad5:	50                   	push   %eax
f0103ad6:	e8 dc c5 ff ff       	call   f01000b7 <_panic>
		curenv->env_status = ENV_RUNNABLE;
f0103adb:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
		curenv->env_runs--;
f0103ae2:	83 6a 58 01          	subl   $0x1,0x58(%edx)
f0103ae6:	eb be                	jmp    f0103aa6 <env_run+0x25>
	return (physaddr_t)kva - KERNBASE;
f0103ae8:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103aee:	0f 22 da             	mov    %edx,%cr3
	env_pop_tf(&curenv->env_tf);
f0103af1:	83 ec 0c             	sub    $0xc,%esp
f0103af4:	50                   	push   %eax
f0103af5:	e8 53 ff ff ff       	call   f0103a4d <env_pop_tf>

f0103afa <__x86.get_pc_thunk.si>:
f0103afa:	8b 34 24             	mov    (%esp),%esi
f0103afd:	c3                   	ret    

f0103afe <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103afe:	55                   	push   %ebp
f0103aff:	89 e5                	mov    %esp,%ebp
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103b01:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b04:	ba 70 00 00 00       	mov    $0x70,%edx
f0103b09:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103b0a:	ba 71 00 00 00       	mov    $0x71,%edx
f0103b0f:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103b10:	0f b6 c0             	movzbl %al,%eax
}
f0103b13:	5d                   	pop    %ebp
f0103b14:	c3                   	ret    

f0103b15 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103b15:	55                   	push   %ebp
f0103b16:	89 e5                	mov    %esp,%ebp
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103b18:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b1b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103b20:	ee                   	out    %al,(%dx)
f0103b21:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b24:	ba 71 00 00 00       	mov    $0x71,%edx
f0103b29:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103b2a:	5d                   	pop    %ebp
f0103b2b:	c3                   	ret    

f0103b2c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103b2c:	55                   	push   %ebp
f0103b2d:	89 e5                	mov    %esp,%ebp
f0103b2f:	53                   	push   %ebx
f0103b30:	83 ec 10             	sub    $0x10,%esp
f0103b33:	e8 35 c6 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0103b38:	81 c3 ec 94 08 00    	add    $0x894ec,%ebx
	cputchar(ch);
f0103b3e:	ff 75 08             	pushl  0x8(%ebp)
f0103b41:	e8 9f cb ff ff       	call   f01006e5 <cputchar>
	*cnt++;
}
f0103b46:	83 c4 10             	add    $0x10,%esp
f0103b49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b4c:	c9                   	leave  
f0103b4d:	c3                   	ret    

f0103b4e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103b4e:	55                   	push   %ebp
f0103b4f:	89 e5                	mov    %esp,%ebp
f0103b51:	53                   	push   %ebx
f0103b52:	83 ec 14             	sub    $0x14,%esp
f0103b55:	e8 13 c6 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0103b5a:	81 c3 ca 94 08 00    	add    $0x894ca,%ebx
	int cnt = 0;
f0103b60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103b67:	ff 75 0c             	pushl  0xc(%ebp)
f0103b6a:	ff 75 08             	pushl  0x8(%ebp)
f0103b6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b70:	50                   	push   %eax
f0103b71:	8d 83 08 6b f7 ff    	lea    -0x894f8(%ebx),%eax
f0103b77:	50                   	push   %eax
f0103b78:	e8 27 0f 00 00       	call   f0104aa4 <vprintfmt>
	return cnt;
}
f0103b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b83:	c9                   	leave  
f0103b84:	c3                   	ret    

f0103b85 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103b85:	55                   	push   %ebp
f0103b86:	89 e5                	mov    %esp,%ebp
f0103b88:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103b8b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103b8e:	50                   	push   %eax
f0103b8f:	ff 75 08             	pushl  0x8(%ebp)
f0103b92:	e8 b7 ff ff ff       	call   f0103b4e <vcprintf>
	va_end(ap);

	return cnt;
}
f0103b97:	c9                   	leave  
f0103b98:	c3                   	ret    

f0103b99 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103b99:	55                   	push   %ebp
f0103b9a:	89 e5                	mov    %esp,%ebp
f0103b9c:	57                   	push   %edi
f0103b9d:	56                   	push   %esi
f0103b9e:	53                   	push   %ebx
f0103b9f:	83 ec 04             	sub    $0x4,%esp
f0103ba2:	e8 c6 c5 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0103ba7:	81 c3 7d 94 08 00    	add    $0x8947d,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103bad:	c7 83 60 2b 00 00 00 	movl   $0xf0000000,0x2b60(%ebx)
f0103bb4:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103bb7:	66 c7 83 64 2b 00 00 	movw   $0x10,0x2b64(%ebx)
f0103bbe:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103bc0:	c7 c0 00 c3 11 f0    	mov    $0xf011c300,%eax
f0103bc6:	66 c7 40 28 68 00    	movw   $0x68,0x28(%eax)
f0103bcc:	8d b3 5c 2b 00 00    	lea    0x2b5c(%ebx),%esi
f0103bd2:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0103bd6:	89 f2                	mov    %esi,%edx
f0103bd8:	c1 ea 10             	shr    $0x10,%edx
f0103bdb:	88 50 2c             	mov    %dl,0x2c(%eax)
f0103bde:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f0103be2:	83 e2 f0             	and    $0xfffffff0,%edx
f0103be5:	83 ca 09             	or     $0x9,%edx
f0103be8:	83 e2 9f             	and    $0xffffff9f,%edx
f0103beb:	83 ca 80             	or     $0xffffff80,%edx
f0103bee:	88 55 f3             	mov    %dl,-0xd(%ebp)
f0103bf1:	88 50 2d             	mov    %dl,0x2d(%eax)
f0103bf4:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f0103bf8:	83 e1 c0             	and    $0xffffffc0,%ecx
f0103bfb:	83 c9 40             	or     $0x40,%ecx
f0103bfe:	83 e1 7f             	and    $0x7f,%ecx
f0103c01:	88 48 2e             	mov    %cl,0x2e(%eax)
f0103c04:	c1 ee 18             	shr    $0x18,%esi
f0103c07:	89 f1                	mov    %esi,%ecx
f0103c09:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103c0c:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f0103c10:	83 e2 ef             	and    $0xffffffef,%edx
f0103c13:	88 50 2d             	mov    %dl,0x2d(%eax)
	__asm __volatile("ltr %0" : : "r" (sel));
f0103c16:	b8 28 00 00 00       	mov    $0x28,%eax
f0103c1b:	0f 00 d8             	ltr    %ax
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103c1e:	8d 83 e4 1f 00 00    	lea    0x1fe4(%ebx),%eax
f0103c24:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103c27:	83 c4 04             	add    $0x4,%esp
f0103c2a:	5b                   	pop    %ebx
f0103c2b:	5e                   	pop    %esi
f0103c2c:	5f                   	pop    %edi
f0103c2d:	5d                   	pop    %ebp
f0103c2e:	c3                   	ret    

f0103c2f <trap_init>:
{
f0103c2f:	55                   	push   %ebp
f0103c30:	89 e5                	mov    %esp,%ebp
f0103c32:	e8 d9 ca ff ff       	call   f0100710 <__x86.get_pc_thunk.ax>
f0103c37:	05 ed 93 08 00       	add    $0x893ed,%eax
	SETGATE(idt[T_DIVIDE], 1, GD_KT, t_divide, 0);
f0103c3c:	c7 c2 fe 43 10 f0    	mov    $0xf01043fe,%edx
f0103c42:	66 89 90 3c 23 00 00 	mov    %dx,0x233c(%eax)
f0103c49:	66 c7 80 3e 23 00 00 	movw   $0x8,0x233e(%eax)
f0103c50:	08 00 
f0103c52:	c6 80 40 23 00 00 00 	movb   $0x0,0x2340(%eax)
f0103c59:	c6 80 41 23 00 00 8f 	movb   $0x8f,0x2341(%eax)
f0103c60:	c1 ea 10             	shr    $0x10,%edx
f0103c63:	66 89 90 42 23 00 00 	mov    %dx,0x2342(%eax)
	SETGATE(idt[T_DEBUG], 1, GD_KT, t_debug, 0);
f0103c6a:	c7 c2 04 44 10 f0    	mov    $0xf0104404,%edx
f0103c70:	66 89 90 44 23 00 00 	mov    %dx,0x2344(%eax)
f0103c77:	66 c7 80 46 23 00 00 	movw   $0x8,0x2346(%eax)
f0103c7e:	08 00 
f0103c80:	c6 80 48 23 00 00 00 	movb   $0x0,0x2348(%eax)
f0103c87:	c6 80 49 23 00 00 8f 	movb   $0x8f,0x2349(%eax)
f0103c8e:	c1 ea 10             	shr    $0x10,%edx
f0103c91:	66 89 90 4a 23 00 00 	mov    %dx,0x234a(%eax)
	SETGATE(idt[T_NMI], 1, GD_KT, t_nmi, 0);
f0103c98:	c7 c2 0a 44 10 f0    	mov    $0xf010440a,%edx
f0103c9e:	66 89 90 4c 23 00 00 	mov    %dx,0x234c(%eax)
f0103ca5:	66 c7 80 4e 23 00 00 	movw   $0x8,0x234e(%eax)
f0103cac:	08 00 
f0103cae:	c6 80 50 23 00 00 00 	movb   $0x0,0x2350(%eax)
f0103cb5:	c6 80 51 23 00 00 8f 	movb   $0x8f,0x2351(%eax)
f0103cbc:	c1 ea 10             	shr    $0x10,%edx
f0103cbf:	66 89 90 52 23 00 00 	mov    %dx,0x2352(%eax)
	SETGATE(idt[T_BRKPT], 1, GD_KT, t_brkpt, 3);
f0103cc6:	c7 c2 10 44 10 f0    	mov    $0xf0104410,%edx
f0103ccc:	66 89 90 54 23 00 00 	mov    %dx,0x2354(%eax)
f0103cd3:	66 c7 80 56 23 00 00 	movw   $0x8,0x2356(%eax)
f0103cda:	08 00 
f0103cdc:	c6 80 58 23 00 00 00 	movb   $0x0,0x2358(%eax)
f0103ce3:	c6 80 59 23 00 00 ef 	movb   $0xef,0x2359(%eax)
f0103cea:	c1 ea 10             	shr    $0x10,%edx
f0103ced:	66 89 90 5a 23 00 00 	mov    %dx,0x235a(%eax)
	SETGATE(idt[T_OFLOW], 1, GD_KT, t_oflow, 0);
f0103cf4:	c7 c2 16 44 10 f0    	mov    $0xf0104416,%edx
f0103cfa:	66 89 90 5c 23 00 00 	mov    %dx,0x235c(%eax)
f0103d01:	66 c7 80 5e 23 00 00 	movw   $0x8,0x235e(%eax)
f0103d08:	08 00 
f0103d0a:	c6 80 60 23 00 00 00 	movb   $0x0,0x2360(%eax)
f0103d11:	c6 80 61 23 00 00 8f 	movb   $0x8f,0x2361(%eax)
f0103d18:	c1 ea 10             	shr    $0x10,%edx
f0103d1b:	66 89 90 62 23 00 00 	mov    %dx,0x2362(%eax)
	SETGATE(idt[T_BOUND], 1, GD_KT, t_bound, 0);
f0103d22:	c7 c2 1c 44 10 f0    	mov    $0xf010441c,%edx
f0103d28:	66 89 90 64 23 00 00 	mov    %dx,0x2364(%eax)
f0103d2f:	66 c7 80 66 23 00 00 	movw   $0x8,0x2366(%eax)
f0103d36:	08 00 
f0103d38:	c6 80 68 23 00 00 00 	movb   $0x0,0x2368(%eax)
f0103d3f:	c6 80 69 23 00 00 8f 	movb   $0x8f,0x2369(%eax)
f0103d46:	c1 ea 10             	shr    $0x10,%edx
f0103d49:	66 89 90 6a 23 00 00 	mov    %dx,0x236a(%eax)
	SETGATE(idt[T_ILLOP], 1, GD_KT, t_illop, 0);
f0103d50:	c7 c2 22 44 10 f0    	mov    $0xf0104422,%edx
f0103d56:	66 89 90 6c 23 00 00 	mov    %dx,0x236c(%eax)
f0103d5d:	66 c7 80 6e 23 00 00 	movw   $0x8,0x236e(%eax)
f0103d64:	08 00 
f0103d66:	c6 80 70 23 00 00 00 	movb   $0x0,0x2370(%eax)
f0103d6d:	c6 80 71 23 00 00 8f 	movb   $0x8f,0x2371(%eax)
f0103d74:	c1 ea 10             	shr    $0x10,%edx
f0103d77:	66 89 90 72 23 00 00 	mov    %dx,0x2372(%eax)
	SETGATE(idt[T_DEVICE], 1, GD_KT, t_device, 0);
f0103d7e:	c7 c2 28 44 10 f0    	mov    $0xf0104428,%edx
f0103d84:	66 89 90 74 23 00 00 	mov    %dx,0x2374(%eax)
f0103d8b:	66 c7 80 76 23 00 00 	movw   $0x8,0x2376(%eax)
f0103d92:	08 00 
f0103d94:	c6 80 78 23 00 00 00 	movb   $0x0,0x2378(%eax)
f0103d9b:	c6 80 79 23 00 00 8f 	movb   $0x8f,0x2379(%eax)
f0103da2:	c1 ea 10             	shr    $0x10,%edx
f0103da5:	66 89 90 7a 23 00 00 	mov    %dx,0x237a(%eax)
	SETGATE(idt[T_DBLFLT], 1, GD_KT, t_dblflt, 0);
f0103dac:	c7 c2 2e 44 10 f0    	mov    $0xf010442e,%edx
f0103db2:	66 89 90 7c 23 00 00 	mov    %dx,0x237c(%eax)
f0103db9:	66 c7 80 7e 23 00 00 	movw   $0x8,0x237e(%eax)
f0103dc0:	08 00 
f0103dc2:	c6 80 80 23 00 00 00 	movb   $0x0,0x2380(%eax)
f0103dc9:	c6 80 81 23 00 00 8f 	movb   $0x8f,0x2381(%eax)
f0103dd0:	c1 ea 10             	shr    $0x10,%edx
f0103dd3:	66 89 90 82 23 00 00 	mov    %dx,0x2382(%eax)
	SETGATE(idt[T_TSS], 1, GD_KT, t_tss, 0);
f0103dda:	c7 c2 32 44 10 f0    	mov    $0xf0104432,%edx
f0103de0:	66 89 90 8c 23 00 00 	mov    %dx,0x238c(%eax)
f0103de7:	66 c7 80 8e 23 00 00 	movw   $0x8,0x238e(%eax)
f0103dee:	08 00 
f0103df0:	c6 80 90 23 00 00 00 	movb   $0x0,0x2390(%eax)
f0103df7:	c6 80 91 23 00 00 8f 	movb   $0x8f,0x2391(%eax)
f0103dfe:	c1 ea 10             	shr    $0x10,%edx
f0103e01:	66 89 90 92 23 00 00 	mov    %dx,0x2392(%eax)
	SETGATE(idt[T_SEGNP], 1, GD_KT, t_segnp, 0);
f0103e08:	c7 c2 36 44 10 f0    	mov    $0xf0104436,%edx
f0103e0e:	66 89 90 94 23 00 00 	mov    %dx,0x2394(%eax)
f0103e15:	66 c7 80 96 23 00 00 	movw   $0x8,0x2396(%eax)
f0103e1c:	08 00 
f0103e1e:	c6 80 98 23 00 00 00 	movb   $0x0,0x2398(%eax)
f0103e25:	c6 80 99 23 00 00 8f 	movb   $0x8f,0x2399(%eax)
f0103e2c:	c1 ea 10             	shr    $0x10,%edx
f0103e2f:	66 89 90 9a 23 00 00 	mov    %dx,0x239a(%eax)
	SETGATE(idt[T_STACK], 1, GD_KT, t_stack, 0);
f0103e36:	c7 c2 3c 44 10 f0    	mov    $0xf010443c,%edx
f0103e3c:	66 89 90 9c 23 00 00 	mov    %dx,0x239c(%eax)
f0103e43:	66 c7 80 9e 23 00 00 	movw   $0x8,0x239e(%eax)
f0103e4a:	08 00 
f0103e4c:	c6 80 a0 23 00 00 00 	movb   $0x0,0x23a0(%eax)
f0103e53:	c6 80 a1 23 00 00 8f 	movb   $0x8f,0x23a1(%eax)
f0103e5a:	c1 ea 10             	shr    $0x10,%edx
f0103e5d:	66 89 90 a2 23 00 00 	mov    %dx,0x23a2(%eax)
	SETGATE(idt[T_GPFLT], 1, GD_KT, t_gpflt, 0);
f0103e64:	c7 c2 40 44 10 f0    	mov    $0xf0104440,%edx
f0103e6a:	66 89 90 a4 23 00 00 	mov    %dx,0x23a4(%eax)
f0103e71:	66 c7 80 a6 23 00 00 	movw   $0x8,0x23a6(%eax)
f0103e78:	08 00 
f0103e7a:	c6 80 a8 23 00 00 00 	movb   $0x0,0x23a8(%eax)
f0103e81:	c6 80 a9 23 00 00 8f 	movb   $0x8f,0x23a9(%eax)
f0103e88:	c1 ea 10             	shr    $0x10,%edx
f0103e8b:	66 89 90 aa 23 00 00 	mov    %dx,0x23aa(%eax)
	SETGATE(idt[T_PGFLT], 1, GD_KT, t_pgflt, 0);
f0103e92:	c7 c2 44 44 10 f0    	mov    $0xf0104444,%edx
f0103e98:	66 89 90 ac 23 00 00 	mov    %dx,0x23ac(%eax)
f0103e9f:	66 c7 80 ae 23 00 00 	movw   $0x8,0x23ae(%eax)
f0103ea6:	08 00 
f0103ea8:	c6 80 b0 23 00 00 00 	movb   $0x0,0x23b0(%eax)
f0103eaf:	c6 80 b1 23 00 00 8f 	movb   $0x8f,0x23b1(%eax)
f0103eb6:	c1 ea 10             	shr    $0x10,%edx
f0103eb9:	66 89 90 b2 23 00 00 	mov    %dx,0x23b2(%eax)
	SETGATE(idt[T_FPERR], 1, GD_KT, t_fperr, 0);
f0103ec0:	c7 c2 48 44 10 f0    	mov    $0xf0104448,%edx
f0103ec6:	66 89 90 bc 23 00 00 	mov    %dx,0x23bc(%eax)
f0103ecd:	66 c7 80 be 23 00 00 	movw   $0x8,0x23be(%eax)
f0103ed4:	08 00 
f0103ed6:	c6 80 c0 23 00 00 00 	movb   $0x0,0x23c0(%eax)
f0103edd:	c6 80 c1 23 00 00 8f 	movb   $0x8f,0x23c1(%eax)
f0103ee4:	c1 ea 10             	shr    $0x10,%edx
f0103ee7:	66 89 90 c2 23 00 00 	mov    %dx,0x23c2(%eax)
	SETGATE(idt[T_ALIGN], 1, GD_KT, t_align, 0);
f0103eee:	c7 c2 4e 44 10 f0    	mov    $0xf010444e,%edx
f0103ef4:	66 89 90 c4 23 00 00 	mov    %dx,0x23c4(%eax)
f0103efb:	66 c7 80 c6 23 00 00 	movw   $0x8,0x23c6(%eax)
f0103f02:	08 00 
f0103f04:	c6 80 c8 23 00 00 00 	movb   $0x0,0x23c8(%eax)
f0103f0b:	c6 80 c9 23 00 00 8f 	movb   $0x8f,0x23c9(%eax)
f0103f12:	c1 ea 10             	shr    $0x10,%edx
f0103f15:	66 89 90 ca 23 00 00 	mov    %dx,0x23ca(%eax)
	SETGATE(idt[T_MCHK], 1, GD_KT, t_mchk, 0);
f0103f1c:	c7 c2 52 44 10 f0    	mov    $0xf0104452,%edx
f0103f22:	66 89 90 cc 23 00 00 	mov    %dx,0x23cc(%eax)
f0103f29:	66 c7 80 ce 23 00 00 	movw   $0x8,0x23ce(%eax)
f0103f30:	08 00 
f0103f32:	c6 80 d0 23 00 00 00 	movb   $0x0,0x23d0(%eax)
f0103f39:	c6 80 d1 23 00 00 8f 	movb   $0x8f,0x23d1(%eax)
f0103f40:	c1 ea 10             	shr    $0x10,%edx
f0103f43:	66 89 90 d2 23 00 00 	mov    %dx,0x23d2(%eax)
	SETGATE(idt[T_SIMDERR], 1, GD_KT, t_simderr, 0);
f0103f4a:	c7 c2 58 44 10 f0    	mov    $0xf0104458,%edx
f0103f50:	66 89 90 d4 23 00 00 	mov    %dx,0x23d4(%eax)
f0103f57:	66 c7 80 d6 23 00 00 	movw   $0x8,0x23d6(%eax)
f0103f5e:	08 00 
f0103f60:	c6 80 d8 23 00 00 00 	movb   $0x0,0x23d8(%eax)
f0103f67:	c6 80 d9 23 00 00 8f 	movb   $0x8f,0x23d9(%eax)
f0103f6e:	c1 ea 10             	shr    $0x10,%edx
f0103f71:	66 89 90 da 23 00 00 	mov    %dx,0x23da(%eax)
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0103f78:	c7 c2 5e 44 10 f0    	mov    $0xf010445e,%edx
f0103f7e:	66 89 90 bc 24 00 00 	mov    %dx,0x24bc(%eax)
f0103f85:	66 c7 80 be 24 00 00 	movw   $0x8,0x24be(%eax)
f0103f8c:	08 00 
f0103f8e:	c6 80 c0 24 00 00 00 	movb   $0x0,0x24c0(%eax)
f0103f95:	c6 80 c1 24 00 00 ee 	movb   $0xee,0x24c1(%eax)
f0103f9c:	c1 ea 10             	shr    $0x10,%edx
f0103f9f:	66 89 90 c2 24 00 00 	mov    %dx,0x24c2(%eax)
	trap_init_percpu();
f0103fa6:	e8 ee fb ff ff       	call   f0103b99 <trap_init_percpu>
}
f0103fab:	5d                   	pop    %ebp
f0103fac:	c3                   	ret    

f0103fad <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103fad:	55                   	push   %ebp
f0103fae:	89 e5                	mov    %esp,%ebp
f0103fb0:	56                   	push   %esi
f0103fb1:	53                   	push   %ebx
f0103fb2:	e8 b6 c1 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0103fb7:	81 c3 6d 90 08 00    	add    $0x8906d,%ebx
f0103fbd:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103fc0:	83 ec 08             	sub    $0x8,%esp
f0103fc3:	ff 36                	pushl  (%esi)
f0103fc5:	8d 83 28 98 f7 ff    	lea    -0x867d8(%ebx),%eax
f0103fcb:	50                   	push   %eax
f0103fcc:	e8 b4 fb ff ff       	call   f0103b85 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103fd1:	83 c4 08             	add    $0x8,%esp
f0103fd4:	ff 76 04             	pushl  0x4(%esi)
f0103fd7:	8d 83 37 98 f7 ff    	lea    -0x867c9(%ebx),%eax
f0103fdd:	50                   	push   %eax
f0103fde:	e8 a2 fb ff ff       	call   f0103b85 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103fe3:	83 c4 08             	add    $0x8,%esp
f0103fe6:	ff 76 08             	pushl  0x8(%esi)
f0103fe9:	8d 83 46 98 f7 ff    	lea    -0x867ba(%ebx),%eax
f0103fef:	50                   	push   %eax
f0103ff0:	e8 90 fb ff ff       	call   f0103b85 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103ff5:	83 c4 08             	add    $0x8,%esp
f0103ff8:	ff 76 0c             	pushl  0xc(%esi)
f0103ffb:	8d 83 55 98 f7 ff    	lea    -0x867ab(%ebx),%eax
f0104001:	50                   	push   %eax
f0104002:	e8 7e fb ff ff       	call   f0103b85 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104007:	83 c4 08             	add    $0x8,%esp
f010400a:	ff 76 10             	pushl  0x10(%esi)
f010400d:	8d 83 64 98 f7 ff    	lea    -0x8679c(%ebx),%eax
f0104013:	50                   	push   %eax
f0104014:	e8 6c fb ff ff       	call   f0103b85 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104019:	83 c4 08             	add    $0x8,%esp
f010401c:	ff 76 14             	pushl  0x14(%esi)
f010401f:	8d 83 73 98 f7 ff    	lea    -0x8678d(%ebx),%eax
f0104025:	50                   	push   %eax
f0104026:	e8 5a fb ff ff       	call   f0103b85 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010402b:	83 c4 08             	add    $0x8,%esp
f010402e:	ff 76 18             	pushl  0x18(%esi)
f0104031:	8d 83 82 98 f7 ff    	lea    -0x8677e(%ebx),%eax
f0104037:	50                   	push   %eax
f0104038:	e8 48 fb ff ff       	call   f0103b85 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010403d:	83 c4 08             	add    $0x8,%esp
f0104040:	ff 76 1c             	pushl  0x1c(%esi)
f0104043:	8d 83 91 98 f7 ff    	lea    -0x8676f(%ebx),%eax
f0104049:	50                   	push   %eax
f010404a:	e8 36 fb ff ff       	call   f0103b85 <cprintf>
}
f010404f:	83 c4 10             	add    $0x10,%esp
f0104052:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104055:	5b                   	pop    %ebx
f0104056:	5e                   	pop    %esi
f0104057:	5d                   	pop    %ebp
f0104058:	c3                   	ret    

f0104059 <print_trapframe>:
{
f0104059:	55                   	push   %ebp
f010405a:	89 e5                	mov    %esp,%ebp
f010405c:	57                   	push   %edi
f010405d:	56                   	push   %esi
f010405e:	53                   	push   %ebx
f010405f:	83 ec 14             	sub    $0x14,%esp
f0104062:	e8 06 c1 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0104067:	81 c3 bd 8f 08 00    	add    $0x88fbd,%ebx
f010406d:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f0104070:	56                   	push   %esi
f0104071:	8d 83 c7 99 f7 ff    	lea    -0x86639(%ebx),%eax
f0104077:	50                   	push   %eax
f0104078:	e8 08 fb ff ff       	call   f0103b85 <cprintf>
	print_regs(&tf->tf_regs);
f010407d:	89 34 24             	mov    %esi,(%esp)
f0104080:	e8 28 ff ff ff       	call   f0103fad <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104085:	83 c4 08             	add    $0x8,%esp
f0104088:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f010408c:	50                   	push   %eax
f010408d:	8d 83 e2 98 f7 ff    	lea    -0x8671e(%ebx),%eax
f0104093:	50                   	push   %eax
f0104094:	e8 ec fa ff ff       	call   f0103b85 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104099:	83 c4 08             	add    $0x8,%esp
f010409c:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f01040a0:	50                   	push   %eax
f01040a1:	8d 83 f5 98 f7 ff    	lea    -0x8670b(%ebx),%eax
f01040a7:	50                   	push   %eax
f01040a8:	e8 d8 fa ff ff       	call   f0103b85 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01040ad:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01040b0:	83 c4 10             	add    $0x10,%esp
f01040b3:	83 fa 13             	cmp    $0x13,%edx
f01040b6:	0f 86 e9 00 00 00    	jbe    f01041a5 <print_trapframe+0x14c>
	return "(unknown trap)";
f01040bc:	83 fa 30             	cmp    $0x30,%edx
f01040bf:	8d 83 a0 98 f7 ff    	lea    -0x86760(%ebx),%eax
f01040c5:	8d 8b ac 98 f7 ff    	lea    -0x86754(%ebx),%ecx
f01040cb:	0f 45 c1             	cmovne %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01040ce:	83 ec 04             	sub    $0x4,%esp
f01040d1:	50                   	push   %eax
f01040d2:	52                   	push   %edx
f01040d3:	8d 83 08 99 f7 ff    	lea    -0x866f8(%ebx),%eax
f01040d9:	50                   	push   %eax
f01040da:	e8 a6 fa ff ff       	call   f0103b85 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01040df:	83 c4 10             	add    $0x10,%esp
f01040e2:	39 b3 3c 2b 00 00    	cmp    %esi,0x2b3c(%ebx)
f01040e8:	0f 84 c3 00 00 00    	je     f01041b1 <print_trapframe+0x158>
	cprintf("  err  0x%08x", tf->tf_err);
f01040ee:	83 ec 08             	sub    $0x8,%esp
f01040f1:	ff 76 2c             	pushl  0x2c(%esi)
f01040f4:	8d 83 29 99 f7 ff    	lea    -0x866d7(%ebx),%eax
f01040fa:	50                   	push   %eax
f01040fb:	e8 85 fa ff ff       	call   f0103b85 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104100:	83 c4 10             	add    $0x10,%esp
f0104103:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0104107:	0f 85 c9 00 00 00    	jne    f01041d6 <print_trapframe+0x17d>
			tf->tf_err & 1 ? "protection" : "not-present");
f010410d:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f0104110:	89 c2                	mov    %eax,%edx
f0104112:	83 e2 01             	and    $0x1,%edx
f0104115:	8d 8b bb 98 f7 ff    	lea    -0x86745(%ebx),%ecx
f010411b:	8d 93 c6 98 f7 ff    	lea    -0x8673a(%ebx),%edx
f0104121:	0f 44 ca             	cmove  %edx,%ecx
f0104124:	89 c2                	mov    %eax,%edx
f0104126:	83 e2 02             	and    $0x2,%edx
f0104129:	8d 93 d2 98 f7 ff    	lea    -0x8672e(%ebx),%edx
f010412f:	8d bb d8 98 f7 ff    	lea    -0x86728(%ebx),%edi
f0104135:	0f 44 d7             	cmove  %edi,%edx
f0104138:	83 e0 04             	and    $0x4,%eax
f010413b:	8d 83 dd 98 f7 ff    	lea    -0x86723(%ebx),%eax
f0104141:	8d bb f2 99 f7 ff    	lea    -0x8660e(%ebx),%edi
f0104147:	0f 44 c7             	cmove  %edi,%eax
f010414a:	51                   	push   %ecx
f010414b:	52                   	push   %edx
f010414c:	50                   	push   %eax
f010414d:	8d 83 37 99 f7 ff    	lea    -0x866c9(%ebx),%eax
f0104153:	50                   	push   %eax
f0104154:	e8 2c fa ff ff       	call   f0103b85 <cprintf>
f0104159:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010415c:	83 ec 08             	sub    $0x8,%esp
f010415f:	ff 76 30             	pushl  0x30(%esi)
f0104162:	8d 83 46 99 f7 ff    	lea    -0x866ba(%ebx),%eax
f0104168:	50                   	push   %eax
f0104169:	e8 17 fa ff ff       	call   f0103b85 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010416e:	83 c4 08             	add    $0x8,%esp
f0104171:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104175:	50                   	push   %eax
f0104176:	8d 83 55 99 f7 ff    	lea    -0x866ab(%ebx),%eax
f010417c:	50                   	push   %eax
f010417d:	e8 03 fa ff ff       	call   f0103b85 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104182:	83 c4 08             	add    $0x8,%esp
f0104185:	ff 76 38             	pushl  0x38(%esi)
f0104188:	8d 83 68 99 f7 ff    	lea    -0x86698(%ebx),%eax
f010418e:	50                   	push   %eax
f010418f:	e8 f1 f9 ff ff       	call   f0103b85 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104194:	83 c4 10             	add    $0x10,%esp
f0104197:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f010419b:	75 50                	jne    f01041ed <print_trapframe+0x194>
}
f010419d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01041a0:	5b                   	pop    %ebx
f01041a1:	5e                   	pop    %esi
f01041a2:	5f                   	pop    %edi
f01041a3:	5d                   	pop    %ebp
f01041a4:	c3                   	ret    
		return excnames[trapno];
f01041a5:	8b 84 93 5c 20 00 00 	mov    0x205c(%ebx,%edx,4),%eax
f01041ac:	e9 1d ff ff ff       	jmp    f01040ce <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01041b1:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f01041b5:	0f 85 33 ff ff ff    	jne    f01040ee <print_trapframe+0x95>
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01041bb:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01041be:	83 ec 08             	sub    $0x8,%esp
f01041c1:	50                   	push   %eax
f01041c2:	8d 83 1a 99 f7 ff    	lea    -0x866e6(%ebx),%eax
f01041c8:	50                   	push   %eax
f01041c9:	e8 b7 f9 ff ff       	call   f0103b85 <cprintf>
f01041ce:	83 c4 10             	add    $0x10,%esp
f01041d1:	e9 18 ff ff ff       	jmp    f01040ee <print_trapframe+0x95>
		cprintf("\n");
f01041d6:	83 ec 0c             	sub    $0xc,%esp
f01041d9:	8d 83 24 8f f7 ff    	lea    -0x870dc(%ebx),%eax
f01041df:	50                   	push   %eax
f01041e0:	e8 a0 f9 ff ff       	call   f0103b85 <cprintf>
f01041e5:	83 c4 10             	add    $0x10,%esp
f01041e8:	e9 6f ff ff ff       	jmp    f010415c <print_trapframe+0x103>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01041ed:	83 ec 08             	sub    $0x8,%esp
f01041f0:	ff 76 3c             	pushl  0x3c(%esi)
f01041f3:	8d 83 77 99 f7 ff    	lea    -0x86689(%ebx),%eax
f01041f9:	50                   	push   %eax
f01041fa:	e8 86 f9 ff ff       	call   f0103b85 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01041ff:	83 c4 08             	add    $0x8,%esp
f0104202:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f0104206:	50                   	push   %eax
f0104207:	8d 83 86 99 f7 ff    	lea    -0x8667a(%ebx),%eax
f010420d:	50                   	push   %eax
f010420e:	e8 72 f9 ff ff       	call   f0103b85 <cprintf>
f0104213:	83 c4 10             	add    $0x10,%esp
}
f0104216:	eb 85                	jmp    f010419d <print_trapframe+0x144>

f0104218 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104218:	55                   	push   %ebp
f0104219:	89 e5                	mov    %esp,%ebp
f010421b:	57                   	push   %edi
f010421c:	56                   	push   %esi
f010421d:	53                   	push   %ebx
f010421e:	83 ec 0c             	sub    $0xc,%esp
f0104221:	e8 47 bf ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0104226:	81 c3 fe 8d 08 00    	add    $0x88dfe,%ebx
f010422c:	8b 75 08             	mov    0x8(%ebp),%esi
f010422f:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if(!(tf->tf_cs & 3))
f0104232:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0104236:	74 38                	je     f0104270 <page_fault_handler+0x58>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104238:	ff 76 30             	pushl  0x30(%esi)
f010423b:	50                   	push   %eax
f010423c:	c7 c7 48 f3 18 f0    	mov    $0xf018f348,%edi
f0104242:	8b 07                	mov    (%edi),%eax
f0104244:	ff 70 48             	pushl  0x48(%eax)
f0104247:	8d 83 74 9b f7 ff    	lea    -0x8648c(%ebx),%eax
f010424d:	50                   	push   %eax
f010424e:	e8 32 f9 ff ff       	call   f0103b85 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104253:	89 34 24             	mov    %esi,(%esp)
f0104256:	e8 fe fd ff ff       	call   f0104059 <print_trapframe>
	env_destroy(curenv);
f010425b:	83 c4 04             	add    $0x4,%esp
f010425e:	ff 37                	pushl  (%edi)
f0104260:	e8 ae f7 ff ff       	call   f0103a13 <env_destroy>
}
f0104265:	83 c4 10             	add    $0x10,%esp
f0104268:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010426b:	5b                   	pop    %ebx
f010426c:	5e                   	pop    %esi
f010426d:	5f                   	pop    %edi
f010426e:	5d                   	pop    %ebp
f010426f:	c3                   	ret    
		panic("page_fault_handler: a page fault occurred in the kernel");
f0104270:	83 ec 04             	sub    $0x4,%esp
f0104273:	8d 83 3c 9b f7 ff    	lea    -0x864c4(%ebx),%eax
f0104279:	50                   	push   %eax
f010427a:	68 09 01 00 00       	push   $0x109
f010427f:	8d 83 99 99 f7 ff    	lea    -0x86667(%ebx),%eax
f0104285:	50                   	push   %eax
f0104286:	e8 2c be ff ff       	call   f01000b7 <_panic>

f010428b <trap>:
{
f010428b:	55                   	push   %ebp
f010428c:	89 e5                	mov    %esp,%ebp
f010428e:	57                   	push   %edi
f010428f:	56                   	push   %esi
f0104290:	53                   	push   %ebx
f0104291:	83 ec 0c             	sub    $0xc,%esp
f0104294:	e8 d4 be ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0104299:	81 c3 8b 8d 08 00    	add    $0x88d8b,%ebx
f010429f:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f01042a2:	fc                   	cld    
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01042a3:	9c                   	pushf  
f01042a4:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f01042a5:	f6 c4 02             	test   $0x2,%ah
f01042a8:	74 1f                	je     f01042c9 <trap+0x3e>
f01042aa:	8d 83 a5 99 f7 ff    	lea    -0x8665b(%ebx),%eax
f01042b0:	50                   	push   %eax
f01042b1:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f01042b7:	50                   	push   %eax
f01042b8:	68 e0 00 00 00       	push   $0xe0
f01042bd:	8d 83 99 99 f7 ff    	lea    -0x86667(%ebx),%eax
f01042c3:	50                   	push   %eax
f01042c4:	e8 ee bd ff ff       	call   f01000b7 <_panic>
	cprintf("Incoming TRAP frame at %p\n", tf);
f01042c9:	83 ec 08             	sub    $0x8,%esp
f01042cc:	56                   	push   %esi
f01042cd:	8d 83 be 99 f7 ff    	lea    -0x86642(%ebx),%eax
f01042d3:	50                   	push   %eax
f01042d4:	e8 ac f8 ff ff       	call   f0103b85 <cprintf>
	if ((tf->tf_cs & 3) == 3) {
f01042d9:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01042dd:	83 e0 03             	and    $0x3,%eax
f01042e0:	83 c4 10             	add    $0x10,%esp
f01042e3:	66 83 f8 03          	cmp    $0x3,%ax
f01042e7:	75 1d                	jne    f0104306 <trap+0x7b>
		assert(curenv);
f01042e9:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f01042ef:	8b 00                	mov    (%eax),%eax
f01042f1:	85 c0                	test   %eax,%eax
f01042f3:	74 5d                	je     f0104352 <trap+0xc7>
		curenv->env_tf = *tf;
f01042f5:	b9 11 00 00 00       	mov    $0x11,%ecx
f01042fa:	89 c7                	mov    %eax,%edi
f01042fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01042fe:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f0104304:	8b 30                	mov    (%eax),%esi
	last_tf = tf;
f0104306:	89 b3 3c 2b 00 00    	mov    %esi,0x2b3c(%ebx)
	switch(tf->tf_trapno){
f010430c:	8b 46 28             	mov    0x28(%esi),%eax
f010430f:	83 f8 0e             	cmp    $0xe,%eax
f0104312:	0f 84 96 00 00 00    	je     f01043ae <trap+0x123>
f0104318:	83 f8 30             	cmp    $0x30,%eax
f010431b:	0f 84 9b 00 00 00    	je     f01043bc <trap+0x131>
f0104321:	83 f8 03             	cmp    $0x3,%eax
f0104324:	74 4b                	je     f0104371 <trap+0xe6>
			print_trapframe(tf);
f0104326:	83 ec 0c             	sub    $0xc,%esp
f0104329:	56                   	push   %esi
f010432a:	e8 2a fd ff ff       	call   f0104059 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f010432f:	83 c4 10             	add    $0x10,%esp
f0104332:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104337:	0f 84 9d 00 00 00    	je     f01043da <trap+0x14f>
				env_destroy(curenv);
f010433d:	83 ec 0c             	sub    $0xc,%esp
f0104340:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f0104346:	ff 30                	pushl  (%eax)
f0104348:	e8 c6 f6 ff ff       	call   f0103a13 <env_destroy>
f010434d:	83 c4 10             	add    $0x10,%esp
f0104350:	eb 2b                	jmp    f010437d <trap+0xf2>
		assert(curenv);
f0104352:	8d 83 d9 99 f7 ff    	lea    -0x86627(%ebx),%eax
f0104358:	50                   	push   %eax
f0104359:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010435f:	50                   	push   %eax
f0104360:	68 e6 00 00 00       	push   $0xe6
f0104365:	8d 83 99 99 f7 ff    	lea    -0x86667(%ebx),%eax
f010436b:	50                   	push   %eax
f010436c:	e8 46 bd ff ff       	call   f01000b7 <_panic>
			monitor(tf);
f0104371:	83 ec 0c             	sub    $0xc,%esp
f0104374:	56                   	push   %esi
f0104375:	e8 b6 c5 ff ff       	call   f0100930 <monitor>
f010437a:	83 c4 10             	add    $0x10,%esp
	assert(curenv && curenv->env_status == ENV_RUNNING);
f010437d:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f0104383:	8b 00                	mov    (%eax),%eax
f0104385:	85 c0                	test   %eax,%eax
f0104387:	74 06                	je     f010438f <trap+0x104>
f0104389:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010438d:	74 66                	je     f01043f5 <trap+0x16a>
f010438f:	8d 83 98 9b f7 ff    	lea    -0x86468(%ebx),%eax
f0104395:	50                   	push   %eax
f0104396:	8d 83 ba 8c f7 ff    	lea    -0x87346(%ebx),%eax
f010439c:	50                   	push   %eax
f010439d:	68 f8 00 00 00       	push   $0xf8
f01043a2:	8d 83 99 99 f7 ff    	lea    -0x86667(%ebx),%eax
f01043a8:	50                   	push   %eax
f01043a9:	e8 09 bd ff ff       	call   f01000b7 <_panic>
			page_fault_handler(tf);
f01043ae:	83 ec 0c             	sub    $0xc,%esp
f01043b1:	56                   	push   %esi
f01043b2:	e8 61 fe ff ff       	call   f0104218 <page_fault_handler>
f01043b7:	83 c4 10             	add    $0x10,%esp
f01043ba:	eb c1                	jmp    f010437d <trap+0xf2>
			syscall(eax, edx, ecx, ebx, edi, esi);
f01043bc:	83 ec 08             	sub    $0x8,%esp
f01043bf:	ff 76 04             	pushl  0x4(%esi)
f01043c2:	ff 36                	pushl  (%esi)
f01043c4:	ff 76 10             	pushl  0x10(%esi)
f01043c7:	ff 76 18             	pushl  0x18(%esi)
f01043ca:	ff 76 14             	pushl  0x14(%esi)
f01043cd:	ff 76 1c             	pushl  0x1c(%esi)
f01043d0:	e8 9e 00 00 00       	call   f0104473 <syscall>
f01043d5:	83 c4 20             	add    $0x20,%esp
f01043d8:	eb a3                	jmp    f010437d <trap+0xf2>
				panic("unhandled trap in kernel");
f01043da:	83 ec 04             	sub    $0x4,%esp
f01043dd:	8d 83 e0 99 f7 ff    	lea    -0x86620(%ebx),%eax
f01043e3:	50                   	push   %eax
f01043e4:	68 cf 00 00 00       	push   $0xcf
f01043e9:	8d 83 99 99 f7 ff    	lea    -0x86667(%ebx),%eax
f01043ef:	50                   	push   %eax
f01043f0:	e8 c2 bc ff ff       	call   f01000b7 <_panic>
	env_run(curenv);
f01043f5:	83 ec 0c             	sub    $0xc,%esp
f01043f8:	50                   	push   %eax
f01043f9:	e8 83 f6 ff ff       	call   f0103a81 <env_run>

f01043fe <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f01043fe:	6a 00                	push   $0x0
f0104400:	6a 00                	push   $0x0
f0104402:	eb 60                	jmp    f0104464 <_alltraps>

f0104404 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0104404:	6a 00                	push   $0x0
f0104406:	6a 01                	push   $0x1
f0104408:	eb 5a                	jmp    f0104464 <_alltraps>

f010440a <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f010440a:	6a 00                	push   $0x0
f010440c:	6a 02                	push   $0x2
f010440e:	eb 54                	jmp    f0104464 <_alltraps>

f0104410 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f0104410:	6a 00                	push   $0x0
f0104412:	6a 03                	push   $0x3
f0104414:	eb 4e                	jmp    f0104464 <_alltraps>

f0104416 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f0104416:	6a 00                	push   $0x0
f0104418:	6a 04                	push   $0x4
f010441a:	eb 48                	jmp    f0104464 <_alltraps>

f010441c <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f010441c:	6a 00                	push   $0x0
f010441e:	6a 05                	push   $0x5
f0104420:	eb 42                	jmp    f0104464 <_alltraps>

f0104422 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f0104422:	6a 00                	push   $0x0
f0104424:	6a 06                	push   $0x6
f0104426:	eb 3c                	jmp    f0104464 <_alltraps>

f0104428 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f0104428:	6a 00                	push   $0x0
f010442a:	6a 07                	push   $0x7
f010442c:	eb 36                	jmp    f0104464 <_alltraps>

f010442e <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f010442e:	6a 08                	push   $0x8
f0104430:	eb 32                	jmp    f0104464 <_alltraps>

f0104432 <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f0104432:	6a 0a                	push   $0xa
f0104434:	eb 2e                	jmp    f0104464 <_alltraps>

f0104436 <t_segnp>:
TRAPHANDLER_NOEC(t_segnp, T_SEGNP)
f0104436:	6a 00                	push   $0x0
f0104438:	6a 0b                	push   $0xb
f010443a:	eb 28                	jmp    f0104464 <_alltraps>

f010443c <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f010443c:	6a 0c                	push   $0xc
f010443e:	eb 24                	jmp    f0104464 <_alltraps>

f0104440 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f0104440:	6a 0d                	push   $0xd
f0104442:	eb 20                	jmp    f0104464 <_alltraps>

f0104444 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f0104444:	6a 0e                	push   $0xe
f0104446:	eb 1c                	jmp    f0104464 <_alltraps>

f0104448 <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f0104448:	6a 00                	push   $0x0
f010444a:	6a 10                	push   $0x10
f010444c:	eb 16                	jmp    f0104464 <_alltraps>

f010444e <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f010444e:	6a 11                	push   $0x11
f0104450:	eb 12                	jmp    f0104464 <_alltraps>

f0104452 <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f0104452:	6a 00                	push   $0x0
f0104454:	6a 12                	push   $0x12
f0104456:	eb 0c                	jmp    f0104464 <_alltraps>

f0104458 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f0104458:	6a 00                	push   $0x0
f010445a:	6a 13                	push   $0x13
f010445c:	eb 06                	jmp    f0104464 <_alltraps>

f010445e <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f010445e:	6a 00                	push   $0x0
f0104460:	6a 30                	push   $0x30
f0104462:	eb 00                	jmp    f0104464 <_alltraps>

f0104464 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
// 构造trapframe
	pushl %ds
f0104464:	1e                   	push   %ds
	pushl %es
f0104465:	06                   	push   %es
	pushal
f0104466:	60                   	pusha  
	// 将GD_KD加载到ds和es寄存器
	movl %ss, %eax
f0104467:	8c d0                	mov    %ss,%eax
	movw %ax, %ds
f0104469:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f010446b:	8e c0                	mov    %eax,%es
	// 传递trapframe指针给trap参数
	pushl %esp
f010446d:	54                   	push   %esp
	// 调用trap
	call trap
f010446e:	e8 18 fe ff ff       	call   f010428b <trap>

f0104473 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104473:	55                   	push   %ebp
f0104474:	89 e5                	mov    %esp,%ebp
f0104476:	53                   	push   %ebx
f0104477:	83 ec 14             	sub    $0x14,%esp
f010447a:	e8 ee bc ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f010447f:	81 c3 a5 8b 08 00    	add    $0x88ba5,%ebx
f0104485:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch(syscallno){
f0104488:	83 f8 01             	cmp    $0x1,%eax
f010448b:	74 4d                	je     f01044da <syscall+0x67>
f010448d:	83 f8 01             	cmp    $0x1,%eax
f0104490:	72 11                	jb     f01044a3 <syscall+0x30>
f0104492:	83 f8 02             	cmp    $0x2,%eax
f0104495:	74 4a                	je     f01044e1 <syscall+0x6e>
f0104497:	83 f8 03             	cmp    $0x3,%eax
f010449a:	74 52                	je     f01044ee <syscall+0x7b>
		case SYS_getenvid:
			return sys_getenvid();
		case SYS_env_destroy:
			return sys_env_destroy(a1);
		default:
			return -E_INVAL;
f010449c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01044a1:	eb 32                	jmp    f01044d5 <syscall+0x62>
	user_mem_assert(curenv, (void *)s, len, 0);
f01044a3:	6a 00                	push   $0x0
f01044a5:	ff 75 10             	pushl  0x10(%ebp)
f01044a8:	ff 75 0c             	pushl  0xc(%ebp)
f01044ab:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f01044b1:	ff 30                	pushl  (%eax)
f01044b3:	e8 20 ee ff ff       	call   f01032d8 <user_mem_assert>
	cprintf("%.*s", len, s);
f01044b8:	83 c4 0c             	add    $0xc,%esp
f01044bb:	ff 75 0c             	pushl  0xc(%ebp)
f01044be:	ff 75 10             	pushl  0x10(%ebp)
f01044c1:	8d 83 c4 9b f7 ff    	lea    -0x8643c(%ebx),%eax
f01044c7:	50                   	push   %eax
f01044c8:	e8 b8 f6 ff ff       	call   f0103b85 <cprintf>
f01044cd:	83 c4 10             	add    $0x10,%esp
			return 0;
f01044d0:	b8 00 00 00 00       	mov    $0x0,%eax
	}
}
f01044d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01044d8:	c9                   	leave  
f01044d9:	c3                   	ret    
	return cons_getc();
f01044da:	e8 8a c0 ff ff       	call   f0100569 <cons_getc>
			return sys_cgetc();
f01044df:	eb f4                	jmp    f01044d5 <syscall+0x62>
	return curenv->env_id;
f01044e1:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f01044e7:	8b 00                	mov    (%eax),%eax
f01044e9:	8b 40 48             	mov    0x48(%eax),%eax
			return sys_getenvid();
f01044ec:	eb e7                	jmp    f01044d5 <syscall+0x62>
	if ((r = envid2env(envid, &e, 1)) < 0)
f01044ee:	83 ec 04             	sub    $0x4,%esp
f01044f1:	6a 01                	push   $0x1
f01044f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01044f6:	50                   	push   %eax
f01044f7:	ff 75 0c             	pushl  0xc(%ebp)
f01044fa:	e8 dc ee ff ff       	call   f01033db <envid2env>
f01044ff:	83 c4 10             	add    $0x10,%esp
f0104502:	85 c0                	test   %eax,%eax
f0104504:	78 cf                	js     f01044d5 <syscall+0x62>
	if (e == curenv)
f0104506:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104509:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f010450f:	8b 00                	mov    (%eax),%eax
f0104511:	39 c2                	cmp    %eax,%edx
f0104513:	74 2d                	je     f0104542 <syscall+0xcf>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104515:	83 ec 04             	sub    $0x4,%esp
f0104518:	ff 72 48             	pushl  0x48(%edx)
f010451b:	ff 70 48             	pushl  0x48(%eax)
f010451e:	8d 83 e4 9b f7 ff    	lea    -0x8641c(%ebx),%eax
f0104524:	50                   	push   %eax
f0104525:	e8 5b f6 ff ff       	call   f0103b85 <cprintf>
f010452a:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f010452d:	83 ec 0c             	sub    $0xc,%esp
f0104530:	ff 75 f4             	pushl  -0xc(%ebp)
f0104533:	e8 db f4 ff ff       	call   f0103a13 <env_destroy>
f0104538:	83 c4 10             	add    $0x10,%esp
	return 0;
f010453b:	b8 00 00 00 00       	mov    $0x0,%eax
			return sys_env_destroy(a1);
f0104540:	eb 93                	jmp    f01044d5 <syscall+0x62>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104542:	83 ec 08             	sub    $0x8,%esp
f0104545:	ff 70 48             	pushl  0x48(%eax)
f0104548:	8d 83 c9 9b f7 ff    	lea    -0x86437(%ebx),%eax
f010454e:	50                   	push   %eax
f010454f:	e8 31 f6 ff ff       	call   f0103b85 <cprintf>
f0104554:	83 c4 10             	add    $0x10,%esp
f0104557:	eb d4                	jmp    f010452d <syscall+0xba>

f0104559 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104559:	55                   	push   %ebp
f010455a:	89 e5                	mov    %esp,%ebp
f010455c:	57                   	push   %edi
f010455d:	56                   	push   %esi
f010455e:	53                   	push   %ebx
f010455f:	83 ec 14             	sub    $0x14,%esp
f0104562:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104565:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104568:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010456b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010456e:	8b 32                	mov    (%edx),%esi
f0104570:	8b 01                	mov    (%ecx),%eax
f0104572:	89 45 f0             	mov    %eax,-0x10(%ebp)

	while (l <= r) {
f0104575:	39 c6                	cmp    %eax,%esi
f0104577:	7f 79                	jg     f01045f2 <stab_binsearch+0x99>
	int l = *region_left, r = *region_right, any_matches = 0;
f0104579:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0104580:	e9 84 00 00 00       	jmp    f0104609 <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104585:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104588:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f010458a:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f010458d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104594:	eb 6e                	jmp    f0104604 <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104596:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104599:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010459b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010459f:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f01045a1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01045a8:	eb 5a                	jmp    f0104604 <stab_binsearch+0xab>
		}
	}

	if (!any_matches)
f01045aa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01045ae:	74 42                	je     f01045f2 <stab_binsearch+0x99>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01045b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01045b3:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01045b5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01045b8:	8b 16                	mov    (%esi),%edx
		for (l = *region_right;
f01045ba:	39 d0                	cmp    %edx,%eax
f01045bc:	7e 27                	jle    f01045e5 <stab_binsearch+0x8c>
		     l > *region_left && stabs[l].n_type != type;
f01045be:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01045c1:	c1 e1 02             	shl    $0x2,%ecx
f01045c4:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01045c7:	0f b6 5c 0e 04       	movzbl 0x4(%esi,%ecx,1),%ebx
f01045cc:	39 df                	cmp    %ebx,%edi
f01045ce:	74 15                	je     f01045e5 <stab_binsearch+0x8c>
f01045d0:	8d 4c 0e f8          	lea    -0x8(%esi,%ecx,1),%ecx
		     l--)
f01045d4:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01045d7:	39 d0                	cmp    %edx,%eax
f01045d9:	74 0a                	je     f01045e5 <stab_binsearch+0x8c>
		     l > *region_left && stabs[l].n_type != type;
f01045db:	0f b6 19             	movzbl (%ecx),%ebx
f01045de:	83 e9 0c             	sub    $0xc,%ecx
f01045e1:	39 fb                	cmp    %edi,%ebx
f01045e3:	75 ef                	jne    f01045d4 <stab_binsearch+0x7b>
			/* do nothing */;
		*region_left = l;
f01045e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01045e8:	89 07                	mov    %eax,(%edi)
	}
}
f01045ea:	83 c4 14             	add    $0x14,%esp
f01045ed:	5b                   	pop    %ebx
f01045ee:	5e                   	pop    %esi
f01045ef:	5f                   	pop    %edi
f01045f0:	5d                   	pop    %ebp
f01045f1:	c3                   	ret    
		*region_right = *region_left - 1;
f01045f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045f5:	8b 00                	mov    (%eax),%eax
f01045f7:	83 e8 01             	sub    $0x1,%eax
f01045fa:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01045fd:	89 07                	mov    %eax,(%edi)
f01045ff:	eb e9                	jmp    f01045ea <stab_binsearch+0x91>
			l = true_m + 1;
f0104601:	8d 73 01             	lea    0x1(%ebx),%esi
	while (l <= r) {
f0104604:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0104607:	7f a1                	jg     f01045aa <stab_binsearch+0x51>
		int true_m = (l + r) / 2, m = true_m;
f0104609:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010460c:	01 f0                	add    %esi,%eax
f010460e:	89 c3                	mov    %eax,%ebx
f0104610:	c1 eb 1f             	shr    $0x1f,%ebx
f0104613:	01 c3                	add    %eax,%ebx
f0104615:	d1 fb                	sar    %ebx
		while (m >= l && stabs[m].n_type != type)
f0104617:	39 f3                	cmp    %esi,%ebx
f0104619:	7c e6                	jl     f0104601 <stab_binsearch+0xa8>
f010461b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010461e:	c1 e0 02             	shl    $0x2,%eax
f0104621:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104624:	0f b6 54 01 04       	movzbl 0x4(%ecx,%eax,1),%edx
f0104629:	39 d7                	cmp    %edx,%edi
f010462b:	74 47                	je     f0104674 <stab_binsearch+0x11b>
f010462d:	8d 54 01 f8          	lea    -0x8(%ecx,%eax,1),%edx
		int true_m = (l + r) / 2, m = true_m;
f0104631:	89 d8                	mov    %ebx,%eax
			m--;
f0104633:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104636:	39 f0                	cmp    %esi,%eax
f0104638:	7c c7                	jl     f0104601 <stab_binsearch+0xa8>
f010463a:	0f b6 0a             	movzbl (%edx),%ecx
f010463d:	83 ea 0c             	sub    $0xc,%edx
f0104640:	39 f9                	cmp    %edi,%ecx
f0104642:	75 ef                	jne    f0104633 <stab_binsearch+0xda>
		if (stabs[m].n_value < addr) {
f0104644:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104647:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010464a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010464e:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104651:	0f 82 2e ff ff ff    	jb     f0104585 <stab_binsearch+0x2c>
		} else if (stabs[m].n_value > addr) {
f0104657:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010465a:	0f 86 36 ff ff ff    	jbe    f0104596 <stab_binsearch+0x3d>
			*region_right = m - 1;
f0104660:	83 e8 01             	sub    $0x1,%eax
f0104663:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104666:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104669:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f010466b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104672:	eb 90                	jmp    f0104604 <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f0104674:	89 d8                	mov    %ebx,%eax
f0104676:	eb cc                	jmp    f0104644 <stab_binsearch+0xeb>

f0104678 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104678:	55                   	push   %ebp
f0104679:	89 e5                	mov    %esp,%ebp
f010467b:	57                   	push   %edi
f010467c:	56                   	push   %esi
f010467d:	53                   	push   %ebx
f010467e:	83 ec 4c             	sub    $0x4c,%esp
f0104681:	e8 e7 ba ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0104686:	81 c3 9e 89 08 00    	add    $0x8899e,%ebx
f010468c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010468f:	8d 83 fc 9b f7 ff    	lea    -0x86404(%ebx),%eax
f0104695:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0104697:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f010469e:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f01046a1:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f01046a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01046ab:	89 47 10             	mov    %eax,0x10(%edi)
	info->eip_fn_narg = 0;
f01046ae:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01046b5:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01046ba:	0f 86 4a 01 00 00    	jbe    f010480a <debuginfo_eip+0x192>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01046c0:	c7 c0 0e 26 11 f0    	mov    $0xf011260e,%eax
f01046c6:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01046c9:	c7 c0 ed fa 10 f0    	mov    $0xf010faed,%eax
f01046cf:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = __STAB_END__;
f01046d2:	c7 c6 ec fa 10 f0    	mov    $0xf010faec,%esi
		stabs = __STAB_BEGIN__;
f01046d8:	c7 c0 1c 6e 10 f0    	mov    $0xf0106e1c,%eax
f01046de:	89 45 c0             	mov    %eax,-0x40(%ebp)
		if(user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01046e1:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f01046e4:	39 4d b8             	cmp    %ecx,-0x48(%ebp)
f01046e7:	0f 83 0d 02 00 00    	jae    f01048fa <debuginfo_eip+0x282>
f01046ed:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f01046f1:	0f 85 0a 02 00 00    	jne    f0104901 <debuginfo_eip+0x289>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01046f7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01046fe:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104701:	c1 fe 02             	sar    $0x2,%esi
f0104704:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f010470a:	83 e8 01             	sub    $0x1,%eax
f010470d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104710:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104713:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104716:	83 ec 08             	sub    $0x8,%esp
f0104719:	ff 75 08             	pushl  0x8(%ebp)
f010471c:	6a 64                	push   $0x64
f010471e:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104721:	89 f0                	mov    %esi,%eax
f0104723:	e8 31 fe ff ff       	call   f0104559 <stab_binsearch>
	if (lfile == 0)
f0104728:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010472b:	83 c4 10             	add    $0x10,%esp
f010472e:	85 c0                	test   %eax,%eax
f0104730:	0f 84 d2 01 00 00    	je     f0104908 <debuginfo_eip+0x290>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104736:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104739:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010473c:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010473f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104742:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104745:	83 ec 08             	sub    $0x8,%esp
f0104748:	ff 75 08             	pushl  0x8(%ebp)
f010474b:	6a 24                	push   $0x24
f010474d:	89 f0                	mov    %esi,%eax
f010474f:	e8 05 fe ff ff       	call   f0104559 <stab_binsearch>

	if (lfun <= rfun) {
f0104754:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104757:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010475a:	83 c4 10             	add    $0x10,%esp
f010475d:	39 d0                	cmp    %edx,%eax
f010475f:	0f 8f 34 01 00 00    	jg     f0104899 <debuginfo_eip+0x221>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104765:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104768:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f010476b:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f010476e:	8b 36                	mov    (%esi),%esi
f0104770:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104773:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104776:	39 ce                	cmp    %ecx,%esi
f0104778:	73 06                	jae    f0104780 <debuginfo_eip+0x108>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010477a:	03 75 b8             	add    -0x48(%ebp),%esi
f010477d:	89 77 08             	mov    %esi,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104780:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104783:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104786:	89 4f 10             	mov    %ecx,0x10(%edi)
		addr -= info->eip_fn_addr;
f0104789:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f010478c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010478f:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104792:	83 ec 08             	sub    $0x8,%esp
f0104795:	6a 3a                	push   $0x3a
f0104797:	ff 77 08             	pushl  0x8(%edi)
f010479a:	e8 91 0b 00 00       	call   f0105330 <strfind>
f010479f:	2b 47 08             	sub    0x8(%edi),%eax
f01047a2:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01047a5:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01047a8:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01047ab:	83 c4 08             	add    $0x8,%esp
f01047ae:	ff 75 08             	pushl  0x8(%ebp)
f01047b1:	6a 44                	push   $0x44
f01047b3:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01047b6:	89 f0                	mov    %esi,%eax
f01047b8:	e8 9c fd ff ff       	call   f0104559 <stab_binsearch>
	if (lline <= rline)
f01047bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01047c0:	83 c4 10             	add    $0x10,%esp
f01047c3:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01047c6:	0f 8f 43 01 00 00    	jg     f010490f <debuginfo_eip+0x297>
		info->eip_line = stabs[lline].n_desc;
f01047cc:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01047cf:	c1 e1 02             	shl    $0x2,%ecx
f01047d2:	8d 1c 0e             	lea    (%esi,%ecx,1),%ebx
f01047d5:	0f b7 53 06          	movzwl 0x6(%ebx),%edx
f01047d9:	89 57 04             	mov    %edx,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01047dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01047df:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f01047e2:	39 d0                	cmp    %edx,%eax
f01047e4:	0f 8c 63 01 00 00    	jl     f010494d <debuginfo_eip+0x2d5>
	       && stabs[lline].n_type != N_SOL
f01047ea:	0f b6 53 04          	movzbl 0x4(%ebx),%edx
f01047ee:	80 fa 84             	cmp    $0x84,%dl
f01047f1:	0f 84 3d 01 00 00    	je     f0104934 <debuginfo_eip+0x2bc>
f01047f7:	8d 4c 0e f8          	lea    -0x8(%esi,%ecx,1),%ecx
f01047fb:	83 c3 08             	add    $0x8,%ebx
f01047fe:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104802:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f0104805:	e9 c3 00 00 00       	jmp    f01048cd <debuginfo_eip+0x255>
		if(user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010480a:	6a 04                	push   $0x4
f010480c:	6a 10                	push   $0x10
f010480e:	68 00 00 20 00       	push   $0x200000
f0104813:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f0104819:	ff 30                	pushl  (%eax)
f010481b:	e8 98 e9 ff ff       	call   f01031b8 <user_mem_check>
f0104820:	83 c4 10             	add    $0x10,%esp
f0104823:	85 c0                	test   %eax,%eax
f0104825:	0f 85 c1 00 00 00    	jne    f01048ec <debuginfo_eip+0x274>
		stabs = usd->stabs;
f010482b:	8b 15 00 00 20 00    	mov    0x200000,%edx
f0104831:	89 55 c0             	mov    %edx,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104834:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f010483a:	a1 08 00 20 00       	mov    0x200008,%eax
f010483f:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104842:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0104848:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		if(user_mem_check(curenv, stabs, sizeof(struct Stab) * (stab_end - stabs), PTE_U))
f010484b:	6a 04                	push   $0x4
f010484d:	89 f0                	mov    %esi,%eax
f010484f:	29 d0                	sub    %edx,%eax
f0104851:	50                   	push   %eax
f0104852:	52                   	push   %edx
f0104853:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f0104859:	ff 30                	pushl  (%eax)
f010485b:	e8 58 e9 ff ff       	call   f01031b8 <user_mem_check>
f0104860:	83 c4 10             	add    $0x10,%esp
f0104863:	85 c0                	test   %eax,%eax
f0104865:	0f 85 88 00 00 00    	jne    f01048f3 <debuginfo_eip+0x27b>
		if(user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
f010486b:	6a 04                	push   $0x4
f010486d:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104870:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0104873:	29 d1                	sub    %edx,%ecx
f0104875:	51                   	push   %ecx
f0104876:	52                   	push   %edx
f0104877:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f010487d:	ff 30                	pushl  (%eax)
f010487f:	e8 34 e9 ff ff       	call   f01031b8 <user_mem_check>
f0104884:	83 c4 10             	add    $0x10,%esp
f0104887:	85 c0                	test   %eax,%eax
f0104889:	0f 84 52 fe ff ff    	je     f01046e1 <debuginfo_eip+0x69>
			return -1;
f010488f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104894:	e9 90 00 00 00       	jmp    f0104929 <debuginfo_eip+0x2b1>
		info->eip_fn_addr = addr;
f0104899:	8b 45 08             	mov    0x8(%ebp),%eax
f010489c:	89 47 10             	mov    %eax,0x10(%edi)
		lline = lfile;
f010489f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01048a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01048ab:	e9 e2 fe ff ff       	jmp    f0104792 <debuginfo_eip+0x11a>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01048b0:	83 e8 01             	sub    $0x1,%eax
	while (lline >= lfile
f01048b3:	39 f0                	cmp    %esi,%eax
f01048b5:	0f 8c 92 00 00 00    	jl     f010494d <debuginfo_eip+0x2d5>
	       && stabs[lline].n_type != N_SOL
f01048bb:	0f b6 11             	movzbl (%ecx),%edx
f01048be:	83 e9 0c             	sub    $0xc,%ecx
f01048c1:	83 eb 0c             	sub    $0xc,%ebx
f01048c4:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01048c8:	80 fa 84             	cmp    $0x84,%dl
f01048cb:	74 64                	je     f0104931 <debuginfo_eip+0x2b9>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01048cd:	80 fa 64             	cmp    $0x64,%dl
f01048d0:	75 de                	jne    f01048b0 <debuginfo_eip+0x238>
f01048d2:	83 3b 00             	cmpl   $0x0,(%ebx)
f01048d5:	74 d9                	je     f01048b0 <debuginfo_eip+0x238>
f01048d7:	89 75 b4             	mov    %esi,-0x4c(%ebp)
f01048da:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01048de:	75 07                	jne    f01048e7 <debuginfo_eip+0x26f>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01048e0:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
f01048e3:	7e 4f                	jle    f0104934 <debuginfo_eip+0x2bc>
f01048e5:	eb 66                	jmp    f010494d <debuginfo_eip+0x2d5>
f01048e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01048ea:	eb f4                	jmp    f01048e0 <debuginfo_eip+0x268>
			return -1;
f01048ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048f1:	eb 36                	jmp    f0104929 <debuginfo_eip+0x2b1>
			return -1;
f01048f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048f8:	eb 2f                	jmp    f0104929 <debuginfo_eip+0x2b1>
		return -1;
f01048fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048ff:	eb 28                	jmp    f0104929 <debuginfo_eip+0x2b1>
f0104901:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104906:	eb 21                	jmp    f0104929 <debuginfo_eip+0x2b1>
		return -1;
f0104908:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010490d:	eb 1a                	jmp    f0104929 <debuginfo_eip+0x2b1>
		return -1;
f010490f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104914:	eb 13                	jmp    f0104929 <debuginfo_eip+0x2b1>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104916:	b8 00 00 00 00       	mov    $0x0,%eax
f010491b:	eb 0c                	jmp    f0104929 <debuginfo_eip+0x2b1>
f010491d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104922:	eb 05                	jmp    f0104929 <debuginfo_eip+0x2b1>
f0104924:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104929:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010492c:	5b                   	pop    %ebx
f010492d:	5e                   	pop    %esi
f010492e:	5f                   	pop    %edi
f010492f:	5d                   	pop    %ebp
f0104930:	c3                   	ret    
f0104931:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104934:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104937:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f010493a:	8b 04 83             	mov    (%ebx,%eax,4),%eax
f010493d:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104940:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0104943:	29 f2                	sub    %esi,%edx
f0104945:	39 d0                	cmp    %edx,%eax
f0104947:	73 04                	jae    f010494d <debuginfo_eip+0x2d5>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104949:	01 f0                	add    %esi,%eax
f010494b:	89 07                	mov    %eax,(%edi)
	if (lfun < rfun)
f010494d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104950:	8b 4d d8             	mov    -0x28(%ebp),%ecx
	return 0;
f0104953:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104958:	39 cb                	cmp    %ecx,%ebx
f010495a:	7d cd                	jge    f0104929 <debuginfo_eip+0x2b1>
		for (lline = lfun + 1;
f010495c:	8d 43 01             	lea    0x1(%ebx),%eax
f010495f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104962:	39 c1                	cmp    %eax,%ecx
f0104964:	7e b0                	jle    f0104916 <debuginfo_eip+0x29e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104966:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104969:	c1 e0 02             	shl    $0x2,%eax
f010496c:	8b 75 c0             	mov    -0x40(%ebp),%esi
f010496f:	80 7c 06 04 a0       	cmpb   $0xa0,0x4(%esi,%eax,1)
f0104974:	75 a7                	jne    f010491d <debuginfo_eip+0x2a5>
f0104976:	8d 54 06 10          	lea    0x10(%esi,%eax,1),%edx
f010497a:	83 e9 02             	sub    $0x2,%ecx
f010497d:	29 d9                	sub    %ebx,%ecx
f010497f:	b8 00 00 00 00       	mov    $0x0,%eax
			info->eip_fn_narg++;
f0104984:	83 47 14 01          	addl   $0x1,0x14(%edi)
		for (lline = lfun + 1;
f0104988:	39 c8                	cmp    %ecx,%eax
f010498a:	74 98                	je     f0104924 <debuginfo_eip+0x2ac>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010498c:	0f b6 1a             	movzbl (%edx),%ebx
f010498f:	83 c0 01             	add    $0x1,%eax
f0104992:	83 c2 0c             	add    $0xc,%edx
f0104995:	80 fb a0             	cmp    $0xa0,%bl
f0104998:	74 ea                	je     f0104984 <debuginfo_eip+0x30c>
	return 0;
f010499a:	b8 00 00 00 00       	mov    $0x0,%eax
f010499f:	eb 88                	jmp    f0104929 <debuginfo_eip+0x2b1>

f01049a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01049a1:	55                   	push   %ebp
f01049a2:	89 e5                	mov    %esp,%ebp
f01049a4:	57                   	push   %edi
f01049a5:	56                   	push   %esi
f01049a6:	53                   	push   %ebx
f01049a7:	83 ec 2c             	sub    $0x2c,%esp
f01049aa:	e8 86 e9 ff ff       	call   f0103335 <__x86.get_pc_thunk.cx>
f01049af:	81 c1 75 86 08 00    	add    $0x88675,%ecx
f01049b5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01049b8:	89 c7                	mov    %eax,%edi
f01049ba:	89 d6                	mov    %edx,%esi
f01049bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01049bf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01049c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01049c5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01049c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01049cb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049d0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f01049d3:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f01049d6:	39 d3                	cmp    %edx,%ebx
f01049d8:	72 56                	jb     f0104a30 <printnum+0x8f>
f01049da:	39 45 10             	cmp    %eax,0x10(%ebp)
f01049dd:	76 51                	jbe    f0104a30 <printnum+0x8f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01049df:	8b 45 14             	mov    0x14(%ebp),%eax
f01049e2:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01049e5:	85 db                	test   %ebx,%ebx
f01049e7:	7e 11                	jle    f01049fa <printnum+0x59>
			putch(padc, putdat);
f01049e9:	83 ec 08             	sub    $0x8,%esp
f01049ec:	56                   	push   %esi
f01049ed:	ff 75 18             	pushl  0x18(%ebp)
f01049f0:	ff d7                	call   *%edi
		while (--width > 0)
f01049f2:	83 c4 10             	add    $0x10,%esp
f01049f5:	83 eb 01             	sub    $0x1,%ebx
f01049f8:	75 ef                	jne    f01049e9 <printnum+0x48>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01049fa:	83 ec 08             	sub    $0x8,%esp
f01049fd:	56                   	push   %esi
f01049fe:	83 ec 04             	sub    $0x4,%esp
f0104a01:	ff 75 dc             	pushl  -0x24(%ebp)
f0104a04:	ff 75 d8             	pushl  -0x28(%ebp)
f0104a07:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104a0a:	ff 75 d0             	pushl  -0x30(%ebp)
f0104a0d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104a10:	89 f3                	mov    %esi,%ebx
f0104a12:	e8 89 0c 00 00       	call   f01056a0 <__umoddi3>
f0104a17:	83 c4 14             	add    $0x14,%esp
f0104a1a:	0f be 84 06 06 9c f7 	movsbl -0x863fa(%esi,%eax,1),%eax
f0104a21:	ff 
f0104a22:	50                   	push   %eax
f0104a23:	ff d7                	call   *%edi
}
f0104a25:	83 c4 10             	add    $0x10,%esp
f0104a28:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104a2b:	5b                   	pop    %ebx
f0104a2c:	5e                   	pop    %esi
f0104a2d:	5f                   	pop    %edi
f0104a2e:	5d                   	pop    %ebp
f0104a2f:	c3                   	ret    
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104a30:	83 ec 0c             	sub    $0xc,%esp
f0104a33:	ff 75 18             	pushl  0x18(%ebp)
f0104a36:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a39:	83 e8 01             	sub    $0x1,%eax
f0104a3c:	50                   	push   %eax
f0104a3d:	ff 75 10             	pushl  0x10(%ebp)
f0104a40:	83 ec 08             	sub    $0x8,%esp
f0104a43:	ff 75 dc             	pushl  -0x24(%ebp)
f0104a46:	ff 75 d8             	pushl  -0x28(%ebp)
f0104a49:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104a4c:	ff 75 d0             	pushl  -0x30(%ebp)
f0104a4f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104a52:	e8 29 0b 00 00       	call   f0105580 <__udivdi3>
f0104a57:	83 c4 18             	add    $0x18,%esp
f0104a5a:	52                   	push   %edx
f0104a5b:	50                   	push   %eax
f0104a5c:	89 f2                	mov    %esi,%edx
f0104a5e:	89 f8                	mov    %edi,%eax
f0104a60:	e8 3c ff ff ff       	call   f01049a1 <printnum>
f0104a65:	83 c4 20             	add    $0x20,%esp
f0104a68:	eb 90                	jmp    f01049fa <printnum+0x59>

f0104a6a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104a6a:	55                   	push   %ebp
f0104a6b:	89 e5                	mov    %esp,%ebp
f0104a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104a70:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104a74:	8b 10                	mov    (%eax),%edx
f0104a76:	3b 50 04             	cmp    0x4(%eax),%edx
f0104a79:	73 0a                	jae    f0104a85 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104a7b:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104a7e:	89 08                	mov    %ecx,(%eax)
f0104a80:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a83:	88 02                	mov    %al,(%edx)
}
f0104a85:	5d                   	pop    %ebp
f0104a86:	c3                   	ret    

f0104a87 <printfmt>:
{
f0104a87:	55                   	push   %ebp
f0104a88:	89 e5                	mov    %esp,%ebp
f0104a8a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104a8d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104a90:	50                   	push   %eax
f0104a91:	ff 75 10             	pushl  0x10(%ebp)
f0104a94:	ff 75 0c             	pushl  0xc(%ebp)
f0104a97:	ff 75 08             	pushl  0x8(%ebp)
f0104a9a:	e8 05 00 00 00       	call   f0104aa4 <vprintfmt>
}
f0104a9f:	83 c4 10             	add    $0x10,%esp
f0104aa2:	c9                   	leave  
f0104aa3:	c3                   	ret    

f0104aa4 <vprintfmt>:
{
f0104aa4:	55                   	push   %ebp
f0104aa5:	89 e5                	mov    %esp,%ebp
f0104aa7:	57                   	push   %edi
f0104aa8:	56                   	push   %esi
f0104aa9:	53                   	push   %ebx
f0104aaa:	83 ec 2c             	sub    $0x2c,%esp
f0104aad:	e8 5e bc ff ff       	call   f0100710 <__x86.get_pc_thunk.ax>
f0104ab2:	05 72 85 08 00       	add    $0x88572,%eax
f0104ab7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104aba:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104abd:	8b 75 0c             	mov    0xc(%ebp),%esi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104ac0:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ac3:	8d 58 01             	lea    0x1(%eax),%ebx
f0104ac6:	0f b6 00             	movzbl (%eax),%eax
f0104ac9:	83 f8 25             	cmp    $0x25,%eax
f0104acc:	74 2b                	je     f0104af9 <vprintfmt+0x55>
			if (ch == '\0')
f0104ace:	85 c0                	test   %eax,%eax
f0104ad0:	74 1a                	je     f0104aec <vprintfmt+0x48>
			putch(ch, putdat);
f0104ad2:	83 ec 08             	sub    $0x8,%esp
f0104ad5:	56                   	push   %esi
f0104ad6:	50                   	push   %eax
f0104ad7:	ff d7                	call   *%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104ad9:	83 c3 01             	add    $0x1,%ebx
f0104adc:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0104ae0:	83 c4 10             	add    $0x10,%esp
f0104ae3:	83 f8 25             	cmp    $0x25,%eax
f0104ae6:	74 11                	je     f0104af9 <vprintfmt+0x55>
			if (ch == '\0')
f0104ae8:	85 c0                	test   %eax,%eax
f0104aea:	75 e6                	jne    f0104ad2 <vprintfmt+0x2e>
}
f0104aec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104aef:	5b                   	pop    %ebx
f0104af0:	5e                   	pop    %esi
f0104af1:	5f                   	pop    %edi
f0104af2:	5d                   	pop    %ebp
f0104af3:	c3                   	ret    
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104af4:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104af7:	eb c7                	jmp    f0104ac0 <vprintfmt+0x1c>
		padc = ' ';
f0104af9:	c6 45 d7 20          	movb   $0x20,-0x29(%ebp)
		altflag = 0;
f0104afd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0104b04:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0104b0b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0104b12:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104b17:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104b1a:	89 75 0c             	mov    %esi,0xc(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104b1d:	8d 43 01             	lea    0x1(%ebx),%eax
f0104b20:	89 45 10             	mov    %eax,0x10(%ebp)
f0104b23:	0f b6 13             	movzbl (%ebx),%edx
f0104b26:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104b29:	3c 55                	cmp    $0x55,%al
f0104b2b:	0f 87 5d 04 00 00    	ja     f0104f8e <.L24>
f0104b31:	0f b6 c0             	movzbl %al,%eax
f0104b34:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104b37:	89 ce                	mov    %ecx,%esi
f0104b39:	03 b4 81 90 9c f7 ff 	add    -0x86370(%ecx,%eax,4),%esi
f0104b40:	ff e6                	jmp    *%esi

f0104b42 <.L72>:
f0104b42:	8b 5d 10             	mov    0x10(%ebp),%ebx
			padc = '-';
f0104b45:	c6 45 d7 2d          	movb   $0x2d,-0x29(%ebp)
f0104b49:	eb d2                	jmp    f0104b1d <vprintfmt+0x79>

f0104b4b <.L30>:
		switch (ch = *(unsigned char *) fmt++) {
f0104b4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
			padc = '0';
f0104b4e:	c6 45 d7 30          	movb   $0x30,-0x29(%ebp)
f0104b52:	eb c9                	jmp    f0104b1d <vprintfmt+0x79>

f0104b54 <.L31>:
		switch (ch = *(unsigned char *) fmt++) {
f0104b54:	0f b6 d2             	movzbl %dl,%edx
				precision = precision * 10 + ch - '0';
f0104b57:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104b5a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
				ch = *fmt;
f0104b5d:	0f be 43 01          	movsbl 0x1(%ebx),%eax
				if (ch < '0' || ch > '9')
f0104b61:	8d 50 d0             	lea    -0x30(%eax),%edx
f0104b64:	83 fa 09             	cmp    $0x9,%edx
f0104b67:	77 7e                	ja     f0104be7 <.L25+0xf>
f0104b69:	89 ca                	mov    %ecx,%edx
f0104b6b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104b6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
f0104b71:	83 c1 01             	add    $0x1,%ecx
				precision = precision * 10 + ch - '0';
f0104b74:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0104b77:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0104b7b:	0f be 01             	movsbl (%ecx),%eax
				if (ch < '0' || ch > '9')
f0104b7e:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0104b81:	83 fb 09             	cmp    $0x9,%ebx
f0104b84:	76 eb                	jbe    f0104b71 <.L31+0x1d>
f0104b86:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104b89:	89 75 0c             	mov    %esi,0xc(%ebp)
			for (precision = 0; ; ++fmt) {
f0104b8c:	89 cb                	mov    %ecx,%ebx
f0104b8e:	eb 14                	jmp    f0104ba4 <.L28+0x14>

f0104b90 <.L28>:
			precision = va_arg(ap, int);
f0104b90:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b93:	8b 00                	mov    (%eax),%eax
f0104b95:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104b98:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b9b:	8d 40 04             	lea    0x4(%eax),%eax
f0104b9e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104ba1:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (width < 0)
f0104ba4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104ba8:	0f 89 6f ff ff ff    	jns    f0104b1d <vprintfmt+0x79>
				width = precision, precision = -1;
f0104bae:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104bb1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104bb4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104bbb:	e9 5d ff ff ff       	jmp    f0104b1d <vprintfmt+0x79>

f0104bc0 <.L29>:
f0104bc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104bc3:	85 c0                	test   %eax,%eax
f0104bc5:	ba 00 00 00 00       	mov    $0x0,%edx
f0104bca:	0f 49 d0             	cmovns %eax,%edx
f0104bcd:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104bd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104bd3:	e9 45 ff ff ff       	jmp    f0104b1d <vprintfmt+0x79>

f0104bd8 <.L25>:
f0104bd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
			altflag = 1;
f0104bdb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104be2:	e9 36 ff ff ff       	jmp    f0104b1d <vprintfmt+0x79>
		switch (ch = *(unsigned char *) fmt++) {
f0104be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104bea:	eb b8                	jmp    f0104ba4 <.L28+0x14>

f0104bec <.L35>:
			lflag++;
f0104bec:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104bf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
			goto reswitch;
f0104bf3:	e9 25 ff ff ff       	jmp    f0104b1d <vprintfmt+0x79>

f0104bf8 <.L32>:
f0104bf8:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f0104bfb:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bfe:	8d 58 04             	lea    0x4(%eax),%ebx
f0104c01:	83 ec 08             	sub    $0x8,%esp
f0104c04:	56                   	push   %esi
f0104c05:	ff 30                	pushl  (%eax)
f0104c07:	ff d7                	call   *%edi
			break;
f0104c09:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0104c0c:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0104c0f:	e9 ac fe ff ff       	jmp    f0104ac0 <vprintfmt+0x1c>

f0104c14 <.L34>:
f0104c14:	8b 75 0c             	mov    0xc(%ebp),%esi
			err = va_arg(ap, int);
f0104c17:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c1a:	8d 58 04             	lea    0x4(%eax),%ebx
f0104c1d:	8b 00                	mov    (%eax),%eax
f0104c1f:	99                   	cltd   
f0104c20:	31 d0                	xor    %edx,%eax
f0104c22:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104c24:	83 f8 06             	cmp    $0x6,%eax
f0104c27:	7f 2b                	jg     f0104c54 <.L34+0x40>
f0104c29:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104c2c:	8b 94 82 ac 20 00 00 	mov    0x20ac(%edx,%eax,4),%edx
f0104c33:	85 d2                	test   %edx,%edx
f0104c35:	74 1d                	je     f0104c54 <.L34+0x40>
				printfmt(putch, putdat, "%s", p);
f0104c37:	52                   	push   %edx
f0104c38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c3b:	8d 80 cc 8c f7 ff    	lea    -0x87334(%eax),%eax
f0104c41:	50                   	push   %eax
f0104c42:	56                   	push   %esi
f0104c43:	57                   	push   %edi
f0104c44:	e8 3e fe ff ff       	call   f0104a87 <printfmt>
f0104c49:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104c4c:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0104c4f:	e9 6c fe ff ff       	jmp    f0104ac0 <vprintfmt+0x1c>
				printfmt(putch, putdat, "error %d", err);
f0104c54:	50                   	push   %eax
f0104c55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c58:	8d 80 1e 9c f7 ff    	lea    -0x863e2(%eax),%eax
f0104c5e:	50                   	push   %eax
f0104c5f:	56                   	push   %esi
f0104c60:	57                   	push   %edi
f0104c61:	e8 21 fe ff ff       	call   f0104a87 <printfmt>
f0104c66:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104c69:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104c6c:	e9 4f fe ff ff       	jmp    f0104ac0 <vprintfmt+0x1c>

f0104c71 <.L38>:
f0104c71:	8b 75 0c             	mov    0xc(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f0104c74:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c77:	83 c0 04             	add    $0x4,%eax
f0104c7a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104c7d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c80:	8b 00                	mov    (%eax),%eax
f0104c82:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104c85:	85 c0                	test   %eax,%eax
f0104c87:	0f 84 3a 03 00 00    	je     f0104fc7 <.L24+0x39>
			if (width > 0 && padc != '-')
f0104c8d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104c91:	7e 06                	jle    f0104c99 <.L38+0x28>
f0104c93:	80 7d d7 2d          	cmpb   $0x2d,-0x29(%ebp)
f0104c97:	75 31                	jne    f0104cca <.L38+0x59>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104c99:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104c9c:	8d 58 01             	lea    0x1(%eax),%ebx
f0104c9f:	0f b6 10             	movzbl (%eax),%edx
f0104ca2:	0f be c2             	movsbl %dl,%eax
f0104ca5:	85 c0                	test   %eax,%eax
f0104ca7:	0f 84 cd 00 00 00    	je     f0104d7a <.L38+0x109>
f0104cad:	89 7d 08             	mov    %edi,0x8(%ebp)
f0104cb0:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0104cb3:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104cb6:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104cb9:	e9 84 00 00 00       	jmp    f0104d42 <.L38+0xd1>
				p = "(null)";
f0104cbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cc1:	8d 80 17 9c f7 ff    	lea    -0x863e9(%eax),%eax
f0104cc7:	89 45 c8             	mov    %eax,-0x38(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104cca:	83 ec 08             	sub    $0x8,%esp
f0104ccd:	ff 75 d0             	pushl  -0x30(%ebp)
f0104cd0:	ff 75 c8             	pushl  -0x38(%ebp)
f0104cd3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104cd6:	e8 b8 04 00 00       	call   f0105193 <strnlen>
f0104cdb:	29 45 e0             	sub    %eax,-0x20(%ebp)
f0104cde:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104ce1:	83 c4 10             	add    $0x10,%esp
f0104ce4:	85 d2                	test   %edx,%edx
f0104ce6:	7e 14                	jle    f0104cfc <.L38+0x8b>
					putch(padc, putdat);
f0104ce8:	0f be 5d d7          	movsbl -0x29(%ebp),%ebx
f0104cec:	83 ec 08             	sub    $0x8,%esp
f0104cef:	56                   	push   %esi
f0104cf0:	53                   	push   %ebx
f0104cf1:	ff d7                	call   *%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104cf3:	83 c4 10             	add    $0x10,%esp
f0104cf6:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f0104cfa:	75 f0                	jne    f0104cec <.L38+0x7b>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104cfc:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104cff:	8d 58 01             	lea    0x1(%eax),%ebx
f0104d02:	0f b6 10             	movzbl (%eax),%edx
f0104d05:	0f be c2             	movsbl %dl,%eax
f0104d08:	85 c0                	test   %eax,%eax
f0104d0a:	0f 84 ac 02 00 00    	je     f0104fbc <.L24+0x2e>
f0104d10:	89 7d 08             	mov    %edi,0x8(%ebp)
f0104d13:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0104d16:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104d19:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104d1c:	eb 24                	jmp    f0104d42 <.L38+0xd1>
				if (altflag && (ch < ' ' || ch > '~'))
f0104d1e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104d22:	75 32                	jne    f0104d56 <.L38+0xe5>
					putch(ch, putdat);
f0104d24:	83 ec 08             	sub    $0x8,%esp
f0104d27:	ff 75 0c             	pushl  0xc(%ebp)
f0104d2a:	50                   	push   %eax
f0104d2b:	ff 55 08             	call   *0x8(%ebp)
f0104d2e:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104d31:	83 ee 01             	sub    $0x1,%esi
f0104d34:	83 c3 01             	add    $0x1,%ebx
f0104d37:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
f0104d3b:	0f be c2             	movsbl %dl,%eax
f0104d3e:	85 c0                	test   %eax,%eax
f0104d40:	74 2f                	je     f0104d71 <.L38+0x100>
f0104d42:	85 ff                	test   %edi,%edi
f0104d44:	78 d8                	js     f0104d1e <.L38+0xad>
f0104d46:	83 ef 01             	sub    $0x1,%edi
f0104d49:	79 d3                	jns    f0104d1e <.L38+0xad>
f0104d4b:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0104d4e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104d51:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104d54:	eb 24                	jmp    f0104d7a <.L38+0x109>
				if (altflag && (ch < ' ' || ch > '~'))
f0104d56:	0f be d2             	movsbl %dl,%edx
f0104d59:	83 ea 20             	sub    $0x20,%edx
f0104d5c:	83 fa 5e             	cmp    $0x5e,%edx
f0104d5f:	76 c3                	jbe    f0104d24 <.L38+0xb3>
					putch('?', putdat);
f0104d61:	83 ec 08             	sub    $0x8,%esp
f0104d64:	ff 75 0c             	pushl  0xc(%ebp)
f0104d67:	6a 3f                	push   $0x3f
f0104d69:	ff 55 08             	call   *0x8(%ebp)
f0104d6c:	83 c4 10             	add    $0x10,%esp
f0104d6f:	eb c0                	jmp    f0104d31 <.L38+0xc0>
f0104d71:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0104d74:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104d77:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104d7a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			for (; width > 0; width--)
f0104d7d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104d81:	7e 1b                	jle    f0104d9e <.L38+0x12d>
				putch(' ', putdat);
f0104d83:	83 ec 08             	sub    $0x8,%esp
f0104d86:	56                   	push   %esi
f0104d87:	6a 20                	push   $0x20
f0104d89:	ff d7                	call   *%edi
			for (; width > 0; width--)
f0104d8b:	83 c4 10             	add    $0x10,%esp
f0104d8e:	83 eb 01             	sub    $0x1,%ebx
f0104d91:	75 f0                	jne    f0104d83 <.L38+0x112>
			if ((p = va_arg(ap, char *)) == NULL)
f0104d93:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104d96:	89 45 14             	mov    %eax,0x14(%ebp)
f0104d99:	e9 22 fd ff ff       	jmp    f0104ac0 <vprintfmt+0x1c>
f0104d9e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104da1:	89 45 14             	mov    %eax,0x14(%ebp)
f0104da4:	e9 17 fd ff ff       	jmp    f0104ac0 <vprintfmt+0x1c>

f0104da9 <.L33>:
f0104da9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104dac:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (lflag >= 2)
f0104daf:	83 f9 01             	cmp    $0x1,%ecx
f0104db2:	7e 3f                	jle    f0104df3 <.L33+0x4a>
		return va_arg(*ap, long long);
f0104db4:	8b 45 14             	mov    0x14(%ebp),%eax
f0104db7:	8b 50 04             	mov    0x4(%eax),%edx
f0104dba:	8b 00                	mov    (%eax),%eax
f0104dbc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104dbf:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104dc2:	8b 45 14             	mov    0x14(%ebp),%eax
f0104dc5:	8d 40 08             	lea    0x8(%eax),%eax
f0104dc8:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104dcb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104dcf:	79 54                	jns    f0104e25 <.L33+0x7c>
				putch('-', putdat);
f0104dd1:	83 ec 08             	sub    $0x8,%esp
f0104dd4:	56                   	push   %esi
f0104dd5:	6a 2d                	push   $0x2d
f0104dd7:	ff d7                	call   *%edi
				num = -(long long) num;
f0104dd9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104ddc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104ddf:	f7 d9                	neg    %ecx
f0104de1:	83 d3 00             	adc    $0x0,%ebx
f0104de4:	f7 db                	neg    %ebx
f0104de6:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104de9:	ba 0a 00 00 00       	mov    $0xa,%edx
f0104dee:	e9 17 01 00 00       	jmp    f0104f0a <.L37+0x2b>
	else if (lflag)
f0104df3:	85 c9                	test   %ecx,%ecx
f0104df5:	75 17                	jne    f0104e0e <.L33+0x65>
		return va_arg(*ap, int);
f0104df7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104dfa:	8b 00                	mov    (%eax),%eax
f0104dfc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104dff:	99                   	cltd   
f0104e00:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104e03:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e06:	8d 40 04             	lea    0x4(%eax),%eax
f0104e09:	89 45 14             	mov    %eax,0x14(%ebp)
f0104e0c:	eb bd                	jmp    f0104dcb <.L33+0x22>
		return va_arg(*ap, long);
f0104e0e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e11:	8b 00                	mov    (%eax),%eax
f0104e13:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e16:	99                   	cltd   
f0104e17:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104e1a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e1d:	8d 40 04             	lea    0x4(%eax),%eax
f0104e20:	89 45 14             	mov    %eax,0x14(%ebp)
f0104e23:	eb a6                	jmp    f0104dcb <.L33+0x22>
			num = getint(&ap, lflag);
f0104e25:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104e28:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f0104e2b:	ba 0a 00 00 00       	mov    $0xa,%edx
f0104e30:	e9 d5 00 00 00       	jmp    f0104f0a <.L37+0x2b>

f0104e35 <.L39>:
f0104e35:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104e38:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (lflag >= 2)
f0104e3b:	83 f9 01             	cmp    $0x1,%ecx
f0104e3e:	7e 18                	jle    f0104e58 <.L39+0x23>
		return va_arg(*ap, unsigned long long);
f0104e40:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e43:	8b 08                	mov    (%eax),%ecx
f0104e45:	8b 58 04             	mov    0x4(%eax),%ebx
f0104e48:	8d 40 08             	lea    0x8(%eax),%eax
f0104e4b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104e4e:	ba 0a 00 00 00       	mov    $0xa,%edx
f0104e53:	e9 b2 00 00 00       	jmp    f0104f0a <.L37+0x2b>
	else if (lflag)
f0104e58:	85 c9                	test   %ecx,%ecx
f0104e5a:	75 1a                	jne    f0104e76 <.L39+0x41>
		return va_arg(*ap, unsigned int);
f0104e5c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e5f:	8b 08                	mov    (%eax),%ecx
f0104e61:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e66:	8d 40 04             	lea    0x4(%eax),%eax
f0104e69:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104e6c:	ba 0a 00 00 00       	mov    $0xa,%edx
f0104e71:	e9 94 00 00 00       	jmp    f0104f0a <.L37+0x2b>
		return va_arg(*ap, unsigned long);
f0104e76:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e79:	8b 08                	mov    (%eax),%ecx
f0104e7b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e80:	8d 40 04             	lea    0x4(%eax),%eax
f0104e83:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104e86:	ba 0a 00 00 00       	mov    $0xa,%edx
f0104e8b:	eb 7d                	jmp    f0104f0a <.L37+0x2b>

f0104e8d <.L36>:
f0104e8d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104e90:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (lflag >= 2)
f0104e93:	83 f9 01             	cmp    $0x1,%ecx
f0104e96:	7e 15                	jle    f0104ead <.L36+0x20>
		return va_arg(*ap, unsigned long long);
f0104e98:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e9b:	8b 08                	mov    (%eax),%ecx
f0104e9d:	8b 58 04             	mov    0x4(%eax),%ebx
f0104ea0:	8d 40 08             	lea    0x8(%eax),%eax
f0104ea3:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f0104ea6:	ba 08 00 00 00       	mov    $0x8,%edx
f0104eab:	eb 5d                	jmp    f0104f0a <.L37+0x2b>
	else if (lflag)
f0104ead:	85 c9                	test   %ecx,%ecx
f0104eaf:	75 17                	jne    f0104ec8 <.L36+0x3b>
		return va_arg(*ap, unsigned int);
f0104eb1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104eb4:	8b 08                	mov    (%eax),%ecx
f0104eb6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104ebb:	8d 40 04             	lea    0x4(%eax),%eax
f0104ebe:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f0104ec1:	ba 08 00 00 00       	mov    $0x8,%edx
f0104ec6:	eb 42                	jmp    f0104f0a <.L37+0x2b>
		return va_arg(*ap, unsigned long);
f0104ec8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ecb:	8b 08                	mov    (%eax),%ecx
f0104ecd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104ed2:	8d 40 04             	lea    0x4(%eax),%eax
f0104ed5:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f0104ed8:	ba 08 00 00 00       	mov    $0x8,%edx
f0104edd:	eb 2b                	jmp    f0104f0a <.L37+0x2b>

f0104edf <.L37>:
f0104edf:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch('0', putdat);
f0104ee2:	83 ec 08             	sub    $0x8,%esp
f0104ee5:	56                   	push   %esi
f0104ee6:	6a 30                	push   $0x30
f0104ee8:	ff d7                	call   *%edi
			putch('x', putdat);
f0104eea:	83 c4 08             	add    $0x8,%esp
f0104eed:	56                   	push   %esi
f0104eee:	6a 78                	push   $0x78
f0104ef0:	ff d7                	call   *%edi
			num = (unsigned long long)
f0104ef2:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ef5:	8b 08                	mov    (%eax),%ecx
f0104ef7:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f0104efc:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104eff:	8d 40 04             	lea    0x4(%eax),%eax
f0104f02:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104f05:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f0104f0a:	83 ec 0c             	sub    $0xc,%esp
f0104f0d:	0f be 45 d7          	movsbl -0x29(%ebp),%eax
f0104f11:	50                   	push   %eax
f0104f12:	ff 75 e0             	pushl  -0x20(%ebp)
f0104f15:	52                   	push   %edx
f0104f16:	53                   	push   %ebx
f0104f17:	51                   	push   %ecx
f0104f18:	89 f2                	mov    %esi,%edx
f0104f1a:	89 f8                	mov    %edi,%eax
f0104f1c:	e8 80 fa ff ff       	call   f01049a1 <printnum>
			break;
f0104f21:	83 c4 20             	add    $0x20,%esp
f0104f24:	e9 97 fb ff ff       	jmp    f0104ac0 <vprintfmt+0x1c>

f0104f29 <.L40>:
f0104f29:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104f2c:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (lflag >= 2)
f0104f2f:	83 f9 01             	cmp    $0x1,%ecx
f0104f32:	7e 15                	jle    f0104f49 <.L40+0x20>
		return va_arg(*ap, unsigned long long);
f0104f34:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f37:	8b 08                	mov    (%eax),%ecx
f0104f39:	8b 58 04             	mov    0x4(%eax),%ebx
f0104f3c:	8d 40 08             	lea    0x8(%eax),%eax
f0104f3f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104f42:	ba 10 00 00 00       	mov    $0x10,%edx
f0104f47:	eb c1                	jmp    f0104f0a <.L37+0x2b>
	else if (lflag)
f0104f49:	85 c9                	test   %ecx,%ecx
f0104f4b:	75 17                	jne    f0104f64 <.L40+0x3b>
		return va_arg(*ap, unsigned int);
f0104f4d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f50:	8b 08                	mov    (%eax),%ecx
f0104f52:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f57:	8d 40 04             	lea    0x4(%eax),%eax
f0104f5a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104f5d:	ba 10 00 00 00       	mov    $0x10,%edx
f0104f62:	eb a6                	jmp    f0104f0a <.L37+0x2b>
		return va_arg(*ap, unsigned long);
f0104f64:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f67:	8b 08                	mov    (%eax),%ecx
f0104f69:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f6e:	8d 40 04             	lea    0x4(%eax),%eax
f0104f71:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104f74:	ba 10 00 00 00       	mov    $0x10,%edx
f0104f79:	eb 8f                	jmp    f0104f0a <.L37+0x2b>

f0104f7b <.L27>:
f0104f7b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(ch, putdat);
f0104f7e:	83 ec 08             	sub    $0x8,%esp
f0104f81:	56                   	push   %esi
f0104f82:	6a 25                	push   $0x25
f0104f84:	ff d7                	call   *%edi
			break;
f0104f86:	83 c4 10             	add    $0x10,%esp
f0104f89:	e9 32 fb ff ff       	jmp    f0104ac0 <vprintfmt+0x1c>

f0104f8e <.L24>:
f0104f8e:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch('%', putdat);
f0104f91:	83 ec 08             	sub    $0x8,%esp
f0104f94:	56                   	push   %esi
f0104f95:	6a 25                	push   $0x25
f0104f97:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104f99:	83 c4 10             	add    $0x10,%esp
f0104f9c:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0104fa0:	0f 84 4e fb ff ff    	je     f0104af4 <vprintfmt+0x50>
f0104fa6:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104fa9:	89 d8                	mov    %ebx,%eax
f0104fab:	83 e8 01             	sub    $0x1,%eax
f0104fae:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104fb2:	75 f7                	jne    f0104fab <.L24+0x1d>
f0104fb4:	89 45 10             	mov    %eax,0x10(%ebp)
f0104fb7:	e9 04 fb ff ff       	jmp    f0104ac0 <vprintfmt+0x1c>
			if ((p = va_arg(ap, char *)) == NULL)
f0104fbc:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104fbf:	89 45 14             	mov    %eax,0x14(%ebp)
f0104fc2:	e9 f9 fa ff ff       	jmp    f0104ac0 <vprintfmt+0x1c>
			if (width > 0 && padc != '-')
f0104fc7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104fcb:	7e 0a                	jle    f0104fd7 <.L24+0x49>
f0104fcd:	80 7d d7 2d          	cmpb   $0x2d,-0x29(%ebp)
f0104fd1:	0f 85 e7 fc ff ff    	jne    f0104cbe <.L38+0x4d>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104fd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104fda:	8d 98 18 9c f7 ff    	lea    -0x863e8(%eax),%ebx
f0104fe0:	b8 28 00 00 00       	mov    $0x28,%eax
f0104fe5:	ba 28 00 00 00       	mov    $0x28,%edx
f0104fea:	89 7d 08             	mov    %edi,0x8(%ebp)
f0104fed:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0104ff0:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104ff3:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104ff6:	e9 47 fd ff ff       	jmp    f0104d42 <.L38+0xd1>

f0104ffb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104ffb:	55                   	push   %ebp
f0104ffc:	89 e5                	mov    %esp,%ebp
f0104ffe:	53                   	push   %ebx
f0104fff:	83 ec 14             	sub    $0x14,%esp
f0105002:	e8 66 b1 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0105007:	81 c3 1d 80 08 00    	add    $0x8801d,%ebx
f010500d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105010:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105013:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105016:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010501a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010501d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105024:	85 c0                	test   %eax,%eax
f0105026:	74 2b                	je     f0105053 <vsnprintf+0x58>
f0105028:	85 d2                	test   %edx,%edx
f010502a:	7e 27                	jle    f0105053 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010502c:	ff 75 14             	pushl  0x14(%ebp)
f010502f:	ff 75 10             	pushl  0x10(%ebp)
f0105032:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105035:	50                   	push   %eax
f0105036:	8d 83 46 7a f7 ff    	lea    -0x885ba(%ebx),%eax
f010503c:	50                   	push   %eax
f010503d:	e8 62 fa ff ff       	call   f0104aa4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105042:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105045:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105048:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010504b:	83 c4 10             	add    $0x10,%esp
}
f010504e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105051:	c9                   	leave  
f0105052:	c3                   	ret    
		return -E_INVAL;
f0105053:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105058:	eb f4                	jmp    f010504e <vsnprintf+0x53>

f010505a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010505a:	55                   	push   %ebp
f010505b:	89 e5                	mov    %esp,%ebp
f010505d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105060:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105063:	50                   	push   %eax
f0105064:	ff 75 10             	pushl  0x10(%ebp)
f0105067:	ff 75 0c             	pushl  0xc(%ebp)
f010506a:	ff 75 08             	pushl  0x8(%ebp)
f010506d:	e8 89 ff ff ff       	call   f0104ffb <vsnprintf>
	va_end(ap);

	return rc;
}
f0105072:	c9                   	leave  
f0105073:	c3                   	ret    

f0105074 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105074:	55                   	push   %ebp
f0105075:	89 e5                	mov    %esp,%ebp
f0105077:	57                   	push   %edi
f0105078:	56                   	push   %esi
f0105079:	53                   	push   %ebx
f010507a:	83 ec 1c             	sub    $0x1c,%esp
f010507d:	e8 eb b0 ff ff       	call   f010016d <__x86.get_pc_thunk.bx>
f0105082:	81 c3 a2 7f 08 00    	add    $0x87fa2,%ebx
f0105088:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010508b:	85 c0                	test   %eax,%eax
f010508d:	74 13                	je     f01050a2 <readline+0x2e>
		cprintf("%s", prompt);
f010508f:	83 ec 08             	sub    $0x8,%esp
f0105092:	50                   	push   %eax
f0105093:	8d 83 cc 8c f7 ff    	lea    -0x87334(%ebx),%eax
f0105099:	50                   	push   %eax
f010509a:	e8 e6 ea ff ff       	call   f0103b85 <cprintf>
f010509f:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01050a2:	83 ec 0c             	sub    $0xc,%esp
f01050a5:	6a 00                	push   $0x0
f01050a7:	e8 5a b6 ff ff       	call   f0100706 <iscons>
f01050ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01050af:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01050b2:	bf 00 00 00 00       	mov    $0x0,%edi
f01050b7:	eb 46                	jmp    f01050ff <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01050b9:	83 ec 08             	sub    $0x8,%esp
f01050bc:	50                   	push   %eax
f01050bd:	8d 83 e8 9d f7 ff    	lea    -0x86218(%ebx),%eax
f01050c3:	50                   	push   %eax
f01050c4:	e8 bc ea ff ff       	call   f0103b85 <cprintf>
			return NULL;
f01050c9:	83 c4 10             	add    $0x10,%esp
f01050cc:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01050d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050d4:	5b                   	pop    %ebx
f01050d5:	5e                   	pop    %esi
f01050d6:	5f                   	pop    %edi
f01050d7:	5d                   	pop    %ebp
f01050d8:	c3                   	ret    
			if (echoing)
f01050d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01050dd:	75 05                	jne    f01050e4 <readline+0x70>
			i--;
f01050df:	83 ef 01             	sub    $0x1,%edi
f01050e2:	eb 1b                	jmp    f01050ff <readline+0x8b>
				cputchar('\b');
f01050e4:	83 ec 0c             	sub    $0xc,%esp
f01050e7:	6a 08                	push   $0x8
f01050e9:	e8 f7 b5 ff ff       	call   f01006e5 <cputchar>
f01050ee:	83 c4 10             	add    $0x10,%esp
f01050f1:	eb ec                	jmp    f01050df <readline+0x6b>
			buf[i++] = c;
f01050f3:	89 f0                	mov    %esi,%eax
f01050f5:	88 84 3b dc 2b 00 00 	mov    %al,0x2bdc(%ebx,%edi,1)
f01050fc:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01050ff:	e8 f1 b5 ff ff       	call   f01006f5 <getchar>
f0105104:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0105106:	85 c0                	test   %eax,%eax
f0105108:	78 af                	js     f01050b9 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010510a:	83 f8 08             	cmp    $0x8,%eax
f010510d:	0f 94 c2             	sete   %dl
f0105110:	83 f8 7f             	cmp    $0x7f,%eax
f0105113:	0f 94 c0             	sete   %al
f0105116:	08 c2                	or     %al,%dl
f0105118:	74 04                	je     f010511e <readline+0xaa>
f010511a:	85 ff                	test   %edi,%edi
f010511c:	7f bb                	jg     f01050d9 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010511e:	83 fe 1f             	cmp    $0x1f,%esi
f0105121:	7e 1c                	jle    f010513f <readline+0xcb>
f0105123:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0105129:	7f 14                	jg     f010513f <readline+0xcb>
			if (echoing)
f010512b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010512f:	74 c2                	je     f01050f3 <readline+0x7f>
				cputchar(c);
f0105131:	83 ec 0c             	sub    $0xc,%esp
f0105134:	56                   	push   %esi
f0105135:	e8 ab b5 ff ff       	call   f01006e5 <cputchar>
f010513a:	83 c4 10             	add    $0x10,%esp
f010513d:	eb b4                	jmp    f01050f3 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f010513f:	83 fe 0a             	cmp    $0xa,%esi
f0105142:	74 05                	je     f0105149 <readline+0xd5>
f0105144:	83 fe 0d             	cmp    $0xd,%esi
f0105147:	75 b6                	jne    f01050ff <readline+0x8b>
			if (echoing)
f0105149:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010514d:	75 13                	jne    f0105162 <readline+0xee>
			buf[i] = 0;
f010514f:	c6 84 3b dc 2b 00 00 	movb   $0x0,0x2bdc(%ebx,%edi,1)
f0105156:	00 
			return buf;
f0105157:	8d 83 dc 2b 00 00    	lea    0x2bdc(%ebx),%eax
f010515d:	e9 6f ff ff ff       	jmp    f01050d1 <readline+0x5d>
				cputchar('\n');
f0105162:	83 ec 0c             	sub    $0xc,%esp
f0105165:	6a 0a                	push   $0xa
f0105167:	e8 79 b5 ff ff       	call   f01006e5 <cputchar>
f010516c:	83 c4 10             	add    $0x10,%esp
f010516f:	eb de                	jmp    f010514f <readline+0xdb>

f0105171 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105171:	55                   	push   %ebp
f0105172:	89 e5                	mov    %esp,%ebp
f0105174:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105177:	80 3a 00             	cmpb   $0x0,(%edx)
f010517a:	74 10                	je     f010518c <strlen+0x1b>
f010517c:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105181:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0105184:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105188:	75 f7                	jne    f0105181 <strlen+0x10>
	return n;
}
f010518a:	5d                   	pop    %ebp
f010518b:	c3                   	ret    
	for (n = 0; *s != '\0'; s++)
f010518c:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
f0105191:	eb f7                	jmp    f010518a <strlen+0x19>

f0105193 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105193:	55                   	push   %ebp
f0105194:	89 e5                	mov    %esp,%ebp
f0105196:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105199:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010519c:	85 d2                	test   %edx,%edx
f010519e:	74 19                	je     f01051b9 <strnlen+0x26>
f01051a0:	80 39 00             	cmpb   $0x0,(%ecx)
f01051a3:	74 1b                	je     f01051c0 <strnlen+0x2d>
f01051a5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01051aa:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01051ad:	39 c2                	cmp    %eax,%edx
f01051af:	74 06                	je     f01051b7 <strnlen+0x24>
f01051b1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01051b5:	75 f3                	jne    f01051aa <strnlen+0x17>
	return n;
}
f01051b7:	5d                   	pop    %ebp
f01051b8:	c3                   	ret    
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01051b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01051be:	eb f7                	jmp    f01051b7 <strnlen+0x24>
f01051c0:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
f01051c5:	eb f0                	jmp    f01051b7 <strnlen+0x24>

f01051c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01051c7:	55                   	push   %ebp
f01051c8:	89 e5                	mov    %esp,%ebp
f01051ca:	53                   	push   %ebx
f01051cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01051ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01051d1:	89 c2                	mov    %eax,%edx
f01051d3:	83 c1 01             	add    $0x1,%ecx
f01051d6:	83 c2 01             	add    $0x1,%edx
f01051d9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01051dd:	88 5a ff             	mov    %bl,-0x1(%edx)
f01051e0:	84 db                	test   %bl,%bl
f01051e2:	75 ef                	jne    f01051d3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01051e4:	5b                   	pop    %ebx
f01051e5:	5d                   	pop    %ebp
f01051e6:	c3                   	ret    

f01051e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01051e7:	55                   	push   %ebp
f01051e8:	89 e5                	mov    %esp,%ebp
f01051ea:	53                   	push   %ebx
f01051eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01051ee:	53                   	push   %ebx
f01051ef:	e8 7d ff ff ff       	call   f0105171 <strlen>
f01051f4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01051f7:	ff 75 0c             	pushl  0xc(%ebp)
f01051fa:	01 d8                	add    %ebx,%eax
f01051fc:	50                   	push   %eax
f01051fd:	e8 c5 ff ff ff       	call   f01051c7 <strcpy>
	return dst;
}
f0105202:	89 d8                	mov    %ebx,%eax
f0105204:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105207:	c9                   	leave  
f0105208:	c3                   	ret    

f0105209 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105209:	55                   	push   %ebp
f010520a:	89 e5                	mov    %esp,%ebp
f010520c:	56                   	push   %esi
f010520d:	53                   	push   %ebx
f010520e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105211:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105214:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105217:	85 db                	test   %ebx,%ebx
f0105219:	74 17                	je     f0105232 <strncpy+0x29>
f010521b:	01 f3                	add    %esi,%ebx
f010521d:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f010521f:	83 c1 01             	add    $0x1,%ecx
f0105222:	0f b6 02             	movzbl (%edx),%eax
f0105225:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105228:	80 3a 01             	cmpb   $0x1,(%edx)
f010522b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f010522e:	39 cb                	cmp    %ecx,%ebx
f0105230:	75 ed                	jne    f010521f <strncpy+0x16>
	}
	return ret;
}
f0105232:	89 f0                	mov    %esi,%eax
f0105234:	5b                   	pop    %ebx
f0105235:	5e                   	pop    %esi
f0105236:	5d                   	pop    %ebp
f0105237:	c3                   	ret    

f0105238 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105238:	55                   	push   %ebp
f0105239:	89 e5                	mov    %esp,%ebp
f010523b:	57                   	push   %edi
f010523c:	56                   	push   %esi
f010523d:	53                   	push   %ebx
f010523e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105241:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105244:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105247:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105249:	85 db                	test   %ebx,%ebx
f010524b:	74 2b                	je     f0105278 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f010524d:	83 fb 01             	cmp    $0x1,%ebx
f0105250:	74 23                	je     f0105275 <strlcpy+0x3d>
f0105252:	0f b6 0f             	movzbl (%edi),%ecx
f0105255:	84 c9                	test   %cl,%cl
f0105257:	74 1c                	je     f0105275 <strlcpy+0x3d>
f0105259:	8d 57 01             	lea    0x1(%edi),%edx
f010525c:	8d 5c 1f ff          	lea    -0x1(%edi,%ebx,1),%ebx
			*dst++ = *src++;
f0105260:	83 c0 01             	add    $0x1,%eax
f0105263:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105266:	39 da                	cmp    %ebx,%edx
f0105268:	74 0b                	je     f0105275 <strlcpy+0x3d>
f010526a:	83 c2 01             	add    $0x1,%edx
f010526d:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
f0105271:	84 c9                	test   %cl,%cl
f0105273:	75 eb                	jne    f0105260 <strlcpy+0x28>
		*dst = '\0';
f0105275:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105278:	29 f0                	sub    %esi,%eax
}
f010527a:	5b                   	pop    %ebx
f010527b:	5e                   	pop    %esi
f010527c:	5f                   	pop    %edi
f010527d:	5d                   	pop    %ebp
f010527e:	c3                   	ret    

f010527f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010527f:	55                   	push   %ebp
f0105280:	89 e5                	mov    %esp,%ebp
f0105282:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105285:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105288:	0f b6 01             	movzbl (%ecx),%eax
f010528b:	84 c0                	test   %al,%al
f010528d:	74 15                	je     f01052a4 <strcmp+0x25>
f010528f:	3a 02                	cmp    (%edx),%al
f0105291:	75 11                	jne    f01052a4 <strcmp+0x25>
		p++, q++;
f0105293:	83 c1 01             	add    $0x1,%ecx
f0105296:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105299:	0f b6 01             	movzbl (%ecx),%eax
f010529c:	84 c0                	test   %al,%al
f010529e:	74 04                	je     f01052a4 <strcmp+0x25>
f01052a0:	3a 02                	cmp    (%edx),%al
f01052a2:	74 ef                	je     f0105293 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01052a4:	0f b6 c0             	movzbl %al,%eax
f01052a7:	0f b6 12             	movzbl (%edx),%edx
f01052aa:	29 d0                	sub    %edx,%eax
}
f01052ac:	5d                   	pop    %ebp
f01052ad:	c3                   	ret    

f01052ae <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01052ae:	55                   	push   %ebp
f01052af:	89 e5                	mov    %esp,%ebp
f01052b1:	53                   	push   %ebx
f01052b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01052b5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01052b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01052bb:	85 db                	test   %ebx,%ebx
f01052bd:	74 2d                	je     f01052ec <strncmp+0x3e>
f01052bf:	0f b6 08             	movzbl (%eax),%ecx
f01052c2:	84 c9                	test   %cl,%cl
f01052c4:	74 1b                	je     f01052e1 <strncmp+0x33>
f01052c6:	3a 0a                	cmp    (%edx),%cl
f01052c8:	75 17                	jne    f01052e1 <strncmp+0x33>
f01052ca:	01 c3                	add    %eax,%ebx
		n--, p++, q++;
f01052cc:	83 c0 01             	add    $0x1,%eax
f01052cf:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01052d2:	39 d8                	cmp    %ebx,%eax
f01052d4:	74 1d                	je     f01052f3 <strncmp+0x45>
f01052d6:	0f b6 08             	movzbl (%eax),%ecx
f01052d9:	84 c9                	test   %cl,%cl
f01052db:	74 04                	je     f01052e1 <strncmp+0x33>
f01052dd:	3a 0a                	cmp    (%edx),%cl
f01052df:	74 eb                	je     f01052cc <strncmp+0x1e>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01052e1:	0f b6 00             	movzbl (%eax),%eax
f01052e4:	0f b6 12             	movzbl (%edx),%edx
f01052e7:	29 d0                	sub    %edx,%eax
}
f01052e9:	5b                   	pop    %ebx
f01052ea:	5d                   	pop    %ebp
f01052eb:	c3                   	ret    
		return 0;
f01052ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01052f1:	eb f6                	jmp    f01052e9 <strncmp+0x3b>
f01052f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01052f8:	eb ef                	jmp    f01052e9 <strncmp+0x3b>

f01052fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01052fa:	55                   	push   %ebp
f01052fb:	89 e5                	mov    %esp,%ebp
f01052fd:	53                   	push   %ebx
f01052fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0105301:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
f0105304:	0f b6 10             	movzbl (%eax),%edx
f0105307:	84 d2                	test   %dl,%dl
f0105309:	74 1e                	je     f0105329 <strchr+0x2f>
f010530b:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
f010530d:	38 d3                	cmp    %dl,%bl
f010530f:	74 15                	je     f0105326 <strchr+0x2c>
	for (; *s; s++)
f0105311:	83 c0 01             	add    $0x1,%eax
f0105314:	0f b6 10             	movzbl (%eax),%edx
f0105317:	84 d2                	test   %dl,%dl
f0105319:	74 06                	je     f0105321 <strchr+0x27>
		if (*s == c)
f010531b:	38 ca                	cmp    %cl,%dl
f010531d:	75 f2                	jne    f0105311 <strchr+0x17>
f010531f:	eb 05                	jmp    f0105326 <strchr+0x2c>
			return (char *) s;
	return 0;
f0105321:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105326:	5b                   	pop    %ebx
f0105327:	5d                   	pop    %ebp
f0105328:	c3                   	ret    
	return 0;
f0105329:	b8 00 00 00 00       	mov    $0x0,%eax
f010532e:	eb f6                	jmp    f0105326 <strchr+0x2c>

f0105330 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105330:	55                   	push   %ebp
f0105331:	89 e5                	mov    %esp,%ebp
f0105333:	53                   	push   %ebx
f0105334:	8b 45 08             	mov    0x8(%ebp),%eax
f0105337:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f010533a:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
f010533d:	38 d3                	cmp    %dl,%bl
f010533f:	74 14                	je     f0105355 <strfind+0x25>
f0105341:	89 d1                	mov    %edx,%ecx
f0105343:	84 db                	test   %bl,%bl
f0105345:	74 0e                	je     f0105355 <strfind+0x25>
	for (; *s; s++)
f0105347:	83 c0 01             	add    $0x1,%eax
f010534a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010534d:	38 ca                	cmp    %cl,%dl
f010534f:	74 04                	je     f0105355 <strfind+0x25>
f0105351:	84 d2                	test   %dl,%dl
f0105353:	75 f2                	jne    f0105347 <strfind+0x17>
			break;
	return (char *) s;
}
f0105355:	5b                   	pop    %ebx
f0105356:	5d                   	pop    %ebp
f0105357:	c3                   	ret    

f0105358 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105358:	55                   	push   %ebp
f0105359:	89 e5                	mov    %esp,%ebp
f010535b:	57                   	push   %edi
f010535c:	56                   	push   %esi
f010535d:	53                   	push   %ebx
f010535e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105361:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105364:	85 c9                	test   %ecx,%ecx
f0105366:	74 13                	je     f010537b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105368:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010536e:	75 05                	jne    f0105375 <memset+0x1d>
f0105370:	f6 c1 03             	test   $0x3,%cl
f0105373:	74 0d                	je     f0105382 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105375:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105378:	fc                   	cld    
f0105379:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010537b:	89 f8                	mov    %edi,%eax
f010537d:	5b                   	pop    %ebx
f010537e:	5e                   	pop    %esi
f010537f:	5f                   	pop    %edi
f0105380:	5d                   	pop    %ebp
f0105381:	c3                   	ret    
		c &= 0xFF;
f0105382:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105386:	89 d3                	mov    %edx,%ebx
f0105388:	c1 e3 08             	shl    $0x8,%ebx
f010538b:	89 d0                	mov    %edx,%eax
f010538d:	c1 e0 18             	shl    $0x18,%eax
f0105390:	89 d6                	mov    %edx,%esi
f0105392:	c1 e6 10             	shl    $0x10,%esi
f0105395:	09 f0                	or     %esi,%eax
f0105397:	09 c2                	or     %eax,%edx
f0105399:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f010539b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010539e:	89 d0                	mov    %edx,%eax
f01053a0:	fc                   	cld    
f01053a1:	f3 ab                	rep stos %eax,%es:(%edi)
f01053a3:	eb d6                	jmp    f010537b <memset+0x23>

f01053a5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01053a5:	55                   	push   %ebp
f01053a6:	89 e5                	mov    %esp,%ebp
f01053a8:	57                   	push   %edi
f01053a9:	56                   	push   %esi
f01053aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01053ad:	8b 75 0c             	mov    0xc(%ebp),%esi
f01053b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01053b3:	39 c6                	cmp    %eax,%esi
f01053b5:	73 35                	jae    f01053ec <memmove+0x47>
f01053b7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01053ba:	39 c2                	cmp    %eax,%edx
f01053bc:	76 2e                	jbe    f01053ec <memmove+0x47>
		s += n;
		d += n;
f01053be:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01053c1:	89 d6                	mov    %edx,%esi
f01053c3:	09 fe                	or     %edi,%esi
f01053c5:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01053cb:	74 0c                	je     f01053d9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01053cd:	83 ef 01             	sub    $0x1,%edi
f01053d0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01053d3:	fd                   	std    
f01053d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01053d6:	fc                   	cld    
f01053d7:	eb 21                	jmp    f01053fa <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01053d9:	f6 c1 03             	test   $0x3,%cl
f01053dc:	75 ef                	jne    f01053cd <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01053de:	83 ef 04             	sub    $0x4,%edi
f01053e1:	8d 72 fc             	lea    -0x4(%edx),%esi
f01053e4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01053e7:	fd                   	std    
f01053e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01053ea:	eb ea                	jmp    f01053d6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01053ec:	89 f2                	mov    %esi,%edx
f01053ee:	09 c2                	or     %eax,%edx
f01053f0:	f6 c2 03             	test   $0x3,%dl
f01053f3:	74 09                	je     f01053fe <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01053f5:	89 c7                	mov    %eax,%edi
f01053f7:	fc                   	cld    
f01053f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01053fa:	5e                   	pop    %esi
f01053fb:	5f                   	pop    %edi
f01053fc:	5d                   	pop    %ebp
f01053fd:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01053fe:	f6 c1 03             	test   $0x3,%cl
f0105401:	75 f2                	jne    f01053f5 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105403:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105406:	89 c7                	mov    %eax,%edi
f0105408:	fc                   	cld    
f0105409:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010540b:	eb ed                	jmp    f01053fa <memmove+0x55>

f010540d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010540d:	55                   	push   %ebp
f010540e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105410:	ff 75 10             	pushl  0x10(%ebp)
f0105413:	ff 75 0c             	pushl  0xc(%ebp)
f0105416:	ff 75 08             	pushl  0x8(%ebp)
f0105419:	e8 87 ff ff ff       	call   f01053a5 <memmove>
}
f010541e:	c9                   	leave  
f010541f:	c3                   	ret    

f0105420 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105420:	55                   	push   %ebp
f0105421:	89 e5                	mov    %esp,%ebp
f0105423:	57                   	push   %edi
f0105424:	56                   	push   %esi
f0105425:	53                   	push   %ebx
f0105426:	8b 75 08             	mov    0x8(%ebp),%esi
f0105429:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010542c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010542f:	85 db                	test   %ebx,%ebx
f0105431:	74 37                	je     f010546a <memcmp+0x4a>
		if (*s1 != *s2)
f0105433:	0f b6 16             	movzbl (%esi),%edx
f0105436:	0f b6 0f             	movzbl (%edi),%ecx
f0105439:	38 ca                	cmp    %cl,%dl
f010543b:	75 19                	jne    f0105456 <memcmp+0x36>
f010543d:	b8 01 00 00 00       	mov    $0x1,%eax
	while (n-- > 0) {
f0105442:	39 d8                	cmp    %ebx,%eax
f0105444:	74 1d                	je     f0105463 <memcmp+0x43>
		if (*s1 != *s2)
f0105446:	0f b6 14 06          	movzbl (%esi,%eax,1),%edx
f010544a:	83 c0 01             	add    $0x1,%eax
f010544d:	0f b6 4c 07 ff       	movzbl -0x1(%edi,%eax,1),%ecx
f0105452:	38 ca                	cmp    %cl,%dl
f0105454:	74 ec                	je     f0105442 <memcmp+0x22>
			return (int) *s1 - (int) *s2;
f0105456:	0f b6 c2             	movzbl %dl,%eax
f0105459:	0f b6 c9             	movzbl %cl,%ecx
f010545c:	29 c8                	sub    %ecx,%eax
		s1++, s2++;
	}

	return 0;
}
f010545e:	5b                   	pop    %ebx
f010545f:	5e                   	pop    %esi
f0105460:	5f                   	pop    %edi
f0105461:	5d                   	pop    %ebp
f0105462:	c3                   	ret    
	return 0;
f0105463:	b8 00 00 00 00       	mov    $0x0,%eax
f0105468:	eb f4                	jmp    f010545e <memcmp+0x3e>
f010546a:	b8 00 00 00 00       	mov    $0x0,%eax
f010546f:	eb ed                	jmp    f010545e <memcmp+0x3e>

f0105471 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105471:	55                   	push   %ebp
f0105472:	89 e5                	mov    %esp,%ebp
f0105474:	53                   	push   %ebx
f0105475:	8b 45 08             	mov    0x8(%ebp),%eax
f0105478:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
f010547b:	89 c2                	mov    %eax,%edx
f010547d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105480:	39 d0                	cmp    %edx,%eax
f0105482:	73 11                	jae    f0105495 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105484:	89 d9                	mov    %ebx,%ecx
f0105486:	38 18                	cmp    %bl,(%eax)
f0105488:	74 0b                	je     f0105495 <memfind+0x24>
	for (; s < ends; s++)
f010548a:	83 c0 01             	add    $0x1,%eax
f010548d:	39 c2                	cmp    %eax,%edx
f010548f:	74 04                	je     f0105495 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105491:	38 08                	cmp    %cl,(%eax)
f0105493:	75 f5                	jne    f010548a <memfind+0x19>
			break;
	return (void *) s;
}
f0105495:	5b                   	pop    %ebx
f0105496:	5d                   	pop    %ebp
f0105497:	c3                   	ret    

f0105498 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105498:	55                   	push   %ebp
f0105499:	89 e5                	mov    %esp,%ebp
f010549b:	57                   	push   %edi
f010549c:	56                   	push   %esi
f010549d:	53                   	push   %ebx
f010549e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01054a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01054a4:	0f b6 01             	movzbl (%ecx),%eax
f01054a7:	3c 20                	cmp    $0x20,%al
f01054a9:	74 04                	je     f01054af <strtol+0x17>
f01054ab:	3c 09                	cmp    $0x9,%al
f01054ad:	75 0e                	jne    f01054bd <strtol+0x25>
		s++;
f01054af:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01054b2:	0f b6 01             	movzbl (%ecx),%eax
f01054b5:	3c 20                	cmp    $0x20,%al
f01054b7:	74 f6                	je     f01054af <strtol+0x17>
f01054b9:	3c 09                	cmp    $0x9,%al
f01054bb:	74 f2                	je     f01054af <strtol+0x17>

	// plus/minus sign
	if (*s == '+')
f01054bd:	3c 2b                	cmp    $0x2b,%al
f01054bf:	74 2e                	je     f01054ef <strtol+0x57>
	int neg = 0;
f01054c1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01054c6:	3c 2d                	cmp    $0x2d,%al
f01054c8:	74 2f                	je     f01054f9 <strtol+0x61>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01054ca:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01054d0:	75 05                	jne    f01054d7 <strtol+0x3f>
f01054d2:	80 39 30             	cmpb   $0x30,(%ecx)
f01054d5:	74 2c                	je     f0105503 <strtol+0x6b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01054d7:	85 db                	test   %ebx,%ebx
f01054d9:	75 0a                	jne    f01054e5 <strtol+0x4d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01054db:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01054e0:	80 39 30             	cmpb   $0x30,(%ecx)
f01054e3:	74 28                	je     f010550d <strtol+0x75>
		base = 10;
f01054e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01054ea:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01054ed:	eb 50                	jmp    f010553f <strtol+0xa7>
		s++;
f01054ef:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01054f2:	bf 00 00 00 00       	mov    $0x0,%edi
f01054f7:	eb d1                	jmp    f01054ca <strtol+0x32>
		s++, neg = 1;
f01054f9:	83 c1 01             	add    $0x1,%ecx
f01054fc:	bf 01 00 00 00       	mov    $0x1,%edi
f0105501:	eb c7                	jmp    f01054ca <strtol+0x32>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105503:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105507:	74 0e                	je     f0105517 <strtol+0x7f>
	else if (base == 0 && s[0] == '0')
f0105509:	85 db                	test   %ebx,%ebx
f010550b:	75 d8                	jne    f01054e5 <strtol+0x4d>
		s++, base = 8;
f010550d:	83 c1 01             	add    $0x1,%ecx
f0105510:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105515:	eb ce                	jmp    f01054e5 <strtol+0x4d>
		s += 2, base = 16;
f0105517:	83 c1 02             	add    $0x2,%ecx
f010551a:	bb 10 00 00 00       	mov    $0x10,%ebx
f010551f:	eb c4                	jmp    f01054e5 <strtol+0x4d>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0105521:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105524:	89 f3                	mov    %esi,%ebx
f0105526:	80 fb 19             	cmp    $0x19,%bl
f0105529:	77 29                	ja     f0105554 <strtol+0xbc>
			dig = *s - 'a' + 10;
f010552b:	0f be d2             	movsbl %dl,%edx
f010552e:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105531:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105534:	7d 30                	jge    f0105566 <strtol+0xce>
			break;
		s++, val = (val * base) + dig;
f0105536:	83 c1 01             	add    $0x1,%ecx
f0105539:	0f af 45 10          	imul   0x10(%ebp),%eax
f010553d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010553f:	0f b6 11             	movzbl (%ecx),%edx
f0105542:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105545:	89 f3                	mov    %esi,%ebx
f0105547:	80 fb 09             	cmp    $0x9,%bl
f010554a:	77 d5                	ja     f0105521 <strtol+0x89>
			dig = *s - '0';
f010554c:	0f be d2             	movsbl %dl,%edx
f010554f:	83 ea 30             	sub    $0x30,%edx
f0105552:	eb dd                	jmp    f0105531 <strtol+0x99>
		else if (*s >= 'A' && *s <= 'Z')
f0105554:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105557:	89 f3                	mov    %esi,%ebx
f0105559:	80 fb 19             	cmp    $0x19,%bl
f010555c:	77 08                	ja     f0105566 <strtol+0xce>
			dig = *s - 'A' + 10;
f010555e:	0f be d2             	movsbl %dl,%edx
f0105561:	83 ea 37             	sub    $0x37,%edx
f0105564:	eb cb                	jmp    f0105531 <strtol+0x99>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105566:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010556a:	74 05                	je     f0105571 <strtol+0xd9>
		*endptr = (char *) s;
f010556c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010556f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105571:	89 c2                	mov    %eax,%edx
f0105573:	f7 da                	neg    %edx
f0105575:	85 ff                	test   %edi,%edi
f0105577:	0f 45 c2             	cmovne %edx,%eax
}
f010557a:	5b                   	pop    %ebx
f010557b:	5e                   	pop    %esi
f010557c:	5f                   	pop    %edi
f010557d:	5d                   	pop    %ebp
f010557e:	c3                   	ret    
f010557f:	90                   	nop

f0105580 <__udivdi3>:
f0105580:	55                   	push   %ebp
f0105581:	57                   	push   %edi
f0105582:	56                   	push   %esi
f0105583:	53                   	push   %ebx
f0105584:	83 ec 1c             	sub    $0x1c,%esp
f0105587:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010558b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010558f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105593:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0105597:	85 d2                	test   %edx,%edx
f0105599:	75 35                	jne    f01055d0 <__udivdi3+0x50>
f010559b:	39 f3                	cmp    %esi,%ebx
f010559d:	0f 87 bd 00 00 00    	ja     f0105660 <__udivdi3+0xe0>
f01055a3:	85 db                	test   %ebx,%ebx
f01055a5:	89 d9                	mov    %ebx,%ecx
f01055a7:	75 0b                	jne    f01055b4 <__udivdi3+0x34>
f01055a9:	b8 01 00 00 00       	mov    $0x1,%eax
f01055ae:	31 d2                	xor    %edx,%edx
f01055b0:	f7 f3                	div    %ebx
f01055b2:	89 c1                	mov    %eax,%ecx
f01055b4:	31 d2                	xor    %edx,%edx
f01055b6:	89 f0                	mov    %esi,%eax
f01055b8:	f7 f1                	div    %ecx
f01055ba:	89 c6                	mov    %eax,%esi
f01055bc:	89 e8                	mov    %ebp,%eax
f01055be:	89 f7                	mov    %esi,%edi
f01055c0:	f7 f1                	div    %ecx
f01055c2:	89 fa                	mov    %edi,%edx
f01055c4:	83 c4 1c             	add    $0x1c,%esp
f01055c7:	5b                   	pop    %ebx
f01055c8:	5e                   	pop    %esi
f01055c9:	5f                   	pop    %edi
f01055ca:	5d                   	pop    %ebp
f01055cb:	c3                   	ret    
f01055cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01055d0:	39 f2                	cmp    %esi,%edx
f01055d2:	77 7c                	ja     f0105650 <__udivdi3+0xd0>
f01055d4:	0f bd fa             	bsr    %edx,%edi
f01055d7:	83 f7 1f             	xor    $0x1f,%edi
f01055da:	0f 84 98 00 00 00    	je     f0105678 <__udivdi3+0xf8>
f01055e0:	89 f9                	mov    %edi,%ecx
f01055e2:	b8 20 00 00 00       	mov    $0x20,%eax
f01055e7:	29 f8                	sub    %edi,%eax
f01055e9:	d3 e2                	shl    %cl,%edx
f01055eb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01055ef:	89 c1                	mov    %eax,%ecx
f01055f1:	89 da                	mov    %ebx,%edx
f01055f3:	d3 ea                	shr    %cl,%edx
f01055f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01055f9:	09 d1                	or     %edx,%ecx
f01055fb:	89 f2                	mov    %esi,%edx
f01055fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105601:	89 f9                	mov    %edi,%ecx
f0105603:	d3 e3                	shl    %cl,%ebx
f0105605:	89 c1                	mov    %eax,%ecx
f0105607:	d3 ea                	shr    %cl,%edx
f0105609:	89 f9                	mov    %edi,%ecx
f010560b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010560f:	d3 e6                	shl    %cl,%esi
f0105611:	89 eb                	mov    %ebp,%ebx
f0105613:	89 c1                	mov    %eax,%ecx
f0105615:	d3 eb                	shr    %cl,%ebx
f0105617:	09 de                	or     %ebx,%esi
f0105619:	89 f0                	mov    %esi,%eax
f010561b:	f7 74 24 08          	divl   0x8(%esp)
f010561f:	89 d6                	mov    %edx,%esi
f0105621:	89 c3                	mov    %eax,%ebx
f0105623:	f7 64 24 0c          	mull   0xc(%esp)
f0105627:	39 d6                	cmp    %edx,%esi
f0105629:	72 0c                	jb     f0105637 <__udivdi3+0xb7>
f010562b:	89 f9                	mov    %edi,%ecx
f010562d:	d3 e5                	shl    %cl,%ebp
f010562f:	39 c5                	cmp    %eax,%ebp
f0105631:	73 5d                	jae    f0105690 <__udivdi3+0x110>
f0105633:	39 d6                	cmp    %edx,%esi
f0105635:	75 59                	jne    f0105690 <__udivdi3+0x110>
f0105637:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010563a:	31 ff                	xor    %edi,%edi
f010563c:	89 fa                	mov    %edi,%edx
f010563e:	83 c4 1c             	add    $0x1c,%esp
f0105641:	5b                   	pop    %ebx
f0105642:	5e                   	pop    %esi
f0105643:	5f                   	pop    %edi
f0105644:	5d                   	pop    %ebp
f0105645:	c3                   	ret    
f0105646:	8d 76 00             	lea    0x0(%esi),%esi
f0105649:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0105650:	31 ff                	xor    %edi,%edi
f0105652:	31 c0                	xor    %eax,%eax
f0105654:	89 fa                	mov    %edi,%edx
f0105656:	83 c4 1c             	add    $0x1c,%esp
f0105659:	5b                   	pop    %ebx
f010565a:	5e                   	pop    %esi
f010565b:	5f                   	pop    %edi
f010565c:	5d                   	pop    %ebp
f010565d:	c3                   	ret    
f010565e:	66 90                	xchg   %ax,%ax
f0105660:	31 ff                	xor    %edi,%edi
f0105662:	89 e8                	mov    %ebp,%eax
f0105664:	89 f2                	mov    %esi,%edx
f0105666:	f7 f3                	div    %ebx
f0105668:	89 fa                	mov    %edi,%edx
f010566a:	83 c4 1c             	add    $0x1c,%esp
f010566d:	5b                   	pop    %ebx
f010566e:	5e                   	pop    %esi
f010566f:	5f                   	pop    %edi
f0105670:	5d                   	pop    %ebp
f0105671:	c3                   	ret    
f0105672:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105678:	39 f2                	cmp    %esi,%edx
f010567a:	72 06                	jb     f0105682 <__udivdi3+0x102>
f010567c:	31 c0                	xor    %eax,%eax
f010567e:	39 eb                	cmp    %ebp,%ebx
f0105680:	77 d2                	ja     f0105654 <__udivdi3+0xd4>
f0105682:	b8 01 00 00 00       	mov    $0x1,%eax
f0105687:	eb cb                	jmp    f0105654 <__udivdi3+0xd4>
f0105689:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105690:	89 d8                	mov    %ebx,%eax
f0105692:	31 ff                	xor    %edi,%edi
f0105694:	eb be                	jmp    f0105654 <__udivdi3+0xd4>
f0105696:	66 90                	xchg   %ax,%ax
f0105698:	66 90                	xchg   %ax,%ax
f010569a:	66 90                	xchg   %ax,%ax
f010569c:	66 90                	xchg   %ax,%ax
f010569e:	66 90                	xchg   %ax,%ax

f01056a0 <__umoddi3>:
f01056a0:	55                   	push   %ebp
f01056a1:	57                   	push   %edi
f01056a2:	56                   	push   %esi
f01056a3:	53                   	push   %ebx
f01056a4:	83 ec 1c             	sub    $0x1c,%esp
f01056a7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01056ab:	8b 74 24 30          	mov    0x30(%esp),%esi
f01056af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01056b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01056b7:	85 ed                	test   %ebp,%ebp
f01056b9:	89 f0                	mov    %esi,%eax
f01056bb:	89 da                	mov    %ebx,%edx
f01056bd:	75 19                	jne    f01056d8 <__umoddi3+0x38>
f01056bf:	39 df                	cmp    %ebx,%edi
f01056c1:	0f 86 b1 00 00 00    	jbe    f0105778 <__umoddi3+0xd8>
f01056c7:	f7 f7                	div    %edi
f01056c9:	89 d0                	mov    %edx,%eax
f01056cb:	31 d2                	xor    %edx,%edx
f01056cd:	83 c4 1c             	add    $0x1c,%esp
f01056d0:	5b                   	pop    %ebx
f01056d1:	5e                   	pop    %esi
f01056d2:	5f                   	pop    %edi
f01056d3:	5d                   	pop    %ebp
f01056d4:	c3                   	ret    
f01056d5:	8d 76 00             	lea    0x0(%esi),%esi
f01056d8:	39 dd                	cmp    %ebx,%ebp
f01056da:	77 f1                	ja     f01056cd <__umoddi3+0x2d>
f01056dc:	0f bd cd             	bsr    %ebp,%ecx
f01056df:	83 f1 1f             	xor    $0x1f,%ecx
f01056e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01056e6:	0f 84 b4 00 00 00    	je     f01057a0 <__umoddi3+0x100>
f01056ec:	b8 20 00 00 00       	mov    $0x20,%eax
f01056f1:	89 c2                	mov    %eax,%edx
f01056f3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01056f7:	29 c2                	sub    %eax,%edx
f01056f9:	89 c1                	mov    %eax,%ecx
f01056fb:	89 f8                	mov    %edi,%eax
f01056fd:	d3 e5                	shl    %cl,%ebp
f01056ff:	89 d1                	mov    %edx,%ecx
f0105701:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105705:	d3 e8                	shr    %cl,%eax
f0105707:	09 c5                	or     %eax,%ebp
f0105709:	8b 44 24 04          	mov    0x4(%esp),%eax
f010570d:	89 c1                	mov    %eax,%ecx
f010570f:	d3 e7                	shl    %cl,%edi
f0105711:	89 d1                	mov    %edx,%ecx
f0105713:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105717:	89 df                	mov    %ebx,%edi
f0105719:	d3 ef                	shr    %cl,%edi
f010571b:	89 c1                	mov    %eax,%ecx
f010571d:	89 f0                	mov    %esi,%eax
f010571f:	d3 e3                	shl    %cl,%ebx
f0105721:	89 d1                	mov    %edx,%ecx
f0105723:	89 fa                	mov    %edi,%edx
f0105725:	d3 e8                	shr    %cl,%eax
f0105727:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010572c:	09 d8                	or     %ebx,%eax
f010572e:	f7 f5                	div    %ebp
f0105730:	d3 e6                	shl    %cl,%esi
f0105732:	89 d1                	mov    %edx,%ecx
f0105734:	f7 64 24 08          	mull   0x8(%esp)
f0105738:	39 d1                	cmp    %edx,%ecx
f010573a:	89 c3                	mov    %eax,%ebx
f010573c:	89 d7                	mov    %edx,%edi
f010573e:	72 06                	jb     f0105746 <__umoddi3+0xa6>
f0105740:	75 0e                	jne    f0105750 <__umoddi3+0xb0>
f0105742:	39 c6                	cmp    %eax,%esi
f0105744:	73 0a                	jae    f0105750 <__umoddi3+0xb0>
f0105746:	2b 44 24 08          	sub    0x8(%esp),%eax
f010574a:	19 ea                	sbb    %ebp,%edx
f010574c:	89 d7                	mov    %edx,%edi
f010574e:	89 c3                	mov    %eax,%ebx
f0105750:	89 ca                	mov    %ecx,%edx
f0105752:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0105757:	29 de                	sub    %ebx,%esi
f0105759:	19 fa                	sbb    %edi,%edx
f010575b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010575f:	89 d0                	mov    %edx,%eax
f0105761:	d3 e0                	shl    %cl,%eax
f0105763:	89 d9                	mov    %ebx,%ecx
f0105765:	d3 ee                	shr    %cl,%esi
f0105767:	d3 ea                	shr    %cl,%edx
f0105769:	09 f0                	or     %esi,%eax
f010576b:	83 c4 1c             	add    $0x1c,%esp
f010576e:	5b                   	pop    %ebx
f010576f:	5e                   	pop    %esi
f0105770:	5f                   	pop    %edi
f0105771:	5d                   	pop    %ebp
f0105772:	c3                   	ret    
f0105773:	90                   	nop
f0105774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105778:	85 ff                	test   %edi,%edi
f010577a:	89 f9                	mov    %edi,%ecx
f010577c:	75 0b                	jne    f0105789 <__umoddi3+0xe9>
f010577e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105783:	31 d2                	xor    %edx,%edx
f0105785:	f7 f7                	div    %edi
f0105787:	89 c1                	mov    %eax,%ecx
f0105789:	89 d8                	mov    %ebx,%eax
f010578b:	31 d2                	xor    %edx,%edx
f010578d:	f7 f1                	div    %ecx
f010578f:	89 f0                	mov    %esi,%eax
f0105791:	f7 f1                	div    %ecx
f0105793:	e9 31 ff ff ff       	jmp    f01056c9 <__umoddi3+0x29>
f0105798:	90                   	nop
f0105799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01057a0:	39 dd                	cmp    %ebx,%ebp
f01057a2:	72 08                	jb     f01057ac <__umoddi3+0x10c>
f01057a4:	39 f7                	cmp    %esi,%edi
f01057a6:	0f 87 21 ff ff ff    	ja     f01056cd <__umoddi3+0x2d>
f01057ac:	89 da                	mov    %ebx,%edx
f01057ae:	89 f0                	mov    %esi,%eax
f01057b0:	29 f8                	sub    %edi,%eax
f01057b2:	19 ea                	sbb    %ebp,%edx
f01057b4:	e9 14 ff ff ff       	jmp    f01056cd <__umoddi3+0x2d>
