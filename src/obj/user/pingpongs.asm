
obj/user/pingpongs：     文件格式 elf32-i386


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
  80003c:	e8 71 12 00 00       	call   8012b2 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 5e                	je     8000a6 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004e:	e8 b8 0c 00 00       	call   800d0b <sys_getenvid>
  800053:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800057:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005b:	c7 04 24 60 17 80 00 	movl   $0x801760,(%esp)
  800062:	e8 df 01 00 00       	call   800246 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800067:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006a:	e8 9c 0c 00 00       	call   800d0b <sys_getenvid>
  80006f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	c7 04 24 7a 17 80 00 	movl   $0x80177a,(%esp)
  80007e:	e8 c3 01 00 00       	call   800246 <cprintf>
		ipc_send(who, 0, 0, 0);
  800083:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008a:	00 
  80008b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800092:	00 
  800093:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009a:	00 
  80009b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009e:	89 04 24             	mov    %eax,(%esp)
  8000a1:	e8 8a 12 00 00       	call   801330 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 13 12 00 00       	call   8012d4 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c1:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c7:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000ca:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000cd:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000d5:	e8 31 0c 00 00       	call   800d0b <sys_getenvid>
  8000da:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8000de:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000e9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f1:	c7 04 24 90 17 80 00 	movl   $0x801790,(%esp)
  8000f8:	e8 49 01 00 00       	call   800246 <cprintf>
		if (val == 10)
  8000fd:	a1 04 20 80 00       	mov    0x802004,%eax
  800102:	83 f8 0a             	cmp    $0xa,%eax
  800105:	74 38                	je     80013f <umain+0x10c>
			return;
		++val;
  800107:	83 c0 01             	add    $0x1,%eax
  80010a:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  80010f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800126:	00 
  800127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 fe 11 00 00       	call   801330 <ipc_send>
		if (val == 10)
  800132:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
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
  800155:	e8 b1 0b 00 00       	call   800d0b <sys_getenvid>
  80015a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800162:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800167:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016c:	85 db                	test   %ebx,%ebx
  80016e:	7e 07                	jle    800177 <libmain+0x30>
		binaryname = argv[0];
  800170:	8b 06                	mov    (%esi),%eax
  800172:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  800195:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80019c:	e8 18 0b 00 00       	call   800cb9 <sys_env_destroy>
}
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 14             	sub    $0x14,%esp
  8001aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ad:	8b 13                	mov    (%ebx),%edx
  8001af:	8d 42 01             	lea    0x1(%edx),%eax
  8001b2:	89 03                	mov    %eax,(%ebx)
  8001b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001bb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c0:	75 19                	jne    8001db <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c9:	00 
  8001ca:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cd:	89 04 24             	mov    %eax,(%esp)
  8001d0:	e8 a7 0a 00 00       	call   800c7c <sys_cputs>
		b->idx = 0;
  8001d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001db:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001df:	83 c4 14             	add    $0x14,%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ee:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f5:	00 00 00 
	b.cnt = 0;
  8001f8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ff:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800202:	8b 45 0c             	mov    0xc(%ebp),%eax
  800205:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800209:	8b 45 08             	mov    0x8(%ebp),%eax
  80020c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800210:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800216:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021a:	c7 04 24 a3 01 80 00 	movl   $0x8001a3,(%esp)
  800221:	e8 ae 01 00 00       	call   8003d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800226:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80022c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800230:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800236:	89 04 24             	mov    %eax,(%esp)
  800239:	e8 3e 0a 00 00       	call   800c7c <sys_cputs>

	return b.cnt;
}
  80023e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	89 04 24             	mov    %eax,(%esp)
  800259:	e8 87 ff ff ff       	call   8001e5 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800274:	8b 75 0c             	mov    0xc(%ebp),%esi
  800277:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80027a:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800282:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800285:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800288:	39 f1                	cmp    %esi,%ecx
  80028a:	72 14                	jb     8002a0 <printnum+0x40>
  80028c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80028f:	76 0f                	jbe    8002a0 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800291:	8b 45 14             	mov    0x14(%ebp),%eax
  800294:	8d 70 ff             	lea    -0x1(%eax),%esi
  800297:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80029a:	85 f6                	test   %esi,%esi
  80029c:	7f 60                	jg     8002fe <printnum+0x9e>
  80029e:	eb 72                	jmp    800312 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002a3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002a7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8002aa:	8d 51 ff             	lea    -0x1(%ecx),%edx
  8002ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b5:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002b9:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002bd:	89 c3                	mov    %eax,%ebx
  8002bf:	89 d6                	mov    %edx,%esi
  8002c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002c4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002c7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002cb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dc:	e8 ef 11 00 00       	call   8014d0 <__udivdi3>
  8002e1:	89 d9                	mov    %ebx,%ecx
  8002e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002e7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002eb:	89 04 24             	mov    %eax,(%esp)
  8002ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f2:	89 fa                	mov    %edi,%edx
  8002f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f7:	e8 64 ff ff ff       	call   800260 <printnum>
  8002fc:	eb 14                	jmp    800312 <printnum+0xb2>
			putch(padc, putdat);
  8002fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800302:	8b 45 18             	mov    0x18(%ebp),%eax
  800305:	89 04 24             	mov    %eax,(%esp)
  800308:	ff d3                	call   *%ebx
		while (--width > 0)
  80030a:	83 ee 01             	sub    $0x1,%esi
  80030d:	75 ef                	jne    8002fe <printnum+0x9e>
  80030f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800312:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800316:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80031a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80031d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800320:	89 44 24 08          	mov    %eax,0x8(%esp)
  800324:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800328:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032b:	89 04 24             	mov    %eax,(%esp)
  80032e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800331:	89 44 24 04          	mov    %eax,0x4(%esp)
  800335:	e8 c6 12 00 00       	call   801600 <__umoddi3>
  80033a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033e:	0f be 80 c0 17 80 00 	movsbl 0x8017c0(%eax),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034b:	ff d0                	call   *%eax
}
  80034d:	83 c4 3c             	add    $0x3c,%esp
  800350:	5b                   	pop    %ebx
  800351:	5e                   	pop    %esi
  800352:	5f                   	pop    %edi
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800358:	83 fa 01             	cmp    $0x1,%edx
  80035b:	7e 0e                	jle    80036b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035d:	8b 10                	mov    (%eax),%edx
  80035f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800362:	89 08                	mov    %ecx,(%eax)
  800364:	8b 02                	mov    (%edx),%eax
  800366:	8b 52 04             	mov    0x4(%edx),%edx
  800369:	eb 22                	jmp    80038d <getuint+0x38>
	else if (lflag)
  80036b:	85 d2                	test   %edx,%edx
  80036d:	74 10                	je     80037f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80036f:	8b 10                	mov    (%eax),%edx
  800371:	8d 4a 04             	lea    0x4(%edx),%ecx
  800374:	89 08                	mov    %ecx,(%eax)
  800376:	8b 02                	mov    (%edx),%eax
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
  80037d:	eb 0e                	jmp    80038d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80037f:	8b 10                	mov    (%eax),%edx
  800381:	8d 4a 04             	lea    0x4(%edx),%ecx
  800384:	89 08                	mov    %ecx,(%eax)
  800386:	8b 02                	mov    (%edx),%eax
  800388:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800395:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	3b 50 04             	cmp    0x4(%eax),%edx
  80039e:	73 0a                	jae    8003aa <sprintputch+0x1b>
		*b->buf++ = ch;
  8003a0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	88 02                	mov    %al,(%edx)
}
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <printfmt>:
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8003b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ca:	89 04 24             	mov    %eax,(%esp)
  8003cd:	e8 02 00 00 00       	call   8003d4 <vprintfmt>
}
  8003d2:	c9                   	leave  
  8003d3:	c3                   	ret    

008003d4 <vprintfmt>:
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	57                   	push   %edi
  8003d8:	56                   	push   %esi
  8003d9:	53                   	push   %ebx
  8003da:	83 ec 3c             	sub    $0x3c,%esp
  8003dd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003e3:	eb 18                	jmp    8003fd <vprintfmt+0x29>
			if (ch == '\0')
  8003e5:	85 c0                	test   %eax,%eax
  8003e7:	0f 84 c3 03 00 00    	je     8007b0 <vprintfmt+0x3dc>
			putch(ch, putdat);
  8003ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f1:	89 04 24             	mov    %eax,(%esp)
  8003f4:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f7:	89 f3                	mov    %esi,%ebx
  8003f9:	eb 02                	jmp    8003fd <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  8003fb:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003fd:	8d 73 01             	lea    0x1(%ebx),%esi
  800400:	0f b6 03             	movzbl (%ebx),%eax
  800403:	83 f8 25             	cmp    $0x25,%eax
  800406:	75 dd                	jne    8003e5 <vprintfmt+0x11>
  800408:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80040c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800413:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80041a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800421:	ba 00 00 00 00       	mov    $0x0,%edx
  800426:	eb 1d                	jmp    800445 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800428:	89 de                	mov    %ebx,%esi
			padc = '-';
  80042a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80042e:	eb 15                	jmp    800445 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800430:	89 de                	mov    %ebx,%esi
			padc = '0';
  800432:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800436:	eb 0d                	jmp    800445 <vprintfmt+0x71>
				width = precision, precision = -1;
  800438:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80043b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80043e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8d 5e 01             	lea    0x1(%esi),%ebx
  800448:	0f b6 06             	movzbl (%esi),%eax
  80044b:	0f b6 c8             	movzbl %al,%ecx
  80044e:	83 e8 23             	sub    $0x23,%eax
  800451:	3c 55                	cmp    $0x55,%al
  800453:	0f 87 2f 03 00 00    	ja     800788 <vprintfmt+0x3b4>
  800459:	0f b6 c0             	movzbl %al,%eax
  80045c:	ff 24 85 80 18 80 00 	jmp    *0x801880(,%eax,4)
				precision = precision * 10 + ch - '0';
  800463:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800466:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  800469:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80046d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800470:	83 f9 09             	cmp    $0x9,%ecx
  800473:	77 50                	ja     8004c5 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  800475:	89 de                	mov    %ebx,%esi
  800477:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  80047a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80047d:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800480:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800484:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800487:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80048a:	83 fb 09             	cmp    $0x9,%ebx
  80048d:	76 eb                	jbe    80047a <vprintfmt+0xa6>
  80048f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800492:	eb 33                	jmp    8004c7 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8d 48 04             	lea    0x4(%eax),%ecx
  80049a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8004a4:	eb 21                	jmp    8004c7 <vprintfmt+0xf3>
  8004a6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004a9:	85 c9                	test   %ecx,%ecx
  8004ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b0:	0f 49 c1             	cmovns %ecx,%eax
  8004b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	89 de                	mov    %ebx,%esi
  8004b8:	eb 8b                	jmp    800445 <vprintfmt+0x71>
  8004ba:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8004bc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c3:	eb 80                	jmp    800445 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	89 de                	mov    %ebx,%esi
			if (width < 0)
  8004c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004cb:	0f 89 74 ff ff ff    	jns    800445 <vprintfmt+0x71>
  8004d1:	e9 62 ff ff ff       	jmp    800438 <vprintfmt+0x64>
			lflag++;
  8004d6:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8004db:	e9 65 ff ff ff       	jmp    800445 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ed:	8b 00                	mov    (%eax),%eax
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004f5:	e9 03 ff ff ff       	jmp    8003fd <vprintfmt+0x29>
			err = va_arg(ap, int);
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 50 04             	lea    0x4(%eax),%edx
  800500:	89 55 14             	mov    %edx,0x14(%ebp)
  800503:	8b 00                	mov    (%eax),%eax
  800505:	99                   	cltd   
  800506:	31 d0                	xor    %edx,%eax
  800508:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050a:	83 f8 08             	cmp    $0x8,%eax
  80050d:	7f 0b                	jg     80051a <vprintfmt+0x146>
  80050f:	8b 14 85 e0 19 80 00 	mov    0x8019e0(,%eax,4),%edx
  800516:	85 d2                	test   %edx,%edx
  800518:	75 20                	jne    80053a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80051a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051e:	c7 44 24 08 d8 17 80 	movl   $0x8017d8,0x8(%esp)
  800525:	00 
  800526:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052a:	8b 45 08             	mov    0x8(%ebp),%eax
  80052d:	89 04 24             	mov    %eax,(%esp)
  800530:	e8 77 fe ff ff       	call   8003ac <printfmt>
  800535:	e9 c3 fe ff ff       	jmp    8003fd <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80053a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80053e:	c7 44 24 08 e1 17 80 	movl   $0x8017e1,0x8(%esp)
  800545:	00 
  800546:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054a:	8b 45 08             	mov    0x8(%ebp),%eax
  80054d:	89 04 24             	mov    %eax,(%esp)
  800550:	e8 57 fe ff ff       	call   8003ac <printfmt>
  800555:	e9 a3 fe ff ff       	jmp    8003fd <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80055d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 04             	lea    0x4(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80056b:	85 c0                	test   %eax,%eax
  80056d:	ba d1 17 80 00       	mov    $0x8017d1,%edx
  800572:	0f 45 d0             	cmovne %eax,%edx
  800575:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800578:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80057c:	74 04                	je     800582 <vprintfmt+0x1ae>
  80057e:	85 f6                	test   %esi,%esi
  800580:	7f 19                	jg     80059b <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800582:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800585:	8d 70 01             	lea    0x1(%eax),%esi
  800588:	0f b6 10             	movzbl (%eax),%edx
  80058b:	0f be c2             	movsbl %dl,%eax
  80058e:	85 c0                	test   %eax,%eax
  800590:	0f 85 95 00 00 00    	jne    80062b <vprintfmt+0x257>
  800596:	e9 85 00 00 00       	jmp    800620 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80059f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005a2:	89 04 24             	mov    %eax,(%esp)
  8005a5:	e8 b8 02 00 00       	call   800862 <strnlen>
  8005aa:	29 c6                	sub    %eax,%esi
  8005ac:	89 f0                	mov    %esi,%eax
  8005ae:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8005b1:	85 f6                	test   %esi,%esi
  8005b3:	7e cd                	jle    800582 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8005b5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8005b9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005bc:	89 c3                	mov    %eax,%ebx
  8005be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c2:	89 34 24             	mov    %esi,(%esp)
  8005c5:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c8:	83 eb 01             	sub    $0x1,%ebx
  8005cb:	75 f1                	jne    8005be <vprintfmt+0x1ea>
  8005cd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005d3:	eb ad                	jmp    800582 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005d9:	74 1e                	je     8005f9 <vprintfmt+0x225>
  8005db:	0f be d2             	movsbl %dl,%edx
  8005de:	83 ea 20             	sub    $0x20,%edx
  8005e1:	83 fa 5e             	cmp    $0x5e,%edx
  8005e4:	76 13                	jbe    8005f9 <vprintfmt+0x225>
					putch('?', putdat);
  8005e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ed:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005f4:	ff 55 08             	call   *0x8(%ebp)
  8005f7:	eb 0d                	jmp    800606 <vprintfmt+0x232>
					putch(ch, putdat);
  8005f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005fc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800600:	89 04 24             	mov    %eax,(%esp)
  800603:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800606:	83 ef 01             	sub    $0x1,%edi
  800609:	83 c6 01             	add    $0x1,%esi
  80060c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800610:	0f be c2             	movsbl %dl,%eax
  800613:	85 c0                	test   %eax,%eax
  800615:	75 20                	jne    800637 <vprintfmt+0x263>
  800617:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80061a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80061d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800620:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800624:	7f 25                	jg     80064b <vprintfmt+0x277>
  800626:	e9 d2 fd ff ff       	jmp    8003fd <vprintfmt+0x29>
  80062b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80062e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800631:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800634:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800637:	85 db                	test   %ebx,%ebx
  800639:	78 9a                	js     8005d5 <vprintfmt+0x201>
  80063b:	83 eb 01             	sub    $0x1,%ebx
  80063e:	79 95                	jns    8005d5 <vprintfmt+0x201>
  800640:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800643:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800646:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800649:	eb d5                	jmp    800620 <vprintfmt+0x24c>
  80064b:	8b 75 08             	mov    0x8(%ebp),%esi
  80064e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800651:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  800654:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800658:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80065f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800661:	83 eb 01             	sub    $0x1,%ebx
  800664:	75 ee                	jne    800654 <vprintfmt+0x280>
  800666:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800669:	e9 8f fd ff ff       	jmp    8003fd <vprintfmt+0x29>
	if (lflag >= 2)
  80066e:	83 fa 01             	cmp    $0x1,%edx
  800671:	7e 16                	jle    800689 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8d 50 08             	lea    0x8(%eax),%edx
  800679:	89 55 14             	mov    %edx,0x14(%ebp)
  80067c:	8b 50 04             	mov    0x4(%eax),%edx
  80067f:	8b 00                	mov    (%eax),%eax
  800681:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800684:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800687:	eb 32                	jmp    8006bb <vprintfmt+0x2e7>
	else if (lflag)
  800689:	85 d2                	test   %edx,%edx
  80068b:	74 18                	je     8006a5 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 50 04             	lea    0x4(%eax),%edx
  800693:	89 55 14             	mov    %edx,0x14(%ebp)
  800696:	8b 30                	mov    (%eax),%esi
  800698:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80069b:	89 f0                	mov    %esi,%eax
  80069d:	c1 f8 1f             	sar    $0x1f,%eax
  8006a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006a3:	eb 16                	jmp    8006bb <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8d 50 04             	lea    0x4(%eax),%edx
  8006ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ae:	8b 30                	mov    (%eax),%esi
  8006b0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006b3:	89 f0                	mov    %esi,%eax
  8006b5:	c1 f8 1f             	sar    $0x1f,%eax
  8006b8:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  8006bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006be:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  8006c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8006c6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ca:	0f 89 80 00 00 00    	jns    800750 <vprintfmt+0x37c>
				putch('-', putdat);
  8006d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006db:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006e4:	f7 d8                	neg    %eax
  8006e6:	83 d2 00             	adc    $0x0,%edx
  8006e9:	f7 da                	neg    %edx
			base = 10;
  8006eb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f0:	eb 5e                	jmp    800750 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8006f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f5:	e8 5b fc ff ff       	call   800355 <getuint>
			base = 10;
  8006fa:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006ff:	eb 4f                	jmp    800750 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800701:	8d 45 14             	lea    0x14(%ebp),%eax
  800704:	e8 4c fc ff ff       	call   800355 <getuint>
			base = 8;
  800709:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80070e:	eb 40                	jmp    800750 <vprintfmt+0x37c>
			putch('0', putdat);
  800710:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800714:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80071b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80071e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800722:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800729:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 50 04             	lea    0x4(%eax),%edx
  800732:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800735:	8b 00                	mov    (%eax),%eax
  800737:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80073c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800741:	eb 0d                	jmp    800750 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800743:	8d 45 14             	lea    0x14(%ebp),%eax
  800746:	e8 0a fc ff ff       	call   800355 <getuint>
			base = 16;
  80074b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800750:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800754:	89 74 24 10          	mov    %esi,0x10(%esp)
  800758:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80075b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80075f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800763:	89 04 24             	mov    %eax,(%esp)
  800766:	89 54 24 04          	mov    %edx,0x4(%esp)
  80076a:	89 fa                	mov    %edi,%edx
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	e8 ec fa ff ff       	call   800260 <printnum>
			break;
  800774:	e9 84 fc ff ff       	jmp    8003fd <vprintfmt+0x29>
			putch(ch, putdat);
  800779:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077d:	89 0c 24             	mov    %ecx,(%esp)
  800780:	ff 55 08             	call   *0x8(%ebp)
			break;
  800783:	e9 75 fc ff ff       	jmp    8003fd <vprintfmt+0x29>
			putch('%', putdat);
  800788:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800793:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800796:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80079a:	0f 84 5b fc ff ff    	je     8003fb <vprintfmt+0x27>
  8007a0:	89 f3                	mov    %esi,%ebx
  8007a2:	83 eb 01             	sub    $0x1,%ebx
  8007a5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007a9:	75 f7                	jne    8007a2 <vprintfmt+0x3ce>
  8007ab:	e9 4d fc ff ff       	jmp    8003fd <vprintfmt+0x29>
}
  8007b0:	83 c4 3c             	add    $0x3c,%esp
  8007b3:	5b                   	pop    %ebx
  8007b4:	5e                   	pop    %esi
  8007b5:	5f                   	pop    %edi
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	83 ec 28             	sub    $0x28,%esp
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007cb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d5:	85 c0                	test   %eax,%eax
  8007d7:	74 30                	je     800809 <vsnprintf+0x51>
  8007d9:	85 d2                	test   %edx,%edx
  8007db:	7e 2c                	jle    800809 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007eb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f2:	c7 04 24 8f 03 80 00 	movl   $0x80038f,(%esp)
  8007f9:	e8 d6 fb ff ff       	call   8003d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800801:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800804:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800807:	eb 05                	jmp    80080e <vsnprintf+0x56>
		return -E_INVAL;
  800809:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80080e:	c9                   	leave  
  80080f:	c3                   	ret    

00800810 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800816:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800819:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081d:	8b 45 10             	mov    0x10(%ebp),%eax
  800820:	89 44 24 08          	mov    %eax,0x8(%esp)
  800824:	8b 45 0c             	mov    0xc(%ebp),%eax
  800827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	89 04 24             	mov    %eax,(%esp)
  800831:	e8 82 ff ff ff       	call   8007b8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800836:	c9                   	leave  
  800837:	c3                   	ret    
  800838:	66 90                	xchg   %ax,%ax
  80083a:	66 90                	xchg   %ax,%ax
  80083c:	66 90                	xchg   %ax,%ax
  80083e:	66 90                	xchg   %ax,%ax

00800840 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800846:	80 3a 00             	cmpb   $0x0,(%edx)
  800849:	74 10                	je     80085b <strlen+0x1b>
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800850:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800853:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800857:	75 f7                	jne    800850 <strlen+0x10>
  800859:	eb 05                	jmp    800860 <strlen+0x20>
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800869:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086c:	85 c9                	test   %ecx,%ecx
  80086e:	74 1c                	je     80088c <strnlen+0x2a>
  800870:	80 3b 00             	cmpb   $0x0,(%ebx)
  800873:	74 1e                	je     800893 <strnlen+0x31>
  800875:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80087a:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	39 ca                	cmp    %ecx,%edx
  80087e:	74 18                	je     800898 <strnlen+0x36>
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800888:	75 f0                	jne    80087a <strnlen+0x18>
  80088a:	eb 0c                	jmp    800898 <strnlen+0x36>
  80088c:	b8 00 00 00 00       	mov    $0x0,%eax
  800891:	eb 05                	jmp    800898 <strnlen+0x36>
  800893:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800898:	5b                   	pop    %ebx
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a5:	89 c2                	mov    %eax,%edx
  8008a7:	83 c2 01             	add    $0x1,%edx
  8008aa:	83 c1 01             	add    $0x1,%ecx
  8008ad:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008b1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b4:	84 db                	test   %bl,%bl
  8008b6:	75 ef                	jne    8008a7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b8:	5b                   	pop    %ebx
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	83 ec 08             	sub    $0x8,%esp
  8008c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c5:	89 1c 24             	mov    %ebx,(%esp)
  8008c8:	e8 73 ff ff ff       	call   800840 <strlen>
	strcpy(dst + len, src);
  8008cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d4:	01 d8                	add    %ebx,%eax
  8008d6:	89 04 24             	mov    %eax,(%esp)
  8008d9:	e8 bd ff ff ff       	call   80089b <strcpy>
	return dst;
}
  8008de:	89 d8                	mov    %ebx,%eax
  8008e0:	83 c4 08             	add    $0x8,%esp
  8008e3:	5b                   	pop    %ebx
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	56                   	push   %esi
  8008ea:	53                   	push   %ebx
  8008eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f4:	85 db                	test   %ebx,%ebx
  8008f6:	74 17                	je     80090f <strncpy+0x29>
  8008f8:	01 f3                	add    %esi,%ebx
  8008fa:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8008fc:	83 c1 01             	add    $0x1,%ecx
  8008ff:	0f b6 02             	movzbl (%edx),%eax
  800902:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800905:	80 3a 01             	cmpb   $0x1,(%edx)
  800908:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80090b:	39 d9                	cmp    %ebx,%ecx
  80090d:	75 ed                	jne    8008fc <strncpy+0x16>
	}
	return ret;
}
  80090f:	89 f0                	mov    %esi,%eax
  800911:	5b                   	pop    %ebx
  800912:	5e                   	pop    %esi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800921:	8b 75 10             	mov    0x10(%ebp),%esi
  800924:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800926:	85 f6                	test   %esi,%esi
  800928:	74 34                	je     80095e <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  80092a:	83 fe 01             	cmp    $0x1,%esi
  80092d:	74 26                	je     800955 <strlcpy+0x40>
  80092f:	0f b6 0b             	movzbl (%ebx),%ecx
  800932:	84 c9                	test   %cl,%cl
  800934:	74 23                	je     800959 <strlcpy+0x44>
  800936:	83 ee 02             	sub    $0x2,%esi
  800939:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  80093e:	83 c0 01             	add    $0x1,%eax
  800941:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800944:	39 f2                	cmp    %esi,%edx
  800946:	74 13                	je     80095b <strlcpy+0x46>
  800948:	83 c2 01             	add    $0x1,%edx
  80094b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80094f:	84 c9                	test   %cl,%cl
  800951:	75 eb                	jne    80093e <strlcpy+0x29>
  800953:	eb 06                	jmp    80095b <strlcpy+0x46>
  800955:	89 f8                	mov    %edi,%eax
  800957:	eb 02                	jmp    80095b <strlcpy+0x46>
  800959:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  80095b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80095e:	29 f8                	sub    %edi,%eax
}
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5f                   	pop    %edi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80096e:	0f b6 01             	movzbl (%ecx),%eax
  800971:	84 c0                	test   %al,%al
  800973:	74 15                	je     80098a <strcmp+0x25>
  800975:	3a 02                	cmp    (%edx),%al
  800977:	75 11                	jne    80098a <strcmp+0x25>
		p++, q++;
  800979:	83 c1 01             	add    $0x1,%ecx
  80097c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80097f:	0f b6 01             	movzbl (%ecx),%eax
  800982:	84 c0                	test   %al,%al
  800984:	74 04                	je     80098a <strcmp+0x25>
  800986:	3a 02                	cmp    (%edx),%al
  800988:	74 ef                	je     800979 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80098a:	0f b6 c0             	movzbl %al,%eax
  80098d:	0f b6 12             	movzbl (%edx),%edx
  800990:	29 d0                	sub    %edx,%eax
}
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009a2:	85 f6                	test   %esi,%esi
  8009a4:	74 29                	je     8009cf <strncmp+0x3b>
  8009a6:	0f b6 03             	movzbl (%ebx),%eax
  8009a9:	84 c0                	test   %al,%al
  8009ab:	74 30                	je     8009dd <strncmp+0x49>
  8009ad:	3a 02                	cmp    (%edx),%al
  8009af:	75 2c                	jne    8009dd <strncmp+0x49>
  8009b1:	8d 43 01             	lea    0x1(%ebx),%eax
  8009b4:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8009b6:	89 c3                	mov    %eax,%ebx
  8009b8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009bb:	39 f0                	cmp    %esi,%eax
  8009bd:	74 17                	je     8009d6 <strncmp+0x42>
  8009bf:	0f b6 08             	movzbl (%eax),%ecx
  8009c2:	84 c9                	test   %cl,%cl
  8009c4:	74 17                	je     8009dd <strncmp+0x49>
  8009c6:	83 c0 01             	add    $0x1,%eax
  8009c9:	3a 0a                	cmp    (%edx),%cl
  8009cb:	74 e9                	je     8009b6 <strncmp+0x22>
  8009cd:	eb 0e                	jmp    8009dd <strncmp+0x49>
	if (n == 0)
		return 0;
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d4:	eb 0f                	jmp    8009e5 <strncmp+0x51>
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009db:	eb 08                	jmp    8009e5 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009dd:	0f b6 03             	movzbl (%ebx),%eax
  8009e0:	0f b6 12             	movzbl (%edx),%edx
  8009e3:	29 d0                	sub    %edx,%eax
}
  8009e5:	5b                   	pop    %ebx
  8009e6:	5e                   	pop    %esi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	53                   	push   %ebx
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009f3:	0f b6 18             	movzbl (%eax),%ebx
  8009f6:	84 db                	test   %bl,%bl
  8009f8:	74 1d                	je     800a17 <strchr+0x2e>
  8009fa:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009fc:	38 d3                	cmp    %dl,%bl
  8009fe:	75 06                	jne    800a06 <strchr+0x1d>
  800a00:	eb 1a                	jmp    800a1c <strchr+0x33>
  800a02:	38 ca                	cmp    %cl,%dl
  800a04:	74 16                	je     800a1c <strchr+0x33>
	for (; *s; s++)
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	0f b6 10             	movzbl (%eax),%edx
  800a0c:	84 d2                	test   %dl,%dl
  800a0e:	75 f2                	jne    800a02 <strchr+0x19>
			return (char *) s;
	return 0;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
  800a15:	eb 05                	jmp    800a1c <strchr+0x33>
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	53                   	push   %ebx
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a29:	0f b6 18             	movzbl (%eax),%ebx
  800a2c:	84 db                	test   %bl,%bl
  800a2e:	74 16                	je     800a46 <strfind+0x27>
  800a30:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a32:	38 d3                	cmp    %dl,%bl
  800a34:	75 06                	jne    800a3c <strfind+0x1d>
  800a36:	eb 0e                	jmp    800a46 <strfind+0x27>
  800a38:	38 ca                	cmp    %cl,%dl
  800a3a:	74 0a                	je     800a46 <strfind+0x27>
	for (; *s; s++)
  800a3c:	83 c0 01             	add    $0x1,%eax
  800a3f:	0f b6 10             	movzbl (%eax),%edx
  800a42:	84 d2                	test   %dl,%dl
  800a44:	75 f2                	jne    800a38 <strfind+0x19>
			break;
	return (char *) s;
}
  800a46:	5b                   	pop    %ebx
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
  800a4f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a55:	85 c9                	test   %ecx,%ecx
  800a57:	74 36                	je     800a8f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a59:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5f:	75 28                	jne    800a89 <memset+0x40>
  800a61:	f6 c1 03             	test   $0x3,%cl
  800a64:	75 23                	jne    800a89 <memset+0x40>
		c &= 0xFF;
  800a66:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a6a:	89 d3                	mov    %edx,%ebx
  800a6c:	c1 e3 08             	shl    $0x8,%ebx
  800a6f:	89 d6                	mov    %edx,%esi
  800a71:	c1 e6 18             	shl    $0x18,%esi
  800a74:	89 d0                	mov    %edx,%eax
  800a76:	c1 e0 10             	shl    $0x10,%eax
  800a79:	09 f0                	or     %esi,%eax
  800a7b:	09 c2                	or     %eax,%edx
  800a7d:	89 d0                	mov    %edx,%eax
  800a7f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a81:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a84:	fc                   	cld    
  800a85:	f3 ab                	rep stos %eax,%es:(%edi)
  800a87:	eb 06                	jmp    800a8f <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8c:	fc                   	cld    
  800a8d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8f:	89 f8                	mov    %edi,%eax
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5f                   	pop    %edi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	57                   	push   %edi
  800a9a:	56                   	push   %esi
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa4:	39 c6                	cmp    %eax,%esi
  800aa6:	73 35                	jae    800add <memmove+0x47>
  800aa8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aab:	39 d0                	cmp    %edx,%eax
  800aad:	73 2e                	jae    800add <memmove+0x47>
		s += n;
		d += n;
  800aaf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ab2:	89 d6                	mov    %edx,%esi
  800ab4:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800abc:	75 13                	jne    800ad1 <memmove+0x3b>
  800abe:	f6 c1 03             	test   $0x3,%cl
  800ac1:	75 0e                	jne    800ad1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac3:	83 ef 04             	sub    $0x4,%edi
  800ac6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800acc:	fd                   	std    
  800acd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acf:	eb 09                	jmp    800ada <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ad1:	83 ef 01             	sub    $0x1,%edi
  800ad4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ad7:	fd                   	std    
  800ad8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ada:	fc                   	cld    
  800adb:	eb 1d                	jmp    800afa <memmove+0x64>
  800add:	89 f2                	mov    %esi,%edx
  800adf:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae1:	f6 c2 03             	test   $0x3,%dl
  800ae4:	75 0f                	jne    800af5 <memmove+0x5f>
  800ae6:	f6 c1 03             	test   $0x3,%cl
  800ae9:	75 0a                	jne    800af5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aeb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aee:	89 c7                	mov    %eax,%edi
  800af0:	fc                   	cld    
  800af1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af3:	eb 05                	jmp    800afa <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800af5:	89 c7                	mov    %eax,%edi
  800af7:	fc                   	cld    
  800af8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b04:	8b 45 10             	mov    0x10(%ebp),%eax
  800b07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	89 04 24             	mov    %eax,(%esp)
  800b18:	e8 79 ff ff ff       	call   800a96 <memmove>
}
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b31:	85 c0                	test   %eax,%eax
  800b33:	74 36                	je     800b6b <memcmp+0x4c>
		if (*s1 != *s2)
  800b35:	0f b6 03             	movzbl (%ebx),%eax
  800b38:	0f b6 0e             	movzbl (%esi),%ecx
  800b3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b40:	38 c8                	cmp    %cl,%al
  800b42:	74 1c                	je     800b60 <memcmp+0x41>
  800b44:	eb 10                	jmp    800b56 <memcmp+0x37>
  800b46:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b4b:	83 c2 01             	add    $0x1,%edx
  800b4e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b52:	38 c8                	cmp    %cl,%al
  800b54:	74 0a                	je     800b60 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b56:	0f b6 c0             	movzbl %al,%eax
  800b59:	0f b6 c9             	movzbl %cl,%ecx
  800b5c:	29 c8                	sub    %ecx,%eax
  800b5e:	eb 10                	jmp    800b70 <memcmp+0x51>
	while (n-- > 0) {
  800b60:	39 fa                	cmp    %edi,%edx
  800b62:	75 e2                	jne    800b46 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800b64:	b8 00 00 00 00       	mov    $0x0,%eax
  800b69:	eb 05                	jmp    800b70 <memcmp+0x51>
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	53                   	push   %ebx
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b7f:	89 c2                	mov    %eax,%edx
  800b81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b84:	39 d0                	cmp    %edx,%eax
  800b86:	73 13                	jae    800b9b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b88:	89 d9                	mov    %ebx,%ecx
  800b8a:	38 18                	cmp    %bl,(%eax)
  800b8c:	75 06                	jne    800b94 <memfind+0x1f>
  800b8e:	eb 0b                	jmp    800b9b <memfind+0x26>
  800b90:	38 08                	cmp    %cl,(%eax)
  800b92:	74 07                	je     800b9b <memfind+0x26>
	for (; s < ends; s++)
  800b94:	83 c0 01             	add    $0x1,%eax
  800b97:	39 d0                	cmp    %edx,%eax
  800b99:	75 f5                	jne    800b90 <memfind+0x1b>
			break;
	return (void *) s;
}
  800b9b:	5b                   	pop    %ebx
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba7:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800baa:	0f b6 0a             	movzbl (%edx),%ecx
  800bad:	80 f9 09             	cmp    $0x9,%cl
  800bb0:	74 05                	je     800bb7 <strtol+0x19>
  800bb2:	80 f9 20             	cmp    $0x20,%cl
  800bb5:	75 10                	jne    800bc7 <strtol+0x29>
		s++;
  800bb7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800bba:	0f b6 0a             	movzbl (%edx),%ecx
  800bbd:	80 f9 09             	cmp    $0x9,%cl
  800bc0:	74 f5                	je     800bb7 <strtol+0x19>
  800bc2:	80 f9 20             	cmp    $0x20,%cl
  800bc5:	74 f0                	je     800bb7 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800bc7:	80 f9 2b             	cmp    $0x2b,%cl
  800bca:	75 0a                	jne    800bd6 <strtol+0x38>
		s++;
  800bcc:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800bcf:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd4:	eb 11                	jmp    800be7 <strtol+0x49>
  800bd6:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800bdb:	80 f9 2d             	cmp    $0x2d,%cl
  800bde:	75 07                	jne    800be7 <strtol+0x49>
		s++, neg = 1;
  800be0:	83 c2 01             	add    $0x1,%edx
  800be3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be7:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800bec:	75 15                	jne    800c03 <strtol+0x65>
  800bee:	80 3a 30             	cmpb   $0x30,(%edx)
  800bf1:	75 10                	jne    800c03 <strtol+0x65>
  800bf3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bf7:	75 0a                	jne    800c03 <strtol+0x65>
		s += 2, base = 16;
  800bf9:	83 c2 02             	add    $0x2,%edx
  800bfc:	b8 10 00 00 00       	mov    $0x10,%eax
  800c01:	eb 10                	jmp    800c13 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800c03:	85 c0                	test   %eax,%eax
  800c05:	75 0c                	jne    800c13 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c07:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800c09:	80 3a 30             	cmpb   $0x30,(%edx)
  800c0c:	75 05                	jne    800c13 <strtol+0x75>
		s++, base = 8;
  800c0e:	83 c2 01             	add    $0x1,%edx
  800c11:	b0 08                	mov    $0x8,%al
		base = 10;
  800c13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c18:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c1b:	0f b6 0a             	movzbl (%edx),%ecx
  800c1e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c21:	89 f0                	mov    %esi,%eax
  800c23:	3c 09                	cmp    $0x9,%al
  800c25:	77 08                	ja     800c2f <strtol+0x91>
			dig = *s - '0';
  800c27:	0f be c9             	movsbl %cl,%ecx
  800c2a:	83 e9 30             	sub    $0x30,%ecx
  800c2d:	eb 20                	jmp    800c4f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800c2f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c32:	89 f0                	mov    %esi,%eax
  800c34:	3c 19                	cmp    $0x19,%al
  800c36:	77 08                	ja     800c40 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c38:	0f be c9             	movsbl %cl,%ecx
  800c3b:	83 e9 57             	sub    $0x57,%ecx
  800c3e:	eb 0f                	jmp    800c4f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800c40:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c43:	89 f0                	mov    %esi,%eax
  800c45:	3c 19                	cmp    $0x19,%al
  800c47:	77 16                	ja     800c5f <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c49:	0f be c9             	movsbl %cl,%ecx
  800c4c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c4f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c52:	7d 0f                	jge    800c63 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c54:	83 c2 01             	add    $0x1,%edx
  800c57:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c5b:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c5d:	eb bc                	jmp    800c1b <strtol+0x7d>
  800c5f:	89 d8                	mov    %ebx,%eax
  800c61:	eb 02                	jmp    800c65 <strtol+0xc7>
  800c63:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c65:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c69:	74 05                	je     800c70 <strtol+0xd2>
		*endptr = (char *) s;
  800c6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c70:	f7 d8                	neg    %eax
  800c72:	85 ff                	test   %edi,%edi
  800c74:	0f 44 c3             	cmove  %ebx,%eax
}
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c82:	b8 00 00 00 00       	mov    $0x0,%eax
  800c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8d:	89 c3                	mov    %eax,%ebx
  800c8f:	89 c7                	mov    %eax,%edi
  800c91:	89 c6                	mov    %eax,%esi
  800c93:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ca0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca5:	b8 01 00 00 00       	mov    $0x1,%eax
  800caa:	89 d1                	mov    %edx,%ecx
  800cac:	89 d3                	mov    %edx,%ebx
  800cae:	89 d7                	mov    %edx,%edi
  800cb0:	89 d6                	mov    %edx,%esi
  800cb2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
  800cbf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cc2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc7:	b8 03 00 00 00       	mov    $0x3,%eax
  800ccc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccf:	89 cb                	mov    %ecx,%ebx
  800cd1:	89 cf                	mov    %ecx,%edi
  800cd3:	89 ce                	mov    %ecx,%esi
  800cd5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	7e 28                	jle    800d03 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ce6:	00 
  800ce7:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  800cee:	00 
  800cef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf6:	00 
  800cf7:	c7 04 24 21 1a 80 00 	movl   $0x801a21,(%esp)
  800cfe:	e8 bd 06 00 00       	call   8013c0 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d03:	83 c4 2c             	add    $0x2c,%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d11:	ba 00 00 00 00       	mov    $0x0,%edx
  800d16:	b8 02 00 00 00       	mov    $0x2,%eax
  800d1b:	89 d1                	mov    %edx,%ecx
  800d1d:	89 d3                	mov    %edx,%ebx
  800d1f:	89 d7                	mov    %edx,%edi
  800d21:	89 d6                	mov    %edx,%esi
  800d23:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_yield>:

void
sys_yield(void)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d30:	ba 00 00 00 00       	mov    $0x0,%edx
  800d35:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d3a:	89 d1                	mov    %edx,%ecx
  800d3c:	89 d3                	mov    %edx,%ebx
  800d3e:	89 d7                	mov    %edx,%edi
  800d40:	89 d6                	mov    %edx,%esi
  800d42:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
  800d4f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d52:	be 00 00 00 00       	mov    $0x0,%esi
  800d57:	b8 04 00 00 00       	mov    $0x4,%eax
  800d5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d65:	89 f7                	mov    %esi,%edi
  800d67:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 28                	jle    800d95 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d71:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d78:	00 
  800d79:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  800d80:	00 
  800d81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d88:	00 
  800d89:	c7 04 24 21 1a 80 00 	movl   $0x801a21,(%esp)
  800d90:	e8 2b 06 00 00       	call   8013c0 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d95:	83 c4 2c             	add    $0x2c,%esp
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800da6:	b8 05 00 00 00       	mov    $0x5,%eax
  800dab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db7:	8b 75 18             	mov    0x18(%ebp),%esi
  800dba:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	7e 28                	jle    800de8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dcb:	00 
  800dcc:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  800dd3:	00 
  800dd4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddb:	00 
  800ddc:	c7 04 24 21 1a 80 00 	movl   $0x801a21,(%esp)
  800de3:	e8 d8 05 00 00       	call   8013c0 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800de8:	83 c4 2c             	add    $0x2c,%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
  800df6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800df9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfe:	b8 06 00 00 00       	mov    $0x6,%eax
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	89 df                	mov    %ebx,%edi
  800e0b:	89 de                	mov    %ebx,%esi
  800e0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7e 28                	jle    800e3b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e17:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e1e:	00 
  800e1f:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  800e26:	00 
  800e27:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2e:	00 
  800e2f:	c7 04 24 21 1a 80 00 	movl   $0x801a21,(%esp)
  800e36:	e8 85 05 00 00       	call   8013c0 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e3b:	83 c4 2c             	add    $0x2c,%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e51:	b8 08 00 00 00       	mov    $0x8,%eax
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	89 df                	mov    %ebx,%edi
  800e5e:	89 de                	mov    %ebx,%esi
  800e60:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e62:	85 c0                	test   %eax,%eax
  800e64:	7e 28                	jle    800e8e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e66:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e71:	00 
  800e72:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  800e79:	00 
  800e7a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e81:	00 
  800e82:	c7 04 24 21 1a 80 00 	movl   $0x801a21,(%esp)
  800e89:	e8 32 05 00 00       	call   8013c0 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e8e:	83 c4 2c             	add    $0x2c,%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	89 df                	mov    %ebx,%edi
  800eb1:	89 de                	mov    %ebx,%esi
  800eb3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	7e 28                	jle    800ee1 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  800ecc:	00 
  800ecd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed4:	00 
  800ed5:	c7 04 24 21 1a 80 00 	movl   $0x801a21,(%esp)
  800edc:	e8 df 04 00 00       	call   8013c0 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ee1:	83 c4 2c             	add    $0x2c,%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	57                   	push   %edi
  800eed:	56                   	push   %esi
  800eee:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eef:	be 00 00 00 00       	mov    $0x0,%esi
  800ef4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ef9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efc:	8b 55 08             	mov    0x8(%ebp),%edx
  800eff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f05:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5f                   	pop    %edi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	57                   	push   %edi
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
  800f12:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f22:	89 cb                	mov    %ecx,%ebx
  800f24:	89 cf                	mov    %ecx,%edi
  800f26:	89 ce                	mov    %ecx,%esi
  800f28:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	7e 28                	jle    800f56 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f32:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f39:	00 
  800f3a:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  800f41:	00 
  800f42:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f49:	00 
  800f4a:	c7 04 24 21 1a 80 00 	movl   $0x801a21,(%esp)
  800f51:	e8 6a 04 00 00       	call   8013c0 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f56:	83 c4 2c             	add    $0x2c,%esp
  800f59:	5b                   	pop    %ebx
  800f5a:	5e                   	pop    %esi
  800f5b:	5f                   	pop    %edi
  800f5c:	5d                   	pop    %ebp
  800f5d:	c3                   	ret    

00800f5e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	53                   	push   %ebx
  800f62:	83 ec 24             	sub    $0x24,%esp
  800f65:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f68:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800f6a:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f6e:	74 2e                	je     800f9e <pgfault+0x40>
  800f70:	89 c2                	mov    %eax,%edx
  800f72:	c1 ea 16             	shr    $0x16,%edx
  800f75:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f7c:	f6 c2 01             	test   $0x1,%dl
  800f7f:	74 1d                	je     800f9e <pgfault+0x40>
  800f81:	89 c2                	mov    %eax,%edx
  800f83:	c1 ea 0c             	shr    $0xc,%edx
  800f86:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f8d:	f6 c1 01             	test   $0x1,%cl
  800f90:	74 0c                	je     800f9e <pgfault+0x40>
  800f92:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f99:	f6 c6 08             	test   $0x8,%dh
  800f9c:	75 20                	jne    800fbe <pgfault+0x60>
		panic("pgfault: page cow check failed, addr=%x\n", addr);
  800f9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fa2:	c7 44 24 08 30 1a 80 	movl   $0x801a30,0x8(%esp)
  800fa9:	00 
  800faa:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800fb1:	00 
  800fb2:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  800fb9:	e8 02 04 00 00       	call   8013c0 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800fbe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fc3:	89 c3                	mov    %eax,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W))
  800fc5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fcc:	00 
  800fcd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fd4:	00 
  800fd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fdc:	e8 68 fd ff ff       	call   800d49 <sys_page_alloc>
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	74 1c                	je     801001 <pgfault+0xa3>
		panic("pgfault: sys_page_alloc error");
  800fe5:	c7 44 24 08 fa 1a 80 	movl   $0x801afa,0x8(%esp)
  800fec:	00 
  800fed:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800ff4:	00 
  800ff5:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  800ffc:	e8 bf 03 00 00       	call   8013c0 <_panic>

	memmove(PFTEMP, addr, PGSIZE);
  801001:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801008:	00 
  801009:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80100d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801014:	e8 7d fa ff ff       	call   800a96 <memmove>
	if(sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))
  801019:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801020:	00 
  801021:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801025:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80102c:	00 
  80102d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801034:	00 
  801035:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80103c:	e8 5c fd ff ff       	call   800d9d <sys_page_map>
  801041:	85 c0                	test   %eax,%eax
  801043:	74 1c                	je     801061 <pgfault+0x103>
		panic("pgfault: sys_page_map error");
  801045:	c7 44 24 08 18 1b 80 	movl   $0x801b18,0x8(%esp)
  80104c:	00 
  80104d:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801054:	00 
  801055:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  80105c:	e8 5f 03 00 00       	call   8013c0 <_panic>

	if(sys_page_unmap(0, PFTEMP))
  801061:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801068:	00 
  801069:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801070:	e8 7b fd ff ff       	call   800df0 <sys_page_unmap>
  801075:	85 c0                	test   %eax,%eax
  801077:	74 1c                	je     801095 <pgfault+0x137>
		panic("pgfault: sys_page_unmap error");
  801079:	c7 44 24 08 34 1b 80 	movl   $0x801b34,0x8(%esp)
  801080:	00 
  801081:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801088:	00 
  801089:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  801090:	e8 2b 03 00 00       	call   8013c0 <_panic>
}
  801095:	83 c4 24             	add    $0x24,%esp
  801098:	5b                   	pop    %ebx
  801099:	5d                   	pop    %ebp
  80109a:	c3                   	ret    

0080109b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	57                   	push   %edi
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	//根据文档的描述，duppage好像不应该处理除了可写或者copy-on-write的部分，但这里都交给duppage一块处理了
	set_pgfault_handler(pgfault);
  8010a4:	c7 04 24 5e 0f 80 00 	movl   $0x800f5e,(%esp)
  8010ab:	e8 66 03 00 00       	call   801416 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010b0:	b8 07 00 00 00       	mov    $0x7,%eax
  8010b5:	cd 30                	int    $0x30
  8010b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();
	if(envid < 0)
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	79 1c                	jns    8010da <fork+0x3f>
		//失败
		panic("fork: sys_exofork error");
  8010be:	c7 44 24 08 52 1b 80 	movl   $0x801b52,0x8(%esp)
  8010c5:	00 
  8010c6:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  8010cd:	00 
  8010ce:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  8010d5:	e8 e6 02 00 00       	call   8013c0 <_panic>
  8010da:	89 c7                	mov    %eax,%edi
	else if(!envid)
  8010dc:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8010e1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010e5:	75 1c                	jne    801103 <fork+0x68>
		//子进程
		thisenv = &envs[ENVX(sys_getenvid())];
  8010e7:	e8 1f fc ff ff       	call   800d0b <sys_getenvid>
  8010ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010f9:	a3 08 20 80 00       	mov    %eax,0x802008
  8010fe:	e9 a4 01 00 00       	jmp    8012a7 <fork+0x20c>
	else{
		//父进程
		unsigned addr;
		for(addr = UTEXT; addr < USTACKTOP; addr+= PGSIZE){
			if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))
  801103:	89 d8                	mov    %ebx,%eax
  801105:	c1 e8 16             	shr    $0x16,%eax
  801108:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80110f:	a8 01                	test   $0x1,%al
  801111:	0f 84 00 01 00 00    	je     801217 <fork+0x17c>
  801117:	89 d8                	mov    %ebx,%eax
  801119:	c1 e8 0c             	shr    $0xc,%eax
  80111c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801123:	f6 c2 01             	test   $0x1,%dl
  801126:	0f 84 eb 00 00 00    	je     801217 <fork+0x17c>
  80112c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801133:	f6 c2 04             	test   $0x4,%dl
  801136:	0f 84 db 00 00 00    	je     801217 <fork+0x17c>
	void *addr = (void *)(pn * PGSIZE);
  80113c:	89 c6                	mov    %eax,%esi
  80113e:	c1 e6 0c             	shl    $0xc,%esi
	if(uvpt[pn] & (PTE_W | PTE_COW)){
  801141:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801148:	a9 02 08 00 00       	test   $0x802,%eax
  80114d:	0f 84 84 00 00 00    	je     8011d7 <fork+0x13c>
		if(sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P))
  801153:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80115a:	00 
  80115b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80115f:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801163:	89 74 24 04          	mov    %esi,0x4(%esp)
  801167:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116e:	e8 2a fc ff ff       	call   800d9d <sys_page_map>
  801173:	85 c0                	test   %eax,%eax
  801175:	74 1c                	je     801193 <fork+0xf8>
			panic("duppage: sys_page_map child error");
  801177:	c7 44 24 08 5c 1a 80 	movl   $0x801a5c,0x8(%esp)
  80117e:	00 
  80117f:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801186:	00 
  801187:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  80118e:	e8 2d 02 00 00       	call   8013c0 <_panic>
		if(sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P))
  801193:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80119a:	00 
  80119b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80119f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011a6:	00 
  8011a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b2:	e8 e6 fb ff ff       	call   800d9d <sys_page_map>
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	74 5c                	je     801217 <fork+0x17c>
			panic("duppage: sys_page_map remap parent error");
  8011bb:	c7 44 24 08 80 1a 80 	movl   $0x801a80,0x8(%esp)
  8011c2:	00 
  8011c3:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8011ca:	00 
  8011cb:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  8011d2:	e8 e9 01 00 00       	call   8013c0 <_panic>
		if(sys_page_map(0, addr, envid, addr, PTE_U|PTE_P))
  8011d7:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8011de:	00 
  8011df:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011e3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f2:	e8 a6 fb ff ff       	call   800d9d <sys_page_map>
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	74 1c                	je     801217 <fork+0x17c>
			panic("duppage: other sys_page_map error");
  8011fb:	c7 44 24 08 ac 1a 80 	movl   $0x801aac,0x8(%esp)
  801202:	00 
  801203:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  80120a:	00 
  80120b:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  801212:	e8 a9 01 00 00       	call   8013c0 <_panic>
		for(addr = UTEXT; addr < USTACKTOP; addr+= PGSIZE){
  801217:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80121d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801223:	0f 85 da fe ff ff    	jne    801103 <fork+0x68>
				duppage(envid, PGNUM(addr));
		}
		if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W))
  801229:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801230:	00 
  801231:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801238:	ee 
  801239:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80123c:	89 04 24             	mov    %eax,(%esp)
  80123f:	e8 05 fb ff ff       	call   800d49 <sys_page_alloc>
  801244:	85 c0                	test   %eax,%eax
  801246:	74 1c                	je     801264 <fork+0x1c9>
			panic("fork: sys_page_alloc error");
  801248:	c7 44 24 08 6a 1b 80 	movl   $0x801b6a,0x8(%esp)
  80124f:	00 
  801250:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  801257:	00 
  801258:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  80125f:	e8 5c 01 00 00       	call   8013c0 <_panic>
		extern void _pgfault_upcall();
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801264:	c7 44 24 04 9f 14 80 	movl   $0x80149f,0x4(%esp)
  80126b:	00 
  80126c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80126f:	89 3c 24             	mov    %edi,(%esp)
  801272:	e8 1f fc ff ff       	call   800e96 <sys_env_set_pgfault_upcall>
		if(sys_env_set_status(envid, ENV_RUNNABLE))
  801277:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80127e:	00 
  80127f:	89 3c 24             	mov    %edi,(%esp)
  801282:	e8 bc fb ff ff       	call   800e43 <sys_env_set_status>
  801287:	85 c0                	test   %eax,%eax
  801289:	74 1c                	je     8012a7 <fork+0x20c>
			panic("fork: sys_env_set_status error");
  80128b:	c7 44 24 08 d0 1a 80 	movl   $0x801ad0,0x8(%esp)
  801292:	00 
  801293:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  80129a:	00 
  80129b:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  8012a2:	e8 19 01 00 00       	call   8013c0 <_panic>
	}
	return envid;
}
  8012a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012aa:	83 c4 2c             	add    $0x2c,%esp
  8012ad:	5b                   	pop    %ebx
  8012ae:	5e                   	pop    %esi
  8012af:	5f                   	pop    %edi
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <sfork>:

// Challenge!
int
sfork(void)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012b8:	c7 44 24 08 85 1b 80 	movl   $0x801b85,0x8(%esp)
  8012bf:	00 
  8012c0:	c7 44 24 04 87 00 00 	movl   $0x87,0x4(%esp)
  8012c7:	00 
  8012c8:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  8012cf:	e8 ec 00 00 00       	call   8013c0 <_panic>

008012d4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
  8012d9:	83 ec 10             	sub    $0x10,%esp
  8012dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8012df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  8012e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e5:	89 04 24             	mov    %eax,(%esp)
  8012e8:	e8 1f fc ff ff       	call   800f0c <sys_ipc_recv>
	if(from_env_store)
  8012ed:	85 f6                	test   %esi,%esi
  8012ef:	74 14                	je     801305 <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  8012f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	78 09                	js     801303 <ipc_recv+0x2f>
  8012fa:	8b 15 08 20 80 00    	mov    0x802008,%edx
  801300:	8b 52 74             	mov    0x74(%edx),%edx
  801303:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  801305:	85 db                	test   %ebx,%ebx
  801307:	74 14                	je     80131d <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  801309:	ba 00 00 00 00       	mov    $0x0,%edx
  80130e:	85 c0                	test   %eax,%eax
  801310:	78 09                	js     80131b <ipc_recv+0x47>
  801312:	8b 15 08 20 80 00    	mov    0x802008,%edx
  801318:	8b 52 78             	mov    0x78(%edx),%edx
  80131b:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 08                	js     801329 <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  801321:	a1 08 20 80 00       	mov    0x802008,%eax
  801326:	8b 40 70             	mov    0x70(%eax),%eax
}
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	5b                   	pop    %ebx
  80132d:	5e                   	pop    %esi
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	57                   	push   %edi
  801334:	56                   	push   %esi
  801335:	53                   	push   %ebx
  801336:	83 ec 1c             	sub    $0x1c,%esp
  801339:	8b 7d 08             	mov    0x8(%ebp),%edi
  80133c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  80133f:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801344:	eb 0c                	jmp    801352 <ipc_send+0x22>
		failed_cnt++;
  801346:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  801349:	84 db                	test   %bl,%bl
  80134b:	75 05                	jne    801352 <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  80134d:	e8 d8 f9 ff ff       	call   800d2a <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801352:	8b 45 14             	mov    0x14(%ebp),%eax
  801355:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801359:	8b 45 10             	mov    0x10(%ebp),%eax
  80135c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801360:	89 74 24 04          	mov    %esi,0x4(%esp)
  801364:	89 3c 24             	mov    %edi,(%esp)
  801367:	e8 7d fb ff ff       	call   800ee9 <sys_ipc_try_send>
  80136c:	85 c0                	test   %eax,%eax
  80136e:	78 d6                	js     801346 <ipc_send+0x16>
	}
}
  801370:	83 c4 1c             	add    $0x1c,%esp
  801373:	5b                   	pop    %ebx
  801374:	5e                   	pop    %esi
  801375:	5f                   	pop    %edi
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    

00801378 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80137e:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801383:	39 c8                	cmp    %ecx,%eax
  801385:	74 17                	je     80139e <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  801387:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80138c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80138f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801395:	8b 52 50             	mov    0x50(%edx),%edx
  801398:	39 ca                	cmp    %ecx,%edx
  80139a:	75 14                	jne    8013b0 <ipc_find_env+0x38>
  80139c:	eb 05                	jmp    8013a3 <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  80139e:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  8013a3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013a6:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013ab:	8b 40 40             	mov    0x40(%eax),%eax
  8013ae:	eb 0e                	jmp    8013be <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  8013b0:	83 c0 01             	add    $0x1,%eax
  8013b3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013b8:	75 d2                	jne    80138c <ipc_find_env+0x14>
	return 0;
  8013ba:	66 b8 00 00          	mov    $0x0,%ax
}
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	56                   	push   %esi
  8013c4:	53                   	push   %ebx
  8013c5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8013c8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013cb:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8013d1:	e8 35 f9 ff ff       	call   800d0b <sys_getenvid>
  8013d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013e4:	89 74 24 08          	mov    %esi,0x8(%esp)
  8013e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ec:	c7 04 24 9c 1b 80 00 	movl   $0x801b9c,(%esp)
  8013f3:	e8 4e ee ff ff       	call   800246 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8013ff:	89 04 24             	mov    %eax,(%esp)
  801402:	e8 de ed ff ff       	call   8001e5 <vcprintf>
	cprintf("\n");
  801407:	c7 04 24 78 17 80 00 	movl   $0x801778,(%esp)
  80140e:	e8 33 ee ff ff       	call   800246 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801413:	cc                   	int3   
  801414:	eb fd                	jmp    801413 <_panic+0x53>

00801416 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80141c:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801423:	75 70                	jne    801495 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  801425:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80142c:	00 
  80142d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801434:	ee 
  801435:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80143c:	e8 08 f9 ff ff       	call   800d49 <sys_page_alloc>
  801441:	85 c0                	test   %eax,%eax
  801443:	79 1c                	jns    801461 <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  801445:	c7 44 24 08 c0 1b 80 	movl   $0x801bc0,0x8(%esp)
  80144c:	00 
  80144d:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801454:	00 
  801455:	c7 04 24 24 1c 80 00 	movl   $0x801c24,(%esp)
  80145c:	e8 5f ff ff ff       	call   8013c0 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801461:	c7 44 24 04 9f 14 80 	movl   $0x80149f,0x4(%esp)
  801468:	00 
  801469:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801470:	e8 21 fa ff ff       	call   800e96 <sys_env_set_pgfault_upcall>
  801475:	85 c0                	test   %eax,%eax
  801477:	79 1c                	jns    801495 <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  801479:	c7 44 24 08 ec 1b 80 	movl   $0x801bec,0x8(%esp)
  801480:	00 
  801481:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801488:	00 
  801489:	c7 04 24 24 1c 80 00 	movl   $0x801c24,(%esp)
  801490:	e8 2b ff ff ff       	call   8013c0 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801495:	8b 45 08             	mov    0x8(%ebp),%eax
  801498:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80149d:	c9                   	leave  
  80149e:	c3                   	ret    

0080149f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80149f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014a0:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8014a5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014a7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  8014aa:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  8014ae:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  8014b3:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  8014b7:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8014b9:	83 c4 08             	add    $0x8,%esp
	popal
  8014bc:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8014bd:	83 c4 04             	add    $0x4,%esp
	popfl
  8014c0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8014c1:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8014c2:	c3                   	ret    
  8014c3:	66 90                	xchg   %ax,%ax
  8014c5:	66 90                	xchg   %ax,%ax
  8014c7:	66 90                	xchg   %ax,%ax
  8014c9:	66 90                	xchg   %ax,%ax
  8014cb:	66 90                	xchg   %ax,%ax
  8014cd:	66 90                	xchg   %ax,%ax
  8014cf:	90                   	nop

008014d0 <__udivdi3>:
  8014d0:	55                   	push   %ebp
  8014d1:	57                   	push   %edi
  8014d2:	56                   	push   %esi
  8014d3:	83 ec 0c             	sub    $0xc,%esp
  8014d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014da:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8014de:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8014e2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014ec:	89 ea                	mov    %ebp,%edx
  8014ee:	89 0c 24             	mov    %ecx,(%esp)
  8014f1:	75 2d                	jne    801520 <__udivdi3+0x50>
  8014f3:	39 e9                	cmp    %ebp,%ecx
  8014f5:	77 61                	ja     801558 <__udivdi3+0x88>
  8014f7:	85 c9                	test   %ecx,%ecx
  8014f9:	89 ce                	mov    %ecx,%esi
  8014fb:	75 0b                	jne    801508 <__udivdi3+0x38>
  8014fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801502:	31 d2                	xor    %edx,%edx
  801504:	f7 f1                	div    %ecx
  801506:	89 c6                	mov    %eax,%esi
  801508:	31 d2                	xor    %edx,%edx
  80150a:	89 e8                	mov    %ebp,%eax
  80150c:	f7 f6                	div    %esi
  80150e:	89 c5                	mov    %eax,%ebp
  801510:	89 f8                	mov    %edi,%eax
  801512:	f7 f6                	div    %esi
  801514:	89 ea                	mov    %ebp,%edx
  801516:	83 c4 0c             	add    $0xc,%esp
  801519:	5e                   	pop    %esi
  80151a:	5f                   	pop    %edi
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    
  80151d:	8d 76 00             	lea    0x0(%esi),%esi
  801520:	39 e8                	cmp    %ebp,%eax
  801522:	77 24                	ja     801548 <__udivdi3+0x78>
  801524:	0f bd e8             	bsr    %eax,%ebp
  801527:	83 f5 1f             	xor    $0x1f,%ebp
  80152a:	75 3c                	jne    801568 <__udivdi3+0x98>
  80152c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801530:	39 34 24             	cmp    %esi,(%esp)
  801533:	0f 86 9f 00 00 00    	jbe    8015d8 <__udivdi3+0x108>
  801539:	39 d0                	cmp    %edx,%eax
  80153b:	0f 82 97 00 00 00    	jb     8015d8 <__udivdi3+0x108>
  801541:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801548:	31 d2                	xor    %edx,%edx
  80154a:	31 c0                	xor    %eax,%eax
  80154c:	83 c4 0c             	add    $0xc,%esp
  80154f:	5e                   	pop    %esi
  801550:	5f                   	pop    %edi
  801551:	5d                   	pop    %ebp
  801552:	c3                   	ret    
  801553:	90                   	nop
  801554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801558:	89 f8                	mov    %edi,%eax
  80155a:	f7 f1                	div    %ecx
  80155c:	31 d2                	xor    %edx,%edx
  80155e:	83 c4 0c             	add    $0xc,%esp
  801561:	5e                   	pop    %esi
  801562:	5f                   	pop    %edi
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    
  801565:	8d 76 00             	lea    0x0(%esi),%esi
  801568:	89 e9                	mov    %ebp,%ecx
  80156a:	8b 3c 24             	mov    (%esp),%edi
  80156d:	d3 e0                	shl    %cl,%eax
  80156f:	89 c6                	mov    %eax,%esi
  801571:	b8 20 00 00 00       	mov    $0x20,%eax
  801576:	29 e8                	sub    %ebp,%eax
  801578:	89 c1                	mov    %eax,%ecx
  80157a:	d3 ef                	shr    %cl,%edi
  80157c:	89 e9                	mov    %ebp,%ecx
  80157e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801582:	8b 3c 24             	mov    (%esp),%edi
  801585:	09 74 24 08          	or     %esi,0x8(%esp)
  801589:	89 d6                	mov    %edx,%esi
  80158b:	d3 e7                	shl    %cl,%edi
  80158d:	89 c1                	mov    %eax,%ecx
  80158f:	89 3c 24             	mov    %edi,(%esp)
  801592:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801596:	d3 ee                	shr    %cl,%esi
  801598:	89 e9                	mov    %ebp,%ecx
  80159a:	d3 e2                	shl    %cl,%edx
  80159c:	89 c1                	mov    %eax,%ecx
  80159e:	d3 ef                	shr    %cl,%edi
  8015a0:	09 d7                	or     %edx,%edi
  8015a2:	89 f2                	mov    %esi,%edx
  8015a4:	89 f8                	mov    %edi,%eax
  8015a6:	f7 74 24 08          	divl   0x8(%esp)
  8015aa:	89 d6                	mov    %edx,%esi
  8015ac:	89 c7                	mov    %eax,%edi
  8015ae:	f7 24 24             	mull   (%esp)
  8015b1:	39 d6                	cmp    %edx,%esi
  8015b3:	89 14 24             	mov    %edx,(%esp)
  8015b6:	72 30                	jb     8015e8 <__udivdi3+0x118>
  8015b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015bc:	89 e9                	mov    %ebp,%ecx
  8015be:	d3 e2                	shl    %cl,%edx
  8015c0:	39 c2                	cmp    %eax,%edx
  8015c2:	73 05                	jae    8015c9 <__udivdi3+0xf9>
  8015c4:	3b 34 24             	cmp    (%esp),%esi
  8015c7:	74 1f                	je     8015e8 <__udivdi3+0x118>
  8015c9:	89 f8                	mov    %edi,%eax
  8015cb:	31 d2                	xor    %edx,%edx
  8015cd:	e9 7a ff ff ff       	jmp    80154c <__udivdi3+0x7c>
  8015d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8015d8:	31 d2                	xor    %edx,%edx
  8015da:	b8 01 00 00 00       	mov    $0x1,%eax
  8015df:	e9 68 ff ff ff       	jmp    80154c <__udivdi3+0x7c>
  8015e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8015eb:	31 d2                	xor    %edx,%edx
  8015ed:	83 c4 0c             	add    $0xc,%esp
  8015f0:	5e                   	pop    %esi
  8015f1:	5f                   	pop    %edi
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    
  8015f4:	66 90                	xchg   %ax,%ax
  8015f6:	66 90                	xchg   %ax,%ax
  8015f8:	66 90                	xchg   %ax,%ax
  8015fa:	66 90                	xchg   %ax,%ax
  8015fc:	66 90                	xchg   %ax,%ax
  8015fe:	66 90                	xchg   %ax,%ax

00801600 <__umoddi3>:
  801600:	55                   	push   %ebp
  801601:	57                   	push   %edi
  801602:	56                   	push   %esi
  801603:	83 ec 14             	sub    $0x14,%esp
  801606:	8b 44 24 28          	mov    0x28(%esp),%eax
  80160a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80160e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801612:	89 c7                	mov    %eax,%edi
  801614:	89 44 24 04          	mov    %eax,0x4(%esp)
  801618:	8b 44 24 30          	mov    0x30(%esp),%eax
  80161c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801620:	89 34 24             	mov    %esi,(%esp)
  801623:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801627:	85 c0                	test   %eax,%eax
  801629:	89 c2                	mov    %eax,%edx
  80162b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80162f:	75 17                	jne    801648 <__umoddi3+0x48>
  801631:	39 fe                	cmp    %edi,%esi
  801633:	76 4b                	jbe    801680 <__umoddi3+0x80>
  801635:	89 c8                	mov    %ecx,%eax
  801637:	89 fa                	mov    %edi,%edx
  801639:	f7 f6                	div    %esi
  80163b:	89 d0                	mov    %edx,%eax
  80163d:	31 d2                	xor    %edx,%edx
  80163f:	83 c4 14             	add    $0x14,%esp
  801642:	5e                   	pop    %esi
  801643:	5f                   	pop    %edi
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    
  801646:	66 90                	xchg   %ax,%ax
  801648:	39 f8                	cmp    %edi,%eax
  80164a:	77 54                	ja     8016a0 <__umoddi3+0xa0>
  80164c:	0f bd e8             	bsr    %eax,%ebp
  80164f:	83 f5 1f             	xor    $0x1f,%ebp
  801652:	75 5c                	jne    8016b0 <__umoddi3+0xb0>
  801654:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801658:	39 3c 24             	cmp    %edi,(%esp)
  80165b:	0f 87 e7 00 00 00    	ja     801748 <__umoddi3+0x148>
  801661:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801665:	29 f1                	sub    %esi,%ecx
  801667:	19 c7                	sbb    %eax,%edi
  801669:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80166d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801671:	8b 44 24 08          	mov    0x8(%esp),%eax
  801675:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801679:	83 c4 14             	add    $0x14,%esp
  80167c:	5e                   	pop    %esi
  80167d:	5f                   	pop    %edi
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    
  801680:	85 f6                	test   %esi,%esi
  801682:	89 f5                	mov    %esi,%ebp
  801684:	75 0b                	jne    801691 <__umoddi3+0x91>
  801686:	b8 01 00 00 00       	mov    $0x1,%eax
  80168b:	31 d2                	xor    %edx,%edx
  80168d:	f7 f6                	div    %esi
  80168f:	89 c5                	mov    %eax,%ebp
  801691:	8b 44 24 04          	mov    0x4(%esp),%eax
  801695:	31 d2                	xor    %edx,%edx
  801697:	f7 f5                	div    %ebp
  801699:	89 c8                	mov    %ecx,%eax
  80169b:	f7 f5                	div    %ebp
  80169d:	eb 9c                	jmp    80163b <__umoddi3+0x3b>
  80169f:	90                   	nop
  8016a0:	89 c8                	mov    %ecx,%eax
  8016a2:	89 fa                	mov    %edi,%edx
  8016a4:	83 c4 14             	add    $0x14,%esp
  8016a7:	5e                   	pop    %esi
  8016a8:	5f                   	pop    %edi
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    
  8016ab:	90                   	nop
  8016ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016b0:	8b 04 24             	mov    (%esp),%eax
  8016b3:	be 20 00 00 00       	mov    $0x20,%esi
  8016b8:	89 e9                	mov    %ebp,%ecx
  8016ba:	29 ee                	sub    %ebp,%esi
  8016bc:	d3 e2                	shl    %cl,%edx
  8016be:	89 f1                	mov    %esi,%ecx
  8016c0:	d3 e8                	shr    %cl,%eax
  8016c2:	89 e9                	mov    %ebp,%ecx
  8016c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c8:	8b 04 24             	mov    (%esp),%eax
  8016cb:	09 54 24 04          	or     %edx,0x4(%esp)
  8016cf:	89 fa                	mov    %edi,%edx
  8016d1:	d3 e0                	shl    %cl,%eax
  8016d3:	89 f1                	mov    %esi,%ecx
  8016d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8016dd:	d3 ea                	shr    %cl,%edx
  8016df:	89 e9                	mov    %ebp,%ecx
  8016e1:	d3 e7                	shl    %cl,%edi
  8016e3:	89 f1                	mov    %esi,%ecx
  8016e5:	d3 e8                	shr    %cl,%eax
  8016e7:	89 e9                	mov    %ebp,%ecx
  8016e9:	09 f8                	or     %edi,%eax
  8016eb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8016ef:	f7 74 24 04          	divl   0x4(%esp)
  8016f3:	d3 e7                	shl    %cl,%edi
  8016f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8016f9:	89 d7                	mov    %edx,%edi
  8016fb:	f7 64 24 08          	mull   0x8(%esp)
  8016ff:	39 d7                	cmp    %edx,%edi
  801701:	89 c1                	mov    %eax,%ecx
  801703:	89 14 24             	mov    %edx,(%esp)
  801706:	72 2c                	jb     801734 <__umoddi3+0x134>
  801708:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80170c:	72 22                	jb     801730 <__umoddi3+0x130>
  80170e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801712:	29 c8                	sub    %ecx,%eax
  801714:	19 d7                	sbb    %edx,%edi
  801716:	89 e9                	mov    %ebp,%ecx
  801718:	89 fa                	mov    %edi,%edx
  80171a:	d3 e8                	shr    %cl,%eax
  80171c:	89 f1                	mov    %esi,%ecx
  80171e:	d3 e2                	shl    %cl,%edx
  801720:	89 e9                	mov    %ebp,%ecx
  801722:	d3 ef                	shr    %cl,%edi
  801724:	09 d0                	or     %edx,%eax
  801726:	89 fa                	mov    %edi,%edx
  801728:	83 c4 14             	add    $0x14,%esp
  80172b:	5e                   	pop    %esi
  80172c:	5f                   	pop    %edi
  80172d:	5d                   	pop    %ebp
  80172e:	c3                   	ret    
  80172f:	90                   	nop
  801730:	39 d7                	cmp    %edx,%edi
  801732:	75 da                	jne    80170e <__umoddi3+0x10e>
  801734:	8b 14 24             	mov    (%esp),%edx
  801737:	89 c1                	mov    %eax,%ecx
  801739:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80173d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801741:	eb cb                	jmp    80170e <__umoddi3+0x10e>
  801743:	90                   	nop
  801744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801748:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80174c:	0f 82 0f ff ff ff    	jb     801661 <__umoddi3+0x61>
  801752:	e9 1a ff ff ff       	jmp    801671 <__umoddi3+0x71>
