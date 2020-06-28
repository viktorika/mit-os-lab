
obj/user/softint：     文件格式 elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	83 ec 10             	sub    $0x10,%esp
  800042:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800045:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800048:	e8 d8 00 00 00       	call   800125 <sys_getenvid>
  80004d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800052:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005f:	85 db                	test   %ebx,%ebx
  800061:	7e 07                	jle    80006a <libmain+0x30>
		binaryname = argv[0];
  800063:	8b 06                	mov    (%esi),%eax
  800065:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80006e:	89 1c 24             	mov    %ebx,(%esp)
  800071:	e8 bd ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800076:	e8 07 00 00 00       	call   800082 <exit>
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	5b                   	pop    %ebx
  80007f:	5e                   	pop    %esi
  800080:	5d                   	pop    %ebp
  800081:	c3                   	ret    

00800082 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800088:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80008f:	e8 3f 00 00 00       	call   8000d3 <sys_env_destroy>
}
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80009c:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a7:	89 c3                	mov    %eax,%ebx
  8000a9:	89 c7                	mov    %eax,%edi
  8000ab:	89 c6                	mov    %eax,%esi
  8000ad:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5f                   	pop    %edi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c4:	89 d1                	mov    %edx,%ecx
  8000c6:	89 d3                	mov    %edx,%ebx
  8000c8:	89 d7                	mov    %edx,%edi
  8000ca:	89 d6                	mov    %edx,%esi
  8000cc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8000dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e9:	89 cb                	mov    %ecx,%ebx
  8000eb:	89 cf                	mov    %ecx,%edi
  8000ed:	89 ce                	mov    %ecx,%esi
  8000ef:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f1:	85 c0                	test   %eax,%eax
  8000f3:	7e 28                	jle    80011d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000f9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800100:	00 
  800101:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  800108:	00 
  800109:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800110:	00 
  800111:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800118:	e8 5b 02 00 00       	call   800378 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	83 c4 2c             	add    $0x2c,%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 28                	jle    8001af <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	89 44 24 10          	mov    %eax,0x10(%esp)
  80018b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800192:	00 
  800193:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  80019a:	00 
  80019b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001a2:	00 
  8001a3:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  8001aa:	e8 c9 01 00 00       	call   800378 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001af:	83 c4 2c             	add    $0x2c,%esp
  8001b2:	5b                   	pop    %ebx
  8001b3:	5e                   	pop    %esi
  8001b4:	5f                   	pop    %edi
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	57                   	push   %edi
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8001c0:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ce:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d1:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d6:	85 c0                	test   %eax,%eax
  8001d8:	7e 28                	jle    800202 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001da:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001de:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001e5:	00 
  8001e6:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  8001ed:	00 
  8001ee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001f5:	00 
  8001f6:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  8001fd:	e8 76 01 00 00       	call   800378 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800202:	83 c4 2c             	add    $0x2c,%esp
  800205:	5b                   	pop    %ebx
  800206:	5e                   	pop    %esi
  800207:	5f                   	pop    %edi
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    

0080020a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	57                   	push   %edi
  80020e:	56                   	push   %esi
  80020f:	53                   	push   %ebx
  800210:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800213:	bb 00 00 00 00       	mov    $0x0,%ebx
  800218:	b8 06 00 00 00       	mov    $0x6,%eax
  80021d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800220:	8b 55 08             	mov    0x8(%ebp),%edx
  800223:	89 df                	mov    %ebx,%edi
  800225:	89 de                	mov    %ebx,%esi
  800227:	cd 30                	int    $0x30
	if(check && ret > 0)
  800229:	85 c0                	test   %eax,%eax
  80022b:	7e 28                	jle    800255 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800231:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800238:	00 
  800239:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  800240:	00 
  800241:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800248:	00 
  800249:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800250:	e8 23 01 00 00       	call   800378 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800255:	83 c4 2c             	add    $0x2c,%esp
  800258:	5b                   	pop    %ebx
  800259:	5e                   	pop    %esi
  80025a:	5f                   	pop    %edi
  80025b:	5d                   	pop    %ebp
  80025c:	c3                   	ret    

0080025d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	57                   	push   %edi
  800261:	56                   	push   %esi
  800262:	53                   	push   %ebx
  800263:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800266:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026b:	b8 08 00 00 00       	mov    $0x8,%eax
  800270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800273:	8b 55 08             	mov    0x8(%ebp),%edx
  800276:	89 df                	mov    %ebx,%edi
  800278:	89 de                	mov    %ebx,%esi
  80027a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027c:	85 c0                	test   %eax,%eax
  80027e:	7e 28                	jle    8002a8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800280:	89 44 24 10          	mov    %eax,0x10(%esp)
  800284:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80028b:	00 
  80028c:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  800293:	00 
  800294:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029b:	00 
  80029c:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  8002a3:	e8 d0 00 00 00       	call   800378 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002a8:	83 c4 2c             	add    $0x2c,%esp
  8002ab:	5b                   	pop    %ebx
  8002ac:	5e                   	pop    %esi
  8002ad:	5f                   	pop    %edi
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002be:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	89 df                	mov    %ebx,%edi
  8002cb:	89 de                	mov    %ebx,%esi
  8002cd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002cf:	85 c0                	test   %eax,%eax
  8002d1:	7e 28                	jle    8002fb <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002d7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002de:	00 
  8002df:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  8002e6:	00 
  8002e7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ee:	00 
  8002ef:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  8002f6:	e8 7d 00 00 00       	call   800378 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002fb:	83 c4 2c             	add    $0x2c,%esp
  8002fe:	5b                   	pop    %ebx
  8002ff:	5e                   	pop    %esi
  800300:	5f                   	pop    %edi
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	57                   	push   %edi
  800307:	56                   	push   %esi
  800308:	53                   	push   %ebx
	asm volatile("int %1\n"
  800309:	be 00 00 00 00       	mov    $0x0,%esi
  80030e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800313:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800316:	8b 55 08             	mov    0x8(%ebp),%edx
  800319:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80031c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80031f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800321:	5b                   	pop    %ebx
  800322:	5e                   	pop    %esi
  800323:	5f                   	pop    %edi
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	57                   	push   %edi
  80032a:	56                   	push   %esi
  80032b:	53                   	push   %ebx
  80032c:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80032f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800334:	b8 0c 00 00 00       	mov    $0xc,%eax
  800339:	8b 55 08             	mov    0x8(%ebp),%edx
  80033c:	89 cb                	mov    %ecx,%ebx
  80033e:	89 cf                	mov    %ecx,%edi
  800340:	89 ce                	mov    %ecx,%esi
  800342:	cd 30                	int    $0x30
	if(check && ret > 0)
  800344:	85 c0                	test   %eax,%eax
  800346:	7e 28                	jle    800370 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800348:	89 44 24 10          	mov    %eax,0x10(%esp)
  80034c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800353:	00 
  800354:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  80035b:	00 
  80035c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800363:	00 
  800364:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  80036b:	e8 08 00 00 00       	call   800378 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800370:	83 c4 2c             	add    $0x2c,%esp
  800373:	5b                   	pop    %ebx
  800374:	5e                   	pop    %esi
  800375:	5f                   	pop    %edi
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	56                   	push   %esi
  80037c:	53                   	push   %ebx
  80037d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800380:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800383:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800389:	e8 97 fd ff ff       	call   800125 <sys_getenvid>
  80038e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800391:	89 54 24 10          	mov    %edx,0x10(%esp)
  800395:	8b 55 08             	mov    0x8(%ebp),%edx
  800398:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80039c:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a4:	c7 04 24 78 11 80 00 	movl   $0x801178,(%esp)
  8003ab:	e8 c1 00 00 00       	call   800471 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b7:	89 04 24             	mov    %eax,(%esp)
  8003ba:	e8 51 00 00 00       	call   800410 <vcprintf>
	cprintf("\n");
  8003bf:	c7 04 24 9c 11 80 00 	movl   $0x80119c,(%esp)
  8003c6:	e8 a6 00 00 00       	call   800471 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003cb:	cc                   	int3   
  8003cc:	eb fd                	jmp    8003cb <_panic+0x53>

008003ce <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	53                   	push   %ebx
  8003d2:	83 ec 14             	sub    $0x14,%esp
  8003d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003d8:	8b 13                	mov    (%ebx),%edx
  8003da:	8d 42 01             	lea    0x1(%edx),%eax
  8003dd:	89 03                	mov    %eax,(%ebx)
  8003df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003eb:	75 19                	jne    800406 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003ed:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003f4:	00 
  8003f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8003f8:	89 04 24             	mov    %eax,(%esp)
  8003fb:	e8 96 fc ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  800400:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800406:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80040a:	83 c4 14             	add    $0x14,%esp
  80040d:	5b                   	pop    %ebx
  80040e:	5d                   	pop    %ebp
  80040f:	c3                   	ret    

00800410 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800419:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800420:	00 00 00 
	b.cnt = 0;
  800423:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80042a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80042d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800430:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800434:	8b 45 08             	mov    0x8(%ebp),%eax
  800437:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800441:	89 44 24 04          	mov    %eax,0x4(%esp)
  800445:	c7 04 24 ce 03 80 00 	movl   $0x8003ce,(%esp)
  80044c:	e8 b3 01 00 00       	call   800604 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800451:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800457:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800461:	89 04 24             	mov    %eax,(%esp)
  800464:	e8 2d fc ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  800469:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80046f:	c9                   	leave  
  800470:	c3                   	ret    

00800471 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800471:	55                   	push   %ebp
  800472:	89 e5                	mov    %esp,%ebp
  800474:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800477:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80047a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047e:	8b 45 08             	mov    0x8(%ebp),%eax
  800481:	89 04 24             	mov    %eax,(%esp)
  800484:	e8 87 ff ff ff       	call   800410 <vcprintf>
	va_end(ap);

	return cnt;
}
  800489:	c9                   	leave  
  80048a:	c3                   	ret    
  80048b:	66 90                	xchg   %ax,%ax
  80048d:	66 90                	xchg   %ax,%ax
  80048f:	90                   	nop

00800490 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	57                   	push   %edi
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 3c             	sub    $0x3c,%esp
  800499:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049c:	89 d7                	mov    %edx,%edi
  80049e:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004a7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8004aa:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004b8:	39 f1                	cmp    %esi,%ecx
  8004ba:	72 14                	jb     8004d0 <printnum+0x40>
  8004bc:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004bf:	76 0f                	jbe    8004d0 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 70 ff             	lea    -0x1(%eax),%esi
  8004c7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004ca:	85 f6                	test   %esi,%esi
  8004cc:	7f 60                	jg     80052e <printnum+0x9e>
  8004ce:	eb 72                	jmp    800542 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004d3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004d7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004da:	8d 51 ff             	lea    -0x1(%ecx),%edx
  8004dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e5:	8b 44 24 08          	mov    0x8(%esp),%eax
  8004e9:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8004ed:	89 c3                	mov    %eax,%ebx
  8004ef:	89 d6                	mov    %edx,%esi
  8004f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004f7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8004fb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8004ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800502:	89 04 24             	mov    %eax,(%esp)
  800505:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800508:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050c:	e8 9f 09 00 00       	call   800eb0 <__udivdi3>
  800511:	89 d9                	mov    %ebx,%ecx
  800513:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800517:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80051b:	89 04 24             	mov    %eax,(%esp)
  80051e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800522:	89 fa                	mov    %edi,%edx
  800524:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800527:	e8 64 ff ff ff       	call   800490 <printnum>
  80052c:	eb 14                	jmp    800542 <printnum+0xb2>
			putch(padc, putdat);
  80052e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800532:	8b 45 18             	mov    0x18(%ebp),%eax
  800535:	89 04 24             	mov    %eax,(%esp)
  800538:	ff d3                	call   *%ebx
		while (--width > 0)
  80053a:	83 ee 01             	sub    $0x1,%esi
  80053d:	75 ef                	jne    80052e <printnum+0x9e>
  80053f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800542:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800546:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80054a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80054d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800550:	89 44 24 08          	mov    %eax,0x8(%esp)
  800554:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800558:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800561:	89 44 24 04          	mov    %eax,0x4(%esp)
  800565:	e8 76 0a 00 00       	call   800fe0 <__umoddi3>
  80056a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056e:	0f be 80 9e 11 80 00 	movsbl 0x80119e(%eax),%eax
  800575:	89 04 24             	mov    %eax,(%esp)
  800578:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057b:	ff d0                	call   *%eax
}
  80057d:	83 c4 3c             	add    $0x3c,%esp
  800580:	5b                   	pop    %ebx
  800581:	5e                   	pop    %esi
  800582:	5f                   	pop    %edi
  800583:	5d                   	pop    %ebp
  800584:	c3                   	ret    

00800585 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800585:	55                   	push   %ebp
  800586:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800588:	83 fa 01             	cmp    $0x1,%edx
  80058b:	7e 0e                	jle    80059b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80058d:	8b 10                	mov    (%eax),%edx
  80058f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800592:	89 08                	mov    %ecx,(%eax)
  800594:	8b 02                	mov    (%edx),%eax
  800596:	8b 52 04             	mov    0x4(%edx),%edx
  800599:	eb 22                	jmp    8005bd <getuint+0x38>
	else if (lflag)
  80059b:	85 d2                	test   %edx,%edx
  80059d:	74 10                	je     8005af <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80059f:	8b 10                	mov    (%eax),%edx
  8005a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005a4:	89 08                	mov    %ecx,(%eax)
  8005a6:	8b 02                	mov    (%edx),%eax
  8005a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ad:	eb 0e                	jmp    8005bd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005af:	8b 10                	mov    (%eax),%edx
  8005b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005b4:	89 08                	mov    %ecx,(%eax)
  8005b6:	8b 02                	mov    (%edx),%eax
  8005b8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005bd:	5d                   	pop    %ebp
  8005be:	c3                   	ret    

008005bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005bf:	55                   	push   %ebp
  8005c0:	89 e5                	mov    %esp,%ebp
  8005c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005c9:	8b 10                	mov    (%eax),%edx
  8005cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ce:	73 0a                	jae    8005da <sprintputch+0x1b>
		*b->buf++ = ch;
  8005d0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005d3:	89 08                	mov    %ecx,(%eax)
  8005d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d8:	88 02                	mov    %al,(%edx)
}
  8005da:	5d                   	pop    %ebp
  8005db:	c3                   	ret    

008005dc <printfmt>:
{
  8005dc:	55                   	push   %ebp
  8005dd:	89 e5                	mov    %esp,%ebp
  8005df:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8005e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fa:	89 04 24             	mov    %eax,(%esp)
  8005fd:	e8 02 00 00 00       	call   800604 <vprintfmt>
}
  800602:	c9                   	leave  
  800603:	c3                   	ret    

00800604 <vprintfmt>:
{
  800604:	55                   	push   %ebp
  800605:	89 e5                	mov    %esp,%ebp
  800607:	57                   	push   %edi
  800608:	56                   	push   %esi
  800609:	53                   	push   %ebx
  80060a:	83 ec 3c             	sub    $0x3c,%esp
  80060d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800610:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800613:	eb 18                	jmp    80062d <vprintfmt+0x29>
			if (ch == '\0')
  800615:	85 c0                	test   %eax,%eax
  800617:	0f 84 c3 03 00 00    	je     8009e0 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80061d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800621:	89 04 24             	mov    %eax,(%esp)
  800624:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800627:	89 f3                	mov    %esi,%ebx
  800629:	eb 02                	jmp    80062d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80062b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80062d:	8d 73 01             	lea    0x1(%ebx),%esi
  800630:	0f b6 03             	movzbl (%ebx),%eax
  800633:	83 f8 25             	cmp    $0x25,%eax
  800636:	75 dd                	jne    800615 <vprintfmt+0x11>
  800638:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80063c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800643:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80064a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800651:	ba 00 00 00 00       	mov    $0x0,%edx
  800656:	eb 1d                	jmp    800675 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800658:	89 de                	mov    %ebx,%esi
			padc = '-';
  80065a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80065e:	eb 15                	jmp    800675 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800660:	89 de                	mov    %ebx,%esi
			padc = '0';
  800662:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800666:	eb 0d                	jmp    800675 <vprintfmt+0x71>
				width = precision, precision = -1;
  800668:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80066b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80066e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800675:	8d 5e 01             	lea    0x1(%esi),%ebx
  800678:	0f b6 06             	movzbl (%esi),%eax
  80067b:	0f b6 c8             	movzbl %al,%ecx
  80067e:	83 e8 23             	sub    $0x23,%eax
  800681:	3c 55                	cmp    $0x55,%al
  800683:	0f 87 2f 03 00 00    	ja     8009b8 <vprintfmt+0x3b4>
  800689:	0f b6 c0             	movzbl %al,%eax
  80068c:	ff 24 85 60 12 80 00 	jmp    *0x801260(,%eax,4)
				precision = precision * 10 + ch - '0';
  800693:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800696:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  800699:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80069d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006a0:	83 f9 09             	cmp    $0x9,%ecx
  8006a3:	77 50                	ja     8006f5 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8006a5:	89 de                	mov    %ebx,%esi
  8006a7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8006aa:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8006ad:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8006b0:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8006b4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006b7:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8006ba:	83 fb 09             	cmp    $0x9,%ebx
  8006bd:	76 eb                	jbe    8006aa <vprintfmt+0xa6>
  8006bf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006c2:	eb 33                	jmp    8006f7 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ca:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006cd:	8b 00                	mov    (%eax),%eax
  8006cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8006d2:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8006d4:	eb 21                	jmp    8006f7 <vprintfmt+0xf3>
  8006d6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006d9:	85 c9                	test   %ecx,%ecx
  8006db:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e0:	0f 49 c1             	cmovns %ecx,%eax
  8006e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8006e6:	89 de                	mov    %ebx,%esi
  8006e8:	eb 8b                	jmp    800675 <vprintfmt+0x71>
  8006ea:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8006ec:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006f3:	eb 80                	jmp    800675 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8006f5:	89 de                	mov    %ebx,%esi
			if (width < 0)
  8006f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006fb:	0f 89 74 ff ff ff    	jns    800675 <vprintfmt+0x71>
  800701:	e9 62 ff ff ff       	jmp    800668 <vprintfmt+0x64>
			lflag++;
  800706:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800709:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80070b:	e9 65 ff ff ff       	jmp    800675 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8d 50 04             	lea    0x4(%eax),%edx
  800716:	89 55 14             	mov    %edx,0x14(%ebp)
  800719:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80071d:	8b 00                	mov    (%eax),%eax
  80071f:	89 04 24             	mov    %eax,(%esp)
  800722:	ff 55 08             	call   *0x8(%ebp)
			break;
  800725:	e9 03 ff ff ff       	jmp    80062d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8d 50 04             	lea    0x4(%eax),%edx
  800730:	89 55 14             	mov    %edx,0x14(%ebp)
  800733:	8b 00                	mov    (%eax),%eax
  800735:	99                   	cltd   
  800736:	31 d0                	xor    %edx,%eax
  800738:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80073a:	83 f8 08             	cmp    $0x8,%eax
  80073d:	7f 0b                	jg     80074a <vprintfmt+0x146>
  80073f:	8b 14 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%edx
  800746:	85 d2                	test   %edx,%edx
  800748:	75 20                	jne    80076a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80074a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074e:	c7 44 24 08 b6 11 80 	movl   $0x8011b6,0x8(%esp)
  800755:	00 
  800756:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075a:	8b 45 08             	mov    0x8(%ebp),%eax
  80075d:	89 04 24             	mov    %eax,(%esp)
  800760:	e8 77 fe ff ff       	call   8005dc <printfmt>
  800765:	e9 c3 fe ff ff       	jmp    80062d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80076a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80076e:	c7 44 24 08 bf 11 80 	movl   $0x8011bf,0x8(%esp)
  800775:	00 
  800776:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077a:	8b 45 08             	mov    0x8(%ebp),%eax
  80077d:	89 04 24             	mov    %eax,(%esp)
  800780:	e8 57 fe ff ff       	call   8005dc <printfmt>
  800785:	e9 a3 fe ff ff       	jmp    80062d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  80078a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80078d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  800790:	8b 45 14             	mov    0x14(%ebp),%eax
  800793:	8d 50 04             	lea    0x4(%eax),%edx
  800796:	89 55 14             	mov    %edx,0x14(%ebp)
  800799:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80079b:	85 c0                	test   %eax,%eax
  80079d:	ba af 11 80 00       	mov    $0x8011af,%edx
  8007a2:	0f 45 d0             	cmovne %eax,%edx
  8007a5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8007a8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8007ac:	74 04                	je     8007b2 <vprintfmt+0x1ae>
  8007ae:	85 f6                	test   %esi,%esi
  8007b0:	7f 19                	jg     8007cb <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007b5:	8d 70 01             	lea    0x1(%eax),%esi
  8007b8:	0f b6 10             	movzbl (%eax),%edx
  8007bb:	0f be c2             	movsbl %dl,%eax
  8007be:	85 c0                	test   %eax,%eax
  8007c0:	0f 85 95 00 00 00    	jne    80085b <vprintfmt+0x257>
  8007c6:	e9 85 00 00 00       	jmp    800850 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007d2:	89 04 24             	mov    %eax,(%esp)
  8007d5:	e8 b8 02 00 00       	call   800a92 <strnlen>
  8007da:	29 c6                	sub    %eax,%esi
  8007dc:	89 f0                	mov    %esi,%eax
  8007de:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8007e1:	85 f6                	test   %esi,%esi
  8007e3:	7e cd                	jle    8007b2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8007e5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8007e9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007ec:	89 c3                	mov    %eax,%ebx
  8007ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007f2:	89 34 24             	mov    %esi,(%esp)
  8007f5:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8007f8:	83 eb 01             	sub    $0x1,%ebx
  8007fb:	75 f1                	jne    8007ee <vprintfmt+0x1ea>
  8007fd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800800:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800803:	eb ad                	jmp    8007b2 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800805:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800809:	74 1e                	je     800829 <vprintfmt+0x225>
  80080b:	0f be d2             	movsbl %dl,%edx
  80080e:	83 ea 20             	sub    $0x20,%edx
  800811:	83 fa 5e             	cmp    $0x5e,%edx
  800814:	76 13                	jbe    800829 <vprintfmt+0x225>
					putch('?', putdat);
  800816:	8b 45 0c             	mov    0xc(%ebp),%eax
  800819:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800824:	ff 55 08             	call   *0x8(%ebp)
  800827:	eb 0d                	jmp    800836 <vprintfmt+0x232>
					putch(ch, putdat);
  800829:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800830:	89 04 24             	mov    %eax,(%esp)
  800833:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800836:	83 ef 01             	sub    $0x1,%edi
  800839:	83 c6 01             	add    $0x1,%esi
  80083c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800840:	0f be c2             	movsbl %dl,%eax
  800843:	85 c0                	test   %eax,%eax
  800845:	75 20                	jne    800867 <vprintfmt+0x263>
  800847:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80084a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80084d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800850:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800854:	7f 25                	jg     80087b <vprintfmt+0x277>
  800856:	e9 d2 fd ff ff       	jmp    80062d <vprintfmt+0x29>
  80085b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80085e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800861:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800864:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800867:	85 db                	test   %ebx,%ebx
  800869:	78 9a                	js     800805 <vprintfmt+0x201>
  80086b:	83 eb 01             	sub    $0x1,%ebx
  80086e:	79 95                	jns    800805 <vprintfmt+0x201>
  800870:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800873:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800876:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800879:	eb d5                	jmp    800850 <vprintfmt+0x24c>
  80087b:	8b 75 08             	mov    0x8(%ebp),%esi
  80087e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800881:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  800884:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800888:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80088f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800891:	83 eb 01             	sub    $0x1,%ebx
  800894:	75 ee                	jne    800884 <vprintfmt+0x280>
  800896:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800899:	e9 8f fd ff ff       	jmp    80062d <vprintfmt+0x29>
	if (lflag >= 2)
  80089e:	83 fa 01             	cmp    $0x1,%edx
  8008a1:	7e 16                	jle    8008b9 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8008a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a6:	8d 50 08             	lea    0x8(%eax),%edx
  8008a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ac:	8b 50 04             	mov    0x4(%eax),%edx
  8008af:	8b 00                	mov    (%eax),%eax
  8008b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008b7:	eb 32                	jmp    8008eb <vprintfmt+0x2e7>
	else if (lflag)
  8008b9:	85 d2                	test   %edx,%edx
  8008bb:	74 18                	je     8008d5 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8008bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c0:	8d 50 04             	lea    0x4(%eax),%edx
  8008c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c6:	8b 30                	mov    (%eax),%esi
  8008c8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008cb:	89 f0                	mov    %esi,%eax
  8008cd:	c1 f8 1f             	sar    $0x1f,%eax
  8008d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008d3:	eb 16                	jmp    8008eb <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  8008d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d8:	8d 50 04             	lea    0x4(%eax),%edx
  8008db:	89 55 14             	mov    %edx,0x14(%ebp)
  8008de:	8b 30                	mov    (%eax),%esi
  8008e0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008e3:	89 f0                	mov    %esi,%eax
  8008e5:	c1 f8 1f             	sar    $0x1f,%eax
  8008e8:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  8008eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008ee:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  8008f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8008f6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008fa:	0f 89 80 00 00 00    	jns    800980 <vprintfmt+0x37c>
				putch('-', putdat);
  800900:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800904:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80090b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80090e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800911:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800914:	f7 d8                	neg    %eax
  800916:	83 d2 00             	adc    $0x0,%edx
  800919:	f7 da                	neg    %edx
			base = 10;
  80091b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800920:	eb 5e                	jmp    800980 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800922:	8d 45 14             	lea    0x14(%ebp),%eax
  800925:	e8 5b fc ff ff       	call   800585 <getuint>
			base = 10;
  80092a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80092f:	eb 4f                	jmp    800980 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800931:	8d 45 14             	lea    0x14(%ebp),%eax
  800934:	e8 4c fc ff ff       	call   800585 <getuint>
			base = 8;
  800939:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80093e:	eb 40                	jmp    800980 <vprintfmt+0x37c>
			putch('0', putdat);
  800940:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800944:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80094b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80094e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800952:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800959:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80095c:	8b 45 14             	mov    0x14(%ebp),%eax
  80095f:	8d 50 04             	lea    0x4(%eax),%edx
  800962:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800965:	8b 00                	mov    (%eax),%eax
  800967:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80096c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800971:	eb 0d                	jmp    800980 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800973:	8d 45 14             	lea    0x14(%ebp),%eax
  800976:	e8 0a fc ff ff       	call   800585 <getuint>
			base = 16;
  80097b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800980:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800984:	89 74 24 10          	mov    %esi,0x10(%esp)
  800988:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80098b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80098f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800993:	89 04 24             	mov    %eax,(%esp)
  800996:	89 54 24 04          	mov    %edx,0x4(%esp)
  80099a:	89 fa                	mov    %edi,%edx
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	e8 ec fa ff ff       	call   800490 <printnum>
			break;
  8009a4:	e9 84 fc ff ff       	jmp    80062d <vprintfmt+0x29>
			putch(ch, putdat);
  8009a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ad:	89 0c 24             	mov    %ecx,(%esp)
  8009b0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009b3:	e9 75 fc ff ff       	jmp    80062d <vprintfmt+0x29>
			putch('%', putdat);
  8009b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009bc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009c3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009c6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009ca:	0f 84 5b fc ff ff    	je     80062b <vprintfmt+0x27>
  8009d0:	89 f3                	mov    %esi,%ebx
  8009d2:	83 eb 01             	sub    $0x1,%ebx
  8009d5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8009d9:	75 f7                	jne    8009d2 <vprintfmt+0x3ce>
  8009db:	e9 4d fc ff ff       	jmp    80062d <vprintfmt+0x29>
}
  8009e0:	83 c4 3c             	add    $0x3c,%esp
  8009e3:	5b                   	pop    %ebx
  8009e4:	5e                   	pop    %esi
  8009e5:	5f                   	pop    %edi
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	83 ec 28             	sub    $0x28,%esp
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009f7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009fb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a05:	85 c0                	test   %eax,%eax
  800a07:	74 30                	je     800a39 <vsnprintf+0x51>
  800a09:	85 d2                	test   %edx,%edx
  800a0b:	7e 2c                	jle    800a39 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a0d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a10:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a14:	8b 45 10             	mov    0x10(%ebp),%eax
  800a17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a1b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a22:	c7 04 24 bf 05 80 00 	movl   $0x8005bf,(%esp)
  800a29:	e8 d6 fb ff ff       	call   800604 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a31:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a37:	eb 05                	jmp    800a3e <vsnprintf+0x56>
		return -E_INVAL;
  800a39:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a46:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a50:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	89 04 24             	mov    %eax,(%esp)
  800a61:	e8 82 ff ff ff       	call   8009e8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a66:	c9                   	leave  
  800a67:	c3                   	ret    
  800a68:	66 90                	xchg   %ax,%ax
  800a6a:	66 90                	xchg   %ax,%ax
  800a6c:	66 90                	xchg   %ax,%ax
  800a6e:	66 90                	xchg   %ax,%ax

00800a70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a76:	80 3a 00             	cmpb   $0x0,(%edx)
  800a79:	74 10                	je     800a8b <strlen+0x1b>
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a80:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a83:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a87:	75 f7                	jne    800a80 <strlen+0x10>
  800a89:	eb 05                	jmp    800a90 <strlen+0x20>
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	53                   	push   %ebx
  800a96:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a9c:	85 c9                	test   %ecx,%ecx
  800a9e:	74 1c                	je     800abc <strnlen+0x2a>
  800aa0:	80 3b 00             	cmpb   $0x0,(%ebx)
  800aa3:	74 1e                	je     800ac3 <strnlen+0x31>
  800aa5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800aaa:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aac:	39 ca                	cmp    %ecx,%edx
  800aae:	74 18                	je     800ac8 <strnlen+0x36>
  800ab0:	83 c2 01             	add    $0x1,%edx
  800ab3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800ab8:	75 f0                	jne    800aaa <strnlen+0x18>
  800aba:	eb 0c                	jmp    800ac8 <strnlen+0x36>
  800abc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac1:	eb 05                	jmp    800ac8 <strnlen+0x36>
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	53                   	push   %ebx
  800acf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ad5:	89 c2                	mov    %eax,%edx
  800ad7:	83 c2 01             	add    $0x1,%edx
  800ada:	83 c1 01             	add    $0x1,%ecx
  800add:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ae1:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ae4:	84 db                	test   %bl,%bl
  800ae6:	75 ef                	jne    800ad7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	53                   	push   %ebx
  800aef:	83 ec 08             	sub    $0x8,%esp
  800af2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800af5:	89 1c 24             	mov    %ebx,(%esp)
  800af8:	e8 73 ff ff ff       	call   800a70 <strlen>
	strcpy(dst + len, src);
  800afd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b00:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b04:	01 d8                	add    %ebx,%eax
  800b06:	89 04 24             	mov    %eax,(%esp)
  800b09:	e8 bd ff ff ff       	call   800acb <strcpy>
	return dst;
}
  800b0e:	89 d8                	mov    %ebx,%eax
  800b10:	83 c4 08             	add    $0x8,%esp
  800b13:	5b                   	pop    %ebx
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	8b 75 08             	mov    0x8(%ebp),%esi
  800b1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b24:	85 db                	test   %ebx,%ebx
  800b26:	74 17                	je     800b3f <strncpy+0x29>
  800b28:	01 f3                	add    %esi,%ebx
  800b2a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800b2c:	83 c1 01             	add    $0x1,%ecx
  800b2f:	0f b6 02             	movzbl (%edx),%eax
  800b32:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b35:	80 3a 01             	cmpb   $0x1,(%edx)
  800b38:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800b3b:	39 d9                	cmp    %ebx,%ecx
  800b3d:	75 ed                	jne    800b2c <strncpy+0x16>
	}
	return ret;
}
  800b3f:	89 f0                	mov    %esi,%eax
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b51:	8b 75 10             	mov    0x10(%ebp),%esi
  800b54:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b56:	85 f6                	test   %esi,%esi
  800b58:	74 34                	je     800b8e <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800b5a:	83 fe 01             	cmp    $0x1,%esi
  800b5d:	74 26                	je     800b85 <strlcpy+0x40>
  800b5f:	0f b6 0b             	movzbl (%ebx),%ecx
  800b62:	84 c9                	test   %cl,%cl
  800b64:	74 23                	je     800b89 <strlcpy+0x44>
  800b66:	83 ee 02             	sub    $0x2,%esi
  800b69:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  800b6e:	83 c0 01             	add    $0x1,%eax
  800b71:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800b74:	39 f2                	cmp    %esi,%edx
  800b76:	74 13                	je     800b8b <strlcpy+0x46>
  800b78:	83 c2 01             	add    $0x1,%edx
  800b7b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b7f:	84 c9                	test   %cl,%cl
  800b81:	75 eb                	jne    800b6e <strlcpy+0x29>
  800b83:	eb 06                	jmp    800b8b <strlcpy+0x46>
  800b85:	89 f8                	mov    %edi,%eax
  800b87:	eb 02                	jmp    800b8b <strlcpy+0x46>
  800b89:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  800b8b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b8e:	29 f8                	sub    %edi,%eax
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b9e:	0f b6 01             	movzbl (%ecx),%eax
  800ba1:	84 c0                	test   %al,%al
  800ba3:	74 15                	je     800bba <strcmp+0x25>
  800ba5:	3a 02                	cmp    (%edx),%al
  800ba7:	75 11                	jne    800bba <strcmp+0x25>
		p++, q++;
  800ba9:	83 c1 01             	add    $0x1,%ecx
  800bac:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800baf:	0f b6 01             	movzbl (%ecx),%eax
  800bb2:	84 c0                	test   %al,%al
  800bb4:	74 04                	je     800bba <strcmp+0x25>
  800bb6:	3a 02                	cmp    (%edx),%al
  800bb8:	74 ef                	je     800ba9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bba:	0f b6 c0             	movzbl %al,%eax
  800bbd:	0f b6 12             	movzbl (%edx),%edx
  800bc0:	29 d0                	sub    %edx,%eax
}
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcf:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800bd2:	85 f6                	test   %esi,%esi
  800bd4:	74 29                	je     800bff <strncmp+0x3b>
  800bd6:	0f b6 03             	movzbl (%ebx),%eax
  800bd9:	84 c0                	test   %al,%al
  800bdb:	74 30                	je     800c0d <strncmp+0x49>
  800bdd:	3a 02                	cmp    (%edx),%al
  800bdf:	75 2c                	jne    800c0d <strncmp+0x49>
  800be1:	8d 43 01             	lea    0x1(%ebx),%eax
  800be4:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800be6:	89 c3                	mov    %eax,%ebx
  800be8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800beb:	39 f0                	cmp    %esi,%eax
  800bed:	74 17                	je     800c06 <strncmp+0x42>
  800bef:	0f b6 08             	movzbl (%eax),%ecx
  800bf2:	84 c9                	test   %cl,%cl
  800bf4:	74 17                	je     800c0d <strncmp+0x49>
  800bf6:	83 c0 01             	add    $0x1,%eax
  800bf9:	3a 0a                	cmp    (%edx),%cl
  800bfb:	74 e9                	je     800be6 <strncmp+0x22>
  800bfd:	eb 0e                	jmp    800c0d <strncmp+0x49>
	if (n == 0)
		return 0;
  800bff:	b8 00 00 00 00       	mov    $0x0,%eax
  800c04:	eb 0f                	jmp    800c15 <strncmp+0x51>
  800c06:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0b:	eb 08                	jmp    800c15 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c0d:	0f b6 03             	movzbl (%ebx),%eax
  800c10:	0f b6 12             	movzbl (%edx),%edx
  800c13:	29 d0                	sub    %edx,%eax
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	53                   	push   %ebx
  800c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c20:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c23:	0f b6 18             	movzbl (%eax),%ebx
  800c26:	84 db                	test   %bl,%bl
  800c28:	74 1d                	je     800c47 <strchr+0x2e>
  800c2a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800c2c:	38 d3                	cmp    %dl,%bl
  800c2e:	75 06                	jne    800c36 <strchr+0x1d>
  800c30:	eb 1a                	jmp    800c4c <strchr+0x33>
  800c32:	38 ca                	cmp    %cl,%dl
  800c34:	74 16                	je     800c4c <strchr+0x33>
	for (; *s; s++)
  800c36:	83 c0 01             	add    $0x1,%eax
  800c39:	0f b6 10             	movzbl (%eax),%edx
  800c3c:	84 d2                	test   %dl,%dl
  800c3e:	75 f2                	jne    800c32 <strchr+0x19>
			return (char *) s;
	return 0;
  800c40:	b8 00 00 00 00       	mov    $0x0,%eax
  800c45:	eb 05                	jmp    800c4c <strchr+0x33>
  800c47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c4c:	5b                   	pop    %ebx
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	53                   	push   %ebx
  800c53:	8b 45 08             	mov    0x8(%ebp),%eax
  800c56:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c59:	0f b6 18             	movzbl (%eax),%ebx
  800c5c:	84 db                	test   %bl,%bl
  800c5e:	74 16                	je     800c76 <strfind+0x27>
  800c60:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800c62:	38 d3                	cmp    %dl,%bl
  800c64:	75 06                	jne    800c6c <strfind+0x1d>
  800c66:	eb 0e                	jmp    800c76 <strfind+0x27>
  800c68:	38 ca                	cmp    %cl,%dl
  800c6a:	74 0a                	je     800c76 <strfind+0x27>
	for (; *s; s++)
  800c6c:	83 c0 01             	add    $0x1,%eax
  800c6f:	0f b6 10             	movzbl (%eax),%edx
  800c72:	84 d2                	test   %dl,%dl
  800c74:	75 f2                	jne    800c68 <strfind+0x19>
			break;
	return (char *) s;
}
  800c76:	5b                   	pop    %ebx
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c82:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c85:	85 c9                	test   %ecx,%ecx
  800c87:	74 36                	je     800cbf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c89:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c8f:	75 28                	jne    800cb9 <memset+0x40>
  800c91:	f6 c1 03             	test   $0x3,%cl
  800c94:	75 23                	jne    800cb9 <memset+0x40>
		c &= 0xFF;
  800c96:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c9a:	89 d3                	mov    %edx,%ebx
  800c9c:	c1 e3 08             	shl    $0x8,%ebx
  800c9f:	89 d6                	mov    %edx,%esi
  800ca1:	c1 e6 18             	shl    $0x18,%esi
  800ca4:	89 d0                	mov    %edx,%eax
  800ca6:	c1 e0 10             	shl    $0x10,%eax
  800ca9:	09 f0                	or     %esi,%eax
  800cab:	09 c2                	or     %eax,%edx
  800cad:	89 d0                	mov    %edx,%eax
  800caf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cb1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800cb4:	fc                   	cld    
  800cb5:	f3 ab                	rep stos %eax,%es:(%edi)
  800cb7:	eb 06                	jmp    800cbf <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbc:	fc                   	cld    
  800cbd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cbf:	89 f8                	mov    %edi,%eax
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cd4:	39 c6                	cmp    %eax,%esi
  800cd6:	73 35                	jae    800d0d <memmove+0x47>
  800cd8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cdb:	39 d0                	cmp    %edx,%eax
  800cdd:	73 2e                	jae    800d0d <memmove+0x47>
		s += n;
		d += n;
  800cdf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ce2:	89 d6                	mov    %edx,%esi
  800ce4:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cec:	75 13                	jne    800d01 <memmove+0x3b>
  800cee:	f6 c1 03             	test   $0x3,%cl
  800cf1:	75 0e                	jne    800d01 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cf3:	83 ef 04             	sub    $0x4,%edi
  800cf6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cf9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800cfc:	fd                   	std    
  800cfd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cff:	eb 09                	jmp    800d0a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d01:	83 ef 01             	sub    $0x1,%edi
  800d04:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d07:	fd                   	std    
  800d08:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d0a:	fc                   	cld    
  800d0b:	eb 1d                	jmp    800d2a <memmove+0x64>
  800d0d:	89 f2                	mov    %esi,%edx
  800d0f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d11:	f6 c2 03             	test   $0x3,%dl
  800d14:	75 0f                	jne    800d25 <memmove+0x5f>
  800d16:	f6 c1 03             	test   $0x3,%cl
  800d19:	75 0a                	jne    800d25 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d1b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d1e:	89 c7                	mov    %eax,%edi
  800d20:	fc                   	cld    
  800d21:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d23:	eb 05                	jmp    800d2a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800d25:	89 c7                	mov    %eax,%edi
  800d27:	fc                   	cld    
  800d28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d34:	8b 45 10             	mov    0x10(%ebp),%eax
  800d37:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d42:	8b 45 08             	mov    0x8(%ebp),%eax
  800d45:	89 04 24             	mov    %eax,(%esp)
  800d48:	e8 79 ff ff ff       	call   800cc6 <memmove>
}
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
  800d55:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d58:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d5b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800d61:	85 c0                	test   %eax,%eax
  800d63:	74 36                	je     800d9b <memcmp+0x4c>
		if (*s1 != *s2)
  800d65:	0f b6 03             	movzbl (%ebx),%eax
  800d68:	0f b6 0e             	movzbl (%esi),%ecx
  800d6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d70:	38 c8                	cmp    %cl,%al
  800d72:	74 1c                	je     800d90 <memcmp+0x41>
  800d74:	eb 10                	jmp    800d86 <memcmp+0x37>
  800d76:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800d7b:	83 c2 01             	add    $0x1,%edx
  800d7e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800d82:	38 c8                	cmp    %cl,%al
  800d84:	74 0a                	je     800d90 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800d86:	0f b6 c0             	movzbl %al,%eax
  800d89:	0f b6 c9             	movzbl %cl,%ecx
  800d8c:	29 c8                	sub    %ecx,%eax
  800d8e:	eb 10                	jmp    800da0 <memcmp+0x51>
	while (n-- > 0) {
  800d90:	39 fa                	cmp    %edi,%edx
  800d92:	75 e2                	jne    800d76 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800d94:	b8 00 00 00 00       	mov    $0x0,%eax
  800d99:	eb 05                	jmp    800da0 <memcmp+0x51>
  800d9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	53                   	push   %ebx
  800da9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800daf:	89 c2                	mov    %eax,%edx
  800db1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800db4:	39 d0                	cmp    %edx,%eax
  800db6:	73 13                	jae    800dcb <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800db8:	89 d9                	mov    %ebx,%ecx
  800dba:	38 18                	cmp    %bl,(%eax)
  800dbc:	75 06                	jne    800dc4 <memfind+0x1f>
  800dbe:	eb 0b                	jmp    800dcb <memfind+0x26>
  800dc0:	38 08                	cmp    %cl,(%eax)
  800dc2:	74 07                	je     800dcb <memfind+0x26>
	for (; s < ends; s++)
  800dc4:	83 c0 01             	add    $0x1,%eax
  800dc7:	39 d0                	cmp    %edx,%eax
  800dc9:	75 f5                	jne    800dc0 <memfind+0x1b>
			break;
	return (void *) s;
}
  800dcb:	5b                   	pop    %ebx
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd7:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dda:	0f b6 0a             	movzbl (%edx),%ecx
  800ddd:	80 f9 09             	cmp    $0x9,%cl
  800de0:	74 05                	je     800de7 <strtol+0x19>
  800de2:	80 f9 20             	cmp    $0x20,%cl
  800de5:	75 10                	jne    800df7 <strtol+0x29>
		s++;
  800de7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800dea:	0f b6 0a             	movzbl (%edx),%ecx
  800ded:	80 f9 09             	cmp    $0x9,%cl
  800df0:	74 f5                	je     800de7 <strtol+0x19>
  800df2:	80 f9 20             	cmp    $0x20,%cl
  800df5:	74 f0                	je     800de7 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800df7:	80 f9 2b             	cmp    $0x2b,%cl
  800dfa:	75 0a                	jne    800e06 <strtol+0x38>
		s++;
  800dfc:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800dff:	bf 00 00 00 00       	mov    $0x0,%edi
  800e04:	eb 11                	jmp    800e17 <strtol+0x49>
  800e06:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800e0b:	80 f9 2d             	cmp    $0x2d,%cl
  800e0e:	75 07                	jne    800e17 <strtol+0x49>
		s++, neg = 1;
  800e10:	83 c2 01             	add    $0x1,%edx
  800e13:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e17:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800e1c:	75 15                	jne    800e33 <strtol+0x65>
  800e1e:	80 3a 30             	cmpb   $0x30,(%edx)
  800e21:	75 10                	jne    800e33 <strtol+0x65>
  800e23:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e27:	75 0a                	jne    800e33 <strtol+0x65>
		s += 2, base = 16;
  800e29:	83 c2 02             	add    $0x2,%edx
  800e2c:	b8 10 00 00 00       	mov    $0x10,%eax
  800e31:	eb 10                	jmp    800e43 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800e33:	85 c0                	test   %eax,%eax
  800e35:	75 0c                	jne    800e43 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e37:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800e39:	80 3a 30             	cmpb   $0x30,(%edx)
  800e3c:	75 05                	jne    800e43 <strtol+0x75>
		s++, base = 8;
  800e3e:	83 c2 01             	add    $0x1,%edx
  800e41:	b0 08                	mov    $0x8,%al
		base = 10;
  800e43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e48:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e4b:	0f b6 0a             	movzbl (%edx),%ecx
  800e4e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800e51:	89 f0                	mov    %esi,%eax
  800e53:	3c 09                	cmp    $0x9,%al
  800e55:	77 08                	ja     800e5f <strtol+0x91>
			dig = *s - '0';
  800e57:	0f be c9             	movsbl %cl,%ecx
  800e5a:	83 e9 30             	sub    $0x30,%ecx
  800e5d:	eb 20                	jmp    800e7f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800e5f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800e62:	89 f0                	mov    %esi,%eax
  800e64:	3c 19                	cmp    $0x19,%al
  800e66:	77 08                	ja     800e70 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800e68:	0f be c9             	movsbl %cl,%ecx
  800e6b:	83 e9 57             	sub    $0x57,%ecx
  800e6e:	eb 0f                	jmp    800e7f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800e70:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e73:	89 f0                	mov    %esi,%eax
  800e75:	3c 19                	cmp    $0x19,%al
  800e77:	77 16                	ja     800e8f <strtol+0xc1>
			dig = *s - 'A' + 10;
  800e79:	0f be c9             	movsbl %cl,%ecx
  800e7c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e7f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e82:	7d 0f                	jge    800e93 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800e84:	83 c2 01             	add    $0x1,%edx
  800e87:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e8b:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e8d:	eb bc                	jmp    800e4b <strtol+0x7d>
  800e8f:	89 d8                	mov    %ebx,%eax
  800e91:	eb 02                	jmp    800e95 <strtol+0xc7>
  800e93:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800e95:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e99:	74 05                	je     800ea0 <strtol+0xd2>
		*endptr = (char *) s;
  800e9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e9e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800ea0:	f7 d8                	neg    %eax
  800ea2:	85 ff                	test   %edi,%edi
  800ea4:	0f 44 c3             	cmove  %ebx,%eax
}
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    
  800eac:	66 90                	xchg   %ax,%ax
  800eae:	66 90                	xchg   %ax,%ax

00800eb0 <__udivdi3>:
  800eb0:	55                   	push   %ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	83 ec 0c             	sub    $0xc,%esp
  800eb6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800eba:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800ebe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800ec2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ecc:	89 ea                	mov    %ebp,%edx
  800ece:	89 0c 24             	mov    %ecx,(%esp)
  800ed1:	75 2d                	jne    800f00 <__udivdi3+0x50>
  800ed3:	39 e9                	cmp    %ebp,%ecx
  800ed5:	77 61                	ja     800f38 <__udivdi3+0x88>
  800ed7:	85 c9                	test   %ecx,%ecx
  800ed9:	89 ce                	mov    %ecx,%esi
  800edb:	75 0b                	jne    800ee8 <__udivdi3+0x38>
  800edd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee2:	31 d2                	xor    %edx,%edx
  800ee4:	f7 f1                	div    %ecx
  800ee6:	89 c6                	mov    %eax,%esi
  800ee8:	31 d2                	xor    %edx,%edx
  800eea:	89 e8                	mov    %ebp,%eax
  800eec:	f7 f6                	div    %esi
  800eee:	89 c5                	mov    %eax,%ebp
  800ef0:	89 f8                	mov    %edi,%eax
  800ef2:	f7 f6                	div    %esi
  800ef4:	89 ea                	mov    %ebp,%edx
  800ef6:	83 c4 0c             	add    $0xc,%esp
  800ef9:	5e                   	pop    %esi
  800efa:	5f                   	pop    %edi
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    
  800efd:	8d 76 00             	lea    0x0(%esi),%esi
  800f00:	39 e8                	cmp    %ebp,%eax
  800f02:	77 24                	ja     800f28 <__udivdi3+0x78>
  800f04:	0f bd e8             	bsr    %eax,%ebp
  800f07:	83 f5 1f             	xor    $0x1f,%ebp
  800f0a:	75 3c                	jne    800f48 <__udivdi3+0x98>
  800f0c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f10:	39 34 24             	cmp    %esi,(%esp)
  800f13:	0f 86 9f 00 00 00    	jbe    800fb8 <__udivdi3+0x108>
  800f19:	39 d0                	cmp    %edx,%eax
  800f1b:	0f 82 97 00 00 00    	jb     800fb8 <__udivdi3+0x108>
  800f21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f28:	31 d2                	xor    %edx,%edx
  800f2a:	31 c0                	xor    %eax,%eax
  800f2c:	83 c4 0c             	add    $0xc,%esp
  800f2f:	5e                   	pop    %esi
  800f30:	5f                   	pop    %edi
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    
  800f33:	90                   	nop
  800f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f38:	89 f8                	mov    %edi,%eax
  800f3a:	f7 f1                	div    %ecx
  800f3c:	31 d2                	xor    %edx,%edx
  800f3e:	83 c4 0c             	add    $0xc,%esp
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    
  800f45:	8d 76 00             	lea    0x0(%esi),%esi
  800f48:	89 e9                	mov    %ebp,%ecx
  800f4a:	8b 3c 24             	mov    (%esp),%edi
  800f4d:	d3 e0                	shl    %cl,%eax
  800f4f:	89 c6                	mov    %eax,%esi
  800f51:	b8 20 00 00 00       	mov    $0x20,%eax
  800f56:	29 e8                	sub    %ebp,%eax
  800f58:	89 c1                	mov    %eax,%ecx
  800f5a:	d3 ef                	shr    %cl,%edi
  800f5c:	89 e9                	mov    %ebp,%ecx
  800f5e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f62:	8b 3c 24             	mov    (%esp),%edi
  800f65:	09 74 24 08          	or     %esi,0x8(%esp)
  800f69:	89 d6                	mov    %edx,%esi
  800f6b:	d3 e7                	shl    %cl,%edi
  800f6d:	89 c1                	mov    %eax,%ecx
  800f6f:	89 3c 24             	mov    %edi,(%esp)
  800f72:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f76:	d3 ee                	shr    %cl,%esi
  800f78:	89 e9                	mov    %ebp,%ecx
  800f7a:	d3 e2                	shl    %cl,%edx
  800f7c:	89 c1                	mov    %eax,%ecx
  800f7e:	d3 ef                	shr    %cl,%edi
  800f80:	09 d7                	or     %edx,%edi
  800f82:	89 f2                	mov    %esi,%edx
  800f84:	89 f8                	mov    %edi,%eax
  800f86:	f7 74 24 08          	divl   0x8(%esp)
  800f8a:	89 d6                	mov    %edx,%esi
  800f8c:	89 c7                	mov    %eax,%edi
  800f8e:	f7 24 24             	mull   (%esp)
  800f91:	39 d6                	cmp    %edx,%esi
  800f93:	89 14 24             	mov    %edx,(%esp)
  800f96:	72 30                	jb     800fc8 <__udivdi3+0x118>
  800f98:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f9c:	89 e9                	mov    %ebp,%ecx
  800f9e:	d3 e2                	shl    %cl,%edx
  800fa0:	39 c2                	cmp    %eax,%edx
  800fa2:	73 05                	jae    800fa9 <__udivdi3+0xf9>
  800fa4:	3b 34 24             	cmp    (%esp),%esi
  800fa7:	74 1f                	je     800fc8 <__udivdi3+0x118>
  800fa9:	89 f8                	mov    %edi,%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	e9 7a ff ff ff       	jmp    800f2c <__udivdi3+0x7c>
  800fb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fb8:	31 d2                	xor    %edx,%edx
  800fba:	b8 01 00 00 00       	mov    $0x1,%eax
  800fbf:	e9 68 ff ff ff       	jmp    800f2c <__udivdi3+0x7c>
  800fc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fc8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	83 c4 0c             	add    $0xc,%esp
  800fd0:	5e                   	pop    %esi
  800fd1:	5f                   	pop    %edi
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    
  800fd4:	66 90                	xchg   %ax,%ax
  800fd6:	66 90                	xchg   %ax,%ax
  800fd8:	66 90                	xchg   %ax,%ax
  800fda:	66 90                	xchg   %ax,%ax
  800fdc:	66 90                	xchg   %ax,%ax
  800fde:	66 90                	xchg   %ax,%ax

00800fe0 <__umoddi3>:
  800fe0:	55                   	push   %ebp
  800fe1:	57                   	push   %edi
  800fe2:	56                   	push   %esi
  800fe3:	83 ec 14             	sub    $0x14,%esp
  800fe6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800fea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800fee:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800ff2:	89 c7                	mov    %eax,%edi
  800ff4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ffc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801000:	89 34 24             	mov    %esi,(%esp)
  801003:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801007:	85 c0                	test   %eax,%eax
  801009:	89 c2                	mov    %eax,%edx
  80100b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80100f:	75 17                	jne    801028 <__umoddi3+0x48>
  801011:	39 fe                	cmp    %edi,%esi
  801013:	76 4b                	jbe    801060 <__umoddi3+0x80>
  801015:	89 c8                	mov    %ecx,%eax
  801017:	89 fa                	mov    %edi,%edx
  801019:	f7 f6                	div    %esi
  80101b:	89 d0                	mov    %edx,%eax
  80101d:	31 d2                	xor    %edx,%edx
  80101f:	83 c4 14             	add    $0x14,%esp
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    
  801026:	66 90                	xchg   %ax,%ax
  801028:	39 f8                	cmp    %edi,%eax
  80102a:	77 54                	ja     801080 <__umoddi3+0xa0>
  80102c:	0f bd e8             	bsr    %eax,%ebp
  80102f:	83 f5 1f             	xor    $0x1f,%ebp
  801032:	75 5c                	jne    801090 <__umoddi3+0xb0>
  801034:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801038:	39 3c 24             	cmp    %edi,(%esp)
  80103b:	0f 87 e7 00 00 00    	ja     801128 <__umoddi3+0x148>
  801041:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801045:	29 f1                	sub    %esi,%ecx
  801047:	19 c7                	sbb    %eax,%edi
  801049:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80104d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801051:	8b 44 24 08          	mov    0x8(%esp),%eax
  801055:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801059:	83 c4 14             	add    $0x14,%esp
  80105c:	5e                   	pop    %esi
  80105d:	5f                   	pop    %edi
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    
  801060:	85 f6                	test   %esi,%esi
  801062:	89 f5                	mov    %esi,%ebp
  801064:	75 0b                	jne    801071 <__umoddi3+0x91>
  801066:	b8 01 00 00 00       	mov    $0x1,%eax
  80106b:	31 d2                	xor    %edx,%edx
  80106d:	f7 f6                	div    %esi
  80106f:	89 c5                	mov    %eax,%ebp
  801071:	8b 44 24 04          	mov    0x4(%esp),%eax
  801075:	31 d2                	xor    %edx,%edx
  801077:	f7 f5                	div    %ebp
  801079:	89 c8                	mov    %ecx,%eax
  80107b:	f7 f5                	div    %ebp
  80107d:	eb 9c                	jmp    80101b <__umoddi3+0x3b>
  80107f:	90                   	nop
  801080:	89 c8                	mov    %ecx,%eax
  801082:	89 fa                	mov    %edi,%edx
  801084:	83 c4 14             	add    $0x14,%esp
  801087:	5e                   	pop    %esi
  801088:	5f                   	pop    %edi
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    
  80108b:	90                   	nop
  80108c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801090:	8b 04 24             	mov    (%esp),%eax
  801093:	be 20 00 00 00       	mov    $0x20,%esi
  801098:	89 e9                	mov    %ebp,%ecx
  80109a:	29 ee                	sub    %ebp,%esi
  80109c:	d3 e2                	shl    %cl,%edx
  80109e:	89 f1                	mov    %esi,%ecx
  8010a0:	d3 e8                	shr    %cl,%eax
  8010a2:	89 e9                	mov    %ebp,%ecx
  8010a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a8:	8b 04 24             	mov    (%esp),%eax
  8010ab:	09 54 24 04          	or     %edx,0x4(%esp)
  8010af:	89 fa                	mov    %edi,%edx
  8010b1:	d3 e0                	shl    %cl,%eax
  8010b3:	89 f1                	mov    %esi,%ecx
  8010b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8010bd:	d3 ea                	shr    %cl,%edx
  8010bf:	89 e9                	mov    %ebp,%ecx
  8010c1:	d3 e7                	shl    %cl,%edi
  8010c3:	89 f1                	mov    %esi,%ecx
  8010c5:	d3 e8                	shr    %cl,%eax
  8010c7:	89 e9                	mov    %ebp,%ecx
  8010c9:	09 f8                	or     %edi,%eax
  8010cb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8010cf:	f7 74 24 04          	divl   0x4(%esp)
  8010d3:	d3 e7                	shl    %cl,%edi
  8010d5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010d9:	89 d7                	mov    %edx,%edi
  8010db:	f7 64 24 08          	mull   0x8(%esp)
  8010df:	39 d7                	cmp    %edx,%edi
  8010e1:	89 c1                	mov    %eax,%ecx
  8010e3:	89 14 24             	mov    %edx,(%esp)
  8010e6:	72 2c                	jb     801114 <__umoddi3+0x134>
  8010e8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8010ec:	72 22                	jb     801110 <__umoddi3+0x130>
  8010ee:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010f2:	29 c8                	sub    %ecx,%eax
  8010f4:	19 d7                	sbb    %edx,%edi
  8010f6:	89 e9                	mov    %ebp,%ecx
  8010f8:	89 fa                	mov    %edi,%edx
  8010fa:	d3 e8                	shr    %cl,%eax
  8010fc:	89 f1                	mov    %esi,%ecx
  8010fe:	d3 e2                	shl    %cl,%edx
  801100:	89 e9                	mov    %ebp,%ecx
  801102:	d3 ef                	shr    %cl,%edi
  801104:	09 d0                	or     %edx,%eax
  801106:	89 fa                	mov    %edi,%edx
  801108:	83 c4 14             	add    $0x14,%esp
  80110b:	5e                   	pop    %esi
  80110c:	5f                   	pop    %edi
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    
  80110f:	90                   	nop
  801110:	39 d7                	cmp    %edx,%edi
  801112:	75 da                	jne    8010ee <__umoddi3+0x10e>
  801114:	8b 14 24             	mov    (%esp),%edx
  801117:	89 c1                	mov    %eax,%ecx
  801119:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80111d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801121:	eb cb                	jmp    8010ee <__umoddi3+0x10e>
  801123:	90                   	nop
  801124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801128:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80112c:	0f 82 0f ff ff ff    	jb     801041 <__umoddi3+0x61>
  801132:	e9 1a ff ff ff       	jmp    801051 <__umoddi3+0x71>
