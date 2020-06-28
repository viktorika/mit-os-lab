
obj/user/faultnostack：     文件格式 elf32-i386


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
  80002c:	e8 28 00 00 00       	call   800059 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	c7 44 24 04 97 03 80 	movl   $0x800397,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800048:	e8 82 02 00 00       	call   8002cf <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004d:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800054:	00 00 00 
}
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800059:	55                   	push   %ebp
  80005a:	89 e5                	mov    %esp,%ebp
  80005c:	56                   	push   %esi
  80005d:	53                   	push   %ebx
  80005e:	83 ec 10             	sub    $0x10,%esp
  800061:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800064:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800067:	e8 d8 00 00 00       	call   800144 <sys_getenvid>
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 db                	test   %ebx,%ebx
  800080:	7e 07                	jle    800089 <libmain+0x30>
		binaryname = argv[0];
  800082:	8b 06                	mov    (%esi),%eax
  800084:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800089:	89 74 24 04          	mov    %esi,0x4(%esp)
  80008d:	89 1c 24             	mov    %ebx,(%esp)
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 07 00 00 00       	call   8000a1 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ae:	e8 3f 00 00 00       	call   8000f2 <sys_env_destroy>
}
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	57                   	push   %edi
  8000b9:	56                   	push   %esi
  8000ba:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c6:	89 c3                	mov    %eax,%ebx
  8000c8:	89 c7                	mov    %eax,%edi
  8000ca:	89 c6                	mov    %eax,%esi
  8000cc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000de:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e3:	89 d1                	mov    %edx,%ecx
  8000e5:	89 d3                	mov    %edx,%ebx
  8000e7:	89 d7                	mov    %edx,%edi
  8000e9:	89 d6                	mov    %edx,%esi
  8000eb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5f                   	pop    %edi
  8000f0:	5d                   	pop    %ebp
  8000f1:	c3                   	ret    

008000f2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	57                   	push   %edi
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8000fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800100:	b8 03 00 00 00       	mov    $0x3,%eax
  800105:	8b 55 08             	mov    0x8(%ebp),%edx
  800108:	89 cb                	mov    %ecx,%ebx
  80010a:	89 cf                	mov    %ecx,%edi
  80010c:	89 ce                	mov    %ecx,%esi
  80010e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800110:	85 c0                	test   %eax,%eax
  800112:	7e 28                	jle    80013c <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800114:	89 44 24 10          	mov    %eax,0x10(%esp)
  800118:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011f:	00 
  800120:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  800127:	00 
  800128:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012f:	00 
  800130:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  800137:	e8 7f 02 00 00       	call   8003bb <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013c:	83 c4 2c             	add    $0x2c,%esp
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 02 00 00 00       	mov    $0x2,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_yield>:

void
sys_yield(void)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
	asm volatile("int %1\n"
  800169:	ba 00 00 00 00       	mov    $0x0,%edx
  80016e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800173:	89 d1                	mov    %edx,%ecx
  800175:	89 d3                	mov    %edx,%ebx
  800177:	89 d7                	mov    %edx,%edi
  800179:	89 d6                	mov    %edx,%esi
  80017b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017d:	5b                   	pop    %ebx
  80017e:	5e                   	pop    %esi
  80017f:	5f                   	pop    %edi
  800180:	5d                   	pop    %ebp
  800181:	c3                   	ret    

00800182 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	57                   	push   %edi
  800186:	56                   	push   %esi
  800187:	53                   	push   %ebx
  800188:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80018b:	be 00 00 00 00       	mov    $0x0,%esi
  800190:	b8 04 00 00 00       	mov    $0x4,%eax
  800195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800198:	8b 55 08             	mov    0x8(%ebp),%edx
  80019b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019e:	89 f7                	mov    %esi,%edi
  8001a0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	7e 28                	jle    8001ce <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001aa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b1:	00 
  8001b2:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  8001b9:	00 
  8001ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c1:	00 
  8001c2:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  8001c9:	e8 ed 01 00 00       	call   8003bb <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ce:	83 c4 2c             	add    $0x2c,%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	57                   	push   %edi
  8001da:	56                   	push   %esi
  8001db:	53                   	push   %ebx
  8001dc:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8001df:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ed:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f5:	85 c0                	test   %eax,%eax
  8001f7:	7e 28                	jle    800221 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fd:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800204:	00 
  800205:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  80020c:	00 
  80020d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800214:	00 
  800215:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  80021c:	e8 9a 01 00 00       	call   8003bb <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800221:	83 c4 2c             	add    $0x2c,%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    

00800229 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800232:	bb 00 00 00 00       	mov    $0x0,%ebx
  800237:	b8 06 00 00 00       	mov    $0x6,%eax
  80023c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	89 df                	mov    %ebx,%edi
  800244:	89 de                	mov    %ebx,%esi
  800246:	cd 30                	int    $0x30
	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7e 28                	jle    800274 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800250:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800257:	00 
  800258:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  80025f:	00 
  800260:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800267:	00 
  800268:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  80026f:	e8 47 01 00 00       	call   8003bb <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800274:	83 c4 2c             	add    $0x2c,%esp
  800277:	5b                   	pop    %ebx
  800278:	5e                   	pop    %esi
  800279:	5f                   	pop    %edi
  80027a:	5d                   	pop    %ebp
  80027b:	c3                   	ret    

0080027c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	57                   	push   %edi
  800280:	56                   	push   %esi
  800281:	53                   	push   %ebx
  800282:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800285:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028a:	b8 08 00 00 00       	mov    $0x8,%eax
  80028f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800292:	8b 55 08             	mov    0x8(%ebp),%edx
  800295:	89 df                	mov    %ebx,%edi
  800297:	89 de                	mov    %ebx,%esi
  800299:	cd 30                	int    $0x30
	if(check && ret > 0)
  80029b:	85 c0                	test   %eax,%eax
  80029d:	7e 28                	jle    8002c7 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a3:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002aa:	00 
  8002ab:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  8002b2:	00 
  8002b3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ba:	00 
  8002bb:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  8002c2:	e8 f4 00 00 00       	call   8003bb <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c7:	83 c4 2c             	add    $0x2c,%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	57                   	push   %edi
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
  8002d5:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002dd:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e8:	89 df                	mov    %ebx,%edi
  8002ea:	89 de                	mov    %ebx,%esi
  8002ec:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	7e 28                	jle    80031a <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f6:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002fd:	00 
  8002fe:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  800305:	00 
  800306:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80030d:	00 
  80030e:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  800315:	e8 a1 00 00 00       	call   8003bb <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80031a:	83 c4 2c             	add    $0x2c,%esp
  80031d:	5b                   	pop    %ebx
  80031e:	5e                   	pop    %esi
  80031f:	5f                   	pop    %edi
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    

00800322 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	57                   	push   %edi
  800326:	56                   	push   %esi
  800327:	53                   	push   %ebx
	asm volatile("int %1\n"
  800328:	be 00 00 00 00       	mov    $0x0,%esi
  80032d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800332:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800335:	8b 55 08             	mov    0x8(%ebp),%edx
  800338:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80033e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800340:	5b                   	pop    %ebx
  800341:	5e                   	pop    %esi
  800342:	5f                   	pop    %edi
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	57                   	push   %edi
  800349:	56                   	push   %esi
  80034a:	53                   	push   %ebx
  80034b:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80034e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800353:	b8 0c 00 00 00       	mov    $0xc,%eax
  800358:	8b 55 08             	mov    0x8(%ebp),%edx
  80035b:	89 cb                	mov    %ecx,%ebx
  80035d:	89 cf                	mov    %ecx,%edi
  80035f:	89 ce                	mov    %ecx,%esi
  800361:	cd 30                	int    $0x30
	if(check && ret > 0)
  800363:	85 c0                	test   %eax,%eax
  800365:	7e 28                	jle    80038f <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800367:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800372:	00 
  800373:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  80037a:	00 
  80037b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800382:	00 
  800383:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  80038a:	e8 2c 00 00 00       	call   8003bb <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80038f:	83 c4 2c             	add    $0x2c,%esp
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800397:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800398:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80039d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80039f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  8003a2:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  8003a6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  8003ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  8003af:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8003b1:	83 c4 08             	add    $0x8,%esp
	popal
  8003b4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8003b5:	83 c4 04             	add    $0x4,%esp
	popfl
  8003b8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8003b9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8003ba:	c3                   	ret    

008003bb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	56                   	push   %esi
  8003bf:	53                   	push   %ebx
  8003c0:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003c3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003c6:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003cc:	e8 73 fd ff ff       	call   800144 <sys_getenvid>
  8003d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003df:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e7:	c7 04 24 58 12 80 00 	movl   $0x801258,(%esp)
  8003ee:	e8 c1 00 00 00       	call   8004b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fa:	89 04 24             	mov    %eax,(%esp)
  8003fd:	e8 51 00 00 00       	call   800453 <vcprintf>
	cprintf("\n");
  800402:	c7 04 24 7b 12 80 00 	movl   $0x80127b,(%esp)
  800409:	e8 a6 00 00 00       	call   8004b4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80040e:	cc                   	int3   
  80040f:	eb fd                	jmp    80040e <_panic+0x53>

00800411 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	53                   	push   %ebx
  800415:	83 ec 14             	sub    $0x14,%esp
  800418:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80041b:	8b 13                	mov    (%ebx),%edx
  80041d:	8d 42 01             	lea    0x1(%edx),%eax
  800420:	89 03                	mov    %eax,(%ebx)
  800422:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800425:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800429:	3d ff 00 00 00       	cmp    $0xff,%eax
  80042e:	75 19                	jne    800449 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800430:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800437:	00 
  800438:	8d 43 08             	lea    0x8(%ebx),%eax
  80043b:	89 04 24             	mov    %eax,(%esp)
  80043e:	e8 72 fc ff ff       	call   8000b5 <sys_cputs>
		b->idx = 0;
  800443:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800449:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80044d:	83 c4 14             	add    $0x14,%esp
  800450:	5b                   	pop    %ebx
  800451:	5d                   	pop    %ebp
  800452:	c3                   	ret    

00800453 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800453:	55                   	push   %ebp
  800454:	89 e5                	mov    %esp,%ebp
  800456:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80045c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800463:	00 00 00 
	b.cnt = 0;
  800466:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80046d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800470:	8b 45 0c             	mov    0xc(%ebp),%eax
  800473:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800477:	8b 45 08             	mov    0x8(%ebp),%eax
  80047a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80047e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800484:	89 44 24 04          	mov    %eax,0x4(%esp)
  800488:	c7 04 24 11 04 80 00 	movl   $0x800411,(%esp)
  80048f:	e8 b0 01 00 00       	call   800644 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800494:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80049a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	e8 09 fc ff ff       	call   8000b5 <sys_cputs>

	return b.cnt;
}
  8004ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004b2:	c9                   	leave  
  8004b3:	c3                   	ret    

008004b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004b4:	55                   	push   %ebp
  8004b5:	89 e5                	mov    %esp,%ebp
  8004b7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c4:	89 04 24             	mov    %eax,(%esp)
  8004c7:	e8 87 ff ff ff       	call   800453 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004cc:	c9                   	leave  
  8004cd:	c3                   	ret    
  8004ce:	66 90                	xchg   %ax,%ax

008004d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	57                   	push   %edi
  8004d4:	56                   	push   %esi
  8004d5:	53                   	push   %ebx
  8004d6:	83 ec 3c             	sub    $0x3c,%esp
  8004d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004dc:	89 d7                	mov    %edx,%edi
  8004de:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004e7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8004ea:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004f8:	39 f1                	cmp    %esi,%ecx
  8004fa:	72 14                	jb     800510 <printnum+0x40>
  8004fc:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004ff:	76 0f                	jbe    800510 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 70 ff             	lea    -0x1(%eax),%esi
  800507:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80050a:	85 f6                	test   %esi,%esi
  80050c:	7f 60                	jg     80056e <printnum+0x9e>
  80050e:	eb 72                	jmp    800582 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800510:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800513:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800517:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80051a:	8d 51 ff             	lea    -0x1(%ecx),%edx
  80051d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800521:	89 44 24 08          	mov    %eax,0x8(%esp)
  800525:	8b 44 24 08          	mov    0x8(%esp),%eax
  800529:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80052d:	89 c3                	mov    %eax,%ebx
  80052f:	89 d6                	mov    %edx,%esi
  800531:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800534:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800537:	89 54 24 08          	mov    %edx,0x8(%esp)
  80053b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80053f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800542:	89 04 24             	mov    %eax,(%esp)
  800545:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800548:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054c:	e8 2f 0a 00 00       	call   800f80 <__udivdi3>
  800551:	89 d9                	mov    %ebx,%ecx
  800553:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800557:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800562:	89 fa                	mov    %edi,%edx
  800564:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800567:	e8 64 ff ff ff       	call   8004d0 <printnum>
  80056c:	eb 14                	jmp    800582 <printnum+0xb2>
			putch(padc, putdat);
  80056e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800572:	8b 45 18             	mov    0x18(%ebp),%eax
  800575:	89 04 24             	mov    %eax,(%esp)
  800578:	ff d3                	call   *%ebx
		while (--width > 0)
  80057a:	83 ee 01             	sub    $0x1,%esi
  80057d:	75 ef                	jne    80056e <printnum+0x9e>
  80057f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800582:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800586:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80058a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80058d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800590:	89 44 24 08          	mov    %eax,0x8(%esp)
  800594:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800598:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80059b:	89 04 24             	mov    %eax,(%esp)
  80059e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a5:	e8 06 0b 00 00       	call   8010b0 <__umoddi3>
  8005aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ae:	0f be 80 7d 12 80 00 	movsbl 0x80127d(%eax),%eax
  8005b5:	89 04 24             	mov    %eax,(%esp)
  8005b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005bb:	ff d0                	call   *%eax
}
  8005bd:	83 c4 3c             	add    $0x3c,%esp
  8005c0:	5b                   	pop    %ebx
  8005c1:	5e                   	pop    %esi
  8005c2:	5f                   	pop    %edi
  8005c3:	5d                   	pop    %ebp
  8005c4:	c3                   	ret    

008005c5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005c5:	55                   	push   %ebp
  8005c6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005c8:	83 fa 01             	cmp    $0x1,%edx
  8005cb:	7e 0e                	jle    8005db <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005cd:	8b 10                	mov    (%eax),%edx
  8005cf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005d2:	89 08                	mov    %ecx,(%eax)
  8005d4:	8b 02                	mov    (%edx),%eax
  8005d6:	8b 52 04             	mov    0x4(%edx),%edx
  8005d9:	eb 22                	jmp    8005fd <getuint+0x38>
	else if (lflag)
  8005db:	85 d2                	test   %edx,%edx
  8005dd:	74 10                	je     8005ef <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005e4:	89 08                	mov    %ecx,(%eax)
  8005e6:	8b 02                	mov    (%edx),%eax
  8005e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ed:	eb 0e                	jmp    8005fd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005ef:	8b 10                	mov    (%eax),%edx
  8005f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005f4:	89 08                	mov    %ecx,(%eax)
  8005f6:	8b 02                	mov    (%edx),%eax
  8005f8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005fd:	5d                   	pop    %ebp
  8005fe:	c3                   	ret    

008005ff <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005ff:	55                   	push   %ebp
  800600:	89 e5                	mov    %esp,%ebp
  800602:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800605:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800609:	8b 10                	mov    (%eax),%edx
  80060b:	3b 50 04             	cmp    0x4(%eax),%edx
  80060e:	73 0a                	jae    80061a <sprintputch+0x1b>
		*b->buf++ = ch;
  800610:	8d 4a 01             	lea    0x1(%edx),%ecx
  800613:	89 08                	mov    %ecx,(%eax)
  800615:	8b 45 08             	mov    0x8(%ebp),%eax
  800618:	88 02                	mov    %al,(%edx)
}
  80061a:	5d                   	pop    %ebp
  80061b:	c3                   	ret    

0080061c <printfmt>:
{
  80061c:	55                   	push   %ebp
  80061d:	89 e5                	mov    %esp,%ebp
  80061f:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  800622:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800625:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800629:	8b 45 10             	mov    0x10(%ebp),%eax
  80062c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800630:	8b 45 0c             	mov    0xc(%ebp),%eax
  800633:	89 44 24 04          	mov    %eax,0x4(%esp)
  800637:	8b 45 08             	mov    0x8(%ebp),%eax
  80063a:	89 04 24             	mov    %eax,(%esp)
  80063d:	e8 02 00 00 00       	call   800644 <vprintfmt>
}
  800642:	c9                   	leave  
  800643:	c3                   	ret    

00800644 <vprintfmt>:
{
  800644:	55                   	push   %ebp
  800645:	89 e5                	mov    %esp,%ebp
  800647:	57                   	push   %edi
  800648:	56                   	push   %esi
  800649:	53                   	push   %ebx
  80064a:	83 ec 3c             	sub    $0x3c,%esp
  80064d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800650:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800653:	eb 18                	jmp    80066d <vprintfmt+0x29>
			if (ch == '\0')
  800655:	85 c0                	test   %eax,%eax
  800657:	0f 84 c3 03 00 00    	je     800a20 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80065d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800661:	89 04 24             	mov    %eax,(%esp)
  800664:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800667:	89 f3                	mov    %esi,%ebx
  800669:	eb 02                	jmp    80066d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80066d:	8d 73 01             	lea    0x1(%ebx),%esi
  800670:	0f b6 03             	movzbl (%ebx),%eax
  800673:	83 f8 25             	cmp    $0x25,%eax
  800676:	75 dd                	jne    800655 <vprintfmt+0x11>
  800678:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80067c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800683:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80068a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800691:	ba 00 00 00 00       	mov    $0x0,%edx
  800696:	eb 1d                	jmp    8006b5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800698:	89 de                	mov    %ebx,%esi
			padc = '-';
  80069a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80069e:	eb 15                	jmp    8006b5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8006a0:	89 de                	mov    %ebx,%esi
			padc = '0';
  8006a2:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8006a6:	eb 0d                	jmp    8006b5 <vprintfmt+0x71>
				width = precision, precision = -1;
  8006a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ae:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8006b5:	8d 5e 01             	lea    0x1(%esi),%ebx
  8006b8:	0f b6 06             	movzbl (%esi),%eax
  8006bb:	0f b6 c8             	movzbl %al,%ecx
  8006be:	83 e8 23             	sub    $0x23,%eax
  8006c1:	3c 55                	cmp    $0x55,%al
  8006c3:	0f 87 2f 03 00 00    	ja     8009f8 <vprintfmt+0x3b4>
  8006c9:	0f b6 c0             	movzbl %al,%eax
  8006cc:	ff 24 85 40 13 80 00 	jmp    *0x801340(,%eax,4)
				precision = precision * 10 + ch - '0';
  8006d3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8006d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  8006d9:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8006dd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006e0:	83 f9 09             	cmp    $0x9,%ecx
  8006e3:	77 50                	ja     800735 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8006e5:	89 de                	mov    %ebx,%esi
  8006e7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8006ea:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8006ed:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8006f0:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8006f4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006f7:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8006fa:	83 fb 09             	cmp    $0x9,%ebx
  8006fd:	76 eb                	jbe    8006ea <vprintfmt+0xa6>
  8006ff:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800702:	eb 33                	jmp    800737 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8d 48 04             	lea    0x4(%eax),%ecx
  80070a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80070d:	8b 00                	mov    (%eax),%eax
  80070f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800712:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800714:	eb 21                	jmp    800737 <vprintfmt+0xf3>
  800716:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800719:	85 c9                	test   %ecx,%ecx
  80071b:	b8 00 00 00 00       	mov    $0x0,%eax
  800720:	0f 49 c1             	cmovns %ecx,%eax
  800723:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800726:	89 de                	mov    %ebx,%esi
  800728:	eb 8b                	jmp    8006b5 <vprintfmt+0x71>
  80072a:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80072c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800733:	eb 80                	jmp    8006b5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800735:	89 de                	mov    %ebx,%esi
			if (width < 0)
  800737:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80073b:	0f 89 74 ff ff ff    	jns    8006b5 <vprintfmt+0x71>
  800741:	e9 62 ff ff ff       	jmp    8006a8 <vprintfmt+0x64>
			lflag++;
  800746:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800749:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80074b:	e9 65 ff ff ff       	jmp    8006b5 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8d 50 04             	lea    0x4(%eax),%edx
  800756:	89 55 14             	mov    %edx,0x14(%ebp)
  800759:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075d:	8b 00                	mov    (%eax),%eax
  80075f:	89 04 24             	mov    %eax,(%esp)
  800762:	ff 55 08             	call   *0x8(%ebp)
			break;
  800765:	e9 03 ff ff ff       	jmp    80066d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	8d 50 04             	lea    0x4(%eax),%edx
  800770:	89 55 14             	mov    %edx,0x14(%ebp)
  800773:	8b 00                	mov    (%eax),%eax
  800775:	99                   	cltd   
  800776:	31 d0                	xor    %edx,%eax
  800778:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80077a:	83 f8 08             	cmp    $0x8,%eax
  80077d:	7f 0b                	jg     80078a <vprintfmt+0x146>
  80077f:	8b 14 85 a0 14 80 00 	mov    0x8014a0(,%eax,4),%edx
  800786:	85 d2                	test   %edx,%edx
  800788:	75 20                	jne    8007aa <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80078a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078e:	c7 44 24 08 95 12 80 	movl   $0x801295,0x8(%esp)
  800795:	00 
  800796:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	89 04 24             	mov    %eax,(%esp)
  8007a0:	e8 77 fe ff ff       	call   80061c <printfmt>
  8007a5:	e9 c3 fe ff ff       	jmp    80066d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  8007aa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007ae:	c7 44 24 08 9e 12 80 	movl   $0x80129e,0x8(%esp)
  8007b5:	00 
  8007b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	89 04 24             	mov    %eax,(%esp)
  8007c0:	e8 57 fe ff ff       	call   80061c <printfmt>
  8007c5:	e9 a3 fe ff ff       	jmp    80066d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  8007ca:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8007cd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  8007d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d3:	8d 50 04             	lea    0x4(%eax),%edx
  8007d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	ba 8e 12 80 00       	mov    $0x80128e,%edx
  8007e2:	0f 45 d0             	cmovne %eax,%edx
  8007e5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8007e8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8007ec:	74 04                	je     8007f2 <vprintfmt+0x1ae>
  8007ee:	85 f6                	test   %esi,%esi
  8007f0:	7f 19                	jg     80080b <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007f5:	8d 70 01             	lea    0x1(%eax),%esi
  8007f8:	0f b6 10             	movzbl (%eax),%edx
  8007fb:	0f be c2             	movsbl %dl,%eax
  8007fe:	85 c0                	test   %eax,%eax
  800800:	0f 85 95 00 00 00    	jne    80089b <vprintfmt+0x257>
  800806:	e9 85 00 00 00       	jmp    800890 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80080b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80080f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800812:	89 04 24             	mov    %eax,(%esp)
  800815:	e8 b8 02 00 00       	call   800ad2 <strnlen>
  80081a:	29 c6                	sub    %eax,%esi
  80081c:	89 f0                	mov    %esi,%eax
  80081e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800821:	85 f6                	test   %esi,%esi
  800823:	7e cd                	jle    8007f2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800825:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800829:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80082c:	89 c3                	mov    %eax,%ebx
  80082e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800832:	89 34 24             	mov    %esi,(%esp)
  800835:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800838:	83 eb 01             	sub    $0x1,%ebx
  80083b:	75 f1                	jne    80082e <vprintfmt+0x1ea>
  80083d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800840:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800843:	eb ad                	jmp    8007f2 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800845:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800849:	74 1e                	je     800869 <vprintfmt+0x225>
  80084b:	0f be d2             	movsbl %dl,%edx
  80084e:	83 ea 20             	sub    $0x20,%edx
  800851:	83 fa 5e             	cmp    $0x5e,%edx
  800854:	76 13                	jbe    800869 <vprintfmt+0x225>
					putch('?', putdat);
  800856:	8b 45 0c             	mov    0xc(%ebp),%eax
  800859:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800864:	ff 55 08             	call   *0x8(%ebp)
  800867:	eb 0d                	jmp    800876 <vprintfmt+0x232>
					putch(ch, putdat);
  800869:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800870:	89 04 24             	mov    %eax,(%esp)
  800873:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800876:	83 ef 01             	sub    $0x1,%edi
  800879:	83 c6 01             	add    $0x1,%esi
  80087c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800880:	0f be c2             	movsbl %dl,%eax
  800883:	85 c0                	test   %eax,%eax
  800885:	75 20                	jne    8008a7 <vprintfmt+0x263>
  800887:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80088a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80088d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800890:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800894:	7f 25                	jg     8008bb <vprintfmt+0x277>
  800896:	e9 d2 fd ff ff       	jmp    80066d <vprintfmt+0x29>
  80089b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80089e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008a1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8008a4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008a7:	85 db                	test   %ebx,%ebx
  8008a9:	78 9a                	js     800845 <vprintfmt+0x201>
  8008ab:	83 eb 01             	sub    $0x1,%ebx
  8008ae:	79 95                	jns    800845 <vprintfmt+0x201>
  8008b0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8008b3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008b9:	eb d5                	jmp    800890 <vprintfmt+0x24c>
  8008bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8008be:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8008c1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  8008c4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008c8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008cf:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8008d1:	83 eb 01             	sub    $0x1,%ebx
  8008d4:	75 ee                	jne    8008c4 <vprintfmt+0x280>
  8008d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008d9:	e9 8f fd ff ff       	jmp    80066d <vprintfmt+0x29>
	if (lflag >= 2)
  8008de:	83 fa 01             	cmp    $0x1,%edx
  8008e1:	7e 16                	jle    8008f9 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8008e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e6:	8d 50 08             	lea    0x8(%eax),%edx
  8008e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ec:	8b 50 04             	mov    0x4(%eax),%edx
  8008ef:	8b 00                	mov    (%eax),%eax
  8008f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008f7:	eb 32                	jmp    80092b <vprintfmt+0x2e7>
	else if (lflag)
  8008f9:	85 d2                	test   %edx,%edx
  8008fb:	74 18                	je     800915 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8008fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800900:	8d 50 04             	lea    0x4(%eax),%edx
  800903:	89 55 14             	mov    %edx,0x14(%ebp)
  800906:	8b 30                	mov    (%eax),%esi
  800908:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80090b:	89 f0                	mov    %esi,%eax
  80090d:	c1 f8 1f             	sar    $0x1f,%eax
  800910:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800913:	eb 16                	jmp    80092b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  800915:	8b 45 14             	mov    0x14(%ebp),%eax
  800918:	8d 50 04             	lea    0x4(%eax),%edx
  80091b:	89 55 14             	mov    %edx,0x14(%ebp)
  80091e:	8b 30                	mov    (%eax),%esi
  800920:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800923:	89 f0                	mov    %esi,%eax
  800925:	c1 f8 1f             	sar    $0x1f,%eax
  800928:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  80092b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80092e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  800931:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800936:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80093a:	0f 89 80 00 00 00    	jns    8009c0 <vprintfmt+0x37c>
				putch('-', putdat);
  800940:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800944:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80094b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80094e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800951:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800954:	f7 d8                	neg    %eax
  800956:	83 d2 00             	adc    $0x0,%edx
  800959:	f7 da                	neg    %edx
			base = 10;
  80095b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800960:	eb 5e                	jmp    8009c0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800962:	8d 45 14             	lea    0x14(%ebp),%eax
  800965:	e8 5b fc ff ff       	call   8005c5 <getuint>
			base = 10;
  80096a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80096f:	eb 4f                	jmp    8009c0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800971:	8d 45 14             	lea    0x14(%ebp),%eax
  800974:	e8 4c fc ff ff       	call   8005c5 <getuint>
			base = 8;
  800979:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80097e:	eb 40                	jmp    8009c0 <vprintfmt+0x37c>
			putch('0', putdat);
  800980:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800984:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80098b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80098e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800992:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800999:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80099c:	8b 45 14             	mov    0x14(%ebp),%eax
  80099f:	8d 50 04             	lea    0x4(%eax),%edx
  8009a2:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8009a5:	8b 00                	mov    (%eax),%eax
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8009ac:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8009b1:	eb 0d                	jmp    8009c0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  8009b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8009b6:	e8 0a fc ff ff       	call   8005c5 <getuint>
			base = 16;
  8009bb:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8009c0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009c4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8009c8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8009cb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8009cf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009d3:	89 04 24             	mov    %eax,(%esp)
  8009d6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009da:	89 fa                	mov    %edi,%edx
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	e8 ec fa ff ff       	call   8004d0 <printnum>
			break;
  8009e4:	e9 84 fc ff ff       	jmp    80066d <vprintfmt+0x29>
			putch(ch, putdat);
  8009e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ed:	89 0c 24             	mov    %ecx,(%esp)
  8009f0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009f3:	e9 75 fc ff ff       	jmp    80066d <vprintfmt+0x29>
			putch('%', putdat);
  8009f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009fc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a03:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a06:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a0a:	0f 84 5b fc ff ff    	je     80066b <vprintfmt+0x27>
  800a10:	89 f3                	mov    %esi,%ebx
  800a12:	83 eb 01             	sub    $0x1,%ebx
  800a15:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800a19:	75 f7                	jne    800a12 <vprintfmt+0x3ce>
  800a1b:	e9 4d fc ff ff       	jmp    80066d <vprintfmt+0x29>
}
  800a20:	83 c4 3c             	add    $0x3c,%esp
  800a23:	5b                   	pop    %ebx
  800a24:	5e                   	pop    %esi
  800a25:	5f                   	pop    %edi
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	83 ec 28             	sub    $0x28,%esp
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a31:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a34:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a37:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a3b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a45:	85 c0                	test   %eax,%eax
  800a47:	74 30                	je     800a79 <vsnprintf+0x51>
  800a49:	85 d2                	test   %edx,%edx
  800a4b:	7e 2c                	jle    800a79 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a4d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a54:	8b 45 10             	mov    0x10(%ebp),%eax
  800a57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a62:	c7 04 24 ff 05 80 00 	movl   $0x8005ff,(%esp)
  800a69:	e8 d6 fb ff ff       	call   800644 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a71:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a77:	eb 05                	jmp    800a7e <vsnprintf+0x56>
		return -E_INVAL;
  800a79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a86:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a90:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	89 04 24             	mov    %eax,(%esp)
  800aa1:	e8 82 ff ff ff       	call   800a28 <vsnprintf>
	va_end(ap);

	return rc;
}
  800aa6:	c9                   	leave  
  800aa7:	c3                   	ret    
  800aa8:	66 90                	xchg   %ax,%ax
  800aaa:	66 90                	xchg   %ax,%ax
  800aac:	66 90                	xchg   %ax,%ax
  800aae:	66 90                	xchg   %ax,%ax

00800ab0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ab6:	80 3a 00             	cmpb   $0x0,(%edx)
  800ab9:	74 10                	je     800acb <strlen+0x1b>
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ac0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800ac3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ac7:	75 f7                	jne    800ac0 <strlen+0x10>
  800ac9:	eb 05                	jmp    800ad0 <strlen+0x20>
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	53                   	push   %ebx
  800ad6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ad9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800adc:	85 c9                	test   %ecx,%ecx
  800ade:	74 1c                	je     800afc <strnlen+0x2a>
  800ae0:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ae3:	74 1e                	je     800b03 <strnlen+0x31>
  800ae5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800aea:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aec:	39 ca                	cmp    %ecx,%edx
  800aee:	74 18                	je     800b08 <strnlen+0x36>
  800af0:	83 c2 01             	add    $0x1,%edx
  800af3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800af8:	75 f0                	jne    800aea <strnlen+0x18>
  800afa:	eb 0c                	jmp    800b08 <strnlen+0x36>
  800afc:	b8 00 00 00 00       	mov    $0x0,%eax
  800b01:	eb 05                	jmp    800b08 <strnlen+0x36>
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800b08:	5b                   	pop    %ebx
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	53                   	push   %ebx
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b15:	89 c2                	mov    %eax,%edx
  800b17:	83 c2 01             	add    $0x1,%edx
  800b1a:	83 c1 01             	add    $0x1,%ecx
  800b1d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b21:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b24:	84 db                	test   %bl,%bl
  800b26:	75 ef                	jne    800b17 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b28:	5b                   	pop    %ebx
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	53                   	push   %ebx
  800b2f:	83 ec 08             	sub    $0x8,%esp
  800b32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b35:	89 1c 24             	mov    %ebx,(%esp)
  800b38:	e8 73 ff ff ff       	call   800ab0 <strlen>
	strcpy(dst + len, src);
  800b3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b40:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b44:	01 d8                	add    %ebx,%eax
  800b46:	89 04 24             	mov    %eax,(%esp)
  800b49:	e8 bd ff ff ff       	call   800b0b <strcpy>
	return dst;
}
  800b4e:	89 d8                	mov    %ebx,%eax
  800b50:	83 c4 08             	add    $0x8,%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	8b 75 08             	mov    0x8(%ebp),%esi
  800b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b64:	85 db                	test   %ebx,%ebx
  800b66:	74 17                	je     800b7f <strncpy+0x29>
  800b68:	01 f3                	add    %esi,%ebx
  800b6a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800b6c:	83 c1 01             	add    $0x1,%ecx
  800b6f:	0f b6 02             	movzbl (%edx),%eax
  800b72:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b75:	80 3a 01             	cmpb   $0x1,(%edx)
  800b78:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800b7b:	39 d9                	cmp    %ebx,%ecx
  800b7d:	75 ed                	jne    800b6c <strncpy+0x16>
	}
	return ret;
}
  800b7f:	89 f0                	mov    %esi,%eax
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b91:	8b 75 10             	mov    0x10(%ebp),%esi
  800b94:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b96:	85 f6                	test   %esi,%esi
  800b98:	74 34                	je     800bce <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800b9a:	83 fe 01             	cmp    $0x1,%esi
  800b9d:	74 26                	je     800bc5 <strlcpy+0x40>
  800b9f:	0f b6 0b             	movzbl (%ebx),%ecx
  800ba2:	84 c9                	test   %cl,%cl
  800ba4:	74 23                	je     800bc9 <strlcpy+0x44>
  800ba6:	83 ee 02             	sub    $0x2,%esi
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  800bae:	83 c0 01             	add    $0x1,%eax
  800bb1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800bb4:	39 f2                	cmp    %esi,%edx
  800bb6:	74 13                	je     800bcb <strlcpy+0x46>
  800bb8:	83 c2 01             	add    $0x1,%edx
  800bbb:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bbf:	84 c9                	test   %cl,%cl
  800bc1:	75 eb                	jne    800bae <strlcpy+0x29>
  800bc3:	eb 06                	jmp    800bcb <strlcpy+0x46>
  800bc5:	89 f8                	mov    %edi,%eax
  800bc7:	eb 02                	jmp    800bcb <strlcpy+0x46>
  800bc9:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  800bcb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bce:	29 f8                	sub    %edi,%eax
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bde:	0f b6 01             	movzbl (%ecx),%eax
  800be1:	84 c0                	test   %al,%al
  800be3:	74 15                	je     800bfa <strcmp+0x25>
  800be5:	3a 02                	cmp    (%edx),%al
  800be7:	75 11                	jne    800bfa <strcmp+0x25>
		p++, q++;
  800be9:	83 c1 01             	add    $0x1,%ecx
  800bec:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800bef:	0f b6 01             	movzbl (%ecx),%eax
  800bf2:	84 c0                	test   %al,%al
  800bf4:	74 04                	je     800bfa <strcmp+0x25>
  800bf6:	3a 02                	cmp    (%edx),%al
  800bf8:	74 ef                	je     800be9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bfa:	0f b6 c0             	movzbl %al,%eax
  800bfd:	0f b6 12             	movzbl (%edx),%edx
  800c00:	29 d0                	sub    %edx,%eax
}
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800c12:	85 f6                	test   %esi,%esi
  800c14:	74 29                	je     800c3f <strncmp+0x3b>
  800c16:	0f b6 03             	movzbl (%ebx),%eax
  800c19:	84 c0                	test   %al,%al
  800c1b:	74 30                	je     800c4d <strncmp+0x49>
  800c1d:	3a 02                	cmp    (%edx),%al
  800c1f:	75 2c                	jne    800c4d <strncmp+0x49>
  800c21:	8d 43 01             	lea    0x1(%ebx),%eax
  800c24:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800c26:	89 c3                	mov    %eax,%ebx
  800c28:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c2b:	39 f0                	cmp    %esi,%eax
  800c2d:	74 17                	je     800c46 <strncmp+0x42>
  800c2f:	0f b6 08             	movzbl (%eax),%ecx
  800c32:	84 c9                	test   %cl,%cl
  800c34:	74 17                	je     800c4d <strncmp+0x49>
  800c36:	83 c0 01             	add    $0x1,%eax
  800c39:	3a 0a                	cmp    (%edx),%cl
  800c3b:	74 e9                	je     800c26 <strncmp+0x22>
  800c3d:	eb 0e                	jmp    800c4d <strncmp+0x49>
	if (n == 0)
		return 0;
  800c3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c44:	eb 0f                	jmp    800c55 <strncmp+0x51>
  800c46:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4b:	eb 08                	jmp    800c55 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c4d:	0f b6 03             	movzbl (%ebx),%eax
  800c50:	0f b6 12             	movzbl (%edx),%edx
  800c53:	29 d0                	sub    %edx,%eax
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	53                   	push   %ebx
  800c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c60:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c63:	0f b6 18             	movzbl (%eax),%ebx
  800c66:	84 db                	test   %bl,%bl
  800c68:	74 1d                	je     800c87 <strchr+0x2e>
  800c6a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800c6c:	38 d3                	cmp    %dl,%bl
  800c6e:	75 06                	jne    800c76 <strchr+0x1d>
  800c70:	eb 1a                	jmp    800c8c <strchr+0x33>
  800c72:	38 ca                	cmp    %cl,%dl
  800c74:	74 16                	je     800c8c <strchr+0x33>
	for (; *s; s++)
  800c76:	83 c0 01             	add    $0x1,%eax
  800c79:	0f b6 10             	movzbl (%eax),%edx
  800c7c:	84 d2                	test   %dl,%dl
  800c7e:	75 f2                	jne    800c72 <strchr+0x19>
			return (char *) s;
	return 0;
  800c80:	b8 00 00 00 00       	mov    $0x0,%eax
  800c85:	eb 05                	jmp    800c8c <strchr+0x33>
  800c87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c8c:	5b                   	pop    %ebx
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	53                   	push   %ebx
  800c93:	8b 45 08             	mov    0x8(%ebp),%eax
  800c96:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c99:	0f b6 18             	movzbl (%eax),%ebx
  800c9c:	84 db                	test   %bl,%bl
  800c9e:	74 16                	je     800cb6 <strfind+0x27>
  800ca0:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800ca2:	38 d3                	cmp    %dl,%bl
  800ca4:	75 06                	jne    800cac <strfind+0x1d>
  800ca6:	eb 0e                	jmp    800cb6 <strfind+0x27>
  800ca8:	38 ca                	cmp    %cl,%dl
  800caa:	74 0a                	je     800cb6 <strfind+0x27>
	for (; *s; s++)
  800cac:	83 c0 01             	add    $0x1,%eax
  800caf:	0f b6 10             	movzbl (%eax),%edx
  800cb2:	84 d2                	test   %dl,%dl
  800cb4:	75 f2                	jne    800ca8 <strfind+0x19>
			break;
	return (char *) s;
}
  800cb6:	5b                   	pop    %ebx
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
  800cbf:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cc2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cc5:	85 c9                	test   %ecx,%ecx
  800cc7:	74 36                	je     800cff <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cc9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ccf:	75 28                	jne    800cf9 <memset+0x40>
  800cd1:	f6 c1 03             	test   $0x3,%cl
  800cd4:	75 23                	jne    800cf9 <memset+0x40>
		c &= 0xFF;
  800cd6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cda:	89 d3                	mov    %edx,%ebx
  800cdc:	c1 e3 08             	shl    $0x8,%ebx
  800cdf:	89 d6                	mov    %edx,%esi
  800ce1:	c1 e6 18             	shl    $0x18,%esi
  800ce4:	89 d0                	mov    %edx,%eax
  800ce6:	c1 e0 10             	shl    $0x10,%eax
  800ce9:	09 f0                	or     %esi,%eax
  800ceb:	09 c2                	or     %eax,%edx
  800ced:	89 d0                	mov    %edx,%eax
  800cef:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cf1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800cf4:	fc                   	cld    
  800cf5:	f3 ab                	rep stos %eax,%es:(%edi)
  800cf7:	eb 06                	jmp    800cff <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cf9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfc:	fc                   	cld    
  800cfd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cff:	89 f8                	mov    %edi,%eax
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d11:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d14:	39 c6                	cmp    %eax,%esi
  800d16:	73 35                	jae    800d4d <memmove+0x47>
  800d18:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d1b:	39 d0                	cmp    %edx,%eax
  800d1d:	73 2e                	jae    800d4d <memmove+0x47>
		s += n;
		d += n;
  800d1f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800d22:	89 d6                	mov    %edx,%esi
  800d24:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d26:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d2c:	75 13                	jne    800d41 <memmove+0x3b>
  800d2e:	f6 c1 03             	test   $0x3,%cl
  800d31:	75 0e                	jne    800d41 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d33:	83 ef 04             	sub    $0x4,%edi
  800d36:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d39:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d3c:	fd                   	std    
  800d3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d3f:	eb 09                	jmp    800d4a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d41:	83 ef 01             	sub    $0x1,%edi
  800d44:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d47:	fd                   	std    
  800d48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d4a:	fc                   	cld    
  800d4b:	eb 1d                	jmp    800d6a <memmove+0x64>
  800d4d:	89 f2                	mov    %esi,%edx
  800d4f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d51:	f6 c2 03             	test   $0x3,%dl
  800d54:	75 0f                	jne    800d65 <memmove+0x5f>
  800d56:	f6 c1 03             	test   $0x3,%cl
  800d59:	75 0a                	jne    800d65 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d5b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d5e:	89 c7                	mov    %eax,%edi
  800d60:	fc                   	cld    
  800d61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d63:	eb 05                	jmp    800d6a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800d65:	89 c7                	mov    %eax,%edi
  800d67:	fc                   	cld    
  800d68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d74:	8b 45 10             	mov    0x10(%ebp),%eax
  800d77:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d82:	8b 45 08             	mov    0x8(%ebp),%eax
  800d85:	89 04 24             	mov    %eax,(%esp)
  800d88:	e8 79 ff ff ff       	call   800d06 <memmove>
}
  800d8d:	c9                   	leave  
  800d8e:	c3                   	ret    

00800d8f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	57                   	push   %edi
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
  800d95:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d98:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d9b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d9e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800da1:	85 c0                	test   %eax,%eax
  800da3:	74 36                	je     800ddb <memcmp+0x4c>
		if (*s1 != *s2)
  800da5:	0f b6 03             	movzbl (%ebx),%eax
  800da8:	0f b6 0e             	movzbl (%esi),%ecx
  800dab:	ba 00 00 00 00       	mov    $0x0,%edx
  800db0:	38 c8                	cmp    %cl,%al
  800db2:	74 1c                	je     800dd0 <memcmp+0x41>
  800db4:	eb 10                	jmp    800dc6 <memcmp+0x37>
  800db6:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800dbb:	83 c2 01             	add    $0x1,%edx
  800dbe:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800dc2:	38 c8                	cmp    %cl,%al
  800dc4:	74 0a                	je     800dd0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800dc6:	0f b6 c0             	movzbl %al,%eax
  800dc9:	0f b6 c9             	movzbl %cl,%ecx
  800dcc:	29 c8                	sub    %ecx,%eax
  800dce:	eb 10                	jmp    800de0 <memcmp+0x51>
	while (n-- > 0) {
  800dd0:	39 fa                	cmp    %edi,%edx
  800dd2:	75 e2                	jne    800db6 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800dd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd9:	eb 05                	jmp    800de0 <memcmp+0x51>
  800ddb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	53                   	push   %ebx
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800def:	89 c2                	mov    %eax,%edx
  800df1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df4:	39 d0                	cmp    %edx,%eax
  800df6:	73 13                	jae    800e0b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800df8:	89 d9                	mov    %ebx,%ecx
  800dfa:	38 18                	cmp    %bl,(%eax)
  800dfc:	75 06                	jne    800e04 <memfind+0x1f>
  800dfe:	eb 0b                	jmp    800e0b <memfind+0x26>
  800e00:	38 08                	cmp    %cl,(%eax)
  800e02:	74 07                	je     800e0b <memfind+0x26>
	for (; s < ends; s++)
  800e04:	83 c0 01             	add    $0x1,%eax
  800e07:	39 d0                	cmp    %edx,%eax
  800e09:	75 f5                	jne    800e00 <memfind+0x1b>
			break;
	return (void *) s;
}
  800e0b:	5b                   	pop    %ebx
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e1a:	0f b6 0a             	movzbl (%edx),%ecx
  800e1d:	80 f9 09             	cmp    $0x9,%cl
  800e20:	74 05                	je     800e27 <strtol+0x19>
  800e22:	80 f9 20             	cmp    $0x20,%cl
  800e25:	75 10                	jne    800e37 <strtol+0x29>
		s++;
  800e27:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800e2a:	0f b6 0a             	movzbl (%edx),%ecx
  800e2d:	80 f9 09             	cmp    $0x9,%cl
  800e30:	74 f5                	je     800e27 <strtol+0x19>
  800e32:	80 f9 20             	cmp    $0x20,%cl
  800e35:	74 f0                	je     800e27 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800e37:	80 f9 2b             	cmp    $0x2b,%cl
  800e3a:	75 0a                	jne    800e46 <strtol+0x38>
		s++;
  800e3c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800e3f:	bf 00 00 00 00       	mov    $0x0,%edi
  800e44:	eb 11                	jmp    800e57 <strtol+0x49>
  800e46:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800e4b:	80 f9 2d             	cmp    $0x2d,%cl
  800e4e:	75 07                	jne    800e57 <strtol+0x49>
		s++, neg = 1;
  800e50:	83 c2 01             	add    $0x1,%edx
  800e53:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e57:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800e5c:	75 15                	jne    800e73 <strtol+0x65>
  800e5e:	80 3a 30             	cmpb   $0x30,(%edx)
  800e61:	75 10                	jne    800e73 <strtol+0x65>
  800e63:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e67:	75 0a                	jne    800e73 <strtol+0x65>
		s += 2, base = 16;
  800e69:	83 c2 02             	add    $0x2,%edx
  800e6c:	b8 10 00 00 00       	mov    $0x10,%eax
  800e71:	eb 10                	jmp    800e83 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800e73:	85 c0                	test   %eax,%eax
  800e75:	75 0c                	jne    800e83 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e77:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800e79:	80 3a 30             	cmpb   $0x30,(%edx)
  800e7c:	75 05                	jne    800e83 <strtol+0x75>
		s++, base = 8;
  800e7e:	83 c2 01             	add    $0x1,%edx
  800e81:	b0 08                	mov    $0x8,%al
		base = 10;
  800e83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e88:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e8b:	0f b6 0a             	movzbl (%edx),%ecx
  800e8e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800e91:	89 f0                	mov    %esi,%eax
  800e93:	3c 09                	cmp    $0x9,%al
  800e95:	77 08                	ja     800e9f <strtol+0x91>
			dig = *s - '0';
  800e97:	0f be c9             	movsbl %cl,%ecx
  800e9a:	83 e9 30             	sub    $0x30,%ecx
  800e9d:	eb 20                	jmp    800ebf <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800e9f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800ea2:	89 f0                	mov    %esi,%eax
  800ea4:	3c 19                	cmp    $0x19,%al
  800ea6:	77 08                	ja     800eb0 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800ea8:	0f be c9             	movsbl %cl,%ecx
  800eab:	83 e9 57             	sub    $0x57,%ecx
  800eae:	eb 0f                	jmp    800ebf <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800eb0:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800eb3:	89 f0                	mov    %esi,%eax
  800eb5:	3c 19                	cmp    $0x19,%al
  800eb7:	77 16                	ja     800ecf <strtol+0xc1>
			dig = *s - 'A' + 10;
  800eb9:	0f be c9             	movsbl %cl,%ecx
  800ebc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ebf:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800ec2:	7d 0f                	jge    800ed3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ec4:	83 c2 01             	add    $0x1,%edx
  800ec7:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ecb:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ecd:	eb bc                	jmp    800e8b <strtol+0x7d>
  800ecf:	89 d8                	mov    %ebx,%eax
  800ed1:	eb 02                	jmp    800ed5 <strtol+0xc7>
  800ed3:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800ed5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ed9:	74 05                	je     800ee0 <strtol+0xd2>
		*endptr = (char *) s;
  800edb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ede:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800ee0:	f7 d8                	neg    %eax
  800ee2:	85 ff                	test   %edi,%edi
  800ee4:	0f 44 c3             	cmove  %ebx,%eax
}
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800ef2:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800ef9:	75 70                	jne    800f6b <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  800efb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f02:	00 
  800f03:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f0a:	ee 
  800f0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f12:	e8 6b f2 ff ff       	call   800182 <sys_page_alloc>
  800f17:	85 c0                	test   %eax,%eax
  800f19:	79 1c                	jns    800f37 <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  800f1b:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800f22:	00 
  800f23:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f2a:	00 
  800f2b:	c7 04 24 28 15 80 00 	movl   $0x801528,(%esp)
  800f32:	e8 84 f4 ff ff       	call   8003bb <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800f37:	c7 44 24 04 97 03 80 	movl   $0x800397,0x4(%esp)
  800f3e:	00 
  800f3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f46:	e8 84 f3 ff ff       	call   8002cf <sys_env_set_pgfault_upcall>
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	79 1c                	jns    800f6b <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  800f4f:	c7 44 24 08 f0 14 80 	movl   $0x8014f0,0x8(%esp)
  800f56:	00 
  800f57:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800f5e:	00 
  800f5f:	c7 04 24 28 15 80 00 	movl   $0x801528,(%esp)
  800f66:	e8 50 f4 ff ff       	call   8003bb <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800f73:	c9                   	leave  
  800f74:	c3                   	ret    
  800f75:	66 90                	xchg   %ax,%ax
  800f77:	66 90                	xchg   %ax,%ax
  800f79:	66 90                	xchg   %ax,%ax
  800f7b:	66 90                	xchg   %ax,%ax
  800f7d:	66 90                	xchg   %ax,%ax
  800f7f:	90                   	nop

00800f80 <__udivdi3>:
  800f80:	55                   	push   %ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	83 ec 0c             	sub    $0xc,%esp
  800f86:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f8a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800f8e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800f92:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f96:	85 c0                	test   %eax,%eax
  800f98:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f9c:	89 ea                	mov    %ebp,%edx
  800f9e:	89 0c 24             	mov    %ecx,(%esp)
  800fa1:	75 2d                	jne    800fd0 <__udivdi3+0x50>
  800fa3:	39 e9                	cmp    %ebp,%ecx
  800fa5:	77 61                	ja     801008 <__udivdi3+0x88>
  800fa7:	85 c9                	test   %ecx,%ecx
  800fa9:	89 ce                	mov    %ecx,%esi
  800fab:	75 0b                	jne    800fb8 <__udivdi3+0x38>
  800fad:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb2:	31 d2                	xor    %edx,%edx
  800fb4:	f7 f1                	div    %ecx
  800fb6:	89 c6                	mov    %eax,%esi
  800fb8:	31 d2                	xor    %edx,%edx
  800fba:	89 e8                	mov    %ebp,%eax
  800fbc:	f7 f6                	div    %esi
  800fbe:	89 c5                	mov    %eax,%ebp
  800fc0:	89 f8                	mov    %edi,%eax
  800fc2:	f7 f6                	div    %esi
  800fc4:	89 ea                	mov    %ebp,%edx
  800fc6:	83 c4 0c             	add    $0xc,%esp
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    
  800fcd:	8d 76 00             	lea    0x0(%esi),%esi
  800fd0:	39 e8                	cmp    %ebp,%eax
  800fd2:	77 24                	ja     800ff8 <__udivdi3+0x78>
  800fd4:	0f bd e8             	bsr    %eax,%ebp
  800fd7:	83 f5 1f             	xor    $0x1f,%ebp
  800fda:	75 3c                	jne    801018 <__udivdi3+0x98>
  800fdc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fe0:	39 34 24             	cmp    %esi,(%esp)
  800fe3:	0f 86 9f 00 00 00    	jbe    801088 <__udivdi3+0x108>
  800fe9:	39 d0                	cmp    %edx,%eax
  800feb:	0f 82 97 00 00 00    	jb     801088 <__udivdi3+0x108>
  800ff1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ff8:	31 d2                	xor    %edx,%edx
  800ffa:	31 c0                	xor    %eax,%eax
  800ffc:	83 c4 0c             	add    $0xc,%esp
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    
  801003:	90                   	nop
  801004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801008:	89 f8                	mov    %edi,%eax
  80100a:	f7 f1                	div    %ecx
  80100c:	31 d2                	xor    %edx,%edx
  80100e:	83 c4 0c             	add    $0xc,%esp
  801011:	5e                   	pop    %esi
  801012:	5f                   	pop    %edi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    
  801015:	8d 76 00             	lea    0x0(%esi),%esi
  801018:	89 e9                	mov    %ebp,%ecx
  80101a:	8b 3c 24             	mov    (%esp),%edi
  80101d:	d3 e0                	shl    %cl,%eax
  80101f:	89 c6                	mov    %eax,%esi
  801021:	b8 20 00 00 00       	mov    $0x20,%eax
  801026:	29 e8                	sub    %ebp,%eax
  801028:	89 c1                	mov    %eax,%ecx
  80102a:	d3 ef                	shr    %cl,%edi
  80102c:	89 e9                	mov    %ebp,%ecx
  80102e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801032:	8b 3c 24             	mov    (%esp),%edi
  801035:	09 74 24 08          	or     %esi,0x8(%esp)
  801039:	89 d6                	mov    %edx,%esi
  80103b:	d3 e7                	shl    %cl,%edi
  80103d:	89 c1                	mov    %eax,%ecx
  80103f:	89 3c 24             	mov    %edi,(%esp)
  801042:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801046:	d3 ee                	shr    %cl,%esi
  801048:	89 e9                	mov    %ebp,%ecx
  80104a:	d3 e2                	shl    %cl,%edx
  80104c:	89 c1                	mov    %eax,%ecx
  80104e:	d3 ef                	shr    %cl,%edi
  801050:	09 d7                	or     %edx,%edi
  801052:	89 f2                	mov    %esi,%edx
  801054:	89 f8                	mov    %edi,%eax
  801056:	f7 74 24 08          	divl   0x8(%esp)
  80105a:	89 d6                	mov    %edx,%esi
  80105c:	89 c7                	mov    %eax,%edi
  80105e:	f7 24 24             	mull   (%esp)
  801061:	39 d6                	cmp    %edx,%esi
  801063:	89 14 24             	mov    %edx,(%esp)
  801066:	72 30                	jb     801098 <__udivdi3+0x118>
  801068:	8b 54 24 04          	mov    0x4(%esp),%edx
  80106c:	89 e9                	mov    %ebp,%ecx
  80106e:	d3 e2                	shl    %cl,%edx
  801070:	39 c2                	cmp    %eax,%edx
  801072:	73 05                	jae    801079 <__udivdi3+0xf9>
  801074:	3b 34 24             	cmp    (%esp),%esi
  801077:	74 1f                	je     801098 <__udivdi3+0x118>
  801079:	89 f8                	mov    %edi,%eax
  80107b:	31 d2                	xor    %edx,%edx
  80107d:	e9 7a ff ff ff       	jmp    800ffc <__udivdi3+0x7c>
  801082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801088:	31 d2                	xor    %edx,%edx
  80108a:	b8 01 00 00 00       	mov    $0x1,%eax
  80108f:	e9 68 ff ff ff       	jmp    800ffc <__udivdi3+0x7c>
  801094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801098:	8d 47 ff             	lea    -0x1(%edi),%eax
  80109b:	31 d2                	xor    %edx,%edx
  80109d:	83 c4 0c             	add    $0xc,%esp
  8010a0:	5e                   	pop    %esi
  8010a1:	5f                   	pop    %edi
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    
  8010a4:	66 90                	xchg   %ax,%ax
  8010a6:	66 90                	xchg   %ax,%ax
  8010a8:	66 90                	xchg   %ax,%ax
  8010aa:	66 90                	xchg   %ax,%ax
  8010ac:	66 90                	xchg   %ax,%ax
  8010ae:	66 90                	xchg   %ax,%ax

008010b0 <__umoddi3>:
  8010b0:	55                   	push   %ebp
  8010b1:	57                   	push   %edi
  8010b2:	56                   	push   %esi
  8010b3:	83 ec 14             	sub    $0x14,%esp
  8010b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8010ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8010be:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8010c2:	89 c7                	mov    %eax,%edi
  8010c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8010cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010d0:	89 34 24             	mov    %esi,(%esp)
  8010d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	89 c2                	mov    %eax,%edx
  8010db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010df:	75 17                	jne    8010f8 <__umoddi3+0x48>
  8010e1:	39 fe                	cmp    %edi,%esi
  8010e3:	76 4b                	jbe    801130 <__umoddi3+0x80>
  8010e5:	89 c8                	mov    %ecx,%eax
  8010e7:	89 fa                	mov    %edi,%edx
  8010e9:	f7 f6                	div    %esi
  8010eb:	89 d0                	mov    %edx,%eax
  8010ed:	31 d2                	xor    %edx,%edx
  8010ef:	83 c4 14             	add    $0x14,%esp
  8010f2:	5e                   	pop    %esi
  8010f3:	5f                   	pop    %edi
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    
  8010f6:	66 90                	xchg   %ax,%ax
  8010f8:	39 f8                	cmp    %edi,%eax
  8010fa:	77 54                	ja     801150 <__umoddi3+0xa0>
  8010fc:	0f bd e8             	bsr    %eax,%ebp
  8010ff:	83 f5 1f             	xor    $0x1f,%ebp
  801102:	75 5c                	jne    801160 <__umoddi3+0xb0>
  801104:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801108:	39 3c 24             	cmp    %edi,(%esp)
  80110b:	0f 87 e7 00 00 00    	ja     8011f8 <__umoddi3+0x148>
  801111:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801115:	29 f1                	sub    %esi,%ecx
  801117:	19 c7                	sbb    %eax,%edi
  801119:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80111d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801121:	8b 44 24 08          	mov    0x8(%esp),%eax
  801125:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801129:	83 c4 14             	add    $0x14,%esp
  80112c:	5e                   	pop    %esi
  80112d:	5f                   	pop    %edi
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    
  801130:	85 f6                	test   %esi,%esi
  801132:	89 f5                	mov    %esi,%ebp
  801134:	75 0b                	jne    801141 <__umoddi3+0x91>
  801136:	b8 01 00 00 00       	mov    $0x1,%eax
  80113b:	31 d2                	xor    %edx,%edx
  80113d:	f7 f6                	div    %esi
  80113f:	89 c5                	mov    %eax,%ebp
  801141:	8b 44 24 04          	mov    0x4(%esp),%eax
  801145:	31 d2                	xor    %edx,%edx
  801147:	f7 f5                	div    %ebp
  801149:	89 c8                	mov    %ecx,%eax
  80114b:	f7 f5                	div    %ebp
  80114d:	eb 9c                	jmp    8010eb <__umoddi3+0x3b>
  80114f:	90                   	nop
  801150:	89 c8                	mov    %ecx,%eax
  801152:	89 fa                	mov    %edi,%edx
  801154:	83 c4 14             	add    $0x14,%esp
  801157:	5e                   	pop    %esi
  801158:	5f                   	pop    %edi
  801159:	5d                   	pop    %ebp
  80115a:	c3                   	ret    
  80115b:	90                   	nop
  80115c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801160:	8b 04 24             	mov    (%esp),%eax
  801163:	be 20 00 00 00       	mov    $0x20,%esi
  801168:	89 e9                	mov    %ebp,%ecx
  80116a:	29 ee                	sub    %ebp,%esi
  80116c:	d3 e2                	shl    %cl,%edx
  80116e:	89 f1                	mov    %esi,%ecx
  801170:	d3 e8                	shr    %cl,%eax
  801172:	89 e9                	mov    %ebp,%ecx
  801174:	89 44 24 04          	mov    %eax,0x4(%esp)
  801178:	8b 04 24             	mov    (%esp),%eax
  80117b:	09 54 24 04          	or     %edx,0x4(%esp)
  80117f:	89 fa                	mov    %edi,%edx
  801181:	d3 e0                	shl    %cl,%eax
  801183:	89 f1                	mov    %esi,%ecx
  801185:	89 44 24 08          	mov    %eax,0x8(%esp)
  801189:	8b 44 24 10          	mov    0x10(%esp),%eax
  80118d:	d3 ea                	shr    %cl,%edx
  80118f:	89 e9                	mov    %ebp,%ecx
  801191:	d3 e7                	shl    %cl,%edi
  801193:	89 f1                	mov    %esi,%ecx
  801195:	d3 e8                	shr    %cl,%eax
  801197:	89 e9                	mov    %ebp,%ecx
  801199:	09 f8                	or     %edi,%eax
  80119b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80119f:	f7 74 24 04          	divl   0x4(%esp)
  8011a3:	d3 e7                	shl    %cl,%edi
  8011a5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011a9:	89 d7                	mov    %edx,%edi
  8011ab:	f7 64 24 08          	mull   0x8(%esp)
  8011af:	39 d7                	cmp    %edx,%edi
  8011b1:	89 c1                	mov    %eax,%ecx
  8011b3:	89 14 24             	mov    %edx,(%esp)
  8011b6:	72 2c                	jb     8011e4 <__umoddi3+0x134>
  8011b8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8011bc:	72 22                	jb     8011e0 <__umoddi3+0x130>
  8011be:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8011c2:	29 c8                	sub    %ecx,%eax
  8011c4:	19 d7                	sbb    %edx,%edi
  8011c6:	89 e9                	mov    %ebp,%ecx
  8011c8:	89 fa                	mov    %edi,%edx
  8011ca:	d3 e8                	shr    %cl,%eax
  8011cc:	89 f1                	mov    %esi,%ecx
  8011ce:	d3 e2                	shl    %cl,%edx
  8011d0:	89 e9                	mov    %ebp,%ecx
  8011d2:	d3 ef                	shr    %cl,%edi
  8011d4:	09 d0                	or     %edx,%eax
  8011d6:	89 fa                	mov    %edi,%edx
  8011d8:	83 c4 14             	add    $0x14,%esp
  8011db:	5e                   	pop    %esi
  8011dc:	5f                   	pop    %edi
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    
  8011df:	90                   	nop
  8011e0:	39 d7                	cmp    %edx,%edi
  8011e2:	75 da                	jne    8011be <__umoddi3+0x10e>
  8011e4:	8b 14 24             	mov    (%esp),%edx
  8011e7:	89 c1                	mov    %eax,%ecx
  8011e9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8011ed:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8011f1:	eb cb                	jmp    8011be <__umoddi3+0x10e>
  8011f3:	90                   	nop
  8011f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8011fc:	0f 82 0f ff ff ff    	jb     801111 <__umoddi3+0x61>
  801202:	e9 1a ff ff ff       	jmp    801121 <__umoddi3+0x71>