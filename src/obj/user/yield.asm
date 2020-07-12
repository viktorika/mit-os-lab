
obj/user/yield.debug：     文件格式 elf32-i386


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
  80002c:	e8 6d 00 00 00       	call   80009e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	89 44 24 04          	mov    %eax,0x4(%esp)
  800046:	c7 04 24 e0 20 80 00 	movl   $0x8020e0,(%esp)
  80004d:	e8 50 01 00 00       	call   8001a2 <cprintf>
	for (i = 0; i < 5; i++) {
  800052:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800057:	e8 2e 0c 00 00       	call   800c8a <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("Back in environment %08x, iteration %d.\n",
  800061:	8b 40 48             	mov    0x48(%eax),%eax
  800064:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006c:	c7 04 24 00 21 80 00 	movl   $0x802100,(%esp)
  800073:	e8 2a 01 00 00       	call   8001a2 <cprintf>
	for (i = 0; i < 5; i++) {
  800078:	83 c3 01             	add    $0x1,%ebx
  80007b:	83 fb 05             	cmp    $0x5,%ebx
  80007e:	75 d7                	jne    800057 <umain+0x24>
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800080:	a1 04 40 80 00       	mov    0x804004,%eax
  800085:	8b 40 48             	mov    0x48(%eax),%eax
  800088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008c:	c7 04 24 2c 21 80 00 	movl   $0x80212c,(%esp)
  800093:	e8 0a 01 00 00       	call   8001a2 <cprintf>
}
  800098:	83 c4 14             	add    $0x14,%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5d                   	pop    %ebp
  80009d:	c3                   	ret    

0080009e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	56                   	push   %esi
  8000a2:	53                   	push   %ebx
  8000a3:	83 ec 10             	sub    $0x10,%esp
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000ac:	e8 ba 0b 00 00       	call   800c6b <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x30>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000d2:	89 1c 24             	mov    %ebx,(%esp)
  8000d5:	e8 59 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000da:	e8 07 00 00 00       	call   8000e6 <exit>
}
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ec:	e8 45 10 00 00       	call   801136 <close_all>
	sys_env_destroy(0);
  8000f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f8:	e8 1c 0b 00 00       	call   800c19 <sys_env_destroy>
}
  8000fd:	c9                   	leave  
  8000fe:	c3                   	ret    

008000ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	53                   	push   %ebx
  800103:	83 ec 14             	sub    $0x14,%esp
  800106:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800109:	8b 13                	mov    (%ebx),%edx
  80010b:	8d 42 01             	lea    0x1(%edx),%eax
  80010e:	89 03                	mov    %eax,(%ebx)
  800110:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800113:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800117:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011c:	75 19                	jne    800137 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80011e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800125:	00 
  800126:	8d 43 08             	lea    0x8(%ebx),%eax
  800129:	89 04 24             	mov    %eax,(%esp)
  80012c:	e8 ab 0a 00 00       	call   800bdc <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800137:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013b:	83 c4 14             	add    $0x14,%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5d                   	pop    %ebp
  800140:	c3                   	ret    

00800141 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80014a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800151:	00 00 00 
	b.cnt = 0;
  800154:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800161:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800165:	8b 45 08             	mov    0x8(%ebp),%eax
  800168:	89 44 24 08          	mov    %eax,0x8(%esp)
  80016c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800172:	89 44 24 04          	mov    %eax,0x4(%esp)
  800176:	c7 04 24 ff 00 80 00 	movl   $0x8000ff,(%esp)
  80017d:	e8 b2 01 00 00       	call   800334 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800182:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800192:	89 04 24             	mov    %eax,(%esp)
  800195:	e8 42 0a 00 00       	call   800bdc <sys_cputs>

	return b.cnt;
}
  80019a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001af:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b2:	89 04 24             	mov    %eax,(%esp)
  8001b5:	e8 87 ff ff ff       	call   800141 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    
  8001bc:	66 90                	xchg   %ax,%ax
  8001be:	66 90                	xchg   %ax,%ax

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 3c             	sub    $0x3c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d7                	mov    %edx,%edi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8001d7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8001da:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001e8:	39 f1                	cmp    %esi,%ecx
  8001ea:	72 14                	jb     800200 <printnum+0x40>
  8001ec:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001ef:	76 0f                	jbe    800200 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f4:	8d 70 ff             	lea    -0x1(%eax),%esi
  8001f7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8001fa:	85 f6                	test   %esi,%esi
  8001fc:	7f 60                	jg     80025e <printnum+0x9e>
  8001fe:	eb 72                	jmp    800272 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800200:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800203:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800207:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80020a:	8d 51 ff             	lea    -0x1(%ecx),%edx
  80020d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800211:	89 44 24 08          	mov    %eax,0x8(%esp)
  800215:	8b 44 24 08          	mov    0x8(%esp),%eax
  800219:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80021d:	89 c3                	mov    %eax,%ebx
  80021f:	89 d6                	mov    %edx,%esi
  800221:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800224:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800227:	89 54 24 08          	mov    %edx,0x8(%esp)
  80022b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80022f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800232:	89 04 24             	mov    %eax,(%esp)
  800235:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023c:	e8 0f 1c 00 00       	call   801e50 <__udivdi3>
  800241:	89 d9                	mov    %ebx,%ecx
  800243:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800247:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80024b:	89 04 24             	mov    %eax,(%esp)
  80024e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800252:	89 fa                	mov    %edi,%edx
  800254:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800257:	e8 64 ff ff ff       	call   8001c0 <printnum>
  80025c:	eb 14                	jmp    800272 <printnum+0xb2>
			putch(padc, putdat);
  80025e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800262:	8b 45 18             	mov    0x18(%ebp),%eax
  800265:	89 04 24             	mov    %eax,(%esp)
  800268:	ff d3                	call   *%ebx
		while (--width > 0)
  80026a:	83 ee 01             	sub    $0x1,%esi
  80026d:	75 ef                	jne    80025e <printnum+0x9e>
  80026f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800272:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800276:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80027a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80027d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800280:	89 44 24 08          	mov    %eax,0x8(%esp)
  800284:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800288:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80028b:	89 04 24             	mov    %eax,(%esp)
  80028e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800291:	89 44 24 04          	mov    %eax,0x4(%esp)
  800295:	e8 e6 1c 00 00       	call   801f80 <__umoddi3>
  80029a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029e:	0f be 80 55 21 80 00 	movsbl 0x802155(%eax),%eax
  8002a5:	89 04 24             	mov    %eax,(%esp)
  8002a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ab:	ff d0                	call   *%eax
}
  8002ad:	83 c4 3c             	add    $0x3c,%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b8:	83 fa 01             	cmp    $0x1,%edx
  8002bb:	7e 0e                	jle    8002cb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bd:	8b 10                	mov    (%eax),%edx
  8002bf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 02                	mov    (%edx),%eax
  8002c6:	8b 52 04             	mov    0x4(%edx),%edx
  8002c9:	eb 22                	jmp    8002ed <getuint+0x38>
	else if (lflag)
  8002cb:	85 d2                	test   %edx,%edx
  8002cd:	74 10                	je     8002df <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cf:	8b 10                	mov    (%eax),%edx
  8002d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d4:	89 08                	mov    %ecx,(%eax)
  8002d6:	8b 02                	mov    (%edx),%eax
  8002d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dd:	eb 0e                	jmp    8002ed <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002df:	8b 10                	mov    (%eax),%edx
  8002e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e4:	89 08                	mov    %ecx,(%eax)
  8002e6:	8b 02                	mov    (%edx),%eax
  8002e8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fe:	73 0a                	jae    80030a <sprintputch+0x1b>
		*b->buf++ = ch;
  800300:	8d 4a 01             	lea    0x1(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 45 08             	mov    0x8(%ebp),%eax
  800308:	88 02                	mov    %al,(%edx)
}
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    

0080030c <printfmt>:
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  800312:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800315:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800319:	8b 45 10             	mov    0x10(%ebp),%eax
  80031c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800320:	8b 45 0c             	mov    0xc(%ebp),%eax
  800323:	89 44 24 04          	mov    %eax,0x4(%esp)
  800327:	8b 45 08             	mov    0x8(%ebp),%eax
  80032a:	89 04 24             	mov    %eax,(%esp)
  80032d:	e8 02 00 00 00       	call   800334 <vprintfmt>
}
  800332:	c9                   	leave  
  800333:	c3                   	ret    

00800334 <vprintfmt>:
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	57                   	push   %edi
  800338:	56                   	push   %esi
  800339:	53                   	push   %ebx
  80033a:	83 ec 3c             	sub    $0x3c,%esp
  80033d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800340:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800343:	eb 18                	jmp    80035d <vprintfmt+0x29>
			if (ch == '\0')
  800345:	85 c0                	test   %eax,%eax
  800347:	0f 84 c3 03 00 00    	je     800710 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80034d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800351:	89 04 24             	mov    %eax,(%esp)
  800354:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800357:	89 f3                	mov    %esi,%ebx
  800359:	eb 02                	jmp    80035d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80035b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035d:	8d 73 01             	lea    0x1(%ebx),%esi
  800360:	0f b6 03             	movzbl (%ebx),%eax
  800363:	83 f8 25             	cmp    $0x25,%eax
  800366:	75 dd                	jne    800345 <vprintfmt+0x11>
  800368:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80036c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800373:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80037a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800381:	ba 00 00 00 00       	mov    $0x0,%edx
  800386:	eb 1d                	jmp    8003a5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800388:	89 de                	mov    %ebx,%esi
			padc = '-';
  80038a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80038e:	eb 15                	jmp    8003a5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800390:	89 de                	mov    %ebx,%esi
			padc = '0';
  800392:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800396:	eb 0d                	jmp    8003a5 <vprintfmt+0x71>
				width = precision, precision = -1;
  800398:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80039b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003a8:	0f b6 06             	movzbl (%esi),%eax
  8003ab:	0f b6 c8             	movzbl %al,%ecx
  8003ae:	83 e8 23             	sub    $0x23,%eax
  8003b1:	3c 55                	cmp    $0x55,%al
  8003b3:	0f 87 2f 03 00 00    	ja     8006e8 <vprintfmt+0x3b4>
  8003b9:	0f b6 c0             	movzbl %al,%eax
  8003bc:	ff 24 85 a0 22 80 00 	jmp    *0x8022a0(,%eax,4)
				precision = precision * 10 + ch - '0';
  8003c3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8003c6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  8003c9:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003cd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003d0:	83 f9 09             	cmp    $0x9,%ecx
  8003d3:	77 50                	ja     800425 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	89 de                	mov    %ebx,%esi
  8003d7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8003da:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003dd:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003e0:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003e4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003e7:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003ea:	83 fb 09             	cmp    $0x9,%ebx
  8003ed:	76 eb                	jbe    8003da <vprintfmt+0xa6>
  8003ef:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8003f2:	eb 33                	jmp    800427 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fd:	8b 00                	mov    (%eax),%eax
  8003ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800402:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800404:	eb 21                	jmp    800427 <vprintfmt+0xf3>
  800406:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800409:	85 c9                	test   %ecx,%ecx
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
  800410:	0f 49 c1             	cmovns %ecx,%eax
  800413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800416:	89 de                	mov    %ebx,%esi
  800418:	eb 8b                	jmp    8003a5 <vprintfmt+0x71>
  80041a:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80041c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800423:	eb 80                	jmp    8003a5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800425:	89 de                	mov    %ebx,%esi
			if (width < 0)
  800427:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80042b:	0f 89 74 ff ff ff    	jns    8003a5 <vprintfmt+0x71>
  800431:	e9 62 ff ff ff       	jmp    800398 <vprintfmt+0x64>
			lflag++;
  800436:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800439:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80043b:	e9 65 ff ff ff       	jmp    8003a5 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044d:	8b 00                	mov    (%eax),%eax
  80044f:	89 04 24             	mov    %eax,(%esp)
  800452:	ff 55 08             	call   *0x8(%ebp)
			break;
  800455:	e9 03 ff ff ff       	jmp    80035d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 50 04             	lea    0x4(%eax),%edx
  800460:	89 55 14             	mov    %edx,0x14(%ebp)
  800463:	8b 00                	mov    (%eax),%eax
  800465:	99                   	cltd   
  800466:	31 d0                	xor    %edx,%eax
  800468:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046a:	83 f8 0f             	cmp    $0xf,%eax
  80046d:	7f 0b                	jg     80047a <vprintfmt+0x146>
  80046f:	8b 14 85 00 24 80 00 	mov    0x802400(,%eax,4),%edx
  800476:	85 d2                	test   %edx,%edx
  800478:	75 20                	jne    80049a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80047a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047e:	c7 44 24 08 6d 21 80 	movl   $0x80216d,0x8(%esp)
  800485:	00 
  800486:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048a:	8b 45 08             	mov    0x8(%ebp),%eax
  80048d:	89 04 24             	mov    %eax,(%esp)
  800490:	e8 77 fe ff ff       	call   80030c <printfmt>
  800495:	e9 c3 fe ff ff       	jmp    80035d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80049a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80049e:	c7 44 24 08 1f 25 80 	movl   $0x80251f,0x8(%esp)
  8004a5:	00 
  8004a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ad:	89 04 24             	mov    %eax,(%esp)
  8004b0:	e8 57 fe ff ff       	call   80030c <printfmt>
  8004b5:	e9 a3 fe ff ff       	jmp    80035d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004bd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8004cb:	85 c0                	test   %eax,%eax
  8004cd:	ba 66 21 80 00       	mov    $0x802166,%edx
  8004d2:	0f 45 d0             	cmovne %eax,%edx
  8004d5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004d8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8004dc:	74 04                	je     8004e2 <vprintfmt+0x1ae>
  8004de:	85 f6                	test   %esi,%esi
  8004e0:	7f 19                	jg     8004fb <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004e5:	8d 70 01             	lea    0x1(%eax),%esi
  8004e8:	0f b6 10             	movzbl (%eax),%edx
  8004eb:	0f be c2             	movsbl %dl,%eax
  8004ee:	85 c0                	test   %eax,%eax
  8004f0:	0f 85 95 00 00 00    	jne    80058b <vprintfmt+0x257>
  8004f6:	e9 85 00 00 00       	jmp    800580 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ff:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800502:	89 04 24             	mov    %eax,(%esp)
  800505:	e8 b8 02 00 00       	call   8007c2 <strnlen>
  80050a:	29 c6                	sub    %eax,%esi
  80050c:	89 f0                	mov    %esi,%eax
  80050e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800511:	85 f6                	test   %esi,%esi
  800513:	7e cd                	jle    8004e2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800515:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800519:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80051c:	89 c3                	mov    %eax,%ebx
  80051e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800522:	89 34 24             	mov    %esi,(%esp)
  800525:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800528:	83 eb 01             	sub    $0x1,%ebx
  80052b:	75 f1                	jne    80051e <vprintfmt+0x1ea>
  80052d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800530:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800533:	eb ad                	jmp    8004e2 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800535:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800539:	74 1e                	je     800559 <vprintfmt+0x225>
  80053b:	0f be d2             	movsbl %dl,%edx
  80053e:	83 ea 20             	sub    $0x20,%edx
  800541:	83 fa 5e             	cmp    $0x5e,%edx
  800544:	76 13                	jbe    800559 <vprintfmt+0x225>
					putch('?', putdat);
  800546:	8b 45 0c             	mov    0xc(%ebp),%eax
  800549:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800554:	ff 55 08             	call   *0x8(%ebp)
  800557:	eb 0d                	jmp    800566 <vprintfmt+0x232>
					putch(ch, putdat);
  800559:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80055c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800560:	89 04 24             	mov    %eax,(%esp)
  800563:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800566:	83 ef 01             	sub    $0x1,%edi
  800569:	83 c6 01             	add    $0x1,%esi
  80056c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800570:	0f be c2             	movsbl %dl,%eax
  800573:	85 c0                	test   %eax,%eax
  800575:	75 20                	jne    800597 <vprintfmt+0x263>
  800577:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80057a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80057d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800580:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800584:	7f 25                	jg     8005ab <vprintfmt+0x277>
  800586:	e9 d2 fd ff ff       	jmp    80035d <vprintfmt+0x29>
  80058b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800591:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800594:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800597:	85 db                	test   %ebx,%ebx
  800599:	78 9a                	js     800535 <vprintfmt+0x201>
  80059b:	83 eb 01             	sub    $0x1,%ebx
  80059e:	79 95                	jns    800535 <vprintfmt+0x201>
  8005a0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005a3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005a9:	eb d5                	jmp    800580 <vprintfmt+0x24c>
  8005ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ae:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  8005b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005bf:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005c1:	83 eb 01             	sub    $0x1,%ebx
  8005c4:	75 ee                	jne    8005b4 <vprintfmt+0x280>
  8005c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005c9:	e9 8f fd ff ff       	jmp    80035d <vprintfmt+0x29>
	if (lflag >= 2)
  8005ce:	83 fa 01             	cmp    $0x1,%edx
  8005d1:	7e 16                	jle    8005e9 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 50 08             	lea    0x8(%eax),%edx
  8005d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dc:	8b 50 04             	mov    0x4(%eax),%edx
  8005df:	8b 00                	mov    (%eax),%eax
  8005e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e7:	eb 32                	jmp    80061b <vprintfmt+0x2e7>
	else if (lflag)
  8005e9:	85 d2                	test   %edx,%edx
  8005eb:	74 18                	je     800605 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 50 04             	lea    0x4(%eax),%edx
  8005f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f6:	8b 30                	mov    (%eax),%esi
  8005f8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005fb:	89 f0                	mov    %esi,%eax
  8005fd:	c1 f8 1f             	sar    $0x1f,%eax
  800600:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800603:	eb 16                	jmp    80061b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 50 04             	lea    0x4(%eax),%edx
  80060b:	89 55 14             	mov    %edx,0x14(%ebp)
  80060e:	8b 30                	mov    (%eax),%esi
  800610:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800613:	89 f0                	mov    %esi,%eax
  800615:	c1 f8 1f             	sar    $0x1f,%eax
  800618:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  80061b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  800621:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800626:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062a:	0f 89 80 00 00 00    	jns    8006b0 <vprintfmt+0x37c>
				putch('-', putdat);
  800630:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800634:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80063b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80063e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800641:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800644:	f7 d8                	neg    %eax
  800646:	83 d2 00             	adc    $0x0,%edx
  800649:	f7 da                	neg    %edx
			base = 10;
  80064b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800650:	eb 5e                	jmp    8006b0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800652:	8d 45 14             	lea    0x14(%ebp),%eax
  800655:	e8 5b fc ff ff       	call   8002b5 <getuint>
			base = 10;
  80065a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80065f:	eb 4f                	jmp    8006b0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800661:	8d 45 14             	lea    0x14(%ebp),%eax
  800664:	e8 4c fc ff ff       	call   8002b5 <getuint>
			base = 8;
  800669:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80066e:	eb 40                	jmp    8006b0 <vprintfmt+0x37c>
			putch('0', putdat);
  800670:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800674:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80067b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80067e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800682:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800689:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800695:	8b 00                	mov    (%eax),%eax
  800697:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80069c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a1:	eb 0d                	jmp    8006b0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 0a fc ff ff       	call   8002b5 <getuint>
			base = 16;
  8006ab:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8006b0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006b4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006b8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006bb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006bf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006c3:	89 04 24             	mov    %eax,(%esp)
  8006c6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ca:	89 fa                	mov    %edi,%edx
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	e8 ec fa ff ff       	call   8001c0 <printnum>
			break;
  8006d4:	e9 84 fc ff ff       	jmp    80035d <vprintfmt+0x29>
			putch(ch, putdat);
  8006d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006dd:	89 0c 24             	mov    %ecx,(%esp)
  8006e0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006e3:	e9 75 fc ff ff       	jmp    80035d <vprintfmt+0x29>
			putch('%', putdat);
  8006e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ec:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006f3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006fa:	0f 84 5b fc ff ff    	je     80035b <vprintfmt+0x27>
  800700:	89 f3                	mov    %esi,%ebx
  800702:	83 eb 01             	sub    $0x1,%ebx
  800705:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800709:	75 f7                	jne    800702 <vprintfmt+0x3ce>
  80070b:	e9 4d fc ff ff       	jmp    80035d <vprintfmt+0x29>
}
  800710:	83 c4 3c             	add    $0x3c,%esp
  800713:	5b                   	pop    %ebx
  800714:	5e                   	pop    %esi
  800715:	5f                   	pop    %edi
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	83 ec 28             	sub    $0x28,%esp
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800724:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800727:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800735:	85 c0                	test   %eax,%eax
  800737:	74 30                	je     800769 <vsnprintf+0x51>
  800739:	85 d2                	test   %edx,%edx
  80073b:	7e 2c                	jle    800769 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800744:	8b 45 10             	mov    0x10(%ebp),%eax
  800747:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800752:	c7 04 24 ef 02 80 00 	movl   $0x8002ef,(%esp)
  800759:	e8 d6 fb ff ff       	call   800334 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80075e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800761:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800764:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800767:	eb 05                	jmp    80076e <vsnprintf+0x56>
		return -E_INVAL;
  800769:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800776:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800779:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077d:	8b 45 10             	mov    0x10(%ebp),%eax
  800780:	89 44 24 08          	mov    %eax,0x8(%esp)
  800784:	8b 45 0c             	mov    0xc(%ebp),%eax
  800787:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	89 04 24             	mov    %eax,(%esp)
  800791:	e8 82 ff ff ff       	call   800718 <vsnprintf>
	va_end(ap);

	return rc;
}
  800796:	c9                   	leave  
  800797:	c3                   	ret    
  800798:	66 90                	xchg   %ax,%ax
  80079a:	66 90                	xchg   %ax,%ax
  80079c:	66 90                	xchg   %ax,%ax
  80079e:	66 90                	xchg   %ax,%ax

008007a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007a9:	74 10                	je     8007bb <strlen+0x1b>
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007b0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b7:	75 f7                	jne    8007b0 <strlen+0x10>
  8007b9:	eb 05                	jmp    8007c0 <strlen+0x20>
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cc:	85 c9                	test   %ecx,%ecx
  8007ce:	74 1c                	je     8007ec <strnlen+0x2a>
  8007d0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007d3:	74 1e                	je     8007f3 <strnlen+0x31>
  8007d5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007da:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007dc:	39 ca                	cmp    %ecx,%edx
  8007de:	74 18                	je     8007f8 <strnlen+0x36>
  8007e0:	83 c2 01             	add    $0x1,%edx
  8007e3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007e8:	75 f0                	jne    8007da <strnlen+0x18>
  8007ea:	eb 0c                	jmp    8007f8 <strnlen+0x36>
  8007ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f1:	eb 05                	jmp    8007f8 <strnlen+0x36>
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8007f8:	5b                   	pop    %ebx
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800805:	89 c2                	mov    %eax,%edx
  800807:	83 c2 01             	add    $0x1,%edx
  80080a:	83 c1 01             	add    $0x1,%ecx
  80080d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800811:	88 5a ff             	mov    %bl,-0x1(%edx)
  800814:	84 db                	test   %bl,%bl
  800816:	75 ef                	jne    800807 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800818:	5b                   	pop    %ebx
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800825:	89 1c 24             	mov    %ebx,(%esp)
  800828:	e8 73 ff ff ff       	call   8007a0 <strlen>
	strcpy(dst + len, src);
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800830:	89 54 24 04          	mov    %edx,0x4(%esp)
  800834:	01 d8                	add    %ebx,%eax
  800836:	89 04 24             	mov    %eax,(%esp)
  800839:	e8 bd ff ff ff       	call   8007fb <strcpy>
	return dst;
}
  80083e:	89 d8                	mov    %ebx,%eax
  800840:	83 c4 08             	add    $0x8,%esp
  800843:	5b                   	pop    %ebx
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	56                   	push   %esi
  80084a:	53                   	push   %ebx
  80084b:	8b 75 08             	mov    0x8(%ebp),%esi
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800851:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800854:	85 db                	test   %ebx,%ebx
  800856:	74 17                	je     80086f <strncpy+0x29>
  800858:	01 f3                	add    %esi,%ebx
  80085a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80085c:	83 c1 01             	add    $0x1,%ecx
  80085f:	0f b6 02             	movzbl (%edx),%eax
  800862:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800865:	80 3a 01             	cmpb   $0x1,(%edx)
  800868:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80086b:	39 d9                	cmp    %ebx,%ecx
  80086d:	75 ed                	jne    80085c <strncpy+0x16>
	}
	return ret;
}
  80086f:	89 f0                	mov    %esi,%eax
  800871:	5b                   	pop    %ebx
  800872:	5e                   	pop    %esi
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	57                   	push   %edi
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800881:	8b 75 10             	mov    0x10(%ebp),%esi
  800884:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800886:	85 f6                	test   %esi,%esi
  800888:	74 34                	je     8008be <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  80088a:	83 fe 01             	cmp    $0x1,%esi
  80088d:	74 26                	je     8008b5 <strlcpy+0x40>
  80088f:	0f b6 0b             	movzbl (%ebx),%ecx
  800892:	84 c9                	test   %cl,%cl
  800894:	74 23                	je     8008b9 <strlcpy+0x44>
  800896:	83 ee 02             	sub    $0x2,%esi
  800899:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  80089e:	83 c0 01             	add    $0x1,%eax
  8008a1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008a4:	39 f2                	cmp    %esi,%edx
  8008a6:	74 13                	je     8008bb <strlcpy+0x46>
  8008a8:	83 c2 01             	add    $0x1,%edx
  8008ab:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008af:	84 c9                	test   %cl,%cl
  8008b1:	75 eb                	jne    80089e <strlcpy+0x29>
  8008b3:	eb 06                	jmp    8008bb <strlcpy+0x46>
  8008b5:	89 f8                	mov    %edi,%eax
  8008b7:	eb 02                	jmp    8008bb <strlcpy+0x46>
  8008b9:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  8008bb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008be:	29 f8                	sub    %edi,%eax
}
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5f                   	pop    %edi
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ce:	0f b6 01             	movzbl (%ecx),%eax
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 15                	je     8008ea <strcmp+0x25>
  8008d5:	3a 02                	cmp    (%edx),%al
  8008d7:	75 11                	jne    8008ea <strcmp+0x25>
		p++, q++;
  8008d9:	83 c1 01             	add    $0x1,%ecx
  8008dc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008df:	0f b6 01             	movzbl (%ecx),%eax
  8008e2:	84 c0                	test   %al,%al
  8008e4:	74 04                	je     8008ea <strcmp+0x25>
  8008e6:	3a 02                	cmp    (%edx),%al
  8008e8:	74 ef                	je     8008d9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ea:	0f b6 c0             	movzbl %al,%eax
  8008ed:	0f b6 12             	movzbl (%edx),%edx
  8008f0:	29 d0                	sub    %edx,%eax
}
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	56                   	push   %esi
  8008f8:	53                   	push   %ebx
  8008f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ff:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800902:	85 f6                	test   %esi,%esi
  800904:	74 29                	je     80092f <strncmp+0x3b>
  800906:	0f b6 03             	movzbl (%ebx),%eax
  800909:	84 c0                	test   %al,%al
  80090b:	74 30                	je     80093d <strncmp+0x49>
  80090d:	3a 02                	cmp    (%edx),%al
  80090f:	75 2c                	jne    80093d <strncmp+0x49>
  800911:	8d 43 01             	lea    0x1(%ebx),%eax
  800914:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800916:	89 c3                	mov    %eax,%ebx
  800918:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80091b:	39 f0                	cmp    %esi,%eax
  80091d:	74 17                	je     800936 <strncmp+0x42>
  80091f:	0f b6 08             	movzbl (%eax),%ecx
  800922:	84 c9                	test   %cl,%cl
  800924:	74 17                	je     80093d <strncmp+0x49>
  800926:	83 c0 01             	add    $0x1,%eax
  800929:	3a 0a                	cmp    (%edx),%cl
  80092b:	74 e9                	je     800916 <strncmp+0x22>
  80092d:	eb 0e                	jmp    80093d <strncmp+0x49>
	if (n == 0)
		return 0;
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
  800934:	eb 0f                	jmp    800945 <strncmp+0x51>
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
  80093b:	eb 08                	jmp    800945 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80093d:	0f b6 03             	movzbl (%ebx),%eax
  800940:	0f b6 12             	movzbl (%edx),%edx
  800943:	29 d0                	sub    %edx,%eax
}
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	53                   	push   %ebx
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800953:	0f b6 18             	movzbl (%eax),%ebx
  800956:	84 db                	test   %bl,%bl
  800958:	74 1d                	je     800977 <strchr+0x2e>
  80095a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80095c:	38 d3                	cmp    %dl,%bl
  80095e:	75 06                	jne    800966 <strchr+0x1d>
  800960:	eb 1a                	jmp    80097c <strchr+0x33>
  800962:	38 ca                	cmp    %cl,%dl
  800964:	74 16                	je     80097c <strchr+0x33>
	for (; *s; s++)
  800966:	83 c0 01             	add    $0x1,%eax
  800969:	0f b6 10             	movzbl (%eax),%edx
  80096c:	84 d2                	test   %dl,%dl
  80096e:	75 f2                	jne    800962 <strchr+0x19>
			return (char *) s;
	return 0;
  800970:	b8 00 00 00 00       	mov    $0x0,%eax
  800975:	eb 05                	jmp    80097c <strchr+0x33>
  800977:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097c:	5b                   	pop    %ebx
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800989:	0f b6 18             	movzbl (%eax),%ebx
  80098c:	84 db                	test   %bl,%bl
  80098e:	74 16                	je     8009a6 <strfind+0x27>
  800990:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800992:	38 d3                	cmp    %dl,%bl
  800994:	75 06                	jne    80099c <strfind+0x1d>
  800996:	eb 0e                	jmp    8009a6 <strfind+0x27>
  800998:	38 ca                	cmp    %cl,%dl
  80099a:	74 0a                	je     8009a6 <strfind+0x27>
	for (; *s; s++)
  80099c:	83 c0 01             	add    $0x1,%eax
  80099f:	0f b6 10             	movzbl (%eax),%edx
  8009a2:	84 d2                	test   %dl,%dl
  8009a4:	75 f2                	jne    800998 <strfind+0x19>
			break;
	return (char *) s;
}
  8009a6:	5b                   	pop    %ebx
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	57                   	push   %edi
  8009ad:	56                   	push   %esi
  8009ae:	53                   	push   %ebx
  8009af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b5:	85 c9                	test   %ecx,%ecx
  8009b7:	74 36                	je     8009ef <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bf:	75 28                	jne    8009e9 <memset+0x40>
  8009c1:	f6 c1 03             	test   $0x3,%cl
  8009c4:	75 23                	jne    8009e9 <memset+0x40>
		c &= 0xFF;
  8009c6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ca:	89 d3                	mov    %edx,%ebx
  8009cc:	c1 e3 08             	shl    $0x8,%ebx
  8009cf:	89 d6                	mov    %edx,%esi
  8009d1:	c1 e6 18             	shl    $0x18,%esi
  8009d4:	89 d0                	mov    %edx,%eax
  8009d6:	c1 e0 10             	shl    $0x10,%eax
  8009d9:	09 f0                	or     %esi,%eax
  8009db:	09 c2                	or     %eax,%edx
  8009dd:	89 d0                	mov    %edx,%eax
  8009df:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009e4:	fc                   	cld    
  8009e5:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e7:	eb 06                	jmp    8009ef <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ec:	fc                   	cld    
  8009ed:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ef:	89 f8                	mov    %edi,%eax
  8009f1:	5b                   	pop    %ebx
  8009f2:	5e                   	pop    %esi
  8009f3:	5f                   	pop    %edi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	57                   	push   %edi
  8009fa:	56                   	push   %esi
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a01:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a04:	39 c6                	cmp    %eax,%esi
  800a06:	73 35                	jae    800a3d <memmove+0x47>
  800a08:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0b:	39 d0                	cmp    %edx,%eax
  800a0d:	73 2e                	jae    800a3d <memmove+0x47>
		s += n;
		d += n;
  800a0f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a12:	89 d6                	mov    %edx,%esi
  800a14:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a16:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1c:	75 13                	jne    800a31 <memmove+0x3b>
  800a1e:	f6 c1 03             	test   $0x3,%cl
  800a21:	75 0e                	jne    800a31 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a23:	83 ef 04             	sub    $0x4,%edi
  800a26:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a29:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a2c:	fd                   	std    
  800a2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2f:	eb 09                	jmp    800a3a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a31:	83 ef 01             	sub    $0x1,%edi
  800a34:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a37:	fd                   	std    
  800a38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a3a:	fc                   	cld    
  800a3b:	eb 1d                	jmp    800a5a <memmove+0x64>
  800a3d:	89 f2                	mov    %esi,%edx
  800a3f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a41:	f6 c2 03             	test   $0x3,%dl
  800a44:	75 0f                	jne    800a55 <memmove+0x5f>
  800a46:	f6 c1 03             	test   $0x3,%cl
  800a49:	75 0a                	jne    800a55 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a4b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a4e:	89 c7                	mov    %eax,%edi
  800a50:	fc                   	cld    
  800a51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a53:	eb 05                	jmp    800a5a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800a55:	89 c7                	mov    %eax,%edi
  800a57:	fc                   	cld    
  800a58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5a:	5e                   	pop    %esi
  800a5b:	5f                   	pop    %edi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a64:	8b 45 10             	mov    0x10(%ebp),%eax
  800a67:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	89 04 24             	mov    %eax,(%esp)
  800a78:	e8 79 ff ff ff       	call   8009f6 <memmove>
}
  800a7d:	c9                   	leave  
  800a7e:	c3                   	ret    

00800a7f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	57                   	push   %edi
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800a91:	85 c0                	test   %eax,%eax
  800a93:	74 36                	je     800acb <memcmp+0x4c>
		if (*s1 != *s2)
  800a95:	0f b6 03             	movzbl (%ebx),%eax
  800a98:	0f b6 0e             	movzbl (%esi),%ecx
  800a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa0:	38 c8                	cmp    %cl,%al
  800aa2:	74 1c                	je     800ac0 <memcmp+0x41>
  800aa4:	eb 10                	jmp    800ab6 <memcmp+0x37>
  800aa6:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800aab:	83 c2 01             	add    $0x1,%edx
  800aae:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ab2:	38 c8                	cmp    %cl,%al
  800ab4:	74 0a                	je     800ac0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ab6:	0f b6 c0             	movzbl %al,%eax
  800ab9:	0f b6 c9             	movzbl %cl,%ecx
  800abc:	29 c8                	sub    %ecx,%eax
  800abe:	eb 10                	jmp    800ad0 <memcmp+0x51>
	while (n-- > 0) {
  800ac0:	39 fa                	cmp    %edi,%edx
  800ac2:	75 e2                	jne    800aa6 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac9:	eb 05                	jmp    800ad0 <memcmp+0x51>
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5f                   	pop    %edi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	53                   	push   %ebx
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800adf:	89 c2                	mov    %eax,%edx
  800ae1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae4:	39 d0                	cmp    %edx,%eax
  800ae6:	73 13                	jae    800afb <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae8:	89 d9                	mov    %ebx,%ecx
  800aea:	38 18                	cmp    %bl,(%eax)
  800aec:	75 06                	jne    800af4 <memfind+0x1f>
  800aee:	eb 0b                	jmp    800afb <memfind+0x26>
  800af0:	38 08                	cmp    %cl,(%eax)
  800af2:	74 07                	je     800afb <memfind+0x26>
	for (; s < ends; s++)
  800af4:	83 c0 01             	add    $0x1,%eax
  800af7:	39 d0                	cmp    %edx,%eax
  800af9:	75 f5                	jne    800af0 <memfind+0x1b>
			break;
	return (void *) s;
}
  800afb:	5b                   	pop    %ebx
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
  800b04:	8b 55 08             	mov    0x8(%ebp),%edx
  800b07:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0a:	0f b6 0a             	movzbl (%edx),%ecx
  800b0d:	80 f9 09             	cmp    $0x9,%cl
  800b10:	74 05                	je     800b17 <strtol+0x19>
  800b12:	80 f9 20             	cmp    $0x20,%cl
  800b15:	75 10                	jne    800b27 <strtol+0x29>
		s++;
  800b17:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b1a:	0f b6 0a             	movzbl (%edx),%ecx
  800b1d:	80 f9 09             	cmp    $0x9,%cl
  800b20:	74 f5                	je     800b17 <strtol+0x19>
  800b22:	80 f9 20             	cmp    $0x20,%cl
  800b25:	74 f0                	je     800b17 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800b27:	80 f9 2b             	cmp    $0x2b,%cl
  800b2a:	75 0a                	jne    800b36 <strtol+0x38>
		s++;
  800b2c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b2f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b34:	eb 11                	jmp    800b47 <strtol+0x49>
  800b36:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800b3b:	80 f9 2d             	cmp    $0x2d,%cl
  800b3e:	75 07                	jne    800b47 <strtol+0x49>
		s++, neg = 1;
  800b40:	83 c2 01             	add    $0x1,%edx
  800b43:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b47:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b4c:	75 15                	jne    800b63 <strtol+0x65>
  800b4e:	80 3a 30             	cmpb   $0x30,(%edx)
  800b51:	75 10                	jne    800b63 <strtol+0x65>
  800b53:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b57:	75 0a                	jne    800b63 <strtol+0x65>
		s += 2, base = 16;
  800b59:	83 c2 02             	add    $0x2,%edx
  800b5c:	b8 10 00 00 00       	mov    $0x10,%eax
  800b61:	eb 10                	jmp    800b73 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800b63:	85 c0                	test   %eax,%eax
  800b65:	75 0c                	jne    800b73 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b67:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800b69:	80 3a 30             	cmpb   $0x30,(%edx)
  800b6c:	75 05                	jne    800b73 <strtol+0x75>
		s++, base = 8;
  800b6e:	83 c2 01             	add    $0x1,%edx
  800b71:	b0 08                	mov    $0x8,%al
		base = 10;
  800b73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b78:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b7b:	0f b6 0a             	movzbl (%edx),%ecx
  800b7e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b81:	89 f0                	mov    %esi,%eax
  800b83:	3c 09                	cmp    $0x9,%al
  800b85:	77 08                	ja     800b8f <strtol+0x91>
			dig = *s - '0';
  800b87:	0f be c9             	movsbl %cl,%ecx
  800b8a:	83 e9 30             	sub    $0x30,%ecx
  800b8d:	eb 20                	jmp    800baf <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800b8f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b92:	89 f0                	mov    %esi,%eax
  800b94:	3c 19                	cmp    $0x19,%al
  800b96:	77 08                	ja     800ba0 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800b98:	0f be c9             	movsbl %cl,%ecx
  800b9b:	83 e9 57             	sub    $0x57,%ecx
  800b9e:	eb 0f                	jmp    800baf <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800ba0:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ba3:	89 f0                	mov    %esi,%eax
  800ba5:	3c 19                	cmp    $0x19,%al
  800ba7:	77 16                	ja     800bbf <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ba9:	0f be c9             	movsbl %cl,%ecx
  800bac:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800baf:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bb2:	7d 0f                	jge    800bc3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bb4:	83 c2 01             	add    $0x1,%edx
  800bb7:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bbb:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bbd:	eb bc                	jmp    800b7b <strtol+0x7d>
  800bbf:	89 d8                	mov    %ebx,%eax
  800bc1:	eb 02                	jmp    800bc5 <strtol+0xc7>
  800bc3:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bc5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc9:	74 05                	je     800bd0 <strtol+0xd2>
		*endptr = (char *) s;
  800bcb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bce:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bd0:	f7 d8                	neg    %eax
  800bd2:	85 ff                	test   %edi,%edi
  800bd4:	0f 44 c3             	cmove  %ebx,%eax
}
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be2:	b8 00 00 00 00       	mov    $0x0,%eax
  800be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bea:	8b 55 08             	mov    0x8(%ebp),%edx
  800bed:	89 c3                	mov    %eax,%ebx
  800bef:	89 c7                	mov    %eax,%edi
  800bf1:	89 c6                	mov    %eax,%esi
  800bf3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_cgetc>:

int
sys_cgetc(void)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c00:	ba 00 00 00 00       	mov    $0x0,%edx
  800c05:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0a:	89 d1                	mov    %edx,%ecx
  800c0c:	89 d3                	mov    %edx,%ebx
  800c0e:	89 d7                	mov    %edx,%edi
  800c10:	89 d6                	mov    %edx,%esi
  800c12:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
  800c1f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c27:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2f:	89 cb                	mov    %ecx,%ebx
  800c31:	89 cf                	mov    %ecx,%edi
  800c33:	89 ce                	mov    %ecx,%esi
  800c35:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c37:	85 c0                	test   %eax,%eax
  800c39:	7e 28                	jle    800c63 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c3f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c46:	00 
  800c47:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800c4e:	00 
  800c4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c56:	00 
  800c57:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800c5e:	e8 63 10 00 00       	call   801cc6 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c63:	83 c4 2c             	add    $0x2c,%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c71:	ba 00 00 00 00       	mov    $0x0,%edx
  800c76:	b8 02 00 00 00       	mov    $0x2,%eax
  800c7b:	89 d1                	mov    %edx,%ecx
  800c7d:	89 d3                	mov    %edx,%ebx
  800c7f:	89 d7                	mov    %edx,%edi
  800c81:	89 d6                	mov    %edx,%esi
  800c83:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_yield>:

void
sys_yield(void)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c90:	ba 00 00 00 00       	mov    $0x0,%edx
  800c95:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9a:	89 d1                	mov    %edx,%ecx
  800c9c:	89 d3                	mov    %edx,%ebx
  800c9e:	89 d7                	mov    %edx,%edi
  800ca0:	89 d6                	mov    %edx,%esi
  800ca2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
  800caf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cb2:	be 00 00 00 00       	mov    $0x0,%esi
  800cb7:	b8 04 00 00 00       	mov    $0x4,%eax
  800cbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc5:	89 f7                	mov    %esi,%edi
  800cc7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 28                	jle    800cf5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cd8:	00 
  800cd9:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce8:	00 
  800ce9:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800cf0:	e8 d1 0f 00 00       	call   801cc6 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf5:	83 c4 2c             	add    $0x2c,%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d06:	b8 05 00 00 00       	mov    $0x5,%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d14:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d17:	8b 75 18             	mov    0x18(%ebp),%esi
  800d1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 28                	jle    800d48 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d24:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d2b:	00 
  800d2c:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800d33:	00 
  800d34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3b:	00 
  800d3c:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800d43:	e8 7e 0f 00 00       	call   801cc6 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d48:	83 c4 2c             	add    $0x2c,%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	89 df                	mov    %ebx,%edi
  800d6b:	89 de                	mov    %ebx,%esi
  800d6d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	7e 28                	jle    800d9b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d77:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d7e:	00 
  800d7f:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800d86:	00 
  800d87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8e:	00 
  800d8f:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800d96:	e8 2b 0f 00 00       	call   801cc6 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d9b:	83 c4 2c             	add    $0x2c,%esp
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db1:	b8 08 00 00 00       	mov    $0x8,%eax
  800db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	89 df                	mov    %ebx,%edi
  800dbe:	89 de                	mov    %ebx,%esi
  800dc0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	7e 28                	jle    800dee <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dca:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dd1:	00 
  800dd2:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800dd9:	00 
  800dda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de1:	00 
  800de2:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800de9:	e8 d8 0e 00 00       	call   801cc6 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dee:	83 c4 2c             	add    $0x2c,%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
  800dfc:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e04:	b8 09 00 00 00       	mov    $0x9,%eax
  800e09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0f:	89 df                	mov    %ebx,%edi
  800e11:	89 de                	mov    %ebx,%esi
  800e13:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e15:	85 c0                	test   %eax,%eax
  800e17:	7e 28                	jle    800e41 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e24:	00 
  800e25:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800e2c:	00 
  800e2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e34:	00 
  800e35:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800e3c:	e8 85 0e 00 00       	call   801cc6 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e41:	83 c4 2c             	add    $0x2c,%esp
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e57:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e62:	89 df                	mov    %ebx,%edi
  800e64:	89 de                	mov    %ebx,%esi
  800e66:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	7e 28                	jle    800e94 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e70:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e77:	00 
  800e78:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800e7f:	00 
  800e80:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e87:	00 
  800e88:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800e8f:	e8 32 0e 00 00       	call   801cc6 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e94:	83 c4 2c             	add    $0x2c,%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	57                   	push   %edi
  800ea0:	56                   	push   %esi
  800ea1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ea2:	be 00 00 00 00       	mov    $0x0,%esi
  800ea7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eba:	5b                   	pop    %ebx
  800ebb:	5e                   	pop    %esi
  800ebc:	5f                   	pop    %edi
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	57                   	push   %edi
  800ec3:	56                   	push   %esi
  800ec4:	53                   	push   %ebx
  800ec5:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ec8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ecd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ed2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed5:	89 cb                	mov    %ecx,%ebx
  800ed7:	89 cf                	mov    %ecx,%edi
  800ed9:	89 ce                	mov    %ecx,%esi
  800edb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800edd:	85 c0                	test   %eax,%eax
  800edf:	7e 28                	jle    800f09 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800eec:	00 
  800eed:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800ef4:	00 
  800ef5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800efc:	00 
  800efd:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800f04:	e8 bd 0d 00 00       	call   801cc6 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f09:	83 c4 2c             	add    $0x2c,%esp
  800f0c:	5b                   	pop    %ebx
  800f0d:	5e                   	pop    %esi
  800f0e:	5f                   	pop    %edi
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    
  800f11:	66 90                	xchg   %ax,%ax
  800f13:	66 90                	xchg   %ax,%ax
  800f15:	66 90                	xchg   %ax,%ax
  800f17:	66 90                	xchg   %ax,%ax
  800f19:	66 90                	xchg   %ax,%ax
  800f1b:	66 90                	xchg   %ax,%ax
  800f1d:	66 90                	xchg   %ax,%ax
  800f1f:	90                   	nop

00800f20 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f23:	8b 45 08             	mov    0x8(%ebp),%eax
  800f26:	05 00 00 00 30       	add    $0x30000000,%eax
  800f2b:	c1 e8 0c             	shr    $0xc,%eax
}
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f33:	8b 45 08             	mov    0x8(%ebp),%eax
  800f36:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f40:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f4a:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800f4f:	a8 01                	test   $0x1,%al
  800f51:	74 34                	je     800f87 <fd_alloc+0x40>
  800f53:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800f58:	a8 01                	test   $0x1,%al
  800f5a:	74 32                	je     800f8e <fd_alloc+0x47>
  800f5c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  800f61:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f63:	89 c2                	mov    %eax,%edx
  800f65:	c1 ea 16             	shr    $0x16,%edx
  800f68:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f6f:	f6 c2 01             	test   $0x1,%dl
  800f72:	74 1f                	je     800f93 <fd_alloc+0x4c>
  800f74:	89 c2                	mov    %eax,%edx
  800f76:	c1 ea 0c             	shr    $0xc,%edx
  800f79:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f80:	f6 c2 01             	test   $0x1,%dl
  800f83:	75 1a                	jne    800f9f <fd_alloc+0x58>
  800f85:	eb 0c                	jmp    800f93 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  800f87:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800f8c:	eb 05                	jmp    800f93 <fd_alloc+0x4c>
  800f8e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  800f93:	8b 45 08             	mov    0x8(%ebp),%eax
  800f96:	89 08                	mov    %ecx,(%eax)
			return 0;
  800f98:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9d:	eb 1a                	jmp    800fb9 <fd_alloc+0x72>
  800f9f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800fa4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fa9:	75 b6                	jne    800f61 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  800fab:	8b 45 08             	mov    0x8(%ebp),%eax
  800fae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800fb4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    

00800fbb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fc1:	83 f8 1f             	cmp    $0x1f,%eax
  800fc4:	77 36                	ja     800ffc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fc6:	c1 e0 0c             	shl    $0xc,%eax
  800fc9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fce:	89 c2                	mov    %eax,%edx
  800fd0:	c1 ea 16             	shr    $0x16,%edx
  800fd3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fda:	f6 c2 01             	test   $0x1,%dl
  800fdd:	74 24                	je     801003 <fd_lookup+0x48>
  800fdf:	89 c2                	mov    %eax,%edx
  800fe1:	c1 ea 0c             	shr    $0xc,%edx
  800fe4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800feb:	f6 c2 01             	test   $0x1,%dl
  800fee:	74 1a                	je     80100a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ff0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff3:	89 02                	mov    %eax,(%edx)
	return 0;
  800ff5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffa:	eb 13                	jmp    80100f <fd_lookup+0x54>
		return -E_INVAL;
  800ffc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801001:	eb 0c                	jmp    80100f <fd_lookup+0x54>
		return -E_INVAL;
  801003:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801008:	eb 05                	jmp    80100f <fd_lookup+0x54>
  80100a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    

00801011 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	53                   	push   %ebx
  801015:	83 ec 14             	sub    $0x14,%esp
  801018:	8b 45 08             	mov    0x8(%ebp),%eax
  80101b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80101e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801024:	75 1e                	jne    801044 <dev_lookup+0x33>
  801026:	eb 0e                	jmp    801036 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  801028:	b8 20 30 80 00       	mov    $0x803020,%eax
  80102d:	eb 0c                	jmp    80103b <dev_lookup+0x2a>
  80102f:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801034:	eb 05                	jmp    80103b <dev_lookup+0x2a>
  801036:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  80103b:	89 03                	mov    %eax,(%ebx)
			return 0;
  80103d:	b8 00 00 00 00       	mov    $0x0,%eax
  801042:	eb 38                	jmp    80107c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  801044:	39 05 20 30 80 00    	cmp    %eax,0x803020
  80104a:	74 dc                	je     801028 <dev_lookup+0x17>
  80104c:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  801052:	74 db                	je     80102f <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801054:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80105a:	8b 52 48             	mov    0x48(%edx),%edx
  80105d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801061:	89 54 24 04          	mov    %edx,0x4(%esp)
  801065:	c7 04 24 8c 24 80 00 	movl   $0x80248c,(%esp)
  80106c:	e8 31 f1 ff ff       	call   8001a2 <cprintf>
	*dev = 0;
  801071:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801077:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80107c:	83 c4 14             	add    $0x14,%esp
  80107f:	5b                   	pop    %ebx
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <fd_close>:
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	56                   	push   %esi
  801086:	53                   	push   %ebx
  801087:	83 ec 20             	sub    $0x20,%esp
  80108a:	8b 75 08             	mov    0x8(%ebp),%esi
  80108d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801090:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801093:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801097:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80109d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010a0:	89 04 24             	mov    %eax,(%esp)
  8010a3:	e8 13 ff ff ff       	call   800fbb <fd_lookup>
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	78 05                	js     8010b1 <fd_close+0x2f>
	    || fd != fd2)
  8010ac:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010af:	74 0c                	je     8010bd <fd_close+0x3b>
		return (must_exist ? r : 0);
  8010b1:	84 db                	test   %bl,%bl
  8010b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b8:	0f 44 c2             	cmove  %edx,%eax
  8010bb:	eb 3f                	jmp    8010fc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c4:	8b 06                	mov    (%esi),%eax
  8010c6:	89 04 24             	mov    %eax,(%esp)
  8010c9:	e8 43 ff ff ff       	call   801011 <dev_lookup>
  8010ce:	89 c3                	mov    %eax,%ebx
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	78 16                	js     8010ea <fd_close+0x68>
		if (dev->dev_close)
  8010d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d7:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8010da:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	74 07                	je     8010ea <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8010e3:	89 34 24             	mov    %esi,(%esp)
  8010e6:	ff d0                	call   *%eax
  8010e8:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8010ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f5:	e8 56 fc ff ff       	call   800d50 <sys_page_unmap>
	return r;
  8010fa:	89 d8                	mov    %ebx,%eax
}
  8010fc:	83 c4 20             	add    $0x20,%esp
  8010ff:	5b                   	pop    %ebx
  801100:	5e                   	pop    %esi
  801101:	5d                   	pop    %ebp
  801102:	c3                   	ret    

00801103 <close>:

int
close(int fdnum)
{
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801109:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801110:	8b 45 08             	mov    0x8(%ebp),%eax
  801113:	89 04 24             	mov    %eax,(%esp)
  801116:	e8 a0 fe ff ff       	call   800fbb <fd_lookup>
  80111b:	89 c2                	mov    %eax,%edx
  80111d:	85 d2                	test   %edx,%edx
  80111f:	78 13                	js     801134 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801121:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801128:	00 
  801129:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112c:	89 04 24             	mov    %eax,(%esp)
  80112f:	e8 4e ff ff ff       	call   801082 <fd_close>
}
  801134:	c9                   	leave  
  801135:	c3                   	ret    

00801136 <close_all>:

void
close_all(void)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	53                   	push   %ebx
  80113a:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80113d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801142:	89 1c 24             	mov    %ebx,(%esp)
  801145:	e8 b9 ff ff ff       	call   801103 <close>
	for (i = 0; i < MAXFD; i++)
  80114a:	83 c3 01             	add    $0x1,%ebx
  80114d:	83 fb 20             	cmp    $0x20,%ebx
  801150:	75 f0                	jne    801142 <close_all+0xc>
}
  801152:	83 c4 14             	add    $0x14,%esp
  801155:	5b                   	pop    %ebx
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    

00801158 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	57                   	push   %edi
  80115c:	56                   	push   %esi
  80115d:	53                   	push   %ebx
  80115e:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801161:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801164:	89 44 24 04          	mov    %eax,0x4(%esp)
  801168:	8b 45 08             	mov    0x8(%ebp),%eax
  80116b:	89 04 24             	mov    %eax,(%esp)
  80116e:	e8 48 fe ff ff       	call   800fbb <fd_lookup>
  801173:	89 c2                	mov    %eax,%edx
  801175:	85 d2                	test   %edx,%edx
  801177:	0f 88 e1 00 00 00    	js     80125e <dup+0x106>
		return r;
	close(newfdnum);
  80117d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801180:	89 04 24             	mov    %eax,(%esp)
  801183:	e8 7b ff ff ff       	call   801103 <close>

	newfd = INDEX2FD(newfdnum);
  801188:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80118b:	c1 e3 0c             	shl    $0xc,%ebx
  80118e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801194:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801197:	89 04 24             	mov    %eax,(%esp)
  80119a:	e8 91 fd ff ff       	call   800f30 <fd2data>
  80119f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8011a1:	89 1c 24             	mov    %ebx,(%esp)
  8011a4:	e8 87 fd ff ff       	call   800f30 <fd2data>
  8011a9:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011ab:	89 f0                	mov    %esi,%eax
  8011ad:	c1 e8 16             	shr    $0x16,%eax
  8011b0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011b7:	a8 01                	test   $0x1,%al
  8011b9:	74 43                	je     8011fe <dup+0xa6>
  8011bb:	89 f0                	mov    %esi,%eax
  8011bd:	c1 e8 0c             	shr    $0xc,%eax
  8011c0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011c7:	f6 c2 01             	test   $0x1,%dl
  8011ca:	74 32                	je     8011fe <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011d3:	25 07 0e 00 00       	and    $0xe07,%eax
  8011d8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011dc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011e7:	00 
  8011e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f3:	e8 05 fb ff ff       	call   800cfd <sys_page_map>
  8011f8:	89 c6                	mov    %eax,%esi
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	78 3e                	js     80123c <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801201:	89 c2                	mov    %eax,%edx
  801203:	c1 ea 0c             	shr    $0xc,%edx
  801206:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801213:	89 54 24 10          	mov    %edx,0x10(%esp)
  801217:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80121b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801222:	00 
  801223:	89 44 24 04          	mov    %eax,0x4(%esp)
  801227:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80122e:	e8 ca fa ff ff       	call   800cfd <sys_page_map>
  801233:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801235:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801238:	85 f6                	test   %esi,%esi
  80123a:	79 22                	jns    80125e <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80123c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801247:	e8 04 fb ff ff       	call   800d50 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80124c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801250:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801257:	e8 f4 fa ff ff       	call   800d50 <sys_page_unmap>
	return r;
  80125c:	89 f0                	mov    %esi,%eax
}
  80125e:	83 c4 3c             	add    $0x3c,%esp
  801261:	5b                   	pop    %ebx
  801262:	5e                   	pop    %esi
  801263:	5f                   	pop    %edi
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    

00801266 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	53                   	push   %ebx
  80126a:	83 ec 24             	sub    $0x24,%esp
  80126d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801270:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801273:	89 44 24 04          	mov    %eax,0x4(%esp)
  801277:	89 1c 24             	mov    %ebx,(%esp)
  80127a:	e8 3c fd ff ff       	call   800fbb <fd_lookup>
  80127f:	89 c2                	mov    %eax,%edx
  801281:	85 d2                	test   %edx,%edx
  801283:	78 6d                	js     8012f2 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801285:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128f:	8b 00                	mov    (%eax),%eax
  801291:	89 04 24             	mov    %eax,(%esp)
  801294:	e8 78 fd ff ff       	call   801011 <dev_lookup>
  801299:	85 c0                	test   %eax,%eax
  80129b:	78 55                	js     8012f2 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80129d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a0:	8b 50 08             	mov    0x8(%eax),%edx
  8012a3:	83 e2 03             	and    $0x3,%edx
  8012a6:	83 fa 01             	cmp    $0x1,%edx
  8012a9:	75 23                	jne    8012ce <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ab:	a1 04 40 80 00       	mov    0x804004,%eax
  8012b0:	8b 40 48             	mov    0x48(%eax),%eax
  8012b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012bb:	c7 04 24 cd 24 80 00 	movl   $0x8024cd,(%esp)
  8012c2:	e8 db ee ff ff       	call   8001a2 <cprintf>
		return -E_INVAL;
  8012c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012cc:	eb 24                	jmp    8012f2 <read+0x8c>
	}
	if (!dev->dev_read)
  8012ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d1:	8b 52 08             	mov    0x8(%edx),%edx
  8012d4:	85 d2                	test   %edx,%edx
  8012d6:	74 15                	je     8012ed <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012e6:	89 04 24             	mov    %eax,(%esp)
  8012e9:	ff d2                	call   *%edx
  8012eb:	eb 05                	jmp    8012f2 <read+0x8c>
		return -E_NOT_SUPP;
  8012ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8012f2:	83 c4 24             	add    $0x24,%esp
  8012f5:	5b                   	pop    %ebx
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	57                   	push   %edi
  8012fc:	56                   	push   %esi
  8012fd:	53                   	push   %ebx
  8012fe:	83 ec 1c             	sub    $0x1c,%esp
  801301:	8b 7d 08             	mov    0x8(%ebp),%edi
  801304:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801307:	85 f6                	test   %esi,%esi
  801309:	74 33                	je     80133e <readn+0x46>
  80130b:	b8 00 00 00 00       	mov    $0x0,%eax
  801310:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801315:	89 f2                	mov    %esi,%edx
  801317:	29 c2                	sub    %eax,%edx
  801319:	89 54 24 08          	mov    %edx,0x8(%esp)
  80131d:	03 45 0c             	add    0xc(%ebp),%eax
  801320:	89 44 24 04          	mov    %eax,0x4(%esp)
  801324:	89 3c 24             	mov    %edi,(%esp)
  801327:	e8 3a ff ff ff       	call   801266 <read>
		if (m < 0)
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 1b                	js     80134b <readn+0x53>
			return m;
		if (m == 0)
  801330:	85 c0                	test   %eax,%eax
  801332:	74 11                	je     801345 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  801334:	01 c3                	add    %eax,%ebx
  801336:	89 d8                	mov    %ebx,%eax
  801338:	39 f3                	cmp    %esi,%ebx
  80133a:	72 d9                	jb     801315 <readn+0x1d>
  80133c:	eb 0b                	jmp    801349 <readn+0x51>
  80133e:	b8 00 00 00 00       	mov    $0x0,%eax
  801343:	eb 06                	jmp    80134b <readn+0x53>
  801345:	89 d8                	mov    %ebx,%eax
  801347:	eb 02                	jmp    80134b <readn+0x53>
  801349:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80134b:	83 c4 1c             	add    $0x1c,%esp
  80134e:	5b                   	pop    %ebx
  80134f:	5e                   	pop    %esi
  801350:	5f                   	pop    %edi
  801351:	5d                   	pop    %ebp
  801352:	c3                   	ret    

00801353 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	53                   	push   %ebx
  801357:	83 ec 24             	sub    $0x24,%esp
  80135a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80135d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801360:	89 44 24 04          	mov    %eax,0x4(%esp)
  801364:	89 1c 24             	mov    %ebx,(%esp)
  801367:	e8 4f fc ff ff       	call   800fbb <fd_lookup>
  80136c:	89 c2                	mov    %eax,%edx
  80136e:	85 d2                	test   %edx,%edx
  801370:	78 68                	js     8013da <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801372:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801375:	89 44 24 04          	mov    %eax,0x4(%esp)
  801379:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137c:	8b 00                	mov    (%eax),%eax
  80137e:	89 04 24             	mov    %eax,(%esp)
  801381:	e8 8b fc ff ff       	call   801011 <dev_lookup>
  801386:	85 c0                	test   %eax,%eax
  801388:	78 50                	js     8013da <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80138a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801391:	75 23                	jne    8013b6 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801393:	a1 04 40 80 00       	mov    0x804004,%eax
  801398:	8b 40 48             	mov    0x48(%eax),%eax
  80139b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80139f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a3:	c7 04 24 e9 24 80 00 	movl   $0x8024e9,(%esp)
  8013aa:	e8 f3 ed ff ff       	call   8001a2 <cprintf>
		return -E_INVAL;
  8013af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b4:	eb 24                	jmp    8013da <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013b9:	8b 52 0c             	mov    0xc(%edx),%edx
  8013bc:	85 d2                	test   %edx,%edx
  8013be:	74 15                	je     8013d5 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ca:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013ce:	89 04 24             	mov    %eax,(%esp)
  8013d1:	ff d2                	call   *%edx
  8013d3:	eb 05                	jmp    8013da <write+0x87>
		return -E_NOT_SUPP;
  8013d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8013da:	83 c4 24             	add    $0x24,%esp
  8013dd:	5b                   	pop    %ebx
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013e6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f0:	89 04 24             	mov    %eax,(%esp)
  8013f3:	e8 c3 fb ff ff       	call   800fbb <fd_lookup>
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	78 0e                	js     80140a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801402:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801405:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80140a:	c9                   	leave  
  80140b:	c3                   	ret    

0080140c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	53                   	push   %ebx
  801410:	83 ec 24             	sub    $0x24,%esp
  801413:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801416:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801419:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141d:	89 1c 24             	mov    %ebx,(%esp)
  801420:	e8 96 fb ff ff       	call   800fbb <fd_lookup>
  801425:	89 c2                	mov    %eax,%edx
  801427:	85 d2                	test   %edx,%edx
  801429:	78 61                	js     80148c <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801432:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801435:	8b 00                	mov    (%eax),%eax
  801437:	89 04 24             	mov    %eax,(%esp)
  80143a:	e8 d2 fb ff ff       	call   801011 <dev_lookup>
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 49                	js     80148c <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801443:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801446:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80144a:	75 23                	jne    80146f <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80144c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801451:	8b 40 48             	mov    0x48(%eax),%eax
  801454:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801458:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145c:	c7 04 24 ac 24 80 00 	movl   $0x8024ac,(%esp)
  801463:	e8 3a ed ff ff       	call   8001a2 <cprintf>
		return -E_INVAL;
  801468:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146d:	eb 1d                	jmp    80148c <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80146f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801472:	8b 52 18             	mov    0x18(%edx),%edx
  801475:	85 d2                	test   %edx,%edx
  801477:	74 0e                	je     801487 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801479:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80147c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801480:	89 04 24             	mov    %eax,(%esp)
  801483:	ff d2                	call   *%edx
  801485:	eb 05                	jmp    80148c <ftruncate+0x80>
		return -E_NOT_SUPP;
  801487:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80148c:	83 c4 24             	add    $0x24,%esp
  80148f:	5b                   	pop    %ebx
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	53                   	push   %ebx
  801496:	83 ec 24             	sub    $0x24,%esp
  801499:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a6:	89 04 24             	mov    %eax,(%esp)
  8014a9:	e8 0d fb ff ff       	call   800fbb <fd_lookup>
  8014ae:	89 c2                	mov    %eax,%edx
  8014b0:	85 d2                	test   %edx,%edx
  8014b2:	78 52                	js     801506 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014be:	8b 00                	mov    (%eax),%eax
  8014c0:	89 04 24             	mov    %eax,(%esp)
  8014c3:	e8 49 fb ff ff       	call   801011 <dev_lookup>
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 3a                	js     801506 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8014cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014d3:	74 2c                	je     801501 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014d5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014d8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014df:	00 00 00 
	stat->st_isdir = 0;
  8014e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014e9:	00 00 00 
	stat->st_dev = dev;
  8014ec:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014f9:	89 14 24             	mov    %edx,(%esp)
  8014fc:	ff 50 14             	call   *0x14(%eax)
  8014ff:	eb 05                	jmp    801506 <fstat+0x74>
		return -E_NOT_SUPP;
  801501:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801506:	83 c4 24             	add    $0x24,%esp
  801509:	5b                   	pop    %ebx
  80150a:	5d                   	pop    %ebp
  80150b:	c3                   	ret    

0080150c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	56                   	push   %esi
  801510:	53                   	push   %ebx
  801511:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801514:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80151b:	00 
  80151c:	8b 45 08             	mov    0x8(%ebp),%eax
  80151f:	89 04 24             	mov    %eax,(%esp)
  801522:	e8 af 01 00 00       	call   8016d6 <open>
  801527:	89 c3                	mov    %eax,%ebx
  801529:	85 db                	test   %ebx,%ebx
  80152b:	78 1b                	js     801548 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80152d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801530:	89 44 24 04          	mov    %eax,0x4(%esp)
  801534:	89 1c 24             	mov    %ebx,(%esp)
  801537:	e8 56 ff ff ff       	call   801492 <fstat>
  80153c:	89 c6                	mov    %eax,%esi
	close(fd);
  80153e:	89 1c 24             	mov    %ebx,(%esp)
  801541:	e8 bd fb ff ff       	call   801103 <close>
	return r;
  801546:	89 f0                	mov    %esi,%eax
}
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	5b                   	pop    %ebx
  80154c:	5e                   	pop    %esi
  80154d:	5d                   	pop    %ebp
  80154e:	c3                   	ret    

0080154f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	56                   	push   %esi
  801553:	53                   	push   %ebx
  801554:	83 ec 10             	sub    $0x10,%esp
  801557:	89 c6                	mov    %eax,%esi
  801559:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80155b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801562:	75 11                	jne    801575 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801564:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80156b:	e8 50 08 00 00       	call   801dc0 <ipc_find_env>
  801570:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801575:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80157c:	00 
  80157d:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801584:	00 
  801585:	89 74 24 04          	mov    %esi,0x4(%esp)
  801589:	a1 00 40 80 00       	mov    0x804000,%eax
  80158e:	89 04 24             	mov    %eax,(%esp)
  801591:	e8 e2 07 00 00       	call   801d78 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801596:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80159d:	00 
  80159e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a9:	e8 6e 07 00 00       	call   801d1c <ipc_recv>
}
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	5b                   	pop    %ebx
  8015b2:	5e                   	pop    %esi
  8015b3:	5d                   	pop    %ebp
  8015b4:	c3                   	ret    

008015b5 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	53                   	push   %ebx
  8015b9:	83 ec 14             	sub    $0x14,%esp
  8015bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cf:	b8 05 00 00 00       	mov    $0x5,%eax
  8015d4:	e8 76 ff ff ff       	call   80154f <fsipc>
  8015d9:	89 c2                	mov    %eax,%edx
  8015db:	85 d2                	test   %edx,%edx
  8015dd:	78 2b                	js     80160a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015df:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015e6:	00 
  8015e7:	89 1c 24             	mov    %ebx,(%esp)
  8015ea:	e8 0c f2 ff ff       	call   8007fb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015ef:	a1 80 50 80 00       	mov    0x805080,%eax
  8015f4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015fa:	a1 84 50 80 00       	mov    0x805084,%eax
  8015ff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801605:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80160a:	83 c4 14             	add    $0x14,%esp
  80160d:	5b                   	pop    %ebx
  80160e:	5d                   	pop    %ebp
  80160f:	c3                   	ret    

00801610 <devfile_flush>:
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801616:	8b 45 08             	mov    0x8(%ebp),%eax
  801619:	8b 40 0c             	mov    0xc(%eax),%eax
  80161c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801621:	ba 00 00 00 00       	mov    $0x0,%edx
  801626:	b8 06 00 00 00       	mov    $0x6,%eax
  80162b:	e8 1f ff ff ff       	call   80154f <fsipc>
}
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <devfile_read>:
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	56                   	push   %esi
  801636:	53                   	push   %ebx
  801637:	83 ec 10             	sub    $0x10,%esp
  80163a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80163d:	8b 45 08             	mov    0x8(%ebp),%eax
  801640:	8b 40 0c             	mov    0xc(%eax),%eax
  801643:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801648:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80164e:	ba 00 00 00 00       	mov    $0x0,%edx
  801653:	b8 03 00 00 00       	mov    $0x3,%eax
  801658:	e8 f2 fe ff ff       	call   80154f <fsipc>
  80165d:	89 c3                	mov    %eax,%ebx
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 6a                	js     8016cd <devfile_read+0x9b>
	assert(r <= n);
  801663:	39 c6                	cmp    %eax,%esi
  801665:	73 24                	jae    80168b <devfile_read+0x59>
  801667:	c7 44 24 0c 06 25 80 	movl   $0x802506,0xc(%esp)
  80166e:	00 
  80166f:	c7 44 24 08 0d 25 80 	movl   $0x80250d,0x8(%esp)
  801676:	00 
  801677:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80167e:	00 
  80167f:	c7 04 24 22 25 80 00 	movl   $0x802522,(%esp)
  801686:	e8 3b 06 00 00       	call   801cc6 <_panic>
	assert(r <= PGSIZE);
  80168b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801690:	7e 24                	jle    8016b6 <devfile_read+0x84>
  801692:	c7 44 24 0c 2d 25 80 	movl   $0x80252d,0xc(%esp)
  801699:	00 
  80169a:	c7 44 24 08 0d 25 80 	movl   $0x80250d,0x8(%esp)
  8016a1:	00 
  8016a2:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  8016a9:	00 
  8016aa:	c7 04 24 22 25 80 00 	movl   $0x802522,(%esp)
  8016b1:	e8 10 06 00 00       	call   801cc6 <_panic>
	memmove(buf, &fsipcbuf, r);
  8016b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016ba:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016c1:	00 
  8016c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c5:	89 04 24             	mov    %eax,(%esp)
  8016c8:	e8 29 f3 ff ff       	call   8009f6 <memmove>
}
  8016cd:	89 d8                	mov    %ebx,%eax
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	5b                   	pop    %ebx
  8016d3:	5e                   	pop    %esi
  8016d4:	5d                   	pop    %ebp
  8016d5:	c3                   	ret    

008016d6 <open>:
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 24             	sub    $0x24,%esp
  8016dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8016e0:	89 1c 24             	mov    %ebx,(%esp)
  8016e3:	e8 b8 f0 ff ff       	call   8007a0 <strlen>
  8016e8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016ed:	7f 60                	jg     80174f <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  8016ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f2:	89 04 24             	mov    %eax,(%esp)
  8016f5:	e8 4d f8 ff ff       	call   800f47 <fd_alloc>
  8016fa:	89 c2                	mov    %eax,%edx
  8016fc:	85 d2                	test   %edx,%edx
  8016fe:	78 54                	js     801754 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801700:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801704:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80170b:	e8 eb f0 ff ff       	call   8007fb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801710:	8b 45 0c             	mov    0xc(%ebp),%eax
  801713:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801718:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80171b:	b8 01 00 00 00       	mov    $0x1,%eax
  801720:	e8 2a fe ff ff       	call   80154f <fsipc>
  801725:	89 c3                	mov    %eax,%ebx
  801727:	85 c0                	test   %eax,%eax
  801729:	79 17                	jns    801742 <open+0x6c>
		fd_close(fd, 0);
  80172b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801732:	00 
  801733:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801736:	89 04 24             	mov    %eax,(%esp)
  801739:	e8 44 f9 ff ff       	call   801082 <fd_close>
		return r;
  80173e:	89 d8                	mov    %ebx,%eax
  801740:	eb 12                	jmp    801754 <open+0x7e>
	return fd2num(fd);
  801742:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801745:	89 04 24             	mov    %eax,(%esp)
  801748:	e8 d3 f7 ff ff       	call   800f20 <fd2num>
  80174d:	eb 05                	jmp    801754 <open+0x7e>
		return -E_BAD_PATH;
  80174f:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801754:	83 c4 24             	add    $0x24,%esp
  801757:	5b                   	pop    %ebx
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    
  80175a:	66 90                	xchg   %ax,%ax
  80175c:	66 90                	xchg   %ax,%ax
  80175e:	66 90                	xchg   %ax,%ax

00801760 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	56                   	push   %esi
  801764:	53                   	push   %ebx
  801765:	83 ec 10             	sub    $0x10,%esp
  801768:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80176b:	8b 45 08             	mov    0x8(%ebp),%eax
  80176e:	89 04 24             	mov    %eax,(%esp)
  801771:	e8 ba f7 ff ff       	call   800f30 <fd2data>
  801776:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801778:	c7 44 24 04 39 25 80 	movl   $0x802539,0x4(%esp)
  80177f:	00 
  801780:	89 1c 24             	mov    %ebx,(%esp)
  801783:	e8 73 f0 ff ff       	call   8007fb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801788:	8b 46 04             	mov    0x4(%esi),%eax
  80178b:	2b 06                	sub    (%esi),%eax
  80178d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801793:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80179a:	00 00 00 
	stat->st_dev = &devpipe;
  80179d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8017a4:	30 80 00 
	return 0;
}
  8017a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ac:	83 c4 10             	add    $0x10,%esp
  8017af:	5b                   	pop    %ebx
  8017b0:	5e                   	pop    %esi
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    

008017b3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	53                   	push   %ebx
  8017b7:	83 ec 14             	sub    $0x14,%esp
  8017ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c8:	e8 83 f5 ff ff       	call   800d50 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017cd:	89 1c 24             	mov    %ebx,(%esp)
  8017d0:	e8 5b f7 ff ff       	call   800f30 <fd2data>
  8017d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e0:	e8 6b f5 ff ff       	call   800d50 <sys_page_unmap>
}
  8017e5:	83 c4 14             	add    $0x14,%esp
  8017e8:	5b                   	pop    %ebx
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    

008017eb <_pipeisclosed>:
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	57                   	push   %edi
  8017ef:	56                   	push   %esi
  8017f0:	53                   	push   %ebx
  8017f1:	83 ec 2c             	sub    $0x2c,%esp
  8017f4:	89 c6                	mov    %eax,%esi
  8017f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  8017f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8017fe:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801801:	89 34 24             	mov    %esi,(%esp)
  801804:	e8 ff 05 00 00       	call   801e08 <pageref>
  801809:	89 c7                	mov    %eax,%edi
  80180b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80180e:	89 04 24             	mov    %eax,(%esp)
  801811:	e8 f2 05 00 00       	call   801e08 <pageref>
  801816:	39 c7                	cmp    %eax,%edi
  801818:	0f 94 c2             	sete   %dl
  80181b:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80181e:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801824:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801827:	39 fb                	cmp    %edi,%ebx
  801829:	74 21                	je     80184c <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  80182b:	84 d2                	test   %dl,%dl
  80182d:	74 ca                	je     8017f9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80182f:	8b 51 58             	mov    0x58(%ecx),%edx
  801832:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801836:	89 54 24 08          	mov    %edx,0x8(%esp)
  80183a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80183e:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  801845:	e8 58 e9 ff ff       	call   8001a2 <cprintf>
  80184a:	eb ad                	jmp    8017f9 <_pipeisclosed+0xe>
}
  80184c:	83 c4 2c             	add    $0x2c,%esp
  80184f:	5b                   	pop    %ebx
  801850:	5e                   	pop    %esi
  801851:	5f                   	pop    %edi
  801852:	5d                   	pop    %ebp
  801853:	c3                   	ret    

00801854 <devpipe_write>:
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	57                   	push   %edi
  801858:	56                   	push   %esi
  801859:	53                   	push   %ebx
  80185a:	83 ec 1c             	sub    $0x1c,%esp
  80185d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801860:	89 34 24             	mov    %esi,(%esp)
  801863:	e8 c8 f6 ff ff       	call   800f30 <fd2data>
	for (i = 0; i < n; i++) {
  801868:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80186c:	74 61                	je     8018cf <devpipe_write+0x7b>
  80186e:	89 c3                	mov    %eax,%ebx
  801870:	bf 00 00 00 00       	mov    $0x0,%edi
  801875:	eb 4a                	jmp    8018c1 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  801877:	89 da                	mov    %ebx,%edx
  801879:	89 f0                	mov    %esi,%eax
  80187b:	e8 6b ff ff ff       	call   8017eb <_pipeisclosed>
  801880:	85 c0                	test   %eax,%eax
  801882:	75 54                	jne    8018d8 <devpipe_write+0x84>
			sys_yield();
  801884:	e8 01 f4 ff ff       	call   800c8a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801889:	8b 43 04             	mov    0x4(%ebx),%eax
  80188c:	8b 0b                	mov    (%ebx),%ecx
  80188e:	8d 51 20             	lea    0x20(%ecx),%edx
  801891:	39 d0                	cmp    %edx,%eax
  801893:	73 e2                	jae    801877 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801895:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801898:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80189c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80189f:	99                   	cltd   
  8018a0:	c1 ea 1b             	shr    $0x1b,%edx
  8018a3:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8018a6:	83 e1 1f             	and    $0x1f,%ecx
  8018a9:	29 d1                	sub    %edx,%ecx
  8018ab:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8018af:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8018b3:	83 c0 01             	add    $0x1,%eax
  8018b6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8018b9:	83 c7 01             	add    $0x1,%edi
  8018bc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018bf:	74 13                	je     8018d4 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018c1:	8b 43 04             	mov    0x4(%ebx),%eax
  8018c4:	8b 0b                	mov    (%ebx),%ecx
  8018c6:	8d 51 20             	lea    0x20(%ecx),%edx
  8018c9:	39 d0                	cmp    %edx,%eax
  8018cb:	73 aa                	jae    801877 <devpipe_write+0x23>
  8018cd:	eb c6                	jmp    801895 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  8018cf:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  8018d4:	89 f8                	mov    %edi,%eax
  8018d6:	eb 05                	jmp    8018dd <devpipe_write+0x89>
				return 0;
  8018d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018dd:	83 c4 1c             	add    $0x1c,%esp
  8018e0:	5b                   	pop    %ebx
  8018e1:	5e                   	pop    %esi
  8018e2:	5f                   	pop    %edi
  8018e3:	5d                   	pop    %ebp
  8018e4:	c3                   	ret    

008018e5 <devpipe_read>:
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	57                   	push   %edi
  8018e9:	56                   	push   %esi
  8018ea:	53                   	push   %ebx
  8018eb:	83 ec 1c             	sub    $0x1c,%esp
  8018ee:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8018f1:	89 3c 24             	mov    %edi,(%esp)
  8018f4:	e8 37 f6 ff ff       	call   800f30 <fd2data>
	for (i = 0; i < n; i++) {
  8018f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018fd:	74 54                	je     801953 <devpipe_read+0x6e>
  8018ff:	89 c3                	mov    %eax,%ebx
  801901:	be 00 00 00 00       	mov    $0x0,%esi
  801906:	eb 3e                	jmp    801946 <devpipe_read+0x61>
				return i;
  801908:	89 f0                	mov    %esi,%eax
  80190a:	eb 55                	jmp    801961 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  80190c:	89 da                	mov    %ebx,%edx
  80190e:	89 f8                	mov    %edi,%eax
  801910:	e8 d6 fe ff ff       	call   8017eb <_pipeisclosed>
  801915:	85 c0                	test   %eax,%eax
  801917:	75 43                	jne    80195c <devpipe_read+0x77>
			sys_yield();
  801919:	e8 6c f3 ff ff       	call   800c8a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80191e:	8b 03                	mov    (%ebx),%eax
  801920:	3b 43 04             	cmp    0x4(%ebx),%eax
  801923:	74 e7                	je     80190c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801925:	99                   	cltd   
  801926:	c1 ea 1b             	shr    $0x1b,%edx
  801929:	01 d0                	add    %edx,%eax
  80192b:	83 e0 1f             	and    $0x1f,%eax
  80192e:	29 d0                	sub    %edx,%eax
  801930:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801935:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801938:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80193b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80193e:	83 c6 01             	add    $0x1,%esi
  801941:	3b 75 10             	cmp    0x10(%ebp),%esi
  801944:	74 12                	je     801958 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  801946:	8b 03                	mov    (%ebx),%eax
  801948:	3b 43 04             	cmp    0x4(%ebx),%eax
  80194b:	75 d8                	jne    801925 <devpipe_read+0x40>
			if (i > 0)
  80194d:	85 f6                	test   %esi,%esi
  80194f:	75 b7                	jne    801908 <devpipe_read+0x23>
  801951:	eb b9                	jmp    80190c <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  801953:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  801958:	89 f0                	mov    %esi,%eax
  80195a:	eb 05                	jmp    801961 <devpipe_read+0x7c>
				return 0;
  80195c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801961:	83 c4 1c             	add    $0x1c,%esp
  801964:	5b                   	pop    %ebx
  801965:	5e                   	pop    %esi
  801966:	5f                   	pop    %edi
  801967:	5d                   	pop    %ebp
  801968:	c3                   	ret    

00801969 <pipe>:
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	56                   	push   %esi
  80196d:	53                   	push   %ebx
  80196e:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801971:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801974:	89 04 24             	mov    %eax,(%esp)
  801977:	e8 cb f5 ff ff       	call   800f47 <fd_alloc>
  80197c:	89 c2                	mov    %eax,%edx
  80197e:	85 d2                	test   %edx,%edx
  801980:	0f 88 4d 01 00 00    	js     801ad3 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801986:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80198d:	00 
  80198e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801991:	89 44 24 04          	mov    %eax,0x4(%esp)
  801995:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199c:	e8 08 f3 ff ff       	call   800ca9 <sys_page_alloc>
  8019a1:	89 c2                	mov    %eax,%edx
  8019a3:	85 d2                	test   %edx,%edx
  8019a5:	0f 88 28 01 00 00    	js     801ad3 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  8019ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019ae:	89 04 24             	mov    %eax,(%esp)
  8019b1:	e8 91 f5 ff ff       	call   800f47 <fd_alloc>
  8019b6:	89 c3                	mov    %eax,%ebx
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	0f 88 fe 00 00 00    	js     801abe <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019c7:	00 
  8019c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d6:	e8 ce f2 ff ff       	call   800ca9 <sys_page_alloc>
  8019db:	89 c3                	mov    %eax,%ebx
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	0f 88 d9 00 00 00    	js     801abe <pipe+0x155>
	va = fd2data(fd0);
  8019e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e8:	89 04 24             	mov    %eax,(%esp)
  8019eb:	e8 40 f5 ff ff       	call   800f30 <fd2data>
  8019f0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019f9:	00 
  8019fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a05:	e8 9f f2 ff ff       	call   800ca9 <sys_page_alloc>
  801a0a:	89 c3                	mov    %eax,%ebx
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	0f 88 97 00 00 00    	js     801aab <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a17:	89 04 24             	mov    %eax,(%esp)
  801a1a:	e8 11 f5 ff ff       	call   800f30 <fd2data>
  801a1f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801a26:	00 
  801a27:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a32:	00 
  801a33:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a3e:	e8 ba f2 ff ff       	call   800cfd <sys_page_map>
  801a43:	89 c3                	mov    %eax,%ebx
  801a45:	85 c0                	test   %eax,%eax
  801a47:	78 52                	js     801a9b <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801a49:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a52:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a57:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801a5e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a67:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a6c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a76:	89 04 24             	mov    %eax,(%esp)
  801a79:	e8 a2 f4 ff ff       	call   800f20 <fd2num>
  801a7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a81:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a86:	89 04 24             	mov    %eax,(%esp)
  801a89:	e8 92 f4 ff ff       	call   800f20 <fd2num>
  801a8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a91:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a94:	b8 00 00 00 00       	mov    $0x0,%eax
  801a99:	eb 38                	jmp    801ad3 <pipe+0x16a>
	sys_page_unmap(0, va);
  801a9b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aa6:	e8 a5 f2 ff ff       	call   800d50 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aae:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ab9:	e8 92 f2 ff ff       	call   800d50 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801acc:	e8 7f f2 ff ff       	call   800d50 <sys_page_unmap>
  801ad1:	89 d8                	mov    %ebx,%eax
}
  801ad3:	83 c4 30             	add    $0x30,%esp
  801ad6:	5b                   	pop    %ebx
  801ad7:	5e                   	pop    %esi
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <pipeisclosed>:
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ae0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aea:	89 04 24             	mov    %eax,(%esp)
  801aed:	e8 c9 f4 ff ff       	call   800fbb <fd_lookup>
  801af2:	89 c2                	mov    %eax,%edx
  801af4:	85 d2                	test   %edx,%edx
  801af6:	78 15                	js     801b0d <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afb:	89 04 24             	mov    %eax,(%esp)
  801afe:	e8 2d f4 ff ff       	call   800f30 <fd2data>
	return _pipeisclosed(fd, p);
  801b03:	89 c2                	mov    %eax,%edx
  801b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b08:	e8 de fc ff ff       	call   8017eb <_pipeisclosed>
}
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    
  801b0f:	90                   	nop

00801b10 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b13:	b8 00 00 00 00       	mov    $0x0,%eax
  801b18:	5d                   	pop    %ebp
  801b19:	c3                   	ret    

00801b1a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801b20:	c7 44 24 04 58 25 80 	movl   $0x802558,0x4(%esp)
  801b27:	00 
  801b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2b:	89 04 24             	mov    %eax,(%esp)
  801b2e:	e8 c8 ec ff ff       	call   8007fb <strcpy>
	return 0;
}
  801b33:	b8 00 00 00 00       	mov    $0x0,%eax
  801b38:	c9                   	leave  
  801b39:	c3                   	ret    

00801b3a <devcons_write>:
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	57                   	push   %edi
  801b3e:	56                   	push   %esi
  801b3f:	53                   	push   %ebx
  801b40:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801b46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b4a:	74 4a                	je     801b96 <devcons_write+0x5c>
  801b4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b51:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b56:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  801b5c:	8b 75 10             	mov    0x10(%ebp),%esi
  801b5f:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  801b61:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801b64:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b69:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b6c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801b70:	03 45 0c             	add    0xc(%ebp),%eax
  801b73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b77:	89 3c 24             	mov    %edi,(%esp)
  801b7a:	e8 77 ee ff ff       	call   8009f6 <memmove>
		sys_cputs(buf, m);
  801b7f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b83:	89 3c 24             	mov    %edi,(%esp)
  801b86:	e8 51 f0 ff ff       	call   800bdc <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801b8b:	01 f3                	add    %esi,%ebx
  801b8d:	89 d8                	mov    %ebx,%eax
  801b8f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b92:	72 c8                	jb     801b5c <devcons_write+0x22>
  801b94:	eb 05                	jmp    801b9b <devcons_write+0x61>
  801b96:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  801b9b:	89 d8                	mov    %ebx,%eax
  801b9d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801ba3:	5b                   	pop    %ebx
  801ba4:	5e                   	pop    %esi
  801ba5:	5f                   	pop    %edi
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    

00801ba8 <devcons_read>:
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801bae:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801bb3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bb7:	75 07                	jne    801bc0 <devcons_read+0x18>
  801bb9:	eb 28                	jmp    801be3 <devcons_read+0x3b>
		sys_yield();
  801bbb:	e8 ca f0 ff ff       	call   800c8a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801bc0:	e8 35 f0 ff ff       	call   800bfa <sys_cgetc>
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	74 f2                	je     801bbb <devcons_read+0x13>
	if (c < 0)
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	78 16                	js     801be3 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  801bcd:	83 f8 04             	cmp    $0x4,%eax
  801bd0:	74 0c                	je     801bde <devcons_read+0x36>
	*(char*)vbuf = c;
  801bd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bd5:	88 02                	mov    %al,(%edx)
	return 1;
  801bd7:	b8 01 00 00 00       	mov    $0x1,%eax
  801bdc:	eb 05                	jmp    801be3 <devcons_read+0x3b>
		return 0;
  801bde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801be3:	c9                   	leave  
  801be4:	c3                   	ret    

00801be5 <cputchar>:
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801beb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bee:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801bf1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bf8:	00 
  801bf9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bfc:	89 04 24             	mov    %eax,(%esp)
  801bff:	e8 d8 ef ff ff       	call   800bdc <sys_cputs>
}
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    

00801c06 <getchar>:
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801c0c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801c13:	00 
  801c14:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c22:	e8 3f f6 ff ff       	call   801266 <read>
	if (r < 0)
  801c27:	85 c0                	test   %eax,%eax
  801c29:	78 0f                	js     801c3a <getchar+0x34>
	if (r < 1)
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	7e 06                	jle    801c35 <getchar+0x2f>
	return c;
  801c2f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c33:	eb 05                	jmp    801c3a <getchar+0x34>
		return -E_EOF;
  801c35:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801c3a:	c9                   	leave  
  801c3b:	c3                   	ret    

00801c3c <iscons>:
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c49:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4c:	89 04 24             	mov    %eax,(%esp)
  801c4f:	e8 67 f3 ff ff       	call   800fbb <fd_lookup>
  801c54:	85 c0                	test   %eax,%eax
  801c56:	78 11                	js     801c69 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c61:	39 10                	cmp    %edx,(%eax)
  801c63:	0f 94 c0             	sete   %al
  801c66:	0f b6 c0             	movzbl %al,%eax
}
  801c69:	c9                   	leave  
  801c6a:	c3                   	ret    

00801c6b <opencons>:
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801c71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c74:	89 04 24             	mov    %eax,(%esp)
  801c77:	e8 cb f2 ff ff       	call   800f47 <fd_alloc>
		return r;
  801c7c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	78 40                	js     801cc2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c82:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c89:	00 
  801c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c98:	e8 0c f0 ff ff       	call   800ca9 <sys_page_alloc>
		return r;
  801c9d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	78 1f                	js     801cc2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801ca3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cac:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cb8:	89 04 24             	mov    %eax,(%esp)
  801cbb:	e8 60 f2 ff ff       	call   800f20 <fd2num>
  801cc0:	89 c2                	mov    %eax,%edx
}
  801cc2:	89 d0                	mov    %edx,%eax
  801cc4:	c9                   	leave  
  801cc5:	c3                   	ret    

00801cc6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	56                   	push   %esi
  801cca:	53                   	push   %ebx
  801ccb:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801cce:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801cd1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801cd7:	e8 8f ef ff ff       	call   800c6b <sys_getenvid>
  801cdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cdf:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  801ce6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cea:	89 74 24 08          	mov    %esi,0x8(%esp)
  801cee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf2:	c7 04 24 64 25 80 00 	movl   $0x802564,(%esp)
  801cf9:	e8 a4 e4 ff ff       	call   8001a2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801cfe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d02:	8b 45 10             	mov    0x10(%ebp),%eax
  801d05:	89 04 24             	mov    %eax,(%esp)
  801d08:	e8 34 e4 ff ff       	call   800141 <vcprintf>
	cprintf("\n");
  801d0d:	c7 04 24 51 25 80 00 	movl   $0x802551,(%esp)
  801d14:	e8 89 e4 ff ff       	call   8001a2 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d19:	cc                   	int3   
  801d1a:	eb fd                	jmp    801d19 <_panic+0x53>

00801d1c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	56                   	push   %esi
  801d20:	53                   	push   %ebx
  801d21:	83 ec 10             	sub    $0x10,%esp
  801d24:	8b 75 08             	mov    0x8(%ebp),%esi
  801d27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  801d2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2d:	89 04 24             	mov    %eax,(%esp)
  801d30:	e8 8a f1 ff ff       	call   800ebf <sys_ipc_recv>
	if(from_env_store)
  801d35:	85 f6                	test   %esi,%esi
  801d37:	74 14                	je     801d4d <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  801d39:	ba 00 00 00 00       	mov    $0x0,%edx
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 09                	js     801d4b <ipc_recv+0x2f>
  801d42:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d48:	8b 52 74             	mov    0x74(%edx),%edx
  801d4b:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  801d4d:	85 db                	test   %ebx,%ebx
  801d4f:	74 14                	je     801d65 <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  801d51:	ba 00 00 00 00       	mov    $0x0,%edx
  801d56:	85 c0                	test   %eax,%eax
  801d58:	78 09                	js     801d63 <ipc_recv+0x47>
  801d5a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d60:	8b 52 78             	mov    0x78(%edx),%edx
  801d63:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  801d65:	85 c0                	test   %eax,%eax
  801d67:	78 08                	js     801d71 <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  801d69:	a1 04 40 80 00       	mov    0x804004,%eax
  801d6e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	5b                   	pop    %ebx
  801d75:	5e                   	pop    %esi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    

00801d78 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	57                   	push   %edi
  801d7c:	56                   	push   %esi
  801d7d:	53                   	push   %ebx
  801d7e:	83 ec 1c             	sub    $0x1c,%esp
  801d81:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d84:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  801d87:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801d8c:	eb 0c                	jmp    801d9a <ipc_send+0x22>
		failed_cnt++;
  801d8e:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  801d91:	84 db                	test   %bl,%bl
  801d93:	75 05                	jne    801d9a <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  801d95:	e8 f0 ee ff ff       	call   800c8a <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801d9a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801da1:	8b 45 10             	mov    0x10(%ebp),%eax
  801da4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801da8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dac:	89 3c 24             	mov    %edi,(%esp)
  801daf:	e8 e8 f0 ff ff       	call   800e9c <sys_ipc_try_send>
  801db4:	85 c0                	test   %eax,%eax
  801db6:	78 d6                	js     801d8e <ipc_send+0x16>
	}
}
  801db8:	83 c4 1c             	add    $0x1c,%esp
  801dbb:	5b                   	pop    %ebx
  801dbc:	5e                   	pop    %esi
  801dbd:	5f                   	pop    %edi
  801dbe:	5d                   	pop    %ebp
  801dbf:	c3                   	ret    

00801dc0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801dc6:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801dcb:	39 c8                	cmp    %ecx,%eax
  801dcd:	74 17                	je     801de6 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  801dcf:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801dd4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801dd7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ddd:	8b 52 50             	mov    0x50(%edx),%edx
  801de0:	39 ca                	cmp    %ecx,%edx
  801de2:	75 14                	jne    801df8 <ipc_find_env+0x38>
  801de4:	eb 05                	jmp    801deb <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  801de6:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  801deb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801dee:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801df3:	8b 40 40             	mov    0x40(%eax),%eax
  801df6:	eb 0e                	jmp    801e06 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  801df8:	83 c0 01             	add    $0x1,%eax
  801dfb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e00:	75 d2                	jne    801dd4 <ipc_find_env+0x14>
	return 0;
  801e02:	66 b8 00 00          	mov    $0x0,%ax
}
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    

00801e08 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
  801e0b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e0e:	89 d0                	mov    %edx,%eax
  801e10:	c1 e8 16             	shr    $0x16,%eax
  801e13:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e1a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801e1f:	f6 c1 01             	test   $0x1,%cl
  801e22:	74 1d                	je     801e41 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801e24:	c1 ea 0c             	shr    $0xc,%edx
  801e27:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e2e:	f6 c2 01             	test   $0x1,%dl
  801e31:	74 0e                	je     801e41 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e33:	c1 ea 0c             	shr    $0xc,%edx
  801e36:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e3d:	ef 
  801e3e:	0f b7 c0             	movzwl %ax,%eax
}
  801e41:	5d                   	pop    %ebp
  801e42:	c3                   	ret    
  801e43:	66 90                	xchg   %ax,%ax
  801e45:	66 90                	xchg   %ax,%ax
  801e47:	66 90                	xchg   %ax,%ax
  801e49:	66 90                	xchg   %ax,%ax
  801e4b:	66 90                	xchg   %ax,%ax
  801e4d:	66 90                	xchg   %ax,%ax
  801e4f:	90                   	nop

00801e50 <__udivdi3>:
  801e50:	55                   	push   %ebp
  801e51:	57                   	push   %edi
  801e52:	56                   	push   %esi
  801e53:	83 ec 0c             	sub    $0xc,%esp
  801e56:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e5a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801e5e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801e62:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e66:	85 c0                	test   %eax,%eax
  801e68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e6c:	89 ea                	mov    %ebp,%edx
  801e6e:	89 0c 24             	mov    %ecx,(%esp)
  801e71:	75 2d                	jne    801ea0 <__udivdi3+0x50>
  801e73:	39 e9                	cmp    %ebp,%ecx
  801e75:	77 61                	ja     801ed8 <__udivdi3+0x88>
  801e77:	85 c9                	test   %ecx,%ecx
  801e79:	89 ce                	mov    %ecx,%esi
  801e7b:	75 0b                	jne    801e88 <__udivdi3+0x38>
  801e7d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e82:	31 d2                	xor    %edx,%edx
  801e84:	f7 f1                	div    %ecx
  801e86:	89 c6                	mov    %eax,%esi
  801e88:	31 d2                	xor    %edx,%edx
  801e8a:	89 e8                	mov    %ebp,%eax
  801e8c:	f7 f6                	div    %esi
  801e8e:	89 c5                	mov    %eax,%ebp
  801e90:	89 f8                	mov    %edi,%eax
  801e92:	f7 f6                	div    %esi
  801e94:	89 ea                	mov    %ebp,%edx
  801e96:	83 c4 0c             	add    $0xc,%esp
  801e99:	5e                   	pop    %esi
  801e9a:	5f                   	pop    %edi
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    
  801e9d:	8d 76 00             	lea    0x0(%esi),%esi
  801ea0:	39 e8                	cmp    %ebp,%eax
  801ea2:	77 24                	ja     801ec8 <__udivdi3+0x78>
  801ea4:	0f bd e8             	bsr    %eax,%ebp
  801ea7:	83 f5 1f             	xor    $0x1f,%ebp
  801eaa:	75 3c                	jne    801ee8 <__udivdi3+0x98>
  801eac:	8b 74 24 04          	mov    0x4(%esp),%esi
  801eb0:	39 34 24             	cmp    %esi,(%esp)
  801eb3:	0f 86 9f 00 00 00    	jbe    801f58 <__udivdi3+0x108>
  801eb9:	39 d0                	cmp    %edx,%eax
  801ebb:	0f 82 97 00 00 00    	jb     801f58 <__udivdi3+0x108>
  801ec1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ec8:	31 d2                	xor    %edx,%edx
  801eca:	31 c0                	xor    %eax,%eax
  801ecc:	83 c4 0c             	add    $0xc,%esp
  801ecf:	5e                   	pop    %esi
  801ed0:	5f                   	pop    %edi
  801ed1:	5d                   	pop    %ebp
  801ed2:	c3                   	ret    
  801ed3:	90                   	nop
  801ed4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ed8:	89 f8                	mov    %edi,%eax
  801eda:	f7 f1                	div    %ecx
  801edc:	31 d2                	xor    %edx,%edx
  801ede:	83 c4 0c             	add    $0xc,%esp
  801ee1:	5e                   	pop    %esi
  801ee2:	5f                   	pop    %edi
  801ee3:	5d                   	pop    %ebp
  801ee4:	c3                   	ret    
  801ee5:	8d 76 00             	lea    0x0(%esi),%esi
  801ee8:	89 e9                	mov    %ebp,%ecx
  801eea:	8b 3c 24             	mov    (%esp),%edi
  801eed:	d3 e0                	shl    %cl,%eax
  801eef:	89 c6                	mov    %eax,%esi
  801ef1:	b8 20 00 00 00       	mov    $0x20,%eax
  801ef6:	29 e8                	sub    %ebp,%eax
  801ef8:	89 c1                	mov    %eax,%ecx
  801efa:	d3 ef                	shr    %cl,%edi
  801efc:	89 e9                	mov    %ebp,%ecx
  801efe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801f02:	8b 3c 24             	mov    (%esp),%edi
  801f05:	09 74 24 08          	or     %esi,0x8(%esp)
  801f09:	89 d6                	mov    %edx,%esi
  801f0b:	d3 e7                	shl    %cl,%edi
  801f0d:	89 c1                	mov    %eax,%ecx
  801f0f:	89 3c 24             	mov    %edi,(%esp)
  801f12:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f16:	d3 ee                	shr    %cl,%esi
  801f18:	89 e9                	mov    %ebp,%ecx
  801f1a:	d3 e2                	shl    %cl,%edx
  801f1c:	89 c1                	mov    %eax,%ecx
  801f1e:	d3 ef                	shr    %cl,%edi
  801f20:	09 d7                	or     %edx,%edi
  801f22:	89 f2                	mov    %esi,%edx
  801f24:	89 f8                	mov    %edi,%eax
  801f26:	f7 74 24 08          	divl   0x8(%esp)
  801f2a:	89 d6                	mov    %edx,%esi
  801f2c:	89 c7                	mov    %eax,%edi
  801f2e:	f7 24 24             	mull   (%esp)
  801f31:	39 d6                	cmp    %edx,%esi
  801f33:	89 14 24             	mov    %edx,(%esp)
  801f36:	72 30                	jb     801f68 <__udivdi3+0x118>
  801f38:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f3c:	89 e9                	mov    %ebp,%ecx
  801f3e:	d3 e2                	shl    %cl,%edx
  801f40:	39 c2                	cmp    %eax,%edx
  801f42:	73 05                	jae    801f49 <__udivdi3+0xf9>
  801f44:	3b 34 24             	cmp    (%esp),%esi
  801f47:	74 1f                	je     801f68 <__udivdi3+0x118>
  801f49:	89 f8                	mov    %edi,%eax
  801f4b:	31 d2                	xor    %edx,%edx
  801f4d:	e9 7a ff ff ff       	jmp    801ecc <__udivdi3+0x7c>
  801f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f58:	31 d2                	xor    %edx,%edx
  801f5a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f5f:	e9 68 ff ff ff       	jmp    801ecc <__udivdi3+0x7c>
  801f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f68:	8d 47 ff             	lea    -0x1(%edi),%eax
  801f6b:	31 d2                	xor    %edx,%edx
  801f6d:	83 c4 0c             	add    $0xc,%esp
  801f70:	5e                   	pop    %esi
  801f71:	5f                   	pop    %edi
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    
  801f74:	66 90                	xchg   %ax,%ax
  801f76:	66 90                	xchg   %ax,%ax
  801f78:	66 90                	xchg   %ax,%ax
  801f7a:	66 90                	xchg   %ax,%ax
  801f7c:	66 90                	xchg   %ax,%ax
  801f7e:	66 90                	xchg   %ax,%ax

00801f80 <__umoddi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	83 ec 14             	sub    $0x14,%esp
  801f86:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f8a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f8e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801f92:	89 c7                	mov    %eax,%edi
  801f94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f98:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f9c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801fa0:	89 34 24             	mov    %esi,(%esp)
  801fa3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	89 c2                	mov    %eax,%edx
  801fab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801faf:	75 17                	jne    801fc8 <__umoddi3+0x48>
  801fb1:	39 fe                	cmp    %edi,%esi
  801fb3:	76 4b                	jbe    802000 <__umoddi3+0x80>
  801fb5:	89 c8                	mov    %ecx,%eax
  801fb7:	89 fa                	mov    %edi,%edx
  801fb9:	f7 f6                	div    %esi
  801fbb:	89 d0                	mov    %edx,%eax
  801fbd:	31 d2                	xor    %edx,%edx
  801fbf:	83 c4 14             	add    $0x14,%esp
  801fc2:	5e                   	pop    %esi
  801fc3:	5f                   	pop    %edi
  801fc4:	5d                   	pop    %ebp
  801fc5:	c3                   	ret    
  801fc6:	66 90                	xchg   %ax,%ax
  801fc8:	39 f8                	cmp    %edi,%eax
  801fca:	77 54                	ja     802020 <__umoddi3+0xa0>
  801fcc:	0f bd e8             	bsr    %eax,%ebp
  801fcf:	83 f5 1f             	xor    $0x1f,%ebp
  801fd2:	75 5c                	jne    802030 <__umoddi3+0xb0>
  801fd4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801fd8:	39 3c 24             	cmp    %edi,(%esp)
  801fdb:	0f 87 e7 00 00 00    	ja     8020c8 <__umoddi3+0x148>
  801fe1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801fe5:	29 f1                	sub    %esi,%ecx
  801fe7:	19 c7                	sbb    %eax,%edi
  801fe9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ff1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ff5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ff9:	83 c4 14             	add    $0x14,%esp
  801ffc:	5e                   	pop    %esi
  801ffd:	5f                   	pop    %edi
  801ffe:	5d                   	pop    %ebp
  801fff:	c3                   	ret    
  802000:	85 f6                	test   %esi,%esi
  802002:	89 f5                	mov    %esi,%ebp
  802004:	75 0b                	jne    802011 <__umoddi3+0x91>
  802006:	b8 01 00 00 00       	mov    $0x1,%eax
  80200b:	31 d2                	xor    %edx,%edx
  80200d:	f7 f6                	div    %esi
  80200f:	89 c5                	mov    %eax,%ebp
  802011:	8b 44 24 04          	mov    0x4(%esp),%eax
  802015:	31 d2                	xor    %edx,%edx
  802017:	f7 f5                	div    %ebp
  802019:	89 c8                	mov    %ecx,%eax
  80201b:	f7 f5                	div    %ebp
  80201d:	eb 9c                	jmp    801fbb <__umoddi3+0x3b>
  80201f:	90                   	nop
  802020:	89 c8                	mov    %ecx,%eax
  802022:	89 fa                	mov    %edi,%edx
  802024:	83 c4 14             	add    $0x14,%esp
  802027:	5e                   	pop    %esi
  802028:	5f                   	pop    %edi
  802029:	5d                   	pop    %ebp
  80202a:	c3                   	ret    
  80202b:	90                   	nop
  80202c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802030:	8b 04 24             	mov    (%esp),%eax
  802033:	be 20 00 00 00       	mov    $0x20,%esi
  802038:	89 e9                	mov    %ebp,%ecx
  80203a:	29 ee                	sub    %ebp,%esi
  80203c:	d3 e2                	shl    %cl,%edx
  80203e:	89 f1                	mov    %esi,%ecx
  802040:	d3 e8                	shr    %cl,%eax
  802042:	89 e9                	mov    %ebp,%ecx
  802044:	89 44 24 04          	mov    %eax,0x4(%esp)
  802048:	8b 04 24             	mov    (%esp),%eax
  80204b:	09 54 24 04          	or     %edx,0x4(%esp)
  80204f:	89 fa                	mov    %edi,%edx
  802051:	d3 e0                	shl    %cl,%eax
  802053:	89 f1                	mov    %esi,%ecx
  802055:	89 44 24 08          	mov    %eax,0x8(%esp)
  802059:	8b 44 24 10          	mov    0x10(%esp),%eax
  80205d:	d3 ea                	shr    %cl,%edx
  80205f:	89 e9                	mov    %ebp,%ecx
  802061:	d3 e7                	shl    %cl,%edi
  802063:	89 f1                	mov    %esi,%ecx
  802065:	d3 e8                	shr    %cl,%eax
  802067:	89 e9                	mov    %ebp,%ecx
  802069:	09 f8                	or     %edi,%eax
  80206b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80206f:	f7 74 24 04          	divl   0x4(%esp)
  802073:	d3 e7                	shl    %cl,%edi
  802075:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802079:	89 d7                	mov    %edx,%edi
  80207b:	f7 64 24 08          	mull   0x8(%esp)
  80207f:	39 d7                	cmp    %edx,%edi
  802081:	89 c1                	mov    %eax,%ecx
  802083:	89 14 24             	mov    %edx,(%esp)
  802086:	72 2c                	jb     8020b4 <__umoddi3+0x134>
  802088:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80208c:	72 22                	jb     8020b0 <__umoddi3+0x130>
  80208e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802092:	29 c8                	sub    %ecx,%eax
  802094:	19 d7                	sbb    %edx,%edi
  802096:	89 e9                	mov    %ebp,%ecx
  802098:	89 fa                	mov    %edi,%edx
  80209a:	d3 e8                	shr    %cl,%eax
  80209c:	89 f1                	mov    %esi,%ecx
  80209e:	d3 e2                	shl    %cl,%edx
  8020a0:	89 e9                	mov    %ebp,%ecx
  8020a2:	d3 ef                	shr    %cl,%edi
  8020a4:	09 d0                	or     %edx,%eax
  8020a6:	89 fa                	mov    %edi,%edx
  8020a8:	83 c4 14             	add    $0x14,%esp
  8020ab:	5e                   	pop    %esi
  8020ac:	5f                   	pop    %edi
  8020ad:	5d                   	pop    %ebp
  8020ae:	c3                   	ret    
  8020af:	90                   	nop
  8020b0:	39 d7                	cmp    %edx,%edi
  8020b2:	75 da                	jne    80208e <__umoddi3+0x10e>
  8020b4:	8b 14 24             	mov    (%esp),%edx
  8020b7:	89 c1                	mov    %eax,%ecx
  8020b9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8020bd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8020c1:	eb cb                	jmp    80208e <__umoddi3+0x10e>
  8020c3:	90                   	nop
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8020cc:	0f 82 0f ff ff ff    	jb     801fe1 <__umoddi3+0x61>
  8020d2:	e9 1a ff ff ff       	jmp    801ff1 <__umoddi3+0x71>
