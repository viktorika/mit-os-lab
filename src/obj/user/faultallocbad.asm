
obj/user/faultallocbad.debug：     文件格式 elf32-i386


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
  800043:	c7 04 24 c0 21 80 00 	movl   $0x8021c0,(%esp)
  80004a:	e8 eb 01 00 00       	call   80023a <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800056:	00 
  800057:	89 d8                	mov    %ebx,%eax
  800059:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800069:	e8 db 0c 00 00       	call   800d49 <sys_page_alloc>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 24                	jns    800096 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800072:	89 44 24 10          	mov    %eax,0x10(%esp)
  800076:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007a:	c7 44 24 08 e0 21 80 	movl   $0x8021e0,0x8(%esp)
  800081:	00 
  800082:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800089:	00 
  80008a:	c7 04 24 ca 21 80 00 	movl   $0x8021ca,(%esp)
  800091:	e8 ab 00 00 00       	call   800141 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800096:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009a:	c7 44 24 08 0c 22 80 	movl   $0x80220c,0x8(%esp)
  8000a1:	00 
  8000a2:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000a9:	00 
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	e8 5e 07 00 00       	call   800810 <snprintf>
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
  8000c5:	e8 e7 0e 00 00       	call   800fb1 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000ca:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d1:	00 
  8000d2:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000d9:	e8 9e 0b 00 00       	call   800c7c <sys_cputs>
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
  8000ee:	e8 18 0c 00 00       	call   800d0b <sys_getenvid>
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x30>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  80012e:	e8 43 11 00 00       	call   801276 <close_all>
	sys_env_destroy(0);
  800133:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80013a:	e8 7a 0b 00 00       	call   800cb9 <sys_env_destroy>
}
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
  800146:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800149:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800152:	e8 b4 0b 00 00       	call   800d0b <sys_getenvid>
  800157:	8b 55 0c             	mov    0xc(%ebp),%edx
  80015a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80015e:	8b 55 08             	mov    0x8(%ebp),%edx
  800161:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800165:	89 74 24 08          	mov    %esi,0x8(%esp)
  800169:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016d:	c7 04 24 38 22 80 00 	movl   $0x802238,(%esp)
  800174:	e8 c1 00 00 00       	call   80023a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800179:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80017d:	8b 45 10             	mov    0x10(%ebp),%eax
  800180:	89 04 24             	mov    %eax,(%esp)
  800183:	e8 51 00 00 00       	call   8001d9 <vcprintf>
	cprintf("\n");
  800188:	c7 04 24 c8 26 80 00 	movl   $0x8026c8,(%esp)
  80018f:	e8 a6 00 00 00       	call   80023a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800194:	cc                   	int3   
  800195:	eb fd                	jmp    800194 <_panic+0x53>

00800197 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	83 ec 14             	sub    $0x14,%esp
  80019e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a1:	8b 13                	mov    (%ebx),%edx
  8001a3:	8d 42 01             	lea    0x1(%edx),%eax
  8001a6:	89 03                	mov    %eax,(%ebx)
  8001a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001af:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b4:	75 19                	jne    8001cf <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001b6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001bd:	00 
  8001be:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c1:	89 04 24             	mov    %eax,(%esp)
  8001c4:	e8 b3 0a 00 00       	call   800c7c <sys_cputs>
		b->idx = 0;
  8001c9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d3:	83 c4 14             	add    $0x14,%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5d                   	pop    %ebp
  8001d8:	c3                   	ret    

008001d9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e9:	00 00 00 
	b.cnt = 0;
  8001ec:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800200:	89 44 24 08          	mov    %eax,0x8(%esp)
  800204:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020e:	c7 04 24 97 01 80 00 	movl   $0x800197,(%esp)
  800215:	e8 ba 01 00 00       	call   8003d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800220:	89 44 24 04          	mov    %eax,0x4(%esp)
  800224:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022a:	89 04 24             	mov    %eax,(%esp)
  80022d:	e8 4a 0a 00 00       	call   800c7c <sys_cputs>

	return b.cnt;
}
  800232:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800240:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800243:	89 44 24 04          	mov    %eax,0x4(%esp)
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	89 04 24             	mov    %eax,(%esp)
  80024d:	e8 87 ff ff ff       	call   8001d9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800252:	c9                   	leave  
  800253:	c3                   	ret    
  800254:	66 90                	xchg   %ax,%ax
  800256:	66 90                	xchg   %ax,%ax
  800258:	66 90                	xchg   %ax,%ax
  80025a:	66 90                	xchg   %ax,%ax
  80025c:	66 90                	xchg   %ax,%ax
  80025e:	66 90                	xchg   %ax,%ax

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800274:	8b 75 0c             	mov    0xc(%ebp),%esi
  800277:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80027a:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800282:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800285:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800288:	39 f1                	cmp    %esi,%ecx
  80028a:	72 14                	jb     8002a0 <printnum+0x40>
  80028c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80028f:	76 0f                	jbe    8002a0 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800291:	8b 45 14             	mov    0x14(%ebp),%eax
  800294:	8d 70 ff             	lea    -0x1(%eax),%esi
  800297:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80029a:	85 f6                	test   %esi,%esi
  80029c:	7f 60                	jg     8002fe <printnum+0x9e>
  80029e:	eb 72                	jmp    800312 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002a3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002a7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8002aa:	8d 51 ff             	lea    -0x1(%ecx),%edx
  8002ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b5:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002b9:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002bd:	89 c3                	mov    %eax,%ebx
  8002bf:	89 d6                	mov    %edx,%esi
  8002c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002c4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002c7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002cb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dc:	e8 4f 1c 00 00       	call   801f30 <__udivdi3>
  8002e1:	89 d9                	mov    %ebx,%ecx
  8002e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002e7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002eb:	89 04 24             	mov    %eax,(%esp)
  8002ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f2:	89 fa                	mov    %edi,%edx
  8002f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f7:	e8 64 ff ff ff       	call   800260 <printnum>
  8002fc:	eb 14                	jmp    800312 <printnum+0xb2>
			putch(padc, putdat);
  8002fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800302:	8b 45 18             	mov    0x18(%ebp),%eax
  800305:	89 04 24             	mov    %eax,(%esp)
  800308:	ff d3                	call   *%ebx
		while (--width > 0)
  80030a:	83 ee 01             	sub    $0x1,%esi
  80030d:	75 ef                	jne    8002fe <printnum+0x9e>
  80030f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800312:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800316:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80031a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80031d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800320:	89 44 24 08          	mov    %eax,0x8(%esp)
  800324:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800328:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032b:	89 04 24             	mov    %eax,(%esp)
  80032e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800331:	89 44 24 04          	mov    %eax,0x4(%esp)
  800335:	e8 26 1d 00 00       	call   802060 <__umoddi3>
  80033a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033e:	0f be 80 5b 22 80 00 	movsbl 0x80225b(%eax),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034b:	ff d0                	call   *%eax
}
  80034d:	83 c4 3c             	add    $0x3c,%esp
  800350:	5b                   	pop    %ebx
  800351:	5e                   	pop    %esi
  800352:	5f                   	pop    %edi
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800358:	83 fa 01             	cmp    $0x1,%edx
  80035b:	7e 0e                	jle    80036b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035d:	8b 10                	mov    (%eax),%edx
  80035f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800362:	89 08                	mov    %ecx,(%eax)
  800364:	8b 02                	mov    (%edx),%eax
  800366:	8b 52 04             	mov    0x4(%edx),%edx
  800369:	eb 22                	jmp    80038d <getuint+0x38>
	else if (lflag)
  80036b:	85 d2                	test   %edx,%edx
  80036d:	74 10                	je     80037f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80036f:	8b 10                	mov    (%eax),%edx
  800371:	8d 4a 04             	lea    0x4(%edx),%ecx
  800374:	89 08                	mov    %ecx,(%eax)
  800376:	8b 02                	mov    (%edx),%eax
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
  80037d:	eb 0e                	jmp    80038d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80037f:	8b 10                	mov    (%eax),%edx
  800381:	8d 4a 04             	lea    0x4(%edx),%ecx
  800384:	89 08                	mov    %ecx,(%eax)
  800386:	8b 02                	mov    (%edx),%eax
  800388:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800395:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	3b 50 04             	cmp    0x4(%eax),%edx
  80039e:	73 0a                	jae    8003aa <sprintputch+0x1b>
		*b->buf++ = ch;
  8003a0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	88 02                	mov    %al,(%edx)
}
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <printfmt>:
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8003b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ca:	89 04 24             	mov    %eax,(%esp)
  8003cd:	e8 02 00 00 00       	call   8003d4 <vprintfmt>
}
  8003d2:	c9                   	leave  
  8003d3:	c3                   	ret    

008003d4 <vprintfmt>:
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	57                   	push   %edi
  8003d8:	56                   	push   %esi
  8003d9:	53                   	push   %ebx
  8003da:	83 ec 3c             	sub    $0x3c,%esp
  8003dd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003e3:	eb 18                	jmp    8003fd <vprintfmt+0x29>
			if (ch == '\0')
  8003e5:	85 c0                	test   %eax,%eax
  8003e7:	0f 84 c3 03 00 00    	je     8007b0 <vprintfmt+0x3dc>
			putch(ch, putdat);
  8003ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f1:	89 04 24             	mov    %eax,(%esp)
  8003f4:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f7:	89 f3                	mov    %esi,%ebx
  8003f9:	eb 02                	jmp    8003fd <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  8003fb:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003fd:	8d 73 01             	lea    0x1(%ebx),%esi
  800400:	0f b6 03             	movzbl (%ebx),%eax
  800403:	83 f8 25             	cmp    $0x25,%eax
  800406:	75 dd                	jne    8003e5 <vprintfmt+0x11>
  800408:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80040c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800413:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80041a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800421:	ba 00 00 00 00       	mov    $0x0,%edx
  800426:	eb 1d                	jmp    800445 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800428:	89 de                	mov    %ebx,%esi
			padc = '-';
  80042a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80042e:	eb 15                	jmp    800445 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800430:	89 de                	mov    %ebx,%esi
			padc = '0';
  800432:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800436:	eb 0d                	jmp    800445 <vprintfmt+0x71>
				width = precision, precision = -1;
  800438:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80043b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80043e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8d 5e 01             	lea    0x1(%esi),%ebx
  800448:	0f b6 06             	movzbl (%esi),%eax
  80044b:	0f b6 c8             	movzbl %al,%ecx
  80044e:	83 e8 23             	sub    $0x23,%eax
  800451:	3c 55                	cmp    $0x55,%al
  800453:	0f 87 2f 03 00 00    	ja     800788 <vprintfmt+0x3b4>
  800459:	0f b6 c0             	movzbl %al,%eax
  80045c:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
				precision = precision * 10 + ch - '0';
  800463:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800466:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  800469:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80046d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800470:	83 f9 09             	cmp    $0x9,%ecx
  800473:	77 50                	ja     8004c5 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  800475:	89 de                	mov    %ebx,%esi
  800477:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  80047a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80047d:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800480:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800484:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800487:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80048a:	83 fb 09             	cmp    $0x9,%ebx
  80048d:	76 eb                	jbe    80047a <vprintfmt+0xa6>
  80048f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800492:	eb 33                	jmp    8004c7 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8d 48 04             	lea    0x4(%eax),%ecx
  80049a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8004a4:	eb 21                	jmp    8004c7 <vprintfmt+0xf3>
  8004a6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004a9:	85 c9                	test   %ecx,%ecx
  8004ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b0:	0f 49 c1             	cmovns %ecx,%eax
  8004b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	89 de                	mov    %ebx,%esi
  8004b8:	eb 8b                	jmp    800445 <vprintfmt+0x71>
  8004ba:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8004bc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c3:	eb 80                	jmp    800445 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	89 de                	mov    %ebx,%esi
			if (width < 0)
  8004c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004cb:	0f 89 74 ff ff ff    	jns    800445 <vprintfmt+0x71>
  8004d1:	e9 62 ff ff ff       	jmp    800438 <vprintfmt+0x64>
			lflag++;
  8004d6:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8004db:	e9 65 ff ff ff       	jmp    800445 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ed:	8b 00                	mov    (%eax),%eax
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004f5:	e9 03 ff ff ff       	jmp    8003fd <vprintfmt+0x29>
			err = va_arg(ap, int);
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 50 04             	lea    0x4(%eax),%edx
  800500:	89 55 14             	mov    %edx,0x14(%ebp)
  800503:	8b 00                	mov    (%eax),%eax
  800505:	99                   	cltd   
  800506:	31 d0                	xor    %edx,%eax
  800508:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050a:	83 f8 0f             	cmp    $0xf,%eax
  80050d:	7f 0b                	jg     80051a <vprintfmt+0x146>
  80050f:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  800516:	85 d2                	test   %edx,%edx
  800518:	75 20                	jne    80053a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80051a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051e:	c7 44 24 08 73 22 80 	movl   $0x802273,0x8(%esp)
  800525:	00 
  800526:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052a:	8b 45 08             	mov    0x8(%ebp),%eax
  80052d:	89 04 24             	mov    %eax,(%esp)
  800530:	e8 77 fe ff ff       	call   8003ac <printfmt>
  800535:	e9 c3 fe ff ff       	jmp    8003fd <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80053a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80053e:	c7 44 24 08 96 26 80 	movl   $0x802696,0x8(%esp)
  800545:	00 
  800546:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054a:	8b 45 08             	mov    0x8(%ebp),%eax
  80054d:	89 04 24             	mov    %eax,(%esp)
  800550:	e8 57 fe ff ff       	call   8003ac <printfmt>
  800555:	e9 a3 fe ff ff       	jmp    8003fd <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80055d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 04             	lea    0x4(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80056b:	85 c0                	test   %eax,%eax
  80056d:	ba 6c 22 80 00       	mov    $0x80226c,%edx
  800572:	0f 45 d0             	cmovne %eax,%edx
  800575:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800578:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80057c:	74 04                	je     800582 <vprintfmt+0x1ae>
  80057e:	85 f6                	test   %esi,%esi
  800580:	7f 19                	jg     80059b <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800582:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800585:	8d 70 01             	lea    0x1(%eax),%esi
  800588:	0f b6 10             	movzbl (%eax),%edx
  80058b:	0f be c2             	movsbl %dl,%eax
  80058e:	85 c0                	test   %eax,%eax
  800590:	0f 85 95 00 00 00    	jne    80062b <vprintfmt+0x257>
  800596:	e9 85 00 00 00       	jmp    800620 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80059f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005a2:	89 04 24             	mov    %eax,(%esp)
  8005a5:	e8 b8 02 00 00       	call   800862 <strnlen>
  8005aa:	29 c6                	sub    %eax,%esi
  8005ac:	89 f0                	mov    %esi,%eax
  8005ae:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8005b1:	85 f6                	test   %esi,%esi
  8005b3:	7e cd                	jle    800582 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8005b5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8005b9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005bc:	89 c3                	mov    %eax,%ebx
  8005be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c2:	89 34 24             	mov    %esi,(%esp)
  8005c5:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c8:	83 eb 01             	sub    $0x1,%ebx
  8005cb:	75 f1                	jne    8005be <vprintfmt+0x1ea>
  8005cd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005d3:	eb ad                	jmp    800582 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005d9:	74 1e                	je     8005f9 <vprintfmt+0x225>
  8005db:	0f be d2             	movsbl %dl,%edx
  8005de:	83 ea 20             	sub    $0x20,%edx
  8005e1:	83 fa 5e             	cmp    $0x5e,%edx
  8005e4:	76 13                	jbe    8005f9 <vprintfmt+0x225>
					putch('?', putdat);
  8005e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ed:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005f4:	ff 55 08             	call   *0x8(%ebp)
  8005f7:	eb 0d                	jmp    800606 <vprintfmt+0x232>
					putch(ch, putdat);
  8005f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005fc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800600:	89 04 24             	mov    %eax,(%esp)
  800603:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800606:	83 ef 01             	sub    $0x1,%edi
  800609:	83 c6 01             	add    $0x1,%esi
  80060c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800610:	0f be c2             	movsbl %dl,%eax
  800613:	85 c0                	test   %eax,%eax
  800615:	75 20                	jne    800637 <vprintfmt+0x263>
  800617:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80061a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80061d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800620:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800624:	7f 25                	jg     80064b <vprintfmt+0x277>
  800626:	e9 d2 fd ff ff       	jmp    8003fd <vprintfmt+0x29>
  80062b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80062e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800631:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800634:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800637:	85 db                	test   %ebx,%ebx
  800639:	78 9a                	js     8005d5 <vprintfmt+0x201>
  80063b:	83 eb 01             	sub    $0x1,%ebx
  80063e:	79 95                	jns    8005d5 <vprintfmt+0x201>
  800640:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800643:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800646:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800649:	eb d5                	jmp    800620 <vprintfmt+0x24c>
  80064b:	8b 75 08             	mov    0x8(%ebp),%esi
  80064e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800651:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  800654:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800658:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80065f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800661:	83 eb 01             	sub    $0x1,%ebx
  800664:	75 ee                	jne    800654 <vprintfmt+0x280>
  800666:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800669:	e9 8f fd ff ff       	jmp    8003fd <vprintfmt+0x29>
	if (lflag >= 2)
  80066e:	83 fa 01             	cmp    $0x1,%edx
  800671:	7e 16                	jle    800689 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8d 50 08             	lea    0x8(%eax),%edx
  800679:	89 55 14             	mov    %edx,0x14(%ebp)
  80067c:	8b 50 04             	mov    0x4(%eax),%edx
  80067f:	8b 00                	mov    (%eax),%eax
  800681:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800684:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800687:	eb 32                	jmp    8006bb <vprintfmt+0x2e7>
	else if (lflag)
  800689:	85 d2                	test   %edx,%edx
  80068b:	74 18                	je     8006a5 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 50 04             	lea    0x4(%eax),%edx
  800693:	89 55 14             	mov    %edx,0x14(%ebp)
  800696:	8b 30                	mov    (%eax),%esi
  800698:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80069b:	89 f0                	mov    %esi,%eax
  80069d:	c1 f8 1f             	sar    $0x1f,%eax
  8006a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006a3:	eb 16                	jmp    8006bb <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8d 50 04             	lea    0x4(%eax),%edx
  8006ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ae:	8b 30                	mov    (%eax),%esi
  8006b0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006b3:	89 f0                	mov    %esi,%eax
  8006b5:	c1 f8 1f             	sar    $0x1f,%eax
  8006b8:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  8006bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006be:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  8006c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8006c6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ca:	0f 89 80 00 00 00    	jns    800750 <vprintfmt+0x37c>
				putch('-', putdat);
  8006d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006db:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006e4:	f7 d8                	neg    %eax
  8006e6:	83 d2 00             	adc    $0x0,%edx
  8006e9:	f7 da                	neg    %edx
			base = 10;
  8006eb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f0:	eb 5e                	jmp    800750 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8006f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f5:	e8 5b fc ff ff       	call   800355 <getuint>
			base = 10;
  8006fa:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006ff:	eb 4f                	jmp    800750 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800701:	8d 45 14             	lea    0x14(%ebp),%eax
  800704:	e8 4c fc ff ff       	call   800355 <getuint>
			base = 8;
  800709:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80070e:	eb 40                	jmp    800750 <vprintfmt+0x37c>
			putch('0', putdat);
  800710:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800714:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80071b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80071e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800722:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800729:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 50 04             	lea    0x4(%eax),%edx
  800732:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800735:	8b 00                	mov    (%eax),%eax
  800737:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80073c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800741:	eb 0d                	jmp    800750 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800743:	8d 45 14             	lea    0x14(%ebp),%eax
  800746:	e8 0a fc ff ff       	call   800355 <getuint>
			base = 16;
  80074b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800750:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800754:	89 74 24 10          	mov    %esi,0x10(%esp)
  800758:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80075b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80075f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800763:	89 04 24             	mov    %eax,(%esp)
  800766:	89 54 24 04          	mov    %edx,0x4(%esp)
  80076a:	89 fa                	mov    %edi,%edx
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	e8 ec fa ff ff       	call   800260 <printnum>
			break;
  800774:	e9 84 fc ff ff       	jmp    8003fd <vprintfmt+0x29>
			putch(ch, putdat);
  800779:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077d:	89 0c 24             	mov    %ecx,(%esp)
  800780:	ff 55 08             	call   *0x8(%ebp)
			break;
  800783:	e9 75 fc ff ff       	jmp    8003fd <vprintfmt+0x29>
			putch('%', putdat);
  800788:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800793:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800796:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80079a:	0f 84 5b fc ff ff    	je     8003fb <vprintfmt+0x27>
  8007a0:	89 f3                	mov    %esi,%ebx
  8007a2:	83 eb 01             	sub    $0x1,%ebx
  8007a5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007a9:	75 f7                	jne    8007a2 <vprintfmt+0x3ce>
  8007ab:	e9 4d fc ff ff       	jmp    8003fd <vprintfmt+0x29>
}
  8007b0:	83 c4 3c             	add    $0x3c,%esp
  8007b3:	5b                   	pop    %ebx
  8007b4:	5e                   	pop    %esi
  8007b5:	5f                   	pop    %edi
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	83 ec 28             	sub    $0x28,%esp
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007cb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d5:	85 c0                	test   %eax,%eax
  8007d7:	74 30                	je     800809 <vsnprintf+0x51>
  8007d9:	85 d2                	test   %edx,%edx
  8007db:	7e 2c                	jle    800809 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007eb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f2:	c7 04 24 8f 03 80 00 	movl   $0x80038f,(%esp)
  8007f9:	e8 d6 fb ff ff       	call   8003d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800801:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800804:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800807:	eb 05                	jmp    80080e <vsnprintf+0x56>
		return -E_INVAL;
  800809:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80080e:	c9                   	leave  
  80080f:	c3                   	ret    

00800810 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800816:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800819:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081d:	8b 45 10             	mov    0x10(%ebp),%eax
  800820:	89 44 24 08          	mov    %eax,0x8(%esp)
  800824:	8b 45 0c             	mov    0xc(%ebp),%eax
  800827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	89 04 24             	mov    %eax,(%esp)
  800831:	e8 82 ff ff ff       	call   8007b8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800836:	c9                   	leave  
  800837:	c3                   	ret    
  800838:	66 90                	xchg   %ax,%ax
  80083a:	66 90                	xchg   %ax,%ax
  80083c:	66 90                	xchg   %ax,%ax
  80083e:	66 90                	xchg   %ax,%ax

00800840 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800846:	80 3a 00             	cmpb   $0x0,(%edx)
  800849:	74 10                	je     80085b <strlen+0x1b>
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800850:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800853:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800857:	75 f7                	jne    800850 <strlen+0x10>
  800859:	eb 05                	jmp    800860 <strlen+0x20>
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800869:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086c:	85 c9                	test   %ecx,%ecx
  80086e:	74 1c                	je     80088c <strnlen+0x2a>
  800870:	80 3b 00             	cmpb   $0x0,(%ebx)
  800873:	74 1e                	je     800893 <strnlen+0x31>
  800875:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80087a:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	39 ca                	cmp    %ecx,%edx
  80087e:	74 18                	je     800898 <strnlen+0x36>
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800888:	75 f0                	jne    80087a <strnlen+0x18>
  80088a:	eb 0c                	jmp    800898 <strnlen+0x36>
  80088c:	b8 00 00 00 00       	mov    $0x0,%eax
  800891:	eb 05                	jmp    800898 <strnlen+0x36>
  800893:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800898:	5b                   	pop    %ebx
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a5:	89 c2                	mov    %eax,%edx
  8008a7:	83 c2 01             	add    $0x1,%edx
  8008aa:	83 c1 01             	add    $0x1,%ecx
  8008ad:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008b1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b4:	84 db                	test   %bl,%bl
  8008b6:	75 ef                	jne    8008a7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b8:	5b                   	pop    %ebx
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	83 ec 08             	sub    $0x8,%esp
  8008c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c5:	89 1c 24             	mov    %ebx,(%esp)
  8008c8:	e8 73 ff ff ff       	call   800840 <strlen>
	strcpy(dst + len, src);
  8008cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d4:	01 d8                	add    %ebx,%eax
  8008d6:	89 04 24             	mov    %eax,(%esp)
  8008d9:	e8 bd ff ff ff       	call   80089b <strcpy>
	return dst;
}
  8008de:	89 d8                	mov    %ebx,%eax
  8008e0:	83 c4 08             	add    $0x8,%esp
  8008e3:	5b                   	pop    %ebx
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	56                   	push   %esi
  8008ea:	53                   	push   %ebx
  8008eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f4:	85 db                	test   %ebx,%ebx
  8008f6:	74 17                	je     80090f <strncpy+0x29>
  8008f8:	01 f3                	add    %esi,%ebx
  8008fa:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8008fc:	83 c1 01             	add    $0x1,%ecx
  8008ff:	0f b6 02             	movzbl (%edx),%eax
  800902:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800905:	80 3a 01             	cmpb   $0x1,(%edx)
  800908:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80090b:	39 d9                	cmp    %ebx,%ecx
  80090d:	75 ed                	jne    8008fc <strncpy+0x16>
	}
	return ret;
}
  80090f:	89 f0                	mov    %esi,%eax
  800911:	5b                   	pop    %ebx
  800912:	5e                   	pop    %esi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800921:	8b 75 10             	mov    0x10(%ebp),%esi
  800924:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800926:	85 f6                	test   %esi,%esi
  800928:	74 34                	je     80095e <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  80092a:	83 fe 01             	cmp    $0x1,%esi
  80092d:	74 26                	je     800955 <strlcpy+0x40>
  80092f:	0f b6 0b             	movzbl (%ebx),%ecx
  800932:	84 c9                	test   %cl,%cl
  800934:	74 23                	je     800959 <strlcpy+0x44>
  800936:	83 ee 02             	sub    $0x2,%esi
  800939:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  80093e:	83 c0 01             	add    $0x1,%eax
  800941:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800944:	39 f2                	cmp    %esi,%edx
  800946:	74 13                	je     80095b <strlcpy+0x46>
  800948:	83 c2 01             	add    $0x1,%edx
  80094b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80094f:	84 c9                	test   %cl,%cl
  800951:	75 eb                	jne    80093e <strlcpy+0x29>
  800953:	eb 06                	jmp    80095b <strlcpy+0x46>
  800955:	89 f8                	mov    %edi,%eax
  800957:	eb 02                	jmp    80095b <strlcpy+0x46>
  800959:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  80095b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80095e:	29 f8                	sub    %edi,%eax
}
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5f                   	pop    %edi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80096e:	0f b6 01             	movzbl (%ecx),%eax
  800971:	84 c0                	test   %al,%al
  800973:	74 15                	je     80098a <strcmp+0x25>
  800975:	3a 02                	cmp    (%edx),%al
  800977:	75 11                	jne    80098a <strcmp+0x25>
		p++, q++;
  800979:	83 c1 01             	add    $0x1,%ecx
  80097c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80097f:	0f b6 01             	movzbl (%ecx),%eax
  800982:	84 c0                	test   %al,%al
  800984:	74 04                	je     80098a <strcmp+0x25>
  800986:	3a 02                	cmp    (%edx),%al
  800988:	74 ef                	je     800979 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80098a:	0f b6 c0             	movzbl %al,%eax
  80098d:	0f b6 12             	movzbl (%edx),%edx
  800990:	29 d0                	sub    %edx,%eax
}
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009a2:	85 f6                	test   %esi,%esi
  8009a4:	74 29                	je     8009cf <strncmp+0x3b>
  8009a6:	0f b6 03             	movzbl (%ebx),%eax
  8009a9:	84 c0                	test   %al,%al
  8009ab:	74 30                	je     8009dd <strncmp+0x49>
  8009ad:	3a 02                	cmp    (%edx),%al
  8009af:	75 2c                	jne    8009dd <strncmp+0x49>
  8009b1:	8d 43 01             	lea    0x1(%ebx),%eax
  8009b4:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8009b6:	89 c3                	mov    %eax,%ebx
  8009b8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009bb:	39 f0                	cmp    %esi,%eax
  8009bd:	74 17                	je     8009d6 <strncmp+0x42>
  8009bf:	0f b6 08             	movzbl (%eax),%ecx
  8009c2:	84 c9                	test   %cl,%cl
  8009c4:	74 17                	je     8009dd <strncmp+0x49>
  8009c6:	83 c0 01             	add    $0x1,%eax
  8009c9:	3a 0a                	cmp    (%edx),%cl
  8009cb:	74 e9                	je     8009b6 <strncmp+0x22>
  8009cd:	eb 0e                	jmp    8009dd <strncmp+0x49>
	if (n == 0)
		return 0;
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d4:	eb 0f                	jmp    8009e5 <strncmp+0x51>
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009db:	eb 08                	jmp    8009e5 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009dd:	0f b6 03             	movzbl (%ebx),%eax
  8009e0:	0f b6 12             	movzbl (%edx),%edx
  8009e3:	29 d0                	sub    %edx,%eax
}
  8009e5:	5b                   	pop    %ebx
  8009e6:	5e                   	pop    %esi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	53                   	push   %ebx
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009f3:	0f b6 18             	movzbl (%eax),%ebx
  8009f6:	84 db                	test   %bl,%bl
  8009f8:	74 1d                	je     800a17 <strchr+0x2e>
  8009fa:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009fc:	38 d3                	cmp    %dl,%bl
  8009fe:	75 06                	jne    800a06 <strchr+0x1d>
  800a00:	eb 1a                	jmp    800a1c <strchr+0x33>
  800a02:	38 ca                	cmp    %cl,%dl
  800a04:	74 16                	je     800a1c <strchr+0x33>
	for (; *s; s++)
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	0f b6 10             	movzbl (%eax),%edx
  800a0c:	84 d2                	test   %dl,%dl
  800a0e:	75 f2                	jne    800a02 <strchr+0x19>
			return (char *) s;
	return 0;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
  800a15:	eb 05                	jmp    800a1c <strchr+0x33>
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	53                   	push   %ebx
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a29:	0f b6 18             	movzbl (%eax),%ebx
  800a2c:	84 db                	test   %bl,%bl
  800a2e:	74 16                	je     800a46 <strfind+0x27>
  800a30:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a32:	38 d3                	cmp    %dl,%bl
  800a34:	75 06                	jne    800a3c <strfind+0x1d>
  800a36:	eb 0e                	jmp    800a46 <strfind+0x27>
  800a38:	38 ca                	cmp    %cl,%dl
  800a3a:	74 0a                	je     800a46 <strfind+0x27>
	for (; *s; s++)
  800a3c:	83 c0 01             	add    $0x1,%eax
  800a3f:	0f b6 10             	movzbl (%eax),%edx
  800a42:	84 d2                	test   %dl,%dl
  800a44:	75 f2                	jne    800a38 <strfind+0x19>
			break;
	return (char *) s;
}
  800a46:	5b                   	pop    %ebx
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
  800a4f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a55:	85 c9                	test   %ecx,%ecx
  800a57:	74 36                	je     800a8f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a59:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5f:	75 28                	jne    800a89 <memset+0x40>
  800a61:	f6 c1 03             	test   $0x3,%cl
  800a64:	75 23                	jne    800a89 <memset+0x40>
		c &= 0xFF;
  800a66:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a6a:	89 d3                	mov    %edx,%ebx
  800a6c:	c1 e3 08             	shl    $0x8,%ebx
  800a6f:	89 d6                	mov    %edx,%esi
  800a71:	c1 e6 18             	shl    $0x18,%esi
  800a74:	89 d0                	mov    %edx,%eax
  800a76:	c1 e0 10             	shl    $0x10,%eax
  800a79:	09 f0                	or     %esi,%eax
  800a7b:	09 c2                	or     %eax,%edx
  800a7d:	89 d0                	mov    %edx,%eax
  800a7f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a81:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a84:	fc                   	cld    
  800a85:	f3 ab                	rep stos %eax,%es:(%edi)
  800a87:	eb 06                	jmp    800a8f <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8c:	fc                   	cld    
  800a8d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8f:	89 f8                	mov    %edi,%eax
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5f                   	pop    %edi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	57                   	push   %edi
  800a9a:	56                   	push   %esi
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa4:	39 c6                	cmp    %eax,%esi
  800aa6:	73 35                	jae    800add <memmove+0x47>
  800aa8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aab:	39 d0                	cmp    %edx,%eax
  800aad:	73 2e                	jae    800add <memmove+0x47>
		s += n;
		d += n;
  800aaf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ab2:	89 d6                	mov    %edx,%esi
  800ab4:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800abc:	75 13                	jne    800ad1 <memmove+0x3b>
  800abe:	f6 c1 03             	test   $0x3,%cl
  800ac1:	75 0e                	jne    800ad1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac3:	83 ef 04             	sub    $0x4,%edi
  800ac6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800acc:	fd                   	std    
  800acd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acf:	eb 09                	jmp    800ada <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ad1:	83 ef 01             	sub    $0x1,%edi
  800ad4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ad7:	fd                   	std    
  800ad8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ada:	fc                   	cld    
  800adb:	eb 1d                	jmp    800afa <memmove+0x64>
  800add:	89 f2                	mov    %esi,%edx
  800adf:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae1:	f6 c2 03             	test   $0x3,%dl
  800ae4:	75 0f                	jne    800af5 <memmove+0x5f>
  800ae6:	f6 c1 03             	test   $0x3,%cl
  800ae9:	75 0a                	jne    800af5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aeb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aee:	89 c7                	mov    %eax,%edi
  800af0:	fc                   	cld    
  800af1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af3:	eb 05                	jmp    800afa <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800af5:	89 c7                	mov    %eax,%edi
  800af7:	fc                   	cld    
  800af8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b04:	8b 45 10             	mov    0x10(%ebp),%eax
  800b07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	89 04 24             	mov    %eax,(%esp)
  800b18:	e8 79 ff ff ff       	call   800a96 <memmove>
}
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b31:	85 c0                	test   %eax,%eax
  800b33:	74 36                	je     800b6b <memcmp+0x4c>
		if (*s1 != *s2)
  800b35:	0f b6 03             	movzbl (%ebx),%eax
  800b38:	0f b6 0e             	movzbl (%esi),%ecx
  800b3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b40:	38 c8                	cmp    %cl,%al
  800b42:	74 1c                	je     800b60 <memcmp+0x41>
  800b44:	eb 10                	jmp    800b56 <memcmp+0x37>
  800b46:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b4b:	83 c2 01             	add    $0x1,%edx
  800b4e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b52:	38 c8                	cmp    %cl,%al
  800b54:	74 0a                	je     800b60 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b56:	0f b6 c0             	movzbl %al,%eax
  800b59:	0f b6 c9             	movzbl %cl,%ecx
  800b5c:	29 c8                	sub    %ecx,%eax
  800b5e:	eb 10                	jmp    800b70 <memcmp+0x51>
	while (n-- > 0) {
  800b60:	39 fa                	cmp    %edi,%edx
  800b62:	75 e2                	jne    800b46 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800b64:	b8 00 00 00 00       	mov    $0x0,%eax
  800b69:	eb 05                	jmp    800b70 <memcmp+0x51>
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	53                   	push   %ebx
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b7f:	89 c2                	mov    %eax,%edx
  800b81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b84:	39 d0                	cmp    %edx,%eax
  800b86:	73 13                	jae    800b9b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b88:	89 d9                	mov    %ebx,%ecx
  800b8a:	38 18                	cmp    %bl,(%eax)
  800b8c:	75 06                	jne    800b94 <memfind+0x1f>
  800b8e:	eb 0b                	jmp    800b9b <memfind+0x26>
  800b90:	38 08                	cmp    %cl,(%eax)
  800b92:	74 07                	je     800b9b <memfind+0x26>
	for (; s < ends; s++)
  800b94:	83 c0 01             	add    $0x1,%eax
  800b97:	39 d0                	cmp    %edx,%eax
  800b99:	75 f5                	jne    800b90 <memfind+0x1b>
			break;
	return (void *) s;
}
  800b9b:	5b                   	pop    %ebx
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba7:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800baa:	0f b6 0a             	movzbl (%edx),%ecx
  800bad:	80 f9 09             	cmp    $0x9,%cl
  800bb0:	74 05                	je     800bb7 <strtol+0x19>
  800bb2:	80 f9 20             	cmp    $0x20,%cl
  800bb5:	75 10                	jne    800bc7 <strtol+0x29>
		s++;
  800bb7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800bba:	0f b6 0a             	movzbl (%edx),%ecx
  800bbd:	80 f9 09             	cmp    $0x9,%cl
  800bc0:	74 f5                	je     800bb7 <strtol+0x19>
  800bc2:	80 f9 20             	cmp    $0x20,%cl
  800bc5:	74 f0                	je     800bb7 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800bc7:	80 f9 2b             	cmp    $0x2b,%cl
  800bca:	75 0a                	jne    800bd6 <strtol+0x38>
		s++;
  800bcc:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800bcf:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd4:	eb 11                	jmp    800be7 <strtol+0x49>
  800bd6:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800bdb:	80 f9 2d             	cmp    $0x2d,%cl
  800bde:	75 07                	jne    800be7 <strtol+0x49>
		s++, neg = 1;
  800be0:	83 c2 01             	add    $0x1,%edx
  800be3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be7:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800bec:	75 15                	jne    800c03 <strtol+0x65>
  800bee:	80 3a 30             	cmpb   $0x30,(%edx)
  800bf1:	75 10                	jne    800c03 <strtol+0x65>
  800bf3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bf7:	75 0a                	jne    800c03 <strtol+0x65>
		s += 2, base = 16;
  800bf9:	83 c2 02             	add    $0x2,%edx
  800bfc:	b8 10 00 00 00       	mov    $0x10,%eax
  800c01:	eb 10                	jmp    800c13 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800c03:	85 c0                	test   %eax,%eax
  800c05:	75 0c                	jne    800c13 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c07:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800c09:	80 3a 30             	cmpb   $0x30,(%edx)
  800c0c:	75 05                	jne    800c13 <strtol+0x75>
		s++, base = 8;
  800c0e:	83 c2 01             	add    $0x1,%edx
  800c11:	b0 08                	mov    $0x8,%al
		base = 10;
  800c13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c18:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c1b:	0f b6 0a             	movzbl (%edx),%ecx
  800c1e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c21:	89 f0                	mov    %esi,%eax
  800c23:	3c 09                	cmp    $0x9,%al
  800c25:	77 08                	ja     800c2f <strtol+0x91>
			dig = *s - '0';
  800c27:	0f be c9             	movsbl %cl,%ecx
  800c2a:	83 e9 30             	sub    $0x30,%ecx
  800c2d:	eb 20                	jmp    800c4f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800c2f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c32:	89 f0                	mov    %esi,%eax
  800c34:	3c 19                	cmp    $0x19,%al
  800c36:	77 08                	ja     800c40 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c38:	0f be c9             	movsbl %cl,%ecx
  800c3b:	83 e9 57             	sub    $0x57,%ecx
  800c3e:	eb 0f                	jmp    800c4f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800c40:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c43:	89 f0                	mov    %esi,%eax
  800c45:	3c 19                	cmp    $0x19,%al
  800c47:	77 16                	ja     800c5f <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c49:	0f be c9             	movsbl %cl,%ecx
  800c4c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c4f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c52:	7d 0f                	jge    800c63 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c54:	83 c2 01             	add    $0x1,%edx
  800c57:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c5b:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c5d:	eb bc                	jmp    800c1b <strtol+0x7d>
  800c5f:	89 d8                	mov    %ebx,%eax
  800c61:	eb 02                	jmp    800c65 <strtol+0xc7>
  800c63:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c65:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c69:	74 05                	je     800c70 <strtol+0xd2>
		*endptr = (char *) s;
  800c6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c70:	f7 d8                	neg    %eax
  800c72:	85 ff                	test   %edi,%edi
  800c74:	0f 44 c3             	cmove  %ebx,%eax
}
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c82:	b8 00 00 00 00       	mov    $0x0,%eax
  800c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8d:	89 c3                	mov    %eax,%ebx
  800c8f:	89 c7                	mov    %eax,%edi
  800c91:	89 c6                	mov    %eax,%esi
  800c93:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ca0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca5:	b8 01 00 00 00       	mov    $0x1,%eax
  800caa:	89 d1                	mov    %edx,%ecx
  800cac:	89 d3                	mov    %edx,%ebx
  800cae:	89 d7                	mov    %edx,%edi
  800cb0:	89 d6                	mov    %edx,%esi
  800cb2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
  800cbf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cc2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc7:	b8 03 00 00 00       	mov    $0x3,%eax
  800ccc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccf:	89 cb                	mov    %ecx,%ebx
  800cd1:	89 cf                	mov    %ecx,%edi
  800cd3:	89 ce                	mov    %ecx,%esi
  800cd5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	7e 28                	jle    800d03 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ce6:	00 
  800ce7:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800cee:	00 
  800cef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf6:	00 
  800cf7:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800cfe:	e8 3e f4 ff ff       	call   800141 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d03:	83 c4 2c             	add    $0x2c,%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d11:	ba 00 00 00 00       	mov    $0x0,%edx
  800d16:	b8 02 00 00 00       	mov    $0x2,%eax
  800d1b:	89 d1                	mov    %edx,%ecx
  800d1d:	89 d3                	mov    %edx,%ebx
  800d1f:	89 d7                	mov    %edx,%edi
  800d21:	89 d6                	mov    %edx,%esi
  800d23:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_yield>:

void
sys_yield(void)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d30:	ba 00 00 00 00       	mov    $0x0,%edx
  800d35:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d3a:	89 d1                	mov    %edx,%ecx
  800d3c:	89 d3                	mov    %edx,%ebx
  800d3e:	89 d7                	mov    %edx,%edi
  800d40:	89 d6                	mov    %edx,%esi
  800d42:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
  800d4f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d52:	be 00 00 00 00       	mov    $0x0,%esi
  800d57:	b8 04 00 00 00       	mov    $0x4,%eax
  800d5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d65:	89 f7                	mov    %esi,%edi
  800d67:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 28                	jle    800d95 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d71:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d78:	00 
  800d79:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800d80:	00 
  800d81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d88:	00 
  800d89:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800d90:	e8 ac f3 ff ff       	call   800141 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d95:	83 c4 2c             	add    $0x2c,%esp
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800da6:	b8 05 00 00 00       	mov    $0x5,%eax
  800dab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db7:	8b 75 18             	mov    0x18(%ebp),%esi
  800dba:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	7e 28                	jle    800de8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dcb:	00 
  800dcc:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800dd3:	00 
  800dd4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddb:	00 
  800ddc:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800de3:	e8 59 f3 ff ff       	call   800141 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800de8:	83 c4 2c             	add    $0x2c,%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
  800df6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800df9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfe:	b8 06 00 00 00       	mov    $0x6,%eax
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	89 df                	mov    %ebx,%edi
  800e0b:	89 de                	mov    %ebx,%esi
  800e0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7e 28                	jle    800e3b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e17:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e1e:	00 
  800e1f:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800e26:	00 
  800e27:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2e:	00 
  800e2f:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800e36:	e8 06 f3 ff ff       	call   800141 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e3b:	83 c4 2c             	add    $0x2c,%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e51:	b8 08 00 00 00       	mov    $0x8,%eax
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	89 df                	mov    %ebx,%edi
  800e5e:	89 de                	mov    %ebx,%esi
  800e60:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e62:	85 c0                	test   %eax,%eax
  800e64:	7e 28                	jle    800e8e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e66:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e71:	00 
  800e72:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800e79:	00 
  800e7a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e81:	00 
  800e82:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800e89:	e8 b3 f2 ff ff       	call   800141 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e8e:	83 c4 2c             	add    $0x2c,%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	89 df                	mov    %ebx,%edi
  800eb1:	89 de                	mov    %ebx,%esi
  800eb3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	7e 28                	jle    800ee1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800ecc:	00 
  800ecd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed4:	00 
  800ed5:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800edc:	e8 60 f2 ff ff       	call   800141 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ee1:	83 c4 2c             	add    $0x2c,%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	57                   	push   %edi
  800eed:	56                   	push   %esi
  800eee:	53                   	push   %ebx
  800eef:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ef2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800efc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eff:	8b 55 08             	mov    0x8(%ebp),%edx
  800f02:	89 df                	mov    %ebx,%edi
  800f04:	89 de                	mov    %ebx,%esi
  800f06:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	7e 28                	jle    800f34 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f10:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f17:	00 
  800f18:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800f1f:	00 
  800f20:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f27:	00 
  800f28:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800f2f:	e8 0d f2 ff ff       	call   800141 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f34:	83 c4 2c             	add    $0x2c,%esp
  800f37:	5b                   	pop    %ebx
  800f38:	5e                   	pop    %esi
  800f39:	5f                   	pop    %edi
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	57                   	push   %edi
  800f40:	56                   	push   %esi
  800f41:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f42:	be 00 00 00 00       	mov    $0x0,%esi
  800f47:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f58:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f5a:	5b                   	pop    %ebx
  800f5b:	5e                   	pop    %esi
  800f5c:	5f                   	pop    %edi
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	57                   	push   %edi
  800f63:	56                   	push   %esi
  800f64:	53                   	push   %ebx
  800f65:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f68:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f6d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f72:	8b 55 08             	mov    0x8(%ebp),%edx
  800f75:	89 cb                	mov    %ecx,%ebx
  800f77:	89 cf                	mov    %ecx,%edi
  800f79:	89 ce                	mov    %ecx,%esi
  800f7b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	7e 28                	jle    800fa9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f81:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f85:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f8c:	00 
  800f8d:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800f94:	00 
  800f95:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9c:	00 
  800f9d:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800fa4:	e8 98 f1 ff ff       	call   800141 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fa9:	83 c4 2c             	add    $0x2c,%esp
  800fac:	5b                   	pop    %ebx
  800fad:	5e                   	pop    %esi
  800fae:	5f                   	pop    %edi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    

00800fb1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fb7:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800fbe:	75 70                	jne    801030 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  800fc0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fc7:	00 
  800fc8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800fcf:	ee 
  800fd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fd7:	e8 6d fd ff ff       	call   800d49 <sys_page_alloc>
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	79 1c                	jns    800ffc <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  800fe0:	c7 44 24 08 8c 25 80 	movl   $0x80258c,0x8(%esp)
  800fe7:	00 
  800fe8:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800fef:	00 
  800ff0:	c7 04 24 ef 25 80 00 	movl   $0x8025ef,(%esp)
  800ff7:	e8 45 f1 ff ff       	call   800141 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800ffc:	c7 44 24 04 3a 10 80 	movl   $0x80103a,0x4(%esp)
  801003:	00 
  801004:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80100b:	e8 d9 fe ff ff       	call   800ee9 <sys_env_set_pgfault_upcall>
  801010:	85 c0                	test   %eax,%eax
  801012:	79 1c                	jns    801030 <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  801014:	c7 44 24 08 b8 25 80 	movl   $0x8025b8,0x8(%esp)
  80101b:	00 
  80101c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801023:	00 
  801024:	c7 04 24 ef 25 80 00 	movl   $0x8025ef,(%esp)
  80102b:	e8 11 f1 ff ff       	call   800141 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801030:	8b 45 08             	mov    0x8(%ebp),%eax
  801033:	a3 08 40 80 00       	mov    %eax,0x804008
}
  801038:	c9                   	leave  
  801039:	c3                   	ret    

0080103a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80103a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80103b:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  801040:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801042:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  801045:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  801049:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  80104e:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  801052:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801054:	83 c4 08             	add    $0x8,%esp
	popal
  801057:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801058:	83 c4 04             	add    $0x4,%esp
	popfl
  80105b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80105c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80105d:	c3                   	ret    
  80105e:	66 90                	xchg   %ax,%ax

00801060 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801063:	8b 45 08             	mov    0x8(%ebp),%eax
  801066:	05 00 00 00 30       	add    $0x30000000,%eax
  80106b:	c1 e8 0c             	shr    $0xc,%eax
}
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801073:	8b 45 08             	mov    0x8(%ebp),%eax
  801076:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80107b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801080:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80108a:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80108f:	a8 01                	test   $0x1,%al
  801091:	74 34                	je     8010c7 <fd_alloc+0x40>
  801093:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801098:	a8 01                	test   $0x1,%al
  80109a:	74 32                	je     8010ce <fd_alloc+0x47>
  80109c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  8010a1:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010a3:	89 c2                	mov    %eax,%edx
  8010a5:	c1 ea 16             	shr    $0x16,%edx
  8010a8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010af:	f6 c2 01             	test   $0x1,%dl
  8010b2:	74 1f                	je     8010d3 <fd_alloc+0x4c>
  8010b4:	89 c2                	mov    %eax,%edx
  8010b6:	c1 ea 0c             	shr    $0xc,%edx
  8010b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c0:	f6 c2 01             	test   $0x1,%dl
  8010c3:	75 1a                	jne    8010df <fd_alloc+0x58>
  8010c5:	eb 0c                	jmp    8010d3 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  8010c7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8010cc:	eb 05                	jmp    8010d3 <fd_alloc+0x4c>
  8010ce:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  8010d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d6:	89 08                	mov    %ecx,(%eax)
			return 0;
  8010d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010dd:	eb 1a                	jmp    8010f9 <fd_alloc+0x72>
  8010df:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8010e4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010e9:	75 b6                	jne    8010a1 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8010f4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801101:	83 f8 1f             	cmp    $0x1f,%eax
  801104:	77 36                	ja     80113c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801106:	c1 e0 0c             	shl    $0xc,%eax
  801109:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80110e:	89 c2                	mov    %eax,%edx
  801110:	c1 ea 16             	shr    $0x16,%edx
  801113:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80111a:	f6 c2 01             	test   $0x1,%dl
  80111d:	74 24                	je     801143 <fd_lookup+0x48>
  80111f:	89 c2                	mov    %eax,%edx
  801121:	c1 ea 0c             	shr    $0xc,%edx
  801124:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80112b:	f6 c2 01             	test   $0x1,%dl
  80112e:	74 1a                	je     80114a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801130:	8b 55 0c             	mov    0xc(%ebp),%edx
  801133:	89 02                	mov    %eax,(%edx)
	return 0;
  801135:	b8 00 00 00 00       	mov    $0x0,%eax
  80113a:	eb 13                	jmp    80114f <fd_lookup+0x54>
		return -E_INVAL;
  80113c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801141:	eb 0c                	jmp    80114f <fd_lookup+0x54>
		return -E_INVAL;
  801143:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801148:	eb 05                	jmp    80114f <fd_lookup+0x54>
  80114a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	53                   	push   %ebx
  801155:	83 ec 14             	sub    $0x14,%esp
  801158:	8b 45 08             	mov    0x8(%ebp),%eax
  80115b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80115e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801164:	75 1e                	jne    801184 <dev_lookup+0x33>
  801166:	eb 0e                	jmp    801176 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  801168:	b8 20 30 80 00       	mov    $0x803020,%eax
  80116d:	eb 0c                	jmp    80117b <dev_lookup+0x2a>
  80116f:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801174:	eb 05                	jmp    80117b <dev_lookup+0x2a>
  801176:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  80117b:	89 03                	mov    %eax,(%ebx)
			return 0;
  80117d:	b8 00 00 00 00       	mov    $0x0,%eax
  801182:	eb 38                	jmp    8011bc <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  801184:	39 05 20 30 80 00    	cmp    %eax,0x803020
  80118a:	74 dc                	je     801168 <dev_lookup+0x17>
  80118c:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  801192:	74 db                	je     80116f <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801194:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80119a:	8b 52 48             	mov    0x48(%edx),%edx
  80119d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011a5:	c7 04 24 00 26 80 00 	movl   $0x802600,(%esp)
  8011ac:	e8 89 f0 ff ff       	call   80023a <cprintf>
	*dev = 0;
  8011b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8011b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011bc:	83 c4 14             	add    $0x14,%esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    

008011c2 <fd_close>:
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	56                   	push   %esi
  8011c6:	53                   	push   %ebx
  8011c7:	83 ec 20             	sub    $0x20,%esp
  8011ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8011cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d3:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011dd:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e0:	89 04 24             	mov    %eax,(%esp)
  8011e3:	e8 13 ff ff ff       	call   8010fb <fd_lookup>
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	78 05                	js     8011f1 <fd_close+0x2f>
	    || fd != fd2)
  8011ec:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011ef:	74 0c                	je     8011fd <fd_close+0x3b>
		return (must_exist ? r : 0);
  8011f1:	84 db                	test   %bl,%bl
  8011f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f8:	0f 44 c2             	cmove  %edx,%eax
  8011fb:	eb 3f                	jmp    80123c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801200:	89 44 24 04          	mov    %eax,0x4(%esp)
  801204:	8b 06                	mov    (%esi),%eax
  801206:	89 04 24             	mov    %eax,(%esp)
  801209:	e8 43 ff ff ff       	call   801151 <dev_lookup>
  80120e:	89 c3                	mov    %eax,%ebx
  801210:	85 c0                	test   %eax,%eax
  801212:	78 16                	js     80122a <fd_close+0x68>
		if (dev->dev_close)
  801214:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801217:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80121a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80121f:	85 c0                	test   %eax,%eax
  801221:	74 07                	je     80122a <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801223:	89 34 24             	mov    %esi,(%esp)
  801226:	ff d0                	call   *%eax
  801228:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  80122a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80122e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801235:	e8 b6 fb ff ff       	call   800df0 <sys_page_unmap>
	return r;
  80123a:	89 d8                	mov    %ebx,%eax
}
  80123c:	83 c4 20             	add    $0x20,%esp
  80123f:	5b                   	pop    %ebx
  801240:	5e                   	pop    %esi
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <close>:

int
close(int fdnum)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801249:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801250:	8b 45 08             	mov    0x8(%ebp),%eax
  801253:	89 04 24             	mov    %eax,(%esp)
  801256:	e8 a0 fe ff ff       	call   8010fb <fd_lookup>
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	85 d2                	test   %edx,%edx
  80125f:	78 13                	js     801274 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801261:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801268:	00 
  801269:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80126c:	89 04 24             	mov    %eax,(%esp)
  80126f:	e8 4e ff ff ff       	call   8011c2 <fd_close>
}
  801274:	c9                   	leave  
  801275:	c3                   	ret    

00801276 <close_all>:

void
close_all(void)
{
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	53                   	push   %ebx
  80127a:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80127d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801282:	89 1c 24             	mov    %ebx,(%esp)
  801285:	e8 b9 ff ff ff       	call   801243 <close>
	for (i = 0; i < MAXFD; i++)
  80128a:	83 c3 01             	add    $0x1,%ebx
  80128d:	83 fb 20             	cmp    $0x20,%ebx
  801290:	75 f0                	jne    801282 <close_all+0xc>
}
  801292:	83 c4 14             	add    $0x14,%esp
  801295:	5b                   	pop    %ebx
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	57                   	push   %edi
  80129c:	56                   	push   %esi
  80129d:	53                   	push   %ebx
  80129e:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ab:	89 04 24             	mov    %eax,(%esp)
  8012ae:	e8 48 fe ff ff       	call   8010fb <fd_lookup>
  8012b3:	89 c2                	mov    %eax,%edx
  8012b5:	85 d2                	test   %edx,%edx
  8012b7:	0f 88 e1 00 00 00    	js     80139e <dup+0x106>
		return r;
	close(newfdnum);
  8012bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c0:	89 04 24             	mov    %eax,(%esp)
  8012c3:	e8 7b ff ff ff       	call   801243 <close>

	newfd = INDEX2FD(newfdnum);
  8012c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012cb:	c1 e3 0c             	shl    $0xc,%ebx
  8012ce:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012d7:	89 04 24             	mov    %eax,(%esp)
  8012da:	e8 91 fd ff ff       	call   801070 <fd2data>
  8012df:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8012e1:	89 1c 24             	mov    %ebx,(%esp)
  8012e4:	e8 87 fd ff ff       	call   801070 <fd2data>
  8012e9:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012eb:	89 f0                	mov    %esi,%eax
  8012ed:	c1 e8 16             	shr    $0x16,%eax
  8012f0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012f7:	a8 01                	test   $0x1,%al
  8012f9:	74 43                	je     80133e <dup+0xa6>
  8012fb:	89 f0                	mov    %esi,%eax
  8012fd:	c1 e8 0c             	shr    $0xc,%eax
  801300:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801307:	f6 c2 01             	test   $0x1,%dl
  80130a:	74 32                	je     80133e <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80130c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801313:	25 07 0e 00 00       	and    $0xe07,%eax
  801318:	89 44 24 10          	mov    %eax,0x10(%esp)
  80131c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801320:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801327:	00 
  801328:	89 74 24 04          	mov    %esi,0x4(%esp)
  80132c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801333:	e8 65 fa ff ff       	call   800d9d <sys_page_map>
  801338:	89 c6                	mov    %eax,%esi
  80133a:	85 c0                	test   %eax,%eax
  80133c:	78 3e                	js     80137c <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80133e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801341:	89 c2                	mov    %eax,%edx
  801343:	c1 ea 0c             	shr    $0xc,%edx
  801346:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80134d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801353:	89 54 24 10          	mov    %edx,0x10(%esp)
  801357:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80135b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801362:	00 
  801363:	89 44 24 04          	mov    %eax,0x4(%esp)
  801367:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80136e:	e8 2a fa ff ff       	call   800d9d <sys_page_map>
  801373:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801375:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801378:	85 f6                	test   %esi,%esi
  80137a:	79 22                	jns    80139e <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80137c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801380:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801387:	e8 64 fa ff ff       	call   800df0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80138c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801390:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801397:	e8 54 fa ff ff       	call   800df0 <sys_page_unmap>
	return r;
  80139c:	89 f0                	mov    %esi,%eax
}
  80139e:	83 c4 3c             	add    $0x3c,%esp
  8013a1:	5b                   	pop    %ebx
  8013a2:	5e                   	pop    %esi
  8013a3:	5f                   	pop    %edi
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	53                   	push   %ebx
  8013aa:	83 ec 24             	sub    $0x24,%esp
  8013ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b7:	89 1c 24             	mov    %ebx,(%esp)
  8013ba:	e8 3c fd ff ff       	call   8010fb <fd_lookup>
  8013bf:	89 c2                	mov    %eax,%edx
  8013c1:	85 d2                	test   %edx,%edx
  8013c3:	78 6d                	js     801432 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cf:	8b 00                	mov    (%eax),%eax
  8013d1:	89 04 24             	mov    %eax,(%esp)
  8013d4:	e8 78 fd ff ff       	call   801151 <dev_lookup>
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 55                	js     801432 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e0:	8b 50 08             	mov    0x8(%eax),%edx
  8013e3:	83 e2 03             	and    $0x3,%edx
  8013e6:	83 fa 01             	cmp    $0x1,%edx
  8013e9:	75 23                	jne    80140e <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8013f0:	8b 40 48             	mov    0x48(%eax),%eax
  8013f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fb:	c7 04 24 44 26 80 00 	movl   $0x802644,(%esp)
  801402:	e8 33 ee ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  801407:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140c:	eb 24                	jmp    801432 <read+0x8c>
	}
	if (!dev->dev_read)
  80140e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801411:	8b 52 08             	mov    0x8(%edx),%edx
  801414:	85 d2                	test   %edx,%edx
  801416:	74 15                	je     80142d <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80141b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80141f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801422:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801426:	89 04 24             	mov    %eax,(%esp)
  801429:	ff d2                	call   *%edx
  80142b:	eb 05                	jmp    801432 <read+0x8c>
		return -E_NOT_SUPP;
  80142d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801432:	83 c4 24             	add    $0x24,%esp
  801435:	5b                   	pop    %ebx
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    

00801438 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	57                   	push   %edi
  80143c:	56                   	push   %esi
  80143d:	53                   	push   %ebx
  80143e:	83 ec 1c             	sub    $0x1c,%esp
  801441:	8b 7d 08             	mov    0x8(%ebp),%edi
  801444:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801447:	85 f6                	test   %esi,%esi
  801449:	74 33                	je     80147e <readn+0x46>
  80144b:	b8 00 00 00 00       	mov    $0x0,%eax
  801450:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801455:	89 f2                	mov    %esi,%edx
  801457:	29 c2                	sub    %eax,%edx
  801459:	89 54 24 08          	mov    %edx,0x8(%esp)
  80145d:	03 45 0c             	add    0xc(%ebp),%eax
  801460:	89 44 24 04          	mov    %eax,0x4(%esp)
  801464:	89 3c 24             	mov    %edi,(%esp)
  801467:	e8 3a ff ff ff       	call   8013a6 <read>
		if (m < 0)
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 1b                	js     80148b <readn+0x53>
			return m;
		if (m == 0)
  801470:	85 c0                	test   %eax,%eax
  801472:	74 11                	je     801485 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  801474:	01 c3                	add    %eax,%ebx
  801476:	89 d8                	mov    %ebx,%eax
  801478:	39 f3                	cmp    %esi,%ebx
  80147a:	72 d9                	jb     801455 <readn+0x1d>
  80147c:	eb 0b                	jmp    801489 <readn+0x51>
  80147e:	b8 00 00 00 00       	mov    $0x0,%eax
  801483:	eb 06                	jmp    80148b <readn+0x53>
  801485:	89 d8                	mov    %ebx,%eax
  801487:	eb 02                	jmp    80148b <readn+0x53>
  801489:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80148b:	83 c4 1c             	add    $0x1c,%esp
  80148e:	5b                   	pop    %ebx
  80148f:	5e                   	pop    %esi
  801490:	5f                   	pop    %edi
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    

00801493 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	53                   	push   %ebx
  801497:	83 ec 24             	sub    $0x24,%esp
  80149a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a4:	89 1c 24             	mov    %ebx,(%esp)
  8014a7:	e8 4f fc ff ff       	call   8010fb <fd_lookup>
  8014ac:	89 c2                	mov    %eax,%edx
  8014ae:	85 d2                	test   %edx,%edx
  8014b0:	78 68                	js     80151a <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bc:	8b 00                	mov    (%eax),%eax
  8014be:	89 04 24             	mov    %eax,(%esp)
  8014c1:	e8 8b fc ff ff       	call   801151 <dev_lookup>
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	78 50                	js     80151a <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014d1:	75 23                	jne    8014f6 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d3:	a1 04 40 80 00       	mov    0x804004,%eax
  8014d8:	8b 40 48             	mov    0x48(%eax),%eax
  8014db:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e3:	c7 04 24 60 26 80 00 	movl   $0x802660,(%esp)
  8014ea:	e8 4b ed ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  8014ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f4:	eb 24                	jmp    80151a <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f9:	8b 52 0c             	mov    0xc(%edx),%edx
  8014fc:	85 d2                	test   %edx,%edx
  8014fe:	74 15                	je     801515 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801500:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801503:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801507:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80150a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80150e:	89 04 24             	mov    %eax,(%esp)
  801511:	ff d2                	call   *%edx
  801513:	eb 05                	jmp    80151a <write+0x87>
		return -E_NOT_SUPP;
  801515:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80151a:	83 c4 24             	add    $0x24,%esp
  80151d:	5b                   	pop    %ebx
  80151e:	5d                   	pop    %ebp
  80151f:	c3                   	ret    

00801520 <seek>:

int
seek(int fdnum, off_t offset)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801526:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152d:	8b 45 08             	mov    0x8(%ebp),%eax
  801530:	89 04 24             	mov    %eax,(%esp)
  801533:	e8 c3 fb ff ff       	call   8010fb <fd_lookup>
  801538:	85 c0                	test   %eax,%eax
  80153a:	78 0e                	js     80154a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80153c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80153f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801542:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801545:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80154a:	c9                   	leave  
  80154b:	c3                   	ret    

0080154c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	53                   	push   %ebx
  801550:	83 ec 24             	sub    $0x24,%esp
  801553:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801556:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155d:	89 1c 24             	mov    %ebx,(%esp)
  801560:	e8 96 fb ff ff       	call   8010fb <fd_lookup>
  801565:	89 c2                	mov    %eax,%edx
  801567:	85 d2                	test   %edx,%edx
  801569:	78 61                	js     8015cc <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801572:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801575:	8b 00                	mov    (%eax),%eax
  801577:	89 04 24             	mov    %eax,(%esp)
  80157a:	e8 d2 fb ff ff       	call   801151 <dev_lookup>
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 49                	js     8015cc <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801583:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801586:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80158a:	75 23                	jne    8015af <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80158c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801591:	8b 40 48             	mov    0x48(%eax),%eax
  801594:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801598:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159c:	c7 04 24 20 26 80 00 	movl   $0x802620,(%esp)
  8015a3:	e8 92 ec ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  8015a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ad:	eb 1d                	jmp    8015cc <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8015af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b2:	8b 52 18             	mov    0x18(%edx),%edx
  8015b5:	85 d2                	test   %edx,%edx
  8015b7:	74 0e                	je     8015c7 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015c0:	89 04 24             	mov    %eax,(%esp)
  8015c3:	ff d2                	call   *%edx
  8015c5:	eb 05                	jmp    8015cc <ftruncate+0x80>
		return -E_NOT_SUPP;
  8015c7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8015cc:	83 c4 24             	add    $0x24,%esp
  8015cf:	5b                   	pop    %ebx
  8015d0:	5d                   	pop    %ebp
  8015d1:	c3                   	ret    

008015d2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	53                   	push   %ebx
  8015d6:	83 ec 24             	sub    $0x24,%esp
  8015d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e6:	89 04 24             	mov    %eax,(%esp)
  8015e9:	e8 0d fb ff ff       	call   8010fb <fd_lookup>
  8015ee:	89 c2                	mov    %eax,%edx
  8015f0:	85 d2                	test   %edx,%edx
  8015f2:	78 52                	js     801646 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fe:	8b 00                	mov    (%eax),%eax
  801600:	89 04 24             	mov    %eax,(%esp)
  801603:	e8 49 fb ff ff       	call   801151 <dev_lookup>
  801608:	85 c0                	test   %eax,%eax
  80160a:	78 3a                	js     801646 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80160c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801613:	74 2c                	je     801641 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801615:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801618:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80161f:	00 00 00 
	stat->st_isdir = 0;
  801622:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801629:	00 00 00 
	stat->st_dev = dev;
  80162c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801632:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801636:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801639:	89 14 24             	mov    %edx,(%esp)
  80163c:	ff 50 14             	call   *0x14(%eax)
  80163f:	eb 05                	jmp    801646 <fstat+0x74>
		return -E_NOT_SUPP;
  801641:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801646:	83 c4 24             	add    $0x24,%esp
  801649:	5b                   	pop    %ebx
  80164a:	5d                   	pop    %ebp
  80164b:	c3                   	ret    

0080164c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	56                   	push   %esi
  801650:	53                   	push   %ebx
  801651:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801654:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80165b:	00 
  80165c:	8b 45 08             	mov    0x8(%ebp),%eax
  80165f:	89 04 24             	mov    %eax,(%esp)
  801662:	e8 af 01 00 00       	call   801816 <open>
  801667:	89 c3                	mov    %eax,%ebx
  801669:	85 db                	test   %ebx,%ebx
  80166b:	78 1b                	js     801688 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80166d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801670:	89 44 24 04          	mov    %eax,0x4(%esp)
  801674:	89 1c 24             	mov    %ebx,(%esp)
  801677:	e8 56 ff ff ff       	call   8015d2 <fstat>
  80167c:	89 c6                	mov    %eax,%esi
	close(fd);
  80167e:	89 1c 24             	mov    %ebx,(%esp)
  801681:	e8 bd fb ff ff       	call   801243 <close>
	return r;
  801686:	89 f0                	mov    %esi,%eax
}
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	5b                   	pop    %ebx
  80168c:	5e                   	pop    %esi
  80168d:	5d                   	pop    %ebp
  80168e:	c3                   	ret    

0080168f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	56                   	push   %esi
  801693:	53                   	push   %ebx
  801694:	83 ec 10             	sub    $0x10,%esp
  801697:	89 c6                	mov    %eax,%esi
  801699:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80169b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016a2:	75 11                	jne    8016b5 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8016ab:	e8 fa 07 00 00       	call   801eaa <ipc_find_env>
  8016b0:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016b5:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8016bc:	00 
  8016bd:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8016c4:	00 
  8016c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016c9:	a1 00 40 80 00       	mov    0x804000,%eax
  8016ce:	89 04 24             	mov    %eax,(%esp)
  8016d1:	e8 8c 07 00 00       	call   801e62 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016dd:	00 
  8016de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e9:	e8 18 07 00 00       	call   801e06 <ipc_recv>
}
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	5b                   	pop    %ebx
  8016f2:	5e                   	pop    %esi
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    

008016f5 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	53                   	push   %ebx
  8016f9:	83 ec 14             	sub    $0x14,%esp
  8016fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801702:	8b 40 0c             	mov    0xc(%eax),%eax
  801705:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80170a:	ba 00 00 00 00       	mov    $0x0,%edx
  80170f:	b8 05 00 00 00       	mov    $0x5,%eax
  801714:	e8 76 ff ff ff       	call   80168f <fsipc>
  801719:	89 c2                	mov    %eax,%edx
  80171b:	85 d2                	test   %edx,%edx
  80171d:	78 2b                	js     80174a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80171f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801726:	00 
  801727:	89 1c 24             	mov    %ebx,(%esp)
  80172a:	e8 6c f1 ff ff       	call   80089b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80172f:	a1 80 50 80 00       	mov    0x805080,%eax
  801734:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80173a:	a1 84 50 80 00       	mov    0x805084,%eax
  80173f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801745:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80174a:	83 c4 14             	add    $0x14,%esp
  80174d:	5b                   	pop    %ebx
  80174e:	5d                   	pop    %ebp
  80174f:	c3                   	ret    

00801750 <devfile_flush>:
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801756:	8b 45 08             	mov    0x8(%ebp),%eax
  801759:	8b 40 0c             	mov    0xc(%eax),%eax
  80175c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801761:	ba 00 00 00 00       	mov    $0x0,%edx
  801766:	b8 06 00 00 00       	mov    $0x6,%eax
  80176b:	e8 1f ff ff ff       	call   80168f <fsipc>
}
  801770:	c9                   	leave  
  801771:	c3                   	ret    

00801772 <devfile_read>:
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	56                   	push   %esi
  801776:	53                   	push   %ebx
  801777:	83 ec 10             	sub    $0x10,%esp
  80177a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80177d:	8b 45 08             	mov    0x8(%ebp),%eax
  801780:	8b 40 0c             	mov    0xc(%eax),%eax
  801783:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801788:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80178e:	ba 00 00 00 00       	mov    $0x0,%edx
  801793:	b8 03 00 00 00       	mov    $0x3,%eax
  801798:	e8 f2 fe ff ff       	call   80168f <fsipc>
  80179d:	89 c3                	mov    %eax,%ebx
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 6a                	js     80180d <devfile_read+0x9b>
	assert(r <= n);
  8017a3:	39 c6                	cmp    %eax,%esi
  8017a5:	73 24                	jae    8017cb <devfile_read+0x59>
  8017a7:	c7 44 24 0c 7d 26 80 	movl   $0x80267d,0xc(%esp)
  8017ae:	00 
  8017af:	c7 44 24 08 84 26 80 	movl   $0x802684,0x8(%esp)
  8017b6:	00 
  8017b7:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  8017be:	00 
  8017bf:	c7 04 24 99 26 80 00 	movl   $0x802699,(%esp)
  8017c6:	e8 76 e9 ff ff       	call   800141 <_panic>
	assert(r <= PGSIZE);
  8017cb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017d0:	7e 24                	jle    8017f6 <devfile_read+0x84>
  8017d2:	c7 44 24 0c a4 26 80 	movl   $0x8026a4,0xc(%esp)
  8017d9:	00 
  8017da:	c7 44 24 08 84 26 80 	movl   $0x802684,0x8(%esp)
  8017e1:	00 
  8017e2:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  8017e9:	00 
  8017ea:	c7 04 24 99 26 80 00 	movl   $0x802699,(%esp)
  8017f1:	e8 4b e9 ff ff       	call   800141 <_panic>
	memmove(buf, &fsipcbuf, r);
  8017f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017fa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801801:	00 
  801802:	8b 45 0c             	mov    0xc(%ebp),%eax
  801805:	89 04 24             	mov    %eax,(%esp)
  801808:	e8 89 f2 ff ff       	call   800a96 <memmove>
}
  80180d:	89 d8                	mov    %ebx,%eax
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	5b                   	pop    %ebx
  801813:	5e                   	pop    %esi
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <open>:
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	53                   	push   %ebx
  80181a:	83 ec 24             	sub    $0x24,%esp
  80181d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801820:	89 1c 24             	mov    %ebx,(%esp)
  801823:	e8 18 f0 ff ff       	call   800840 <strlen>
  801828:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80182d:	7f 60                	jg     80188f <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80182f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801832:	89 04 24             	mov    %eax,(%esp)
  801835:	e8 4d f8 ff ff       	call   801087 <fd_alloc>
  80183a:	89 c2                	mov    %eax,%edx
  80183c:	85 d2                	test   %edx,%edx
  80183e:	78 54                	js     801894 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801840:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801844:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80184b:	e8 4b f0 ff ff       	call   80089b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801850:	8b 45 0c             	mov    0xc(%ebp),%eax
  801853:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801858:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185b:	b8 01 00 00 00       	mov    $0x1,%eax
  801860:	e8 2a fe ff ff       	call   80168f <fsipc>
  801865:	89 c3                	mov    %eax,%ebx
  801867:	85 c0                	test   %eax,%eax
  801869:	79 17                	jns    801882 <open+0x6c>
		fd_close(fd, 0);
  80186b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801872:	00 
  801873:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801876:	89 04 24             	mov    %eax,(%esp)
  801879:	e8 44 f9 ff ff       	call   8011c2 <fd_close>
		return r;
  80187e:	89 d8                	mov    %ebx,%eax
  801880:	eb 12                	jmp    801894 <open+0x7e>
	return fd2num(fd);
  801882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801885:	89 04 24             	mov    %eax,(%esp)
  801888:	e8 d3 f7 ff ff       	call   801060 <fd2num>
  80188d:	eb 05                	jmp    801894 <open+0x7e>
		return -E_BAD_PATH;
  80188f:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801894:	83 c4 24             	add    $0x24,%esp
  801897:	5b                   	pop    %ebx
  801898:	5d                   	pop    %ebp
  801899:	c3                   	ret    
  80189a:	66 90                	xchg   %ax,%ax
  80189c:	66 90                	xchg   %ax,%ax
  80189e:	66 90                	xchg   %ax,%ax

008018a0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	56                   	push   %esi
  8018a4:	53                   	push   %ebx
  8018a5:	83 ec 10             	sub    $0x10,%esp
  8018a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ae:	89 04 24             	mov    %eax,(%esp)
  8018b1:	e8 ba f7 ff ff       	call   801070 <fd2data>
  8018b6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018b8:	c7 44 24 04 b0 26 80 	movl   $0x8026b0,0x4(%esp)
  8018bf:	00 
  8018c0:	89 1c 24             	mov    %ebx,(%esp)
  8018c3:	e8 d3 ef ff ff       	call   80089b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018c8:	8b 46 04             	mov    0x4(%esi),%eax
  8018cb:	2b 06                	sub    (%esi),%eax
  8018cd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018d3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018da:	00 00 00 
	stat->st_dev = &devpipe;
  8018dd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018e4:	30 80 00 
	return 0;
}
  8018e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	5b                   	pop    %ebx
  8018f0:	5e                   	pop    %esi
  8018f1:	5d                   	pop    %ebp
  8018f2:	c3                   	ret    

008018f3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	53                   	push   %ebx
  8018f7:	83 ec 14             	sub    $0x14,%esp
  8018fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801901:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801908:	e8 e3 f4 ff ff       	call   800df0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80190d:	89 1c 24             	mov    %ebx,(%esp)
  801910:	e8 5b f7 ff ff       	call   801070 <fd2data>
  801915:	89 44 24 04          	mov    %eax,0x4(%esp)
  801919:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801920:	e8 cb f4 ff ff       	call   800df0 <sys_page_unmap>
}
  801925:	83 c4 14             	add    $0x14,%esp
  801928:	5b                   	pop    %ebx
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <_pipeisclosed>:
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	57                   	push   %edi
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
  801931:	83 ec 2c             	sub    $0x2c,%esp
  801934:	89 c6                	mov    %eax,%esi
  801936:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801939:	a1 04 40 80 00       	mov    0x804004,%eax
  80193e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801941:	89 34 24             	mov    %esi,(%esp)
  801944:	e8 a9 05 00 00       	call   801ef2 <pageref>
  801949:	89 c7                	mov    %eax,%edi
  80194b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80194e:	89 04 24             	mov    %eax,(%esp)
  801951:	e8 9c 05 00 00       	call   801ef2 <pageref>
  801956:	39 c7                	cmp    %eax,%edi
  801958:	0f 94 c2             	sete   %dl
  80195b:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80195e:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801964:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801967:	39 fb                	cmp    %edi,%ebx
  801969:	74 21                	je     80198c <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  80196b:	84 d2                	test   %dl,%dl
  80196d:	74 ca                	je     801939 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80196f:	8b 51 58             	mov    0x58(%ecx),%edx
  801972:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801976:	89 54 24 08          	mov    %edx,0x8(%esp)
  80197a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80197e:	c7 04 24 b7 26 80 00 	movl   $0x8026b7,(%esp)
  801985:	e8 b0 e8 ff ff       	call   80023a <cprintf>
  80198a:	eb ad                	jmp    801939 <_pipeisclosed+0xe>
}
  80198c:	83 c4 2c             	add    $0x2c,%esp
  80198f:	5b                   	pop    %ebx
  801990:	5e                   	pop    %esi
  801991:	5f                   	pop    %edi
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    

00801994 <devpipe_write>:
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	57                   	push   %edi
  801998:	56                   	push   %esi
  801999:	53                   	push   %ebx
  80199a:	83 ec 1c             	sub    $0x1c,%esp
  80199d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8019a0:	89 34 24             	mov    %esi,(%esp)
  8019a3:	e8 c8 f6 ff ff       	call   801070 <fd2data>
	for (i = 0; i < n; i++) {
  8019a8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019ac:	74 61                	je     801a0f <devpipe_write+0x7b>
  8019ae:	89 c3                	mov    %eax,%ebx
  8019b0:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b5:	eb 4a                	jmp    801a01 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  8019b7:	89 da                	mov    %ebx,%edx
  8019b9:	89 f0                	mov    %esi,%eax
  8019bb:	e8 6b ff ff ff       	call   80192b <_pipeisclosed>
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	75 54                	jne    801a18 <devpipe_write+0x84>
			sys_yield();
  8019c4:	e8 61 f3 ff ff       	call   800d2a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019c9:	8b 43 04             	mov    0x4(%ebx),%eax
  8019cc:	8b 0b                	mov    (%ebx),%ecx
  8019ce:	8d 51 20             	lea    0x20(%ecx),%edx
  8019d1:	39 d0                	cmp    %edx,%eax
  8019d3:	73 e2                	jae    8019b7 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019d8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019dc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019df:	99                   	cltd   
  8019e0:	c1 ea 1b             	shr    $0x1b,%edx
  8019e3:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8019e6:	83 e1 1f             	and    $0x1f,%ecx
  8019e9:	29 d1                	sub    %edx,%ecx
  8019eb:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8019ef:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8019f3:	83 c0 01             	add    $0x1,%eax
  8019f6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8019f9:	83 c7 01             	add    $0x1,%edi
  8019fc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019ff:	74 13                	je     801a14 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a01:	8b 43 04             	mov    0x4(%ebx),%eax
  801a04:	8b 0b                	mov    (%ebx),%ecx
  801a06:	8d 51 20             	lea    0x20(%ecx),%edx
  801a09:	39 d0                	cmp    %edx,%eax
  801a0b:	73 aa                	jae    8019b7 <devpipe_write+0x23>
  801a0d:	eb c6                	jmp    8019d5 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  801a0f:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  801a14:	89 f8                	mov    %edi,%eax
  801a16:	eb 05                	jmp    801a1d <devpipe_write+0x89>
				return 0;
  801a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a1d:	83 c4 1c             	add    $0x1c,%esp
  801a20:	5b                   	pop    %ebx
  801a21:	5e                   	pop    %esi
  801a22:	5f                   	pop    %edi
  801a23:	5d                   	pop    %ebp
  801a24:	c3                   	ret    

00801a25 <devpipe_read>:
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	57                   	push   %edi
  801a29:	56                   	push   %esi
  801a2a:	53                   	push   %ebx
  801a2b:	83 ec 1c             	sub    $0x1c,%esp
  801a2e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a31:	89 3c 24             	mov    %edi,(%esp)
  801a34:	e8 37 f6 ff ff       	call   801070 <fd2data>
	for (i = 0; i < n; i++) {
  801a39:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a3d:	74 54                	je     801a93 <devpipe_read+0x6e>
  801a3f:	89 c3                	mov    %eax,%ebx
  801a41:	be 00 00 00 00       	mov    $0x0,%esi
  801a46:	eb 3e                	jmp    801a86 <devpipe_read+0x61>
				return i;
  801a48:	89 f0                	mov    %esi,%eax
  801a4a:	eb 55                	jmp    801aa1 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  801a4c:	89 da                	mov    %ebx,%edx
  801a4e:	89 f8                	mov    %edi,%eax
  801a50:	e8 d6 fe ff ff       	call   80192b <_pipeisclosed>
  801a55:	85 c0                	test   %eax,%eax
  801a57:	75 43                	jne    801a9c <devpipe_read+0x77>
			sys_yield();
  801a59:	e8 cc f2 ff ff       	call   800d2a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801a5e:	8b 03                	mov    (%ebx),%eax
  801a60:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a63:	74 e7                	je     801a4c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a65:	99                   	cltd   
  801a66:	c1 ea 1b             	shr    $0x1b,%edx
  801a69:	01 d0                	add    %edx,%eax
  801a6b:	83 e0 1f             	and    $0x1f,%eax
  801a6e:	29 d0                	sub    %edx,%eax
  801a70:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a78:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a7b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801a7e:	83 c6 01             	add    $0x1,%esi
  801a81:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a84:	74 12                	je     801a98 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  801a86:	8b 03                	mov    (%ebx),%eax
  801a88:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a8b:	75 d8                	jne    801a65 <devpipe_read+0x40>
			if (i > 0)
  801a8d:	85 f6                	test   %esi,%esi
  801a8f:	75 b7                	jne    801a48 <devpipe_read+0x23>
  801a91:	eb b9                	jmp    801a4c <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  801a93:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  801a98:	89 f0                	mov    %esi,%eax
  801a9a:	eb 05                	jmp    801aa1 <devpipe_read+0x7c>
				return 0;
  801a9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa1:	83 c4 1c             	add    $0x1c,%esp
  801aa4:	5b                   	pop    %ebx
  801aa5:	5e                   	pop    %esi
  801aa6:	5f                   	pop    %edi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <pipe>:
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	56                   	push   %esi
  801aad:	53                   	push   %ebx
  801aae:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ab1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab4:	89 04 24             	mov    %eax,(%esp)
  801ab7:	e8 cb f5 ff ff       	call   801087 <fd_alloc>
  801abc:	89 c2                	mov    %eax,%edx
  801abe:	85 d2                	test   %edx,%edx
  801ac0:	0f 88 4d 01 00 00    	js     801c13 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801acd:	00 
  801ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801adc:	e8 68 f2 ff ff       	call   800d49 <sys_page_alloc>
  801ae1:	89 c2                	mov    %eax,%edx
  801ae3:	85 d2                	test   %edx,%edx
  801ae5:	0f 88 28 01 00 00    	js     801c13 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801aeb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aee:	89 04 24             	mov    %eax,(%esp)
  801af1:	e8 91 f5 ff ff       	call   801087 <fd_alloc>
  801af6:	89 c3                	mov    %eax,%ebx
  801af8:	85 c0                	test   %eax,%eax
  801afa:	0f 88 fe 00 00 00    	js     801bfe <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b00:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b07:	00 
  801b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b16:	e8 2e f2 ff ff       	call   800d49 <sys_page_alloc>
  801b1b:	89 c3                	mov    %eax,%ebx
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	0f 88 d9 00 00 00    	js     801bfe <pipe+0x155>
	va = fd2data(fd0);
  801b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b28:	89 04 24             	mov    %eax,(%esp)
  801b2b:	e8 40 f5 ff ff       	call   801070 <fd2data>
  801b30:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b32:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b39:	00 
  801b3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b45:	e8 ff f1 ff ff       	call   800d49 <sys_page_alloc>
  801b4a:	89 c3                	mov    %eax,%ebx
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	0f 88 97 00 00 00    	js     801beb <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b57:	89 04 24             	mov    %eax,(%esp)
  801b5a:	e8 11 f5 ff ff       	call   801070 <fd2data>
  801b5f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b66:	00 
  801b67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b6b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b72:	00 
  801b73:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b7e:	e8 1a f2 ff ff       	call   800d9d <sys_page_map>
  801b83:	89 c3                	mov    %eax,%ebx
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 52                	js     801bdb <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801b89:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b92:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b97:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801b9e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ba4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ba9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bac:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb6:	89 04 24             	mov    %eax,(%esp)
  801bb9:	e8 a2 f4 ff ff       	call   801060 <fd2num>
  801bbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bc6:	89 04 24             	mov    %eax,(%esp)
  801bc9:	e8 92 f4 ff ff       	call   801060 <fd2num>
  801bce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd9:	eb 38                	jmp    801c13 <pipe+0x16a>
	sys_page_unmap(0, va);
  801bdb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be6:	e8 05 f2 ff ff       	call   800df0 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf9:	e8 f2 f1 ff ff       	call   800df0 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c0c:	e8 df f1 ff ff       	call   800df0 <sys_page_unmap>
  801c11:	89 d8                	mov    %ebx,%eax
}
  801c13:	83 c4 30             	add    $0x30,%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    

00801c1a <pipeisclosed>:
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c27:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2a:	89 04 24             	mov    %eax,(%esp)
  801c2d:	e8 c9 f4 ff ff       	call   8010fb <fd_lookup>
  801c32:	89 c2                	mov    %eax,%edx
  801c34:	85 d2                	test   %edx,%edx
  801c36:	78 15                	js     801c4d <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3b:	89 04 24             	mov    %eax,(%esp)
  801c3e:	e8 2d f4 ff ff       	call   801070 <fd2data>
	return _pipeisclosed(fd, p);
  801c43:	89 c2                	mov    %eax,%edx
  801c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c48:	e8 de fc ff ff       	call   80192b <_pipeisclosed>
}
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    
  801c4f:	90                   	nop

00801c50 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c53:	b8 00 00 00 00       	mov    $0x0,%eax
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    

00801c5a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801c60:	c7 44 24 04 cf 26 80 	movl   $0x8026cf,0x4(%esp)
  801c67:	00 
  801c68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c6b:	89 04 24             	mov    %eax,(%esp)
  801c6e:	e8 28 ec ff ff       	call   80089b <strcpy>
	return 0;
}
  801c73:	b8 00 00 00 00       	mov    $0x0,%eax
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    

00801c7a <devcons_write>:
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	57                   	push   %edi
  801c7e:	56                   	push   %esi
  801c7f:	53                   	push   %ebx
  801c80:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c8a:	74 4a                	je     801cd6 <devcons_write+0x5c>
  801c8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c91:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c96:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  801c9c:	8b 75 10             	mov    0x10(%ebp),%esi
  801c9f:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  801ca1:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801ca4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ca9:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801cac:	89 74 24 08          	mov    %esi,0x8(%esp)
  801cb0:	03 45 0c             	add    0xc(%ebp),%eax
  801cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb7:	89 3c 24             	mov    %edi,(%esp)
  801cba:	e8 d7 ed ff ff       	call   800a96 <memmove>
		sys_cputs(buf, m);
  801cbf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cc3:	89 3c 24             	mov    %edi,(%esp)
  801cc6:	e8 b1 ef ff ff       	call   800c7c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ccb:	01 f3                	add    %esi,%ebx
  801ccd:	89 d8                	mov    %ebx,%eax
  801ccf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cd2:	72 c8                	jb     801c9c <devcons_write+0x22>
  801cd4:	eb 05                	jmp    801cdb <devcons_write+0x61>
  801cd6:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  801cdb:	89 d8                	mov    %ebx,%eax
  801cdd:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801ce3:	5b                   	pop    %ebx
  801ce4:	5e                   	pop    %esi
  801ce5:	5f                   	pop    %edi
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    

00801ce8 <devcons_read>:
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801cee:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801cf3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cf7:	75 07                	jne    801d00 <devcons_read+0x18>
  801cf9:	eb 28                	jmp    801d23 <devcons_read+0x3b>
		sys_yield();
  801cfb:	e8 2a f0 ff ff       	call   800d2a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801d00:	e8 95 ef ff ff       	call   800c9a <sys_cgetc>
  801d05:	85 c0                	test   %eax,%eax
  801d07:	74 f2                	je     801cfb <devcons_read+0x13>
	if (c < 0)
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	78 16                	js     801d23 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  801d0d:	83 f8 04             	cmp    $0x4,%eax
  801d10:	74 0c                	je     801d1e <devcons_read+0x36>
	*(char*)vbuf = c;
  801d12:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d15:	88 02                	mov    %al,(%edx)
	return 1;
  801d17:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1c:	eb 05                	jmp    801d23 <devcons_read+0x3b>
		return 0;
  801d1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    

00801d25 <cputchar>:
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d31:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d38:	00 
  801d39:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d3c:	89 04 24             	mov    %eax,(%esp)
  801d3f:	e8 38 ef ff ff       	call   800c7c <sys_cputs>
}
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <getchar>:
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801d4c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801d53:	00 
  801d54:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d62:	e8 3f f6 ff ff       	call   8013a6 <read>
	if (r < 0)
  801d67:	85 c0                	test   %eax,%eax
  801d69:	78 0f                	js     801d7a <getchar+0x34>
	if (r < 1)
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	7e 06                	jle    801d75 <getchar+0x2f>
	return c;
  801d6f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d73:	eb 05                	jmp    801d7a <getchar+0x34>
		return -E_EOF;
  801d75:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <iscons>:
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d89:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8c:	89 04 24             	mov    %eax,(%esp)
  801d8f:	e8 67 f3 ff ff       	call   8010fb <fd_lookup>
  801d94:	85 c0                	test   %eax,%eax
  801d96:	78 11                	js     801da9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801da1:	39 10                	cmp    %edx,(%eax)
  801da3:	0f 94 c0             	sete   %al
  801da6:	0f b6 c0             	movzbl %al,%eax
}
  801da9:	c9                   	leave  
  801daa:	c3                   	ret    

00801dab <opencons>:
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801db1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db4:	89 04 24             	mov    %eax,(%esp)
  801db7:	e8 cb f2 ff ff       	call   801087 <fd_alloc>
		return r;
  801dbc:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	78 40                	js     801e02 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dc2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dc9:	00 
  801dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd8:	e8 6c ef ff ff       	call   800d49 <sys_page_alloc>
		return r;
  801ddd:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	78 1f                	js     801e02 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801de3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dec:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801df8:	89 04 24             	mov    %eax,(%esp)
  801dfb:	e8 60 f2 ff ff       	call   801060 <fd2num>
  801e00:	89 c2                	mov    %eax,%edx
}
  801e02:	89 d0                	mov    %edx,%eax
  801e04:	c9                   	leave  
  801e05:	c3                   	ret    

00801e06 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	56                   	push   %esi
  801e0a:	53                   	push   %ebx
  801e0b:	83 ec 10             	sub    $0x10,%esp
  801e0e:	8b 75 08             	mov    0x8(%ebp),%esi
  801e11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  801e14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e17:	89 04 24             	mov    %eax,(%esp)
  801e1a:	e8 40 f1 ff ff       	call   800f5f <sys_ipc_recv>
	if(from_env_store)
  801e1f:	85 f6                	test   %esi,%esi
  801e21:	74 14                	je     801e37 <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  801e23:	ba 00 00 00 00       	mov    $0x0,%edx
  801e28:	85 c0                	test   %eax,%eax
  801e2a:	78 09                	js     801e35 <ipc_recv+0x2f>
  801e2c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e32:	8b 52 74             	mov    0x74(%edx),%edx
  801e35:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  801e37:	85 db                	test   %ebx,%ebx
  801e39:	74 14                	je     801e4f <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  801e3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801e40:	85 c0                	test   %eax,%eax
  801e42:	78 09                	js     801e4d <ipc_recv+0x47>
  801e44:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e4a:	8b 52 78             	mov    0x78(%edx),%edx
  801e4d:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	78 08                	js     801e5b <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  801e53:	a1 04 40 80 00       	mov    0x804004,%eax
  801e58:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e5b:	83 c4 10             	add    $0x10,%esp
  801e5e:	5b                   	pop    %ebx
  801e5f:	5e                   	pop    %esi
  801e60:	5d                   	pop    %ebp
  801e61:	c3                   	ret    

00801e62 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e62:	55                   	push   %ebp
  801e63:	89 e5                	mov    %esp,%ebp
  801e65:	57                   	push   %edi
  801e66:	56                   	push   %esi
  801e67:	53                   	push   %ebx
  801e68:	83 ec 1c             	sub    $0x1c,%esp
  801e6b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e6e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  801e71:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801e76:	eb 0c                	jmp    801e84 <ipc_send+0x22>
		failed_cnt++;
  801e78:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  801e7b:	84 db                	test   %bl,%bl
  801e7d:	75 05                	jne    801e84 <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  801e7f:	e8 a6 ee ff ff       	call   800d2a <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801e84:	8b 45 14             	mov    0x14(%ebp),%eax
  801e87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e92:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e96:	89 3c 24             	mov    %edi,(%esp)
  801e99:	e8 9e f0 ff ff       	call   800f3c <sys_ipc_try_send>
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 d6                	js     801e78 <ipc_send+0x16>
	}
}
  801ea2:	83 c4 1c             	add    $0x1c,%esp
  801ea5:	5b                   	pop    %ebx
  801ea6:	5e                   	pop    %esi
  801ea7:	5f                   	pop    %edi
  801ea8:	5d                   	pop    %ebp
  801ea9:	c3                   	ret    

00801eaa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801eb0:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801eb5:	39 c8                	cmp    %ecx,%eax
  801eb7:	74 17                	je     801ed0 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  801eb9:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ebe:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ec1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ec7:	8b 52 50             	mov    0x50(%edx),%edx
  801eca:	39 ca                	cmp    %ecx,%edx
  801ecc:	75 14                	jne    801ee2 <ipc_find_env+0x38>
  801ece:	eb 05                	jmp    801ed5 <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  801ed0:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  801ed5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ed8:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801edd:	8b 40 40             	mov    0x40(%eax),%eax
  801ee0:	eb 0e                	jmp    801ef0 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  801ee2:	83 c0 01             	add    $0x1,%eax
  801ee5:	3d 00 04 00 00       	cmp    $0x400,%eax
  801eea:	75 d2                	jne    801ebe <ipc_find_env+0x14>
	return 0;
  801eec:	66 b8 00 00          	mov    $0x0,%ax
}
  801ef0:	5d                   	pop    %ebp
  801ef1:	c3                   	ret    

00801ef2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
  801ef5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef8:	89 d0                	mov    %edx,%eax
  801efa:	c1 e8 16             	shr    $0x16,%eax
  801efd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f04:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f09:	f6 c1 01             	test   $0x1,%cl
  801f0c:	74 1d                	je     801f2b <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f0e:	c1 ea 0c             	shr    $0xc,%edx
  801f11:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f18:	f6 c2 01             	test   $0x1,%dl
  801f1b:	74 0e                	je     801f2b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f1d:	c1 ea 0c             	shr    $0xc,%edx
  801f20:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f27:	ef 
  801f28:	0f b7 c0             	movzwl %ax,%eax
}
  801f2b:	5d                   	pop    %ebp
  801f2c:	c3                   	ret    
  801f2d:	66 90                	xchg   %ax,%ax
  801f2f:	90                   	nop

00801f30 <__udivdi3>:
  801f30:	55                   	push   %ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	83 ec 0c             	sub    $0xc,%esp
  801f36:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f3a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801f3e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801f42:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f46:	85 c0                	test   %eax,%eax
  801f48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f4c:	89 ea                	mov    %ebp,%edx
  801f4e:	89 0c 24             	mov    %ecx,(%esp)
  801f51:	75 2d                	jne    801f80 <__udivdi3+0x50>
  801f53:	39 e9                	cmp    %ebp,%ecx
  801f55:	77 61                	ja     801fb8 <__udivdi3+0x88>
  801f57:	85 c9                	test   %ecx,%ecx
  801f59:	89 ce                	mov    %ecx,%esi
  801f5b:	75 0b                	jne    801f68 <__udivdi3+0x38>
  801f5d:	b8 01 00 00 00       	mov    $0x1,%eax
  801f62:	31 d2                	xor    %edx,%edx
  801f64:	f7 f1                	div    %ecx
  801f66:	89 c6                	mov    %eax,%esi
  801f68:	31 d2                	xor    %edx,%edx
  801f6a:	89 e8                	mov    %ebp,%eax
  801f6c:	f7 f6                	div    %esi
  801f6e:	89 c5                	mov    %eax,%ebp
  801f70:	89 f8                	mov    %edi,%eax
  801f72:	f7 f6                	div    %esi
  801f74:	89 ea                	mov    %ebp,%edx
  801f76:	83 c4 0c             	add    $0xc,%esp
  801f79:	5e                   	pop    %esi
  801f7a:	5f                   	pop    %edi
  801f7b:	5d                   	pop    %ebp
  801f7c:	c3                   	ret    
  801f7d:	8d 76 00             	lea    0x0(%esi),%esi
  801f80:	39 e8                	cmp    %ebp,%eax
  801f82:	77 24                	ja     801fa8 <__udivdi3+0x78>
  801f84:	0f bd e8             	bsr    %eax,%ebp
  801f87:	83 f5 1f             	xor    $0x1f,%ebp
  801f8a:	75 3c                	jne    801fc8 <__udivdi3+0x98>
  801f8c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801f90:	39 34 24             	cmp    %esi,(%esp)
  801f93:	0f 86 9f 00 00 00    	jbe    802038 <__udivdi3+0x108>
  801f99:	39 d0                	cmp    %edx,%eax
  801f9b:	0f 82 97 00 00 00    	jb     802038 <__udivdi3+0x108>
  801fa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa8:	31 d2                	xor    %edx,%edx
  801faa:	31 c0                	xor    %eax,%eax
  801fac:	83 c4 0c             	add    $0xc,%esp
  801faf:	5e                   	pop    %esi
  801fb0:	5f                   	pop    %edi
  801fb1:	5d                   	pop    %ebp
  801fb2:	c3                   	ret    
  801fb3:	90                   	nop
  801fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	89 f8                	mov    %edi,%eax
  801fba:	f7 f1                	div    %ecx
  801fbc:	31 d2                	xor    %edx,%edx
  801fbe:	83 c4 0c             	add    $0xc,%esp
  801fc1:	5e                   	pop    %esi
  801fc2:	5f                   	pop    %edi
  801fc3:	5d                   	pop    %ebp
  801fc4:	c3                   	ret    
  801fc5:	8d 76 00             	lea    0x0(%esi),%esi
  801fc8:	89 e9                	mov    %ebp,%ecx
  801fca:	8b 3c 24             	mov    (%esp),%edi
  801fcd:	d3 e0                	shl    %cl,%eax
  801fcf:	89 c6                	mov    %eax,%esi
  801fd1:	b8 20 00 00 00       	mov    $0x20,%eax
  801fd6:	29 e8                	sub    %ebp,%eax
  801fd8:	89 c1                	mov    %eax,%ecx
  801fda:	d3 ef                	shr    %cl,%edi
  801fdc:	89 e9                	mov    %ebp,%ecx
  801fde:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801fe2:	8b 3c 24             	mov    (%esp),%edi
  801fe5:	09 74 24 08          	or     %esi,0x8(%esp)
  801fe9:	89 d6                	mov    %edx,%esi
  801feb:	d3 e7                	shl    %cl,%edi
  801fed:	89 c1                	mov    %eax,%ecx
  801fef:	89 3c 24             	mov    %edi,(%esp)
  801ff2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ff6:	d3 ee                	shr    %cl,%esi
  801ff8:	89 e9                	mov    %ebp,%ecx
  801ffa:	d3 e2                	shl    %cl,%edx
  801ffc:	89 c1                	mov    %eax,%ecx
  801ffe:	d3 ef                	shr    %cl,%edi
  802000:	09 d7                	or     %edx,%edi
  802002:	89 f2                	mov    %esi,%edx
  802004:	89 f8                	mov    %edi,%eax
  802006:	f7 74 24 08          	divl   0x8(%esp)
  80200a:	89 d6                	mov    %edx,%esi
  80200c:	89 c7                	mov    %eax,%edi
  80200e:	f7 24 24             	mull   (%esp)
  802011:	39 d6                	cmp    %edx,%esi
  802013:	89 14 24             	mov    %edx,(%esp)
  802016:	72 30                	jb     802048 <__udivdi3+0x118>
  802018:	8b 54 24 04          	mov    0x4(%esp),%edx
  80201c:	89 e9                	mov    %ebp,%ecx
  80201e:	d3 e2                	shl    %cl,%edx
  802020:	39 c2                	cmp    %eax,%edx
  802022:	73 05                	jae    802029 <__udivdi3+0xf9>
  802024:	3b 34 24             	cmp    (%esp),%esi
  802027:	74 1f                	je     802048 <__udivdi3+0x118>
  802029:	89 f8                	mov    %edi,%eax
  80202b:	31 d2                	xor    %edx,%edx
  80202d:	e9 7a ff ff ff       	jmp    801fac <__udivdi3+0x7c>
  802032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802038:	31 d2                	xor    %edx,%edx
  80203a:	b8 01 00 00 00       	mov    $0x1,%eax
  80203f:	e9 68 ff ff ff       	jmp    801fac <__udivdi3+0x7c>
  802044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802048:	8d 47 ff             	lea    -0x1(%edi),%eax
  80204b:	31 d2                	xor    %edx,%edx
  80204d:	83 c4 0c             	add    $0xc,%esp
  802050:	5e                   	pop    %esi
  802051:	5f                   	pop    %edi
  802052:	5d                   	pop    %ebp
  802053:	c3                   	ret    
  802054:	66 90                	xchg   %ax,%ax
  802056:	66 90                	xchg   %ax,%ax
  802058:	66 90                	xchg   %ax,%ax
  80205a:	66 90                	xchg   %ax,%ax
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__umoddi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	83 ec 14             	sub    $0x14,%esp
  802066:	8b 44 24 28          	mov    0x28(%esp),%eax
  80206a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80206e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802072:	89 c7                	mov    %eax,%edi
  802074:	89 44 24 04          	mov    %eax,0x4(%esp)
  802078:	8b 44 24 30          	mov    0x30(%esp),%eax
  80207c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802080:	89 34 24             	mov    %esi,(%esp)
  802083:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802087:	85 c0                	test   %eax,%eax
  802089:	89 c2                	mov    %eax,%edx
  80208b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80208f:	75 17                	jne    8020a8 <__umoddi3+0x48>
  802091:	39 fe                	cmp    %edi,%esi
  802093:	76 4b                	jbe    8020e0 <__umoddi3+0x80>
  802095:	89 c8                	mov    %ecx,%eax
  802097:	89 fa                	mov    %edi,%edx
  802099:	f7 f6                	div    %esi
  80209b:	89 d0                	mov    %edx,%eax
  80209d:	31 d2                	xor    %edx,%edx
  80209f:	83 c4 14             	add    $0x14,%esp
  8020a2:	5e                   	pop    %esi
  8020a3:	5f                   	pop    %edi
  8020a4:	5d                   	pop    %ebp
  8020a5:	c3                   	ret    
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	39 f8                	cmp    %edi,%eax
  8020aa:	77 54                	ja     802100 <__umoddi3+0xa0>
  8020ac:	0f bd e8             	bsr    %eax,%ebp
  8020af:	83 f5 1f             	xor    $0x1f,%ebp
  8020b2:	75 5c                	jne    802110 <__umoddi3+0xb0>
  8020b4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8020b8:	39 3c 24             	cmp    %edi,(%esp)
  8020bb:	0f 87 e7 00 00 00    	ja     8021a8 <__umoddi3+0x148>
  8020c1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8020c5:	29 f1                	sub    %esi,%ecx
  8020c7:	19 c7                	sbb    %eax,%edi
  8020c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020cd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020d1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020d5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020d9:	83 c4 14             	add    $0x14,%esp
  8020dc:	5e                   	pop    %esi
  8020dd:	5f                   	pop    %edi
  8020de:	5d                   	pop    %ebp
  8020df:	c3                   	ret    
  8020e0:	85 f6                	test   %esi,%esi
  8020e2:	89 f5                	mov    %esi,%ebp
  8020e4:	75 0b                	jne    8020f1 <__umoddi3+0x91>
  8020e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020eb:	31 d2                	xor    %edx,%edx
  8020ed:	f7 f6                	div    %esi
  8020ef:	89 c5                	mov    %eax,%ebp
  8020f1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020f5:	31 d2                	xor    %edx,%edx
  8020f7:	f7 f5                	div    %ebp
  8020f9:	89 c8                	mov    %ecx,%eax
  8020fb:	f7 f5                	div    %ebp
  8020fd:	eb 9c                	jmp    80209b <__umoddi3+0x3b>
  8020ff:	90                   	nop
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 fa                	mov    %edi,%edx
  802104:	83 c4 14             	add    $0x14,%esp
  802107:	5e                   	pop    %esi
  802108:	5f                   	pop    %edi
  802109:	5d                   	pop    %ebp
  80210a:	c3                   	ret    
  80210b:	90                   	nop
  80210c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802110:	8b 04 24             	mov    (%esp),%eax
  802113:	be 20 00 00 00       	mov    $0x20,%esi
  802118:	89 e9                	mov    %ebp,%ecx
  80211a:	29 ee                	sub    %ebp,%esi
  80211c:	d3 e2                	shl    %cl,%edx
  80211e:	89 f1                	mov    %esi,%ecx
  802120:	d3 e8                	shr    %cl,%eax
  802122:	89 e9                	mov    %ebp,%ecx
  802124:	89 44 24 04          	mov    %eax,0x4(%esp)
  802128:	8b 04 24             	mov    (%esp),%eax
  80212b:	09 54 24 04          	or     %edx,0x4(%esp)
  80212f:	89 fa                	mov    %edi,%edx
  802131:	d3 e0                	shl    %cl,%eax
  802133:	89 f1                	mov    %esi,%ecx
  802135:	89 44 24 08          	mov    %eax,0x8(%esp)
  802139:	8b 44 24 10          	mov    0x10(%esp),%eax
  80213d:	d3 ea                	shr    %cl,%edx
  80213f:	89 e9                	mov    %ebp,%ecx
  802141:	d3 e7                	shl    %cl,%edi
  802143:	89 f1                	mov    %esi,%ecx
  802145:	d3 e8                	shr    %cl,%eax
  802147:	89 e9                	mov    %ebp,%ecx
  802149:	09 f8                	or     %edi,%eax
  80214b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80214f:	f7 74 24 04          	divl   0x4(%esp)
  802153:	d3 e7                	shl    %cl,%edi
  802155:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802159:	89 d7                	mov    %edx,%edi
  80215b:	f7 64 24 08          	mull   0x8(%esp)
  80215f:	39 d7                	cmp    %edx,%edi
  802161:	89 c1                	mov    %eax,%ecx
  802163:	89 14 24             	mov    %edx,(%esp)
  802166:	72 2c                	jb     802194 <__umoddi3+0x134>
  802168:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80216c:	72 22                	jb     802190 <__umoddi3+0x130>
  80216e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802172:	29 c8                	sub    %ecx,%eax
  802174:	19 d7                	sbb    %edx,%edi
  802176:	89 e9                	mov    %ebp,%ecx
  802178:	89 fa                	mov    %edi,%edx
  80217a:	d3 e8                	shr    %cl,%eax
  80217c:	89 f1                	mov    %esi,%ecx
  80217e:	d3 e2                	shl    %cl,%edx
  802180:	89 e9                	mov    %ebp,%ecx
  802182:	d3 ef                	shr    %cl,%edi
  802184:	09 d0                	or     %edx,%eax
  802186:	89 fa                	mov    %edi,%edx
  802188:	83 c4 14             	add    $0x14,%esp
  80218b:	5e                   	pop    %esi
  80218c:	5f                   	pop    %edi
  80218d:	5d                   	pop    %ebp
  80218e:	c3                   	ret    
  80218f:	90                   	nop
  802190:	39 d7                	cmp    %edx,%edi
  802192:	75 da                	jne    80216e <__umoddi3+0x10e>
  802194:	8b 14 24             	mov    (%esp),%edx
  802197:	89 c1                	mov    %eax,%ecx
  802199:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80219d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8021a1:	eb cb                	jmp    80216e <__umoddi3+0x10e>
  8021a3:	90                   	nop
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8021ac:	0f 82 0f ff ff ff    	jb     8020c1 <__umoddi3+0x61>
  8021b2:	e9 1a ff ff ff       	jmp    8020d1 <__umoddi3+0x71>
