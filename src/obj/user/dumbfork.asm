
obj/user/dumbfork：     文件格式 elf32-i386


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
  80002c:	e8 30 02 00 00       	call   800261 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 20             	sub    $0x20,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80004e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800055:	00 
  800056:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80005a:	89 34 24             	mov    %esi,(%esp)
  80005d:	e8 57 0e 00 00       	call   800eb9 <sys_page_alloc>
  800062:	85 c0                	test   %eax,%eax
  800064:	79 20                	jns    800086 <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  800066:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80006a:	c7 44 24 08 60 13 80 	movl   $0x801360,0x8(%esp)
  800071:	00 
  800072:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800079:	00 
  80007a:	c7 04 24 73 13 80 00 	movl   $0x801373,(%esp)
  800081:	e8 37 02 00 00       	call   8002bd <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800086:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80008d:	00 
  80008e:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800095:	00 
  800096:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80009d:	00 
  80009e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a2:	89 34 24             	mov    %esi,(%esp)
  8000a5:	e8 63 0e 00 00       	call   800f0d <sys_page_map>
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	79 20                	jns    8000ce <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b2:	c7 44 24 08 83 13 80 	movl   $0x801383,0x8(%esp)
  8000b9:	00 
  8000ba:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000c1:	00 
  8000c2:	c7 04 24 73 13 80 00 	movl   $0x801373,(%esp)
  8000c9:	e8 ef 01 00 00       	call   8002bd <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000d5:	00 
  8000d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000da:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000e1:	e8 20 0b 00 00       	call   800c06 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000e6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 66 0e 00 00       	call   800f60 <sys_page_unmap>
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 94 13 80 	movl   $0x801394,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 73 13 80 00 	movl   $0x801373,(%esp)
  800119:	e8 9f 01 00 00       	call   8002bd <_panic>
}
  80011e:	83 c4 20             	add    $0x20,%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <dumbfork>:

envid_t
dumbfork(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80012d:	b8 07 00 00 00       	mov    $0x7,%eax
  800132:	cd 30                	int    $0x30
  800134:	89 c6                	mov    %eax,%esi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800136:	85 c0                	test   %eax,%eax
  800138:	79 20                	jns    80015a <dumbfork+0x35>
		panic("sys_exofork: %e", envid);
  80013a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013e:	c7 44 24 08 a7 13 80 	movl   $0x8013a7,0x8(%esp)
  800145:	00 
  800146:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  80014d:	00 
  80014e:	c7 04 24 73 13 80 00 	movl   $0x801373,(%esp)
  800155:	e8 63 01 00 00       	call   8002bd <_panic>
  80015a:	89 c3                	mov    %eax,%ebx
	if (envid == 0) {
  80015c:	85 c0                	test   %eax,%eax
  80015e:	75 21                	jne    800181 <dumbfork+0x5c>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800160:	e8 16 0d 00 00       	call   800e7b <sys_getenvid>
  800165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800172:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800177:	b8 00 00 00 00       	mov    $0x0,%eax
  80017c:	e9 82 00 00 00       	jmp    800203 <dumbfork+0xde>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800181:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800188:	b8 08 20 80 00       	mov    $0x802008,%eax
  80018d:	3d 00 00 80 00       	cmp    $0x800000,%eax
  800192:	76 25                	jbe    8001b9 <dumbfork+0x94>
  800194:	ba 00 00 80 00       	mov    $0x800000,%edx
		duppage(envid, addr);
  800199:	89 54 24 04          	mov    %edx,0x4(%esp)
  80019d:	89 1c 24             	mov    %ebx,(%esp)
  8001a0:	e8 9b fe ff ff       	call   800040 <duppage>
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8001a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001a8:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  8001ae:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8001b1:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  8001b7:	72 e0                	jb     800199 <dumbfork+0x74>

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c5:	89 34 24             	mov    %esi,(%esp)
  8001c8:	e8 73 fe ff ff       	call   800040 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001cd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001d4:	00 
  8001d5:	89 34 24             	mov    %esi,(%esp)
  8001d8:	e8 d6 0d 00 00       	call   800fb3 <sys_env_set_status>
  8001dd:	85 c0                	test   %eax,%eax
  8001df:	79 20                	jns    800201 <dumbfork+0xdc>
		panic("sys_env_set_status: %e", r);
  8001e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e5:	c7 44 24 08 b7 13 80 	movl   $0x8013b7,0x8(%esp)
  8001ec:	00 
  8001ed:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001f4:	00 
  8001f5:	c7 04 24 73 13 80 00 	movl   $0x801373,(%esp)
  8001fc:	e8 bc 00 00 00       	call   8002bd <_panic>

	return envid;
  800201:	89 f0                	mov    %esi,%eax
}
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	5b                   	pop    %ebx
  800207:	5e                   	pop    %esi
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    

0080020a <umain>:
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	83 ec 10             	sub    $0x10,%esp
	who = dumbfork();
  800212:	e8 0e ff ff ff       	call   800125 <dumbfork>
  800217:	89 c6                	mov    %eax,%esi
	for (i = 0; i < (who ? 10 : 20); i++) {
  800219:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021e:	eb 28                	jmp    800248 <umain+0x3e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800220:	b8 d5 13 80 00       	mov    $0x8013d5,%eax
  800225:	eb 05                	jmp    80022c <umain+0x22>
  800227:	b8 ce 13 80 00       	mov    $0x8013ce,%eax
  80022c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800230:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800234:	c7 04 24 db 13 80 00 	movl   $0x8013db,(%esp)
  80023b:	e8 76 01 00 00       	call   8003b6 <cprintf>
		sys_yield();
  800240:	e8 55 0c 00 00       	call   800e9a <sys_yield>
	for (i = 0; i < (who ? 10 : 20); i++) {
  800245:	83 c3 01             	add    $0x1,%ebx
  800248:	85 f6                	test   %esi,%esi
  80024a:	75 07                	jne    800253 <umain+0x49>
  80024c:	83 fb 13             	cmp    $0x13,%ebx
  80024f:	7e cf                	jle    800220 <umain+0x16>
  800251:	eb 05                	jmp    800258 <umain+0x4e>
  800253:	83 fb 09             	cmp    $0x9,%ebx
  800256:	7e cf                	jle    800227 <umain+0x1d>
}
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	5b                   	pop    %ebx
  80025c:	5e                   	pop    %esi
  80025d:	5d                   	pop    %ebp
  80025e:	66 90                	xchg   %ax,%ax
  800260:	c3                   	ret    

00800261 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 10             	sub    $0x10,%esp
  800269:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80026c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80026f:	e8 07 0c 00 00       	call   800e7b <sys_getenvid>
  800274:	25 ff 03 00 00       	and    $0x3ff,%eax
  800279:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80027c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800281:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800286:	85 db                	test   %ebx,%ebx
  800288:	7e 07                	jle    800291 <libmain+0x30>
		binaryname = argv[0];
  80028a:	8b 06                	mov    (%esi),%eax
  80028c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800291:	89 74 24 04          	mov    %esi,0x4(%esp)
  800295:	89 1c 24             	mov    %ebx,(%esp)
  800298:	e8 6d ff ff ff       	call   80020a <umain>

	// exit gracefully
	exit();
  80029d:	e8 07 00 00 00       	call   8002a9 <exit>
}
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	5b                   	pop    %ebx
  8002a6:	5e                   	pop    %esi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002b6:	e8 6e 0b 00 00       	call   800e29 <sys_env_destroy>
}
  8002bb:	c9                   	leave  
  8002bc:	c3                   	ret    

008002bd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002c8:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002ce:	e8 a8 0b 00 00       	call   800e7b <sys_getenvid>
  8002d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002da:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e1:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e9:	c7 04 24 f8 13 80 00 	movl   $0x8013f8,(%esp)
  8002f0:	e8 c1 00 00 00       	call   8003b6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fc:	89 04 24             	mov    %eax,(%esp)
  8002ff:	e8 51 00 00 00       	call   800355 <vcprintf>
	cprintf("\n");
  800304:	c7 04 24 eb 13 80 00 	movl   $0x8013eb,(%esp)
  80030b:	e8 a6 00 00 00       	call   8003b6 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800310:	cc                   	int3   
  800311:	eb fd                	jmp    800310 <_panic+0x53>

00800313 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	53                   	push   %ebx
  800317:	83 ec 14             	sub    $0x14,%esp
  80031a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031d:	8b 13                	mov    (%ebx),%edx
  80031f:	8d 42 01             	lea    0x1(%edx),%eax
  800322:	89 03                	mov    %eax,(%ebx)
  800324:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800327:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80032b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800330:	75 19                	jne    80034b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800332:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800339:	00 
  80033a:	8d 43 08             	lea    0x8(%ebx),%eax
  80033d:	89 04 24             	mov    %eax,(%esp)
  800340:	e8 a7 0a 00 00       	call   800dec <sys_cputs>
		b->idx = 0;
  800345:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80034b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80034f:	83 c4 14             	add    $0x14,%esp
  800352:	5b                   	pop    %ebx
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80035e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800365:	00 00 00 
	b.cnt = 0;
  800368:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80036f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800372:	8b 45 0c             	mov    0xc(%ebp),%eax
  800375:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800379:	8b 45 08             	mov    0x8(%ebp),%eax
  80037c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800380:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800386:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038a:	c7 04 24 13 03 80 00 	movl   $0x800313,(%esp)
  800391:	e8 ae 01 00 00       	call   800544 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800396:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80039c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003a6:	89 04 24             	mov    %eax,(%esp)
  8003a9:	e8 3e 0a 00 00       	call   800dec <sys_cputs>

	return b.cnt;
}
  8003ae:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003b4:	c9                   	leave  
  8003b5:	c3                   	ret    

008003b6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003bc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c6:	89 04 24             	mov    %eax,(%esp)
  8003c9:	e8 87 ff ff ff       	call   800355 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ce:	c9                   	leave  
  8003cf:	c3                   	ret    

008003d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	56                   	push   %esi
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 3c             	sub    $0x3c,%esp
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	89 d7                	mov    %edx,%edi
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003e7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8003ea:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003f8:	39 f1                	cmp    %esi,%ecx
  8003fa:	72 14                	jb     800410 <printnum+0x40>
  8003fc:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8003ff:	76 0f                	jbe    800410 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 70 ff             	lea    -0x1(%eax),%esi
  800407:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80040a:	85 f6                	test   %esi,%esi
  80040c:	7f 60                	jg     80046e <printnum+0x9e>
  80040e:	eb 72                	jmp    800482 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800410:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800413:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800417:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80041a:	8d 51 ff             	lea    -0x1(%ecx),%edx
  80041d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800421:	89 44 24 08          	mov    %eax,0x8(%esp)
  800425:	8b 44 24 08          	mov    0x8(%esp),%eax
  800429:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80042d:	89 c3                	mov    %eax,%ebx
  80042f:	89 d6                	mov    %edx,%esi
  800431:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800434:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800437:	89 54 24 08          	mov    %edx,0x8(%esp)
  80043b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80043f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800442:	89 04 24             	mov    %eax,(%esp)
  800445:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044c:	e8 7f 0c 00 00       	call   8010d0 <__udivdi3>
  800451:	89 d9                	mov    %ebx,%ecx
  800453:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800457:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80045b:	89 04 24             	mov    %eax,(%esp)
  80045e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800462:	89 fa                	mov    %edi,%edx
  800464:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800467:	e8 64 ff ff ff       	call   8003d0 <printnum>
  80046c:	eb 14                	jmp    800482 <printnum+0xb2>
			putch(padc, putdat);
  80046e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800472:	8b 45 18             	mov    0x18(%ebp),%eax
  800475:	89 04 24             	mov    %eax,(%esp)
  800478:	ff d3                	call   *%ebx
		while (--width > 0)
  80047a:	83 ee 01             	sub    $0x1,%esi
  80047d:	75 ef                	jne    80046e <printnum+0x9e>
  80047f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800482:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800486:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80048a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80048d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800490:	89 44 24 08          	mov    %eax,0x8(%esp)
  800494:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800498:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80049b:	89 04 24             	mov    %eax,(%esp)
  80049e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a5:	e8 56 0d 00 00       	call   801200 <__umoddi3>
  8004aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ae:	0f be 80 1c 14 80 00 	movsbl 0x80141c(%eax),%eax
  8004b5:	89 04 24             	mov    %eax,(%esp)
  8004b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004bb:	ff d0                	call   *%eax
}
  8004bd:	83 c4 3c             	add    $0x3c,%esp
  8004c0:	5b                   	pop    %ebx
  8004c1:	5e                   	pop    %esi
  8004c2:	5f                   	pop    %edi
  8004c3:	5d                   	pop    %ebp
  8004c4:	c3                   	ret    

008004c5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c5:	55                   	push   %ebp
  8004c6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c8:	83 fa 01             	cmp    $0x1,%edx
  8004cb:	7e 0e                	jle    8004db <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004cd:	8b 10                	mov    (%eax),%edx
  8004cf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d2:	89 08                	mov    %ecx,(%eax)
  8004d4:	8b 02                	mov    (%edx),%eax
  8004d6:	8b 52 04             	mov    0x4(%edx),%edx
  8004d9:	eb 22                	jmp    8004fd <getuint+0x38>
	else if (lflag)
  8004db:	85 d2                	test   %edx,%edx
  8004dd:	74 10                	je     8004ef <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004df:	8b 10                	mov    (%eax),%edx
  8004e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e4:	89 08                	mov    %ecx,(%eax)
  8004e6:	8b 02                	mov    (%edx),%eax
  8004e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ed:	eb 0e                	jmp    8004fd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ef:	8b 10                	mov    (%eax),%edx
  8004f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f4:	89 08                	mov    %ecx,(%eax)
  8004f6:	8b 02                	mov    (%edx),%eax
  8004f8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    

008004ff <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800505:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800509:	8b 10                	mov    (%eax),%edx
  80050b:	3b 50 04             	cmp    0x4(%eax),%edx
  80050e:	73 0a                	jae    80051a <sprintputch+0x1b>
		*b->buf++ = ch;
  800510:	8d 4a 01             	lea    0x1(%edx),%ecx
  800513:	89 08                	mov    %ecx,(%eax)
  800515:	8b 45 08             	mov    0x8(%ebp),%eax
  800518:	88 02                	mov    %al,(%edx)
}
  80051a:	5d                   	pop    %ebp
  80051b:	c3                   	ret    

0080051c <printfmt>:
{
  80051c:	55                   	push   %ebp
  80051d:	89 e5                	mov    %esp,%ebp
  80051f:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  800522:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800525:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800529:	8b 45 10             	mov    0x10(%ebp),%eax
  80052c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800530:	8b 45 0c             	mov    0xc(%ebp),%eax
  800533:	89 44 24 04          	mov    %eax,0x4(%esp)
  800537:	8b 45 08             	mov    0x8(%ebp),%eax
  80053a:	89 04 24             	mov    %eax,(%esp)
  80053d:	e8 02 00 00 00       	call   800544 <vprintfmt>
}
  800542:	c9                   	leave  
  800543:	c3                   	ret    

00800544 <vprintfmt>:
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	57                   	push   %edi
  800548:	56                   	push   %esi
  800549:	53                   	push   %ebx
  80054a:	83 ec 3c             	sub    $0x3c,%esp
  80054d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800550:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800553:	eb 18                	jmp    80056d <vprintfmt+0x29>
			if (ch == '\0')
  800555:	85 c0                	test   %eax,%eax
  800557:	0f 84 c3 03 00 00    	je     800920 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80055d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800561:	89 04 24             	mov    %eax,(%esp)
  800564:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800567:	89 f3                	mov    %esi,%ebx
  800569:	eb 02                	jmp    80056d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80056b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80056d:	8d 73 01             	lea    0x1(%ebx),%esi
  800570:	0f b6 03             	movzbl (%ebx),%eax
  800573:	83 f8 25             	cmp    $0x25,%eax
  800576:	75 dd                	jne    800555 <vprintfmt+0x11>
  800578:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80057c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800583:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80058a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800591:	ba 00 00 00 00       	mov    $0x0,%edx
  800596:	eb 1d                	jmp    8005b5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800598:	89 de                	mov    %ebx,%esi
			padc = '-';
  80059a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80059e:	eb 15                	jmp    8005b5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	89 de                	mov    %ebx,%esi
			padc = '0';
  8005a2:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8005a6:	eb 0d                	jmp    8005b5 <vprintfmt+0x71>
				width = precision, precision = -1;
  8005a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ae:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8d 5e 01             	lea    0x1(%esi),%ebx
  8005b8:	0f b6 06             	movzbl (%esi),%eax
  8005bb:	0f b6 c8             	movzbl %al,%ecx
  8005be:	83 e8 23             	sub    $0x23,%eax
  8005c1:	3c 55                	cmp    $0x55,%al
  8005c3:	0f 87 2f 03 00 00    	ja     8008f8 <vprintfmt+0x3b4>
  8005c9:	0f b6 c0             	movzbl %al,%eax
  8005cc:	ff 24 85 e0 14 80 00 	jmp    *0x8014e0(,%eax,4)
				precision = precision * 10 + ch - '0';
  8005d3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  8005d9:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8005dd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8005e0:	83 f9 09             	cmp    $0x9,%ecx
  8005e3:	77 50                	ja     800635 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	89 de                	mov    %ebx,%esi
  8005e7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8005ea:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8005ed:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8005f0:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8005f4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005f7:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005fa:	83 fb 09             	cmp    $0x9,%ebx
  8005fd:	76 eb                	jbe    8005ea <vprintfmt+0xa6>
  8005ff:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800602:	eb 33                	jmp    800637 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 48 04             	lea    0x4(%eax),%ecx
  80060a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800612:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800614:	eb 21                	jmp    800637 <vprintfmt+0xf3>
  800616:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800619:	85 c9                	test   %ecx,%ecx
  80061b:	b8 00 00 00 00       	mov    $0x0,%eax
  800620:	0f 49 c1             	cmovns %ecx,%eax
  800623:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800626:	89 de                	mov    %ebx,%esi
  800628:	eb 8b                	jmp    8005b5 <vprintfmt+0x71>
  80062a:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80062c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800633:	eb 80                	jmp    8005b5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800635:	89 de                	mov    %ebx,%esi
			if (width < 0)
  800637:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80063b:	0f 89 74 ff ff ff    	jns    8005b5 <vprintfmt+0x71>
  800641:	e9 62 ff ff ff       	jmp    8005a8 <vprintfmt+0x64>
			lflag++;
  800646:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800649:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80064b:	e9 65 ff ff ff       	jmp    8005b5 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 50 04             	lea    0x4(%eax),%edx
  800656:	89 55 14             	mov    %edx,0x14(%ebp)
  800659:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	89 04 24             	mov    %eax,(%esp)
  800662:	ff 55 08             	call   *0x8(%ebp)
			break;
  800665:	e9 03 ff ff ff       	jmp    80056d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8d 50 04             	lea    0x4(%eax),%edx
  800670:	89 55 14             	mov    %edx,0x14(%ebp)
  800673:	8b 00                	mov    (%eax),%eax
  800675:	99                   	cltd   
  800676:	31 d0                	xor    %edx,%eax
  800678:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80067a:	83 f8 08             	cmp    $0x8,%eax
  80067d:	7f 0b                	jg     80068a <vprintfmt+0x146>
  80067f:	8b 14 85 40 16 80 00 	mov    0x801640(,%eax,4),%edx
  800686:	85 d2                	test   %edx,%edx
  800688:	75 20                	jne    8006aa <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80068a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068e:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  800695:	00 
  800696:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069a:	8b 45 08             	mov    0x8(%ebp),%eax
  80069d:	89 04 24             	mov    %eax,(%esp)
  8006a0:	e8 77 fe ff ff       	call   80051c <printfmt>
  8006a5:	e9 c3 fe ff ff       	jmp    80056d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  8006aa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ae:	c7 44 24 08 3d 14 80 	movl   $0x80143d,0x8(%esp)
  8006b5:	00 
  8006b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bd:	89 04 24             	mov    %eax,(%esp)
  8006c0:	e8 57 fe ff ff       	call   80051c <printfmt>
  8006c5:	e9 a3 fe ff ff       	jmp    80056d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  8006ca:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006cd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8d 50 04             	lea    0x4(%eax),%edx
  8006d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8006db:	85 c0                	test   %eax,%eax
  8006dd:	ba 2d 14 80 00       	mov    $0x80142d,%edx
  8006e2:	0f 45 d0             	cmovne %eax,%edx
  8006e5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8006e8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8006ec:	74 04                	je     8006f2 <vprintfmt+0x1ae>
  8006ee:	85 f6                	test   %esi,%esi
  8006f0:	7f 19                	jg     80070b <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006f5:	8d 70 01             	lea    0x1(%eax),%esi
  8006f8:	0f b6 10             	movzbl (%eax),%edx
  8006fb:	0f be c2             	movsbl %dl,%eax
  8006fe:	85 c0                	test   %eax,%eax
  800700:	0f 85 95 00 00 00    	jne    80079b <vprintfmt+0x257>
  800706:	e9 85 00 00 00       	jmp    800790 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80070b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80070f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800712:	89 04 24             	mov    %eax,(%esp)
  800715:	e8 b8 02 00 00       	call   8009d2 <strnlen>
  80071a:	29 c6                	sub    %eax,%esi
  80071c:	89 f0                	mov    %esi,%eax
  80071e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800721:	85 f6                	test   %esi,%esi
  800723:	7e cd                	jle    8006f2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800725:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800729:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80072c:	89 c3                	mov    %eax,%ebx
  80072e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800732:	89 34 24             	mov    %esi,(%esp)
  800735:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800738:	83 eb 01             	sub    $0x1,%ebx
  80073b:	75 f1                	jne    80072e <vprintfmt+0x1ea>
  80073d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800740:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800743:	eb ad                	jmp    8006f2 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800745:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800749:	74 1e                	je     800769 <vprintfmt+0x225>
  80074b:	0f be d2             	movsbl %dl,%edx
  80074e:	83 ea 20             	sub    $0x20,%edx
  800751:	83 fa 5e             	cmp    $0x5e,%edx
  800754:	76 13                	jbe    800769 <vprintfmt+0x225>
					putch('?', putdat);
  800756:	8b 45 0c             	mov    0xc(%ebp),%eax
  800759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800764:	ff 55 08             	call   *0x8(%ebp)
  800767:	eb 0d                	jmp    800776 <vprintfmt+0x232>
					putch(ch, putdat);
  800769:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800770:	89 04 24             	mov    %eax,(%esp)
  800773:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800776:	83 ef 01             	sub    $0x1,%edi
  800779:	83 c6 01             	add    $0x1,%esi
  80077c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800780:	0f be c2             	movsbl %dl,%eax
  800783:	85 c0                	test   %eax,%eax
  800785:	75 20                	jne    8007a7 <vprintfmt+0x263>
  800787:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80078a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80078d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800790:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800794:	7f 25                	jg     8007bb <vprintfmt+0x277>
  800796:	e9 d2 fd ff ff       	jmp    80056d <vprintfmt+0x29>
  80079b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80079e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007a4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a7:	85 db                	test   %ebx,%ebx
  8007a9:	78 9a                	js     800745 <vprintfmt+0x201>
  8007ab:	83 eb 01             	sub    $0x1,%ebx
  8007ae:	79 95                	jns    800745 <vprintfmt+0x201>
  8007b0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007b3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007b9:	eb d5                	jmp    800790 <vprintfmt+0x24c>
  8007bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007be:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007c1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  8007c4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007cf:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8007d1:	83 eb 01             	sub    $0x1,%ebx
  8007d4:	75 ee                	jne    8007c4 <vprintfmt+0x280>
  8007d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007d9:	e9 8f fd ff ff       	jmp    80056d <vprintfmt+0x29>
	if (lflag >= 2)
  8007de:	83 fa 01             	cmp    $0x1,%edx
  8007e1:	7e 16                	jle    8007f9 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8d 50 08             	lea    0x8(%eax),%edx
  8007e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ec:	8b 50 04             	mov    0x4(%eax),%edx
  8007ef:	8b 00                	mov    (%eax),%eax
  8007f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007f7:	eb 32                	jmp    80082b <vprintfmt+0x2e7>
	else if (lflag)
  8007f9:	85 d2                	test   %edx,%edx
  8007fb:	74 18                	je     800815 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8d 50 04             	lea    0x4(%eax),%edx
  800803:	89 55 14             	mov    %edx,0x14(%ebp)
  800806:	8b 30                	mov    (%eax),%esi
  800808:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80080b:	89 f0                	mov    %esi,%eax
  80080d:	c1 f8 1f             	sar    $0x1f,%eax
  800810:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800813:	eb 16                	jmp    80082b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	8d 50 04             	lea    0x4(%eax),%edx
  80081b:	89 55 14             	mov    %edx,0x14(%ebp)
  80081e:	8b 30                	mov    (%eax),%esi
  800820:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800823:	89 f0                	mov    %esi,%eax
  800825:	c1 f8 1f             	sar    $0x1f,%eax
  800828:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  80082b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80082e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  800831:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800836:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80083a:	0f 89 80 00 00 00    	jns    8008c0 <vprintfmt+0x37c>
				putch('-', putdat);
  800840:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800844:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80084b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80084e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800851:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800854:	f7 d8                	neg    %eax
  800856:	83 d2 00             	adc    $0x0,%edx
  800859:	f7 da                	neg    %edx
			base = 10;
  80085b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800860:	eb 5e                	jmp    8008c0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800862:	8d 45 14             	lea    0x14(%ebp),%eax
  800865:	e8 5b fc ff ff       	call   8004c5 <getuint>
			base = 10;
  80086a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80086f:	eb 4f                	jmp    8008c0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800871:	8d 45 14             	lea    0x14(%ebp),%eax
  800874:	e8 4c fc ff ff       	call   8004c5 <getuint>
			base = 8;
  800879:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80087e:	eb 40                	jmp    8008c0 <vprintfmt+0x37c>
			putch('0', putdat);
  800880:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800884:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80088b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80088e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800892:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800899:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80089c:	8b 45 14             	mov    0x14(%ebp),%eax
  80089f:	8d 50 04             	lea    0x4(%eax),%edx
  8008a2:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8008a5:	8b 00                	mov    (%eax),%eax
  8008a7:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8008ac:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008b1:	eb 0d                	jmp    8008c0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8008b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b6:	e8 0a fc ff ff       	call   8004c5 <getuint>
			base = 16;
  8008bb:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8008c0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008c4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8008c8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8008cb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008cf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008d3:	89 04 24             	mov    %eax,(%esp)
  8008d6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008da:	89 fa                	mov    %edi,%edx
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	e8 ec fa ff ff       	call   8003d0 <printnum>
			break;
  8008e4:	e9 84 fc ff ff       	jmp    80056d <vprintfmt+0x29>
			putch(ch, putdat);
  8008e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ed:	89 0c 24             	mov    %ecx,(%esp)
  8008f0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008f3:	e9 75 fc ff ff       	jmp    80056d <vprintfmt+0x29>
			putch('%', putdat);
  8008f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008fc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800903:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800906:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80090a:	0f 84 5b fc ff ff    	je     80056b <vprintfmt+0x27>
  800910:	89 f3                	mov    %esi,%ebx
  800912:	83 eb 01             	sub    $0x1,%ebx
  800915:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800919:	75 f7                	jne    800912 <vprintfmt+0x3ce>
  80091b:	e9 4d fc ff ff       	jmp    80056d <vprintfmt+0x29>
}
  800920:	83 c4 3c             	add    $0x3c,%esp
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	83 ec 28             	sub    $0x28,%esp
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800934:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800937:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80093b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80093e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800945:	85 c0                	test   %eax,%eax
  800947:	74 30                	je     800979 <vsnprintf+0x51>
  800949:	85 d2                	test   %edx,%edx
  80094b:	7e 2c                	jle    800979 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80094d:	8b 45 14             	mov    0x14(%ebp),%eax
  800950:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800954:	8b 45 10             	mov    0x10(%ebp),%eax
  800957:	89 44 24 08          	mov    %eax,0x8(%esp)
  80095b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80095e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800962:	c7 04 24 ff 04 80 00 	movl   $0x8004ff,(%esp)
  800969:	e8 d6 fb ff ff       	call   800544 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80096e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800971:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800974:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800977:	eb 05                	jmp    80097e <vsnprintf+0x56>
		return -E_INVAL;
  800979:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800986:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800989:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098d:	8b 45 10             	mov    0x10(%ebp),%eax
  800990:	89 44 24 08          	mov    %eax,0x8(%esp)
  800994:	8b 45 0c             	mov    0xc(%ebp),%eax
  800997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	89 04 24             	mov    %eax,(%esp)
  8009a1:	e8 82 ff ff ff       	call   800928 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009a6:	c9                   	leave  
  8009a7:	c3                   	ret    
  8009a8:	66 90                	xchg   %ax,%ax
  8009aa:	66 90                	xchg   %ax,%ax
  8009ac:	66 90                	xchg   %ax,%ax
  8009ae:	66 90                	xchg   %ax,%ax

008009b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b6:	80 3a 00             	cmpb   $0x0,(%edx)
  8009b9:	74 10                	je     8009cb <strlen+0x1b>
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009c0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009c7:	75 f7                	jne    8009c0 <strlen+0x10>
  8009c9:	eb 05                	jmp    8009d0 <strlen+0x20>
  8009cb:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	53                   	push   %ebx
  8009d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009dc:	85 c9                	test   %ecx,%ecx
  8009de:	74 1c                	je     8009fc <strnlen+0x2a>
  8009e0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009e3:	74 1e                	je     800a03 <strnlen+0x31>
  8009e5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009ea:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ec:	39 ca                	cmp    %ecx,%edx
  8009ee:	74 18                	je     800a08 <strnlen+0x36>
  8009f0:	83 c2 01             	add    $0x1,%edx
  8009f3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009f8:	75 f0                	jne    8009ea <strnlen+0x18>
  8009fa:	eb 0c                	jmp    800a08 <strnlen+0x36>
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800a01:	eb 05                	jmp    800a08 <strnlen+0x36>
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800a08:	5b                   	pop    %ebx
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a15:	89 c2                	mov    %eax,%edx
  800a17:	83 c2 01             	add    $0x1,%edx
  800a1a:	83 c1 01             	add    $0x1,%ecx
  800a1d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a21:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a24:	84 db                	test   %bl,%bl
  800a26:	75 ef                	jne    800a17 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a28:	5b                   	pop    %ebx
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	83 ec 08             	sub    $0x8,%esp
  800a32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a35:	89 1c 24             	mov    %ebx,(%esp)
  800a38:	e8 73 ff ff ff       	call   8009b0 <strlen>
	strcpy(dst + len, src);
  800a3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a40:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a44:	01 d8                	add    %ebx,%eax
  800a46:	89 04 24             	mov    %eax,(%esp)
  800a49:	e8 bd ff ff ff       	call   800a0b <strcpy>
	return dst;
}
  800a4e:	89 d8                	mov    %ebx,%eax
  800a50:	83 c4 08             	add    $0x8,%esp
  800a53:	5b                   	pop    %ebx
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a64:	85 db                	test   %ebx,%ebx
  800a66:	74 17                	je     800a7f <strncpy+0x29>
  800a68:	01 f3                	add    %esi,%ebx
  800a6a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	0f b6 02             	movzbl (%edx),%eax
  800a72:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a75:	80 3a 01             	cmpb   $0x1,(%edx)
  800a78:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a7b:	39 d9                	cmp    %ebx,%ecx
  800a7d:	75 ed                	jne    800a6c <strncpy+0x16>
	}
	return ret;
}
  800a7f:	89 f0                	mov    %esi,%eax
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	57                   	push   %edi
  800a89:	56                   	push   %esi
  800a8a:	53                   	push   %ebx
  800a8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a91:	8b 75 10             	mov    0x10(%ebp),%esi
  800a94:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a96:	85 f6                	test   %esi,%esi
  800a98:	74 34                	je     800ace <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800a9a:	83 fe 01             	cmp    $0x1,%esi
  800a9d:	74 26                	je     800ac5 <strlcpy+0x40>
  800a9f:	0f b6 0b             	movzbl (%ebx),%ecx
  800aa2:	84 c9                	test   %cl,%cl
  800aa4:	74 23                	je     800ac9 <strlcpy+0x44>
  800aa6:	83 ee 02             	sub    $0x2,%esi
  800aa9:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  800aae:	83 c0 01             	add    $0x1,%eax
  800ab1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800ab4:	39 f2                	cmp    %esi,%edx
  800ab6:	74 13                	je     800acb <strlcpy+0x46>
  800ab8:	83 c2 01             	add    $0x1,%edx
  800abb:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800abf:	84 c9                	test   %cl,%cl
  800ac1:	75 eb                	jne    800aae <strlcpy+0x29>
  800ac3:	eb 06                	jmp    800acb <strlcpy+0x46>
  800ac5:	89 f8                	mov    %edi,%eax
  800ac7:	eb 02                	jmp    800acb <strlcpy+0x46>
  800ac9:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  800acb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ace:	29 f8                	sub    %edi,%eax
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5f                   	pop    %edi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ade:	0f b6 01             	movzbl (%ecx),%eax
  800ae1:	84 c0                	test   %al,%al
  800ae3:	74 15                	je     800afa <strcmp+0x25>
  800ae5:	3a 02                	cmp    (%edx),%al
  800ae7:	75 11                	jne    800afa <strcmp+0x25>
		p++, q++;
  800ae9:	83 c1 01             	add    $0x1,%ecx
  800aec:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800aef:	0f b6 01             	movzbl (%ecx),%eax
  800af2:	84 c0                	test   %al,%al
  800af4:	74 04                	je     800afa <strcmp+0x25>
  800af6:	3a 02                	cmp    (%edx),%al
  800af8:	74 ef                	je     800ae9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800afa:	0f b6 c0             	movzbl %al,%eax
  800afd:	0f b6 12             	movzbl (%edx),%edx
  800b00:	29 d0                	sub    %edx,%eax
}
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b12:	85 f6                	test   %esi,%esi
  800b14:	74 29                	je     800b3f <strncmp+0x3b>
  800b16:	0f b6 03             	movzbl (%ebx),%eax
  800b19:	84 c0                	test   %al,%al
  800b1b:	74 30                	je     800b4d <strncmp+0x49>
  800b1d:	3a 02                	cmp    (%edx),%al
  800b1f:	75 2c                	jne    800b4d <strncmp+0x49>
  800b21:	8d 43 01             	lea    0x1(%ebx),%eax
  800b24:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b26:	89 c3                	mov    %eax,%ebx
  800b28:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b2b:	39 f0                	cmp    %esi,%eax
  800b2d:	74 17                	je     800b46 <strncmp+0x42>
  800b2f:	0f b6 08             	movzbl (%eax),%ecx
  800b32:	84 c9                	test   %cl,%cl
  800b34:	74 17                	je     800b4d <strncmp+0x49>
  800b36:	83 c0 01             	add    $0x1,%eax
  800b39:	3a 0a                	cmp    (%edx),%cl
  800b3b:	74 e9                	je     800b26 <strncmp+0x22>
  800b3d:	eb 0e                	jmp    800b4d <strncmp+0x49>
	if (n == 0)
		return 0;
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b44:	eb 0f                	jmp    800b55 <strncmp+0x51>
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	eb 08                	jmp    800b55 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b4d:	0f b6 03             	movzbl (%ebx),%eax
  800b50:	0f b6 12             	movzbl (%edx),%edx
  800b53:	29 d0                	sub    %edx,%eax
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	53                   	push   %ebx
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b60:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b63:	0f b6 18             	movzbl (%eax),%ebx
  800b66:	84 db                	test   %bl,%bl
  800b68:	74 1d                	je     800b87 <strchr+0x2e>
  800b6a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800b6c:	38 d3                	cmp    %dl,%bl
  800b6e:	75 06                	jne    800b76 <strchr+0x1d>
  800b70:	eb 1a                	jmp    800b8c <strchr+0x33>
  800b72:	38 ca                	cmp    %cl,%dl
  800b74:	74 16                	je     800b8c <strchr+0x33>
	for (; *s; s++)
  800b76:	83 c0 01             	add    $0x1,%eax
  800b79:	0f b6 10             	movzbl (%eax),%edx
  800b7c:	84 d2                	test   %dl,%dl
  800b7e:	75 f2                	jne    800b72 <strchr+0x19>
			return (char *) s;
	return 0;
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
  800b85:	eb 05                	jmp    800b8c <strchr+0x33>
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	53                   	push   %ebx
  800b93:	8b 45 08             	mov    0x8(%ebp),%eax
  800b96:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b99:	0f b6 18             	movzbl (%eax),%ebx
  800b9c:	84 db                	test   %bl,%bl
  800b9e:	74 16                	je     800bb6 <strfind+0x27>
  800ba0:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800ba2:	38 d3                	cmp    %dl,%bl
  800ba4:	75 06                	jne    800bac <strfind+0x1d>
  800ba6:	eb 0e                	jmp    800bb6 <strfind+0x27>
  800ba8:	38 ca                	cmp    %cl,%dl
  800baa:	74 0a                	je     800bb6 <strfind+0x27>
	for (; *s; s++)
  800bac:	83 c0 01             	add    $0x1,%eax
  800baf:	0f b6 10             	movzbl (%eax),%edx
  800bb2:	84 d2                	test   %dl,%dl
  800bb4:	75 f2                	jne    800ba8 <strfind+0x19>
			break;
	return (char *) s;
}
  800bb6:	5b                   	pop    %ebx
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bc2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bc5:	85 c9                	test   %ecx,%ecx
  800bc7:	74 36                	je     800bff <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bc9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bcf:	75 28                	jne    800bf9 <memset+0x40>
  800bd1:	f6 c1 03             	test   $0x3,%cl
  800bd4:	75 23                	jne    800bf9 <memset+0x40>
		c &= 0xFF;
  800bd6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bda:	89 d3                	mov    %edx,%ebx
  800bdc:	c1 e3 08             	shl    $0x8,%ebx
  800bdf:	89 d6                	mov    %edx,%esi
  800be1:	c1 e6 18             	shl    $0x18,%esi
  800be4:	89 d0                	mov    %edx,%eax
  800be6:	c1 e0 10             	shl    $0x10,%eax
  800be9:	09 f0                	or     %esi,%eax
  800beb:	09 c2                	or     %eax,%edx
  800bed:	89 d0                	mov    %edx,%eax
  800bef:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bf1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bf4:	fc                   	cld    
  800bf5:	f3 ab                	rep stos %eax,%es:(%edi)
  800bf7:	eb 06                	jmp    800bff <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bf9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfc:	fc                   	cld    
  800bfd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bff:	89 f8                	mov    %edi,%eax
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c11:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c14:	39 c6                	cmp    %eax,%esi
  800c16:	73 35                	jae    800c4d <memmove+0x47>
  800c18:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c1b:	39 d0                	cmp    %edx,%eax
  800c1d:	73 2e                	jae    800c4d <memmove+0x47>
		s += n;
		d += n;
  800c1f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800c22:	89 d6                	mov    %edx,%esi
  800c24:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c26:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c2c:	75 13                	jne    800c41 <memmove+0x3b>
  800c2e:	f6 c1 03             	test   $0x3,%cl
  800c31:	75 0e                	jne    800c41 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c33:	83 ef 04             	sub    $0x4,%edi
  800c36:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c39:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c3c:	fd                   	std    
  800c3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c3f:	eb 09                	jmp    800c4a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c41:	83 ef 01             	sub    $0x1,%edi
  800c44:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c47:	fd                   	std    
  800c48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c4a:	fc                   	cld    
  800c4b:	eb 1d                	jmp    800c6a <memmove+0x64>
  800c4d:	89 f2                	mov    %esi,%edx
  800c4f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c51:	f6 c2 03             	test   $0x3,%dl
  800c54:	75 0f                	jne    800c65 <memmove+0x5f>
  800c56:	f6 c1 03             	test   $0x3,%cl
  800c59:	75 0a                	jne    800c65 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c5b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c5e:	89 c7                	mov    %eax,%edi
  800c60:	fc                   	cld    
  800c61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c63:	eb 05                	jmp    800c6a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800c65:	89 c7                	mov    %eax,%edi
  800c67:	fc                   	cld    
  800c68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c74:	8b 45 10             	mov    0x10(%ebp),%eax
  800c77:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c82:	8b 45 08             	mov    0x8(%ebp),%eax
  800c85:	89 04 24             	mov    %eax,(%esp)
  800c88:	e8 79 ff ff ff       	call   800c06 <memmove>
}
  800c8d:	c9                   	leave  
  800c8e:	c3                   	ret    

00800c8f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c98:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c9e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	74 36                	je     800cdb <memcmp+0x4c>
		if (*s1 != *s2)
  800ca5:	0f b6 03             	movzbl (%ebx),%eax
  800ca8:	0f b6 0e             	movzbl (%esi),%ecx
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	38 c8                	cmp    %cl,%al
  800cb2:	74 1c                	je     800cd0 <memcmp+0x41>
  800cb4:	eb 10                	jmp    800cc6 <memcmp+0x37>
  800cb6:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800cbb:	83 c2 01             	add    $0x1,%edx
  800cbe:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800cc2:	38 c8                	cmp    %cl,%al
  800cc4:	74 0a                	je     800cd0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800cc6:	0f b6 c0             	movzbl %al,%eax
  800cc9:	0f b6 c9             	movzbl %cl,%ecx
  800ccc:	29 c8                	sub    %ecx,%eax
  800cce:	eb 10                	jmp    800ce0 <memcmp+0x51>
	while (n-- > 0) {
  800cd0:	39 fa                	cmp    %edi,%edx
  800cd2:	75 e2                	jne    800cb6 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800cd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd9:	eb 05                	jmp    800ce0 <memcmp+0x51>
  800cdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	53                   	push   %ebx
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800cef:	89 c2                	mov    %eax,%edx
  800cf1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cf4:	39 d0                	cmp    %edx,%eax
  800cf6:	73 13                	jae    800d0b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf8:	89 d9                	mov    %ebx,%ecx
  800cfa:	38 18                	cmp    %bl,(%eax)
  800cfc:	75 06                	jne    800d04 <memfind+0x1f>
  800cfe:	eb 0b                	jmp    800d0b <memfind+0x26>
  800d00:	38 08                	cmp    %cl,(%eax)
  800d02:	74 07                	je     800d0b <memfind+0x26>
	for (; s < ends; s++)
  800d04:	83 c0 01             	add    $0x1,%eax
  800d07:	39 d0                	cmp    %edx,%eax
  800d09:	75 f5                	jne    800d00 <memfind+0x1b>
			break;
	return (void *) s;
}
  800d0b:	5b                   	pop    %ebx
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d1a:	0f b6 0a             	movzbl (%edx),%ecx
  800d1d:	80 f9 09             	cmp    $0x9,%cl
  800d20:	74 05                	je     800d27 <strtol+0x19>
  800d22:	80 f9 20             	cmp    $0x20,%cl
  800d25:	75 10                	jne    800d37 <strtol+0x29>
		s++;
  800d27:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800d2a:	0f b6 0a             	movzbl (%edx),%ecx
  800d2d:	80 f9 09             	cmp    $0x9,%cl
  800d30:	74 f5                	je     800d27 <strtol+0x19>
  800d32:	80 f9 20             	cmp    $0x20,%cl
  800d35:	74 f0                	je     800d27 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800d37:	80 f9 2b             	cmp    $0x2b,%cl
  800d3a:	75 0a                	jne    800d46 <strtol+0x38>
		s++;
  800d3c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800d3f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d44:	eb 11                	jmp    800d57 <strtol+0x49>
  800d46:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800d4b:	80 f9 2d             	cmp    $0x2d,%cl
  800d4e:	75 07                	jne    800d57 <strtol+0x49>
		s++, neg = 1;
  800d50:	83 c2 01             	add    $0x1,%edx
  800d53:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d57:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800d5c:	75 15                	jne    800d73 <strtol+0x65>
  800d5e:	80 3a 30             	cmpb   $0x30,(%edx)
  800d61:	75 10                	jne    800d73 <strtol+0x65>
  800d63:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d67:	75 0a                	jne    800d73 <strtol+0x65>
		s += 2, base = 16;
  800d69:	83 c2 02             	add    $0x2,%edx
  800d6c:	b8 10 00 00 00       	mov    $0x10,%eax
  800d71:	eb 10                	jmp    800d83 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800d73:	85 c0                	test   %eax,%eax
  800d75:	75 0c                	jne    800d83 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d77:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800d79:	80 3a 30             	cmpb   $0x30,(%edx)
  800d7c:	75 05                	jne    800d83 <strtol+0x75>
		s++, base = 8;
  800d7e:	83 c2 01             	add    $0x1,%edx
  800d81:	b0 08                	mov    $0x8,%al
		base = 10;
  800d83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d88:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d8b:	0f b6 0a             	movzbl (%edx),%ecx
  800d8e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800d91:	89 f0                	mov    %esi,%eax
  800d93:	3c 09                	cmp    $0x9,%al
  800d95:	77 08                	ja     800d9f <strtol+0x91>
			dig = *s - '0';
  800d97:	0f be c9             	movsbl %cl,%ecx
  800d9a:	83 e9 30             	sub    $0x30,%ecx
  800d9d:	eb 20                	jmp    800dbf <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800d9f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800da2:	89 f0                	mov    %esi,%eax
  800da4:	3c 19                	cmp    $0x19,%al
  800da6:	77 08                	ja     800db0 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800da8:	0f be c9             	movsbl %cl,%ecx
  800dab:	83 e9 57             	sub    $0x57,%ecx
  800dae:	eb 0f                	jmp    800dbf <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800db0:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800db3:	89 f0                	mov    %esi,%eax
  800db5:	3c 19                	cmp    $0x19,%al
  800db7:	77 16                	ja     800dcf <strtol+0xc1>
			dig = *s - 'A' + 10;
  800db9:	0f be c9             	movsbl %cl,%ecx
  800dbc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dbf:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800dc2:	7d 0f                	jge    800dd3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800dc4:	83 c2 01             	add    $0x1,%edx
  800dc7:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800dcb:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800dcd:	eb bc                	jmp    800d8b <strtol+0x7d>
  800dcf:	89 d8                	mov    %ebx,%eax
  800dd1:	eb 02                	jmp    800dd5 <strtol+0xc7>
  800dd3:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800dd5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd9:	74 05                	je     800de0 <strtol+0xd2>
		*endptr = (char *) s;
  800ddb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dde:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800de0:	f7 d8                	neg    %eax
  800de2:	85 ff                	test   %edi,%edi
  800de4:	0f 44 c3             	cmove  %ebx,%eax
}
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df2:	b8 00 00 00 00       	mov    $0x0,%eax
  800df7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfd:	89 c3                	mov    %eax,%ebx
  800dff:	89 c7                	mov    %eax,%edi
  800e01:	89 c6                	mov    %eax,%esi
  800e03:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_cgetc>:

int
sys_cgetc(void)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e10:	ba 00 00 00 00       	mov    $0x0,%edx
  800e15:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1a:	89 d1                	mov    %edx,%ecx
  800e1c:	89 d3                	mov    %edx,%ebx
  800e1e:	89 d7                	mov    %edx,%edi
  800e20:	89 d6                	mov    %edx,%esi
  800e22:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e37:	b8 03 00 00 00       	mov    $0x3,%eax
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	89 cb                	mov    %ecx,%ebx
  800e41:	89 cf                	mov    %ecx,%edi
  800e43:	89 ce                	mov    %ecx,%esi
  800e45:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7e 28                	jle    800e73 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e56:	00 
  800e57:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800e5e:	00 
  800e5f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e66:	00 
  800e67:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800e6e:	e8 4a f4 ff ff       	call   8002bd <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e73:	83 c4 2c             	add    $0x2c,%esp
  800e76:	5b                   	pop    %ebx
  800e77:	5e                   	pop    %esi
  800e78:	5f                   	pop    %edi
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	57                   	push   %edi
  800e7f:	56                   	push   %esi
  800e80:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e81:	ba 00 00 00 00       	mov    $0x0,%edx
  800e86:	b8 02 00 00 00       	mov    $0x2,%eax
  800e8b:	89 d1                	mov    %edx,%ecx
  800e8d:	89 d3                	mov    %edx,%ebx
  800e8f:	89 d7                	mov    %edx,%edi
  800e91:	89 d6                	mov    %edx,%esi
  800e93:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <sys_yield>:

void
sys_yield(void)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	57                   	push   %edi
  800e9e:	56                   	push   %esi
  800e9f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ea0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eaa:	89 d1                	mov    %edx,%ecx
  800eac:	89 d3                	mov    %edx,%ebx
  800eae:	89 d7                	mov    %edx,%edi
  800eb0:	89 d6                	mov    %edx,%esi
  800eb2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ec2:	be 00 00 00 00       	mov    $0x0,%esi
  800ec7:	b8 04 00 00 00       	mov    $0x4,%eax
  800ecc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed5:	89 f7                	mov    %esi,%edi
  800ed7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	7e 28                	jle    800f05 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ee8:	00 
  800ee9:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800ef0:	00 
  800ef1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef8:	00 
  800ef9:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800f00:	e8 b8 f3 ff ff       	call   8002bd <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f05:	83 c4 2c             	add    $0x2c,%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	57                   	push   %edi
  800f11:	56                   	push   %esi
  800f12:	53                   	push   %ebx
  800f13:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f16:	b8 05 00 00 00       	mov    $0x5,%eax
  800f1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f24:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f27:	8b 75 18             	mov    0x18(%ebp),%esi
  800f2a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	7e 28                	jle    800f58 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f34:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f3b:	00 
  800f3c:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800f43:	00 
  800f44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4b:	00 
  800f4c:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800f53:	e8 65 f3 ff ff       	call   8002bd <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f58:	83 c4 2c             	add    $0x2c,%esp
  800f5b:	5b                   	pop    %ebx
  800f5c:	5e                   	pop    %esi
  800f5d:	5f                   	pop    %edi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	57                   	push   %edi
  800f64:	56                   	push   %esi
  800f65:	53                   	push   %ebx
  800f66:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800f73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f76:	8b 55 08             	mov    0x8(%ebp),%edx
  800f79:	89 df                	mov    %ebx,%edi
  800f7b:	89 de                	mov    %ebx,%esi
  800f7d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	7e 28                	jle    800fab <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f83:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f87:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f8e:	00 
  800f8f:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800f96:	00 
  800f97:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9e:	00 
  800f9f:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800fa6:	e8 12 f3 ff ff       	call   8002bd <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fab:	83 c4 2c             	add    $0x2c,%esp
  800fae:	5b                   	pop    %ebx
  800faf:	5e                   	pop    %esi
  800fb0:	5f                   	pop    %edi
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    

00800fb3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	57                   	push   %edi
  800fb7:	56                   	push   %esi
  800fb8:	53                   	push   %ebx
  800fb9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800fbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc1:	b8 08 00 00 00       	mov    $0x8,%eax
  800fc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcc:	89 df                	mov    %ebx,%edi
  800fce:	89 de                	mov    %ebx,%esi
  800fd0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	7e 28                	jle    800ffe <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fda:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fe1:	00 
  800fe2:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800fe9:	00 
  800fea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff1:	00 
  800ff2:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800ff9:	e8 bf f2 ff ff       	call   8002bd <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ffe:	83 c4 2c             	add    $0x2c,%esp
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5f                   	pop    %edi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	57                   	push   %edi
  80100a:	56                   	push   %esi
  80100b:	53                   	push   %ebx
  80100c:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80100f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801014:	b8 09 00 00 00       	mov    $0x9,%eax
  801019:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101c:	8b 55 08             	mov    0x8(%ebp),%edx
  80101f:	89 df                	mov    %ebx,%edi
  801021:	89 de                	mov    %ebx,%esi
  801023:	cd 30                	int    $0x30
	if(check && ret > 0)
  801025:	85 c0                	test   %eax,%eax
  801027:	7e 28                	jle    801051 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801029:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801034:	00 
  801035:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  80103c:	00 
  80103d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801044:	00 
  801045:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  80104c:	e8 6c f2 ff ff       	call   8002bd <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801051:	83 c4 2c             	add    $0x2c,%esp
  801054:	5b                   	pop    %ebx
  801055:	5e                   	pop    %esi
  801056:	5f                   	pop    %edi
  801057:	5d                   	pop    %ebp
  801058:	c3                   	ret    

00801059 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	57                   	push   %edi
  80105d:	56                   	push   %esi
  80105e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80105f:	be 00 00 00 00       	mov    $0x0,%esi
  801064:	b8 0b 00 00 00       	mov    $0xb,%eax
  801069:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106c:	8b 55 08             	mov    0x8(%ebp),%edx
  80106f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801072:	8b 7d 14             	mov    0x14(%ebp),%edi
  801075:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801077:	5b                   	pop    %ebx
  801078:	5e                   	pop    %esi
  801079:	5f                   	pop    %edi
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    

0080107c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	57                   	push   %edi
  801080:	56                   	push   %esi
  801081:	53                   	push   %ebx
  801082:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801085:	b9 00 00 00 00       	mov    $0x0,%ecx
  80108a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80108f:	8b 55 08             	mov    0x8(%ebp),%edx
  801092:	89 cb                	mov    %ecx,%ebx
  801094:	89 cf                	mov    %ecx,%edi
  801096:	89 ce                	mov    %ecx,%esi
  801098:	cd 30                	int    $0x30
	if(check && ret > 0)
  80109a:	85 c0                	test   %eax,%eax
  80109c:	7e 28                	jle    8010c6 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a2:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8010a9:	00 
  8010aa:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  8010b1:	00 
  8010b2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010b9:	00 
  8010ba:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  8010c1:	e8 f7 f1 ff ff       	call   8002bd <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010c6:	83 c4 2c             	add    $0x2c,%esp
  8010c9:	5b                   	pop    %ebx
  8010ca:	5e                   	pop    %esi
  8010cb:	5f                   	pop    %edi
  8010cc:	5d                   	pop    %ebp
  8010cd:	c3                   	ret    
  8010ce:	66 90                	xchg   %ax,%ax

008010d0 <__udivdi3>:
  8010d0:	55                   	push   %ebp
  8010d1:	57                   	push   %edi
  8010d2:	56                   	push   %esi
  8010d3:	83 ec 0c             	sub    $0xc,%esp
  8010d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8010da:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8010de:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8010e2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010ec:	89 ea                	mov    %ebp,%edx
  8010ee:	89 0c 24             	mov    %ecx,(%esp)
  8010f1:	75 2d                	jne    801120 <__udivdi3+0x50>
  8010f3:	39 e9                	cmp    %ebp,%ecx
  8010f5:	77 61                	ja     801158 <__udivdi3+0x88>
  8010f7:	85 c9                	test   %ecx,%ecx
  8010f9:	89 ce                	mov    %ecx,%esi
  8010fb:	75 0b                	jne    801108 <__udivdi3+0x38>
  8010fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801102:	31 d2                	xor    %edx,%edx
  801104:	f7 f1                	div    %ecx
  801106:	89 c6                	mov    %eax,%esi
  801108:	31 d2                	xor    %edx,%edx
  80110a:	89 e8                	mov    %ebp,%eax
  80110c:	f7 f6                	div    %esi
  80110e:	89 c5                	mov    %eax,%ebp
  801110:	89 f8                	mov    %edi,%eax
  801112:	f7 f6                	div    %esi
  801114:	89 ea                	mov    %ebp,%edx
  801116:	83 c4 0c             	add    $0xc,%esp
  801119:	5e                   	pop    %esi
  80111a:	5f                   	pop    %edi
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    
  80111d:	8d 76 00             	lea    0x0(%esi),%esi
  801120:	39 e8                	cmp    %ebp,%eax
  801122:	77 24                	ja     801148 <__udivdi3+0x78>
  801124:	0f bd e8             	bsr    %eax,%ebp
  801127:	83 f5 1f             	xor    $0x1f,%ebp
  80112a:	75 3c                	jne    801168 <__udivdi3+0x98>
  80112c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801130:	39 34 24             	cmp    %esi,(%esp)
  801133:	0f 86 9f 00 00 00    	jbe    8011d8 <__udivdi3+0x108>
  801139:	39 d0                	cmp    %edx,%eax
  80113b:	0f 82 97 00 00 00    	jb     8011d8 <__udivdi3+0x108>
  801141:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801148:	31 d2                	xor    %edx,%edx
  80114a:	31 c0                	xor    %eax,%eax
  80114c:	83 c4 0c             	add    $0xc,%esp
  80114f:	5e                   	pop    %esi
  801150:	5f                   	pop    %edi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    
  801153:	90                   	nop
  801154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801158:	89 f8                	mov    %edi,%eax
  80115a:	f7 f1                	div    %ecx
  80115c:	31 d2                	xor    %edx,%edx
  80115e:	83 c4 0c             	add    $0xc,%esp
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    
  801165:	8d 76 00             	lea    0x0(%esi),%esi
  801168:	89 e9                	mov    %ebp,%ecx
  80116a:	8b 3c 24             	mov    (%esp),%edi
  80116d:	d3 e0                	shl    %cl,%eax
  80116f:	89 c6                	mov    %eax,%esi
  801171:	b8 20 00 00 00       	mov    $0x20,%eax
  801176:	29 e8                	sub    %ebp,%eax
  801178:	89 c1                	mov    %eax,%ecx
  80117a:	d3 ef                	shr    %cl,%edi
  80117c:	89 e9                	mov    %ebp,%ecx
  80117e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801182:	8b 3c 24             	mov    (%esp),%edi
  801185:	09 74 24 08          	or     %esi,0x8(%esp)
  801189:	89 d6                	mov    %edx,%esi
  80118b:	d3 e7                	shl    %cl,%edi
  80118d:	89 c1                	mov    %eax,%ecx
  80118f:	89 3c 24             	mov    %edi,(%esp)
  801192:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801196:	d3 ee                	shr    %cl,%esi
  801198:	89 e9                	mov    %ebp,%ecx
  80119a:	d3 e2                	shl    %cl,%edx
  80119c:	89 c1                	mov    %eax,%ecx
  80119e:	d3 ef                	shr    %cl,%edi
  8011a0:	09 d7                	or     %edx,%edi
  8011a2:	89 f2                	mov    %esi,%edx
  8011a4:	89 f8                	mov    %edi,%eax
  8011a6:	f7 74 24 08          	divl   0x8(%esp)
  8011aa:	89 d6                	mov    %edx,%esi
  8011ac:	89 c7                	mov    %eax,%edi
  8011ae:	f7 24 24             	mull   (%esp)
  8011b1:	39 d6                	cmp    %edx,%esi
  8011b3:	89 14 24             	mov    %edx,(%esp)
  8011b6:	72 30                	jb     8011e8 <__udivdi3+0x118>
  8011b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8011bc:	89 e9                	mov    %ebp,%ecx
  8011be:	d3 e2                	shl    %cl,%edx
  8011c0:	39 c2                	cmp    %eax,%edx
  8011c2:	73 05                	jae    8011c9 <__udivdi3+0xf9>
  8011c4:	3b 34 24             	cmp    (%esp),%esi
  8011c7:	74 1f                	je     8011e8 <__udivdi3+0x118>
  8011c9:	89 f8                	mov    %edi,%eax
  8011cb:	31 d2                	xor    %edx,%edx
  8011cd:	e9 7a ff ff ff       	jmp    80114c <__udivdi3+0x7c>
  8011d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011d8:	31 d2                	xor    %edx,%edx
  8011da:	b8 01 00 00 00       	mov    $0x1,%eax
  8011df:	e9 68 ff ff ff       	jmp    80114c <__udivdi3+0x7c>
  8011e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8011eb:	31 d2                	xor    %edx,%edx
  8011ed:	83 c4 0c             	add    $0xc,%esp
  8011f0:	5e                   	pop    %esi
  8011f1:	5f                   	pop    %edi
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    
  8011f4:	66 90                	xchg   %ax,%ax
  8011f6:	66 90                	xchg   %ax,%ax
  8011f8:	66 90                	xchg   %ax,%ax
  8011fa:	66 90                	xchg   %ax,%ax
  8011fc:	66 90                	xchg   %ax,%ax
  8011fe:	66 90                	xchg   %ax,%ax

00801200 <__umoddi3>:
  801200:	55                   	push   %ebp
  801201:	57                   	push   %edi
  801202:	56                   	push   %esi
  801203:	83 ec 14             	sub    $0x14,%esp
  801206:	8b 44 24 28          	mov    0x28(%esp),%eax
  80120a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80120e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801212:	89 c7                	mov    %eax,%edi
  801214:	89 44 24 04          	mov    %eax,0x4(%esp)
  801218:	8b 44 24 30          	mov    0x30(%esp),%eax
  80121c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801220:	89 34 24             	mov    %esi,(%esp)
  801223:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801227:	85 c0                	test   %eax,%eax
  801229:	89 c2                	mov    %eax,%edx
  80122b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80122f:	75 17                	jne    801248 <__umoddi3+0x48>
  801231:	39 fe                	cmp    %edi,%esi
  801233:	76 4b                	jbe    801280 <__umoddi3+0x80>
  801235:	89 c8                	mov    %ecx,%eax
  801237:	89 fa                	mov    %edi,%edx
  801239:	f7 f6                	div    %esi
  80123b:	89 d0                	mov    %edx,%eax
  80123d:	31 d2                	xor    %edx,%edx
  80123f:	83 c4 14             	add    $0x14,%esp
  801242:	5e                   	pop    %esi
  801243:	5f                   	pop    %edi
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    
  801246:	66 90                	xchg   %ax,%ax
  801248:	39 f8                	cmp    %edi,%eax
  80124a:	77 54                	ja     8012a0 <__umoddi3+0xa0>
  80124c:	0f bd e8             	bsr    %eax,%ebp
  80124f:	83 f5 1f             	xor    $0x1f,%ebp
  801252:	75 5c                	jne    8012b0 <__umoddi3+0xb0>
  801254:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801258:	39 3c 24             	cmp    %edi,(%esp)
  80125b:	0f 87 e7 00 00 00    	ja     801348 <__umoddi3+0x148>
  801261:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801265:	29 f1                	sub    %esi,%ecx
  801267:	19 c7                	sbb    %eax,%edi
  801269:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80126d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801271:	8b 44 24 08          	mov    0x8(%esp),%eax
  801275:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801279:	83 c4 14             	add    $0x14,%esp
  80127c:	5e                   	pop    %esi
  80127d:	5f                   	pop    %edi
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    
  801280:	85 f6                	test   %esi,%esi
  801282:	89 f5                	mov    %esi,%ebp
  801284:	75 0b                	jne    801291 <__umoddi3+0x91>
  801286:	b8 01 00 00 00       	mov    $0x1,%eax
  80128b:	31 d2                	xor    %edx,%edx
  80128d:	f7 f6                	div    %esi
  80128f:	89 c5                	mov    %eax,%ebp
  801291:	8b 44 24 04          	mov    0x4(%esp),%eax
  801295:	31 d2                	xor    %edx,%edx
  801297:	f7 f5                	div    %ebp
  801299:	89 c8                	mov    %ecx,%eax
  80129b:	f7 f5                	div    %ebp
  80129d:	eb 9c                	jmp    80123b <__umoddi3+0x3b>
  80129f:	90                   	nop
  8012a0:	89 c8                	mov    %ecx,%eax
  8012a2:	89 fa                	mov    %edi,%edx
  8012a4:	83 c4 14             	add    $0x14,%esp
  8012a7:	5e                   	pop    %esi
  8012a8:	5f                   	pop    %edi
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    
  8012ab:	90                   	nop
  8012ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b0:	8b 04 24             	mov    (%esp),%eax
  8012b3:	be 20 00 00 00       	mov    $0x20,%esi
  8012b8:	89 e9                	mov    %ebp,%ecx
  8012ba:	29 ee                	sub    %ebp,%esi
  8012bc:	d3 e2                	shl    %cl,%edx
  8012be:	89 f1                	mov    %esi,%ecx
  8012c0:	d3 e8                	shr    %cl,%eax
  8012c2:	89 e9                	mov    %ebp,%ecx
  8012c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c8:	8b 04 24             	mov    (%esp),%eax
  8012cb:	09 54 24 04          	or     %edx,0x4(%esp)
  8012cf:	89 fa                	mov    %edi,%edx
  8012d1:	d3 e0                	shl    %cl,%eax
  8012d3:	89 f1                	mov    %esi,%ecx
  8012d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8012dd:	d3 ea                	shr    %cl,%edx
  8012df:	89 e9                	mov    %ebp,%ecx
  8012e1:	d3 e7                	shl    %cl,%edi
  8012e3:	89 f1                	mov    %esi,%ecx
  8012e5:	d3 e8                	shr    %cl,%eax
  8012e7:	89 e9                	mov    %ebp,%ecx
  8012e9:	09 f8                	or     %edi,%eax
  8012eb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8012ef:	f7 74 24 04          	divl   0x4(%esp)
  8012f3:	d3 e7                	shl    %cl,%edi
  8012f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012f9:	89 d7                	mov    %edx,%edi
  8012fb:	f7 64 24 08          	mull   0x8(%esp)
  8012ff:	39 d7                	cmp    %edx,%edi
  801301:	89 c1                	mov    %eax,%ecx
  801303:	89 14 24             	mov    %edx,(%esp)
  801306:	72 2c                	jb     801334 <__umoddi3+0x134>
  801308:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80130c:	72 22                	jb     801330 <__umoddi3+0x130>
  80130e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801312:	29 c8                	sub    %ecx,%eax
  801314:	19 d7                	sbb    %edx,%edi
  801316:	89 e9                	mov    %ebp,%ecx
  801318:	89 fa                	mov    %edi,%edx
  80131a:	d3 e8                	shr    %cl,%eax
  80131c:	89 f1                	mov    %esi,%ecx
  80131e:	d3 e2                	shl    %cl,%edx
  801320:	89 e9                	mov    %ebp,%ecx
  801322:	d3 ef                	shr    %cl,%edi
  801324:	09 d0                	or     %edx,%eax
  801326:	89 fa                	mov    %edi,%edx
  801328:	83 c4 14             	add    $0x14,%esp
  80132b:	5e                   	pop    %esi
  80132c:	5f                   	pop    %edi
  80132d:	5d                   	pop    %ebp
  80132e:	c3                   	ret    
  80132f:	90                   	nop
  801330:	39 d7                	cmp    %edx,%edi
  801332:	75 da                	jne    80130e <__umoddi3+0x10e>
  801334:	8b 14 24             	mov    (%esp),%edx
  801337:	89 c1                	mov    %eax,%ecx
  801339:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80133d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801341:	eb cb                	jmp    80130e <__umoddi3+0x10e>
  801343:	90                   	nop
  801344:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801348:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80134c:	0f 82 0f ff ff ff    	jb     801261 <__umoddi3+0x61>
  801352:	e9 1a ff ff ff       	jmp    801271 <__umoddi3+0x71>
