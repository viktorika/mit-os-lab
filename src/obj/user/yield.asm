
obj/user/yield：     文件格式 elf32-i386


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
  80003a:	a1 04 20 80 00       	mov    0x802004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	89 44 24 04          	mov    %eax,0x4(%esp)
  800046:	c7 04 24 c0 11 80 00 	movl   $0x8011c0,(%esp)
  80004d:	e8 4b 01 00 00       	call   80019d <cprintf>
	for (i = 0; i < 5; i++) {
  800052:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800057:	e8 2e 0c 00 00       	call   800c8a <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005c:	a1 04 20 80 00       	mov    0x802004,%eax
		cprintf("Back in environment %08x, iteration %d.\n",
  800061:	8b 40 48             	mov    0x48(%eax),%eax
  800064:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006c:	c7 04 24 e0 11 80 00 	movl   $0x8011e0,(%esp)
  800073:	e8 25 01 00 00       	call   80019d <cprintf>
	for (i = 0; i < 5; i++) {
  800078:	83 c3 01             	add    $0x1,%ebx
  80007b:	83 fb 05             	cmp    $0x5,%ebx
  80007e:	75 d7                	jne    800057 <umain+0x24>
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800080:	a1 04 20 80 00       	mov    0x802004,%eax
  800085:	8b 40 48             	mov    0x48(%eax),%eax
  800088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008c:	c7 04 24 0c 12 80 00 	movl   $0x80120c,(%esp)
  800093:	e8 05 01 00 00       	call   80019d <cprintf>
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
  8000be:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x30>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  8000ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f3:	e8 21 0b 00 00       	call   800c19 <sys_env_destroy>
}
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 14             	sub    $0x14,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 19                	jne    800132 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800119:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800120:	00 
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	89 04 24             	mov    %eax,(%esp)
  800127:	e8 b0 0a 00 00       	call   800bdc <sys_cputs>
		b->idx = 0;
  80012c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800132:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800136:	83 c4 14             	add    $0x14,%esp
  800139:	5b                   	pop    %ebx
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014c:	00 00 00 
	b.cnt = 0;
  80014f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800159:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800160:	8b 45 08             	mov    0x8(%ebp),%eax
  800163:	89 44 24 08          	mov    %eax,0x8(%esp)
  800167:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800171:	c7 04 24 fa 00 80 00 	movl   $0x8000fa,(%esp)
  800178:	e8 b7 01 00 00       	call   800334 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800183:	89 44 24 04          	mov    %eax,0x4(%esp)
  800187:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018d:	89 04 24             	mov    %eax,(%esp)
  800190:	e8 47 0a 00 00       	call   800bdc <sys_cputs>

	return b.cnt;
}
  800195:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ad:	89 04 24             	mov    %eax,(%esp)
  8001b0:	e8 87 ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    
  8001b7:	66 90                	xchg   %ax,%ax
  8001b9:	66 90                	xchg   %ax,%ax
  8001bb:	66 90                	xchg   %ax,%ax
  8001bd:	66 90                	xchg   %ax,%ax
  8001bf:	90                   	nop

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
  80023c:	e8 df 0c 00 00       	call   800f20 <__udivdi3>
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
  800295:	e8 b6 0d 00 00       	call   801050 <__umoddi3>
  80029a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029e:	0f be 80 35 12 80 00 	movsbl 0x801235(%eax),%eax
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
  8003bc:	ff 24 85 00 13 80 00 	jmp    *0x801300(,%eax,4)
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
  80046a:	83 f8 08             	cmp    $0x8,%eax
  80046d:	7f 0b                	jg     80047a <vprintfmt+0x146>
  80046f:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  800476:	85 d2                	test   %edx,%edx
  800478:	75 20                	jne    80049a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80047a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047e:	c7 44 24 08 4d 12 80 	movl   $0x80124d,0x8(%esp)
  800485:	00 
  800486:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048a:	8b 45 08             	mov    0x8(%ebp),%eax
  80048d:	89 04 24             	mov    %eax,(%esp)
  800490:	e8 77 fe ff ff       	call   80030c <printfmt>
  800495:	e9 c3 fe ff ff       	jmp    80035d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80049a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80049e:	c7 44 24 08 56 12 80 	movl   $0x801256,0x8(%esp)
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
  8004cd:	ba 46 12 80 00       	mov    $0x801246,%edx
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
  800c47:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800c4e:	00 
  800c4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c56:	00 
  800c57:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800c5e:	e8 5b 02 00 00       	call   800ebe <_panic>
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
  800c95:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800cd9:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce8:	00 
  800ce9:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800cf0:	e8 c9 01 00 00       	call   800ebe <_panic>
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
  800d2c:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800d33:	00 
  800d34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3b:	00 
  800d3c:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800d43:	e8 76 01 00 00       	call   800ebe <_panic>
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
  800d7f:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800d86:	00 
  800d87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8e:	00 
  800d8f:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800d96:	e8 23 01 00 00       	call   800ebe <_panic>
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
  800dd2:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800dd9:	00 
  800dda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de1:	00 
  800de2:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800de9:	e8 d0 00 00 00       	call   800ebe <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dee:	83 c4 2c             	add    $0x2c,%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800e17:	7e 28                	jle    800e41 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e24:	00 
  800e25:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800e2c:	00 
  800e2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e34:	00 
  800e35:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800e3c:	e8 7d 00 00 00       	call   800ebe <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e41:	83 c4 2c             	add    $0x2c,%esp
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e4f:	be 00 00 00 00       	mov    $0x0,%esi
  800e54:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e65:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	57                   	push   %edi
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
  800e72:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e75:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e7a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e82:	89 cb                	mov    %ecx,%ebx
  800e84:	89 cf                	mov    %ecx,%edi
  800e86:	89 ce                	mov    %ecx,%esi
  800e88:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	7e 28                	jle    800eb6 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e92:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e99:	00 
  800e9a:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800ea1:	00 
  800ea2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea9:	00 
  800eaa:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800eb1:	e8 08 00 00 00       	call   800ebe <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb6:	83 c4 2c             	add    $0x2c,%esp
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	56                   	push   %esi
  800ec2:	53                   	push   %ebx
  800ec3:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800ec6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ec9:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ecf:	e8 97 fd ff ff       	call   800c6b <sys_getenvid>
  800ed4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed7:	89 54 24 10          	mov    %edx,0x10(%esp)
  800edb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ede:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ee2:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ee6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eea:	c7 04 24 b0 14 80 00 	movl   $0x8014b0,(%esp)
  800ef1:	e8 a7 f2 ff ff       	call   80019d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ef6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800efa:	8b 45 10             	mov    0x10(%ebp),%eax
  800efd:	89 04 24             	mov    %eax,(%esp)
  800f00:	e8 37 f2 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  800f05:	c7 04 24 d4 14 80 00 	movl   $0x8014d4,(%esp)
  800f0c:	e8 8c f2 ff ff       	call   80019d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f11:	cc                   	int3   
  800f12:	eb fd                	jmp    800f11 <_panic+0x53>
  800f14:	66 90                	xchg   %ax,%ax
  800f16:	66 90                	xchg   %ax,%ax
  800f18:	66 90                	xchg   %ax,%ax
  800f1a:	66 90                	xchg   %ax,%ax
  800f1c:	66 90                	xchg   %ax,%ax
  800f1e:	66 90                	xchg   %ax,%ax

00800f20 <__udivdi3>:
  800f20:	55                   	push   %ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	83 ec 0c             	sub    $0xc,%esp
  800f26:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f2a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800f2e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800f32:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f36:	85 c0                	test   %eax,%eax
  800f38:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f3c:	89 ea                	mov    %ebp,%edx
  800f3e:	89 0c 24             	mov    %ecx,(%esp)
  800f41:	75 2d                	jne    800f70 <__udivdi3+0x50>
  800f43:	39 e9                	cmp    %ebp,%ecx
  800f45:	77 61                	ja     800fa8 <__udivdi3+0x88>
  800f47:	85 c9                	test   %ecx,%ecx
  800f49:	89 ce                	mov    %ecx,%esi
  800f4b:	75 0b                	jne    800f58 <__udivdi3+0x38>
  800f4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f52:	31 d2                	xor    %edx,%edx
  800f54:	f7 f1                	div    %ecx
  800f56:	89 c6                	mov    %eax,%esi
  800f58:	31 d2                	xor    %edx,%edx
  800f5a:	89 e8                	mov    %ebp,%eax
  800f5c:	f7 f6                	div    %esi
  800f5e:	89 c5                	mov    %eax,%ebp
  800f60:	89 f8                	mov    %edi,%eax
  800f62:	f7 f6                	div    %esi
  800f64:	89 ea                	mov    %ebp,%edx
  800f66:	83 c4 0c             	add    $0xc,%esp
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    
  800f6d:	8d 76 00             	lea    0x0(%esi),%esi
  800f70:	39 e8                	cmp    %ebp,%eax
  800f72:	77 24                	ja     800f98 <__udivdi3+0x78>
  800f74:	0f bd e8             	bsr    %eax,%ebp
  800f77:	83 f5 1f             	xor    $0x1f,%ebp
  800f7a:	75 3c                	jne    800fb8 <__udivdi3+0x98>
  800f7c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f80:	39 34 24             	cmp    %esi,(%esp)
  800f83:	0f 86 9f 00 00 00    	jbe    801028 <__udivdi3+0x108>
  800f89:	39 d0                	cmp    %edx,%eax
  800f8b:	0f 82 97 00 00 00    	jb     801028 <__udivdi3+0x108>
  800f91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f98:	31 d2                	xor    %edx,%edx
  800f9a:	31 c0                	xor    %eax,%eax
  800f9c:	83 c4 0c             	add    $0xc,%esp
  800f9f:	5e                   	pop    %esi
  800fa0:	5f                   	pop    %edi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    
  800fa3:	90                   	nop
  800fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa8:	89 f8                	mov    %edi,%eax
  800faa:	f7 f1                	div    %ecx
  800fac:	31 d2                	xor    %edx,%edx
  800fae:	83 c4 0c             	add    $0xc,%esp
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    
  800fb5:	8d 76 00             	lea    0x0(%esi),%esi
  800fb8:	89 e9                	mov    %ebp,%ecx
  800fba:	8b 3c 24             	mov    (%esp),%edi
  800fbd:	d3 e0                	shl    %cl,%eax
  800fbf:	89 c6                	mov    %eax,%esi
  800fc1:	b8 20 00 00 00       	mov    $0x20,%eax
  800fc6:	29 e8                	sub    %ebp,%eax
  800fc8:	89 c1                	mov    %eax,%ecx
  800fca:	d3 ef                	shr    %cl,%edi
  800fcc:	89 e9                	mov    %ebp,%ecx
  800fce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fd2:	8b 3c 24             	mov    (%esp),%edi
  800fd5:	09 74 24 08          	or     %esi,0x8(%esp)
  800fd9:	89 d6                	mov    %edx,%esi
  800fdb:	d3 e7                	shl    %cl,%edi
  800fdd:	89 c1                	mov    %eax,%ecx
  800fdf:	89 3c 24             	mov    %edi,(%esp)
  800fe2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fe6:	d3 ee                	shr    %cl,%esi
  800fe8:	89 e9                	mov    %ebp,%ecx
  800fea:	d3 e2                	shl    %cl,%edx
  800fec:	89 c1                	mov    %eax,%ecx
  800fee:	d3 ef                	shr    %cl,%edi
  800ff0:	09 d7                	or     %edx,%edi
  800ff2:	89 f2                	mov    %esi,%edx
  800ff4:	89 f8                	mov    %edi,%eax
  800ff6:	f7 74 24 08          	divl   0x8(%esp)
  800ffa:	89 d6                	mov    %edx,%esi
  800ffc:	89 c7                	mov    %eax,%edi
  800ffe:	f7 24 24             	mull   (%esp)
  801001:	39 d6                	cmp    %edx,%esi
  801003:	89 14 24             	mov    %edx,(%esp)
  801006:	72 30                	jb     801038 <__udivdi3+0x118>
  801008:	8b 54 24 04          	mov    0x4(%esp),%edx
  80100c:	89 e9                	mov    %ebp,%ecx
  80100e:	d3 e2                	shl    %cl,%edx
  801010:	39 c2                	cmp    %eax,%edx
  801012:	73 05                	jae    801019 <__udivdi3+0xf9>
  801014:	3b 34 24             	cmp    (%esp),%esi
  801017:	74 1f                	je     801038 <__udivdi3+0x118>
  801019:	89 f8                	mov    %edi,%eax
  80101b:	31 d2                	xor    %edx,%edx
  80101d:	e9 7a ff ff ff       	jmp    800f9c <__udivdi3+0x7c>
  801022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801028:	31 d2                	xor    %edx,%edx
  80102a:	b8 01 00 00 00       	mov    $0x1,%eax
  80102f:	e9 68 ff ff ff       	jmp    800f9c <__udivdi3+0x7c>
  801034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801038:	8d 47 ff             	lea    -0x1(%edi),%eax
  80103b:	31 d2                	xor    %edx,%edx
  80103d:	83 c4 0c             	add    $0xc,%esp
  801040:	5e                   	pop    %esi
  801041:	5f                   	pop    %edi
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    
  801044:	66 90                	xchg   %ax,%ax
  801046:	66 90                	xchg   %ax,%ax
  801048:	66 90                	xchg   %ax,%ax
  80104a:	66 90                	xchg   %ax,%ax
  80104c:	66 90                	xchg   %ax,%ax
  80104e:	66 90                	xchg   %ax,%ax

00801050 <__umoddi3>:
  801050:	55                   	push   %ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	83 ec 14             	sub    $0x14,%esp
  801056:	8b 44 24 28          	mov    0x28(%esp),%eax
  80105a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80105e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801062:	89 c7                	mov    %eax,%edi
  801064:	89 44 24 04          	mov    %eax,0x4(%esp)
  801068:	8b 44 24 30          	mov    0x30(%esp),%eax
  80106c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801070:	89 34 24             	mov    %esi,(%esp)
  801073:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801077:	85 c0                	test   %eax,%eax
  801079:	89 c2                	mov    %eax,%edx
  80107b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80107f:	75 17                	jne    801098 <__umoddi3+0x48>
  801081:	39 fe                	cmp    %edi,%esi
  801083:	76 4b                	jbe    8010d0 <__umoddi3+0x80>
  801085:	89 c8                	mov    %ecx,%eax
  801087:	89 fa                	mov    %edi,%edx
  801089:	f7 f6                	div    %esi
  80108b:	89 d0                	mov    %edx,%eax
  80108d:	31 d2                	xor    %edx,%edx
  80108f:	83 c4 14             	add    $0x14,%esp
  801092:	5e                   	pop    %esi
  801093:	5f                   	pop    %edi
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    
  801096:	66 90                	xchg   %ax,%ax
  801098:	39 f8                	cmp    %edi,%eax
  80109a:	77 54                	ja     8010f0 <__umoddi3+0xa0>
  80109c:	0f bd e8             	bsr    %eax,%ebp
  80109f:	83 f5 1f             	xor    $0x1f,%ebp
  8010a2:	75 5c                	jne    801100 <__umoddi3+0xb0>
  8010a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010a8:	39 3c 24             	cmp    %edi,(%esp)
  8010ab:	0f 87 e7 00 00 00    	ja     801198 <__umoddi3+0x148>
  8010b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010b5:	29 f1                	sub    %esi,%ecx
  8010b7:	19 c7                	sbb    %eax,%edi
  8010b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8010c9:	83 c4 14             	add    $0x14,%esp
  8010cc:	5e                   	pop    %esi
  8010cd:	5f                   	pop    %edi
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    
  8010d0:	85 f6                	test   %esi,%esi
  8010d2:	89 f5                	mov    %esi,%ebp
  8010d4:	75 0b                	jne    8010e1 <__umoddi3+0x91>
  8010d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010db:	31 d2                	xor    %edx,%edx
  8010dd:	f7 f6                	div    %esi
  8010df:	89 c5                	mov    %eax,%ebp
  8010e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010e5:	31 d2                	xor    %edx,%edx
  8010e7:	f7 f5                	div    %ebp
  8010e9:	89 c8                	mov    %ecx,%eax
  8010eb:	f7 f5                	div    %ebp
  8010ed:	eb 9c                	jmp    80108b <__umoddi3+0x3b>
  8010ef:	90                   	nop
  8010f0:	89 c8                	mov    %ecx,%eax
  8010f2:	89 fa                	mov    %edi,%edx
  8010f4:	83 c4 14             	add    $0x14,%esp
  8010f7:	5e                   	pop    %esi
  8010f8:	5f                   	pop    %edi
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    
  8010fb:	90                   	nop
  8010fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801100:	8b 04 24             	mov    (%esp),%eax
  801103:	be 20 00 00 00       	mov    $0x20,%esi
  801108:	89 e9                	mov    %ebp,%ecx
  80110a:	29 ee                	sub    %ebp,%esi
  80110c:	d3 e2                	shl    %cl,%edx
  80110e:	89 f1                	mov    %esi,%ecx
  801110:	d3 e8                	shr    %cl,%eax
  801112:	89 e9                	mov    %ebp,%ecx
  801114:	89 44 24 04          	mov    %eax,0x4(%esp)
  801118:	8b 04 24             	mov    (%esp),%eax
  80111b:	09 54 24 04          	or     %edx,0x4(%esp)
  80111f:	89 fa                	mov    %edi,%edx
  801121:	d3 e0                	shl    %cl,%eax
  801123:	89 f1                	mov    %esi,%ecx
  801125:	89 44 24 08          	mov    %eax,0x8(%esp)
  801129:	8b 44 24 10          	mov    0x10(%esp),%eax
  80112d:	d3 ea                	shr    %cl,%edx
  80112f:	89 e9                	mov    %ebp,%ecx
  801131:	d3 e7                	shl    %cl,%edi
  801133:	89 f1                	mov    %esi,%ecx
  801135:	d3 e8                	shr    %cl,%eax
  801137:	89 e9                	mov    %ebp,%ecx
  801139:	09 f8                	or     %edi,%eax
  80113b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80113f:	f7 74 24 04          	divl   0x4(%esp)
  801143:	d3 e7                	shl    %cl,%edi
  801145:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801149:	89 d7                	mov    %edx,%edi
  80114b:	f7 64 24 08          	mull   0x8(%esp)
  80114f:	39 d7                	cmp    %edx,%edi
  801151:	89 c1                	mov    %eax,%ecx
  801153:	89 14 24             	mov    %edx,(%esp)
  801156:	72 2c                	jb     801184 <__umoddi3+0x134>
  801158:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80115c:	72 22                	jb     801180 <__umoddi3+0x130>
  80115e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801162:	29 c8                	sub    %ecx,%eax
  801164:	19 d7                	sbb    %edx,%edi
  801166:	89 e9                	mov    %ebp,%ecx
  801168:	89 fa                	mov    %edi,%edx
  80116a:	d3 e8                	shr    %cl,%eax
  80116c:	89 f1                	mov    %esi,%ecx
  80116e:	d3 e2                	shl    %cl,%edx
  801170:	89 e9                	mov    %ebp,%ecx
  801172:	d3 ef                	shr    %cl,%edi
  801174:	09 d0                	or     %edx,%eax
  801176:	89 fa                	mov    %edi,%edx
  801178:	83 c4 14             	add    $0x14,%esp
  80117b:	5e                   	pop    %esi
  80117c:	5f                   	pop    %edi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    
  80117f:	90                   	nop
  801180:	39 d7                	cmp    %edx,%edi
  801182:	75 da                	jne    80115e <__umoddi3+0x10e>
  801184:	8b 14 24             	mov    (%esp),%edx
  801187:	89 c1                	mov    %eax,%ecx
  801189:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80118d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801191:	eb cb                	jmp    80115e <__umoddi3+0x10e>
  801193:	90                   	nop
  801194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801198:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80119c:	0f 82 0f ff ff ff    	jb     8010b1 <__umoddi3+0x61>
  8011a2:	e9 1a ff ff ff       	jmp    8010c1 <__umoddi3+0x71>
