
obj/user/forktree：     文件格式 elf32-i386


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
  80003d:	e8 79 0c 00 00       	call   800cbb <sys_getenvid>
  800042:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004a:	c7 04 24 20 16 80 00 	movl   $0x801620,(%esp)
  800051:	e8 9c 01 00 00       	call   8001f2 <cprintf>

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
  80008d:	e8 5e 07 00 00       	call   8007f0 <strlen>
  800092:	83 f8 02             	cmp    $0x2,%eax
  800095:	7f 41                	jg     8000d8 <forkchild+0x5c>
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800097:	89 f0                	mov    %esi,%eax
  800099:	0f be f0             	movsbl %al,%esi
  80009c:	89 74 24 10          	mov    %esi,0x10(%esp)
  8000a0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a4:	c7 44 24 08 31 16 80 	movl   $0x801631,0x8(%esp)
  8000ab:	00 
  8000ac:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b3:	00 
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	89 04 24             	mov    %eax,(%esp)
  8000ba:	e8 01 07 00 00       	call   8007c0 <snprintf>
	if (fork() == 0) {
  8000bf:	e8 87 0f 00 00       	call   80104b <fork>
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
  8000e5:	c7 04 24 30 16 80 00 	movl   $0x801630,(%esp)
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
  800101:	e8 b5 0b 00 00       	call   800cbb <sys_getenvid>
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800113:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800118:	85 db                	test   %ebx,%ebx
  80011a:	7e 07                	jle    800123 <libmain+0x30>
		binaryname = argv[0];
  80011c:	8b 06                	mov    (%esi),%eax
  80011e:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  800141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800148:	e8 1c 0b 00 00       	call   800c69 <sys_env_destroy>
}
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	53                   	push   %ebx
  800153:	83 ec 14             	sub    $0x14,%esp
  800156:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800159:	8b 13                	mov    (%ebx),%edx
  80015b:	8d 42 01             	lea    0x1(%edx),%eax
  80015e:	89 03                	mov    %eax,(%ebx)
  800160:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800163:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800167:	3d ff 00 00 00       	cmp    $0xff,%eax
  80016c:	75 19                	jne    800187 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80016e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800175:	00 
  800176:	8d 43 08             	lea    0x8(%ebx),%eax
  800179:	89 04 24             	mov    %eax,(%esp)
  80017c:	e8 ab 0a 00 00       	call   800c2c <sys_cputs>
		b->idx = 0;
  800181:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800187:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018b:	83 c4 14             	add    $0x14,%esp
  80018e:	5b                   	pop    %ebx
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80019a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a1:	00 00 00 
	b.cnt = 0;
  8001a4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ab:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001bc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c6:	c7 04 24 4f 01 80 00 	movl   $0x80014f,(%esp)
  8001cd:	e8 b2 01 00 00       	call   800384 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e2:	89 04 24             	mov    %eax,(%esp)
  8001e5:	e8 42 0a 00 00       	call   800c2c <sys_cputs>

	return b.cnt;
}
  8001ea:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f0:	c9                   	leave  
  8001f1:	c3                   	ret    

008001f2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800202:	89 04 24             	mov    %eax,(%esp)
  800205:	e8 87 ff ff ff       	call   800191 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    
  80020c:	66 90                	xchg   %ax,%ax
  80020e:	66 90                	xchg   %ax,%ax

00800210 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 3c             	sub    $0x3c,%esp
  800219:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80021c:	89 d7                	mov    %edx,%edi
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800224:	8b 75 0c             	mov    0xc(%ebp),%esi
  800227:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80022a:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800232:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800235:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800238:	39 f1                	cmp    %esi,%ecx
  80023a:	72 14                	jb     800250 <printnum+0x40>
  80023c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80023f:	76 0f                	jbe    800250 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800241:	8b 45 14             	mov    0x14(%ebp),%eax
  800244:	8d 70 ff             	lea    -0x1(%eax),%esi
  800247:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80024a:	85 f6                	test   %esi,%esi
  80024c:	7f 60                	jg     8002ae <printnum+0x9e>
  80024e:	eb 72                	jmp    8002c2 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800250:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800253:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800257:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80025a:	8d 51 ff             	lea    -0x1(%ecx),%edx
  80025d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800261:	89 44 24 08          	mov    %eax,0x8(%esp)
  800265:	8b 44 24 08          	mov    0x8(%esp),%eax
  800269:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80026d:	89 c3                	mov    %eax,%ebx
  80026f:	89 d6                	mov    %edx,%esi
  800271:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800274:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800277:	89 54 24 08          	mov    %edx,0x8(%esp)
  80027b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80027f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800282:	89 04 24             	mov    %eax,(%esp)
  800285:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	e8 ff 10 00 00       	call   801390 <__udivdi3>
  800291:	89 d9                	mov    %ebx,%ecx
  800293:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800297:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80029b:	89 04 24             	mov    %eax,(%esp)
  80029e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002a2:	89 fa                	mov    %edi,%edx
  8002a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002a7:	e8 64 ff ff ff       	call   800210 <printnum>
  8002ac:	eb 14                	jmp    8002c2 <printnum+0xb2>
			putch(padc, putdat);
  8002ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b2:	8b 45 18             	mov    0x18(%ebp),%eax
  8002b5:	89 04 24             	mov    %eax,(%esp)
  8002b8:	ff d3                	call   *%ebx
		while (--width > 0)
  8002ba:	83 ee 01             	sub    $0x1,%esi
  8002bd:	75 ef                	jne    8002ae <printnum+0x9e>
  8002bf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002cd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002db:	89 04 24             	mov    %eax,(%esp)
  8002de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e5:	e8 d6 11 00 00       	call   8014c0 <__umoddi3>
  8002ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ee:	0f be 80 40 16 80 00 	movsbl 0x801640(%eax),%eax
  8002f5:	89 04 24             	mov    %eax,(%esp)
  8002f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fb:	ff d0                	call   *%eax
}
  8002fd:	83 c4 3c             	add    $0x3c,%esp
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800308:	83 fa 01             	cmp    $0x1,%edx
  80030b:	7e 0e                	jle    80031b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80030d:	8b 10                	mov    (%eax),%edx
  80030f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800312:	89 08                	mov    %ecx,(%eax)
  800314:	8b 02                	mov    (%edx),%eax
  800316:	8b 52 04             	mov    0x4(%edx),%edx
  800319:	eb 22                	jmp    80033d <getuint+0x38>
	else if (lflag)
  80031b:	85 d2                	test   %edx,%edx
  80031d:	74 10                	je     80032f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80031f:	8b 10                	mov    (%eax),%edx
  800321:	8d 4a 04             	lea    0x4(%edx),%ecx
  800324:	89 08                	mov    %ecx,(%eax)
  800326:	8b 02                	mov    (%edx),%eax
  800328:	ba 00 00 00 00       	mov    $0x0,%edx
  80032d:	eb 0e                	jmp    80033d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80032f:	8b 10                	mov    (%eax),%edx
  800331:	8d 4a 04             	lea    0x4(%edx),%ecx
  800334:	89 08                	mov    %ecx,(%eax)
  800336:	8b 02                	mov    (%edx),%eax
  800338:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    

0080033f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800345:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800349:	8b 10                	mov    (%eax),%edx
  80034b:	3b 50 04             	cmp    0x4(%eax),%edx
  80034e:	73 0a                	jae    80035a <sprintputch+0x1b>
		*b->buf++ = ch;
  800350:	8d 4a 01             	lea    0x1(%edx),%ecx
  800353:	89 08                	mov    %ecx,(%eax)
  800355:	8b 45 08             	mov    0x8(%ebp),%eax
  800358:	88 02                	mov    %al,(%edx)
}
  80035a:	5d                   	pop    %ebp
  80035b:	c3                   	ret    

0080035c <printfmt>:
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  800362:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800365:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800369:	8b 45 10             	mov    0x10(%ebp),%eax
  80036c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800370:	8b 45 0c             	mov    0xc(%ebp),%eax
  800373:	89 44 24 04          	mov    %eax,0x4(%esp)
  800377:	8b 45 08             	mov    0x8(%ebp),%eax
  80037a:	89 04 24             	mov    %eax,(%esp)
  80037d:	e8 02 00 00 00       	call   800384 <vprintfmt>
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <vprintfmt>:
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
  80038a:	83 ec 3c             	sub    $0x3c,%esp
  80038d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800390:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800393:	eb 18                	jmp    8003ad <vprintfmt+0x29>
			if (ch == '\0')
  800395:	85 c0                	test   %eax,%eax
  800397:	0f 84 c3 03 00 00    	je     800760 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80039d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003a1:	89 04 24             	mov    %eax,(%esp)
  8003a4:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a7:	89 f3                	mov    %esi,%ebx
  8003a9:	eb 02                	jmp    8003ad <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  8003ab:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ad:	8d 73 01             	lea    0x1(%ebx),%esi
  8003b0:	0f b6 03             	movzbl (%ebx),%eax
  8003b3:	83 f8 25             	cmp    $0x25,%eax
  8003b6:	75 dd                	jne    800395 <vprintfmt+0x11>
  8003b8:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8003bc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003c3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003ca:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d6:	eb 1d                	jmp    8003f5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	89 de                	mov    %ebx,%esi
			padc = '-';
  8003da:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8003de:	eb 15                	jmp    8003f5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	89 de                	mov    %ebx,%esi
			padc = '0';
  8003e2:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8003e6:	eb 0d                	jmp    8003f5 <vprintfmt+0x71>
				width = precision, precision = -1;
  8003e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ee:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003f8:	0f b6 06             	movzbl (%esi),%eax
  8003fb:	0f b6 c8             	movzbl %al,%ecx
  8003fe:	83 e8 23             	sub    $0x23,%eax
  800401:	3c 55                	cmp    $0x55,%al
  800403:	0f 87 2f 03 00 00    	ja     800738 <vprintfmt+0x3b4>
  800409:	0f b6 c0             	movzbl %al,%eax
  80040c:	ff 24 85 00 17 80 00 	jmp    *0x801700(,%eax,4)
				precision = precision * 10 + ch - '0';
  800413:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800416:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  800419:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80041d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800420:	83 f9 09             	cmp    $0x9,%ecx
  800423:	77 50                	ja     800475 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  800425:	89 de                	mov    %ebx,%esi
  800427:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  80042a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80042d:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800430:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800434:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800437:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80043a:	83 fb 09             	cmp    $0x9,%ebx
  80043d:	76 eb                	jbe    80042a <vprintfmt+0xa6>
  80043f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800442:	eb 33                	jmp    800477 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 48 04             	lea    0x4(%eax),%ecx
  80044a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80044d:	8b 00                	mov    (%eax),%eax
  80044f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800452:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800454:	eb 21                	jmp    800477 <vprintfmt+0xf3>
  800456:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800459:	85 c9                	test   %ecx,%ecx
  80045b:	b8 00 00 00 00       	mov    $0x0,%eax
  800460:	0f 49 c1             	cmovns %ecx,%eax
  800463:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800466:	89 de                	mov    %ebx,%esi
  800468:	eb 8b                	jmp    8003f5 <vprintfmt+0x71>
  80046a:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80046c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800473:	eb 80                	jmp    8003f5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800475:	89 de                	mov    %ebx,%esi
			if (width < 0)
  800477:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047b:	0f 89 74 ff ff ff    	jns    8003f5 <vprintfmt+0x71>
  800481:	e9 62 ff ff ff       	jmp    8003e8 <vprintfmt+0x64>
			lflag++;
  800486:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800489:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80048b:	e9 65 ff ff ff       	jmp    8003f5 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8d 50 04             	lea    0x4(%eax),%edx
  800496:	89 55 14             	mov    %edx,0x14(%ebp)
  800499:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	89 04 24             	mov    %eax,(%esp)
  8004a2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004a5:	e9 03 ff ff ff       	jmp    8003ad <vprintfmt+0x29>
			err = va_arg(ap, int);
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	8d 50 04             	lea    0x4(%eax),%edx
  8004b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b3:	8b 00                	mov    (%eax),%eax
  8004b5:	99                   	cltd   
  8004b6:	31 d0                	xor    %edx,%eax
  8004b8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ba:	83 f8 08             	cmp    $0x8,%eax
  8004bd:	7f 0b                	jg     8004ca <vprintfmt+0x146>
  8004bf:	8b 14 85 60 18 80 00 	mov    0x801860(,%eax,4),%edx
  8004c6:	85 d2                	test   %edx,%edx
  8004c8:	75 20                	jne    8004ea <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  8004ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ce:	c7 44 24 08 58 16 80 	movl   $0x801658,0x8(%esp)
  8004d5:	00 
  8004d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004da:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dd:	89 04 24             	mov    %eax,(%esp)
  8004e0:	e8 77 fe ff ff       	call   80035c <printfmt>
  8004e5:	e9 c3 fe ff ff       	jmp    8003ad <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  8004ea:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ee:	c7 44 24 08 61 16 80 	movl   $0x801661,0x8(%esp)
  8004f5:	00 
  8004f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fd:	89 04 24             	mov    %eax,(%esp)
  800500:	e8 57 fe ff ff       	call   80035c <printfmt>
  800505:	e9 a3 fe ff ff       	jmp    8003ad <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80050d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8d 50 04             	lea    0x4(%eax),%edx
  800516:	89 55 14             	mov    %edx,0x14(%ebp)
  800519:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80051b:	85 c0                	test   %eax,%eax
  80051d:	ba 51 16 80 00       	mov    $0x801651,%edx
  800522:	0f 45 d0             	cmovne %eax,%edx
  800525:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800528:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80052c:	74 04                	je     800532 <vprintfmt+0x1ae>
  80052e:	85 f6                	test   %esi,%esi
  800530:	7f 19                	jg     80054b <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800532:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800535:	8d 70 01             	lea    0x1(%eax),%esi
  800538:	0f b6 10             	movzbl (%eax),%edx
  80053b:	0f be c2             	movsbl %dl,%eax
  80053e:	85 c0                	test   %eax,%eax
  800540:	0f 85 95 00 00 00    	jne    8005db <vprintfmt+0x257>
  800546:	e9 85 00 00 00       	jmp    8005d0 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80054b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80054f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800552:	89 04 24             	mov    %eax,(%esp)
  800555:	e8 b8 02 00 00       	call   800812 <strnlen>
  80055a:	29 c6                	sub    %eax,%esi
  80055c:	89 f0                	mov    %esi,%eax
  80055e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800561:	85 f6                	test   %esi,%esi
  800563:	7e cd                	jle    800532 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800565:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800569:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80056c:	89 c3                	mov    %eax,%ebx
  80056e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800572:	89 34 24             	mov    %esi,(%esp)
  800575:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800578:	83 eb 01             	sub    $0x1,%ebx
  80057b:	75 f1                	jne    80056e <vprintfmt+0x1ea>
  80057d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800580:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800583:	eb ad                	jmp    800532 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800585:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800589:	74 1e                	je     8005a9 <vprintfmt+0x225>
  80058b:	0f be d2             	movsbl %dl,%edx
  80058e:	83 ea 20             	sub    $0x20,%edx
  800591:	83 fa 5e             	cmp    $0x5e,%edx
  800594:	76 13                	jbe    8005a9 <vprintfmt+0x225>
					putch('?', putdat);
  800596:	8b 45 0c             	mov    0xc(%ebp),%eax
  800599:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005a4:	ff 55 08             	call   *0x8(%ebp)
  8005a7:	eb 0d                	jmp    8005b6 <vprintfmt+0x232>
					putch(ch, putdat);
  8005a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b6:	83 ef 01             	sub    $0x1,%edi
  8005b9:	83 c6 01             	add    $0x1,%esi
  8005bc:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8005c0:	0f be c2             	movsbl %dl,%eax
  8005c3:	85 c0                	test   %eax,%eax
  8005c5:	75 20                	jne    8005e7 <vprintfmt+0x263>
  8005c7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005ca:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  8005d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d4:	7f 25                	jg     8005fb <vprintfmt+0x277>
  8005d6:	e9 d2 fd ff ff       	jmp    8003ad <vprintfmt+0x29>
  8005db:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005e4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e7:	85 db                	test   %ebx,%ebx
  8005e9:	78 9a                	js     800585 <vprintfmt+0x201>
  8005eb:	83 eb 01             	sub    $0x1,%ebx
  8005ee:	79 95                	jns    800585 <vprintfmt+0x201>
  8005f0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005f3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005f9:	eb d5                	jmp    8005d0 <vprintfmt+0x24c>
  8005fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fe:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800601:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  800604:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800608:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80060f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800611:	83 eb 01             	sub    $0x1,%ebx
  800614:	75 ee                	jne    800604 <vprintfmt+0x280>
  800616:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800619:	e9 8f fd ff ff       	jmp    8003ad <vprintfmt+0x29>
	if (lflag >= 2)
  80061e:	83 fa 01             	cmp    $0x1,%edx
  800621:	7e 16                	jle    800639 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 08             	lea    0x8(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	8b 50 04             	mov    0x4(%eax),%edx
  80062f:	8b 00                	mov    (%eax),%eax
  800631:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800634:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800637:	eb 32                	jmp    80066b <vprintfmt+0x2e7>
	else if (lflag)
  800639:	85 d2                	test   %edx,%edx
  80063b:	74 18                	je     800655 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 50 04             	lea    0x4(%eax),%edx
  800643:	89 55 14             	mov    %edx,0x14(%ebp)
  800646:	8b 30                	mov    (%eax),%esi
  800648:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80064b:	89 f0                	mov    %esi,%eax
  80064d:	c1 f8 1f             	sar    $0x1f,%eax
  800650:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800653:	eb 16                	jmp    80066b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8d 50 04             	lea    0x4(%eax),%edx
  80065b:	89 55 14             	mov    %edx,0x14(%ebp)
  80065e:	8b 30                	mov    (%eax),%esi
  800660:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800663:	89 f0                	mov    %esi,%eax
  800665:	c1 f8 1f             	sar    $0x1f,%eax
  800668:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  80066b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80066e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  800671:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800676:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80067a:	0f 89 80 00 00 00    	jns    800700 <vprintfmt+0x37c>
				putch('-', putdat);
  800680:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800684:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80068b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80068e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800691:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800694:	f7 d8                	neg    %eax
  800696:	83 d2 00             	adc    $0x0,%edx
  800699:	f7 da                	neg    %edx
			base = 10;
  80069b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a0:	eb 5e                	jmp    800700 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8006a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a5:	e8 5b fc ff ff       	call   800305 <getuint>
			base = 10;
  8006aa:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006af:	eb 4f                	jmp    800700 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b4:	e8 4c fc ff ff       	call   800305 <getuint>
			base = 8;
  8006b9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006be:	eb 40                	jmp    800700 <vprintfmt+0x37c>
			putch('0', putdat);
  8006c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006cb:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006d9:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8d 50 04             	lea    0x4(%eax),%edx
  8006e2:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8006e5:	8b 00                	mov    (%eax),%eax
  8006e7:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8006ec:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006f1:	eb 0d                	jmp    800700 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8006f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f6:	e8 0a fc ff ff       	call   800305 <getuint>
			base = 16;
  8006fb:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800700:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800704:	89 74 24 10          	mov    %esi,0x10(%esp)
  800708:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80070b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80070f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800713:	89 04 24             	mov    %eax,(%esp)
  800716:	89 54 24 04          	mov    %edx,0x4(%esp)
  80071a:	89 fa                	mov    %edi,%edx
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	e8 ec fa ff ff       	call   800210 <printnum>
			break;
  800724:	e9 84 fc ff ff       	jmp    8003ad <vprintfmt+0x29>
			putch(ch, putdat);
  800729:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072d:	89 0c 24             	mov    %ecx,(%esp)
  800730:	ff 55 08             	call   *0x8(%ebp)
			break;
  800733:	e9 75 fc ff ff       	jmp    8003ad <vprintfmt+0x29>
			putch('%', putdat);
  800738:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800743:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800746:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80074a:	0f 84 5b fc ff ff    	je     8003ab <vprintfmt+0x27>
  800750:	89 f3                	mov    %esi,%ebx
  800752:	83 eb 01             	sub    $0x1,%ebx
  800755:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800759:	75 f7                	jne    800752 <vprintfmt+0x3ce>
  80075b:	e9 4d fc ff ff       	jmp    8003ad <vprintfmt+0x29>
}
  800760:	83 c4 3c             	add    $0x3c,%esp
  800763:	5b                   	pop    %ebx
  800764:	5e                   	pop    %esi
  800765:	5f                   	pop    %edi
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	83 ec 28             	sub    $0x28,%esp
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800774:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800777:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800785:	85 c0                	test   %eax,%eax
  800787:	74 30                	je     8007b9 <vsnprintf+0x51>
  800789:	85 d2                	test   %edx,%edx
  80078b:	7e 2c                	jle    8007b9 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800794:	8b 45 10             	mov    0x10(%ebp),%eax
  800797:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a2:	c7 04 24 3f 03 80 00 	movl   $0x80033f,(%esp)
  8007a9:	e8 d6 fb ff ff       	call   800384 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b7:	eb 05                	jmp    8007be <vsnprintf+0x56>
		return -E_INVAL;
  8007b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	89 04 24             	mov    %eax,(%esp)
  8007e1:	e8 82 ff ff ff       	call   800768 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e6:	c9                   	leave  
  8007e7:	c3                   	ret    
  8007e8:	66 90                	xchg   %ax,%ax
  8007ea:	66 90                	xchg   %ax,%ax
  8007ec:	66 90                	xchg   %ax,%ax
  8007ee:	66 90                	xchg   %ax,%ax

008007f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007f9:	74 10                	je     80080b <strlen+0x1b>
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800800:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800803:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800807:	75 f7                	jne    800800 <strlen+0x10>
  800809:	eb 05                	jmp    800810 <strlen+0x20>
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800819:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081c:	85 c9                	test   %ecx,%ecx
  80081e:	74 1c                	je     80083c <strnlen+0x2a>
  800820:	80 3b 00             	cmpb   $0x0,(%ebx)
  800823:	74 1e                	je     800843 <strnlen+0x31>
  800825:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80082a:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082c:	39 ca                	cmp    %ecx,%edx
  80082e:	74 18                	je     800848 <strnlen+0x36>
  800830:	83 c2 01             	add    $0x1,%edx
  800833:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800838:	75 f0                	jne    80082a <strnlen+0x18>
  80083a:	eb 0c                	jmp    800848 <strnlen+0x36>
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
  800841:	eb 05                	jmp    800848 <strnlen+0x36>
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800848:	5b                   	pop    %ebx
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800855:	89 c2                	mov    %eax,%edx
  800857:	83 c2 01             	add    $0x1,%edx
  80085a:	83 c1 01             	add    $0x1,%ecx
  80085d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800861:	88 5a ff             	mov    %bl,-0x1(%edx)
  800864:	84 db                	test   %bl,%bl
  800866:	75 ef                	jne    800857 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800868:	5b                   	pop    %ebx
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800875:	89 1c 24             	mov    %ebx,(%esp)
  800878:	e8 73 ff ff ff       	call   8007f0 <strlen>
	strcpy(dst + len, src);
  80087d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800880:	89 54 24 04          	mov    %edx,0x4(%esp)
  800884:	01 d8                	add    %ebx,%eax
  800886:	89 04 24             	mov    %eax,(%esp)
  800889:	e8 bd ff ff ff       	call   80084b <strcpy>
	return dst;
}
  80088e:	89 d8                	mov    %ebx,%eax
  800890:	83 c4 08             	add    $0x8,%esp
  800893:	5b                   	pop    %ebx
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	56                   	push   %esi
  80089a:	53                   	push   %ebx
  80089b:	8b 75 08             	mov    0x8(%ebp),%esi
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a4:	85 db                	test   %ebx,%ebx
  8008a6:	74 17                	je     8008bf <strncpy+0x29>
  8008a8:	01 f3                	add    %esi,%ebx
  8008aa:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8008ac:	83 c1 01             	add    $0x1,%ecx
  8008af:	0f b6 02             	movzbl (%edx),%eax
  8008b2:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b5:	80 3a 01             	cmpb   $0x1,(%edx)
  8008b8:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8008bb:	39 d9                	cmp    %ebx,%ecx
  8008bd:	75 ed                	jne    8008ac <strncpy+0x16>
	}
	return ret;
}
  8008bf:	89 f0                	mov    %esi,%eax
  8008c1:	5b                   	pop    %ebx
  8008c2:	5e                   	pop    %esi
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	57                   	push   %edi
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
  8008cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008d1:	8b 75 10             	mov    0x10(%ebp),%esi
  8008d4:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d6:	85 f6                	test   %esi,%esi
  8008d8:	74 34                	je     80090e <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  8008da:	83 fe 01             	cmp    $0x1,%esi
  8008dd:	74 26                	je     800905 <strlcpy+0x40>
  8008df:	0f b6 0b             	movzbl (%ebx),%ecx
  8008e2:	84 c9                	test   %cl,%cl
  8008e4:	74 23                	je     800909 <strlcpy+0x44>
  8008e6:	83 ee 02             	sub    $0x2,%esi
  8008e9:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  8008ee:	83 c0 01             	add    $0x1,%eax
  8008f1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008f4:	39 f2                	cmp    %esi,%edx
  8008f6:	74 13                	je     80090b <strlcpy+0x46>
  8008f8:	83 c2 01             	add    $0x1,%edx
  8008fb:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ff:	84 c9                	test   %cl,%cl
  800901:	75 eb                	jne    8008ee <strlcpy+0x29>
  800903:	eb 06                	jmp    80090b <strlcpy+0x46>
  800905:	89 f8                	mov    %edi,%eax
  800907:	eb 02                	jmp    80090b <strlcpy+0x46>
  800909:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  80090b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80090e:	29 f8                	sub    %edi,%eax
}
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5f                   	pop    %edi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80091e:	0f b6 01             	movzbl (%ecx),%eax
  800921:	84 c0                	test   %al,%al
  800923:	74 15                	je     80093a <strcmp+0x25>
  800925:	3a 02                	cmp    (%edx),%al
  800927:	75 11                	jne    80093a <strcmp+0x25>
		p++, q++;
  800929:	83 c1 01             	add    $0x1,%ecx
  80092c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80092f:	0f b6 01             	movzbl (%ecx),%eax
  800932:	84 c0                	test   %al,%al
  800934:	74 04                	je     80093a <strcmp+0x25>
  800936:	3a 02                	cmp    (%edx),%al
  800938:	74 ef                	je     800929 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80093a:	0f b6 c0             	movzbl %al,%eax
  80093d:	0f b6 12             	movzbl (%edx),%edx
  800940:	29 d0                	sub    %edx,%eax
}
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80094c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800952:	85 f6                	test   %esi,%esi
  800954:	74 29                	je     80097f <strncmp+0x3b>
  800956:	0f b6 03             	movzbl (%ebx),%eax
  800959:	84 c0                	test   %al,%al
  80095b:	74 30                	je     80098d <strncmp+0x49>
  80095d:	3a 02                	cmp    (%edx),%al
  80095f:	75 2c                	jne    80098d <strncmp+0x49>
  800961:	8d 43 01             	lea    0x1(%ebx),%eax
  800964:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800966:	89 c3                	mov    %eax,%ebx
  800968:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80096b:	39 f0                	cmp    %esi,%eax
  80096d:	74 17                	je     800986 <strncmp+0x42>
  80096f:	0f b6 08             	movzbl (%eax),%ecx
  800972:	84 c9                	test   %cl,%cl
  800974:	74 17                	je     80098d <strncmp+0x49>
  800976:	83 c0 01             	add    $0x1,%eax
  800979:	3a 0a                	cmp    (%edx),%cl
  80097b:	74 e9                	je     800966 <strncmp+0x22>
  80097d:	eb 0e                	jmp    80098d <strncmp+0x49>
	if (n == 0)
		return 0;
  80097f:	b8 00 00 00 00       	mov    $0x0,%eax
  800984:	eb 0f                	jmp    800995 <strncmp+0x51>
  800986:	b8 00 00 00 00       	mov    $0x0,%eax
  80098b:	eb 08                	jmp    800995 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098d:	0f b6 03             	movzbl (%ebx),%eax
  800990:	0f b6 12             	movzbl (%edx),%edx
  800993:	29 d0                	sub    %edx,%eax
}
  800995:	5b                   	pop    %ebx
  800996:	5e                   	pop    %esi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	53                   	push   %ebx
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009a3:	0f b6 18             	movzbl (%eax),%ebx
  8009a6:	84 db                	test   %bl,%bl
  8009a8:	74 1d                	je     8009c7 <strchr+0x2e>
  8009aa:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009ac:	38 d3                	cmp    %dl,%bl
  8009ae:	75 06                	jne    8009b6 <strchr+0x1d>
  8009b0:	eb 1a                	jmp    8009cc <strchr+0x33>
  8009b2:	38 ca                	cmp    %cl,%dl
  8009b4:	74 16                	je     8009cc <strchr+0x33>
	for (; *s; s++)
  8009b6:	83 c0 01             	add    $0x1,%eax
  8009b9:	0f b6 10             	movzbl (%eax),%edx
  8009bc:	84 d2                	test   %dl,%dl
  8009be:	75 f2                	jne    8009b2 <strchr+0x19>
			return (char *) s;
	return 0;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c5:	eb 05                	jmp    8009cc <strchr+0x33>
  8009c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cc:	5b                   	pop    %ebx
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	53                   	push   %ebx
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009d9:	0f b6 18             	movzbl (%eax),%ebx
  8009dc:	84 db                	test   %bl,%bl
  8009de:	74 16                	je     8009f6 <strfind+0x27>
  8009e0:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009e2:	38 d3                	cmp    %dl,%bl
  8009e4:	75 06                	jne    8009ec <strfind+0x1d>
  8009e6:	eb 0e                	jmp    8009f6 <strfind+0x27>
  8009e8:	38 ca                	cmp    %cl,%dl
  8009ea:	74 0a                	je     8009f6 <strfind+0x27>
	for (; *s; s++)
  8009ec:	83 c0 01             	add    $0x1,%eax
  8009ef:	0f b6 10             	movzbl (%eax),%edx
  8009f2:	84 d2                	test   %dl,%dl
  8009f4:	75 f2                	jne    8009e8 <strfind+0x19>
			break;
	return (char *) s;
}
  8009f6:	5b                   	pop    %ebx
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	57                   	push   %edi
  8009fd:	56                   	push   %esi
  8009fe:	53                   	push   %ebx
  8009ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a05:	85 c9                	test   %ecx,%ecx
  800a07:	74 36                	je     800a3f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a09:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0f:	75 28                	jne    800a39 <memset+0x40>
  800a11:	f6 c1 03             	test   $0x3,%cl
  800a14:	75 23                	jne    800a39 <memset+0x40>
		c &= 0xFF;
  800a16:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1a:	89 d3                	mov    %edx,%ebx
  800a1c:	c1 e3 08             	shl    $0x8,%ebx
  800a1f:	89 d6                	mov    %edx,%esi
  800a21:	c1 e6 18             	shl    $0x18,%esi
  800a24:	89 d0                	mov    %edx,%eax
  800a26:	c1 e0 10             	shl    $0x10,%eax
  800a29:	09 f0                	or     %esi,%eax
  800a2b:	09 c2                	or     %eax,%edx
  800a2d:	89 d0                	mov    %edx,%eax
  800a2f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a31:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a34:	fc                   	cld    
  800a35:	f3 ab                	rep stos %eax,%es:(%edi)
  800a37:	eb 06                	jmp    800a3f <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3c:	fc                   	cld    
  800a3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a3f:	89 f8                	mov    %edi,%eax
  800a41:	5b                   	pop    %ebx
  800a42:	5e                   	pop    %esi
  800a43:	5f                   	pop    %edi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	57                   	push   %edi
  800a4a:	56                   	push   %esi
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a51:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a54:	39 c6                	cmp    %eax,%esi
  800a56:	73 35                	jae    800a8d <memmove+0x47>
  800a58:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a5b:	39 d0                	cmp    %edx,%eax
  800a5d:	73 2e                	jae    800a8d <memmove+0x47>
		s += n;
		d += n;
  800a5f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a62:	89 d6                	mov    %edx,%esi
  800a64:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6c:	75 13                	jne    800a81 <memmove+0x3b>
  800a6e:	f6 c1 03             	test   $0x3,%cl
  800a71:	75 0e                	jne    800a81 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a73:	83 ef 04             	sub    $0x4,%edi
  800a76:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a79:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a7c:	fd                   	std    
  800a7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7f:	eb 09                	jmp    800a8a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a81:	83 ef 01             	sub    $0x1,%edi
  800a84:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a87:	fd                   	std    
  800a88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8a:	fc                   	cld    
  800a8b:	eb 1d                	jmp    800aaa <memmove+0x64>
  800a8d:	89 f2                	mov    %esi,%edx
  800a8f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a91:	f6 c2 03             	test   $0x3,%dl
  800a94:	75 0f                	jne    800aa5 <memmove+0x5f>
  800a96:	f6 c1 03             	test   $0x3,%cl
  800a99:	75 0a                	jne    800aa5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a9e:	89 c7                	mov    %eax,%edi
  800aa0:	fc                   	cld    
  800aa1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa3:	eb 05                	jmp    800aaa <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800aa5:	89 c7                	mov    %eax,%edi
  800aa7:	fc                   	cld    
  800aa8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800abb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac5:	89 04 24             	mov    %eax,(%esp)
  800ac8:	e8 79 ff ff ff       	call   800a46 <memmove>
}
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adb:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ade:	8d 78 ff             	lea    -0x1(%eax),%edi
  800ae1:	85 c0                	test   %eax,%eax
  800ae3:	74 36                	je     800b1b <memcmp+0x4c>
		if (*s1 != *s2)
  800ae5:	0f b6 03             	movzbl (%ebx),%eax
  800ae8:	0f b6 0e             	movzbl (%esi),%ecx
  800aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800af0:	38 c8                	cmp    %cl,%al
  800af2:	74 1c                	je     800b10 <memcmp+0x41>
  800af4:	eb 10                	jmp    800b06 <memcmp+0x37>
  800af6:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800afb:	83 c2 01             	add    $0x1,%edx
  800afe:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b02:	38 c8                	cmp    %cl,%al
  800b04:	74 0a                	je     800b10 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b06:	0f b6 c0             	movzbl %al,%eax
  800b09:	0f b6 c9             	movzbl %cl,%ecx
  800b0c:	29 c8                	sub    %ecx,%eax
  800b0e:	eb 10                	jmp    800b20 <memcmp+0x51>
	while (n-- > 0) {
  800b10:	39 fa                	cmp    %edi,%edx
  800b12:	75 e2                	jne    800af6 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800b14:	b8 00 00 00 00       	mov    $0x0,%eax
  800b19:	eb 05                	jmp    800b20 <memcmp+0x51>
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	53                   	push   %ebx
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b2f:	89 c2                	mov    %eax,%edx
  800b31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b34:	39 d0                	cmp    %edx,%eax
  800b36:	73 13                	jae    800b4b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b38:	89 d9                	mov    %ebx,%ecx
  800b3a:	38 18                	cmp    %bl,(%eax)
  800b3c:	75 06                	jne    800b44 <memfind+0x1f>
  800b3e:	eb 0b                	jmp    800b4b <memfind+0x26>
  800b40:	38 08                	cmp    %cl,(%eax)
  800b42:	74 07                	je     800b4b <memfind+0x26>
	for (; s < ends; s++)
  800b44:	83 c0 01             	add    $0x1,%eax
  800b47:	39 d0                	cmp    %edx,%eax
  800b49:	75 f5                	jne    800b40 <memfind+0x1b>
			break;
	return (void *) s;
}
  800b4b:	5b                   	pop    %ebx
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	8b 55 08             	mov    0x8(%ebp),%edx
  800b57:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5a:	0f b6 0a             	movzbl (%edx),%ecx
  800b5d:	80 f9 09             	cmp    $0x9,%cl
  800b60:	74 05                	je     800b67 <strtol+0x19>
  800b62:	80 f9 20             	cmp    $0x20,%cl
  800b65:	75 10                	jne    800b77 <strtol+0x29>
		s++;
  800b67:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b6a:	0f b6 0a             	movzbl (%edx),%ecx
  800b6d:	80 f9 09             	cmp    $0x9,%cl
  800b70:	74 f5                	je     800b67 <strtol+0x19>
  800b72:	80 f9 20             	cmp    $0x20,%cl
  800b75:	74 f0                	je     800b67 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800b77:	80 f9 2b             	cmp    $0x2b,%cl
  800b7a:	75 0a                	jne    800b86 <strtol+0x38>
		s++;
  800b7c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b84:	eb 11                	jmp    800b97 <strtol+0x49>
  800b86:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800b8b:	80 f9 2d             	cmp    $0x2d,%cl
  800b8e:	75 07                	jne    800b97 <strtol+0x49>
		s++, neg = 1;
  800b90:	83 c2 01             	add    $0x1,%edx
  800b93:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b97:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b9c:	75 15                	jne    800bb3 <strtol+0x65>
  800b9e:	80 3a 30             	cmpb   $0x30,(%edx)
  800ba1:	75 10                	jne    800bb3 <strtol+0x65>
  800ba3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ba7:	75 0a                	jne    800bb3 <strtol+0x65>
		s += 2, base = 16;
  800ba9:	83 c2 02             	add    $0x2,%edx
  800bac:	b8 10 00 00 00       	mov    $0x10,%eax
  800bb1:	eb 10                	jmp    800bc3 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	75 0c                	jne    800bc3 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bb7:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800bb9:	80 3a 30             	cmpb   $0x30,(%edx)
  800bbc:	75 05                	jne    800bc3 <strtol+0x75>
		s++, base = 8;
  800bbe:	83 c2 01             	add    $0x1,%edx
  800bc1:	b0 08                	mov    $0x8,%al
		base = 10;
  800bc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc8:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bcb:	0f b6 0a             	movzbl (%edx),%ecx
  800bce:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bd1:	89 f0                	mov    %esi,%eax
  800bd3:	3c 09                	cmp    $0x9,%al
  800bd5:	77 08                	ja     800bdf <strtol+0x91>
			dig = *s - '0';
  800bd7:	0f be c9             	movsbl %cl,%ecx
  800bda:	83 e9 30             	sub    $0x30,%ecx
  800bdd:	eb 20                	jmp    800bff <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800bdf:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800be2:	89 f0                	mov    %esi,%eax
  800be4:	3c 19                	cmp    $0x19,%al
  800be6:	77 08                	ja     800bf0 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800be8:	0f be c9             	movsbl %cl,%ecx
  800beb:	83 e9 57             	sub    $0x57,%ecx
  800bee:	eb 0f                	jmp    800bff <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800bf0:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bf3:	89 f0                	mov    %esi,%eax
  800bf5:	3c 19                	cmp    $0x19,%al
  800bf7:	77 16                	ja     800c0f <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bf9:	0f be c9             	movsbl %cl,%ecx
  800bfc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bff:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c02:	7d 0f                	jge    800c13 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c04:	83 c2 01             	add    $0x1,%edx
  800c07:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c0b:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c0d:	eb bc                	jmp    800bcb <strtol+0x7d>
  800c0f:	89 d8                	mov    %ebx,%eax
  800c11:	eb 02                	jmp    800c15 <strtol+0xc7>
  800c13:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c19:	74 05                	je     800c20 <strtol+0xd2>
		*endptr = (char *) s;
  800c1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c20:	f7 d8                	neg    %eax
  800c22:	85 ff                	test   %edi,%edi
  800c24:	0f 44 c3             	cmove  %ebx,%eax
}
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c32:	b8 00 00 00 00       	mov    $0x0,%eax
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	89 c3                	mov    %eax,%ebx
  800c3f:	89 c7                	mov    %eax,%edi
  800c41:	89 c6                	mov    %eax,%esi
  800c43:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c50:	ba 00 00 00 00       	mov    $0x0,%edx
  800c55:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5a:	89 d1                	mov    %edx,%ecx
  800c5c:	89 d3                	mov    %edx,%ebx
  800c5e:	89 d7                	mov    %edx,%edi
  800c60:	89 d6                	mov    %edx,%esi
  800c62:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c77:	b8 03 00 00 00       	mov    $0x3,%eax
  800c7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7f:	89 cb                	mov    %ecx,%ebx
  800c81:	89 cf                	mov    %ecx,%edi
  800c83:	89 ce                	mov    %ecx,%esi
  800c85:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c87:	85 c0                	test   %eax,%eax
  800c89:	7e 28                	jle    800cb3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c96:	00 
  800c97:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  800c9e:	00 
  800c9f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca6:	00 
  800ca7:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  800cae:	e8 d1 05 00 00       	call   801284 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb3:	83 c4 2c             	add    $0x2c,%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ccb:	89 d1                	mov    %edx,%ecx
  800ccd:	89 d3                	mov    %edx,%ebx
  800ccf:	89 d7                	mov    %edx,%edi
  800cd1:	89 d6                	mov    %edx,%esi
  800cd3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_yield>:

void
sys_yield(void)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cea:	89 d1                	mov    %edx,%ecx
  800cec:	89 d3                	mov    %edx,%ebx
  800cee:	89 d7                	mov    %edx,%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d02:	be 00 00 00 00       	mov    $0x0,%esi
  800d07:	b8 04 00 00 00       	mov    $0x4,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d15:	89 f7                	mov    %esi,%edi
  800d17:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 28                	jle    800d45 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d21:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d28:	00 
  800d29:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  800d30:	00 
  800d31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d38:	00 
  800d39:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  800d40:	e8 3f 05 00 00       	call   801284 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d45:	83 c4 2c             	add    $0x2c,%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d56:	b8 05 00 00 00       	mov    $0x5,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d67:	8b 75 18             	mov    0x18(%ebp),%esi
  800d6a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	7e 28                	jle    800d98 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d70:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d74:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d7b:	00 
  800d7c:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  800d83:	00 
  800d84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8b:	00 
  800d8c:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  800d93:	e8 ec 04 00 00       	call   801284 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d98:	83 c4 2c             	add    $0x2c,%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 06 00 00 00       	mov    $0x6,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 28                	jle    800deb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dce:	00 
  800dcf:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  800dd6:	00 
  800dd7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dde:	00 
  800ddf:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  800de6:	e8 99 04 00 00       	call   801284 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800deb:	83 c4 2c             	add    $0x2c,%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dfc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e01:	b8 08 00 00 00       	mov    $0x8,%eax
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	89 df                	mov    %ebx,%edi
  800e0e:	89 de                	mov    %ebx,%esi
  800e10:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e12:	85 c0                	test   %eax,%eax
  800e14:	7e 28                	jle    800e3e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e21:	00 
  800e22:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  800e29:	00 
  800e2a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e31:	00 
  800e32:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  800e39:	e8 46 04 00 00       	call   801284 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e3e:	83 c4 2c             	add    $0x2c,%esp
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e54:	b8 09 00 00 00       	mov    $0x9,%eax
  800e59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5f:	89 df                	mov    %ebx,%edi
  800e61:	89 de                	mov    %ebx,%esi
  800e63:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e65:	85 c0                	test   %eax,%eax
  800e67:	7e 28                	jle    800e91 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e69:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e74:	00 
  800e75:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  800e7c:	00 
  800e7d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e84:	00 
  800e85:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  800e8c:	e8 f3 03 00 00       	call   801284 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e91:	83 c4 2c             	add    $0x2c,%esp
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	57                   	push   %edi
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e9f:	be 00 00 00 00       	mov    $0x0,%esi
  800ea4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ea9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	57                   	push   %edi
  800ec0:	56                   	push   %esi
  800ec1:	53                   	push   %ebx
  800ec2:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ec5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eca:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ecf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed2:	89 cb                	mov    %ecx,%ebx
  800ed4:	89 cf                	mov    %ecx,%edi
  800ed6:	89 ce                	mov    %ecx,%esi
  800ed8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eda:	85 c0                	test   %eax,%eax
  800edc:	7e 28                	jle    800f06 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ede:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee2:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ee9:	00 
  800eea:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  800ef1:	00 
  800ef2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef9:	00 
  800efa:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  800f01:	e8 7e 03 00 00       	call   801284 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f06:	83 c4 2c             	add    $0x2c,%esp
  800f09:	5b                   	pop    %ebx
  800f0a:	5e                   	pop    %esi
  800f0b:	5f                   	pop    %edi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	53                   	push   %ebx
  800f12:	83 ec 24             	sub    $0x24,%esp
  800f15:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f18:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800f1a:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f1e:	74 2e                	je     800f4e <pgfault+0x40>
  800f20:	89 c2                	mov    %eax,%edx
  800f22:	c1 ea 16             	shr    $0x16,%edx
  800f25:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f2c:	f6 c2 01             	test   $0x1,%dl
  800f2f:	74 1d                	je     800f4e <pgfault+0x40>
  800f31:	89 c2                	mov    %eax,%edx
  800f33:	c1 ea 0c             	shr    $0xc,%edx
  800f36:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f3d:	f6 c1 01             	test   $0x1,%cl
  800f40:	74 0c                	je     800f4e <pgfault+0x40>
  800f42:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f49:	f6 c6 08             	test   $0x8,%dh
  800f4c:	75 20                	jne    800f6e <pgfault+0x60>
		panic("pgfault: page cow check failed, addr=%x\n", addr);
  800f4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f52:	c7 44 24 08 b0 18 80 	movl   $0x8018b0,0x8(%esp)
  800f59:	00 
  800f5a:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800f61:	00 
  800f62:	c7 04 24 6f 19 80 00 	movl   $0x80196f,(%esp)
  800f69:	e8 16 03 00 00       	call   801284 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800f6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f73:	89 c3                	mov    %eax,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W))
  800f75:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f7c:	00 
  800f7d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f84:	00 
  800f85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f8c:	e8 68 fd ff ff       	call   800cf9 <sys_page_alloc>
  800f91:	85 c0                	test   %eax,%eax
  800f93:	74 1c                	je     800fb1 <pgfault+0xa3>
		panic("pgfault: sys_page_alloc error");
  800f95:	c7 44 24 08 7a 19 80 	movl   $0x80197a,0x8(%esp)
  800f9c:	00 
  800f9d:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800fa4:	00 
  800fa5:	c7 04 24 6f 19 80 00 	movl   $0x80196f,(%esp)
  800fac:	e8 d3 02 00 00       	call   801284 <_panic>

	memmove(PFTEMP, addr, PGSIZE);
  800fb1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fb8:	00 
  800fb9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fbd:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fc4:	e8 7d fa ff ff       	call   800a46 <memmove>
	if(sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))
  800fc9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fd0:	00 
  800fd1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fd5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fdc:	00 
  800fdd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fe4:	00 
  800fe5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fec:	e8 5c fd ff ff       	call   800d4d <sys_page_map>
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	74 1c                	je     801011 <pgfault+0x103>
		panic("pgfault: sys_page_map error");
  800ff5:	c7 44 24 08 98 19 80 	movl   $0x801998,0x8(%esp)
  800ffc:	00 
  800ffd:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801004:	00 
  801005:	c7 04 24 6f 19 80 00 	movl   $0x80196f,(%esp)
  80100c:	e8 73 02 00 00       	call   801284 <_panic>

	if(sys_page_unmap(0, PFTEMP))
  801011:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801018:	00 
  801019:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801020:	e8 7b fd ff ff       	call   800da0 <sys_page_unmap>
  801025:	85 c0                	test   %eax,%eax
  801027:	74 1c                	je     801045 <pgfault+0x137>
		panic("pgfault: sys_page_unmap error");
  801029:	c7 44 24 08 b4 19 80 	movl   $0x8019b4,0x8(%esp)
  801030:	00 
  801031:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801038:	00 
  801039:	c7 04 24 6f 19 80 00 	movl   $0x80196f,(%esp)
  801040:	e8 3f 02 00 00       	call   801284 <_panic>
}
  801045:	83 c4 24             	add    $0x24,%esp
  801048:	5b                   	pop    %ebx
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    

0080104b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
  801051:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	//根据文档的描述，duppage好像不应该处理除了可写或者copy-on-write的部分，但这里都交给duppage一块处理了
	set_pgfault_handler(pgfault);
  801054:	c7 04 24 0e 0f 80 00 	movl   $0x800f0e,(%esp)
  80105b:	e8 7a 02 00 00       	call   8012da <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801060:	b8 07 00 00 00       	mov    $0x7,%eax
  801065:	cd 30                	int    $0x30
  801067:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();
	if(envid < 0)
  80106a:	85 c0                	test   %eax,%eax
  80106c:	79 1c                	jns    80108a <fork+0x3f>
		//失败
		panic("fork: sys_exofork error");
  80106e:	c7 44 24 08 d2 19 80 	movl   $0x8019d2,0x8(%esp)
  801075:	00 
  801076:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  80107d:	00 
  80107e:	c7 04 24 6f 19 80 00 	movl   $0x80196f,(%esp)
  801085:	e8 fa 01 00 00       	call   801284 <_panic>
  80108a:	89 c7                	mov    %eax,%edi
	else if(!envid)
  80108c:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801091:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801095:	75 1c                	jne    8010b3 <fork+0x68>
		//子进程
		thisenv = &envs[ENVX(sys_getenvid())];
  801097:	e8 1f fc ff ff       	call   800cbb <sys_getenvid>
  80109c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010a9:	a3 04 20 80 00       	mov    %eax,0x802004
  8010ae:	e9 a4 01 00 00       	jmp    801257 <fork+0x20c>
	else{
		//父进程
		unsigned addr;
		for(addr = UTEXT; addr < USTACKTOP; addr+= PGSIZE){
			if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))
  8010b3:	89 d8                	mov    %ebx,%eax
  8010b5:	c1 e8 16             	shr    $0x16,%eax
  8010b8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010bf:	a8 01                	test   $0x1,%al
  8010c1:	0f 84 00 01 00 00    	je     8011c7 <fork+0x17c>
  8010c7:	89 d8                	mov    %ebx,%eax
  8010c9:	c1 e8 0c             	shr    $0xc,%eax
  8010cc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010d3:	f6 c2 01             	test   $0x1,%dl
  8010d6:	0f 84 eb 00 00 00    	je     8011c7 <fork+0x17c>
  8010dc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e3:	f6 c2 04             	test   $0x4,%dl
  8010e6:	0f 84 db 00 00 00    	je     8011c7 <fork+0x17c>
	void *addr = (void *)(pn * PGSIZE);
  8010ec:	89 c6                	mov    %eax,%esi
  8010ee:	c1 e6 0c             	shl    $0xc,%esi
	if(uvpt[pn] & (PTE_W | PTE_COW)){
  8010f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f8:	a9 02 08 00 00       	test   $0x802,%eax
  8010fd:	0f 84 84 00 00 00    	je     801187 <fork+0x13c>
		if(sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P))
  801103:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80110a:	00 
  80110b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80110f:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801113:	89 74 24 04          	mov    %esi,0x4(%esp)
  801117:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80111e:	e8 2a fc ff ff       	call   800d4d <sys_page_map>
  801123:	85 c0                	test   %eax,%eax
  801125:	74 1c                	je     801143 <fork+0xf8>
			panic("duppage: sys_page_map child error");
  801127:	c7 44 24 08 dc 18 80 	movl   $0x8018dc,0x8(%esp)
  80112e:	00 
  80112f:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801136:	00 
  801137:	c7 04 24 6f 19 80 00 	movl   $0x80196f,(%esp)
  80113e:	e8 41 01 00 00       	call   801284 <_panic>
		if(sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P))
  801143:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80114a:	00 
  80114b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80114f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801156:	00 
  801157:	89 74 24 04          	mov    %esi,0x4(%esp)
  80115b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801162:	e8 e6 fb ff ff       	call   800d4d <sys_page_map>
  801167:	85 c0                	test   %eax,%eax
  801169:	74 5c                	je     8011c7 <fork+0x17c>
			panic("duppage: sys_page_map remap parent error");
  80116b:	c7 44 24 08 00 19 80 	movl   $0x801900,0x8(%esp)
  801172:	00 
  801173:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  80117a:	00 
  80117b:	c7 04 24 6f 19 80 00 	movl   $0x80196f,(%esp)
  801182:	e8 fd 00 00 00       	call   801284 <_panic>
		if(sys_page_map(0, addr, envid, addr, PTE_U|PTE_P))
  801187:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80118e:	00 
  80118f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801193:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801197:	89 74 24 04          	mov    %esi,0x4(%esp)
  80119b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011a2:	e8 a6 fb ff ff       	call   800d4d <sys_page_map>
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	74 1c                	je     8011c7 <fork+0x17c>
			panic("duppage: other sys_page_map error");
  8011ab:	c7 44 24 08 2c 19 80 	movl   $0x80192c,0x8(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8011ba:	00 
  8011bb:	c7 04 24 6f 19 80 00 	movl   $0x80196f,(%esp)
  8011c2:	e8 bd 00 00 00       	call   801284 <_panic>
		for(addr = UTEXT; addr < USTACKTOP; addr+= PGSIZE){
  8011c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011cd:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011d3:	0f 85 da fe ff ff    	jne    8010b3 <fork+0x68>
				duppage(envid, PGNUM(addr));
		}
		if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W))
  8011d9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011e0:	00 
  8011e1:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011e8:	ee 
  8011e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011ec:	89 04 24             	mov    %eax,(%esp)
  8011ef:	e8 05 fb ff ff       	call   800cf9 <sys_page_alloc>
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	74 1c                	je     801214 <fork+0x1c9>
			panic("fork: sys_page_alloc error");
  8011f8:	c7 44 24 08 ea 19 80 	movl   $0x8019ea,0x8(%esp)
  8011ff:	00 
  801200:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  801207:	00 
  801208:	c7 04 24 6f 19 80 00 	movl   $0x80196f,(%esp)
  80120f:	e8 70 00 00 00       	call   801284 <_panic>
		extern void _pgfault_upcall();
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801214:	c7 44 24 04 63 13 80 	movl   $0x801363,0x4(%esp)
  80121b:	00 
  80121c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80121f:	89 3c 24             	mov    %edi,(%esp)
  801222:	e8 1f fc ff ff       	call   800e46 <sys_env_set_pgfault_upcall>
		if(sys_env_set_status(envid, ENV_RUNNABLE))
  801227:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80122e:	00 
  80122f:	89 3c 24             	mov    %edi,(%esp)
  801232:	e8 bc fb ff ff       	call   800df3 <sys_env_set_status>
  801237:	85 c0                	test   %eax,%eax
  801239:	74 1c                	je     801257 <fork+0x20c>
			panic("fork: sys_env_set_status error");
  80123b:	c7 44 24 08 50 19 80 	movl   $0x801950,0x8(%esp)
  801242:	00 
  801243:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  80124a:	00 
  80124b:	c7 04 24 6f 19 80 00 	movl   $0x80196f,(%esp)
  801252:	e8 2d 00 00 00       	call   801284 <_panic>
	}
	return envid;
}
  801257:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80125a:	83 c4 2c             	add    $0x2c,%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5f                   	pop    %edi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <sfork>:

// Challenge!
int
sfork(void)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801268:	c7 44 24 08 05 1a 80 	movl   $0x801a05,0x8(%esp)
  80126f:	00 
  801270:	c7 44 24 04 87 00 00 	movl   $0x87,0x4(%esp)
  801277:	00 
  801278:	c7 04 24 6f 19 80 00 	movl   $0x80196f,(%esp)
  80127f:	e8 00 00 00 00       	call   801284 <_panic>

00801284 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	56                   	push   %esi
  801288:	53                   	push   %ebx
  801289:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80128c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80128f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801295:	e8 21 fa ff ff       	call   800cbb <sys_getenvid>
  80129a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012a8:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b0:	c7 04 24 1c 1a 80 00 	movl   $0x801a1c,(%esp)
  8012b7:	e8 36 ef ff ff       	call   8001f2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8012c3:	89 04 24             	mov    %eax,(%esp)
  8012c6:	e8 c6 ee ff ff       	call   800191 <vcprintf>
	cprintf("\n");
  8012cb:	c7 04 24 2f 16 80 00 	movl   $0x80162f,(%esp)
  8012d2:	e8 1b ef ff ff       	call   8001f2 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012d7:	cc                   	int3   
  8012d8:	eb fd                	jmp    8012d7 <_panic+0x53>

008012da <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012e0:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8012e7:	75 70                	jne    801359 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  8012e9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012f0:	00 
  8012f1:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012f8:	ee 
  8012f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801300:	e8 f4 f9 ff ff       	call   800cf9 <sys_page_alloc>
  801305:	85 c0                	test   %eax,%eax
  801307:	79 1c                	jns    801325 <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  801309:	c7 44 24 08 40 1a 80 	movl   $0x801a40,0x8(%esp)
  801310:	00 
  801311:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801318:	00 
  801319:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  801320:	e8 5f ff ff ff       	call   801284 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801325:	c7 44 24 04 63 13 80 	movl   $0x801363,0x4(%esp)
  80132c:	00 
  80132d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801334:	e8 0d fb ff ff       	call   800e46 <sys_env_set_pgfault_upcall>
  801339:	85 c0                	test   %eax,%eax
  80133b:	79 1c                	jns    801359 <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  80133d:	c7 44 24 08 6c 1a 80 	movl   $0x801a6c,0x8(%esp)
  801344:	00 
  801345:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  80134c:	00 
  80134d:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  801354:	e8 2b ff ff ff       	call   801284 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801359:	8b 45 08             	mov    0x8(%ebp),%eax
  80135c:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801361:	c9                   	leave  
  801362:	c3                   	ret    

00801363 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801363:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801364:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801369:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80136b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  80136e:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  801372:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  801377:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  80137b:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80137d:	83 c4 08             	add    $0x8,%esp
	popal
  801380:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801381:	83 c4 04             	add    $0x4,%esp
	popfl
  801384:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801385:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801386:	c3                   	ret    
  801387:	66 90                	xchg   %ax,%ax
  801389:	66 90                	xchg   %ax,%ax
  80138b:	66 90                	xchg   %ax,%ax
  80138d:	66 90                	xchg   %ax,%ax
  80138f:	90                   	nop

00801390 <__udivdi3>:
  801390:	55                   	push   %ebp
  801391:	57                   	push   %edi
  801392:	56                   	push   %esi
  801393:	83 ec 0c             	sub    $0xc,%esp
  801396:	8b 44 24 28          	mov    0x28(%esp),%eax
  80139a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80139e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8013a2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013ac:	89 ea                	mov    %ebp,%edx
  8013ae:	89 0c 24             	mov    %ecx,(%esp)
  8013b1:	75 2d                	jne    8013e0 <__udivdi3+0x50>
  8013b3:	39 e9                	cmp    %ebp,%ecx
  8013b5:	77 61                	ja     801418 <__udivdi3+0x88>
  8013b7:	85 c9                	test   %ecx,%ecx
  8013b9:	89 ce                	mov    %ecx,%esi
  8013bb:	75 0b                	jne    8013c8 <__udivdi3+0x38>
  8013bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8013c2:	31 d2                	xor    %edx,%edx
  8013c4:	f7 f1                	div    %ecx
  8013c6:	89 c6                	mov    %eax,%esi
  8013c8:	31 d2                	xor    %edx,%edx
  8013ca:	89 e8                	mov    %ebp,%eax
  8013cc:	f7 f6                	div    %esi
  8013ce:	89 c5                	mov    %eax,%ebp
  8013d0:	89 f8                	mov    %edi,%eax
  8013d2:	f7 f6                	div    %esi
  8013d4:	89 ea                	mov    %ebp,%edx
  8013d6:	83 c4 0c             	add    $0xc,%esp
  8013d9:	5e                   	pop    %esi
  8013da:	5f                   	pop    %edi
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    
  8013dd:	8d 76 00             	lea    0x0(%esi),%esi
  8013e0:	39 e8                	cmp    %ebp,%eax
  8013e2:	77 24                	ja     801408 <__udivdi3+0x78>
  8013e4:	0f bd e8             	bsr    %eax,%ebp
  8013e7:	83 f5 1f             	xor    $0x1f,%ebp
  8013ea:	75 3c                	jne    801428 <__udivdi3+0x98>
  8013ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8013f0:	39 34 24             	cmp    %esi,(%esp)
  8013f3:	0f 86 9f 00 00 00    	jbe    801498 <__udivdi3+0x108>
  8013f9:	39 d0                	cmp    %edx,%eax
  8013fb:	0f 82 97 00 00 00    	jb     801498 <__udivdi3+0x108>
  801401:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801408:	31 d2                	xor    %edx,%edx
  80140a:	31 c0                	xor    %eax,%eax
  80140c:	83 c4 0c             	add    $0xc,%esp
  80140f:	5e                   	pop    %esi
  801410:	5f                   	pop    %edi
  801411:	5d                   	pop    %ebp
  801412:	c3                   	ret    
  801413:	90                   	nop
  801414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801418:	89 f8                	mov    %edi,%eax
  80141a:	f7 f1                	div    %ecx
  80141c:	31 d2                	xor    %edx,%edx
  80141e:	83 c4 0c             	add    $0xc,%esp
  801421:	5e                   	pop    %esi
  801422:	5f                   	pop    %edi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    
  801425:	8d 76 00             	lea    0x0(%esi),%esi
  801428:	89 e9                	mov    %ebp,%ecx
  80142a:	8b 3c 24             	mov    (%esp),%edi
  80142d:	d3 e0                	shl    %cl,%eax
  80142f:	89 c6                	mov    %eax,%esi
  801431:	b8 20 00 00 00       	mov    $0x20,%eax
  801436:	29 e8                	sub    %ebp,%eax
  801438:	89 c1                	mov    %eax,%ecx
  80143a:	d3 ef                	shr    %cl,%edi
  80143c:	89 e9                	mov    %ebp,%ecx
  80143e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801442:	8b 3c 24             	mov    (%esp),%edi
  801445:	09 74 24 08          	or     %esi,0x8(%esp)
  801449:	89 d6                	mov    %edx,%esi
  80144b:	d3 e7                	shl    %cl,%edi
  80144d:	89 c1                	mov    %eax,%ecx
  80144f:	89 3c 24             	mov    %edi,(%esp)
  801452:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801456:	d3 ee                	shr    %cl,%esi
  801458:	89 e9                	mov    %ebp,%ecx
  80145a:	d3 e2                	shl    %cl,%edx
  80145c:	89 c1                	mov    %eax,%ecx
  80145e:	d3 ef                	shr    %cl,%edi
  801460:	09 d7                	or     %edx,%edi
  801462:	89 f2                	mov    %esi,%edx
  801464:	89 f8                	mov    %edi,%eax
  801466:	f7 74 24 08          	divl   0x8(%esp)
  80146a:	89 d6                	mov    %edx,%esi
  80146c:	89 c7                	mov    %eax,%edi
  80146e:	f7 24 24             	mull   (%esp)
  801471:	39 d6                	cmp    %edx,%esi
  801473:	89 14 24             	mov    %edx,(%esp)
  801476:	72 30                	jb     8014a8 <__udivdi3+0x118>
  801478:	8b 54 24 04          	mov    0x4(%esp),%edx
  80147c:	89 e9                	mov    %ebp,%ecx
  80147e:	d3 e2                	shl    %cl,%edx
  801480:	39 c2                	cmp    %eax,%edx
  801482:	73 05                	jae    801489 <__udivdi3+0xf9>
  801484:	3b 34 24             	cmp    (%esp),%esi
  801487:	74 1f                	je     8014a8 <__udivdi3+0x118>
  801489:	89 f8                	mov    %edi,%eax
  80148b:	31 d2                	xor    %edx,%edx
  80148d:	e9 7a ff ff ff       	jmp    80140c <__udivdi3+0x7c>
  801492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801498:	31 d2                	xor    %edx,%edx
  80149a:	b8 01 00 00 00       	mov    $0x1,%eax
  80149f:	e9 68 ff ff ff       	jmp    80140c <__udivdi3+0x7c>
  8014a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8014ab:	31 d2                	xor    %edx,%edx
  8014ad:	83 c4 0c             	add    $0xc,%esp
  8014b0:	5e                   	pop    %esi
  8014b1:	5f                   	pop    %edi
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    
  8014b4:	66 90                	xchg   %ax,%ax
  8014b6:	66 90                	xchg   %ax,%ax
  8014b8:	66 90                	xchg   %ax,%ax
  8014ba:	66 90                	xchg   %ax,%ax
  8014bc:	66 90                	xchg   %ax,%ax
  8014be:	66 90                	xchg   %ax,%ax

008014c0 <__umoddi3>:
  8014c0:	55                   	push   %ebp
  8014c1:	57                   	push   %edi
  8014c2:	56                   	push   %esi
  8014c3:	83 ec 14             	sub    $0x14,%esp
  8014c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014ca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8014ce:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8014d2:	89 c7                	mov    %eax,%edi
  8014d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8014dc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8014e0:	89 34 24             	mov    %esi,(%esp)
  8014e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	89 c2                	mov    %eax,%edx
  8014eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014ef:	75 17                	jne    801508 <__umoddi3+0x48>
  8014f1:	39 fe                	cmp    %edi,%esi
  8014f3:	76 4b                	jbe    801540 <__umoddi3+0x80>
  8014f5:	89 c8                	mov    %ecx,%eax
  8014f7:	89 fa                	mov    %edi,%edx
  8014f9:	f7 f6                	div    %esi
  8014fb:	89 d0                	mov    %edx,%eax
  8014fd:	31 d2                	xor    %edx,%edx
  8014ff:	83 c4 14             	add    $0x14,%esp
  801502:	5e                   	pop    %esi
  801503:	5f                   	pop    %edi
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    
  801506:	66 90                	xchg   %ax,%ax
  801508:	39 f8                	cmp    %edi,%eax
  80150a:	77 54                	ja     801560 <__umoddi3+0xa0>
  80150c:	0f bd e8             	bsr    %eax,%ebp
  80150f:	83 f5 1f             	xor    $0x1f,%ebp
  801512:	75 5c                	jne    801570 <__umoddi3+0xb0>
  801514:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801518:	39 3c 24             	cmp    %edi,(%esp)
  80151b:	0f 87 e7 00 00 00    	ja     801608 <__umoddi3+0x148>
  801521:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801525:	29 f1                	sub    %esi,%ecx
  801527:	19 c7                	sbb    %eax,%edi
  801529:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80152d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801531:	8b 44 24 08          	mov    0x8(%esp),%eax
  801535:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801539:	83 c4 14             	add    $0x14,%esp
  80153c:	5e                   	pop    %esi
  80153d:	5f                   	pop    %edi
  80153e:	5d                   	pop    %ebp
  80153f:	c3                   	ret    
  801540:	85 f6                	test   %esi,%esi
  801542:	89 f5                	mov    %esi,%ebp
  801544:	75 0b                	jne    801551 <__umoddi3+0x91>
  801546:	b8 01 00 00 00       	mov    $0x1,%eax
  80154b:	31 d2                	xor    %edx,%edx
  80154d:	f7 f6                	div    %esi
  80154f:	89 c5                	mov    %eax,%ebp
  801551:	8b 44 24 04          	mov    0x4(%esp),%eax
  801555:	31 d2                	xor    %edx,%edx
  801557:	f7 f5                	div    %ebp
  801559:	89 c8                	mov    %ecx,%eax
  80155b:	f7 f5                	div    %ebp
  80155d:	eb 9c                	jmp    8014fb <__umoddi3+0x3b>
  80155f:	90                   	nop
  801560:	89 c8                	mov    %ecx,%eax
  801562:	89 fa                	mov    %edi,%edx
  801564:	83 c4 14             	add    $0x14,%esp
  801567:	5e                   	pop    %esi
  801568:	5f                   	pop    %edi
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    
  80156b:	90                   	nop
  80156c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801570:	8b 04 24             	mov    (%esp),%eax
  801573:	be 20 00 00 00       	mov    $0x20,%esi
  801578:	89 e9                	mov    %ebp,%ecx
  80157a:	29 ee                	sub    %ebp,%esi
  80157c:	d3 e2                	shl    %cl,%edx
  80157e:	89 f1                	mov    %esi,%ecx
  801580:	d3 e8                	shr    %cl,%eax
  801582:	89 e9                	mov    %ebp,%ecx
  801584:	89 44 24 04          	mov    %eax,0x4(%esp)
  801588:	8b 04 24             	mov    (%esp),%eax
  80158b:	09 54 24 04          	or     %edx,0x4(%esp)
  80158f:	89 fa                	mov    %edi,%edx
  801591:	d3 e0                	shl    %cl,%eax
  801593:	89 f1                	mov    %esi,%ecx
  801595:	89 44 24 08          	mov    %eax,0x8(%esp)
  801599:	8b 44 24 10          	mov    0x10(%esp),%eax
  80159d:	d3 ea                	shr    %cl,%edx
  80159f:	89 e9                	mov    %ebp,%ecx
  8015a1:	d3 e7                	shl    %cl,%edi
  8015a3:	89 f1                	mov    %esi,%ecx
  8015a5:	d3 e8                	shr    %cl,%eax
  8015a7:	89 e9                	mov    %ebp,%ecx
  8015a9:	09 f8                	or     %edi,%eax
  8015ab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8015af:	f7 74 24 04          	divl   0x4(%esp)
  8015b3:	d3 e7                	shl    %cl,%edi
  8015b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015b9:	89 d7                	mov    %edx,%edi
  8015bb:	f7 64 24 08          	mull   0x8(%esp)
  8015bf:	39 d7                	cmp    %edx,%edi
  8015c1:	89 c1                	mov    %eax,%ecx
  8015c3:	89 14 24             	mov    %edx,(%esp)
  8015c6:	72 2c                	jb     8015f4 <__umoddi3+0x134>
  8015c8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8015cc:	72 22                	jb     8015f0 <__umoddi3+0x130>
  8015ce:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015d2:	29 c8                	sub    %ecx,%eax
  8015d4:	19 d7                	sbb    %edx,%edi
  8015d6:	89 e9                	mov    %ebp,%ecx
  8015d8:	89 fa                	mov    %edi,%edx
  8015da:	d3 e8                	shr    %cl,%eax
  8015dc:	89 f1                	mov    %esi,%ecx
  8015de:	d3 e2                	shl    %cl,%edx
  8015e0:	89 e9                	mov    %ebp,%ecx
  8015e2:	d3 ef                	shr    %cl,%edi
  8015e4:	09 d0                	or     %edx,%eax
  8015e6:	89 fa                	mov    %edi,%edx
  8015e8:	83 c4 14             	add    $0x14,%esp
  8015eb:	5e                   	pop    %esi
  8015ec:	5f                   	pop    %edi
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    
  8015ef:	90                   	nop
  8015f0:	39 d7                	cmp    %edx,%edi
  8015f2:	75 da                	jne    8015ce <__umoddi3+0x10e>
  8015f4:	8b 14 24             	mov    (%esp),%edx
  8015f7:	89 c1                	mov    %eax,%ecx
  8015f9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8015fd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801601:	eb cb                	jmp    8015ce <__umoddi3+0x10e>
  801603:	90                   	nop
  801604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801608:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80160c:	0f 82 0f ff ff ff    	jb     801521 <__umoddi3+0x61>
  801612:	e9 1a ff ff ff       	jmp    801531 <__umoddi3+0x71>
