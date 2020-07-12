
obj/user/pingpong.debug：     文件格式 elf32-i386


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
  80002c:	e8 c6 00 00 00       	call   8000f7 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 6d 10 00 00       	call   8010ae <fork>
  800041:	89 c3                	mov    %eax,%ebx
  800043:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800046:	85 c0                	test   %eax,%eax
  800048:	74 3c                	je     800086 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 7c 0c 00 00       	call   800ccb <sys_getenvid>
  80004f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800053:	89 44 24 04          	mov    %eax,0x4(%esp)
  800057:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  80005e:	e8 98 01 00 00       	call   8001fb <cprintf>
		ipc_send(who, 0, 0, 0);
  800063:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006a:	00 
  80006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800072:	00 
  800073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007a:	00 
  80007b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007e:	89 04 24             	mov    %eax,(%esp)
  800081:	e8 15 13 00 00       	call   80139b <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800086:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800089:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800090:	00 
  800091:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800098:	00 
  800099:	89 34 24             	mov    %esi,(%esp)
  80009c:	e8 9e 12 00 00       	call   80133f <ipc_recv>
  8000a1:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000a6:	e8 20 0c 00 00       	call   800ccb <sys_getenvid>
  8000ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b7:	c7 04 24 d6 25 80 00 	movl   $0x8025d6,(%esp)
  8000be:	e8 38 01 00 00       	call   8001fb <cprintf>
		if (i == 10)
  8000c3:	83 fb 0a             	cmp    $0xa,%ebx
  8000c6:	74 27                	je     8000ef <umain+0xbc>
			return;
		i++;
  8000c8:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d2:	00 
  8000d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000da:	00 
  8000db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e2:	89 04 24             	mov    %eax,(%esp)
  8000e5:	e8 b1 12 00 00       	call   80139b <ipc_send>
		if (i == 10)
  8000ea:	83 fb 0a             	cmp    $0xa,%ebx
  8000ed:	75 9a                	jne    800089 <umain+0x56>
			return;
	}

}
  8000ef:	83 c4 2c             	add    $0x2c,%esp
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5f                   	pop    %edi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 10             	sub    $0x10,%esp
  8000ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800102:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800105:	e8 c1 0b 00 00       	call   800ccb <sys_getenvid>
  80010a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800112:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800117:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011c:	85 db                	test   %ebx,%ebx
  80011e:	7e 07                	jle    800127 <libmain+0x30>
		binaryname = argv[0];
  800120:	8b 06                	mov    (%esi),%eax
  800122:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800127:	89 74 24 04          	mov    %esi,0x4(%esp)
  80012b:	89 1c 24             	mov    %ebx,(%esp)
  80012e:	e8 00 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800133:	e8 07 00 00 00       	call   80013f <exit>
}
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800145:	e8 fc 14 00 00       	call   801646 <close_all>
	sys_env_destroy(0);
  80014a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800151:	e8 23 0b 00 00       	call   800c79 <sys_env_destroy>
}
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	53                   	push   %ebx
  80015c:	83 ec 14             	sub    $0x14,%esp
  80015f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800162:	8b 13                	mov    (%ebx),%edx
  800164:	8d 42 01             	lea    0x1(%edx),%eax
  800167:	89 03                	mov    %eax,(%ebx)
  800169:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800170:	3d ff 00 00 00       	cmp    $0xff,%eax
  800175:	75 19                	jne    800190 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800177:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80017e:	00 
  80017f:	8d 43 08             	lea    0x8(%ebx),%eax
  800182:	89 04 24             	mov    %eax,(%esp)
  800185:	e8 b2 0a 00 00       	call   800c3c <sys_cputs>
		b->idx = 0;
  80018a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800190:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800194:	83 c4 14             	add    $0x14,%esp
  800197:	5b                   	pop    %ebx
  800198:	5d                   	pop    %ebp
  800199:	c3                   	ret    

0080019a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001aa:	00 00 00 
	b.cnt = 0;
  8001ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cf:	c7 04 24 58 01 80 00 	movl   $0x800158,(%esp)
  8001d6:	e8 b9 01 00 00       	call   800394 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001db:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001eb:	89 04 24             	mov    %eax,(%esp)
  8001ee:	e8 49 0a 00 00       	call   800c3c <sys_cputs>

	return b.cnt;
}
  8001f3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800201:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800204:	89 44 24 04          	mov    %eax,0x4(%esp)
  800208:	8b 45 08             	mov    0x8(%ebp),%eax
  80020b:	89 04 24             	mov    %eax,(%esp)
  80020e:	e8 87 ff ff ff       	call   80019a <vcprintf>
	va_end(ap);

	return cnt;
}
  800213:	c9                   	leave  
  800214:	c3                   	ret    
  800215:	66 90                	xchg   %ax,%ax
  800217:	66 90                	xchg   %ax,%ax
  800219:	66 90                	xchg   %ax,%ax
  80021b:	66 90                	xchg   %ax,%ax
  80021d:	66 90                	xchg   %ax,%ax
  80021f:	90                   	nop

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 3c             	sub    $0x3c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d7                	mov    %edx,%edi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800234:	8b 75 0c             	mov    0xc(%ebp),%esi
  800237:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80023a:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800242:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800245:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800248:	39 f1                	cmp    %esi,%ecx
  80024a:	72 14                	jb     800260 <printnum+0x40>
  80024c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80024f:	76 0f                	jbe    800260 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800251:	8b 45 14             	mov    0x14(%ebp),%eax
  800254:	8d 70 ff             	lea    -0x1(%eax),%esi
  800257:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80025a:	85 f6                	test   %esi,%esi
  80025c:	7f 60                	jg     8002be <printnum+0x9e>
  80025e:	eb 72                	jmp    8002d2 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800260:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800263:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800267:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80026a:	8d 51 ff             	lea    -0x1(%ecx),%edx
  80026d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800271:	89 44 24 08          	mov    %eax,0x8(%esp)
  800275:	8b 44 24 08          	mov    0x8(%esp),%eax
  800279:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80027d:	89 c3                	mov    %eax,%ebx
  80027f:	89 d6                	mov    %edx,%esi
  800281:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800284:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800287:	89 54 24 08          	mov    %edx,0x8(%esp)
  80028b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80028f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800292:	89 04 24             	mov    %eax,(%esp)
  800295:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029c:	e8 7f 20 00 00       	call   802320 <__udivdi3>
  8002a1:	89 d9                	mov    %ebx,%ecx
  8002a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002a7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ab:	89 04 24             	mov    %eax,(%esp)
  8002ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002b2:	89 fa                	mov    %edi,%edx
  8002b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002b7:	e8 64 ff ff ff       	call   800220 <printnum>
  8002bc:	eb 14                	jmp    8002d2 <printnum+0xb2>
			putch(padc, putdat);
  8002be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c2:	8b 45 18             	mov    0x18(%ebp),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	ff d3                	call   *%ebx
		while (--width > 0)
  8002ca:	83 ee 01             	sub    $0x1,%esi
  8002cd:	75 ef                	jne    8002be <printnum+0x9e>
  8002cf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002da:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002eb:	89 04 24             	mov    %eax,(%esp)
  8002ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f5:	e8 56 21 00 00       	call   802450 <__umoddi3>
  8002fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fe:	0f be 80 f3 25 80 00 	movsbl 0x8025f3(%eax),%eax
  800305:	89 04 24             	mov    %eax,(%esp)
  800308:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030b:	ff d0                	call   *%eax
}
  80030d:	83 c4 3c             	add    $0x3c,%esp
  800310:	5b                   	pop    %ebx
  800311:	5e                   	pop    %esi
  800312:	5f                   	pop    %edi
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800318:	83 fa 01             	cmp    $0x1,%edx
  80031b:	7e 0e                	jle    80032b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80031d:	8b 10                	mov    (%eax),%edx
  80031f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800322:	89 08                	mov    %ecx,(%eax)
  800324:	8b 02                	mov    (%edx),%eax
  800326:	8b 52 04             	mov    0x4(%edx),%edx
  800329:	eb 22                	jmp    80034d <getuint+0x38>
	else if (lflag)
  80032b:	85 d2                	test   %edx,%edx
  80032d:	74 10                	je     80033f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80032f:	8b 10                	mov    (%eax),%edx
  800331:	8d 4a 04             	lea    0x4(%edx),%ecx
  800334:	89 08                	mov    %ecx,(%eax)
  800336:	8b 02                	mov    (%edx),%eax
  800338:	ba 00 00 00 00       	mov    $0x0,%edx
  80033d:	eb 0e                	jmp    80034d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80033f:	8b 10                	mov    (%eax),%edx
  800341:	8d 4a 04             	lea    0x4(%edx),%ecx
  800344:	89 08                	mov    %ecx,(%eax)
  800346:	8b 02                	mov    (%edx),%eax
  800348:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800355:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	3b 50 04             	cmp    0x4(%eax),%edx
  80035e:	73 0a                	jae    80036a <sprintputch+0x1b>
		*b->buf++ = ch;
  800360:	8d 4a 01             	lea    0x1(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 45 08             	mov    0x8(%ebp),%eax
  800368:	88 02                	mov    %al,(%edx)
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <printfmt>:
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  800372:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800375:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800379:	8b 45 10             	mov    0x10(%ebp),%eax
  80037c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800380:	8b 45 0c             	mov    0xc(%ebp),%eax
  800383:	89 44 24 04          	mov    %eax,0x4(%esp)
  800387:	8b 45 08             	mov    0x8(%ebp),%eax
  80038a:	89 04 24             	mov    %eax,(%esp)
  80038d:	e8 02 00 00 00       	call   800394 <vprintfmt>
}
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <vprintfmt>:
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 3c             	sub    $0x3c,%esp
  80039d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003a3:	eb 18                	jmp    8003bd <vprintfmt+0x29>
			if (ch == '\0')
  8003a5:	85 c0                	test   %eax,%eax
  8003a7:	0f 84 c3 03 00 00    	je     800770 <vprintfmt+0x3dc>
			putch(ch, putdat);
  8003ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b1:	89 04 24             	mov    %eax,(%esp)
  8003b4:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b7:	89 f3                	mov    %esi,%ebx
  8003b9:	eb 02                	jmp    8003bd <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  8003bb:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003bd:	8d 73 01             	lea    0x1(%ebx),%esi
  8003c0:	0f b6 03             	movzbl (%ebx),%eax
  8003c3:	83 f8 25             	cmp    $0x25,%eax
  8003c6:	75 dd                	jne    8003a5 <vprintfmt+0x11>
  8003c8:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8003cc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003d3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003da:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e6:	eb 1d                	jmp    800405 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	89 de                	mov    %ebx,%esi
			padc = '-';
  8003ea:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8003ee:	eb 15                	jmp    800405 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	89 de                	mov    %ebx,%esi
			padc = '0';
  8003f2:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8003f6:	eb 0d                	jmp    800405 <vprintfmt+0x71>
				width = precision, precision = -1;
  8003f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fe:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8d 5e 01             	lea    0x1(%esi),%ebx
  800408:	0f b6 06             	movzbl (%esi),%eax
  80040b:	0f b6 c8             	movzbl %al,%ecx
  80040e:	83 e8 23             	sub    $0x23,%eax
  800411:	3c 55                	cmp    $0x55,%al
  800413:	0f 87 2f 03 00 00    	ja     800748 <vprintfmt+0x3b4>
  800419:	0f b6 c0             	movzbl %al,%eax
  80041c:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
				precision = precision * 10 + ch - '0';
  800423:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800426:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  800429:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80042d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800430:	83 f9 09             	cmp    $0x9,%ecx
  800433:	77 50                	ja     800485 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  800435:	89 de                	mov    %ebx,%esi
  800437:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  80043a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80043d:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800440:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800444:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800447:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80044a:	83 fb 09             	cmp    $0x9,%ebx
  80044d:	76 eb                	jbe    80043a <vprintfmt+0xa6>
  80044f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800452:	eb 33                	jmp    800487 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 48 04             	lea    0x4(%eax),%ecx
  80045a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80045d:	8b 00                	mov    (%eax),%eax
  80045f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800462:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800464:	eb 21                	jmp    800487 <vprintfmt+0xf3>
  800466:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800469:	85 c9                	test   %ecx,%ecx
  80046b:	b8 00 00 00 00       	mov    $0x0,%eax
  800470:	0f 49 c1             	cmovns %ecx,%eax
  800473:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800476:	89 de                	mov    %ebx,%esi
  800478:	eb 8b                	jmp    800405 <vprintfmt+0x71>
  80047a:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80047c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800483:	eb 80                	jmp    800405 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800485:	89 de                	mov    %ebx,%esi
			if (width < 0)
  800487:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048b:	0f 89 74 ff ff ff    	jns    800405 <vprintfmt+0x71>
  800491:	e9 62 ff ff ff       	jmp    8003f8 <vprintfmt+0x64>
			lflag++;
  800496:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800499:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80049b:	e9 65 ff ff ff       	jmp    800405 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  8004a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a3:	8d 50 04             	lea    0x4(%eax),%edx
  8004a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ad:	8b 00                	mov    (%eax),%eax
  8004af:	89 04 24             	mov    %eax,(%esp)
  8004b2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004b5:	e9 03 ff ff ff       	jmp    8003bd <vprintfmt+0x29>
			err = va_arg(ap, int);
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 50 04             	lea    0x4(%eax),%edx
  8004c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c3:	8b 00                	mov    (%eax),%eax
  8004c5:	99                   	cltd   
  8004c6:	31 d0                	xor    %edx,%eax
  8004c8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ca:	83 f8 0f             	cmp    $0xf,%eax
  8004cd:	7f 0b                	jg     8004da <vprintfmt+0x146>
  8004cf:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	75 20                	jne    8004fa <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  8004da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004de:	c7 44 24 08 0b 26 80 	movl   $0x80260b,0x8(%esp)
  8004e5:	00 
  8004e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ed:	89 04 24             	mov    %eax,(%esp)
  8004f0:	e8 77 fe ff ff       	call   80036c <printfmt>
  8004f5:	e9 c3 fe ff ff       	jmp    8003bd <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  8004fa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004fe:	c7 44 24 08 53 2b 80 	movl   $0x802b53,0x8(%esp)
  800505:	00 
  800506:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80050a:	8b 45 08             	mov    0x8(%ebp),%eax
  80050d:	89 04 24             	mov    %eax,(%esp)
  800510:	e8 57 fe ff ff       	call   80036c <printfmt>
  800515:	e9 a3 fe ff ff       	jmp    8003bd <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80051d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 04             	lea    0x4(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80052b:	85 c0                	test   %eax,%eax
  80052d:	ba 04 26 80 00       	mov    $0x802604,%edx
  800532:	0f 45 d0             	cmovne %eax,%edx
  800535:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800538:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80053c:	74 04                	je     800542 <vprintfmt+0x1ae>
  80053e:	85 f6                	test   %esi,%esi
  800540:	7f 19                	jg     80055b <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800542:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800545:	8d 70 01             	lea    0x1(%eax),%esi
  800548:	0f b6 10             	movzbl (%eax),%edx
  80054b:	0f be c2             	movsbl %dl,%eax
  80054e:	85 c0                	test   %eax,%eax
  800550:	0f 85 95 00 00 00    	jne    8005eb <vprintfmt+0x257>
  800556:	e9 85 00 00 00       	jmp    8005e0 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80055f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800562:	89 04 24             	mov    %eax,(%esp)
  800565:	e8 b8 02 00 00       	call   800822 <strnlen>
  80056a:	29 c6                	sub    %eax,%esi
  80056c:	89 f0                	mov    %esi,%eax
  80056e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800571:	85 f6                	test   %esi,%esi
  800573:	7e cd                	jle    800542 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800575:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800579:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80057c:	89 c3                	mov    %eax,%ebx
  80057e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800582:	89 34 24             	mov    %esi,(%esp)
  800585:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800588:	83 eb 01             	sub    $0x1,%ebx
  80058b:	75 f1                	jne    80057e <vprintfmt+0x1ea>
  80058d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800590:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800593:	eb ad                	jmp    800542 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800595:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800599:	74 1e                	je     8005b9 <vprintfmt+0x225>
  80059b:	0f be d2             	movsbl %dl,%edx
  80059e:	83 ea 20             	sub    $0x20,%edx
  8005a1:	83 fa 5e             	cmp    $0x5e,%edx
  8005a4:	76 13                	jbe    8005b9 <vprintfmt+0x225>
					putch('?', putdat);
  8005a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ad:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b4:	ff 55 08             	call   *0x8(%ebp)
  8005b7:	eb 0d                	jmp    8005c6 <vprintfmt+0x232>
					putch(ch, putdat);
  8005b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005c0:	89 04 24             	mov    %eax,(%esp)
  8005c3:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c6:	83 ef 01             	sub    $0x1,%edi
  8005c9:	83 c6 01             	add    $0x1,%esi
  8005cc:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8005d0:	0f be c2             	movsbl %dl,%eax
  8005d3:	85 c0                	test   %eax,%eax
  8005d5:	75 20                	jne    8005f7 <vprintfmt+0x263>
  8005d7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005da:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  8005e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e4:	7f 25                	jg     80060b <vprintfmt+0x277>
  8005e6:	e9 d2 fd ff ff       	jmp    8003bd <vprintfmt+0x29>
  8005eb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005f4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f7:	85 db                	test   %ebx,%ebx
  8005f9:	78 9a                	js     800595 <vprintfmt+0x201>
  8005fb:	83 eb 01             	sub    $0x1,%ebx
  8005fe:	79 95                	jns    800595 <vprintfmt+0x201>
  800600:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800603:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800606:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800609:	eb d5                	jmp    8005e0 <vprintfmt+0x24c>
  80060b:	8b 75 08             	mov    0x8(%ebp),%esi
  80060e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800611:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  800614:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800618:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80061f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800621:	83 eb 01             	sub    $0x1,%ebx
  800624:	75 ee                	jne    800614 <vprintfmt+0x280>
  800626:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800629:	e9 8f fd ff ff       	jmp    8003bd <vprintfmt+0x29>
	if (lflag >= 2)
  80062e:	83 fa 01             	cmp    $0x1,%edx
  800631:	7e 16                	jle    800649 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8d 50 08             	lea    0x8(%eax),%edx
  800639:	89 55 14             	mov    %edx,0x14(%ebp)
  80063c:	8b 50 04             	mov    0x4(%eax),%edx
  80063f:	8b 00                	mov    (%eax),%eax
  800641:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800644:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800647:	eb 32                	jmp    80067b <vprintfmt+0x2e7>
	else if (lflag)
  800649:	85 d2                	test   %edx,%edx
  80064b:	74 18                	je     800665 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8d 50 04             	lea    0x4(%eax),%edx
  800653:	89 55 14             	mov    %edx,0x14(%ebp)
  800656:	8b 30                	mov    (%eax),%esi
  800658:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80065b:	89 f0                	mov    %esi,%eax
  80065d:	c1 f8 1f             	sar    $0x1f,%eax
  800660:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800663:	eb 16                	jmp    80067b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 50 04             	lea    0x4(%eax),%edx
  80066b:	89 55 14             	mov    %edx,0x14(%ebp)
  80066e:	8b 30                	mov    (%eax),%esi
  800670:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800673:	89 f0                	mov    %esi,%eax
  800675:	c1 f8 1f             	sar    $0x1f,%eax
  800678:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  80067b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80067e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  800681:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800686:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80068a:	0f 89 80 00 00 00    	jns    800710 <vprintfmt+0x37c>
				putch('-', putdat);
  800690:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800694:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80069b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80069e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006a4:	f7 d8                	neg    %eax
  8006a6:	83 d2 00             	adc    $0x0,%edx
  8006a9:	f7 da                	neg    %edx
			base = 10;
  8006ab:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006b0:	eb 5e                	jmp    800710 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8006b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b5:	e8 5b fc ff ff       	call   800315 <getuint>
			base = 10;
  8006ba:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006bf:	eb 4f                	jmp    800710 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8006c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c4:	e8 4c fc ff ff       	call   800315 <getuint>
			base = 8;
  8006c9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006ce:	eb 40                	jmp    800710 <vprintfmt+0x37c>
			putch('0', putdat);
  8006d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006db:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006e9:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  8006ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ef:	8d 50 04             	lea    0x4(%eax),%edx
  8006f2:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8006f5:	8b 00                	mov    (%eax),%eax
  8006f7:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8006fc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800701:	eb 0d                	jmp    800710 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
  800706:	e8 0a fc ff ff       	call   800315 <getuint>
			base = 16;
  80070b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800710:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800714:	89 74 24 10          	mov    %esi,0x10(%esp)
  800718:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80071b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80071f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800723:	89 04 24             	mov    %eax,(%esp)
  800726:	89 54 24 04          	mov    %edx,0x4(%esp)
  80072a:	89 fa                	mov    %edi,%edx
  80072c:	8b 45 08             	mov    0x8(%ebp),%eax
  80072f:	e8 ec fa ff ff       	call   800220 <printnum>
			break;
  800734:	e9 84 fc ff ff       	jmp    8003bd <vprintfmt+0x29>
			putch(ch, putdat);
  800739:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073d:	89 0c 24             	mov    %ecx,(%esp)
  800740:	ff 55 08             	call   *0x8(%ebp)
			break;
  800743:	e9 75 fc ff ff       	jmp    8003bd <vprintfmt+0x29>
			putch('%', putdat);
  800748:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80074c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800753:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800756:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80075a:	0f 84 5b fc ff ff    	je     8003bb <vprintfmt+0x27>
  800760:	89 f3                	mov    %esi,%ebx
  800762:	83 eb 01             	sub    $0x1,%ebx
  800765:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800769:	75 f7                	jne    800762 <vprintfmt+0x3ce>
  80076b:	e9 4d fc ff ff       	jmp    8003bd <vprintfmt+0x29>
}
  800770:	83 c4 3c             	add    $0x3c,%esp
  800773:	5b                   	pop    %ebx
  800774:	5e                   	pop    %esi
  800775:	5f                   	pop    %edi
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	83 ec 28             	sub    $0x28,%esp
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800784:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800787:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800795:	85 c0                	test   %eax,%eax
  800797:	74 30                	je     8007c9 <vsnprintf+0x51>
  800799:	85 d2                	test   %edx,%edx
  80079b:	7e 2c                	jle    8007c9 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b2:	c7 04 24 4f 03 80 00 	movl   $0x80034f,(%esp)
  8007b9:	e8 d6 fb ff ff       	call   800394 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007be:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c7:	eb 05                	jmp    8007ce <vsnprintf+0x56>
		return -E_INVAL;
  8007c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	89 04 24             	mov    %eax,(%esp)
  8007f1:	e8 82 ff ff ff       	call   800778 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    
  8007f8:	66 90                	xchg   %ax,%ax
  8007fa:	66 90                	xchg   %ax,%ax
  8007fc:	66 90                	xchg   %ax,%ax
  8007fe:	66 90                	xchg   %ax,%ax

00800800 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	80 3a 00             	cmpb   $0x0,(%edx)
  800809:	74 10                	je     80081b <strlen+0x1b>
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800810:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800813:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800817:	75 f7                	jne    800810 <strlen+0x10>
  800819:	eb 05                	jmp    800820 <strlen+0x20>
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	53                   	push   %ebx
  800826:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800829:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082c:	85 c9                	test   %ecx,%ecx
  80082e:	74 1c                	je     80084c <strnlen+0x2a>
  800830:	80 3b 00             	cmpb   $0x0,(%ebx)
  800833:	74 1e                	je     800853 <strnlen+0x31>
  800835:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80083a:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083c:	39 ca                	cmp    %ecx,%edx
  80083e:	74 18                	je     800858 <strnlen+0x36>
  800840:	83 c2 01             	add    $0x1,%edx
  800843:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800848:	75 f0                	jne    80083a <strnlen+0x18>
  80084a:	eb 0c                	jmp    800858 <strnlen+0x36>
  80084c:	b8 00 00 00 00       	mov    $0x0,%eax
  800851:	eb 05                	jmp    800858 <strnlen+0x36>
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800858:	5b                   	pop    %ebx
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800865:	89 c2                	mov    %eax,%edx
  800867:	83 c2 01             	add    $0x1,%edx
  80086a:	83 c1 01             	add    $0x1,%ecx
  80086d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800871:	88 5a ff             	mov    %bl,-0x1(%edx)
  800874:	84 db                	test   %bl,%bl
  800876:	75 ef                	jne    800867 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800878:	5b                   	pop    %ebx
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	83 ec 08             	sub    $0x8,%esp
  800882:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800885:	89 1c 24             	mov    %ebx,(%esp)
  800888:	e8 73 ff ff ff       	call   800800 <strlen>
	strcpy(dst + len, src);
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800890:	89 54 24 04          	mov    %edx,0x4(%esp)
  800894:	01 d8                	add    %ebx,%eax
  800896:	89 04 24             	mov    %eax,(%esp)
  800899:	e8 bd ff ff ff       	call   80085b <strcpy>
	return dst;
}
  80089e:	89 d8                	mov    %ebx,%eax
  8008a0:	83 c4 08             	add    $0x8,%esp
  8008a3:	5b                   	pop    %ebx
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b4:	85 db                	test   %ebx,%ebx
  8008b6:	74 17                	je     8008cf <strncpy+0x29>
  8008b8:	01 f3                	add    %esi,%ebx
  8008ba:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8008bc:	83 c1 01             	add    $0x1,%ecx
  8008bf:	0f b6 02             	movzbl (%edx),%eax
  8008c2:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c5:	80 3a 01             	cmpb   $0x1,(%edx)
  8008c8:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8008cb:	39 d9                	cmp    %ebx,%ecx
  8008cd:	75 ed                	jne    8008bc <strncpy+0x16>
	}
	return ret;
}
  8008cf:	89 f0                	mov    %esi,%eax
  8008d1:	5b                   	pop    %ebx
  8008d2:	5e                   	pop    %esi
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	57                   	push   %edi
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008e1:	8b 75 10             	mov    0x10(%ebp),%esi
  8008e4:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e6:	85 f6                	test   %esi,%esi
  8008e8:	74 34                	je     80091e <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  8008ea:	83 fe 01             	cmp    $0x1,%esi
  8008ed:	74 26                	je     800915 <strlcpy+0x40>
  8008ef:	0f b6 0b             	movzbl (%ebx),%ecx
  8008f2:	84 c9                	test   %cl,%cl
  8008f4:	74 23                	je     800919 <strlcpy+0x44>
  8008f6:	83 ee 02             	sub    $0x2,%esi
  8008f9:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  8008fe:	83 c0 01             	add    $0x1,%eax
  800901:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800904:	39 f2                	cmp    %esi,%edx
  800906:	74 13                	je     80091b <strlcpy+0x46>
  800908:	83 c2 01             	add    $0x1,%edx
  80090b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80090f:	84 c9                	test   %cl,%cl
  800911:	75 eb                	jne    8008fe <strlcpy+0x29>
  800913:	eb 06                	jmp    80091b <strlcpy+0x46>
  800915:	89 f8                	mov    %edi,%eax
  800917:	eb 02                	jmp    80091b <strlcpy+0x46>
  800919:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  80091b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80091e:	29 f8                	sub    %edi,%eax
}
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5f                   	pop    %edi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092e:	0f b6 01             	movzbl (%ecx),%eax
  800931:	84 c0                	test   %al,%al
  800933:	74 15                	je     80094a <strcmp+0x25>
  800935:	3a 02                	cmp    (%edx),%al
  800937:	75 11                	jne    80094a <strcmp+0x25>
		p++, q++;
  800939:	83 c1 01             	add    $0x1,%ecx
  80093c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80093f:	0f b6 01             	movzbl (%ecx),%eax
  800942:	84 c0                	test   %al,%al
  800944:	74 04                	je     80094a <strcmp+0x25>
  800946:	3a 02                	cmp    (%edx),%al
  800948:	74 ef                	je     800939 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80094a:	0f b6 c0             	movzbl %al,%eax
  80094d:	0f b6 12             	movzbl (%edx),%edx
  800950:	29 d0                	sub    %edx,%eax
}
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	56                   	push   %esi
  800958:	53                   	push   %ebx
  800959:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800962:	85 f6                	test   %esi,%esi
  800964:	74 29                	je     80098f <strncmp+0x3b>
  800966:	0f b6 03             	movzbl (%ebx),%eax
  800969:	84 c0                	test   %al,%al
  80096b:	74 30                	je     80099d <strncmp+0x49>
  80096d:	3a 02                	cmp    (%edx),%al
  80096f:	75 2c                	jne    80099d <strncmp+0x49>
  800971:	8d 43 01             	lea    0x1(%ebx),%eax
  800974:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800976:	89 c3                	mov    %eax,%ebx
  800978:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80097b:	39 f0                	cmp    %esi,%eax
  80097d:	74 17                	je     800996 <strncmp+0x42>
  80097f:	0f b6 08             	movzbl (%eax),%ecx
  800982:	84 c9                	test   %cl,%cl
  800984:	74 17                	je     80099d <strncmp+0x49>
  800986:	83 c0 01             	add    $0x1,%eax
  800989:	3a 0a                	cmp    (%edx),%cl
  80098b:	74 e9                	je     800976 <strncmp+0x22>
  80098d:	eb 0e                	jmp    80099d <strncmp+0x49>
	if (n == 0)
		return 0;
  80098f:	b8 00 00 00 00       	mov    $0x0,%eax
  800994:	eb 0f                	jmp    8009a5 <strncmp+0x51>
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
  80099b:	eb 08                	jmp    8009a5 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80099d:	0f b6 03             	movzbl (%ebx),%eax
  8009a0:	0f b6 12             	movzbl (%edx),%edx
  8009a3:	29 d0                	sub    %edx,%eax
}
  8009a5:	5b                   	pop    %ebx
  8009a6:	5e                   	pop    %esi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	53                   	push   %ebx
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009b3:	0f b6 18             	movzbl (%eax),%ebx
  8009b6:	84 db                	test   %bl,%bl
  8009b8:	74 1d                	je     8009d7 <strchr+0x2e>
  8009ba:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009bc:	38 d3                	cmp    %dl,%bl
  8009be:	75 06                	jne    8009c6 <strchr+0x1d>
  8009c0:	eb 1a                	jmp    8009dc <strchr+0x33>
  8009c2:	38 ca                	cmp    %cl,%dl
  8009c4:	74 16                	je     8009dc <strchr+0x33>
	for (; *s; s++)
  8009c6:	83 c0 01             	add    $0x1,%eax
  8009c9:	0f b6 10             	movzbl (%eax),%edx
  8009cc:	84 d2                	test   %dl,%dl
  8009ce:	75 f2                	jne    8009c2 <strchr+0x19>
			return (char *) s;
	return 0;
  8009d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d5:	eb 05                	jmp    8009dc <strchr+0x33>
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009dc:	5b                   	pop    %ebx
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	53                   	push   %ebx
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009e9:	0f b6 18             	movzbl (%eax),%ebx
  8009ec:	84 db                	test   %bl,%bl
  8009ee:	74 16                	je     800a06 <strfind+0x27>
  8009f0:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009f2:	38 d3                	cmp    %dl,%bl
  8009f4:	75 06                	jne    8009fc <strfind+0x1d>
  8009f6:	eb 0e                	jmp    800a06 <strfind+0x27>
  8009f8:	38 ca                	cmp    %cl,%dl
  8009fa:	74 0a                	je     800a06 <strfind+0x27>
	for (; *s; s++)
  8009fc:	83 c0 01             	add    $0x1,%eax
  8009ff:	0f b6 10             	movzbl (%eax),%edx
  800a02:	84 d2                	test   %dl,%dl
  800a04:	75 f2                	jne    8009f8 <strfind+0x19>
			break;
	return (char *) s;
}
  800a06:	5b                   	pop    %ebx
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	57                   	push   %edi
  800a0d:	56                   	push   %esi
  800a0e:	53                   	push   %ebx
  800a0f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a15:	85 c9                	test   %ecx,%ecx
  800a17:	74 36                	je     800a4f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a19:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1f:	75 28                	jne    800a49 <memset+0x40>
  800a21:	f6 c1 03             	test   $0x3,%cl
  800a24:	75 23                	jne    800a49 <memset+0x40>
		c &= 0xFF;
  800a26:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a2a:	89 d3                	mov    %edx,%ebx
  800a2c:	c1 e3 08             	shl    $0x8,%ebx
  800a2f:	89 d6                	mov    %edx,%esi
  800a31:	c1 e6 18             	shl    $0x18,%esi
  800a34:	89 d0                	mov    %edx,%eax
  800a36:	c1 e0 10             	shl    $0x10,%eax
  800a39:	09 f0                	or     %esi,%eax
  800a3b:	09 c2                	or     %eax,%edx
  800a3d:	89 d0                	mov    %edx,%eax
  800a3f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a41:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a44:	fc                   	cld    
  800a45:	f3 ab                	rep stos %eax,%es:(%edi)
  800a47:	eb 06                	jmp    800a4f <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4c:	fc                   	cld    
  800a4d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4f:	89 f8                	mov    %edi,%eax
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5f                   	pop    %edi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	57                   	push   %edi
  800a5a:	56                   	push   %esi
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a61:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a64:	39 c6                	cmp    %eax,%esi
  800a66:	73 35                	jae    800a9d <memmove+0x47>
  800a68:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a6b:	39 d0                	cmp    %edx,%eax
  800a6d:	73 2e                	jae    800a9d <memmove+0x47>
		s += n;
		d += n;
  800a6f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a72:	89 d6                	mov    %edx,%esi
  800a74:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a76:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a7c:	75 13                	jne    800a91 <memmove+0x3b>
  800a7e:	f6 c1 03             	test   $0x3,%cl
  800a81:	75 0e                	jne    800a91 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a83:	83 ef 04             	sub    $0x4,%edi
  800a86:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a89:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a8c:	fd                   	std    
  800a8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8f:	eb 09                	jmp    800a9a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a91:	83 ef 01             	sub    $0x1,%edi
  800a94:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a97:	fd                   	std    
  800a98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a9a:	fc                   	cld    
  800a9b:	eb 1d                	jmp    800aba <memmove+0x64>
  800a9d:	89 f2                	mov    %esi,%edx
  800a9f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa1:	f6 c2 03             	test   $0x3,%dl
  800aa4:	75 0f                	jne    800ab5 <memmove+0x5f>
  800aa6:	f6 c1 03             	test   $0x3,%cl
  800aa9:	75 0a                	jne    800ab5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aab:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aae:	89 c7                	mov    %eax,%edi
  800ab0:	fc                   	cld    
  800ab1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab3:	eb 05                	jmp    800aba <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800ab5:	89 c7                	mov    %eax,%edi
  800ab7:	fc                   	cld    
  800ab8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ac4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800acb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ace:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	89 04 24             	mov    %eax,(%esp)
  800ad8:	e8 79 ff ff ff       	call   800a56 <memmove>
}
  800add:	c9                   	leave  
  800ade:	c3                   	ret    

00800adf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ae8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aeb:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aee:	8d 78 ff             	lea    -0x1(%eax),%edi
  800af1:	85 c0                	test   %eax,%eax
  800af3:	74 36                	je     800b2b <memcmp+0x4c>
		if (*s1 != *s2)
  800af5:	0f b6 03             	movzbl (%ebx),%eax
  800af8:	0f b6 0e             	movzbl (%esi),%ecx
  800afb:	ba 00 00 00 00       	mov    $0x0,%edx
  800b00:	38 c8                	cmp    %cl,%al
  800b02:	74 1c                	je     800b20 <memcmp+0x41>
  800b04:	eb 10                	jmp    800b16 <memcmp+0x37>
  800b06:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b0b:	83 c2 01             	add    $0x1,%edx
  800b0e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b12:	38 c8                	cmp    %cl,%al
  800b14:	74 0a                	je     800b20 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b16:	0f b6 c0             	movzbl %al,%eax
  800b19:	0f b6 c9             	movzbl %cl,%ecx
  800b1c:	29 c8                	sub    %ecx,%eax
  800b1e:	eb 10                	jmp    800b30 <memcmp+0x51>
	while (n-- > 0) {
  800b20:	39 fa                	cmp    %edi,%edx
  800b22:	75 e2                	jne    800b06 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800b24:	b8 00 00 00 00       	mov    $0x0,%eax
  800b29:	eb 05                	jmp    800b30 <memcmp+0x51>
  800b2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	53                   	push   %ebx
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b3f:	89 c2                	mov    %eax,%edx
  800b41:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b44:	39 d0                	cmp    %edx,%eax
  800b46:	73 13                	jae    800b5b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b48:	89 d9                	mov    %ebx,%ecx
  800b4a:	38 18                	cmp    %bl,(%eax)
  800b4c:	75 06                	jne    800b54 <memfind+0x1f>
  800b4e:	eb 0b                	jmp    800b5b <memfind+0x26>
  800b50:	38 08                	cmp    %cl,(%eax)
  800b52:	74 07                	je     800b5b <memfind+0x26>
	for (; s < ends; s++)
  800b54:	83 c0 01             	add    $0x1,%eax
  800b57:	39 d0                	cmp    %edx,%eax
  800b59:	75 f5                	jne    800b50 <memfind+0x1b>
			break;
	return (void *) s;
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6a:	0f b6 0a             	movzbl (%edx),%ecx
  800b6d:	80 f9 09             	cmp    $0x9,%cl
  800b70:	74 05                	je     800b77 <strtol+0x19>
  800b72:	80 f9 20             	cmp    $0x20,%cl
  800b75:	75 10                	jne    800b87 <strtol+0x29>
		s++;
  800b77:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b7a:	0f b6 0a             	movzbl (%edx),%ecx
  800b7d:	80 f9 09             	cmp    $0x9,%cl
  800b80:	74 f5                	je     800b77 <strtol+0x19>
  800b82:	80 f9 20             	cmp    $0x20,%cl
  800b85:	74 f0                	je     800b77 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800b87:	80 f9 2b             	cmp    $0x2b,%cl
  800b8a:	75 0a                	jne    800b96 <strtol+0x38>
		s++;
  800b8c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b8f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b94:	eb 11                	jmp    800ba7 <strtol+0x49>
  800b96:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800b9b:	80 f9 2d             	cmp    $0x2d,%cl
  800b9e:	75 07                	jne    800ba7 <strtol+0x49>
		s++, neg = 1;
  800ba0:	83 c2 01             	add    $0x1,%edx
  800ba3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba7:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800bac:	75 15                	jne    800bc3 <strtol+0x65>
  800bae:	80 3a 30             	cmpb   $0x30,(%edx)
  800bb1:	75 10                	jne    800bc3 <strtol+0x65>
  800bb3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bb7:	75 0a                	jne    800bc3 <strtol+0x65>
		s += 2, base = 16;
  800bb9:	83 c2 02             	add    $0x2,%edx
  800bbc:	b8 10 00 00 00       	mov    $0x10,%eax
  800bc1:	eb 10                	jmp    800bd3 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800bc3:	85 c0                	test   %eax,%eax
  800bc5:	75 0c                	jne    800bd3 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc7:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800bc9:	80 3a 30             	cmpb   $0x30,(%edx)
  800bcc:	75 05                	jne    800bd3 <strtol+0x75>
		s++, base = 8;
  800bce:	83 c2 01             	add    $0x1,%edx
  800bd1:	b0 08                	mov    $0x8,%al
		base = 10;
  800bd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd8:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bdb:	0f b6 0a             	movzbl (%edx),%ecx
  800bde:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800be1:	89 f0                	mov    %esi,%eax
  800be3:	3c 09                	cmp    $0x9,%al
  800be5:	77 08                	ja     800bef <strtol+0x91>
			dig = *s - '0';
  800be7:	0f be c9             	movsbl %cl,%ecx
  800bea:	83 e9 30             	sub    $0x30,%ecx
  800bed:	eb 20                	jmp    800c0f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800bef:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bf2:	89 f0                	mov    %esi,%eax
  800bf4:	3c 19                	cmp    $0x19,%al
  800bf6:	77 08                	ja     800c00 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800bf8:	0f be c9             	movsbl %cl,%ecx
  800bfb:	83 e9 57             	sub    $0x57,%ecx
  800bfe:	eb 0f                	jmp    800c0f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800c00:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c03:	89 f0                	mov    %esi,%eax
  800c05:	3c 19                	cmp    $0x19,%al
  800c07:	77 16                	ja     800c1f <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c09:	0f be c9             	movsbl %cl,%ecx
  800c0c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c0f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c12:	7d 0f                	jge    800c23 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c14:	83 c2 01             	add    $0x1,%edx
  800c17:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c1b:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c1d:	eb bc                	jmp    800bdb <strtol+0x7d>
  800c1f:	89 d8                	mov    %ebx,%eax
  800c21:	eb 02                	jmp    800c25 <strtol+0xc7>
  800c23:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c25:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c29:	74 05                	je     800c30 <strtol+0xd2>
		*endptr = (char *) s;
  800c2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c30:	f7 d8                	neg    %eax
  800c32:	85 ff                	test   %edi,%edi
  800c34:	0f 44 c3             	cmove  %ebx,%eax
}
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	89 c3                	mov    %eax,%ebx
  800c4f:	89 c7                	mov    %eax,%edi
  800c51:	89 c6                	mov    %eax,%esi
  800c53:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6a:	89 d1                	mov    %edx,%ecx
  800c6c:	89 d3                	mov    %edx,%ebx
  800c6e:	89 d7                	mov    %edx,%edi
  800c70:	89 d6                	mov    %edx,%esi
  800c72:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c87:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	89 cb                	mov    %ecx,%ebx
  800c91:	89 cf                	mov    %ecx,%edi
  800c93:	89 ce                	mov    %ecx,%esi
  800c95:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c97:	85 c0                	test   %eax,%eax
  800c99:	7e 28                	jle    800cc3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ca6:	00 
  800ca7:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800cae:	00 
  800caf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb6:	00 
  800cb7:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800cbe:	e8 13 15 00 00       	call   8021d6 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cc3:	83 c4 2c             	add    $0x2c,%esp
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd6:	b8 02 00 00 00       	mov    $0x2,%eax
  800cdb:	89 d1                	mov    %edx,%ecx
  800cdd:	89 d3                	mov    %edx,%ebx
  800cdf:	89 d7                	mov    %edx,%edi
  800ce1:	89 d6                	mov    %edx,%esi
  800ce3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_yield>:

void
sys_yield(void)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cfa:	89 d1                	mov    %edx,%ecx
  800cfc:	89 d3                	mov    %edx,%ebx
  800cfe:	89 d7                	mov    %edx,%edi
  800d00:	89 d6                	mov    %edx,%esi
  800d02:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d12:	be 00 00 00 00       	mov    $0x0,%esi
  800d17:	b8 04 00 00 00       	mov    $0x4,%eax
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d25:	89 f7                	mov    %esi,%edi
  800d27:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 28                	jle    800d55 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d31:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d38:	00 
  800d39:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800d40:	00 
  800d41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d48:	00 
  800d49:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800d50:	e8 81 14 00 00       	call   8021d6 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d55:	83 c4 2c             	add    $0x2c,%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
  800d63:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d66:	b8 05 00 00 00       	mov    $0x5,%eax
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d74:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d77:	8b 75 18             	mov    0x18(%ebp),%esi
  800d7a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7e 28                	jle    800da8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d84:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d8b:	00 
  800d8c:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800d93:	00 
  800d94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9b:	00 
  800d9c:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800da3:	e8 2e 14 00 00       	call   8021d6 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800da8:	83 c4 2c             	add    $0x2c,%esp
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	57                   	push   %edi
  800db4:	56                   	push   %esi
  800db5:	53                   	push   %ebx
  800db6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800db9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbe:	b8 06 00 00 00       	mov    $0x6,%eax
  800dc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	89 df                	mov    %ebx,%edi
  800dcb:	89 de                	mov    %ebx,%esi
  800dcd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	7e 28                	jle    800dfb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dde:	00 
  800ddf:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800de6:	00 
  800de7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dee:	00 
  800def:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800df6:	e8 db 13 00 00       	call   8021d6 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dfb:	83 c4 2c             	add    $0x2c,%esp
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e11:	b8 08 00 00 00       	mov    $0x8,%eax
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	89 df                	mov    %ebx,%edi
  800e1e:	89 de                	mov    %ebx,%esi
  800e20:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e22:	85 c0                	test   %eax,%eax
  800e24:	7e 28                	jle    800e4e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e31:	00 
  800e32:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800e39:	00 
  800e3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e41:	00 
  800e42:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800e49:	e8 88 13 00 00       	call   8021d6 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e4e:	83 c4 2c             	add    $0x2c,%esp
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	57                   	push   %edi
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e64:	b8 09 00 00 00       	mov    $0x9,%eax
  800e69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6f:	89 df                	mov    %ebx,%edi
  800e71:	89 de                	mov    %ebx,%esi
  800e73:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e75:	85 c0                	test   %eax,%eax
  800e77:	7e 28                	jle    800ea1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e84:	00 
  800e85:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800e8c:	00 
  800e8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e94:	00 
  800e95:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800e9c:	e8 35 13 00 00       	call   8021d6 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ea1:	83 c4 2c             	add    $0x2c,%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800eb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ebc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec2:	89 df                	mov    %ebx,%edi
  800ec4:	89 de                	mov    %ebx,%esi
  800ec6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	7e 28                	jle    800ef4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ed7:	00 
  800ed8:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800edf:	00 
  800ee0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee7:	00 
  800ee8:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800eef:	e8 e2 12 00 00       	call   8021d6 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef4:	83 c4 2c             	add    $0x2c,%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	57                   	push   %edi
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f02:	be 00 00 00 00       	mov    $0x0,%esi
  800f07:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f18:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f1a:	5b                   	pop    %ebx
  800f1b:	5e                   	pop    %esi
  800f1c:	5f                   	pop    %edi
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    

00800f1f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	57                   	push   %edi
  800f23:	56                   	push   %esi
  800f24:	53                   	push   %ebx
  800f25:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f2d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f32:	8b 55 08             	mov    0x8(%ebp),%edx
  800f35:	89 cb                	mov    %ecx,%ebx
  800f37:	89 cf                	mov    %ecx,%edi
  800f39:	89 ce                	mov    %ecx,%esi
  800f3b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	7e 28                	jle    800f69 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f41:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f45:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800f54:	00 
  800f55:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5c:	00 
  800f5d:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800f64:	e8 6d 12 00 00       	call   8021d6 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f69:	83 c4 2c             	add    $0x2c,%esp
  800f6c:	5b                   	pop    %ebx
  800f6d:	5e                   	pop    %esi
  800f6e:	5f                   	pop    %edi
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    

00800f71 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	53                   	push   %ebx
  800f75:	83 ec 24             	sub    $0x24,%esp
  800f78:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f7b:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800f7d:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f81:	74 2e                	je     800fb1 <pgfault+0x40>
  800f83:	89 c2                	mov    %eax,%edx
  800f85:	c1 ea 16             	shr    $0x16,%edx
  800f88:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f8f:	f6 c2 01             	test   $0x1,%dl
  800f92:	74 1d                	je     800fb1 <pgfault+0x40>
  800f94:	89 c2                	mov    %eax,%edx
  800f96:	c1 ea 0c             	shr    $0xc,%edx
  800f99:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800fa0:	f6 c1 01             	test   $0x1,%cl
  800fa3:	74 0c                	je     800fb1 <pgfault+0x40>
  800fa5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fac:	f6 c6 08             	test   $0x8,%dh
  800faf:	75 20                	jne    800fd1 <pgfault+0x60>
		panic("pgfault: page cow check failed, addr=%x\n", addr);
  800fb1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fb5:	c7 44 24 08 2c 29 80 	movl   $0x80292c,0x8(%esp)
  800fbc:	00 
  800fbd:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800fc4:	00 
  800fc5:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  800fcc:	e8 05 12 00 00       	call   8021d6 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800fd1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fd6:	89 c3                	mov    %eax,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W))
  800fd8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fdf:	00 
  800fe0:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fe7:	00 
  800fe8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fef:	e8 15 fd ff ff       	call   800d09 <sys_page_alloc>
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	74 1c                	je     801014 <pgfault+0xa3>
		panic("pgfault: sys_page_alloc error");
  800ff8:	c7 44 24 08 1e 2a 80 	movl   $0x802a1e,0x8(%esp)
  800fff:	00 
  801000:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801007:	00 
  801008:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  80100f:	e8 c2 11 00 00       	call   8021d6 <_panic>

	memmove(PFTEMP, addr, PGSIZE);
  801014:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80101b:	00 
  80101c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801020:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801027:	e8 2a fa ff ff       	call   800a56 <memmove>
	if(sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))
  80102c:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801033:	00 
  801034:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801038:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80103f:	00 
  801040:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801047:	00 
  801048:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80104f:	e8 09 fd ff ff       	call   800d5d <sys_page_map>
  801054:	85 c0                	test   %eax,%eax
  801056:	74 1c                	je     801074 <pgfault+0x103>
		panic("pgfault: sys_page_map error");
  801058:	c7 44 24 08 3c 2a 80 	movl   $0x802a3c,0x8(%esp)
  80105f:	00 
  801060:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801067:	00 
  801068:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  80106f:	e8 62 11 00 00       	call   8021d6 <_panic>

	if(sys_page_unmap(0, PFTEMP))
  801074:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80107b:	00 
  80107c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801083:	e8 28 fd ff ff       	call   800db0 <sys_page_unmap>
  801088:	85 c0                	test   %eax,%eax
  80108a:	74 1c                	je     8010a8 <pgfault+0x137>
		panic("pgfault: sys_page_unmap error");
  80108c:	c7 44 24 08 58 2a 80 	movl   $0x802a58,0x8(%esp)
  801093:	00 
  801094:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80109b:	00 
  80109c:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  8010a3:	e8 2e 11 00 00       	call   8021d6 <_panic>
}
  8010a8:	83 c4 24             	add    $0x24,%esp
  8010ab:	5b                   	pop    %ebx
  8010ac:	5d                   	pop    %ebp
  8010ad:	c3                   	ret    

008010ae <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	57                   	push   %edi
  8010b2:	56                   	push   %esi
  8010b3:	53                   	push   %ebx
  8010b4:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	//根据文档的描述，duppage好像不应该处理除了可写或者copy-on-write的部分，但这里都交给duppage一块处理了
	set_pgfault_handler(pgfault);
  8010b7:	c7 04 24 71 0f 80 00 	movl   $0x800f71,(%esp)
  8010be:	e8 69 11 00 00       	call   80222c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010c3:	b8 07 00 00 00       	mov    $0x7,%eax
  8010c8:	cd 30                	int    $0x30
  8010ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();
	if(envid < 0)
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	79 1c                	jns    8010ed <fork+0x3f>
		//失败
		panic("fork: sys_exofork error");
  8010d1:	c7 44 24 08 76 2a 80 	movl   $0x802a76,0x8(%esp)
  8010d8:	00 
  8010d9:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
  8010e0:	00 
  8010e1:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  8010e8:	e8 e9 10 00 00       	call   8021d6 <_panic>
  8010ed:	89 c7                	mov    %eax,%edi
	else if(!envid)
  8010ef:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8010f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010f8:	75 1c                	jne    801116 <fork+0x68>
		//子进程
		thisenv = &envs[ENVX(sys_getenvid())];
  8010fa:	e8 cc fb ff ff       	call   800ccb <sys_getenvid>
  8010ff:	25 ff 03 00 00       	and    $0x3ff,%eax
  801104:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801107:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80110c:	a3 04 40 80 00       	mov    %eax,0x804004
  801111:	e9 fc 01 00 00       	jmp    801312 <fork+0x264>
	else{
		//父进程
		unsigned addr;
		for(addr = UTEXT; addr < USTACKTOP; addr += PGSIZE){
			if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))
  801116:	89 d8                	mov    %ebx,%eax
  801118:	c1 e8 16             	shr    $0x16,%eax
  80111b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801122:	a8 01                	test   $0x1,%al
  801124:	0f 84 58 01 00 00    	je     801282 <fork+0x1d4>
  80112a:	89 d8                	mov    %ebx,%eax
  80112c:	c1 e8 0c             	shr    $0xc,%eax
  80112f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801136:	f6 c2 01             	test   $0x1,%dl
  801139:	0f 84 43 01 00 00    	je     801282 <fork+0x1d4>
  80113f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801146:	f6 c2 04             	test   $0x4,%dl
  801149:	0f 84 33 01 00 00    	je     801282 <fork+0x1d4>
	void *addr = (void *)(pn * PGSIZE);
  80114f:	89 c6                	mov    %eax,%esi
  801151:	c1 e6 0c             	shl    $0xc,%esi
	if(uvpt[pn] & PTE_SHARE){
  801154:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80115b:	f6 c6 04             	test   $0x4,%dh
  80115e:	74 4c                	je     8011ac <fork+0xfe>
		if(sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL))
  801160:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801167:	25 07 0e 00 00       	and    $0xe07,%eax
  80116c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801170:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801174:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801178:	89 74 24 04          	mov    %esi,0x4(%esp)
  80117c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801183:	e8 d5 fb ff ff       	call   800d5d <sys_page_map>
  801188:	85 c0                	test   %eax,%eax
  80118a:	0f 84 f2 00 00 00    	je     801282 <fork+0x1d4>
			panic("duppage: sys_page_map pte_syscall error");
  801190:	c7 44 24 08 58 29 80 	movl   $0x802958,0x8(%esp)
  801197:	00 
  801198:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80119f:	00 
  8011a0:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  8011a7:	e8 2a 10 00 00       	call   8021d6 <_panic>
	else if(uvpt[pn] & (PTE_W | PTE_COW)){
  8011ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b3:	a9 02 08 00 00       	test   $0x802,%eax
  8011b8:	0f 84 84 00 00 00    	je     801242 <fork+0x194>
		if(sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P))
  8011be:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011c5:	00 
  8011c6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011ca:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d9:	e8 7f fb ff ff       	call   800d5d <sys_page_map>
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	74 1c                	je     8011fe <fork+0x150>
			panic("duppage: sys_page_map child error");
  8011e2:	c7 44 24 08 80 29 80 	movl   $0x802980,0x8(%esp)
  8011e9:	00 
  8011ea:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8011f1:	00 
  8011f2:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  8011f9:	e8 d8 0f 00 00       	call   8021d6 <_panic>
		if(sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P))
  8011fe:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801205:	00 
  801206:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80120a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801211:	00 
  801212:	89 74 24 04          	mov    %esi,0x4(%esp)
  801216:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80121d:	e8 3b fb ff ff       	call   800d5d <sys_page_map>
  801222:	85 c0                	test   %eax,%eax
  801224:	74 5c                	je     801282 <fork+0x1d4>
			panic("duppage: sys_page_map remap parent error");
  801226:	c7 44 24 08 a4 29 80 	movl   $0x8029a4,0x8(%esp)
  80122d:	00 
  80122e:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  801235:	00 
  801236:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  80123d:	e8 94 0f 00 00       	call   8021d6 <_panic>
		if(sys_page_map(0, addr, envid, addr, PTE_U|PTE_P))
  801242:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801249:	00 
  80124a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80124e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801252:	89 74 24 04          	mov    %esi,0x4(%esp)
  801256:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80125d:	e8 fb fa ff ff       	call   800d5d <sys_page_map>
  801262:	85 c0                	test   %eax,%eax
  801264:	74 1c                	je     801282 <fork+0x1d4>
			panic("duppage: other sys_page_map error");
  801266:	c7 44 24 08 d0 29 80 	movl   $0x8029d0,0x8(%esp)
  80126d:	00 
  80126e:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  801275:	00 
  801276:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  80127d:	e8 54 0f 00 00       	call   8021d6 <_panic>
		for(addr = UTEXT; addr < USTACKTOP; addr += PGSIZE){
  801282:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801288:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80128e:	0f 85 82 fe ff ff    	jne    801116 <fork+0x68>
				duppage(envid, PGNUM(addr));
		}
		if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W))
  801294:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80129b:	00 
  80129c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012a3:	ee 
  8012a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012a7:	89 04 24             	mov    %eax,(%esp)
  8012aa:	e8 5a fa ff ff       	call   800d09 <sys_page_alloc>
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	74 1c                	je     8012cf <fork+0x221>
			panic("fork: sys_page_alloc error");
  8012b3:	c7 44 24 08 8e 2a 80 	movl   $0x802a8e,0x8(%esp)
  8012ba:	00 
  8012bb:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  8012c2:	00 
  8012c3:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  8012ca:	e8 07 0f 00 00       	call   8021d6 <_panic>
		extern void _pgfault_upcall();
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8012cf:	c7 44 24 04 b5 22 80 	movl   $0x8022b5,0x4(%esp)
  8012d6:	00 
  8012d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012da:	89 3c 24             	mov    %edi,(%esp)
  8012dd:	e8 c7 fb ff ff       	call   800ea9 <sys_env_set_pgfault_upcall>
		if(sys_env_set_status(envid, ENV_RUNNABLE))
  8012e2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012e9:	00 
  8012ea:	89 3c 24             	mov    %edi,(%esp)
  8012ed:	e8 11 fb ff ff       	call   800e03 <sys_env_set_status>
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	74 1c                	je     801312 <fork+0x264>
			panic("fork: sys_env_set_status error");
  8012f6:	c7 44 24 08 f4 29 80 	movl   $0x8029f4,0x8(%esp)
  8012fd:	00 
  8012fe:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801305:	00 
  801306:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  80130d:	e8 c4 0e 00 00       	call   8021d6 <_panic>
	}
	return envid;
}
  801312:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801315:	83 c4 2c             	add    $0x2c,%esp
  801318:	5b                   	pop    %ebx
  801319:	5e                   	pop    %esi
  80131a:	5f                   	pop    %edi
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <sfork>:

// Challenge!
int
sfork(void)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801323:	c7 44 24 08 a9 2a 80 	movl   $0x802aa9,0x8(%esp)
  80132a:	00 
  80132b:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  801332:	00 
  801333:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  80133a:	e8 97 0e 00 00       	call   8021d6 <_panic>

0080133f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	56                   	push   %esi
  801343:	53                   	push   %ebx
  801344:	83 ec 10             	sub    $0x10,%esp
  801347:	8b 75 08             	mov    0x8(%ebp),%esi
  80134a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  80134d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801350:	89 04 24             	mov    %eax,(%esp)
  801353:	e8 c7 fb ff ff       	call   800f1f <sys_ipc_recv>
	if(from_env_store)
  801358:	85 f6                	test   %esi,%esi
  80135a:	74 14                	je     801370 <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  80135c:	ba 00 00 00 00       	mov    $0x0,%edx
  801361:	85 c0                	test   %eax,%eax
  801363:	78 09                	js     80136e <ipc_recv+0x2f>
  801365:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80136b:	8b 52 74             	mov    0x74(%edx),%edx
  80136e:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  801370:	85 db                	test   %ebx,%ebx
  801372:	74 14                	je     801388 <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  801374:	ba 00 00 00 00       	mov    $0x0,%edx
  801379:	85 c0                	test   %eax,%eax
  80137b:	78 09                	js     801386 <ipc_recv+0x47>
  80137d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801383:	8b 52 78             	mov    0x78(%edx),%edx
  801386:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 08                	js     801394 <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  80138c:	a1 04 40 80 00       	mov    0x804004,%eax
  801391:	8b 40 70             	mov    0x70(%eax),%eax
}
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	5b                   	pop    %ebx
  801398:	5e                   	pop    %esi
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    

0080139b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	57                   	push   %edi
  80139f:	56                   	push   %esi
  8013a0:	53                   	push   %ebx
  8013a1:	83 ec 1c             	sub    $0x1c,%esp
  8013a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  8013aa:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  8013af:	eb 0c                	jmp    8013bd <ipc_send+0x22>
		failed_cnt++;
  8013b1:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  8013b4:	84 db                	test   %bl,%bl
  8013b6:	75 05                	jne    8013bd <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  8013b8:	e8 2d f9 ff ff       	call   800cea <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  8013bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8013c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013cf:	89 3c 24             	mov    %edi,(%esp)
  8013d2:	e8 25 fb ff ff       	call   800efc <sys_ipc_try_send>
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	78 d6                	js     8013b1 <ipc_send+0x16>
	}
}
  8013db:	83 c4 1c             	add    $0x1c,%esp
  8013de:	5b                   	pop    %ebx
  8013df:	5e                   	pop    %esi
  8013e0:	5f                   	pop    %edi
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    

008013e3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8013e9:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8013ee:	39 c8                	cmp    %ecx,%eax
  8013f0:	74 17                	je     801409 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  8013f2:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8013f7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013fa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801400:	8b 52 50             	mov    0x50(%edx),%edx
  801403:	39 ca                	cmp    %ecx,%edx
  801405:	75 14                	jne    80141b <ipc_find_env+0x38>
  801407:	eb 05                	jmp    80140e <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  801409:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  80140e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801411:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801416:	8b 40 40             	mov    0x40(%eax),%eax
  801419:	eb 0e                	jmp    801429 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  80141b:	83 c0 01             	add    $0x1,%eax
  80141e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801423:	75 d2                	jne    8013f7 <ipc_find_env+0x14>
	return 0;
  801425:	66 b8 00 00          	mov    $0x0,%ax
}
  801429:	5d                   	pop    %ebp
  80142a:	c3                   	ret    
  80142b:	66 90                	xchg   %ax,%ax
  80142d:	66 90                	xchg   %ax,%ax
  80142f:	90                   	nop

00801430 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801433:	8b 45 08             	mov    0x8(%ebp),%eax
  801436:	05 00 00 00 30       	add    $0x30000000,%eax
  80143b:	c1 e8 0c             	shr    $0xc,%eax
}
  80143e:	5d                   	pop    %ebp
  80143f:	c3                   	ret    

00801440 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801443:	8b 45 08             	mov    0x8(%ebp),%eax
  801446:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80144b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801450:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801455:	5d                   	pop    %ebp
  801456:	c3                   	ret    

00801457 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80145a:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80145f:	a8 01                	test   $0x1,%al
  801461:	74 34                	je     801497 <fd_alloc+0x40>
  801463:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801468:	a8 01                	test   $0x1,%al
  80146a:	74 32                	je     80149e <fd_alloc+0x47>
  80146c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  801471:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801473:	89 c2                	mov    %eax,%edx
  801475:	c1 ea 16             	shr    $0x16,%edx
  801478:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80147f:	f6 c2 01             	test   $0x1,%dl
  801482:	74 1f                	je     8014a3 <fd_alloc+0x4c>
  801484:	89 c2                	mov    %eax,%edx
  801486:	c1 ea 0c             	shr    $0xc,%edx
  801489:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801490:	f6 c2 01             	test   $0x1,%dl
  801493:	75 1a                	jne    8014af <fd_alloc+0x58>
  801495:	eb 0c                	jmp    8014a3 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  801497:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80149c:	eb 05                	jmp    8014a3 <fd_alloc+0x4c>
  80149e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  8014a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a6:	89 08                	mov    %ecx,(%eax)
			return 0;
  8014a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ad:	eb 1a                	jmp    8014c9 <fd_alloc+0x72>
  8014af:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8014b4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014b9:	75 b6                	jne    801471 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  8014bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014be:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8014c4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    

008014cb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014d1:	83 f8 1f             	cmp    $0x1f,%eax
  8014d4:	77 36                	ja     80150c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014d6:	c1 e0 0c             	shl    $0xc,%eax
  8014d9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014de:	89 c2                	mov    %eax,%edx
  8014e0:	c1 ea 16             	shr    $0x16,%edx
  8014e3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014ea:	f6 c2 01             	test   $0x1,%dl
  8014ed:	74 24                	je     801513 <fd_lookup+0x48>
  8014ef:	89 c2                	mov    %eax,%edx
  8014f1:	c1 ea 0c             	shr    $0xc,%edx
  8014f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014fb:	f6 c2 01             	test   $0x1,%dl
  8014fe:	74 1a                	je     80151a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801500:	8b 55 0c             	mov    0xc(%ebp),%edx
  801503:	89 02                	mov    %eax,(%edx)
	return 0;
  801505:	b8 00 00 00 00       	mov    $0x0,%eax
  80150a:	eb 13                	jmp    80151f <fd_lookup+0x54>
		return -E_INVAL;
  80150c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801511:	eb 0c                	jmp    80151f <fd_lookup+0x54>
		return -E_INVAL;
  801513:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801518:	eb 05                	jmp    80151f <fd_lookup+0x54>
  80151a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80151f:	5d                   	pop    %ebp
  801520:	c3                   	ret    

00801521 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	53                   	push   %ebx
  801525:	83 ec 14             	sub    $0x14,%esp
  801528:	8b 45 08             	mov    0x8(%ebp),%eax
  80152b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80152e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801534:	75 1e                	jne    801554 <dev_lookup+0x33>
  801536:	eb 0e                	jmp    801546 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  801538:	b8 20 30 80 00       	mov    $0x803020,%eax
  80153d:	eb 0c                	jmp    80154b <dev_lookup+0x2a>
  80153f:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801544:	eb 05                	jmp    80154b <dev_lookup+0x2a>
  801546:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  80154b:	89 03                	mov    %eax,(%ebx)
			return 0;
  80154d:	b8 00 00 00 00       	mov    $0x0,%eax
  801552:	eb 38                	jmp    80158c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  801554:	39 05 20 30 80 00    	cmp    %eax,0x803020
  80155a:	74 dc                	je     801538 <dev_lookup+0x17>
  80155c:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  801562:	74 db                	je     80153f <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801564:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80156a:	8b 52 48             	mov    0x48(%edx),%edx
  80156d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801571:	89 54 24 04          	mov    %edx,0x4(%esp)
  801575:	c7 04 24 c0 2a 80 00 	movl   $0x802ac0,(%esp)
  80157c:	e8 7a ec ff ff       	call   8001fb <cprintf>
	*dev = 0;
  801581:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801587:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80158c:	83 c4 14             	add    $0x14,%esp
  80158f:	5b                   	pop    %ebx
  801590:	5d                   	pop    %ebp
  801591:	c3                   	ret    

00801592 <fd_close>:
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	56                   	push   %esi
  801596:	53                   	push   %ebx
  801597:	83 ec 20             	sub    $0x20,%esp
  80159a:	8b 75 08             	mov    0x8(%ebp),%esi
  80159d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a3:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015a7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015ad:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015b0:	89 04 24             	mov    %eax,(%esp)
  8015b3:	e8 13 ff ff ff       	call   8014cb <fd_lookup>
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 05                	js     8015c1 <fd_close+0x2f>
	    || fd != fd2)
  8015bc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015bf:	74 0c                	je     8015cd <fd_close+0x3b>
		return (must_exist ? r : 0);
  8015c1:	84 db                	test   %bl,%bl
  8015c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c8:	0f 44 c2             	cmove  %edx,%eax
  8015cb:	eb 3f                	jmp    80160c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d4:	8b 06                	mov    (%esi),%eax
  8015d6:	89 04 24             	mov    %eax,(%esp)
  8015d9:	e8 43 ff ff ff       	call   801521 <dev_lookup>
  8015de:	89 c3                	mov    %eax,%ebx
  8015e0:	85 c0                	test   %eax,%eax
  8015e2:	78 16                	js     8015fa <fd_close+0x68>
		if (dev->dev_close)
  8015e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e7:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8015ea:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	74 07                	je     8015fa <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8015f3:	89 34 24             	mov    %esi,(%esp)
  8015f6:	ff d0                	call   *%eax
  8015f8:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8015fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801605:	e8 a6 f7 ff ff       	call   800db0 <sys_page_unmap>
	return r;
  80160a:	89 d8                	mov    %ebx,%eax
}
  80160c:	83 c4 20             	add    $0x20,%esp
  80160f:	5b                   	pop    %ebx
  801610:	5e                   	pop    %esi
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    

00801613 <close>:

int
close(int fdnum)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801619:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801620:	8b 45 08             	mov    0x8(%ebp),%eax
  801623:	89 04 24             	mov    %eax,(%esp)
  801626:	e8 a0 fe ff ff       	call   8014cb <fd_lookup>
  80162b:	89 c2                	mov    %eax,%edx
  80162d:	85 d2                	test   %edx,%edx
  80162f:	78 13                	js     801644 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801631:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801638:	00 
  801639:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163c:	89 04 24             	mov    %eax,(%esp)
  80163f:	e8 4e ff ff ff       	call   801592 <fd_close>
}
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <close_all>:

void
close_all(void)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	53                   	push   %ebx
  80164a:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80164d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801652:	89 1c 24             	mov    %ebx,(%esp)
  801655:	e8 b9 ff ff ff       	call   801613 <close>
	for (i = 0; i < MAXFD; i++)
  80165a:	83 c3 01             	add    $0x1,%ebx
  80165d:	83 fb 20             	cmp    $0x20,%ebx
  801660:	75 f0                	jne    801652 <close_all+0xc>
}
  801662:	83 c4 14             	add    $0x14,%esp
  801665:	5b                   	pop    %ebx
  801666:	5d                   	pop    %ebp
  801667:	c3                   	ret    

00801668 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	57                   	push   %edi
  80166c:	56                   	push   %esi
  80166d:	53                   	push   %ebx
  80166e:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801671:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801674:	89 44 24 04          	mov    %eax,0x4(%esp)
  801678:	8b 45 08             	mov    0x8(%ebp),%eax
  80167b:	89 04 24             	mov    %eax,(%esp)
  80167e:	e8 48 fe ff ff       	call   8014cb <fd_lookup>
  801683:	89 c2                	mov    %eax,%edx
  801685:	85 d2                	test   %edx,%edx
  801687:	0f 88 e1 00 00 00    	js     80176e <dup+0x106>
		return r;
	close(newfdnum);
  80168d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801690:	89 04 24             	mov    %eax,(%esp)
  801693:	e8 7b ff ff ff       	call   801613 <close>

	newfd = INDEX2FD(newfdnum);
  801698:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80169b:	c1 e3 0c             	shl    $0xc,%ebx
  80169e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016a7:	89 04 24             	mov    %eax,(%esp)
  8016aa:	e8 91 fd ff ff       	call   801440 <fd2data>
  8016af:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8016b1:	89 1c 24             	mov    %ebx,(%esp)
  8016b4:	e8 87 fd ff ff       	call   801440 <fd2data>
  8016b9:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016bb:	89 f0                	mov    %esi,%eax
  8016bd:	c1 e8 16             	shr    $0x16,%eax
  8016c0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016c7:	a8 01                	test   $0x1,%al
  8016c9:	74 43                	je     80170e <dup+0xa6>
  8016cb:	89 f0                	mov    %esi,%eax
  8016cd:	c1 e8 0c             	shr    $0xc,%eax
  8016d0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016d7:	f6 c2 01             	test   $0x1,%dl
  8016da:	74 32                	je     80170e <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016e3:	25 07 0e 00 00       	and    $0xe07,%eax
  8016e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016ec:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8016f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016f7:	00 
  8016f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801703:	e8 55 f6 ff ff       	call   800d5d <sys_page_map>
  801708:	89 c6                	mov    %eax,%esi
  80170a:	85 c0                	test   %eax,%eax
  80170c:	78 3e                	js     80174c <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80170e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801711:	89 c2                	mov    %eax,%edx
  801713:	c1 ea 0c             	shr    $0xc,%edx
  801716:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80171d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801723:	89 54 24 10          	mov    %edx,0x10(%esp)
  801727:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80172b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801732:	00 
  801733:	89 44 24 04          	mov    %eax,0x4(%esp)
  801737:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80173e:	e8 1a f6 ff ff       	call   800d5d <sys_page_map>
  801743:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801745:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801748:	85 f6                	test   %esi,%esi
  80174a:	79 22                	jns    80176e <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80174c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801750:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801757:	e8 54 f6 ff ff       	call   800db0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80175c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801760:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801767:	e8 44 f6 ff ff       	call   800db0 <sys_page_unmap>
	return r;
  80176c:	89 f0                	mov    %esi,%eax
}
  80176e:	83 c4 3c             	add    $0x3c,%esp
  801771:	5b                   	pop    %ebx
  801772:	5e                   	pop    %esi
  801773:	5f                   	pop    %edi
  801774:	5d                   	pop    %ebp
  801775:	c3                   	ret    

00801776 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	53                   	push   %ebx
  80177a:	83 ec 24             	sub    $0x24,%esp
  80177d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801780:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801783:	89 44 24 04          	mov    %eax,0x4(%esp)
  801787:	89 1c 24             	mov    %ebx,(%esp)
  80178a:	e8 3c fd ff ff       	call   8014cb <fd_lookup>
  80178f:	89 c2                	mov    %eax,%edx
  801791:	85 d2                	test   %edx,%edx
  801793:	78 6d                	js     801802 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801795:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801798:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179f:	8b 00                	mov    (%eax),%eax
  8017a1:	89 04 24             	mov    %eax,(%esp)
  8017a4:	e8 78 fd ff ff       	call   801521 <dev_lookup>
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	78 55                	js     801802 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b0:	8b 50 08             	mov    0x8(%eax),%edx
  8017b3:	83 e2 03             	and    $0x3,%edx
  8017b6:	83 fa 01             	cmp    $0x1,%edx
  8017b9:	75 23                	jne    8017de <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017bb:	a1 04 40 80 00       	mov    0x804004,%eax
  8017c0:	8b 40 48             	mov    0x48(%eax),%eax
  8017c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cb:	c7 04 24 01 2b 80 00 	movl   $0x802b01,(%esp)
  8017d2:	e8 24 ea ff ff       	call   8001fb <cprintf>
		return -E_INVAL;
  8017d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017dc:	eb 24                	jmp    801802 <read+0x8c>
	}
	if (!dev->dev_read)
  8017de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e1:	8b 52 08             	mov    0x8(%edx),%edx
  8017e4:	85 d2                	test   %edx,%edx
  8017e6:	74 15                	je     8017fd <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017eb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017f6:	89 04 24             	mov    %eax,(%esp)
  8017f9:	ff d2                	call   *%edx
  8017fb:	eb 05                	jmp    801802 <read+0x8c>
		return -E_NOT_SUPP;
  8017fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801802:	83 c4 24             	add    $0x24,%esp
  801805:	5b                   	pop    %ebx
  801806:	5d                   	pop    %ebp
  801807:	c3                   	ret    

00801808 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	57                   	push   %edi
  80180c:	56                   	push   %esi
  80180d:	53                   	push   %ebx
  80180e:	83 ec 1c             	sub    $0x1c,%esp
  801811:	8b 7d 08             	mov    0x8(%ebp),%edi
  801814:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801817:	85 f6                	test   %esi,%esi
  801819:	74 33                	je     80184e <readn+0x46>
  80181b:	b8 00 00 00 00       	mov    $0x0,%eax
  801820:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801825:	89 f2                	mov    %esi,%edx
  801827:	29 c2                	sub    %eax,%edx
  801829:	89 54 24 08          	mov    %edx,0x8(%esp)
  80182d:	03 45 0c             	add    0xc(%ebp),%eax
  801830:	89 44 24 04          	mov    %eax,0x4(%esp)
  801834:	89 3c 24             	mov    %edi,(%esp)
  801837:	e8 3a ff ff ff       	call   801776 <read>
		if (m < 0)
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 1b                	js     80185b <readn+0x53>
			return m;
		if (m == 0)
  801840:	85 c0                	test   %eax,%eax
  801842:	74 11                	je     801855 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  801844:	01 c3                	add    %eax,%ebx
  801846:	89 d8                	mov    %ebx,%eax
  801848:	39 f3                	cmp    %esi,%ebx
  80184a:	72 d9                	jb     801825 <readn+0x1d>
  80184c:	eb 0b                	jmp    801859 <readn+0x51>
  80184e:	b8 00 00 00 00       	mov    $0x0,%eax
  801853:	eb 06                	jmp    80185b <readn+0x53>
  801855:	89 d8                	mov    %ebx,%eax
  801857:	eb 02                	jmp    80185b <readn+0x53>
  801859:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80185b:	83 c4 1c             	add    $0x1c,%esp
  80185e:	5b                   	pop    %ebx
  80185f:	5e                   	pop    %esi
  801860:	5f                   	pop    %edi
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	53                   	push   %ebx
  801867:	83 ec 24             	sub    $0x24,%esp
  80186a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801870:	89 44 24 04          	mov    %eax,0x4(%esp)
  801874:	89 1c 24             	mov    %ebx,(%esp)
  801877:	e8 4f fc ff ff       	call   8014cb <fd_lookup>
  80187c:	89 c2                	mov    %eax,%edx
  80187e:	85 d2                	test   %edx,%edx
  801880:	78 68                	js     8018ea <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801882:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801885:	89 44 24 04          	mov    %eax,0x4(%esp)
  801889:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188c:	8b 00                	mov    (%eax),%eax
  80188e:	89 04 24             	mov    %eax,(%esp)
  801891:	e8 8b fc ff ff       	call   801521 <dev_lookup>
  801896:	85 c0                	test   %eax,%eax
  801898:	78 50                	js     8018ea <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018a1:	75 23                	jne    8018c6 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8018a8:	8b 40 48             	mov    0x48(%eax),%eax
  8018ab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b3:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  8018ba:	e8 3c e9 ff ff       	call   8001fb <cprintf>
		return -E_INVAL;
  8018bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018c4:	eb 24                	jmp    8018ea <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c9:	8b 52 0c             	mov    0xc(%edx),%edx
  8018cc:	85 d2                	test   %edx,%edx
  8018ce:	74 15                	je     8018e5 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018da:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018de:	89 04 24             	mov    %eax,(%esp)
  8018e1:	ff d2                	call   *%edx
  8018e3:	eb 05                	jmp    8018ea <write+0x87>
		return -E_NOT_SUPP;
  8018e5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8018ea:	83 c4 24             	add    $0x24,%esp
  8018ed:	5b                   	pop    %ebx
  8018ee:	5d                   	pop    %ebp
  8018ef:	c3                   	ret    

008018f0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018f6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801900:	89 04 24             	mov    %eax,(%esp)
  801903:	e8 c3 fb ff ff       	call   8014cb <fd_lookup>
  801908:	85 c0                	test   %eax,%eax
  80190a:	78 0e                	js     80191a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80190c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80190f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801912:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801915:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191a:	c9                   	leave  
  80191b:	c3                   	ret    

0080191c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	53                   	push   %ebx
  801920:	83 ec 24             	sub    $0x24,%esp
  801923:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801926:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801929:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192d:	89 1c 24             	mov    %ebx,(%esp)
  801930:	e8 96 fb ff ff       	call   8014cb <fd_lookup>
  801935:	89 c2                	mov    %eax,%edx
  801937:	85 d2                	test   %edx,%edx
  801939:	78 61                	js     80199c <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80193b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801942:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801945:	8b 00                	mov    (%eax),%eax
  801947:	89 04 24             	mov    %eax,(%esp)
  80194a:	e8 d2 fb ff ff       	call   801521 <dev_lookup>
  80194f:	85 c0                	test   %eax,%eax
  801951:	78 49                	js     80199c <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801953:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801956:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80195a:	75 23                	jne    80197f <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80195c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801961:	8b 40 48             	mov    0x48(%eax),%eax
  801964:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801968:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196c:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  801973:	e8 83 e8 ff ff       	call   8001fb <cprintf>
		return -E_INVAL;
  801978:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80197d:	eb 1d                	jmp    80199c <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80197f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801982:	8b 52 18             	mov    0x18(%edx),%edx
  801985:	85 d2                	test   %edx,%edx
  801987:	74 0e                	je     801997 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801989:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80198c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801990:	89 04 24             	mov    %eax,(%esp)
  801993:	ff d2                	call   *%edx
  801995:	eb 05                	jmp    80199c <ftruncate+0x80>
		return -E_NOT_SUPP;
  801997:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80199c:	83 c4 24             	add    $0x24,%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5d                   	pop    %ebp
  8019a1:	c3                   	ret    

008019a2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	53                   	push   %ebx
  8019a6:	83 ec 24             	sub    $0x24,%esp
  8019a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b6:	89 04 24             	mov    %eax,(%esp)
  8019b9:	e8 0d fb ff ff       	call   8014cb <fd_lookup>
  8019be:	89 c2                	mov    %eax,%edx
  8019c0:	85 d2                	test   %edx,%edx
  8019c2:	78 52                	js     801a16 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ce:	8b 00                	mov    (%eax),%eax
  8019d0:	89 04 24             	mov    %eax,(%esp)
  8019d3:	e8 49 fb ff ff       	call   801521 <dev_lookup>
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	78 3a                	js     801a16 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8019dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019df:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019e3:	74 2c                	je     801a11 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019e5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019e8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019ef:	00 00 00 
	stat->st_isdir = 0;
  8019f2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f9:	00 00 00 
	stat->st_dev = dev;
  8019fc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a06:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a09:	89 14 24             	mov    %edx,(%esp)
  801a0c:	ff 50 14             	call   *0x14(%eax)
  801a0f:	eb 05                	jmp    801a16 <fstat+0x74>
		return -E_NOT_SUPP;
  801a11:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801a16:	83 c4 24             	add    $0x24,%esp
  801a19:	5b                   	pop    %ebx
  801a1a:	5d                   	pop    %ebp
  801a1b:	c3                   	ret    

00801a1c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	56                   	push   %esi
  801a20:	53                   	push   %ebx
  801a21:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a24:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a2b:	00 
  801a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2f:	89 04 24             	mov    %eax,(%esp)
  801a32:	e8 af 01 00 00       	call   801be6 <open>
  801a37:	89 c3                	mov    %eax,%ebx
  801a39:	85 db                	test   %ebx,%ebx
  801a3b:	78 1b                	js     801a58 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a44:	89 1c 24             	mov    %ebx,(%esp)
  801a47:	e8 56 ff ff ff       	call   8019a2 <fstat>
  801a4c:	89 c6                	mov    %eax,%esi
	close(fd);
  801a4e:	89 1c 24             	mov    %ebx,(%esp)
  801a51:	e8 bd fb ff ff       	call   801613 <close>
	return r;
  801a56:	89 f0                	mov    %esi,%eax
}
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	5b                   	pop    %ebx
  801a5c:	5e                   	pop    %esi
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    

00801a5f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	56                   	push   %esi
  801a63:	53                   	push   %ebx
  801a64:	83 ec 10             	sub    $0x10,%esp
  801a67:	89 c6                	mov    %eax,%esi
  801a69:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a6b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a72:	75 11                	jne    801a85 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a7b:	e8 63 f9 ff ff       	call   8013e3 <ipc_find_env>
  801a80:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a85:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a8c:	00 
  801a8d:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a94:	00 
  801a95:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a99:	a1 00 40 80 00       	mov    0x804000,%eax
  801a9e:	89 04 24             	mov    %eax,(%esp)
  801aa1:	e8 f5 f8 ff ff       	call   80139b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801aa6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801aad:	00 
  801aae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ab2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ab9:	e8 81 f8 ff ff       	call   80133f <ipc_recv>
}
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	5b                   	pop    %ebx
  801ac2:	5e                   	pop    %esi
  801ac3:	5d                   	pop    %ebp
  801ac4:	c3                   	ret    

00801ac5 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	53                   	push   %ebx
  801ac9:	83 ec 14             	sub    $0x14,%esp
  801acc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801acf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ada:	ba 00 00 00 00       	mov    $0x0,%edx
  801adf:	b8 05 00 00 00       	mov    $0x5,%eax
  801ae4:	e8 76 ff ff ff       	call   801a5f <fsipc>
  801ae9:	89 c2                	mov    %eax,%edx
  801aeb:	85 d2                	test   %edx,%edx
  801aed:	78 2b                	js     801b1a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801aef:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801af6:	00 
  801af7:	89 1c 24             	mov    %ebx,(%esp)
  801afa:	e8 5c ed ff ff       	call   80085b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aff:	a1 80 50 80 00       	mov    0x805080,%eax
  801b04:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b0a:	a1 84 50 80 00       	mov    0x805084,%eax
  801b0f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b1a:	83 c4 14             	add    $0x14,%esp
  801b1d:	5b                   	pop    %ebx
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    

00801b20 <devfile_flush>:
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b26:	8b 45 08             	mov    0x8(%ebp),%eax
  801b29:	8b 40 0c             	mov    0xc(%eax),%eax
  801b2c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b31:	ba 00 00 00 00       	mov    $0x0,%edx
  801b36:	b8 06 00 00 00       	mov    $0x6,%eax
  801b3b:	e8 1f ff ff ff       	call   801a5f <fsipc>
}
  801b40:	c9                   	leave  
  801b41:	c3                   	ret    

00801b42 <devfile_read>:
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	56                   	push   %esi
  801b46:	53                   	push   %ebx
  801b47:	83 ec 10             	sub    $0x10,%esp
  801b4a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b50:	8b 40 0c             	mov    0xc(%eax),%eax
  801b53:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b58:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b5e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b63:	b8 03 00 00 00       	mov    $0x3,%eax
  801b68:	e8 f2 fe ff ff       	call   801a5f <fsipc>
  801b6d:	89 c3                	mov    %eax,%ebx
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	78 6a                	js     801bdd <devfile_read+0x9b>
	assert(r <= n);
  801b73:	39 c6                	cmp    %eax,%esi
  801b75:	73 24                	jae    801b9b <devfile_read+0x59>
  801b77:	c7 44 24 0c 3a 2b 80 	movl   $0x802b3a,0xc(%esp)
  801b7e:	00 
  801b7f:	c7 44 24 08 41 2b 80 	movl   $0x802b41,0x8(%esp)
  801b86:	00 
  801b87:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  801b8e:	00 
  801b8f:	c7 04 24 56 2b 80 00 	movl   $0x802b56,(%esp)
  801b96:	e8 3b 06 00 00       	call   8021d6 <_panic>
	assert(r <= PGSIZE);
  801b9b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ba0:	7e 24                	jle    801bc6 <devfile_read+0x84>
  801ba2:	c7 44 24 0c 61 2b 80 	movl   $0x802b61,0xc(%esp)
  801ba9:	00 
  801baa:	c7 44 24 08 41 2b 80 	movl   $0x802b41,0x8(%esp)
  801bb1:	00 
  801bb2:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801bb9:	00 
  801bba:	c7 04 24 56 2b 80 00 	movl   $0x802b56,(%esp)
  801bc1:	e8 10 06 00 00       	call   8021d6 <_panic>
	memmove(buf, &fsipcbuf, r);
  801bc6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bca:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bd1:	00 
  801bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd5:	89 04 24             	mov    %eax,(%esp)
  801bd8:	e8 79 ee ff ff       	call   800a56 <memmove>
}
  801bdd:	89 d8                	mov    %ebx,%eax
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	5b                   	pop    %ebx
  801be3:	5e                   	pop    %esi
  801be4:	5d                   	pop    %ebp
  801be5:	c3                   	ret    

00801be6 <open>:
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	53                   	push   %ebx
  801bea:	83 ec 24             	sub    $0x24,%esp
  801bed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801bf0:	89 1c 24             	mov    %ebx,(%esp)
  801bf3:	e8 08 ec ff ff       	call   800800 <strlen>
  801bf8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bfd:	7f 60                	jg     801c5f <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801bff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c02:	89 04 24             	mov    %eax,(%esp)
  801c05:	e8 4d f8 ff ff       	call   801457 <fd_alloc>
  801c0a:	89 c2                	mov    %eax,%edx
  801c0c:	85 d2                	test   %edx,%edx
  801c0e:	78 54                	js     801c64 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801c10:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c14:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c1b:	e8 3b ec ff ff       	call   80085b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c23:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c28:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c2b:	b8 01 00 00 00       	mov    $0x1,%eax
  801c30:	e8 2a fe ff ff       	call   801a5f <fsipc>
  801c35:	89 c3                	mov    %eax,%ebx
  801c37:	85 c0                	test   %eax,%eax
  801c39:	79 17                	jns    801c52 <open+0x6c>
		fd_close(fd, 0);
  801c3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c42:	00 
  801c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c46:	89 04 24             	mov    %eax,(%esp)
  801c49:	e8 44 f9 ff ff       	call   801592 <fd_close>
		return r;
  801c4e:	89 d8                	mov    %ebx,%eax
  801c50:	eb 12                	jmp    801c64 <open+0x7e>
	return fd2num(fd);
  801c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c55:	89 04 24             	mov    %eax,(%esp)
  801c58:	e8 d3 f7 ff ff       	call   801430 <fd2num>
  801c5d:	eb 05                	jmp    801c64 <open+0x7e>
		return -E_BAD_PATH;
  801c5f:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801c64:	83 c4 24             	add    $0x24,%esp
  801c67:	5b                   	pop    %ebx
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    
  801c6a:	66 90                	xchg   %ax,%ax
  801c6c:	66 90                	xchg   %ax,%ax
  801c6e:	66 90                	xchg   %ax,%ax

00801c70 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	56                   	push   %esi
  801c74:	53                   	push   %ebx
  801c75:	83 ec 10             	sub    $0x10,%esp
  801c78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7e:	89 04 24             	mov    %eax,(%esp)
  801c81:	e8 ba f7 ff ff       	call   801440 <fd2data>
  801c86:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c88:	c7 44 24 04 6d 2b 80 	movl   $0x802b6d,0x4(%esp)
  801c8f:	00 
  801c90:	89 1c 24             	mov    %ebx,(%esp)
  801c93:	e8 c3 eb ff ff       	call   80085b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c98:	8b 46 04             	mov    0x4(%esi),%eax
  801c9b:	2b 06                	sub    (%esi),%eax
  801c9d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ca3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801caa:	00 00 00 
	stat->st_dev = &devpipe;
  801cad:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801cb4:	30 80 00 
	return 0;
}
  801cb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbc:	83 c4 10             	add    $0x10,%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5d                   	pop    %ebp
  801cc2:	c3                   	ret    

00801cc3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cc3:	55                   	push   %ebp
  801cc4:	89 e5                	mov    %esp,%ebp
  801cc6:	53                   	push   %ebx
  801cc7:	83 ec 14             	sub    $0x14,%esp
  801cca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ccd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd8:	e8 d3 f0 ff ff       	call   800db0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cdd:	89 1c 24             	mov    %ebx,(%esp)
  801ce0:	e8 5b f7 ff ff       	call   801440 <fd2data>
  801ce5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf0:	e8 bb f0 ff ff       	call   800db0 <sys_page_unmap>
}
  801cf5:	83 c4 14             	add    $0x14,%esp
  801cf8:	5b                   	pop    %ebx
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <_pipeisclosed>:
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	57                   	push   %edi
  801cff:	56                   	push   %esi
  801d00:	53                   	push   %ebx
  801d01:	83 ec 2c             	sub    $0x2c,%esp
  801d04:	89 c6                	mov    %eax,%esi
  801d06:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801d09:	a1 04 40 80 00       	mov    0x804004,%eax
  801d0e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d11:	89 34 24             	mov    %esi,(%esp)
  801d14:	e8 c0 05 00 00       	call   8022d9 <pageref>
  801d19:	89 c7                	mov    %eax,%edi
  801d1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d1e:	89 04 24             	mov    %eax,(%esp)
  801d21:	e8 b3 05 00 00       	call   8022d9 <pageref>
  801d26:	39 c7                	cmp    %eax,%edi
  801d28:	0f 94 c2             	sete   %dl
  801d2b:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801d2e:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801d34:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801d37:	39 fb                	cmp    %edi,%ebx
  801d39:	74 21                	je     801d5c <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801d3b:	84 d2                	test   %dl,%dl
  801d3d:	74 ca                	je     801d09 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d3f:	8b 51 58             	mov    0x58(%ecx),%edx
  801d42:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d46:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d4e:	c7 04 24 74 2b 80 00 	movl   $0x802b74,(%esp)
  801d55:	e8 a1 e4 ff ff       	call   8001fb <cprintf>
  801d5a:	eb ad                	jmp    801d09 <_pipeisclosed+0xe>
}
  801d5c:	83 c4 2c             	add    $0x2c,%esp
  801d5f:	5b                   	pop    %ebx
  801d60:	5e                   	pop    %esi
  801d61:	5f                   	pop    %edi
  801d62:	5d                   	pop    %ebp
  801d63:	c3                   	ret    

00801d64 <devpipe_write>:
{
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
  801d67:	57                   	push   %edi
  801d68:	56                   	push   %esi
  801d69:	53                   	push   %ebx
  801d6a:	83 ec 1c             	sub    $0x1c,%esp
  801d6d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d70:	89 34 24             	mov    %esi,(%esp)
  801d73:	e8 c8 f6 ff ff       	call   801440 <fd2data>
	for (i = 0; i < n; i++) {
  801d78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d7c:	74 61                	je     801ddf <devpipe_write+0x7b>
  801d7e:	89 c3                	mov    %eax,%ebx
  801d80:	bf 00 00 00 00       	mov    $0x0,%edi
  801d85:	eb 4a                	jmp    801dd1 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  801d87:	89 da                	mov    %ebx,%edx
  801d89:	89 f0                	mov    %esi,%eax
  801d8b:	e8 6b ff ff ff       	call   801cfb <_pipeisclosed>
  801d90:	85 c0                	test   %eax,%eax
  801d92:	75 54                	jne    801de8 <devpipe_write+0x84>
			sys_yield();
  801d94:	e8 51 ef ff ff       	call   800cea <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d99:	8b 43 04             	mov    0x4(%ebx),%eax
  801d9c:	8b 0b                	mov    (%ebx),%ecx
  801d9e:	8d 51 20             	lea    0x20(%ecx),%edx
  801da1:	39 d0                	cmp    %edx,%eax
  801da3:	73 e2                	jae    801d87 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801da5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801da8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dac:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801daf:	99                   	cltd   
  801db0:	c1 ea 1b             	shr    $0x1b,%edx
  801db3:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801db6:	83 e1 1f             	and    $0x1f,%ecx
  801db9:	29 d1                	sub    %edx,%ecx
  801dbb:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801dbf:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801dc3:	83 c0 01             	add    $0x1,%eax
  801dc6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801dc9:	83 c7 01             	add    $0x1,%edi
  801dcc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dcf:	74 13                	je     801de4 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dd1:	8b 43 04             	mov    0x4(%ebx),%eax
  801dd4:	8b 0b                	mov    (%ebx),%ecx
  801dd6:	8d 51 20             	lea    0x20(%ecx),%edx
  801dd9:	39 d0                	cmp    %edx,%eax
  801ddb:	73 aa                	jae    801d87 <devpipe_write+0x23>
  801ddd:	eb c6                	jmp    801da5 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  801ddf:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  801de4:	89 f8                	mov    %edi,%eax
  801de6:	eb 05                	jmp    801ded <devpipe_write+0x89>
				return 0;
  801de8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ded:	83 c4 1c             	add    $0x1c,%esp
  801df0:	5b                   	pop    %ebx
  801df1:	5e                   	pop    %esi
  801df2:	5f                   	pop    %edi
  801df3:	5d                   	pop    %ebp
  801df4:	c3                   	ret    

00801df5 <devpipe_read>:
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	57                   	push   %edi
  801df9:	56                   	push   %esi
  801dfa:	53                   	push   %ebx
  801dfb:	83 ec 1c             	sub    $0x1c,%esp
  801dfe:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e01:	89 3c 24             	mov    %edi,(%esp)
  801e04:	e8 37 f6 ff ff       	call   801440 <fd2data>
	for (i = 0; i < n; i++) {
  801e09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e0d:	74 54                	je     801e63 <devpipe_read+0x6e>
  801e0f:	89 c3                	mov    %eax,%ebx
  801e11:	be 00 00 00 00       	mov    $0x0,%esi
  801e16:	eb 3e                	jmp    801e56 <devpipe_read+0x61>
				return i;
  801e18:	89 f0                	mov    %esi,%eax
  801e1a:	eb 55                	jmp    801e71 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  801e1c:	89 da                	mov    %ebx,%edx
  801e1e:	89 f8                	mov    %edi,%eax
  801e20:	e8 d6 fe ff ff       	call   801cfb <_pipeisclosed>
  801e25:	85 c0                	test   %eax,%eax
  801e27:	75 43                	jne    801e6c <devpipe_read+0x77>
			sys_yield();
  801e29:	e8 bc ee ff ff       	call   800cea <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e2e:	8b 03                	mov    (%ebx),%eax
  801e30:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e33:	74 e7                	je     801e1c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e35:	99                   	cltd   
  801e36:	c1 ea 1b             	shr    $0x1b,%edx
  801e39:	01 d0                	add    %edx,%eax
  801e3b:	83 e0 1f             	and    $0x1f,%eax
  801e3e:	29 d0                	sub    %edx,%eax
  801e40:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e48:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e4b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e4e:	83 c6 01             	add    $0x1,%esi
  801e51:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e54:	74 12                	je     801e68 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  801e56:	8b 03                	mov    (%ebx),%eax
  801e58:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e5b:	75 d8                	jne    801e35 <devpipe_read+0x40>
			if (i > 0)
  801e5d:	85 f6                	test   %esi,%esi
  801e5f:	75 b7                	jne    801e18 <devpipe_read+0x23>
  801e61:	eb b9                	jmp    801e1c <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  801e63:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  801e68:	89 f0                	mov    %esi,%eax
  801e6a:	eb 05                	jmp    801e71 <devpipe_read+0x7c>
				return 0;
  801e6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e71:	83 c4 1c             	add    $0x1c,%esp
  801e74:	5b                   	pop    %ebx
  801e75:	5e                   	pop    %esi
  801e76:	5f                   	pop    %edi
  801e77:	5d                   	pop    %ebp
  801e78:	c3                   	ret    

00801e79 <pipe>:
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	56                   	push   %esi
  801e7d:	53                   	push   %ebx
  801e7e:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e84:	89 04 24             	mov    %eax,(%esp)
  801e87:	e8 cb f5 ff ff       	call   801457 <fd_alloc>
  801e8c:	89 c2                	mov    %eax,%edx
  801e8e:	85 d2                	test   %edx,%edx
  801e90:	0f 88 4d 01 00 00    	js     801fe3 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e96:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e9d:	00 
  801e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eac:	e8 58 ee ff ff       	call   800d09 <sys_page_alloc>
  801eb1:	89 c2                	mov    %eax,%edx
  801eb3:	85 d2                	test   %edx,%edx
  801eb5:	0f 88 28 01 00 00    	js     801fe3 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801ebb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ebe:	89 04 24             	mov    %eax,(%esp)
  801ec1:	e8 91 f5 ff ff       	call   801457 <fd_alloc>
  801ec6:	89 c3                	mov    %eax,%ebx
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	0f 88 fe 00 00 00    	js     801fce <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ed0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ed7:	00 
  801ed8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801edb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801edf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee6:	e8 1e ee ff ff       	call   800d09 <sys_page_alloc>
  801eeb:	89 c3                	mov    %eax,%ebx
  801eed:	85 c0                	test   %eax,%eax
  801eef:	0f 88 d9 00 00 00    	js     801fce <pipe+0x155>
	va = fd2data(fd0);
  801ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef8:	89 04 24             	mov    %eax,(%esp)
  801efb:	e8 40 f5 ff ff       	call   801440 <fd2data>
  801f00:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f02:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f09:	00 
  801f0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f15:	e8 ef ed ff ff       	call   800d09 <sys_page_alloc>
  801f1a:	89 c3                	mov    %eax,%ebx
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	0f 88 97 00 00 00    	js     801fbb <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f27:	89 04 24             	mov    %eax,(%esp)
  801f2a:	e8 11 f5 ff ff       	call   801440 <fd2data>
  801f2f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f36:	00 
  801f37:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f3b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f42:	00 
  801f43:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f4e:	e8 0a ee ff ff       	call   800d5d <sys_page_map>
  801f53:	89 c3                	mov    %eax,%ebx
  801f55:	85 c0                	test   %eax,%eax
  801f57:	78 52                	js     801fab <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801f59:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f62:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f67:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801f6e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f77:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f7c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f86:	89 04 24             	mov    %eax,(%esp)
  801f89:	e8 a2 f4 ff ff       	call   801430 <fd2num>
  801f8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f91:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f96:	89 04 24             	mov    %eax,(%esp)
  801f99:	e8 92 f4 ff ff       	call   801430 <fd2num>
  801f9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fa1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fa4:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa9:	eb 38                	jmp    801fe3 <pipe+0x16a>
	sys_page_unmap(0, va);
  801fab:	89 74 24 04          	mov    %esi,0x4(%esp)
  801faf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb6:	e8 f5 ed ff ff       	call   800db0 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801fbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc9:	e8 e2 ed ff ff       	call   800db0 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fdc:	e8 cf ed ff ff       	call   800db0 <sys_page_unmap>
  801fe1:	89 d8                	mov    %ebx,%eax
}
  801fe3:	83 c4 30             	add    $0x30,%esp
  801fe6:	5b                   	pop    %ebx
  801fe7:	5e                   	pop    %esi
  801fe8:	5d                   	pop    %ebp
  801fe9:	c3                   	ret    

00801fea <pipeisclosed>:
{
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff7:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffa:	89 04 24             	mov    %eax,(%esp)
  801ffd:	e8 c9 f4 ff ff       	call   8014cb <fd_lookup>
  802002:	89 c2                	mov    %eax,%edx
  802004:	85 d2                	test   %edx,%edx
  802006:	78 15                	js     80201d <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  802008:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200b:	89 04 24             	mov    %eax,(%esp)
  80200e:	e8 2d f4 ff ff       	call   801440 <fd2data>
	return _pipeisclosed(fd, p);
  802013:	89 c2                	mov    %eax,%edx
  802015:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802018:	e8 de fc ff ff       	call   801cfb <_pipeisclosed>
}
  80201d:	c9                   	leave  
  80201e:	c3                   	ret    
  80201f:	90                   	nop

00802020 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802023:	b8 00 00 00 00       	mov    $0x0,%eax
  802028:	5d                   	pop    %ebp
  802029:	c3                   	ret    

0080202a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80202a:	55                   	push   %ebp
  80202b:	89 e5                	mov    %esp,%ebp
  80202d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802030:	c7 44 24 04 8c 2b 80 	movl   $0x802b8c,0x4(%esp)
  802037:	00 
  802038:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203b:	89 04 24             	mov    %eax,(%esp)
  80203e:	e8 18 e8 ff ff       	call   80085b <strcpy>
	return 0;
}
  802043:	b8 00 00 00 00       	mov    $0x0,%eax
  802048:	c9                   	leave  
  802049:	c3                   	ret    

0080204a <devcons_write>:
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	57                   	push   %edi
  80204e:	56                   	push   %esi
  80204f:	53                   	push   %ebx
  802050:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  802056:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80205a:	74 4a                	je     8020a6 <devcons_write+0x5c>
  80205c:	b8 00 00 00 00       	mov    $0x0,%eax
  802061:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802066:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  80206c:	8b 75 10             	mov    0x10(%ebp),%esi
  80206f:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  802071:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  802074:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802079:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80207c:	89 74 24 08          	mov    %esi,0x8(%esp)
  802080:	03 45 0c             	add    0xc(%ebp),%eax
  802083:	89 44 24 04          	mov    %eax,0x4(%esp)
  802087:	89 3c 24             	mov    %edi,(%esp)
  80208a:	e8 c7 e9 ff ff       	call   800a56 <memmove>
		sys_cputs(buf, m);
  80208f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802093:	89 3c 24             	mov    %edi,(%esp)
  802096:	e8 a1 eb ff ff       	call   800c3c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80209b:	01 f3                	add    %esi,%ebx
  80209d:	89 d8                	mov    %ebx,%eax
  80209f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020a2:	72 c8                	jb     80206c <devcons_write+0x22>
  8020a4:	eb 05                	jmp    8020ab <devcons_write+0x61>
  8020a6:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  8020ab:	89 d8                	mov    %ebx,%eax
  8020ad:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    

008020b8 <devcons_read>:
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	83 ec 08             	sub    $0x8,%esp
		return 0;
  8020be:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8020c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020c7:	75 07                	jne    8020d0 <devcons_read+0x18>
  8020c9:	eb 28                	jmp    8020f3 <devcons_read+0x3b>
		sys_yield();
  8020cb:	e8 1a ec ff ff       	call   800cea <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8020d0:	e8 85 eb ff ff       	call   800c5a <sys_cgetc>
  8020d5:	85 c0                	test   %eax,%eax
  8020d7:	74 f2                	je     8020cb <devcons_read+0x13>
	if (c < 0)
  8020d9:	85 c0                	test   %eax,%eax
  8020db:	78 16                	js     8020f3 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  8020dd:	83 f8 04             	cmp    $0x4,%eax
  8020e0:	74 0c                	je     8020ee <devcons_read+0x36>
	*(char*)vbuf = c;
  8020e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020e5:	88 02                	mov    %al,(%edx)
	return 1;
  8020e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ec:	eb 05                	jmp    8020f3 <devcons_read+0x3b>
		return 0;
  8020ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020f3:	c9                   	leave  
  8020f4:	c3                   	ret    

008020f5 <cputchar>:
{
  8020f5:	55                   	push   %ebp
  8020f6:	89 e5                	mov    %esp,%ebp
  8020f8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8020fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fe:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802101:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802108:	00 
  802109:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80210c:	89 04 24             	mov    %eax,(%esp)
  80210f:	e8 28 eb ff ff       	call   800c3c <sys_cputs>
}
  802114:	c9                   	leave  
  802115:	c3                   	ret    

00802116 <getchar>:
{
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80211c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802123:	00 
  802124:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802127:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802132:	e8 3f f6 ff ff       	call   801776 <read>
	if (r < 0)
  802137:	85 c0                	test   %eax,%eax
  802139:	78 0f                	js     80214a <getchar+0x34>
	if (r < 1)
  80213b:	85 c0                	test   %eax,%eax
  80213d:	7e 06                	jle    802145 <getchar+0x2f>
	return c;
  80213f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802143:	eb 05                	jmp    80214a <getchar+0x34>
		return -E_EOF;
  802145:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80214a:	c9                   	leave  
  80214b:	c3                   	ret    

0080214c <iscons>:
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
  80214f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802152:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802155:	89 44 24 04          	mov    %eax,0x4(%esp)
  802159:	8b 45 08             	mov    0x8(%ebp),%eax
  80215c:	89 04 24             	mov    %eax,(%esp)
  80215f:	e8 67 f3 ff ff       	call   8014cb <fd_lookup>
  802164:	85 c0                	test   %eax,%eax
  802166:	78 11                	js     802179 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  802168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802171:	39 10                	cmp    %edx,(%eax)
  802173:	0f 94 c0             	sete   %al
  802176:	0f b6 c0             	movzbl %al,%eax
}
  802179:	c9                   	leave  
  80217a:	c3                   	ret    

0080217b <opencons>:
{
  80217b:	55                   	push   %ebp
  80217c:	89 e5                	mov    %esp,%ebp
  80217e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802181:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802184:	89 04 24             	mov    %eax,(%esp)
  802187:	e8 cb f2 ff ff       	call   801457 <fd_alloc>
		return r;
  80218c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80218e:	85 c0                	test   %eax,%eax
  802190:	78 40                	js     8021d2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802192:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802199:	00 
  80219a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80219d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a8:	e8 5c eb ff ff       	call   800d09 <sys_page_alloc>
		return r;
  8021ad:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021af:	85 c0                	test   %eax,%eax
  8021b1:	78 1f                	js     8021d2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  8021b3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021bc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021c8:	89 04 24             	mov    %eax,(%esp)
  8021cb:	e8 60 f2 ff ff       	call   801430 <fd2num>
  8021d0:	89 c2                	mov    %eax,%edx
}
  8021d2:	89 d0                	mov    %edx,%eax
  8021d4:	c9                   	leave  
  8021d5:	c3                   	ret    

008021d6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	56                   	push   %esi
  8021da:	53                   	push   %ebx
  8021db:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8021de:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8021e1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8021e7:	e8 df ea ff ff       	call   800ccb <sys_getenvid>
  8021ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021ef:	89 54 24 10          	mov    %edx,0x10(%esp)
  8021f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8021f6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021fa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8021fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  802202:	c7 04 24 98 2b 80 00 	movl   $0x802b98,(%esp)
  802209:	e8 ed df ff ff       	call   8001fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80220e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802212:	8b 45 10             	mov    0x10(%ebp),%eax
  802215:	89 04 24             	mov    %eax,(%esp)
  802218:	e8 7d df ff ff       	call   80019a <vcprintf>
	cprintf("\n");
  80221d:	c7 04 24 85 2b 80 00 	movl   $0x802b85,(%esp)
  802224:	e8 d2 df ff ff       	call   8001fb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802229:	cc                   	int3   
  80222a:	eb fd                	jmp    802229 <_panic+0x53>

0080222c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802232:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802239:	75 70                	jne    8022ab <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  80223b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802242:	00 
  802243:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80224a:	ee 
  80224b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802252:	e8 b2 ea ff ff       	call   800d09 <sys_page_alloc>
  802257:	85 c0                	test   %eax,%eax
  802259:	79 1c                	jns    802277 <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  80225b:	c7 44 24 08 bc 2b 80 	movl   $0x802bbc,0x8(%esp)
  802262:	00 
  802263:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80226a:	00 
  80226b:	c7 04 24 20 2c 80 00 	movl   $0x802c20,(%esp)
  802272:	e8 5f ff ff ff       	call   8021d6 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802277:	c7 44 24 04 b5 22 80 	movl   $0x8022b5,0x4(%esp)
  80227e:	00 
  80227f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802286:	e8 1e ec ff ff       	call   800ea9 <sys_env_set_pgfault_upcall>
  80228b:	85 c0                	test   %eax,%eax
  80228d:	79 1c                	jns    8022ab <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  80228f:	c7 44 24 08 e8 2b 80 	movl   $0x802be8,0x8(%esp)
  802296:	00 
  802297:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  80229e:	00 
  80229f:	c7 04 24 20 2c 80 00 	movl   $0x802c20,(%esp)
  8022a6:	e8 2b ff ff ff       	call   8021d6 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ae:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8022b3:	c9                   	leave  
  8022b4:	c3                   	ret    

008022b5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022b5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022b6:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8022bb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022bd:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  8022c0:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  8022c4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  8022c9:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  8022cd:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8022cf:	83 c4 08             	add    $0x8,%esp
	popal
  8022d2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8022d3:	83 c4 04             	add    $0x4,%esp
	popfl
  8022d6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8022d7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8022d8:	c3                   	ret    

008022d9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022df:	89 d0                	mov    %edx,%eax
  8022e1:	c1 e8 16             	shr    $0x16,%eax
  8022e4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022eb:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8022f0:	f6 c1 01             	test   $0x1,%cl
  8022f3:	74 1d                	je     802312 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8022f5:	c1 ea 0c             	shr    $0xc,%edx
  8022f8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022ff:	f6 c2 01             	test   $0x1,%dl
  802302:	74 0e                	je     802312 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802304:	c1 ea 0c             	shr    $0xc,%edx
  802307:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80230e:	ef 
  80230f:	0f b7 c0             	movzwl %ax,%eax
}
  802312:	5d                   	pop    %ebp
  802313:	c3                   	ret    
  802314:	66 90                	xchg   %ax,%ax
  802316:	66 90                	xchg   %ax,%ax
  802318:	66 90                	xchg   %ax,%ax
  80231a:	66 90                	xchg   %ax,%ax
  80231c:	66 90                	xchg   %ax,%ax
  80231e:	66 90                	xchg   %ax,%ax

00802320 <__udivdi3>:
  802320:	55                   	push   %ebp
  802321:	57                   	push   %edi
  802322:	56                   	push   %esi
  802323:	83 ec 0c             	sub    $0xc,%esp
  802326:	8b 44 24 28          	mov    0x28(%esp),%eax
  80232a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80232e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802332:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802336:	85 c0                	test   %eax,%eax
  802338:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80233c:	89 ea                	mov    %ebp,%edx
  80233e:	89 0c 24             	mov    %ecx,(%esp)
  802341:	75 2d                	jne    802370 <__udivdi3+0x50>
  802343:	39 e9                	cmp    %ebp,%ecx
  802345:	77 61                	ja     8023a8 <__udivdi3+0x88>
  802347:	85 c9                	test   %ecx,%ecx
  802349:	89 ce                	mov    %ecx,%esi
  80234b:	75 0b                	jne    802358 <__udivdi3+0x38>
  80234d:	b8 01 00 00 00       	mov    $0x1,%eax
  802352:	31 d2                	xor    %edx,%edx
  802354:	f7 f1                	div    %ecx
  802356:	89 c6                	mov    %eax,%esi
  802358:	31 d2                	xor    %edx,%edx
  80235a:	89 e8                	mov    %ebp,%eax
  80235c:	f7 f6                	div    %esi
  80235e:	89 c5                	mov    %eax,%ebp
  802360:	89 f8                	mov    %edi,%eax
  802362:	f7 f6                	div    %esi
  802364:	89 ea                	mov    %ebp,%edx
  802366:	83 c4 0c             	add    $0xc,%esp
  802369:	5e                   	pop    %esi
  80236a:	5f                   	pop    %edi
  80236b:	5d                   	pop    %ebp
  80236c:	c3                   	ret    
  80236d:	8d 76 00             	lea    0x0(%esi),%esi
  802370:	39 e8                	cmp    %ebp,%eax
  802372:	77 24                	ja     802398 <__udivdi3+0x78>
  802374:	0f bd e8             	bsr    %eax,%ebp
  802377:	83 f5 1f             	xor    $0x1f,%ebp
  80237a:	75 3c                	jne    8023b8 <__udivdi3+0x98>
  80237c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802380:	39 34 24             	cmp    %esi,(%esp)
  802383:	0f 86 9f 00 00 00    	jbe    802428 <__udivdi3+0x108>
  802389:	39 d0                	cmp    %edx,%eax
  80238b:	0f 82 97 00 00 00    	jb     802428 <__udivdi3+0x108>
  802391:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802398:	31 d2                	xor    %edx,%edx
  80239a:	31 c0                	xor    %eax,%eax
  80239c:	83 c4 0c             	add    $0xc,%esp
  80239f:	5e                   	pop    %esi
  8023a0:	5f                   	pop    %edi
  8023a1:	5d                   	pop    %ebp
  8023a2:	c3                   	ret    
  8023a3:	90                   	nop
  8023a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	89 f8                	mov    %edi,%eax
  8023aa:	f7 f1                	div    %ecx
  8023ac:	31 d2                	xor    %edx,%edx
  8023ae:	83 c4 0c             	add    $0xc,%esp
  8023b1:	5e                   	pop    %esi
  8023b2:	5f                   	pop    %edi
  8023b3:	5d                   	pop    %ebp
  8023b4:	c3                   	ret    
  8023b5:	8d 76 00             	lea    0x0(%esi),%esi
  8023b8:	89 e9                	mov    %ebp,%ecx
  8023ba:	8b 3c 24             	mov    (%esp),%edi
  8023bd:	d3 e0                	shl    %cl,%eax
  8023bf:	89 c6                	mov    %eax,%esi
  8023c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8023c6:	29 e8                	sub    %ebp,%eax
  8023c8:	89 c1                	mov    %eax,%ecx
  8023ca:	d3 ef                	shr    %cl,%edi
  8023cc:	89 e9                	mov    %ebp,%ecx
  8023ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8023d2:	8b 3c 24             	mov    (%esp),%edi
  8023d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8023d9:	89 d6                	mov    %edx,%esi
  8023db:	d3 e7                	shl    %cl,%edi
  8023dd:	89 c1                	mov    %eax,%ecx
  8023df:	89 3c 24             	mov    %edi,(%esp)
  8023e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023e6:	d3 ee                	shr    %cl,%esi
  8023e8:	89 e9                	mov    %ebp,%ecx
  8023ea:	d3 e2                	shl    %cl,%edx
  8023ec:	89 c1                	mov    %eax,%ecx
  8023ee:	d3 ef                	shr    %cl,%edi
  8023f0:	09 d7                	or     %edx,%edi
  8023f2:	89 f2                	mov    %esi,%edx
  8023f4:	89 f8                	mov    %edi,%eax
  8023f6:	f7 74 24 08          	divl   0x8(%esp)
  8023fa:	89 d6                	mov    %edx,%esi
  8023fc:	89 c7                	mov    %eax,%edi
  8023fe:	f7 24 24             	mull   (%esp)
  802401:	39 d6                	cmp    %edx,%esi
  802403:	89 14 24             	mov    %edx,(%esp)
  802406:	72 30                	jb     802438 <__udivdi3+0x118>
  802408:	8b 54 24 04          	mov    0x4(%esp),%edx
  80240c:	89 e9                	mov    %ebp,%ecx
  80240e:	d3 e2                	shl    %cl,%edx
  802410:	39 c2                	cmp    %eax,%edx
  802412:	73 05                	jae    802419 <__udivdi3+0xf9>
  802414:	3b 34 24             	cmp    (%esp),%esi
  802417:	74 1f                	je     802438 <__udivdi3+0x118>
  802419:	89 f8                	mov    %edi,%eax
  80241b:	31 d2                	xor    %edx,%edx
  80241d:	e9 7a ff ff ff       	jmp    80239c <__udivdi3+0x7c>
  802422:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802428:	31 d2                	xor    %edx,%edx
  80242a:	b8 01 00 00 00       	mov    $0x1,%eax
  80242f:	e9 68 ff ff ff       	jmp    80239c <__udivdi3+0x7c>
  802434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802438:	8d 47 ff             	lea    -0x1(%edi),%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	83 c4 0c             	add    $0xc,%esp
  802440:	5e                   	pop    %esi
  802441:	5f                   	pop    %edi
  802442:	5d                   	pop    %ebp
  802443:	c3                   	ret    
  802444:	66 90                	xchg   %ax,%ax
  802446:	66 90                	xchg   %ax,%ax
  802448:	66 90                	xchg   %ax,%ax
  80244a:	66 90                	xchg   %ax,%ax
  80244c:	66 90                	xchg   %ax,%ax
  80244e:	66 90                	xchg   %ax,%ax

00802450 <__umoddi3>:
  802450:	55                   	push   %ebp
  802451:	57                   	push   %edi
  802452:	56                   	push   %esi
  802453:	83 ec 14             	sub    $0x14,%esp
  802456:	8b 44 24 28          	mov    0x28(%esp),%eax
  80245a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80245e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802462:	89 c7                	mov    %eax,%edi
  802464:	89 44 24 04          	mov    %eax,0x4(%esp)
  802468:	8b 44 24 30          	mov    0x30(%esp),%eax
  80246c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802470:	89 34 24             	mov    %esi,(%esp)
  802473:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802477:	85 c0                	test   %eax,%eax
  802479:	89 c2                	mov    %eax,%edx
  80247b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80247f:	75 17                	jne    802498 <__umoddi3+0x48>
  802481:	39 fe                	cmp    %edi,%esi
  802483:	76 4b                	jbe    8024d0 <__umoddi3+0x80>
  802485:	89 c8                	mov    %ecx,%eax
  802487:	89 fa                	mov    %edi,%edx
  802489:	f7 f6                	div    %esi
  80248b:	89 d0                	mov    %edx,%eax
  80248d:	31 d2                	xor    %edx,%edx
  80248f:	83 c4 14             	add    $0x14,%esp
  802492:	5e                   	pop    %esi
  802493:	5f                   	pop    %edi
  802494:	5d                   	pop    %ebp
  802495:	c3                   	ret    
  802496:	66 90                	xchg   %ax,%ax
  802498:	39 f8                	cmp    %edi,%eax
  80249a:	77 54                	ja     8024f0 <__umoddi3+0xa0>
  80249c:	0f bd e8             	bsr    %eax,%ebp
  80249f:	83 f5 1f             	xor    $0x1f,%ebp
  8024a2:	75 5c                	jne    802500 <__umoddi3+0xb0>
  8024a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8024a8:	39 3c 24             	cmp    %edi,(%esp)
  8024ab:	0f 87 e7 00 00 00    	ja     802598 <__umoddi3+0x148>
  8024b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024b5:	29 f1                	sub    %esi,%ecx
  8024b7:	19 c7                	sbb    %eax,%edi
  8024b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024c9:	83 c4 14             	add    $0x14,%esp
  8024cc:	5e                   	pop    %esi
  8024cd:	5f                   	pop    %edi
  8024ce:	5d                   	pop    %ebp
  8024cf:	c3                   	ret    
  8024d0:	85 f6                	test   %esi,%esi
  8024d2:	89 f5                	mov    %esi,%ebp
  8024d4:	75 0b                	jne    8024e1 <__umoddi3+0x91>
  8024d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024db:	31 d2                	xor    %edx,%edx
  8024dd:	f7 f6                	div    %esi
  8024df:	89 c5                	mov    %eax,%ebp
  8024e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8024e5:	31 d2                	xor    %edx,%edx
  8024e7:	f7 f5                	div    %ebp
  8024e9:	89 c8                	mov    %ecx,%eax
  8024eb:	f7 f5                	div    %ebp
  8024ed:	eb 9c                	jmp    80248b <__umoddi3+0x3b>
  8024ef:	90                   	nop
  8024f0:	89 c8                	mov    %ecx,%eax
  8024f2:	89 fa                	mov    %edi,%edx
  8024f4:	83 c4 14             	add    $0x14,%esp
  8024f7:	5e                   	pop    %esi
  8024f8:	5f                   	pop    %edi
  8024f9:	5d                   	pop    %ebp
  8024fa:	c3                   	ret    
  8024fb:	90                   	nop
  8024fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802500:	8b 04 24             	mov    (%esp),%eax
  802503:	be 20 00 00 00       	mov    $0x20,%esi
  802508:	89 e9                	mov    %ebp,%ecx
  80250a:	29 ee                	sub    %ebp,%esi
  80250c:	d3 e2                	shl    %cl,%edx
  80250e:	89 f1                	mov    %esi,%ecx
  802510:	d3 e8                	shr    %cl,%eax
  802512:	89 e9                	mov    %ebp,%ecx
  802514:	89 44 24 04          	mov    %eax,0x4(%esp)
  802518:	8b 04 24             	mov    (%esp),%eax
  80251b:	09 54 24 04          	or     %edx,0x4(%esp)
  80251f:	89 fa                	mov    %edi,%edx
  802521:	d3 e0                	shl    %cl,%eax
  802523:	89 f1                	mov    %esi,%ecx
  802525:	89 44 24 08          	mov    %eax,0x8(%esp)
  802529:	8b 44 24 10          	mov    0x10(%esp),%eax
  80252d:	d3 ea                	shr    %cl,%edx
  80252f:	89 e9                	mov    %ebp,%ecx
  802531:	d3 e7                	shl    %cl,%edi
  802533:	89 f1                	mov    %esi,%ecx
  802535:	d3 e8                	shr    %cl,%eax
  802537:	89 e9                	mov    %ebp,%ecx
  802539:	09 f8                	or     %edi,%eax
  80253b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80253f:	f7 74 24 04          	divl   0x4(%esp)
  802543:	d3 e7                	shl    %cl,%edi
  802545:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802549:	89 d7                	mov    %edx,%edi
  80254b:	f7 64 24 08          	mull   0x8(%esp)
  80254f:	39 d7                	cmp    %edx,%edi
  802551:	89 c1                	mov    %eax,%ecx
  802553:	89 14 24             	mov    %edx,(%esp)
  802556:	72 2c                	jb     802584 <__umoddi3+0x134>
  802558:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80255c:	72 22                	jb     802580 <__umoddi3+0x130>
  80255e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802562:	29 c8                	sub    %ecx,%eax
  802564:	19 d7                	sbb    %edx,%edi
  802566:	89 e9                	mov    %ebp,%ecx
  802568:	89 fa                	mov    %edi,%edx
  80256a:	d3 e8                	shr    %cl,%eax
  80256c:	89 f1                	mov    %esi,%ecx
  80256e:	d3 e2                	shl    %cl,%edx
  802570:	89 e9                	mov    %ebp,%ecx
  802572:	d3 ef                	shr    %cl,%edi
  802574:	09 d0                	or     %edx,%eax
  802576:	89 fa                	mov    %edi,%edx
  802578:	83 c4 14             	add    $0x14,%esp
  80257b:	5e                   	pop    %esi
  80257c:	5f                   	pop    %edi
  80257d:	5d                   	pop    %ebp
  80257e:	c3                   	ret    
  80257f:	90                   	nop
  802580:	39 d7                	cmp    %edx,%edi
  802582:	75 da                	jne    80255e <__umoddi3+0x10e>
  802584:	8b 14 24             	mov    (%esp),%edx
  802587:	89 c1                	mov    %eax,%ecx
  802589:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80258d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802591:	eb cb                	jmp    80255e <__umoddi3+0x10e>
  802593:	90                   	nop
  802594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802598:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80259c:	0f 82 0f ff ff ff    	jb     8024b1 <__umoddi3+0x61>
  8025a2:	e9 1a ff ff ff       	jmp    8024c1 <__umoddi3+0x71>
