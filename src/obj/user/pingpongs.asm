
obj/user/pingpongs.debug：     文件格式 elf32-i386


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
  80002c:	e8 16 01 00 00       	call   800147 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 3c             	sub    $0x3c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 2c 13 00 00       	call   80136d <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 5e                	je     8000a6 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 c8 0c 00 00       	call   800d1b <sys_getenvid>
  800053:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800057:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005b:	c7 04 24 00 26 80 00 	movl   $0x802600,(%esp)
  800062:	e8 e4 01 00 00       	call   80024b <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800067:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006a:	e8 ac 0c 00 00       	call   800d1b <sys_getenvid>
  80006f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	c7 04 24 1a 26 80 00 	movl   $0x80261a,(%esp)
  80007e:	e8 c8 01 00 00       	call   80024b <cprintf>
		ipc_send(who, 0, 0, 0);
  800083:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008a:	00 
  80008b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800092:	00 
  800093:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009a:	00 
  80009b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009e:	89 04 24             	mov    %eax,(%esp)
  8000a1:	e8 45 13 00 00       	call   8013eb <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 ce 12 00 00       	call   80138f <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c1:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000c7:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000ca:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8000d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000d5:	e8 41 0c 00 00       	call   800d1b <sys_getenvid>
  8000da:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8000de:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000e9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f1:	c7 04 24 30 26 80 00 	movl   $0x802630,(%esp)
  8000f8:	e8 4e 01 00 00       	call   80024b <cprintf>
		if (val == 10)
  8000fd:	a1 04 40 80 00       	mov    0x804004,%eax
  800102:	83 f8 0a             	cmp    $0xa,%eax
  800105:	74 38                	je     80013f <umain+0x10c>
			return;
		++val;
  800107:	83 c0 01             	add    $0x1,%eax
  80010a:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  80010f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800126:	00 
  800127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 b9 12 00 00       	call   8013eb <ipc_send>
		if (val == 10)
  800132:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  800139:	0f 85 67 ff ff ff    	jne    8000a6 <umain+0x73>
			return;
	}

}
  80013f:	83 c4 3c             	add    $0x3c,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
  80014c:	83 ec 10             	sub    $0x10,%esp
  80014f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800152:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800155:	e8 c1 0b 00 00       	call   800d1b <sys_getenvid>
  80015a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800162:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800167:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016c:	85 db                	test   %ebx,%ebx
  80016e:	7e 07                	jle    800177 <libmain+0x30>
		binaryname = argv[0];
  800170:	8b 06                	mov    (%esi),%eax
  800172:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800177:	89 74 24 04          	mov    %esi,0x4(%esp)
  80017b:	89 1c 24             	mov    %ebx,(%esp)
  80017e:	e8 b0 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800183:	e8 07 00 00 00       	call   80018f <exit>
}
  800188:	83 c4 10             	add    $0x10,%esp
  80018b:	5b                   	pop    %ebx
  80018c:	5e                   	pop    %esi
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    

0080018f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800195:	e8 fc 14 00 00       	call   801696 <close_all>
	sys_env_destroy(0);
  80019a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a1:	e8 23 0b 00 00       	call   800cc9 <sys_env_destroy>
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 14             	sub    $0x14,%esp
  8001af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b2:	8b 13                	mov    (%ebx),%edx
  8001b4:	8d 42 01             	lea    0x1(%edx),%eax
  8001b7:	89 03                	mov    %eax,(%ebx)
  8001b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c5:	75 19                	jne    8001e0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ce:	00 
  8001cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d2:	89 04 24             	mov    %eax,(%esp)
  8001d5:	e8 b2 0a 00 00       	call   800c8c <sys_cputs>
		b->idx = 0;
  8001da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e4:	83 c4 14             	add    $0x14,%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    

008001ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fa:	00 00 00 
	b.cnt = 0;
  8001fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800204:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800207:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	89 44 24 08          	mov    %eax,0x8(%esp)
  800215:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	c7 04 24 a8 01 80 00 	movl   $0x8001a8,(%esp)
  800226:	e8 b9 01 00 00       	call   8003e4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800231:	89 44 24 04          	mov    %eax,0x4(%esp)
  800235:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023b:	89 04 24             	mov    %eax,(%esp)
  80023e:	e8 49 0a 00 00       	call   800c8c <sys_cputs>

	return b.cnt;
}
  800243:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800251:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800254:	89 44 24 04          	mov    %eax,0x4(%esp)
  800258:	8b 45 08             	mov    0x8(%ebp),%eax
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	e8 87 ff ff ff       	call   8001ea <vcprintf>
	va_end(ap);

	return cnt;
}
  800263:	c9                   	leave  
  800264:	c3                   	ret    
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
  8002ec:	e8 7f 20 00 00       	call   802370 <__udivdi3>
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
  800345:	e8 56 21 00 00       	call   8024a0 <__umoddi3>
  80034a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034e:	0f be 80 60 26 80 00 	movsbl 0x802660(%eax),%eax
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
  80046c:	ff 24 85 a0 27 80 00 	jmp    *0x8027a0(,%eax,4)
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
  80051f:	8b 14 85 00 29 80 00 	mov    0x802900(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 20                	jne    80054a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80052a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80052e:	c7 44 24 08 78 26 80 	movl   $0x802678,0x8(%esp)
  800535:	00 
  800536:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053a:	8b 45 08             	mov    0x8(%ebp),%eax
  80053d:	89 04 24             	mov    %eax,(%esp)
  800540:	e8 77 fe ff ff       	call   8003bc <printfmt>
  800545:	e9 c3 fe ff ff       	jmp    80040d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80054a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80054e:	c7 44 24 08 b3 2b 80 	movl   $0x802bb3,0x8(%esp)
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
  80057d:	ba 71 26 80 00       	mov    $0x802671,%edx
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
  800cf7:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800cfe:	00 
  800cff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d06:	00 
  800d07:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800d0e:	e8 13 15 00 00       	call   802226 <_panic>
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
  800d89:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800da0:	e8 81 14 00 00       	call   802226 <_panic>
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
  800ddc:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800de3:	00 
  800de4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800deb:	00 
  800dec:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800df3:	e8 2e 14 00 00       	call   802226 <_panic>
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
  800e2f:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800e36:	00 
  800e37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3e:	00 
  800e3f:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800e46:	e8 db 13 00 00       	call   802226 <_panic>
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
  800e82:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800e89:	00 
  800e8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e91:	00 
  800e92:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800e99:	e8 88 13 00 00       	call   802226 <_panic>
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
  800ed5:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800edc:	00 
  800edd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee4:	00 
  800ee5:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800eec:	e8 35 13 00 00       	call   802226 <_panic>
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
  800f28:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800f2f:	00 
  800f30:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f37:	00 
  800f38:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800f3f:	e8 e2 12 00 00       	call   802226 <_panic>
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
  800f9d:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800fa4:	00 
  800fa5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fac:	00 
  800fad:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800fb4:	e8 6d 12 00 00       	call   802226 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fb9:	83 c4 2c             	add    $0x2c,%esp
  800fbc:	5b                   	pop    %ebx
  800fbd:	5e                   	pop    %esi
  800fbe:	5f                   	pop    %edi
  800fbf:	5d                   	pop    %ebp
  800fc0:	c3                   	ret    

00800fc1 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	53                   	push   %ebx
  800fc5:	83 ec 24             	sub    $0x24,%esp
  800fc8:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800fcb:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800fcd:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800fd1:	74 2e                	je     801001 <pgfault+0x40>
  800fd3:	89 c2                	mov    %eax,%edx
  800fd5:	c1 ea 16             	shr    $0x16,%edx
  800fd8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fdf:	f6 c2 01             	test   $0x1,%dl
  800fe2:	74 1d                	je     801001 <pgfault+0x40>
  800fe4:	89 c2                	mov    %eax,%edx
  800fe6:	c1 ea 0c             	shr    $0xc,%edx
  800fe9:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800ff0:	f6 c1 01             	test   $0x1,%cl
  800ff3:	74 0c                	je     801001 <pgfault+0x40>
  800ff5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ffc:	f6 c6 08             	test   $0x8,%dh
  800fff:	75 20                	jne    801021 <pgfault+0x60>
		panic("pgfault: page cow check failed, addr=%x\n", addr);
  801001:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801005:	c7 44 24 08 8c 29 80 	movl   $0x80298c,0x8(%esp)
  80100c:	00 
  80100d:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  801014:	00 
  801015:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  80101c:	e8 05 12 00 00       	call   802226 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  801021:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801026:	89 c3                	mov    %eax,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W))
  801028:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80102f:	00 
  801030:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801037:	00 
  801038:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80103f:	e8 15 fd ff ff       	call   800d59 <sys_page_alloc>
  801044:	85 c0                	test   %eax,%eax
  801046:	74 1c                	je     801064 <pgfault+0xa3>
		panic("pgfault: sys_page_alloc error");
  801048:	c7 44 24 08 7e 2a 80 	movl   $0x802a7e,0x8(%esp)
  80104f:	00 
  801050:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801057:	00 
  801058:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  80105f:	e8 c2 11 00 00       	call   802226 <_panic>

	memmove(PFTEMP, addr, PGSIZE);
  801064:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80106b:	00 
  80106c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801070:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801077:	e8 2a fa ff ff       	call   800aa6 <memmove>
	if(sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))
  80107c:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801083:	00 
  801084:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801088:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80108f:	00 
  801090:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801097:	00 
  801098:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80109f:	e8 09 fd ff ff       	call   800dad <sys_page_map>
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	74 1c                	je     8010c4 <pgfault+0x103>
		panic("pgfault: sys_page_map error");
  8010a8:	c7 44 24 08 9c 2a 80 	movl   $0x802a9c,0x8(%esp)
  8010af:	00 
  8010b0:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8010b7:	00 
  8010b8:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  8010bf:	e8 62 11 00 00       	call   802226 <_panic>

	if(sys_page_unmap(0, PFTEMP))
  8010c4:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010cb:	00 
  8010cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d3:	e8 28 fd ff ff       	call   800e00 <sys_page_unmap>
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	74 1c                	je     8010f8 <pgfault+0x137>
		panic("pgfault: sys_page_unmap error");
  8010dc:	c7 44 24 08 b8 2a 80 	movl   $0x802ab8,0x8(%esp)
  8010e3:	00 
  8010e4:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8010eb:	00 
  8010ec:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  8010f3:	e8 2e 11 00 00       	call   802226 <_panic>
}
  8010f8:	83 c4 24             	add    $0x24,%esp
  8010fb:	5b                   	pop    %ebx
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	57                   	push   %edi
  801102:	56                   	push   %esi
  801103:	53                   	push   %ebx
  801104:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	//根据文档的描述，duppage好像不应该处理除了可写或者copy-on-write的部分，但这里都交给duppage一块处理了
	set_pgfault_handler(pgfault);
  801107:	c7 04 24 c1 0f 80 00 	movl   $0x800fc1,(%esp)
  80110e:	e8 69 11 00 00       	call   80227c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801113:	b8 07 00 00 00       	mov    $0x7,%eax
  801118:	cd 30                	int    $0x30
  80111a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();
	if(envid < 0)
  80111d:	85 c0                	test   %eax,%eax
  80111f:	79 1c                	jns    80113d <fork+0x3f>
		//失败
		panic("fork: sys_exofork error");
  801121:	c7 44 24 08 d6 2a 80 	movl   $0x802ad6,0x8(%esp)
  801128:	00 
  801129:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
  801130:	00 
  801131:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  801138:	e8 e9 10 00 00       	call   802226 <_panic>
  80113d:	89 c7                	mov    %eax,%edi
	else if(!envid)
  80113f:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801144:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801148:	75 1c                	jne    801166 <fork+0x68>
		//子进程
		thisenv = &envs[ENVX(sys_getenvid())];
  80114a:	e8 cc fb ff ff       	call   800d1b <sys_getenvid>
  80114f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801154:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801157:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80115c:	a3 08 40 80 00       	mov    %eax,0x804008
  801161:	e9 fc 01 00 00       	jmp    801362 <fork+0x264>
	else{
		//父进程
		unsigned addr;
		for(addr = UTEXT; addr < USTACKTOP; addr += PGSIZE){
			if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))
  801166:	89 d8                	mov    %ebx,%eax
  801168:	c1 e8 16             	shr    $0x16,%eax
  80116b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801172:	a8 01                	test   $0x1,%al
  801174:	0f 84 58 01 00 00    	je     8012d2 <fork+0x1d4>
  80117a:	89 d8                	mov    %ebx,%eax
  80117c:	c1 e8 0c             	shr    $0xc,%eax
  80117f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801186:	f6 c2 01             	test   $0x1,%dl
  801189:	0f 84 43 01 00 00    	je     8012d2 <fork+0x1d4>
  80118f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801196:	f6 c2 04             	test   $0x4,%dl
  801199:	0f 84 33 01 00 00    	je     8012d2 <fork+0x1d4>
	void *addr = (void *)(pn * PGSIZE);
  80119f:	89 c6                	mov    %eax,%esi
  8011a1:	c1 e6 0c             	shl    $0xc,%esi
	if(uvpt[pn] & PTE_SHARE){
  8011a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011ab:	f6 c6 04             	test   $0x4,%dh
  8011ae:	74 4c                	je     8011fc <fork+0xfe>
		if(sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL))
  8011b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8011bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011c4:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d3:	e8 d5 fb ff ff       	call   800dad <sys_page_map>
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	0f 84 f2 00 00 00    	je     8012d2 <fork+0x1d4>
			panic("duppage: sys_page_map pte_syscall error");
  8011e0:	c7 44 24 08 b8 29 80 	movl   $0x8029b8,0x8(%esp)
  8011e7:	00 
  8011e8:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8011ef:	00 
  8011f0:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  8011f7:	e8 2a 10 00 00       	call   802226 <_panic>
	else if(uvpt[pn] & (PTE_W | PTE_COW)){
  8011fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801203:	a9 02 08 00 00       	test   $0x802,%eax
  801208:	0f 84 84 00 00 00    	je     801292 <fork+0x194>
		if(sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P))
  80120e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801215:	00 
  801216:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80121a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80121e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801222:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801229:	e8 7f fb ff ff       	call   800dad <sys_page_map>
  80122e:	85 c0                	test   %eax,%eax
  801230:	74 1c                	je     80124e <fork+0x150>
			panic("duppage: sys_page_map child error");
  801232:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  801239:	00 
  80123a:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801241:	00 
  801242:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  801249:	e8 d8 0f 00 00       	call   802226 <_panic>
		if(sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P))
  80124e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801255:	00 
  801256:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80125a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801261:	00 
  801262:	89 74 24 04          	mov    %esi,0x4(%esp)
  801266:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80126d:	e8 3b fb ff ff       	call   800dad <sys_page_map>
  801272:	85 c0                	test   %eax,%eax
  801274:	74 5c                	je     8012d2 <fork+0x1d4>
			panic("duppage: sys_page_map remap parent error");
  801276:	c7 44 24 08 04 2a 80 	movl   $0x802a04,0x8(%esp)
  80127d:	00 
  80127e:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  801285:	00 
  801286:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  80128d:	e8 94 0f 00 00       	call   802226 <_panic>
		if(sys_page_map(0, addr, envid, addr, PTE_U|PTE_P))
  801292:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801299:	00 
  80129a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80129e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ad:	e8 fb fa ff ff       	call   800dad <sys_page_map>
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	74 1c                	je     8012d2 <fork+0x1d4>
			panic("duppage: other sys_page_map error");
  8012b6:	c7 44 24 08 30 2a 80 	movl   $0x802a30,0x8(%esp)
  8012bd:	00 
  8012be:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  8012c5:	00 
  8012c6:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  8012cd:	e8 54 0f 00 00       	call   802226 <_panic>
		for(addr = UTEXT; addr < USTACKTOP; addr += PGSIZE){
  8012d2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012d8:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8012de:	0f 85 82 fe ff ff    	jne    801166 <fork+0x68>
				duppage(envid, PGNUM(addr));
		}
		if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W))
  8012e4:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012eb:	00 
  8012ec:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012f3:	ee 
  8012f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f7:	89 04 24             	mov    %eax,(%esp)
  8012fa:	e8 5a fa ff ff       	call   800d59 <sys_page_alloc>
  8012ff:	85 c0                	test   %eax,%eax
  801301:	74 1c                	je     80131f <fork+0x221>
			panic("fork: sys_page_alloc error");
  801303:	c7 44 24 08 ee 2a 80 	movl   $0x802aee,0x8(%esp)
  80130a:	00 
  80130b:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801312:	00 
  801313:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  80131a:	e8 07 0f 00 00       	call   802226 <_panic>
		extern void _pgfault_upcall();
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80131f:	c7 44 24 04 05 23 80 	movl   $0x802305,0x4(%esp)
  801326:	00 
  801327:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80132a:	89 3c 24             	mov    %edi,(%esp)
  80132d:	e8 c7 fb ff ff       	call   800ef9 <sys_env_set_pgfault_upcall>
		if(sys_env_set_status(envid, ENV_RUNNABLE))
  801332:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801339:	00 
  80133a:	89 3c 24             	mov    %edi,(%esp)
  80133d:	e8 11 fb ff ff       	call   800e53 <sys_env_set_status>
  801342:	85 c0                	test   %eax,%eax
  801344:	74 1c                	je     801362 <fork+0x264>
			panic("fork: sys_env_set_status error");
  801346:	c7 44 24 08 54 2a 80 	movl   $0x802a54,0x8(%esp)
  80134d:	00 
  80134e:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801355:	00 
  801356:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  80135d:	e8 c4 0e 00 00       	call   802226 <_panic>
	}
	return envid;
}
  801362:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801365:	83 c4 2c             	add    $0x2c,%esp
  801368:	5b                   	pop    %ebx
  801369:	5e                   	pop    %esi
  80136a:	5f                   	pop    %edi
  80136b:	5d                   	pop    %ebp
  80136c:	c3                   	ret    

0080136d <sfork>:

// Challenge!
int
sfork(void)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801373:	c7 44 24 08 09 2b 80 	movl   $0x802b09,0x8(%esp)
  80137a:	00 
  80137b:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  801382:	00 
  801383:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  80138a:	e8 97 0e 00 00       	call   802226 <_panic>

0080138f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	56                   	push   %esi
  801393:	53                   	push   %ebx
  801394:	83 ec 10             	sub    $0x10,%esp
  801397:	8b 75 08             	mov    0x8(%ebp),%esi
  80139a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  80139d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a0:	89 04 24             	mov    %eax,(%esp)
  8013a3:	e8 c7 fb ff ff       	call   800f6f <sys_ipc_recv>
	if(from_env_store)
  8013a8:	85 f6                	test   %esi,%esi
  8013aa:	74 14                	je     8013c0 <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  8013ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	78 09                	js     8013be <ipc_recv+0x2f>
  8013b5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8013bb:	8b 52 74             	mov    0x74(%edx),%edx
  8013be:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  8013c0:	85 db                	test   %ebx,%ebx
  8013c2:	74 14                	je     8013d8 <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  8013c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	78 09                	js     8013d6 <ipc_recv+0x47>
  8013cd:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8013d3:	8b 52 78             	mov    0x78(%edx),%edx
  8013d6:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 08                	js     8013e4 <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  8013dc:	a1 08 40 80 00       	mov    0x804008,%eax
  8013e1:	8b 40 70             	mov    0x70(%eax),%eax
}
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5e                   	pop    %esi
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    

008013eb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	57                   	push   %edi
  8013ef:	56                   	push   %esi
  8013f0:	53                   	push   %ebx
  8013f1:	83 ec 1c             	sub    $0x1c,%esp
  8013f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  8013fa:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  8013ff:	eb 0c                	jmp    80140d <ipc_send+0x22>
		failed_cnt++;
  801401:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  801404:	84 db                	test   %bl,%bl
  801406:	75 05                	jne    80140d <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  801408:	e8 2d f9 ff ff       	call   800d3a <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  80140d:	8b 45 14             	mov    0x14(%ebp),%eax
  801410:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801414:	8b 45 10             	mov    0x10(%ebp),%eax
  801417:	89 44 24 08          	mov    %eax,0x8(%esp)
  80141b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80141f:	89 3c 24             	mov    %edi,(%esp)
  801422:	e8 25 fb ff ff       	call   800f4c <sys_ipc_try_send>
  801427:	85 c0                	test   %eax,%eax
  801429:	78 d6                	js     801401 <ipc_send+0x16>
	}
}
  80142b:	83 c4 1c             	add    $0x1c,%esp
  80142e:	5b                   	pop    %ebx
  80142f:	5e                   	pop    %esi
  801430:	5f                   	pop    %edi
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    

00801433 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801439:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80143e:	39 c8                	cmp    %ecx,%eax
  801440:	74 17                	je     801459 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  801442:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801447:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80144a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801450:	8b 52 50             	mov    0x50(%edx),%edx
  801453:	39 ca                	cmp    %ecx,%edx
  801455:	75 14                	jne    80146b <ipc_find_env+0x38>
  801457:	eb 05                	jmp    80145e <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  801459:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  80145e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801461:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801466:	8b 40 40             	mov    0x40(%eax),%eax
  801469:	eb 0e                	jmp    801479 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  80146b:	83 c0 01             	add    $0x1,%eax
  80146e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801473:	75 d2                	jne    801447 <ipc_find_env+0x14>
	return 0;
  801475:	66 b8 00 00          	mov    $0x0,%ax
}
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    
  80147b:	66 90                	xchg   %ax,%ax
  80147d:	66 90                	xchg   %ax,%ax
  80147f:	90                   	nop

00801480 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801483:	8b 45 08             	mov    0x8(%ebp),%eax
  801486:	05 00 00 00 30       	add    $0x30000000,%eax
  80148b:	c1 e8 0c             	shr    $0xc,%eax
}
  80148e:	5d                   	pop    %ebp
  80148f:	c3                   	ret    

00801490 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801493:	8b 45 08             	mov    0x8(%ebp),%eax
  801496:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80149b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014a0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014a5:	5d                   	pop    %ebp
  8014a6:	c3                   	ret    

008014a7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014aa:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8014af:	a8 01                	test   $0x1,%al
  8014b1:	74 34                	je     8014e7 <fd_alloc+0x40>
  8014b3:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8014b8:	a8 01                	test   $0x1,%al
  8014ba:	74 32                	je     8014ee <fd_alloc+0x47>
  8014bc:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  8014c1:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014c3:	89 c2                	mov    %eax,%edx
  8014c5:	c1 ea 16             	shr    $0x16,%edx
  8014c8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014cf:	f6 c2 01             	test   $0x1,%dl
  8014d2:	74 1f                	je     8014f3 <fd_alloc+0x4c>
  8014d4:	89 c2                	mov    %eax,%edx
  8014d6:	c1 ea 0c             	shr    $0xc,%edx
  8014d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014e0:	f6 c2 01             	test   $0x1,%dl
  8014e3:	75 1a                	jne    8014ff <fd_alloc+0x58>
  8014e5:	eb 0c                	jmp    8014f3 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  8014e7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8014ec:	eb 05                	jmp    8014f3 <fd_alloc+0x4c>
  8014ee:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  8014f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f6:	89 08                	mov    %ecx,(%eax)
			return 0;
  8014f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014fd:	eb 1a                	jmp    801519 <fd_alloc+0x72>
  8014ff:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801504:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801509:	75 b6                	jne    8014c1 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  80150b:	8b 45 08             	mov    0x8(%ebp),%eax
  80150e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801514:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801519:	5d                   	pop    %ebp
  80151a:	c3                   	ret    

0080151b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801521:	83 f8 1f             	cmp    $0x1f,%eax
  801524:	77 36                	ja     80155c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801526:	c1 e0 0c             	shl    $0xc,%eax
  801529:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80152e:	89 c2                	mov    %eax,%edx
  801530:	c1 ea 16             	shr    $0x16,%edx
  801533:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80153a:	f6 c2 01             	test   $0x1,%dl
  80153d:	74 24                	je     801563 <fd_lookup+0x48>
  80153f:	89 c2                	mov    %eax,%edx
  801541:	c1 ea 0c             	shr    $0xc,%edx
  801544:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80154b:	f6 c2 01             	test   $0x1,%dl
  80154e:	74 1a                	je     80156a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801550:	8b 55 0c             	mov    0xc(%ebp),%edx
  801553:	89 02                	mov    %eax,(%edx)
	return 0;
  801555:	b8 00 00 00 00       	mov    $0x0,%eax
  80155a:	eb 13                	jmp    80156f <fd_lookup+0x54>
		return -E_INVAL;
  80155c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801561:	eb 0c                	jmp    80156f <fd_lookup+0x54>
		return -E_INVAL;
  801563:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801568:	eb 05                	jmp    80156f <fd_lookup+0x54>
  80156a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80156f:	5d                   	pop    %ebp
  801570:	c3                   	ret    

00801571 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	53                   	push   %ebx
  801575:	83 ec 14             	sub    $0x14,%esp
  801578:	8b 45 08             	mov    0x8(%ebp),%eax
  80157b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80157e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801584:	75 1e                	jne    8015a4 <dev_lookup+0x33>
  801586:	eb 0e                	jmp    801596 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  801588:	b8 20 30 80 00       	mov    $0x803020,%eax
  80158d:	eb 0c                	jmp    80159b <dev_lookup+0x2a>
  80158f:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801594:	eb 05                	jmp    80159b <dev_lookup+0x2a>
  801596:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  80159b:	89 03                	mov    %eax,(%ebx)
			return 0;
  80159d:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a2:	eb 38                	jmp    8015dc <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  8015a4:	39 05 20 30 80 00    	cmp    %eax,0x803020
  8015aa:	74 dc                	je     801588 <dev_lookup+0x17>
  8015ac:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  8015b2:	74 db                	je     80158f <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015b4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8015ba:	8b 52 48             	mov    0x48(%edx),%edx
  8015bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015c5:	c7 04 24 20 2b 80 00 	movl   $0x802b20,(%esp)
  8015cc:	e8 7a ec ff ff       	call   80024b <cprintf>
	*dev = 0;
  8015d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8015d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015dc:	83 c4 14             	add    $0x14,%esp
  8015df:	5b                   	pop    %ebx
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    

008015e2 <fd_close>:
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	56                   	push   %esi
  8015e6:	53                   	push   %ebx
  8015e7:	83 ec 20             	sub    $0x20,%esp
  8015ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f3:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015f7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015fd:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801600:	89 04 24             	mov    %eax,(%esp)
  801603:	e8 13 ff ff ff       	call   80151b <fd_lookup>
  801608:	85 c0                	test   %eax,%eax
  80160a:	78 05                	js     801611 <fd_close+0x2f>
	    || fd != fd2)
  80160c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80160f:	74 0c                	je     80161d <fd_close+0x3b>
		return (must_exist ? r : 0);
  801611:	84 db                	test   %bl,%bl
  801613:	ba 00 00 00 00       	mov    $0x0,%edx
  801618:	0f 44 c2             	cmove  %edx,%eax
  80161b:	eb 3f                	jmp    80165c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80161d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801620:	89 44 24 04          	mov    %eax,0x4(%esp)
  801624:	8b 06                	mov    (%esi),%eax
  801626:	89 04 24             	mov    %eax,(%esp)
  801629:	e8 43 ff ff ff       	call   801571 <dev_lookup>
  80162e:	89 c3                	mov    %eax,%ebx
  801630:	85 c0                	test   %eax,%eax
  801632:	78 16                	js     80164a <fd_close+0x68>
		if (dev->dev_close)
  801634:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801637:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80163a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80163f:	85 c0                	test   %eax,%eax
  801641:	74 07                	je     80164a <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801643:	89 34 24             	mov    %esi,(%esp)
  801646:	ff d0                	call   *%eax
  801648:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  80164a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80164e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801655:	e8 a6 f7 ff ff       	call   800e00 <sys_page_unmap>
	return r;
  80165a:	89 d8                	mov    %ebx,%eax
}
  80165c:	83 c4 20             	add    $0x20,%esp
  80165f:	5b                   	pop    %ebx
  801660:	5e                   	pop    %esi
  801661:	5d                   	pop    %ebp
  801662:	c3                   	ret    

00801663 <close>:

int
close(int fdnum)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801669:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801670:	8b 45 08             	mov    0x8(%ebp),%eax
  801673:	89 04 24             	mov    %eax,(%esp)
  801676:	e8 a0 fe ff ff       	call   80151b <fd_lookup>
  80167b:	89 c2                	mov    %eax,%edx
  80167d:	85 d2                	test   %edx,%edx
  80167f:	78 13                	js     801694 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801681:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801688:	00 
  801689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168c:	89 04 24             	mov    %eax,(%esp)
  80168f:	e8 4e ff ff ff       	call   8015e2 <fd_close>
}
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <close_all>:

void
close_all(void)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	53                   	push   %ebx
  80169a:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80169d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016a2:	89 1c 24             	mov    %ebx,(%esp)
  8016a5:	e8 b9 ff ff ff       	call   801663 <close>
	for (i = 0; i < MAXFD; i++)
  8016aa:	83 c3 01             	add    $0x1,%ebx
  8016ad:	83 fb 20             	cmp    $0x20,%ebx
  8016b0:	75 f0                	jne    8016a2 <close_all+0xc>
}
  8016b2:	83 c4 14             	add    $0x14,%esp
  8016b5:	5b                   	pop    %ebx
  8016b6:	5d                   	pop    %ebp
  8016b7:	c3                   	ret    

008016b8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	57                   	push   %edi
  8016bc:	56                   	push   %esi
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016c1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cb:	89 04 24             	mov    %eax,(%esp)
  8016ce:	e8 48 fe ff ff       	call   80151b <fd_lookup>
  8016d3:	89 c2                	mov    %eax,%edx
  8016d5:	85 d2                	test   %edx,%edx
  8016d7:	0f 88 e1 00 00 00    	js     8017be <dup+0x106>
		return r;
	close(newfdnum);
  8016dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e0:	89 04 24             	mov    %eax,(%esp)
  8016e3:	e8 7b ff ff ff       	call   801663 <close>

	newfd = INDEX2FD(newfdnum);
  8016e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016eb:	c1 e3 0c             	shl    $0xc,%ebx
  8016ee:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016f7:	89 04 24             	mov    %eax,(%esp)
  8016fa:	e8 91 fd ff ff       	call   801490 <fd2data>
  8016ff:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801701:	89 1c 24             	mov    %ebx,(%esp)
  801704:	e8 87 fd ff ff       	call   801490 <fd2data>
  801709:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80170b:	89 f0                	mov    %esi,%eax
  80170d:	c1 e8 16             	shr    $0x16,%eax
  801710:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801717:	a8 01                	test   $0x1,%al
  801719:	74 43                	je     80175e <dup+0xa6>
  80171b:	89 f0                	mov    %esi,%eax
  80171d:	c1 e8 0c             	shr    $0xc,%eax
  801720:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801727:	f6 c2 01             	test   $0x1,%dl
  80172a:	74 32                	je     80175e <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80172c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801733:	25 07 0e 00 00       	and    $0xe07,%eax
  801738:	89 44 24 10          	mov    %eax,0x10(%esp)
  80173c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801740:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801747:	00 
  801748:	89 74 24 04          	mov    %esi,0x4(%esp)
  80174c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801753:	e8 55 f6 ff ff       	call   800dad <sys_page_map>
  801758:	89 c6                	mov    %eax,%esi
  80175a:	85 c0                	test   %eax,%eax
  80175c:	78 3e                	js     80179c <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80175e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801761:	89 c2                	mov    %eax,%edx
  801763:	c1 ea 0c             	shr    $0xc,%edx
  801766:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80176d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801773:	89 54 24 10          	mov    %edx,0x10(%esp)
  801777:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80177b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801782:	00 
  801783:	89 44 24 04          	mov    %eax,0x4(%esp)
  801787:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80178e:	e8 1a f6 ff ff       	call   800dad <sys_page_map>
  801793:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801795:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801798:	85 f6                	test   %esi,%esi
  80179a:	79 22                	jns    8017be <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80179c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a7:	e8 54 f6 ff ff       	call   800e00 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b7:	e8 44 f6 ff ff       	call   800e00 <sys_page_unmap>
	return r;
  8017bc:	89 f0                	mov    %esi,%eax
}
  8017be:	83 c4 3c             	add    $0x3c,%esp
  8017c1:	5b                   	pop    %ebx
  8017c2:	5e                   	pop    %esi
  8017c3:	5f                   	pop    %edi
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	53                   	push   %ebx
  8017ca:	83 ec 24             	sub    $0x24,%esp
  8017cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d7:	89 1c 24             	mov    %ebx,(%esp)
  8017da:	e8 3c fd ff ff       	call   80151b <fd_lookup>
  8017df:	89 c2                	mov    %eax,%edx
  8017e1:	85 d2                	test   %edx,%edx
  8017e3:	78 6d                	js     801852 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ef:	8b 00                	mov    (%eax),%eax
  8017f1:	89 04 24             	mov    %eax,(%esp)
  8017f4:	e8 78 fd ff ff       	call   801571 <dev_lookup>
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 55                	js     801852 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801800:	8b 50 08             	mov    0x8(%eax),%edx
  801803:	83 e2 03             	and    $0x3,%edx
  801806:	83 fa 01             	cmp    $0x1,%edx
  801809:	75 23                	jne    80182e <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80180b:	a1 08 40 80 00       	mov    0x804008,%eax
  801810:	8b 40 48             	mov    0x48(%eax),%eax
  801813:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181b:	c7 04 24 61 2b 80 00 	movl   $0x802b61,(%esp)
  801822:	e8 24 ea ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  801827:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80182c:	eb 24                	jmp    801852 <read+0x8c>
	}
	if (!dev->dev_read)
  80182e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801831:	8b 52 08             	mov    0x8(%edx),%edx
  801834:	85 d2                	test   %edx,%edx
  801836:	74 15                	je     80184d <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801838:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80183b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80183f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801842:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801846:	89 04 24             	mov    %eax,(%esp)
  801849:	ff d2                	call   *%edx
  80184b:	eb 05                	jmp    801852 <read+0x8c>
		return -E_NOT_SUPP;
  80184d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801852:	83 c4 24             	add    $0x24,%esp
  801855:	5b                   	pop    %ebx
  801856:	5d                   	pop    %ebp
  801857:	c3                   	ret    

00801858 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	57                   	push   %edi
  80185c:	56                   	push   %esi
  80185d:	53                   	push   %ebx
  80185e:	83 ec 1c             	sub    $0x1c,%esp
  801861:	8b 7d 08             	mov    0x8(%ebp),%edi
  801864:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801867:	85 f6                	test   %esi,%esi
  801869:	74 33                	je     80189e <readn+0x46>
  80186b:	b8 00 00 00 00       	mov    $0x0,%eax
  801870:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801875:	89 f2                	mov    %esi,%edx
  801877:	29 c2                	sub    %eax,%edx
  801879:	89 54 24 08          	mov    %edx,0x8(%esp)
  80187d:	03 45 0c             	add    0xc(%ebp),%eax
  801880:	89 44 24 04          	mov    %eax,0x4(%esp)
  801884:	89 3c 24             	mov    %edi,(%esp)
  801887:	e8 3a ff ff ff       	call   8017c6 <read>
		if (m < 0)
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 1b                	js     8018ab <readn+0x53>
			return m;
		if (m == 0)
  801890:	85 c0                	test   %eax,%eax
  801892:	74 11                	je     8018a5 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  801894:	01 c3                	add    %eax,%ebx
  801896:	89 d8                	mov    %ebx,%eax
  801898:	39 f3                	cmp    %esi,%ebx
  80189a:	72 d9                	jb     801875 <readn+0x1d>
  80189c:	eb 0b                	jmp    8018a9 <readn+0x51>
  80189e:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a3:	eb 06                	jmp    8018ab <readn+0x53>
  8018a5:	89 d8                	mov    %ebx,%eax
  8018a7:	eb 02                	jmp    8018ab <readn+0x53>
  8018a9:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8018ab:	83 c4 1c             	add    $0x1c,%esp
  8018ae:	5b                   	pop    %ebx
  8018af:	5e                   	pop    %esi
  8018b0:	5f                   	pop    %edi
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	53                   	push   %ebx
  8018b7:	83 ec 24             	sub    $0x24,%esp
  8018ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c4:	89 1c 24             	mov    %ebx,(%esp)
  8018c7:	e8 4f fc ff ff       	call   80151b <fd_lookup>
  8018cc:	89 c2                	mov    %eax,%edx
  8018ce:	85 d2                	test   %edx,%edx
  8018d0:	78 68                	js     80193a <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018dc:	8b 00                	mov    (%eax),%eax
  8018de:	89 04 24             	mov    %eax,(%esp)
  8018e1:	e8 8b fc ff ff       	call   801571 <dev_lookup>
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 50                	js     80193a <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018f1:	75 23                	jne    801916 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018f3:	a1 08 40 80 00       	mov    0x804008,%eax
  8018f8:	8b 40 48             	mov    0x48(%eax),%eax
  8018fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801903:	c7 04 24 7d 2b 80 00 	movl   $0x802b7d,(%esp)
  80190a:	e8 3c e9 ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  80190f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801914:	eb 24                	jmp    80193a <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801916:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801919:	8b 52 0c             	mov    0xc(%edx),%edx
  80191c:	85 d2                	test   %edx,%edx
  80191e:	74 15                	je     801935 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801920:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801923:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801927:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80192a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80192e:	89 04 24             	mov    %eax,(%esp)
  801931:	ff d2                	call   *%edx
  801933:	eb 05                	jmp    80193a <write+0x87>
		return -E_NOT_SUPP;
  801935:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80193a:	83 c4 24             	add    $0x24,%esp
  80193d:	5b                   	pop    %ebx
  80193e:	5d                   	pop    %ebp
  80193f:	c3                   	ret    

00801940 <seek>:

int
seek(int fdnum, off_t offset)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801946:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801949:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194d:	8b 45 08             	mov    0x8(%ebp),%eax
  801950:	89 04 24             	mov    %eax,(%esp)
  801953:	e8 c3 fb ff ff       	call   80151b <fd_lookup>
  801958:	85 c0                	test   %eax,%eax
  80195a:	78 0e                	js     80196a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80195c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80195f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801962:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801965:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	53                   	push   %ebx
  801970:	83 ec 24             	sub    $0x24,%esp
  801973:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801976:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801979:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197d:	89 1c 24             	mov    %ebx,(%esp)
  801980:	e8 96 fb ff ff       	call   80151b <fd_lookup>
  801985:	89 c2                	mov    %eax,%edx
  801987:	85 d2                	test   %edx,%edx
  801989:	78 61                	js     8019ec <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80198b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801992:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801995:	8b 00                	mov    (%eax),%eax
  801997:	89 04 24             	mov    %eax,(%esp)
  80199a:	e8 d2 fb ff ff       	call   801571 <dev_lookup>
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	78 49                	js     8019ec <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019aa:	75 23                	jne    8019cf <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019ac:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019b1:	8b 40 48             	mov    0x48(%eax),%eax
  8019b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019bc:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  8019c3:	e8 83 e8 ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  8019c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019cd:	eb 1d                	jmp    8019ec <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8019cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d2:	8b 52 18             	mov    0x18(%edx),%edx
  8019d5:	85 d2                	test   %edx,%edx
  8019d7:	74 0e                	je     8019e7 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019dc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019e0:	89 04 24             	mov    %eax,(%esp)
  8019e3:	ff d2                	call   *%edx
  8019e5:	eb 05                	jmp    8019ec <ftruncate+0x80>
		return -E_NOT_SUPP;
  8019e7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8019ec:	83 c4 24             	add    $0x24,%esp
  8019ef:	5b                   	pop    %ebx
  8019f0:	5d                   	pop    %ebp
  8019f1:	c3                   	ret    

008019f2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	53                   	push   %ebx
  8019f6:	83 ec 24             	sub    $0x24,%esp
  8019f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a03:	8b 45 08             	mov    0x8(%ebp),%eax
  801a06:	89 04 24             	mov    %eax,(%esp)
  801a09:	e8 0d fb ff ff       	call   80151b <fd_lookup>
  801a0e:	89 c2                	mov    %eax,%edx
  801a10:	85 d2                	test   %edx,%edx
  801a12:	78 52                	js     801a66 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a1e:	8b 00                	mov    (%eax),%eax
  801a20:	89 04 24             	mov    %eax,(%esp)
  801a23:	e8 49 fb ff ff       	call   801571 <dev_lookup>
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	78 3a                	js     801a66 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a33:	74 2c                	je     801a61 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a35:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a38:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a3f:	00 00 00 
	stat->st_isdir = 0;
  801a42:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a49:	00 00 00 
	stat->st_dev = dev;
  801a4c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a56:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a59:	89 14 24             	mov    %edx,(%esp)
  801a5c:	ff 50 14             	call   *0x14(%eax)
  801a5f:	eb 05                	jmp    801a66 <fstat+0x74>
		return -E_NOT_SUPP;
  801a61:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801a66:	83 c4 24             	add    $0x24,%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	56                   	push   %esi
  801a70:	53                   	push   %ebx
  801a71:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a74:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a7b:	00 
  801a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7f:	89 04 24             	mov    %eax,(%esp)
  801a82:	e8 af 01 00 00       	call   801c36 <open>
  801a87:	89 c3                	mov    %eax,%ebx
  801a89:	85 db                	test   %ebx,%ebx
  801a8b:	78 1b                	js     801aa8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a94:	89 1c 24             	mov    %ebx,(%esp)
  801a97:	e8 56 ff ff ff       	call   8019f2 <fstat>
  801a9c:	89 c6                	mov    %eax,%esi
	close(fd);
  801a9e:	89 1c 24             	mov    %ebx,(%esp)
  801aa1:	e8 bd fb ff ff       	call   801663 <close>
	return r;
  801aa6:	89 f0                	mov    %esi,%eax
}
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	5b                   	pop    %ebx
  801aac:	5e                   	pop    %esi
  801aad:	5d                   	pop    %ebp
  801aae:	c3                   	ret    

00801aaf <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	56                   	push   %esi
  801ab3:	53                   	push   %ebx
  801ab4:	83 ec 10             	sub    $0x10,%esp
  801ab7:	89 c6                	mov    %eax,%esi
  801ab9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801abb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801ac2:	75 11                	jne    801ad5 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ac4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801acb:	e8 63 f9 ff ff       	call   801433 <ipc_find_env>
  801ad0:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ad5:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801adc:	00 
  801add:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801ae4:	00 
  801ae5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ae9:	a1 00 40 80 00       	mov    0x804000,%eax
  801aee:	89 04 24             	mov    %eax,(%esp)
  801af1:	e8 f5 f8 ff ff       	call   8013eb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801af6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801afd:	00 
  801afe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b09:	e8 81 f8 ff ff       	call   80138f <ipc_recv>
}
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	5b                   	pop    %ebx
  801b12:	5e                   	pop    %esi
  801b13:	5d                   	pop    %ebp
  801b14:	c3                   	ret    

00801b15 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	53                   	push   %ebx
  801b19:	83 ec 14             	sub    $0x14,%esp
  801b1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b22:	8b 40 0c             	mov    0xc(%eax),%eax
  801b25:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2f:	b8 05 00 00 00       	mov    $0x5,%eax
  801b34:	e8 76 ff ff ff       	call   801aaf <fsipc>
  801b39:	89 c2                	mov    %eax,%edx
  801b3b:	85 d2                	test   %edx,%edx
  801b3d:	78 2b                	js     801b6a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b3f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b46:	00 
  801b47:	89 1c 24             	mov    %ebx,(%esp)
  801b4a:	e8 5c ed ff ff       	call   8008ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b4f:	a1 80 50 80 00       	mov    0x805080,%eax
  801b54:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b5a:	a1 84 50 80 00       	mov    0x805084,%eax
  801b5f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b6a:	83 c4 14             	add    $0x14,%esp
  801b6d:	5b                   	pop    %ebx
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    

00801b70 <devfile_flush>:
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b76:	8b 45 08             	mov    0x8(%ebp),%eax
  801b79:	8b 40 0c             	mov    0xc(%eax),%eax
  801b7c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b81:	ba 00 00 00 00       	mov    $0x0,%edx
  801b86:	b8 06 00 00 00       	mov    $0x6,%eax
  801b8b:	e8 1f ff ff ff       	call   801aaf <fsipc>
}
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <devfile_read>:
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	56                   	push   %esi
  801b96:	53                   	push   %ebx
  801b97:	83 ec 10             	sub    $0x10,%esp
  801b9a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ba3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ba8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bae:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb3:	b8 03 00 00 00       	mov    $0x3,%eax
  801bb8:	e8 f2 fe ff ff       	call   801aaf <fsipc>
  801bbd:	89 c3                	mov    %eax,%ebx
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	78 6a                	js     801c2d <devfile_read+0x9b>
	assert(r <= n);
  801bc3:	39 c6                	cmp    %eax,%esi
  801bc5:	73 24                	jae    801beb <devfile_read+0x59>
  801bc7:	c7 44 24 0c 9a 2b 80 	movl   $0x802b9a,0xc(%esp)
  801bce:	00 
  801bcf:	c7 44 24 08 a1 2b 80 	movl   $0x802ba1,0x8(%esp)
  801bd6:	00 
  801bd7:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  801bde:	00 
  801bdf:	c7 04 24 b6 2b 80 00 	movl   $0x802bb6,(%esp)
  801be6:	e8 3b 06 00 00       	call   802226 <_panic>
	assert(r <= PGSIZE);
  801beb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bf0:	7e 24                	jle    801c16 <devfile_read+0x84>
  801bf2:	c7 44 24 0c c1 2b 80 	movl   $0x802bc1,0xc(%esp)
  801bf9:	00 
  801bfa:	c7 44 24 08 a1 2b 80 	movl   $0x802ba1,0x8(%esp)
  801c01:	00 
  801c02:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801c09:	00 
  801c0a:	c7 04 24 b6 2b 80 00 	movl   $0x802bb6,(%esp)
  801c11:	e8 10 06 00 00       	call   802226 <_panic>
	memmove(buf, &fsipcbuf, r);
  801c16:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c1a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c21:	00 
  801c22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c25:	89 04 24             	mov    %eax,(%esp)
  801c28:	e8 79 ee ff ff       	call   800aa6 <memmove>
}
  801c2d:	89 d8                	mov    %ebx,%eax
  801c2f:	83 c4 10             	add    $0x10,%esp
  801c32:	5b                   	pop    %ebx
  801c33:	5e                   	pop    %esi
  801c34:	5d                   	pop    %ebp
  801c35:	c3                   	ret    

00801c36 <open>:
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	53                   	push   %ebx
  801c3a:	83 ec 24             	sub    $0x24,%esp
  801c3d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801c40:	89 1c 24             	mov    %ebx,(%esp)
  801c43:	e8 08 ec ff ff       	call   800850 <strlen>
  801c48:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c4d:	7f 60                	jg     801caf <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801c4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c52:	89 04 24             	mov    %eax,(%esp)
  801c55:	e8 4d f8 ff ff       	call   8014a7 <fd_alloc>
  801c5a:	89 c2                	mov    %eax,%edx
  801c5c:	85 d2                	test   %edx,%edx
  801c5e:	78 54                	js     801cb4 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801c60:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c64:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c6b:	e8 3b ec ff ff       	call   8008ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c73:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c78:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c7b:	b8 01 00 00 00       	mov    $0x1,%eax
  801c80:	e8 2a fe ff ff       	call   801aaf <fsipc>
  801c85:	89 c3                	mov    %eax,%ebx
  801c87:	85 c0                	test   %eax,%eax
  801c89:	79 17                	jns    801ca2 <open+0x6c>
		fd_close(fd, 0);
  801c8b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c92:	00 
  801c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c96:	89 04 24             	mov    %eax,(%esp)
  801c99:	e8 44 f9 ff ff       	call   8015e2 <fd_close>
		return r;
  801c9e:	89 d8                	mov    %ebx,%eax
  801ca0:	eb 12                	jmp    801cb4 <open+0x7e>
	return fd2num(fd);
  801ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca5:	89 04 24             	mov    %eax,(%esp)
  801ca8:	e8 d3 f7 ff ff       	call   801480 <fd2num>
  801cad:	eb 05                	jmp    801cb4 <open+0x7e>
		return -E_BAD_PATH;
  801caf:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801cb4:	83 c4 24             	add    $0x24,%esp
  801cb7:	5b                   	pop    %ebx
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    
  801cba:	66 90                	xchg   %ax,%ax
  801cbc:	66 90                	xchg   %ax,%ax
  801cbe:	66 90                	xchg   %ax,%ax

00801cc0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	56                   	push   %esi
  801cc4:	53                   	push   %ebx
  801cc5:	83 ec 10             	sub    $0x10,%esp
  801cc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cce:	89 04 24             	mov    %eax,(%esp)
  801cd1:	e8 ba f7 ff ff       	call   801490 <fd2data>
  801cd6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cd8:	c7 44 24 04 cd 2b 80 	movl   $0x802bcd,0x4(%esp)
  801cdf:	00 
  801ce0:	89 1c 24             	mov    %ebx,(%esp)
  801ce3:	e8 c3 eb ff ff       	call   8008ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ce8:	8b 46 04             	mov    0x4(%esi),%eax
  801ceb:	2b 06                	sub    (%esi),%eax
  801ced:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cf3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cfa:	00 00 00 
	stat->st_dev = &devpipe;
  801cfd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801d04:	30 80 00 
	return 0;
}
  801d07:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0c:	83 c4 10             	add    $0x10,%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    

00801d13 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	53                   	push   %ebx
  801d17:	83 ec 14             	sub    $0x14,%esp
  801d1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d1d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d28:	e8 d3 f0 ff ff       	call   800e00 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d2d:	89 1c 24             	mov    %ebx,(%esp)
  801d30:	e8 5b f7 ff ff       	call   801490 <fd2data>
  801d35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d40:	e8 bb f0 ff ff       	call   800e00 <sys_page_unmap>
}
  801d45:	83 c4 14             	add    $0x14,%esp
  801d48:	5b                   	pop    %ebx
  801d49:	5d                   	pop    %ebp
  801d4a:	c3                   	ret    

00801d4b <_pipeisclosed>:
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	57                   	push   %edi
  801d4f:	56                   	push   %esi
  801d50:	53                   	push   %ebx
  801d51:	83 ec 2c             	sub    $0x2c,%esp
  801d54:	89 c6                	mov    %eax,%esi
  801d56:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801d59:	a1 08 40 80 00       	mov    0x804008,%eax
  801d5e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d61:	89 34 24             	mov    %esi,(%esp)
  801d64:	e8 c0 05 00 00       	call   802329 <pageref>
  801d69:	89 c7                	mov    %eax,%edi
  801d6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d6e:	89 04 24             	mov    %eax,(%esp)
  801d71:	e8 b3 05 00 00       	call   802329 <pageref>
  801d76:	39 c7                	cmp    %eax,%edi
  801d78:	0f 94 c2             	sete   %dl
  801d7b:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801d7e:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801d84:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801d87:	39 fb                	cmp    %edi,%ebx
  801d89:	74 21                	je     801dac <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801d8b:	84 d2                	test   %dl,%dl
  801d8d:	74 ca                	je     801d59 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d8f:	8b 51 58             	mov    0x58(%ecx),%edx
  801d92:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d96:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d9e:	c7 04 24 d4 2b 80 00 	movl   $0x802bd4,(%esp)
  801da5:	e8 a1 e4 ff ff       	call   80024b <cprintf>
  801daa:	eb ad                	jmp    801d59 <_pipeisclosed+0xe>
}
  801dac:	83 c4 2c             	add    $0x2c,%esp
  801daf:	5b                   	pop    %ebx
  801db0:	5e                   	pop    %esi
  801db1:	5f                   	pop    %edi
  801db2:	5d                   	pop    %ebp
  801db3:	c3                   	ret    

00801db4 <devpipe_write>:
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	57                   	push   %edi
  801db8:	56                   	push   %esi
  801db9:	53                   	push   %ebx
  801dba:	83 ec 1c             	sub    $0x1c,%esp
  801dbd:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801dc0:	89 34 24             	mov    %esi,(%esp)
  801dc3:	e8 c8 f6 ff ff       	call   801490 <fd2data>
	for (i = 0; i < n; i++) {
  801dc8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dcc:	74 61                	je     801e2f <devpipe_write+0x7b>
  801dce:	89 c3                	mov    %eax,%ebx
  801dd0:	bf 00 00 00 00       	mov    $0x0,%edi
  801dd5:	eb 4a                	jmp    801e21 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  801dd7:	89 da                	mov    %ebx,%edx
  801dd9:	89 f0                	mov    %esi,%eax
  801ddb:	e8 6b ff ff ff       	call   801d4b <_pipeisclosed>
  801de0:	85 c0                	test   %eax,%eax
  801de2:	75 54                	jne    801e38 <devpipe_write+0x84>
			sys_yield();
  801de4:	e8 51 ef ff ff       	call   800d3a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801de9:	8b 43 04             	mov    0x4(%ebx),%eax
  801dec:	8b 0b                	mov    (%ebx),%ecx
  801dee:	8d 51 20             	lea    0x20(%ecx),%edx
  801df1:	39 d0                	cmp    %edx,%eax
  801df3:	73 e2                	jae    801dd7 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801df8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dfc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dff:	99                   	cltd   
  801e00:	c1 ea 1b             	shr    $0x1b,%edx
  801e03:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801e06:	83 e1 1f             	and    $0x1f,%ecx
  801e09:	29 d1                	sub    %edx,%ecx
  801e0b:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801e0f:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801e13:	83 c0 01             	add    $0x1,%eax
  801e16:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801e19:	83 c7 01             	add    $0x1,%edi
  801e1c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e1f:	74 13                	je     801e34 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e21:	8b 43 04             	mov    0x4(%ebx),%eax
  801e24:	8b 0b                	mov    (%ebx),%ecx
  801e26:	8d 51 20             	lea    0x20(%ecx),%edx
  801e29:	39 d0                	cmp    %edx,%eax
  801e2b:	73 aa                	jae    801dd7 <devpipe_write+0x23>
  801e2d:	eb c6                	jmp    801df5 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  801e2f:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  801e34:	89 f8                	mov    %edi,%eax
  801e36:	eb 05                	jmp    801e3d <devpipe_write+0x89>
				return 0;
  801e38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e3d:	83 c4 1c             	add    $0x1c,%esp
  801e40:	5b                   	pop    %ebx
  801e41:	5e                   	pop    %esi
  801e42:	5f                   	pop    %edi
  801e43:	5d                   	pop    %ebp
  801e44:	c3                   	ret    

00801e45 <devpipe_read>:
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	57                   	push   %edi
  801e49:	56                   	push   %esi
  801e4a:	53                   	push   %ebx
  801e4b:	83 ec 1c             	sub    $0x1c,%esp
  801e4e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e51:	89 3c 24             	mov    %edi,(%esp)
  801e54:	e8 37 f6 ff ff       	call   801490 <fd2data>
	for (i = 0; i < n; i++) {
  801e59:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e5d:	74 54                	je     801eb3 <devpipe_read+0x6e>
  801e5f:	89 c3                	mov    %eax,%ebx
  801e61:	be 00 00 00 00       	mov    $0x0,%esi
  801e66:	eb 3e                	jmp    801ea6 <devpipe_read+0x61>
				return i;
  801e68:	89 f0                	mov    %esi,%eax
  801e6a:	eb 55                	jmp    801ec1 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  801e6c:	89 da                	mov    %ebx,%edx
  801e6e:	89 f8                	mov    %edi,%eax
  801e70:	e8 d6 fe ff ff       	call   801d4b <_pipeisclosed>
  801e75:	85 c0                	test   %eax,%eax
  801e77:	75 43                	jne    801ebc <devpipe_read+0x77>
			sys_yield();
  801e79:	e8 bc ee ff ff       	call   800d3a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e7e:	8b 03                	mov    (%ebx),%eax
  801e80:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e83:	74 e7                	je     801e6c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e85:	99                   	cltd   
  801e86:	c1 ea 1b             	shr    $0x1b,%edx
  801e89:	01 d0                	add    %edx,%eax
  801e8b:	83 e0 1f             	and    $0x1f,%eax
  801e8e:	29 d0                	sub    %edx,%eax
  801e90:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e98:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e9b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e9e:	83 c6 01             	add    $0x1,%esi
  801ea1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ea4:	74 12                	je     801eb8 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  801ea6:	8b 03                	mov    (%ebx),%eax
  801ea8:	3b 43 04             	cmp    0x4(%ebx),%eax
  801eab:	75 d8                	jne    801e85 <devpipe_read+0x40>
			if (i > 0)
  801ead:	85 f6                	test   %esi,%esi
  801eaf:	75 b7                	jne    801e68 <devpipe_read+0x23>
  801eb1:	eb b9                	jmp    801e6c <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  801eb3:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  801eb8:	89 f0                	mov    %esi,%eax
  801eba:	eb 05                	jmp    801ec1 <devpipe_read+0x7c>
				return 0;
  801ebc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ec1:	83 c4 1c             	add    $0x1c,%esp
  801ec4:	5b                   	pop    %ebx
  801ec5:	5e                   	pop    %esi
  801ec6:	5f                   	pop    %edi
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    

00801ec9 <pipe>:
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	56                   	push   %esi
  801ecd:	53                   	push   %ebx
  801ece:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ed1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed4:	89 04 24             	mov    %eax,(%esp)
  801ed7:	e8 cb f5 ff ff       	call   8014a7 <fd_alloc>
  801edc:	89 c2                	mov    %eax,%edx
  801ede:	85 d2                	test   %edx,%edx
  801ee0:	0f 88 4d 01 00 00    	js     802033 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801eed:	00 
  801eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801efc:	e8 58 ee ff ff       	call   800d59 <sys_page_alloc>
  801f01:	89 c2                	mov    %eax,%edx
  801f03:	85 d2                	test   %edx,%edx
  801f05:	0f 88 28 01 00 00    	js     802033 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801f0b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f0e:	89 04 24             	mov    %eax,(%esp)
  801f11:	e8 91 f5 ff ff       	call   8014a7 <fd_alloc>
  801f16:	89 c3                	mov    %eax,%ebx
  801f18:	85 c0                	test   %eax,%eax
  801f1a:	0f 88 fe 00 00 00    	js     80201e <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f20:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f27:	00 
  801f28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f36:	e8 1e ee ff ff       	call   800d59 <sys_page_alloc>
  801f3b:	89 c3                	mov    %eax,%ebx
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	0f 88 d9 00 00 00    	js     80201e <pipe+0x155>
	va = fd2data(fd0);
  801f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f48:	89 04 24             	mov    %eax,(%esp)
  801f4b:	e8 40 f5 ff ff       	call   801490 <fd2data>
  801f50:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f52:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f59:	00 
  801f5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f65:	e8 ef ed ff ff       	call   800d59 <sys_page_alloc>
  801f6a:	89 c3                	mov    %eax,%ebx
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	0f 88 97 00 00 00    	js     80200b <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f77:	89 04 24             	mov    %eax,(%esp)
  801f7a:	e8 11 f5 ff ff       	call   801490 <fd2data>
  801f7f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f86:	00 
  801f87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f8b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f92:	00 
  801f93:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f9e:	e8 0a ee ff ff       	call   800dad <sys_page_map>
  801fa3:	89 c3                	mov    %eax,%ebx
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	78 52                	js     801ffb <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801fa9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801fbe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fc7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fcc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd6:	89 04 24             	mov    %eax,(%esp)
  801fd9:	e8 a2 f4 ff ff       	call   801480 <fd2num>
  801fde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fe1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fe3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fe6:	89 04 24             	mov    %eax,(%esp)
  801fe9:	e8 92 f4 ff ff       	call   801480 <fd2num>
  801fee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ff1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ff4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff9:	eb 38                	jmp    802033 <pipe+0x16a>
	sys_page_unmap(0, va);
  801ffb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802006:	e8 f5 ed ff ff       	call   800e00 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  80200b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80200e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802012:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802019:	e8 e2 ed ff ff       	call   800e00 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  80201e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802021:	89 44 24 04          	mov    %eax,0x4(%esp)
  802025:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80202c:	e8 cf ed ff ff       	call   800e00 <sys_page_unmap>
  802031:	89 d8                	mov    %ebx,%eax
}
  802033:	83 c4 30             	add    $0x30,%esp
  802036:	5b                   	pop    %ebx
  802037:	5e                   	pop    %esi
  802038:	5d                   	pop    %ebp
  802039:	c3                   	ret    

0080203a <pipeisclosed>:
{
  80203a:	55                   	push   %ebp
  80203b:	89 e5                	mov    %esp,%ebp
  80203d:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802040:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802043:	89 44 24 04          	mov    %eax,0x4(%esp)
  802047:	8b 45 08             	mov    0x8(%ebp),%eax
  80204a:	89 04 24             	mov    %eax,(%esp)
  80204d:	e8 c9 f4 ff ff       	call   80151b <fd_lookup>
  802052:	89 c2                	mov    %eax,%edx
  802054:	85 d2                	test   %edx,%edx
  802056:	78 15                	js     80206d <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  802058:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205b:	89 04 24             	mov    %eax,(%esp)
  80205e:	e8 2d f4 ff ff       	call   801490 <fd2data>
	return _pipeisclosed(fd, p);
  802063:	89 c2                	mov    %eax,%edx
  802065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802068:	e8 de fc ff ff       	call   801d4b <_pipeisclosed>
}
  80206d:	c9                   	leave  
  80206e:	c3                   	ret    
  80206f:	90                   	nop

00802070 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802073:	b8 00 00 00 00       	mov    $0x0,%eax
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    

0080207a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80207a:	55                   	push   %ebp
  80207b:	89 e5                	mov    %esp,%ebp
  80207d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802080:	c7 44 24 04 ec 2b 80 	movl   $0x802bec,0x4(%esp)
  802087:	00 
  802088:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208b:	89 04 24             	mov    %eax,(%esp)
  80208e:	e8 18 e8 ff ff       	call   8008ab <strcpy>
	return 0;
}
  802093:	b8 00 00 00 00       	mov    $0x0,%eax
  802098:	c9                   	leave  
  802099:	c3                   	ret    

0080209a <devcons_write>:
{
  80209a:	55                   	push   %ebp
  80209b:	89 e5                	mov    %esp,%ebp
  80209d:	57                   	push   %edi
  80209e:	56                   	push   %esi
  80209f:	53                   	push   %ebx
  8020a0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  8020a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020aa:	74 4a                	je     8020f6 <devcons_write+0x5c>
  8020ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b1:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8020b6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  8020bc:	8b 75 10             	mov    0x10(%ebp),%esi
  8020bf:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  8020c1:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  8020c4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020c9:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8020cc:	89 74 24 08          	mov    %esi,0x8(%esp)
  8020d0:	03 45 0c             	add    0xc(%ebp),%eax
  8020d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d7:	89 3c 24             	mov    %edi,(%esp)
  8020da:	e8 c7 e9 ff ff       	call   800aa6 <memmove>
		sys_cputs(buf, m);
  8020df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020e3:	89 3c 24             	mov    %edi,(%esp)
  8020e6:	e8 a1 eb ff ff       	call   800c8c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8020eb:	01 f3                	add    %esi,%ebx
  8020ed:	89 d8                	mov    %ebx,%eax
  8020ef:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020f2:	72 c8                	jb     8020bc <devcons_write+0x22>
  8020f4:	eb 05                	jmp    8020fb <devcons_write+0x61>
  8020f6:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  8020fb:	89 d8                	mov    %ebx,%eax
  8020fd:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    

00802108 <devcons_read>:
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80210e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802113:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802117:	75 07                	jne    802120 <devcons_read+0x18>
  802119:	eb 28                	jmp    802143 <devcons_read+0x3b>
		sys_yield();
  80211b:	e8 1a ec ff ff       	call   800d3a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802120:	e8 85 eb ff ff       	call   800caa <sys_cgetc>
  802125:	85 c0                	test   %eax,%eax
  802127:	74 f2                	je     80211b <devcons_read+0x13>
	if (c < 0)
  802129:	85 c0                	test   %eax,%eax
  80212b:	78 16                	js     802143 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  80212d:	83 f8 04             	cmp    $0x4,%eax
  802130:	74 0c                	je     80213e <devcons_read+0x36>
	*(char*)vbuf = c;
  802132:	8b 55 0c             	mov    0xc(%ebp),%edx
  802135:	88 02                	mov    %al,(%edx)
	return 1;
  802137:	b8 01 00 00 00       	mov    $0x1,%eax
  80213c:	eb 05                	jmp    802143 <devcons_read+0x3b>
		return 0;
  80213e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802143:	c9                   	leave  
  802144:	c3                   	ret    

00802145 <cputchar>:
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80214b:	8b 45 08             	mov    0x8(%ebp),%eax
  80214e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802151:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802158:	00 
  802159:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80215c:	89 04 24             	mov    %eax,(%esp)
  80215f:	e8 28 eb ff ff       	call   800c8c <sys_cputs>
}
  802164:	c9                   	leave  
  802165:	c3                   	ret    

00802166 <getchar>:
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80216c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802173:	00 
  802174:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80217b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802182:	e8 3f f6 ff ff       	call   8017c6 <read>
	if (r < 0)
  802187:	85 c0                	test   %eax,%eax
  802189:	78 0f                	js     80219a <getchar+0x34>
	if (r < 1)
  80218b:	85 c0                	test   %eax,%eax
  80218d:	7e 06                	jle    802195 <getchar+0x2f>
	return c;
  80218f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802193:	eb 05                	jmp    80219a <getchar+0x34>
		return -E_EOF;
  802195:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80219a:	c9                   	leave  
  80219b:	c3                   	ret    

0080219c <iscons>:
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ac:	89 04 24             	mov    %eax,(%esp)
  8021af:	e8 67 f3 ff ff       	call   80151b <fd_lookup>
  8021b4:	85 c0                	test   %eax,%eax
  8021b6:	78 11                	js     8021c9 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  8021b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021bb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021c1:	39 10                	cmp    %edx,(%eax)
  8021c3:	0f 94 c0             	sete   %al
  8021c6:	0f b6 c0             	movzbl %al,%eax
}
  8021c9:	c9                   	leave  
  8021ca:	c3                   	ret    

008021cb <opencons>:
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8021d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d4:	89 04 24             	mov    %eax,(%esp)
  8021d7:	e8 cb f2 ff ff       	call   8014a7 <fd_alloc>
		return r;
  8021dc:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  8021de:	85 c0                	test   %eax,%eax
  8021e0:	78 40                	js     802222 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021e9:	00 
  8021ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021f8:	e8 5c eb ff ff       	call   800d59 <sys_page_alloc>
		return r;
  8021fd:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021ff:	85 c0                	test   %eax,%eax
  802201:	78 1f                	js     802222 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  802203:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802209:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80220e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802211:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802218:	89 04 24             	mov    %eax,(%esp)
  80221b:	e8 60 f2 ff ff       	call   801480 <fd2num>
  802220:	89 c2                	mov    %eax,%edx
}
  802222:	89 d0                	mov    %edx,%eax
  802224:	c9                   	leave  
  802225:	c3                   	ret    

00802226 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802226:	55                   	push   %ebp
  802227:	89 e5                	mov    %esp,%ebp
  802229:	56                   	push   %esi
  80222a:	53                   	push   %ebx
  80222b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80222e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802231:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802237:	e8 df ea ff ff       	call   800d1b <sys_getenvid>
  80223c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80223f:	89 54 24 10          	mov    %edx,0x10(%esp)
  802243:	8b 55 08             	mov    0x8(%ebp),%edx
  802246:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80224a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80224e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802252:	c7 04 24 f8 2b 80 00 	movl   $0x802bf8,(%esp)
  802259:	e8 ed df ff ff       	call   80024b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80225e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802262:	8b 45 10             	mov    0x10(%ebp),%eax
  802265:	89 04 24             	mov    %eax,(%esp)
  802268:	e8 7d df ff ff       	call   8001ea <vcprintf>
	cprintf("\n");
  80226d:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  802274:	e8 d2 df ff ff       	call   80024b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802279:	cc                   	int3   
  80227a:	eb fd                	jmp    802279 <_panic+0x53>

0080227c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80227c:	55                   	push   %ebp
  80227d:	89 e5                	mov    %esp,%ebp
  80227f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802282:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802289:	75 70                	jne    8022fb <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  80228b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802292:	00 
  802293:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80229a:	ee 
  80229b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022a2:	e8 b2 ea ff ff       	call   800d59 <sys_page_alloc>
  8022a7:	85 c0                	test   %eax,%eax
  8022a9:	79 1c                	jns    8022c7 <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  8022ab:	c7 44 24 08 1c 2c 80 	movl   $0x802c1c,0x8(%esp)
  8022b2:	00 
  8022b3:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8022ba:	00 
  8022bb:	c7 04 24 80 2c 80 00 	movl   $0x802c80,(%esp)
  8022c2:	e8 5f ff ff ff       	call   802226 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8022c7:	c7 44 24 04 05 23 80 	movl   $0x802305,0x4(%esp)
  8022ce:	00 
  8022cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022d6:	e8 1e ec ff ff       	call   800ef9 <sys_env_set_pgfault_upcall>
  8022db:	85 c0                	test   %eax,%eax
  8022dd:	79 1c                	jns    8022fb <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  8022df:	c7 44 24 08 48 2c 80 	movl   $0x802c48,0x8(%esp)
  8022e6:	00 
  8022e7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8022ee:	00 
  8022ef:	c7 04 24 80 2c 80 00 	movl   $0x802c80,(%esp)
  8022f6:	e8 2b ff ff ff       	call   802226 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fe:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802303:	c9                   	leave  
  802304:	c3                   	ret    

00802305 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802305:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802306:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80230b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80230d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  802310:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  802314:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  802319:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  80231d:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80231f:	83 c4 08             	add    $0x8,%esp
	popal
  802322:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802323:	83 c4 04             	add    $0x4,%esp
	popfl
  802326:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802327:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802328:	c3                   	ret    

00802329 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802329:	55                   	push   %ebp
  80232a:	89 e5                	mov    %esp,%ebp
  80232c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80232f:	89 d0                	mov    %edx,%eax
  802331:	c1 e8 16             	shr    $0x16,%eax
  802334:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80233b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  802340:	f6 c1 01             	test   $0x1,%cl
  802343:	74 1d                	je     802362 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802345:	c1 ea 0c             	shr    $0xc,%edx
  802348:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80234f:	f6 c2 01             	test   $0x1,%dl
  802352:	74 0e                	je     802362 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802354:	c1 ea 0c             	shr    $0xc,%edx
  802357:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80235e:	ef 
  80235f:	0f b7 c0             	movzwl %ax,%eax
}
  802362:	5d                   	pop    %ebp
  802363:	c3                   	ret    
  802364:	66 90                	xchg   %ax,%ax
  802366:	66 90                	xchg   %ax,%ax
  802368:	66 90                	xchg   %ax,%ax
  80236a:	66 90                	xchg   %ax,%ax
  80236c:	66 90                	xchg   %ax,%ax
  80236e:	66 90                	xchg   %ax,%ax

00802370 <__udivdi3>:
  802370:	55                   	push   %ebp
  802371:	57                   	push   %edi
  802372:	56                   	push   %esi
  802373:	83 ec 0c             	sub    $0xc,%esp
  802376:	8b 44 24 28          	mov    0x28(%esp),%eax
  80237a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80237e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802382:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802386:	85 c0                	test   %eax,%eax
  802388:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80238c:	89 ea                	mov    %ebp,%edx
  80238e:	89 0c 24             	mov    %ecx,(%esp)
  802391:	75 2d                	jne    8023c0 <__udivdi3+0x50>
  802393:	39 e9                	cmp    %ebp,%ecx
  802395:	77 61                	ja     8023f8 <__udivdi3+0x88>
  802397:	85 c9                	test   %ecx,%ecx
  802399:	89 ce                	mov    %ecx,%esi
  80239b:	75 0b                	jne    8023a8 <__udivdi3+0x38>
  80239d:	b8 01 00 00 00       	mov    $0x1,%eax
  8023a2:	31 d2                	xor    %edx,%edx
  8023a4:	f7 f1                	div    %ecx
  8023a6:	89 c6                	mov    %eax,%esi
  8023a8:	31 d2                	xor    %edx,%edx
  8023aa:	89 e8                	mov    %ebp,%eax
  8023ac:	f7 f6                	div    %esi
  8023ae:	89 c5                	mov    %eax,%ebp
  8023b0:	89 f8                	mov    %edi,%eax
  8023b2:	f7 f6                	div    %esi
  8023b4:	89 ea                	mov    %ebp,%edx
  8023b6:	83 c4 0c             	add    $0xc,%esp
  8023b9:	5e                   	pop    %esi
  8023ba:	5f                   	pop    %edi
  8023bb:	5d                   	pop    %ebp
  8023bc:	c3                   	ret    
  8023bd:	8d 76 00             	lea    0x0(%esi),%esi
  8023c0:	39 e8                	cmp    %ebp,%eax
  8023c2:	77 24                	ja     8023e8 <__udivdi3+0x78>
  8023c4:	0f bd e8             	bsr    %eax,%ebp
  8023c7:	83 f5 1f             	xor    $0x1f,%ebp
  8023ca:	75 3c                	jne    802408 <__udivdi3+0x98>
  8023cc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8023d0:	39 34 24             	cmp    %esi,(%esp)
  8023d3:	0f 86 9f 00 00 00    	jbe    802478 <__udivdi3+0x108>
  8023d9:	39 d0                	cmp    %edx,%eax
  8023db:	0f 82 97 00 00 00    	jb     802478 <__udivdi3+0x108>
  8023e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023e8:	31 d2                	xor    %edx,%edx
  8023ea:	31 c0                	xor    %eax,%eax
  8023ec:	83 c4 0c             	add    $0xc,%esp
  8023ef:	5e                   	pop    %esi
  8023f0:	5f                   	pop    %edi
  8023f1:	5d                   	pop    %ebp
  8023f2:	c3                   	ret    
  8023f3:	90                   	nop
  8023f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023f8:	89 f8                	mov    %edi,%eax
  8023fa:	f7 f1                	div    %ecx
  8023fc:	31 d2                	xor    %edx,%edx
  8023fe:	83 c4 0c             	add    $0xc,%esp
  802401:	5e                   	pop    %esi
  802402:	5f                   	pop    %edi
  802403:	5d                   	pop    %ebp
  802404:	c3                   	ret    
  802405:	8d 76 00             	lea    0x0(%esi),%esi
  802408:	89 e9                	mov    %ebp,%ecx
  80240a:	8b 3c 24             	mov    (%esp),%edi
  80240d:	d3 e0                	shl    %cl,%eax
  80240f:	89 c6                	mov    %eax,%esi
  802411:	b8 20 00 00 00       	mov    $0x20,%eax
  802416:	29 e8                	sub    %ebp,%eax
  802418:	89 c1                	mov    %eax,%ecx
  80241a:	d3 ef                	shr    %cl,%edi
  80241c:	89 e9                	mov    %ebp,%ecx
  80241e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802422:	8b 3c 24             	mov    (%esp),%edi
  802425:	09 74 24 08          	or     %esi,0x8(%esp)
  802429:	89 d6                	mov    %edx,%esi
  80242b:	d3 e7                	shl    %cl,%edi
  80242d:	89 c1                	mov    %eax,%ecx
  80242f:	89 3c 24             	mov    %edi,(%esp)
  802432:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802436:	d3 ee                	shr    %cl,%esi
  802438:	89 e9                	mov    %ebp,%ecx
  80243a:	d3 e2                	shl    %cl,%edx
  80243c:	89 c1                	mov    %eax,%ecx
  80243e:	d3 ef                	shr    %cl,%edi
  802440:	09 d7                	or     %edx,%edi
  802442:	89 f2                	mov    %esi,%edx
  802444:	89 f8                	mov    %edi,%eax
  802446:	f7 74 24 08          	divl   0x8(%esp)
  80244a:	89 d6                	mov    %edx,%esi
  80244c:	89 c7                	mov    %eax,%edi
  80244e:	f7 24 24             	mull   (%esp)
  802451:	39 d6                	cmp    %edx,%esi
  802453:	89 14 24             	mov    %edx,(%esp)
  802456:	72 30                	jb     802488 <__udivdi3+0x118>
  802458:	8b 54 24 04          	mov    0x4(%esp),%edx
  80245c:	89 e9                	mov    %ebp,%ecx
  80245e:	d3 e2                	shl    %cl,%edx
  802460:	39 c2                	cmp    %eax,%edx
  802462:	73 05                	jae    802469 <__udivdi3+0xf9>
  802464:	3b 34 24             	cmp    (%esp),%esi
  802467:	74 1f                	je     802488 <__udivdi3+0x118>
  802469:	89 f8                	mov    %edi,%eax
  80246b:	31 d2                	xor    %edx,%edx
  80246d:	e9 7a ff ff ff       	jmp    8023ec <__udivdi3+0x7c>
  802472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802478:	31 d2                	xor    %edx,%edx
  80247a:	b8 01 00 00 00       	mov    $0x1,%eax
  80247f:	e9 68 ff ff ff       	jmp    8023ec <__udivdi3+0x7c>
  802484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802488:	8d 47 ff             	lea    -0x1(%edi),%eax
  80248b:	31 d2                	xor    %edx,%edx
  80248d:	83 c4 0c             	add    $0xc,%esp
  802490:	5e                   	pop    %esi
  802491:	5f                   	pop    %edi
  802492:	5d                   	pop    %ebp
  802493:	c3                   	ret    
  802494:	66 90                	xchg   %ax,%ax
  802496:	66 90                	xchg   %ax,%ax
  802498:	66 90                	xchg   %ax,%ax
  80249a:	66 90                	xchg   %ax,%ax
  80249c:	66 90                	xchg   %ax,%ax
  80249e:	66 90                	xchg   %ax,%ax

008024a0 <__umoddi3>:
  8024a0:	55                   	push   %ebp
  8024a1:	57                   	push   %edi
  8024a2:	56                   	push   %esi
  8024a3:	83 ec 14             	sub    $0x14,%esp
  8024a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8024aa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8024ae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8024b2:	89 c7                	mov    %eax,%edi
  8024b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024b8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024bc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8024c0:	89 34 24             	mov    %esi,(%esp)
  8024c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024c7:	85 c0                	test   %eax,%eax
  8024c9:	89 c2                	mov    %eax,%edx
  8024cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024cf:	75 17                	jne    8024e8 <__umoddi3+0x48>
  8024d1:	39 fe                	cmp    %edi,%esi
  8024d3:	76 4b                	jbe    802520 <__umoddi3+0x80>
  8024d5:	89 c8                	mov    %ecx,%eax
  8024d7:	89 fa                	mov    %edi,%edx
  8024d9:	f7 f6                	div    %esi
  8024db:	89 d0                	mov    %edx,%eax
  8024dd:	31 d2                	xor    %edx,%edx
  8024df:	83 c4 14             	add    $0x14,%esp
  8024e2:	5e                   	pop    %esi
  8024e3:	5f                   	pop    %edi
  8024e4:	5d                   	pop    %ebp
  8024e5:	c3                   	ret    
  8024e6:	66 90                	xchg   %ax,%ax
  8024e8:	39 f8                	cmp    %edi,%eax
  8024ea:	77 54                	ja     802540 <__umoddi3+0xa0>
  8024ec:	0f bd e8             	bsr    %eax,%ebp
  8024ef:	83 f5 1f             	xor    $0x1f,%ebp
  8024f2:	75 5c                	jne    802550 <__umoddi3+0xb0>
  8024f4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8024f8:	39 3c 24             	cmp    %edi,(%esp)
  8024fb:	0f 87 e7 00 00 00    	ja     8025e8 <__umoddi3+0x148>
  802501:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802505:	29 f1                	sub    %esi,%ecx
  802507:	19 c7                	sbb    %eax,%edi
  802509:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80250d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802511:	8b 44 24 08          	mov    0x8(%esp),%eax
  802515:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802519:	83 c4 14             	add    $0x14,%esp
  80251c:	5e                   	pop    %esi
  80251d:	5f                   	pop    %edi
  80251e:	5d                   	pop    %ebp
  80251f:	c3                   	ret    
  802520:	85 f6                	test   %esi,%esi
  802522:	89 f5                	mov    %esi,%ebp
  802524:	75 0b                	jne    802531 <__umoddi3+0x91>
  802526:	b8 01 00 00 00       	mov    $0x1,%eax
  80252b:	31 d2                	xor    %edx,%edx
  80252d:	f7 f6                	div    %esi
  80252f:	89 c5                	mov    %eax,%ebp
  802531:	8b 44 24 04          	mov    0x4(%esp),%eax
  802535:	31 d2                	xor    %edx,%edx
  802537:	f7 f5                	div    %ebp
  802539:	89 c8                	mov    %ecx,%eax
  80253b:	f7 f5                	div    %ebp
  80253d:	eb 9c                	jmp    8024db <__umoddi3+0x3b>
  80253f:	90                   	nop
  802540:	89 c8                	mov    %ecx,%eax
  802542:	89 fa                	mov    %edi,%edx
  802544:	83 c4 14             	add    $0x14,%esp
  802547:	5e                   	pop    %esi
  802548:	5f                   	pop    %edi
  802549:	5d                   	pop    %ebp
  80254a:	c3                   	ret    
  80254b:	90                   	nop
  80254c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802550:	8b 04 24             	mov    (%esp),%eax
  802553:	be 20 00 00 00       	mov    $0x20,%esi
  802558:	89 e9                	mov    %ebp,%ecx
  80255a:	29 ee                	sub    %ebp,%esi
  80255c:	d3 e2                	shl    %cl,%edx
  80255e:	89 f1                	mov    %esi,%ecx
  802560:	d3 e8                	shr    %cl,%eax
  802562:	89 e9                	mov    %ebp,%ecx
  802564:	89 44 24 04          	mov    %eax,0x4(%esp)
  802568:	8b 04 24             	mov    (%esp),%eax
  80256b:	09 54 24 04          	or     %edx,0x4(%esp)
  80256f:	89 fa                	mov    %edi,%edx
  802571:	d3 e0                	shl    %cl,%eax
  802573:	89 f1                	mov    %esi,%ecx
  802575:	89 44 24 08          	mov    %eax,0x8(%esp)
  802579:	8b 44 24 10          	mov    0x10(%esp),%eax
  80257d:	d3 ea                	shr    %cl,%edx
  80257f:	89 e9                	mov    %ebp,%ecx
  802581:	d3 e7                	shl    %cl,%edi
  802583:	89 f1                	mov    %esi,%ecx
  802585:	d3 e8                	shr    %cl,%eax
  802587:	89 e9                	mov    %ebp,%ecx
  802589:	09 f8                	or     %edi,%eax
  80258b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80258f:	f7 74 24 04          	divl   0x4(%esp)
  802593:	d3 e7                	shl    %cl,%edi
  802595:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802599:	89 d7                	mov    %edx,%edi
  80259b:	f7 64 24 08          	mull   0x8(%esp)
  80259f:	39 d7                	cmp    %edx,%edi
  8025a1:	89 c1                	mov    %eax,%ecx
  8025a3:	89 14 24             	mov    %edx,(%esp)
  8025a6:	72 2c                	jb     8025d4 <__umoddi3+0x134>
  8025a8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8025ac:	72 22                	jb     8025d0 <__umoddi3+0x130>
  8025ae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025b2:	29 c8                	sub    %ecx,%eax
  8025b4:	19 d7                	sbb    %edx,%edi
  8025b6:	89 e9                	mov    %ebp,%ecx
  8025b8:	89 fa                	mov    %edi,%edx
  8025ba:	d3 e8                	shr    %cl,%eax
  8025bc:	89 f1                	mov    %esi,%ecx
  8025be:	d3 e2                	shl    %cl,%edx
  8025c0:	89 e9                	mov    %ebp,%ecx
  8025c2:	d3 ef                	shr    %cl,%edi
  8025c4:	09 d0                	or     %edx,%eax
  8025c6:	89 fa                	mov    %edi,%edx
  8025c8:	83 c4 14             	add    $0x14,%esp
  8025cb:	5e                   	pop    %esi
  8025cc:	5f                   	pop    %edi
  8025cd:	5d                   	pop    %ebp
  8025ce:	c3                   	ret    
  8025cf:	90                   	nop
  8025d0:	39 d7                	cmp    %edx,%edi
  8025d2:	75 da                	jne    8025ae <__umoddi3+0x10e>
  8025d4:	8b 14 24             	mov    (%esp),%edx
  8025d7:	89 c1                	mov    %eax,%ecx
  8025d9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8025dd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8025e1:	eb cb                	jmp    8025ae <__umoddi3+0x10e>
  8025e3:	90                   	nop
  8025e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025e8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8025ec:	0f 82 0f ff ff ff    	jb     802501 <__umoddi3+0x61>
  8025f2:	e9 1a ff ff ff       	jmp    802511 <__umoddi3+0x71>
