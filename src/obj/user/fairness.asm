
obj/user/fairness.debug：     文件格式 elf32-i386


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
  80002c:	e8 91 00 00 00       	call   8000c2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 4b 0c 00 00       	call   800c8b <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 34                	jne    800082 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800058:	00 
  800059:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800060:	00 
  800061:	89 34 24             	mov    %esi,(%esp)
  800064:	e8 c8 0e 00 00       	call   800f31 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  800069:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80006c:	89 54 24 08          	mov    %edx,0x8(%esp)
  800070:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800074:	c7 04 24 00 21 80 00 	movl   $0x802100,(%esp)
  80007b:	e8 46 01 00 00       	call   8001c6 <cprintf>
  800080:	eb cf                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800082:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800087:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008f:	c7 04 24 11 21 80 00 	movl   $0x802111,(%esp)
  800096:	e8 2b 01 00 00       	call   8001c6 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a7:	00 
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 04 24             	mov    %eax,(%esp)
  8000bb:	e8 cd 0e 00 00       	call   800f8d <ipc_send>
  8000c0:	eb d9                	jmp    80009b <umain+0x68>

008000c2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
  8000c7:	83 ec 10             	sub    $0x10,%esp
  8000ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000cd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000d0:	e8 b6 0b 00 00       	call   800c8b <sys_getenvid>
  8000d5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e7:	85 db                	test   %ebx,%ebx
  8000e9:	7e 07                	jle    8000f2 <libmain+0x30>
		binaryname = argv[0];
  8000eb:	8b 06                	mov    (%esi),%eax
  8000ed:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000f6:	89 1c 24             	mov    %ebx,(%esp)
  8000f9:	e8 35 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000fe:	e8 07 00 00 00       	call   80010a <exit>
}
  800103:	83 c4 10             	add    $0x10,%esp
  800106:	5b                   	pop    %ebx
  800107:	5e                   	pop    %esi
  800108:	5d                   	pop    %ebp
  800109:	c3                   	ret    

0080010a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800110:	e8 21 11 00 00       	call   801236 <close_all>
	sys_env_destroy(0);
  800115:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80011c:	e8 18 0b 00 00       	call   800c39 <sys_env_destroy>
}
  800121:	c9                   	leave  
  800122:	c3                   	ret    

00800123 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	53                   	push   %ebx
  800127:	83 ec 14             	sub    $0x14,%esp
  80012a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012d:	8b 13                	mov    (%ebx),%edx
  80012f:	8d 42 01             	lea    0x1(%edx),%eax
  800132:	89 03                	mov    %eax,(%ebx)
  800134:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800137:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80013b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800140:	75 19                	jne    80015b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800142:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800149:	00 
  80014a:	8d 43 08             	lea    0x8(%ebx),%eax
  80014d:	89 04 24             	mov    %eax,(%esp)
  800150:	e8 a7 0a 00 00       	call   800bfc <sys_cputs>
		b->idx = 0;
  800155:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80015b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015f:	83 c4 14             	add    $0x14,%esp
  800162:	5b                   	pop    %ebx
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80016e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800175:	00 00 00 
	b.cnt = 0;
  800178:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800182:	8b 45 0c             	mov    0xc(%ebp),%eax
  800185:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800189:	8b 45 08             	mov    0x8(%ebp),%eax
  80018c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800190:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019a:	c7 04 24 23 01 80 00 	movl   $0x800123,(%esp)
  8001a1:	e8 ae 01 00 00       	call   800354 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b6:	89 04 24             	mov    %eax,(%esp)
  8001b9:	e8 3e 0a 00 00       	call   800bfc <sys_cputs>

	return b.cnt;
}
  8001be:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    

008001c6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001cc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d6:	89 04 24             	mov    %eax,(%esp)
  8001d9:	e8 87 ff ff ff       	call   800165 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 3c             	sub    $0x3c,%esp
  8001e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ec:	89 d7                	mov    %edx,%edi
  8001ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8001f7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8001fa:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800202:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800205:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800208:	39 f1                	cmp    %esi,%ecx
  80020a:	72 14                	jb     800220 <printnum+0x40>
  80020c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80020f:	76 0f                	jbe    800220 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800211:	8b 45 14             	mov    0x14(%ebp),%eax
  800214:	8d 70 ff             	lea    -0x1(%eax),%esi
  800217:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80021a:	85 f6                	test   %esi,%esi
  80021c:	7f 60                	jg     80027e <printnum+0x9e>
  80021e:	eb 72                	jmp    800292 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800220:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800223:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800227:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80022a:	8d 51 ff             	lea    -0x1(%ecx),%edx
  80022d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800231:	89 44 24 08          	mov    %eax,0x8(%esp)
  800235:	8b 44 24 08          	mov    0x8(%esp),%eax
  800239:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80023d:	89 c3                	mov    %eax,%ebx
  80023f:	89 d6                	mov    %edx,%esi
  800241:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800244:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800247:	89 54 24 08          	mov    %edx,0x8(%esp)
  80024b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80024f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800252:	89 04 24             	mov    %eax,(%esp)
  800255:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	e8 ff 1b 00 00       	call   801e60 <__udivdi3>
  800261:	89 d9                	mov    %ebx,%ecx
  800263:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800267:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800272:	89 fa                	mov    %edi,%edx
  800274:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800277:	e8 64 ff ff ff       	call   8001e0 <printnum>
  80027c:	eb 14                	jmp    800292 <printnum+0xb2>
			putch(padc, putdat);
  80027e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800282:	8b 45 18             	mov    0x18(%ebp),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	ff d3                	call   *%ebx
		while (--width > 0)
  80028a:	83 ee 01             	sub    $0x1,%esi
  80028d:	75 ef                	jne    80027e <printnum+0x9e>
  80028f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800292:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800296:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80029a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80029d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002ab:	89 04 24             	mov    %eax,(%esp)
  8002ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b5:	e8 d6 1c 00 00       	call   801f90 <__umoddi3>
  8002ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002be:	0f be 80 32 21 80 00 	movsbl 0x802132(%eax),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002cb:	ff d0                	call   *%eax
}
  8002cd:	83 c4 3c             	add    $0x3c,%esp
  8002d0:	5b                   	pop    %ebx
  8002d1:	5e                   	pop    %esi
  8002d2:	5f                   	pop    %edi
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d8:	83 fa 01             	cmp    $0x1,%edx
  8002db:	7e 0e                	jle    8002eb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	8b 52 04             	mov    0x4(%edx),%edx
  8002e9:	eb 22                	jmp    80030d <getuint+0x38>
	else if (lflag)
  8002eb:	85 d2                	test   %edx,%edx
  8002ed:	74 10                	je     8002ff <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ef:	8b 10                	mov    (%eax),%edx
  8002f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f4:	89 08                	mov    %ecx,(%eax)
  8002f6:	8b 02                	mov    (%edx),%eax
  8002f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fd:	eb 0e                	jmp    80030d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	8d 4a 04             	lea    0x4(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 02                	mov    (%edx),%eax
  800308:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800315:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	3b 50 04             	cmp    0x4(%eax),%edx
  80031e:	73 0a                	jae    80032a <sprintputch+0x1b>
		*b->buf++ = ch;
  800320:	8d 4a 01             	lea    0x1(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 45 08             	mov    0x8(%ebp),%eax
  800328:	88 02                	mov    %al,(%edx)
}
  80032a:	5d                   	pop    %ebp
  80032b:	c3                   	ret    

0080032c <printfmt>:
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  800332:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800335:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800339:	8b 45 10             	mov    0x10(%ebp),%eax
  80033c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800340:	8b 45 0c             	mov    0xc(%ebp),%eax
  800343:	89 44 24 04          	mov    %eax,0x4(%esp)
  800347:	8b 45 08             	mov    0x8(%ebp),%eax
  80034a:	89 04 24             	mov    %eax,(%esp)
  80034d:	e8 02 00 00 00       	call   800354 <vprintfmt>
}
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <vprintfmt>:
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
  80035a:	83 ec 3c             	sub    $0x3c,%esp
  80035d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800360:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800363:	eb 18                	jmp    80037d <vprintfmt+0x29>
			if (ch == '\0')
  800365:	85 c0                	test   %eax,%eax
  800367:	0f 84 c3 03 00 00    	je     800730 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80036d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800371:	89 04 24             	mov    %eax,(%esp)
  800374:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800377:	89 f3                	mov    %esi,%ebx
  800379:	eb 02                	jmp    80037d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80037b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037d:	8d 73 01             	lea    0x1(%ebx),%esi
  800380:	0f b6 03             	movzbl (%ebx),%eax
  800383:	83 f8 25             	cmp    $0x25,%eax
  800386:	75 dd                	jne    800365 <vprintfmt+0x11>
  800388:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80038c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800393:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80039a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a6:	eb 1d                	jmp    8003c5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	89 de                	mov    %ebx,%esi
			padc = '-';
  8003aa:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8003ae:	eb 15                	jmp    8003c5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	89 de                	mov    %ebx,%esi
			padc = '0';
  8003b2:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8003b6:	eb 0d                	jmp    8003c5 <vprintfmt+0x71>
				width = precision, precision = -1;
  8003b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003be:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003c8:	0f b6 06             	movzbl (%esi),%eax
  8003cb:	0f b6 c8             	movzbl %al,%ecx
  8003ce:	83 e8 23             	sub    $0x23,%eax
  8003d1:	3c 55                	cmp    $0x55,%al
  8003d3:	0f 87 2f 03 00 00    	ja     800708 <vprintfmt+0x3b4>
  8003d9:	0f b6 c0             	movzbl %al,%eax
  8003dc:	ff 24 85 80 22 80 00 	jmp    *0x802280(,%eax,4)
				precision = precision * 10 + ch - '0';
  8003e3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8003e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  8003e9:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003ed:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003f0:	83 f9 09             	cmp    $0x9,%ecx
  8003f3:	77 50                	ja     800445 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	89 de                	mov    %ebx,%esi
  8003f7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8003fa:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003fd:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800400:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800404:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800407:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80040a:	83 fb 09             	cmp    $0x9,%ebx
  80040d:	76 eb                	jbe    8003fa <vprintfmt+0xa6>
  80040f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800412:	eb 33                	jmp    800447 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 48 04             	lea    0x4(%eax),%ecx
  80041a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80041d:	8b 00                	mov    (%eax),%eax
  80041f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800422:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800424:	eb 21                	jmp    800447 <vprintfmt+0xf3>
  800426:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800429:	85 c9                	test   %ecx,%ecx
  80042b:	b8 00 00 00 00       	mov    $0x0,%eax
  800430:	0f 49 c1             	cmovns %ecx,%eax
  800433:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800436:	89 de                	mov    %ebx,%esi
  800438:	eb 8b                	jmp    8003c5 <vprintfmt+0x71>
  80043a:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80043c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800443:	eb 80                	jmp    8003c5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800445:	89 de                	mov    %ebx,%esi
			if (width < 0)
  800447:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044b:	0f 89 74 ff ff ff    	jns    8003c5 <vprintfmt+0x71>
  800451:	e9 62 ff ff ff       	jmp    8003b8 <vprintfmt+0x64>
			lflag++;
  800456:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800459:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80045b:	e9 65 ff ff ff       	jmp    8003c5 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046d:	8b 00                	mov    (%eax),%eax
  80046f:	89 04 24             	mov    %eax,(%esp)
  800472:	ff 55 08             	call   *0x8(%ebp)
			break;
  800475:	e9 03 ff ff ff       	jmp    80037d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80047a:	8b 45 14             	mov    0x14(%ebp),%eax
  80047d:	8d 50 04             	lea    0x4(%eax),%edx
  800480:	89 55 14             	mov    %edx,0x14(%ebp)
  800483:	8b 00                	mov    (%eax),%eax
  800485:	99                   	cltd   
  800486:	31 d0                	xor    %edx,%eax
  800488:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048a:	83 f8 0f             	cmp    $0xf,%eax
  80048d:	7f 0b                	jg     80049a <vprintfmt+0x146>
  80048f:	8b 14 85 e0 23 80 00 	mov    0x8023e0(,%eax,4),%edx
  800496:	85 d2                	test   %edx,%edx
  800498:	75 20                	jne    8004ba <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80049a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049e:	c7 44 24 08 4a 21 80 	movl   $0x80214a,0x8(%esp)
  8004a5:	00 
  8004a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ad:	89 04 24             	mov    %eax,(%esp)
  8004b0:	e8 77 fe ff ff       	call   80032c <printfmt>
  8004b5:	e9 c3 fe ff ff       	jmp    80037d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  8004ba:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004be:	c7 44 24 08 ff 24 80 	movl   $0x8024ff,0x8(%esp)
  8004c5:	00 
  8004c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cd:	89 04 24             	mov    %eax,(%esp)
  8004d0:	e8 57 fe ff ff       	call   80032c <printfmt>
  8004d5:	e9 a3 fe ff ff       	jmp    80037d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004dd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	ba 43 21 80 00       	mov    $0x802143,%edx
  8004f2:	0f 45 d0             	cmovne %eax,%edx
  8004f5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004f8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8004fc:	74 04                	je     800502 <vprintfmt+0x1ae>
  8004fe:	85 f6                	test   %esi,%esi
  800500:	7f 19                	jg     80051b <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800502:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800505:	8d 70 01             	lea    0x1(%eax),%esi
  800508:	0f b6 10             	movzbl (%eax),%edx
  80050b:	0f be c2             	movsbl %dl,%eax
  80050e:	85 c0                	test   %eax,%eax
  800510:	0f 85 95 00 00 00    	jne    8005ab <vprintfmt+0x257>
  800516:	e9 85 00 00 00       	jmp    8005a0 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80051f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800522:	89 04 24             	mov    %eax,(%esp)
  800525:	e8 b8 02 00 00       	call   8007e2 <strnlen>
  80052a:	29 c6                	sub    %eax,%esi
  80052c:	89 f0                	mov    %esi,%eax
  80052e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800531:	85 f6                	test   %esi,%esi
  800533:	7e cd                	jle    800502 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800535:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800539:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80053c:	89 c3                	mov    %eax,%ebx
  80053e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800542:	89 34 24             	mov    %esi,(%esp)
  800545:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800548:	83 eb 01             	sub    $0x1,%ebx
  80054b:	75 f1                	jne    80053e <vprintfmt+0x1ea>
  80054d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800550:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800553:	eb ad                	jmp    800502 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800555:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800559:	74 1e                	je     800579 <vprintfmt+0x225>
  80055b:	0f be d2             	movsbl %dl,%edx
  80055e:	83 ea 20             	sub    $0x20,%edx
  800561:	83 fa 5e             	cmp    $0x5e,%edx
  800564:	76 13                	jbe    800579 <vprintfmt+0x225>
					putch('?', putdat);
  800566:	8b 45 0c             	mov    0xc(%ebp),%eax
  800569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800574:	ff 55 08             	call   *0x8(%ebp)
  800577:	eb 0d                	jmp    800586 <vprintfmt+0x232>
					putch(ch, putdat);
  800579:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80057c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800586:	83 ef 01             	sub    $0x1,%edi
  800589:	83 c6 01             	add    $0x1,%esi
  80058c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800590:	0f be c2             	movsbl %dl,%eax
  800593:	85 c0                	test   %eax,%eax
  800595:	75 20                	jne    8005b7 <vprintfmt+0x263>
  800597:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80059a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80059d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  8005a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a4:	7f 25                	jg     8005cb <vprintfmt+0x277>
  8005a6:	e9 d2 fd ff ff       	jmp    80037d <vprintfmt+0x29>
  8005ab:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005b4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b7:	85 db                	test   %ebx,%ebx
  8005b9:	78 9a                	js     800555 <vprintfmt+0x201>
  8005bb:	83 eb 01             	sub    $0x1,%ebx
  8005be:	79 95                	jns    800555 <vprintfmt+0x201>
  8005c0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005c3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005c9:	eb d5                	jmp    8005a0 <vprintfmt+0x24c>
  8005cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ce:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  8005d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005df:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005e1:	83 eb 01             	sub    $0x1,%ebx
  8005e4:	75 ee                	jne    8005d4 <vprintfmt+0x280>
  8005e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005e9:	e9 8f fd ff ff       	jmp    80037d <vprintfmt+0x29>
	if (lflag >= 2)
  8005ee:	83 fa 01             	cmp    $0x1,%edx
  8005f1:	7e 16                	jle    800609 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 08             	lea    0x8(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fc:	8b 50 04             	mov    0x4(%eax),%edx
  8005ff:	8b 00                	mov    (%eax),%eax
  800601:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800604:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800607:	eb 32                	jmp    80063b <vprintfmt+0x2e7>
	else if (lflag)
  800609:	85 d2                	test   %edx,%edx
  80060b:	74 18                	je     800625 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 50 04             	lea    0x4(%eax),%edx
  800613:	89 55 14             	mov    %edx,0x14(%ebp)
  800616:	8b 30                	mov    (%eax),%esi
  800618:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80061b:	89 f0                	mov    %esi,%eax
  80061d:	c1 f8 1f             	sar    $0x1f,%eax
  800620:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800623:	eb 16                	jmp    80063b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 50 04             	lea    0x4(%eax),%edx
  80062b:	89 55 14             	mov    %edx,0x14(%ebp)
  80062e:	8b 30                	mov    (%eax),%esi
  800630:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800633:	89 f0                	mov    %esi,%eax
  800635:	c1 f8 1f             	sar    $0x1f,%eax
  800638:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  80063b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  800641:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800646:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064a:	0f 89 80 00 00 00    	jns    8006d0 <vprintfmt+0x37c>
				putch('-', putdat);
  800650:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800654:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80065e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800661:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800664:	f7 d8                	neg    %eax
  800666:	83 d2 00             	adc    $0x0,%edx
  800669:	f7 da                	neg    %edx
			base = 10;
  80066b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800670:	eb 5e                	jmp    8006d0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800672:	8d 45 14             	lea    0x14(%ebp),%eax
  800675:	e8 5b fc ff ff       	call   8002d5 <getuint>
			base = 10;
  80067a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80067f:	eb 4f                	jmp    8006d0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800681:	8d 45 14             	lea    0x14(%ebp),%eax
  800684:	e8 4c fc ff ff       	call   8002d5 <getuint>
			base = 8;
  800689:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80068e:	eb 40                	jmp    8006d0 <vprintfmt+0x37c>
			putch('0', putdat);
  800690:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800694:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80069b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80069e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a9:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 50 04             	lea    0x4(%eax),%edx
  8006b2:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8006b5:	8b 00                	mov    (%eax),%eax
  8006b7:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8006bc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006c1:	eb 0d                	jmp    8006d0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8006c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c6:	e8 0a fc ff ff       	call   8002d5 <getuint>
			base = 16;
  8006cb:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8006d0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006d4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006d8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006db:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006df:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006e3:	89 04 24             	mov    %eax,(%esp)
  8006e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ea:	89 fa                	mov    %edi,%edx
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	e8 ec fa ff ff       	call   8001e0 <printnum>
			break;
  8006f4:	e9 84 fc ff ff       	jmp    80037d <vprintfmt+0x29>
			putch(ch, putdat);
  8006f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006fd:	89 0c 24             	mov    %ecx,(%esp)
  800700:	ff 55 08             	call   *0x8(%ebp)
			break;
  800703:	e9 75 fc ff ff       	jmp    80037d <vprintfmt+0x29>
			putch('%', putdat);
  800708:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800713:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800716:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80071a:	0f 84 5b fc ff ff    	je     80037b <vprintfmt+0x27>
  800720:	89 f3                	mov    %esi,%ebx
  800722:	83 eb 01             	sub    $0x1,%ebx
  800725:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800729:	75 f7                	jne    800722 <vprintfmt+0x3ce>
  80072b:	e9 4d fc ff ff       	jmp    80037d <vprintfmt+0x29>
}
  800730:	83 c4 3c             	add    $0x3c,%esp
  800733:	5b                   	pop    %ebx
  800734:	5e                   	pop    %esi
  800735:	5f                   	pop    %edi
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	83 ec 28             	sub    $0x28,%esp
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  800741:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800744:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800747:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800755:	85 c0                	test   %eax,%eax
  800757:	74 30                	je     800789 <vsnprintf+0x51>
  800759:	85 d2                	test   %edx,%edx
  80075b:	7e 2c                	jle    800789 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800764:	8b 45 10             	mov    0x10(%ebp),%eax
  800767:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800772:	c7 04 24 0f 03 80 00 	movl   $0x80030f,(%esp)
  800779:	e8 d6 fb ff ff       	call   800354 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800781:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800784:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800787:	eb 05                	jmp    80078e <vsnprintf+0x56>
		return -E_INVAL;
  800789:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800796:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800799:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079d:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	89 04 24             	mov    %eax,(%esp)
  8007b1:	e8 82 ff ff ff       	call   800738 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    
  8007b8:	66 90                	xchg   %ax,%ax
  8007ba:	66 90                	xchg   %ax,%ax
  8007bc:	66 90                	xchg   %ax,%ax
  8007be:	66 90                	xchg   %ax,%ax

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007c9:	74 10                	je     8007db <strlen+0x1b>
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007d0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d7:	75 f7                	jne    8007d0 <strlen+0x10>
  8007d9:	eb 05                	jmp    8007e0 <strlen+0x20>
  8007db:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	53                   	push   %ebx
  8007e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ec:	85 c9                	test   %ecx,%ecx
  8007ee:	74 1c                	je     80080c <strnlen+0x2a>
  8007f0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007f3:	74 1e                	je     800813 <strnlen+0x31>
  8007f5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007fa:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fc:	39 ca                	cmp    %ecx,%edx
  8007fe:	74 18                	je     800818 <strnlen+0x36>
  800800:	83 c2 01             	add    $0x1,%edx
  800803:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800808:	75 f0                	jne    8007fa <strnlen+0x18>
  80080a:	eb 0c                	jmp    800818 <strnlen+0x36>
  80080c:	b8 00 00 00 00       	mov    $0x0,%eax
  800811:	eb 05                	jmp    800818 <strnlen+0x36>
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800818:	5b                   	pop    %ebx
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800825:	89 c2                	mov    %eax,%edx
  800827:	83 c2 01             	add    $0x1,%edx
  80082a:	83 c1 01             	add    $0x1,%ecx
  80082d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800831:	88 5a ff             	mov    %bl,-0x1(%edx)
  800834:	84 db                	test   %bl,%bl
  800836:	75 ef                	jne    800827 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800838:	5b                   	pop    %ebx
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	83 ec 08             	sub    $0x8,%esp
  800842:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800845:	89 1c 24             	mov    %ebx,(%esp)
  800848:	e8 73 ff ff ff       	call   8007c0 <strlen>
	strcpy(dst + len, src);
  80084d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800850:	89 54 24 04          	mov    %edx,0x4(%esp)
  800854:	01 d8                	add    %ebx,%eax
  800856:	89 04 24             	mov    %eax,(%esp)
  800859:	e8 bd ff ff ff       	call   80081b <strcpy>
	return dst;
}
  80085e:	89 d8                	mov    %ebx,%eax
  800860:	83 c4 08             	add    $0x8,%esp
  800863:	5b                   	pop    %ebx
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	56                   	push   %esi
  80086a:	53                   	push   %ebx
  80086b:	8b 75 08             	mov    0x8(%ebp),%esi
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800874:	85 db                	test   %ebx,%ebx
  800876:	74 17                	je     80088f <strncpy+0x29>
  800878:	01 f3                	add    %esi,%ebx
  80087a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80087c:	83 c1 01             	add    $0x1,%ecx
  80087f:	0f b6 02             	movzbl (%edx),%eax
  800882:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800885:	80 3a 01             	cmpb   $0x1,(%edx)
  800888:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80088b:	39 d9                	cmp    %ebx,%ecx
  80088d:	75 ed                	jne    80087c <strncpy+0x16>
	}
	return ret;
}
  80088f:	89 f0                	mov    %esi,%eax
  800891:	5b                   	pop    %ebx
  800892:	5e                   	pop    %esi
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	57                   	push   %edi
  800899:	56                   	push   %esi
  80089a:	53                   	push   %ebx
  80089b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a1:	8b 75 10             	mov    0x10(%ebp),%esi
  8008a4:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a6:	85 f6                	test   %esi,%esi
  8008a8:	74 34                	je     8008de <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  8008aa:	83 fe 01             	cmp    $0x1,%esi
  8008ad:	74 26                	je     8008d5 <strlcpy+0x40>
  8008af:	0f b6 0b             	movzbl (%ebx),%ecx
  8008b2:	84 c9                	test   %cl,%cl
  8008b4:	74 23                	je     8008d9 <strlcpy+0x44>
  8008b6:	83 ee 02             	sub    $0x2,%esi
  8008b9:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  8008be:	83 c0 01             	add    $0x1,%eax
  8008c1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008c4:	39 f2                	cmp    %esi,%edx
  8008c6:	74 13                	je     8008db <strlcpy+0x46>
  8008c8:	83 c2 01             	add    $0x1,%edx
  8008cb:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008cf:	84 c9                	test   %cl,%cl
  8008d1:	75 eb                	jne    8008be <strlcpy+0x29>
  8008d3:	eb 06                	jmp    8008db <strlcpy+0x46>
  8008d5:	89 f8                	mov    %edi,%eax
  8008d7:	eb 02                	jmp    8008db <strlcpy+0x46>
  8008d9:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  8008db:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008de:	29 f8                	sub    %edi,%eax
}
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5f                   	pop    %edi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ee:	0f b6 01             	movzbl (%ecx),%eax
  8008f1:	84 c0                	test   %al,%al
  8008f3:	74 15                	je     80090a <strcmp+0x25>
  8008f5:	3a 02                	cmp    (%edx),%al
  8008f7:	75 11                	jne    80090a <strcmp+0x25>
		p++, q++;
  8008f9:	83 c1 01             	add    $0x1,%ecx
  8008fc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ff:	0f b6 01             	movzbl (%ecx),%eax
  800902:	84 c0                	test   %al,%al
  800904:	74 04                	je     80090a <strcmp+0x25>
  800906:	3a 02                	cmp    (%edx),%al
  800908:	74 ef                	je     8008f9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80090a:	0f b6 c0             	movzbl %al,%eax
  80090d:	0f b6 12             	movzbl (%edx),%edx
  800910:	29 d0                	sub    %edx,%eax
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800922:	85 f6                	test   %esi,%esi
  800924:	74 29                	je     80094f <strncmp+0x3b>
  800926:	0f b6 03             	movzbl (%ebx),%eax
  800929:	84 c0                	test   %al,%al
  80092b:	74 30                	je     80095d <strncmp+0x49>
  80092d:	3a 02                	cmp    (%edx),%al
  80092f:	75 2c                	jne    80095d <strncmp+0x49>
  800931:	8d 43 01             	lea    0x1(%ebx),%eax
  800934:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800936:	89 c3                	mov    %eax,%ebx
  800938:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80093b:	39 f0                	cmp    %esi,%eax
  80093d:	74 17                	je     800956 <strncmp+0x42>
  80093f:	0f b6 08             	movzbl (%eax),%ecx
  800942:	84 c9                	test   %cl,%cl
  800944:	74 17                	je     80095d <strncmp+0x49>
  800946:	83 c0 01             	add    $0x1,%eax
  800949:	3a 0a                	cmp    (%edx),%cl
  80094b:	74 e9                	je     800936 <strncmp+0x22>
  80094d:	eb 0e                	jmp    80095d <strncmp+0x49>
	if (n == 0)
		return 0;
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
  800954:	eb 0f                	jmp    800965 <strncmp+0x51>
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
  80095b:	eb 08                	jmp    800965 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80095d:	0f b6 03             	movzbl (%ebx),%eax
  800960:	0f b6 12             	movzbl (%edx),%edx
  800963:	29 d0                	sub    %edx,%eax
}
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	53                   	push   %ebx
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800973:	0f b6 18             	movzbl (%eax),%ebx
  800976:	84 db                	test   %bl,%bl
  800978:	74 1d                	je     800997 <strchr+0x2e>
  80097a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80097c:	38 d3                	cmp    %dl,%bl
  80097e:	75 06                	jne    800986 <strchr+0x1d>
  800980:	eb 1a                	jmp    80099c <strchr+0x33>
  800982:	38 ca                	cmp    %cl,%dl
  800984:	74 16                	je     80099c <strchr+0x33>
	for (; *s; s++)
  800986:	83 c0 01             	add    $0x1,%eax
  800989:	0f b6 10             	movzbl (%eax),%edx
  80098c:	84 d2                	test   %dl,%dl
  80098e:	75 f2                	jne    800982 <strchr+0x19>
			return (char *) s;
	return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
  800995:	eb 05                	jmp    80099c <strchr+0x33>
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009a9:	0f b6 18             	movzbl (%eax),%ebx
  8009ac:	84 db                	test   %bl,%bl
  8009ae:	74 16                	je     8009c6 <strfind+0x27>
  8009b0:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009b2:	38 d3                	cmp    %dl,%bl
  8009b4:	75 06                	jne    8009bc <strfind+0x1d>
  8009b6:	eb 0e                	jmp    8009c6 <strfind+0x27>
  8009b8:	38 ca                	cmp    %cl,%dl
  8009ba:	74 0a                	je     8009c6 <strfind+0x27>
	for (; *s; s++)
  8009bc:	83 c0 01             	add    $0x1,%eax
  8009bf:	0f b6 10             	movzbl (%eax),%edx
  8009c2:	84 d2                	test   %dl,%dl
  8009c4:	75 f2                	jne    8009b8 <strfind+0x19>
			break;
	return (char *) s;
}
  8009c6:	5b                   	pop    %ebx
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	57                   	push   %edi
  8009cd:	56                   	push   %esi
  8009ce:	53                   	push   %ebx
  8009cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d5:	85 c9                	test   %ecx,%ecx
  8009d7:	74 36                	je     800a0f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009df:	75 28                	jne    800a09 <memset+0x40>
  8009e1:	f6 c1 03             	test   $0x3,%cl
  8009e4:	75 23                	jne    800a09 <memset+0x40>
		c &= 0xFF;
  8009e6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ea:	89 d3                	mov    %edx,%ebx
  8009ec:	c1 e3 08             	shl    $0x8,%ebx
  8009ef:	89 d6                	mov    %edx,%esi
  8009f1:	c1 e6 18             	shl    $0x18,%esi
  8009f4:	89 d0                	mov    %edx,%eax
  8009f6:	c1 e0 10             	shl    $0x10,%eax
  8009f9:	09 f0                	or     %esi,%eax
  8009fb:	09 c2                	or     %eax,%edx
  8009fd:	89 d0                	mov    %edx,%eax
  8009ff:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a01:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a04:	fc                   	cld    
  800a05:	f3 ab                	rep stos %eax,%es:(%edi)
  800a07:	eb 06                	jmp    800a0f <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0c:	fc                   	cld    
  800a0d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0f:	89 f8                	mov    %edi,%eax
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5f                   	pop    %edi
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	57                   	push   %edi
  800a1a:	56                   	push   %esi
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a21:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a24:	39 c6                	cmp    %eax,%esi
  800a26:	73 35                	jae    800a5d <memmove+0x47>
  800a28:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a2b:	39 d0                	cmp    %edx,%eax
  800a2d:	73 2e                	jae    800a5d <memmove+0x47>
		s += n;
		d += n;
  800a2f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a32:	89 d6                	mov    %edx,%esi
  800a34:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3c:	75 13                	jne    800a51 <memmove+0x3b>
  800a3e:	f6 c1 03             	test   $0x3,%cl
  800a41:	75 0e                	jne    800a51 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a43:	83 ef 04             	sub    $0x4,%edi
  800a46:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a49:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a4c:	fd                   	std    
  800a4d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4f:	eb 09                	jmp    800a5a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a51:	83 ef 01             	sub    $0x1,%edi
  800a54:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a57:	fd                   	std    
  800a58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a5a:	fc                   	cld    
  800a5b:	eb 1d                	jmp    800a7a <memmove+0x64>
  800a5d:	89 f2                	mov    %esi,%edx
  800a5f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a61:	f6 c2 03             	test   $0x3,%dl
  800a64:	75 0f                	jne    800a75 <memmove+0x5f>
  800a66:	f6 c1 03             	test   $0x3,%cl
  800a69:	75 0a                	jne    800a75 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a6b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a6e:	89 c7                	mov    %eax,%edi
  800a70:	fc                   	cld    
  800a71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a73:	eb 05                	jmp    800a7a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800a75:	89 c7                	mov    %eax,%edi
  800a77:	fc                   	cld    
  800a78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a84:	8b 45 10             	mov    0x10(%ebp),%eax
  800a87:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	89 04 24             	mov    %eax,(%esp)
  800a98:	e8 79 ff ff ff       	call   800a16 <memmove>
}
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800aa8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aab:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aae:	8d 78 ff             	lea    -0x1(%eax),%edi
  800ab1:	85 c0                	test   %eax,%eax
  800ab3:	74 36                	je     800aeb <memcmp+0x4c>
		if (*s1 != *s2)
  800ab5:	0f b6 03             	movzbl (%ebx),%eax
  800ab8:	0f b6 0e             	movzbl (%esi),%ecx
  800abb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac0:	38 c8                	cmp    %cl,%al
  800ac2:	74 1c                	je     800ae0 <memcmp+0x41>
  800ac4:	eb 10                	jmp    800ad6 <memcmp+0x37>
  800ac6:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800acb:	83 c2 01             	add    $0x1,%edx
  800ace:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ad2:	38 c8                	cmp    %cl,%al
  800ad4:	74 0a                	je     800ae0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ad6:	0f b6 c0             	movzbl %al,%eax
  800ad9:	0f b6 c9             	movzbl %cl,%ecx
  800adc:	29 c8                	sub    %ecx,%eax
  800ade:	eb 10                	jmp    800af0 <memcmp+0x51>
	while (n-- > 0) {
  800ae0:	39 fa                	cmp    %edi,%edx
  800ae2:	75 e2                	jne    800ac6 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae9:	eb 05                	jmp    800af0 <memcmp+0x51>
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	53                   	push   %ebx
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800aff:	89 c2                	mov    %eax,%edx
  800b01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b04:	39 d0                	cmp    %edx,%eax
  800b06:	73 13                	jae    800b1b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b08:	89 d9                	mov    %ebx,%ecx
  800b0a:	38 18                	cmp    %bl,(%eax)
  800b0c:	75 06                	jne    800b14 <memfind+0x1f>
  800b0e:	eb 0b                	jmp    800b1b <memfind+0x26>
  800b10:	38 08                	cmp    %cl,(%eax)
  800b12:	74 07                	je     800b1b <memfind+0x26>
	for (; s < ends; s++)
  800b14:	83 c0 01             	add    $0x1,%eax
  800b17:	39 d0                	cmp    %edx,%eax
  800b19:	75 f5                	jne    800b10 <memfind+0x1b>
			break;
	return (void *) s;
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2a:	0f b6 0a             	movzbl (%edx),%ecx
  800b2d:	80 f9 09             	cmp    $0x9,%cl
  800b30:	74 05                	je     800b37 <strtol+0x19>
  800b32:	80 f9 20             	cmp    $0x20,%cl
  800b35:	75 10                	jne    800b47 <strtol+0x29>
		s++;
  800b37:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b3a:	0f b6 0a             	movzbl (%edx),%ecx
  800b3d:	80 f9 09             	cmp    $0x9,%cl
  800b40:	74 f5                	je     800b37 <strtol+0x19>
  800b42:	80 f9 20             	cmp    $0x20,%cl
  800b45:	74 f0                	je     800b37 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800b47:	80 f9 2b             	cmp    $0x2b,%cl
  800b4a:	75 0a                	jne    800b56 <strtol+0x38>
		s++;
  800b4c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b4f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b54:	eb 11                	jmp    800b67 <strtol+0x49>
  800b56:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800b5b:	80 f9 2d             	cmp    $0x2d,%cl
  800b5e:	75 07                	jne    800b67 <strtol+0x49>
		s++, neg = 1;
  800b60:	83 c2 01             	add    $0x1,%edx
  800b63:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b67:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b6c:	75 15                	jne    800b83 <strtol+0x65>
  800b6e:	80 3a 30             	cmpb   $0x30,(%edx)
  800b71:	75 10                	jne    800b83 <strtol+0x65>
  800b73:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b77:	75 0a                	jne    800b83 <strtol+0x65>
		s += 2, base = 16;
  800b79:	83 c2 02             	add    $0x2,%edx
  800b7c:	b8 10 00 00 00       	mov    $0x10,%eax
  800b81:	eb 10                	jmp    800b93 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800b83:	85 c0                	test   %eax,%eax
  800b85:	75 0c                	jne    800b93 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b87:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800b89:	80 3a 30             	cmpb   $0x30,(%edx)
  800b8c:	75 05                	jne    800b93 <strtol+0x75>
		s++, base = 8;
  800b8e:	83 c2 01             	add    $0x1,%edx
  800b91:	b0 08                	mov    $0x8,%al
		base = 10;
  800b93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b98:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9b:	0f b6 0a             	movzbl (%edx),%ecx
  800b9e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ba1:	89 f0                	mov    %esi,%eax
  800ba3:	3c 09                	cmp    $0x9,%al
  800ba5:	77 08                	ja     800baf <strtol+0x91>
			dig = *s - '0';
  800ba7:	0f be c9             	movsbl %cl,%ecx
  800baa:	83 e9 30             	sub    $0x30,%ecx
  800bad:	eb 20                	jmp    800bcf <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800baf:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bb2:	89 f0                	mov    %esi,%eax
  800bb4:	3c 19                	cmp    $0x19,%al
  800bb6:	77 08                	ja     800bc0 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800bb8:	0f be c9             	movsbl %cl,%ecx
  800bbb:	83 e9 57             	sub    $0x57,%ecx
  800bbe:	eb 0f                	jmp    800bcf <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800bc0:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bc3:	89 f0                	mov    %esi,%eax
  800bc5:	3c 19                	cmp    $0x19,%al
  800bc7:	77 16                	ja     800bdf <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bc9:	0f be c9             	movsbl %cl,%ecx
  800bcc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bcf:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bd2:	7d 0f                	jge    800be3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bd4:	83 c2 01             	add    $0x1,%edx
  800bd7:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bdb:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bdd:	eb bc                	jmp    800b9b <strtol+0x7d>
  800bdf:	89 d8                	mov    %ebx,%eax
  800be1:	eb 02                	jmp    800be5 <strtol+0xc7>
  800be3:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800be5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be9:	74 05                	je     800bf0 <strtol+0xd2>
		*endptr = (char *) s;
  800beb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bee:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bf0:	f7 d8                	neg    %eax
  800bf2:	85 ff                	test   %edi,%edi
  800bf4:	0f 44 c3             	cmove  %ebx,%eax
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	89 c3                	mov    %eax,%ebx
  800c0f:	89 c7                	mov    %eax,%edi
  800c11:	89 c6                	mov    %eax,%esi
  800c13:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2a:	89 d1                	mov    %edx,%ecx
  800c2c:	89 d3                	mov    %edx,%ebx
  800c2e:	89 d7                	mov    %edx,%edi
  800c30:	89 d6                	mov    %edx,%esi
  800c32:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c47:	b8 03 00 00 00       	mov    $0x3,%eax
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	89 cb                	mov    %ecx,%ebx
  800c51:	89 cf                	mov    %ecx,%edi
  800c53:	89 ce                	mov    %ecx,%esi
  800c55:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 28                	jle    800c83 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c66:	00 
  800c67:	c7 44 24 08 3f 24 80 	movl   $0x80243f,0x8(%esp)
  800c6e:	00 
  800c6f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c76:	00 
  800c77:	c7 04 24 5c 24 80 00 	movl   $0x80245c,(%esp)
  800c7e:	e8 43 11 00 00       	call   801dc6 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c83:	83 c4 2c             	add    $0x2c,%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c91:	ba 00 00 00 00       	mov    $0x0,%edx
  800c96:	b8 02 00 00 00       	mov    $0x2,%eax
  800c9b:	89 d1                	mov    %edx,%ecx
  800c9d:	89 d3                	mov    %edx,%ebx
  800c9f:	89 d7                	mov    %edx,%edi
  800ca1:	89 d6                	mov    %edx,%esi
  800ca3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_yield>:

void
sys_yield(void)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cba:	89 d1                	mov    %edx,%ecx
  800cbc:	89 d3                	mov    %edx,%ebx
  800cbe:	89 d7                	mov    %edx,%edi
  800cc0:	89 d6                	mov    %edx,%esi
  800cc2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cd2:	be 00 00 00 00       	mov    $0x0,%esi
  800cd7:	b8 04 00 00 00       	mov    $0x4,%eax
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce5:	89 f7                	mov    %esi,%edi
  800ce7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7e 28                	jle    800d15 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cf8:	00 
  800cf9:	c7 44 24 08 3f 24 80 	movl   $0x80243f,0x8(%esp)
  800d00:	00 
  800d01:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d08:	00 
  800d09:	c7 04 24 5c 24 80 00 	movl   $0x80245c,(%esp)
  800d10:	e8 b1 10 00 00       	call   801dc6 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d15:	83 c4 2c             	add    $0x2c,%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d26:	b8 05 00 00 00       	mov    $0x5,%eax
  800d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d34:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d37:	8b 75 18             	mov    0x18(%ebp),%esi
  800d3a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 28                	jle    800d68 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d44:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d4b:	00 
  800d4c:	c7 44 24 08 3f 24 80 	movl   $0x80243f,0x8(%esp)
  800d53:	00 
  800d54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d5b:	00 
  800d5c:	c7 04 24 5c 24 80 00 	movl   $0x80245c,(%esp)
  800d63:	e8 5e 10 00 00       	call   801dc6 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d68:	83 c4 2c             	add    $0x2c,%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
  800d76:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	89 df                	mov    %ebx,%edi
  800d8b:	89 de                	mov    %ebx,%esi
  800d8d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	7e 28                	jle    800dbb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d97:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d9e:	00 
  800d9f:	c7 44 24 08 3f 24 80 	movl   $0x80243f,0x8(%esp)
  800da6:	00 
  800da7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dae:	00 
  800daf:	c7 04 24 5c 24 80 00 	movl   $0x80245c,(%esp)
  800db6:	e8 0b 10 00 00       	call   801dc6 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dbb:	83 c4 2c             	add    $0x2c,%esp
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	57                   	push   %edi
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd1:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	89 df                	mov    %ebx,%edi
  800dde:	89 de                	mov    %ebx,%esi
  800de0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 28                	jle    800e0e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dea:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800df1:	00 
  800df2:	c7 44 24 08 3f 24 80 	movl   $0x80243f,0x8(%esp)
  800df9:	00 
  800dfa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e01:	00 
  800e02:	c7 04 24 5c 24 80 00 	movl   $0x80245c,(%esp)
  800e09:	e8 b8 0f 00 00       	call   801dc6 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e0e:	83 c4 2c             	add    $0x2c,%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	57                   	push   %edi
  800e1a:	56                   	push   %esi
  800e1b:	53                   	push   %ebx
  800e1c:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e24:	b8 09 00 00 00       	mov    $0x9,%eax
  800e29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2f:	89 df                	mov    %ebx,%edi
  800e31:	89 de                	mov    %ebx,%esi
  800e33:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e35:	85 c0                	test   %eax,%eax
  800e37:	7e 28                	jle    800e61 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e44:	00 
  800e45:	c7 44 24 08 3f 24 80 	movl   $0x80243f,0x8(%esp)
  800e4c:	00 
  800e4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e54:	00 
  800e55:	c7 04 24 5c 24 80 00 	movl   $0x80245c,(%esp)
  800e5c:	e8 65 0f 00 00       	call   801dc6 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e61:	83 c4 2c             	add    $0x2c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	57                   	push   %edi
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
  800e6f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e77:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e82:	89 df                	mov    %ebx,%edi
  800e84:	89 de                	mov    %ebx,%esi
  800e86:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	7e 28                	jle    800eb4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e90:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e97:	00 
  800e98:	c7 44 24 08 3f 24 80 	movl   $0x80243f,0x8(%esp)
  800e9f:	00 
  800ea0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea7:	00 
  800ea8:	c7 04 24 5c 24 80 00 	movl   $0x80245c,(%esp)
  800eaf:	e8 12 0f 00 00       	call   801dc6 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb4:	83 c4 2c             	add    $0x2c,%esp
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	57                   	push   %edi
  800ec0:	56                   	push   %esi
  800ec1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ec2:	be 00 00 00 00       	mov    $0x0,%esi
  800ec7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ecc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eda:	5b                   	pop    %ebx
  800edb:	5e                   	pop    %esi
  800edc:	5f                   	pop    %edi
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
  800ee5:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ee8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eed:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef5:	89 cb                	mov    %ecx,%ebx
  800ef7:	89 cf                	mov    %ecx,%edi
  800ef9:	89 ce                	mov    %ecx,%esi
  800efb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800efd:	85 c0                	test   %eax,%eax
  800eff:	7e 28                	jle    800f29 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f01:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f05:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 08 3f 24 80 	movl   $0x80243f,0x8(%esp)
  800f14:	00 
  800f15:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1c:	00 
  800f1d:	c7 04 24 5c 24 80 00 	movl   $0x80245c,(%esp)
  800f24:	e8 9d 0e 00 00       	call   801dc6 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f29:	83 c4 2c             	add    $0x2c,%esp
  800f2c:	5b                   	pop    %ebx
  800f2d:	5e                   	pop    %esi
  800f2e:	5f                   	pop    %edi
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
  800f36:	83 ec 10             	sub    $0x10,%esp
  800f39:	8b 75 08             	mov    0x8(%ebp),%esi
  800f3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  800f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f42:	89 04 24             	mov    %eax,(%esp)
  800f45:	e8 95 ff ff ff       	call   800edf <sys_ipc_recv>
	if(from_env_store)
  800f4a:	85 f6                	test   %esi,%esi
  800f4c:	74 14                	je     800f62 <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  800f4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f53:	85 c0                	test   %eax,%eax
  800f55:	78 09                	js     800f60 <ipc_recv+0x2f>
  800f57:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f5d:	8b 52 74             	mov    0x74(%edx),%edx
  800f60:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  800f62:	85 db                	test   %ebx,%ebx
  800f64:	74 14                	je     800f7a <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  800f66:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	78 09                	js     800f78 <ipc_recv+0x47>
  800f6f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f75:	8b 52 78             	mov    0x78(%edx),%edx
  800f78:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	78 08                	js     800f86 <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  800f7e:	a1 04 40 80 00       	mov    0x804004,%eax
  800f83:	8b 40 70             	mov    0x70(%eax),%eax
}
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	57                   	push   %edi
  800f91:	56                   	push   %esi
  800f92:	53                   	push   %ebx
  800f93:	83 ec 1c             	sub    $0x1c,%esp
  800f96:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f99:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  800f9c:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  800fa1:	eb 0c                	jmp    800faf <ipc_send+0x22>
		failed_cnt++;
  800fa3:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  800fa6:	84 db                	test   %bl,%bl
  800fa8:	75 05                	jne    800faf <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  800faa:	e8 fb fc ff ff       	call   800caa <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  800faf:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fb6:	8b 45 10             	mov    0x10(%ebp),%eax
  800fb9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fbd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fc1:	89 3c 24             	mov    %edi,(%esp)
  800fc4:	e8 f3 fe ff ff       	call   800ebc <sys_ipc_try_send>
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	78 d6                	js     800fa3 <ipc_send+0x16>
	}
}
  800fcd:	83 c4 1c             	add    $0x1c,%esp
  800fd0:	5b                   	pop    %ebx
  800fd1:	5e                   	pop    %esi
  800fd2:	5f                   	pop    %edi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    

00800fd5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  800fdb:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  800fe0:	39 c8                	cmp    %ecx,%eax
  800fe2:	74 17                	je     800ffb <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  800fe4:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  800fe9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800fec:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800ff2:	8b 52 50             	mov    0x50(%edx),%edx
  800ff5:	39 ca                	cmp    %ecx,%edx
  800ff7:	75 14                	jne    80100d <ipc_find_env+0x38>
  800ff9:	eb 05                	jmp    801000 <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  800ffb:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  801000:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801003:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801008:	8b 40 40             	mov    0x40(%eax),%eax
  80100b:	eb 0e                	jmp    80101b <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  80100d:	83 c0 01             	add    $0x1,%eax
  801010:	3d 00 04 00 00       	cmp    $0x400,%eax
  801015:	75 d2                	jne    800fe9 <ipc_find_env+0x14>
	return 0;
  801017:	66 b8 00 00          	mov    $0x0,%ax
}
  80101b:	5d                   	pop    %ebp
  80101c:	c3                   	ret    
  80101d:	66 90                	xchg   %ax,%ax
  80101f:	90                   	nop

00801020 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801023:	8b 45 08             	mov    0x8(%ebp),%eax
  801026:	05 00 00 00 30       	add    $0x30000000,%eax
  80102b:	c1 e8 0c             	shr    $0xc,%eax
}
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801033:	8b 45 08             	mov    0x8(%ebp),%eax
  801036:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80103b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801040:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    

00801047 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80104a:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80104f:	a8 01                	test   $0x1,%al
  801051:	74 34                	je     801087 <fd_alloc+0x40>
  801053:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801058:	a8 01                	test   $0x1,%al
  80105a:	74 32                	je     80108e <fd_alloc+0x47>
  80105c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  801061:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801063:	89 c2                	mov    %eax,%edx
  801065:	c1 ea 16             	shr    $0x16,%edx
  801068:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80106f:	f6 c2 01             	test   $0x1,%dl
  801072:	74 1f                	je     801093 <fd_alloc+0x4c>
  801074:	89 c2                	mov    %eax,%edx
  801076:	c1 ea 0c             	shr    $0xc,%edx
  801079:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801080:	f6 c2 01             	test   $0x1,%dl
  801083:	75 1a                	jne    80109f <fd_alloc+0x58>
  801085:	eb 0c                	jmp    801093 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  801087:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80108c:	eb 05                	jmp    801093 <fd_alloc+0x4c>
  80108e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  801093:	8b 45 08             	mov    0x8(%ebp),%eax
  801096:	89 08                	mov    %ecx,(%eax)
			return 0;
  801098:	b8 00 00 00 00       	mov    $0x0,%eax
  80109d:	eb 1a                	jmp    8010b9 <fd_alloc+0x72>
  80109f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8010a4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010a9:	75 b6                	jne    801061 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  8010ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8010b4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010c1:	83 f8 1f             	cmp    $0x1f,%eax
  8010c4:	77 36                	ja     8010fc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010c6:	c1 e0 0c             	shl    $0xc,%eax
  8010c9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010ce:	89 c2                	mov    %eax,%edx
  8010d0:	c1 ea 16             	shr    $0x16,%edx
  8010d3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010da:	f6 c2 01             	test   $0x1,%dl
  8010dd:	74 24                	je     801103 <fd_lookup+0x48>
  8010df:	89 c2                	mov    %eax,%edx
  8010e1:	c1 ea 0c             	shr    $0xc,%edx
  8010e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010eb:	f6 c2 01             	test   $0x1,%dl
  8010ee:	74 1a                	je     80110a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f3:	89 02                	mov    %eax,(%edx)
	return 0;
  8010f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fa:	eb 13                	jmp    80110f <fd_lookup+0x54>
		return -E_INVAL;
  8010fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801101:	eb 0c                	jmp    80110f <fd_lookup+0x54>
		return -E_INVAL;
  801103:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801108:	eb 05                	jmp    80110f <fd_lookup+0x54>
  80110a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	53                   	push   %ebx
  801115:	83 ec 14             	sub    $0x14,%esp
  801118:	8b 45 08             	mov    0x8(%ebp),%eax
  80111b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80111e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801124:	75 1e                	jne    801144 <dev_lookup+0x33>
  801126:	eb 0e                	jmp    801136 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  801128:	b8 20 30 80 00       	mov    $0x803020,%eax
  80112d:	eb 0c                	jmp    80113b <dev_lookup+0x2a>
  80112f:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801134:	eb 05                	jmp    80113b <dev_lookup+0x2a>
  801136:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  80113b:	89 03                	mov    %eax,(%ebx)
			return 0;
  80113d:	b8 00 00 00 00       	mov    $0x0,%eax
  801142:	eb 38                	jmp    80117c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  801144:	39 05 20 30 80 00    	cmp    %eax,0x803020
  80114a:	74 dc                	je     801128 <dev_lookup+0x17>
  80114c:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  801152:	74 db                	je     80112f <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801154:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80115a:	8b 52 48             	mov    0x48(%edx),%edx
  80115d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801161:	89 54 24 04          	mov    %edx,0x4(%esp)
  801165:	c7 04 24 6c 24 80 00 	movl   $0x80246c,(%esp)
  80116c:	e8 55 f0 ff ff       	call   8001c6 <cprintf>
	*dev = 0;
  801171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801177:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80117c:	83 c4 14             	add    $0x14,%esp
  80117f:	5b                   	pop    %ebx
  801180:	5d                   	pop    %ebp
  801181:	c3                   	ret    

00801182 <fd_close>:
{
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
  801185:	56                   	push   %esi
  801186:	53                   	push   %ebx
  801187:	83 ec 20             	sub    $0x20,%esp
  80118a:	8b 75 08             	mov    0x8(%ebp),%esi
  80118d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801190:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801193:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801197:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80119d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011a0:	89 04 24             	mov    %eax,(%esp)
  8011a3:	e8 13 ff ff ff       	call   8010bb <fd_lookup>
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	78 05                	js     8011b1 <fd_close+0x2f>
	    || fd != fd2)
  8011ac:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011af:	74 0c                	je     8011bd <fd_close+0x3b>
		return (must_exist ? r : 0);
  8011b1:	84 db                	test   %bl,%bl
  8011b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b8:	0f 44 c2             	cmove  %edx,%eax
  8011bb:	eb 3f                	jmp    8011fc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c4:	8b 06                	mov    (%esi),%eax
  8011c6:	89 04 24             	mov    %eax,(%esp)
  8011c9:	e8 43 ff ff ff       	call   801111 <dev_lookup>
  8011ce:	89 c3                	mov    %eax,%ebx
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	78 16                	js     8011ea <fd_close+0x68>
		if (dev->dev_close)
  8011d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d7:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8011da:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	74 07                	je     8011ea <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8011e3:	89 34 24             	mov    %esi,(%esp)
  8011e6:	ff d0                	call   *%eax
  8011e8:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8011ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f5:	e8 76 fb ff ff       	call   800d70 <sys_page_unmap>
	return r;
  8011fa:	89 d8                	mov    %ebx,%eax
}
  8011fc:	83 c4 20             	add    $0x20,%esp
  8011ff:	5b                   	pop    %ebx
  801200:	5e                   	pop    %esi
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <close>:

int
close(int fdnum)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801209:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801210:	8b 45 08             	mov    0x8(%ebp),%eax
  801213:	89 04 24             	mov    %eax,(%esp)
  801216:	e8 a0 fe ff ff       	call   8010bb <fd_lookup>
  80121b:	89 c2                	mov    %eax,%edx
  80121d:	85 d2                	test   %edx,%edx
  80121f:	78 13                	js     801234 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801221:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801228:	00 
  801229:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122c:	89 04 24             	mov    %eax,(%esp)
  80122f:	e8 4e ff ff ff       	call   801182 <fd_close>
}
  801234:	c9                   	leave  
  801235:	c3                   	ret    

00801236 <close_all>:

void
close_all(void)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	53                   	push   %ebx
  80123a:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80123d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801242:	89 1c 24             	mov    %ebx,(%esp)
  801245:	e8 b9 ff ff ff       	call   801203 <close>
	for (i = 0; i < MAXFD; i++)
  80124a:	83 c3 01             	add    $0x1,%ebx
  80124d:	83 fb 20             	cmp    $0x20,%ebx
  801250:	75 f0                	jne    801242 <close_all+0xc>
}
  801252:	83 c4 14             	add    $0x14,%esp
  801255:	5b                   	pop    %ebx
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	57                   	push   %edi
  80125c:	56                   	push   %esi
  80125d:	53                   	push   %ebx
  80125e:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801261:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801264:	89 44 24 04          	mov    %eax,0x4(%esp)
  801268:	8b 45 08             	mov    0x8(%ebp),%eax
  80126b:	89 04 24             	mov    %eax,(%esp)
  80126e:	e8 48 fe ff ff       	call   8010bb <fd_lookup>
  801273:	89 c2                	mov    %eax,%edx
  801275:	85 d2                	test   %edx,%edx
  801277:	0f 88 e1 00 00 00    	js     80135e <dup+0x106>
		return r;
	close(newfdnum);
  80127d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801280:	89 04 24             	mov    %eax,(%esp)
  801283:	e8 7b ff ff ff       	call   801203 <close>

	newfd = INDEX2FD(newfdnum);
  801288:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80128b:	c1 e3 0c             	shl    $0xc,%ebx
  80128e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801294:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801297:	89 04 24             	mov    %eax,(%esp)
  80129a:	e8 91 fd ff ff       	call   801030 <fd2data>
  80129f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8012a1:	89 1c 24             	mov    %ebx,(%esp)
  8012a4:	e8 87 fd ff ff       	call   801030 <fd2data>
  8012a9:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012ab:	89 f0                	mov    %esi,%eax
  8012ad:	c1 e8 16             	shr    $0x16,%eax
  8012b0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012b7:	a8 01                	test   $0x1,%al
  8012b9:	74 43                	je     8012fe <dup+0xa6>
  8012bb:	89 f0                	mov    %esi,%eax
  8012bd:	c1 e8 0c             	shr    $0xc,%eax
  8012c0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012c7:	f6 c2 01             	test   $0x1,%dl
  8012ca:	74 32                	je     8012fe <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d3:	25 07 0e 00 00       	and    $0xe07,%eax
  8012d8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012dc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012e7:	00 
  8012e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012f3:	e8 25 fa ff ff       	call   800d1d <sys_page_map>
  8012f8:	89 c6                	mov    %eax,%esi
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 3e                	js     80133c <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801301:	89 c2                	mov    %eax,%edx
  801303:	c1 ea 0c             	shr    $0xc,%edx
  801306:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80130d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801313:	89 54 24 10          	mov    %edx,0x10(%esp)
  801317:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80131b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801322:	00 
  801323:	89 44 24 04          	mov    %eax,0x4(%esp)
  801327:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80132e:	e8 ea f9 ff ff       	call   800d1d <sys_page_map>
  801333:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801335:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801338:	85 f6                	test   %esi,%esi
  80133a:	79 22                	jns    80135e <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80133c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801340:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801347:	e8 24 fa ff ff       	call   800d70 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80134c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801350:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801357:	e8 14 fa ff ff       	call   800d70 <sys_page_unmap>
	return r;
  80135c:	89 f0                	mov    %esi,%eax
}
  80135e:	83 c4 3c             	add    $0x3c,%esp
  801361:	5b                   	pop    %ebx
  801362:	5e                   	pop    %esi
  801363:	5f                   	pop    %edi
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    

00801366 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	53                   	push   %ebx
  80136a:	83 ec 24             	sub    $0x24,%esp
  80136d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801370:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801373:	89 44 24 04          	mov    %eax,0x4(%esp)
  801377:	89 1c 24             	mov    %ebx,(%esp)
  80137a:	e8 3c fd ff ff       	call   8010bb <fd_lookup>
  80137f:	89 c2                	mov    %eax,%edx
  801381:	85 d2                	test   %edx,%edx
  801383:	78 6d                	js     8013f2 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801385:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801388:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138f:	8b 00                	mov    (%eax),%eax
  801391:	89 04 24             	mov    %eax,(%esp)
  801394:	e8 78 fd ff ff       	call   801111 <dev_lookup>
  801399:	85 c0                	test   %eax,%eax
  80139b:	78 55                	js     8013f2 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80139d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a0:	8b 50 08             	mov    0x8(%eax),%edx
  8013a3:	83 e2 03             	and    $0x3,%edx
  8013a6:	83 fa 01             	cmp    $0x1,%edx
  8013a9:	75 23                	jne    8013ce <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013ab:	a1 04 40 80 00       	mov    0x804004,%eax
  8013b0:	8b 40 48             	mov    0x48(%eax),%eax
  8013b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bb:	c7 04 24 ad 24 80 00 	movl   $0x8024ad,(%esp)
  8013c2:	e8 ff ed ff ff       	call   8001c6 <cprintf>
		return -E_INVAL;
  8013c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013cc:	eb 24                	jmp    8013f2 <read+0x8c>
	}
	if (!dev->dev_read)
  8013ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013d1:	8b 52 08             	mov    0x8(%edx),%edx
  8013d4:	85 d2                	test   %edx,%edx
  8013d6:	74 15                	je     8013ed <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013e6:	89 04 24             	mov    %eax,(%esp)
  8013e9:	ff d2                	call   *%edx
  8013eb:	eb 05                	jmp    8013f2 <read+0x8c>
		return -E_NOT_SUPP;
  8013ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8013f2:	83 c4 24             	add    $0x24,%esp
  8013f5:	5b                   	pop    %ebx
  8013f6:	5d                   	pop    %ebp
  8013f7:	c3                   	ret    

008013f8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	57                   	push   %edi
  8013fc:	56                   	push   %esi
  8013fd:	53                   	push   %ebx
  8013fe:	83 ec 1c             	sub    $0x1c,%esp
  801401:	8b 7d 08             	mov    0x8(%ebp),%edi
  801404:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801407:	85 f6                	test   %esi,%esi
  801409:	74 33                	je     80143e <readn+0x46>
  80140b:	b8 00 00 00 00       	mov    $0x0,%eax
  801410:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801415:	89 f2                	mov    %esi,%edx
  801417:	29 c2                	sub    %eax,%edx
  801419:	89 54 24 08          	mov    %edx,0x8(%esp)
  80141d:	03 45 0c             	add    0xc(%ebp),%eax
  801420:	89 44 24 04          	mov    %eax,0x4(%esp)
  801424:	89 3c 24             	mov    %edi,(%esp)
  801427:	e8 3a ff ff ff       	call   801366 <read>
		if (m < 0)
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 1b                	js     80144b <readn+0x53>
			return m;
		if (m == 0)
  801430:	85 c0                	test   %eax,%eax
  801432:	74 11                	je     801445 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  801434:	01 c3                	add    %eax,%ebx
  801436:	89 d8                	mov    %ebx,%eax
  801438:	39 f3                	cmp    %esi,%ebx
  80143a:	72 d9                	jb     801415 <readn+0x1d>
  80143c:	eb 0b                	jmp    801449 <readn+0x51>
  80143e:	b8 00 00 00 00       	mov    $0x0,%eax
  801443:	eb 06                	jmp    80144b <readn+0x53>
  801445:	89 d8                	mov    %ebx,%eax
  801447:	eb 02                	jmp    80144b <readn+0x53>
  801449:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80144b:	83 c4 1c             	add    $0x1c,%esp
  80144e:	5b                   	pop    %ebx
  80144f:	5e                   	pop    %esi
  801450:	5f                   	pop    %edi
  801451:	5d                   	pop    %ebp
  801452:	c3                   	ret    

00801453 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	53                   	push   %ebx
  801457:	83 ec 24             	sub    $0x24,%esp
  80145a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801460:	89 44 24 04          	mov    %eax,0x4(%esp)
  801464:	89 1c 24             	mov    %ebx,(%esp)
  801467:	e8 4f fc ff ff       	call   8010bb <fd_lookup>
  80146c:	89 c2                	mov    %eax,%edx
  80146e:	85 d2                	test   %edx,%edx
  801470:	78 68                	js     8014da <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801472:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801475:	89 44 24 04          	mov    %eax,0x4(%esp)
  801479:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147c:	8b 00                	mov    (%eax),%eax
  80147e:	89 04 24             	mov    %eax,(%esp)
  801481:	e8 8b fc ff ff       	call   801111 <dev_lookup>
  801486:	85 c0                	test   %eax,%eax
  801488:	78 50                	js     8014da <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80148a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801491:	75 23                	jne    8014b6 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801493:	a1 04 40 80 00       	mov    0x804004,%eax
  801498:	8b 40 48             	mov    0x48(%eax),%eax
  80149b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80149f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a3:	c7 04 24 c9 24 80 00 	movl   $0x8024c9,(%esp)
  8014aa:	e8 17 ed ff ff       	call   8001c6 <cprintf>
		return -E_INVAL;
  8014af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b4:	eb 24                	jmp    8014da <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b9:	8b 52 0c             	mov    0xc(%edx),%edx
  8014bc:	85 d2                	test   %edx,%edx
  8014be:	74 15                	je     8014d5 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ca:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014ce:	89 04 24             	mov    %eax,(%esp)
  8014d1:	ff d2                	call   *%edx
  8014d3:	eb 05                	jmp    8014da <write+0x87>
		return -E_NOT_SUPP;
  8014d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8014da:	83 c4 24             	add    $0x24,%esp
  8014dd:	5b                   	pop    %ebx
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f0:	89 04 24             	mov    %eax,(%esp)
  8014f3:	e8 c3 fb ff ff       	call   8010bb <fd_lookup>
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	78 0e                	js     80150a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8014fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801502:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801505:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80150a:	c9                   	leave  
  80150b:	c3                   	ret    

0080150c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	53                   	push   %ebx
  801510:	83 ec 24             	sub    $0x24,%esp
  801513:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801516:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801519:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151d:	89 1c 24             	mov    %ebx,(%esp)
  801520:	e8 96 fb ff ff       	call   8010bb <fd_lookup>
  801525:	89 c2                	mov    %eax,%edx
  801527:	85 d2                	test   %edx,%edx
  801529:	78 61                	js     80158c <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801532:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801535:	8b 00                	mov    (%eax),%eax
  801537:	89 04 24             	mov    %eax,(%esp)
  80153a:	e8 d2 fb ff ff       	call   801111 <dev_lookup>
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 49                	js     80158c <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801543:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801546:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154a:	75 23                	jne    80156f <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80154c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801551:	8b 40 48             	mov    0x48(%eax),%eax
  801554:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155c:	c7 04 24 8c 24 80 00 	movl   $0x80248c,(%esp)
  801563:	e8 5e ec ff ff       	call   8001c6 <cprintf>
		return -E_INVAL;
  801568:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156d:	eb 1d                	jmp    80158c <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80156f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801572:	8b 52 18             	mov    0x18(%edx),%edx
  801575:	85 d2                	test   %edx,%edx
  801577:	74 0e                	je     801587 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801579:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80157c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801580:	89 04 24             	mov    %eax,(%esp)
  801583:	ff d2                	call   *%edx
  801585:	eb 05                	jmp    80158c <ftruncate+0x80>
		return -E_NOT_SUPP;
  801587:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80158c:	83 c4 24             	add    $0x24,%esp
  80158f:	5b                   	pop    %ebx
  801590:	5d                   	pop    %ebp
  801591:	c3                   	ret    

00801592 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	53                   	push   %ebx
  801596:	83 ec 24             	sub    $0x24,%esp
  801599:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a6:	89 04 24             	mov    %eax,(%esp)
  8015a9:	e8 0d fb ff ff       	call   8010bb <fd_lookup>
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	85 d2                	test   %edx,%edx
  8015b2:	78 52                	js     801606 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015be:	8b 00                	mov    (%eax),%eax
  8015c0:	89 04 24             	mov    %eax,(%esp)
  8015c3:	e8 49 fb ff ff       	call   801111 <dev_lookup>
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	78 3a                	js     801606 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8015cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015cf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015d3:	74 2c                	je     801601 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015d5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015d8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015df:	00 00 00 
	stat->st_isdir = 0;
  8015e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015e9:	00 00 00 
	stat->st_dev = dev;
  8015ec:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015f9:	89 14 24             	mov    %edx,(%esp)
  8015fc:	ff 50 14             	call   *0x14(%eax)
  8015ff:	eb 05                	jmp    801606 <fstat+0x74>
		return -E_NOT_SUPP;
  801601:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801606:	83 c4 24             	add    $0x24,%esp
  801609:	5b                   	pop    %ebx
  80160a:	5d                   	pop    %ebp
  80160b:	c3                   	ret    

0080160c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	56                   	push   %esi
  801610:	53                   	push   %ebx
  801611:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801614:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80161b:	00 
  80161c:	8b 45 08             	mov    0x8(%ebp),%eax
  80161f:	89 04 24             	mov    %eax,(%esp)
  801622:	e8 af 01 00 00       	call   8017d6 <open>
  801627:	89 c3                	mov    %eax,%ebx
  801629:	85 db                	test   %ebx,%ebx
  80162b:	78 1b                	js     801648 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80162d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801630:	89 44 24 04          	mov    %eax,0x4(%esp)
  801634:	89 1c 24             	mov    %ebx,(%esp)
  801637:	e8 56 ff ff ff       	call   801592 <fstat>
  80163c:	89 c6                	mov    %eax,%esi
	close(fd);
  80163e:	89 1c 24             	mov    %ebx,(%esp)
  801641:	e8 bd fb ff ff       	call   801203 <close>
	return r;
  801646:	89 f0                	mov    %esi,%eax
}
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	5b                   	pop    %ebx
  80164c:	5e                   	pop    %esi
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    

0080164f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	56                   	push   %esi
  801653:	53                   	push   %ebx
  801654:	83 ec 10             	sub    $0x10,%esp
  801657:	89 c6                	mov    %eax,%esi
  801659:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80165b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801662:	75 11                	jne    801675 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801664:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80166b:	e8 65 f9 ff ff       	call   800fd5 <ipc_find_env>
  801670:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801675:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80167c:	00 
  80167d:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801684:	00 
  801685:	89 74 24 04          	mov    %esi,0x4(%esp)
  801689:	a1 00 40 80 00       	mov    0x804000,%eax
  80168e:	89 04 24             	mov    %eax,(%esp)
  801691:	e8 f7 f8 ff ff       	call   800f8d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801696:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80169d:	00 
  80169e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a9:	e8 83 f8 ff ff       	call   800f31 <ipc_recv>
}
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	5b                   	pop    %ebx
  8016b2:	5e                   	pop    %esi
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 14             	sub    $0x14,%esp
  8016bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cf:	b8 05 00 00 00       	mov    $0x5,%eax
  8016d4:	e8 76 ff ff ff       	call   80164f <fsipc>
  8016d9:	89 c2                	mov    %eax,%edx
  8016db:	85 d2                	test   %edx,%edx
  8016dd:	78 2b                	js     80170a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016df:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016e6:	00 
  8016e7:	89 1c 24             	mov    %ebx,(%esp)
  8016ea:	e8 2c f1 ff ff       	call   80081b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ef:	a1 80 50 80 00       	mov    0x805080,%eax
  8016f4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016fa:	a1 84 50 80 00       	mov    0x805084,%eax
  8016ff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801705:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80170a:	83 c4 14             	add    $0x14,%esp
  80170d:	5b                   	pop    %ebx
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    

00801710 <devfile_flush>:
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801716:	8b 45 08             	mov    0x8(%ebp),%eax
  801719:	8b 40 0c             	mov    0xc(%eax),%eax
  80171c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801721:	ba 00 00 00 00       	mov    $0x0,%edx
  801726:	b8 06 00 00 00       	mov    $0x6,%eax
  80172b:	e8 1f ff ff ff       	call   80164f <fsipc>
}
  801730:	c9                   	leave  
  801731:	c3                   	ret    

00801732 <devfile_read>:
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	56                   	push   %esi
  801736:	53                   	push   %ebx
  801737:	83 ec 10             	sub    $0x10,%esp
  80173a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80173d:	8b 45 08             	mov    0x8(%ebp),%eax
  801740:	8b 40 0c             	mov    0xc(%eax),%eax
  801743:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801748:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80174e:	ba 00 00 00 00       	mov    $0x0,%edx
  801753:	b8 03 00 00 00       	mov    $0x3,%eax
  801758:	e8 f2 fe ff ff       	call   80164f <fsipc>
  80175d:	89 c3                	mov    %eax,%ebx
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 6a                	js     8017cd <devfile_read+0x9b>
	assert(r <= n);
  801763:	39 c6                	cmp    %eax,%esi
  801765:	73 24                	jae    80178b <devfile_read+0x59>
  801767:	c7 44 24 0c e6 24 80 	movl   $0x8024e6,0xc(%esp)
  80176e:	00 
  80176f:	c7 44 24 08 ed 24 80 	movl   $0x8024ed,0x8(%esp)
  801776:	00 
  801777:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80177e:	00 
  80177f:	c7 04 24 02 25 80 00 	movl   $0x802502,(%esp)
  801786:	e8 3b 06 00 00       	call   801dc6 <_panic>
	assert(r <= PGSIZE);
  80178b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801790:	7e 24                	jle    8017b6 <devfile_read+0x84>
  801792:	c7 44 24 0c 0d 25 80 	movl   $0x80250d,0xc(%esp)
  801799:	00 
  80179a:	c7 44 24 08 ed 24 80 	movl   $0x8024ed,0x8(%esp)
  8017a1:	00 
  8017a2:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  8017a9:	00 
  8017aa:	c7 04 24 02 25 80 00 	movl   $0x802502,(%esp)
  8017b1:	e8 10 06 00 00       	call   801dc6 <_panic>
	memmove(buf, &fsipcbuf, r);
  8017b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ba:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017c1:	00 
  8017c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c5:	89 04 24             	mov    %eax,(%esp)
  8017c8:	e8 49 f2 ff ff       	call   800a16 <memmove>
}
  8017cd:	89 d8                	mov    %ebx,%eax
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	5b                   	pop    %ebx
  8017d3:	5e                   	pop    %esi
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <open>:
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 24             	sub    $0x24,%esp
  8017dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8017e0:	89 1c 24             	mov    %ebx,(%esp)
  8017e3:	e8 d8 ef ff ff       	call   8007c0 <strlen>
  8017e8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017ed:	7f 60                	jg     80184f <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  8017ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f2:	89 04 24             	mov    %eax,(%esp)
  8017f5:	e8 4d f8 ff ff       	call   801047 <fd_alloc>
  8017fa:	89 c2                	mov    %eax,%edx
  8017fc:	85 d2                	test   %edx,%edx
  8017fe:	78 54                	js     801854 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801800:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801804:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80180b:	e8 0b f0 ff ff       	call   80081b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801810:	8b 45 0c             	mov    0xc(%ebp),%eax
  801813:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801818:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80181b:	b8 01 00 00 00       	mov    $0x1,%eax
  801820:	e8 2a fe ff ff       	call   80164f <fsipc>
  801825:	89 c3                	mov    %eax,%ebx
  801827:	85 c0                	test   %eax,%eax
  801829:	79 17                	jns    801842 <open+0x6c>
		fd_close(fd, 0);
  80182b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801832:	00 
  801833:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801836:	89 04 24             	mov    %eax,(%esp)
  801839:	e8 44 f9 ff ff       	call   801182 <fd_close>
		return r;
  80183e:	89 d8                	mov    %ebx,%eax
  801840:	eb 12                	jmp    801854 <open+0x7e>
	return fd2num(fd);
  801842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801845:	89 04 24             	mov    %eax,(%esp)
  801848:	e8 d3 f7 ff ff       	call   801020 <fd2num>
  80184d:	eb 05                	jmp    801854 <open+0x7e>
		return -E_BAD_PATH;
  80184f:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801854:	83 c4 24             	add    $0x24,%esp
  801857:	5b                   	pop    %ebx
  801858:	5d                   	pop    %ebp
  801859:	c3                   	ret    
  80185a:	66 90                	xchg   %ax,%ax
  80185c:	66 90                	xchg   %ax,%ax
  80185e:	66 90                	xchg   %ax,%ax

00801860 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	56                   	push   %esi
  801864:	53                   	push   %ebx
  801865:	83 ec 10             	sub    $0x10,%esp
  801868:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80186b:	8b 45 08             	mov    0x8(%ebp),%eax
  80186e:	89 04 24             	mov    %eax,(%esp)
  801871:	e8 ba f7 ff ff       	call   801030 <fd2data>
  801876:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801878:	c7 44 24 04 19 25 80 	movl   $0x802519,0x4(%esp)
  80187f:	00 
  801880:	89 1c 24             	mov    %ebx,(%esp)
  801883:	e8 93 ef ff ff       	call   80081b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801888:	8b 46 04             	mov    0x4(%esi),%eax
  80188b:	2b 06                	sub    (%esi),%eax
  80188d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801893:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80189a:	00 00 00 
	stat->st_dev = &devpipe;
  80189d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018a4:	30 80 00 
	return 0;
}
  8018a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	5b                   	pop    %ebx
  8018b0:	5e                   	pop    %esi
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	53                   	push   %ebx
  8018b7:	83 ec 14             	sub    $0x14,%esp
  8018ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018c8:	e8 a3 f4 ff ff       	call   800d70 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018cd:	89 1c 24             	mov    %ebx,(%esp)
  8018d0:	e8 5b f7 ff ff       	call   801030 <fd2data>
  8018d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e0:	e8 8b f4 ff ff       	call   800d70 <sys_page_unmap>
}
  8018e5:	83 c4 14             	add    $0x14,%esp
  8018e8:	5b                   	pop    %ebx
  8018e9:	5d                   	pop    %ebp
  8018ea:	c3                   	ret    

008018eb <_pipeisclosed>:
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	57                   	push   %edi
  8018ef:	56                   	push   %esi
  8018f0:	53                   	push   %ebx
  8018f1:	83 ec 2c             	sub    $0x2c,%esp
  8018f4:	89 c6                	mov    %eax,%esi
  8018f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  8018f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8018fe:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801901:	89 34 24             	mov    %esi,(%esp)
  801904:	e8 13 05 00 00       	call   801e1c <pageref>
  801909:	89 c7                	mov    %eax,%edi
  80190b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80190e:	89 04 24             	mov    %eax,(%esp)
  801911:	e8 06 05 00 00       	call   801e1c <pageref>
  801916:	39 c7                	cmp    %eax,%edi
  801918:	0f 94 c2             	sete   %dl
  80191b:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80191e:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801924:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801927:	39 fb                	cmp    %edi,%ebx
  801929:	74 21                	je     80194c <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  80192b:	84 d2                	test   %dl,%dl
  80192d:	74 ca                	je     8018f9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80192f:	8b 51 58             	mov    0x58(%ecx),%edx
  801932:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801936:	89 54 24 08          	mov    %edx,0x8(%esp)
  80193a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80193e:	c7 04 24 20 25 80 00 	movl   $0x802520,(%esp)
  801945:	e8 7c e8 ff ff       	call   8001c6 <cprintf>
  80194a:	eb ad                	jmp    8018f9 <_pipeisclosed+0xe>
}
  80194c:	83 c4 2c             	add    $0x2c,%esp
  80194f:	5b                   	pop    %ebx
  801950:	5e                   	pop    %esi
  801951:	5f                   	pop    %edi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <devpipe_write>:
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	57                   	push   %edi
  801958:	56                   	push   %esi
  801959:	53                   	push   %ebx
  80195a:	83 ec 1c             	sub    $0x1c,%esp
  80195d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801960:	89 34 24             	mov    %esi,(%esp)
  801963:	e8 c8 f6 ff ff       	call   801030 <fd2data>
	for (i = 0; i < n; i++) {
  801968:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80196c:	74 61                	je     8019cf <devpipe_write+0x7b>
  80196e:	89 c3                	mov    %eax,%ebx
  801970:	bf 00 00 00 00       	mov    $0x0,%edi
  801975:	eb 4a                	jmp    8019c1 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  801977:	89 da                	mov    %ebx,%edx
  801979:	89 f0                	mov    %esi,%eax
  80197b:	e8 6b ff ff ff       	call   8018eb <_pipeisclosed>
  801980:	85 c0                	test   %eax,%eax
  801982:	75 54                	jne    8019d8 <devpipe_write+0x84>
			sys_yield();
  801984:	e8 21 f3 ff ff       	call   800caa <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801989:	8b 43 04             	mov    0x4(%ebx),%eax
  80198c:	8b 0b                	mov    (%ebx),%ecx
  80198e:	8d 51 20             	lea    0x20(%ecx),%edx
  801991:	39 d0                	cmp    %edx,%eax
  801993:	73 e2                	jae    801977 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801995:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801998:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80199c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80199f:	99                   	cltd   
  8019a0:	c1 ea 1b             	shr    $0x1b,%edx
  8019a3:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8019a6:	83 e1 1f             	and    $0x1f,%ecx
  8019a9:	29 d1                	sub    %edx,%ecx
  8019ab:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8019af:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8019b3:	83 c0 01             	add    $0x1,%eax
  8019b6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8019b9:	83 c7 01             	add    $0x1,%edi
  8019bc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019bf:	74 13                	je     8019d4 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019c1:	8b 43 04             	mov    0x4(%ebx),%eax
  8019c4:	8b 0b                	mov    (%ebx),%ecx
  8019c6:	8d 51 20             	lea    0x20(%ecx),%edx
  8019c9:	39 d0                	cmp    %edx,%eax
  8019cb:	73 aa                	jae    801977 <devpipe_write+0x23>
  8019cd:	eb c6                	jmp    801995 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  8019cf:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  8019d4:	89 f8                	mov    %edi,%eax
  8019d6:	eb 05                	jmp    8019dd <devpipe_write+0x89>
				return 0;
  8019d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019dd:	83 c4 1c             	add    $0x1c,%esp
  8019e0:	5b                   	pop    %ebx
  8019e1:	5e                   	pop    %esi
  8019e2:	5f                   	pop    %edi
  8019e3:	5d                   	pop    %ebp
  8019e4:	c3                   	ret    

008019e5 <devpipe_read>:
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	57                   	push   %edi
  8019e9:	56                   	push   %esi
  8019ea:	53                   	push   %ebx
  8019eb:	83 ec 1c             	sub    $0x1c,%esp
  8019ee:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8019f1:	89 3c 24             	mov    %edi,(%esp)
  8019f4:	e8 37 f6 ff ff       	call   801030 <fd2data>
	for (i = 0; i < n; i++) {
  8019f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019fd:	74 54                	je     801a53 <devpipe_read+0x6e>
  8019ff:	89 c3                	mov    %eax,%ebx
  801a01:	be 00 00 00 00       	mov    $0x0,%esi
  801a06:	eb 3e                	jmp    801a46 <devpipe_read+0x61>
				return i;
  801a08:	89 f0                	mov    %esi,%eax
  801a0a:	eb 55                	jmp    801a61 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  801a0c:	89 da                	mov    %ebx,%edx
  801a0e:	89 f8                	mov    %edi,%eax
  801a10:	e8 d6 fe ff ff       	call   8018eb <_pipeisclosed>
  801a15:	85 c0                	test   %eax,%eax
  801a17:	75 43                	jne    801a5c <devpipe_read+0x77>
			sys_yield();
  801a19:	e8 8c f2 ff ff       	call   800caa <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801a1e:	8b 03                	mov    (%ebx),%eax
  801a20:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a23:	74 e7                	je     801a0c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a25:	99                   	cltd   
  801a26:	c1 ea 1b             	shr    $0x1b,%edx
  801a29:	01 d0                	add    %edx,%eax
  801a2b:	83 e0 1f             	and    $0x1f,%eax
  801a2e:	29 d0                	sub    %edx,%eax
  801a30:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a38:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a3b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801a3e:	83 c6 01             	add    $0x1,%esi
  801a41:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a44:	74 12                	je     801a58 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  801a46:	8b 03                	mov    (%ebx),%eax
  801a48:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a4b:	75 d8                	jne    801a25 <devpipe_read+0x40>
			if (i > 0)
  801a4d:	85 f6                	test   %esi,%esi
  801a4f:	75 b7                	jne    801a08 <devpipe_read+0x23>
  801a51:	eb b9                	jmp    801a0c <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  801a53:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  801a58:	89 f0                	mov    %esi,%eax
  801a5a:	eb 05                	jmp    801a61 <devpipe_read+0x7c>
				return 0;
  801a5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a61:	83 c4 1c             	add    $0x1c,%esp
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5f                   	pop    %edi
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    

00801a69 <pipe>:
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	56                   	push   %esi
  801a6d:	53                   	push   %ebx
  801a6e:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801a71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a74:	89 04 24             	mov    %eax,(%esp)
  801a77:	e8 cb f5 ff ff       	call   801047 <fd_alloc>
  801a7c:	89 c2                	mov    %eax,%edx
  801a7e:	85 d2                	test   %edx,%edx
  801a80:	0f 88 4d 01 00 00    	js     801bd3 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a86:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a8d:	00 
  801a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a91:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a9c:	e8 28 f2 ff ff       	call   800cc9 <sys_page_alloc>
  801aa1:	89 c2                	mov    %eax,%edx
  801aa3:	85 d2                	test   %edx,%edx
  801aa5:	0f 88 28 01 00 00    	js     801bd3 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801aab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aae:	89 04 24             	mov    %eax,(%esp)
  801ab1:	e8 91 f5 ff ff       	call   801047 <fd_alloc>
  801ab6:	89 c3                	mov    %eax,%ebx
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	0f 88 fe 00 00 00    	js     801bbe <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ac7:	00 
  801ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801acb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801acf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ad6:	e8 ee f1 ff ff       	call   800cc9 <sys_page_alloc>
  801adb:	89 c3                	mov    %eax,%ebx
  801add:	85 c0                	test   %eax,%eax
  801adf:	0f 88 d9 00 00 00    	js     801bbe <pipe+0x155>
	va = fd2data(fd0);
  801ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae8:	89 04 24             	mov    %eax,(%esp)
  801aeb:	e8 40 f5 ff ff       	call   801030 <fd2data>
  801af0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801af9:	00 
  801afa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b05:	e8 bf f1 ff ff       	call   800cc9 <sys_page_alloc>
  801b0a:	89 c3                	mov    %eax,%ebx
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	0f 88 97 00 00 00    	js     801bab <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b17:	89 04 24             	mov    %eax,(%esp)
  801b1a:	e8 11 f5 ff ff       	call   801030 <fd2data>
  801b1f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b26:	00 
  801b27:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b32:	00 
  801b33:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b3e:	e8 da f1 ff ff       	call   800d1d <sys_page_map>
  801b43:	89 c3                	mov    %eax,%ebx
  801b45:	85 c0                	test   %eax,%eax
  801b47:	78 52                	js     801b9b <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801b49:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b52:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b57:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801b5e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b67:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b76:	89 04 24             	mov    %eax,(%esp)
  801b79:	e8 a2 f4 ff ff       	call   801020 <fd2num>
  801b7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b81:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b86:	89 04 24             	mov    %eax,(%esp)
  801b89:	e8 92 f4 ff ff       	call   801020 <fd2num>
  801b8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b91:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
  801b99:	eb 38                	jmp    801bd3 <pipe+0x16a>
	sys_page_unmap(0, va);
  801b9b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba6:	e8 c5 f1 ff ff       	call   800d70 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bae:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bb9:	e8 b2 f1 ff ff       	call   800d70 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bcc:	e8 9f f1 ff ff       	call   800d70 <sys_page_unmap>
  801bd1:	89 d8                	mov    %ebx,%eax
}
  801bd3:	83 c4 30             	add    $0x30,%esp
  801bd6:	5b                   	pop    %ebx
  801bd7:	5e                   	pop    %esi
  801bd8:	5d                   	pop    %ebp
  801bd9:	c3                   	ret    

00801bda <pipeisclosed>:
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801be0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bea:	89 04 24             	mov    %eax,(%esp)
  801bed:	e8 c9 f4 ff ff       	call   8010bb <fd_lookup>
  801bf2:	89 c2                	mov    %eax,%edx
  801bf4:	85 d2                	test   %edx,%edx
  801bf6:	78 15                	js     801c0d <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfb:	89 04 24             	mov    %eax,(%esp)
  801bfe:	e8 2d f4 ff ff       	call   801030 <fd2data>
	return _pipeisclosed(fd, p);
  801c03:	89 c2                	mov    %eax,%edx
  801c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c08:	e8 de fc ff ff       	call   8018eb <_pipeisclosed>
}
  801c0d:	c9                   	leave  
  801c0e:	c3                   	ret    
  801c0f:	90                   	nop

00801c10 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c13:	b8 00 00 00 00       	mov    $0x0,%eax
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    

00801c1a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801c20:	c7 44 24 04 38 25 80 	movl   $0x802538,0x4(%esp)
  801c27:	00 
  801c28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2b:	89 04 24             	mov    %eax,(%esp)
  801c2e:	e8 e8 eb ff ff       	call   80081b <strcpy>
	return 0;
}
  801c33:	b8 00 00 00 00       	mov    $0x0,%eax
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <devcons_write>:
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	57                   	push   %edi
  801c3e:	56                   	push   %esi
  801c3f:	53                   	push   %ebx
  801c40:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c4a:	74 4a                	je     801c96 <devcons_write+0x5c>
  801c4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c51:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c56:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  801c5c:	8b 75 10             	mov    0x10(%ebp),%esi
  801c5f:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  801c61:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801c64:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c69:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c6c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c70:	03 45 0c             	add    0xc(%ebp),%eax
  801c73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c77:	89 3c 24             	mov    %edi,(%esp)
  801c7a:	e8 97 ed ff ff       	call   800a16 <memmove>
		sys_cputs(buf, m);
  801c7f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c83:	89 3c 24             	mov    %edi,(%esp)
  801c86:	e8 71 ef ff ff       	call   800bfc <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801c8b:	01 f3                	add    %esi,%ebx
  801c8d:	89 d8                	mov    %ebx,%eax
  801c8f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c92:	72 c8                	jb     801c5c <devcons_write+0x22>
  801c94:	eb 05                	jmp    801c9b <devcons_write+0x61>
  801c96:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  801c9b:	89 d8                	mov    %ebx,%eax
  801c9d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    

00801ca8 <devcons_read>:
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801cae:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801cb3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cb7:	75 07                	jne    801cc0 <devcons_read+0x18>
  801cb9:	eb 28                	jmp    801ce3 <devcons_read+0x3b>
		sys_yield();
  801cbb:	e8 ea ef ff ff       	call   800caa <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801cc0:	e8 55 ef ff ff       	call   800c1a <sys_cgetc>
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	74 f2                	je     801cbb <devcons_read+0x13>
	if (c < 0)
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	78 16                	js     801ce3 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  801ccd:	83 f8 04             	cmp    $0x4,%eax
  801cd0:	74 0c                	je     801cde <devcons_read+0x36>
	*(char*)vbuf = c;
  801cd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd5:	88 02                	mov    %al,(%edx)
	return 1;
  801cd7:	b8 01 00 00 00       	mov    $0x1,%eax
  801cdc:	eb 05                	jmp    801ce3 <devcons_read+0x3b>
		return 0;
  801cde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ce3:	c9                   	leave  
  801ce4:	c3                   	ret    

00801ce5 <cputchar>:
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cee:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801cf1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801cf8:	00 
  801cf9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cfc:	89 04 24             	mov    %eax,(%esp)
  801cff:	e8 f8 ee ff ff       	call   800bfc <sys_cputs>
}
  801d04:	c9                   	leave  
  801d05:	c3                   	ret    

00801d06 <getchar>:
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801d0c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801d13:	00 
  801d14:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d22:	e8 3f f6 ff ff       	call   801366 <read>
	if (r < 0)
  801d27:	85 c0                	test   %eax,%eax
  801d29:	78 0f                	js     801d3a <getchar+0x34>
	if (r < 1)
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	7e 06                	jle    801d35 <getchar+0x2f>
	return c;
  801d2f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d33:	eb 05                	jmp    801d3a <getchar+0x34>
		return -E_EOF;
  801d35:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    

00801d3c <iscons>:
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d49:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4c:	89 04 24             	mov    %eax,(%esp)
  801d4f:	e8 67 f3 ff ff       	call   8010bb <fd_lookup>
  801d54:	85 c0                	test   %eax,%eax
  801d56:	78 11                	js     801d69 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d61:	39 10                	cmp    %edx,(%eax)
  801d63:	0f 94 c0             	sete   %al
  801d66:	0f b6 c0             	movzbl %al,%eax
}
  801d69:	c9                   	leave  
  801d6a:	c3                   	ret    

00801d6b <opencons>:
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d74:	89 04 24             	mov    %eax,(%esp)
  801d77:	e8 cb f2 ff ff       	call   801047 <fd_alloc>
		return r;
  801d7c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	78 40                	js     801dc2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d82:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d89:	00 
  801d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d98:	e8 2c ef ff ff       	call   800cc9 <sys_page_alloc>
		return r;
  801d9d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d9f:	85 c0                	test   %eax,%eax
  801da1:	78 1f                	js     801dc2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801da3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dac:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801db8:	89 04 24             	mov    %eax,(%esp)
  801dbb:	e8 60 f2 ff ff       	call   801020 <fd2num>
  801dc0:	89 c2                	mov    %eax,%edx
}
  801dc2:	89 d0                	mov    %edx,%eax
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	56                   	push   %esi
  801dca:	53                   	push   %ebx
  801dcb:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801dce:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801dd1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801dd7:	e8 af ee ff ff       	call   800c8b <sys_getenvid>
  801ddc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ddf:	89 54 24 10          	mov    %edx,0x10(%esp)
  801de3:	8b 55 08             	mov    0x8(%ebp),%edx
  801de6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801dea:	89 74 24 08          	mov    %esi,0x8(%esp)
  801dee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df2:	c7 04 24 44 25 80 00 	movl   $0x802544,(%esp)
  801df9:	e8 c8 e3 ff ff       	call   8001c6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801dfe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e02:	8b 45 10             	mov    0x10(%ebp),%eax
  801e05:	89 04 24             	mov    %eax,(%esp)
  801e08:	e8 58 e3 ff ff       	call   800165 <vcprintf>
	cprintf("\n");
  801e0d:	c7 04 24 31 25 80 00 	movl   $0x802531,(%esp)
  801e14:	e8 ad e3 ff ff       	call   8001c6 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e19:	cc                   	int3   
  801e1a:	eb fd                	jmp    801e19 <_panic+0x53>

00801e1c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e22:	89 d0                	mov    %edx,%eax
  801e24:	c1 e8 16             	shr    $0x16,%eax
  801e27:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e2e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801e33:	f6 c1 01             	test   $0x1,%cl
  801e36:	74 1d                	je     801e55 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801e38:	c1 ea 0c             	shr    $0xc,%edx
  801e3b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e42:	f6 c2 01             	test   $0x1,%dl
  801e45:	74 0e                	je     801e55 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e47:	c1 ea 0c             	shr    $0xc,%edx
  801e4a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e51:	ef 
  801e52:	0f b7 c0             	movzwl %ax,%eax
}
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    
  801e57:	66 90                	xchg   %ax,%ax
  801e59:	66 90                	xchg   %ax,%ax
  801e5b:	66 90                	xchg   %ax,%ax
  801e5d:	66 90                	xchg   %ax,%ax
  801e5f:	90                   	nop

00801e60 <__udivdi3>:
  801e60:	55                   	push   %ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	83 ec 0c             	sub    $0xc,%esp
  801e66:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e6a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801e6e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801e72:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e76:	85 c0                	test   %eax,%eax
  801e78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e7c:	89 ea                	mov    %ebp,%edx
  801e7e:	89 0c 24             	mov    %ecx,(%esp)
  801e81:	75 2d                	jne    801eb0 <__udivdi3+0x50>
  801e83:	39 e9                	cmp    %ebp,%ecx
  801e85:	77 61                	ja     801ee8 <__udivdi3+0x88>
  801e87:	85 c9                	test   %ecx,%ecx
  801e89:	89 ce                	mov    %ecx,%esi
  801e8b:	75 0b                	jne    801e98 <__udivdi3+0x38>
  801e8d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e92:	31 d2                	xor    %edx,%edx
  801e94:	f7 f1                	div    %ecx
  801e96:	89 c6                	mov    %eax,%esi
  801e98:	31 d2                	xor    %edx,%edx
  801e9a:	89 e8                	mov    %ebp,%eax
  801e9c:	f7 f6                	div    %esi
  801e9e:	89 c5                	mov    %eax,%ebp
  801ea0:	89 f8                	mov    %edi,%eax
  801ea2:	f7 f6                	div    %esi
  801ea4:	89 ea                	mov    %ebp,%edx
  801ea6:	83 c4 0c             	add    $0xc,%esp
  801ea9:	5e                   	pop    %esi
  801eaa:	5f                   	pop    %edi
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    
  801ead:	8d 76 00             	lea    0x0(%esi),%esi
  801eb0:	39 e8                	cmp    %ebp,%eax
  801eb2:	77 24                	ja     801ed8 <__udivdi3+0x78>
  801eb4:	0f bd e8             	bsr    %eax,%ebp
  801eb7:	83 f5 1f             	xor    $0x1f,%ebp
  801eba:	75 3c                	jne    801ef8 <__udivdi3+0x98>
  801ebc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801ec0:	39 34 24             	cmp    %esi,(%esp)
  801ec3:	0f 86 9f 00 00 00    	jbe    801f68 <__udivdi3+0x108>
  801ec9:	39 d0                	cmp    %edx,%eax
  801ecb:	0f 82 97 00 00 00    	jb     801f68 <__udivdi3+0x108>
  801ed1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ed8:	31 d2                	xor    %edx,%edx
  801eda:	31 c0                	xor    %eax,%eax
  801edc:	83 c4 0c             	add    $0xc,%esp
  801edf:	5e                   	pop    %esi
  801ee0:	5f                   	pop    %edi
  801ee1:	5d                   	pop    %ebp
  801ee2:	c3                   	ret    
  801ee3:	90                   	nop
  801ee4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ee8:	89 f8                	mov    %edi,%eax
  801eea:	f7 f1                	div    %ecx
  801eec:	31 d2                	xor    %edx,%edx
  801eee:	83 c4 0c             	add    $0xc,%esp
  801ef1:	5e                   	pop    %esi
  801ef2:	5f                   	pop    %edi
  801ef3:	5d                   	pop    %ebp
  801ef4:	c3                   	ret    
  801ef5:	8d 76 00             	lea    0x0(%esi),%esi
  801ef8:	89 e9                	mov    %ebp,%ecx
  801efa:	8b 3c 24             	mov    (%esp),%edi
  801efd:	d3 e0                	shl    %cl,%eax
  801eff:	89 c6                	mov    %eax,%esi
  801f01:	b8 20 00 00 00       	mov    $0x20,%eax
  801f06:	29 e8                	sub    %ebp,%eax
  801f08:	89 c1                	mov    %eax,%ecx
  801f0a:	d3 ef                	shr    %cl,%edi
  801f0c:	89 e9                	mov    %ebp,%ecx
  801f0e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801f12:	8b 3c 24             	mov    (%esp),%edi
  801f15:	09 74 24 08          	or     %esi,0x8(%esp)
  801f19:	89 d6                	mov    %edx,%esi
  801f1b:	d3 e7                	shl    %cl,%edi
  801f1d:	89 c1                	mov    %eax,%ecx
  801f1f:	89 3c 24             	mov    %edi,(%esp)
  801f22:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f26:	d3 ee                	shr    %cl,%esi
  801f28:	89 e9                	mov    %ebp,%ecx
  801f2a:	d3 e2                	shl    %cl,%edx
  801f2c:	89 c1                	mov    %eax,%ecx
  801f2e:	d3 ef                	shr    %cl,%edi
  801f30:	09 d7                	or     %edx,%edi
  801f32:	89 f2                	mov    %esi,%edx
  801f34:	89 f8                	mov    %edi,%eax
  801f36:	f7 74 24 08          	divl   0x8(%esp)
  801f3a:	89 d6                	mov    %edx,%esi
  801f3c:	89 c7                	mov    %eax,%edi
  801f3e:	f7 24 24             	mull   (%esp)
  801f41:	39 d6                	cmp    %edx,%esi
  801f43:	89 14 24             	mov    %edx,(%esp)
  801f46:	72 30                	jb     801f78 <__udivdi3+0x118>
  801f48:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f4c:	89 e9                	mov    %ebp,%ecx
  801f4e:	d3 e2                	shl    %cl,%edx
  801f50:	39 c2                	cmp    %eax,%edx
  801f52:	73 05                	jae    801f59 <__udivdi3+0xf9>
  801f54:	3b 34 24             	cmp    (%esp),%esi
  801f57:	74 1f                	je     801f78 <__udivdi3+0x118>
  801f59:	89 f8                	mov    %edi,%eax
  801f5b:	31 d2                	xor    %edx,%edx
  801f5d:	e9 7a ff ff ff       	jmp    801edc <__udivdi3+0x7c>
  801f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f68:	31 d2                	xor    %edx,%edx
  801f6a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6f:	e9 68 ff ff ff       	jmp    801edc <__udivdi3+0x7c>
  801f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f78:	8d 47 ff             	lea    -0x1(%edi),%eax
  801f7b:	31 d2                	xor    %edx,%edx
  801f7d:	83 c4 0c             	add    $0xc,%esp
  801f80:	5e                   	pop    %esi
  801f81:	5f                   	pop    %edi
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    
  801f84:	66 90                	xchg   %ax,%ax
  801f86:	66 90                	xchg   %ax,%ax
  801f88:	66 90                	xchg   %ax,%ax
  801f8a:	66 90                	xchg   %ax,%ax
  801f8c:	66 90                	xchg   %ax,%ax
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <__umoddi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	83 ec 14             	sub    $0x14,%esp
  801f96:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f9a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f9e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801fa2:	89 c7                	mov    %eax,%edi
  801fa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801fac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801fb0:	89 34 24             	mov    %esi,(%esp)
  801fb3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	89 c2                	mov    %eax,%edx
  801fbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fbf:	75 17                	jne    801fd8 <__umoddi3+0x48>
  801fc1:	39 fe                	cmp    %edi,%esi
  801fc3:	76 4b                	jbe    802010 <__umoddi3+0x80>
  801fc5:	89 c8                	mov    %ecx,%eax
  801fc7:	89 fa                	mov    %edi,%edx
  801fc9:	f7 f6                	div    %esi
  801fcb:	89 d0                	mov    %edx,%eax
  801fcd:	31 d2                	xor    %edx,%edx
  801fcf:	83 c4 14             	add    $0x14,%esp
  801fd2:	5e                   	pop    %esi
  801fd3:	5f                   	pop    %edi
  801fd4:	5d                   	pop    %ebp
  801fd5:	c3                   	ret    
  801fd6:	66 90                	xchg   %ax,%ax
  801fd8:	39 f8                	cmp    %edi,%eax
  801fda:	77 54                	ja     802030 <__umoddi3+0xa0>
  801fdc:	0f bd e8             	bsr    %eax,%ebp
  801fdf:	83 f5 1f             	xor    $0x1f,%ebp
  801fe2:	75 5c                	jne    802040 <__umoddi3+0xb0>
  801fe4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801fe8:	39 3c 24             	cmp    %edi,(%esp)
  801feb:	0f 87 e7 00 00 00    	ja     8020d8 <__umoddi3+0x148>
  801ff1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ff5:	29 f1                	sub    %esi,%ecx
  801ff7:	19 c7                	sbb    %eax,%edi
  801ff9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ffd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802001:	8b 44 24 08          	mov    0x8(%esp),%eax
  802005:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802009:	83 c4 14             	add    $0x14,%esp
  80200c:	5e                   	pop    %esi
  80200d:	5f                   	pop    %edi
  80200e:	5d                   	pop    %ebp
  80200f:	c3                   	ret    
  802010:	85 f6                	test   %esi,%esi
  802012:	89 f5                	mov    %esi,%ebp
  802014:	75 0b                	jne    802021 <__umoddi3+0x91>
  802016:	b8 01 00 00 00       	mov    $0x1,%eax
  80201b:	31 d2                	xor    %edx,%edx
  80201d:	f7 f6                	div    %esi
  80201f:	89 c5                	mov    %eax,%ebp
  802021:	8b 44 24 04          	mov    0x4(%esp),%eax
  802025:	31 d2                	xor    %edx,%edx
  802027:	f7 f5                	div    %ebp
  802029:	89 c8                	mov    %ecx,%eax
  80202b:	f7 f5                	div    %ebp
  80202d:	eb 9c                	jmp    801fcb <__umoddi3+0x3b>
  80202f:	90                   	nop
  802030:	89 c8                	mov    %ecx,%eax
  802032:	89 fa                	mov    %edi,%edx
  802034:	83 c4 14             	add    $0x14,%esp
  802037:	5e                   	pop    %esi
  802038:	5f                   	pop    %edi
  802039:	5d                   	pop    %ebp
  80203a:	c3                   	ret    
  80203b:	90                   	nop
  80203c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802040:	8b 04 24             	mov    (%esp),%eax
  802043:	be 20 00 00 00       	mov    $0x20,%esi
  802048:	89 e9                	mov    %ebp,%ecx
  80204a:	29 ee                	sub    %ebp,%esi
  80204c:	d3 e2                	shl    %cl,%edx
  80204e:	89 f1                	mov    %esi,%ecx
  802050:	d3 e8                	shr    %cl,%eax
  802052:	89 e9                	mov    %ebp,%ecx
  802054:	89 44 24 04          	mov    %eax,0x4(%esp)
  802058:	8b 04 24             	mov    (%esp),%eax
  80205b:	09 54 24 04          	or     %edx,0x4(%esp)
  80205f:	89 fa                	mov    %edi,%edx
  802061:	d3 e0                	shl    %cl,%eax
  802063:	89 f1                	mov    %esi,%ecx
  802065:	89 44 24 08          	mov    %eax,0x8(%esp)
  802069:	8b 44 24 10          	mov    0x10(%esp),%eax
  80206d:	d3 ea                	shr    %cl,%edx
  80206f:	89 e9                	mov    %ebp,%ecx
  802071:	d3 e7                	shl    %cl,%edi
  802073:	89 f1                	mov    %esi,%ecx
  802075:	d3 e8                	shr    %cl,%eax
  802077:	89 e9                	mov    %ebp,%ecx
  802079:	09 f8                	or     %edi,%eax
  80207b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80207f:	f7 74 24 04          	divl   0x4(%esp)
  802083:	d3 e7                	shl    %cl,%edi
  802085:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802089:	89 d7                	mov    %edx,%edi
  80208b:	f7 64 24 08          	mull   0x8(%esp)
  80208f:	39 d7                	cmp    %edx,%edi
  802091:	89 c1                	mov    %eax,%ecx
  802093:	89 14 24             	mov    %edx,(%esp)
  802096:	72 2c                	jb     8020c4 <__umoddi3+0x134>
  802098:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80209c:	72 22                	jb     8020c0 <__umoddi3+0x130>
  80209e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8020a2:	29 c8                	sub    %ecx,%eax
  8020a4:	19 d7                	sbb    %edx,%edi
  8020a6:	89 e9                	mov    %ebp,%ecx
  8020a8:	89 fa                	mov    %edi,%edx
  8020aa:	d3 e8                	shr    %cl,%eax
  8020ac:	89 f1                	mov    %esi,%ecx
  8020ae:	d3 e2                	shl    %cl,%edx
  8020b0:	89 e9                	mov    %ebp,%ecx
  8020b2:	d3 ef                	shr    %cl,%edi
  8020b4:	09 d0                	or     %edx,%eax
  8020b6:	89 fa                	mov    %edi,%edx
  8020b8:	83 c4 14             	add    $0x14,%esp
  8020bb:	5e                   	pop    %esi
  8020bc:	5f                   	pop    %edi
  8020bd:	5d                   	pop    %ebp
  8020be:	c3                   	ret    
  8020bf:	90                   	nop
  8020c0:	39 d7                	cmp    %edx,%edi
  8020c2:	75 da                	jne    80209e <__umoddi3+0x10e>
  8020c4:	8b 14 24             	mov    (%esp),%edx
  8020c7:	89 c1                	mov    %eax,%ecx
  8020c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8020cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8020d1:	eb cb                	jmp    80209e <__umoddi3+0x10e>
  8020d3:	90                   	nop
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8020dc:	0f 82 0f ff ff ff    	jb     801ff1 <__umoddi3+0x61>
  8020e2:	e9 1a ff ff ff       	jmp    802001 <__umoddi3+0x71>
