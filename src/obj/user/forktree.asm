
obj/user/forktree.debug：     文件格式 elf32-i386


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
  80002c:	e8 c2 00 00 00       	call   8000f3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 14             	sub    $0x14,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 89 0c 00 00       	call   800ccb <sys_getenvid>
  800042:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004a:	c7 04 24 a0 25 80 00 	movl   $0x8025a0,(%esp)
  800051:	e8 a1 01 00 00       	call   8001f7 <cprintf>

	forkchild(cur, '0');
  800056:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005d:	00 
  80005e:	89 1c 24             	mov    %ebx,(%esp)
  800061:	e8 16 00 00 00       	call   80007c <forkchild>
	forkchild(cur, '1');
  800066:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006d:	00 
  80006e:	89 1c 24             	mov    %ebx,(%esp)
  800071:	e8 06 00 00 00       	call   80007c <forkchild>
}
  800076:	83 c4 14             	add    $0x14,%esp
  800079:	5b                   	pop    %ebx
  80007a:	5d                   	pop    %ebp
  80007b:	c3                   	ret    

0080007c <forkchild>:
{
  80007c:	55                   	push   %ebp
  80007d:	89 e5                	mov    %esp,%ebp
  80007f:	56                   	push   %esi
  800080:	53                   	push   %ebx
  800081:	83 ec 30             	sub    $0x30,%esp
  800084:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800087:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  80008a:	89 1c 24             	mov    %ebx,(%esp)
  80008d:	e8 6e 07 00 00       	call   800800 <strlen>
  800092:	83 f8 02             	cmp    $0x2,%eax
  800095:	7f 41                	jg     8000d8 <forkchild+0x5c>
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800097:	89 f0                	mov    %esi,%eax
  800099:	0f be f0             	movsbl %al,%esi
  80009c:	89 74 24 10          	mov    %esi,0x10(%esp)
  8000a0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a4:	c7 44 24 08 b1 25 80 	movl   $0x8025b1,0x8(%esp)
  8000ab:	00 
  8000ac:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b3:	00 
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	89 04 24             	mov    %eax,(%esp)
  8000ba:	e8 11 07 00 00       	call   8007d0 <snprintf>
	if (fork() == 0) {
  8000bf:	e8 ea 0f 00 00       	call   8010ae <fork>
  8000c4:	85 c0                	test   %eax,%eax
  8000c6:	75 10                	jne    8000d8 <forkchild+0x5c>
		forktree(nxt);
  8000c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000cb:	89 04 24             	mov    %eax,(%esp)
  8000ce:	e8 60 ff ff ff       	call   800033 <forktree>
		exit();
  8000d3:	e8 63 00 00 00       	call   80013b <exit>
}
  8000d8:	83 c4 30             	add    $0x30,%esp
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <umain>:

void
umain(int argc, char **argv)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000e5:	c7 04 24 b0 25 80 00 	movl   $0x8025b0,(%esp)
  8000ec:	e8 42 ff ff ff       	call   800033 <forktree>
}
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    

008000f3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	83 ec 10             	sub    $0x10,%esp
  8000fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fe:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800101:	e8 c5 0b 00 00       	call   800ccb <sys_getenvid>
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800113:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800118:	85 db                	test   %ebx,%ebx
  80011a:	7e 07                	jle    800123 <libmain+0x30>
		binaryname = argv[0];
  80011c:	8b 06                	mov    (%esi),%eax
  80011e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800123:	89 74 24 04          	mov    %esi,0x4(%esp)
  800127:	89 1c 24             	mov    %ebx,(%esp)
  80012a:	e8 b0 ff ff ff       	call   8000df <umain>

	// exit gracefully
	exit();
  80012f:	e8 07 00 00 00       	call   80013b <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800141:	e8 10 14 00 00       	call   801556 <close_all>
	sys_env_destroy(0);
  800146:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014d:	e8 27 0b 00 00       	call   800c79 <sys_env_destroy>
}
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	53                   	push   %ebx
  800158:	83 ec 14             	sub    $0x14,%esp
  80015b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015e:	8b 13                	mov    (%ebx),%edx
  800160:	8d 42 01             	lea    0x1(%edx),%eax
  800163:	89 03                	mov    %eax,(%ebx)
  800165:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800168:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800171:	75 19                	jne    80018c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800173:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80017a:	00 
  80017b:	8d 43 08             	lea    0x8(%ebx),%eax
  80017e:	89 04 24             	mov    %eax,(%esp)
  800181:	e8 b6 0a 00 00       	call   800c3c <sys_cputs>
		b->idx = 0;
  800186:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80018c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800190:	83 c4 14             	add    $0x14,%esp
  800193:	5b                   	pop    %ebx
  800194:	5d                   	pop    %ebp
  800195:	c3                   	ret    

00800196 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80019f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a6:	00 00 00 
	b.cnt = 0;
  8001a9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cb:	c7 04 24 54 01 80 00 	movl   $0x800154,(%esp)
  8001d2:	e8 bd 01 00 00       	call   800394 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e7:	89 04 24             	mov    %eax,(%esp)
  8001ea:	e8 4d 0a 00 00       	call   800c3c <sys_cputs>

	return b.cnt;
}
  8001ef:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800200:	89 44 24 04          	mov    %eax,0x4(%esp)
  800204:	8b 45 08             	mov    0x8(%ebp),%eax
  800207:	89 04 24             	mov    %eax,(%esp)
  80020a:	e8 87 ff ff ff       	call   800196 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020f:	c9                   	leave  
  800210:	c3                   	ret    
  800211:	66 90                	xchg   %ax,%ax
  800213:	66 90                	xchg   %ax,%ax
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
  80029c:	e8 6f 20 00 00       	call   802310 <__udivdi3>
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
  8002f5:	e8 46 21 00 00       	call   802440 <__umoddi3>
  8002fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fe:	0f be 80 c0 25 80 00 	movsbl 0x8025c0(%eax),%eax
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
  80041c:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
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
  8004cf:	8b 14 85 60 28 80 00 	mov    0x802860(,%eax,4),%edx
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	75 20                	jne    8004fa <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  8004da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004de:	c7 44 24 08 d8 25 80 	movl   $0x8025d8,0x8(%esp)
  8004e5:	00 
  8004e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ed:	89 04 24             	mov    %eax,(%esp)
  8004f0:	e8 77 fe ff ff       	call   80036c <printfmt>
  8004f5:	e9 c3 fe ff ff       	jmp    8003bd <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  8004fa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004fe:	c7 44 24 08 13 2b 80 	movl   $0x802b13,0x8(%esp)
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
  80052d:	ba d1 25 80 00       	mov    $0x8025d1,%edx
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
  800ca7:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800cae:	00 
  800caf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb6:	00 
  800cb7:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800cbe:	e8 23 14 00 00       	call   8020e6 <_panic>
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
  800d39:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800d40:	00 
  800d41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d48:	00 
  800d49:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800d50:	e8 91 13 00 00       	call   8020e6 <_panic>
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
  800d8c:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800d93:	00 
  800d94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9b:	00 
  800d9c:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800da3:	e8 3e 13 00 00       	call   8020e6 <_panic>
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
  800ddf:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800de6:	00 
  800de7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dee:	00 
  800def:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800df6:	e8 eb 12 00 00       	call   8020e6 <_panic>
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
  800e32:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800e39:	00 
  800e3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e41:	00 
  800e42:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800e49:	e8 98 12 00 00       	call   8020e6 <_panic>
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
  800e85:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800e8c:	00 
  800e8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e94:	00 
  800e95:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800e9c:	e8 45 12 00 00       	call   8020e6 <_panic>
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
  800ed8:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800edf:	00 
  800ee0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee7:	00 
  800ee8:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800eef:	e8 f2 11 00 00       	call   8020e6 <_panic>
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
  800f4d:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800f54:	00 
  800f55:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5c:	00 
  800f5d:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800f64:	e8 7d 11 00 00       	call   8020e6 <_panic>
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
  800fb5:	c7 44 24 08 ec 28 80 	movl   $0x8028ec,0x8(%esp)
  800fbc:	00 
  800fbd:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800fc4:	00 
  800fc5:	c7 04 24 d3 29 80 00 	movl   $0x8029d3,(%esp)
  800fcc:	e8 15 11 00 00       	call   8020e6 <_panic>
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
  800ff8:	c7 44 24 08 de 29 80 	movl   $0x8029de,0x8(%esp)
  800fff:	00 
  801000:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801007:	00 
  801008:	c7 04 24 d3 29 80 00 	movl   $0x8029d3,(%esp)
  80100f:	e8 d2 10 00 00       	call   8020e6 <_panic>

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
  801058:	c7 44 24 08 fc 29 80 	movl   $0x8029fc,0x8(%esp)
  80105f:	00 
  801060:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801067:	00 
  801068:	c7 04 24 d3 29 80 00 	movl   $0x8029d3,(%esp)
  80106f:	e8 72 10 00 00       	call   8020e6 <_panic>

	if(sys_page_unmap(0, PFTEMP))
  801074:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80107b:	00 
  80107c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801083:	e8 28 fd ff ff       	call   800db0 <sys_page_unmap>
  801088:	85 c0                	test   %eax,%eax
  80108a:	74 1c                	je     8010a8 <pgfault+0x137>
		panic("pgfault: sys_page_unmap error");
  80108c:	c7 44 24 08 18 2a 80 	movl   $0x802a18,0x8(%esp)
  801093:	00 
  801094:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80109b:	00 
  80109c:	c7 04 24 d3 29 80 00 	movl   $0x8029d3,(%esp)
  8010a3:	e8 3e 10 00 00       	call   8020e6 <_panic>
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
  8010be:	e8 79 10 00 00       	call   80213c <set_pgfault_handler>
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
  8010d1:	c7 44 24 08 36 2a 80 	movl   $0x802a36,0x8(%esp)
  8010d8:	00 
  8010d9:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
  8010e0:	00 
  8010e1:	c7 04 24 d3 29 80 00 	movl   $0x8029d3,(%esp)
  8010e8:	e8 f9 0f 00 00       	call   8020e6 <_panic>
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
  801190:	c7 44 24 08 18 29 80 	movl   $0x802918,0x8(%esp)
  801197:	00 
  801198:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80119f:	00 
  8011a0:	c7 04 24 d3 29 80 00 	movl   $0x8029d3,(%esp)
  8011a7:	e8 3a 0f 00 00       	call   8020e6 <_panic>
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
  8011e2:	c7 44 24 08 40 29 80 	movl   $0x802940,0x8(%esp)
  8011e9:	00 
  8011ea:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8011f1:	00 
  8011f2:	c7 04 24 d3 29 80 00 	movl   $0x8029d3,(%esp)
  8011f9:	e8 e8 0e 00 00       	call   8020e6 <_panic>
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
  801226:	c7 44 24 08 64 29 80 	movl   $0x802964,0x8(%esp)
  80122d:	00 
  80122e:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  801235:	00 
  801236:	c7 04 24 d3 29 80 00 	movl   $0x8029d3,(%esp)
  80123d:	e8 a4 0e 00 00       	call   8020e6 <_panic>
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
  801266:	c7 44 24 08 90 29 80 	movl   $0x802990,0x8(%esp)
  80126d:	00 
  80126e:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  801275:	00 
  801276:	c7 04 24 d3 29 80 00 	movl   $0x8029d3,(%esp)
  80127d:	e8 64 0e 00 00       	call   8020e6 <_panic>
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
  8012b3:	c7 44 24 08 4e 2a 80 	movl   $0x802a4e,0x8(%esp)
  8012ba:	00 
  8012bb:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  8012c2:	00 
  8012c3:	c7 04 24 d3 29 80 00 	movl   $0x8029d3,(%esp)
  8012ca:	e8 17 0e 00 00       	call   8020e6 <_panic>
		extern void _pgfault_upcall();
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8012cf:	c7 44 24 04 c5 21 80 	movl   $0x8021c5,0x4(%esp)
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
  8012f6:	c7 44 24 08 b4 29 80 	movl   $0x8029b4,0x8(%esp)
  8012fd:	00 
  8012fe:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801305:	00 
  801306:	c7 04 24 d3 29 80 00 	movl   $0x8029d3,(%esp)
  80130d:	e8 d4 0d 00 00       	call   8020e6 <_panic>
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
  801323:	c7 44 24 08 69 2a 80 	movl   $0x802a69,0x8(%esp)
  80132a:	00 
  80132b:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  801332:	00 
  801333:	c7 04 24 d3 29 80 00 	movl   $0x8029d3,(%esp)
  80133a:	e8 a7 0d 00 00       	call   8020e6 <_panic>
  80133f:	90                   	nop

00801340 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801343:	8b 45 08             	mov    0x8(%ebp),%eax
  801346:	05 00 00 00 30       	add    $0x30000000,%eax
  80134b:	c1 e8 0c             	shr    $0xc,%eax
}
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    

00801350 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801353:	8b 45 08             	mov    0x8(%ebp),%eax
  801356:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80135b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801360:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    

00801367 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80136a:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80136f:	a8 01                	test   $0x1,%al
  801371:	74 34                	je     8013a7 <fd_alloc+0x40>
  801373:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801378:	a8 01                	test   $0x1,%al
  80137a:	74 32                	je     8013ae <fd_alloc+0x47>
  80137c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  801381:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801383:	89 c2                	mov    %eax,%edx
  801385:	c1 ea 16             	shr    $0x16,%edx
  801388:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80138f:	f6 c2 01             	test   $0x1,%dl
  801392:	74 1f                	je     8013b3 <fd_alloc+0x4c>
  801394:	89 c2                	mov    %eax,%edx
  801396:	c1 ea 0c             	shr    $0xc,%edx
  801399:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013a0:	f6 c2 01             	test   $0x1,%dl
  8013a3:	75 1a                	jne    8013bf <fd_alloc+0x58>
  8013a5:	eb 0c                	jmp    8013b3 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  8013a7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8013ac:	eb 05                	jmp    8013b3 <fd_alloc+0x4c>
  8013ae:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  8013b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b6:	89 08                	mov    %ecx,(%eax)
			return 0;
  8013b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013bd:	eb 1a                	jmp    8013d9 <fd_alloc+0x72>
  8013bf:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8013c4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013c9:	75 b6                	jne    801381 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  8013cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8013d4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    

008013db <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013e1:	83 f8 1f             	cmp    $0x1f,%eax
  8013e4:	77 36                	ja     80141c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013e6:	c1 e0 0c             	shl    $0xc,%eax
  8013e9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	c1 ea 16             	shr    $0x16,%edx
  8013f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013fa:	f6 c2 01             	test   $0x1,%dl
  8013fd:	74 24                	je     801423 <fd_lookup+0x48>
  8013ff:	89 c2                	mov    %eax,%edx
  801401:	c1 ea 0c             	shr    $0xc,%edx
  801404:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80140b:	f6 c2 01             	test   $0x1,%dl
  80140e:	74 1a                	je     80142a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801410:	8b 55 0c             	mov    0xc(%ebp),%edx
  801413:	89 02                	mov    %eax,(%edx)
	return 0;
  801415:	b8 00 00 00 00       	mov    $0x0,%eax
  80141a:	eb 13                	jmp    80142f <fd_lookup+0x54>
		return -E_INVAL;
  80141c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801421:	eb 0c                	jmp    80142f <fd_lookup+0x54>
		return -E_INVAL;
  801423:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801428:	eb 05                	jmp    80142f <fd_lookup+0x54>
  80142a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    

00801431 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	53                   	push   %ebx
  801435:	83 ec 14             	sub    $0x14,%esp
  801438:	8b 45 08             	mov    0x8(%ebp),%eax
  80143b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80143e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801444:	75 1e                	jne    801464 <dev_lookup+0x33>
  801446:	eb 0e                	jmp    801456 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  801448:	b8 20 30 80 00       	mov    $0x803020,%eax
  80144d:	eb 0c                	jmp    80145b <dev_lookup+0x2a>
  80144f:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801454:	eb 05                	jmp    80145b <dev_lookup+0x2a>
  801456:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  80145b:	89 03                	mov    %eax,(%ebx)
			return 0;
  80145d:	b8 00 00 00 00       	mov    $0x0,%eax
  801462:	eb 38                	jmp    80149c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  801464:	39 05 20 30 80 00    	cmp    %eax,0x803020
  80146a:	74 dc                	je     801448 <dev_lookup+0x17>
  80146c:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  801472:	74 db                	je     80144f <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801474:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80147a:	8b 52 48             	mov    0x48(%edx),%edx
  80147d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801481:	89 54 24 04          	mov    %edx,0x4(%esp)
  801485:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  80148c:	e8 66 ed ff ff       	call   8001f7 <cprintf>
	*dev = 0;
  801491:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801497:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80149c:	83 c4 14             	add    $0x14,%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5d                   	pop    %ebp
  8014a1:	c3                   	ret    

008014a2 <fd_close>:
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	56                   	push   %esi
  8014a6:	53                   	push   %ebx
  8014a7:	83 ec 20             	sub    $0x20,%esp
  8014aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b3:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014b7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014bd:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014c0:	89 04 24             	mov    %eax,(%esp)
  8014c3:	e8 13 ff ff ff       	call   8013db <fd_lookup>
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 05                	js     8014d1 <fd_close+0x2f>
	    || fd != fd2)
  8014cc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014cf:	74 0c                	je     8014dd <fd_close+0x3b>
		return (must_exist ? r : 0);
  8014d1:	84 db                	test   %bl,%bl
  8014d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d8:	0f 44 c2             	cmove  %edx,%eax
  8014db:	eb 3f                	jmp    80151c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e4:	8b 06                	mov    (%esi),%eax
  8014e6:	89 04 24             	mov    %eax,(%esp)
  8014e9:	e8 43 ff ff ff       	call   801431 <dev_lookup>
  8014ee:	89 c3                	mov    %eax,%ebx
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	78 16                	js     80150a <fd_close+0x68>
		if (dev->dev_close)
  8014f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f7:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8014fa:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8014ff:	85 c0                	test   %eax,%eax
  801501:	74 07                	je     80150a <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801503:	89 34 24             	mov    %esi,(%esp)
  801506:	ff d0                	call   *%eax
  801508:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  80150a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80150e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801515:	e8 96 f8 ff ff       	call   800db0 <sys_page_unmap>
	return r;
  80151a:	89 d8                	mov    %ebx,%eax
}
  80151c:	83 c4 20             	add    $0x20,%esp
  80151f:	5b                   	pop    %ebx
  801520:	5e                   	pop    %esi
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    

00801523 <close>:

int
close(int fdnum)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801529:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801530:	8b 45 08             	mov    0x8(%ebp),%eax
  801533:	89 04 24             	mov    %eax,(%esp)
  801536:	e8 a0 fe ff ff       	call   8013db <fd_lookup>
  80153b:	89 c2                	mov    %eax,%edx
  80153d:	85 d2                	test   %edx,%edx
  80153f:	78 13                	js     801554 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801541:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801548:	00 
  801549:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154c:	89 04 24             	mov    %eax,(%esp)
  80154f:	e8 4e ff ff ff       	call   8014a2 <fd_close>
}
  801554:	c9                   	leave  
  801555:	c3                   	ret    

00801556 <close_all>:

void
close_all(void)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	53                   	push   %ebx
  80155a:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80155d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801562:	89 1c 24             	mov    %ebx,(%esp)
  801565:	e8 b9 ff ff ff       	call   801523 <close>
	for (i = 0; i < MAXFD; i++)
  80156a:	83 c3 01             	add    $0x1,%ebx
  80156d:	83 fb 20             	cmp    $0x20,%ebx
  801570:	75 f0                	jne    801562 <close_all+0xc>
}
  801572:	83 c4 14             	add    $0x14,%esp
  801575:	5b                   	pop    %ebx
  801576:	5d                   	pop    %ebp
  801577:	c3                   	ret    

00801578 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	57                   	push   %edi
  80157c:	56                   	push   %esi
  80157d:	53                   	push   %ebx
  80157e:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801581:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801584:	89 44 24 04          	mov    %eax,0x4(%esp)
  801588:	8b 45 08             	mov    0x8(%ebp),%eax
  80158b:	89 04 24             	mov    %eax,(%esp)
  80158e:	e8 48 fe ff ff       	call   8013db <fd_lookup>
  801593:	89 c2                	mov    %eax,%edx
  801595:	85 d2                	test   %edx,%edx
  801597:	0f 88 e1 00 00 00    	js     80167e <dup+0x106>
		return r;
	close(newfdnum);
  80159d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a0:	89 04 24             	mov    %eax,(%esp)
  8015a3:	e8 7b ff ff ff       	call   801523 <close>

	newfd = INDEX2FD(newfdnum);
  8015a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015ab:	c1 e3 0c             	shl    $0xc,%ebx
  8015ae:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015b7:	89 04 24             	mov    %eax,(%esp)
  8015ba:	e8 91 fd ff ff       	call   801350 <fd2data>
  8015bf:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8015c1:	89 1c 24             	mov    %ebx,(%esp)
  8015c4:	e8 87 fd ff ff       	call   801350 <fd2data>
  8015c9:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015cb:	89 f0                	mov    %esi,%eax
  8015cd:	c1 e8 16             	shr    $0x16,%eax
  8015d0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015d7:	a8 01                	test   $0x1,%al
  8015d9:	74 43                	je     80161e <dup+0xa6>
  8015db:	89 f0                	mov    %esi,%eax
  8015dd:	c1 e8 0c             	shr    $0xc,%eax
  8015e0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015e7:	f6 c2 01             	test   $0x1,%dl
  8015ea:	74 32                	je     80161e <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8015f8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015fc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801600:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801607:	00 
  801608:	89 74 24 04          	mov    %esi,0x4(%esp)
  80160c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801613:	e8 45 f7 ff ff       	call   800d5d <sys_page_map>
  801618:	89 c6                	mov    %eax,%esi
  80161a:	85 c0                	test   %eax,%eax
  80161c:	78 3e                	js     80165c <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80161e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801621:	89 c2                	mov    %eax,%edx
  801623:	c1 ea 0c             	shr    $0xc,%edx
  801626:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80162d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801633:	89 54 24 10          	mov    %edx,0x10(%esp)
  801637:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80163b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801642:	00 
  801643:	89 44 24 04          	mov    %eax,0x4(%esp)
  801647:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164e:	e8 0a f7 ff ff       	call   800d5d <sys_page_map>
  801653:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801655:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801658:	85 f6                	test   %esi,%esi
  80165a:	79 22                	jns    80167e <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80165c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801660:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801667:	e8 44 f7 ff ff       	call   800db0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80166c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801670:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801677:	e8 34 f7 ff ff       	call   800db0 <sys_page_unmap>
	return r;
  80167c:	89 f0                	mov    %esi,%eax
}
  80167e:	83 c4 3c             	add    $0x3c,%esp
  801681:	5b                   	pop    %ebx
  801682:	5e                   	pop    %esi
  801683:	5f                   	pop    %edi
  801684:	5d                   	pop    %ebp
  801685:	c3                   	ret    

00801686 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	53                   	push   %ebx
  80168a:	83 ec 24             	sub    $0x24,%esp
  80168d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801690:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801693:	89 44 24 04          	mov    %eax,0x4(%esp)
  801697:	89 1c 24             	mov    %ebx,(%esp)
  80169a:	e8 3c fd ff ff       	call   8013db <fd_lookup>
  80169f:	89 c2                	mov    %eax,%edx
  8016a1:	85 d2                	test   %edx,%edx
  8016a3:	78 6d                	js     801712 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016af:	8b 00                	mov    (%eax),%eax
  8016b1:	89 04 24             	mov    %eax,(%esp)
  8016b4:	e8 78 fd ff ff       	call   801431 <dev_lookup>
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 55                	js     801712 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c0:	8b 50 08             	mov    0x8(%eax),%edx
  8016c3:	83 e2 03             	and    $0x3,%edx
  8016c6:	83 fa 01             	cmp    $0x1,%edx
  8016c9:	75 23                	jne    8016ee <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016cb:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d0:	8b 40 48             	mov    0x48(%eax),%eax
  8016d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016db:	c7 04 24 c1 2a 80 00 	movl   $0x802ac1,(%esp)
  8016e2:	e8 10 eb ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  8016e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ec:	eb 24                	jmp    801712 <read+0x8c>
	}
	if (!dev->dev_read)
  8016ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f1:	8b 52 08             	mov    0x8(%edx),%edx
  8016f4:	85 d2                	test   %edx,%edx
  8016f6:	74 15                	je     80170d <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801702:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801706:	89 04 24             	mov    %eax,(%esp)
  801709:	ff d2                	call   *%edx
  80170b:	eb 05                	jmp    801712 <read+0x8c>
		return -E_NOT_SUPP;
  80170d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801712:	83 c4 24             	add    $0x24,%esp
  801715:	5b                   	pop    %ebx
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	57                   	push   %edi
  80171c:	56                   	push   %esi
  80171d:	53                   	push   %ebx
  80171e:	83 ec 1c             	sub    $0x1c,%esp
  801721:	8b 7d 08             	mov    0x8(%ebp),%edi
  801724:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801727:	85 f6                	test   %esi,%esi
  801729:	74 33                	je     80175e <readn+0x46>
  80172b:	b8 00 00 00 00       	mov    $0x0,%eax
  801730:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801735:	89 f2                	mov    %esi,%edx
  801737:	29 c2                	sub    %eax,%edx
  801739:	89 54 24 08          	mov    %edx,0x8(%esp)
  80173d:	03 45 0c             	add    0xc(%ebp),%eax
  801740:	89 44 24 04          	mov    %eax,0x4(%esp)
  801744:	89 3c 24             	mov    %edi,(%esp)
  801747:	e8 3a ff ff ff       	call   801686 <read>
		if (m < 0)
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 1b                	js     80176b <readn+0x53>
			return m;
		if (m == 0)
  801750:	85 c0                	test   %eax,%eax
  801752:	74 11                	je     801765 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  801754:	01 c3                	add    %eax,%ebx
  801756:	89 d8                	mov    %ebx,%eax
  801758:	39 f3                	cmp    %esi,%ebx
  80175a:	72 d9                	jb     801735 <readn+0x1d>
  80175c:	eb 0b                	jmp    801769 <readn+0x51>
  80175e:	b8 00 00 00 00       	mov    $0x0,%eax
  801763:	eb 06                	jmp    80176b <readn+0x53>
  801765:	89 d8                	mov    %ebx,%eax
  801767:	eb 02                	jmp    80176b <readn+0x53>
  801769:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80176b:	83 c4 1c             	add    $0x1c,%esp
  80176e:	5b                   	pop    %ebx
  80176f:	5e                   	pop    %esi
  801770:	5f                   	pop    %edi
  801771:	5d                   	pop    %ebp
  801772:	c3                   	ret    

00801773 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	53                   	push   %ebx
  801777:	83 ec 24             	sub    $0x24,%esp
  80177a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801780:	89 44 24 04          	mov    %eax,0x4(%esp)
  801784:	89 1c 24             	mov    %ebx,(%esp)
  801787:	e8 4f fc ff ff       	call   8013db <fd_lookup>
  80178c:	89 c2                	mov    %eax,%edx
  80178e:	85 d2                	test   %edx,%edx
  801790:	78 68                	js     8017fa <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801792:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801795:	89 44 24 04          	mov    %eax,0x4(%esp)
  801799:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179c:	8b 00                	mov    (%eax),%eax
  80179e:	89 04 24             	mov    %eax,(%esp)
  8017a1:	e8 8b fc ff ff       	call   801431 <dev_lookup>
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	78 50                	js     8017fa <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017b1:	75 23                	jne    8017d6 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8017b8:	8b 40 48             	mov    0x48(%eax),%eax
  8017bb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c3:	c7 04 24 dd 2a 80 00 	movl   $0x802add,(%esp)
  8017ca:	e8 28 ea ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  8017cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017d4:	eb 24                	jmp    8017fa <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d9:	8b 52 0c             	mov    0xc(%edx),%edx
  8017dc:	85 d2                	test   %edx,%edx
  8017de:	74 15                	je     8017f5 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ea:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017ee:	89 04 24             	mov    %eax,(%esp)
  8017f1:	ff d2                	call   *%edx
  8017f3:	eb 05                	jmp    8017fa <write+0x87>
		return -E_NOT_SUPP;
  8017f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8017fa:	83 c4 24             	add    $0x24,%esp
  8017fd:	5b                   	pop    %ebx
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <seek>:

int
seek(int fdnum, off_t offset)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801806:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180d:	8b 45 08             	mov    0x8(%ebp),%eax
  801810:	89 04 24             	mov    %eax,(%esp)
  801813:	e8 c3 fb ff ff       	call   8013db <fd_lookup>
  801818:	85 c0                	test   %eax,%eax
  80181a:	78 0e                	js     80182a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80181c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80181f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801822:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801825:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182a:	c9                   	leave  
  80182b:	c3                   	ret    

0080182c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	53                   	push   %ebx
  801830:	83 ec 24             	sub    $0x24,%esp
  801833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801836:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183d:	89 1c 24             	mov    %ebx,(%esp)
  801840:	e8 96 fb ff ff       	call   8013db <fd_lookup>
  801845:	89 c2                	mov    %eax,%edx
  801847:	85 d2                	test   %edx,%edx
  801849:	78 61                	js     8018ac <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801852:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801855:	8b 00                	mov    (%eax),%eax
  801857:	89 04 24             	mov    %eax,(%esp)
  80185a:	e8 d2 fb ff ff       	call   801431 <dev_lookup>
  80185f:	85 c0                	test   %eax,%eax
  801861:	78 49                	js     8018ac <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801863:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801866:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80186a:	75 23                	jne    80188f <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80186c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801871:	8b 40 48             	mov    0x48(%eax),%eax
  801874:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801878:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187c:	c7 04 24 a0 2a 80 00 	movl   $0x802aa0,(%esp)
  801883:	e8 6f e9 ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  801888:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80188d:	eb 1d                	jmp    8018ac <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80188f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801892:	8b 52 18             	mov    0x18(%edx),%edx
  801895:	85 d2                	test   %edx,%edx
  801897:	74 0e                	je     8018a7 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801899:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80189c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018a0:	89 04 24             	mov    %eax,(%esp)
  8018a3:	ff d2                	call   *%edx
  8018a5:	eb 05                	jmp    8018ac <ftruncate+0x80>
		return -E_NOT_SUPP;
  8018a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8018ac:	83 c4 24             	add    $0x24,%esp
  8018af:	5b                   	pop    %ebx
  8018b0:	5d                   	pop    %ebp
  8018b1:	c3                   	ret    

008018b2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	53                   	push   %ebx
  8018b6:	83 ec 24             	sub    $0x24,%esp
  8018b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c6:	89 04 24             	mov    %eax,(%esp)
  8018c9:	e8 0d fb ff ff       	call   8013db <fd_lookup>
  8018ce:	89 c2                	mov    %eax,%edx
  8018d0:	85 d2                	test   %edx,%edx
  8018d2:	78 52                	js     801926 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018de:	8b 00                	mov    (%eax),%eax
  8018e0:	89 04 24             	mov    %eax,(%esp)
  8018e3:	e8 49 fb ff ff       	call   801431 <dev_lookup>
  8018e8:	85 c0                	test   %eax,%eax
  8018ea:	78 3a                	js     801926 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8018ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ef:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018f3:	74 2c                	je     801921 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018f5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018ff:	00 00 00 
	stat->st_isdir = 0;
  801902:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801909:	00 00 00 
	stat->st_dev = dev;
  80190c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801912:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801916:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801919:	89 14 24             	mov    %edx,(%esp)
  80191c:	ff 50 14             	call   *0x14(%eax)
  80191f:	eb 05                	jmp    801926 <fstat+0x74>
		return -E_NOT_SUPP;
  801921:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801926:	83 c4 24             	add    $0x24,%esp
  801929:	5b                   	pop    %ebx
  80192a:	5d                   	pop    %ebp
  80192b:	c3                   	ret    

0080192c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
  801931:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801934:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80193b:	00 
  80193c:	8b 45 08             	mov    0x8(%ebp),%eax
  80193f:	89 04 24             	mov    %eax,(%esp)
  801942:	e8 af 01 00 00       	call   801af6 <open>
  801947:	89 c3                	mov    %eax,%ebx
  801949:	85 db                	test   %ebx,%ebx
  80194b:	78 1b                	js     801968 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80194d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801950:	89 44 24 04          	mov    %eax,0x4(%esp)
  801954:	89 1c 24             	mov    %ebx,(%esp)
  801957:	e8 56 ff ff ff       	call   8018b2 <fstat>
  80195c:	89 c6                	mov    %eax,%esi
	close(fd);
  80195e:	89 1c 24             	mov    %ebx,(%esp)
  801961:	e8 bd fb ff ff       	call   801523 <close>
	return r;
  801966:	89 f0                	mov    %esi,%eax
}
  801968:	83 c4 10             	add    $0x10,%esp
  80196b:	5b                   	pop    %ebx
  80196c:	5e                   	pop    %esi
  80196d:	5d                   	pop    %ebp
  80196e:	c3                   	ret    

0080196f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	56                   	push   %esi
  801973:	53                   	push   %ebx
  801974:	83 ec 10             	sub    $0x10,%esp
  801977:	89 c6                	mov    %eax,%esi
  801979:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80197b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801982:	75 11                	jne    801995 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801984:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80198b:	e8 fd 08 00 00       	call   80228d <ipc_find_env>
  801990:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801995:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80199c:	00 
  80199d:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8019a4:	00 
  8019a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019a9:	a1 00 40 80 00       	mov    0x804000,%eax
  8019ae:	89 04 24             	mov    %eax,(%esp)
  8019b1:	e8 8f 08 00 00       	call   802245 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019bd:	00 
  8019be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c9:	e8 1b 08 00 00       	call   8021e9 <ipc_recv>
}
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	5b                   	pop    %ebx
  8019d2:	5e                   	pop    %esi
  8019d3:	5d                   	pop    %ebp
  8019d4:	c3                   	ret    

008019d5 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	53                   	push   %ebx
  8019d9:	83 ec 14             	sub    $0x14,%esp
  8019dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019df:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ef:	b8 05 00 00 00       	mov    $0x5,%eax
  8019f4:	e8 76 ff ff ff       	call   80196f <fsipc>
  8019f9:	89 c2                	mov    %eax,%edx
  8019fb:	85 d2                	test   %edx,%edx
  8019fd:	78 2b                	js     801a2a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019ff:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a06:	00 
  801a07:	89 1c 24             	mov    %ebx,(%esp)
  801a0a:	e8 4c ee ff ff       	call   80085b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a0f:	a1 80 50 80 00       	mov    0x805080,%eax
  801a14:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a1a:	a1 84 50 80 00       	mov    0x805084,%eax
  801a1f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a2a:	83 c4 14             	add    $0x14,%esp
  801a2d:	5b                   	pop    %ebx
  801a2e:	5d                   	pop    %ebp
  801a2f:	c3                   	ret    

00801a30 <devfile_flush>:
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a36:	8b 45 08             	mov    0x8(%ebp),%eax
  801a39:	8b 40 0c             	mov    0xc(%eax),%eax
  801a3c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a41:	ba 00 00 00 00       	mov    $0x0,%edx
  801a46:	b8 06 00 00 00       	mov    $0x6,%eax
  801a4b:	e8 1f ff ff ff       	call   80196f <fsipc>
}
  801a50:	c9                   	leave  
  801a51:	c3                   	ret    

00801a52 <devfile_read>:
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	56                   	push   %esi
  801a56:	53                   	push   %ebx
  801a57:	83 ec 10             	sub    $0x10,%esp
  801a5a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a60:	8b 40 0c             	mov    0xc(%eax),%eax
  801a63:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a68:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a73:	b8 03 00 00 00       	mov    $0x3,%eax
  801a78:	e8 f2 fe ff ff       	call   80196f <fsipc>
  801a7d:	89 c3                	mov    %eax,%ebx
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	78 6a                	js     801aed <devfile_read+0x9b>
	assert(r <= n);
  801a83:	39 c6                	cmp    %eax,%esi
  801a85:	73 24                	jae    801aab <devfile_read+0x59>
  801a87:	c7 44 24 0c fa 2a 80 	movl   $0x802afa,0xc(%esp)
  801a8e:	00 
  801a8f:	c7 44 24 08 01 2b 80 	movl   $0x802b01,0x8(%esp)
  801a96:	00 
  801a97:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  801a9e:	00 
  801a9f:	c7 04 24 16 2b 80 00 	movl   $0x802b16,(%esp)
  801aa6:	e8 3b 06 00 00       	call   8020e6 <_panic>
	assert(r <= PGSIZE);
  801aab:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ab0:	7e 24                	jle    801ad6 <devfile_read+0x84>
  801ab2:	c7 44 24 0c 21 2b 80 	movl   $0x802b21,0xc(%esp)
  801ab9:	00 
  801aba:	c7 44 24 08 01 2b 80 	movl   $0x802b01,0x8(%esp)
  801ac1:	00 
  801ac2:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801ac9:	00 
  801aca:	c7 04 24 16 2b 80 00 	movl   $0x802b16,(%esp)
  801ad1:	e8 10 06 00 00       	call   8020e6 <_panic>
	memmove(buf, &fsipcbuf, r);
  801ad6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ada:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ae1:	00 
  801ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae5:	89 04 24             	mov    %eax,(%esp)
  801ae8:	e8 69 ef ff ff       	call   800a56 <memmove>
}
  801aed:	89 d8                	mov    %ebx,%eax
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <open>:
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	53                   	push   %ebx
  801afa:	83 ec 24             	sub    $0x24,%esp
  801afd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801b00:	89 1c 24             	mov    %ebx,(%esp)
  801b03:	e8 f8 ec ff ff       	call   800800 <strlen>
  801b08:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b0d:	7f 60                	jg     801b6f <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801b0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b12:	89 04 24             	mov    %eax,(%esp)
  801b15:	e8 4d f8 ff ff       	call   801367 <fd_alloc>
  801b1a:	89 c2                	mov    %eax,%edx
  801b1c:	85 d2                	test   %edx,%edx
  801b1e:	78 54                	js     801b74 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801b20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b24:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b2b:	e8 2b ed ff ff       	call   80085b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b33:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b38:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b3b:	b8 01 00 00 00       	mov    $0x1,%eax
  801b40:	e8 2a fe ff ff       	call   80196f <fsipc>
  801b45:	89 c3                	mov    %eax,%ebx
  801b47:	85 c0                	test   %eax,%eax
  801b49:	79 17                	jns    801b62 <open+0x6c>
		fd_close(fd, 0);
  801b4b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b52:	00 
  801b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b56:	89 04 24             	mov    %eax,(%esp)
  801b59:	e8 44 f9 ff ff       	call   8014a2 <fd_close>
		return r;
  801b5e:	89 d8                	mov    %ebx,%eax
  801b60:	eb 12                	jmp    801b74 <open+0x7e>
	return fd2num(fd);
  801b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b65:	89 04 24             	mov    %eax,(%esp)
  801b68:	e8 d3 f7 ff ff       	call   801340 <fd2num>
  801b6d:	eb 05                	jmp    801b74 <open+0x7e>
		return -E_BAD_PATH;
  801b6f:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801b74:	83 c4 24             	add    $0x24,%esp
  801b77:	5b                   	pop    %ebx
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    
  801b7a:	66 90                	xchg   %ax,%ax
  801b7c:	66 90                	xchg   %ax,%ax
  801b7e:	66 90                	xchg   %ax,%ax

00801b80 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	56                   	push   %esi
  801b84:	53                   	push   %ebx
  801b85:	83 ec 10             	sub    $0x10,%esp
  801b88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	89 04 24             	mov    %eax,(%esp)
  801b91:	e8 ba f7 ff ff       	call   801350 <fd2data>
  801b96:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b98:	c7 44 24 04 2d 2b 80 	movl   $0x802b2d,0x4(%esp)
  801b9f:	00 
  801ba0:	89 1c 24             	mov    %ebx,(%esp)
  801ba3:	e8 b3 ec ff ff       	call   80085b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ba8:	8b 46 04             	mov    0x4(%esi),%eax
  801bab:	2b 06                	sub    (%esi),%eax
  801bad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bb3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bba:	00 00 00 
	stat->st_dev = &devpipe;
  801bbd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bc4:	30 80 00 
	return 0;
}
  801bc7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	5b                   	pop    %ebx
  801bd0:	5e                   	pop    %esi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	53                   	push   %ebx
  801bd7:	83 ec 14             	sub    $0x14,%esp
  801bda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bdd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801be1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be8:	e8 c3 f1 ff ff       	call   800db0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bed:	89 1c 24             	mov    %ebx,(%esp)
  801bf0:	e8 5b f7 ff ff       	call   801350 <fd2data>
  801bf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c00:	e8 ab f1 ff ff       	call   800db0 <sys_page_unmap>
}
  801c05:	83 c4 14             	add    $0x14,%esp
  801c08:	5b                   	pop    %ebx
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    

00801c0b <_pipeisclosed>:
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	57                   	push   %edi
  801c0f:	56                   	push   %esi
  801c10:	53                   	push   %ebx
  801c11:	83 ec 2c             	sub    $0x2c,%esp
  801c14:	89 c6                	mov    %eax,%esi
  801c16:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801c19:	a1 04 40 80 00       	mov    0x804004,%eax
  801c1e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c21:	89 34 24             	mov    %esi,(%esp)
  801c24:	e8 ac 06 00 00       	call   8022d5 <pageref>
  801c29:	89 c7                	mov    %eax,%edi
  801c2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c2e:	89 04 24             	mov    %eax,(%esp)
  801c31:	e8 9f 06 00 00       	call   8022d5 <pageref>
  801c36:	39 c7                	cmp    %eax,%edi
  801c38:	0f 94 c2             	sete   %dl
  801c3b:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801c3e:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801c44:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801c47:	39 fb                	cmp    %edi,%ebx
  801c49:	74 21                	je     801c6c <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801c4b:	84 d2                	test   %dl,%dl
  801c4d:	74 ca                	je     801c19 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c4f:	8b 51 58             	mov    0x58(%ecx),%edx
  801c52:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c56:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c5a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c5e:	c7 04 24 34 2b 80 00 	movl   $0x802b34,(%esp)
  801c65:	e8 8d e5 ff ff       	call   8001f7 <cprintf>
  801c6a:	eb ad                	jmp    801c19 <_pipeisclosed+0xe>
}
  801c6c:	83 c4 2c             	add    $0x2c,%esp
  801c6f:	5b                   	pop    %ebx
  801c70:	5e                   	pop    %esi
  801c71:	5f                   	pop    %edi
  801c72:	5d                   	pop    %ebp
  801c73:	c3                   	ret    

00801c74 <devpipe_write>:
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	57                   	push   %edi
  801c78:	56                   	push   %esi
  801c79:	53                   	push   %ebx
  801c7a:	83 ec 1c             	sub    $0x1c,%esp
  801c7d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c80:	89 34 24             	mov    %esi,(%esp)
  801c83:	e8 c8 f6 ff ff       	call   801350 <fd2data>
	for (i = 0; i < n; i++) {
  801c88:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c8c:	74 61                	je     801cef <devpipe_write+0x7b>
  801c8e:	89 c3                	mov    %eax,%ebx
  801c90:	bf 00 00 00 00       	mov    $0x0,%edi
  801c95:	eb 4a                	jmp    801ce1 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  801c97:	89 da                	mov    %ebx,%edx
  801c99:	89 f0                	mov    %esi,%eax
  801c9b:	e8 6b ff ff ff       	call   801c0b <_pipeisclosed>
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	75 54                	jne    801cf8 <devpipe_write+0x84>
			sys_yield();
  801ca4:	e8 41 f0 ff ff       	call   800cea <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ca9:	8b 43 04             	mov    0x4(%ebx),%eax
  801cac:	8b 0b                	mov    (%ebx),%ecx
  801cae:	8d 51 20             	lea    0x20(%ecx),%edx
  801cb1:	39 d0                	cmp    %edx,%eax
  801cb3:	73 e2                	jae    801c97 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cb8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cbc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cbf:	99                   	cltd   
  801cc0:	c1 ea 1b             	shr    $0x1b,%edx
  801cc3:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801cc6:	83 e1 1f             	and    $0x1f,%ecx
  801cc9:	29 d1                	sub    %edx,%ecx
  801ccb:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801ccf:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801cd3:	83 c0 01             	add    $0x1,%eax
  801cd6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801cd9:	83 c7 01             	add    $0x1,%edi
  801cdc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cdf:	74 13                	je     801cf4 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ce1:	8b 43 04             	mov    0x4(%ebx),%eax
  801ce4:	8b 0b                	mov    (%ebx),%ecx
  801ce6:	8d 51 20             	lea    0x20(%ecx),%edx
  801ce9:	39 d0                	cmp    %edx,%eax
  801ceb:	73 aa                	jae    801c97 <devpipe_write+0x23>
  801ced:	eb c6                	jmp    801cb5 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  801cef:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  801cf4:	89 f8                	mov    %edi,%eax
  801cf6:	eb 05                	jmp    801cfd <devpipe_write+0x89>
				return 0;
  801cf8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cfd:	83 c4 1c             	add    $0x1c,%esp
  801d00:	5b                   	pop    %ebx
  801d01:	5e                   	pop    %esi
  801d02:	5f                   	pop    %edi
  801d03:	5d                   	pop    %ebp
  801d04:	c3                   	ret    

00801d05 <devpipe_read>:
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	57                   	push   %edi
  801d09:	56                   	push   %esi
  801d0a:	53                   	push   %ebx
  801d0b:	83 ec 1c             	sub    $0x1c,%esp
  801d0e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d11:	89 3c 24             	mov    %edi,(%esp)
  801d14:	e8 37 f6 ff ff       	call   801350 <fd2data>
	for (i = 0; i < n; i++) {
  801d19:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d1d:	74 54                	je     801d73 <devpipe_read+0x6e>
  801d1f:	89 c3                	mov    %eax,%ebx
  801d21:	be 00 00 00 00       	mov    $0x0,%esi
  801d26:	eb 3e                	jmp    801d66 <devpipe_read+0x61>
				return i;
  801d28:	89 f0                	mov    %esi,%eax
  801d2a:	eb 55                	jmp    801d81 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  801d2c:	89 da                	mov    %ebx,%edx
  801d2e:	89 f8                	mov    %edi,%eax
  801d30:	e8 d6 fe ff ff       	call   801c0b <_pipeisclosed>
  801d35:	85 c0                	test   %eax,%eax
  801d37:	75 43                	jne    801d7c <devpipe_read+0x77>
			sys_yield();
  801d39:	e8 ac ef ff ff       	call   800cea <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d3e:	8b 03                	mov    (%ebx),%eax
  801d40:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d43:	74 e7                	je     801d2c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d45:	99                   	cltd   
  801d46:	c1 ea 1b             	shr    $0x1b,%edx
  801d49:	01 d0                	add    %edx,%eax
  801d4b:	83 e0 1f             	and    $0x1f,%eax
  801d4e:	29 d0                	sub    %edx,%eax
  801d50:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d58:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d5b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d5e:	83 c6 01             	add    $0x1,%esi
  801d61:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d64:	74 12                	je     801d78 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  801d66:	8b 03                	mov    (%ebx),%eax
  801d68:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d6b:	75 d8                	jne    801d45 <devpipe_read+0x40>
			if (i > 0)
  801d6d:	85 f6                	test   %esi,%esi
  801d6f:	75 b7                	jne    801d28 <devpipe_read+0x23>
  801d71:	eb b9                	jmp    801d2c <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  801d73:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  801d78:	89 f0                	mov    %esi,%eax
  801d7a:	eb 05                	jmp    801d81 <devpipe_read+0x7c>
				return 0;
  801d7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d81:	83 c4 1c             	add    $0x1c,%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5e                   	pop    %esi
  801d86:	5f                   	pop    %edi
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    

00801d89 <pipe>:
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	56                   	push   %esi
  801d8d:	53                   	push   %ebx
  801d8e:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d94:	89 04 24             	mov    %eax,(%esp)
  801d97:	e8 cb f5 ff ff       	call   801367 <fd_alloc>
  801d9c:	89 c2                	mov    %eax,%edx
  801d9e:	85 d2                	test   %edx,%edx
  801da0:	0f 88 4d 01 00 00    	js     801ef3 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dad:	00 
  801dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dbc:	e8 48 ef ff ff       	call   800d09 <sys_page_alloc>
  801dc1:	89 c2                	mov    %eax,%edx
  801dc3:	85 d2                	test   %edx,%edx
  801dc5:	0f 88 28 01 00 00    	js     801ef3 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801dcb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dce:	89 04 24             	mov    %eax,(%esp)
  801dd1:	e8 91 f5 ff ff       	call   801367 <fd_alloc>
  801dd6:	89 c3                	mov    %eax,%ebx
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	0f 88 fe 00 00 00    	js     801ede <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801de7:	00 
  801de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801deb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801def:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df6:	e8 0e ef ff ff       	call   800d09 <sys_page_alloc>
  801dfb:	89 c3                	mov    %eax,%ebx
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	0f 88 d9 00 00 00    	js     801ede <pipe+0x155>
	va = fd2data(fd0);
  801e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e08:	89 04 24             	mov    %eax,(%esp)
  801e0b:	e8 40 f5 ff ff       	call   801350 <fd2data>
  801e10:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e12:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e19:	00 
  801e1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e25:	e8 df ee ff ff       	call   800d09 <sys_page_alloc>
  801e2a:	89 c3                	mov    %eax,%ebx
  801e2c:	85 c0                	test   %eax,%eax
  801e2e:	0f 88 97 00 00 00    	js     801ecb <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e37:	89 04 24             	mov    %eax,(%esp)
  801e3a:	e8 11 f5 ff ff       	call   801350 <fd2data>
  801e3f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e46:	00 
  801e47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e52:	00 
  801e53:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e5e:	e8 fa ee ff ff       	call   800d5d <sys_page_map>
  801e63:	89 c3                	mov    %eax,%ebx
  801e65:	85 c0                	test   %eax,%eax
  801e67:	78 52                	js     801ebb <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801e69:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e72:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e77:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801e7e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e87:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e8c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e96:	89 04 24             	mov    %eax,(%esp)
  801e99:	e8 a2 f4 ff ff       	call   801340 <fd2num>
  801e9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ea1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea6:	89 04 24             	mov    %eax,(%esp)
  801ea9:	e8 92 f4 ff ff       	call   801340 <fd2num>
  801eae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eb1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801eb4:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb9:	eb 38                	jmp    801ef3 <pipe+0x16a>
	sys_page_unmap(0, va);
  801ebb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ebf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec6:	e8 e5 ee ff ff       	call   800db0 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ece:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed9:	e8 d2 ee ff ff       	call   800db0 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eec:	e8 bf ee ff ff       	call   800db0 <sys_page_unmap>
  801ef1:	89 d8                	mov    %ebx,%eax
}
  801ef3:	83 c4 30             	add    $0x30,%esp
  801ef6:	5b                   	pop    %ebx
  801ef7:	5e                   	pop    %esi
  801ef8:	5d                   	pop    %ebp
  801ef9:	c3                   	ret    

00801efa <pipeisclosed>:
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f07:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0a:	89 04 24             	mov    %eax,(%esp)
  801f0d:	e8 c9 f4 ff ff       	call   8013db <fd_lookup>
  801f12:	89 c2                	mov    %eax,%edx
  801f14:	85 d2                	test   %edx,%edx
  801f16:	78 15                	js     801f2d <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1b:	89 04 24             	mov    %eax,(%esp)
  801f1e:	e8 2d f4 ff ff       	call   801350 <fd2data>
	return _pipeisclosed(fd, p);
  801f23:	89 c2                	mov    %eax,%edx
  801f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f28:	e8 de fc ff ff       	call   801c0b <_pipeisclosed>
}
  801f2d:	c9                   	leave  
  801f2e:	c3                   	ret    
  801f2f:	90                   	nop

00801f30 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f33:	b8 00 00 00 00       	mov    $0x0,%eax
  801f38:	5d                   	pop    %ebp
  801f39:	c3                   	ret    

00801f3a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f40:	c7 44 24 04 4c 2b 80 	movl   $0x802b4c,0x4(%esp)
  801f47:	00 
  801f48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4b:	89 04 24             	mov    %eax,(%esp)
  801f4e:	e8 08 e9 ff ff       	call   80085b <strcpy>
	return 0;
}
  801f53:	b8 00 00 00 00       	mov    $0x0,%eax
  801f58:	c9                   	leave  
  801f59:	c3                   	ret    

00801f5a <devcons_write>:
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	57                   	push   %edi
  801f5e:	56                   	push   %esi
  801f5f:	53                   	push   %ebx
  801f60:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f66:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f6a:	74 4a                	je     801fb6 <devcons_write+0x5c>
  801f6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f71:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f76:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  801f7c:	8b 75 10             	mov    0x10(%ebp),%esi
  801f7f:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  801f81:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801f84:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f89:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f8c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f90:	03 45 0c             	add    0xc(%ebp),%eax
  801f93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f97:	89 3c 24             	mov    %edi,(%esp)
  801f9a:	e8 b7 ea ff ff       	call   800a56 <memmove>
		sys_cputs(buf, m);
  801f9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fa3:	89 3c 24             	mov    %edi,(%esp)
  801fa6:	e8 91 ec ff ff       	call   800c3c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801fab:	01 f3                	add    %esi,%ebx
  801fad:	89 d8                	mov    %ebx,%eax
  801faf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fb2:	72 c8                	jb     801f7c <devcons_write+0x22>
  801fb4:	eb 05                	jmp    801fbb <devcons_write+0x61>
  801fb6:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  801fbb:	89 d8                	mov    %ebx,%eax
  801fbd:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    

00801fc8 <devcons_read>:
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801fce:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801fd3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fd7:	75 07                	jne    801fe0 <devcons_read+0x18>
  801fd9:	eb 28                	jmp    802003 <devcons_read+0x3b>
		sys_yield();
  801fdb:	e8 0a ed ff ff       	call   800cea <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801fe0:	e8 75 ec ff ff       	call   800c5a <sys_cgetc>
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	74 f2                	je     801fdb <devcons_read+0x13>
	if (c < 0)
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	78 16                	js     802003 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  801fed:	83 f8 04             	cmp    $0x4,%eax
  801ff0:	74 0c                	je     801ffe <devcons_read+0x36>
	*(char*)vbuf = c;
  801ff2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ff5:	88 02                	mov    %al,(%edx)
	return 1;
  801ff7:	b8 01 00 00 00       	mov    $0x1,%eax
  801ffc:	eb 05                	jmp    802003 <devcons_read+0x3b>
		return 0;
  801ffe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802003:	c9                   	leave  
  802004:	c3                   	ret    

00802005 <cputchar>:
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80200b:	8b 45 08             	mov    0x8(%ebp),%eax
  80200e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802011:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802018:	00 
  802019:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80201c:	89 04 24             	mov    %eax,(%esp)
  80201f:	e8 18 ec ff ff       	call   800c3c <sys_cputs>
}
  802024:	c9                   	leave  
  802025:	c3                   	ret    

00802026 <getchar>:
{
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  80202c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802033:	00 
  802034:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802037:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802042:	e8 3f f6 ff ff       	call   801686 <read>
	if (r < 0)
  802047:	85 c0                	test   %eax,%eax
  802049:	78 0f                	js     80205a <getchar+0x34>
	if (r < 1)
  80204b:	85 c0                	test   %eax,%eax
  80204d:	7e 06                	jle    802055 <getchar+0x2f>
	return c;
  80204f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802053:	eb 05                	jmp    80205a <getchar+0x34>
		return -E_EOF;
  802055:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80205a:	c9                   	leave  
  80205b:	c3                   	ret    

0080205c <iscons>:
{
  80205c:	55                   	push   %ebp
  80205d:	89 e5                	mov    %esp,%ebp
  80205f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802062:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802065:	89 44 24 04          	mov    %eax,0x4(%esp)
  802069:	8b 45 08             	mov    0x8(%ebp),%eax
  80206c:	89 04 24             	mov    %eax,(%esp)
  80206f:	e8 67 f3 ff ff       	call   8013db <fd_lookup>
  802074:	85 c0                	test   %eax,%eax
  802076:	78 11                	js     802089 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  802078:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802081:	39 10                	cmp    %edx,(%eax)
  802083:	0f 94 c0             	sete   %al
  802086:	0f b6 c0             	movzbl %al,%eax
}
  802089:	c9                   	leave  
  80208a:	c3                   	ret    

0080208b <opencons>:
{
  80208b:	55                   	push   %ebp
  80208c:	89 e5                	mov    %esp,%ebp
  80208e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802091:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802094:	89 04 24             	mov    %eax,(%esp)
  802097:	e8 cb f2 ff ff       	call   801367 <fd_alloc>
		return r;
  80209c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80209e:	85 c0                	test   %eax,%eax
  8020a0:	78 40                	js     8020e2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020a2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020a9:	00 
  8020aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020b8:	e8 4c ec ff ff       	call   800d09 <sys_page_alloc>
		return r;
  8020bd:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020bf:	85 c0                	test   %eax,%eax
  8020c1:	78 1f                	js     8020e2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  8020c3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020cc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020d8:	89 04 24             	mov    %eax,(%esp)
  8020db:	e8 60 f2 ff ff       	call   801340 <fd2num>
  8020e0:	89 c2                	mov    %eax,%edx
}
  8020e2:	89 d0                	mov    %edx,%eax
  8020e4:	c9                   	leave  
  8020e5:	c3                   	ret    

008020e6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	56                   	push   %esi
  8020ea:	53                   	push   %ebx
  8020eb:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8020ee:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8020f1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8020f7:	e8 cf eb ff ff       	call   800ccb <sys_getenvid>
  8020fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020ff:	89 54 24 10          	mov    %edx,0x10(%esp)
  802103:	8b 55 08             	mov    0x8(%ebp),%edx
  802106:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80210a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80210e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802112:	c7 04 24 58 2b 80 00 	movl   $0x802b58,(%esp)
  802119:	e8 d9 e0 ff ff       	call   8001f7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80211e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802122:	8b 45 10             	mov    0x10(%ebp),%eax
  802125:	89 04 24             	mov    %eax,(%esp)
  802128:	e8 69 e0 ff ff       	call   800196 <vcprintf>
	cprintf("\n");
  80212d:	c7 04 24 af 25 80 00 	movl   $0x8025af,(%esp)
  802134:	e8 be e0 ff ff       	call   8001f7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802139:	cc                   	int3   
  80213a:	eb fd                	jmp    802139 <_panic+0x53>

0080213c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80213c:	55                   	push   %ebp
  80213d:	89 e5                	mov    %esp,%ebp
  80213f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802142:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802149:	75 70                	jne    8021bb <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  80214b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802152:	00 
  802153:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80215a:	ee 
  80215b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802162:	e8 a2 eb ff ff       	call   800d09 <sys_page_alloc>
  802167:	85 c0                	test   %eax,%eax
  802169:	79 1c                	jns    802187 <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  80216b:	c7 44 24 08 7c 2b 80 	movl   $0x802b7c,0x8(%esp)
  802172:	00 
  802173:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80217a:	00 
  80217b:	c7 04 24 e0 2b 80 00 	movl   $0x802be0,(%esp)
  802182:	e8 5f ff ff ff       	call   8020e6 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802187:	c7 44 24 04 c5 21 80 	movl   $0x8021c5,0x4(%esp)
  80218e:	00 
  80218f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802196:	e8 0e ed ff ff       	call   800ea9 <sys_env_set_pgfault_upcall>
  80219b:	85 c0                	test   %eax,%eax
  80219d:	79 1c                	jns    8021bb <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  80219f:	c7 44 24 08 a8 2b 80 	movl   $0x802ba8,0x8(%esp)
  8021a6:	00 
  8021a7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8021ae:	00 
  8021af:	c7 04 24 e0 2b 80 00 	movl   $0x802be0,(%esp)
  8021b6:	e8 2b ff ff ff       	call   8020e6 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021be:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8021c3:	c9                   	leave  
  8021c4:	c3                   	ret    

008021c5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021c5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021c6:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021cb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021cd:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  8021d0:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  8021d4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  8021d9:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  8021dd:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8021df:	83 c4 08             	add    $0x8,%esp
	popal
  8021e2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8021e3:	83 c4 04             	add    $0x4,%esp
	popfl
  8021e6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8021e7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8021e8:	c3                   	ret    

008021e9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021e9:	55                   	push   %ebp
  8021ea:	89 e5                	mov    %esp,%ebp
  8021ec:	56                   	push   %esi
  8021ed:	53                   	push   %ebx
  8021ee:	83 ec 10             	sub    $0x10,%esp
  8021f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8021f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  8021f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021fa:	89 04 24             	mov    %eax,(%esp)
  8021fd:	e8 1d ed ff ff       	call   800f1f <sys_ipc_recv>
	if(from_env_store)
  802202:	85 f6                	test   %esi,%esi
  802204:	74 14                	je     80221a <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  802206:	ba 00 00 00 00       	mov    $0x0,%edx
  80220b:	85 c0                	test   %eax,%eax
  80220d:	78 09                	js     802218 <ipc_recv+0x2f>
  80220f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802215:	8b 52 74             	mov    0x74(%edx),%edx
  802218:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  80221a:	85 db                	test   %ebx,%ebx
  80221c:	74 14                	je     802232 <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  80221e:	ba 00 00 00 00       	mov    $0x0,%edx
  802223:	85 c0                	test   %eax,%eax
  802225:	78 09                	js     802230 <ipc_recv+0x47>
  802227:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80222d:	8b 52 78             	mov    0x78(%edx),%edx
  802230:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  802232:	85 c0                	test   %eax,%eax
  802234:	78 08                	js     80223e <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  802236:	a1 04 40 80 00       	mov    0x804004,%eax
  80223b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80223e:	83 c4 10             	add    $0x10,%esp
  802241:	5b                   	pop    %ebx
  802242:	5e                   	pop    %esi
  802243:	5d                   	pop    %ebp
  802244:	c3                   	ret    

00802245 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802245:	55                   	push   %ebp
  802246:	89 e5                	mov    %esp,%ebp
  802248:	57                   	push   %edi
  802249:	56                   	push   %esi
  80224a:	53                   	push   %ebx
  80224b:	83 ec 1c             	sub    $0x1c,%esp
  80224e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802251:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  802254:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  802259:	eb 0c                	jmp    802267 <ipc_send+0x22>
		failed_cnt++;
  80225b:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  80225e:	84 db                	test   %bl,%bl
  802260:	75 05                	jne    802267 <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  802262:	e8 83 ea ff ff       	call   800cea <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  802267:	8b 45 14             	mov    0x14(%ebp),%eax
  80226a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80226e:	8b 45 10             	mov    0x10(%ebp),%eax
  802271:	89 44 24 08          	mov    %eax,0x8(%esp)
  802275:	89 74 24 04          	mov    %esi,0x4(%esp)
  802279:	89 3c 24             	mov    %edi,(%esp)
  80227c:	e8 7b ec ff ff       	call   800efc <sys_ipc_try_send>
  802281:	85 c0                	test   %eax,%eax
  802283:	78 d6                	js     80225b <ipc_send+0x16>
	}
}
  802285:	83 c4 1c             	add    $0x1c,%esp
  802288:	5b                   	pop    %ebx
  802289:	5e                   	pop    %esi
  80228a:	5f                   	pop    %edi
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    

0080228d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80228d:	55                   	push   %ebp
  80228e:	89 e5                	mov    %esp,%ebp
  802290:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802293:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  802298:	39 c8                	cmp    %ecx,%eax
  80229a:	74 17                	je     8022b3 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  80229c:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8022a1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022a4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022aa:	8b 52 50             	mov    0x50(%edx),%edx
  8022ad:	39 ca                	cmp    %ecx,%edx
  8022af:	75 14                	jne    8022c5 <ipc_find_env+0x38>
  8022b1:	eb 05                	jmp    8022b8 <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  8022b3:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  8022b8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022bb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022c0:	8b 40 40             	mov    0x40(%eax),%eax
  8022c3:	eb 0e                	jmp    8022d3 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  8022c5:	83 c0 01             	add    $0x1,%eax
  8022c8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022cd:	75 d2                	jne    8022a1 <ipc_find_env+0x14>
	return 0;
  8022cf:	66 b8 00 00          	mov    $0x0,%ax
}
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    

008022d5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022d5:	55                   	push   %ebp
  8022d6:	89 e5                	mov    %esp,%ebp
  8022d8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022db:	89 d0                	mov    %edx,%eax
  8022dd:	c1 e8 16             	shr    $0x16,%eax
  8022e0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022e7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8022ec:	f6 c1 01             	test   $0x1,%cl
  8022ef:	74 1d                	je     80230e <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8022f1:	c1 ea 0c             	shr    $0xc,%edx
  8022f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022fb:	f6 c2 01             	test   $0x1,%dl
  8022fe:	74 0e                	je     80230e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802300:	c1 ea 0c             	shr    $0xc,%edx
  802303:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80230a:	ef 
  80230b:	0f b7 c0             	movzwl %ax,%eax
}
  80230e:	5d                   	pop    %ebp
  80230f:	c3                   	ret    

00802310 <__udivdi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	83 ec 0c             	sub    $0xc,%esp
  802316:	8b 44 24 28          	mov    0x28(%esp),%eax
  80231a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80231e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802322:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802326:	85 c0                	test   %eax,%eax
  802328:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80232c:	89 ea                	mov    %ebp,%edx
  80232e:	89 0c 24             	mov    %ecx,(%esp)
  802331:	75 2d                	jne    802360 <__udivdi3+0x50>
  802333:	39 e9                	cmp    %ebp,%ecx
  802335:	77 61                	ja     802398 <__udivdi3+0x88>
  802337:	85 c9                	test   %ecx,%ecx
  802339:	89 ce                	mov    %ecx,%esi
  80233b:	75 0b                	jne    802348 <__udivdi3+0x38>
  80233d:	b8 01 00 00 00       	mov    $0x1,%eax
  802342:	31 d2                	xor    %edx,%edx
  802344:	f7 f1                	div    %ecx
  802346:	89 c6                	mov    %eax,%esi
  802348:	31 d2                	xor    %edx,%edx
  80234a:	89 e8                	mov    %ebp,%eax
  80234c:	f7 f6                	div    %esi
  80234e:	89 c5                	mov    %eax,%ebp
  802350:	89 f8                	mov    %edi,%eax
  802352:	f7 f6                	div    %esi
  802354:	89 ea                	mov    %ebp,%edx
  802356:	83 c4 0c             	add    $0xc,%esp
  802359:	5e                   	pop    %esi
  80235a:	5f                   	pop    %edi
  80235b:	5d                   	pop    %ebp
  80235c:	c3                   	ret    
  80235d:	8d 76 00             	lea    0x0(%esi),%esi
  802360:	39 e8                	cmp    %ebp,%eax
  802362:	77 24                	ja     802388 <__udivdi3+0x78>
  802364:	0f bd e8             	bsr    %eax,%ebp
  802367:	83 f5 1f             	xor    $0x1f,%ebp
  80236a:	75 3c                	jne    8023a8 <__udivdi3+0x98>
  80236c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802370:	39 34 24             	cmp    %esi,(%esp)
  802373:	0f 86 9f 00 00 00    	jbe    802418 <__udivdi3+0x108>
  802379:	39 d0                	cmp    %edx,%eax
  80237b:	0f 82 97 00 00 00    	jb     802418 <__udivdi3+0x108>
  802381:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802388:	31 d2                	xor    %edx,%edx
  80238a:	31 c0                	xor    %eax,%eax
  80238c:	83 c4 0c             	add    $0xc,%esp
  80238f:	5e                   	pop    %esi
  802390:	5f                   	pop    %edi
  802391:	5d                   	pop    %ebp
  802392:	c3                   	ret    
  802393:	90                   	nop
  802394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802398:	89 f8                	mov    %edi,%eax
  80239a:	f7 f1                	div    %ecx
  80239c:	31 d2                	xor    %edx,%edx
  80239e:	83 c4 0c             	add    $0xc,%esp
  8023a1:	5e                   	pop    %esi
  8023a2:	5f                   	pop    %edi
  8023a3:	5d                   	pop    %ebp
  8023a4:	c3                   	ret    
  8023a5:	8d 76 00             	lea    0x0(%esi),%esi
  8023a8:	89 e9                	mov    %ebp,%ecx
  8023aa:	8b 3c 24             	mov    (%esp),%edi
  8023ad:	d3 e0                	shl    %cl,%eax
  8023af:	89 c6                	mov    %eax,%esi
  8023b1:	b8 20 00 00 00       	mov    $0x20,%eax
  8023b6:	29 e8                	sub    %ebp,%eax
  8023b8:	89 c1                	mov    %eax,%ecx
  8023ba:	d3 ef                	shr    %cl,%edi
  8023bc:	89 e9                	mov    %ebp,%ecx
  8023be:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8023c2:	8b 3c 24             	mov    (%esp),%edi
  8023c5:	09 74 24 08          	or     %esi,0x8(%esp)
  8023c9:	89 d6                	mov    %edx,%esi
  8023cb:	d3 e7                	shl    %cl,%edi
  8023cd:	89 c1                	mov    %eax,%ecx
  8023cf:	89 3c 24             	mov    %edi,(%esp)
  8023d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023d6:	d3 ee                	shr    %cl,%esi
  8023d8:	89 e9                	mov    %ebp,%ecx
  8023da:	d3 e2                	shl    %cl,%edx
  8023dc:	89 c1                	mov    %eax,%ecx
  8023de:	d3 ef                	shr    %cl,%edi
  8023e0:	09 d7                	or     %edx,%edi
  8023e2:	89 f2                	mov    %esi,%edx
  8023e4:	89 f8                	mov    %edi,%eax
  8023e6:	f7 74 24 08          	divl   0x8(%esp)
  8023ea:	89 d6                	mov    %edx,%esi
  8023ec:	89 c7                	mov    %eax,%edi
  8023ee:	f7 24 24             	mull   (%esp)
  8023f1:	39 d6                	cmp    %edx,%esi
  8023f3:	89 14 24             	mov    %edx,(%esp)
  8023f6:	72 30                	jb     802428 <__udivdi3+0x118>
  8023f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023fc:	89 e9                	mov    %ebp,%ecx
  8023fe:	d3 e2                	shl    %cl,%edx
  802400:	39 c2                	cmp    %eax,%edx
  802402:	73 05                	jae    802409 <__udivdi3+0xf9>
  802404:	3b 34 24             	cmp    (%esp),%esi
  802407:	74 1f                	je     802428 <__udivdi3+0x118>
  802409:	89 f8                	mov    %edi,%eax
  80240b:	31 d2                	xor    %edx,%edx
  80240d:	e9 7a ff ff ff       	jmp    80238c <__udivdi3+0x7c>
  802412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802418:	31 d2                	xor    %edx,%edx
  80241a:	b8 01 00 00 00       	mov    $0x1,%eax
  80241f:	e9 68 ff ff ff       	jmp    80238c <__udivdi3+0x7c>
  802424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802428:	8d 47 ff             	lea    -0x1(%edi),%eax
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	83 c4 0c             	add    $0xc,%esp
  802430:	5e                   	pop    %esi
  802431:	5f                   	pop    %edi
  802432:	5d                   	pop    %ebp
  802433:	c3                   	ret    
  802434:	66 90                	xchg   %ax,%ax
  802436:	66 90                	xchg   %ax,%ax
  802438:	66 90                	xchg   %ax,%ax
  80243a:	66 90                	xchg   %ax,%ax
  80243c:	66 90                	xchg   %ax,%ax
  80243e:	66 90                	xchg   %ax,%ax

00802440 <__umoddi3>:
  802440:	55                   	push   %ebp
  802441:	57                   	push   %edi
  802442:	56                   	push   %esi
  802443:	83 ec 14             	sub    $0x14,%esp
  802446:	8b 44 24 28          	mov    0x28(%esp),%eax
  80244a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80244e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802452:	89 c7                	mov    %eax,%edi
  802454:	89 44 24 04          	mov    %eax,0x4(%esp)
  802458:	8b 44 24 30          	mov    0x30(%esp),%eax
  80245c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802460:	89 34 24             	mov    %esi,(%esp)
  802463:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802467:	85 c0                	test   %eax,%eax
  802469:	89 c2                	mov    %eax,%edx
  80246b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80246f:	75 17                	jne    802488 <__umoddi3+0x48>
  802471:	39 fe                	cmp    %edi,%esi
  802473:	76 4b                	jbe    8024c0 <__umoddi3+0x80>
  802475:	89 c8                	mov    %ecx,%eax
  802477:	89 fa                	mov    %edi,%edx
  802479:	f7 f6                	div    %esi
  80247b:	89 d0                	mov    %edx,%eax
  80247d:	31 d2                	xor    %edx,%edx
  80247f:	83 c4 14             	add    $0x14,%esp
  802482:	5e                   	pop    %esi
  802483:	5f                   	pop    %edi
  802484:	5d                   	pop    %ebp
  802485:	c3                   	ret    
  802486:	66 90                	xchg   %ax,%ax
  802488:	39 f8                	cmp    %edi,%eax
  80248a:	77 54                	ja     8024e0 <__umoddi3+0xa0>
  80248c:	0f bd e8             	bsr    %eax,%ebp
  80248f:	83 f5 1f             	xor    $0x1f,%ebp
  802492:	75 5c                	jne    8024f0 <__umoddi3+0xb0>
  802494:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802498:	39 3c 24             	cmp    %edi,(%esp)
  80249b:	0f 87 e7 00 00 00    	ja     802588 <__umoddi3+0x148>
  8024a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024a5:	29 f1                	sub    %esi,%ecx
  8024a7:	19 c7                	sbb    %eax,%edi
  8024a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024ad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024b1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024b5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024b9:	83 c4 14             	add    $0x14,%esp
  8024bc:	5e                   	pop    %esi
  8024bd:	5f                   	pop    %edi
  8024be:	5d                   	pop    %ebp
  8024bf:	c3                   	ret    
  8024c0:	85 f6                	test   %esi,%esi
  8024c2:	89 f5                	mov    %esi,%ebp
  8024c4:	75 0b                	jne    8024d1 <__umoddi3+0x91>
  8024c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024cb:	31 d2                	xor    %edx,%edx
  8024cd:	f7 f6                	div    %esi
  8024cf:	89 c5                	mov    %eax,%ebp
  8024d1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8024d5:	31 d2                	xor    %edx,%edx
  8024d7:	f7 f5                	div    %ebp
  8024d9:	89 c8                	mov    %ecx,%eax
  8024db:	f7 f5                	div    %ebp
  8024dd:	eb 9c                	jmp    80247b <__umoddi3+0x3b>
  8024df:	90                   	nop
  8024e0:	89 c8                	mov    %ecx,%eax
  8024e2:	89 fa                	mov    %edi,%edx
  8024e4:	83 c4 14             	add    $0x14,%esp
  8024e7:	5e                   	pop    %esi
  8024e8:	5f                   	pop    %edi
  8024e9:	5d                   	pop    %ebp
  8024ea:	c3                   	ret    
  8024eb:	90                   	nop
  8024ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	8b 04 24             	mov    (%esp),%eax
  8024f3:	be 20 00 00 00       	mov    $0x20,%esi
  8024f8:	89 e9                	mov    %ebp,%ecx
  8024fa:	29 ee                	sub    %ebp,%esi
  8024fc:	d3 e2                	shl    %cl,%edx
  8024fe:	89 f1                	mov    %esi,%ecx
  802500:	d3 e8                	shr    %cl,%eax
  802502:	89 e9                	mov    %ebp,%ecx
  802504:	89 44 24 04          	mov    %eax,0x4(%esp)
  802508:	8b 04 24             	mov    (%esp),%eax
  80250b:	09 54 24 04          	or     %edx,0x4(%esp)
  80250f:	89 fa                	mov    %edi,%edx
  802511:	d3 e0                	shl    %cl,%eax
  802513:	89 f1                	mov    %esi,%ecx
  802515:	89 44 24 08          	mov    %eax,0x8(%esp)
  802519:	8b 44 24 10          	mov    0x10(%esp),%eax
  80251d:	d3 ea                	shr    %cl,%edx
  80251f:	89 e9                	mov    %ebp,%ecx
  802521:	d3 e7                	shl    %cl,%edi
  802523:	89 f1                	mov    %esi,%ecx
  802525:	d3 e8                	shr    %cl,%eax
  802527:	89 e9                	mov    %ebp,%ecx
  802529:	09 f8                	or     %edi,%eax
  80252b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80252f:	f7 74 24 04          	divl   0x4(%esp)
  802533:	d3 e7                	shl    %cl,%edi
  802535:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802539:	89 d7                	mov    %edx,%edi
  80253b:	f7 64 24 08          	mull   0x8(%esp)
  80253f:	39 d7                	cmp    %edx,%edi
  802541:	89 c1                	mov    %eax,%ecx
  802543:	89 14 24             	mov    %edx,(%esp)
  802546:	72 2c                	jb     802574 <__umoddi3+0x134>
  802548:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80254c:	72 22                	jb     802570 <__umoddi3+0x130>
  80254e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802552:	29 c8                	sub    %ecx,%eax
  802554:	19 d7                	sbb    %edx,%edi
  802556:	89 e9                	mov    %ebp,%ecx
  802558:	89 fa                	mov    %edi,%edx
  80255a:	d3 e8                	shr    %cl,%eax
  80255c:	89 f1                	mov    %esi,%ecx
  80255e:	d3 e2                	shl    %cl,%edx
  802560:	89 e9                	mov    %ebp,%ecx
  802562:	d3 ef                	shr    %cl,%edi
  802564:	09 d0                	or     %edx,%eax
  802566:	89 fa                	mov    %edi,%edx
  802568:	83 c4 14             	add    $0x14,%esp
  80256b:	5e                   	pop    %esi
  80256c:	5f                   	pop    %edi
  80256d:	5d                   	pop    %ebp
  80256e:	c3                   	ret    
  80256f:	90                   	nop
  802570:	39 d7                	cmp    %edx,%edi
  802572:	75 da                	jne    80254e <__umoddi3+0x10e>
  802574:	8b 14 24             	mov    (%esp),%edx
  802577:	89 c1                	mov    %eax,%ecx
  802579:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80257d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802581:	eb cb                	jmp    80254e <__umoddi3+0x10e>
  802583:	90                   	nop
  802584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802588:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80258c:	0f 82 0f ff ff ff    	jb     8024a1 <__umoddi3+0x61>
  802592:	e9 1a ff ff ff       	jmp    8024b1 <__umoddi3+0x71>
