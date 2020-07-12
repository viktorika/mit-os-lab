
obj/user/dumbfork.debug：     文件格式 elf32-i386


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
  80005d:	e8 67 0e 00 00       	call   800ec9 <sys_page_alloc>
  800062:	85 c0                	test   %eax,%eax
  800064:	79 20                	jns    800086 <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  800066:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80006a:	c7 44 24 08 a0 22 80 	movl   $0x8022a0,0x8(%esp)
  800071:	00 
  800072:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800079:	00 
  80007a:	c7 04 24 b3 22 80 00 	movl   $0x8022b3,(%esp)
  800081:	e8 3c 02 00 00       	call   8002c2 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800086:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80008d:	00 
  80008e:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800095:	00 
  800096:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80009d:	00 
  80009e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a2:	89 34 24             	mov    %esi,(%esp)
  8000a5:	e8 73 0e 00 00       	call   800f1d <sys_page_map>
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	79 20                	jns    8000ce <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b2:	c7 44 24 08 c3 22 80 	movl   $0x8022c3,0x8(%esp)
  8000b9:	00 
  8000ba:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000c1:	00 
  8000c2:	c7 04 24 b3 22 80 00 	movl   $0x8022b3,(%esp)
  8000c9:	e8 f4 01 00 00       	call   8002c2 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000d5:	00 
  8000d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000da:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000e1:	e8 30 0b 00 00       	call   800c16 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000e6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 76 0e 00 00       	call   800f70 <sys_page_unmap>
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 d4 22 80 	movl   $0x8022d4,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 b3 22 80 00 	movl   $0x8022b3,(%esp)
  800119:	e8 a4 01 00 00       	call   8002c2 <_panic>
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
  80013e:	c7 44 24 08 e7 22 80 	movl   $0x8022e7,0x8(%esp)
  800145:	00 
  800146:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  80014d:	00 
  80014e:	c7 04 24 b3 22 80 00 	movl   $0x8022b3,(%esp)
  800155:	e8 68 01 00 00       	call   8002c2 <_panic>
  80015a:	89 c3                	mov    %eax,%ebx
	if (envid == 0) {
  80015c:	85 c0                	test   %eax,%eax
  80015e:	75 21                	jne    800181 <dumbfork+0x5c>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800160:	e8 26 0d 00 00       	call   800e8b <sys_getenvid>
  800165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800172:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800177:	b8 00 00 00 00       	mov    $0x0,%eax
  80017c:	e9 82 00 00 00       	jmp    800203 <dumbfork+0xde>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800181:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800188:	b8 00 60 80 00       	mov    $0x806000,%eax
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
  8001b1:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
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
  8001d8:	e8 e6 0d 00 00       	call   800fc3 <sys_env_set_status>
  8001dd:	85 c0                	test   %eax,%eax
  8001df:	79 20                	jns    800201 <dumbfork+0xdc>
		panic("sys_env_set_status: %e", r);
  8001e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e5:	c7 44 24 08 f7 22 80 	movl   $0x8022f7,0x8(%esp)
  8001ec:	00 
  8001ed:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001f4:	00 
  8001f5:	c7 04 24 b3 22 80 00 	movl   $0x8022b3,(%esp)
  8001fc:	e8 c1 00 00 00       	call   8002c2 <_panic>

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
  800220:	b8 15 23 80 00       	mov    $0x802315,%eax
  800225:	eb 05                	jmp    80022c <umain+0x22>
  800227:	b8 0e 23 80 00       	mov    $0x80230e,%eax
  80022c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800230:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800234:	c7 04 24 1b 23 80 00 	movl   $0x80231b,(%esp)
  80023b:	e8 7b 01 00 00       	call   8003bb <cprintf>
		sys_yield();
  800240:	e8 65 0c 00 00       	call   800eaa <sys_yield>
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
  80026f:	e8 17 0c 00 00       	call   800e8b <sys_getenvid>
  800274:	25 ff 03 00 00       	and    $0x3ff,%eax
  800279:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80027c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800281:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800286:	85 db                	test   %ebx,%ebx
  800288:	7e 07                	jle    800291 <libmain+0x30>
		binaryname = argv[0];
  80028a:	8b 06                	mov    (%esi),%eax
  80028c:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  8002af:	e8 a2 10 00 00       	call   801356 <close_all>
	sys_env_destroy(0);
  8002b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002bb:	e8 79 0b 00 00       	call   800e39 <sys_env_destroy>
}
  8002c0:	c9                   	leave  
  8002c1:	c3                   	ret    

008002c2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	56                   	push   %esi
  8002c6:	53                   	push   %ebx
  8002c7:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ca:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002cd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002d3:	e8 b3 0b 00 00       	call   800e8b <sys_getenvid>
  8002d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002db:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002df:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ee:	c7 04 24 38 23 80 00 	movl   $0x802338,(%esp)
  8002f5:	e8 c1 00 00 00       	call   8003bb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800301:	89 04 24             	mov    %eax,(%esp)
  800304:	e8 51 00 00 00       	call   80035a <vcprintf>
	cprintf("\n");
  800309:	c7 04 24 2b 23 80 00 	movl   $0x80232b,(%esp)
  800310:	e8 a6 00 00 00       	call   8003bb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800315:	cc                   	int3   
  800316:	eb fd                	jmp    800315 <_panic+0x53>

00800318 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	53                   	push   %ebx
  80031c:	83 ec 14             	sub    $0x14,%esp
  80031f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800322:	8b 13                	mov    (%ebx),%edx
  800324:	8d 42 01             	lea    0x1(%edx),%eax
  800327:	89 03                	mov    %eax,(%ebx)
  800329:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80032c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800330:	3d ff 00 00 00       	cmp    $0xff,%eax
  800335:	75 19                	jne    800350 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800337:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80033e:	00 
  80033f:	8d 43 08             	lea    0x8(%ebx),%eax
  800342:	89 04 24             	mov    %eax,(%esp)
  800345:	e8 b2 0a 00 00       	call   800dfc <sys_cputs>
		b->idx = 0;
  80034a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800350:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800354:	83 c4 14             	add    $0x14,%esp
  800357:	5b                   	pop    %ebx
  800358:	5d                   	pop    %ebp
  800359:	c3                   	ret    

0080035a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800363:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80036a:	00 00 00 
	b.cnt = 0;
  80036d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800374:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800377:	8b 45 0c             	mov    0xc(%ebp),%eax
  80037a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80037e:	8b 45 08             	mov    0x8(%ebp),%eax
  800381:	89 44 24 08          	mov    %eax,0x8(%esp)
  800385:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80038b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038f:	c7 04 24 18 03 80 00 	movl   $0x800318,(%esp)
  800396:	e8 b9 01 00 00       	call   800554 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80039b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ab:	89 04 24             	mov    %eax,(%esp)
  8003ae:	e8 49 0a 00 00       	call   800dfc <sys_cputs>

	return b.cnt;
}
  8003b3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003b9:	c9                   	leave  
  8003ba:	c3                   	ret    

008003bb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003c1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cb:	89 04 24             	mov    %eax,(%esp)
  8003ce:	e8 87 ff ff ff       	call   80035a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003d3:	c9                   	leave  
  8003d4:	c3                   	ret    
  8003d5:	66 90                	xchg   %ax,%ax
  8003d7:	66 90                	xchg   %ax,%ax
  8003d9:	66 90                	xchg   %ax,%ax
  8003db:	66 90                	xchg   %ax,%ax
  8003dd:	66 90                	xchg   %ax,%ax
  8003df:	90                   	nop

008003e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	83 ec 3c             	sub    $0x3c,%esp
  8003e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ec:	89 d7                	mov    %edx,%edi
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003f7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8003fa:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800402:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800405:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800408:	39 f1                	cmp    %esi,%ecx
  80040a:	72 14                	jb     800420 <printnum+0x40>
  80040c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80040f:	76 0f                	jbe    800420 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 70 ff             	lea    -0x1(%eax),%esi
  800417:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80041a:	85 f6                	test   %esi,%esi
  80041c:	7f 60                	jg     80047e <printnum+0x9e>
  80041e:	eb 72                	jmp    800492 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800420:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800423:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800427:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80042a:	8d 51 ff             	lea    -0x1(%ecx),%edx
  80042d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800431:	89 44 24 08          	mov    %eax,0x8(%esp)
  800435:	8b 44 24 08          	mov    0x8(%esp),%eax
  800439:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80043d:	89 c3                	mov    %eax,%ebx
  80043f:	89 d6                	mov    %edx,%esi
  800441:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800444:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800447:	89 54 24 08          	mov    %edx,0x8(%esp)
  80044b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80044f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800452:	89 04 24             	mov    %eax,(%esp)
  800455:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800458:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045c:	e8 af 1b 00 00       	call   802010 <__udivdi3>
  800461:	89 d9                	mov    %ebx,%ecx
  800463:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800467:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80046b:	89 04 24             	mov    %eax,(%esp)
  80046e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800472:	89 fa                	mov    %edi,%edx
  800474:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800477:	e8 64 ff ff ff       	call   8003e0 <printnum>
  80047c:	eb 14                	jmp    800492 <printnum+0xb2>
			putch(padc, putdat);
  80047e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800482:	8b 45 18             	mov    0x18(%ebp),%eax
  800485:	89 04 24             	mov    %eax,(%esp)
  800488:	ff d3                	call   *%ebx
		while (--width > 0)
  80048a:	83 ee 01             	sub    $0x1,%esi
  80048d:	75 ef                	jne    80047e <printnum+0x9e>
  80048f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800492:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800496:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80049a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80049d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8004a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ab:	89 04 24             	mov    %eax,(%esp)
  8004ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b5:	e8 86 1c 00 00       	call   802140 <__umoddi3>
  8004ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004be:	0f be 80 5b 23 80 00 	movsbl 0x80235b(%eax),%eax
  8004c5:	89 04 24             	mov    %eax,(%esp)
  8004c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004cb:	ff d0                	call   *%eax
}
  8004cd:	83 c4 3c             	add    $0x3c,%esp
  8004d0:	5b                   	pop    %ebx
  8004d1:	5e                   	pop    %esi
  8004d2:	5f                   	pop    %edi
  8004d3:	5d                   	pop    %ebp
  8004d4:	c3                   	ret    

008004d5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004d8:	83 fa 01             	cmp    $0x1,%edx
  8004db:	7e 0e                	jle    8004eb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004dd:	8b 10                	mov    (%eax),%edx
  8004df:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004e2:	89 08                	mov    %ecx,(%eax)
  8004e4:	8b 02                	mov    (%edx),%eax
  8004e6:	8b 52 04             	mov    0x4(%edx),%edx
  8004e9:	eb 22                	jmp    80050d <getuint+0x38>
	else if (lflag)
  8004eb:	85 d2                	test   %edx,%edx
  8004ed:	74 10                	je     8004ff <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004ef:	8b 10                	mov    (%eax),%edx
  8004f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f4:	89 08                	mov    %ecx,(%eax)
  8004f6:	8b 02                	mov    (%edx),%eax
  8004f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fd:	eb 0e                	jmp    80050d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ff:	8b 10                	mov    (%eax),%edx
  800501:	8d 4a 04             	lea    0x4(%edx),%ecx
  800504:	89 08                	mov    %ecx,(%eax)
  800506:	8b 02                	mov    (%edx),%eax
  800508:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80050d:	5d                   	pop    %ebp
  80050e:	c3                   	ret    

0080050f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80050f:	55                   	push   %ebp
  800510:	89 e5                	mov    %esp,%ebp
  800512:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800515:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800519:	8b 10                	mov    (%eax),%edx
  80051b:	3b 50 04             	cmp    0x4(%eax),%edx
  80051e:	73 0a                	jae    80052a <sprintputch+0x1b>
		*b->buf++ = ch;
  800520:	8d 4a 01             	lea    0x1(%edx),%ecx
  800523:	89 08                	mov    %ecx,(%eax)
  800525:	8b 45 08             	mov    0x8(%ebp),%eax
  800528:	88 02                	mov    %al,(%edx)
}
  80052a:	5d                   	pop    %ebp
  80052b:	c3                   	ret    

0080052c <printfmt>:
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  800532:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800535:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800539:	8b 45 10             	mov    0x10(%ebp),%eax
  80053c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800540:	8b 45 0c             	mov    0xc(%ebp),%eax
  800543:	89 44 24 04          	mov    %eax,0x4(%esp)
  800547:	8b 45 08             	mov    0x8(%ebp),%eax
  80054a:	89 04 24             	mov    %eax,(%esp)
  80054d:	e8 02 00 00 00       	call   800554 <vprintfmt>
}
  800552:	c9                   	leave  
  800553:	c3                   	ret    

00800554 <vprintfmt>:
{
  800554:	55                   	push   %ebp
  800555:	89 e5                	mov    %esp,%ebp
  800557:	57                   	push   %edi
  800558:	56                   	push   %esi
  800559:	53                   	push   %ebx
  80055a:	83 ec 3c             	sub    $0x3c,%esp
  80055d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800560:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800563:	eb 18                	jmp    80057d <vprintfmt+0x29>
			if (ch == '\0')
  800565:	85 c0                	test   %eax,%eax
  800567:	0f 84 c3 03 00 00    	je     800930 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80056d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800571:	89 04 24             	mov    %eax,(%esp)
  800574:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800577:	89 f3                	mov    %esi,%ebx
  800579:	eb 02                	jmp    80057d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80057b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80057d:	8d 73 01             	lea    0x1(%ebx),%esi
  800580:	0f b6 03             	movzbl (%ebx),%eax
  800583:	83 f8 25             	cmp    $0x25,%eax
  800586:	75 dd                	jne    800565 <vprintfmt+0x11>
  800588:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80058c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800593:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80059a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a6:	eb 1d                	jmp    8005c5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	89 de                	mov    %ebx,%esi
			padc = '-';
  8005aa:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8005ae:	eb 15                	jmp    8005c5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	89 de                	mov    %ebx,%esi
			padc = '0';
  8005b2:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8005b6:	eb 0d                	jmp    8005c5 <vprintfmt+0x71>
				width = precision, precision = -1;
  8005b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005be:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8d 5e 01             	lea    0x1(%esi),%ebx
  8005c8:	0f b6 06             	movzbl (%esi),%eax
  8005cb:	0f b6 c8             	movzbl %al,%ecx
  8005ce:	83 e8 23             	sub    $0x23,%eax
  8005d1:	3c 55                	cmp    $0x55,%al
  8005d3:	0f 87 2f 03 00 00    	ja     800908 <vprintfmt+0x3b4>
  8005d9:	0f b6 c0             	movzbl %al,%eax
  8005dc:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
				precision = precision * 10 + ch - '0';
  8005e3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  8005e9:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8005ed:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8005f0:	83 f9 09             	cmp    $0x9,%ecx
  8005f3:	77 50                	ja     800645 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8005f5:	89 de                	mov    %ebx,%esi
  8005f7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8005fa:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8005fd:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800600:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800604:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800607:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80060a:	83 fb 09             	cmp    $0x9,%ebx
  80060d:	76 eb                	jbe    8005fa <vprintfmt+0xa6>
  80060f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800612:	eb 33                	jmp    800647 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 48 04             	lea    0x4(%eax),%ecx
  80061a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80061d:	8b 00                	mov    (%eax),%eax
  80061f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800622:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800624:	eb 21                	jmp    800647 <vprintfmt+0xf3>
  800626:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800629:	85 c9                	test   %ecx,%ecx
  80062b:	b8 00 00 00 00       	mov    $0x0,%eax
  800630:	0f 49 c1             	cmovns %ecx,%eax
  800633:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800636:	89 de                	mov    %ebx,%esi
  800638:	eb 8b                	jmp    8005c5 <vprintfmt+0x71>
  80063a:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80063c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800643:	eb 80                	jmp    8005c5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800645:	89 de                	mov    %ebx,%esi
			if (width < 0)
  800647:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80064b:	0f 89 74 ff ff ff    	jns    8005c5 <vprintfmt+0x71>
  800651:	e9 62 ff ff ff       	jmp    8005b8 <vprintfmt+0x64>
			lflag++;
  800656:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800659:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80065b:	e9 65 ff ff ff       	jmp    8005c5 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 50 04             	lea    0x4(%eax),%edx
  800666:	89 55 14             	mov    %edx,0x14(%ebp)
  800669:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	89 04 24             	mov    %eax,(%esp)
  800672:	ff 55 08             	call   *0x8(%ebp)
			break;
  800675:	e9 03 ff ff ff       	jmp    80057d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 04             	lea    0x4(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)
  800683:	8b 00                	mov    (%eax),%eax
  800685:	99                   	cltd   
  800686:	31 d0                	xor    %edx,%eax
  800688:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80068a:	83 f8 0f             	cmp    $0xf,%eax
  80068d:	7f 0b                	jg     80069a <vprintfmt+0x146>
  80068f:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  800696:	85 d2                	test   %edx,%edx
  800698:	75 20                	jne    8006ba <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80069a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80069e:	c7 44 24 08 73 23 80 	movl   $0x802373,0x8(%esp)
  8006a5:	00 
  8006a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ad:	89 04 24             	mov    %eax,(%esp)
  8006b0:	e8 77 fe ff ff       	call   80052c <printfmt>
  8006b5:	e9 c3 fe ff ff       	jmp    80057d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  8006ba:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006be:	c7 44 24 08 22 27 80 	movl   $0x802722,0x8(%esp)
  8006c5:	00 
  8006c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cd:	89 04 24             	mov    %eax,(%esp)
  8006d0:	e8 57 fe ff ff       	call   80052c <printfmt>
  8006d5:	e9 a3 fe ff ff       	jmp    80057d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  8006da:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006dd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 50 04             	lea    0x4(%eax),%edx
  8006e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	ba 6c 23 80 00       	mov    $0x80236c,%edx
  8006f2:	0f 45 d0             	cmovne %eax,%edx
  8006f5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8006f8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8006fc:	74 04                	je     800702 <vprintfmt+0x1ae>
  8006fe:	85 f6                	test   %esi,%esi
  800700:	7f 19                	jg     80071b <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800702:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800705:	8d 70 01             	lea    0x1(%eax),%esi
  800708:	0f b6 10             	movzbl (%eax),%edx
  80070b:	0f be c2             	movsbl %dl,%eax
  80070e:	85 c0                	test   %eax,%eax
  800710:	0f 85 95 00 00 00    	jne    8007ab <vprintfmt+0x257>
  800716:	e9 85 00 00 00       	jmp    8007a0 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80071b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80071f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800722:	89 04 24             	mov    %eax,(%esp)
  800725:	e8 b8 02 00 00       	call   8009e2 <strnlen>
  80072a:	29 c6                	sub    %eax,%esi
  80072c:	89 f0                	mov    %esi,%eax
  80072e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800731:	85 f6                	test   %esi,%esi
  800733:	7e cd                	jle    800702 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800735:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800739:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80073c:	89 c3                	mov    %eax,%ebx
  80073e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800742:	89 34 24             	mov    %esi,(%esp)
  800745:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800748:	83 eb 01             	sub    $0x1,%ebx
  80074b:	75 f1                	jne    80073e <vprintfmt+0x1ea>
  80074d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800750:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800753:	eb ad                	jmp    800702 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800755:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800759:	74 1e                	je     800779 <vprintfmt+0x225>
  80075b:	0f be d2             	movsbl %dl,%edx
  80075e:	83 ea 20             	sub    $0x20,%edx
  800761:	83 fa 5e             	cmp    $0x5e,%edx
  800764:	76 13                	jbe    800779 <vprintfmt+0x225>
					putch('?', putdat);
  800766:	8b 45 0c             	mov    0xc(%ebp),%eax
  800769:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800774:	ff 55 08             	call   *0x8(%ebp)
  800777:	eb 0d                	jmp    800786 <vprintfmt+0x232>
					putch(ch, putdat);
  800779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800780:	89 04 24             	mov    %eax,(%esp)
  800783:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800786:	83 ef 01             	sub    $0x1,%edi
  800789:	83 c6 01             	add    $0x1,%esi
  80078c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800790:	0f be c2             	movsbl %dl,%eax
  800793:	85 c0                	test   %eax,%eax
  800795:	75 20                	jne    8007b7 <vprintfmt+0x263>
  800797:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80079a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80079d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  8007a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007a4:	7f 25                	jg     8007cb <vprintfmt+0x277>
  8007a6:	e9 d2 fd ff ff       	jmp    80057d <vprintfmt+0x29>
  8007ab:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007b4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007b7:	85 db                	test   %ebx,%ebx
  8007b9:	78 9a                	js     800755 <vprintfmt+0x201>
  8007bb:	83 eb 01             	sub    $0x1,%ebx
  8007be:	79 95                	jns    800755 <vprintfmt+0x201>
  8007c0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007c3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007c9:	eb d5                	jmp    8007a0 <vprintfmt+0x24c>
  8007cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ce:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  8007d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007df:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8007e1:	83 eb 01             	sub    $0x1,%ebx
  8007e4:	75 ee                	jne    8007d4 <vprintfmt+0x280>
  8007e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007e9:	e9 8f fd ff ff       	jmp    80057d <vprintfmt+0x29>
	if (lflag >= 2)
  8007ee:	83 fa 01             	cmp    $0x1,%edx
  8007f1:	7e 16                	jle    800809 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8d 50 08             	lea    0x8(%eax),%edx
  8007f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fc:	8b 50 04             	mov    0x4(%eax),%edx
  8007ff:	8b 00                	mov    (%eax),%eax
  800801:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800804:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800807:	eb 32                	jmp    80083b <vprintfmt+0x2e7>
	else if (lflag)
  800809:	85 d2                	test   %edx,%edx
  80080b:	74 18                	je     800825 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80080d:	8b 45 14             	mov    0x14(%ebp),%eax
  800810:	8d 50 04             	lea    0x4(%eax),%edx
  800813:	89 55 14             	mov    %edx,0x14(%ebp)
  800816:	8b 30                	mov    (%eax),%esi
  800818:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80081b:	89 f0                	mov    %esi,%eax
  80081d:	c1 f8 1f             	sar    $0x1f,%eax
  800820:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800823:	eb 16                	jmp    80083b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  800825:	8b 45 14             	mov    0x14(%ebp),%eax
  800828:	8d 50 04             	lea    0x4(%eax),%edx
  80082b:	89 55 14             	mov    %edx,0x14(%ebp)
  80082e:	8b 30                	mov    (%eax),%esi
  800830:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800833:	89 f0                	mov    %esi,%eax
  800835:	c1 f8 1f             	sar    $0x1f,%eax
  800838:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  80083b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80083e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  800841:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800846:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80084a:	0f 89 80 00 00 00    	jns    8008d0 <vprintfmt+0x37c>
				putch('-', putdat);
  800850:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800854:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80085b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80085e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800861:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800864:	f7 d8                	neg    %eax
  800866:	83 d2 00             	adc    $0x0,%edx
  800869:	f7 da                	neg    %edx
			base = 10;
  80086b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800870:	eb 5e                	jmp    8008d0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800872:	8d 45 14             	lea    0x14(%ebp),%eax
  800875:	e8 5b fc ff ff       	call   8004d5 <getuint>
			base = 10;
  80087a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80087f:	eb 4f                	jmp    8008d0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800881:	8d 45 14             	lea    0x14(%ebp),%eax
  800884:	e8 4c fc ff ff       	call   8004d5 <getuint>
			base = 8;
  800889:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80088e:	eb 40                	jmp    8008d0 <vprintfmt+0x37c>
			putch('0', putdat);
  800890:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800894:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80089b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80089e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008a2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008a9:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  8008ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8008af:	8d 50 04             	lea    0x4(%eax),%edx
  8008b2:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8008b5:	8b 00                	mov    (%eax),%eax
  8008b7:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8008bc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008c1:	eb 0d                	jmp    8008d0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8008c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c6:	e8 0a fc ff ff       	call   8004d5 <getuint>
			base = 16;
  8008cb:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8008d0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008d4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8008d8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8008db:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008df:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008e3:	89 04 24             	mov    %eax,(%esp)
  8008e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ea:	89 fa                	mov    %edi,%edx
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	e8 ec fa ff ff       	call   8003e0 <printnum>
			break;
  8008f4:	e9 84 fc ff ff       	jmp    80057d <vprintfmt+0x29>
			putch(ch, putdat);
  8008f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008fd:	89 0c 24             	mov    %ecx,(%esp)
  800900:	ff 55 08             	call   *0x8(%ebp)
			break;
  800903:	e9 75 fc ff ff       	jmp    80057d <vprintfmt+0x29>
			putch('%', putdat);
  800908:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80090c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800913:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800916:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80091a:	0f 84 5b fc ff ff    	je     80057b <vprintfmt+0x27>
  800920:	89 f3                	mov    %esi,%ebx
  800922:	83 eb 01             	sub    $0x1,%ebx
  800925:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800929:	75 f7                	jne    800922 <vprintfmt+0x3ce>
  80092b:	e9 4d fc ff ff       	jmp    80057d <vprintfmt+0x29>
}
  800930:	83 c4 3c             	add    $0x3c,%esp
  800933:	5b                   	pop    %ebx
  800934:	5e                   	pop    %esi
  800935:	5f                   	pop    %edi
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	83 ec 28             	sub    $0x28,%esp
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800944:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800947:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80094b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80094e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800955:	85 c0                	test   %eax,%eax
  800957:	74 30                	je     800989 <vsnprintf+0x51>
  800959:	85 d2                	test   %edx,%edx
  80095b:	7e 2c                	jle    800989 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80095d:	8b 45 14             	mov    0x14(%ebp),%eax
  800960:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800964:	8b 45 10             	mov    0x10(%ebp),%eax
  800967:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80096e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800972:	c7 04 24 0f 05 80 00 	movl   $0x80050f,(%esp)
  800979:	e8 d6 fb ff ff       	call   800554 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80097e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800981:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800984:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800987:	eb 05                	jmp    80098e <vsnprintf+0x56>
		return -E_INVAL;
  800989:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80098e:	c9                   	leave  
  80098f:	c3                   	ret    

00800990 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800996:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800999:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80099d:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	89 04 24             	mov    %eax,(%esp)
  8009b1:	e8 82 ff ff ff       	call   800938 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    
  8009b8:	66 90                	xchg   %ax,%ax
  8009ba:	66 90                	xchg   %ax,%ax
  8009bc:	66 90                	xchg   %ax,%ax
  8009be:	66 90                	xchg   %ax,%ax

008009c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	80 3a 00             	cmpb   $0x0,(%edx)
  8009c9:	74 10                	je     8009db <strlen+0x1b>
  8009cb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009d0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009d7:	75 f7                	jne    8009d0 <strlen+0x10>
  8009d9:	eb 05                	jmp    8009e0 <strlen+0x20>
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	53                   	push   %ebx
  8009e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ec:	85 c9                	test   %ecx,%ecx
  8009ee:	74 1c                	je     800a0c <strnlen+0x2a>
  8009f0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009f3:	74 1e                	je     800a13 <strnlen+0x31>
  8009f5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009fa:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009fc:	39 ca                	cmp    %ecx,%edx
  8009fe:	74 18                	je     800a18 <strnlen+0x36>
  800a00:	83 c2 01             	add    $0x1,%edx
  800a03:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a08:	75 f0                	jne    8009fa <strnlen+0x18>
  800a0a:	eb 0c                	jmp    800a18 <strnlen+0x36>
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a11:	eb 05                	jmp    800a18 <strnlen+0x36>
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800a18:	5b                   	pop    %ebx
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	53                   	push   %ebx
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a25:	89 c2                	mov    %eax,%edx
  800a27:	83 c2 01             	add    $0x1,%edx
  800a2a:	83 c1 01             	add    $0x1,%ecx
  800a2d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a31:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a34:	84 db                	test   %bl,%bl
  800a36:	75 ef                	jne    800a27 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a38:	5b                   	pop    %ebx
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	83 ec 08             	sub    $0x8,%esp
  800a42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a45:	89 1c 24             	mov    %ebx,(%esp)
  800a48:	e8 73 ff ff ff       	call   8009c0 <strlen>
	strcpy(dst + len, src);
  800a4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a50:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a54:	01 d8                	add    %ebx,%eax
  800a56:	89 04 24             	mov    %eax,(%esp)
  800a59:	e8 bd ff ff ff       	call   800a1b <strcpy>
	return dst;
}
  800a5e:	89 d8                	mov    %ebx,%eax
  800a60:	83 c4 08             	add    $0x8,%esp
  800a63:	5b                   	pop    %ebx
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a74:	85 db                	test   %ebx,%ebx
  800a76:	74 17                	je     800a8f <strncpy+0x29>
  800a78:	01 f3                	add    %esi,%ebx
  800a7a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a7c:	83 c1 01             	add    $0x1,%ecx
  800a7f:	0f b6 02             	movzbl (%edx),%eax
  800a82:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a85:	80 3a 01             	cmpb   $0x1,(%edx)
  800a88:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a8b:	39 d9                	cmp    %ebx,%ecx
  800a8d:	75 ed                	jne    800a7c <strncpy+0x16>
	}
	return ret;
}
  800a8f:	89 f0                	mov    %esi,%eax
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	57                   	push   %edi
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
  800a9b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa1:	8b 75 10             	mov    0x10(%ebp),%esi
  800aa4:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa6:	85 f6                	test   %esi,%esi
  800aa8:	74 34                	je     800ade <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800aaa:	83 fe 01             	cmp    $0x1,%esi
  800aad:	74 26                	je     800ad5 <strlcpy+0x40>
  800aaf:	0f b6 0b             	movzbl (%ebx),%ecx
  800ab2:	84 c9                	test   %cl,%cl
  800ab4:	74 23                	je     800ad9 <strlcpy+0x44>
  800ab6:	83 ee 02             	sub    $0x2,%esi
  800ab9:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  800abe:	83 c0 01             	add    $0x1,%eax
  800ac1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800ac4:	39 f2                	cmp    %esi,%edx
  800ac6:	74 13                	je     800adb <strlcpy+0x46>
  800ac8:	83 c2 01             	add    $0x1,%edx
  800acb:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800acf:	84 c9                	test   %cl,%cl
  800ad1:	75 eb                	jne    800abe <strlcpy+0x29>
  800ad3:	eb 06                	jmp    800adb <strlcpy+0x46>
  800ad5:	89 f8                	mov    %edi,%eax
  800ad7:	eb 02                	jmp    800adb <strlcpy+0x46>
  800ad9:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  800adb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ade:	29 f8                	sub    %edi,%eax
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aeb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aee:	0f b6 01             	movzbl (%ecx),%eax
  800af1:	84 c0                	test   %al,%al
  800af3:	74 15                	je     800b0a <strcmp+0x25>
  800af5:	3a 02                	cmp    (%edx),%al
  800af7:	75 11                	jne    800b0a <strcmp+0x25>
		p++, q++;
  800af9:	83 c1 01             	add    $0x1,%ecx
  800afc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800aff:	0f b6 01             	movzbl (%ecx),%eax
  800b02:	84 c0                	test   %al,%al
  800b04:	74 04                	je     800b0a <strcmp+0x25>
  800b06:	3a 02                	cmp    (%edx),%al
  800b08:	74 ef                	je     800af9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0a:	0f b6 c0             	movzbl %al,%eax
  800b0d:	0f b6 12             	movzbl (%edx),%edx
  800b10:	29 d0                	sub    %edx,%eax
}
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b22:	85 f6                	test   %esi,%esi
  800b24:	74 29                	je     800b4f <strncmp+0x3b>
  800b26:	0f b6 03             	movzbl (%ebx),%eax
  800b29:	84 c0                	test   %al,%al
  800b2b:	74 30                	je     800b5d <strncmp+0x49>
  800b2d:	3a 02                	cmp    (%edx),%al
  800b2f:	75 2c                	jne    800b5d <strncmp+0x49>
  800b31:	8d 43 01             	lea    0x1(%ebx),%eax
  800b34:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b36:	89 c3                	mov    %eax,%ebx
  800b38:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b3b:	39 f0                	cmp    %esi,%eax
  800b3d:	74 17                	je     800b56 <strncmp+0x42>
  800b3f:	0f b6 08             	movzbl (%eax),%ecx
  800b42:	84 c9                	test   %cl,%cl
  800b44:	74 17                	je     800b5d <strncmp+0x49>
  800b46:	83 c0 01             	add    $0x1,%eax
  800b49:	3a 0a                	cmp    (%edx),%cl
  800b4b:	74 e9                	je     800b36 <strncmp+0x22>
  800b4d:	eb 0e                	jmp    800b5d <strncmp+0x49>
	if (n == 0)
		return 0;
  800b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b54:	eb 0f                	jmp    800b65 <strncmp+0x51>
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5b:	eb 08                	jmp    800b65 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b5d:	0f b6 03             	movzbl (%ebx),%eax
  800b60:	0f b6 12             	movzbl (%edx),%edx
  800b63:	29 d0                	sub    %edx,%eax
}
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	53                   	push   %ebx
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b70:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b73:	0f b6 18             	movzbl (%eax),%ebx
  800b76:	84 db                	test   %bl,%bl
  800b78:	74 1d                	je     800b97 <strchr+0x2e>
  800b7a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800b7c:	38 d3                	cmp    %dl,%bl
  800b7e:	75 06                	jne    800b86 <strchr+0x1d>
  800b80:	eb 1a                	jmp    800b9c <strchr+0x33>
  800b82:	38 ca                	cmp    %cl,%dl
  800b84:	74 16                	je     800b9c <strchr+0x33>
	for (; *s; s++)
  800b86:	83 c0 01             	add    $0x1,%eax
  800b89:	0f b6 10             	movzbl (%eax),%edx
  800b8c:	84 d2                	test   %dl,%dl
  800b8e:	75 f2                	jne    800b82 <strchr+0x19>
			return (char *) s;
	return 0;
  800b90:	b8 00 00 00 00       	mov    $0x0,%eax
  800b95:	eb 05                	jmp    800b9c <strchr+0x33>
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	53                   	push   %ebx
  800ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba6:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ba9:	0f b6 18             	movzbl (%eax),%ebx
  800bac:	84 db                	test   %bl,%bl
  800bae:	74 16                	je     800bc6 <strfind+0x27>
  800bb0:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800bb2:	38 d3                	cmp    %dl,%bl
  800bb4:	75 06                	jne    800bbc <strfind+0x1d>
  800bb6:	eb 0e                	jmp    800bc6 <strfind+0x27>
  800bb8:	38 ca                	cmp    %cl,%dl
  800bba:	74 0a                	je     800bc6 <strfind+0x27>
	for (; *s; s++)
  800bbc:	83 c0 01             	add    $0x1,%eax
  800bbf:	0f b6 10             	movzbl (%eax),%edx
  800bc2:	84 d2                	test   %dl,%dl
  800bc4:	75 f2                	jne    800bb8 <strfind+0x19>
			break;
	return (char *) s;
}
  800bc6:	5b                   	pop    %ebx
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bd2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bd5:	85 c9                	test   %ecx,%ecx
  800bd7:	74 36                	je     800c0f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bdf:	75 28                	jne    800c09 <memset+0x40>
  800be1:	f6 c1 03             	test   $0x3,%cl
  800be4:	75 23                	jne    800c09 <memset+0x40>
		c &= 0xFF;
  800be6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bea:	89 d3                	mov    %edx,%ebx
  800bec:	c1 e3 08             	shl    $0x8,%ebx
  800bef:	89 d6                	mov    %edx,%esi
  800bf1:	c1 e6 18             	shl    $0x18,%esi
  800bf4:	89 d0                	mov    %edx,%eax
  800bf6:	c1 e0 10             	shl    $0x10,%eax
  800bf9:	09 f0                	or     %esi,%eax
  800bfb:	09 c2                	or     %eax,%edx
  800bfd:	89 d0                	mov    %edx,%eax
  800bff:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c01:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c04:	fc                   	cld    
  800c05:	f3 ab                	rep stos %eax,%es:(%edi)
  800c07:	eb 06                	jmp    800c0f <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0c:	fc                   	cld    
  800c0d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c0f:	89 f8                	mov    %edi,%eax
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c21:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c24:	39 c6                	cmp    %eax,%esi
  800c26:	73 35                	jae    800c5d <memmove+0x47>
  800c28:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c2b:	39 d0                	cmp    %edx,%eax
  800c2d:	73 2e                	jae    800c5d <memmove+0x47>
		s += n;
		d += n;
  800c2f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800c32:	89 d6                	mov    %edx,%esi
  800c34:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c3c:	75 13                	jne    800c51 <memmove+0x3b>
  800c3e:	f6 c1 03             	test   $0x3,%cl
  800c41:	75 0e                	jne    800c51 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c43:	83 ef 04             	sub    $0x4,%edi
  800c46:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c49:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c4c:	fd                   	std    
  800c4d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4f:	eb 09                	jmp    800c5a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c51:	83 ef 01             	sub    $0x1,%edi
  800c54:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c57:	fd                   	std    
  800c58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c5a:	fc                   	cld    
  800c5b:	eb 1d                	jmp    800c7a <memmove+0x64>
  800c5d:	89 f2                	mov    %esi,%edx
  800c5f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c61:	f6 c2 03             	test   $0x3,%dl
  800c64:	75 0f                	jne    800c75 <memmove+0x5f>
  800c66:	f6 c1 03             	test   $0x3,%cl
  800c69:	75 0a                	jne    800c75 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c6b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c6e:	89 c7                	mov    %eax,%edi
  800c70:	fc                   	cld    
  800c71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c73:	eb 05                	jmp    800c7a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800c75:	89 c7                	mov    %eax,%edi
  800c77:	fc                   	cld    
  800c78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c84:	8b 45 10             	mov    0x10(%ebp),%eax
  800c87:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c92:	8b 45 08             	mov    0x8(%ebp),%eax
  800c95:	89 04 24             	mov    %eax,(%esp)
  800c98:	e8 79 ff ff ff       	call   800c16 <memmove>
}
  800c9d:	c9                   	leave  
  800c9e:	c3                   	ret    

00800c9f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ca8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cab:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cae:	8d 78 ff             	lea    -0x1(%eax),%edi
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	74 36                	je     800ceb <memcmp+0x4c>
		if (*s1 != *s2)
  800cb5:	0f b6 03             	movzbl (%ebx),%eax
  800cb8:	0f b6 0e             	movzbl (%esi),%ecx
  800cbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc0:	38 c8                	cmp    %cl,%al
  800cc2:	74 1c                	je     800ce0 <memcmp+0x41>
  800cc4:	eb 10                	jmp    800cd6 <memcmp+0x37>
  800cc6:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ccb:	83 c2 01             	add    $0x1,%edx
  800cce:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800cd2:	38 c8                	cmp    %cl,%al
  800cd4:	74 0a                	je     800ce0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800cd6:	0f b6 c0             	movzbl %al,%eax
  800cd9:	0f b6 c9             	movzbl %cl,%ecx
  800cdc:	29 c8                	sub    %ecx,%eax
  800cde:	eb 10                	jmp    800cf0 <memcmp+0x51>
	while (n-- > 0) {
  800ce0:	39 fa                	cmp    %edi,%edx
  800ce2:	75 e2                	jne    800cc6 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800ce4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce9:	eb 05                	jmp    800cf0 <memcmp+0x51>
  800ceb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	53                   	push   %ebx
  800cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800cff:	89 c2                	mov    %eax,%edx
  800d01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d04:	39 d0                	cmp    %edx,%eax
  800d06:	73 13                	jae    800d1b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d08:	89 d9                	mov    %ebx,%ecx
  800d0a:	38 18                	cmp    %bl,(%eax)
  800d0c:	75 06                	jne    800d14 <memfind+0x1f>
  800d0e:	eb 0b                	jmp    800d1b <memfind+0x26>
  800d10:	38 08                	cmp    %cl,(%eax)
  800d12:	74 07                	je     800d1b <memfind+0x26>
	for (; s < ends; s++)
  800d14:	83 c0 01             	add    $0x1,%eax
  800d17:	39 d0                	cmp    %edx,%eax
  800d19:	75 f5                	jne    800d10 <memfind+0x1b>
			break;
	return (void *) s;
}
  800d1b:	5b                   	pop    %ebx
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d2a:	0f b6 0a             	movzbl (%edx),%ecx
  800d2d:	80 f9 09             	cmp    $0x9,%cl
  800d30:	74 05                	je     800d37 <strtol+0x19>
  800d32:	80 f9 20             	cmp    $0x20,%cl
  800d35:	75 10                	jne    800d47 <strtol+0x29>
		s++;
  800d37:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800d3a:	0f b6 0a             	movzbl (%edx),%ecx
  800d3d:	80 f9 09             	cmp    $0x9,%cl
  800d40:	74 f5                	je     800d37 <strtol+0x19>
  800d42:	80 f9 20             	cmp    $0x20,%cl
  800d45:	74 f0                	je     800d37 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800d47:	80 f9 2b             	cmp    $0x2b,%cl
  800d4a:	75 0a                	jne    800d56 <strtol+0x38>
		s++;
  800d4c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800d4f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d54:	eb 11                	jmp    800d67 <strtol+0x49>
  800d56:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800d5b:	80 f9 2d             	cmp    $0x2d,%cl
  800d5e:	75 07                	jne    800d67 <strtol+0x49>
		s++, neg = 1;
  800d60:	83 c2 01             	add    $0x1,%edx
  800d63:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d67:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800d6c:	75 15                	jne    800d83 <strtol+0x65>
  800d6e:	80 3a 30             	cmpb   $0x30,(%edx)
  800d71:	75 10                	jne    800d83 <strtol+0x65>
  800d73:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d77:	75 0a                	jne    800d83 <strtol+0x65>
		s += 2, base = 16;
  800d79:	83 c2 02             	add    $0x2,%edx
  800d7c:	b8 10 00 00 00       	mov    $0x10,%eax
  800d81:	eb 10                	jmp    800d93 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800d83:	85 c0                	test   %eax,%eax
  800d85:	75 0c                	jne    800d93 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d87:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800d89:	80 3a 30             	cmpb   $0x30,(%edx)
  800d8c:	75 05                	jne    800d93 <strtol+0x75>
		s++, base = 8;
  800d8e:	83 c2 01             	add    $0x1,%edx
  800d91:	b0 08                	mov    $0x8,%al
		base = 10;
  800d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d98:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d9b:	0f b6 0a             	movzbl (%edx),%ecx
  800d9e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800da1:	89 f0                	mov    %esi,%eax
  800da3:	3c 09                	cmp    $0x9,%al
  800da5:	77 08                	ja     800daf <strtol+0x91>
			dig = *s - '0';
  800da7:	0f be c9             	movsbl %cl,%ecx
  800daa:	83 e9 30             	sub    $0x30,%ecx
  800dad:	eb 20                	jmp    800dcf <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800daf:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800db2:	89 f0                	mov    %esi,%eax
  800db4:	3c 19                	cmp    $0x19,%al
  800db6:	77 08                	ja     800dc0 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800db8:	0f be c9             	movsbl %cl,%ecx
  800dbb:	83 e9 57             	sub    $0x57,%ecx
  800dbe:	eb 0f                	jmp    800dcf <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800dc0:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800dc3:	89 f0                	mov    %esi,%eax
  800dc5:	3c 19                	cmp    $0x19,%al
  800dc7:	77 16                	ja     800ddf <strtol+0xc1>
			dig = *s - 'A' + 10;
  800dc9:	0f be c9             	movsbl %cl,%ecx
  800dcc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dcf:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800dd2:	7d 0f                	jge    800de3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800dd4:	83 c2 01             	add    $0x1,%edx
  800dd7:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ddb:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ddd:	eb bc                	jmp    800d9b <strtol+0x7d>
  800ddf:	89 d8                	mov    %ebx,%eax
  800de1:	eb 02                	jmp    800de5 <strtol+0xc7>
  800de3:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800de5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de9:	74 05                	je     800df0 <strtol+0xd2>
		*endptr = (char *) s;
  800deb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dee:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800df0:	f7 d8                	neg    %eax
  800df2:	85 ff                	test   %edi,%edi
  800df4:	0f 44 c3             	cmove  %ebx,%eax
}
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e02:	b8 00 00 00 00       	mov    $0x0,%eax
  800e07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0d:	89 c3                	mov    %eax,%ebx
  800e0f:	89 c7                	mov    %eax,%edi
  800e11:	89 c6                	mov    %eax,%esi
  800e13:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <sys_cgetc>:

int
sys_cgetc(void)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	57                   	push   %edi
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e20:	ba 00 00 00 00       	mov    $0x0,%edx
  800e25:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2a:	89 d1                	mov    %edx,%ecx
  800e2c:	89 d3                	mov    %edx,%ebx
  800e2e:	89 d7                	mov    %edx,%edi
  800e30:	89 d6                	mov    %edx,%esi
  800e32:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	57                   	push   %edi
  800e3d:	56                   	push   %esi
  800e3e:	53                   	push   %ebx
  800e3f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e47:	b8 03 00 00 00       	mov    $0x3,%eax
  800e4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4f:	89 cb                	mov    %ecx,%ebx
  800e51:	89 cf                	mov    %ecx,%edi
  800e53:	89 ce                	mov    %ecx,%esi
  800e55:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e57:	85 c0                	test   %eax,%eax
  800e59:	7e 28                	jle    800e83 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e66:	00 
  800e67:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800e6e:	00 
  800e6f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e76:	00 
  800e77:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800e7e:	e8 3f f4 ff ff       	call   8002c2 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e83:	83 c4 2c             	add    $0x2c,%esp
  800e86:	5b                   	pop    %ebx
  800e87:	5e                   	pop    %esi
  800e88:	5f                   	pop    %edi
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	57                   	push   %edi
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e91:	ba 00 00 00 00       	mov    $0x0,%edx
  800e96:	b8 02 00 00 00       	mov    $0x2,%eax
  800e9b:	89 d1                	mov    %edx,%ecx
  800e9d:	89 d3                	mov    %edx,%ebx
  800e9f:	89 d7                	mov    %edx,%edi
  800ea1:	89 d6                	mov    %edx,%esi
  800ea3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ea5:	5b                   	pop    %ebx
  800ea6:	5e                   	pop    %esi
  800ea7:	5f                   	pop    %edi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <sys_yield>:

void
sys_yield(void)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800eba:	89 d1                	mov    %edx,%ecx
  800ebc:	89 d3                	mov    %edx,%ebx
  800ebe:	89 d7                	mov    %edx,%edi
  800ec0:	89 d6                	mov    %edx,%esi
  800ec2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	57                   	push   %edi
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
  800ecf:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800ed2:	be 00 00 00 00       	mov    $0x0,%esi
  800ed7:	b8 04 00 00 00       	mov    $0x4,%eax
  800edc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee5:	89 f7                	mov    %esi,%edi
  800ee7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	7e 28                	jle    800f15 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eed:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ef8:	00 
  800ef9:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800f00:	00 
  800f01:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f08:	00 
  800f09:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800f10:	e8 ad f3 ff ff       	call   8002c2 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f15:	83 c4 2c             	add    $0x2c,%esp
  800f18:	5b                   	pop    %ebx
  800f19:	5e                   	pop    %esi
  800f1a:	5f                   	pop    %edi
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    

00800f1d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	57                   	push   %edi
  800f21:	56                   	push   %esi
  800f22:	53                   	push   %ebx
  800f23:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f26:	b8 05 00 00 00       	mov    $0x5,%eax
  800f2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f34:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f37:	8b 75 18             	mov    0x18(%ebp),%esi
  800f3a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	7e 28                	jle    800f68 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f44:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f4b:	00 
  800f4c:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800f53:	00 
  800f54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5b:	00 
  800f5c:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800f63:	e8 5a f3 ff ff       	call   8002c2 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f68:	83 c4 2c             	add    $0x2c,%esp
  800f6b:	5b                   	pop    %ebx
  800f6c:	5e                   	pop    %esi
  800f6d:	5f                   	pop    %edi
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	57                   	push   %edi
  800f74:	56                   	push   %esi
  800f75:	53                   	push   %ebx
  800f76:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800f79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7e:	b8 06 00 00 00       	mov    $0x6,%eax
  800f83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f86:	8b 55 08             	mov    0x8(%ebp),%edx
  800f89:	89 df                	mov    %ebx,%edi
  800f8b:	89 de                	mov    %ebx,%esi
  800f8d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	7e 28                	jle    800fbb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f97:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f9e:	00 
  800f9f:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800fa6:	00 
  800fa7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fae:	00 
  800faf:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800fb6:	e8 07 f3 ff ff       	call   8002c2 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fbb:	83 c4 2c             	add    $0x2c,%esp
  800fbe:	5b                   	pop    %ebx
  800fbf:	5e                   	pop    %esi
  800fc0:	5f                   	pop    %edi
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    

00800fc3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	57                   	push   %edi
  800fc7:	56                   	push   %esi
  800fc8:	53                   	push   %ebx
  800fc9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800fcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd1:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdc:	89 df                	mov    %ebx,%edi
  800fde:	89 de                	mov    %ebx,%esi
  800fe0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	7e 28                	jle    80100e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fea:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ff1:	00 
  800ff2:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800ff9:	00 
  800ffa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801001:	00 
  801002:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  801009:	e8 b4 f2 ff ff       	call   8002c2 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80100e:	83 c4 2c             	add    $0x2c,%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	57                   	push   %edi
  80101a:	56                   	push   %esi
  80101b:	53                   	push   %ebx
  80101c:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80101f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801024:	b8 09 00 00 00       	mov    $0x9,%eax
  801029:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102c:	8b 55 08             	mov    0x8(%ebp),%edx
  80102f:	89 df                	mov    %ebx,%edi
  801031:	89 de                	mov    %ebx,%esi
  801033:	cd 30                	int    $0x30
	if(check && ret > 0)
  801035:	85 c0                	test   %eax,%eax
  801037:	7e 28                	jle    801061 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801039:	89 44 24 10          	mov    %eax,0x10(%esp)
  80103d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801044:	00 
  801045:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  80104c:	00 
  80104d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801054:	00 
  801055:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  80105c:	e8 61 f2 ff ff       	call   8002c2 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801061:	83 c4 2c             	add    $0x2c,%esp
  801064:	5b                   	pop    %ebx
  801065:	5e                   	pop    %esi
  801066:	5f                   	pop    %edi
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    

00801069 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	57                   	push   %edi
  80106d:	56                   	push   %esi
  80106e:	53                   	push   %ebx
  80106f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801072:	bb 00 00 00 00       	mov    $0x0,%ebx
  801077:	b8 0a 00 00 00       	mov    $0xa,%eax
  80107c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107f:	8b 55 08             	mov    0x8(%ebp),%edx
  801082:	89 df                	mov    %ebx,%edi
  801084:	89 de                	mov    %ebx,%esi
  801086:	cd 30                	int    $0x30
	if(check && ret > 0)
  801088:	85 c0                	test   %eax,%eax
  80108a:	7e 28                	jle    8010b4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801090:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801097:	00 
  801098:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  80109f:	00 
  8010a0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010a7:	00 
  8010a8:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  8010af:	e8 0e f2 ff ff       	call   8002c2 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010b4:	83 c4 2c             	add    $0x2c,%esp
  8010b7:	5b                   	pop    %ebx
  8010b8:	5e                   	pop    %esi
  8010b9:	5f                   	pop    %edi
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	57                   	push   %edi
  8010c0:	56                   	push   %esi
  8010c1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010c2:	be 00 00 00 00       	mov    $0x0,%esi
  8010c7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010da:	5b                   	pop    %ebx
  8010db:	5e                   	pop    %esi
  8010dc:	5f                   	pop    %edi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	57                   	push   %edi
  8010e3:	56                   	push   %esi
  8010e4:	53                   	push   %ebx
  8010e5:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8010e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ed:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f5:	89 cb                	mov    %ecx,%ebx
  8010f7:	89 cf                	mov    %ecx,%edi
  8010f9:	89 ce                	mov    %ecx,%esi
  8010fb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	7e 28                	jle    801129 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801101:	89 44 24 10          	mov    %eax,0x10(%esp)
  801105:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80110c:	00 
  80110d:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  801114:	00 
  801115:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80111c:	00 
  80111d:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  801124:	e8 99 f1 ff ff       	call   8002c2 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801129:	83 c4 2c             	add    $0x2c,%esp
  80112c:	5b                   	pop    %ebx
  80112d:	5e                   	pop    %esi
  80112e:	5f                   	pop    %edi
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    
  801131:	66 90                	xchg   %ax,%ax
  801133:	66 90                	xchg   %ax,%ax
  801135:	66 90                	xchg   %ax,%ax
  801137:	66 90                	xchg   %ax,%ax
  801139:	66 90                	xchg   %ax,%ax
  80113b:	66 90                	xchg   %ax,%ax
  80113d:	66 90                	xchg   %ax,%ax
  80113f:	90                   	nop

00801140 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801143:	8b 45 08             	mov    0x8(%ebp),%eax
  801146:	05 00 00 00 30       	add    $0x30000000,%eax
  80114b:	c1 e8 0c             	shr    $0xc,%eax
}
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    

00801150 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801153:	8b 45 08             	mov    0x8(%ebp),%eax
  801156:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80115b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801160:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80116a:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80116f:	a8 01                	test   $0x1,%al
  801171:	74 34                	je     8011a7 <fd_alloc+0x40>
  801173:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801178:	a8 01                	test   $0x1,%al
  80117a:	74 32                	je     8011ae <fd_alloc+0x47>
  80117c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  801181:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801183:	89 c2                	mov    %eax,%edx
  801185:	c1 ea 16             	shr    $0x16,%edx
  801188:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118f:	f6 c2 01             	test   $0x1,%dl
  801192:	74 1f                	je     8011b3 <fd_alloc+0x4c>
  801194:	89 c2                	mov    %eax,%edx
  801196:	c1 ea 0c             	shr    $0xc,%edx
  801199:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a0:	f6 c2 01             	test   $0x1,%dl
  8011a3:	75 1a                	jne    8011bf <fd_alloc+0x58>
  8011a5:	eb 0c                	jmp    8011b3 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  8011a7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8011ac:	eb 05                	jmp    8011b3 <fd_alloc+0x4c>
  8011ae:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  8011b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b6:	89 08                	mov    %ecx,(%eax)
			return 0;
  8011b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bd:	eb 1a                	jmp    8011d9 <fd_alloc+0x72>
  8011bf:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8011c4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011c9:	75 b6                	jne    801181 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  8011cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8011d4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    

008011db <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011e1:	83 f8 1f             	cmp    $0x1f,%eax
  8011e4:	77 36                	ja     80121c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011e6:	c1 e0 0c             	shl    $0xc,%eax
  8011e9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	c1 ea 16             	shr    $0x16,%edx
  8011f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011fa:	f6 c2 01             	test   $0x1,%dl
  8011fd:	74 24                	je     801223 <fd_lookup+0x48>
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	c1 ea 0c             	shr    $0xc,%edx
  801204:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120b:	f6 c2 01             	test   $0x1,%dl
  80120e:	74 1a                	je     80122a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801210:	8b 55 0c             	mov    0xc(%ebp),%edx
  801213:	89 02                	mov    %eax,(%edx)
	return 0;
  801215:	b8 00 00 00 00       	mov    $0x0,%eax
  80121a:	eb 13                	jmp    80122f <fd_lookup+0x54>
		return -E_INVAL;
  80121c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801221:	eb 0c                	jmp    80122f <fd_lookup+0x54>
		return -E_INVAL;
  801223:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801228:	eb 05                	jmp    80122f <fd_lookup+0x54>
  80122a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    

00801231 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	53                   	push   %ebx
  801235:	83 ec 14             	sub    $0x14,%esp
  801238:	8b 45 08             	mov    0x8(%ebp),%eax
  80123b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80123e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801244:	75 1e                	jne    801264 <dev_lookup+0x33>
  801246:	eb 0e                	jmp    801256 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  801248:	b8 20 30 80 00       	mov    $0x803020,%eax
  80124d:	eb 0c                	jmp    80125b <dev_lookup+0x2a>
  80124f:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801254:	eb 05                	jmp    80125b <dev_lookup+0x2a>
  801256:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  80125b:	89 03                	mov    %eax,(%ebx)
			return 0;
  80125d:	b8 00 00 00 00       	mov    $0x0,%eax
  801262:	eb 38                	jmp    80129c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  801264:	39 05 20 30 80 00    	cmp    %eax,0x803020
  80126a:	74 dc                	je     801248 <dev_lookup+0x17>
  80126c:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  801272:	74 db                	je     80124f <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801274:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80127a:	8b 52 48             	mov    0x48(%edx),%edx
  80127d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801281:	89 54 24 04          	mov    %edx,0x4(%esp)
  801285:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  80128c:	e8 2a f1 ff ff       	call   8003bb <cprintf>
	*dev = 0;
  801291:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801297:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80129c:	83 c4 14             	add    $0x14,%esp
  80129f:	5b                   	pop    %ebx
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <fd_close>:
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	56                   	push   %esi
  8012a6:	53                   	push   %ebx
  8012a7:	83 ec 20             	sub    $0x20,%esp
  8012aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b3:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012b7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012bd:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012c0:	89 04 24             	mov    %eax,(%esp)
  8012c3:	e8 13 ff ff ff       	call   8011db <fd_lookup>
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	78 05                	js     8012d1 <fd_close+0x2f>
	    || fd != fd2)
  8012cc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012cf:	74 0c                	je     8012dd <fd_close+0x3b>
		return (must_exist ? r : 0);
  8012d1:	84 db                	test   %bl,%bl
  8012d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d8:	0f 44 c2             	cmove  %edx,%eax
  8012db:	eb 3f                	jmp    80131c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e4:	8b 06                	mov    (%esi),%eax
  8012e6:	89 04 24             	mov    %eax,(%esp)
  8012e9:	e8 43 ff ff ff       	call   801231 <dev_lookup>
  8012ee:	89 c3                	mov    %eax,%ebx
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	78 16                	js     80130a <fd_close+0x68>
		if (dev->dev_close)
  8012f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f7:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8012fa:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8012ff:	85 c0                	test   %eax,%eax
  801301:	74 07                	je     80130a <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801303:	89 34 24             	mov    %esi,(%esp)
  801306:	ff d0                	call   *%eax
  801308:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  80130a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80130e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801315:	e8 56 fc ff ff       	call   800f70 <sys_page_unmap>
	return r;
  80131a:	89 d8                	mov    %ebx,%eax
}
  80131c:	83 c4 20             	add    $0x20,%esp
  80131f:	5b                   	pop    %ebx
  801320:	5e                   	pop    %esi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <close>:

int
close(int fdnum)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801329:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801330:	8b 45 08             	mov    0x8(%ebp),%eax
  801333:	89 04 24             	mov    %eax,(%esp)
  801336:	e8 a0 fe ff ff       	call   8011db <fd_lookup>
  80133b:	89 c2                	mov    %eax,%edx
  80133d:	85 d2                	test   %edx,%edx
  80133f:	78 13                	js     801354 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801341:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801348:	00 
  801349:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134c:	89 04 24             	mov    %eax,(%esp)
  80134f:	e8 4e ff ff ff       	call   8012a2 <fd_close>
}
  801354:	c9                   	leave  
  801355:	c3                   	ret    

00801356 <close_all>:

void
close_all(void)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	53                   	push   %ebx
  80135a:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80135d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801362:	89 1c 24             	mov    %ebx,(%esp)
  801365:	e8 b9 ff ff ff       	call   801323 <close>
	for (i = 0; i < MAXFD; i++)
  80136a:	83 c3 01             	add    $0x1,%ebx
  80136d:	83 fb 20             	cmp    $0x20,%ebx
  801370:	75 f0                	jne    801362 <close_all+0xc>
}
  801372:	83 c4 14             	add    $0x14,%esp
  801375:	5b                   	pop    %ebx
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    

00801378 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	57                   	push   %edi
  80137c:	56                   	push   %esi
  80137d:	53                   	push   %ebx
  80137e:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801381:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801384:	89 44 24 04          	mov    %eax,0x4(%esp)
  801388:	8b 45 08             	mov    0x8(%ebp),%eax
  80138b:	89 04 24             	mov    %eax,(%esp)
  80138e:	e8 48 fe ff ff       	call   8011db <fd_lookup>
  801393:	89 c2                	mov    %eax,%edx
  801395:	85 d2                	test   %edx,%edx
  801397:	0f 88 e1 00 00 00    	js     80147e <dup+0x106>
		return r;
	close(newfdnum);
  80139d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a0:	89 04 24             	mov    %eax,(%esp)
  8013a3:	e8 7b ff ff ff       	call   801323 <close>

	newfd = INDEX2FD(newfdnum);
  8013a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013ab:	c1 e3 0c             	shl    $0xc,%ebx
  8013ae:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013b7:	89 04 24             	mov    %eax,(%esp)
  8013ba:	e8 91 fd ff ff       	call   801150 <fd2data>
  8013bf:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8013c1:	89 1c 24             	mov    %ebx,(%esp)
  8013c4:	e8 87 fd ff ff       	call   801150 <fd2data>
  8013c9:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013cb:	89 f0                	mov    %esi,%eax
  8013cd:	c1 e8 16             	shr    $0x16,%eax
  8013d0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013d7:	a8 01                	test   $0x1,%al
  8013d9:	74 43                	je     80141e <dup+0xa6>
  8013db:	89 f0                	mov    %esi,%eax
  8013dd:	c1 e8 0c             	shr    $0xc,%eax
  8013e0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013e7:	f6 c2 01             	test   $0x1,%dl
  8013ea:	74 32                	je     80141e <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013fc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801400:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801407:	00 
  801408:	89 74 24 04          	mov    %esi,0x4(%esp)
  80140c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801413:	e8 05 fb ff ff       	call   800f1d <sys_page_map>
  801418:	89 c6                	mov    %eax,%esi
  80141a:	85 c0                	test   %eax,%eax
  80141c:	78 3e                	js     80145c <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80141e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801421:	89 c2                	mov    %eax,%edx
  801423:	c1 ea 0c             	shr    $0xc,%edx
  801426:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80142d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801433:	89 54 24 10          	mov    %edx,0x10(%esp)
  801437:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80143b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801442:	00 
  801443:	89 44 24 04          	mov    %eax,0x4(%esp)
  801447:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80144e:	e8 ca fa ff ff       	call   800f1d <sys_page_map>
  801453:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801455:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801458:	85 f6                	test   %esi,%esi
  80145a:	79 22                	jns    80147e <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80145c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801460:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801467:	e8 04 fb ff ff       	call   800f70 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80146c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801470:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801477:	e8 f4 fa ff ff       	call   800f70 <sys_page_unmap>
	return r;
  80147c:	89 f0                	mov    %esi,%eax
}
  80147e:	83 c4 3c             	add    $0x3c,%esp
  801481:	5b                   	pop    %ebx
  801482:	5e                   	pop    %esi
  801483:	5f                   	pop    %edi
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    

00801486 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	53                   	push   %ebx
  80148a:	83 ec 24             	sub    $0x24,%esp
  80148d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801490:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801493:	89 44 24 04          	mov    %eax,0x4(%esp)
  801497:	89 1c 24             	mov    %ebx,(%esp)
  80149a:	e8 3c fd ff ff       	call   8011db <fd_lookup>
  80149f:	89 c2                	mov    %eax,%edx
  8014a1:	85 d2                	test   %edx,%edx
  8014a3:	78 6d                	js     801512 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014af:	8b 00                	mov    (%eax),%eax
  8014b1:	89 04 24             	mov    %eax,(%esp)
  8014b4:	e8 78 fd ff ff       	call   801231 <dev_lookup>
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 55                	js     801512 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c0:	8b 50 08             	mov    0x8(%eax),%edx
  8014c3:	83 e2 03             	and    $0x3,%edx
  8014c6:	83 fa 01             	cmp    $0x1,%edx
  8014c9:	75 23                	jne    8014ee <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014cb:	a1 04 40 80 00       	mov    0x804004,%eax
  8014d0:	8b 40 48             	mov    0x48(%eax),%eax
  8014d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014db:	c7 04 24 d0 26 80 00 	movl   $0x8026d0,(%esp)
  8014e2:	e8 d4 ee ff ff       	call   8003bb <cprintf>
		return -E_INVAL;
  8014e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ec:	eb 24                	jmp    801512 <read+0x8c>
	}
	if (!dev->dev_read)
  8014ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f1:	8b 52 08             	mov    0x8(%edx),%edx
  8014f4:	85 d2                	test   %edx,%edx
  8014f6:	74 15                	je     80150d <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801502:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801506:	89 04 24             	mov    %eax,(%esp)
  801509:	ff d2                	call   *%edx
  80150b:	eb 05                	jmp    801512 <read+0x8c>
		return -E_NOT_SUPP;
  80150d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801512:	83 c4 24             	add    $0x24,%esp
  801515:	5b                   	pop    %ebx
  801516:	5d                   	pop    %ebp
  801517:	c3                   	ret    

00801518 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	57                   	push   %edi
  80151c:	56                   	push   %esi
  80151d:	53                   	push   %ebx
  80151e:	83 ec 1c             	sub    $0x1c,%esp
  801521:	8b 7d 08             	mov    0x8(%ebp),%edi
  801524:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801527:	85 f6                	test   %esi,%esi
  801529:	74 33                	je     80155e <readn+0x46>
  80152b:	b8 00 00 00 00       	mov    $0x0,%eax
  801530:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801535:	89 f2                	mov    %esi,%edx
  801537:	29 c2                	sub    %eax,%edx
  801539:	89 54 24 08          	mov    %edx,0x8(%esp)
  80153d:	03 45 0c             	add    0xc(%ebp),%eax
  801540:	89 44 24 04          	mov    %eax,0x4(%esp)
  801544:	89 3c 24             	mov    %edi,(%esp)
  801547:	e8 3a ff ff ff       	call   801486 <read>
		if (m < 0)
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 1b                	js     80156b <readn+0x53>
			return m;
		if (m == 0)
  801550:	85 c0                	test   %eax,%eax
  801552:	74 11                	je     801565 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  801554:	01 c3                	add    %eax,%ebx
  801556:	89 d8                	mov    %ebx,%eax
  801558:	39 f3                	cmp    %esi,%ebx
  80155a:	72 d9                	jb     801535 <readn+0x1d>
  80155c:	eb 0b                	jmp    801569 <readn+0x51>
  80155e:	b8 00 00 00 00       	mov    $0x0,%eax
  801563:	eb 06                	jmp    80156b <readn+0x53>
  801565:	89 d8                	mov    %ebx,%eax
  801567:	eb 02                	jmp    80156b <readn+0x53>
  801569:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80156b:	83 c4 1c             	add    $0x1c,%esp
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5f                   	pop    %edi
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    

00801573 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	53                   	push   %ebx
  801577:	83 ec 24             	sub    $0x24,%esp
  80157a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801580:	89 44 24 04          	mov    %eax,0x4(%esp)
  801584:	89 1c 24             	mov    %ebx,(%esp)
  801587:	e8 4f fc ff ff       	call   8011db <fd_lookup>
  80158c:	89 c2                	mov    %eax,%edx
  80158e:	85 d2                	test   %edx,%edx
  801590:	78 68                	js     8015fa <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801592:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801595:	89 44 24 04          	mov    %eax,0x4(%esp)
  801599:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159c:	8b 00                	mov    (%eax),%eax
  80159e:	89 04 24             	mov    %eax,(%esp)
  8015a1:	e8 8b fc ff ff       	call   801231 <dev_lookup>
  8015a6:	85 c0                	test   %eax,%eax
  8015a8:	78 50                	js     8015fa <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b1:	75 23                	jne    8015d6 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b8:	8b 40 48             	mov    0x48(%eax),%eax
  8015bb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c3:	c7 04 24 ec 26 80 00 	movl   $0x8026ec,(%esp)
  8015ca:	e8 ec ed ff ff       	call   8003bb <cprintf>
		return -E_INVAL;
  8015cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d4:	eb 24                	jmp    8015fa <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d9:	8b 52 0c             	mov    0xc(%edx),%edx
  8015dc:	85 d2                	test   %edx,%edx
  8015de:	74 15                	je     8015f5 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ea:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015ee:	89 04 24             	mov    %eax,(%esp)
  8015f1:	ff d2                	call   *%edx
  8015f3:	eb 05                	jmp    8015fa <write+0x87>
		return -E_NOT_SUPP;
  8015f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8015fa:	83 c4 24             	add    $0x24,%esp
  8015fd:	5b                   	pop    %ebx
  8015fe:	5d                   	pop    %ebp
  8015ff:	c3                   	ret    

00801600 <seek>:

int
seek(int fdnum, off_t offset)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801606:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801609:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160d:	8b 45 08             	mov    0x8(%ebp),%eax
  801610:	89 04 24             	mov    %eax,(%esp)
  801613:	e8 c3 fb ff ff       	call   8011db <fd_lookup>
  801618:	85 c0                	test   %eax,%eax
  80161a:	78 0e                	js     80162a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80161c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80161f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801622:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801625:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80162a:	c9                   	leave  
  80162b:	c3                   	ret    

0080162c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	53                   	push   %ebx
  801630:	83 ec 24             	sub    $0x24,%esp
  801633:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801636:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801639:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163d:	89 1c 24             	mov    %ebx,(%esp)
  801640:	e8 96 fb ff ff       	call   8011db <fd_lookup>
  801645:	89 c2                	mov    %eax,%edx
  801647:	85 d2                	test   %edx,%edx
  801649:	78 61                	js     8016ac <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801652:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801655:	8b 00                	mov    (%eax),%eax
  801657:	89 04 24             	mov    %eax,(%esp)
  80165a:	e8 d2 fb ff ff       	call   801231 <dev_lookup>
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 49                	js     8016ac <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801663:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801666:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80166a:	75 23                	jne    80168f <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80166c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801671:	8b 40 48             	mov    0x48(%eax),%eax
  801674:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801678:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167c:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  801683:	e8 33 ed ff ff       	call   8003bb <cprintf>
		return -E_INVAL;
  801688:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80168d:	eb 1d                	jmp    8016ac <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80168f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801692:	8b 52 18             	mov    0x18(%edx),%edx
  801695:	85 d2                	test   %edx,%edx
  801697:	74 0e                	je     8016a7 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801699:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80169c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016a0:	89 04 24             	mov    %eax,(%esp)
  8016a3:	ff d2                	call   *%edx
  8016a5:	eb 05                	jmp    8016ac <ftruncate+0x80>
		return -E_NOT_SUPP;
  8016a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8016ac:	83 c4 24             	add    $0x24,%esp
  8016af:	5b                   	pop    %ebx
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    

008016b2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	53                   	push   %ebx
  8016b6:	83 ec 24             	sub    $0x24,%esp
  8016b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c6:	89 04 24             	mov    %eax,(%esp)
  8016c9:	e8 0d fb ff ff       	call   8011db <fd_lookup>
  8016ce:	89 c2                	mov    %eax,%edx
  8016d0:	85 d2                	test   %edx,%edx
  8016d2:	78 52                	js     801726 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016de:	8b 00                	mov    (%eax),%eax
  8016e0:	89 04 24             	mov    %eax,(%esp)
  8016e3:	e8 49 fb ff ff       	call   801231 <dev_lookup>
  8016e8:	85 c0                	test   %eax,%eax
  8016ea:	78 3a                	js     801726 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8016ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ef:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016f3:	74 2c                	je     801721 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ff:	00 00 00 
	stat->st_isdir = 0;
  801702:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801709:	00 00 00 
	stat->st_dev = dev;
  80170c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801712:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801716:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801719:	89 14 24             	mov    %edx,(%esp)
  80171c:	ff 50 14             	call   *0x14(%eax)
  80171f:	eb 05                	jmp    801726 <fstat+0x74>
		return -E_NOT_SUPP;
  801721:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801726:	83 c4 24             	add    $0x24,%esp
  801729:	5b                   	pop    %ebx
  80172a:	5d                   	pop    %ebp
  80172b:	c3                   	ret    

0080172c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	56                   	push   %esi
  801730:	53                   	push   %ebx
  801731:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801734:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80173b:	00 
  80173c:	8b 45 08             	mov    0x8(%ebp),%eax
  80173f:	89 04 24             	mov    %eax,(%esp)
  801742:	e8 af 01 00 00       	call   8018f6 <open>
  801747:	89 c3                	mov    %eax,%ebx
  801749:	85 db                	test   %ebx,%ebx
  80174b:	78 1b                	js     801768 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80174d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801750:	89 44 24 04          	mov    %eax,0x4(%esp)
  801754:	89 1c 24             	mov    %ebx,(%esp)
  801757:	e8 56 ff ff ff       	call   8016b2 <fstat>
  80175c:	89 c6                	mov    %eax,%esi
	close(fd);
  80175e:	89 1c 24             	mov    %ebx,(%esp)
  801761:	e8 bd fb ff ff       	call   801323 <close>
	return r;
  801766:	89 f0                	mov    %esi,%eax
}
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	5b                   	pop    %ebx
  80176c:	5e                   	pop    %esi
  80176d:	5d                   	pop    %ebp
  80176e:	c3                   	ret    

0080176f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	56                   	push   %esi
  801773:	53                   	push   %ebx
  801774:	83 ec 10             	sub    $0x10,%esp
  801777:	89 c6                	mov    %eax,%esi
  801779:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80177b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801782:	75 11                	jne    801795 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801784:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80178b:	e8 fa 07 00 00       	call   801f8a <ipc_find_env>
  801790:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801795:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80179c:	00 
  80179d:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8017a4:	00 
  8017a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017a9:	a1 00 40 80 00       	mov    0x804000,%eax
  8017ae:	89 04 24             	mov    %eax,(%esp)
  8017b1:	e8 8c 07 00 00       	call   801f42 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017bd:	00 
  8017be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c9:	e8 18 07 00 00       	call   801ee6 <ipc_recv>
}
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	5b                   	pop    %ebx
  8017d2:	5e                   	pop    %esi
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	53                   	push   %ebx
  8017d9:	83 ec 14             	sub    $0x14,%esp
  8017dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ef:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f4:	e8 76 ff ff ff       	call   80176f <fsipc>
  8017f9:	89 c2                	mov    %eax,%edx
  8017fb:	85 d2                	test   %edx,%edx
  8017fd:	78 2b                	js     80182a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ff:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801806:	00 
  801807:	89 1c 24             	mov    %ebx,(%esp)
  80180a:	e8 0c f2 ff ff       	call   800a1b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80180f:	a1 80 50 80 00       	mov    0x805080,%eax
  801814:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80181a:	a1 84 50 80 00       	mov    0x805084,%eax
  80181f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801825:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182a:	83 c4 14             	add    $0x14,%esp
  80182d:	5b                   	pop    %ebx
  80182e:	5d                   	pop    %ebp
  80182f:	c3                   	ret    

00801830 <devfile_flush>:
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801836:	8b 45 08             	mov    0x8(%ebp),%eax
  801839:	8b 40 0c             	mov    0xc(%eax),%eax
  80183c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801841:	ba 00 00 00 00       	mov    $0x0,%edx
  801846:	b8 06 00 00 00       	mov    $0x6,%eax
  80184b:	e8 1f ff ff ff       	call   80176f <fsipc>
}
  801850:	c9                   	leave  
  801851:	c3                   	ret    

00801852 <devfile_read>:
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	56                   	push   %esi
  801856:	53                   	push   %ebx
  801857:	83 ec 10             	sub    $0x10,%esp
  80185a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80185d:	8b 45 08             	mov    0x8(%ebp),%eax
  801860:	8b 40 0c             	mov    0xc(%eax),%eax
  801863:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801868:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80186e:	ba 00 00 00 00       	mov    $0x0,%edx
  801873:	b8 03 00 00 00       	mov    $0x3,%eax
  801878:	e8 f2 fe ff ff       	call   80176f <fsipc>
  80187d:	89 c3                	mov    %eax,%ebx
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 6a                	js     8018ed <devfile_read+0x9b>
	assert(r <= n);
  801883:	39 c6                	cmp    %eax,%esi
  801885:	73 24                	jae    8018ab <devfile_read+0x59>
  801887:	c7 44 24 0c 09 27 80 	movl   $0x802709,0xc(%esp)
  80188e:	00 
  80188f:	c7 44 24 08 10 27 80 	movl   $0x802710,0x8(%esp)
  801896:	00 
  801897:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80189e:	00 
  80189f:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  8018a6:	e8 17 ea ff ff       	call   8002c2 <_panic>
	assert(r <= PGSIZE);
  8018ab:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b0:	7e 24                	jle    8018d6 <devfile_read+0x84>
  8018b2:	c7 44 24 0c 30 27 80 	movl   $0x802730,0xc(%esp)
  8018b9:	00 
  8018ba:	c7 44 24 08 10 27 80 	movl   $0x802710,0x8(%esp)
  8018c1:	00 
  8018c2:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  8018c9:	00 
  8018ca:	c7 04 24 25 27 80 00 	movl   $0x802725,(%esp)
  8018d1:	e8 ec e9 ff ff       	call   8002c2 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018da:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018e1:	00 
  8018e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e5:	89 04 24             	mov    %eax,(%esp)
  8018e8:	e8 29 f3 ff ff       	call   800c16 <memmove>
}
  8018ed:	89 d8                	mov    %ebx,%eax
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	5b                   	pop    %ebx
  8018f3:	5e                   	pop    %esi
  8018f4:	5d                   	pop    %ebp
  8018f5:	c3                   	ret    

008018f6 <open>:
{
  8018f6:	55                   	push   %ebp
  8018f7:	89 e5                	mov    %esp,%ebp
  8018f9:	53                   	push   %ebx
  8018fa:	83 ec 24             	sub    $0x24,%esp
  8018fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801900:	89 1c 24             	mov    %ebx,(%esp)
  801903:	e8 b8 f0 ff ff       	call   8009c0 <strlen>
  801908:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80190d:	7f 60                	jg     80196f <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  80190f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801912:	89 04 24             	mov    %eax,(%esp)
  801915:	e8 4d f8 ff ff       	call   801167 <fd_alloc>
  80191a:	89 c2                	mov    %eax,%edx
  80191c:	85 d2                	test   %edx,%edx
  80191e:	78 54                	js     801974 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801920:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801924:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80192b:	e8 eb f0 ff ff       	call   800a1b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801930:	8b 45 0c             	mov    0xc(%ebp),%eax
  801933:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801938:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193b:	b8 01 00 00 00       	mov    $0x1,%eax
  801940:	e8 2a fe ff ff       	call   80176f <fsipc>
  801945:	89 c3                	mov    %eax,%ebx
  801947:	85 c0                	test   %eax,%eax
  801949:	79 17                	jns    801962 <open+0x6c>
		fd_close(fd, 0);
  80194b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801952:	00 
  801953:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801956:	89 04 24             	mov    %eax,(%esp)
  801959:	e8 44 f9 ff ff       	call   8012a2 <fd_close>
		return r;
  80195e:	89 d8                	mov    %ebx,%eax
  801960:	eb 12                	jmp    801974 <open+0x7e>
	return fd2num(fd);
  801962:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801965:	89 04 24             	mov    %eax,(%esp)
  801968:	e8 d3 f7 ff ff       	call   801140 <fd2num>
  80196d:	eb 05                	jmp    801974 <open+0x7e>
		return -E_BAD_PATH;
  80196f:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801974:	83 c4 24             	add    $0x24,%esp
  801977:	5b                   	pop    %ebx
  801978:	5d                   	pop    %ebp
  801979:	c3                   	ret    
  80197a:	66 90                	xchg   %ax,%ax
  80197c:	66 90                	xchg   %ax,%ax
  80197e:	66 90                	xchg   %ax,%ax

00801980 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	56                   	push   %esi
  801984:	53                   	push   %ebx
  801985:	83 ec 10             	sub    $0x10,%esp
  801988:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80198b:	8b 45 08             	mov    0x8(%ebp),%eax
  80198e:	89 04 24             	mov    %eax,(%esp)
  801991:	e8 ba f7 ff ff       	call   801150 <fd2data>
  801996:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801998:	c7 44 24 04 3c 27 80 	movl   $0x80273c,0x4(%esp)
  80199f:	00 
  8019a0:	89 1c 24             	mov    %ebx,(%esp)
  8019a3:	e8 73 f0 ff ff       	call   800a1b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019a8:	8b 46 04             	mov    0x4(%esi),%eax
  8019ab:	2b 06                	sub    (%esi),%eax
  8019ad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019ba:	00 00 00 
	stat->st_dev = &devpipe;
  8019bd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019c4:	30 80 00 
	return 0;
}
  8019c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	5b                   	pop    %ebx
  8019d0:	5e                   	pop    %esi
  8019d1:	5d                   	pop    %ebp
  8019d2:	c3                   	ret    

008019d3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	53                   	push   %ebx
  8019d7:	83 ec 14             	sub    $0x14,%esp
  8019da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e8:	e8 83 f5 ff ff       	call   800f70 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019ed:	89 1c 24             	mov    %ebx,(%esp)
  8019f0:	e8 5b f7 ff ff       	call   801150 <fd2data>
  8019f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a00:	e8 6b f5 ff ff       	call   800f70 <sys_page_unmap>
}
  801a05:	83 c4 14             	add    $0x14,%esp
  801a08:	5b                   	pop    %ebx
  801a09:	5d                   	pop    %ebp
  801a0a:	c3                   	ret    

00801a0b <_pipeisclosed>:
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	57                   	push   %edi
  801a0f:	56                   	push   %esi
  801a10:	53                   	push   %ebx
  801a11:	83 ec 2c             	sub    $0x2c,%esp
  801a14:	89 c6                	mov    %eax,%esi
  801a16:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801a19:	a1 04 40 80 00       	mov    0x804004,%eax
  801a1e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a21:	89 34 24             	mov    %esi,(%esp)
  801a24:	e8 a9 05 00 00       	call   801fd2 <pageref>
  801a29:	89 c7                	mov    %eax,%edi
  801a2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a2e:	89 04 24             	mov    %eax,(%esp)
  801a31:	e8 9c 05 00 00       	call   801fd2 <pageref>
  801a36:	39 c7                	cmp    %eax,%edi
  801a38:	0f 94 c2             	sete   %dl
  801a3b:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801a3e:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801a44:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801a47:	39 fb                	cmp    %edi,%ebx
  801a49:	74 21                	je     801a6c <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801a4b:	84 d2                	test   %dl,%dl
  801a4d:	74 ca                	je     801a19 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a4f:	8b 51 58             	mov    0x58(%ecx),%edx
  801a52:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a56:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a5a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a5e:	c7 04 24 43 27 80 00 	movl   $0x802743,(%esp)
  801a65:	e8 51 e9 ff ff       	call   8003bb <cprintf>
  801a6a:	eb ad                	jmp    801a19 <_pipeisclosed+0xe>
}
  801a6c:	83 c4 2c             	add    $0x2c,%esp
  801a6f:	5b                   	pop    %ebx
  801a70:	5e                   	pop    %esi
  801a71:	5f                   	pop    %edi
  801a72:	5d                   	pop    %ebp
  801a73:	c3                   	ret    

00801a74 <devpipe_write>:
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	57                   	push   %edi
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
  801a7a:	83 ec 1c             	sub    $0x1c,%esp
  801a7d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801a80:	89 34 24             	mov    %esi,(%esp)
  801a83:	e8 c8 f6 ff ff       	call   801150 <fd2data>
	for (i = 0; i < n; i++) {
  801a88:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a8c:	74 61                	je     801aef <devpipe_write+0x7b>
  801a8e:	89 c3                	mov    %eax,%ebx
  801a90:	bf 00 00 00 00       	mov    $0x0,%edi
  801a95:	eb 4a                	jmp    801ae1 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  801a97:	89 da                	mov    %ebx,%edx
  801a99:	89 f0                	mov    %esi,%eax
  801a9b:	e8 6b ff ff ff       	call   801a0b <_pipeisclosed>
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	75 54                	jne    801af8 <devpipe_write+0x84>
			sys_yield();
  801aa4:	e8 01 f4 ff ff       	call   800eaa <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aa9:	8b 43 04             	mov    0x4(%ebx),%eax
  801aac:	8b 0b                	mov    (%ebx),%ecx
  801aae:	8d 51 20             	lea    0x20(%ecx),%edx
  801ab1:	39 d0                	cmp    %edx,%eax
  801ab3:	73 e2                	jae    801a97 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ab5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801abc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801abf:	99                   	cltd   
  801ac0:	c1 ea 1b             	shr    $0x1b,%edx
  801ac3:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801ac6:	83 e1 1f             	and    $0x1f,%ecx
  801ac9:	29 d1                	sub    %edx,%ecx
  801acb:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801acf:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801ad3:	83 c0 01             	add    $0x1,%eax
  801ad6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ad9:	83 c7 01             	add    $0x1,%edi
  801adc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801adf:	74 13                	je     801af4 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ae1:	8b 43 04             	mov    0x4(%ebx),%eax
  801ae4:	8b 0b                	mov    (%ebx),%ecx
  801ae6:	8d 51 20             	lea    0x20(%ecx),%edx
  801ae9:	39 d0                	cmp    %edx,%eax
  801aeb:	73 aa                	jae    801a97 <devpipe_write+0x23>
  801aed:	eb c6                	jmp    801ab5 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  801aef:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  801af4:	89 f8                	mov    %edi,%eax
  801af6:	eb 05                	jmp    801afd <devpipe_write+0x89>
				return 0;
  801af8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801afd:	83 c4 1c             	add    $0x1c,%esp
  801b00:	5b                   	pop    %ebx
  801b01:	5e                   	pop    %esi
  801b02:	5f                   	pop    %edi
  801b03:	5d                   	pop    %ebp
  801b04:	c3                   	ret    

00801b05 <devpipe_read>:
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	57                   	push   %edi
  801b09:	56                   	push   %esi
  801b0a:	53                   	push   %ebx
  801b0b:	83 ec 1c             	sub    $0x1c,%esp
  801b0e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b11:	89 3c 24             	mov    %edi,(%esp)
  801b14:	e8 37 f6 ff ff       	call   801150 <fd2data>
	for (i = 0; i < n; i++) {
  801b19:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b1d:	74 54                	je     801b73 <devpipe_read+0x6e>
  801b1f:	89 c3                	mov    %eax,%ebx
  801b21:	be 00 00 00 00       	mov    $0x0,%esi
  801b26:	eb 3e                	jmp    801b66 <devpipe_read+0x61>
				return i;
  801b28:	89 f0                	mov    %esi,%eax
  801b2a:	eb 55                	jmp    801b81 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  801b2c:	89 da                	mov    %ebx,%edx
  801b2e:	89 f8                	mov    %edi,%eax
  801b30:	e8 d6 fe ff ff       	call   801a0b <_pipeisclosed>
  801b35:	85 c0                	test   %eax,%eax
  801b37:	75 43                	jne    801b7c <devpipe_read+0x77>
			sys_yield();
  801b39:	e8 6c f3 ff ff       	call   800eaa <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b3e:	8b 03                	mov    (%ebx),%eax
  801b40:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b43:	74 e7                	je     801b2c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b45:	99                   	cltd   
  801b46:	c1 ea 1b             	shr    $0x1b,%edx
  801b49:	01 d0                	add    %edx,%eax
  801b4b:	83 e0 1f             	and    $0x1f,%eax
  801b4e:	29 d0                	sub    %edx,%eax
  801b50:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b58:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b5b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b5e:	83 c6 01             	add    $0x1,%esi
  801b61:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b64:	74 12                	je     801b78 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  801b66:	8b 03                	mov    (%ebx),%eax
  801b68:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b6b:	75 d8                	jne    801b45 <devpipe_read+0x40>
			if (i > 0)
  801b6d:	85 f6                	test   %esi,%esi
  801b6f:	75 b7                	jne    801b28 <devpipe_read+0x23>
  801b71:	eb b9                	jmp    801b2c <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  801b73:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  801b78:	89 f0                	mov    %esi,%eax
  801b7a:	eb 05                	jmp    801b81 <devpipe_read+0x7c>
				return 0;
  801b7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b81:	83 c4 1c             	add    $0x1c,%esp
  801b84:	5b                   	pop    %ebx
  801b85:	5e                   	pop    %esi
  801b86:	5f                   	pop    %edi
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <pipe>:
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	56                   	push   %esi
  801b8d:	53                   	push   %ebx
  801b8e:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b94:	89 04 24             	mov    %eax,(%esp)
  801b97:	e8 cb f5 ff ff       	call   801167 <fd_alloc>
  801b9c:	89 c2                	mov    %eax,%edx
  801b9e:	85 d2                	test   %edx,%edx
  801ba0:	0f 88 4d 01 00 00    	js     801cf3 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bad:	00 
  801bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bbc:	e8 08 f3 ff ff       	call   800ec9 <sys_page_alloc>
  801bc1:	89 c2                	mov    %eax,%edx
  801bc3:	85 d2                	test   %edx,%edx
  801bc5:	0f 88 28 01 00 00    	js     801cf3 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801bcb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bce:	89 04 24             	mov    %eax,(%esp)
  801bd1:	e8 91 f5 ff ff       	call   801167 <fd_alloc>
  801bd6:	89 c3                	mov    %eax,%ebx
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	0f 88 fe 00 00 00    	js     801cde <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801be7:	00 
  801be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801beb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf6:	e8 ce f2 ff ff       	call   800ec9 <sys_page_alloc>
  801bfb:	89 c3                	mov    %eax,%ebx
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	0f 88 d9 00 00 00    	js     801cde <pipe+0x155>
	va = fd2data(fd0);
  801c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c08:	89 04 24             	mov    %eax,(%esp)
  801c0b:	e8 40 f5 ff ff       	call   801150 <fd2data>
  801c10:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c12:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c19:	00 
  801c1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c25:	e8 9f f2 ff ff       	call   800ec9 <sys_page_alloc>
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	0f 88 97 00 00 00    	js     801ccb <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c37:	89 04 24             	mov    %eax,(%esp)
  801c3a:	e8 11 f5 ff ff       	call   801150 <fd2data>
  801c3f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801c46:	00 
  801c47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c52:	00 
  801c53:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c5e:	e8 ba f2 ff ff       	call   800f1d <sys_page_map>
  801c63:	89 c3                	mov    %eax,%ebx
  801c65:	85 c0                	test   %eax,%eax
  801c67:	78 52                	js     801cbb <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  801c69:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c72:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c77:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801c7e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c87:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c8c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c96:	89 04 24             	mov    %eax,(%esp)
  801c99:	e8 a2 f4 ff ff       	call   801140 <fd2num>
  801c9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca6:	89 04 24             	mov    %eax,(%esp)
  801ca9:	e8 92 f4 ff ff       	call   801140 <fd2num>
  801cae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cb4:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb9:	eb 38                	jmp    801cf3 <pipe+0x16a>
	sys_page_unmap(0, va);
  801cbb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc6:	e8 a5 f2 ff ff       	call   800f70 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  801ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd9:	e8 92 f2 ff ff       	call   800f70 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  801cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cec:	e8 7f f2 ff ff       	call   800f70 <sys_page_unmap>
  801cf1:	89 d8                	mov    %ebx,%eax
}
  801cf3:	83 c4 30             	add    $0x30,%esp
  801cf6:	5b                   	pop    %ebx
  801cf7:	5e                   	pop    %esi
  801cf8:	5d                   	pop    %ebp
  801cf9:	c3                   	ret    

00801cfa <pipeisclosed>:
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d07:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0a:	89 04 24             	mov    %eax,(%esp)
  801d0d:	e8 c9 f4 ff ff       	call   8011db <fd_lookup>
  801d12:	89 c2                	mov    %eax,%edx
  801d14:	85 d2                	test   %edx,%edx
  801d16:	78 15                	js     801d2d <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  801d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1b:	89 04 24             	mov    %eax,(%esp)
  801d1e:	e8 2d f4 ff ff       	call   801150 <fd2data>
	return _pipeisclosed(fd, p);
  801d23:	89 c2                	mov    %eax,%edx
  801d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d28:	e8 de fc ff ff       	call   801a0b <_pipeisclosed>
}
  801d2d:	c9                   	leave  
  801d2e:	c3                   	ret    
  801d2f:	90                   	nop

00801d30 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d33:	b8 00 00 00 00       	mov    $0x0,%eax
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    

00801d3a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801d40:	c7 44 24 04 5b 27 80 	movl   $0x80275b,0x4(%esp)
  801d47:	00 
  801d48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4b:	89 04 24             	mov    %eax,(%esp)
  801d4e:	e8 c8 ec ff ff       	call   800a1b <strcpy>
	return 0;
}
  801d53:	b8 00 00 00 00       	mov    $0x0,%eax
  801d58:	c9                   	leave  
  801d59:	c3                   	ret    

00801d5a <devcons_write>:
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	57                   	push   %edi
  801d5e:	56                   	push   %esi
  801d5f:	53                   	push   %ebx
  801d60:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d66:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d6a:	74 4a                	je     801db6 <devcons_write+0x5c>
  801d6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d71:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d76:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  801d7c:	8b 75 10             	mov    0x10(%ebp),%esi
  801d7f:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  801d81:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801d84:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d89:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d8c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d90:	03 45 0c             	add    0xc(%ebp),%eax
  801d93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d97:	89 3c 24             	mov    %edi,(%esp)
  801d9a:	e8 77 ee ff ff       	call   800c16 <memmove>
		sys_cputs(buf, m);
  801d9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801da3:	89 3c 24             	mov    %edi,(%esp)
  801da6:	e8 51 f0 ff ff       	call   800dfc <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801dab:	01 f3                	add    %esi,%ebx
  801dad:	89 d8                	mov    %ebx,%eax
  801daf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801db2:	72 c8                	jb     801d7c <devcons_write+0x22>
  801db4:	eb 05                	jmp    801dbb <devcons_write+0x61>
  801db6:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  801dbb:	89 d8                	mov    %ebx,%eax
  801dbd:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801dc3:	5b                   	pop    %ebx
  801dc4:	5e                   	pop    %esi
  801dc5:	5f                   	pop    %edi
  801dc6:	5d                   	pop    %ebp
  801dc7:	c3                   	ret    

00801dc8 <devcons_read>:
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	83 ec 08             	sub    $0x8,%esp
		return 0;
  801dce:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801dd3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dd7:	75 07                	jne    801de0 <devcons_read+0x18>
  801dd9:	eb 28                	jmp    801e03 <devcons_read+0x3b>
		sys_yield();
  801ddb:	e8 ca f0 ff ff       	call   800eaa <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801de0:	e8 35 f0 ff ff       	call   800e1a <sys_cgetc>
  801de5:	85 c0                	test   %eax,%eax
  801de7:	74 f2                	je     801ddb <devcons_read+0x13>
	if (c < 0)
  801de9:	85 c0                	test   %eax,%eax
  801deb:	78 16                	js     801e03 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  801ded:	83 f8 04             	cmp    $0x4,%eax
  801df0:	74 0c                	je     801dfe <devcons_read+0x36>
	*(char*)vbuf = c;
  801df2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df5:	88 02                	mov    %al,(%edx)
	return 1;
  801df7:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfc:	eb 05                	jmp    801e03 <devcons_read+0x3b>
		return 0;
  801dfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e03:	c9                   	leave  
  801e04:	c3                   	ret    

00801e05 <cputchar>:
{
  801e05:	55                   	push   %ebp
  801e06:	89 e5                	mov    %esp,%ebp
  801e08:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e11:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e18:	00 
  801e19:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e1c:	89 04 24             	mov    %eax,(%esp)
  801e1f:	e8 d8 ef ff ff       	call   800dfc <sys_cputs>
}
  801e24:	c9                   	leave  
  801e25:	c3                   	ret    

00801e26 <getchar>:
{
  801e26:	55                   	push   %ebp
  801e27:	89 e5                	mov    %esp,%ebp
  801e29:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  801e2c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801e33:	00 
  801e34:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e42:	e8 3f f6 ff ff       	call   801486 <read>
	if (r < 0)
  801e47:	85 c0                	test   %eax,%eax
  801e49:	78 0f                	js     801e5a <getchar+0x34>
	if (r < 1)
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	7e 06                	jle    801e55 <getchar+0x2f>
	return c;
  801e4f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e53:	eb 05                	jmp    801e5a <getchar+0x34>
		return -E_EOF;
  801e55:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  801e5a:	c9                   	leave  
  801e5b:	c3                   	ret    

00801e5c <iscons>:
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e69:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6c:	89 04 24             	mov    %eax,(%esp)
  801e6f:	e8 67 f3 ff ff       	call   8011db <fd_lookup>
  801e74:	85 c0                	test   %eax,%eax
  801e76:	78 11                	js     801e89 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e81:	39 10                	cmp    %edx,(%eax)
  801e83:	0f 94 c0             	sete   %al
  801e86:	0f b6 c0             	movzbl %al,%eax
}
  801e89:	c9                   	leave  
  801e8a:	c3                   	ret    

00801e8b <opencons>:
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
  801e8e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e94:	89 04 24             	mov    %eax,(%esp)
  801e97:	e8 cb f2 ff ff       	call   801167 <fd_alloc>
		return r;
  801e9c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 40                	js     801ee2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ea2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ea9:	00 
  801eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ead:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb8:	e8 0c f0 ff ff       	call   800ec9 <sys_page_alloc>
		return r;
  801ebd:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	78 1f                	js     801ee2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801ec3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ecc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ed8:	89 04 24             	mov    %eax,(%esp)
  801edb:	e8 60 f2 ff ff       	call   801140 <fd2num>
  801ee0:	89 c2                	mov    %eax,%edx
}
  801ee2:	89 d0                	mov    %edx,%eax
  801ee4:	c9                   	leave  
  801ee5:	c3                   	ret    

00801ee6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	56                   	push   %esi
  801eea:	53                   	push   %ebx
  801eeb:	83 ec 10             	sub    $0x10,%esp
  801eee:	8b 75 08             	mov    0x8(%ebp),%esi
  801ef1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  801ef4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef7:	89 04 24             	mov    %eax,(%esp)
  801efa:	e8 e0 f1 ff ff       	call   8010df <sys_ipc_recv>
	if(from_env_store)
  801eff:	85 f6                	test   %esi,%esi
  801f01:	74 14                	je     801f17 <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  801f03:	ba 00 00 00 00       	mov    $0x0,%edx
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	78 09                	js     801f15 <ipc_recv+0x2f>
  801f0c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f12:	8b 52 74             	mov    0x74(%edx),%edx
  801f15:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  801f17:	85 db                	test   %ebx,%ebx
  801f19:	74 14                	je     801f2f <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  801f1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f20:	85 c0                	test   %eax,%eax
  801f22:	78 09                	js     801f2d <ipc_recv+0x47>
  801f24:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f2a:	8b 52 78             	mov    0x78(%edx),%edx
  801f2d:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	78 08                	js     801f3b <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  801f33:	a1 04 40 80 00       	mov    0x804004,%eax
  801f38:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f3b:	83 c4 10             	add    $0x10,%esp
  801f3e:	5b                   	pop    %ebx
  801f3f:	5e                   	pop    %esi
  801f40:	5d                   	pop    %ebp
  801f41:	c3                   	ret    

00801f42 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	57                   	push   %edi
  801f46:	56                   	push   %esi
  801f47:	53                   	push   %ebx
  801f48:	83 ec 1c             	sub    $0x1c,%esp
  801f4b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f4e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  801f51:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801f56:	eb 0c                	jmp    801f64 <ipc_send+0x22>
		failed_cnt++;
  801f58:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  801f5b:	84 db                	test   %bl,%bl
  801f5d:	75 05                	jne    801f64 <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  801f5f:	e8 46 ef ff ff       	call   800eaa <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801f64:	8b 45 14             	mov    0x14(%ebp),%eax
  801f67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f6b:	8b 45 10             	mov    0x10(%ebp),%eax
  801f6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f72:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f76:	89 3c 24             	mov    %edi,(%esp)
  801f79:	e8 3e f1 ff ff       	call   8010bc <sys_ipc_try_send>
  801f7e:	85 c0                	test   %eax,%eax
  801f80:	78 d6                	js     801f58 <ipc_send+0x16>
	}
}
  801f82:	83 c4 1c             	add    $0x1c,%esp
  801f85:	5b                   	pop    %ebx
  801f86:	5e                   	pop    %esi
  801f87:	5f                   	pop    %edi
  801f88:	5d                   	pop    %ebp
  801f89:	c3                   	ret    

00801f8a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f90:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801f95:	39 c8                	cmp    %ecx,%eax
  801f97:	74 17                	je     801fb0 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  801f99:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801f9e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fa1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fa7:	8b 52 50             	mov    0x50(%edx),%edx
  801faa:	39 ca                	cmp    %ecx,%edx
  801fac:	75 14                	jne    801fc2 <ipc_find_env+0x38>
  801fae:	eb 05                	jmp    801fb5 <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  801fb0:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  801fb5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fb8:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801fbd:	8b 40 40             	mov    0x40(%eax),%eax
  801fc0:	eb 0e                	jmp    801fd0 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  801fc2:	83 c0 01             	add    $0x1,%eax
  801fc5:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fca:	75 d2                	jne    801f9e <ipc_find_env+0x14>
	return 0;
  801fcc:	66 b8 00 00          	mov    $0x0,%ax
}
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    

00801fd2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fd8:	89 d0                	mov    %edx,%eax
  801fda:	c1 e8 16             	shr    $0x16,%eax
  801fdd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fe4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801fe9:	f6 c1 01             	test   $0x1,%cl
  801fec:	74 1d                	je     80200b <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801fee:	c1 ea 0c             	shr    $0xc,%edx
  801ff1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ff8:	f6 c2 01             	test   $0x1,%dl
  801ffb:	74 0e                	je     80200b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ffd:	c1 ea 0c             	shr    $0xc,%edx
  802000:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802007:	ef 
  802008:	0f b7 c0             	movzwl %ax,%eax
}
  80200b:	5d                   	pop    %ebp
  80200c:	c3                   	ret    
  80200d:	66 90                	xchg   %ax,%ax
  80200f:	90                   	nop

00802010 <__udivdi3>:
  802010:	55                   	push   %ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	83 ec 0c             	sub    $0xc,%esp
  802016:	8b 44 24 28          	mov    0x28(%esp),%eax
  80201a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80201e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802022:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802026:	85 c0                	test   %eax,%eax
  802028:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80202c:	89 ea                	mov    %ebp,%edx
  80202e:	89 0c 24             	mov    %ecx,(%esp)
  802031:	75 2d                	jne    802060 <__udivdi3+0x50>
  802033:	39 e9                	cmp    %ebp,%ecx
  802035:	77 61                	ja     802098 <__udivdi3+0x88>
  802037:	85 c9                	test   %ecx,%ecx
  802039:	89 ce                	mov    %ecx,%esi
  80203b:	75 0b                	jne    802048 <__udivdi3+0x38>
  80203d:	b8 01 00 00 00       	mov    $0x1,%eax
  802042:	31 d2                	xor    %edx,%edx
  802044:	f7 f1                	div    %ecx
  802046:	89 c6                	mov    %eax,%esi
  802048:	31 d2                	xor    %edx,%edx
  80204a:	89 e8                	mov    %ebp,%eax
  80204c:	f7 f6                	div    %esi
  80204e:	89 c5                	mov    %eax,%ebp
  802050:	89 f8                	mov    %edi,%eax
  802052:	f7 f6                	div    %esi
  802054:	89 ea                	mov    %ebp,%edx
  802056:	83 c4 0c             	add    $0xc,%esp
  802059:	5e                   	pop    %esi
  80205a:	5f                   	pop    %edi
  80205b:	5d                   	pop    %ebp
  80205c:	c3                   	ret    
  80205d:	8d 76 00             	lea    0x0(%esi),%esi
  802060:	39 e8                	cmp    %ebp,%eax
  802062:	77 24                	ja     802088 <__udivdi3+0x78>
  802064:	0f bd e8             	bsr    %eax,%ebp
  802067:	83 f5 1f             	xor    $0x1f,%ebp
  80206a:	75 3c                	jne    8020a8 <__udivdi3+0x98>
  80206c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802070:	39 34 24             	cmp    %esi,(%esp)
  802073:	0f 86 9f 00 00 00    	jbe    802118 <__udivdi3+0x108>
  802079:	39 d0                	cmp    %edx,%eax
  80207b:	0f 82 97 00 00 00    	jb     802118 <__udivdi3+0x108>
  802081:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802088:	31 d2                	xor    %edx,%edx
  80208a:	31 c0                	xor    %eax,%eax
  80208c:	83 c4 0c             	add    $0xc,%esp
  80208f:	5e                   	pop    %esi
  802090:	5f                   	pop    %edi
  802091:	5d                   	pop    %ebp
  802092:	c3                   	ret    
  802093:	90                   	nop
  802094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802098:	89 f8                	mov    %edi,%eax
  80209a:	f7 f1                	div    %ecx
  80209c:	31 d2                	xor    %edx,%edx
  80209e:	83 c4 0c             	add    $0xc,%esp
  8020a1:	5e                   	pop    %esi
  8020a2:	5f                   	pop    %edi
  8020a3:	5d                   	pop    %ebp
  8020a4:	c3                   	ret    
  8020a5:	8d 76 00             	lea    0x0(%esi),%esi
  8020a8:	89 e9                	mov    %ebp,%ecx
  8020aa:	8b 3c 24             	mov    (%esp),%edi
  8020ad:	d3 e0                	shl    %cl,%eax
  8020af:	89 c6                	mov    %eax,%esi
  8020b1:	b8 20 00 00 00       	mov    $0x20,%eax
  8020b6:	29 e8                	sub    %ebp,%eax
  8020b8:	89 c1                	mov    %eax,%ecx
  8020ba:	d3 ef                	shr    %cl,%edi
  8020bc:	89 e9                	mov    %ebp,%ecx
  8020be:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8020c2:	8b 3c 24             	mov    (%esp),%edi
  8020c5:	09 74 24 08          	or     %esi,0x8(%esp)
  8020c9:	89 d6                	mov    %edx,%esi
  8020cb:	d3 e7                	shl    %cl,%edi
  8020cd:	89 c1                	mov    %eax,%ecx
  8020cf:	89 3c 24             	mov    %edi,(%esp)
  8020d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8020d6:	d3 ee                	shr    %cl,%esi
  8020d8:	89 e9                	mov    %ebp,%ecx
  8020da:	d3 e2                	shl    %cl,%edx
  8020dc:	89 c1                	mov    %eax,%ecx
  8020de:	d3 ef                	shr    %cl,%edi
  8020e0:	09 d7                	or     %edx,%edi
  8020e2:	89 f2                	mov    %esi,%edx
  8020e4:	89 f8                	mov    %edi,%eax
  8020e6:	f7 74 24 08          	divl   0x8(%esp)
  8020ea:	89 d6                	mov    %edx,%esi
  8020ec:	89 c7                	mov    %eax,%edi
  8020ee:	f7 24 24             	mull   (%esp)
  8020f1:	39 d6                	cmp    %edx,%esi
  8020f3:	89 14 24             	mov    %edx,(%esp)
  8020f6:	72 30                	jb     802128 <__udivdi3+0x118>
  8020f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020fc:	89 e9                	mov    %ebp,%ecx
  8020fe:	d3 e2                	shl    %cl,%edx
  802100:	39 c2                	cmp    %eax,%edx
  802102:	73 05                	jae    802109 <__udivdi3+0xf9>
  802104:	3b 34 24             	cmp    (%esp),%esi
  802107:	74 1f                	je     802128 <__udivdi3+0x118>
  802109:	89 f8                	mov    %edi,%eax
  80210b:	31 d2                	xor    %edx,%edx
  80210d:	e9 7a ff ff ff       	jmp    80208c <__udivdi3+0x7c>
  802112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802118:	31 d2                	xor    %edx,%edx
  80211a:	b8 01 00 00 00       	mov    $0x1,%eax
  80211f:	e9 68 ff ff ff       	jmp    80208c <__udivdi3+0x7c>
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	8d 47 ff             	lea    -0x1(%edi),%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	83 c4 0c             	add    $0xc,%esp
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    
  802134:	66 90                	xchg   %ax,%ax
  802136:	66 90                	xchg   %ax,%ax
  802138:	66 90                	xchg   %ax,%ax
  80213a:	66 90                	xchg   %ax,%ax
  80213c:	66 90                	xchg   %ax,%ax
  80213e:	66 90                	xchg   %ax,%ax

00802140 <__umoddi3>:
  802140:	55                   	push   %ebp
  802141:	57                   	push   %edi
  802142:	56                   	push   %esi
  802143:	83 ec 14             	sub    $0x14,%esp
  802146:	8b 44 24 28          	mov    0x28(%esp),%eax
  80214a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80214e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802152:	89 c7                	mov    %eax,%edi
  802154:	89 44 24 04          	mov    %eax,0x4(%esp)
  802158:	8b 44 24 30          	mov    0x30(%esp),%eax
  80215c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802160:	89 34 24             	mov    %esi,(%esp)
  802163:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802167:	85 c0                	test   %eax,%eax
  802169:	89 c2                	mov    %eax,%edx
  80216b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80216f:	75 17                	jne    802188 <__umoddi3+0x48>
  802171:	39 fe                	cmp    %edi,%esi
  802173:	76 4b                	jbe    8021c0 <__umoddi3+0x80>
  802175:	89 c8                	mov    %ecx,%eax
  802177:	89 fa                	mov    %edi,%edx
  802179:	f7 f6                	div    %esi
  80217b:	89 d0                	mov    %edx,%eax
  80217d:	31 d2                	xor    %edx,%edx
  80217f:	83 c4 14             	add    $0x14,%esp
  802182:	5e                   	pop    %esi
  802183:	5f                   	pop    %edi
  802184:	5d                   	pop    %ebp
  802185:	c3                   	ret    
  802186:	66 90                	xchg   %ax,%ax
  802188:	39 f8                	cmp    %edi,%eax
  80218a:	77 54                	ja     8021e0 <__umoddi3+0xa0>
  80218c:	0f bd e8             	bsr    %eax,%ebp
  80218f:	83 f5 1f             	xor    $0x1f,%ebp
  802192:	75 5c                	jne    8021f0 <__umoddi3+0xb0>
  802194:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802198:	39 3c 24             	cmp    %edi,(%esp)
  80219b:	0f 87 e7 00 00 00    	ja     802288 <__umoddi3+0x148>
  8021a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8021a5:	29 f1                	sub    %esi,%ecx
  8021a7:	19 c7                	sbb    %eax,%edi
  8021a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021b1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021b5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021b9:	83 c4 14             	add    $0x14,%esp
  8021bc:	5e                   	pop    %esi
  8021bd:	5f                   	pop    %edi
  8021be:	5d                   	pop    %ebp
  8021bf:	c3                   	ret    
  8021c0:	85 f6                	test   %esi,%esi
  8021c2:	89 f5                	mov    %esi,%ebp
  8021c4:	75 0b                	jne    8021d1 <__umoddi3+0x91>
  8021c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021cb:	31 d2                	xor    %edx,%edx
  8021cd:	f7 f6                	div    %esi
  8021cf:	89 c5                	mov    %eax,%ebp
  8021d1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021d5:	31 d2                	xor    %edx,%edx
  8021d7:	f7 f5                	div    %ebp
  8021d9:	89 c8                	mov    %ecx,%eax
  8021db:	f7 f5                	div    %ebp
  8021dd:	eb 9c                	jmp    80217b <__umoddi3+0x3b>
  8021df:	90                   	nop
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 fa                	mov    %edi,%edx
  8021e4:	83 c4 14             	add    $0x14,%esp
  8021e7:	5e                   	pop    %esi
  8021e8:	5f                   	pop    %edi
  8021e9:	5d                   	pop    %ebp
  8021ea:	c3                   	ret    
  8021eb:	90                   	nop
  8021ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	8b 04 24             	mov    (%esp),%eax
  8021f3:	be 20 00 00 00       	mov    $0x20,%esi
  8021f8:	89 e9                	mov    %ebp,%ecx
  8021fa:	29 ee                	sub    %ebp,%esi
  8021fc:	d3 e2                	shl    %cl,%edx
  8021fe:	89 f1                	mov    %esi,%ecx
  802200:	d3 e8                	shr    %cl,%eax
  802202:	89 e9                	mov    %ebp,%ecx
  802204:	89 44 24 04          	mov    %eax,0x4(%esp)
  802208:	8b 04 24             	mov    (%esp),%eax
  80220b:	09 54 24 04          	or     %edx,0x4(%esp)
  80220f:	89 fa                	mov    %edi,%edx
  802211:	d3 e0                	shl    %cl,%eax
  802213:	89 f1                	mov    %esi,%ecx
  802215:	89 44 24 08          	mov    %eax,0x8(%esp)
  802219:	8b 44 24 10          	mov    0x10(%esp),%eax
  80221d:	d3 ea                	shr    %cl,%edx
  80221f:	89 e9                	mov    %ebp,%ecx
  802221:	d3 e7                	shl    %cl,%edi
  802223:	89 f1                	mov    %esi,%ecx
  802225:	d3 e8                	shr    %cl,%eax
  802227:	89 e9                	mov    %ebp,%ecx
  802229:	09 f8                	or     %edi,%eax
  80222b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80222f:	f7 74 24 04          	divl   0x4(%esp)
  802233:	d3 e7                	shl    %cl,%edi
  802235:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802239:	89 d7                	mov    %edx,%edi
  80223b:	f7 64 24 08          	mull   0x8(%esp)
  80223f:	39 d7                	cmp    %edx,%edi
  802241:	89 c1                	mov    %eax,%ecx
  802243:	89 14 24             	mov    %edx,(%esp)
  802246:	72 2c                	jb     802274 <__umoddi3+0x134>
  802248:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80224c:	72 22                	jb     802270 <__umoddi3+0x130>
  80224e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802252:	29 c8                	sub    %ecx,%eax
  802254:	19 d7                	sbb    %edx,%edi
  802256:	89 e9                	mov    %ebp,%ecx
  802258:	89 fa                	mov    %edi,%edx
  80225a:	d3 e8                	shr    %cl,%eax
  80225c:	89 f1                	mov    %esi,%ecx
  80225e:	d3 e2                	shl    %cl,%edx
  802260:	89 e9                	mov    %ebp,%ecx
  802262:	d3 ef                	shr    %cl,%edi
  802264:	09 d0                	or     %edx,%eax
  802266:	89 fa                	mov    %edi,%edx
  802268:	83 c4 14             	add    $0x14,%esp
  80226b:	5e                   	pop    %esi
  80226c:	5f                   	pop    %edi
  80226d:	5d                   	pop    %ebp
  80226e:	c3                   	ret    
  80226f:	90                   	nop
  802270:	39 d7                	cmp    %edx,%edi
  802272:	75 da                	jne    80224e <__umoddi3+0x10e>
  802274:	8b 14 24             	mov    (%esp),%edx
  802277:	89 c1                	mov    %eax,%ecx
  802279:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80227d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802281:	eb cb                	jmp    80224e <__umoddi3+0x10e>
  802283:	90                   	nop
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80228c:	0f 82 0f ff ff ff    	jb     8021a1 <__umoddi3+0x61>
  802292:	e9 1a ff ff ff       	jmp    8021b1 <__umoddi3+0x71>
