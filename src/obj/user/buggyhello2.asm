
obj/user/buggyhello2.debug：     文件格式 elf32-i386


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

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  800039:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800040:	00 
  800041:	a1 00 30 80 00       	mov    0x803000,%eax
  800046:	89 04 24             	mov    %eax,(%esp)
  800049:	e8 63 00 00 00       	call   8000b1 <sys_cputs>
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
  80005e:	e8 dd 00 00 00       	call   800140 <sys_getenvid>
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
  80007b:	a3 04 30 80 00       	mov    %eax,0x803004

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
  80009e:	e8 63 05 00 00       	call   800606 <close_all>
	sys_env_destroy(0);
  8000a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000aa:	e8 3f 00 00 00       	call   8000ee <sys_env_destroy>
}
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    

008000b1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	57                   	push   %edi
  8000b5:	56                   	push   %esi
  8000b6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c2:	89 c3                	mov    %eax,%ebx
  8000c4:	89 c7                	mov    %eax,%edi
  8000c6:	89 c6                	mov    %eax,%esi
  8000c8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000da:	b8 01 00 00 00       	mov    $0x1,%eax
  8000df:	89 d1                	mov    %edx,%ecx
  8000e1:	89 d3                	mov    %edx,%ebx
  8000e3:	89 d7                	mov    %edx,%edi
  8000e5:	89 d6                	mov    %edx,%esi
  8000e7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5f                   	pop    %edi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8000f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fc:	b8 03 00 00 00       	mov    $0x3,%eax
  800101:	8b 55 08             	mov    0x8(%ebp),%edx
  800104:	89 cb                	mov    %ecx,%ebx
  800106:	89 cf                	mov    %ecx,%edi
  800108:	89 ce                	mov    %ecx,%esi
  80010a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010c:	85 c0                	test   %eax,%eax
  80010e:	7e 28                	jle    800138 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800110:	89 44 24 10          	mov    %eax,0x10(%esp)
  800114:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011b:	00 
  80011c:	c7 44 24 08 b8 20 80 	movl   $0x8020b8,0x8(%esp)
  800123:	00 
  800124:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012b:	00 
  80012c:	c7 04 24 d5 20 80 00 	movl   $0x8020d5,(%esp)
  800133:	e8 5e 10 00 00       	call   801196 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800138:	83 c4 2c             	add    $0x2c,%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5f                   	pop    %edi
  80013e:	5d                   	pop    %ebp
  80013f:	c3                   	ret    

00800140 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	57                   	push   %edi
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
	asm volatile("int %1\n"
  800146:	ba 00 00 00 00       	mov    $0x0,%edx
  80014b:	b8 02 00 00 00       	mov    $0x2,%eax
  800150:	89 d1                	mov    %edx,%ecx
  800152:	89 d3                	mov    %edx,%ebx
  800154:	89 d7                	mov    %edx,%edi
  800156:	89 d6                	mov    %edx,%esi
  800158:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015a:	5b                   	pop    %ebx
  80015b:	5e                   	pop    %esi
  80015c:	5f                   	pop    %edi
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <sys_yield>:

void
sys_yield(void)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
	asm volatile("int %1\n"
  800165:	ba 00 00 00 00       	mov    $0x0,%edx
  80016a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016f:	89 d1                	mov    %edx,%ecx
  800171:	89 d3                	mov    %edx,%ebx
  800173:	89 d7                	mov    %edx,%edi
  800175:	89 d6                	mov    %edx,%esi
  800177:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5f                   	pop    %edi
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    

0080017e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	57                   	push   %edi
  800182:	56                   	push   %esi
  800183:	53                   	push   %ebx
  800184:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800187:	be 00 00 00 00       	mov    $0x0,%esi
  80018c:	b8 04 00 00 00       	mov    $0x4,%eax
  800191:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800194:	8b 55 08             	mov    0x8(%ebp),%edx
  800197:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019a:	89 f7                	mov    %esi,%edi
  80019c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	7e 28                	jle    8001ca <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a6:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001ad:	00 
  8001ae:	c7 44 24 08 b8 20 80 	movl   $0x8020b8,0x8(%esp)
  8001b5:	00 
  8001b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001bd:	00 
  8001be:	c7 04 24 d5 20 80 00 	movl   $0x8020d5,(%esp)
  8001c5:	e8 cc 0f 00 00       	call   801196 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ca:	83 c4 2c             	add    $0x2c,%esp
  8001cd:	5b                   	pop    %ebx
  8001ce:	5e                   	pop    %esi
  8001cf:	5f                   	pop    %edi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	57                   	push   %edi
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8001db:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ec:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ef:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	7e 28                	jle    80021d <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800200:	00 
  800201:	c7 44 24 08 b8 20 80 	movl   $0x8020b8,0x8(%esp)
  800208:	00 
  800209:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800210:	00 
  800211:	c7 04 24 d5 20 80 00 	movl   $0x8020d5,(%esp)
  800218:	e8 79 0f 00 00       	call   801196 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80021d:	83 c4 2c             	add    $0x2c,%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 06 00 00 00       	mov    $0x6,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 28                	jle    800270 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024c:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800253:	00 
  800254:	c7 44 24 08 b8 20 80 	movl   $0x8020b8,0x8(%esp)
  80025b:	00 
  80025c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800263:	00 
  800264:	c7 04 24 d5 20 80 00 	movl   $0x8020d5,(%esp)
  80026b:	e8 26 0f 00 00       	call   801196 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800270:	83 c4 2c             	add    $0x2c,%esp
  800273:	5b                   	pop    %ebx
  800274:	5e                   	pop    %esi
  800275:	5f                   	pop    %edi
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    

00800278 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800281:	bb 00 00 00 00       	mov    $0x0,%ebx
  800286:	b8 08 00 00 00       	mov    $0x8,%eax
  80028b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028e:	8b 55 08             	mov    0x8(%ebp),%edx
  800291:	89 df                	mov    %ebx,%edi
  800293:	89 de                	mov    %ebx,%esi
  800295:	cd 30                	int    $0x30
	if(check && ret > 0)
  800297:	85 c0                	test   %eax,%eax
  800299:	7e 28                	jle    8002c3 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029f:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a6:	00 
  8002a7:	c7 44 24 08 b8 20 80 	movl   $0x8020b8,0x8(%esp)
  8002ae:	00 
  8002af:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b6:	00 
  8002b7:	c7 04 24 d5 20 80 00 	movl   $0x8020d5,(%esp)
  8002be:	e8 d3 0e 00 00       	call   801196 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c3:	83 c4 2c             	add    $0x2c,%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e4:	89 df                	mov    %ebx,%edi
  8002e6:	89 de                	mov    %ebx,%esi
  8002e8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	7e 28                	jle    800316 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f9:	00 
  8002fa:	c7 44 24 08 b8 20 80 	movl   $0x8020b8,0x8(%esp)
  800301:	00 
  800302:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800309:	00 
  80030a:	c7 04 24 d5 20 80 00 	movl   $0x8020d5,(%esp)
  800311:	e8 80 0e 00 00       	call   801196 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800316:	83 c4 2c             	add    $0x2c,%esp
  800319:	5b                   	pop    %ebx
  80031a:	5e                   	pop    %esi
  80031b:	5f                   	pop    %edi
  80031c:	5d                   	pop    %ebp
  80031d:	c3                   	ret    

0080031e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	57                   	push   %edi
  800322:	56                   	push   %esi
  800323:	53                   	push   %ebx
  800324:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800327:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800331:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800334:	8b 55 08             	mov    0x8(%ebp),%edx
  800337:	89 df                	mov    %ebx,%edi
  800339:	89 de                	mov    %ebx,%esi
  80033b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80033d:	85 c0                	test   %eax,%eax
  80033f:	7e 28                	jle    800369 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800341:	89 44 24 10          	mov    %eax,0x10(%esp)
  800345:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80034c:	00 
  80034d:	c7 44 24 08 b8 20 80 	movl   $0x8020b8,0x8(%esp)
  800354:	00 
  800355:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80035c:	00 
  80035d:	c7 04 24 d5 20 80 00 	movl   $0x8020d5,(%esp)
  800364:	e8 2d 0e 00 00       	call   801196 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800369:	83 c4 2c             	add    $0x2c,%esp
  80036c:	5b                   	pop    %ebx
  80036d:	5e                   	pop    %esi
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	57                   	push   %edi
  800375:	56                   	push   %esi
  800376:	53                   	push   %ebx
	asm volatile("int %1\n"
  800377:	be 00 00 00 00       	mov    $0x0,%esi
  80037c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800381:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800384:	8b 55 08             	mov    0x8(%ebp),%edx
  800387:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80038a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80038d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80038f:	5b                   	pop    %ebx
  800390:	5e                   	pop    %esi
  800391:	5f                   	pop    %edi
  800392:	5d                   	pop    %ebp
  800393:	c3                   	ret    

00800394 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80039d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a2:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003aa:	89 cb                	mov    %ecx,%ebx
  8003ac:	89 cf                	mov    %ecx,%edi
  8003ae:	89 ce                	mov    %ecx,%esi
  8003b0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	7e 28                	jle    8003de <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003ba:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c1:	00 
  8003c2:	c7 44 24 08 b8 20 80 	movl   $0x8020b8,0x8(%esp)
  8003c9:	00 
  8003ca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d1:	00 
  8003d2:	c7 04 24 d5 20 80 00 	movl   $0x8020d5,(%esp)
  8003d9:	e8 b8 0d 00 00       	call   801196 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003de:	83 c4 2c             	add    $0x2c,%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5f                   	pop    %edi
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    
  8003e6:	66 90                	xchg   %ax,%ax
  8003e8:	66 90                	xchg   %ax,%ax
  8003ea:	66 90                	xchg   %ax,%ax
  8003ec:	66 90                	xchg   %ax,%ax
  8003ee:	66 90                	xchg   %ax,%ax

008003f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8003fe:	5d                   	pop    %ebp
  8003ff:	c3                   	ret    

00800400 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800403:	8b 45 08             	mov    0x8(%ebp),%eax
  800406:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80040b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800410:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80041a:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80041f:	a8 01                	test   $0x1,%al
  800421:	74 34                	je     800457 <fd_alloc+0x40>
  800423:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800428:	a8 01                	test   $0x1,%al
  80042a:	74 32                	je     80045e <fd_alloc+0x47>
  80042c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  800431:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800433:	89 c2                	mov    %eax,%edx
  800435:	c1 ea 16             	shr    $0x16,%edx
  800438:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80043f:	f6 c2 01             	test   $0x1,%dl
  800442:	74 1f                	je     800463 <fd_alloc+0x4c>
  800444:	89 c2                	mov    %eax,%edx
  800446:	c1 ea 0c             	shr    $0xc,%edx
  800449:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800450:	f6 c2 01             	test   $0x1,%dl
  800453:	75 1a                	jne    80046f <fd_alloc+0x58>
  800455:	eb 0c                	jmp    800463 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  800457:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80045c:	eb 05                	jmp    800463 <fd_alloc+0x4c>
  80045e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  800463:	8b 45 08             	mov    0x8(%ebp),%eax
  800466:	89 08                	mov    %ecx,(%eax)
			return 0;
  800468:	b8 00 00 00 00       	mov    $0x0,%eax
  80046d:	eb 1a                	jmp    800489 <fd_alloc+0x72>
  80046f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800474:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800479:	75 b6                	jne    800431 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  80047b:	8b 45 08             	mov    0x8(%ebp),%eax
  80047e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800484:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800491:	83 f8 1f             	cmp    $0x1f,%eax
  800494:	77 36                	ja     8004cc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800496:	c1 e0 0c             	shl    $0xc,%eax
  800499:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80049e:	89 c2                	mov    %eax,%edx
  8004a0:	c1 ea 16             	shr    $0x16,%edx
  8004a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004aa:	f6 c2 01             	test   $0x1,%dl
  8004ad:	74 24                	je     8004d3 <fd_lookup+0x48>
  8004af:	89 c2                	mov    %eax,%edx
  8004b1:	c1 ea 0c             	shr    $0xc,%edx
  8004b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004bb:	f6 c2 01             	test   $0x1,%dl
  8004be:	74 1a                	je     8004da <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c3:	89 02                	mov    %eax,(%edx)
	return 0;
  8004c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ca:	eb 13                	jmp    8004df <fd_lookup+0x54>
		return -E_INVAL;
  8004cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004d1:	eb 0c                	jmp    8004df <fd_lookup+0x54>
		return -E_INVAL;
  8004d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004d8:	eb 05                	jmp    8004df <fd_lookup+0x54>
  8004da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004df:	5d                   	pop    %ebp
  8004e0:	c3                   	ret    

008004e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  8004e4:	53                   	push   %ebx
  8004e5:	83 ec 14             	sub    $0x14,%esp
  8004e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8004ee:	39 05 08 30 80 00    	cmp    %eax,0x803008
  8004f4:	75 1e                	jne    800514 <dev_lookup+0x33>
  8004f6:	eb 0e                	jmp    800506 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  8004f8:	b8 24 30 80 00       	mov    $0x803024,%eax
  8004fd:	eb 0c                	jmp    80050b <dev_lookup+0x2a>
  8004ff:	b8 40 30 80 00       	mov    $0x803040,%eax
  800504:	eb 05                	jmp    80050b <dev_lookup+0x2a>
  800506:	b8 08 30 80 00       	mov    $0x803008,%eax
			*dev = devtab[i];
  80050b:	89 03                	mov    %eax,(%ebx)
			return 0;
  80050d:	b8 00 00 00 00       	mov    $0x0,%eax
  800512:	eb 38                	jmp    80054c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  800514:	39 05 24 30 80 00    	cmp    %eax,0x803024
  80051a:	74 dc                	je     8004f8 <dev_lookup+0x17>
  80051c:	39 05 40 30 80 00    	cmp    %eax,0x803040
  800522:	74 db                	je     8004ff <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800524:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80052a:	8b 52 48             	mov    0x48(%edx),%edx
  80052d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800531:	89 54 24 04          	mov    %edx,0x4(%esp)
  800535:	c7 04 24 e4 20 80 00 	movl   $0x8020e4,(%esp)
  80053c:	e8 4e 0d 00 00       	call   80128f <cprintf>
	*dev = 0;
  800541:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800547:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80054c:	83 c4 14             	add    $0x14,%esp
  80054f:	5b                   	pop    %ebx
  800550:	5d                   	pop    %ebp
  800551:	c3                   	ret    

00800552 <fd_close>:
{
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
  800555:	56                   	push   %esi
  800556:	53                   	push   %ebx
  800557:	83 ec 20             	sub    $0x20,%esp
  80055a:	8b 75 08             	mov    0x8(%ebp),%esi
  80055d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800560:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800563:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800567:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80056d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	e8 13 ff ff ff       	call   80048b <fd_lookup>
  800578:	85 c0                	test   %eax,%eax
  80057a:	78 05                	js     800581 <fd_close+0x2f>
	    || fd != fd2)
  80057c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80057f:	74 0c                	je     80058d <fd_close+0x3b>
		return (must_exist ? r : 0);
  800581:	84 db                	test   %bl,%bl
  800583:	ba 00 00 00 00       	mov    $0x0,%edx
  800588:	0f 44 c2             	cmove  %edx,%eax
  80058b:	eb 3f                	jmp    8005cc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80058d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800590:	89 44 24 04          	mov    %eax,0x4(%esp)
  800594:	8b 06                	mov    (%esi),%eax
  800596:	89 04 24             	mov    %eax,(%esp)
  800599:	e8 43 ff ff ff       	call   8004e1 <dev_lookup>
  80059e:	89 c3                	mov    %eax,%ebx
  8005a0:	85 c0                	test   %eax,%eax
  8005a2:	78 16                	js     8005ba <fd_close+0x68>
		if (dev->dev_close)
  8005a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a7:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8005aa:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	74 07                	je     8005ba <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8005b3:	89 34 24             	mov    %esi,(%esp)
  8005b6:	ff d0                	call   *%eax
  8005b8:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8005ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005c5:	e8 5b fc ff ff       	call   800225 <sys_page_unmap>
	return r;
  8005ca:	89 d8                	mov    %ebx,%eax
}
  8005cc:	83 c4 20             	add    $0x20,%esp
  8005cf:	5b                   	pop    %ebx
  8005d0:	5e                   	pop    %esi
  8005d1:	5d                   	pop    %ebp
  8005d2:	c3                   	ret    

008005d3 <close>:

int
close(int fdnum)
{
  8005d3:	55                   	push   %ebp
  8005d4:	89 e5                	mov    %esp,%ebp
  8005d6:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e3:	89 04 24             	mov    %eax,(%esp)
  8005e6:	e8 a0 fe ff ff       	call   80048b <fd_lookup>
  8005eb:	89 c2                	mov    %eax,%edx
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	78 13                	js     800604 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8005f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005f8:	00 
  8005f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005fc:	89 04 24             	mov    %eax,(%esp)
  8005ff:	e8 4e ff ff ff       	call   800552 <fd_close>
}
  800604:	c9                   	leave  
  800605:	c3                   	ret    

00800606 <close_all>:

void
close_all(void)
{
  800606:	55                   	push   %ebp
  800607:	89 e5                	mov    %esp,%ebp
  800609:	53                   	push   %ebx
  80060a:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80060d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800612:	89 1c 24             	mov    %ebx,(%esp)
  800615:	e8 b9 ff ff ff       	call   8005d3 <close>
	for (i = 0; i < MAXFD; i++)
  80061a:	83 c3 01             	add    $0x1,%ebx
  80061d:	83 fb 20             	cmp    $0x20,%ebx
  800620:	75 f0                	jne    800612 <close_all+0xc>
}
  800622:	83 c4 14             	add    $0x14,%esp
  800625:	5b                   	pop    %ebx
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	57                   	push   %edi
  80062c:	56                   	push   %esi
  80062d:	53                   	push   %ebx
  80062e:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800631:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800634:	89 44 24 04          	mov    %eax,0x4(%esp)
  800638:	8b 45 08             	mov    0x8(%ebp),%eax
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	e8 48 fe ff ff       	call   80048b <fd_lookup>
  800643:	89 c2                	mov    %eax,%edx
  800645:	85 d2                	test   %edx,%edx
  800647:	0f 88 e1 00 00 00    	js     80072e <dup+0x106>
		return r;
	close(newfdnum);
  80064d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800650:	89 04 24             	mov    %eax,(%esp)
  800653:	e8 7b ff ff ff       	call   8005d3 <close>

	newfd = INDEX2FD(newfdnum);
  800658:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80065b:	c1 e3 0c             	shl    $0xc,%ebx
  80065e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800664:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800667:	89 04 24             	mov    %eax,(%esp)
  80066a:	e8 91 fd ff ff       	call   800400 <fd2data>
  80066f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  800671:	89 1c 24             	mov    %ebx,(%esp)
  800674:	e8 87 fd ff ff       	call   800400 <fd2data>
  800679:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80067b:	89 f0                	mov    %esi,%eax
  80067d:	c1 e8 16             	shr    $0x16,%eax
  800680:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800687:	a8 01                	test   $0x1,%al
  800689:	74 43                	je     8006ce <dup+0xa6>
  80068b:	89 f0                	mov    %esi,%eax
  80068d:	c1 e8 0c             	shr    $0xc,%eax
  800690:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800697:	f6 c2 01             	test   $0x1,%dl
  80069a:	74 32                	je     8006ce <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80069c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006a3:	25 07 0e 00 00       	and    $0xe07,%eax
  8006a8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ac:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8006b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006b7:	00 
  8006b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006c3:	e8 0a fb ff ff       	call   8001d2 <sys_page_map>
  8006c8:	89 c6                	mov    %eax,%esi
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	78 3e                	js     80070c <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006d1:	89 c2                	mov    %eax,%edx
  8006d3:	c1 ea 0c             	shr    $0xc,%edx
  8006d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006dd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006e3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006e7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006f2:	00 
  8006f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006fe:	e8 cf fa ff ff       	call   8001d2 <sys_page_map>
  800703:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  800705:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800708:	85 f6                	test   %esi,%esi
  80070a:	79 22                	jns    80072e <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80070c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800710:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800717:	e8 09 fb ff ff       	call   800225 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80071c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800720:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800727:	e8 f9 fa ff ff       	call   800225 <sys_page_unmap>
	return r;
  80072c:	89 f0                	mov    %esi,%eax
}
  80072e:	83 c4 3c             	add    $0x3c,%esp
  800731:	5b                   	pop    %ebx
  800732:	5e                   	pop    %esi
  800733:	5f                   	pop    %edi
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	53                   	push   %ebx
  80073a:	83 ec 24             	sub    $0x24,%esp
  80073d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800740:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800743:	89 44 24 04          	mov    %eax,0x4(%esp)
  800747:	89 1c 24             	mov    %ebx,(%esp)
  80074a:	e8 3c fd ff ff       	call   80048b <fd_lookup>
  80074f:	89 c2                	mov    %eax,%edx
  800751:	85 d2                	test   %edx,%edx
  800753:	78 6d                	js     8007c2 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800755:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800758:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80075f:	8b 00                	mov    (%eax),%eax
  800761:	89 04 24             	mov    %eax,(%esp)
  800764:	e8 78 fd ff ff       	call   8004e1 <dev_lookup>
  800769:	85 c0                	test   %eax,%eax
  80076b:	78 55                	js     8007c2 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80076d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800770:	8b 50 08             	mov    0x8(%eax),%edx
  800773:	83 e2 03             	and    $0x3,%edx
  800776:	83 fa 01             	cmp    $0x1,%edx
  800779:	75 23                	jne    80079e <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80077b:	a1 04 40 80 00       	mov    0x804004,%eax
  800780:	8b 40 48             	mov    0x48(%eax),%eax
  800783:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800787:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078b:	c7 04 24 25 21 80 00 	movl   $0x802125,(%esp)
  800792:	e8 f8 0a 00 00       	call   80128f <cprintf>
		return -E_INVAL;
  800797:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079c:	eb 24                	jmp    8007c2 <read+0x8c>
	}
	if (!dev->dev_read)
  80079e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a1:	8b 52 08             	mov    0x8(%edx),%edx
  8007a4:	85 d2                	test   %edx,%edx
  8007a6:	74 15                	je     8007bd <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8007a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007ab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007b6:	89 04 24             	mov    %eax,(%esp)
  8007b9:	ff d2                	call   *%edx
  8007bb:	eb 05                	jmp    8007c2 <read+0x8c>
		return -E_NOT_SUPP;
  8007bd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8007c2:	83 c4 24             	add    $0x24,%esp
  8007c5:	5b                   	pop    %ebx
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	57                   	push   %edi
  8007cc:	56                   	push   %esi
  8007cd:	53                   	push   %ebx
  8007ce:	83 ec 1c             	sub    $0x1c,%esp
  8007d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007d7:	85 f6                	test   %esi,%esi
  8007d9:	74 33                	je     80080e <readn+0x46>
  8007db:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e0:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007e5:	89 f2                	mov    %esi,%edx
  8007e7:	29 c2                	sub    %eax,%edx
  8007e9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8007ed:	03 45 0c             	add    0xc(%ebp),%eax
  8007f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f4:	89 3c 24             	mov    %edi,(%esp)
  8007f7:	e8 3a ff ff ff       	call   800736 <read>
		if (m < 0)
  8007fc:	85 c0                	test   %eax,%eax
  8007fe:	78 1b                	js     80081b <readn+0x53>
			return m;
		if (m == 0)
  800800:	85 c0                	test   %eax,%eax
  800802:	74 11                	je     800815 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  800804:	01 c3                	add    %eax,%ebx
  800806:	89 d8                	mov    %ebx,%eax
  800808:	39 f3                	cmp    %esi,%ebx
  80080a:	72 d9                	jb     8007e5 <readn+0x1d>
  80080c:	eb 0b                	jmp    800819 <readn+0x51>
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
  800813:	eb 06                	jmp    80081b <readn+0x53>
  800815:	89 d8                	mov    %ebx,%eax
  800817:	eb 02                	jmp    80081b <readn+0x53>
  800819:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80081b:	83 c4 1c             	add    $0x1c,%esp
  80081e:	5b                   	pop    %ebx
  80081f:	5e                   	pop    %esi
  800820:	5f                   	pop    %edi
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	83 ec 24             	sub    $0x24,%esp
  80082a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800830:	89 44 24 04          	mov    %eax,0x4(%esp)
  800834:	89 1c 24             	mov    %ebx,(%esp)
  800837:	e8 4f fc ff ff       	call   80048b <fd_lookup>
  80083c:	89 c2                	mov    %eax,%edx
  80083e:	85 d2                	test   %edx,%edx
  800840:	78 68                	js     8008aa <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800842:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800845:	89 44 24 04          	mov    %eax,0x4(%esp)
  800849:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084c:	8b 00                	mov    (%eax),%eax
  80084e:	89 04 24             	mov    %eax,(%esp)
  800851:	e8 8b fc ff ff       	call   8004e1 <dev_lookup>
  800856:	85 c0                	test   %eax,%eax
  800858:	78 50                	js     8008aa <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80085a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800861:	75 23                	jne    800886 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800863:	a1 04 40 80 00       	mov    0x804004,%eax
  800868:	8b 40 48             	mov    0x48(%eax),%eax
  80086b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80086f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800873:	c7 04 24 41 21 80 00 	movl   $0x802141,(%esp)
  80087a:	e8 10 0a 00 00       	call   80128f <cprintf>
		return -E_INVAL;
  80087f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800884:	eb 24                	jmp    8008aa <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800886:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800889:	8b 52 0c             	mov    0xc(%edx),%edx
  80088c:	85 d2                	test   %edx,%edx
  80088e:	74 15                	je     8008a5 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800890:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800893:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800897:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80089e:	89 04 24             	mov    %eax,(%esp)
  8008a1:	ff d2                	call   *%edx
  8008a3:	eb 05                	jmp    8008aa <write+0x87>
		return -E_NOT_SUPP;
  8008a5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8008aa:	83 c4 24             	add    $0x24,%esp
  8008ad:	5b                   	pop    %ebx
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008b6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8008b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	89 04 24             	mov    %eax,(%esp)
  8008c3:	e8 c3 fb ff ff       	call   80048b <fd_lookup>
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	78 0e                	js     8008da <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    

008008dc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	53                   	push   %ebx
  8008e0:	83 ec 24             	sub    $0x24,%esp
  8008e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ed:	89 1c 24             	mov    %ebx,(%esp)
  8008f0:	e8 96 fb ff ff       	call   80048b <fd_lookup>
  8008f5:	89 c2                	mov    %eax,%edx
  8008f7:	85 d2                	test   %edx,%edx
  8008f9:	78 61                	js     80095c <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800902:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800905:	8b 00                	mov    (%eax),%eax
  800907:	89 04 24             	mov    %eax,(%esp)
  80090a:	e8 d2 fb ff ff       	call   8004e1 <dev_lookup>
  80090f:	85 c0                	test   %eax,%eax
  800911:	78 49                	js     80095c <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800913:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800916:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80091a:	75 23                	jne    80093f <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80091c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800921:	8b 40 48             	mov    0x48(%eax),%eax
  800924:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800928:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092c:	c7 04 24 04 21 80 00 	movl   $0x802104,(%esp)
  800933:	e8 57 09 00 00       	call   80128f <cprintf>
		return -E_INVAL;
  800938:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80093d:	eb 1d                	jmp    80095c <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80093f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800942:	8b 52 18             	mov    0x18(%edx),%edx
  800945:	85 d2                	test   %edx,%edx
  800947:	74 0e                	je     800957 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800949:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800950:	89 04 24             	mov    %eax,(%esp)
  800953:	ff d2                	call   *%edx
  800955:	eb 05                	jmp    80095c <ftruncate+0x80>
		return -E_NOT_SUPP;
  800957:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80095c:	83 c4 24             	add    $0x24,%esp
  80095f:	5b                   	pop    %ebx
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	53                   	push   %ebx
  800966:	83 ec 24             	sub    $0x24,%esp
  800969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80096c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80096f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	89 04 24             	mov    %eax,(%esp)
  800979:	e8 0d fb ff ff       	call   80048b <fd_lookup>
  80097e:	89 c2                	mov    %eax,%edx
  800980:	85 d2                	test   %edx,%edx
  800982:	78 52                	js     8009d6 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800984:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800987:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80098e:	8b 00                	mov    (%eax),%eax
  800990:	89 04 24             	mov    %eax,(%esp)
  800993:	e8 49 fb ff ff       	call   8004e1 <dev_lookup>
  800998:	85 c0                	test   %eax,%eax
  80099a:	78 3a                	js     8009d6 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80099c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8009a3:	74 2c                	je     8009d1 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8009a5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8009a8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8009af:	00 00 00 
	stat->st_isdir = 0;
  8009b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8009b9:	00 00 00 
	stat->st_dev = dev;
  8009bc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009c9:	89 14 24             	mov    %edx,(%esp)
  8009cc:	ff 50 14             	call   *0x14(%eax)
  8009cf:	eb 05                	jmp    8009d6 <fstat+0x74>
		return -E_NOT_SUPP;
  8009d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8009d6:	83 c4 24             	add    $0x24,%esp
  8009d9:	5b                   	pop    %ebx
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009eb:	00 
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	89 04 24             	mov    %eax,(%esp)
  8009f2:	e8 af 01 00 00       	call   800ba6 <open>
  8009f7:	89 c3                	mov    %eax,%ebx
  8009f9:	85 db                	test   %ebx,%ebx
  8009fb:	78 1b                	js     800a18 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a04:	89 1c 24             	mov    %ebx,(%esp)
  800a07:	e8 56 ff ff ff       	call   800962 <fstat>
  800a0c:	89 c6                	mov    %eax,%esi
	close(fd);
  800a0e:	89 1c 24             	mov    %ebx,(%esp)
  800a11:	e8 bd fb ff ff       	call   8005d3 <close>
	return r;
  800a16:	89 f0                	mov    %esi,%eax
}
  800a18:	83 c4 10             	add    $0x10,%esp
  800a1b:	5b                   	pop    %ebx
  800a1c:	5e                   	pop    %esi
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	83 ec 10             	sub    $0x10,%esp
  800a27:	89 c6                	mov    %eax,%esi
  800a29:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800a2b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a32:	75 11                	jne    800a45 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a3b:	e8 30 13 00 00       	call   801d70 <ipc_find_env>
  800a40:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a45:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a4c:	00 
  800a4d:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a54:	00 
  800a55:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a59:	a1 00 40 80 00       	mov    0x804000,%eax
  800a5e:	89 04 24             	mov    %eax,(%esp)
  800a61:	e8 c2 12 00 00       	call   801d28 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a66:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a6d:	00 
  800a6e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a79:	e8 4e 12 00 00       	call   801ccc <ipc_recv>
}
  800a7e:	83 c4 10             	add    $0x10,%esp
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	53                   	push   %ebx
  800a89:	83 ec 14             	sub    $0x14,%esp
  800a8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	8b 40 0c             	mov    0xc(%eax),%eax
  800a95:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9f:	b8 05 00 00 00       	mov    $0x5,%eax
  800aa4:	e8 76 ff ff ff       	call   800a1f <fsipc>
  800aa9:	89 c2                	mov    %eax,%edx
  800aab:	85 d2                	test   %edx,%edx
  800aad:	78 2b                	js     800ada <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800aaf:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ab6:	00 
  800ab7:	89 1c 24             	mov    %ebx,(%esp)
  800aba:	e8 2c 0e 00 00       	call   8018eb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800abf:	a1 80 50 80 00       	mov    0x805080,%eax
  800ac4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800aca:	a1 84 50 80 00       	mov    0x805084,%eax
  800acf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ada:	83 c4 14             	add    $0x14,%esp
  800add:	5b                   	pop    %ebx
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <devfile_flush>:
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae9:	8b 40 0c             	mov    0xc(%eax),%eax
  800aec:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800af1:	ba 00 00 00 00       	mov    $0x0,%edx
  800af6:	b8 06 00 00 00       	mov    $0x6,%eax
  800afb:	e8 1f ff ff ff       	call   800a1f <fsipc>
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <devfile_read>:
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 10             	sub    $0x10,%esp
  800b0a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b10:	8b 40 0c             	mov    0xc(%eax),%eax
  800b13:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b18:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b23:	b8 03 00 00 00       	mov    $0x3,%eax
  800b28:	e8 f2 fe ff ff       	call   800a1f <fsipc>
  800b2d:	89 c3                	mov    %eax,%ebx
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	78 6a                	js     800b9d <devfile_read+0x9b>
	assert(r <= n);
  800b33:	39 c6                	cmp    %eax,%esi
  800b35:	73 24                	jae    800b5b <devfile_read+0x59>
  800b37:	c7 44 24 0c 5e 21 80 	movl   $0x80215e,0xc(%esp)
  800b3e:	00 
  800b3f:	c7 44 24 08 65 21 80 	movl   $0x802165,0x8(%esp)
  800b46:	00 
  800b47:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  800b4e:	00 
  800b4f:	c7 04 24 7a 21 80 00 	movl   $0x80217a,(%esp)
  800b56:	e8 3b 06 00 00       	call   801196 <_panic>
	assert(r <= PGSIZE);
  800b5b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b60:	7e 24                	jle    800b86 <devfile_read+0x84>
  800b62:	c7 44 24 0c 85 21 80 	movl   $0x802185,0xc(%esp)
  800b69:	00 
  800b6a:	c7 44 24 08 65 21 80 	movl   $0x802165,0x8(%esp)
  800b71:	00 
  800b72:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  800b79:	00 
  800b7a:	c7 04 24 7a 21 80 00 	movl   $0x80217a,(%esp)
  800b81:	e8 10 06 00 00       	call   801196 <_panic>
	memmove(buf, &fsipcbuf, r);
  800b86:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b8a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b91:	00 
  800b92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b95:	89 04 24             	mov    %eax,(%esp)
  800b98:	e8 49 0f 00 00       	call   801ae6 <memmove>
}
  800b9d:	89 d8                	mov    %ebx,%eax
  800b9f:	83 c4 10             	add    $0x10,%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <open>:
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 24             	sub    $0x24,%esp
  800bad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800bb0:	89 1c 24             	mov    %ebx,(%esp)
  800bb3:	e8 d8 0c 00 00       	call   801890 <strlen>
  800bb8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bbd:	7f 60                	jg     800c1f <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  800bbf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bc2:	89 04 24             	mov    %eax,(%esp)
  800bc5:	e8 4d f8 ff ff       	call   800417 <fd_alloc>
  800bca:	89 c2                	mov    %eax,%edx
  800bcc:	85 d2                	test   %edx,%edx
  800bce:	78 54                	js     800c24 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  800bd0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bd4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800bdb:	e8 0b 0d 00 00       	call   8018eb <strcpy>
	fsipcbuf.open.req_omode = mode;
  800be0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800be8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800beb:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf0:	e8 2a fe ff ff       	call   800a1f <fsipc>
  800bf5:	89 c3                	mov    %eax,%ebx
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	79 17                	jns    800c12 <open+0x6c>
		fd_close(fd, 0);
  800bfb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c02:	00 
  800c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c06:	89 04 24             	mov    %eax,(%esp)
  800c09:	e8 44 f9 ff ff       	call   800552 <fd_close>
		return r;
  800c0e:	89 d8                	mov    %ebx,%eax
  800c10:	eb 12                	jmp    800c24 <open+0x7e>
	return fd2num(fd);
  800c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c15:	89 04 24             	mov    %eax,(%esp)
  800c18:	e8 d3 f7 ff ff       	call   8003f0 <fd2num>
  800c1d:	eb 05                	jmp    800c24 <open+0x7e>
		return -E_BAD_PATH;
  800c1f:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  800c24:	83 c4 24             	add    $0x24,%esp
  800c27:	5b                   	pop    %ebx
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    
  800c2a:	66 90                	xchg   %ax,%ax
  800c2c:	66 90                	xchg   %ax,%ax
  800c2e:	66 90                	xchg   %ax,%ax

00800c30 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	83 ec 10             	sub    $0x10,%esp
  800c38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3e:	89 04 24             	mov    %eax,(%esp)
  800c41:	e8 ba f7 ff ff       	call   800400 <fd2data>
  800c46:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800c48:	c7 44 24 04 91 21 80 	movl   $0x802191,0x4(%esp)
  800c4f:	00 
  800c50:	89 1c 24             	mov    %ebx,(%esp)
  800c53:	e8 93 0c 00 00       	call   8018eb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c58:	8b 46 04             	mov    0x4(%esi),%eax
  800c5b:	2b 06                	sub    (%esi),%eax
  800c5d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c63:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c6a:	00 00 00 
	stat->st_dev = &devpipe;
  800c6d:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800c74:	30 80 00 
	return 0;
}
  800c77:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7c:	83 c4 10             	add    $0x10,%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	53                   	push   %ebx
  800c87:	83 ec 14             	sub    $0x14,%esp
  800c8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c8d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c98:	e8 88 f5 ff ff       	call   800225 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c9d:	89 1c 24             	mov    %ebx,(%esp)
  800ca0:	e8 5b f7 ff ff       	call   800400 <fd2data>
  800ca5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cb0:	e8 70 f5 ff ff       	call   800225 <sys_page_unmap>
}
  800cb5:	83 c4 14             	add    $0x14,%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <_pipeisclosed>:
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	83 ec 2c             	sub    $0x2c,%esp
  800cc4:	89 c6                	mov    %eax,%esi
  800cc6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  800cc9:	a1 04 40 80 00       	mov    0x804004,%eax
  800cce:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800cd1:	89 34 24             	mov    %esi,(%esp)
  800cd4:	e8 df 10 00 00       	call   801db8 <pageref>
  800cd9:	89 c7                	mov    %eax,%edi
  800cdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cde:	89 04 24             	mov    %eax,(%esp)
  800ce1:	e8 d2 10 00 00       	call   801db8 <pageref>
  800ce6:	39 c7                	cmp    %eax,%edi
  800ce8:	0f 94 c2             	sete   %dl
  800ceb:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800cee:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800cf4:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800cf7:	39 fb                	cmp    %edi,%ebx
  800cf9:	74 21                	je     800d1c <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  800cfb:	84 d2                	test   %dl,%dl
  800cfd:	74 ca                	je     800cc9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800cff:	8b 51 58             	mov    0x58(%ecx),%edx
  800d02:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d06:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d0e:	c7 04 24 98 21 80 00 	movl   $0x802198,(%esp)
  800d15:	e8 75 05 00 00       	call   80128f <cprintf>
  800d1a:	eb ad                	jmp    800cc9 <_pipeisclosed+0xe>
}
  800d1c:	83 c4 2c             	add    $0x2c,%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <devpipe_write>:
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 1c             	sub    $0x1c,%esp
  800d2d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800d30:	89 34 24             	mov    %esi,(%esp)
  800d33:	e8 c8 f6 ff ff       	call   800400 <fd2data>
	for (i = 0; i < n; i++) {
  800d38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d3c:	74 61                	je     800d9f <devpipe_write+0x7b>
  800d3e:	89 c3                	mov    %eax,%ebx
  800d40:	bf 00 00 00 00       	mov    $0x0,%edi
  800d45:	eb 4a                	jmp    800d91 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  800d47:	89 da                	mov    %ebx,%edx
  800d49:	89 f0                	mov    %esi,%eax
  800d4b:	e8 6b ff ff ff       	call   800cbb <_pipeisclosed>
  800d50:	85 c0                	test   %eax,%eax
  800d52:	75 54                	jne    800da8 <devpipe_write+0x84>
			sys_yield();
  800d54:	e8 06 f4 ff ff       	call   80015f <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d59:	8b 43 04             	mov    0x4(%ebx),%eax
  800d5c:	8b 0b                	mov    (%ebx),%ecx
  800d5e:	8d 51 20             	lea    0x20(%ecx),%edx
  800d61:	39 d0                	cmp    %edx,%eax
  800d63:	73 e2                	jae    800d47 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d6c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d6f:	99                   	cltd   
  800d70:	c1 ea 1b             	shr    $0x1b,%edx
  800d73:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800d76:	83 e1 1f             	and    $0x1f,%ecx
  800d79:	29 d1                	sub    %edx,%ecx
  800d7b:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800d7f:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  800d83:	83 c0 01             	add    $0x1,%eax
  800d86:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d89:	83 c7 01             	add    $0x1,%edi
  800d8c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d8f:	74 13                	je     800da4 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d91:	8b 43 04             	mov    0x4(%ebx),%eax
  800d94:	8b 0b                	mov    (%ebx),%ecx
  800d96:	8d 51 20             	lea    0x20(%ecx),%edx
  800d99:	39 d0                	cmp    %edx,%eax
  800d9b:	73 aa                	jae    800d47 <devpipe_write+0x23>
  800d9d:	eb c6                	jmp    800d65 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  800d9f:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  800da4:	89 f8                	mov    %edi,%eax
  800da6:	eb 05                	jmp    800dad <devpipe_write+0x89>
				return 0;
  800da8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dad:	83 c4 1c             	add    $0x1c,%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <devpipe_read>:
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 1c             	sub    $0x1c,%esp
  800dbe:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800dc1:	89 3c 24             	mov    %edi,(%esp)
  800dc4:	e8 37 f6 ff ff       	call   800400 <fd2data>
	for (i = 0; i < n; i++) {
  800dc9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dcd:	74 54                	je     800e23 <devpipe_read+0x6e>
  800dcf:	89 c3                	mov    %eax,%ebx
  800dd1:	be 00 00 00 00       	mov    $0x0,%esi
  800dd6:	eb 3e                	jmp    800e16 <devpipe_read+0x61>
				return i;
  800dd8:	89 f0                	mov    %esi,%eax
  800dda:	eb 55                	jmp    800e31 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  800ddc:	89 da                	mov    %ebx,%edx
  800dde:	89 f8                	mov    %edi,%eax
  800de0:	e8 d6 fe ff ff       	call   800cbb <_pipeisclosed>
  800de5:	85 c0                	test   %eax,%eax
  800de7:	75 43                	jne    800e2c <devpipe_read+0x77>
			sys_yield();
  800de9:	e8 71 f3 ff ff       	call   80015f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800dee:	8b 03                	mov    (%ebx),%eax
  800df0:	3b 43 04             	cmp    0x4(%ebx),%eax
  800df3:	74 e7                	je     800ddc <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800df5:	99                   	cltd   
  800df6:	c1 ea 1b             	shr    $0x1b,%edx
  800df9:	01 d0                	add    %edx,%eax
  800dfb:	83 e0 1f             	and    $0x1f,%eax
  800dfe:	29 d0                	sub    %edx,%eax
  800e00:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e08:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800e0b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800e0e:	83 c6 01             	add    $0x1,%esi
  800e11:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e14:	74 12                	je     800e28 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  800e16:	8b 03                	mov    (%ebx),%eax
  800e18:	3b 43 04             	cmp    0x4(%ebx),%eax
  800e1b:	75 d8                	jne    800df5 <devpipe_read+0x40>
			if (i > 0)
  800e1d:	85 f6                	test   %esi,%esi
  800e1f:	75 b7                	jne    800dd8 <devpipe_read+0x23>
  800e21:	eb b9                	jmp    800ddc <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  800e23:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  800e28:	89 f0                	mov    %esi,%eax
  800e2a:	eb 05                	jmp    800e31 <devpipe_read+0x7c>
				return 0;
  800e2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e31:	83 c4 1c             	add    $0x1c,%esp
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <pipe>:
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	56                   	push   %esi
  800e3d:	53                   	push   %ebx
  800e3e:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800e41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e44:	89 04 24             	mov    %eax,(%esp)
  800e47:	e8 cb f5 ff ff       	call   800417 <fd_alloc>
  800e4c:	89 c2                	mov    %eax,%edx
  800e4e:	85 d2                	test   %edx,%edx
  800e50:	0f 88 4d 01 00 00    	js     800fa3 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e56:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e5d:	00 
  800e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e6c:	e8 0d f3 ff ff       	call   80017e <sys_page_alloc>
  800e71:	89 c2                	mov    %eax,%edx
  800e73:	85 d2                	test   %edx,%edx
  800e75:	0f 88 28 01 00 00    	js     800fa3 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  800e7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e7e:	89 04 24             	mov    %eax,(%esp)
  800e81:	e8 91 f5 ff ff       	call   800417 <fd_alloc>
  800e86:	89 c3                	mov    %eax,%ebx
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	0f 88 fe 00 00 00    	js     800f8e <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e90:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e97:	00 
  800e98:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ea6:	e8 d3 f2 ff ff       	call   80017e <sys_page_alloc>
  800eab:	89 c3                	mov    %eax,%ebx
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	0f 88 d9 00 00 00    	js     800f8e <pipe+0x155>
	va = fd2data(fd0);
  800eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb8:	89 04 24             	mov    %eax,(%esp)
  800ebb:	e8 40 f5 ff ff       	call   800400 <fd2data>
  800ec0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ec2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ec9:	00 
  800eca:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ece:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ed5:	e8 a4 f2 ff ff       	call   80017e <sys_page_alloc>
  800eda:	89 c3                	mov    %eax,%ebx
  800edc:	85 c0                	test   %eax,%eax
  800ede:	0f 88 97 00 00 00    	js     800f7b <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee7:	89 04 24             	mov    %eax,(%esp)
  800eea:	e8 11 f5 ff ff       	call   800400 <fd2data>
  800eef:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800ef6:	00 
  800ef7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800efb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f02:	00 
  800f03:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f0e:	e8 bf f2 ff ff       	call   8001d2 <sys_page_map>
  800f13:	89 c3                	mov    %eax,%ebx
  800f15:	85 c0                	test   %eax,%eax
  800f17:	78 52                	js     800f6b <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  800f19:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f22:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f27:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800f2e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800f34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f37:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f3c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f46:	89 04 24             	mov    %eax,(%esp)
  800f49:	e8 a2 f4 ff ff       	call   8003f0 <fd2num>
  800f4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f51:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f56:	89 04 24             	mov    %eax,(%esp)
  800f59:	e8 92 f4 ff ff       	call   8003f0 <fd2num>
  800f5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f61:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800f64:	b8 00 00 00 00       	mov    $0x0,%eax
  800f69:	eb 38                	jmp    800fa3 <pipe+0x16a>
	sys_page_unmap(0, va);
  800f6b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f76:	e8 aa f2 ff ff       	call   800225 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  800f7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f89:	e8 97 f2 ff ff       	call   800225 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  800f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f9c:	e8 84 f2 ff ff       	call   800225 <sys_page_unmap>
  800fa1:	89 d8                	mov    %ebx,%eax
}
  800fa3:	83 c4 30             	add    $0x30,%esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5e                   	pop    %esi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <pipeisclosed>:
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fba:	89 04 24             	mov    %eax,(%esp)
  800fbd:	e8 c9 f4 ff ff       	call   80048b <fd_lookup>
  800fc2:	89 c2                	mov    %eax,%edx
  800fc4:	85 d2                	test   %edx,%edx
  800fc6:	78 15                	js     800fdd <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  800fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcb:	89 04 24             	mov    %eax,(%esp)
  800fce:	e8 2d f4 ff ff       	call   800400 <fd2data>
	return _pipeisclosed(fd, p);
  800fd3:	89 c2                	mov    %eax,%edx
  800fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd8:	e8 de fc ff ff       	call   800cbb <_pipeisclosed>
}
  800fdd:	c9                   	leave  
  800fde:	c3                   	ret    
  800fdf:	90                   	nop

00800fe0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800fe3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    

00800fea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800ff0:	c7 44 24 04 b0 21 80 	movl   $0x8021b0,0x4(%esp)
  800ff7:	00 
  800ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffb:	89 04 24             	mov    %eax,(%esp)
  800ffe:	e8 e8 08 00 00       	call   8018eb <strcpy>
	return 0;
}
  801003:	b8 00 00 00 00       	mov    $0x0,%eax
  801008:	c9                   	leave  
  801009:	c3                   	ret    

0080100a <devcons_write>:
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	57                   	push   %edi
  80100e:	56                   	push   %esi
  80100f:	53                   	push   %ebx
  801010:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801016:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80101a:	74 4a                	je     801066 <devcons_write+0x5c>
  80101c:	b8 00 00 00 00       	mov    $0x0,%eax
  801021:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801026:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  80102c:	8b 75 10             	mov    0x10(%ebp),%esi
  80102f:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  801031:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801034:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801039:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80103c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801040:	03 45 0c             	add    0xc(%ebp),%eax
  801043:	89 44 24 04          	mov    %eax,0x4(%esp)
  801047:	89 3c 24             	mov    %edi,(%esp)
  80104a:	e8 97 0a 00 00       	call   801ae6 <memmove>
		sys_cputs(buf, m);
  80104f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801053:	89 3c 24             	mov    %edi,(%esp)
  801056:	e8 56 f0 ff ff       	call   8000b1 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80105b:	01 f3                	add    %esi,%ebx
  80105d:	89 d8                	mov    %ebx,%eax
  80105f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801062:	72 c8                	jb     80102c <devcons_write+0x22>
  801064:	eb 05                	jmp    80106b <devcons_write+0x61>
  801066:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  80106b:	89 d8                	mov    %ebx,%eax
  80106d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801073:	5b                   	pop    %ebx
  801074:	5e                   	pop    %esi
  801075:	5f                   	pop    %edi
  801076:	5d                   	pop    %ebp
  801077:	c3                   	ret    

00801078 <devcons_read>:
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80107e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801083:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801087:	75 07                	jne    801090 <devcons_read+0x18>
  801089:	eb 28                	jmp    8010b3 <devcons_read+0x3b>
		sys_yield();
  80108b:	e8 cf f0 ff ff       	call   80015f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801090:	e8 3a f0 ff ff       	call   8000cf <sys_cgetc>
  801095:	85 c0                	test   %eax,%eax
  801097:	74 f2                	je     80108b <devcons_read+0x13>
	if (c < 0)
  801099:	85 c0                	test   %eax,%eax
  80109b:	78 16                	js     8010b3 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  80109d:	83 f8 04             	cmp    $0x4,%eax
  8010a0:	74 0c                	je     8010ae <devcons_read+0x36>
	*(char*)vbuf = c;
  8010a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a5:	88 02                	mov    %al,(%edx)
	return 1;
  8010a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ac:	eb 05                	jmp    8010b3 <devcons_read+0x3b>
		return 0;
  8010ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010b3:	c9                   	leave  
  8010b4:	c3                   	ret    

008010b5 <cputchar>:
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010be:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8010c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010c8:	00 
  8010c9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010cc:	89 04 24             	mov    %eax,(%esp)
  8010cf:	e8 dd ef ff ff       	call   8000b1 <sys_cputs>
}
  8010d4:	c9                   	leave  
  8010d5:	c3                   	ret    

008010d6 <getchar>:
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  8010dc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010e3:	00 
  8010e4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f2:	e8 3f f6 ff ff       	call   800736 <read>
	if (r < 0)
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	78 0f                	js     80110a <getchar+0x34>
	if (r < 1)
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	7e 06                	jle    801105 <getchar+0x2f>
	return c;
  8010ff:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801103:	eb 05                	jmp    80110a <getchar+0x34>
		return -E_EOF;
  801105:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80110a:	c9                   	leave  
  80110b:	c3                   	ret    

0080110c <iscons>:
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801112:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801115:	89 44 24 04          	mov    %eax,0x4(%esp)
  801119:	8b 45 08             	mov    0x8(%ebp),%eax
  80111c:	89 04 24             	mov    %eax,(%esp)
  80111f:	e8 67 f3 ff ff       	call   80048b <fd_lookup>
  801124:	85 c0                	test   %eax,%eax
  801126:	78 11                	js     801139 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801128:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112b:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801131:	39 10                	cmp    %edx,(%eax)
  801133:	0f 94 c0             	sete   %al
  801136:	0f b6 c0             	movzbl %al,%eax
}
  801139:	c9                   	leave  
  80113a:	c3                   	ret    

0080113b <opencons>:
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801141:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801144:	89 04 24             	mov    %eax,(%esp)
  801147:	e8 cb f2 ff ff       	call   800417 <fd_alloc>
		return r;
  80114c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80114e:	85 c0                	test   %eax,%eax
  801150:	78 40                	js     801192 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801152:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801159:	00 
  80115a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801161:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801168:	e8 11 f0 ff ff       	call   80017e <sys_page_alloc>
		return r;
  80116d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80116f:	85 c0                	test   %eax,%eax
  801171:	78 1f                	js     801192 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801173:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801179:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80117e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801181:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801188:	89 04 24             	mov    %eax,(%esp)
  80118b:	e8 60 f2 ff ff       	call   8003f0 <fd2num>
  801190:	89 c2                	mov    %eax,%edx
}
  801192:	89 d0                	mov    %edx,%eax
  801194:	c9                   	leave  
  801195:	c3                   	ret    

00801196 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	56                   	push   %esi
  80119a:	53                   	push   %ebx
  80119b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80119e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011a1:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8011a7:	e8 94 ef ff ff       	call   800140 <sys_getenvid>
  8011ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011af:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011ba:	89 74 24 08          	mov    %esi,0x8(%esp)
  8011be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c2:	c7 04 24 bc 21 80 00 	movl   $0x8021bc,(%esp)
  8011c9:	e8 c1 00 00 00       	call   80128f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d5:	89 04 24             	mov    %eax,(%esp)
  8011d8:	e8 51 00 00 00       	call   80122e <vcprintf>
	cprintf("\n");
  8011dd:	c7 04 24 a9 21 80 00 	movl   $0x8021a9,(%esp)
  8011e4:	e8 a6 00 00 00       	call   80128f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011e9:	cc                   	int3   
  8011ea:	eb fd                	jmp    8011e9 <_panic+0x53>

008011ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 14             	sub    $0x14,%esp
  8011f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8011f6:	8b 13                	mov    (%ebx),%edx
  8011f8:	8d 42 01             	lea    0x1(%edx),%eax
  8011fb:	89 03                	mov    %eax,(%ebx)
  8011fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801200:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801204:	3d ff 00 00 00       	cmp    $0xff,%eax
  801209:	75 19                	jne    801224 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80120b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801212:	00 
  801213:	8d 43 08             	lea    0x8(%ebx),%eax
  801216:	89 04 24             	mov    %eax,(%esp)
  801219:	e8 93 ee ff ff       	call   8000b1 <sys_cputs>
		b->idx = 0;
  80121e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801224:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801228:	83 c4 14             	add    $0x14,%esp
  80122b:	5b                   	pop    %ebx
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    

0080122e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801237:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80123e:	00 00 00 
	b.cnt = 0;
  801241:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801248:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80124b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801252:	8b 45 08             	mov    0x8(%ebp),%eax
  801255:	89 44 24 08          	mov    %eax,0x8(%esp)
  801259:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80125f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801263:	c7 04 24 ec 11 80 00 	movl   $0x8011ec,(%esp)
  80126a:	e8 b5 01 00 00       	call   801424 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80126f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801275:	89 44 24 04          	mov    %eax,0x4(%esp)
  801279:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80127f:	89 04 24             	mov    %eax,(%esp)
  801282:	e8 2a ee ff ff       	call   8000b1 <sys_cputs>

	return b.cnt;
}
  801287:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80128d:	c9                   	leave  
  80128e:	c3                   	ret    

0080128f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801295:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129c:	8b 45 08             	mov    0x8(%ebp),%eax
  80129f:	89 04 24             	mov    %eax,(%esp)
  8012a2:	e8 87 ff ff ff       	call   80122e <vcprintf>
	va_end(ap);

	return cnt;
}
  8012a7:	c9                   	leave  
  8012a8:	c3                   	ret    
  8012a9:	66 90                	xchg   %ax,%ax
  8012ab:	66 90                	xchg   %ax,%ax
  8012ad:	66 90                	xchg   %ax,%ax
  8012af:	90                   	nop

008012b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	57                   	push   %edi
  8012b4:	56                   	push   %esi
  8012b5:	53                   	push   %ebx
  8012b6:	83 ec 3c             	sub    $0x3c,%esp
  8012b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012bc:	89 d7                	mov    %edx,%edi
  8012be:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012c7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8012ca:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8012cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012d5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8012d8:	39 f1                	cmp    %esi,%ecx
  8012da:	72 14                	jb     8012f0 <printnum+0x40>
  8012dc:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8012df:	76 0f                	jbe    8012f0 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8012e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e4:	8d 70 ff             	lea    -0x1(%eax),%esi
  8012e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8012ea:	85 f6                	test   %esi,%esi
  8012ec:	7f 60                	jg     80134e <printnum+0x9e>
  8012ee:	eb 72                	jmp    801362 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8012f0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8012f3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012f7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8012fa:	8d 51 ff             	lea    -0x1(%ecx),%edx
  8012fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801301:	89 44 24 08          	mov    %eax,0x8(%esp)
  801305:	8b 44 24 08          	mov    0x8(%esp),%eax
  801309:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80130d:	89 c3                	mov    %eax,%ebx
  80130f:	89 d6                	mov    %edx,%esi
  801311:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801314:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801317:	89 54 24 08          	mov    %edx,0x8(%esp)
  80131b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80131f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801322:	89 04 24             	mov    %eax,(%esp)
  801325:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132c:	e8 cf 0a 00 00       	call   801e00 <__udivdi3>
  801331:	89 d9                	mov    %ebx,%ecx
  801333:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801337:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80133b:	89 04 24             	mov    %eax,(%esp)
  80133e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801342:	89 fa                	mov    %edi,%edx
  801344:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801347:	e8 64 ff ff ff       	call   8012b0 <printnum>
  80134c:	eb 14                	jmp    801362 <printnum+0xb2>
			putch(padc, putdat);
  80134e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801352:	8b 45 18             	mov    0x18(%ebp),%eax
  801355:	89 04 24             	mov    %eax,(%esp)
  801358:	ff d3                	call   *%ebx
		while (--width > 0)
  80135a:	83 ee 01             	sub    $0x1,%esi
  80135d:	75 ef                	jne    80134e <printnum+0x9e>
  80135f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801362:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801366:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80136a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80136d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801370:	89 44 24 08          	mov    %eax,0x8(%esp)
  801374:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801378:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80137b:	89 04 24             	mov    %eax,(%esp)
  80137e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801381:	89 44 24 04          	mov    %eax,0x4(%esp)
  801385:	e8 a6 0b 00 00       	call   801f30 <__umoddi3>
  80138a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80138e:	0f be 80 df 21 80 00 	movsbl 0x8021df(%eax),%eax
  801395:	89 04 24             	mov    %eax,(%esp)
  801398:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80139b:	ff d0                	call   *%eax
}
  80139d:	83 c4 3c             	add    $0x3c,%esp
  8013a0:	5b                   	pop    %ebx
  8013a1:	5e                   	pop    %esi
  8013a2:	5f                   	pop    %edi
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    

008013a5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8013a8:	83 fa 01             	cmp    $0x1,%edx
  8013ab:	7e 0e                	jle    8013bb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8013ad:	8b 10                	mov    (%eax),%edx
  8013af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8013b2:	89 08                	mov    %ecx,(%eax)
  8013b4:	8b 02                	mov    (%edx),%eax
  8013b6:	8b 52 04             	mov    0x4(%edx),%edx
  8013b9:	eb 22                	jmp    8013dd <getuint+0x38>
	else if (lflag)
  8013bb:	85 d2                	test   %edx,%edx
  8013bd:	74 10                	je     8013cf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8013bf:	8b 10                	mov    (%eax),%edx
  8013c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013c4:	89 08                	mov    %ecx,(%eax)
  8013c6:	8b 02                	mov    (%edx),%eax
  8013c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013cd:	eb 0e                	jmp    8013dd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8013cf:	8b 10                	mov    (%eax),%edx
  8013d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013d4:	89 08                	mov    %ecx,(%eax)
  8013d6:	8b 02                	mov    (%edx),%eax
  8013d8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8013e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8013e9:	8b 10                	mov    (%eax),%edx
  8013eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8013ee:	73 0a                	jae    8013fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8013f0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8013f3:	89 08                	mov    %ecx,(%eax)
  8013f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f8:	88 02                	mov    %al,(%edx)
}
  8013fa:	5d                   	pop    %ebp
  8013fb:	c3                   	ret    

008013fc <printfmt>:
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  801402:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801405:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801409:	8b 45 10             	mov    0x10(%ebp),%eax
  80140c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801410:	8b 45 0c             	mov    0xc(%ebp),%eax
  801413:	89 44 24 04          	mov    %eax,0x4(%esp)
  801417:	8b 45 08             	mov    0x8(%ebp),%eax
  80141a:	89 04 24             	mov    %eax,(%esp)
  80141d:	e8 02 00 00 00       	call   801424 <vprintfmt>
}
  801422:	c9                   	leave  
  801423:	c3                   	ret    

00801424 <vprintfmt>:
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	57                   	push   %edi
  801428:	56                   	push   %esi
  801429:	53                   	push   %ebx
  80142a:	83 ec 3c             	sub    $0x3c,%esp
  80142d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801430:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801433:	eb 18                	jmp    80144d <vprintfmt+0x29>
			if (ch == '\0')
  801435:	85 c0                	test   %eax,%eax
  801437:	0f 84 c3 03 00 00    	je     801800 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80143d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801441:	89 04 24             	mov    %eax,(%esp)
  801444:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801447:	89 f3                	mov    %esi,%ebx
  801449:	eb 02                	jmp    80144d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80144b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80144d:	8d 73 01             	lea    0x1(%ebx),%esi
  801450:	0f b6 03             	movzbl (%ebx),%eax
  801453:	83 f8 25             	cmp    $0x25,%eax
  801456:	75 dd                	jne    801435 <vprintfmt+0x11>
  801458:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80145c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801463:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80146a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801471:	ba 00 00 00 00       	mov    $0x0,%edx
  801476:	eb 1d                	jmp    801495 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  801478:	89 de                	mov    %ebx,%esi
			padc = '-';
  80147a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80147e:	eb 15                	jmp    801495 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  801480:	89 de                	mov    %ebx,%esi
			padc = '0';
  801482:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  801486:	eb 0d                	jmp    801495 <vprintfmt+0x71>
				width = precision, precision = -1;
  801488:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80148b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80148e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801495:	8d 5e 01             	lea    0x1(%esi),%ebx
  801498:	0f b6 06             	movzbl (%esi),%eax
  80149b:	0f b6 c8             	movzbl %al,%ecx
  80149e:	83 e8 23             	sub    $0x23,%eax
  8014a1:	3c 55                	cmp    $0x55,%al
  8014a3:	0f 87 2f 03 00 00    	ja     8017d8 <vprintfmt+0x3b4>
  8014a9:	0f b6 c0             	movzbl %al,%eax
  8014ac:	ff 24 85 20 23 80 00 	jmp    *0x802320(,%eax,4)
				precision = precision * 10 + ch - '0';
  8014b3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8014b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  8014b9:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8014bd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8014c0:	83 f9 09             	cmp    $0x9,%ecx
  8014c3:	77 50                	ja     801515 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8014c5:	89 de                	mov    %ebx,%esi
  8014c7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8014ca:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8014cd:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8014d0:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8014d4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8014d7:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8014da:	83 fb 09             	cmp    $0x9,%ebx
  8014dd:	76 eb                	jbe    8014ca <vprintfmt+0xa6>
  8014df:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8014e2:	eb 33                	jmp    801517 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  8014e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e7:	8d 48 04             	lea    0x4(%eax),%ecx
  8014ea:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8014ed:	8b 00                	mov    (%eax),%eax
  8014ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8014f2:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8014f4:	eb 21                	jmp    801517 <vprintfmt+0xf3>
  8014f6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8014f9:	85 c9                	test   %ecx,%ecx
  8014fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801500:	0f 49 c1             	cmovns %ecx,%eax
  801503:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801506:	89 de                	mov    %ebx,%esi
  801508:	eb 8b                	jmp    801495 <vprintfmt+0x71>
  80150a:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80150c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801513:	eb 80                	jmp    801495 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  801515:	89 de                	mov    %ebx,%esi
			if (width < 0)
  801517:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80151b:	0f 89 74 ff ff ff    	jns    801495 <vprintfmt+0x71>
  801521:	e9 62 ff ff ff       	jmp    801488 <vprintfmt+0x64>
			lflag++;
  801526:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  801529:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80152b:	e9 65 ff ff ff       	jmp    801495 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  801530:	8b 45 14             	mov    0x14(%ebp),%eax
  801533:	8d 50 04             	lea    0x4(%eax),%edx
  801536:	89 55 14             	mov    %edx,0x14(%ebp)
  801539:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80153d:	8b 00                	mov    (%eax),%eax
  80153f:	89 04 24             	mov    %eax,(%esp)
  801542:	ff 55 08             	call   *0x8(%ebp)
			break;
  801545:	e9 03 ff ff ff       	jmp    80144d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80154a:	8b 45 14             	mov    0x14(%ebp),%eax
  80154d:	8d 50 04             	lea    0x4(%eax),%edx
  801550:	89 55 14             	mov    %edx,0x14(%ebp)
  801553:	8b 00                	mov    (%eax),%eax
  801555:	99                   	cltd   
  801556:	31 d0                	xor    %edx,%eax
  801558:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80155a:	83 f8 0f             	cmp    $0xf,%eax
  80155d:	7f 0b                	jg     80156a <vprintfmt+0x146>
  80155f:	8b 14 85 80 24 80 00 	mov    0x802480(,%eax,4),%edx
  801566:	85 d2                	test   %edx,%edx
  801568:	75 20                	jne    80158a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80156a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80156e:	c7 44 24 08 f7 21 80 	movl   $0x8021f7,0x8(%esp)
  801575:	00 
  801576:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80157a:	8b 45 08             	mov    0x8(%ebp),%eax
  80157d:	89 04 24             	mov    %eax,(%esp)
  801580:	e8 77 fe ff ff       	call   8013fc <printfmt>
  801585:	e9 c3 fe ff ff       	jmp    80144d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80158a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80158e:	c7 44 24 08 77 21 80 	movl   $0x802177,0x8(%esp)
  801595:	00 
  801596:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80159a:	8b 45 08             	mov    0x8(%ebp),%eax
  80159d:	89 04 24             	mov    %eax,(%esp)
  8015a0:	e8 57 fe ff ff       	call   8013fc <printfmt>
  8015a5:	e9 a3 fe ff ff       	jmp    80144d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  8015aa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8015ad:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  8015b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b3:	8d 50 04             	lea    0x4(%eax),%edx
  8015b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8015b9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	ba f0 21 80 00       	mov    $0x8021f0,%edx
  8015c2:	0f 45 d0             	cmovne %eax,%edx
  8015c5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8015c8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8015cc:	74 04                	je     8015d2 <vprintfmt+0x1ae>
  8015ce:	85 f6                	test   %esi,%esi
  8015d0:	7f 19                	jg     8015eb <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8015d5:	8d 70 01             	lea    0x1(%eax),%esi
  8015d8:	0f b6 10             	movzbl (%eax),%edx
  8015db:	0f be c2             	movsbl %dl,%eax
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	0f 85 95 00 00 00    	jne    80167b <vprintfmt+0x257>
  8015e6:	e9 85 00 00 00       	jmp    801670 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8015eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8015f2:	89 04 24             	mov    %eax,(%esp)
  8015f5:	e8 b8 02 00 00       	call   8018b2 <strnlen>
  8015fa:	29 c6                	sub    %eax,%esi
  8015fc:	89 f0                	mov    %esi,%eax
  8015fe:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  801601:	85 f6                	test   %esi,%esi
  801603:	7e cd                	jle    8015d2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  801605:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  801609:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80160c:	89 c3                	mov    %eax,%ebx
  80160e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801612:	89 34 24             	mov    %esi,(%esp)
  801615:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801618:	83 eb 01             	sub    $0x1,%ebx
  80161b:	75 f1                	jne    80160e <vprintfmt+0x1ea>
  80161d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801620:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801623:	eb ad                	jmp    8015d2 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  801625:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801629:	74 1e                	je     801649 <vprintfmt+0x225>
  80162b:	0f be d2             	movsbl %dl,%edx
  80162e:	83 ea 20             	sub    $0x20,%edx
  801631:	83 fa 5e             	cmp    $0x5e,%edx
  801634:	76 13                	jbe    801649 <vprintfmt+0x225>
					putch('?', putdat);
  801636:	8b 45 0c             	mov    0xc(%ebp),%eax
  801639:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801644:	ff 55 08             	call   *0x8(%ebp)
  801647:	eb 0d                	jmp    801656 <vprintfmt+0x232>
					putch(ch, putdat);
  801649:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80164c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801650:	89 04 24             	mov    %eax,(%esp)
  801653:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801656:	83 ef 01             	sub    $0x1,%edi
  801659:	83 c6 01             	add    $0x1,%esi
  80165c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  801660:	0f be c2             	movsbl %dl,%eax
  801663:	85 c0                	test   %eax,%eax
  801665:	75 20                	jne    801687 <vprintfmt+0x263>
  801667:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80166a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80166d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  801670:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801674:	7f 25                	jg     80169b <vprintfmt+0x277>
  801676:	e9 d2 fd ff ff       	jmp    80144d <vprintfmt+0x29>
  80167b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80167e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801681:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801684:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801687:	85 db                	test   %ebx,%ebx
  801689:	78 9a                	js     801625 <vprintfmt+0x201>
  80168b:	83 eb 01             	sub    $0x1,%ebx
  80168e:	79 95                	jns    801625 <vprintfmt+0x201>
  801690:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801693:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801696:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801699:	eb d5                	jmp    801670 <vprintfmt+0x24c>
  80169b:	8b 75 08             	mov    0x8(%ebp),%esi
  80169e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8016a1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  8016a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016a8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8016af:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8016b1:	83 eb 01             	sub    $0x1,%ebx
  8016b4:	75 ee                	jne    8016a4 <vprintfmt+0x280>
  8016b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016b9:	e9 8f fd ff ff       	jmp    80144d <vprintfmt+0x29>
	if (lflag >= 2)
  8016be:	83 fa 01             	cmp    $0x1,%edx
  8016c1:	7e 16                	jle    8016d9 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8016c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c6:	8d 50 08             	lea    0x8(%eax),%edx
  8016c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8016cc:	8b 50 04             	mov    0x4(%eax),%edx
  8016cf:	8b 00                	mov    (%eax),%eax
  8016d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8016d7:	eb 32                	jmp    80170b <vprintfmt+0x2e7>
	else if (lflag)
  8016d9:	85 d2                	test   %edx,%edx
  8016db:	74 18                	je     8016f5 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8016dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8016e0:	8d 50 04             	lea    0x4(%eax),%edx
  8016e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8016e6:	8b 30                	mov    (%eax),%esi
  8016e8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8016eb:	89 f0                	mov    %esi,%eax
  8016ed:	c1 f8 1f             	sar    $0x1f,%eax
  8016f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8016f3:	eb 16                	jmp    80170b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  8016f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8016f8:	8d 50 04             	lea    0x4(%eax),%edx
  8016fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8016fe:	8b 30                	mov    (%eax),%esi
  801700:	89 75 d8             	mov    %esi,-0x28(%ebp)
  801703:	89 f0                	mov    %esi,%eax
  801705:	c1 f8 1f             	sar    $0x1f,%eax
  801708:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  80170b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80170e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  801711:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  801716:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80171a:	0f 89 80 00 00 00    	jns    8017a0 <vprintfmt+0x37c>
				putch('-', putdat);
  801720:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801724:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80172b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80172e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801731:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801734:	f7 d8                	neg    %eax
  801736:	83 d2 00             	adc    $0x0,%edx
  801739:	f7 da                	neg    %edx
			base = 10;
  80173b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801740:	eb 5e                	jmp    8017a0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  801742:	8d 45 14             	lea    0x14(%ebp),%eax
  801745:	e8 5b fc ff ff       	call   8013a5 <getuint>
			base = 10;
  80174a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80174f:	eb 4f                	jmp    8017a0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  801751:	8d 45 14             	lea    0x14(%ebp),%eax
  801754:	e8 4c fc ff ff       	call   8013a5 <getuint>
			base = 8;
  801759:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80175e:	eb 40                	jmp    8017a0 <vprintfmt+0x37c>
			putch('0', putdat);
  801760:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801764:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80176b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80176e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801772:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801779:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80177c:	8b 45 14             	mov    0x14(%ebp),%eax
  80177f:	8d 50 04             	lea    0x4(%eax),%edx
  801782:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  801785:	8b 00                	mov    (%eax),%eax
  801787:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80178c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801791:	eb 0d                	jmp    8017a0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  801793:	8d 45 14             	lea    0x14(%ebp),%eax
  801796:	e8 0a fc ff ff       	call   8013a5 <getuint>
			base = 16;
  80179b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8017a0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8017a4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8017a8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8017ab:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017b3:	89 04 24             	mov    %eax,(%esp)
  8017b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017ba:	89 fa                	mov    %edi,%edx
  8017bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bf:	e8 ec fa ff ff       	call   8012b0 <printnum>
			break;
  8017c4:	e9 84 fc ff ff       	jmp    80144d <vprintfmt+0x29>
			putch(ch, putdat);
  8017c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017cd:	89 0c 24             	mov    %ecx,(%esp)
  8017d0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8017d3:	e9 75 fc ff ff       	jmp    80144d <vprintfmt+0x29>
			putch('%', putdat);
  8017d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017e3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017e6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8017ea:	0f 84 5b fc ff ff    	je     80144b <vprintfmt+0x27>
  8017f0:	89 f3                	mov    %esi,%ebx
  8017f2:	83 eb 01             	sub    $0x1,%ebx
  8017f5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8017f9:	75 f7                	jne    8017f2 <vprintfmt+0x3ce>
  8017fb:	e9 4d fc ff ff       	jmp    80144d <vprintfmt+0x29>
}
  801800:	83 c4 3c             	add    $0x3c,%esp
  801803:	5b                   	pop    %ebx
  801804:	5e                   	pop    %esi
  801805:	5f                   	pop    %edi
  801806:	5d                   	pop    %ebp
  801807:	c3                   	ret    

00801808 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	83 ec 28             	sub    $0x28,%esp
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801814:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801817:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80181b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80181e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801825:	85 c0                	test   %eax,%eax
  801827:	74 30                	je     801859 <vsnprintf+0x51>
  801829:	85 d2                	test   %edx,%edx
  80182b:	7e 2c                	jle    801859 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80182d:	8b 45 14             	mov    0x14(%ebp),%eax
  801830:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801834:	8b 45 10             	mov    0x10(%ebp),%eax
  801837:	89 44 24 08          	mov    %eax,0x8(%esp)
  80183b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80183e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801842:	c7 04 24 df 13 80 00 	movl   $0x8013df,(%esp)
  801849:	e8 d6 fb ff ff       	call   801424 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80184e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801851:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801854:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801857:	eb 05                	jmp    80185e <vsnprintf+0x56>
		return -E_INVAL;
  801859:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801866:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801869:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80186d:	8b 45 10             	mov    0x10(%ebp),%eax
  801870:	89 44 24 08          	mov    %eax,0x8(%esp)
  801874:	8b 45 0c             	mov    0xc(%ebp),%eax
  801877:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187b:	8b 45 08             	mov    0x8(%ebp),%eax
  80187e:	89 04 24             	mov    %eax,(%esp)
  801881:	e8 82 ff ff ff       	call   801808 <vsnprintf>
	va_end(ap);

	return rc;
}
  801886:	c9                   	leave  
  801887:	c3                   	ret    
  801888:	66 90                	xchg   %ax,%ax
  80188a:	66 90                	xchg   %ax,%ax
  80188c:	66 90                	xchg   %ax,%ax
  80188e:	66 90                	xchg   %ax,%ax

00801890 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801896:	80 3a 00             	cmpb   $0x0,(%edx)
  801899:	74 10                	je     8018ab <strlen+0x1b>
  80189b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8018a0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8018a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8018a7:	75 f7                	jne    8018a0 <strlen+0x10>
  8018a9:	eb 05                	jmp    8018b0 <strlen+0x20>
  8018ab:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8018b0:	5d                   	pop    %ebp
  8018b1:	c3                   	ret    

008018b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	53                   	push   %ebx
  8018b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8018bc:	85 c9                	test   %ecx,%ecx
  8018be:	74 1c                	je     8018dc <strnlen+0x2a>
  8018c0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8018c3:	74 1e                	je     8018e3 <strnlen+0x31>
  8018c5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8018ca:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8018cc:	39 ca                	cmp    %ecx,%edx
  8018ce:	74 18                	je     8018e8 <strnlen+0x36>
  8018d0:	83 c2 01             	add    $0x1,%edx
  8018d3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8018d8:	75 f0                	jne    8018ca <strnlen+0x18>
  8018da:	eb 0c                	jmp    8018e8 <strnlen+0x36>
  8018dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e1:	eb 05                	jmp    8018e8 <strnlen+0x36>
  8018e3:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8018e8:	5b                   	pop    %ebx
  8018e9:	5d                   	pop    %ebp
  8018ea:	c3                   	ret    

008018eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	53                   	push   %ebx
  8018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8018f5:	89 c2                	mov    %eax,%edx
  8018f7:	83 c2 01             	add    $0x1,%edx
  8018fa:	83 c1 01             	add    $0x1,%ecx
  8018fd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801901:	88 5a ff             	mov    %bl,-0x1(%edx)
  801904:	84 db                	test   %bl,%bl
  801906:	75 ef                	jne    8018f7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801908:	5b                   	pop    %ebx
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	53                   	push   %ebx
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801915:	89 1c 24             	mov    %ebx,(%esp)
  801918:	e8 73 ff ff ff       	call   801890 <strlen>
	strcpy(dst + len, src);
  80191d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801920:	89 54 24 04          	mov    %edx,0x4(%esp)
  801924:	01 d8                	add    %ebx,%eax
  801926:	89 04 24             	mov    %eax,(%esp)
  801929:	e8 bd ff ff ff       	call   8018eb <strcpy>
	return dst;
}
  80192e:	89 d8                	mov    %ebx,%eax
  801930:	83 c4 08             	add    $0x8,%esp
  801933:	5b                   	pop    %ebx
  801934:	5d                   	pop    %ebp
  801935:	c3                   	ret    

00801936 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	56                   	push   %esi
  80193a:	53                   	push   %ebx
  80193b:	8b 75 08             	mov    0x8(%ebp),%esi
  80193e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801941:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801944:	85 db                	test   %ebx,%ebx
  801946:	74 17                	je     80195f <strncpy+0x29>
  801948:	01 f3                	add    %esi,%ebx
  80194a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80194c:	83 c1 01             	add    $0x1,%ecx
  80194f:	0f b6 02             	movzbl (%edx),%eax
  801952:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801955:	80 3a 01             	cmpb   $0x1,(%edx)
  801958:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80195b:	39 d9                	cmp    %ebx,%ecx
  80195d:	75 ed                	jne    80194c <strncpy+0x16>
	}
	return ret;
}
  80195f:	89 f0                	mov    %esi,%eax
  801961:	5b                   	pop    %ebx
  801962:	5e                   	pop    %esi
  801963:	5d                   	pop    %ebp
  801964:	c3                   	ret    

00801965 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	57                   	push   %edi
  801969:	56                   	push   %esi
  80196a:	53                   	push   %ebx
  80196b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80196e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801971:	8b 75 10             	mov    0x10(%ebp),%esi
  801974:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801976:	85 f6                	test   %esi,%esi
  801978:	74 34                	je     8019ae <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  80197a:	83 fe 01             	cmp    $0x1,%esi
  80197d:	74 26                	je     8019a5 <strlcpy+0x40>
  80197f:	0f b6 0b             	movzbl (%ebx),%ecx
  801982:	84 c9                	test   %cl,%cl
  801984:	74 23                	je     8019a9 <strlcpy+0x44>
  801986:	83 ee 02             	sub    $0x2,%esi
  801989:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  80198e:	83 c0 01             	add    $0x1,%eax
  801991:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801994:	39 f2                	cmp    %esi,%edx
  801996:	74 13                	je     8019ab <strlcpy+0x46>
  801998:	83 c2 01             	add    $0x1,%edx
  80199b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80199f:	84 c9                	test   %cl,%cl
  8019a1:	75 eb                	jne    80198e <strlcpy+0x29>
  8019a3:	eb 06                	jmp    8019ab <strlcpy+0x46>
  8019a5:	89 f8                	mov    %edi,%eax
  8019a7:	eb 02                	jmp    8019ab <strlcpy+0x46>
  8019a9:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  8019ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8019ae:	29 f8                	sub    %edi,%eax
}
  8019b0:	5b                   	pop    %ebx
  8019b1:	5e                   	pop    %esi
  8019b2:	5f                   	pop    %edi
  8019b3:	5d                   	pop    %ebp
  8019b4:	c3                   	ret    

008019b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8019be:	0f b6 01             	movzbl (%ecx),%eax
  8019c1:	84 c0                	test   %al,%al
  8019c3:	74 15                	je     8019da <strcmp+0x25>
  8019c5:	3a 02                	cmp    (%edx),%al
  8019c7:	75 11                	jne    8019da <strcmp+0x25>
		p++, q++;
  8019c9:	83 c1 01             	add    $0x1,%ecx
  8019cc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8019cf:	0f b6 01             	movzbl (%ecx),%eax
  8019d2:	84 c0                	test   %al,%al
  8019d4:	74 04                	je     8019da <strcmp+0x25>
  8019d6:	3a 02                	cmp    (%edx),%al
  8019d8:	74 ef                	je     8019c9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8019da:	0f b6 c0             	movzbl %al,%eax
  8019dd:	0f b6 12             	movzbl (%edx),%edx
  8019e0:	29 d0                	sub    %edx,%eax
}
  8019e2:	5d                   	pop    %ebp
  8019e3:	c3                   	ret    

008019e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	56                   	push   %esi
  8019e8:	53                   	push   %ebx
  8019e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8019ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ef:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8019f2:	85 f6                	test   %esi,%esi
  8019f4:	74 29                	je     801a1f <strncmp+0x3b>
  8019f6:	0f b6 03             	movzbl (%ebx),%eax
  8019f9:	84 c0                	test   %al,%al
  8019fb:	74 30                	je     801a2d <strncmp+0x49>
  8019fd:	3a 02                	cmp    (%edx),%al
  8019ff:	75 2c                	jne    801a2d <strncmp+0x49>
  801a01:	8d 43 01             	lea    0x1(%ebx),%eax
  801a04:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  801a06:	89 c3                	mov    %eax,%ebx
  801a08:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801a0b:	39 f0                	cmp    %esi,%eax
  801a0d:	74 17                	je     801a26 <strncmp+0x42>
  801a0f:	0f b6 08             	movzbl (%eax),%ecx
  801a12:	84 c9                	test   %cl,%cl
  801a14:	74 17                	je     801a2d <strncmp+0x49>
  801a16:	83 c0 01             	add    $0x1,%eax
  801a19:	3a 0a                	cmp    (%edx),%cl
  801a1b:	74 e9                	je     801a06 <strncmp+0x22>
  801a1d:	eb 0e                	jmp    801a2d <strncmp+0x49>
	if (n == 0)
		return 0;
  801a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a24:	eb 0f                	jmp    801a35 <strncmp+0x51>
  801a26:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2b:	eb 08                	jmp    801a35 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801a2d:	0f b6 03             	movzbl (%ebx),%eax
  801a30:	0f b6 12             	movzbl (%edx),%edx
  801a33:	29 d0                	sub    %edx,%eax
}
  801a35:	5b                   	pop    %ebx
  801a36:	5e                   	pop    %esi
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	53                   	push   %ebx
  801a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a40:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  801a43:	0f b6 18             	movzbl (%eax),%ebx
  801a46:	84 db                	test   %bl,%bl
  801a48:	74 1d                	je     801a67 <strchr+0x2e>
  801a4a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  801a4c:	38 d3                	cmp    %dl,%bl
  801a4e:	75 06                	jne    801a56 <strchr+0x1d>
  801a50:	eb 1a                	jmp    801a6c <strchr+0x33>
  801a52:	38 ca                	cmp    %cl,%dl
  801a54:	74 16                	je     801a6c <strchr+0x33>
	for (; *s; s++)
  801a56:	83 c0 01             	add    $0x1,%eax
  801a59:	0f b6 10             	movzbl (%eax),%edx
  801a5c:	84 d2                	test   %dl,%dl
  801a5e:	75 f2                	jne    801a52 <strchr+0x19>
			return (char *) s;
	return 0;
  801a60:	b8 00 00 00 00       	mov    $0x0,%eax
  801a65:	eb 05                	jmp    801a6c <strchr+0x33>
  801a67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a6c:	5b                   	pop    %ebx
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	53                   	push   %ebx
  801a73:	8b 45 08             	mov    0x8(%ebp),%eax
  801a76:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  801a79:	0f b6 18             	movzbl (%eax),%ebx
  801a7c:	84 db                	test   %bl,%bl
  801a7e:	74 16                	je     801a96 <strfind+0x27>
  801a80:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  801a82:	38 d3                	cmp    %dl,%bl
  801a84:	75 06                	jne    801a8c <strfind+0x1d>
  801a86:	eb 0e                	jmp    801a96 <strfind+0x27>
  801a88:	38 ca                	cmp    %cl,%dl
  801a8a:	74 0a                	je     801a96 <strfind+0x27>
	for (; *s; s++)
  801a8c:	83 c0 01             	add    $0x1,%eax
  801a8f:	0f b6 10             	movzbl (%eax),%edx
  801a92:	84 d2                	test   %dl,%dl
  801a94:	75 f2                	jne    801a88 <strfind+0x19>
			break;
	return (char *) s;
}
  801a96:	5b                   	pop    %ebx
  801a97:	5d                   	pop    %ebp
  801a98:	c3                   	ret    

00801a99 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	57                   	push   %edi
  801a9d:	56                   	push   %esi
  801a9e:	53                   	push   %ebx
  801a9f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aa2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801aa5:	85 c9                	test   %ecx,%ecx
  801aa7:	74 36                	je     801adf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801aa9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801aaf:	75 28                	jne    801ad9 <memset+0x40>
  801ab1:	f6 c1 03             	test   $0x3,%cl
  801ab4:	75 23                	jne    801ad9 <memset+0x40>
		c &= 0xFF;
  801ab6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801aba:	89 d3                	mov    %edx,%ebx
  801abc:	c1 e3 08             	shl    $0x8,%ebx
  801abf:	89 d6                	mov    %edx,%esi
  801ac1:	c1 e6 18             	shl    $0x18,%esi
  801ac4:	89 d0                	mov    %edx,%eax
  801ac6:	c1 e0 10             	shl    $0x10,%eax
  801ac9:	09 f0                	or     %esi,%eax
  801acb:	09 c2                	or     %eax,%edx
  801acd:	89 d0                	mov    %edx,%eax
  801acf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801ad1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801ad4:	fc                   	cld    
  801ad5:	f3 ab                	rep stos %eax,%es:(%edi)
  801ad7:	eb 06                	jmp    801adf <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801adc:	fc                   	cld    
  801add:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801adf:	89 f8                	mov    %edi,%eax
  801ae1:	5b                   	pop    %ebx
  801ae2:	5e                   	pop    %esi
  801ae3:	5f                   	pop    %edi
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    

00801ae6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	57                   	push   %edi
  801aea:	56                   	push   %esi
  801aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  801aee:	8b 75 0c             	mov    0xc(%ebp),%esi
  801af1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801af4:	39 c6                	cmp    %eax,%esi
  801af6:	73 35                	jae    801b2d <memmove+0x47>
  801af8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801afb:	39 d0                	cmp    %edx,%eax
  801afd:	73 2e                	jae    801b2d <memmove+0x47>
		s += n;
		d += n;
  801aff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801b02:	89 d6                	mov    %edx,%esi
  801b04:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801b0c:	75 13                	jne    801b21 <memmove+0x3b>
  801b0e:	f6 c1 03             	test   $0x3,%cl
  801b11:	75 0e                	jne    801b21 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801b13:	83 ef 04             	sub    $0x4,%edi
  801b16:	8d 72 fc             	lea    -0x4(%edx),%esi
  801b19:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801b1c:	fd                   	std    
  801b1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801b1f:	eb 09                	jmp    801b2a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801b21:	83 ef 01             	sub    $0x1,%edi
  801b24:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801b27:	fd                   	std    
  801b28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801b2a:	fc                   	cld    
  801b2b:	eb 1d                	jmp    801b4a <memmove+0x64>
  801b2d:	89 f2                	mov    %esi,%edx
  801b2f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b31:	f6 c2 03             	test   $0x3,%dl
  801b34:	75 0f                	jne    801b45 <memmove+0x5f>
  801b36:	f6 c1 03             	test   $0x3,%cl
  801b39:	75 0a                	jne    801b45 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801b3b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801b3e:	89 c7                	mov    %eax,%edi
  801b40:	fc                   	cld    
  801b41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801b43:	eb 05                	jmp    801b4a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  801b45:	89 c7                	mov    %eax,%edi
  801b47:	fc                   	cld    
  801b48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801b4a:	5e                   	pop    %esi
  801b4b:	5f                   	pop    %edi
  801b4c:	5d                   	pop    %ebp
  801b4d:	c3                   	ret    

00801b4e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801b54:	8b 45 10             	mov    0x10(%ebp),%eax
  801b57:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b62:	8b 45 08             	mov    0x8(%ebp),%eax
  801b65:	89 04 24             	mov    %eax,(%esp)
  801b68:	e8 79 ff ff ff       	call   801ae6 <memmove>
}
  801b6d:	c9                   	leave  
  801b6e:	c3                   	ret    

00801b6f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	57                   	push   %edi
  801b73:	56                   	push   %esi
  801b74:	53                   	push   %ebx
  801b75:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b78:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b7b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801b7e:	8d 78 ff             	lea    -0x1(%eax),%edi
  801b81:	85 c0                	test   %eax,%eax
  801b83:	74 36                	je     801bbb <memcmp+0x4c>
		if (*s1 != *s2)
  801b85:	0f b6 03             	movzbl (%ebx),%eax
  801b88:	0f b6 0e             	movzbl (%esi),%ecx
  801b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b90:	38 c8                	cmp    %cl,%al
  801b92:	74 1c                	je     801bb0 <memcmp+0x41>
  801b94:	eb 10                	jmp    801ba6 <memcmp+0x37>
  801b96:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801b9b:	83 c2 01             	add    $0x1,%edx
  801b9e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  801ba2:	38 c8                	cmp    %cl,%al
  801ba4:	74 0a                	je     801bb0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801ba6:	0f b6 c0             	movzbl %al,%eax
  801ba9:	0f b6 c9             	movzbl %cl,%ecx
  801bac:	29 c8                	sub    %ecx,%eax
  801bae:	eb 10                	jmp    801bc0 <memcmp+0x51>
	while (n-- > 0) {
  801bb0:	39 fa                	cmp    %edi,%edx
  801bb2:	75 e2                	jne    801b96 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  801bb4:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb9:	eb 05                	jmp    801bc0 <memcmp+0x51>
  801bbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bc0:	5b                   	pop    %ebx
  801bc1:	5e                   	pop    %esi
  801bc2:	5f                   	pop    %edi
  801bc3:	5d                   	pop    %ebp
  801bc4:	c3                   	ret    

00801bc5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801bc5:	55                   	push   %ebp
  801bc6:	89 e5                	mov    %esp,%ebp
  801bc8:	53                   	push   %ebx
  801bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  801bcf:	89 c2                	mov    %eax,%edx
  801bd1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801bd4:	39 d0                	cmp    %edx,%eax
  801bd6:	73 13                	jae    801beb <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801bd8:	89 d9                	mov    %ebx,%ecx
  801bda:	38 18                	cmp    %bl,(%eax)
  801bdc:	75 06                	jne    801be4 <memfind+0x1f>
  801bde:	eb 0b                	jmp    801beb <memfind+0x26>
  801be0:	38 08                	cmp    %cl,(%eax)
  801be2:	74 07                	je     801beb <memfind+0x26>
	for (; s < ends; s++)
  801be4:	83 c0 01             	add    $0x1,%eax
  801be7:	39 d0                	cmp    %edx,%eax
  801be9:	75 f5                	jne    801be0 <memfind+0x1b>
			break;
	return (void *) s;
}
  801beb:	5b                   	pop    %ebx
  801bec:	5d                   	pop    %ebp
  801bed:	c3                   	ret    

00801bee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  801bf7:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801bfa:	0f b6 0a             	movzbl (%edx),%ecx
  801bfd:	80 f9 09             	cmp    $0x9,%cl
  801c00:	74 05                	je     801c07 <strtol+0x19>
  801c02:	80 f9 20             	cmp    $0x20,%cl
  801c05:	75 10                	jne    801c17 <strtol+0x29>
		s++;
  801c07:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801c0a:	0f b6 0a             	movzbl (%edx),%ecx
  801c0d:	80 f9 09             	cmp    $0x9,%cl
  801c10:	74 f5                	je     801c07 <strtol+0x19>
  801c12:	80 f9 20             	cmp    $0x20,%cl
  801c15:	74 f0                	je     801c07 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  801c17:	80 f9 2b             	cmp    $0x2b,%cl
  801c1a:	75 0a                	jne    801c26 <strtol+0x38>
		s++;
  801c1c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801c1f:	bf 00 00 00 00       	mov    $0x0,%edi
  801c24:	eb 11                	jmp    801c37 <strtol+0x49>
  801c26:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  801c2b:	80 f9 2d             	cmp    $0x2d,%cl
  801c2e:	75 07                	jne    801c37 <strtol+0x49>
		s++, neg = 1;
  801c30:	83 c2 01             	add    $0x1,%edx
  801c33:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c37:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801c3c:	75 15                	jne    801c53 <strtol+0x65>
  801c3e:	80 3a 30             	cmpb   $0x30,(%edx)
  801c41:	75 10                	jne    801c53 <strtol+0x65>
  801c43:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801c47:	75 0a                	jne    801c53 <strtol+0x65>
		s += 2, base = 16;
  801c49:	83 c2 02             	add    $0x2,%edx
  801c4c:	b8 10 00 00 00       	mov    $0x10,%eax
  801c51:	eb 10                	jmp    801c63 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  801c53:	85 c0                	test   %eax,%eax
  801c55:	75 0c                	jne    801c63 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801c57:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  801c59:	80 3a 30             	cmpb   $0x30,(%edx)
  801c5c:	75 05                	jne    801c63 <strtol+0x75>
		s++, base = 8;
  801c5e:	83 c2 01             	add    $0x1,%edx
  801c61:	b0 08                	mov    $0x8,%al
		base = 10;
  801c63:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c68:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801c6b:	0f b6 0a             	movzbl (%edx),%ecx
  801c6e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  801c71:	89 f0                	mov    %esi,%eax
  801c73:	3c 09                	cmp    $0x9,%al
  801c75:	77 08                	ja     801c7f <strtol+0x91>
			dig = *s - '0';
  801c77:	0f be c9             	movsbl %cl,%ecx
  801c7a:	83 e9 30             	sub    $0x30,%ecx
  801c7d:	eb 20                	jmp    801c9f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  801c7f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  801c82:	89 f0                	mov    %esi,%eax
  801c84:	3c 19                	cmp    $0x19,%al
  801c86:	77 08                	ja     801c90 <strtol+0xa2>
			dig = *s - 'a' + 10;
  801c88:	0f be c9             	movsbl %cl,%ecx
  801c8b:	83 e9 57             	sub    $0x57,%ecx
  801c8e:	eb 0f                	jmp    801c9f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  801c90:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801c93:	89 f0                	mov    %esi,%eax
  801c95:	3c 19                	cmp    $0x19,%al
  801c97:	77 16                	ja     801caf <strtol+0xc1>
			dig = *s - 'A' + 10;
  801c99:	0f be c9             	movsbl %cl,%ecx
  801c9c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801c9f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  801ca2:	7d 0f                	jge    801cb3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801ca4:	83 c2 01             	add    $0x1,%edx
  801ca7:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801cab:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801cad:	eb bc                	jmp    801c6b <strtol+0x7d>
  801caf:	89 d8                	mov    %ebx,%eax
  801cb1:	eb 02                	jmp    801cb5 <strtol+0xc7>
  801cb3:	89 d8                	mov    %ebx,%eax

	if (endptr)
  801cb5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801cb9:	74 05                	je     801cc0 <strtol+0xd2>
		*endptr = (char *) s;
  801cbb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cbe:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  801cc0:	f7 d8                	neg    %eax
  801cc2:	85 ff                	test   %edi,%edi
  801cc4:	0f 44 c3             	cmove  %ebx,%eax
}
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5f                   	pop    %edi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    

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
  801ce0:	e8 af e6 ff ff       	call   800394 <sys_ipc_recv>
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
  801d45:	e8 15 e4 ff ff       	call   80015f <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801d4a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d51:	8b 45 10             	mov    0x10(%ebp),%eax
  801d54:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d58:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d5c:	89 3c 24             	mov    %edi,(%esp)
  801d5f:	e8 0d e6 ff ff       	call   800371 <sys_ipc_try_send>
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
