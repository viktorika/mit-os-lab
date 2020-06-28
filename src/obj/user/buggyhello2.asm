
obj/user/buggyhello2：     文件格式 elf32-i386


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
  800041:	a1 00 20 80 00       	mov    0x802000,%eax
  800046:	89 04 24             	mov    %eax,(%esp)
  800049:	e8 5e 00 00 00       	call   8000ac <sys_cputs>
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
  80005e:	e8 d8 00 00 00       	call   80013b <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 db                	test   %ebx,%ebx
  800077:	7e 07                	jle    800080 <libmain+0x30>
		binaryname = argv[0];
  800079:	8b 06                	mov    (%esi),%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004

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
  8000a5:	e8 3f 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 28                	jle    800133 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 78 11 80 	movl   $0x801178,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800126:	00 
  800127:	c7 04 24 95 11 80 00 	movl   $0x801195,(%esp)
  80012e:	e8 5b 02 00 00       	call   80038e <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800133:	83 c4 2c             	add    $0x2c,%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 02 00 00 00       	mov    $0x2,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_yield>:

void
sys_yield(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 0a 00 00 00       	mov    $0xa,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	b8 04 00 00 00       	mov    $0x4,%eax
  80018c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7e 28                	jle    8001c5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001a8:	00 
  8001a9:	c7 44 24 08 78 11 80 	movl   $0x801178,0x8(%esp)
  8001b0:	00 
  8001b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b8:	00 
  8001b9:	c7 04 24 95 11 80 00 	movl   $0x801195,(%esp)
  8001c0:	e8 c9 01 00 00       	call   80038e <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c5:	83 c4 2c             	add    $0x2c,%esp
  8001c8:	5b                   	pop    %ebx
  8001c9:	5e                   	pop    %esi
  8001ca:	5f                   	pop    %edi
  8001cb:	5d                   	pop    %ebp
  8001cc:	c3                   	ret    

008001cd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	57                   	push   %edi
  8001d1:	56                   	push   %esi
  8001d2:	53                   	push   %ebx
  8001d3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8001d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001de:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ea:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ec:	85 c0                	test   %eax,%eax
  8001ee:	7e 28                	jle    800218 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001fb:	00 
  8001fc:	c7 44 24 08 78 11 80 	movl   $0x801178,0x8(%esp)
  800203:	00 
  800204:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020b:	00 
  80020c:	c7 04 24 95 11 80 00 	movl   $0x801195,(%esp)
  800213:	e8 76 01 00 00       	call   80038e <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800218:	83 c4 2c             	add    $0x2c,%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5e                   	pop    %esi
  80021d:	5f                   	pop    %edi
  80021e:	5d                   	pop    %ebp
  80021f:	c3                   	ret    

00800220 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800229:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022e:	b8 06 00 00 00       	mov    $0x6,%eax
  800233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800236:	8b 55 08             	mov    0x8(%ebp),%edx
  800239:	89 df                	mov    %ebx,%edi
  80023b:	89 de                	mov    %ebx,%esi
  80023d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023f:	85 c0                	test   %eax,%eax
  800241:	7e 28                	jle    80026b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800243:	89 44 24 10          	mov    %eax,0x10(%esp)
  800247:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80024e:	00 
  80024f:	c7 44 24 08 78 11 80 	movl   $0x801178,0x8(%esp)
  800256:	00 
  800257:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025e:	00 
  80025f:	c7 04 24 95 11 80 00 	movl   $0x801195,(%esp)
  800266:	e8 23 01 00 00       	call   80038e <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026b:	83 c4 2c             	add    $0x2c,%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 08 00 00 00       	mov    $0x8,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 28                	jle    8002be <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a1:	00 
  8002a2:	c7 44 24 08 78 11 80 	movl   $0x801178,0x8(%esp)
  8002a9:	00 
  8002aa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b1:	00 
  8002b2:	c7 04 24 95 11 80 00 	movl   $0x801195,(%esp)
  8002b9:	e8 d0 00 00 00       	call   80038e <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002be:	83 c4 2c             	add    $0x2c,%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002df:	89 df                	mov    %ebx,%edi
  8002e1:	89 de                	mov    %ebx,%esi
  8002e3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002e5:	85 c0                	test   %eax,%eax
  8002e7:	7e 28                	jle    800311 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ed:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f4:	00 
  8002f5:	c7 44 24 08 78 11 80 	movl   $0x801178,0x8(%esp)
  8002fc:	00 
  8002fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800304:	00 
  800305:	c7 04 24 95 11 80 00 	movl   $0x801195,(%esp)
  80030c:	e8 7d 00 00 00       	call   80038e <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800311:	83 c4 2c             	add    $0x2c,%esp
  800314:	5b                   	pop    %ebx
  800315:	5e                   	pop    %esi
  800316:	5f                   	pop    %edi
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    

00800319 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80031f:	be 00 00 00 00       	mov    $0x0,%esi
  800324:	b8 0b 00 00 00       	mov    $0xb,%eax
  800329:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032c:	8b 55 08             	mov    0x8(%ebp),%edx
  80032f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800332:	8b 7d 14             	mov    0x14(%ebp),%edi
  800335:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800337:	5b                   	pop    %ebx
  800338:	5e                   	pop    %esi
  800339:	5f                   	pop    %edi
  80033a:	5d                   	pop    %ebp
  80033b:	c3                   	ret    

0080033c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	57                   	push   %edi
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
  800342:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800345:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80034f:	8b 55 08             	mov    0x8(%ebp),%edx
  800352:	89 cb                	mov    %ecx,%ebx
  800354:	89 cf                	mov    %ecx,%edi
  800356:	89 ce                	mov    %ecx,%esi
  800358:	cd 30                	int    $0x30
	if(check && ret > 0)
  80035a:	85 c0                	test   %eax,%eax
  80035c:	7e 28                	jle    800386 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800362:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800369:	00 
  80036a:	c7 44 24 08 78 11 80 	movl   $0x801178,0x8(%esp)
  800371:	00 
  800372:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800379:	00 
  80037a:	c7 04 24 95 11 80 00 	movl   $0x801195,(%esp)
  800381:	e8 08 00 00 00       	call   80038e <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800386:	83 c4 2c             	add    $0x2c,%esp
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	56                   	push   %esi
  800392:	53                   	push   %ebx
  800393:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800396:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800399:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80039f:	e8 97 fd ff ff       	call   80013b <sys_getenvid>
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ba:	c7 04 24 a4 11 80 00 	movl   $0x8011a4,(%esp)
  8003c1:	e8 c1 00 00 00       	call   800487 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cd:	89 04 24             	mov    %eax,(%esp)
  8003d0:	e8 51 00 00 00       	call   800426 <vcprintf>
	cprintf("\n");
  8003d5:	c7 04 24 6c 11 80 00 	movl   $0x80116c,(%esp)
  8003dc:	e8 a6 00 00 00       	call   800487 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003e1:	cc                   	int3   
  8003e2:	eb fd                	jmp    8003e1 <_panic+0x53>

008003e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	53                   	push   %ebx
  8003e8:	83 ec 14             	sub    $0x14,%esp
  8003eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ee:	8b 13                	mov    (%ebx),%edx
  8003f0:	8d 42 01             	lea    0x1(%edx),%eax
  8003f3:	89 03                	mov    %eax,(%ebx)
  8003f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  800401:	75 19                	jne    80041c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800403:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80040a:	00 
  80040b:	8d 43 08             	lea    0x8(%ebx),%eax
  80040e:	89 04 24             	mov    %eax,(%esp)
  800411:	e8 96 fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  800416:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80041c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800420:	83 c4 14             	add    $0x14,%esp
  800423:	5b                   	pop    %ebx
  800424:	5d                   	pop    %ebp
  800425:	c3                   	ret    

00800426 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80042f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800436:	00 00 00 
	b.cnt = 0;
  800439:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800440:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800443:	8b 45 0c             	mov    0xc(%ebp),%eax
  800446:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044a:	8b 45 08             	mov    0x8(%ebp),%eax
  80044d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800451:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800457:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045b:	c7 04 24 e4 03 80 00 	movl   $0x8003e4,(%esp)
  800462:	e8 bd 01 00 00       	call   800624 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800467:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80046d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800471:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800477:	89 04 24             	mov    %eax,(%esp)
  80047a:	e8 2d fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80047f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800485:	c9                   	leave  
  800486:	c3                   	ret    

00800487 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80048d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800490:	89 44 24 04          	mov    %eax,0x4(%esp)
  800494:	8b 45 08             	mov    0x8(%ebp),%eax
  800497:	89 04 24             	mov    %eax,(%esp)
  80049a:	e8 87 ff ff ff       	call   800426 <vcprintf>
	va_end(ap);

	return cnt;
}
  80049f:	c9                   	leave  
  8004a0:	c3                   	ret    
  8004a1:	66 90                	xchg   %ax,%ax
  8004a3:	66 90                	xchg   %ax,%ax
  8004a5:	66 90                	xchg   %ax,%ax
  8004a7:	66 90                	xchg   %ax,%ax
  8004a9:	66 90                	xchg   %ax,%ax
  8004ab:	66 90                	xchg   %ax,%ax
  8004ad:	66 90                	xchg   %ax,%ax
  8004af:	90                   	nop

008004b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	57                   	push   %edi
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	83 ec 3c             	sub    $0x3c,%esp
  8004b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004bc:	89 d7                	mov    %edx,%edi
  8004be:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004c7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8004ca:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004d8:	39 f1                	cmp    %esi,%ecx
  8004da:	72 14                	jb     8004f0 <printnum+0x40>
  8004dc:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004df:	76 0f                	jbe    8004f0 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 70 ff             	lea    -0x1(%eax),%esi
  8004e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004ea:	85 f6                	test   %esi,%esi
  8004ec:	7f 60                	jg     80054e <printnum+0x9e>
  8004ee:	eb 72                	jmp    800562 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004f0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004f3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004f7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004fa:	8d 51 ff             	lea    -0x1(%ecx),%edx
  8004fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800501:	89 44 24 08          	mov    %eax,0x8(%esp)
  800505:	8b 44 24 08          	mov    0x8(%esp),%eax
  800509:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80050d:	89 c3                	mov    %eax,%ebx
  80050f:	89 d6                	mov    %edx,%esi
  800511:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800514:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800517:	89 54 24 08          	mov    %edx,0x8(%esp)
  80051b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80051f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800522:	89 04 24             	mov    %eax,(%esp)
  800525:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800528:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052c:	e8 9f 09 00 00       	call   800ed0 <__udivdi3>
  800531:	89 d9                	mov    %ebx,%ecx
  800533:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800537:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80053b:	89 04 24             	mov    %eax,(%esp)
  80053e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800542:	89 fa                	mov    %edi,%edx
  800544:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800547:	e8 64 ff ff ff       	call   8004b0 <printnum>
  80054c:	eb 14                	jmp    800562 <printnum+0xb2>
			putch(padc, putdat);
  80054e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800552:	8b 45 18             	mov    0x18(%ebp),%eax
  800555:	89 04 24             	mov    %eax,(%esp)
  800558:	ff d3                	call   *%ebx
		while (--width > 0)
  80055a:	83 ee 01             	sub    $0x1,%esi
  80055d:	75 ef                	jne    80054e <printnum+0x9e>
  80055f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800562:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800566:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80056a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80056d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800570:	89 44 24 08          	mov    %eax,0x8(%esp)
  800574:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800578:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80057b:	89 04 24             	mov    %eax,(%esp)
  80057e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800581:	89 44 24 04          	mov    %eax,0x4(%esp)
  800585:	e8 76 0a 00 00       	call   801000 <__umoddi3>
  80058a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058e:	0f be 80 c8 11 80 00 	movsbl 0x8011c8(%eax),%eax
  800595:	89 04 24             	mov    %eax,(%esp)
  800598:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059b:	ff d0                	call   *%eax
}
  80059d:	83 c4 3c             	add    $0x3c,%esp
  8005a0:	5b                   	pop    %ebx
  8005a1:	5e                   	pop    %esi
  8005a2:	5f                   	pop    %edi
  8005a3:	5d                   	pop    %ebp
  8005a4:	c3                   	ret    

008005a5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005a5:	55                   	push   %ebp
  8005a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005a8:	83 fa 01             	cmp    $0x1,%edx
  8005ab:	7e 0e                	jle    8005bb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005ad:	8b 10                	mov    (%eax),%edx
  8005af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005b2:	89 08                	mov    %ecx,(%eax)
  8005b4:	8b 02                	mov    (%edx),%eax
  8005b6:	8b 52 04             	mov    0x4(%edx),%edx
  8005b9:	eb 22                	jmp    8005dd <getuint+0x38>
	else if (lflag)
  8005bb:	85 d2                	test   %edx,%edx
  8005bd:	74 10                	je     8005cf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005bf:	8b 10                	mov    (%eax),%edx
  8005c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005c4:	89 08                	mov    %ecx,(%eax)
  8005c6:	8b 02                	mov    (%edx),%eax
  8005c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005cd:	eb 0e                	jmp    8005dd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005cf:	8b 10                	mov    (%eax),%edx
  8005d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005d4:	89 08                	mov    %ecx,(%eax)
  8005d6:	8b 02                	mov    (%edx),%eax
  8005d8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005dd:	5d                   	pop    %ebp
  8005de:	c3                   	ret    

008005df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005e9:	8b 10                	mov    (%eax),%edx
  8005eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ee:	73 0a                	jae    8005fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8005f0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005f3:	89 08                	mov    %ecx,(%eax)
  8005f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f8:	88 02                	mov    %al,(%edx)
}
  8005fa:	5d                   	pop    %ebp
  8005fb:	c3                   	ret    

008005fc <printfmt>:
{
  8005fc:	55                   	push   %ebp
  8005fd:	89 e5                	mov    %esp,%ebp
  8005ff:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  800602:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800605:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800609:	8b 45 10             	mov    0x10(%ebp),%eax
  80060c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800610:	8b 45 0c             	mov    0xc(%ebp),%eax
  800613:	89 44 24 04          	mov    %eax,0x4(%esp)
  800617:	8b 45 08             	mov    0x8(%ebp),%eax
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	e8 02 00 00 00       	call   800624 <vprintfmt>
}
  800622:	c9                   	leave  
  800623:	c3                   	ret    

00800624 <vprintfmt>:
{
  800624:	55                   	push   %ebp
  800625:	89 e5                	mov    %esp,%ebp
  800627:	57                   	push   %edi
  800628:	56                   	push   %esi
  800629:	53                   	push   %ebx
  80062a:	83 ec 3c             	sub    $0x3c,%esp
  80062d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800630:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800633:	eb 18                	jmp    80064d <vprintfmt+0x29>
			if (ch == '\0')
  800635:	85 c0                	test   %eax,%eax
  800637:	0f 84 c3 03 00 00    	je     800a00 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80063d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800641:	89 04 24             	mov    %eax,(%esp)
  800644:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800647:	89 f3                	mov    %esi,%ebx
  800649:	eb 02                	jmp    80064d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80064b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80064d:	8d 73 01             	lea    0x1(%ebx),%esi
  800650:	0f b6 03             	movzbl (%ebx),%eax
  800653:	83 f8 25             	cmp    $0x25,%eax
  800656:	75 dd                	jne    800635 <vprintfmt+0x11>
  800658:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80065c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800663:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80066a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800671:	ba 00 00 00 00       	mov    $0x0,%edx
  800676:	eb 1d                	jmp    800695 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800678:	89 de                	mov    %ebx,%esi
			padc = '-';
  80067a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80067e:	eb 15                	jmp    800695 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800680:	89 de                	mov    %ebx,%esi
			padc = '0';
  800682:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800686:	eb 0d                	jmp    800695 <vprintfmt+0x71>
				width = precision, precision = -1;
  800688:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80068b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80068e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800695:	8d 5e 01             	lea    0x1(%esi),%ebx
  800698:	0f b6 06             	movzbl (%esi),%eax
  80069b:	0f b6 c8             	movzbl %al,%ecx
  80069e:	83 e8 23             	sub    $0x23,%eax
  8006a1:	3c 55                	cmp    $0x55,%al
  8006a3:	0f 87 2f 03 00 00    	ja     8009d8 <vprintfmt+0x3b4>
  8006a9:	0f b6 c0             	movzbl %al,%eax
  8006ac:	ff 24 85 80 12 80 00 	jmp    *0x801280(,%eax,4)
				precision = precision * 10 + ch - '0';
  8006b3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8006b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  8006b9:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8006bd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006c0:	83 f9 09             	cmp    $0x9,%ecx
  8006c3:	77 50                	ja     800715 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8006c5:	89 de                	mov    %ebx,%esi
  8006c7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8006ca:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8006cd:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8006d0:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8006d4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006d7:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8006da:	83 fb 09             	cmp    $0x9,%ebx
  8006dd:	76 eb                	jbe    8006ca <vprintfmt+0xa6>
  8006df:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006e2:	eb 33                	jmp    800717 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ea:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006ed:	8b 00                	mov    (%eax),%eax
  8006ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8006f2:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8006f4:	eb 21                	jmp    800717 <vprintfmt+0xf3>
  8006f6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006f9:	85 c9                	test   %ecx,%ecx
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800700:	0f 49 c1             	cmovns %ecx,%eax
  800703:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800706:	89 de                	mov    %ebx,%esi
  800708:	eb 8b                	jmp    800695 <vprintfmt+0x71>
  80070a:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80070c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800713:	eb 80                	jmp    800695 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800715:	89 de                	mov    %ebx,%esi
			if (width < 0)
  800717:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80071b:	0f 89 74 ff ff ff    	jns    800695 <vprintfmt+0x71>
  800721:	e9 62 ff ff ff       	jmp    800688 <vprintfmt+0x64>
			lflag++;
  800726:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800729:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80072b:	e9 65 ff ff ff       	jmp    800695 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8d 50 04             	lea    0x4(%eax),%edx
  800736:	89 55 14             	mov    %edx,0x14(%ebp)
  800739:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	89 04 24             	mov    %eax,(%esp)
  800742:	ff 55 08             	call   *0x8(%ebp)
			break;
  800745:	e9 03 ff ff ff       	jmp    80064d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8d 50 04             	lea    0x4(%eax),%edx
  800750:	89 55 14             	mov    %edx,0x14(%ebp)
  800753:	8b 00                	mov    (%eax),%eax
  800755:	99                   	cltd   
  800756:	31 d0                	xor    %edx,%eax
  800758:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80075a:	83 f8 08             	cmp    $0x8,%eax
  80075d:	7f 0b                	jg     80076a <vprintfmt+0x146>
  80075f:	8b 14 85 e0 13 80 00 	mov    0x8013e0(,%eax,4),%edx
  800766:	85 d2                	test   %edx,%edx
  800768:	75 20                	jne    80078a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80076a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076e:	c7 44 24 08 e0 11 80 	movl   $0x8011e0,0x8(%esp)
  800775:	00 
  800776:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077a:	8b 45 08             	mov    0x8(%ebp),%eax
  80077d:	89 04 24             	mov    %eax,(%esp)
  800780:	e8 77 fe ff ff       	call   8005fc <printfmt>
  800785:	e9 c3 fe ff ff       	jmp    80064d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80078a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80078e:	c7 44 24 08 e9 11 80 	movl   $0x8011e9,0x8(%esp)
  800795:	00 
  800796:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	89 04 24             	mov    %eax,(%esp)
  8007a0:	e8 57 fe ff ff       	call   8005fc <printfmt>
  8007a5:	e9 a3 fe ff ff       	jmp    80064d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8007ad:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8d 50 04             	lea    0x4(%eax),%edx
  8007b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	ba d9 11 80 00       	mov    $0x8011d9,%edx
  8007c2:	0f 45 d0             	cmovne %eax,%edx
  8007c5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8007c8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8007cc:	74 04                	je     8007d2 <vprintfmt+0x1ae>
  8007ce:	85 f6                	test   %esi,%esi
  8007d0:	7f 19                	jg     8007eb <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007d5:	8d 70 01             	lea    0x1(%eax),%esi
  8007d8:	0f b6 10             	movzbl (%eax),%edx
  8007db:	0f be c2             	movsbl %dl,%eax
  8007de:	85 c0                	test   %eax,%eax
  8007e0:	0f 85 95 00 00 00    	jne    80087b <vprintfmt+0x257>
  8007e6:	e9 85 00 00 00       	jmp    800870 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007f2:	89 04 24             	mov    %eax,(%esp)
  8007f5:	e8 b8 02 00 00       	call   800ab2 <strnlen>
  8007fa:	29 c6                	sub    %eax,%esi
  8007fc:	89 f0                	mov    %esi,%eax
  8007fe:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800801:	85 f6                	test   %esi,%esi
  800803:	7e cd                	jle    8007d2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800805:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800809:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80080c:	89 c3                	mov    %eax,%ebx
  80080e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800812:	89 34 24             	mov    %esi,(%esp)
  800815:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800818:	83 eb 01             	sub    $0x1,%ebx
  80081b:	75 f1                	jne    80080e <vprintfmt+0x1ea>
  80081d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800820:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800823:	eb ad                	jmp    8007d2 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800825:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800829:	74 1e                	je     800849 <vprintfmt+0x225>
  80082b:	0f be d2             	movsbl %dl,%edx
  80082e:	83 ea 20             	sub    $0x20,%edx
  800831:	83 fa 5e             	cmp    $0x5e,%edx
  800834:	76 13                	jbe    800849 <vprintfmt+0x225>
					putch('?', putdat);
  800836:	8b 45 0c             	mov    0xc(%ebp),%eax
  800839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800844:	ff 55 08             	call   *0x8(%ebp)
  800847:	eb 0d                	jmp    800856 <vprintfmt+0x232>
					putch(ch, putdat);
  800849:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800850:	89 04 24             	mov    %eax,(%esp)
  800853:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800856:	83 ef 01             	sub    $0x1,%edi
  800859:	83 c6 01             	add    $0x1,%esi
  80085c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800860:	0f be c2             	movsbl %dl,%eax
  800863:	85 c0                	test   %eax,%eax
  800865:	75 20                	jne    800887 <vprintfmt+0x263>
  800867:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80086a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80086d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800870:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800874:	7f 25                	jg     80089b <vprintfmt+0x277>
  800876:	e9 d2 fd ff ff       	jmp    80064d <vprintfmt+0x29>
  80087b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80087e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800881:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800884:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800887:	85 db                	test   %ebx,%ebx
  800889:	78 9a                	js     800825 <vprintfmt+0x201>
  80088b:	83 eb 01             	sub    $0x1,%ebx
  80088e:	79 95                	jns    800825 <vprintfmt+0x201>
  800890:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800893:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800896:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800899:	eb d5                	jmp    800870 <vprintfmt+0x24c>
  80089b:	8b 75 08             	mov    0x8(%ebp),%esi
  80089e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8008a1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  8008a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008a8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008af:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8008b1:	83 eb 01             	sub    $0x1,%ebx
  8008b4:	75 ee                	jne    8008a4 <vprintfmt+0x280>
  8008b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008b9:	e9 8f fd ff ff       	jmp    80064d <vprintfmt+0x29>
	if (lflag >= 2)
  8008be:	83 fa 01             	cmp    $0x1,%edx
  8008c1:	7e 16                	jle    8008d9 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8008c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c6:	8d 50 08             	lea    0x8(%eax),%edx
  8008c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cc:	8b 50 04             	mov    0x4(%eax),%edx
  8008cf:	8b 00                	mov    (%eax),%eax
  8008d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008d7:	eb 32                	jmp    80090b <vprintfmt+0x2e7>
	else if (lflag)
  8008d9:	85 d2                	test   %edx,%edx
  8008db:	74 18                	je     8008f5 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8008dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e0:	8d 50 04             	lea    0x4(%eax),%edx
  8008e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e6:	8b 30                	mov    (%eax),%esi
  8008e8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008eb:	89 f0                	mov    %esi,%eax
  8008ed:	c1 f8 1f             	sar    $0x1f,%eax
  8008f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008f3:	eb 16                	jmp    80090b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  8008f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f8:	8d 50 04             	lea    0x4(%eax),%edx
  8008fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008fe:	8b 30                	mov    (%eax),%esi
  800900:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800903:	89 f0                	mov    %esi,%eax
  800905:	c1 f8 1f             	sar    $0x1f,%eax
  800908:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  80090b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80090e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  800911:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800916:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80091a:	0f 89 80 00 00 00    	jns    8009a0 <vprintfmt+0x37c>
				putch('-', putdat);
  800920:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800924:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80092b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80092e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800931:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800934:	f7 d8                	neg    %eax
  800936:	83 d2 00             	adc    $0x0,%edx
  800939:	f7 da                	neg    %edx
			base = 10;
  80093b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800940:	eb 5e                	jmp    8009a0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800942:	8d 45 14             	lea    0x14(%ebp),%eax
  800945:	e8 5b fc ff ff       	call   8005a5 <getuint>
			base = 10;
  80094a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80094f:	eb 4f                	jmp    8009a0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800951:	8d 45 14             	lea    0x14(%ebp),%eax
  800954:	e8 4c fc ff ff       	call   8005a5 <getuint>
			base = 8;
  800959:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80095e:	eb 40                	jmp    8009a0 <vprintfmt+0x37c>
			putch('0', putdat);
  800960:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800964:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80096b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80096e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800972:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800979:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80097c:	8b 45 14             	mov    0x14(%ebp),%eax
  80097f:	8d 50 04             	lea    0x4(%eax),%edx
  800982:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800985:	8b 00                	mov    (%eax),%eax
  800987:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80098c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800991:	eb 0d                	jmp    8009a0 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800993:	8d 45 14             	lea    0x14(%ebp),%eax
  800996:	e8 0a fc ff ff       	call   8005a5 <getuint>
			base = 16;
  80099b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8009a0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009a4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8009a8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8009ab:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8009af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009b3:	89 04 24             	mov    %eax,(%esp)
  8009b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009ba:	89 fa                	mov    %edi,%edx
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	e8 ec fa ff ff       	call   8004b0 <printnum>
			break;
  8009c4:	e9 84 fc ff ff       	jmp    80064d <vprintfmt+0x29>
			putch(ch, putdat);
  8009c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009cd:	89 0c 24             	mov    %ecx,(%esp)
  8009d0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009d3:	e9 75 fc ff ff       	jmp    80064d <vprintfmt+0x29>
			putch('%', putdat);
  8009d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009e3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009e6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009ea:	0f 84 5b fc ff ff    	je     80064b <vprintfmt+0x27>
  8009f0:	89 f3                	mov    %esi,%ebx
  8009f2:	83 eb 01             	sub    $0x1,%ebx
  8009f5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8009f9:	75 f7                	jne    8009f2 <vprintfmt+0x3ce>
  8009fb:	e9 4d fc ff ff       	jmp    80064d <vprintfmt+0x29>
}
  800a00:	83 c4 3c             	add    $0x3c,%esp
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5f                   	pop    %edi
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	83 ec 28             	sub    $0x28,%esp
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a14:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a17:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a1b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a25:	85 c0                	test   %eax,%eax
  800a27:	74 30                	je     800a59 <vsnprintf+0x51>
  800a29:	85 d2                	test   %edx,%edx
  800a2b:	7e 2c                	jle    800a59 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a2d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a30:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a34:	8b 45 10             	mov    0x10(%ebp),%eax
  800a37:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a3b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a42:	c7 04 24 df 05 80 00 	movl   $0x8005df,(%esp)
  800a49:	e8 d6 fb ff ff       	call   800624 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a51:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a57:	eb 05                	jmp    800a5e <vsnprintf+0x56>
		return -E_INVAL;
  800a59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a5e:	c9                   	leave  
  800a5f:	c3                   	ret    

00800a60 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a66:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a6d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a70:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	89 04 24             	mov    %eax,(%esp)
  800a81:	e8 82 ff ff ff       	call   800a08 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    
  800a88:	66 90                	xchg   %ax,%ax
  800a8a:	66 90                	xchg   %ax,%ax
  800a8c:	66 90                	xchg   %ax,%ax
  800a8e:	66 90                	xchg   %ax,%ax

00800a90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a96:	80 3a 00             	cmpb   $0x0,(%edx)
  800a99:	74 10                	je     800aab <strlen+0x1b>
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800aa0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800aa3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800aa7:	75 f7                	jne    800aa0 <strlen+0x10>
  800aa9:	eb 05                	jmp    800ab0 <strlen+0x20>
  800aab:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	53                   	push   %ebx
  800ab6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ab9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800abc:	85 c9                	test   %ecx,%ecx
  800abe:	74 1c                	je     800adc <strnlen+0x2a>
  800ac0:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ac3:	74 1e                	je     800ae3 <strnlen+0x31>
  800ac5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800aca:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800acc:	39 ca                	cmp    %ecx,%edx
  800ace:	74 18                	je     800ae8 <strnlen+0x36>
  800ad0:	83 c2 01             	add    $0x1,%edx
  800ad3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800ad8:	75 f0                	jne    800aca <strnlen+0x18>
  800ada:	eb 0c                	jmp    800ae8 <strnlen+0x36>
  800adc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae1:	eb 05                	jmp    800ae8 <strnlen+0x36>
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	53                   	push   %ebx
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800af5:	89 c2                	mov    %eax,%edx
  800af7:	83 c2 01             	add    $0x1,%edx
  800afa:	83 c1 01             	add    $0x1,%ecx
  800afd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b01:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b04:	84 db                	test   %bl,%bl
  800b06:	75 ef                	jne    800af7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b08:	5b                   	pop    %ebx
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	53                   	push   %ebx
  800b0f:	83 ec 08             	sub    $0x8,%esp
  800b12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b15:	89 1c 24             	mov    %ebx,(%esp)
  800b18:	e8 73 ff ff ff       	call   800a90 <strlen>
	strcpy(dst + len, src);
  800b1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b20:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b24:	01 d8                	add    %ebx,%eax
  800b26:	89 04 24             	mov    %eax,(%esp)
  800b29:	e8 bd ff ff ff       	call   800aeb <strcpy>
	return dst;
}
  800b2e:	89 d8                	mov    %ebx,%eax
  800b30:	83 c4 08             	add    $0x8,%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	8b 75 08             	mov    0x8(%ebp),%esi
  800b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b44:	85 db                	test   %ebx,%ebx
  800b46:	74 17                	je     800b5f <strncpy+0x29>
  800b48:	01 f3                	add    %esi,%ebx
  800b4a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800b4c:	83 c1 01             	add    $0x1,%ecx
  800b4f:	0f b6 02             	movzbl (%edx),%eax
  800b52:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b55:	80 3a 01             	cmpb   $0x1,(%edx)
  800b58:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800b5b:	39 d9                	cmp    %ebx,%ecx
  800b5d:	75 ed                	jne    800b4c <strncpy+0x16>
	}
	return ret;
}
  800b5f:	89 f0                	mov    %esi,%eax
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b6e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b71:	8b 75 10             	mov    0x10(%ebp),%esi
  800b74:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b76:	85 f6                	test   %esi,%esi
  800b78:	74 34                	je     800bae <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800b7a:	83 fe 01             	cmp    $0x1,%esi
  800b7d:	74 26                	je     800ba5 <strlcpy+0x40>
  800b7f:	0f b6 0b             	movzbl (%ebx),%ecx
  800b82:	84 c9                	test   %cl,%cl
  800b84:	74 23                	je     800ba9 <strlcpy+0x44>
  800b86:	83 ee 02             	sub    $0x2,%esi
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  800b8e:	83 c0 01             	add    $0x1,%eax
  800b91:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800b94:	39 f2                	cmp    %esi,%edx
  800b96:	74 13                	je     800bab <strlcpy+0x46>
  800b98:	83 c2 01             	add    $0x1,%edx
  800b9b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b9f:	84 c9                	test   %cl,%cl
  800ba1:	75 eb                	jne    800b8e <strlcpy+0x29>
  800ba3:	eb 06                	jmp    800bab <strlcpy+0x46>
  800ba5:	89 f8                	mov    %edi,%eax
  800ba7:	eb 02                	jmp    800bab <strlcpy+0x46>
  800ba9:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  800bab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bae:	29 f8                	sub    %edi,%eax
}
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bbe:	0f b6 01             	movzbl (%ecx),%eax
  800bc1:	84 c0                	test   %al,%al
  800bc3:	74 15                	je     800bda <strcmp+0x25>
  800bc5:	3a 02                	cmp    (%edx),%al
  800bc7:	75 11                	jne    800bda <strcmp+0x25>
		p++, q++;
  800bc9:	83 c1 01             	add    $0x1,%ecx
  800bcc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800bcf:	0f b6 01             	movzbl (%ecx),%eax
  800bd2:	84 c0                	test   %al,%al
  800bd4:	74 04                	je     800bda <strcmp+0x25>
  800bd6:	3a 02                	cmp    (%edx),%al
  800bd8:	74 ef                	je     800bc9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bda:	0f b6 c0             	movzbl %al,%eax
  800bdd:	0f b6 12             	movzbl (%edx),%edx
  800be0:	29 d0                	sub    %edx,%eax
}
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bef:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800bf2:	85 f6                	test   %esi,%esi
  800bf4:	74 29                	je     800c1f <strncmp+0x3b>
  800bf6:	0f b6 03             	movzbl (%ebx),%eax
  800bf9:	84 c0                	test   %al,%al
  800bfb:	74 30                	je     800c2d <strncmp+0x49>
  800bfd:	3a 02                	cmp    (%edx),%al
  800bff:	75 2c                	jne    800c2d <strncmp+0x49>
  800c01:	8d 43 01             	lea    0x1(%ebx),%eax
  800c04:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800c06:	89 c3                	mov    %eax,%ebx
  800c08:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c0b:	39 f0                	cmp    %esi,%eax
  800c0d:	74 17                	je     800c26 <strncmp+0x42>
  800c0f:	0f b6 08             	movzbl (%eax),%ecx
  800c12:	84 c9                	test   %cl,%cl
  800c14:	74 17                	je     800c2d <strncmp+0x49>
  800c16:	83 c0 01             	add    $0x1,%eax
  800c19:	3a 0a                	cmp    (%edx),%cl
  800c1b:	74 e9                	je     800c06 <strncmp+0x22>
  800c1d:	eb 0e                	jmp    800c2d <strncmp+0x49>
	if (n == 0)
		return 0;
  800c1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c24:	eb 0f                	jmp    800c35 <strncmp+0x51>
  800c26:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2b:	eb 08                	jmp    800c35 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c2d:	0f b6 03             	movzbl (%ebx),%eax
  800c30:	0f b6 12             	movzbl (%edx),%edx
  800c33:	29 d0                	sub    %edx,%eax
}
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	53                   	push   %ebx
  800c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c40:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c43:	0f b6 18             	movzbl (%eax),%ebx
  800c46:	84 db                	test   %bl,%bl
  800c48:	74 1d                	je     800c67 <strchr+0x2e>
  800c4a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800c4c:	38 d3                	cmp    %dl,%bl
  800c4e:	75 06                	jne    800c56 <strchr+0x1d>
  800c50:	eb 1a                	jmp    800c6c <strchr+0x33>
  800c52:	38 ca                	cmp    %cl,%dl
  800c54:	74 16                	je     800c6c <strchr+0x33>
	for (; *s; s++)
  800c56:	83 c0 01             	add    $0x1,%eax
  800c59:	0f b6 10             	movzbl (%eax),%edx
  800c5c:	84 d2                	test   %dl,%dl
  800c5e:	75 f2                	jne    800c52 <strchr+0x19>
			return (char *) s;
	return 0;
  800c60:	b8 00 00 00 00       	mov    $0x0,%eax
  800c65:	eb 05                	jmp    800c6c <strchr+0x33>
  800c67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	53                   	push   %ebx
  800c73:	8b 45 08             	mov    0x8(%ebp),%eax
  800c76:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c79:	0f b6 18             	movzbl (%eax),%ebx
  800c7c:	84 db                	test   %bl,%bl
  800c7e:	74 16                	je     800c96 <strfind+0x27>
  800c80:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800c82:	38 d3                	cmp    %dl,%bl
  800c84:	75 06                	jne    800c8c <strfind+0x1d>
  800c86:	eb 0e                	jmp    800c96 <strfind+0x27>
  800c88:	38 ca                	cmp    %cl,%dl
  800c8a:	74 0a                	je     800c96 <strfind+0x27>
	for (; *s; s++)
  800c8c:	83 c0 01             	add    $0x1,%eax
  800c8f:	0f b6 10             	movzbl (%eax),%edx
  800c92:	84 d2                	test   %dl,%dl
  800c94:	75 f2                	jne    800c88 <strfind+0x19>
			break;
	return (char *) s;
}
  800c96:	5b                   	pop    %ebx
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ca2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ca5:	85 c9                	test   %ecx,%ecx
  800ca7:	74 36                	je     800cdf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ca9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800caf:	75 28                	jne    800cd9 <memset+0x40>
  800cb1:	f6 c1 03             	test   $0x3,%cl
  800cb4:	75 23                	jne    800cd9 <memset+0x40>
		c &= 0xFF;
  800cb6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cba:	89 d3                	mov    %edx,%ebx
  800cbc:	c1 e3 08             	shl    $0x8,%ebx
  800cbf:	89 d6                	mov    %edx,%esi
  800cc1:	c1 e6 18             	shl    $0x18,%esi
  800cc4:	89 d0                	mov    %edx,%eax
  800cc6:	c1 e0 10             	shl    $0x10,%eax
  800cc9:	09 f0                	or     %esi,%eax
  800ccb:	09 c2                	or     %eax,%edx
  800ccd:	89 d0                	mov    %edx,%eax
  800ccf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cd1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800cd4:	fc                   	cld    
  800cd5:	f3 ab                	rep stos %eax,%es:(%edi)
  800cd7:	eb 06                	jmp    800cdf <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdc:	fc                   	cld    
  800cdd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cdf:	89 f8                	mov    %edi,%eax
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cf4:	39 c6                	cmp    %eax,%esi
  800cf6:	73 35                	jae    800d2d <memmove+0x47>
  800cf8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cfb:	39 d0                	cmp    %edx,%eax
  800cfd:	73 2e                	jae    800d2d <memmove+0x47>
		s += n;
		d += n;
  800cff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800d02:	89 d6                	mov    %edx,%esi
  800d04:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d0c:	75 13                	jne    800d21 <memmove+0x3b>
  800d0e:	f6 c1 03             	test   $0x3,%cl
  800d11:	75 0e                	jne    800d21 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d13:	83 ef 04             	sub    $0x4,%edi
  800d16:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d19:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d1c:	fd                   	std    
  800d1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d1f:	eb 09                	jmp    800d2a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d21:	83 ef 01             	sub    $0x1,%edi
  800d24:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d27:	fd                   	std    
  800d28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d2a:	fc                   	cld    
  800d2b:	eb 1d                	jmp    800d4a <memmove+0x64>
  800d2d:	89 f2                	mov    %esi,%edx
  800d2f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d31:	f6 c2 03             	test   $0x3,%dl
  800d34:	75 0f                	jne    800d45 <memmove+0x5f>
  800d36:	f6 c1 03             	test   $0x3,%cl
  800d39:	75 0a                	jne    800d45 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d3b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d3e:	89 c7                	mov    %eax,%edi
  800d40:	fc                   	cld    
  800d41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d43:	eb 05                	jmp    800d4a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800d45:	89 c7                	mov    %eax,%edi
  800d47:	fc                   	cld    
  800d48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d54:	8b 45 10             	mov    0x10(%ebp),%eax
  800d57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
  800d65:	89 04 24             	mov    %eax,(%esp)
  800d68:	e8 79 ff ff ff       	call   800ce6 <memmove>
}
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    

00800d6f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d7b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800d81:	85 c0                	test   %eax,%eax
  800d83:	74 36                	je     800dbb <memcmp+0x4c>
		if (*s1 != *s2)
  800d85:	0f b6 03             	movzbl (%ebx),%eax
  800d88:	0f b6 0e             	movzbl (%esi),%ecx
  800d8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d90:	38 c8                	cmp    %cl,%al
  800d92:	74 1c                	je     800db0 <memcmp+0x41>
  800d94:	eb 10                	jmp    800da6 <memcmp+0x37>
  800d96:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800d9b:	83 c2 01             	add    $0x1,%edx
  800d9e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800da2:	38 c8                	cmp    %cl,%al
  800da4:	74 0a                	je     800db0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800da6:	0f b6 c0             	movzbl %al,%eax
  800da9:	0f b6 c9             	movzbl %cl,%ecx
  800dac:	29 c8                	sub    %ecx,%eax
  800dae:	eb 10                	jmp    800dc0 <memcmp+0x51>
	while (n-- > 0) {
  800db0:	39 fa                	cmp    %edi,%edx
  800db2:	75 e2                	jne    800d96 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800db4:	b8 00 00 00 00       	mov    $0x0,%eax
  800db9:	eb 05                	jmp    800dc0 <memcmp+0x51>
  800dbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	53                   	push   %ebx
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800dcf:	89 c2                	mov    %eax,%edx
  800dd1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800dd4:	39 d0                	cmp    %edx,%eax
  800dd6:	73 13                	jae    800deb <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dd8:	89 d9                	mov    %ebx,%ecx
  800dda:	38 18                	cmp    %bl,(%eax)
  800ddc:	75 06                	jne    800de4 <memfind+0x1f>
  800dde:	eb 0b                	jmp    800deb <memfind+0x26>
  800de0:	38 08                	cmp    %cl,(%eax)
  800de2:	74 07                	je     800deb <memfind+0x26>
	for (; s < ends; s++)
  800de4:	83 c0 01             	add    $0x1,%eax
  800de7:	39 d0                	cmp    %edx,%eax
  800de9:	75 f5                	jne    800de0 <memfind+0x1b>
			break;
	return (void *) s;
}
  800deb:	5b                   	pop    %ebx
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dfa:	0f b6 0a             	movzbl (%edx),%ecx
  800dfd:	80 f9 09             	cmp    $0x9,%cl
  800e00:	74 05                	je     800e07 <strtol+0x19>
  800e02:	80 f9 20             	cmp    $0x20,%cl
  800e05:	75 10                	jne    800e17 <strtol+0x29>
		s++;
  800e07:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800e0a:	0f b6 0a             	movzbl (%edx),%ecx
  800e0d:	80 f9 09             	cmp    $0x9,%cl
  800e10:	74 f5                	je     800e07 <strtol+0x19>
  800e12:	80 f9 20             	cmp    $0x20,%cl
  800e15:	74 f0                	je     800e07 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800e17:	80 f9 2b             	cmp    $0x2b,%cl
  800e1a:	75 0a                	jne    800e26 <strtol+0x38>
		s++;
  800e1c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800e1f:	bf 00 00 00 00       	mov    $0x0,%edi
  800e24:	eb 11                	jmp    800e37 <strtol+0x49>
  800e26:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800e2b:	80 f9 2d             	cmp    $0x2d,%cl
  800e2e:	75 07                	jne    800e37 <strtol+0x49>
		s++, neg = 1;
  800e30:	83 c2 01             	add    $0x1,%edx
  800e33:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e37:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800e3c:	75 15                	jne    800e53 <strtol+0x65>
  800e3e:	80 3a 30             	cmpb   $0x30,(%edx)
  800e41:	75 10                	jne    800e53 <strtol+0x65>
  800e43:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e47:	75 0a                	jne    800e53 <strtol+0x65>
		s += 2, base = 16;
  800e49:	83 c2 02             	add    $0x2,%edx
  800e4c:	b8 10 00 00 00       	mov    $0x10,%eax
  800e51:	eb 10                	jmp    800e63 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800e53:	85 c0                	test   %eax,%eax
  800e55:	75 0c                	jne    800e63 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e57:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800e59:	80 3a 30             	cmpb   $0x30,(%edx)
  800e5c:	75 05                	jne    800e63 <strtol+0x75>
		s++, base = 8;
  800e5e:	83 c2 01             	add    $0x1,%edx
  800e61:	b0 08                	mov    $0x8,%al
		base = 10;
  800e63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e68:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e6b:	0f b6 0a             	movzbl (%edx),%ecx
  800e6e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800e71:	89 f0                	mov    %esi,%eax
  800e73:	3c 09                	cmp    $0x9,%al
  800e75:	77 08                	ja     800e7f <strtol+0x91>
			dig = *s - '0';
  800e77:	0f be c9             	movsbl %cl,%ecx
  800e7a:	83 e9 30             	sub    $0x30,%ecx
  800e7d:	eb 20                	jmp    800e9f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800e7f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800e82:	89 f0                	mov    %esi,%eax
  800e84:	3c 19                	cmp    $0x19,%al
  800e86:	77 08                	ja     800e90 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800e88:	0f be c9             	movsbl %cl,%ecx
  800e8b:	83 e9 57             	sub    $0x57,%ecx
  800e8e:	eb 0f                	jmp    800e9f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800e90:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e93:	89 f0                	mov    %esi,%eax
  800e95:	3c 19                	cmp    $0x19,%al
  800e97:	77 16                	ja     800eaf <strtol+0xc1>
			dig = *s - 'A' + 10;
  800e99:	0f be c9             	movsbl %cl,%ecx
  800e9c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e9f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800ea2:	7d 0f                	jge    800eb3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ea4:	83 c2 01             	add    $0x1,%edx
  800ea7:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800eab:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ead:	eb bc                	jmp    800e6b <strtol+0x7d>
  800eaf:	89 d8                	mov    %ebx,%eax
  800eb1:	eb 02                	jmp    800eb5 <strtol+0xc7>
  800eb3:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800eb5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eb9:	74 05                	je     800ec0 <strtol+0xd2>
		*endptr = (char *) s;
  800ebb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ebe:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800ec0:	f7 d8                	neg    %eax
  800ec2:	85 ff                	test   %edi,%edi
  800ec4:	0f 44 c3             	cmove  %ebx,%eax
}
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    
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
