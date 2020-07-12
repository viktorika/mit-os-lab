
obj/user/faultread.debug：     文件格式 elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	a1 00 00 00 00       	mov    0x0,%eax
  80003e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800042:	c7 04 24 a0 20 80 00 	movl   $0x8020a0,(%esp)
  800049:	e8 06 01 00 00       	call   800154 <cprintf>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80005e:	e8 b8 0b 00 00       	call   800c1b <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 db                	test   %ebx,%ebx
  800077:	7e 07                	jle    800080 <libmain+0x30>
		binaryname = argv[0];
  800079:	8b 06                	mov    (%esi),%eax
  80007b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800080:	89 74 24 04          	mov    %esi,0x4(%esp)
  800084:	89 1c 24             	mov    %ebx,(%esp)
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008c:	e8 07 00 00 00       	call   800098 <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80009e:	e8 43 10 00 00       	call   8010e6 <close_all>
	sys_env_destroy(0);
  8000a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000aa:	e8 1a 0b 00 00       	call   800bc9 <sys_env_destroy>
}
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    

008000b1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	53                   	push   %ebx
  8000b5:	83 ec 14             	sub    $0x14,%esp
  8000b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000bb:	8b 13                	mov    (%ebx),%edx
  8000bd:	8d 42 01             	lea    0x1(%edx),%eax
  8000c0:	89 03                	mov    %eax,(%ebx)
  8000c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ce:	75 19                	jne    8000e9 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000d0:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000d7:	00 
  8000d8:	8d 43 08             	lea    0x8(%ebx),%eax
  8000db:	89 04 24             	mov    %eax,(%esp)
  8000de:	e8 a9 0a 00 00       	call   800b8c <sys_cputs>
		b->idx = 0;
  8000e3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000e9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000ed:	83 c4 14             	add    $0x14,%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000fc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800103:	00 00 00 
	b.cnt = 0;
  800106:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800110:	8b 45 0c             	mov    0xc(%ebp),%eax
  800113:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800117:	8b 45 08             	mov    0x8(%ebp),%eax
  80011a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80011e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800124:	89 44 24 04          	mov    %eax,0x4(%esp)
  800128:	c7 04 24 b1 00 80 00 	movl   $0x8000b1,(%esp)
  80012f:	e8 b0 01 00 00       	call   8002e4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80013a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800144:	89 04 24             	mov    %eax,(%esp)
  800147:	e8 40 0a 00 00       	call   800b8c <sys_cputs>

	return b.cnt;
}
  80014c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	8b 45 08             	mov    0x8(%ebp),%eax
  800164:	89 04 24             	mov    %eax,(%esp)
  800167:	e8 87 ff ff ff       	call   8000f3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016c:	c9                   	leave  
  80016d:	c3                   	ret    
  80016e:	66 90                	xchg   %ax,%ax

00800170 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 3c             	sub    $0x3c,%esp
  800179:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80017c:	89 d7                	mov    %edx,%edi
  80017e:	8b 45 08             	mov    0x8(%ebp),%eax
  800181:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800184:	8b 75 0c             	mov    0xc(%ebp),%esi
  800187:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80018a:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800192:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800195:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800198:	39 f1                	cmp    %esi,%ecx
  80019a:	72 14                	jb     8001b0 <printnum+0x40>
  80019c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80019f:	76 0f                	jbe    8001b0 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a4:	8d 70 ff             	lea    -0x1(%eax),%esi
  8001a7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8001aa:	85 f6                	test   %esi,%esi
  8001ac:	7f 60                	jg     80020e <printnum+0x9e>
  8001ae:	eb 72                	jmp    800222 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001b3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001b7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8001ba:	8d 51 ff             	lea    -0x1(%ecx),%edx
  8001bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c5:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001c9:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001cd:	89 c3                	mov    %eax,%ebx
  8001cf:	89 d6                	mov    %edx,%esi
  8001d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001d4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001d7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001db:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e2:	89 04 24             	mov    %eax,(%esp)
  8001e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ec:	e8 0f 1c 00 00       	call   801e00 <__udivdi3>
  8001f1:	89 d9                	mov    %ebx,%ecx
  8001f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001f7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001fb:	89 04 24             	mov    %eax,(%esp)
  8001fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800202:	89 fa                	mov    %edi,%edx
  800204:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800207:	e8 64 ff ff ff       	call   800170 <printnum>
  80020c:	eb 14                	jmp    800222 <printnum+0xb2>
			putch(padc, putdat);
  80020e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800212:	8b 45 18             	mov    0x18(%ebp),%eax
  800215:	89 04 24             	mov    %eax,(%esp)
  800218:	ff d3                	call   *%ebx
		while (--width > 0)
  80021a:	83 ee 01             	sub    $0x1,%esi
  80021d:	75 ef                	jne    80020e <printnum+0x9e>
  80021f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800222:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800226:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80022a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80022d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800230:	89 44 24 08          	mov    %eax,0x8(%esp)
  800234:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800238:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80023b:	89 04 24             	mov    %eax,(%esp)
  80023e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800241:	89 44 24 04          	mov    %eax,0x4(%esp)
  800245:	e8 e6 1c 00 00       	call   801f30 <__umoddi3>
  80024a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80024e:	0f be 80 c8 20 80 00 	movsbl 0x8020c8(%eax),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80025b:	ff d0                	call   *%eax
}
  80025d:	83 c4 3c             	add    $0x3c,%esp
  800260:	5b                   	pop    %ebx
  800261:	5e                   	pop    %esi
  800262:	5f                   	pop    %edi
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    

00800265 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800268:	83 fa 01             	cmp    $0x1,%edx
  80026b:	7e 0e                	jle    80027b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026d:	8b 10                	mov    (%eax),%edx
  80026f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800272:	89 08                	mov    %ecx,(%eax)
  800274:	8b 02                	mov    (%edx),%eax
  800276:	8b 52 04             	mov    0x4(%edx),%edx
  800279:	eb 22                	jmp    80029d <getuint+0x38>
	else if (lflag)
  80027b:	85 d2                	test   %edx,%edx
  80027d:	74 10                	je     80028f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	8d 4a 04             	lea    0x4(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 02                	mov    (%edx),%eax
  800288:	ba 00 00 00 00       	mov    $0x0,%edx
  80028d:	eb 0e                	jmp    80029d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	8d 4a 04             	lea    0x4(%edx),%ecx
  800294:	89 08                	mov    %ecx,(%eax)
  800296:	8b 02                	mov    (%edx),%eax
  800298:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    

0080029f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a9:	8b 10                	mov    (%eax),%edx
  8002ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ae:	73 0a                	jae    8002ba <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b3:	89 08                	mov    %ecx,(%eax)
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	88 02                	mov    %al,(%edx)
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <printfmt>:
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8002c2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002da:	89 04 24             	mov    %eax,(%esp)
  8002dd:	e8 02 00 00 00       	call   8002e4 <vprintfmt>
}
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <vprintfmt>:
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	57                   	push   %edi
  8002e8:	56                   	push   %esi
  8002e9:	53                   	push   %ebx
  8002ea:	83 ec 3c             	sub    $0x3c,%esp
  8002ed:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002f3:	eb 18                	jmp    80030d <vprintfmt+0x29>
			if (ch == '\0')
  8002f5:	85 c0                	test   %eax,%eax
  8002f7:	0f 84 c3 03 00 00    	je     8006c0 <vprintfmt+0x3dc>
			putch(ch, putdat);
  8002fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800301:	89 04 24             	mov    %eax,(%esp)
  800304:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800307:	89 f3                	mov    %esi,%ebx
  800309:	eb 02                	jmp    80030d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80030b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030d:	8d 73 01             	lea    0x1(%ebx),%esi
  800310:	0f b6 03             	movzbl (%ebx),%eax
  800313:	83 f8 25             	cmp    $0x25,%eax
  800316:	75 dd                	jne    8002f5 <vprintfmt+0x11>
  800318:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80031c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800323:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80032a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800331:	ba 00 00 00 00       	mov    $0x0,%edx
  800336:	eb 1d                	jmp    800355 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800338:	89 de                	mov    %ebx,%esi
			padc = '-';
  80033a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80033e:	eb 15                	jmp    800355 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800340:	89 de                	mov    %ebx,%esi
			padc = '0';
  800342:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800346:	eb 0d                	jmp    800355 <vprintfmt+0x71>
				width = precision, precision = -1;
  800348:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80034b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8d 5e 01             	lea    0x1(%esi),%ebx
  800358:	0f b6 06             	movzbl (%esi),%eax
  80035b:	0f b6 c8             	movzbl %al,%ecx
  80035e:	83 e8 23             	sub    $0x23,%eax
  800361:	3c 55                	cmp    $0x55,%al
  800363:	0f 87 2f 03 00 00    	ja     800698 <vprintfmt+0x3b4>
  800369:	0f b6 c0             	movzbl %al,%eax
  80036c:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
				precision = precision * 10 + ch - '0';
  800373:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800376:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  800379:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80037d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800380:	83 f9 09             	cmp    $0x9,%ecx
  800383:	77 50                	ja     8003d5 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  800385:	89 de                	mov    %ebx,%esi
  800387:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  80038a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80038d:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800390:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800394:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800397:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80039a:	83 fb 09             	cmp    $0x9,%ebx
  80039d:	76 eb                	jbe    80038a <vprintfmt+0xa6>
  80039f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8003a2:	eb 33                	jmp    8003d7 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  8003a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003aa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ad:	8b 00                	mov    (%eax),%eax
  8003af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8003b4:	eb 21                	jmp    8003d7 <vprintfmt+0xf3>
  8003b6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003b9:	85 c9                	test   %ecx,%ecx
  8003bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c0:	0f 49 c1             	cmovns %ecx,%eax
  8003c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	89 de                	mov    %ebx,%esi
  8003c8:	eb 8b                	jmp    800355 <vprintfmt+0x71>
  8003ca:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8003cc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003d3:	eb 80                	jmp    800355 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	89 de                	mov    %ebx,%esi
			if (width < 0)
  8003d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003db:	0f 89 74 ff ff ff    	jns    800355 <vprintfmt+0x71>
  8003e1:	e9 62 ff ff ff       	jmp    800348 <vprintfmt+0x64>
			lflag++;
  8003e6:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	89 de                	mov    %ebx,%esi
			goto reswitch;
  8003eb:	e9 65 ff ff ff       	jmp    800355 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 50 04             	lea    0x4(%eax),%edx
  8003f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003fd:	8b 00                	mov    (%eax),%eax
  8003ff:	89 04 24             	mov    %eax,(%esp)
  800402:	ff 55 08             	call   *0x8(%ebp)
			break;
  800405:	e9 03 ff ff ff       	jmp    80030d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 50 04             	lea    0x4(%eax),%edx
  800410:	89 55 14             	mov    %edx,0x14(%ebp)
  800413:	8b 00                	mov    (%eax),%eax
  800415:	99                   	cltd   
  800416:	31 d0                	xor    %edx,%eax
  800418:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041a:	83 f8 0f             	cmp    $0xf,%eax
  80041d:	7f 0b                	jg     80042a <vprintfmt+0x146>
  80041f:	8b 14 85 60 23 80 00 	mov    0x802360(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 20                	jne    80044a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80042a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042e:	c7 44 24 08 e0 20 80 	movl   $0x8020e0,0x8(%esp)
  800435:	00 
  800436:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	89 04 24             	mov    %eax,(%esp)
  800440:	e8 77 fe ff ff       	call   8002bc <printfmt>
  800445:	e9 c3 fe ff ff       	jmp    80030d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80044a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044e:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800455:	00 
  800456:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80045a:	8b 45 08             	mov    0x8(%ebp),%eax
  80045d:	89 04 24             	mov    %eax,(%esp)
  800460:	e8 57 fe ff ff       	call   8002bc <printfmt>
  800465:	e9 a3 fe ff ff       	jmp    80030d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80046d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80047b:	85 c0                	test   %eax,%eax
  80047d:	ba d9 20 80 00       	mov    $0x8020d9,%edx
  800482:	0f 45 d0             	cmovne %eax,%edx
  800485:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800488:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80048c:	74 04                	je     800492 <vprintfmt+0x1ae>
  80048e:	85 f6                	test   %esi,%esi
  800490:	7f 19                	jg     8004ab <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800492:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800495:	8d 70 01             	lea    0x1(%eax),%esi
  800498:	0f b6 10             	movzbl (%eax),%edx
  80049b:	0f be c2             	movsbl %dl,%eax
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	0f 85 95 00 00 00    	jne    80053b <vprintfmt+0x257>
  8004a6:	e9 85 00 00 00       	jmp    800530 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004af:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004b2:	89 04 24             	mov    %eax,(%esp)
  8004b5:	e8 b8 02 00 00       	call   800772 <strnlen>
  8004ba:	29 c6                	sub    %eax,%esi
  8004bc:	89 f0                	mov    %esi,%eax
  8004be:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8004c1:	85 f6                	test   %esi,%esi
  8004c3:	7e cd                	jle    800492 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8004c5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8004c9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004cc:	89 c3                	mov    %eax,%ebx
  8004ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d2:	89 34 24             	mov    %esi,(%esp)
  8004d5:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d8:	83 eb 01             	sub    $0x1,%ebx
  8004db:	75 f1                	jne    8004ce <vprintfmt+0x1ea>
  8004dd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004e3:	eb ad                	jmp    800492 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e9:	74 1e                	je     800509 <vprintfmt+0x225>
  8004eb:	0f be d2             	movsbl %dl,%edx
  8004ee:	83 ea 20             	sub    $0x20,%edx
  8004f1:	83 fa 5e             	cmp    $0x5e,%edx
  8004f4:	76 13                	jbe    800509 <vprintfmt+0x225>
					putch('?', putdat);
  8004f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800504:	ff 55 08             	call   *0x8(%ebp)
  800507:	eb 0d                	jmp    800516 <vprintfmt+0x232>
					putch(ch, putdat);
  800509:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80050c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800510:	89 04 24             	mov    %eax,(%esp)
  800513:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800516:	83 ef 01             	sub    $0x1,%edi
  800519:	83 c6 01             	add    $0x1,%esi
  80051c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800520:	0f be c2             	movsbl %dl,%eax
  800523:	85 c0                	test   %eax,%eax
  800525:	75 20                	jne    800547 <vprintfmt+0x263>
  800527:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80052a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80052d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800530:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800534:	7f 25                	jg     80055b <vprintfmt+0x277>
  800536:	e9 d2 fd ff ff       	jmp    80030d <vprintfmt+0x29>
  80053b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80053e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800541:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800544:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800547:	85 db                	test   %ebx,%ebx
  800549:	78 9a                	js     8004e5 <vprintfmt+0x201>
  80054b:	83 eb 01             	sub    $0x1,%ebx
  80054e:	79 95                	jns    8004e5 <vprintfmt+0x201>
  800550:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800553:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800556:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800559:	eb d5                	jmp    800530 <vprintfmt+0x24c>
  80055b:	8b 75 08             	mov    0x8(%ebp),%esi
  80055e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800561:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  800564:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800568:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80056f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800571:	83 eb 01             	sub    $0x1,%ebx
  800574:	75 ee                	jne    800564 <vprintfmt+0x280>
  800576:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800579:	e9 8f fd ff ff       	jmp    80030d <vprintfmt+0x29>
	if (lflag >= 2)
  80057e:	83 fa 01             	cmp    $0x1,%edx
  800581:	7e 16                	jle    800599 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 50 08             	lea    0x8(%eax),%edx
  800589:	89 55 14             	mov    %edx,0x14(%ebp)
  80058c:	8b 50 04             	mov    0x4(%eax),%edx
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800597:	eb 32                	jmp    8005cb <vprintfmt+0x2e7>
	else if (lflag)
  800599:	85 d2                	test   %edx,%edx
  80059b:	74 18                	je     8005b5 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 50 04             	lea    0x4(%eax),%edx
  8005a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a6:	8b 30                	mov    (%eax),%esi
  8005a8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005ab:	89 f0                	mov    %esi,%eax
  8005ad:	c1 f8 1f             	sar    $0x1f,%eax
  8005b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005b3:	eb 16                	jmp    8005cb <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 50 04             	lea    0x4(%eax),%edx
  8005bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005be:	8b 30                	mov    (%eax),%esi
  8005c0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005c3:	89 f0                	mov    %esi,%eax
  8005c5:	c1 f8 1f             	sar    $0x1f,%eax
  8005c8:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  8005cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  8005d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8005d6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005da:	0f 89 80 00 00 00    	jns    800660 <vprintfmt+0x37c>
				putch('-', putdat);
  8005e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005eb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005f4:	f7 d8                	neg    %eax
  8005f6:	83 d2 00             	adc    $0x0,%edx
  8005f9:	f7 da                	neg    %edx
			base = 10;
  8005fb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800600:	eb 5e                	jmp    800660 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800602:	8d 45 14             	lea    0x14(%ebp),%eax
  800605:	e8 5b fc ff ff       	call   800265 <getuint>
			base = 10;
  80060a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80060f:	eb 4f                	jmp    800660 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800611:	8d 45 14             	lea    0x14(%ebp),%eax
  800614:	e8 4c fc ff ff       	call   800265 <getuint>
			base = 8;
  800619:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80061e:	eb 40                	jmp    800660 <vprintfmt+0x37c>
			putch('0', putdat);
  800620:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800624:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80062b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80062e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800632:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800639:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8d 50 04             	lea    0x4(%eax),%edx
  800642:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800645:	8b 00                	mov    (%eax),%eax
  800647:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80064c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800651:	eb 0d                	jmp    800660 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 0a fc ff ff       	call   800265 <getuint>
			base = 16;
  80065b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800660:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800664:	89 74 24 10          	mov    %esi,0x10(%esp)
  800668:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80066b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80066f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800673:	89 04 24             	mov    %eax,(%esp)
  800676:	89 54 24 04          	mov    %edx,0x4(%esp)
  80067a:	89 fa                	mov    %edi,%edx
  80067c:	8b 45 08             	mov    0x8(%ebp),%eax
  80067f:	e8 ec fa ff ff       	call   800170 <printnum>
			break;
  800684:	e9 84 fc ff ff       	jmp    80030d <vprintfmt+0x29>
			putch(ch, putdat);
  800689:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068d:	89 0c 24             	mov    %ecx,(%esp)
  800690:	ff 55 08             	call   *0x8(%ebp)
			break;
  800693:	e9 75 fc ff ff       	jmp    80030d <vprintfmt+0x29>
			putch('%', putdat);
  800698:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006a3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006aa:	0f 84 5b fc ff ff    	je     80030b <vprintfmt+0x27>
  8006b0:	89 f3                	mov    %esi,%ebx
  8006b2:	83 eb 01             	sub    $0x1,%ebx
  8006b5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006b9:	75 f7                	jne    8006b2 <vprintfmt+0x3ce>
  8006bb:	e9 4d fc ff ff       	jmp    80030d <vprintfmt+0x29>
}
  8006c0:	83 c4 3c             	add    $0x3c,%esp
  8006c3:	5b                   	pop    %ebx
  8006c4:	5e                   	pop    %esi
  8006c5:	5f                   	pop    %edi
  8006c6:	5d                   	pop    %ebp
  8006c7:	c3                   	ret    

008006c8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	83 ec 28             	sub    $0x28,%esp
  8006ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006db:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	74 30                	je     800719 <vsnprintf+0x51>
  8006e9:	85 d2                	test   %edx,%edx
  8006eb:	7e 2c                	jle    800719 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800702:	c7 04 24 9f 02 80 00 	movl   $0x80029f,(%esp)
  800709:	e8 d6 fb ff ff       	call   8002e4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800711:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800714:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800717:	eb 05                	jmp    80071e <vsnprintf+0x56>
		return -E_INVAL;
  800719:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800729:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072d:	8b 45 10             	mov    0x10(%ebp),%eax
  800730:	89 44 24 08          	mov    %eax,0x8(%esp)
  800734:	8b 45 0c             	mov    0xc(%ebp),%eax
  800737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	89 04 24             	mov    %eax,(%esp)
  800741:	e8 82 ff ff ff       	call   8006c8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800746:	c9                   	leave  
  800747:	c3                   	ret    
  800748:	66 90                	xchg   %ax,%ax
  80074a:	66 90                	xchg   %ax,%ax
  80074c:	66 90                	xchg   %ax,%ax
  80074e:	66 90                	xchg   %ax,%ax

00800750 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800756:	80 3a 00             	cmpb   $0x0,(%edx)
  800759:	74 10                	je     80076b <strlen+0x1b>
  80075b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800760:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800763:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800767:	75 f7                	jne    800760 <strlen+0x10>
  800769:	eb 05                	jmp    800770 <strlen+0x20>
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	53                   	push   %ebx
  800776:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077c:	85 c9                	test   %ecx,%ecx
  80077e:	74 1c                	je     80079c <strnlen+0x2a>
  800780:	80 3b 00             	cmpb   $0x0,(%ebx)
  800783:	74 1e                	je     8007a3 <strnlen+0x31>
  800785:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80078a:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078c:	39 ca                	cmp    %ecx,%edx
  80078e:	74 18                	je     8007a8 <strnlen+0x36>
  800790:	83 c2 01             	add    $0x1,%edx
  800793:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800798:	75 f0                	jne    80078a <strnlen+0x18>
  80079a:	eb 0c                	jmp    8007a8 <strnlen+0x36>
  80079c:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a1:	eb 05                	jmp    8007a8 <strnlen+0x36>
  8007a3:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8007a8:	5b                   	pop    %ebx
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b5:	89 c2                	mov    %eax,%edx
  8007b7:	83 c2 01             	add    $0x1,%edx
  8007ba:	83 c1 01             	add    $0x1,%ecx
  8007bd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c4:	84 db                	test   %bl,%bl
  8007c6:	75 ef                	jne    8007b7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d5:	89 1c 24             	mov    %ebx,(%esp)
  8007d8:	e8 73 ff ff ff       	call   800750 <strlen>
	strcpy(dst + len, src);
  8007dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e4:	01 d8                	add    %ebx,%eax
  8007e6:	89 04 24             	mov    %eax,(%esp)
  8007e9:	e8 bd ff ff ff       	call   8007ab <strcpy>
	return dst;
}
  8007ee:	89 d8                	mov    %ebx,%eax
  8007f0:	83 c4 08             	add    $0x8,%esp
  8007f3:	5b                   	pop    %ebx
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	56                   	push   %esi
  8007fa:	53                   	push   %ebx
  8007fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800801:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800804:	85 db                	test   %ebx,%ebx
  800806:	74 17                	je     80081f <strncpy+0x29>
  800808:	01 f3                	add    %esi,%ebx
  80080a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80080c:	83 c1 01             	add    $0x1,%ecx
  80080f:	0f b6 02             	movzbl (%edx),%eax
  800812:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800815:	80 3a 01             	cmpb   $0x1,(%edx)
  800818:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80081b:	39 d9                	cmp    %ebx,%ecx
  80081d:	75 ed                	jne    80080c <strncpy+0x16>
	}
	return ret;
}
  80081f:	89 f0                	mov    %esi,%eax
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	57                   	push   %edi
  800829:	56                   	push   %esi
  80082a:	53                   	push   %ebx
  80082b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80082e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800831:	8b 75 10             	mov    0x10(%ebp),%esi
  800834:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800836:	85 f6                	test   %esi,%esi
  800838:	74 34                	je     80086e <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  80083a:	83 fe 01             	cmp    $0x1,%esi
  80083d:	74 26                	je     800865 <strlcpy+0x40>
  80083f:	0f b6 0b             	movzbl (%ebx),%ecx
  800842:	84 c9                	test   %cl,%cl
  800844:	74 23                	je     800869 <strlcpy+0x44>
  800846:	83 ee 02             	sub    $0x2,%esi
  800849:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800854:	39 f2                	cmp    %esi,%edx
  800856:	74 13                	je     80086b <strlcpy+0x46>
  800858:	83 c2 01             	add    $0x1,%edx
  80085b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80085f:	84 c9                	test   %cl,%cl
  800861:	75 eb                	jne    80084e <strlcpy+0x29>
  800863:	eb 06                	jmp    80086b <strlcpy+0x46>
  800865:	89 f8                	mov    %edi,%eax
  800867:	eb 02                	jmp    80086b <strlcpy+0x46>
  800869:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  80086b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086e:	29 f8                	sub    %edi,%eax
}
  800870:	5b                   	pop    %ebx
  800871:	5e                   	pop    %esi
  800872:	5f                   	pop    %edi
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087e:	0f b6 01             	movzbl (%ecx),%eax
  800881:	84 c0                	test   %al,%al
  800883:	74 15                	je     80089a <strcmp+0x25>
  800885:	3a 02                	cmp    (%edx),%al
  800887:	75 11                	jne    80089a <strcmp+0x25>
		p++, q++;
  800889:	83 c1 01             	add    $0x1,%ecx
  80088c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80088f:	0f b6 01             	movzbl (%ecx),%eax
  800892:	84 c0                	test   %al,%al
  800894:	74 04                	je     80089a <strcmp+0x25>
  800896:	3a 02                	cmp    (%edx),%al
  800898:	74 ef                	je     800889 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089a:	0f b6 c0             	movzbl %al,%eax
  80089d:	0f b6 12             	movzbl (%edx),%edx
  8008a0:	29 d0                	sub    %edx,%eax
}
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	56                   	push   %esi
  8008a8:	53                   	push   %ebx
  8008a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008af:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8008b2:	85 f6                	test   %esi,%esi
  8008b4:	74 29                	je     8008df <strncmp+0x3b>
  8008b6:	0f b6 03             	movzbl (%ebx),%eax
  8008b9:	84 c0                	test   %al,%al
  8008bb:	74 30                	je     8008ed <strncmp+0x49>
  8008bd:	3a 02                	cmp    (%edx),%al
  8008bf:	75 2c                	jne    8008ed <strncmp+0x49>
  8008c1:	8d 43 01             	lea    0x1(%ebx),%eax
  8008c4:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8008c6:	89 c3                	mov    %eax,%ebx
  8008c8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008cb:	39 f0                	cmp    %esi,%eax
  8008cd:	74 17                	je     8008e6 <strncmp+0x42>
  8008cf:	0f b6 08             	movzbl (%eax),%ecx
  8008d2:	84 c9                	test   %cl,%cl
  8008d4:	74 17                	je     8008ed <strncmp+0x49>
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	3a 0a                	cmp    (%edx),%cl
  8008db:	74 e9                	je     8008c6 <strncmp+0x22>
  8008dd:	eb 0e                	jmp    8008ed <strncmp+0x49>
	if (n == 0)
		return 0;
  8008df:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e4:	eb 0f                	jmp    8008f5 <strncmp+0x51>
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008eb:	eb 08                	jmp    8008f5 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ed:	0f b6 03             	movzbl (%ebx),%eax
  8008f0:	0f b6 12             	movzbl (%edx),%edx
  8008f3:	29 d0                	sub    %edx,%eax
}
  8008f5:	5b                   	pop    %ebx
  8008f6:	5e                   	pop    %esi
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	53                   	push   %ebx
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800903:	0f b6 18             	movzbl (%eax),%ebx
  800906:	84 db                	test   %bl,%bl
  800908:	74 1d                	je     800927 <strchr+0x2e>
  80090a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80090c:	38 d3                	cmp    %dl,%bl
  80090e:	75 06                	jne    800916 <strchr+0x1d>
  800910:	eb 1a                	jmp    80092c <strchr+0x33>
  800912:	38 ca                	cmp    %cl,%dl
  800914:	74 16                	je     80092c <strchr+0x33>
	for (; *s; s++)
  800916:	83 c0 01             	add    $0x1,%eax
  800919:	0f b6 10             	movzbl (%eax),%edx
  80091c:	84 d2                	test   %dl,%dl
  80091e:	75 f2                	jne    800912 <strchr+0x19>
			return (char *) s;
	return 0;
  800920:	b8 00 00 00 00       	mov    $0x0,%eax
  800925:	eb 05                	jmp    80092c <strchr+0x33>
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092c:	5b                   	pop    %ebx
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	53                   	push   %ebx
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800939:	0f b6 18             	movzbl (%eax),%ebx
  80093c:	84 db                	test   %bl,%bl
  80093e:	74 16                	je     800956 <strfind+0x27>
  800940:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800942:	38 d3                	cmp    %dl,%bl
  800944:	75 06                	jne    80094c <strfind+0x1d>
  800946:	eb 0e                	jmp    800956 <strfind+0x27>
  800948:	38 ca                	cmp    %cl,%dl
  80094a:	74 0a                	je     800956 <strfind+0x27>
	for (; *s; s++)
  80094c:	83 c0 01             	add    $0x1,%eax
  80094f:	0f b6 10             	movzbl (%eax),%edx
  800952:	84 d2                	test   %dl,%dl
  800954:	75 f2                	jne    800948 <strfind+0x19>
			break;
	return (char *) s;
}
  800956:	5b                   	pop    %ebx
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	57                   	push   %edi
  80095d:	56                   	push   %esi
  80095e:	53                   	push   %ebx
  80095f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800962:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800965:	85 c9                	test   %ecx,%ecx
  800967:	74 36                	je     80099f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800969:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096f:	75 28                	jne    800999 <memset+0x40>
  800971:	f6 c1 03             	test   $0x3,%cl
  800974:	75 23                	jne    800999 <memset+0x40>
		c &= 0xFF;
  800976:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097a:	89 d3                	mov    %edx,%ebx
  80097c:	c1 e3 08             	shl    $0x8,%ebx
  80097f:	89 d6                	mov    %edx,%esi
  800981:	c1 e6 18             	shl    $0x18,%esi
  800984:	89 d0                	mov    %edx,%eax
  800986:	c1 e0 10             	shl    $0x10,%eax
  800989:	09 f0                	or     %esi,%eax
  80098b:	09 c2                	or     %eax,%edx
  80098d:	89 d0                	mov    %edx,%eax
  80098f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800991:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800994:	fc                   	cld    
  800995:	f3 ab                	rep stos %eax,%es:(%edi)
  800997:	eb 06                	jmp    80099f <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800999:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099c:	fc                   	cld    
  80099d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099f:	89 f8                	mov    %edi,%eax
  8009a1:	5b                   	pop    %ebx
  8009a2:	5e                   	pop    %esi
  8009a3:	5f                   	pop    %edi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	57                   	push   %edi
  8009aa:	56                   	push   %esi
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b4:	39 c6                	cmp    %eax,%esi
  8009b6:	73 35                	jae    8009ed <memmove+0x47>
  8009b8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009bb:	39 d0                	cmp    %edx,%eax
  8009bd:	73 2e                	jae    8009ed <memmove+0x47>
		s += n;
		d += n;
  8009bf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009c2:	89 d6                	mov    %edx,%esi
  8009c4:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cc:	75 13                	jne    8009e1 <memmove+0x3b>
  8009ce:	f6 c1 03             	test   $0x3,%cl
  8009d1:	75 0e                	jne    8009e1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d3:	83 ef 04             	sub    $0x4,%edi
  8009d6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009dc:	fd                   	std    
  8009dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009df:	eb 09                	jmp    8009ea <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009e1:	83 ef 01             	sub    $0x1,%edi
  8009e4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009e7:	fd                   	std    
  8009e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ea:	fc                   	cld    
  8009eb:	eb 1d                	jmp    800a0a <memmove+0x64>
  8009ed:	89 f2                	mov    %esi,%edx
  8009ef:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f1:	f6 c2 03             	test   $0x3,%dl
  8009f4:	75 0f                	jne    800a05 <memmove+0x5f>
  8009f6:	f6 c1 03             	test   $0x3,%cl
  8009f9:	75 0a                	jne    800a05 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009fb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009fe:	89 c7                	mov    %eax,%edi
  800a00:	fc                   	cld    
  800a01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a03:	eb 05                	jmp    800a0a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800a05:	89 c7                	mov    %eax,%edi
  800a07:	fc                   	cld    
  800a08:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0a:	5e                   	pop    %esi
  800a0b:	5f                   	pop    %edi
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a14:	8b 45 10             	mov    0x10(%ebp),%eax
  800a17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	89 04 24             	mov    %eax,(%esp)
  800a28:	e8 79 ff ff ff       	call   8009a6 <memmove>
}
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	57                   	push   %edi
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a38:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800a41:	85 c0                	test   %eax,%eax
  800a43:	74 36                	je     800a7b <memcmp+0x4c>
		if (*s1 != *s2)
  800a45:	0f b6 03             	movzbl (%ebx),%eax
  800a48:	0f b6 0e             	movzbl (%esi),%ecx
  800a4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a50:	38 c8                	cmp    %cl,%al
  800a52:	74 1c                	je     800a70 <memcmp+0x41>
  800a54:	eb 10                	jmp    800a66 <memcmp+0x37>
  800a56:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a5b:	83 c2 01             	add    $0x1,%edx
  800a5e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a62:	38 c8                	cmp    %cl,%al
  800a64:	74 0a                	je     800a70 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800a66:	0f b6 c0             	movzbl %al,%eax
  800a69:	0f b6 c9             	movzbl %cl,%ecx
  800a6c:	29 c8                	sub    %ecx,%eax
  800a6e:	eb 10                	jmp    800a80 <memcmp+0x51>
	while (n-- > 0) {
  800a70:	39 fa                	cmp    %edi,%edx
  800a72:	75 e2                	jne    800a56 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
  800a79:	eb 05                	jmp    800a80 <memcmp+0x51>
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	53                   	push   %ebx
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800a8f:	89 c2                	mov    %eax,%edx
  800a91:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a94:	39 d0                	cmp    %edx,%eax
  800a96:	73 13                	jae    800aab <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a98:	89 d9                	mov    %ebx,%ecx
  800a9a:	38 18                	cmp    %bl,(%eax)
  800a9c:	75 06                	jne    800aa4 <memfind+0x1f>
  800a9e:	eb 0b                	jmp    800aab <memfind+0x26>
  800aa0:	38 08                	cmp    %cl,(%eax)
  800aa2:	74 07                	je     800aab <memfind+0x26>
	for (; s < ends; s++)
  800aa4:	83 c0 01             	add    $0x1,%eax
  800aa7:	39 d0                	cmp    %edx,%eax
  800aa9:	75 f5                	jne    800aa0 <memfind+0x1b>
			break;
	return (void *) s;
}
  800aab:	5b                   	pop    %ebx
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	57                   	push   %edi
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab7:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aba:	0f b6 0a             	movzbl (%edx),%ecx
  800abd:	80 f9 09             	cmp    $0x9,%cl
  800ac0:	74 05                	je     800ac7 <strtol+0x19>
  800ac2:	80 f9 20             	cmp    $0x20,%cl
  800ac5:	75 10                	jne    800ad7 <strtol+0x29>
		s++;
  800ac7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800aca:	0f b6 0a             	movzbl (%edx),%ecx
  800acd:	80 f9 09             	cmp    $0x9,%cl
  800ad0:	74 f5                	je     800ac7 <strtol+0x19>
  800ad2:	80 f9 20             	cmp    $0x20,%cl
  800ad5:	74 f0                	je     800ac7 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800ad7:	80 f9 2b             	cmp    $0x2b,%cl
  800ada:	75 0a                	jne    800ae6 <strtol+0x38>
		s++;
  800adc:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800adf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae4:	eb 11                	jmp    800af7 <strtol+0x49>
  800ae6:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800aeb:	80 f9 2d             	cmp    $0x2d,%cl
  800aee:	75 07                	jne    800af7 <strtol+0x49>
		s++, neg = 1;
  800af0:	83 c2 01             	add    $0x1,%edx
  800af3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af7:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800afc:	75 15                	jne    800b13 <strtol+0x65>
  800afe:	80 3a 30             	cmpb   $0x30,(%edx)
  800b01:	75 10                	jne    800b13 <strtol+0x65>
  800b03:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b07:	75 0a                	jne    800b13 <strtol+0x65>
		s += 2, base = 16;
  800b09:	83 c2 02             	add    $0x2,%edx
  800b0c:	b8 10 00 00 00       	mov    $0x10,%eax
  800b11:	eb 10                	jmp    800b23 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800b13:	85 c0                	test   %eax,%eax
  800b15:	75 0c                	jne    800b23 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b17:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800b19:	80 3a 30             	cmpb   $0x30,(%edx)
  800b1c:	75 05                	jne    800b23 <strtol+0x75>
		s++, base = 8;
  800b1e:	83 c2 01             	add    $0x1,%edx
  800b21:	b0 08                	mov    $0x8,%al
		base = 10;
  800b23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b28:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b2b:	0f b6 0a             	movzbl (%edx),%ecx
  800b2e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b31:	89 f0                	mov    %esi,%eax
  800b33:	3c 09                	cmp    $0x9,%al
  800b35:	77 08                	ja     800b3f <strtol+0x91>
			dig = *s - '0';
  800b37:	0f be c9             	movsbl %cl,%ecx
  800b3a:	83 e9 30             	sub    $0x30,%ecx
  800b3d:	eb 20                	jmp    800b5f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800b3f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b42:	89 f0                	mov    %esi,%eax
  800b44:	3c 19                	cmp    $0x19,%al
  800b46:	77 08                	ja     800b50 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800b48:	0f be c9             	movsbl %cl,%ecx
  800b4b:	83 e9 57             	sub    $0x57,%ecx
  800b4e:	eb 0f                	jmp    800b5f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800b50:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b53:	89 f0                	mov    %esi,%eax
  800b55:	3c 19                	cmp    $0x19,%al
  800b57:	77 16                	ja     800b6f <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b59:	0f be c9             	movsbl %cl,%ecx
  800b5c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b5f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b62:	7d 0f                	jge    800b73 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b64:	83 c2 01             	add    $0x1,%edx
  800b67:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b6b:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b6d:	eb bc                	jmp    800b2b <strtol+0x7d>
  800b6f:	89 d8                	mov    %ebx,%eax
  800b71:	eb 02                	jmp    800b75 <strtol+0xc7>
  800b73:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b75:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b79:	74 05                	je     800b80 <strtol+0xd2>
		*endptr = (char *) s;
  800b7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b80:	f7 d8                	neg    %eax
  800b82:	85 ff                	test   %edi,%edi
  800b84:	0f 44 c3             	cmove  %ebx,%eax
}
  800b87:	5b                   	pop    %ebx
  800b88:	5e                   	pop    %esi
  800b89:	5f                   	pop    %edi
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	57                   	push   %edi
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b92:	b8 00 00 00 00       	mov    $0x0,%eax
  800b97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	89 c3                	mov    %eax,%ebx
  800b9f:	89 c7                	mov    %eax,%edi
  800ba1:	89 c6                	mov    %eax,%esi
  800ba3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_cgetc>:

int
sys_cgetc(void)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bba:	89 d1                	mov    %edx,%ecx
  800bbc:	89 d3                	mov    %edx,%ebx
  800bbe:	89 d7                	mov    %edx,%edi
  800bc0:	89 d6                	mov    %edx,%esi
  800bc2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800bd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdf:	89 cb                	mov    %ecx,%ebx
  800be1:	89 cf                	mov    %ecx,%edi
  800be3:	89 ce                	mov    %ecx,%esi
  800be5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be7:	85 c0                	test   %eax,%eax
  800be9:	7e 28                	jle    800c13 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800beb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bef:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bf6:	00 
  800bf7:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800bfe:	00 
  800bff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c06:	00 
  800c07:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800c0e:	e8 63 10 00 00       	call   801c76 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c13:	83 c4 2c             	add    $0x2c,%esp
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c21:	ba 00 00 00 00       	mov    $0x0,%edx
  800c26:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2b:	89 d1                	mov    %edx,%ecx
  800c2d:	89 d3                	mov    %edx,%ebx
  800c2f:	89 d7                	mov    %edx,%edi
  800c31:	89 d6                	mov    %edx,%esi
  800c33:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <sys_yield>:

void
sys_yield(void)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c40:	ba 00 00 00 00       	mov    $0x0,%edx
  800c45:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c4a:	89 d1                	mov    %edx,%ecx
  800c4c:	89 d3                	mov    %edx,%ebx
  800c4e:	89 d7                	mov    %edx,%edi
  800c50:	89 d6                	mov    %edx,%esi
  800c52:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
  800c5f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c62:	be 00 00 00 00       	mov    $0x0,%esi
  800c67:	b8 04 00 00 00       	mov    $0x4,%eax
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c75:	89 f7                	mov    %esi,%edi
  800c77:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	7e 28                	jle    800ca5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c81:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c88:	00 
  800c89:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800c90:	00 
  800c91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c98:	00 
  800c99:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800ca0:	e8 d1 0f 00 00       	call   801c76 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca5:	83 c4 2c             	add    $0x2c,%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cb6:	b8 05 00 00 00       	mov    $0x5,%eax
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc7:	8b 75 18             	mov    0x18(%ebp),%esi
  800cca:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7e 28                	jle    800cf8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cdb:	00 
  800cdc:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800ce3:	00 
  800ce4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ceb:	00 
  800cec:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800cf3:	e8 7e 0f 00 00       	call   801c76 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf8:	83 c4 2c             	add    $0x2c,%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 df                	mov    %ebx,%edi
  800d1b:	89 de                	mov    %ebx,%esi
  800d1d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7e 28                	jle    800d4b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d27:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d2e:	00 
  800d2f:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800d36:	00 
  800d37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3e:	00 
  800d3f:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800d46:	e8 2b 0f 00 00       	call   801c76 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d4b:	83 c4 2c             	add    $0x2c,%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d61:	b8 08 00 00 00       	mov    $0x8,%eax
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	89 df                	mov    %ebx,%edi
  800d6e:	89 de                	mov    %ebx,%esi
  800d70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7e 28                	jle    800d9e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d81:	00 
  800d82:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800d89:	00 
  800d8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d91:	00 
  800d92:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800d99:	e8 d8 0e 00 00       	call   801c76 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9e:	83 c4 2c             	add    $0x2c,%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
  800dac:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800daf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db4:	b8 09 00 00 00       	mov    $0x9,%eax
  800db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	89 df                	mov    %ebx,%edi
  800dc1:	89 de                	mov    %ebx,%esi
  800dc3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	7e 28                	jle    800df1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dcd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dd4:	00 
  800dd5:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800ddc:	00 
  800ddd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de4:	00 
  800de5:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800dec:	e8 85 0e 00 00       	call   801c76 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800df1:	83 c4 2c             	add    $0x2c,%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	57                   	push   %edi
  800dfd:	56                   	push   %esi
  800dfe:	53                   	push   %ebx
  800dff:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e07:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e12:	89 df                	mov    %ebx,%edi
  800e14:	89 de                	mov    %ebx,%esi
  800e16:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	7e 28                	jle    800e44 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e20:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e27:	00 
  800e28:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800e2f:	00 
  800e30:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e37:	00 
  800e38:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800e3f:	e8 32 0e 00 00       	call   801c76 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e44:	83 c4 2c             	add    $0x2c,%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e52:	be 00 00 00 00       	mov    $0x0,%esi
  800e57:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e65:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e68:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e6a:	5b                   	pop    %ebx
  800e6b:	5e                   	pop    %esi
  800e6c:	5f                   	pop    %edi
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e78:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e7d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e82:	8b 55 08             	mov    0x8(%ebp),%edx
  800e85:	89 cb                	mov    %ecx,%ebx
  800e87:	89 cf                	mov    %ecx,%edi
  800e89:	89 ce                	mov    %ecx,%esi
  800e8b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	7e 28                	jle    800eb9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e95:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800ea4:	00 
  800ea5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eac:	00 
  800ead:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800eb4:	e8 bd 0d 00 00       	call   801c76 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb9:	83 c4 2c             	add    $0x2c,%esp
  800ebc:	5b                   	pop    %ebx
  800ebd:	5e                   	pop    %esi
  800ebe:	5f                   	pop    %edi
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    
  800ec1:	66 90                	xchg   %ax,%ax
  800ec3:	66 90                	xchg   %ax,%ax
  800ec5:	66 90                	xchg   %ax,%ax
  800ec7:	66 90                	xchg   %ax,%ax
  800ec9:	66 90                	xchg   %ax,%ax
  800ecb:	66 90                	xchg   %ax,%ax
  800ecd:	66 90                	xchg   %ax,%ax
  800ecf:	90                   	nop

00800ed0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed6:	05 00 00 00 30       	add    $0x30000000,%eax
  800edb:	c1 e8 0c             	shr    $0xc,%eax
}
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800eeb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ef0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800efa:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800eff:	a8 01                	test   $0x1,%al
  800f01:	74 34                	je     800f37 <fd_alloc+0x40>
  800f03:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800f08:	a8 01                	test   $0x1,%al
  800f0a:	74 32                	je     800f3e <fd_alloc+0x47>
  800f0c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  800f11:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f13:	89 c2                	mov    %eax,%edx
  800f15:	c1 ea 16             	shr    $0x16,%edx
  800f18:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f1f:	f6 c2 01             	test   $0x1,%dl
  800f22:	74 1f                	je     800f43 <fd_alloc+0x4c>
  800f24:	89 c2                	mov    %eax,%edx
  800f26:	c1 ea 0c             	shr    $0xc,%edx
  800f29:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f30:	f6 c2 01             	test   $0x1,%dl
  800f33:	75 1a                	jne    800f4f <fd_alloc+0x58>
  800f35:	eb 0c                	jmp    800f43 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  800f37:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800f3c:	eb 05                	jmp    800f43 <fd_alloc+0x4c>
  800f3e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  800f43:	8b 45 08             	mov    0x8(%ebp),%eax
  800f46:	89 08                	mov    %ecx,(%eax)
			return 0;
  800f48:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4d:	eb 1a                	jmp    800f69 <fd_alloc+0x72>
  800f4f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800f54:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f59:	75 b6                	jne    800f11 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  800f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f64:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f71:	83 f8 1f             	cmp    $0x1f,%eax
  800f74:	77 36                	ja     800fac <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f76:	c1 e0 0c             	shl    $0xc,%eax
  800f79:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f7e:	89 c2                	mov    %eax,%edx
  800f80:	c1 ea 16             	shr    $0x16,%edx
  800f83:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f8a:	f6 c2 01             	test   $0x1,%dl
  800f8d:	74 24                	je     800fb3 <fd_lookup+0x48>
  800f8f:	89 c2                	mov    %eax,%edx
  800f91:	c1 ea 0c             	shr    $0xc,%edx
  800f94:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f9b:	f6 c2 01             	test   $0x1,%dl
  800f9e:	74 1a                	je     800fba <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fa0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa3:	89 02                	mov    %eax,(%edx)
	return 0;
  800fa5:	b8 00 00 00 00       	mov    $0x0,%eax
  800faa:	eb 13                	jmp    800fbf <fd_lookup+0x54>
		return -E_INVAL;
  800fac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fb1:	eb 0c                	jmp    800fbf <fd_lookup+0x54>
		return -E_INVAL;
  800fb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fb8:	eb 05                	jmp    800fbf <fd_lookup+0x54>
  800fba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fbf:	5d                   	pop    %ebp
  800fc0:	c3                   	ret    

00800fc1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	53                   	push   %ebx
  800fc5:	83 ec 14             	sub    $0x14,%esp
  800fc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800fce:	39 05 04 30 80 00    	cmp    %eax,0x803004
  800fd4:	75 1e                	jne    800ff4 <dev_lookup+0x33>
  800fd6:	eb 0e                	jmp    800fe6 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  800fd8:	b8 20 30 80 00       	mov    $0x803020,%eax
  800fdd:	eb 0c                	jmp    800feb <dev_lookup+0x2a>
  800fdf:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800fe4:	eb 05                	jmp    800feb <dev_lookup+0x2a>
  800fe6:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  800feb:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fed:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff2:	eb 38                	jmp    80102c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  800ff4:	39 05 20 30 80 00    	cmp    %eax,0x803020
  800ffa:	74 dc                	je     800fd8 <dev_lookup+0x17>
  800ffc:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  801002:	74 db                	je     800fdf <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801004:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80100a:	8b 52 48             	mov    0x48(%edx),%edx
  80100d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801011:	89 54 24 04          	mov    %edx,0x4(%esp)
  801015:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  80101c:	e8 33 f1 ff ff       	call   800154 <cprintf>
	*dev = 0;
  801021:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801027:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80102c:	83 c4 14             	add    $0x14,%esp
  80102f:	5b                   	pop    %ebx
  801030:	5d                   	pop    %ebp
  801031:	c3                   	ret    

00801032 <fd_close>:
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	56                   	push   %esi
  801036:	53                   	push   %ebx
  801037:	83 ec 20             	sub    $0x20,%esp
  80103a:	8b 75 08             	mov    0x8(%ebp),%esi
  80103d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801040:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801043:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801047:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80104d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801050:	89 04 24             	mov    %eax,(%esp)
  801053:	e8 13 ff ff ff       	call   800f6b <fd_lookup>
  801058:	85 c0                	test   %eax,%eax
  80105a:	78 05                	js     801061 <fd_close+0x2f>
	    || fd != fd2)
  80105c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80105f:	74 0c                	je     80106d <fd_close+0x3b>
		return (must_exist ? r : 0);
  801061:	84 db                	test   %bl,%bl
  801063:	ba 00 00 00 00       	mov    $0x0,%edx
  801068:	0f 44 c2             	cmove  %edx,%eax
  80106b:	eb 3f                	jmp    8010ac <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80106d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801070:	89 44 24 04          	mov    %eax,0x4(%esp)
  801074:	8b 06                	mov    (%esi),%eax
  801076:	89 04 24             	mov    %eax,(%esp)
  801079:	e8 43 ff ff ff       	call   800fc1 <dev_lookup>
  80107e:	89 c3                	mov    %eax,%ebx
  801080:	85 c0                	test   %eax,%eax
  801082:	78 16                	js     80109a <fd_close+0x68>
		if (dev->dev_close)
  801084:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801087:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80108a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80108f:	85 c0                	test   %eax,%eax
  801091:	74 07                	je     80109a <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801093:	89 34 24             	mov    %esi,(%esp)
  801096:	ff d0                	call   *%eax
  801098:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  80109a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80109e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a5:	e8 56 fc ff ff       	call   800d00 <sys_page_unmap>
	return r;
  8010aa:	89 d8                	mov    %ebx,%eax
}
  8010ac:	83 c4 20             	add    $0x20,%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <close>:

int
close(int fdnum)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c3:	89 04 24             	mov    %eax,(%esp)
  8010c6:	e8 a0 fe ff ff       	call   800f6b <fd_lookup>
  8010cb:	89 c2                	mov    %eax,%edx
  8010cd:	85 d2                	test   %edx,%edx
  8010cf:	78 13                	js     8010e4 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8010d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010d8:	00 
  8010d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010dc:	89 04 24             	mov    %eax,(%esp)
  8010df:	e8 4e ff ff ff       	call   801032 <fd_close>
}
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <close_all>:

void
close_all(void)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	53                   	push   %ebx
  8010ea:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010f2:	89 1c 24             	mov    %ebx,(%esp)
  8010f5:	e8 b9 ff ff ff       	call   8010b3 <close>
	for (i = 0; i < MAXFD; i++)
  8010fa:	83 c3 01             	add    $0x1,%ebx
  8010fd:	83 fb 20             	cmp    $0x20,%ebx
  801100:	75 f0                	jne    8010f2 <close_all+0xc>
}
  801102:	83 c4 14             	add    $0x14,%esp
  801105:	5b                   	pop    %ebx
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    

00801108 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	57                   	push   %edi
  80110c:	56                   	push   %esi
  80110d:	53                   	push   %ebx
  80110e:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801111:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801114:	89 44 24 04          	mov    %eax,0x4(%esp)
  801118:	8b 45 08             	mov    0x8(%ebp),%eax
  80111b:	89 04 24             	mov    %eax,(%esp)
  80111e:	e8 48 fe ff ff       	call   800f6b <fd_lookup>
  801123:	89 c2                	mov    %eax,%edx
  801125:	85 d2                	test   %edx,%edx
  801127:	0f 88 e1 00 00 00    	js     80120e <dup+0x106>
		return r;
	close(newfdnum);
  80112d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801130:	89 04 24             	mov    %eax,(%esp)
  801133:	e8 7b ff ff ff       	call   8010b3 <close>

	newfd = INDEX2FD(newfdnum);
  801138:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80113b:	c1 e3 0c             	shl    $0xc,%ebx
  80113e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801144:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801147:	89 04 24             	mov    %eax,(%esp)
  80114a:	e8 91 fd ff ff       	call   800ee0 <fd2data>
  80114f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801151:	89 1c 24             	mov    %ebx,(%esp)
  801154:	e8 87 fd ff ff       	call   800ee0 <fd2data>
  801159:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80115b:	89 f0                	mov    %esi,%eax
  80115d:	c1 e8 16             	shr    $0x16,%eax
  801160:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801167:	a8 01                	test   $0x1,%al
  801169:	74 43                	je     8011ae <dup+0xa6>
  80116b:	89 f0                	mov    %esi,%eax
  80116d:	c1 e8 0c             	shr    $0xc,%eax
  801170:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801177:	f6 c2 01             	test   $0x1,%dl
  80117a:	74 32                	je     8011ae <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80117c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801183:	25 07 0e 00 00       	and    $0xe07,%eax
  801188:	89 44 24 10          	mov    %eax,0x10(%esp)
  80118c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801190:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801197:	00 
  801198:	89 74 24 04          	mov    %esi,0x4(%esp)
  80119c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011a3:	e8 05 fb ff ff       	call   800cad <sys_page_map>
  8011a8:	89 c6                	mov    %eax,%esi
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	78 3e                	js     8011ec <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b1:	89 c2                	mov    %eax,%edx
  8011b3:	c1 ea 0c             	shr    $0xc,%edx
  8011b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011bd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011c3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011c7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011d2:	00 
  8011d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011de:	e8 ca fa ff ff       	call   800cad <sys_page_map>
  8011e3:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8011e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011e8:	85 f6                	test   %esi,%esi
  8011ea:	79 22                	jns    80120e <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8011ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f7:	e8 04 fb ff ff       	call   800d00 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801200:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801207:	e8 f4 fa ff ff       	call   800d00 <sys_page_unmap>
	return r;
  80120c:	89 f0                	mov    %esi,%eax
}
  80120e:	83 c4 3c             	add    $0x3c,%esp
  801211:	5b                   	pop    %ebx
  801212:	5e                   	pop    %esi
  801213:	5f                   	pop    %edi
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	53                   	push   %ebx
  80121a:	83 ec 24             	sub    $0x24,%esp
  80121d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801220:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801223:	89 44 24 04          	mov    %eax,0x4(%esp)
  801227:	89 1c 24             	mov    %ebx,(%esp)
  80122a:	e8 3c fd ff ff       	call   800f6b <fd_lookup>
  80122f:	89 c2                	mov    %eax,%edx
  801231:	85 d2                	test   %edx,%edx
  801233:	78 6d                	js     8012a2 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801235:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123f:	8b 00                	mov    (%eax),%eax
  801241:	89 04 24             	mov    %eax,(%esp)
  801244:	e8 78 fd ff ff       	call   800fc1 <dev_lookup>
  801249:	85 c0                	test   %eax,%eax
  80124b:	78 55                	js     8012a2 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80124d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801250:	8b 50 08             	mov    0x8(%eax),%edx
  801253:	83 e2 03             	and    $0x3,%edx
  801256:	83 fa 01             	cmp    $0x1,%edx
  801259:	75 23                	jne    80127e <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80125b:	a1 04 40 80 00       	mov    0x804004,%eax
  801260:	8b 40 48             	mov    0x48(%eax),%eax
  801263:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126b:	c7 04 24 2d 24 80 00 	movl   $0x80242d,(%esp)
  801272:	e8 dd ee ff ff       	call   800154 <cprintf>
		return -E_INVAL;
  801277:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127c:	eb 24                	jmp    8012a2 <read+0x8c>
	}
	if (!dev->dev_read)
  80127e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801281:	8b 52 08             	mov    0x8(%edx),%edx
  801284:	85 d2                	test   %edx,%edx
  801286:	74 15                	je     80129d <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801288:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80128b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80128f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801292:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801296:	89 04 24             	mov    %eax,(%esp)
  801299:	ff d2                	call   *%edx
  80129b:	eb 05                	jmp    8012a2 <read+0x8c>
		return -E_NOT_SUPP;
  80129d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8012a2:	83 c4 24             	add    $0x24,%esp
  8012a5:	5b                   	pop    %ebx
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    

008012a8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	57                   	push   %edi
  8012ac:	56                   	push   %esi
  8012ad:	53                   	push   %ebx
  8012ae:	83 ec 1c             	sub    $0x1c,%esp
  8012b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012b4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b7:	85 f6                	test   %esi,%esi
  8012b9:	74 33                	je     8012ee <readn+0x46>
  8012bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c0:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012c5:	89 f2                	mov    %esi,%edx
  8012c7:	29 c2                	sub    %eax,%edx
  8012c9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012cd:	03 45 0c             	add    0xc(%ebp),%eax
  8012d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d4:	89 3c 24             	mov    %edi,(%esp)
  8012d7:	e8 3a ff ff ff       	call   801216 <read>
		if (m < 0)
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 1b                	js     8012fb <readn+0x53>
			return m;
		if (m == 0)
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	74 11                	je     8012f5 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  8012e4:	01 c3                	add    %eax,%ebx
  8012e6:	89 d8                	mov    %ebx,%eax
  8012e8:	39 f3                	cmp    %esi,%ebx
  8012ea:	72 d9                	jb     8012c5 <readn+0x1d>
  8012ec:	eb 0b                	jmp    8012f9 <readn+0x51>
  8012ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f3:	eb 06                	jmp    8012fb <readn+0x53>
  8012f5:	89 d8                	mov    %ebx,%eax
  8012f7:	eb 02                	jmp    8012fb <readn+0x53>
  8012f9:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012fb:	83 c4 1c             	add    $0x1c,%esp
  8012fe:	5b                   	pop    %ebx
  8012ff:	5e                   	pop    %esi
  801300:	5f                   	pop    %edi
  801301:	5d                   	pop    %ebp
  801302:	c3                   	ret    

00801303 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	53                   	push   %ebx
  801307:	83 ec 24             	sub    $0x24,%esp
  80130a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801310:	89 44 24 04          	mov    %eax,0x4(%esp)
  801314:	89 1c 24             	mov    %ebx,(%esp)
  801317:	e8 4f fc ff ff       	call   800f6b <fd_lookup>
  80131c:	89 c2                	mov    %eax,%edx
  80131e:	85 d2                	test   %edx,%edx
  801320:	78 68                	js     80138a <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801322:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801325:	89 44 24 04          	mov    %eax,0x4(%esp)
  801329:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132c:	8b 00                	mov    (%eax),%eax
  80132e:	89 04 24             	mov    %eax,(%esp)
  801331:	e8 8b fc ff ff       	call   800fc1 <dev_lookup>
  801336:	85 c0                	test   %eax,%eax
  801338:	78 50                	js     80138a <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80133a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801341:	75 23                	jne    801366 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801343:	a1 04 40 80 00       	mov    0x804004,%eax
  801348:	8b 40 48             	mov    0x48(%eax),%eax
  80134b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80134f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801353:	c7 04 24 49 24 80 00 	movl   $0x802449,(%esp)
  80135a:	e8 f5 ed ff ff       	call   800154 <cprintf>
		return -E_INVAL;
  80135f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801364:	eb 24                	jmp    80138a <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801366:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801369:	8b 52 0c             	mov    0xc(%edx),%edx
  80136c:	85 d2                	test   %edx,%edx
  80136e:	74 15                	je     801385 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801370:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801373:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801377:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80137a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80137e:	89 04 24             	mov    %eax,(%esp)
  801381:	ff d2                	call   *%edx
  801383:	eb 05                	jmp    80138a <write+0x87>
		return -E_NOT_SUPP;
  801385:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80138a:	83 c4 24             	add    $0x24,%esp
  80138d:	5b                   	pop    %ebx
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <seek>:

int
seek(int fdnum, off_t offset)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801396:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139d:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a0:	89 04 24             	mov    %eax,(%esp)
  8013a3:	e8 c3 fb ff ff       	call   800f6b <fd_lookup>
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	78 0e                	js     8013ba <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ba:	c9                   	leave  
  8013bb:	c3                   	ret    

008013bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	53                   	push   %ebx
  8013c0:	83 ec 24             	sub    $0x24,%esp
  8013c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013cd:	89 1c 24             	mov    %ebx,(%esp)
  8013d0:	e8 96 fb ff ff       	call   800f6b <fd_lookup>
  8013d5:	89 c2                	mov    %eax,%edx
  8013d7:	85 d2                	test   %edx,%edx
  8013d9:	78 61                	js     80143c <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e5:	8b 00                	mov    (%eax),%eax
  8013e7:	89 04 24             	mov    %eax,(%esp)
  8013ea:	e8 d2 fb ff ff       	call   800fc1 <dev_lookup>
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 49                	js     80143c <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013fa:	75 23                	jne    80141f <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013fc:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801401:	8b 40 48             	mov    0x48(%eax),%eax
  801404:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801408:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140c:	c7 04 24 0c 24 80 00 	movl   $0x80240c,(%esp)
  801413:	e8 3c ed ff ff       	call   800154 <cprintf>
		return -E_INVAL;
  801418:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141d:	eb 1d                	jmp    80143c <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80141f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801422:	8b 52 18             	mov    0x18(%edx),%edx
  801425:	85 d2                	test   %edx,%edx
  801427:	74 0e                	je     801437 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801429:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80142c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801430:	89 04 24             	mov    %eax,(%esp)
  801433:	ff d2                	call   *%edx
  801435:	eb 05                	jmp    80143c <ftruncate+0x80>
		return -E_NOT_SUPP;
  801437:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80143c:	83 c4 24             	add    $0x24,%esp
  80143f:	5b                   	pop    %ebx
  801440:	5d                   	pop    %ebp
  801441:	c3                   	ret    

00801442 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	53                   	push   %ebx
  801446:	83 ec 24             	sub    $0x24,%esp
  801449:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801453:	8b 45 08             	mov    0x8(%ebp),%eax
  801456:	89 04 24             	mov    %eax,(%esp)
  801459:	e8 0d fb ff ff       	call   800f6b <fd_lookup>
  80145e:	89 c2                	mov    %eax,%edx
  801460:	85 d2                	test   %edx,%edx
  801462:	78 52                	js     8014b6 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801464:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146e:	8b 00                	mov    (%eax),%eax
  801470:	89 04 24             	mov    %eax,(%esp)
  801473:	e8 49 fb ff ff       	call   800fc1 <dev_lookup>
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 3a                	js     8014b6 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80147c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801483:	74 2c                	je     8014b1 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801485:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801488:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80148f:	00 00 00 
	stat->st_isdir = 0;
  801492:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801499:	00 00 00 
	stat->st_dev = dev;
  80149c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a9:	89 14 24             	mov    %edx,(%esp)
  8014ac:	ff 50 14             	call   *0x14(%eax)
  8014af:	eb 05                	jmp    8014b6 <fstat+0x74>
		return -E_NOT_SUPP;
  8014b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8014b6:	83 c4 24             	add    $0x24,%esp
  8014b9:	5b                   	pop    %ebx
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	56                   	push   %esi
  8014c0:	53                   	push   %ebx
  8014c1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014cb:	00 
  8014cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cf:	89 04 24             	mov    %eax,(%esp)
  8014d2:	e8 af 01 00 00       	call   801686 <open>
  8014d7:	89 c3                	mov    %eax,%ebx
  8014d9:	85 db                	test   %ebx,%ebx
  8014db:	78 1b                	js     8014f8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e4:	89 1c 24             	mov    %ebx,(%esp)
  8014e7:	e8 56 ff ff ff       	call   801442 <fstat>
  8014ec:	89 c6                	mov    %eax,%esi
	close(fd);
  8014ee:	89 1c 24             	mov    %ebx,(%esp)
  8014f1:	e8 bd fb ff ff       	call   8010b3 <close>
	return r;
  8014f6:	89 f0                	mov    %esi,%eax
}
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	5b                   	pop    %ebx
  8014fc:	5e                   	pop    %esi
  8014fd:	5d                   	pop    %ebp
  8014fe:	c3                   	ret    

008014ff <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	56                   	push   %esi
  801503:	53                   	push   %ebx
  801504:	83 ec 10             	sub    $0x10,%esp
  801507:	89 c6                	mov    %eax,%esi
  801509:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80150b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801512:	75 11                	jne    801525 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801514:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80151b:	e8 50 08 00 00       	call   801d70 <ipc_find_env>
  801520:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801525:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80152c:	00 
  80152d:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801534:	00 
  801535:	89 74 24 04          	mov    %esi,0x4(%esp)
  801539:	a1 00 40 80 00       	mov    0x804000,%eax
  80153e:	89 04 24             	mov    %eax,(%esp)
  801541:	e8 e2 07 00 00       	call   801d28 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801546:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80154d:	00 
  80154e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801552:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801559:	e8 6e 07 00 00       	call   801ccc <ipc_recv>
}
  80155e:	83 c4 10             	add    $0x10,%esp
  801561:	5b                   	pop    %ebx
  801562:	5e                   	pop    %esi
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    

00801565 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	53                   	push   %ebx
  801569:	83 ec 14             	sub    $0x14,%esp
  80156c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80156f:	8b 45 08             	mov    0x8(%ebp),%eax
  801572:	8b 40 0c             	mov    0xc(%eax),%eax
  801575:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80157a:	ba 00 00 00 00       	mov    $0x0,%edx
  80157f:	b8 05 00 00 00       	mov    $0x5,%eax
  801584:	e8 76 ff ff ff       	call   8014ff <fsipc>
  801589:	89 c2                	mov    %eax,%edx
  80158b:	85 d2                	test   %edx,%edx
  80158d:	78 2b                	js     8015ba <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80158f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801596:	00 
  801597:	89 1c 24             	mov    %ebx,(%esp)
  80159a:	e8 0c f2 ff ff       	call   8007ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80159f:	a1 80 50 80 00       	mov    0x805080,%eax
  8015a4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015aa:	a1 84 50 80 00       	mov    0x805084,%eax
  8015af:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ba:	83 c4 14             	add    $0x14,%esp
  8015bd:	5b                   	pop    %ebx
  8015be:	5d                   	pop    %ebp
  8015bf:	c3                   	ret    

008015c0 <devfile_flush>:
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8015cc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d6:	b8 06 00 00 00       	mov    $0x6,%eax
  8015db:	e8 1f ff ff ff       	call   8014ff <fsipc>
}
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <devfile_read>:
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	56                   	push   %esi
  8015e6:	53                   	push   %ebx
  8015e7:	83 ec 10             	sub    $0x10,%esp
  8015ea:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8015f3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015f8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801603:	b8 03 00 00 00       	mov    $0x3,%eax
  801608:	e8 f2 fe ff ff       	call   8014ff <fsipc>
  80160d:	89 c3                	mov    %eax,%ebx
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 6a                	js     80167d <devfile_read+0x9b>
	assert(r <= n);
  801613:	39 c6                	cmp    %eax,%esi
  801615:	73 24                	jae    80163b <devfile_read+0x59>
  801617:	c7 44 24 0c 66 24 80 	movl   $0x802466,0xc(%esp)
  80161e:	00 
  80161f:	c7 44 24 08 6d 24 80 	movl   $0x80246d,0x8(%esp)
  801626:	00 
  801627:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80162e:	00 
  80162f:	c7 04 24 82 24 80 00 	movl   $0x802482,(%esp)
  801636:	e8 3b 06 00 00       	call   801c76 <_panic>
	assert(r <= PGSIZE);
  80163b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801640:	7e 24                	jle    801666 <devfile_read+0x84>
  801642:	c7 44 24 0c 8d 24 80 	movl   $0x80248d,0xc(%esp)
  801649:	00 
  80164a:	c7 44 24 08 6d 24 80 	movl   $0x80246d,0x8(%esp)
  801651:	00 
  801652:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801659:	00 
  80165a:	c7 04 24 82 24 80 00 	movl   $0x802482,(%esp)
  801661:	e8 10 06 00 00       	call   801c76 <_panic>
	memmove(buf, &fsipcbuf, r);
  801666:	89 44 24 08          	mov    %eax,0x8(%esp)
  80166a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801671:	00 
  801672:	8b 45 0c             	mov    0xc(%ebp),%eax
  801675:	89 04 24             	mov    %eax,(%esp)
  801678:	e8 29 f3 ff ff       	call   8009a6 <memmove>
}
  80167d:	89 d8                	mov    %ebx,%eax
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	5b                   	pop    %ebx
  801683:	5e                   	pop    %esi
  801684:	5d                   	pop    %ebp
  801685:	c3                   	ret    

00801686 <open>:
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	53                   	push   %ebx
  80168a:	83 ec 24             	sub    $0x24,%esp
  80168d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801690:	89 1c 24             	mov    %ebx,(%esp)
  801693:	e8 b8 f0 ff ff       	call   800750 <strlen>
  801698:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80169d:	7f 60                	jg     8016ff <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80169f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a2:	89 04 24             	mov    %eax,(%esp)
  8016a5:	e8 4d f8 ff ff       	call   800ef7 <fd_alloc>
  8016aa:	89 c2                	mov    %eax,%edx
  8016ac:	85 d2                	test   %edx,%edx
  8016ae:	78 54                	js     801704 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  8016b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016b4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8016bb:	e8 eb f0 ff ff       	call   8007ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8016d0:	e8 2a fe ff ff       	call   8014ff <fsipc>
  8016d5:	89 c3                	mov    %eax,%ebx
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	79 17                	jns    8016f2 <open+0x6c>
		fd_close(fd, 0);
  8016db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016e2:	00 
  8016e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e6:	89 04 24             	mov    %eax,(%esp)
  8016e9:	e8 44 f9 ff ff       	call   801032 <fd_close>
		return r;
  8016ee:	89 d8                	mov    %ebx,%eax
  8016f0:	eb 12                	jmp    801704 <open+0x7e>
	return fd2num(fd);
  8016f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f5:	89 04 24             	mov    %eax,(%esp)
  8016f8:	e8 d3 f7 ff ff       	call   800ed0 <fd2num>
  8016fd:	eb 05                	jmp    801704 <open+0x7e>
		return -E_BAD_PATH;
  8016ff:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801704:	83 c4 24             	add    $0x24,%esp
  801707:	5b                   	pop    %ebx
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    
  80170a:	66 90                	xchg   %ax,%ax
  80170c:	66 90                	xchg   %ax,%ax
  80170e:	66 90                	xchg   %ax,%ax

00801710 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	56                   	push   %esi
  801714:	53                   	push   %ebx
  801715:	83 ec 10             	sub    $0x10,%esp
  801718:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80171b:	8b 45 08             	mov    0x8(%ebp),%eax
  80171e:	89 04 24             	mov    %eax,(%esp)
  801721:	e8 ba f7 ff ff       	call   800ee0 <fd2data>
  801726:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801728:	c7 44 24 04 99 24 80 	movl   $0x802499,0x4(%esp)
  80172f:	00 
  801730:	89 1c 24             	mov    %ebx,(%esp)
  801733:	e8 73 f0 ff ff       	call   8007ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801738:	8b 46 04             	mov    0x4(%esi),%eax
  80173b:	2b 06                	sub    (%esi),%eax
  80173d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801743:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80174a:	00 00 00 
	stat->st_dev = &devpipe;
  80174d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801754:	30 80 00 
	return 0;
}
  801757:	b8 00 00 00 00       	mov    $0x0,%eax
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	5b                   	pop    %ebx
  801760:	5e                   	pop    %esi
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    

00801763 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	53                   	push   %ebx
  801767:	83 ec 14             	sub    $0x14,%esp
  80176a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80176d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801771:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801778:	e8 83 f5 ff ff       	call   800d00 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80177d:	89 1c 24             	mov    %ebx,(%esp)
  801780:	e8 5b f7 ff ff       	call   800ee0 <fd2data>
  801785:	89 44 24 04          	mov    %eax,0x4(%esp)
  801789:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801790:	e8 6b f5 ff ff       	call   800d00 <sys_page_unmap>
}
  801795:	83 c4 14             	add    $0x14,%esp
  801798:	5b                   	pop    %ebx
  801799:	5d                   	pop    %ebp
  80179a:	c3                   	ret    

0080179b <_pipeisclosed>:
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	57                   	push   %edi
  80179f:	56                   	push   %esi
  8017a0:	53                   	push   %ebx
  8017a1:	83 ec 2c             	sub    $0x2c,%esp
  8017a4:	89 c6                	mov    %eax,%esi
  8017a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  8017a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8017ae:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017b1:	89 34 24             	mov    %esi,(%esp)
  8017b4:	e8 ff 05 00 00       	call   801db8 <pageref>
  8017b9:	89 c7                	mov    %eax,%edi
  8017bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017be:	89 04 24             	mov    %eax,(%esp)
  8017c1:	e8 f2 05 00 00       	call   801db8 <pageref>
  8017c6:	39 c7                	cmp    %eax,%edi
  8017c8:	0f 94 c2             	sete   %dl
  8017cb:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8017ce:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  8017d4:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8017d7:	39 fb                	cmp    %edi,%ebx
  8017d9:	74 21                	je     8017fc <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  8017db:	84 d2                	test   %dl,%dl
  8017dd:	74 ca                	je     8017a9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017df:	8b 51 58             	mov    0x58(%ecx),%edx
  8017e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017e6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ee:	c7 04 24 a0 24 80 00 	movl   $0x8024a0,(%esp)
  8017f5:	e8 5a e9 ff ff       	call   800154 <cprintf>
  8017fa:	eb ad                	jmp    8017a9 <_pipeisclosed+0xe>
}
  8017fc:	83 c4 2c             	add    $0x2c,%esp
  8017ff:	5b                   	pop    %ebx
  801800:	5e                   	pop    %esi
  801801:	5f                   	pop    %edi
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    

00801804 <devpipe_write>:
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	57                   	push   %edi
  801808:	56                   	push   %esi
  801809:	53                   	push   %ebx
  80180a:	83 ec 1c             	sub    $0x1c,%esp
  80180d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801810:	89 34 24             	mov    %esi,(%esp)
  801813:	e8 c8 f6 ff ff       	call   800ee0 <fd2data>
	for (i = 0; i < n; i++) {
  801818:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80181c:	74 61                	je     80187f <devpipe_write+0x7b>
  80181e:	89 c3                	mov    %eax,%ebx
  801820:	bf 00 00 00 00       	mov    $0x0,%edi
  801825:	eb 4a                	jmp    801871 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  801827:	89 da                	mov    %ebx,%edx
  801829:	89 f0                	mov    %esi,%eax
  80182b:	e8 6b ff ff ff       	call   80179b <_pipeisclosed>
  801830:	85 c0                	test   %eax,%eax
  801832:	75 54                	jne    801888 <devpipe_write+0x84>
			sys_yield();
  801834:	e8 01 f4 ff ff       	call   800c3a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801839:	8b 43 04             	mov    0x4(%ebx),%eax
  80183c:	8b 0b                	mov    (%ebx),%ecx
  80183e:	8d 51 20             	lea    0x20(%ecx),%edx
  801841:	39 d0                	cmp    %edx,%eax
  801843:	73 e2                	jae    801827 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801845:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801848:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80184c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80184f:	99                   	cltd   
  801850:	c1 ea 1b             	shr    $0x1b,%edx
  801853:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801856:	83 e1 1f             	and    $0x1f,%ecx
  801859:	29 d1                	sub    %edx,%ecx
  80185b:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80185f:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801863:	83 c0 01             	add    $0x1,%eax
  801866:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801869:	83 c7 01             	add    $0x1,%edi
  80186c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80186f:	74 13                	je     801884 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801871:	8b 43 04             	mov    0x4(%ebx),%eax
  801874:	8b 0b                	mov    (%ebx),%ecx
  801876:	8d 51 20             	lea    0x20(%ecx),%edx
  801879:	39 d0                	cmp    %edx,%eax
  80187b:	73 aa                	jae    801827 <devpipe_write+0x23>
  80187d:	eb c6                	jmp    801845 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  80187f:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  801884:	89 f8                	mov    %edi,%eax
  801886:	eb 05                	jmp    80188d <devpipe_write+0x89>
				return 0;
  801888:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80188d:	83 c4 1c             	add    $0x1c,%esp
  801890:	5b                   	pop    %ebx
  801891:	5e                   	pop    %esi
  801892:	5f                   	pop    %edi
  801893:	5d                   	pop    %ebp
  801894:	c3                   	ret    

00801895 <devpipe_read>:
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	57                   	push   %edi
  801899:	56                   	push   %esi
  80189a:	53                   	push   %ebx
  80189b:	83 ec 1c             	sub    $0x1c,%esp
  80189e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8018a1:	89 3c 24             	mov    %edi,(%esp)
  8018a4:	e8 37 f6 ff ff       	call   800ee0 <fd2data>
	for (i = 0; i < n; i++) {
  8018a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018ad:	74 54                	je     801903 <devpipe_read+0x6e>
  8018af:	89 c3                	mov    %eax,%ebx
  8018b1:	be 00 00 00 00       	mov    $0x0,%esi
  8018b6:	eb 3e                	jmp    8018f6 <devpipe_read+0x61>
				return i;
  8018b8:	89 f0                	mov    %esi,%eax
  8018ba:	eb 55                	jmp    801911 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  8018bc:	89 da                	mov    %ebx,%edx
  8018be:	89 f8                	mov    %edi,%eax
  8018c0:	e8 d6 fe ff ff       	call   80179b <_pipeisclosed>
  8018c5:	85 c0                	test   %eax,%eax
  8018c7:	75 43                	jne    80190c <devpipe_read+0x77>
			sys_yield();
  8018c9:	e8 6c f3 ff ff       	call   800c3a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8018ce:	8b 03                	mov    (%ebx),%eax
  8018d0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018d3:	74 e7                	je     8018bc <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018d5:	99                   	cltd   
  8018d6:	c1 ea 1b             	shr    $0x1b,%edx
  8018d9:	01 d0                	add    %edx,%eax
  8018db:	83 e0 1f             	and    $0x1f,%eax
  8018de:	29 d0                	sub    %edx,%eax
  8018e0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8018e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018e8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8018eb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8018ee:	83 c6 01             	add    $0x1,%esi
  8018f1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018f4:	74 12                	je     801908 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  8018f6:	8b 03                	mov    (%ebx),%eax
  8018f8:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018fb:	75 d8                	jne    8018d5 <devpipe_read+0x40>
			if (i > 0)
  8018fd:	85 f6                	test   %esi,%esi
  8018ff:	75 b7                	jne    8018b8 <devpipe_read+0x23>
  801901:	eb b9                	jmp    8018bc <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  801903:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  801908:	89 f0                	mov    %esi,%eax
  80190a:	eb 05                	jmp    801911 <devpipe_read+0x7c>
				return 0;
  80190c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801911:	83 c4 1c             	add    $0x1c,%esp
  801914:	5b                   	pop    %ebx
  801915:	5e                   	pop    %esi
  801916:	5f                   	pop    %edi
  801917:	5d                   	pop    %ebp
  801918:	c3                   	ret    

00801919 <pipe>:
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	56                   	push   %esi
  80191d:	53                   	push   %ebx
  80191e:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801921:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801924:	89 04 24             	mov    %eax,(%esp)
  801927:	e8 cb f5 ff ff       	call   800ef7 <fd_alloc>
  80192c:	89 c2                	mov    %eax,%edx
  80192e:	85 d2                	test   %edx,%edx
  801930:	0f 88 4d 01 00 00    	js     801a83 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801936:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80193d:	00 
  80193e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801941:	89 44 24 04          	mov    %eax,0x4(%esp)
  801945:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80194c:	e8 08 f3 ff ff       	call   800c59 <sys_page_alloc>
  801951:	89 c2                	mov    %eax,%edx
  801953:	85 d2                	test   %edx,%edx
  801955:	0f 88 28 01 00 00    	js     801a83 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  80195b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80195e:	89 04 24             	mov    %eax,(%esp)
  801961:	e8 91 f5 ff ff       	call   800ef7 <fd_alloc>
  801966:	89 c3                	mov    %eax,%ebx
  801968:	85 c0                	test   %eax,%eax
  80196a:	0f 88 fe 00 00 00    	js     801a6e <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801970:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801977:	00 
  801978:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801986:	e8 ce f2 ff ff       	call   800c59 <sys_page_alloc>
  80198b:	89 c3                	mov    %eax,%ebx
  80198d:	85 c0                	test   %eax,%eax
  80198f:	0f 88 d9 00 00 00    	js     801a6e <pipe+0x155>
	va = fd2data(fd0);
  801995:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801998:	89 04 24             	mov    %eax,(%esp)
  80199b:	e8 40 f5 ff ff       	call   800ee0 <fd2data>
  8019a0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019a2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019a9:	00 
  8019aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b5:	e8 9f f2 ff ff       	call   800c59 <sys_page_alloc>
  8019ba:	89 c3                	mov    %eax,%ebx
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	0f 88 97 00 00 00    	js     801a5b <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c7:	89 04 24             	mov    %eax,(%esp)
  8019ca:	e8 11 f5 ff ff       	call   800ee0 <fd2data>
  8019cf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8019d6:	00 
  8019d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019e2:	00 
  8019e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ee:	e8 ba f2 ff ff       	call   800cad <sys_page_map>
  8019f3:	89 c3                	mov    %eax,%ebx
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	78 52                	js     801a4b <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  8019f9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a02:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a07:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801a0e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a17:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a1c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a26:	89 04 24             	mov    %eax,(%esp)
  801a29:	e8 a2 f4 ff ff       	call   800ed0 <fd2num>
  801a2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a31:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a36:	89 04 24             	mov    %eax,(%esp)
  801a39:	e8 92 f4 ff ff       	call   800ed0 <fd2num>
  801a3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a41:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a44:	b8 00 00 00 00       	mov    $0x0,%eax
  801a49:	eb 38                	jmp    801a83 <pipe+0x16a>
	sys_page_unmap(0, va);
  801a4b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a56:	e8 a5 f2 ff ff       	call   800d00 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801a5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a69:	e8 92 f2 ff ff       	call   800d00 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a7c:	e8 7f f2 ff ff       	call   800d00 <sys_page_unmap>
  801a81:	89 d8                	mov    %ebx,%eax
}
  801a83:	83 c4 30             	add    $0x30,%esp
  801a86:	5b                   	pop    %ebx
  801a87:	5e                   	pop    %esi
  801a88:	5d                   	pop    %ebp
  801a89:	c3                   	ret    

00801a8a <pipeisclosed>:
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a97:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9a:	89 04 24             	mov    %eax,(%esp)
  801a9d:	e8 c9 f4 ff ff       	call   800f6b <fd_lookup>
  801aa2:	89 c2                	mov    %eax,%edx
  801aa4:	85 d2                	test   %edx,%edx
  801aa6:	78 15                	js     801abd <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aab:	89 04 24             	mov    %eax,(%esp)
  801aae:	e8 2d f4 ff ff       	call   800ee0 <fd2data>
	return _pipeisclosed(fd, p);
  801ab3:	89 c2                	mov    %eax,%edx
  801ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab8:	e8 de fc ff ff       	call   80179b <_pipeisclosed>
}
  801abd:	c9                   	leave  
  801abe:	c3                   	ret    
  801abf:	90                   	nop

00801ac0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    

00801aca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801ad0:	c7 44 24 04 b8 24 80 	movl   $0x8024b8,0x4(%esp)
  801ad7:	00 
  801ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801adb:	89 04 24             	mov    %eax,(%esp)
  801ade:	e8 c8 ec ff ff       	call   8007ab <strcpy>
	return 0;
}
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    

00801aea <devcons_write>:
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	57                   	push   %edi
  801aee:	56                   	push   %esi
  801aef:	53                   	push   %ebx
  801af0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801af6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801afa:	74 4a                	je     801b46 <devcons_write+0x5c>
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
  801b01:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b06:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  801b0c:	8b 75 10             	mov    0x10(%ebp),%esi
  801b0f:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  801b11:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801b14:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b19:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b1c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801b20:	03 45 0c             	add    0xc(%ebp),%eax
  801b23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b27:	89 3c 24             	mov    %edi,(%esp)
  801b2a:	e8 77 ee ff ff       	call   8009a6 <memmove>
		sys_cputs(buf, m);
  801b2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b33:	89 3c 24             	mov    %edi,(%esp)
  801b36:	e8 51 f0 ff ff       	call   800b8c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801b3b:	01 f3                	add    %esi,%ebx
  801b3d:	89 d8                	mov    %ebx,%eax
  801b3f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b42:	72 c8                	jb     801b0c <devcons_write+0x22>
  801b44:	eb 05                	jmp    801b4b <devcons_write+0x61>
  801b46:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  801b4b:	89 d8                	mov    %ebx,%eax
  801b4d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5f                   	pop    %edi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    

00801b58 <devcons_read>:
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801b5e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801b63:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b67:	75 07                	jne    801b70 <devcons_read+0x18>
  801b69:	eb 28                	jmp    801b93 <devcons_read+0x3b>
		sys_yield();
  801b6b:	e8 ca f0 ff ff       	call   800c3a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801b70:	e8 35 f0 ff ff       	call   800baa <sys_cgetc>
  801b75:	85 c0                	test   %eax,%eax
  801b77:	74 f2                	je     801b6b <devcons_read+0x13>
	if (c < 0)
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	78 16                	js     801b93 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  801b7d:	83 f8 04             	cmp    $0x4,%eax
  801b80:	74 0c                	je     801b8e <devcons_read+0x36>
	*(char*)vbuf = c;
  801b82:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b85:	88 02                	mov    %al,(%edx)
	return 1;
  801b87:	b8 01 00 00 00       	mov    $0x1,%eax
  801b8c:	eb 05                	jmp    801b93 <devcons_read+0x3b>
		return 0;
  801b8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    

00801b95 <cputchar>:
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ba1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ba8:	00 
  801ba9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bac:	89 04 24             	mov    %eax,(%esp)
  801baf:	e8 d8 ef ff ff       	call   800b8c <sys_cputs>
}
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    

00801bb6 <getchar>:
{
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801bbc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801bc3:	00 
  801bc4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bcb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd2:	e8 3f f6 ff ff       	call   801216 <read>
	if (r < 0)
  801bd7:	85 c0                	test   %eax,%eax
  801bd9:	78 0f                	js     801bea <getchar+0x34>
	if (r < 1)
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	7e 06                	jle    801be5 <getchar+0x2f>
	return c;
  801bdf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801be3:	eb 05                	jmp    801bea <getchar+0x34>
		return -E_EOF;
  801be5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801bea:	c9                   	leave  
  801beb:	c3                   	ret    

00801bec <iscons>:
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bf2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfc:	89 04 24             	mov    %eax,(%esp)
  801bff:	e8 67 f3 ff ff       	call   800f6b <fd_lookup>
  801c04:	85 c0                	test   %eax,%eax
  801c06:	78 11                	js     801c19 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c11:	39 10                	cmp    %edx,(%eax)
  801c13:	0f 94 c0             	sete   %al
  801c16:	0f b6 c0             	movzbl %al,%eax
}
  801c19:	c9                   	leave  
  801c1a:	c3                   	ret    

00801c1b <opencons>:
{
  801c1b:	55                   	push   %ebp
  801c1c:	89 e5                	mov    %esp,%ebp
  801c1e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801c21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c24:	89 04 24             	mov    %eax,(%esp)
  801c27:	e8 cb f2 ff ff       	call   800ef7 <fd_alloc>
		return r;
  801c2c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	78 40                	js     801c72 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c32:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c39:	00 
  801c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c48:	e8 0c f0 ff ff       	call   800c59 <sys_page_alloc>
		return r;
  801c4d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c4f:	85 c0                	test   %eax,%eax
  801c51:	78 1f                	js     801c72 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801c53:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c61:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c68:	89 04 24             	mov    %eax,(%esp)
  801c6b:	e8 60 f2 ff ff       	call   800ed0 <fd2num>
  801c70:	89 c2                	mov    %eax,%edx
}
  801c72:	89 d0                	mov    %edx,%eax
  801c74:	c9                   	leave  
  801c75:	c3                   	ret    

00801c76 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	56                   	push   %esi
  801c7a:	53                   	push   %ebx
  801c7b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801c7e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c81:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801c87:	e8 8f ef ff ff       	call   800c1b <sys_getenvid>
  801c8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c93:	8b 55 08             	mov    0x8(%ebp),%edx
  801c96:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c9a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca2:	c7 04 24 c4 24 80 00 	movl   $0x8024c4,(%esp)
  801ca9:	e8 a6 e4 ff ff       	call   800154 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801cae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cb2:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb5:	89 04 24             	mov    %eax,(%esp)
  801cb8:	e8 36 e4 ff ff       	call   8000f3 <vcprintf>
	cprintf("\n");
  801cbd:	c7 04 24 bc 20 80 00 	movl   $0x8020bc,(%esp)
  801cc4:	e8 8b e4 ff ff       	call   800154 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801cc9:	cc                   	int3   
  801cca:	eb fd                	jmp    801cc9 <_panic+0x53>

00801ccc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	56                   	push   %esi
  801cd0:	53                   	push   %ebx
  801cd1:	83 ec 10             	sub    $0x10,%esp
  801cd4:	8b 75 08             	mov    0x8(%ebp),%esi
  801cd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  801cda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdd:	89 04 24             	mov    %eax,(%esp)
  801ce0:	e8 8a f1 ff ff       	call   800e6f <sys_ipc_recv>
	if(from_env_store)
  801ce5:	85 f6                	test   %esi,%esi
  801ce7:	74 14                	je     801cfd <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  801ce9:	ba 00 00 00 00       	mov    $0x0,%edx
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	78 09                	js     801cfb <ipc_recv+0x2f>
  801cf2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cf8:	8b 52 74             	mov    0x74(%edx),%edx
  801cfb:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  801cfd:	85 db                	test   %ebx,%ebx
  801cff:	74 14                	je     801d15 <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  801d01:	ba 00 00 00 00       	mov    $0x0,%edx
  801d06:	85 c0                	test   %eax,%eax
  801d08:	78 09                	js     801d13 <ipc_recv+0x47>
  801d0a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d10:	8b 52 78             	mov    0x78(%edx),%edx
  801d13:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  801d15:	85 c0                	test   %eax,%eax
  801d17:	78 08                	js     801d21 <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  801d19:	a1 04 40 80 00       	mov    0x804004,%eax
  801d1e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d21:	83 c4 10             	add    $0x10,%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    

00801d28 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	57                   	push   %edi
  801d2c:	56                   	push   %esi
  801d2d:	53                   	push   %ebx
  801d2e:	83 ec 1c             	sub    $0x1c,%esp
  801d31:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d34:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  801d37:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801d3c:	eb 0c                	jmp    801d4a <ipc_send+0x22>
		failed_cnt++;
  801d3e:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  801d41:	84 db                	test   %bl,%bl
  801d43:	75 05                	jne    801d4a <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  801d45:	e8 f0 ee ff ff       	call   800c3a <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801d4a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d51:	8b 45 10             	mov    0x10(%ebp),%eax
  801d54:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d58:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d5c:	89 3c 24             	mov    %edi,(%esp)
  801d5f:	e8 e8 f0 ff ff       	call   800e4c <sys_ipc_try_send>
  801d64:	85 c0                	test   %eax,%eax
  801d66:	78 d6                	js     801d3e <ipc_send+0x16>
	}
}
  801d68:	83 c4 1c             	add    $0x1c,%esp
  801d6b:	5b                   	pop    %ebx
  801d6c:	5e                   	pop    %esi
  801d6d:	5f                   	pop    %edi
  801d6e:	5d                   	pop    %ebp
  801d6f:	c3                   	ret    

00801d70 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d76:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801d7b:	39 c8                	cmp    %ecx,%eax
  801d7d:	74 17                	je     801d96 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  801d7f:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801d84:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d87:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d8d:	8b 52 50             	mov    0x50(%edx),%edx
  801d90:	39 ca                	cmp    %ecx,%edx
  801d92:	75 14                	jne    801da8 <ipc_find_env+0x38>
  801d94:	eb 05                	jmp    801d9b <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  801d96:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  801d9b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d9e:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801da3:	8b 40 40             	mov    0x40(%eax),%eax
  801da6:	eb 0e                	jmp    801db6 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  801da8:	83 c0 01             	add    $0x1,%eax
  801dab:	3d 00 04 00 00       	cmp    $0x400,%eax
  801db0:	75 d2                	jne    801d84 <ipc_find_env+0x14>
	return 0;
  801db2:	66 b8 00 00          	mov    $0x0,%ax
}
  801db6:	5d                   	pop    %ebp
  801db7:	c3                   	ret    

00801db8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dbe:	89 d0                	mov    %edx,%eax
  801dc0:	c1 e8 16             	shr    $0x16,%eax
  801dc3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801dca:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801dcf:	f6 c1 01             	test   $0x1,%cl
  801dd2:	74 1d                	je     801df1 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801dd4:	c1 ea 0c             	shr    $0xc,%edx
  801dd7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dde:	f6 c2 01             	test   $0x1,%dl
  801de1:	74 0e                	je     801df1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801de3:	c1 ea 0c             	shr    $0xc,%edx
  801de6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ded:	ef 
  801dee:	0f b7 c0             	movzwl %ax,%eax
}
  801df1:	5d                   	pop    %ebp
  801df2:	c3                   	ret    
  801df3:	66 90                	xchg   %ax,%ax
  801df5:	66 90                	xchg   %ax,%ax
  801df7:	66 90                	xchg   %ax,%ax
  801df9:	66 90                	xchg   %ax,%ax
  801dfb:	66 90                	xchg   %ax,%ax
  801dfd:	66 90                	xchg   %ax,%ax
  801dff:	90                   	nop

00801e00 <__udivdi3>:
  801e00:	55                   	push   %ebp
  801e01:	57                   	push   %edi
  801e02:	56                   	push   %esi
  801e03:	83 ec 0c             	sub    $0xc,%esp
  801e06:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e0a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801e0e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801e12:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e16:	85 c0                	test   %eax,%eax
  801e18:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e1c:	89 ea                	mov    %ebp,%edx
  801e1e:	89 0c 24             	mov    %ecx,(%esp)
  801e21:	75 2d                	jne    801e50 <__udivdi3+0x50>
  801e23:	39 e9                	cmp    %ebp,%ecx
  801e25:	77 61                	ja     801e88 <__udivdi3+0x88>
  801e27:	85 c9                	test   %ecx,%ecx
  801e29:	89 ce                	mov    %ecx,%esi
  801e2b:	75 0b                	jne    801e38 <__udivdi3+0x38>
  801e2d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e32:	31 d2                	xor    %edx,%edx
  801e34:	f7 f1                	div    %ecx
  801e36:	89 c6                	mov    %eax,%esi
  801e38:	31 d2                	xor    %edx,%edx
  801e3a:	89 e8                	mov    %ebp,%eax
  801e3c:	f7 f6                	div    %esi
  801e3e:	89 c5                	mov    %eax,%ebp
  801e40:	89 f8                	mov    %edi,%eax
  801e42:	f7 f6                	div    %esi
  801e44:	89 ea                	mov    %ebp,%edx
  801e46:	83 c4 0c             	add    $0xc,%esp
  801e49:	5e                   	pop    %esi
  801e4a:	5f                   	pop    %edi
  801e4b:	5d                   	pop    %ebp
  801e4c:	c3                   	ret    
  801e4d:	8d 76 00             	lea    0x0(%esi),%esi
  801e50:	39 e8                	cmp    %ebp,%eax
  801e52:	77 24                	ja     801e78 <__udivdi3+0x78>
  801e54:	0f bd e8             	bsr    %eax,%ebp
  801e57:	83 f5 1f             	xor    $0x1f,%ebp
  801e5a:	75 3c                	jne    801e98 <__udivdi3+0x98>
  801e5c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e60:	39 34 24             	cmp    %esi,(%esp)
  801e63:	0f 86 9f 00 00 00    	jbe    801f08 <__udivdi3+0x108>
  801e69:	39 d0                	cmp    %edx,%eax
  801e6b:	0f 82 97 00 00 00    	jb     801f08 <__udivdi3+0x108>
  801e71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e78:	31 d2                	xor    %edx,%edx
  801e7a:	31 c0                	xor    %eax,%eax
  801e7c:	83 c4 0c             	add    $0xc,%esp
  801e7f:	5e                   	pop    %esi
  801e80:	5f                   	pop    %edi
  801e81:	5d                   	pop    %ebp
  801e82:	c3                   	ret    
  801e83:	90                   	nop
  801e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e88:	89 f8                	mov    %edi,%eax
  801e8a:	f7 f1                	div    %ecx
  801e8c:	31 d2                	xor    %edx,%edx
  801e8e:	83 c4 0c             	add    $0xc,%esp
  801e91:	5e                   	pop    %esi
  801e92:	5f                   	pop    %edi
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    
  801e95:	8d 76 00             	lea    0x0(%esi),%esi
  801e98:	89 e9                	mov    %ebp,%ecx
  801e9a:	8b 3c 24             	mov    (%esp),%edi
  801e9d:	d3 e0                	shl    %cl,%eax
  801e9f:	89 c6                	mov    %eax,%esi
  801ea1:	b8 20 00 00 00       	mov    $0x20,%eax
  801ea6:	29 e8                	sub    %ebp,%eax
  801ea8:	89 c1                	mov    %eax,%ecx
  801eaa:	d3 ef                	shr    %cl,%edi
  801eac:	89 e9                	mov    %ebp,%ecx
  801eae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801eb2:	8b 3c 24             	mov    (%esp),%edi
  801eb5:	09 74 24 08          	or     %esi,0x8(%esp)
  801eb9:	89 d6                	mov    %edx,%esi
  801ebb:	d3 e7                	shl    %cl,%edi
  801ebd:	89 c1                	mov    %eax,%ecx
  801ebf:	89 3c 24             	mov    %edi,(%esp)
  801ec2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ec6:	d3 ee                	shr    %cl,%esi
  801ec8:	89 e9                	mov    %ebp,%ecx
  801eca:	d3 e2                	shl    %cl,%edx
  801ecc:	89 c1                	mov    %eax,%ecx
  801ece:	d3 ef                	shr    %cl,%edi
  801ed0:	09 d7                	or     %edx,%edi
  801ed2:	89 f2                	mov    %esi,%edx
  801ed4:	89 f8                	mov    %edi,%eax
  801ed6:	f7 74 24 08          	divl   0x8(%esp)
  801eda:	89 d6                	mov    %edx,%esi
  801edc:	89 c7                	mov    %eax,%edi
  801ede:	f7 24 24             	mull   (%esp)
  801ee1:	39 d6                	cmp    %edx,%esi
  801ee3:	89 14 24             	mov    %edx,(%esp)
  801ee6:	72 30                	jb     801f18 <__udivdi3+0x118>
  801ee8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801eec:	89 e9                	mov    %ebp,%ecx
  801eee:	d3 e2                	shl    %cl,%edx
  801ef0:	39 c2                	cmp    %eax,%edx
  801ef2:	73 05                	jae    801ef9 <__udivdi3+0xf9>
  801ef4:	3b 34 24             	cmp    (%esp),%esi
  801ef7:	74 1f                	je     801f18 <__udivdi3+0x118>
  801ef9:	89 f8                	mov    %edi,%eax
  801efb:	31 d2                	xor    %edx,%edx
  801efd:	e9 7a ff ff ff       	jmp    801e7c <__udivdi3+0x7c>
  801f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f08:	31 d2                	xor    %edx,%edx
  801f0a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f0f:	e9 68 ff ff ff       	jmp    801e7c <__udivdi3+0x7c>
  801f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f18:	8d 47 ff             	lea    -0x1(%edi),%eax
  801f1b:	31 d2                	xor    %edx,%edx
  801f1d:	83 c4 0c             	add    $0xc,%esp
  801f20:	5e                   	pop    %esi
  801f21:	5f                   	pop    %edi
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    
  801f24:	66 90                	xchg   %ax,%ax
  801f26:	66 90                	xchg   %ax,%ax
  801f28:	66 90                	xchg   %ax,%ax
  801f2a:	66 90                	xchg   %ax,%ax
  801f2c:	66 90                	xchg   %ax,%ax
  801f2e:	66 90                	xchg   %ax,%ax

00801f30 <__umoddi3>:
  801f30:	55                   	push   %ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	83 ec 14             	sub    $0x14,%esp
  801f36:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f3a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f3e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801f42:	89 c7                	mov    %eax,%edi
  801f44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f48:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f4c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801f50:	89 34 24             	mov    %esi,(%esp)
  801f53:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f57:	85 c0                	test   %eax,%eax
  801f59:	89 c2                	mov    %eax,%edx
  801f5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f5f:	75 17                	jne    801f78 <__umoddi3+0x48>
  801f61:	39 fe                	cmp    %edi,%esi
  801f63:	76 4b                	jbe    801fb0 <__umoddi3+0x80>
  801f65:	89 c8                	mov    %ecx,%eax
  801f67:	89 fa                	mov    %edi,%edx
  801f69:	f7 f6                	div    %esi
  801f6b:	89 d0                	mov    %edx,%eax
  801f6d:	31 d2                	xor    %edx,%edx
  801f6f:	83 c4 14             	add    $0x14,%esp
  801f72:	5e                   	pop    %esi
  801f73:	5f                   	pop    %edi
  801f74:	5d                   	pop    %ebp
  801f75:	c3                   	ret    
  801f76:	66 90                	xchg   %ax,%ax
  801f78:	39 f8                	cmp    %edi,%eax
  801f7a:	77 54                	ja     801fd0 <__umoddi3+0xa0>
  801f7c:	0f bd e8             	bsr    %eax,%ebp
  801f7f:	83 f5 1f             	xor    $0x1f,%ebp
  801f82:	75 5c                	jne    801fe0 <__umoddi3+0xb0>
  801f84:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801f88:	39 3c 24             	cmp    %edi,(%esp)
  801f8b:	0f 87 e7 00 00 00    	ja     802078 <__umoddi3+0x148>
  801f91:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f95:	29 f1                	sub    %esi,%ecx
  801f97:	19 c7                	sbb    %eax,%edi
  801f99:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f9d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fa1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fa5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801fa9:	83 c4 14             	add    $0x14,%esp
  801fac:	5e                   	pop    %esi
  801fad:	5f                   	pop    %edi
  801fae:	5d                   	pop    %ebp
  801faf:	c3                   	ret    
  801fb0:	85 f6                	test   %esi,%esi
  801fb2:	89 f5                	mov    %esi,%ebp
  801fb4:	75 0b                	jne    801fc1 <__umoddi3+0x91>
  801fb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fbb:	31 d2                	xor    %edx,%edx
  801fbd:	f7 f6                	div    %esi
  801fbf:	89 c5                	mov    %eax,%ebp
  801fc1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fc5:	31 d2                	xor    %edx,%edx
  801fc7:	f7 f5                	div    %ebp
  801fc9:	89 c8                	mov    %ecx,%eax
  801fcb:	f7 f5                	div    %ebp
  801fcd:	eb 9c                	jmp    801f6b <__umoddi3+0x3b>
  801fcf:	90                   	nop
  801fd0:	89 c8                	mov    %ecx,%eax
  801fd2:	89 fa                	mov    %edi,%edx
  801fd4:	83 c4 14             	add    $0x14,%esp
  801fd7:	5e                   	pop    %esi
  801fd8:	5f                   	pop    %edi
  801fd9:	5d                   	pop    %ebp
  801fda:	c3                   	ret    
  801fdb:	90                   	nop
  801fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fe0:	8b 04 24             	mov    (%esp),%eax
  801fe3:	be 20 00 00 00       	mov    $0x20,%esi
  801fe8:	89 e9                	mov    %ebp,%ecx
  801fea:	29 ee                	sub    %ebp,%esi
  801fec:	d3 e2                	shl    %cl,%edx
  801fee:	89 f1                	mov    %esi,%ecx
  801ff0:	d3 e8                	shr    %cl,%eax
  801ff2:	89 e9                	mov    %ebp,%ecx
  801ff4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff8:	8b 04 24             	mov    (%esp),%eax
  801ffb:	09 54 24 04          	or     %edx,0x4(%esp)
  801fff:	89 fa                	mov    %edi,%edx
  802001:	d3 e0                	shl    %cl,%eax
  802003:	89 f1                	mov    %esi,%ecx
  802005:	89 44 24 08          	mov    %eax,0x8(%esp)
  802009:	8b 44 24 10          	mov    0x10(%esp),%eax
  80200d:	d3 ea                	shr    %cl,%edx
  80200f:	89 e9                	mov    %ebp,%ecx
  802011:	d3 e7                	shl    %cl,%edi
  802013:	89 f1                	mov    %esi,%ecx
  802015:	d3 e8                	shr    %cl,%eax
  802017:	89 e9                	mov    %ebp,%ecx
  802019:	09 f8                	or     %edi,%eax
  80201b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80201f:	f7 74 24 04          	divl   0x4(%esp)
  802023:	d3 e7                	shl    %cl,%edi
  802025:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802029:	89 d7                	mov    %edx,%edi
  80202b:	f7 64 24 08          	mull   0x8(%esp)
  80202f:	39 d7                	cmp    %edx,%edi
  802031:	89 c1                	mov    %eax,%ecx
  802033:	89 14 24             	mov    %edx,(%esp)
  802036:	72 2c                	jb     802064 <__umoddi3+0x134>
  802038:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80203c:	72 22                	jb     802060 <__umoddi3+0x130>
  80203e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802042:	29 c8                	sub    %ecx,%eax
  802044:	19 d7                	sbb    %edx,%edi
  802046:	89 e9                	mov    %ebp,%ecx
  802048:	89 fa                	mov    %edi,%edx
  80204a:	d3 e8                	shr    %cl,%eax
  80204c:	89 f1                	mov    %esi,%ecx
  80204e:	d3 e2                	shl    %cl,%edx
  802050:	89 e9                	mov    %ebp,%ecx
  802052:	d3 ef                	shr    %cl,%edi
  802054:	09 d0                	or     %edx,%eax
  802056:	89 fa                	mov    %edi,%edx
  802058:	83 c4 14             	add    $0x14,%esp
  80205b:	5e                   	pop    %esi
  80205c:	5f                   	pop    %edi
  80205d:	5d                   	pop    %ebp
  80205e:	c3                   	ret    
  80205f:	90                   	nop
  802060:	39 d7                	cmp    %edx,%edi
  802062:	75 da                	jne    80203e <__umoddi3+0x10e>
  802064:	8b 14 24             	mov    (%esp),%edx
  802067:	89 c1                	mov    %eax,%ecx
  802069:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80206d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802071:	eb cb                	jmp    80203e <__umoddi3+0x10e>
  802073:	90                   	nop
  802074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802078:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80207c:	0f 82 0f ff ff ff    	jb     801f91 <__umoddi3+0x61>
  802082:	e9 1a ff ff ff       	jmp    801fa1 <__umoddi3+0x71>
