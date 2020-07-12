
obj/user/testbss.debug：     文件格式 elf32-i386


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
  800046:	c7 04 24 80 21 80 00 	movl   $0x802180,(%esp)
  80004d:	e8 3b 02 00 00       	call   80028d <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800052:	83 3d 20 40 80 00 00 	cmpl   $0x0,0x804020
  800059:	75 11                	jne    80006c <umain+0x2c>
	for (i = 0; i < ARRAYSIZE; i++)
  80005b:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != 0)
  800060:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800067:	00 
  800068:	74 27                	je     800091 <umain+0x51>
  80006a:	eb 05                	jmp    800071 <umain+0x31>
	for (i = 0; i < ARRAYSIZE; i++)
  80006c:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] isn't cleared!\n", i);
  800071:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800075:	c7 44 24 08 fb 21 80 	movl   $0x8021fb,0x8(%esp)
  80007c:	00 
  80007d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800084:	00 
  800085:	c7 04 24 18 22 80 00 	movl   $0x802218,(%esp)
  80008c:	e8 03 01 00 00       	call   800194 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
  800091:	83 c0 01             	add    $0x1,%eax
  800094:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800099:	75 c5                	jne    800060 <umain+0x20>
  80009b:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  8000a0:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 ef                	jne    8000a0 <umain+0x60>
  8000b1:	eb 70                	jmp    800123 <umain+0xe3>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000b3:	3b 04 85 20 40 80 00 	cmp    0x804020(,%eax,4),%eax
  8000ba:	74 2b                	je     8000e7 <umain+0xa7>
  8000bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8000c0:	eb 05                	jmp    8000c7 <umain+0x87>
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000cb:	c7 44 24 08 a0 21 80 	movl   $0x8021a0,0x8(%esp)
  8000d2:	00 
  8000d3:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000da:	00 
  8000db:	c7 04 24 18 22 80 00 	movl   $0x802218,(%esp)
  8000e2:	e8 ad 00 00 00       	call   800194 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
  8000e7:	83 c0 01             	add    $0x1,%eax
  8000ea:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000ef:	75 c2                	jne    8000b3 <umain+0x73>

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000f1:	c7 04 24 c8 21 80 00 	movl   $0x8021c8,(%esp)
  8000f8:	e8 90 01 00 00       	call   80028d <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000fd:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  800104:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800107:	c7 44 24 08 27 22 80 	movl   $0x802227,0x8(%esp)
  80010e:	00 
  80010f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800116:	00 
  800117:	c7 04 24 18 22 80 00 	movl   $0x802218,(%esp)
  80011e:	e8 71 00 00 00       	call   800194 <_panic>
		if (bigarray[i] != i)
  800123:	83 3d 20 40 80 00 00 	cmpl   $0x0,0x804020
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
  800153:	a3 20 40 c0 00       	mov    %eax,0xc04020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800158:	85 db                	test   %ebx,%ebx
  80015a:	7e 07                	jle    800163 <libmain+0x30>
		binaryname = argv[0];
  80015c:	8b 06                	mov    (%esi),%eax
  80015e:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  800181:	e8 a0 10 00 00       	call   801226 <close_all>
	sys_env_destroy(0);
  800186:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80018d:	e8 77 0b 00 00       	call   800d09 <sys_env_destroy>
}
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
  800199:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80019c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a5:	e8 b1 0b 00 00       	call   800d5b <sys_getenvid>
  8001aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b8:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c0:	c7 04 24 48 22 80 00 	movl   $0x802248,(%esp)
  8001c7:	e8 c1 00 00 00       	call   80028d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	e8 51 00 00 00       	call   80022c <vcprintf>
	cprintf("\n");
  8001db:	c7 04 24 16 22 80 00 	movl   $0x802216,(%esp)
  8001e2:	e8 a6 00 00 00       	call   80028d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e7:	cc                   	int3   
  8001e8:	eb fd                	jmp    8001e7 <_panic+0x53>

008001ea <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 14             	sub    $0x14,%esp
  8001f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f4:	8b 13                	mov    (%ebx),%edx
  8001f6:	8d 42 01             	lea    0x1(%edx),%eax
  8001f9:	89 03                	mov    %eax,(%ebx)
  8001fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001fe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800202:	3d ff 00 00 00       	cmp    $0xff,%eax
  800207:	75 19                	jne    800222 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800209:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800210:	00 
  800211:	8d 43 08             	lea    0x8(%ebx),%eax
  800214:	89 04 24             	mov    %eax,(%esp)
  800217:	e8 b0 0a 00 00       	call   800ccc <sys_cputs>
		b->idx = 0;
  80021c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800222:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800226:	83 c4 14             	add    $0x14,%esp
  800229:	5b                   	pop    %ebx
  80022a:	5d                   	pop    %ebp
  80022b:	c3                   	ret    

0080022c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800235:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023c:	00 00 00 
	b.cnt = 0;
  80023f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800246:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800249:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800250:	8b 45 08             	mov    0x8(%ebp),%eax
  800253:	89 44 24 08          	mov    %eax,0x8(%esp)
  800257:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800261:	c7 04 24 ea 01 80 00 	movl   $0x8001ea,(%esp)
  800268:	e8 b7 01 00 00       	call   800424 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800273:	89 44 24 04          	mov    %eax,0x4(%esp)
  800277:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027d:	89 04 24             	mov    %eax,(%esp)
  800280:	e8 47 0a 00 00       	call   800ccc <sys_cputs>

	return b.cnt;
}
  800285:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    

0080028d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800293:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800296:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029a:	8b 45 08             	mov    0x8(%ebp),%eax
  80029d:	89 04 24             	mov    %eax,(%esp)
  8002a0:	e8 87 ff ff ff       	call   80022c <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    
  8002a7:	66 90                	xchg   %ax,%ax
  8002a9:	66 90                	xchg   %ax,%ax
  8002ab:	66 90                	xchg   %ax,%ax
  8002ad:	66 90                	xchg   %ax,%ax
  8002af:	90                   	nop

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
  80032c:	e8 af 1b 00 00       	call   801ee0 <__udivdi3>
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
  800385:	e8 86 1c 00 00       	call   802010 <__umoddi3>
  80038a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80038e:	0f be 80 6b 22 80 00 	movsbl 0x80226b(%eax),%eax
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
  8004ac:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
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
  80055a:	83 f8 0f             	cmp    $0xf,%eax
  80055d:	7f 0b                	jg     80056a <vprintfmt+0x146>
  80055f:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 20                	jne    80058a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80056a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056e:	c7 44 24 08 83 22 80 	movl   $0x802283,0x8(%esp)
  800575:	00 
  800576:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057a:	8b 45 08             	mov    0x8(%ebp),%eax
  80057d:	89 04 24             	mov    %eax,(%esp)
  800580:	e8 77 fe ff ff       	call   8003fc <printfmt>
  800585:	e9 c3 fe ff ff       	jmp    80044d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80058a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80058e:	c7 44 24 08 22 26 80 	movl   $0x802622,0x8(%esp)
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
  8005bd:	ba 7c 22 80 00       	mov    $0x80227c,%edx
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
  800d37:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800d3e:	00 
  800d3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d46:	00 
  800d47:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800d4e:	e8 41 f4 ff ff       	call   800194 <_panic>
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
  800d85:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800dc9:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd8:	00 
  800dd9:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800de0:	e8 af f3 ff ff       	call   800194 <_panic>
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
  800e1c:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800e23:	00 
  800e24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2b:	00 
  800e2c:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800e33:	e8 5c f3 ff ff       	call   800194 <_panic>
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
  800e6f:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800e76:	00 
  800e77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7e:	00 
  800e7f:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800e86:	e8 09 f3 ff ff       	call   800194 <_panic>
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
  800ec2:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800ec9:	00 
  800eca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed1:	00 
  800ed2:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800ed9:	e8 b6 f2 ff ff       	call   800194 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ede:	83 c4 2c             	add    $0x2c,%esp
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800f07:	7e 28                	jle    800f31 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f09:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f14:	00 
  800f15:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800f1c:	00 
  800f1d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f24:	00 
  800f25:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800f2c:	e8 63 f2 ff ff       	call   800194 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f31:	83 c4 2c             	add    $0x2c,%esp
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	57                   	push   %edi
  800f3d:	56                   	push   %esi
  800f3e:	53                   	push   %ebx
  800f3f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f47:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f52:	89 df                	mov    %ebx,%edi
  800f54:	89 de                	mov    %ebx,%esi
  800f56:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	7e 28                	jle    800f84 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f60:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f67:	00 
  800f68:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800f6f:	00 
  800f70:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f77:	00 
  800f78:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800f7f:	e8 10 f2 ff ff       	call   800194 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f84:	83 c4 2c             	add    $0x2c,%esp
  800f87:	5b                   	pop    %ebx
  800f88:	5e                   	pop    %esi
  800f89:	5f                   	pop    %edi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    

00800f8c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	57                   	push   %edi
  800f90:	56                   	push   %esi
  800f91:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f92:	be 00 00 00 00       	mov    $0x0,%esi
  800f97:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800faa:	5b                   	pop    %ebx
  800fab:	5e                   	pop    %esi
  800fac:	5f                   	pop    %edi
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    

00800faf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	57                   	push   %edi
  800fb3:	56                   	push   %esi
  800fb4:	53                   	push   %ebx
  800fb5:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800fb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fbd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc5:	89 cb                	mov    %ecx,%ebx
  800fc7:	89 cf                	mov    %ecx,%edi
  800fc9:	89 ce                	mov    %ecx,%esi
  800fcb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	7e 28                	jle    800ff9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fdc:	00 
  800fdd:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800fe4:	00 
  800fe5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fec:	00 
  800fed:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800ff4:	e8 9b f1 ff ff       	call   800194 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ff9:	83 c4 2c             	add    $0x2c,%esp
  800ffc:	5b                   	pop    %ebx
  800ffd:	5e                   	pop    %esi
  800ffe:	5f                   	pop    %edi
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    
  801001:	66 90                	xchg   %ax,%ax
  801003:	66 90                	xchg   %ax,%ax
  801005:	66 90                	xchg   %ax,%ax
  801007:	66 90                	xchg   %ax,%ax
  801009:	66 90                	xchg   %ax,%ax
  80100b:	66 90                	xchg   %ax,%ax
  80100d:	66 90                	xchg   %ax,%ax
  80100f:	90                   	nop

00801010 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801013:	8b 45 08             	mov    0x8(%ebp),%eax
  801016:	05 00 00 00 30       	add    $0x30000000,%eax
  80101b:	c1 e8 0c             	shr    $0xc,%eax
}
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    

00801020 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801023:	8b 45 08             	mov    0x8(%ebp),%eax
  801026:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80102b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801030:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    

00801037 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80103a:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80103f:	a8 01                	test   $0x1,%al
  801041:	74 34                	je     801077 <fd_alloc+0x40>
  801043:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801048:	a8 01                	test   $0x1,%al
  80104a:	74 32                	je     80107e <fd_alloc+0x47>
  80104c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  801051:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801053:	89 c2                	mov    %eax,%edx
  801055:	c1 ea 16             	shr    $0x16,%edx
  801058:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80105f:	f6 c2 01             	test   $0x1,%dl
  801062:	74 1f                	je     801083 <fd_alloc+0x4c>
  801064:	89 c2                	mov    %eax,%edx
  801066:	c1 ea 0c             	shr    $0xc,%edx
  801069:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801070:	f6 c2 01             	test   $0x1,%dl
  801073:	75 1a                	jne    80108f <fd_alloc+0x58>
  801075:	eb 0c                	jmp    801083 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  801077:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80107c:	eb 05                	jmp    801083 <fd_alloc+0x4c>
  80107e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  801083:	8b 45 08             	mov    0x8(%ebp),%eax
  801086:	89 08                	mov    %ecx,(%eax)
			return 0;
  801088:	b8 00 00 00 00       	mov    $0x0,%eax
  80108d:	eb 1a                	jmp    8010a9 <fd_alloc+0x72>
  80108f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801094:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801099:	75 b6                	jne    801051 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  80109b:	8b 45 08             	mov    0x8(%ebp),%eax
  80109e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8010a4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010b1:	83 f8 1f             	cmp    $0x1f,%eax
  8010b4:	77 36                	ja     8010ec <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010b6:	c1 e0 0c             	shl    $0xc,%eax
  8010b9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010be:	89 c2                	mov    %eax,%edx
  8010c0:	c1 ea 16             	shr    $0x16,%edx
  8010c3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ca:	f6 c2 01             	test   $0x1,%dl
  8010cd:	74 24                	je     8010f3 <fd_lookup+0x48>
  8010cf:	89 c2                	mov    %eax,%edx
  8010d1:	c1 ea 0c             	shr    $0xc,%edx
  8010d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010db:	f6 c2 01             	test   $0x1,%dl
  8010de:	74 1a                	je     8010fa <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e3:	89 02                	mov    %eax,(%edx)
	return 0;
  8010e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ea:	eb 13                	jmp    8010ff <fd_lookup+0x54>
		return -E_INVAL;
  8010ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f1:	eb 0c                	jmp    8010ff <fd_lookup+0x54>
		return -E_INVAL;
  8010f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f8:	eb 05                	jmp    8010ff <fd_lookup+0x54>
  8010fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	53                   	push   %ebx
  801105:	83 ec 14             	sub    $0x14,%esp
  801108:	8b 45 08             	mov    0x8(%ebp),%eax
  80110b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80110e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801114:	75 1e                	jne    801134 <dev_lookup+0x33>
  801116:	eb 0e                	jmp    801126 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  801118:	b8 20 30 80 00       	mov    $0x803020,%eax
  80111d:	eb 0c                	jmp    80112b <dev_lookup+0x2a>
  80111f:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801124:	eb 05                	jmp    80112b <dev_lookup+0x2a>
  801126:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  80112b:	89 03                	mov    %eax,(%ebx)
			return 0;
  80112d:	b8 00 00 00 00       	mov    $0x0,%eax
  801132:	eb 38                	jmp    80116c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  801134:	39 05 20 30 80 00    	cmp    %eax,0x803020
  80113a:	74 dc                	je     801118 <dev_lookup+0x17>
  80113c:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  801142:	74 db                	je     80111f <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801144:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  80114a:	8b 52 48             	mov    0x48(%edx),%edx
  80114d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801151:	89 54 24 04          	mov    %edx,0x4(%esp)
  801155:	c7 04 24 8c 25 80 00 	movl   $0x80258c,(%esp)
  80115c:	e8 2c f1 ff ff       	call   80028d <cprintf>
	*dev = 0;
  801161:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801167:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80116c:	83 c4 14             	add    $0x14,%esp
  80116f:	5b                   	pop    %ebx
  801170:	5d                   	pop    %ebp
  801171:	c3                   	ret    

00801172 <fd_close>:
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	56                   	push   %esi
  801176:	53                   	push   %ebx
  801177:	83 ec 20             	sub    $0x20,%esp
  80117a:	8b 75 08             	mov    0x8(%ebp),%esi
  80117d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801180:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801183:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801187:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80118d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801190:	89 04 24             	mov    %eax,(%esp)
  801193:	e8 13 ff ff ff       	call   8010ab <fd_lookup>
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 05                	js     8011a1 <fd_close+0x2f>
	    || fd != fd2)
  80119c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80119f:	74 0c                	je     8011ad <fd_close+0x3b>
		return (must_exist ? r : 0);
  8011a1:	84 db                	test   %bl,%bl
  8011a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a8:	0f 44 c2             	cmove  %edx,%eax
  8011ab:	eb 3f                	jmp    8011ec <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b4:	8b 06                	mov    (%esi),%eax
  8011b6:	89 04 24             	mov    %eax,(%esp)
  8011b9:	e8 43 ff ff ff       	call   801101 <dev_lookup>
  8011be:	89 c3                	mov    %eax,%ebx
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	78 16                	js     8011da <fd_close+0x68>
		if (dev->dev_close)
  8011c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c7:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8011ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	74 07                	je     8011da <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8011d3:	89 34 24             	mov    %esi,(%esp)
  8011d6:	ff d0                	call   *%eax
  8011d8:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8011da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e5:	e8 56 fc ff ff       	call   800e40 <sys_page_unmap>
	return r;
  8011ea:	89 d8                	mov    %ebx,%eax
}
  8011ec:	83 c4 20             	add    $0x20,%esp
  8011ef:	5b                   	pop    %ebx
  8011f0:	5e                   	pop    %esi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <close>:

int
close(int fdnum)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801200:	8b 45 08             	mov    0x8(%ebp),%eax
  801203:	89 04 24             	mov    %eax,(%esp)
  801206:	e8 a0 fe ff ff       	call   8010ab <fd_lookup>
  80120b:	89 c2                	mov    %eax,%edx
  80120d:	85 d2                	test   %edx,%edx
  80120f:	78 13                	js     801224 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801211:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801218:	00 
  801219:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80121c:	89 04 24             	mov    %eax,(%esp)
  80121f:	e8 4e ff ff ff       	call   801172 <fd_close>
}
  801224:	c9                   	leave  
  801225:	c3                   	ret    

00801226 <close_all>:

void
close_all(void)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	53                   	push   %ebx
  80122a:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80122d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801232:	89 1c 24             	mov    %ebx,(%esp)
  801235:	e8 b9 ff ff ff       	call   8011f3 <close>
	for (i = 0; i < MAXFD; i++)
  80123a:	83 c3 01             	add    $0x1,%ebx
  80123d:	83 fb 20             	cmp    $0x20,%ebx
  801240:	75 f0                	jne    801232 <close_all+0xc>
}
  801242:	83 c4 14             	add    $0x14,%esp
  801245:	5b                   	pop    %ebx
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	57                   	push   %edi
  80124c:	56                   	push   %esi
  80124d:	53                   	push   %ebx
  80124e:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801251:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801254:	89 44 24 04          	mov    %eax,0x4(%esp)
  801258:	8b 45 08             	mov    0x8(%ebp),%eax
  80125b:	89 04 24             	mov    %eax,(%esp)
  80125e:	e8 48 fe ff ff       	call   8010ab <fd_lookup>
  801263:	89 c2                	mov    %eax,%edx
  801265:	85 d2                	test   %edx,%edx
  801267:	0f 88 e1 00 00 00    	js     80134e <dup+0x106>
		return r;
	close(newfdnum);
  80126d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801270:	89 04 24             	mov    %eax,(%esp)
  801273:	e8 7b ff ff ff       	call   8011f3 <close>

	newfd = INDEX2FD(newfdnum);
  801278:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80127b:	c1 e3 0c             	shl    $0xc,%ebx
  80127e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801284:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801287:	89 04 24             	mov    %eax,(%esp)
  80128a:	e8 91 fd ff ff       	call   801020 <fd2data>
  80128f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801291:	89 1c 24             	mov    %ebx,(%esp)
  801294:	e8 87 fd ff ff       	call   801020 <fd2data>
  801299:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80129b:	89 f0                	mov    %esi,%eax
  80129d:	c1 e8 16             	shr    $0x16,%eax
  8012a0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012a7:	a8 01                	test   $0x1,%al
  8012a9:	74 43                	je     8012ee <dup+0xa6>
  8012ab:	89 f0                	mov    %esi,%eax
  8012ad:	c1 e8 0c             	shr    $0xc,%eax
  8012b0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012b7:	f6 c2 01             	test   $0x1,%dl
  8012ba:	74 32                	je     8012ee <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c3:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012cc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012d7:	00 
  8012d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012e3:	e8 05 fb ff ff       	call   800ded <sys_page_map>
  8012e8:	89 c6                	mov    %eax,%esi
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 3e                	js     80132c <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f1:	89 c2                	mov    %eax,%edx
  8012f3:	c1 ea 0c             	shr    $0xc,%edx
  8012f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012fd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801303:	89 54 24 10          	mov    %edx,0x10(%esp)
  801307:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80130b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801312:	00 
  801313:	89 44 24 04          	mov    %eax,0x4(%esp)
  801317:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80131e:	e8 ca fa ff ff       	call   800ded <sys_page_map>
  801323:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801325:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801328:	85 f6                	test   %esi,%esi
  80132a:	79 22                	jns    80134e <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80132c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801330:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801337:	e8 04 fb ff ff       	call   800e40 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80133c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801340:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801347:	e8 f4 fa ff ff       	call   800e40 <sys_page_unmap>
	return r;
  80134c:	89 f0                	mov    %esi,%eax
}
  80134e:	83 c4 3c             	add    $0x3c,%esp
  801351:	5b                   	pop    %ebx
  801352:	5e                   	pop    %esi
  801353:	5f                   	pop    %edi
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    

00801356 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	53                   	push   %ebx
  80135a:	83 ec 24             	sub    $0x24,%esp
  80135d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801360:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801363:	89 44 24 04          	mov    %eax,0x4(%esp)
  801367:	89 1c 24             	mov    %ebx,(%esp)
  80136a:	e8 3c fd ff ff       	call   8010ab <fd_lookup>
  80136f:	89 c2                	mov    %eax,%edx
  801371:	85 d2                	test   %edx,%edx
  801373:	78 6d                	js     8013e2 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801375:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801378:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137f:	8b 00                	mov    (%eax),%eax
  801381:	89 04 24             	mov    %eax,(%esp)
  801384:	e8 78 fd ff ff       	call   801101 <dev_lookup>
  801389:	85 c0                	test   %eax,%eax
  80138b:	78 55                	js     8013e2 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80138d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801390:	8b 50 08             	mov    0x8(%eax),%edx
  801393:	83 e2 03             	and    $0x3,%edx
  801396:	83 fa 01             	cmp    $0x1,%edx
  801399:	75 23                	jne    8013be <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80139b:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8013a0:	8b 40 48             	mov    0x48(%eax),%eax
  8013a3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ab:	c7 04 24 d0 25 80 00 	movl   $0x8025d0,(%esp)
  8013b2:	e8 d6 ee ff ff       	call   80028d <cprintf>
		return -E_INVAL;
  8013b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013bc:	eb 24                	jmp    8013e2 <read+0x8c>
	}
	if (!dev->dev_read)
  8013be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013c1:	8b 52 08             	mov    0x8(%edx),%edx
  8013c4:	85 d2                	test   %edx,%edx
  8013c6:	74 15                	je     8013dd <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013d6:	89 04 24             	mov    %eax,(%esp)
  8013d9:	ff d2                	call   *%edx
  8013db:	eb 05                	jmp    8013e2 <read+0x8c>
		return -E_NOT_SUPP;
  8013dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8013e2:	83 c4 24             	add    $0x24,%esp
  8013e5:	5b                   	pop    %ebx
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    

008013e8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	57                   	push   %edi
  8013ec:	56                   	push   %esi
  8013ed:	53                   	push   %ebx
  8013ee:	83 ec 1c             	sub    $0x1c,%esp
  8013f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f7:	85 f6                	test   %esi,%esi
  8013f9:	74 33                	je     80142e <readn+0x46>
  8013fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801400:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801405:	89 f2                	mov    %esi,%edx
  801407:	29 c2                	sub    %eax,%edx
  801409:	89 54 24 08          	mov    %edx,0x8(%esp)
  80140d:	03 45 0c             	add    0xc(%ebp),%eax
  801410:	89 44 24 04          	mov    %eax,0x4(%esp)
  801414:	89 3c 24             	mov    %edi,(%esp)
  801417:	e8 3a ff ff ff       	call   801356 <read>
		if (m < 0)
  80141c:	85 c0                	test   %eax,%eax
  80141e:	78 1b                	js     80143b <readn+0x53>
			return m;
		if (m == 0)
  801420:	85 c0                	test   %eax,%eax
  801422:	74 11                	je     801435 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  801424:	01 c3                	add    %eax,%ebx
  801426:	89 d8                	mov    %ebx,%eax
  801428:	39 f3                	cmp    %esi,%ebx
  80142a:	72 d9                	jb     801405 <readn+0x1d>
  80142c:	eb 0b                	jmp    801439 <readn+0x51>
  80142e:	b8 00 00 00 00       	mov    $0x0,%eax
  801433:	eb 06                	jmp    80143b <readn+0x53>
  801435:	89 d8                	mov    %ebx,%eax
  801437:	eb 02                	jmp    80143b <readn+0x53>
  801439:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80143b:	83 c4 1c             	add    $0x1c,%esp
  80143e:	5b                   	pop    %ebx
  80143f:	5e                   	pop    %esi
  801440:	5f                   	pop    %edi
  801441:	5d                   	pop    %ebp
  801442:	c3                   	ret    

00801443 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	53                   	push   %ebx
  801447:	83 ec 24             	sub    $0x24,%esp
  80144a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801450:	89 44 24 04          	mov    %eax,0x4(%esp)
  801454:	89 1c 24             	mov    %ebx,(%esp)
  801457:	e8 4f fc ff ff       	call   8010ab <fd_lookup>
  80145c:	89 c2                	mov    %eax,%edx
  80145e:	85 d2                	test   %edx,%edx
  801460:	78 68                	js     8014ca <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801462:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801465:	89 44 24 04          	mov    %eax,0x4(%esp)
  801469:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146c:	8b 00                	mov    (%eax),%eax
  80146e:	89 04 24             	mov    %eax,(%esp)
  801471:	e8 8b fc ff ff       	call   801101 <dev_lookup>
  801476:	85 c0                	test   %eax,%eax
  801478:	78 50                	js     8014ca <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80147a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801481:	75 23                	jne    8014a6 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801483:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801488:	8b 40 48             	mov    0x48(%eax),%eax
  80148b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80148f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801493:	c7 04 24 ec 25 80 00 	movl   $0x8025ec,(%esp)
  80149a:	e8 ee ed ff ff       	call   80028d <cprintf>
		return -E_INVAL;
  80149f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a4:	eb 24                	jmp    8014ca <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a9:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ac:	85 d2                	test   %edx,%edx
  8014ae:	74 15                	je     8014c5 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ba:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014be:	89 04 24             	mov    %eax,(%esp)
  8014c1:	ff d2                	call   *%edx
  8014c3:	eb 05                	jmp    8014ca <write+0x87>
		return -E_NOT_SUPP;
  8014c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8014ca:	83 c4 24             	add    $0x24,%esp
  8014cd:	5b                   	pop    %ebx
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    

008014d0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e0:	89 04 24             	mov    %eax,(%esp)
  8014e3:	e8 c3 fb ff ff       	call   8010ab <fd_lookup>
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 0e                	js     8014fa <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8014ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	53                   	push   %ebx
  801500:	83 ec 24             	sub    $0x24,%esp
  801503:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801506:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801509:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150d:	89 1c 24             	mov    %ebx,(%esp)
  801510:	e8 96 fb ff ff       	call   8010ab <fd_lookup>
  801515:	89 c2                	mov    %eax,%edx
  801517:	85 d2                	test   %edx,%edx
  801519:	78 61                	js     80157c <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801522:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801525:	8b 00                	mov    (%eax),%eax
  801527:	89 04 24             	mov    %eax,(%esp)
  80152a:	e8 d2 fb ff ff       	call   801101 <dev_lookup>
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 49                	js     80157c <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801533:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801536:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153a:	75 23                	jne    80155f <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80153c:	a1 20 40 c0 00       	mov    0xc04020,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801541:	8b 40 48             	mov    0x48(%eax),%eax
  801544:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801548:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154c:	c7 04 24 ac 25 80 00 	movl   $0x8025ac,(%esp)
  801553:	e8 35 ed ff ff       	call   80028d <cprintf>
		return -E_INVAL;
  801558:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80155d:	eb 1d                	jmp    80157c <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80155f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801562:	8b 52 18             	mov    0x18(%edx),%edx
  801565:	85 d2                	test   %edx,%edx
  801567:	74 0e                	je     801577 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801569:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80156c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801570:	89 04 24             	mov    %eax,(%esp)
  801573:	ff d2                	call   *%edx
  801575:	eb 05                	jmp    80157c <ftruncate+0x80>
		return -E_NOT_SUPP;
  801577:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80157c:	83 c4 24             	add    $0x24,%esp
  80157f:	5b                   	pop    %ebx
  801580:	5d                   	pop    %ebp
  801581:	c3                   	ret    

00801582 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	53                   	push   %ebx
  801586:	83 ec 24             	sub    $0x24,%esp
  801589:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801593:	8b 45 08             	mov    0x8(%ebp),%eax
  801596:	89 04 24             	mov    %eax,(%esp)
  801599:	e8 0d fb ff ff       	call   8010ab <fd_lookup>
  80159e:	89 c2                	mov    %eax,%edx
  8015a0:	85 d2                	test   %edx,%edx
  8015a2:	78 52                	js     8015f6 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ae:	8b 00                	mov    (%eax),%eax
  8015b0:	89 04 24             	mov    %eax,(%esp)
  8015b3:	e8 49 fb ff ff       	call   801101 <dev_lookup>
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 3a                	js     8015f6 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8015bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015c3:	74 2c                	je     8015f1 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015c5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015c8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015cf:	00 00 00 
	stat->st_isdir = 0;
  8015d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015d9:	00 00 00 
	stat->st_dev = dev;
  8015dc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015e9:	89 14 24             	mov    %edx,(%esp)
  8015ec:	ff 50 14             	call   *0x14(%eax)
  8015ef:	eb 05                	jmp    8015f6 <fstat+0x74>
		return -E_NOT_SUPP;
  8015f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8015f6:	83 c4 24             	add    $0x24,%esp
  8015f9:	5b                   	pop    %ebx
  8015fa:	5d                   	pop    %ebp
  8015fb:	c3                   	ret    

008015fc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	56                   	push   %esi
  801600:	53                   	push   %ebx
  801601:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801604:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80160b:	00 
  80160c:	8b 45 08             	mov    0x8(%ebp),%eax
  80160f:	89 04 24             	mov    %eax,(%esp)
  801612:	e8 af 01 00 00       	call   8017c6 <open>
  801617:	89 c3                	mov    %eax,%ebx
  801619:	85 db                	test   %ebx,%ebx
  80161b:	78 1b                	js     801638 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80161d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801620:	89 44 24 04          	mov    %eax,0x4(%esp)
  801624:	89 1c 24             	mov    %ebx,(%esp)
  801627:	e8 56 ff ff ff       	call   801582 <fstat>
  80162c:	89 c6                	mov    %eax,%esi
	close(fd);
  80162e:	89 1c 24             	mov    %ebx,(%esp)
  801631:	e8 bd fb ff ff       	call   8011f3 <close>
	return r;
  801636:	89 f0                	mov    %esi,%eax
}
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	56                   	push   %esi
  801643:	53                   	push   %ebx
  801644:	83 ec 10             	sub    $0x10,%esp
  801647:	89 c6                	mov    %eax,%esi
  801649:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80164b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801652:	75 11                	jne    801665 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801654:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80165b:	e8 fa 07 00 00       	call   801e5a <ipc_find_env>
  801660:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801665:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80166c:	00 
  80166d:	c7 44 24 08 00 50 c0 	movl   $0xc05000,0x8(%esp)
  801674:	00 
  801675:	89 74 24 04          	mov    %esi,0x4(%esp)
  801679:	a1 00 40 80 00       	mov    0x804000,%eax
  80167e:	89 04 24             	mov    %eax,(%esp)
  801681:	e8 8c 07 00 00       	call   801e12 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801686:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80168d:	00 
  80168e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801692:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801699:	e8 18 07 00 00       	call   801db6 <ipc_recv>
}
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	5b                   	pop    %ebx
  8016a2:	5e                   	pop    %esi
  8016a3:	5d                   	pop    %ebp
  8016a4:	c3                   	ret    

008016a5 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	53                   	push   %ebx
  8016a9:	83 ec 14             	sub    $0x14,%esp
  8016ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016af:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b5:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bf:	b8 05 00 00 00       	mov    $0x5,%eax
  8016c4:	e8 76 ff ff ff       	call   80163f <fsipc>
  8016c9:	89 c2                	mov    %eax,%edx
  8016cb:	85 d2                	test   %edx,%edx
  8016cd:	78 2b                	js     8016fa <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016cf:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  8016d6:	00 
  8016d7:	89 1c 24             	mov    %ebx,(%esp)
  8016da:	e8 0c f2 ff ff       	call   8008eb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016df:	a1 80 50 c0 00       	mov    0xc05080,%eax
  8016e4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016ea:	a1 84 50 c0 00       	mov    0xc05084,%eax
  8016ef:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016fa:	83 c4 14             	add    $0x14,%esp
  8016fd:	5b                   	pop    %ebx
  8016fe:	5d                   	pop    %ebp
  8016ff:	c3                   	ret    

00801700 <devfile_flush>:
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801706:	8b 45 08             	mov    0x8(%ebp),%eax
  801709:	8b 40 0c             	mov    0xc(%eax),%eax
  80170c:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801711:	ba 00 00 00 00       	mov    $0x0,%edx
  801716:	b8 06 00 00 00       	mov    $0x6,%eax
  80171b:	e8 1f ff ff ff       	call   80163f <fsipc>
}
  801720:	c9                   	leave  
  801721:	c3                   	ret    

00801722 <devfile_read>:
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	56                   	push   %esi
  801726:	53                   	push   %ebx
  801727:	83 ec 10             	sub    $0x10,%esp
  80172a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80172d:	8b 45 08             	mov    0x8(%ebp),%eax
  801730:	8b 40 0c             	mov    0xc(%eax),%eax
  801733:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  801738:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80173e:	ba 00 00 00 00       	mov    $0x0,%edx
  801743:	b8 03 00 00 00       	mov    $0x3,%eax
  801748:	e8 f2 fe ff ff       	call   80163f <fsipc>
  80174d:	89 c3                	mov    %eax,%ebx
  80174f:	85 c0                	test   %eax,%eax
  801751:	78 6a                	js     8017bd <devfile_read+0x9b>
	assert(r <= n);
  801753:	39 c6                	cmp    %eax,%esi
  801755:	73 24                	jae    80177b <devfile_read+0x59>
  801757:	c7 44 24 0c 09 26 80 	movl   $0x802609,0xc(%esp)
  80175e:	00 
  80175f:	c7 44 24 08 10 26 80 	movl   $0x802610,0x8(%esp)
  801766:	00 
  801767:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80176e:	00 
  80176f:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  801776:	e8 19 ea ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  80177b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801780:	7e 24                	jle    8017a6 <devfile_read+0x84>
  801782:	c7 44 24 0c 30 26 80 	movl   $0x802630,0xc(%esp)
  801789:	00 
  80178a:	c7 44 24 08 10 26 80 	movl   $0x802610,0x8(%esp)
  801791:	00 
  801792:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801799:	00 
  80179a:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  8017a1:	e8 ee e9 ff ff       	call   800194 <_panic>
	memmove(buf, &fsipcbuf, r);
  8017a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017aa:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  8017b1:	00 
  8017b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b5:	89 04 24             	mov    %eax,(%esp)
  8017b8:	e8 29 f3 ff ff       	call   800ae6 <memmove>
}
  8017bd:	89 d8                	mov    %ebx,%eax
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	5b                   	pop    %ebx
  8017c3:	5e                   	pop    %esi
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <open>:
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	53                   	push   %ebx
  8017ca:	83 ec 24             	sub    $0x24,%esp
  8017cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8017d0:	89 1c 24             	mov    %ebx,(%esp)
  8017d3:	e8 b8 f0 ff ff       	call   800890 <strlen>
  8017d8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017dd:	7f 60                	jg     80183f <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  8017df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e2:	89 04 24             	mov    %eax,(%esp)
  8017e5:	e8 4d f8 ff ff       	call   801037 <fd_alloc>
  8017ea:	89 c2                	mov    %eax,%edx
  8017ec:	85 d2                	test   %edx,%edx
  8017ee:	78 54                	js     801844 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  8017f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017f4:	c7 04 24 00 50 c0 00 	movl   $0xc05000,(%esp)
  8017fb:	e8 eb f0 ff ff       	call   8008eb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801800:	8b 45 0c             	mov    0xc(%ebp),%eax
  801803:	a3 00 54 c0 00       	mov    %eax,0xc05400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801808:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80180b:	b8 01 00 00 00       	mov    $0x1,%eax
  801810:	e8 2a fe ff ff       	call   80163f <fsipc>
  801815:	89 c3                	mov    %eax,%ebx
  801817:	85 c0                	test   %eax,%eax
  801819:	79 17                	jns    801832 <open+0x6c>
		fd_close(fd, 0);
  80181b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801822:	00 
  801823:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801826:	89 04 24             	mov    %eax,(%esp)
  801829:	e8 44 f9 ff ff       	call   801172 <fd_close>
		return r;
  80182e:	89 d8                	mov    %ebx,%eax
  801830:	eb 12                	jmp    801844 <open+0x7e>
	return fd2num(fd);
  801832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801835:	89 04 24             	mov    %eax,(%esp)
  801838:	e8 d3 f7 ff ff       	call   801010 <fd2num>
  80183d:	eb 05                	jmp    801844 <open+0x7e>
		return -E_BAD_PATH;
  80183f:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801844:	83 c4 24             	add    $0x24,%esp
  801847:	5b                   	pop    %ebx
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    
  80184a:	66 90                	xchg   %ax,%ax
  80184c:	66 90                	xchg   %ax,%ax
  80184e:	66 90                	xchg   %ax,%ax

00801850 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	56                   	push   %esi
  801854:	53                   	push   %ebx
  801855:	83 ec 10             	sub    $0x10,%esp
  801858:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80185b:	8b 45 08             	mov    0x8(%ebp),%eax
  80185e:	89 04 24             	mov    %eax,(%esp)
  801861:	e8 ba f7 ff ff       	call   801020 <fd2data>
  801866:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801868:	c7 44 24 04 3c 26 80 	movl   $0x80263c,0x4(%esp)
  80186f:	00 
  801870:	89 1c 24             	mov    %ebx,(%esp)
  801873:	e8 73 f0 ff ff       	call   8008eb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801878:	8b 46 04             	mov    0x4(%esi),%eax
  80187b:	2b 06                	sub    (%esi),%eax
  80187d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801883:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80188a:	00 00 00 
	stat->st_dev = &devpipe;
  80188d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801894:	30 80 00 
	return 0;
}
  801897:	b8 00 00 00 00       	mov    $0x0,%eax
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	5b                   	pop    %ebx
  8018a0:	5e                   	pop    %esi
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    

008018a3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	53                   	push   %ebx
  8018a7:	83 ec 14             	sub    $0x14,%esp
  8018aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b8:	e8 83 f5 ff ff       	call   800e40 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018bd:	89 1c 24             	mov    %ebx,(%esp)
  8018c0:	e8 5b f7 ff ff       	call   801020 <fd2data>
  8018c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018d0:	e8 6b f5 ff ff       	call   800e40 <sys_page_unmap>
}
  8018d5:	83 c4 14             	add    $0x14,%esp
  8018d8:	5b                   	pop    %ebx
  8018d9:	5d                   	pop    %ebp
  8018da:	c3                   	ret    

008018db <_pipeisclosed>:
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	57                   	push   %edi
  8018df:	56                   	push   %esi
  8018e0:	53                   	push   %ebx
  8018e1:	83 ec 2c             	sub    $0x2c,%esp
  8018e4:	89 c6                	mov    %eax,%esi
  8018e6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  8018e9:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8018ee:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018f1:	89 34 24             	mov    %esi,(%esp)
  8018f4:	e8 a9 05 00 00       	call   801ea2 <pageref>
  8018f9:	89 c7                	mov    %eax,%edi
  8018fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018fe:	89 04 24             	mov    %eax,(%esp)
  801901:	e8 9c 05 00 00       	call   801ea2 <pageref>
  801906:	39 c7                	cmp    %eax,%edi
  801908:	0f 94 c2             	sete   %dl
  80190b:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80190e:	8b 0d 20 40 c0 00    	mov    0xc04020,%ecx
  801914:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801917:	39 fb                	cmp    %edi,%ebx
  801919:	74 21                	je     80193c <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  80191b:	84 d2                	test   %dl,%dl
  80191d:	74 ca                	je     8018e9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80191f:	8b 51 58             	mov    0x58(%ecx),%edx
  801922:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801926:	89 54 24 08          	mov    %edx,0x8(%esp)
  80192a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80192e:	c7 04 24 43 26 80 00 	movl   $0x802643,(%esp)
  801935:	e8 53 e9 ff ff       	call   80028d <cprintf>
  80193a:	eb ad                	jmp    8018e9 <_pipeisclosed+0xe>
}
  80193c:	83 c4 2c             	add    $0x2c,%esp
  80193f:	5b                   	pop    %ebx
  801940:	5e                   	pop    %esi
  801941:	5f                   	pop    %edi
  801942:	5d                   	pop    %ebp
  801943:	c3                   	ret    

00801944 <devpipe_write>:
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	57                   	push   %edi
  801948:	56                   	push   %esi
  801949:	53                   	push   %ebx
  80194a:	83 ec 1c             	sub    $0x1c,%esp
  80194d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801950:	89 34 24             	mov    %esi,(%esp)
  801953:	e8 c8 f6 ff ff       	call   801020 <fd2data>
	for (i = 0; i < n; i++) {
  801958:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80195c:	74 61                	je     8019bf <devpipe_write+0x7b>
  80195e:	89 c3                	mov    %eax,%ebx
  801960:	bf 00 00 00 00       	mov    $0x0,%edi
  801965:	eb 4a                	jmp    8019b1 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  801967:	89 da                	mov    %ebx,%edx
  801969:	89 f0                	mov    %esi,%eax
  80196b:	e8 6b ff ff ff       	call   8018db <_pipeisclosed>
  801970:	85 c0                	test   %eax,%eax
  801972:	75 54                	jne    8019c8 <devpipe_write+0x84>
			sys_yield();
  801974:	e8 01 f4 ff ff       	call   800d7a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801979:	8b 43 04             	mov    0x4(%ebx),%eax
  80197c:	8b 0b                	mov    (%ebx),%ecx
  80197e:	8d 51 20             	lea    0x20(%ecx),%edx
  801981:	39 d0                	cmp    %edx,%eax
  801983:	73 e2                	jae    801967 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801985:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801988:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80198c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80198f:	99                   	cltd   
  801990:	c1 ea 1b             	shr    $0x1b,%edx
  801993:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801996:	83 e1 1f             	and    $0x1f,%ecx
  801999:	29 d1                	sub    %edx,%ecx
  80199b:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80199f:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8019a3:	83 c0 01             	add    $0x1,%eax
  8019a6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8019a9:	83 c7 01             	add    $0x1,%edi
  8019ac:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019af:	74 13                	je     8019c4 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8019b4:	8b 0b                	mov    (%ebx),%ecx
  8019b6:	8d 51 20             	lea    0x20(%ecx),%edx
  8019b9:	39 d0                	cmp    %edx,%eax
  8019bb:	73 aa                	jae    801967 <devpipe_write+0x23>
  8019bd:	eb c6                	jmp    801985 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  8019bf:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  8019c4:	89 f8                	mov    %edi,%eax
  8019c6:	eb 05                	jmp    8019cd <devpipe_write+0x89>
				return 0;
  8019c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019cd:	83 c4 1c             	add    $0x1c,%esp
  8019d0:	5b                   	pop    %ebx
  8019d1:	5e                   	pop    %esi
  8019d2:	5f                   	pop    %edi
  8019d3:	5d                   	pop    %ebp
  8019d4:	c3                   	ret    

008019d5 <devpipe_read>:
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	57                   	push   %edi
  8019d9:	56                   	push   %esi
  8019da:	53                   	push   %ebx
  8019db:	83 ec 1c             	sub    $0x1c,%esp
  8019de:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8019e1:	89 3c 24             	mov    %edi,(%esp)
  8019e4:	e8 37 f6 ff ff       	call   801020 <fd2data>
	for (i = 0; i < n; i++) {
  8019e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019ed:	74 54                	je     801a43 <devpipe_read+0x6e>
  8019ef:	89 c3                	mov    %eax,%ebx
  8019f1:	be 00 00 00 00       	mov    $0x0,%esi
  8019f6:	eb 3e                	jmp    801a36 <devpipe_read+0x61>
				return i;
  8019f8:	89 f0                	mov    %esi,%eax
  8019fa:	eb 55                	jmp    801a51 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  8019fc:	89 da                	mov    %ebx,%edx
  8019fe:	89 f8                	mov    %edi,%eax
  801a00:	e8 d6 fe ff ff       	call   8018db <_pipeisclosed>
  801a05:	85 c0                	test   %eax,%eax
  801a07:	75 43                	jne    801a4c <devpipe_read+0x77>
			sys_yield();
  801a09:	e8 6c f3 ff ff       	call   800d7a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801a0e:	8b 03                	mov    (%ebx),%eax
  801a10:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a13:	74 e7                	je     8019fc <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a15:	99                   	cltd   
  801a16:	c1 ea 1b             	shr    $0x1b,%edx
  801a19:	01 d0                	add    %edx,%eax
  801a1b:	83 e0 1f             	and    $0x1f,%eax
  801a1e:	29 d0                	sub    %edx,%eax
  801a20:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a28:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a2b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801a2e:	83 c6 01             	add    $0x1,%esi
  801a31:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a34:	74 12                	je     801a48 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  801a36:	8b 03                	mov    (%ebx),%eax
  801a38:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a3b:	75 d8                	jne    801a15 <devpipe_read+0x40>
			if (i > 0)
  801a3d:	85 f6                	test   %esi,%esi
  801a3f:	75 b7                	jne    8019f8 <devpipe_read+0x23>
  801a41:	eb b9                	jmp    8019fc <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  801a43:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  801a48:	89 f0                	mov    %esi,%eax
  801a4a:	eb 05                	jmp    801a51 <devpipe_read+0x7c>
				return 0;
  801a4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a51:	83 c4 1c             	add    $0x1c,%esp
  801a54:	5b                   	pop    %ebx
  801a55:	5e                   	pop    %esi
  801a56:	5f                   	pop    %edi
  801a57:	5d                   	pop    %ebp
  801a58:	c3                   	ret    

00801a59 <pipe>:
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	56                   	push   %esi
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801a61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a64:	89 04 24             	mov    %eax,(%esp)
  801a67:	e8 cb f5 ff ff       	call   801037 <fd_alloc>
  801a6c:	89 c2                	mov    %eax,%edx
  801a6e:	85 d2                	test   %edx,%edx
  801a70:	0f 88 4d 01 00 00    	js     801bc3 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a76:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a7d:	00 
  801a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a81:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a8c:	e8 08 f3 ff ff       	call   800d99 <sys_page_alloc>
  801a91:	89 c2                	mov    %eax,%edx
  801a93:	85 d2                	test   %edx,%edx
  801a95:	0f 88 28 01 00 00    	js     801bc3 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801a9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a9e:	89 04 24             	mov    %eax,(%esp)
  801aa1:	e8 91 f5 ff ff       	call   801037 <fd_alloc>
  801aa6:	89 c3                	mov    %eax,%ebx
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	0f 88 fe 00 00 00    	js     801bae <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ab7:	00 
  801ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801abb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ac6:	e8 ce f2 ff ff       	call   800d99 <sys_page_alloc>
  801acb:	89 c3                	mov    %eax,%ebx
  801acd:	85 c0                	test   %eax,%eax
  801acf:	0f 88 d9 00 00 00    	js     801bae <pipe+0x155>
	va = fd2data(fd0);
  801ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad8:	89 04 24             	mov    %eax,(%esp)
  801adb:	e8 40 f5 ff ff       	call   801020 <fd2data>
  801ae0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ae9:	00 
  801aea:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af5:	e8 9f f2 ff ff       	call   800d99 <sys_page_alloc>
  801afa:	89 c3                	mov    %eax,%ebx
  801afc:	85 c0                	test   %eax,%eax
  801afe:	0f 88 97 00 00 00    	js     801b9b <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b07:	89 04 24             	mov    %eax,(%esp)
  801b0a:	e8 11 f5 ff ff       	call   801020 <fd2data>
  801b0f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b16:	00 
  801b17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b22:	00 
  801b23:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2e:	e8 ba f2 ff ff       	call   800ded <sys_page_map>
  801b33:	89 c3                	mov    %eax,%ebx
  801b35:	85 c0                	test   %eax,%eax
  801b37:	78 52                	js     801b8b <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801b39:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b42:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b47:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801b4e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b57:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b5c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b66:	89 04 24             	mov    %eax,(%esp)
  801b69:	e8 a2 f4 ff ff       	call   801010 <fd2num>
  801b6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b71:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b76:	89 04 24             	mov    %eax,(%esp)
  801b79:	e8 92 f4 ff ff       	call   801010 <fd2num>
  801b7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b81:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
  801b89:	eb 38                	jmp    801bc3 <pipe+0x16a>
	sys_page_unmap(0, va);
  801b8b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b96:	e8 a5 f2 ff ff       	call   800e40 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba9:	e8 92 f2 ff ff       	call   800e40 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bbc:	e8 7f f2 ff ff       	call   800e40 <sys_page_unmap>
  801bc1:	89 d8                	mov    %ebx,%eax
}
  801bc3:	83 c4 30             	add    $0x30,%esp
  801bc6:	5b                   	pop    %ebx
  801bc7:	5e                   	pop    %esi
  801bc8:	5d                   	pop    %ebp
  801bc9:	c3                   	ret    

00801bca <pipeisclosed>:
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bda:	89 04 24             	mov    %eax,(%esp)
  801bdd:	e8 c9 f4 ff ff       	call   8010ab <fd_lookup>
  801be2:	89 c2                	mov    %eax,%edx
  801be4:	85 d2                	test   %edx,%edx
  801be6:	78 15                	js     801bfd <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801beb:	89 04 24             	mov    %eax,(%esp)
  801bee:	e8 2d f4 ff ff       	call   801020 <fd2data>
	return _pipeisclosed(fd, p);
  801bf3:	89 c2                	mov    %eax,%edx
  801bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf8:	e8 de fc ff ff       	call   8018db <_pipeisclosed>
}
  801bfd:	c9                   	leave  
  801bfe:	c3                   	ret    
  801bff:	90                   	nop

00801c00 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c03:	b8 00 00 00 00       	mov    $0x0,%eax
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    

00801c0a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801c10:	c7 44 24 04 5b 26 80 	movl   $0x80265b,0x4(%esp)
  801c17:	00 
  801c18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c1b:	89 04 24             	mov    %eax,(%esp)
  801c1e:	e8 c8 ec ff ff       	call   8008eb <strcpy>
	return 0;
}
  801c23:	b8 00 00 00 00       	mov    $0x0,%eax
  801c28:	c9                   	leave  
  801c29:	c3                   	ret    

00801c2a <devcons_write>:
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	57                   	push   %edi
  801c2e:	56                   	push   %esi
  801c2f:	53                   	push   %ebx
  801c30:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c36:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c3a:	74 4a                	je     801c86 <devcons_write+0x5c>
  801c3c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c41:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c46:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  801c4c:	8b 75 10             	mov    0x10(%ebp),%esi
  801c4f:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  801c51:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801c54:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c59:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c5c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c60:	03 45 0c             	add    0xc(%ebp),%eax
  801c63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c67:	89 3c 24             	mov    %edi,(%esp)
  801c6a:	e8 77 ee ff ff       	call   800ae6 <memmove>
		sys_cputs(buf, m);
  801c6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c73:	89 3c 24             	mov    %edi,(%esp)
  801c76:	e8 51 f0 ff ff       	call   800ccc <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801c7b:	01 f3                	add    %esi,%ebx
  801c7d:	89 d8                	mov    %ebx,%eax
  801c7f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c82:	72 c8                	jb     801c4c <devcons_write+0x22>
  801c84:	eb 05                	jmp    801c8b <devcons_write+0x61>
  801c86:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  801c8b:	89 d8                	mov    %ebx,%eax
  801c8d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    

00801c98 <devcons_read>:
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801c9e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ca3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ca7:	75 07                	jne    801cb0 <devcons_read+0x18>
  801ca9:	eb 28                	jmp    801cd3 <devcons_read+0x3b>
		sys_yield();
  801cab:	e8 ca f0 ff ff       	call   800d7a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801cb0:	e8 35 f0 ff ff       	call   800cea <sys_cgetc>
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	74 f2                	je     801cab <devcons_read+0x13>
	if (c < 0)
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	78 16                	js     801cd3 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  801cbd:	83 f8 04             	cmp    $0x4,%eax
  801cc0:	74 0c                	je     801cce <devcons_read+0x36>
	*(char*)vbuf = c;
  801cc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cc5:	88 02                	mov    %al,(%edx)
	return 1;
  801cc7:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccc:	eb 05                	jmp    801cd3 <devcons_read+0x3b>
		return 0;
  801cce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    

00801cd5 <cputchar>:
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cde:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ce1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ce8:	00 
  801ce9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cec:	89 04 24             	mov    %eax,(%esp)
  801cef:	e8 d8 ef ff ff       	call   800ccc <sys_cputs>
}
  801cf4:	c9                   	leave  
  801cf5:	c3                   	ret    

00801cf6 <getchar>:
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801cfc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801d03:	00 
  801d04:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d12:	e8 3f f6 ff ff       	call   801356 <read>
	if (r < 0)
  801d17:	85 c0                	test   %eax,%eax
  801d19:	78 0f                	js     801d2a <getchar+0x34>
	if (r < 1)
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	7e 06                	jle    801d25 <getchar+0x2f>
	return c;
  801d1f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d23:	eb 05                	jmp    801d2a <getchar+0x34>
		return -E_EOF;
  801d25:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801d2a:	c9                   	leave  
  801d2b:	c3                   	ret    

00801d2c <iscons>:
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d39:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3c:	89 04 24             	mov    %eax,(%esp)
  801d3f:	e8 67 f3 ff ff       	call   8010ab <fd_lookup>
  801d44:	85 c0                	test   %eax,%eax
  801d46:	78 11                	js     801d59 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d51:	39 10                	cmp    %edx,(%eax)
  801d53:	0f 94 c0             	sete   %al
  801d56:	0f b6 c0             	movzbl %al,%eax
}
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <opencons>:
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d64:	89 04 24             	mov    %eax,(%esp)
  801d67:	e8 cb f2 ff ff       	call   801037 <fd_alloc>
		return r;
  801d6c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	78 40                	js     801db2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d72:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d79:	00 
  801d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d88:	e8 0c f0 ff ff       	call   800d99 <sys_page_alloc>
		return r;
  801d8d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	78 1f                	js     801db2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801d93:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801da8:	89 04 24             	mov    %eax,(%esp)
  801dab:	e8 60 f2 ff ff       	call   801010 <fd2num>
  801db0:	89 c2                	mov    %eax,%edx
}
  801db2:	89 d0                	mov    %edx,%eax
  801db4:	c9                   	leave  
  801db5:	c3                   	ret    

00801db6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	56                   	push   %esi
  801dba:	53                   	push   %ebx
  801dbb:	83 ec 10             	sub    $0x10,%esp
  801dbe:	8b 75 08             	mov    0x8(%ebp),%esi
  801dc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  801dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc7:	89 04 24             	mov    %eax,(%esp)
  801dca:	e8 e0 f1 ff ff       	call   800faf <sys_ipc_recv>
	if(from_env_store)
  801dcf:	85 f6                	test   %esi,%esi
  801dd1:	74 14                	je     801de7 <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  801dd3:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	78 09                	js     801de5 <ipc_recv+0x2f>
  801ddc:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801de2:	8b 52 74             	mov    0x74(%edx),%edx
  801de5:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  801de7:	85 db                	test   %ebx,%ebx
  801de9:	74 14                	je     801dff <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  801deb:	ba 00 00 00 00       	mov    $0x0,%edx
  801df0:	85 c0                	test   %eax,%eax
  801df2:	78 09                	js     801dfd <ipc_recv+0x47>
  801df4:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801dfa:	8b 52 78             	mov    0x78(%edx),%edx
  801dfd:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  801dff:	85 c0                	test   %eax,%eax
  801e01:	78 08                	js     801e0b <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  801e03:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801e08:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e0b:	83 c4 10             	add    $0x10,%esp
  801e0e:	5b                   	pop    %ebx
  801e0f:	5e                   	pop    %esi
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    

00801e12 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	57                   	push   %edi
  801e16:	56                   	push   %esi
  801e17:	53                   	push   %ebx
  801e18:	83 ec 1c             	sub    $0x1c,%esp
  801e1b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e1e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  801e21:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801e26:	eb 0c                	jmp    801e34 <ipc_send+0x22>
		failed_cnt++;
  801e28:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  801e2b:	84 db                	test   %bl,%bl
  801e2d:	75 05                	jne    801e34 <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  801e2f:	e8 46 ef ff ff       	call   800d7a <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801e34:	8b 45 14             	mov    0x14(%ebp),%eax
  801e37:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e3b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e42:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e46:	89 3c 24             	mov    %edi,(%esp)
  801e49:	e8 3e f1 ff ff       	call   800f8c <sys_ipc_try_send>
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	78 d6                	js     801e28 <ipc_send+0x16>
	}
}
  801e52:	83 c4 1c             	add    $0x1c,%esp
  801e55:	5b                   	pop    %ebx
  801e56:	5e                   	pop    %esi
  801e57:	5f                   	pop    %edi
  801e58:	5d                   	pop    %ebp
  801e59:	c3                   	ret    

00801e5a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801e60:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801e65:	39 c8                	cmp    %ecx,%eax
  801e67:	74 17                	je     801e80 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  801e69:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801e6e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e71:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e77:	8b 52 50             	mov    0x50(%edx),%edx
  801e7a:	39 ca                	cmp    %ecx,%edx
  801e7c:	75 14                	jne    801e92 <ipc_find_env+0x38>
  801e7e:	eb 05                	jmp    801e85 <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  801e80:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  801e85:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e88:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801e8d:	8b 40 40             	mov    0x40(%eax),%eax
  801e90:	eb 0e                	jmp    801ea0 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  801e92:	83 c0 01             	add    $0x1,%eax
  801e95:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e9a:	75 d2                	jne    801e6e <ipc_find_env+0x14>
	return 0;
  801e9c:	66 b8 00 00          	mov    $0x0,%ax
}
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    

00801ea2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ea8:	89 d0                	mov    %edx,%eax
  801eaa:	c1 e8 16             	shr    $0x16,%eax
  801ead:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801eb4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801eb9:	f6 c1 01             	test   $0x1,%cl
  801ebc:	74 1d                	je     801edb <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801ebe:	c1 ea 0c             	shr    $0xc,%edx
  801ec1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ec8:	f6 c2 01             	test   $0x1,%dl
  801ecb:	74 0e                	je     801edb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ecd:	c1 ea 0c             	shr    $0xc,%edx
  801ed0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ed7:	ef 
  801ed8:	0f b7 c0             	movzwl %ax,%eax
}
  801edb:	5d                   	pop    %ebp
  801edc:	c3                   	ret    
  801edd:	66 90                	xchg   %ax,%ax
  801edf:	90                   	nop

00801ee0 <__udivdi3>:
  801ee0:	55                   	push   %ebp
  801ee1:	57                   	push   %edi
  801ee2:	56                   	push   %esi
  801ee3:	83 ec 0c             	sub    $0xc,%esp
  801ee6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801eea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801eee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801ef2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801efc:	89 ea                	mov    %ebp,%edx
  801efe:	89 0c 24             	mov    %ecx,(%esp)
  801f01:	75 2d                	jne    801f30 <__udivdi3+0x50>
  801f03:	39 e9                	cmp    %ebp,%ecx
  801f05:	77 61                	ja     801f68 <__udivdi3+0x88>
  801f07:	85 c9                	test   %ecx,%ecx
  801f09:	89 ce                	mov    %ecx,%esi
  801f0b:	75 0b                	jne    801f18 <__udivdi3+0x38>
  801f0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801f12:	31 d2                	xor    %edx,%edx
  801f14:	f7 f1                	div    %ecx
  801f16:	89 c6                	mov    %eax,%esi
  801f18:	31 d2                	xor    %edx,%edx
  801f1a:	89 e8                	mov    %ebp,%eax
  801f1c:	f7 f6                	div    %esi
  801f1e:	89 c5                	mov    %eax,%ebp
  801f20:	89 f8                	mov    %edi,%eax
  801f22:	f7 f6                	div    %esi
  801f24:	89 ea                	mov    %ebp,%edx
  801f26:	83 c4 0c             	add    $0xc,%esp
  801f29:	5e                   	pop    %esi
  801f2a:	5f                   	pop    %edi
  801f2b:	5d                   	pop    %ebp
  801f2c:	c3                   	ret    
  801f2d:	8d 76 00             	lea    0x0(%esi),%esi
  801f30:	39 e8                	cmp    %ebp,%eax
  801f32:	77 24                	ja     801f58 <__udivdi3+0x78>
  801f34:	0f bd e8             	bsr    %eax,%ebp
  801f37:	83 f5 1f             	xor    $0x1f,%ebp
  801f3a:	75 3c                	jne    801f78 <__udivdi3+0x98>
  801f3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801f40:	39 34 24             	cmp    %esi,(%esp)
  801f43:	0f 86 9f 00 00 00    	jbe    801fe8 <__udivdi3+0x108>
  801f49:	39 d0                	cmp    %edx,%eax
  801f4b:	0f 82 97 00 00 00    	jb     801fe8 <__udivdi3+0x108>
  801f51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f58:	31 d2                	xor    %edx,%edx
  801f5a:	31 c0                	xor    %eax,%eax
  801f5c:	83 c4 0c             	add    $0xc,%esp
  801f5f:	5e                   	pop    %esi
  801f60:	5f                   	pop    %edi
  801f61:	5d                   	pop    %ebp
  801f62:	c3                   	ret    
  801f63:	90                   	nop
  801f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f68:	89 f8                	mov    %edi,%eax
  801f6a:	f7 f1                	div    %ecx
  801f6c:	31 d2                	xor    %edx,%edx
  801f6e:	83 c4 0c             	add    $0xc,%esp
  801f71:	5e                   	pop    %esi
  801f72:	5f                   	pop    %edi
  801f73:	5d                   	pop    %ebp
  801f74:	c3                   	ret    
  801f75:	8d 76 00             	lea    0x0(%esi),%esi
  801f78:	89 e9                	mov    %ebp,%ecx
  801f7a:	8b 3c 24             	mov    (%esp),%edi
  801f7d:	d3 e0                	shl    %cl,%eax
  801f7f:	89 c6                	mov    %eax,%esi
  801f81:	b8 20 00 00 00       	mov    $0x20,%eax
  801f86:	29 e8                	sub    %ebp,%eax
  801f88:	89 c1                	mov    %eax,%ecx
  801f8a:	d3 ef                	shr    %cl,%edi
  801f8c:	89 e9                	mov    %ebp,%ecx
  801f8e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801f92:	8b 3c 24             	mov    (%esp),%edi
  801f95:	09 74 24 08          	or     %esi,0x8(%esp)
  801f99:	89 d6                	mov    %edx,%esi
  801f9b:	d3 e7                	shl    %cl,%edi
  801f9d:	89 c1                	mov    %eax,%ecx
  801f9f:	89 3c 24             	mov    %edi,(%esp)
  801fa2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801fa6:	d3 ee                	shr    %cl,%esi
  801fa8:	89 e9                	mov    %ebp,%ecx
  801faa:	d3 e2                	shl    %cl,%edx
  801fac:	89 c1                	mov    %eax,%ecx
  801fae:	d3 ef                	shr    %cl,%edi
  801fb0:	09 d7                	or     %edx,%edi
  801fb2:	89 f2                	mov    %esi,%edx
  801fb4:	89 f8                	mov    %edi,%eax
  801fb6:	f7 74 24 08          	divl   0x8(%esp)
  801fba:	89 d6                	mov    %edx,%esi
  801fbc:	89 c7                	mov    %eax,%edi
  801fbe:	f7 24 24             	mull   (%esp)
  801fc1:	39 d6                	cmp    %edx,%esi
  801fc3:	89 14 24             	mov    %edx,(%esp)
  801fc6:	72 30                	jb     801ff8 <__udivdi3+0x118>
  801fc8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801fcc:	89 e9                	mov    %ebp,%ecx
  801fce:	d3 e2                	shl    %cl,%edx
  801fd0:	39 c2                	cmp    %eax,%edx
  801fd2:	73 05                	jae    801fd9 <__udivdi3+0xf9>
  801fd4:	3b 34 24             	cmp    (%esp),%esi
  801fd7:	74 1f                	je     801ff8 <__udivdi3+0x118>
  801fd9:	89 f8                	mov    %edi,%eax
  801fdb:	31 d2                	xor    %edx,%edx
  801fdd:	e9 7a ff ff ff       	jmp    801f5c <__udivdi3+0x7c>
  801fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fe8:	31 d2                	xor    %edx,%edx
  801fea:	b8 01 00 00 00       	mov    $0x1,%eax
  801fef:	e9 68 ff ff ff       	jmp    801f5c <__udivdi3+0x7c>
  801ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ff8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801ffb:	31 d2                	xor    %edx,%edx
  801ffd:	83 c4 0c             	add    $0xc,%esp
  802000:	5e                   	pop    %esi
  802001:	5f                   	pop    %edi
  802002:	5d                   	pop    %ebp
  802003:	c3                   	ret    
  802004:	66 90                	xchg   %ax,%ax
  802006:	66 90                	xchg   %ax,%ax
  802008:	66 90                	xchg   %ax,%ax
  80200a:	66 90                	xchg   %ax,%ax
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <__umoddi3>:
  802010:	55                   	push   %ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	83 ec 14             	sub    $0x14,%esp
  802016:	8b 44 24 28          	mov    0x28(%esp),%eax
  80201a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80201e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802022:	89 c7                	mov    %eax,%edi
  802024:	89 44 24 04          	mov    %eax,0x4(%esp)
  802028:	8b 44 24 30          	mov    0x30(%esp),%eax
  80202c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802030:	89 34 24             	mov    %esi,(%esp)
  802033:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802037:	85 c0                	test   %eax,%eax
  802039:	89 c2                	mov    %eax,%edx
  80203b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80203f:	75 17                	jne    802058 <__umoddi3+0x48>
  802041:	39 fe                	cmp    %edi,%esi
  802043:	76 4b                	jbe    802090 <__umoddi3+0x80>
  802045:	89 c8                	mov    %ecx,%eax
  802047:	89 fa                	mov    %edi,%edx
  802049:	f7 f6                	div    %esi
  80204b:	89 d0                	mov    %edx,%eax
  80204d:	31 d2                	xor    %edx,%edx
  80204f:	83 c4 14             	add    $0x14,%esp
  802052:	5e                   	pop    %esi
  802053:	5f                   	pop    %edi
  802054:	5d                   	pop    %ebp
  802055:	c3                   	ret    
  802056:	66 90                	xchg   %ax,%ax
  802058:	39 f8                	cmp    %edi,%eax
  80205a:	77 54                	ja     8020b0 <__umoddi3+0xa0>
  80205c:	0f bd e8             	bsr    %eax,%ebp
  80205f:	83 f5 1f             	xor    $0x1f,%ebp
  802062:	75 5c                	jne    8020c0 <__umoddi3+0xb0>
  802064:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802068:	39 3c 24             	cmp    %edi,(%esp)
  80206b:	0f 87 e7 00 00 00    	ja     802158 <__umoddi3+0x148>
  802071:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802075:	29 f1                	sub    %esi,%ecx
  802077:	19 c7                	sbb    %eax,%edi
  802079:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80207d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802081:	8b 44 24 08          	mov    0x8(%esp),%eax
  802085:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802089:	83 c4 14             	add    $0x14,%esp
  80208c:	5e                   	pop    %esi
  80208d:	5f                   	pop    %edi
  80208e:	5d                   	pop    %ebp
  80208f:	c3                   	ret    
  802090:	85 f6                	test   %esi,%esi
  802092:	89 f5                	mov    %esi,%ebp
  802094:	75 0b                	jne    8020a1 <__umoddi3+0x91>
  802096:	b8 01 00 00 00       	mov    $0x1,%eax
  80209b:	31 d2                	xor    %edx,%edx
  80209d:	f7 f6                	div    %esi
  80209f:	89 c5                	mov    %eax,%ebp
  8020a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020a5:	31 d2                	xor    %edx,%edx
  8020a7:	f7 f5                	div    %ebp
  8020a9:	89 c8                	mov    %ecx,%eax
  8020ab:	f7 f5                	div    %ebp
  8020ad:	eb 9c                	jmp    80204b <__umoddi3+0x3b>
  8020af:	90                   	nop
  8020b0:	89 c8                	mov    %ecx,%eax
  8020b2:	89 fa                	mov    %edi,%edx
  8020b4:	83 c4 14             	add    $0x14,%esp
  8020b7:	5e                   	pop    %esi
  8020b8:	5f                   	pop    %edi
  8020b9:	5d                   	pop    %ebp
  8020ba:	c3                   	ret    
  8020bb:	90                   	nop
  8020bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	8b 04 24             	mov    (%esp),%eax
  8020c3:	be 20 00 00 00       	mov    $0x20,%esi
  8020c8:	89 e9                	mov    %ebp,%ecx
  8020ca:	29 ee                	sub    %ebp,%esi
  8020cc:	d3 e2                	shl    %cl,%edx
  8020ce:	89 f1                	mov    %esi,%ecx
  8020d0:	d3 e8                	shr    %cl,%eax
  8020d2:	89 e9                	mov    %ebp,%ecx
  8020d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d8:	8b 04 24             	mov    (%esp),%eax
  8020db:	09 54 24 04          	or     %edx,0x4(%esp)
  8020df:	89 fa                	mov    %edi,%edx
  8020e1:	d3 e0                	shl    %cl,%eax
  8020e3:	89 f1                	mov    %esi,%ecx
  8020e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8020ed:	d3 ea                	shr    %cl,%edx
  8020ef:	89 e9                	mov    %ebp,%ecx
  8020f1:	d3 e7                	shl    %cl,%edi
  8020f3:	89 f1                	mov    %esi,%ecx
  8020f5:	d3 e8                	shr    %cl,%eax
  8020f7:	89 e9                	mov    %ebp,%ecx
  8020f9:	09 f8                	or     %edi,%eax
  8020fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8020ff:	f7 74 24 04          	divl   0x4(%esp)
  802103:	d3 e7                	shl    %cl,%edi
  802105:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802109:	89 d7                	mov    %edx,%edi
  80210b:	f7 64 24 08          	mull   0x8(%esp)
  80210f:	39 d7                	cmp    %edx,%edi
  802111:	89 c1                	mov    %eax,%ecx
  802113:	89 14 24             	mov    %edx,(%esp)
  802116:	72 2c                	jb     802144 <__umoddi3+0x134>
  802118:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80211c:	72 22                	jb     802140 <__umoddi3+0x130>
  80211e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802122:	29 c8                	sub    %ecx,%eax
  802124:	19 d7                	sbb    %edx,%edi
  802126:	89 e9                	mov    %ebp,%ecx
  802128:	89 fa                	mov    %edi,%edx
  80212a:	d3 e8                	shr    %cl,%eax
  80212c:	89 f1                	mov    %esi,%ecx
  80212e:	d3 e2                	shl    %cl,%edx
  802130:	89 e9                	mov    %ebp,%ecx
  802132:	d3 ef                	shr    %cl,%edi
  802134:	09 d0                	or     %edx,%eax
  802136:	89 fa                	mov    %edi,%edx
  802138:	83 c4 14             	add    $0x14,%esp
  80213b:	5e                   	pop    %esi
  80213c:	5f                   	pop    %edi
  80213d:	5d                   	pop    %ebp
  80213e:	c3                   	ret    
  80213f:	90                   	nop
  802140:	39 d7                	cmp    %edx,%edi
  802142:	75 da                	jne    80211e <__umoddi3+0x10e>
  802144:	8b 14 24             	mov    (%esp),%edx
  802147:	89 c1                	mov    %eax,%ecx
  802149:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80214d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802151:	eb cb                	jmp    80211e <__umoddi3+0x10e>
  802153:	90                   	nop
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80215c:	0f 82 0f ff ff ff    	jb     802071 <__umoddi3+0x61>
  802162:	e9 1a ff ff ff       	jmp    802081 <__umoddi3+0x71>
