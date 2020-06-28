
obj/user/faultalloc：     文件格式 elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
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
  800043:	c7 04 24 c0 12 80 00 	movl   $0x8012c0,(%esp)
  80004a:	e8 fa 01 00 00       	call   800249 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800056:	00 
  800057:	89 d8                	mov    %ebx,%eax
  800059:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800069:	e8 eb 0c 00 00       	call   800d59 <sys_page_alloc>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 24                	jns    800096 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800072:	89 44 24 10          	mov    %eax,0x10(%esp)
  800076:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007a:	c7 44 24 08 e0 12 80 	movl   $0x8012e0,0x8(%esp)
  800081:	00 
  800082:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  800089:	00 
  80008a:	c7 04 24 ca 12 80 00 	movl   $0x8012ca,(%esp)
  800091:	e8 ba 00 00 00       	call   800150 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800096:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009a:	c7 44 24 08 0c 13 80 	movl   $0x80130c,0x8(%esp)
  8000a1:	00 
  8000a2:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000a9:	00 
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	e8 6e 07 00 00       	call   800820 <snprintf>
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
  8000c5:	e8 a4 0e 00 00       	call   800f6e <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000ca:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d1:	de 
  8000d2:	c7 04 24 dc 12 80 00 	movl   $0x8012dc,(%esp)
  8000d9:	e8 6b 01 00 00       	call   800249 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000de:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e5:	ca 
  8000e6:	c7 04 24 dc 12 80 00 	movl   $0x8012dc,(%esp)
  8000ed:	e8 57 01 00 00       	call   800249 <cprintf>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 10             	sub    $0x10,%esp
  8000fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ff:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800102:	e8 14 0c 00 00       	call   800d1b <sys_getenvid>
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800114:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800119:	85 db                	test   %ebx,%ebx
  80011b:	7e 07                	jle    800124 <libmain+0x30>
		binaryname = argv[0];
  80011d:	8b 06                	mov    (%esi),%eax
  80011f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800124:	89 74 24 04          	mov    %esi,0x4(%esp)
  800128:	89 1c 24             	mov    %ebx,(%esp)
  80012b:	e8 88 ff ff ff       	call   8000b8 <umain>

	// exit gracefully
	exit();
  800130:	e8 07 00 00 00       	call   80013c <exit>
}
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800142:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800149:	e8 7b 0b 00 00       	call   800cc9 <sys_env_destroy>
}
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
  800155:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800158:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800161:	e8 b5 0b 00 00       	call   800d1b <sys_getenvid>
  800166:	8b 55 0c             	mov    0xc(%ebp),%edx
  800169:	89 54 24 10          	mov    %edx,0x10(%esp)
  80016d:	8b 55 08             	mov    0x8(%ebp),%edx
  800170:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800174:	89 74 24 08          	mov    %esi,0x8(%esp)
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	c7 04 24 38 13 80 00 	movl   $0x801338,(%esp)
  800183:	e8 c1 00 00 00       	call   800249 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800188:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80018c:	8b 45 10             	mov    0x10(%ebp),%eax
  80018f:	89 04 24             	mov    %eax,(%esp)
  800192:	e8 51 00 00 00       	call   8001e8 <vcprintf>
	cprintf("\n");
  800197:	c7 04 24 de 12 80 00 	movl   $0x8012de,(%esp)
  80019e:	e8 a6 00 00 00       	call   800249 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a3:	cc                   	int3   
  8001a4:	eb fd                	jmp    8001a3 <_panic+0x53>

008001a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	83 ec 14             	sub    $0x14,%esp
  8001ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b0:	8b 13                	mov    (%ebx),%edx
  8001b2:	8d 42 01             	lea    0x1(%edx),%eax
  8001b5:	89 03                	mov    %eax,(%ebx)
  8001b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c3:	75 19                	jne    8001de <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001cc:	00 
  8001cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d0:	89 04 24             	mov    %eax,(%esp)
  8001d3:	e8 b4 0a 00 00       	call   800c8c <sys_cputs>
		b->idx = 0;
  8001d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001de:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e2:	83 c4 14             	add    $0x14,%esp
  8001e5:	5b                   	pop    %ebx
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f8:	00 00 00 
	b.cnt = 0;
  8001fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800202:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800205:	8b 45 0c             	mov    0xc(%ebp),%eax
  800208:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020c:	8b 45 08             	mov    0x8(%ebp),%eax
  80020f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800213:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800219:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021d:	c7 04 24 a6 01 80 00 	movl   $0x8001a6,(%esp)
  800224:	e8 bb 01 00 00       	call   8003e4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800229:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80022f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800233:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800239:	89 04 24             	mov    %eax,(%esp)
  80023c:	e8 4b 0a 00 00       	call   800c8c <sys_cputs>

	return b.cnt;
}
  800241:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800247:	c9                   	leave  
  800248:	c3                   	ret    

00800249 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800252:	89 44 24 04          	mov    %eax,0x4(%esp)
  800256:	8b 45 08             	mov    0x8(%ebp),%eax
  800259:	89 04 24             	mov    %eax,(%esp)
  80025c:	e8 87 ff ff ff       	call   8001e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800261:	c9                   	leave  
  800262:	c3                   	ret    
  800263:	66 90                	xchg   %ax,%ax
  800265:	66 90                	xchg   %ax,%ax
  800267:	66 90                	xchg   %ax,%ax
  800269:	66 90                	xchg   %ax,%ax
  80026b:	66 90                	xchg   %ax,%ax
  80026d:	66 90                	xchg   %ax,%ax
  80026f:	90                   	nop

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 3c             	sub    $0x3c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d7                	mov    %edx,%edi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800284:	8b 75 0c             	mov    0xc(%ebp),%esi
  800287:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80028a:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800292:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800295:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800298:	39 f1                	cmp    %esi,%ecx
  80029a:	72 14                	jb     8002b0 <printnum+0x40>
  80029c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80029f:	76 0f                	jbe    8002b0 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002a4:	8d 70 ff             	lea    -0x1(%eax),%esi
  8002a7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002aa:	85 f6                	test   %esi,%esi
  8002ac:	7f 60                	jg     80030e <printnum+0x9e>
  8002ae:	eb 72                	jmp    800322 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002b3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002b7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8002ba:	8d 51 ff             	lea    -0x1(%ecx),%edx
  8002bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c5:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002c9:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002cd:	89 c3                	mov    %eax,%ebx
  8002cf:	89 d6                	mov    %edx,%esi
  8002d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002d4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002d7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002db:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e2:	89 04 24             	mov    %eax,(%esp)
  8002e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ec:	e8 2f 0d 00 00       	call   801020 <__udivdi3>
  8002f1:	89 d9                	mov    %ebx,%ecx
  8002f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002f7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002fb:	89 04 24             	mov    %eax,(%esp)
  8002fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800302:	89 fa                	mov    %edi,%edx
  800304:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800307:	e8 64 ff ff ff       	call   800270 <printnum>
  80030c:	eb 14                	jmp    800322 <printnum+0xb2>
			putch(padc, putdat);
  80030e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800312:	8b 45 18             	mov    0x18(%ebp),%eax
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	ff d3                	call   *%ebx
		while (--width > 0)
  80031a:	83 ee 01             	sub    $0x1,%esi
  80031d:	75 ef                	jne    80030e <printnum+0x9e>
  80031f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800322:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800326:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80032a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80032d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800330:	89 44 24 08          	mov    %eax,0x8(%esp)
  800334:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800338:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033b:	89 04 24             	mov    %eax,(%esp)
  80033e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800341:	89 44 24 04          	mov    %eax,0x4(%esp)
  800345:	e8 06 0e 00 00       	call   801150 <__umoddi3>
  80034a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034e:	0f be 80 5b 13 80 00 	movsbl 0x80135b(%eax),%eax
  800355:	89 04 24             	mov    %eax,(%esp)
  800358:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80035b:	ff d0                	call   *%eax
}
  80035d:	83 c4 3c             	add    $0x3c,%esp
  800360:	5b                   	pop    %ebx
  800361:	5e                   	pop    %esi
  800362:	5f                   	pop    %edi
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    

00800365 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800368:	83 fa 01             	cmp    $0x1,%edx
  80036b:	7e 0e                	jle    80037b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80036d:	8b 10                	mov    (%eax),%edx
  80036f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800372:	89 08                	mov    %ecx,(%eax)
  800374:	8b 02                	mov    (%edx),%eax
  800376:	8b 52 04             	mov    0x4(%edx),%edx
  800379:	eb 22                	jmp    80039d <getuint+0x38>
	else if (lflag)
  80037b:	85 d2                	test   %edx,%edx
  80037d:	74 10                	je     80038f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80037f:	8b 10                	mov    (%eax),%edx
  800381:	8d 4a 04             	lea    0x4(%edx),%ecx
  800384:	89 08                	mov    %ecx,(%eax)
  800386:	8b 02                	mov    (%edx),%eax
  800388:	ba 00 00 00 00       	mov    $0x0,%edx
  80038d:	eb 0e                	jmp    80039d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	8d 4a 04             	lea    0x4(%edx),%ecx
  800394:	89 08                	mov    %ecx,(%eax)
  800396:	8b 02                	mov    (%edx),%eax
  800398:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ae:	73 0a                	jae    8003ba <sprintputch+0x1b>
		*b->buf++ = ch;
  8003b0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003b3:	89 08                	mov    %ecx,(%eax)
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b8:	88 02                	mov    %al,(%edx)
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <printfmt>:
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8003c2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003da:	89 04 24             	mov    %eax,(%esp)
  8003dd:	e8 02 00 00 00       	call   8003e4 <vprintfmt>
}
  8003e2:	c9                   	leave  
  8003e3:	c3                   	ret    

008003e4 <vprintfmt>:
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	57                   	push   %edi
  8003e8:	56                   	push   %esi
  8003e9:	53                   	push   %ebx
  8003ea:	83 ec 3c             	sub    $0x3c,%esp
  8003ed:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003f3:	eb 18                	jmp    80040d <vprintfmt+0x29>
			if (ch == '\0')
  8003f5:	85 c0                	test   %eax,%eax
  8003f7:	0f 84 c3 03 00 00    	je     8007c0 <vprintfmt+0x3dc>
			putch(ch, putdat);
  8003fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800401:	89 04 24             	mov    %eax,(%esp)
  800404:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800407:	89 f3                	mov    %esi,%ebx
  800409:	eb 02                	jmp    80040d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80040b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040d:	8d 73 01             	lea    0x1(%ebx),%esi
  800410:	0f b6 03             	movzbl (%ebx),%eax
  800413:	83 f8 25             	cmp    $0x25,%eax
  800416:	75 dd                	jne    8003f5 <vprintfmt+0x11>
  800418:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80041c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800423:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80042a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800431:	ba 00 00 00 00       	mov    $0x0,%edx
  800436:	eb 1d                	jmp    800455 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800438:	89 de                	mov    %ebx,%esi
			padc = '-';
  80043a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80043e:	eb 15                	jmp    800455 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800440:	89 de                	mov    %ebx,%esi
			padc = '0';
  800442:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800446:	eb 0d                	jmp    800455 <vprintfmt+0x71>
				width = precision, precision = -1;
  800448:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80044b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8d 5e 01             	lea    0x1(%esi),%ebx
  800458:	0f b6 06             	movzbl (%esi),%eax
  80045b:	0f b6 c8             	movzbl %al,%ecx
  80045e:	83 e8 23             	sub    $0x23,%eax
  800461:	3c 55                	cmp    $0x55,%al
  800463:	0f 87 2f 03 00 00    	ja     800798 <vprintfmt+0x3b4>
  800469:	0f b6 c0             	movzbl %al,%eax
  80046c:	ff 24 85 20 14 80 00 	jmp    *0x801420(,%eax,4)
				precision = precision * 10 + ch - '0';
  800473:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800476:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  800479:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80047d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800480:	83 f9 09             	cmp    $0x9,%ecx
  800483:	77 50                	ja     8004d5 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  800485:	89 de                	mov    %ebx,%esi
  800487:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  80048a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80048d:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800490:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800494:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800497:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80049a:	83 fb 09             	cmp    $0x9,%ebx
  80049d:	76 eb                	jbe    80048a <vprintfmt+0xa6>
  80049f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004a2:	eb 33                	jmp    8004d7 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8d 48 04             	lea    0x4(%eax),%ecx
  8004aa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ad:	8b 00                	mov    (%eax),%eax
  8004af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8004b4:	eb 21                	jmp    8004d7 <vprintfmt+0xf3>
  8004b6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004b9:	85 c9                	test   %ecx,%ecx
  8004bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c0:	0f 49 c1             	cmovns %ecx,%eax
  8004c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	89 de                	mov    %ebx,%esi
  8004c8:	eb 8b                	jmp    800455 <vprintfmt+0x71>
  8004ca:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8004cc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004d3:	eb 80                	jmp    800455 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	89 de                	mov    %ebx,%esi
			if (width < 0)
  8004d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004db:	0f 89 74 ff ff ff    	jns    800455 <vprintfmt+0x71>
  8004e1:	e9 62 ff ff ff       	jmp    800448 <vprintfmt+0x64>
			lflag++;
  8004e6:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8004e9:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8004eb:	e9 65 ff ff ff       	jmp    800455 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  8004f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f3:	8d 50 04             	lea    0x4(%eax),%edx
  8004f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004fd:	8b 00                	mov    (%eax),%eax
  8004ff:	89 04 24             	mov    %eax,(%esp)
  800502:	ff 55 08             	call   *0x8(%ebp)
			break;
  800505:	e9 03 ff ff ff       	jmp    80040d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 50 04             	lea    0x4(%eax),%edx
  800510:	89 55 14             	mov    %edx,0x14(%ebp)
  800513:	8b 00                	mov    (%eax),%eax
  800515:	99                   	cltd   
  800516:	31 d0                	xor    %edx,%eax
  800518:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051a:	83 f8 08             	cmp    $0x8,%eax
  80051d:	7f 0b                	jg     80052a <vprintfmt+0x146>
  80051f:	8b 14 85 80 15 80 00 	mov    0x801580(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 20                	jne    80054a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80052a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80052e:	c7 44 24 08 73 13 80 	movl   $0x801373,0x8(%esp)
  800535:	00 
  800536:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053a:	8b 45 08             	mov    0x8(%ebp),%eax
  80053d:	89 04 24             	mov    %eax,(%esp)
  800540:	e8 77 fe ff ff       	call   8003bc <printfmt>
  800545:	e9 c3 fe ff ff       	jmp    80040d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80054a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80054e:	c7 44 24 08 7c 13 80 	movl   $0x80137c,0x8(%esp)
  800555:	00 
  800556:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055a:	8b 45 08             	mov    0x8(%ebp),%eax
  80055d:	89 04 24             	mov    %eax,(%esp)
  800560:	e8 57 fe ff ff       	call   8003bc <printfmt>
  800565:	e9 a3 fe ff ff       	jmp    80040d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80056d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 50 04             	lea    0x4(%eax),%edx
  800576:	89 55 14             	mov    %edx,0x14(%ebp)
  800579:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80057b:	85 c0                	test   %eax,%eax
  80057d:	ba 6c 13 80 00       	mov    $0x80136c,%edx
  800582:	0f 45 d0             	cmovne %eax,%edx
  800585:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800588:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80058c:	74 04                	je     800592 <vprintfmt+0x1ae>
  80058e:	85 f6                	test   %esi,%esi
  800590:	7f 19                	jg     8005ab <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800592:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800595:	8d 70 01             	lea    0x1(%eax),%esi
  800598:	0f b6 10             	movzbl (%eax),%edx
  80059b:	0f be c2             	movsbl %dl,%eax
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	0f 85 95 00 00 00    	jne    80063b <vprintfmt+0x257>
  8005a6:	e9 85 00 00 00       	jmp    800630 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005af:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005b2:	89 04 24             	mov    %eax,(%esp)
  8005b5:	e8 b8 02 00 00       	call   800872 <strnlen>
  8005ba:	29 c6                	sub    %eax,%esi
  8005bc:	89 f0                	mov    %esi,%eax
  8005be:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8005c1:	85 f6                	test   %esi,%esi
  8005c3:	7e cd                	jle    800592 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8005c5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8005c9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005cc:	89 c3                	mov    %eax,%ebx
  8005ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d2:	89 34 24             	mov    %esi,(%esp)
  8005d5:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d8:	83 eb 01             	sub    $0x1,%ebx
  8005db:	75 f1                	jne    8005ce <vprintfmt+0x1ea>
  8005dd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005e3:	eb ad                	jmp    800592 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e9:	74 1e                	je     800609 <vprintfmt+0x225>
  8005eb:	0f be d2             	movsbl %dl,%edx
  8005ee:	83 ea 20             	sub    $0x20,%edx
  8005f1:	83 fa 5e             	cmp    $0x5e,%edx
  8005f4:	76 13                	jbe    800609 <vprintfmt+0x225>
					putch('?', putdat);
  8005f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800604:	ff 55 08             	call   *0x8(%ebp)
  800607:	eb 0d                	jmp    800616 <vprintfmt+0x232>
					putch(ch, putdat);
  800609:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80060c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800610:	89 04 24             	mov    %eax,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800616:	83 ef 01             	sub    $0x1,%edi
  800619:	83 c6 01             	add    $0x1,%esi
  80061c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800620:	0f be c2             	movsbl %dl,%eax
  800623:	85 c0                	test   %eax,%eax
  800625:	75 20                	jne    800647 <vprintfmt+0x263>
  800627:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80062a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80062d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800630:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800634:	7f 25                	jg     80065b <vprintfmt+0x277>
  800636:	e9 d2 fd ff ff       	jmp    80040d <vprintfmt+0x29>
  80063b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800641:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800644:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800647:	85 db                	test   %ebx,%ebx
  800649:	78 9a                	js     8005e5 <vprintfmt+0x201>
  80064b:	83 eb 01             	sub    $0x1,%ebx
  80064e:	79 95                	jns    8005e5 <vprintfmt+0x201>
  800650:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800653:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800656:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800659:	eb d5                	jmp    800630 <vprintfmt+0x24c>
  80065b:	8b 75 08             	mov    0x8(%ebp),%esi
  80065e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800661:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  800664:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800668:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80066f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800671:	83 eb 01             	sub    $0x1,%ebx
  800674:	75 ee                	jne    800664 <vprintfmt+0x280>
  800676:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800679:	e9 8f fd ff ff       	jmp    80040d <vprintfmt+0x29>
	if (lflag >= 2)
  80067e:	83 fa 01             	cmp    $0x1,%edx
  800681:	7e 16                	jle    800699 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 50 08             	lea    0x8(%eax),%edx
  800689:	89 55 14             	mov    %edx,0x14(%ebp)
  80068c:	8b 50 04             	mov    0x4(%eax),%edx
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800694:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800697:	eb 32                	jmp    8006cb <vprintfmt+0x2e7>
	else if (lflag)
  800699:	85 d2                	test   %edx,%edx
  80069b:	74 18                	je     8006b5 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8d 50 04             	lea    0x4(%eax),%edx
  8006a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a6:	8b 30                	mov    (%eax),%esi
  8006a8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006ab:	89 f0                	mov    %esi,%eax
  8006ad:	c1 f8 1f             	sar    $0x1f,%eax
  8006b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006b3:	eb 16                	jmp    8006cb <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8d 50 04             	lea    0x4(%eax),%edx
  8006bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006be:	8b 30                	mov    (%eax),%esi
  8006c0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006c3:	89 f0                	mov    %esi,%eax
  8006c5:	c1 f8 1f             	sar    $0x1f,%eax
  8006c8:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  8006cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  8006d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8006d6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006da:	0f 89 80 00 00 00    	jns    800760 <vprintfmt+0x37c>
				putch('-', putdat);
  8006e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006eb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006f4:	f7 d8                	neg    %eax
  8006f6:	83 d2 00             	adc    $0x0,%edx
  8006f9:	f7 da                	neg    %edx
			base = 10;
  8006fb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800700:	eb 5e                	jmp    800760 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800702:	8d 45 14             	lea    0x14(%ebp),%eax
  800705:	e8 5b fc ff ff       	call   800365 <getuint>
			base = 10;
  80070a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80070f:	eb 4f                	jmp    800760 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800711:	8d 45 14             	lea    0x14(%ebp),%eax
  800714:	e8 4c fc ff ff       	call   800365 <getuint>
			base = 8;
  800719:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80071e:	eb 40                	jmp    800760 <vprintfmt+0x37c>
			putch('0', putdat);
  800720:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800724:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80072b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80072e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800732:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800739:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8d 50 04             	lea    0x4(%eax),%edx
  800742:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800745:	8b 00                	mov    (%eax),%eax
  800747:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80074c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800751:	eb 0d                	jmp    800760 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800753:	8d 45 14             	lea    0x14(%ebp),%eax
  800756:	e8 0a fc ff ff       	call   800365 <getuint>
			base = 16;
  80075b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800760:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800764:	89 74 24 10          	mov    %esi,0x10(%esp)
  800768:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80076b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80076f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800773:	89 04 24             	mov    %eax,(%esp)
  800776:	89 54 24 04          	mov    %edx,0x4(%esp)
  80077a:	89 fa                	mov    %edi,%edx
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	e8 ec fa ff ff       	call   800270 <printnum>
			break;
  800784:	e9 84 fc ff ff       	jmp    80040d <vprintfmt+0x29>
			putch(ch, putdat);
  800789:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078d:	89 0c 24             	mov    %ecx,(%esp)
  800790:	ff 55 08             	call   *0x8(%ebp)
			break;
  800793:	e9 75 fc ff ff       	jmp    80040d <vprintfmt+0x29>
			putch('%', putdat);
  800798:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007aa:	0f 84 5b fc ff ff    	je     80040b <vprintfmt+0x27>
  8007b0:	89 f3                	mov    %esi,%ebx
  8007b2:	83 eb 01             	sub    $0x1,%ebx
  8007b5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007b9:	75 f7                	jne    8007b2 <vprintfmt+0x3ce>
  8007bb:	e9 4d fc ff ff       	jmp    80040d <vprintfmt+0x29>
}
  8007c0:	83 c4 3c             	add    $0x3c,%esp
  8007c3:	5b                   	pop    %ebx
  8007c4:	5e                   	pop    %esi
  8007c5:	5f                   	pop    %edi
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	83 ec 28             	sub    $0x28,%esp
  8007ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007d7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007db:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	74 30                	je     800819 <vsnprintf+0x51>
  8007e9:	85 d2                	test   %edx,%edx
  8007eb:	7e 2c                	jle    800819 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800802:	c7 04 24 9f 03 80 00 	movl   $0x80039f,(%esp)
  800809:	e8 d6 fb ff ff       	call   8003e4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80080e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800811:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800814:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800817:	eb 05                	jmp    80081e <vsnprintf+0x56>
		return -E_INVAL;
  800819:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80081e:	c9                   	leave  
  80081f:	c3                   	ret    

00800820 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800826:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800829:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082d:	8b 45 10             	mov    0x10(%ebp),%eax
  800830:	89 44 24 08          	mov    %eax,0x8(%esp)
  800834:	8b 45 0c             	mov    0xc(%ebp),%eax
  800837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	89 04 24             	mov    %eax,(%esp)
  800841:	e8 82 ff ff ff       	call   8007c8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800846:	c9                   	leave  
  800847:	c3                   	ret    
  800848:	66 90                	xchg   %ax,%ax
  80084a:	66 90                	xchg   %ax,%ax
  80084c:	66 90                	xchg   %ax,%ax
  80084e:	66 90                	xchg   %ax,%ax

00800850 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800856:	80 3a 00             	cmpb   $0x0,(%edx)
  800859:	74 10                	je     80086b <strlen+0x1b>
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800860:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800863:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800867:	75 f7                	jne    800860 <strlen+0x10>
  800869:	eb 05                	jmp    800870 <strlen+0x20>
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	53                   	push   %ebx
  800876:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800879:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	85 c9                	test   %ecx,%ecx
  80087e:	74 1c                	je     80089c <strnlen+0x2a>
  800880:	80 3b 00             	cmpb   $0x0,(%ebx)
  800883:	74 1e                	je     8008a3 <strnlen+0x31>
  800885:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80088a:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088c:	39 ca                	cmp    %ecx,%edx
  80088e:	74 18                	je     8008a8 <strnlen+0x36>
  800890:	83 c2 01             	add    $0x1,%edx
  800893:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800898:	75 f0                	jne    80088a <strnlen+0x18>
  80089a:	eb 0c                	jmp    8008a8 <strnlen+0x36>
  80089c:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a1:	eb 05                	jmp    8008a8 <strnlen+0x36>
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b5:	89 c2                	mov    %eax,%edx
  8008b7:	83 c2 01             	add    $0x1,%edx
  8008ba:	83 c1 01             	add    $0x1,%ecx
  8008bd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008c1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c4:	84 db                	test   %bl,%bl
  8008c6:	75 ef                	jne    8008b7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	83 ec 08             	sub    $0x8,%esp
  8008d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d5:	89 1c 24             	mov    %ebx,(%esp)
  8008d8:	e8 73 ff ff ff       	call   800850 <strlen>
	strcpy(dst + len, src);
  8008dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e4:	01 d8                	add    %ebx,%eax
  8008e6:	89 04 24             	mov    %eax,(%esp)
  8008e9:	e8 bd ff ff ff       	call   8008ab <strcpy>
	return dst;
}
  8008ee:	89 d8                	mov    %ebx,%eax
  8008f0:	83 c4 08             	add    $0x8,%esp
  8008f3:	5b                   	pop    %ebx
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800901:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800904:	85 db                	test   %ebx,%ebx
  800906:	74 17                	je     80091f <strncpy+0x29>
  800908:	01 f3                	add    %esi,%ebx
  80090a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80090c:	83 c1 01             	add    $0x1,%ecx
  80090f:	0f b6 02             	movzbl (%edx),%eax
  800912:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800915:	80 3a 01             	cmpb   $0x1,(%edx)
  800918:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80091b:	39 d9                	cmp    %ebx,%ecx
  80091d:	75 ed                	jne    80090c <strncpy+0x16>
	}
	return ret;
}
  80091f:	89 f0                	mov    %esi,%eax
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	57                   	push   %edi
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800931:	8b 75 10             	mov    0x10(%ebp),%esi
  800934:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800936:	85 f6                	test   %esi,%esi
  800938:	74 34                	je     80096e <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  80093a:	83 fe 01             	cmp    $0x1,%esi
  80093d:	74 26                	je     800965 <strlcpy+0x40>
  80093f:	0f b6 0b             	movzbl (%ebx),%ecx
  800942:	84 c9                	test   %cl,%cl
  800944:	74 23                	je     800969 <strlcpy+0x44>
  800946:	83 ee 02             	sub    $0x2,%esi
  800949:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  80094e:	83 c0 01             	add    $0x1,%eax
  800951:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800954:	39 f2                	cmp    %esi,%edx
  800956:	74 13                	je     80096b <strlcpy+0x46>
  800958:	83 c2 01             	add    $0x1,%edx
  80095b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80095f:	84 c9                	test   %cl,%cl
  800961:	75 eb                	jne    80094e <strlcpy+0x29>
  800963:	eb 06                	jmp    80096b <strlcpy+0x46>
  800965:	89 f8                	mov    %edi,%eax
  800967:	eb 02                	jmp    80096b <strlcpy+0x46>
  800969:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  80096b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80096e:	29 f8                	sub    %edi,%eax
}
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5f                   	pop    %edi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80097e:	0f b6 01             	movzbl (%ecx),%eax
  800981:	84 c0                	test   %al,%al
  800983:	74 15                	je     80099a <strcmp+0x25>
  800985:	3a 02                	cmp    (%edx),%al
  800987:	75 11                	jne    80099a <strcmp+0x25>
		p++, q++;
  800989:	83 c1 01             	add    $0x1,%ecx
  80098c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80098f:	0f b6 01             	movzbl (%ecx),%eax
  800992:	84 c0                	test   %al,%al
  800994:	74 04                	je     80099a <strcmp+0x25>
  800996:	3a 02                	cmp    (%edx),%al
  800998:	74 ef                	je     800989 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80099a:	0f b6 c0             	movzbl %al,%eax
  80099d:	0f b6 12             	movzbl (%edx),%edx
  8009a0:	29 d0                	sub    %edx,%eax
}
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009af:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009b2:	85 f6                	test   %esi,%esi
  8009b4:	74 29                	je     8009df <strncmp+0x3b>
  8009b6:	0f b6 03             	movzbl (%ebx),%eax
  8009b9:	84 c0                	test   %al,%al
  8009bb:	74 30                	je     8009ed <strncmp+0x49>
  8009bd:	3a 02                	cmp    (%edx),%al
  8009bf:	75 2c                	jne    8009ed <strncmp+0x49>
  8009c1:	8d 43 01             	lea    0x1(%ebx),%eax
  8009c4:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8009c6:	89 c3                	mov    %eax,%ebx
  8009c8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009cb:	39 f0                	cmp    %esi,%eax
  8009cd:	74 17                	je     8009e6 <strncmp+0x42>
  8009cf:	0f b6 08             	movzbl (%eax),%ecx
  8009d2:	84 c9                	test   %cl,%cl
  8009d4:	74 17                	je     8009ed <strncmp+0x49>
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	3a 0a                	cmp    (%edx),%cl
  8009db:	74 e9                	je     8009c6 <strncmp+0x22>
  8009dd:	eb 0e                	jmp    8009ed <strncmp+0x49>
	if (n == 0)
		return 0;
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e4:	eb 0f                	jmp    8009f5 <strncmp+0x51>
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009eb:	eb 08                	jmp    8009f5 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ed:	0f b6 03             	movzbl (%ebx),%eax
  8009f0:	0f b6 12             	movzbl (%edx),%edx
  8009f3:	29 d0                	sub    %edx,%eax
}
  8009f5:	5b                   	pop    %ebx
  8009f6:	5e                   	pop    %esi
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	53                   	push   %ebx
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a03:	0f b6 18             	movzbl (%eax),%ebx
  800a06:	84 db                	test   %bl,%bl
  800a08:	74 1d                	je     800a27 <strchr+0x2e>
  800a0a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a0c:	38 d3                	cmp    %dl,%bl
  800a0e:	75 06                	jne    800a16 <strchr+0x1d>
  800a10:	eb 1a                	jmp    800a2c <strchr+0x33>
  800a12:	38 ca                	cmp    %cl,%dl
  800a14:	74 16                	je     800a2c <strchr+0x33>
	for (; *s; s++)
  800a16:	83 c0 01             	add    $0x1,%eax
  800a19:	0f b6 10             	movzbl (%eax),%edx
  800a1c:	84 d2                	test   %dl,%dl
  800a1e:	75 f2                	jne    800a12 <strchr+0x19>
			return (char *) s;
	return 0;
  800a20:	b8 00 00 00 00       	mov    $0x0,%eax
  800a25:	eb 05                	jmp    800a2c <strchr+0x33>
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2c:	5b                   	pop    %ebx
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	53                   	push   %ebx
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a39:	0f b6 18             	movzbl (%eax),%ebx
  800a3c:	84 db                	test   %bl,%bl
  800a3e:	74 16                	je     800a56 <strfind+0x27>
  800a40:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a42:	38 d3                	cmp    %dl,%bl
  800a44:	75 06                	jne    800a4c <strfind+0x1d>
  800a46:	eb 0e                	jmp    800a56 <strfind+0x27>
  800a48:	38 ca                	cmp    %cl,%dl
  800a4a:	74 0a                	je     800a56 <strfind+0x27>
	for (; *s; s++)
  800a4c:	83 c0 01             	add    $0x1,%eax
  800a4f:	0f b6 10             	movzbl (%eax),%edx
  800a52:	84 d2                	test   %dl,%dl
  800a54:	75 f2                	jne    800a48 <strfind+0x19>
			break;
	return (char *) s;
}
  800a56:	5b                   	pop    %ebx
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
  800a5f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a62:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a65:	85 c9                	test   %ecx,%ecx
  800a67:	74 36                	je     800a9f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a69:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6f:	75 28                	jne    800a99 <memset+0x40>
  800a71:	f6 c1 03             	test   $0x3,%cl
  800a74:	75 23                	jne    800a99 <memset+0x40>
		c &= 0xFF;
  800a76:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a7a:	89 d3                	mov    %edx,%ebx
  800a7c:	c1 e3 08             	shl    $0x8,%ebx
  800a7f:	89 d6                	mov    %edx,%esi
  800a81:	c1 e6 18             	shl    $0x18,%esi
  800a84:	89 d0                	mov    %edx,%eax
  800a86:	c1 e0 10             	shl    $0x10,%eax
  800a89:	09 f0                	or     %esi,%eax
  800a8b:	09 c2                	or     %eax,%edx
  800a8d:	89 d0                	mov    %edx,%eax
  800a8f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a91:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a94:	fc                   	cld    
  800a95:	f3 ab                	rep stos %eax,%es:(%edi)
  800a97:	eb 06                	jmp    800a9f <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9c:	fc                   	cld    
  800a9d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a9f:	89 f8                	mov    %edi,%eax
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab4:	39 c6                	cmp    %eax,%esi
  800ab6:	73 35                	jae    800aed <memmove+0x47>
  800ab8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800abb:	39 d0                	cmp    %edx,%eax
  800abd:	73 2e                	jae    800aed <memmove+0x47>
		s += n;
		d += n;
  800abf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ac2:	89 d6                	mov    %edx,%esi
  800ac4:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800acc:	75 13                	jne    800ae1 <memmove+0x3b>
  800ace:	f6 c1 03             	test   $0x3,%cl
  800ad1:	75 0e                	jne    800ae1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ad3:	83 ef 04             	sub    $0x4,%edi
  800ad6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800adc:	fd                   	std    
  800add:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800adf:	eb 09                	jmp    800aea <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ae1:	83 ef 01             	sub    $0x1,%edi
  800ae4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ae7:	fd                   	std    
  800ae8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aea:	fc                   	cld    
  800aeb:	eb 1d                	jmp    800b0a <memmove+0x64>
  800aed:	89 f2                	mov    %esi,%edx
  800aef:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af1:	f6 c2 03             	test   $0x3,%dl
  800af4:	75 0f                	jne    800b05 <memmove+0x5f>
  800af6:	f6 c1 03             	test   $0x3,%cl
  800af9:	75 0a                	jne    800b05 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800afb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800afe:	89 c7                	mov    %eax,%edi
  800b00:	fc                   	cld    
  800b01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b03:	eb 05                	jmp    800b0a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	fc                   	cld    
  800b08:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b14:	8b 45 10             	mov    0x10(%ebp),%eax
  800b17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	89 04 24             	mov    %eax,(%esp)
  800b28:	e8 79 ff ff ff       	call   800aa6 <memmove>
}
  800b2d:	c9                   	leave  
  800b2e:	c3                   	ret    

00800b2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b38:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b41:	85 c0                	test   %eax,%eax
  800b43:	74 36                	je     800b7b <memcmp+0x4c>
		if (*s1 != *s2)
  800b45:	0f b6 03             	movzbl (%ebx),%eax
  800b48:	0f b6 0e             	movzbl (%esi),%ecx
  800b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b50:	38 c8                	cmp    %cl,%al
  800b52:	74 1c                	je     800b70 <memcmp+0x41>
  800b54:	eb 10                	jmp    800b66 <memcmp+0x37>
  800b56:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b5b:	83 c2 01             	add    $0x1,%edx
  800b5e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b62:	38 c8                	cmp    %cl,%al
  800b64:	74 0a                	je     800b70 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b66:	0f b6 c0             	movzbl %al,%eax
  800b69:	0f b6 c9             	movzbl %cl,%ecx
  800b6c:	29 c8                	sub    %ecx,%eax
  800b6e:	eb 10                	jmp    800b80 <memcmp+0x51>
	while (n-- > 0) {
  800b70:	39 fa                	cmp    %edi,%edx
  800b72:	75 e2                	jne    800b56 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
  800b79:	eb 05                	jmp    800b80 <memcmp+0x51>
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	53                   	push   %ebx
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b8f:	89 c2                	mov    %eax,%edx
  800b91:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b94:	39 d0                	cmp    %edx,%eax
  800b96:	73 13                	jae    800bab <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b98:	89 d9                	mov    %ebx,%ecx
  800b9a:	38 18                	cmp    %bl,(%eax)
  800b9c:	75 06                	jne    800ba4 <memfind+0x1f>
  800b9e:	eb 0b                	jmp    800bab <memfind+0x26>
  800ba0:	38 08                	cmp    %cl,(%eax)
  800ba2:	74 07                	je     800bab <memfind+0x26>
	for (; s < ends; s++)
  800ba4:	83 c0 01             	add    $0x1,%eax
  800ba7:	39 d0                	cmp    %edx,%eax
  800ba9:	75 f5                	jne    800ba0 <memfind+0x1b>
			break;
	return (void *) s;
}
  800bab:	5b                   	pop    %ebx
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bba:	0f b6 0a             	movzbl (%edx),%ecx
  800bbd:	80 f9 09             	cmp    $0x9,%cl
  800bc0:	74 05                	je     800bc7 <strtol+0x19>
  800bc2:	80 f9 20             	cmp    $0x20,%cl
  800bc5:	75 10                	jne    800bd7 <strtol+0x29>
		s++;
  800bc7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800bca:	0f b6 0a             	movzbl (%edx),%ecx
  800bcd:	80 f9 09             	cmp    $0x9,%cl
  800bd0:	74 f5                	je     800bc7 <strtol+0x19>
  800bd2:	80 f9 20             	cmp    $0x20,%cl
  800bd5:	74 f0                	je     800bc7 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800bd7:	80 f9 2b             	cmp    $0x2b,%cl
  800bda:	75 0a                	jne    800be6 <strtol+0x38>
		s++;
  800bdc:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800bdf:	bf 00 00 00 00       	mov    $0x0,%edi
  800be4:	eb 11                	jmp    800bf7 <strtol+0x49>
  800be6:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800beb:	80 f9 2d             	cmp    $0x2d,%cl
  800bee:	75 07                	jne    800bf7 <strtol+0x49>
		s++, neg = 1;
  800bf0:	83 c2 01             	add    $0x1,%edx
  800bf3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf7:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800bfc:	75 15                	jne    800c13 <strtol+0x65>
  800bfe:	80 3a 30             	cmpb   $0x30,(%edx)
  800c01:	75 10                	jne    800c13 <strtol+0x65>
  800c03:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c07:	75 0a                	jne    800c13 <strtol+0x65>
		s += 2, base = 16;
  800c09:	83 c2 02             	add    $0x2,%edx
  800c0c:	b8 10 00 00 00       	mov    $0x10,%eax
  800c11:	eb 10                	jmp    800c23 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800c13:	85 c0                	test   %eax,%eax
  800c15:	75 0c                	jne    800c23 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c17:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800c19:	80 3a 30             	cmpb   $0x30,(%edx)
  800c1c:	75 05                	jne    800c23 <strtol+0x75>
		s++, base = 8;
  800c1e:	83 c2 01             	add    $0x1,%edx
  800c21:	b0 08                	mov    $0x8,%al
		base = 10;
  800c23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c28:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c2b:	0f b6 0a             	movzbl (%edx),%ecx
  800c2e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c31:	89 f0                	mov    %esi,%eax
  800c33:	3c 09                	cmp    $0x9,%al
  800c35:	77 08                	ja     800c3f <strtol+0x91>
			dig = *s - '0';
  800c37:	0f be c9             	movsbl %cl,%ecx
  800c3a:	83 e9 30             	sub    $0x30,%ecx
  800c3d:	eb 20                	jmp    800c5f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800c3f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c42:	89 f0                	mov    %esi,%eax
  800c44:	3c 19                	cmp    $0x19,%al
  800c46:	77 08                	ja     800c50 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c48:	0f be c9             	movsbl %cl,%ecx
  800c4b:	83 e9 57             	sub    $0x57,%ecx
  800c4e:	eb 0f                	jmp    800c5f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800c50:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c53:	89 f0                	mov    %esi,%eax
  800c55:	3c 19                	cmp    $0x19,%al
  800c57:	77 16                	ja     800c6f <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c59:	0f be c9             	movsbl %cl,%ecx
  800c5c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c5f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c62:	7d 0f                	jge    800c73 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c64:	83 c2 01             	add    $0x1,%edx
  800c67:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c6b:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c6d:	eb bc                	jmp    800c2b <strtol+0x7d>
  800c6f:	89 d8                	mov    %ebx,%eax
  800c71:	eb 02                	jmp    800c75 <strtol+0xc7>
  800c73:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c75:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c79:	74 05                	je     800c80 <strtol+0xd2>
		*endptr = (char *) s;
  800c7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c7e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c80:	f7 d8                	neg    %eax
  800c82:	85 ff                	test   %edi,%edi
  800c84:	0f 44 c3             	cmove  %ebx,%eax
}
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c92:	b8 00 00 00 00       	mov    $0x0,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 c3                	mov    %eax,%ebx
  800c9f:	89 c7                	mov    %eax,%edi
  800ca1:	89 c6                	mov    %eax,%esi
  800ca3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_cgetc>:

int
sys_cgetc(void)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cba:	89 d1                	mov    %edx,%ecx
  800cbc:	89 d3                	mov    %edx,%ebx
  800cbe:	89 d7                	mov    %edx,%edi
  800cc0:	89 d6                	mov    %edx,%esi
  800cc2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd7:	b8 03 00 00 00       	mov    $0x3,%eax
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	89 cb                	mov    %ecx,%ebx
  800ce1:	89 cf                	mov    %ecx,%edi
  800ce3:	89 ce                	mov    %ecx,%esi
  800ce5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7e 28                	jle    800d13 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cef:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cf6:	00 
  800cf7:	c7 44 24 08 a4 15 80 	movl   $0x8015a4,0x8(%esp)
  800cfe:	00 
  800cff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d06:	00 
  800d07:	c7 04 24 c1 15 80 00 	movl   $0x8015c1,(%esp)
  800d0e:	e8 3d f4 ff ff       	call   800150 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d13:	83 c4 2c             	add    $0x2c,%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d21:	ba 00 00 00 00       	mov    $0x0,%edx
  800d26:	b8 02 00 00 00       	mov    $0x2,%eax
  800d2b:	89 d1                	mov    %edx,%ecx
  800d2d:	89 d3                	mov    %edx,%ebx
  800d2f:	89 d7                	mov    %edx,%edi
  800d31:	89 d6                	mov    %edx,%esi
  800d33:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_yield>:

void
sys_yield(void)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d40:	ba 00 00 00 00       	mov    $0x0,%edx
  800d45:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d4a:	89 d1                	mov    %edx,%ecx
  800d4c:	89 d3                	mov    %edx,%ebx
  800d4e:	89 d7                	mov    %edx,%edi
  800d50:	89 d6                	mov    %edx,%esi
  800d52:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d62:	be 00 00 00 00       	mov    $0x0,%esi
  800d67:	b8 04 00 00 00       	mov    $0x4,%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d75:	89 f7                	mov    %esi,%edi
  800d77:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 28                	jle    800da5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d81:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d88:	00 
  800d89:	c7 44 24 08 a4 15 80 	movl   $0x8015a4,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 c1 15 80 00 	movl   $0x8015c1,(%esp)
  800da0:	e8 ab f3 ff ff       	call   800150 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800da5:	83 c4 2c             	add    $0x2c,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800db6:	b8 05 00 00 00       	mov    $0x5,%eax
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc7:	8b 75 18             	mov    0x18(%ebp),%esi
  800dca:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	7e 28                	jle    800df8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ddb:	00 
  800ddc:	c7 44 24 08 a4 15 80 	movl   $0x8015a4,0x8(%esp)
  800de3:	00 
  800de4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800deb:	00 
  800dec:	c7 04 24 c1 15 80 00 	movl   $0x8015c1,(%esp)
  800df3:	e8 58 f3 ff ff       	call   800150 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df8:	83 c4 2c             	add    $0x2c,%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	89 df                	mov    %ebx,%edi
  800e1b:	89 de                	mov    %ebx,%esi
  800e1d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	7e 28                	jle    800e4b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e27:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e2e:	00 
  800e2f:	c7 44 24 08 a4 15 80 	movl   $0x8015a4,0x8(%esp)
  800e36:	00 
  800e37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3e:	00 
  800e3f:	c7 04 24 c1 15 80 00 	movl   $0x8015c1,(%esp)
  800e46:	e8 05 f3 ff ff       	call   800150 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e4b:	83 c4 2c             	add    $0x2c,%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	57                   	push   %edi
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
  800e59:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e61:	b8 08 00 00 00       	mov    $0x8,%eax
  800e66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	89 df                	mov    %ebx,%edi
  800e6e:	89 de                	mov    %ebx,%esi
  800e70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e72:	85 c0                	test   %eax,%eax
  800e74:	7e 28                	jle    800e9e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e81:	00 
  800e82:	c7 44 24 08 a4 15 80 	movl   $0x8015a4,0x8(%esp)
  800e89:	00 
  800e8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e91:	00 
  800e92:	c7 04 24 c1 15 80 00 	movl   $0x8015c1,(%esp)
  800e99:	e8 b2 f2 ff ff       	call   800150 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e9e:	83 c4 2c             	add    $0x2c,%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800eaf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb4:	b8 09 00 00 00       	mov    $0x9,%eax
  800eb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	89 df                	mov    %ebx,%edi
  800ec1:	89 de                	mov    %ebx,%esi
  800ec3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	7e 28                	jle    800ef1 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ed4:	00 
  800ed5:	c7 44 24 08 a4 15 80 	movl   $0x8015a4,0x8(%esp)
  800edc:	00 
  800edd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee4:	00 
  800ee5:	c7 04 24 c1 15 80 00 	movl   $0x8015c1,(%esp)
  800eec:	e8 5f f2 ff ff       	call   800150 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef1:	83 c4 2c             	add    $0x2c,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eff:	be 00 00 00 00       	mov    $0x0,%esi
  800f04:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f15:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f17:	5b                   	pop    %ebx
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	57                   	push   %edi
  800f20:	56                   	push   %esi
  800f21:	53                   	push   %ebx
  800f22:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f2a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f32:	89 cb                	mov    %ecx,%ebx
  800f34:	89 cf                	mov    %ecx,%edi
  800f36:	89 ce                	mov    %ecx,%esi
  800f38:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	7e 28                	jle    800f66 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f42:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f49:	00 
  800f4a:	c7 44 24 08 a4 15 80 	movl   $0x8015a4,0x8(%esp)
  800f51:	00 
  800f52:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f59:	00 
  800f5a:	c7 04 24 c1 15 80 00 	movl   $0x8015c1,(%esp)
  800f61:	e8 ea f1 ff ff       	call   800150 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f66:	83 c4 2c             	add    $0x2c,%esp
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	5f                   	pop    %edi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    

00800f6e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f74:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800f7b:	75 70                	jne    800fed <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  800f7d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f84:	00 
  800f85:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f8c:	ee 
  800f8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f94:	e8 c0 fd ff ff       	call   800d59 <sys_page_alloc>
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	79 1c                	jns    800fb9 <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  800f9d:	c7 44 24 08 d0 15 80 	movl   $0x8015d0,0x8(%esp)
  800fa4:	00 
  800fa5:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800fac:	00 
  800fad:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  800fb4:	e8 97 f1 ff ff       	call   800150 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800fb9:	c7 44 24 04 f7 0f 80 	movl   $0x800ff7,0x4(%esp)
  800fc0:	00 
  800fc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fc8:	e8 d9 fe ff ff       	call   800ea6 <sys_env_set_pgfault_upcall>
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	79 1c                	jns    800fed <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  800fd1:	c7 44 24 08 fc 15 80 	movl   $0x8015fc,0x8(%esp)
  800fd8:	00 
  800fd9:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800fe0:	00 
  800fe1:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  800fe8:	e8 63 f1 ff ff       	call   800150 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800fed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff0:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    

00800ff7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ff7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ff8:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800ffd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800fff:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  801002:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  801006:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  80100b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  80100f:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801011:	83 c4 08             	add    $0x8,%esp
	popal
  801014:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801015:	83 c4 04             	add    $0x4,%esp
	popfl
  801018:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801019:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80101a:	c3                   	ret    
  80101b:	66 90                	xchg   %ax,%ax
  80101d:	66 90                	xchg   %ax,%ax
  80101f:	90                   	nop

00801020 <__udivdi3>:
  801020:	55                   	push   %ebp
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	8b 44 24 28          	mov    0x28(%esp),%eax
  80102a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80102e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801032:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801036:	85 c0                	test   %eax,%eax
  801038:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80103c:	89 ea                	mov    %ebp,%edx
  80103e:	89 0c 24             	mov    %ecx,(%esp)
  801041:	75 2d                	jne    801070 <__udivdi3+0x50>
  801043:	39 e9                	cmp    %ebp,%ecx
  801045:	77 61                	ja     8010a8 <__udivdi3+0x88>
  801047:	85 c9                	test   %ecx,%ecx
  801049:	89 ce                	mov    %ecx,%esi
  80104b:	75 0b                	jne    801058 <__udivdi3+0x38>
  80104d:	b8 01 00 00 00       	mov    $0x1,%eax
  801052:	31 d2                	xor    %edx,%edx
  801054:	f7 f1                	div    %ecx
  801056:	89 c6                	mov    %eax,%esi
  801058:	31 d2                	xor    %edx,%edx
  80105a:	89 e8                	mov    %ebp,%eax
  80105c:	f7 f6                	div    %esi
  80105e:	89 c5                	mov    %eax,%ebp
  801060:	89 f8                	mov    %edi,%eax
  801062:	f7 f6                	div    %esi
  801064:	89 ea                	mov    %ebp,%edx
  801066:	83 c4 0c             	add    $0xc,%esp
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    
  80106d:	8d 76 00             	lea    0x0(%esi),%esi
  801070:	39 e8                	cmp    %ebp,%eax
  801072:	77 24                	ja     801098 <__udivdi3+0x78>
  801074:	0f bd e8             	bsr    %eax,%ebp
  801077:	83 f5 1f             	xor    $0x1f,%ebp
  80107a:	75 3c                	jne    8010b8 <__udivdi3+0x98>
  80107c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801080:	39 34 24             	cmp    %esi,(%esp)
  801083:	0f 86 9f 00 00 00    	jbe    801128 <__udivdi3+0x108>
  801089:	39 d0                	cmp    %edx,%eax
  80108b:	0f 82 97 00 00 00    	jb     801128 <__udivdi3+0x108>
  801091:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801098:	31 d2                	xor    %edx,%edx
  80109a:	31 c0                	xor    %eax,%eax
  80109c:	83 c4 0c             	add    $0xc,%esp
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    
  8010a3:	90                   	nop
  8010a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010a8:	89 f8                	mov    %edi,%eax
  8010aa:	f7 f1                	div    %ecx
  8010ac:	31 d2                	xor    %edx,%edx
  8010ae:	83 c4 0c             	add    $0xc,%esp
  8010b1:	5e                   	pop    %esi
  8010b2:	5f                   	pop    %edi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    
  8010b5:	8d 76 00             	lea    0x0(%esi),%esi
  8010b8:	89 e9                	mov    %ebp,%ecx
  8010ba:	8b 3c 24             	mov    (%esp),%edi
  8010bd:	d3 e0                	shl    %cl,%eax
  8010bf:	89 c6                	mov    %eax,%esi
  8010c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8010c6:	29 e8                	sub    %ebp,%eax
  8010c8:	89 c1                	mov    %eax,%ecx
  8010ca:	d3 ef                	shr    %cl,%edi
  8010cc:	89 e9                	mov    %ebp,%ecx
  8010ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010d2:	8b 3c 24             	mov    (%esp),%edi
  8010d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8010d9:	89 d6                	mov    %edx,%esi
  8010db:	d3 e7                	shl    %cl,%edi
  8010dd:	89 c1                	mov    %eax,%ecx
  8010df:	89 3c 24             	mov    %edi,(%esp)
  8010e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010e6:	d3 ee                	shr    %cl,%esi
  8010e8:	89 e9                	mov    %ebp,%ecx
  8010ea:	d3 e2                	shl    %cl,%edx
  8010ec:	89 c1                	mov    %eax,%ecx
  8010ee:	d3 ef                	shr    %cl,%edi
  8010f0:	09 d7                	or     %edx,%edi
  8010f2:	89 f2                	mov    %esi,%edx
  8010f4:	89 f8                	mov    %edi,%eax
  8010f6:	f7 74 24 08          	divl   0x8(%esp)
  8010fa:	89 d6                	mov    %edx,%esi
  8010fc:	89 c7                	mov    %eax,%edi
  8010fe:	f7 24 24             	mull   (%esp)
  801101:	39 d6                	cmp    %edx,%esi
  801103:	89 14 24             	mov    %edx,(%esp)
  801106:	72 30                	jb     801138 <__udivdi3+0x118>
  801108:	8b 54 24 04          	mov    0x4(%esp),%edx
  80110c:	89 e9                	mov    %ebp,%ecx
  80110e:	d3 e2                	shl    %cl,%edx
  801110:	39 c2                	cmp    %eax,%edx
  801112:	73 05                	jae    801119 <__udivdi3+0xf9>
  801114:	3b 34 24             	cmp    (%esp),%esi
  801117:	74 1f                	je     801138 <__udivdi3+0x118>
  801119:	89 f8                	mov    %edi,%eax
  80111b:	31 d2                	xor    %edx,%edx
  80111d:	e9 7a ff ff ff       	jmp    80109c <__udivdi3+0x7c>
  801122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801128:	31 d2                	xor    %edx,%edx
  80112a:	b8 01 00 00 00       	mov    $0x1,%eax
  80112f:	e9 68 ff ff ff       	jmp    80109c <__udivdi3+0x7c>
  801134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801138:	8d 47 ff             	lea    -0x1(%edi),%eax
  80113b:	31 d2                	xor    %edx,%edx
  80113d:	83 c4 0c             	add    $0xc,%esp
  801140:	5e                   	pop    %esi
  801141:	5f                   	pop    %edi
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    
  801144:	66 90                	xchg   %ax,%ax
  801146:	66 90                	xchg   %ax,%ax
  801148:	66 90                	xchg   %ax,%ax
  80114a:	66 90                	xchg   %ax,%ax
  80114c:	66 90                	xchg   %ax,%ax
  80114e:	66 90                	xchg   %ax,%ax

00801150 <__umoddi3>:
  801150:	55                   	push   %ebp
  801151:	57                   	push   %edi
  801152:	56                   	push   %esi
  801153:	83 ec 14             	sub    $0x14,%esp
  801156:	8b 44 24 28          	mov    0x28(%esp),%eax
  80115a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80115e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801162:	89 c7                	mov    %eax,%edi
  801164:	89 44 24 04          	mov    %eax,0x4(%esp)
  801168:	8b 44 24 30          	mov    0x30(%esp),%eax
  80116c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801170:	89 34 24             	mov    %esi,(%esp)
  801173:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801177:	85 c0                	test   %eax,%eax
  801179:	89 c2                	mov    %eax,%edx
  80117b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80117f:	75 17                	jne    801198 <__umoddi3+0x48>
  801181:	39 fe                	cmp    %edi,%esi
  801183:	76 4b                	jbe    8011d0 <__umoddi3+0x80>
  801185:	89 c8                	mov    %ecx,%eax
  801187:	89 fa                	mov    %edi,%edx
  801189:	f7 f6                	div    %esi
  80118b:	89 d0                	mov    %edx,%eax
  80118d:	31 d2                	xor    %edx,%edx
  80118f:	83 c4 14             	add    $0x14,%esp
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    
  801196:	66 90                	xchg   %ax,%ax
  801198:	39 f8                	cmp    %edi,%eax
  80119a:	77 54                	ja     8011f0 <__umoddi3+0xa0>
  80119c:	0f bd e8             	bsr    %eax,%ebp
  80119f:	83 f5 1f             	xor    $0x1f,%ebp
  8011a2:	75 5c                	jne    801200 <__umoddi3+0xb0>
  8011a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011a8:	39 3c 24             	cmp    %edi,(%esp)
  8011ab:	0f 87 e7 00 00 00    	ja     801298 <__umoddi3+0x148>
  8011b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011b5:	29 f1                	sub    %esi,%ecx
  8011b7:	19 c7                	sbb    %eax,%edi
  8011b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8011c9:	83 c4 14             	add    $0x14,%esp
  8011cc:	5e                   	pop    %esi
  8011cd:	5f                   	pop    %edi
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    
  8011d0:	85 f6                	test   %esi,%esi
  8011d2:	89 f5                	mov    %esi,%ebp
  8011d4:	75 0b                	jne    8011e1 <__umoddi3+0x91>
  8011d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011db:	31 d2                	xor    %edx,%edx
  8011dd:	f7 f6                	div    %esi
  8011df:	89 c5                	mov    %eax,%ebp
  8011e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8011e5:	31 d2                	xor    %edx,%edx
  8011e7:	f7 f5                	div    %ebp
  8011e9:	89 c8                	mov    %ecx,%eax
  8011eb:	f7 f5                	div    %ebp
  8011ed:	eb 9c                	jmp    80118b <__umoddi3+0x3b>
  8011ef:	90                   	nop
  8011f0:	89 c8                	mov    %ecx,%eax
  8011f2:	89 fa                	mov    %edi,%edx
  8011f4:	83 c4 14             	add    $0x14,%esp
  8011f7:	5e                   	pop    %esi
  8011f8:	5f                   	pop    %edi
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    
  8011fb:	90                   	nop
  8011fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801200:	8b 04 24             	mov    (%esp),%eax
  801203:	be 20 00 00 00       	mov    $0x20,%esi
  801208:	89 e9                	mov    %ebp,%ecx
  80120a:	29 ee                	sub    %ebp,%esi
  80120c:	d3 e2                	shl    %cl,%edx
  80120e:	89 f1                	mov    %esi,%ecx
  801210:	d3 e8                	shr    %cl,%eax
  801212:	89 e9                	mov    %ebp,%ecx
  801214:	89 44 24 04          	mov    %eax,0x4(%esp)
  801218:	8b 04 24             	mov    (%esp),%eax
  80121b:	09 54 24 04          	or     %edx,0x4(%esp)
  80121f:	89 fa                	mov    %edi,%edx
  801221:	d3 e0                	shl    %cl,%eax
  801223:	89 f1                	mov    %esi,%ecx
  801225:	89 44 24 08          	mov    %eax,0x8(%esp)
  801229:	8b 44 24 10          	mov    0x10(%esp),%eax
  80122d:	d3 ea                	shr    %cl,%edx
  80122f:	89 e9                	mov    %ebp,%ecx
  801231:	d3 e7                	shl    %cl,%edi
  801233:	89 f1                	mov    %esi,%ecx
  801235:	d3 e8                	shr    %cl,%eax
  801237:	89 e9                	mov    %ebp,%ecx
  801239:	09 f8                	or     %edi,%eax
  80123b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80123f:	f7 74 24 04          	divl   0x4(%esp)
  801243:	d3 e7                	shl    %cl,%edi
  801245:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801249:	89 d7                	mov    %edx,%edi
  80124b:	f7 64 24 08          	mull   0x8(%esp)
  80124f:	39 d7                	cmp    %edx,%edi
  801251:	89 c1                	mov    %eax,%ecx
  801253:	89 14 24             	mov    %edx,(%esp)
  801256:	72 2c                	jb     801284 <__umoddi3+0x134>
  801258:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80125c:	72 22                	jb     801280 <__umoddi3+0x130>
  80125e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801262:	29 c8                	sub    %ecx,%eax
  801264:	19 d7                	sbb    %edx,%edi
  801266:	89 e9                	mov    %ebp,%ecx
  801268:	89 fa                	mov    %edi,%edx
  80126a:	d3 e8                	shr    %cl,%eax
  80126c:	89 f1                	mov    %esi,%ecx
  80126e:	d3 e2                	shl    %cl,%edx
  801270:	89 e9                	mov    %ebp,%ecx
  801272:	d3 ef                	shr    %cl,%edi
  801274:	09 d0                	or     %edx,%eax
  801276:	89 fa                	mov    %edi,%edx
  801278:	83 c4 14             	add    $0x14,%esp
  80127b:	5e                   	pop    %esi
  80127c:	5f                   	pop    %edi
  80127d:	5d                   	pop    %ebp
  80127e:	c3                   	ret    
  80127f:	90                   	nop
  801280:	39 d7                	cmp    %edx,%edi
  801282:	75 da                	jne    80125e <__umoddi3+0x10e>
  801284:	8b 14 24             	mov    (%esp),%edx
  801287:	89 c1                	mov    %eax,%ecx
  801289:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80128d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801291:	eb cb                	jmp    80125e <__umoddi3+0x10e>
  801293:	90                   	nop
  801294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801298:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80129c:	0f 82 0f ff ff ff    	jb     8011b1 <__umoddi3+0x61>
  8012a2:	e9 1a ff ff ff       	jmp    8011c1 <__umoddi3+0x71>
