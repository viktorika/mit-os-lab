
obj/user/primes：     文件格式 elf32-i386


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
  800052:	e8 dd 12 00 00       	call   801334 <ipc_recv>
  800057:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800059:	a1 04 20 80 00       	mov    0x802004,%eax
  80005e:	8b 40 5c             	mov    0x5c(%eax),%eax
  800061:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800065:	89 44 24 04          	mov    %eax,0x4(%esp)
  800069:	c7 04 24 60 17 80 00 	movl   $0x801760,(%esp)
  800070:	e8 28 02 00 00       	call   80029d <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800075:	e8 81 10 00 00       	call   8010fb <fork>
  80007a:	89 c7                	mov    %eax,%edi
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 20                	jns    8000a0 <primeproc+0x6d>
		panic("fork: %e", id);
  800080:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800084:	c7 44 24 08 6c 17 80 	movl   $0x80176c,0x8(%esp)
  80008b:	00 
  80008c:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800093:	00 
  800094:	c7 04 24 75 17 80 00 	movl   $0x801775,(%esp)
  80009b:	e8 04 01 00 00       	call   8001a4 <_panic>
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
  8000ba:	e8 75 12 00 00       	call   801334 <ipc_recv>
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
  8000df:	e8 ac 12 00 00       	call   801390 <ipc_send>
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
  8000ee:	e8 08 10 00 00       	call   8010fb <fork>
  8000f3:	89 c6                	mov    %eax,%esi
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	79 20                	jns    800119 <umain+0x33>
		panic("fork: %e", id);
  8000f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fd:	c7 44 24 08 6c 17 80 	movl   $0x80176c,0x8(%esp)
  800104:	00 
  800105:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80010c:	00 
  80010d:	c7 04 24 75 17 80 00 	movl   $0x801775,(%esp)
  800114:	e8 8b 00 00 00       	call   8001a4 <_panic>
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
  80013e:	e8 4d 12 00 00       	call   801390 <ipc_send>
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
  800168:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016d:	85 db                	test   %ebx,%ebx
  80016f:	7e 07                	jle    800178 <libmain+0x30>
		binaryname = argv[0];
  800171:	8b 06                	mov    (%esi),%eax
  800173:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  800196:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80019d:	e8 77 0b 00 00       	call   800d19 <sys_env_destroy>
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001ac:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001af:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001b5:	e8 b1 0b 00 00       	call   800d6b <sys_getenvid>
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001c8:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	c7 04 24 90 17 80 00 	movl   $0x801790,(%esp)
  8001d7:	e8 c1 00 00 00       	call   80029d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e3:	89 04 24             	mov    %eax,(%esp)
  8001e6:	e8 51 00 00 00       	call   80023c <vcprintf>
	cprintf("\n");
  8001eb:	c7 04 24 b3 17 80 00 	movl   $0x8017b3,(%esp)
  8001f2:	e8 a6 00 00 00       	call   80029d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f7:	cc                   	int3   
  8001f8:	eb fd                	jmp    8001f7 <_panic+0x53>

008001fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	53                   	push   %ebx
  8001fe:	83 ec 14             	sub    $0x14,%esp
  800201:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800204:	8b 13                	mov    (%ebx),%edx
  800206:	8d 42 01             	lea    0x1(%edx),%eax
  800209:	89 03                	mov    %eax,(%ebx)
  80020b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800212:	3d ff 00 00 00       	cmp    $0xff,%eax
  800217:	75 19                	jne    800232 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800219:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800220:	00 
  800221:	8d 43 08             	lea    0x8(%ebx),%eax
  800224:	89 04 24             	mov    %eax,(%esp)
  800227:	e8 b0 0a 00 00       	call   800cdc <sys_cputs>
		b->idx = 0;
  80022c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	83 c4 14             	add    $0x14,%esp
  800239:	5b                   	pop    %ebx
  80023a:	5d                   	pop    %ebp
  80023b:	c3                   	ret    

0080023c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800245:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024c:	00 00 00 
	b.cnt = 0;
  80024f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800256:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800259:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800260:	8b 45 08             	mov    0x8(%ebp),%eax
  800263:	89 44 24 08          	mov    %eax,0x8(%esp)
  800267:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	c7 04 24 fa 01 80 00 	movl   $0x8001fa,(%esp)
  800278:	e8 b7 01 00 00       	call   800434 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800283:	89 44 24 04          	mov    %eax,0x4(%esp)
  800287:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80028d:	89 04 24             	mov    %eax,(%esp)
  800290:	e8 47 0a 00 00       	call   800cdc <sys_cputs>

	return b.cnt;
}
  800295:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    

0080029d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ad:	89 04 24             	mov    %eax,(%esp)
  8002b0:	e8 87 ff ff ff       	call   80023c <vcprintf>
	va_end(ap);

	return cnt;
}
  8002b5:	c9                   	leave  
  8002b6:	c3                   	ret    
  8002b7:	66 90                	xchg   %ax,%ax
  8002b9:	66 90                	xchg   %ax,%ax
  8002bb:	66 90                	xchg   %ax,%ax
  8002bd:	66 90                	xchg   %ax,%ax
  8002bf:	90                   	nop

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
  80033c:	e8 8f 11 00 00       	call   8014d0 <__udivdi3>
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
  800395:	e8 66 12 00 00       	call   801600 <__umoddi3>
  80039a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80039e:	0f be 80 b5 17 80 00 	movsbl 0x8017b5(%eax),%eax
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
  8004bc:	ff 24 85 80 18 80 00 	jmp    *0x801880(,%eax,4)
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
  80056a:	83 f8 08             	cmp    $0x8,%eax
  80056d:	7f 0b                	jg     80057a <vprintfmt+0x146>
  80056f:	8b 14 85 e0 19 80 00 	mov    0x8019e0(,%eax,4),%edx
  800576:	85 d2                	test   %edx,%edx
  800578:	75 20                	jne    80059a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80057a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80057e:	c7 44 24 08 cd 17 80 	movl   $0x8017cd,0x8(%esp)
  800585:	00 
  800586:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058a:	8b 45 08             	mov    0x8(%ebp),%eax
  80058d:	89 04 24             	mov    %eax,(%esp)
  800590:	e8 77 fe ff ff       	call   80040c <printfmt>
  800595:	e9 c3 fe ff ff       	jmp    80045d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80059a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80059e:	c7 44 24 08 d6 17 80 	movl   $0x8017d6,0x8(%esp)
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
  8005cd:	ba c6 17 80 00       	mov    $0x8017c6,%edx
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
  800d47:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  800d4e:	00 
  800d4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d56:	00 
  800d57:	c7 04 24 21 1a 80 00 	movl   $0x801a21,(%esp)
  800d5e:	e8 41 f4 ff ff       	call   8001a4 <_panic>
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
  800d95:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800dd9:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  800de0:	00 
  800de1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de8:	00 
  800de9:	c7 04 24 21 1a 80 00 	movl   $0x801a21,(%esp)
  800df0:	e8 af f3 ff ff       	call   8001a4 <_panic>
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
  800e2c:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  800e33:	00 
  800e34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3b:	00 
  800e3c:	c7 04 24 21 1a 80 00 	movl   $0x801a21,(%esp)
  800e43:	e8 5c f3 ff ff       	call   8001a4 <_panic>
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
  800e7f:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  800e86:	00 
  800e87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8e:	00 
  800e8f:	c7 04 24 21 1a 80 00 	movl   $0x801a21,(%esp)
  800e96:	e8 09 f3 ff ff       	call   8001a4 <_panic>
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
  800ed2:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  800ed9:	00 
  800eda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee1:	00 
  800ee2:	c7 04 24 21 1a 80 00 	movl   $0x801a21,(%esp)
  800ee9:	e8 b6 f2 ff ff       	call   8001a4 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800eee:	83 c4 2c             	add    $0x2c,%esp
  800ef1:	5b                   	pop    %ebx
  800ef2:	5e                   	pop    %esi
  800ef3:	5f                   	pop    %edi
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    

00800ef6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800f17:	7e 28                	jle    800f41 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f24:	00 
  800f25:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  800f2c:	00 
  800f2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f34:	00 
  800f35:	c7 04 24 21 1a 80 00 	movl   $0x801a21,(%esp)
  800f3c:	e8 63 f2 ff ff       	call   8001a4 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f41:	83 c4 2c             	add    $0x2c,%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    

00800f49 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	57                   	push   %edi
  800f4d:	56                   	push   %esi
  800f4e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f4f:	be 00 00 00 00       	mov    $0x0,%esi
  800f54:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f65:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f67:	5b                   	pop    %ebx
  800f68:	5e                   	pop    %esi
  800f69:	5f                   	pop    %edi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	57                   	push   %edi
  800f70:	56                   	push   %esi
  800f71:	53                   	push   %ebx
  800f72:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f75:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f7a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f82:	89 cb                	mov    %ecx,%ebx
  800f84:	89 cf                	mov    %ecx,%edi
  800f86:	89 ce                	mov    %ecx,%esi
  800f88:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	7e 28                	jle    800fb6 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f92:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f99:	00 
  800f9a:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  800fa1:	00 
  800fa2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa9:	00 
  800faa:	c7 04 24 21 1a 80 00 	movl   $0x801a21,(%esp)
  800fb1:	e8 ee f1 ff ff       	call   8001a4 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fb6:	83 c4 2c             	add    $0x2c,%esp
  800fb9:	5b                   	pop    %ebx
  800fba:	5e                   	pop    %esi
  800fbb:	5f                   	pop    %edi
  800fbc:	5d                   	pop    %ebp
  800fbd:	c3                   	ret    

00800fbe <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	53                   	push   %ebx
  800fc2:	83 ec 24             	sub    $0x24,%esp
  800fc5:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800fc8:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800fca:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800fce:	74 2e                	je     800ffe <pgfault+0x40>
  800fd0:	89 c2                	mov    %eax,%edx
  800fd2:	c1 ea 16             	shr    $0x16,%edx
  800fd5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fdc:	f6 c2 01             	test   $0x1,%dl
  800fdf:	74 1d                	je     800ffe <pgfault+0x40>
  800fe1:	89 c2                	mov    %eax,%edx
  800fe3:	c1 ea 0c             	shr    $0xc,%edx
  800fe6:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800fed:	f6 c1 01             	test   $0x1,%cl
  800ff0:	74 0c                	je     800ffe <pgfault+0x40>
  800ff2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ff9:	f6 c6 08             	test   $0x8,%dh
  800ffc:	75 20                	jne    80101e <pgfault+0x60>
		panic("pgfault: page cow check failed, addr=%x\n", addr);
  800ffe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801002:	c7 44 24 08 30 1a 80 	movl   $0x801a30,0x8(%esp)
  801009:	00 
  80100a:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  801011:	00 
  801012:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  801019:	e8 86 f1 ff ff       	call   8001a4 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  80101e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801023:	89 c3                	mov    %eax,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W))
  801025:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80102c:	00 
  80102d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801034:	00 
  801035:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80103c:	e8 68 fd ff ff       	call   800da9 <sys_page_alloc>
  801041:	85 c0                	test   %eax,%eax
  801043:	74 1c                	je     801061 <pgfault+0xa3>
		panic("pgfault: sys_page_alloc error");
  801045:	c7 44 24 08 fa 1a 80 	movl   $0x801afa,0x8(%esp)
  80104c:	00 
  80104d:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801054:	00 
  801055:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  80105c:	e8 43 f1 ff ff       	call   8001a4 <_panic>

	memmove(PFTEMP, addr, PGSIZE);
  801061:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801068:	00 
  801069:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80106d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801074:	e8 7d fa ff ff       	call   800af6 <memmove>
	if(sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))
  801079:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801080:	00 
  801081:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801085:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80108c:	00 
  80108d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801094:	00 
  801095:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80109c:	e8 5c fd ff ff       	call   800dfd <sys_page_map>
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	74 1c                	je     8010c1 <pgfault+0x103>
		panic("pgfault: sys_page_map error");
  8010a5:	c7 44 24 08 18 1b 80 	movl   $0x801b18,0x8(%esp)
  8010ac:	00 
  8010ad:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8010b4:	00 
  8010b5:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  8010bc:	e8 e3 f0 ff ff       	call   8001a4 <_panic>

	if(sys_page_unmap(0, PFTEMP))
  8010c1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010c8:	00 
  8010c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d0:	e8 7b fd ff ff       	call   800e50 <sys_page_unmap>
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	74 1c                	je     8010f5 <pgfault+0x137>
		panic("pgfault: sys_page_unmap error");
  8010d9:	c7 44 24 08 34 1b 80 	movl   $0x801b34,0x8(%esp)
  8010e0:	00 
  8010e1:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8010e8:	00 
  8010e9:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  8010f0:	e8 af f0 ff ff       	call   8001a4 <_panic>
}
  8010f5:	83 c4 24             	add    $0x24,%esp
  8010f8:	5b                   	pop    %ebx
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
  801101:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	//根据文档的描述，duppage好像不应该处理除了可写或者copy-on-write的部分，但这里都交给duppage一块处理了
	set_pgfault_handler(pgfault);
  801104:	c7 04 24 be 0f 80 00 	movl   $0x800fbe,(%esp)
  80110b:	e8 10 03 00 00       	call   801420 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801110:	b8 07 00 00 00       	mov    $0x7,%eax
  801115:	cd 30                	int    $0x30
  801117:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();
	if(envid < 0)
  80111a:	85 c0                	test   %eax,%eax
  80111c:	79 1c                	jns    80113a <fork+0x3f>
		//失败
		panic("fork: sys_exofork error");
  80111e:	c7 44 24 08 52 1b 80 	movl   $0x801b52,0x8(%esp)
  801125:	00 
  801126:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  80112d:	00 
  80112e:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  801135:	e8 6a f0 ff ff       	call   8001a4 <_panic>
  80113a:	89 c7                	mov    %eax,%edi
	else if(!envid)
  80113c:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801141:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801145:	75 1c                	jne    801163 <fork+0x68>
		//子进程
		thisenv = &envs[ENVX(sys_getenvid())];
  801147:	e8 1f fc ff ff       	call   800d6b <sys_getenvid>
  80114c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801151:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801154:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801159:	a3 04 20 80 00       	mov    %eax,0x802004
  80115e:	e9 a4 01 00 00       	jmp    801307 <fork+0x20c>
	else{
		//父进程
		unsigned addr;
		for(addr = UTEXT; addr < USTACKTOP; addr+= PGSIZE){
			if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))
  801163:	89 d8                	mov    %ebx,%eax
  801165:	c1 e8 16             	shr    $0x16,%eax
  801168:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80116f:	a8 01                	test   $0x1,%al
  801171:	0f 84 00 01 00 00    	je     801277 <fork+0x17c>
  801177:	89 d8                	mov    %ebx,%eax
  801179:	c1 e8 0c             	shr    $0xc,%eax
  80117c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801183:	f6 c2 01             	test   $0x1,%dl
  801186:	0f 84 eb 00 00 00    	je     801277 <fork+0x17c>
  80118c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801193:	f6 c2 04             	test   $0x4,%dl
  801196:	0f 84 db 00 00 00    	je     801277 <fork+0x17c>
	void *addr = (void *)(pn * PGSIZE);
  80119c:	89 c6                	mov    %eax,%esi
  80119e:	c1 e6 0c             	shl    $0xc,%esi
	if(uvpt[pn] & (PTE_W | PTE_COW)){
  8011a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a8:	a9 02 08 00 00       	test   $0x802,%eax
  8011ad:	0f 84 84 00 00 00    	je     801237 <fork+0x13c>
		if(sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P))
  8011b3:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011ba:	00 
  8011bb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011bf:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ce:	e8 2a fc ff ff       	call   800dfd <sys_page_map>
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	74 1c                	je     8011f3 <fork+0xf8>
			panic("duppage: sys_page_map child error");
  8011d7:	c7 44 24 08 5c 1a 80 	movl   $0x801a5c,0x8(%esp)
  8011de:	00 
  8011df:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  8011e6:	00 
  8011e7:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  8011ee:	e8 b1 ef ff ff       	call   8001a4 <_panic>
		if(sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P))
  8011f3:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011fa:	00 
  8011fb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801206:	00 
  801207:	89 74 24 04          	mov    %esi,0x4(%esp)
  80120b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801212:	e8 e6 fb ff ff       	call   800dfd <sys_page_map>
  801217:	85 c0                	test   %eax,%eax
  801219:	74 5c                	je     801277 <fork+0x17c>
			panic("duppage: sys_page_map remap parent error");
  80121b:	c7 44 24 08 80 1a 80 	movl   $0x801a80,0x8(%esp)
  801222:	00 
  801223:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  80122a:	00 
  80122b:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  801232:	e8 6d ef ff ff       	call   8001a4 <_panic>
		if(sys_page_map(0, addr, envid, addr, PTE_U|PTE_P))
  801237:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80123e:	00 
  80123f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801243:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801247:	89 74 24 04          	mov    %esi,0x4(%esp)
  80124b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801252:	e8 a6 fb ff ff       	call   800dfd <sys_page_map>
  801257:	85 c0                	test   %eax,%eax
  801259:	74 1c                	je     801277 <fork+0x17c>
			panic("duppage: other sys_page_map error");
  80125b:	c7 44 24 08 ac 1a 80 	movl   $0x801aac,0x8(%esp)
  801262:	00 
  801263:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  80126a:	00 
  80126b:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  801272:	e8 2d ef ff ff       	call   8001a4 <_panic>
		for(addr = UTEXT; addr < USTACKTOP; addr+= PGSIZE){
  801277:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80127d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801283:	0f 85 da fe ff ff    	jne    801163 <fork+0x68>
				duppage(envid, PGNUM(addr));
		}
		if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W))
  801289:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801290:	00 
  801291:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801298:	ee 
  801299:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80129c:	89 04 24             	mov    %eax,(%esp)
  80129f:	e8 05 fb ff ff       	call   800da9 <sys_page_alloc>
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	74 1c                	je     8012c4 <fork+0x1c9>
			panic("fork: sys_page_alloc error");
  8012a8:	c7 44 24 08 6a 1b 80 	movl   $0x801b6a,0x8(%esp)
  8012af:	00 
  8012b0:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  8012b7:	00 
  8012b8:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  8012bf:	e8 e0 ee ff ff       	call   8001a4 <_panic>
		extern void _pgfault_upcall();
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8012c4:	c7 44 24 04 a9 14 80 	movl   $0x8014a9,0x4(%esp)
  8012cb:	00 
  8012cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012cf:	89 3c 24             	mov    %edi,(%esp)
  8012d2:	e8 1f fc ff ff       	call   800ef6 <sys_env_set_pgfault_upcall>
		if(sys_env_set_status(envid, ENV_RUNNABLE))
  8012d7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012de:	00 
  8012df:	89 3c 24             	mov    %edi,(%esp)
  8012e2:	e8 bc fb ff ff       	call   800ea3 <sys_env_set_status>
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	74 1c                	je     801307 <fork+0x20c>
			panic("fork: sys_env_set_status error");
  8012eb:	c7 44 24 08 d0 1a 80 	movl   $0x801ad0,0x8(%esp)
  8012f2:	00 
  8012f3:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  8012fa:	00 
  8012fb:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  801302:	e8 9d ee ff ff       	call   8001a4 <_panic>
	}
	return envid;
}
  801307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80130a:	83 c4 2c             	add    $0x2c,%esp
  80130d:	5b                   	pop    %ebx
  80130e:	5e                   	pop    %esi
  80130f:	5f                   	pop    %edi
  801310:	5d                   	pop    %ebp
  801311:	c3                   	ret    

00801312 <sfork>:

// Challenge!
int
sfork(void)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801318:	c7 44 24 08 85 1b 80 	movl   $0x801b85,0x8(%esp)
  80131f:	00 
  801320:	c7 44 24 04 87 00 00 	movl   $0x87,0x4(%esp)
  801327:	00 
  801328:	c7 04 24 ef 1a 80 00 	movl   $0x801aef,(%esp)
  80132f:	e8 70 ee ff ff       	call   8001a4 <_panic>

00801334 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	56                   	push   %esi
  801338:	53                   	push   %ebx
  801339:	83 ec 10             	sub    $0x10,%esp
  80133c:	8b 75 08             	mov    0x8(%ebp),%esi
  80133f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  801342:	8b 45 0c             	mov    0xc(%ebp),%eax
  801345:	89 04 24             	mov    %eax,(%esp)
  801348:	e8 1f fc ff ff       	call   800f6c <sys_ipc_recv>
	if(from_env_store)
  80134d:	85 f6                	test   %esi,%esi
  80134f:	74 14                	je     801365 <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  801351:	ba 00 00 00 00       	mov    $0x0,%edx
  801356:	85 c0                	test   %eax,%eax
  801358:	78 09                	js     801363 <ipc_recv+0x2f>
  80135a:	8b 15 04 20 80 00    	mov    0x802004,%edx
  801360:	8b 52 74             	mov    0x74(%edx),%edx
  801363:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  801365:	85 db                	test   %ebx,%ebx
  801367:	74 14                	je     80137d <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  801369:	ba 00 00 00 00       	mov    $0x0,%edx
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 09                	js     80137b <ipc_recv+0x47>
  801372:	8b 15 04 20 80 00    	mov    0x802004,%edx
  801378:	8b 52 78             	mov    0x78(%edx),%edx
  80137b:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 08                	js     801389 <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  801381:	a1 04 20 80 00       	mov    0x802004,%eax
  801386:	8b 40 70             	mov    0x70(%eax),%eax
}
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	5b                   	pop    %ebx
  80138d:	5e                   	pop    %esi
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	57                   	push   %edi
  801394:	56                   	push   %esi
  801395:	53                   	push   %ebx
  801396:	83 ec 1c             	sub    $0x1c,%esp
  801399:	8b 7d 08             	mov    0x8(%ebp),%edi
  80139c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  80139f:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  8013a4:	eb 0c                	jmp    8013b2 <ipc_send+0x22>
		failed_cnt++;
  8013a6:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  8013a9:	84 db                	test   %bl,%bl
  8013ab:	75 05                	jne    8013b2 <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  8013ad:	e8 d8 f9 ff ff       	call   800d8a <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  8013b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8013bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013c4:	89 3c 24             	mov    %edi,(%esp)
  8013c7:	e8 7d fb ff ff       	call   800f49 <sys_ipc_try_send>
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	78 d6                	js     8013a6 <ipc_send+0x16>
	}
}
  8013d0:	83 c4 1c             	add    $0x1c,%esp
  8013d3:	5b                   	pop    %ebx
  8013d4:	5e                   	pop    %esi
  8013d5:	5f                   	pop    %edi
  8013d6:	5d                   	pop    %ebp
  8013d7:	c3                   	ret    

008013d8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8013de:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8013e3:	39 c8                	cmp    %ecx,%eax
  8013e5:	74 17                	je     8013fe <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  8013e7:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8013ec:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013ef:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013f5:	8b 52 50             	mov    0x50(%edx),%edx
  8013f8:	39 ca                	cmp    %ecx,%edx
  8013fa:	75 14                	jne    801410 <ipc_find_env+0x38>
  8013fc:	eb 05                	jmp    801403 <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  8013fe:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  801403:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801406:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80140b:	8b 40 40             	mov    0x40(%eax),%eax
  80140e:	eb 0e                	jmp    80141e <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  801410:	83 c0 01             	add    $0x1,%eax
  801413:	3d 00 04 00 00       	cmp    $0x400,%eax
  801418:	75 d2                	jne    8013ec <ipc_find_env+0x14>
	return 0;
  80141a:	66 b8 00 00          	mov    $0x0,%ax
}
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801426:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80142d:	75 70                	jne    80149f <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  80142f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801436:	00 
  801437:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80143e:	ee 
  80143f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801446:	e8 5e f9 ff ff       	call   800da9 <sys_page_alloc>
  80144b:	85 c0                	test   %eax,%eax
  80144d:	79 1c                	jns    80146b <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  80144f:	c7 44 24 08 9c 1b 80 	movl   $0x801b9c,0x8(%esp)
  801456:	00 
  801457:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80145e:	00 
  80145f:	c7 04 24 00 1c 80 00 	movl   $0x801c00,(%esp)
  801466:	e8 39 ed ff ff       	call   8001a4 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80146b:	c7 44 24 04 a9 14 80 	movl   $0x8014a9,0x4(%esp)
  801472:	00 
  801473:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80147a:	e8 77 fa ff ff       	call   800ef6 <sys_env_set_pgfault_upcall>
  80147f:	85 c0                	test   %eax,%eax
  801481:	79 1c                	jns    80149f <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  801483:	c7 44 24 08 c8 1b 80 	movl   $0x801bc8,0x8(%esp)
  80148a:	00 
  80148b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801492:	00 
  801493:	c7 04 24 00 1c 80 00 	movl   $0x801c00,(%esp)
  80149a:	e8 05 ed ff ff       	call   8001a4 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80149f:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a2:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8014a7:	c9                   	leave  
  8014a8:	c3                   	ret    

008014a9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014a9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014aa:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8014af:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014b1:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  8014b4:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  8014b8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  8014bd:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  8014c1:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8014c3:	83 c4 08             	add    $0x8,%esp
	popal
  8014c6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8014c7:	83 c4 04             	add    $0x4,%esp
	popfl
  8014ca:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8014cb:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8014cc:	c3                   	ret    
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
