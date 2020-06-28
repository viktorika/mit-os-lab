
obj/user/spin：     文件格式 elf32-i386


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
  800047:	c7 04 24 00 16 80 00 	movl   $0x801600,(%esp)
  80004e:	e8 6b 01 00 00       	call   8001be <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 c3 0f 00 00       	call   80101b <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 78 16 80 00 	movl   $0x801678,(%esp)
  800065:	e8 54 01 00 00       	call   8001be <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 28 16 80 00 	movl   $0x801628,(%esp)
  800073:	e8 46 01 00 00       	call   8001be <cprintf>
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
  8000a5:	c7 04 24 50 16 80 00 	movl   $0x801650,(%esp)
  8000ac:	e8 0d 01 00 00       	call   8001be <cprintf>
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
  8000df:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e4:	85 db                	test   %ebx,%ebx
  8000e6:	7e 07                	jle    8000ef <libmain+0x30>
		binaryname = argv[0];
  8000e8:	8b 06                	mov    (%esi),%eax
  8000ea:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  80010d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800114:	e8 20 0b 00 00       	call   800c39 <sys_env_destroy>
}
  800119:	c9                   	leave  
  80011a:	c3                   	ret    

0080011b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	53                   	push   %ebx
  80011f:	83 ec 14             	sub    $0x14,%esp
  800122:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800125:	8b 13                	mov    (%ebx),%edx
  800127:	8d 42 01             	lea    0x1(%edx),%eax
  80012a:	89 03                	mov    %eax,(%ebx)
  80012c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800133:	3d ff 00 00 00       	cmp    $0xff,%eax
  800138:	75 19                	jne    800153 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80013a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800141:	00 
  800142:	8d 43 08             	lea    0x8(%ebx),%eax
  800145:	89 04 24             	mov    %eax,(%esp)
  800148:	e8 af 0a 00 00       	call   800bfc <sys_cputs>
		b->idx = 0;
  80014d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800153:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800157:	83 c4 14             	add    $0x14,%esp
  80015a:	5b                   	pop    %ebx
  80015b:	5d                   	pop    %ebp
  80015c:	c3                   	ret    

0080015d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800166:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016d:	00 00 00 
	b.cnt = 0;
  800170:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800177:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800181:	8b 45 08             	mov    0x8(%ebp),%eax
  800184:	89 44 24 08          	mov    %eax,0x8(%esp)
  800188:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800192:	c7 04 24 1b 01 80 00 	movl   $0x80011b,(%esp)
  800199:	e8 b6 01 00 00       	call   800354 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ae:	89 04 24             	mov    %eax,(%esp)
  8001b1:	e8 46 0a 00 00       	call   800bfc <sys_cputs>

	return b.cnt;
}
  8001b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ce:	89 04 24             	mov    %eax,(%esp)
  8001d1:	e8 87 ff ff ff       	call   80015d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    
  8001d8:	66 90                	xchg   %ax,%ax
  8001da:	66 90                	xchg   %ax,%ax
  8001dc:	66 90                	xchg   %ax,%ax
  8001de:	66 90                	xchg   %ax,%ax

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
  80025c:	e8 ff 10 00 00       	call   801360 <__udivdi3>
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
  8002b5:	e8 d6 11 00 00       	call   801490 <__umoddi3>
  8002ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002be:	0f be 80 a0 16 80 00 	movsbl 0x8016a0(%eax),%eax
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
  8003dc:	ff 24 85 60 17 80 00 	jmp    *0x801760(,%eax,4)
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
  80048a:	83 f8 08             	cmp    $0x8,%eax
  80048d:	7f 0b                	jg     80049a <vprintfmt+0x146>
  80048f:	8b 14 85 c0 18 80 00 	mov    0x8018c0(,%eax,4),%edx
  800496:	85 d2                	test   %edx,%edx
  800498:	75 20                	jne    8004ba <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80049a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049e:	c7 44 24 08 b8 16 80 	movl   $0x8016b8,0x8(%esp)
  8004a5:	00 
  8004a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ad:	89 04 24             	mov    %eax,(%esp)
  8004b0:	e8 77 fe ff ff       	call   80032c <printfmt>
  8004b5:	e9 c3 fe ff ff       	jmp    80037d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  8004ba:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004be:	c7 44 24 08 c1 16 80 	movl   $0x8016c1,0x8(%esp)
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
  8004ed:	ba b1 16 80 00       	mov    $0x8016b1,%edx
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
  800c67:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800c6e:	00 
  800c6f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c76:	00 
  800c77:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800c7e:	e8 d1 05 00 00       	call   801254 <_panic>
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
  800cb5:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800cf9:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800d00:	00 
  800d01:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d08:	00 
  800d09:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800d10:	e8 3f 05 00 00       	call   801254 <_panic>
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
  800d4c:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800d53:	00 
  800d54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d5b:	00 
  800d5c:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800d63:	e8 ec 04 00 00       	call   801254 <_panic>
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
  800d9f:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800da6:	00 
  800da7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dae:	00 
  800daf:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800db6:	e8 99 04 00 00       	call   801254 <_panic>
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
  800df2:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800df9:	00 
  800dfa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e01:	00 
  800e02:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800e09:	e8 46 04 00 00       	call   801254 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e0e:	83 c4 2c             	add    $0x2c,%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800e37:	7e 28                	jle    800e61 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e44:	00 
  800e45:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800e4c:	00 
  800e4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e54:	00 
  800e55:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800e5c:	e8 f3 03 00 00       	call   801254 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e61:	83 c4 2c             	add    $0x2c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	57                   	push   %edi
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e6f:	be 00 00 00 00       	mov    $0x0,%esi
  800e74:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e85:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e87:	5b                   	pop    %ebx
  800e88:	5e                   	pop    %esi
  800e89:	5f                   	pop    %edi
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	57                   	push   %edi
  800e90:	56                   	push   %esi
  800e91:	53                   	push   %ebx
  800e92:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e9a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	89 cb                	mov    %ecx,%ebx
  800ea4:	89 cf                	mov    %ecx,%edi
  800ea6:	89 ce                	mov    %ecx,%esi
  800ea8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	7e 28                	jle    800ed6 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eae:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb2:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800eb9:	00 
  800eba:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800ec1:	00 
  800ec2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec9:	00 
  800eca:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800ed1:	e8 7e 03 00 00       	call   801254 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ed6:	83 c4 2c             	add    $0x2c,%esp
  800ed9:	5b                   	pop    %ebx
  800eda:	5e                   	pop    %esi
  800edb:	5f                   	pop    %edi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	53                   	push   %ebx
  800ee2:	83 ec 24             	sub    $0x24,%esp
  800ee5:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800ee8:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800eea:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800eee:	74 2e                	je     800f1e <pgfault+0x40>
  800ef0:	89 c2                	mov    %eax,%edx
  800ef2:	c1 ea 16             	shr    $0x16,%edx
  800ef5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800efc:	f6 c2 01             	test   $0x1,%dl
  800eff:	74 1d                	je     800f1e <pgfault+0x40>
  800f01:	89 c2                	mov    %eax,%edx
  800f03:	c1 ea 0c             	shr    $0xc,%edx
  800f06:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f0d:	f6 c1 01             	test   $0x1,%cl
  800f10:	74 0c                	je     800f1e <pgfault+0x40>
  800f12:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f19:	f6 c6 08             	test   $0x8,%dh
  800f1c:	75 20                	jne    800f3e <pgfault+0x60>
		panic("pgfault: page cow check failed, addr=%x\n", addr);
  800f1e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f22:	c7 44 24 08 10 19 80 	movl   $0x801910,0x8(%esp)
  800f29:	00 
  800f2a:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800f31:	00 
  800f32:	c7 04 24 cf 19 80 00 	movl   $0x8019cf,(%esp)
  800f39:	e8 16 03 00 00       	call   801254 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800f3e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f43:	89 c3                	mov    %eax,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W))
  800f45:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f54:	00 
  800f55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f5c:	e8 68 fd ff ff       	call   800cc9 <sys_page_alloc>
  800f61:	85 c0                	test   %eax,%eax
  800f63:	74 1c                	je     800f81 <pgfault+0xa3>
		panic("pgfault: sys_page_alloc error");
  800f65:	c7 44 24 08 da 19 80 	movl   $0x8019da,0x8(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800f74:	00 
  800f75:	c7 04 24 cf 19 80 00 	movl   $0x8019cf,(%esp)
  800f7c:	e8 d3 02 00 00       	call   801254 <_panic>

	memmove(PFTEMP, addr, PGSIZE);
  800f81:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f88:	00 
  800f89:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f8d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f94:	e8 7d fa ff ff       	call   800a16 <memmove>
	if(sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))
  800f99:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fa0:	00 
  800fa1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fa5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fac:	00 
  800fad:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fb4:	00 
  800fb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fbc:	e8 5c fd ff ff       	call   800d1d <sys_page_map>
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	74 1c                	je     800fe1 <pgfault+0x103>
		panic("pgfault: sys_page_map error");
  800fc5:	c7 44 24 08 f8 19 80 	movl   $0x8019f8,0x8(%esp)
  800fcc:	00 
  800fcd:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800fd4:	00 
  800fd5:	c7 04 24 cf 19 80 00 	movl   $0x8019cf,(%esp)
  800fdc:	e8 73 02 00 00       	call   801254 <_panic>

	if(sys_page_unmap(0, PFTEMP))
  800fe1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fe8:	00 
  800fe9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ff0:	e8 7b fd ff ff       	call   800d70 <sys_page_unmap>
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	74 1c                	je     801015 <pgfault+0x137>
		panic("pgfault: sys_page_unmap error");
  800ff9:	c7 44 24 08 14 1a 80 	movl   $0x801a14,0x8(%esp)
  801000:	00 
  801001:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801008:	00 
  801009:	c7 04 24 cf 19 80 00 	movl   $0x8019cf,(%esp)
  801010:	e8 3f 02 00 00       	call   801254 <_panic>
}
  801015:	83 c4 24             	add    $0x24,%esp
  801018:	5b                   	pop    %ebx
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    

0080101b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
  801021:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	//根据文档的描述，duppage好像不应该处理除了可写或者copy-on-write的部分，但这里都交给duppage一块处理了
	set_pgfault_handler(pgfault);
  801024:	c7 04 24 de 0e 80 00 	movl   $0x800ede,(%esp)
  80102b:	e8 7a 02 00 00       	call   8012aa <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801030:	b8 07 00 00 00       	mov    $0x7,%eax
  801035:	cd 30                	int    $0x30
  801037:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();
	if(envid < 0)
  80103a:	85 c0                	test   %eax,%eax
  80103c:	79 1c                	jns    80105a <fork+0x3f>
		//失败
		panic("fork: sys_exofork error");
  80103e:	c7 44 24 08 32 1a 80 	movl   $0x801a32,0x8(%esp)
  801045:	00 
  801046:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  80104d:	00 
  80104e:	c7 04 24 cf 19 80 00 	movl   $0x8019cf,(%esp)
  801055:	e8 fa 01 00 00       	call   801254 <_panic>
  80105a:	89 c7                	mov    %eax,%edi
	else if(!envid)
  80105c:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801061:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801065:	75 1c                	jne    801083 <fork+0x68>
		//子进程
		thisenv = &envs[ENVX(sys_getenvid())];
  801067:	e8 1f fc ff ff       	call   800c8b <sys_getenvid>
  80106c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801071:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801079:	a3 04 20 80 00       	mov    %eax,0x802004
  80107e:	e9 a4 01 00 00       	jmp    801227 <fork+0x20c>
	else{
		//父进程
		unsigned addr;
		for(addr = UTEXT; addr < USTACKTOP; addr+= PGSIZE){
			if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))
  801083:	89 d8                	mov    %ebx,%eax
  801085:	c1 e8 16             	shr    $0x16,%eax
  801088:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80108f:	a8 01                	test   $0x1,%al
  801091:	0f 84 00 01 00 00    	je     801197 <fork+0x17c>
  801097:	89 d8                	mov    %ebx,%eax
  801099:	c1 e8 0c             	shr    $0xc,%eax
  80109c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010a3:	f6 c2 01             	test   $0x1,%dl
  8010a6:	0f 84 eb 00 00 00    	je     801197 <fork+0x17c>
  8010ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b3:	f6 c2 04             	test   $0x4,%dl
  8010b6:	0f 84 db 00 00 00    	je     801197 <fork+0x17c>
	void *addr = (void *)(pn * PGSIZE);
  8010bc:	89 c6                	mov    %eax,%esi
  8010be:	c1 e6 0c             	shl    $0xc,%esi
	if(uvpt[pn] & (PTE_W | PTE_COW)){
  8010c1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c8:	a9 02 08 00 00       	test   $0x802,%eax
  8010cd:	0f 84 84 00 00 00    	je     801157 <fork+0x13c>
		if(sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P))
  8010d3:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010da:	00 
  8010db:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010df:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ee:	e8 2a fc ff ff       	call   800d1d <sys_page_map>
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	74 1c                	je     801113 <fork+0xf8>
			panic("duppage: sys_page_map child error");
  8010f7:	c7 44 24 08 3c 19 80 	movl   $0x80193c,0x8(%esp)
  8010fe:	00 
  8010ff:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801106:	00 
  801107:	c7 04 24 cf 19 80 00 	movl   $0x8019cf,(%esp)
  80110e:	e8 41 01 00 00       	call   801254 <_panic>
		if(sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P))
  801113:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80111a:	00 
  80111b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80111f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801126:	00 
  801127:	89 74 24 04          	mov    %esi,0x4(%esp)
  80112b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801132:	e8 e6 fb ff ff       	call   800d1d <sys_page_map>
  801137:	85 c0                	test   %eax,%eax
  801139:	74 5c                	je     801197 <fork+0x17c>
			panic("duppage: sys_page_map remap parent error");
  80113b:	c7 44 24 08 60 19 80 	movl   $0x801960,0x8(%esp)
  801142:	00 
  801143:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  80114a:	00 
  80114b:	c7 04 24 cf 19 80 00 	movl   $0x8019cf,(%esp)
  801152:	e8 fd 00 00 00       	call   801254 <_panic>
		if(sys_page_map(0, addr, envid, addr, PTE_U|PTE_P))
  801157:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80115e:	00 
  80115f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801163:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801167:	89 74 24 04          	mov    %esi,0x4(%esp)
  80116b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801172:	e8 a6 fb ff ff       	call   800d1d <sys_page_map>
  801177:	85 c0                	test   %eax,%eax
  801179:	74 1c                	je     801197 <fork+0x17c>
			panic("duppage: other sys_page_map error");
  80117b:	c7 44 24 08 8c 19 80 	movl   $0x80198c,0x8(%esp)
  801182:	00 
  801183:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  80118a:	00 
  80118b:	c7 04 24 cf 19 80 00 	movl   $0x8019cf,(%esp)
  801192:	e8 bd 00 00 00       	call   801254 <_panic>
		for(addr = UTEXT; addr < USTACKTOP; addr+= PGSIZE){
  801197:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80119d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011a3:	0f 85 da fe ff ff    	jne    801083 <fork+0x68>
				duppage(envid, PGNUM(addr));
		}
		if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W))
  8011a9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011b0:	00 
  8011b1:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011b8:	ee 
  8011b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011bc:	89 04 24             	mov    %eax,(%esp)
  8011bf:	e8 05 fb ff ff       	call   800cc9 <sys_page_alloc>
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	74 1c                	je     8011e4 <fork+0x1c9>
			panic("fork: sys_page_alloc error");
  8011c8:	c7 44 24 08 4a 1a 80 	movl   $0x801a4a,0x8(%esp)
  8011cf:	00 
  8011d0:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  8011d7:	00 
  8011d8:	c7 04 24 cf 19 80 00 	movl   $0x8019cf,(%esp)
  8011df:	e8 70 00 00 00       	call   801254 <_panic>
		extern void _pgfault_upcall();
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011e4:	c7 44 24 04 33 13 80 	movl   $0x801333,0x4(%esp)
  8011eb:	00 
  8011ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8011ef:	89 3c 24             	mov    %edi,(%esp)
  8011f2:	e8 1f fc ff ff       	call   800e16 <sys_env_set_pgfault_upcall>
		if(sys_env_set_status(envid, ENV_RUNNABLE))
  8011f7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011fe:	00 
  8011ff:	89 3c 24             	mov    %edi,(%esp)
  801202:	e8 bc fb ff ff       	call   800dc3 <sys_env_set_status>
  801207:	85 c0                	test   %eax,%eax
  801209:	74 1c                	je     801227 <fork+0x20c>
			panic("fork: sys_env_set_status error");
  80120b:	c7 44 24 08 b0 19 80 	movl   $0x8019b0,0x8(%esp)
  801212:	00 
  801213:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  80121a:	00 
  80121b:	c7 04 24 cf 19 80 00 	movl   $0x8019cf,(%esp)
  801222:	e8 2d 00 00 00       	call   801254 <_panic>
	}
	return envid;
}
  801227:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80122a:	83 c4 2c             	add    $0x2c,%esp
  80122d:	5b                   	pop    %ebx
  80122e:	5e                   	pop    %esi
  80122f:	5f                   	pop    %edi
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <sfork>:

// Challenge!
int
sfork(void)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801238:	c7 44 24 08 65 1a 80 	movl   $0x801a65,0x8(%esp)
  80123f:	00 
  801240:	c7 44 24 04 87 00 00 	movl   $0x87,0x4(%esp)
  801247:	00 
  801248:	c7 04 24 cf 19 80 00 	movl   $0x8019cf,(%esp)
  80124f:	e8 00 00 00 00       	call   801254 <_panic>

00801254 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	56                   	push   %esi
  801258:	53                   	push   %ebx
  801259:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80125c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80125f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801265:	e8 21 fa ff ff       	call   800c8b <sys_getenvid>
  80126a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801271:	8b 55 08             	mov    0x8(%ebp),%edx
  801274:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801278:	89 74 24 08          	mov    %esi,0x8(%esp)
  80127c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801280:	c7 04 24 7c 1a 80 00 	movl   $0x801a7c,(%esp)
  801287:	e8 32 ef ff ff       	call   8001be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80128c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801290:	8b 45 10             	mov    0x10(%ebp),%eax
  801293:	89 04 24             	mov    %eax,(%esp)
  801296:	e8 c2 ee ff ff       	call   80015d <vcprintf>
	cprintf("\n");
  80129b:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  8012a2:	e8 17 ef ff ff       	call   8001be <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012a7:	cc                   	int3   
  8012a8:	eb fd                	jmp    8012a7 <_panic+0x53>

008012aa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012b0:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8012b7:	75 70                	jne    801329 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  8012b9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012c0:	00 
  8012c1:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012c8:	ee 
  8012c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d0:	e8 f4 f9 ff ff       	call   800cc9 <sys_page_alloc>
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	79 1c                	jns    8012f5 <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  8012d9:	c7 44 24 08 a0 1a 80 	movl   $0x801aa0,0x8(%esp)
  8012e0:	00 
  8012e1:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8012e8:	00 
  8012e9:	c7 04 24 04 1b 80 00 	movl   $0x801b04,(%esp)
  8012f0:	e8 5f ff ff ff       	call   801254 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8012f5:	c7 44 24 04 33 13 80 	movl   $0x801333,0x4(%esp)
  8012fc:	00 
  8012fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801304:	e8 0d fb ff ff       	call   800e16 <sys_env_set_pgfault_upcall>
  801309:	85 c0                	test   %eax,%eax
  80130b:	79 1c                	jns    801329 <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  80130d:	c7 44 24 08 cc 1a 80 	movl   $0x801acc,0x8(%esp)
  801314:	00 
  801315:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  80131c:	00 
  80131d:	c7 04 24 04 1b 80 00 	movl   $0x801b04,(%esp)
  801324:	e8 2b ff ff ff       	call   801254 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801329:	8b 45 08             	mov    0x8(%ebp),%eax
  80132c:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801331:	c9                   	leave  
  801332:	c3                   	ret    

00801333 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801333:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801334:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801339:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80133b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  80133e:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  801342:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  801347:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  80134b:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80134d:	83 c4 08             	add    $0x8,%esp
	popal
  801350:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801351:	83 c4 04             	add    $0x4,%esp
	popfl
  801354:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801355:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801356:	c3                   	ret    
  801357:	66 90                	xchg   %ax,%ax
  801359:	66 90                	xchg   %ax,%ax
  80135b:	66 90                	xchg   %ax,%ax
  80135d:	66 90                	xchg   %ax,%ax
  80135f:	90                   	nop

00801360 <__udivdi3>:
  801360:	55                   	push   %ebp
  801361:	57                   	push   %edi
  801362:	56                   	push   %esi
  801363:	83 ec 0c             	sub    $0xc,%esp
  801366:	8b 44 24 28          	mov    0x28(%esp),%eax
  80136a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80136e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801372:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801376:	85 c0                	test   %eax,%eax
  801378:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80137c:	89 ea                	mov    %ebp,%edx
  80137e:	89 0c 24             	mov    %ecx,(%esp)
  801381:	75 2d                	jne    8013b0 <__udivdi3+0x50>
  801383:	39 e9                	cmp    %ebp,%ecx
  801385:	77 61                	ja     8013e8 <__udivdi3+0x88>
  801387:	85 c9                	test   %ecx,%ecx
  801389:	89 ce                	mov    %ecx,%esi
  80138b:	75 0b                	jne    801398 <__udivdi3+0x38>
  80138d:	b8 01 00 00 00       	mov    $0x1,%eax
  801392:	31 d2                	xor    %edx,%edx
  801394:	f7 f1                	div    %ecx
  801396:	89 c6                	mov    %eax,%esi
  801398:	31 d2                	xor    %edx,%edx
  80139a:	89 e8                	mov    %ebp,%eax
  80139c:	f7 f6                	div    %esi
  80139e:	89 c5                	mov    %eax,%ebp
  8013a0:	89 f8                	mov    %edi,%eax
  8013a2:	f7 f6                	div    %esi
  8013a4:	89 ea                	mov    %ebp,%edx
  8013a6:	83 c4 0c             	add    $0xc,%esp
  8013a9:	5e                   	pop    %esi
  8013aa:	5f                   	pop    %edi
  8013ab:	5d                   	pop    %ebp
  8013ac:	c3                   	ret    
  8013ad:	8d 76 00             	lea    0x0(%esi),%esi
  8013b0:	39 e8                	cmp    %ebp,%eax
  8013b2:	77 24                	ja     8013d8 <__udivdi3+0x78>
  8013b4:	0f bd e8             	bsr    %eax,%ebp
  8013b7:	83 f5 1f             	xor    $0x1f,%ebp
  8013ba:	75 3c                	jne    8013f8 <__udivdi3+0x98>
  8013bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8013c0:	39 34 24             	cmp    %esi,(%esp)
  8013c3:	0f 86 9f 00 00 00    	jbe    801468 <__udivdi3+0x108>
  8013c9:	39 d0                	cmp    %edx,%eax
  8013cb:	0f 82 97 00 00 00    	jb     801468 <__udivdi3+0x108>
  8013d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013d8:	31 d2                	xor    %edx,%edx
  8013da:	31 c0                	xor    %eax,%eax
  8013dc:	83 c4 0c             	add    $0xc,%esp
  8013df:	5e                   	pop    %esi
  8013e0:	5f                   	pop    %edi
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    
  8013e3:	90                   	nop
  8013e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013e8:	89 f8                	mov    %edi,%eax
  8013ea:	f7 f1                	div    %ecx
  8013ec:	31 d2                	xor    %edx,%edx
  8013ee:	83 c4 0c             	add    $0xc,%esp
  8013f1:	5e                   	pop    %esi
  8013f2:	5f                   	pop    %edi
  8013f3:	5d                   	pop    %ebp
  8013f4:	c3                   	ret    
  8013f5:	8d 76 00             	lea    0x0(%esi),%esi
  8013f8:	89 e9                	mov    %ebp,%ecx
  8013fa:	8b 3c 24             	mov    (%esp),%edi
  8013fd:	d3 e0                	shl    %cl,%eax
  8013ff:	89 c6                	mov    %eax,%esi
  801401:	b8 20 00 00 00       	mov    $0x20,%eax
  801406:	29 e8                	sub    %ebp,%eax
  801408:	89 c1                	mov    %eax,%ecx
  80140a:	d3 ef                	shr    %cl,%edi
  80140c:	89 e9                	mov    %ebp,%ecx
  80140e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801412:	8b 3c 24             	mov    (%esp),%edi
  801415:	09 74 24 08          	or     %esi,0x8(%esp)
  801419:	89 d6                	mov    %edx,%esi
  80141b:	d3 e7                	shl    %cl,%edi
  80141d:	89 c1                	mov    %eax,%ecx
  80141f:	89 3c 24             	mov    %edi,(%esp)
  801422:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801426:	d3 ee                	shr    %cl,%esi
  801428:	89 e9                	mov    %ebp,%ecx
  80142a:	d3 e2                	shl    %cl,%edx
  80142c:	89 c1                	mov    %eax,%ecx
  80142e:	d3 ef                	shr    %cl,%edi
  801430:	09 d7                	or     %edx,%edi
  801432:	89 f2                	mov    %esi,%edx
  801434:	89 f8                	mov    %edi,%eax
  801436:	f7 74 24 08          	divl   0x8(%esp)
  80143a:	89 d6                	mov    %edx,%esi
  80143c:	89 c7                	mov    %eax,%edi
  80143e:	f7 24 24             	mull   (%esp)
  801441:	39 d6                	cmp    %edx,%esi
  801443:	89 14 24             	mov    %edx,(%esp)
  801446:	72 30                	jb     801478 <__udivdi3+0x118>
  801448:	8b 54 24 04          	mov    0x4(%esp),%edx
  80144c:	89 e9                	mov    %ebp,%ecx
  80144e:	d3 e2                	shl    %cl,%edx
  801450:	39 c2                	cmp    %eax,%edx
  801452:	73 05                	jae    801459 <__udivdi3+0xf9>
  801454:	3b 34 24             	cmp    (%esp),%esi
  801457:	74 1f                	je     801478 <__udivdi3+0x118>
  801459:	89 f8                	mov    %edi,%eax
  80145b:	31 d2                	xor    %edx,%edx
  80145d:	e9 7a ff ff ff       	jmp    8013dc <__udivdi3+0x7c>
  801462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801468:	31 d2                	xor    %edx,%edx
  80146a:	b8 01 00 00 00       	mov    $0x1,%eax
  80146f:	e9 68 ff ff ff       	jmp    8013dc <__udivdi3+0x7c>
  801474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801478:	8d 47 ff             	lea    -0x1(%edi),%eax
  80147b:	31 d2                	xor    %edx,%edx
  80147d:	83 c4 0c             	add    $0xc,%esp
  801480:	5e                   	pop    %esi
  801481:	5f                   	pop    %edi
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    
  801484:	66 90                	xchg   %ax,%ax
  801486:	66 90                	xchg   %ax,%ax
  801488:	66 90                	xchg   %ax,%ax
  80148a:	66 90                	xchg   %ax,%ax
  80148c:	66 90                	xchg   %ax,%ax
  80148e:	66 90                	xchg   %ax,%ax

00801490 <__umoddi3>:
  801490:	55                   	push   %ebp
  801491:	57                   	push   %edi
  801492:	56                   	push   %esi
  801493:	83 ec 14             	sub    $0x14,%esp
  801496:	8b 44 24 28          	mov    0x28(%esp),%eax
  80149a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80149e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8014a2:	89 c7                	mov    %eax,%edi
  8014a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8014ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8014b0:	89 34 24             	mov    %esi,(%esp)
  8014b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	89 c2                	mov    %eax,%edx
  8014bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014bf:	75 17                	jne    8014d8 <__umoddi3+0x48>
  8014c1:	39 fe                	cmp    %edi,%esi
  8014c3:	76 4b                	jbe    801510 <__umoddi3+0x80>
  8014c5:	89 c8                	mov    %ecx,%eax
  8014c7:	89 fa                	mov    %edi,%edx
  8014c9:	f7 f6                	div    %esi
  8014cb:	89 d0                	mov    %edx,%eax
  8014cd:	31 d2                	xor    %edx,%edx
  8014cf:	83 c4 14             	add    $0x14,%esp
  8014d2:	5e                   	pop    %esi
  8014d3:	5f                   	pop    %edi
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    
  8014d6:	66 90                	xchg   %ax,%ax
  8014d8:	39 f8                	cmp    %edi,%eax
  8014da:	77 54                	ja     801530 <__umoddi3+0xa0>
  8014dc:	0f bd e8             	bsr    %eax,%ebp
  8014df:	83 f5 1f             	xor    $0x1f,%ebp
  8014e2:	75 5c                	jne    801540 <__umoddi3+0xb0>
  8014e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8014e8:	39 3c 24             	cmp    %edi,(%esp)
  8014eb:	0f 87 e7 00 00 00    	ja     8015d8 <__umoddi3+0x148>
  8014f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014f5:	29 f1                	sub    %esi,%ecx
  8014f7:	19 c7                	sbb    %eax,%edi
  8014f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801501:	8b 44 24 08          	mov    0x8(%esp),%eax
  801505:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801509:	83 c4 14             	add    $0x14,%esp
  80150c:	5e                   	pop    %esi
  80150d:	5f                   	pop    %edi
  80150e:	5d                   	pop    %ebp
  80150f:	c3                   	ret    
  801510:	85 f6                	test   %esi,%esi
  801512:	89 f5                	mov    %esi,%ebp
  801514:	75 0b                	jne    801521 <__umoddi3+0x91>
  801516:	b8 01 00 00 00       	mov    $0x1,%eax
  80151b:	31 d2                	xor    %edx,%edx
  80151d:	f7 f6                	div    %esi
  80151f:	89 c5                	mov    %eax,%ebp
  801521:	8b 44 24 04          	mov    0x4(%esp),%eax
  801525:	31 d2                	xor    %edx,%edx
  801527:	f7 f5                	div    %ebp
  801529:	89 c8                	mov    %ecx,%eax
  80152b:	f7 f5                	div    %ebp
  80152d:	eb 9c                	jmp    8014cb <__umoddi3+0x3b>
  80152f:	90                   	nop
  801530:	89 c8                	mov    %ecx,%eax
  801532:	89 fa                	mov    %edi,%edx
  801534:	83 c4 14             	add    $0x14,%esp
  801537:	5e                   	pop    %esi
  801538:	5f                   	pop    %edi
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    
  80153b:	90                   	nop
  80153c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801540:	8b 04 24             	mov    (%esp),%eax
  801543:	be 20 00 00 00       	mov    $0x20,%esi
  801548:	89 e9                	mov    %ebp,%ecx
  80154a:	29 ee                	sub    %ebp,%esi
  80154c:	d3 e2                	shl    %cl,%edx
  80154e:	89 f1                	mov    %esi,%ecx
  801550:	d3 e8                	shr    %cl,%eax
  801552:	89 e9                	mov    %ebp,%ecx
  801554:	89 44 24 04          	mov    %eax,0x4(%esp)
  801558:	8b 04 24             	mov    (%esp),%eax
  80155b:	09 54 24 04          	or     %edx,0x4(%esp)
  80155f:	89 fa                	mov    %edi,%edx
  801561:	d3 e0                	shl    %cl,%eax
  801563:	89 f1                	mov    %esi,%ecx
  801565:	89 44 24 08          	mov    %eax,0x8(%esp)
  801569:	8b 44 24 10          	mov    0x10(%esp),%eax
  80156d:	d3 ea                	shr    %cl,%edx
  80156f:	89 e9                	mov    %ebp,%ecx
  801571:	d3 e7                	shl    %cl,%edi
  801573:	89 f1                	mov    %esi,%ecx
  801575:	d3 e8                	shr    %cl,%eax
  801577:	89 e9                	mov    %ebp,%ecx
  801579:	09 f8                	or     %edi,%eax
  80157b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80157f:	f7 74 24 04          	divl   0x4(%esp)
  801583:	d3 e7                	shl    %cl,%edi
  801585:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801589:	89 d7                	mov    %edx,%edi
  80158b:	f7 64 24 08          	mull   0x8(%esp)
  80158f:	39 d7                	cmp    %edx,%edi
  801591:	89 c1                	mov    %eax,%ecx
  801593:	89 14 24             	mov    %edx,(%esp)
  801596:	72 2c                	jb     8015c4 <__umoddi3+0x134>
  801598:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80159c:	72 22                	jb     8015c0 <__umoddi3+0x130>
  80159e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015a2:	29 c8                	sub    %ecx,%eax
  8015a4:	19 d7                	sbb    %edx,%edi
  8015a6:	89 e9                	mov    %ebp,%ecx
  8015a8:	89 fa                	mov    %edi,%edx
  8015aa:	d3 e8                	shr    %cl,%eax
  8015ac:	89 f1                	mov    %esi,%ecx
  8015ae:	d3 e2                	shl    %cl,%edx
  8015b0:	89 e9                	mov    %ebp,%ecx
  8015b2:	d3 ef                	shr    %cl,%edi
  8015b4:	09 d0                	or     %edx,%eax
  8015b6:	89 fa                	mov    %edi,%edx
  8015b8:	83 c4 14             	add    $0x14,%esp
  8015bb:	5e                   	pop    %esi
  8015bc:	5f                   	pop    %edi
  8015bd:	5d                   	pop    %ebp
  8015be:	c3                   	ret    
  8015bf:	90                   	nop
  8015c0:	39 d7                	cmp    %edx,%edi
  8015c2:	75 da                	jne    80159e <__umoddi3+0x10e>
  8015c4:	8b 14 24             	mov    (%esp),%edx
  8015c7:	89 c1                	mov    %eax,%ecx
  8015c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8015cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8015d1:	eb cb                	jmp    80159e <__umoddi3+0x10e>
  8015d3:	90                   	nop
  8015d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8015dc:	0f 82 0f ff ff ff    	jb     8014f1 <__umoddi3+0x61>
  8015e2:	e9 1a ff ff ff       	jmp    801501 <__umoddi3+0x71>
