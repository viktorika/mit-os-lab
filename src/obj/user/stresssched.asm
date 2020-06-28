
obj/user/stresssched：     文件格式 elf32-i386


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
  800054:	e8 82 10 00 00       	call   8010db <fork>
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
  8000b3:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000b9:	83 c2 01             	add    $0x1,%edx
  8000bc:	89 15 04 20 80 00    	mov    %edx,0x802004
		for (j = 0; j < 10000; j++)
  8000c2:	83 e8 01             	sub    $0x1,%eax
  8000c5:	75 ec                	jne    8000b3 <umain+0x73>
	for (i = 0; i < 10; i++) {
  8000c7:	83 eb 01             	sub    $0x1,%ebx
  8000ca:	75 dd                	jne    8000a9 <umain+0x69>
	}

	if (counter != 10*10000)
  8000cc:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d1:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000d6:	74 25                	je     8000fd <umain+0xbd>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d8:	a1 04 20 80 00       	mov    0x802004,%eax
  8000dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e1:	c7 44 24 08 60 16 80 	movl   $0x801660,0x8(%esp)
  8000e8:	00 
  8000e9:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000f0:	00 
  8000f1:	c7 04 24 88 16 80 00 	movl   $0x801688,(%esp)
  8000f8:	e8 82 00 00 00       	call   80017f <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000fd:	a1 08 20 80 00       	mov    0x802008,%eax
  800102:	8b 50 5c             	mov    0x5c(%eax),%edx
  800105:	8b 40 48             	mov    0x48(%eax),%eax
  800108:	89 54 24 08          	mov    %edx,0x8(%esp)
  80010c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800110:	c7 04 24 9b 16 80 00 	movl   $0x80169b,(%esp)
  800117:	e8 5c 01 00 00       	call   800278 <cprintf>

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
  800143:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800148:	85 db                	test   %ebx,%ebx
  80014a:	7e 07                	jle    800153 <libmain+0x30>
		binaryname = argv[0];
  80014c:	8b 06                	mov    (%esi),%eax
  80014e:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  800171:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800178:	e8 7c 0b 00 00       	call   800cf9 <sys_env_destroy>
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	56                   	push   %esi
  800183:	53                   	push   %ebx
  800184:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800187:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800190:	e8 b6 0b 00 00       	call   800d4b <sys_getenvid>
  800195:	8b 55 0c             	mov    0xc(%ebp),%edx
  800198:	89 54 24 10          	mov    %edx,0x10(%esp)
  80019c:	8b 55 08             	mov    0x8(%ebp),%edx
  80019f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001a3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ab:	c7 04 24 c4 16 80 00 	movl   $0x8016c4,(%esp)
  8001b2:	e8 c1 00 00 00       	call   800278 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8001be:	89 04 24             	mov    %eax,(%esp)
  8001c1:	e8 51 00 00 00       	call   800217 <vcprintf>
	cprintf("\n");
  8001c6:	c7 04 24 b7 16 80 00 	movl   $0x8016b7,(%esp)
  8001cd:	e8 a6 00 00 00       	call   800278 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d2:	cc                   	int3   
  8001d3:	eb fd                	jmp    8001d2 <_panic+0x53>

008001d5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 14             	sub    $0x14,%esp
  8001dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001df:	8b 13                	mov    (%ebx),%edx
  8001e1:	8d 42 01             	lea    0x1(%edx),%eax
  8001e4:	89 03                	mov    %eax,(%ebx)
  8001e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ed:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f2:	75 19                	jne    80020d <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001f4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001fb:	00 
  8001fc:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ff:	89 04 24             	mov    %eax,(%esp)
  800202:	e8 b5 0a 00 00       	call   800cbc <sys_cputs>
		b->idx = 0;
  800207:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80020d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800211:	83 c4 14             	add    $0x14,%esp
  800214:	5b                   	pop    %ebx
  800215:	5d                   	pop    %ebp
  800216:	c3                   	ret    

00800217 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800220:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800227:	00 00 00 
	b.cnt = 0;
  80022a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800231:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80023b:	8b 45 08             	mov    0x8(%ebp),%eax
  80023e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800242:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800248:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024c:	c7 04 24 d5 01 80 00 	movl   $0x8001d5,(%esp)
  800253:	e8 bc 01 00 00       	call   800414 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800258:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80025e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800262:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	e8 4c 0a 00 00       	call   800cbc <sys_cputs>

	return b.cnt;
}
  800270:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800281:	89 44 24 04          	mov    %eax,0x4(%esp)
  800285:	8b 45 08             	mov    0x8(%ebp),%eax
  800288:	89 04 24             	mov    %eax,(%esp)
  80028b:	e8 87 ff ff ff       	call   800217 <vcprintf>
	va_end(ap);

	return cnt;
}
  800290:	c9                   	leave  
  800291:	c3                   	ret    
  800292:	66 90                	xchg   %ax,%ax
  800294:	66 90                	xchg   %ax,%ax
  800296:	66 90                	xchg   %ax,%ax
  800298:	66 90                	xchg   %ax,%ax
  80029a:	66 90                	xchg   %ax,%ax
  80029c:	66 90                	xchg   %ax,%ax
  80029e:	66 90                	xchg   %ax,%ax

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
  80031c:	e8 af 10 00 00       	call   8013d0 <__udivdi3>
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
  800375:	e8 86 11 00 00       	call   801500 <__umoddi3>
  80037a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80037e:	0f be 80 e7 16 80 00 	movsbl 0x8016e7(%eax),%eax
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
  80049c:	ff 24 85 a0 17 80 00 	jmp    *0x8017a0(,%eax,4)
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
  80054a:	83 f8 08             	cmp    $0x8,%eax
  80054d:	7f 0b                	jg     80055a <vprintfmt+0x146>
  80054f:	8b 14 85 00 19 80 00 	mov    0x801900(,%eax,4),%edx
  800556:	85 d2                	test   %edx,%edx
  800558:	75 20                	jne    80057a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80055a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055e:	c7 44 24 08 ff 16 80 	movl   $0x8016ff,0x8(%esp)
  800565:	00 
  800566:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056a:	8b 45 08             	mov    0x8(%ebp),%eax
  80056d:	89 04 24             	mov    %eax,(%esp)
  800570:	e8 77 fe ff ff       	call   8003ec <printfmt>
  800575:	e9 c3 fe ff ff       	jmp    80043d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80057a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80057e:	c7 44 24 08 08 17 80 	movl   $0x801708,0x8(%esp)
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
  8005ad:	ba f8 16 80 00       	mov    $0x8016f8,%edx
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
  800d27:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  800d2e:	00 
  800d2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d36:	00 
  800d37:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  800d3e:	e8 3c f4 ff ff       	call   80017f <_panic>
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
  800d75:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800db9:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  800dc0:	00 
  800dc1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc8:	00 
  800dc9:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  800dd0:	e8 aa f3 ff ff       	call   80017f <_panic>
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
  800e0c:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  800e13:	00 
  800e14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1b:	00 
  800e1c:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  800e23:	e8 57 f3 ff ff       	call   80017f <_panic>
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
  800e5f:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  800e66:	00 
  800e67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6e:	00 
  800e6f:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  800e76:	e8 04 f3 ff ff       	call   80017f <_panic>
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
  800eb2:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  800eb9:	00 
  800eba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec1:	00 
  800ec2:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  800ec9:	e8 b1 f2 ff ff       	call   80017f <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ece:	83 c4 2c             	add    $0x2c,%esp
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800ef7:	7e 28                	jle    800f21 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f04:	00 
  800f05:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f14:	00 
  800f15:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  800f1c:	e8 5e f2 ff ff       	call   80017f <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f21:	83 c4 2c             	add    $0x2c,%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	57                   	push   %edi
  800f2d:	56                   	push   %esi
  800f2e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f2f:	be 00 00 00 00       	mov    $0x0,%esi
  800f34:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f45:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	57                   	push   %edi
  800f50:	56                   	push   %esi
  800f51:	53                   	push   %ebx
  800f52:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f5a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f62:	89 cb                	mov    %ecx,%ebx
  800f64:	89 cf                	mov    %ecx,%edi
  800f66:	89 ce                	mov    %ecx,%esi
  800f68:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	7e 28                	jle    800f96 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f72:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f79:	00 
  800f7a:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  800f81:	00 
  800f82:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f89:	00 
  800f8a:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  800f91:	e8 e9 f1 ff ff       	call   80017f <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f96:	83 c4 2c             	add    $0x2c,%esp
  800f99:	5b                   	pop    %ebx
  800f9a:	5e                   	pop    %esi
  800f9b:	5f                   	pop    %edi
  800f9c:	5d                   	pop    %ebp
  800f9d:	c3                   	ret    

00800f9e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	53                   	push   %ebx
  800fa2:	83 ec 24             	sub    $0x24,%esp
  800fa5:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800fa8:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800faa:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800fae:	74 2e                	je     800fde <pgfault+0x40>
  800fb0:	89 c2                	mov    %eax,%edx
  800fb2:	c1 ea 16             	shr    $0x16,%edx
  800fb5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fbc:	f6 c2 01             	test   $0x1,%dl
  800fbf:	74 1d                	je     800fde <pgfault+0x40>
  800fc1:	89 c2                	mov    %eax,%edx
  800fc3:	c1 ea 0c             	shr    $0xc,%edx
  800fc6:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800fcd:	f6 c1 01             	test   $0x1,%cl
  800fd0:	74 0c                	je     800fde <pgfault+0x40>
  800fd2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fd9:	f6 c6 08             	test   $0x8,%dh
  800fdc:	75 20                	jne    800ffe <pgfault+0x60>
		panic("pgfault: page cow check failed, addr=%x\n", addr);
  800fde:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fe2:	c7 44 24 08 50 19 80 	movl   $0x801950,0x8(%esp)
  800fe9:	00 
  800fea:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800ff1:	00 
  800ff2:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  800ff9:	e8 81 f1 ff ff       	call   80017f <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800ffe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801003:	89 c3                	mov    %eax,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W))
  801005:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80100c:	00 
  80100d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801014:	00 
  801015:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80101c:	e8 68 fd ff ff       	call   800d89 <sys_page_alloc>
  801021:	85 c0                	test   %eax,%eax
  801023:	74 1c                	je     801041 <pgfault+0xa3>
		panic("pgfault: sys_page_alloc error");
  801025:	c7 44 24 08 1a 1a 80 	movl   $0x801a1a,0x8(%esp)
  80102c:	00 
  80102d:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801034:	00 
  801035:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  80103c:	e8 3e f1 ff ff       	call   80017f <_panic>

	memmove(PFTEMP, addr, PGSIZE);
  801041:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801048:	00 
  801049:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80104d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801054:	e8 7d fa ff ff       	call   800ad6 <memmove>
	if(sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))
  801059:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801060:	00 
  801061:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801065:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80106c:	00 
  80106d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801074:	00 
  801075:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80107c:	e8 5c fd ff ff       	call   800ddd <sys_page_map>
  801081:	85 c0                	test   %eax,%eax
  801083:	74 1c                	je     8010a1 <pgfault+0x103>
		panic("pgfault: sys_page_map error");
  801085:	c7 44 24 08 38 1a 80 	movl   $0x801a38,0x8(%esp)
  80108c:	00 
  80108d:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801094:	00 
  801095:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  80109c:	e8 de f0 ff ff       	call   80017f <_panic>

	if(sys_page_unmap(0, PFTEMP))
  8010a1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010a8:	00 
  8010a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b0:	e8 7b fd ff ff       	call   800e30 <sys_page_unmap>
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	74 1c                	je     8010d5 <pgfault+0x137>
		panic("pgfault: sys_page_unmap error");
  8010b9:	c7 44 24 08 54 1a 80 	movl   $0x801a54,0x8(%esp)
  8010c0:	00 
  8010c1:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8010c8:	00 
  8010c9:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  8010d0:	e8 aa f0 ff ff       	call   80017f <_panic>
}
  8010d5:	83 c4 24             	add    $0x24,%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	53                   	push   %ebx
  8010e1:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	//根据文档的描述，duppage好像不应该处理除了可写或者copy-on-write的部分，但这里都交给duppage一块处理了
	set_pgfault_handler(pgfault);
  8010e4:	c7 04 24 9e 0f 80 00 	movl   $0x800f9e,(%esp)
  8010eb:	e8 24 02 00 00       	call   801314 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010f0:	b8 07 00 00 00       	mov    $0x7,%eax
  8010f5:	cd 30                	int    $0x30
  8010f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();
	if(envid < 0)
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	79 1c                	jns    80111a <fork+0x3f>
		//失败
		panic("fork: sys_exofork error");
  8010fe:	c7 44 24 08 72 1a 80 	movl   $0x801a72,0x8(%esp)
  801105:	00 
  801106:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  80110d:	00 
  80110e:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  801115:	e8 65 f0 ff ff       	call   80017f <_panic>
  80111a:	89 c7                	mov    %eax,%edi
	else if(!envid)
  80111c:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801121:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801125:	75 1c                	jne    801143 <fork+0x68>
		//子进程
		thisenv = &envs[ENVX(sys_getenvid())];
  801127:	e8 1f fc ff ff       	call   800d4b <sys_getenvid>
  80112c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801131:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801134:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801139:	a3 08 20 80 00       	mov    %eax,0x802008
  80113e:	e9 a4 01 00 00       	jmp    8012e7 <fork+0x20c>
	else{
		//父进程
		unsigned addr;
		for(addr = UTEXT; addr < USTACKTOP; addr+= PGSIZE){
			if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))
  801143:	89 d8                	mov    %ebx,%eax
  801145:	c1 e8 16             	shr    $0x16,%eax
  801148:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80114f:	a8 01                	test   $0x1,%al
  801151:	0f 84 00 01 00 00    	je     801257 <fork+0x17c>
  801157:	89 d8                	mov    %ebx,%eax
  801159:	c1 e8 0c             	shr    $0xc,%eax
  80115c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801163:	f6 c2 01             	test   $0x1,%dl
  801166:	0f 84 eb 00 00 00    	je     801257 <fork+0x17c>
  80116c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801173:	f6 c2 04             	test   $0x4,%dl
  801176:	0f 84 db 00 00 00    	je     801257 <fork+0x17c>
	void *addr = (void *)(pn * PGSIZE);
  80117c:	89 c6                	mov    %eax,%esi
  80117e:	c1 e6 0c             	shl    $0xc,%esi
	if(uvpt[pn] & (PTE_W | PTE_COW)){
  801181:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801188:	a9 02 08 00 00       	test   $0x802,%eax
  80118d:	0f 84 84 00 00 00    	je     801217 <fork+0x13c>
		if(sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P))
  801193:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80119a:	00 
  80119b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80119f:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ae:	e8 2a fc ff ff       	call   800ddd <sys_page_map>
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	74 1c                	je     8011d3 <fork+0xf8>
			panic("duppage: sys_page_map child error");
  8011b7:	c7 44 24 08 7c 19 80 	movl   $0x80197c,0x8(%esp)
  8011be:	00 
  8011bf:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  8011c6:	00 
  8011c7:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  8011ce:	e8 ac ef ff ff       	call   80017f <_panic>
		if(sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P))
  8011d3:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011da:	00 
  8011db:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011e6:	00 
  8011e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f2:	e8 e6 fb ff ff       	call   800ddd <sys_page_map>
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	74 5c                	je     801257 <fork+0x17c>
			panic("duppage: sys_page_map remap parent error");
  8011fb:	c7 44 24 08 a0 19 80 	movl   $0x8019a0,0x8(%esp)
  801202:	00 
  801203:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  80120a:	00 
  80120b:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  801212:	e8 68 ef ff ff       	call   80017f <_panic>
		if(sys_page_map(0, addr, envid, addr, PTE_U|PTE_P))
  801217:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80121e:	00 
  80121f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801223:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801227:	89 74 24 04          	mov    %esi,0x4(%esp)
  80122b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801232:	e8 a6 fb ff ff       	call   800ddd <sys_page_map>
  801237:	85 c0                	test   %eax,%eax
  801239:	74 1c                	je     801257 <fork+0x17c>
			panic("duppage: other sys_page_map error");
  80123b:	c7 44 24 08 cc 19 80 	movl   $0x8019cc,0x8(%esp)
  801242:	00 
  801243:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  80124a:	00 
  80124b:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  801252:	e8 28 ef ff ff       	call   80017f <_panic>
		for(addr = UTEXT; addr < USTACKTOP; addr+= PGSIZE){
  801257:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80125d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801263:	0f 85 da fe ff ff    	jne    801143 <fork+0x68>
				duppage(envid, PGNUM(addr));
		}
		if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W))
  801269:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801270:	00 
  801271:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801278:	ee 
  801279:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80127c:	89 04 24             	mov    %eax,(%esp)
  80127f:	e8 05 fb ff ff       	call   800d89 <sys_page_alloc>
  801284:	85 c0                	test   %eax,%eax
  801286:	74 1c                	je     8012a4 <fork+0x1c9>
			panic("fork: sys_page_alloc error");
  801288:	c7 44 24 08 8a 1a 80 	movl   $0x801a8a,0x8(%esp)
  80128f:	00 
  801290:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  801297:	00 
  801298:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  80129f:	e8 db ee ff ff       	call   80017f <_panic>
		extern void _pgfault_upcall();
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8012a4:	c7 44 24 04 9d 13 80 	movl   $0x80139d,0x4(%esp)
  8012ab:	00 
  8012ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012af:	89 3c 24             	mov    %edi,(%esp)
  8012b2:	e8 1f fc ff ff       	call   800ed6 <sys_env_set_pgfault_upcall>
		if(sys_env_set_status(envid, ENV_RUNNABLE))
  8012b7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012be:	00 
  8012bf:	89 3c 24             	mov    %edi,(%esp)
  8012c2:	e8 bc fb ff ff       	call   800e83 <sys_env_set_status>
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	74 1c                	je     8012e7 <fork+0x20c>
			panic("fork: sys_env_set_status error");
  8012cb:	c7 44 24 08 f0 19 80 	movl   $0x8019f0,0x8(%esp)
  8012d2:	00 
  8012d3:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  8012da:	00 
  8012db:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  8012e2:	e8 98 ee ff ff       	call   80017f <_panic>
	}
	return envid;
}
  8012e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012ea:	83 c4 2c             	add    $0x2c,%esp
  8012ed:	5b                   	pop    %ebx
  8012ee:	5e                   	pop    %esi
  8012ef:	5f                   	pop    %edi
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    

008012f2 <sfork>:

// Challenge!
int
sfork(void)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012f8:	c7 44 24 08 a5 1a 80 	movl   $0x801aa5,0x8(%esp)
  8012ff:	00 
  801300:	c7 44 24 04 87 00 00 	movl   $0x87,0x4(%esp)
  801307:	00 
  801308:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  80130f:	e8 6b ee ff ff       	call   80017f <_panic>

00801314 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80131a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801321:	75 70                	jne    801393 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  801323:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80132a:	00 
  80132b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801332:	ee 
  801333:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80133a:	e8 4a fa ff ff       	call   800d89 <sys_page_alloc>
  80133f:	85 c0                	test   %eax,%eax
  801341:	79 1c                	jns    80135f <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  801343:	c7 44 24 08 bc 1a 80 	movl   $0x801abc,0x8(%esp)
  80134a:	00 
  80134b:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801352:	00 
  801353:	c7 04 24 20 1b 80 00 	movl   $0x801b20,(%esp)
  80135a:	e8 20 ee ff ff       	call   80017f <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80135f:	c7 44 24 04 9d 13 80 	movl   $0x80139d,0x4(%esp)
  801366:	00 
  801367:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80136e:	e8 63 fb ff ff       	call   800ed6 <sys_env_set_pgfault_upcall>
  801373:	85 c0                	test   %eax,%eax
  801375:	79 1c                	jns    801393 <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  801377:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  80137e:	00 
  80137f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801386:	00 
  801387:	c7 04 24 20 1b 80 00 	movl   $0x801b20,(%esp)
  80138e:	e8 ec ed ff ff       	call   80017f <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801393:	8b 45 08             	mov    0x8(%ebp),%eax
  801396:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80139b:	c9                   	leave  
  80139c:	c3                   	ret    

0080139d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80139d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80139e:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8013a3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013a5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  8013a8:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  8013ac:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  8013b1:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  8013b5:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8013b7:	83 c4 08             	add    $0x8,%esp
	popal
  8013ba:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8013bb:	83 c4 04             	add    $0x4,%esp
	popfl
  8013be:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8013bf:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8013c0:	c3                   	ret    
  8013c1:	66 90                	xchg   %ax,%ax
  8013c3:	66 90                	xchg   %ax,%ax
  8013c5:	66 90                	xchg   %ax,%ax
  8013c7:	66 90                	xchg   %ax,%ax
  8013c9:	66 90                	xchg   %ax,%ax
  8013cb:	66 90                	xchg   %ax,%ax
  8013cd:	66 90                	xchg   %ax,%ax
  8013cf:	90                   	nop

008013d0 <__udivdi3>:
  8013d0:	55                   	push   %ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	83 ec 0c             	sub    $0xc,%esp
  8013d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013da:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8013de:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8013e2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013ec:	89 ea                	mov    %ebp,%edx
  8013ee:	89 0c 24             	mov    %ecx,(%esp)
  8013f1:	75 2d                	jne    801420 <__udivdi3+0x50>
  8013f3:	39 e9                	cmp    %ebp,%ecx
  8013f5:	77 61                	ja     801458 <__udivdi3+0x88>
  8013f7:	85 c9                	test   %ecx,%ecx
  8013f9:	89 ce                	mov    %ecx,%esi
  8013fb:	75 0b                	jne    801408 <__udivdi3+0x38>
  8013fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801402:	31 d2                	xor    %edx,%edx
  801404:	f7 f1                	div    %ecx
  801406:	89 c6                	mov    %eax,%esi
  801408:	31 d2                	xor    %edx,%edx
  80140a:	89 e8                	mov    %ebp,%eax
  80140c:	f7 f6                	div    %esi
  80140e:	89 c5                	mov    %eax,%ebp
  801410:	89 f8                	mov    %edi,%eax
  801412:	f7 f6                	div    %esi
  801414:	89 ea                	mov    %ebp,%edx
  801416:	83 c4 0c             	add    $0xc,%esp
  801419:	5e                   	pop    %esi
  80141a:	5f                   	pop    %edi
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    
  80141d:	8d 76 00             	lea    0x0(%esi),%esi
  801420:	39 e8                	cmp    %ebp,%eax
  801422:	77 24                	ja     801448 <__udivdi3+0x78>
  801424:	0f bd e8             	bsr    %eax,%ebp
  801427:	83 f5 1f             	xor    $0x1f,%ebp
  80142a:	75 3c                	jne    801468 <__udivdi3+0x98>
  80142c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801430:	39 34 24             	cmp    %esi,(%esp)
  801433:	0f 86 9f 00 00 00    	jbe    8014d8 <__udivdi3+0x108>
  801439:	39 d0                	cmp    %edx,%eax
  80143b:	0f 82 97 00 00 00    	jb     8014d8 <__udivdi3+0x108>
  801441:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801448:	31 d2                	xor    %edx,%edx
  80144a:	31 c0                	xor    %eax,%eax
  80144c:	83 c4 0c             	add    $0xc,%esp
  80144f:	5e                   	pop    %esi
  801450:	5f                   	pop    %edi
  801451:	5d                   	pop    %ebp
  801452:	c3                   	ret    
  801453:	90                   	nop
  801454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801458:	89 f8                	mov    %edi,%eax
  80145a:	f7 f1                	div    %ecx
  80145c:	31 d2                	xor    %edx,%edx
  80145e:	83 c4 0c             	add    $0xc,%esp
  801461:	5e                   	pop    %esi
  801462:	5f                   	pop    %edi
  801463:	5d                   	pop    %ebp
  801464:	c3                   	ret    
  801465:	8d 76 00             	lea    0x0(%esi),%esi
  801468:	89 e9                	mov    %ebp,%ecx
  80146a:	8b 3c 24             	mov    (%esp),%edi
  80146d:	d3 e0                	shl    %cl,%eax
  80146f:	89 c6                	mov    %eax,%esi
  801471:	b8 20 00 00 00       	mov    $0x20,%eax
  801476:	29 e8                	sub    %ebp,%eax
  801478:	89 c1                	mov    %eax,%ecx
  80147a:	d3 ef                	shr    %cl,%edi
  80147c:	89 e9                	mov    %ebp,%ecx
  80147e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801482:	8b 3c 24             	mov    (%esp),%edi
  801485:	09 74 24 08          	or     %esi,0x8(%esp)
  801489:	89 d6                	mov    %edx,%esi
  80148b:	d3 e7                	shl    %cl,%edi
  80148d:	89 c1                	mov    %eax,%ecx
  80148f:	89 3c 24             	mov    %edi,(%esp)
  801492:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801496:	d3 ee                	shr    %cl,%esi
  801498:	89 e9                	mov    %ebp,%ecx
  80149a:	d3 e2                	shl    %cl,%edx
  80149c:	89 c1                	mov    %eax,%ecx
  80149e:	d3 ef                	shr    %cl,%edi
  8014a0:	09 d7                	or     %edx,%edi
  8014a2:	89 f2                	mov    %esi,%edx
  8014a4:	89 f8                	mov    %edi,%eax
  8014a6:	f7 74 24 08          	divl   0x8(%esp)
  8014aa:	89 d6                	mov    %edx,%esi
  8014ac:	89 c7                	mov    %eax,%edi
  8014ae:	f7 24 24             	mull   (%esp)
  8014b1:	39 d6                	cmp    %edx,%esi
  8014b3:	89 14 24             	mov    %edx,(%esp)
  8014b6:	72 30                	jb     8014e8 <__udivdi3+0x118>
  8014b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014bc:	89 e9                	mov    %ebp,%ecx
  8014be:	d3 e2                	shl    %cl,%edx
  8014c0:	39 c2                	cmp    %eax,%edx
  8014c2:	73 05                	jae    8014c9 <__udivdi3+0xf9>
  8014c4:	3b 34 24             	cmp    (%esp),%esi
  8014c7:	74 1f                	je     8014e8 <__udivdi3+0x118>
  8014c9:	89 f8                	mov    %edi,%eax
  8014cb:	31 d2                	xor    %edx,%edx
  8014cd:	e9 7a ff ff ff       	jmp    80144c <__udivdi3+0x7c>
  8014d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014d8:	31 d2                	xor    %edx,%edx
  8014da:	b8 01 00 00 00       	mov    $0x1,%eax
  8014df:	e9 68 ff ff ff       	jmp    80144c <__udivdi3+0x7c>
  8014e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8014eb:	31 d2                	xor    %edx,%edx
  8014ed:	83 c4 0c             	add    $0xc,%esp
  8014f0:	5e                   	pop    %esi
  8014f1:	5f                   	pop    %edi
  8014f2:	5d                   	pop    %ebp
  8014f3:	c3                   	ret    
  8014f4:	66 90                	xchg   %ax,%ax
  8014f6:	66 90                	xchg   %ax,%ax
  8014f8:	66 90                	xchg   %ax,%ax
  8014fa:	66 90                	xchg   %ax,%ax
  8014fc:	66 90                	xchg   %ax,%ax
  8014fe:	66 90                	xchg   %ax,%ax

00801500 <__umoddi3>:
  801500:	55                   	push   %ebp
  801501:	57                   	push   %edi
  801502:	56                   	push   %esi
  801503:	83 ec 14             	sub    $0x14,%esp
  801506:	8b 44 24 28          	mov    0x28(%esp),%eax
  80150a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80150e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801512:	89 c7                	mov    %eax,%edi
  801514:	89 44 24 04          	mov    %eax,0x4(%esp)
  801518:	8b 44 24 30          	mov    0x30(%esp),%eax
  80151c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801520:	89 34 24             	mov    %esi,(%esp)
  801523:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801527:	85 c0                	test   %eax,%eax
  801529:	89 c2                	mov    %eax,%edx
  80152b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80152f:	75 17                	jne    801548 <__umoddi3+0x48>
  801531:	39 fe                	cmp    %edi,%esi
  801533:	76 4b                	jbe    801580 <__umoddi3+0x80>
  801535:	89 c8                	mov    %ecx,%eax
  801537:	89 fa                	mov    %edi,%edx
  801539:	f7 f6                	div    %esi
  80153b:	89 d0                	mov    %edx,%eax
  80153d:	31 d2                	xor    %edx,%edx
  80153f:	83 c4 14             	add    $0x14,%esp
  801542:	5e                   	pop    %esi
  801543:	5f                   	pop    %edi
  801544:	5d                   	pop    %ebp
  801545:	c3                   	ret    
  801546:	66 90                	xchg   %ax,%ax
  801548:	39 f8                	cmp    %edi,%eax
  80154a:	77 54                	ja     8015a0 <__umoddi3+0xa0>
  80154c:	0f bd e8             	bsr    %eax,%ebp
  80154f:	83 f5 1f             	xor    $0x1f,%ebp
  801552:	75 5c                	jne    8015b0 <__umoddi3+0xb0>
  801554:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801558:	39 3c 24             	cmp    %edi,(%esp)
  80155b:	0f 87 e7 00 00 00    	ja     801648 <__umoddi3+0x148>
  801561:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801565:	29 f1                	sub    %esi,%ecx
  801567:	19 c7                	sbb    %eax,%edi
  801569:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80156d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801571:	8b 44 24 08          	mov    0x8(%esp),%eax
  801575:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801579:	83 c4 14             	add    $0x14,%esp
  80157c:	5e                   	pop    %esi
  80157d:	5f                   	pop    %edi
  80157e:	5d                   	pop    %ebp
  80157f:	c3                   	ret    
  801580:	85 f6                	test   %esi,%esi
  801582:	89 f5                	mov    %esi,%ebp
  801584:	75 0b                	jne    801591 <__umoddi3+0x91>
  801586:	b8 01 00 00 00       	mov    $0x1,%eax
  80158b:	31 d2                	xor    %edx,%edx
  80158d:	f7 f6                	div    %esi
  80158f:	89 c5                	mov    %eax,%ebp
  801591:	8b 44 24 04          	mov    0x4(%esp),%eax
  801595:	31 d2                	xor    %edx,%edx
  801597:	f7 f5                	div    %ebp
  801599:	89 c8                	mov    %ecx,%eax
  80159b:	f7 f5                	div    %ebp
  80159d:	eb 9c                	jmp    80153b <__umoddi3+0x3b>
  80159f:	90                   	nop
  8015a0:	89 c8                	mov    %ecx,%eax
  8015a2:	89 fa                	mov    %edi,%edx
  8015a4:	83 c4 14             	add    $0x14,%esp
  8015a7:	5e                   	pop    %esi
  8015a8:	5f                   	pop    %edi
  8015a9:	5d                   	pop    %ebp
  8015aa:	c3                   	ret    
  8015ab:	90                   	nop
  8015ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015b0:	8b 04 24             	mov    (%esp),%eax
  8015b3:	be 20 00 00 00       	mov    $0x20,%esi
  8015b8:	89 e9                	mov    %ebp,%ecx
  8015ba:	29 ee                	sub    %ebp,%esi
  8015bc:	d3 e2                	shl    %cl,%edx
  8015be:	89 f1                	mov    %esi,%ecx
  8015c0:	d3 e8                	shr    %cl,%eax
  8015c2:	89 e9                	mov    %ebp,%ecx
  8015c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c8:	8b 04 24             	mov    (%esp),%eax
  8015cb:	09 54 24 04          	or     %edx,0x4(%esp)
  8015cf:	89 fa                	mov    %edi,%edx
  8015d1:	d3 e0                	shl    %cl,%eax
  8015d3:	89 f1                	mov    %esi,%ecx
  8015d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8015dd:	d3 ea                	shr    %cl,%edx
  8015df:	89 e9                	mov    %ebp,%ecx
  8015e1:	d3 e7                	shl    %cl,%edi
  8015e3:	89 f1                	mov    %esi,%ecx
  8015e5:	d3 e8                	shr    %cl,%eax
  8015e7:	89 e9                	mov    %ebp,%ecx
  8015e9:	09 f8                	or     %edi,%eax
  8015eb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8015ef:	f7 74 24 04          	divl   0x4(%esp)
  8015f3:	d3 e7                	shl    %cl,%edi
  8015f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015f9:	89 d7                	mov    %edx,%edi
  8015fb:	f7 64 24 08          	mull   0x8(%esp)
  8015ff:	39 d7                	cmp    %edx,%edi
  801601:	89 c1                	mov    %eax,%ecx
  801603:	89 14 24             	mov    %edx,(%esp)
  801606:	72 2c                	jb     801634 <__umoddi3+0x134>
  801608:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80160c:	72 22                	jb     801630 <__umoddi3+0x130>
  80160e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801612:	29 c8                	sub    %ecx,%eax
  801614:	19 d7                	sbb    %edx,%edi
  801616:	89 e9                	mov    %ebp,%ecx
  801618:	89 fa                	mov    %edi,%edx
  80161a:	d3 e8                	shr    %cl,%eax
  80161c:	89 f1                	mov    %esi,%ecx
  80161e:	d3 e2                	shl    %cl,%edx
  801620:	89 e9                	mov    %ebp,%ecx
  801622:	d3 ef                	shr    %cl,%edi
  801624:	09 d0                	or     %edx,%eax
  801626:	89 fa                	mov    %edi,%edx
  801628:	83 c4 14             	add    $0x14,%esp
  80162b:	5e                   	pop    %esi
  80162c:	5f                   	pop    %edi
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    
  80162f:	90                   	nop
  801630:	39 d7                	cmp    %edx,%edi
  801632:	75 da                	jne    80160e <__umoddi3+0x10e>
  801634:	8b 14 24             	mov    (%esp),%edx
  801637:	89 c1                	mov    %eax,%ecx
  801639:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80163d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801641:	eb cb                	jmp    80160e <__umoddi3+0x10e>
  801643:	90                   	nop
  801644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801648:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80164c:	0f 82 0f ff ff ff    	jb     801561 <__umoddi3+0x61>
  801652:	e9 1a ff ff ff       	jmp    801571 <__umoddi3+0x71>
