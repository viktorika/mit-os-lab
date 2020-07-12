
obj/user/spin.debug：     文件格式 elf32-i386


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
  80002c:	e8 8e 00 00 00       	call   8000bf <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800047:	c7 04 24 60 25 80 00 	movl   $0x802560,(%esp)
  80004e:	e8 70 01 00 00       	call   8001c3 <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 16 10 00 00       	call   80106e <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 d8 25 80 00 	movl   $0x8025d8,(%esp)
  800065:	e8 59 01 00 00       	call   8001c3 <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  800073:	e8 4b 01 00 00       	call   8001c3 <cprintf>
	sys_yield();
  800078:	e8 2d 0c 00 00       	call   800caa <sys_yield>
	sys_yield();
  80007d:	e8 28 0c 00 00       	call   800caa <sys_yield>
	sys_yield();
  800082:	e8 23 0c 00 00       	call   800caa <sys_yield>
	sys_yield();
  800087:	e8 1e 0c 00 00       	call   800caa <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 15 0c 00 00       	call   800caa <sys_yield>
	sys_yield();
  800095:	e8 10 0c 00 00       	call   800caa <sys_yield>
	sys_yield();
  80009a:	e8 0b 0c 00 00       	call   800caa <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 05 0c 00 00       	call   800caa <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 b0 25 80 00 	movl   $0x8025b0,(%esp)
  8000ac:	e8 12 01 00 00       	call   8001c3 <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 80 0b 00 00       	call   800c39 <sys_env_destroy>
}
  8000b9:	83 c4 14             	add    $0x14,%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 10             	sub    $0x10,%esp
  8000c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000cd:	e8 b9 0b 00 00       	call   800c8b <sys_getenvid>
  8000d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000df:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e4:	85 db                	test   %ebx,%ebx
  8000e6:	7e 07                	jle    8000ef <libmain+0x30>
		binaryname = argv[0];
  8000e8:	8b 06                	mov    (%esi),%eax
  8000ea:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000f3:	89 1c 24             	mov    %ebx,(%esp)
  8000f6:	e8 45 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8000fb:	e8 07 00 00 00       	call   800107 <exit>
}
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80010d:	e8 04 14 00 00       	call   801516 <close_all>
	sys_env_destroy(0);
  800112:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800119:	e8 1b 0b 00 00       	call   800c39 <sys_env_destroy>
}
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 14             	sub    $0x14,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 13                	mov    (%ebx),%edx
  80012c:	8d 42 01             	lea    0x1(%edx),%eax
  80012f:	89 03                	mov    %eax,(%ebx)
  800131:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800134:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800138:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013d:	75 19                	jne    800158 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80013f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800146:	00 
  800147:	8d 43 08             	lea    0x8(%ebx),%eax
  80014a:	89 04 24             	mov    %eax,(%esp)
  80014d:	e8 aa 0a 00 00       	call   800bfc <sys_cputs>
		b->idx = 0;
  800152:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800158:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015c:	83 c4 14             	add    $0x14,%esp
  80015f:	5b                   	pop    %ebx
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80016b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800172:	00 00 00 
	b.cnt = 0;
  800175:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800182:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800186:	8b 45 08             	mov    0x8(%ebp),%eax
  800189:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800193:	89 44 24 04          	mov    %eax,0x4(%esp)
  800197:	c7 04 24 20 01 80 00 	movl   $0x800120,(%esp)
  80019e:	e8 b1 01 00 00       	call   800354 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ad:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b3:	89 04 24             	mov    %eax,(%esp)
  8001b6:	e8 41 0a 00 00       	call   800bfc <sys_cputs>

	return b.cnt;
}
  8001bb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    

008001c3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	e8 87 ff ff ff       	call   800162 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    
  8001dd:	66 90                	xchg   %ax,%ax
  8001df:	90                   	nop

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 3c             	sub    $0x3c,%esp
  8001e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ec:	89 d7                	mov    %edx,%edi
  8001ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8001f7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8001fa:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800202:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800205:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800208:	39 f1                	cmp    %esi,%ecx
  80020a:	72 14                	jb     800220 <printnum+0x40>
  80020c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80020f:	76 0f                	jbe    800220 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800211:	8b 45 14             	mov    0x14(%ebp),%eax
  800214:	8d 70 ff             	lea    -0x1(%eax),%esi
  800217:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80021a:	85 f6                	test   %esi,%esi
  80021c:	7f 60                	jg     80027e <printnum+0x9e>
  80021e:	eb 72                	jmp    800292 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800220:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800223:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800227:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80022a:	8d 51 ff             	lea    -0x1(%ecx),%edx
  80022d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800231:	89 44 24 08          	mov    %eax,0x8(%esp)
  800235:	8b 44 24 08          	mov    0x8(%esp),%eax
  800239:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80023d:	89 c3                	mov    %eax,%ebx
  80023f:	89 d6                	mov    %edx,%esi
  800241:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800244:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800247:	89 54 24 08          	mov    %edx,0x8(%esp)
  80024b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80024f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800252:	89 04 24             	mov    %eax,(%esp)
  800255:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	e8 6f 20 00 00       	call   8022d0 <__udivdi3>
  800261:	89 d9                	mov    %ebx,%ecx
  800263:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800267:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800272:	89 fa                	mov    %edi,%edx
  800274:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800277:	e8 64 ff ff ff       	call   8001e0 <printnum>
  80027c:	eb 14                	jmp    800292 <printnum+0xb2>
			putch(padc, putdat);
  80027e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800282:	8b 45 18             	mov    0x18(%ebp),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	ff d3                	call   *%ebx
		while (--width > 0)
  80028a:	83 ee 01             	sub    $0x1,%esi
  80028d:	75 ef                	jne    80027e <printnum+0x9e>
  80028f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800292:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800296:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80029a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80029d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002ab:	89 04 24             	mov    %eax,(%esp)
  8002ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b5:	e8 46 21 00 00       	call   802400 <__umoddi3>
  8002ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002be:	0f be 80 00 26 80 00 	movsbl 0x802600(%eax),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002cb:	ff d0                	call   *%eax
}
  8002cd:	83 c4 3c             	add    $0x3c,%esp
  8002d0:	5b                   	pop    %ebx
  8002d1:	5e                   	pop    %esi
  8002d2:	5f                   	pop    %edi
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d8:	83 fa 01             	cmp    $0x1,%edx
  8002db:	7e 0e                	jle    8002eb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	8b 52 04             	mov    0x4(%edx),%edx
  8002e9:	eb 22                	jmp    80030d <getuint+0x38>
	else if (lflag)
  8002eb:	85 d2                	test   %edx,%edx
  8002ed:	74 10                	je     8002ff <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ef:	8b 10                	mov    (%eax),%edx
  8002f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f4:	89 08                	mov    %ecx,(%eax)
  8002f6:	8b 02                	mov    (%edx),%eax
  8002f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fd:	eb 0e                	jmp    80030d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	8d 4a 04             	lea    0x4(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 02                	mov    (%edx),%eax
  800308:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800315:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	3b 50 04             	cmp    0x4(%eax),%edx
  80031e:	73 0a                	jae    80032a <sprintputch+0x1b>
		*b->buf++ = ch;
  800320:	8d 4a 01             	lea    0x1(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 45 08             	mov    0x8(%ebp),%eax
  800328:	88 02                	mov    %al,(%edx)
}
  80032a:	5d                   	pop    %ebp
  80032b:	c3                   	ret    

0080032c <printfmt>:
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  800332:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800335:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800339:	8b 45 10             	mov    0x10(%ebp),%eax
  80033c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800340:	8b 45 0c             	mov    0xc(%ebp),%eax
  800343:	89 44 24 04          	mov    %eax,0x4(%esp)
  800347:	8b 45 08             	mov    0x8(%ebp),%eax
  80034a:	89 04 24             	mov    %eax,(%esp)
  80034d:	e8 02 00 00 00       	call   800354 <vprintfmt>
}
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <vprintfmt>:
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
  80035a:	83 ec 3c             	sub    $0x3c,%esp
  80035d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800360:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800363:	eb 18                	jmp    80037d <vprintfmt+0x29>
			if (ch == '\0')
  800365:	85 c0                	test   %eax,%eax
  800367:	0f 84 c3 03 00 00    	je     800730 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80036d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800371:	89 04 24             	mov    %eax,(%esp)
  800374:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800377:	89 f3                	mov    %esi,%ebx
  800379:	eb 02                	jmp    80037d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80037b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037d:	8d 73 01             	lea    0x1(%ebx),%esi
  800380:	0f b6 03             	movzbl (%ebx),%eax
  800383:	83 f8 25             	cmp    $0x25,%eax
  800386:	75 dd                	jne    800365 <vprintfmt+0x11>
  800388:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80038c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800393:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80039a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a6:	eb 1d                	jmp    8003c5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	89 de                	mov    %ebx,%esi
			padc = '-';
  8003aa:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8003ae:	eb 15                	jmp    8003c5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	89 de                	mov    %ebx,%esi
			padc = '0';
  8003b2:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8003b6:	eb 0d                	jmp    8003c5 <vprintfmt+0x71>
				width = precision, precision = -1;
  8003b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003be:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003c8:	0f b6 06             	movzbl (%esi),%eax
  8003cb:	0f b6 c8             	movzbl %al,%ecx
  8003ce:	83 e8 23             	sub    $0x23,%eax
  8003d1:	3c 55                	cmp    $0x55,%al
  8003d3:	0f 87 2f 03 00 00    	ja     800708 <vprintfmt+0x3b4>
  8003d9:	0f b6 c0             	movzbl %al,%eax
  8003dc:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
				precision = precision * 10 + ch - '0';
  8003e3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8003e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  8003e9:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003ed:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003f0:	83 f9 09             	cmp    $0x9,%ecx
  8003f3:	77 50                	ja     800445 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	89 de                	mov    %ebx,%esi
  8003f7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8003fa:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003fd:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800400:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800404:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800407:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80040a:	83 fb 09             	cmp    $0x9,%ebx
  80040d:	76 eb                	jbe    8003fa <vprintfmt+0xa6>
  80040f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800412:	eb 33                	jmp    800447 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 48 04             	lea    0x4(%eax),%ecx
  80041a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80041d:	8b 00                	mov    (%eax),%eax
  80041f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800422:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800424:	eb 21                	jmp    800447 <vprintfmt+0xf3>
  800426:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800429:	85 c9                	test   %ecx,%ecx
  80042b:	b8 00 00 00 00       	mov    $0x0,%eax
  800430:	0f 49 c1             	cmovns %ecx,%eax
  800433:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800436:	89 de                	mov    %ebx,%esi
  800438:	eb 8b                	jmp    8003c5 <vprintfmt+0x71>
  80043a:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80043c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800443:	eb 80                	jmp    8003c5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800445:	89 de                	mov    %ebx,%esi
			if (width < 0)
  800447:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044b:	0f 89 74 ff ff ff    	jns    8003c5 <vprintfmt+0x71>
  800451:	e9 62 ff ff ff       	jmp    8003b8 <vprintfmt+0x64>
			lflag++;
  800456:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800459:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80045b:	e9 65 ff ff ff       	jmp    8003c5 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046d:	8b 00                	mov    (%eax),%eax
  80046f:	89 04 24             	mov    %eax,(%esp)
  800472:	ff 55 08             	call   *0x8(%ebp)
			break;
  800475:	e9 03 ff ff ff       	jmp    80037d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80047a:	8b 45 14             	mov    0x14(%ebp),%eax
  80047d:	8d 50 04             	lea    0x4(%eax),%edx
  800480:	89 55 14             	mov    %edx,0x14(%ebp)
  800483:	8b 00                	mov    (%eax),%eax
  800485:	99                   	cltd   
  800486:	31 d0                	xor    %edx,%eax
  800488:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048a:	83 f8 0f             	cmp    $0xf,%eax
  80048d:	7f 0b                	jg     80049a <vprintfmt+0x146>
  80048f:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  800496:	85 d2                	test   %edx,%edx
  800498:	75 20                	jne    8004ba <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80049a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049e:	c7 44 24 08 18 26 80 	movl   $0x802618,0x8(%esp)
  8004a5:	00 
  8004a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ad:	89 04 24             	mov    %eax,(%esp)
  8004b0:	e8 77 fe ff ff       	call   80032c <printfmt>
  8004b5:	e9 c3 fe ff ff       	jmp    80037d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  8004ba:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004be:	c7 44 24 08 53 2b 80 	movl   $0x802b53,0x8(%esp)
  8004c5:	00 
  8004c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cd:	89 04 24             	mov    %eax,(%esp)
  8004d0:	e8 57 fe ff ff       	call   80032c <printfmt>
  8004d5:	e9 a3 fe ff ff       	jmp    80037d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004dd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	ba 11 26 80 00       	mov    $0x802611,%edx
  8004f2:	0f 45 d0             	cmovne %eax,%edx
  8004f5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004f8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8004fc:	74 04                	je     800502 <vprintfmt+0x1ae>
  8004fe:	85 f6                	test   %esi,%esi
  800500:	7f 19                	jg     80051b <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800502:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800505:	8d 70 01             	lea    0x1(%eax),%esi
  800508:	0f b6 10             	movzbl (%eax),%edx
  80050b:	0f be c2             	movsbl %dl,%eax
  80050e:	85 c0                	test   %eax,%eax
  800510:	0f 85 95 00 00 00    	jne    8005ab <vprintfmt+0x257>
  800516:	e9 85 00 00 00       	jmp    8005a0 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80051f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800522:	89 04 24             	mov    %eax,(%esp)
  800525:	e8 b8 02 00 00       	call   8007e2 <strnlen>
  80052a:	29 c6                	sub    %eax,%esi
  80052c:	89 f0                	mov    %esi,%eax
  80052e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800531:	85 f6                	test   %esi,%esi
  800533:	7e cd                	jle    800502 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800535:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800539:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80053c:	89 c3                	mov    %eax,%ebx
  80053e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800542:	89 34 24             	mov    %esi,(%esp)
  800545:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800548:	83 eb 01             	sub    $0x1,%ebx
  80054b:	75 f1                	jne    80053e <vprintfmt+0x1ea>
  80054d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800550:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800553:	eb ad                	jmp    800502 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800555:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800559:	74 1e                	je     800579 <vprintfmt+0x225>
  80055b:	0f be d2             	movsbl %dl,%edx
  80055e:	83 ea 20             	sub    $0x20,%edx
  800561:	83 fa 5e             	cmp    $0x5e,%edx
  800564:	76 13                	jbe    800579 <vprintfmt+0x225>
					putch('?', putdat);
  800566:	8b 45 0c             	mov    0xc(%ebp),%eax
  800569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800574:	ff 55 08             	call   *0x8(%ebp)
  800577:	eb 0d                	jmp    800586 <vprintfmt+0x232>
					putch(ch, putdat);
  800579:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80057c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800586:	83 ef 01             	sub    $0x1,%edi
  800589:	83 c6 01             	add    $0x1,%esi
  80058c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800590:	0f be c2             	movsbl %dl,%eax
  800593:	85 c0                	test   %eax,%eax
  800595:	75 20                	jne    8005b7 <vprintfmt+0x263>
  800597:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80059a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80059d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  8005a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a4:	7f 25                	jg     8005cb <vprintfmt+0x277>
  8005a6:	e9 d2 fd ff ff       	jmp    80037d <vprintfmt+0x29>
  8005ab:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005b4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b7:	85 db                	test   %ebx,%ebx
  8005b9:	78 9a                	js     800555 <vprintfmt+0x201>
  8005bb:	83 eb 01             	sub    $0x1,%ebx
  8005be:	79 95                	jns    800555 <vprintfmt+0x201>
  8005c0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005c3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005c9:	eb d5                	jmp    8005a0 <vprintfmt+0x24c>
  8005cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ce:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  8005d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005df:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005e1:	83 eb 01             	sub    $0x1,%ebx
  8005e4:	75 ee                	jne    8005d4 <vprintfmt+0x280>
  8005e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005e9:	e9 8f fd ff ff       	jmp    80037d <vprintfmt+0x29>
	if (lflag >= 2)
  8005ee:	83 fa 01             	cmp    $0x1,%edx
  8005f1:	7e 16                	jle    800609 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 08             	lea    0x8(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fc:	8b 50 04             	mov    0x4(%eax),%edx
  8005ff:	8b 00                	mov    (%eax),%eax
  800601:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800604:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800607:	eb 32                	jmp    80063b <vprintfmt+0x2e7>
	else if (lflag)
  800609:	85 d2                	test   %edx,%edx
  80060b:	74 18                	je     800625 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 50 04             	lea    0x4(%eax),%edx
  800613:	89 55 14             	mov    %edx,0x14(%ebp)
  800616:	8b 30                	mov    (%eax),%esi
  800618:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80061b:	89 f0                	mov    %esi,%eax
  80061d:	c1 f8 1f             	sar    $0x1f,%eax
  800620:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800623:	eb 16                	jmp    80063b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 50 04             	lea    0x4(%eax),%edx
  80062b:	89 55 14             	mov    %edx,0x14(%ebp)
  80062e:	8b 30                	mov    (%eax),%esi
  800630:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800633:	89 f0                	mov    %esi,%eax
  800635:	c1 f8 1f             	sar    $0x1f,%eax
  800638:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  80063b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  800641:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800646:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064a:	0f 89 80 00 00 00    	jns    8006d0 <vprintfmt+0x37c>
				putch('-', putdat);
  800650:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800654:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80065e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800661:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800664:	f7 d8                	neg    %eax
  800666:	83 d2 00             	adc    $0x0,%edx
  800669:	f7 da                	neg    %edx
			base = 10;
  80066b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800670:	eb 5e                	jmp    8006d0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800672:	8d 45 14             	lea    0x14(%ebp),%eax
  800675:	e8 5b fc ff ff       	call   8002d5 <getuint>
			base = 10;
  80067a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80067f:	eb 4f                	jmp    8006d0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800681:	8d 45 14             	lea    0x14(%ebp),%eax
  800684:	e8 4c fc ff ff       	call   8002d5 <getuint>
			base = 8;
  800689:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80068e:	eb 40                	jmp    8006d0 <vprintfmt+0x37c>
			putch('0', putdat);
  800690:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800694:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80069b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80069e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a9:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 50 04             	lea    0x4(%eax),%edx
  8006b2:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8006b5:	8b 00                	mov    (%eax),%eax
  8006b7:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8006bc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006c1:	eb 0d                	jmp    8006d0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8006c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c6:	e8 0a fc ff ff       	call   8002d5 <getuint>
			base = 16;
  8006cb:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8006d0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006d4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006d8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006db:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006df:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006e3:	89 04 24             	mov    %eax,(%esp)
  8006e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ea:	89 fa                	mov    %edi,%edx
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	e8 ec fa ff ff       	call   8001e0 <printnum>
			break;
  8006f4:	e9 84 fc ff ff       	jmp    80037d <vprintfmt+0x29>
			putch(ch, putdat);
  8006f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006fd:	89 0c 24             	mov    %ecx,(%esp)
  800700:	ff 55 08             	call   *0x8(%ebp)
			break;
  800703:	e9 75 fc ff ff       	jmp    80037d <vprintfmt+0x29>
			putch('%', putdat);
  800708:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800713:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800716:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80071a:	0f 84 5b fc ff ff    	je     80037b <vprintfmt+0x27>
  800720:	89 f3                	mov    %esi,%ebx
  800722:	83 eb 01             	sub    $0x1,%ebx
  800725:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800729:	75 f7                	jne    800722 <vprintfmt+0x3ce>
  80072b:	e9 4d fc ff ff       	jmp    80037d <vprintfmt+0x29>
}
  800730:	83 c4 3c             	add    $0x3c,%esp
  800733:	5b                   	pop    %ebx
  800734:	5e                   	pop    %esi
  800735:	5f                   	pop    %edi
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	83 ec 28             	sub    $0x28,%esp
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  800741:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800744:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800747:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800755:	85 c0                	test   %eax,%eax
  800757:	74 30                	je     800789 <vsnprintf+0x51>
  800759:	85 d2                	test   %edx,%edx
  80075b:	7e 2c                	jle    800789 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800764:	8b 45 10             	mov    0x10(%ebp),%eax
  800767:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800772:	c7 04 24 0f 03 80 00 	movl   $0x80030f,(%esp)
  800779:	e8 d6 fb ff ff       	call   800354 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800781:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800784:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800787:	eb 05                	jmp    80078e <vsnprintf+0x56>
		return -E_INVAL;
  800789:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800796:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800799:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079d:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	89 04 24             	mov    %eax,(%esp)
  8007b1:	e8 82 ff ff ff       	call   800738 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    
  8007b8:	66 90                	xchg   %ax,%ax
  8007ba:	66 90                	xchg   %ax,%ax
  8007bc:	66 90                	xchg   %ax,%ax
  8007be:	66 90                	xchg   %ax,%ax

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007c9:	74 10                	je     8007db <strlen+0x1b>
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007d0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d7:	75 f7                	jne    8007d0 <strlen+0x10>
  8007d9:	eb 05                	jmp    8007e0 <strlen+0x20>
  8007db:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	53                   	push   %ebx
  8007e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ec:	85 c9                	test   %ecx,%ecx
  8007ee:	74 1c                	je     80080c <strnlen+0x2a>
  8007f0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007f3:	74 1e                	je     800813 <strnlen+0x31>
  8007f5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007fa:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fc:	39 ca                	cmp    %ecx,%edx
  8007fe:	74 18                	je     800818 <strnlen+0x36>
  800800:	83 c2 01             	add    $0x1,%edx
  800803:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800808:	75 f0                	jne    8007fa <strnlen+0x18>
  80080a:	eb 0c                	jmp    800818 <strnlen+0x36>
  80080c:	b8 00 00 00 00       	mov    $0x0,%eax
  800811:	eb 05                	jmp    800818 <strnlen+0x36>
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800818:	5b                   	pop    %ebx
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800825:	89 c2                	mov    %eax,%edx
  800827:	83 c2 01             	add    $0x1,%edx
  80082a:	83 c1 01             	add    $0x1,%ecx
  80082d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800831:	88 5a ff             	mov    %bl,-0x1(%edx)
  800834:	84 db                	test   %bl,%bl
  800836:	75 ef                	jne    800827 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800838:	5b                   	pop    %ebx
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	83 ec 08             	sub    $0x8,%esp
  800842:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800845:	89 1c 24             	mov    %ebx,(%esp)
  800848:	e8 73 ff ff ff       	call   8007c0 <strlen>
	strcpy(dst + len, src);
  80084d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800850:	89 54 24 04          	mov    %edx,0x4(%esp)
  800854:	01 d8                	add    %ebx,%eax
  800856:	89 04 24             	mov    %eax,(%esp)
  800859:	e8 bd ff ff ff       	call   80081b <strcpy>
	return dst;
}
  80085e:	89 d8                	mov    %ebx,%eax
  800860:	83 c4 08             	add    $0x8,%esp
  800863:	5b                   	pop    %ebx
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	56                   	push   %esi
  80086a:	53                   	push   %ebx
  80086b:	8b 75 08             	mov    0x8(%ebp),%esi
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800874:	85 db                	test   %ebx,%ebx
  800876:	74 17                	je     80088f <strncpy+0x29>
  800878:	01 f3                	add    %esi,%ebx
  80087a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80087c:	83 c1 01             	add    $0x1,%ecx
  80087f:	0f b6 02             	movzbl (%edx),%eax
  800882:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800885:	80 3a 01             	cmpb   $0x1,(%edx)
  800888:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80088b:	39 d9                	cmp    %ebx,%ecx
  80088d:	75 ed                	jne    80087c <strncpy+0x16>
	}
	return ret;
}
  80088f:	89 f0                	mov    %esi,%eax
  800891:	5b                   	pop    %ebx
  800892:	5e                   	pop    %esi
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	57                   	push   %edi
  800899:	56                   	push   %esi
  80089a:	53                   	push   %ebx
  80089b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a1:	8b 75 10             	mov    0x10(%ebp),%esi
  8008a4:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a6:	85 f6                	test   %esi,%esi
  8008a8:	74 34                	je     8008de <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  8008aa:	83 fe 01             	cmp    $0x1,%esi
  8008ad:	74 26                	je     8008d5 <strlcpy+0x40>
  8008af:	0f b6 0b             	movzbl (%ebx),%ecx
  8008b2:	84 c9                	test   %cl,%cl
  8008b4:	74 23                	je     8008d9 <strlcpy+0x44>
  8008b6:	83 ee 02             	sub    $0x2,%esi
  8008b9:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  8008be:	83 c0 01             	add    $0x1,%eax
  8008c1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008c4:	39 f2                	cmp    %esi,%edx
  8008c6:	74 13                	je     8008db <strlcpy+0x46>
  8008c8:	83 c2 01             	add    $0x1,%edx
  8008cb:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008cf:	84 c9                	test   %cl,%cl
  8008d1:	75 eb                	jne    8008be <strlcpy+0x29>
  8008d3:	eb 06                	jmp    8008db <strlcpy+0x46>
  8008d5:	89 f8                	mov    %edi,%eax
  8008d7:	eb 02                	jmp    8008db <strlcpy+0x46>
  8008d9:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  8008db:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008de:	29 f8                	sub    %edi,%eax
}
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5f                   	pop    %edi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ee:	0f b6 01             	movzbl (%ecx),%eax
  8008f1:	84 c0                	test   %al,%al
  8008f3:	74 15                	je     80090a <strcmp+0x25>
  8008f5:	3a 02                	cmp    (%edx),%al
  8008f7:	75 11                	jne    80090a <strcmp+0x25>
		p++, q++;
  8008f9:	83 c1 01             	add    $0x1,%ecx
  8008fc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ff:	0f b6 01             	movzbl (%ecx),%eax
  800902:	84 c0                	test   %al,%al
  800904:	74 04                	je     80090a <strcmp+0x25>
  800906:	3a 02                	cmp    (%edx),%al
  800908:	74 ef                	je     8008f9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80090a:	0f b6 c0             	movzbl %al,%eax
  80090d:	0f b6 12             	movzbl (%edx),%edx
  800910:	29 d0                	sub    %edx,%eax
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800922:	85 f6                	test   %esi,%esi
  800924:	74 29                	je     80094f <strncmp+0x3b>
  800926:	0f b6 03             	movzbl (%ebx),%eax
  800929:	84 c0                	test   %al,%al
  80092b:	74 30                	je     80095d <strncmp+0x49>
  80092d:	3a 02                	cmp    (%edx),%al
  80092f:	75 2c                	jne    80095d <strncmp+0x49>
  800931:	8d 43 01             	lea    0x1(%ebx),%eax
  800934:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800936:	89 c3                	mov    %eax,%ebx
  800938:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80093b:	39 f0                	cmp    %esi,%eax
  80093d:	74 17                	je     800956 <strncmp+0x42>
  80093f:	0f b6 08             	movzbl (%eax),%ecx
  800942:	84 c9                	test   %cl,%cl
  800944:	74 17                	je     80095d <strncmp+0x49>
  800946:	83 c0 01             	add    $0x1,%eax
  800949:	3a 0a                	cmp    (%edx),%cl
  80094b:	74 e9                	je     800936 <strncmp+0x22>
  80094d:	eb 0e                	jmp    80095d <strncmp+0x49>
	if (n == 0)
		return 0;
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
  800954:	eb 0f                	jmp    800965 <strncmp+0x51>
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
  80095b:	eb 08                	jmp    800965 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80095d:	0f b6 03             	movzbl (%ebx),%eax
  800960:	0f b6 12             	movzbl (%edx),%edx
  800963:	29 d0                	sub    %edx,%eax
}
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	53                   	push   %ebx
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800973:	0f b6 18             	movzbl (%eax),%ebx
  800976:	84 db                	test   %bl,%bl
  800978:	74 1d                	je     800997 <strchr+0x2e>
  80097a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80097c:	38 d3                	cmp    %dl,%bl
  80097e:	75 06                	jne    800986 <strchr+0x1d>
  800980:	eb 1a                	jmp    80099c <strchr+0x33>
  800982:	38 ca                	cmp    %cl,%dl
  800984:	74 16                	je     80099c <strchr+0x33>
	for (; *s; s++)
  800986:	83 c0 01             	add    $0x1,%eax
  800989:	0f b6 10             	movzbl (%eax),%edx
  80098c:	84 d2                	test   %dl,%dl
  80098e:	75 f2                	jne    800982 <strchr+0x19>
			return (char *) s;
	return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
  800995:	eb 05                	jmp    80099c <strchr+0x33>
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009a9:	0f b6 18             	movzbl (%eax),%ebx
  8009ac:	84 db                	test   %bl,%bl
  8009ae:	74 16                	je     8009c6 <strfind+0x27>
  8009b0:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009b2:	38 d3                	cmp    %dl,%bl
  8009b4:	75 06                	jne    8009bc <strfind+0x1d>
  8009b6:	eb 0e                	jmp    8009c6 <strfind+0x27>
  8009b8:	38 ca                	cmp    %cl,%dl
  8009ba:	74 0a                	je     8009c6 <strfind+0x27>
	for (; *s; s++)
  8009bc:	83 c0 01             	add    $0x1,%eax
  8009bf:	0f b6 10             	movzbl (%eax),%edx
  8009c2:	84 d2                	test   %dl,%dl
  8009c4:	75 f2                	jne    8009b8 <strfind+0x19>
			break;
	return (char *) s;
}
  8009c6:	5b                   	pop    %ebx
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	57                   	push   %edi
  8009cd:	56                   	push   %esi
  8009ce:	53                   	push   %ebx
  8009cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d5:	85 c9                	test   %ecx,%ecx
  8009d7:	74 36                	je     800a0f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009df:	75 28                	jne    800a09 <memset+0x40>
  8009e1:	f6 c1 03             	test   $0x3,%cl
  8009e4:	75 23                	jne    800a09 <memset+0x40>
		c &= 0xFF;
  8009e6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ea:	89 d3                	mov    %edx,%ebx
  8009ec:	c1 e3 08             	shl    $0x8,%ebx
  8009ef:	89 d6                	mov    %edx,%esi
  8009f1:	c1 e6 18             	shl    $0x18,%esi
  8009f4:	89 d0                	mov    %edx,%eax
  8009f6:	c1 e0 10             	shl    $0x10,%eax
  8009f9:	09 f0                	or     %esi,%eax
  8009fb:	09 c2                	or     %eax,%edx
  8009fd:	89 d0                	mov    %edx,%eax
  8009ff:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a01:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a04:	fc                   	cld    
  800a05:	f3 ab                	rep stos %eax,%es:(%edi)
  800a07:	eb 06                	jmp    800a0f <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0c:	fc                   	cld    
  800a0d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0f:	89 f8                	mov    %edi,%eax
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5f                   	pop    %edi
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	57                   	push   %edi
  800a1a:	56                   	push   %esi
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a21:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a24:	39 c6                	cmp    %eax,%esi
  800a26:	73 35                	jae    800a5d <memmove+0x47>
  800a28:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a2b:	39 d0                	cmp    %edx,%eax
  800a2d:	73 2e                	jae    800a5d <memmove+0x47>
		s += n;
		d += n;
  800a2f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a32:	89 d6                	mov    %edx,%esi
  800a34:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3c:	75 13                	jne    800a51 <memmove+0x3b>
  800a3e:	f6 c1 03             	test   $0x3,%cl
  800a41:	75 0e                	jne    800a51 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a43:	83 ef 04             	sub    $0x4,%edi
  800a46:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a49:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a4c:	fd                   	std    
  800a4d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4f:	eb 09                	jmp    800a5a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a51:	83 ef 01             	sub    $0x1,%edi
  800a54:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a57:	fd                   	std    
  800a58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a5a:	fc                   	cld    
  800a5b:	eb 1d                	jmp    800a7a <memmove+0x64>
  800a5d:	89 f2                	mov    %esi,%edx
  800a5f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a61:	f6 c2 03             	test   $0x3,%dl
  800a64:	75 0f                	jne    800a75 <memmove+0x5f>
  800a66:	f6 c1 03             	test   $0x3,%cl
  800a69:	75 0a                	jne    800a75 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a6b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a6e:	89 c7                	mov    %eax,%edi
  800a70:	fc                   	cld    
  800a71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a73:	eb 05                	jmp    800a7a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800a75:	89 c7                	mov    %eax,%edi
  800a77:	fc                   	cld    
  800a78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a84:	8b 45 10             	mov    0x10(%ebp),%eax
  800a87:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	89 04 24             	mov    %eax,(%esp)
  800a98:	e8 79 ff ff ff       	call   800a16 <memmove>
}
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800aa8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aab:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aae:	8d 78 ff             	lea    -0x1(%eax),%edi
  800ab1:	85 c0                	test   %eax,%eax
  800ab3:	74 36                	je     800aeb <memcmp+0x4c>
		if (*s1 != *s2)
  800ab5:	0f b6 03             	movzbl (%ebx),%eax
  800ab8:	0f b6 0e             	movzbl (%esi),%ecx
  800abb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac0:	38 c8                	cmp    %cl,%al
  800ac2:	74 1c                	je     800ae0 <memcmp+0x41>
  800ac4:	eb 10                	jmp    800ad6 <memcmp+0x37>
  800ac6:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800acb:	83 c2 01             	add    $0x1,%edx
  800ace:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ad2:	38 c8                	cmp    %cl,%al
  800ad4:	74 0a                	je     800ae0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ad6:	0f b6 c0             	movzbl %al,%eax
  800ad9:	0f b6 c9             	movzbl %cl,%ecx
  800adc:	29 c8                	sub    %ecx,%eax
  800ade:	eb 10                	jmp    800af0 <memcmp+0x51>
	while (n-- > 0) {
  800ae0:	39 fa                	cmp    %edi,%edx
  800ae2:	75 e2                	jne    800ac6 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae9:	eb 05                	jmp    800af0 <memcmp+0x51>
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	53                   	push   %ebx
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800aff:	89 c2                	mov    %eax,%edx
  800b01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b04:	39 d0                	cmp    %edx,%eax
  800b06:	73 13                	jae    800b1b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b08:	89 d9                	mov    %ebx,%ecx
  800b0a:	38 18                	cmp    %bl,(%eax)
  800b0c:	75 06                	jne    800b14 <memfind+0x1f>
  800b0e:	eb 0b                	jmp    800b1b <memfind+0x26>
  800b10:	38 08                	cmp    %cl,(%eax)
  800b12:	74 07                	je     800b1b <memfind+0x26>
	for (; s < ends; s++)
  800b14:	83 c0 01             	add    $0x1,%eax
  800b17:	39 d0                	cmp    %edx,%eax
  800b19:	75 f5                	jne    800b10 <memfind+0x1b>
			break;
	return (void *) s;
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2a:	0f b6 0a             	movzbl (%edx),%ecx
  800b2d:	80 f9 09             	cmp    $0x9,%cl
  800b30:	74 05                	je     800b37 <strtol+0x19>
  800b32:	80 f9 20             	cmp    $0x20,%cl
  800b35:	75 10                	jne    800b47 <strtol+0x29>
		s++;
  800b37:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b3a:	0f b6 0a             	movzbl (%edx),%ecx
  800b3d:	80 f9 09             	cmp    $0x9,%cl
  800b40:	74 f5                	je     800b37 <strtol+0x19>
  800b42:	80 f9 20             	cmp    $0x20,%cl
  800b45:	74 f0                	je     800b37 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800b47:	80 f9 2b             	cmp    $0x2b,%cl
  800b4a:	75 0a                	jne    800b56 <strtol+0x38>
		s++;
  800b4c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b4f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b54:	eb 11                	jmp    800b67 <strtol+0x49>
  800b56:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800b5b:	80 f9 2d             	cmp    $0x2d,%cl
  800b5e:	75 07                	jne    800b67 <strtol+0x49>
		s++, neg = 1;
  800b60:	83 c2 01             	add    $0x1,%edx
  800b63:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b67:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b6c:	75 15                	jne    800b83 <strtol+0x65>
  800b6e:	80 3a 30             	cmpb   $0x30,(%edx)
  800b71:	75 10                	jne    800b83 <strtol+0x65>
  800b73:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b77:	75 0a                	jne    800b83 <strtol+0x65>
		s += 2, base = 16;
  800b79:	83 c2 02             	add    $0x2,%edx
  800b7c:	b8 10 00 00 00       	mov    $0x10,%eax
  800b81:	eb 10                	jmp    800b93 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800b83:	85 c0                	test   %eax,%eax
  800b85:	75 0c                	jne    800b93 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b87:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800b89:	80 3a 30             	cmpb   $0x30,(%edx)
  800b8c:	75 05                	jne    800b93 <strtol+0x75>
		s++, base = 8;
  800b8e:	83 c2 01             	add    $0x1,%edx
  800b91:	b0 08                	mov    $0x8,%al
		base = 10;
  800b93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b98:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9b:	0f b6 0a             	movzbl (%edx),%ecx
  800b9e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ba1:	89 f0                	mov    %esi,%eax
  800ba3:	3c 09                	cmp    $0x9,%al
  800ba5:	77 08                	ja     800baf <strtol+0x91>
			dig = *s - '0';
  800ba7:	0f be c9             	movsbl %cl,%ecx
  800baa:	83 e9 30             	sub    $0x30,%ecx
  800bad:	eb 20                	jmp    800bcf <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800baf:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bb2:	89 f0                	mov    %esi,%eax
  800bb4:	3c 19                	cmp    $0x19,%al
  800bb6:	77 08                	ja     800bc0 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800bb8:	0f be c9             	movsbl %cl,%ecx
  800bbb:	83 e9 57             	sub    $0x57,%ecx
  800bbe:	eb 0f                	jmp    800bcf <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800bc0:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bc3:	89 f0                	mov    %esi,%eax
  800bc5:	3c 19                	cmp    $0x19,%al
  800bc7:	77 16                	ja     800bdf <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bc9:	0f be c9             	movsbl %cl,%ecx
  800bcc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bcf:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bd2:	7d 0f                	jge    800be3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bd4:	83 c2 01             	add    $0x1,%edx
  800bd7:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bdb:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bdd:	eb bc                	jmp    800b9b <strtol+0x7d>
  800bdf:	89 d8                	mov    %ebx,%eax
  800be1:	eb 02                	jmp    800be5 <strtol+0xc7>
  800be3:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800be5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be9:	74 05                	je     800bf0 <strtol+0xd2>
		*endptr = (char *) s;
  800beb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bee:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bf0:	f7 d8                	neg    %eax
  800bf2:	85 ff                	test   %edi,%edi
  800bf4:	0f 44 c3             	cmove  %ebx,%eax
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	89 c3                	mov    %eax,%ebx
  800c0f:	89 c7                	mov    %eax,%edi
  800c11:	89 c6                	mov    %eax,%esi
  800c13:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2a:	89 d1                	mov    %edx,%ecx
  800c2c:	89 d3                	mov    %edx,%ebx
  800c2e:	89 d7                	mov    %edx,%edi
  800c30:	89 d6                	mov    %edx,%esi
  800c32:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c47:	b8 03 00 00 00       	mov    $0x3,%eax
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	89 cb                	mov    %ecx,%ebx
  800c51:	89 cf                	mov    %ecx,%edi
  800c53:	89 ce                	mov    %ecx,%esi
  800c55:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 28                	jle    800c83 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c66:	00 
  800c67:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800c6e:	00 
  800c6f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c76:	00 
  800c77:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800c7e:	e8 23 14 00 00       	call   8020a6 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c83:	83 c4 2c             	add    $0x2c,%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c91:	ba 00 00 00 00       	mov    $0x0,%edx
  800c96:	b8 02 00 00 00       	mov    $0x2,%eax
  800c9b:	89 d1                	mov    %edx,%ecx
  800c9d:	89 d3                	mov    %edx,%ebx
  800c9f:	89 d7                	mov    %edx,%edi
  800ca1:	89 d6                	mov    %edx,%esi
  800ca3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_yield>:

void
sys_yield(void)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cba:	89 d1                	mov    %edx,%ecx
  800cbc:	89 d3                	mov    %edx,%ebx
  800cbe:	89 d7                	mov    %edx,%edi
  800cc0:	89 d6                	mov    %edx,%esi
  800cc2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cd2:	be 00 00 00 00       	mov    $0x0,%esi
  800cd7:	b8 04 00 00 00       	mov    $0x4,%eax
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce5:	89 f7                	mov    %esi,%edi
  800ce7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7e 28                	jle    800d15 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cf8:	00 
  800cf9:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800d00:	00 
  800d01:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d08:	00 
  800d09:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800d10:	e8 91 13 00 00       	call   8020a6 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d15:	83 c4 2c             	add    $0x2c,%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d26:	b8 05 00 00 00       	mov    $0x5,%eax
  800d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d34:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d37:	8b 75 18             	mov    0x18(%ebp),%esi
  800d3a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 28                	jle    800d68 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d44:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d4b:	00 
  800d4c:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800d53:	00 
  800d54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d5b:	00 
  800d5c:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800d63:	e8 3e 13 00 00       	call   8020a6 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d68:	83 c4 2c             	add    $0x2c,%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
  800d76:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	89 df                	mov    %ebx,%edi
  800d8b:	89 de                	mov    %ebx,%esi
  800d8d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	7e 28                	jle    800dbb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d97:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d9e:	00 
  800d9f:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800da6:	00 
  800da7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dae:	00 
  800daf:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800db6:	e8 eb 12 00 00       	call   8020a6 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dbb:	83 c4 2c             	add    $0x2c,%esp
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	57                   	push   %edi
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd1:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	89 df                	mov    %ebx,%edi
  800dde:	89 de                	mov    %ebx,%esi
  800de0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 28                	jle    800e0e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dea:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800df1:	00 
  800df2:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800df9:	00 
  800dfa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e01:	00 
  800e02:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800e09:	e8 98 12 00 00       	call   8020a6 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e0e:	83 c4 2c             	add    $0x2c,%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	57                   	push   %edi
  800e1a:	56                   	push   %esi
  800e1b:	53                   	push   %ebx
  800e1c:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e24:	b8 09 00 00 00       	mov    $0x9,%eax
  800e29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2f:	89 df                	mov    %ebx,%edi
  800e31:	89 de                	mov    %ebx,%esi
  800e33:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e35:	85 c0                	test   %eax,%eax
  800e37:	7e 28                	jle    800e61 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e44:	00 
  800e45:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800e4c:	00 
  800e4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e54:	00 
  800e55:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800e5c:	e8 45 12 00 00       	call   8020a6 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e61:	83 c4 2c             	add    $0x2c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	57                   	push   %edi
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
  800e6f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e77:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e82:	89 df                	mov    %ebx,%edi
  800e84:	89 de                	mov    %ebx,%esi
  800e86:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	7e 28                	jle    800eb4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e90:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e97:	00 
  800e98:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800e9f:	00 
  800ea0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea7:	00 
  800ea8:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800eaf:	e8 f2 11 00 00       	call   8020a6 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb4:	83 c4 2c             	add    $0x2c,%esp
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	57                   	push   %edi
  800ec0:	56                   	push   %esi
  800ec1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ec2:	be 00 00 00 00       	mov    $0x0,%esi
  800ec7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ecc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eda:	5b                   	pop    %ebx
  800edb:	5e                   	pop    %esi
  800edc:	5f                   	pop    %edi
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
  800ee5:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ee8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eed:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef5:	89 cb                	mov    %ecx,%ebx
  800ef7:	89 cf                	mov    %ecx,%edi
  800ef9:	89 ce                	mov    %ecx,%esi
  800efb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800efd:	85 c0                	test   %eax,%eax
  800eff:	7e 28                	jle    800f29 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f01:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f05:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800f14:	00 
  800f15:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1c:	00 
  800f1d:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800f24:	e8 7d 11 00 00       	call   8020a6 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f29:	83 c4 2c             	add    $0x2c,%esp
  800f2c:	5b                   	pop    %ebx
  800f2d:	5e                   	pop    %esi
  800f2e:	5f                   	pop    %edi
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	53                   	push   %ebx
  800f35:	83 ec 24             	sub    $0x24,%esp
  800f38:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f3b:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800f3d:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f41:	74 2e                	je     800f71 <pgfault+0x40>
  800f43:	89 c2                	mov    %eax,%edx
  800f45:	c1 ea 16             	shr    $0x16,%edx
  800f48:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f4f:	f6 c2 01             	test   $0x1,%dl
  800f52:	74 1d                	je     800f71 <pgfault+0x40>
  800f54:	89 c2                	mov    %eax,%edx
  800f56:	c1 ea 0c             	shr    $0xc,%edx
  800f59:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f60:	f6 c1 01             	test   $0x1,%cl
  800f63:	74 0c                	je     800f71 <pgfault+0x40>
  800f65:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f6c:	f6 c6 08             	test   $0x8,%dh
  800f6f:	75 20                	jne    800f91 <pgfault+0x60>
		panic("pgfault: page cow check failed, addr=%x\n", addr);
  800f71:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f75:	c7 44 24 08 2c 29 80 	movl   $0x80292c,0x8(%esp)
  800f7c:	00 
  800f7d:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800f84:	00 
  800f85:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  800f8c:	e8 15 11 00 00       	call   8020a6 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800f91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f96:	89 c3                	mov    %eax,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W))
  800f98:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f9f:	00 
  800fa0:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fa7:	00 
  800fa8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800faf:	e8 15 fd ff ff       	call   800cc9 <sys_page_alloc>
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	74 1c                	je     800fd4 <pgfault+0xa3>
		panic("pgfault: sys_page_alloc error");
  800fb8:	c7 44 24 08 1e 2a 80 	movl   $0x802a1e,0x8(%esp)
  800fbf:	00 
  800fc0:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800fc7:	00 
  800fc8:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  800fcf:	e8 d2 10 00 00       	call   8020a6 <_panic>

	memmove(PFTEMP, addr, PGSIZE);
  800fd4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fdb:	00 
  800fdc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fe0:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fe7:	e8 2a fa ff ff       	call   800a16 <memmove>
	if(sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))
  800fec:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ff3:	00 
  800ff4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ff8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fff:	00 
  801000:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801007:	00 
  801008:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80100f:	e8 09 fd ff ff       	call   800d1d <sys_page_map>
  801014:	85 c0                	test   %eax,%eax
  801016:	74 1c                	je     801034 <pgfault+0x103>
		panic("pgfault: sys_page_map error");
  801018:	c7 44 24 08 3c 2a 80 	movl   $0x802a3c,0x8(%esp)
  80101f:	00 
  801020:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801027:	00 
  801028:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  80102f:	e8 72 10 00 00       	call   8020a6 <_panic>

	if(sys_page_unmap(0, PFTEMP))
  801034:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80103b:	00 
  80103c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801043:	e8 28 fd ff ff       	call   800d70 <sys_page_unmap>
  801048:	85 c0                	test   %eax,%eax
  80104a:	74 1c                	je     801068 <pgfault+0x137>
		panic("pgfault: sys_page_unmap error");
  80104c:	c7 44 24 08 58 2a 80 	movl   $0x802a58,0x8(%esp)
  801053:	00 
  801054:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80105b:	00 
  80105c:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  801063:	e8 3e 10 00 00       	call   8020a6 <_panic>
}
  801068:	83 c4 24             	add    $0x24,%esp
  80106b:	5b                   	pop    %ebx
  80106c:	5d                   	pop    %ebp
  80106d:	c3                   	ret    

0080106e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	57                   	push   %edi
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
  801074:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	//根据文档的描述，duppage好像不应该处理除了可写或者copy-on-write的部分，但这里都交给duppage一块处理了
	set_pgfault_handler(pgfault);
  801077:	c7 04 24 31 0f 80 00 	movl   $0x800f31,(%esp)
  80107e:	e8 79 10 00 00       	call   8020fc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801083:	b8 07 00 00 00       	mov    $0x7,%eax
  801088:	cd 30                	int    $0x30
  80108a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();
	if(envid < 0)
  80108d:	85 c0                	test   %eax,%eax
  80108f:	79 1c                	jns    8010ad <fork+0x3f>
		//失败
		panic("fork: sys_exofork error");
  801091:	c7 44 24 08 76 2a 80 	movl   $0x802a76,0x8(%esp)
  801098:	00 
  801099:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
  8010a0:	00 
  8010a1:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  8010a8:	e8 f9 0f 00 00       	call   8020a6 <_panic>
  8010ad:	89 c7                	mov    %eax,%edi
	else if(!envid)
  8010af:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8010b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010b8:	75 1c                	jne    8010d6 <fork+0x68>
		//子进程
		thisenv = &envs[ENVX(sys_getenvid())];
  8010ba:	e8 cc fb ff ff       	call   800c8b <sys_getenvid>
  8010bf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010c4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010c7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010cc:	a3 04 40 80 00       	mov    %eax,0x804004
  8010d1:	e9 fc 01 00 00       	jmp    8012d2 <fork+0x264>
	else{
		//父进程
		unsigned addr;
		for(addr = UTEXT; addr < USTACKTOP; addr += PGSIZE){
			if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))
  8010d6:	89 d8                	mov    %ebx,%eax
  8010d8:	c1 e8 16             	shr    $0x16,%eax
  8010db:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e2:	a8 01                	test   $0x1,%al
  8010e4:	0f 84 58 01 00 00    	je     801242 <fork+0x1d4>
  8010ea:	89 d8                	mov    %ebx,%eax
  8010ec:	c1 e8 0c             	shr    $0xc,%eax
  8010ef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f6:	f6 c2 01             	test   $0x1,%dl
  8010f9:	0f 84 43 01 00 00    	je     801242 <fork+0x1d4>
  8010ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801106:	f6 c2 04             	test   $0x4,%dl
  801109:	0f 84 33 01 00 00    	je     801242 <fork+0x1d4>
	void *addr = (void *)(pn * PGSIZE);
  80110f:	89 c6                	mov    %eax,%esi
  801111:	c1 e6 0c             	shl    $0xc,%esi
	if(uvpt[pn] & PTE_SHARE){
  801114:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80111b:	f6 c6 04             	test   $0x4,%dh
  80111e:	74 4c                	je     80116c <fork+0xfe>
		if(sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL))
  801120:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801127:	25 07 0e 00 00       	and    $0xe07,%eax
  80112c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801130:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801134:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801138:	89 74 24 04          	mov    %esi,0x4(%esp)
  80113c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801143:	e8 d5 fb ff ff       	call   800d1d <sys_page_map>
  801148:	85 c0                	test   %eax,%eax
  80114a:	0f 84 f2 00 00 00    	je     801242 <fork+0x1d4>
			panic("duppage: sys_page_map pte_syscall error");
  801150:	c7 44 24 08 58 29 80 	movl   $0x802958,0x8(%esp)
  801157:	00 
  801158:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80115f:	00 
  801160:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  801167:	e8 3a 0f 00 00       	call   8020a6 <_panic>
	else if(uvpt[pn] & (PTE_W | PTE_COW)){
  80116c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801173:	a9 02 08 00 00       	test   $0x802,%eax
  801178:	0f 84 84 00 00 00    	je     801202 <fork+0x194>
		if(sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P))
  80117e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801185:	00 
  801186:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80118a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80118e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801192:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801199:	e8 7f fb ff ff       	call   800d1d <sys_page_map>
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	74 1c                	je     8011be <fork+0x150>
			panic("duppage: sys_page_map child error");
  8011a2:	c7 44 24 08 80 29 80 	movl   $0x802980,0x8(%esp)
  8011a9:	00 
  8011aa:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8011b1:	00 
  8011b2:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  8011b9:	e8 e8 0e 00 00       	call   8020a6 <_panic>
		if(sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P))
  8011be:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011c5:	00 
  8011c6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011d1:	00 
  8011d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011dd:	e8 3b fb ff ff       	call   800d1d <sys_page_map>
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	74 5c                	je     801242 <fork+0x1d4>
			panic("duppage: sys_page_map remap parent error");
  8011e6:	c7 44 24 08 a4 29 80 	movl   $0x8029a4,0x8(%esp)
  8011ed:	00 
  8011ee:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  8011f5:	00 
  8011f6:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  8011fd:	e8 a4 0e 00 00       	call   8020a6 <_panic>
		if(sys_page_map(0, addr, envid, addr, PTE_U|PTE_P))
  801202:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801209:	00 
  80120a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80120e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801212:	89 74 24 04          	mov    %esi,0x4(%esp)
  801216:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80121d:	e8 fb fa ff ff       	call   800d1d <sys_page_map>
  801222:	85 c0                	test   %eax,%eax
  801224:	74 1c                	je     801242 <fork+0x1d4>
			panic("duppage: other sys_page_map error");
  801226:	c7 44 24 08 d0 29 80 	movl   $0x8029d0,0x8(%esp)
  80122d:	00 
  80122e:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  801235:	00 
  801236:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  80123d:	e8 64 0e 00 00       	call   8020a6 <_panic>
		for(addr = UTEXT; addr < USTACKTOP; addr += PGSIZE){
  801242:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801248:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80124e:	0f 85 82 fe ff ff    	jne    8010d6 <fork+0x68>
				duppage(envid, PGNUM(addr));
		}
		if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W))
  801254:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80125b:	00 
  80125c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801263:	ee 
  801264:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801267:	89 04 24             	mov    %eax,(%esp)
  80126a:	e8 5a fa ff ff       	call   800cc9 <sys_page_alloc>
  80126f:	85 c0                	test   %eax,%eax
  801271:	74 1c                	je     80128f <fork+0x221>
			panic("fork: sys_page_alloc error");
  801273:	c7 44 24 08 8e 2a 80 	movl   $0x802a8e,0x8(%esp)
  80127a:	00 
  80127b:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801282:	00 
  801283:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  80128a:	e8 17 0e 00 00       	call   8020a6 <_panic>
		extern void _pgfault_upcall();
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80128f:	c7 44 24 04 85 21 80 	movl   $0x802185,0x4(%esp)
  801296:	00 
  801297:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80129a:	89 3c 24             	mov    %edi,(%esp)
  80129d:	e8 c7 fb ff ff       	call   800e69 <sys_env_set_pgfault_upcall>
		if(sys_env_set_status(envid, ENV_RUNNABLE))
  8012a2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012a9:	00 
  8012aa:	89 3c 24             	mov    %edi,(%esp)
  8012ad:	e8 11 fb ff ff       	call   800dc3 <sys_env_set_status>
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	74 1c                	je     8012d2 <fork+0x264>
			panic("fork: sys_env_set_status error");
  8012b6:	c7 44 24 08 f4 29 80 	movl   $0x8029f4,0x8(%esp)
  8012bd:	00 
  8012be:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8012c5:	00 
  8012c6:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  8012cd:	e8 d4 0d 00 00       	call   8020a6 <_panic>
	}
	return envid;
}
  8012d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012d5:	83 c4 2c             	add    $0x2c,%esp
  8012d8:	5b                   	pop    %ebx
  8012d9:	5e                   	pop    %esi
  8012da:	5f                   	pop    %edi
  8012db:	5d                   	pop    %ebp
  8012dc:	c3                   	ret    

008012dd <sfork>:

// Challenge!
int
sfork(void)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012e3:	c7 44 24 08 a9 2a 80 	movl   $0x802aa9,0x8(%esp)
  8012ea:	00 
  8012eb:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  8012f2:	00 
  8012f3:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  8012fa:	e8 a7 0d 00 00       	call   8020a6 <_panic>
  8012ff:	90                   	nop

00801300 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801303:	8b 45 08             	mov    0x8(%ebp),%eax
  801306:	05 00 00 00 30       	add    $0x30000000,%eax
  80130b:	c1 e8 0c             	shr    $0xc,%eax
}
  80130e:	5d                   	pop    %ebp
  80130f:	c3                   	ret    

00801310 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801313:	8b 45 08             	mov    0x8(%ebp),%eax
  801316:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80131b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801320:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801325:	5d                   	pop    %ebp
  801326:	c3                   	ret    

00801327 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80132a:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80132f:	a8 01                	test   $0x1,%al
  801331:	74 34                	je     801367 <fd_alloc+0x40>
  801333:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801338:	a8 01                	test   $0x1,%al
  80133a:	74 32                	je     80136e <fd_alloc+0x47>
  80133c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  801341:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801343:	89 c2                	mov    %eax,%edx
  801345:	c1 ea 16             	shr    $0x16,%edx
  801348:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134f:	f6 c2 01             	test   $0x1,%dl
  801352:	74 1f                	je     801373 <fd_alloc+0x4c>
  801354:	89 c2                	mov    %eax,%edx
  801356:	c1 ea 0c             	shr    $0xc,%edx
  801359:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801360:	f6 c2 01             	test   $0x1,%dl
  801363:	75 1a                	jne    80137f <fd_alloc+0x58>
  801365:	eb 0c                	jmp    801373 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  801367:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80136c:	eb 05                	jmp    801373 <fd_alloc+0x4c>
  80136e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  801373:	8b 45 08             	mov    0x8(%ebp),%eax
  801376:	89 08                	mov    %ecx,(%eax)
			return 0;
  801378:	b8 00 00 00 00       	mov    $0x0,%eax
  80137d:	eb 1a                	jmp    801399 <fd_alloc+0x72>
  80137f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801384:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801389:	75 b6                	jne    801341 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  80138b:	8b 45 08             	mov    0x8(%ebp),%eax
  80138e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801394:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    

0080139b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013a1:	83 f8 1f             	cmp    $0x1f,%eax
  8013a4:	77 36                	ja     8013dc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013a6:	c1 e0 0c             	shl    $0xc,%eax
  8013a9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	c1 ea 16             	shr    $0x16,%edx
  8013b3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ba:	f6 c2 01             	test   $0x1,%dl
  8013bd:	74 24                	je     8013e3 <fd_lookup+0x48>
  8013bf:	89 c2                	mov    %eax,%edx
  8013c1:	c1 ea 0c             	shr    $0xc,%edx
  8013c4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013cb:	f6 c2 01             	test   $0x1,%dl
  8013ce:	74 1a                	je     8013ea <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d3:	89 02                	mov    %eax,(%edx)
	return 0;
  8013d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013da:	eb 13                	jmp    8013ef <fd_lookup+0x54>
		return -E_INVAL;
  8013dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e1:	eb 0c                	jmp    8013ef <fd_lookup+0x54>
		return -E_INVAL;
  8013e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e8:	eb 05                	jmp    8013ef <fd_lookup+0x54>
  8013ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013ef:	5d                   	pop    %ebp
  8013f0:	c3                   	ret    

008013f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	53                   	push   %ebx
  8013f5:	83 ec 14             	sub    $0x14,%esp
  8013f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8013fe:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801404:	75 1e                	jne    801424 <dev_lookup+0x33>
  801406:	eb 0e                	jmp    801416 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  801408:	b8 20 30 80 00       	mov    $0x803020,%eax
  80140d:	eb 0c                	jmp    80141b <dev_lookup+0x2a>
  80140f:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801414:	eb 05                	jmp    80141b <dev_lookup+0x2a>
  801416:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  80141b:	89 03                	mov    %eax,(%ebx)
			return 0;
  80141d:	b8 00 00 00 00       	mov    $0x0,%eax
  801422:	eb 38                	jmp    80145c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  801424:	39 05 20 30 80 00    	cmp    %eax,0x803020
  80142a:	74 dc                	je     801408 <dev_lookup+0x17>
  80142c:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  801432:	74 db                	je     80140f <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801434:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80143a:	8b 52 48             	mov    0x48(%edx),%edx
  80143d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801441:	89 54 24 04          	mov    %edx,0x4(%esp)
  801445:	c7 04 24 c0 2a 80 00 	movl   $0x802ac0,(%esp)
  80144c:	e8 72 ed ff ff       	call   8001c3 <cprintf>
	*dev = 0;
  801451:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801457:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80145c:	83 c4 14             	add    $0x14,%esp
  80145f:	5b                   	pop    %ebx
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    

00801462 <fd_close>:
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	56                   	push   %esi
  801466:	53                   	push   %ebx
  801467:	83 ec 20             	sub    $0x20,%esp
  80146a:	8b 75 08             	mov    0x8(%ebp),%esi
  80146d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801470:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801473:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801477:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80147d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801480:	89 04 24             	mov    %eax,(%esp)
  801483:	e8 13 ff ff ff       	call   80139b <fd_lookup>
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 05                	js     801491 <fd_close+0x2f>
	    || fd != fd2)
  80148c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80148f:	74 0c                	je     80149d <fd_close+0x3b>
		return (must_exist ? r : 0);
  801491:	84 db                	test   %bl,%bl
  801493:	ba 00 00 00 00       	mov    $0x0,%edx
  801498:	0f 44 c2             	cmove  %edx,%eax
  80149b:	eb 3f                	jmp    8014dc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80149d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a4:	8b 06                	mov    (%esi),%eax
  8014a6:	89 04 24             	mov    %eax,(%esp)
  8014a9:	e8 43 ff ff ff       	call   8013f1 <dev_lookup>
  8014ae:	89 c3                	mov    %eax,%ebx
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 16                	js     8014ca <fd_close+0x68>
		if (dev->dev_close)
  8014b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b7:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8014ba:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	74 07                	je     8014ca <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8014c3:	89 34 24             	mov    %esi,(%esp)
  8014c6:	ff d0                	call   *%eax
  8014c8:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8014ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d5:	e8 96 f8 ff ff       	call   800d70 <sys_page_unmap>
	return r;
  8014da:	89 d8                	mov    %ebx,%eax
}
  8014dc:	83 c4 20             	add    $0x20,%esp
  8014df:	5b                   	pop    %ebx
  8014e0:	5e                   	pop    %esi
  8014e1:	5d                   	pop    %ebp
  8014e2:	c3                   	ret    

008014e3 <close>:

int
close(int fdnum)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f3:	89 04 24             	mov    %eax,(%esp)
  8014f6:	e8 a0 fe ff ff       	call   80139b <fd_lookup>
  8014fb:	89 c2                	mov    %eax,%edx
  8014fd:	85 d2                	test   %edx,%edx
  8014ff:	78 13                	js     801514 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801501:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801508:	00 
  801509:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150c:	89 04 24             	mov    %eax,(%esp)
  80150f:	e8 4e ff ff ff       	call   801462 <fd_close>
}
  801514:	c9                   	leave  
  801515:	c3                   	ret    

00801516 <close_all>:

void
close_all(void)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	53                   	push   %ebx
  80151a:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80151d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801522:	89 1c 24             	mov    %ebx,(%esp)
  801525:	e8 b9 ff ff ff       	call   8014e3 <close>
	for (i = 0; i < MAXFD; i++)
  80152a:	83 c3 01             	add    $0x1,%ebx
  80152d:	83 fb 20             	cmp    $0x20,%ebx
  801530:	75 f0                	jne    801522 <close_all+0xc>
}
  801532:	83 c4 14             	add    $0x14,%esp
  801535:	5b                   	pop    %ebx
  801536:	5d                   	pop    %ebp
  801537:	c3                   	ret    

00801538 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	57                   	push   %edi
  80153c:	56                   	push   %esi
  80153d:	53                   	push   %ebx
  80153e:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801541:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801544:	89 44 24 04          	mov    %eax,0x4(%esp)
  801548:	8b 45 08             	mov    0x8(%ebp),%eax
  80154b:	89 04 24             	mov    %eax,(%esp)
  80154e:	e8 48 fe ff ff       	call   80139b <fd_lookup>
  801553:	89 c2                	mov    %eax,%edx
  801555:	85 d2                	test   %edx,%edx
  801557:	0f 88 e1 00 00 00    	js     80163e <dup+0x106>
		return r;
	close(newfdnum);
  80155d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801560:	89 04 24             	mov    %eax,(%esp)
  801563:	e8 7b ff ff ff       	call   8014e3 <close>

	newfd = INDEX2FD(newfdnum);
  801568:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80156b:	c1 e3 0c             	shl    $0xc,%ebx
  80156e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801574:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801577:	89 04 24             	mov    %eax,(%esp)
  80157a:	e8 91 fd ff ff       	call   801310 <fd2data>
  80157f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801581:	89 1c 24             	mov    %ebx,(%esp)
  801584:	e8 87 fd ff ff       	call   801310 <fd2data>
  801589:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80158b:	89 f0                	mov    %esi,%eax
  80158d:	c1 e8 16             	shr    $0x16,%eax
  801590:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801597:	a8 01                	test   $0x1,%al
  801599:	74 43                	je     8015de <dup+0xa6>
  80159b:	89 f0                	mov    %esi,%eax
  80159d:	c1 e8 0c             	shr    $0xc,%eax
  8015a0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015a7:	f6 c2 01             	test   $0x1,%dl
  8015aa:	74 32                	je     8015de <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015bc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015c7:	00 
  8015c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d3:	e8 45 f7 ff ff       	call   800d1d <sys_page_map>
  8015d8:	89 c6                	mov    %eax,%esi
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 3e                	js     80161c <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015e1:	89 c2                	mov    %eax,%edx
  8015e3:	c1 ea 0c             	shr    $0xc,%edx
  8015e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015ed:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015f3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015f7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8015fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801602:	00 
  801603:	89 44 24 04          	mov    %eax,0x4(%esp)
  801607:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80160e:	e8 0a f7 ff ff       	call   800d1d <sys_page_map>
  801613:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801615:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801618:	85 f6                	test   %esi,%esi
  80161a:	79 22                	jns    80163e <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80161c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801620:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801627:	e8 44 f7 ff ff       	call   800d70 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80162c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801630:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801637:	e8 34 f7 ff ff       	call   800d70 <sys_page_unmap>
	return r;
  80163c:	89 f0                	mov    %esi,%eax
}
  80163e:	83 c4 3c             	add    $0x3c,%esp
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	5f                   	pop    %edi
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    

00801646 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	53                   	push   %ebx
  80164a:	83 ec 24             	sub    $0x24,%esp
  80164d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801650:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801653:	89 44 24 04          	mov    %eax,0x4(%esp)
  801657:	89 1c 24             	mov    %ebx,(%esp)
  80165a:	e8 3c fd ff ff       	call   80139b <fd_lookup>
  80165f:	89 c2                	mov    %eax,%edx
  801661:	85 d2                	test   %edx,%edx
  801663:	78 6d                	js     8016d2 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801665:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801668:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166f:	8b 00                	mov    (%eax),%eax
  801671:	89 04 24             	mov    %eax,(%esp)
  801674:	e8 78 fd ff ff       	call   8013f1 <dev_lookup>
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 55                	js     8016d2 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80167d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801680:	8b 50 08             	mov    0x8(%eax),%edx
  801683:	83 e2 03             	and    $0x3,%edx
  801686:	83 fa 01             	cmp    $0x1,%edx
  801689:	75 23                	jne    8016ae <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80168b:	a1 04 40 80 00       	mov    0x804004,%eax
  801690:	8b 40 48             	mov    0x48(%eax),%eax
  801693:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801697:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169b:	c7 04 24 01 2b 80 00 	movl   $0x802b01,(%esp)
  8016a2:	e8 1c eb ff ff       	call   8001c3 <cprintf>
		return -E_INVAL;
  8016a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ac:	eb 24                	jmp    8016d2 <read+0x8c>
	}
	if (!dev->dev_read)
  8016ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b1:	8b 52 08             	mov    0x8(%edx),%edx
  8016b4:	85 d2                	test   %edx,%edx
  8016b6:	74 15                	je     8016cd <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016c6:	89 04 24             	mov    %eax,(%esp)
  8016c9:	ff d2                	call   *%edx
  8016cb:	eb 05                	jmp    8016d2 <read+0x8c>
		return -E_NOT_SUPP;
  8016cd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8016d2:	83 c4 24             	add    $0x24,%esp
  8016d5:	5b                   	pop    %ebx
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    

008016d8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	57                   	push   %edi
  8016dc:	56                   	push   %esi
  8016dd:	53                   	push   %ebx
  8016de:	83 ec 1c             	sub    $0x1c,%esp
  8016e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016e4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016e7:	85 f6                	test   %esi,%esi
  8016e9:	74 33                	je     80171e <readn+0x46>
  8016eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f0:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016f5:	89 f2                	mov    %esi,%edx
  8016f7:	29 c2                	sub    %eax,%edx
  8016f9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016fd:	03 45 0c             	add    0xc(%ebp),%eax
  801700:	89 44 24 04          	mov    %eax,0x4(%esp)
  801704:	89 3c 24             	mov    %edi,(%esp)
  801707:	e8 3a ff ff ff       	call   801646 <read>
		if (m < 0)
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 1b                	js     80172b <readn+0x53>
			return m;
		if (m == 0)
  801710:	85 c0                	test   %eax,%eax
  801712:	74 11                	je     801725 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  801714:	01 c3                	add    %eax,%ebx
  801716:	89 d8                	mov    %ebx,%eax
  801718:	39 f3                	cmp    %esi,%ebx
  80171a:	72 d9                	jb     8016f5 <readn+0x1d>
  80171c:	eb 0b                	jmp    801729 <readn+0x51>
  80171e:	b8 00 00 00 00       	mov    $0x0,%eax
  801723:	eb 06                	jmp    80172b <readn+0x53>
  801725:	89 d8                	mov    %ebx,%eax
  801727:	eb 02                	jmp    80172b <readn+0x53>
  801729:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80172b:	83 c4 1c             	add    $0x1c,%esp
  80172e:	5b                   	pop    %ebx
  80172f:	5e                   	pop    %esi
  801730:	5f                   	pop    %edi
  801731:	5d                   	pop    %ebp
  801732:	c3                   	ret    

00801733 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	53                   	push   %ebx
  801737:	83 ec 24             	sub    $0x24,%esp
  80173a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801740:	89 44 24 04          	mov    %eax,0x4(%esp)
  801744:	89 1c 24             	mov    %ebx,(%esp)
  801747:	e8 4f fc ff ff       	call   80139b <fd_lookup>
  80174c:	89 c2                	mov    %eax,%edx
  80174e:	85 d2                	test   %edx,%edx
  801750:	78 68                	js     8017ba <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801752:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801755:	89 44 24 04          	mov    %eax,0x4(%esp)
  801759:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175c:	8b 00                	mov    (%eax),%eax
  80175e:	89 04 24             	mov    %eax,(%esp)
  801761:	e8 8b fc ff ff       	call   8013f1 <dev_lookup>
  801766:	85 c0                	test   %eax,%eax
  801768:	78 50                	js     8017ba <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80176a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801771:	75 23                	jne    801796 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801773:	a1 04 40 80 00       	mov    0x804004,%eax
  801778:	8b 40 48             	mov    0x48(%eax),%eax
  80177b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80177f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801783:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  80178a:	e8 34 ea ff ff       	call   8001c3 <cprintf>
		return -E_INVAL;
  80178f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801794:	eb 24                	jmp    8017ba <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801796:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801799:	8b 52 0c             	mov    0xc(%edx),%edx
  80179c:	85 d2                	test   %edx,%edx
  80179e:	74 15                	je     8017b5 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017aa:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017ae:	89 04 24             	mov    %eax,(%esp)
  8017b1:	ff d2                	call   *%edx
  8017b3:	eb 05                	jmp    8017ba <write+0x87>
		return -E_NOT_SUPP;
  8017b5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8017ba:	83 c4 24             	add    $0x24,%esp
  8017bd:	5b                   	pop    %ebx
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    

008017c0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017c6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d0:	89 04 24             	mov    %eax,(%esp)
  8017d3:	e8 c3 fb ff ff       	call   80139b <fd_lookup>
  8017d8:	85 c0                	test   %eax,%eax
  8017da:	78 0e                	js     8017ea <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ea:	c9                   	leave  
  8017eb:	c3                   	ret    

008017ec <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	53                   	push   %ebx
  8017f0:	83 ec 24             	sub    $0x24,%esp
  8017f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fd:	89 1c 24             	mov    %ebx,(%esp)
  801800:	e8 96 fb ff ff       	call   80139b <fd_lookup>
  801805:	89 c2                	mov    %eax,%edx
  801807:	85 d2                	test   %edx,%edx
  801809:	78 61                	js     80186c <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80180b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801815:	8b 00                	mov    (%eax),%eax
  801817:	89 04 24             	mov    %eax,(%esp)
  80181a:	e8 d2 fb ff ff       	call   8013f1 <dev_lookup>
  80181f:	85 c0                	test   %eax,%eax
  801821:	78 49                	js     80186c <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801823:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801826:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80182a:	75 23                	jne    80184f <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80182c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801831:	8b 40 48             	mov    0x48(%eax),%eax
  801834:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183c:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  801843:	e8 7b e9 ff ff       	call   8001c3 <cprintf>
		return -E_INVAL;
  801848:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80184d:	eb 1d                	jmp    80186c <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80184f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801852:	8b 52 18             	mov    0x18(%edx),%edx
  801855:	85 d2                	test   %edx,%edx
  801857:	74 0e                	je     801867 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80185c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801860:	89 04 24             	mov    %eax,(%esp)
  801863:	ff d2                	call   *%edx
  801865:	eb 05                	jmp    80186c <ftruncate+0x80>
		return -E_NOT_SUPP;
  801867:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80186c:	83 c4 24             	add    $0x24,%esp
  80186f:	5b                   	pop    %ebx
  801870:	5d                   	pop    %ebp
  801871:	c3                   	ret    

00801872 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	53                   	push   %ebx
  801876:	83 ec 24             	sub    $0x24,%esp
  801879:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80187c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80187f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801883:	8b 45 08             	mov    0x8(%ebp),%eax
  801886:	89 04 24             	mov    %eax,(%esp)
  801889:	e8 0d fb ff ff       	call   80139b <fd_lookup>
  80188e:	89 c2                	mov    %eax,%edx
  801890:	85 d2                	test   %edx,%edx
  801892:	78 52                	js     8018e6 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801894:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801897:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189e:	8b 00                	mov    (%eax),%eax
  8018a0:	89 04 24             	mov    %eax,(%esp)
  8018a3:	e8 49 fb ff ff       	call   8013f1 <dev_lookup>
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	78 3a                	js     8018e6 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8018ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018af:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018b3:	74 2c                	je     8018e1 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018b5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018b8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018bf:	00 00 00 
	stat->st_isdir = 0;
  8018c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018c9:	00 00 00 
	stat->st_dev = dev;
  8018cc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018d9:	89 14 24             	mov    %edx,(%esp)
  8018dc:	ff 50 14             	call   *0x14(%eax)
  8018df:	eb 05                	jmp    8018e6 <fstat+0x74>
		return -E_NOT_SUPP;
  8018e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8018e6:	83 c4 24             	add    $0x24,%esp
  8018e9:	5b                   	pop    %ebx
  8018ea:	5d                   	pop    %ebp
  8018eb:	c3                   	ret    

008018ec <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	56                   	push   %esi
  8018f0:	53                   	push   %ebx
  8018f1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018fb:	00 
  8018fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ff:	89 04 24             	mov    %eax,(%esp)
  801902:	e8 af 01 00 00       	call   801ab6 <open>
  801907:	89 c3                	mov    %eax,%ebx
  801909:	85 db                	test   %ebx,%ebx
  80190b:	78 1b                	js     801928 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80190d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801910:	89 44 24 04          	mov    %eax,0x4(%esp)
  801914:	89 1c 24             	mov    %ebx,(%esp)
  801917:	e8 56 ff ff ff       	call   801872 <fstat>
  80191c:	89 c6                	mov    %eax,%esi
	close(fd);
  80191e:	89 1c 24             	mov    %ebx,(%esp)
  801921:	e8 bd fb ff ff       	call   8014e3 <close>
	return r;
  801926:	89 f0                	mov    %esi,%eax
}
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	5b                   	pop    %ebx
  80192c:	5e                   	pop    %esi
  80192d:	5d                   	pop    %ebp
  80192e:	c3                   	ret    

0080192f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	56                   	push   %esi
  801933:	53                   	push   %ebx
  801934:	83 ec 10             	sub    $0x10,%esp
  801937:	89 c6                	mov    %eax,%esi
  801939:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80193b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801942:	75 11                	jne    801955 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801944:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80194b:	e8 fd 08 00 00       	call   80224d <ipc_find_env>
  801950:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801955:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80195c:	00 
  80195d:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801964:	00 
  801965:	89 74 24 04          	mov    %esi,0x4(%esp)
  801969:	a1 00 40 80 00       	mov    0x804000,%eax
  80196e:	89 04 24             	mov    %eax,(%esp)
  801971:	e8 8f 08 00 00       	call   802205 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801976:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80197d:	00 
  80197e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801982:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801989:	e8 1b 08 00 00       	call   8021a9 <ipc_recv>
}
  80198e:	83 c4 10             	add    $0x10,%esp
  801991:	5b                   	pop    %ebx
  801992:	5e                   	pop    %esi
  801993:	5d                   	pop    %ebp
  801994:	c3                   	ret    

00801995 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	53                   	push   %ebx
  801999:	83 ec 14             	sub    $0x14,%esp
  80199c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80199f:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8019af:	b8 05 00 00 00       	mov    $0x5,%eax
  8019b4:	e8 76 ff ff ff       	call   80192f <fsipc>
  8019b9:	89 c2                	mov    %eax,%edx
  8019bb:	85 d2                	test   %edx,%edx
  8019bd:	78 2b                	js     8019ea <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019bf:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019c6:	00 
  8019c7:	89 1c 24             	mov    %ebx,(%esp)
  8019ca:	e8 4c ee ff ff       	call   80081b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019cf:	a1 80 50 80 00       	mov    0x805080,%eax
  8019d4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019da:	a1 84 50 80 00       	mov    0x805084,%eax
  8019df:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019ea:	83 c4 14             	add    $0x14,%esp
  8019ed:	5b                   	pop    %ebx
  8019ee:	5d                   	pop    %ebp
  8019ef:	c3                   	ret    

008019f0 <devfile_flush>:
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a01:	ba 00 00 00 00       	mov    $0x0,%edx
  801a06:	b8 06 00 00 00       	mov    $0x6,%eax
  801a0b:	e8 1f ff ff ff       	call   80192f <fsipc>
}
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <devfile_read>:
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	56                   	push   %esi
  801a16:	53                   	push   %ebx
  801a17:	83 ec 10             	sub    $0x10,%esp
  801a1a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a20:	8b 40 0c             	mov    0xc(%eax),%eax
  801a23:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a28:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a33:	b8 03 00 00 00       	mov    $0x3,%eax
  801a38:	e8 f2 fe ff ff       	call   80192f <fsipc>
  801a3d:	89 c3                	mov    %eax,%ebx
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	78 6a                	js     801aad <devfile_read+0x9b>
	assert(r <= n);
  801a43:	39 c6                	cmp    %eax,%esi
  801a45:	73 24                	jae    801a6b <devfile_read+0x59>
  801a47:	c7 44 24 0c 3a 2b 80 	movl   $0x802b3a,0xc(%esp)
  801a4e:	00 
  801a4f:	c7 44 24 08 41 2b 80 	movl   $0x802b41,0x8(%esp)
  801a56:	00 
  801a57:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  801a5e:	00 
  801a5f:	c7 04 24 56 2b 80 00 	movl   $0x802b56,(%esp)
  801a66:	e8 3b 06 00 00       	call   8020a6 <_panic>
	assert(r <= PGSIZE);
  801a6b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a70:	7e 24                	jle    801a96 <devfile_read+0x84>
  801a72:	c7 44 24 0c 61 2b 80 	movl   $0x802b61,0xc(%esp)
  801a79:	00 
  801a7a:	c7 44 24 08 41 2b 80 	movl   $0x802b41,0x8(%esp)
  801a81:	00 
  801a82:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801a89:	00 
  801a8a:	c7 04 24 56 2b 80 00 	movl   $0x802b56,(%esp)
  801a91:	e8 10 06 00 00       	call   8020a6 <_panic>
	memmove(buf, &fsipcbuf, r);
  801a96:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a9a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801aa1:	00 
  801aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa5:	89 04 24             	mov    %eax,(%esp)
  801aa8:	e8 69 ef ff ff       	call   800a16 <memmove>
}
  801aad:	89 d8                	mov    %ebx,%eax
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	5b                   	pop    %ebx
  801ab3:	5e                   	pop    %esi
  801ab4:	5d                   	pop    %ebp
  801ab5:	c3                   	ret    

00801ab6 <open>:
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	53                   	push   %ebx
  801aba:	83 ec 24             	sub    $0x24,%esp
  801abd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801ac0:	89 1c 24             	mov    %ebx,(%esp)
  801ac3:	e8 f8 ec ff ff       	call   8007c0 <strlen>
  801ac8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801acd:	7f 60                	jg     801b2f <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801acf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad2:	89 04 24             	mov    %eax,(%esp)
  801ad5:	e8 4d f8 ff ff       	call   801327 <fd_alloc>
  801ada:	89 c2                	mov    %eax,%edx
  801adc:	85 d2                	test   %edx,%edx
  801ade:	78 54                	js     801b34 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801ae0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ae4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801aeb:	e8 2b ed ff ff       	call   80081b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801af0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801af8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801afb:	b8 01 00 00 00       	mov    $0x1,%eax
  801b00:	e8 2a fe ff ff       	call   80192f <fsipc>
  801b05:	89 c3                	mov    %eax,%ebx
  801b07:	85 c0                	test   %eax,%eax
  801b09:	79 17                	jns    801b22 <open+0x6c>
		fd_close(fd, 0);
  801b0b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b12:	00 
  801b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b16:	89 04 24             	mov    %eax,(%esp)
  801b19:	e8 44 f9 ff ff       	call   801462 <fd_close>
		return r;
  801b1e:	89 d8                	mov    %ebx,%eax
  801b20:	eb 12                	jmp    801b34 <open+0x7e>
	return fd2num(fd);
  801b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b25:	89 04 24             	mov    %eax,(%esp)
  801b28:	e8 d3 f7 ff ff       	call   801300 <fd2num>
  801b2d:	eb 05                	jmp    801b34 <open+0x7e>
		return -E_BAD_PATH;
  801b2f:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801b34:	83 c4 24             	add    $0x24,%esp
  801b37:	5b                   	pop    %ebx
  801b38:	5d                   	pop    %ebp
  801b39:	c3                   	ret    
  801b3a:	66 90                	xchg   %ax,%ax
  801b3c:	66 90                	xchg   %ax,%ax
  801b3e:	66 90                	xchg   %ax,%ax

00801b40 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	56                   	push   %esi
  801b44:	53                   	push   %ebx
  801b45:	83 ec 10             	sub    $0x10,%esp
  801b48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4e:	89 04 24             	mov    %eax,(%esp)
  801b51:	e8 ba f7 ff ff       	call   801310 <fd2data>
  801b56:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b58:	c7 44 24 04 6d 2b 80 	movl   $0x802b6d,0x4(%esp)
  801b5f:	00 
  801b60:	89 1c 24             	mov    %ebx,(%esp)
  801b63:	e8 b3 ec ff ff       	call   80081b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b68:	8b 46 04             	mov    0x4(%esi),%eax
  801b6b:	2b 06                	sub    (%esi),%eax
  801b6d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b73:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b7a:	00 00 00 
	stat->st_dev = &devpipe;
  801b7d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b84:	30 80 00 
	return 0;
}
  801b87:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	5b                   	pop    %ebx
  801b90:	5e                   	pop    %esi
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    

00801b93 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	53                   	push   %ebx
  801b97:	83 ec 14             	sub    $0x14,%esp
  801b9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b9d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ba1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba8:	e8 c3 f1 ff ff       	call   800d70 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bad:	89 1c 24             	mov    %ebx,(%esp)
  801bb0:	e8 5b f7 ff ff       	call   801310 <fd2data>
  801bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc0:	e8 ab f1 ff ff       	call   800d70 <sys_page_unmap>
}
  801bc5:	83 c4 14             	add    $0x14,%esp
  801bc8:	5b                   	pop    %ebx
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    

00801bcb <_pipeisclosed>:
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	57                   	push   %edi
  801bcf:	56                   	push   %esi
  801bd0:	53                   	push   %ebx
  801bd1:	83 ec 2c             	sub    $0x2c,%esp
  801bd4:	89 c6                	mov    %eax,%esi
  801bd6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801bd9:	a1 04 40 80 00       	mov    0x804004,%eax
  801bde:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801be1:	89 34 24             	mov    %esi,(%esp)
  801be4:	e8 ac 06 00 00       	call   802295 <pageref>
  801be9:	89 c7                	mov    %eax,%edi
  801beb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bee:	89 04 24             	mov    %eax,(%esp)
  801bf1:	e8 9f 06 00 00       	call   802295 <pageref>
  801bf6:	39 c7                	cmp    %eax,%edi
  801bf8:	0f 94 c2             	sete   %dl
  801bfb:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801bfe:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801c04:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801c07:	39 fb                	cmp    %edi,%ebx
  801c09:	74 21                	je     801c2c <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801c0b:	84 d2                	test   %dl,%dl
  801c0d:	74 ca                	je     801bd9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c0f:	8b 51 58             	mov    0x58(%ecx),%edx
  801c12:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c16:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c1e:	c7 04 24 74 2b 80 00 	movl   $0x802b74,(%esp)
  801c25:	e8 99 e5 ff ff       	call   8001c3 <cprintf>
  801c2a:	eb ad                	jmp    801bd9 <_pipeisclosed+0xe>
}
  801c2c:	83 c4 2c             	add    $0x2c,%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5f                   	pop    %edi
  801c32:	5d                   	pop    %ebp
  801c33:	c3                   	ret    

00801c34 <devpipe_write>:
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	57                   	push   %edi
  801c38:	56                   	push   %esi
  801c39:	53                   	push   %ebx
  801c3a:	83 ec 1c             	sub    $0x1c,%esp
  801c3d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c40:	89 34 24             	mov    %esi,(%esp)
  801c43:	e8 c8 f6 ff ff       	call   801310 <fd2data>
	for (i = 0; i < n; i++) {
  801c48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c4c:	74 61                	je     801caf <devpipe_write+0x7b>
  801c4e:	89 c3                	mov    %eax,%ebx
  801c50:	bf 00 00 00 00       	mov    $0x0,%edi
  801c55:	eb 4a                	jmp    801ca1 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  801c57:	89 da                	mov    %ebx,%edx
  801c59:	89 f0                	mov    %esi,%eax
  801c5b:	e8 6b ff ff ff       	call   801bcb <_pipeisclosed>
  801c60:	85 c0                	test   %eax,%eax
  801c62:	75 54                	jne    801cb8 <devpipe_write+0x84>
			sys_yield();
  801c64:	e8 41 f0 ff ff       	call   800caa <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c69:	8b 43 04             	mov    0x4(%ebx),%eax
  801c6c:	8b 0b                	mov    (%ebx),%ecx
  801c6e:	8d 51 20             	lea    0x20(%ecx),%edx
  801c71:	39 d0                	cmp    %edx,%eax
  801c73:	73 e2                	jae    801c57 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c78:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c7c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c7f:	99                   	cltd   
  801c80:	c1 ea 1b             	shr    $0x1b,%edx
  801c83:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801c86:	83 e1 1f             	and    $0x1f,%ecx
  801c89:	29 d1                	sub    %edx,%ecx
  801c8b:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801c8f:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801c93:	83 c0 01             	add    $0x1,%eax
  801c96:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c99:	83 c7 01             	add    $0x1,%edi
  801c9c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c9f:	74 13                	je     801cb4 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ca1:	8b 43 04             	mov    0x4(%ebx),%eax
  801ca4:	8b 0b                	mov    (%ebx),%ecx
  801ca6:	8d 51 20             	lea    0x20(%ecx),%edx
  801ca9:	39 d0                	cmp    %edx,%eax
  801cab:	73 aa                	jae    801c57 <devpipe_write+0x23>
  801cad:	eb c6                	jmp    801c75 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  801caf:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  801cb4:	89 f8                	mov    %edi,%eax
  801cb6:	eb 05                	jmp    801cbd <devpipe_write+0x89>
				return 0;
  801cb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cbd:	83 c4 1c             	add    $0x1c,%esp
  801cc0:	5b                   	pop    %ebx
  801cc1:	5e                   	pop    %esi
  801cc2:	5f                   	pop    %edi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    

00801cc5 <devpipe_read>:
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	57                   	push   %edi
  801cc9:	56                   	push   %esi
  801cca:	53                   	push   %ebx
  801ccb:	83 ec 1c             	sub    $0x1c,%esp
  801cce:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801cd1:	89 3c 24             	mov    %edi,(%esp)
  801cd4:	e8 37 f6 ff ff       	call   801310 <fd2data>
	for (i = 0; i < n; i++) {
  801cd9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cdd:	74 54                	je     801d33 <devpipe_read+0x6e>
  801cdf:	89 c3                	mov    %eax,%ebx
  801ce1:	be 00 00 00 00       	mov    $0x0,%esi
  801ce6:	eb 3e                	jmp    801d26 <devpipe_read+0x61>
				return i;
  801ce8:	89 f0                	mov    %esi,%eax
  801cea:	eb 55                	jmp    801d41 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  801cec:	89 da                	mov    %ebx,%edx
  801cee:	89 f8                	mov    %edi,%eax
  801cf0:	e8 d6 fe ff ff       	call   801bcb <_pipeisclosed>
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	75 43                	jne    801d3c <devpipe_read+0x77>
			sys_yield();
  801cf9:	e8 ac ef ff ff       	call   800caa <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801cfe:	8b 03                	mov    (%ebx),%eax
  801d00:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d03:	74 e7                	je     801cec <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d05:	99                   	cltd   
  801d06:	c1 ea 1b             	shr    $0x1b,%edx
  801d09:	01 d0                	add    %edx,%eax
  801d0b:	83 e0 1f             	and    $0x1f,%eax
  801d0e:	29 d0                	sub    %edx,%eax
  801d10:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d18:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d1b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d1e:	83 c6 01             	add    $0x1,%esi
  801d21:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d24:	74 12                	je     801d38 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  801d26:	8b 03                	mov    (%ebx),%eax
  801d28:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d2b:	75 d8                	jne    801d05 <devpipe_read+0x40>
			if (i > 0)
  801d2d:	85 f6                	test   %esi,%esi
  801d2f:	75 b7                	jne    801ce8 <devpipe_read+0x23>
  801d31:	eb b9                	jmp    801cec <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  801d33:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  801d38:	89 f0                	mov    %esi,%eax
  801d3a:	eb 05                	jmp    801d41 <devpipe_read+0x7c>
				return 0;
  801d3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d41:	83 c4 1c             	add    $0x1c,%esp
  801d44:	5b                   	pop    %ebx
  801d45:	5e                   	pop    %esi
  801d46:	5f                   	pop    %edi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    

00801d49 <pipe>:
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	56                   	push   %esi
  801d4d:	53                   	push   %ebx
  801d4e:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d54:	89 04 24             	mov    %eax,(%esp)
  801d57:	e8 cb f5 ff ff       	call   801327 <fd_alloc>
  801d5c:	89 c2                	mov    %eax,%edx
  801d5e:	85 d2                	test   %edx,%edx
  801d60:	0f 88 4d 01 00 00    	js     801eb3 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d66:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d6d:	00 
  801d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d7c:	e8 48 ef ff ff       	call   800cc9 <sys_page_alloc>
  801d81:	89 c2                	mov    %eax,%edx
  801d83:	85 d2                	test   %edx,%edx
  801d85:	0f 88 28 01 00 00    	js     801eb3 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801d8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d8e:	89 04 24             	mov    %eax,(%esp)
  801d91:	e8 91 f5 ff ff       	call   801327 <fd_alloc>
  801d96:	89 c3                	mov    %eax,%ebx
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	0f 88 fe 00 00 00    	js     801e9e <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801da7:	00 
  801da8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dab:	89 44 24 04          	mov    %eax,0x4(%esp)
  801daf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db6:	e8 0e ef ff ff       	call   800cc9 <sys_page_alloc>
  801dbb:	89 c3                	mov    %eax,%ebx
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	0f 88 d9 00 00 00    	js     801e9e <pipe+0x155>
	va = fd2data(fd0);
  801dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc8:	89 04 24             	mov    %eax,(%esp)
  801dcb:	e8 40 f5 ff ff       	call   801310 <fd2data>
  801dd0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dd9:	00 
  801dda:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dde:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801de5:	e8 df ee ff ff       	call   800cc9 <sys_page_alloc>
  801dea:	89 c3                	mov    %eax,%ebx
  801dec:	85 c0                	test   %eax,%eax
  801dee:	0f 88 97 00 00 00    	js     801e8b <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801df7:	89 04 24             	mov    %eax,(%esp)
  801dfa:	e8 11 f5 ff ff       	call   801310 <fd2data>
  801dff:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e06:	00 
  801e07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e12:	00 
  801e13:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e1e:	e8 fa ee ff ff       	call   800d1d <sys_page_map>
  801e23:	89 c3                	mov    %eax,%ebx
  801e25:	85 c0                	test   %eax,%eax
  801e27:	78 52                	js     801e7b <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801e29:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e32:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e37:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801e3e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e47:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e4c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e56:	89 04 24             	mov    %eax,(%esp)
  801e59:	e8 a2 f4 ff ff       	call   801300 <fd2num>
  801e5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e61:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e66:	89 04 24             	mov    %eax,(%esp)
  801e69:	e8 92 f4 ff ff       	call   801300 <fd2num>
  801e6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e71:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e74:	b8 00 00 00 00       	mov    $0x0,%eax
  801e79:	eb 38                	jmp    801eb3 <pipe+0x16a>
	sys_page_unmap(0, va);
  801e7b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e86:	e8 e5 ee ff ff       	call   800d70 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801e8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e92:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e99:	e8 d2 ee ff ff       	call   800d70 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eac:	e8 bf ee ff ff       	call   800d70 <sys_page_unmap>
  801eb1:	89 d8                	mov    %ebx,%eax
}
  801eb3:	83 c4 30             	add    $0x30,%esp
  801eb6:	5b                   	pop    %ebx
  801eb7:	5e                   	pop    %esi
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    

00801eba <pipeisclosed>:
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eca:	89 04 24             	mov    %eax,(%esp)
  801ecd:	e8 c9 f4 ff ff       	call   80139b <fd_lookup>
  801ed2:	89 c2                	mov    %eax,%edx
  801ed4:	85 d2                	test   %edx,%edx
  801ed6:	78 15                	js     801eed <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edb:	89 04 24             	mov    %eax,(%esp)
  801ede:	e8 2d f4 ff ff       	call   801310 <fd2data>
	return _pipeisclosed(fd, p);
  801ee3:	89 c2                	mov    %eax,%edx
  801ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee8:	e8 de fc ff ff       	call   801bcb <_pipeisclosed>
}
  801eed:	c9                   	leave  
  801eee:	c3                   	ret    
  801eef:	90                   	nop

00801ef0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ef3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef8:	5d                   	pop    %ebp
  801ef9:	c3                   	ret    

00801efa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f00:	c7 44 24 04 8c 2b 80 	movl   $0x802b8c,0x4(%esp)
  801f07:	00 
  801f08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0b:	89 04 24             	mov    %eax,(%esp)
  801f0e:	e8 08 e9 ff ff       	call   80081b <strcpy>
	return 0;
}
  801f13:	b8 00 00 00 00       	mov    $0x0,%eax
  801f18:	c9                   	leave  
  801f19:	c3                   	ret    

00801f1a <devcons_write>:
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	57                   	push   %edi
  801f1e:	56                   	push   %esi
  801f1f:	53                   	push   %ebx
  801f20:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f2a:	74 4a                	je     801f76 <devcons_write+0x5c>
  801f2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f31:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f36:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  801f3c:	8b 75 10             	mov    0x10(%ebp),%esi
  801f3f:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  801f41:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801f44:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f49:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f4c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f50:	03 45 0c             	add    0xc(%ebp),%eax
  801f53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f57:	89 3c 24             	mov    %edi,(%esp)
  801f5a:	e8 b7 ea ff ff       	call   800a16 <memmove>
		sys_cputs(buf, m);
  801f5f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f63:	89 3c 24             	mov    %edi,(%esp)
  801f66:	e8 91 ec ff ff       	call   800bfc <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f6b:	01 f3                	add    %esi,%ebx
  801f6d:	89 d8                	mov    %ebx,%eax
  801f6f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f72:	72 c8                	jb     801f3c <devcons_write+0x22>
  801f74:	eb 05                	jmp    801f7b <devcons_write+0x61>
  801f76:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  801f7b:	89 d8                	mov    %ebx,%eax
  801f7d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801f83:	5b                   	pop    %ebx
  801f84:	5e                   	pop    %esi
  801f85:	5f                   	pop    %edi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    

00801f88 <devcons_read>:
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801f8e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f93:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f97:	75 07                	jne    801fa0 <devcons_read+0x18>
  801f99:	eb 28                	jmp    801fc3 <devcons_read+0x3b>
		sys_yield();
  801f9b:	e8 0a ed ff ff       	call   800caa <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801fa0:	e8 75 ec ff ff       	call   800c1a <sys_cgetc>
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	74 f2                	je     801f9b <devcons_read+0x13>
	if (c < 0)
  801fa9:	85 c0                	test   %eax,%eax
  801fab:	78 16                	js     801fc3 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  801fad:	83 f8 04             	cmp    $0x4,%eax
  801fb0:	74 0c                	je     801fbe <devcons_read+0x36>
	*(char*)vbuf = c;
  801fb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fb5:	88 02                	mov    %al,(%edx)
	return 1;
  801fb7:	b8 01 00 00 00       	mov    $0x1,%eax
  801fbc:	eb 05                	jmp    801fc3 <devcons_read+0x3b>
		return 0;
  801fbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    

00801fc5 <cputchar>:
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fce:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801fd1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fd8:	00 
  801fd9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fdc:	89 04 24             	mov    %eax,(%esp)
  801fdf:	e8 18 ec ff ff       	call   800bfc <sys_cputs>
}
  801fe4:	c9                   	leave  
  801fe5:	c3                   	ret    

00801fe6 <getchar>:
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801fec:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801ff3:	00 
  801ff4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802002:	e8 3f f6 ff ff       	call   801646 <read>
	if (r < 0)
  802007:	85 c0                	test   %eax,%eax
  802009:	78 0f                	js     80201a <getchar+0x34>
	if (r < 1)
  80200b:	85 c0                	test   %eax,%eax
  80200d:	7e 06                	jle    802015 <getchar+0x2f>
	return c;
  80200f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802013:	eb 05                	jmp    80201a <getchar+0x34>
		return -E_EOF;
  802015:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80201a:	c9                   	leave  
  80201b:	c3                   	ret    

0080201c <iscons>:
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802022:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802025:	89 44 24 04          	mov    %eax,0x4(%esp)
  802029:	8b 45 08             	mov    0x8(%ebp),%eax
  80202c:	89 04 24             	mov    %eax,(%esp)
  80202f:	e8 67 f3 ff ff       	call   80139b <fd_lookup>
  802034:	85 c0                	test   %eax,%eax
  802036:	78 11                	js     802049 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  802038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802041:	39 10                	cmp    %edx,(%eax)
  802043:	0f 94 c0             	sete   %al
  802046:	0f b6 c0             	movzbl %al,%eax
}
  802049:	c9                   	leave  
  80204a:	c3                   	ret    

0080204b <opencons>:
{
  80204b:	55                   	push   %ebp
  80204c:	89 e5                	mov    %esp,%ebp
  80204e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802051:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802054:	89 04 24             	mov    %eax,(%esp)
  802057:	e8 cb f2 ff ff       	call   801327 <fd_alloc>
		return r;
  80205c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80205e:	85 c0                	test   %eax,%eax
  802060:	78 40                	js     8020a2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802062:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802069:	00 
  80206a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802071:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802078:	e8 4c ec ff ff       	call   800cc9 <sys_page_alloc>
		return r;
  80207d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80207f:	85 c0                	test   %eax,%eax
  802081:	78 1f                	js     8020a2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  802083:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802089:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80208e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802091:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802098:	89 04 24             	mov    %eax,(%esp)
  80209b:	e8 60 f2 ff ff       	call   801300 <fd2num>
  8020a0:	89 c2                	mov    %eax,%edx
}
  8020a2:	89 d0                	mov    %edx,%eax
  8020a4:	c9                   	leave  
  8020a5:	c3                   	ret    

008020a6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	56                   	push   %esi
  8020aa:	53                   	push   %ebx
  8020ab:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8020ae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8020b1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8020b7:	e8 cf eb ff ff       	call   800c8b <sys_getenvid>
  8020bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020bf:	89 54 24 10          	mov    %edx,0x10(%esp)
  8020c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8020c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8020ca:	89 74 24 08          	mov    %esi,0x8(%esp)
  8020ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d2:	c7 04 24 98 2b 80 00 	movl   $0x802b98,(%esp)
  8020d9:	e8 e5 e0 ff ff       	call   8001c3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8020de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8020e5:	89 04 24             	mov    %eax,(%esp)
  8020e8:	e8 75 e0 ff ff       	call   800162 <vcprintf>
	cprintf("\n");
  8020ed:	c7 04 24 f4 25 80 00 	movl   $0x8025f4,(%esp)
  8020f4:	e8 ca e0 ff ff       	call   8001c3 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8020f9:	cc                   	int3   
  8020fa:	eb fd                	jmp    8020f9 <_panic+0x53>

008020fc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
  8020ff:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802102:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802109:	75 70                	jne    80217b <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  80210b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802112:	00 
  802113:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80211a:	ee 
  80211b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802122:	e8 a2 eb ff ff       	call   800cc9 <sys_page_alloc>
  802127:	85 c0                	test   %eax,%eax
  802129:	79 1c                	jns    802147 <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  80212b:	c7 44 24 08 bc 2b 80 	movl   $0x802bbc,0x8(%esp)
  802132:	00 
  802133:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80213a:	00 
  80213b:	c7 04 24 20 2c 80 00 	movl   $0x802c20,(%esp)
  802142:	e8 5f ff ff ff       	call   8020a6 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802147:	c7 44 24 04 85 21 80 	movl   $0x802185,0x4(%esp)
  80214e:	00 
  80214f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802156:	e8 0e ed ff ff       	call   800e69 <sys_env_set_pgfault_upcall>
  80215b:	85 c0                	test   %eax,%eax
  80215d:	79 1c                	jns    80217b <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  80215f:	c7 44 24 08 e8 2b 80 	movl   $0x802be8,0x8(%esp)
  802166:	00 
  802167:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  80216e:	00 
  80216f:	c7 04 24 20 2c 80 00 	movl   $0x802c20,(%esp)
  802176:	e8 2b ff ff ff       	call   8020a6 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80217b:	8b 45 08             	mov    0x8(%ebp),%eax
  80217e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802183:	c9                   	leave  
  802184:	c3                   	ret    

00802185 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802185:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802186:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80218b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80218d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  802190:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  802194:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  802199:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  80219d:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80219f:	83 c4 08             	add    $0x8,%esp
	popal
  8021a2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8021a3:	83 c4 04             	add    $0x4,%esp
	popfl
  8021a6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8021a7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8021a8:	c3                   	ret    

008021a9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021a9:	55                   	push   %ebp
  8021aa:	89 e5                	mov    %esp,%ebp
  8021ac:	56                   	push   %esi
  8021ad:	53                   	push   %ebx
  8021ae:	83 ec 10             	sub    $0x10,%esp
  8021b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8021b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  8021b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ba:	89 04 24             	mov    %eax,(%esp)
  8021bd:	e8 1d ed ff ff       	call   800edf <sys_ipc_recv>
	if(from_env_store)
  8021c2:	85 f6                	test   %esi,%esi
  8021c4:	74 14                	je     8021da <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  8021c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8021cb:	85 c0                	test   %eax,%eax
  8021cd:	78 09                	js     8021d8 <ipc_recv+0x2f>
  8021cf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8021d5:	8b 52 74             	mov    0x74(%edx),%edx
  8021d8:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  8021da:	85 db                	test   %ebx,%ebx
  8021dc:	74 14                	je     8021f2 <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  8021de:	ba 00 00 00 00       	mov    $0x0,%edx
  8021e3:	85 c0                	test   %eax,%eax
  8021e5:	78 09                	js     8021f0 <ipc_recv+0x47>
  8021e7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8021ed:	8b 52 78             	mov    0x78(%edx),%edx
  8021f0:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  8021f2:	85 c0                	test   %eax,%eax
  8021f4:	78 08                	js     8021fe <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  8021f6:	a1 04 40 80 00       	mov    0x804004,%eax
  8021fb:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021fe:	83 c4 10             	add    $0x10,%esp
  802201:	5b                   	pop    %ebx
  802202:	5e                   	pop    %esi
  802203:	5d                   	pop    %ebp
  802204:	c3                   	ret    

00802205 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
  802208:	57                   	push   %edi
  802209:	56                   	push   %esi
  80220a:	53                   	push   %ebx
  80220b:	83 ec 1c             	sub    $0x1c,%esp
  80220e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802211:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  802214:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  802219:	eb 0c                	jmp    802227 <ipc_send+0x22>
		failed_cnt++;
  80221b:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  80221e:	84 db                	test   %bl,%bl
  802220:	75 05                	jne    802227 <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  802222:	e8 83 ea ff ff       	call   800caa <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  802227:	8b 45 14             	mov    0x14(%ebp),%eax
  80222a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80222e:	8b 45 10             	mov    0x10(%ebp),%eax
  802231:	89 44 24 08          	mov    %eax,0x8(%esp)
  802235:	89 74 24 04          	mov    %esi,0x4(%esp)
  802239:	89 3c 24             	mov    %edi,(%esp)
  80223c:	e8 7b ec ff ff       	call   800ebc <sys_ipc_try_send>
  802241:	85 c0                	test   %eax,%eax
  802243:	78 d6                	js     80221b <ipc_send+0x16>
	}
}
  802245:	83 c4 1c             	add    $0x1c,%esp
  802248:	5b                   	pop    %ebx
  802249:	5e                   	pop    %esi
  80224a:	5f                   	pop    %edi
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    

0080224d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80224d:	55                   	push   %ebp
  80224e:	89 e5                	mov    %esp,%ebp
  802250:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802253:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  802258:	39 c8                	cmp    %ecx,%eax
  80225a:	74 17                	je     802273 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  80225c:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802261:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802264:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80226a:	8b 52 50             	mov    0x50(%edx),%edx
  80226d:	39 ca                	cmp    %ecx,%edx
  80226f:	75 14                	jne    802285 <ipc_find_env+0x38>
  802271:	eb 05                	jmp    802278 <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  802273:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  802278:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80227b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802280:	8b 40 40             	mov    0x40(%eax),%eax
  802283:	eb 0e                	jmp    802293 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  802285:	83 c0 01             	add    $0x1,%eax
  802288:	3d 00 04 00 00       	cmp    $0x400,%eax
  80228d:	75 d2                	jne    802261 <ipc_find_env+0x14>
	return 0;
  80228f:	66 b8 00 00          	mov    $0x0,%ax
}
  802293:	5d                   	pop    %ebp
  802294:	c3                   	ret    

00802295 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802295:	55                   	push   %ebp
  802296:	89 e5                	mov    %esp,%ebp
  802298:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80229b:	89 d0                	mov    %edx,%eax
  80229d:	c1 e8 16             	shr    $0x16,%eax
  8022a0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022a7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8022ac:	f6 c1 01             	test   $0x1,%cl
  8022af:	74 1d                	je     8022ce <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8022b1:	c1 ea 0c             	shr    $0xc,%edx
  8022b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022bb:	f6 c2 01             	test   $0x1,%dl
  8022be:	74 0e                	je     8022ce <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022c0:	c1 ea 0c             	shr    $0xc,%edx
  8022c3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022ca:	ef 
  8022cb:	0f b7 c0             	movzwl %ax,%eax
}
  8022ce:	5d                   	pop    %ebp
  8022cf:	c3                   	ret    

008022d0 <__udivdi3>:
  8022d0:	55                   	push   %ebp
  8022d1:	57                   	push   %edi
  8022d2:	56                   	push   %esi
  8022d3:	83 ec 0c             	sub    $0xc,%esp
  8022d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8022da:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8022de:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8022e2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8022e6:	85 c0                	test   %eax,%eax
  8022e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022ec:	89 ea                	mov    %ebp,%edx
  8022ee:	89 0c 24             	mov    %ecx,(%esp)
  8022f1:	75 2d                	jne    802320 <__udivdi3+0x50>
  8022f3:	39 e9                	cmp    %ebp,%ecx
  8022f5:	77 61                	ja     802358 <__udivdi3+0x88>
  8022f7:	85 c9                	test   %ecx,%ecx
  8022f9:	89 ce                	mov    %ecx,%esi
  8022fb:	75 0b                	jne    802308 <__udivdi3+0x38>
  8022fd:	b8 01 00 00 00       	mov    $0x1,%eax
  802302:	31 d2                	xor    %edx,%edx
  802304:	f7 f1                	div    %ecx
  802306:	89 c6                	mov    %eax,%esi
  802308:	31 d2                	xor    %edx,%edx
  80230a:	89 e8                	mov    %ebp,%eax
  80230c:	f7 f6                	div    %esi
  80230e:	89 c5                	mov    %eax,%ebp
  802310:	89 f8                	mov    %edi,%eax
  802312:	f7 f6                	div    %esi
  802314:	89 ea                	mov    %ebp,%edx
  802316:	83 c4 0c             	add    $0xc,%esp
  802319:	5e                   	pop    %esi
  80231a:	5f                   	pop    %edi
  80231b:	5d                   	pop    %ebp
  80231c:	c3                   	ret    
  80231d:	8d 76 00             	lea    0x0(%esi),%esi
  802320:	39 e8                	cmp    %ebp,%eax
  802322:	77 24                	ja     802348 <__udivdi3+0x78>
  802324:	0f bd e8             	bsr    %eax,%ebp
  802327:	83 f5 1f             	xor    $0x1f,%ebp
  80232a:	75 3c                	jne    802368 <__udivdi3+0x98>
  80232c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802330:	39 34 24             	cmp    %esi,(%esp)
  802333:	0f 86 9f 00 00 00    	jbe    8023d8 <__udivdi3+0x108>
  802339:	39 d0                	cmp    %edx,%eax
  80233b:	0f 82 97 00 00 00    	jb     8023d8 <__udivdi3+0x108>
  802341:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802348:	31 d2                	xor    %edx,%edx
  80234a:	31 c0                	xor    %eax,%eax
  80234c:	83 c4 0c             	add    $0xc,%esp
  80234f:	5e                   	pop    %esi
  802350:	5f                   	pop    %edi
  802351:	5d                   	pop    %ebp
  802352:	c3                   	ret    
  802353:	90                   	nop
  802354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802358:	89 f8                	mov    %edi,%eax
  80235a:	f7 f1                	div    %ecx
  80235c:	31 d2                	xor    %edx,%edx
  80235e:	83 c4 0c             	add    $0xc,%esp
  802361:	5e                   	pop    %esi
  802362:	5f                   	pop    %edi
  802363:	5d                   	pop    %ebp
  802364:	c3                   	ret    
  802365:	8d 76 00             	lea    0x0(%esi),%esi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	8b 3c 24             	mov    (%esp),%edi
  80236d:	d3 e0                	shl    %cl,%eax
  80236f:	89 c6                	mov    %eax,%esi
  802371:	b8 20 00 00 00       	mov    $0x20,%eax
  802376:	29 e8                	sub    %ebp,%eax
  802378:	89 c1                	mov    %eax,%ecx
  80237a:	d3 ef                	shr    %cl,%edi
  80237c:	89 e9                	mov    %ebp,%ecx
  80237e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802382:	8b 3c 24             	mov    (%esp),%edi
  802385:	09 74 24 08          	or     %esi,0x8(%esp)
  802389:	89 d6                	mov    %edx,%esi
  80238b:	d3 e7                	shl    %cl,%edi
  80238d:	89 c1                	mov    %eax,%ecx
  80238f:	89 3c 24             	mov    %edi,(%esp)
  802392:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802396:	d3 ee                	shr    %cl,%esi
  802398:	89 e9                	mov    %ebp,%ecx
  80239a:	d3 e2                	shl    %cl,%edx
  80239c:	89 c1                	mov    %eax,%ecx
  80239e:	d3 ef                	shr    %cl,%edi
  8023a0:	09 d7                	or     %edx,%edi
  8023a2:	89 f2                	mov    %esi,%edx
  8023a4:	89 f8                	mov    %edi,%eax
  8023a6:	f7 74 24 08          	divl   0x8(%esp)
  8023aa:	89 d6                	mov    %edx,%esi
  8023ac:	89 c7                	mov    %eax,%edi
  8023ae:	f7 24 24             	mull   (%esp)
  8023b1:	39 d6                	cmp    %edx,%esi
  8023b3:	89 14 24             	mov    %edx,(%esp)
  8023b6:	72 30                	jb     8023e8 <__udivdi3+0x118>
  8023b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023bc:	89 e9                	mov    %ebp,%ecx
  8023be:	d3 e2                	shl    %cl,%edx
  8023c0:	39 c2                	cmp    %eax,%edx
  8023c2:	73 05                	jae    8023c9 <__udivdi3+0xf9>
  8023c4:	3b 34 24             	cmp    (%esp),%esi
  8023c7:	74 1f                	je     8023e8 <__udivdi3+0x118>
  8023c9:	89 f8                	mov    %edi,%eax
  8023cb:	31 d2                	xor    %edx,%edx
  8023cd:	e9 7a ff ff ff       	jmp    80234c <__udivdi3+0x7c>
  8023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d8:	31 d2                	xor    %edx,%edx
  8023da:	b8 01 00 00 00       	mov    $0x1,%eax
  8023df:	e9 68 ff ff ff       	jmp    80234c <__udivdi3+0x7c>
  8023e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8023eb:	31 d2                	xor    %edx,%edx
  8023ed:	83 c4 0c             	add    $0xc,%esp
  8023f0:	5e                   	pop    %esi
  8023f1:	5f                   	pop    %edi
  8023f2:	5d                   	pop    %ebp
  8023f3:	c3                   	ret    
  8023f4:	66 90                	xchg   %ax,%ax
  8023f6:	66 90                	xchg   %ax,%ax
  8023f8:	66 90                	xchg   %ax,%ax
  8023fa:	66 90                	xchg   %ax,%ax
  8023fc:	66 90                	xchg   %ax,%ax
  8023fe:	66 90                	xchg   %ax,%ax

00802400 <__umoddi3>:
  802400:	55                   	push   %ebp
  802401:	57                   	push   %edi
  802402:	56                   	push   %esi
  802403:	83 ec 14             	sub    $0x14,%esp
  802406:	8b 44 24 28          	mov    0x28(%esp),%eax
  80240a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80240e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802412:	89 c7                	mov    %eax,%edi
  802414:	89 44 24 04          	mov    %eax,0x4(%esp)
  802418:	8b 44 24 30          	mov    0x30(%esp),%eax
  80241c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802420:	89 34 24             	mov    %esi,(%esp)
  802423:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802427:	85 c0                	test   %eax,%eax
  802429:	89 c2                	mov    %eax,%edx
  80242b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80242f:	75 17                	jne    802448 <__umoddi3+0x48>
  802431:	39 fe                	cmp    %edi,%esi
  802433:	76 4b                	jbe    802480 <__umoddi3+0x80>
  802435:	89 c8                	mov    %ecx,%eax
  802437:	89 fa                	mov    %edi,%edx
  802439:	f7 f6                	div    %esi
  80243b:	89 d0                	mov    %edx,%eax
  80243d:	31 d2                	xor    %edx,%edx
  80243f:	83 c4 14             	add    $0x14,%esp
  802442:	5e                   	pop    %esi
  802443:	5f                   	pop    %edi
  802444:	5d                   	pop    %ebp
  802445:	c3                   	ret    
  802446:	66 90                	xchg   %ax,%ax
  802448:	39 f8                	cmp    %edi,%eax
  80244a:	77 54                	ja     8024a0 <__umoddi3+0xa0>
  80244c:	0f bd e8             	bsr    %eax,%ebp
  80244f:	83 f5 1f             	xor    $0x1f,%ebp
  802452:	75 5c                	jne    8024b0 <__umoddi3+0xb0>
  802454:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802458:	39 3c 24             	cmp    %edi,(%esp)
  80245b:	0f 87 e7 00 00 00    	ja     802548 <__umoddi3+0x148>
  802461:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802465:	29 f1                	sub    %esi,%ecx
  802467:	19 c7                	sbb    %eax,%edi
  802469:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80246d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802471:	8b 44 24 08          	mov    0x8(%esp),%eax
  802475:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802479:	83 c4 14             	add    $0x14,%esp
  80247c:	5e                   	pop    %esi
  80247d:	5f                   	pop    %edi
  80247e:	5d                   	pop    %ebp
  80247f:	c3                   	ret    
  802480:	85 f6                	test   %esi,%esi
  802482:	89 f5                	mov    %esi,%ebp
  802484:	75 0b                	jne    802491 <__umoddi3+0x91>
  802486:	b8 01 00 00 00       	mov    $0x1,%eax
  80248b:	31 d2                	xor    %edx,%edx
  80248d:	f7 f6                	div    %esi
  80248f:	89 c5                	mov    %eax,%ebp
  802491:	8b 44 24 04          	mov    0x4(%esp),%eax
  802495:	31 d2                	xor    %edx,%edx
  802497:	f7 f5                	div    %ebp
  802499:	89 c8                	mov    %ecx,%eax
  80249b:	f7 f5                	div    %ebp
  80249d:	eb 9c                	jmp    80243b <__umoddi3+0x3b>
  80249f:	90                   	nop
  8024a0:	89 c8                	mov    %ecx,%eax
  8024a2:	89 fa                	mov    %edi,%edx
  8024a4:	83 c4 14             	add    $0x14,%esp
  8024a7:	5e                   	pop    %esi
  8024a8:	5f                   	pop    %edi
  8024a9:	5d                   	pop    %ebp
  8024aa:	c3                   	ret    
  8024ab:	90                   	nop
  8024ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	8b 04 24             	mov    (%esp),%eax
  8024b3:	be 20 00 00 00       	mov    $0x20,%esi
  8024b8:	89 e9                	mov    %ebp,%ecx
  8024ba:	29 ee                	sub    %ebp,%esi
  8024bc:	d3 e2                	shl    %cl,%edx
  8024be:	89 f1                	mov    %esi,%ecx
  8024c0:	d3 e8                	shr    %cl,%eax
  8024c2:	89 e9                	mov    %ebp,%ecx
  8024c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c8:	8b 04 24             	mov    (%esp),%eax
  8024cb:	09 54 24 04          	or     %edx,0x4(%esp)
  8024cf:	89 fa                	mov    %edi,%edx
  8024d1:	d3 e0                	shl    %cl,%eax
  8024d3:	89 f1                	mov    %esi,%ecx
  8024d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8024dd:	d3 ea                	shr    %cl,%edx
  8024df:	89 e9                	mov    %ebp,%ecx
  8024e1:	d3 e7                	shl    %cl,%edi
  8024e3:	89 f1                	mov    %esi,%ecx
  8024e5:	d3 e8                	shr    %cl,%eax
  8024e7:	89 e9                	mov    %ebp,%ecx
  8024e9:	09 f8                	or     %edi,%eax
  8024eb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8024ef:	f7 74 24 04          	divl   0x4(%esp)
  8024f3:	d3 e7                	shl    %cl,%edi
  8024f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024f9:	89 d7                	mov    %edx,%edi
  8024fb:	f7 64 24 08          	mull   0x8(%esp)
  8024ff:	39 d7                	cmp    %edx,%edi
  802501:	89 c1                	mov    %eax,%ecx
  802503:	89 14 24             	mov    %edx,(%esp)
  802506:	72 2c                	jb     802534 <__umoddi3+0x134>
  802508:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80250c:	72 22                	jb     802530 <__umoddi3+0x130>
  80250e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802512:	29 c8                	sub    %ecx,%eax
  802514:	19 d7                	sbb    %edx,%edi
  802516:	89 e9                	mov    %ebp,%ecx
  802518:	89 fa                	mov    %edi,%edx
  80251a:	d3 e8                	shr    %cl,%eax
  80251c:	89 f1                	mov    %esi,%ecx
  80251e:	d3 e2                	shl    %cl,%edx
  802520:	89 e9                	mov    %ebp,%ecx
  802522:	d3 ef                	shr    %cl,%edi
  802524:	09 d0                	or     %edx,%eax
  802526:	89 fa                	mov    %edi,%edx
  802528:	83 c4 14             	add    $0x14,%esp
  80252b:	5e                   	pop    %esi
  80252c:	5f                   	pop    %edi
  80252d:	5d                   	pop    %ebp
  80252e:	c3                   	ret    
  80252f:	90                   	nop
  802530:	39 d7                	cmp    %edx,%edi
  802532:	75 da                	jne    80250e <__umoddi3+0x10e>
  802534:	8b 14 24             	mov    (%esp),%edx
  802537:	89 c1                	mov    %eax,%ecx
  802539:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80253d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802541:	eb cb                	jmp    80250e <__umoddi3+0x10e>
  802543:	90                   	nop
  802544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802548:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80254c:	0f 82 0f ff ff ff    	jb     802461 <__umoddi3+0x61>
  802552:	e9 1a ff ff ff       	jmp    802471 <__umoddi3+0x71>
