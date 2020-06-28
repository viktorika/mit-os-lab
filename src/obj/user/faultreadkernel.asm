
obj/user/faultreadkernel：     文件格式 elf32-i386


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
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800042:	c7 04 24 60 11 80 00 	movl   $0x801160,(%esp)
  800049:	e8 01 01 00 00       	call   80014f <cprintf>
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
  800070:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 db                	test   %ebx,%ebx
  800077:	7e 07                	jle    800080 <libmain+0x30>
		binaryname = argv[0];
  800079:	8b 06                	mov    (%esi),%eax
  80007b:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 1f 0b 00 00       	call   800bc9 <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	53                   	push   %ebx
  8000b0:	83 ec 14             	sub    $0x14,%esp
  8000b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b6:	8b 13                	mov    (%ebx),%edx
  8000b8:	8d 42 01             	lea    0x1(%edx),%eax
  8000bb:	89 03                	mov    %eax,(%ebx)
  8000bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c9:	75 19                	jne    8000e4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000cb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000d2:	00 
  8000d3:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d6:	89 04 24             	mov    %eax,(%esp)
  8000d9:	e8 ae 0a 00 00       	call   800b8c <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000e4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e8:	83 c4 14             	add    $0x14,%esp
  8000eb:	5b                   	pop    %ebx
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fe:	00 00 00 
	b.cnt = 0;
  800101:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800108:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800112:	8b 45 08             	mov    0x8(%ebp),%eax
  800115:	89 44 24 08          	mov    %eax,0x8(%esp)
  800119:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800123:	c7 04 24 ac 00 80 00 	movl   $0x8000ac,(%esp)
  80012a:	e8 b5 01 00 00       	call   8002e4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800135:	89 44 24 04          	mov    %eax,0x4(%esp)
  800139:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013f:	89 04 24             	mov    %eax,(%esp)
  800142:	e8 45 0a 00 00       	call   800b8c <sys_cputs>

	return b.cnt;
}
  800147:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800155:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015c:	8b 45 08             	mov    0x8(%ebp),%eax
  80015f:	89 04 24             	mov    %eax,(%esp)
  800162:	e8 87 ff ff ff       	call   8000ee <vcprintf>
	va_end(ap);

	return cnt;
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    
  800169:	66 90                	xchg   %ax,%ax
  80016b:	66 90                	xchg   %ax,%ax
  80016d:	66 90                	xchg   %ax,%ax
  80016f:	90                   	nop

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
  8001ec:	e8 df 0c 00 00       	call   800ed0 <__udivdi3>
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
  800245:	e8 b6 0d 00 00       	call   801000 <__umoddi3>
  80024a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80024e:	0f be 80 91 11 80 00 	movsbl 0x801191(%eax),%eax
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
  80036c:	ff 24 85 60 12 80 00 	jmp    *0x801260(,%eax,4)
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
  80041a:	83 f8 08             	cmp    $0x8,%eax
  80041d:	7f 0b                	jg     80042a <vprintfmt+0x146>
  80041f:	8b 14 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 20                	jne    80044a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80042a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042e:	c7 44 24 08 a9 11 80 	movl   $0x8011a9,0x8(%esp)
  800435:	00 
  800436:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	89 04 24             	mov    %eax,(%esp)
  800440:	e8 77 fe ff ff       	call   8002bc <printfmt>
  800445:	e9 c3 fe ff ff       	jmp    80030d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80044a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044e:	c7 44 24 08 b2 11 80 	movl   $0x8011b2,0x8(%esp)
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
  80047d:	ba a2 11 80 00       	mov    $0x8011a2,%edx
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
  800bf7:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800bfe:	00 
  800bff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c06:	00 
  800c07:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800c0e:	e8 5b 02 00 00       	call   800e6e <_panic>
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
  800c45:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800c89:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800c90:	00 
  800c91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c98:	00 
  800c99:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800ca0:	e8 c9 01 00 00       	call   800e6e <_panic>
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
  800cdc:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800ce3:	00 
  800ce4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ceb:	00 
  800cec:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800cf3:	e8 76 01 00 00       	call   800e6e <_panic>
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
  800d2f:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800d36:	00 
  800d37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3e:	00 
  800d3f:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800d46:	e8 23 01 00 00       	call   800e6e <_panic>
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
  800d82:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800d89:	00 
  800d8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d91:	00 
  800d92:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800d99:	e8 d0 00 00 00       	call   800e6e <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9e:	83 c4 2c             	add    $0x2c,%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800dc7:	7e 28                	jle    800df1 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dcd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dd4:	00 
  800dd5:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800ddc:	00 
  800ddd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de4:	00 
  800de5:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800dec:	e8 7d 00 00 00       	call   800e6e <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df1:	83 c4 2c             	add    $0x2c,%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	57                   	push   %edi
  800dfd:	56                   	push   %esi
  800dfe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dff:	be 00 00 00 00       	mov    $0x0,%esi
  800e04:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e15:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e17:	5b                   	pop    %ebx
  800e18:	5e                   	pop    %esi
  800e19:	5f                   	pop    %edi
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	57                   	push   %edi
  800e20:	56                   	push   %esi
  800e21:	53                   	push   %ebx
  800e22:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e2a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e32:	89 cb                	mov    %ecx,%ebx
  800e34:	89 cf                	mov    %ecx,%edi
  800e36:	89 ce                	mov    %ecx,%esi
  800e38:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	7e 28                	jle    800e66 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e42:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e49:	00 
  800e4a:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800e51:	00 
  800e52:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e59:	00 
  800e5a:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800e61:	e8 08 00 00 00       	call   800e6e <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e66:	83 c4 2c             	add    $0x2c,%esp
  800e69:	5b                   	pop    %ebx
  800e6a:	5e                   	pop    %esi
  800e6b:	5f                   	pop    %edi
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    

00800e6e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	56                   	push   %esi
  800e72:	53                   	push   %ebx
  800e73:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800e76:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e79:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e7f:	e8 97 fd ff ff       	call   800c1b <sys_getenvid>
  800e84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e87:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e92:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e96:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e9a:	c7 04 24 10 14 80 00 	movl   $0x801410,(%esp)
  800ea1:	e8 a9 f2 ff ff       	call   80014f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ea6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800eaa:	8b 45 10             	mov    0x10(%ebp),%eax
  800ead:	89 04 24             	mov    %eax,(%esp)
  800eb0:	e8 39 f2 ff ff       	call   8000ee <vcprintf>
	cprintf("\n");
  800eb5:	c7 04 24 34 14 80 00 	movl   $0x801434,(%esp)
  800ebc:	e8 8e f2 ff ff       	call   80014f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ec1:	cc                   	int3   
  800ec2:	eb fd                	jmp    800ec1 <_panic+0x53>
  800ec4:	66 90                	xchg   %ax,%ax
  800ec6:	66 90                	xchg   %ax,%ax
  800ec8:	66 90                	xchg   %ax,%ax
  800eca:	66 90                	xchg   %ax,%ax
  800ecc:	66 90                	xchg   %ax,%ax
  800ece:	66 90                	xchg   %ax,%ax

00800ed0 <__udivdi3>:
  800ed0:	55                   	push   %ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	83 ec 0c             	sub    $0xc,%esp
  800ed6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800eda:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800ede:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800ee2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800eec:	89 ea                	mov    %ebp,%edx
  800eee:	89 0c 24             	mov    %ecx,(%esp)
  800ef1:	75 2d                	jne    800f20 <__udivdi3+0x50>
  800ef3:	39 e9                	cmp    %ebp,%ecx
  800ef5:	77 61                	ja     800f58 <__udivdi3+0x88>
  800ef7:	85 c9                	test   %ecx,%ecx
  800ef9:	89 ce                	mov    %ecx,%esi
  800efb:	75 0b                	jne    800f08 <__udivdi3+0x38>
  800efd:	b8 01 00 00 00       	mov    $0x1,%eax
  800f02:	31 d2                	xor    %edx,%edx
  800f04:	f7 f1                	div    %ecx
  800f06:	89 c6                	mov    %eax,%esi
  800f08:	31 d2                	xor    %edx,%edx
  800f0a:	89 e8                	mov    %ebp,%eax
  800f0c:	f7 f6                	div    %esi
  800f0e:	89 c5                	mov    %eax,%ebp
  800f10:	89 f8                	mov    %edi,%eax
  800f12:	f7 f6                	div    %esi
  800f14:	89 ea                	mov    %ebp,%edx
  800f16:	83 c4 0c             	add    $0xc,%esp
  800f19:	5e                   	pop    %esi
  800f1a:	5f                   	pop    %edi
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    
  800f1d:	8d 76 00             	lea    0x0(%esi),%esi
  800f20:	39 e8                	cmp    %ebp,%eax
  800f22:	77 24                	ja     800f48 <__udivdi3+0x78>
  800f24:	0f bd e8             	bsr    %eax,%ebp
  800f27:	83 f5 1f             	xor    $0x1f,%ebp
  800f2a:	75 3c                	jne    800f68 <__udivdi3+0x98>
  800f2c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f30:	39 34 24             	cmp    %esi,(%esp)
  800f33:	0f 86 9f 00 00 00    	jbe    800fd8 <__udivdi3+0x108>
  800f39:	39 d0                	cmp    %edx,%eax
  800f3b:	0f 82 97 00 00 00    	jb     800fd8 <__udivdi3+0x108>
  800f41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f48:	31 d2                	xor    %edx,%edx
  800f4a:	31 c0                	xor    %eax,%eax
  800f4c:	83 c4 0c             	add    $0xc,%esp
  800f4f:	5e                   	pop    %esi
  800f50:	5f                   	pop    %edi
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    
  800f53:	90                   	nop
  800f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f58:	89 f8                	mov    %edi,%eax
  800f5a:	f7 f1                	div    %ecx
  800f5c:	31 d2                	xor    %edx,%edx
  800f5e:	83 c4 0c             	add    $0xc,%esp
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    
  800f65:	8d 76 00             	lea    0x0(%esi),%esi
  800f68:	89 e9                	mov    %ebp,%ecx
  800f6a:	8b 3c 24             	mov    (%esp),%edi
  800f6d:	d3 e0                	shl    %cl,%eax
  800f6f:	89 c6                	mov    %eax,%esi
  800f71:	b8 20 00 00 00       	mov    $0x20,%eax
  800f76:	29 e8                	sub    %ebp,%eax
  800f78:	89 c1                	mov    %eax,%ecx
  800f7a:	d3 ef                	shr    %cl,%edi
  800f7c:	89 e9                	mov    %ebp,%ecx
  800f7e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f82:	8b 3c 24             	mov    (%esp),%edi
  800f85:	09 74 24 08          	or     %esi,0x8(%esp)
  800f89:	89 d6                	mov    %edx,%esi
  800f8b:	d3 e7                	shl    %cl,%edi
  800f8d:	89 c1                	mov    %eax,%ecx
  800f8f:	89 3c 24             	mov    %edi,(%esp)
  800f92:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f96:	d3 ee                	shr    %cl,%esi
  800f98:	89 e9                	mov    %ebp,%ecx
  800f9a:	d3 e2                	shl    %cl,%edx
  800f9c:	89 c1                	mov    %eax,%ecx
  800f9e:	d3 ef                	shr    %cl,%edi
  800fa0:	09 d7                	or     %edx,%edi
  800fa2:	89 f2                	mov    %esi,%edx
  800fa4:	89 f8                	mov    %edi,%eax
  800fa6:	f7 74 24 08          	divl   0x8(%esp)
  800faa:	89 d6                	mov    %edx,%esi
  800fac:	89 c7                	mov    %eax,%edi
  800fae:	f7 24 24             	mull   (%esp)
  800fb1:	39 d6                	cmp    %edx,%esi
  800fb3:	89 14 24             	mov    %edx,(%esp)
  800fb6:	72 30                	jb     800fe8 <__udivdi3+0x118>
  800fb8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fbc:	89 e9                	mov    %ebp,%ecx
  800fbe:	d3 e2                	shl    %cl,%edx
  800fc0:	39 c2                	cmp    %eax,%edx
  800fc2:	73 05                	jae    800fc9 <__udivdi3+0xf9>
  800fc4:	3b 34 24             	cmp    (%esp),%esi
  800fc7:	74 1f                	je     800fe8 <__udivdi3+0x118>
  800fc9:	89 f8                	mov    %edi,%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	e9 7a ff ff ff       	jmp    800f4c <__udivdi3+0x7c>
  800fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fd8:	31 d2                	xor    %edx,%edx
  800fda:	b8 01 00 00 00       	mov    $0x1,%eax
  800fdf:	e9 68 ff ff ff       	jmp    800f4c <__udivdi3+0x7c>
  800fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fe8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	83 c4 0c             	add    $0xc,%esp
  800ff0:	5e                   	pop    %esi
  800ff1:	5f                   	pop    %edi
  800ff2:	5d                   	pop    %ebp
  800ff3:	c3                   	ret    
  800ff4:	66 90                	xchg   %ax,%ax
  800ff6:	66 90                	xchg   %ax,%ax
  800ff8:	66 90                	xchg   %ax,%ax
  800ffa:	66 90                	xchg   %ax,%ax
  800ffc:	66 90                	xchg   %ax,%ax
  800ffe:	66 90                	xchg   %ax,%ax

00801000 <__umoddi3>:
  801000:	55                   	push   %ebp
  801001:	57                   	push   %edi
  801002:	56                   	push   %esi
  801003:	83 ec 14             	sub    $0x14,%esp
  801006:	8b 44 24 28          	mov    0x28(%esp),%eax
  80100a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80100e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801012:	89 c7                	mov    %eax,%edi
  801014:	89 44 24 04          	mov    %eax,0x4(%esp)
  801018:	8b 44 24 30          	mov    0x30(%esp),%eax
  80101c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801020:	89 34 24             	mov    %esi,(%esp)
  801023:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801027:	85 c0                	test   %eax,%eax
  801029:	89 c2                	mov    %eax,%edx
  80102b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80102f:	75 17                	jne    801048 <__umoddi3+0x48>
  801031:	39 fe                	cmp    %edi,%esi
  801033:	76 4b                	jbe    801080 <__umoddi3+0x80>
  801035:	89 c8                	mov    %ecx,%eax
  801037:	89 fa                	mov    %edi,%edx
  801039:	f7 f6                	div    %esi
  80103b:	89 d0                	mov    %edx,%eax
  80103d:	31 d2                	xor    %edx,%edx
  80103f:	83 c4 14             	add    $0x14,%esp
  801042:	5e                   	pop    %esi
  801043:	5f                   	pop    %edi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    
  801046:	66 90                	xchg   %ax,%ax
  801048:	39 f8                	cmp    %edi,%eax
  80104a:	77 54                	ja     8010a0 <__umoddi3+0xa0>
  80104c:	0f bd e8             	bsr    %eax,%ebp
  80104f:	83 f5 1f             	xor    $0x1f,%ebp
  801052:	75 5c                	jne    8010b0 <__umoddi3+0xb0>
  801054:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801058:	39 3c 24             	cmp    %edi,(%esp)
  80105b:	0f 87 e7 00 00 00    	ja     801148 <__umoddi3+0x148>
  801061:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801065:	29 f1                	sub    %esi,%ecx
  801067:	19 c7                	sbb    %eax,%edi
  801069:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80106d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801071:	8b 44 24 08          	mov    0x8(%esp),%eax
  801075:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801079:	83 c4 14             	add    $0x14,%esp
  80107c:	5e                   	pop    %esi
  80107d:	5f                   	pop    %edi
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    
  801080:	85 f6                	test   %esi,%esi
  801082:	89 f5                	mov    %esi,%ebp
  801084:	75 0b                	jne    801091 <__umoddi3+0x91>
  801086:	b8 01 00 00 00       	mov    $0x1,%eax
  80108b:	31 d2                	xor    %edx,%edx
  80108d:	f7 f6                	div    %esi
  80108f:	89 c5                	mov    %eax,%ebp
  801091:	8b 44 24 04          	mov    0x4(%esp),%eax
  801095:	31 d2                	xor    %edx,%edx
  801097:	f7 f5                	div    %ebp
  801099:	89 c8                	mov    %ecx,%eax
  80109b:	f7 f5                	div    %ebp
  80109d:	eb 9c                	jmp    80103b <__umoddi3+0x3b>
  80109f:	90                   	nop
  8010a0:	89 c8                	mov    %ecx,%eax
  8010a2:	89 fa                	mov    %edi,%edx
  8010a4:	83 c4 14             	add    $0x14,%esp
  8010a7:	5e                   	pop    %esi
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    
  8010ab:	90                   	nop
  8010ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010b0:	8b 04 24             	mov    (%esp),%eax
  8010b3:	be 20 00 00 00       	mov    $0x20,%esi
  8010b8:	89 e9                	mov    %ebp,%ecx
  8010ba:	29 ee                	sub    %ebp,%esi
  8010bc:	d3 e2                	shl    %cl,%edx
  8010be:	89 f1                	mov    %esi,%ecx
  8010c0:	d3 e8                	shr    %cl,%eax
  8010c2:	89 e9                	mov    %ebp,%ecx
  8010c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c8:	8b 04 24             	mov    (%esp),%eax
  8010cb:	09 54 24 04          	or     %edx,0x4(%esp)
  8010cf:	89 fa                	mov    %edi,%edx
  8010d1:	d3 e0                	shl    %cl,%eax
  8010d3:	89 f1                	mov    %esi,%ecx
  8010d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8010dd:	d3 ea                	shr    %cl,%edx
  8010df:	89 e9                	mov    %ebp,%ecx
  8010e1:	d3 e7                	shl    %cl,%edi
  8010e3:	89 f1                	mov    %esi,%ecx
  8010e5:	d3 e8                	shr    %cl,%eax
  8010e7:	89 e9                	mov    %ebp,%ecx
  8010e9:	09 f8                	or     %edi,%eax
  8010eb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8010ef:	f7 74 24 04          	divl   0x4(%esp)
  8010f3:	d3 e7                	shl    %cl,%edi
  8010f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010f9:	89 d7                	mov    %edx,%edi
  8010fb:	f7 64 24 08          	mull   0x8(%esp)
  8010ff:	39 d7                	cmp    %edx,%edi
  801101:	89 c1                	mov    %eax,%ecx
  801103:	89 14 24             	mov    %edx,(%esp)
  801106:	72 2c                	jb     801134 <__umoddi3+0x134>
  801108:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80110c:	72 22                	jb     801130 <__umoddi3+0x130>
  80110e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801112:	29 c8                	sub    %ecx,%eax
  801114:	19 d7                	sbb    %edx,%edi
  801116:	89 e9                	mov    %ebp,%ecx
  801118:	89 fa                	mov    %edi,%edx
  80111a:	d3 e8                	shr    %cl,%eax
  80111c:	89 f1                	mov    %esi,%ecx
  80111e:	d3 e2                	shl    %cl,%edx
  801120:	89 e9                	mov    %ebp,%ecx
  801122:	d3 ef                	shr    %cl,%edi
  801124:	09 d0                	or     %edx,%eax
  801126:	89 fa                	mov    %edi,%edx
  801128:	83 c4 14             	add    $0x14,%esp
  80112b:	5e                   	pop    %esi
  80112c:	5f                   	pop    %edi
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    
  80112f:	90                   	nop
  801130:	39 d7                	cmp    %edx,%edi
  801132:	75 da                	jne    80110e <__umoddi3+0x10e>
  801134:	8b 14 24             	mov    (%esp),%edx
  801137:	89 c1                	mov    %eax,%ecx
  801139:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80113d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801141:	eb cb                	jmp    80110e <__umoddi3+0x10e>
  801143:	90                   	nop
  801144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801148:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80114c:	0f 82 0f ff ff ff    	jb     801061 <__umoddi3+0x61>
  801152:	e9 1a ff ff ff       	jmp    801071 <__umoddi3+0x71>
