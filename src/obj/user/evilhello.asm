
obj/user/evilhello：     文件格式 elf32-i386


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
  80002c:	e8 1e 00 00 00       	call   80004f <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800048:	e8 5e 00 00 00       	call   8000ab <sys_cputs>
}
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    

0080004f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004f:	55                   	push   %ebp
  800050:	89 e5                	mov    %esp,%ebp
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 10             	sub    $0x10,%esp
  800057:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80005d:	e8 d8 00 00 00       	call   80013a <sys_getenvid>
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	85 db                	test   %ebx,%ebx
  800076:	7e 07                	jle    80007f <libmain+0x30>
		binaryname = argv[0];
  800078:	8b 06                	mov    (%esi),%eax
  80007a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800083:	89 1c 24             	mov    %ebx,(%esp)
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 07 00 00 00       	call   800097 <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a4:	e8 3f 00 00 00       	call   8000e8 <sys_env_destroy>
}
  8000a9:	c9                   	leave  
  8000aa:	c3                   	ret    

008000ab <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bc:	89 c3                	mov    %eax,%ebx
  8000be:	89 c7                	mov    %eax,%edi
  8000c0:	89 c6                	mov    %eax,%esi
  8000c2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c4:	5b                   	pop    %ebx
  8000c5:	5e                   	pop    %esi
  8000c6:	5f                   	pop    %edi
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    

008000c9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	57                   	push   %edi
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d9:	89 d1                	mov    %edx,%ecx
  8000db:	89 d3                	mov    %edx,%ebx
  8000dd:	89 d7                	mov    %edx,%edi
  8000df:	89 d6                	mov    %edx,%esi
  8000e1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5f                   	pop    %edi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	57                   	push   %edi
  8000ec:	56                   	push   %esi
  8000ed:	53                   	push   %ebx
  8000ee:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8000f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fe:	89 cb                	mov    %ecx,%ebx
  800100:	89 cf                	mov    %ecx,%edi
  800102:	89 ce                	mov    %ecx,%esi
  800104:	cd 30                	int    $0x30
	if(check && ret > 0)
  800106:	85 c0                	test   %eax,%eax
  800108:	7e 28                	jle    800132 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010e:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800115:	00 
  800116:	c7 44 24 08 6a 11 80 	movl   $0x80116a,0x8(%esp)
  80011d:	00 
  80011e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 87 11 80 00 	movl   $0x801187,(%esp)
  80012d:	e8 5b 02 00 00       	call   80038d <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800132:	83 c4 2c             	add    $0x2c,%esp
  800135:	5b                   	pop    %ebx
  800136:	5e                   	pop    %esi
  800137:	5f                   	pop    %edi
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	57                   	push   %edi
  80013e:	56                   	push   %esi
  80013f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800140:	ba 00 00 00 00       	mov    $0x0,%edx
  800145:	b8 02 00 00 00       	mov    $0x2,%eax
  80014a:	89 d1                	mov    %edx,%ecx
  80014c:	89 d3                	mov    %edx,%ebx
  80014e:	89 d7                	mov    %edx,%edi
  800150:	89 d6                	mov    %edx,%esi
  800152:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800154:	5b                   	pop    %ebx
  800155:	5e                   	pop    %esi
  800156:	5f                   	pop    %edi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    

00800159 <sys_yield>:

void
sys_yield(void)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	57                   	push   %edi
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	b8 0a 00 00 00       	mov    $0xa,%eax
  800169:	89 d1                	mov    %edx,%ecx
  80016b:	89 d3                	mov    %edx,%ebx
  80016d:	89 d7                	mov    %edx,%edi
  80016f:	89 d6                	mov    %edx,%esi
  800171:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800173:	5b                   	pop    %ebx
  800174:	5e                   	pop    %esi
  800175:	5f                   	pop    %edi
  800176:	5d                   	pop    %ebp
  800177:	c3                   	ret    

00800178 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800181:	be 00 00 00 00       	mov    $0x0,%esi
  800186:	b8 04 00 00 00       	mov    $0x4,%eax
  80018b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018e:	8b 55 08             	mov    0x8(%ebp),%edx
  800191:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800194:	89 f7                	mov    %esi,%edi
  800196:	cd 30                	int    $0x30
	if(check && ret > 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	7e 28                	jle    8001c4 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001a7:	00 
  8001a8:	c7 44 24 08 6a 11 80 	movl   $0x80116a,0x8(%esp)
  8001af:	00 
  8001b0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b7:	00 
  8001b8:	c7 04 24 87 11 80 00 	movl   $0x801187,(%esp)
  8001bf:	e8 c9 01 00 00       	call   80038d <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c4:	83 c4 2c             	add    $0x2c,%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5f                   	pop    %edi
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8001d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001eb:	85 c0                	test   %eax,%eax
  8001ed:	7e 28                	jle    800217 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f3:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001fa:	00 
  8001fb:	c7 44 24 08 6a 11 80 	movl   $0x80116a,0x8(%esp)
  800202:	00 
  800203:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020a:	00 
  80020b:	c7 04 24 87 11 80 00 	movl   $0x801187,(%esp)
  800212:	e8 76 01 00 00       	call   80038d <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800217:	83 c4 2c             	add    $0x2c,%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5e                   	pop    %esi
  80021c:	5f                   	pop    %edi
  80021d:	5d                   	pop    %ebp
  80021e:	c3                   	ret    

0080021f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	57                   	push   %edi
  800223:	56                   	push   %esi
  800224:	53                   	push   %ebx
  800225:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022d:	b8 06 00 00 00       	mov    $0x6,%eax
  800232:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800235:	8b 55 08             	mov    0x8(%ebp),%edx
  800238:	89 df                	mov    %ebx,%edi
  80023a:	89 de                	mov    %ebx,%esi
  80023c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023e:	85 c0                	test   %eax,%eax
  800240:	7e 28                	jle    80026a <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800242:	89 44 24 10          	mov    %eax,0x10(%esp)
  800246:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80024d:	00 
  80024e:	c7 44 24 08 6a 11 80 	movl   $0x80116a,0x8(%esp)
  800255:	00 
  800256:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025d:	00 
  80025e:	c7 04 24 87 11 80 00 	movl   $0x801187,(%esp)
  800265:	e8 23 01 00 00       	call   80038d <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026a:	83 c4 2c             	add    $0x2c,%esp
  80026d:	5b                   	pop    %ebx
  80026e:	5e                   	pop    %esi
  80026f:	5f                   	pop    %edi
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	57                   	push   %edi
  800276:	56                   	push   %esi
  800277:	53                   	push   %ebx
  800278:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80027b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800280:	b8 08 00 00 00       	mov    $0x8,%eax
  800285:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800288:	8b 55 08             	mov    0x8(%ebp),%edx
  80028b:	89 df                	mov    %ebx,%edi
  80028d:	89 de                	mov    %ebx,%esi
  80028f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800291:	85 c0                	test   %eax,%eax
  800293:	7e 28                	jle    8002bd <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800295:	89 44 24 10          	mov    %eax,0x10(%esp)
  800299:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a0:	00 
  8002a1:	c7 44 24 08 6a 11 80 	movl   $0x80116a,0x8(%esp)
  8002a8:	00 
  8002a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b0:	00 
  8002b1:	c7 04 24 87 11 80 00 	movl   $0x801187,(%esp)
  8002b8:	e8 d0 00 00 00       	call   80038d <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002bd:	83 c4 2c             	add    $0x2c,%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5f                   	pop    %edi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d3:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002db:	8b 55 08             	mov    0x8(%ebp),%edx
  8002de:	89 df                	mov    %ebx,%edi
  8002e0:	89 de                	mov    %ebx,%esi
  8002e2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	7e 28                	jle    800310 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ec:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f3:	00 
  8002f4:	c7 44 24 08 6a 11 80 	movl   $0x80116a,0x8(%esp)
  8002fb:	00 
  8002fc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800303:	00 
  800304:	c7 04 24 87 11 80 00 	movl   $0x801187,(%esp)
  80030b:	e8 7d 00 00 00       	call   80038d <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800310:	83 c4 2c             	add    $0x2c,%esp
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	5f                   	pop    %edi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80031e:	be 00 00 00 00       	mov    $0x0,%esi
  800323:	b8 0b 00 00 00       	mov    $0xb,%eax
  800328:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032b:	8b 55 08             	mov    0x8(%ebp),%edx
  80032e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800331:	8b 7d 14             	mov    0x14(%ebp),%edi
  800334:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800336:	5b                   	pop    %ebx
  800337:	5e                   	pop    %esi
  800338:	5f                   	pop    %edi
  800339:	5d                   	pop    %ebp
  80033a:	c3                   	ret    

0080033b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	57                   	push   %edi
  80033f:	56                   	push   %esi
  800340:	53                   	push   %ebx
  800341:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800344:	b9 00 00 00 00       	mov    $0x0,%ecx
  800349:	b8 0c 00 00 00       	mov    $0xc,%eax
  80034e:	8b 55 08             	mov    0x8(%ebp),%edx
  800351:	89 cb                	mov    %ecx,%ebx
  800353:	89 cf                	mov    %ecx,%edi
  800355:	89 ce                	mov    %ecx,%esi
  800357:	cd 30                	int    $0x30
	if(check && ret > 0)
  800359:	85 c0                	test   %eax,%eax
  80035b:	7e 28                	jle    800385 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800361:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800368:	00 
  800369:	c7 44 24 08 6a 11 80 	movl   $0x80116a,0x8(%esp)
  800370:	00 
  800371:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800378:	00 
  800379:	c7 04 24 87 11 80 00 	movl   $0x801187,(%esp)
  800380:	e8 08 00 00 00       	call   80038d <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800385:	83 c4 2c             	add    $0x2c,%esp
  800388:	5b                   	pop    %ebx
  800389:	5e                   	pop    %esi
  80038a:	5f                   	pop    %edi
  80038b:	5d                   	pop    %ebp
  80038c:	c3                   	ret    

0080038d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	56                   	push   %esi
  800391:	53                   	push   %ebx
  800392:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800395:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800398:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80039e:	e8 97 fd ff ff       	call   80013a <sys_getenvid>
  8003a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b1:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b9:	c7 04 24 98 11 80 00 	movl   $0x801198,(%esp)
  8003c0:	e8 c1 00 00 00       	call   800486 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cc:	89 04 24             	mov    %eax,(%esp)
  8003cf:	e8 51 00 00 00       	call   800425 <vcprintf>
	cprintf("\n");
  8003d4:	c7 04 24 bc 11 80 00 	movl   $0x8011bc,(%esp)
  8003db:	e8 a6 00 00 00       	call   800486 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003e0:	cc                   	int3   
  8003e1:	eb fd                	jmp    8003e0 <_panic+0x53>

008003e3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	53                   	push   %ebx
  8003e7:	83 ec 14             	sub    $0x14,%esp
  8003ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ed:	8b 13                	mov    (%ebx),%edx
  8003ef:	8d 42 01             	lea    0x1(%edx),%eax
  8003f2:	89 03                	mov    %eax,(%ebx)
  8003f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003fb:	3d ff 00 00 00       	cmp    $0xff,%eax
  800400:	75 19                	jne    80041b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800402:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800409:	00 
  80040a:	8d 43 08             	lea    0x8(%ebx),%eax
  80040d:	89 04 24             	mov    %eax,(%esp)
  800410:	e8 96 fc ff ff       	call   8000ab <sys_cputs>
		b->idx = 0;
  800415:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80041b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80041f:	83 c4 14             	add    $0x14,%esp
  800422:	5b                   	pop    %ebx
  800423:	5d                   	pop    %ebp
  800424:	c3                   	ret    

00800425 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800425:	55                   	push   %ebp
  800426:	89 e5                	mov    %esp,%ebp
  800428:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80042e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800435:	00 00 00 
	b.cnt = 0;
  800438:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80043f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800442:	8b 45 0c             	mov    0xc(%ebp),%eax
  800445:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800449:	8b 45 08             	mov    0x8(%ebp),%eax
  80044c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800450:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800456:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045a:	c7 04 24 e3 03 80 00 	movl   $0x8003e3,(%esp)
  800461:	e8 ae 01 00 00       	call   800614 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800466:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80046c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800470:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800476:	89 04 24             	mov    %eax,(%esp)
  800479:	e8 2d fc ff ff       	call   8000ab <sys_cputs>

	return b.cnt;
}
  80047e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800484:	c9                   	leave  
  800485:	c3                   	ret    

00800486 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80048c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80048f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800493:	8b 45 08             	mov    0x8(%ebp),%eax
  800496:	89 04 24             	mov    %eax,(%esp)
  800499:	e8 87 ff ff ff       	call   800425 <vcprintf>
	va_end(ap);

	return cnt;
}
  80049e:	c9                   	leave  
  80049f:	c3                   	ret    

008004a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
  8004a3:	57                   	push   %edi
  8004a4:	56                   	push   %esi
  8004a5:	53                   	push   %ebx
  8004a6:	83 ec 3c             	sub    $0x3c,%esp
  8004a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ac:	89 d7                	mov    %edx,%edi
  8004ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004b7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8004ba:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004c8:	39 f1                	cmp    %esi,%ecx
  8004ca:	72 14                	jb     8004e0 <printnum+0x40>
  8004cc:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004cf:	76 0f                	jbe    8004e0 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d4:	8d 70 ff             	lea    -0x1(%eax),%esi
  8004d7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004da:	85 f6                	test   %esi,%esi
  8004dc:	7f 60                	jg     80053e <printnum+0x9e>
  8004de:	eb 72                	jmp    800552 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004e0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004e3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004e7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004ea:	8d 51 ff             	lea    -0x1(%ecx),%edx
  8004ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004f5:	8b 44 24 08          	mov    0x8(%esp),%eax
  8004f9:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8004fd:	89 c3                	mov    %eax,%ebx
  8004ff:	89 d6                	mov    %edx,%esi
  800501:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800504:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800507:	89 54 24 08          	mov    %edx,0x8(%esp)
  80050b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80050f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800512:	89 04 24             	mov    %eax,(%esp)
  800515:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800518:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051c:	e8 9f 09 00 00       	call   800ec0 <__udivdi3>
  800521:	89 d9                	mov    %ebx,%ecx
  800523:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800527:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80052b:	89 04 24             	mov    %eax,(%esp)
  80052e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800532:	89 fa                	mov    %edi,%edx
  800534:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800537:	e8 64 ff ff ff       	call   8004a0 <printnum>
  80053c:	eb 14                	jmp    800552 <printnum+0xb2>
			putch(padc, putdat);
  80053e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800542:	8b 45 18             	mov    0x18(%ebp),%eax
  800545:	89 04 24             	mov    %eax,(%esp)
  800548:	ff d3                	call   *%ebx
		while (--width > 0)
  80054a:	83 ee 01             	sub    $0x1,%esi
  80054d:	75 ef                	jne    80053e <printnum+0x9e>
  80054f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800552:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800556:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80055a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80055d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800560:	89 44 24 08          	mov    %eax,0x8(%esp)
  800564:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800568:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80056b:	89 04 24             	mov    %eax,(%esp)
  80056e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800571:	89 44 24 04          	mov    %eax,0x4(%esp)
  800575:	e8 76 0a 00 00       	call   800ff0 <__umoddi3>
  80057a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057e:	0f be 80 be 11 80 00 	movsbl 0x8011be(%eax),%eax
  800585:	89 04 24             	mov    %eax,(%esp)
  800588:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80058b:	ff d0                	call   *%eax
}
  80058d:	83 c4 3c             	add    $0x3c,%esp
  800590:	5b                   	pop    %ebx
  800591:	5e                   	pop    %esi
  800592:	5f                   	pop    %edi
  800593:	5d                   	pop    %ebp
  800594:	c3                   	ret    

00800595 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800595:	55                   	push   %ebp
  800596:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800598:	83 fa 01             	cmp    $0x1,%edx
  80059b:	7e 0e                	jle    8005ab <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80059d:	8b 10                	mov    (%eax),%edx
  80059f:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005a2:	89 08                	mov    %ecx,(%eax)
  8005a4:	8b 02                	mov    (%edx),%eax
  8005a6:	8b 52 04             	mov    0x4(%edx),%edx
  8005a9:	eb 22                	jmp    8005cd <getuint+0x38>
	else if (lflag)
  8005ab:	85 d2                	test   %edx,%edx
  8005ad:	74 10                	je     8005bf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005af:	8b 10                	mov    (%eax),%edx
  8005b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005b4:	89 08                	mov    %ecx,(%eax)
  8005b6:	8b 02                	mov    (%edx),%eax
  8005b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005bd:	eb 0e                	jmp    8005cd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005bf:	8b 10                	mov    (%eax),%edx
  8005c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005c4:	89 08                	mov    %ecx,(%eax)
  8005c6:	8b 02                	mov    (%edx),%eax
  8005c8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005cd:	5d                   	pop    %ebp
  8005ce:	c3                   	ret    

008005cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005cf:	55                   	push   %ebp
  8005d0:	89 e5                	mov    %esp,%ebp
  8005d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005d5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005d9:	8b 10                	mov    (%eax),%edx
  8005db:	3b 50 04             	cmp    0x4(%eax),%edx
  8005de:	73 0a                	jae    8005ea <sprintputch+0x1b>
		*b->buf++ = ch;
  8005e0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005e3:	89 08                	mov    %ecx,(%eax)
  8005e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e8:	88 02                	mov    %al,(%edx)
}
  8005ea:	5d                   	pop    %ebp
  8005eb:	c3                   	ret    

008005ec <printfmt>:
{
  8005ec:	55                   	push   %ebp
  8005ed:	89 e5                	mov    %esp,%ebp
  8005ef:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8005f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800600:	8b 45 0c             	mov    0xc(%ebp),%eax
  800603:	89 44 24 04          	mov    %eax,0x4(%esp)
  800607:	8b 45 08             	mov    0x8(%ebp),%eax
  80060a:	89 04 24             	mov    %eax,(%esp)
  80060d:	e8 02 00 00 00       	call   800614 <vprintfmt>
}
  800612:	c9                   	leave  
  800613:	c3                   	ret    

00800614 <vprintfmt>:
{
  800614:	55                   	push   %ebp
  800615:	89 e5                	mov    %esp,%ebp
  800617:	57                   	push   %edi
  800618:	56                   	push   %esi
  800619:	53                   	push   %ebx
  80061a:	83 ec 3c             	sub    $0x3c,%esp
  80061d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800620:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800623:	eb 18                	jmp    80063d <vprintfmt+0x29>
			if (ch == '\0')
  800625:	85 c0                	test   %eax,%eax
  800627:	0f 84 c3 03 00 00    	je     8009f0 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80062d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800631:	89 04 24             	mov    %eax,(%esp)
  800634:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800637:	89 f3                	mov    %esi,%ebx
  800639:	eb 02                	jmp    80063d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80063d:	8d 73 01             	lea    0x1(%ebx),%esi
  800640:	0f b6 03             	movzbl (%ebx),%eax
  800643:	83 f8 25             	cmp    $0x25,%eax
  800646:	75 dd                	jne    800625 <vprintfmt+0x11>
  800648:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80064c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800653:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80065a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800661:	ba 00 00 00 00       	mov    $0x0,%edx
  800666:	eb 1d                	jmp    800685 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800668:	89 de                	mov    %ebx,%esi
			padc = '-';
  80066a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80066e:	eb 15                	jmp    800685 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800670:	89 de                	mov    %ebx,%esi
			padc = '0';
  800672:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800676:	eb 0d                	jmp    800685 <vprintfmt+0x71>
				width = precision, precision = -1;
  800678:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80067b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80067e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800685:	8d 5e 01             	lea    0x1(%esi),%ebx
  800688:	0f b6 06             	movzbl (%esi),%eax
  80068b:	0f b6 c8             	movzbl %al,%ecx
  80068e:	83 e8 23             	sub    $0x23,%eax
  800691:	3c 55                	cmp    $0x55,%al
  800693:	0f 87 2f 03 00 00    	ja     8009c8 <vprintfmt+0x3b4>
  800699:	0f b6 c0             	movzbl %al,%eax
  80069c:	ff 24 85 80 12 80 00 	jmp    *0x801280(,%eax,4)
				precision = precision * 10 + ch - '0';
  8006a3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8006a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  8006a9:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8006ad:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006b0:	83 f9 09             	cmp    $0x9,%ecx
  8006b3:	77 50                	ja     800705 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8006b5:	89 de                	mov    %ebx,%esi
  8006b7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8006ba:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8006bd:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8006c0:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8006c4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006c7:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8006ca:	83 fb 09             	cmp    $0x9,%ebx
  8006cd:	76 eb                	jbe    8006ba <vprintfmt+0xa6>
  8006cf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006d2:	eb 33                	jmp    800707 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 48 04             	lea    0x4(%eax),%ecx
  8006da:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006dd:	8b 00                	mov    (%eax),%eax
  8006df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8006e2:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8006e4:	eb 21                	jmp    800707 <vprintfmt+0xf3>
  8006e6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006e9:	85 c9                	test   %ecx,%ecx
  8006eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f0:	0f 49 c1             	cmovns %ecx,%eax
  8006f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8006f6:	89 de                	mov    %ebx,%esi
  8006f8:	eb 8b                	jmp    800685 <vprintfmt+0x71>
  8006fa:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8006fc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800703:	eb 80                	jmp    800685 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800705:	89 de                	mov    %ebx,%esi
			if (width < 0)
  800707:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80070b:	0f 89 74 ff ff ff    	jns    800685 <vprintfmt+0x71>
  800711:	e9 62 ff ff ff       	jmp    800678 <vprintfmt+0x64>
			lflag++;
  800716:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800719:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80071b:	e9 65 ff ff ff       	jmp    800685 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8d 50 04             	lea    0x4(%eax),%edx
  800726:	89 55 14             	mov    %edx,0x14(%ebp)
  800729:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072d:	8b 00                	mov    (%eax),%eax
  80072f:	89 04 24             	mov    %eax,(%esp)
  800732:	ff 55 08             	call   *0x8(%ebp)
			break;
  800735:	e9 03 ff ff ff       	jmp    80063d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	8d 50 04             	lea    0x4(%eax),%edx
  800740:	89 55 14             	mov    %edx,0x14(%ebp)
  800743:	8b 00                	mov    (%eax),%eax
  800745:	99                   	cltd   
  800746:	31 d0                	xor    %edx,%eax
  800748:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80074a:	83 f8 08             	cmp    $0x8,%eax
  80074d:	7f 0b                	jg     80075a <vprintfmt+0x146>
  80074f:	8b 14 85 e0 13 80 00 	mov    0x8013e0(,%eax,4),%edx
  800756:	85 d2                	test   %edx,%edx
  800758:	75 20                	jne    80077a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80075a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075e:	c7 44 24 08 d6 11 80 	movl   $0x8011d6,0x8(%esp)
  800765:	00 
  800766:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076a:	8b 45 08             	mov    0x8(%ebp),%eax
  80076d:	89 04 24             	mov    %eax,(%esp)
  800770:	e8 77 fe ff ff       	call   8005ec <printfmt>
  800775:	e9 c3 fe ff ff       	jmp    80063d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80077a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80077e:	c7 44 24 08 df 11 80 	movl   $0x8011df,0x8(%esp)
  800785:	00 
  800786:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078a:	8b 45 08             	mov    0x8(%ebp),%eax
  80078d:	89 04 24             	mov    %eax,(%esp)
  800790:	e8 57 fe ff ff       	call   8005ec <printfmt>
  800795:	e9 a3 fe ff ff       	jmp    80063d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  80079a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80079d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8d 50 04             	lea    0x4(%eax),%edx
  8007a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	ba cf 11 80 00       	mov    $0x8011cf,%edx
  8007b2:	0f 45 d0             	cmovne %eax,%edx
  8007b5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8007b8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8007bc:	74 04                	je     8007c2 <vprintfmt+0x1ae>
  8007be:	85 f6                	test   %esi,%esi
  8007c0:	7f 19                	jg     8007db <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007c5:	8d 70 01             	lea    0x1(%eax),%esi
  8007c8:	0f b6 10             	movzbl (%eax),%edx
  8007cb:	0f be c2             	movsbl %dl,%eax
  8007ce:	85 c0                	test   %eax,%eax
  8007d0:	0f 85 95 00 00 00    	jne    80086b <vprintfmt+0x257>
  8007d6:	e9 85 00 00 00       	jmp    800860 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007df:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007e2:	89 04 24             	mov    %eax,(%esp)
  8007e5:	e8 b8 02 00 00       	call   800aa2 <strnlen>
  8007ea:	29 c6                	sub    %eax,%esi
  8007ec:	89 f0                	mov    %esi,%eax
  8007ee:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8007f1:	85 f6                	test   %esi,%esi
  8007f3:	7e cd                	jle    8007c2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8007f5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8007f9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007fc:	89 c3                	mov    %eax,%ebx
  8007fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800802:	89 34 24             	mov    %esi,(%esp)
  800805:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800808:	83 eb 01             	sub    $0x1,%ebx
  80080b:	75 f1                	jne    8007fe <vprintfmt+0x1ea>
  80080d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800810:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800813:	eb ad                	jmp    8007c2 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800815:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800819:	74 1e                	je     800839 <vprintfmt+0x225>
  80081b:	0f be d2             	movsbl %dl,%edx
  80081e:	83 ea 20             	sub    $0x20,%edx
  800821:	83 fa 5e             	cmp    $0x5e,%edx
  800824:	76 13                	jbe    800839 <vprintfmt+0x225>
					putch('?', putdat);
  800826:	8b 45 0c             	mov    0xc(%ebp),%eax
  800829:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800834:	ff 55 08             	call   *0x8(%ebp)
  800837:	eb 0d                	jmp    800846 <vprintfmt+0x232>
					putch(ch, putdat);
  800839:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800840:	89 04 24             	mov    %eax,(%esp)
  800843:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800846:	83 ef 01             	sub    $0x1,%edi
  800849:	83 c6 01             	add    $0x1,%esi
  80084c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800850:	0f be c2             	movsbl %dl,%eax
  800853:	85 c0                	test   %eax,%eax
  800855:	75 20                	jne    800877 <vprintfmt+0x263>
  800857:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80085a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80085d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800860:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800864:	7f 25                	jg     80088b <vprintfmt+0x277>
  800866:	e9 d2 fd ff ff       	jmp    80063d <vprintfmt+0x29>
  80086b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80086e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800871:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800874:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800877:	85 db                	test   %ebx,%ebx
  800879:	78 9a                	js     800815 <vprintfmt+0x201>
  80087b:	83 eb 01             	sub    $0x1,%ebx
  80087e:	79 95                	jns    800815 <vprintfmt+0x201>
  800880:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800883:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800886:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800889:	eb d5                	jmp    800860 <vprintfmt+0x24c>
  80088b:	8b 75 08             	mov    0x8(%ebp),%esi
  80088e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800891:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  800894:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800898:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80089f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8008a1:	83 eb 01             	sub    $0x1,%ebx
  8008a4:	75 ee                	jne    800894 <vprintfmt+0x280>
  8008a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008a9:	e9 8f fd ff ff       	jmp    80063d <vprintfmt+0x29>
	if (lflag >= 2)
  8008ae:	83 fa 01             	cmp    $0x1,%edx
  8008b1:	7e 16                	jle    8008c9 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8008b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b6:	8d 50 08             	lea    0x8(%eax),%edx
  8008b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bc:	8b 50 04             	mov    0x4(%eax),%edx
  8008bf:	8b 00                	mov    (%eax),%eax
  8008c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008c7:	eb 32                	jmp    8008fb <vprintfmt+0x2e7>
	else if (lflag)
  8008c9:	85 d2                	test   %edx,%edx
  8008cb:	74 18                	je     8008e5 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8d 50 04             	lea    0x4(%eax),%edx
  8008d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d6:	8b 30                	mov    (%eax),%esi
  8008d8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008db:	89 f0                	mov    %esi,%eax
  8008dd:	c1 f8 1f             	sar    $0x1f,%eax
  8008e0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008e3:	eb 16                	jmp    8008fb <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  8008e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e8:	8d 50 04             	lea    0x4(%eax),%edx
  8008eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ee:	8b 30                	mov    (%eax),%esi
  8008f0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008f3:	89 f0                	mov    %esi,%eax
  8008f5:	c1 f8 1f             	sar    $0x1f,%eax
  8008f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  8008fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  800901:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800906:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80090a:	0f 89 80 00 00 00    	jns    800990 <vprintfmt+0x37c>
				putch('-', putdat);
  800910:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800914:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80091b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80091e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800921:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800924:	f7 d8                	neg    %eax
  800926:	83 d2 00             	adc    $0x0,%edx
  800929:	f7 da                	neg    %edx
			base = 10;
  80092b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800930:	eb 5e                	jmp    800990 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800932:	8d 45 14             	lea    0x14(%ebp),%eax
  800935:	e8 5b fc ff ff       	call   800595 <getuint>
			base = 10;
  80093a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80093f:	eb 4f                	jmp    800990 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800941:	8d 45 14             	lea    0x14(%ebp),%eax
  800944:	e8 4c fc ff ff       	call   800595 <getuint>
			base = 8;
  800949:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80094e:	eb 40                	jmp    800990 <vprintfmt+0x37c>
			putch('0', putdat);
  800950:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800954:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80095b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80095e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800962:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800969:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80096c:	8b 45 14             	mov    0x14(%ebp),%eax
  80096f:	8d 50 04             	lea    0x4(%eax),%edx
  800972:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800975:	8b 00                	mov    (%eax),%eax
  800977:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80097c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800981:	eb 0d                	jmp    800990 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800983:	8d 45 14             	lea    0x14(%ebp),%eax
  800986:	e8 0a fc ff ff       	call   800595 <getuint>
			base = 16;
  80098b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800990:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800994:	89 74 24 10          	mov    %esi,0x10(%esp)
  800998:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80099b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80099f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009a3:	89 04 24             	mov    %eax,(%esp)
  8009a6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009aa:	89 fa                	mov    %edi,%edx
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	e8 ec fa ff ff       	call   8004a0 <printnum>
			break;
  8009b4:	e9 84 fc ff ff       	jmp    80063d <vprintfmt+0x29>
			putch(ch, putdat);
  8009b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009bd:	89 0c 24             	mov    %ecx,(%esp)
  8009c0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009c3:	e9 75 fc ff ff       	jmp    80063d <vprintfmt+0x29>
			putch('%', putdat);
  8009c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009cc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009d3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009d6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009da:	0f 84 5b fc ff ff    	je     80063b <vprintfmt+0x27>
  8009e0:	89 f3                	mov    %esi,%ebx
  8009e2:	83 eb 01             	sub    $0x1,%ebx
  8009e5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8009e9:	75 f7                	jne    8009e2 <vprintfmt+0x3ce>
  8009eb:	e9 4d fc ff ff       	jmp    80063d <vprintfmt+0x29>
}
  8009f0:	83 c4 3c             	add    $0x3c,%esp
  8009f3:	5b                   	pop    %ebx
  8009f4:	5e                   	pop    %esi
  8009f5:	5f                   	pop    %edi
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	83 ec 28             	sub    $0x28,%esp
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a04:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a07:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a0b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a15:	85 c0                	test   %eax,%eax
  800a17:	74 30                	je     800a49 <vsnprintf+0x51>
  800a19:	85 d2                	test   %edx,%edx
  800a1b:	7e 2c                	jle    800a49 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a20:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a24:	8b 45 10             	mov    0x10(%ebp),%eax
  800a27:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a2b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a32:	c7 04 24 cf 05 80 00 	movl   $0x8005cf,(%esp)
  800a39:	e8 d6 fb ff ff       	call   800614 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a41:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a47:	eb 05                	jmp    800a4e <vsnprintf+0x56>
		return -E_INVAL;
  800a49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a56:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a5d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a60:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a67:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	89 04 24             	mov    %eax,(%esp)
  800a71:	e8 82 ff ff ff       	call   8009f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    
  800a78:	66 90                	xchg   %ax,%ax
  800a7a:	66 90                	xchg   %ax,%ax
  800a7c:	66 90                	xchg   %ax,%ax
  800a7e:	66 90                	xchg   %ax,%ax

00800a80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a86:	80 3a 00             	cmpb   $0x0,(%edx)
  800a89:	74 10                	je     800a9b <strlen+0x1b>
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a90:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a93:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a97:	75 f7                	jne    800a90 <strlen+0x10>
  800a99:	eb 05                	jmp    800aa0 <strlen+0x20>
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	53                   	push   %ebx
  800aa6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800aa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aac:	85 c9                	test   %ecx,%ecx
  800aae:	74 1c                	je     800acc <strnlen+0x2a>
  800ab0:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ab3:	74 1e                	je     800ad3 <strnlen+0x31>
  800ab5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800aba:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800abc:	39 ca                	cmp    %ecx,%edx
  800abe:	74 18                	je     800ad8 <strnlen+0x36>
  800ac0:	83 c2 01             	add    $0x1,%edx
  800ac3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800ac8:	75 f0                	jne    800aba <strnlen+0x18>
  800aca:	eb 0c                	jmp    800ad8 <strnlen+0x36>
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad1:	eb 05                	jmp    800ad8 <strnlen+0x36>
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	53                   	push   %ebx
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ae5:	89 c2                	mov    %eax,%edx
  800ae7:	83 c2 01             	add    $0x1,%edx
  800aea:	83 c1 01             	add    $0x1,%ecx
  800aed:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800af1:	88 5a ff             	mov    %bl,-0x1(%edx)
  800af4:	84 db                	test   %bl,%bl
  800af6:	75 ef                	jne    800ae7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800af8:	5b                   	pop    %ebx
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	83 ec 08             	sub    $0x8,%esp
  800b02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b05:	89 1c 24             	mov    %ebx,(%esp)
  800b08:	e8 73 ff ff ff       	call   800a80 <strlen>
	strcpy(dst + len, src);
  800b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b10:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b14:	01 d8                	add    %ebx,%eax
  800b16:	89 04 24             	mov    %eax,(%esp)
  800b19:	e8 bd ff ff ff       	call   800adb <strcpy>
	return dst;
}
  800b1e:	89 d8                	mov    %ebx,%eax
  800b20:	83 c4 08             	add    $0x8,%esp
  800b23:	5b                   	pop    %ebx
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	8b 75 08             	mov    0x8(%ebp),%esi
  800b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b34:	85 db                	test   %ebx,%ebx
  800b36:	74 17                	je     800b4f <strncpy+0x29>
  800b38:	01 f3                	add    %esi,%ebx
  800b3a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800b3c:	83 c1 01             	add    $0x1,%ecx
  800b3f:	0f b6 02             	movzbl (%edx),%eax
  800b42:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b45:	80 3a 01             	cmpb   $0x1,(%edx)
  800b48:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800b4b:	39 d9                	cmp    %ebx,%ecx
  800b4d:	75 ed                	jne    800b3c <strncpy+0x16>
	}
	return ret;
}
  800b4f:	89 f0                	mov    %esi,%eax
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b61:	8b 75 10             	mov    0x10(%ebp),%esi
  800b64:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b66:	85 f6                	test   %esi,%esi
  800b68:	74 34                	je     800b9e <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800b6a:	83 fe 01             	cmp    $0x1,%esi
  800b6d:	74 26                	je     800b95 <strlcpy+0x40>
  800b6f:	0f b6 0b             	movzbl (%ebx),%ecx
  800b72:	84 c9                	test   %cl,%cl
  800b74:	74 23                	je     800b99 <strlcpy+0x44>
  800b76:	83 ee 02             	sub    $0x2,%esi
  800b79:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  800b7e:	83 c0 01             	add    $0x1,%eax
  800b81:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800b84:	39 f2                	cmp    %esi,%edx
  800b86:	74 13                	je     800b9b <strlcpy+0x46>
  800b88:	83 c2 01             	add    $0x1,%edx
  800b8b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b8f:	84 c9                	test   %cl,%cl
  800b91:	75 eb                	jne    800b7e <strlcpy+0x29>
  800b93:	eb 06                	jmp    800b9b <strlcpy+0x46>
  800b95:	89 f8                	mov    %edi,%eax
  800b97:	eb 02                	jmp    800b9b <strlcpy+0x46>
  800b99:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  800b9b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b9e:	29 f8                	sub    %edi,%eax
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bae:	0f b6 01             	movzbl (%ecx),%eax
  800bb1:	84 c0                	test   %al,%al
  800bb3:	74 15                	je     800bca <strcmp+0x25>
  800bb5:	3a 02                	cmp    (%edx),%al
  800bb7:	75 11                	jne    800bca <strcmp+0x25>
		p++, q++;
  800bb9:	83 c1 01             	add    $0x1,%ecx
  800bbc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800bbf:	0f b6 01             	movzbl (%ecx),%eax
  800bc2:	84 c0                	test   %al,%al
  800bc4:	74 04                	je     800bca <strcmp+0x25>
  800bc6:	3a 02                	cmp    (%edx),%al
  800bc8:	74 ef                	je     800bb9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bca:	0f b6 c0             	movzbl %al,%eax
  800bcd:	0f b6 12             	movzbl (%edx),%edx
  800bd0:	29 d0                	sub    %edx,%eax
}
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bdf:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800be2:	85 f6                	test   %esi,%esi
  800be4:	74 29                	je     800c0f <strncmp+0x3b>
  800be6:	0f b6 03             	movzbl (%ebx),%eax
  800be9:	84 c0                	test   %al,%al
  800beb:	74 30                	je     800c1d <strncmp+0x49>
  800bed:	3a 02                	cmp    (%edx),%al
  800bef:	75 2c                	jne    800c1d <strncmp+0x49>
  800bf1:	8d 43 01             	lea    0x1(%ebx),%eax
  800bf4:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800bf6:	89 c3                	mov    %eax,%ebx
  800bf8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800bfb:	39 f0                	cmp    %esi,%eax
  800bfd:	74 17                	je     800c16 <strncmp+0x42>
  800bff:	0f b6 08             	movzbl (%eax),%ecx
  800c02:	84 c9                	test   %cl,%cl
  800c04:	74 17                	je     800c1d <strncmp+0x49>
  800c06:	83 c0 01             	add    $0x1,%eax
  800c09:	3a 0a                	cmp    (%edx),%cl
  800c0b:	74 e9                	je     800bf6 <strncmp+0x22>
  800c0d:	eb 0e                	jmp    800c1d <strncmp+0x49>
	if (n == 0)
		return 0;
  800c0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c14:	eb 0f                	jmp    800c25 <strncmp+0x51>
  800c16:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1b:	eb 08                	jmp    800c25 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c1d:	0f b6 03             	movzbl (%ebx),%eax
  800c20:	0f b6 12             	movzbl (%edx),%edx
  800c23:	29 d0                	sub    %edx,%eax
}
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	53                   	push   %ebx
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c30:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c33:	0f b6 18             	movzbl (%eax),%ebx
  800c36:	84 db                	test   %bl,%bl
  800c38:	74 1d                	je     800c57 <strchr+0x2e>
  800c3a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800c3c:	38 d3                	cmp    %dl,%bl
  800c3e:	75 06                	jne    800c46 <strchr+0x1d>
  800c40:	eb 1a                	jmp    800c5c <strchr+0x33>
  800c42:	38 ca                	cmp    %cl,%dl
  800c44:	74 16                	je     800c5c <strchr+0x33>
	for (; *s; s++)
  800c46:	83 c0 01             	add    $0x1,%eax
  800c49:	0f b6 10             	movzbl (%eax),%edx
  800c4c:	84 d2                	test   %dl,%dl
  800c4e:	75 f2                	jne    800c42 <strchr+0x19>
			return (char *) s;
	return 0;
  800c50:	b8 00 00 00 00       	mov    $0x0,%eax
  800c55:	eb 05                	jmp    800c5c <strchr+0x33>
  800c57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	53                   	push   %ebx
  800c63:	8b 45 08             	mov    0x8(%ebp),%eax
  800c66:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c69:	0f b6 18             	movzbl (%eax),%ebx
  800c6c:	84 db                	test   %bl,%bl
  800c6e:	74 16                	je     800c86 <strfind+0x27>
  800c70:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800c72:	38 d3                	cmp    %dl,%bl
  800c74:	75 06                	jne    800c7c <strfind+0x1d>
  800c76:	eb 0e                	jmp    800c86 <strfind+0x27>
  800c78:	38 ca                	cmp    %cl,%dl
  800c7a:	74 0a                	je     800c86 <strfind+0x27>
	for (; *s; s++)
  800c7c:	83 c0 01             	add    $0x1,%eax
  800c7f:	0f b6 10             	movzbl (%eax),%edx
  800c82:	84 d2                	test   %dl,%dl
  800c84:	75 f2                	jne    800c78 <strfind+0x19>
			break;
	return (char *) s;
}
  800c86:	5b                   	pop    %ebx
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c95:	85 c9                	test   %ecx,%ecx
  800c97:	74 36                	je     800ccf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c99:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9f:	75 28                	jne    800cc9 <memset+0x40>
  800ca1:	f6 c1 03             	test   $0x3,%cl
  800ca4:	75 23                	jne    800cc9 <memset+0x40>
		c &= 0xFF;
  800ca6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800caa:	89 d3                	mov    %edx,%ebx
  800cac:	c1 e3 08             	shl    $0x8,%ebx
  800caf:	89 d6                	mov    %edx,%esi
  800cb1:	c1 e6 18             	shl    $0x18,%esi
  800cb4:	89 d0                	mov    %edx,%eax
  800cb6:	c1 e0 10             	shl    $0x10,%eax
  800cb9:	09 f0                	or     %esi,%eax
  800cbb:	09 c2                	or     %eax,%edx
  800cbd:	89 d0                	mov    %edx,%eax
  800cbf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cc1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800cc4:	fc                   	cld    
  800cc5:	f3 ab                	rep stos %eax,%es:(%edi)
  800cc7:	eb 06                	jmp    800ccf <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccc:	fc                   	cld    
  800ccd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ccf:	89 f8                	mov    %edi,%eax
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce4:	39 c6                	cmp    %eax,%esi
  800ce6:	73 35                	jae    800d1d <memmove+0x47>
  800ce8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ceb:	39 d0                	cmp    %edx,%eax
  800ced:	73 2e                	jae    800d1d <memmove+0x47>
		s += n;
		d += n;
  800cef:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800cf2:	89 d6                	mov    %edx,%esi
  800cf4:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfc:	75 13                	jne    800d11 <memmove+0x3b>
  800cfe:	f6 c1 03             	test   $0x3,%cl
  800d01:	75 0e                	jne    800d11 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d03:	83 ef 04             	sub    $0x4,%edi
  800d06:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d09:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d0c:	fd                   	std    
  800d0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0f:	eb 09                	jmp    800d1a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d11:	83 ef 01             	sub    $0x1,%edi
  800d14:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d17:	fd                   	std    
  800d18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d1a:	fc                   	cld    
  800d1b:	eb 1d                	jmp    800d3a <memmove+0x64>
  800d1d:	89 f2                	mov    %esi,%edx
  800d1f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d21:	f6 c2 03             	test   $0x3,%dl
  800d24:	75 0f                	jne    800d35 <memmove+0x5f>
  800d26:	f6 c1 03             	test   $0x3,%cl
  800d29:	75 0a                	jne    800d35 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d2b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d2e:	89 c7                	mov    %eax,%edi
  800d30:	fc                   	cld    
  800d31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d33:	eb 05                	jmp    800d3a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800d35:	89 c7                	mov    %eax,%edi
  800d37:	fc                   	cld    
  800d38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    

00800d3e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d44:	8b 45 10             	mov    0x10(%ebp),%eax
  800d47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	89 04 24             	mov    %eax,(%esp)
  800d58:	e8 79 ff ff ff       	call   800cd6 <memmove>
}
  800d5d:	c9                   	leave  
  800d5e:	c3                   	ret    

00800d5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d6b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d6e:	8d 78 ff             	lea    -0x1(%eax),%edi
  800d71:	85 c0                	test   %eax,%eax
  800d73:	74 36                	je     800dab <memcmp+0x4c>
		if (*s1 != *s2)
  800d75:	0f b6 03             	movzbl (%ebx),%eax
  800d78:	0f b6 0e             	movzbl (%esi),%ecx
  800d7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d80:	38 c8                	cmp    %cl,%al
  800d82:	74 1c                	je     800da0 <memcmp+0x41>
  800d84:	eb 10                	jmp    800d96 <memcmp+0x37>
  800d86:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800d8b:	83 c2 01             	add    $0x1,%edx
  800d8e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800d92:	38 c8                	cmp    %cl,%al
  800d94:	74 0a                	je     800da0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800d96:	0f b6 c0             	movzbl %al,%eax
  800d99:	0f b6 c9             	movzbl %cl,%ecx
  800d9c:	29 c8                	sub    %ecx,%eax
  800d9e:	eb 10                	jmp    800db0 <memcmp+0x51>
	while (n-- > 0) {
  800da0:	39 fa                	cmp    %edi,%edx
  800da2:	75 e2                	jne    800d86 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  800da4:	b8 00 00 00 00       	mov    $0x0,%eax
  800da9:	eb 05                	jmp    800db0 <memcmp+0x51>
  800dab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	53                   	push   %ebx
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800dbf:	89 c2                	mov    %eax,%edx
  800dc1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800dc4:	39 d0                	cmp    %edx,%eax
  800dc6:	73 13                	jae    800ddb <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dc8:	89 d9                	mov    %ebx,%ecx
  800dca:	38 18                	cmp    %bl,(%eax)
  800dcc:	75 06                	jne    800dd4 <memfind+0x1f>
  800dce:	eb 0b                	jmp    800ddb <memfind+0x26>
  800dd0:	38 08                	cmp    %cl,(%eax)
  800dd2:	74 07                	je     800ddb <memfind+0x26>
	for (; s < ends; s++)
  800dd4:	83 c0 01             	add    $0x1,%eax
  800dd7:	39 d0                	cmp    %edx,%eax
  800dd9:	75 f5                	jne    800dd0 <memfind+0x1b>
			break;
	return (void *) s;
}
  800ddb:	5b                   	pop    %ebx
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dea:	0f b6 0a             	movzbl (%edx),%ecx
  800ded:	80 f9 09             	cmp    $0x9,%cl
  800df0:	74 05                	je     800df7 <strtol+0x19>
  800df2:	80 f9 20             	cmp    $0x20,%cl
  800df5:	75 10                	jne    800e07 <strtol+0x29>
		s++;
  800df7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800dfa:	0f b6 0a             	movzbl (%edx),%ecx
  800dfd:	80 f9 09             	cmp    $0x9,%cl
  800e00:	74 f5                	je     800df7 <strtol+0x19>
  800e02:	80 f9 20             	cmp    $0x20,%cl
  800e05:	74 f0                	je     800df7 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  800e07:	80 f9 2b             	cmp    $0x2b,%cl
  800e0a:	75 0a                	jne    800e16 <strtol+0x38>
		s++;
  800e0c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800e0f:	bf 00 00 00 00       	mov    $0x0,%edi
  800e14:	eb 11                	jmp    800e27 <strtol+0x49>
  800e16:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800e1b:	80 f9 2d             	cmp    $0x2d,%cl
  800e1e:	75 07                	jne    800e27 <strtol+0x49>
		s++, neg = 1;
  800e20:	83 c2 01             	add    $0x1,%edx
  800e23:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e27:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800e2c:	75 15                	jne    800e43 <strtol+0x65>
  800e2e:	80 3a 30             	cmpb   $0x30,(%edx)
  800e31:	75 10                	jne    800e43 <strtol+0x65>
  800e33:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e37:	75 0a                	jne    800e43 <strtol+0x65>
		s += 2, base = 16;
  800e39:	83 c2 02             	add    $0x2,%edx
  800e3c:	b8 10 00 00 00       	mov    $0x10,%eax
  800e41:	eb 10                	jmp    800e53 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  800e43:	85 c0                	test   %eax,%eax
  800e45:	75 0c                	jne    800e53 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e47:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800e49:	80 3a 30             	cmpb   $0x30,(%edx)
  800e4c:	75 05                	jne    800e53 <strtol+0x75>
		s++, base = 8;
  800e4e:	83 c2 01             	add    $0x1,%edx
  800e51:	b0 08                	mov    $0x8,%al
		base = 10;
  800e53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e58:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e5b:	0f b6 0a             	movzbl (%edx),%ecx
  800e5e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800e61:	89 f0                	mov    %esi,%eax
  800e63:	3c 09                	cmp    $0x9,%al
  800e65:	77 08                	ja     800e6f <strtol+0x91>
			dig = *s - '0';
  800e67:	0f be c9             	movsbl %cl,%ecx
  800e6a:	83 e9 30             	sub    $0x30,%ecx
  800e6d:	eb 20                	jmp    800e8f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  800e6f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800e72:	89 f0                	mov    %esi,%eax
  800e74:	3c 19                	cmp    $0x19,%al
  800e76:	77 08                	ja     800e80 <strtol+0xa2>
			dig = *s - 'a' + 10;
  800e78:	0f be c9             	movsbl %cl,%ecx
  800e7b:	83 e9 57             	sub    $0x57,%ecx
  800e7e:	eb 0f                	jmp    800e8f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  800e80:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e83:	89 f0                	mov    %esi,%eax
  800e85:	3c 19                	cmp    $0x19,%al
  800e87:	77 16                	ja     800e9f <strtol+0xc1>
			dig = *s - 'A' + 10;
  800e89:	0f be c9             	movsbl %cl,%ecx
  800e8c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e8f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e92:	7d 0f                	jge    800ea3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800e94:	83 c2 01             	add    $0x1,%edx
  800e97:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e9b:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e9d:	eb bc                	jmp    800e5b <strtol+0x7d>
  800e9f:	89 d8                	mov    %ebx,%eax
  800ea1:	eb 02                	jmp    800ea5 <strtol+0xc7>
  800ea3:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800ea5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ea9:	74 05                	je     800eb0 <strtol+0xd2>
		*endptr = (char *) s;
  800eab:	8b 75 0c             	mov    0xc(%ebp),%esi
  800eae:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800eb0:	f7 d8                	neg    %eax
  800eb2:	85 ff                	test   %edi,%edi
  800eb4:	0f 44 c3             	cmove  %ebx,%eax
}
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    
  800ebc:	66 90                	xchg   %ax,%ax
  800ebe:	66 90                	xchg   %ax,%ax

00800ec0 <__udivdi3>:
  800ec0:	55                   	push   %ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	83 ec 0c             	sub    $0xc,%esp
  800ec6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800eca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800ece:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800ed2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800edc:	89 ea                	mov    %ebp,%edx
  800ede:	89 0c 24             	mov    %ecx,(%esp)
  800ee1:	75 2d                	jne    800f10 <__udivdi3+0x50>
  800ee3:	39 e9                	cmp    %ebp,%ecx
  800ee5:	77 61                	ja     800f48 <__udivdi3+0x88>
  800ee7:	85 c9                	test   %ecx,%ecx
  800ee9:	89 ce                	mov    %ecx,%esi
  800eeb:	75 0b                	jne    800ef8 <__udivdi3+0x38>
  800eed:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef2:	31 d2                	xor    %edx,%edx
  800ef4:	f7 f1                	div    %ecx
  800ef6:	89 c6                	mov    %eax,%esi
  800ef8:	31 d2                	xor    %edx,%edx
  800efa:	89 e8                	mov    %ebp,%eax
  800efc:	f7 f6                	div    %esi
  800efe:	89 c5                	mov    %eax,%ebp
  800f00:	89 f8                	mov    %edi,%eax
  800f02:	f7 f6                	div    %esi
  800f04:	89 ea                	mov    %ebp,%edx
  800f06:	83 c4 0c             	add    $0xc,%esp
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    
  800f0d:	8d 76 00             	lea    0x0(%esi),%esi
  800f10:	39 e8                	cmp    %ebp,%eax
  800f12:	77 24                	ja     800f38 <__udivdi3+0x78>
  800f14:	0f bd e8             	bsr    %eax,%ebp
  800f17:	83 f5 1f             	xor    $0x1f,%ebp
  800f1a:	75 3c                	jne    800f58 <__udivdi3+0x98>
  800f1c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f20:	39 34 24             	cmp    %esi,(%esp)
  800f23:	0f 86 9f 00 00 00    	jbe    800fc8 <__udivdi3+0x108>
  800f29:	39 d0                	cmp    %edx,%eax
  800f2b:	0f 82 97 00 00 00    	jb     800fc8 <__udivdi3+0x108>
  800f31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f38:	31 d2                	xor    %edx,%edx
  800f3a:	31 c0                	xor    %eax,%eax
  800f3c:	83 c4 0c             	add    $0xc,%esp
  800f3f:	5e                   	pop    %esi
  800f40:	5f                   	pop    %edi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    
  800f43:	90                   	nop
  800f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f48:	89 f8                	mov    %edi,%eax
  800f4a:	f7 f1                	div    %ecx
  800f4c:	31 d2                	xor    %edx,%edx
  800f4e:	83 c4 0c             	add    $0xc,%esp
  800f51:	5e                   	pop    %esi
  800f52:	5f                   	pop    %edi
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    
  800f55:	8d 76 00             	lea    0x0(%esi),%esi
  800f58:	89 e9                	mov    %ebp,%ecx
  800f5a:	8b 3c 24             	mov    (%esp),%edi
  800f5d:	d3 e0                	shl    %cl,%eax
  800f5f:	89 c6                	mov    %eax,%esi
  800f61:	b8 20 00 00 00       	mov    $0x20,%eax
  800f66:	29 e8                	sub    %ebp,%eax
  800f68:	89 c1                	mov    %eax,%ecx
  800f6a:	d3 ef                	shr    %cl,%edi
  800f6c:	89 e9                	mov    %ebp,%ecx
  800f6e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f72:	8b 3c 24             	mov    (%esp),%edi
  800f75:	09 74 24 08          	or     %esi,0x8(%esp)
  800f79:	89 d6                	mov    %edx,%esi
  800f7b:	d3 e7                	shl    %cl,%edi
  800f7d:	89 c1                	mov    %eax,%ecx
  800f7f:	89 3c 24             	mov    %edi,(%esp)
  800f82:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f86:	d3 ee                	shr    %cl,%esi
  800f88:	89 e9                	mov    %ebp,%ecx
  800f8a:	d3 e2                	shl    %cl,%edx
  800f8c:	89 c1                	mov    %eax,%ecx
  800f8e:	d3 ef                	shr    %cl,%edi
  800f90:	09 d7                	or     %edx,%edi
  800f92:	89 f2                	mov    %esi,%edx
  800f94:	89 f8                	mov    %edi,%eax
  800f96:	f7 74 24 08          	divl   0x8(%esp)
  800f9a:	89 d6                	mov    %edx,%esi
  800f9c:	89 c7                	mov    %eax,%edi
  800f9e:	f7 24 24             	mull   (%esp)
  800fa1:	39 d6                	cmp    %edx,%esi
  800fa3:	89 14 24             	mov    %edx,(%esp)
  800fa6:	72 30                	jb     800fd8 <__udivdi3+0x118>
  800fa8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fac:	89 e9                	mov    %ebp,%ecx
  800fae:	d3 e2                	shl    %cl,%edx
  800fb0:	39 c2                	cmp    %eax,%edx
  800fb2:	73 05                	jae    800fb9 <__udivdi3+0xf9>
  800fb4:	3b 34 24             	cmp    (%esp),%esi
  800fb7:	74 1f                	je     800fd8 <__udivdi3+0x118>
  800fb9:	89 f8                	mov    %edi,%eax
  800fbb:	31 d2                	xor    %edx,%edx
  800fbd:	e9 7a ff ff ff       	jmp    800f3c <__udivdi3+0x7c>
  800fc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fc8:	31 d2                	xor    %edx,%edx
  800fca:	b8 01 00 00 00       	mov    $0x1,%eax
  800fcf:	e9 68 ff ff ff       	jmp    800f3c <__udivdi3+0x7c>
  800fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fd8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800fdb:	31 d2                	xor    %edx,%edx
  800fdd:	83 c4 0c             	add    $0xc,%esp
  800fe0:	5e                   	pop    %esi
  800fe1:	5f                   	pop    %edi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    
  800fe4:	66 90                	xchg   %ax,%ax
  800fe6:	66 90                	xchg   %ax,%ax
  800fe8:	66 90                	xchg   %ax,%ax
  800fea:	66 90                	xchg   %ax,%ax
  800fec:	66 90                	xchg   %ax,%ax
  800fee:	66 90                	xchg   %ax,%ax

00800ff0 <__umoddi3>:
  800ff0:	55                   	push   %ebp
  800ff1:	57                   	push   %edi
  800ff2:	56                   	push   %esi
  800ff3:	83 ec 14             	sub    $0x14,%esp
  800ff6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800ffa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800ffe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801002:	89 c7                	mov    %eax,%edi
  801004:	89 44 24 04          	mov    %eax,0x4(%esp)
  801008:	8b 44 24 30          	mov    0x30(%esp),%eax
  80100c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801010:	89 34 24             	mov    %esi,(%esp)
  801013:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801017:	85 c0                	test   %eax,%eax
  801019:	89 c2                	mov    %eax,%edx
  80101b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80101f:	75 17                	jne    801038 <__umoddi3+0x48>
  801021:	39 fe                	cmp    %edi,%esi
  801023:	76 4b                	jbe    801070 <__umoddi3+0x80>
  801025:	89 c8                	mov    %ecx,%eax
  801027:	89 fa                	mov    %edi,%edx
  801029:	f7 f6                	div    %esi
  80102b:	89 d0                	mov    %edx,%eax
  80102d:	31 d2                	xor    %edx,%edx
  80102f:	83 c4 14             	add    $0x14,%esp
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    
  801036:	66 90                	xchg   %ax,%ax
  801038:	39 f8                	cmp    %edi,%eax
  80103a:	77 54                	ja     801090 <__umoddi3+0xa0>
  80103c:	0f bd e8             	bsr    %eax,%ebp
  80103f:	83 f5 1f             	xor    $0x1f,%ebp
  801042:	75 5c                	jne    8010a0 <__umoddi3+0xb0>
  801044:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801048:	39 3c 24             	cmp    %edi,(%esp)
  80104b:	0f 87 e7 00 00 00    	ja     801138 <__umoddi3+0x148>
  801051:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801055:	29 f1                	sub    %esi,%ecx
  801057:	19 c7                	sbb    %eax,%edi
  801059:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80105d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801061:	8b 44 24 08          	mov    0x8(%esp),%eax
  801065:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801069:	83 c4 14             	add    $0x14,%esp
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    
  801070:	85 f6                	test   %esi,%esi
  801072:	89 f5                	mov    %esi,%ebp
  801074:	75 0b                	jne    801081 <__umoddi3+0x91>
  801076:	b8 01 00 00 00       	mov    $0x1,%eax
  80107b:	31 d2                	xor    %edx,%edx
  80107d:	f7 f6                	div    %esi
  80107f:	89 c5                	mov    %eax,%ebp
  801081:	8b 44 24 04          	mov    0x4(%esp),%eax
  801085:	31 d2                	xor    %edx,%edx
  801087:	f7 f5                	div    %ebp
  801089:	89 c8                	mov    %ecx,%eax
  80108b:	f7 f5                	div    %ebp
  80108d:	eb 9c                	jmp    80102b <__umoddi3+0x3b>
  80108f:	90                   	nop
  801090:	89 c8                	mov    %ecx,%eax
  801092:	89 fa                	mov    %edi,%edx
  801094:	83 c4 14             	add    $0x14,%esp
  801097:	5e                   	pop    %esi
  801098:	5f                   	pop    %edi
  801099:	5d                   	pop    %ebp
  80109a:	c3                   	ret    
  80109b:	90                   	nop
  80109c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010a0:	8b 04 24             	mov    (%esp),%eax
  8010a3:	be 20 00 00 00       	mov    $0x20,%esi
  8010a8:	89 e9                	mov    %ebp,%ecx
  8010aa:	29 ee                	sub    %ebp,%esi
  8010ac:	d3 e2                	shl    %cl,%edx
  8010ae:	89 f1                	mov    %esi,%ecx
  8010b0:	d3 e8                	shr    %cl,%eax
  8010b2:	89 e9                	mov    %ebp,%ecx
  8010b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b8:	8b 04 24             	mov    (%esp),%eax
  8010bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8010bf:	89 fa                	mov    %edi,%edx
  8010c1:	d3 e0                	shl    %cl,%eax
  8010c3:	89 f1                	mov    %esi,%ecx
  8010c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8010cd:	d3 ea                	shr    %cl,%edx
  8010cf:	89 e9                	mov    %ebp,%ecx
  8010d1:	d3 e7                	shl    %cl,%edi
  8010d3:	89 f1                	mov    %esi,%ecx
  8010d5:	d3 e8                	shr    %cl,%eax
  8010d7:	89 e9                	mov    %ebp,%ecx
  8010d9:	09 f8                	or     %edi,%eax
  8010db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8010df:	f7 74 24 04          	divl   0x4(%esp)
  8010e3:	d3 e7                	shl    %cl,%edi
  8010e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010e9:	89 d7                	mov    %edx,%edi
  8010eb:	f7 64 24 08          	mull   0x8(%esp)
  8010ef:	39 d7                	cmp    %edx,%edi
  8010f1:	89 c1                	mov    %eax,%ecx
  8010f3:	89 14 24             	mov    %edx,(%esp)
  8010f6:	72 2c                	jb     801124 <__umoddi3+0x134>
  8010f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8010fc:	72 22                	jb     801120 <__umoddi3+0x130>
  8010fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801102:	29 c8                	sub    %ecx,%eax
  801104:	19 d7                	sbb    %edx,%edi
  801106:	89 e9                	mov    %ebp,%ecx
  801108:	89 fa                	mov    %edi,%edx
  80110a:	d3 e8                	shr    %cl,%eax
  80110c:	89 f1                	mov    %esi,%ecx
  80110e:	d3 e2                	shl    %cl,%edx
  801110:	89 e9                	mov    %ebp,%ecx
  801112:	d3 ef                	shr    %cl,%edi
  801114:	09 d0                	or     %edx,%eax
  801116:	89 fa                	mov    %edi,%edx
  801118:	83 c4 14             	add    $0x14,%esp
  80111b:	5e                   	pop    %esi
  80111c:	5f                   	pop    %edi
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    
  80111f:	90                   	nop
  801120:	39 d7                	cmp    %edx,%edi
  801122:	75 da                	jne    8010fe <__umoddi3+0x10e>
  801124:	8b 14 24             	mov    (%esp),%edx
  801127:	89 c1                	mov    %eax,%ecx
  801129:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80112d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801131:	eb cb                	jmp    8010fe <__umoddi3+0x10e>
  801133:	90                   	nop
  801134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801138:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80113c:	0f 82 0f ff ff ff    	jb     801051 <__umoddi3+0x61>
  801142:	e9 1a ff ff ff       	jmp    801061 <__umoddi3+0x71>
