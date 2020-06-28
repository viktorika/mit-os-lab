
obj/user/faultallocbad：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 af 00 00 00       	call   8000e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800043:	c7 04 24 a0 12 80 00 	movl   $0x8012a0,(%esp)
  80004a:	e8 e6 01 00 00       	call   800235 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800056:	00 
  800057:	89 d8                	mov    %ebx,%eax
  800059:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800069:	e8 cb 0c 00 00       	call   800d39 <sys_page_alloc>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 24                	jns    800096 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800072:	89 44 24 10          	mov    %eax,0x10(%esp)
  800076:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007a:	c7 44 24 08 c0 12 80 	movl   $0x8012c0,0x8(%esp)
  800081:	00 
  800082:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800089:	00 
  80008a:	c7 04 24 aa 12 80 00 	movl   $0x8012aa,(%esp)
  800091:	e8 a6 00 00 00       	call   80013c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800096:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009a:	c7 44 24 08 ec 12 80 	movl   $0x8012ec,0x8(%esp)
  8000a1:	00 
  8000a2:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000a9:	00 
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	e8 4e 07 00 00       	call   800800 <snprintf>
}
  8000b2:	83 c4 24             	add    $0x24,%esp
  8000b5:	5b                   	pop    %ebx
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <umain>:

void
umain(int argc, char **argv)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000be:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000c5:	e8 84 0e 00 00       	call   800f4e <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000ca:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d1:	00 
  8000d2:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000d9:	e8 8e 0b 00 00       	call   800c6c <sys_cputs>
}
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 10             	sub    $0x10,%esp
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000ee:	e8 08 0c 00 00       	call   800cfb <sys_getenvid>
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x30>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800110:	89 74 24 04          	mov    %esi,0x4(%esp)
  800114:	89 1c 24             	mov    %ebx,(%esp)
  800117:	e8 9c ff ff ff       	call   8000b8 <umain>

	// exit gracefully
	exit();
  80011c:	e8 07 00 00 00       	call   800128 <exit>
}
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	5b                   	pop    %ebx
  800125:	5e                   	pop    %esi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800135:	e8 6f 0b 00 00       	call   800ca9 <sys_env_destroy>
}
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
  800141:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800144:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800147:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80014d:	e8 a9 0b 00 00       	call   800cfb <sys_getenvid>
  800152:	8b 55 0c             	mov    0xc(%ebp),%edx
  800155:	89 54 24 10          	mov    %edx,0x10(%esp)
  800159:	8b 55 08             	mov    0x8(%ebp),%edx
  80015c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800160:	89 74 24 08          	mov    %esi,0x8(%esp)
  800164:	89 44 24 04          	mov    %eax,0x4(%esp)
  800168:	c7 04 24 18 13 80 00 	movl   $0x801318,(%esp)
  80016f:	e8 c1 00 00 00       	call   800235 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800174:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800178:	8b 45 10             	mov    0x10(%ebp),%eax
  80017b:	89 04 24             	mov    %eax,(%esp)
  80017e:	e8 51 00 00 00       	call   8001d4 <vcprintf>
	cprintf("\n");
  800183:	c7 04 24 a8 12 80 00 	movl   $0x8012a8,(%esp)
  80018a:	e8 a6 00 00 00       	call   800235 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018f:	cc                   	int3   
  800190:	eb fd                	jmp    80018f <_panic+0x53>

00800192 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	53                   	push   %ebx
  800196:	83 ec 14             	sub    $0x14,%esp
  800199:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019c:	8b 13                	mov    (%ebx),%edx
  80019e:	8d 42 01             	lea    0x1(%edx),%eax
  8001a1:	89 03                	mov    %eax,(%ebx)
  8001a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001aa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001af:	75 19                	jne    8001ca <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001b1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001b8:	00 
  8001b9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bc:	89 04 24             	mov    %eax,(%esp)
  8001bf:	e8 a8 0a 00 00       	call   800c6c <sys_cputs>
		b->idx = 0;
  8001c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ca:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ce:	83 c4 14             	add    $0x14,%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5d                   	pop    %ebp
  8001d3:	c3                   	ret    

008001d4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001dd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e4:	00 00 00 
	b.cnt = 0;
  8001e7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ee:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ff:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800205:	89 44 24 04          	mov    %eax,0x4(%esp)
  800209:	c7 04 24 92 01 80 00 	movl   $0x800192,(%esp)
  800210:	e8 af 01 00 00       	call   8003c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800215:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	e8 3f 0a 00 00       	call   800c6c <sys_cputs>

	return b.cnt;
}
  80022d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800233:	c9                   	leave  
  800234:	c3                   	ret    

00800235 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800242:	8b 45 08             	mov    0x8(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	e8 87 ff ff ff       	call   8001d4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    
  80024f:	90                   	nop

00800250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 3c             	sub    $0x3c,%esp
  800259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80025c:	89 d7                	mov    %edx,%edi
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800264:	8b 75 0c             	mov    0xc(%ebp),%esi
  800267:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80026a:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80026d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800272:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800275:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800278:	39 f1                	cmp    %esi,%ecx
  80027a:	72 14                	jb     800290 <printnum+0x40>
  80027c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80027f:	76 0f                	jbe    800290 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800281:	8b 45 14             	mov    0x14(%ebp),%eax
  800284:	8d 70 ff             	lea    -0x1(%eax),%esi
  800287:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80028a:	85 f6                	test   %esi,%esi
  80028c:	7f 60                	jg     8002ee <printnum+0x9e>
  80028e:	eb 72                	jmp    800302 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800290:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800293:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800297:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80029a:	8d 51 ff             	lea    -0x1(%ecx),%edx
  80029d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a5:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002a9:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002ad:	89 c3                	mov    %eax,%ebx
  8002af:	89 d6                	mov    %edx,%esi
  8002b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002bb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c2:	89 04 24             	mov    %eax,(%esp)
  8002c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cc:	e8 2f 0d 00 00       	call   801000 <__udivdi3>
  8002d1:	89 d9                	mov    %ebx,%ecx
  8002d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002d7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002db:	89 04 24             	mov    %eax,(%esp)
  8002de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e2:	89 fa                	mov    %edi,%edx
  8002e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002e7:	e8 64 ff ff ff       	call   800250 <printnum>
  8002ec:	eb 14                	jmp    800302 <printnum+0xb2>
			putch(padc, putdat);
  8002ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f2:	8b 45 18             	mov    0x18(%ebp),%eax
  8002f5:	89 04 24             	mov    %eax,(%esp)
  8002f8:	ff d3                	call   *%ebx
		while (--width > 0)
  8002fa:	83 ee 01             	sub    $0x1,%esi
  8002fd:	75 ef                	jne    8002ee <printnum+0x9e>
  8002ff:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800302:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800306:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80030a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80030d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800310:	89 44 24 08          	mov    %eax,0x8(%esp)
  800314:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800318:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031b:	89 04 24             	mov    %eax,(%esp)
  80031e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800321:	89 44 24 04          	mov    %eax,0x4(%esp)
  800325:	e8 06 0e 00 00       	call   801130 <__umoddi3>
  80032a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032e:	0f be 80 3b 13 80 00 	movsbl 0x80133b(%eax),%eax
  800335:	89 04 24             	mov    %eax,(%esp)
  800338:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80033b:	ff d0                	call   *%eax
}
  80033d:	83 c4 3c             	add    $0x3c,%esp
  800340:	5b                   	pop    %ebx
  800341:	5e                   	pop    %esi
  800342:	5f                   	pop    %edi
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800348:	83 fa 01             	cmp    $0x1,%edx
  80034b:	7e 0e                	jle    80035b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034d:	8b 10                	mov    (%eax),%edx
  80034f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800352:	89 08                	mov    %ecx,(%eax)
  800354:	8b 02                	mov    (%edx),%eax
  800356:	8b 52 04             	mov    0x4(%edx),%edx
  800359:	eb 22                	jmp    80037d <getuint+0x38>
	else if (lflag)
  80035b:	85 d2                	test   %edx,%edx
  80035d:	74 10                	je     80036f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80035f:	8b 10                	mov    (%eax),%edx
  800361:	8d 4a 04             	lea    0x4(%edx),%ecx
  800364:	89 08                	mov    %ecx,(%eax)
  800366:	8b 02                	mov    (%edx),%eax
  800368:	ba 00 00 00 00       	mov    $0x0,%edx
  80036d:	eb 0e                	jmp    80037d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80036f:	8b 10                	mov    (%eax),%edx
  800371:	8d 4a 04             	lea    0x4(%edx),%ecx
  800374:	89 08                	mov    %ecx,(%eax)
  800376:	8b 02                	mov    (%edx),%eax
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800385:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	3b 50 04             	cmp    0x4(%eax),%edx
  80038e:	73 0a                	jae    80039a <sprintputch+0x1b>
		*b->buf++ = ch;
  800390:	8d 4a 01             	lea    0x1(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 45 08             	mov    0x8(%ebp),%eax
  800398:	88 02                	mov    %al,(%edx)
}
  80039a:	5d                   	pop    %ebp
  80039b:	c3                   	ret    

0080039c <printfmt>:
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8003a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ba:	89 04 24             	mov    %eax,(%esp)
  8003bd:	e8 02 00 00 00       	call   8003c4 <vprintfmt>
}
  8003c2:	c9                   	leave  
  8003c3:	c3                   	ret    

008003c4 <vprintfmt>:
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	57                   	push   %edi
  8003c8:	56                   	push   %esi
  8003c9:	53                   	push   %ebx
  8003ca:	83 ec 3c             	sub    $0x3c,%esp
  8003cd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003d3:	eb 18                	jmp    8003ed <vprintfmt+0x29>
			if (ch == '\0')
  8003d5:	85 c0                	test   %eax,%eax
  8003d7:	0f 84 c3 03 00 00    	je     8007a0 <vprintfmt+0x3dc>
			putch(ch, putdat);
  8003dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003e1:	89 04 24             	mov    %eax,(%esp)
  8003e4:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e7:	89 f3                	mov    %esi,%ebx
  8003e9:	eb 02                	jmp    8003ed <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  8003eb:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ed:	8d 73 01             	lea    0x1(%ebx),%esi
  8003f0:	0f b6 03             	movzbl (%ebx),%eax
  8003f3:	83 f8 25             	cmp    $0x25,%eax
  8003f6:	75 dd                	jne    8003d5 <vprintfmt+0x11>
  8003f8:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8003fc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800403:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80040a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800411:	ba 00 00 00 00       	mov    $0x0,%edx
  800416:	eb 1d                	jmp    800435 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800418:	89 de                	mov    %ebx,%esi
			padc = '-';
  80041a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80041e:	eb 15                	jmp    800435 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800420:	89 de                	mov    %ebx,%esi
			padc = '0';
  800422:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800426:	eb 0d                	jmp    800435 <vprintfmt+0x71>
				width = precision, precision = -1;
  800428:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80042b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80042e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8d 5e 01             	lea    0x1(%esi),%ebx
  800438:	0f b6 06             	movzbl (%esi),%eax
  80043b:	0f b6 c8             	movzbl %al,%ecx
  80043e:	83 e8 23             	sub    $0x23,%eax
  800441:	3c 55                	cmp    $0x55,%al
  800443:	0f 87 2f 03 00 00    	ja     800778 <vprintfmt+0x3b4>
  800449:	0f b6 c0             	movzbl %al,%eax
  80044c:	ff 24 85 00 14 80 00 	jmp    *0x801400(,%eax,4)
				precision = precision * 10 + ch - '0';
  800453:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800456:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  800459:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80045d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800460:	83 f9 09             	cmp    $0x9,%ecx
  800463:	77 50                	ja     8004b5 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  800465:	89 de                	mov    %ebx,%esi
  800467:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  80046a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80046d:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800470:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800474:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800477:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80047a:	83 fb 09             	cmp    $0x9,%ebx
  80047d:	76 eb                	jbe    80046a <vprintfmt+0xa6>
  80047f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800482:	eb 33                	jmp    8004b7 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	8d 48 04             	lea    0x4(%eax),%ecx
  80048a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80048d:	8b 00                	mov    (%eax),%eax
  80048f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800492:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800494:	eb 21                	jmp    8004b7 <vprintfmt+0xf3>
  800496:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800499:	85 c9                	test   %ecx,%ecx
  80049b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a0:	0f 49 c1             	cmovns %ecx,%eax
  8004a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	89 de                	mov    %ebx,%esi
  8004a8:	eb 8b                	jmp    800435 <vprintfmt+0x71>
  8004aa:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8004ac:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004b3:	eb 80                	jmp    800435 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	89 de                	mov    %ebx,%esi
			if (width < 0)
  8004b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004bb:	0f 89 74 ff ff ff    	jns    800435 <vprintfmt+0x71>
  8004c1:	e9 62 ff ff ff       	jmp    800428 <vprintfmt+0x64>
			lflag++;
  8004c6:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8004cb:	e9 65 ff ff ff       	jmp    800435 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  8004d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d3:	8d 50 04             	lea    0x4(%eax),%edx
  8004d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004dd:	8b 00                	mov    (%eax),%eax
  8004df:	89 04 24             	mov    %eax,(%esp)
  8004e2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004e5:	e9 03 ff ff ff       	jmp    8003ed <vprintfmt+0x29>
			err = va_arg(ap, int);
  8004ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ed:	8d 50 04             	lea    0x4(%eax),%edx
  8004f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f3:	8b 00                	mov    (%eax),%eax
  8004f5:	99                   	cltd   
  8004f6:	31 d0                	xor    %edx,%eax
  8004f8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004fa:	83 f8 08             	cmp    $0x8,%eax
  8004fd:	7f 0b                	jg     80050a <vprintfmt+0x146>
  8004ff:	8b 14 85 60 15 80 00 	mov    0x801560(,%eax,4),%edx
  800506:	85 d2                	test   %edx,%edx
  800508:	75 20                	jne    80052a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80050a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050e:	c7 44 24 08 53 13 80 	movl   $0x801353,0x8(%esp)
  800515:	00 
  800516:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051a:	8b 45 08             	mov    0x8(%ebp),%eax
  80051d:	89 04 24             	mov    %eax,(%esp)
  800520:	e8 77 fe ff ff       	call   80039c <printfmt>
  800525:	e9 c3 fe ff ff       	jmp    8003ed <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80052a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80052e:	c7 44 24 08 5c 13 80 	movl   $0x80135c,0x8(%esp)
  800535:	00 
  800536:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053a:	8b 45 08             	mov    0x8(%ebp),%eax
  80053d:	89 04 24             	mov    %eax,(%esp)
  800540:	e8 57 fe ff ff       	call   80039c <printfmt>
  800545:	e9 a3 fe ff ff       	jmp    8003ed <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80054d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  800550:	8b 45 14             	mov    0x14(%ebp),%eax
  800553:	8d 50 04             	lea    0x4(%eax),%edx
  800556:	89 55 14             	mov    %edx,0x14(%ebp)
  800559:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80055b:	85 c0                	test   %eax,%eax
  80055d:	ba 4c 13 80 00       	mov    $0x80134c,%edx
  800562:	0f 45 d0             	cmovne %eax,%edx
  800565:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800568:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80056c:	74 04                	je     800572 <vprintfmt+0x1ae>
  80056e:	85 f6                	test   %esi,%esi
  800570:	7f 19                	jg     80058b <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800572:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800575:	8d 70 01             	lea    0x1(%eax),%esi
  800578:	0f b6 10             	movzbl (%eax),%edx
  80057b:	0f be c2             	movsbl %dl,%eax
  80057e:	85 c0                	test   %eax,%eax
  800580:	0f 85 95 00 00 00    	jne    80061b <vprintfmt+0x257>
  800586:	e9 85 00 00 00       	jmp    800610 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80058f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800592:	89 04 24             	mov    %eax,(%esp)
  800595:	e8 b8 02 00 00       	call   800852 <strnlen>
  80059a:	29 c6                	sub    %eax,%esi
  80059c:	89 f0                	mov    %esi,%eax
  80059e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8005a1:	85 f6                	test   %esi,%esi
  8005a3:	7e cd                	jle    800572 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8005a5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8005a9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005ac:	89 c3                	mov    %eax,%ebx
  8005ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b2:	89 34 24             	mov    %esi,(%esp)
  8005b5:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b8:	83 eb 01             	sub    $0x1,%ebx
  8005bb:	75 f1                	jne    8005ae <vprintfmt+0x1ea>
  8005bd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005c3:	eb ad                	jmp    800572 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  8005c5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c9:	74 1e                	je     8005e9 <vprintfmt+0x225>
  8005cb:	0f be d2             	movsbl %dl,%edx
  8005ce:	83 ea 20             	sub    $0x20,%edx
  8005d1:	83 fa 5e             	cmp    $0x5e,%edx
  8005d4:	76 13                	jbe    8005e9 <vprintfmt+0x225>
					putch('?', putdat);
  8005d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005dd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005e4:	ff 55 08             	call   *0x8(%ebp)
  8005e7:	eb 0d                	jmp    8005f6 <vprintfmt+0x232>
					putch(ch, putdat);
  8005e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ec:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005f0:	89 04 24             	mov    %eax,(%esp)
  8005f3:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f6:	83 ef 01             	sub    $0x1,%edi
  8005f9:	83 c6 01             	add    $0x1,%esi
  8005fc:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800600:	0f be c2             	movsbl %dl,%eax
  800603:	85 c0                	test   %eax,%eax
  800605:	75 20                	jne    800627 <vprintfmt+0x263>
  800607:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80060a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80060d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800610:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800614:	7f 25                	jg     80063b <vprintfmt+0x277>
  800616:	e9 d2 fd ff ff       	jmp    8003ed <vprintfmt+0x29>
  80061b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80061e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800621:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800624:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800627:	85 db                	test   %ebx,%ebx
  800629:	78 9a                	js     8005c5 <vprintfmt+0x201>
  80062b:	83 eb 01             	sub    $0x1,%ebx
  80062e:	79 95                	jns    8005c5 <vprintfmt+0x201>
  800630:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800633:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800636:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800639:	eb d5                	jmp    800610 <vprintfmt+0x24c>
  80063b:	8b 75 08             	mov    0x8(%ebp),%esi
  80063e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800641:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  800644:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800648:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80064f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800651:	83 eb 01             	sub    $0x1,%ebx
  800654:	75 ee                	jne    800644 <vprintfmt+0x280>
  800656:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800659:	e9 8f fd ff ff       	jmp    8003ed <vprintfmt+0x29>
	if (lflag >= 2)
  80065e:	83 fa 01             	cmp    $0x1,%edx
  800661:	7e 16                	jle    800679 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8d 50 08             	lea    0x8(%eax),%edx
  800669:	89 55 14             	mov    %edx,0x14(%ebp)
  80066c:	8b 50 04             	mov    0x4(%eax),%edx
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800674:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800677:	eb 32                	jmp    8006ab <vprintfmt+0x2e7>
	else if (lflag)
  800679:	85 d2                	test   %edx,%edx
  80067b:	74 18                	je     800695 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8d 50 04             	lea    0x4(%eax),%edx
  800683:	89 55 14             	mov    %edx,0x14(%ebp)
  800686:	8b 30                	mov    (%eax),%esi
  800688:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80068b:	89 f0                	mov    %esi,%eax
  80068d:	c1 f8 1f             	sar    $0x1f,%eax
  800690:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800693:	eb 16                	jmp    8006ab <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8d 50 04             	lea    0x4(%eax),%edx
  80069b:	89 55 14             	mov    %edx,0x14(%ebp)
  80069e:	8b 30                	mov    (%eax),%esi
  8006a0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006a3:	89 f0                	mov    %esi,%eax
  8006a5:	c1 f8 1f             	sar    $0x1f,%eax
  8006a8:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  8006ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  8006b1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8006b6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ba:	0f 89 80 00 00 00    	jns    800740 <vprintfmt+0x37c>
				putch('-', putdat);
  8006c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006cb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006d4:	f7 d8                	neg    %eax
  8006d6:	83 d2 00             	adc    $0x0,%edx
  8006d9:	f7 da                	neg    %edx
			base = 10;
  8006db:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e0:	eb 5e                	jmp    800740 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8006e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e5:	e8 5b fc ff ff       	call   800345 <getuint>
			base = 10;
  8006ea:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006ef:	eb 4f                	jmp    800740 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8006f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f4:	e8 4c fc ff ff       	call   800345 <getuint>
			base = 8;
  8006f9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006fe:	eb 40                	jmp    800740 <vprintfmt+0x37c>
			putch('0', putdat);
  800700:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800704:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80070b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80070e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800712:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800719:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8d 50 04             	lea    0x4(%eax),%edx
  800722:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800725:	8b 00                	mov    (%eax),%eax
  800727:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80072c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800731:	eb 0d                	jmp    800740 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
  800736:	e8 0a fc ff ff       	call   800345 <getuint>
			base = 16;
  80073b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800740:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800744:	89 74 24 10          	mov    %esi,0x10(%esp)
  800748:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80074b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80074f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800753:	89 04 24             	mov    %eax,(%esp)
  800756:	89 54 24 04          	mov    %edx,0x4(%esp)
  80075a:	89 fa                	mov    %edi,%edx
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	e8 ec fa ff ff       	call   800250 <printnum>
			break;
  800764:	e9 84 fc ff ff       	jmp    8003ed <vprintfmt+0x29>
			putch(ch, putdat);
  800769:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076d:	89 0c 24             	mov    %ecx,(%esp)
  800770:	ff 55 08             	call   *0x8(%ebp)
			break;
  800773:	e9 75 fc ff ff       	jmp    8003ed <vprintfmt+0x29>
			putch('%', putdat);
  800778:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800783:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800786:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80078a:	0f 84 5b fc ff ff    	je     8003eb <vprintfmt+0x27>
  800790:	89 f3                	mov    %esi,%ebx
  800792:	83 eb 01             	sub    $0x1,%ebx
  800795:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800799:	75 f7                	jne    800792 <vprintfmt+0x3ce>
  80079b:	e9 4d fc ff ff       	jmp    8003ed <vprintfmt+0x29>
}
  8007a0:	83 c4 3c             	add    $0x3c,%esp
  8007a3:	5b                   	pop    %ebx
  8007a4:	5e                   	pop    %esi
  8007a5:	5f                   	pop    %edi
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 28             	sub    $0x28,%esp
  8007ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007bb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c5:	85 c0                	test   %eax,%eax
  8007c7:	74 30                	je     8007f9 <vsnprintf+0x51>
  8007c9:	85 d2                	test   %edx,%edx
  8007cb:	7e 2c                	jle    8007f9 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007db:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e2:	c7 04 24 7f 03 80 00 	movl   $0x80037f,(%esp)
  8007e9:	e8 d6 fb ff ff       	call   8003c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f7:	eb 05                	jmp    8007fe <vsnprintf+0x56>
		return -E_INVAL;
  8007f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800806:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800809:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080d:	8b 45 10             	mov    0x10(%ebp),%eax
  800810:	89 44 24 08          	mov    %eax,0x8(%esp)
  800814:	8b 45 0c             	mov    0xc(%ebp),%eax
  800817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	89 04 24             	mov    %eax,(%esp)
  800821:	e8 82 ff ff ff       	call   8007a8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800826:	c9                   	leave  
  800827:	c3                   	ret    
  800828:	66 90                	xchg   %ax,%ax
  80082a:	66 90                	xchg   %ax,%ax
  80082c:	66 90                	xchg   %ax,%ax
  80082e:	66 90                	xchg   %ax,%ax

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	80 3a 00             	cmpb   $0x0,(%edx)
  800839:	74 10                	je     80084b <strlen+0x1b>
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800840:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800843:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800847:	75 f7                	jne    800840 <strlen+0x10>
  800849:	eb 05                	jmp    800850 <strlen+0x20>
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	53                   	push   %ebx
  800856:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085c:	85 c9                	test   %ecx,%ecx
  80085e:	74 1c                	je     80087c <strnlen+0x2a>
  800860:	80 3b 00             	cmpb   $0x0,(%ebx)
  800863:	74 1e                	je     800883 <strnlen+0x31>
  800865:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80086a:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086c:	39 ca                	cmp    %ecx,%edx
  80086e:	74 18                	je     800888 <strnlen+0x36>
  800870:	83 c2 01             	add    $0x1,%edx
  800873:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800878:	75 f0                	jne    80086a <strnlen+0x18>
  80087a:	eb 0c                	jmp    800888 <strnlen+0x36>
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
  800881:	eb 05                	jmp    800888 <strnlen+0x36>
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800888:	5b                   	pop    %ebx
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800895:	89 c2                	mov    %eax,%edx
  800897:	83 c2 01             	add    $0x1,%edx
  80089a:	83 c1 01             	add    $0x1,%ecx
  80089d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008a1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a4:	84 db                	test   %bl,%bl
  8008a6:	75 ef                	jne    800897 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	83 ec 08             	sub    $0x8,%esp
  8008b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b5:	89 1c 24             	mov    %ebx,(%esp)
  8008b8:	e8 73 ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  8008bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c4:	01 d8                	add    %ebx,%eax
  8008c6:	89 04 24             	mov    %eax,(%esp)
  8008c9:	e8 bd ff ff ff       	call   80088b <strcpy>
	return dst;
}
  8008ce:	89 d8                	mov    %ebx,%eax
  8008d0:	83 c4 08             	add    $0x8,%esp
  8008d3:	5b                   	pop    %ebx
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 75 08             	mov    0x8(%ebp),%esi
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e4:	85 db                	test   %ebx,%ebx
  8008e6:	74 17                	je     8008ff <strncpy+0x29>
  8008e8:	01 f3                	add    %esi,%ebx
  8008ea:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8008ec:	83 c1 01             	add    $0x1,%ecx
  8008ef:	0f b6 02             	movzbl (%edx),%eax
  8008f2:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f5:	80 3a 01             	cmpb   $0x1,(%edx)
  8008f8:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8008fb:	39 d9                	cmp    %ebx,%ecx
  8008fd:	75 ed                	jne    8008ec <strncpy+0x16>
	}
	return ret;
}
  8008ff:	89 f0                	mov    %esi,%eax
  800901:	5b                   	pop    %ebx
  800902:	5e                   	pop    %esi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	57                   	push   %edi
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800911:	8b 75 10             	mov    0x10(%ebp),%esi
  800914:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800916:	85 f6                	test   %esi,%esi
  800918:	74 34                	je     80094e <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  80091a:	83 fe 01             	cmp    $0x1,%esi
  80091d:	74 26                	je     800945 <strlcpy+0x40>
  80091f:	0f b6 0b             	movzbl (%ebx),%ecx
  800922:	84 c9                	test   %cl,%cl
  800924:	74 23                	je     800949 <strlcpy+0x44>
  800926:	83 ee 02             	sub    $0x2,%esi
  800929:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  80092e:	83 c0 01             	add    $0x1,%eax
  800931:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800934:	39 f2                	cmp    %esi,%edx
  800936:	74 13                	je     80094b <strlcpy+0x46>
  800938:	83 c2 01             	add    $0x1,%edx
  80093b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80093f:	84 c9                	test   %cl,%cl
  800941:	75 eb                	jne    80092e <strlcpy+0x29>
  800943:	eb 06                	jmp    80094b <strlcpy+0x46>
  800945:	89 f8                	mov    %edi,%eax
  800947:	eb 02                	jmp    80094b <strlcpy+0x46>
  800949:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  80094b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80094e:	29 f8                	sub    %edi,%eax
}
  800950:	5b                   	pop    %ebx
  800951:	5e                   	pop    %esi
  800952:	5f                   	pop    %edi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095e:	0f b6 01             	movzbl (%ecx),%eax
  800961:	84 c0                	test   %al,%al
  800963:	74 15                	je     80097a <strcmp+0x25>
  800965:	3a 02                	cmp    (%edx),%al
  800967:	75 11                	jne    80097a <strcmp+0x25>
		p++, q++;
  800969:	83 c1 01             	add    $0x1,%ecx
  80096c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80096f:	0f b6 01             	movzbl (%ecx),%eax
  800972:	84 c0                	test   %al,%al
  800974:	74 04                	je     80097a <strcmp+0x25>
  800976:	3a 02                	cmp    (%edx),%al
  800978:	74 ef                	je     800969 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80097a:	0f b6 c0             	movzbl %al,%eax
  80097d:	0f b6 12             	movzbl (%edx),%edx
  800980:	29 d0                	sub    %edx,%eax
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800992:	85 f6                	test   %esi,%esi
  800994:	74 29                	je     8009bf <strncmp+0x3b>
  800996:	0f b6 03             	movzbl (%ebx),%eax
  800999:	84 c0                	test   %al,%al
  80099b:	74 30                	je     8009cd <strncmp+0x49>
  80099d:	3a 02                	cmp    (%edx),%al
  80099f:	75 2c                	jne    8009cd <strncmp+0x49>
  8009a1:	8d 43 01             	lea    0x1(%ebx),%eax
  8009a4:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8009a6:	89 c3                	mov    %eax,%ebx
  8009a8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009ab:	39 f0                	cmp    %esi,%eax
  8009ad:	74 17                	je     8009c6 <strncmp+0x42>
  8009af:	0f b6 08             	movzbl (%eax),%ecx
  8009b2:	84 c9                	test   %cl,%cl
  8009b4:	74 17                	je     8009cd <strncmp+0x49>
  8009b6:	83 c0 01             	add    $0x1,%eax
  8009b9:	3a 0a                	cmp    (%edx),%cl
  8009bb:	74 e9                	je     8009a6 <strncmp+0x22>
  8009bd:	eb 0e                	jmp    8009cd <strncmp+0x49>
	if (n == 0)
		return 0;
  8009bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c4:	eb 0f                	jmp    8009d5 <strncmp+0x51>
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cb:	eb 08                	jmp    8009d5 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009cd:	0f b6 03             	movzbl (%ebx),%eax
  8009d0:	0f b6 12             	movzbl (%edx),%edx
  8009d3:	29 d0                	sub    %edx,%eax
}
  8009d5:	5b                   	pop    %ebx
  8009d6:	5e                   	pop    %esi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	53                   	push   %ebx
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009e3:	0f b6 18             	movzbl (%eax),%ebx
  8009e6:	84 db                	test   %bl,%bl
  8009e8:	74 1d                	je     800a07 <strchr+0x2e>
  8009ea:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009ec:	38 d3                	cmp    %dl,%bl
  8009ee:	75 06                	jne    8009f6 <strchr+0x1d>
  8009f0:	eb 1a                	jmp    800a0c <strchr+0x33>
  8009f2:	38 ca                	cmp    %cl,%dl
  8009f4:	74 16                	je     800a0c <strchr+0x33>
	for (; *s; s++)
  8009f6:	83 c0 01             	add    $0x1,%eax
  8009f9:	0f b6 10             	movzbl (%eax),%edx
  8009fc:	84 d2                	test   %dl,%dl
  8009fe:	75 f2                	jne    8009f2 <strchr+0x19>
			return (char *) s;
	return 0;
  800a00:	b8 00 00 00 00       	mov    $0x0,%eax
  800a05:	eb 05                	jmp    800a0c <strchr+0x33>
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0c:	5b                   	pop    %ebx
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	53                   	push   %ebx
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a19:	0f b6 18             	movzbl (%eax),%ebx
  800a1c:	84 db                	test   %bl,%bl
  800a1e:	74 16                	je     800a36 <strfind+0x27>
  800a20:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a22:	38 d3                	cmp    %dl,%bl
  800a24:	75 06                	jne    800a2c <strfind+0x1d>
  800a26:	eb 0e                	jmp    800a36 <strfind+0x27>
  800a28:	38 ca                	cmp    %cl,%dl
  800a2a:	74 0a                	je     800a36 <strfind+0x27>
	for (; *s; s++)
  800a2c:	83 c0 01             	add    $0x1,%eax
  800a2f:	0f b6 10             	movzbl (%eax),%edx
  800a32:	84 d2                	test   %dl,%dl
  800a34:	75 f2                	jne    800a28 <strfind+0x19>
			break;
	return (char *) s;
}
  800a36:	5b                   	pop    %ebx
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	57                   	push   %edi
  800a3d:	56                   	push   %esi
  800a3e:	53                   	push   %ebx
  800a3f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a42:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a45:	85 c9                	test   %ecx,%ecx
  800a47:	74 36                	je     800a7f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a49:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a4f:	75 28                	jne    800a79 <memset+0x40>
  800a51:	f6 c1 03             	test   $0x3,%cl
  800a54:	75 23                	jne    800a79 <memset+0x40>
		c &= 0xFF;
  800a56:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5a:	89 d3                	mov    %edx,%ebx
  800a5c:	c1 e3 08             	shl    $0x8,%ebx
  800a5f:	89 d6                	mov    %edx,%esi
  800a61:	c1 e6 18             	shl    $0x18,%esi
  800a64:	89 d0                	mov    %edx,%eax
  800a66:	c1 e0 10             	shl    $0x10,%eax
  800a69:	09 f0                	or     %esi,%eax
  800a6b:	09 c2                	or     %eax,%edx
  800a6d:	89 d0                	mov    %edx,%eax
  800a6f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a71:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a74:	fc                   	cld    
  800a75:	f3 ab                	rep stos %eax,%es:(%edi)
  800a77:	eb 06                	jmp    800a7f <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7c:	fc                   	cld    
  800a7d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a7f:	89 f8                	mov    %edi,%eax
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a91:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a94:	39 c6                	cmp    %eax,%esi
  800a96:	73 35                	jae    800acd <memmove+0x47>
  800a98:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9b:	39 d0                	cmp    %edx,%eax
  800a9d:	73 2e                	jae    800acd <memmove+0x47>
		s += n;
		d += n;
  800a9f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800aa2:	89 d6                	mov    %edx,%esi
  800aa4:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aac:	75 13                	jne    800ac1 <memmove+0x3b>
  800aae:	f6 c1 03             	test   $0x3,%cl
  800ab1:	75 0e                	jne    800ac1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab3:	83 ef 04             	sub    $0x4,%edi
  800ab6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800abc:	fd                   	std    
  800abd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abf:	eb 09                	jmp    800aca <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ac1:	83 ef 01             	sub    $0x1,%edi
  800ac4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ac7:	fd                   	std    
  800ac8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aca:	fc                   	cld    
  800acb:	eb 1d                	jmp    800aea <memmove+0x64>
  800acd:	89 f2                	mov    %esi,%edx
  800acf:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad1:	f6 c2 03             	test   $0x3,%dl
  800ad4:	75 0f                	jne    800ae5 <memmove+0x5f>
  800ad6:	f6 c1 03             	test   $0x3,%cl
  800ad9:	75 0a                	jne    800ae5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800adb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ade:	89 c7                	mov    %eax,%edi
  800ae0:	fc                   	cld    
  800ae1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae3:	eb 05                	jmp    800aea <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800ae5:	89 c7                	mov    %eax,%edi
  800ae7:	fc                   	cld    
  800ae8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800af4:	8b 45 10             	mov    0x10(%ebp),%eax
  800af7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800afb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
  800b05:	89 04 24             	mov    %eax,(%esp)
  800b08:	e8 79 ff ff ff       	call   800a86 <memmove>
}
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b21:	85 c0                	test   %eax,%eax
  800b23:	74 36                	je     800b5b <memcmp+0x4c>
		if (*s1 != *s2)
  800b25:	0f b6 03             	movzbl (%ebx),%eax
  800b28:	0f b6 0e             	movzbl (%esi),%ecx
  800b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b30:	38 c8                	cmp    %cl,%al
  800b32:	74 1c                	je     800b50 <memcmp+0x41>
  800b34:	eb 10                	jmp    800b46 <memcmp+0x37>
  800b36:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b3b:	83 c2 01             	add    $0x1,%edx
  800b3e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b42:	38 c8                	cmp    %cl,%al
  800b44:	74 0a                	je     800b50 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b46:	0f b6 c0             	movzbl %al,%eax
  800b49:	0f b6 c9             	movzbl %cl,%ecx
  800b4c:	29 c8                	sub    %ecx,%eax
  800b4e:	eb 10                	jmp    800b60 <memcmp+0x51>
	while (n-- > 0) {
  800b50:	39 fa                	cmp    %edi,%edx
  800b52:	75 e2                	jne    800b36 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800b54:	b8 00 00 00 00       	mov    $0x0,%eax
  800b59:	eb 05                	jmp    800b60 <memcmp+0x51>
  800b5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	53                   	push   %ebx
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b74:	39 d0                	cmp    %edx,%eax
  800b76:	73 13                	jae    800b8b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b78:	89 d9                	mov    %ebx,%ecx
  800b7a:	38 18                	cmp    %bl,(%eax)
  800b7c:	75 06                	jne    800b84 <memfind+0x1f>
  800b7e:	eb 0b                	jmp    800b8b <memfind+0x26>
  800b80:	38 08                	cmp    %cl,(%eax)
  800b82:	74 07                	je     800b8b <memfind+0x26>
	for (; s < ends; s++)
  800b84:	83 c0 01             	add    $0x1,%eax
  800b87:	39 d0                	cmp    %edx,%eax
  800b89:	75 f5                	jne    800b80 <memfind+0x1b>
			break;
	return (void *) s;
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9a:	0f b6 0a             	movzbl (%edx),%ecx
  800b9d:	80 f9 09             	cmp    $0x9,%cl
  800ba0:	74 05                	je     800ba7 <strtol+0x19>
  800ba2:	80 f9 20             	cmp    $0x20,%cl
  800ba5:	75 10                	jne    800bb7 <strtol+0x29>
		s++;
  800ba7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800baa:	0f b6 0a             	movzbl (%edx),%ecx
  800bad:	80 f9 09             	cmp    $0x9,%cl
  800bb0:	74 f5                	je     800ba7 <strtol+0x19>
  800bb2:	80 f9 20             	cmp    $0x20,%cl
  800bb5:	74 f0                	je     800ba7 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800bb7:	80 f9 2b             	cmp    $0x2b,%cl
  800bba:	75 0a                	jne    800bc6 <strtol+0x38>
		s++;
  800bbc:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800bbf:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc4:	eb 11                	jmp    800bd7 <strtol+0x49>
  800bc6:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800bcb:	80 f9 2d             	cmp    $0x2d,%cl
  800bce:	75 07                	jne    800bd7 <strtol+0x49>
		s++, neg = 1;
  800bd0:	83 c2 01             	add    $0x1,%edx
  800bd3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd7:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800bdc:	75 15                	jne    800bf3 <strtol+0x65>
  800bde:	80 3a 30             	cmpb   $0x30,(%edx)
  800be1:	75 10                	jne    800bf3 <strtol+0x65>
  800be3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800be7:	75 0a                	jne    800bf3 <strtol+0x65>
		s += 2, base = 16;
  800be9:	83 c2 02             	add    $0x2,%edx
  800bec:	b8 10 00 00 00       	mov    $0x10,%eax
  800bf1:	eb 10                	jmp    800c03 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	75 0c                	jne    800c03 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bf7:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800bf9:	80 3a 30             	cmpb   $0x30,(%edx)
  800bfc:	75 05                	jne    800c03 <strtol+0x75>
		s++, base = 8;
  800bfe:	83 c2 01             	add    $0x1,%edx
  800c01:	b0 08                	mov    $0x8,%al
		base = 10;
  800c03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c08:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c0b:	0f b6 0a             	movzbl (%edx),%ecx
  800c0e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c11:	89 f0                	mov    %esi,%eax
  800c13:	3c 09                	cmp    $0x9,%al
  800c15:	77 08                	ja     800c1f <strtol+0x91>
			dig = *s - '0';
  800c17:	0f be c9             	movsbl %cl,%ecx
  800c1a:	83 e9 30             	sub    $0x30,%ecx
  800c1d:	eb 20                	jmp    800c3f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800c1f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c22:	89 f0                	mov    %esi,%eax
  800c24:	3c 19                	cmp    $0x19,%al
  800c26:	77 08                	ja     800c30 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c28:	0f be c9             	movsbl %cl,%ecx
  800c2b:	83 e9 57             	sub    $0x57,%ecx
  800c2e:	eb 0f                	jmp    800c3f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800c30:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c33:	89 f0                	mov    %esi,%eax
  800c35:	3c 19                	cmp    $0x19,%al
  800c37:	77 16                	ja     800c4f <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c39:	0f be c9             	movsbl %cl,%ecx
  800c3c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c3f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c42:	7d 0f                	jge    800c53 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c44:	83 c2 01             	add    $0x1,%edx
  800c47:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c4b:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c4d:	eb bc                	jmp    800c0b <strtol+0x7d>
  800c4f:	89 d8                	mov    %ebx,%eax
  800c51:	eb 02                	jmp    800c55 <strtol+0xc7>
  800c53:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c59:	74 05                	je     800c60 <strtol+0xd2>
		*endptr = (char *) s;
  800c5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c5e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c60:	f7 d8                	neg    %eax
  800c62:	85 ff                	test   %edi,%edi
  800c64:	0f 44 c3             	cmove  %ebx,%eax
}
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c72:	b8 00 00 00 00       	mov    $0x0,%eax
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	89 c3                	mov    %eax,%ebx
  800c7f:	89 c7                	mov    %eax,%edi
  800c81:	89 c6                	mov    %eax,%esi
  800c83:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c90:	ba 00 00 00 00       	mov    $0x0,%edx
  800c95:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9a:	89 d1                	mov    %edx,%ecx
  800c9c:	89 d3                	mov    %edx,%ebx
  800c9e:	89 d7                	mov    %edx,%edi
  800ca0:	89 d6                	mov    %edx,%esi
  800ca2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
  800caf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb7:	b8 03 00 00 00       	mov    $0x3,%eax
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	89 cb                	mov    %ecx,%ebx
  800cc1:	89 cf                	mov    %ecx,%edi
  800cc3:	89 ce                	mov    %ecx,%esi
  800cc5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7e 28                	jle    800cf3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cd6:	00 
  800cd7:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800cde:	00 
  800cdf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce6:	00 
  800ce7:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800cee:	e8 49 f4 ff ff       	call   80013c <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cf3:	83 c4 2c             	add    $0x2c,%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d01:	ba 00 00 00 00       	mov    $0x0,%edx
  800d06:	b8 02 00 00 00       	mov    $0x2,%eax
  800d0b:	89 d1                	mov    %edx,%ecx
  800d0d:	89 d3                	mov    %edx,%ebx
  800d0f:	89 d7                	mov    %edx,%edi
  800d11:	89 d6                	mov    %edx,%esi
  800d13:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <sys_yield>:

void
sys_yield(void)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d20:	ba 00 00 00 00       	mov    $0x0,%edx
  800d25:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d2a:	89 d1                	mov    %edx,%ecx
  800d2c:	89 d3                	mov    %edx,%ebx
  800d2e:	89 d7                	mov    %edx,%edi
  800d30:	89 d6                	mov    %edx,%esi
  800d32:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
  800d3f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d42:	be 00 00 00 00       	mov    $0x0,%esi
  800d47:	b8 04 00 00 00       	mov    $0x4,%eax
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d55:	89 f7                	mov    %esi,%edi
  800d57:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 28                	jle    800d85 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d61:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d68:	00 
  800d69:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800d70:	00 
  800d71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d78:	00 
  800d79:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800d80:	e8 b7 f3 ff ff       	call   80013c <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d85:	83 c4 2c             	add    $0x2c,%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d96:	b8 05 00 00 00       	mov    $0x5,%eax
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da7:	8b 75 18             	mov    0x18(%ebp),%esi
  800daa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dac:	85 c0                	test   %eax,%eax
  800dae:	7e 28                	jle    800dd8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dbb:	00 
  800dbc:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800dc3:	00 
  800dc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dcb:	00 
  800dcc:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800dd3:	e8 64 f3 ff ff       	call   80013c <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dd8:	83 c4 2c             	add    $0x2c,%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
  800de6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800de9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dee:	b8 06 00 00 00       	mov    $0x6,%eax
  800df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df6:	8b 55 08             	mov    0x8(%ebp),%edx
  800df9:	89 df                	mov    %ebx,%edi
  800dfb:	89 de                	mov    %ebx,%esi
  800dfd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 28                	jle    800e2b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e07:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e0e:	00 
  800e0f:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800e16:	00 
  800e17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1e:	00 
  800e1f:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800e26:	e8 11 f3 ff ff       	call   80013c <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e2b:	83 c4 2c             	add    $0x2c,%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e41:	b8 08 00 00 00       	mov    $0x8,%eax
  800e46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	89 df                	mov    %ebx,%edi
  800e4e:	89 de                	mov    %ebx,%esi
  800e50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e52:	85 c0                	test   %eax,%eax
  800e54:	7e 28                	jle    800e7e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e56:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e61:	00 
  800e62:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800e69:	00 
  800e6a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e71:	00 
  800e72:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800e79:	e8 be f2 ff ff       	call   80013c <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e7e:	83 c4 2c             	add    $0x2c,%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e94:	b8 09 00 00 00       	mov    $0x9,%eax
  800e99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	89 df                	mov    %ebx,%edi
  800ea1:	89 de                	mov    %ebx,%esi
  800ea3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	7e 28                	jle    800ed1 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ead:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800eb4:	00 
  800eb5:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800ebc:	00 
  800ebd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec4:	00 
  800ec5:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800ecc:	e8 6b f2 ff ff       	call   80013c <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ed1:	83 c4 2c             	add    $0x2c,%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	57                   	push   %edi
  800edd:	56                   	push   %esi
  800ede:	53                   	push   %ebx
	asm volatile("int %1\n"
  800edf:	be 00 00 00 00       	mov    $0x0,%esi
  800ee4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ee9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eec:	8b 55 08             	mov    0x8(%ebp),%edx
  800eef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	57                   	push   %edi
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
  800f02:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f0a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f12:	89 cb                	mov    %ecx,%ebx
  800f14:	89 cf                	mov    %ecx,%edi
  800f16:	89 ce                	mov    %ecx,%esi
  800f18:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	7e 28                	jle    800f46 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f22:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f29:	00 
  800f2a:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800f31:	00 
  800f32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f39:	00 
  800f3a:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800f41:	e8 f6 f1 ff ff       	call   80013c <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f46:	83 c4 2c             	add    $0x2c,%esp
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5f                   	pop    %edi
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f54:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800f5b:	75 70                	jne    800fcd <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  800f5d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f64:	00 
  800f65:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f6c:	ee 
  800f6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f74:	e8 c0 fd ff ff       	call   800d39 <sys_page_alloc>
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	79 1c                	jns    800f99 <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  800f7d:	c7 44 24 08 b0 15 80 	movl   $0x8015b0,0x8(%esp)
  800f84:	00 
  800f85:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f8c:	00 
  800f8d:	c7 04 24 14 16 80 00 	movl   $0x801614,(%esp)
  800f94:	e8 a3 f1 ff ff       	call   80013c <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800f99:	c7 44 24 04 d7 0f 80 	movl   $0x800fd7,0x4(%esp)
  800fa0:	00 
  800fa1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa8:	e8 d9 fe ff ff       	call   800e86 <sys_env_set_pgfault_upcall>
  800fad:	85 c0                	test   %eax,%eax
  800faf:	79 1c                	jns    800fcd <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  800fb1:	c7 44 24 08 dc 15 80 	movl   $0x8015dc,0x8(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800fc0:	00 
  800fc1:	c7 04 24 14 16 80 00 	movl   $0x801614,(%esp)
  800fc8:	e8 6f f1 ff ff       	call   80013c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800fcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd0:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800fd7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800fd8:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800fdd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800fdf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  800fe2:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  800fe6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  800feb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  800fef:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800ff1:	83 c4 08             	add    $0x8,%esp
	popal
  800ff4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800ff5:	83 c4 04             	add    $0x4,%esp
	popfl
  800ff8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800ff9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800ffa:	c3                   	ret    
  800ffb:	66 90                	xchg   %ax,%ax
  800ffd:	66 90                	xchg   %ax,%ax
  800fff:	90                   	nop

00801000 <__udivdi3>:
  801000:	55                   	push   %ebp
  801001:	57                   	push   %edi
  801002:	56                   	push   %esi
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	8b 44 24 28          	mov    0x28(%esp),%eax
  80100a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80100e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801012:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801016:	85 c0                	test   %eax,%eax
  801018:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80101c:	89 ea                	mov    %ebp,%edx
  80101e:	89 0c 24             	mov    %ecx,(%esp)
  801021:	75 2d                	jne    801050 <__udivdi3+0x50>
  801023:	39 e9                	cmp    %ebp,%ecx
  801025:	77 61                	ja     801088 <__udivdi3+0x88>
  801027:	85 c9                	test   %ecx,%ecx
  801029:	89 ce                	mov    %ecx,%esi
  80102b:	75 0b                	jne    801038 <__udivdi3+0x38>
  80102d:	b8 01 00 00 00       	mov    $0x1,%eax
  801032:	31 d2                	xor    %edx,%edx
  801034:	f7 f1                	div    %ecx
  801036:	89 c6                	mov    %eax,%esi
  801038:	31 d2                	xor    %edx,%edx
  80103a:	89 e8                	mov    %ebp,%eax
  80103c:	f7 f6                	div    %esi
  80103e:	89 c5                	mov    %eax,%ebp
  801040:	89 f8                	mov    %edi,%eax
  801042:	f7 f6                	div    %esi
  801044:	89 ea                	mov    %ebp,%edx
  801046:	83 c4 0c             	add    $0xc,%esp
  801049:	5e                   	pop    %esi
  80104a:	5f                   	pop    %edi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    
  80104d:	8d 76 00             	lea    0x0(%esi),%esi
  801050:	39 e8                	cmp    %ebp,%eax
  801052:	77 24                	ja     801078 <__udivdi3+0x78>
  801054:	0f bd e8             	bsr    %eax,%ebp
  801057:	83 f5 1f             	xor    $0x1f,%ebp
  80105a:	75 3c                	jne    801098 <__udivdi3+0x98>
  80105c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801060:	39 34 24             	cmp    %esi,(%esp)
  801063:	0f 86 9f 00 00 00    	jbe    801108 <__udivdi3+0x108>
  801069:	39 d0                	cmp    %edx,%eax
  80106b:	0f 82 97 00 00 00    	jb     801108 <__udivdi3+0x108>
  801071:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801078:	31 d2                	xor    %edx,%edx
  80107a:	31 c0                	xor    %eax,%eax
  80107c:	83 c4 0c             	add    $0xc,%esp
  80107f:	5e                   	pop    %esi
  801080:	5f                   	pop    %edi
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    
  801083:	90                   	nop
  801084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801088:	89 f8                	mov    %edi,%eax
  80108a:	f7 f1                	div    %ecx
  80108c:	31 d2                	xor    %edx,%edx
  80108e:	83 c4 0c             	add    $0xc,%esp
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    
  801095:	8d 76 00             	lea    0x0(%esi),%esi
  801098:	89 e9                	mov    %ebp,%ecx
  80109a:	8b 3c 24             	mov    (%esp),%edi
  80109d:	d3 e0                	shl    %cl,%eax
  80109f:	89 c6                	mov    %eax,%esi
  8010a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8010a6:	29 e8                	sub    %ebp,%eax
  8010a8:	89 c1                	mov    %eax,%ecx
  8010aa:	d3 ef                	shr    %cl,%edi
  8010ac:	89 e9                	mov    %ebp,%ecx
  8010ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010b2:	8b 3c 24             	mov    (%esp),%edi
  8010b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8010b9:	89 d6                	mov    %edx,%esi
  8010bb:	d3 e7                	shl    %cl,%edi
  8010bd:	89 c1                	mov    %eax,%ecx
  8010bf:	89 3c 24             	mov    %edi,(%esp)
  8010c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010c6:	d3 ee                	shr    %cl,%esi
  8010c8:	89 e9                	mov    %ebp,%ecx
  8010ca:	d3 e2                	shl    %cl,%edx
  8010cc:	89 c1                	mov    %eax,%ecx
  8010ce:	d3 ef                	shr    %cl,%edi
  8010d0:	09 d7                	or     %edx,%edi
  8010d2:	89 f2                	mov    %esi,%edx
  8010d4:	89 f8                	mov    %edi,%eax
  8010d6:	f7 74 24 08          	divl   0x8(%esp)
  8010da:	89 d6                	mov    %edx,%esi
  8010dc:	89 c7                	mov    %eax,%edi
  8010de:	f7 24 24             	mull   (%esp)
  8010e1:	39 d6                	cmp    %edx,%esi
  8010e3:	89 14 24             	mov    %edx,(%esp)
  8010e6:	72 30                	jb     801118 <__udivdi3+0x118>
  8010e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010ec:	89 e9                	mov    %ebp,%ecx
  8010ee:	d3 e2                	shl    %cl,%edx
  8010f0:	39 c2                	cmp    %eax,%edx
  8010f2:	73 05                	jae    8010f9 <__udivdi3+0xf9>
  8010f4:	3b 34 24             	cmp    (%esp),%esi
  8010f7:	74 1f                	je     801118 <__udivdi3+0x118>
  8010f9:	89 f8                	mov    %edi,%eax
  8010fb:	31 d2                	xor    %edx,%edx
  8010fd:	e9 7a ff ff ff       	jmp    80107c <__udivdi3+0x7c>
  801102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801108:	31 d2                	xor    %edx,%edx
  80110a:	b8 01 00 00 00       	mov    $0x1,%eax
  80110f:	e9 68 ff ff ff       	jmp    80107c <__udivdi3+0x7c>
  801114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801118:	8d 47 ff             	lea    -0x1(%edi),%eax
  80111b:	31 d2                	xor    %edx,%edx
  80111d:	83 c4 0c             	add    $0xc,%esp
  801120:	5e                   	pop    %esi
  801121:	5f                   	pop    %edi
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    
  801124:	66 90                	xchg   %ax,%ax
  801126:	66 90                	xchg   %ax,%ax
  801128:	66 90                	xchg   %ax,%ax
  80112a:	66 90                	xchg   %ax,%ax
  80112c:	66 90                	xchg   %ax,%ax
  80112e:	66 90                	xchg   %ax,%ax

00801130 <__umoddi3>:
  801130:	55                   	push   %ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	83 ec 14             	sub    $0x14,%esp
  801136:	8b 44 24 28          	mov    0x28(%esp),%eax
  80113a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80113e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801142:	89 c7                	mov    %eax,%edi
  801144:	89 44 24 04          	mov    %eax,0x4(%esp)
  801148:	8b 44 24 30          	mov    0x30(%esp),%eax
  80114c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801150:	89 34 24             	mov    %esi,(%esp)
  801153:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801157:	85 c0                	test   %eax,%eax
  801159:	89 c2                	mov    %eax,%edx
  80115b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80115f:	75 17                	jne    801178 <__umoddi3+0x48>
  801161:	39 fe                	cmp    %edi,%esi
  801163:	76 4b                	jbe    8011b0 <__umoddi3+0x80>
  801165:	89 c8                	mov    %ecx,%eax
  801167:	89 fa                	mov    %edi,%edx
  801169:	f7 f6                	div    %esi
  80116b:	89 d0                	mov    %edx,%eax
  80116d:	31 d2                	xor    %edx,%edx
  80116f:	83 c4 14             	add    $0x14,%esp
  801172:	5e                   	pop    %esi
  801173:	5f                   	pop    %edi
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    
  801176:	66 90                	xchg   %ax,%ax
  801178:	39 f8                	cmp    %edi,%eax
  80117a:	77 54                	ja     8011d0 <__umoddi3+0xa0>
  80117c:	0f bd e8             	bsr    %eax,%ebp
  80117f:	83 f5 1f             	xor    $0x1f,%ebp
  801182:	75 5c                	jne    8011e0 <__umoddi3+0xb0>
  801184:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801188:	39 3c 24             	cmp    %edi,(%esp)
  80118b:	0f 87 e7 00 00 00    	ja     801278 <__umoddi3+0x148>
  801191:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801195:	29 f1                	sub    %esi,%ecx
  801197:	19 c7                	sbb    %eax,%edi
  801199:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80119d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8011a9:	83 c4 14             	add    $0x14,%esp
  8011ac:	5e                   	pop    %esi
  8011ad:	5f                   	pop    %edi
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    
  8011b0:	85 f6                	test   %esi,%esi
  8011b2:	89 f5                	mov    %esi,%ebp
  8011b4:	75 0b                	jne    8011c1 <__umoddi3+0x91>
  8011b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011bb:	31 d2                	xor    %edx,%edx
  8011bd:	f7 f6                	div    %esi
  8011bf:	89 c5                	mov    %eax,%ebp
  8011c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8011c5:	31 d2                	xor    %edx,%edx
  8011c7:	f7 f5                	div    %ebp
  8011c9:	89 c8                	mov    %ecx,%eax
  8011cb:	f7 f5                	div    %ebp
  8011cd:	eb 9c                	jmp    80116b <__umoddi3+0x3b>
  8011cf:	90                   	nop
  8011d0:	89 c8                	mov    %ecx,%eax
  8011d2:	89 fa                	mov    %edi,%edx
  8011d4:	83 c4 14             	add    $0x14,%esp
  8011d7:	5e                   	pop    %esi
  8011d8:	5f                   	pop    %edi
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    
  8011db:	90                   	nop
  8011dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011e0:	8b 04 24             	mov    (%esp),%eax
  8011e3:	be 20 00 00 00       	mov    $0x20,%esi
  8011e8:	89 e9                	mov    %ebp,%ecx
  8011ea:	29 ee                	sub    %ebp,%esi
  8011ec:	d3 e2                	shl    %cl,%edx
  8011ee:	89 f1                	mov    %esi,%ecx
  8011f0:	d3 e8                	shr    %cl,%eax
  8011f2:	89 e9                	mov    %ebp,%ecx
  8011f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f8:	8b 04 24             	mov    (%esp),%eax
  8011fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8011ff:	89 fa                	mov    %edi,%edx
  801201:	d3 e0                	shl    %cl,%eax
  801203:	89 f1                	mov    %esi,%ecx
  801205:	89 44 24 08          	mov    %eax,0x8(%esp)
  801209:	8b 44 24 10          	mov    0x10(%esp),%eax
  80120d:	d3 ea                	shr    %cl,%edx
  80120f:	89 e9                	mov    %ebp,%ecx
  801211:	d3 e7                	shl    %cl,%edi
  801213:	89 f1                	mov    %esi,%ecx
  801215:	d3 e8                	shr    %cl,%eax
  801217:	89 e9                	mov    %ebp,%ecx
  801219:	09 f8                	or     %edi,%eax
  80121b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80121f:	f7 74 24 04          	divl   0x4(%esp)
  801223:	d3 e7                	shl    %cl,%edi
  801225:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801229:	89 d7                	mov    %edx,%edi
  80122b:	f7 64 24 08          	mull   0x8(%esp)
  80122f:	39 d7                	cmp    %edx,%edi
  801231:	89 c1                	mov    %eax,%ecx
  801233:	89 14 24             	mov    %edx,(%esp)
  801236:	72 2c                	jb     801264 <__umoddi3+0x134>
  801238:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80123c:	72 22                	jb     801260 <__umoddi3+0x130>
  80123e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801242:	29 c8                	sub    %ecx,%eax
  801244:	19 d7                	sbb    %edx,%edi
  801246:	89 e9                	mov    %ebp,%ecx
  801248:	89 fa                	mov    %edi,%edx
  80124a:	d3 e8                	shr    %cl,%eax
  80124c:	89 f1                	mov    %esi,%ecx
  80124e:	d3 e2                	shl    %cl,%edx
  801250:	89 e9                	mov    %ebp,%ecx
  801252:	d3 ef                	shr    %cl,%edi
  801254:	09 d0                	or     %edx,%eax
  801256:	89 fa                	mov    %edi,%edx
  801258:	83 c4 14             	add    $0x14,%esp
  80125b:	5e                   	pop    %esi
  80125c:	5f                   	pop    %edi
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    
  80125f:	90                   	nop
  801260:	39 d7                	cmp    %edx,%edi
  801262:	75 da                	jne    80123e <__umoddi3+0x10e>
  801264:	8b 14 24             	mov    (%esp),%edx
  801267:	89 c1                	mov    %eax,%ecx
  801269:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80126d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801271:	eb cb                	jmp    80123e <__umoddi3+0x10e>
  801273:	90                   	nop
  801274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801278:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80127c:	0f 82 0f ff ff ff    	jb     801191 <__umoddi3+0x61>
  801282:	e9 1a ff ff ff       	jmp    8011a1 <__umoddi3+0x71>
