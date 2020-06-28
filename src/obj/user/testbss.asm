
obj/user/testbss：     文件格式 elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
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

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800046:	c7 04 24 40 12 80 00 	movl   $0x801240,(%esp)
  80004d:	e8 36 02 00 00       	call   800288 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800052:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  800059:	75 11                	jne    80006c <umain+0x2c>
	for (i = 0; i < ARRAYSIZE; i++)
  80005b:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != 0)
  800060:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800067:	00 
  800068:	74 27                	je     800091 <umain+0x51>
  80006a:	eb 05                	jmp    800071 <umain+0x31>
	for (i = 0; i < ARRAYSIZE; i++)
  80006c:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] isn't cleared!\n", i);
  800071:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800075:	c7 44 24 08 bb 12 80 	movl   $0x8012bb,0x8(%esp)
  80007c:	00 
  80007d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800084:	00 
  800085:	c7 04 24 d8 12 80 00 	movl   $0x8012d8,(%esp)
  80008c:	e8 fe 00 00 00       	call   80018f <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
  800091:	83 c0 01             	add    $0x1,%eax
  800094:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800099:	75 c5                	jne    800060 <umain+0x20>
  80009b:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  8000a0:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 ef                	jne    8000a0 <umain+0x60>
  8000b1:	eb 70                	jmp    800123 <umain+0xe3>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000b3:	3b 04 85 20 20 80 00 	cmp    0x802020(,%eax,4),%eax
  8000ba:	74 2b                	je     8000e7 <umain+0xa7>
  8000bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8000c0:	eb 05                	jmp    8000c7 <umain+0x87>
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000cb:	c7 44 24 08 60 12 80 	movl   $0x801260,0x8(%esp)
  8000d2:	00 
  8000d3:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000da:	00 
  8000db:	c7 04 24 d8 12 80 00 	movl   $0x8012d8,(%esp)
  8000e2:	e8 a8 00 00 00       	call   80018f <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
  8000e7:	83 c0 01             	add    $0x1,%eax
  8000ea:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000ef:	75 c2                	jne    8000b3 <umain+0x73>

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000f1:	c7 04 24 88 12 80 00 	movl   $0x801288,(%esp)
  8000f8:	e8 8b 01 00 00       	call   800288 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000fd:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  800104:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800107:	c7 44 24 08 e7 12 80 	movl   $0x8012e7,0x8(%esp)
  80010e:	00 
  80010f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800116:	00 
  800117:	c7 04 24 d8 12 80 00 	movl   $0x8012d8,(%esp)
  80011e:	e8 6c 00 00 00       	call   80018f <_panic>
		if (bigarray[i] != i)
  800123:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  80012a:	75 96                	jne    8000c2 <umain+0x82>
	for (i = 0; i < ARRAYSIZE; i++)
  80012c:	b8 01 00 00 00       	mov    $0x1,%eax
  800131:	eb 80                	jmp    8000b3 <umain+0x73>

00800133 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	83 ec 10             	sub    $0x10,%esp
  80013b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800141:	e8 15 0c 00 00       	call   800d5b <sys_getenvid>
  800146:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800153:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800158:	85 db                	test   %ebx,%ebx
  80015a:	7e 07                	jle    800163 <libmain+0x30>
		binaryname = argv[0];
  80015c:	8b 06                	mov    (%esi),%eax
  80015e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800163:	89 74 24 04          	mov    %esi,0x4(%esp)
  800167:	89 1c 24             	mov    %ebx,(%esp)
  80016a:	e8 d1 fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  80016f:	e8 07 00 00 00       	call   80017b <exit>
}
  800174:	83 c4 10             	add    $0x10,%esp
  800177:	5b                   	pop    %ebx
  800178:	5e                   	pop    %esi
  800179:	5d                   	pop    %ebp
  80017a:	c3                   	ret    

0080017b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800181:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800188:	e8 7c 0b 00 00       	call   800d09 <sys_env_destroy>
}
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    

0080018f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
  800194:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800197:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001a0:	e8 b6 0b 00 00       	call   800d5b <sys_getenvid>
  8001a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bb:	c7 04 24 08 13 80 00 	movl   $0x801308,(%esp)
  8001c2:	e8 c1 00 00 00       	call   800288 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ce:	89 04 24             	mov    %eax,(%esp)
  8001d1:	e8 51 00 00 00       	call   800227 <vcprintf>
	cprintf("\n");
  8001d6:	c7 04 24 d6 12 80 00 	movl   $0x8012d6,(%esp)
  8001dd:	e8 a6 00 00 00       	call   800288 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e2:	cc                   	int3   
  8001e3:	eb fd                	jmp    8001e2 <_panic+0x53>

008001e5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 14             	sub    $0x14,%esp
  8001ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ef:	8b 13                	mov    (%ebx),%edx
  8001f1:	8d 42 01             	lea    0x1(%edx),%eax
  8001f4:	89 03                	mov    %eax,(%ebx)
  8001f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001fd:	3d ff 00 00 00       	cmp    $0xff,%eax
  800202:	75 19                	jne    80021d <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800204:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80020b:	00 
  80020c:	8d 43 08             	lea    0x8(%ebx),%eax
  80020f:	89 04 24             	mov    %eax,(%esp)
  800212:	e8 b5 0a 00 00       	call   800ccc <sys_cputs>
		b->idx = 0;
  800217:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80021d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800221:	83 c4 14             	add    $0x14,%esp
  800224:	5b                   	pop    %ebx
  800225:	5d                   	pop    %ebp
  800226:	c3                   	ret    

00800227 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800230:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800237:	00 00 00 
	b.cnt = 0;
  80023a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800241:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800244:	8b 45 0c             	mov    0xc(%ebp),%eax
  800247:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80024b:	8b 45 08             	mov    0x8(%ebp),%eax
  80024e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800252:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	c7 04 24 e5 01 80 00 	movl   $0x8001e5,(%esp)
  800263:	e8 bc 01 00 00       	call   800424 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800268:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80026e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800272:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	e8 4c 0a 00 00       	call   800ccc <sys_cputs>

	return b.cnt;
}
  800280:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800291:	89 44 24 04          	mov    %eax,0x4(%esp)
  800295:	8b 45 08             	mov    0x8(%ebp),%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	e8 87 ff ff ff       	call   800227 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a0:	c9                   	leave  
  8002a1:	c3                   	ret    
  8002a2:	66 90                	xchg   %ax,%ax
  8002a4:	66 90                	xchg   %ax,%ax
  8002a6:	66 90                	xchg   %ax,%ax
  8002a8:	66 90                	xchg   %ax,%ax
  8002aa:	66 90                	xchg   %ax,%ax
  8002ac:	66 90                	xchg   %ax,%ax
  8002ae:	66 90                	xchg   %ax,%ax

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 3c             	sub    $0x3c,%esp
  8002b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bc:	89 d7                	mov    %edx,%edi
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002c7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8002ca:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002d5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002d8:	39 f1                	cmp    %esi,%ecx
  8002da:	72 14                	jb     8002f0 <printnum+0x40>
  8002dc:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002df:	76 0f                	jbe    8002f0 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e4:	8d 70 ff             	lea    -0x1(%eax),%esi
  8002e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002ea:	85 f6                	test   %esi,%esi
  8002ec:	7f 60                	jg     80034e <printnum+0x9e>
  8002ee:	eb 72                	jmp    800362 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002f3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002f7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8002fa:	8d 51 ff             	lea    -0x1(%ecx),%edx
  8002fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800301:	89 44 24 08          	mov    %eax,0x8(%esp)
  800305:	8b 44 24 08          	mov    0x8(%esp),%eax
  800309:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80030d:	89 c3                	mov    %eax,%ebx
  80030f:	89 d6                	mov    %edx,%esi
  800311:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800314:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800317:	89 54 24 08          	mov    %edx,0x8(%esp)
  80031b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80031f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032c:	e8 7f 0c 00 00       	call   800fb0 <__udivdi3>
  800331:	89 d9                	mov    %ebx,%ecx
  800333:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800337:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80033b:	89 04 24             	mov    %eax,(%esp)
  80033e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800342:	89 fa                	mov    %edi,%edx
  800344:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800347:	e8 64 ff ff ff       	call   8002b0 <printnum>
  80034c:	eb 14                	jmp    800362 <printnum+0xb2>
			putch(padc, putdat);
  80034e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800352:	8b 45 18             	mov    0x18(%ebp),%eax
  800355:	89 04 24             	mov    %eax,(%esp)
  800358:	ff d3                	call   *%ebx
		while (--width > 0)
  80035a:	83 ee 01             	sub    $0x1,%esi
  80035d:	75 ef                	jne    80034e <printnum+0x9e>
  80035f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800362:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800366:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80036a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80036d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800370:	89 44 24 08          	mov    %eax,0x8(%esp)
  800374:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800378:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037b:	89 04 24             	mov    %eax,(%esp)
  80037e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800381:	89 44 24 04          	mov    %eax,0x4(%esp)
  800385:	e8 56 0d 00 00       	call   8010e0 <__umoddi3>
  80038a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80038e:	0f be 80 2c 13 80 00 	movsbl 0x80132c(%eax),%eax
  800395:	89 04 24             	mov    %eax,(%esp)
  800398:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80039b:	ff d0                	call   *%eax
}
  80039d:	83 c4 3c             	add    $0x3c,%esp
  8003a0:	5b                   	pop    %ebx
  8003a1:	5e                   	pop    %esi
  8003a2:	5f                   	pop    %edi
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    

008003a5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a8:	83 fa 01             	cmp    $0x1,%edx
  8003ab:	7e 0e                	jle    8003bb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ad:	8b 10                	mov    (%eax),%edx
  8003af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b2:	89 08                	mov    %ecx,(%eax)
  8003b4:	8b 02                	mov    (%edx),%eax
  8003b6:	8b 52 04             	mov    0x4(%edx),%edx
  8003b9:	eb 22                	jmp    8003dd <getuint+0x38>
	else if (lflag)
  8003bb:	85 d2                	test   %edx,%edx
  8003bd:	74 10                	je     8003cf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003bf:	8b 10                	mov    (%eax),%edx
  8003c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c4:	89 08                	mov    %ecx,(%eax)
  8003c6:	8b 02                	mov    (%edx),%eax
  8003c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cd:	eb 0e                	jmp    8003dd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003cf:	8b 10                	mov    (%eax),%edx
  8003d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d4:	89 08                	mov    %ecx,(%eax)
  8003d6:	8b 02                	mov    (%edx),%eax
  8003d8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003e9:	8b 10                	mov    (%eax),%edx
  8003eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ee:	73 0a                	jae    8003fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003f3:	89 08                	mov    %ecx,(%eax)
  8003f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f8:	88 02                	mov    %al,(%edx)
}
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <printfmt>:
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  800402:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800405:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800409:	8b 45 10             	mov    0x10(%ebp),%eax
  80040c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800410:	8b 45 0c             	mov    0xc(%ebp),%eax
  800413:	89 44 24 04          	mov    %eax,0x4(%esp)
  800417:	8b 45 08             	mov    0x8(%ebp),%eax
  80041a:	89 04 24             	mov    %eax,(%esp)
  80041d:	e8 02 00 00 00       	call   800424 <vprintfmt>
}
  800422:	c9                   	leave  
  800423:	c3                   	ret    

00800424 <vprintfmt>:
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	57                   	push   %edi
  800428:	56                   	push   %esi
  800429:	53                   	push   %ebx
  80042a:	83 ec 3c             	sub    $0x3c,%esp
  80042d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800430:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800433:	eb 18                	jmp    80044d <vprintfmt+0x29>
			if (ch == '\0')
  800435:	85 c0                	test   %eax,%eax
  800437:	0f 84 c3 03 00 00    	je     800800 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80043d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800441:	89 04 24             	mov    %eax,(%esp)
  800444:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800447:	89 f3                	mov    %esi,%ebx
  800449:	eb 02                	jmp    80044d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80044b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044d:	8d 73 01             	lea    0x1(%ebx),%esi
  800450:	0f b6 03             	movzbl (%ebx),%eax
  800453:	83 f8 25             	cmp    $0x25,%eax
  800456:	75 dd                	jne    800435 <vprintfmt+0x11>
  800458:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80045c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800463:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80046a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800471:	ba 00 00 00 00       	mov    $0x0,%edx
  800476:	eb 1d                	jmp    800495 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800478:	89 de                	mov    %ebx,%esi
			padc = '-';
  80047a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80047e:	eb 15                	jmp    800495 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800480:	89 de                	mov    %ebx,%esi
			padc = '0';
  800482:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800486:	eb 0d                	jmp    800495 <vprintfmt+0x71>
				width = precision, precision = -1;
  800488:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80048b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80048e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8d 5e 01             	lea    0x1(%esi),%ebx
  800498:	0f b6 06             	movzbl (%esi),%eax
  80049b:	0f b6 c8             	movzbl %al,%ecx
  80049e:	83 e8 23             	sub    $0x23,%eax
  8004a1:	3c 55                	cmp    $0x55,%al
  8004a3:	0f 87 2f 03 00 00    	ja     8007d8 <vprintfmt+0x3b4>
  8004a9:	0f b6 c0             	movzbl %al,%eax
  8004ac:	ff 24 85 00 14 80 00 	jmp    *0x801400(,%eax,4)
				precision = precision * 10 + ch - '0';
  8004b3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8004b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  8004b9:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004bd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004c0:	83 f9 09             	cmp    $0x9,%ecx
  8004c3:	77 50                	ja     800515 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	89 de                	mov    %ebx,%esi
  8004c7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8004ca:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004cd:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004d0:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004d4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004d7:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004da:	83 fb 09             	cmp    $0x9,%ebx
  8004dd:	76 eb                	jbe    8004ca <vprintfmt+0xa6>
  8004df:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004e2:	eb 33                	jmp    800517 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ea:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ed:	8b 00                	mov    (%eax),%eax
  8004ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8004f4:	eb 21                	jmp    800517 <vprintfmt+0xf3>
  8004f6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004f9:	85 c9                	test   %ecx,%ecx
  8004fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800500:	0f 49 c1             	cmovns %ecx,%eax
  800503:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800506:	89 de                	mov    %ebx,%esi
  800508:	eb 8b                	jmp    800495 <vprintfmt+0x71>
  80050a:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80050c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800513:	eb 80                	jmp    800495 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800515:	89 de                	mov    %ebx,%esi
			if (width < 0)
  800517:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80051b:	0f 89 74 ff ff ff    	jns    800495 <vprintfmt+0x71>
  800521:	e9 62 ff ff ff       	jmp    800488 <vprintfmt+0x64>
			lflag++;
  800526:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800529:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80052b:	e9 65 ff ff ff       	jmp    800495 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 50 04             	lea    0x4(%eax),%edx
  800536:	89 55 14             	mov    %edx,0x14(%ebp)
  800539:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053d:	8b 00                	mov    (%eax),%eax
  80053f:	89 04 24             	mov    %eax,(%esp)
  800542:	ff 55 08             	call   *0x8(%ebp)
			break;
  800545:	e9 03 ff ff ff       	jmp    80044d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	99                   	cltd   
  800556:	31 d0                	xor    %edx,%eax
  800558:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055a:	83 f8 08             	cmp    $0x8,%eax
  80055d:	7f 0b                	jg     80056a <vprintfmt+0x146>
  80055f:	8b 14 85 60 15 80 00 	mov    0x801560(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 20                	jne    80058a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80056a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056e:	c7 44 24 08 44 13 80 	movl   $0x801344,0x8(%esp)
  800575:	00 
  800576:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057a:	8b 45 08             	mov    0x8(%ebp),%eax
  80057d:	89 04 24             	mov    %eax,(%esp)
  800580:	e8 77 fe ff ff       	call   8003fc <printfmt>
  800585:	e9 c3 fe ff ff       	jmp    80044d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80058a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80058e:	c7 44 24 08 4d 13 80 	movl   $0x80134d,0x8(%esp)
  800595:	00 
  800596:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80059a:	8b 45 08             	mov    0x8(%ebp),%eax
  80059d:	89 04 24             	mov    %eax,(%esp)
  8005a0:	e8 57 fe ff ff       	call   8003fc <printfmt>
  8005a5:	e9 a3 fe ff ff       	jmp    80044d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005ad:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 04             	lea    0x4(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8005bb:	85 c0                	test   %eax,%eax
  8005bd:	ba 3d 13 80 00       	mov    $0x80133d,%edx
  8005c2:	0f 45 d0             	cmovne %eax,%edx
  8005c5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8005c8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8005cc:	74 04                	je     8005d2 <vprintfmt+0x1ae>
  8005ce:	85 f6                	test   %esi,%esi
  8005d0:	7f 19                	jg     8005eb <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005d5:	8d 70 01             	lea    0x1(%eax),%esi
  8005d8:	0f b6 10             	movzbl (%eax),%edx
  8005db:	0f be c2             	movsbl %dl,%eax
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	0f 85 95 00 00 00    	jne    80067b <vprintfmt+0x257>
  8005e6:	e9 85 00 00 00       	jmp    800670 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005f2:	89 04 24             	mov    %eax,(%esp)
  8005f5:	e8 b8 02 00 00       	call   8008b2 <strnlen>
  8005fa:	29 c6                	sub    %eax,%esi
  8005fc:	89 f0                	mov    %esi,%eax
  8005fe:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800601:	85 f6                	test   %esi,%esi
  800603:	7e cd                	jle    8005d2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800605:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800609:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80060c:	89 c3                	mov    %eax,%ebx
  80060e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800612:	89 34 24             	mov    %esi,(%esp)
  800615:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800618:	83 eb 01             	sub    $0x1,%ebx
  80061b:	75 f1                	jne    80060e <vprintfmt+0x1ea>
  80061d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800620:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800623:	eb ad                	jmp    8005d2 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800625:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800629:	74 1e                	je     800649 <vprintfmt+0x225>
  80062b:	0f be d2             	movsbl %dl,%edx
  80062e:	83 ea 20             	sub    $0x20,%edx
  800631:	83 fa 5e             	cmp    $0x5e,%edx
  800634:	76 13                	jbe    800649 <vprintfmt+0x225>
					putch('?', putdat);
  800636:	8b 45 0c             	mov    0xc(%ebp),%eax
  800639:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800644:	ff 55 08             	call   *0x8(%ebp)
  800647:	eb 0d                	jmp    800656 <vprintfmt+0x232>
					putch(ch, putdat);
  800649:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80064c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800650:	89 04 24             	mov    %eax,(%esp)
  800653:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800656:	83 ef 01             	sub    $0x1,%edi
  800659:	83 c6 01             	add    $0x1,%esi
  80065c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800660:	0f be c2             	movsbl %dl,%eax
  800663:	85 c0                	test   %eax,%eax
  800665:	75 20                	jne    800687 <vprintfmt+0x263>
  800667:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80066a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80066d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800670:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800674:	7f 25                	jg     80069b <vprintfmt+0x277>
  800676:	e9 d2 fd ff ff       	jmp    80044d <vprintfmt+0x29>
  80067b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80067e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800681:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800684:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800687:	85 db                	test   %ebx,%ebx
  800689:	78 9a                	js     800625 <vprintfmt+0x201>
  80068b:	83 eb 01             	sub    $0x1,%ebx
  80068e:	79 95                	jns    800625 <vprintfmt+0x201>
  800690:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800693:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800696:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800699:	eb d5                	jmp    800670 <vprintfmt+0x24c>
  80069b:	8b 75 08             	mov    0x8(%ebp),%esi
  80069e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006a1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  8006a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006af:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006b1:	83 eb 01             	sub    $0x1,%ebx
  8006b4:	75 ee                	jne    8006a4 <vprintfmt+0x280>
  8006b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006b9:	e9 8f fd ff ff       	jmp    80044d <vprintfmt+0x29>
	if (lflag >= 2)
  8006be:	83 fa 01             	cmp    $0x1,%edx
  8006c1:	7e 16                	jle    8006d9 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 50 08             	lea    0x8(%eax),%edx
  8006c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cc:	8b 50 04             	mov    0x4(%eax),%edx
  8006cf:	8b 00                	mov    (%eax),%eax
  8006d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006d7:	eb 32                	jmp    80070b <vprintfmt+0x2e7>
	else if (lflag)
  8006d9:	85 d2                	test   %edx,%edx
  8006db:	74 18                	je     8006f5 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 04             	lea    0x4(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e6:	8b 30                	mov    (%eax),%esi
  8006e8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006eb:	89 f0                	mov    %esi,%eax
  8006ed:	c1 f8 1f             	sar    $0x1f,%eax
  8006f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006f3:	eb 16                	jmp    80070b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8d 50 04             	lea    0x4(%eax),%edx
  8006fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fe:	8b 30                	mov    (%eax),%esi
  800700:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800703:	89 f0                	mov    %esi,%eax
  800705:	c1 f8 1f             	sar    $0x1f,%eax
  800708:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  80070b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80070e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  800711:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800716:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80071a:	0f 89 80 00 00 00    	jns    8007a0 <vprintfmt+0x37c>
				putch('-', putdat);
  800720:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800724:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80072b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80072e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800731:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800734:	f7 d8                	neg    %eax
  800736:	83 d2 00             	adc    $0x0,%edx
  800739:	f7 da                	neg    %edx
			base = 10;
  80073b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800740:	eb 5e                	jmp    8007a0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800742:	8d 45 14             	lea    0x14(%ebp),%eax
  800745:	e8 5b fc ff ff       	call   8003a5 <getuint>
			base = 10;
  80074a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80074f:	eb 4f                	jmp    8007a0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800751:	8d 45 14             	lea    0x14(%ebp),%eax
  800754:	e8 4c fc ff ff       	call   8003a5 <getuint>
			base = 8;
  800759:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80075e:	eb 40                	jmp    8007a0 <vprintfmt+0x37c>
			putch('0', putdat);
  800760:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800764:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80076b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80076e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800772:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800779:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80077c:	8b 45 14             	mov    0x14(%ebp),%eax
  80077f:	8d 50 04             	lea    0x4(%eax),%edx
  800782:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800785:	8b 00                	mov    (%eax),%eax
  800787:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80078c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800791:	eb 0d                	jmp    8007a0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800793:	8d 45 14             	lea    0x14(%ebp),%eax
  800796:	e8 0a fc ff ff       	call   8003a5 <getuint>
			base = 16;
  80079b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8007a0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8007a4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007a8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007ab:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007b3:	89 04 24             	mov    %eax,(%esp)
  8007b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ba:	89 fa                	mov    %edi,%edx
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	e8 ec fa ff ff       	call   8002b0 <printnum>
			break;
  8007c4:	e9 84 fc ff ff       	jmp    80044d <vprintfmt+0x29>
			putch(ch, putdat);
  8007c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007cd:	89 0c 24             	mov    %ecx,(%esp)
  8007d0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007d3:	e9 75 fc ff ff       	jmp    80044d <vprintfmt+0x29>
			putch('%', putdat);
  8007d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007e3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007ea:	0f 84 5b fc ff ff    	je     80044b <vprintfmt+0x27>
  8007f0:	89 f3                	mov    %esi,%ebx
  8007f2:	83 eb 01             	sub    $0x1,%ebx
  8007f5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007f9:	75 f7                	jne    8007f2 <vprintfmt+0x3ce>
  8007fb:	e9 4d fc ff ff       	jmp    80044d <vprintfmt+0x29>
}
  800800:	83 c4 3c             	add    $0x3c,%esp
  800803:	5b                   	pop    %ebx
  800804:	5e                   	pop    %esi
  800805:	5f                   	pop    %edi
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	83 ec 28             	sub    $0x28,%esp
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800814:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800817:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80081e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800825:	85 c0                	test   %eax,%eax
  800827:	74 30                	je     800859 <vsnprintf+0x51>
  800829:	85 d2                	test   %edx,%edx
  80082b:	7e 2c                	jle    800859 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80082d:	8b 45 14             	mov    0x14(%ebp),%eax
  800830:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800834:	8b 45 10             	mov    0x10(%ebp),%eax
  800837:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80083e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800842:	c7 04 24 df 03 80 00 	movl   $0x8003df,(%esp)
  800849:	e8 d6 fb ff ff       	call   800424 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80084e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800851:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800854:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800857:	eb 05                	jmp    80085e <vsnprintf+0x56>
		return -E_INVAL;
  800859:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80085e:	c9                   	leave  
  80085f:	c3                   	ret    

00800860 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800866:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800869:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086d:	8b 45 10             	mov    0x10(%ebp),%eax
  800870:	89 44 24 08          	mov    %eax,0x8(%esp)
  800874:	8b 45 0c             	mov    0xc(%ebp),%eax
  800877:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	89 04 24             	mov    %eax,(%esp)
  800881:	e8 82 ff ff ff       	call   800808 <vsnprintf>
	va_end(ap);

	return rc;
}
  800886:	c9                   	leave  
  800887:	c3                   	ret    
  800888:	66 90                	xchg   %ax,%ax
  80088a:	66 90                	xchg   %ax,%ax
  80088c:	66 90                	xchg   %ax,%ax
  80088e:	66 90                	xchg   %ax,%ax

00800890 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800896:	80 3a 00             	cmpb   $0x0,(%edx)
  800899:	74 10                	je     8008ab <strlen+0x1b>
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008a0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a7:	75 f7                	jne    8008a0 <strlen+0x10>
  8008a9:	eb 05                	jmp    8008b0 <strlen+0x20>
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	53                   	push   %ebx
  8008b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bc:	85 c9                	test   %ecx,%ecx
  8008be:	74 1c                	je     8008dc <strnlen+0x2a>
  8008c0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008c3:	74 1e                	je     8008e3 <strnlen+0x31>
  8008c5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008ca:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cc:	39 ca                	cmp    %ecx,%edx
  8008ce:	74 18                	je     8008e8 <strnlen+0x36>
  8008d0:	83 c2 01             	add    $0x1,%edx
  8008d3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008d8:	75 f0                	jne    8008ca <strnlen+0x18>
  8008da:	eb 0c                	jmp    8008e8 <strnlen+0x36>
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e1:	eb 05                	jmp    8008e8 <strnlen+0x36>
  8008e3:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8008e8:	5b                   	pop    %ebx
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f5:	89 c2                	mov    %eax,%edx
  8008f7:	83 c2 01             	add    $0x1,%edx
  8008fa:	83 c1 01             	add    $0x1,%ecx
  8008fd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800901:	88 5a ff             	mov    %bl,-0x1(%edx)
  800904:	84 db                	test   %bl,%bl
  800906:	75 ef                	jne    8008f7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800908:	5b                   	pop    %ebx
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	53                   	push   %ebx
  80090f:	83 ec 08             	sub    $0x8,%esp
  800912:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800915:	89 1c 24             	mov    %ebx,(%esp)
  800918:	e8 73 ff ff ff       	call   800890 <strlen>
	strcpy(dst + len, src);
  80091d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800920:	89 54 24 04          	mov    %edx,0x4(%esp)
  800924:	01 d8                	add    %ebx,%eax
  800926:	89 04 24             	mov    %eax,(%esp)
  800929:	e8 bd ff ff ff       	call   8008eb <strcpy>
	return dst;
}
  80092e:	89 d8                	mov    %ebx,%eax
  800930:	83 c4 08             	add    $0x8,%esp
  800933:	5b                   	pop    %ebx
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	8b 75 08             	mov    0x8(%ebp),%esi
  80093e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800941:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800944:	85 db                	test   %ebx,%ebx
  800946:	74 17                	je     80095f <strncpy+0x29>
  800948:	01 f3                	add    %esi,%ebx
  80094a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80094c:	83 c1 01             	add    $0x1,%ecx
  80094f:	0f b6 02             	movzbl (%edx),%eax
  800952:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800955:	80 3a 01             	cmpb   $0x1,(%edx)
  800958:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80095b:	39 d9                	cmp    %ebx,%ecx
  80095d:	75 ed                	jne    80094c <strncpy+0x16>
	}
	return ret;
}
  80095f:	89 f0                	mov    %esi,%eax
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	57                   	push   %edi
  800969:	56                   	push   %esi
  80096a:	53                   	push   %ebx
  80096b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800971:	8b 75 10             	mov    0x10(%ebp),%esi
  800974:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800976:	85 f6                	test   %esi,%esi
  800978:	74 34                	je     8009ae <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  80097a:	83 fe 01             	cmp    $0x1,%esi
  80097d:	74 26                	je     8009a5 <strlcpy+0x40>
  80097f:	0f b6 0b             	movzbl (%ebx),%ecx
  800982:	84 c9                	test   %cl,%cl
  800984:	74 23                	je     8009a9 <strlcpy+0x44>
  800986:	83 ee 02             	sub    $0x2,%esi
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  80098e:	83 c0 01             	add    $0x1,%eax
  800991:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800994:	39 f2                	cmp    %esi,%edx
  800996:	74 13                	je     8009ab <strlcpy+0x46>
  800998:	83 c2 01             	add    $0x1,%edx
  80099b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80099f:	84 c9                	test   %cl,%cl
  8009a1:	75 eb                	jne    80098e <strlcpy+0x29>
  8009a3:	eb 06                	jmp    8009ab <strlcpy+0x46>
  8009a5:	89 f8                	mov    %edi,%eax
  8009a7:	eb 02                	jmp    8009ab <strlcpy+0x46>
  8009a9:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  8009ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ae:	29 f8                	sub    %edi,%eax
}
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5f                   	pop    %edi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009be:	0f b6 01             	movzbl (%ecx),%eax
  8009c1:	84 c0                	test   %al,%al
  8009c3:	74 15                	je     8009da <strcmp+0x25>
  8009c5:	3a 02                	cmp    (%edx),%al
  8009c7:	75 11                	jne    8009da <strcmp+0x25>
		p++, q++;
  8009c9:	83 c1 01             	add    $0x1,%ecx
  8009cc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009cf:	0f b6 01             	movzbl (%ecx),%eax
  8009d2:	84 c0                	test   %al,%al
  8009d4:	74 04                	je     8009da <strcmp+0x25>
  8009d6:	3a 02                	cmp    (%edx),%al
  8009d8:	74 ef                	je     8009c9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009da:	0f b6 c0             	movzbl %al,%eax
  8009dd:	0f b6 12             	movzbl (%edx),%edx
  8009e0:	29 d0                	sub    %edx,%eax
}
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ef:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009f2:	85 f6                	test   %esi,%esi
  8009f4:	74 29                	je     800a1f <strncmp+0x3b>
  8009f6:	0f b6 03             	movzbl (%ebx),%eax
  8009f9:	84 c0                	test   %al,%al
  8009fb:	74 30                	je     800a2d <strncmp+0x49>
  8009fd:	3a 02                	cmp    (%edx),%al
  8009ff:	75 2c                	jne    800a2d <strncmp+0x49>
  800a01:	8d 43 01             	lea    0x1(%ebx),%eax
  800a04:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800a06:	89 c3                	mov    %eax,%ebx
  800a08:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a0b:	39 f0                	cmp    %esi,%eax
  800a0d:	74 17                	je     800a26 <strncmp+0x42>
  800a0f:	0f b6 08             	movzbl (%eax),%ecx
  800a12:	84 c9                	test   %cl,%cl
  800a14:	74 17                	je     800a2d <strncmp+0x49>
  800a16:	83 c0 01             	add    $0x1,%eax
  800a19:	3a 0a                	cmp    (%edx),%cl
  800a1b:	74 e9                	je     800a06 <strncmp+0x22>
  800a1d:	eb 0e                	jmp    800a2d <strncmp+0x49>
	if (n == 0)
		return 0;
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a24:	eb 0f                	jmp    800a35 <strncmp+0x51>
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2b:	eb 08                	jmp    800a35 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2d:	0f b6 03             	movzbl (%ebx),%eax
  800a30:	0f b6 12             	movzbl (%edx),%edx
  800a33:	29 d0                	sub    %edx,%eax
}
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	53                   	push   %ebx
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a43:	0f b6 18             	movzbl (%eax),%ebx
  800a46:	84 db                	test   %bl,%bl
  800a48:	74 1d                	je     800a67 <strchr+0x2e>
  800a4a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a4c:	38 d3                	cmp    %dl,%bl
  800a4e:	75 06                	jne    800a56 <strchr+0x1d>
  800a50:	eb 1a                	jmp    800a6c <strchr+0x33>
  800a52:	38 ca                	cmp    %cl,%dl
  800a54:	74 16                	je     800a6c <strchr+0x33>
	for (; *s; s++)
  800a56:	83 c0 01             	add    $0x1,%eax
  800a59:	0f b6 10             	movzbl (%eax),%edx
  800a5c:	84 d2                	test   %dl,%dl
  800a5e:	75 f2                	jne    800a52 <strchr+0x19>
			return (char *) s;
	return 0;
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
  800a65:	eb 05                	jmp    800a6c <strchr+0x33>
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	53                   	push   %ebx
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a79:	0f b6 18             	movzbl (%eax),%ebx
  800a7c:	84 db                	test   %bl,%bl
  800a7e:	74 16                	je     800a96 <strfind+0x27>
  800a80:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a82:	38 d3                	cmp    %dl,%bl
  800a84:	75 06                	jne    800a8c <strfind+0x1d>
  800a86:	eb 0e                	jmp    800a96 <strfind+0x27>
  800a88:	38 ca                	cmp    %cl,%dl
  800a8a:	74 0a                	je     800a96 <strfind+0x27>
	for (; *s; s++)
  800a8c:	83 c0 01             	add    $0x1,%eax
  800a8f:	0f b6 10             	movzbl (%eax),%edx
  800a92:	84 d2                	test   %dl,%dl
  800a94:	75 f2                	jne    800a88 <strfind+0x19>
			break;
	return (char *) s;
}
  800a96:	5b                   	pop    %ebx
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	57                   	push   %edi
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa5:	85 c9                	test   %ecx,%ecx
  800aa7:	74 36                	je     800adf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aa9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aaf:	75 28                	jne    800ad9 <memset+0x40>
  800ab1:	f6 c1 03             	test   $0x3,%cl
  800ab4:	75 23                	jne    800ad9 <memset+0x40>
		c &= 0xFF;
  800ab6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aba:	89 d3                	mov    %edx,%ebx
  800abc:	c1 e3 08             	shl    $0x8,%ebx
  800abf:	89 d6                	mov    %edx,%esi
  800ac1:	c1 e6 18             	shl    $0x18,%esi
  800ac4:	89 d0                	mov    %edx,%eax
  800ac6:	c1 e0 10             	shl    $0x10,%eax
  800ac9:	09 f0                	or     %esi,%eax
  800acb:	09 c2                	or     %eax,%edx
  800acd:	89 d0                	mov    %edx,%eax
  800acf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ad1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ad4:	fc                   	cld    
  800ad5:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad7:	eb 06                	jmp    800adf <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adc:	fc                   	cld    
  800add:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800adf:	89 f8                	mov    %edi,%eax
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af4:	39 c6                	cmp    %eax,%esi
  800af6:	73 35                	jae    800b2d <memmove+0x47>
  800af8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800afb:	39 d0                	cmp    %edx,%eax
  800afd:	73 2e                	jae    800b2d <memmove+0x47>
		s += n;
		d += n;
  800aff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b02:	89 d6                	mov    %edx,%esi
  800b04:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b0c:	75 13                	jne    800b21 <memmove+0x3b>
  800b0e:	f6 c1 03             	test   $0x3,%cl
  800b11:	75 0e                	jne    800b21 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b13:	83 ef 04             	sub    $0x4,%edi
  800b16:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b19:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b1c:	fd                   	std    
  800b1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1f:	eb 09                	jmp    800b2a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b21:	83 ef 01             	sub    $0x1,%edi
  800b24:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b27:	fd                   	std    
  800b28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b2a:	fc                   	cld    
  800b2b:	eb 1d                	jmp    800b4a <memmove+0x64>
  800b2d:	89 f2                	mov    %esi,%edx
  800b2f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b31:	f6 c2 03             	test   $0x3,%dl
  800b34:	75 0f                	jne    800b45 <memmove+0x5f>
  800b36:	f6 c1 03             	test   $0x3,%cl
  800b39:	75 0a                	jne    800b45 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b3b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b3e:	89 c7                	mov    %eax,%edi
  800b40:	fc                   	cld    
  800b41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b43:	eb 05                	jmp    800b4a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800b45:	89 c7                	mov    %eax,%edi
  800b47:	fc                   	cld    
  800b48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b54:	8b 45 10             	mov    0x10(%ebp),%eax
  800b57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b62:	8b 45 08             	mov    0x8(%ebp),%eax
  800b65:	89 04 24             	mov    %eax,(%esp)
  800b68:	e8 79 ff ff ff       	call   800ae6 <memmove>
}
  800b6d:	c9                   	leave  
  800b6e:	c3                   	ret    

00800b6f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	57                   	push   %edi
  800b73:	56                   	push   %esi
  800b74:	53                   	push   %ebx
  800b75:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b81:	85 c0                	test   %eax,%eax
  800b83:	74 36                	je     800bbb <memcmp+0x4c>
		if (*s1 != *s2)
  800b85:	0f b6 03             	movzbl (%ebx),%eax
  800b88:	0f b6 0e             	movzbl (%esi),%ecx
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b90:	38 c8                	cmp    %cl,%al
  800b92:	74 1c                	je     800bb0 <memcmp+0x41>
  800b94:	eb 10                	jmp    800ba6 <memcmp+0x37>
  800b96:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b9b:	83 c2 01             	add    $0x1,%edx
  800b9e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ba2:	38 c8                	cmp    %cl,%al
  800ba4:	74 0a                	je     800bb0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ba6:	0f b6 c0             	movzbl %al,%eax
  800ba9:	0f b6 c9             	movzbl %cl,%ecx
  800bac:	29 c8                	sub    %ecx,%eax
  800bae:	eb 10                	jmp    800bc0 <memcmp+0x51>
	while (n-- > 0) {
  800bb0:	39 fa                	cmp    %edi,%edx
  800bb2:	75 e2                	jne    800b96 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800bb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb9:	eb 05                	jmp    800bc0 <memcmp+0x51>
  800bbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	53                   	push   %ebx
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800bcf:	89 c2                	mov    %eax,%edx
  800bd1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bd4:	39 d0                	cmp    %edx,%eax
  800bd6:	73 13                	jae    800beb <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd8:	89 d9                	mov    %ebx,%ecx
  800bda:	38 18                	cmp    %bl,(%eax)
  800bdc:	75 06                	jne    800be4 <memfind+0x1f>
  800bde:	eb 0b                	jmp    800beb <memfind+0x26>
  800be0:	38 08                	cmp    %cl,(%eax)
  800be2:	74 07                	je     800beb <memfind+0x26>
	for (; s < ends; s++)
  800be4:	83 c0 01             	add    $0x1,%eax
  800be7:	39 d0                	cmp    %edx,%eax
  800be9:	75 f5                	jne    800be0 <memfind+0x1b>
			break;
	return (void *) s;
}
  800beb:	5b                   	pop    %ebx
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfa:	0f b6 0a             	movzbl (%edx),%ecx
  800bfd:	80 f9 09             	cmp    $0x9,%cl
  800c00:	74 05                	je     800c07 <strtol+0x19>
  800c02:	80 f9 20             	cmp    $0x20,%cl
  800c05:	75 10                	jne    800c17 <strtol+0x29>
		s++;
  800c07:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c0a:	0f b6 0a             	movzbl (%edx),%ecx
  800c0d:	80 f9 09             	cmp    $0x9,%cl
  800c10:	74 f5                	je     800c07 <strtol+0x19>
  800c12:	80 f9 20             	cmp    $0x20,%cl
  800c15:	74 f0                	je     800c07 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800c17:	80 f9 2b             	cmp    $0x2b,%cl
  800c1a:	75 0a                	jne    800c26 <strtol+0x38>
		s++;
  800c1c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c1f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c24:	eb 11                	jmp    800c37 <strtol+0x49>
  800c26:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800c2b:	80 f9 2d             	cmp    $0x2d,%cl
  800c2e:	75 07                	jne    800c37 <strtol+0x49>
		s++, neg = 1;
  800c30:	83 c2 01             	add    $0x1,%edx
  800c33:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c37:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c3c:	75 15                	jne    800c53 <strtol+0x65>
  800c3e:	80 3a 30             	cmpb   $0x30,(%edx)
  800c41:	75 10                	jne    800c53 <strtol+0x65>
  800c43:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c47:	75 0a                	jne    800c53 <strtol+0x65>
		s += 2, base = 16;
  800c49:	83 c2 02             	add    $0x2,%edx
  800c4c:	b8 10 00 00 00       	mov    $0x10,%eax
  800c51:	eb 10                	jmp    800c63 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800c53:	85 c0                	test   %eax,%eax
  800c55:	75 0c                	jne    800c63 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c57:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800c59:	80 3a 30             	cmpb   $0x30,(%edx)
  800c5c:	75 05                	jne    800c63 <strtol+0x75>
		s++, base = 8;
  800c5e:	83 c2 01             	add    $0x1,%edx
  800c61:	b0 08                	mov    $0x8,%al
		base = 10;
  800c63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c68:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c6b:	0f b6 0a             	movzbl (%edx),%ecx
  800c6e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c71:	89 f0                	mov    %esi,%eax
  800c73:	3c 09                	cmp    $0x9,%al
  800c75:	77 08                	ja     800c7f <strtol+0x91>
			dig = *s - '0';
  800c77:	0f be c9             	movsbl %cl,%ecx
  800c7a:	83 e9 30             	sub    $0x30,%ecx
  800c7d:	eb 20                	jmp    800c9f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800c7f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c82:	89 f0                	mov    %esi,%eax
  800c84:	3c 19                	cmp    $0x19,%al
  800c86:	77 08                	ja     800c90 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c88:	0f be c9             	movsbl %cl,%ecx
  800c8b:	83 e9 57             	sub    $0x57,%ecx
  800c8e:	eb 0f                	jmp    800c9f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800c90:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c93:	89 f0                	mov    %esi,%eax
  800c95:	3c 19                	cmp    $0x19,%al
  800c97:	77 16                	ja     800caf <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c99:	0f be c9             	movsbl %cl,%ecx
  800c9c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c9f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800ca2:	7d 0f                	jge    800cb3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ca4:	83 c2 01             	add    $0x1,%edx
  800ca7:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800cab:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800cad:	eb bc                	jmp    800c6b <strtol+0x7d>
  800caf:	89 d8                	mov    %ebx,%eax
  800cb1:	eb 02                	jmp    800cb5 <strtol+0xc7>
  800cb3:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800cb5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb9:	74 05                	je     800cc0 <strtol+0xd2>
		*endptr = (char *) s;
  800cbb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbe:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800cc0:	f7 d8                	neg    %eax
  800cc2:	85 ff                	test   %edi,%edi
  800cc4:	0f 44 c3             	cmove  %ebx,%eax
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 c3                	mov    %eax,%ebx
  800cdf:	89 c7                	mov    %eax,%edi
  800ce1:	89 c6                	mov    %eax,%esi
  800ce3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_cgetc>:

int
sys_cgetc(void)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfa:	89 d1                	mov    %edx,%ecx
  800cfc:	89 d3                	mov    %edx,%ebx
  800cfe:	89 d7                	mov    %edx,%edi
  800d00:	89 d6                	mov    %edx,%esi
  800d02:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d17:	b8 03 00 00 00       	mov    $0x3,%eax
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	89 cb                	mov    %ecx,%ebx
  800d21:	89 cf                	mov    %ecx,%edi
  800d23:	89 ce                	mov    %ecx,%esi
  800d25:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7e 28                	jle    800d53 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d36:	00 
  800d37:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800d3e:	00 
  800d3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d46:	00 
  800d47:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800d4e:	e8 3c f4 ff ff       	call   80018f <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d53:	83 c4 2c             	add    $0x2c,%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d61:	ba 00 00 00 00       	mov    $0x0,%edx
  800d66:	b8 02 00 00 00       	mov    $0x2,%eax
  800d6b:	89 d1                	mov    %edx,%ecx
  800d6d:	89 d3                	mov    %edx,%ebx
  800d6f:	89 d7                	mov    %edx,%edi
  800d71:	89 d6                	mov    %edx,%esi
  800d73:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <sys_yield>:

void
sys_yield(void)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	57                   	push   %edi
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d80:	ba 00 00 00 00       	mov    $0x0,%edx
  800d85:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d8a:	89 d1                	mov    %edx,%ecx
  800d8c:	89 d3                	mov    %edx,%ebx
  800d8e:	89 d7                	mov    %edx,%edi
  800d90:	89 d6                	mov    %edx,%esi
  800d92:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    

00800d99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	57                   	push   %edi
  800d9d:	56                   	push   %esi
  800d9e:	53                   	push   %ebx
  800d9f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800da2:	be 00 00 00 00       	mov    $0x0,%esi
  800da7:	b8 04 00 00 00       	mov    $0x4,%eax
  800dac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daf:	8b 55 08             	mov    0x8(%ebp),%edx
  800db2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db5:	89 f7                	mov    %esi,%edi
  800db7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	7e 28                	jle    800de5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800dc8:	00 
  800dc9:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd8:	00 
  800dd9:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800de0:	e8 aa f3 ff ff       	call   80018f <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800de5:	83 c4 2c             	add    $0x2c,%esp
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800df6:	b8 05 00 00 00       	mov    $0x5,%eax
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e07:	8b 75 18             	mov    0x18(%ebp),%esi
  800e0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	7e 28                	jle    800e38 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e14:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e1b:	00 
  800e1c:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800e23:	00 
  800e24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2b:	00 
  800e2c:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800e33:	e8 57 f3 ff ff       	call   80018f <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e38:	83 c4 2c             	add    $0x2c,%esp
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5f                   	pop    %edi
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
  800e46:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	89 df                	mov    %ebx,%edi
  800e5b:	89 de                	mov    %ebx,%esi
  800e5d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	7e 28                	jle    800e8b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e67:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e6e:	00 
  800e6f:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800e76:	00 
  800e77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7e:	00 
  800e7f:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800e86:	e8 04 f3 ff ff       	call   80018f <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e8b:	83 c4 2c             	add    $0x2c,%esp
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	57                   	push   %edi
  800e97:	56                   	push   %esi
  800e98:	53                   	push   %ebx
  800e99:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eac:	89 df                	mov    %ebx,%edi
  800eae:	89 de                	mov    %ebx,%esi
  800eb0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	7e 28                	jle    800ede <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eba:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ec1:	00 
  800ec2:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800ec9:	00 
  800eca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed1:	00 
  800ed2:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800ed9:	e8 b1 f2 ff ff       	call   80018f <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ede:	83 c4 2c             	add    $0x2c,%esp
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	57                   	push   %edi
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
  800eec:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800eef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ef9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efc:	8b 55 08             	mov    0x8(%ebp),%edx
  800eff:	89 df                	mov    %ebx,%edi
  800f01:	89 de                	mov    %ebx,%esi
  800f03:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f05:	85 c0                	test   %eax,%eax
  800f07:	7e 28                	jle    800f31 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f09:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f14:	00 
  800f15:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800f1c:	00 
  800f1d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f24:	00 
  800f25:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800f2c:	e8 5e f2 ff ff       	call   80018f <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f31:	83 c4 2c             	add    $0x2c,%esp
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	57                   	push   %edi
  800f3d:	56                   	push   %esi
  800f3e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f3f:	be 00 00 00 00       	mov    $0x0,%esi
  800f44:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f55:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f57:	5b                   	pop    %ebx
  800f58:	5e                   	pop    %esi
  800f59:	5f                   	pop    %edi
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    

00800f5c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	57                   	push   %edi
  800f60:	56                   	push   %esi
  800f61:	53                   	push   %ebx
  800f62:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f6a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f72:	89 cb                	mov    %ecx,%ebx
  800f74:	89 cf                	mov    %ecx,%edi
  800f76:	89 ce                	mov    %ecx,%esi
  800f78:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	7e 28                	jle    800fa6 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f82:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f89:	00 
  800f8a:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800f91:	00 
  800f92:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f99:	00 
  800f9a:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800fa1:	e8 e9 f1 ff ff       	call   80018f <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fa6:	83 c4 2c             	add    $0x2c,%esp
  800fa9:	5b                   	pop    %ebx
  800faa:	5e                   	pop    %esi
  800fab:	5f                   	pop    %edi
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    
  800fae:	66 90                	xchg   %ax,%ax

00800fb0 <__udivdi3>:
  800fb0:	55                   	push   %ebp
  800fb1:	57                   	push   %edi
  800fb2:	56                   	push   %esi
  800fb3:	83 ec 0c             	sub    $0xc,%esp
  800fb6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800fba:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800fbe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800fc2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fcc:	89 ea                	mov    %ebp,%edx
  800fce:	89 0c 24             	mov    %ecx,(%esp)
  800fd1:	75 2d                	jne    801000 <__udivdi3+0x50>
  800fd3:	39 e9                	cmp    %ebp,%ecx
  800fd5:	77 61                	ja     801038 <__udivdi3+0x88>
  800fd7:	85 c9                	test   %ecx,%ecx
  800fd9:	89 ce                	mov    %ecx,%esi
  800fdb:	75 0b                	jne    800fe8 <__udivdi3+0x38>
  800fdd:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe2:	31 d2                	xor    %edx,%edx
  800fe4:	f7 f1                	div    %ecx
  800fe6:	89 c6                	mov    %eax,%esi
  800fe8:	31 d2                	xor    %edx,%edx
  800fea:	89 e8                	mov    %ebp,%eax
  800fec:	f7 f6                	div    %esi
  800fee:	89 c5                	mov    %eax,%ebp
  800ff0:	89 f8                	mov    %edi,%eax
  800ff2:	f7 f6                	div    %esi
  800ff4:	89 ea                	mov    %ebp,%edx
  800ff6:	83 c4 0c             	add    $0xc,%esp
  800ff9:	5e                   	pop    %esi
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    
  800ffd:	8d 76 00             	lea    0x0(%esi),%esi
  801000:	39 e8                	cmp    %ebp,%eax
  801002:	77 24                	ja     801028 <__udivdi3+0x78>
  801004:	0f bd e8             	bsr    %eax,%ebp
  801007:	83 f5 1f             	xor    $0x1f,%ebp
  80100a:	75 3c                	jne    801048 <__udivdi3+0x98>
  80100c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801010:	39 34 24             	cmp    %esi,(%esp)
  801013:	0f 86 9f 00 00 00    	jbe    8010b8 <__udivdi3+0x108>
  801019:	39 d0                	cmp    %edx,%eax
  80101b:	0f 82 97 00 00 00    	jb     8010b8 <__udivdi3+0x108>
  801021:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801028:	31 d2                	xor    %edx,%edx
  80102a:	31 c0                	xor    %eax,%eax
  80102c:	83 c4 0c             	add    $0xc,%esp
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    
  801033:	90                   	nop
  801034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801038:	89 f8                	mov    %edi,%eax
  80103a:	f7 f1                	div    %ecx
  80103c:	31 d2                	xor    %edx,%edx
  80103e:	83 c4 0c             	add    $0xc,%esp
  801041:	5e                   	pop    %esi
  801042:	5f                   	pop    %edi
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    
  801045:	8d 76 00             	lea    0x0(%esi),%esi
  801048:	89 e9                	mov    %ebp,%ecx
  80104a:	8b 3c 24             	mov    (%esp),%edi
  80104d:	d3 e0                	shl    %cl,%eax
  80104f:	89 c6                	mov    %eax,%esi
  801051:	b8 20 00 00 00       	mov    $0x20,%eax
  801056:	29 e8                	sub    %ebp,%eax
  801058:	89 c1                	mov    %eax,%ecx
  80105a:	d3 ef                	shr    %cl,%edi
  80105c:	89 e9                	mov    %ebp,%ecx
  80105e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801062:	8b 3c 24             	mov    (%esp),%edi
  801065:	09 74 24 08          	or     %esi,0x8(%esp)
  801069:	89 d6                	mov    %edx,%esi
  80106b:	d3 e7                	shl    %cl,%edi
  80106d:	89 c1                	mov    %eax,%ecx
  80106f:	89 3c 24             	mov    %edi,(%esp)
  801072:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801076:	d3 ee                	shr    %cl,%esi
  801078:	89 e9                	mov    %ebp,%ecx
  80107a:	d3 e2                	shl    %cl,%edx
  80107c:	89 c1                	mov    %eax,%ecx
  80107e:	d3 ef                	shr    %cl,%edi
  801080:	09 d7                	or     %edx,%edi
  801082:	89 f2                	mov    %esi,%edx
  801084:	89 f8                	mov    %edi,%eax
  801086:	f7 74 24 08          	divl   0x8(%esp)
  80108a:	89 d6                	mov    %edx,%esi
  80108c:	89 c7                	mov    %eax,%edi
  80108e:	f7 24 24             	mull   (%esp)
  801091:	39 d6                	cmp    %edx,%esi
  801093:	89 14 24             	mov    %edx,(%esp)
  801096:	72 30                	jb     8010c8 <__udivdi3+0x118>
  801098:	8b 54 24 04          	mov    0x4(%esp),%edx
  80109c:	89 e9                	mov    %ebp,%ecx
  80109e:	d3 e2                	shl    %cl,%edx
  8010a0:	39 c2                	cmp    %eax,%edx
  8010a2:	73 05                	jae    8010a9 <__udivdi3+0xf9>
  8010a4:	3b 34 24             	cmp    (%esp),%esi
  8010a7:	74 1f                	je     8010c8 <__udivdi3+0x118>
  8010a9:	89 f8                	mov    %edi,%eax
  8010ab:	31 d2                	xor    %edx,%edx
  8010ad:	e9 7a ff ff ff       	jmp    80102c <__udivdi3+0x7c>
  8010b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010b8:	31 d2                	xor    %edx,%edx
  8010ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8010bf:	e9 68 ff ff ff       	jmp    80102c <__udivdi3+0x7c>
  8010c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8010cb:	31 d2                	xor    %edx,%edx
  8010cd:	83 c4 0c             	add    $0xc,%esp
  8010d0:	5e                   	pop    %esi
  8010d1:	5f                   	pop    %edi
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    
  8010d4:	66 90                	xchg   %ax,%ax
  8010d6:	66 90                	xchg   %ax,%ax
  8010d8:	66 90                	xchg   %ax,%ax
  8010da:	66 90                	xchg   %ax,%ax
  8010dc:	66 90                	xchg   %ax,%ax
  8010de:	66 90                	xchg   %ax,%ax

008010e0 <__umoddi3>:
  8010e0:	55                   	push   %ebp
  8010e1:	57                   	push   %edi
  8010e2:	56                   	push   %esi
  8010e3:	83 ec 14             	sub    $0x14,%esp
  8010e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8010ea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8010ee:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8010f2:	89 c7                	mov    %eax,%edi
  8010f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8010fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801100:	89 34 24             	mov    %esi,(%esp)
  801103:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801107:	85 c0                	test   %eax,%eax
  801109:	89 c2                	mov    %eax,%edx
  80110b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80110f:	75 17                	jne    801128 <__umoddi3+0x48>
  801111:	39 fe                	cmp    %edi,%esi
  801113:	76 4b                	jbe    801160 <__umoddi3+0x80>
  801115:	89 c8                	mov    %ecx,%eax
  801117:	89 fa                	mov    %edi,%edx
  801119:	f7 f6                	div    %esi
  80111b:	89 d0                	mov    %edx,%eax
  80111d:	31 d2                	xor    %edx,%edx
  80111f:	83 c4 14             	add    $0x14,%esp
  801122:	5e                   	pop    %esi
  801123:	5f                   	pop    %edi
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    
  801126:	66 90                	xchg   %ax,%ax
  801128:	39 f8                	cmp    %edi,%eax
  80112a:	77 54                	ja     801180 <__umoddi3+0xa0>
  80112c:	0f bd e8             	bsr    %eax,%ebp
  80112f:	83 f5 1f             	xor    $0x1f,%ebp
  801132:	75 5c                	jne    801190 <__umoddi3+0xb0>
  801134:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801138:	39 3c 24             	cmp    %edi,(%esp)
  80113b:	0f 87 e7 00 00 00    	ja     801228 <__umoddi3+0x148>
  801141:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801145:	29 f1                	sub    %esi,%ecx
  801147:	19 c7                	sbb    %eax,%edi
  801149:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80114d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801151:	8b 44 24 08          	mov    0x8(%esp),%eax
  801155:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801159:	83 c4 14             	add    $0x14,%esp
  80115c:	5e                   	pop    %esi
  80115d:	5f                   	pop    %edi
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    
  801160:	85 f6                	test   %esi,%esi
  801162:	89 f5                	mov    %esi,%ebp
  801164:	75 0b                	jne    801171 <__umoddi3+0x91>
  801166:	b8 01 00 00 00       	mov    $0x1,%eax
  80116b:	31 d2                	xor    %edx,%edx
  80116d:	f7 f6                	div    %esi
  80116f:	89 c5                	mov    %eax,%ebp
  801171:	8b 44 24 04          	mov    0x4(%esp),%eax
  801175:	31 d2                	xor    %edx,%edx
  801177:	f7 f5                	div    %ebp
  801179:	89 c8                	mov    %ecx,%eax
  80117b:	f7 f5                	div    %ebp
  80117d:	eb 9c                	jmp    80111b <__umoddi3+0x3b>
  80117f:	90                   	nop
  801180:	89 c8                	mov    %ecx,%eax
  801182:	89 fa                	mov    %edi,%edx
  801184:	83 c4 14             	add    $0x14,%esp
  801187:	5e                   	pop    %esi
  801188:	5f                   	pop    %edi
  801189:	5d                   	pop    %ebp
  80118a:	c3                   	ret    
  80118b:	90                   	nop
  80118c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801190:	8b 04 24             	mov    (%esp),%eax
  801193:	be 20 00 00 00       	mov    $0x20,%esi
  801198:	89 e9                	mov    %ebp,%ecx
  80119a:	29 ee                	sub    %ebp,%esi
  80119c:	d3 e2                	shl    %cl,%edx
  80119e:	89 f1                	mov    %esi,%ecx
  8011a0:	d3 e8                	shr    %cl,%eax
  8011a2:	89 e9                	mov    %ebp,%ecx
  8011a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a8:	8b 04 24             	mov    (%esp),%eax
  8011ab:	09 54 24 04          	or     %edx,0x4(%esp)
  8011af:	89 fa                	mov    %edi,%edx
  8011b1:	d3 e0                	shl    %cl,%eax
  8011b3:	89 f1                	mov    %esi,%ecx
  8011b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8011bd:	d3 ea                	shr    %cl,%edx
  8011bf:	89 e9                	mov    %ebp,%ecx
  8011c1:	d3 e7                	shl    %cl,%edi
  8011c3:	89 f1                	mov    %esi,%ecx
  8011c5:	d3 e8                	shr    %cl,%eax
  8011c7:	89 e9                	mov    %ebp,%ecx
  8011c9:	09 f8                	or     %edi,%eax
  8011cb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8011cf:	f7 74 24 04          	divl   0x4(%esp)
  8011d3:	d3 e7                	shl    %cl,%edi
  8011d5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011d9:	89 d7                	mov    %edx,%edi
  8011db:	f7 64 24 08          	mull   0x8(%esp)
  8011df:	39 d7                	cmp    %edx,%edi
  8011e1:	89 c1                	mov    %eax,%ecx
  8011e3:	89 14 24             	mov    %edx,(%esp)
  8011e6:	72 2c                	jb     801214 <__umoddi3+0x134>
  8011e8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8011ec:	72 22                	jb     801210 <__umoddi3+0x130>
  8011ee:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8011f2:	29 c8                	sub    %ecx,%eax
  8011f4:	19 d7                	sbb    %edx,%edi
  8011f6:	89 e9                	mov    %ebp,%ecx
  8011f8:	89 fa                	mov    %edi,%edx
  8011fa:	d3 e8                	shr    %cl,%eax
  8011fc:	89 f1                	mov    %esi,%ecx
  8011fe:	d3 e2                	shl    %cl,%edx
  801200:	89 e9                	mov    %ebp,%ecx
  801202:	d3 ef                	shr    %cl,%edi
  801204:	09 d0                	or     %edx,%eax
  801206:	89 fa                	mov    %edi,%edx
  801208:	83 c4 14             	add    $0x14,%esp
  80120b:	5e                   	pop    %esi
  80120c:	5f                   	pop    %edi
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    
  80120f:	90                   	nop
  801210:	39 d7                	cmp    %edx,%edi
  801212:	75 da                	jne    8011ee <__umoddi3+0x10e>
  801214:	8b 14 24             	mov    (%esp),%edx
  801217:	89 c1                	mov    %eax,%ecx
  801219:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80121d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801221:	eb cb                	jmp    8011ee <__umoddi3+0x10e>
  801223:	90                   	nop
  801224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801228:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80122c:	0f 82 0f ff ff ff    	jb     801141 <__umoddi3+0x61>
  801232:	e9 1a ff ff ff       	jmp    801151 <__umoddi3+0x71>
