
obj/user/faultwrite.debug：     文件格式 elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	83 ec 10             	sub    $0x10,%esp
  80004a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800050:	e8 dd 00 00 00       	call   800132 <sys_getenvid>
  800055:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 db                	test   %ebx,%ebx
  800069:	7e 07                	jle    800072 <libmain+0x30>
		binaryname = argv[0];
  80006b:	8b 06                	mov    (%esi),%eax
  80006d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800072:	89 74 24 04          	mov    %esi,0x4(%esp)
  800076:	89 1c 24             	mov    %ebx,(%esp)
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 07 00 00 00       	call   80008a <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	5b                   	pop    %ebx
  800087:	5e                   	pop    %esi
  800088:	5d                   	pop    %ebp
  800089:	c3                   	ret    

0080008a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008a:	55                   	push   %ebp
  80008b:	89 e5                	mov    %esp,%ebp
  80008d:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800090:	e8 61 05 00 00       	call   8005f6 <close_all>
	sys_env_destroy(0);
  800095:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009c:	e8 3f 00 00 00       	call   8000e0 <sys_env_destroy>
}
  8000a1:	c9                   	leave  
  8000a2:	c3                   	ret    

008000a3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	57                   	push   %edi
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	89 c3                	mov    %eax,%ebx
  8000b6:	89 c7                	mov    %eax,%edi
  8000b8:	89 c6                	mov    %eax,%esi
  8000ba:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bc:	5b                   	pop    %ebx
  8000bd:	5e                   	pop    %esi
  8000be:	5f                   	pop    %edi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	57                   	push   %edi
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d1:	89 d1                	mov    %edx,%ecx
  8000d3:	89 d3                	mov    %edx,%ebx
  8000d5:	89 d7                	mov    %edx,%edi
  8000d7:	89 d6                	mov    %edx,%esi
  8000d9:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5f                   	pop    %edi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8000e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f6:	89 cb                	mov    %ecx,%ebx
  8000f8:	89 cf                	mov    %ecx,%edi
  8000fa:	89 ce                	mov    %ecx,%esi
  8000fc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000fe:	85 c0                	test   %eax,%eax
  800100:	7e 28                	jle    80012a <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800102:	89 44 24 10          	mov    %eax,0x10(%esp)
  800106:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80010d:	00 
  80010e:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  800115:	00 
  800116:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011d:	00 
  80011e:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  800125:	e8 5c 10 00 00       	call   801186 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	83 c4 2c             	add    $0x2c,%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 28                	jle    8001bc <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	89 44 24 10          	mov    %eax,0x10(%esp)
  800198:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80019f:	00 
  8001a0:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  8001a7:	00 
  8001a8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001af:	00 
  8001b0:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  8001b7:	e8 ca 0f 00 00       	call   801186 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	83 c4 2c             	add    $0x2c,%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 28                	jle    80020f <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001eb:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001f2:	00 
  8001f3:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  8001fa:	00 
  8001fb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800202:	00 
  800203:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  80020a:	e8 77 0f 00 00       	call   801186 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80020f:	83 c4 2c             	add    $0x2c,%esp
  800212:	5b                   	pop    %ebx
  800213:	5e                   	pop    %esi
  800214:	5f                   	pop    %edi
  800215:	5d                   	pop    %ebp
  800216:	c3                   	ret    

00800217 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800220:	bb 00 00 00 00       	mov    $0x0,%ebx
  800225:	b8 06 00 00 00       	mov    $0x6,%eax
  80022a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022d:	8b 55 08             	mov    0x8(%ebp),%edx
  800230:	89 df                	mov    %ebx,%edi
  800232:	89 de                	mov    %ebx,%esi
  800234:	cd 30                	int    $0x30
	if(check && ret > 0)
  800236:	85 c0                	test   %eax,%eax
  800238:	7e 28                	jle    800262 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80023e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800245:	00 
  800246:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  80024d:	00 
  80024e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800255:	00 
  800256:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  80025d:	e8 24 0f 00 00       	call   801186 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800262:	83 c4 2c             	add    $0x2c,%esp
  800265:	5b                   	pop    %ebx
  800266:	5e                   	pop    %esi
  800267:	5f                   	pop    %edi
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    

0080026a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	57                   	push   %edi
  80026e:	56                   	push   %esi
  80026f:	53                   	push   %ebx
  800270:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800273:	bb 00 00 00 00       	mov    $0x0,%ebx
  800278:	b8 08 00 00 00       	mov    $0x8,%eax
  80027d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800280:	8b 55 08             	mov    0x8(%ebp),%edx
  800283:	89 df                	mov    %ebx,%edi
  800285:	89 de                	mov    %ebx,%esi
  800287:	cd 30                	int    $0x30
	if(check && ret > 0)
  800289:	85 c0                	test   %eax,%eax
  80028b:	7e 28                	jle    8002b5 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800291:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800298:	00 
  800299:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  8002a0:	00 
  8002a1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a8:	00 
  8002a9:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  8002b0:	e8 d1 0e 00 00       	call   801186 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002b5:	83 c4 2c             	add    $0x2c,%esp
  8002b8:	5b                   	pop    %ebx
  8002b9:	5e                   	pop    %esi
  8002ba:	5f                   	pop    %edi
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cb:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d6:	89 df                	mov    %ebx,%edi
  8002d8:	89 de                	mov    %ebx,%esi
  8002da:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	7e 28                	jle    800308 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e4:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002eb:	00 
  8002ec:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  8002f3:	00 
  8002f4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002fb:	00 
  8002fc:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  800303:	e8 7e 0e 00 00       	call   801186 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800308:	83 c4 2c             	add    $0x2c,%esp
  80030b:	5b                   	pop    %ebx
  80030c:	5e                   	pop    %esi
  80030d:	5f                   	pop    %edi
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	57                   	push   %edi
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
  800316:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800319:	bb 00 00 00 00       	mov    $0x0,%ebx
  80031e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800323:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 df                	mov    %ebx,%edi
  80032b:	89 de                	mov    %ebx,%esi
  80032d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80032f:	85 c0                	test   %eax,%eax
  800331:	7e 28                	jle    80035b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800333:	89 44 24 10          	mov    %eax,0x10(%esp)
  800337:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80033e:	00 
  80033f:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  800346:	00 
  800347:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80034e:	00 
  80034f:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  800356:	e8 2b 0e 00 00       	call   801186 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80035b:	83 c4 2c             	add    $0x2c,%esp
  80035e:	5b                   	pop    %ebx
  80035f:	5e                   	pop    %esi
  800360:	5f                   	pop    %edi
  800361:	5d                   	pop    %ebp
  800362:	c3                   	ret    

00800363 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
  800366:	57                   	push   %edi
  800367:	56                   	push   %esi
  800368:	53                   	push   %ebx
	asm volatile("int %1\n"
  800369:	be 00 00 00 00       	mov    $0x0,%esi
  80036e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800373:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800376:	8b 55 08             	mov    0x8(%ebp),%edx
  800379:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80037c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80037f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800381:	5b                   	pop    %ebx
  800382:	5e                   	pop    %esi
  800383:	5f                   	pop    %edi
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	57                   	push   %edi
  80038a:	56                   	push   %esi
  80038b:	53                   	push   %ebx
  80038c:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80038f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800394:	b8 0d 00 00 00       	mov    $0xd,%eax
  800399:	8b 55 08             	mov    0x8(%ebp),%edx
  80039c:	89 cb                	mov    %ecx,%ebx
  80039e:	89 cf                	mov    %ecx,%edi
  8003a0:	89 ce                	mov    %ecx,%esi
  8003a2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8003a4:	85 c0                	test   %eax,%eax
  8003a6:	7e 28                	jle    8003d0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003ac:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003b3:	00 
  8003b4:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  8003bb:	00 
  8003bc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003c3:	00 
  8003c4:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  8003cb:	e8 b6 0d 00 00       	call   801186 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003d0:	83 c4 2c             	add    $0x2c,%esp
  8003d3:	5b                   	pop    %ebx
  8003d4:	5e                   	pop    %esi
  8003d5:	5f                   	pop    %edi
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    
  8003d8:	66 90                	xchg   %ax,%ax
  8003da:	66 90                	xchg   %ax,%ax
  8003dc:	66 90                	xchg   %ax,%ax
  8003de:	66 90                	xchg   %ax,%ax

008003e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8003ee:	5d                   	pop    %ebp
  8003ef:	c3                   	ret    

008003f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800400:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800405:	5d                   	pop    %ebp
  800406:	c3                   	ret    

00800407 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80040a:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80040f:	a8 01                	test   $0x1,%al
  800411:	74 34                	je     800447 <fd_alloc+0x40>
  800413:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800418:	a8 01                	test   $0x1,%al
  80041a:	74 32                	je     80044e <fd_alloc+0x47>
  80041c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  800421:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800423:	89 c2                	mov    %eax,%edx
  800425:	c1 ea 16             	shr    $0x16,%edx
  800428:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80042f:	f6 c2 01             	test   $0x1,%dl
  800432:	74 1f                	je     800453 <fd_alloc+0x4c>
  800434:	89 c2                	mov    %eax,%edx
  800436:	c1 ea 0c             	shr    $0xc,%edx
  800439:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800440:	f6 c2 01             	test   $0x1,%dl
  800443:	75 1a                	jne    80045f <fd_alloc+0x58>
  800445:	eb 0c                	jmp    800453 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  800447:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80044c:	eb 05                	jmp    800453 <fd_alloc+0x4c>
  80044e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  800453:	8b 45 08             	mov    0x8(%ebp),%eax
  800456:	89 08                	mov    %ecx,(%eax)
			return 0;
  800458:	b8 00 00 00 00       	mov    $0x0,%eax
  80045d:	eb 1a                	jmp    800479 <fd_alloc+0x72>
  80045f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800464:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800469:	75 b6                	jne    800421 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  80046b:	8b 45 08             	mov    0x8(%ebp),%eax
  80046e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800474:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800479:	5d                   	pop    %ebp
  80047a:	c3                   	ret    

0080047b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
  80047e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800481:	83 f8 1f             	cmp    $0x1f,%eax
  800484:	77 36                	ja     8004bc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800486:	c1 e0 0c             	shl    $0xc,%eax
  800489:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80048e:	89 c2                	mov    %eax,%edx
  800490:	c1 ea 16             	shr    $0x16,%edx
  800493:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80049a:	f6 c2 01             	test   $0x1,%dl
  80049d:	74 24                	je     8004c3 <fd_lookup+0x48>
  80049f:	89 c2                	mov    %eax,%edx
  8004a1:	c1 ea 0c             	shr    $0xc,%edx
  8004a4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004ab:	f6 c2 01             	test   $0x1,%dl
  8004ae:	74 1a                	je     8004ca <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b3:	89 02                	mov    %eax,(%edx)
	return 0;
  8004b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ba:	eb 13                	jmp    8004cf <fd_lookup+0x54>
		return -E_INVAL;
  8004bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004c1:	eb 0c                	jmp    8004cf <fd_lookup+0x54>
		return -E_INVAL;
  8004c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004c8:	eb 05                	jmp    8004cf <fd_lookup+0x54>
  8004ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004cf:	5d                   	pop    %ebp
  8004d0:	c3                   	ret    

008004d1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004d1:	55                   	push   %ebp
  8004d2:	89 e5                	mov    %esp,%ebp
  8004d4:	53                   	push   %ebx
  8004d5:	83 ec 14             	sub    $0x14,%esp
  8004d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8004de:	39 05 04 30 80 00    	cmp    %eax,0x803004
  8004e4:	75 1e                	jne    800504 <dev_lookup+0x33>
  8004e6:	eb 0e                	jmp    8004f6 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  8004e8:	b8 20 30 80 00       	mov    $0x803020,%eax
  8004ed:	eb 0c                	jmp    8004fb <dev_lookup+0x2a>
  8004ef:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  8004f4:	eb 05                	jmp    8004fb <dev_lookup+0x2a>
  8004f6:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  8004fb:	89 03                	mov    %eax,(%ebx)
			return 0;
  8004fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800502:	eb 38                	jmp    80053c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  800504:	39 05 20 30 80 00    	cmp    %eax,0x803020
  80050a:	74 dc                	je     8004e8 <dev_lookup+0x17>
  80050c:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  800512:	74 db                	je     8004ef <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800514:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80051a:	8b 52 48             	mov    0x48(%edx),%edx
  80051d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800521:	89 54 24 04          	mov    %edx,0x4(%esp)
  800525:	c7 04 24 b8 20 80 00 	movl   $0x8020b8,(%esp)
  80052c:	e8 4e 0d 00 00       	call   80127f <cprintf>
	*dev = 0;
  800531:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800537:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80053c:	83 c4 14             	add    $0x14,%esp
  80053f:	5b                   	pop    %ebx
  800540:	5d                   	pop    %ebp
  800541:	c3                   	ret    

00800542 <fd_close>:
{
  800542:	55                   	push   %ebp
  800543:	89 e5                	mov    %esp,%ebp
  800545:	56                   	push   %esi
  800546:	53                   	push   %ebx
  800547:	83 ec 20             	sub    $0x20,%esp
  80054a:	8b 75 08             	mov    0x8(%ebp),%esi
  80054d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800550:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800553:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800557:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80055d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800560:	89 04 24             	mov    %eax,(%esp)
  800563:	e8 13 ff ff ff       	call   80047b <fd_lookup>
  800568:	85 c0                	test   %eax,%eax
  80056a:	78 05                	js     800571 <fd_close+0x2f>
	    || fd != fd2)
  80056c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80056f:	74 0c                	je     80057d <fd_close+0x3b>
		return (must_exist ? r : 0);
  800571:	84 db                	test   %bl,%bl
  800573:	ba 00 00 00 00       	mov    $0x0,%edx
  800578:	0f 44 c2             	cmove  %edx,%eax
  80057b:	eb 3f                	jmp    8005bc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80057d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800580:	89 44 24 04          	mov    %eax,0x4(%esp)
  800584:	8b 06                	mov    (%esi),%eax
  800586:	89 04 24             	mov    %eax,(%esp)
  800589:	e8 43 ff ff ff       	call   8004d1 <dev_lookup>
  80058e:	89 c3                	mov    %eax,%ebx
  800590:	85 c0                	test   %eax,%eax
  800592:	78 16                	js     8005aa <fd_close+0x68>
		if (dev->dev_close)
  800594:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800597:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80059a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	74 07                	je     8005aa <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8005a3:	89 34 24             	mov    %esi,(%esp)
  8005a6:	ff d0                	call   *%eax
  8005a8:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8005aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005b5:	e8 5d fc ff ff       	call   800217 <sys_page_unmap>
	return r;
  8005ba:	89 d8                	mov    %ebx,%eax
}
  8005bc:	83 c4 20             	add    $0x20,%esp
  8005bf:	5b                   	pop    %ebx
  8005c0:	5e                   	pop    %esi
  8005c1:	5d                   	pop    %ebp
  8005c2:	c3                   	ret    

008005c3 <close>:

int
close(int fdnum)
{
  8005c3:	55                   	push   %ebp
  8005c4:	89 e5                	mov    %esp,%ebp
  8005c6:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d3:	89 04 24             	mov    %eax,(%esp)
  8005d6:	e8 a0 fe ff ff       	call   80047b <fd_lookup>
  8005db:	89 c2                	mov    %eax,%edx
  8005dd:	85 d2                	test   %edx,%edx
  8005df:	78 13                	js     8005f4 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8005e1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005e8:	00 
  8005e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005ec:	89 04 24             	mov    %eax,(%esp)
  8005ef:	e8 4e ff ff ff       	call   800542 <fd_close>
}
  8005f4:	c9                   	leave  
  8005f5:	c3                   	ret    

008005f6 <close_all>:

void
close_all(void)
{
  8005f6:	55                   	push   %ebp
  8005f7:	89 e5                	mov    %esp,%ebp
  8005f9:	53                   	push   %ebx
  8005fa:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800602:	89 1c 24             	mov    %ebx,(%esp)
  800605:	e8 b9 ff ff ff       	call   8005c3 <close>
	for (i = 0; i < MAXFD; i++)
  80060a:	83 c3 01             	add    $0x1,%ebx
  80060d:	83 fb 20             	cmp    $0x20,%ebx
  800610:	75 f0                	jne    800602 <close_all+0xc>
}
  800612:	83 c4 14             	add    $0x14,%esp
  800615:	5b                   	pop    %ebx
  800616:	5d                   	pop    %ebp
  800617:	c3                   	ret    

00800618 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800618:	55                   	push   %ebp
  800619:	89 e5                	mov    %esp,%ebp
  80061b:	57                   	push   %edi
  80061c:	56                   	push   %esi
  80061d:	53                   	push   %ebx
  80061e:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800621:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800624:	89 44 24 04          	mov    %eax,0x4(%esp)
  800628:	8b 45 08             	mov    0x8(%ebp),%eax
  80062b:	89 04 24             	mov    %eax,(%esp)
  80062e:	e8 48 fe ff ff       	call   80047b <fd_lookup>
  800633:	89 c2                	mov    %eax,%edx
  800635:	85 d2                	test   %edx,%edx
  800637:	0f 88 e1 00 00 00    	js     80071e <dup+0x106>
		return r;
	close(newfdnum);
  80063d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800640:	89 04 24             	mov    %eax,(%esp)
  800643:	e8 7b ff ff ff       	call   8005c3 <close>

	newfd = INDEX2FD(newfdnum);
  800648:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80064b:	c1 e3 0c             	shl    $0xc,%ebx
  80064e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800654:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800657:	89 04 24             	mov    %eax,(%esp)
  80065a:	e8 91 fd ff ff       	call   8003f0 <fd2data>
  80065f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  800661:	89 1c 24             	mov    %ebx,(%esp)
  800664:	e8 87 fd ff ff       	call   8003f0 <fd2data>
  800669:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80066b:	89 f0                	mov    %esi,%eax
  80066d:	c1 e8 16             	shr    $0x16,%eax
  800670:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800677:	a8 01                	test   $0x1,%al
  800679:	74 43                	je     8006be <dup+0xa6>
  80067b:	89 f0                	mov    %esi,%eax
  80067d:	c1 e8 0c             	shr    $0xc,%eax
  800680:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800687:	f6 c2 01             	test   $0x1,%dl
  80068a:	74 32                	je     8006be <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80068c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800693:	25 07 0e 00 00       	and    $0xe07,%eax
  800698:	89 44 24 10          	mov    %eax,0x10(%esp)
  80069c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8006a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006a7:	00 
  8006a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006b3:	e8 0c fb ff ff       	call   8001c4 <sys_page_map>
  8006b8:	89 c6                	mov    %eax,%esi
  8006ba:	85 c0                	test   %eax,%eax
  8006bc:	78 3e                	js     8006fc <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006c1:	89 c2                	mov    %eax,%edx
  8006c3:	c1 ea 0c             	shr    $0xc,%edx
  8006c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006cd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006d3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006d7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006e2:	00 
  8006e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ee:	e8 d1 fa ff ff       	call   8001c4 <sys_page_map>
  8006f3:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8006f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006f8:	85 f6                	test   %esi,%esi
  8006fa:	79 22                	jns    80071e <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8006fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800700:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800707:	e8 0b fb ff ff       	call   800217 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80070c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800710:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800717:	e8 fb fa ff ff       	call   800217 <sys_page_unmap>
	return r;
  80071c:	89 f0                	mov    %esi,%eax
}
  80071e:	83 c4 3c             	add    $0x3c,%esp
  800721:	5b                   	pop    %ebx
  800722:	5e                   	pop    %esi
  800723:	5f                   	pop    %edi
  800724:	5d                   	pop    %ebp
  800725:	c3                   	ret    

00800726 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	53                   	push   %ebx
  80072a:	83 ec 24             	sub    $0x24,%esp
  80072d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800730:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800733:	89 44 24 04          	mov    %eax,0x4(%esp)
  800737:	89 1c 24             	mov    %ebx,(%esp)
  80073a:	e8 3c fd ff ff       	call   80047b <fd_lookup>
  80073f:	89 c2                	mov    %eax,%edx
  800741:	85 d2                	test   %edx,%edx
  800743:	78 6d                	js     8007b2 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800745:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800748:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074f:	8b 00                	mov    (%eax),%eax
  800751:	89 04 24             	mov    %eax,(%esp)
  800754:	e8 78 fd ff ff       	call   8004d1 <dev_lookup>
  800759:	85 c0                	test   %eax,%eax
  80075b:	78 55                	js     8007b2 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80075d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800760:	8b 50 08             	mov    0x8(%eax),%edx
  800763:	83 e2 03             	and    $0x3,%edx
  800766:	83 fa 01             	cmp    $0x1,%edx
  800769:	75 23                	jne    80078e <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80076b:	a1 04 40 80 00       	mov    0x804004,%eax
  800770:	8b 40 48             	mov    0x48(%eax),%eax
  800773:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077b:	c7 04 24 f9 20 80 00 	movl   $0x8020f9,(%esp)
  800782:	e8 f8 0a 00 00       	call   80127f <cprintf>
		return -E_INVAL;
  800787:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078c:	eb 24                	jmp    8007b2 <read+0x8c>
	}
	if (!dev->dev_read)
  80078e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800791:	8b 52 08             	mov    0x8(%edx),%edx
  800794:	85 d2                	test   %edx,%edx
  800796:	74 15                	je     8007ad <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800798:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80079b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80079f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007a6:	89 04 24             	mov    %eax,(%esp)
  8007a9:	ff d2                	call   *%edx
  8007ab:	eb 05                	jmp    8007b2 <read+0x8c>
		return -E_NOT_SUPP;
  8007ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8007b2:	83 c4 24             	add    $0x24,%esp
  8007b5:	5b                   	pop    %ebx
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	57                   	push   %edi
  8007bc:	56                   	push   %esi
  8007bd:	53                   	push   %ebx
  8007be:	83 ec 1c             	sub    $0x1c,%esp
  8007c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007c7:	85 f6                	test   %esi,%esi
  8007c9:	74 33                	je     8007fe <readn+0x46>
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d0:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007d5:	89 f2                	mov    %esi,%edx
  8007d7:	29 c2                	sub    %eax,%edx
  8007d9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8007dd:	03 45 0c             	add    0xc(%ebp),%eax
  8007e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e4:	89 3c 24             	mov    %edi,(%esp)
  8007e7:	e8 3a ff ff ff       	call   800726 <read>
		if (m < 0)
  8007ec:	85 c0                	test   %eax,%eax
  8007ee:	78 1b                	js     80080b <readn+0x53>
			return m;
		if (m == 0)
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	74 11                	je     800805 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  8007f4:	01 c3                	add    %eax,%ebx
  8007f6:	89 d8                	mov    %ebx,%eax
  8007f8:	39 f3                	cmp    %esi,%ebx
  8007fa:	72 d9                	jb     8007d5 <readn+0x1d>
  8007fc:	eb 0b                	jmp    800809 <readn+0x51>
  8007fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800803:	eb 06                	jmp    80080b <readn+0x53>
  800805:	89 d8                	mov    %ebx,%eax
  800807:	eb 02                	jmp    80080b <readn+0x53>
  800809:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80080b:	83 c4 1c             	add    $0x1c,%esp
  80080e:	5b                   	pop    %ebx
  80080f:	5e                   	pop    %esi
  800810:	5f                   	pop    %edi
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	53                   	push   %ebx
  800817:	83 ec 24             	sub    $0x24,%esp
  80081a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80081d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800820:	89 44 24 04          	mov    %eax,0x4(%esp)
  800824:	89 1c 24             	mov    %ebx,(%esp)
  800827:	e8 4f fc ff ff       	call   80047b <fd_lookup>
  80082c:	89 c2                	mov    %eax,%edx
  80082e:	85 d2                	test   %edx,%edx
  800830:	78 68                	js     80089a <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800832:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800835:	89 44 24 04          	mov    %eax,0x4(%esp)
  800839:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083c:	8b 00                	mov    (%eax),%eax
  80083e:	89 04 24             	mov    %eax,(%esp)
  800841:	e8 8b fc ff ff       	call   8004d1 <dev_lookup>
  800846:	85 c0                	test   %eax,%eax
  800848:	78 50                	js     80089a <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80084a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800851:	75 23                	jne    800876 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800853:	a1 04 40 80 00       	mov    0x804004,%eax
  800858:	8b 40 48             	mov    0x48(%eax),%eax
  80085b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80085f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800863:	c7 04 24 15 21 80 00 	movl   $0x802115,(%esp)
  80086a:	e8 10 0a 00 00       	call   80127f <cprintf>
		return -E_INVAL;
  80086f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800874:	eb 24                	jmp    80089a <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800876:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800879:	8b 52 0c             	mov    0xc(%edx),%edx
  80087c:	85 d2                	test   %edx,%edx
  80087e:	74 15                	je     800895 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800880:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800883:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80088e:	89 04 24             	mov    %eax,(%esp)
  800891:	ff d2                	call   *%edx
  800893:	eb 05                	jmp    80089a <write+0x87>
		return -E_NOT_SUPP;
  800895:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80089a:	83 c4 24             	add    $0x24,%esp
  80089d:	5b                   	pop    %ebx
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008a6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8008a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	89 04 24             	mov    %eax,(%esp)
  8008b3:	e8 c3 fb ff ff       	call   80047b <fd_lookup>
  8008b8:	85 c0                	test   %eax,%eax
  8008ba:	78 0e                	js     8008ca <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	53                   	push   %ebx
  8008d0:	83 ec 24             	sub    $0x24,%esp
  8008d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008dd:	89 1c 24             	mov    %ebx,(%esp)
  8008e0:	e8 96 fb ff ff       	call   80047b <fd_lookup>
  8008e5:	89 c2                	mov    %eax,%edx
  8008e7:	85 d2                	test   %edx,%edx
  8008e9:	78 61                	js     80094c <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008f5:	8b 00                	mov    (%eax),%eax
  8008f7:	89 04 24             	mov    %eax,(%esp)
  8008fa:	e8 d2 fb ff ff       	call   8004d1 <dev_lookup>
  8008ff:	85 c0                	test   %eax,%eax
  800901:	78 49                	js     80094c <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800903:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800906:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80090a:	75 23                	jne    80092f <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80090c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800911:	8b 40 48             	mov    0x48(%eax),%eax
  800914:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800918:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091c:	c7 04 24 d8 20 80 00 	movl   $0x8020d8,(%esp)
  800923:	e8 57 09 00 00       	call   80127f <cprintf>
		return -E_INVAL;
  800928:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80092d:	eb 1d                	jmp    80094c <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80092f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800932:	8b 52 18             	mov    0x18(%edx),%edx
  800935:	85 d2                	test   %edx,%edx
  800937:	74 0e                	je     800947 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800939:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800940:	89 04 24             	mov    %eax,(%esp)
  800943:	ff d2                	call   *%edx
  800945:	eb 05                	jmp    80094c <ftruncate+0x80>
		return -E_NOT_SUPP;
  800947:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80094c:	83 c4 24             	add    $0x24,%esp
  80094f:	5b                   	pop    %ebx
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	53                   	push   %ebx
  800956:	83 ec 24             	sub    $0x24,%esp
  800959:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80095c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80095f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	89 04 24             	mov    %eax,(%esp)
  800969:	e8 0d fb ff ff       	call   80047b <fd_lookup>
  80096e:	89 c2                	mov    %eax,%edx
  800970:	85 d2                	test   %edx,%edx
  800972:	78 52                	js     8009c6 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800974:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800977:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80097e:	8b 00                	mov    (%eax),%eax
  800980:	89 04 24             	mov    %eax,(%esp)
  800983:	e8 49 fb ff ff       	call   8004d1 <dev_lookup>
  800988:	85 c0                	test   %eax,%eax
  80098a:	78 3a                	js     8009c6 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80098c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80098f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800993:	74 2c                	je     8009c1 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800995:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800998:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80099f:	00 00 00 
	stat->st_isdir = 0;
  8009a2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8009a9:	00 00 00 
	stat->st_dev = dev;
  8009ac:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009b9:	89 14 24             	mov    %edx,(%esp)
  8009bc:	ff 50 14             	call   *0x14(%eax)
  8009bf:	eb 05                	jmp    8009c6 <fstat+0x74>
		return -E_NOT_SUPP;
  8009c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8009c6:	83 c4 24             	add    $0x24,%esp
  8009c9:	5b                   	pop    %ebx
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	56                   	push   %esi
  8009d0:	53                   	push   %ebx
  8009d1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009db:	00 
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	89 04 24             	mov    %eax,(%esp)
  8009e2:	e8 af 01 00 00       	call   800b96 <open>
  8009e7:	89 c3                	mov    %eax,%ebx
  8009e9:	85 db                	test   %ebx,%ebx
  8009eb:	78 1b                	js     800a08 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f4:	89 1c 24             	mov    %ebx,(%esp)
  8009f7:	e8 56 ff ff ff       	call   800952 <fstat>
  8009fc:	89 c6                	mov    %eax,%esi
	close(fd);
  8009fe:	89 1c 24             	mov    %ebx,(%esp)
  800a01:	e8 bd fb ff ff       	call   8005c3 <close>
	return r;
  800a06:	89 f0                	mov    %esi,%eax
}
  800a08:	83 c4 10             	add    $0x10,%esp
  800a0b:	5b                   	pop    %ebx
  800a0c:	5e                   	pop    %esi
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	83 ec 10             	sub    $0x10,%esp
  800a17:	89 c6                	mov    %eax,%esi
  800a19:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800a1b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a22:	75 11                	jne    800a35 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a24:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a2b:	e8 30 13 00 00       	call   801d60 <ipc_find_env>
  800a30:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a35:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a3c:	00 
  800a3d:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a44:	00 
  800a45:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a49:	a1 00 40 80 00       	mov    0x804000,%eax
  800a4e:	89 04 24             	mov    %eax,(%esp)
  800a51:	e8 c2 12 00 00       	call   801d18 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a56:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a5d:	00 
  800a5e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a69:	e8 4e 12 00 00       	call   801cbc <ipc_recv>
}
  800a6e:	83 c4 10             	add    $0x10,%esp
  800a71:	5b                   	pop    %ebx
  800a72:	5e                   	pop    %esi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	53                   	push   %ebx
  800a79:	83 ec 14             	sub    $0x14,%esp
  800a7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a82:	8b 40 0c             	mov    0xc(%eax),%eax
  800a85:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800a94:	e8 76 ff ff ff       	call   800a0f <fsipc>
  800a99:	89 c2                	mov    %eax,%edx
  800a9b:	85 d2                	test   %edx,%edx
  800a9d:	78 2b                	js     800aca <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a9f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800aa6:	00 
  800aa7:	89 1c 24             	mov    %ebx,(%esp)
  800aaa:	e8 2c 0e 00 00       	call   8018db <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800aaf:	a1 80 50 80 00       	mov    0x805080,%eax
  800ab4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800aba:	a1 84 50 80 00       	mov    0x805084,%eax
  800abf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ac5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aca:	83 c4 14             	add    $0x14,%esp
  800acd:	5b                   	pop    %ebx
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <devfile_flush>:
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad9:	8b 40 0c             	mov    0xc(%eax),%eax
  800adc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ae1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae6:	b8 06 00 00 00       	mov    $0x6,%eax
  800aeb:	e8 1f ff ff ff       	call   800a0f <fsipc>
}
  800af0:	c9                   	leave  
  800af1:	c3                   	ret    

00800af2 <devfile_read>:
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	56                   	push   %esi
  800af6:	53                   	push   %ebx
  800af7:	83 ec 10             	sub    $0x10,%esp
  800afa:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	8b 40 0c             	mov    0xc(%eax),%eax
  800b03:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b08:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b13:	b8 03 00 00 00       	mov    $0x3,%eax
  800b18:	e8 f2 fe ff ff       	call   800a0f <fsipc>
  800b1d:	89 c3                	mov    %eax,%ebx
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	78 6a                	js     800b8d <devfile_read+0x9b>
	assert(r <= n);
  800b23:	39 c6                	cmp    %eax,%esi
  800b25:	73 24                	jae    800b4b <devfile_read+0x59>
  800b27:	c7 44 24 0c 32 21 80 	movl   $0x802132,0xc(%esp)
  800b2e:	00 
  800b2f:	c7 44 24 08 39 21 80 	movl   $0x802139,0x8(%esp)
  800b36:	00 
  800b37:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  800b3e:	00 
  800b3f:	c7 04 24 4e 21 80 00 	movl   $0x80214e,(%esp)
  800b46:	e8 3b 06 00 00       	call   801186 <_panic>
	assert(r <= PGSIZE);
  800b4b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b50:	7e 24                	jle    800b76 <devfile_read+0x84>
  800b52:	c7 44 24 0c 59 21 80 	movl   $0x802159,0xc(%esp)
  800b59:	00 
  800b5a:	c7 44 24 08 39 21 80 	movl   $0x802139,0x8(%esp)
  800b61:	00 
  800b62:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  800b69:	00 
  800b6a:	c7 04 24 4e 21 80 00 	movl   $0x80214e,(%esp)
  800b71:	e8 10 06 00 00       	call   801186 <_panic>
	memmove(buf, &fsipcbuf, r);
  800b76:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b7a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b81:	00 
  800b82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b85:	89 04 24             	mov    %eax,(%esp)
  800b88:	e8 49 0f 00 00       	call   801ad6 <memmove>
}
  800b8d:	89 d8                	mov    %ebx,%eax
  800b8f:	83 c4 10             	add    $0x10,%esp
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <open>:
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	53                   	push   %ebx
  800b9a:	83 ec 24             	sub    $0x24,%esp
  800b9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800ba0:	89 1c 24             	mov    %ebx,(%esp)
  800ba3:	e8 d8 0c 00 00       	call   801880 <strlen>
  800ba8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bad:	7f 60                	jg     800c0f <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  800baf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bb2:	89 04 24             	mov    %eax,(%esp)
  800bb5:	e8 4d f8 ff ff       	call   800407 <fd_alloc>
  800bba:	89 c2                	mov    %eax,%edx
  800bbc:	85 d2                	test   %edx,%edx
  800bbe:	78 54                	js     800c14 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  800bc0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bc4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800bcb:	e8 0b 0d 00 00       	call   8018db <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bdb:	b8 01 00 00 00       	mov    $0x1,%eax
  800be0:	e8 2a fe ff ff       	call   800a0f <fsipc>
  800be5:	89 c3                	mov    %eax,%ebx
  800be7:	85 c0                	test   %eax,%eax
  800be9:	79 17                	jns    800c02 <open+0x6c>
		fd_close(fd, 0);
  800beb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800bf2:	00 
  800bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf6:	89 04 24             	mov    %eax,(%esp)
  800bf9:	e8 44 f9 ff ff       	call   800542 <fd_close>
		return r;
  800bfe:	89 d8                	mov    %ebx,%eax
  800c00:	eb 12                	jmp    800c14 <open+0x7e>
	return fd2num(fd);
  800c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c05:	89 04 24             	mov    %eax,(%esp)
  800c08:	e8 d3 f7 ff ff       	call   8003e0 <fd2num>
  800c0d:	eb 05                	jmp    800c14 <open+0x7e>
		return -E_BAD_PATH;
  800c0f:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  800c14:	83 c4 24             	add    $0x24,%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    
  800c1a:	66 90                	xchg   %ax,%ax
  800c1c:	66 90                	xchg   %ax,%ax
  800c1e:	66 90                	xchg   %ax,%ax

00800c20 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	83 ec 10             	sub    $0x10,%esp
  800c28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2e:	89 04 24             	mov    %eax,(%esp)
  800c31:	e8 ba f7 ff ff       	call   8003f0 <fd2data>
  800c36:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800c38:	c7 44 24 04 65 21 80 	movl   $0x802165,0x4(%esp)
  800c3f:	00 
  800c40:	89 1c 24             	mov    %ebx,(%esp)
  800c43:	e8 93 0c 00 00       	call   8018db <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c48:	8b 46 04             	mov    0x4(%esi),%eax
  800c4b:	2b 06                	sub    (%esi),%eax
  800c4d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c53:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c5a:	00 00 00 
	stat->st_dev = &devpipe;
  800c5d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c64:	30 80 00 
	return 0;
}
  800c67:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6c:	83 c4 10             	add    $0x10,%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	53                   	push   %ebx
  800c77:	83 ec 14             	sub    $0x14,%esp
  800c7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c7d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c88:	e8 8a f5 ff ff       	call   800217 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c8d:	89 1c 24             	mov    %ebx,(%esp)
  800c90:	e8 5b f7 ff ff       	call   8003f0 <fd2data>
  800c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ca0:	e8 72 f5 ff ff       	call   800217 <sys_page_unmap>
}
  800ca5:	83 c4 14             	add    $0x14,%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <_pipeisclosed>:
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 2c             	sub    $0x2c,%esp
  800cb4:	89 c6                	mov    %eax,%esi
  800cb6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  800cb9:	a1 04 40 80 00       	mov    0x804004,%eax
  800cbe:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800cc1:	89 34 24             	mov    %esi,(%esp)
  800cc4:	e8 df 10 00 00       	call   801da8 <pageref>
  800cc9:	89 c7                	mov    %eax,%edi
  800ccb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cce:	89 04 24             	mov    %eax,(%esp)
  800cd1:	e8 d2 10 00 00       	call   801da8 <pageref>
  800cd6:	39 c7                	cmp    %eax,%edi
  800cd8:	0f 94 c2             	sete   %dl
  800cdb:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800cde:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800ce4:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800ce7:	39 fb                	cmp    %edi,%ebx
  800ce9:	74 21                	je     800d0c <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  800ceb:	84 d2                	test   %dl,%dl
  800ced:	74 ca                	je     800cb9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800cef:	8b 51 58             	mov    0x58(%ecx),%edx
  800cf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cf6:	89 54 24 08          	mov    %edx,0x8(%esp)
  800cfa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cfe:	c7 04 24 6c 21 80 00 	movl   $0x80216c,(%esp)
  800d05:	e8 75 05 00 00       	call   80127f <cprintf>
  800d0a:	eb ad                	jmp    800cb9 <_pipeisclosed+0xe>
}
  800d0c:	83 c4 2c             	add    $0x2c,%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <devpipe_write>:
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 1c             	sub    $0x1c,%esp
  800d1d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800d20:	89 34 24             	mov    %esi,(%esp)
  800d23:	e8 c8 f6 ff ff       	call   8003f0 <fd2data>
	for (i = 0; i < n; i++) {
  800d28:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d2c:	74 61                	je     800d8f <devpipe_write+0x7b>
  800d2e:	89 c3                	mov    %eax,%ebx
  800d30:	bf 00 00 00 00       	mov    $0x0,%edi
  800d35:	eb 4a                	jmp    800d81 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  800d37:	89 da                	mov    %ebx,%edx
  800d39:	89 f0                	mov    %esi,%eax
  800d3b:	e8 6b ff ff ff       	call   800cab <_pipeisclosed>
  800d40:	85 c0                	test   %eax,%eax
  800d42:	75 54                	jne    800d98 <devpipe_write+0x84>
			sys_yield();
  800d44:	e8 08 f4 ff ff       	call   800151 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d49:	8b 43 04             	mov    0x4(%ebx),%eax
  800d4c:	8b 0b                	mov    (%ebx),%ecx
  800d4e:	8d 51 20             	lea    0x20(%ecx),%edx
  800d51:	39 d0                	cmp    %edx,%eax
  800d53:	73 e2                	jae    800d37 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d5c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d5f:	99                   	cltd   
  800d60:	c1 ea 1b             	shr    $0x1b,%edx
  800d63:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800d66:	83 e1 1f             	and    $0x1f,%ecx
  800d69:	29 d1                	sub    %edx,%ecx
  800d6b:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800d6f:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  800d73:	83 c0 01             	add    $0x1,%eax
  800d76:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d79:	83 c7 01             	add    $0x1,%edi
  800d7c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d7f:	74 13                	je     800d94 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d81:	8b 43 04             	mov    0x4(%ebx),%eax
  800d84:	8b 0b                	mov    (%ebx),%ecx
  800d86:	8d 51 20             	lea    0x20(%ecx),%edx
  800d89:	39 d0                	cmp    %edx,%eax
  800d8b:	73 aa                	jae    800d37 <devpipe_write+0x23>
  800d8d:	eb c6                	jmp    800d55 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  800d8f:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  800d94:	89 f8                	mov    %edi,%eax
  800d96:	eb 05                	jmp    800d9d <devpipe_write+0x89>
				return 0;
  800d98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d9d:	83 c4 1c             	add    $0x1c,%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <devpipe_read>:
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 1c             	sub    $0x1c,%esp
  800dae:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800db1:	89 3c 24             	mov    %edi,(%esp)
  800db4:	e8 37 f6 ff ff       	call   8003f0 <fd2data>
	for (i = 0; i < n; i++) {
  800db9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dbd:	74 54                	je     800e13 <devpipe_read+0x6e>
  800dbf:	89 c3                	mov    %eax,%ebx
  800dc1:	be 00 00 00 00       	mov    $0x0,%esi
  800dc6:	eb 3e                	jmp    800e06 <devpipe_read+0x61>
				return i;
  800dc8:	89 f0                	mov    %esi,%eax
  800dca:	eb 55                	jmp    800e21 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  800dcc:	89 da                	mov    %ebx,%edx
  800dce:	89 f8                	mov    %edi,%eax
  800dd0:	e8 d6 fe ff ff       	call   800cab <_pipeisclosed>
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	75 43                	jne    800e1c <devpipe_read+0x77>
			sys_yield();
  800dd9:	e8 73 f3 ff ff       	call   800151 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800dde:	8b 03                	mov    (%ebx),%eax
  800de0:	3b 43 04             	cmp    0x4(%ebx),%eax
  800de3:	74 e7                	je     800dcc <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800de5:	99                   	cltd   
  800de6:	c1 ea 1b             	shr    $0x1b,%edx
  800de9:	01 d0                	add    %edx,%eax
  800deb:	83 e0 1f             	and    $0x1f,%eax
  800dee:	29 d0                	sub    %edx,%eax
  800df0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800dfb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800dfe:	83 c6 01             	add    $0x1,%esi
  800e01:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e04:	74 12                	je     800e18 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  800e06:	8b 03                	mov    (%ebx),%eax
  800e08:	3b 43 04             	cmp    0x4(%ebx),%eax
  800e0b:	75 d8                	jne    800de5 <devpipe_read+0x40>
			if (i > 0)
  800e0d:	85 f6                	test   %esi,%esi
  800e0f:	75 b7                	jne    800dc8 <devpipe_read+0x23>
  800e11:	eb b9                	jmp    800dcc <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  800e13:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  800e18:	89 f0                	mov    %esi,%eax
  800e1a:	eb 05                	jmp    800e21 <devpipe_read+0x7c>
				return 0;
  800e1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e21:	83 c4 1c             	add    $0x1c,%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <pipe>:
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800e31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e34:	89 04 24             	mov    %eax,(%esp)
  800e37:	e8 cb f5 ff ff       	call   800407 <fd_alloc>
  800e3c:	89 c2                	mov    %eax,%edx
  800e3e:	85 d2                	test   %edx,%edx
  800e40:	0f 88 4d 01 00 00    	js     800f93 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e46:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e4d:	00 
  800e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e5c:	e8 0f f3 ff ff       	call   800170 <sys_page_alloc>
  800e61:	89 c2                	mov    %eax,%edx
  800e63:	85 d2                	test   %edx,%edx
  800e65:	0f 88 28 01 00 00    	js     800f93 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  800e6b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e6e:	89 04 24             	mov    %eax,(%esp)
  800e71:	e8 91 f5 ff ff       	call   800407 <fd_alloc>
  800e76:	89 c3                	mov    %eax,%ebx
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	0f 88 fe 00 00 00    	js     800f7e <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e80:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e87:	00 
  800e88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e96:	e8 d5 f2 ff ff       	call   800170 <sys_page_alloc>
  800e9b:	89 c3                	mov    %eax,%ebx
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	0f 88 d9 00 00 00    	js     800f7e <pipe+0x155>
	va = fd2data(fd0);
  800ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea8:	89 04 24             	mov    %eax,(%esp)
  800eab:	e8 40 f5 ff ff       	call   8003f0 <fd2data>
  800eb0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800eb2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800eb9:	00 
  800eba:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ebe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ec5:	e8 a6 f2 ff ff       	call   800170 <sys_page_alloc>
  800eca:	89 c3                	mov    %eax,%ebx
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	0f 88 97 00 00 00    	js     800f6b <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ed4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed7:	89 04 24             	mov    %eax,(%esp)
  800eda:	e8 11 f5 ff ff       	call   8003f0 <fd2data>
  800edf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800ee6:	00 
  800ee7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eeb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ef2:	00 
  800ef3:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ef7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800efe:	e8 c1 f2 ff ff       	call   8001c4 <sys_page_map>
  800f03:	89 c3                	mov    %eax,%ebx
  800f05:	85 c0                	test   %eax,%eax
  800f07:	78 52                	js     800f5b <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  800f09:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f12:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f17:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800f1e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f27:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f2c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f36:	89 04 24             	mov    %eax,(%esp)
  800f39:	e8 a2 f4 ff ff       	call   8003e0 <fd2num>
  800f3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f41:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f46:	89 04 24             	mov    %eax,(%esp)
  800f49:	e8 92 f4 ff ff       	call   8003e0 <fd2num>
  800f4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f51:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800f54:	b8 00 00 00 00       	mov    $0x0,%eax
  800f59:	eb 38                	jmp    800f93 <pipe+0x16a>
	sys_page_unmap(0, va);
  800f5b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f66:	e8 ac f2 ff ff       	call   800217 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  800f6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f79:	e8 99 f2 ff ff       	call   800217 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  800f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f8c:	e8 86 f2 ff ff       	call   800217 <sys_page_unmap>
  800f91:	89 d8                	mov    %ebx,%eax
}
  800f93:	83 c4 30             	add    $0x30,%esp
  800f96:	5b                   	pop    %ebx
  800f97:	5e                   	pop    %esi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <pipeisclosed>:
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800faa:	89 04 24             	mov    %eax,(%esp)
  800fad:	e8 c9 f4 ff ff       	call   80047b <fd_lookup>
  800fb2:	89 c2                	mov    %eax,%edx
  800fb4:	85 d2                	test   %edx,%edx
  800fb6:	78 15                	js     800fcd <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  800fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fbb:	89 04 24             	mov    %eax,(%esp)
  800fbe:	e8 2d f4 ff ff       	call   8003f0 <fd2data>
	return _pipeisclosed(fd, p);
  800fc3:	89 c2                	mov    %eax,%edx
  800fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc8:	e8 de fc ff ff       	call   800cab <_pipeisclosed>
}
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    
  800fcf:	90                   	nop

00800fd0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800fd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800fe0:	c7 44 24 04 84 21 80 	movl   $0x802184,0x4(%esp)
  800fe7:	00 
  800fe8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800feb:	89 04 24             	mov    %eax,(%esp)
  800fee:	e8 e8 08 00 00       	call   8018db <strcpy>
	return 0;
}
  800ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff8:	c9                   	leave  
  800ff9:	c3                   	ret    

00800ffa <devcons_write>:
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	57                   	push   %edi
  800ffe:	56                   	push   %esi
  800fff:	53                   	push   %ebx
  801000:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  801006:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80100a:	74 4a                	je     801056 <devcons_write+0x5c>
  80100c:	b8 00 00 00 00       	mov    $0x0,%eax
  801011:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801016:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  80101c:	8b 75 10             	mov    0x10(%ebp),%esi
  80101f:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  801021:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801024:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801029:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80102c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801030:	03 45 0c             	add    0xc(%ebp),%eax
  801033:	89 44 24 04          	mov    %eax,0x4(%esp)
  801037:	89 3c 24             	mov    %edi,(%esp)
  80103a:	e8 97 0a 00 00       	call   801ad6 <memmove>
		sys_cputs(buf, m);
  80103f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801043:	89 3c 24             	mov    %edi,(%esp)
  801046:	e8 58 f0 ff ff       	call   8000a3 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80104b:	01 f3                	add    %esi,%ebx
  80104d:	89 d8                	mov    %ebx,%eax
  80104f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801052:	72 c8                	jb     80101c <devcons_write+0x22>
  801054:	eb 05                	jmp    80105b <devcons_write+0x61>
  801056:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  80105b:	89 d8                	mov    %ebx,%eax
  80105d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801063:	5b                   	pop    %ebx
  801064:	5e                   	pop    %esi
  801065:	5f                   	pop    %edi
  801066:	5d                   	pop    %ebp
  801067:	c3                   	ret    

00801068 <devcons_read>:
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80106e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801073:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801077:	75 07                	jne    801080 <devcons_read+0x18>
  801079:	eb 28                	jmp    8010a3 <devcons_read+0x3b>
		sys_yield();
  80107b:	e8 d1 f0 ff ff       	call   800151 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801080:	e8 3c f0 ff ff       	call   8000c1 <sys_cgetc>
  801085:	85 c0                	test   %eax,%eax
  801087:	74 f2                	je     80107b <devcons_read+0x13>
	if (c < 0)
  801089:	85 c0                	test   %eax,%eax
  80108b:	78 16                	js     8010a3 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  80108d:	83 f8 04             	cmp    $0x4,%eax
  801090:	74 0c                	je     80109e <devcons_read+0x36>
	*(char*)vbuf = c;
  801092:	8b 55 0c             	mov    0xc(%ebp),%edx
  801095:	88 02                	mov    %al,(%edx)
	return 1;
  801097:	b8 01 00 00 00       	mov    $0x1,%eax
  80109c:	eb 05                	jmp    8010a3 <devcons_read+0x3b>
		return 0;
  80109e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010a3:	c9                   	leave  
  8010a4:	c3                   	ret    

008010a5 <cputchar>:
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8010ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ae:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8010b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010b8:	00 
  8010b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010bc:	89 04 24             	mov    %eax,(%esp)
  8010bf:	e8 df ef ff ff       	call   8000a3 <sys_cputs>
}
  8010c4:	c9                   	leave  
  8010c5:	c3                   	ret    

008010c6 <getchar>:
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  8010cc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010d3:	00 
  8010d4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e2:	e8 3f f6 ff ff       	call   800726 <read>
	if (r < 0)
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 0f                	js     8010fa <getchar+0x34>
	if (r < 1)
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	7e 06                	jle    8010f5 <getchar+0x2f>
	return c;
  8010ef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010f3:	eb 05                	jmp    8010fa <getchar+0x34>
		return -E_EOF;
  8010f5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  8010fa:	c9                   	leave  
  8010fb:	c3                   	ret    

008010fc <iscons>:
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801102:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801105:	89 44 24 04          	mov    %eax,0x4(%esp)
  801109:	8b 45 08             	mov    0x8(%ebp),%eax
  80110c:	89 04 24             	mov    %eax,(%esp)
  80110f:	e8 67 f3 ff ff       	call   80047b <fd_lookup>
  801114:	85 c0                	test   %eax,%eax
  801116:	78 11                	js     801129 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801118:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801121:	39 10                	cmp    %edx,(%eax)
  801123:	0f 94 c0             	sete   %al
  801126:	0f b6 c0             	movzbl %al,%eax
}
  801129:	c9                   	leave  
  80112a:	c3                   	ret    

0080112b <opencons>:
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801131:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801134:	89 04 24             	mov    %eax,(%esp)
  801137:	e8 cb f2 ff ff       	call   800407 <fd_alloc>
		return r;
  80113c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 40                	js     801182 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801142:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801149:	00 
  80114a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801151:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801158:	e8 13 f0 ff ff       	call   800170 <sys_page_alloc>
		return r;
  80115d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80115f:	85 c0                	test   %eax,%eax
  801161:	78 1f                	js     801182 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801163:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801169:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80116e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801171:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801178:	89 04 24             	mov    %eax,(%esp)
  80117b:	e8 60 f2 ff ff       	call   8003e0 <fd2num>
  801180:	89 c2                	mov    %eax,%edx
}
  801182:	89 d0                	mov    %edx,%eax
  801184:	c9                   	leave  
  801185:	c3                   	ret    

00801186 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	56                   	push   %esi
  80118a:	53                   	push   %ebx
  80118b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80118e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801191:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801197:	e8 96 ef ff ff       	call   800132 <sys_getenvid>
  80119c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80119f:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011aa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8011ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b2:	c7 04 24 90 21 80 00 	movl   $0x802190,(%esp)
  8011b9:	e8 c1 00 00 00       	call   80127f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c5:	89 04 24             	mov    %eax,(%esp)
  8011c8:	e8 51 00 00 00       	call   80121e <vcprintf>
	cprintf("\n");
  8011cd:	c7 04 24 7d 21 80 00 	movl   $0x80217d,(%esp)
  8011d4:	e8 a6 00 00 00       	call   80127f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011d9:	cc                   	int3   
  8011da:	eb fd                	jmp    8011d9 <_panic+0x53>

008011dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 14             	sub    $0x14,%esp
  8011e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8011e6:	8b 13                	mov    (%ebx),%edx
  8011e8:	8d 42 01             	lea    0x1(%edx),%eax
  8011eb:	89 03                	mov    %eax,(%ebx)
  8011ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8011f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011f9:	75 19                	jne    801214 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8011fb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801202:	00 
  801203:	8d 43 08             	lea    0x8(%ebx),%eax
  801206:	89 04 24             	mov    %eax,(%esp)
  801209:	e8 95 ee ff ff       	call   8000a3 <sys_cputs>
		b->idx = 0;
  80120e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801214:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801218:	83 c4 14             	add    $0x14,%esp
  80121b:	5b                   	pop    %ebx
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    

0080121e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801227:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80122e:	00 00 00 
	b.cnt = 0;
  801231:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801238:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80123b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801242:	8b 45 08             	mov    0x8(%ebp),%eax
  801245:	89 44 24 08          	mov    %eax,0x8(%esp)
  801249:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80124f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801253:	c7 04 24 dc 11 80 00 	movl   $0x8011dc,(%esp)
  80125a:	e8 b5 01 00 00       	call   801414 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80125f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801265:	89 44 24 04          	mov    %eax,0x4(%esp)
  801269:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80126f:	89 04 24             	mov    %eax,(%esp)
  801272:	e8 2c ee ff ff       	call   8000a3 <sys_cputs>

	return b.cnt;
}
  801277:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80127d:	c9                   	leave  
  80127e:	c3                   	ret    

0080127f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801285:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128c:	8b 45 08             	mov    0x8(%ebp),%eax
  80128f:	89 04 24             	mov    %eax,(%esp)
  801292:	e8 87 ff ff ff       	call   80121e <vcprintf>
	va_end(ap);

	return cnt;
}
  801297:	c9                   	leave  
  801298:	c3                   	ret    
  801299:	66 90                	xchg   %ax,%ax
  80129b:	66 90                	xchg   %ax,%ax
  80129d:	66 90                	xchg   %ax,%ax
  80129f:	90                   	nop

008012a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	57                   	push   %edi
  8012a4:	56                   	push   %esi
  8012a5:	53                   	push   %ebx
  8012a6:	83 ec 3c             	sub    $0x3c,%esp
  8012a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ac:	89 d7                	mov    %edx,%edi
  8012ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012b7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8012ba:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8012bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8012c8:	39 f1                	cmp    %esi,%ecx
  8012ca:	72 14                	jb     8012e0 <printnum+0x40>
  8012cc:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8012cf:	76 0f                	jbe    8012e0 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8012d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d4:	8d 70 ff             	lea    -0x1(%eax),%esi
  8012d7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8012da:	85 f6                	test   %esi,%esi
  8012dc:	7f 60                	jg     80133e <printnum+0x9e>
  8012de:	eb 72                	jmp    801352 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8012e0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8012e3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012e7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8012ea:	8d 51 ff             	lea    -0x1(%ecx),%edx
  8012ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f5:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012f9:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8012fd:	89 c3                	mov    %eax,%ebx
  8012ff:	89 d6                	mov    %edx,%esi
  801301:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801304:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801307:	89 54 24 08          	mov    %edx,0x8(%esp)
  80130b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80130f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801312:	89 04 24             	mov    %eax,(%esp)
  801315:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801318:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131c:	e8 cf 0a 00 00       	call   801df0 <__udivdi3>
  801321:	89 d9                	mov    %ebx,%ecx
  801323:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801327:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80132b:	89 04 24             	mov    %eax,(%esp)
  80132e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801332:	89 fa                	mov    %edi,%edx
  801334:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801337:	e8 64 ff ff ff       	call   8012a0 <printnum>
  80133c:	eb 14                	jmp    801352 <printnum+0xb2>
			putch(padc, putdat);
  80133e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801342:	8b 45 18             	mov    0x18(%ebp),%eax
  801345:	89 04 24             	mov    %eax,(%esp)
  801348:	ff d3                	call   *%ebx
		while (--width > 0)
  80134a:	83 ee 01             	sub    $0x1,%esi
  80134d:	75 ef                	jne    80133e <printnum+0x9e>
  80134f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801352:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801356:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80135a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80135d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801360:	89 44 24 08          	mov    %eax,0x8(%esp)
  801364:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801368:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80136b:	89 04 24             	mov    %eax,(%esp)
  80136e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801371:	89 44 24 04          	mov    %eax,0x4(%esp)
  801375:	e8 a6 0b 00 00       	call   801f20 <__umoddi3>
  80137a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80137e:	0f be 80 b3 21 80 00 	movsbl 0x8021b3(%eax),%eax
  801385:	89 04 24             	mov    %eax,(%esp)
  801388:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80138b:	ff d0                	call   *%eax
}
  80138d:	83 c4 3c             	add    $0x3c,%esp
  801390:	5b                   	pop    %ebx
  801391:	5e                   	pop    %esi
  801392:	5f                   	pop    %edi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    

00801395 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801398:	83 fa 01             	cmp    $0x1,%edx
  80139b:	7e 0e                	jle    8013ab <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80139d:	8b 10                	mov    (%eax),%edx
  80139f:	8d 4a 08             	lea    0x8(%edx),%ecx
  8013a2:	89 08                	mov    %ecx,(%eax)
  8013a4:	8b 02                	mov    (%edx),%eax
  8013a6:	8b 52 04             	mov    0x4(%edx),%edx
  8013a9:	eb 22                	jmp    8013cd <getuint+0x38>
	else if (lflag)
  8013ab:	85 d2                	test   %edx,%edx
  8013ad:	74 10                	je     8013bf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8013af:	8b 10                	mov    (%eax),%edx
  8013b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013b4:	89 08                	mov    %ecx,(%eax)
  8013b6:	8b 02                	mov    (%edx),%eax
  8013b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bd:	eb 0e                	jmp    8013cd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8013bf:	8b 10                	mov    (%eax),%edx
  8013c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013c4:	89 08                	mov    %ecx,(%eax)
  8013c6:	8b 02                	mov    (%edx),%eax
  8013c8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    

008013cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8013d5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8013d9:	8b 10                	mov    (%eax),%edx
  8013db:	3b 50 04             	cmp    0x4(%eax),%edx
  8013de:	73 0a                	jae    8013ea <sprintputch+0x1b>
		*b->buf++ = ch;
  8013e0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8013e3:	89 08                	mov    %ecx,(%eax)
  8013e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e8:	88 02                	mov    %al,(%edx)
}
  8013ea:	5d                   	pop    %ebp
  8013eb:	c3                   	ret    

008013ec <printfmt>:
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8013f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8013f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8013fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801400:	8b 45 0c             	mov    0xc(%ebp),%eax
  801403:	89 44 24 04          	mov    %eax,0x4(%esp)
  801407:	8b 45 08             	mov    0x8(%ebp),%eax
  80140a:	89 04 24             	mov    %eax,(%esp)
  80140d:	e8 02 00 00 00       	call   801414 <vprintfmt>
}
  801412:	c9                   	leave  
  801413:	c3                   	ret    

00801414 <vprintfmt>:
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	57                   	push   %edi
  801418:	56                   	push   %esi
  801419:	53                   	push   %ebx
  80141a:	83 ec 3c             	sub    $0x3c,%esp
  80141d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801420:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801423:	eb 18                	jmp    80143d <vprintfmt+0x29>
			if (ch == '\0')
  801425:	85 c0                	test   %eax,%eax
  801427:	0f 84 c3 03 00 00    	je     8017f0 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80142d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801431:	89 04 24             	mov    %eax,(%esp)
  801434:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801437:	89 f3                	mov    %esi,%ebx
  801439:	eb 02                	jmp    80143d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80143b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80143d:	8d 73 01             	lea    0x1(%ebx),%esi
  801440:	0f b6 03             	movzbl (%ebx),%eax
  801443:	83 f8 25             	cmp    $0x25,%eax
  801446:	75 dd                	jne    801425 <vprintfmt+0x11>
  801448:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80144c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801453:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80145a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801461:	ba 00 00 00 00       	mov    $0x0,%edx
  801466:	eb 1d                	jmp    801485 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  801468:	89 de                	mov    %ebx,%esi
			padc = '-';
  80146a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80146e:	eb 15                	jmp    801485 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  801470:	89 de                	mov    %ebx,%esi
			padc = '0';
  801472:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  801476:	eb 0d                	jmp    801485 <vprintfmt+0x71>
				width = precision, precision = -1;
  801478:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80147b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80147e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801485:	8d 5e 01             	lea    0x1(%esi),%ebx
  801488:	0f b6 06             	movzbl (%esi),%eax
  80148b:	0f b6 c8             	movzbl %al,%ecx
  80148e:	83 e8 23             	sub    $0x23,%eax
  801491:	3c 55                	cmp    $0x55,%al
  801493:	0f 87 2f 03 00 00    	ja     8017c8 <vprintfmt+0x3b4>
  801499:	0f b6 c0             	movzbl %al,%eax
  80149c:	ff 24 85 00 23 80 00 	jmp    *0x802300(,%eax,4)
				precision = precision * 10 + ch - '0';
  8014a3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8014a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  8014a9:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8014ad:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8014b0:	83 f9 09             	cmp    $0x9,%ecx
  8014b3:	77 50                	ja     801505 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8014b5:	89 de                	mov    %ebx,%esi
  8014b7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8014ba:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8014bd:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8014c0:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8014c4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8014c7:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8014ca:	83 fb 09             	cmp    $0x9,%ebx
  8014cd:	76 eb                	jbe    8014ba <vprintfmt+0xa6>
  8014cf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8014d2:	eb 33                	jmp    801507 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  8014d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d7:	8d 48 04             	lea    0x4(%eax),%ecx
  8014da:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8014dd:	8b 00                	mov    (%eax),%eax
  8014df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8014e2:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8014e4:	eb 21                	jmp    801507 <vprintfmt+0xf3>
  8014e6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8014e9:	85 c9                	test   %ecx,%ecx
  8014eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f0:	0f 49 c1             	cmovns %ecx,%eax
  8014f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8014f6:	89 de                	mov    %ebx,%esi
  8014f8:	eb 8b                	jmp    801485 <vprintfmt+0x71>
  8014fa:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8014fc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801503:	eb 80                	jmp    801485 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  801505:	89 de                	mov    %ebx,%esi
			if (width < 0)
  801507:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80150b:	0f 89 74 ff ff ff    	jns    801485 <vprintfmt+0x71>
  801511:	e9 62 ff ff ff       	jmp    801478 <vprintfmt+0x64>
			lflag++;
  801516:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  801519:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80151b:	e9 65 ff ff ff       	jmp    801485 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  801520:	8b 45 14             	mov    0x14(%ebp),%eax
  801523:	8d 50 04             	lea    0x4(%eax),%edx
  801526:	89 55 14             	mov    %edx,0x14(%ebp)
  801529:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80152d:	8b 00                	mov    (%eax),%eax
  80152f:	89 04 24             	mov    %eax,(%esp)
  801532:	ff 55 08             	call   *0x8(%ebp)
			break;
  801535:	e9 03 ff ff ff       	jmp    80143d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80153a:	8b 45 14             	mov    0x14(%ebp),%eax
  80153d:	8d 50 04             	lea    0x4(%eax),%edx
  801540:	89 55 14             	mov    %edx,0x14(%ebp)
  801543:	8b 00                	mov    (%eax),%eax
  801545:	99                   	cltd   
  801546:	31 d0                	xor    %edx,%eax
  801548:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80154a:	83 f8 0f             	cmp    $0xf,%eax
  80154d:	7f 0b                	jg     80155a <vprintfmt+0x146>
  80154f:	8b 14 85 60 24 80 00 	mov    0x802460(,%eax,4),%edx
  801556:	85 d2                	test   %edx,%edx
  801558:	75 20                	jne    80157a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80155a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80155e:	c7 44 24 08 cb 21 80 	movl   $0x8021cb,0x8(%esp)
  801565:	00 
  801566:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80156a:	8b 45 08             	mov    0x8(%ebp),%eax
  80156d:	89 04 24             	mov    %eax,(%esp)
  801570:	e8 77 fe ff ff       	call   8013ec <printfmt>
  801575:	e9 c3 fe ff ff       	jmp    80143d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80157a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80157e:	c7 44 24 08 4b 21 80 	movl   $0x80214b,0x8(%esp)
  801585:	00 
  801586:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80158a:	8b 45 08             	mov    0x8(%ebp),%eax
  80158d:	89 04 24             	mov    %eax,(%esp)
  801590:	e8 57 fe ff ff       	call   8013ec <printfmt>
  801595:	e9 a3 fe ff ff       	jmp    80143d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  80159a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80159d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  8015a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a3:	8d 50 04             	lea    0x4(%eax),%edx
  8015a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8015a9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	ba c4 21 80 00       	mov    $0x8021c4,%edx
  8015b2:	0f 45 d0             	cmovne %eax,%edx
  8015b5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8015b8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8015bc:	74 04                	je     8015c2 <vprintfmt+0x1ae>
  8015be:	85 f6                	test   %esi,%esi
  8015c0:	7f 19                	jg     8015db <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8015c5:	8d 70 01             	lea    0x1(%eax),%esi
  8015c8:	0f b6 10             	movzbl (%eax),%edx
  8015cb:	0f be c2             	movsbl %dl,%eax
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	0f 85 95 00 00 00    	jne    80166b <vprintfmt+0x257>
  8015d6:	e9 85 00 00 00       	jmp    801660 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8015db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015df:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8015e2:	89 04 24             	mov    %eax,(%esp)
  8015e5:	e8 b8 02 00 00       	call   8018a2 <strnlen>
  8015ea:	29 c6                	sub    %eax,%esi
  8015ec:	89 f0                	mov    %esi,%eax
  8015ee:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8015f1:	85 f6                	test   %esi,%esi
  8015f3:	7e cd                	jle    8015c2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8015f5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8015f9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8015fc:	89 c3                	mov    %eax,%ebx
  8015fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801602:	89 34 24             	mov    %esi,(%esp)
  801605:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801608:	83 eb 01             	sub    $0x1,%ebx
  80160b:	75 f1                	jne    8015fe <vprintfmt+0x1ea>
  80160d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801610:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801613:	eb ad                	jmp    8015c2 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  801615:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801619:	74 1e                	je     801639 <vprintfmt+0x225>
  80161b:	0f be d2             	movsbl %dl,%edx
  80161e:	83 ea 20             	sub    $0x20,%edx
  801621:	83 fa 5e             	cmp    $0x5e,%edx
  801624:	76 13                	jbe    801639 <vprintfmt+0x225>
					putch('?', putdat);
  801626:	8b 45 0c             	mov    0xc(%ebp),%eax
  801629:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801634:	ff 55 08             	call   *0x8(%ebp)
  801637:	eb 0d                	jmp    801646 <vprintfmt+0x232>
					putch(ch, putdat);
  801639:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80163c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801640:	89 04 24             	mov    %eax,(%esp)
  801643:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801646:	83 ef 01             	sub    $0x1,%edi
  801649:	83 c6 01             	add    $0x1,%esi
  80164c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  801650:	0f be c2             	movsbl %dl,%eax
  801653:	85 c0                	test   %eax,%eax
  801655:	75 20                	jne    801677 <vprintfmt+0x263>
  801657:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80165a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80165d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  801660:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801664:	7f 25                	jg     80168b <vprintfmt+0x277>
  801666:	e9 d2 fd ff ff       	jmp    80143d <vprintfmt+0x29>
  80166b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80166e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801671:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801674:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801677:	85 db                	test   %ebx,%ebx
  801679:	78 9a                	js     801615 <vprintfmt+0x201>
  80167b:	83 eb 01             	sub    $0x1,%ebx
  80167e:	79 95                	jns    801615 <vprintfmt+0x201>
  801680:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801683:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801686:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801689:	eb d5                	jmp    801660 <vprintfmt+0x24c>
  80168b:	8b 75 08             	mov    0x8(%ebp),%esi
  80168e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801691:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  801694:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801698:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80169f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8016a1:	83 eb 01             	sub    $0x1,%ebx
  8016a4:	75 ee                	jne    801694 <vprintfmt+0x280>
  8016a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016a9:	e9 8f fd ff ff       	jmp    80143d <vprintfmt+0x29>
	if (lflag >= 2)
  8016ae:	83 fa 01             	cmp    $0x1,%edx
  8016b1:	7e 16                	jle    8016c9 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8016b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b6:	8d 50 08             	lea    0x8(%eax),%edx
  8016b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8016bc:	8b 50 04             	mov    0x4(%eax),%edx
  8016bf:	8b 00                	mov    (%eax),%eax
  8016c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8016c7:	eb 32                	jmp    8016fb <vprintfmt+0x2e7>
	else if (lflag)
  8016c9:	85 d2                	test   %edx,%edx
  8016cb:	74 18                	je     8016e5 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8016cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d0:	8d 50 04             	lea    0x4(%eax),%edx
  8016d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8016d6:	8b 30                	mov    (%eax),%esi
  8016d8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8016db:	89 f0                	mov    %esi,%eax
  8016dd:	c1 f8 1f             	sar    $0x1f,%eax
  8016e0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8016e3:	eb 16                	jmp    8016fb <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  8016e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8016e8:	8d 50 04             	lea    0x4(%eax),%edx
  8016eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8016ee:	8b 30                	mov    (%eax),%esi
  8016f0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8016f3:	89 f0                	mov    %esi,%eax
  8016f5:	c1 f8 1f             	sar    $0x1f,%eax
  8016f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  8016fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8016fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  801701:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  801706:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80170a:	0f 89 80 00 00 00    	jns    801790 <vprintfmt+0x37c>
				putch('-', putdat);
  801710:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801714:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80171b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80171e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801721:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801724:	f7 d8                	neg    %eax
  801726:	83 d2 00             	adc    $0x0,%edx
  801729:	f7 da                	neg    %edx
			base = 10;
  80172b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801730:	eb 5e                	jmp    801790 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  801732:	8d 45 14             	lea    0x14(%ebp),%eax
  801735:	e8 5b fc ff ff       	call   801395 <getuint>
			base = 10;
  80173a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80173f:	eb 4f                	jmp    801790 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  801741:	8d 45 14             	lea    0x14(%ebp),%eax
  801744:	e8 4c fc ff ff       	call   801395 <getuint>
			base = 8;
  801749:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80174e:	eb 40                	jmp    801790 <vprintfmt+0x37c>
			putch('0', putdat);
  801750:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801754:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80175b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80175e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801762:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801769:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80176c:	8b 45 14             	mov    0x14(%ebp),%eax
  80176f:	8d 50 04             	lea    0x4(%eax),%edx
  801772:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  801775:	8b 00                	mov    (%eax),%eax
  801777:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80177c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801781:	eb 0d                	jmp    801790 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  801783:	8d 45 14             	lea    0x14(%ebp),%eax
  801786:	e8 0a fc ff ff       	call   801395 <getuint>
			base = 16;
  80178b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  801790:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  801794:	89 74 24 10          	mov    %esi,0x10(%esp)
  801798:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80179b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80179f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017a3:	89 04 24             	mov    %eax,(%esp)
  8017a6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017aa:	89 fa                	mov    %edi,%edx
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	e8 ec fa ff ff       	call   8012a0 <printnum>
			break;
  8017b4:	e9 84 fc ff ff       	jmp    80143d <vprintfmt+0x29>
			putch(ch, putdat);
  8017b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017bd:	89 0c 24             	mov    %ecx,(%esp)
  8017c0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8017c3:	e9 75 fc ff ff       	jmp    80143d <vprintfmt+0x29>
			putch('%', putdat);
  8017c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017cc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017d3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017d6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8017da:	0f 84 5b fc ff ff    	je     80143b <vprintfmt+0x27>
  8017e0:	89 f3                	mov    %esi,%ebx
  8017e2:	83 eb 01             	sub    $0x1,%ebx
  8017e5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8017e9:	75 f7                	jne    8017e2 <vprintfmt+0x3ce>
  8017eb:	e9 4d fc ff ff       	jmp    80143d <vprintfmt+0x29>
}
  8017f0:	83 c4 3c             	add    $0x3c,%esp
  8017f3:	5b                   	pop    %ebx
  8017f4:	5e                   	pop    %esi
  8017f5:	5f                   	pop    %edi
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    

008017f8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	83 ec 28             	sub    $0x28,%esp
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801804:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801807:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80180b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80180e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801815:	85 c0                	test   %eax,%eax
  801817:	74 30                	je     801849 <vsnprintf+0x51>
  801819:	85 d2                	test   %edx,%edx
  80181b:	7e 2c                	jle    801849 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80181d:	8b 45 14             	mov    0x14(%ebp),%eax
  801820:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801824:	8b 45 10             	mov    0x10(%ebp),%eax
  801827:	89 44 24 08          	mov    %eax,0x8(%esp)
  80182b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80182e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801832:	c7 04 24 cf 13 80 00 	movl   $0x8013cf,(%esp)
  801839:	e8 d6 fb ff ff       	call   801414 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80183e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801841:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801844:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801847:	eb 05                	jmp    80184e <vsnprintf+0x56>
		return -E_INVAL;
  801849:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801856:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801859:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80185d:	8b 45 10             	mov    0x10(%ebp),%eax
  801860:	89 44 24 08          	mov    %eax,0x8(%esp)
  801864:	8b 45 0c             	mov    0xc(%ebp),%eax
  801867:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186b:	8b 45 08             	mov    0x8(%ebp),%eax
  80186e:	89 04 24             	mov    %eax,(%esp)
  801871:	e8 82 ff ff ff       	call   8017f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  801876:	c9                   	leave  
  801877:	c3                   	ret    
  801878:	66 90                	xchg   %ax,%ax
  80187a:	66 90                	xchg   %ax,%ax
  80187c:	66 90                	xchg   %ax,%ax
  80187e:	66 90                	xchg   %ax,%ax

00801880 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801886:	80 3a 00             	cmpb   $0x0,(%edx)
  801889:	74 10                	je     80189b <strlen+0x1b>
  80188b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801890:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801893:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801897:	75 f7                	jne    801890 <strlen+0x10>
  801899:	eb 05                	jmp    8018a0 <strlen+0x20>
  80189b:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8018a0:	5d                   	pop    %ebp
  8018a1:	c3                   	ret    

008018a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	53                   	push   %ebx
  8018a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8018ac:	85 c9                	test   %ecx,%ecx
  8018ae:	74 1c                	je     8018cc <strnlen+0x2a>
  8018b0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8018b3:	74 1e                	je     8018d3 <strnlen+0x31>
  8018b5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8018ba:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8018bc:	39 ca                	cmp    %ecx,%edx
  8018be:	74 18                	je     8018d8 <strnlen+0x36>
  8018c0:	83 c2 01             	add    $0x1,%edx
  8018c3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8018c8:	75 f0                	jne    8018ba <strnlen+0x18>
  8018ca:	eb 0c                	jmp    8018d8 <strnlen+0x36>
  8018cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d1:	eb 05                	jmp    8018d8 <strnlen+0x36>
  8018d3:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8018d8:	5b                   	pop    %ebx
  8018d9:	5d                   	pop    %ebp
  8018da:	c3                   	ret    

008018db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	53                   	push   %ebx
  8018df:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8018e5:	89 c2                	mov    %eax,%edx
  8018e7:	83 c2 01             	add    $0x1,%edx
  8018ea:	83 c1 01             	add    $0x1,%ecx
  8018ed:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8018f1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8018f4:	84 db                	test   %bl,%bl
  8018f6:	75 ef                	jne    8018e7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8018f8:	5b                   	pop    %ebx
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    

008018fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	53                   	push   %ebx
  8018ff:	83 ec 08             	sub    $0x8,%esp
  801902:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801905:	89 1c 24             	mov    %ebx,(%esp)
  801908:	e8 73 ff ff ff       	call   801880 <strlen>
	strcpy(dst + len, src);
  80190d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801910:	89 54 24 04          	mov    %edx,0x4(%esp)
  801914:	01 d8                	add    %ebx,%eax
  801916:	89 04 24             	mov    %eax,(%esp)
  801919:	e8 bd ff ff ff       	call   8018db <strcpy>
	return dst;
}
  80191e:	89 d8                	mov    %ebx,%eax
  801920:	83 c4 08             	add    $0x8,%esp
  801923:	5b                   	pop    %ebx
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    

00801926 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	56                   	push   %esi
  80192a:	53                   	push   %ebx
  80192b:	8b 75 08             	mov    0x8(%ebp),%esi
  80192e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801931:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801934:	85 db                	test   %ebx,%ebx
  801936:	74 17                	je     80194f <strncpy+0x29>
  801938:	01 f3                	add    %esi,%ebx
  80193a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80193c:	83 c1 01             	add    $0x1,%ecx
  80193f:	0f b6 02             	movzbl (%edx),%eax
  801942:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801945:	80 3a 01             	cmpb   $0x1,(%edx)
  801948:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80194b:	39 d9                	cmp    %ebx,%ecx
  80194d:	75 ed                	jne    80193c <strncpy+0x16>
	}
	return ret;
}
  80194f:	89 f0                	mov    %esi,%eax
  801951:	5b                   	pop    %ebx
  801952:	5e                   	pop    %esi
  801953:	5d                   	pop    %ebp
  801954:	c3                   	ret    

00801955 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	57                   	push   %edi
  801959:	56                   	push   %esi
  80195a:	53                   	push   %ebx
  80195b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80195e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801961:	8b 75 10             	mov    0x10(%ebp),%esi
  801964:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801966:	85 f6                	test   %esi,%esi
  801968:	74 34                	je     80199e <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  80196a:	83 fe 01             	cmp    $0x1,%esi
  80196d:	74 26                	je     801995 <strlcpy+0x40>
  80196f:	0f b6 0b             	movzbl (%ebx),%ecx
  801972:	84 c9                	test   %cl,%cl
  801974:	74 23                	je     801999 <strlcpy+0x44>
  801976:	83 ee 02             	sub    $0x2,%esi
  801979:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  80197e:	83 c0 01             	add    $0x1,%eax
  801981:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801984:	39 f2                	cmp    %esi,%edx
  801986:	74 13                	je     80199b <strlcpy+0x46>
  801988:	83 c2 01             	add    $0x1,%edx
  80198b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80198f:	84 c9                	test   %cl,%cl
  801991:	75 eb                	jne    80197e <strlcpy+0x29>
  801993:	eb 06                	jmp    80199b <strlcpy+0x46>
  801995:	89 f8                	mov    %edi,%eax
  801997:	eb 02                	jmp    80199b <strlcpy+0x46>
  801999:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  80199b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80199e:	29 f8                	sub    %edi,%eax
}
  8019a0:	5b                   	pop    %ebx
  8019a1:	5e                   	pop    %esi
  8019a2:	5f                   	pop    %edi
  8019a3:	5d                   	pop    %ebp
  8019a4:	c3                   	ret    

008019a5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8019ae:	0f b6 01             	movzbl (%ecx),%eax
  8019b1:	84 c0                	test   %al,%al
  8019b3:	74 15                	je     8019ca <strcmp+0x25>
  8019b5:	3a 02                	cmp    (%edx),%al
  8019b7:	75 11                	jne    8019ca <strcmp+0x25>
		p++, q++;
  8019b9:	83 c1 01             	add    $0x1,%ecx
  8019bc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8019bf:	0f b6 01             	movzbl (%ecx),%eax
  8019c2:	84 c0                	test   %al,%al
  8019c4:	74 04                	je     8019ca <strcmp+0x25>
  8019c6:	3a 02                	cmp    (%edx),%al
  8019c8:	74 ef                	je     8019b9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8019ca:	0f b6 c0             	movzbl %al,%eax
  8019cd:	0f b6 12             	movzbl (%edx),%edx
  8019d0:	29 d0                	sub    %edx,%eax
}
  8019d2:	5d                   	pop    %ebp
  8019d3:	c3                   	ret    

008019d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	56                   	push   %esi
  8019d8:	53                   	push   %ebx
  8019d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8019dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019df:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8019e2:	85 f6                	test   %esi,%esi
  8019e4:	74 29                	je     801a0f <strncmp+0x3b>
  8019e6:	0f b6 03             	movzbl (%ebx),%eax
  8019e9:	84 c0                	test   %al,%al
  8019eb:	74 30                	je     801a1d <strncmp+0x49>
  8019ed:	3a 02                	cmp    (%edx),%al
  8019ef:	75 2c                	jne    801a1d <strncmp+0x49>
  8019f1:	8d 43 01             	lea    0x1(%ebx),%eax
  8019f4:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8019f6:	89 c3                	mov    %eax,%ebx
  8019f8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8019fb:	39 f0                	cmp    %esi,%eax
  8019fd:	74 17                	je     801a16 <strncmp+0x42>
  8019ff:	0f b6 08             	movzbl (%eax),%ecx
  801a02:	84 c9                	test   %cl,%cl
  801a04:	74 17                	je     801a1d <strncmp+0x49>
  801a06:	83 c0 01             	add    $0x1,%eax
  801a09:	3a 0a                	cmp    (%edx),%cl
  801a0b:	74 e9                	je     8019f6 <strncmp+0x22>
  801a0d:	eb 0e                	jmp    801a1d <strncmp+0x49>
	if (n == 0)
		return 0;
  801a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a14:	eb 0f                	jmp    801a25 <strncmp+0x51>
  801a16:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1b:	eb 08                	jmp    801a25 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801a1d:	0f b6 03             	movzbl (%ebx),%eax
  801a20:	0f b6 12             	movzbl (%edx),%edx
  801a23:	29 d0                	sub    %edx,%eax
}
  801a25:	5b                   	pop    %ebx
  801a26:	5e                   	pop    %esi
  801a27:	5d                   	pop    %ebp
  801a28:	c3                   	ret    

00801a29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	53                   	push   %ebx
  801a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a30:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  801a33:	0f b6 18             	movzbl (%eax),%ebx
  801a36:	84 db                	test   %bl,%bl
  801a38:	74 1d                	je     801a57 <strchr+0x2e>
  801a3a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  801a3c:	38 d3                	cmp    %dl,%bl
  801a3e:	75 06                	jne    801a46 <strchr+0x1d>
  801a40:	eb 1a                	jmp    801a5c <strchr+0x33>
  801a42:	38 ca                	cmp    %cl,%dl
  801a44:	74 16                	je     801a5c <strchr+0x33>
	for (; *s; s++)
  801a46:	83 c0 01             	add    $0x1,%eax
  801a49:	0f b6 10             	movzbl (%eax),%edx
  801a4c:	84 d2                	test   %dl,%dl
  801a4e:	75 f2                	jne    801a42 <strchr+0x19>
			return (char *) s;
	return 0;
  801a50:	b8 00 00 00 00       	mov    $0x0,%eax
  801a55:	eb 05                	jmp    801a5c <strchr+0x33>
  801a57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a5c:	5b                   	pop    %ebx
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    

00801a5f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	53                   	push   %ebx
  801a63:	8b 45 08             	mov    0x8(%ebp),%eax
  801a66:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  801a69:	0f b6 18             	movzbl (%eax),%ebx
  801a6c:	84 db                	test   %bl,%bl
  801a6e:	74 16                	je     801a86 <strfind+0x27>
  801a70:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  801a72:	38 d3                	cmp    %dl,%bl
  801a74:	75 06                	jne    801a7c <strfind+0x1d>
  801a76:	eb 0e                	jmp    801a86 <strfind+0x27>
  801a78:	38 ca                	cmp    %cl,%dl
  801a7a:	74 0a                	je     801a86 <strfind+0x27>
	for (; *s; s++)
  801a7c:	83 c0 01             	add    $0x1,%eax
  801a7f:	0f b6 10             	movzbl (%eax),%edx
  801a82:	84 d2                	test   %dl,%dl
  801a84:	75 f2                	jne    801a78 <strfind+0x19>
			break;
	return (char *) s;
}
  801a86:	5b                   	pop    %ebx
  801a87:	5d                   	pop    %ebp
  801a88:	c3                   	ret    

00801a89 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	57                   	push   %edi
  801a8d:	56                   	push   %esi
  801a8e:	53                   	push   %ebx
  801a8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801a95:	85 c9                	test   %ecx,%ecx
  801a97:	74 36                	je     801acf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801a99:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801a9f:	75 28                	jne    801ac9 <memset+0x40>
  801aa1:	f6 c1 03             	test   $0x3,%cl
  801aa4:	75 23                	jne    801ac9 <memset+0x40>
		c &= 0xFF;
  801aa6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801aaa:	89 d3                	mov    %edx,%ebx
  801aac:	c1 e3 08             	shl    $0x8,%ebx
  801aaf:	89 d6                	mov    %edx,%esi
  801ab1:	c1 e6 18             	shl    $0x18,%esi
  801ab4:	89 d0                	mov    %edx,%eax
  801ab6:	c1 e0 10             	shl    $0x10,%eax
  801ab9:	09 f0                	or     %esi,%eax
  801abb:	09 c2                	or     %eax,%edx
  801abd:	89 d0                	mov    %edx,%eax
  801abf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801ac1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801ac4:	fc                   	cld    
  801ac5:	f3 ab                	rep stos %eax,%es:(%edi)
  801ac7:	eb 06                	jmp    801acf <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acc:	fc                   	cld    
  801acd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801acf:	89 f8                	mov    %edi,%eax
  801ad1:	5b                   	pop    %ebx
  801ad2:	5e                   	pop    %esi
  801ad3:	5f                   	pop    %edi
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	57                   	push   %edi
  801ada:	56                   	push   %esi
  801adb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ade:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ae4:	39 c6                	cmp    %eax,%esi
  801ae6:	73 35                	jae    801b1d <memmove+0x47>
  801ae8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801aeb:	39 d0                	cmp    %edx,%eax
  801aed:	73 2e                	jae    801b1d <memmove+0x47>
		s += n;
		d += n;
  801aef:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801af2:	89 d6                	mov    %edx,%esi
  801af4:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801af6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801afc:	75 13                	jne    801b11 <memmove+0x3b>
  801afe:	f6 c1 03             	test   $0x3,%cl
  801b01:	75 0e                	jne    801b11 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801b03:	83 ef 04             	sub    $0x4,%edi
  801b06:	8d 72 fc             	lea    -0x4(%edx),%esi
  801b09:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801b0c:	fd                   	std    
  801b0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801b0f:	eb 09                	jmp    801b1a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801b11:	83 ef 01             	sub    $0x1,%edi
  801b14:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801b17:	fd                   	std    
  801b18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801b1a:	fc                   	cld    
  801b1b:	eb 1d                	jmp    801b3a <memmove+0x64>
  801b1d:	89 f2                	mov    %esi,%edx
  801b1f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b21:	f6 c2 03             	test   $0x3,%dl
  801b24:	75 0f                	jne    801b35 <memmove+0x5f>
  801b26:	f6 c1 03             	test   $0x3,%cl
  801b29:	75 0a                	jne    801b35 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801b2b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801b2e:	89 c7                	mov    %eax,%edi
  801b30:	fc                   	cld    
  801b31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801b33:	eb 05                	jmp    801b3a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  801b35:	89 c7                	mov    %eax,%edi
  801b37:	fc                   	cld    
  801b38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801b3a:	5e                   	pop    %esi
  801b3b:	5f                   	pop    %edi
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801b44:	8b 45 10             	mov    0x10(%ebp),%eax
  801b47:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b52:	8b 45 08             	mov    0x8(%ebp),%eax
  801b55:	89 04 24             	mov    %eax,(%esp)
  801b58:	e8 79 ff ff ff       	call   801ad6 <memmove>
}
  801b5d:	c9                   	leave  
  801b5e:	c3                   	ret    

00801b5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	57                   	push   %edi
  801b63:	56                   	push   %esi
  801b64:	53                   	push   %ebx
  801b65:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b68:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b6b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801b6e:	8d 78 ff             	lea    -0x1(%eax),%edi
  801b71:	85 c0                	test   %eax,%eax
  801b73:	74 36                	je     801bab <memcmp+0x4c>
		if (*s1 != *s2)
  801b75:	0f b6 03             	movzbl (%ebx),%eax
  801b78:	0f b6 0e             	movzbl (%esi),%ecx
  801b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b80:	38 c8                	cmp    %cl,%al
  801b82:	74 1c                	je     801ba0 <memcmp+0x41>
  801b84:	eb 10                	jmp    801b96 <memcmp+0x37>
  801b86:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801b8b:	83 c2 01             	add    $0x1,%edx
  801b8e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  801b92:	38 c8                	cmp    %cl,%al
  801b94:	74 0a                	je     801ba0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801b96:	0f b6 c0             	movzbl %al,%eax
  801b99:	0f b6 c9             	movzbl %cl,%ecx
  801b9c:	29 c8                	sub    %ecx,%eax
  801b9e:	eb 10                	jmp    801bb0 <memcmp+0x51>
	while (n-- > 0) {
  801ba0:	39 fa                	cmp    %edi,%edx
  801ba2:	75 e2                	jne    801b86 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  801ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba9:	eb 05                	jmp    801bb0 <memcmp+0x51>
  801bab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bb0:	5b                   	pop    %ebx
  801bb1:	5e                   	pop    %esi
  801bb2:	5f                   	pop    %edi
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    

00801bb5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	53                   	push   %ebx
  801bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  801bbf:	89 c2                	mov    %eax,%edx
  801bc1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801bc4:	39 d0                	cmp    %edx,%eax
  801bc6:	73 13                	jae    801bdb <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801bc8:	89 d9                	mov    %ebx,%ecx
  801bca:	38 18                	cmp    %bl,(%eax)
  801bcc:	75 06                	jne    801bd4 <memfind+0x1f>
  801bce:	eb 0b                	jmp    801bdb <memfind+0x26>
  801bd0:	38 08                	cmp    %cl,(%eax)
  801bd2:	74 07                	je     801bdb <memfind+0x26>
	for (; s < ends; s++)
  801bd4:	83 c0 01             	add    $0x1,%eax
  801bd7:	39 d0                	cmp    %edx,%eax
  801bd9:	75 f5                	jne    801bd0 <memfind+0x1b>
			break;
	return (void *) s;
}
  801bdb:	5b                   	pop    %ebx
  801bdc:	5d                   	pop    %ebp
  801bdd:	c3                   	ret    

00801bde <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	57                   	push   %edi
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	8b 55 08             	mov    0x8(%ebp),%edx
  801be7:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801bea:	0f b6 0a             	movzbl (%edx),%ecx
  801bed:	80 f9 09             	cmp    $0x9,%cl
  801bf0:	74 05                	je     801bf7 <strtol+0x19>
  801bf2:	80 f9 20             	cmp    $0x20,%cl
  801bf5:	75 10                	jne    801c07 <strtol+0x29>
		s++;
  801bf7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801bfa:	0f b6 0a             	movzbl (%edx),%ecx
  801bfd:	80 f9 09             	cmp    $0x9,%cl
  801c00:	74 f5                	je     801bf7 <strtol+0x19>
  801c02:	80 f9 20             	cmp    $0x20,%cl
  801c05:	74 f0                	je     801bf7 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  801c07:	80 f9 2b             	cmp    $0x2b,%cl
  801c0a:	75 0a                	jne    801c16 <strtol+0x38>
		s++;
  801c0c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801c0f:	bf 00 00 00 00       	mov    $0x0,%edi
  801c14:	eb 11                	jmp    801c27 <strtol+0x49>
  801c16:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  801c1b:	80 f9 2d             	cmp    $0x2d,%cl
  801c1e:	75 07                	jne    801c27 <strtol+0x49>
		s++, neg = 1;
  801c20:	83 c2 01             	add    $0x1,%edx
  801c23:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c27:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801c2c:	75 15                	jne    801c43 <strtol+0x65>
  801c2e:	80 3a 30             	cmpb   $0x30,(%edx)
  801c31:	75 10                	jne    801c43 <strtol+0x65>
  801c33:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801c37:	75 0a                	jne    801c43 <strtol+0x65>
		s += 2, base = 16;
  801c39:	83 c2 02             	add    $0x2,%edx
  801c3c:	b8 10 00 00 00       	mov    $0x10,%eax
  801c41:	eb 10                	jmp    801c53 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  801c43:	85 c0                	test   %eax,%eax
  801c45:	75 0c                	jne    801c53 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801c47:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  801c49:	80 3a 30             	cmpb   $0x30,(%edx)
  801c4c:	75 05                	jne    801c53 <strtol+0x75>
		s++, base = 8;
  801c4e:	83 c2 01             	add    $0x1,%edx
  801c51:	b0 08                	mov    $0x8,%al
		base = 10;
  801c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c58:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801c5b:	0f b6 0a             	movzbl (%edx),%ecx
  801c5e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  801c61:	89 f0                	mov    %esi,%eax
  801c63:	3c 09                	cmp    $0x9,%al
  801c65:	77 08                	ja     801c6f <strtol+0x91>
			dig = *s - '0';
  801c67:	0f be c9             	movsbl %cl,%ecx
  801c6a:	83 e9 30             	sub    $0x30,%ecx
  801c6d:	eb 20                	jmp    801c8f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  801c6f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  801c72:	89 f0                	mov    %esi,%eax
  801c74:	3c 19                	cmp    $0x19,%al
  801c76:	77 08                	ja     801c80 <strtol+0xa2>
			dig = *s - 'a' + 10;
  801c78:	0f be c9             	movsbl %cl,%ecx
  801c7b:	83 e9 57             	sub    $0x57,%ecx
  801c7e:	eb 0f                	jmp    801c8f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  801c80:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801c83:	89 f0                	mov    %esi,%eax
  801c85:	3c 19                	cmp    $0x19,%al
  801c87:	77 16                	ja     801c9f <strtol+0xc1>
			dig = *s - 'A' + 10;
  801c89:	0f be c9             	movsbl %cl,%ecx
  801c8c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801c8f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  801c92:	7d 0f                	jge    801ca3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801c94:	83 c2 01             	add    $0x1,%edx
  801c97:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801c9b:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801c9d:	eb bc                	jmp    801c5b <strtol+0x7d>
  801c9f:	89 d8                	mov    %ebx,%eax
  801ca1:	eb 02                	jmp    801ca5 <strtol+0xc7>
  801ca3:	89 d8                	mov    %ebx,%eax

	if (endptr)
  801ca5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ca9:	74 05                	je     801cb0 <strtol+0xd2>
		*endptr = (char *) s;
  801cab:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cae:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  801cb0:	f7 d8                	neg    %eax
  801cb2:	85 ff                	test   %edi,%edi
  801cb4:	0f 44 c3             	cmove  %ebx,%eax
}
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5f                   	pop    %edi
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    

00801cbc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	56                   	push   %esi
  801cc0:	53                   	push   %ebx
  801cc1:	83 ec 10             	sub    $0x10,%esp
  801cc4:	8b 75 08             	mov    0x8(%ebp),%esi
  801cc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  801cca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ccd:	89 04 24             	mov    %eax,(%esp)
  801cd0:	e8 b1 e6 ff ff       	call   800386 <sys_ipc_recv>
	if(from_env_store)
  801cd5:	85 f6                	test   %esi,%esi
  801cd7:	74 14                	je     801ced <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  801cd9:	ba 00 00 00 00       	mov    $0x0,%edx
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	78 09                	js     801ceb <ipc_recv+0x2f>
  801ce2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ce8:	8b 52 74             	mov    0x74(%edx),%edx
  801ceb:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  801ced:	85 db                	test   %ebx,%ebx
  801cef:	74 14                	je     801d05 <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  801cf1:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	78 09                	js     801d03 <ipc_recv+0x47>
  801cfa:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d00:	8b 52 78             	mov    0x78(%edx),%edx
  801d03:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  801d05:	85 c0                	test   %eax,%eax
  801d07:	78 08                	js     801d11 <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  801d09:	a1 04 40 80 00       	mov    0x804004,%eax
  801d0e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d11:	83 c4 10             	add    $0x10,%esp
  801d14:	5b                   	pop    %ebx
  801d15:	5e                   	pop    %esi
  801d16:	5d                   	pop    %ebp
  801d17:	c3                   	ret    

00801d18 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	57                   	push   %edi
  801d1c:	56                   	push   %esi
  801d1d:	53                   	push   %ebx
  801d1e:	83 ec 1c             	sub    $0x1c,%esp
  801d21:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d24:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  801d27:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801d2c:	eb 0c                	jmp    801d3a <ipc_send+0x22>
		failed_cnt++;
  801d2e:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  801d31:	84 db                	test   %bl,%bl
  801d33:	75 05                	jne    801d3a <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  801d35:	e8 17 e4 ff ff       	call   800151 <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801d3a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d41:	8b 45 10             	mov    0x10(%ebp),%eax
  801d44:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d48:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d4c:	89 3c 24             	mov    %edi,(%esp)
  801d4f:	e8 0f e6 ff ff       	call   800363 <sys_ipc_try_send>
  801d54:	85 c0                	test   %eax,%eax
  801d56:	78 d6                	js     801d2e <ipc_send+0x16>
	}
}
  801d58:	83 c4 1c             	add    $0x1c,%esp
  801d5b:	5b                   	pop    %ebx
  801d5c:	5e                   	pop    %esi
  801d5d:	5f                   	pop    %edi
  801d5e:	5d                   	pop    %ebp
  801d5f:	c3                   	ret    

00801d60 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d66:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801d6b:	39 c8                	cmp    %ecx,%eax
  801d6d:	74 17                	je     801d86 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  801d6f:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801d74:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d77:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d7d:	8b 52 50             	mov    0x50(%edx),%edx
  801d80:	39 ca                	cmp    %ecx,%edx
  801d82:	75 14                	jne    801d98 <ipc_find_env+0x38>
  801d84:	eb 05                	jmp    801d8b <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  801d86:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  801d8b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d8e:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d93:	8b 40 40             	mov    0x40(%eax),%eax
  801d96:	eb 0e                	jmp    801da6 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  801d98:	83 c0 01             	add    $0x1,%eax
  801d9b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801da0:	75 d2                	jne    801d74 <ipc_find_env+0x14>
	return 0;
  801da2:	66 b8 00 00          	mov    $0x0,%ax
}
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    

00801da8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dae:	89 d0                	mov    %edx,%eax
  801db0:	c1 e8 16             	shr    $0x16,%eax
  801db3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801dba:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801dbf:	f6 c1 01             	test   $0x1,%cl
  801dc2:	74 1d                	je     801de1 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801dc4:	c1 ea 0c             	shr    $0xc,%edx
  801dc7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dce:	f6 c2 01             	test   $0x1,%dl
  801dd1:	74 0e                	je     801de1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801dd3:	c1 ea 0c             	shr    $0xc,%edx
  801dd6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ddd:	ef 
  801dde:	0f b7 c0             	movzwl %ax,%eax
}
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    
  801de3:	66 90                	xchg   %ax,%ax
  801de5:	66 90                	xchg   %ax,%ax
  801de7:	66 90                	xchg   %ax,%ax
  801de9:	66 90                	xchg   %ax,%ax
  801deb:	66 90                	xchg   %ax,%ax
  801ded:	66 90                	xchg   %ax,%ax
  801def:	90                   	nop

00801df0 <__udivdi3>:
  801df0:	55                   	push   %ebp
  801df1:	57                   	push   %edi
  801df2:	56                   	push   %esi
  801df3:	83 ec 0c             	sub    $0xc,%esp
  801df6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801dfa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801dfe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801e02:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e06:	85 c0                	test   %eax,%eax
  801e08:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e0c:	89 ea                	mov    %ebp,%edx
  801e0e:	89 0c 24             	mov    %ecx,(%esp)
  801e11:	75 2d                	jne    801e40 <__udivdi3+0x50>
  801e13:	39 e9                	cmp    %ebp,%ecx
  801e15:	77 61                	ja     801e78 <__udivdi3+0x88>
  801e17:	85 c9                	test   %ecx,%ecx
  801e19:	89 ce                	mov    %ecx,%esi
  801e1b:	75 0b                	jne    801e28 <__udivdi3+0x38>
  801e1d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e22:	31 d2                	xor    %edx,%edx
  801e24:	f7 f1                	div    %ecx
  801e26:	89 c6                	mov    %eax,%esi
  801e28:	31 d2                	xor    %edx,%edx
  801e2a:	89 e8                	mov    %ebp,%eax
  801e2c:	f7 f6                	div    %esi
  801e2e:	89 c5                	mov    %eax,%ebp
  801e30:	89 f8                	mov    %edi,%eax
  801e32:	f7 f6                	div    %esi
  801e34:	89 ea                	mov    %ebp,%edx
  801e36:	83 c4 0c             	add    $0xc,%esp
  801e39:	5e                   	pop    %esi
  801e3a:	5f                   	pop    %edi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    
  801e3d:	8d 76 00             	lea    0x0(%esi),%esi
  801e40:	39 e8                	cmp    %ebp,%eax
  801e42:	77 24                	ja     801e68 <__udivdi3+0x78>
  801e44:	0f bd e8             	bsr    %eax,%ebp
  801e47:	83 f5 1f             	xor    $0x1f,%ebp
  801e4a:	75 3c                	jne    801e88 <__udivdi3+0x98>
  801e4c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e50:	39 34 24             	cmp    %esi,(%esp)
  801e53:	0f 86 9f 00 00 00    	jbe    801ef8 <__udivdi3+0x108>
  801e59:	39 d0                	cmp    %edx,%eax
  801e5b:	0f 82 97 00 00 00    	jb     801ef8 <__udivdi3+0x108>
  801e61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e68:	31 d2                	xor    %edx,%edx
  801e6a:	31 c0                	xor    %eax,%eax
  801e6c:	83 c4 0c             	add    $0xc,%esp
  801e6f:	5e                   	pop    %esi
  801e70:	5f                   	pop    %edi
  801e71:	5d                   	pop    %ebp
  801e72:	c3                   	ret    
  801e73:	90                   	nop
  801e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e78:	89 f8                	mov    %edi,%eax
  801e7a:	f7 f1                	div    %ecx
  801e7c:	31 d2                	xor    %edx,%edx
  801e7e:	83 c4 0c             	add    $0xc,%esp
  801e81:	5e                   	pop    %esi
  801e82:	5f                   	pop    %edi
  801e83:	5d                   	pop    %ebp
  801e84:	c3                   	ret    
  801e85:	8d 76 00             	lea    0x0(%esi),%esi
  801e88:	89 e9                	mov    %ebp,%ecx
  801e8a:	8b 3c 24             	mov    (%esp),%edi
  801e8d:	d3 e0                	shl    %cl,%eax
  801e8f:	89 c6                	mov    %eax,%esi
  801e91:	b8 20 00 00 00       	mov    $0x20,%eax
  801e96:	29 e8                	sub    %ebp,%eax
  801e98:	89 c1                	mov    %eax,%ecx
  801e9a:	d3 ef                	shr    %cl,%edi
  801e9c:	89 e9                	mov    %ebp,%ecx
  801e9e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801ea2:	8b 3c 24             	mov    (%esp),%edi
  801ea5:	09 74 24 08          	or     %esi,0x8(%esp)
  801ea9:	89 d6                	mov    %edx,%esi
  801eab:	d3 e7                	shl    %cl,%edi
  801ead:	89 c1                	mov    %eax,%ecx
  801eaf:	89 3c 24             	mov    %edi,(%esp)
  801eb2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801eb6:	d3 ee                	shr    %cl,%esi
  801eb8:	89 e9                	mov    %ebp,%ecx
  801eba:	d3 e2                	shl    %cl,%edx
  801ebc:	89 c1                	mov    %eax,%ecx
  801ebe:	d3 ef                	shr    %cl,%edi
  801ec0:	09 d7                	or     %edx,%edi
  801ec2:	89 f2                	mov    %esi,%edx
  801ec4:	89 f8                	mov    %edi,%eax
  801ec6:	f7 74 24 08          	divl   0x8(%esp)
  801eca:	89 d6                	mov    %edx,%esi
  801ecc:	89 c7                	mov    %eax,%edi
  801ece:	f7 24 24             	mull   (%esp)
  801ed1:	39 d6                	cmp    %edx,%esi
  801ed3:	89 14 24             	mov    %edx,(%esp)
  801ed6:	72 30                	jb     801f08 <__udivdi3+0x118>
  801ed8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801edc:	89 e9                	mov    %ebp,%ecx
  801ede:	d3 e2                	shl    %cl,%edx
  801ee0:	39 c2                	cmp    %eax,%edx
  801ee2:	73 05                	jae    801ee9 <__udivdi3+0xf9>
  801ee4:	3b 34 24             	cmp    (%esp),%esi
  801ee7:	74 1f                	je     801f08 <__udivdi3+0x118>
  801ee9:	89 f8                	mov    %edi,%eax
  801eeb:	31 d2                	xor    %edx,%edx
  801eed:	e9 7a ff ff ff       	jmp    801e6c <__udivdi3+0x7c>
  801ef2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ef8:	31 d2                	xor    %edx,%edx
  801efa:	b8 01 00 00 00       	mov    $0x1,%eax
  801eff:	e9 68 ff ff ff       	jmp    801e6c <__udivdi3+0x7c>
  801f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f08:	8d 47 ff             	lea    -0x1(%edi),%eax
  801f0b:	31 d2                	xor    %edx,%edx
  801f0d:	83 c4 0c             	add    $0xc,%esp
  801f10:	5e                   	pop    %esi
  801f11:	5f                   	pop    %edi
  801f12:	5d                   	pop    %ebp
  801f13:	c3                   	ret    
  801f14:	66 90                	xchg   %ax,%ax
  801f16:	66 90                	xchg   %ax,%ax
  801f18:	66 90                	xchg   %ax,%ax
  801f1a:	66 90                	xchg   %ax,%ax
  801f1c:	66 90                	xchg   %ax,%ax
  801f1e:	66 90                	xchg   %ax,%ax

00801f20 <__umoddi3>:
  801f20:	55                   	push   %ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	83 ec 14             	sub    $0x14,%esp
  801f26:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f2a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f2e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801f32:	89 c7                	mov    %eax,%edi
  801f34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f38:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f3c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801f40:	89 34 24             	mov    %esi,(%esp)
  801f43:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f47:	85 c0                	test   %eax,%eax
  801f49:	89 c2                	mov    %eax,%edx
  801f4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f4f:	75 17                	jne    801f68 <__umoddi3+0x48>
  801f51:	39 fe                	cmp    %edi,%esi
  801f53:	76 4b                	jbe    801fa0 <__umoddi3+0x80>
  801f55:	89 c8                	mov    %ecx,%eax
  801f57:	89 fa                	mov    %edi,%edx
  801f59:	f7 f6                	div    %esi
  801f5b:	89 d0                	mov    %edx,%eax
  801f5d:	31 d2                	xor    %edx,%edx
  801f5f:	83 c4 14             	add    $0x14,%esp
  801f62:	5e                   	pop    %esi
  801f63:	5f                   	pop    %edi
  801f64:	5d                   	pop    %ebp
  801f65:	c3                   	ret    
  801f66:	66 90                	xchg   %ax,%ax
  801f68:	39 f8                	cmp    %edi,%eax
  801f6a:	77 54                	ja     801fc0 <__umoddi3+0xa0>
  801f6c:	0f bd e8             	bsr    %eax,%ebp
  801f6f:	83 f5 1f             	xor    $0x1f,%ebp
  801f72:	75 5c                	jne    801fd0 <__umoddi3+0xb0>
  801f74:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801f78:	39 3c 24             	cmp    %edi,(%esp)
  801f7b:	0f 87 e7 00 00 00    	ja     802068 <__umoddi3+0x148>
  801f81:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f85:	29 f1                	sub    %esi,%ecx
  801f87:	19 c7                	sbb    %eax,%edi
  801f89:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f8d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f91:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f95:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f99:	83 c4 14             	add    $0x14,%esp
  801f9c:	5e                   	pop    %esi
  801f9d:	5f                   	pop    %edi
  801f9e:	5d                   	pop    %ebp
  801f9f:	c3                   	ret    
  801fa0:	85 f6                	test   %esi,%esi
  801fa2:	89 f5                	mov    %esi,%ebp
  801fa4:	75 0b                	jne    801fb1 <__umoddi3+0x91>
  801fa6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fab:	31 d2                	xor    %edx,%edx
  801fad:	f7 f6                	div    %esi
  801faf:	89 c5                	mov    %eax,%ebp
  801fb1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fb5:	31 d2                	xor    %edx,%edx
  801fb7:	f7 f5                	div    %ebp
  801fb9:	89 c8                	mov    %ecx,%eax
  801fbb:	f7 f5                	div    %ebp
  801fbd:	eb 9c                	jmp    801f5b <__umoddi3+0x3b>
  801fbf:	90                   	nop
  801fc0:	89 c8                	mov    %ecx,%eax
  801fc2:	89 fa                	mov    %edi,%edx
  801fc4:	83 c4 14             	add    $0x14,%esp
  801fc7:	5e                   	pop    %esi
  801fc8:	5f                   	pop    %edi
  801fc9:	5d                   	pop    %ebp
  801fca:	c3                   	ret    
  801fcb:	90                   	nop
  801fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	8b 04 24             	mov    (%esp),%eax
  801fd3:	be 20 00 00 00       	mov    $0x20,%esi
  801fd8:	89 e9                	mov    %ebp,%ecx
  801fda:	29 ee                	sub    %ebp,%esi
  801fdc:	d3 e2                	shl    %cl,%edx
  801fde:	89 f1                	mov    %esi,%ecx
  801fe0:	d3 e8                	shr    %cl,%eax
  801fe2:	89 e9                	mov    %ebp,%ecx
  801fe4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe8:	8b 04 24             	mov    (%esp),%eax
  801feb:	09 54 24 04          	or     %edx,0x4(%esp)
  801fef:	89 fa                	mov    %edi,%edx
  801ff1:	d3 e0                	shl    %cl,%eax
  801ff3:	89 f1                	mov    %esi,%ecx
  801ff5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ff9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801ffd:	d3 ea                	shr    %cl,%edx
  801fff:	89 e9                	mov    %ebp,%ecx
  802001:	d3 e7                	shl    %cl,%edi
  802003:	89 f1                	mov    %esi,%ecx
  802005:	d3 e8                	shr    %cl,%eax
  802007:	89 e9                	mov    %ebp,%ecx
  802009:	09 f8                	or     %edi,%eax
  80200b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80200f:	f7 74 24 04          	divl   0x4(%esp)
  802013:	d3 e7                	shl    %cl,%edi
  802015:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802019:	89 d7                	mov    %edx,%edi
  80201b:	f7 64 24 08          	mull   0x8(%esp)
  80201f:	39 d7                	cmp    %edx,%edi
  802021:	89 c1                	mov    %eax,%ecx
  802023:	89 14 24             	mov    %edx,(%esp)
  802026:	72 2c                	jb     802054 <__umoddi3+0x134>
  802028:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80202c:	72 22                	jb     802050 <__umoddi3+0x130>
  80202e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802032:	29 c8                	sub    %ecx,%eax
  802034:	19 d7                	sbb    %edx,%edi
  802036:	89 e9                	mov    %ebp,%ecx
  802038:	89 fa                	mov    %edi,%edx
  80203a:	d3 e8                	shr    %cl,%eax
  80203c:	89 f1                	mov    %esi,%ecx
  80203e:	d3 e2                	shl    %cl,%edx
  802040:	89 e9                	mov    %ebp,%ecx
  802042:	d3 ef                	shr    %cl,%edi
  802044:	09 d0                	or     %edx,%eax
  802046:	89 fa                	mov    %edi,%edx
  802048:	83 c4 14             	add    $0x14,%esp
  80204b:	5e                   	pop    %esi
  80204c:	5f                   	pop    %edi
  80204d:	5d                   	pop    %ebp
  80204e:	c3                   	ret    
  80204f:	90                   	nop
  802050:	39 d7                	cmp    %edx,%edi
  802052:	75 da                	jne    80202e <__umoddi3+0x10e>
  802054:	8b 14 24             	mov    (%esp),%edx
  802057:	89 c1                	mov    %eax,%ecx
  802059:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80205d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802061:	eb cb                	jmp    80202e <__umoddi3+0x10e>
  802063:	90                   	nop
  802064:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802068:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80206c:	0f 82 0f ff ff ff    	jb     801f81 <__umoddi3+0x61>
  802072:	e9 1a ff ff ff       	jmp    801f91 <__umoddi3+0x71>
