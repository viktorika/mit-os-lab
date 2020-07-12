
obj/user/faultdie.debug：     文件格式 elf32-i386


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
  800059:	c7 04 24 80 21 80 00 	movl   $0x802180,(%esp)
  800060:	e8 31 01 00 00       	call   800196 <cprintf>
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
  800081:	e8 7b 0e 00 00       	call   800f01 <set_pgfault_handler>
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
  8000b2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b7:	85 db                	test   %ebx,%ebx
  8000b9:	7e 07                	jle    8000c2 <libmain+0x30>
		binaryname = argv[0];
  8000bb:	8b 06                	mov    (%esi),%eax
  8000bd:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  8000e0:	e8 e1 10 00 00       	call   8011c6 <close_all>
	sys_env_destroy(0);
  8000e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ec:	e8 18 0b 00 00       	call   800c09 <sys_env_destroy>
}
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    

008000f3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 14             	sub    $0x14,%esp
  8000fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fd:	8b 13                	mov    (%ebx),%edx
  8000ff:	8d 42 01             	lea    0x1(%edx),%eax
  800102:	89 03                	mov    %eax,(%ebx)
  800104:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800107:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80010b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800110:	75 19                	jne    80012b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800112:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800119:	00 
  80011a:	8d 43 08             	lea    0x8(%ebx),%eax
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 a7 0a 00 00       	call   800bcc <sys_cputs>
		b->idx = 0;
  800125:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80012b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012f:	83 c4 14             	add    $0x14,%esp
  800132:	5b                   	pop    %ebx
  800133:	5d                   	pop    %ebp
  800134:	c3                   	ret    

00800135 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80013e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800145:	00 00 00 
	b.cnt = 0;
  800148:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800152:	8b 45 0c             	mov    0xc(%ebp),%eax
  800155:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800159:	8b 45 08             	mov    0x8(%ebp),%eax
  80015c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800160:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800166:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016a:	c7 04 24 f3 00 80 00 	movl   $0x8000f3,(%esp)
  800171:	e8 ae 01 00 00       	call   800324 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800176:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	89 04 24             	mov    %eax,(%esp)
  800189:	e8 3e 0a 00 00       	call   800bcc <sys_cputs>

	return b.cnt;
}
  80018e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800194:	c9                   	leave  
  800195:	c3                   	ret    

00800196 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 87 ff ff ff       	call   800135 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

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
  80022c:	e8 af 1c 00 00       	call   801ee0 <__udivdi3>
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
  800285:	e8 86 1d 00 00       	call   802010 <__umoddi3>
  80028a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80028e:	0f be 80 a6 21 80 00 	movsbl 0x8021a6(%eax),%eax
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
  8003ac:	ff 24 85 e0 22 80 00 	jmp    *0x8022e0(,%eax,4)
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
  80045a:	83 f8 0f             	cmp    $0xf,%eax
  80045d:	7f 0b                	jg     80046a <vprintfmt+0x146>
  80045f:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 20                	jne    80048a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80046a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046e:	c7 44 24 08 be 21 80 	movl   $0x8021be,0x8(%esp)
  800475:	00 
  800476:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80047a:	8b 45 08             	mov    0x8(%ebp),%eax
  80047d:	89 04 24             	mov    %eax,(%esp)
  800480:	e8 77 fe ff ff       	call   8002fc <printfmt>
  800485:	e9 c3 fe ff ff       	jmp    80034d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80048a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048e:	c7 44 24 08 d3 25 80 	movl   $0x8025d3,0x8(%esp)
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
  8004bd:	ba b7 21 80 00       	mov    $0x8021b7,%edx
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
  800c37:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800c3e:	00 
  800c3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c46:	00 
  800c47:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800c4e:	e8 03 11 00 00       	call   801d56 <_panic>
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
  800c85:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800cc9:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800cd0:	00 
  800cd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd8:	00 
  800cd9:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800ce0:	e8 71 10 00 00       	call   801d56 <_panic>
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
  800d1c:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800d23:	00 
  800d24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2b:	00 
  800d2c:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800d33:	e8 1e 10 00 00       	call   801d56 <_panic>
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
  800d6f:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800d76:	00 
  800d77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7e:	00 
  800d7f:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800d86:	e8 cb 0f 00 00       	call   801d56 <_panic>
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
  800dc2:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800dc9:	00 
  800dca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd1:	00 
  800dd2:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800dd9:	e8 78 0f 00 00       	call   801d56 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dde:	83 c4 2c             	add    $0x2c,%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800e07:	7e 28                	jle    800e31 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e09:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e14:	00 
  800e15:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800e1c:	00 
  800e1d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e24:	00 
  800e25:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800e2c:	e8 25 0f 00 00       	call   801d56 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e31:	83 c4 2c             	add    $0x2c,%esp
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	57                   	push   %edi
  800e3d:	56                   	push   %esi
  800e3e:	53                   	push   %ebx
  800e3f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e47:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e52:	89 df                	mov    %ebx,%edi
  800e54:	89 de                	mov    %ebx,%esi
  800e56:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	7e 28                	jle    800e84 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e60:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e67:	00 
  800e68:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800e6f:	00 
  800e70:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e77:	00 
  800e78:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800e7f:	e8 d2 0e 00 00       	call   801d56 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e84:	83 c4 2c             	add    $0x2c,%esp
  800e87:	5b                   	pop    %ebx
  800e88:	5e                   	pop    %esi
  800e89:	5f                   	pop    %edi
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	57                   	push   %edi
  800e90:	56                   	push   %esi
  800e91:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e92:	be 00 00 00 00       	mov    $0x0,%esi
  800e97:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eaa:	5b                   	pop    %ebx
  800eab:	5e                   	pop    %esi
  800eac:	5f                   	pop    %edi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	57                   	push   %edi
  800eb3:	56                   	push   %esi
  800eb4:	53                   	push   %ebx
  800eb5:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800eb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ebd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ec2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec5:	89 cb                	mov    %ecx,%ebx
  800ec7:	89 cf                	mov    %ecx,%edi
  800ec9:	89 ce                	mov    %ecx,%esi
  800ecb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	7e 28                	jle    800ef9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800edc:	00 
  800edd:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800ee4:	00 
  800ee5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eec:	00 
  800eed:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800ef4:	e8 5d 0e 00 00       	call   801d56 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ef9:	83 c4 2c             	add    $0x2c,%esp
  800efc:	5b                   	pop    %ebx
  800efd:	5e                   	pop    %esi
  800efe:	5f                   	pop    %edi
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f07:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800f0e:	75 70                	jne    800f80 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  800f10:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f17:	00 
  800f18:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f1f:	ee 
  800f20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f27:	e8 6d fd ff ff       	call   800c99 <sys_page_alloc>
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	79 1c                	jns    800f4c <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  800f30:	c7 44 24 08 cc 24 80 	movl   $0x8024cc,0x8(%esp)
  800f37:	00 
  800f38:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f3f:	00 
  800f40:	c7 04 24 2f 25 80 00 	movl   $0x80252f,(%esp)
  800f47:	e8 0a 0e 00 00       	call   801d56 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800f4c:	c7 44 24 04 8a 0f 80 	movl   $0x800f8a,0x4(%esp)
  800f53:	00 
  800f54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f5b:	e8 d9 fe ff ff       	call   800e39 <sys_env_set_pgfault_upcall>
  800f60:	85 c0                	test   %eax,%eax
  800f62:	79 1c                	jns    800f80 <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  800f64:	c7 44 24 08 f8 24 80 	movl   $0x8024f8,0x8(%esp)
  800f6b:	00 
  800f6c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800f73:	00 
  800f74:	c7 04 24 2f 25 80 00 	movl   $0x80252f,(%esp)
  800f7b:	e8 d6 0d 00 00       	call   801d56 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f80:	8b 45 08             	mov    0x8(%ebp),%eax
  800f83:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800f88:	c9                   	leave  
  800f89:	c3                   	ret    

00800f8a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f8a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f8b:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800f90:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f92:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  800f95:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  800f99:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  800f9e:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  800fa2:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800fa4:	83 c4 08             	add    $0x8,%esp
	popal
  800fa7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800fa8:	83 c4 04             	add    $0x4,%esp
	popfl
  800fab:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800fac:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800fad:	c3                   	ret    
  800fae:	66 90                	xchg   %ax,%ax

00800fb0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb6:	05 00 00 00 30       	add    $0x30000000,%eax
  800fbb:	c1 e8 0c             	shr    $0xc,%eax
}
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800fcb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fd0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fda:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800fdf:	a8 01                	test   $0x1,%al
  800fe1:	74 34                	je     801017 <fd_alloc+0x40>
  800fe3:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800fe8:	a8 01                	test   $0x1,%al
  800fea:	74 32                	je     80101e <fd_alloc+0x47>
  800fec:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  800ff1:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ff3:	89 c2                	mov    %eax,%edx
  800ff5:	c1 ea 16             	shr    $0x16,%edx
  800ff8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fff:	f6 c2 01             	test   $0x1,%dl
  801002:	74 1f                	je     801023 <fd_alloc+0x4c>
  801004:	89 c2                	mov    %eax,%edx
  801006:	c1 ea 0c             	shr    $0xc,%edx
  801009:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801010:	f6 c2 01             	test   $0x1,%dl
  801013:	75 1a                	jne    80102f <fd_alloc+0x58>
  801015:	eb 0c                	jmp    801023 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  801017:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80101c:	eb 05                	jmp    801023 <fd_alloc+0x4c>
  80101e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  801023:	8b 45 08             	mov    0x8(%ebp),%eax
  801026:	89 08                	mov    %ecx,(%eax)
			return 0;
  801028:	b8 00 00 00 00       	mov    $0x0,%eax
  80102d:	eb 1a                	jmp    801049 <fd_alloc+0x72>
  80102f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801034:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801039:	75 b6                	jne    800ff1 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  80103b:	8b 45 08             	mov    0x8(%ebp),%eax
  80103e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801044:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    

0080104b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801051:	83 f8 1f             	cmp    $0x1f,%eax
  801054:	77 36                	ja     80108c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801056:	c1 e0 0c             	shl    $0xc,%eax
  801059:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80105e:	89 c2                	mov    %eax,%edx
  801060:	c1 ea 16             	shr    $0x16,%edx
  801063:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80106a:	f6 c2 01             	test   $0x1,%dl
  80106d:	74 24                	je     801093 <fd_lookup+0x48>
  80106f:	89 c2                	mov    %eax,%edx
  801071:	c1 ea 0c             	shr    $0xc,%edx
  801074:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80107b:	f6 c2 01             	test   $0x1,%dl
  80107e:	74 1a                	je     80109a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801080:	8b 55 0c             	mov    0xc(%ebp),%edx
  801083:	89 02                	mov    %eax,(%edx)
	return 0;
  801085:	b8 00 00 00 00       	mov    $0x0,%eax
  80108a:	eb 13                	jmp    80109f <fd_lookup+0x54>
		return -E_INVAL;
  80108c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801091:	eb 0c                	jmp    80109f <fd_lookup+0x54>
		return -E_INVAL;
  801093:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801098:	eb 05                	jmp    80109f <fd_lookup+0x54>
  80109a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80109f:	5d                   	pop    %ebp
  8010a0:	c3                   	ret    

008010a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	53                   	push   %ebx
  8010a5:	83 ec 14             	sub    $0x14,%esp
  8010a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8010ae:	39 05 04 30 80 00    	cmp    %eax,0x803004
  8010b4:	75 1e                	jne    8010d4 <dev_lookup+0x33>
  8010b6:	eb 0e                	jmp    8010c6 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  8010b8:	b8 20 30 80 00       	mov    $0x803020,%eax
  8010bd:	eb 0c                	jmp    8010cb <dev_lookup+0x2a>
  8010bf:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  8010c4:	eb 05                	jmp    8010cb <dev_lookup+0x2a>
  8010c6:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  8010cb:	89 03                	mov    %eax,(%ebx)
			return 0;
  8010cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d2:	eb 38                	jmp    80110c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  8010d4:	39 05 20 30 80 00    	cmp    %eax,0x803020
  8010da:	74 dc                	je     8010b8 <dev_lookup+0x17>
  8010dc:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  8010e2:	74 db                	je     8010bf <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010e4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8010ea:	8b 52 48             	mov    0x48(%edx),%edx
  8010ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010f5:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  8010fc:	e8 95 f0 ff ff       	call   800196 <cprintf>
	*dev = 0;
  801101:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801107:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80110c:	83 c4 14             	add    $0x14,%esp
  80110f:	5b                   	pop    %ebx
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    

00801112 <fd_close>:
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
  801115:	56                   	push   %esi
  801116:	53                   	push   %ebx
  801117:	83 ec 20             	sub    $0x20,%esp
  80111a:	8b 75 08             	mov    0x8(%ebp),%esi
  80111d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801120:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801123:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801127:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80112d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801130:	89 04 24             	mov    %eax,(%esp)
  801133:	e8 13 ff ff ff       	call   80104b <fd_lookup>
  801138:	85 c0                	test   %eax,%eax
  80113a:	78 05                	js     801141 <fd_close+0x2f>
	    || fd != fd2)
  80113c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80113f:	74 0c                	je     80114d <fd_close+0x3b>
		return (must_exist ? r : 0);
  801141:	84 db                	test   %bl,%bl
  801143:	ba 00 00 00 00       	mov    $0x0,%edx
  801148:	0f 44 c2             	cmove  %edx,%eax
  80114b:	eb 3f                	jmp    80118c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80114d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801150:	89 44 24 04          	mov    %eax,0x4(%esp)
  801154:	8b 06                	mov    (%esi),%eax
  801156:	89 04 24             	mov    %eax,(%esp)
  801159:	e8 43 ff ff ff       	call   8010a1 <dev_lookup>
  80115e:	89 c3                	mov    %eax,%ebx
  801160:	85 c0                	test   %eax,%eax
  801162:	78 16                	js     80117a <fd_close+0x68>
		if (dev->dev_close)
  801164:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801167:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80116a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80116f:	85 c0                	test   %eax,%eax
  801171:	74 07                	je     80117a <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801173:	89 34 24             	mov    %esi,(%esp)
  801176:	ff d0                	call   *%eax
  801178:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  80117a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80117e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801185:	e8 b6 fb ff ff       	call   800d40 <sys_page_unmap>
	return r;
  80118a:	89 d8                	mov    %ebx,%eax
}
  80118c:	83 c4 20             	add    $0x20,%esp
  80118f:	5b                   	pop    %ebx
  801190:	5e                   	pop    %esi
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <close>:

int
close(int fdnum)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801199:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a3:	89 04 24             	mov    %eax,(%esp)
  8011a6:	e8 a0 fe ff ff       	call   80104b <fd_lookup>
  8011ab:	89 c2                	mov    %eax,%edx
  8011ad:	85 d2                	test   %edx,%edx
  8011af:	78 13                	js     8011c4 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8011b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011b8:	00 
  8011b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011bc:	89 04 24             	mov    %eax,(%esp)
  8011bf:	e8 4e ff ff ff       	call   801112 <fd_close>
}
  8011c4:	c9                   	leave  
  8011c5:	c3                   	ret    

008011c6 <close_all>:

void
close_all(void)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	53                   	push   %ebx
  8011ca:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011cd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011d2:	89 1c 24             	mov    %ebx,(%esp)
  8011d5:	e8 b9 ff ff ff       	call   801193 <close>
	for (i = 0; i < MAXFD; i++)
  8011da:	83 c3 01             	add    $0x1,%ebx
  8011dd:	83 fb 20             	cmp    $0x20,%ebx
  8011e0:	75 f0                	jne    8011d2 <close_all+0xc>
}
  8011e2:	83 c4 14             	add    $0x14,%esp
  8011e5:	5b                   	pop    %ebx
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	57                   	push   %edi
  8011ec:	56                   	push   %esi
  8011ed:	53                   	push   %ebx
  8011ee:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011f1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fb:	89 04 24             	mov    %eax,(%esp)
  8011fe:	e8 48 fe ff ff       	call   80104b <fd_lookup>
  801203:	89 c2                	mov    %eax,%edx
  801205:	85 d2                	test   %edx,%edx
  801207:	0f 88 e1 00 00 00    	js     8012ee <dup+0x106>
		return r;
	close(newfdnum);
  80120d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801210:	89 04 24             	mov    %eax,(%esp)
  801213:	e8 7b ff ff ff       	call   801193 <close>

	newfd = INDEX2FD(newfdnum);
  801218:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80121b:	c1 e3 0c             	shl    $0xc,%ebx
  80121e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801224:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801227:	89 04 24             	mov    %eax,(%esp)
  80122a:	e8 91 fd ff ff       	call   800fc0 <fd2data>
  80122f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801231:	89 1c 24             	mov    %ebx,(%esp)
  801234:	e8 87 fd ff ff       	call   800fc0 <fd2data>
  801239:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80123b:	89 f0                	mov    %esi,%eax
  80123d:	c1 e8 16             	shr    $0x16,%eax
  801240:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801247:	a8 01                	test   $0x1,%al
  801249:	74 43                	je     80128e <dup+0xa6>
  80124b:	89 f0                	mov    %esi,%eax
  80124d:	c1 e8 0c             	shr    $0xc,%eax
  801250:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801257:	f6 c2 01             	test   $0x1,%dl
  80125a:	74 32                	je     80128e <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80125c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801263:	25 07 0e 00 00       	and    $0xe07,%eax
  801268:	89 44 24 10          	mov    %eax,0x10(%esp)
  80126c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801270:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801277:	00 
  801278:	89 74 24 04          	mov    %esi,0x4(%esp)
  80127c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801283:	e8 65 fa ff ff       	call   800ced <sys_page_map>
  801288:	89 c6                	mov    %eax,%esi
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 3e                	js     8012cc <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80128e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801291:	89 c2                	mov    %eax,%edx
  801293:	c1 ea 0c             	shr    $0xc,%edx
  801296:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80129d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8012a3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012a7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012b2:	00 
  8012b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012be:	e8 2a fa ff ff       	call   800ced <sys_page_map>
  8012c3:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8012c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012c8:	85 f6                	test   %esi,%esi
  8012ca:	79 22                	jns    8012ee <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8012cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d7:	e8 64 fa ff ff       	call   800d40 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012e7:	e8 54 fa ff ff       	call   800d40 <sys_page_unmap>
	return r;
  8012ec:	89 f0                	mov    %esi,%eax
}
  8012ee:	83 c4 3c             	add    $0x3c,%esp
  8012f1:	5b                   	pop    %ebx
  8012f2:	5e                   	pop    %esi
  8012f3:	5f                   	pop    %edi
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	53                   	push   %ebx
  8012fa:	83 ec 24             	sub    $0x24,%esp
  8012fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801300:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801303:	89 44 24 04          	mov    %eax,0x4(%esp)
  801307:	89 1c 24             	mov    %ebx,(%esp)
  80130a:	e8 3c fd ff ff       	call   80104b <fd_lookup>
  80130f:	89 c2                	mov    %eax,%edx
  801311:	85 d2                	test   %edx,%edx
  801313:	78 6d                	js     801382 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801315:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801318:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131f:	8b 00                	mov    (%eax),%eax
  801321:	89 04 24             	mov    %eax,(%esp)
  801324:	e8 78 fd ff ff       	call   8010a1 <dev_lookup>
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 55                	js     801382 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80132d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801330:	8b 50 08             	mov    0x8(%eax),%edx
  801333:	83 e2 03             	and    $0x3,%edx
  801336:	83 fa 01             	cmp    $0x1,%edx
  801339:	75 23                	jne    80135e <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80133b:	a1 04 40 80 00       	mov    0x804004,%eax
  801340:	8b 40 48             	mov    0x48(%eax),%eax
  801343:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801347:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134b:	c7 04 24 81 25 80 00 	movl   $0x802581,(%esp)
  801352:	e8 3f ee ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  801357:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135c:	eb 24                	jmp    801382 <read+0x8c>
	}
	if (!dev->dev_read)
  80135e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801361:	8b 52 08             	mov    0x8(%edx),%edx
  801364:	85 d2                	test   %edx,%edx
  801366:	74 15                	je     80137d <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801368:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80136b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80136f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801372:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801376:	89 04 24             	mov    %eax,(%esp)
  801379:	ff d2                	call   *%edx
  80137b:	eb 05                	jmp    801382 <read+0x8c>
		return -E_NOT_SUPP;
  80137d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801382:	83 c4 24             	add    $0x24,%esp
  801385:	5b                   	pop    %ebx
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    

00801388 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	57                   	push   %edi
  80138c:	56                   	push   %esi
  80138d:	53                   	push   %ebx
  80138e:	83 ec 1c             	sub    $0x1c,%esp
  801391:	8b 7d 08             	mov    0x8(%ebp),%edi
  801394:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801397:	85 f6                	test   %esi,%esi
  801399:	74 33                	je     8013ce <readn+0x46>
  80139b:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a0:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013a5:	89 f2                	mov    %esi,%edx
  8013a7:	29 c2                	sub    %eax,%edx
  8013a9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013ad:	03 45 0c             	add    0xc(%ebp),%eax
  8013b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b4:	89 3c 24             	mov    %edi,(%esp)
  8013b7:	e8 3a ff ff ff       	call   8012f6 <read>
		if (m < 0)
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 1b                	js     8013db <readn+0x53>
			return m;
		if (m == 0)
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	74 11                	je     8013d5 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  8013c4:	01 c3                	add    %eax,%ebx
  8013c6:	89 d8                	mov    %ebx,%eax
  8013c8:	39 f3                	cmp    %esi,%ebx
  8013ca:	72 d9                	jb     8013a5 <readn+0x1d>
  8013cc:	eb 0b                	jmp    8013d9 <readn+0x51>
  8013ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d3:	eb 06                	jmp    8013db <readn+0x53>
  8013d5:	89 d8                	mov    %ebx,%eax
  8013d7:	eb 02                	jmp    8013db <readn+0x53>
  8013d9:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8013db:	83 c4 1c             	add    $0x1c,%esp
  8013de:	5b                   	pop    %ebx
  8013df:	5e                   	pop    %esi
  8013e0:	5f                   	pop    %edi
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    

008013e3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	53                   	push   %ebx
  8013e7:	83 ec 24             	sub    $0x24,%esp
  8013ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f4:	89 1c 24             	mov    %ebx,(%esp)
  8013f7:	e8 4f fc ff ff       	call   80104b <fd_lookup>
  8013fc:	89 c2                	mov    %eax,%edx
  8013fe:	85 d2                	test   %edx,%edx
  801400:	78 68                	js     80146a <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801402:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801405:	89 44 24 04          	mov    %eax,0x4(%esp)
  801409:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140c:	8b 00                	mov    (%eax),%eax
  80140e:	89 04 24             	mov    %eax,(%esp)
  801411:	e8 8b fc ff ff       	call   8010a1 <dev_lookup>
  801416:	85 c0                	test   %eax,%eax
  801418:	78 50                	js     80146a <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80141a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801421:	75 23                	jne    801446 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801423:	a1 04 40 80 00       	mov    0x804004,%eax
  801428:	8b 40 48             	mov    0x48(%eax),%eax
  80142b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80142f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801433:	c7 04 24 9d 25 80 00 	movl   $0x80259d,(%esp)
  80143a:	e8 57 ed ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  80143f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801444:	eb 24                	jmp    80146a <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801446:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801449:	8b 52 0c             	mov    0xc(%edx),%edx
  80144c:	85 d2                	test   %edx,%edx
  80144e:	74 15                	je     801465 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801450:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801453:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801457:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80145a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80145e:	89 04 24             	mov    %eax,(%esp)
  801461:	ff d2                	call   *%edx
  801463:	eb 05                	jmp    80146a <write+0x87>
		return -E_NOT_SUPP;
  801465:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80146a:	83 c4 24             	add    $0x24,%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <seek>:

int
seek(int fdnum, off_t offset)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801476:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801479:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147d:	8b 45 08             	mov    0x8(%ebp),%eax
  801480:	89 04 24             	mov    %eax,(%esp)
  801483:	e8 c3 fb ff ff       	call   80104b <fd_lookup>
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 0e                	js     80149a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80148c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80148f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801492:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801495:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149a:	c9                   	leave  
  80149b:	c3                   	ret    

0080149c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	53                   	push   %ebx
  8014a0:	83 ec 24             	sub    $0x24,%esp
  8014a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ad:	89 1c 24             	mov    %ebx,(%esp)
  8014b0:	e8 96 fb ff ff       	call   80104b <fd_lookup>
  8014b5:	89 c2                	mov    %eax,%edx
  8014b7:	85 d2                	test   %edx,%edx
  8014b9:	78 61                	js     80151c <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c5:	8b 00                	mov    (%eax),%eax
  8014c7:	89 04 24             	mov    %eax,(%esp)
  8014ca:	e8 d2 fb ff ff       	call   8010a1 <dev_lookup>
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 49                	js     80151c <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014da:	75 23                	jne    8014ff <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014dc:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014e1:	8b 40 48             	mov    0x48(%eax),%eax
  8014e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ec:	c7 04 24 60 25 80 00 	movl   $0x802560,(%esp)
  8014f3:	e8 9e ec ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  8014f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014fd:	eb 1d                	jmp    80151c <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8014ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801502:	8b 52 18             	mov    0x18(%edx),%edx
  801505:	85 d2                	test   %edx,%edx
  801507:	74 0e                	je     801517 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801509:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80150c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801510:	89 04 24             	mov    %eax,(%esp)
  801513:	ff d2                	call   *%edx
  801515:	eb 05                	jmp    80151c <ftruncate+0x80>
		return -E_NOT_SUPP;
  801517:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80151c:	83 c4 24             	add    $0x24,%esp
  80151f:	5b                   	pop    %ebx
  801520:	5d                   	pop    %ebp
  801521:	c3                   	ret    

00801522 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	53                   	push   %ebx
  801526:	83 ec 24             	sub    $0x24,%esp
  801529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801533:	8b 45 08             	mov    0x8(%ebp),%eax
  801536:	89 04 24             	mov    %eax,(%esp)
  801539:	e8 0d fb ff ff       	call   80104b <fd_lookup>
  80153e:	89 c2                	mov    %eax,%edx
  801540:	85 d2                	test   %edx,%edx
  801542:	78 52                	js     801596 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801544:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801547:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154e:	8b 00                	mov    (%eax),%eax
  801550:	89 04 24             	mov    %eax,(%esp)
  801553:	e8 49 fb ff ff       	call   8010a1 <dev_lookup>
  801558:	85 c0                	test   %eax,%eax
  80155a:	78 3a                	js     801596 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80155c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801563:	74 2c                	je     801591 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801565:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801568:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80156f:	00 00 00 
	stat->st_isdir = 0;
  801572:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801579:	00 00 00 
	stat->st_dev = dev;
  80157c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801582:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801586:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801589:	89 14 24             	mov    %edx,(%esp)
  80158c:	ff 50 14             	call   *0x14(%eax)
  80158f:	eb 05                	jmp    801596 <fstat+0x74>
		return -E_NOT_SUPP;
  801591:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801596:	83 c4 24             	add    $0x24,%esp
  801599:	5b                   	pop    %ebx
  80159a:	5d                   	pop    %ebp
  80159b:	c3                   	ret    

0080159c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	56                   	push   %esi
  8015a0:	53                   	push   %ebx
  8015a1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015ab:	00 
  8015ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8015af:	89 04 24             	mov    %eax,(%esp)
  8015b2:	e8 af 01 00 00       	call   801766 <open>
  8015b7:	89 c3                	mov    %eax,%ebx
  8015b9:	85 db                	test   %ebx,%ebx
  8015bb:	78 1b                	js     8015d8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8015bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c4:	89 1c 24             	mov    %ebx,(%esp)
  8015c7:	e8 56 ff ff ff       	call   801522 <fstat>
  8015cc:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ce:	89 1c 24             	mov    %ebx,(%esp)
  8015d1:	e8 bd fb ff ff       	call   801193 <close>
	return r;
  8015d6:	89 f0                	mov    %esi,%eax
}
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	5b                   	pop    %ebx
  8015dc:	5e                   	pop    %esi
  8015dd:	5d                   	pop    %ebp
  8015de:	c3                   	ret    

008015df <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	56                   	push   %esi
  8015e3:	53                   	push   %ebx
  8015e4:	83 ec 10             	sub    $0x10,%esp
  8015e7:	89 c6                	mov    %eax,%esi
  8015e9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015eb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015f2:	75 11                	jne    801605 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8015fb:	e8 50 08 00 00       	call   801e50 <ipc_find_env>
  801600:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801605:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80160c:	00 
  80160d:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801614:	00 
  801615:	89 74 24 04          	mov    %esi,0x4(%esp)
  801619:	a1 00 40 80 00       	mov    0x804000,%eax
  80161e:	89 04 24             	mov    %eax,(%esp)
  801621:	e8 e2 07 00 00       	call   801e08 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801626:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80162d:	00 
  80162e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801632:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801639:	e8 6e 07 00 00       	call   801dac <ipc_recv>
}
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	5d                   	pop    %ebp
  801644:	c3                   	ret    

00801645 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	53                   	push   %ebx
  801649:	83 ec 14             	sub    $0x14,%esp
  80164c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80164f:	8b 45 08             	mov    0x8(%ebp),%eax
  801652:	8b 40 0c             	mov    0xc(%eax),%eax
  801655:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80165a:	ba 00 00 00 00       	mov    $0x0,%edx
  80165f:	b8 05 00 00 00       	mov    $0x5,%eax
  801664:	e8 76 ff ff ff       	call   8015df <fsipc>
  801669:	89 c2                	mov    %eax,%edx
  80166b:	85 d2                	test   %edx,%edx
  80166d:	78 2b                	js     80169a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80166f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801676:	00 
  801677:	89 1c 24             	mov    %ebx,(%esp)
  80167a:	e8 6c f1 ff ff       	call   8007eb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80167f:	a1 80 50 80 00       	mov    0x805080,%eax
  801684:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80168a:	a1 84 50 80 00       	mov    0x805084,%eax
  80168f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801695:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80169a:	83 c4 14             	add    $0x14,%esp
  80169d:	5b                   	pop    %ebx
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    

008016a0 <devfile_flush>:
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ac:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b6:	b8 06 00 00 00       	mov    $0x6,%eax
  8016bb:	e8 1f ff ff ff       	call   8015df <fsipc>
}
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <devfile_read>:
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	56                   	push   %esi
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 10             	sub    $0x10,%esp
  8016ca:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016d8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016de:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e3:	b8 03 00 00 00       	mov    $0x3,%eax
  8016e8:	e8 f2 fe ff ff       	call   8015df <fsipc>
  8016ed:	89 c3                	mov    %eax,%ebx
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	78 6a                	js     80175d <devfile_read+0x9b>
	assert(r <= n);
  8016f3:	39 c6                	cmp    %eax,%esi
  8016f5:	73 24                	jae    80171b <devfile_read+0x59>
  8016f7:	c7 44 24 0c ba 25 80 	movl   $0x8025ba,0xc(%esp)
  8016fe:	00 
  8016ff:	c7 44 24 08 c1 25 80 	movl   $0x8025c1,0x8(%esp)
  801706:	00 
  801707:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80170e:	00 
  80170f:	c7 04 24 d6 25 80 00 	movl   $0x8025d6,(%esp)
  801716:	e8 3b 06 00 00       	call   801d56 <_panic>
	assert(r <= PGSIZE);
  80171b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801720:	7e 24                	jle    801746 <devfile_read+0x84>
  801722:	c7 44 24 0c e1 25 80 	movl   $0x8025e1,0xc(%esp)
  801729:	00 
  80172a:	c7 44 24 08 c1 25 80 	movl   $0x8025c1,0x8(%esp)
  801731:	00 
  801732:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801739:	00 
  80173a:	c7 04 24 d6 25 80 00 	movl   $0x8025d6,(%esp)
  801741:	e8 10 06 00 00       	call   801d56 <_panic>
	memmove(buf, &fsipcbuf, r);
  801746:	89 44 24 08          	mov    %eax,0x8(%esp)
  80174a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801751:	00 
  801752:	8b 45 0c             	mov    0xc(%ebp),%eax
  801755:	89 04 24             	mov    %eax,(%esp)
  801758:	e8 89 f2 ff ff       	call   8009e6 <memmove>
}
  80175d:	89 d8                	mov    %ebx,%eax
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	5b                   	pop    %ebx
  801763:	5e                   	pop    %esi
  801764:	5d                   	pop    %ebp
  801765:	c3                   	ret    

00801766 <open>:
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	53                   	push   %ebx
  80176a:	83 ec 24             	sub    $0x24,%esp
  80176d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801770:	89 1c 24             	mov    %ebx,(%esp)
  801773:	e8 18 f0 ff ff       	call   800790 <strlen>
  801778:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80177d:	7f 60                	jg     8017df <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80177f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801782:	89 04 24             	mov    %eax,(%esp)
  801785:	e8 4d f8 ff ff       	call   800fd7 <fd_alloc>
  80178a:	89 c2                	mov    %eax,%edx
  80178c:	85 d2                	test   %edx,%edx
  80178e:	78 54                	js     8017e4 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801790:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801794:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80179b:	e8 4b f0 ff ff       	call   8007eb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8017b0:	e8 2a fe ff ff       	call   8015df <fsipc>
  8017b5:	89 c3                	mov    %eax,%ebx
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	79 17                	jns    8017d2 <open+0x6c>
		fd_close(fd, 0);
  8017bb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017c2:	00 
  8017c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c6:	89 04 24             	mov    %eax,(%esp)
  8017c9:	e8 44 f9 ff ff       	call   801112 <fd_close>
		return r;
  8017ce:	89 d8                	mov    %ebx,%eax
  8017d0:	eb 12                	jmp    8017e4 <open+0x7e>
	return fd2num(fd);
  8017d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d5:	89 04 24             	mov    %eax,(%esp)
  8017d8:	e8 d3 f7 ff ff       	call   800fb0 <fd2num>
  8017dd:	eb 05                	jmp    8017e4 <open+0x7e>
		return -E_BAD_PATH;
  8017df:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  8017e4:	83 c4 24             	add    $0x24,%esp
  8017e7:	5b                   	pop    %ebx
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    
  8017ea:	66 90                	xchg   %ax,%ax
  8017ec:	66 90                	xchg   %ax,%ax
  8017ee:	66 90                	xchg   %ax,%ax

008017f0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	56                   	push   %esi
  8017f4:	53                   	push   %ebx
  8017f5:	83 ec 10             	sub    $0x10,%esp
  8017f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fe:	89 04 24             	mov    %eax,(%esp)
  801801:	e8 ba f7 ff ff       	call   800fc0 <fd2data>
  801806:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801808:	c7 44 24 04 ed 25 80 	movl   $0x8025ed,0x4(%esp)
  80180f:	00 
  801810:	89 1c 24             	mov    %ebx,(%esp)
  801813:	e8 d3 ef ff ff       	call   8007eb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801818:	8b 46 04             	mov    0x4(%esi),%eax
  80181b:	2b 06                	sub    (%esi),%eax
  80181d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801823:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80182a:	00 00 00 
	stat->st_dev = &devpipe;
  80182d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801834:	30 80 00 
	return 0;
}
  801837:	b8 00 00 00 00       	mov    $0x0,%eax
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	5b                   	pop    %ebx
  801840:	5e                   	pop    %esi
  801841:	5d                   	pop    %ebp
  801842:	c3                   	ret    

00801843 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	53                   	push   %ebx
  801847:	83 ec 14             	sub    $0x14,%esp
  80184a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80184d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801851:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801858:	e8 e3 f4 ff ff       	call   800d40 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80185d:	89 1c 24             	mov    %ebx,(%esp)
  801860:	e8 5b f7 ff ff       	call   800fc0 <fd2data>
  801865:	89 44 24 04          	mov    %eax,0x4(%esp)
  801869:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801870:	e8 cb f4 ff ff       	call   800d40 <sys_page_unmap>
}
  801875:	83 c4 14             	add    $0x14,%esp
  801878:	5b                   	pop    %ebx
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    

0080187b <_pipeisclosed>:
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	57                   	push   %edi
  80187f:	56                   	push   %esi
  801880:	53                   	push   %ebx
  801881:	83 ec 2c             	sub    $0x2c,%esp
  801884:	89 c6                	mov    %eax,%esi
  801886:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801889:	a1 04 40 80 00       	mov    0x804004,%eax
  80188e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801891:	89 34 24             	mov    %esi,(%esp)
  801894:	e8 ff 05 00 00       	call   801e98 <pageref>
  801899:	89 c7                	mov    %eax,%edi
  80189b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80189e:	89 04 24             	mov    %eax,(%esp)
  8018a1:	e8 f2 05 00 00       	call   801e98 <pageref>
  8018a6:	39 c7                	cmp    %eax,%edi
  8018a8:	0f 94 c2             	sete   %dl
  8018ab:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8018ae:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  8018b4:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8018b7:	39 fb                	cmp    %edi,%ebx
  8018b9:	74 21                	je     8018dc <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  8018bb:	84 d2                	test   %dl,%dl
  8018bd:	74 ca                	je     801889 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018bf:	8b 51 58             	mov    0x58(%ecx),%edx
  8018c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018c6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018ce:	c7 04 24 f4 25 80 00 	movl   $0x8025f4,(%esp)
  8018d5:	e8 bc e8 ff ff       	call   800196 <cprintf>
  8018da:	eb ad                	jmp    801889 <_pipeisclosed+0xe>
}
  8018dc:	83 c4 2c             	add    $0x2c,%esp
  8018df:	5b                   	pop    %ebx
  8018e0:	5e                   	pop    %esi
  8018e1:	5f                   	pop    %edi
  8018e2:	5d                   	pop    %ebp
  8018e3:	c3                   	ret    

008018e4 <devpipe_write>:
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	57                   	push   %edi
  8018e8:	56                   	push   %esi
  8018e9:	53                   	push   %ebx
  8018ea:	83 ec 1c             	sub    $0x1c,%esp
  8018ed:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8018f0:	89 34 24             	mov    %esi,(%esp)
  8018f3:	e8 c8 f6 ff ff       	call   800fc0 <fd2data>
	for (i = 0; i < n; i++) {
  8018f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018fc:	74 61                	je     80195f <devpipe_write+0x7b>
  8018fe:	89 c3                	mov    %eax,%ebx
  801900:	bf 00 00 00 00       	mov    $0x0,%edi
  801905:	eb 4a                	jmp    801951 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  801907:	89 da                	mov    %ebx,%edx
  801909:	89 f0                	mov    %esi,%eax
  80190b:	e8 6b ff ff ff       	call   80187b <_pipeisclosed>
  801910:	85 c0                	test   %eax,%eax
  801912:	75 54                	jne    801968 <devpipe_write+0x84>
			sys_yield();
  801914:	e8 61 f3 ff ff       	call   800c7a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801919:	8b 43 04             	mov    0x4(%ebx),%eax
  80191c:	8b 0b                	mov    (%ebx),%ecx
  80191e:	8d 51 20             	lea    0x20(%ecx),%edx
  801921:	39 d0                	cmp    %edx,%eax
  801923:	73 e2                	jae    801907 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801925:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801928:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80192c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80192f:	99                   	cltd   
  801930:	c1 ea 1b             	shr    $0x1b,%edx
  801933:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801936:	83 e1 1f             	and    $0x1f,%ecx
  801939:	29 d1                	sub    %edx,%ecx
  80193b:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80193f:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801943:	83 c0 01             	add    $0x1,%eax
  801946:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801949:	83 c7 01             	add    $0x1,%edi
  80194c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80194f:	74 13                	je     801964 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801951:	8b 43 04             	mov    0x4(%ebx),%eax
  801954:	8b 0b                	mov    (%ebx),%ecx
  801956:	8d 51 20             	lea    0x20(%ecx),%edx
  801959:	39 d0                	cmp    %edx,%eax
  80195b:	73 aa                	jae    801907 <devpipe_write+0x23>
  80195d:	eb c6                	jmp    801925 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  80195f:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  801964:	89 f8                	mov    %edi,%eax
  801966:	eb 05                	jmp    80196d <devpipe_write+0x89>
				return 0;
  801968:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80196d:	83 c4 1c             	add    $0x1c,%esp
  801970:	5b                   	pop    %ebx
  801971:	5e                   	pop    %esi
  801972:	5f                   	pop    %edi
  801973:	5d                   	pop    %ebp
  801974:	c3                   	ret    

00801975 <devpipe_read>:
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	57                   	push   %edi
  801979:	56                   	push   %esi
  80197a:	53                   	push   %ebx
  80197b:	83 ec 1c             	sub    $0x1c,%esp
  80197e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801981:	89 3c 24             	mov    %edi,(%esp)
  801984:	e8 37 f6 ff ff       	call   800fc0 <fd2data>
	for (i = 0; i < n; i++) {
  801989:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80198d:	74 54                	je     8019e3 <devpipe_read+0x6e>
  80198f:	89 c3                	mov    %eax,%ebx
  801991:	be 00 00 00 00       	mov    $0x0,%esi
  801996:	eb 3e                	jmp    8019d6 <devpipe_read+0x61>
				return i;
  801998:	89 f0                	mov    %esi,%eax
  80199a:	eb 55                	jmp    8019f1 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  80199c:	89 da                	mov    %ebx,%edx
  80199e:	89 f8                	mov    %edi,%eax
  8019a0:	e8 d6 fe ff ff       	call   80187b <_pipeisclosed>
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	75 43                	jne    8019ec <devpipe_read+0x77>
			sys_yield();
  8019a9:	e8 cc f2 ff ff       	call   800c7a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8019ae:	8b 03                	mov    (%ebx),%eax
  8019b0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019b3:	74 e7                	je     80199c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019b5:	99                   	cltd   
  8019b6:	c1 ea 1b             	shr    $0x1b,%edx
  8019b9:	01 d0                	add    %edx,%eax
  8019bb:	83 e0 1f             	and    $0x1f,%eax
  8019be:	29 d0                	sub    %edx,%eax
  8019c0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8019c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019c8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8019cb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8019ce:	83 c6 01             	add    $0x1,%esi
  8019d1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019d4:	74 12                	je     8019e8 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  8019d6:	8b 03                	mov    (%ebx),%eax
  8019d8:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019db:	75 d8                	jne    8019b5 <devpipe_read+0x40>
			if (i > 0)
  8019dd:	85 f6                	test   %esi,%esi
  8019df:	75 b7                	jne    801998 <devpipe_read+0x23>
  8019e1:	eb b9                	jmp    80199c <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  8019e3:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  8019e8:	89 f0                	mov    %esi,%eax
  8019ea:	eb 05                	jmp    8019f1 <devpipe_read+0x7c>
				return 0;
  8019ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019f1:	83 c4 1c             	add    $0x1c,%esp
  8019f4:	5b                   	pop    %ebx
  8019f5:	5e                   	pop    %esi
  8019f6:	5f                   	pop    %edi
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <pipe>:
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	56                   	push   %esi
  8019fd:	53                   	push   %ebx
  8019fe:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801a01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a04:	89 04 24             	mov    %eax,(%esp)
  801a07:	e8 cb f5 ff ff       	call   800fd7 <fd_alloc>
  801a0c:	89 c2                	mov    %eax,%edx
  801a0e:	85 d2                	test   %edx,%edx
  801a10:	0f 88 4d 01 00 00    	js     801b63 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a16:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a1d:	00 
  801a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a21:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a2c:	e8 68 f2 ff ff       	call   800c99 <sys_page_alloc>
  801a31:	89 c2                	mov    %eax,%edx
  801a33:	85 d2                	test   %edx,%edx
  801a35:	0f 88 28 01 00 00    	js     801b63 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801a3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a3e:	89 04 24             	mov    %eax,(%esp)
  801a41:	e8 91 f5 ff ff       	call   800fd7 <fd_alloc>
  801a46:	89 c3                	mov    %eax,%ebx
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	0f 88 fe 00 00 00    	js     801b4e <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a50:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a57:	00 
  801a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a66:	e8 2e f2 ff ff       	call   800c99 <sys_page_alloc>
  801a6b:	89 c3                	mov    %eax,%ebx
  801a6d:	85 c0                	test   %eax,%eax
  801a6f:	0f 88 d9 00 00 00    	js     801b4e <pipe+0x155>
	va = fd2data(fd0);
  801a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a78:	89 04 24             	mov    %eax,(%esp)
  801a7b:	e8 40 f5 ff ff       	call   800fc0 <fd2data>
  801a80:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a82:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a89:	00 
  801a8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a95:	e8 ff f1 ff ff       	call   800c99 <sys_page_alloc>
  801a9a:	89 c3                	mov    %eax,%ebx
  801a9c:	85 c0                	test   %eax,%eax
  801a9e:	0f 88 97 00 00 00    	js     801b3b <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aa7:	89 04 24             	mov    %eax,(%esp)
  801aaa:	e8 11 f5 ff ff       	call   800fc0 <fd2data>
  801aaf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ab6:	00 
  801ab7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801abb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ac2:	00 
  801ac3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ac7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ace:	e8 1a f2 ff ff       	call   800ced <sys_page_map>
  801ad3:	89 c3                	mov    %eax,%ebx
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	78 52                	js     801b2b <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801ad9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801aee:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801af7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801af9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801afc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b06:	89 04 24             	mov    %eax,(%esp)
  801b09:	e8 a2 f4 ff ff       	call   800fb0 <fd2num>
  801b0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b11:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b16:	89 04 24             	mov    %eax,(%esp)
  801b19:	e8 92 f4 ff ff       	call   800fb0 <fd2num>
  801b1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b21:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b24:	b8 00 00 00 00       	mov    $0x0,%eax
  801b29:	eb 38                	jmp    801b63 <pipe+0x16a>
	sys_page_unmap(0, va);
  801b2b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b36:	e8 05 f2 ff ff       	call   800d40 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801b3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b49:	e8 f2 f1 ff ff       	call   800d40 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b5c:	e8 df f1 ff ff       	call   800d40 <sys_page_unmap>
  801b61:	89 d8                	mov    %ebx,%eax
}
  801b63:	83 c4 30             	add    $0x30,%esp
  801b66:	5b                   	pop    %ebx
  801b67:	5e                   	pop    %esi
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    

00801b6a <pipeisclosed>:
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b77:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7a:	89 04 24             	mov    %eax,(%esp)
  801b7d:	e8 c9 f4 ff ff       	call   80104b <fd_lookup>
  801b82:	89 c2                	mov    %eax,%edx
  801b84:	85 d2                	test   %edx,%edx
  801b86:	78 15                	js     801b9d <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8b:	89 04 24             	mov    %eax,(%esp)
  801b8e:	e8 2d f4 ff ff       	call   800fc0 <fd2data>
	return _pipeisclosed(fd, p);
  801b93:	89 c2                	mov    %eax,%edx
  801b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b98:	e8 de fc ff ff       	call   80187b <_pipeisclosed>
}
  801b9d:	c9                   	leave  
  801b9e:	c3                   	ret    
  801b9f:	90                   	nop

00801ba0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba8:	5d                   	pop    %ebp
  801ba9:	c3                   	ret    

00801baa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801baa:	55                   	push   %ebp
  801bab:	89 e5                	mov    %esp,%ebp
  801bad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801bb0:	c7 44 24 04 0c 26 80 	movl   $0x80260c,0x4(%esp)
  801bb7:	00 
  801bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbb:	89 04 24             	mov    %eax,(%esp)
  801bbe:	e8 28 ec ff ff       	call   8007eb <strcpy>
	return 0;
}
  801bc3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc8:	c9                   	leave  
  801bc9:	c3                   	ret    

00801bca <devcons_write>:
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	57                   	push   %edi
  801bce:	56                   	push   %esi
  801bcf:	53                   	push   %ebx
  801bd0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801bd6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bda:	74 4a                	je     801c26 <devcons_write+0x5c>
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  801be1:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801be6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  801bec:	8b 75 10             	mov    0x10(%ebp),%esi
  801bef:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  801bf1:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801bf4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bf9:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801bfc:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c00:	03 45 0c             	add    0xc(%ebp),%eax
  801c03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c07:	89 3c 24             	mov    %edi,(%esp)
  801c0a:	e8 d7 ed ff ff       	call   8009e6 <memmove>
		sys_cputs(buf, m);
  801c0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c13:	89 3c 24             	mov    %edi,(%esp)
  801c16:	e8 b1 ef ff ff       	call   800bcc <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801c1b:	01 f3                	add    %esi,%ebx
  801c1d:	89 d8                	mov    %ebx,%eax
  801c1f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c22:	72 c8                	jb     801bec <devcons_write+0x22>
  801c24:	eb 05                	jmp    801c2b <devcons_write+0x61>
  801c26:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  801c2b:	89 d8                	mov    %ebx,%eax
  801c2d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5f                   	pop    %edi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    

00801c38 <devcons_read>:
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801c3e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801c43:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c47:	75 07                	jne    801c50 <devcons_read+0x18>
  801c49:	eb 28                	jmp    801c73 <devcons_read+0x3b>
		sys_yield();
  801c4b:	e8 2a f0 ff ff       	call   800c7a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801c50:	e8 95 ef ff ff       	call   800bea <sys_cgetc>
  801c55:	85 c0                	test   %eax,%eax
  801c57:	74 f2                	je     801c4b <devcons_read+0x13>
	if (c < 0)
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	78 16                	js     801c73 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  801c5d:	83 f8 04             	cmp    $0x4,%eax
  801c60:	74 0c                	je     801c6e <devcons_read+0x36>
	*(char*)vbuf = c;
  801c62:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c65:	88 02                	mov    %al,(%edx)
	return 1;
  801c67:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6c:	eb 05                	jmp    801c73 <devcons_read+0x3b>
		return 0;
  801c6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    

00801c75 <cputchar>:
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801c81:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c88:	00 
  801c89:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c8c:	89 04 24             	mov    %eax,(%esp)
  801c8f:	e8 38 ef ff ff       	call   800bcc <sys_cputs>
}
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    

00801c96 <getchar>:
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801c9c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801ca3:	00 
  801ca4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ca7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cb2:	e8 3f f6 ff ff       	call   8012f6 <read>
	if (r < 0)
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	78 0f                	js     801cca <getchar+0x34>
	if (r < 1)
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	7e 06                	jle    801cc5 <getchar+0x2f>
	return c;
  801cbf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cc3:	eb 05                	jmp    801cca <getchar+0x34>
		return -E_EOF;
  801cc5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    

00801ccc <iscons>:
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdc:	89 04 24             	mov    %eax,(%esp)
  801cdf:	e8 67 f3 ff ff       	call   80104b <fd_lookup>
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	78 11                	js     801cf9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ceb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cf1:	39 10                	cmp    %edx,(%eax)
  801cf3:	0f 94 c0             	sete   %al
  801cf6:	0f b6 c0             	movzbl %al,%eax
}
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <opencons>:
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d04:	89 04 24             	mov    %eax,(%esp)
  801d07:	e8 cb f2 ff ff       	call   800fd7 <fd_alloc>
		return r;
  801d0c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	78 40                	js     801d52 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d12:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d19:	00 
  801d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d28:	e8 6c ef ff ff       	call   800c99 <sys_page_alloc>
		return r;
  801d2d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	78 1f                	js     801d52 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801d33:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d41:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d48:	89 04 24             	mov    %eax,(%esp)
  801d4b:	e8 60 f2 ff ff       	call   800fb0 <fd2num>
  801d50:	89 c2                	mov    %eax,%edx
}
  801d52:	89 d0                	mov    %edx,%eax
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	56                   	push   %esi
  801d5a:	53                   	push   %ebx
  801d5b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801d5e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d61:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d67:	e8 ef ee ff ff       	call   800c5b <sys_getenvid>
  801d6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d6f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d73:	8b 55 08             	mov    0x8(%ebp),%edx
  801d76:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d7a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d82:	c7 04 24 18 26 80 00 	movl   $0x802618,(%esp)
  801d89:	e8 08 e4 ff ff       	call   800196 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d8e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d92:	8b 45 10             	mov    0x10(%ebp),%eax
  801d95:	89 04 24             	mov    %eax,(%esp)
  801d98:	e8 98 e3 ff ff       	call   800135 <vcprintf>
	cprintf("\n");
  801d9d:	c7 04 24 05 26 80 00 	movl   $0x802605,(%esp)
  801da4:	e8 ed e3 ff ff       	call   800196 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801da9:	cc                   	int3   
  801daa:	eb fd                	jmp    801da9 <_panic+0x53>

00801dac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	56                   	push   %esi
  801db0:	53                   	push   %ebx
  801db1:	83 ec 10             	sub    $0x10,%esp
  801db4:	8b 75 08             	mov    0x8(%ebp),%esi
  801db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  801dba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dbd:	89 04 24             	mov    %eax,(%esp)
  801dc0:	e8 ea f0 ff ff       	call   800eaf <sys_ipc_recv>
	if(from_env_store)
  801dc5:	85 f6                	test   %esi,%esi
  801dc7:	74 14                	je     801ddd <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  801dc9:	ba 00 00 00 00       	mov    $0x0,%edx
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 09                	js     801ddb <ipc_recv+0x2f>
  801dd2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801dd8:	8b 52 74             	mov    0x74(%edx),%edx
  801ddb:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  801ddd:	85 db                	test   %ebx,%ebx
  801ddf:	74 14                	je     801df5 <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  801de1:	ba 00 00 00 00       	mov    $0x0,%edx
  801de6:	85 c0                	test   %eax,%eax
  801de8:	78 09                	js     801df3 <ipc_recv+0x47>
  801dea:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801df0:	8b 52 78             	mov    0x78(%edx),%edx
  801df3:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  801df5:	85 c0                	test   %eax,%eax
  801df7:	78 08                	js     801e01 <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  801df9:	a1 04 40 80 00       	mov    0x804004,%eax
  801dfe:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    

00801e08 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
  801e0b:	57                   	push   %edi
  801e0c:	56                   	push   %esi
  801e0d:	53                   	push   %ebx
  801e0e:	83 ec 1c             	sub    $0x1c,%esp
  801e11:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e14:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  801e17:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801e1c:	eb 0c                	jmp    801e2a <ipc_send+0x22>
		failed_cnt++;
  801e1e:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  801e21:	84 db                	test   %bl,%bl
  801e23:	75 05                	jne    801e2a <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  801e25:	e8 50 ee ff ff       	call   800c7a <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801e2a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e31:	8b 45 10             	mov    0x10(%ebp),%eax
  801e34:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e38:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e3c:	89 3c 24             	mov    %edi,(%esp)
  801e3f:	e8 48 f0 ff ff       	call   800e8c <sys_ipc_try_send>
  801e44:	85 c0                	test   %eax,%eax
  801e46:	78 d6                	js     801e1e <ipc_send+0x16>
	}
}
  801e48:	83 c4 1c             	add    $0x1c,%esp
  801e4b:	5b                   	pop    %ebx
  801e4c:	5e                   	pop    %esi
  801e4d:	5f                   	pop    %edi
  801e4e:	5d                   	pop    %ebp
  801e4f:	c3                   	ret    

00801e50 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801e56:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801e5b:	39 c8                	cmp    %ecx,%eax
  801e5d:	74 17                	je     801e76 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  801e5f:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801e64:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e67:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e6d:	8b 52 50             	mov    0x50(%edx),%edx
  801e70:	39 ca                	cmp    %ecx,%edx
  801e72:	75 14                	jne    801e88 <ipc_find_env+0x38>
  801e74:	eb 05                	jmp    801e7b <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  801e76:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  801e7b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e7e:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801e83:	8b 40 40             	mov    0x40(%eax),%eax
  801e86:	eb 0e                	jmp    801e96 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  801e88:	83 c0 01             	add    $0x1,%eax
  801e8b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e90:	75 d2                	jne    801e64 <ipc_find_env+0x14>
	return 0;
  801e92:	66 b8 00 00          	mov    $0x0,%ax
}
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    

00801e98 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e9e:	89 d0                	mov    %edx,%eax
  801ea0:	c1 e8 16             	shr    $0x16,%eax
  801ea3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801eaa:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801eaf:	f6 c1 01             	test   $0x1,%cl
  801eb2:	74 1d                	je     801ed1 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801eb4:	c1 ea 0c             	shr    $0xc,%edx
  801eb7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ebe:	f6 c2 01             	test   $0x1,%dl
  801ec1:	74 0e                	je     801ed1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ec3:	c1 ea 0c             	shr    $0xc,%edx
  801ec6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ecd:	ef 
  801ece:	0f b7 c0             	movzwl %ax,%eax
}
  801ed1:	5d                   	pop    %ebp
  801ed2:	c3                   	ret    
  801ed3:	66 90                	xchg   %ax,%ax
  801ed5:	66 90                	xchg   %ax,%ax
  801ed7:	66 90                	xchg   %ax,%ax
  801ed9:	66 90                	xchg   %ax,%ax
  801edb:	66 90                	xchg   %ax,%ax
  801edd:	66 90                	xchg   %ax,%ax
  801edf:	90                   	nop

00801ee0 <__udivdi3>:
  801ee0:	55                   	push   %ebp
  801ee1:	57                   	push   %edi
  801ee2:	56                   	push   %esi
  801ee3:	83 ec 0c             	sub    $0xc,%esp
  801ee6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801eea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801eee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801ef2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801efc:	89 ea                	mov    %ebp,%edx
  801efe:	89 0c 24             	mov    %ecx,(%esp)
  801f01:	75 2d                	jne    801f30 <__udivdi3+0x50>
  801f03:	39 e9                	cmp    %ebp,%ecx
  801f05:	77 61                	ja     801f68 <__udivdi3+0x88>
  801f07:	85 c9                	test   %ecx,%ecx
  801f09:	89 ce                	mov    %ecx,%esi
  801f0b:	75 0b                	jne    801f18 <__udivdi3+0x38>
  801f0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801f12:	31 d2                	xor    %edx,%edx
  801f14:	f7 f1                	div    %ecx
  801f16:	89 c6                	mov    %eax,%esi
  801f18:	31 d2                	xor    %edx,%edx
  801f1a:	89 e8                	mov    %ebp,%eax
  801f1c:	f7 f6                	div    %esi
  801f1e:	89 c5                	mov    %eax,%ebp
  801f20:	89 f8                	mov    %edi,%eax
  801f22:	f7 f6                	div    %esi
  801f24:	89 ea                	mov    %ebp,%edx
  801f26:	83 c4 0c             	add    $0xc,%esp
  801f29:	5e                   	pop    %esi
  801f2a:	5f                   	pop    %edi
  801f2b:	5d                   	pop    %ebp
  801f2c:	c3                   	ret    
  801f2d:	8d 76 00             	lea    0x0(%esi),%esi
  801f30:	39 e8                	cmp    %ebp,%eax
  801f32:	77 24                	ja     801f58 <__udivdi3+0x78>
  801f34:	0f bd e8             	bsr    %eax,%ebp
  801f37:	83 f5 1f             	xor    $0x1f,%ebp
  801f3a:	75 3c                	jne    801f78 <__udivdi3+0x98>
  801f3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801f40:	39 34 24             	cmp    %esi,(%esp)
  801f43:	0f 86 9f 00 00 00    	jbe    801fe8 <__udivdi3+0x108>
  801f49:	39 d0                	cmp    %edx,%eax
  801f4b:	0f 82 97 00 00 00    	jb     801fe8 <__udivdi3+0x108>
  801f51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f58:	31 d2                	xor    %edx,%edx
  801f5a:	31 c0                	xor    %eax,%eax
  801f5c:	83 c4 0c             	add    $0xc,%esp
  801f5f:	5e                   	pop    %esi
  801f60:	5f                   	pop    %edi
  801f61:	5d                   	pop    %ebp
  801f62:	c3                   	ret    
  801f63:	90                   	nop
  801f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f68:	89 f8                	mov    %edi,%eax
  801f6a:	f7 f1                	div    %ecx
  801f6c:	31 d2                	xor    %edx,%edx
  801f6e:	83 c4 0c             	add    $0xc,%esp
  801f71:	5e                   	pop    %esi
  801f72:	5f                   	pop    %edi
  801f73:	5d                   	pop    %ebp
  801f74:	c3                   	ret    
  801f75:	8d 76 00             	lea    0x0(%esi),%esi
  801f78:	89 e9                	mov    %ebp,%ecx
  801f7a:	8b 3c 24             	mov    (%esp),%edi
  801f7d:	d3 e0                	shl    %cl,%eax
  801f7f:	89 c6                	mov    %eax,%esi
  801f81:	b8 20 00 00 00       	mov    $0x20,%eax
  801f86:	29 e8                	sub    %ebp,%eax
  801f88:	89 c1                	mov    %eax,%ecx
  801f8a:	d3 ef                	shr    %cl,%edi
  801f8c:	89 e9                	mov    %ebp,%ecx
  801f8e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801f92:	8b 3c 24             	mov    (%esp),%edi
  801f95:	09 74 24 08          	or     %esi,0x8(%esp)
  801f99:	89 d6                	mov    %edx,%esi
  801f9b:	d3 e7                	shl    %cl,%edi
  801f9d:	89 c1                	mov    %eax,%ecx
  801f9f:	89 3c 24             	mov    %edi,(%esp)
  801fa2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801fa6:	d3 ee                	shr    %cl,%esi
  801fa8:	89 e9                	mov    %ebp,%ecx
  801faa:	d3 e2                	shl    %cl,%edx
  801fac:	89 c1                	mov    %eax,%ecx
  801fae:	d3 ef                	shr    %cl,%edi
  801fb0:	09 d7                	or     %edx,%edi
  801fb2:	89 f2                	mov    %esi,%edx
  801fb4:	89 f8                	mov    %edi,%eax
  801fb6:	f7 74 24 08          	divl   0x8(%esp)
  801fba:	89 d6                	mov    %edx,%esi
  801fbc:	89 c7                	mov    %eax,%edi
  801fbe:	f7 24 24             	mull   (%esp)
  801fc1:	39 d6                	cmp    %edx,%esi
  801fc3:	89 14 24             	mov    %edx,(%esp)
  801fc6:	72 30                	jb     801ff8 <__udivdi3+0x118>
  801fc8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801fcc:	89 e9                	mov    %ebp,%ecx
  801fce:	d3 e2                	shl    %cl,%edx
  801fd0:	39 c2                	cmp    %eax,%edx
  801fd2:	73 05                	jae    801fd9 <__udivdi3+0xf9>
  801fd4:	3b 34 24             	cmp    (%esp),%esi
  801fd7:	74 1f                	je     801ff8 <__udivdi3+0x118>
  801fd9:	89 f8                	mov    %edi,%eax
  801fdb:	31 d2                	xor    %edx,%edx
  801fdd:	e9 7a ff ff ff       	jmp    801f5c <__udivdi3+0x7c>
  801fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fe8:	31 d2                	xor    %edx,%edx
  801fea:	b8 01 00 00 00       	mov    $0x1,%eax
  801fef:	e9 68 ff ff ff       	jmp    801f5c <__udivdi3+0x7c>
  801ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ff8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801ffb:	31 d2                	xor    %edx,%edx
  801ffd:	83 c4 0c             	add    $0xc,%esp
  802000:	5e                   	pop    %esi
  802001:	5f                   	pop    %edi
  802002:	5d                   	pop    %ebp
  802003:	c3                   	ret    
  802004:	66 90                	xchg   %ax,%ax
  802006:	66 90                	xchg   %ax,%ax
  802008:	66 90                	xchg   %ax,%ax
  80200a:	66 90                	xchg   %ax,%ax
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <__umoddi3>:
  802010:	55                   	push   %ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	83 ec 14             	sub    $0x14,%esp
  802016:	8b 44 24 28          	mov    0x28(%esp),%eax
  80201a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80201e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802022:	89 c7                	mov    %eax,%edi
  802024:	89 44 24 04          	mov    %eax,0x4(%esp)
  802028:	8b 44 24 30          	mov    0x30(%esp),%eax
  80202c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802030:	89 34 24             	mov    %esi,(%esp)
  802033:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802037:	85 c0                	test   %eax,%eax
  802039:	89 c2                	mov    %eax,%edx
  80203b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80203f:	75 17                	jne    802058 <__umoddi3+0x48>
  802041:	39 fe                	cmp    %edi,%esi
  802043:	76 4b                	jbe    802090 <__umoddi3+0x80>
  802045:	89 c8                	mov    %ecx,%eax
  802047:	89 fa                	mov    %edi,%edx
  802049:	f7 f6                	div    %esi
  80204b:	89 d0                	mov    %edx,%eax
  80204d:	31 d2                	xor    %edx,%edx
  80204f:	83 c4 14             	add    $0x14,%esp
  802052:	5e                   	pop    %esi
  802053:	5f                   	pop    %edi
  802054:	5d                   	pop    %ebp
  802055:	c3                   	ret    
  802056:	66 90                	xchg   %ax,%ax
  802058:	39 f8                	cmp    %edi,%eax
  80205a:	77 54                	ja     8020b0 <__umoddi3+0xa0>
  80205c:	0f bd e8             	bsr    %eax,%ebp
  80205f:	83 f5 1f             	xor    $0x1f,%ebp
  802062:	75 5c                	jne    8020c0 <__umoddi3+0xb0>
  802064:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802068:	39 3c 24             	cmp    %edi,(%esp)
  80206b:	0f 87 e7 00 00 00    	ja     802158 <__umoddi3+0x148>
  802071:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802075:	29 f1                	sub    %esi,%ecx
  802077:	19 c7                	sbb    %eax,%edi
  802079:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80207d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802081:	8b 44 24 08          	mov    0x8(%esp),%eax
  802085:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802089:	83 c4 14             	add    $0x14,%esp
  80208c:	5e                   	pop    %esi
  80208d:	5f                   	pop    %edi
  80208e:	5d                   	pop    %ebp
  80208f:	c3                   	ret    
  802090:	85 f6                	test   %esi,%esi
  802092:	89 f5                	mov    %esi,%ebp
  802094:	75 0b                	jne    8020a1 <__umoddi3+0x91>
  802096:	b8 01 00 00 00       	mov    $0x1,%eax
  80209b:	31 d2                	xor    %edx,%edx
  80209d:	f7 f6                	div    %esi
  80209f:	89 c5                	mov    %eax,%ebp
  8020a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020a5:	31 d2                	xor    %edx,%edx
  8020a7:	f7 f5                	div    %ebp
  8020a9:	89 c8                	mov    %ecx,%eax
  8020ab:	f7 f5                	div    %ebp
  8020ad:	eb 9c                	jmp    80204b <__umoddi3+0x3b>
  8020af:	90                   	nop
  8020b0:	89 c8                	mov    %ecx,%eax
  8020b2:	89 fa                	mov    %edi,%edx
  8020b4:	83 c4 14             	add    $0x14,%esp
  8020b7:	5e                   	pop    %esi
  8020b8:	5f                   	pop    %edi
  8020b9:	5d                   	pop    %ebp
  8020ba:	c3                   	ret    
  8020bb:	90                   	nop
  8020bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	8b 04 24             	mov    (%esp),%eax
  8020c3:	be 20 00 00 00       	mov    $0x20,%esi
  8020c8:	89 e9                	mov    %ebp,%ecx
  8020ca:	29 ee                	sub    %ebp,%esi
  8020cc:	d3 e2                	shl    %cl,%edx
  8020ce:	89 f1                	mov    %esi,%ecx
  8020d0:	d3 e8                	shr    %cl,%eax
  8020d2:	89 e9                	mov    %ebp,%ecx
  8020d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d8:	8b 04 24             	mov    (%esp),%eax
  8020db:	09 54 24 04          	or     %edx,0x4(%esp)
  8020df:	89 fa                	mov    %edi,%edx
  8020e1:	d3 e0                	shl    %cl,%eax
  8020e3:	89 f1                	mov    %esi,%ecx
  8020e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8020ed:	d3 ea                	shr    %cl,%edx
  8020ef:	89 e9                	mov    %ebp,%ecx
  8020f1:	d3 e7                	shl    %cl,%edi
  8020f3:	89 f1                	mov    %esi,%ecx
  8020f5:	d3 e8                	shr    %cl,%eax
  8020f7:	89 e9                	mov    %ebp,%ecx
  8020f9:	09 f8                	or     %edi,%eax
  8020fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8020ff:	f7 74 24 04          	divl   0x4(%esp)
  802103:	d3 e7                	shl    %cl,%edi
  802105:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802109:	89 d7                	mov    %edx,%edi
  80210b:	f7 64 24 08          	mull   0x8(%esp)
  80210f:	39 d7                	cmp    %edx,%edi
  802111:	89 c1                	mov    %eax,%ecx
  802113:	89 14 24             	mov    %edx,(%esp)
  802116:	72 2c                	jb     802144 <__umoddi3+0x134>
  802118:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80211c:	72 22                	jb     802140 <__umoddi3+0x130>
  80211e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802122:	29 c8                	sub    %ecx,%eax
  802124:	19 d7                	sbb    %edx,%edi
  802126:	89 e9                	mov    %ebp,%ecx
  802128:	89 fa                	mov    %edi,%edx
  80212a:	d3 e8                	shr    %cl,%eax
  80212c:	89 f1                	mov    %esi,%ecx
  80212e:	d3 e2                	shl    %cl,%edx
  802130:	89 e9                	mov    %ebp,%ecx
  802132:	d3 ef                	shr    %cl,%edi
  802134:	09 d0                	or     %edx,%eax
  802136:	89 fa                	mov    %edi,%edx
  802138:	83 c4 14             	add    $0x14,%esp
  80213b:	5e                   	pop    %esi
  80213c:	5f                   	pop    %edi
  80213d:	5d                   	pop    %ebp
  80213e:	c3                   	ret    
  80213f:	90                   	nop
  802140:	39 d7                	cmp    %edx,%edi
  802142:	75 da                	jne    80211e <__umoddi3+0x10e>
  802144:	8b 14 24             	mov    (%esp),%edx
  802147:	89 c1                	mov    %eax,%ecx
  802149:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80214d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802151:	eb cb                	jmp    80211e <__umoddi3+0x10e>
  802153:	90                   	nop
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80215c:	0f 82 0f ff ff ff    	jb     802071 <__umoddi3+0x61>
  802162:	e9 1a ff ff ff       	jmp    802081 <__umoddi3+0x71>
