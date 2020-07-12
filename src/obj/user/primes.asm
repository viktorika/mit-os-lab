
obj/user/primes.debug：     文件格式 elf32-i386


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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800046:	00 
  800047:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004e:	00 
  80004f:	89 34 24             	mov    %esi,(%esp)
  800052:	e8 88 13 00 00       	call   8013df <ipc_recv>
  800057:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800059:	a1 04 40 80 00       	mov    0x804004,%eax
  80005e:	8b 40 5c             	mov    0x5c(%eax),%eax
  800061:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800065:	89 44 24 04          	mov    %eax,0x4(%esp)
  800069:	c7 04 24 00 26 80 00 	movl   $0x802600,(%esp)
  800070:	e8 2d 02 00 00       	call   8002a2 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800075:	e8 d4 10 00 00       	call   80114e <fork>
  80007a:	89 c7                	mov    %eax,%edi
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 20                	jns    8000a0 <primeproc+0x6d>
		panic("fork: %e", id);
  800080:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800084:	c7 44 24 08 0c 26 80 	movl   $0x80260c,0x8(%esp)
  80008b:	00 
  80008c:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800093:	00 
  800094:	c7 04 24 15 26 80 00 	movl   $0x802615,(%esp)
  80009b:	e8 09 01 00 00       	call   8001a9 <_panic>
	if (id == 0)
  8000a0:	85 c0                	test   %eax,%eax
  8000a2:	74 9b                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a4:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	89 34 24             	mov    %esi,(%esp)
  8000ba:	e8 20 13 00 00       	call   8013df <ipc_recv>
  8000bf:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c1:	99                   	cltd   
  8000c2:	f7 fb                	idiv   %ebx
  8000c4:	85 d2                	test   %edx,%edx
  8000c6:	74 df                	je     8000a7 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000cf:	00 
  8000d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d7:	00 
  8000d8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000dc:	89 3c 24             	mov    %edi,(%esp)
  8000df:	e8 57 13 00 00       	call   80143b <ipc_send>
  8000e4:	eb c1                	jmp    8000a7 <primeproc+0x74>

008000e6 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ee:	e8 5b 10 00 00       	call   80114e <fork>
  8000f3:	89 c6                	mov    %eax,%esi
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	79 20                	jns    800119 <umain+0x33>
		panic("fork: %e", id);
  8000f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fd:	c7 44 24 08 0c 26 80 	movl   $0x80260c,0x8(%esp)
  800104:	00 
  800105:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80010c:	00 
  80010d:	c7 04 24 15 26 80 00 	movl   $0x802615,(%esp)
  800114:	e8 90 00 00 00       	call   8001a9 <_panic>
	if (id == 0)
  800119:	bb 02 00 00 00       	mov    $0x2,%ebx
  80011e:	85 c0                	test   %eax,%eax
  800120:	75 05                	jne    800127 <umain+0x41>
		primeproc();
  800122:	e8 0c ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  800127:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80012e:	00 
  80012f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800136:	00 
  800137:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013b:	89 34 24             	mov    %esi,(%esp)
  80013e:	e8 f8 12 00 00       	call   80143b <ipc_send>
	for (i = 2; ; i++)
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	eb df                	jmp    800127 <umain+0x41>

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800153:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800156:	e8 10 0c 00 00       	call   800d6b <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800163:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800168:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016d:	85 db                	test   %ebx,%ebx
  80016f:	7e 07                	jle    800178 <libmain+0x30>
		binaryname = argv[0];
  800171:	8b 06                	mov    (%esi),%eax
  800173:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800178:	89 74 24 04          	mov    %esi,0x4(%esp)
  80017c:	89 1c 24             	mov    %ebx,(%esp)
  80017f:	e8 62 ff ff ff       	call   8000e6 <umain>

	// exit gracefully
	exit();
  800184:	e8 07 00 00 00       	call   800190 <exit>
}
  800189:	83 c4 10             	add    $0x10,%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800196:	e8 4b 15 00 00       	call   8016e6 <close_all>
	sys_env_destroy(0);
  80019b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a2:	e8 72 0b 00 00       	call   800d19 <sys_env_destroy>
}
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001b1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001ba:	e8 ac 0b 00 00       	call   800d6b <sys_getenvid>
  8001bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001cd:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d5:	c7 04 24 30 26 80 00 	movl   $0x802630,(%esp)
  8001dc:	e8 c1 00 00 00       	call   8002a2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 51 00 00 00       	call   800241 <vcprintf>
	cprintf("\n");
  8001f0:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  8001f7:	e8 a6 00 00 00       	call   8002a2 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001fc:	cc                   	int3   
  8001fd:	eb fd                	jmp    8001fc <_panic+0x53>

008001ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	53                   	push   %ebx
  800203:	83 ec 14             	sub    $0x14,%esp
  800206:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800209:	8b 13                	mov    (%ebx),%edx
  80020b:	8d 42 01             	lea    0x1(%edx),%eax
  80020e:	89 03                	mov    %eax,(%ebx)
  800210:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800213:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800217:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021c:	75 19                	jne    800237 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80021e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800225:	00 
  800226:	8d 43 08             	lea    0x8(%ebx),%eax
  800229:	89 04 24             	mov    %eax,(%esp)
  80022c:	e8 ab 0a 00 00       	call   800cdc <sys_cputs>
		b->idx = 0;
  800231:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800237:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80023b:	83 c4 14             	add    $0x14,%esp
  80023e:	5b                   	pop    %ebx
  80023f:	5d                   	pop    %ebp
  800240:	c3                   	ret    

00800241 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80024a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800251:	00 00 00 
	b.cnt = 0;
  800254:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800261:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800265:	8b 45 08             	mov    0x8(%ebp),%eax
  800268:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800272:	89 44 24 04          	mov    %eax,0x4(%esp)
  800276:	c7 04 24 ff 01 80 00 	movl   $0x8001ff,(%esp)
  80027d:	e8 b2 01 00 00       	call   800434 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800282:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800292:	89 04 24             	mov    %eax,(%esp)
  800295:	e8 42 0a 00 00       	call   800cdc <sys_cputs>

	return b.cnt;
}
  80029a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002a0:	c9                   	leave  
  8002a1:	c3                   	ret    

008002a2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002af:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b2:	89 04 24             	mov    %eax,(%esp)
  8002b5:	e8 87 ff ff ff       	call   800241 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    
  8002bc:	66 90                	xchg   %ax,%ax
  8002be:	66 90                	xchg   %ax,%ax

008002c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 3c             	sub    $0x3c,%esp
  8002c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cc:	89 d7                	mov    %edx,%edi
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002d7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8002da:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002e8:	39 f1                	cmp    %esi,%ecx
  8002ea:	72 14                	jb     800300 <printnum+0x40>
  8002ec:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002ef:	76 0f                	jbe    800300 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f4:	8d 70 ff             	lea    -0x1(%eax),%esi
  8002f7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002fa:	85 f6                	test   %esi,%esi
  8002fc:	7f 60                	jg     80035e <printnum+0x9e>
  8002fe:	eb 72                	jmp    800372 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800300:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800303:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800307:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80030a:	8d 51 ff             	lea    -0x1(%ecx),%edx
  80030d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800311:	89 44 24 08          	mov    %eax,0x8(%esp)
  800315:	8b 44 24 08          	mov    0x8(%esp),%eax
  800319:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80031d:	89 c3                	mov    %eax,%ebx
  80031f:	89 d6                	mov    %edx,%esi
  800321:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800324:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800327:	89 54 24 08          	mov    %edx,0x8(%esp)
  80032b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80032f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800332:	89 04 24             	mov    %eax,(%esp)
  800335:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800338:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033c:	e8 1f 20 00 00       	call   802360 <__udivdi3>
  800341:	89 d9                	mov    %ebx,%ecx
  800343:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800347:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80034b:	89 04 24             	mov    %eax,(%esp)
  80034e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800352:	89 fa                	mov    %edi,%edx
  800354:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800357:	e8 64 ff ff ff       	call   8002c0 <printnum>
  80035c:	eb 14                	jmp    800372 <printnum+0xb2>
			putch(padc, putdat);
  80035e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800362:	8b 45 18             	mov    0x18(%ebp),%eax
  800365:	89 04 24             	mov    %eax,(%esp)
  800368:	ff d3                	call   *%ebx
		while (--width > 0)
  80036a:	83 ee 01             	sub    $0x1,%esi
  80036d:	75 ef                	jne    80035e <printnum+0x9e>
  80036f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800372:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800376:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80037a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80037d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800380:	89 44 24 08          	mov    %eax,0x8(%esp)
  800384:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800388:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038b:	89 04 24             	mov    %eax,(%esp)
  80038e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800391:	89 44 24 04          	mov    %eax,0x4(%esp)
  800395:	e8 f6 20 00 00       	call   802490 <__umoddi3>
  80039a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80039e:	0f be 80 53 26 80 00 	movsbl 0x802653(%eax),%eax
  8003a5:	89 04 24             	mov    %eax,(%esp)
  8003a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ab:	ff d0                	call   *%eax
}
  8003ad:	83 c4 3c             	add    $0x3c,%esp
  8003b0:	5b                   	pop    %ebx
  8003b1:	5e                   	pop    %esi
  8003b2:	5f                   	pop    %edi
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b8:	83 fa 01             	cmp    $0x1,%edx
  8003bb:	7e 0e                	jle    8003cb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003bd:	8b 10                	mov    (%eax),%edx
  8003bf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c2:	89 08                	mov    %ecx,(%eax)
  8003c4:	8b 02                	mov    (%edx),%eax
  8003c6:	8b 52 04             	mov    0x4(%edx),%edx
  8003c9:	eb 22                	jmp    8003ed <getuint+0x38>
	else if (lflag)
  8003cb:	85 d2                	test   %edx,%edx
  8003cd:	74 10                	je     8003df <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003cf:	8b 10                	mov    (%eax),%edx
  8003d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d4:	89 08                	mov    %ecx,(%eax)
  8003d6:	8b 02                	mov    (%edx),%eax
  8003d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dd:	eb 0e                	jmp    8003ed <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003df:	8b 10                	mov    (%eax),%edx
  8003e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e4:	89 08                	mov    %ecx,(%eax)
  8003e6:	8b 02                	mov    (%edx),%eax
  8003e8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f9:	8b 10                	mov    (%eax),%edx
  8003fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fe:	73 0a                	jae    80040a <sprintputch+0x1b>
		*b->buf++ = ch;
  800400:	8d 4a 01             	lea    0x1(%edx),%ecx
  800403:	89 08                	mov    %ecx,(%eax)
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	88 02                	mov    %al,(%edx)
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <printfmt>:
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  800412:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800415:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800419:	8b 45 10             	mov    0x10(%ebp),%eax
  80041c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800420:	8b 45 0c             	mov    0xc(%ebp),%eax
  800423:	89 44 24 04          	mov    %eax,0x4(%esp)
  800427:	8b 45 08             	mov    0x8(%ebp),%eax
  80042a:	89 04 24             	mov    %eax,(%esp)
  80042d:	e8 02 00 00 00       	call   800434 <vprintfmt>
}
  800432:	c9                   	leave  
  800433:	c3                   	ret    

00800434 <vprintfmt>:
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	57                   	push   %edi
  800438:	56                   	push   %esi
  800439:	53                   	push   %ebx
  80043a:	83 ec 3c             	sub    $0x3c,%esp
  80043d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800440:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800443:	eb 18                	jmp    80045d <vprintfmt+0x29>
			if (ch == '\0')
  800445:	85 c0                	test   %eax,%eax
  800447:	0f 84 c3 03 00 00    	je     800810 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80044d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800451:	89 04 24             	mov    %eax,(%esp)
  800454:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800457:	89 f3                	mov    %esi,%ebx
  800459:	eb 02                	jmp    80045d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80045b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80045d:	8d 73 01             	lea    0x1(%ebx),%esi
  800460:	0f b6 03             	movzbl (%ebx),%eax
  800463:	83 f8 25             	cmp    $0x25,%eax
  800466:	75 dd                	jne    800445 <vprintfmt+0x11>
  800468:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80046c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800473:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80047a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800481:	ba 00 00 00 00       	mov    $0x0,%edx
  800486:	eb 1d                	jmp    8004a5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800488:	89 de                	mov    %ebx,%esi
			padc = '-';
  80048a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80048e:	eb 15                	jmp    8004a5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800490:	89 de                	mov    %ebx,%esi
			padc = '0';
  800492:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800496:	eb 0d                	jmp    8004a5 <vprintfmt+0x71>
				width = precision, precision = -1;
  800498:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80049b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004a8:	0f b6 06             	movzbl (%esi),%eax
  8004ab:	0f b6 c8             	movzbl %al,%ecx
  8004ae:	83 e8 23             	sub    $0x23,%eax
  8004b1:	3c 55                	cmp    $0x55,%al
  8004b3:	0f 87 2f 03 00 00    	ja     8007e8 <vprintfmt+0x3b4>
  8004b9:	0f b6 c0             	movzbl %al,%eax
  8004bc:	ff 24 85 a0 27 80 00 	jmp    *0x8027a0(,%eax,4)
				precision = precision * 10 + ch - '0';
  8004c3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8004c6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  8004c9:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004cd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004d0:	83 f9 09             	cmp    $0x9,%ecx
  8004d3:	77 50                	ja     800525 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	89 de                	mov    %ebx,%esi
  8004d7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8004da:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004dd:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004e0:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004e4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004e7:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004ea:	83 fb 09             	cmp    $0x9,%ebx
  8004ed:	76 eb                	jbe    8004da <vprintfmt+0xa6>
  8004ef:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004f2:	eb 33                	jmp    800527 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	8d 48 04             	lea    0x4(%eax),%ecx
  8004fa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004fd:	8b 00                	mov    (%eax),%eax
  8004ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800502:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800504:	eb 21                	jmp    800527 <vprintfmt+0xf3>
  800506:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800509:	85 c9                	test   %ecx,%ecx
  80050b:	b8 00 00 00 00       	mov    $0x0,%eax
  800510:	0f 49 c1             	cmovns %ecx,%eax
  800513:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800516:	89 de                	mov    %ebx,%esi
  800518:	eb 8b                	jmp    8004a5 <vprintfmt+0x71>
  80051a:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80051c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800523:	eb 80                	jmp    8004a5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800525:	89 de                	mov    %ebx,%esi
			if (width < 0)
  800527:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052b:	0f 89 74 ff ff ff    	jns    8004a5 <vprintfmt+0x71>
  800531:	e9 62 ff ff ff       	jmp    800498 <vprintfmt+0x64>
			lflag++;
  800536:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800539:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80053b:	e9 65 ff ff ff       	jmp    8004a5 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054d:	8b 00                	mov    (%eax),%eax
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	ff 55 08             	call   *0x8(%ebp)
			break;
  800555:	e9 03 ff ff ff       	jmp    80045d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	8b 00                	mov    (%eax),%eax
  800565:	99                   	cltd   
  800566:	31 d0                	xor    %edx,%eax
  800568:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056a:	83 f8 0f             	cmp    $0xf,%eax
  80056d:	7f 0b                	jg     80057a <vprintfmt+0x146>
  80056f:	8b 14 85 00 29 80 00 	mov    0x802900(,%eax,4),%edx
  800576:	85 d2                	test   %edx,%edx
  800578:	75 20                	jne    80059a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80057a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80057e:	c7 44 24 08 6b 26 80 	movl   $0x80266b,0x8(%esp)
  800585:	00 
  800586:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058a:	8b 45 08             	mov    0x8(%ebp),%eax
  80058d:	89 04 24             	mov    %eax,(%esp)
  800590:	e8 77 fe ff ff       	call   80040c <printfmt>
  800595:	e9 c3 fe ff ff       	jmp    80045d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80059a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80059e:	c7 44 24 08 b3 2b 80 	movl   $0x802bb3,0x8(%esp)
  8005a5:	00 
  8005a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ad:	89 04 24             	mov    %eax,(%esp)
  8005b0:	e8 57 fe ff ff       	call   80040c <printfmt>
  8005b5:	e9 a3 fe ff ff       	jmp    80045d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005bd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 04             	lea    0x4(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	ba 64 26 80 00       	mov    $0x802664,%edx
  8005d2:	0f 45 d0             	cmovne %eax,%edx
  8005d5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8005d8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8005dc:	74 04                	je     8005e2 <vprintfmt+0x1ae>
  8005de:	85 f6                	test   %esi,%esi
  8005e0:	7f 19                	jg     8005fb <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005e5:	8d 70 01             	lea    0x1(%eax),%esi
  8005e8:	0f b6 10             	movzbl (%eax),%edx
  8005eb:	0f be c2             	movsbl %dl,%eax
  8005ee:	85 c0                	test   %eax,%eax
  8005f0:	0f 85 95 00 00 00    	jne    80068b <vprintfmt+0x257>
  8005f6:	e9 85 00 00 00       	jmp    800680 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ff:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800602:	89 04 24             	mov    %eax,(%esp)
  800605:	e8 b8 02 00 00       	call   8008c2 <strnlen>
  80060a:	29 c6                	sub    %eax,%esi
  80060c:	89 f0                	mov    %esi,%eax
  80060e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800611:	85 f6                	test   %esi,%esi
  800613:	7e cd                	jle    8005e2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800615:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800619:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80061c:	89 c3                	mov    %eax,%ebx
  80061e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800622:	89 34 24             	mov    %esi,(%esp)
  800625:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800628:	83 eb 01             	sub    $0x1,%ebx
  80062b:	75 f1                	jne    80061e <vprintfmt+0x1ea>
  80062d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800630:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800633:	eb ad                	jmp    8005e2 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800635:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800639:	74 1e                	je     800659 <vprintfmt+0x225>
  80063b:	0f be d2             	movsbl %dl,%edx
  80063e:	83 ea 20             	sub    $0x20,%edx
  800641:	83 fa 5e             	cmp    $0x5e,%edx
  800644:	76 13                	jbe    800659 <vprintfmt+0x225>
					putch('?', putdat);
  800646:	8b 45 0c             	mov    0xc(%ebp),%eax
  800649:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800654:	ff 55 08             	call   *0x8(%ebp)
  800657:	eb 0d                	jmp    800666 <vprintfmt+0x232>
					putch(ch, putdat);
  800659:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80065c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800660:	89 04 24             	mov    %eax,(%esp)
  800663:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800666:	83 ef 01             	sub    $0x1,%edi
  800669:	83 c6 01             	add    $0x1,%esi
  80066c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800670:	0f be c2             	movsbl %dl,%eax
  800673:	85 c0                	test   %eax,%eax
  800675:	75 20                	jne    800697 <vprintfmt+0x263>
  800677:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80067a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80067d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800680:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800684:	7f 25                	jg     8006ab <vprintfmt+0x277>
  800686:	e9 d2 fd ff ff       	jmp    80045d <vprintfmt+0x29>
  80068b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80068e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800691:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800694:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800697:	85 db                	test   %ebx,%ebx
  800699:	78 9a                	js     800635 <vprintfmt+0x201>
  80069b:	83 eb 01             	sub    $0x1,%ebx
  80069e:	79 95                	jns    800635 <vprintfmt+0x201>
  8006a0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006a3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006a9:	eb d5                	jmp    800680 <vprintfmt+0x24c>
  8006ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ae:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  8006b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006bf:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006c1:	83 eb 01             	sub    $0x1,%ebx
  8006c4:	75 ee                	jne    8006b4 <vprintfmt+0x280>
  8006c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006c9:	e9 8f fd ff ff       	jmp    80045d <vprintfmt+0x29>
	if (lflag >= 2)
  8006ce:	83 fa 01             	cmp    $0x1,%edx
  8006d1:	7e 16                	jle    8006e9 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8d 50 08             	lea    0x8(%eax),%edx
  8006d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dc:	8b 50 04             	mov    0x4(%eax),%edx
  8006df:	8b 00                	mov    (%eax),%eax
  8006e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e7:	eb 32                	jmp    80071b <vprintfmt+0x2e7>
	else if (lflag)
  8006e9:	85 d2                	test   %edx,%edx
  8006eb:	74 18                	je     800705 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8d 50 04             	lea    0x4(%eax),%edx
  8006f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f6:	8b 30                	mov    (%eax),%esi
  8006f8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006fb:	89 f0                	mov    %esi,%eax
  8006fd:	c1 f8 1f             	sar    $0x1f,%eax
  800700:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800703:	eb 16                	jmp    80071b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8d 50 04             	lea    0x4(%eax),%edx
  80070b:	89 55 14             	mov    %edx,0x14(%ebp)
  80070e:	8b 30                	mov    (%eax),%esi
  800710:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800713:	89 f0                	mov    %esi,%eax
  800715:	c1 f8 1f             	sar    $0x1f,%eax
  800718:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  80071b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  800721:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800726:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80072a:	0f 89 80 00 00 00    	jns    8007b0 <vprintfmt+0x37c>
				putch('-', putdat);
  800730:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800734:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80073b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80073e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800741:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800744:	f7 d8                	neg    %eax
  800746:	83 d2 00             	adc    $0x0,%edx
  800749:	f7 da                	neg    %edx
			base = 10;
  80074b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800750:	eb 5e                	jmp    8007b0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800752:	8d 45 14             	lea    0x14(%ebp),%eax
  800755:	e8 5b fc ff ff       	call   8003b5 <getuint>
			base = 10;
  80075a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80075f:	eb 4f                	jmp    8007b0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800761:	8d 45 14             	lea    0x14(%ebp),%eax
  800764:	e8 4c fc ff ff       	call   8003b5 <getuint>
			base = 8;
  800769:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80076e:	eb 40                	jmp    8007b0 <vprintfmt+0x37c>
			putch('0', putdat);
  800770:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800774:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80077b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80077e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800782:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800789:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8d 50 04             	lea    0x4(%eax),%edx
  800792:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800795:	8b 00                	mov    (%eax),%eax
  800797:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80079c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007a1:	eb 0d                	jmp    8007b0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a6:	e8 0a fc ff ff       	call   8003b5 <getuint>
			base = 16;
  8007ab:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8007b0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8007b4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007b8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007bb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007bf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007c3:	89 04 24             	mov    %eax,(%esp)
  8007c6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ca:	89 fa                	mov    %edi,%edx
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	e8 ec fa ff ff       	call   8002c0 <printnum>
			break;
  8007d4:	e9 84 fc ff ff       	jmp    80045d <vprintfmt+0x29>
			putch(ch, putdat);
  8007d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007dd:	89 0c 24             	mov    %ecx,(%esp)
  8007e0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007e3:	e9 75 fc ff ff       	jmp    80045d <vprintfmt+0x29>
			putch('%', putdat);
  8007e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ec:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007f3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007fa:	0f 84 5b fc ff ff    	je     80045b <vprintfmt+0x27>
  800800:	89 f3                	mov    %esi,%ebx
  800802:	83 eb 01             	sub    $0x1,%ebx
  800805:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800809:	75 f7                	jne    800802 <vprintfmt+0x3ce>
  80080b:	e9 4d fc ff ff       	jmp    80045d <vprintfmt+0x29>
}
  800810:	83 c4 3c             	add    $0x3c,%esp
  800813:	5b                   	pop    %ebx
  800814:	5e                   	pop    %esi
  800815:	5f                   	pop    %edi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	83 ec 28             	sub    $0x28,%esp
  80081e:	8b 45 08             	mov    0x8(%ebp),%eax
  800821:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800824:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800827:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80082b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800835:	85 c0                	test   %eax,%eax
  800837:	74 30                	je     800869 <vsnprintf+0x51>
  800839:	85 d2                	test   %edx,%edx
  80083b:	7e 2c                	jle    800869 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083d:	8b 45 14             	mov    0x14(%ebp),%eax
  800840:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800844:	8b 45 10             	mov    0x10(%ebp),%eax
  800847:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800852:	c7 04 24 ef 03 80 00 	movl   $0x8003ef,(%esp)
  800859:	e8 d6 fb ff ff       	call   800434 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800861:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800864:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800867:	eb 05                	jmp    80086e <vsnprintf+0x56>
		return -E_INVAL;
  800869:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80086e:	c9                   	leave  
  80086f:	c3                   	ret    

00800870 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800876:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800879:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087d:	8b 45 10             	mov    0x10(%ebp),%eax
  800880:	89 44 24 08          	mov    %eax,0x8(%esp)
  800884:	8b 45 0c             	mov    0xc(%ebp),%eax
  800887:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	89 04 24             	mov    %eax,(%esp)
  800891:	e8 82 ff ff ff       	call   800818 <vsnprintf>
	va_end(ap);

	return rc;
}
  800896:	c9                   	leave  
  800897:	c3                   	ret    
  800898:	66 90                	xchg   %ax,%ax
  80089a:	66 90                	xchg   %ax,%ax
  80089c:	66 90                	xchg   %ax,%ax
  80089e:	66 90                	xchg   %ax,%ax

008008a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a6:	80 3a 00             	cmpb   $0x0,(%edx)
  8008a9:	74 10                	je     8008bb <strlen+0x1b>
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008b0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b7:	75 f7                	jne    8008b0 <strlen+0x10>
  8008b9:	eb 05                	jmp    8008c0 <strlen+0x20>
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cc:	85 c9                	test   %ecx,%ecx
  8008ce:	74 1c                	je     8008ec <strnlen+0x2a>
  8008d0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008d3:	74 1e                	je     8008f3 <strnlen+0x31>
  8008d5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008da:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008dc:	39 ca                	cmp    %ecx,%edx
  8008de:	74 18                	je     8008f8 <strnlen+0x36>
  8008e0:	83 c2 01             	add    $0x1,%edx
  8008e3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008e8:	75 f0                	jne    8008da <strnlen+0x18>
  8008ea:	eb 0c                	jmp    8008f8 <strnlen+0x36>
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f1:	eb 05                	jmp    8008f8 <strnlen+0x36>
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	53                   	push   %ebx
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800905:	89 c2                	mov    %eax,%edx
  800907:	83 c2 01             	add    $0x1,%edx
  80090a:	83 c1 01             	add    $0x1,%ecx
  80090d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800911:	88 5a ff             	mov    %bl,-0x1(%edx)
  800914:	84 db                	test   %bl,%bl
  800916:	75 ef                	jne    800907 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800918:	5b                   	pop    %ebx
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	83 ec 08             	sub    $0x8,%esp
  800922:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800925:	89 1c 24             	mov    %ebx,(%esp)
  800928:	e8 73 ff ff ff       	call   8008a0 <strlen>
	strcpy(dst + len, src);
  80092d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800930:	89 54 24 04          	mov    %edx,0x4(%esp)
  800934:	01 d8                	add    %ebx,%eax
  800936:	89 04 24             	mov    %eax,(%esp)
  800939:	e8 bd ff ff ff       	call   8008fb <strcpy>
	return dst;
}
  80093e:	89 d8                	mov    %ebx,%eax
  800940:	83 c4 08             	add    $0x8,%esp
  800943:	5b                   	pop    %ebx
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	56                   	push   %esi
  80094a:	53                   	push   %ebx
  80094b:	8b 75 08             	mov    0x8(%ebp),%esi
  80094e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800951:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800954:	85 db                	test   %ebx,%ebx
  800956:	74 17                	je     80096f <strncpy+0x29>
  800958:	01 f3                	add    %esi,%ebx
  80095a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80095c:	83 c1 01             	add    $0x1,%ecx
  80095f:	0f b6 02             	movzbl (%edx),%eax
  800962:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800965:	80 3a 01             	cmpb   $0x1,(%edx)
  800968:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80096b:	39 d9                	cmp    %ebx,%ecx
  80096d:	75 ed                	jne    80095c <strncpy+0x16>
	}
	return ret;
}
  80096f:	89 f0                	mov    %esi,%eax
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	57                   	push   %edi
  800979:	56                   	push   %esi
  80097a:	53                   	push   %ebx
  80097b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800981:	8b 75 10             	mov    0x10(%ebp),%esi
  800984:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800986:	85 f6                	test   %esi,%esi
  800988:	74 34                	je     8009be <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  80098a:	83 fe 01             	cmp    $0x1,%esi
  80098d:	74 26                	je     8009b5 <strlcpy+0x40>
  80098f:	0f b6 0b             	movzbl (%ebx),%ecx
  800992:	84 c9                	test   %cl,%cl
  800994:	74 23                	je     8009b9 <strlcpy+0x44>
  800996:	83 ee 02             	sub    $0x2,%esi
  800999:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  80099e:	83 c0 01             	add    $0x1,%eax
  8009a1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009a4:	39 f2                	cmp    %esi,%edx
  8009a6:	74 13                	je     8009bb <strlcpy+0x46>
  8009a8:	83 c2 01             	add    $0x1,%edx
  8009ab:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009af:	84 c9                	test   %cl,%cl
  8009b1:	75 eb                	jne    80099e <strlcpy+0x29>
  8009b3:	eb 06                	jmp    8009bb <strlcpy+0x46>
  8009b5:	89 f8                	mov    %edi,%eax
  8009b7:	eb 02                	jmp    8009bb <strlcpy+0x46>
  8009b9:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  8009bb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009be:	29 f8                	sub    %edi,%eax
}
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5f                   	pop    %edi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ce:	0f b6 01             	movzbl (%ecx),%eax
  8009d1:	84 c0                	test   %al,%al
  8009d3:	74 15                	je     8009ea <strcmp+0x25>
  8009d5:	3a 02                	cmp    (%edx),%al
  8009d7:	75 11                	jne    8009ea <strcmp+0x25>
		p++, q++;
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009df:	0f b6 01             	movzbl (%ecx),%eax
  8009e2:	84 c0                	test   %al,%al
  8009e4:	74 04                	je     8009ea <strcmp+0x25>
  8009e6:	3a 02                	cmp    (%edx),%al
  8009e8:	74 ef                	je     8009d9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ea:	0f b6 c0             	movzbl %al,%eax
  8009ed:	0f b6 12             	movzbl (%edx),%edx
  8009f0:	29 d0                	sub    %edx,%eax
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ff:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a02:	85 f6                	test   %esi,%esi
  800a04:	74 29                	je     800a2f <strncmp+0x3b>
  800a06:	0f b6 03             	movzbl (%ebx),%eax
  800a09:	84 c0                	test   %al,%al
  800a0b:	74 30                	je     800a3d <strncmp+0x49>
  800a0d:	3a 02                	cmp    (%edx),%al
  800a0f:	75 2c                	jne    800a3d <strncmp+0x49>
  800a11:	8d 43 01             	lea    0x1(%ebx),%eax
  800a14:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800a16:	89 c3                	mov    %eax,%ebx
  800a18:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a1b:	39 f0                	cmp    %esi,%eax
  800a1d:	74 17                	je     800a36 <strncmp+0x42>
  800a1f:	0f b6 08             	movzbl (%eax),%ecx
  800a22:	84 c9                	test   %cl,%cl
  800a24:	74 17                	je     800a3d <strncmp+0x49>
  800a26:	83 c0 01             	add    $0x1,%eax
  800a29:	3a 0a                	cmp    (%edx),%cl
  800a2b:	74 e9                	je     800a16 <strncmp+0x22>
  800a2d:	eb 0e                	jmp    800a3d <strncmp+0x49>
	if (n == 0)
		return 0;
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a34:	eb 0f                	jmp    800a45 <strncmp+0x51>
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	eb 08                	jmp    800a45 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3d:	0f b6 03             	movzbl (%ebx),%eax
  800a40:	0f b6 12             	movzbl (%edx),%edx
  800a43:	29 d0                	sub    %edx,%eax
}
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	53                   	push   %ebx
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a53:	0f b6 18             	movzbl (%eax),%ebx
  800a56:	84 db                	test   %bl,%bl
  800a58:	74 1d                	je     800a77 <strchr+0x2e>
  800a5a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a5c:	38 d3                	cmp    %dl,%bl
  800a5e:	75 06                	jne    800a66 <strchr+0x1d>
  800a60:	eb 1a                	jmp    800a7c <strchr+0x33>
  800a62:	38 ca                	cmp    %cl,%dl
  800a64:	74 16                	je     800a7c <strchr+0x33>
	for (; *s; s++)
  800a66:	83 c0 01             	add    $0x1,%eax
  800a69:	0f b6 10             	movzbl (%eax),%edx
  800a6c:	84 d2                	test   %dl,%dl
  800a6e:	75 f2                	jne    800a62 <strchr+0x19>
			return (char *) s;
	return 0;
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
  800a75:	eb 05                	jmp    800a7c <strchr+0x33>
  800a77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	53                   	push   %ebx
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a89:	0f b6 18             	movzbl (%eax),%ebx
  800a8c:	84 db                	test   %bl,%bl
  800a8e:	74 16                	je     800aa6 <strfind+0x27>
  800a90:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a92:	38 d3                	cmp    %dl,%bl
  800a94:	75 06                	jne    800a9c <strfind+0x1d>
  800a96:	eb 0e                	jmp    800aa6 <strfind+0x27>
  800a98:	38 ca                	cmp    %cl,%dl
  800a9a:	74 0a                	je     800aa6 <strfind+0x27>
	for (; *s; s++)
  800a9c:	83 c0 01             	add    $0x1,%eax
  800a9f:	0f b6 10             	movzbl (%eax),%edx
  800aa2:	84 d2                	test   %dl,%dl
  800aa4:	75 f2                	jne    800a98 <strfind+0x19>
			break;
	return (char *) s;
}
  800aa6:	5b                   	pop    %ebx
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ab5:	85 c9                	test   %ecx,%ecx
  800ab7:	74 36                	je     800aef <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800abf:	75 28                	jne    800ae9 <memset+0x40>
  800ac1:	f6 c1 03             	test   $0x3,%cl
  800ac4:	75 23                	jne    800ae9 <memset+0x40>
		c &= 0xFF;
  800ac6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aca:	89 d3                	mov    %edx,%ebx
  800acc:	c1 e3 08             	shl    $0x8,%ebx
  800acf:	89 d6                	mov    %edx,%esi
  800ad1:	c1 e6 18             	shl    $0x18,%esi
  800ad4:	89 d0                	mov    %edx,%eax
  800ad6:	c1 e0 10             	shl    $0x10,%eax
  800ad9:	09 f0                	or     %esi,%eax
  800adb:	09 c2                	or     %eax,%edx
  800add:	89 d0                	mov    %edx,%eax
  800adf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ae1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ae4:	fc                   	cld    
  800ae5:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae7:	eb 06                	jmp    800aef <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aec:	fc                   	cld    
  800aed:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aef:	89 f8                	mov    %edi,%eax
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b01:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b04:	39 c6                	cmp    %eax,%esi
  800b06:	73 35                	jae    800b3d <memmove+0x47>
  800b08:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b0b:	39 d0                	cmp    %edx,%eax
  800b0d:	73 2e                	jae    800b3d <memmove+0x47>
		s += n;
		d += n;
  800b0f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b12:	89 d6                	mov    %edx,%esi
  800b14:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b16:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b1c:	75 13                	jne    800b31 <memmove+0x3b>
  800b1e:	f6 c1 03             	test   $0x3,%cl
  800b21:	75 0e                	jne    800b31 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b23:	83 ef 04             	sub    $0x4,%edi
  800b26:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b29:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b2c:	fd                   	std    
  800b2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2f:	eb 09                	jmp    800b3a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b31:	83 ef 01             	sub    $0x1,%edi
  800b34:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b37:	fd                   	std    
  800b38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b3a:	fc                   	cld    
  800b3b:	eb 1d                	jmp    800b5a <memmove+0x64>
  800b3d:	89 f2                	mov    %esi,%edx
  800b3f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b41:	f6 c2 03             	test   $0x3,%dl
  800b44:	75 0f                	jne    800b55 <memmove+0x5f>
  800b46:	f6 c1 03             	test   $0x3,%cl
  800b49:	75 0a                	jne    800b55 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b4b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b4e:	89 c7                	mov    %eax,%edi
  800b50:	fc                   	cld    
  800b51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b53:	eb 05                	jmp    800b5a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800b55:	89 c7                	mov    %eax,%edi
  800b57:	fc                   	cld    
  800b58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b64:	8b 45 10             	mov    0x10(%ebp),%eax
  800b67:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b72:	8b 45 08             	mov    0x8(%ebp),%eax
  800b75:	89 04 24             	mov    %eax,(%esp)
  800b78:	e8 79 ff ff ff       	call   800af6 <memmove>
}
  800b7d:	c9                   	leave  
  800b7e:	c3                   	ret    

00800b7f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b91:	85 c0                	test   %eax,%eax
  800b93:	74 36                	je     800bcb <memcmp+0x4c>
		if (*s1 != *s2)
  800b95:	0f b6 03             	movzbl (%ebx),%eax
  800b98:	0f b6 0e             	movzbl (%esi),%ecx
  800b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba0:	38 c8                	cmp    %cl,%al
  800ba2:	74 1c                	je     800bc0 <memcmp+0x41>
  800ba4:	eb 10                	jmp    800bb6 <memcmp+0x37>
  800ba6:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800bab:	83 c2 01             	add    $0x1,%edx
  800bae:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800bb2:	38 c8                	cmp    %cl,%al
  800bb4:	74 0a                	je     800bc0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800bb6:	0f b6 c0             	movzbl %al,%eax
  800bb9:	0f b6 c9             	movzbl %cl,%ecx
  800bbc:	29 c8                	sub    %ecx,%eax
  800bbe:	eb 10                	jmp    800bd0 <memcmp+0x51>
	while (n-- > 0) {
  800bc0:	39 fa                	cmp    %edi,%edx
  800bc2:	75 e2                	jne    800ba6 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800bc4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc9:	eb 05                	jmp    800bd0 <memcmp+0x51>
  800bcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	53                   	push   %ebx
  800bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800bdf:	89 c2                	mov    %eax,%edx
  800be1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800be4:	39 d0                	cmp    %edx,%eax
  800be6:	73 13                	jae    800bfb <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be8:	89 d9                	mov    %ebx,%ecx
  800bea:	38 18                	cmp    %bl,(%eax)
  800bec:	75 06                	jne    800bf4 <memfind+0x1f>
  800bee:	eb 0b                	jmp    800bfb <memfind+0x26>
  800bf0:	38 08                	cmp    %cl,(%eax)
  800bf2:	74 07                	je     800bfb <memfind+0x26>
	for (; s < ends; s++)
  800bf4:	83 c0 01             	add    $0x1,%eax
  800bf7:	39 d0                	cmp    %edx,%eax
  800bf9:	75 f5                	jne    800bf0 <memfind+0x1b>
			break;
	return (void *) s;
}
  800bfb:	5b                   	pop    %ebx
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	8b 55 08             	mov    0x8(%ebp),%edx
  800c07:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0a:	0f b6 0a             	movzbl (%edx),%ecx
  800c0d:	80 f9 09             	cmp    $0x9,%cl
  800c10:	74 05                	je     800c17 <strtol+0x19>
  800c12:	80 f9 20             	cmp    $0x20,%cl
  800c15:	75 10                	jne    800c27 <strtol+0x29>
		s++;
  800c17:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c1a:	0f b6 0a             	movzbl (%edx),%ecx
  800c1d:	80 f9 09             	cmp    $0x9,%cl
  800c20:	74 f5                	je     800c17 <strtol+0x19>
  800c22:	80 f9 20             	cmp    $0x20,%cl
  800c25:	74 f0                	je     800c17 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800c27:	80 f9 2b             	cmp    $0x2b,%cl
  800c2a:	75 0a                	jne    800c36 <strtol+0x38>
		s++;
  800c2c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c2f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c34:	eb 11                	jmp    800c47 <strtol+0x49>
  800c36:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800c3b:	80 f9 2d             	cmp    $0x2d,%cl
  800c3e:	75 07                	jne    800c47 <strtol+0x49>
		s++, neg = 1;
  800c40:	83 c2 01             	add    $0x1,%edx
  800c43:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c47:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c4c:	75 15                	jne    800c63 <strtol+0x65>
  800c4e:	80 3a 30             	cmpb   $0x30,(%edx)
  800c51:	75 10                	jne    800c63 <strtol+0x65>
  800c53:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c57:	75 0a                	jne    800c63 <strtol+0x65>
		s += 2, base = 16;
  800c59:	83 c2 02             	add    $0x2,%edx
  800c5c:	b8 10 00 00 00       	mov    $0x10,%eax
  800c61:	eb 10                	jmp    800c73 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800c63:	85 c0                	test   %eax,%eax
  800c65:	75 0c                	jne    800c73 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c67:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800c69:	80 3a 30             	cmpb   $0x30,(%edx)
  800c6c:	75 05                	jne    800c73 <strtol+0x75>
		s++, base = 8;
  800c6e:	83 c2 01             	add    $0x1,%edx
  800c71:	b0 08                	mov    $0x8,%al
		base = 10;
  800c73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c78:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c7b:	0f b6 0a             	movzbl (%edx),%ecx
  800c7e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c81:	89 f0                	mov    %esi,%eax
  800c83:	3c 09                	cmp    $0x9,%al
  800c85:	77 08                	ja     800c8f <strtol+0x91>
			dig = *s - '0';
  800c87:	0f be c9             	movsbl %cl,%ecx
  800c8a:	83 e9 30             	sub    $0x30,%ecx
  800c8d:	eb 20                	jmp    800caf <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800c8f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c92:	89 f0                	mov    %esi,%eax
  800c94:	3c 19                	cmp    $0x19,%al
  800c96:	77 08                	ja     800ca0 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c98:	0f be c9             	movsbl %cl,%ecx
  800c9b:	83 e9 57             	sub    $0x57,%ecx
  800c9e:	eb 0f                	jmp    800caf <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800ca0:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ca3:	89 f0                	mov    %esi,%eax
  800ca5:	3c 19                	cmp    $0x19,%al
  800ca7:	77 16                	ja     800cbf <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ca9:	0f be c9             	movsbl %cl,%ecx
  800cac:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800caf:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800cb2:	7d 0f                	jge    800cc3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800cb4:	83 c2 01             	add    $0x1,%edx
  800cb7:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800cbb:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800cbd:	eb bc                	jmp    800c7b <strtol+0x7d>
  800cbf:	89 d8                	mov    %ebx,%eax
  800cc1:	eb 02                	jmp    800cc5 <strtol+0xc7>
  800cc3:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800cc5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc9:	74 05                	je     800cd0 <strtol+0xd2>
		*endptr = (char *) s;
  800ccb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cce:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800cd0:	f7 d8                	neg    %eax
  800cd2:	85 ff                	test   %edi,%edi
  800cd4:	0f 44 c3             	cmove  %ebx,%eax
}
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	89 c3                	mov    %eax,%ebx
  800cef:	89 c7                	mov    %eax,%edi
  800cf1:	89 c6                	mov    %eax,%esi
  800cf3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_cgetc>:

int
sys_cgetc(void)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d00:	ba 00 00 00 00       	mov    $0x0,%edx
  800d05:	b8 01 00 00 00       	mov    $0x1,%eax
  800d0a:	89 d1                	mov    %edx,%ecx
  800d0c:	89 d3                	mov    %edx,%ebx
  800d0e:	89 d7                	mov    %edx,%edi
  800d10:	89 d6                	mov    %edx,%esi
  800d12:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d27:	b8 03 00 00 00       	mov    $0x3,%eax
  800d2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2f:	89 cb                	mov    %ecx,%ebx
  800d31:	89 cf                	mov    %ecx,%edi
  800d33:	89 ce                	mov    %ecx,%esi
  800d35:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d37:	85 c0                	test   %eax,%eax
  800d39:	7e 28                	jle    800d63 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d46:	00 
  800d47:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800d4e:	00 
  800d4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d56:	00 
  800d57:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800d5e:	e8 46 f4 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d63:	83 c4 2c             	add    $0x2c,%esp
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d71:	ba 00 00 00 00       	mov    $0x0,%edx
  800d76:	b8 02 00 00 00       	mov    $0x2,%eax
  800d7b:	89 d1                	mov    %edx,%ecx
  800d7d:	89 d3                	mov    %edx,%ebx
  800d7f:	89 d7                	mov    %edx,%edi
  800d81:	89 d6                	mov    %edx,%esi
  800d83:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_yield>:

void
sys_yield(void)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d90:	ba 00 00 00 00       	mov    $0x0,%edx
  800d95:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d9a:	89 d1                	mov    %edx,%ecx
  800d9c:	89 d3                	mov    %edx,%ebx
  800d9e:	89 d7                	mov    %edx,%edi
  800da0:	89 d6                	mov    %edx,%esi
  800da2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800db2:	be 00 00 00 00       	mov    $0x0,%esi
  800db7:	b8 04 00 00 00       	mov    $0x4,%eax
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc5:	89 f7                	mov    %esi,%edi
  800dc7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 28                	jle    800df5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800dd8:	00 
  800dd9:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800de0:	00 
  800de1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de8:	00 
  800de9:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800df0:	e8 b4 f3 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800df5:	83 c4 2c             	add    $0x2c,%esp
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e06:	b8 05 00 00 00       	mov    $0x5,%eax
  800e0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e14:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e17:	8b 75 18             	mov    0x18(%ebp),%esi
  800e1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	7e 28                	jle    800e48 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e24:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e2b:	00 
  800e2c:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800e33:	00 
  800e34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3b:	00 
  800e3c:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800e43:	e8 61 f3 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e48:	83 c4 2c             	add    $0x2c,%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	57                   	push   %edi
  800e54:	56                   	push   %esi
  800e55:	53                   	push   %ebx
  800e56:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e66:	8b 55 08             	mov    0x8(%ebp),%edx
  800e69:	89 df                	mov    %ebx,%edi
  800e6b:	89 de                	mov    %ebx,%esi
  800e6d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	7e 28                	jle    800e9b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e77:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e7e:	00 
  800e7f:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800e86:	00 
  800e87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8e:	00 
  800e8f:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800e96:	e8 0e f3 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e9b:	83 c4 2c             	add    $0x2c,%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800eac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb1:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	89 df                	mov    %ebx,%edi
  800ebe:	89 de                	mov    %ebx,%esi
  800ec0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	7e 28                	jle    800eee <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eca:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800ed9:	00 
  800eda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee1:	00 
  800ee2:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800ee9:	e8 bb f2 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800eee:	83 c4 2c             	add    $0x2c,%esp
  800ef1:	5b                   	pop    %ebx
  800ef2:	5e                   	pop    %esi
  800ef3:	5f                   	pop    %edi
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    

00800ef6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	57                   	push   %edi
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
  800efc:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800eff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f04:	b8 09 00 00 00       	mov    $0x9,%eax
  800f09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0f:	89 df                	mov    %ebx,%edi
  800f11:	89 de                	mov    %ebx,%esi
  800f13:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f15:	85 c0                	test   %eax,%eax
  800f17:	7e 28                	jle    800f41 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f24:	00 
  800f25:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800f2c:	00 
  800f2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f34:	00 
  800f35:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800f3c:	e8 68 f2 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f41:	83 c4 2c             	add    $0x2c,%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    

00800f49 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	57                   	push   %edi
  800f4d:	56                   	push   %esi
  800f4e:	53                   	push   %ebx
  800f4f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f57:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f62:	89 df                	mov    %ebx,%edi
  800f64:	89 de                	mov    %ebx,%esi
  800f66:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	7e 28                	jle    800f94 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f70:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f77:	00 
  800f78:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800f7f:	00 
  800f80:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f87:	00 
  800f88:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800f8f:	e8 15 f2 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f94:	83 c4 2c             	add    $0x2c,%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	57                   	push   %edi
  800fa0:	56                   	push   %esi
  800fa1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fa2:	be 00 00 00 00       	mov    $0x0,%esi
  800fa7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800faf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fb8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fba:	5b                   	pop    %ebx
  800fbb:	5e                   	pop    %esi
  800fbc:	5f                   	pop    %edi
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    

00800fbf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	57                   	push   %edi
  800fc3:	56                   	push   %esi
  800fc4:	53                   	push   %ebx
  800fc5:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800fc8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fcd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd5:	89 cb                	mov    %ecx,%ebx
  800fd7:	89 cf                	mov    %ecx,%edi
  800fd9:	89 ce                	mov    %ecx,%esi
  800fdb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	7e 28                	jle    801009 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fec:	00 
  800fed:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800ff4:	00 
  800ff5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ffc:	00 
  800ffd:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  801004:	e8 a0 f1 ff ff       	call   8001a9 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801009:	83 c4 2c             	add    $0x2c,%esp
  80100c:	5b                   	pop    %ebx
  80100d:	5e                   	pop    %esi
  80100e:	5f                   	pop    %edi
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    

00801011 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	53                   	push   %ebx
  801015:	83 ec 24             	sub    $0x24,%esp
  801018:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80101b:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  80101d:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  801021:	74 2e                	je     801051 <pgfault+0x40>
  801023:	89 c2                	mov    %eax,%edx
  801025:	c1 ea 16             	shr    $0x16,%edx
  801028:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80102f:	f6 c2 01             	test   $0x1,%dl
  801032:	74 1d                	je     801051 <pgfault+0x40>
  801034:	89 c2                	mov    %eax,%edx
  801036:	c1 ea 0c             	shr    $0xc,%edx
  801039:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801040:	f6 c1 01             	test   $0x1,%cl
  801043:	74 0c                	je     801051 <pgfault+0x40>
  801045:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80104c:	f6 c6 08             	test   $0x8,%dh
  80104f:	75 20                	jne    801071 <pgfault+0x60>
		panic("pgfault: page cow check failed, addr=%x\n", addr);
  801051:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801055:	c7 44 24 08 8c 29 80 	movl   $0x80298c,0x8(%esp)
  80105c:	00 
  80105d:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  801064:	00 
  801065:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  80106c:	e8 38 f1 ff ff       	call   8001a9 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  801071:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801076:	89 c3                	mov    %eax,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W))
  801078:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80107f:	00 
  801080:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801087:	00 
  801088:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80108f:	e8 15 fd ff ff       	call   800da9 <sys_page_alloc>
  801094:	85 c0                	test   %eax,%eax
  801096:	74 1c                	je     8010b4 <pgfault+0xa3>
		panic("pgfault: sys_page_alloc error");
  801098:	c7 44 24 08 7e 2a 80 	movl   $0x802a7e,0x8(%esp)
  80109f:	00 
  8010a0:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8010a7:	00 
  8010a8:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  8010af:	e8 f5 f0 ff ff       	call   8001a9 <_panic>

	memmove(PFTEMP, addr, PGSIZE);
  8010b4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010bb:	00 
  8010bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010c0:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010c7:	e8 2a fa ff ff       	call   800af6 <memmove>
	if(sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))
  8010cc:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010d3:	00 
  8010d4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010df:	00 
  8010e0:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010e7:	00 
  8010e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ef:	e8 09 fd ff ff       	call   800dfd <sys_page_map>
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	74 1c                	je     801114 <pgfault+0x103>
		panic("pgfault: sys_page_map error");
  8010f8:	c7 44 24 08 9c 2a 80 	movl   $0x802a9c,0x8(%esp)
  8010ff:	00 
  801100:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801107:	00 
  801108:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  80110f:	e8 95 f0 ff ff       	call   8001a9 <_panic>

	if(sys_page_unmap(0, PFTEMP))
  801114:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80111b:	00 
  80111c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801123:	e8 28 fd ff ff       	call   800e50 <sys_page_unmap>
  801128:	85 c0                	test   %eax,%eax
  80112a:	74 1c                	je     801148 <pgfault+0x137>
		panic("pgfault: sys_page_unmap error");
  80112c:	c7 44 24 08 b8 2a 80 	movl   $0x802ab8,0x8(%esp)
  801133:	00 
  801134:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80113b:	00 
  80113c:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  801143:	e8 61 f0 ff ff       	call   8001a9 <_panic>
}
  801148:	83 c4 24             	add    $0x24,%esp
  80114b:	5b                   	pop    %ebx
  80114c:	5d                   	pop    %ebp
  80114d:	c3                   	ret    

0080114e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	57                   	push   %edi
  801152:	56                   	push   %esi
  801153:	53                   	push   %ebx
  801154:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	//根据文档的描述，duppage好像不应该处理除了可写或者copy-on-write的部分，但这里都交给duppage一块处理了
	set_pgfault_handler(pgfault);
  801157:	c7 04 24 11 10 80 00 	movl   $0x801011,(%esp)
  80115e:	e8 13 11 00 00       	call   802276 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801163:	b8 07 00 00 00       	mov    $0x7,%eax
  801168:	cd 30                	int    $0x30
  80116a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();
	if(envid < 0)
  80116d:	85 c0                	test   %eax,%eax
  80116f:	79 1c                	jns    80118d <fork+0x3f>
		//失败
		panic("fork: sys_exofork error");
  801171:	c7 44 24 08 d6 2a 80 	movl   $0x802ad6,0x8(%esp)
  801178:	00 
  801179:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
  801180:	00 
  801181:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  801188:	e8 1c f0 ff ff       	call   8001a9 <_panic>
  80118d:	89 c7                	mov    %eax,%edi
	else if(!envid)
  80118f:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801194:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801198:	75 1c                	jne    8011b6 <fork+0x68>
		//子进程
		thisenv = &envs[ENVX(sys_getenvid())];
  80119a:	e8 cc fb ff ff       	call   800d6b <sys_getenvid>
  80119f:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011a4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011a7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011ac:	a3 04 40 80 00       	mov    %eax,0x804004
  8011b1:	e9 fc 01 00 00       	jmp    8013b2 <fork+0x264>
	else{
		//父进程
		unsigned addr;
		for(addr = UTEXT; addr < USTACKTOP; addr += PGSIZE){
			if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))
  8011b6:	89 d8                	mov    %ebx,%eax
  8011b8:	c1 e8 16             	shr    $0x16,%eax
  8011bb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011c2:	a8 01                	test   $0x1,%al
  8011c4:	0f 84 58 01 00 00    	je     801322 <fork+0x1d4>
  8011ca:	89 d8                	mov    %ebx,%eax
  8011cc:	c1 e8 0c             	shr    $0xc,%eax
  8011cf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011d6:	f6 c2 01             	test   $0x1,%dl
  8011d9:	0f 84 43 01 00 00    	je     801322 <fork+0x1d4>
  8011df:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011e6:	f6 c2 04             	test   $0x4,%dl
  8011e9:	0f 84 33 01 00 00    	je     801322 <fork+0x1d4>
	void *addr = (void *)(pn * PGSIZE);
  8011ef:	89 c6                	mov    %eax,%esi
  8011f1:	c1 e6 0c             	shl    $0xc,%esi
	if(uvpt[pn] & PTE_SHARE){
  8011f4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011fb:	f6 c6 04             	test   $0x4,%dh
  8011fe:	74 4c                	je     80124c <fork+0xfe>
		if(sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL))
  801200:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801207:	25 07 0e 00 00       	and    $0xe07,%eax
  80120c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801210:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801214:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801218:	89 74 24 04          	mov    %esi,0x4(%esp)
  80121c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801223:	e8 d5 fb ff ff       	call   800dfd <sys_page_map>
  801228:	85 c0                	test   %eax,%eax
  80122a:	0f 84 f2 00 00 00    	je     801322 <fork+0x1d4>
			panic("duppage: sys_page_map pte_syscall error");
  801230:	c7 44 24 08 b8 29 80 	movl   $0x8029b8,0x8(%esp)
  801237:	00 
  801238:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80123f:	00 
  801240:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  801247:	e8 5d ef ff ff       	call   8001a9 <_panic>
	else if(uvpt[pn] & (PTE_W | PTE_COW)){
  80124c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801253:	a9 02 08 00 00       	test   $0x802,%eax
  801258:	0f 84 84 00 00 00    	je     8012e2 <fork+0x194>
		if(sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P))
  80125e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801265:	00 
  801266:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80126a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80126e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801272:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801279:	e8 7f fb ff ff       	call   800dfd <sys_page_map>
  80127e:	85 c0                	test   %eax,%eax
  801280:	74 1c                	je     80129e <fork+0x150>
			panic("duppage: sys_page_map child error");
  801282:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  801289:	00 
  80128a:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801291:	00 
  801292:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  801299:	e8 0b ef ff ff       	call   8001a9 <_panic>
		if(sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P))
  80129e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8012a5:	00 
  8012a6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012b1:	00 
  8012b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012bd:	e8 3b fb ff ff       	call   800dfd <sys_page_map>
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	74 5c                	je     801322 <fork+0x1d4>
			panic("duppage: sys_page_map remap parent error");
  8012c6:	c7 44 24 08 04 2a 80 	movl   $0x802a04,0x8(%esp)
  8012cd:	00 
  8012ce:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  8012d5:	00 
  8012d6:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  8012dd:	e8 c7 ee ff ff       	call   8001a9 <_panic>
		if(sys_page_map(0, addr, envid, addr, PTE_U|PTE_P))
  8012e2:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8012e9:	00 
  8012ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012fd:	e8 fb fa ff ff       	call   800dfd <sys_page_map>
  801302:	85 c0                	test   %eax,%eax
  801304:	74 1c                	je     801322 <fork+0x1d4>
			panic("duppage: other sys_page_map error");
  801306:	c7 44 24 08 30 2a 80 	movl   $0x802a30,0x8(%esp)
  80130d:	00 
  80130e:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  801315:	00 
  801316:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  80131d:	e8 87 ee ff ff       	call   8001a9 <_panic>
		for(addr = UTEXT; addr < USTACKTOP; addr += PGSIZE){
  801322:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801328:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80132e:	0f 85 82 fe ff ff    	jne    8011b6 <fork+0x68>
				duppage(envid, PGNUM(addr));
		}
		if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W))
  801334:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80133b:	00 
  80133c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801343:	ee 
  801344:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801347:	89 04 24             	mov    %eax,(%esp)
  80134a:	e8 5a fa ff ff       	call   800da9 <sys_page_alloc>
  80134f:	85 c0                	test   %eax,%eax
  801351:	74 1c                	je     80136f <fork+0x221>
			panic("fork: sys_page_alloc error");
  801353:	c7 44 24 08 ee 2a 80 	movl   $0x802aee,0x8(%esp)
  80135a:	00 
  80135b:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801362:	00 
  801363:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  80136a:	e8 3a ee ff ff       	call   8001a9 <_panic>
		extern void _pgfault_upcall();
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80136f:	c7 44 24 04 ff 22 80 	movl   $0x8022ff,0x4(%esp)
  801376:	00 
  801377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80137a:	89 3c 24             	mov    %edi,(%esp)
  80137d:	e8 c7 fb ff ff       	call   800f49 <sys_env_set_pgfault_upcall>
		if(sys_env_set_status(envid, ENV_RUNNABLE))
  801382:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801389:	00 
  80138a:	89 3c 24             	mov    %edi,(%esp)
  80138d:	e8 11 fb ff ff       	call   800ea3 <sys_env_set_status>
  801392:	85 c0                	test   %eax,%eax
  801394:	74 1c                	je     8013b2 <fork+0x264>
			panic("fork: sys_env_set_status error");
  801396:	c7 44 24 08 54 2a 80 	movl   $0x802a54,0x8(%esp)
  80139d:	00 
  80139e:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8013a5:	00 
  8013a6:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  8013ad:	e8 f7 ed ff ff       	call   8001a9 <_panic>
	}
	return envid;
}
  8013b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013b5:	83 c4 2c             	add    $0x2c,%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5e                   	pop    %esi
  8013ba:	5f                   	pop    %edi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <sfork>:

// Challenge!
int
sfork(void)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013c3:	c7 44 24 08 09 2b 80 	movl   $0x802b09,0x8(%esp)
  8013ca:	00 
  8013cb:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  8013d2:	00 
  8013d3:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  8013da:	e8 ca ed ff ff       	call   8001a9 <_panic>

008013df <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	56                   	push   %esi
  8013e3:	53                   	push   %ebx
  8013e4:	83 ec 10             	sub    $0x10,%esp
  8013e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8013ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  8013ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f0:	89 04 24             	mov    %eax,(%esp)
  8013f3:	e8 c7 fb ff ff       	call   800fbf <sys_ipc_recv>
	if(from_env_store)
  8013f8:	85 f6                	test   %esi,%esi
  8013fa:	74 14                	je     801410 <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  8013fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801401:	85 c0                	test   %eax,%eax
  801403:	78 09                	js     80140e <ipc_recv+0x2f>
  801405:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80140b:	8b 52 74             	mov    0x74(%edx),%edx
  80140e:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  801410:	85 db                	test   %ebx,%ebx
  801412:	74 14                	je     801428 <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  801414:	ba 00 00 00 00       	mov    $0x0,%edx
  801419:	85 c0                	test   %eax,%eax
  80141b:	78 09                	js     801426 <ipc_recv+0x47>
  80141d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801423:	8b 52 78             	mov    0x78(%edx),%edx
  801426:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 08                	js     801434 <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  80142c:	a1 04 40 80 00       	mov    0x804004,%eax
  801431:	8b 40 70             	mov    0x70(%eax),%eax
}
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	5b                   	pop    %ebx
  801438:	5e                   	pop    %esi
  801439:	5d                   	pop    %ebp
  80143a:	c3                   	ret    

0080143b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	57                   	push   %edi
  80143f:	56                   	push   %esi
  801440:	53                   	push   %ebx
  801441:	83 ec 1c             	sub    $0x1c,%esp
  801444:	8b 7d 08             	mov    0x8(%ebp),%edi
  801447:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  80144a:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  80144f:	eb 0c                	jmp    80145d <ipc_send+0x22>
		failed_cnt++;
  801451:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  801454:	84 db                	test   %bl,%bl
  801456:	75 05                	jne    80145d <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  801458:	e8 2d f9 ff ff       	call   800d8a <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  80145d:	8b 45 14             	mov    0x14(%ebp),%eax
  801460:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801464:	8b 45 10             	mov    0x10(%ebp),%eax
  801467:	89 44 24 08          	mov    %eax,0x8(%esp)
  80146b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80146f:	89 3c 24             	mov    %edi,(%esp)
  801472:	e8 25 fb ff ff       	call   800f9c <sys_ipc_try_send>
  801477:	85 c0                	test   %eax,%eax
  801479:	78 d6                	js     801451 <ipc_send+0x16>
	}
}
  80147b:	83 c4 1c             	add    $0x1c,%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5e                   	pop    %esi
  801480:	5f                   	pop    %edi
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    

00801483 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801489:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80148e:	39 c8                	cmp    %ecx,%eax
  801490:	74 17                	je     8014a9 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  801492:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801497:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80149a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014a0:	8b 52 50             	mov    0x50(%edx),%edx
  8014a3:	39 ca                	cmp    %ecx,%edx
  8014a5:	75 14                	jne    8014bb <ipc_find_env+0x38>
  8014a7:	eb 05                	jmp    8014ae <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  8014a9:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  8014ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8014b1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8014b6:	8b 40 40             	mov    0x40(%eax),%eax
  8014b9:	eb 0e                	jmp    8014c9 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  8014bb:	83 c0 01             	add    $0x1,%eax
  8014be:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014c3:	75 d2                	jne    801497 <ipc_find_env+0x14>
	return 0;
  8014c5:	66 b8 00 00          	mov    $0x0,%ax
}
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    
  8014cb:	66 90                	xchg   %ax,%ax
  8014cd:	66 90                	xchg   %ax,%ax
  8014cf:	90                   	nop

008014d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8014db:	c1 e8 0c             	shr    $0xc,%eax
}
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8014eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014f0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014f5:	5d                   	pop    %ebp
  8014f6:	c3                   	ret    

008014f7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014fa:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8014ff:	a8 01                	test   $0x1,%al
  801501:	74 34                	je     801537 <fd_alloc+0x40>
  801503:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801508:	a8 01                	test   $0x1,%al
  80150a:	74 32                	je     80153e <fd_alloc+0x47>
  80150c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  801511:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801513:	89 c2                	mov    %eax,%edx
  801515:	c1 ea 16             	shr    $0x16,%edx
  801518:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80151f:	f6 c2 01             	test   $0x1,%dl
  801522:	74 1f                	je     801543 <fd_alloc+0x4c>
  801524:	89 c2                	mov    %eax,%edx
  801526:	c1 ea 0c             	shr    $0xc,%edx
  801529:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801530:	f6 c2 01             	test   $0x1,%dl
  801533:	75 1a                	jne    80154f <fd_alloc+0x58>
  801535:	eb 0c                	jmp    801543 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  801537:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80153c:	eb 05                	jmp    801543 <fd_alloc+0x4c>
  80153e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  801543:	8b 45 08             	mov    0x8(%ebp),%eax
  801546:	89 08                	mov    %ecx,(%eax)
			return 0;
  801548:	b8 00 00 00 00       	mov    $0x0,%eax
  80154d:	eb 1a                	jmp    801569 <fd_alloc+0x72>
  80154f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801554:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801559:	75 b6                	jne    801511 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  80155b:	8b 45 08             	mov    0x8(%ebp),%eax
  80155e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801564:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    

0080156b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801571:	83 f8 1f             	cmp    $0x1f,%eax
  801574:	77 36                	ja     8015ac <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801576:	c1 e0 0c             	shl    $0xc,%eax
  801579:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80157e:	89 c2                	mov    %eax,%edx
  801580:	c1 ea 16             	shr    $0x16,%edx
  801583:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80158a:	f6 c2 01             	test   $0x1,%dl
  80158d:	74 24                	je     8015b3 <fd_lookup+0x48>
  80158f:	89 c2                	mov    %eax,%edx
  801591:	c1 ea 0c             	shr    $0xc,%edx
  801594:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80159b:	f6 c2 01             	test   $0x1,%dl
  80159e:	74 1a                	je     8015ba <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015a3:	89 02                	mov    %eax,(%edx)
	return 0;
  8015a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8015aa:	eb 13                	jmp    8015bf <fd_lookup+0x54>
		return -E_INVAL;
  8015ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b1:	eb 0c                	jmp    8015bf <fd_lookup+0x54>
		return -E_INVAL;
  8015b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b8:	eb 05                	jmp    8015bf <fd_lookup+0x54>
  8015ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015bf:	5d                   	pop    %ebp
  8015c0:	c3                   	ret    

008015c1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	53                   	push   %ebx
  8015c5:	83 ec 14             	sub    $0x14,%esp
  8015c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8015ce:	39 05 04 30 80 00    	cmp    %eax,0x803004
  8015d4:	75 1e                	jne    8015f4 <dev_lookup+0x33>
  8015d6:	eb 0e                	jmp    8015e6 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  8015d8:	b8 20 30 80 00       	mov    $0x803020,%eax
  8015dd:	eb 0c                	jmp    8015eb <dev_lookup+0x2a>
  8015df:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  8015e4:	eb 05                	jmp    8015eb <dev_lookup+0x2a>
  8015e6:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  8015eb:	89 03                	mov    %eax,(%ebx)
			return 0;
  8015ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f2:	eb 38                	jmp    80162c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  8015f4:	39 05 20 30 80 00    	cmp    %eax,0x803020
  8015fa:	74 dc                	je     8015d8 <dev_lookup+0x17>
  8015fc:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  801602:	74 db                	je     8015df <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801604:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80160a:	8b 52 48             	mov    0x48(%edx),%edx
  80160d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801611:	89 54 24 04          	mov    %edx,0x4(%esp)
  801615:	c7 04 24 20 2b 80 00 	movl   $0x802b20,(%esp)
  80161c:	e8 81 ec ff ff       	call   8002a2 <cprintf>
	*dev = 0;
  801621:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801627:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80162c:	83 c4 14             	add    $0x14,%esp
  80162f:	5b                   	pop    %ebx
  801630:	5d                   	pop    %ebp
  801631:	c3                   	ret    

00801632 <fd_close>:
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	56                   	push   %esi
  801636:	53                   	push   %ebx
  801637:	83 ec 20             	sub    $0x20,%esp
  80163a:	8b 75 08             	mov    0x8(%ebp),%esi
  80163d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801640:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801643:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801647:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80164d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801650:	89 04 24             	mov    %eax,(%esp)
  801653:	e8 13 ff ff ff       	call   80156b <fd_lookup>
  801658:	85 c0                	test   %eax,%eax
  80165a:	78 05                	js     801661 <fd_close+0x2f>
	    || fd != fd2)
  80165c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80165f:	74 0c                	je     80166d <fd_close+0x3b>
		return (must_exist ? r : 0);
  801661:	84 db                	test   %bl,%bl
  801663:	ba 00 00 00 00       	mov    $0x0,%edx
  801668:	0f 44 c2             	cmove  %edx,%eax
  80166b:	eb 3f                	jmp    8016ac <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80166d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801670:	89 44 24 04          	mov    %eax,0x4(%esp)
  801674:	8b 06                	mov    (%esi),%eax
  801676:	89 04 24             	mov    %eax,(%esp)
  801679:	e8 43 ff ff ff       	call   8015c1 <dev_lookup>
  80167e:	89 c3                	mov    %eax,%ebx
  801680:	85 c0                	test   %eax,%eax
  801682:	78 16                	js     80169a <fd_close+0x68>
		if (dev->dev_close)
  801684:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801687:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80168a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80168f:	85 c0                	test   %eax,%eax
  801691:	74 07                	je     80169a <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801693:	89 34 24             	mov    %esi,(%esp)
  801696:	ff d0                	call   *%eax
  801698:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  80169a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80169e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a5:	e8 a6 f7 ff ff       	call   800e50 <sys_page_unmap>
	return r;
  8016aa:	89 d8                	mov    %ebx,%eax
}
  8016ac:	83 c4 20             	add    $0x20,%esp
  8016af:	5b                   	pop    %ebx
  8016b0:	5e                   	pop    %esi
  8016b1:	5d                   	pop    %ebp
  8016b2:	c3                   	ret    

008016b3 <close>:

int
close(int fdnum)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c3:	89 04 24             	mov    %eax,(%esp)
  8016c6:	e8 a0 fe ff ff       	call   80156b <fd_lookup>
  8016cb:	89 c2                	mov    %eax,%edx
  8016cd:	85 d2                	test   %edx,%edx
  8016cf:	78 13                	js     8016e4 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8016d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016d8:	00 
  8016d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016dc:	89 04 24             	mov    %eax,(%esp)
  8016df:	e8 4e ff ff ff       	call   801632 <fd_close>
}
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <close_all>:

void
close_all(void)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	53                   	push   %ebx
  8016ea:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016f2:	89 1c 24             	mov    %ebx,(%esp)
  8016f5:	e8 b9 ff ff ff       	call   8016b3 <close>
	for (i = 0; i < MAXFD; i++)
  8016fa:	83 c3 01             	add    $0x1,%ebx
  8016fd:	83 fb 20             	cmp    $0x20,%ebx
  801700:	75 f0                	jne    8016f2 <close_all+0xc>
}
  801702:	83 c4 14             	add    $0x14,%esp
  801705:	5b                   	pop    %ebx
  801706:	5d                   	pop    %ebp
  801707:	c3                   	ret    

00801708 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	57                   	push   %edi
  80170c:	56                   	push   %esi
  80170d:	53                   	push   %ebx
  80170e:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801711:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801714:	89 44 24 04          	mov    %eax,0x4(%esp)
  801718:	8b 45 08             	mov    0x8(%ebp),%eax
  80171b:	89 04 24             	mov    %eax,(%esp)
  80171e:	e8 48 fe ff ff       	call   80156b <fd_lookup>
  801723:	89 c2                	mov    %eax,%edx
  801725:	85 d2                	test   %edx,%edx
  801727:	0f 88 e1 00 00 00    	js     80180e <dup+0x106>
		return r;
	close(newfdnum);
  80172d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801730:	89 04 24             	mov    %eax,(%esp)
  801733:	e8 7b ff ff ff       	call   8016b3 <close>

	newfd = INDEX2FD(newfdnum);
  801738:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80173b:	c1 e3 0c             	shl    $0xc,%ebx
  80173e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801744:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801747:	89 04 24             	mov    %eax,(%esp)
  80174a:	e8 91 fd ff ff       	call   8014e0 <fd2data>
  80174f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801751:	89 1c 24             	mov    %ebx,(%esp)
  801754:	e8 87 fd ff ff       	call   8014e0 <fd2data>
  801759:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80175b:	89 f0                	mov    %esi,%eax
  80175d:	c1 e8 16             	shr    $0x16,%eax
  801760:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801767:	a8 01                	test   $0x1,%al
  801769:	74 43                	je     8017ae <dup+0xa6>
  80176b:	89 f0                	mov    %esi,%eax
  80176d:	c1 e8 0c             	shr    $0xc,%eax
  801770:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801777:	f6 c2 01             	test   $0x1,%dl
  80177a:	74 32                	je     8017ae <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80177c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801783:	25 07 0e 00 00       	and    $0xe07,%eax
  801788:	89 44 24 10          	mov    %eax,0x10(%esp)
  80178c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801790:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801797:	00 
  801798:	89 74 24 04          	mov    %esi,0x4(%esp)
  80179c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a3:	e8 55 f6 ff ff       	call   800dfd <sys_page_map>
  8017a8:	89 c6                	mov    %eax,%esi
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	78 3e                	js     8017ec <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017b1:	89 c2                	mov    %eax,%edx
  8017b3:	c1 ea 0c             	shr    $0xc,%edx
  8017b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017bd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017c3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017c7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8017cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017d2:	00 
  8017d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017de:	e8 1a f6 ff ff       	call   800dfd <sys_page_map>
  8017e3:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8017e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017e8:	85 f6                	test   %esi,%esi
  8017ea:	79 22                	jns    80180e <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8017ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f7:	e8 54 f6 ff ff       	call   800e50 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801800:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801807:	e8 44 f6 ff ff       	call   800e50 <sys_page_unmap>
	return r;
  80180c:	89 f0                	mov    %esi,%eax
}
  80180e:	83 c4 3c             	add    $0x3c,%esp
  801811:	5b                   	pop    %ebx
  801812:	5e                   	pop    %esi
  801813:	5f                   	pop    %edi
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	53                   	push   %ebx
  80181a:	83 ec 24             	sub    $0x24,%esp
  80181d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801820:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801823:	89 44 24 04          	mov    %eax,0x4(%esp)
  801827:	89 1c 24             	mov    %ebx,(%esp)
  80182a:	e8 3c fd ff ff       	call   80156b <fd_lookup>
  80182f:	89 c2                	mov    %eax,%edx
  801831:	85 d2                	test   %edx,%edx
  801833:	78 6d                	js     8018a2 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801835:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183f:	8b 00                	mov    (%eax),%eax
  801841:	89 04 24             	mov    %eax,(%esp)
  801844:	e8 78 fd ff ff       	call   8015c1 <dev_lookup>
  801849:	85 c0                	test   %eax,%eax
  80184b:	78 55                	js     8018a2 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80184d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801850:	8b 50 08             	mov    0x8(%eax),%edx
  801853:	83 e2 03             	and    $0x3,%edx
  801856:	83 fa 01             	cmp    $0x1,%edx
  801859:	75 23                	jne    80187e <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80185b:	a1 04 40 80 00       	mov    0x804004,%eax
  801860:	8b 40 48             	mov    0x48(%eax),%eax
  801863:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801867:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186b:	c7 04 24 61 2b 80 00 	movl   $0x802b61,(%esp)
  801872:	e8 2b ea ff ff       	call   8002a2 <cprintf>
		return -E_INVAL;
  801877:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80187c:	eb 24                	jmp    8018a2 <read+0x8c>
	}
	if (!dev->dev_read)
  80187e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801881:	8b 52 08             	mov    0x8(%edx),%edx
  801884:	85 d2                	test   %edx,%edx
  801886:	74 15                	je     80189d <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801888:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80188b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80188f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801892:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801896:	89 04 24             	mov    %eax,(%esp)
  801899:	ff d2                	call   *%edx
  80189b:	eb 05                	jmp    8018a2 <read+0x8c>
		return -E_NOT_SUPP;
  80189d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8018a2:	83 c4 24             	add    $0x24,%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5d                   	pop    %ebp
  8018a7:	c3                   	ret    

008018a8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	57                   	push   %edi
  8018ac:	56                   	push   %esi
  8018ad:	53                   	push   %ebx
  8018ae:	83 ec 1c             	sub    $0x1c,%esp
  8018b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018b4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018b7:	85 f6                	test   %esi,%esi
  8018b9:	74 33                	je     8018ee <readn+0x46>
  8018bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c0:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018c5:	89 f2                	mov    %esi,%edx
  8018c7:	29 c2                	sub    %eax,%edx
  8018c9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018cd:	03 45 0c             	add    0xc(%ebp),%eax
  8018d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d4:	89 3c 24             	mov    %edi,(%esp)
  8018d7:	e8 3a ff ff ff       	call   801816 <read>
		if (m < 0)
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 1b                	js     8018fb <readn+0x53>
			return m;
		if (m == 0)
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	74 11                	je     8018f5 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  8018e4:	01 c3                	add    %eax,%ebx
  8018e6:	89 d8                	mov    %ebx,%eax
  8018e8:	39 f3                	cmp    %esi,%ebx
  8018ea:	72 d9                	jb     8018c5 <readn+0x1d>
  8018ec:	eb 0b                	jmp    8018f9 <readn+0x51>
  8018ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f3:	eb 06                	jmp    8018fb <readn+0x53>
  8018f5:	89 d8                	mov    %ebx,%eax
  8018f7:	eb 02                	jmp    8018fb <readn+0x53>
  8018f9:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8018fb:	83 c4 1c             	add    $0x1c,%esp
  8018fe:	5b                   	pop    %ebx
  8018ff:	5e                   	pop    %esi
  801900:	5f                   	pop    %edi
  801901:	5d                   	pop    %ebp
  801902:	c3                   	ret    

00801903 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	53                   	push   %ebx
  801907:	83 ec 24             	sub    $0x24,%esp
  80190a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80190d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801910:	89 44 24 04          	mov    %eax,0x4(%esp)
  801914:	89 1c 24             	mov    %ebx,(%esp)
  801917:	e8 4f fc ff ff       	call   80156b <fd_lookup>
  80191c:	89 c2                	mov    %eax,%edx
  80191e:	85 d2                	test   %edx,%edx
  801920:	78 68                	js     80198a <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801922:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801925:	89 44 24 04          	mov    %eax,0x4(%esp)
  801929:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192c:	8b 00                	mov    (%eax),%eax
  80192e:	89 04 24             	mov    %eax,(%esp)
  801931:	e8 8b fc ff ff       	call   8015c1 <dev_lookup>
  801936:	85 c0                	test   %eax,%eax
  801938:	78 50                	js     80198a <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80193a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801941:	75 23                	jne    801966 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801943:	a1 04 40 80 00       	mov    0x804004,%eax
  801948:	8b 40 48             	mov    0x48(%eax),%eax
  80194b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80194f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801953:	c7 04 24 7d 2b 80 00 	movl   $0x802b7d,(%esp)
  80195a:	e8 43 e9 ff ff       	call   8002a2 <cprintf>
		return -E_INVAL;
  80195f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801964:	eb 24                	jmp    80198a <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801966:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801969:	8b 52 0c             	mov    0xc(%edx),%edx
  80196c:	85 d2                	test   %edx,%edx
  80196e:	74 15                	je     801985 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801970:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801973:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801977:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80197a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80197e:	89 04 24             	mov    %eax,(%esp)
  801981:	ff d2                	call   *%edx
  801983:	eb 05                	jmp    80198a <write+0x87>
		return -E_NOT_SUPP;
  801985:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80198a:	83 c4 24             	add    $0x24,%esp
  80198d:	5b                   	pop    %ebx
  80198e:	5d                   	pop    %ebp
  80198f:	c3                   	ret    

00801990 <seek>:

int
seek(int fdnum, off_t offset)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801996:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801999:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199d:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a0:	89 04 24             	mov    %eax,(%esp)
  8019a3:	e8 c3 fb ff ff       	call   80156b <fd_lookup>
  8019a8:	85 c0                	test   %eax,%eax
  8019aa:	78 0e                	js     8019ba <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8019ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8019af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8019b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019ba:	c9                   	leave  
  8019bb:	c3                   	ret    

008019bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	53                   	push   %ebx
  8019c0:	83 ec 24             	sub    $0x24,%esp
  8019c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cd:	89 1c 24             	mov    %ebx,(%esp)
  8019d0:	e8 96 fb ff ff       	call   80156b <fd_lookup>
  8019d5:	89 c2                	mov    %eax,%edx
  8019d7:	85 d2                	test   %edx,%edx
  8019d9:	78 61                	js     801a3c <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e5:	8b 00                	mov    (%eax),%eax
  8019e7:	89 04 24             	mov    %eax,(%esp)
  8019ea:	e8 d2 fb ff ff       	call   8015c1 <dev_lookup>
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	78 49                	js     801a3c <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019f6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019fa:	75 23                	jne    801a1f <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019fc:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a01:	8b 40 48             	mov    0x48(%eax),%eax
  801a04:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0c:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  801a13:	e8 8a e8 ff ff       	call   8002a2 <cprintf>
		return -E_INVAL;
  801a18:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a1d:	eb 1d                	jmp    801a3c <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801a1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a22:	8b 52 18             	mov    0x18(%edx),%edx
  801a25:	85 d2                	test   %edx,%edx
  801a27:	74 0e                	je     801a37 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a2c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a30:	89 04 24             	mov    %eax,(%esp)
  801a33:	ff d2                	call   *%edx
  801a35:	eb 05                	jmp    801a3c <ftruncate+0x80>
		return -E_NOT_SUPP;
  801a37:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801a3c:	83 c4 24             	add    $0x24,%esp
  801a3f:	5b                   	pop    %ebx
  801a40:	5d                   	pop    %ebp
  801a41:	c3                   	ret    

00801a42 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	53                   	push   %ebx
  801a46:	83 ec 24             	sub    $0x24,%esp
  801a49:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a4c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a53:	8b 45 08             	mov    0x8(%ebp),%eax
  801a56:	89 04 24             	mov    %eax,(%esp)
  801a59:	e8 0d fb ff ff       	call   80156b <fd_lookup>
  801a5e:	89 c2                	mov    %eax,%edx
  801a60:	85 d2                	test   %edx,%edx
  801a62:	78 52                	js     801ab6 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a6e:	8b 00                	mov    (%eax),%eax
  801a70:	89 04 24             	mov    %eax,(%esp)
  801a73:	e8 49 fb ff ff       	call   8015c1 <dev_lookup>
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	78 3a                	js     801ab6 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a83:	74 2c                	je     801ab1 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a85:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a88:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a8f:	00 00 00 
	stat->st_isdir = 0;
  801a92:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a99:	00 00 00 
	stat->st_dev = dev;
  801a9c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801aa2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aa6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801aa9:	89 14 24             	mov    %edx,(%esp)
  801aac:	ff 50 14             	call   *0x14(%eax)
  801aaf:	eb 05                	jmp    801ab6 <fstat+0x74>
		return -E_NOT_SUPP;
  801ab1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801ab6:	83 c4 24             	add    $0x24,%esp
  801ab9:	5b                   	pop    %ebx
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ac4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801acb:	00 
  801acc:	8b 45 08             	mov    0x8(%ebp),%eax
  801acf:	89 04 24             	mov    %eax,(%esp)
  801ad2:	e8 af 01 00 00       	call   801c86 <open>
  801ad7:	89 c3                	mov    %eax,%ebx
  801ad9:	85 db                	test   %ebx,%ebx
  801adb:	78 1b                	js     801af8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801add:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae4:	89 1c 24             	mov    %ebx,(%esp)
  801ae7:	e8 56 ff ff ff       	call   801a42 <fstat>
  801aec:	89 c6                	mov    %eax,%esi
	close(fd);
  801aee:	89 1c 24             	mov    %ebx,(%esp)
  801af1:	e8 bd fb ff ff       	call   8016b3 <close>
	return r;
  801af6:	89 f0                	mov    %esi,%eax
}
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	5b                   	pop    %ebx
  801afc:	5e                   	pop    %esi
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    

00801aff <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	83 ec 10             	sub    $0x10,%esp
  801b07:	89 c6                	mov    %eax,%esi
  801b09:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801b0b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801b12:	75 11                	jne    801b25 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b14:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b1b:	e8 63 f9 ff ff       	call   801483 <ipc_find_env>
  801b20:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b25:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b2c:	00 
  801b2d:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b34:	00 
  801b35:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b39:	a1 00 40 80 00       	mov    0x804000,%eax
  801b3e:	89 04 24             	mov    %eax,(%esp)
  801b41:	e8 f5 f8 ff ff       	call   80143b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b4d:	00 
  801b4e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b59:	e8 81 f8 ff ff       	call   8013df <ipc_recv>
}
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	5b                   	pop    %ebx
  801b62:	5e                   	pop    %esi
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	53                   	push   %ebx
  801b69:	83 ec 14             	sub    $0x14,%esp
  801b6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b72:	8b 40 0c             	mov    0xc(%eax),%eax
  801b75:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b7f:	b8 05 00 00 00       	mov    $0x5,%eax
  801b84:	e8 76 ff ff ff       	call   801aff <fsipc>
  801b89:	89 c2                	mov    %eax,%edx
  801b8b:	85 d2                	test   %edx,%edx
  801b8d:	78 2b                	js     801bba <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b8f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b96:	00 
  801b97:	89 1c 24             	mov    %ebx,(%esp)
  801b9a:	e8 5c ed ff ff       	call   8008fb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b9f:	a1 80 50 80 00       	mov    0x805080,%eax
  801ba4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801baa:	a1 84 50 80 00       	mov    0x805084,%eax
  801baf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bba:	83 c4 14             	add    $0x14,%esp
  801bbd:	5b                   	pop    %ebx
  801bbe:	5d                   	pop    %ebp
  801bbf:	c3                   	ret    

00801bc0 <devfile_flush>:
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc9:	8b 40 0c             	mov    0xc(%eax),%eax
  801bcc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801bd1:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd6:	b8 06 00 00 00       	mov    $0x6,%eax
  801bdb:	e8 1f ff ff ff       	call   801aff <fsipc>
}
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <devfile_read>:
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	56                   	push   %esi
  801be6:	53                   	push   %ebx
  801be7:	83 ec 10             	sub    $0x10,%esp
  801bea:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bed:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf0:	8b 40 0c             	mov    0xc(%eax),%eax
  801bf3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801bf8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bfe:	ba 00 00 00 00       	mov    $0x0,%edx
  801c03:	b8 03 00 00 00       	mov    $0x3,%eax
  801c08:	e8 f2 fe ff ff       	call   801aff <fsipc>
  801c0d:	89 c3                	mov    %eax,%ebx
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	78 6a                	js     801c7d <devfile_read+0x9b>
	assert(r <= n);
  801c13:	39 c6                	cmp    %eax,%esi
  801c15:	73 24                	jae    801c3b <devfile_read+0x59>
  801c17:	c7 44 24 0c 9a 2b 80 	movl   $0x802b9a,0xc(%esp)
  801c1e:	00 
  801c1f:	c7 44 24 08 a1 2b 80 	movl   $0x802ba1,0x8(%esp)
  801c26:	00 
  801c27:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  801c2e:	00 
  801c2f:	c7 04 24 b6 2b 80 00 	movl   $0x802bb6,(%esp)
  801c36:	e8 6e e5 ff ff       	call   8001a9 <_panic>
	assert(r <= PGSIZE);
  801c3b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c40:	7e 24                	jle    801c66 <devfile_read+0x84>
  801c42:	c7 44 24 0c c1 2b 80 	movl   $0x802bc1,0xc(%esp)
  801c49:	00 
  801c4a:	c7 44 24 08 a1 2b 80 	movl   $0x802ba1,0x8(%esp)
  801c51:	00 
  801c52:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801c59:	00 
  801c5a:	c7 04 24 b6 2b 80 00 	movl   $0x802bb6,(%esp)
  801c61:	e8 43 e5 ff ff       	call   8001a9 <_panic>
	memmove(buf, &fsipcbuf, r);
  801c66:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c6a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c71:	00 
  801c72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c75:	89 04 24             	mov    %eax,(%esp)
  801c78:	e8 79 ee ff ff       	call   800af6 <memmove>
}
  801c7d:	89 d8                	mov    %ebx,%eax
  801c7f:	83 c4 10             	add    $0x10,%esp
  801c82:	5b                   	pop    %ebx
  801c83:	5e                   	pop    %esi
  801c84:	5d                   	pop    %ebp
  801c85:	c3                   	ret    

00801c86 <open>:
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	53                   	push   %ebx
  801c8a:	83 ec 24             	sub    $0x24,%esp
  801c8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801c90:	89 1c 24             	mov    %ebx,(%esp)
  801c93:	e8 08 ec ff ff       	call   8008a0 <strlen>
  801c98:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c9d:	7f 60                	jg     801cff <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801c9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca2:	89 04 24             	mov    %eax,(%esp)
  801ca5:	e8 4d f8 ff ff       	call   8014f7 <fd_alloc>
  801caa:	89 c2                	mov    %eax,%edx
  801cac:	85 d2                	test   %edx,%edx
  801cae:	78 54                	js     801d04 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801cb0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cb4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801cbb:	e8 3b ec ff ff       	call   8008fb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ccb:	b8 01 00 00 00       	mov    $0x1,%eax
  801cd0:	e8 2a fe ff ff       	call   801aff <fsipc>
  801cd5:	89 c3                	mov    %eax,%ebx
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	79 17                	jns    801cf2 <open+0x6c>
		fd_close(fd, 0);
  801cdb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ce2:	00 
  801ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce6:	89 04 24             	mov    %eax,(%esp)
  801ce9:	e8 44 f9 ff ff       	call   801632 <fd_close>
		return r;
  801cee:	89 d8                	mov    %ebx,%eax
  801cf0:	eb 12                	jmp    801d04 <open+0x7e>
	return fd2num(fd);
  801cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf5:	89 04 24             	mov    %eax,(%esp)
  801cf8:	e8 d3 f7 ff ff       	call   8014d0 <fd2num>
  801cfd:	eb 05                	jmp    801d04 <open+0x7e>
		return -E_BAD_PATH;
  801cff:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801d04:	83 c4 24             	add    $0x24,%esp
  801d07:	5b                   	pop    %ebx
  801d08:	5d                   	pop    %ebp
  801d09:	c3                   	ret    
  801d0a:	66 90                	xchg   %ax,%ax
  801d0c:	66 90                	xchg   %ax,%ax
  801d0e:	66 90                	xchg   %ax,%ax

00801d10 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	56                   	push   %esi
  801d14:	53                   	push   %ebx
  801d15:	83 ec 10             	sub    $0x10,%esp
  801d18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1e:	89 04 24             	mov    %eax,(%esp)
  801d21:	e8 ba f7 ff ff       	call   8014e0 <fd2data>
  801d26:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d28:	c7 44 24 04 cd 2b 80 	movl   $0x802bcd,0x4(%esp)
  801d2f:	00 
  801d30:	89 1c 24             	mov    %ebx,(%esp)
  801d33:	e8 c3 eb ff ff       	call   8008fb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d38:	8b 46 04             	mov    0x4(%esi),%eax
  801d3b:	2b 06                	sub    (%esi),%eax
  801d3d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d43:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d4a:	00 00 00 
	stat->st_dev = &devpipe;
  801d4d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801d54:	30 80 00 
	return 0;
}
  801d57:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	5b                   	pop    %ebx
  801d60:	5e                   	pop    %esi
  801d61:	5d                   	pop    %ebp
  801d62:	c3                   	ret    

00801d63 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	53                   	push   %ebx
  801d67:	83 ec 14             	sub    $0x14,%esp
  801d6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d6d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d78:	e8 d3 f0 ff ff       	call   800e50 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d7d:	89 1c 24             	mov    %ebx,(%esp)
  801d80:	e8 5b f7 ff ff       	call   8014e0 <fd2data>
  801d85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d90:	e8 bb f0 ff ff       	call   800e50 <sys_page_unmap>
}
  801d95:	83 c4 14             	add    $0x14,%esp
  801d98:	5b                   	pop    %ebx
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    

00801d9b <_pipeisclosed>:
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	57                   	push   %edi
  801d9f:	56                   	push   %esi
  801da0:	53                   	push   %ebx
  801da1:	83 ec 2c             	sub    $0x2c,%esp
  801da4:	89 c6                	mov    %eax,%esi
  801da6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801da9:	a1 04 40 80 00       	mov    0x804004,%eax
  801dae:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801db1:	89 34 24             	mov    %esi,(%esp)
  801db4:	e8 6a 05 00 00       	call   802323 <pageref>
  801db9:	89 c7                	mov    %eax,%edi
  801dbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dbe:	89 04 24             	mov    %eax,(%esp)
  801dc1:	e8 5d 05 00 00       	call   802323 <pageref>
  801dc6:	39 c7                	cmp    %eax,%edi
  801dc8:	0f 94 c2             	sete   %dl
  801dcb:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801dce:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801dd4:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801dd7:	39 fb                	cmp    %edi,%ebx
  801dd9:	74 21                	je     801dfc <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801ddb:	84 d2                	test   %dl,%dl
  801ddd:	74 ca                	je     801da9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ddf:	8b 51 58             	mov    0x58(%ecx),%edx
  801de2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801de6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dee:	c7 04 24 d4 2b 80 00 	movl   $0x802bd4,(%esp)
  801df5:	e8 a8 e4 ff ff       	call   8002a2 <cprintf>
  801dfa:	eb ad                	jmp    801da9 <_pipeisclosed+0xe>
}
  801dfc:	83 c4 2c             	add    $0x2c,%esp
  801dff:	5b                   	pop    %ebx
  801e00:	5e                   	pop    %esi
  801e01:	5f                   	pop    %edi
  801e02:	5d                   	pop    %ebp
  801e03:	c3                   	ret    

00801e04 <devpipe_write>:
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	57                   	push   %edi
  801e08:	56                   	push   %esi
  801e09:	53                   	push   %ebx
  801e0a:	83 ec 1c             	sub    $0x1c,%esp
  801e0d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801e10:	89 34 24             	mov    %esi,(%esp)
  801e13:	e8 c8 f6 ff ff       	call   8014e0 <fd2data>
	for (i = 0; i < n; i++) {
  801e18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e1c:	74 61                	je     801e7f <devpipe_write+0x7b>
  801e1e:	89 c3                	mov    %eax,%ebx
  801e20:	bf 00 00 00 00       	mov    $0x0,%edi
  801e25:	eb 4a                	jmp    801e71 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  801e27:	89 da                	mov    %ebx,%edx
  801e29:	89 f0                	mov    %esi,%eax
  801e2b:	e8 6b ff ff ff       	call   801d9b <_pipeisclosed>
  801e30:	85 c0                	test   %eax,%eax
  801e32:	75 54                	jne    801e88 <devpipe_write+0x84>
			sys_yield();
  801e34:	e8 51 ef ff ff       	call   800d8a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e39:	8b 43 04             	mov    0x4(%ebx),%eax
  801e3c:	8b 0b                	mov    (%ebx),%ecx
  801e3e:	8d 51 20             	lea    0x20(%ecx),%edx
  801e41:	39 d0                	cmp    %edx,%eax
  801e43:	73 e2                	jae    801e27 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e48:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e4c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e4f:	99                   	cltd   
  801e50:	c1 ea 1b             	shr    $0x1b,%edx
  801e53:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801e56:	83 e1 1f             	and    $0x1f,%ecx
  801e59:	29 d1                	sub    %edx,%ecx
  801e5b:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801e5f:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801e63:	83 c0 01             	add    $0x1,%eax
  801e66:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801e69:	83 c7 01             	add    $0x1,%edi
  801e6c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e6f:	74 13                	je     801e84 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e71:	8b 43 04             	mov    0x4(%ebx),%eax
  801e74:	8b 0b                	mov    (%ebx),%ecx
  801e76:	8d 51 20             	lea    0x20(%ecx),%edx
  801e79:	39 d0                	cmp    %edx,%eax
  801e7b:	73 aa                	jae    801e27 <devpipe_write+0x23>
  801e7d:	eb c6                	jmp    801e45 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  801e7f:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  801e84:	89 f8                	mov    %edi,%eax
  801e86:	eb 05                	jmp    801e8d <devpipe_write+0x89>
				return 0;
  801e88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e8d:	83 c4 1c             	add    $0x1c,%esp
  801e90:	5b                   	pop    %ebx
  801e91:	5e                   	pop    %esi
  801e92:	5f                   	pop    %edi
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    

00801e95 <devpipe_read>:
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	57                   	push   %edi
  801e99:	56                   	push   %esi
  801e9a:	53                   	push   %ebx
  801e9b:	83 ec 1c             	sub    $0x1c,%esp
  801e9e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801ea1:	89 3c 24             	mov    %edi,(%esp)
  801ea4:	e8 37 f6 ff ff       	call   8014e0 <fd2data>
	for (i = 0; i < n; i++) {
  801ea9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ead:	74 54                	je     801f03 <devpipe_read+0x6e>
  801eaf:	89 c3                	mov    %eax,%ebx
  801eb1:	be 00 00 00 00       	mov    $0x0,%esi
  801eb6:	eb 3e                	jmp    801ef6 <devpipe_read+0x61>
				return i;
  801eb8:	89 f0                	mov    %esi,%eax
  801eba:	eb 55                	jmp    801f11 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  801ebc:	89 da                	mov    %ebx,%edx
  801ebe:	89 f8                	mov    %edi,%eax
  801ec0:	e8 d6 fe ff ff       	call   801d9b <_pipeisclosed>
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	75 43                	jne    801f0c <devpipe_read+0x77>
			sys_yield();
  801ec9:	e8 bc ee ff ff       	call   800d8a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801ece:	8b 03                	mov    (%ebx),%eax
  801ed0:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ed3:	74 e7                	je     801ebc <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ed5:	99                   	cltd   
  801ed6:	c1 ea 1b             	shr    $0x1b,%edx
  801ed9:	01 d0                	add    %edx,%eax
  801edb:	83 e0 1f             	and    $0x1f,%eax
  801ede:	29 d0                	sub    %edx,%eax
  801ee0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ee5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ee8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801eeb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801eee:	83 c6 01             	add    $0x1,%esi
  801ef1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ef4:	74 12                	je     801f08 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  801ef6:	8b 03                	mov    (%ebx),%eax
  801ef8:	3b 43 04             	cmp    0x4(%ebx),%eax
  801efb:	75 d8                	jne    801ed5 <devpipe_read+0x40>
			if (i > 0)
  801efd:	85 f6                	test   %esi,%esi
  801eff:	75 b7                	jne    801eb8 <devpipe_read+0x23>
  801f01:	eb b9                	jmp    801ebc <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  801f03:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  801f08:	89 f0                	mov    %esi,%eax
  801f0a:	eb 05                	jmp    801f11 <devpipe_read+0x7c>
				return 0;
  801f0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f11:	83 c4 1c             	add    $0x1c,%esp
  801f14:	5b                   	pop    %ebx
  801f15:	5e                   	pop    %esi
  801f16:	5f                   	pop    %edi
  801f17:	5d                   	pop    %ebp
  801f18:	c3                   	ret    

00801f19 <pipe>:
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	56                   	push   %esi
  801f1d:	53                   	push   %ebx
  801f1e:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801f21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f24:	89 04 24             	mov    %eax,(%esp)
  801f27:	e8 cb f5 ff ff       	call   8014f7 <fd_alloc>
  801f2c:	89 c2                	mov    %eax,%edx
  801f2e:	85 d2                	test   %edx,%edx
  801f30:	0f 88 4d 01 00 00    	js     802083 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f36:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f3d:	00 
  801f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f41:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f4c:	e8 58 ee ff ff       	call   800da9 <sys_page_alloc>
  801f51:	89 c2                	mov    %eax,%edx
  801f53:	85 d2                	test   %edx,%edx
  801f55:	0f 88 28 01 00 00    	js     802083 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801f5b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f5e:	89 04 24             	mov    %eax,(%esp)
  801f61:	e8 91 f5 ff ff       	call   8014f7 <fd_alloc>
  801f66:	89 c3                	mov    %eax,%ebx
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	0f 88 fe 00 00 00    	js     80206e <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f70:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f77:	00 
  801f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f86:	e8 1e ee ff ff       	call   800da9 <sys_page_alloc>
  801f8b:	89 c3                	mov    %eax,%ebx
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	0f 88 d9 00 00 00    	js     80206e <pipe+0x155>
	va = fd2data(fd0);
  801f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f98:	89 04 24             	mov    %eax,(%esp)
  801f9b:	e8 40 f5 ff ff       	call   8014e0 <fd2data>
  801fa0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fa2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fa9:	00 
  801faa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb5:	e8 ef ed ff ff       	call   800da9 <sys_page_alloc>
  801fba:	89 c3                	mov    %eax,%ebx
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	0f 88 97 00 00 00    	js     80205b <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fc7:	89 04 24             	mov    %eax,(%esp)
  801fca:	e8 11 f5 ff ff       	call   8014e0 <fd2data>
  801fcf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801fd6:	00 
  801fd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fdb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fe2:	00 
  801fe3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fe7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fee:	e8 0a ee ff ff       	call   800dfd <sys_page_map>
  801ff3:	89 c3                	mov    %eax,%ebx
  801ff5:	85 c0                	test   %eax,%eax
  801ff7:	78 52                	js     80204b <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801ff9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802002:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802004:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802007:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  80200e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802014:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802017:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802019:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80201c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802023:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802026:	89 04 24             	mov    %eax,(%esp)
  802029:	e8 a2 f4 ff ff       	call   8014d0 <fd2num>
  80202e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802031:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802033:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802036:	89 04 24             	mov    %eax,(%esp)
  802039:	e8 92 f4 ff ff       	call   8014d0 <fd2num>
  80203e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802041:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802044:	b8 00 00 00 00       	mov    $0x0,%eax
  802049:	eb 38                	jmp    802083 <pipe+0x16a>
	sys_page_unmap(0, va);
  80204b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80204f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802056:	e8 f5 ed ff ff       	call   800e50 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  80205b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80205e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802069:	e8 e2 ed ff ff       	call   800e50 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  80206e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802071:	89 44 24 04          	mov    %eax,0x4(%esp)
  802075:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80207c:	e8 cf ed ff ff       	call   800e50 <sys_page_unmap>
  802081:	89 d8                	mov    %ebx,%eax
}
  802083:	83 c4 30             	add    $0x30,%esp
  802086:	5b                   	pop    %ebx
  802087:	5e                   	pop    %esi
  802088:	5d                   	pop    %ebp
  802089:	c3                   	ret    

0080208a <pipeisclosed>:
{
  80208a:	55                   	push   %ebp
  80208b:	89 e5                	mov    %esp,%ebp
  80208d:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802090:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802093:	89 44 24 04          	mov    %eax,0x4(%esp)
  802097:	8b 45 08             	mov    0x8(%ebp),%eax
  80209a:	89 04 24             	mov    %eax,(%esp)
  80209d:	e8 c9 f4 ff ff       	call   80156b <fd_lookup>
  8020a2:	89 c2                	mov    %eax,%edx
  8020a4:	85 d2                	test   %edx,%edx
  8020a6:	78 15                	js     8020bd <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  8020a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ab:	89 04 24             	mov    %eax,(%esp)
  8020ae:	e8 2d f4 ff ff       	call   8014e0 <fd2data>
	return _pipeisclosed(fd, p);
  8020b3:	89 c2                	mov    %eax,%edx
  8020b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b8:	e8 de fc ff ff       	call   801d9b <_pipeisclosed>
}
  8020bd:	c9                   	leave  
  8020be:	c3                   	ret    
  8020bf:	90                   	nop

008020c0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020c0:	55                   	push   %ebp
  8020c1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c8:	5d                   	pop    %ebp
  8020c9:	c3                   	ret    

008020ca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020ca:	55                   	push   %ebp
  8020cb:	89 e5                	mov    %esp,%ebp
  8020cd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8020d0:	c7 44 24 04 ec 2b 80 	movl   $0x802bec,0x4(%esp)
  8020d7:	00 
  8020d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020db:	89 04 24             	mov    %eax,(%esp)
  8020de:	e8 18 e8 ff ff       	call   8008fb <strcpy>
	return 0;
}
  8020e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8020e8:	c9                   	leave  
  8020e9:	c3                   	ret    

008020ea <devcons_write>:
{
  8020ea:	55                   	push   %ebp
  8020eb:	89 e5                	mov    %esp,%ebp
  8020ed:	57                   	push   %edi
  8020ee:	56                   	push   %esi
  8020ef:	53                   	push   %ebx
  8020f0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  8020f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020fa:	74 4a                	je     802146 <devcons_write+0x5c>
  8020fc:	b8 00 00 00 00       	mov    $0x0,%eax
  802101:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802106:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  80210c:	8b 75 10             	mov    0x10(%ebp),%esi
  80210f:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  802111:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  802114:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802119:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80211c:	89 74 24 08          	mov    %esi,0x8(%esp)
  802120:	03 45 0c             	add    0xc(%ebp),%eax
  802123:	89 44 24 04          	mov    %eax,0x4(%esp)
  802127:	89 3c 24             	mov    %edi,(%esp)
  80212a:	e8 c7 e9 ff ff       	call   800af6 <memmove>
		sys_cputs(buf, m);
  80212f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802133:	89 3c 24             	mov    %edi,(%esp)
  802136:	e8 a1 eb ff ff       	call   800cdc <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80213b:	01 f3                	add    %esi,%ebx
  80213d:	89 d8                	mov    %ebx,%eax
  80213f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802142:	72 c8                	jb     80210c <devcons_write+0x22>
  802144:	eb 05                	jmp    80214b <devcons_write+0x61>
  802146:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  80214b:	89 d8                	mov    %ebx,%eax
  80214d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    

00802158 <devcons_read>:
{
  802158:	55                   	push   %ebp
  802159:	89 e5                	mov    %esp,%ebp
  80215b:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80215e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802163:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802167:	75 07                	jne    802170 <devcons_read+0x18>
  802169:	eb 28                	jmp    802193 <devcons_read+0x3b>
		sys_yield();
  80216b:	e8 1a ec ff ff       	call   800d8a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802170:	e8 85 eb ff ff       	call   800cfa <sys_cgetc>
  802175:	85 c0                	test   %eax,%eax
  802177:	74 f2                	je     80216b <devcons_read+0x13>
	if (c < 0)
  802179:	85 c0                	test   %eax,%eax
  80217b:	78 16                	js     802193 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  80217d:	83 f8 04             	cmp    $0x4,%eax
  802180:	74 0c                	je     80218e <devcons_read+0x36>
	*(char*)vbuf = c;
  802182:	8b 55 0c             	mov    0xc(%ebp),%edx
  802185:	88 02                	mov    %al,(%edx)
	return 1;
  802187:	b8 01 00 00 00       	mov    $0x1,%eax
  80218c:	eb 05                	jmp    802193 <devcons_read+0x3b>
		return 0;
  80218e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802193:	c9                   	leave  
  802194:	c3                   	ret    

00802195 <cputchar>:
{
  802195:	55                   	push   %ebp
  802196:	89 e5                	mov    %esp,%ebp
  802198:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80219b:	8b 45 08             	mov    0x8(%ebp),%eax
  80219e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8021a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8021a8:	00 
  8021a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021ac:	89 04 24             	mov    %eax,(%esp)
  8021af:	e8 28 eb ff ff       	call   800cdc <sys_cputs>
}
  8021b4:	c9                   	leave  
  8021b5:	c3                   	ret    

008021b6 <getchar>:
{
  8021b6:	55                   	push   %ebp
  8021b7:	89 e5                	mov    %esp,%ebp
  8021b9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  8021bc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8021c3:	00 
  8021c4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021d2:	e8 3f f6 ff ff       	call   801816 <read>
	if (r < 0)
  8021d7:	85 c0                	test   %eax,%eax
  8021d9:	78 0f                	js     8021ea <getchar+0x34>
	if (r < 1)
  8021db:	85 c0                	test   %eax,%eax
  8021dd:	7e 06                	jle    8021e5 <getchar+0x2f>
	return c;
  8021df:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021e3:	eb 05                	jmp    8021ea <getchar+0x34>
		return -E_EOF;
  8021e5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  8021ea:	c9                   	leave  
  8021eb:	c3                   	ret    

008021ec <iscons>:
{
  8021ec:	55                   	push   %ebp
  8021ed:	89 e5                	mov    %esp,%ebp
  8021ef:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fc:	89 04 24             	mov    %eax,(%esp)
  8021ff:	e8 67 f3 ff ff       	call   80156b <fd_lookup>
  802204:	85 c0                	test   %eax,%eax
  802206:	78 11                	js     802219 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  802208:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802211:	39 10                	cmp    %edx,(%eax)
  802213:	0f 94 c0             	sete   %al
  802216:	0f b6 c0             	movzbl %al,%eax
}
  802219:	c9                   	leave  
  80221a:	c3                   	ret    

0080221b <opencons>:
{
  80221b:	55                   	push   %ebp
  80221c:	89 e5                	mov    %esp,%ebp
  80221e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802221:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802224:	89 04 24             	mov    %eax,(%esp)
  802227:	e8 cb f2 ff ff       	call   8014f7 <fd_alloc>
		return r;
  80222c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80222e:	85 c0                	test   %eax,%eax
  802230:	78 40                	js     802272 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802232:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802239:	00 
  80223a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802248:	e8 5c eb ff ff       	call   800da9 <sys_page_alloc>
		return r;
  80224d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80224f:	85 c0                	test   %eax,%eax
  802251:	78 1f                	js     802272 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  802253:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802259:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80225e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802261:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802268:	89 04 24             	mov    %eax,(%esp)
  80226b:	e8 60 f2 ff ff       	call   8014d0 <fd2num>
  802270:	89 c2                	mov    %eax,%edx
}
  802272:	89 d0                	mov    %edx,%eax
  802274:	c9                   	leave  
  802275:	c3                   	ret    

00802276 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802276:	55                   	push   %ebp
  802277:	89 e5                	mov    %esp,%ebp
  802279:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80227c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802283:	75 70                	jne    8022f5 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  802285:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80228c:	00 
  80228d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802294:	ee 
  802295:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80229c:	e8 08 eb ff ff       	call   800da9 <sys_page_alloc>
  8022a1:	85 c0                	test   %eax,%eax
  8022a3:	79 1c                	jns    8022c1 <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  8022a5:	c7 44 24 08 f8 2b 80 	movl   $0x802bf8,0x8(%esp)
  8022ac:	00 
  8022ad:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8022b4:	00 
  8022b5:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  8022bc:	e8 e8 de ff ff       	call   8001a9 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8022c1:	c7 44 24 04 ff 22 80 	movl   $0x8022ff,0x4(%esp)
  8022c8:	00 
  8022c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022d0:	e8 74 ec ff ff       	call   800f49 <sys_env_set_pgfault_upcall>
  8022d5:	85 c0                	test   %eax,%eax
  8022d7:	79 1c                	jns    8022f5 <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  8022d9:	c7 44 24 08 24 2c 80 	movl   $0x802c24,0x8(%esp)
  8022e0:	00 
  8022e1:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8022e8:	00 
  8022e9:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  8022f0:	e8 b4 de ff ff       	call   8001a9 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f8:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8022fd:	c9                   	leave  
  8022fe:	c3                   	ret    

008022ff <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022ff:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802300:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802305:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802307:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  80230a:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  80230e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  802313:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  802317:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802319:	83 c4 08             	add    $0x8,%esp
	popal
  80231c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80231d:	83 c4 04             	add    $0x4,%esp
	popfl
  802320:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802321:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802322:	c3                   	ret    

00802323 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802323:	55                   	push   %ebp
  802324:	89 e5                	mov    %esp,%ebp
  802326:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802329:	89 d0                	mov    %edx,%eax
  80232b:	c1 e8 16             	shr    $0x16,%eax
  80232e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802335:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80233a:	f6 c1 01             	test   $0x1,%cl
  80233d:	74 1d                	je     80235c <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  80233f:	c1 ea 0c             	shr    $0xc,%edx
  802342:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802349:	f6 c2 01             	test   $0x1,%dl
  80234c:	74 0e                	je     80235c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80234e:	c1 ea 0c             	shr    $0xc,%edx
  802351:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802358:	ef 
  802359:	0f b7 c0             	movzwl %ax,%eax
}
  80235c:	5d                   	pop    %ebp
  80235d:	c3                   	ret    
  80235e:	66 90                	xchg   %ax,%ax

00802360 <__udivdi3>:
  802360:	55                   	push   %ebp
  802361:	57                   	push   %edi
  802362:	56                   	push   %esi
  802363:	83 ec 0c             	sub    $0xc,%esp
  802366:	8b 44 24 28          	mov    0x28(%esp),%eax
  80236a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80236e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802372:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802376:	85 c0                	test   %eax,%eax
  802378:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80237c:	89 ea                	mov    %ebp,%edx
  80237e:	89 0c 24             	mov    %ecx,(%esp)
  802381:	75 2d                	jne    8023b0 <__udivdi3+0x50>
  802383:	39 e9                	cmp    %ebp,%ecx
  802385:	77 61                	ja     8023e8 <__udivdi3+0x88>
  802387:	85 c9                	test   %ecx,%ecx
  802389:	89 ce                	mov    %ecx,%esi
  80238b:	75 0b                	jne    802398 <__udivdi3+0x38>
  80238d:	b8 01 00 00 00       	mov    $0x1,%eax
  802392:	31 d2                	xor    %edx,%edx
  802394:	f7 f1                	div    %ecx
  802396:	89 c6                	mov    %eax,%esi
  802398:	31 d2                	xor    %edx,%edx
  80239a:	89 e8                	mov    %ebp,%eax
  80239c:	f7 f6                	div    %esi
  80239e:	89 c5                	mov    %eax,%ebp
  8023a0:	89 f8                	mov    %edi,%eax
  8023a2:	f7 f6                	div    %esi
  8023a4:	89 ea                	mov    %ebp,%edx
  8023a6:	83 c4 0c             	add    $0xc,%esp
  8023a9:	5e                   	pop    %esi
  8023aa:	5f                   	pop    %edi
  8023ab:	5d                   	pop    %ebp
  8023ac:	c3                   	ret    
  8023ad:	8d 76 00             	lea    0x0(%esi),%esi
  8023b0:	39 e8                	cmp    %ebp,%eax
  8023b2:	77 24                	ja     8023d8 <__udivdi3+0x78>
  8023b4:	0f bd e8             	bsr    %eax,%ebp
  8023b7:	83 f5 1f             	xor    $0x1f,%ebp
  8023ba:	75 3c                	jne    8023f8 <__udivdi3+0x98>
  8023bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8023c0:	39 34 24             	cmp    %esi,(%esp)
  8023c3:	0f 86 9f 00 00 00    	jbe    802468 <__udivdi3+0x108>
  8023c9:	39 d0                	cmp    %edx,%eax
  8023cb:	0f 82 97 00 00 00    	jb     802468 <__udivdi3+0x108>
  8023d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d8:	31 d2                	xor    %edx,%edx
  8023da:	31 c0                	xor    %eax,%eax
  8023dc:	83 c4 0c             	add    $0xc,%esp
  8023df:	5e                   	pop    %esi
  8023e0:	5f                   	pop    %edi
  8023e1:	5d                   	pop    %ebp
  8023e2:	c3                   	ret    
  8023e3:	90                   	nop
  8023e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e8:	89 f8                	mov    %edi,%eax
  8023ea:	f7 f1                	div    %ecx
  8023ec:	31 d2                	xor    %edx,%edx
  8023ee:	83 c4 0c             	add    $0xc,%esp
  8023f1:	5e                   	pop    %esi
  8023f2:	5f                   	pop    %edi
  8023f3:	5d                   	pop    %ebp
  8023f4:	c3                   	ret    
  8023f5:	8d 76 00             	lea    0x0(%esi),%esi
  8023f8:	89 e9                	mov    %ebp,%ecx
  8023fa:	8b 3c 24             	mov    (%esp),%edi
  8023fd:	d3 e0                	shl    %cl,%eax
  8023ff:	89 c6                	mov    %eax,%esi
  802401:	b8 20 00 00 00       	mov    $0x20,%eax
  802406:	29 e8                	sub    %ebp,%eax
  802408:	89 c1                	mov    %eax,%ecx
  80240a:	d3 ef                	shr    %cl,%edi
  80240c:	89 e9                	mov    %ebp,%ecx
  80240e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802412:	8b 3c 24             	mov    (%esp),%edi
  802415:	09 74 24 08          	or     %esi,0x8(%esp)
  802419:	89 d6                	mov    %edx,%esi
  80241b:	d3 e7                	shl    %cl,%edi
  80241d:	89 c1                	mov    %eax,%ecx
  80241f:	89 3c 24             	mov    %edi,(%esp)
  802422:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802426:	d3 ee                	shr    %cl,%esi
  802428:	89 e9                	mov    %ebp,%ecx
  80242a:	d3 e2                	shl    %cl,%edx
  80242c:	89 c1                	mov    %eax,%ecx
  80242e:	d3 ef                	shr    %cl,%edi
  802430:	09 d7                	or     %edx,%edi
  802432:	89 f2                	mov    %esi,%edx
  802434:	89 f8                	mov    %edi,%eax
  802436:	f7 74 24 08          	divl   0x8(%esp)
  80243a:	89 d6                	mov    %edx,%esi
  80243c:	89 c7                	mov    %eax,%edi
  80243e:	f7 24 24             	mull   (%esp)
  802441:	39 d6                	cmp    %edx,%esi
  802443:	89 14 24             	mov    %edx,(%esp)
  802446:	72 30                	jb     802478 <__udivdi3+0x118>
  802448:	8b 54 24 04          	mov    0x4(%esp),%edx
  80244c:	89 e9                	mov    %ebp,%ecx
  80244e:	d3 e2                	shl    %cl,%edx
  802450:	39 c2                	cmp    %eax,%edx
  802452:	73 05                	jae    802459 <__udivdi3+0xf9>
  802454:	3b 34 24             	cmp    (%esp),%esi
  802457:	74 1f                	je     802478 <__udivdi3+0x118>
  802459:	89 f8                	mov    %edi,%eax
  80245b:	31 d2                	xor    %edx,%edx
  80245d:	e9 7a ff ff ff       	jmp    8023dc <__udivdi3+0x7c>
  802462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802468:	31 d2                	xor    %edx,%edx
  80246a:	b8 01 00 00 00       	mov    $0x1,%eax
  80246f:	e9 68 ff ff ff       	jmp    8023dc <__udivdi3+0x7c>
  802474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802478:	8d 47 ff             	lea    -0x1(%edi),%eax
  80247b:	31 d2                	xor    %edx,%edx
  80247d:	83 c4 0c             	add    $0xc,%esp
  802480:	5e                   	pop    %esi
  802481:	5f                   	pop    %edi
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    
  802484:	66 90                	xchg   %ax,%ax
  802486:	66 90                	xchg   %ax,%ax
  802488:	66 90                	xchg   %ax,%ax
  80248a:	66 90                	xchg   %ax,%ax
  80248c:	66 90                	xchg   %ax,%ax
  80248e:	66 90                	xchg   %ax,%ax

00802490 <__umoddi3>:
  802490:	55                   	push   %ebp
  802491:	57                   	push   %edi
  802492:	56                   	push   %esi
  802493:	83 ec 14             	sub    $0x14,%esp
  802496:	8b 44 24 28          	mov    0x28(%esp),%eax
  80249a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80249e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8024a2:	89 c7                	mov    %eax,%edi
  8024a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8024b0:	89 34 24             	mov    %esi,(%esp)
  8024b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024b7:	85 c0                	test   %eax,%eax
  8024b9:	89 c2                	mov    %eax,%edx
  8024bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024bf:	75 17                	jne    8024d8 <__umoddi3+0x48>
  8024c1:	39 fe                	cmp    %edi,%esi
  8024c3:	76 4b                	jbe    802510 <__umoddi3+0x80>
  8024c5:	89 c8                	mov    %ecx,%eax
  8024c7:	89 fa                	mov    %edi,%edx
  8024c9:	f7 f6                	div    %esi
  8024cb:	89 d0                	mov    %edx,%eax
  8024cd:	31 d2                	xor    %edx,%edx
  8024cf:	83 c4 14             	add    $0x14,%esp
  8024d2:	5e                   	pop    %esi
  8024d3:	5f                   	pop    %edi
  8024d4:	5d                   	pop    %ebp
  8024d5:	c3                   	ret    
  8024d6:	66 90                	xchg   %ax,%ax
  8024d8:	39 f8                	cmp    %edi,%eax
  8024da:	77 54                	ja     802530 <__umoddi3+0xa0>
  8024dc:	0f bd e8             	bsr    %eax,%ebp
  8024df:	83 f5 1f             	xor    $0x1f,%ebp
  8024e2:	75 5c                	jne    802540 <__umoddi3+0xb0>
  8024e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8024e8:	39 3c 24             	cmp    %edi,(%esp)
  8024eb:	0f 87 e7 00 00 00    	ja     8025d8 <__umoddi3+0x148>
  8024f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024f5:	29 f1                	sub    %esi,%ecx
  8024f7:	19 c7                	sbb    %eax,%edi
  8024f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802501:	8b 44 24 08          	mov    0x8(%esp),%eax
  802505:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802509:	83 c4 14             	add    $0x14,%esp
  80250c:	5e                   	pop    %esi
  80250d:	5f                   	pop    %edi
  80250e:	5d                   	pop    %ebp
  80250f:	c3                   	ret    
  802510:	85 f6                	test   %esi,%esi
  802512:	89 f5                	mov    %esi,%ebp
  802514:	75 0b                	jne    802521 <__umoddi3+0x91>
  802516:	b8 01 00 00 00       	mov    $0x1,%eax
  80251b:	31 d2                	xor    %edx,%edx
  80251d:	f7 f6                	div    %esi
  80251f:	89 c5                	mov    %eax,%ebp
  802521:	8b 44 24 04          	mov    0x4(%esp),%eax
  802525:	31 d2                	xor    %edx,%edx
  802527:	f7 f5                	div    %ebp
  802529:	89 c8                	mov    %ecx,%eax
  80252b:	f7 f5                	div    %ebp
  80252d:	eb 9c                	jmp    8024cb <__umoddi3+0x3b>
  80252f:	90                   	nop
  802530:	89 c8                	mov    %ecx,%eax
  802532:	89 fa                	mov    %edi,%edx
  802534:	83 c4 14             	add    $0x14,%esp
  802537:	5e                   	pop    %esi
  802538:	5f                   	pop    %edi
  802539:	5d                   	pop    %ebp
  80253a:	c3                   	ret    
  80253b:	90                   	nop
  80253c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802540:	8b 04 24             	mov    (%esp),%eax
  802543:	be 20 00 00 00       	mov    $0x20,%esi
  802548:	89 e9                	mov    %ebp,%ecx
  80254a:	29 ee                	sub    %ebp,%esi
  80254c:	d3 e2                	shl    %cl,%edx
  80254e:	89 f1                	mov    %esi,%ecx
  802550:	d3 e8                	shr    %cl,%eax
  802552:	89 e9                	mov    %ebp,%ecx
  802554:	89 44 24 04          	mov    %eax,0x4(%esp)
  802558:	8b 04 24             	mov    (%esp),%eax
  80255b:	09 54 24 04          	or     %edx,0x4(%esp)
  80255f:	89 fa                	mov    %edi,%edx
  802561:	d3 e0                	shl    %cl,%eax
  802563:	89 f1                	mov    %esi,%ecx
  802565:	89 44 24 08          	mov    %eax,0x8(%esp)
  802569:	8b 44 24 10          	mov    0x10(%esp),%eax
  80256d:	d3 ea                	shr    %cl,%edx
  80256f:	89 e9                	mov    %ebp,%ecx
  802571:	d3 e7                	shl    %cl,%edi
  802573:	89 f1                	mov    %esi,%ecx
  802575:	d3 e8                	shr    %cl,%eax
  802577:	89 e9                	mov    %ebp,%ecx
  802579:	09 f8                	or     %edi,%eax
  80257b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80257f:	f7 74 24 04          	divl   0x4(%esp)
  802583:	d3 e7                	shl    %cl,%edi
  802585:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802589:	89 d7                	mov    %edx,%edi
  80258b:	f7 64 24 08          	mull   0x8(%esp)
  80258f:	39 d7                	cmp    %edx,%edi
  802591:	89 c1                	mov    %eax,%ecx
  802593:	89 14 24             	mov    %edx,(%esp)
  802596:	72 2c                	jb     8025c4 <__umoddi3+0x134>
  802598:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80259c:	72 22                	jb     8025c0 <__umoddi3+0x130>
  80259e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025a2:	29 c8                	sub    %ecx,%eax
  8025a4:	19 d7                	sbb    %edx,%edi
  8025a6:	89 e9                	mov    %ebp,%ecx
  8025a8:	89 fa                	mov    %edi,%edx
  8025aa:	d3 e8                	shr    %cl,%eax
  8025ac:	89 f1                	mov    %esi,%ecx
  8025ae:	d3 e2                	shl    %cl,%edx
  8025b0:	89 e9                	mov    %ebp,%ecx
  8025b2:	d3 ef                	shr    %cl,%edi
  8025b4:	09 d0                	or     %edx,%eax
  8025b6:	89 fa                	mov    %edi,%edx
  8025b8:	83 c4 14             	add    $0x14,%esp
  8025bb:	5e                   	pop    %esi
  8025bc:	5f                   	pop    %edi
  8025bd:	5d                   	pop    %ebp
  8025be:	c3                   	ret    
  8025bf:	90                   	nop
  8025c0:	39 d7                	cmp    %edx,%edi
  8025c2:	75 da                	jne    80259e <__umoddi3+0x10e>
  8025c4:	8b 14 24             	mov    (%esp),%edx
  8025c7:	89 c1                	mov    %eax,%ecx
  8025c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8025cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8025d1:	eb cb                	jmp    80259e <__umoddi3+0x10e>
  8025d3:	90                   	nop
  8025d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8025dc:	0f 82 0f ff ff ff    	jb     8024f1 <__umoddi3+0x61>
  8025e2:	e9 1a ff ff ff       	jmp    802501 <__umoddi3+0x71>
