
obj/user/faultdie：     文件格式 elf32-i386


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
  80002c:	e8 61 00 00 00       	call   800092 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800049:	8b 50 04             	mov    0x4(%eax),%edx
  80004c:	83 e2 07             	and    $0x7,%edx
  80004f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800053:	8b 00                	mov    (%eax),%eax
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 60 12 80 00 	movl   $0x801260,(%esp)
  800060:	e8 2c 01 00 00       	call   800191 <cprintf>
	sys_env_destroy(sys_getenvid());
  800065:	e8 f1 0b 00 00       	call   800c5b <sys_getenvid>
  80006a:	89 04 24             	mov    %eax,(%esp)
  80006d:	e8 97 0b 00 00       	call   800c09 <sys_env_destroy>
}
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <umain>:

void
umain(int argc, char **argv)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80007a:	c7 04 24 40 00 80 00 	movl   $0x800040,(%esp)
  800081:	e8 28 0e 00 00       	call   800eae <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800086:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  80008d:	00 00 00 
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	83 ec 10             	sub    $0x10,%esp
  80009a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80009d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000a0:	e8 b6 0b 00 00       	call   800c5b <sys_getenvid>
  8000a5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000aa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ad:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b7:	85 db                	test   %ebx,%ebx
  8000b9:	7e 07                	jle    8000c2 <libmain+0x30>
		binaryname = argv[0];
  8000bb:	8b 06                	mov    (%esi),%eax
  8000bd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c6:	89 1c 24             	mov    %ebx,(%esp)
  8000c9:	e8 a6 ff ff ff       	call   800074 <umain>

	// exit gracefully
	exit();
  8000ce:	e8 07 00 00 00       	call   8000da <exit>
}
  8000d3:	83 c4 10             	add    $0x10,%esp
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e7:	e8 1d 0b 00 00       	call   800c09 <sys_env_destroy>
}
  8000ec:	c9                   	leave  
  8000ed:	c3                   	ret    

008000ee <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 14             	sub    $0x14,%esp
  8000f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f8:	8b 13                	mov    (%ebx),%edx
  8000fa:	8d 42 01             	lea    0x1(%edx),%eax
  8000fd:	89 03                	mov    %eax,(%ebx)
  8000ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800102:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800106:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010b:	75 19                	jne    800126 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80010d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800114:	00 
  800115:	8d 43 08             	lea    0x8(%ebx),%eax
  800118:	89 04 24             	mov    %eax,(%esp)
  80011b:	e8 ac 0a 00 00       	call   800bcc <sys_cputs>
		b->idx = 0;
  800120:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800126:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012a:	83 c4 14             	add    $0x14,%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5d                   	pop    %ebp
  80012f:	c3                   	ret    

00800130 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800139:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800140:	00 00 00 
	b.cnt = 0;
  800143:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80014d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800150:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800154:	8b 45 08             	mov    0x8(%ebp),%eax
  800157:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800161:	89 44 24 04          	mov    %eax,0x4(%esp)
  800165:	c7 04 24 ee 00 80 00 	movl   $0x8000ee,(%esp)
  80016c:	e8 b3 01 00 00       	call   800324 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800171:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800181:	89 04 24             	mov    %eax,(%esp)
  800184:	e8 43 0a 00 00       	call   800bcc <sys_cputs>

	return b.cnt;
}
  800189:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800197:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 04 24             	mov    %eax,(%esp)
  8001a4:	e8 87 ff ff ff       	call   800130 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    
  8001ab:	66 90                	xchg   %ax,%ax
  8001ad:	66 90                	xchg   %ax,%ax
  8001af:	90                   	nop

008001b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 3c             	sub    $0x3c,%esp
  8001b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001bc:	89 d7                	mov    %edx,%edi
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8001c7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8001ca:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001d8:	39 f1                	cmp    %esi,%ecx
  8001da:	72 14                	jb     8001f0 <printnum+0x40>
  8001dc:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001df:	76 0f                	jbe    8001f0 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e4:	8d 70 ff             	lea    -0x1(%eax),%esi
  8001e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8001ea:	85 f6                	test   %esi,%esi
  8001ec:	7f 60                	jg     80024e <printnum+0x9e>
  8001ee:	eb 72                	jmp    800262 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001f3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001f7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8001fa:	8d 51 ff             	lea    -0x1(%ecx),%edx
  8001fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800201:	89 44 24 08          	mov    %eax,0x8(%esp)
  800205:	8b 44 24 08          	mov    0x8(%esp),%eax
  800209:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80020d:	89 c3                	mov    %eax,%ebx
  80020f:	89 d6                	mov    %edx,%esi
  800211:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800214:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800217:	89 54 24 08          	mov    %edx,0x8(%esp)
  80021b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80021f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022c:	e8 8f 0d 00 00       	call   800fc0 <__udivdi3>
  800231:	89 d9                	mov    %ebx,%ecx
  800233:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800237:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80023b:	89 04 24             	mov    %eax,(%esp)
  80023e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800242:	89 fa                	mov    %edi,%edx
  800244:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800247:	e8 64 ff ff ff       	call   8001b0 <printnum>
  80024c:	eb 14                	jmp    800262 <printnum+0xb2>
			putch(padc, putdat);
  80024e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800252:	8b 45 18             	mov    0x18(%ebp),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	ff d3                	call   *%ebx
		while (--width > 0)
  80025a:	83 ee 01             	sub    $0x1,%esi
  80025d:	75 ef                	jne    80024e <printnum+0x9e>
  80025f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800262:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800266:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80026a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80026d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800270:	89 44 24 08          	mov    %eax,0x8(%esp)
  800274:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800278:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80027b:	89 04 24             	mov    %eax,(%esp)
  80027e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800281:	89 44 24 04          	mov    %eax,0x4(%esp)
  800285:	e8 66 0e 00 00       	call   8010f0 <__umoddi3>
  80028a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80028e:	0f be 80 86 12 80 00 	movsbl 0x801286(%eax),%eax
  800295:	89 04 24             	mov    %eax,(%esp)
  800298:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80029b:	ff d0                	call   *%eax
}
  80029d:	83 c4 3c             	add    $0x3c,%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a8:	83 fa 01             	cmp    $0x1,%edx
  8002ab:	7e 0e                	jle    8002bb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ad:	8b 10                	mov    (%eax),%edx
  8002af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b2:	89 08                	mov    %ecx,(%eax)
  8002b4:	8b 02                	mov    (%edx),%eax
  8002b6:	8b 52 04             	mov    0x4(%edx),%edx
  8002b9:	eb 22                	jmp    8002dd <getuint+0x38>
	else if (lflag)
  8002bb:	85 d2                	test   %edx,%edx
  8002bd:	74 10                	je     8002cf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c4:	89 08                	mov    %ecx,(%eax)
  8002c6:	8b 02                	mov    (%edx),%eax
  8002c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cd:	eb 0e                	jmp    8002dd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002cf:	8b 10                	mov    (%eax),%edx
  8002d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d4:	89 08                	mov    %ecx,(%eax)
  8002d6:	8b 02                	mov    (%edx),%eax
  8002d8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ee:	73 0a                	jae    8002fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	88 02                	mov    %al,(%edx)
}
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <printfmt>:
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  800302:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800305:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800309:	8b 45 10             	mov    0x10(%ebp),%eax
  80030c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800310:	8b 45 0c             	mov    0xc(%ebp),%eax
  800313:	89 44 24 04          	mov    %eax,0x4(%esp)
  800317:	8b 45 08             	mov    0x8(%ebp),%eax
  80031a:	89 04 24             	mov    %eax,(%esp)
  80031d:	e8 02 00 00 00       	call   800324 <vprintfmt>
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <vprintfmt>:
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	57                   	push   %edi
  800328:	56                   	push   %esi
  800329:	53                   	push   %ebx
  80032a:	83 ec 3c             	sub    $0x3c,%esp
  80032d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800330:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800333:	eb 18                	jmp    80034d <vprintfmt+0x29>
			if (ch == '\0')
  800335:	85 c0                	test   %eax,%eax
  800337:	0f 84 c3 03 00 00    	je     800700 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80033d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800341:	89 04 24             	mov    %eax,(%esp)
  800344:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800347:	89 f3                	mov    %esi,%ebx
  800349:	eb 02                	jmp    80034d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80034b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034d:	8d 73 01             	lea    0x1(%ebx),%esi
  800350:	0f b6 03             	movzbl (%ebx),%eax
  800353:	83 f8 25             	cmp    $0x25,%eax
  800356:	75 dd                	jne    800335 <vprintfmt+0x11>
  800358:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80035c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800363:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80036a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
  800376:	eb 1d                	jmp    800395 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800378:	89 de                	mov    %ebx,%esi
			padc = '-';
  80037a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80037e:	eb 15                	jmp    800395 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800380:	89 de                	mov    %ebx,%esi
			padc = '0';
  800382:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800386:	eb 0d                	jmp    800395 <vprintfmt+0x71>
				width = precision, precision = -1;
  800388:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80038b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8d 5e 01             	lea    0x1(%esi),%ebx
  800398:	0f b6 06             	movzbl (%esi),%eax
  80039b:	0f b6 c8             	movzbl %al,%ecx
  80039e:	83 e8 23             	sub    $0x23,%eax
  8003a1:	3c 55                	cmp    $0x55,%al
  8003a3:	0f 87 2f 03 00 00    	ja     8006d8 <vprintfmt+0x3b4>
  8003a9:	0f b6 c0             	movzbl %al,%eax
  8003ac:	ff 24 85 40 13 80 00 	jmp    *0x801340(,%eax,4)
				precision = precision * 10 + ch - '0';
  8003b3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8003b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  8003b9:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003bd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003c0:	83 f9 09             	cmp    $0x9,%ecx
  8003c3:	77 50                	ja     800415 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	89 de                	mov    %ebx,%esi
  8003c7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8003ca:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003cd:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003d0:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003d4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003d7:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003da:	83 fb 09             	cmp    $0x9,%ebx
  8003dd:	76 eb                	jbe    8003ca <vprintfmt+0xa6>
  8003df:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8003e2:	eb 33                	jmp    800417 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ea:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ed:	8b 00                	mov    (%eax),%eax
  8003ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8003f4:	eb 21                	jmp    800417 <vprintfmt+0xf3>
  8003f6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f9:	85 c9                	test   %ecx,%ecx
  8003fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800400:	0f 49 c1             	cmovns %ecx,%eax
  800403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800406:	89 de                	mov    %ebx,%esi
  800408:	eb 8b                	jmp    800395 <vprintfmt+0x71>
  80040a:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80040c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800413:	eb 80                	jmp    800395 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800415:	89 de                	mov    %ebx,%esi
			if (width < 0)
  800417:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80041b:	0f 89 74 ff ff ff    	jns    800395 <vprintfmt+0x71>
  800421:	e9 62 ff ff ff       	jmp    800388 <vprintfmt+0x64>
			lflag++;
  800426:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800429:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80042b:	e9 65 ff ff ff       	jmp    800395 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 50 04             	lea    0x4(%eax),%edx
  800436:	89 55 14             	mov    %edx,0x14(%ebp)
  800439:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80043d:	8b 00                	mov    (%eax),%eax
  80043f:	89 04 24             	mov    %eax,(%esp)
  800442:	ff 55 08             	call   *0x8(%ebp)
			break;
  800445:	e9 03 ff ff ff       	jmp    80034d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 50 04             	lea    0x4(%eax),%edx
  800450:	89 55 14             	mov    %edx,0x14(%ebp)
  800453:	8b 00                	mov    (%eax),%eax
  800455:	99                   	cltd   
  800456:	31 d0                	xor    %edx,%eax
  800458:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045a:	83 f8 08             	cmp    $0x8,%eax
  80045d:	7f 0b                	jg     80046a <vprintfmt+0x146>
  80045f:	8b 14 85 a0 14 80 00 	mov    0x8014a0(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 20                	jne    80048a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80046a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046e:	c7 44 24 08 9e 12 80 	movl   $0x80129e,0x8(%esp)
  800475:	00 
  800476:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80047a:	8b 45 08             	mov    0x8(%ebp),%eax
  80047d:	89 04 24             	mov    %eax,(%esp)
  800480:	e8 77 fe ff ff       	call   8002fc <printfmt>
  800485:	e9 c3 fe ff ff       	jmp    80034d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80048a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048e:	c7 44 24 08 a7 12 80 	movl   $0x8012a7,0x8(%esp)
  800495:	00 
  800496:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80049a:	8b 45 08             	mov    0x8(%ebp),%eax
  80049d:	89 04 24             	mov    %eax,(%esp)
  8004a0:	e8 57 fe ff ff       	call   8002fc <printfmt>
  8004a5:	e9 a3 fe ff ff       	jmp    80034d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  8004aa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004ad:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 50 04             	lea    0x4(%eax),%edx
  8004b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8004bb:	85 c0                	test   %eax,%eax
  8004bd:	ba 97 12 80 00       	mov    $0x801297,%edx
  8004c2:	0f 45 d0             	cmovne %eax,%edx
  8004c5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004c8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8004cc:	74 04                	je     8004d2 <vprintfmt+0x1ae>
  8004ce:	85 f6                	test   %esi,%esi
  8004d0:	7f 19                	jg     8004eb <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004d5:	8d 70 01             	lea    0x1(%eax),%esi
  8004d8:	0f b6 10             	movzbl (%eax),%edx
  8004db:	0f be c2             	movsbl %dl,%eax
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	0f 85 95 00 00 00    	jne    80057b <vprintfmt+0x257>
  8004e6:	e9 85 00 00 00       	jmp    800570 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004f2:	89 04 24             	mov    %eax,(%esp)
  8004f5:	e8 b8 02 00 00       	call   8007b2 <strnlen>
  8004fa:	29 c6                	sub    %eax,%esi
  8004fc:	89 f0                	mov    %esi,%eax
  8004fe:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800501:	85 f6                	test   %esi,%esi
  800503:	7e cd                	jle    8004d2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800505:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800509:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80050c:	89 c3                	mov    %eax,%ebx
  80050e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800512:	89 34 24             	mov    %esi,(%esp)
  800515:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800518:	83 eb 01             	sub    $0x1,%ebx
  80051b:	75 f1                	jne    80050e <vprintfmt+0x1ea>
  80051d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800520:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800523:	eb ad                	jmp    8004d2 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800525:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800529:	74 1e                	je     800549 <vprintfmt+0x225>
  80052b:	0f be d2             	movsbl %dl,%edx
  80052e:	83 ea 20             	sub    $0x20,%edx
  800531:	83 fa 5e             	cmp    $0x5e,%edx
  800534:	76 13                	jbe    800549 <vprintfmt+0x225>
					putch('?', putdat);
  800536:	8b 45 0c             	mov    0xc(%ebp),%eax
  800539:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800544:	ff 55 08             	call   *0x8(%ebp)
  800547:	eb 0d                	jmp    800556 <vprintfmt+0x232>
					putch(ch, putdat);
  800549:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80054c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800556:	83 ef 01             	sub    $0x1,%edi
  800559:	83 c6 01             	add    $0x1,%esi
  80055c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800560:	0f be c2             	movsbl %dl,%eax
  800563:	85 c0                	test   %eax,%eax
  800565:	75 20                	jne    800587 <vprintfmt+0x263>
  800567:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80056a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80056d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800570:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800574:	7f 25                	jg     80059b <vprintfmt+0x277>
  800576:	e9 d2 fd ff ff       	jmp    80034d <vprintfmt+0x29>
  80057b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80057e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800581:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800584:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800587:	85 db                	test   %ebx,%ebx
  800589:	78 9a                	js     800525 <vprintfmt+0x201>
  80058b:	83 eb 01             	sub    $0x1,%ebx
  80058e:	79 95                	jns    800525 <vprintfmt+0x201>
  800590:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800593:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800596:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800599:	eb d5                	jmp    800570 <vprintfmt+0x24c>
  80059b:	8b 75 08             	mov    0x8(%ebp),%esi
  80059e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005a1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  8005a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005af:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005b1:	83 eb 01             	sub    $0x1,%ebx
  8005b4:	75 ee                	jne    8005a4 <vprintfmt+0x280>
  8005b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005b9:	e9 8f fd ff ff       	jmp    80034d <vprintfmt+0x29>
	if (lflag >= 2)
  8005be:	83 fa 01             	cmp    $0x1,%edx
  8005c1:	7e 16                	jle    8005d9 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 50 08             	lea    0x8(%eax),%edx
  8005c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cc:	8b 50 04             	mov    0x4(%eax),%edx
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d7:	eb 32                	jmp    80060b <vprintfmt+0x2e7>
	else if (lflag)
  8005d9:	85 d2                	test   %edx,%edx
  8005db:	74 18                	je     8005f5 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	8b 30                	mov    (%eax),%esi
  8005e8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005eb:	89 f0                	mov    %esi,%eax
  8005ed:	c1 f8 1f             	sar    $0x1f,%eax
  8005f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005f3:	eb 16                	jmp    80060b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 04             	lea    0x4(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fe:	8b 30                	mov    (%eax),%esi
  800600:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800603:	89 f0                	mov    %esi,%eax
  800605:	c1 f8 1f             	sar    $0x1f,%eax
  800608:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  80060b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  800611:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800616:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061a:	0f 89 80 00 00 00    	jns    8006a0 <vprintfmt+0x37c>
				putch('-', putdat);
  800620:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800624:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80062b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80062e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800631:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800634:	f7 d8                	neg    %eax
  800636:	83 d2 00             	adc    $0x0,%edx
  800639:	f7 da                	neg    %edx
			base = 10;
  80063b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800640:	eb 5e                	jmp    8006a0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800642:	8d 45 14             	lea    0x14(%ebp),%eax
  800645:	e8 5b fc ff ff       	call   8002a5 <getuint>
			base = 10;
  80064a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80064f:	eb 4f                	jmp    8006a0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800651:	8d 45 14             	lea    0x14(%ebp),%eax
  800654:	e8 4c fc ff ff       	call   8002a5 <getuint>
			base = 8;
  800659:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80065e:	eb 40                	jmp    8006a0 <vprintfmt+0x37c>
			putch('0', putdat);
  800660:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800664:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80066b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80066e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800672:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800679:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 50 04             	lea    0x4(%eax),%edx
  800682:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800685:	8b 00                	mov    (%eax),%eax
  800687:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80068c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800691:	eb 0d                	jmp    8006a0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
  800696:	e8 0a fc ff ff       	call   8002a5 <getuint>
			base = 16;
  80069b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8006a0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006a4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006a8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006ab:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006b3:	89 04 24             	mov    %eax,(%esp)
  8006b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ba:	89 fa                	mov    %edi,%edx
  8006bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bf:	e8 ec fa ff ff       	call   8001b0 <printnum>
			break;
  8006c4:	e9 84 fc ff ff       	jmp    80034d <vprintfmt+0x29>
			putch(ch, putdat);
  8006c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006cd:	89 0c 24             	mov    %ecx,(%esp)
  8006d0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006d3:	e9 75 fc ff ff       	jmp    80034d <vprintfmt+0x29>
			putch('%', putdat);
  8006d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006e3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006ea:	0f 84 5b fc ff ff    	je     80034b <vprintfmt+0x27>
  8006f0:	89 f3                	mov    %esi,%ebx
  8006f2:	83 eb 01             	sub    $0x1,%ebx
  8006f5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006f9:	75 f7                	jne    8006f2 <vprintfmt+0x3ce>
  8006fb:	e9 4d fc ff ff       	jmp    80034d <vprintfmt+0x29>
}
  800700:	83 c4 3c             	add    $0x3c,%esp
  800703:	5b                   	pop    %ebx
  800704:	5e                   	pop    %esi
  800705:	5f                   	pop    %edi
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    

00800708 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	83 ec 28             	sub    $0x28,%esp
  80070e:	8b 45 08             	mov    0x8(%ebp),%eax
  800711:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800714:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800717:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800725:	85 c0                	test   %eax,%eax
  800727:	74 30                	je     800759 <vsnprintf+0x51>
  800729:	85 d2                	test   %edx,%edx
  80072b:	7e 2c                	jle    800759 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072d:	8b 45 14             	mov    0x14(%ebp),%eax
  800730:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800734:	8b 45 10             	mov    0x10(%ebp),%eax
  800737:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800742:	c7 04 24 df 02 80 00 	movl   $0x8002df,(%esp)
  800749:	e8 d6 fb ff ff       	call   800324 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800751:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800754:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800757:	eb 05                	jmp    80075e <vsnprintf+0x56>
		return -E_INVAL;
  800759:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800769:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076d:	8b 45 10             	mov    0x10(%ebp),%eax
  800770:	89 44 24 08          	mov    %eax,0x8(%esp)
  800774:	8b 45 0c             	mov    0xc(%ebp),%eax
  800777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	89 04 24             	mov    %eax,(%esp)
  800781:	e8 82 ff ff ff       	call   800708 <vsnprintf>
	va_end(ap);

	return rc;
}
  800786:	c9                   	leave  
  800787:	c3                   	ret    
  800788:	66 90                	xchg   %ax,%ax
  80078a:	66 90                	xchg   %ax,%ax
  80078c:	66 90                	xchg   %ax,%ax
  80078e:	66 90                	xchg   %ax,%ax

00800790 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800796:	80 3a 00             	cmpb   $0x0,(%edx)
  800799:	74 10                	je     8007ab <strlen+0x1b>
  80079b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007a0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a7:	75 f7                	jne    8007a0 <strlen+0x10>
  8007a9:	eb 05                	jmp    8007b0 <strlen+0x20>
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bc:	85 c9                	test   %ecx,%ecx
  8007be:	74 1c                	je     8007dc <strnlen+0x2a>
  8007c0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007c3:	74 1e                	je     8007e3 <strnlen+0x31>
  8007c5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007ca:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cc:	39 ca                	cmp    %ecx,%edx
  8007ce:	74 18                	je     8007e8 <strnlen+0x36>
  8007d0:	83 c2 01             	add    $0x1,%edx
  8007d3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007d8:	75 f0                	jne    8007ca <strnlen+0x18>
  8007da:	eb 0c                	jmp    8007e8 <strnlen+0x36>
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	eb 05                	jmp    8007e8 <strnlen+0x36>
  8007e3:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8007e8:	5b                   	pop    %ebx
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f5:	89 c2                	mov    %eax,%edx
  8007f7:	83 c2 01             	add    $0x1,%edx
  8007fa:	83 c1 01             	add    $0x1,%ecx
  8007fd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800801:	88 5a ff             	mov    %bl,-0x1(%edx)
  800804:	84 db                	test   %bl,%bl
  800806:	75 ef                	jne    8007f7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800808:	5b                   	pop    %ebx
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	83 ec 08             	sub    $0x8,%esp
  800812:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800815:	89 1c 24             	mov    %ebx,(%esp)
  800818:	e8 73 ff ff ff       	call   800790 <strlen>
	strcpy(dst + len, src);
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800820:	89 54 24 04          	mov    %edx,0x4(%esp)
  800824:	01 d8                	add    %ebx,%eax
  800826:	89 04 24             	mov    %eax,(%esp)
  800829:	e8 bd ff ff ff       	call   8007eb <strcpy>
	return dst;
}
  80082e:	89 d8                	mov    %ebx,%eax
  800830:	83 c4 08             	add    $0x8,%esp
  800833:	5b                   	pop    %ebx
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	56                   	push   %esi
  80083a:	53                   	push   %ebx
  80083b:	8b 75 08             	mov    0x8(%ebp),%esi
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800841:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800844:	85 db                	test   %ebx,%ebx
  800846:	74 17                	je     80085f <strncpy+0x29>
  800848:	01 f3                	add    %esi,%ebx
  80084a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80084c:	83 c1 01             	add    $0x1,%ecx
  80084f:	0f b6 02             	movzbl (%edx),%eax
  800852:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800855:	80 3a 01             	cmpb   $0x1,(%edx)
  800858:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80085b:	39 d9                	cmp    %ebx,%ecx
  80085d:	75 ed                	jne    80084c <strncpy+0x16>
	}
	return ret;
}
  80085f:	89 f0                	mov    %esi,%eax
  800861:	5b                   	pop    %ebx
  800862:	5e                   	pop    %esi
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	57                   	push   %edi
  800869:	56                   	push   %esi
  80086a:	53                   	push   %ebx
  80086b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800871:	8b 75 10             	mov    0x10(%ebp),%esi
  800874:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800876:	85 f6                	test   %esi,%esi
  800878:	74 34                	je     8008ae <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  80087a:	83 fe 01             	cmp    $0x1,%esi
  80087d:	74 26                	je     8008a5 <strlcpy+0x40>
  80087f:	0f b6 0b             	movzbl (%ebx),%ecx
  800882:	84 c9                	test   %cl,%cl
  800884:	74 23                	je     8008a9 <strlcpy+0x44>
  800886:	83 ee 02             	sub    $0x2,%esi
  800889:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  80088e:	83 c0 01             	add    $0x1,%eax
  800891:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800894:	39 f2                	cmp    %esi,%edx
  800896:	74 13                	je     8008ab <strlcpy+0x46>
  800898:	83 c2 01             	add    $0x1,%edx
  80089b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80089f:	84 c9                	test   %cl,%cl
  8008a1:	75 eb                	jne    80088e <strlcpy+0x29>
  8008a3:	eb 06                	jmp    8008ab <strlcpy+0x46>
  8008a5:	89 f8                	mov    %edi,%eax
  8008a7:	eb 02                	jmp    8008ab <strlcpy+0x46>
  8008a9:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  8008ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ae:	29 f8                	sub    %edi,%eax
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5f                   	pop    %edi
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008be:	0f b6 01             	movzbl (%ecx),%eax
  8008c1:	84 c0                	test   %al,%al
  8008c3:	74 15                	je     8008da <strcmp+0x25>
  8008c5:	3a 02                	cmp    (%edx),%al
  8008c7:	75 11                	jne    8008da <strcmp+0x25>
		p++, q++;
  8008c9:	83 c1 01             	add    $0x1,%ecx
  8008cc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008cf:	0f b6 01             	movzbl (%ecx),%eax
  8008d2:	84 c0                	test   %al,%al
  8008d4:	74 04                	je     8008da <strcmp+0x25>
  8008d6:	3a 02                	cmp    (%edx),%al
  8008d8:	74 ef                	je     8008c9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008da:	0f b6 c0             	movzbl %al,%eax
  8008dd:	0f b6 12             	movzbl (%edx),%edx
  8008e0:	29 d0                	sub    %edx,%eax
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ef:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8008f2:	85 f6                	test   %esi,%esi
  8008f4:	74 29                	je     80091f <strncmp+0x3b>
  8008f6:	0f b6 03             	movzbl (%ebx),%eax
  8008f9:	84 c0                	test   %al,%al
  8008fb:	74 30                	je     80092d <strncmp+0x49>
  8008fd:	3a 02                	cmp    (%edx),%al
  8008ff:	75 2c                	jne    80092d <strncmp+0x49>
  800901:	8d 43 01             	lea    0x1(%ebx),%eax
  800904:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800906:	89 c3                	mov    %eax,%ebx
  800908:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80090b:	39 f0                	cmp    %esi,%eax
  80090d:	74 17                	je     800926 <strncmp+0x42>
  80090f:	0f b6 08             	movzbl (%eax),%ecx
  800912:	84 c9                	test   %cl,%cl
  800914:	74 17                	je     80092d <strncmp+0x49>
  800916:	83 c0 01             	add    $0x1,%eax
  800919:	3a 0a                	cmp    (%edx),%cl
  80091b:	74 e9                	je     800906 <strncmp+0x22>
  80091d:	eb 0e                	jmp    80092d <strncmp+0x49>
	if (n == 0)
		return 0;
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
  800924:	eb 0f                	jmp    800935 <strncmp+0x51>
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
  80092b:	eb 08                	jmp    800935 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092d:	0f b6 03             	movzbl (%ebx),%eax
  800930:	0f b6 12             	movzbl (%edx),%edx
  800933:	29 d0                	sub    %edx,%eax
}
  800935:	5b                   	pop    %ebx
  800936:	5e                   	pop    %esi
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	53                   	push   %ebx
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800943:	0f b6 18             	movzbl (%eax),%ebx
  800946:	84 db                	test   %bl,%bl
  800948:	74 1d                	je     800967 <strchr+0x2e>
  80094a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80094c:	38 d3                	cmp    %dl,%bl
  80094e:	75 06                	jne    800956 <strchr+0x1d>
  800950:	eb 1a                	jmp    80096c <strchr+0x33>
  800952:	38 ca                	cmp    %cl,%dl
  800954:	74 16                	je     80096c <strchr+0x33>
	for (; *s; s++)
  800956:	83 c0 01             	add    $0x1,%eax
  800959:	0f b6 10             	movzbl (%eax),%edx
  80095c:	84 d2                	test   %dl,%dl
  80095e:	75 f2                	jne    800952 <strchr+0x19>
			return (char *) s;
	return 0;
  800960:	b8 00 00 00 00       	mov    $0x0,%eax
  800965:	eb 05                	jmp    80096c <strchr+0x33>
  800967:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096c:	5b                   	pop    %ebx
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	53                   	push   %ebx
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800979:	0f b6 18             	movzbl (%eax),%ebx
  80097c:	84 db                	test   %bl,%bl
  80097e:	74 16                	je     800996 <strfind+0x27>
  800980:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800982:	38 d3                	cmp    %dl,%bl
  800984:	75 06                	jne    80098c <strfind+0x1d>
  800986:	eb 0e                	jmp    800996 <strfind+0x27>
  800988:	38 ca                	cmp    %cl,%dl
  80098a:	74 0a                	je     800996 <strfind+0x27>
	for (; *s; s++)
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	0f b6 10             	movzbl (%eax),%edx
  800992:	84 d2                	test   %dl,%dl
  800994:	75 f2                	jne    800988 <strfind+0x19>
			break;
	return (char *) s;
}
  800996:	5b                   	pop    %ebx
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	57                   	push   %edi
  80099d:	56                   	push   %esi
  80099e:	53                   	push   %ebx
  80099f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a5:	85 c9                	test   %ecx,%ecx
  8009a7:	74 36                	je     8009df <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009af:	75 28                	jne    8009d9 <memset+0x40>
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 23                	jne    8009d9 <memset+0x40>
		c &= 0xFF;
  8009b6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ba:	89 d3                	mov    %edx,%ebx
  8009bc:	c1 e3 08             	shl    $0x8,%ebx
  8009bf:	89 d6                	mov    %edx,%esi
  8009c1:	c1 e6 18             	shl    $0x18,%esi
  8009c4:	89 d0                	mov    %edx,%eax
  8009c6:	c1 e0 10             	shl    $0x10,%eax
  8009c9:	09 f0                	or     %esi,%eax
  8009cb:	09 c2                	or     %eax,%edx
  8009cd:	89 d0                	mov    %edx,%eax
  8009cf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009d4:	fc                   	cld    
  8009d5:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d7:	eb 06                	jmp    8009df <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dc:	fc                   	cld    
  8009dd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009df:	89 f8                	mov    %edi,%eax
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5f                   	pop    %edi
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	57                   	push   %edi
  8009ea:	56                   	push   %esi
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f4:	39 c6                	cmp    %eax,%esi
  8009f6:	73 35                	jae    800a2d <memmove+0x47>
  8009f8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009fb:	39 d0                	cmp    %edx,%eax
  8009fd:	73 2e                	jae    800a2d <memmove+0x47>
		s += n;
		d += n;
  8009ff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a02:	89 d6                	mov    %edx,%esi
  800a04:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0c:	75 13                	jne    800a21 <memmove+0x3b>
  800a0e:	f6 c1 03             	test   $0x3,%cl
  800a11:	75 0e                	jne    800a21 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a13:	83 ef 04             	sub    $0x4,%edi
  800a16:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a19:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a1c:	fd                   	std    
  800a1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1f:	eb 09                	jmp    800a2a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a21:	83 ef 01             	sub    $0x1,%edi
  800a24:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a27:	fd                   	std    
  800a28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2a:	fc                   	cld    
  800a2b:	eb 1d                	jmp    800a4a <memmove+0x64>
  800a2d:	89 f2                	mov    %esi,%edx
  800a2f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a31:	f6 c2 03             	test   $0x3,%dl
  800a34:	75 0f                	jne    800a45 <memmove+0x5f>
  800a36:	f6 c1 03             	test   $0x3,%cl
  800a39:	75 0a                	jne    800a45 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a3b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a3e:	89 c7                	mov    %eax,%edi
  800a40:	fc                   	cld    
  800a41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a43:	eb 05                	jmp    800a4a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800a45:	89 c7                	mov    %eax,%edi
  800a47:	fc                   	cld    
  800a48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4a:	5e                   	pop    %esi
  800a4b:	5f                   	pop    %edi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a54:	8b 45 10             	mov    0x10(%ebp),%eax
  800a57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	89 04 24             	mov    %eax,(%esp)
  800a68:	e8 79 ff ff ff       	call   8009e6 <memmove>
}
  800a6d:	c9                   	leave  
  800a6e:	c3                   	ret    

00800a6f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800a81:	85 c0                	test   %eax,%eax
  800a83:	74 36                	je     800abb <memcmp+0x4c>
		if (*s1 != *s2)
  800a85:	0f b6 03             	movzbl (%ebx),%eax
  800a88:	0f b6 0e             	movzbl (%esi),%ecx
  800a8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a90:	38 c8                	cmp    %cl,%al
  800a92:	74 1c                	je     800ab0 <memcmp+0x41>
  800a94:	eb 10                	jmp    800aa6 <memcmp+0x37>
  800a96:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a9b:	83 c2 01             	add    $0x1,%edx
  800a9e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800aa2:	38 c8                	cmp    %cl,%al
  800aa4:	74 0a                	je     800ab0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800aa6:	0f b6 c0             	movzbl %al,%eax
  800aa9:	0f b6 c9             	movzbl %cl,%ecx
  800aac:	29 c8                	sub    %ecx,%eax
  800aae:	eb 10                	jmp    800ac0 <memcmp+0x51>
	while (n-- > 0) {
  800ab0:	39 fa                	cmp    %edi,%edx
  800ab2:	75 e2                	jne    800a96 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800ab4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab9:	eb 05                	jmp    800ac0 <memcmp+0x51>
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	53                   	push   %ebx
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800acf:	89 c2                	mov    %eax,%edx
  800ad1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad4:	39 d0                	cmp    %edx,%eax
  800ad6:	73 13                	jae    800aeb <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad8:	89 d9                	mov    %ebx,%ecx
  800ada:	38 18                	cmp    %bl,(%eax)
  800adc:	75 06                	jne    800ae4 <memfind+0x1f>
  800ade:	eb 0b                	jmp    800aeb <memfind+0x26>
  800ae0:	38 08                	cmp    %cl,(%eax)
  800ae2:	74 07                	je     800aeb <memfind+0x26>
	for (; s < ends; s++)
  800ae4:	83 c0 01             	add    $0x1,%eax
  800ae7:	39 d0                	cmp    %edx,%eax
  800ae9:	75 f5                	jne    800ae0 <memfind+0x1b>
			break;
	return (void *) s;
}
  800aeb:	5b                   	pop    %ebx
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
  800af7:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afa:	0f b6 0a             	movzbl (%edx),%ecx
  800afd:	80 f9 09             	cmp    $0x9,%cl
  800b00:	74 05                	je     800b07 <strtol+0x19>
  800b02:	80 f9 20             	cmp    $0x20,%cl
  800b05:	75 10                	jne    800b17 <strtol+0x29>
		s++;
  800b07:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b0a:	0f b6 0a             	movzbl (%edx),%ecx
  800b0d:	80 f9 09             	cmp    $0x9,%cl
  800b10:	74 f5                	je     800b07 <strtol+0x19>
  800b12:	80 f9 20             	cmp    $0x20,%cl
  800b15:	74 f0                	je     800b07 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800b17:	80 f9 2b             	cmp    $0x2b,%cl
  800b1a:	75 0a                	jne    800b26 <strtol+0x38>
		s++;
  800b1c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b1f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b24:	eb 11                	jmp    800b37 <strtol+0x49>
  800b26:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800b2b:	80 f9 2d             	cmp    $0x2d,%cl
  800b2e:	75 07                	jne    800b37 <strtol+0x49>
		s++, neg = 1;
  800b30:	83 c2 01             	add    $0x1,%edx
  800b33:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b37:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b3c:	75 15                	jne    800b53 <strtol+0x65>
  800b3e:	80 3a 30             	cmpb   $0x30,(%edx)
  800b41:	75 10                	jne    800b53 <strtol+0x65>
  800b43:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b47:	75 0a                	jne    800b53 <strtol+0x65>
		s += 2, base = 16;
  800b49:	83 c2 02             	add    $0x2,%edx
  800b4c:	b8 10 00 00 00       	mov    $0x10,%eax
  800b51:	eb 10                	jmp    800b63 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800b53:	85 c0                	test   %eax,%eax
  800b55:	75 0c                	jne    800b63 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b57:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800b59:	80 3a 30             	cmpb   $0x30,(%edx)
  800b5c:	75 05                	jne    800b63 <strtol+0x75>
		s++, base = 8;
  800b5e:	83 c2 01             	add    $0x1,%edx
  800b61:	b0 08                	mov    $0x8,%al
		base = 10;
  800b63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b68:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b6b:	0f b6 0a             	movzbl (%edx),%ecx
  800b6e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b71:	89 f0                	mov    %esi,%eax
  800b73:	3c 09                	cmp    $0x9,%al
  800b75:	77 08                	ja     800b7f <strtol+0x91>
			dig = *s - '0';
  800b77:	0f be c9             	movsbl %cl,%ecx
  800b7a:	83 e9 30             	sub    $0x30,%ecx
  800b7d:	eb 20                	jmp    800b9f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800b7f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b82:	89 f0                	mov    %esi,%eax
  800b84:	3c 19                	cmp    $0x19,%al
  800b86:	77 08                	ja     800b90 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800b88:	0f be c9             	movsbl %cl,%ecx
  800b8b:	83 e9 57             	sub    $0x57,%ecx
  800b8e:	eb 0f                	jmp    800b9f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800b90:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b93:	89 f0                	mov    %esi,%eax
  800b95:	3c 19                	cmp    $0x19,%al
  800b97:	77 16                	ja     800baf <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b99:	0f be c9             	movsbl %cl,%ecx
  800b9c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b9f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800ba2:	7d 0f                	jge    800bb3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ba4:	83 c2 01             	add    $0x1,%edx
  800ba7:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bab:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bad:	eb bc                	jmp    800b6b <strtol+0x7d>
  800baf:	89 d8                	mov    %ebx,%eax
  800bb1:	eb 02                	jmp    800bb5 <strtol+0xc7>
  800bb3:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bb5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb9:	74 05                	je     800bc0 <strtol+0xd2>
		*endptr = (char *) s;
  800bbb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbe:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bc0:	f7 d8                	neg    %eax
  800bc2:	85 ff                	test   %edi,%edi
  800bc4:	0f 44 c3             	cmove  %ebx,%eax
}
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	89 c3                	mov    %eax,%ebx
  800bdf:	89 c7                	mov    %eax,%edi
  800be1:	89 c6                	mov    %eax,%esi
  800be3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sys_cgetc>:

int
sys_cgetc(void)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bfa:	89 d1                	mov    %edx,%ecx
  800bfc:	89 d3                	mov    %edx,%ebx
  800bfe:	89 d7                	mov    %edx,%edi
  800c00:	89 d6                	mov    %edx,%esi
  800c02:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c17:	b8 03 00 00 00       	mov    $0x3,%eax
  800c1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1f:	89 cb                	mov    %ecx,%ebx
  800c21:	89 cf                	mov    %ecx,%edi
  800c23:	89 ce                	mov    %ecx,%esi
  800c25:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7e 28                	jle    800c53 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c36:	00 
  800c37:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800c3e:	00 
  800c3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c46:	00 
  800c47:	c7 04 24 e1 14 80 00 	movl   $0x8014e1,(%esp)
  800c4e:	e8 08 03 00 00       	call   800f5b <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c53:	83 c4 2c             	add    $0x2c,%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c61:	ba 00 00 00 00       	mov    $0x0,%edx
  800c66:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6b:	89 d1                	mov    %edx,%ecx
  800c6d:	89 d3                	mov    %edx,%ebx
  800c6f:	89 d7                	mov    %edx,%edi
  800c71:	89 d6                	mov    %edx,%esi
  800c73:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_yield>:

void
sys_yield(void)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c80:	ba 00 00 00 00       	mov    $0x0,%edx
  800c85:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c8a:	89 d1                	mov    %edx,%ecx
  800c8c:	89 d3                	mov    %edx,%ebx
  800c8e:	89 d7                	mov    %edx,%edi
  800c90:	89 d6                	mov    %edx,%esi
  800c92:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ca2:	be 00 00 00 00       	mov    $0x0,%esi
  800ca7:	b8 04 00 00 00       	mov    $0x4,%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb5:	89 f7                	mov    %esi,%edi
  800cb7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7e 28                	jle    800ce5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cc8:	00 
  800cc9:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800cd0:	00 
  800cd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd8:	00 
  800cd9:	c7 04 24 e1 14 80 00 	movl   $0x8014e1,(%esp)
  800ce0:	e8 76 02 00 00       	call   800f5b <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce5:	83 c4 2c             	add    $0x2c,%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cf6:	b8 05 00 00 00       	mov    $0x5,%eax
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d07:	8b 75 18             	mov    0x18(%ebp),%esi
  800d0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	7e 28                	jle    800d38 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d14:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d1b:	00 
  800d1c:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800d23:	00 
  800d24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2b:	00 
  800d2c:	c7 04 24 e1 14 80 00 	movl   $0x8014e1,(%esp)
  800d33:	e8 23 02 00 00       	call   800f5b <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d38:	83 c4 2c             	add    $0x2c,%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 df                	mov    %ebx,%edi
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 28                	jle    800d8b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d67:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d6e:	00 
  800d6f:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800d76:	00 
  800d77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7e:	00 
  800d7f:	c7 04 24 e1 14 80 00 	movl   $0x8014e1,(%esp)
  800d86:	e8 d0 01 00 00       	call   800f5b <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d8b:	83 c4 2c             	add    $0x2c,%esp
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da1:	b8 08 00 00 00       	mov    $0x8,%eax
  800da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	89 df                	mov    %ebx,%edi
  800dae:	89 de                	mov    %ebx,%esi
  800db0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db2:	85 c0                	test   %eax,%eax
  800db4:	7e 28                	jle    800dde <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dba:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dc1:	00 
  800dc2:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800dc9:	00 
  800dca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd1:	00 
  800dd2:	c7 04 24 e1 14 80 00 	movl   $0x8014e1,(%esp)
  800dd9:	e8 7d 01 00 00       	call   800f5b <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dde:	83 c4 2c             	add    $0x2c,%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
  800dec:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800def:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df4:	b8 09 00 00 00       	mov    $0x9,%eax
  800df9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	89 df                	mov    %ebx,%edi
  800e01:	89 de                	mov    %ebx,%esi
  800e03:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e05:	85 c0                	test   %eax,%eax
  800e07:	7e 28                	jle    800e31 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e09:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e14:	00 
  800e15:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800e1c:	00 
  800e1d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e24:	00 
  800e25:	c7 04 24 e1 14 80 00 	movl   $0x8014e1,(%esp)
  800e2c:	e8 2a 01 00 00       	call   800f5b <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e31:	83 c4 2c             	add    $0x2c,%esp
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	57                   	push   %edi
  800e3d:	56                   	push   %esi
  800e3e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3f:	be 00 00 00 00       	mov    $0x0,%esi
  800e44:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e55:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
  800e62:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e6a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e72:	89 cb                	mov    %ecx,%ebx
  800e74:	89 cf                	mov    %ecx,%edi
  800e76:	89 ce                	mov    %ecx,%esi
  800e78:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	7e 28                	jle    800ea6 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e82:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e89:	00 
  800e8a:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800e91:	00 
  800e92:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e99:	00 
  800e9a:	c7 04 24 e1 14 80 00 	movl   $0x8014e1,(%esp)
  800ea1:	e8 b5 00 00 00       	call   800f5b <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea6:	83 c4 2c             	add    $0x2c,%esp
  800ea9:	5b                   	pop    %ebx
  800eaa:	5e                   	pop    %esi
  800eab:	5f                   	pop    %edi
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800eb4:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800ebb:	75 70                	jne    800f2d <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  800ebd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800ecc:	ee 
  800ecd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ed4:	e8 c0 fd ff ff       	call   800c99 <sys_page_alloc>
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	79 1c                	jns    800ef9 <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  800edd:	c7 44 24 08 f0 14 80 	movl   $0x8014f0,0x8(%esp)
  800ee4:	00 
  800ee5:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800eec:	00 
  800eed:	c7 04 24 53 15 80 00 	movl   $0x801553,(%esp)
  800ef4:	e8 62 00 00 00       	call   800f5b <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800ef9:	c7 44 24 04 37 0f 80 	movl   $0x800f37,0x4(%esp)
  800f00:	00 
  800f01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f08:	e8 d9 fe ff ff       	call   800de6 <sys_env_set_pgfault_upcall>
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	79 1c                	jns    800f2d <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  800f11:	c7 44 24 08 1c 15 80 	movl   $0x80151c,0x8(%esp)
  800f18:	00 
  800f19:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800f20:	00 
  800f21:	c7 04 24 53 15 80 00 	movl   $0x801553,(%esp)
  800f28:	e8 2e 00 00 00       	call   800f5b <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f30:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800f35:	c9                   	leave  
  800f36:	c3                   	ret    

00800f37 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f37:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f38:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800f3d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f3f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  800f42:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  800f46:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  800f4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  800f4f:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800f51:	83 c4 08             	add    $0x8,%esp
	popal
  800f54:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800f55:	83 c4 04             	add    $0x4,%esp
	popfl
  800f58:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800f59:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800f5a:	c3                   	ret    

00800f5b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
  800f60:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800f63:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f66:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f6c:	e8 ea fc ff ff       	call   800c5b <sys_getenvid>
  800f71:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f74:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f78:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f7f:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f87:	c7 04 24 64 15 80 00 	movl   $0x801564,(%esp)
  800f8e:	e8 fe f1 ff ff       	call   800191 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f93:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f97:	8b 45 10             	mov    0x10(%ebp),%eax
  800f9a:	89 04 24             	mov    %eax,(%esp)
  800f9d:	e8 8e f1 ff ff       	call   800130 <vcprintf>
	cprintf("\n");
  800fa2:	c7 04 24 7a 12 80 00 	movl   $0x80127a,(%esp)
  800fa9:	e8 e3 f1 ff ff       	call   800191 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fae:	cc                   	int3   
  800faf:	eb fd                	jmp    800fae <_panic+0x53>
  800fb1:	66 90                	xchg   %ax,%ax
  800fb3:	66 90                	xchg   %ax,%ax
  800fb5:	66 90                	xchg   %ax,%ax
  800fb7:	66 90                	xchg   %ax,%ax
  800fb9:	66 90                	xchg   %ax,%ax
  800fbb:	66 90                	xchg   %ax,%ax
  800fbd:	66 90                	xchg   %ax,%ax
  800fbf:	90                   	nop

00800fc0 <__udivdi3>:
  800fc0:	55                   	push   %ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800fca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800fce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800fd2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fdc:	89 ea                	mov    %ebp,%edx
  800fde:	89 0c 24             	mov    %ecx,(%esp)
  800fe1:	75 2d                	jne    801010 <__udivdi3+0x50>
  800fe3:	39 e9                	cmp    %ebp,%ecx
  800fe5:	77 61                	ja     801048 <__udivdi3+0x88>
  800fe7:	85 c9                	test   %ecx,%ecx
  800fe9:	89 ce                	mov    %ecx,%esi
  800feb:	75 0b                	jne    800ff8 <__udivdi3+0x38>
  800fed:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff2:	31 d2                	xor    %edx,%edx
  800ff4:	f7 f1                	div    %ecx
  800ff6:	89 c6                	mov    %eax,%esi
  800ff8:	31 d2                	xor    %edx,%edx
  800ffa:	89 e8                	mov    %ebp,%eax
  800ffc:	f7 f6                	div    %esi
  800ffe:	89 c5                	mov    %eax,%ebp
  801000:	89 f8                	mov    %edi,%eax
  801002:	f7 f6                	div    %esi
  801004:	89 ea                	mov    %ebp,%edx
  801006:	83 c4 0c             	add    $0xc,%esp
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    
  80100d:	8d 76 00             	lea    0x0(%esi),%esi
  801010:	39 e8                	cmp    %ebp,%eax
  801012:	77 24                	ja     801038 <__udivdi3+0x78>
  801014:	0f bd e8             	bsr    %eax,%ebp
  801017:	83 f5 1f             	xor    $0x1f,%ebp
  80101a:	75 3c                	jne    801058 <__udivdi3+0x98>
  80101c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801020:	39 34 24             	cmp    %esi,(%esp)
  801023:	0f 86 9f 00 00 00    	jbe    8010c8 <__udivdi3+0x108>
  801029:	39 d0                	cmp    %edx,%eax
  80102b:	0f 82 97 00 00 00    	jb     8010c8 <__udivdi3+0x108>
  801031:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801038:	31 d2                	xor    %edx,%edx
  80103a:	31 c0                	xor    %eax,%eax
  80103c:	83 c4 0c             	add    $0xc,%esp
  80103f:	5e                   	pop    %esi
  801040:	5f                   	pop    %edi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    
  801043:	90                   	nop
  801044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801048:	89 f8                	mov    %edi,%eax
  80104a:	f7 f1                	div    %ecx
  80104c:	31 d2                	xor    %edx,%edx
  80104e:	83 c4 0c             	add    $0xc,%esp
  801051:	5e                   	pop    %esi
  801052:	5f                   	pop    %edi
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    
  801055:	8d 76 00             	lea    0x0(%esi),%esi
  801058:	89 e9                	mov    %ebp,%ecx
  80105a:	8b 3c 24             	mov    (%esp),%edi
  80105d:	d3 e0                	shl    %cl,%eax
  80105f:	89 c6                	mov    %eax,%esi
  801061:	b8 20 00 00 00       	mov    $0x20,%eax
  801066:	29 e8                	sub    %ebp,%eax
  801068:	89 c1                	mov    %eax,%ecx
  80106a:	d3 ef                	shr    %cl,%edi
  80106c:	89 e9                	mov    %ebp,%ecx
  80106e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801072:	8b 3c 24             	mov    (%esp),%edi
  801075:	09 74 24 08          	or     %esi,0x8(%esp)
  801079:	89 d6                	mov    %edx,%esi
  80107b:	d3 e7                	shl    %cl,%edi
  80107d:	89 c1                	mov    %eax,%ecx
  80107f:	89 3c 24             	mov    %edi,(%esp)
  801082:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801086:	d3 ee                	shr    %cl,%esi
  801088:	89 e9                	mov    %ebp,%ecx
  80108a:	d3 e2                	shl    %cl,%edx
  80108c:	89 c1                	mov    %eax,%ecx
  80108e:	d3 ef                	shr    %cl,%edi
  801090:	09 d7                	or     %edx,%edi
  801092:	89 f2                	mov    %esi,%edx
  801094:	89 f8                	mov    %edi,%eax
  801096:	f7 74 24 08          	divl   0x8(%esp)
  80109a:	89 d6                	mov    %edx,%esi
  80109c:	89 c7                	mov    %eax,%edi
  80109e:	f7 24 24             	mull   (%esp)
  8010a1:	39 d6                	cmp    %edx,%esi
  8010a3:	89 14 24             	mov    %edx,(%esp)
  8010a6:	72 30                	jb     8010d8 <__udivdi3+0x118>
  8010a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010ac:	89 e9                	mov    %ebp,%ecx
  8010ae:	d3 e2                	shl    %cl,%edx
  8010b0:	39 c2                	cmp    %eax,%edx
  8010b2:	73 05                	jae    8010b9 <__udivdi3+0xf9>
  8010b4:	3b 34 24             	cmp    (%esp),%esi
  8010b7:	74 1f                	je     8010d8 <__udivdi3+0x118>
  8010b9:	89 f8                	mov    %edi,%eax
  8010bb:	31 d2                	xor    %edx,%edx
  8010bd:	e9 7a ff ff ff       	jmp    80103c <__udivdi3+0x7c>
  8010c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010c8:	31 d2                	xor    %edx,%edx
  8010ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8010cf:	e9 68 ff ff ff       	jmp    80103c <__udivdi3+0x7c>
  8010d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8010db:	31 d2                	xor    %edx,%edx
  8010dd:	83 c4 0c             	add    $0xc,%esp
  8010e0:	5e                   	pop    %esi
  8010e1:	5f                   	pop    %edi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    
  8010e4:	66 90                	xchg   %ax,%ax
  8010e6:	66 90                	xchg   %ax,%ax
  8010e8:	66 90                	xchg   %ax,%ax
  8010ea:	66 90                	xchg   %ax,%ax
  8010ec:	66 90                	xchg   %ax,%ax
  8010ee:	66 90                	xchg   %ax,%ax

008010f0 <__umoddi3>:
  8010f0:	55                   	push   %ebp
  8010f1:	57                   	push   %edi
  8010f2:	56                   	push   %esi
  8010f3:	83 ec 14             	sub    $0x14,%esp
  8010f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8010fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8010fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801102:	89 c7                	mov    %eax,%edi
  801104:	89 44 24 04          	mov    %eax,0x4(%esp)
  801108:	8b 44 24 30          	mov    0x30(%esp),%eax
  80110c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801110:	89 34 24             	mov    %esi,(%esp)
  801113:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801117:	85 c0                	test   %eax,%eax
  801119:	89 c2                	mov    %eax,%edx
  80111b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80111f:	75 17                	jne    801138 <__umoddi3+0x48>
  801121:	39 fe                	cmp    %edi,%esi
  801123:	76 4b                	jbe    801170 <__umoddi3+0x80>
  801125:	89 c8                	mov    %ecx,%eax
  801127:	89 fa                	mov    %edi,%edx
  801129:	f7 f6                	div    %esi
  80112b:	89 d0                	mov    %edx,%eax
  80112d:	31 d2                	xor    %edx,%edx
  80112f:	83 c4 14             	add    $0x14,%esp
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    
  801136:	66 90                	xchg   %ax,%ax
  801138:	39 f8                	cmp    %edi,%eax
  80113a:	77 54                	ja     801190 <__umoddi3+0xa0>
  80113c:	0f bd e8             	bsr    %eax,%ebp
  80113f:	83 f5 1f             	xor    $0x1f,%ebp
  801142:	75 5c                	jne    8011a0 <__umoddi3+0xb0>
  801144:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801148:	39 3c 24             	cmp    %edi,(%esp)
  80114b:	0f 87 e7 00 00 00    	ja     801238 <__umoddi3+0x148>
  801151:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801155:	29 f1                	sub    %esi,%ecx
  801157:	19 c7                	sbb    %eax,%edi
  801159:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80115d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801161:	8b 44 24 08          	mov    0x8(%esp),%eax
  801165:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801169:	83 c4 14             	add    $0x14,%esp
  80116c:	5e                   	pop    %esi
  80116d:	5f                   	pop    %edi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    
  801170:	85 f6                	test   %esi,%esi
  801172:	89 f5                	mov    %esi,%ebp
  801174:	75 0b                	jne    801181 <__umoddi3+0x91>
  801176:	b8 01 00 00 00       	mov    $0x1,%eax
  80117b:	31 d2                	xor    %edx,%edx
  80117d:	f7 f6                	div    %esi
  80117f:	89 c5                	mov    %eax,%ebp
  801181:	8b 44 24 04          	mov    0x4(%esp),%eax
  801185:	31 d2                	xor    %edx,%edx
  801187:	f7 f5                	div    %ebp
  801189:	89 c8                	mov    %ecx,%eax
  80118b:	f7 f5                	div    %ebp
  80118d:	eb 9c                	jmp    80112b <__umoddi3+0x3b>
  80118f:	90                   	nop
  801190:	89 c8                	mov    %ecx,%eax
  801192:	89 fa                	mov    %edi,%edx
  801194:	83 c4 14             	add    $0x14,%esp
  801197:	5e                   	pop    %esi
  801198:	5f                   	pop    %edi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    
  80119b:	90                   	nop
  80119c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	8b 04 24             	mov    (%esp),%eax
  8011a3:	be 20 00 00 00       	mov    $0x20,%esi
  8011a8:	89 e9                	mov    %ebp,%ecx
  8011aa:	29 ee                	sub    %ebp,%esi
  8011ac:	d3 e2                	shl    %cl,%edx
  8011ae:	89 f1                	mov    %esi,%ecx
  8011b0:	d3 e8                	shr    %cl,%eax
  8011b2:	89 e9                	mov    %ebp,%ecx
  8011b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b8:	8b 04 24             	mov    (%esp),%eax
  8011bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8011bf:	89 fa                	mov    %edi,%edx
  8011c1:	d3 e0                	shl    %cl,%eax
  8011c3:	89 f1                	mov    %esi,%ecx
  8011c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8011cd:	d3 ea                	shr    %cl,%edx
  8011cf:	89 e9                	mov    %ebp,%ecx
  8011d1:	d3 e7                	shl    %cl,%edi
  8011d3:	89 f1                	mov    %esi,%ecx
  8011d5:	d3 e8                	shr    %cl,%eax
  8011d7:	89 e9                	mov    %ebp,%ecx
  8011d9:	09 f8                	or     %edi,%eax
  8011db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8011df:	f7 74 24 04          	divl   0x4(%esp)
  8011e3:	d3 e7                	shl    %cl,%edi
  8011e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011e9:	89 d7                	mov    %edx,%edi
  8011eb:	f7 64 24 08          	mull   0x8(%esp)
  8011ef:	39 d7                	cmp    %edx,%edi
  8011f1:	89 c1                	mov    %eax,%ecx
  8011f3:	89 14 24             	mov    %edx,(%esp)
  8011f6:	72 2c                	jb     801224 <__umoddi3+0x134>
  8011f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8011fc:	72 22                	jb     801220 <__umoddi3+0x130>
  8011fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801202:	29 c8                	sub    %ecx,%eax
  801204:	19 d7                	sbb    %edx,%edi
  801206:	89 e9                	mov    %ebp,%ecx
  801208:	89 fa                	mov    %edi,%edx
  80120a:	d3 e8                	shr    %cl,%eax
  80120c:	89 f1                	mov    %esi,%ecx
  80120e:	d3 e2                	shl    %cl,%edx
  801210:	89 e9                	mov    %ebp,%ecx
  801212:	d3 ef                	shr    %cl,%edi
  801214:	09 d0                	or     %edx,%eax
  801216:	89 fa                	mov    %edi,%edx
  801218:	83 c4 14             	add    $0x14,%esp
  80121b:	5e                   	pop    %esi
  80121c:	5f                   	pop    %edi
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    
  80121f:	90                   	nop
  801220:	39 d7                	cmp    %edx,%edi
  801222:	75 da                	jne    8011fe <__umoddi3+0x10e>
  801224:	8b 14 24             	mov    (%esp),%edx
  801227:	89 c1                	mov    %eax,%ecx
  801229:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80122d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801231:	eb cb                	jmp    8011fe <__umoddi3+0x10e>
  801233:	90                   	nop
  801234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801238:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80123c:	0f 82 0f ff ff ff    	jb     801151 <__umoddi3+0x61>
  801242:	e9 1a ff ff ff       	jmp    801161 <__umoddi3+0x71>
