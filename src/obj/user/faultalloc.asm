
obj/user/faultalloc.debug：     文件格式 elf32-i386


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
  800043:	c7 04 24 e0 21 80 00 	movl   $0x8021e0,(%esp)
  80004a:	e8 ff 01 00 00       	call   80024e <cprintf>
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
  80007a:	c7 44 24 08 00 22 80 	movl   $0x802200,0x8(%esp)
  800081:	00 
  800082:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  800089:	00 
  80008a:	c7 04 24 ea 21 80 00 	movl   $0x8021ea,(%esp)
  800091:	e8 bf 00 00 00       	call   800155 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800096:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009a:	c7 44 24 08 2c 22 80 	movl   $0x80222c,0x8(%esp)
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
  8000c5:	e8 f7 0e 00 00       	call   800fc1 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000ca:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d1:	de 
  8000d2:	c7 04 24 fc 21 80 00 	movl   $0x8021fc,(%esp)
  8000d9:	e8 70 01 00 00       	call   80024e <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000de:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e5:	ca 
  8000e6:	c7 04 24 fc 21 80 00 	movl   $0x8021fc,(%esp)
  8000ed:	e8 5c 01 00 00       	call   80024e <cprintf>
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
  800114:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800119:	85 db                	test   %ebx,%ebx
  80011b:	7e 07                	jle    800124 <libmain+0x30>
		binaryname = argv[0];
  80011d:	8b 06                	mov    (%esi),%eax
  80011f:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  800142:	e8 3f 11 00 00       	call   801286 <close_all>
	sys_env_destroy(0);
  800147:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014e:	e8 76 0b 00 00       	call   800cc9 <sys_env_destroy>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
  80015a:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 b0 0b 00 00       	call   800d1b <sys_getenvid>
  80016b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800172:	8b 55 08             	mov    0x8(%ebp),%edx
  800175:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800179:	89 74 24 08          	mov    %esi,0x8(%esp)
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	c7 04 24 58 22 80 00 	movl   $0x802258,(%esp)
  800188:	e8 c1 00 00 00       	call   80024e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800191:	8b 45 10             	mov    0x10(%ebp),%eax
  800194:	89 04 24             	mov    %eax,(%esp)
  800197:	e8 51 00 00 00       	call   8001ed <vcprintf>
	cprintf("\n");
  80019c:	c7 04 24 e8 26 80 00 	movl   $0x8026e8,(%esp)
  8001a3:	e8 a6 00 00 00       	call   80024e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a8:	cc                   	int3   
  8001a9:	eb fd                	jmp    8001a8 <_panic+0x53>

008001ab <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 14             	sub    $0x14,%esp
  8001b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b5:	8b 13                	mov    (%ebx),%edx
  8001b7:	8d 42 01             	lea    0x1(%edx),%eax
  8001ba:	89 03                	mov    %eax,(%ebx)
  8001bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001c3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c8:	75 19                	jne    8001e3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001ca:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d1:	00 
  8001d2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	e8 af 0a 00 00       	call   800c8c <sys_cputs>
		b->idx = 0;
  8001dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e7:	83 c4 14             	add    $0x14,%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fd:	00 00 00 
	b.cnt = 0;
  800200:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800207:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	89 44 24 08          	mov    %eax,0x8(%esp)
  800218:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800222:	c7 04 24 ab 01 80 00 	movl   $0x8001ab,(%esp)
  800229:	e8 b6 01 00 00       	call   8003e4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800234:	89 44 24 04          	mov    %eax,0x4(%esp)
  800238:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023e:	89 04 24             	mov    %eax,(%esp)
  800241:	e8 46 0a 00 00       	call   800c8c <sys_cputs>

	return b.cnt;
}
  800246:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800254:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025b:	8b 45 08             	mov    0x8(%ebp),%eax
  80025e:	89 04 24             	mov    %eax,(%esp)
  800261:	e8 87 ff ff ff       	call   8001ed <vcprintf>
	va_end(ap);

	return cnt;
}
  800266:	c9                   	leave  
  800267:	c3                   	ret    
  800268:	66 90                	xchg   %ax,%ax
  80026a:	66 90                	xchg   %ax,%ax
  80026c:	66 90                	xchg   %ax,%ax
  80026e:	66 90                	xchg   %ax,%ax

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
  8002ec:	e8 4f 1c 00 00       	call   801f40 <__udivdi3>
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
  800345:	e8 26 1d 00 00       	call   802070 <__umoddi3>
  80034a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034e:	0f be 80 7b 22 80 00 	movsbl 0x80227b(%eax),%eax
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
  80046c:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
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
  80051a:	83 f8 0f             	cmp    $0xf,%eax
  80051d:	7f 0b                	jg     80052a <vprintfmt+0x146>
  80051f:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 20                	jne    80054a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80052a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80052e:	c7 44 24 08 93 22 80 	movl   $0x802293,0x8(%esp)
  800535:	00 
  800536:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053a:	8b 45 08             	mov    0x8(%ebp),%eax
  80053d:	89 04 24             	mov    %eax,(%esp)
  800540:	e8 77 fe ff ff       	call   8003bc <printfmt>
  800545:	e9 c3 fe ff ff       	jmp    80040d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80054a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80054e:	c7 44 24 08 b6 26 80 	movl   $0x8026b6,0x8(%esp)
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
  80057d:	ba 8c 22 80 00       	mov    $0x80228c,%edx
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
  800cf7:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800cfe:	00 
  800cff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d06:	00 
  800d07:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800d0e:	e8 42 f4 ff ff       	call   800155 <_panic>
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
  800d45:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800d89:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800da0:	e8 b0 f3 ff ff       	call   800155 <_panic>
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
  800ddc:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800de3:	00 
  800de4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800deb:	00 
  800dec:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800df3:	e8 5d f3 ff ff       	call   800155 <_panic>
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
  800e2f:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800e36:	00 
  800e37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3e:	00 
  800e3f:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800e46:	e8 0a f3 ff ff       	call   800155 <_panic>
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
  800e82:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800e89:	00 
  800e8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e91:	00 
  800e92:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800e99:	e8 b7 f2 ff ff       	call   800155 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e9e:	83 c4 2c             	add    $0x2c,%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800ec7:	7e 28                	jle    800ef1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ed4:	00 
  800ed5:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800edc:	00 
  800edd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee4:	00 
  800ee5:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800eec:	e8 64 f2 ff ff       	call   800155 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ef1:	83 c4 2c             	add    $0x2c,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f07:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f12:	89 df                	mov    %ebx,%edi
  800f14:	89 de                	mov    %ebx,%esi
  800f16:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	7e 28                	jle    800f44 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f20:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f27:	00 
  800f28:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800f2f:	00 
  800f30:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f37:	00 
  800f38:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800f3f:	e8 11 f2 ff ff       	call   800155 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f44:	83 c4 2c             	add    $0x2c,%esp
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	57                   	push   %edi
  800f50:	56                   	push   %esi
  800f51:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f52:	be 00 00 00 00       	mov    $0x0,%esi
  800f57:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f65:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f68:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f6a:	5b                   	pop    %ebx
  800f6b:	5e                   	pop    %esi
  800f6c:	5f                   	pop    %edi
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    

00800f6f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	57                   	push   %edi
  800f73:	56                   	push   %esi
  800f74:	53                   	push   %ebx
  800f75:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f78:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f7d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f82:	8b 55 08             	mov    0x8(%ebp),%edx
  800f85:	89 cb                	mov    %ecx,%ebx
  800f87:	89 cf                	mov    %ecx,%edi
  800f89:	89 ce                	mov    %ecx,%esi
  800f8b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	7e 28                	jle    800fb9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f95:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f9c:	00 
  800f9d:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800fa4:	00 
  800fa5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fac:	00 
  800fad:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800fb4:	e8 9c f1 ff ff       	call   800155 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fb9:	83 c4 2c             	add    $0x2c,%esp
  800fbc:	5b                   	pop    %ebx
  800fbd:	5e                   	pop    %esi
  800fbe:	5f                   	pop    %edi
  800fbf:	5d                   	pop    %ebp
  800fc0:	c3                   	ret    

00800fc1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fc7:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800fce:	75 70                	jne    801040 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  800fd0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fd7:	00 
  800fd8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800fdf:	ee 
  800fe0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fe7:	e8 6d fd ff ff       	call   800d59 <sys_page_alloc>
  800fec:	85 c0                	test   %eax,%eax
  800fee:	79 1c                	jns    80100c <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  800ff0:	c7 44 24 08 ac 25 80 	movl   $0x8025ac,0x8(%esp)
  800ff7:	00 
  800ff8:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800fff:	00 
  801000:	c7 04 24 0f 26 80 00 	movl   $0x80260f,(%esp)
  801007:	e8 49 f1 ff ff       	call   800155 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80100c:	c7 44 24 04 4a 10 80 	movl   $0x80104a,0x4(%esp)
  801013:	00 
  801014:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80101b:	e8 d9 fe ff ff       	call   800ef9 <sys_env_set_pgfault_upcall>
  801020:	85 c0                	test   %eax,%eax
  801022:	79 1c                	jns    801040 <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  801024:	c7 44 24 08 d8 25 80 	movl   $0x8025d8,0x8(%esp)
  80102b:	00 
  80102c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801033:	00 
  801034:	c7 04 24 0f 26 80 00 	movl   $0x80260f,(%esp)
  80103b:	e8 15 f1 ff ff       	call   800155 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801040:	8b 45 08             	mov    0x8(%ebp),%eax
  801043:	a3 08 40 80 00       	mov    %eax,0x804008
}
  801048:	c9                   	leave  
  801049:	c3                   	ret    

0080104a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80104a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80104b:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  801050:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801052:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  801055:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  801059:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  80105e:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  801062:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801064:	83 c4 08             	add    $0x8,%esp
	popal
  801067:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801068:	83 c4 04             	add    $0x4,%esp
	popfl
  80106b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80106c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80106d:	c3                   	ret    
  80106e:	66 90                	xchg   %ax,%ax

00801070 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801073:	8b 45 08             	mov    0x8(%ebp),%eax
  801076:	05 00 00 00 30       	add    $0x30000000,%eax
  80107b:	c1 e8 0c             	shr    $0xc,%eax
}
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801083:	8b 45 08             	mov    0x8(%ebp),%eax
  801086:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80108b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801090:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    

00801097 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80109a:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80109f:	a8 01                	test   $0x1,%al
  8010a1:	74 34                	je     8010d7 <fd_alloc+0x40>
  8010a3:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8010a8:	a8 01                	test   $0x1,%al
  8010aa:	74 32                	je     8010de <fd_alloc+0x47>
  8010ac:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  8010b1:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010b3:	89 c2                	mov    %eax,%edx
  8010b5:	c1 ea 16             	shr    $0x16,%edx
  8010b8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010bf:	f6 c2 01             	test   $0x1,%dl
  8010c2:	74 1f                	je     8010e3 <fd_alloc+0x4c>
  8010c4:	89 c2                	mov    %eax,%edx
  8010c6:	c1 ea 0c             	shr    $0xc,%edx
  8010c9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d0:	f6 c2 01             	test   $0x1,%dl
  8010d3:	75 1a                	jne    8010ef <fd_alloc+0x58>
  8010d5:	eb 0c                	jmp    8010e3 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  8010d7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8010dc:	eb 05                	jmp    8010e3 <fd_alloc+0x4c>
  8010de:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  8010e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e6:	89 08                	mov    %ecx,(%eax)
			return 0;
  8010e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ed:	eb 1a                	jmp    801109 <fd_alloc+0x72>
  8010ef:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8010f4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010f9:	75 b6                	jne    8010b1 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801104:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801111:	83 f8 1f             	cmp    $0x1f,%eax
  801114:	77 36                	ja     80114c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801116:	c1 e0 0c             	shl    $0xc,%eax
  801119:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80111e:	89 c2                	mov    %eax,%edx
  801120:	c1 ea 16             	shr    $0x16,%edx
  801123:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112a:	f6 c2 01             	test   $0x1,%dl
  80112d:	74 24                	je     801153 <fd_lookup+0x48>
  80112f:	89 c2                	mov    %eax,%edx
  801131:	c1 ea 0c             	shr    $0xc,%edx
  801134:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113b:	f6 c2 01             	test   $0x1,%dl
  80113e:	74 1a                	je     80115a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801140:	8b 55 0c             	mov    0xc(%ebp),%edx
  801143:	89 02                	mov    %eax,(%edx)
	return 0;
  801145:	b8 00 00 00 00       	mov    $0x0,%eax
  80114a:	eb 13                	jmp    80115f <fd_lookup+0x54>
		return -E_INVAL;
  80114c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801151:	eb 0c                	jmp    80115f <fd_lookup+0x54>
		return -E_INVAL;
  801153:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801158:	eb 05                	jmp    80115f <fd_lookup+0x54>
  80115a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	53                   	push   %ebx
  801165:	83 ec 14             	sub    $0x14,%esp
  801168:	8b 45 08             	mov    0x8(%ebp),%eax
  80116b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80116e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801174:	75 1e                	jne    801194 <dev_lookup+0x33>
  801176:	eb 0e                	jmp    801186 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  801178:	b8 20 30 80 00       	mov    $0x803020,%eax
  80117d:	eb 0c                	jmp    80118b <dev_lookup+0x2a>
  80117f:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801184:	eb 05                	jmp    80118b <dev_lookup+0x2a>
  801186:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  80118b:	89 03                	mov    %eax,(%ebx)
			return 0;
  80118d:	b8 00 00 00 00       	mov    $0x0,%eax
  801192:	eb 38                	jmp    8011cc <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  801194:	39 05 20 30 80 00    	cmp    %eax,0x803020
  80119a:	74 dc                	je     801178 <dev_lookup+0x17>
  80119c:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  8011a2:	74 db                	je     80117f <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011a4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8011aa:	8b 52 48             	mov    0x48(%edx),%edx
  8011ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011b5:	c7 04 24 20 26 80 00 	movl   $0x802620,(%esp)
  8011bc:	e8 8d f0 ff ff       	call   80024e <cprintf>
	*dev = 0;
  8011c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8011c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011cc:	83 c4 14             	add    $0x14,%esp
  8011cf:	5b                   	pop    %ebx
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <fd_close>:
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	56                   	push   %esi
  8011d6:	53                   	push   %ebx
  8011d7:	83 ec 20             	sub    $0x20,%esp
  8011da:	8b 75 08             	mov    0x8(%ebp),%esi
  8011dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e3:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011ed:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011f0:	89 04 24             	mov    %eax,(%esp)
  8011f3:	e8 13 ff ff ff       	call   80110b <fd_lookup>
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	78 05                	js     801201 <fd_close+0x2f>
	    || fd != fd2)
  8011fc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011ff:	74 0c                	je     80120d <fd_close+0x3b>
		return (must_exist ? r : 0);
  801201:	84 db                	test   %bl,%bl
  801203:	ba 00 00 00 00       	mov    $0x0,%edx
  801208:	0f 44 c2             	cmove  %edx,%eax
  80120b:	eb 3f                	jmp    80124c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80120d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801210:	89 44 24 04          	mov    %eax,0x4(%esp)
  801214:	8b 06                	mov    (%esi),%eax
  801216:	89 04 24             	mov    %eax,(%esp)
  801219:	e8 43 ff ff ff       	call   801161 <dev_lookup>
  80121e:	89 c3                	mov    %eax,%ebx
  801220:	85 c0                	test   %eax,%eax
  801222:	78 16                	js     80123a <fd_close+0x68>
		if (dev->dev_close)
  801224:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801227:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80122a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80122f:	85 c0                	test   %eax,%eax
  801231:	74 07                	je     80123a <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801233:	89 34 24             	mov    %esi,(%esp)
  801236:	ff d0                	call   *%eax
  801238:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  80123a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80123e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801245:	e8 b6 fb ff ff       	call   800e00 <sys_page_unmap>
	return r;
  80124a:	89 d8                	mov    %ebx,%eax
}
  80124c:	83 c4 20             	add    $0x20,%esp
  80124f:	5b                   	pop    %ebx
  801250:	5e                   	pop    %esi
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <close>:

int
close(int fdnum)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801259:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801260:	8b 45 08             	mov    0x8(%ebp),%eax
  801263:	89 04 24             	mov    %eax,(%esp)
  801266:	e8 a0 fe ff ff       	call   80110b <fd_lookup>
  80126b:	89 c2                	mov    %eax,%edx
  80126d:	85 d2                	test   %edx,%edx
  80126f:	78 13                	js     801284 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801271:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801278:	00 
  801279:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127c:	89 04 24             	mov    %eax,(%esp)
  80127f:	e8 4e ff ff ff       	call   8011d2 <fd_close>
}
  801284:	c9                   	leave  
  801285:	c3                   	ret    

00801286 <close_all>:

void
close_all(void)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	53                   	push   %ebx
  80128a:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80128d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801292:	89 1c 24             	mov    %ebx,(%esp)
  801295:	e8 b9 ff ff ff       	call   801253 <close>
	for (i = 0; i < MAXFD; i++)
  80129a:	83 c3 01             	add    $0x1,%ebx
  80129d:	83 fb 20             	cmp    $0x20,%ebx
  8012a0:	75 f0                	jne    801292 <close_all+0xc>
}
  8012a2:	83 c4 14             	add    $0x14,%esp
  8012a5:	5b                   	pop    %ebx
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    

008012a8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	57                   	push   %edi
  8012ac:	56                   	push   %esi
  8012ad:	53                   	push   %ebx
  8012ae:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012b1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bb:	89 04 24             	mov    %eax,(%esp)
  8012be:	e8 48 fe ff ff       	call   80110b <fd_lookup>
  8012c3:	89 c2                	mov    %eax,%edx
  8012c5:	85 d2                	test   %edx,%edx
  8012c7:	0f 88 e1 00 00 00    	js     8013ae <dup+0x106>
		return r;
	close(newfdnum);
  8012cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d0:	89 04 24             	mov    %eax,(%esp)
  8012d3:	e8 7b ff ff ff       	call   801253 <close>

	newfd = INDEX2FD(newfdnum);
  8012d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012db:	c1 e3 0c             	shl    $0xc,%ebx
  8012de:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e7:	89 04 24             	mov    %eax,(%esp)
  8012ea:	e8 91 fd ff ff       	call   801080 <fd2data>
  8012ef:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8012f1:	89 1c 24             	mov    %ebx,(%esp)
  8012f4:	e8 87 fd ff ff       	call   801080 <fd2data>
  8012f9:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012fb:	89 f0                	mov    %esi,%eax
  8012fd:	c1 e8 16             	shr    $0x16,%eax
  801300:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801307:	a8 01                	test   $0x1,%al
  801309:	74 43                	je     80134e <dup+0xa6>
  80130b:	89 f0                	mov    %esi,%eax
  80130d:	c1 e8 0c             	shr    $0xc,%eax
  801310:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801317:	f6 c2 01             	test   $0x1,%dl
  80131a:	74 32                	je     80134e <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80131c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801323:	25 07 0e 00 00       	and    $0xe07,%eax
  801328:	89 44 24 10          	mov    %eax,0x10(%esp)
  80132c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801330:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801337:	00 
  801338:	89 74 24 04          	mov    %esi,0x4(%esp)
  80133c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801343:	e8 65 fa ff ff       	call   800dad <sys_page_map>
  801348:	89 c6                	mov    %eax,%esi
  80134a:	85 c0                	test   %eax,%eax
  80134c:	78 3e                	js     80138c <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80134e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801351:	89 c2                	mov    %eax,%edx
  801353:	c1 ea 0c             	shr    $0xc,%edx
  801356:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80135d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801363:	89 54 24 10          	mov    %edx,0x10(%esp)
  801367:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80136b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801372:	00 
  801373:	89 44 24 04          	mov    %eax,0x4(%esp)
  801377:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80137e:	e8 2a fa ff ff       	call   800dad <sys_page_map>
  801383:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801385:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801388:	85 f6                	test   %esi,%esi
  80138a:	79 22                	jns    8013ae <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80138c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801390:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801397:	e8 64 fa ff ff       	call   800e00 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80139c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013a7:	e8 54 fa ff ff       	call   800e00 <sys_page_unmap>
	return r;
  8013ac:	89 f0                	mov    %esi,%eax
}
  8013ae:	83 c4 3c             	add    $0x3c,%esp
  8013b1:	5b                   	pop    %ebx
  8013b2:	5e                   	pop    %esi
  8013b3:	5f                   	pop    %edi
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    

008013b6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	53                   	push   %ebx
  8013ba:	83 ec 24             	sub    $0x24,%esp
  8013bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c7:	89 1c 24             	mov    %ebx,(%esp)
  8013ca:	e8 3c fd ff ff       	call   80110b <fd_lookup>
  8013cf:	89 c2                	mov    %eax,%edx
  8013d1:	85 d2                	test   %edx,%edx
  8013d3:	78 6d                	js     801442 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013df:	8b 00                	mov    (%eax),%eax
  8013e1:	89 04 24             	mov    %eax,(%esp)
  8013e4:	e8 78 fd ff ff       	call   801161 <dev_lookup>
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 55                	js     801442 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f0:	8b 50 08             	mov    0x8(%eax),%edx
  8013f3:	83 e2 03             	and    $0x3,%edx
  8013f6:	83 fa 01             	cmp    $0x1,%edx
  8013f9:	75 23                	jne    80141e <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013fb:	a1 04 40 80 00       	mov    0x804004,%eax
  801400:	8b 40 48             	mov    0x48(%eax),%eax
  801403:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801407:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140b:	c7 04 24 64 26 80 00 	movl   $0x802664,(%esp)
  801412:	e8 37 ee ff ff       	call   80024e <cprintf>
		return -E_INVAL;
  801417:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141c:	eb 24                	jmp    801442 <read+0x8c>
	}
	if (!dev->dev_read)
  80141e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801421:	8b 52 08             	mov    0x8(%edx),%edx
  801424:	85 d2                	test   %edx,%edx
  801426:	74 15                	je     80143d <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801428:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80142b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80142f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801432:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801436:	89 04 24             	mov    %eax,(%esp)
  801439:	ff d2                	call   *%edx
  80143b:	eb 05                	jmp    801442 <read+0x8c>
		return -E_NOT_SUPP;
  80143d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801442:	83 c4 24             	add    $0x24,%esp
  801445:	5b                   	pop    %ebx
  801446:	5d                   	pop    %ebp
  801447:	c3                   	ret    

00801448 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	57                   	push   %edi
  80144c:	56                   	push   %esi
  80144d:	53                   	push   %ebx
  80144e:	83 ec 1c             	sub    $0x1c,%esp
  801451:	8b 7d 08             	mov    0x8(%ebp),%edi
  801454:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801457:	85 f6                	test   %esi,%esi
  801459:	74 33                	je     80148e <readn+0x46>
  80145b:	b8 00 00 00 00       	mov    $0x0,%eax
  801460:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801465:	89 f2                	mov    %esi,%edx
  801467:	29 c2                	sub    %eax,%edx
  801469:	89 54 24 08          	mov    %edx,0x8(%esp)
  80146d:	03 45 0c             	add    0xc(%ebp),%eax
  801470:	89 44 24 04          	mov    %eax,0x4(%esp)
  801474:	89 3c 24             	mov    %edi,(%esp)
  801477:	e8 3a ff ff ff       	call   8013b6 <read>
		if (m < 0)
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 1b                	js     80149b <readn+0x53>
			return m;
		if (m == 0)
  801480:	85 c0                	test   %eax,%eax
  801482:	74 11                	je     801495 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  801484:	01 c3                	add    %eax,%ebx
  801486:	89 d8                	mov    %ebx,%eax
  801488:	39 f3                	cmp    %esi,%ebx
  80148a:	72 d9                	jb     801465 <readn+0x1d>
  80148c:	eb 0b                	jmp    801499 <readn+0x51>
  80148e:	b8 00 00 00 00       	mov    $0x0,%eax
  801493:	eb 06                	jmp    80149b <readn+0x53>
  801495:	89 d8                	mov    %ebx,%eax
  801497:	eb 02                	jmp    80149b <readn+0x53>
  801499:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80149b:	83 c4 1c             	add    $0x1c,%esp
  80149e:	5b                   	pop    %ebx
  80149f:	5e                   	pop    %esi
  8014a0:	5f                   	pop    %edi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    

008014a3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	53                   	push   %ebx
  8014a7:	83 ec 24             	sub    $0x24,%esp
  8014aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b4:	89 1c 24             	mov    %ebx,(%esp)
  8014b7:	e8 4f fc ff ff       	call   80110b <fd_lookup>
  8014bc:	89 c2                	mov    %eax,%edx
  8014be:	85 d2                	test   %edx,%edx
  8014c0:	78 68                	js     80152a <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cc:	8b 00                	mov    (%eax),%eax
  8014ce:	89 04 24             	mov    %eax,(%esp)
  8014d1:	e8 8b fc ff ff       	call   801161 <dev_lookup>
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 50                	js     80152a <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014e1:	75 23                	jne    801506 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e3:	a1 04 40 80 00       	mov    0x804004,%eax
  8014e8:	8b 40 48             	mov    0x48(%eax),%eax
  8014eb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f3:	c7 04 24 80 26 80 00 	movl   $0x802680,(%esp)
  8014fa:	e8 4f ed ff ff       	call   80024e <cprintf>
		return -E_INVAL;
  8014ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801504:	eb 24                	jmp    80152a <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801506:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801509:	8b 52 0c             	mov    0xc(%edx),%edx
  80150c:	85 d2                	test   %edx,%edx
  80150e:	74 15                	je     801525 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801510:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801513:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801517:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80151a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80151e:	89 04 24             	mov    %eax,(%esp)
  801521:	ff d2                	call   *%edx
  801523:	eb 05                	jmp    80152a <write+0x87>
		return -E_NOT_SUPP;
  801525:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80152a:	83 c4 24             	add    $0x24,%esp
  80152d:	5b                   	pop    %ebx
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <seek>:

int
seek(int fdnum, off_t offset)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801536:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801539:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153d:	8b 45 08             	mov    0x8(%ebp),%eax
  801540:	89 04 24             	mov    %eax,(%esp)
  801543:	e8 c3 fb ff ff       	call   80110b <fd_lookup>
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 0e                	js     80155a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80154c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80154f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801552:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801555:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80155a:	c9                   	leave  
  80155b:	c3                   	ret    

0080155c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	53                   	push   %ebx
  801560:	83 ec 24             	sub    $0x24,%esp
  801563:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801566:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156d:	89 1c 24             	mov    %ebx,(%esp)
  801570:	e8 96 fb ff ff       	call   80110b <fd_lookup>
  801575:	89 c2                	mov    %eax,%edx
  801577:	85 d2                	test   %edx,%edx
  801579:	78 61                	js     8015dc <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801582:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801585:	8b 00                	mov    (%eax),%eax
  801587:	89 04 24             	mov    %eax,(%esp)
  80158a:	e8 d2 fb ff ff       	call   801161 <dev_lookup>
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 49                	js     8015dc <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801593:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801596:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80159a:	75 23                	jne    8015bf <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80159c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015a1:	8b 40 48             	mov    0x48(%eax),%eax
  8015a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ac:	c7 04 24 40 26 80 00 	movl   $0x802640,(%esp)
  8015b3:	e8 96 ec ff ff       	call   80024e <cprintf>
		return -E_INVAL;
  8015b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015bd:	eb 1d                	jmp    8015dc <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8015bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c2:	8b 52 18             	mov    0x18(%edx),%edx
  8015c5:	85 d2                	test   %edx,%edx
  8015c7:	74 0e                	je     8015d7 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015d0:	89 04 24             	mov    %eax,(%esp)
  8015d3:	ff d2                	call   *%edx
  8015d5:	eb 05                	jmp    8015dc <ftruncate+0x80>
		return -E_NOT_SUPP;
  8015d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8015dc:	83 c4 24             	add    $0x24,%esp
  8015df:	5b                   	pop    %ebx
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    

008015e2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 24             	sub    $0x24,%esp
  8015e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f6:	89 04 24             	mov    %eax,(%esp)
  8015f9:	e8 0d fb ff ff       	call   80110b <fd_lookup>
  8015fe:	89 c2                	mov    %eax,%edx
  801600:	85 d2                	test   %edx,%edx
  801602:	78 52                	js     801656 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801604:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801607:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160e:	8b 00                	mov    (%eax),%eax
  801610:	89 04 24             	mov    %eax,(%esp)
  801613:	e8 49 fb ff ff       	call   801161 <dev_lookup>
  801618:	85 c0                	test   %eax,%eax
  80161a:	78 3a                	js     801656 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80161c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801623:	74 2c                	je     801651 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801625:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801628:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80162f:	00 00 00 
	stat->st_isdir = 0;
  801632:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801639:	00 00 00 
	stat->st_dev = dev;
  80163c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801642:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801646:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801649:	89 14 24             	mov    %edx,(%esp)
  80164c:	ff 50 14             	call   *0x14(%eax)
  80164f:	eb 05                	jmp    801656 <fstat+0x74>
		return -E_NOT_SUPP;
  801651:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801656:	83 c4 24             	add    $0x24,%esp
  801659:	5b                   	pop    %ebx
  80165a:	5d                   	pop    %ebp
  80165b:	c3                   	ret    

0080165c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	56                   	push   %esi
  801660:	53                   	push   %ebx
  801661:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801664:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80166b:	00 
  80166c:	8b 45 08             	mov    0x8(%ebp),%eax
  80166f:	89 04 24             	mov    %eax,(%esp)
  801672:	e8 af 01 00 00       	call   801826 <open>
  801677:	89 c3                	mov    %eax,%ebx
  801679:	85 db                	test   %ebx,%ebx
  80167b:	78 1b                	js     801698 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80167d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801680:	89 44 24 04          	mov    %eax,0x4(%esp)
  801684:	89 1c 24             	mov    %ebx,(%esp)
  801687:	e8 56 ff ff ff       	call   8015e2 <fstat>
  80168c:	89 c6                	mov    %eax,%esi
	close(fd);
  80168e:	89 1c 24             	mov    %ebx,(%esp)
  801691:	e8 bd fb ff ff       	call   801253 <close>
	return r;
  801696:	89 f0                	mov    %esi,%eax
}
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	5b                   	pop    %ebx
  80169c:	5e                   	pop    %esi
  80169d:	5d                   	pop    %ebp
  80169e:	c3                   	ret    

0080169f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	56                   	push   %esi
  8016a3:	53                   	push   %ebx
  8016a4:	83 ec 10             	sub    $0x10,%esp
  8016a7:	89 c6                	mov    %eax,%esi
  8016a9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016ab:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016b2:	75 11                	jne    8016c5 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8016bb:	e8 fa 07 00 00       	call   801eba <ipc_find_env>
  8016c0:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016c5:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8016cc:	00 
  8016cd:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8016d4:	00 
  8016d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016d9:	a1 00 40 80 00       	mov    0x804000,%eax
  8016de:	89 04 24             	mov    %eax,(%esp)
  8016e1:	e8 8c 07 00 00       	call   801e72 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016ed:	00 
  8016ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f9:	e8 18 07 00 00       	call   801e16 <ipc_recv>
}
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	5b                   	pop    %ebx
  801702:	5e                   	pop    %esi
  801703:	5d                   	pop    %ebp
  801704:	c3                   	ret    

00801705 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	53                   	push   %ebx
  801709:	83 ec 14             	sub    $0x14,%esp
  80170c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80170f:	8b 45 08             	mov    0x8(%ebp),%eax
  801712:	8b 40 0c             	mov    0xc(%eax),%eax
  801715:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80171a:	ba 00 00 00 00       	mov    $0x0,%edx
  80171f:	b8 05 00 00 00       	mov    $0x5,%eax
  801724:	e8 76 ff ff ff       	call   80169f <fsipc>
  801729:	89 c2                	mov    %eax,%edx
  80172b:	85 d2                	test   %edx,%edx
  80172d:	78 2b                	js     80175a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80172f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801736:	00 
  801737:	89 1c 24             	mov    %ebx,(%esp)
  80173a:	e8 6c f1 ff ff       	call   8008ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80173f:	a1 80 50 80 00       	mov    0x805080,%eax
  801744:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80174a:	a1 84 50 80 00       	mov    0x805084,%eax
  80174f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801755:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80175a:	83 c4 14             	add    $0x14,%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5d                   	pop    %ebp
  80175f:	c3                   	ret    

00801760 <devfile_flush>:
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801766:	8b 45 08             	mov    0x8(%ebp),%eax
  801769:	8b 40 0c             	mov    0xc(%eax),%eax
  80176c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801771:	ba 00 00 00 00       	mov    $0x0,%edx
  801776:	b8 06 00 00 00       	mov    $0x6,%eax
  80177b:	e8 1f ff ff ff       	call   80169f <fsipc>
}
  801780:	c9                   	leave  
  801781:	c3                   	ret    

00801782 <devfile_read>:
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	56                   	push   %esi
  801786:	53                   	push   %ebx
  801787:	83 ec 10             	sub    $0x10,%esp
  80178a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80178d:	8b 45 08             	mov    0x8(%ebp),%eax
  801790:	8b 40 0c             	mov    0xc(%eax),%eax
  801793:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801798:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80179e:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a3:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a8:	e8 f2 fe ff ff       	call   80169f <fsipc>
  8017ad:	89 c3                	mov    %eax,%ebx
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	78 6a                	js     80181d <devfile_read+0x9b>
	assert(r <= n);
  8017b3:	39 c6                	cmp    %eax,%esi
  8017b5:	73 24                	jae    8017db <devfile_read+0x59>
  8017b7:	c7 44 24 0c 9d 26 80 	movl   $0x80269d,0xc(%esp)
  8017be:	00 
  8017bf:	c7 44 24 08 a4 26 80 	movl   $0x8026a4,0x8(%esp)
  8017c6:	00 
  8017c7:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  8017ce:	00 
  8017cf:	c7 04 24 b9 26 80 00 	movl   $0x8026b9,(%esp)
  8017d6:	e8 7a e9 ff ff       	call   800155 <_panic>
	assert(r <= PGSIZE);
  8017db:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017e0:	7e 24                	jle    801806 <devfile_read+0x84>
  8017e2:	c7 44 24 0c c4 26 80 	movl   $0x8026c4,0xc(%esp)
  8017e9:	00 
  8017ea:	c7 44 24 08 a4 26 80 	movl   $0x8026a4,0x8(%esp)
  8017f1:	00 
  8017f2:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  8017f9:	00 
  8017fa:	c7 04 24 b9 26 80 00 	movl   $0x8026b9,(%esp)
  801801:	e8 4f e9 ff ff       	call   800155 <_panic>
	memmove(buf, &fsipcbuf, r);
  801806:	89 44 24 08          	mov    %eax,0x8(%esp)
  80180a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801811:	00 
  801812:	8b 45 0c             	mov    0xc(%ebp),%eax
  801815:	89 04 24             	mov    %eax,(%esp)
  801818:	e8 89 f2 ff ff       	call   800aa6 <memmove>
}
  80181d:	89 d8                	mov    %ebx,%eax
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	5b                   	pop    %ebx
  801823:	5e                   	pop    %esi
  801824:	5d                   	pop    %ebp
  801825:	c3                   	ret    

00801826 <open>:
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	53                   	push   %ebx
  80182a:	83 ec 24             	sub    $0x24,%esp
  80182d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801830:	89 1c 24             	mov    %ebx,(%esp)
  801833:	e8 18 f0 ff ff       	call   800850 <strlen>
  801838:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80183d:	7f 60                	jg     80189f <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80183f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801842:	89 04 24             	mov    %eax,(%esp)
  801845:	e8 4d f8 ff ff       	call   801097 <fd_alloc>
  80184a:	89 c2                	mov    %eax,%edx
  80184c:	85 d2                	test   %edx,%edx
  80184e:	78 54                	js     8018a4 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801850:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801854:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80185b:	e8 4b f0 ff ff       	call   8008ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  801860:	8b 45 0c             	mov    0xc(%ebp),%eax
  801863:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801868:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80186b:	b8 01 00 00 00       	mov    $0x1,%eax
  801870:	e8 2a fe ff ff       	call   80169f <fsipc>
  801875:	89 c3                	mov    %eax,%ebx
  801877:	85 c0                	test   %eax,%eax
  801879:	79 17                	jns    801892 <open+0x6c>
		fd_close(fd, 0);
  80187b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801882:	00 
  801883:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801886:	89 04 24             	mov    %eax,(%esp)
  801889:	e8 44 f9 ff ff       	call   8011d2 <fd_close>
		return r;
  80188e:	89 d8                	mov    %ebx,%eax
  801890:	eb 12                	jmp    8018a4 <open+0x7e>
	return fd2num(fd);
  801892:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801895:	89 04 24             	mov    %eax,(%esp)
  801898:	e8 d3 f7 ff ff       	call   801070 <fd2num>
  80189d:	eb 05                	jmp    8018a4 <open+0x7e>
		return -E_BAD_PATH;
  80189f:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  8018a4:	83 c4 24             	add    $0x24,%esp
  8018a7:	5b                   	pop    %ebx
  8018a8:	5d                   	pop    %ebp
  8018a9:	c3                   	ret    
  8018aa:	66 90                	xchg   %ax,%ax
  8018ac:	66 90                	xchg   %ax,%ax
  8018ae:	66 90                	xchg   %ax,%ax

008018b0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	56                   	push   %esi
  8018b4:	53                   	push   %ebx
  8018b5:	83 ec 10             	sub    $0x10,%esp
  8018b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	89 04 24             	mov    %eax,(%esp)
  8018c1:	e8 ba f7 ff ff       	call   801080 <fd2data>
  8018c6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018c8:	c7 44 24 04 d0 26 80 	movl   $0x8026d0,0x4(%esp)
  8018cf:	00 
  8018d0:	89 1c 24             	mov    %ebx,(%esp)
  8018d3:	e8 d3 ef ff ff       	call   8008ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018d8:	8b 46 04             	mov    0x4(%esi),%eax
  8018db:	2b 06                	sub    (%esi),%eax
  8018dd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018e3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018ea:	00 00 00 
	stat->st_dev = &devpipe;
  8018ed:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018f4:	30 80 00 
	return 0;
}
  8018f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	5b                   	pop    %ebx
  801900:	5e                   	pop    %esi
  801901:	5d                   	pop    %ebp
  801902:	c3                   	ret    

00801903 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	53                   	push   %ebx
  801907:	83 ec 14             	sub    $0x14,%esp
  80190a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80190d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801911:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801918:	e8 e3 f4 ff ff       	call   800e00 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80191d:	89 1c 24             	mov    %ebx,(%esp)
  801920:	e8 5b f7 ff ff       	call   801080 <fd2data>
  801925:	89 44 24 04          	mov    %eax,0x4(%esp)
  801929:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801930:	e8 cb f4 ff ff       	call   800e00 <sys_page_unmap>
}
  801935:	83 c4 14             	add    $0x14,%esp
  801938:	5b                   	pop    %ebx
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    

0080193b <_pipeisclosed>:
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	57                   	push   %edi
  80193f:	56                   	push   %esi
  801940:	53                   	push   %ebx
  801941:	83 ec 2c             	sub    $0x2c,%esp
  801944:	89 c6                	mov    %eax,%esi
  801946:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801949:	a1 04 40 80 00       	mov    0x804004,%eax
  80194e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801951:	89 34 24             	mov    %esi,(%esp)
  801954:	e8 a9 05 00 00       	call   801f02 <pageref>
  801959:	89 c7                	mov    %eax,%edi
  80195b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80195e:	89 04 24             	mov    %eax,(%esp)
  801961:	e8 9c 05 00 00       	call   801f02 <pageref>
  801966:	39 c7                	cmp    %eax,%edi
  801968:	0f 94 c2             	sete   %dl
  80196b:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80196e:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801974:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801977:	39 fb                	cmp    %edi,%ebx
  801979:	74 21                	je     80199c <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  80197b:	84 d2                	test   %dl,%dl
  80197d:	74 ca                	je     801949 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80197f:	8b 51 58             	mov    0x58(%ecx),%edx
  801982:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801986:	89 54 24 08          	mov    %edx,0x8(%esp)
  80198a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80198e:	c7 04 24 d7 26 80 00 	movl   $0x8026d7,(%esp)
  801995:	e8 b4 e8 ff ff       	call   80024e <cprintf>
  80199a:	eb ad                	jmp    801949 <_pipeisclosed+0xe>
}
  80199c:	83 c4 2c             	add    $0x2c,%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5e                   	pop    %esi
  8019a1:	5f                   	pop    %edi
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    

008019a4 <devpipe_write>:
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	57                   	push   %edi
  8019a8:	56                   	push   %esi
  8019a9:	53                   	push   %ebx
  8019aa:	83 ec 1c             	sub    $0x1c,%esp
  8019ad:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8019b0:	89 34 24             	mov    %esi,(%esp)
  8019b3:	e8 c8 f6 ff ff       	call   801080 <fd2data>
	for (i = 0; i < n; i++) {
  8019b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019bc:	74 61                	je     801a1f <devpipe_write+0x7b>
  8019be:	89 c3                	mov    %eax,%ebx
  8019c0:	bf 00 00 00 00       	mov    $0x0,%edi
  8019c5:	eb 4a                	jmp    801a11 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  8019c7:	89 da                	mov    %ebx,%edx
  8019c9:	89 f0                	mov    %esi,%eax
  8019cb:	e8 6b ff ff ff       	call   80193b <_pipeisclosed>
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	75 54                	jne    801a28 <devpipe_write+0x84>
			sys_yield();
  8019d4:	e8 61 f3 ff ff       	call   800d3a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019d9:	8b 43 04             	mov    0x4(%ebx),%eax
  8019dc:	8b 0b                	mov    (%ebx),%ecx
  8019de:	8d 51 20             	lea    0x20(%ecx),%edx
  8019e1:	39 d0                	cmp    %edx,%eax
  8019e3:	73 e2                	jae    8019c7 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019ec:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019ef:	99                   	cltd   
  8019f0:	c1 ea 1b             	shr    $0x1b,%edx
  8019f3:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8019f6:	83 e1 1f             	and    $0x1f,%ecx
  8019f9:	29 d1                	sub    %edx,%ecx
  8019fb:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8019ff:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801a03:	83 c0 01             	add    $0x1,%eax
  801a06:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801a09:	83 c7 01             	add    $0x1,%edi
  801a0c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a0f:	74 13                	je     801a24 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a11:	8b 43 04             	mov    0x4(%ebx),%eax
  801a14:	8b 0b                	mov    (%ebx),%ecx
  801a16:	8d 51 20             	lea    0x20(%ecx),%edx
  801a19:	39 d0                	cmp    %edx,%eax
  801a1b:	73 aa                	jae    8019c7 <devpipe_write+0x23>
  801a1d:	eb c6                	jmp    8019e5 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  801a1f:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  801a24:	89 f8                	mov    %edi,%eax
  801a26:	eb 05                	jmp    801a2d <devpipe_write+0x89>
				return 0;
  801a28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a2d:	83 c4 1c             	add    $0x1c,%esp
  801a30:	5b                   	pop    %ebx
  801a31:	5e                   	pop    %esi
  801a32:	5f                   	pop    %edi
  801a33:	5d                   	pop    %ebp
  801a34:	c3                   	ret    

00801a35 <devpipe_read>:
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	57                   	push   %edi
  801a39:	56                   	push   %esi
  801a3a:	53                   	push   %ebx
  801a3b:	83 ec 1c             	sub    $0x1c,%esp
  801a3e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a41:	89 3c 24             	mov    %edi,(%esp)
  801a44:	e8 37 f6 ff ff       	call   801080 <fd2data>
	for (i = 0; i < n; i++) {
  801a49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a4d:	74 54                	je     801aa3 <devpipe_read+0x6e>
  801a4f:	89 c3                	mov    %eax,%ebx
  801a51:	be 00 00 00 00       	mov    $0x0,%esi
  801a56:	eb 3e                	jmp    801a96 <devpipe_read+0x61>
				return i;
  801a58:	89 f0                	mov    %esi,%eax
  801a5a:	eb 55                	jmp    801ab1 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  801a5c:	89 da                	mov    %ebx,%edx
  801a5e:	89 f8                	mov    %edi,%eax
  801a60:	e8 d6 fe ff ff       	call   80193b <_pipeisclosed>
  801a65:	85 c0                	test   %eax,%eax
  801a67:	75 43                	jne    801aac <devpipe_read+0x77>
			sys_yield();
  801a69:	e8 cc f2 ff ff       	call   800d3a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801a6e:	8b 03                	mov    (%ebx),%eax
  801a70:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a73:	74 e7                	je     801a5c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a75:	99                   	cltd   
  801a76:	c1 ea 1b             	shr    $0x1b,%edx
  801a79:	01 d0                	add    %edx,%eax
  801a7b:	83 e0 1f             	and    $0x1f,%eax
  801a7e:	29 d0                	sub    %edx,%eax
  801a80:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a88:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a8b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801a8e:	83 c6 01             	add    $0x1,%esi
  801a91:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a94:	74 12                	je     801aa8 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  801a96:	8b 03                	mov    (%ebx),%eax
  801a98:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a9b:	75 d8                	jne    801a75 <devpipe_read+0x40>
			if (i > 0)
  801a9d:	85 f6                	test   %esi,%esi
  801a9f:	75 b7                	jne    801a58 <devpipe_read+0x23>
  801aa1:	eb b9                	jmp    801a5c <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  801aa3:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  801aa8:	89 f0                	mov    %esi,%eax
  801aaa:	eb 05                	jmp    801ab1 <devpipe_read+0x7c>
				return 0;
  801aac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab1:	83 c4 1c             	add    $0x1c,%esp
  801ab4:	5b                   	pop    %ebx
  801ab5:	5e                   	pop    %esi
  801ab6:	5f                   	pop    %edi
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    

00801ab9 <pipe>:
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	56                   	push   %esi
  801abd:	53                   	push   %ebx
  801abe:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ac1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac4:	89 04 24             	mov    %eax,(%esp)
  801ac7:	e8 cb f5 ff ff       	call   801097 <fd_alloc>
  801acc:	89 c2                	mov    %eax,%edx
  801ace:	85 d2                	test   %edx,%edx
  801ad0:	0f 88 4d 01 00 00    	js     801c23 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801add:	00 
  801ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aec:	e8 68 f2 ff ff       	call   800d59 <sys_page_alloc>
  801af1:	89 c2                	mov    %eax,%edx
  801af3:	85 d2                	test   %edx,%edx
  801af5:	0f 88 28 01 00 00    	js     801c23 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801afb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801afe:	89 04 24             	mov    %eax,(%esp)
  801b01:	e8 91 f5 ff ff       	call   801097 <fd_alloc>
  801b06:	89 c3                	mov    %eax,%ebx
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	0f 88 fe 00 00 00    	js     801c0e <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b10:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b17:	00 
  801b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b26:	e8 2e f2 ff ff       	call   800d59 <sys_page_alloc>
  801b2b:	89 c3                	mov    %eax,%ebx
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	0f 88 d9 00 00 00    	js     801c0e <pipe+0x155>
	va = fd2data(fd0);
  801b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b38:	89 04 24             	mov    %eax,(%esp)
  801b3b:	e8 40 f5 ff ff       	call   801080 <fd2data>
  801b40:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b42:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b49:	00 
  801b4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b55:	e8 ff f1 ff ff       	call   800d59 <sys_page_alloc>
  801b5a:	89 c3                	mov    %eax,%ebx
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	0f 88 97 00 00 00    	js     801bfb <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b67:	89 04 24             	mov    %eax,(%esp)
  801b6a:	e8 11 f5 ff ff       	call   801080 <fd2data>
  801b6f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b76:	00 
  801b77:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b7b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b82:	00 
  801b83:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b8e:	e8 1a f2 ff ff       	call   800dad <sys_page_map>
  801b93:	89 c3                	mov    %eax,%ebx
  801b95:	85 c0                	test   %eax,%eax
  801b97:	78 52                	js     801beb <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801b99:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801bae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bb7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bbc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc6:	89 04 24             	mov    %eax,(%esp)
  801bc9:	e8 a2 f4 ff ff       	call   801070 <fd2num>
  801bce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bd6:	89 04 24             	mov    %eax,(%esp)
  801bd9:	e8 92 f4 ff ff       	call   801070 <fd2num>
  801bde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801be4:	b8 00 00 00 00       	mov    $0x0,%eax
  801be9:	eb 38                	jmp    801c23 <pipe+0x16a>
	sys_page_unmap(0, va);
  801beb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf6:	e8 05 f2 ff ff       	call   800e00 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c09:	e8 f2 f1 ff ff       	call   800e00 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c1c:	e8 df f1 ff ff       	call   800e00 <sys_page_unmap>
  801c21:	89 d8                	mov    %ebx,%eax
}
  801c23:	83 c4 30             	add    $0x30,%esp
  801c26:	5b                   	pop    %ebx
  801c27:	5e                   	pop    %esi
  801c28:	5d                   	pop    %ebp
  801c29:	c3                   	ret    

00801c2a <pipeisclosed>:
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c37:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3a:	89 04 24             	mov    %eax,(%esp)
  801c3d:	e8 c9 f4 ff ff       	call   80110b <fd_lookup>
  801c42:	89 c2                	mov    %eax,%edx
  801c44:	85 d2                	test   %edx,%edx
  801c46:	78 15                	js     801c5d <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4b:	89 04 24             	mov    %eax,(%esp)
  801c4e:	e8 2d f4 ff ff       	call   801080 <fd2data>
	return _pipeisclosed(fd, p);
  801c53:	89 c2                	mov    %eax,%edx
  801c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c58:	e8 de fc ff ff       	call   80193b <_pipeisclosed>
}
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    
  801c5f:	90                   	nop

00801c60 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c63:	b8 00 00 00 00       	mov    $0x0,%eax
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    

00801c6a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801c70:	c7 44 24 04 ef 26 80 	movl   $0x8026ef,0x4(%esp)
  801c77:	00 
  801c78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7b:	89 04 24             	mov    %eax,(%esp)
  801c7e:	e8 28 ec ff ff       	call   8008ab <strcpy>
	return 0;
}
  801c83:	b8 00 00 00 00       	mov    $0x0,%eax
  801c88:	c9                   	leave  
  801c89:	c3                   	ret    

00801c8a <devcons_write>:
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	57                   	push   %edi
  801c8e:	56                   	push   %esi
  801c8f:	53                   	push   %ebx
  801c90:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c9a:	74 4a                	je     801ce6 <devcons_write+0x5c>
  801c9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca1:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ca6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  801cac:	8b 75 10             	mov    0x10(%ebp),%esi
  801caf:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  801cb1:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801cb4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cb9:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801cbc:	89 74 24 08          	mov    %esi,0x8(%esp)
  801cc0:	03 45 0c             	add    0xc(%ebp),%eax
  801cc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc7:	89 3c 24             	mov    %edi,(%esp)
  801cca:	e8 d7 ed ff ff       	call   800aa6 <memmove>
		sys_cputs(buf, m);
  801ccf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cd3:	89 3c 24             	mov    %edi,(%esp)
  801cd6:	e8 b1 ef ff ff       	call   800c8c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801cdb:	01 f3                	add    %esi,%ebx
  801cdd:	89 d8                	mov    %ebx,%eax
  801cdf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ce2:	72 c8                	jb     801cac <devcons_write+0x22>
  801ce4:	eb 05                	jmp    801ceb <devcons_write+0x61>
  801ce6:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  801ceb:	89 d8                	mov    %ebx,%eax
  801ced:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5f                   	pop    %edi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    

00801cf8 <devcons_read>:
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801cfe:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d03:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d07:	75 07                	jne    801d10 <devcons_read+0x18>
  801d09:	eb 28                	jmp    801d33 <devcons_read+0x3b>
		sys_yield();
  801d0b:	e8 2a f0 ff ff       	call   800d3a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801d10:	e8 95 ef ff ff       	call   800caa <sys_cgetc>
  801d15:	85 c0                	test   %eax,%eax
  801d17:	74 f2                	je     801d0b <devcons_read+0x13>
	if (c < 0)
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	78 16                	js     801d33 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  801d1d:	83 f8 04             	cmp    $0x4,%eax
  801d20:	74 0c                	je     801d2e <devcons_read+0x36>
	*(char*)vbuf = c;
  801d22:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d25:	88 02                	mov    %al,(%edx)
	return 1;
  801d27:	b8 01 00 00 00       	mov    $0x1,%eax
  801d2c:	eb 05                	jmp    801d33 <devcons_read+0x3b>
		return 0;
  801d2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    

00801d35 <cputchar>:
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d41:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d48:	00 
  801d49:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d4c:	89 04 24             	mov    %eax,(%esp)
  801d4f:	e8 38 ef ff ff       	call   800c8c <sys_cputs>
}
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <getchar>:
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801d5c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801d63:	00 
  801d64:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d72:	e8 3f f6 ff ff       	call   8013b6 <read>
	if (r < 0)
  801d77:	85 c0                	test   %eax,%eax
  801d79:	78 0f                	js     801d8a <getchar+0x34>
	if (r < 1)
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	7e 06                	jle    801d85 <getchar+0x2f>
	return c;
  801d7f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d83:	eb 05                	jmp    801d8a <getchar+0x34>
		return -E_EOF;
  801d85:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801d8a:	c9                   	leave  
  801d8b:	c3                   	ret    

00801d8c <iscons>:
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d99:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9c:	89 04 24             	mov    %eax,(%esp)
  801d9f:	e8 67 f3 ff ff       	call   80110b <fd_lookup>
  801da4:	85 c0                	test   %eax,%eax
  801da6:	78 11                	js     801db9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801db1:	39 10                	cmp    %edx,(%eax)
  801db3:	0f 94 c0             	sete   %al
  801db6:	0f b6 c0             	movzbl %al,%eax
}
  801db9:	c9                   	leave  
  801dba:	c3                   	ret    

00801dbb <opencons>:
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801dc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc4:	89 04 24             	mov    %eax,(%esp)
  801dc7:	e8 cb f2 ff ff       	call   801097 <fd_alloc>
		return r;
  801dcc:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 40                	js     801e12 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dd2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dd9:	00 
  801dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801de8:	e8 6c ef ff ff       	call   800d59 <sys_page_alloc>
		return r;
  801ded:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801def:	85 c0                	test   %eax,%eax
  801df1:	78 1f                	js     801e12 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801df3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e01:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e08:	89 04 24             	mov    %eax,(%esp)
  801e0b:	e8 60 f2 ff ff       	call   801070 <fd2num>
  801e10:	89 c2                	mov    %eax,%edx
}
  801e12:	89 d0                	mov    %edx,%eax
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    

00801e16 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	56                   	push   %esi
  801e1a:	53                   	push   %ebx
  801e1b:	83 ec 10             	sub    $0x10,%esp
  801e1e:	8b 75 08             	mov    0x8(%ebp),%esi
  801e21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  801e24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e27:	89 04 24             	mov    %eax,(%esp)
  801e2a:	e8 40 f1 ff ff       	call   800f6f <sys_ipc_recv>
	if(from_env_store)
  801e2f:	85 f6                	test   %esi,%esi
  801e31:	74 14                	je     801e47 <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  801e33:	ba 00 00 00 00       	mov    $0x0,%edx
  801e38:	85 c0                	test   %eax,%eax
  801e3a:	78 09                	js     801e45 <ipc_recv+0x2f>
  801e3c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e42:	8b 52 74             	mov    0x74(%edx),%edx
  801e45:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  801e47:	85 db                	test   %ebx,%ebx
  801e49:	74 14                	je     801e5f <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  801e4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801e50:	85 c0                	test   %eax,%eax
  801e52:	78 09                	js     801e5d <ipc_recv+0x47>
  801e54:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e5a:	8b 52 78             	mov    0x78(%edx),%edx
  801e5d:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  801e5f:	85 c0                	test   %eax,%eax
  801e61:	78 08                	js     801e6b <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  801e63:	a1 04 40 80 00       	mov    0x804004,%eax
  801e68:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e6b:	83 c4 10             	add    $0x10,%esp
  801e6e:	5b                   	pop    %ebx
  801e6f:	5e                   	pop    %esi
  801e70:	5d                   	pop    %ebp
  801e71:	c3                   	ret    

00801e72 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	57                   	push   %edi
  801e76:	56                   	push   %esi
  801e77:	53                   	push   %ebx
  801e78:	83 ec 1c             	sub    $0x1c,%esp
  801e7b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e7e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  801e81:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801e86:	eb 0c                	jmp    801e94 <ipc_send+0x22>
		failed_cnt++;
  801e88:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  801e8b:	84 db                	test   %bl,%bl
  801e8d:	75 05                	jne    801e94 <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  801e8f:	e8 a6 ee ff ff       	call   800d3a <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801e94:	8b 45 14             	mov    0x14(%ebp),%eax
  801e97:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e9b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ea2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ea6:	89 3c 24             	mov    %edi,(%esp)
  801ea9:	e8 9e f0 ff ff       	call   800f4c <sys_ipc_try_send>
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	78 d6                	js     801e88 <ipc_send+0x16>
	}
}
  801eb2:	83 c4 1c             	add    $0x1c,%esp
  801eb5:	5b                   	pop    %ebx
  801eb6:	5e                   	pop    %esi
  801eb7:	5f                   	pop    %edi
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    

00801eba <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ec0:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801ec5:	39 c8                	cmp    %ecx,%eax
  801ec7:	74 17                	je     801ee0 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  801ec9:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ece:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ed1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ed7:	8b 52 50             	mov    0x50(%edx),%edx
  801eda:	39 ca                	cmp    %ecx,%edx
  801edc:	75 14                	jne    801ef2 <ipc_find_env+0x38>
  801ede:	eb 05                	jmp    801ee5 <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  801ee0:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  801ee5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ee8:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801eed:	8b 40 40             	mov    0x40(%eax),%eax
  801ef0:	eb 0e                	jmp    801f00 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  801ef2:	83 c0 01             	add    $0x1,%eax
  801ef5:	3d 00 04 00 00       	cmp    $0x400,%eax
  801efa:	75 d2                	jne    801ece <ipc_find_env+0x14>
	return 0;
  801efc:	66 b8 00 00          	mov    $0x0,%ax
}
  801f00:	5d                   	pop    %ebp
  801f01:	c3                   	ret    

00801f02 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f08:	89 d0                	mov    %edx,%eax
  801f0a:	c1 e8 16             	shr    $0x16,%eax
  801f0d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f14:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f19:	f6 c1 01             	test   $0x1,%cl
  801f1c:	74 1d                	je     801f3b <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f1e:	c1 ea 0c             	shr    $0xc,%edx
  801f21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f28:	f6 c2 01             	test   $0x1,%dl
  801f2b:	74 0e                	je     801f3b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f2d:	c1 ea 0c             	shr    $0xc,%edx
  801f30:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f37:	ef 
  801f38:	0f b7 c0             	movzwl %ax,%eax
}
  801f3b:	5d                   	pop    %ebp
  801f3c:	c3                   	ret    
  801f3d:	66 90                	xchg   %ax,%ax
  801f3f:	90                   	nop

00801f40 <__udivdi3>:
  801f40:	55                   	push   %ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	83 ec 0c             	sub    $0xc,%esp
  801f46:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f4a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801f4e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801f52:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f56:	85 c0                	test   %eax,%eax
  801f58:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f5c:	89 ea                	mov    %ebp,%edx
  801f5e:	89 0c 24             	mov    %ecx,(%esp)
  801f61:	75 2d                	jne    801f90 <__udivdi3+0x50>
  801f63:	39 e9                	cmp    %ebp,%ecx
  801f65:	77 61                	ja     801fc8 <__udivdi3+0x88>
  801f67:	85 c9                	test   %ecx,%ecx
  801f69:	89 ce                	mov    %ecx,%esi
  801f6b:	75 0b                	jne    801f78 <__udivdi3+0x38>
  801f6d:	b8 01 00 00 00       	mov    $0x1,%eax
  801f72:	31 d2                	xor    %edx,%edx
  801f74:	f7 f1                	div    %ecx
  801f76:	89 c6                	mov    %eax,%esi
  801f78:	31 d2                	xor    %edx,%edx
  801f7a:	89 e8                	mov    %ebp,%eax
  801f7c:	f7 f6                	div    %esi
  801f7e:	89 c5                	mov    %eax,%ebp
  801f80:	89 f8                	mov    %edi,%eax
  801f82:	f7 f6                	div    %esi
  801f84:	89 ea                	mov    %ebp,%edx
  801f86:	83 c4 0c             	add    $0xc,%esp
  801f89:	5e                   	pop    %esi
  801f8a:	5f                   	pop    %edi
  801f8b:	5d                   	pop    %ebp
  801f8c:	c3                   	ret    
  801f8d:	8d 76 00             	lea    0x0(%esi),%esi
  801f90:	39 e8                	cmp    %ebp,%eax
  801f92:	77 24                	ja     801fb8 <__udivdi3+0x78>
  801f94:	0f bd e8             	bsr    %eax,%ebp
  801f97:	83 f5 1f             	xor    $0x1f,%ebp
  801f9a:	75 3c                	jne    801fd8 <__udivdi3+0x98>
  801f9c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801fa0:	39 34 24             	cmp    %esi,(%esp)
  801fa3:	0f 86 9f 00 00 00    	jbe    802048 <__udivdi3+0x108>
  801fa9:	39 d0                	cmp    %edx,%eax
  801fab:	0f 82 97 00 00 00    	jb     802048 <__udivdi3+0x108>
  801fb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	31 d2                	xor    %edx,%edx
  801fba:	31 c0                	xor    %eax,%eax
  801fbc:	83 c4 0c             	add    $0xc,%esp
  801fbf:	5e                   	pop    %esi
  801fc0:	5f                   	pop    %edi
  801fc1:	5d                   	pop    %ebp
  801fc2:	c3                   	ret    
  801fc3:	90                   	nop
  801fc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fc8:	89 f8                	mov    %edi,%eax
  801fca:	f7 f1                	div    %ecx
  801fcc:	31 d2                	xor    %edx,%edx
  801fce:	83 c4 0c             	add    $0xc,%esp
  801fd1:	5e                   	pop    %esi
  801fd2:	5f                   	pop    %edi
  801fd3:	5d                   	pop    %ebp
  801fd4:	c3                   	ret    
  801fd5:	8d 76 00             	lea    0x0(%esi),%esi
  801fd8:	89 e9                	mov    %ebp,%ecx
  801fda:	8b 3c 24             	mov    (%esp),%edi
  801fdd:	d3 e0                	shl    %cl,%eax
  801fdf:	89 c6                	mov    %eax,%esi
  801fe1:	b8 20 00 00 00       	mov    $0x20,%eax
  801fe6:	29 e8                	sub    %ebp,%eax
  801fe8:	89 c1                	mov    %eax,%ecx
  801fea:	d3 ef                	shr    %cl,%edi
  801fec:	89 e9                	mov    %ebp,%ecx
  801fee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801ff2:	8b 3c 24             	mov    (%esp),%edi
  801ff5:	09 74 24 08          	or     %esi,0x8(%esp)
  801ff9:	89 d6                	mov    %edx,%esi
  801ffb:	d3 e7                	shl    %cl,%edi
  801ffd:	89 c1                	mov    %eax,%ecx
  801fff:	89 3c 24             	mov    %edi,(%esp)
  802002:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802006:	d3 ee                	shr    %cl,%esi
  802008:	89 e9                	mov    %ebp,%ecx
  80200a:	d3 e2                	shl    %cl,%edx
  80200c:	89 c1                	mov    %eax,%ecx
  80200e:	d3 ef                	shr    %cl,%edi
  802010:	09 d7                	or     %edx,%edi
  802012:	89 f2                	mov    %esi,%edx
  802014:	89 f8                	mov    %edi,%eax
  802016:	f7 74 24 08          	divl   0x8(%esp)
  80201a:	89 d6                	mov    %edx,%esi
  80201c:	89 c7                	mov    %eax,%edi
  80201e:	f7 24 24             	mull   (%esp)
  802021:	39 d6                	cmp    %edx,%esi
  802023:	89 14 24             	mov    %edx,(%esp)
  802026:	72 30                	jb     802058 <__udivdi3+0x118>
  802028:	8b 54 24 04          	mov    0x4(%esp),%edx
  80202c:	89 e9                	mov    %ebp,%ecx
  80202e:	d3 e2                	shl    %cl,%edx
  802030:	39 c2                	cmp    %eax,%edx
  802032:	73 05                	jae    802039 <__udivdi3+0xf9>
  802034:	3b 34 24             	cmp    (%esp),%esi
  802037:	74 1f                	je     802058 <__udivdi3+0x118>
  802039:	89 f8                	mov    %edi,%eax
  80203b:	31 d2                	xor    %edx,%edx
  80203d:	e9 7a ff ff ff       	jmp    801fbc <__udivdi3+0x7c>
  802042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802048:	31 d2                	xor    %edx,%edx
  80204a:	b8 01 00 00 00       	mov    $0x1,%eax
  80204f:	e9 68 ff ff ff       	jmp    801fbc <__udivdi3+0x7c>
  802054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802058:	8d 47 ff             	lea    -0x1(%edi),%eax
  80205b:	31 d2                	xor    %edx,%edx
  80205d:	83 c4 0c             	add    $0xc,%esp
  802060:	5e                   	pop    %esi
  802061:	5f                   	pop    %edi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    
  802064:	66 90                	xchg   %ax,%ax
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__umoddi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	83 ec 14             	sub    $0x14,%esp
  802076:	8b 44 24 28          	mov    0x28(%esp),%eax
  80207a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80207e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802082:	89 c7                	mov    %eax,%edi
  802084:	89 44 24 04          	mov    %eax,0x4(%esp)
  802088:	8b 44 24 30          	mov    0x30(%esp),%eax
  80208c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802090:	89 34 24             	mov    %esi,(%esp)
  802093:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802097:	85 c0                	test   %eax,%eax
  802099:	89 c2                	mov    %eax,%edx
  80209b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80209f:	75 17                	jne    8020b8 <__umoddi3+0x48>
  8020a1:	39 fe                	cmp    %edi,%esi
  8020a3:	76 4b                	jbe    8020f0 <__umoddi3+0x80>
  8020a5:	89 c8                	mov    %ecx,%eax
  8020a7:	89 fa                	mov    %edi,%edx
  8020a9:	f7 f6                	div    %esi
  8020ab:	89 d0                	mov    %edx,%eax
  8020ad:	31 d2                	xor    %edx,%edx
  8020af:	83 c4 14             	add    $0x14,%esp
  8020b2:	5e                   	pop    %esi
  8020b3:	5f                   	pop    %edi
  8020b4:	5d                   	pop    %ebp
  8020b5:	c3                   	ret    
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	39 f8                	cmp    %edi,%eax
  8020ba:	77 54                	ja     802110 <__umoddi3+0xa0>
  8020bc:	0f bd e8             	bsr    %eax,%ebp
  8020bf:	83 f5 1f             	xor    $0x1f,%ebp
  8020c2:	75 5c                	jne    802120 <__umoddi3+0xb0>
  8020c4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8020c8:	39 3c 24             	cmp    %edi,(%esp)
  8020cb:	0f 87 e7 00 00 00    	ja     8021b8 <__umoddi3+0x148>
  8020d1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8020d5:	29 f1                	sub    %esi,%ecx
  8020d7:	19 c7                	sbb    %eax,%edi
  8020d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020e1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020e5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020e9:	83 c4 14             	add    $0x14,%esp
  8020ec:	5e                   	pop    %esi
  8020ed:	5f                   	pop    %edi
  8020ee:	5d                   	pop    %ebp
  8020ef:	c3                   	ret    
  8020f0:	85 f6                	test   %esi,%esi
  8020f2:	89 f5                	mov    %esi,%ebp
  8020f4:	75 0b                	jne    802101 <__umoddi3+0x91>
  8020f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	f7 f6                	div    %esi
  8020ff:	89 c5                	mov    %eax,%ebp
  802101:	8b 44 24 04          	mov    0x4(%esp),%eax
  802105:	31 d2                	xor    %edx,%edx
  802107:	f7 f5                	div    %ebp
  802109:	89 c8                	mov    %ecx,%eax
  80210b:	f7 f5                	div    %ebp
  80210d:	eb 9c                	jmp    8020ab <__umoddi3+0x3b>
  80210f:	90                   	nop
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 fa                	mov    %edi,%edx
  802114:	83 c4 14             	add    $0x14,%esp
  802117:	5e                   	pop    %esi
  802118:	5f                   	pop    %edi
  802119:	5d                   	pop    %ebp
  80211a:	c3                   	ret    
  80211b:	90                   	nop
  80211c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802120:	8b 04 24             	mov    (%esp),%eax
  802123:	be 20 00 00 00       	mov    $0x20,%esi
  802128:	89 e9                	mov    %ebp,%ecx
  80212a:	29 ee                	sub    %ebp,%esi
  80212c:	d3 e2                	shl    %cl,%edx
  80212e:	89 f1                	mov    %esi,%ecx
  802130:	d3 e8                	shr    %cl,%eax
  802132:	89 e9                	mov    %ebp,%ecx
  802134:	89 44 24 04          	mov    %eax,0x4(%esp)
  802138:	8b 04 24             	mov    (%esp),%eax
  80213b:	09 54 24 04          	or     %edx,0x4(%esp)
  80213f:	89 fa                	mov    %edi,%edx
  802141:	d3 e0                	shl    %cl,%eax
  802143:	89 f1                	mov    %esi,%ecx
  802145:	89 44 24 08          	mov    %eax,0x8(%esp)
  802149:	8b 44 24 10          	mov    0x10(%esp),%eax
  80214d:	d3 ea                	shr    %cl,%edx
  80214f:	89 e9                	mov    %ebp,%ecx
  802151:	d3 e7                	shl    %cl,%edi
  802153:	89 f1                	mov    %esi,%ecx
  802155:	d3 e8                	shr    %cl,%eax
  802157:	89 e9                	mov    %ebp,%ecx
  802159:	09 f8                	or     %edi,%eax
  80215b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80215f:	f7 74 24 04          	divl   0x4(%esp)
  802163:	d3 e7                	shl    %cl,%edi
  802165:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802169:	89 d7                	mov    %edx,%edi
  80216b:	f7 64 24 08          	mull   0x8(%esp)
  80216f:	39 d7                	cmp    %edx,%edi
  802171:	89 c1                	mov    %eax,%ecx
  802173:	89 14 24             	mov    %edx,(%esp)
  802176:	72 2c                	jb     8021a4 <__umoddi3+0x134>
  802178:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80217c:	72 22                	jb     8021a0 <__umoddi3+0x130>
  80217e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802182:	29 c8                	sub    %ecx,%eax
  802184:	19 d7                	sbb    %edx,%edi
  802186:	89 e9                	mov    %ebp,%ecx
  802188:	89 fa                	mov    %edi,%edx
  80218a:	d3 e8                	shr    %cl,%eax
  80218c:	89 f1                	mov    %esi,%ecx
  80218e:	d3 e2                	shl    %cl,%edx
  802190:	89 e9                	mov    %ebp,%ecx
  802192:	d3 ef                	shr    %cl,%edi
  802194:	09 d0                	or     %edx,%eax
  802196:	89 fa                	mov    %edi,%edx
  802198:	83 c4 14             	add    $0x14,%esp
  80219b:	5e                   	pop    %esi
  80219c:	5f                   	pop    %edi
  80219d:	5d                   	pop    %ebp
  80219e:	c3                   	ret    
  80219f:	90                   	nop
  8021a0:	39 d7                	cmp    %edx,%edi
  8021a2:	75 da                	jne    80217e <__umoddi3+0x10e>
  8021a4:	8b 14 24             	mov    (%esp),%edx
  8021a7:	89 c1                	mov    %eax,%ecx
  8021a9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8021ad:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8021b1:	eb cb                	jmp    80217e <__umoddi3+0x10e>
  8021b3:	90                   	nop
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8021bc:	0f 82 0f ff ff ff    	jb     8020d1 <__umoddi3+0x61>
  8021c2:	e9 1a ff ff ff       	jmp    8020e1 <__umoddi3+0x71>
