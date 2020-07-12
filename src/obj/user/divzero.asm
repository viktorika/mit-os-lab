
obj/user/divzero.debug：     文件格式 elf32-i386


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
  80002c:	e8 31 00 00 00       	call   800062 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  800039:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	89 44 24 04          	mov    %eax,0x4(%esp)
  800054:	c7 04 24 a0 20 80 00 	movl   $0x8020a0,(%esp)
  80005b:	e8 06 01 00 00       	call   800166 <cprintf>
}
  800060:	c9                   	leave  
  800061:	c3                   	ret    

00800062 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800062:	55                   	push   %ebp
  800063:	89 e5                	mov    %esp,%ebp
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	83 ec 10             	sub    $0x10,%esp
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800070:	e8 b6 0b 00 00       	call   800c2b <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x30>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	89 74 24 04          	mov    %esi,0x4(%esp)
  800096:	89 1c 24             	mov    %ebx,(%esp)
  800099:	e8 95 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009e:	e8 07 00 00 00       	call   8000aa <exit>
}
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	5b                   	pop    %ebx
  8000a7:	5e                   	pop    %esi
  8000a8:	5d                   	pop    %ebp
  8000a9:	c3                   	ret    

008000aa <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000b0:	e8 41 10 00 00       	call   8010f6 <close_all>
	sys_env_destroy(0);
  8000b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bc:	e8 18 0b 00 00       	call   800bd9 <sys_env_destroy>
}
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	53                   	push   %ebx
  8000c7:	83 ec 14             	sub    $0x14,%esp
  8000ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000cd:	8b 13                	mov    (%ebx),%edx
  8000cf:	8d 42 01             	lea    0x1(%edx),%eax
  8000d2:	89 03                	mov    %eax,(%ebx)
  8000d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e0:	75 19                	jne    8000fb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000e2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e9:	00 
  8000ea:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ed:	89 04 24             	mov    %eax,(%esp)
  8000f0:	e8 a7 0a 00 00       	call   800b9c <sys_cputs>
		b->idx = 0;
  8000f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000ff:	83 c4 14             	add    $0x14,%esp
  800102:	5b                   	pop    %ebx
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    

00800105 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800115:	00 00 00 
	b.cnt = 0;
  800118:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800122:	8b 45 0c             	mov    0xc(%ebp),%eax
  800125:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800129:	8b 45 08             	mov    0x8(%ebp),%eax
  80012c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800130:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013a:	c7 04 24 c3 00 80 00 	movl   $0x8000c3,(%esp)
  800141:	e8 ae 01 00 00       	call   8002f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800146:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800150:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800156:	89 04 24             	mov    %eax,(%esp)
  800159:	e8 3e 0a 00 00       	call   800b9c <sys_cputs>

	return b.cnt;
}
  80015e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800164:	c9                   	leave  
  800165:	c3                   	ret    

00800166 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800173:	8b 45 08             	mov    0x8(%ebp),%eax
  800176:	89 04 24             	mov    %eax,(%esp)
  800179:	e8 87 ff ff ff       	call   800105 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 3c             	sub    $0x3c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d7                	mov    %edx,%edi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800194:	8b 75 0c             	mov    0xc(%ebp),%esi
  800197:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80019a:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001a8:	39 f1                	cmp    %esi,%ecx
  8001aa:	72 14                	jb     8001c0 <printnum+0x40>
  8001ac:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001af:	76 0f                	jbe    8001c0 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b4:	8d 70 ff             	lea    -0x1(%eax),%esi
  8001b7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8001ba:	85 f6                	test   %esi,%esi
  8001bc:	7f 60                	jg     80021e <printnum+0x9e>
  8001be:	eb 72                	jmp    800232 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001c7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8001ca:	8d 51 ff             	lea    -0x1(%ecx),%edx
  8001cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d5:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001d9:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001dd:	89 c3                	mov    %eax,%ebx
  8001df:	89 d6                	mov    %edx,%esi
  8001e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001e4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001e7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001eb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001f2:	89 04 24             	mov    %eax,(%esp)
  8001f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fc:	e8 0f 1c 00 00       	call   801e10 <__udivdi3>
  800201:	89 d9                	mov    %ebx,%ecx
  800203:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800207:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80020b:	89 04 24             	mov    %eax,(%esp)
  80020e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800212:	89 fa                	mov    %edi,%edx
  800214:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800217:	e8 64 ff ff ff       	call   800180 <printnum>
  80021c:	eb 14                	jmp    800232 <printnum+0xb2>
			putch(padc, putdat);
  80021e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800222:	8b 45 18             	mov    0x18(%ebp),%eax
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	ff d3                	call   *%ebx
		while (--width > 0)
  80022a:	83 ee 01             	sub    $0x1,%esi
  80022d:	75 ef                	jne    80021e <printnum+0x9e>
  80022f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800232:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800236:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80023a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80023d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800240:	89 44 24 08          	mov    %eax,0x8(%esp)
  800244:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800248:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80024b:	89 04 24             	mov    %eax,(%esp)
  80024e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800251:	89 44 24 04          	mov    %eax,0x4(%esp)
  800255:	e8 e6 1c 00 00       	call   801f40 <__umoddi3>
  80025a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025e:	0f be 80 b8 20 80 00 	movsbl 0x8020b8(%eax),%eax
  800265:	89 04 24             	mov    %eax,(%esp)
  800268:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026b:	ff d0                	call   *%eax
}
  80026d:	83 c4 3c             	add    $0x3c,%esp
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800278:	83 fa 01             	cmp    $0x1,%edx
  80027b:	7e 0e                	jle    80028b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 02                	mov    (%edx),%eax
  800286:	8b 52 04             	mov    0x4(%edx),%edx
  800289:	eb 22                	jmp    8002ad <getuint+0x38>
	else if (lflag)
  80028b:	85 d2                	test   %edx,%edx
  80028d:	74 10                	je     80029f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	8d 4a 04             	lea    0x4(%edx),%ecx
  800294:	89 08                	mov    %ecx,(%eax)
  800296:	8b 02                	mov    (%edx),%eax
  800298:	ba 00 00 00 00       	mov    $0x0,%edx
  80029d:	eb 0e                	jmp    8002ad <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002be:	73 0a                	jae    8002ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c3:	89 08                	mov    %ecx,(%eax)
  8002c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c8:	88 02                	mov    %al,(%edx)
}
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <printfmt>:
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8002d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	89 04 24             	mov    %eax,(%esp)
  8002ed:	e8 02 00 00 00       	call   8002f4 <vprintfmt>
}
  8002f2:	c9                   	leave  
  8002f3:	c3                   	ret    

008002f4 <vprintfmt>:
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	57                   	push   %edi
  8002f8:	56                   	push   %esi
  8002f9:	53                   	push   %ebx
  8002fa:	83 ec 3c             	sub    $0x3c,%esp
  8002fd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800300:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800303:	eb 18                	jmp    80031d <vprintfmt+0x29>
			if (ch == '\0')
  800305:	85 c0                	test   %eax,%eax
  800307:	0f 84 c3 03 00 00    	je     8006d0 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80030d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800311:	89 04 24             	mov    %eax,(%esp)
  800314:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800317:	89 f3                	mov    %esi,%ebx
  800319:	eb 02                	jmp    80031d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80031b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031d:	8d 73 01             	lea    0x1(%ebx),%esi
  800320:	0f b6 03             	movzbl (%ebx),%eax
  800323:	83 f8 25             	cmp    $0x25,%eax
  800326:	75 dd                	jne    800305 <vprintfmt+0x11>
  800328:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80032c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800333:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80033a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800341:	ba 00 00 00 00       	mov    $0x0,%edx
  800346:	eb 1d                	jmp    800365 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800348:	89 de                	mov    %ebx,%esi
			padc = '-';
  80034a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80034e:	eb 15                	jmp    800365 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800350:	89 de                	mov    %ebx,%esi
			padc = '0';
  800352:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800356:	eb 0d                	jmp    800365 <vprintfmt+0x71>
				width = precision, precision = -1;
  800358:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80035b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8d 5e 01             	lea    0x1(%esi),%ebx
  800368:	0f b6 06             	movzbl (%esi),%eax
  80036b:	0f b6 c8             	movzbl %al,%ecx
  80036e:	83 e8 23             	sub    $0x23,%eax
  800371:	3c 55                	cmp    $0x55,%al
  800373:	0f 87 2f 03 00 00    	ja     8006a8 <vprintfmt+0x3b4>
  800379:	0f b6 c0             	movzbl %al,%eax
  80037c:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
				precision = precision * 10 + ch - '0';
  800383:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800386:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  800389:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80038d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800390:	83 f9 09             	cmp    $0x9,%ecx
  800393:	77 50                	ja     8003e5 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  800395:	89 de                	mov    %ebx,%esi
  800397:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  80039a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80039d:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003a0:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003a4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003a7:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003aa:	83 fb 09             	cmp    $0x9,%ebx
  8003ad:	76 eb                	jbe    80039a <vprintfmt+0xa6>
  8003af:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8003b2:	eb 33                	jmp    8003e7 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ba:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003bd:	8b 00                	mov    (%eax),%eax
  8003bf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8003c4:	eb 21                	jmp    8003e7 <vprintfmt+0xf3>
  8003c6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003c9:	85 c9                	test   %ecx,%ecx
  8003cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d0:	0f 49 c1             	cmovns %ecx,%eax
  8003d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	89 de                	mov    %ebx,%esi
  8003d8:	eb 8b                	jmp    800365 <vprintfmt+0x71>
  8003da:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8003dc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e3:	eb 80                	jmp    800365 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	89 de                	mov    %ebx,%esi
			if (width < 0)
  8003e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003eb:	0f 89 74 ff ff ff    	jns    800365 <vprintfmt+0x71>
  8003f1:	e9 62 ff ff ff       	jmp    800358 <vprintfmt+0x64>
			lflag++;
  8003f6:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8003fb:	e9 65 ff ff ff       	jmp    800365 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 50 04             	lea    0x4(%eax),%edx
  800406:	89 55 14             	mov    %edx,0x14(%ebp)
  800409:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80040d:	8b 00                	mov    (%eax),%eax
  80040f:	89 04 24             	mov    %eax,(%esp)
  800412:	ff 55 08             	call   *0x8(%ebp)
			break;
  800415:	e9 03 ff ff ff       	jmp    80031d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8d 50 04             	lea    0x4(%eax),%edx
  800420:	89 55 14             	mov    %edx,0x14(%ebp)
  800423:	8b 00                	mov    (%eax),%eax
  800425:	99                   	cltd   
  800426:	31 d0                	xor    %edx,%eax
  800428:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042a:	83 f8 0f             	cmp    $0xf,%eax
  80042d:	7f 0b                	jg     80043a <vprintfmt+0x146>
  80042f:	8b 14 85 60 23 80 00 	mov    0x802360(,%eax,4),%edx
  800436:	85 d2                	test   %edx,%edx
  800438:	75 20                	jne    80045a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80043a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043e:	c7 44 24 08 d0 20 80 	movl   $0x8020d0,0x8(%esp)
  800445:	00 
  800446:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044a:	8b 45 08             	mov    0x8(%ebp),%eax
  80044d:	89 04 24             	mov    %eax,(%esp)
  800450:	e8 77 fe ff ff       	call   8002cc <printfmt>
  800455:	e9 c3 fe ff ff       	jmp    80031d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80045a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045e:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800465:	00 
  800466:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046a:	8b 45 08             	mov    0x8(%ebp),%eax
  80046d:	89 04 24             	mov    %eax,(%esp)
  800470:	e8 57 fe ff ff       	call   8002cc <printfmt>
  800475:	e9 a3 fe ff ff       	jmp    80031d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80047d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80048b:	85 c0                	test   %eax,%eax
  80048d:	ba c9 20 80 00       	mov    $0x8020c9,%edx
  800492:	0f 45 d0             	cmovne %eax,%edx
  800495:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800498:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80049c:	74 04                	je     8004a2 <vprintfmt+0x1ae>
  80049e:	85 f6                	test   %esi,%esi
  8004a0:	7f 19                	jg     8004bb <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004a5:	8d 70 01             	lea    0x1(%eax),%esi
  8004a8:	0f b6 10             	movzbl (%eax),%edx
  8004ab:	0f be c2             	movsbl %dl,%eax
  8004ae:	85 c0                	test   %eax,%eax
  8004b0:	0f 85 95 00 00 00    	jne    80054b <vprintfmt+0x257>
  8004b6:	e9 85 00 00 00       	jmp    800540 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004bf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004c2:	89 04 24             	mov    %eax,(%esp)
  8004c5:	e8 b8 02 00 00       	call   800782 <strnlen>
  8004ca:	29 c6                	sub    %eax,%esi
  8004cc:	89 f0                	mov    %esi,%eax
  8004ce:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8004d1:	85 f6                	test   %esi,%esi
  8004d3:	7e cd                	jle    8004a2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8004d5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8004d9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004dc:	89 c3                	mov    %eax,%ebx
  8004de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004e2:	89 34 24             	mov    %esi,(%esp)
  8004e5:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e8:	83 eb 01             	sub    $0x1,%ebx
  8004eb:	75 f1                	jne    8004de <vprintfmt+0x1ea>
  8004ed:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004f3:	eb ad                	jmp    8004a2 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f9:	74 1e                	je     800519 <vprintfmt+0x225>
  8004fb:	0f be d2             	movsbl %dl,%edx
  8004fe:	83 ea 20             	sub    $0x20,%edx
  800501:	83 fa 5e             	cmp    $0x5e,%edx
  800504:	76 13                	jbe    800519 <vprintfmt+0x225>
					putch('?', putdat);
  800506:	8b 45 0c             	mov    0xc(%ebp),%eax
  800509:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800514:	ff 55 08             	call   *0x8(%ebp)
  800517:	eb 0d                	jmp    800526 <vprintfmt+0x232>
					putch(ch, putdat);
  800519:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80051c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800520:	89 04 24             	mov    %eax,(%esp)
  800523:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800526:	83 ef 01             	sub    $0x1,%edi
  800529:	83 c6 01             	add    $0x1,%esi
  80052c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800530:	0f be c2             	movsbl %dl,%eax
  800533:	85 c0                	test   %eax,%eax
  800535:	75 20                	jne    800557 <vprintfmt+0x263>
  800537:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80053a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80053d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800544:	7f 25                	jg     80056b <vprintfmt+0x277>
  800546:	e9 d2 fd ff ff       	jmp    80031d <vprintfmt+0x29>
  80054b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80054e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800551:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800554:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800557:	85 db                	test   %ebx,%ebx
  800559:	78 9a                	js     8004f5 <vprintfmt+0x201>
  80055b:	83 eb 01             	sub    $0x1,%ebx
  80055e:	79 95                	jns    8004f5 <vprintfmt+0x201>
  800560:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800563:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800566:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800569:	eb d5                	jmp    800540 <vprintfmt+0x24c>
  80056b:	8b 75 08             	mov    0x8(%ebp),%esi
  80056e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800571:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  800574:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800578:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80057f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800581:	83 eb 01             	sub    $0x1,%ebx
  800584:	75 ee                	jne    800574 <vprintfmt+0x280>
  800586:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800589:	e9 8f fd ff ff       	jmp    80031d <vprintfmt+0x29>
	if (lflag >= 2)
  80058e:	83 fa 01             	cmp    $0x1,%edx
  800591:	7e 16                	jle    8005a9 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8d 50 08             	lea    0x8(%eax),%edx
  800599:	89 55 14             	mov    %edx,0x14(%ebp)
  80059c:	8b 50 04             	mov    0x4(%eax),%edx
  80059f:	8b 00                	mov    (%eax),%eax
  8005a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a7:	eb 32                	jmp    8005db <vprintfmt+0x2e7>
	else if (lflag)
  8005a9:	85 d2                	test   %edx,%edx
  8005ab:	74 18                	je     8005c5 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 50 04             	lea    0x4(%eax),%edx
  8005b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b6:	8b 30                	mov    (%eax),%esi
  8005b8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005bb:	89 f0                	mov    %esi,%eax
  8005bd:	c1 f8 1f             	sar    $0x1f,%eax
  8005c0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005c3:	eb 16                	jmp    8005db <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 50 04             	lea    0x4(%eax),%edx
  8005cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ce:	8b 30                	mov    (%eax),%esi
  8005d0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005d3:	89 f0                	mov    %esi,%eax
  8005d5:	c1 f8 1f             	sar    $0x1f,%eax
  8005d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  8005db:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005de:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  8005e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8005e6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ea:	0f 89 80 00 00 00    	jns    800670 <vprintfmt+0x37c>
				putch('-', putdat);
  8005f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005fb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800601:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800604:	f7 d8                	neg    %eax
  800606:	83 d2 00             	adc    $0x0,%edx
  800609:	f7 da                	neg    %edx
			base = 10;
  80060b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800610:	eb 5e                	jmp    800670 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800612:	8d 45 14             	lea    0x14(%ebp),%eax
  800615:	e8 5b fc ff ff       	call   800275 <getuint>
			base = 10;
  80061a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80061f:	eb 4f                	jmp    800670 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800621:	8d 45 14             	lea    0x14(%ebp),%eax
  800624:	e8 4c fc ff ff       	call   800275 <getuint>
			base = 8;
  800629:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80062e:	eb 40                	jmp    800670 <vprintfmt+0x37c>
			putch('0', putdat);
  800630:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800634:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80063b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80063e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800642:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800649:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 04             	lea    0x4(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800655:	8b 00                	mov    (%eax),%eax
  800657:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80065c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800661:	eb 0d                	jmp    800670 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
  800666:	e8 0a fc ff ff       	call   800275 <getuint>
			base = 16;
  80066b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800670:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800674:	89 74 24 10          	mov    %esi,0x10(%esp)
  800678:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80067b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80067f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800683:	89 04 24             	mov    %eax,(%esp)
  800686:	89 54 24 04          	mov    %edx,0x4(%esp)
  80068a:	89 fa                	mov    %edi,%edx
  80068c:	8b 45 08             	mov    0x8(%ebp),%eax
  80068f:	e8 ec fa ff ff       	call   800180 <printnum>
			break;
  800694:	e9 84 fc ff ff       	jmp    80031d <vprintfmt+0x29>
			putch(ch, putdat);
  800699:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069d:	89 0c 24             	mov    %ecx,(%esp)
  8006a0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006a3:	e9 75 fc ff ff       	jmp    80031d <vprintfmt+0x29>
			putch('%', putdat);
  8006a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ac:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006b3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006ba:	0f 84 5b fc ff ff    	je     80031b <vprintfmt+0x27>
  8006c0:	89 f3                	mov    %esi,%ebx
  8006c2:	83 eb 01             	sub    $0x1,%ebx
  8006c5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006c9:	75 f7                	jne    8006c2 <vprintfmt+0x3ce>
  8006cb:	e9 4d fc ff ff       	jmp    80031d <vprintfmt+0x29>
}
  8006d0:	83 c4 3c             	add    $0x3c,%esp
  8006d3:	5b                   	pop    %ebx
  8006d4:	5e                   	pop    %esi
  8006d5:	5f                   	pop    %edi
  8006d6:	5d                   	pop    %ebp
  8006d7:	c3                   	ret    

008006d8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	83 ec 28             	sub    $0x28,%esp
  8006de:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006eb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 30                	je     800729 <vsnprintf+0x51>
  8006f9:	85 d2                	test   %edx,%edx
  8006fb:	7e 2c                	jle    800729 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800704:	8b 45 10             	mov    0x10(%ebp),%eax
  800707:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800712:	c7 04 24 af 02 80 00 	movl   $0x8002af,(%esp)
  800719:	e8 d6 fb ff ff       	call   8002f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800721:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800724:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800727:	eb 05                	jmp    80072e <vsnprintf+0x56>
		return -E_INVAL;
  800729:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800736:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800739:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073d:	8b 45 10             	mov    0x10(%ebp),%eax
  800740:	89 44 24 08          	mov    %eax,0x8(%esp)
  800744:	8b 45 0c             	mov    0xc(%ebp),%eax
  800747:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074b:	8b 45 08             	mov    0x8(%ebp),%eax
  80074e:	89 04 24             	mov    %eax,(%esp)
  800751:	e8 82 ff ff ff       	call   8006d8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    
  800758:	66 90                	xchg   %ax,%ax
  80075a:	66 90                	xchg   %ax,%ax
  80075c:	66 90                	xchg   %ax,%ax
  80075e:	66 90                	xchg   %ax,%ax

00800760 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	80 3a 00             	cmpb   $0x0,(%edx)
  800769:	74 10                	je     80077b <strlen+0x1b>
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800770:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800773:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800777:	75 f7                	jne    800770 <strlen+0x10>
  800779:	eb 05                	jmp    800780 <strlen+0x20>
  80077b:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	53                   	push   %ebx
  800786:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800789:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078c:	85 c9                	test   %ecx,%ecx
  80078e:	74 1c                	je     8007ac <strnlen+0x2a>
  800790:	80 3b 00             	cmpb   $0x0,(%ebx)
  800793:	74 1e                	je     8007b3 <strnlen+0x31>
  800795:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80079a:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079c:	39 ca                	cmp    %ecx,%edx
  80079e:	74 18                	je     8007b8 <strnlen+0x36>
  8007a0:	83 c2 01             	add    $0x1,%edx
  8007a3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007a8:	75 f0                	jne    80079a <strnlen+0x18>
  8007aa:	eb 0c                	jmp    8007b8 <strnlen+0x36>
  8007ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b1:	eb 05                	jmp    8007b8 <strnlen+0x36>
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8007b8:	5b                   	pop    %ebx
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c5:	89 c2                	mov    %eax,%edx
  8007c7:	83 c2 01             	add    $0x1,%edx
  8007ca:	83 c1 01             	add    $0x1,%ecx
  8007cd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d4:	84 db                	test   %bl,%bl
  8007d6:	75 ef                	jne    8007c7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d8:	5b                   	pop    %ebx
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e5:	89 1c 24             	mov    %ebx,(%esp)
  8007e8:	e8 73 ff ff ff       	call   800760 <strlen>
	strcpy(dst + len, src);
  8007ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007f4:	01 d8                	add    %ebx,%eax
  8007f6:	89 04 24             	mov    %eax,(%esp)
  8007f9:	e8 bd ff ff ff       	call   8007bb <strcpy>
	return dst;
}
  8007fe:	89 d8                	mov    %ebx,%eax
  800800:	83 c4 08             	add    $0x8,%esp
  800803:	5b                   	pop    %ebx
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	56                   	push   %esi
  80080a:	53                   	push   %ebx
  80080b:	8b 75 08             	mov    0x8(%ebp),%esi
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800811:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800814:	85 db                	test   %ebx,%ebx
  800816:	74 17                	je     80082f <strncpy+0x29>
  800818:	01 f3                	add    %esi,%ebx
  80081a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80081c:	83 c1 01             	add    $0x1,%ecx
  80081f:	0f b6 02             	movzbl (%edx),%eax
  800822:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800825:	80 3a 01             	cmpb   $0x1,(%edx)
  800828:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80082b:	39 d9                	cmp    %ebx,%ecx
  80082d:	75 ed                	jne    80081c <strncpy+0x16>
	}
	return ret;
}
  80082f:	89 f0                	mov    %esi,%eax
  800831:	5b                   	pop    %ebx
  800832:	5e                   	pop    %esi
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	57                   	push   %edi
  800839:	56                   	push   %esi
  80083a:	53                   	push   %ebx
  80083b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800841:	8b 75 10             	mov    0x10(%ebp),%esi
  800844:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800846:	85 f6                	test   %esi,%esi
  800848:	74 34                	je     80087e <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  80084a:	83 fe 01             	cmp    $0x1,%esi
  80084d:	74 26                	je     800875 <strlcpy+0x40>
  80084f:	0f b6 0b             	movzbl (%ebx),%ecx
  800852:	84 c9                	test   %cl,%cl
  800854:	74 23                	je     800879 <strlcpy+0x44>
  800856:	83 ee 02             	sub    $0x2,%esi
  800859:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800864:	39 f2                	cmp    %esi,%edx
  800866:	74 13                	je     80087b <strlcpy+0x46>
  800868:	83 c2 01             	add    $0x1,%edx
  80086b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80086f:	84 c9                	test   %cl,%cl
  800871:	75 eb                	jne    80085e <strlcpy+0x29>
  800873:	eb 06                	jmp    80087b <strlcpy+0x46>
  800875:	89 f8                	mov    %edi,%eax
  800877:	eb 02                	jmp    80087b <strlcpy+0x46>
  800879:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  80087b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087e:	29 f8                	sub    %edi,%eax
}
  800880:	5b                   	pop    %ebx
  800881:	5e                   	pop    %esi
  800882:	5f                   	pop    %edi
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088e:	0f b6 01             	movzbl (%ecx),%eax
  800891:	84 c0                	test   %al,%al
  800893:	74 15                	je     8008aa <strcmp+0x25>
  800895:	3a 02                	cmp    (%edx),%al
  800897:	75 11                	jne    8008aa <strcmp+0x25>
		p++, q++;
  800899:	83 c1 01             	add    $0x1,%ecx
  80089c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80089f:	0f b6 01             	movzbl (%ecx),%eax
  8008a2:	84 c0                	test   %al,%al
  8008a4:	74 04                	je     8008aa <strcmp+0x25>
  8008a6:	3a 02                	cmp    (%edx),%al
  8008a8:	74 ef                	je     800899 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008aa:	0f b6 c0             	movzbl %al,%eax
  8008ad:	0f b6 12             	movzbl (%edx),%edx
  8008b0:	29 d0                	sub    %edx,%eax
}
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	56                   	push   %esi
  8008b8:	53                   	push   %ebx
  8008b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bf:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8008c2:	85 f6                	test   %esi,%esi
  8008c4:	74 29                	je     8008ef <strncmp+0x3b>
  8008c6:	0f b6 03             	movzbl (%ebx),%eax
  8008c9:	84 c0                	test   %al,%al
  8008cb:	74 30                	je     8008fd <strncmp+0x49>
  8008cd:	3a 02                	cmp    (%edx),%al
  8008cf:	75 2c                	jne    8008fd <strncmp+0x49>
  8008d1:	8d 43 01             	lea    0x1(%ebx),%eax
  8008d4:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8008d6:	89 c3                	mov    %eax,%ebx
  8008d8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008db:	39 f0                	cmp    %esi,%eax
  8008dd:	74 17                	je     8008f6 <strncmp+0x42>
  8008df:	0f b6 08             	movzbl (%eax),%ecx
  8008e2:	84 c9                	test   %cl,%cl
  8008e4:	74 17                	je     8008fd <strncmp+0x49>
  8008e6:	83 c0 01             	add    $0x1,%eax
  8008e9:	3a 0a                	cmp    (%edx),%cl
  8008eb:	74 e9                	je     8008d6 <strncmp+0x22>
  8008ed:	eb 0e                	jmp    8008fd <strncmp+0x49>
	if (n == 0)
		return 0;
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f4:	eb 0f                	jmp    800905 <strncmp+0x51>
  8008f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fb:	eb 08                	jmp    800905 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fd:	0f b6 03             	movzbl (%ebx),%eax
  800900:	0f b6 12             	movzbl (%edx),%edx
  800903:	29 d0                	sub    %edx,%eax
}
  800905:	5b                   	pop    %ebx
  800906:	5e                   	pop    %esi
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	53                   	push   %ebx
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800913:	0f b6 18             	movzbl (%eax),%ebx
  800916:	84 db                	test   %bl,%bl
  800918:	74 1d                	je     800937 <strchr+0x2e>
  80091a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80091c:	38 d3                	cmp    %dl,%bl
  80091e:	75 06                	jne    800926 <strchr+0x1d>
  800920:	eb 1a                	jmp    80093c <strchr+0x33>
  800922:	38 ca                	cmp    %cl,%dl
  800924:	74 16                	je     80093c <strchr+0x33>
	for (; *s; s++)
  800926:	83 c0 01             	add    $0x1,%eax
  800929:	0f b6 10             	movzbl (%eax),%edx
  80092c:	84 d2                	test   %dl,%dl
  80092e:	75 f2                	jne    800922 <strchr+0x19>
			return (char *) s;
	return 0;
  800930:	b8 00 00 00 00       	mov    $0x0,%eax
  800935:	eb 05                	jmp    80093c <strchr+0x33>
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093c:	5b                   	pop    %ebx
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	53                   	push   %ebx
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800949:	0f b6 18             	movzbl (%eax),%ebx
  80094c:	84 db                	test   %bl,%bl
  80094e:	74 16                	je     800966 <strfind+0x27>
  800950:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800952:	38 d3                	cmp    %dl,%bl
  800954:	75 06                	jne    80095c <strfind+0x1d>
  800956:	eb 0e                	jmp    800966 <strfind+0x27>
  800958:	38 ca                	cmp    %cl,%dl
  80095a:	74 0a                	je     800966 <strfind+0x27>
	for (; *s; s++)
  80095c:	83 c0 01             	add    $0x1,%eax
  80095f:	0f b6 10             	movzbl (%eax),%edx
  800962:	84 d2                	test   %dl,%dl
  800964:	75 f2                	jne    800958 <strfind+0x19>
			break;
	return (char *) s;
}
  800966:	5b                   	pop    %ebx
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	57                   	push   %edi
  80096d:	56                   	push   %esi
  80096e:	53                   	push   %ebx
  80096f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800972:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800975:	85 c9                	test   %ecx,%ecx
  800977:	74 36                	je     8009af <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800979:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097f:	75 28                	jne    8009a9 <memset+0x40>
  800981:	f6 c1 03             	test   $0x3,%cl
  800984:	75 23                	jne    8009a9 <memset+0x40>
		c &= 0xFF;
  800986:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80098a:	89 d3                	mov    %edx,%ebx
  80098c:	c1 e3 08             	shl    $0x8,%ebx
  80098f:	89 d6                	mov    %edx,%esi
  800991:	c1 e6 18             	shl    $0x18,%esi
  800994:	89 d0                	mov    %edx,%eax
  800996:	c1 e0 10             	shl    $0x10,%eax
  800999:	09 f0                	or     %esi,%eax
  80099b:	09 c2                	or     %eax,%edx
  80099d:	89 d0                	mov    %edx,%eax
  80099f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009a4:	fc                   	cld    
  8009a5:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a7:	eb 06                	jmp    8009af <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ac:	fc                   	cld    
  8009ad:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009af:	89 f8                	mov    %edi,%eax
  8009b1:	5b                   	pop    %ebx
  8009b2:	5e                   	pop    %esi
  8009b3:	5f                   	pop    %edi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	57                   	push   %edi
  8009ba:	56                   	push   %esi
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c4:	39 c6                	cmp    %eax,%esi
  8009c6:	73 35                	jae    8009fd <memmove+0x47>
  8009c8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009cb:	39 d0                	cmp    %edx,%eax
  8009cd:	73 2e                	jae    8009fd <memmove+0x47>
		s += n;
		d += n;
  8009cf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009d2:	89 d6                	mov    %edx,%esi
  8009d4:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009dc:	75 13                	jne    8009f1 <memmove+0x3b>
  8009de:	f6 c1 03             	test   $0x3,%cl
  8009e1:	75 0e                	jne    8009f1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009e3:	83 ef 04             	sub    $0x4,%edi
  8009e6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009ec:	fd                   	std    
  8009ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ef:	eb 09                	jmp    8009fa <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009f1:	83 ef 01             	sub    $0x1,%edi
  8009f4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009f7:	fd                   	std    
  8009f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009fa:	fc                   	cld    
  8009fb:	eb 1d                	jmp    800a1a <memmove+0x64>
  8009fd:	89 f2                	mov    %esi,%edx
  8009ff:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a01:	f6 c2 03             	test   $0x3,%dl
  800a04:	75 0f                	jne    800a15 <memmove+0x5f>
  800a06:	f6 c1 03             	test   $0x3,%cl
  800a09:	75 0a                	jne    800a15 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a0b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a0e:	89 c7                	mov    %eax,%edi
  800a10:	fc                   	cld    
  800a11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a13:	eb 05                	jmp    800a1a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800a15:	89 c7                	mov    %eax,%edi
  800a17:	fc                   	cld    
  800a18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a1a:	5e                   	pop    %esi
  800a1b:	5f                   	pop    %edi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a24:	8b 45 10             	mov    0x10(%ebp),%eax
  800a27:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	89 04 24             	mov    %eax,(%esp)
  800a38:	e8 79 ff ff ff       	call   8009b6 <memmove>
}
  800a3d:	c9                   	leave  
  800a3e:	c3                   	ret    

00800a3f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800a51:	85 c0                	test   %eax,%eax
  800a53:	74 36                	je     800a8b <memcmp+0x4c>
		if (*s1 != *s2)
  800a55:	0f b6 03             	movzbl (%ebx),%eax
  800a58:	0f b6 0e             	movzbl (%esi),%ecx
  800a5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a60:	38 c8                	cmp    %cl,%al
  800a62:	74 1c                	je     800a80 <memcmp+0x41>
  800a64:	eb 10                	jmp    800a76 <memcmp+0x37>
  800a66:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a6b:	83 c2 01             	add    $0x1,%edx
  800a6e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a72:	38 c8                	cmp    %cl,%al
  800a74:	74 0a                	je     800a80 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800a76:	0f b6 c0             	movzbl %al,%eax
  800a79:	0f b6 c9             	movzbl %cl,%ecx
  800a7c:	29 c8                	sub    %ecx,%eax
  800a7e:	eb 10                	jmp    800a90 <memcmp+0x51>
	while (n-- > 0) {
  800a80:	39 fa                	cmp    %edi,%edx
  800a82:	75 e2                	jne    800a66 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
  800a89:	eb 05                	jmp    800a90 <memcmp+0x51>
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5f                   	pop    %edi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	53                   	push   %ebx
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800a9f:	89 c2                	mov    %eax,%edx
  800aa1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa4:	39 d0                	cmp    %edx,%eax
  800aa6:	73 13                	jae    800abb <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa8:	89 d9                	mov    %ebx,%ecx
  800aaa:	38 18                	cmp    %bl,(%eax)
  800aac:	75 06                	jne    800ab4 <memfind+0x1f>
  800aae:	eb 0b                	jmp    800abb <memfind+0x26>
  800ab0:	38 08                	cmp    %cl,(%eax)
  800ab2:	74 07                	je     800abb <memfind+0x26>
	for (; s < ends; s++)
  800ab4:	83 c0 01             	add    $0x1,%eax
  800ab7:	39 d0                	cmp    %edx,%eax
  800ab9:	75 f5                	jne    800ab0 <memfind+0x1b>
			break;
	return (void *) s;
}
  800abb:	5b                   	pop    %ebx
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aca:	0f b6 0a             	movzbl (%edx),%ecx
  800acd:	80 f9 09             	cmp    $0x9,%cl
  800ad0:	74 05                	je     800ad7 <strtol+0x19>
  800ad2:	80 f9 20             	cmp    $0x20,%cl
  800ad5:	75 10                	jne    800ae7 <strtol+0x29>
		s++;
  800ad7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800ada:	0f b6 0a             	movzbl (%edx),%ecx
  800add:	80 f9 09             	cmp    $0x9,%cl
  800ae0:	74 f5                	je     800ad7 <strtol+0x19>
  800ae2:	80 f9 20             	cmp    $0x20,%cl
  800ae5:	74 f0                	je     800ad7 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800ae7:	80 f9 2b             	cmp    $0x2b,%cl
  800aea:	75 0a                	jne    800af6 <strtol+0x38>
		s++;
  800aec:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800aef:	bf 00 00 00 00       	mov    $0x0,%edi
  800af4:	eb 11                	jmp    800b07 <strtol+0x49>
  800af6:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800afb:	80 f9 2d             	cmp    $0x2d,%cl
  800afe:	75 07                	jne    800b07 <strtol+0x49>
		s++, neg = 1;
  800b00:	83 c2 01             	add    $0x1,%edx
  800b03:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b07:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b0c:	75 15                	jne    800b23 <strtol+0x65>
  800b0e:	80 3a 30             	cmpb   $0x30,(%edx)
  800b11:	75 10                	jne    800b23 <strtol+0x65>
  800b13:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b17:	75 0a                	jne    800b23 <strtol+0x65>
		s += 2, base = 16;
  800b19:	83 c2 02             	add    $0x2,%edx
  800b1c:	b8 10 00 00 00       	mov    $0x10,%eax
  800b21:	eb 10                	jmp    800b33 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800b23:	85 c0                	test   %eax,%eax
  800b25:	75 0c                	jne    800b33 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b27:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800b29:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2c:	75 05                	jne    800b33 <strtol+0x75>
		s++, base = 8;
  800b2e:	83 c2 01             	add    $0x1,%edx
  800b31:	b0 08                	mov    $0x8,%al
		base = 10;
  800b33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b38:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b3b:	0f b6 0a             	movzbl (%edx),%ecx
  800b3e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b41:	89 f0                	mov    %esi,%eax
  800b43:	3c 09                	cmp    $0x9,%al
  800b45:	77 08                	ja     800b4f <strtol+0x91>
			dig = *s - '0';
  800b47:	0f be c9             	movsbl %cl,%ecx
  800b4a:	83 e9 30             	sub    $0x30,%ecx
  800b4d:	eb 20                	jmp    800b6f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800b4f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b52:	89 f0                	mov    %esi,%eax
  800b54:	3c 19                	cmp    $0x19,%al
  800b56:	77 08                	ja     800b60 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800b58:	0f be c9             	movsbl %cl,%ecx
  800b5b:	83 e9 57             	sub    $0x57,%ecx
  800b5e:	eb 0f                	jmp    800b6f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800b60:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b63:	89 f0                	mov    %esi,%eax
  800b65:	3c 19                	cmp    $0x19,%al
  800b67:	77 16                	ja     800b7f <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b69:	0f be c9             	movsbl %cl,%ecx
  800b6c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b6f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b72:	7d 0f                	jge    800b83 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b74:	83 c2 01             	add    $0x1,%edx
  800b77:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b7b:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b7d:	eb bc                	jmp    800b3b <strtol+0x7d>
  800b7f:	89 d8                	mov    %ebx,%eax
  800b81:	eb 02                	jmp    800b85 <strtol+0xc7>
  800b83:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b85:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b89:	74 05                	je     800b90 <strtol+0xd2>
		*endptr = (char *) s;
  800b8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b90:	f7 d8                	neg    %eax
  800b92:	85 ff                	test   %edi,%edi
  800b94:	0f 44 c3             	cmove  %ebx,%eax
}
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bad:	89 c3                	mov    %eax,%ebx
  800baf:	89 c7                	mov    %eax,%edi
  800bb1:	89 c6                	mov    %eax,%esi
  800bb3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_cgetc>:

int
sys_cgetc(void)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bca:	89 d1                	mov    %edx,%ecx
  800bcc:	89 d3                	mov    %edx,%ebx
  800bce:	89 d7                	mov    %edx,%edi
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800be2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	89 cb                	mov    %ecx,%ebx
  800bf1:	89 cf                	mov    %ecx,%edi
  800bf3:	89 ce                	mov    %ecx,%esi
  800bf5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	7e 28                	jle    800c23 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bff:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c06:	00 
  800c07:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800c0e:	00 
  800c0f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c16:	00 
  800c17:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800c1e:	e8 63 10 00 00       	call   801c86 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c23:	83 c4 2c             	add    $0x2c,%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c31:	ba 00 00 00 00       	mov    $0x0,%edx
  800c36:	b8 02 00 00 00       	mov    $0x2,%eax
  800c3b:	89 d1                	mov    %edx,%ecx
  800c3d:	89 d3                	mov    %edx,%ebx
  800c3f:	89 d7                	mov    %edx,%edi
  800c41:	89 d6                	mov    %edx,%esi
  800c43:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_yield>:

void
sys_yield(void)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c50:	ba 00 00 00 00       	mov    $0x0,%edx
  800c55:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c5a:	89 d1                	mov    %edx,%ecx
  800c5c:	89 d3                	mov    %edx,%ebx
  800c5e:	89 d7                	mov    %edx,%edi
  800c60:	89 d6                	mov    %edx,%esi
  800c62:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c72:	be 00 00 00 00       	mov    $0x0,%esi
  800c77:	b8 04 00 00 00       	mov    $0x4,%eax
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c85:	89 f7                	mov    %esi,%edi
  800c87:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	7e 28                	jle    800cb5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c91:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c98:	00 
  800c99:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800ca0:	00 
  800ca1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca8:	00 
  800ca9:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800cb0:	e8 d1 0f 00 00       	call   801c86 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb5:	83 c4 2c             	add    $0x2c,%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd7:	8b 75 18             	mov    0x18(%ebp),%esi
  800cda:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	7e 28                	jle    800d08 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ceb:	00 
  800cec:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800cf3:	00 
  800cf4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfb:	00 
  800cfc:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800d03:	e8 7e 0f 00 00       	call   801c86 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d08:	83 c4 2c             	add    $0x2c,%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
  800d16:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	89 df                	mov    %ebx,%edi
  800d2b:	89 de                	mov    %ebx,%esi
  800d2d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	7e 28                	jle    800d5b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d37:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d3e:	00 
  800d3f:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800d46:	00 
  800d47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4e:	00 
  800d4f:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800d56:	e8 2b 0f 00 00       	call   801c86 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5b:	83 c4 2c             	add    $0x2c,%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d71:	b8 08 00 00 00       	mov    $0x8,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 df                	mov    %ebx,%edi
  800d7e:	89 de                	mov    %ebx,%esi
  800d80:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7e 28                	jle    800dae <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d91:	00 
  800d92:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800d99:	00 
  800d9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da1:	00 
  800da2:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800da9:	e8 d8 0e 00 00       	call   801c86 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dae:	83 c4 2c             	add    $0x2c,%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc4:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcf:	89 df                	mov    %ebx,%edi
  800dd1:	89 de                	mov    %ebx,%esi
  800dd3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 28                	jle    800e01 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800de4:	00 
  800de5:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800dec:	00 
  800ded:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df4:	00 
  800df5:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800dfc:	e8 85 0e 00 00       	call   801c86 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e01:	83 c4 2c             	add    $0x2c,%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
  800e0f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e17:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	89 df                	mov    %ebx,%edi
  800e24:	89 de                	mov    %ebx,%esi
  800e26:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	7e 28                	jle    800e54 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e30:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e37:	00 
  800e38:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800e3f:	00 
  800e40:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e47:	00 
  800e48:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800e4f:	e8 32 0e 00 00       	call   801c86 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e54:	83 c4 2c             	add    $0x2c,%esp
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e62:	be 00 00 00 00       	mov    $0x0,%esi
  800e67:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e78:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e7a:	5b                   	pop    %ebx
  800e7b:	5e                   	pop    %esi
  800e7c:	5f                   	pop    %edi
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	57                   	push   %edi
  800e83:	56                   	push   %esi
  800e84:	53                   	push   %ebx
  800e85:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e8d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e92:	8b 55 08             	mov    0x8(%ebp),%edx
  800e95:	89 cb                	mov    %ecx,%ebx
  800e97:	89 cf                	mov    %ecx,%edi
  800e99:	89 ce                	mov    %ecx,%esi
  800e9b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	7e 28                	jle    800ec9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800eac:	00 
  800ead:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800eb4:	00 
  800eb5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebc:	00 
  800ebd:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800ec4:	e8 bd 0d 00 00       	call   801c86 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ec9:	83 c4 2c             	add    $0x2c,%esp
  800ecc:	5b                   	pop    %ebx
  800ecd:	5e                   	pop    %esi
  800ece:	5f                   	pop    %edi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    
  800ed1:	66 90                	xchg   %ax,%ax
  800ed3:	66 90                	xchg   %ax,%ax
  800ed5:	66 90                	xchg   %ax,%ax
  800ed7:	66 90                	xchg   %ax,%ax
  800ed9:	66 90                	xchg   %ax,%ax
  800edb:	66 90                	xchg   %ax,%ax
  800edd:	66 90                	xchg   %ax,%ax
  800edf:	90                   	nop

00800ee0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee6:	05 00 00 00 30       	add    $0x30000000,%eax
  800eeb:	c1 e8 0c             	shr    $0xc,%eax
}
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800efb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f00:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f0a:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800f0f:	a8 01                	test   $0x1,%al
  800f11:	74 34                	je     800f47 <fd_alloc+0x40>
  800f13:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800f18:	a8 01                	test   $0x1,%al
  800f1a:	74 32                	je     800f4e <fd_alloc+0x47>
  800f1c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  800f21:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f23:	89 c2                	mov    %eax,%edx
  800f25:	c1 ea 16             	shr    $0x16,%edx
  800f28:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f2f:	f6 c2 01             	test   $0x1,%dl
  800f32:	74 1f                	je     800f53 <fd_alloc+0x4c>
  800f34:	89 c2                	mov    %eax,%edx
  800f36:	c1 ea 0c             	shr    $0xc,%edx
  800f39:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f40:	f6 c2 01             	test   $0x1,%dl
  800f43:	75 1a                	jne    800f5f <fd_alloc+0x58>
  800f45:	eb 0c                	jmp    800f53 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  800f47:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800f4c:	eb 05                	jmp    800f53 <fd_alloc+0x4c>
  800f4e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  800f53:	8b 45 08             	mov    0x8(%ebp),%eax
  800f56:	89 08                	mov    %ecx,(%eax)
			return 0;
  800f58:	b8 00 00 00 00       	mov    $0x0,%eax
  800f5d:	eb 1a                	jmp    800f79 <fd_alloc+0x72>
  800f5f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800f64:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f69:	75 b6                	jne    800f21 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f74:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f81:	83 f8 1f             	cmp    $0x1f,%eax
  800f84:	77 36                	ja     800fbc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f86:	c1 e0 0c             	shl    $0xc,%eax
  800f89:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f8e:	89 c2                	mov    %eax,%edx
  800f90:	c1 ea 16             	shr    $0x16,%edx
  800f93:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f9a:	f6 c2 01             	test   $0x1,%dl
  800f9d:	74 24                	je     800fc3 <fd_lookup+0x48>
  800f9f:	89 c2                	mov    %eax,%edx
  800fa1:	c1 ea 0c             	shr    $0xc,%edx
  800fa4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fab:	f6 c2 01             	test   $0x1,%dl
  800fae:	74 1a                	je     800fca <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fb0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb3:	89 02                	mov    %eax,(%edx)
	return 0;
  800fb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800fba:	eb 13                	jmp    800fcf <fd_lookup+0x54>
		return -E_INVAL;
  800fbc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fc1:	eb 0c                	jmp    800fcf <fd_lookup+0x54>
		return -E_INVAL;
  800fc3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fc8:	eb 05                	jmp    800fcf <fd_lookup+0x54>
  800fca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    

00800fd1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	53                   	push   %ebx
  800fd5:	83 ec 14             	sub    $0x14,%esp
  800fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800fde:	39 05 04 30 80 00    	cmp    %eax,0x803004
  800fe4:	75 1e                	jne    801004 <dev_lookup+0x33>
  800fe6:	eb 0e                	jmp    800ff6 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  800fe8:	b8 20 30 80 00       	mov    $0x803020,%eax
  800fed:	eb 0c                	jmp    800ffb <dev_lookup+0x2a>
  800fef:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800ff4:	eb 05                	jmp    800ffb <dev_lookup+0x2a>
  800ff6:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  800ffb:	89 03                	mov    %eax,(%ebx)
			return 0;
  800ffd:	b8 00 00 00 00       	mov    $0x0,%eax
  801002:	eb 38                	jmp    80103c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  801004:	39 05 20 30 80 00    	cmp    %eax,0x803020
  80100a:	74 dc                	je     800fe8 <dev_lookup+0x17>
  80100c:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  801012:	74 db                	je     800fef <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801014:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80101a:	8b 52 48             	mov    0x48(%edx),%edx
  80101d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801021:	89 54 24 04          	mov    %edx,0x4(%esp)
  801025:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  80102c:	e8 35 f1 ff ff       	call   800166 <cprintf>
	*dev = 0;
  801031:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801037:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80103c:	83 c4 14             	add    $0x14,%esp
  80103f:	5b                   	pop    %ebx
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    

00801042 <fd_close>:
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	56                   	push   %esi
  801046:	53                   	push   %ebx
  801047:	83 ec 20             	sub    $0x20,%esp
  80104a:	8b 75 08             	mov    0x8(%ebp),%esi
  80104d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801050:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801053:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801057:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80105d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801060:	89 04 24             	mov    %eax,(%esp)
  801063:	e8 13 ff ff ff       	call   800f7b <fd_lookup>
  801068:	85 c0                	test   %eax,%eax
  80106a:	78 05                	js     801071 <fd_close+0x2f>
	    || fd != fd2)
  80106c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80106f:	74 0c                	je     80107d <fd_close+0x3b>
		return (must_exist ? r : 0);
  801071:	84 db                	test   %bl,%bl
  801073:	ba 00 00 00 00       	mov    $0x0,%edx
  801078:	0f 44 c2             	cmove  %edx,%eax
  80107b:	eb 3f                	jmp    8010bc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80107d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801080:	89 44 24 04          	mov    %eax,0x4(%esp)
  801084:	8b 06                	mov    (%esi),%eax
  801086:	89 04 24             	mov    %eax,(%esp)
  801089:	e8 43 ff ff ff       	call   800fd1 <dev_lookup>
  80108e:	89 c3                	mov    %eax,%ebx
  801090:	85 c0                	test   %eax,%eax
  801092:	78 16                	js     8010aa <fd_close+0x68>
		if (dev->dev_close)
  801094:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801097:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80109a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	74 07                	je     8010aa <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8010a3:	89 34 24             	mov    %esi,(%esp)
  8010a6:	ff d0                	call   *%eax
  8010a8:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8010aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b5:	e8 56 fc ff ff       	call   800d10 <sys_page_unmap>
	return r;
  8010ba:	89 d8                	mov    %ebx,%eax
}
  8010bc:	83 c4 20             	add    $0x20,%esp
  8010bf:	5b                   	pop    %ebx
  8010c0:	5e                   	pop    %esi
  8010c1:	5d                   	pop    %ebp
  8010c2:	c3                   	ret    

008010c3 <close>:

int
close(int fdnum)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d3:	89 04 24             	mov    %eax,(%esp)
  8010d6:	e8 a0 fe ff ff       	call   800f7b <fd_lookup>
  8010db:	89 c2                	mov    %eax,%edx
  8010dd:	85 d2                	test   %edx,%edx
  8010df:	78 13                	js     8010f4 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8010e1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010e8:	00 
  8010e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ec:	89 04 24             	mov    %eax,(%esp)
  8010ef:	e8 4e ff ff ff       	call   801042 <fd_close>
}
  8010f4:	c9                   	leave  
  8010f5:	c3                   	ret    

008010f6 <close_all>:

void
close_all(void)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	53                   	push   %ebx
  8010fa:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801102:	89 1c 24             	mov    %ebx,(%esp)
  801105:	e8 b9 ff ff ff       	call   8010c3 <close>
	for (i = 0; i < MAXFD; i++)
  80110a:	83 c3 01             	add    $0x1,%ebx
  80110d:	83 fb 20             	cmp    $0x20,%ebx
  801110:	75 f0                	jne    801102 <close_all+0xc>
}
  801112:	83 c4 14             	add    $0x14,%esp
  801115:	5b                   	pop    %ebx
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    

00801118 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	57                   	push   %edi
  80111c:	56                   	push   %esi
  80111d:	53                   	push   %ebx
  80111e:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801121:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801124:	89 44 24 04          	mov    %eax,0x4(%esp)
  801128:	8b 45 08             	mov    0x8(%ebp),%eax
  80112b:	89 04 24             	mov    %eax,(%esp)
  80112e:	e8 48 fe ff ff       	call   800f7b <fd_lookup>
  801133:	89 c2                	mov    %eax,%edx
  801135:	85 d2                	test   %edx,%edx
  801137:	0f 88 e1 00 00 00    	js     80121e <dup+0x106>
		return r;
	close(newfdnum);
  80113d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801140:	89 04 24             	mov    %eax,(%esp)
  801143:	e8 7b ff ff ff       	call   8010c3 <close>

	newfd = INDEX2FD(newfdnum);
  801148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80114b:	c1 e3 0c             	shl    $0xc,%ebx
  80114e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801154:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801157:	89 04 24             	mov    %eax,(%esp)
  80115a:	e8 91 fd ff ff       	call   800ef0 <fd2data>
  80115f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801161:	89 1c 24             	mov    %ebx,(%esp)
  801164:	e8 87 fd ff ff       	call   800ef0 <fd2data>
  801169:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80116b:	89 f0                	mov    %esi,%eax
  80116d:	c1 e8 16             	shr    $0x16,%eax
  801170:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801177:	a8 01                	test   $0x1,%al
  801179:	74 43                	je     8011be <dup+0xa6>
  80117b:	89 f0                	mov    %esi,%eax
  80117d:	c1 e8 0c             	shr    $0xc,%eax
  801180:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801187:	f6 c2 01             	test   $0x1,%dl
  80118a:	74 32                	je     8011be <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80118c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801193:	25 07 0e 00 00       	and    $0xe07,%eax
  801198:	89 44 24 10          	mov    %eax,0x10(%esp)
  80119c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011a7:	00 
  8011a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b3:	e8 05 fb ff ff       	call   800cbd <sys_page_map>
  8011b8:	89 c6                	mov    %eax,%esi
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	78 3e                	js     8011fc <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	c1 ea 0c             	shr    $0xc,%edx
  8011c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011cd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011d3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011d7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011e2:	00 
  8011e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ee:	e8 ca fa ff ff       	call   800cbd <sys_page_map>
  8011f3:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8011f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011f8:	85 f6                	test   %esi,%esi
  8011fa:	79 22                	jns    80121e <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8011fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801200:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801207:	e8 04 fb ff ff       	call   800d10 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80120c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801210:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801217:	e8 f4 fa ff ff       	call   800d10 <sys_page_unmap>
	return r;
  80121c:	89 f0                	mov    %esi,%eax
}
  80121e:	83 c4 3c             	add    $0x3c,%esp
  801221:	5b                   	pop    %ebx
  801222:	5e                   	pop    %esi
  801223:	5f                   	pop    %edi
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    

00801226 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	53                   	push   %ebx
  80122a:	83 ec 24             	sub    $0x24,%esp
  80122d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801230:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801233:	89 44 24 04          	mov    %eax,0x4(%esp)
  801237:	89 1c 24             	mov    %ebx,(%esp)
  80123a:	e8 3c fd ff ff       	call   800f7b <fd_lookup>
  80123f:	89 c2                	mov    %eax,%edx
  801241:	85 d2                	test   %edx,%edx
  801243:	78 6d                	js     8012b2 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801245:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801248:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124f:	8b 00                	mov    (%eax),%eax
  801251:	89 04 24             	mov    %eax,(%esp)
  801254:	e8 78 fd ff ff       	call   800fd1 <dev_lookup>
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 55                	js     8012b2 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80125d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801260:	8b 50 08             	mov    0x8(%eax),%edx
  801263:	83 e2 03             	and    $0x3,%edx
  801266:	83 fa 01             	cmp    $0x1,%edx
  801269:	75 23                	jne    80128e <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80126b:	a1 08 40 80 00       	mov    0x804008,%eax
  801270:	8b 40 48             	mov    0x48(%eax),%eax
  801273:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801277:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127b:	c7 04 24 2d 24 80 00 	movl   $0x80242d,(%esp)
  801282:	e8 df ee ff ff       	call   800166 <cprintf>
		return -E_INVAL;
  801287:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128c:	eb 24                	jmp    8012b2 <read+0x8c>
	}
	if (!dev->dev_read)
  80128e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801291:	8b 52 08             	mov    0x8(%edx),%edx
  801294:	85 d2                	test   %edx,%edx
  801296:	74 15                	je     8012ad <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801298:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80129b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80129f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012a6:	89 04 24             	mov    %eax,(%esp)
  8012a9:	ff d2                	call   *%edx
  8012ab:	eb 05                	jmp    8012b2 <read+0x8c>
		return -E_NOT_SUPP;
  8012ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8012b2:	83 c4 24             	add    $0x24,%esp
  8012b5:	5b                   	pop    %ebx
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    

008012b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	57                   	push   %edi
  8012bc:	56                   	push   %esi
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 1c             	sub    $0x1c,%esp
  8012c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012c7:	85 f6                	test   %esi,%esi
  8012c9:	74 33                	je     8012fe <readn+0x46>
  8012cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d0:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012d5:	89 f2                	mov    %esi,%edx
  8012d7:	29 c2                	sub    %eax,%edx
  8012d9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012dd:	03 45 0c             	add    0xc(%ebp),%eax
  8012e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e4:	89 3c 24             	mov    %edi,(%esp)
  8012e7:	e8 3a ff ff ff       	call   801226 <read>
		if (m < 0)
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 1b                	js     80130b <readn+0x53>
			return m;
		if (m == 0)
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	74 11                	je     801305 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  8012f4:	01 c3                	add    %eax,%ebx
  8012f6:	89 d8                	mov    %ebx,%eax
  8012f8:	39 f3                	cmp    %esi,%ebx
  8012fa:	72 d9                	jb     8012d5 <readn+0x1d>
  8012fc:	eb 0b                	jmp    801309 <readn+0x51>
  8012fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801303:	eb 06                	jmp    80130b <readn+0x53>
  801305:	89 d8                	mov    %ebx,%eax
  801307:	eb 02                	jmp    80130b <readn+0x53>
  801309:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80130b:	83 c4 1c             	add    $0x1c,%esp
  80130e:	5b                   	pop    %ebx
  80130f:	5e                   	pop    %esi
  801310:	5f                   	pop    %edi
  801311:	5d                   	pop    %ebp
  801312:	c3                   	ret    

00801313 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	53                   	push   %ebx
  801317:	83 ec 24             	sub    $0x24,%esp
  80131a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80131d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801320:	89 44 24 04          	mov    %eax,0x4(%esp)
  801324:	89 1c 24             	mov    %ebx,(%esp)
  801327:	e8 4f fc ff ff       	call   800f7b <fd_lookup>
  80132c:	89 c2                	mov    %eax,%edx
  80132e:	85 d2                	test   %edx,%edx
  801330:	78 68                	js     80139a <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801332:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801335:	89 44 24 04          	mov    %eax,0x4(%esp)
  801339:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133c:	8b 00                	mov    (%eax),%eax
  80133e:	89 04 24             	mov    %eax,(%esp)
  801341:	e8 8b fc ff ff       	call   800fd1 <dev_lookup>
  801346:	85 c0                	test   %eax,%eax
  801348:	78 50                	js     80139a <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80134a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801351:	75 23                	jne    801376 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801353:	a1 08 40 80 00       	mov    0x804008,%eax
  801358:	8b 40 48             	mov    0x48(%eax),%eax
  80135b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80135f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801363:	c7 04 24 49 24 80 00 	movl   $0x802449,(%esp)
  80136a:	e8 f7 ed ff ff       	call   800166 <cprintf>
		return -E_INVAL;
  80136f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801374:	eb 24                	jmp    80139a <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801376:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801379:	8b 52 0c             	mov    0xc(%edx),%edx
  80137c:	85 d2                	test   %edx,%edx
  80137e:	74 15                	je     801395 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801380:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801383:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801387:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80138e:	89 04 24             	mov    %eax,(%esp)
  801391:	ff d2                	call   *%edx
  801393:	eb 05                	jmp    80139a <write+0x87>
		return -E_NOT_SUPP;
  801395:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80139a:	83 c4 24             	add    $0x24,%esp
  80139d:	5b                   	pop    %ebx
  80139e:	5d                   	pop    %ebp
  80139f:	c3                   	ret    

008013a0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b0:	89 04 24             	mov    %eax,(%esp)
  8013b3:	e8 c3 fb ff ff       	call   800f7b <fd_lookup>
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 0e                	js     8013ca <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ca:	c9                   	leave  
  8013cb:	c3                   	ret    

008013cc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	53                   	push   %ebx
  8013d0:	83 ec 24             	sub    $0x24,%esp
  8013d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013dd:	89 1c 24             	mov    %ebx,(%esp)
  8013e0:	e8 96 fb ff ff       	call   800f7b <fd_lookup>
  8013e5:	89 c2                	mov    %eax,%edx
  8013e7:	85 d2                	test   %edx,%edx
  8013e9:	78 61                	js     80144c <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f5:	8b 00                	mov    (%eax),%eax
  8013f7:	89 04 24             	mov    %eax,(%esp)
  8013fa:	e8 d2 fb ff ff       	call   800fd1 <dev_lookup>
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 49                	js     80144c <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801403:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801406:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80140a:	75 23                	jne    80142f <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80140c:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801411:	8b 40 48             	mov    0x48(%eax),%eax
  801414:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801418:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141c:	c7 04 24 0c 24 80 00 	movl   $0x80240c,(%esp)
  801423:	e8 3e ed ff ff       	call   800166 <cprintf>
		return -E_INVAL;
  801428:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80142d:	eb 1d                	jmp    80144c <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80142f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801432:	8b 52 18             	mov    0x18(%edx),%edx
  801435:	85 d2                	test   %edx,%edx
  801437:	74 0e                	je     801447 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801439:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80143c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801440:	89 04 24             	mov    %eax,(%esp)
  801443:	ff d2                	call   *%edx
  801445:	eb 05                	jmp    80144c <ftruncate+0x80>
		return -E_NOT_SUPP;
  801447:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80144c:	83 c4 24             	add    $0x24,%esp
  80144f:	5b                   	pop    %ebx
  801450:	5d                   	pop    %ebp
  801451:	c3                   	ret    

00801452 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	53                   	push   %ebx
  801456:	83 ec 24             	sub    $0x24,%esp
  801459:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801463:	8b 45 08             	mov    0x8(%ebp),%eax
  801466:	89 04 24             	mov    %eax,(%esp)
  801469:	e8 0d fb ff ff       	call   800f7b <fd_lookup>
  80146e:	89 c2                	mov    %eax,%edx
  801470:	85 d2                	test   %edx,%edx
  801472:	78 52                	js     8014c6 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801477:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147e:	8b 00                	mov    (%eax),%eax
  801480:	89 04 24             	mov    %eax,(%esp)
  801483:	e8 49 fb ff ff       	call   800fd1 <dev_lookup>
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 3a                	js     8014c6 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80148c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801493:	74 2c                	je     8014c1 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801495:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801498:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80149f:	00 00 00 
	stat->st_isdir = 0;
  8014a2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014a9:	00 00 00 
	stat->st_dev = dev;
  8014ac:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014b9:	89 14 24             	mov    %edx,(%esp)
  8014bc:	ff 50 14             	call   *0x14(%eax)
  8014bf:	eb 05                	jmp    8014c6 <fstat+0x74>
		return -E_NOT_SUPP;
  8014c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8014c6:	83 c4 24             	add    $0x24,%esp
  8014c9:	5b                   	pop    %ebx
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	56                   	push   %esi
  8014d0:	53                   	push   %ebx
  8014d1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014db:	00 
  8014dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014df:	89 04 24             	mov    %eax,(%esp)
  8014e2:	e8 af 01 00 00       	call   801696 <open>
  8014e7:	89 c3                	mov    %eax,%ebx
  8014e9:	85 db                	test   %ebx,%ebx
  8014eb:	78 1b                	js     801508 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f4:	89 1c 24             	mov    %ebx,(%esp)
  8014f7:	e8 56 ff ff ff       	call   801452 <fstat>
  8014fc:	89 c6                	mov    %eax,%esi
	close(fd);
  8014fe:	89 1c 24             	mov    %ebx,(%esp)
  801501:	e8 bd fb ff ff       	call   8010c3 <close>
	return r;
  801506:	89 f0                	mov    %esi,%eax
}
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	5b                   	pop    %ebx
  80150c:	5e                   	pop    %esi
  80150d:	5d                   	pop    %ebp
  80150e:	c3                   	ret    

0080150f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	56                   	push   %esi
  801513:	53                   	push   %ebx
  801514:	83 ec 10             	sub    $0x10,%esp
  801517:	89 c6                	mov    %eax,%esi
  801519:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80151b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801522:	75 11                	jne    801535 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801524:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80152b:	e8 50 08 00 00       	call   801d80 <ipc_find_env>
  801530:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801535:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80153c:	00 
  80153d:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801544:	00 
  801545:	89 74 24 04          	mov    %esi,0x4(%esp)
  801549:	a1 00 40 80 00       	mov    0x804000,%eax
  80154e:	89 04 24             	mov    %eax,(%esp)
  801551:	e8 e2 07 00 00       	call   801d38 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801556:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80155d:	00 
  80155e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801562:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801569:	e8 6e 07 00 00       	call   801cdc <ipc_recv>
}
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	5b                   	pop    %ebx
  801572:	5e                   	pop    %esi
  801573:	5d                   	pop    %ebp
  801574:	c3                   	ret    

00801575 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	53                   	push   %ebx
  801579:	83 ec 14             	sub    $0x14,%esp
  80157c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80157f:	8b 45 08             	mov    0x8(%ebp),%eax
  801582:	8b 40 0c             	mov    0xc(%eax),%eax
  801585:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80158a:	ba 00 00 00 00       	mov    $0x0,%edx
  80158f:	b8 05 00 00 00       	mov    $0x5,%eax
  801594:	e8 76 ff ff ff       	call   80150f <fsipc>
  801599:	89 c2                	mov    %eax,%edx
  80159b:	85 d2                	test   %edx,%edx
  80159d:	78 2b                	js     8015ca <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80159f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015a6:	00 
  8015a7:	89 1c 24             	mov    %ebx,(%esp)
  8015aa:	e8 0c f2 ff ff       	call   8007bb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015af:	a1 80 50 80 00       	mov    0x805080,%eax
  8015b4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015ba:	a1 84 50 80 00       	mov    0x805084,%eax
  8015bf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ca:	83 c4 14             	add    $0x14,%esp
  8015cd:	5b                   	pop    %ebx
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <devfile_flush>:
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8015dc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8015eb:	e8 1f ff ff ff       	call   80150f <fsipc>
}
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    

008015f2 <devfile_read>:
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	56                   	push   %esi
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 10             	sub    $0x10,%esp
  8015fa:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801600:	8b 40 0c             	mov    0xc(%eax),%eax
  801603:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801608:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80160e:	ba 00 00 00 00       	mov    $0x0,%edx
  801613:	b8 03 00 00 00       	mov    $0x3,%eax
  801618:	e8 f2 fe ff ff       	call   80150f <fsipc>
  80161d:	89 c3                	mov    %eax,%ebx
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 6a                	js     80168d <devfile_read+0x9b>
	assert(r <= n);
  801623:	39 c6                	cmp    %eax,%esi
  801625:	73 24                	jae    80164b <devfile_read+0x59>
  801627:	c7 44 24 0c 66 24 80 	movl   $0x802466,0xc(%esp)
  80162e:	00 
  80162f:	c7 44 24 08 6d 24 80 	movl   $0x80246d,0x8(%esp)
  801636:	00 
  801637:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80163e:	00 
  80163f:	c7 04 24 82 24 80 00 	movl   $0x802482,(%esp)
  801646:	e8 3b 06 00 00       	call   801c86 <_panic>
	assert(r <= PGSIZE);
  80164b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801650:	7e 24                	jle    801676 <devfile_read+0x84>
  801652:	c7 44 24 0c 8d 24 80 	movl   $0x80248d,0xc(%esp)
  801659:	00 
  80165a:	c7 44 24 08 6d 24 80 	movl   $0x80246d,0x8(%esp)
  801661:	00 
  801662:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801669:	00 
  80166a:	c7 04 24 82 24 80 00 	movl   $0x802482,(%esp)
  801671:	e8 10 06 00 00       	call   801c86 <_panic>
	memmove(buf, &fsipcbuf, r);
  801676:	89 44 24 08          	mov    %eax,0x8(%esp)
  80167a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801681:	00 
  801682:	8b 45 0c             	mov    0xc(%ebp),%eax
  801685:	89 04 24             	mov    %eax,(%esp)
  801688:	e8 29 f3 ff ff       	call   8009b6 <memmove>
}
  80168d:	89 d8                	mov    %ebx,%eax
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	5b                   	pop    %ebx
  801693:	5e                   	pop    %esi
  801694:	5d                   	pop    %ebp
  801695:	c3                   	ret    

00801696 <open>:
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	53                   	push   %ebx
  80169a:	83 ec 24             	sub    $0x24,%esp
  80169d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8016a0:	89 1c 24             	mov    %ebx,(%esp)
  8016a3:	e8 b8 f0 ff ff       	call   800760 <strlen>
  8016a8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016ad:	7f 60                	jg     80170f <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  8016af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b2:	89 04 24             	mov    %eax,(%esp)
  8016b5:	e8 4d f8 ff ff       	call   800f07 <fd_alloc>
  8016ba:	89 c2                	mov    %eax,%edx
  8016bc:	85 d2                	test   %edx,%edx
  8016be:	78 54                	js     801714 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  8016c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016c4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8016cb:	e8 eb f0 ff ff       	call   8007bb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016db:	b8 01 00 00 00       	mov    $0x1,%eax
  8016e0:	e8 2a fe ff ff       	call   80150f <fsipc>
  8016e5:	89 c3                	mov    %eax,%ebx
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	79 17                	jns    801702 <open+0x6c>
		fd_close(fd, 0);
  8016eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016f2:	00 
  8016f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f6:	89 04 24             	mov    %eax,(%esp)
  8016f9:	e8 44 f9 ff ff       	call   801042 <fd_close>
		return r;
  8016fe:	89 d8                	mov    %ebx,%eax
  801700:	eb 12                	jmp    801714 <open+0x7e>
	return fd2num(fd);
  801702:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801705:	89 04 24             	mov    %eax,(%esp)
  801708:	e8 d3 f7 ff ff       	call   800ee0 <fd2num>
  80170d:	eb 05                	jmp    801714 <open+0x7e>
		return -E_BAD_PATH;
  80170f:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801714:	83 c4 24             	add    $0x24,%esp
  801717:	5b                   	pop    %ebx
  801718:	5d                   	pop    %ebp
  801719:	c3                   	ret    
  80171a:	66 90                	xchg   %ax,%ax
  80171c:	66 90                	xchg   %ax,%ax
  80171e:	66 90                	xchg   %ax,%ax

00801720 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	56                   	push   %esi
  801724:	53                   	push   %ebx
  801725:	83 ec 10             	sub    $0x10,%esp
  801728:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80172b:	8b 45 08             	mov    0x8(%ebp),%eax
  80172e:	89 04 24             	mov    %eax,(%esp)
  801731:	e8 ba f7 ff ff       	call   800ef0 <fd2data>
  801736:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801738:	c7 44 24 04 99 24 80 	movl   $0x802499,0x4(%esp)
  80173f:	00 
  801740:	89 1c 24             	mov    %ebx,(%esp)
  801743:	e8 73 f0 ff ff       	call   8007bb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801748:	8b 46 04             	mov    0x4(%esi),%eax
  80174b:	2b 06                	sub    (%esi),%eax
  80174d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801753:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80175a:	00 00 00 
	stat->st_dev = &devpipe;
  80175d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801764:	30 80 00 
	return 0;
}
  801767:	b8 00 00 00 00       	mov    $0x0,%eax
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	5b                   	pop    %ebx
  801770:	5e                   	pop    %esi
  801771:	5d                   	pop    %ebp
  801772:	c3                   	ret    

00801773 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	53                   	push   %ebx
  801777:	83 ec 14             	sub    $0x14,%esp
  80177a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80177d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801781:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801788:	e8 83 f5 ff ff       	call   800d10 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80178d:	89 1c 24             	mov    %ebx,(%esp)
  801790:	e8 5b f7 ff ff       	call   800ef0 <fd2data>
  801795:	89 44 24 04          	mov    %eax,0x4(%esp)
  801799:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a0:	e8 6b f5 ff ff       	call   800d10 <sys_page_unmap>
}
  8017a5:	83 c4 14             	add    $0x14,%esp
  8017a8:	5b                   	pop    %ebx
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    

008017ab <_pipeisclosed>:
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	57                   	push   %edi
  8017af:	56                   	push   %esi
  8017b0:	53                   	push   %ebx
  8017b1:	83 ec 2c             	sub    $0x2c,%esp
  8017b4:	89 c6                	mov    %eax,%esi
  8017b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  8017b9:	a1 08 40 80 00       	mov    0x804008,%eax
  8017be:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017c1:	89 34 24             	mov    %esi,(%esp)
  8017c4:	e8 ff 05 00 00       	call   801dc8 <pageref>
  8017c9:	89 c7                	mov    %eax,%edi
  8017cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017ce:	89 04 24             	mov    %eax,(%esp)
  8017d1:	e8 f2 05 00 00       	call   801dc8 <pageref>
  8017d6:	39 c7                	cmp    %eax,%edi
  8017d8:	0f 94 c2             	sete   %dl
  8017db:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8017de:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  8017e4:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8017e7:	39 fb                	cmp    %edi,%ebx
  8017e9:	74 21                	je     80180c <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  8017eb:	84 d2                	test   %dl,%dl
  8017ed:	74 ca                	je     8017b9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017ef:	8b 51 58             	mov    0x58(%ecx),%edx
  8017f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017f6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017fe:	c7 04 24 a0 24 80 00 	movl   $0x8024a0,(%esp)
  801805:	e8 5c e9 ff ff       	call   800166 <cprintf>
  80180a:	eb ad                	jmp    8017b9 <_pipeisclosed+0xe>
}
  80180c:	83 c4 2c             	add    $0x2c,%esp
  80180f:	5b                   	pop    %ebx
  801810:	5e                   	pop    %esi
  801811:	5f                   	pop    %edi
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <devpipe_write>:
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	57                   	push   %edi
  801818:	56                   	push   %esi
  801819:	53                   	push   %ebx
  80181a:	83 ec 1c             	sub    $0x1c,%esp
  80181d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801820:	89 34 24             	mov    %esi,(%esp)
  801823:	e8 c8 f6 ff ff       	call   800ef0 <fd2data>
	for (i = 0; i < n; i++) {
  801828:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80182c:	74 61                	je     80188f <devpipe_write+0x7b>
  80182e:	89 c3                	mov    %eax,%ebx
  801830:	bf 00 00 00 00       	mov    $0x0,%edi
  801835:	eb 4a                	jmp    801881 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  801837:	89 da                	mov    %ebx,%edx
  801839:	89 f0                	mov    %esi,%eax
  80183b:	e8 6b ff ff ff       	call   8017ab <_pipeisclosed>
  801840:	85 c0                	test   %eax,%eax
  801842:	75 54                	jne    801898 <devpipe_write+0x84>
			sys_yield();
  801844:	e8 01 f4 ff ff       	call   800c4a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801849:	8b 43 04             	mov    0x4(%ebx),%eax
  80184c:	8b 0b                	mov    (%ebx),%ecx
  80184e:	8d 51 20             	lea    0x20(%ecx),%edx
  801851:	39 d0                	cmp    %edx,%eax
  801853:	73 e2                	jae    801837 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801855:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801858:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80185c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80185f:	99                   	cltd   
  801860:	c1 ea 1b             	shr    $0x1b,%edx
  801863:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801866:	83 e1 1f             	and    $0x1f,%ecx
  801869:	29 d1                	sub    %edx,%ecx
  80186b:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80186f:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801873:	83 c0 01             	add    $0x1,%eax
  801876:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801879:	83 c7 01             	add    $0x1,%edi
  80187c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80187f:	74 13                	je     801894 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801881:	8b 43 04             	mov    0x4(%ebx),%eax
  801884:	8b 0b                	mov    (%ebx),%ecx
  801886:	8d 51 20             	lea    0x20(%ecx),%edx
  801889:	39 d0                	cmp    %edx,%eax
  80188b:	73 aa                	jae    801837 <devpipe_write+0x23>
  80188d:	eb c6                	jmp    801855 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  80188f:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  801894:	89 f8                	mov    %edi,%eax
  801896:	eb 05                	jmp    80189d <devpipe_write+0x89>
				return 0;
  801898:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80189d:	83 c4 1c             	add    $0x1c,%esp
  8018a0:	5b                   	pop    %ebx
  8018a1:	5e                   	pop    %esi
  8018a2:	5f                   	pop    %edi
  8018a3:	5d                   	pop    %ebp
  8018a4:	c3                   	ret    

008018a5 <devpipe_read>:
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	57                   	push   %edi
  8018a9:	56                   	push   %esi
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 1c             	sub    $0x1c,%esp
  8018ae:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8018b1:	89 3c 24             	mov    %edi,(%esp)
  8018b4:	e8 37 f6 ff ff       	call   800ef0 <fd2data>
	for (i = 0; i < n; i++) {
  8018b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018bd:	74 54                	je     801913 <devpipe_read+0x6e>
  8018bf:	89 c3                	mov    %eax,%ebx
  8018c1:	be 00 00 00 00       	mov    $0x0,%esi
  8018c6:	eb 3e                	jmp    801906 <devpipe_read+0x61>
				return i;
  8018c8:	89 f0                	mov    %esi,%eax
  8018ca:	eb 55                	jmp    801921 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  8018cc:	89 da                	mov    %ebx,%edx
  8018ce:	89 f8                	mov    %edi,%eax
  8018d0:	e8 d6 fe ff ff       	call   8017ab <_pipeisclosed>
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	75 43                	jne    80191c <devpipe_read+0x77>
			sys_yield();
  8018d9:	e8 6c f3 ff ff       	call   800c4a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8018de:	8b 03                	mov    (%ebx),%eax
  8018e0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018e3:	74 e7                	je     8018cc <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018e5:	99                   	cltd   
  8018e6:	c1 ea 1b             	shr    $0x1b,%edx
  8018e9:	01 d0                	add    %edx,%eax
  8018eb:	83 e0 1f             	and    $0x1f,%eax
  8018ee:	29 d0                	sub    %edx,%eax
  8018f0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8018f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018f8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8018fb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8018fe:	83 c6 01             	add    $0x1,%esi
  801901:	3b 75 10             	cmp    0x10(%ebp),%esi
  801904:	74 12                	je     801918 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  801906:	8b 03                	mov    (%ebx),%eax
  801908:	3b 43 04             	cmp    0x4(%ebx),%eax
  80190b:	75 d8                	jne    8018e5 <devpipe_read+0x40>
			if (i > 0)
  80190d:	85 f6                	test   %esi,%esi
  80190f:	75 b7                	jne    8018c8 <devpipe_read+0x23>
  801911:	eb b9                	jmp    8018cc <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  801913:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  801918:	89 f0                	mov    %esi,%eax
  80191a:	eb 05                	jmp    801921 <devpipe_read+0x7c>
				return 0;
  80191c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801921:	83 c4 1c             	add    $0x1c,%esp
  801924:	5b                   	pop    %ebx
  801925:	5e                   	pop    %esi
  801926:	5f                   	pop    %edi
  801927:	5d                   	pop    %ebp
  801928:	c3                   	ret    

00801929 <pipe>:
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	56                   	push   %esi
  80192d:	53                   	push   %ebx
  80192e:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801931:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801934:	89 04 24             	mov    %eax,(%esp)
  801937:	e8 cb f5 ff ff       	call   800f07 <fd_alloc>
  80193c:	89 c2                	mov    %eax,%edx
  80193e:	85 d2                	test   %edx,%edx
  801940:	0f 88 4d 01 00 00    	js     801a93 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801946:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80194d:	00 
  80194e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801951:	89 44 24 04          	mov    %eax,0x4(%esp)
  801955:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80195c:	e8 08 f3 ff ff       	call   800c69 <sys_page_alloc>
  801961:	89 c2                	mov    %eax,%edx
  801963:	85 d2                	test   %edx,%edx
  801965:	0f 88 28 01 00 00    	js     801a93 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  80196b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80196e:	89 04 24             	mov    %eax,(%esp)
  801971:	e8 91 f5 ff ff       	call   800f07 <fd_alloc>
  801976:	89 c3                	mov    %eax,%ebx
  801978:	85 c0                	test   %eax,%eax
  80197a:	0f 88 fe 00 00 00    	js     801a7e <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801980:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801987:	00 
  801988:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801996:	e8 ce f2 ff ff       	call   800c69 <sys_page_alloc>
  80199b:	89 c3                	mov    %eax,%ebx
  80199d:	85 c0                	test   %eax,%eax
  80199f:	0f 88 d9 00 00 00    	js     801a7e <pipe+0x155>
	va = fd2data(fd0);
  8019a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a8:	89 04 24             	mov    %eax,(%esp)
  8019ab:	e8 40 f5 ff ff       	call   800ef0 <fd2data>
  8019b0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019b2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019b9:	00 
  8019ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c5:	e8 9f f2 ff ff       	call   800c69 <sys_page_alloc>
  8019ca:	89 c3                	mov    %eax,%ebx
  8019cc:	85 c0                	test   %eax,%eax
  8019ce:	0f 88 97 00 00 00    	js     801a6b <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d7:	89 04 24             	mov    %eax,(%esp)
  8019da:	e8 11 f5 ff ff       	call   800ef0 <fd2data>
  8019df:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8019e6:	00 
  8019e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019f2:	00 
  8019f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019fe:	e8 ba f2 ff ff       	call   800cbd <sys_page_map>
  801a03:	89 c3                	mov    %eax,%ebx
  801a05:	85 c0                	test   %eax,%eax
  801a07:	78 52                	js     801a5b <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801a09:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a12:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a17:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801a1e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a27:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a2c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a36:	89 04 24             	mov    %eax,(%esp)
  801a39:	e8 a2 f4 ff ff       	call   800ee0 <fd2num>
  801a3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a41:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a46:	89 04 24             	mov    %eax,(%esp)
  801a49:	e8 92 f4 ff ff       	call   800ee0 <fd2num>
  801a4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a51:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a54:	b8 00 00 00 00       	mov    $0x0,%eax
  801a59:	eb 38                	jmp    801a93 <pipe+0x16a>
	sys_page_unmap(0, va);
  801a5b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a66:	e8 a5 f2 ff ff       	call   800d10 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a79:	e8 92 f2 ff ff       	call   800d10 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a81:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a8c:	e8 7f f2 ff ff       	call   800d10 <sys_page_unmap>
  801a91:	89 d8                	mov    %ebx,%eax
}
  801a93:	83 c4 30             	add    $0x30,%esp
  801a96:	5b                   	pop    %ebx
  801a97:	5e                   	pop    %esi
  801a98:	5d                   	pop    %ebp
  801a99:	c3                   	ret    

00801a9a <pipeisclosed>:
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aa0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaa:	89 04 24             	mov    %eax,(%esp)
  801aad:	e8 c9 f4 ff ff       	call   800f7b <fd_lookup>
  801ab2:	89 c2                	mov    %eax,%edx
  801ab4:	85 d2                	test   %edx,%edx
  801ab6:	78 15                	js     801acd <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abb:	89 04 24             	mov    %eax,(%esp)
  801abe:	e8 2d f4 ff ff       	call   800ef0 <fd2data>
	return _pipeisclosed(fd, p);
  801ac3:	89 c2                	mov    %eax,%edx
  801ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac8:	e8 de fc ff ff       	call   8017ab <_pipeisclosed>
}
  801acd:	c9                   	leave  
  801ace:	c3                   	ret    
  801acf:	90                   	nop

00801ad0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ad3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801ae0:	c7 44 24 04 b8 24 80 	movl   $0x8024b8,0x4(%esp)
  801ae7:	00 
  801ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aeb:	89 04 24             	mov    %eax,(%esp)
  801aee:	e8 c8 ec ff ff       	call   8007bb <strcpy>
	return 0;
}
  801af3:	b8 00 00 00 00       	mov    $0x0,%eax
  801af8:	c9                   	leave  
  801af9:	c3                   	ret    

00801afa <devcons_write>:
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	57                   	push   %edi
  801afe:	56                   	push   %esi
  801aff:	53                   	push   %ebx
  801b00:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801b06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b0a:	74 4a                	je     801b56 <devcons_write+0x5c>
  801b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b11:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b16:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  801b1c:	8b 75 10             	mov    0x10(%ebp),%esi
  801b1f:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  801b21:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801b24:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b29:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b2c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801b30:	03 45 0c             	add    0xc(%ebp),%eax
  801b33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b37:	89 3c 24             	mov    %edi,(%esp)
  801b3a:	e8 77 ee ff ff       	call   8009b6 <memmove>
		sys_cputs(buf, m);
  801b3f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b43:	89 3c 24             	mov    %edi,(%esp)
  801b46:	e8 51 f0 ff ff       	call   800b9c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801b4b:	01 f3                	add    %esi,%ebx
  801b4d:	89 d8                	mov    %ebx,%eax
  801b4f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b52:	72 c8                	jb     801b1c <devcons_write+0x22>
  801b54:	eb 05                	jmp    801b5b <devcons_write+0x61>
  801b56:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  801b5b:	89 d8                	mov    %ebx,%eax
  801b5d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5e                   	pop    %esi
  801b65:	5f                   	pop    %edi
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    

00801b68 <devcons_read>:
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801b6e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801b73:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b77:	75 07                	jne    801b80 <devcons_read+0x18>
  801b79:	eb 28                	jmp    801ba3 <devcons_read+0x3b>
		sys_yield();
  801b7b:	e8 ca f0 ff ff       	call   800c4a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801b80:	e8 35 f0 ff ff       	call   800bba <sys_cgetc>
  801b85:	85 c0                	test   %eax,%eax
  801b87:	74 f2                	je     801b7b <devcons_read+0x13>
	if (c < 0)
  801b89:	85 c0                	test   %eax,%eax
  801b8b:	78 16                	js     801ba3 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  801b8d:	83 f8 04             	cmp    $0x4,%eax
  801b90:	74 0c                	je     801b9e <devcons_read+0x36>
	*(char*)vbuf = c;
  801b92:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b95:	88 02                	mov    %al,(%edx)
	return 1;
  801b97:	b8 01 00 00 00       	mov    $0x1,%eax
  801b9c:	eb 05                	jmp    801ba3 <devcons_read+0x3b>
		return 0;
  801b9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ba3:	c9                   	leave  
  801ba4:	c3                   	ret    

00801ba5 <cputchar>:
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801bab:	8b 45 08             	mov    0x8(%ebp),%eax
  801bae:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801bb1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bb8:	00 
  801bb9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bbc:	89 04 24             	mov    %eax,(%esp)
  801bbf:	e8 d8 ef ff ff       	call   800b9c <sys_cputs>
}
  801bc4:	c9                   	leave  
  801bc5:	c3                   	ret    

00801bc6 <getchar>:
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801bcc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801bd3:	00 
  801bd4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be2:	e8 3f f6 ff ff       	call   801226 <read>
	if (r < 0)
  801be7:	85 c0                	test   %eax,%eax
  801be9:	78 0f                	js     801bfa <getchar+0x34>
	if (r < 1)
  801beb:	85 c0                	test   %eax,%eax
  801bed:	7e 06                	jle    801bf5 <getchar+0x2f>
	return c;
  801bef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bf3:	eb 05                	jmp    801bfa <getchar+0x34>
		return -E_EOF;
  801bf5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <iscons>:
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c09:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0c:	89 04 24             	mov    %eax,(%esp)
  801c0f:	e8 67 f3 ff ff       	call   800f7b <fd_lookup>
  801c14:	85 c0                	test   %eax,%eax
  801c16:	78 11                	js     801c29 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c21:	39 10                	cmp    %edx,(%eax)
  801c23:	0f 94 c0             	sete   %al
  801c26:	0f b6 c0             	movzbl %al,%eax
}
  801c29:	c9                   	leave  
  801c2a:	c3                   	ret    

00801c2b <opencons>:
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801c31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c34:	89 04 24             	mov    %eax,(%esp)
  801c37:	e8 cb f2 ff ff       	call   800f07 <fd_alloc>
		return r;
  801c3c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	78 40                	js     801c82 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c42:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c49:	00 
  801c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c58:	e8 0c f0 ff ff       	call   800c69 <sys_page_alloc>
		return r;
  801c5d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	78 1f                	js     801c82 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801c63:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c71:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c78:	89 04 24             	mov    %eax,(%esp)
  801c7b:	e8 60 f2 ff ff       	call   800ee0 <fd2num>
  801c80:	89 c2                	mov    %eax,%edx
}
  801c82:	89 d0                	mov    %edx,%eax
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	56                   	push   %esi
  801c8a:	53                   	push   %ebx
  801c8b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801c8e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c91:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801c97:	e8 8f ef ff ff       	call   800c2b <sys_getenvid>
  801c9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c9f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  801ca6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801caa:	89 74 24 08          	mov    %esi,0x8(%esp)
  801cae:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb2:	c7 04 24 c4 24 80 00 	movl   $0x8024c4,(%esp)
  801cb9:	e8 a8 e4 ff ff       	call   800166 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801cbe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cc2:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc5:	89 04 24             	mov    %eax,(%esp)
  801cc8:	e8 38 e4 ff ff       	call   800105 <vcprintf>
	cprintf("\n");
  801ccd:	c7 04 24 ac 20 80 00 	movl   $0x8020ac,(%esp)
  801cd4:	e8 8d e4 ff ff       	call   800166 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801cd9:	cc                   	int3   
  801cda:	eb fd                	jmp    801cd9 <_panic+0x53>

00801cdc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	56                   	push   %esi
  801ce0:	53                   	push   %ebx
  801ce1:	83 ec 10             	sub    $0x10,%esp
  801ce4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ce7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  801cea:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ced:	89 04 24             	mov    %eax,(%esp)
  801cf0:	e8 8a f1 ff ff       	call   800e7f <sys_ipc_recv>
	if(from_env_store)
  801cf5:	85 f6                	test   %esi,%esi
  801cf7:	74 14                	je     801d0d <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  801cf9:	ba 00 00 00 00       	mov    $0x0,%edx
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	78 09                	js     801d0b <ipc_recv+0x2f>
  801d02:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d08:	8b 52 74             	mov    0x74(%edx),%edx
  801d0b:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  801d0d:	85 db                	test   %ebx,%ebx
  801d0f:	74 14                	je     801d25 <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  801d11:	ba 00 00 00 00       	mov    $0x0,%edx
  801d16:	85 c0                	test   %eax,%eax
  801d18:	78 09                	js     801d23 <ipc_recv+0x47>
  801d1a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d20:	8b 52 78             	mov    0x78(%edx),%edx
  801d23:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  801d25:	85 c0                	test   %eax,%eax
  801d27:	78 08                	js     801d31 <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  801d29:	a1 08 40 80 00       	mov    0x804008,%eax
  801d2e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    

00801d38 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	57                   	push   %edi
  801d3c:	56                   	push   %esi
  801d3d:	53                   	push   %ebx
  801d3e:	83 ec 1c             	sub    $0x1c,%esp
  801d41:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d44:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  801d47:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801d4c:	eb 0c                	jmp    801d5a <ipc_send+0x22>
		failed_cnt++;
  801d4e:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  801d51:	84 db                	test   %bl,%bl
  801d53:	75 05                	jne    801d5a <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  801d55:	e8 f0 ee ff ff       	call   800c4a <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801d5a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d61:	8b 45 10             	mov    0x10(%ebp),%eax
  801d64:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d68:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d6c:	89 3c 24             	mov    %edi,(%esp)
  801d6f:	e8 e8 f0 ff ff       	call   800e5c <sys_ipc_try_send>
  801d74:	85 c0                	test   %eax,%eax
  801d76:	78 d6                	js     801d4e <ipc_send+0x16>
	}
}
  801d78:	83 c4 1c             	add    $0x1c,%esp
  801d7b:	5b                   	pop    %ebx
  801d7c:	5e                   	pop    %esi
  801d7d:	5f                   	pop    %edi
  801d7e:	5d                   	pop    %ebp
  801d7f:	c3                   	ret    

00801d80 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d86:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801d8b:	39 c8                	cmp    %ecx,%eax
  801d8d:	74 17                	je     801da6 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  801d8f:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801d94:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d97:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d9d:	8b 52 50             	mov    0x50(%edx),%edx
  801da0:	39 ca                	cmp    %ecx,%edx
  801da2:	75 14                	jne    801db8 <ipc_find_env+0x38>
  801da4:	eb 05                	jmp    801dab <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  801da6:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  801dab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801dae:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801db3:	8b 40 40             	mov    0x40(%eax),%eax
  801db6:	eb 0e                	jmp    801dc6 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  801db8:	83 c0 01             	add    $0x1,%eax
  801dbb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dc0:	75 d2                	jne    801d94 <ipc_find_env+0x14>
	return 0;
  801dc2:	66 b8 00 00          	mov    $0x0,%ax
}
  801dc6:	5d                   	pop    %ebp
  801dc7:	c3                   	ret    

00801dc8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dce:	89 d0                	mov    %edx,%eax
  801dd0:	c1 e8 16             	shr    $0x16,%eax
  801dd3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801dda:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801ddf:	f6 c1 01             	test   $0x1,%cl
  801de2:	74 1d                	je     801e01 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801de4:	c1 ea 0c             	shr    $0xc,%edx
  801de7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dee:	f6 c2 01             	test   $0x1,%dl
  801df1:	74 0e                	je     801e01 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801df3:	c1 ea 0c             	shr    $0xc,%edx
  801df6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801dfd:	ef 
  801dfe:	0f b7 c0             	movzwl %ax,%eax
}
  801e01:	5d                   	pop    %ebp
  801e02:	c3                   	ret    
  801e03:	66 90                	xchg   %ax,%ax
  801e05:	66 90                	xchg   %ax,%ax
  801e07:	66 90                	xchg   %ax,%ax
  801e09:	66 90                	xchg   %ax,%ax
  801e0b:	66 90                	xchg   %ax,%ax
  801e0d:	66 90                	xchg   %ax,%ax
  801e0f:	90                   	nop

00801e10 <__udivdi3>:
  801e10:	55                   	push   %ebp
  801e11:	57                   	push   %edi
  801e12:	56                   	push   %esi
  801e13:	83 ec 0c             	sub    $0xc,%esp
  801e16:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e1a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801e1e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801e22:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e26:	85 c0                	test   %eax,%eax
  801e28:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e2c:	89 ea                	mov    %ebp,%edx
  801e2e:	89 0c 24             	mov    %ecx,(%esp)
  801e31:	75 2d                	jne    801e60 <__udivdi3+0x50>
  801e33:	39 e9                	cmp    %ebp,%ecx
  801e35:	77 61                	ja     801e98 <__udivdi3+0x88>
  801e37:	85 c9                	test   %ecx,%ecx
  801e39:	89 ce                	mov    %ecx,%esi
  801e3b:	75 0b                	jne    801e48 <__udivdi3+0x38>
  801e3d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e42:	31 d2                	xor    %edx,%edx
  801e44:	f7 f1                	div    %ecx
  801e46:	89 c6                	mov    %eax,%esi
  801e48:	31 d2                	xor    %edx,%edx
  801e4a:	89 e8                	mov    %ebp,%eax
  801e4c:	f7 f6                	div    %esi
  801e4e:	89 c5                	mov    %eax,%ebp
  801e50:	89 f8                	mov    %edi,%eax
  801e52:	f7 f6                	div    %esi
  801e54:	89 ea                	mov    %ebp,%edx
  801e56:	83 c4 0c             	add    $0xc,%esp
  801e59:	5e                   	pop    %esi
  801e5a:	5f                   	pop    %edi
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    
  801e5d:	8d 76 00             	lea    0x0(%esi),%esi
  801e60:	39 e8                	cmp    %ebp,%eax
  801e62:	77 24                	ja     801e88 <__udivdi3+0x78>
  801e64:	0f bd e8             	bsr    %eax,%ebp
  801e67:	83 f5 1f             	xor    $0x1f,%ebp
  801e6a:	75 3c                	jne    801ea8 <__udivdi3+0x98>
  801e6c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e70:	39 34 24             	cmp    %esi,(%esp)
  801e73:	0f 86 9f 00 00 00    	jbe    801f18 <__udivdi3+0x108>
  801e79:	39 d0                	cmp    %edx,%eax
  801e7b:	0f 82 97 00 00 00    	jb     801f18 <__udivdi3+0x108>
  801e81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e88:	31 d2                	xor    %edx,%edx
  801e8a:	31 c0                	xor    %eax,%eax
  801e8c:	83 c4 0c             	add    $0xc,%esp
  801e8f:	5e                   	pop    %esi
  801e90:	5f                   	pop    %edi
  801e91:	5d                   	pop    %ebp
  801e92:	c3                   	ret    
  801e93:	90                   	nop
  801e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e98:	89 f8                	mov    %edi,%eax
  801e9a:	f7 f1                	div    %ecx
  801e9c:	31 d2                	xor    %edx,%edx
  801e9e:	83 c4 0c             	add    $0xc,%esp
  801ea1:	5e                   	pop    %esi
  801ea2:	5f                   	pop    %edi
  801ea3:	5d                   	pop    %ebp
  801ea4:	c3                   	ret    
  801ea5:	8d 76 00             	lea    0x0(%esi),%esi
  801ea8:	89 e9                	mov    %ebp,%ecx
  801eaa:	8b 3c 24             	mov    (%esp),%edi
  801ead:	d3 e0                	shl    %cl,%eax
  801eaf:	89 c6                	mov    %eax,%esi
  801eb1:	b8 20 00 00 00       	mov    $0x20,%eax
  801eb6:	29 e8                	sub    %ebp,%eax
  801eb8:	89 c1                	mov    %eax,%ecx
  801eba:	d3 ef                	shr    %cl,%edi
  801ebc:	89 e9                	mov    %ebp,%ecx
  801ebe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801ec2:	8b 3c 24             	mov    (%esp),%edi
  801ec5:	09 74 24 08          	or     %esi,0x8(%esp)
  801ec9:	89 d6                	mov    %edx,%esi
  801ecb:	d3 e7                	shl    %cl,%edi
  801ecd:	89 c1                	mov    %eax,%ecx
  801ecf:	89 3c 24             	mov    %edi,(%esp)
  801ed2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ed6:	d3 ee                	shr    %cl,%esi
  801ed8:	89 e9                	mov    %ebp,%ecx
  801eda:	d3 e2                	shl    %cl,%edx
  801edc:	89 c1                	mov    %eax,%ecx
  801ede:	d3 ef                	shr    %cl,%edi
  801ee0:	09 d7                	or     %edx,%edi
  801ee2:	89 f2                	mov    %esi,%edx
  801ee4:	89 f8                	mov    %edi,%eax
  801ee6:	f7 74 24 08          	divl   0x8(%esp)
  801eea:	89 d6                	mov    %edx,%esi
  801eec:	89 c7                	mov    %eax,%edi
  801eee:	f7 24 24             	mull   (%esp)
  801ef1:	39 d6                	cmp    %edx,%esi
  801ef3:	89 14 24             	mov    %edx,(%esp)
  801ef6:	72 30                	jb     801f28 <__udivdi3+0x118>
  801ef8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801efc:	89 e9                	mov    %ebp,%ecx
  801efe:	d3 e2                	shl    %cl,%edx
  801f00:	39 c2                	cmp    %eax,%edx
  801f02:	73 05                	jae    801f09 <__udivdi3+0xf9>
  801f04:	3b 34 24             	cmp    (%esp),%esi
  801f07:	74 1f                	je     801f28 <__udivdi3+0x118>
  801f09:	89 f8                	mov    %edi,%eax
  801f0b:	31 d2                	xor    %edx,%edx
  801f0d:	e9 7a ff ff ff       	jmp    801e8c <__udivdi3+0x7c>
  801f12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f18:	31 d2                	xor    %edx,%edx
  801f1a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f1f:	e9 68 ff ff ff       	jmp    801e8c <__udivdi3+0x7c>
  801f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f28:	8d 47 ff             	lea    -0x1(%edi),%eax
  801f2b:	31 d2                	xor    %edx,%edx
  801f2d:	83 c4 0c             	add    $0xc,%esp
  801f30:	5e                   	pop    %esi
  801f31:	5f                   	pop    %edi
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    
  801f34:	66 90                	xchg   %ax,%ax
  801f36:	66 90                	xchg   %ax,%ax
  801f38:	66 90                	xchg   %ax,%ax
  801f3a:	66 90                	xchg   %ax,%ax
  801f3c:	66 90                	xchg   %ax,%ax
  801f3e:	66 90                	xchg   %ax,%ax

00801f40 <__umoddi3>:
  801f40:	55                   	push   %ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	83 ec 14             	sub    $0x14,%esp
  801f46:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f4a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f4e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801f52:	89 c7                	mov    %eax,%edi
  801f54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f58:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f5c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801f60:	89 34 24             	mov    %esi,(%esp)
  801f63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f67:	85 c0                	test   %eax,%eax
  801f69:	89 c2                	mov    %eax,%edx
  801f6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f6f:	75 17                	jne    801f88 <__umoddi3+0x48>
  801f71:	39 fe                	cmp    %edi,%esi
  801f73:	76 4b                	jbe    801fc0 <__umoddi3+0x80>
  801f75:	89 c8                	mov    %ecx,%eax
  801f77:	89 fa                	mov    %edi,%edx
  801f79:	f7 f6                	div    %esi
  801f7b:	89 d0                	mov    %edx,%eax
  801f7d:	31 d2                	xor    %edx,%edx
  801f7f:	83 c4 14             	add    $0x14,%esp
  801f82:	5e                   	pop    %esi
  801f83:	5f                   	pop    %edi
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    
  801f86:	66 90                	xchg   %ax,%ax
  801f88:	39 f8                	cmp    %edi,%eax
  801f8a:	77 54                	ja     801fe0 <__umoddi3+0xa0>
  801f8c:	0f bd e8             	bsr    %eax,%ebp
  801f8f:	83 f5 1f             	xor    $0x1f,%ebp
  801f92:	75 5c                	jne    801ff0 <__umoddi3+0xb0>
  801f94:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801f98:	39 3c 24             	cmp    %edi,(%esp)
  801f9b:	0f 87 e7 00 00 00    	ja     802088 <__umoddi3+0x148>
  801fa1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801fa5:	29 f1                	sub    %esi,%ecx
  801fa7:	19 c7                	sbb    %eax,%edi
  801fa9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fb1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fb5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801fb9:	83 c4 14             	add    $0x14,%esp
  801fbc:	5e                   	pop    %esi
  801fbd:	5f                   	pop    %edi
  801fbe:	5d                   	pop    %ebp
  801fbf:	c3                   	ret    
  801fc0:	85 f6                	test   %esi,%esi
  801fc2:	89 f5                	mov    %esi,%ebp
  801fc4:	75 0b                	jne    801fd1 <__umoddi3+0x91>
  801fc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fcb:	31 d2                	xor    %edx,%edx
  801fcd:	f7 f6                	div    %esi
  801fcf:	89 c5                	mov    %eax,%ebp
  801fd1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fd5:	31 d2                	xor    %edx,%edx
  801fd7:	f7 f5                	div    %ebp
  801fd9:	89 c8                	mov    %ecx,%eax
  801fdb:	f7 f5                	div    %ebp
  801fdd:	eb 9c                	jmp    801f7b <__umoddi3+0x3b>
  801fdf:	90                   	nop
  801fe0:	89 c8                	mov    %ecx,%eax
  801fe2:	89 fa                	mov    %edi,%edx
  801fe4:	83 c4 14             	add    $0x14,%esp
  801fe7:	5e                   	pop    %esi
  801fe8:	5f                   	pop    %edi
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    
  801feb:	90                   	nop
  801fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	8b 04 24             	mov    (%esp),%eax
  801ff3:	be 20 00 00 00       	mov    $0x20,%esi
  801ff8:	89 e9                	mov    %ebp,%ecx
  801ffa:	29 ee                	sub    %ebp,%esi
  801ffc:	d3 e2                	shl    %cl,%edx
  801ffe:	89 f1                	mov    %esi,%ecx
  802000:	d3 e8                	shr    %cl,%eax
  802002:	89 e9                	mov    %ebp,%ecx
  802004:	89 44 24 04          	mov    %eax,0x4(%esp)
  802008:	8b 04 24             	mov    (%esp),%eax
  80200b:	09 54 24 04          	or     %edx,0x4(%esp)
  80200f:	89 fa                	mov    %edi,%edx
  802011:	d3 e0                	shl    %cl,%eax
  802013:	89 f1                	mov    %esi,%ecx
  802015:	89 44 24 08          	mov    %eax,0x8(%esp)
  802019:	8b 44 24 10          	mov    0x10(%esp),%eax
  80201d:	d3 ea                	shr    %cl,%edx
  80201f:	89 e9                	mov    %ebp,%ecx
  802021:	d3 e7                	shl    %cl,%edi
  802023:	89 f1                	mov    %esi,%ecx
  802025:	d3 e8                	shr    %cl,%eax
  802027:	89 e9                	mov    %ebp,%ecx
  802029:	09 f8                	or     %edi,%eax
  80202b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80202f:	f7 74 24 04          	divl   0x4(%esp)
  802033:	d3 e7                	shl    %cl,%edi
  802035:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802039:	89 d7                	mov    %edx,%edi
  80203b:	f7 64 24 08          	mull   0x8(%esp)
  80203f:	39 d7                	cmp    %edx,%edi
  802041:	89 c1                	mov    %eax,%ecx
  802043:	89 14 24             	mov    %edx,(%esp)
  802046:	72 2c                	jb     802074 <__umoddi3+0x134>
  802048:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80204c:	72 22                	jb     802070 <__umoddi3+0x130>
  80204e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802052:	29 c8                	sub    %ecx,%eax
  802054:	19 d7                	sbb    %edx,%edi
  802056:	89 e9                	mov    %ebp,%ecx
  802058:	89 fa                	mov    %edi,%edx
  80205a:	d3 e8                	shr    %cl,%eax
  80205c:	89 f1                	mov    %esi,%ecx
  80205e:	d3 e2                	shl    %cl,%edx
  802060:	89 e9                	mov    %ebp,%ecx
  802062:	d3 ef                	shr    %cl,%edi
  802064:	09 d0                	or     %edx,%eax
  802066:	89 fa                	mov    %edi,%edx
  802068:	83 c4 14             	add    $0x14,%esp
  80206b:	5e                   	pop    %esi
  80206c:	5f                   	pop    %edi
  80206d:	5d                   	pop    %ebp
  80206e:	c3                   	ret    
  80206f:	90                   	nop
  802070:	39 d7                	cmp    %edx,%edi
  802072:	75 da                	jne    80204e <__umoddi3+0x10e>
  802074:	8b 14 24             	mov    (%esp),%edx
  802077:	89 c1                	mov    %eax,%ecx
  802079:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80207d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802081:	eb cb                	jmp    80204e <__umoddi3+0x10e>
  802083:	90                   	nop
  802084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802088:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80208c:	0f 82 0f ff ff ff    	jb     801fa1 <__umoddi3+0x61>
  802092:	e9 1a ff ff ff       	jmp    801fb1 <__umoddi3+0x71>
