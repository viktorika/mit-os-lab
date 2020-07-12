
obj/user/stresssched.debug：     文件格式 elf32-i386


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
  80002c:	e8 f2 00 00 00       	call   800123 <libmain>
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

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 fe 0c 00 00       	call   800d4b <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800054:	e8 d5 10 00 00       	call   80112e <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 23                	jmp    80008a <umain+0x4a>
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 1e                	je     80008a <umain+0x4a>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	89 f0                	mov    %esi,%eax
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800076:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  80007c:	8b 52 50             	mov    0x50(%edx),%edx
  80007f:	85 d2                	test   %edx,%edx
  800081:	75 12                	jne    800095 <umain+0x55>
	for (i = 0; i < 20; i++)
  800083:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800088:	eb 1f                	jmp    8000a9 <umain+0x69>
		sys_yield();
  80008a:	e8 db 0c 00 00       	call   800d6a <sys_yield>
		return;
  80008f:	90                   	nop
  800090:	e9 87 00 00 00       	jmp    80011c <umain+0xdc>
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	8d 90 04 00 c0 ee    	lea    -0x113ffffc(%eax),%edx
		asm volatile("pause");
  80009e:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  8000a0:	8b 42 50             	mov    0x50(%edx),%eax
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	75 f7                	jne    80009e <umain+0x5e>
  8000a7:	eb da                	jmp    800083 <umain+0x43>

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  8000a9:	e8 bc 0c 00 00       	call   800d6a <sys_yield>
  8000ae:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000b3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000b9:	83 c2 01             	add    $0x1,%edx
  8000bc:	89 15 04 40 80 00    	mov    %edx,0x804004
		for (j = 0; j < 10000; j++)
  8000c2:	83 e8 01             	sub    $0x1,%eax
  8000c5:	75 ec                	jne    8000b3 <umain+0x73>
	for (i = 0; i < 10; i++) {
  8000c7:	83 eb 01             	sub    $0x1,%ebx
  8000ca:	75 dd                	jne    8000a9 <umain+0x69>
	}

	if (counter != 10*10000)
  8000cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8000d1:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000d6:	74 25                	je     8000fd <umain+0xbd>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e1:	c7 44 24 08 e0 25 80 	movl   $0x8025e0,0x8(%esp)
  8000e8:	00 
  8000e9:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000f0:	00 
  8000f1:	c7 04 24 08 26 80 00 	movl   $0x802608,(%esp)
  8000f8:	e8 87 00 00 00       	call   800184 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000fd:	a1 08 40 80 00       	mov    0x804008,%eax
  800102:	8b 50 5c             	mov    0x5c(%eax),%edx
  800105:	8b 40 48             	mov    0x48(%eax),%eax
  800108:	89 54 24 08          	mov    %edx,0x8(%esp)
  80010c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800110:	c7 04 24 1b 26 80 00 	movl   $0x80261b,(%esp)
  800117:	e8 61 01 00 00       	call   80027d <cprintf>

}
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5d                   	pop    %ebp
  800122:	c3                   	ret    

00800123 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	56                   	push   %esi
  800127:	53                   	push   %ebx
  800128:	83 ec 10             	sub    $0x10,%esp
  80012b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80012e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800131:	e8 15 0c 00 00       	call   800d4b <sys_getenvid>
  800136:	25 ff 03 00 00       	and    $0x3ff,%eax
  80013b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80013e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800143:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800148:	85 db                	test   %ebx,%ebx
  80014a:	7e 07                	jle    800153 <libmain+0x30>
		binaryname = argv[0];
  80014c:	8b 06                	mov    (%esi),%eax
  80014e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800153:	89 74 24 04          	mov    %esi,0x4(%esp)
  800157:	89 1c 24             	mov    %ebx,(%esp)
  80015a:	e8 e1 fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  80015f:	e8 07 00 00 00       	call   80016b <exit>
}
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    

0080016b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800171:	e8 60 14 00 00       	call   8015d6 <close_all>
	sys_env_destroy(0);
  800176:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017d:	e8 77 0b 00 00       	call   800cf9 <sys_env_destroy>
}
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80018c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800195:	e8 b1 0b 00 00       	call   800d4b <sys_getenvid>
  80019a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001a8:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b0:	c7 04 24 44 26 80 00 	movl   $0x802644,(%esp)
  8001b7:	e8 c1 00 00 00       	call   80027d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c3:	89 04 24             	mov    %eax,(%esp)
  8001c6:	e8 51 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001cb:	c7 04 24 37 26 80 00 	movl   $0x802637,(%esp)
  8001d2:	e8 a6 00 00 00       	call   80027d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x53>

008001da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 14             	sub    $0x14,%esp
  8001e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e4:	8b 13                	mov    (%ebx),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 03                	mov    %eax,(%ebx)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	75 19                	jne    800212 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001f9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800200:	00 
  800201:	8d 43 08             	lea    0x8(%ebx),%eax
  800204:	89 04 24             	mov    %eax,(%esp)
  800207:	e8 b0 0a 00 00       	call   800cbc <sys_cputs>
		b->idx = 0;
  80020c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800212:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800216:	83 c4 14             	add    $0x14,%esp
  800219:	5b                   	pop    %ebx
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800225:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022c:	00 00 00 
	b.cnt = 0;
  80022f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800236:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800239:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800240:	8b 45 08             	mov    0x8(%ebp),%eax
  800243:	89 44 24 08          	mov    %eax,0x8(%esp)
  800247:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800251:	c7 04 24 da 01 80 00 	movl   $0x8001da,(%esp)
  800258:	e8 b7 01 00 00       	call   800414 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800263:	89 44 24 04          	mov    %eax,0x4(%esp)
  800267:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026d:	89 04 24             	mov    %eax,(%esp)
  800270:	e8 47 0a 00 00       	call   800cbc <sys_cputs>

	return b.cnt;
}
  800275:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027b:	c9                   	leave  
  80027c:	c3                   	ret    

0080027d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800283:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800286:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	89 04 24             	mov    %eax,(%esp)
  800290:	e8 87 ff ff ff       	call   80021c <vcprintf>
	va_end(ap);

	return cnt;
}
  800295:	c9                   	leave  
  800296:	c3                   	ret    
  800297:	66 90                	xchg   %ax,%ax
  800299:	66 90                	xchg   %ax,%ax
  80029b:	66 90                	xchg   %ax,%ax
  80029d:	66 90                	xchg   %ax,%ax
  80029f:	90                   	nop

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 3c             	sub    $0x3c,%esp
  8002a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ac:	89 d7                	mov    %edx,%edi
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002b7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8002ba:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002c8:	39 f1                	cmp    %esi,%ecx
  8002ca:	72 14                	jb     8002e0 <printnum+0x40>
  8002cc:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002cf:	76 0f                	jbe    8002e0 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d4:	8d 70 ff             	lea    -0x1(%eax),%esi
  8002d7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002da:	85 f6                	test   %esi,%esi
  8002dc:	7f 60                	jg     80033e <printnum+0x9e>
  8002de:	eb 72                	jmp    800352 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002e3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002e7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8002ea:	8d 51 ff             	lea    -0x1(%ecx),%edx
  8002ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f5:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002f9:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002fd:	89 c3                	mov    %eax,%ebx
  8002ff:	89 d6                	mov    %edx,%esi
  800301:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800304:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800307:	89 54 24 08          	mov    %edx,0x8(%esp)
  80030b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80030f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800312:	89 04 24             	mov    %eax,(%esp)
  800315:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800318:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031c:	e8 1f 20 00 00       	call   802340 <__udivdi3>
  800321:	89 d9                	mov    %ebx,%ecx
  800323:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800327:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80032b:	89 04 24             	mov    %eax,(%esp)
  80032e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800332:	89 fa                	mov    %edi,%edx
  800334:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800337:	e8 64 ff ff ff       	call   8002a0 <printnum>
  80033c:	eb 14                	jmp    800352 <printnum+0xb2>
			putch(padc, putdat);
  80033e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800342:	8b 45 18             	mov    0x18(%ebp),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	ff d3                	call   *%ebx
		while (--width > 0)
  80034a:	83 ee 01             	sub    $0x1,%esi
  80034d:	75 ef                	jne    80033e <printnum+0x9e>
  80034f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800352:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800356:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80035a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80035d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800360:	89 44 24 08          	mov    %eax,0x8(%esp)
  800364:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800368:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036b:	89 04 24             	mov    %eax,(%esp)
  80036e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800371:	89 44 24 04          	mov    %eax,0x4(%esp)
  800375:	e8 f6 20 00 00       	call   802470 <__umoddi3>
  80037a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80037e:	0f be 80 67 26 80 00 	movsbl 0x802667(%eax),%eax
  800385:	89 04 24             	mov    %eax,(%esp)
  800388:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80038b:	ff d0                	call   *%eax
}
  80038d:	83 c4 3c             	add    $0x3c,%esp
  800390:	5b                   	pop    %ebx
  800391:	5e                   	pop    %esi
  800392:	5f                   	pop    %edi
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800398:	83 fa 01             	cmp    $0x1,%edx
  80039b:	7e 0e                	jle    8003ab <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80039d:	8b 10                	mov    (%eax),%edx
  80039f:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a2:	89 08                	mov    %ecx,(%eax)
  8003a4:	8b 02                	mov    (%edx),%eax
  8003a6:	8b 52 04             	mov    0x4(%edx),%edx
  8003a9:	eb 22                	jmp    8003cd <getuint+0x38>
	else if (lflag)
  8003ab:	85 d2                	test   %edx,%edx
  8003ad:	74 10                	je     8003bf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003af:	8b 10                	mov    (%eax),%edx
  8003b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b4:	89 08                	mov    %ecx,(%eax)
  8003b6:	8b 02                	mov    (%edx),%eax
  8003b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bd:	eb 0e                	jmp    8003cd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003bf:	8b 10                	mov    (%eax),%edx
  8003c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c4:	89 08                	mov    %ecx,(%eax)
  8003c6:	8b 02                	mov    (%edx),%eax
  8003c8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	3b 50 04             	cmp    0x4(%eax),%edx
  8003de:	73 0a                	jae    8003ea <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e8:	88 02                	mov    %al,(%edx)
}
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <printfmt>:
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8003f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800400:	8b 45 0c             	mov    0xc(%ebp),%eax
  800403:	89 44 24 04          	mov    %eax,0x4(%esp)
  800407:	8b 45 08             	mov    0x8(%ebp),%eax
  80040a:	89 04 24             	mov    %eax,(%esp)
  80040d:	e8 02 00 00 00       	call   800414 <vprintfmt>
}
  800412:	c9                   	leave  
  800413:	c3                   	ret    

00800414 <vprintfmt>:
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	57                   	push   %edi
  800418:	56                   	push   %esi
  800419:	53                   	push   %ebx
  80041a:	83 ec 3c             	sub    $0x3c,%esp
  80041d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800420:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800423:	eb 18                	jmp    80043d <vprintfmt+0x29>
			if (ch == '\0')
  800425:	85 c0                	test   %eax,%eax
  800427:	0f 84 c3 03 00 00    	je     8007f0 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80042d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800431:	89 04 24             	mov    %eax,(%esp)
  800434:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800437:	89 f3                	mov    %esi,%ebx
  800439:	eb 02                	jmp    80043d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80043b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80043d:	8d 73 01             	lea    0x1(%ebx),%esi
  800440:	0f b6 03             	movzbl (%ebx),%eax
  800443:	83 f8 25             	cmp    $0x25,%eax
  800446:	75 dd                	jne    800425 <vprintfmt+0x11>
  800448:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80044c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800453:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80045a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800461:	ba 00 00 00 00       	mov    $0x0,%edx
  800466:	eb 1d                	jmp    800485 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800468:	89 de                	mov    %ebx,%esi
			padc = '-';
  80046a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80046e:	eb 15                	jmp    800485 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800470:	89 de                	mov    %ebx,%esi
			padc = '0';
  800472:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800476:	eb 0d                	jmp    800485 <vprintfmt+0x71>
				width = precision, precision = -1;
  800478:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80047b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80047e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8d 5e 01             	lea    0x1(%esi),%ebx
  800488:	0f b6 06             	movzbl (%esi),%eax
  80048b:	0f b6 c8             	movzbl %al,%ecx
  80048e:	83 e8 23             	sub    $0x23,%eax
  800491:	3c 55                	cmp    $0x55,%al
  800493:	0f 87 2f 03 00 00    	ja     8007c8 <vprintfmt+0x3b4>
  800499:	0f b6 c0             	movzbl %al,%eax
  80049c:	ff 24 85 a0 27 80 00 	jmp    *0x8027a0(,%eax,4)
				precision = precision * 10 + ch - '0';
  8004a3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8004a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  8004a9:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004ad:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004b0:	83 f9 09             	cmp    $0x9,%ecx
  8004b3:	77 50                	ja     800505 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	89 de                	mov    %ebx,%esi
  8004b7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8004ba:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004bd:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004c0:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004c4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004c7:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004ca:	83 fb 09             	cmp    $0x9,%ebx
  8004cd:	76 eb                	jbe    8004ba <vprintfmt+0xa6>
  8004cf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004d2:	eb 33                	jmp    800507 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8d 48 04             	lea    0x4(%eax),%ecx
  8004da:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004dd:	8b 00                	mov    (%eax),%eax
  8004df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8004e4:	eb 21                	jmp    800507 <vprintfmt+0xf3>
  8004e6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004e9:	85 c9                	test   %ecx,%ecx
  8004eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f0:	0f 49 c1             	cmovns %ecx,%eax
  8004f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	89 de                	mov    %ebx,%esi
  8004f8:	eb 8b                	jmp    800485 <vprintfmt+0x71>
  8004fa:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8004fc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800503:	eb 80                	jmp    800485 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800505:	89 de                	mov    %ebx,%esi
			if (width < 0)
  800507:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050b:	0f 89 74 ff ff ff    	jns    800485 <vprintfmt+0x71>
  800511:	e9 62 ff ff ff       	jmp    800478 <vprintfmt+0x64>
			lflag++;
  800516:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800519:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80051b:	e9 65 ff ff ff       	jmp    800485 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 04             	lea    0x4(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052d:	8b 00                	mov    (%eax),%eax
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	ff 55 08             	call   *0x8(%ebp)
			break;
  800535:	e9 03 ff ff ff       	jmp    80043d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 50 04             	lea    0x4(%eax),%edx
  800540:	89 55 14             	mov    %edx,0x14(%ebp)
  800543:	8b 00                	mov    (%eax),%eax
  800545:	99                   	cltd   
  800546:	31 d0                	xor    %edx,%eax
  800548:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054a:	83 f8 0f             	cmp    $0xf,%eax
  80054d:	7f 0b                	jg     80055a <vprintfmt+0x146>
  80054f:	8b 14 85 00 29 80 00 	mov    0x802900(,%eax,4),%edx
  800556:	85 d2                	test   %edx,%edx
  800558:	75 20                	jne    80057a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80055a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055e:	c7 44 24 08 7f 26 80 	movl   $0x80267f,0x8(%esp)
  800565:	00 
  800566:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056a:	8b 45 08             	mov    0x8(%ebp),%eax
  80056d:	89 04 24             	mov    %eax,(%esp)
  800570:	e8 77 fe ff ff       	call   8003ec <printfmt>
  800575:	e9 c3 fe ff ff       	jmp    80043d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80057a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80057e:	c7 44 24 08 b3 2b 80 	movl   $0x802bb3,0x8(%esp)
  800585:	00 
  800586:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058a:	8b 45 08             	mov    0x8(%ebp),%eax
  80058d:	89 04 24             	mov    %eax,(%esp)
  800590:	e8 57 fe ff ff       	call   8003ec <printfmt>
  800595:	e9 a3 fe ff ff       	jmp    80043d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80059d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8d 50 04             	lea    0x4(%eax),%edx
  8005a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	ba 78 26 80 00       	mov    $0x802678,%edx
  8005b2:	0f 45 d0             	cmovne %eax,%edx
  8005b5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8005b8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8005bc:	74 04                	je     8005c2 <vprintfmt+0x1ae>
  8005be:	85 f6                	test   %esi,%esi
  8005c0:	7f 19                	jg     8005db <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005c5:	8d 70 01             	lea    0x1(%eax),%esi
  8005c8:	0f b6 10             	movzbl (%eax),%edx
  8005cb:	0f be c2             	movsbl %dl,%eax
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	0f 85 95 00 00 00    	jne    80066b <vprintfmt+0x257>
  8005d6:	e9 85 00 00 00       	jmp    800660 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005df:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005e2:	89 04 24             	mov    %eax,(%esp)
  8005e5:	e8 b8 02 00 00       	call   8008a2 <strnlen>
  8005ea:	29 c6                	sub    %eax,%esi
  8005ec:	89 f0                	mov    %esi,%eax
  8005ee:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8005f1:	85 f6                	test   %esi,%esi
  8005f3:	7e cd                	jle    8005c2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8005f5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8005f9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005fc:	89 c3                	mov    %eax,%ebx
  8005fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800602:	89 34 24             	mov    %esi,(%esp)
  800605:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800608:	83 eb 01             	sub    $0x1,%ebx
  80060b:	75 f1                	jne    8005fe <vprintfmt+0x1ea>
  80060d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800610:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800613:	eb ad                	jmp    8005c2 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800615:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800619:	74 1e                	je     800639 <vprintfmt+0x225>
  80061b:	0f be d2             	movsbl %dl,%edx
  80061e:	83 ea 20             	sub    $0x20,%edx
  800621:	83 fa 5e             	cmp    $0x5e,%edx
  800624:	76 13                	jbe    800639 <vprintfmt+0x225>
					putch('?', putdat);
  800626:	8b 45 0c             	mov    0xc(%ebp),%eax
  800629:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800634:	ff 55 08             	call   *0x8(%ebp)
  800637:	eb 0d                	jmp    800646 <vprintfmt+0x232>
					putch(ch, putdat);
  800639:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80063c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800640:	89 04 24             	mov    %eax,(%esp)
  800643:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800646:	83 ef 01             	sub    $0x1,%edi
  800649:	83 c6 01             	add    $0x1,%esi
  80064c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800650:	0f be c2             	movsbl %dl,%eax
  800653:	85 c0                	test   %eax,%eax
  800655:	75 20                	jne    800677 <vprintfmt+0x263>
  800657:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80065a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80065d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800660:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800664:	7f 25                	jg     80068b <vprintfmt+0x277>
  800666:	e9 d2 fd ff ff       	jmp    80043d <vprintfmt+0x29>
  80066b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80066e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800671:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800674:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800677:	85 db                	test   %ebx,%ebx
  800679:	78 9a                	js     800615 <vprintfmt+0x201>
  80067b:	83 eb 01             	sub    $0x1,%ebx
  80067e:	79 95                	jns    800615 <vprintfmt+0x201>
  800680:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800683:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800686:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800689:	eb d5                	jmp    800660 <vprintfmt+0x24c>
  80068b:	8b 75 08             	mov    0x8(%ebp),%esi
  80068e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800691:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  800694:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800698:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80069f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006a1:	83 eb 01             	sub    $0x1,%ebx
  8006a4:	75 ee                	jne    800694 <vprintfmt+0x280>
  8006a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006a9:	e9 8f fd ff ff       	jmp    80043d <vprintfmt+0x29>
	if (lflag >= 2)
  8006ae:	83 fa 01             	cmp    $0x1,%edx
  8006b1:	7e 16                	jle    8006c9 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8d 50 08             	lea    0x8(%eax),%edx
  8006b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bc:	8b 50 04             	mov    0x4(%eax),%edx
  8006bf:	8b 00                	mov    (%eax),%eax
  8006c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c7:	eb 32                	jmp    8006fb <vprintfmt+0x2e7>
	else if (lflag)
  8006c9:	85 d2                	test   %edx,%edx
  8006cb:	74 18                	je     8006e5 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8d 50 04             	lea    0x4(%eax),%edx
  8006d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d6:	8b 30                	mov    (%eax),%esi
  8006d8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006db:	89 f0                	mov    %esi,%eax
  8006dd:	c1 f8 1f             	sar    $0x1f,%eax
  8006e0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006e3:	eb 16                	jmp    8006fb <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8d 50 04             	lea    0x4(%eax),%edx
  8006eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ee:	8b 30                	mov    (%eax),%esi
  8006f0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006f3:	89 f0                	mov    %esi,%eax
  8006f5:	c1 f8 1f             	sar    $0x1f,%eax
  8006f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  8006fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  800701:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800706:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80070a:	0f 89 80 00 00 00    	jns    800790 <vprintfmt+0x37c>
				putch('-', putdat);
  800710:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800714:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80071b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80071e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800721:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800724:	f7 d8                	neg    %eax
  800726:	83 d2 00             	adc    $0x0,%edx
  800729:	f7 da                	neg    %edx
			base = 10;
  80072b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800730:	eb 5e                	jmp    800790 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800732:	8d 45 14             	lea    0x14(%ebp),%eax
  800735:	e8 5b fc ff ff       	call   800395 <getuint>
			base = 10;
  80073a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80073f:	eb 4f                	jmp    800790 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800741:	8d 45 14             	lea    0x14(%ebp),%eax
  800744:	e8 4c fc ff ff       	call   800395 <getuint>
			base = 8;
  800749:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80074e:	eb 40                	jmp    800790 <vprintfmt+0x37c>
			putch('0', putdat);
  800750:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800754:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80075b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80075e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800762:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800769:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8d 50 04             	lea    0x4(%eax),%edx
  800772:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800775:	8b 00                	mov    (%eax),%eax
  800777:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80077c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800781:	eb 0d                	jmp    800790 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
  800786:	e8 0a fc ff ff       	call   800395 <getuint>
			base = 16;
  80078b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800790:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800794:	89 74 24 10          	mov    %esi,0x10(%esp)
  800798:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80079b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80079f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007a3:	89 04 24             	mov    %eax,(%esp)
  8007a6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007aa:	89 fa                	mov    %edi,%edx
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	e8 ec fa ff ff       	call   8002a0 <printnum>
			break;
  8007b4:	e9 84 fc ff ff       	jmp    80043d <vprintfmt+0x29>
			putch(ch, putdat);
  8007b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007bd:	89 0c 24             	mov    %ecx,(%esp)
  8007c0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007c3:	e9 75 fc ff ff       	jmp    80043d <vprintfmt+0x29>
			putch('%', putdat);
  8007c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007cc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007d3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007da:	0f 84 5b fc ff ff    	je     80043b <vprintfmt+0x27>
  8007e0:	89 f3                	mov    %esi,%ebx
  8007e2:	83 eb 01             	sub    $0x1,%ebx
  8007e5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007e9:	75 f7                	jne    8007e2 <vprintfmt+0x3ce>
  8007eb:	e9 4d fc ff ff       	jmp    80043d <vprintfmt+0x29>
}
  8007f0:	83 c4 3c             	add    $0x3c,%esp
  8007f3:	5b                   	pop    %ebx
  8007f4:	5e                   	pop    %esi
  8007f5:	5f                   	pop    %edi
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	83 ec 28             	sub    $0x28,%esp
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800804:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800807:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80080b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80080e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800815:	85 c0                	test   %eax,%eax
  800817:	74 30                	je     800849 <vsnprintf+0x51>
  800819:	85 d2                	test   %edx,%edx
  80081b:	7e 2c                	jle    800849 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800824:	8b 45 10             	mov    0x10(%ebp),%eax
  800827:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800832:	c7 04 24 cf 03 80 00 	movl   $0x8003cf,(%esp)
  800839:	e8 d6 fb ff ff       	call   800414 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800841:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800844:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800847:	eb 05                	jmp    80084e <vsnprintf+0x56>
		return -E_INVAL;
  800849:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80084e:	c9                   	leave  
  80084f:	c3                   	ret    

00800850 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800856:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800859:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085d:	8b 45 10             	mov    0x10(%ebp),%eax
  800860:	89 44 24 08          	mov    %eax,0x8(%esp)
  800864:	8b 45 0c             	mov    0xc(%ebp),%eax
  800867:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	89 04 24             	mov    %eax,(%esp)
  800871:	e8 82 ff ff ff       	call   8007f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800876:	c9                   	leave  
  800877:	c3                   	ret    
  800878:	66 90                	xchg   %ax,%ax
  80087a:	66 90                	xchg   %ax,%ax
  80087c:	66 90                	xchg   %ax,%ax
  80087e:	66 90                	xchg   %ax,%ax

00800880 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800886:	80 3a 00             	cmpb   $0x0,(%edx)
  800889:	74 10                	je     80089b <strlen+0x1b>
  80088b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800890:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800893:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800897:	75 f7                	jne    800890 <strlen+0x10>
  800899:	eb 05                	jmp    8008a0 <strlen+0x20>
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ac:	85 c9                	test   %ecx,%ecx
  8008ae:	74 1c                	je     8008cc <strnlen+0x2a>
  8008b0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008b3:	74 1e                	je     8008d3 <strnlen+0x31>
  8008b5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008ba:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bc:	39 ca                	cmp    %ecx,%edx
  8008be:	74 18                	je     8008d8 <strnlen+0x36>
  8008c0:	83 c2 01             	add    $0x1,%edx
  8008c3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008c8:	75 f0                	jne    8008ba <strnlen+0x18>
  8008ca:	eb 0c                	jmp    8008d8 <strnlen+0x36>
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d1:	eb 05                	jmp    8008d8 <strnlen+0x36>
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e5:	89 c2                	mov    %eax,%edx
  8008e7:	83 c2 01             	add    $0x1,%edx
  8008ea:	83 c1 01             	add    $0x1,%ecx
  8008ed:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008f1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f4:	84 db                	test   %bl,%bl
  8008f6:	75 ef                	jne    8008e7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	53                   	push   %ebx
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800905:	89 1c 24             	mov    %ebx,(%esp)
  800908:	e8 73 ff ff ff       	call   800880 <strlen>
	strcpy(dst + len, src);
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 54 24 04          	mov    %edx,0x4(%esp)
  800914:	01 d8                	add    %ebx,%eax
  800916:	89 04 24             	mov    %eax,(%esp)
  800919:	e8 bd ff ff ff       	call   8008db <strcpy>
	return dst;
}
  80091e:	89 d8                	mov    %ebx,%eax
  800920:	83 c4 08             	add    $0x8,%esp
  800923:	5b                   	pop    %ebx
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 75 08             	mov    0x8(%ebp),%esi
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800931:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800934:	85 db                	test   %ebx,%ebx
  800936:	74 17                	je     80094f <strncpy+0x29>
  800938:	01 f3                	add    %esi,%ebx
  80093a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80093c:	83 c1 01             	add    $0x1,%ecx
  80093f:	0f b6 02             	movzbl (%edx),%eax
  800942:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800945:	80 3a 01             	cmpb   $0x1,(%edx)
  800948:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80094b:	39 d9                	cmp    %ebx,%ecx
  80094d:	75 ed                	jne    80093c <strncpy+0x16>
	}
	return ret;
}
  80094f:	89 f0                	mov    %esi,%eax
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	57                   	push   %edi
  800959:	56                   	push   %esi
  80095a:	53                   	push   %ebx
  80095b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800961:	8b 75 10             	mov    0x10(%ebp),%esi
  800964:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800966:	85 f6                	test   %esi,%esi
  800968:	74 34                	je     80099e <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  80096a:	83 fe 01             	cmp    $0x1,%esi
  80096d:	74 26                	je     800995 <strlcpy+0x40>
  80096f:	0f b6 0b             	movzbl (%ebx),%ecx
  800972:	84 c9                	test   %cl,%cl
  800974:	74 23                	je     800999 <strlcpy+0x44>
  800976:	83 ee 02             	sub    $0x2,%esi
  800979:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  80097e:	83 c0 01             	add    $0x1,%eax
  800981:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800984:	39 f2                	cmp    %esi,%edx
  800986:	74 13                	je     80099b <strlcpy+0x46>
  800988:	83 c2 01             	add    $0x1,%edx
  80098b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80098f:	84 c9                	test   %cl,%cl
  800991:	75 eb                	jne    80097e <strlcpy+0x29>
  800993:	eb 06                	jmp    80099b <strlcpy+0x46>
  800995:	89 f8                	mov    %edi,%eax
  800997:	eb 02                	jmp    80099b <strlcpy+0x46>
  800999:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  80099b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099e:	29 f8                	sub    %edi,%eax
}
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5f                   	pop    %edi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ae:	0f b6 01             	movzbl (%ecx),%eax
  8009b1:	84 c0                	test   %al,%al
  8009b3:	74 15                	je     8009ca <strcmp+0x25>
  8009b5:	3a 02                	cmp    (%edx),%al
  8009b7:	75 11                	jne    8009ca <strcmp+0x25>
		p++, q++;
  8009b9:	83 c1 01             	add    $0x1,%ecx
  8009bc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009bf:	0f b6 01             	movzbl (%ecx),%eax
  8009c2:	84 c0                	test   %al,%al
  8009c4:	74 04                	je     8009ca <strcmp+0x25>
  8009c6:	3a 02                	cmp    (%edx),%al
  8009c8:	74 ef                	je     8009b9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ca:	0f b6 c0             	movzbl %al,%eax
  8009cd:	0f b6 12             	movzbl (%edx),%edx
  8009d0:	29 d0                	sub    %edx,%eax
}
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009df:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009e2:	85 f6                	test   %esi,%esi
  8009e4:	74 29                	je     800a0f <strncmp+0x3b>
  8009e6:	0f b6 03             	movzbl (%ebx),%eax
  8009e9:	84 c0                	test   %al,%al
  8009eb:	74 30                	je     800a1d <strncmp+0x49>
  8009ed:	3a 02                	cmp    (%edx),%al
  8009ef:	75 2c                	jne    800a1d <strncmp+0x49>
  8009f1:	8d 43 01             	lea    0x1(%ebx),%eax
  8009f4:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8009f6:	89 c3                	mov    %eax,%ebx
  8009f8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009fb:	39 f0                	cmp    %esi,%eax
  8009fd:	74 17                	je     800a16 <strncmp+0x42>
  8009ff:	0f b6 08             	movzbl (%eax),%ecx
  800a02:	84 c9                	test   %cl,%cl
  800a04:	74 17                	je     800a1d <strncmp+0x49>
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	3a 0a                	cmp    (%edx),%cl
  800a0b:	74 e9                	je     8009f6 <strncmp+0x22>
  800a0d:	eb 0e                	jmp    800a1d <strncmp+0x49>
	if (n == 0)
		return 0;
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a14:	eb 0f                	jmp    800a25 <strncmp+0x51>
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1b:	eb 08                	jmp    800a25 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1d:	0f b6 03             	movzbl (%ebx),%eax
  800a20:	0f b6 12             	movzbl (%edx),%edx
  800a23:	29 d0                	sub    %edx,%eax
}
  800a25:	5b                   	pop    %ebx
  800a26:	5e                   	pop    %esi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	53                   	push   %ebx
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a33:	0f b6 18             	movzbl (%eax),%ebx
  800a36:	84 db                	test   %bl,%bl
  800a38:	74 1d                	je     800a57 <strchr+0x2e>
  800a3a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a3c:	38 d3                	cmp    %dl,%bl
  800a3e:	75 06                	jne    800a46 <strchr+0x1d>
  800a40:	eb 1a                	jmp    800a5c <strchr+0x33>
  800a42:	38 ca                	cmp    %cl,%dl
  800a44:	74 16                	je     800a5c <strchr+0x33>
	for (; *s; s++)
  800a46:	83 c0 01             	add    $0x1,%eax
  800a49:	0f b6 10             	movzbl (%eax),%edx
  800a4c:	84 d2                	test   %dl,%dl
  800a4e:	75 f2                	jne    800a42 <strchr+0x19>
			return (char *) s;
	return 0;
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
  800a55:	eb 05                	jmp    800a5c <strchr+0x33>
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5c:	5b                   	pop    %ebx
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	53                   	push   %ebx
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a69:	0f b6 18             	movzbl (%eax),%ebx
  800a6c:	84 db                	test   %bl,%bl
  800a6e:	74 16                	je     800a86 <strfind+0x27>
  800a70:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a72:	38 d3                	cmp    %dl,%bl
  800a74:	75 06                	jne    800a7c <strfind+0x1d>
  800a76:	eb 0e                	jmp    800a86 <strfind+0x27>
  800a78:	38 ca                	cmp    %cl,%dl
  800a7a:	74 0a                	je     800a86 <strfind+0x27>
	for (; *s; s++)
  800a7c:	83 c0 01             	add    $0x1,%eax
  800a7f:	0f b6 10             	movzbl (%eax),%edx
  800a82:	84 d2                	test   %dl,%dl
  800a84:	75 f2                	jne    800a78 <strfind+0x19>
			break;
	return (char *) s;
}
  800a86:	5b                   	pop    %ebx
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	57                   	push   %edi
  800a8d:	56                   	push   %esi
  800a8e:	53                   	push   %ebx
  800a8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a95:	85 c9                	test   %ecx,%ecx
  800a97:	74 36                	je     800acf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a99:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9f:	75 28                	jne    800ac9 <memset+0x40>
  800aa1:	f6 c1 03             	test   $0x3,%cl
  800aa4:	75 23                	jne    800ac9 <memset+0x40>
		c &= 0xFF;
  800aa6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aaa:	89 d3                	mov    %edx,%ebx
  800aac:	c1 e3 08             	shl    $0x8,%ebx
  800aaf:	89 d6                	mov    %edx,%esi
  800ab1:	c1 e6 18             	shl    $0x18,%esi
  800ab4:	89 d0                	mov    %edx,%eax
  800ab6:	c1 e0 10             	shl    $0x10,%eax
  800ab9:	09 f0                	or     %esi,%eax
  800abb:	09 c2                	or     %eax,%edx
  800abd:	89 d0                	mov    %edx,%eax
  800abf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ac1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ac4:	fc                   	cld    
  800ac5:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac7:	eb 06                	jmp    800acf <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acc:	fc                   	cld    
  800acd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800acf:	89 f8                	mov    %edi,%eax
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	57                   	push   %edi
  800ada:	56                   	push   %esi
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae4:	39 c6                	cmp    %eax,%esi
  800ae6:	73 35                	jae    800b1d <memmove+0x47>
  800ae8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aeb:	39 d0                	cmp    %edx,%eax
  800aed:	73 2e                	jae    800b1d <memmove+0x47>
		s += n;
		d += n;
  800aef:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800af2:	89 d6                	mov    %edx,%esi
  800af4:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800afc:	75 13                	jne    800b11 <memmove+0x3b>
  800afe:	f6 c1 03             	test   $0x3,%cl
  800b01:	75 0e                	jne    800b11 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b03:	83 ef 04             	sub    $0x4,%edi
  800b06:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b09:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b0c:	fd                   	std    
  800b0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0f:	eb 09                	jmp    800b1a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b11:	83 ef 01             	sub    $0x1,%edi
  800b14:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b17:	fd                   	std    
  800b18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b1a:	fc                   	cld    
  800b1b:	eb 1d                	jmp    800b3a <memmove+0x64>
  800b1d:	89 f2                	mov    %esi,%edx
  800b1f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b21:	f6 c2 03             	test   $0x3,%dl
  800b24:	75 0f                	jne    800b35 <memmove+0x5f>
  800b26:	f6 c1 03             	test   $0x3,%cl
  800b29:	75 0a                	jne    800b35 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b2b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b2e:	89 c7                	mov    %eax,%edi
  800b30:	fc                   	cld    
  800b31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b33:	eb 05                	jmp    800b3a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800b35:	89 c7                	mov    %eax,%edi
  800b37:	fc                   	cld    
  800b38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b44:	8b 45 10             	mov    0x10(%ebp),%eax
  800b47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	89 04 24             	mov    %eax,(%esp)
  800b58:	e8 79 ff ff ff       	call   800ad6 <memmove>
}
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b71:	85 c0                	test   %eax,%eax
  800b73:	74 36                	je     800bab <memcmp+0x4c>
		if (*s1 != *s2)
  800b75:	0f b6 03             	movzbl (%ebx),%eax
  800b78:	0f b6 0e             	movzbl (%esi),%ecx
  800b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b80:	38 c8                	cmp    %cl,%al
  800b82:	74 1c                	je     800ba0 <memcmp+0x41>
  800b84:	eb 10                	jmp    800b96 <memcmp+0x37>
  800b86:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b8b:	83 c2 01             	add    $0x1,%edx
  800b8e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b92:	38 c8                	cmp    %cl,%al
  800b94:	74 0a                	je     800ba0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b96:	0f b6 c0             	movzbl %al,%eax
  800b99:	0f b6 c9             	movzbl %cl,%ecx
  800b9c:	29 c8                	sub    %ecx,%eax
  800b9e:	eb 10                	jmp    800bb0 <memcmp+0x51>
	while (n-- > 0) {
  800ba0:	39 fa                	cmp    %edi,%edx
  800ba2:	75 e2                	jne    800b86 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba9:	eb 05                	jmp    800bb0 <memcmp+0x51>
  800bab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	53                   	push   %ebx
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800bbf:	89 c2                	mov    %eax,%edx
  800bc1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bc4:	39 d0                	cmp    %edx,%eax
  800bc6:	73 13                	jae    800bdb <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc8:	89 d9                	mov    %ebx,%ecx
  800bca:	38 18                	cmp    %bl,(%eax)
  800bcc:	75 06                	jne    800bd4 <memfind+0x1f>
  800bce:	eb 0b                	jmp    800bdb <memfind+0x26>
  800bd0:	38 08                	cmp    %cl,(%eax)
  800bd2:	74 07                	je     800bdb <memfind+0x26>
	for (; s < ends; s++)
  800bd4:	83 c0 01             	add    $0x1,%eax
  800bd7:	39 d0                	cmp    %edx,%eax
  800bd9:	75 f5                	jne    800bd0 <memfind+0x1b>
			break;
	return (void *) s;
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bea:	0f b6 0a             	movzbl (%edx),%ecx
  800bed:	80 f9 09             	cmp    $0x9,%cl
  800bf0:	74 05                	je     800bf7 <strtol+0x19>
  800bf2:	80 f9 20             	cmp    $0x20,%cl
  800bf5:	75 10                	jne    800c07 <strtol+0x29>
		s++;
  800bf7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800bfa:	0f b6 0a             	movzbl (%edx),%ecx
  800bfd:	80 f9 09             	cmp    $0x9,%cl
  800c00:	74 f5                	je     800bf7 <strtol+0x19>
  800c02:	80 f9 20             	cmp    $0x20,%cl
  800c05:	74 f0                	je     800bf7 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800c07:	80 f9 2b             	cmp    $0x2b,%cl
  800c0a:	75 0a                	jne    800c16 <strtol+0x38>
		s++;
  800c0c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c0f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c14:	eb 11                	jmp    800c27 <strtol+0x49>
  800c16:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800c1b:	80 f9 2d             	cmp    $0x2d,%cl
  800c1e:	75 07                	jne    800c27 <strtol+0x49>
		s++, neg = 1;
  800c20:	83 c2 01             	add    $0x1,%edx
  800c23:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c27:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c2c:	75 15                	jne    800c43 <strtol+0x65>
  800c2e:	80 3a 30             	cmpb   $0x30,(%edx)
  800c31:	75 10                	jne    800c43 <strtol+0x65>
  800c33:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c37:	75 0a                	jne    800c43 <strtol+0x65>
		s += 2, base = 16;
  800c39:	83 c2 02             	add    $0x2,%edx
  800c3c:	b8 10 00 00 00       	mov    $0x10,%eax
  800c41:	eb 10                	jmp    800c53 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800c43:	85 c0                	test   %eax,%eax
  800c45:	75 0c                	jne    800c53 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c47:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800c49:	80 3a 30             	cmpb   $0x30,(%edx)
  800c4c:	75 05                	jne    800c53 <strtol+0x75>
		s++, base = 8;
  800c4e:	83 c2 01             	add    $0x1,%edx
  800c51:	b0 08                	mov    $0x8,%al
		base = 10;
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c5b:	0f b6 0a             	movzbl (%edx),%ecx
  800c5e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c61:	89 f0                	mov    %esi,%eax
  800c63:	3c 09                	cmp    $0x9,%al
  800c65:	77 08                	ja     800c6f <strtol+0x91>
			dig = *s - '0';
  800c67:	0f be c9             	movsbl %cl,%ecx
  800c6a:	83 e9 30             	sub    $0x30,%ecx
  800c6d:	eb 20                	jmp    800c8f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800c6f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c72:	89 f0                	mov    %esi,%eax
  800c74:	3c 19                	cmp    $0x19,%al
  800c76:	77 08                	ja     800c80 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c78:	0f be c9             	movsbl %cl,%ecx
  800c7b:	83 e9 57             	sub    $0x57,%ecx
  800c7e:	eb 0f                	jmp    800c8f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800c80:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c83:	89 f0                	mov    %esi,%eax
  800c85:	3c 19                	cmp    $0x19,%al
  800c87:	77 16                	ja     800c9f <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c89:	0f be c9             	movsbl %cl,%ecx
  800c8c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c8f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c92:	7d 0f                	jge    800ca3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c94:	83 c2 01             	add    $0x1,%edx
  800c97:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c9b:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c9d:	eb bc                	jmp    800c5b <strtol+0x7d>
  800c9f:	89 d8                	mov    %ebx,%eax
  800ca1:	eb 02                	jmp    800ca5 <strtol+0xc7>
  800ca3:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800ca5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca9:	74 05                	je     800cb0 <strtol+0xd2>
		*endptr = (char *) s;
  800cab:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cae:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800cb0:	f7 d8                	neg    %eax
  800cb2:	85 ff                	test   %edi,%edi
  800cb4:	0f 44 c3             	cmove  %ebx,%eax
}
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 c3                	mov    %eax,%ebx
  800ccf:	89 c7                	mov    %eax,%edi
  800cd1:	89 c6                	mov    %eax,%esi
  800cd3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_cgetc>:

int
sys_cgetc(void)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cea:	89 d1                	mov    %edx,%ecx
  800cec:	89 d3                	mov    %edx,%ebx
  800cee:	89 d7                	mov    %edx,%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d07:	b8 03 00 00 00       	mov    $0x3,%eax
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	89 cb                	mov    %ecx,%ebx
  800d11:	89 cf                	mov    %ecx,%edi
  800d13:	89 ce                	mov    %ecx,%esi
  800d15:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d17:	85 c0                	test   %eax,%eax
  800d19:	7e 28                	jle    800d43 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d26:	00 
  800d27:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800d2e:	00 
  800d2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d36:	00 
  800d37:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800d3e:	e8 41 f4 ff ff       	call   800184 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d43:	83 c4 2c             	add    $0x2c,%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d51:	ba 00 00 00 00       	mov    $0x0,%edx
  800d56:	b8 02 00 00 00       	mov    $0x2,%eax
  800d5b:	89 d1                	mov    %edx,%ecx
  800d5d:	89 d3                	mov    %edx,%ebx
  800d5f:	89 d7                	mov    %edx,%edi
  800d61:	89 d6                	mov    %edx,%esi
  800d63:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <sys_yield>:

void
sys_yield(void)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d70:	ba 00 00 00 00       	mov    $0x0,%edx
  800d75:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d7a:	89 d1                	mov    %edx,%ecx
  800d7c:	89 d3                	mov    %edx,%ebx
  800d7e:	89 d7                	mov    %edx,%edi
  800d80:	89 d6                	mov    %edx,%esi
  800d82:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d92:	be 00 00 00 00       	mov    $0x0,%esi
  800d97:	b8 04 00 00 00       	mov    $0x4,%eax
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da5:	89 f7                	mov    %esi,%edi
  800da7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 28                	jle    800dd5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800db8:	00 
  800db9:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800dc0:	00 
  800dc1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc8:	00 
  800dc9:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800dd0:	e8 af f3 ff ff       	call   800184 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dd5:	83 c4 2c             	add    $0x2c,%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800de6:	b8 05 00 00 00       	mov    $0x5,%eax
  800deb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dee:	8b 55 08             	mov    0x8(%ebp),%edx
  800df1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df7:	8b 75 18             	mov    0x18(%ebp),%esi
  800dfa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	7e 28                	jle    800e28 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e00:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e04:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e0b:	00 
  800e0c:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800e13:	00 
  800e14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1b:	00 
  800e1c:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800e23:	e8 5c f3 ff ff       	call   800184 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e28:	83 c4 2c             	add    $0x2c,%esp
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5f                   	pop    %edi
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	57                   	push   %edi
  800e34:	56                   	push   %esi
  800e35:	53                   	push   %ebx
  800e36:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	89 df                	mov    %ebx,%edi
  800e4b:	89 de                	mov    %ebx,%esi
  800e4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	7e 28                	jle    800e7b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e53:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e57:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e5e:	00 
  800e5f:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800e66:	00 
  800e67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6e:	00 
  800e6f:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800e76:	e8 09 f3 ff ff       	call   800184 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e7b:	83 c4 2c             	add    $0x2c,%esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
  800e89:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e91:	b8 08 00 00 00       	mov    $0x8,%eax
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	89 df                	mov    %ebx,%edi
  800e9e:	89 de                	mov    %ebx,%esi
  800ea0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	7e 28                	jle    800ece <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eaa:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800eb1:	00 
  800eb2:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800eb9:	00 
  800eba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec1:	00 
  800ec2:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800ec9:	e8 b6 f2 ff ff       	call   800184 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ece:	83 c4 2c             	add    $0x2c,%esp
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	57                   	push   %edi
  800eda:	56                   	push   %esi
  800edb:	53                   	push   %ebx
  800edc:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800edf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ee9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eec:	8b 55 08             	mov    0x8(%ebp),%edx
  800eef:	89 df                	mov    %ebx,%edi
  800ef1:	89 de                	mov    %ebx,%esi
  800ef3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	7e 28                	jle    800f21 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f04:	00 
  800f05:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f14:	00 
  800f15:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800f1c:	e8 63 f2 ff ff       	call   800184 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f21:	83 c4 2c             	add    $0x2c,%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	57                   	push   %edi
  800f2d:	56                   	push   %esi
  800f2e:	53                   	push   %ebx
  800f2f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f37:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f42:	89 df                	mov    %ebx,%edi
  800f44:	89 de                	mov    %ebx,%esi
  800f46:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	7e 28                	jle    800f74 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f50:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f57:	00 
  800f58:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800f5f:	00 
  800f60:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f67:	00 
  800f68:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800f6f:	e8 10 f2 ff ff       	call   800184 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f74:	83 c4 2c             	add    $0x2c,%esp
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	57                   	push   %edi
  800f80:	56                   	push   %esi
  800f81:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f82:	be 00 00 00 00       	mov    $0x0,%esi
  800f87:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f95:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f98:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f9a:	5b                   	pop    %ebx
  800f9b:	5e                   	pop    %esi
  800f9c:	5f                   	pop    %edi
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    

00800f9f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	57                   	push   %edi
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
  800fa5:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800fa8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fad:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb5:	89 cb                	mov    %ecx,%ebx
  800fb7:	89 cf                	mov    %ecx,%edi
  800fb9:	89 ce                	mov    %ecx,%esi
  800fbb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	7e 28                	jle    800fe9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fcc:	00 
  800fcd:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800fd4:	00 
  800fd5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fdc:	00 
  800fdd:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800fe4:	e8 9b f1 ff ff       	call   800184 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fe9:	83 c4 2c             	add    $0x2c,%esp
  800fec:	5b                   	pop    %ebx
  800fed:	5e                   	pop    %esi
  800fee:	5f                   	pop    %edi
  800fef:	5d                   	pop    %ebp
  800ff0:	c3                   	ret    

00800ff1 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	53                   	push   %ebx
  800ff5:	83 ec 24             	sub    $0x24,%esp
  800ff8:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800ffb:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800ffd:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  801001:	74 2e                	je     801031 <pgfault+0x40>
  801003:	89 c2                	mov    %eax,%edx
  801005:	c1 ea 16             	shr    $0x16,%edx
  801008:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80100f:	f6 c2 01             	test   $0x1,%dl
  801012:	74 1d                	je     801031 <pgfault+0x40>
  801014:	89 c2                	mov    %eax,%edx
  801016:	c1 ea 0c             	shr    $0xc,%edx
  801019:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801020:	f6 c1 01             	test   $0x1,%cl
  801023:	74 0c                	je     801031 <pgfault+0x40>
  801025:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80102c:	f6 c6 08             	test   $0x8,%dh
  80102f:	75 20                	jne    801051 <pgfault+0x60>
		panic("pgfault: page cow check failed, addr=%x\n", addr);
  801031:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801035:	c7 44 24 08 8c 29 80 	movl   $0x80298c,0x8(%esp)
  80103c:	00 
  80103d:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  801044:	00 
  801045:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  80104c:	e8 33 f1 ff ff       	call   800184 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  801051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801056:	89 c3                	mov    %eax,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W))
  801058:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80105f:	00 
  801060:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801067:	00 
  801068:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80106f:	e8 15 fd ff ff       	call   800d89 <sys_page_alloc>
  801074:	85 c0                	test   %eax,%eax
  801076:	74 1c                	je     801094 <pgfault+0xa3>
		panic("pgfault: sys_page_alloc error");
  801078:	c7 44 24 08 7e 2a 80 	movl   $0x802a7e,0x8(%esp)
  80107f:	00 
  801080:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801087:	00 
  801088:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  80108f:	e8 f0 f0 ff ff       	call   800184 <_panic>

	memmove(PFTEMP, addr, PGSIZE);
  801094:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80109b:	00 
  80109c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010a0:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010a7:	e8 2a fa ff ff       	call   800ad6 <memmove>
	if(sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))
  8010ac:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010b3:	00 
  8010b4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010bf:	00 
  8010c0:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010c7:	00 
  8010c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010cf:	e8 09 fd ff ff       	call   800ddd <sys_page_map>
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	74 1c                	je     8010f4 <pgfault+0x103>
		panic("pgfault: sys_page_map error");
  8010d8:	c7 44 24 08 9c 2a 80 	movl   $0x802a9c,0x8(%esp)
  8010df:	00 
  8010e0:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8010e7:	00 
  8010e8:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  8010ef:	e8 90 f0 ff ff       	call   800184 <_panic>

	if(sys_page_unmap(0, PFTEMP))
  8010f4:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010fb:	00 
  8010fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801103:	e8 28 fd ff ff       	call   800e30 <sys_page_unmap>
  801108:	85 c0                	test   %eax,%eax
  80110a:	74 1c                	je     801128 <pgfault+0x137>
		panic("pgfault: sys_page_unmap error");
  80110c:	c7 44 24 08 b8 2a 80 	movl   $0x802ab8,0x8(%esp)
  801113:	00 
  801114:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80111b:	00 
  80111c:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  801123:	e8 5c f0 ff ff       	call   800184 <_panic>
}
  801128:	83 c4 24             	add    $0x24,%esp
  80112b:	5b                   	pop    %ebx
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	53                   	push   %ebx
  801134:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	//根据文档的描述，duppage好像不应该处理除了可写或者copy-on-write的部分，但这里都交给duppage一块处理了
	set_pgfault_handler(pgfault);
  801137:	c7 04 24 f1 0f 80 00 	movl   $0x800ff1,(%esp)
  80113e:	e8 23 10 00 00       	call   802166 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801143:	b8 07 00 00 00       	mov    $0x7,%eax
  801148:	cd 30                	int    $0x30
  80114a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();
	if(envid < 0)
  80114d:	85 c0                	test   %eax,%eax
  80114f:	79 1c                	jns    80116d <fork+0x3f>
		//失败
		panic("fork: sys_exofork error");
  801151:	c7 44 24 08 d6 2a 80 	movl   $0x802ad6,0x8(%esp)
  801158:	00 
  801159:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
  801160:	00 
  801161:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  801168:	e8 17 f0 ff ff       	call   800184 <_panic>
  80116d:	89 c7                	mov    %eax,%edi
	else if(!envid)
  80116f:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801174:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801178:	75 1c                	jne    801196 <fork+0x68>
		//子进程
		thisenv = &envs[ENVX(sys_getenvid())];
  80117a:	e8 cc fb ff ff       	call   800d4b <sys_getenvid>
  80117f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801184:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801187:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80118c:	a3 08 40 80 00       	mov    %eax,0x804008
  801191:	e9 fc 01 00 00       	jmp    801392 <fork+0x264>
	else{
		//父进程
		unsigned addr;
		for(addr = UTEXT; addr < USTACKTOP; addr += PGSIZE){
			if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))
  801196:	89 d8                	mov    %ebx,%eax
  801198:	c1 e8 16             	shr    $0x16,%eax
  80119b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011a2:	a8 01                	test   $0x1,%al
  8011a4:	0f 84 58 01 00 00    	je     801302 <fork+0x1d4>
  8011aa:	89 d8                	mov    %ebx,%eax
  8011ac:	c1 e8 0c             	shr    $0xc,%eax
  8011af:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011b6:	f6 c2 01             	test   $0x1,%dl
  8011b9:	0f 84 43 01 00 00    	je     801302 <fork+0x1d4>
  8011bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011c6:	f6 c2 04             	test   $0x4,%dl
  8011c9:	0f 84 33 01 00 00    	je     801302 <fork+0x1d4>
	void *addr = (void *)(pn * PGSIZE);
  8011cf:	89 c6                	mov    %eax,%esi
  8011d1:	c1 e6 0c             	shl    $0xc,%esi
	if(uvpt[pn] & PTE_SHARE){
  8011d4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011db:	f6 c6 04             	test   $0x4,%dh
  8011de:	74 4c                	je     80122c <fork+0xfe>
		if(sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL))
  8011e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8011ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011f4:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801203:	e8 d5 fb ff ff       	call   800ddd <sys_page_map>
  801208:	85 c0                	test   %eax,%eax
  80120a:	0f 84 f2 00 00 00    	je     801302 <fork+0x1d4>
			panic("duppage: sys_page_map pte_syscall error");
  801210:	c7 44 24 08 b8 29 80 	movl   $0x8029b8,0x8(%esp)
  801217:	00 
  801218:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80121f:	00 
  801220:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  801227:	e8 58 ef ff ff       	call   800184 <_panic>
	else if(uvpt[pn] & (PTE_W | PTE_COW)){
  80122c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801233:	a9 02 08 00 00       	test   $0x802,%eax
  801238:	0f 84 84 00 00 00    	je     8012c2 <fork+0x194>
		if(sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P))
  80123e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801245:	00 
  801246:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80124a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80124e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801252:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801259:	e8 7f fb ff ff       	call   800ddd <sys_page_map>
  80125e:	85 c0                	test   %eax,%eax
  801260:	74 1c                	je     80127e <fork+0x150>
			panic("duppage: sys_page_map child error");
  801262:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  801269:	00 
  80126a:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801271:	00 
  801272:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  801279:	e8 06 ef ff ff       	call   800184 <_panic>
		if(sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P))
  80127e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801285:	00 
  801286:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80128a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801291:	00 
  801292:	89 74 24 04          	mov    %esi,0x4(%esp)
  801296:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80129d:	e8 3b fb ff ff       	call   800ddd <sys_page_map>
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	74 5c                	je     801302 <fork+0x1d4>
			panic("duppage: sys_page_map remap parent error");
  8012a6:	c7 44 24 08 04 2a 80 	movl   $0x802a04,0x8(%esp)
  8012ad:	00 
  8012ae:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  8012b5:	00 
  8012b6:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  8012bd:	e8 c2 ee ff ff       	call   800184 <_panic>
		if(sys_page_map(0, addr, envid, addr, PTE_U|PTE_P))
  8012c2:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8012c9:	00 
  8012ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012dd:	e8 fb fa ff ff       	call   800ddd <sys_page_map>
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	74 1c                	je     801302 <fork+0x1d4>
			panic("duppage: other sys_page_map error");
  8012e6:	c7 44 24 08 30 2a 80 	movl   $0x802a30,0x8(%esp)
  8012ed:	00 
  8012ee:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  8012f5:	00 
  8012f6:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  8012fd:	e8 82 ee ff ff       	call   800184 <_panic>
		for(addr = UTEXT; addr < USTACKTOP; addr += PGSIZE){
  801302:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801308:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80130e:	0f 85 82 fe ff ff    	jne    801196 <fork+0x68>
				duppage(envid, PGNUM(addr));
		}
		if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W))
  801314:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80131b:	00 
  80131c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801323:	ee 
  801324:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801327:	89 04 24             	mov    %eax,(%esp)
  80132a:	e8 5a fa ff ff       	call   800d89 <sys_page_alloc>
  80132f:	85 c0                	test   %eax,%eax
  801331:	74 1c                	je     80134f <fork+0x221>
			panic("fork: sys_page_alloc error");
  801333:	c7 44 24 08 ee 2a 80 	movl   $0x802aee,0x8(%esp)
  80133a:	00 
  80133b:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801342:	00 
  801343:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  80134a:	e8 35 ee ff ff       	call   800184 <_panic>
		extern void _pgfault_upcall();
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80134f:	c7 44 24 04 ef 21 80 	movl   $0x8021ef,0x4(%esp)
  801356:	00 
  801357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80135a:	89 3c 24             	mov    %edi,(%esp)
  80135d:	e8 c7 fb ff ff       	call   800f29 <sys_env_set_pgfault_upcall>
		if(sys_env_set_status(envid, ENV_RUNNABLE))
  801362:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801369:	00 
  80136a:	89 3c 24             	mov    %edi,(%esp)
  80136d:	e8 11 fb ff ff       	call   800e83 <sys_env_set_status>
  801372:	85 c0                	test   %eax,%eax
  801374:	74 1c                	je     801392 <fork+0x264>
			panic("fork: sys_env_set_status error");
  801376:	c7 44 24 08 54 2a 80 	movl   $0x802a54,0x8(%esp)
  80137d:	00 
  80137e:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801385:	00 
  801386:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  80138d:	e8 f2 ed ff ff       	call   800184 <_panic>
	}
	return envid;
}
  801392:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801395:	83 c4 2c             	add    $0x2c,%esp
  801398:	5b                   	pop    %ebx
  801399:	5e                   	pop    %esi
  80139a:	5f                   	pop    %edi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <sfork>:

// Challenge!
int
sfork(void)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013a3:	c7 44 24 08 09 2b 80 	movl   $0x802b09,0x8(%esp)
  8013aa:	00 
  8013ab:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  8013b2:	00 
  8013b3:	c7 04 24 73 2a 80 00 	movl   $0x802a73,(%esp)
  8013ba:	e8 c5 ed ff ff       	call   800184 <_panic>
  8013bf:	90                   	nop

008013c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8013cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    

008013d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8013db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013e0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013e5:	5d                   	pop    %ebp
  8013e6:	c3                   	ret    

008013e7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013ea:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8013ef:	a8 01                	test   $0x1,%al
  8013f1:	74 34                	je     801427 <fd_alloc+0x40>
  8013f3:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8013f8:	a8 01                	test   $0x1,%al
  8013fa:	74 32                	je     80142e <fd_alloc+0x47>
  8013fc:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  801401:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801403:	89 c2                	mov    %eax,%edx
  801405:	c1 ea 16             	shr    $0x16,%edx
  801408:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80140f:	f6 c2 01             	test   $0x1,%dl
  801412:	74 1f                	je     801433 <fd_alloc+0x4c>
  801414:	89 c2                	mov    %eax,%edx
  801416:	c1 ea 0c             	shr    $0xc,%edx
  801419:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801420:	f6 c2 01             	test   $0x1,%dl
  801423:	75 1a                	jne    80143f <fd_alloc+0x58>
  801425:	eb 0c                	jmp    801433 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  801427:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80142c:	eb 05                	jmp    801433 <fd_alloc+0x4c>
  80142e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  801433:	8b 45 08             	mov    0x8(%ebp),%eax
  801436:	89 08                	mov    %ecx,(%eax)
			return 0;
  801438:	b8 00 00 00 00       	mov    $0x0,%eax
  80143d:	eb 1a                	jmp    801459 <fd_alloc+0x72>
  80143f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801444:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801449:	75 b6                	jne    801401 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  80144b:	8b 45 08             	mov    0x8(%ebp),%eax
  80144e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801454:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801459:	5d                   	pop    %ebp
  80145a:	c3                   	ret    

0080145b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801461:	83 f8 1f             	cmp    $0x1f,%eax
  801464:	77 36                	ja     80149c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801466:	c1 e0 0c             	shl    $0xc,%eax
  801469:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80146e:	89 c2                	mov    %eax,%edx
  801470:	c1 ea 16             	shr    $0x16,%edx
  801473:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80147a:	f6 c2 01             	test   $0x1,%dl
  80147d:	74 24                	je     8014a3 <fd_lookup+0x48>
  80147f:	89 c2                	mov    %eax,%edx
  801481:	c1 ea 0c             	shr    $0xc,%edx
  801484:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80148b:	f6 c2 01             	test   $0x1,%dl
  80148e:	74 1a                	je     8014aa <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801490:	8b 55 0c             	mov    0xc(%ebp),%edx
  801493:	89 02                	mov    %eax,(%edx)
	return 0;
  801495:	b8 00 00 00 00       	mov    $0x0,%eax
  80149a:	eb 13                	jmp    8014af <fd_lookup+0x54>
		return -E_INVAL;
  80149c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a1:	eb 0c                	jmp    8014af <fd_lookup+0x54>
		return -E_INVAL;
  8014a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a8:	eb 05                	jmp    8014af <fd_lookup+0x54>
  8014aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014af:	5d                   	pop    %ebp
  8014b0:	c3                   	ret    

008014b1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	53                   	push   %ebx
  8014b5:	83 ec 14             	sub    $0x14,%esp
  8014b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8014be:	39 05 04 30 80 00    	cmp    %eax,0x803004
  8014c4:	75 1e                	jne    8014e4 <dev_lookup+0x33>
  8014c6:	eb 0e                	jmp    8014d6 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  8014c8:	b8 20 30 80 00       	mov    $0x803020,%eax
  8014cd:	eb 0c                	jmp    8014db <dev_lookup+0x2a>
  8014cf:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  8014d4:	eb 05                	jmp    8014db <dev_lookup+0x2a>
  8014d6:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  8014db:	89 03                	mov    %eax,(%ebx)
			return 0;
  8014dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e2:	eb 38                	jmp    80151c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  8014e4:	39 05 20 30 80 00    	cmp    %eax,0x803020
  8014ea:	74 dc                	je     8014c8 <dev_lookup+0x17>
  8014ec:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  8014f2:	74 db                	je     8014cf <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014f4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8014fa:	8b 52 48             	mov    0x48(%edx),%edx
  8014fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801501:	89 54 24 04          	mov    %edx,0x4(%esp)
  801505:	c7 04 24 20 2b 80 00 	movl   $0x802b20,(%esp)
  80150c:	e8 6c ed ff ff       	call   80027d <cprintf>
	*dev = 0;
  801511:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801517:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80151c:	83 c4 14             	add    $0x14,%esp
  80151f:	5b                   	pop    %ebx
  801520:	5d                   	pop    %ebp
  801521:	c3                   	ret    

00801522 <fd_close>:
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	56                   	push   %esi
  801526:	53                   	push   %ebx
  801527:	83 ec 20             	sub    $0x20,%esp
  80152a:	8b 75 08             	mov    0x8(%ebp),%esi
  80152d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801530:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801533:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801537:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80153d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801540:	89 04 24             	mov    %eax,(%esp)
  801543:	e8 13 ff ff ff       	call   80145b <fd_lookup>
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 05                	js     801551 <fd_close+0x2f>
	    || fd != fd2)
  80154c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80154f:	74 0c                	je     80155d <fd_close+0x3b>
		return (must_exist ? r : 0);
  801551:	84 db                	test   %bl,%bl
  801553:	ba 00 00 00 00       	mov    $0x0,%edx
  801558:	0f 44 c2             	cmove  %edx,%eax
  80155b:	eb 3f                	jmp    80159c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80155d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801560:	89 44 24 04          	mov    %eax,0x4(%esp)
  801564:	8b 06                	mov    (%esi),%eax
  801566:	89 04 24             	mov    %eax,(%esp)
  801569:	e8 43 ff ff ff       	call   8014b1 <dev_lookup>
  80156e:	89 c3                	mov    %eax,%ebx
  801570:	85 c0                	test   %eax,%eax
  801572:	78 16                	js     80158a <fd_close+0x68>
		if (dev->dev_close)
  801574:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801577:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80157a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80157f:	85 c0                	test   %eax,%eax
  801581:	74 07                	je     80158a <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801583:	89 34 24             	mov    %esi,(%esp)
  801586:	ff d0                	call   *%eax
  801588:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  80158a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80158e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801595:	e8 96 f8 ff ff       	call   800e30 <sys_page_unmap>
	return r;
  80159a:	89 d8                	mov    %ebx,%eax
}
  80159c:	83 c4 20             	add    $0x20,%esp
  80159f:	5b                   	pop    %ebx
  8015a0:	5e                   	pop    %esi
  8015a1:	5d                   	pop    %ebp
  8015a2:	c3                   	ret    

008015a3 <close>:

int
close(int fdnum)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b3:	89 04 24             	mov    %eax,(%esp)
  8015b6:	e8 a0 fe ff ff       	call   80145b <fd_lookup>
  8015bb:	89 c2                	mov    %eax,%edx
  8015bd:	85 d2                	test   %edx,%edx
  8015bf:	78 13                	js     8015d4 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8015c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015c8:	00 
  8015c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015cc:	89 04 24             	mov    %eax,(%esp)
  8015cf:	e8 4e ff ff ff       	call   801522 <fd_close>
}
  8015d4:	c9                   	leave  
  8015d5:	c3                   	ret    

008015d6 <close_all>:

void
close_all(void)
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	53                   	push   %ebx
  8015da:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015dd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015e2:	89 1c 24             	mov    %ebx,(%esp)
  8015e5:	e8 b9 ff ff ff       	call   8015a3 <close>
	for (i = 0; i < MAXFD; i++)
  8015ea:	83 c3 01             	add    $0x1,%ebx
  8015ed:	83 fb 20             	cmp    $0x20,%ebx
  8015f0:	75 f0                	jne    8015e2 <close_all+0xc>
}
  8015f2:	83 c4 14             	add    $0x14,%esp
  8015f5:	5b                   	pop    %ebx
  8015f6:	5d                   	pop    %ebp
  8015f7:	c3                   	ret    

008015f8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	57                   	push   %edi
  8015fc:	56                   	push   %esi
  8015fd:	53                   	push   %ebx
  8015fe:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801601:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801604:	89 44 24 04          	mov    %eax,0x4(%esp)
  801608:	8b 45 08             	mov    0x8(%ebp),%eax
  80160b:	89 04 24             	mov    %eax,(%esp)
  80160e:	e8 48 fe ff ff       	call   80145b <fd_lookup>
  801613:	89 c2                	mov    %eax,%edx
  801615:	85 d2                	test   %edx,%edx
  801617:	0f 88 e1 00 00 00    	js     8016fe <dup+0x106>
		return r;
	close(newfdnum);
  80161d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801620:	89 04 24             	mov    %eax,(%esp)
  801623:	e8 7b ff ff ff       	call   8015a3 <close>

	newfd = INDEX2FD(newfdnum);
  801628:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80162b:	c1 e3 0c             	shl    $0xc,%ebx
  80162e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801634:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801637:	89 04 24             	mov    %eax,(%esp)
  80163a:	e8 91 fd ff ff       	call   8013d0 <fd2data>
  80163f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801641:	89 1c 24             	mov    %ebx,(%esp)
  801644:	e8 87 fd ff ff       	call   8013d0 <fd2data>
  801649:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80164b:	89 f0                	mov    %esi,%eax
  80164d:	c1 e8 16             	shr    $0x16,%eax
  801650:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801657:	a8 01                	test   $0x1,%al
  801659:	74 43                	je     80169e <dup+0xa6>
  80165b:	89 f0                	mov    %esi,%eax
  80165d:	c1 e8 0c             	shr    $0xc,%eax
  801660:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801667:	f6 c2 01             	test   $0x1,%dl
  80166a:	74 32                	je     80169e <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80166c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801673:	25 07 0e 00 00       	and    $0xe07,%eax
  801678:	89 44 24 10          	mov    %eax,0x10(%esp)
  80167c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801680:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801687:	00 
  801688:	89 74 24 04          	mov    %esi,0x4(%esp)
  80168c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801693:	e8 45 f7 ff ff       	call   800ddd <sys_page_map>
  801698:	89 c6                	mov    %eax,%esi
  80169a:	85 c0                	test   %eax,%eax
  80169c:	78 3e                	js     8016dc <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80169e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016a1:	89 c2                	mov    %eax,%edx
  8016a3:	c1 ea 0c             	shr    $0xc,%edx
  8016a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016ad:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016b3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016b7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8016bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016c2:	00 
  8016c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ce:	e8 0a f7 ff ff       	call   800ddd <sys_page_map>
  8016d3:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8016d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016d8:	85 f6                	test   %esi,%esi
  8016da:	79 22                	jns    8016fe <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8016dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e7:	e8 44 f7 ff ff       	call   800e30 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f7:	e8 34 f7 ff ff       	call   800e30 <sys_page_unmap>
	return r;
  8016fc:	89 f0                	mov    %esi,%eax
}
  8016fe:	83 c4 3c             	add    $0x3c,%esp
  801701:	5b                   	pop    %ebx
  801702:	5e                   	pop    %esi
  801703:	5f                   	pop    %edi
  801704:	5d                   	pop    %ebp
  801705:	c3                   	ret    

00801706 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	53                   	push   %ebx
  80170a:	83 ec 24             	sub    $0x24,%esp
  80170d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801710:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801713:	89 44 24 04          	mov    %eax,0x4(%esp)
  801717:	89 1c 24             	mov    %ebx,(%esp)
  80171a:	e8 3c fd ff ff       	call   80145b <fd_lookup>
  80171f:	89 c2                	mov    %eax,%edx
  801721:	85 d2                	test   %edx,%edx
  801723:	78 6d                	js     801792 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801725:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172f:	8b 00                	mov    (%eax),%eax
  801731:	89 04 24             	mov    %eax,(%esp)
  801734:	e8 78 fd ff ff       	call   8014b1 <dev_lookup>
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 55                	js     801792 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80173d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801740:	8b 50 08             	mov    0x8(%eax),%edx
  801743:	83 e2 03             	and    $0x3,%edx
  801746:	83 fa 01             	cmp    $0x1,%edx
  801749:	75 23                	jne    80176e <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80174b:	a1 08 40 80 00       	mov    0x804008,%eax
  801750:	8b 40 48             	mov    0x48(%eax),%eax
  801753:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801757:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175b:	c7 04 24 61 2b 80 00 	movl   $0x802b61,(%esp)
  801762:	e8 16 eb ff ff       	call   80027d <cprintf>
		return -E_INVAL;
  801767:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80176c:	eb 24                	jmp    801792 <read+0x8c>
	}
	if (!dev->dev_read)
  80176e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801771:	8b 52 08             	mov    0x8(%edx),%edx
  801774:	85 d2                	test   %edx,%edx
  801776:	74 15                	je     80178d <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801778:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80177b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80177f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801782:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801786:	89 04 24             	mov    %eax,(%esp)
  801789:	ff d2                	call   *%edx
  80178b:	eb 05                	jmp    801792 <read+0x8c>
		return -E_NOT_SUPP;
  80178d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801792:	83 c4 24             	add    $0x24,%esp
  801795:	5b                   	pop    %ebx
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	57                   	push   %edi
  80179c:	56                   	push   %esi
  80179d:	53                   	push   %ebx
  80179e:	83 ec 1c             	sub    $0x1c,%esp
  8017a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017a4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017a7:	85 f6                	test   %esi,%esi
  8017a9:	74 33                	je     8017de <readn+0x46>
  8017ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b0:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017b5:	89 f2                	mov    %esi,%edx
  8017b7:	29 c2                	sub    %eax,%edx
  8017b9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017bd:	03 45 0c             	add    0xc(%ebp),%eax
  8017c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c4:	89 3c 24             	mov    %edi,(%esp)
  8017c7:	e8 3a ff ff ff       	call   801706 <read>
		if (m < 0)
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 1b                	js     8017eb <readn+0x53>
			return m;
		if (m == 0)
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	74 11                	je     8017e5 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  8017d4:	01 c3                	add    %eax,%ebx
  8017d6:	89 d8                	mov    %ebx,%eax
  8017d8:	39 f3                	cmp    %esi,%ebx
  8017da:	72 d9                	jb     8017b5 <readn+0x1d>
  8017dc:	eb 0b                	jmp    8017e9 <readn+0x51>
  8017de:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e3:	eb 06                	jmp    8017eb <readn+0x53>
  8017e5:	89 d8                	mov    %ebx,%eax
  8017e7:	eb 02                	jmp    8017eb <readn+0x53>
  8017e9:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8017eb:	83 c4 1c             	add    $0x1c,%esp
  8017ee:	5b                   	pop    %ebx
  8017ef:	5e                   	pop    %esi
  8017f0:	5f                   	pop    %edi
  8017f1:	5d                   	pop    %ebp
  8017f2:	c3                   	ret    

008017f3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	53                   	push   %ebx
  8017f7:	83 ec 24             	sub    $0x24,%esp
  8017fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801800:	89 44 24 04          	mov    %eax,0x4(%esp)
  801804:	89 1c 24             	mov    %ebx,(%esp)
  801807:	e8 4f fc ff ff       	call   80145b <fd_lookup>
  80180c:	89 c2                	mov    %eax,%edx
  80180e:	85 d2                	test   %edx,%edx
  801810:	78 68                	js     80187a <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801812:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801815:	89 44 24 04          	mov    %eax,0x4(%esp)
  801819:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181c:	8b 00                	mov    (%eax),%eax
  80181e:	89 04 24             	mov    %eax,(%esp)
  801821:	e8 8b fc ff ff       	call   8014b1 <dev_lookup>
  801826:	85 c0                	test   %eax,%eax
  801828:	78 50                	js     80187a <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80182a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801831:	75 23                	jne    801856 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801833:	a1 08 40 80 00       	mov    0x804008,%eax
  801838:	8b 40 48             	mov    0x48(%eax),%eax
  80183b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80183f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801843:	c7 04 24 7d 2b 80 00 	movl   $0x802b7d,(%esp)
  80184a:	e8 2e ea ff ff       	call   80027d <cprintf>
		return -E_INVAL;
  80184f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801854:	eb 24                	jmp    80187a <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801856:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801859:	8b 52 0c             	mov    0xc(%edx),%edx
  80185c:	85 d2                	test   %edx,%edx
  80185e:	74 15                	je     801875 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801860:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801863:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801867:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80186a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80186e:	89 04 24             	mov    %eax,(%esp)
  801871:	ff d2                	call   *%edx
  801873:	eb 05                	jmp    80187a <write+0x87>
		return -E_NOT_SUPP;
  801875:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80187a:	83 c4 24             	add    $0x24,%esp
  80187d:	5b                   	pop    %ebx
  80187e:	5d                   	pop    %ebp
  80187f:	c3                   	ret    

00801880 <seek>:

int
seek(int fdnum, off_t offset)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801886:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801889:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188d:	8b 45 08             	mov    0x8(%ebp),%eax
  801890:	89 04 24             	mov    %eax,(%esp)
  801893:	e8 c3 fb ff ff       	call   80145b <fd_lookup>
  801898:	85 c0                	test   %eax,%eax
  80189a:	78 0e                	js     8018aa <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80189c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80189f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	53                   	push   %ebx
  8018b0:	83 ec 24             	sub    $0x24,%esp
  8018b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bd:	89 1c 24             	mov    %ebx,(%esp)
  8018c0:	e8 96 fb ff ff       	call   80145b <fd_lookup>
  8018c5:	89 c2                	mov    %eax,%edx
  8018c7:	85 d2                	test   %edx,%edx
  8018c9:	78 61                	js     80192c <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d5:	8b 00                	mov    (%eax),%eax
  8018d7:	89 04 24             	mov    %eax,(%esp)
  8018da:	e8 d2 fb ff ff       	call   8014b1 <dev_lookup>
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 49                	js     80192c <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018ea:	75 23                	jne    80190f <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018ec:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018f1:	8b 40 48             	mov    0x48(%eax),%eax
  8018f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fc:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  801903:	e8 75 e9 ff ff       	call   80027d <cprintf>
		return -E_INVAL;
  801908:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80190d:	eb 1d                	jmp    80192c <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80190f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801912:	8b 52 18             	mov    0x18(%edx),%edx
  801915:	85 d2                	test   %edx,%edx
  801917:	74 0e                	je     801927 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801919:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80191c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801920:	89 04 24             	mov    %eax,(%esp)
  801923:	ff d2                	call   *%edx
  801925:	eb 05                	jmp    80192c <ftruncate+0x80>
		return -E_NOT_SUPP;
  801927:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80192c:	83 c4 24             	add    $0x24,%esp
  80192f:	5b                   	pop    %ebx
  801930:	5d                   	pop    %ebp
  801931:	c3                   	ret    

00801932 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	53                   	push   %ebx
  801936:	83 ec 24             	sub    $0x24,%esp
  801939:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80193c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80193f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801943:	8b 45 08             	mov    0x8(%ebp),%eax
  801946:	89 04 24             	mov    %eax,(%esp)
  801949:	e8 0d fb ff ff       	call   80145b <fd_lookup>
  80194e:	89 c2                	mov    %eax,%edx
  801950:	85 d2                	test   %edx,%edx
  801952:	78 52                	js     8019a6 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801954:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801957:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195e:	8b 00                	mov    (%eax),%eax
  801960:	89 04 24             	mov    %eax,(%esp)
  801963:	e8 49 fb ff ff       	call   8014b1 <dev_lookup>
  801968:	85 c0                	test   %eax,%eax
  80196a:	78 3a                	js     8019a6 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80196c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801973:	74 2c                	je     8019a1 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801975:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801978:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80197f:	00 00 00 
	stat->st_isdir = 0;
  801982:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801989:	00 00 00 
	stat->st_dev = dev;
  80198c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801992:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801996:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801999:	89 14 24             	mov    %edx,(%esp)
  80199c:	ff 50 14             	call   *0x14(%eax)
  80199f:	eb 05                	jmp    8019a6 <fstat+0x74>
		return -E_NOT_SUPP;
  8019a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8019a6:	83 c4 24             	add    $0x24,%esp
  8019a9:	5b                   	pop    %ebx
  8019aa:	5d                   	pop    %ebp
  8019ab:	c3                   	ret    

008019ac <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	56                   	push   %esi
  8019b0:	53                   	push   %ebx
  8019b1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019bb:	00 
  8019bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bf:	89 04 24             	mov    %eax,(%esp)
  8019c2:	e8 af 01 00 00       	call   801b76 <open>
  8019c7:	89 c3                	mov    %eax,%ebx
  8019c9:	85 db                	test   %ebx,%ebx
  8019cb:	78 1b                	js     8019e8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8019cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d4:	89 1c 24             	mov    %ebx,(%esp)
  8019d7:	e8 56 ff ff ff       	call   801932 <fstat>
  8019dc:	89 c6                	mov    %eax,%esi
	close(fd);
  8019de:	89 1c 24             	mov    %ebx,(%esp)
  8019e1:	e8 bd fb ff ff       	call   8015a3 <close>
	return r;
  8019e6:	89 f0                	mov    %esi,%eax
}
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	5b                   	pop    %ebx
  8019ec:	5e                   	pop    %esi
  8019ed:	5d                   	pop    %ebp
  8019ee:	c3                   	ret    

008019ef <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	56                   	push   %esi
  8019f3:	53                   	push   %ebx
  8019f4:	83 ec 10             	sub    $0x10,%esp
  8019f7:	89 c6                	mov    %eax,%esi
  8019f9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019fb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a02:	75 11                	jne    801a15 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a04:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a0b:	e8 a7 08 00 00       	call   8022b7 <ipc_find_env>
  801a10:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a15:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a1c:	00 
  801a1d:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a24:	00 
  801a25:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a29:	a1 00 40 80 00       	mov    0x804000,%eax
  801a2e:	89 04 24             	mov    %eax,(%esp)
  801a31:	e8 39 08 00 00       	call   80226f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a36:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a3d:	00 
  801a3e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a49:	e8 c5 07 00 00       	call   802213 <ipc_recv>
}
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	5b                   	pop    %ebx
  801a52:	5e                   	pop    %esi
  801a53:	5d                   	pop    %ebp
  801a54:	c3                   	ret    

00801a55 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	53                   	push   %ebx
  801a59:	83 ec 14             	sub    $0x14,%esp
  801a5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a62:	8b 40 0c             	mov    0xc(%eax),%eax
  801a65:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a6a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6f:	b8 05 00 00 00       	mov    $0x5,%eax
  801a74:	e8 76 ff ff ff       	call   8019ef <fsipc>
  801a79:	89 c2                	mov    %eax,%edx
  801a7b:	85 d2                	test   %edx,%edx
  801a7d:	78 2b                	js     801aaa <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a7f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a86:	00 
  801a87:	89 1c 24             	mov    %ebx,(%esp)
  801a8a:	e8 4c ee ff ff       	call   8008db <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a8f:	a1 80 50 80 00       	mov    0x805080,%eax
  801a94:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a9a:	a1 84 50 80 00       	mov    0x805084,%eax
  801a9f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aa5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aaa:	83 c4 14             	add    $0x14,%esp
  801aad:	5b                   	pop    %ebx
  801aae:	5d                   	pop    %ebp
  801aaf:	c3                   	ret    

00801ab0 <devfile_flush>:
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab9:	8b 40 0c             	mov    0xc(%eax),%eax
  801abc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ac1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac6:	b8 06 00 00 00       	mov    $0x6,%eax
  801acb:	e8 1f ff ff ff       	call   8019ef <fsipc>
}
  801ad0:	c9                   	leave  
  801ad1:	c3                   	ret    

00801ad2 <devfile_read>:
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	56                   	push   %esi
  801ad6:	53                   	push   %ebx
  801ad7:	83 ec 10             	sub    $0x10,%esp
  801ada:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801add:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ae8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aee:	ba 00 00 00 00       	mov    $0x0,%edx
  801af3:	b8 03 00 00 00       	mov    $0x3,%eax
  801af8:	e8 f2 fe ff ff       	call   8019ef <fsipc>
  801afd:	89 c3                	mov    %eax,%ebx
  801aff:	85 c0                	test   %eax,%eax
  801b01:	78 6a                	js     801b6d <devfile_read+0x9b>
	assert(r <= n);
  801b03:	39 c6                	cmp    %eax,%esi
  801b05:	73 24                	jae    801b2b <devfile_read+0x59>
  801b07:	c7 44 24 0c 9a 2b 80 	movl   $0x802b9a,0xc(%esp)
  801b0e:	00 
  801b0f:	c7 44 24 08 a1 2b 80 	movl   $0x802ba1,0x8(%esp)
  801b16:	00 
  801b17:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  801b1e:	00 
  801b1f:	c7 04 24 b6 2b 80 00 	movl   $0x802bb6,(%esp)
  801b26:	e8 59 e6 ff ff       	call   800184 <_panic>
	assert(r <= PGSIZE);
  801b2b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b30:	7e 24                	jle    801b56 <devfile_read+0x84>
  801b32:	c7 44 24 0c c1 2b 80 	movl   $0x802bc1,0xc(%esp)
  801b39:	00 
  801b3a:	c7 44 24 08 a1 2b 80 	movl   $0x802ba1,0x8(%esp)
  801b41:	00 
  801b42:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801b49:	00 
  801b4a:	c7 04 24 b6 2b 80 00 	movl   $0x802bb6,(%esp)
  801b51:	e8 2e e6 ff ff       	call   800184 <_panic>
	memmove(buf, &fsipcbuf, r);
  801b56:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b5a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b61:	00 
  801b62:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b65:	89 04 24             	mov    %eax,(%esp)
  801b68:	e8 69 ef ff ff       	call   800ad6 <memmove>
}
  801b6d:	89 d8                	mov    %ebx,%eax
  801b6f:	83 c4 10             	add    $0x10,%esp
  801b72:	5b                   	pop    %ebx
  801b73:	5e                   	pop    %esi
  801b74:	5d                   	pop    %ebp
  801b75:	c3                   	ret    

00801b76 <open>:
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	53                   	push   %ebx
  801b7a:	83 ec 24             	sub    $0x24,%esp
  801b7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801b80:	89 1c 24             	mov    %ebx,(%esp)
  801b83:	e8 f8 ec ff ff       	call   800880 <strlen>
  801b88:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b8d:	7f 60                	jg     801bef <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801b8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b92:	89 04 24             	mov    %eax,(%esp)
  801b95:	e8 4d f8 ff ff       	call   8013e7 <fd_alloc>
  801b9a:	89 c2                	mov    %eax,%edx
  801b9c:	85 d2                	test   %edx,%edx
  801b9e:	78 54                	js     801bf4 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801ba0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ba4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801bab:	e8 2b ed ff ff       	call   8008db <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bbb:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc0:	e8 2a fe ff ff       	call   8019ef <fsipc>
  801bc5:	89 c3                	mov    %eax,%ebx
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	79 17                	jns    801be2 <open+0x6c>
		fd_close(fd, 0);
  801bcb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bd2:	00 
  801bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd6:	89 04 24             	mov    %eax,(%esp)
  801bd9:	e8 44 f9 ff ff       	call   801522 <fd_close>
		return r;
  801bde:	89 d8                	mov    %ebx,%eax
  801be0:	eb 12                	jmp    801bf4 <open+0x7e>
	return fd2num(fd);
  801be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be5:	89 04 24             	mov    %eax,(%esp)
  801be8:	e8 d3 f7 ff ff       	call   8013c0 <fd2num>
  801bed:	eb 05                	jmp    801bf4 <open+0x7e>
		return -E_BAD_PATH;
  801bef:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801bf4:	83 c4 24             	add    $0x24,%esp
  801bf7:	5b                   	pop    %ebx
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    
  801bfa:	66 90                	xchg   %ax,%ax
  801bfc:	66 90                	xchg   %ax,%ax
  801bfe:	66 90                	xchg   %ax,%ax

00801c00 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	56                   	push   %esi
  801c04:	53                   	push   %ebx
  801c05:	83 ec 10             	sub    $0x10,%esp
  801c08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0e:	89 04 24             	mov    %eax,(%esp)
  801c11:	e8 ba f7 ff ff       	call   8013d0 <fd2data>
  801c16:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c18:	c7 44 24 04 cd 2b 80 	movl   $0x802bcd,0x4(%esp)
  801c1f:	00 
  801c20:	89 1c 24             	mov    %ebx,(%esp)
  801c23:	e8 b3 ec ff ff       	call   8008db <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c28:	8b 46 04             	mov    0x4(%esi),%eax
  801c2b:	2b 06                	sub    (%esi),%eax
  801c2d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c33:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c3a:	00 00 00 
	stat->st_dev = &devpipe;
  801c3d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c44:	30 80 00 
	return 0;
}
  801c47:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4c:	83 c4 10             	add    $0x10,%esp
  801c4f:	5b                   	pop    %ebx
  801c50:	5e                   	pop    %esi
  801c51:	5d                   	pop    %ebp
  801c52:	c3                   	ret    

00801c53 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	53                   	push   %ebx
  801c57:	83 ec 14             	sub    $0x14,%esp
  801c5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c68:	e8 c3 f1 ff ff       	call   800e30 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c6d:	89 1c 24             	mov    %ebx,(%esp)
  801c70:	e8 5b f7 ff ff       	call   8013d0 <fd2data>
  801c75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c80:	e8 ab f1 ff ff       	call   800e30 <sys_page_unmap>
}
  801c85:	83 c4 14             	add    $0x14,%esp
  801c88:	5b                   	pop    %ebx
  801c89:	5d                   	pop    %ebp
  801c8a:	c3                   	ret    

00801c8b <_pipeisclosed>:
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	57                   	push   %edi
  801c8f:	56                   	push   %esi
  801c90:	53                   	push   %ebx
  801c91:	83 ec 2c             	sub    $0x2c,%esp
  801c94:	89 c6                	mov    %eax,%esi
  801c96:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801c99:	a1 08 40 80 00       	mov    0x804008,%eax
  801c9e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ca1:	89 34 24             	mov    %esi,(%esp)
  801ca4:	e8 56 06 00 00       	call   8022ff <pageref>
  801ca9:	89 c7                	mov    %eax,%edi
  801cab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cae:	89 04 24             	mov    %eax,(%esp)
  801cb1:	e8 49 06 00 00       	call   8022ff <pageref>
  801cb6:	39 c7                	cmp    %eax,%edi
  801cb8:	0f 94 c2             	sete   %dl
  801cbb:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801cbe:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801cc4:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801cc7:	39 fb                	cmp    %edi,%ebx
  801cc9:	74 21                	je     801cec <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801ccb:	84 d2                	test   %dl,%dl
  801ccd:	74 ca                	je     801c99 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ccf:	8b 51 58             	mov    0x58(%ecx),%edx
  801cd2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cd6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cda:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cde:	c7 04 24 d4 2b 80 00 	movl   $0x802bd4,(%esp)
  801ce5:	e8 93 e5 ff ff       	call   80027d <cprintf>
  801cea:	eb ad                	jmp    801c99 <_pipeisclosed+0xe>
}
  801cec:	83 c4 2c             	add    $0x2c,%esp
  801cef:	5b                   	pop    %ebx
  801cf0:	5e                   	pop    %esi
  801cf1:	5f                   	pop    %edi
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    

00801cf4 <devpipe_write>:
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	57                   	push   %edi
  801cf8:	56                   	push   %esi
  801cf9:	53                   	push   %ebx
  801cfa:	83 ec 1c             	sub    $0x1c,%esp
  801cfd:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d00:	89 34 24             	mov    %esi,(%esp)
  801d03:	e8 c8 f6 ff ff       	call   8013d0 <fd2data>
	for (i = 0; i < n; i++) {
  801d08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d0c:	74 61                	je     801d6f <devpipe_write+0x7b>
  801d0e:	89 c3                	mov    %eax,%ebx
  801d10:	bf 00 00 00 00       	mov    $0x0,%edi
  801d15:	eb 4a                	jmp    801d61 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  801d17:	89 da                	mov    %ebx,%edx
  801d19:	89 f0                	mov    %esi,%eax
  801d1b:	e8 6b ff ff ff       	call   801c8b <_pipeisclosed>
  801d20:	85 c0                	test   %eax,%eax
  801d22:	75 54                	jne    801d78 <devpipe_write+0x84>
			sys_yield();
  801d24:	e8 41 f0 ff ff       	call   800d6a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d29:	8b 43 04             	mov    0x4(%ebx),%eax
  801d2c:	8b 0b                	mov    (%ebx),%ecx
  801d2e:	8d 51 20             	lea    0x20(%ecx),%edx
  801d31:	39 d0                	cmp    %edx,%eax
  801d33:	73 e2                	jae    801d17 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d38:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d3c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d3f:	99                   	cltd   
  801d40:	c1 ea 1b             	shr    $0x1b,%edx
  801d43:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801d46:	83 e1 1f             	and    $0x1f,%ecx
  801d49:	29 d1                	sub    %edx,%ecx
  801d4b:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801d4f:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801d53:	83 c0 01             	add    $0x1,%eax
  801d56:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d59:	83 c7 01             	add    $0x1,%edi
  801d5c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d5f:	74 13                	je     801d74 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d61:	8b 43 04             	mov    0x4(%ebx),%eax
  801d64:	8b 0b                	mov    (%ebx),%ecx
  801d66:	8d 51 20             	lea    0x20(%ecx),%edx
  801d69:	39 d0                	cmp    %edx,%eax
  801d6b:	73 aa                	jae    801d17 <devpipe_write+0x23>
  801d6d:	eb c6                	jmp    801d35 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  801d6f:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  801d74:	89 f8                	mov    %edi,%eax
  801d76:	eb 05                	jmp    801d7d <devpipe_write+0x89>
				return 0;
  801d78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d7d:	83 c4 1c             	add    $0x1c,%esp
  801d80:	5b                   	pop    %ebx
  801d81:	5e                   	pop    %esi
  801d82:	5f                   	pop    %edi
  801d83:	5d                   	pop    %ebp
  801d84:	c3                   	ret    

00801d85 <devpipe_read>:
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	57                   	push   %edi
  801d89:	56                   	push   %esi
  801d8a:	53                   	push   %ebx
  801d8b:	83 ec 1c             	sub    $0x1c,%esp
  801d8e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d91:	89 3c 24             	mov    %edi,(%esp)
  801d94:	e8 37 f6 ff ff       	call   8013d0 <fd2data>
	for (i = 0; i < n; i++) {
  801d99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d9d:	74 54                	je     801df3 <devpipe_read+0x6e>
  801d9f:	89 c3                	mov    %eax,%ebx
  801da1:	be 00 00 00 00       	mov    $0x0,%esi
  801da6:	eb 3e                	jmp    801de6 <devpipe_read+0x61>
				return i;
  801da8:	89 f0                	mov    %esi,%eax
  801daa:	eb 55                	jmp    801e01 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  801dac:	89 da                	mov    %ebx,%edx
  801dae:	89 f8                	mov    %edi,%eax
  801db0:	e8 d6 fe ff ff       	call   801c8b <_pipeisclosed>
  801db5:	85 c0                	test   %eax,%eax
  801db7:	75 43                	jne    801dfc <devpipe_read+0x77>
			sys_yield();
  801db9:	e8 ac ef ff ff       	call   800d6a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801dbe:	8b 03                	mov    (%ebx),%eax
  801dc0:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dc3:	74 e7                	je     801dac <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dc5:	99                   	cltd   
  801dc6:	c1 ea 1b             	shr    $0x1b,%edx
  801dc9:	01 d0                	add    %edx,%eax
  801dcb:	83 e0 1f             	and    $0x1f,%eax
  801dce:	29 d0                	sub    %edx,%eax
  801dd0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801dd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dd8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ddb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801dde:	83 c6 01             	add    $0x1,%esi
  801de1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801de4:	74 12                	je     801df8 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  801de6:	8b 03                	mov    (%ebx),%eax
  801de8:	3b 43 04             	cmp    0x4(%ebx),%eax
  801deb:	75 d8                	jne    801dc5 <devpipe_read+0x40>
			if (i > 0)
  801ded:	85 f6                	test   %esi,%esi
  801def:	75 b7                	jne    801da8 <devpipe_read+0x23>
  801df1:	eb b9                	jmp    801dac <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  801df3:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  801df8:	89 f0                	mov    %esi,%eax
  801dfa:	eb 05                	jmp    801e01 <devpipe_read+0x7c>
				return 0;
  801dfc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e01:	83 c4 1c             	add    $0x1c,%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5f                   	pop    %edi
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    

00801e09 <pipe>:
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	56                   	push   %esi
  801e0d:	53                   	push   %ebx
  801e0e:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e14:	89 04 24             	mov    %eax,(%esp)
  801e17:	e8 cb f5 ff ff       	call   8013e7 <fd_alloc>
  801e1c:	89 c2                	mov    %eax,%edx
  801e1e:	85 d2                	test   %edx,%edx
  801e20:	0f 88 4d 01 00 00    	js     801f73 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e26:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e2d:	00 
  801e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e3c:	e8 48 ef ff ff       	call   800d89 <sys_page_alloc>
  801e41:	89 c2                	mov    %eax,%edx
  801e43:	85 d2                	test   %edx,%edx
  801e45:	0f 88 28 01 00 00    	js     801f73 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801e4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e4e:	89 04 24             	mov    %eax,(%esp)
  801e51:	e8 91 f5 ff ff       	call   8013e7 <fd_alloc>
  801e56:	89 c3                	mov    %eax,%ebx
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	0f 88 fe 00 00 00    	js     801f5e <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e60:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e67:	00 
  801e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e76:	e8 0e ef ff ff       	call   800d89 <sys_page_alloc>
  801e7b:	89 c3                	mov    %eax,%ebx
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	0f 88 d9 00 00 00    	js     801f5e <pipe+0x155>
	va = fd2data(fd0);
  801e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e88:	89 04 24             	mov    %eax,(%esp)
  801e8b:	e8 40 f5 ff ff       	call   8013d0 <fd2data>
  801e90:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e92:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e99:	00 
  801e9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea5:	e8 df ee ff ff       	call   800d89 <sys_page_alloc>
  801eaa:	89 c3                	mov    %eax,%ebx
  801eac:	85 c0                	test   %eax,%eax
  801eae:	0f 88 97 00 00 00    	js     801f4b <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eb7:	89 04 24             	mov    %eax,(%esp)
  801eba:	e8 11 f5 ff ff       	call   8013d0 <fd2data>
  801ebf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ec6:	00 
  801ec7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ecb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ed2:	00 
  801ed3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ed7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ede:	e8 fa ee ff ff       	call   800ddd <sys_page_map>
  801ee3:	89 c3                	mov    %eax,%ebx
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	78 52                	js     801f3b <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801ee9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801efe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f07:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f0c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f16:	89 04 24             	mov    %eax,(%esp)
  801f19:	e8 a2 f4 ff ff       	call   8013c0 <fd2num>
  801f1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f21:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f26:	89 04 24             	mov    %eax,(%esp)
  801f29:	e8 92 f4 ff ff       	call   8013c0 <fd2num>
  801f2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f31:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f34:	b8 00 00 00 00       	mov    $0x0,%eax
  801f39:	eb 38                	jmp    801f73 <pipe+0x16a>
	sys_page_unmap(0, va);
  801f3b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f46:	e8 e5 ee ff ff       	call   800e30 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f59:	e8 d2 ee ff ff       	call   800e30 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f61:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f6c:	e8 bf ee ff ff       	call   800e30 <sys_page_unmap>
  801f71:	89 d8                	mov    %ebx,%eax
}
  801f73:	83 c4 30             	add    $0x30,%esp
  801f76:	5b                   	pop    %ebx
  801f77:	5e                   	pop    %esi
  801f78:	5d                   	pop    %ebp
  801f79:	c3                   	ret    

00801f7a <pipeisclosed>:
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f87:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8a:	89 04 24             	mov    %eax,(%esp)
  801f8d:	e8 c9 f4 ff ff       	call   80145b <fd_lookup>
  801f92:	89 c2                	mov    %eax,%edx
  801f94:	85 d2                	test   %edx,%edx
  801f96:	78 15                	js     801fad <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9b:	89 04 24             	mov    %eax,(%esp)
  801f9e:	e8 2d f4 ff ff       	call   8013d0 <fd2data>
	return _pipeisclosed(fd, p);
  801fa3:	89 c2                	mov    %eax,%edx
  801fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa8:	e8 de fc ff ff       	call   801c8b <_pipeisclosed>
}
  801fad:	c9                   	leave  
  801fae:	c3                   	ret    
  801faf:	90                   	nop

00801fb0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb8:	5d                   	pop    %ebp
  801fb9:	c3                   	ret    

00801fba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fc0:	c7 44 24 04 ec 2b 80 	movl   $0x802bec,0x4(%esp)
  801fc7:	00 
  801fc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcb:	89 04 24             	mov    %eax,(%esp)
  801fce:	e8 08 e9 ff ff       	call   8008db <strcpy>
	return 0;
}
  801fd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd8:	c9                   	leave  
  801fd9:	c3                   	ret    

00801fda <devcons_write>:
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	57                   	push   %edi
  801fde:	56                   	push   %esi
  801fdf:	53                   	push   %ebx
  801fe0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801fe6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fea:	74 4a                	je     802036 <devcons_write+0x5c>
  801fec:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff1:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ff6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  801ffc:	8b 75 10             	mov    0x10(%ebp),%esi
  801fff:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  802001:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  802004:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802009:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80200c:	89 74 24 08          	mov    %esi,0x8(%esp)
  802010:	03 45 0c             	add    0xc(%ebp),%eax
  802013:	89 44 24 04          	mov    %eax,0x4(%esp)
  802017:	89 3c 24             	mov    %edi,(%esp)
  80201a:	e8 b7 ea ff ff       	call   800ad6 <memmove>
		sys_cputs(buf, m);
  80201f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802023:	89 3c 24             	mov    %edi,(%esp)
  802026:	e8 91 ec ff ff       	call   800cbc <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80202b:	01 f3                	add    %esi,%ebx
  80202d:	89 d8                	mov    %ebx,%eax
  80202f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802032:	72 c8                	jb     801ffc <devcons_write+0x22>
  802034:	eb 05                	jmp    80203b <devcons_write+0x61>
  802036:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  80203b:	89 d8                	mov    %ebx,%eax
  80203d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    

00802048 <devcons_read>:
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80204e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802053:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802057:	75 07                	jne    802060 <devcons_read+0x18>
  802059:	eb 28                	jmp    802083 <devcons_read+0x3b>
		sys_yield();
  80205b:	e8 0a ed ff ff       	call   800d6a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802060:	e8 75 ec ff ff       	call   800cda <sys_cgetc>
  802065:	85 c0                	test   %eax,%eax
  802067:	74 f2                	je     80205b <devcons_read+0x13>
	if (c < 0)
  802069:	85 c0                	test   %eax,%eax
  80206b:	78 16                	js     802083 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  80206d:	83 f8 04             	cmp    $0x4,%eax
  802070:	74 0c                	je     80207e <devcons_read+0x36>
	*(char*)vbuf = c;
  802072:	8b 55 0c             	mov    0xc(%ebp),%edx
  802075:	88 02                	mov    %al,(%edx)
	return 1;
  802077:	b8 01 00 00 00       	mov    $0x1,%eax
  80207c:	eb 05                	jmp    802083 <devcons_read+0x3b>
		return 0;
  80207e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802083:	c9                   	leave  
  802084:	c3                   	ret    

00802085 <cputchar>:
{
  802085:	55                   	push   %ebp
  802086:	89 e5                	mov    %esp,%ebp
  802088:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80208b:	8b 45 08             	mov    0x8(%ebp),%eax
  80208e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802091:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802098:	00 
  802099:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80209c:	89 04 24             	mov    %eax,(%esp)
  80209f:	e8 18 ec ff ff       	call   800cbc <sys_cputs>
}
  8020a4:	c9                   	leave  
  8020a5:	c3                   	ret    

008020a6 <getchar>:
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  8020ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020b3:	00 
  8020b4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c2:	e8 3f f6 ff ff       	call   801706 <read>
	if (r < 0)
  8020c7:	85 c0                	test   %eax,%eax
  8020c9:	78 0f                	js     8020da <getchar+0x34>
	if (r < 1)
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	7e 06                	jle    8020d5 <getchar+0x2f>
	return c;
  8020cf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020d3:	eb 05                	jmp    8020da <getchar+0x34>
		return -E_EOF;
  8020d5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  8020da:	c9                   	leave  
  8020db:	c3                   	ret    

008020dc <iscons>:
{
  8020dc:	55                   	push   %ebp
  8020dd:	89 e5                	mov    %esp,%ebp
  8020df:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ec:	89 04 24             	mov    %eax,(%esp)
  8020ef:	e8 67 f3 ff ff       	call   80145b <fd_lookup>
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	78 11                	js     802109 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  8020f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802101:	39 10                	cmp    %edx,(%eax)
  802103:	0f 94 c0             	sete   %al
  802106:	0f b6 c0             	movzbl %al,%eax
}
  802109:	c9                   	leave  
  80210a:	c3                   	ret    

0080210b <opencons>:
{
  80210b:	55                   	push   %ebp
  80210c:	89 e5                	mov    %esp,%ebp
  80210e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802111:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802114:	89 04 24             	mov    %eax,(%esp)
  802117:	e8 cb f2 ff ff       	call   8013e7 <fd_alloc>
		return r;
  80211c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80211e:	85 c0                	test   %eax,%eax
  802120:	78 40                	js     802162 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802122:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802129:	00 
  80212a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802131:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802138:	e8 4c ec ff ff       	call   800d89 <sys_page_alloc>
		return r;
  80213d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80213f:	85 c0                	test   %eax,%eax
  802141:	78 1f                	js     802162 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  802143:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802149:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80214e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802151:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802158:	89 04 24             	mov    %eax,(%esp)
  80215b:	e8 60 f2 ff ff       	call   8013c0 <fd2num>
  802160:	89 c2                	mov    %eax,%edx
}
  802162:	89 d0                	mov    %edx,%eax
  802164:	c9                   	leave  
  802165:	c3                   	ret    

00802166 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80216c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802173:	75 70                	jne    8021e5 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  802175:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80217c:	00 
  80217d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802184:	ee 
  802185:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80218c:	e8 f8 eb ff ff       	call   800d89 <sys_page_alloc>
  802191:	85 c0                	test   %eax,%eax
  802193:	79 1c                	jns    8021b1 <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  802195:	c7 44 24 08 f8 2b 80 	movl   $0x802bf8,0x8(%esp)
  80219c:	00 
  80219d:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8021a4:	00 
  8021a5:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  8021ac:	e8 d3 df ff ff       	call   800184 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8021b1:	c7 44 24 04 ef 21 80 	movl   $0x8021ef,0x4(%esp)
  8021b8:	00 
  8021b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c0:	e8 64 ed ff ff       	call   800f29 <sys_env_set_pgfault_upcall>
  8021c5:	85 c0                	test   %eax,%eax
  8021c7:	79 1c                	jns    8021e5 <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  8021c9:	c7 44 24 08 24 2c 80 	movl   $0x802c24,0x8(%esp)
  8021d0:	00 
  8021d1:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8021d8:	00 
  8021d9:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  8021e0:	e8 9f df ff ff       	call   800184 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e8:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8021ed:	c9                   	leave  
  8021ee:	c3                   	ret    

008021ef <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021ef:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021f0:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021f5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021f7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  8021fa:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  8021fe:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  802203:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  802207:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802209:	83 c4 08             	add    $0x8,%esp
	popal
  80220c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80220d:	83 c4 04             	add    $0x4,%esp
	popfl
  802210:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802211:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802212:	c3                   	ret    

00802213 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802213:	55                   	push   %ebp
  802214:	89 e5                	mov    %esp,%ebp
  802216:	56                   	push   %esi
  802217:	53                   	push   %ebx
  802218:	83 ec 10             	sub    $0x10,%esp
  80221b:	8b 75 08             	mov    0x8(%ebp),%esi
  80221e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  802221:	8b 45 0c             	mov    0xc(%ebp),%eax
  802224:	89 04 24             	mov    %eax,(%esp)
  802227:	e8 73 ed ff ff       	call   800f9f <sys_ipc_recv>
	if(from_env_store)
  80222c:	85 f6                	test   %esi,%esi
  80222e:	74 14                	je     802244 <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  802230:	ba 00 00 00 00       	mov    $0x0,%edx
  802235:	85 c0                	test   %eax,%eax
  802237:	78 09                	js     802242 <ipc_recv+0x2f>
  802239:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80223f:	8b 52 74             	mov    0x74(%edx),%edx
  802242:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  802244:	85 db                	test   %ebx,%ebx
  802246:	74 14                	je     80225c <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  802248:	ba 00 00 00 00       	mov    $0x0,%edx
  80224d:	85 c0                	test   %eax,%eax
  80224f:	78 09                	js     80225a <ipc_recv+0x47>
  802251:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802257:	8b 52 78             	mov    0x78(%edx),%edx
  80225a:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  80225c:	85 c0                	test   %eax,%eax
  80225e:	78 08                	js     802268 <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  802260:	a1 08 40 80 00       	mov    0x804008,%eax
  802265:	8b 40 70             	mov    0x70(%eax),%eax
}
  802268:	83 c4 10             	add    $0x10,%esp
  80226b:	5b                   	pop    %ebx
  80226c:	5e                   	pop    %esi
  80226d:	5d                   	pop    %ebp
  80226e:	c3                   	ret    

0080226f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80226f:	55                   	push   %ebp
  802270:	89 e5                	mov    %esp,%ebp
  802272:	57                   	push   %edi
  802273:	56                   	push   %esi
  802274:	53                   	push   %ebx
  802275:	83 ec 1c             	sub    $0x1c,%esp
  802278:	8b 7d 08             	mov    0x8(%ebp),%edi
  80227b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  80227e:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  802283:	eb 0c                	jmp    802291 <ipc_send+0x22>
		failed_cnt++;
  802285:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  802288:	84 db                	test   %bl,%bl
  80228a:	75 05                	jne    802291 <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  80228c:	e8 d9 ea ff ff       	call   800d6a <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  802291:	8b 45 14             	mov    0x14(%ebp),%eax
  802294:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802298:	8b 45 10             	mov    0x10(%ebp),%eax
  80229b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80229f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a3:	89 3c 24             	mov    %edi,(%esp)
  8022a6:	e8 d1 ec ff ff       	call   800f7c <sys_ipc_try_send>
  8022ab:	85 c0                	test   %eax,%eax
  8022ad:	78 d6                	js     802285 <ipc_send+0x16>
	}
}
  8022af:	83 c4 1c             	add    $0x1c,%esp
  8022b2:	5b                   	pop    %ebx
  8022b3:	5e                   	pop    %esi
  8022b4:	5f                   	pop    %edi
  8022b5:	5d                   	pop    %ebp
  8022b6:	c3                   	ret    

008022b7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022b7:	55                   	push   %ebp
  8022b8:	89 e5                	mov    %esp,%ebp
  8022ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8022bd:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8022c2:	39 c8                	cmp    %ecx,%eax
  8022c4:	74 17                	je     8022dd <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  8022c6:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8022cb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022ce:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022d4:	8b 52 50             	mov    0x50(%edx),%edx
  8022d7:	39 ca                	cmp    %ecx,%edx
  8022d9:	75 14                	jne    8022ef <ipc_find_env+0x38>
  8022db:	eb 05                	jmp    8022e2 <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  8022dd:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  8022e2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022e5:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022ea:	8b 40 40             	mov    0x40(%eax),%eax
  8022ed:	eb 0e                	jmp    8022fd <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  8022ef:	83 c0 01             	add    $0x1,%eax
  8022f2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022f7:	75 d2                	jne    8022cb <ipc_find_env+0x14>
	return 0;
  8022f9:	66 b8 00 00          	mov    $0x0,%ax
}
  8022fd:	5d                   	pop    %ebp
  8022fe:	c3                   	ret    

008022ff <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022ff:	55                   	push   %ebp
  802300:	89 e5                	mov    %esp,%ebp
  802302:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802305:	89 d0                	mov    %edx,%eax
  802307:	c1 e8 16             	shr    $0x16,%eax
  80230a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802311:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  802316:	f6 c1 01             	test   $0x1,%cl
  802319:	74 1d                	je     802338 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  80231b:	c1 ea 0c             	shr    $0xc,%edx
  80231e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802325:	f6 c2 01             	test   $0x1,%dl
  802328:	74 0e                	je     802338 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80232a:	c1 ea 0c             	shr    $0xc,%edx
  80232d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802334:	ef 
  802335:	0f b7 c0             	movzwl %ax,%eax
}
  802338:	5d                   	pop    %ebp
  802339:	c3                   	ret    
  80233a:	66 90                	xchg   %ax,%ax
  80233c:	66 90                	xchg   %ax,%ax
  80233e:	66 90                	xchg   %ax,%ax

00802340 <__udivdi3>:
  802340:	55                   	push   %ebp
  802341:	57                   	push   %edi
  802342:	56                   	push   %esi
  802343:	83 ec 0c             	sub    $0xc,%esp
  802346:	8b 44 24 28          	mov    0x28(%esp),%eax
  80234a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80234e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802352:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802356:	85 c0                	test   %eax,%eax
  802358:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80235c:	89 ea                	mov    %ebp,%edx
  80235e:	89 0c 24             	mov    %ecx,(%esp)
  802361:	75 2d                	jne    802390 <__udivdi3+0x50>
  802363:	39 e9                	cmp    %ebp,%ecx
  802365:	77 61                	ja     8023c8 <__udivdi3+0x88>
  802367:	85 c9                	test   %ecx,%ecx
  802369:	89 ce                	mov    %ecx,%esi
  80236b:	75 0b                	jne    802378 <__udivdi3+0x38>
  80236d:	b8 01 00 00 00       	mov    $0x1,%eax
  802372:	31 d2                	xor    %edx,%edx
  802374:	f7 f1                	div    %ecx
  802376:	89 c6                	mov    %eax,%esi
  802378:	31 d2                	xor    %edx,%edx
  80237a:	89 e8                	mov    %ebp,%eax
  80237c:	f7 f6                	div    %esi
  80237e:	89 c5                	mov    %eax,%ebp
  802380:	89 f8                	mov    %edi,%eax
  802382:	f7 f6                	div    %esi
  802384:	89 ea                	mov    %ebp,%edx
  802386:	83 c4 0c             	add    $0xc,%esp
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    
  80238d:	8d 76 00             	lea    0x0(%esi),%esi
  802390:	39 e8                	cmp    %ebp,%eax
  802392:	77 24                	ja     8023b8 <__udivdi3+0x78>
  802394:	0f bd e8             	bsr    %eax,%ebp
  802397:	83 f5 1f             	xor    $0x1f,%ebp
  80239a:	75 3c                	jne    8023d8 <__udivdi3+0x98>
  80239c:	8b 74 24 04          	mov    0x4(%esp),%esi
  8023a0:	39 34 24             	cmp    %esi,(%esp)
  8023a3:	0f 86 9f 00 00 00    	jbe    802448 <__udivdi3+0x108>
  8023a9:	39 d0                	cmp    %edx,%eax
  8023ab:	0f 82 97 00 00 00    	jb     802448 <__udivdi3+0x108>
  8023b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023b8:	31 d2                	xor    %edx,%edx
  8023ba:	31 c0                	xor    %eax,%eax
  8023bc:	83 c4 0c             	add    $0xc,%esp
  8023bf:	5e                   	pop    %esi
  8023c0:	5f                   	pop    %edi
  8023c1:	5d                   	pop    %ebp
  8023c2:	c3                   	ret    
  8023c3:	90                   	nop
  8023c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c8:	89 f8                	mov    %edi,%eax
  8023ca:	f7 f1                	div    %ecx
  8023cc:	31 d2                	xor    %edx,%edx
  8023ce:	83 c4 0c             	add    $0xc,%esp
  8023d1:	5e                   	pop    %esi
  8023d2:	5f                   	pop    %edi
  8023d3:	5d                   	pop    %ebp
  8023d4:	c3                   	ret    
  8023d5:	8d 76 00             	lea    0x0(%esi),%esi
  8023d8:	89 e9                	mov    %ebp,%ecx
  8023da:	8b 3c 24             	mov    (%esp),%edi
  8023dd:	d3 e0                	shl    %cl,%eax
  8023df:	89 c6                	mov    %eax,%esi
  8023e1:	b8 20 00 00 00       	mov    $0x20,%eax
  8023e6:	29 e8                	sub    %ebp,%eax
  8023e8:	89 c1                	mov    %eax,%ecx
  8023ea:	d3 ef                	shr    %cl,%edi
  8023ec:	89 e9                	mov    %ebp,%ecx
  8023ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8023f2:	8b 3c 24             	mov    (%esp),%edi
  8023f5:	09 74 24 08          	or     %esi,0x8(%esp)
  8023f9:	89 d6                	mov    %edx,%esi
  8023fb:	d3 e7                	shl    %cl,%edi
  8023fd:	89 c1                	mov    %eax,%ecx
  8023ff:	89 3c 24             	mov    %edi,(%esp)
  802402:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802406:	d3 ee                	shr    %cl,%esi
  802408:	89 e9                	mov    %ebp,%ecx
  80240a:	d3 e2                	shl    %cl,%edx
  80240c:	89 c1                	mov    %eax,%ecx
  80240e:	d3 ef                	shr    %cl,%edi
  802410:	09 d7                	or     %edx,%edi
  802412:	89 f2                	mov    %esi,%edx
  802414:	89 f8                	mov    %edi,%eax
  802416:	f7 74 24 08          	divl   0x8(%esp)
  80241a:	89 d6                	mov    %edx,%esi
  80241c:	89 c7                	mov    %eax,%edi
  80241e:	f7 24 24             	mull   (%esp)
  802421:	39 d6                	cmp    %edx,%esi
  802423:	89 14 24             	mov    %edx,(%esp)
  802426:	72 30                	jb     802458 <__udivdi3+0x118>
  802428:	8b 54 24 04          	mov    0x4(%esp),%edx
  80242c:	89 e9                	mov    %ebp,%ecx
  80242e:	d3 e2                	shl    %cl,%edx
  802430:	39 c2                	cmp    %eax,%edx
  802432:	73 05                	jae    802439 <__udivdi3+0xf9>
  802434:	3b 34 24             	cmp    (%esp),%esi
  802437:	74 1f                	je     802458 <__udivdi3+0x118>
  802439:	89 f8                	mov    %edi,%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	e9 7a ff ff ff       	jmp    8023bc <__udivdi3+0x7c>
  802442:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802448:	31 d2                	xor    %edx,%edx
  80244a:	b8 01 00 00 00       	mov    $0x1,%eax
  80244f:	e9 68 ff ff ff       	jmp    8023bc <__udivdi3+0x7c>
  802454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802458:	8d 47 ff             	lea    -0x1(%edi),%eax
  80245b:	31 d2                	xor    %edx,%edx
  80245d:	83 c4 0c             	add    $0xc,%esp
  802460:	5e                   	pop    %esi
  802461:	5f                   	pop    %edi
  802462:	5d                   	pop    %ebp
  802463:	c3                   	ret    
  802464:	66 90                	xchg   %ax,%ax
  802466:	66 90                	xchg   %ax,%ax
  802468:	66 90                	xchg   %ax,%ax
  80246a:	66 90                	xchg   %ax,%ax
  80246c:	66 90                	xchg   %ax,%ax
  80246e:	66 90                	xchg   %ax,%ax

00802470 <__umoddi3>:
  802470:	55                   	push   %ebp
  802471:	57                   	push   %edi
  802472:	56                   	push   %esi
  802473:	83 ec 14             	sub    $0x14,%esp
  802476:	8b 44 24 28          	mov    0x28(%esp),%eax
  80247a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80247e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802482:	89 c7                	mov    %eax,%edi
  802484:	89 44 24 04          	mov    %eax,0x4(%esp)
  802488:	8b 44 24 30          	mov    0x30(%esp),%eax
  80248c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802490:	89 34 24             	mov    %esi,(%esp)
  802493:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802497:	85 c0                	test   %eax,%eax
  802499:	89 c2                	mov    %eax,%edx
  80249b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80249f:	75 17                	jne    8024b8 <__umoddi3+0x48>
  8024a1:	39 fe                	cmp    %edi,%esi
  8024a3:	76 4b                	jbe    8024f0 <__umoddi3+0x80>
  8024a5:	89 c8                	mov    %ecx,%eax
  8024a7:	89 fa                	mov    %edi,%edx
  8024a9:	f7 f6                	div    %esi
  8024ab:	89 d0                	mov    %edx,%eax
  8024ad:	31 d2                	xor    %edx,%edx
  8024af:	83 c4 14             	add    $0x14,%esp
  8024b2:	5e                   	pop    %esi
  8024b3:	5f                   	pop    %edi
  8024b4:	5d                   	pop    %ebp
  8024b5:	c3                   	ret    
  8024b6:	66 90                	xchg   %ax,%ax
  8024b8:	39 f8                	cmp    %edi,%eax
  8024ba:	77 54                	ja     802510 <__umoddi3+0xa0>
  8024bc:	0f bd e8             	bsr    %eax,%ebp
  8024bf:	83 f5 1f             	xor    $0x1f,%ebp
  8024c2:	75 5c                	jne    802520 <__umoddi3+0xb0>
  8024c4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8024c8:	39 3c 24             	cmp    %edi,(%esp)
  8024cb:	0f 87 e7 00 00 00    	ja     8025b8 <__umoddi3+0x148>
  8024d1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024d5:	29 f1                	sub    %esi,%ecx
  8024d7:	19 c7                	sbb    %eax,%edi
  8024d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024e1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024e5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024e9:	83 c4 14             	add    $0x14,%esp
  8024ec:	5e                   	pop    %esi
  8024ed:	5f                   	pop    %edi
  8024ee:	5d                   	pop    %ebp
  8024ef:	c3                   	ret    
  8024f0:	85 f6                	test   %esi,%esi
  8024f2:	89 f5                	mov    %esi,%ebp
  8024f4:	75 0b                	jne    802501 <__umoddi3+0x91>
  8024f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024fb:	31 d2                	xor    %edx,%edx
  8024fd:	f7 f6                	div    %esi
  8024ff:	89 c5                	mov    %eax,%ebp
  802501:	8b 44 24 04          	mov    0x4(%esp),%eax
  802505:	31 d2                	xor    %edx,%edx
  802507:	f7 f5                	div    %ebp
  802509:	89 c8                	mov    %ecx,%eax
  80250b:	f7 f5                	div    %ebp
  80250d:	eb 9c                	jmp    8024ab <__umoddi3+0x3b>
  80250f:	90                   	nop
  802510:	89 c8                	mov    %ecx,%eax
  802512:	89 fa                	mov    %edi,%edx
  802514:	83 c4 14             	add    $0x14,%esp
  802517:	5e                   	pop    %esi
  802518:	5f                   	pop    %edi
  802519:	5d                   	pop    %ebp
  80251a:	c3                   	ret    
  80251b:	90                   	nop
  80251c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802520:	8b 04 24             	mov    (%esp),%eax
  802523:	be 20 00 00 00       	mov    $0x20,%esi
  802528:	89 e9                	mov    %ebp,%ecx
  80252a:	29 ee                	sub    %ebp,%esi
  80252c:	d3 e2                	shl    %cl,%edx
  80252e:	89 f1                	mov    %esi,%ecx
  802530:	d3 e8                	shr    %cl,%eax
  802532:	89 e9                	mov    %ebp,%ecx
  802534:	89 44 24 04          	mov    %eax,0x4(%esp)
  802538:	8b 04 24             	mov    (%esp),%eax
  80253b:	09 54 24 04          	or     %edx,0x4(%esp)
  80253f:	89 fa                	mov    %edi,%edx
  802541:	d3 e0                	shl    %cl,%eax
  802543:	89 f1                	mov    %esi,%ecx
  802545:	89 44 24 08          	mov    %eax,0x8(%esp)
  802549:	8b 44 24 10          	mov    0x10(%esp),%eax
  80254d:	d3 ea                	shr    %cl,%edx
  80254f:	89 e9                	mov    %ebp,%ecx
  802551:	d3 e7                	shl    %cl,%edi
  802553:	89 f1                	mov    %esi,%ecx
  802555:	d3 e8                	shr    %cl,%eax
  802557:	89 e9                	mov    %ebp,%ecx
  802559:	09 f8                	or     %edi,%eax
  80255b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80255f:	f7 74 24 04          	divl   0x4(%esp)
  802563:	d3 e7                	shl    %cl,%edi
  802565:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802569:	89 d7                	mov    %edx,%edi
  80256b:	f7 64 24 08          	mull   0x8(%esp)
  80256f:	39 d7                	cmp    %edx,%edi
  802571:	89 c1                	mov    %eax,%ecx
  802573:	89 14 24             	mov    %edx,(%esp)
  802576:	72 2c                	jb     8025a4 <__umoddi3+0x134>
  802578:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80257c:	72 22                	jb     8025a0 <__umoddi3+0x130>
  80257e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802582:	29 c8                	sub    %ecx,%eax
  802584:	19 d7                	sbb    %edx,%edi
  802586:	89 e9                	mov    %ebp,%ecx
  802588:	89 fa                	mov    %edi,%edx
  80258a:	d3 e8                	shr    %cl,%eax
  80258c:	89 f1                	mov    %esi,%ecx
  80258e:	d3 e2                	shl    %cl,%edx
  802590:	89 e9                	mov    %ebp,%ecx
  802592:	d3 ef                	shr    %cl,%edi
  802594:	09 d0                	or     %edx,%eax
  802596:	89 fa                	mov    %edi,%edx
  802598:	83 c4 14             	add    $0x14,%esp
  80259b:	5e                   	pop    %esi
  80259c:	5f                   	pop    %edi
  80259d:	5d                   	pop    %ebp
  80259e:	c3                   	ret    
  80259f:	90                   	nop
  8025a0:	39 d7                	cmp    %edx,%edi
  8025a2:	75 da                	jne    80257e <__umoddi3+0x10e>
  8025a4:	8b 14 24             	mov    (%esp),%edx
  8025a7:	89 c1                	mov    %eax,%ecx
  8025a9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8025ad:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8025b1:	eb cb                	jmp    80257e <__umoddi3+0x10e>
  8025b3:	90                   	nop
  8025b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025b8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8025bc:	0f 82 0f ff ff ff    	jb     8024d1 <__umoddi3+0x61>
  8025c2:	e9 1a ff ff ff       	jmp    8024e1 <__umoddi3+0x71>
